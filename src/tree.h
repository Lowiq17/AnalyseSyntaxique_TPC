/* tree.h */

typedef enum {
  Prog,
  Ident, 
  Divstar, 
  If, 
  While, 
  Type, 
  Void, 
  Else, 
  Return, 
  Or, 
  And, 
  Eq, 
  Order, 
  Addsub, 
  Num, 
  Character, 
  DeclVars, 
  Declarateurs, 
  DeclFonct,
  EnTeteFonct, 
  ListTypVar,
  CorpsFonction, 
  Assign, 
  Appel, 
  Bloc, 
  Negation, 
  Non, 
  ListExp, 
  InstructionVide, 
  Instr, 
  SuiteInstr, 
  Static,
  VariableLoc,
  VariableGlbl,
  Fonction,
  Parametres,
  Variable,
  TeteFonction,
  Variable_Static,
  Arguments,
  Type_retour,
  Type_para
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
  char* lexeme;
} Node;

Node *makeNode(label_t label, char* lexem);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
