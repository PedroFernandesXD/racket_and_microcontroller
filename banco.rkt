#lang racket

(require db)
(require racket/date)


(provide soma-dados
         novo-dado
         limite-maximo
         valor-maximo
         inserir-valor-max
         create-db
	 criar-tabela
         verificar-limite
	 deletar-dados)


(define dbs "db/consumo.db")

(define (create-db)
  (sqlite3-connect #:database dbs  #:mode 'create))

(define string-tabela-consumo "CREATE TABLE tabela_consumo(
                                                valor INTEGER NOT NULL,
                                                dia TEXT NOT NULL,
                                                horas TEXT NOT NULL)")

(define string-tabela-consumo-max "CREATE TABLE tabela_consumo_max(
                                                valor_maximo INTEGER NOT NULL,
                                                data TEXT NOT NULL)")

(define string-tabela-consumo-bkp "CREATE TABLE tabela_consumo_bkp(
                                              valor INTEGER NOT NULL,
                                              dia TEXT NOT NULL,
                                              horas TEXT NOT NULL)")

(define string-drop-tabela-consumo "DROP TABLE tabela_consumo")
(define string-drop-tabela-consumo-max "DROP TABLE tabela_consumo_max")
(define string-drop-tabela-consumo-bkp "DROP TABLE tabela_consumo_bkp") 
(define string-inserir-dados "INSERT INTO tabela_consumo VALUES (1,date('now'),time('now'))")
(define string-select-last-dia "SELECT dia FROM tabela_consumo ORDER BY dia DESC LIMIT 1")
(define string-select-last-hora "SELECT horas FROM tabela_consumo ORDER BY horas DESC LIMIT 1")
(define string-select-dia "SELECT date('now')")
(define string-select-hora "SELECT time('now')")
(define string-bkp-dados "INSERT INTO tabela_consumo_bkp SELECT * FROM tabela_consumo")
(define string-deletar-dados  "DELETE FROM tabela_consumo")
(define string-select-consumo-max "SELECT valor_maximo FROM tabela_consumo_max ORDER BY data DESC LIMIT 1")


(define (criar-tabela)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)])
    (query-exec db-connect string-tabela-consumo)
    (query-exec db-connect string-tabela-consumo-max)
    (query-exec db-connect string-tabela-consumo-bkp)
    (query-exec db-connect "INSERT INTO tabela_consumo_max VALUES (100,datetime('now'))")
    (disconnect db-connect))
  (printf "Tabelas Criadas."))

(define (deletar-tabela)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)])
    (query-exec db-connect string-drop-tabela-consumo)
    (query-exec db-connect string-drop-tabela-consumo-max)
    (query-exec db-connect string-drop-tabela-consumo-bkp)
    (disconnect db-connect))
  (printf "Tabela Deletadas."))


(define (inserir-dados)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)])
    (query-exec db-connect string-inserir-dados)
    (disconnect db-connect)))

(define (selecionar-tudo)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
        [result (query-rows db-connect "SELECT * FROM tabela_consumo")])
    (disconnect db-connect)
    result))

(define (selecionar-tudo-bkp)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [result (query-rows db-connect "SELECT * FROM tabela_consumo_bkp")])
    (disconnect db-connect)
    result))


(define (soma-dados)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [soma (query-value db-connect "SELECT sum(valor) FROM tabela_consumo")])
    (disconnect db-connect)
    (if (sql-null? soma)
        (format "~a" 0)
        (format "~a" soma))))

(define (selecionar-last-dia)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [result (query-value db-connect string-select-last-dia)])
    (disconnect db-connect)
    result))

(define (selecionar-last-hora)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [result (query-value db-connect string-select-last-hora)])
    (disconnect db-connect)
    result))

(define (selecionar-dia-atual)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [dia (query-value db-connect string-select-dia)])
    (disconnect db-connect)
    dia))

(define (selecionar-hora-atual)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [hora (query-value db-connect string-select-hora)])
    (disconnect db-connect)
    hora))

(define (bkp)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)])
    (query-exec db-connect string-bkp-dados)
    (disconnect db-connect)))
         
(define (deletar-dados)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)])
    (query-exec db-connect string-deletar-dados)
    (disconnect db-connect)))


(define (tempo)
  (let ([h (list (cadddr (vector->list (struct->vector (current-date))))
                 (caddr  (vector->list (struct->vector (current-date)))))])
    (if (and (zero? (car h)) (zero? (cadr h)))
        #f
        #t)))

(define (verificar-dia)
  (if (empty? (selecionar-tudo))
      #t
      (equal? (selecionar-dia-atual) (selecionar-last-dia))))
    
(define (novo-dado)
  (if (tempo)
      (if (verificar-dia)
          (inserir-dados)
          (begin (bkp) (deletar-dados) (inserir-dados)))
      (if (verificar-dia)
          (inserir-dados)
          (begin (bkp) (deletar-dados) (inserir-dados)))))


(define (inserir-valor-max valor)
  (let ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
        [var (abs valor)])
    (query-exec db-connect (~a "INSERT INTO tabela_consumo_max VALUES('" var "',datetime('now'))"))
    (disconnect db-connect)))

(define (selecionar-tudo-max)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [results (query-rows db-connect "SELECT * FROM tabela_consumo_max")])
    (disconnect db-connect)
    results))

(define (valor-maximo)
  (let* ([db-connect (sqlite3-connect #:database dbs #:mode 'read/write)]
         [result (query-value db-connect string-select-consumo-max)])
    (disconnect db-connect)
    result))

(define (limite-maximo)
  (if (>= (string->number (soma-dados)) (valor-maximo)) #t #f))

(define (verificar-limite)
  (if (limite-maximo)
      "desligado"
      "ligado"))
