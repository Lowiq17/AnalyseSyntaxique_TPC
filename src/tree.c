/* tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
#include "string.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
  "Prog",
  "Ident", 
  "Divstar", 
  "if", 
  "while", 
  "Type", 
  "Void", 
  "else", 
  "return", 
  "Or", 
  "And", 
  "Test_bool", 
  "Order", 
  "Addsub", 
  "Num", 
  "Character", 
  "DeclVars", 
  "Declarateurs", 
  "DeclFonct",
  "EnTeteFonct", 
  "ListTypVar",
  "CorpsFonction", 
  "Assign", 
  "Appel", 
  "Bloc", 
  "Negation", 
  "Non",  
  "ListExp", 
  "InstructionVide", 
  "Instr", 
  "SuiteInstr", 
  "static",
  "VariableLoc",
  "VariableGlbl",
  "Fonction",
  "Parametres",
  "Variable",
  "TeteFonction",
  "Variable_Static",
  "Arguments",
  "Type_Retour",
  "Type_Parametre"
  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeNode(label_t label, char* lexeme) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  if (lexeme) {
    node->lexeme = strdup(lexeme);
  } else {
    node->lexeme = NULL;
  }
  return node;
}

void addSibling(Node *node, Node *sibling) {
  if (node==NULL) return;
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node == NULL) return;
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node->lexeme);
  free(node);
}

void printTree(Node *node) {
  static bool rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;       // depth of current node
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }
  if (node->lexeme == NULL) {
    printf("%s", StringFromLabel[node->label]);
    printf("\n");
  } else {
    printf("%s : %s", StringFromLabel[node->label], node->lexeme);
    printf("\n");
  }

  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}
