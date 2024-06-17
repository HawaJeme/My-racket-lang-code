;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-my-solution) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))



;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))


(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))



(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; Functions

;; Game -> Game
;; start the world with (main (make-game empty empty T0))
;; < no examples for main function >
(define (main g)
  (big-bang g                    ; Game
          (on-key    move-fire)     ; Game KeyEvent -> Game
          (on-tick   game-start)    ; Game -> Game
          (to-draw   render-game)   ; Game -> Image
            ))


;; Game KeyEvent-> Game
;; Start the game by moving the tank and fire missles
(check-expect (move-fire (make-game empty empty T0) "left")  (make-game empty empty (make-tank (- 150 TANK-SPEED) -1)))
(check-expect (move-fire (make-game empty empty T0) "right") (make-game empty empty (make-tank (+ 150 TANK-SPEED) 1)))

;(define (move-fire (make-game empty empty T0) " ") (make-game empty empty T0)) ;stub

(define (move-fire g key)
  (cond [(key=? "left" key)  (make-game (game-invaders g)                (game-missiles g) (move-tank (game-tank g) -1))]
        [(key=? "right" key) (make-game (game-invaders g)                (game-missiles g) (move-tank (game-tank g) 1))]
        [(key=? " " key)     (make-game (game-invaders g) (fire-missiles (game-missiles g) (game-tank g)) (game-tank g))]
        [else g]
        ))

;; Tank -> Tank
(define (move-tank t dir)
  (if (positive? dir)
      (cond [(< (tank-x t) WIDTH) (make-tank (+ (tank-x t) TANK-SPEED) 1)]
            [(>= (tank-x t) WIDTH) (make-tank WIDTH 1)])
      (cond [(> (tank-x t) 0) (make-tank (- (tank-x t) TANK-SPEED) -1)]
            [(<= (tank-x t) 0) (make-tank 0 -1)])))

;; Misssle -> Missles
(define (fire-missiles m t)
  (cons (make-missile (tank-x t) (- HEIGHT TANK-HEIGHT/2)) m))
  
;; Game -> Game
;; produce the next state of the game
;; !!!

;; <Template from game>

;(define (game-start g) ...) ;stub


;; Game -> Game
;;

(define (game-start g)
  (make-game (move-invaders (new-invaders (game-invaders g)) (game-missiles g))
             (move-missiles (game-missiles g))
             (game-tank g)))


;; Invader -> Invader
;; making new invaders on the screen
(check-random (new-invaders empty) (cons (make-invader (random WIDTH) 0 12) empty))
(check-random (new-invaders (cons (make-invader 150 100 12) (cons (make-invader 150 HEIGHT -10) empty)))
              (cons (make-invader (random WIDTH) 0 12) (cons (make-invader 150 100 12) (cons (make-invader 150 HEIGHT -10) empty))))

#;
(define (new-invaders loi)
  (cond [(empty? loi) (cons (make-invader (random WIDTH) 0 12) empty)]
        [(<= (length loi) 5) (cons (make-invader (random WIDTH) 0 12) (list* loi))]
        [else loi]))
(define (new-invaders loi)
  (cond [(empty? loi) (cons(make-invader (random WIDTH) 0 12) loi)]
        [(<= (length loi) 5) (cons (make-invader (random WIDTH) 0 12) (list* loi))]
        [else (cons (make-invader (random WIDTH) 0 12) loi)]))


;; Invader -> Invader
;; moving existing invaders
(define (move-invaders loi m)
  (cond [(empty? loi) empty]
        [(or (false? (game-over-list loi)) (false? (remove-invader m (first loi))))
         (cond [(<= (invader-x (first loi)) 0) ;If invader-x moved beyond borders
              (cons (make-invader (+ (invader-x (first loi)) INVADER-X-SPEED) (+ (invader-y (first loi)) INVADER-Y-SPEED) (- (invader-dx (first loi)))) (move-invaders (rest loi) m))]
             [(>= (invader-x (first loi)) WIDTH)
              (cons (make-invader (- (invader-x (first loi)) INVADER-X-SPEED) (+ (invader-y (first loi)) INVADER-Y-SPEED) (- (invader-dx (first loi)))) (move-invaders (rest loi) m))]
             [else (cond                       ;Moving in normal direction
                     [(positive? (invader-dx (first loi)))
                     (cons (make-invader (+ (invader-x (first loi)) INVADER-X-SPEED) (+ (invader-y (first loi)) INVADER-Y-SPEED) (invader-dx (first loi))) (move-invaders (rest loi) m))]
                     [(negative? (invader-dx (first loi)))
                     (cons (make-invader (- (invader-x (first loi)) INVADER-X-SPEED) (+ (invader-y (first loi)) INVADER-Y-SPEED) (invader-dx (first loi))) (move-invaders (rest loi) m))])])]
        [else (move-invaders (rest loi) m)])
  )

(define (game-over-list loi)
  (cond [(empty?  loi) empty]
        [else (game-over? (first loi)
              (game-over-list (rest loi)))]))

(define (game-over? i y/n)
 (if (>= (invader-y  i) HEIGHT) true false))

(define (remove-invader m i)
  (cond [(empty? i) false]
        [else (if (is-shot? m (first i)) (remove (first i) i) (remove-invader m (rest i)))]
        ))
  
(define (is-shot? m i)
  (cond [(empty? i) false]
        [else
           (if (and (equal? (invader-x (first m)) (missile-x i)) (equal? (invader-y (first m)) (missile-y i)))
               true
               false)]))

(define (move-missiles m)
  (cond [(empty? m) empty]
        [else (cond [(> (missile-y (first m)) 0) (cons (make-missile (missile-x (first m)) (- (missile-y (first m)) MISSILE-SPEED)) (move-missiles (rest m)))]
               [(<= (missile-y (first m)) 0) empty])]))

;; Missiles -> Missiles
#;
(define (is-shot? m i)
  (cond [(and (= (invader-x (first loi)) (missile-x i)))]
        ))
  #;
(define (is-shot? i m)
  (cond [(empty? i) false]
        [else (if (or (= (missile-x m) (invader-x (first i))) (= (missile-y m) (invader-y (first i))))
                  (remove (first i) i)
                  (is-shot? (rest i) m))])
   ;(lambda ((missile-x m)) (member elem i))
  )

;; Game -> Image
;; render game elements in the game
;; 

(define (render-game g)
  (cond ;[(and (not (empty? (game-invaders g))) (not (empty? (game-missiles g))))
                       ;(render-tank (game-tank g) (render-invaders (game-invaders g) (render-missiles (game-missiles g))))]
        
        [(not (empty? (game-missiles g)))
                       (render-tank (game-tank g) (render-missiles (game-missiles g)))]
        
        [(not (empty? (game-invaders g)))
                      (render-tank (game-tank g) (render-invaders (game-invaders g)))]
        
        [else (render-tank (game-tank g) empty)])
  )
 
(define (render-tank t i)
  (cond [(empty? i) (place-image TANK (tank-x t) (- HEIGHT TANK-HEIGHT/2) BACKGROUND)]
        [else (place-image TANK (tank-x t) (- HEIGHT TANK-HEIGHT/2) i)]))

(define (render-invaders loi)
  (cond [(empty? loi) BACKGROUND]
        [else
         (render-invader (first loi)
          (render-invaders (rest loi)))]))

(define (render-invader i img)
  (place-image INVADER (invader-x i) (invader-y i) img))

(define (render-missiles lom)
  (cond [(empty? lom) BACKGROUND]
        [else
         (render-missile (first lom)
          (render-missiles (rest lom)))]))

(define (render-missile m img)
  (place-image MISSILE (missile-x m) (missile-y m) img))
