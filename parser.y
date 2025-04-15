%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern FILE *yyin;


int yylex();


void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


#define MAX_SYMBOLS 100

typedef struct {
    char *name;
    double value;
    int type;  // 0 for integer, 1 for float (for future type checking)
} symbol;

symbol symtab[MAX_SYMBOLS];
int symcount = 0;

void add_symbol(char *name, int type) {
    if(symcount >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow\n");
        exit(1);
    }
    symtab[symcount].name = strdup(name);
    symtab[symcount].value = 0;
    symtab[symcount].type = type;
    symcount++;
}

void update_symbol(char *name, double value) {
    int i;
    for(i = 0; i < symcount; i++) {
         if(strcmp(symtab[i].name, name) == 0) {
             symtab[i].value = value;
             return;
         }
    }
    fprintf(stderr, "Undefined variable %s\n", name);
}

double lookup_symbol(char *name) {
    int i;
    for(i = 0; i < symcount; i++) {
         if(strcmp(symtab[i].name, name) == 0) {
             return symtab[i].value;
         }
    }
    fprintf(stderr, "Undefined variable %s\n", name);
    return 0;
}
%}

%union {
    double dval;
    char *sval;
}

/* Reserved words and tokens */
%token <sval> NAME
%token F I PRINT
%token <dval> NUMBER

%type <dval> expression term factor

%%

program:
      /* empty */
    | program statement
    ;

statement:
      decl_statement       
    | assign_statement     
    | print_statement      
    ;

decl_statement:
      F NAME   { add_symbol($2, 1); free($2); }
    | I NAME   { add_symbol($2, 0); free($2); }
    ;

assign_statement:
      NAME '=' expression { update_symbol($1, $3); free($1); }
    ;

print_statement:
      PRINT NAME { 
                   double val = lookup_symbol($2); 
                   free($2);
                   printf("%f\n", val);
                 }
    ;

expression:
      expression '+' term { $$ = $1 + $3; }
    | expression '-' term { $$ = $1 - $3; }
    | term                { $$ = $1; }
    ;

term:
      term '*' factor     { $$ = $1 * $3; }
    | term '/' factor     { 
                              if($3 == 0) {
                                  yyerror("division by zero");
                                  $$ = 0;
                              } else {
                                  $$ = $1 / $3;
                              }
                            }
    | factor              { $$ = $1; }
    ;

factor:
      '(' expression ')'  { $$ = $2; }
    | NUMBER              { $$ = $1; }
    | NAME                { $$ = lookup_symbol($1); free($1); }
    ;

%%

/* Main function: read input from file if provided */
int main(int argc, char *argv[]) {
    FILE *file = NULL;

    if (argc > 1) {
        file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            exit(EXIT_FAILURE);
        }
        yyin = file;
    }
    
    int result = yyparse();
    
    if (file)
        fclose(file);

    return result;
}