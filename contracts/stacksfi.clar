;; Title: StacksFi - Real-World Asset Tokenization Platform
;;
;; Summary: 
;; A comprehensive DeFi protocol for tokenizing real-world assets with built-in
;; governance, dividend distribution, and compliance features on Stacks Layer 2.
;;
;; Description:
;; StacksFi revolutionizes traditional asset ownership by enabling fractional 
;; tokenization of real-world assets through Semi-Fungible Tokens (SFTs). The 
;; platform provides institutional-grade features including automated dividend 
;; distribution, decentralized governance voting, KYC compliance integration, 
;; and real-time price oracle feeds. Built specifically for Stacks Layer 2 to 
;; leverage Bitcoin's security while maintaining low transaction costs and high 
;; throughput for enterprise adoption.
;;
;; Key Features:
;; - Asset tokenization with configurable fractional ownership
;; - Automated dividend distribution and claiming mechanisms  
;; - Decentralized governance with weighted voting rights
;; - Integrated KYC/AML compliance framework
;; - Real-time price oracle integration for asset valuation
;; - Enterprise-grade access controls and security measures

;; CONSTANTS & CONFIGURATION

;; Administrative Configuration
(define-constant contract-owner tx-sender)

;; Error Codes - Access Control & Authorization
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u104))

;; Error Codes - Asset Management & Operations
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))

;; Error Codes - Regulatory Compliance
(define-constant err-kyc-required (err u105))
(define-constant err-price-expired (err u108))

;; Error Codes - Governance & Voting
(define-constant err-vote-exists (err u106))
(define-constant err-vote-ended (err u107))

;; Error Codes - Input Validation
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-value (err u111))
(define-constant err-invalid-duration (err u112))
(define-constant err-invalid-kyc-level (err u113))
(define-constant err-invalid-expiry (err u114))
(define-constant err-invalid-votes (err u115))
(define-constant err-invalid-address (err u116))
(define-constant err-invalid-title (err u117))

;; Asset Value Constraints
(define-constant MAX-ASSET-VALUE u1000000000000) ;; 1 trillion STX (institutional assets)
(define-constant MIN-ASSET-VALUE u1000) ;; 1 thousand STX (minimum viable asset)

;; Governance Time Constraints (in Stacks blocks)
(define-constant MAX-DURATION u144) ;; ~24 hours (1 day voting period)
(define-constant MIN-DURATION u12) ;; ~2 hours (minimum voting period)

;; Compliance Configuration
(define-constant MAX-KYC-LEVEL u5) ;; Maximum KYC verification level
(define-constant MAX-EXPIRY u52560) ;; ~365 days (1 year maximum expiry)

;; Tokenization Configuration
(define-constant tokens-per-asset u100000) ;; Standard SFT supply per asset (100k tokens)

;; STATE VARIABLES

;; Global Counters
(define-data-var last-asset-id uint u0)
(define-data-var last-proposal-id uint u0)

;; DATA STRUCTURES

;; Core Asset Registry
(define-map assets
  { asset-id: uint }
  {
    owner: principal, ;; Asset owner/registrant
    metadata-uri: (string-ascii 256), ;; IPFS/Arweave metadata URI
    asset-value: uint, ;; Current asset valuation in STX
    is-locked: bool, ;; Asset transfer lock status
    creation-height: uint, ;; Registration block height
    last-price-update: uint, ;; Last price oracle update
    total-dividends: uint, ;; Cumulative dividend pool
  }
)

;; Token Ownership Ledger
(define-map token-balances
  {
    owner: principal,
    asset-id: uint,
  }
  { balance: uint } ;; SFT token balance
)

;; KYC/AML Compliance Registry
(define-map kyc-status
  { address: principal }
  {
    is-approved: bool, ;; KYC approval status
    level: uint, ;; Verification level (1-5)
    expiry: uint, ;; KYC expiration block
  }
)

;; Governance Proposal Registry
(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 256), ;; Proposal title/description
    asset-id: uint, ;; Target asset ID
    start-height: uint, ;; Voting start block
    end-height: uint, ;; Voting end block
    executed: bool, ;; Execution status
    votes-for: uint, ;; Supporting votes (weighted)
    votes-against: uint, ;; Opposition votes (weighted)
    minimum-votes: uint, ;; Quorum threshold
  }
)

;; Voting Records Ledger
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  { vote-amount: uint } ;; Weighted vote amount
)

;; Dividend Distribution Tracking
(define-map dividend-claims
  {
    asset-id: uint,
    claimer: principal,
  }
  { last-claimed-amount: uint } ;; Last claimed dividend total
)

;; Price Oracle Integration
(define-map price-feeds
  { asset-id: uint }
  {
    price: uint, ;; Current asset price
    decimals: uint, ;; Price decimal precision
    last-updated: uint, ;; Last oracle update block
    oracle: principal, ;; Authorized oracle address
  }
)

;; VALIDATION FUNCTIONS

;; Validate asset value within economic constraints
(define-private (validate-asset-value (value uint))
  (and
    (>= value MIN-ASSET-VALUE)
    (<= value MAX-ASSET-VALUE)
  )
)

;; Validate governance proposal duration
(define-private (validate-duration (duration uint))
  (and
    (>= duration MIN-DURATION)
    (<= duration MAX-DURATION)
  )
)

;; Validate KYC verification level
(define-private (validate-kyc-level (level uint))
  (<= level MAX-KYC-LEVEL)
)

;; Validate expiry timestamp constraints
(define-private (validate-expiry (expiry uint))
  (and
    (> expiry stacks-block-height)
    (<= (- expiry stacks-block-height) MAX-EXPIRY)
  )
)

;; Validate governance voting thresholds
(define-private (validate-minimum-votes (vote-count uint))
  (and
    (> vote-count u0)
    (<= vote-count tokens-per-asset)
  )
)

;; Validate metadata URI format and length
(define-private (validate-metadata-uri (uri (string-ascii 256)))
  (and
    (> (len uri) u0)
    (<= (len uri) u256)
  )
)

;; CORE PUBLIC FUNCTIONS

;; Asset Registration & Tokenization
;; Registers a new real-world asset and creates corresponding SFT tokens
(define-public (register-asset
    (metadata-uri (string-ascii 256))
    (asset-value uint)
  )
  (begin
    ;; Access Control: Only contract owner can register assets
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; Input Validation
    (asserts! (validate-metadata-uri metadata-uri) err-invalid-uri)
    (asserts! (validate-asset-value asset-value) err-invalid-value)
    (let ((asset-id (get-next-asset-id)))
      ;; Create asset registry entry
      (map-set assets { asset-id: asset-id } {
        owner: contract-owner,
        metadata-uri: metadata-uri,
        asset-value: asset-value,
        is-locked: false,
        creation-height: stacks-block-height,
        last-price-update: stacks-block-height,
        total-dividends: u0,
      })
      ;; Mint initial SFT token supply to asset owner
      (map-set token-balances {
        owner: contract-owner,
        asset-id: asset-id,
      } { balance: tokens-per-asset }
      )
      ;; Update global asset counter
      (var-set last-asset-id asset-id)
      (ok asset-id)
    )
  )
)

;; Dividend Distribution System
;; Allows token holders to claim proportional dividends from asset revenue
(define-public (claim-dividends (asset-id uint))
  (let (
      (asset (unwrap! (get-asset-info asset-id) err-not-found))
      (balance (get-balance tx-sender asset-id))
      (last-claim (get-last-claim asset-id tx-sender))
      (total-dividends (get total-dividends asset))
      (claimable-amount (/ (* balance (- total-dividends last-claim)) tokens-per-asset))
    )
    ;; Ensure there are claimable dividends
    (asserts! (> claimable-amount u0) err-invalid-amount)
    ;; Update dividend claim record
    (ok (map-set dividend-claims {
      asset-id: asset-id,
      claimer: tx-sender,
    } { last-claimed-amount: total-dividends }
    ))
  )
)

;; Decentralized Governance System
;; Creates proposals for asset management decisions with token-weighted voting
(define-public (create-proposal
    (asset-id uint)
    (title (string-ascii 256))
    (duration uint)
    (minimum-votes uint)
  )
  (begin
    ;; Input Validation
    (asserts! (validate-duration duration) err-invalid-duration)
    (asserts! (validate-minimum-votes minimum-votes) err-invalid-votes)
    (asserts! (validate-metadata-uri title) err-invalid-title)
    ;; Authorization: Require minimum 10% token ownership to create proposals
    (asserts! (>= (get-balance tx-sender asset-id) (/ tokens-per-asset u10))
      err-not-authorized
    )
    (let ((proposal-id (get-next-proposal-id)))
      ;; Create governance proposal
      (map-set proposals { proposal-id: proposal-id } {
        title: title,
        asset-id: asset-id,
        start-height: stacks-block-height,
        end-height: (+ stacks-block-height duration),
        executed: false,
        votes-for: u0,
        votes-against: u0,
        minimum-votes: minimum-votes,
      })
      ;; Update global proposal counter
      (var-set last-proposal-id proposal-id)
      (ok proposal-id)
    )
  )
)