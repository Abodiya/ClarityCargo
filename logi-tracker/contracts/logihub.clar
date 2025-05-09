;; Define constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-DISPATCHED (err u101))
(define-constant ERR-INSUFFICIENT-CREDITS (err u102))
(define-constant ERR-SHIPMENT-NOT-ACTIVE (err u103))
(define-constant ERR-SHIPMENT-IN-TRANSIT (err u104))
(define-constant ERR-INVALID-CARGO-AMOUNT (err u105))
(define-constant ERR-INVALID-INSURANCE-RATE (err u106))
(define-constant ERR-INVALID-TRANSIT-TIME (err u107))

;; Define data maps
(define-map cargo-shipments 
  { shipment-id: uint }
  {
    sender: principal,
    courier: (optional principal),
    cargo-amount: uint,
    insurance-rate: uint,
    transit-time: uint,
    dispatch-block: (optional uint),
    status: (string-ascii 20)
  }
)

(define-map credit-balances principal uint)

;; Define functions
(define-public (register-shipment (cargo-amount uint) (insurance-rate uint) (transit-time uint))
  (let ((shipment-id (+ (var-get shipment-counter) u1)))
    ;; Validate input parameters
    (asserts! (> cargo-amount u0) ERR-INVALID-CARGO-AMOUNT)
    (asserts! (<= insurance-rate u50) ERR-INVALID-INSURANCE-RATE)
    (asserts! (> transit-time u0) ERR-INVALID-TRANSIT-TIME)
    
    (map-set cargo-shipments 
      { shipment-id: shipment-id }
      {
        sender: tx-sender,
        courier: none,
        cargo-amount: cargo-amount,
        insurance-rate: insurance-rate,
        transit-time: transit-time,
        dispatch-block: none,
        status: "REGISTERED"
      }
    )
    (var-set shipment-counter shipment-id)
    (ok shipment-id)
  )
)

(define-public (dispatch-shipment (shipment-id uint))
  (let (
    (shipment (unwrap! (map-get? cargo-shipments { shipment-id: shipment-id }) ERR-SHIPMENT-NOT-ACTIVE))
    (courier-balance (default-to u0 (map-get? credit-balances tx-sender)))
  )
    (asserts! (is-none (get courier shipment)) ERR-ALREADY-DISPATCHED)
    (asserts! (>= courier-balance (get cargo-amount shipment)) ERR-INSUFFICIENT-CREDITS)
    
    (map-set cargo-shipments { shipment-id: shipment-id }
      (merge shipment { 
        courier: (some tx-sender),
        dispatch-block: (some block-height),
        status: "IN_TRANSIT"
      })
    )
    (map-set credit-balances tx-sender (- courier-balance (get cargo-amount shipment)))
    (map-set credit-balances (get sender shipment) (+ (default-to u0 (map-get? credit-balances (get sender shipment))) (get cargo-amount shipment)))
    (ok true)
  )
)

(define-public (complete-delivery (shipment-id uint))
  (let (
    (shipment (unwrap! (map-get? cargo-shipments { shipment-id: shipment-id }) ERR-SHIPMENT-NOT-ACTIVE))
    (sender-balance (default-to u0 (map-get? credit-balances tx-sender)))
    (payment-amount (+ (get cargo-amount shipment) (/ (* (get cargo-amount shipment) (get insurance-rate shipment)) u100)))
  )
    (asserts! (is-eq (get sender shipment) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status shipment) "IN_TRANSIT") ERR-SHIPMENT-NOT-ACTIVE)
    (asserts! (>= (- block-height (unwrap! (get dispatch-block shipment) ERR-SHIPMENT-NOT-ACTIVE)) (get transit-time shipment)) ERR-SHIPMENT-IN-TRANSIT)
    (asserts! (>= sender-balance payment-amount) ERR-INSUFFICIENT-CREDITS)
    
    (map-set credit-balances tx-sender (- sender-balance payment-amount))
    (map-set credit-balances (unwrap! (get courier shipment) ERR-SHIPMENT-NOT-ACTIVE) 
      (+ (default-to u0 (map-get? credit-balances (unwrap! (get courier shipment) ERR-SHIPMENT-NOT-ACTIVE))) payment-amount)
    )
    (map-set cargo-shipments { shipment-id: shipment-id } (merge shipment { status: "DELIVERED" }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-shipment (shipment-id uint))
  (map-get? cargo-shipments { shipment-id: shipment-id })
)

(define-read-only (get-credits (user principal))
  (default-to u0 (map-get? credit-balances user))
)

;; Initialize shipment counter
(define-data-var shipment-counter uint u0)