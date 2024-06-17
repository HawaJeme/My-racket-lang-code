;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname |stepper problem|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define (foo x)
  (local [(define (bar y) (+ x y))]
    (+ x (bar (* 2 x)))))

(list (foo 2) (foo 3))

;; (list 8 (foo 3))

;; (list 8
;;    (local [define (bar y) (+ 3 y)]
;;      (+ 3 (bar (* 2 3)))))


;; (define (bar_0 y) (+ 3 y))
;; (list 8 (+ 3 (bar_0 (* 2 3))))

;; (define (bar_0 y) (+ 3 y))
;; (list 8 (+ 3 (bar_0 6)))

;;(define (bar_0 y) (+ 3 y))
;; (list 8 (+ 3 (+ 3 6))))

;; (define (bar_0 y) (+ 3 y))
;; (list 8 (+ 3 9)))

;; (define (bar_0 y) (+ 3 y))
;; (list 8 12))