BACKSLSH: '\';
IDENTIFIER: [0-9a-zA-Z]+;
LBRACK: '[';
RBRACK: ']';
LBRACE: '{';
RBRACE: '}';
SPACE: ' ';
WHITESPACE: (SPACE | [\t\n])+;

mtex
  : statement*
  ;

statement
  : BACKSLSH IDENTIFIER data
  ;

data
  : attributes
  | attributes? content attributes?
  ;

attributes
  : LBRACK IDENTIFIER* RBRACK
  ;

content
  : LBRACE .* RBRACE
  ;
