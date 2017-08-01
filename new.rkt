#!/usr/bin/env /home/radiacao/racket/bin/racket

#lang racket

(require "banco.rkt")

(define (get-num str)
 (let ([valor (regexp-match* #rx"[0-9]+" str)])
   (if (or (empty? valor) (not (empty? (cdr valor))))
       "<h1>ERRO, TENTE NOVAMENTE!</h1>"
       (begin
         (inserir-valor-max (string->number (car valor)))
         "<h1> NOVO VALOR DEFINIDO COM SUCESSO!</h1>"))))
     
(displayln "Content-type: html")
(newline)
(newline)
(displayln 
"<html>
  <head>
  <title>Novo valor</title>
  <meta http-equiv='refresh' content='2;url=/pedro/web.rkt'>
  <body>")
(displayln (get-num (getenv "QUERY_STRING")))
(displayln (~a "<p>Valor maximo: " (valor-maximo) "</p>"))
(displayln 
"</body>
  </head>
</html>")


 
