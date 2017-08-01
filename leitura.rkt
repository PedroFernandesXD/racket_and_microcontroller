#!/usr/bin/env /home/radiacao/racket/bin/racket

#lang racket

(require "banco.rkt")


(define (verificar-codigo cod)
  (if (equal? cod "appnew")
      (begin
        (novo-dado)
        "<h1>DADO RECEBIDO</h1>")
       "<h1>CODIGO INVALIDO</h1>"))



(displayln "Content-type: html")
(newline)
(newline)
(displayln (~a "<html>
                <head>
                 <title>LEITURA</title>
                 <body>"
               (verificar-codigo (getenv "QUERY_STRING"))
               "<h2>Status: " (verificar-limite) " </h2>"))

(displayln "</head>
           </body>
</html>")
