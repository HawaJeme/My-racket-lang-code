;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname abstraction) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; List of number -> Natural
; Produce the sum of a list
(check-expect (sum (list 1 2 3 4)) 10)

;(define (sum lon) 0) ;stub

(define (sum lon)
  (foldr + 0 lon))
