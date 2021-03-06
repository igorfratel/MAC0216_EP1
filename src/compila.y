/* Compilador */

%{
#include <stdio.h>
#include <math.h>
#include "symrec.h"
#include "acertos.h"
#include "types.h"
#include "utils.h"
#include "arena.h"
extern int yylex();
void yyerror(char const *);
int compila(FILE *, INSTR *);
static int ip  = 0;					/* ponteiro de instruções */
static int mem = 6;					/* ponteiro da memória */
static INSTR *prog;
static int parmcnt = 0;		/* contador de parâmetros */

void AddInstr(OpCode op, int val) {
  prog[ip++] = (INSTR) {op, val};
}
%}

/*  Declaracoes */
%union {
  double val;
  /* symrec *cod; */
  char cod[30];
}

/* %type  Expr */

%token <val>  NUMt
%token <cod> ID
%token ADDt SUBt MULt DIVt ASGN OPEN CLOSE RETt EOL
%token CRI_CIMAt CRI_DSUPt CRI_DINFt CRI_BAIXOt CRI_EINFt CRI_ESUPt
%token REC_CIMAt REC_DSUPt REC_DINFt REC_BAIXOt REC_EINFt REC_ESUPt
%token MOV_CIMAt MOV_DSUPt MOV_DINFt MOV_BAIXOt MOV_EINFt MOV_ESUPt
%token ATQ_CIMAt ATQ_DSUPt ATQ_DINFt ATQ_BAIXOt ATQ_EINFt ATQ_ESUPt
%token DEP_CIMAt DEP_DSUPt DEP_DINFt DEP_BAIXOt DEP_EINFt DEP_ESUPt
%token INI_CIMAt INI_DSUPt INI_DINFt INI_BAIXOt INI_EINFt INI_ESUPt
%token BASE_CIMAt BASE_DSUPt BASE_DINFt BASE_BAIXOt BASE_EINFt BASE_ESUPt
%token EQt NEt LTt LEt GTt GEt ABRE FECHA SEP
%token IF WHILE FUNC PRINT
%token ELSE

%right ASGN
%left ADDt SUBt
%left MULt DIVt
%left NEG
%right PWR
%left LTt GTt LEt GEt EQt NEt


/* Gramatica */
%%

Programa: Comando
       | Programa Comando
	   ;

Comando: Expr EOL
       | Cond
       | Loop
       | Func
	   | PRINT Expr EOL { AddInstr(PRN, 0);}
	   | RETt EOL {
		 	     AddInstr(LEAVE, 0);
			     AddInstr(RET, 0);
 			  }
	   | RETt OPEN  Expr CLOSE EOL {
		 	     AddInstr(LEAVE, 0);
			     AddInstr(RET,0);
 		      }
	   /* | EOL {printf("--> %d\n", ip);} */
;

Expr: NUMt {  AddInstr(PUSH, $1);}
    | ID   {
	         symrec *s = getsym($1);
			 if (s==0) s = putsym($1); /* não definida */
			 AddInstr(RCL, s->val);
	       }
	| ID ASGN Expr {
	         symrec *s = getsym($1);
			 if (s==0) s = putsym($1); /* não definida */
			 AddInstr(STO, s->val);
 		 }
	/* | ID PONTO NUMt  {  % v.4 */
	/*          symrec *s = getsym($1); */
	/* 		 if (s==0) s = putsym($1); /\* não definida *\/ */
	/* 		 AddInstr(PUSH, s->val); */
	/* 		 AddInstr(ATR, $3); */
 	/* 	 } */
	| Chamada
    | Expr ADDt Expr { AddInstr(ADD,  0);}
	| Expr SUBt Expr { AddInstr(SUB,  0);}
	| Expr MULt Expr { AddInstr(MUL,  0);}
	| Expr DIVt Expr { AddInstr(DIV,  0);}	
    | '-' Expr %prec NEG  { printf("  {CHS,  0},\n"); }
	| OPEN Expr CLOSE
	| Expr LTt Expr  { AddInstr(LT,   0);}
	| Expr GTt Expr  { AddInstr(GT,   0);}
	| Expr LEt Expr  { AddInstr(LE,   0);}
	| Expr GEt Expr  { AddInstr(GE,   0);}
	| Expr EQt Expr  { AddInstr(EQ,   0);}
	| Expr NEt Expr  { AddInstr(NE,   0);}

	| CRI_CIMAt  { AddInstr(PUSHCELL, 0); AddInstr(ATR, 1);}
	| CRI_DSUPt  { AddInstr(PUSHCELL, 1); AddInstr(ATR, 1);}
	| CRI_DINFt  { AddInstr(PUSHCELL, 2); AddInstr(ATR, 1);}
	| CRI_BAIXOt { AddInstr(PUSHCELL, 3); AddInstr(ATR, 1);}
	| CRI_EINFt  { AddInstr(PUSHCELL, 4); AddInstr(ATR, 1);}
	| CRI_ESUPt  { AddInstr(PUSHCELL, 5); AddInstr(ATR, 1);}

	| INI_CIMAt   { AddInstr(PUSHCELL, 0); AddInstr(ATR, 2);}
	| INI_DSUPt   { AddInstr(PUSHCELL, 1); AddInstr(ATR, 2);}
	| INI_DINFt   { AddInstr(PUSHCELL, 2); AddInstr(ATR, 2);}
	| INI_BAIXOt  { AddInstr(PUSHCELL, 3); AddInstr(ATR, 2);}
	| INI_EINFt   { AddInstr(PUSHCELL, 4); AddInstr(ATR, 2);}
	| INI_ESUPt   { AddInstr(PUSHCELL, 5); AddInstr(ATR, 2);}

	| BASE_CIMAt  { AddInstr(PUSHCELL, 0); AddInstr(ATR, 3);}
	| BASE_DSUPt  { AddInstr(PUSHCELL, 1); AddInstr(ATR, 3);}
	| BASE_DINFt  { AddInstr(PUSHCELL, 2); AddInstr(ATR, 3);}
	| BASE_BAIXOt { AddInstr(PUSHCELL, 3); AddInstr(ATR, 3);}
	| BASE_EINFt  { AddInstr(PUSHCELL, 4); AddInstr(ATR, 3);}
	| BASE_ESUPt  { AddInstr(PUSHCELL, 5); AddInstr(ATR, 3);}

	| REC_CIMAt  { AddInstr(PUSH, 0);  AddInstr(SYS, 1);}
	| REC_DSUPt  { AddInstr(PUSH, 1);  AddInstr(SYS, 1);}
	| REC_DINFt  { AddInstr(PUSH, 2);  AddInstr(SYS, 1);}
	| REC_BAIXOt { AddInstr(PUSH, 3);  AddInstr(SYS, 1);}
	| REC_EINFt  { AddInstr(PUSH, 4);  AddInstr(SYS, 1);}
	| REC_ESUPt  { AddInstr(PUSH, 5);  AddInstr(SYS, 1);}

	| MOV_CIMAt  { AddInstr(PUSH, 0);  AddInstr(SYS, 0);}
	| MOV_DSUPt  { AddInstr(PUSH, 1);  AddInstr(SYS, 0);}
	| MOV_DINFt  { AddInstr(PUSH, 2);  AddInstr(SYS, 0);}
	| MOV_BAIXOt { AddInstr(PUSH, 3);  AddInstr(SYS, 0);}
	| MOV_EINFt  { AddInstr(PUSH, 4);  AddInstr(SYS, 0);}
	| MOV_ESUPt  { AddInstr(PUSH, 5);  AddInstr(SYS, 0);}

	| ATQ_CIMAt  { AddInstr(PUSH, 0); AddInstr(SYS, 3);}
	| ATQ_DSUPt  { AddInstr(PUSH, 1); AddInstr(SYS, 3);}
	| ATQ_DINFt  { AddInstr(PUSH, 2); AddInstr(SYS, 3);}
	| ATQ_BAIXOt { AddInstr(PUSH, 3); AddInstr(SYS, 3);}
	| ATQ_EINFt  { AddInstr(PUSH, 4); AddInstr(SYS, 3);}
	| ATQ_ESUPt  { AddInstr(PUSH, 5); AddInstr(SYS, 3);}

	| DEP_CIMAt  { AddInstr(PUSH, 0); AddInstr(SYS, 2);}
	| DEP_DSUPt  { AddInstr(PUSH, 1); AddInstr(SYS, 2);}
	| DEP_DINFt  { AddInstr(PUSH, 2); AddInstr(SYS, 2);}
	| DEP_BAIXOt { AddInstr(PUSH, 3); AddInstr(SYS, 2);}
	| DEP_EINFt  { AddInstr(PUSH, 4); AddInstr(SYS, 2);}
	| DEP_ESUPt  { AddInstr(PUSH, 5); AddInstr(SYS, 2);}
;

Cond: IF OPEN Expr {
  	    salva_end(ip);
	    AddInstr(JIF,  0);}
	  CLOSE  Bloco {
        AddInstr(JMP, ip);
	    prog[pega_end()].op = ip;}

Cond: Cond ELSE Bloco{
        salva_end(ip);
        AddInstr(JMP, ip);
        prog[pega_end()].op = ip;}

Loop: WHILE OPEN  {salva_end(ip);}
	  		Expr  { salva_end(ip); AddInstr(JIF,0); }
	  		CLOSE Bloco {
			  int ip2 = pega_end();
			  AddInstr(JMP, pega_end());
			  prog[ip2].op = ip;
			};

Bloco: ABRE Comandos FECHA ;

Comandos: Comando
    | Comandos Comando
	;

Func: FUNC ID
	  {
		salva_end(ip);
		AddInstr(JMP,  0);
		symrec *s = getsym($2);
		if (s==0) s = putsym($2);
		else {
		  yyerror("Função definida duas vezes\n");
		  YYABORT;
		}
		s->val = ip;
	  } OPEN
	  {
		newtab(0);
	  }
	  Args CLOSE  Bloco
	  {
		AddInstr(LEAVE, 0);
		AddInstr(RET, 0);
		prog[pega_end()].op = ip;
		deltab();
	  }
	  ;

Args:
	| ID {
	  	 putsym($1);
	  }
    | Args SEP ID {
	  	 putsym($3);
	  }
	;

Chamada: ID OPEN
		 {
			 parmcnt = 0;
			 /* posição da memória mais avançada */
		 }
		 ListParms
		 {
		   symrec *s = getsym($1);
		   if (s == 0) {
			 yyerror("Função não definida\n");
			 YYABORT;
		   }
		   AddInstr(ENTRY, lastval());
		   /* Cópia dos parâmetros */
		   while (parmcnt > 0)
			 AddInstr( STO, --parmcnt);
		   AddInstr(CALL, s->val);
		 }
	  	 CLOSE ;


ListParms:
	| Expr { parmcnt++;}
	| Expr { parmcnt++;} SEP ListParms
;

%%
extern FILE *yyin;

void yyerror(char const *msg) {
  fprintf(stderr,"ERRO: %s",msg);
}

int compilador(FILE *cod, INSTR *dest) {
  int r;
  yyin = cod;
  prog = dest;
  r = yyparse();
  AddInstr(END,0);
  return r;
}

/* int main(int ac, char **av) */
/* { */
/*   ac --; av++; */
/*   if (ac>0) */
/* 	yyin = fopen(*av,"r"); */

/*   yyparse(); */
/*   return 0; */
/* } */
