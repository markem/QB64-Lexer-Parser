/*
	A [F]lex version of QB64.
	by Mark Manning
	Copyleft (C) 2015-NOW.
	This program/source code can be used by anyone who wishes to use it.
	For any purpose commercial or otherwise.  All that is asked is
	recognition of my work.  This will be hosted on GitHub.
*/

	/*	Definitions	*/

binary			([01])
octal			([01234567])
digit			([[:digit:]])
alpha			([[:alpha:]])
alnum			([[:alnum:]])
xdigit			([[:xdigit:]])
exponent		([Ee][-+]?{digit}+)
integer			({digit}+)
float			(({digit}+\.{digit}*|{digit}*\.{digit}+){exponent}?)
hex_integer		(0[Xx]{hex_code}+)
num_var			({letter}_][[:alnum:]_]*)
str_var			([[:alpha:]_][[:alnum:]_]*[$]?)
blank			([[:blank:]])
space			([[:space:]])
ws				({blank}|{space})
nl				(\n)
notnl			(.)
any				({notnl}|{nl})

%option noyywrap nodefault yylineno case-insensitive

%x INCL
%x STRING

	/*	Symbol Table	*/
	/*	This is taken directly from the Flex/Bison manual from O'Reilly	*/

%{
	/*	Defines	*/

	/*
		The MAX_START_STACK >MUST< be at least the size of all start states. MORE IS BETTER HERE!!!!
		So you don't fall off the end of the stack!  You have been warned!  Make it smaller at your
		own risk!
	*/

#define MAX_START_STACK 3000
#define MAX_INCLUDE_DEPTH 1000
#define MAX_STRING_LENGTH 65536
#define NHASH 9997

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"y.tab.h"
#include	"qb_enums.h"

char yylval[MAX_STRING_LENGTH];

struct symbol {				/* a variable name */
	struct ref *reflist;
	char *name;
	};

struct ref {
	struct ref *next;
	char *filename;
	int flags;				/* 01 - definition */
	int lineno;
	};

struct symbol symtab[NHASH];
struct symbol *lookup(char*);

	int i;
	int	include_stack_ptr = 0;
	int start_stack[MAX_START_STACK];
	int start_stack_counter = 0;

	char myBuffer[MAX_STRING_LENGTH];
	char *myString;
	char c;

YY_BUFFER_STATE	include_stack[ 1000 ];

	/*	include file stack	*/

void	yyerror( char * );

struct {
	char	token[40];
	int		id;
	} tokens;

	int	nline, nchar, nword, ws;

%}

%%
	/*	Rules	*/

	/*
	The following was taken from http://flex.sourceforge.net/manual/Multiple-Input-Buffers.html
	because it was a lot simpler than what was in the Flex/Bison book.
	*/

^{ws}*(rem|'){ws}+\$include{ws}*[\"<]	{ start_stack[start_stack_counter++] = YY_START; BEGIN INCL; }
:{ws}*(rem|'){ws}+\$include{ws}*[\"<]	{ start_stack[start_stack_counter++] = YY_START; BEGIN INCL; }

<INCL>[^{ws}*\">]+   { /* got the include file name */
	if( include_stack_ptr >= MAX_INCLUDE_DEPTH ){
		fprintf( stderr, "*****ERROR : Includes nested too deeply" );
		exit( 1 );
		}

	include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

	yyin = fopen( yytext, "r" );

	if( ! yyin ){ printf( "*****ERROR : No Input File - Aborting\n" ); exit; }

	yy_switch_to_buffer( yy_create_buffer( yyin, YY_BUF_SIZE ) );

	BEGIN(start_stack[--start_stack_counter]);
	}

<<EOF>> {

	if( --include_stack_ptr < 0 ){ yyterminate(); }
		else{
			yy_delete_buffer( YY_CURRENT_BUFFER );
			yy_switch_to_buffer( include_stack[include_stack_ptr] );
			}
   }

	/*	The string parser is taken from http://epaperpress.com/lexandyacc/str.html - Modified 2/19/2016 MEM	*/

{ws}\"			{
					start_stack[start_stack_counter++] = YY_START;
					for( i=0; i<MAX_STRING_LENGTH; i++ ){ myBuffer[i] = 0; }
					

					BEGIN STRING;
					myString = myBuffer;
					}

<STRING>\\n		{ *myString++ = '\n'; }
<STRING>\\t		{ *myString++ = '\t'; }
<STRING>\\\"	{ *myString++ = '\"'; }
<STRING>\"		{
					*myString = 0;
					c = input();
					BEGIN(start_stack[--start_stack_counter]);
					return ENUM_QB_STRING_VALUE;
				}

<STRING>\n		{
					printf( "*****ERROR : Unterminated String : %s\n", yytext );
					exit(1);
				}

<STRING>.		{	*myString++ = *yytext; }

	/*	+++++	DO NOT REMOVE THE NEXT LINE!!!	+++++	*/
	/*	BEGIN LEX	*/
"+"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_PLUS_SIGN; }

"-"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_MINUS_SIGN; }

"*"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_ASTERIK; }

"/"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_SLASH_FORWARDS; }

"\\"						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_SLASH_BACK; }

"^"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_CARET; }

"="							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_EQUAL; }

"<"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_LESS_THAN; }

">"							{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_GREATER_THAN; }

"<="						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }

">="						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }

"<>"						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NOT_EQUAL_TO; }

"\("						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_PAREN_OPEN; }

"\)"						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_PAREN_CLOSED; }

"&"b{binary}+				{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BINARY; }

"&"o{octal}+				{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OCTAL; }

"&"h{xdigit}+				{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_HEXADECIMAL; }

{alpha}{alnum}*\$			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STRING_VARIABLE; }

{alpha}{alnum}*\!			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SINGLE_VARIABLE; }

{alpha}{alnum}*\#			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DOUBLE_VARIABLE; }

{alpha}{alnum}*\#\#			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FLOAT_VARIABLE; }

{alpha}{alnum}*\%			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTEGER_VARIABLE; }

{alpha}{alnum}*\&			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LONG_VARIABLE; }

{alpha}{alnum}*\&\&			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTEGER64_VARIABLE; }

{alpha}{alnum}*\`			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BIT_VARIABLE; }

{alpha}{alnum}*\%\%			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BYTE_VARIABLE; }

{alpha}{alnum}*\%\&			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OFFSET_VARIABLE; }

{alpha}{alnum}*\~			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_VARIABLE; }

{alpha}{alnum}*\~\%			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }

{alpha}{alnum}*\~\&			{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_LONG_VARIABLE; }

{alpha}{alnum}*\~\&\&		{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }

{alpha}{alnum}*\~\`			{	nchar += yyleng; strcpy(yylval,yytext); return

ENUM_QB_UNSIGNED_BIT_VARIABLE; }

{alpha}{alnum}*\~\%\%		{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }

{alpha}{alnum}*\~\%\&		{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }

{alpha}{alnum}*				{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STANDARD_VARIABLE; }

{digit}+					{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LONG_VARIABLE; }

{float}						{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FLOAT_VARIABLE; }

^{ws}*rem{ws}+[^$].*{nl}{1}	{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_REM; }

^{ws}*'{ws}+[^$].*{nl}{1}	{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_REM; }

:{ws}*rem{ws}+[^$].*{nl}{1}	{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_REM; }

:{ws}*'{ws}+[^$].*{nl}{1}	{	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_REM; }

(^|{ws}*)IF{ws}*                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_IF; }
(^|{ws}*)TO{ws}*                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TO; }
(^|{ws}*)AS{ws}*                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_AS; }
(^|{ws}*)DO{ws}*                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DO; }
(^|{ws}*)OR{ws}*                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OR; }
(^|{ws}*)EQV{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_EQV; }
(^|{ws}*)FIX{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FIX; }
(^|{ws}*)ERL{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERL; }
(^|{ws}*)EXP{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_EXP; }
(^|{ws}*)ERR{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERR; }
(^|{ws}*)EOF{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_EOF; }
(^|{ws}*)INT{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INT; }
(^|{ws}*)CVL{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVL; }
(^|{ws}*)DIM{ws}+                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DIM; }
(^|{ws}*)POS{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_POS; }
(^|{ws}*)FOR{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FOR; }
(^|{ws}*)END{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_END; }
(^|{ws}*)_CV{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CV; }
(^|{ws}*)FRE{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FRE; }
(^|{ws}*)IMP{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_IMP; }
(^|{ws}*)LOC{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOC; }
(^|{ws}*)INP{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INP; }
(^|{ws}*)LET{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LET; }
(^|{ws}*)LEN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LEN; }
(^|{ws}*)LOF{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOF; }
(^|{ws}*)LOG{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOG; }
(^|{ws}*)OFF{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OFF; }
(^|{ws}*)RND{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RND; }
(^|{ws}*)NOT{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NOT; }
(^|{ws}*)MOD{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MOD; }
(^|{ws}*)GET{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GET; }
(^|{ws}*)OUT{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OUT; }
(^|{ws}*)CVS{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVS; }
(^|{ws}*)TAN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TAN; }
(^|{ws}*)ATN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ATN; }
(^|{ws}*)TAB{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TAB; }
(^|{ws}*)CVI{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVI; }
(^|{ws}*)SQR{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SQR; }
(^|{ws}*)ASC{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ASC; }
(^|{ws}*)ANY{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ANY; }
(^|{ws}*)XOR{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_XOR; }
(^|{ws}*)ABS{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ABS; }
(^|{ws}*)VAL{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VAL; }
(^|{ws}*)AND{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_AND; }
(^|{ws}*)SPC{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SPC; }
(^|{ws}*)SUB{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SUB; }
(^|{ws}*)CVD{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVD; }
(^|{ws}*)CLS{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CLS; }
(^|{ws}*)COS{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_COS; }
(^|{ws}*)SGN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SGN; }
(^|{ws}*)RUN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RUN; }
(^|{ws}*)SIN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SIN; }
(^|{ws}*)CSNG{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CSNG; }
(^|{ws}*)GOTO{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GOTO; }
(^|{ws}*)DATA{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DATA; }
(^|{ws}*)_SEC{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SEC; }
(^|{ws}*)_R2G{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__R2G; }
(^|{ws}*)_RED{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RED; }
(^|{ws}*)_RGB{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RGB; }
(^|{ws}*)FREE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FREE; }
(^|{ws}*)DRAW{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DRAW; }
(^|{ws}*)CASE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CASE; }
(^|{ws}*)CDBL{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CDBL; }
(^|{ws}*)EXIT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_EXIT; }
(^|{ws}*)CINT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CINT; }
(^|{ws}*)CALL{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CALL; }
(^|{ws}*)BEEP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BEEP; }
(^|{ws}*)CLNG{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CLNG; }
(^|{ws}*)_G2R{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__G2R; }
(^|{ws}*)ELSE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ELSE; }
(^|{ws}*)_G2D{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__G2D; }
(^|{ws}*)KILL{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_KILL; }
(^|{ws}*)READ{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_READ; }
(^|{ws}*)RSET{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RSET; }
(^|{ws}*)STEP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STEP; }
(^|{ws}*)PSET{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PSET; }
(^|{ws}*)_COT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COT; }
(^|{ws}*)_D2G{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__D2G; }
(^|{ws}*)POKE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_POKE; }
(^|{ws}*)_CSC{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CSC; }
(^|{ws}*)STOP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STOP; }
(^|{ws}*)SWAP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SWAP; }
(^|{ws}*)VIEW{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VIEW; }
(^|{ws}*)WAIT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WAIT; }
(^|{ws}*)WEND{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WEND; }
(^|{ws}*)TYPE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TYPE; }
(^|{ws}*)TRON{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TRON; }
(^|{ws}*)_BIT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BIT; }
(^|{ws}*)THEN{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_THEN; }
(^|{ws}*)_D2R{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__D2R; }
(^|{ws}*)SADD{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SADD; }
(^|{ws}*)LPOS{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LPOS; }
(^|{ws}*)NAME{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NAME; }
(^|{ws}*)LONG{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LONG; }
(^|{ws}*)OPEN{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OPEN; }
(^|{ws}*)LIST{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LIST; }
(^|{ws}*)_R2D{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__R2D; }
(^|{ws}*)PMAP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PMAP; }
(^|{ws}*)PEEK{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PEEK; }
(^|{ws}*)LOCK{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOCK; }
(^|{ws}*)LINE{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LINE; }
(^|{ws}*)LSET{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LSET; }
(^|{ws}*)GOSUB{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GOSUB; }
(^|{ws}*)BYVAL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BYVAL; }
(^|{ws}*)STICK{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STICK; }
(^|{ws}*)CALLS{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CALLS; }
(^|{ws}*)TROFF{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TROFF; }
(^|{ws}*)BSAVE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BSAVE; }
(^|{ws}*)BLOAD{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BLOAD; }
(^|{ws}*)ALIAS{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ALIAS; }
(^|{ws}*)_RGBA{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RGBA; }
(^|{ws}*)WHILE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WHILE; }
(^|{ws}*)WIDTH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WIDTH; }
(^|{ws}*)INSTR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INSTR; }
(^|{ws}*)_SECH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SECH; }
(^|{ws}*)CDECL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CDECL; }
(^|{ws}*)_TANH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__TANH; }
(^|{ws}*)_SINH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SINH; }
(^|{ws}*)UNTIL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNTIL; }
(^|{ws}*)MKDIR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKDIR; }
(^|{ws}*)PCOPY{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PCOPY; }
(^|{ws}*)PAINT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PAINT; }
(^|{ws}*)REDIM{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_REDIM; }
(^|{ws}*)RESET{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RESET; }
(^|{ws}*)PRINT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRINT; }
(^|{ws}*)FILES{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FILES; }
(^|{ws}*)ERDEV{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERDEV; }
(^|{ws}*)ERASE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERASE; }
(^|{ws}*)POINT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_POINT; }
(^|{ws}*)FIELD{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FIELD; }
(^|{ws}*)RMDIR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RMDIR; }
(^|{ws}*)IOCTL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_IOCTL; }
(^|{ws}*)SOUND{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SOUND; }
(^|{ws}*)CLEAR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CLEAR; }
(^|{ws}*)ERROR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERROR; }
(^|{ws}*)CHDIR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CHDIR; }
(^|{ws}*)CLOSE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CLOSE; }
(^|{ws}*)SLEEP{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SLEEP; }
(^|{ws}*)_ACOS{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ACOS; }
(^|{ws}*)SHELL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SHELL; }
(^|{ws}*)CONST{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CONST; }
(^|{ws}*)COLOR{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_COLOR; }
(^|{ws}*)CHAIN{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CHAIN; }
(^|{ws}*)INPUT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INPUT; }
(^|{ws}*)_ICON{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ICON; }
(^|{ws}*)_COSH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COSH; }
(^|{ws}*)_ASIN{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ASIN; }
(^|{ws}*)_COTH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COTH; }
(^|{ws}*)_CEIL{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CEIL; }
(^|{ws}*)_AXIS{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__AXIS; }
(^|{ws}*)_EXIT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__EXIT; }
(^|{ws}*)_CSCH{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CSCH; }
(^|{ws}*)\$IF{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_IF; }
(^|{ws}*)_BYTE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BYTE; }
(^|{ws}*)_CLIP{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CLIP; }
(^|{ws}*)_HIDE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__HIDE; }
(^|{ws}*)_BLUE{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BLUE; }
(^|{ws}*)ACCESS{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ACCESS; }
(^|{ws}*)LBOUND{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LBOUND; }
(^|{ws}*)_FLOAT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FLOAT; }
(^|{ws}*)APPEND{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_APPEND; }
(^|{ws}*)\$END{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_END; }
(^|{ws}*)MKL\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKL_DS; }
(^|{ws}*)MKS\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKS_DS; }
(^|{ws}*)OCT\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OCT_DS; }
(^|{ws}*)ON{ws}+COM{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_COM; }
(^|{ws}*)MKI\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKI_DS; }
(^|{ws}*)MKD\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKD_DS; }
(^|{ws}*)_WHEEL{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__WHEEL; }
(^|{ws}*)LOCATE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOCATE; }
(^|{ws}*)_TITLE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__TITLE; }
(^|{ws}*)LPRINT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LPRINT; }
(^|{ws}*)_WIDTH{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__WIDTH; }
(^|{ws}*)BINARY{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BINARY; }
(^|{ws}*)DEFLNG{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEFLNG; }
(^|{ws}*)CIRCLE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CIRCLE; }
(^|{ws}*)DEFSNG{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEFSNG; }
(^|{ws}*)CHR\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CHR_DS; }
(^|{ws}*)DEFINT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEFINT; }
(^|{ws}*)DEFDBL{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEFDBL; }
(^|{ws}*)CVDMBF{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVDMBF; }
(^|{ws}*)CVSMBF{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CVSMBF; }
(^|{ws}*)COMMON{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_COMMON; }
(^|{ws}*)DEF{ws}+FN{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEF_FN; }
(^|{ws}*)DEFSTR{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEFSTR; }
(^|{ws}*)_MK\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MK_DS; }
(^|{ws}*)\$LET{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_LET; }
(^|{ws}*)_HYPOT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__HYPOT; }
(^|{ws}*)ON{ws}+KEY{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_KEY; }
(^|{ws}*)_GREEN{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__GREEN; }
(^|{ws}*)END{ws}+IF{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_END_IF; }
(^|{ws}*)ELSEIF{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ELSEIF; }
(^|{ws}*)DIR\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DIR_DS; }
(^|{ws}*)DOUBLE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DOUBLE; }
(^|{ws}*)_LIMIT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LIMIT; }
(^|{ws}*)HEX\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_HEX_DS; }
(^|{ws}*)ON{ws}+PEN{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_PEN; }
(^|{ws}*)UBOUND{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UBOUND; }
(^|{ws}*)UEVENT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UEVENT; }
(^|{ws}*)_ROUND{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ROUND; }
(^|{ws}*)_ATAN2{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ATAN2; }
(^|{ws}*)_ATANH{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ATANH; }
(^|{ws}*)STR\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STR_DS; }
(^|{ws}*)CSRLIN{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CSRLIN; }
(^|{ws}*)SYSTEM{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SYSTEM; }
(^|{ws}*)UNLOCK{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNLOCK; }
(^|{ws}*)_ASINH{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ASINH; }
(^|{ws}*)_ALPHA{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ALPHA; }
(^|{ws}*)WINDOW{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WINDOW; }
(^|{ws}*)_ACOSH{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ACOSH; }
(^|{ws}*)_RED32{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RED32; }
(^|{ws}*)_ARCSC{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ARCSC; }
(^|{ws}*)_RGB32{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RGB32; }
(^|{ws}*)VARPTR{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VARPTR; }
(^|{ws}*)VARSEG{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VARSEG; }
(^|{ws}*)STATIC{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STATIC; }
(^|{ws}*)STRING{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STRING; }
(^|{ws}*)SINGLE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SINGLE; }
(^|{ws}*)RETURN{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RETURN; }
(^|{ws}*)SETMEM{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SETMEM; }
(^|{ws}*)RANDOM{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RANDOM; }
(^|{ws}*)PRESET{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRESET; }
(^|{ws}*)OUTPUT{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OUTPUT; }
(^|{ws}*)_DELAY{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DELAY; }
(^|{ws}*)SHARED{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SHARED; }
(^|{ws}*)RESUME{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RESUME; }
(^|{ws}*)SIGNAL{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SIGNAL; }
(^|{ws}*)_OS\${ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__OS_DS; }
(^|{ws}*)DEF{ws}+SEG{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DEF_SEG; }
(^|{ws}*)_ARCCOT{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ARCCOT; }
(^|{ws}*)PALETTE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PALETTE; }
(^|{ws}*)_BUTTON{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BUTTON; }
(^|{ws}*)DECLARE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DECLARE; }
_glEnd                                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEnd; }
(^|{ws}*)ON{ws}+PLAY{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_PLAY; }
(^|{ws}*)ON{ws}+GOTO{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_GOTO; }
(^|{ws}*)_HEIGHT{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__HEIGHT; }
(^|{ws}*)_CWD\${ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CWD_DS; }
(^|{ws}*)ELSE{ws}+IF{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ELSE_IF; }
(^|{ws}*)LEFT\${ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LEFT_DS; }
(^|{ws}*)ENVIRON{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ENVIRON; }
(^|{ws}*)_BLUE32{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BLUE32; }
(^|{ws}*)RESTORE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RESTORE; }
(^|{ws}*)_KEYHIT{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__KEYHIT; }
(^|{ws}*)\$ELSE{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_ELSE; }
(^|{ws}*)INTEGER{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTEGER; }
(^|{ws}*)_ARCSEC{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ARCSEC; }
(^|{ws}*)_DEFINE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEFINE; }
(^|{ws}*)_MOUSEY{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEY; }
(^|{ws}*)CASE{ws}+IS{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CASE_IS; }
(^|{ws}*)_RGBA32{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RGBA32; }
(^|{ws}*)_SNDLEN{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDLEN; }
(^|{ws}*)_MEMNEW{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMNEW; }
(^|{ws}*)_MOUSEX{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEX; }
(^|{ws}*)_MEMPUT{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMPUT; }
(^|{ws}*)_RESIZE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RESIZE; }
(^|{ws}*)_STRCMP{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__STRCMP; }
(^|{ws}*)_SNDBAL{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDBAL; }
(^|{ws}*)_SNDVOL{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDVOL; }
(^|{ws}*)_SOURCE{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SOURCE; }
(^|{ws}*)_SNDRAW{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDRAW; }
(^|{ws}*)FILEATTR{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FILEATTR; }
(^|{ws}*)_KEYDOWN{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__KEYDOWN; }
(^|{ws}*)ERDEV\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ERDEV_DS; }
(^|{ws}*)ON{ws}+GOSUB{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_GOSUB; }
(^|{ws}*)OPEN{ws}+COM{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OPEN_COM; }
(^|{ws}*)_SNDRATE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDRATE; }
(^|{ws}*)INPUT\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INPUT_DS; }
(^|{ws}*)LCASE\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LCASE_DS; }
(^|{ws}*)FOR{ws}+FILE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FOR_FILE; }
(^|{ws}*)ON{ws}+STRIG{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_STRIG; }
_glFogf                                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFogf; }
(^|{ws}*)ON{ws}+ERROR{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_ERROR; }
(^|{ws}*)_SNDSTOP{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDSTOP; }
(^|{ws}*)INKEY\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INKEY_DS; }
(^|{ws}*)_DEVICES{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEVICES; }
(^|{ws}*)GET{ws}+QB64{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GET_QB64; }
(^|{ws}*)GET{ws}+FILE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GET_FILE; }
(^|{ws}*)LTRIM\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LTRIM_DS; }
_glFogi                                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFogi; }
(^|{ws}*)ON{ws}+TIMER{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_TIMER; }
(^|{ws}*)FREEFILE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FREEFILE; }
(^|{ws}*)_GREEN32{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__GREEN32; }
(^|{ws}*)END{ws}+TYPE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_END_TYPE; }
(^|{ws}*)_CONSOLE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CONSOLE; }
(^|{ws}*)RTRIM\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RTRIM_DS; }
(^|{ws}*)NEW{ws}+LINE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NEW_LINE; }
(^|{ws}*)_MEMFREE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMFREE; }
(^|{ws}*)RIGHT\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RIGHT_DS; }
(^|{ws}*)_SCREENX{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENX; }
(^|{ws}*)_SNDCOPY{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDCOPY; }
(^|{ws}*)ABSOLUTE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ABSOLUTE; }
(^|{ws}*)_MEMCOPY{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMCOPY; }
(^|{ws}*)_SCREENY{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENY; }
(^|{ws}*)KEY{ws}+LIST{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_KEY_LIST; }
(^|{ws}*)_MEMFILL{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMFILL; }
(^|{ws}*)_ALPHA32{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ALPHA32; }
(^|{ws}*)IOCTL\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_IOCTL_DS; }
(^|{ws}*)_SNDPLAY{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPLAY; }
(^|{ws}*)UCASE\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UCASE_DS; }
(^|{ws}*)PUT{ws}+FILE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PUT_FILE; }
(^|{ws}*)PUT{ws}+QB64{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PUT_QB64; }
(^|{ws}*)_SNDLOOP{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDLOOP; }
_glHint                                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glHint; }
(^|{ws}*)_SNDOPEN{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDOPEN; }
(^|{ws}*)SPACE\${ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SPACE_DS; }
(^|{ws}*)_STRICMP{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__STRICMP; }
_glRects                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRects; }
_glRecti                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRecti; }
(^|{ws}*)MKDMBF\${ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKDMBF_DS; }
(^|{ws}*)\$ELSEIF{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_ELSEIF; }
(^|{ws}*)_OPENHOST{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__OPENHOST; }
(^|{ws}*)_DONTWAIT{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DONTWAIT; }
_glAccum                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glAccum; }
(^|{ws}*)_SNDLIMIT{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDLIMIT; }
(^|{ws}*)RANDOMIZE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RANDOMIZE; }
(^|{ws}*)STRING\${ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STRING_DS; }
(^|{ws}*)\$STATIC{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_STATIC; }
(^|{ws}*)_SETALPHA{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SETALPHA; }
(^|{ws}*)_SNDCLOSE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDCLOSE; }
(^|{ws}*)_PRESERVE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PRESERVE; }
(^|{ws}*)VARPTR\${ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VARPTR_DS; }
_glClear                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClear; }
(^|{ws}*)ON{ws}+UEVENT{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ON_UEVENT; }
_glBegin                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glBegin; }
(^|{ws}*)_PUTIMAGE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PUTIMAGE; }
(^|{ws}*)_SNDPAUSE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPAUSE; }
(^|{ws}*)\$RESIZE{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_RESIZE; }
(^|{ws}*)MKSMBF\${ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MKSMBF_DS; }
(^|{ws}*)_UNSIGNED{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__UNSIGNED; }
(^|{ws}*)_FREEFONT{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FREEFONT; }
_glMap1f                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMap1f; }
_glMap1d                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMap1d; }
_glFlush                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFlush; }
(^|{ws}*)_LOADFONT{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LOADFONT; }
_glOrtho                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glOrtho; }
(^|{ws}*)_NEWIMAGE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__NEWIMAGE; }
(^|{ws}*)_LASTAXIS{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LASTAXIS; }
(^|{ws}*)_KEYCLEAR{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__KEYCLEAR; }
_glRectf                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectf; }
_glMap2f                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMap2f; }
_glFogiv                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFogiv; }
_glMap2d                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMap2d; }
_glFogfv                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFogfv; }
(^|{ws}*)_MEMIMAGE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMIMAGE; }
(^|{ws}*)CASE{ws}+ELSE{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CASE_ELSE; }
_glRectd                                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectd; }
(^|{ws}*)INTERRUPT{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTERRUPT; }
(^|{ws}*)WHILE{ws}+WEND{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WHILE_WEND; }
(^|{ws}*)WRITE{ws}+FILE{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WRITE_FILE; }
(^|{ws}*)_CONNECTED{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CONNECTED; }
(^|{ws}*)ENVIRON\${ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_ENVIRON_DS; }
(^|{ws}*)COMMAND\${ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_COMMAND_DS; }
_glIndexi                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexi; }
_glIndexs                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexs; }
(^|{ws}*)_MEMEXISTS{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMEXISTS; }
_glScalef                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glScalef; }
_glBitmap                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glBitmap; }
(^|{ws}*)_SHELLHIDE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SHELLHIDE; }
(^|{ws}*)SHELL{ws}+QB64{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SHELL_QB64; }
_glIsList                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIsList; }
(^|{ws}*)\$CONSOLE{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_CONSOLE; }
(^|{ws}*)_MOUSEMOVE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEMOVE; }
_glIndexd                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexd; }
(^|{ws}*)\$DYNAMIC{ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_DYNAMIC; }
(^|{ws}*)_MOUSEHIDE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEHIDE; }
(^|{ws}*)_PIXELSIZE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PIXELSIZE; }
(^|{ws}*)_COPYIMAGE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COPYIMAGE; }
(^|{ws}*)_LOADIMAGE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LOADIMAGE; }
_glScaled                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glScaled; }
(^|{ws}*)_SNDGETPOS{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDGETPOS; }
(^|{ws}*)VIEW{ws}+PRINT{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_VIEW_PRINT; }
_glLighti                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLighti; }
_glIndexf                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexf; }
(^|{ws}*)PRINT{ws}+FILE{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRINT_FILE; }
(^|{ws}*)_LASTWHEEL{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LASTWHEEL; }
(^|{ws}*)PRINT{ws}+QB64{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRINT_QB64; }
(^|{ws}*)_SNDPAUSED{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPAUSED; }
(^|{ws}*)_INTEGER64{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__INTEGER64; }
(^|{ws}*)_DIREXISTS{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DIREXISTS; }
(^|{ws}*)INPUT{ws}+QB64{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INPUT_QB64; }
_glFinish                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFinish; }
_glLightf                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightf; }
(^|{ws}*)LINE{ws}+INPUT{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LINE_INPUT; }
_glRectiv                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectiv; }
(^|{ws}*)\$ELSE{ws}+IF{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_ELSE_IF; }
_glRectsv                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectsv; }
(^|{ws}*)_DONTBLEND{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DONTBLEND; }
(^|{ws}*)INTERRUPTX{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTERRUPTX; }
_glEnable                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEnable; }
(^|{ws}*)_DEVICE\${ws}*                           {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEVICE_DS; }
(^|{ws}*)_FONTWIDTH{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FONTWIDTH; }
(^|{ws}*)_ERRORLINE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__ERRORLINE; }
(^|{ws}*)_FREEIMAGE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FREEIMAGE; }
(^|{ws}*)_FREETIMER{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FREETIMER; }
(^|{ws}*)_MOUSESHOW{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSESHOW; }
(^|{ws}*)_SNDRAWLEN{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDRAWLEN; }
_glRectdv                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectdv; }
_glRectfv                                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRectfv; }
(^|{ws}*)_SNDSETPOS{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDSETPOS; }
_glIndexfv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexfv; }
(^|{ws}*)_SCREENHIDE{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENHIDE; }
_glDisable                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDisable; }
_glIndexdv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexdv; }
(^|{ws}*)_SCREENSHOW{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENSHOW; }
_glPopName                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPopName; }
_glIndexsv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexsv; }
_glIndexub                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexub; }
_glIndexiv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexiv; }
(^|{ws}*)_MEMELEMENT{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMELEMENT; }
_glLightfv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightfv; }
(^|{ws}*)_SCREENMOVE{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENMOVE; }
_glColor4s                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4s; }
(^|{ws}*)_PRINTIMAGE{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PRINTIMAGE; }
_glColor3i                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3i; }
_glColor3s                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3s; }
_glColor4b                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4b; }
_glColor3f                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3f; }
_glFrustum                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFrustum; }
_glScissor                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glScissor; }
_glNewList                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNewList; }
_glColor3d                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3d; }
_glColor4d                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4d; }
_glColor4f                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4f; }
_glRotatef                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRotatef; }
(^|{ws}*)_PRINTWIDTH{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PRINTWIDTH; }
(^|{ws}*)WHITE{ws}+SPACE{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WHITE_SPACE; }
_glLightiv                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightiv; }
_glColor3b                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3b; }
_glColor4i                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4i; }
_glEndList                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEndList; }
_glLogicOp                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLogicOp; }
_glRotated                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRotated; }
(^|{ws}*)\$CHECKING{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_CHECKING; }
(^|{ws}*)_SNDOPENRAW{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDOPENRAW; }
(^|{ws}*)OPTION{ws}+BASE{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OPTION_BASE; }
(^|{ws}*)PRINT{ws}+USING{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRINT_USING; }
(^|{ws}*)_LASTBUTTON{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__LASTBUTTON; }
_glTexGend                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGend; }
(^|{ws}*)_MOUSEINPUT{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEINPUT; }
(^|{ws}*)_SNDRAWDONE{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDRAWDONE; }
(^|{ws}*)_MOUSEWHEEL{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEWHEEL; }
(^|{ws}*)_OPENCLIENT{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__OPENCLIENT; }
(^|{ws}*)_FILEEXISTS{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FILEEXISTS; }
_glTexEnvf                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexEnvf; }
_glTexEnvi                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexEnvi; }
(^|{ws}*)_FONTHEIGHT{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FONTHEIGHT; }
_glTexGenf                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGenf; }
(^|{ws}*)_SNDPLAYING{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPLAYING; }
_glTexGeni                                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGeni; }
(^|{ws}*)SELECT{ws}+CASE{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SELECT_CASE; }
_glColor3us                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3us; }
_glVertex4d                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4d; }
_glNormal3f                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3f; }
_glColor3ui                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3ui; }
_glGenLists                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGenLists; }
(^|{ws}*)_DEVICEINPUT{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEVICEINPUT; }
_glColor4dv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4dv; }
(^|{ws}*)_STARTDIR\${ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__STARTDIR_DS; }
_glColor4bv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4bv; }
_glColor3ub                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3ub; }
_glColor3sv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3sv; }
_glTexGenfv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGenfv; }
_glColor3bv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3bv; }
_glIndexubv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexubv; }
_glGetError                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetError; }
_glColor3fv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3fv; }
_glVertex4i                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4i; }
_glColor4fv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4fv; }
_glNormal3d                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3d; }
_glColor3iv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3iv; }
_glVertex4s                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4s; }
_glColor4sv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4sv; }
_glNormal3s                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3s; }
(^|{ws}*)BIT{ws}+VARIABLE{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BIT_VARIABLE; }
_glCullFace                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCullFace; }
_glTexEnvfv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexEnvfv; }
_glPushName                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPushName; }
_glVertex2i                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2i; }
(^|{ws}*)_OFFSET{ws}+TYPE{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__OFFSET_TYPE; }
_glEdgeFlag                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEdgeFlag; }
_glNormal3i                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3i; }
_glVertex4f                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4f; }
_glTexEnviv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexEnviv; }
_glColor4ub                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4ub; }
_glNormal3b                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3b; }
_glColor4ui                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4ui; }
_glVertex3s                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3s; }
(^|{ws}*)LPRINT{ws}+USING{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LPRINT_USING; }
(^|{ws}*)NOT{ws}+EQUAL{ws}+TO{ws}*                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NOT_EQUAL_TO; }
_glColor4us                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4us; }
_glColor4iv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4iv; }
_glColor3dv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3dv; }
(^|{ws}*)_COPYPALETTE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COPYPALETTE; }
(^|{ws}*)PUT{ws}+GRAPHICS{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PUT_GRAPHICS; }
_glLoadName                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLoadName; }
_glListBase                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glListBase; }
(^|{ws}*)_RESIZEWIDTH{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RESIZEWIDTH; }
_glVertex2s                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2s; }
(^|{ws}*)_SCREENPRINT{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENPRINT; }
_glVertex3i                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3i; }
_glVertex2f                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2f; }
(^|{ws}*)_SCREENCLICK{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENCLICK; }
_glVertex3f                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3f; }
_glTexGendv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGendv; }
(^|{ws}*)_SCREENIMAGE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENIMAGE; }
_glViewport                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glViewport; }
_glVertex3d                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3d; }
(^|{ws}*)_AUTODISPLAY{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__AUTODISPLAY; }
(^|{ws}*)_MOUSEBUTTON{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEBUTTON; }
(^|{ws}*)_MAPTRIANGLE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MAPTRIANGLE; }
_glVertex2d                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2d; }
_glTexGeniv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexGeniv; }
(^|{ws}*)_SNDPLAYFILE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPLAYFILE; }
(^|{ws}*)_SNDPLAYCOPY{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SNDPLAYCOPY; }
(^|{ws}*)_PRINTSTRING{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PRINTSTRING; }
(^|{ws}*)WRITE{ws}+SCREEN{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_WRITE_SCREEN; }
_glGetMapiv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetMapiv; }
_glGetMapfv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetMapfv; }
(^|{ws}*)_DEPTHBUFFER{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEPTHBUFFER; }
_glGetMapdv                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetMapdv; }
_glCallList                                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCallList; }
_glIsTexture                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIsTexture; }
_glEvalMesh2                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalMesh2; }
_glNormal3bv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3bv; }
_glNormal3iv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3iv; }
_glIndexMask                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexMask; }
_glEvalMesh1                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalMesh1; }
_glVertex3dv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3dv; }
_glPopAttrib                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPopAttrib; }
_glPopMatrix                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPopMatrix; }
_glPointSize                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPointSize; }
_glGetFloatv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetFloatv; }
_glPixelZoom                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelZoom; }
_glNormal3sv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3sv; }
_glLineWidth                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLineWidth; }
_glMapGrid1f                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMapGrid1f; }
_glVertex3fv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3fv; }
_glVertex3iv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3iv; }
_glFrontFace                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFrontFace; }
_glVertex2iv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2iv; }
_glMapGrid1d                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMapGrid1d; }
_glVertex2sv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2sv; }
(^|{ws}*)CALL{ws}+ABSOLUTE{ws}*                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_CALL_ABSOLUTE; }
_glNormal3dv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3dv; }
_glMapGrid2d                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMapGrid2d; }
_glIsEnabled                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIsEnabled; }
_glGetString                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetString; }
_glNormal3fv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormal3fv; }
_glInitNames                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glInitNames; }
_glMateriali                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMateriali; }
_glMapGrid2f                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMapGrid2f; }
_glMaterialf                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMaterialf; }
_glVertex3sv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex3sv; }
_glColor4usv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4usv; }
(^|{ws}*)_DESKTOPWIDTH{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DESKTOPWIDTH; }
_glStencilOp                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glStencilOp; }
_glCallLists                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCallLists; }
_glBlendFunc                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glBlendFunc; }
_glClipPlane                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClipPlane; }
_glVertex4iv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4iv; }
_glColor3uiv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3uiv; }
_glColor3ubv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3ubv; }
(^|{ws}*)_SCREENEXISTS{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENEXISTS; }
_glVertex4dv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4dv; }
(^|{ws}*)PALETTE{ws}+USING{ws}*                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PALETTE_USING; }
(^|{ws}*)_RESIZEHEIGHT{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__RESIZEHEIGHT; }
(^|{ws}*)\$SCREENHIDE{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_SCREENHIDE; }
_glVertex2dv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2dv; }
_glVertex4sv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4sv; }
(^|{ws}*)_DEFAULTCOLOR{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEFAULTCOLOR; }
(^|{ws}*)_CONSOLETITLE{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CONSOLETITLE; }
_glAlphaFunc                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glAlphaFunc; }
(^|{ws}*)PEN{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PEN_STATEMENT; }
_glColor3usv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor3usv; }
(^|{ws}*)_BUTTONCHANGE{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BUTTONCHANGE; }
(^|{ws}*)KEY{ws}*                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_KEY_STATEMENT; }
_glDepthMask                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDepthMask; }
_glDepthFunc                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDepthFunc; }
(^|{ws}*)_COMMANDCOUNT{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__COMMANDCOUNT; }
_glEdgeFlagv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEdgeFlagv; }
(^|{ws}*)BYTE{ws}+VARIABLE{ws}*                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_BYTE_VARIABLE; }
(^|{ws}*)LONG{ws}+VARIABLE{ws}*                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LONG_VARIABLE; }
(^|{ws}*)\$SCREENSHOW{ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_SCREENSHOW; }
_glVertex2fv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex2fv; }
_glColor4uiv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4uiv; }
_glColorMask                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColorMask; }
_glColor4ubv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColor4ubv; }
(^|{ws}*)_DISPLAYORDER{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DISPLAYORDER; }
_glVertex4fv                                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertex4fv; }
_glTexCoord2s                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2s; }
_glTexCoord1s                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1s; }
_glTexCoord3i                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3i; }
_glTexCoord2f                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2f; }
(^|{ws}*)FLOAT{ws}+VARIABLE{ws}*                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_FLOAT_VARIABLE; }
_glTexCoord3f                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3f; }
_glTexCoord2i                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2i; }
_glTexImage2D                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexImage2D; }
_glTranslated                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTranslated; }
_glTexCoord3d                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3d; }
_glTexCoord2d                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2d; }
_glMaterialiv                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMaterialiv; }
_glTexImage1D                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexImage1D; }
_glRenderMode                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRenderMode; }
_glTexCoord4s                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4s; }
_glReadPixels                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glReadPixels; }
_glReadBuffer                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glReadBuffer; }
_glPushAttrib                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPushAttrib; }
_glPushMatrix                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPushMatrix; }
_glPixelMapfv                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelMapfv; }
_glTexCoord4i                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4i; }
_glShadeModel                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glShadeModel; }
_glTranslatef                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTranslatef; }
_glTexCoord4f                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4f; }
_glTexCoord4d                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4d; }
_glTexCoord1i                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1i; }
_glTexCoord1f                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1f; }
_glMatrixMode                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMatrixMode; }
_glTexCoord1d                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1d; }
_glMaterialfv                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMaterialfv; }
_glTexCoord3s                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3s; }
(^|{ws}*)SEEK{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SEEK_STATEMENT; }
_glDepthRange                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDepthRange; }
_glCopyPixels                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCopyPixels; }
(^|{ws}*)NEXT{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_NEXT_STATEMENT; }
(^|{ws}*)LOOP{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LOOP_STATEMENT; }
_glDrawBuffer                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDrawBuffer; }
_glDrawArrays                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDrawArrays; }
_glClearIndex                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClearIndex; }
_glClearDepth                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClearDepth; }
_glGetLightiv                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetLightiv; }
_glClearAccum                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClearAccum; }
(^|{ws}*)PLAY{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PLAY_STATEMENT; }
_glGetDoublev                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetDoublev; }
_glClearColor                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClearColor; }
_glGetLightfv                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetLightfv; }
(^|{ws}*)_MOUSEPIPEOPEN{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEPIPEOPEN; }
(^|{ws}*)_DESKTOPHEIGHT{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DESKTOPHEIGHT; }
_glEvalPoint1                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalPoint1; }
_glDrawPixels                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDrawPixels; }
(^|{ws}*)_MEM{ws}*                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEM_STATEMENT; }
_glEvalPoint2                                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalPoint2; }
_glTexCoord1dv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1dv; }
_glTexCoord2dv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2dv; }
_glTexCoord1sv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1sv; }
_glTexCoord1fv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1fv; }
_glTexCoord1iv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord1iv; }
(^|{ws}*)TIMER{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TIMER_STATEMENT; }
_glDeleteLists                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDeleteLists; }
_glRasterPos3s                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3s; }
_glRasterPos3i                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3i; }
_glRasterPos3f                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3f; }
_glRasterPos3d                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3d; }
_glRasterPos4d                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4d; }
_glRasterPos4f                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4f; }
_glStencilFunc                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glStencilFunc; }
_glTexCoord2fv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2fv; }
_glRasterPos4s                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4s; }
_glRasterPos4i                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4i; }
_glBindTexture                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glBindTexture; }
(^|{ws}*)_MOUSEMOVEMENTY{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEMOVEMENTY; }
(^|{ws}*)_MOUSEMOVEMENTX{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MOUSEMOVEMENTX; }
(^|{ws}*)_OPENCONNECTION{ws}*                     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__OPENCONNECTION; }
(^|{ws}*)DECLARE{ws}+LIBRARY{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DECLARE_LIBRARY; }
(^|{ws}*)LINE{ws}+INPUT{ws}+FILE{ws}*             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LINE_INPUT_FILE; }
(^|{ws}*)INPUT{ws}+FILE{ws}+MODE{ws}*             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INPUT_FILE_MODE; }
(^|{ws}*)_FONT{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FONT_STATEMENT; }
(^|{ws}*)_DEST{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DEST_STATEMENT; }
(^|{ws}*)OFFSET{ws}+VARIABLE{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_OFFSET_VARIABLE; }
(^|{ws}*)DOUBLE{ws}+VARIABLE{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DOUBLE_VARIABLE; }
(^|{ws}*)SINGLE{ws}+VARIABLE{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SINGLE_VARIABLE; }
(^|{ws}*)STRING{ws}+VARIABLE{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STRING_VARIABLE; }
_glTexCoord4sv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4sv; }
(^|{ws}*)MID{ws}+\$STATMENT{ws}*                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MID_DS_STATMENT; }
_glRasterPos2s                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2s; }
_glTexCoord3fv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3fv; }
_glTexCoord3dv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3dv; }
(^|{ws}*)STRIG{ws}*                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STRIG_STATEMENT; }
_glTexCoord2sv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2sv; }
_glTexCoord3iv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3iv; }
(^|{ws}*)RANDOMIZE{ws}+USING{ws}*                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_RANDOMIZE_USING; }
_glTexCoord4iv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4iv; }
_glTexCoord4fv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4fv; }
_glTexCoord4dv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord4dv; }
_glTexCoord3sv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord3sv; }
_glTexCoord2iv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoord2iv; }
_glStencilMask                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glStencilMask; }
_glGetTexImage                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexImage; }
_glGetTexGeniv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexGeniv; }
_glPassThrough                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPassThrough; }
_glLineStipple                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLineStipple; }
_glLoadMatrixf                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLoadMatrixf; }
_glGenTextures                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGenTextures; }
_glEvalCoord1d                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord1d; }
_glEvalCoord2f                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord2f; }
_glEvalCoord2d                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord2d; }
_glPixelMapuiv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelMapuiv; }
_glPixelStoref                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelStoref; }
_glLightModelf                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightModelf; }
_glPixelStorei                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelStorei; }
_glEvalCoord1f                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord1f; }
_glGetTexEnvfv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexEnvfv; }
_glPixelMapusv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelMapusv; }
_glPolygonMode                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPolygonMode; }
_glGetBooleanv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetBooleanv; }
_glLightModeli                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightModeli; }
_glGetTexGenfv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexGenfv; }
_glRasterPos2f                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2f; }
_glMultMatrixd                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMultMatrixd; }
_glGetPointerv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetPointerv; }
_glGetTexGendv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexGendv; }
_glGetTexEnviv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexEnviv; }
_glRasterPos2i                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2i; }
_glLoadMatrixd                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLoadMatrixd; }
_glRasterPos2d                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2d; }
_glGetIntegerv                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetIntegerv; }
_glMultMatrixf                                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glMultMatrixf; }
(^|{ws}*)SCREEN{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_SCREEN_STATEMENT; }
_glEvalCoord2fv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord2fv; }
_glLightModeliv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightModeliv; }
_glRasterPos2sv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2sv; }
_glGetClipPlane                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetClipPlane; }
_glLoadIdentity                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLoadIdentity; }
(^|{ws}*)INTEGER{ws}+VARIABLE{ws}*                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTEGER_VARIABLE; }
_glEvalCoord2dv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord2dv; }
(^|{ws}*)PRINT{ws}+USING{ws}+FILE{ws}*            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_PRINT_USING_FILE; }
_glLightModelfv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glLightModelfv; }
_glRasterPos4fv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4fv; }
_glRasterPos4dv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4dv; }
_glDrawElements                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDrawElements; }
_glRasterPos4iv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4iv; }
_glRasterPos4sv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos4sv; }
_glRasterPos2dv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2dv; }
_glRasterPos3sv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3sv; }
_glRasterPos3dv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3dv; }
_glRasterPos2iv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2iv; }
_glRasterPos3fv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3fv; }
_glRasterPos2fv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos2fv; }
_glRasterPos3iv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glRasterPos3iv; }
(^|{ws}*)_BLEND{ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BLEND_STATEMENT; }
(^|{ws}*)_BACKGROUNDCOLOR{ws}*                    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__BACKGROUNDCOLOR; }
_glColorPointer                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColorPointer; }
_glSelectBuffer                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glSelectBuffer; }
_glClearStencil                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glClearStencil; }
_glArrayElement                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glArrayElement; }
_glEvalCoord1dv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord1dv; }
_glEvalCoord1fv                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEvalCoord1fv; }
_glIndexPointer                                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glIndexPointer; }
_glVertexPointer                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glVertexPointer; }
_glTexParameterf                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexParameterf; }
(^|{ws}*)_MEMGET{ws}*                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MEMGET_STATEMENT; }
_glTexSubImage2D                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexSubImage2D; }
_glTexSubImage1D                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexSubImage1D; }
_glTexParameteri                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexParameteri; }
(^|{ws}*)DATE\${ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DATE_DS_STATEMENT; }
_glNormalPointer                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glNormalPointer; }
_glGetMaterialiv                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetMaterialiv; }
_glPolygonOffset                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPolygonOffset; }
_glGetMaterialfv                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetMaterialfv; }
_glColorMaterial                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glColorMaterial; }
(^|{ws}*)TIME\${ws}*                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_TIME_DS_STATEMENT; }
_glGetPixelMapfv                                  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetPixelMapfv; }
(^|{ws}*)UNSIGNED{ws}+VARIABLE{ws}*               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_VARIABLE; }
(^|{ws}*)UNKNOWN{ws}+CHARACTER{ws}*               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNKNOWN_CHARACTER; }
(^|{ws}*)STANDARD{ws}+VARIABLE{ws}*               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_STANDARD_VARIABLE; }
(^|{ws}*)_DISPLAY{ws}*                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__DISPLAY_STATEMENT; }
_glPolygonStipple                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPolygonStipple; }
_glCopyTexImage2D                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCopyTexImage2D; }
_glDeleteTextures                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDeleteTextures; }
(^|{ws}*)_MIDDLE{ws}+SCREENMOVE{ws}*              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MIDDLE_SCREENMOVE; }
_glCopyTexImage1D                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCopyTexImage1D; }
_glPixelTransferi                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelTransferi; }
_glGetPixelMapuiv                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetPixelMapuiv; }
(^|{ws}*)\$VIRTUALKEYBOARD{ws}*                   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DS_VIRTUALKEYBOARD; }
_glGetPixelMapusv                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetPixelMapusv; }
(^|{ws}*)INTEGER64{ws}+VARIABLE{ws}*              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INTEGER64_VARIABLE; }
_glFeedbackBuffer                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glFeedbackBuffer; }
_glTexParameterfv                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexParameterfv; }
_glPixelTransferf                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPixelTransferf; }
_glTexParameteriv                                 {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexParameteriv; }
_glEdgeFlagPointer                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEdgeFlagPointer; }
_glPopClientAttrib                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPopClientAttrib; }
_glTexCoordPointer                                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glTexCoordPointer; }
(^|{ws}*)INPUT{ws}+FILE{ws}*                      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_INPUT_FILE_STATEMENT; }
(^|{ws}*)_PRINTMODE{ws}*                          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PRINTMODE_STATEMENT; }
_glPushClientAttrib                               {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPushClientAttrib; }
(^|{ws}*)_SCREENICON{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__SCREENICON_STATEMENT; }
_glInterleavedArrays                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glInterleavedArrays; }
(^|{ws}*)_CONNECTIONADDRESS\${ws}*                {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CONNECTIONADDRESS_DS; }
(^|{ws}*)UNSIGNED{ws}+BIT{ws}+VARIABLE{ws}*       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_BIT_VARIABLE; }
_glGetPolygonStipple                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetPolygonStipple; }
_glCopyTexSubImage2D                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCopyTexSubImage2D; }
(^|{ws}*)_FULLSCREEN{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__FULLSCREEN_STATEMENT; }
(^|{ws}*)_CLEARCOLOR{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CLEARCOLOR_STATEMENT; }
_glGetTexParameterfv                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexParameterfv; }
(^|{ws}*)_MAPUNICODE{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__MAPUNICODE_STATEMENT; }
(^|{ws}*)LESS{ws}+THAN{ws}+OR{ws}+EQUAL{ws}+TO{ws}*          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }
_glGetTexParameteriv                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexParameteriv; }
_glCopyTexSubImage1D                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glCopyTexSubImage1D; }
_glEnableClientState                              {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glEnableClientState; }
(^|{ws}*)_CONTROLCHR{ws}*                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CONTROLCHR_STATEMENT; }
(^|{ws}*)UNSIGNED{ws}+LONG{ws}+VARIABLE{ws}*      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_LONG_VARIABLE; }
(^|{ws}*)UNSIGNED{ws}+BYTE{ws}+VARIABLE{ws}*      {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }
_glPrioritizeTextures                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glPrioritizeTextures; }
_glDisableClientState                             {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glDisableClientState; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+END{ws}*  {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MULTI_LINE_COMMENT_END; }
(^|{ws}*)DECLARE{ws}+DYNAMIC{ws}+LIBRARY{ws}*     {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_DECLARE_DYNAMIC_LIBRARY; }
(^|{ws}*)_CLIPBOARD\${ws}*                        {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__CLIPBOARD_DS_STATEMENT; }
_glAreTexturesResident                            {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glAreTexturesResident; }
(^|{ws}*)_PALETTECOLOR{ws}*                       {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB__PALETTECOLOR_STATEMENT; }
(^|{ws}*)GREATER{ws}+THAN{ws}+OR{ws}+EQUAL{ws}+TO{ws}*          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+BEGIN{ws}*          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MULTI_LINE_COMMENT_BEGIN; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+ERROR{ws}*          {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_MULTI_LINE_COMMENT_ERROR; }
(^|{ws}*)UNSIGNED{ws}+OFFSET{ws}+VARIABLE{ws}*    {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }
(^|{ws}*)UNSIGNED{ws}+INTEGER{ws}+VARIABLE{ws}*   {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }
_glGetTexLevelParameterfv                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexLevelParameterfv; }
_glGetTexLevelParameteriv                         {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_OGL__glGetTexLevelParameteriv; }
(^|{ws}*)UNSIGNED{ws}+INTEGER64{ws}+VARIABLE{ws}* {	nchar += yyleng; strcpy(yylval,yytext); return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }

	/*	END LEX	*/
	/*	+++++	DO NOT REMOVE THE PREVIOUS LINE!!!	+++++	*/

{nl}		{	nline++; nchar++; return ENUM_QB_NEW_LINE; }
{ws}		{	ws++; return ENUM_QB_WHITE_SPACE; }
.			{	nchar++; return ENUM_QB_UNKNOWN_CHARACTER; }


%%
	/*	Routines	*/

/*
	Main Program
*/
int main( void )
{
	int tok,i,curlen;

	while( tok = yylex() ){
		while( (yylval[0] < 32) && (strlen(yylval) > 0) ){ strcpy( yylval, yylval+1 ); }
		curlen = strlen(yylval);
		while( (curlen > 0) && (yylval[curlen] < 32) ){ yylval[curlen] = 0; curlen--; }
		printf( "--->RETURNED : %d => %s\n", tok, yylval );
		for( i=0; i<65536; i++ ){ yylval[i] = 0; }
		}

	printf( "\n\nCharacters : %d\nWords : %d\nLines : %d\nWhite Space : %d\n", nchar, nword, yylineno, ws );
	return 0;
}


