#lang eopl
;Especificación Léxica

(define lexica
  '(
    (white-sp (whitespace) skip)
    (comment ("%" (arbno (not #\newline))) skip)
    (identifier (letter (arbno (or letter digit "?" "_"))) symbol)
    (number (digit (arbno digit)) number)
    (number ("-" digit (arbno digit)) number)
    (number (digit (arbno digit) "." digit (arbno digit)) number)
    (number ("-" digit (arbno digit) "." digit (arbno digit)) number)
    (cadena ("\"" (arbno (not #\")) "\"") string)
    )
  )

;Especificación Sintáctica (gramática)

(define gramatica
  '(
    ;; =========================================================
    ;; PROGRAMA: Punto de entrada
    ;; =========================================================
    ;<programa> ::= GLOBALS { { <declaracion> }* } PROGRAM { proc main ( ) { return <expresion> } }
    ;               un-programa (decls exp pc)
    (programa
      ("GLOBALS" "{" (arbno declaracion) "}"
       "PROGRAM" "{" "proc" "main" "(" ")" "{" "return" expresion (arbno ";") "}" "}")
      un-programa)

    ;; =========================================================
    ;; DECLARACIÓN: Crear un nombre (variable, constante o proc)
    ;; =========================================================
    ;<declaracion> ::= <tipo> <identificador> = <expresion> ;
    ;                  var-decl (tipo id exp)
    (declaracion (tipo identifier "=" expresion ";") var-decl)

    ;<declaracion> ::= const <tipo> <identificador> = <expresion> ;
    ;                  const-decl (tipo id exp)
    (declaracion ("const" tipo identifier "=" expresion ";") const-decl)

    ;<declaracion> ::= proc <identificador> = <expresion>
    ;                  proc-decl (id exp)
    (declaracion ("proc" identifier "=" expresion) proc-decl)

    ;; =========================================================
    ;; TIPO: La etiqueta de la declaración
    ;; =========================================================
    ;<tipo> ::= int | float | string | bool | void
    ;         | list < <tipo> > | vector < <tipo> > | dict < <tipo> , <tipo> >
    (tipo ("int") tipo-int)
    (tipo ("float") tipo-float)
    (tipo ("string") tipo-string)
    (tipo ("bool") tipo-bool)
    (tipo ("void") tipo-void)
    (tipo ("list" "<" tipo ">") tipo-list)
    (tipo ("vector" "<" tipo ">") tipo-vector)
    (tipo ("dict" "<" tipo "," tipo ">") tipo-dict)

    ;; =========================================================
    ;; EXPRESIÓN: Cadena de operandos unidos por primitivas
    ;; =========================================================
    ;<expresion> ::= <operando> { <primitiva-binaria> <operando> }*
    ;                operacion-exp (primer-op prims otros-ops)
    (expresion (operando (arbno primitiva-binaria operando)) operacion-exp)

    ;; =========================================================
    ;; OPERANDO: Cada pieza atómica de una expresión
    ;; =========================================================
    ;<operando> ::= <numero>
    ;               numero-lit (num)
    (operando (number) numero-lit)

    ;<operando> ::= " <texto> "
    ;               texto-lit (txt)
    (operando (cadena) texto-lit)

    ;<operando> ::= True | False
    ;               true-lit () | false-lit ()
    (operando ("True") true-lit)
    (operando ("False") false-lit)

    ;<operando> ::= <identificador> <sufijo-id>
    ;               id-exp (id sufijo)
    (operando (identifier sufijo-id) id-exp)

    ;<sufijo-id> ::= vacio | ( { <expresion> }*(,) )
    ;                var-sufijo () | app-sufijo (args)
    (sufijo-id () var-sufijo)
    (sufijo-id ("(" (separated-list expresion ",") ")") app-sufijo)

    ;<operando> ::= ( <expresion> )
    ;               grupo-exp (exp)
    (operando ("(" expresion ")") grupo-exp)

    ;<operando> ::= <bloque>
    ;               bloque-exp (blk)
    (operando (bloque) bloque-exp)

    ;<operando> ::= <locales>
    ;               locales-exp (loc)
    (operando (locales) locales-exp)

    ;; =========================================================
    ;; PRIMITIVA BINARIA: Operadores
    ;; =========================================================
    (primitiva-binaria ("+") primitiva-suma)
    (primitiva-binaria ("-") primitiva-resta)
    (primitiva-binaria ("*") primitiva-multi)
    (primitiva-binaria ("/") primitiva-div)
    (primitiva-binaria ("==") primitiva-comparador-igual)
    (primitiva-binaria ("!=") primitiva-diferente)
    (primitiva-binaria (">") primitiva-mayor)
    (primitiva-binaria ("<") primitiva-menor)
    (primitiva-binaria (">=") primitiva-mayor-igual)
    (primitiva-binaria ("<=") primitiva-menor-igual)
    (primitiva-binaria ("->") primitiva-asignacion)

    ;; =========================================================
    ;; SENTENCIA: Paso dentro de un bloque
    ;; =========================================================
    ;<sentencia> ::= <expresion> ;
    ;                una-sentencia (exp)
    (sentencia (expresion ";") una-sentencia)

    ;; =========================================================
    ;; BLOCK: Ejecutar varias sentencias en orden
    ;; =========================================================
    ;<bloque> ::= BLOCK { <sentencia> { <sentencia> }* }
    ;             un-bloque (primera-sent resto-sents)
    (bloque ("BLOCK" "{" sentencia (arbno sentencia) "}") un-bloque)

    ;; =========================================================
    ;; LOCALS: Variables temporales y luego instrucciones
    ;; =========================================================
    ;<locales> ::= LOCALS { <declaracion> { <declaracion> }* } { <sentencia> { <sentencia> }* }
    ;              variableLocal-exp (primera-decl resto-decls primera-sent resto-sents)
    (locales
      ("LOCALS" "{" declaracion (arbno declaracion) "}"
                "{" sentencia (arbno sentencia) "}")
      variableLocal-exp)
  ))


