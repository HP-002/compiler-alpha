/* === Definitions === */
%option noyywrap
%option yylineno

%{
#include "grammar.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdbool.h>


/* runner.c sets this when -tok is enabled. */
extern FILE *FILE_tok;
extern FILE *FILE_asc;
extern char line_buf[2048];
extern char err_buf[20][256];
extern int err_count;
void debug_log(const char *fmt, ...);

int columnNumber = 1;

/*runs after every token match, moved incrementing columnNumber to this*/
#define YY_USER_ACTION \
    strcat(line_buf, yytext); \
    columnNumber += yyleng;

/* prints a token to the .tok file if enabled. */
static void tok(int token){
    if (FILE_tok != NULL){
        if(token == 700){
            fprintf(FILE_tok, "%d %d %3d COMMENT \n", yylineno, columnNumber-yyleng, token);
        }
        else{
            fprintf(FILE_tok, "%d %d %3d \"%s\"\n", yylineno, columnNumber-yyleng, token, yytext);
        }
    }
    debug_log("token %d at %d:%d -> %s", token, yylineno, columnNumber, yytext);
}
static void asc(int lino){
    if (FILE_asc) {
        fprintf(FILE_asc, "%03d: %s", lino, line_buf);
        for (int i = 0; i < err_count; i++) {
            fprintf(FILE_asc, "%s\n", err_buf[i]);
        }
        fflush(FILE_asc);
    }
    debug_log("asc line flush at %d with %d buffered errors", lino, err_count);
    columnNumber = 1;
    err_count = 0;
    line_buf[0] = '\0';
}

/* Populates TypeInfo for basic tokens of ID, T_INTEGER, etc. */
void populate_tinfo() {
    yylval.tinfo = (TypeInfo *)malloc(sizeof(TypeInfo));
    yylval.tinfo->name = strdup(yytext);

    yylval.tinfo->line = yylineno;
    yylval.tinfo->column = columnNumber;

    yylval.tinfo->entry = NULL;
}

/* Populates ConstantInfo for constants (C_INTEGER, C_TRUE, etc.) */
void populate_constinfo(ConstantType c_type) {
    yylval.constinfo = (ConstantInfo *)malloc(sizeof(ConstantInfo));
    yylval.constinfo->name = strdup(yytext);

    yylval.constinfo->line = yylineno;
    yylval.constinfo->column = columnNumber;

    yylval.constinfo->entry = NULL;
    yylval.constinfo->type = c_type;

    switch (c_type) {
        case CINT:
            yylval.constinfo->value.int_v = atoi(yytext);
            break;
        case CCHAR:
            if(yytext[1]=='\\'){
                if(yytext[2]=='n'){
                    yylval.constinfo->value.char_v = (char)(10);
                }
            }
            else{
            yylval.constinfo->value.char_v = yytext[1];}
            break;
        case CBOOL:
            yylval.constinfo->value.bool_v = (strcmp(yytext, "true") == 0);
            break;
        case CADDR:
            yylval.constinfo->value.addr_v = NULL;
            break;
        case CSTR:
            yylval.constinfo->value.str_v = strdup(yytext);
            break;
    }
}
%}

/*=== States ===*/
%x COMMENT_STATE

/* Character classes */
DIGIT       [0-9]
LETTER      [a-zA-Z]
SQ          \'
ESC         \\
ESCABLE     [nt\'\\\"]
CHAR_BODY   ([^\\'\n]|{ESC}{ESCABLE})

%%
 /* === RULES === */
{DIGIT}+            { tok(C_INTEGER); populate_constinfo(CINT); return C_INTEGER; }
{SQ}{CHAR_BODY}{SQ} { tok(C_CHARACTER); populate_constinfo(CCHAR); return C_CHARACTER; }
\"([^"\\\n]|\\.)*\" { tok(C_STRING); populate_constinfo(CSTR); return C_STRING; }

    /* operators */
"+"                 {tok(ADD);  return ADD;}
"-"                 {tok(SUB_OR_NEG);  return SUB_OR_NEG;}
"*"                 {tok(MUL);  return MUL;}
"/"                 {tok(DIV);  return DIV;}
"%"                 {tok(REM);  return REM;}
"<"                 {tok(LESS_THAN);  return LESS_THAN;}
"="                 {tok(EQUAL_TO);  return EQUAL_TO;}
":="                {tok(ASSIGN);  return ASSIGN;}
"!"                 {tok(NOT);  return NOT;}
"&"                 {tok(AND);  return AND;}
"|"                 {tok(OR);  return OR;}
"."                 {tok(DOT);  return DOT;}

   /* punctuation */
[(]                 {tok(L_PAREN);  return L_PAREN;}
[)]                 {tok(R_PAREN);  return R_PAREN;}
\[                 {tok(L_BRACKET);  return L_BRACKET;}
\]                 {tok(R_BRACKET);  return R_BRACKET;}
[{]                 {tok(L_BRACE);  return L_BRACE;}
[}]                 {tok(R_BRACE);  return R_BRACE;}
[;]                 {tok(SEMI_COLON);  return SEMI_COLON;}
[:]                 {tok(COLON);  return COLON;}
[,]                 {tok(COMMA);  return COMMA;}
"->"                {tok(ARROW);  return ARROW;}

    /* keywords */
"true"              {tok(C_TRUE); populate_constinfo(CBOOL); return C_TRUE;}
"false"             {tok(C_FALSE); populate_constinfo(CBOOL); return C_FALSE;}
"null"              {tok(C_NULL); populate_constinfo(CADDR); return C_NULL;}
"while"             {tok(WHILE);  return WHILE;}
"if"                {tok(IF);  return IF;}
"then"              {tok(THEN);  return THEN;}
"else"              {tok(ELSE);  return ELSE;}
"type"              {tok(TYPE);  return TYPE;}
"function"          {tok(FUNCTION);  return FUNCTION;}
"return"            {tok(RETURN);  return RETURN;}
"external"          {tok(EXTERNAL);  return EXTERNAL;}
"as"                {tok(AS);  return AS;}
"reserve"           {tok(RESERVE);  return RESERVE;}
"release"           {tok(RELEASE);  return RELEASE;}

    /* types */
"integer"           {tok(T_INTEGER); populate_tinfo(); return T_INTEGER;}
"Boolean"           {tok(T_BOOLEAN); populate_tinfo(); return T_BOOLEAN;}
"character"         {tok(T_CHARACTER); populate_tinfo(); return T_CHARACTER;}
"address"           {tok(T_ADDRESS); populate_tinfo(); return T_ADDRESS;}
"string"            {tok(T_STRING); populate_tinfo(); return T_STRING;}

    /* whitespace and comments */
[ ]+                {}
"(*"                {tok(COMMENT); columnNumber+= yyleng; BEGIN(COMMENT_STATE);}
<COMMENT_STATE>\n   {asc(yylineno-1);columnNumber = 1;}
<COMMENT_STATE>"*)" { BEGIN(INITIAL);}
<COMMENT_STATE>.    {}


    /* identifier (This should be the last rule) */
({LETTER}|_)({LETTER}|{DIGIT}|_)*   {tok(ID); populate_tinfo(); return ID;}


    /* moved these to the end as they are last resorts */
\n                  { asc(yylineno-1); columnNumber = 1; }
<<EOF>>             { if (line_buf[0] != '\0') {
                        strcat(line_buf, "\n");
                        asc(yylineno);
                    }
                    yyterminate();}

.                   {  /* ignore other chars for now */ }

%%
/* === User Code */
