%{
#include <stdio.h>
#include "tree.h"

void yyerror(char* s);
int yylex(void);
Node *root;
extern int lineno;
extern int cara;
%}

%union {    
    char chaine[100];
    Node *node;
}
%token <chaine> CHARACTER
%token <chaine> IDENT NUM
%token <chaine> TYPE WHILE IF ELSE RETURN VOID STATIC
%token <chaine> ADDSUB DIVSTAR OR AND EQ ORDER
%type <node> Prog LstDeclVarsLoc Declarateurs DeclFonct DeclFoncts DeclVars EnTeteFonct Parametres ListTypVar Corps SuiteInstr Instr Exp ListExp Arguments TB FB M E T F DeclVarsLoc
%nonassoc EQ ORDER
%left OR
%left AND
%left ADDSUB
%left DIVSTAR
%expect 1

%%

Prog:  DeclVars DeclFoncts                                  
    {
        
        $$ = makeNode(Prog,NULL);
        addChild($$, $1);
        addChild($$,$2);
        root = $$;
    }
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'                       
    {
        if ($$ == NULL) {
            Node* delcvar = makeNode(Variable,NULL);
            Node* nodeType = makeNode(Type,$2);
            addChild(delcvar,nodeType);
            addChild(nodeType,$3);
            $$=delcvar;
        } else {
            Node* nodeType = makeNode(Type,$2);
            addChild($$,nodeType);
            addChild(nodeType,$3);
        }
    } 
    |                                                    
    {
        $$ = makeNode(Variable,NULL);
    }
    ;
Declarateurs:
       Declarateurs ',' IDENT                               
    {
        if ($$ == NULL) {
            Node* delc = makeNode(Declarateurs,NULL);
            addChild(delc,makeNode(Ident,$3));
            $$=delc;
        } else {
            addSibling($$,makeNode(Ident,$3));
        }
        
    }
    |  IDENT                                                
    {
        $$ = makeNode(Ident,$1);
    }
    ;
DeclFoncts:
       DeclFoncts DeclFonct                                 
    {
        addSibling($1,$2);
        $$=$1;
    }
    |  DeclFonct                                            
    {
        $$ = $1;
    }
    ;
DeclFonct:
       EnTeteFonct Corps                                    
    {
        Node* funcdecl = makeNode(Fonction,NULL);
        addChild(funcdecl,$1);
        addChild(funcdecl,$2);
        $$=funcdecl;
    }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'                        
    {
        Node* entete = makeNode(EnTeteFonct,NULL);
        Node* name = makeNode(Ident,$2);
        addChild(entete,name);
        addChild(name,makeNode(Type_retour,$1));
        addChild(name,$4);
        $$=entete;
    }
    |  VOID IDENT '(' Parametres ')'                        
    {
        Node* entete = makeNode(EnTeteFonct,NULL);
        Node* name = makeNode(Ident,$2);
        addChild(entete,name);
        addChild(name,makeNode(Type_retour,$1));
        addChild(name,$4);
        $$=entete;
    }
    ;
Parametres:
       VOID                                                 
    {
        $$ = makeNode(Type_para,$1);
    }
    |  ListTypVar                                           
    {
        $$ = $1;
    }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT                            
    {
        if ($$ == NULL) {
            Node* lst = makeNode(Parametres,NULL);
            Node* nodeType = makeNode(Type_para,$3);
            addChild(lst,nodeType);
            addChild(nodeType,makeNode(Ident,$4));
            $$=lst;
        } else {
            Node* nodeType = makeNode(Type_para,$3);
            addChild($$,nodeType);
            addChild(nodeType,makeNode(Ident,$4));
        }  
    }
    |  TYPE IDENT                                           
    {
        Node* lst = makeNode(Parametres,NULL);
        Node* nodeType = makeNode(Type_para,$1);
        addChild(lst,nodeType);
        addChild(nodeType,makeNode(Ident,$2));
        $$=lst;
    }
    ;
Corps: '{' LstDeclVarsLoc SuiteInstr '}'                          
    {
        Node* corp = makeNode(CorpsFonction,NULL);
        addChild(corp, $2);
        addChild(corp,$3);
        $$=corp;
    }
    ;
LstDeclVarsLoc: LstDeclVarsLoc DeclVarsLoc
    {
        if ($1 != NULL && $2 != NULL) {
            addChild($1, $2);
            $$ = $1;
        } else if ($1 != NULL) {
            $$ = $1;
        } else {
            $$ = $2; 
        }
    }
    | 
    { 
        $$ = makeNode(Variable, NULL); 
    }
    ;
DeclVarsLoc: 
        TYPE Declarateurs ';'
    {  
            Node* nType = makeNode(Type,$1);
            addChild(nType,$2);
            $$ = nType;
    }
    |   STATIC TYPE Declarateurs ';'
    {
            Node* nStat = makeNode(Static,NULL);  
            Node* nType = makeNode(Type,$2);
            addChild(nStat,nType);
            addChild(nType,$3);
            $$ = nStat; 
    }
    ;
SuiteInstr: 
       SuiteInstr Instr 
    {
        if ($1 != NULL && $2 != NULL) {
            addSibling($1, $2);
            $$ = $1;
        } else if ($1 != NULL) {
            $$ = $1;
        } else {
            $$ = $2; 
        }
    }
    | 
    { 
        $$ = NULL; 
    }
    ;
Instr:
       IDENT '=' Exp ';'                                    
    {
        Node* inst = makeNode(Assign,"=");
        addChild(inst,makeNode(Ident,$1));
        addChild(inst,$3);
        $$ = inst;
    }
    |  IF '(' Exp ')' Instr                      
    {
        Node* ifInst = makeNode(If,NULL);
        addChild(ifInst, $3);
        addChild(ifInst, $5);
        $$ = ifInst;
    }
    |  IF '(' Exp ')' Instr ELSE Instr               
    {
        Node* ifElseInst = makeNode(If,NULL);
        Node* ElseInst = makeNode(Else,NULL);
        addChild(ifElseInst, $3);
        addChild(ifElseInst, $5);
        addChild(ElseInst,$7);
        addSibling(ifElseInst,ElseInst);
        $$ = ifElseInst;
    }
    |  WHILE '(' Exp ')' Instr                              
    {
        Node* whileInst = makeNode(While,NULL);
        addChild(whileInst,$3);
        addChild(whileInst,$5);
        $$=whileInst;
    }
    |  IDENT '(' Arguments  ')' ';'                         
    {
        Node* identInst = makeNode(Ident,$1);
        addChild(identInst, $3);
        $$ = identInst;
    }
    |  RETURN Exp ';'                                       
    {
        Node* returnExpInst = makeNode(Return,NULL);
        addChild(returnExpInst, $2);
        $$ = returnExpInst;
    }
    |  RETURN ';'                                           
    {
        Node* returnInst = makeNode(Return,NULL);
        $$=returnInst;
    }
    |  '{' SuiteInstr '}'                                   
    {
        if ($2 == NULL) {
            $$ = makeNode(Bloc,NULL);
            $$ = $2;
        } else {
            $$ = makeNode(Bloc,NULL);
            addChild($$,$2);
        }
    }
    |  ';'                                                  
    {
        $$ = makeNode(InstructionVide,NULL);
    }
    ;
Exp :  Exp OR TB                                            
    {
        Node* ouExp = makeNode(Or,$2);
        addChild(ouExp,$1);
        addChild(ouExp,$3);
        $$=ouExp;
    }
    |  TB                                                   
    {
        $$ = $1;
    }
    ;
TB  :  TB AND FB                                            
    {
        Node *etExp = makeNode(And,$2);
        addChild(etExp,$1);
        addChild(etExp,$3);
        $$ = etExp;
    }
    |  FB                                                   
    {
        $$ = $1;
    }
    ;
FB  :  FB EQ M                                              
    {
        Node* eqExp = makeNode(Eq,$2);
        addChild(eqExp,$1);
        addChild(eqExp,$3);
        $$=eqExp;
    }
    |  M                                                    
    {
        $$ = $1;
    }
    ;
M   :  M ORDER E                                            
    {
        Node* orderExp = makeNode(Order,$2);
        addChild(orderExp,$1);
        addChild(orderExp,$3);
        $$=orderExp;
    }
    |  E                                                    
    {
        $$ = $1;
    }
    ;
E   :  E ADDSUB T                                           
    {
        Node* addsubExp = makeNode(Addsub,$2);
        addChild(addsubExp,$1);
        addChild(addsubExp,$3);
        $$ = addsubExp;
    }
    |  T                                                    
    {
        $$ = $1;
    }
    ;    
T   :  T DIVSTAR F                                          
    {
        Node* divExp = makeNode(Divstar,$2);
        addChild(divExp,$1);
        addChild(divExp,$3);
        $$ = divExp;
    }
    |  F                                                    
    {
        $$ = $1;
    }
    ;
F   :  ADDSUB F                                            
    {
        Node* negExp = makeNode(Negation,$1);
        addChild(negExp,$2);
        $$=negExp;
    } 
    |  '!' F                                                
    {
        Node* nonExp = makeNode(Non,"!");
        addChild(nonExp,$2);
        $$=nonExp;
    }
    |  '(' Exp ')'                                          
    {
        $$ = $2;
    }
    |  NUM                                                  
    {
        Node* numExp = makeNode(Num,$1);
        $$=numExp;
    }
    |  CHARACTER                                            
    {
        Node* characterExp = makeNode(Character,$1);
        $$=characterExp;
    }
    |  IDENT                                                
    {
        Node* identExp = makeNode(Ident,$1);
        $$=identExp;
    }
    |  IDENT '(' Arguments  ')'                             
    {
        Node* identExp2 = makeNode(Ident,$1);
        addChild(identExp2,$3);
        $$=identExp2;
    }
    ;
Arguments:
       ListExp                                              
    {
        $$ = $1;
    }
    |                                                       
    {
        $$ = NULL;
    }
    ;
ListExp:
       ListExp ',' Exp                                     
    {
        if ($$ == NULL) {
            Node* lst = makeNode(Arguments,NULL);
            addChild(lst,$1);
            addChild(lst,$3);
            $$=lst;
        } else {
            addChild($$,$3);
        }

    }
    |  Exp                                                  
    {
        Node* lst2 = makeNode(Arguments,NULL);
        addChild(lst2,$1);
        $$=lst2;
    }
    ;
%%

void yyerror(char *s) {
    fprintf(stderr, "%s : %d - %d\n", s, lineno,cara);
}

int main(void) {
    if (yyparse() == 0) {
        printTree(root);
        deleteTree(root);
        return 0;
    } else {
        deleteTree(root);
        return 1;
    }
}