;; SoundScape Collective - Generative Music NFT
;; A platform for creating unique musical compositions from artist contributions

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-contributor (err u101))
(define-constant err-not-found (err u102))
(define-constant err-max-supply (err u103))
(define-constant err-invalid-payment (err u104))
(define-constant err-element-exists (err u105))
(define-constant err-invalid-price (err u106))
(define-constant err-invalid-max-supply (err u107))
(define-constant err-invalid-parameter (err u108))

;; Define NFT token
(define-non-fungible-token soundscape uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var max-supply uint u1000)
(define-data-var mint-price uint u200000000) ;; 200 STX
(define-data-var artist-royalty-percent uint u10) ;; 10% royalty

;; Data Maps
(define-map contributors principal bool)

(define-map musical-elements
    {element-type: (string-ascii 32), element-id: uint}
    {
        artist: principal,
        name: (string-ascii 64),
        genre: (string-ascii 32),
        mood: (string-ascii 32),
        bpm: uint,
        key: (string-ascii 8),
        duration: uint,
        rarity: uint,
        uri: (string-ascii 256)
    }
)

(define-map element-counts
    (string-ascii 32)  ;; element-type
    uint
)

(define-map compositions
    uint  ;; token-id
    {
        melody: uint,
        harmony: uint,
        rhythm: uint,
        effects: uint,
        seed: uint,
        timestamp: uint
    }
)

(define-map artist-royalties
    principal
    uint
)

;; Constants for validation
(define-constant min-price u1000000) ;; 1 STX minimum
(define-constant max-price u1000000000) ;; 1000 STX maximum
(define-constant min-supply u100)
(define-constant max-supply-limit u10000)

;; Administrative Functions
(define-public (set-mint-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Validate price range
        (asserts! (and (>= new-price min-price) (<= new-price max-price)) err-invalid-price)
        (ok (var-set mint-price new-price))))

(define-public (set-max-supply (new-max uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Validate supply range
        (asserts! (and (>= new-max min-supply) (<= new-max max-supply-limit)) err-invalid-parameter)
        (ok (var-set max-supply new-max))))

(define-public (add-contributor (artist principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Check if address is not null and not already a contributor
        (asserts! (and 
            (not (is-eq artist contract-owner))
            (not (default-to false (map-get? contributors artist)))) 
            err-invalid-parameter)
        (ok (map-set contributors artist true))))

;; Helper function for string validation
(define-private (validate-string (str (string-ascii 256)))
    (let ((len (len str)))
        (and (> len u0) (< len u256))))

;; Helper function for musical parameters validation
(define-private (validate-musical-params 
    (bpm uint)
    (duration uint)
    (rarity uint))
    (and 
        (and (>= bpm u20) (<= bpm u300))  ;; Valid BPM range
        (and (> duration u0) (<= duration u600))  ;; Max 10 minutes
        (and (>= rarity u1) (<= rarity u100))))  ;; Rarity percentage

;; Artist Contribution Functions
(define-public (add-musical-element
    (element-type (string-ascii 32))
    (name (string-ascii 64))
    (genre (string-ascii 32))
    (mood (string-ascii 32))
    (bpm uint)
    (key (string-ascii 8))
    (duration uint)
    (rarity uint)
    (uri (string-ascii 256)))
    (let ((element-id (default-to u0 (map-get? element-counts element-type))))  ;; Removed incorrect ]
        (begin
            ;; Validate contributor
            (asserts! (default-to false (map-get? contributors tx-sender)) err-invalid-contributor)
            ;; Validate strings
            (asserts! (and 
                (validate-string element-type)
                (validate-string name)
                (validate-string genre)
                (validate-string mood)
                (validate-string key)
                (validate-string uri)) err-invalid-parameter)
            ;; Validate musical parameters
            (asserts! (validate-musical-params bpm duration rarity) err-invalid-parameter)
            ;; Check if element type is valid
            (asserts! (or 
                (is-eq element-type "melody")
                (is-eq element-type "harmony")
                (is-eq element-type "rhythm")
                (is-eq element-type "effects")) err-invalid-parameter)
            (ok (begin
                (map-set musical-elements
                    {element-type: element-type, element-id: element-id}
                    {
                        artist: tx-sender,
                        name: name,
                        genre: genre,
                        mood: mood,
                        bpm: bpm,
                        key: key,
                        duration: duration,
                        rarity: rarity,
                        uri: uri
                    })
                (map-set element-counts element-type (+ element-id u1)))))))

;; Generation Functions
(define-private (get-random (seed uint) (max uint))
    (let (
        (hash (sha256 (concat 
                    (unwrap-panic (to-consensus-buff? (var-get last-token-id)))
                    (unwrap-panic (to-consensus-buff? block-height)))))
        (hash-16 (unwrap-panic (as-max-len? (unwrap-panic (slice? hash u0 u16)) u16))))
        (mod (buff-to-uint-be hash-16) max)))

(define-private (generate-composition (seed uint))
    (let (
        (melody-count (default-to u1 (map-get? element-counts "melody")))
        (harmony-count (default-to u1 (map-get? element-counts "harmony")))
        (rhythm-count (default-to u1 (map-get? element-counts "rhythm")))
        (effects-count (default-to u1 (map-get? element-counts "effects"))))
        {
            melody: (get-random seed melody-count),
            harmony: (get-random (+ seed u1) harmony-count),
            rhythm: (get-random (+ seed u2) rhythm-count),
            effects: (get-random (+ seed u3) effects-count),
            seed: seed,
            timestamp: block-height
        }))

;; Minting Functions
(define-private (distribute-royalties (payment uint))
    (let ((royalty-amount (/ (* payment (var-get artist-royalty-percent)) u100)))
        (begin
            ;; Implementation would distribute royalties to contributing artists
            ;; Based on element usage in the composition
            (ok royalty-amount))))

(define-public (mint)
    (let (
        (token-id (+ (var-get last-token-id) u1))
        (composition (generate-composition block-height)))
        (asserts! (<= token-id (var-get max-supply)) err-max-supply)
        (asserts! (is-eq (stx-transfer? (var-get mint-price) tx-sender (as-contract tx-sender)) (ok true)) err-invalid-payment)
        
        ;; Mint NFT and store composition
        (try! (nft-mint? soundscape token-id tx-sender))
        (unwrap-panic (distribute-royalties (var-get mint-price))) ;; Changed from try! to unwrap-panic
        (map-set compositions token-id composition)
        (var-set last-token-id token-id)
        (ok token-id)))

;; Getter Functions
(define-read-only (get-composition (token-id uint))
    (map-get? compositions token-id))

(define-read-only (get-musical-element (element-type (string-ascii 32)) (element-id uint))
    (map-get? musical-elements {element-type: element-type, element-id: element-id}))

(define-read-only (get-element-count (element-type (string-ascii 32)))
    (default-to u0 (map-get? element-counts element-type)))

(define-read-only (get-composition-details (token-id uint))
    (match (map-get? compositions token-id)
        composition (ok {
            melody: (get-musical-element "melody" (get melody composition)),
            harmony: (get-musical-element "harmony" (get harmony composition)),
            rhythm: (get-musical-element "rhythm" (get rhythm composition)),
            effects: (get-musical-element "effects" (get effects composition)),
            seed: (get seed composition),
            timestamp: (get timestamp composition)
        })
        (err err-not-found)))