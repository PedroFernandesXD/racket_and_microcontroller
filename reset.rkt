#!/usr/bin/env /home/radiacao/racket/bin/racket

#lang racket


(require "banco.rkt")


(define (verificar-cod cod)
  (if (equal? cod "xresetx")
      (begin
        (deletar-dados)
        "<h1>DADOS DELEDADOS</h1>")
      "<h2>CODIGO INVALIDO</h2>"))

(displayln "Content-type: html")
(newline)
(newline)
(displayln (~a "<html><head>" (verificar-cod (getenv "QUERY_STRING")) "</head></html>"))
