#!/home/radiacao/racket/bin/racket

#lang racket

(require "banco.rkt")

(displayln "Content-type: text/html")
(newline)
(newline)
(displayln
"<html><head>
 <title> Controle </title>
 <meta http-equiv='refresh' content='10;url=/pedro/web.rkt'
 <body>
 <center>
 <h1> Consumo Diario</h1>
 </center>")

(displayln (~a 
"<ul>
<li> <p> Gasto Atual: " (soma-dados) " Wh </p> </li>
<p>
<li> <p> Consumo Maximo: "(valor-maximo) " Wh </p> </li>
<p>
<li>"))

(displayln
"<form action='/pedro/new.rkt' method='get'>
<p>Configurar Valor Maximo (Wh):
<input type='text' name='maximo' value='100'/>
<input type='submit' value='Reconfigurar'/>
</p>
</form>")

(displayln (~a "<li> <p> Status: " (verificar-limite) "</p></li>"))

(displayln 
"</ul>
</body>
</head>
</html>")
          
