%{
#include <stdlib.h>
#include <stdio.h>

#include "tree.h"
#include "parser.tab.h"
int lineno = 1;
int cara = 1;
%}

%x COM1LIGNE
%x COMLIGNES
%option nounput
%option noinput
%option noyywrap
%%

"/*"                         {cara+=2;BEGIN COMLIGNES; }
<COMLIGNES>"*/"                         {cara+=2;BEGIN INITIAL; }
<COMLIGNES>. ;                          {cara++;}
<COMLIGNES>\n ;                         {lineno++;cara = 0;}       

"//"                         {cara+=2;BEGIN COM1LIGNE; }
<COM1LIGNE>. ;               {cara++;}
<COM1LIGNE>\n ;                          { lineno++;cara=0;BEGIN INITIAL; }

'([^\\]|\\[nt\'])'      { strcpy(yylval.chaine,yytext);return CHARACTER;cara += strlen(yytext);        }
"int"                   { strcpy(yylval.chaine,yytext);return TYPE;cara += strlen(yytext);        }
"char"                  { strcpy(yylval.chaine,yytext);return TYPE;cara += strlen(yytext);        }
"=="                    { strcpy(yylval.chaine,yytext);return EQ;cara += strlen(yytext);          }
"!="                    { strcpy(yylval.chaine,yytext);return EQ;cara += strlen(yytext);          }
"<="                    { strcpy(yylval.chaine,yytext);return ORDER;cara += strlen(yytext);       }
">="                    { strcpy(yylval.chaine,yytext);return ORDER;cara += strlen(yytext);       }
")"                     { strcpy(yylval.chaine,yytext);return ')';cara += strlen(yytext);         }
"("                     { strcpy(yylval.chaine,yytext);return '(';cara += strlen(yytext);         }
"{"                     { strcpy(yylval.chaine,yytext);return '{';cara += strlen(yytext);         }
"}"                     { strcpy(yylval.chaine,yytext);return '}';cara += strlen(yytext);         }
","                     { strcpy(yylval.chaine,yytext);return ',';cara += strlen(yytext);         }
";"                     { strcpy(yylval.chaine,yytext);return ';';cara += strlen(yytext);         }
"="                     { strcpy(yylval.chaine,yytext);return '=';cara += strlen(yytext);         }
">"                     { strcpy(yylval.chaine,yytext);return ORDER;cara += strlen(yytext);       }
"<"                     { strcpy(yylval.chaine,yytext);return ORDER;cara += strlen(yytext);       }
"+"                     { strcpy(yylval.chaine,yytext);return ADDSUB;cara += strlen(yytext);      }
"-"                     { strcpy(yylval.chaine,yytext);return ADDSUB;cara += strlen(yytext);      }
"/"                     { strcpy(yylval.chaine,yytext);return DIVSTAR;cara += strlen(yytext);     }
"%"                     { strcpy(yylval.chaine,yytext);return DIVSTAR;cara += strlen(yytext);     }
"*"                     { strcpy(yylval.chaine,yytext);return DIVSTAR;cara += strlen(yytext);     }
"||"                    { strcpy(yylval.chaine,yytext);return OR;cara += strlen(yytext);          }
"&&"                    { strcpy(yylval.chaine,yytext);return AND;cara += strlen(yytext);         }
"while"                 { strcpy(yylval.chaine,yytext);return WHILE;cara += strlen(yytext);       }
"if"                    { strcpy(yylval.chaine,yytext);return IF;cara += strlen(yytext);          }
"else"                  { strcpy(yylval.chaine,yytext);return ELSE;cara += strlen(yytext);        }
"return"                { strcpy(yylval.chaine,yytext);return RETURN;cara += strlen(yytext);      }
"static"                { strcpy(yylval.chaine,yytext);return STATIC;cara += 6;      } 
"void"                  { strcpy(yylval.chaine,yytext);return VOID;cara += strlen(yytext);        }
[0-9]+                  { strcpy(yylval.chaine,yytext);return NUM; cara += strlen(yytext);        }
[_a-zA-Z][_0-9a-zA-Z]*  { strcpy(yylval.chaine, yytext); return IDENT;cara += strlen(yytext);     }
[ \t]+                  {cara += strlen(yytext);}
\n                      {lineno++;cara=0;}
.                       {return yytext[0];cara++;   }


%%
