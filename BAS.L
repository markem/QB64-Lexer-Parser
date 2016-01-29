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
rem				([rR][eE][mM]|['])

%option noyywrap nodefault yylineno case-insensitive

%x INCL

	/*	Symbol Table	*/
	/*	This is taken directly from the Flex/Bison manual from O'Reilly	*/

%{
	/*	Defines	*/

#define MAX_INCLUDE_DEPTH 1000
#define NHASH 9997

#include	<stdio.h>
#include	<stdlib.h>
#include	"y.tab.h"

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

int	include_stack_ptr = 0;

YY_BUFFER_STATE	include_stack[ 1000 ];

	/*	include file stack	*/

void	yyerror( char * );

/*	Enumeration setup	*/
/*	BEGINNING OF THE ASCII CHARACTER TABLE	*/
enum {
	ENUM_NULL = 0,
	ENUM_CONTROL_A,
	ENUM_CONTROL_B,
	ENUM_CONTROL_C,
	ENUM_CONTROL_D,
	ENUM_CONTROL_E,
	ENUM_CONTROL_F,
	ENUM_CONTROL_G,
	ENUM_CONTROL_H,
	ENUM_CONTROL_I,
	ENUM_CONTROL_J,
	ENUM_CONTROL_K,
	ENUM_CONTROL_L,
	ENUM_CONTROL_M,
	ENUM_CONTROL_N,
	ENUM_CONTROL_O,
	ENUM_CONTROL_P,
	ENUM_CONTROL_Q,
	ENUM_CONTROL_R,
	ENUM_CONTROL_S,
	ENUM_CONTROL_T,
	ENUM_CONTROL_U,
	ENUM_CONTROL_V,
	ENUM_CONTROL_W,
	ENUM_CONTROL_X,
	ENUM_CONTROL_Y,
	ENUM_CONTROL_Z,
	ENUM_ESCAPE,
	ENUM_FILE_SEPARATOR,
	ENUM_GROUP_SEPARATOR,
	ENUM_RECORD_SEPARATOR,
	ENUM_UNIT_SEPARATOR,
	ENUM_SPACE,
	ENUM_EXCLAMATION_POINT,
	ENUM_DOUBLE_QUOTE,
	ENUM_POUND_SIGN,
	ENUM_DOLLAR_SIGN,
	ENUM_PERCENT_SIGN,
	ENUM_AMPERSAND,
	ENUM_SINGLE_QUOTE,
	ENUM_PAREN_OPEN,
	ENUM_PAREN_CLOSED,
	ENUM_ASTERIK,
	ENUM_PLUS_SIGN,
	ENUM_COMMA,
	ENUM_MINUS_SIGN,
	ENUM_PERIOD,
	ENUM_SLASH_FORWARDS,
	ENUM_ZERO,
	ENUM_ONE,
	ENUM_TWO,
	ENUM_THREE,
	ENUM_FOUR,
	ENUM_FIVE,
	ENUM_SIX,
	ENUM_SEVEN,
	ENUM_EIGHT,
	ENUM_NINE,
	ENUM_COLON,
	ENUM_SEMICOLON,
	ENUM_LESS_THAN,
	ENUM_EQUAL,
	ENUM_GREATER_THAN,
	ENUM_QUESTION_MARK,
	ENUM_AT_SIGN,
	ENUM_UPPERCASE_A,
	ENUM_UPPERCASE_B,
	ENUM_UPPERCASE_C,
	ENUM_UPPERCASE_D,
	ENUM_UPPERCASE_E,
	ENUM_UPPERCASE_F,
	ENUM_UPPERCASE_G,
	ENUM_UPPERCASE_H,
	ENUM_UPPERCASE_I,
	ENUM_UPPERCASE_J,
	ENUM_UPPERCASE_K,
	ENUM_UPPERCASE_L,
	ENUM_UPPERCASE_M,
	ENUM_UPPERCASE_N,
	ENUM_UPPERCASE_O,
	ENUM_UPPERCASE_P,
	ENUM_UPPERCASE_Q,
	ENUM_UPPERCASE_R,
	ENUM_UPPERCASE_S,
	ENUM_UPPERCASE_T,
	ENUM_UPPERCASE_U,
	ENUM_UPPERCASE_V,
	ENUM_UPPERCASE_W,
	ENUM_UPPERCASE_X,
	ENUM_UPPERCASE_Y,
	ENUM_UPPERCASE_Z,
	ENUM_BRACKET_OPEN,
	ENUM_SLASH_BACK,
	ENUM_BRACKET_CLOSE,
	ENUM_CARET,
	ENUM_UNDERSCORE,
	ENUM_BACK_TICK,
	ENUM_LOWERCASE_A,
	ENUM_LOWERCASE_B,
	ENUM_LOWERCASE_C,
	ENUM_LOWERCASE_D,
	ENUM_LOWERCASE_E,
	ENUM_LOWERCASE_F,
	ENUM_LOWERCASE_G,
	ENUM_LOWERCASE_H,
	ENUM_LOWERCASE_I,
	ENUM_LOWERCASE_J,
	ENUM_LOWERCASE_K,
	ENUM_LOWERCASE_L,
	ENUM_LOWERCASE_M,
	ENUM_LOWERCASE_N,
	ENUM_LOWERCASE_O,
	ENUM_LOWERCASE_P,
	ENUM_LOWERCASE_Q,
	ENUM_LOWERCASE_R,
	ENUM_LOWERCASE_S,
	ENUM_LOWERCASE_T,
	ENUM_LOWERCASE_U,
	ENUM_LOWERCASE_V,
	ENUM_LOWERCASE_W,
	ENUM_LOWERCASE_X,
	ENUM_LOWERCASE_Y,
	ENUM_LOWERCASE_Z,
	ENUM_BRACE_OPEN,
	ENUM_OR_BAR,
	ENUM_BRACE_CLOSE,
	ENUM_TILDE,
	ENUM_DELETE,
/*	End of standard ASCII table - Extended table to follow	*/
	ENUM_SYMBOL_128,
	ENUM_SYMBOL_129,
	ENUM_SYMBOL_130,
	ENUM_SYMBOL_131,
	ENUM_SYMBOL_132,
	ENUM_SYMBOL_133,
	ENUM_SYMBOL_134,
	ENUM_SYMBOL_135,
	ENUM_SYMBOL_136,
	ENUM_SYMBOL_137,
	ENUM_SYMBOL_138,
	ENUM_SYMBOL_139,
	ENUM_SYMBOL_140,
	ENUM_SYMBOL_141,
	ENUM_SYMBOL_142,
	ENUM_SYMBOL_143,
	ENUM_SYMBOL_144,
	ENUM_SYMBOL_145,
	ENUM_SYMBOL_146,
	ENUM_SYMBOL_147,
	ENUM_SYMBOL_148,
	ENUM_SYMBOL_149,
	ENUM_SYMBOL_150,
	ENUM_SYMBOL_151,
	ENUM_SYMBOL_152,
	ENUM_SYMBOL_153,
	ENUM_SYMBOL_154,
	ENUM_SYMBOL_155,
	ENUM_SYMBOL_156,
	ENUM_SYMBOL_157,
	ENUM_SYMBOL_158,
	ENUM_SYMBOL_159,
	ENUM_SYMBOL_160,
	ENUM_SYMBOL_161,
	ENUM_SYMBOL_162,
	ENUM_SYMBOL_163,
	ENUM_SYMBOL_164,
	ENUM_SYMBOL_165,
	ENUM_SYMBOL_166,
	ENUM_SYMBOL_167,
	ENUM_SYMBOL_168,
	ENUM_SYMBOL_169,
	ENUM_SYMBOL_170,
	ENUM_SYMBOL_171,
	ENUM_SYMBOL_172,
	ENUM_SYMBOL_173,
	ENUM_SYMBOL_174,
	ENUM_SYMBOL_175,
	ENUM_SYMBOL_176,
	ENUM_SYMBOL_177,
	ENUM_SYMBOL_178,
	ENUM_SYMBOL_179,
	ENUM_SYMBOL_180,
	ENUM_SYMBOL_181,
	ENUM_SYMBOL_182,
	ENUM_SYMBOL_183,
	ENUM_SYMBOL_184,
	ENUM_SYMBOL_185,
	ENUM_SYMBOL_186,
	ENUM_SYMBOL_187,
	ENUM_SYMBOL_188,
	ENUM_SYMBOL_189,
	ENUM_SYMBOL_190,
	ENUM_SYMBOL_191,
	ENUM_SYMBOL_192,
	ENUM_SYMBOL_193,
	ENUM_SYMBOL_194,
	ENUM_SYMBOL_195,
	ENUM_SYMBOL_196,
	ENUM_SYMBOL_197,
	ENUM_SYMBOL_198,
	ENUM_SYMBOL_199,
	ENUM_SYMBOL_200,
	ENUM_SYMBOL_201,
	ENUM_SYMBOL_202,
	ENUM_SYMBOL_203,
	ENUM_SYMBOL_204,
	ENUM_SYMBOL_205,
	ENUM_SYMBOL_206,
	ENUM_SYMBOL_207,
	ENUM_SYMBOL_208,
	ENUM_SYMBOL_209,
	ENUM_SYMBOL_210,
	ENUM_SYMBOL_211,
	ENUM_SYMBOL_212,
	ENUM_SYMBOL_213,
	ENUM_SYMBOL_214,
	ENUM_SYMBOL_215,
	ENUM_SYMBOL_216,
	ENUM_SYMBOL_217,
	ENUM_SYMBOL_218,
	ENUM_SYMBOL_219,
	ENUM_SYMBOL_220,
	ENUM_SYMBOL_221,
	ENUM_SYMBOL_222,
	ENUM_SYMBOL_223,
	ENUM_SYMBOL_224,
	ENUM_SYMBOL_225,
	ENUM_SYMBOL_226,
	ENUM_SYMBOL_227,
	ENUM_SYMBOL_228,
	ENUM_SYMBOL_229,
	ENUM_SYMBOL_230,
	ENUM_SYMBOL_231,
	ENUM_SYMBOL_232,
	ENUM_SYMBOL_233,
	ENUM_SYMBOL_234,
	ENUM_SYMBOL_235,
	ENUM_SYMBOL_236,
	ENUM_SYMBOL_237,
	ENUM_SYMBOL_238,
	ENUM_SYMBOL_239,
	ENUM_SYMBOL_240,
	ENUM_SYMBOL_241,
	ENUM_SYMBOL_242,
	ENUM_SYMBOL_243,
	ENUM_SYMBOL_244,
	ENUM_SYMBOL_245,
	ENUM_SYMBOL_246,
	ENUM_SYMBOL_247,
	ENUM_SYMBOL_248,
	ENUM_SYMBOL_249,
	ENUM_SYMBOL_250,
	ENUM_SYMBOL_251,
	ENUM_SYMBOL_252,
	ENUM_SYMBOL_253,
	ENUM_SYMBOL_254,
	ENUM_SYMBOL_255,
/*
	END OF ASCII CHARACTER TABLE
	BEGINNING OF QUICKBASIC 64 COMMAND TABLE	-	DS = Dollar Sign ($)
	BEGIN : QB64 specific keywords
*/
	ENUM_QB__ACOS,
	ENUM_QB__ACOSH,
	ENUM_QB__ALPHA,
	ENUM_QB__ALPHA32,
	ENUM_QB__ARCCOT,
	ENUM_QB__ARCSC,
	ENUM_QB__ARCSEC,
	ENUM_QB__ASIN,
	ENUM_QB__ASINH,
	ENUM_QB__ATAN2,
	ENUM_QB__ATANH,
	ENUM_QB__AUTODISPLAY,
	ENUM_QB__AXIS,
	ENUM_QB__BACKGROUNDCOLOR,
	ENUM_QB__BIT,
	ENUM_QB__BLEND_STATEMENT,
	ENUM_QB__BLEND_FUNCTION,
	ENUM_QB__BLUE,
	ENUM_QB__BLUE32,
	ENUM_QB__BUTTON,
	ENUM_QB__BUTTONCHANGE,
	ENUM_QB__BYTE,
	ENUM_QB_DS_CHECKING,
	ENUM_QB__CEIL,
	ENUM_QB__CLEARCOLOR_STATEMENT,
	ENUM_QB__CLEARCOLOR_FUNCTION,
	ENUM_QB__CLIP,
	ENUM_QB__CLIPBOARD_DS_STATEMENT,
	ENUM_QB__CLIPBOARD_DS_FUNCTION,
	ENUM_QB__COMMANDCOUNT,
	ENUM_QB__CONNECTED,
	ENUM_QB__CONNECTIONADDRESS_DS,
	ENUM_QB_DS_CONSOLE,
	ENUM_QB__CONSOLE,
	ENUM_QB__CONSOLETITLE,
	ENUM_QB__CONTROLCHR_STATEMENT,
	ENUM_QB__CONTROLCHR_FUNCTION,
	ENUM_QB__COPYIMAGE,
	ENUM_QB__COPYPALETTE,
	ENUM_QB__COT,
	ENUM_QB__COTH,
	ENUM_QB__COSH,
	ENUM_QB__CSC,
	ENUM_QB__CSCH,
	ENUM_QB__CV,
	ENUM_QB__CWD_DS,
	ENUM_QB__D2G,
	ENUM_QB__D2R,
	ENUM_QB__DEFAULTCOLOR,
	ENUM_QB__DEFINE,
	ENUM_QB__DELAY,
	ENUM_QB__DEPTHBUFFER,
	ENUM_QB__DESKTOPHEIGHT,
	ENUM_QB__DESKTOPWIDTH,
	ENUM_QB__DEST_STATEMENT,
	ENUM_QB__DEST_FUNCTION,
	ENUM_QB__DEVICE_DS,
	ENUM_QB__DEVICEINPUT,
	ENUM_QB__DEVICES,
	ENUM_QB__DIREXISTS,
	ENUM_QB__DISPLAY_STATEMENT,
	ENUM_QB__DISPLAY_FUNCTION,
	ENUM_QB__DISPLAYORDER,
	ENUM_QB__DONTBLEND,
	ENUM_QB__DONTWAIT,
	ENUM_QB_DS_ELSE,
	ENUM_QB_DS_ELSEIF,
	ENUM_QB_DS_ELSE_IF,
	ENUM_QB_DS_END,
	ENUM_QB__ERRORLINE,
	ENUM_QB__EXIT,
	ENUM_QB__FILEEXISTS,
	ENUM_QB__FLOAT,
	ENUM_QB__FONT_STATEMENT,
	ENUM_QB__FONT_FUNCTION,
	ENUM_QB__FONTHEIGHT,
	ENUM_QB__FONTWIDTH,
	ENUM_QB__FREEFONT,
	ENUM_QB__FREEIMAGE,
	ENUM_QB__FREETIMER,
	ENUM_QB__FULLSCREEN_STATEMENT,
	ENUM_QB__FULLSCREEN_FUNCTION,
	ENUM_QB__G2D,
	ENUM_QB__G2R,
	ENUM_QB__GREEN,
	ENUM_QB__GREEN32,
	ENUM_QB__HEIGHT,
	ENUM_QB__HIDE,
	ENUM_QB__HYPOT,
	ENUM_QB_DS_IF,
	ENUM_QB__ICON,
	ENUM_QB__INTEGER64,
	ENUM_QB__KEYCLEAR,
	ENUM_QB__KEYHIT,
	ENUM_QB__KEYDOWN,
	ENUM_QB_DS_LET,
	ENUM_QB__LASTAXIS,
	ENUM_QB__LASTBUTTON,
	ENUM_QB__LASTWHEEL,
	ENUM_QB__LIMIT,
	ENUM_QB__LOADFONT,
	ENUM_QB__LOADIMAGE,
	ENUM_QB__MAPTRIANGLE,
	ENUM_QB__MAPUNICODE_STATEMENT,
	ENUM_QB__MAPUNICODE_FUNCTION,
	ENUM_QB__MEM_STATEMENT,
	ENUM_QB__MEM_FUNCTION,
	ENUM_QB__MEMCOPY,
	ENUM_QB__MEMELEMENT,
	ENUM_QB__MEMEXISTS,
	ENUM_QB__MEMFILL,
	ENUM_QB__MEMFREE,
	ENUM_QB__MEMGET_STATEMENT,
	ENUM_QB__MEMGET_FUNCTION,
	ENUM_QB__MEMIMAGE,
	ENUM_QB__MEMNEW,
	ENUM_QB__MEMPUT,
	ENUM_QB__MIDDLE_SCREENMOVE,
	ENUM_QB__MK_DS,
	ENUM_QB__MOUSEBUTTON,
	ENUM_QB__MOUSEHIDE,
	ENUM_QB__MOUSEINPUT,
	ENUM_QB__MOUSEMOVE,
	ENUM_QB__MOUSEMOVEMENTX,
	ENUM_QB__MOUSEMOVEMENTY,
	ENUM_QB__MOUSEPIPEOPEN,
	ENUM_QB__MOUSESHOW,
	ENUM_QB__MOUSEWHEEL,
	ENUM_QB__MOUSEX,
	ENUM_QB__MOUSEY,
	ENUM_QB__NEWIMAGE,
	ENUM_QB__OFFSET_FUNCTION,
	ENUM_QB__OFFSET_TYPE,
	ENUM_QB__OPENCLIENT,
	ENUM_QB__OPENCONNECTION,
	ENUM_QB__OPENHOST,
	ENUM_QB__OS_DS,
	ENUM_QB__PALETTECOLOR_STATEMENT,
	ENUM_QB__PALETTECOLOR_FUNCTION,
	ENUM_QB__PIXELSIZE,
	ENUM_QB__PRESERVE,
	ENUM_QB__PRINTIMAGE,
	ENUM_QB__PRINTMODE_STATEMENT,
	ENUM_QB__PRINTMODE_FUNCTION,
	ENUM_QB__PRINTSTRING,
	ENUM_QB__PRINTWIDTH,
	ENUM_QB__PUTIMAGE,
	ENUM_QB__R2D,
	ENUM_QB__R2G,
	ENUM_QB__RED,
	ENUM_QB__RED32,
	ENUM_QB_DS_RESIZE,
	ENUM_QB__RESIZE,
	ENUM_QB__RESIZEHEIGHT,
	ENUM_QB__RESIZEWIDTH,
	ENUM_QB__RGB,
	ENUM_QB__RGB32,
	ENUM_QB__RGBA,
	ENUM_QB__RGBA32,
	ENUM_QB__ROUND,
	ENUM_QB__SEC,
	ENUM_QB__SECH,
	ENUM_QB__SCREENCLICK,
	ENUM_QB__SCREENEXISTS,
	ENUM_QB_DS_SCREENHIDE,
	ENUM_QB__SCREENHIDE,
	ENUM_QB__SCREENICON_STATEMENT,
	ENUM_QB__SCREENICON_FUNCTION,
	ENUM_QB__SCREENIMAGE,
	ENUM_QB__SCREENMOVE,
	ENUM_QB__SCREENPRINT,
	ENUM_QB_DS_SCREENSHOW,
	ENUM_QB__SCREENSHOW,
	ENUM_QB__SCREENX,
	ENUM_QB__SCREENY,
	ENUM_QB__SETALPHA,
	ENUM_QB__SHELLHIDE,
	ENUM_QB__SINH,
	ENUM_QB__SNDBAL,
	ENUM_QB__SNDCLOSE,
	ENUM_QB__SNDCOPY,
	ENUM_QB__SNDGETPOS,
	ENUM_QB__SNDLEN,
	ENUM_QB__SNDLIMIT,
	ENUM_QB__SNDLOOP,
	ENUM_QB__SNDOPEN,
	ENUM_QB__SNDOPENRAW,
	ENUM_QB__SNDPAUSE,
	ENUM_QB__SNDPAUSED,
	ENUM_QB__SNDPLAY,
	ENUM_QB__SNDPLAYCOPY,
	ENUM_QB__SNDPLAYFILE,
	ENUM_QB__SNDPLAYING,
	ENUM_QB__SNDRATE,
	ENUM_QB__SNDRAW,
	ENUM_QB__SNDRAWDONE,
	ENUM_QB__SNDRAWLEN,
	ENUM_QB__SNDSETPOS,
	ENUM_QB__SNDSTOP,
	ENUM_QB__SNDVOL,
	ENUM_QB__SOURCE,
	ENUM_QB__STARTDIR_DS,
	ENUM_QB__STRCMP,
	ENUM_QB__STRICMP,
	ENUM_QB__TANH,
	ENUM_QB__TITLE,
	ENUM_QB__UNSIGNED,
	ENUM_QB_DS_VIRTUALKEYBOARD,
	ENUM_QB__WHEEL,
	ENUM_QB__WIDTH,
/*
	END : QB64 specific keywords
	BEGIN : ORIGINAL QBASIC KEYWORDS
*/
	ENUM_QB_ABS,
	ENUM_QB_ABSOLUTE,
	ENUM_QB_ACCESS,
	ENUM_QB_ALIAS,
	ENUM_QB_AND,
	ENUM_QB_ANY,
	ENUM_QB_APPEND,
	ENUM_QB_AS,
	ENUM_QB_ASC,
	ENUM_QB_ATN,
	ENUM_QB_BEEP,
	ENUM_QB_BINARY,
	ENUM_QB_OCTAL,
	ENUM_QB_HEXADECIMAL,
	ENUM_QB_BLOAD,
	ENUM_QB_BSAVE,
	ENUM_QB_BYVAL,
	ENUM_QB_CALL,
	ENUM_QB_CALL_ABSOLUTE,
	ENUM_QB_CALLS,
	ENUM_QB_CASE,
	ENUM_QB_CASE_ELSE,
	ENUM_QB_CASE_IS,
	ENUM_QB_CDBL,
	ENUM_QB_CDECL,
	ENUM_QB_CHAIN,
	ENUM_QB_CHDIR,
	ENUM_QB_CHR_DS,
	ENUM_QB_CINT,
	ENUM_QB_CIRCLE,
	ENUM_QB_CLEAR,
	ENUM_QB_CLNG,
	ENUM_QB_CLOSE,
	ENUM_QB_CLS,
	ENUM_QB_COLOR,
	ENUM_QB_COMMAND_DS,
	ENUM_QB_COMMON,
	ENUM_QB_CONST,
	ENUM_QB_COS,
	ENUM_QB_CSNG,
	ENUM_QB_CSRLIN,
	ENUM_QB_CVD,
	ENUM_QB_CVDMBF,
	ENUM_QB_CVI,
	ENUM_QB_CVL,
	ENUM_QB_CVS,
	ENUM_QB_CVSMBF,
	ENUM_QB_DATA,
	ENUM_QB_DATE_DS_STATEMENT,
	ENUM_QB_DATE_DS_FUNCTION,
	ENUM_QB_DECLARE,
	ENUM_QB_DECLARE_C_FUNCTION,
	ENUM_QB_DECLARE_LIBRARY,
	ENUM_QB_DECLARE_DYNAMIC_LIBRARY,
	ENUM_QB_DEF_FN,
	ENUM_QB_DEF_SEG,
	ENUM_QB_DEFDBL,
	ENUM_QB_DEFINT,
	ENUM_QB_DEFLNG,
	ENUM_QB_DEFSNG,
	ENUM_QB_DEFSTR,
	ENUM_QB_DIM,
	ENUM_QB_DIR_DS,
	ENUM_QB_DO,
	ENUM_QB_LOOP_STATEMENT,
	ENUM_QB_DOUBLE,
	ENUM_QB_DRAW,
	ENUM_QB_DS_DYNAMIC,
	ENUM_QB_ELSE,
	ENUM_QB_ELSEIF,
	ENUM_QB_END,
	ENUM_QB_END_IF,
	ENUM_QB_END_TYPE,
	ENUM_QB_ENVIRON,
	ENUM_QB_ENVIRON_DS,
	ENUM_QB_EOF,
	ENUM_QB_EQV,
	ENUM_QB_ERASE,
	ENUM_QB_ERDEV,
	ENUM_QB_ERDEV_DS,
	ENUM_QB_ERL,
	ENUM_QB_ERR,
	ENUM_QB_ERROR,
	ENUM_QB_EXIT,
	ENUM_QB_EXP,
	ENUM_QB_FIELD,
	ENUM_QB_FILEATTR,
	ENUM_QB_FILES,
	ENUM_QB_FIX,
	ENUM_QB_FOR,
	ENUM_QB_NEXT_STATEMENT,
	ENUM_QB_FOR_FILE,
	ENUM_QB_FRE,
	ENUM_QB_FREE,
	ENUM_QB_FREEFILE,
	ENUM_QB_FUNCTION,
	ENUM_QB_GET_FILE,
	ENUM_QB_GET_QB64,
	ENUM_QB_GET,
	ENUM_QB_GOSUB,
	ENUM_QB_GOTO,
	ENUM_QB_HEX_DS,
	ENUM_QB_IF,
	ENUM_QB_IMP,
	ENUM_QB_DS_INCLUDE,
	ENUM_QB_INKEY_DS,
	ENUM_QB_INP,
	ENUM_QB_INPUT,
	ENUM_QB_INPUT_FILE_MODE,
	ENUM_QB_INPUT_FILE_STATEMENT,
	ENUM_QB_INPUT_QB64,
	ENUM_QB_INPUT_DS,
	ENUM_QB_INSTR,
	ENUM_QB_INT,
	ENUM_QB_INTEGER,
	ENUM_QB_INTERRUPT,
	ENUM_QB_INTERRUPTX,
	ENUM_QB_IOCTL,
	ENUM_QB_IOCTL_DS,
	ENUM_QB_KEY_STATEMENT,
	ENUM_QB_KEY_FUNCTION,
	ENUM_QB_KEY_LIST,
	ENUM_QB_KILL,
	ENUM_QB_LBOUND,
	ENUM_QB_LCASE_DS,
	ENUM_QB_LEFT_DS,
	ENUM_QB_LEN,
	ENUM_QB_LET,
	ENUM_QB_LINE,
	ENUM_QB_LINE_INPUT,
	ENUM_QB_LINE_INPUT_FILE,
	ENUM_QB_LIST,
	ENUM_QB_LOC,
	ENUM_QB_LOCATE,
	ENUM_QB_LOCK,
	ENUM_QB_LOF,
	ENUM_QB_LOG,
	ENUM_QB_LONG,
	ENUM_QB_LOOP_FUNCTION,
	ENUM_QB_LPOS,
	ENUM_QB_LPRINT,
	ENUM_QB_LPRINT_USING,
	ENUM_QB_LSET,
	ENUM_QB_LTRIM_DS,
	ENUM_QB_MID_DS_STATMENT,
	ENUM_QB_MID_DS_FUNCTION,
	ENUM_QB_MKD_DS,
	ENUM_QB_MKDIR,
	ENUM_QB_MKDMBF_DS,
	ENUM_QB_MKI_DS,
	ENUM_QB_MKL_DS,
	ENUM_QB_MKS_DS,
	ENUM_QB_MKSMBF_DS,
	ENUM_QB_MOD,
	ENUM_QB_NAME,
	ENUM_QB_NEXT_FUNCTION,
	ENUM_QB_NOT,
	ENUM_QB_OCT_DS,
	ENUM_QB_OFF,
	ENUM_QB_ON_COM,
	ENUM_QB_ON_ERROR,
	ENUM_QB_ON_KEY,
	ENUM_QB_ON_PEN,
	ENUM_QB_ON_PLAY,
	ENUM_QB_ON_STRIG,
	ENUM_QB_ON_TIMER,
	ENUM_QB_ON_UEVENT,
	ENUM_QB_ON_GOSUB,
	ENUM_QB_ON_GOTO,
	ENUM_QB_OPEN,
	ENUM_QB_OPEN_COM,
	ENUM_QB_OPTION_BASE,
	ENUM_QB_OR,
	ENUM_QB_OUT,
	ENUM_QB_OUTPUT,
	ENUM_QB_PAINT,
	ENUM_QB_PALETTE,
	ENUM_QB_PALETTE_USING,
	ENUM_QB_PCOPY,
	ENUM_QB_PEEK,
	ENUM_QB_PEN_STATEMENT,
	ENUM_QB_PEN_FUNCTION,
	ENUM_QB_PLAY_STATEMENT,
	ENUM_QB_PLAY_FUNCTION,
	ENUM_QB_PMAP,
	ENUM_QB_POINT,
	ENUM_QB_POKE,
	ENUM_QB_POS,
	ENUM_QB_PRESET,
	ENUM_QB_PRINT,
	ENUM_QB_PRINT_FILE,
	ENUM_QB_PRINT_QB64,
	ENUM_QB_PRINT_USING,
	ENUM_QB_PRINT_USING_FILE,
	ENUM_QB_PSET,
	ENUM_QB_PUT_FILE,
	ENUM_QB_PUT_QB64,
	ENUM_QB_PUT_GRAPHICS,
	ENUM_QB_RANDOM,
	ENUM_QB_RANDOMIZE,
	ENUM_QB_RANDOMIZE_USING,
	ENUM_QB_READ,
	ENUM_QB_REDIM,
	ENUM_QB_REM,
	ENUM_QB_RESET,
	ENUM_QB_RESTORE,
	ENUM_QB_RESUME,
	ENUM_QB_RETURN,
	ENUM_QB_RIGHT_DS,
	ENUM_QB_RMDIR,
	ENUM_QB_RND,
	ENUM_QB_RSET,
	ENUM_QB_RTRIM_DS,
	ENUM_QB_RUN,
	ENUM_QB_SADD,
	ENUM_QB_SCREEN_STATEMENT,
	ENUM_QB_SCREEN_FUNCTION,
	ENUM_QB_SEEK_STATEMENT,
	ENUM_QB_SEEK_FUNCTION,
	ENUM_QB_SELECT_CASE,
	ENUM_QB_SETMEM,
	ENUM_QB_SGN,
	ENUM_QB_SHARED,
	ENUM_QB_SHELL,
	ENUM_QB_SHELL_QB64,
	ENUM_QB_SIGNAL,
	ENUM_QB_SIN,
	ENUM_QB_SINGLE,
	ENUM_QB_SLEEP,
	ENUM_QB_SOUND,
	ENUM_QB_SPACE_DS,
	ENUM_QB_SPC,
	ENUM_QB_SQR,
	ENUM_QB_STATIC,
	ENUM_QB_DS_STATIC,
	ENUM_QB_STEP,
	ENUM_QB_STICK,
	ENUM_QB_STOP,
	ENUM_QB_STR_DS,
	ENUM_QB_STRIG_STATEMENT,
	ENUM_QB_STRIG_FUNCTION,
	ENUM_QB_STRING,
	ENUM_QB_STRING_DS,
	ENUM_QB_SUB,
	ENUM_QB_SWAP,
	ENUM_QB_SYSTEM,
	ENUM_QB_TAB,
	ENUM_QB_TAN,
	ENUM_QB_THEN,
	ENUM_QB_TIME_DS_STATEMENT,
	ENUM_QB_TIME_DS_FUNCTION,
	ENUM_QB_TIMER_STATEMENT,
	ENUM_QB_TIMER_FUNCTION,
	ENUM_QB_TO,
	ENUM_QB_TROFF,
	ENUM_QB_TRON,
	ENUM_QB_TYPE,
	ENUM_QB_UBOUND,
	ENUM_QB_UCASE_DS,
	ENUM_QB_UEVENT,
	ENUM_QB_UNLOCK,
	ENUM_QB_UNTIL,
	ENUM_QB_VAL,
	ENUM_QB_VARPTR,
	ENUM_QB_VARPTR_DS,
	ENUM_QB_VARSEG,
	ENUM_QB_VIEW,
	ENUM_QB_VIEW_PRINT,
	ENUM_QB_WAIT,
	ENUM_QB_WEND,
	ENUM_QB_WHILE,
	ENUM_QB_WHILE_WEND,
	ENUM_QB_WIDTH,
	ENUM_QB_WINDOW,
	ENUM_QB_WRITE_SCREEN,
	ENUM_QB_WRITE_FILE,
	ENUM_QB_XOR,
/*
	END : ORIGINAL QBASIC KEYWORDS
	BEGIN : OpenGL specific keywords
*/
	ENUM_OGL__glAccum,
	ENUM_OGL__glAlphaFunc,
	ENUM_OGL__glAreTexturesResident,
	ENUM_OGL__glArrayElement,
	ENUM_OGL__glBegin,
	ENUM_OGL__glBindTexture,
	ENUM_OGL__glBitmap,
	ENUM_OGL__glBlendFunc,
	ENUM_OGL__glCallList,
	ENUM_OGL__glCallLists,
	ENUM_OGL__glClear,
	ENUM_OGL__glClearAccum,
	ENUM_OGL__glClearColor,
	ENUM_OGL__glClearDepth,
	ENUM_OGL__glClearIndex,
	ENUM_OGL__glClearStencil,
	ENUM_OGL__glClipPlane,
	ENUM_OGL__glColor3b,
	ENUM_OGL__glColor3bv,
	ENUM_OGL__glColor3d,
	ENUM_OGL__glColor3dv,
	ENUM_OGL__glColor3f,
	ENUM_OGL__glColor3fv,
	ENUM_OGL__glColor3i,
	ENUM_OGL__glColor3iv,
	ENUM_OGL__glColor3s,
	ENUM_OGL__glColor3sv,
	ENUM_OGL__glColor3ub,
	ENUM_OGL__glColor3ubv,
	ENUM_OGL__glColor3ui,
	ENUM_OGL__glColor3uiv,
	ENUM_OGL__glColor3us,
	ENUM_OGL__glColor3usv,
	ENUM_OGL__glColor4b,
	ENUM_OGL__glColor4bv,
	ENUM_OGL__glColor4d,
	ENUM_OGL__glColor4dv,
	ENUM_OGL__glColor4f,
	ENUM_OGL__glColor4fv,
	ENUM_OGL__glColor4i,
	ENUM_OGL__glColor4iv,
	ENUM_OGL__glColor4s,
	ENUM_OGL__glColor4sv,
	ENUM_OGL__glColor4ub,
	ENUM_OGL__glColor4ubv,
	ENUM_OGL__glColor4ui,
	ENUM_OGL__glColor4uiv,
	ENUM_OGL__glColor4us,
	ENUM_OGL__glColor4usv,
	ENUM_OGL__glColorMask,
	ENUM_OGL__glColorMaterial,
	ENUM_OGL__glColorPointer,
	ENUM_OGL__glCopyPixels,
	ENUM_OGL__glCopyTexImage1D,
	ENUM_OGL__glCopyTexImage2D,
	ENUM_OGL__glCopyTexSubImage1D,
	ENUM_OGL__glCopyTexSubImage2D,
	ENUM_OGL__glCullFace,
	ENUM_OGL__glDeleteLists,
	ENUM_OGL__glDeleteTextures,
	ENUM_OGL__glDepthFunc,
	ENUM_OGL__glDepthMask,
	ENUM_OGL__glDepthRange,
	ENUM_OGL__glDisable,
	ENUM_OGL__glDisableClientState,
	ENUM_OGL__glDrawArrays,
	ENUM_OGL__glDrawBuffer,
	ENUM_OGL__glDrawElements,
	ENUM_OGL__glDrawPixels,
	ENUM_OGL__glEdgeFlag,
	ENUM_OGL__glEdgeFlagPointer,
	ENUM_OGL__glEdgeFlagv,
	ENUM_OGL__glEnable,
	ENUM_OGL__glEnableClientState,
	ENUM_OGL__glEnd,
	ENUM_OGL__glEndList,
	ENUM_OGL__glEvalCoord1d,
	ENUM_OGL__glEvalCoord1dv,
	ENUM_OGL__glEvalCoord1f,
	ENUM_OGL__glEvalCoord1fv,
	ENUM_OGL__glEvalCoord2d,
	ENUM_OGL__glEvalCoord2dv,
	ENUM_OGL__glEvalCoord2f,
	ENUM_OGL__glEvalCoord2fv,
	ENUM_OGL__glEvalMesh1,
	ENUM_OGL__glEvalMesh2,
	ENUM_OGL__glEvalPoint1,
	ENUM_OGL__glEvalPoint2,
	ENUM_OGL__glFeedbackBuffer,
	ENUM_OGL__glFinish,
	ENUM_OGL__glFlush,
	ENUM_OGL__glFogf,
	ENUM_OGL__glFogfv,
	ENUM_OGL__glFogi,
	ENUM_OGL__glFogiv,
	ENUM_OGL__glFrontFace,
	ENUM_OGL__glFrustum,
	ENUM_OGL__glGenLists,
	ENUM_OGL__glGenTextures,
	ENUM_OGL__glGetBooleanv,
	ENUM_OGL__glGetClipPlane,
	ENUM_OGL__glGetDoublev,
	ENUM_OGL__glGetError,
	ENUM_OGL__glGetFloatv,
	ENUM_OGL__glGetIntegerv,
	ENUM_OGL__glGetLightfv,
	ENUM_OGL__glGetLightiv,
	ENUM_OGL__glGetMapdv,
	ENUM_OGL__glGetMapfv,
	ENUM_OGL__glGetMapiv,
	ENUM_OGL__glGetMaterialfv,
	ENUM_OGL__glGetMaterialiv,
	ENUM_OGL__glGetPixelMapfv,
	ENUM_OGL__glGetPixelMapuiv,
	ENUM_OGL__glGetPixelMapusv,
	ENUM_OGL__glGetPointerv,
	ENUM_OGL__glGetPolygonStipple,
	ENUM_OGL__glGetString,
	ENUM_OGL__glGetTexEnvfv,
	ENUM_OGL__glGetTexEnviv,
	ENUM_OGL__glGetTexGendv,
	ENUM_OGL__glGetTexGenfv,
	ENUM_OGL__glGetTexGeniv,
	ENUM_OGL__glGetTexImage,
	ENUM_OGL__glGetTexLevelParameterfv,
	ENUM_OGL__glGetTexLevelParameteriv,
	ENUM_OGL__glGetTexParameterfv,
	ENUM_OGL__glGetTexParameteriv,
	ENUM_OGL__glHint,
	ENUM_OGL__glIndexMask,
	ENUM_OGL__glIndexPointer,
	ENUM_OGL__glIndexd,
	ENUM_OGL__glIndexdv,
	ENUM_OGL__glIndexf,
	ENUM_OGL__glIndexfv,
	ENUM_OGL__glIndexi,
	ENUM_OGL__glIndexiv,
	ENUM_OGL__glIndexs,
	ENUM_OGL__glIndexsv,
	ENUM_OGL__glIndexub,
	ENUM_OGL__glIndexubv,
	ENUM_OGL__glInitNames,
	ENUM_OGL__glInterleavedArrays,
	ENUM_OGL__glIsEnabled,
	ENUM_OGL__glIsList,
	ENUM_OGL__glIsTexture,
	ENUM_OGL__glLightModelf,
	ENUM_OGL__glLightModelfv,
	ENUM_OGL__glLightModeli,
	ENUM_OGL__glLightModeliv,
	ENUM_OGL__glLightf,
	ENUM_OGL__glLightfv,
	ENUM_OGL__glLighti,
	ENUM_OGL__glLightiv,
	ENUM_OGL__glLineStipple,
	ENUM_OGL__glLineWidth,
	ENUM_OGL__glListBase,
	ENUM_OGL__glLoadIdentity,
	ENUM_OGL__glLoadMatrixd,
	ENUM_OGL__glLoadMatrixf,
	ENUM_OGL__glLoadName,
	ENUM_OGL__glLogicOp,
	ENUM_OGL__glMap1d,
	ENUM_OGL__glMap1f,
	ENUM_OGL__glMap2d,
	ENUM_OGL__glMap2f,
	ENUM_OGL__glMapGrid1d,
	ENUM_OGL__glMapGrid1f,
	ENUM_OGL__glMapGrid2d,
	ENUM_OGL__glMapGrid2f,
	ENUM_OGL__glMaterialf,
	ENUM_OGL__glMaterialfv,
	ENUM_OGL__glMateriali,
	ENUM_OGL__glMaterialiv,
	ENUM_OGL__glMatrixMode,
	ENUM_OGL__glMultMatrixd,
	ENUM_OGL__glMultMatrixf,
	ENUM_OGL__glNewList,
	ENUM_OGL__glNormal3b,
	ENUM_OGL__glNormal3bv,
	ENUM_OGL__glNormal3d,
	ENUM_OGL__glNormal3dv,
	ENUM_OGL__glNormal3f,
	ENUM_OGL__glNormal3fv,
	ENUM_OGL__glNormal3i,
	ENUM_OGL__glNormal3iv,
	ENUM_OGL__glNormal3s,
	ENUM_OGL__glNormal3sv,
	ENUM_OGL__glNormalPointer,
	ENUM_OGL__glOrtho,
	ENUM_OGL__glPassThrough,
	ENUM_OGL__glPixelMapfv,
	ENUM_OGL__glPixelMapuiv,
	ENUM_OGL__glPixelMapusv,
	ENUM_OGL__glPixelStoref,
	ENUM_OGL__glPixelStorei,
	ENUM_OGL__glPixelTransferf,
	ENUM_OGL__glPixelTransferi,
	ENUM_OGL__glPixelZoom,
	ENUM_OGL__glPointSize,
	ENUM_OGL__glPolygonMode,
	ENUM_OGL__glPolygonOffset,
	ENUM_OGL__glPolygonStipple,
	ENUM_OGL__glPopAttrib,
	ENUM_OGL__glPopClientAttrib,
	ENUM_OGL__glPopMatrix,
	ENUM_OGL__glPopName,
	ENUM_OGL__glPrioritizeTextures,
	ENUM_OGL__glPushAttrib,
	ENUM_OGL__glPushClientAttrib,
	ENUM_OGL__glPushMatrix,
	ENUM_OGL__glPushName,
	ENUM_OGL__glRasterPos2d,
	ENUM_OGL__glRasterPos2dv,
	ENUM_OGL__glRasterPos2f,
	ENUM_OGL__glRasterPos2fv,
	ENUM_OGL__glRasterPos2i,
	ENUM_OGL__glRasterPos2iv,
	ENUM_OGL__glRasterPos2s,
	ENUM_OGL__glRasterPos2sv,
	ENUM_OGL__glRasterPos3d,
	ENUM_OGL__glRasterPos3dv,
	ENUM_OGL__glRasterPos3f,
	ENUM_OGL__glRasterPos3fv,
	ENUM_OGL__glRasterPos3i,
	ENUM_OGL__glRasterPos3iv,
	ENUM_OGL__glRasterPos3s,
	ENUM_OGL__glRasterPos3sv,
	ENUM_OGL__glRasterPos4d,
	ENUM_OGL__glRasterPos4dv,
	ENUM_OGL__glRasterPos4f,
	ENUM_OGL__glRasterPos4fv,
	ENUM_OGL__glRasterPos4i,
	ENUM_OGL__glRasterPos4iv,
	ENUM_OGL__glRasterPos4s,
	ENUM_OGL__glRasterPos4sv,
	ENUM_OGL__glReadBuffer,
	ENUM_OGL__glReadPixels,
	ENUM_OGL__glRectd,
	ENUM_OGL__glRectdv,
	ENUM_OGL__glRectf,
	ENUM_OGL__glRectfv,
	ENUM_OGL__glRecti,
	ENUM_OGL__glRectiv,
	ENUM_OGL__glRects,
	ENUM_OGL__glRectsv,
	ENUM_OGL__glRenderMode,
	ENUM_OGL__glRotated,
	ENUM_OGL__glRotatef,
	ENUM_OGL__glScaled,
	ENUM_OGL__glScalef,
	ENUM_OGL__glScissor,
	ENUM_OGL__glSelectBuffer,
	ENUM_OGL__glShadeModel,
	ENUM_OGL__glStencilFunc,
	ENUM_OGL__glStencilMask,
	ENUM_OGL__glStencilOp,
	ENUM_OGL__glTexCoord1d,
	ENUM_OGL__glTexCoord1dv,
	ENUM_OGL__glTexCoord1f,
	ENUM_OGL__glTexCoord1fv,
	ENUM_OGL__glTexCoord1i,
	ENUM_OGL__glTexCoord1iv,
	ENUM_OGL__glTexCoord1s,
	ENUM_OGL__glTexCoord1sv,
	ENUM_OGL__glTexCoord2d,
	ENUM_OGL__glTexCoord2dv,
	ENUM_OGL__glTexCoord2f,
	ENUM_OGL__glTexCoord2fv,
	ENUM_OGL__glTexCoord2i,
	ENUM_OGL__glTexCoord2iv,
	ENUM_OGL__glTexCoord2s,
	ENUM_OGL__glTexCoord2sv,
	ENUM_OGL__glTexCoord3d,
	ENUM_OGL__glTexCoord3dv,
	ENUM_OGL__glTexCoord3f,
	ENUM_OGL__glTexCoord3fv,
	ENUM_OGL__glTexCoord3i,
	ENUM_OGL__glTexCoord3iv,
	ENUM_OGL__glTexCoord3s,
	ENUM_OGL__glTexCoord3sv,
	ENUM_OGL__glTexCoord4d,
	ENUM_OGL__glTexCoord4dv,
	ENUM_OGL__glTexCoord4f,
	ENUM_OGL__glTexCoord4fv,
	ENUM_OGL__glTexCoord4i,
	ENUM_OGL__glTexCoord4iv,
	ENUM_OGL__glTexCoord4s,
	ENUM_OGL__glTexCoord4sv,
	ENUM_OGL__glTexCoordPointer,
	ENUM_OGL__glTexEnvf,
	ENUM_OGL__glTexEnvfv,
	ENUM_OGL__glTexEnvi,
	ENUM_OGL__glTexEnviv,
	ENUM_OGL__glTexGend,
	ENUM_OGL__glTexGendv,
	ENUM_OGL__glTexGenf,
	ENUM_OGL__glTexGenfv,
	ENUM_OGL__glTexGeni,
	ENUM_OGL__glTexGeniv,
	ENUM_OGL__glTexImage1D,
	ENUM_OGL__glTexImage2D,
	ENUM_OGL__glTexParameterf,
	ENUM_OGL__glTexParameterfv,
	ENUM_OGL__glTexParameteri,
	ENUM_OGL__glTexParameteriv,
	ENUM_OGL__glTexSubImage1D,
	ENUM_OGL__glTexSubImage2D,
	ENUM_OGL__glTranslated,
	ENUM_OGL__glTranslatef,
	ENUM_OGL__glVertex2d,
	ENUM_OGL__glVertex2dv,
	ENUM_OGL__glVertex2f,
	ENUM_OGL__glVertex2fv,
	ENUM_OGL__glVertex2i,
	ENUM_OGL__glVertex2iv,
	ENUM_OGL__glVertex2s,
	ENUM_OGL__glVertex2sv,
	ENUM_OGL__glVertex3d,
	ENUM_OGL__glVertex3dv,
	ENUM_OGL__glVertex3f,
	ENUM_OGL__glVertex3fv,
	ENUM_OGL__glVertex3i,
	ENUM_OGL__glVertex3iv,
	ENUM_OGL__glVertex3s,
	ENUM_OGL__glVertex3sv,
	ENUM_OGL__glVertex4d,
	ENUM_OGL__glVertex4dv,
	ENUM_OGL__glVertex4f,
	ENUM_OGL__glVertex4fv,
	ENUM_OGL__glVertex4i,
	ENUM_OGL__glVertex4iv,
	ENUM_OGL__glVertex4s,
	ENUM_OGL__glVertex4sv,
	ENUM_OGL__glVertexPointer,
	ENUM_OGL__glViewport,
/*
	Additional commands not covered by the above.
*/
	ENUM_QB_MULTI_LINE_COMMENT_BEGIN,
	ENUM_QB_MULTI_LINE_COMMENT_END,
	ENUM_QB_MULTI_LINE_COMMENT_ERROR,
	ENUM_QB_STRING_VARIABLE,
	ENUM_QB_SINGLE_VARIABLE,
	ENUM_QB_DOUBLE_VARIABLE,
	ENUM_QB_FLOAT_VARIABLE,
	ENUM_QB_INTEGER_VARIABLE,
	ENUM_QB_LONG_VARIABLE,
	ENUM_QB_INTEGER64_VARIABLE,
	ENUM_QB_BIT_VARIABLE,
	ENUM_QB_BYTE_VARIABLE,
	ENUM_QB_OFFSET_VARIABLE,
	ENUM_QB_UNSIGNED_VARIABLE,
	ENUM_QB_UNSIGNED_INTEGER_VARIABLE,
	ENUM_QB_UNSIGNED_LONG_VARIABLE,
	ENUM_QB_UNSIGNED_INTEGER64_VARIABLE,
	ENUM_QB_UNSIGNED_BIT_VARIABLE,
	ENUM_QB_UNSIGNED_BYTE_VARIABLE,
	ENUM_QB_UNSIGNED_OFFSET_VARIABLE,
	ENUM_QB_STANDARD_VARIABLE,
	ENUM_QB_LESS_THAN_OR_EQUAL_TO,
	ENUM_QB_GREATER_THAN_OR_EQUAL_TO,
	ENUM_QB_NOT_EQUAL_TO,
	ENUM_QB_ELSE_IF,
	ENUM_QB_NEW_LINE,
	ENUM_QB_WHITE_SPACE,
	ENUM_QB_UNKNOWN_CHARACTER,
	};

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

\$[iI][nN][cC][lL][uU][dD][eE]{ws}*[\"<]	{	BEGIN INCL;	}

<INCL>[^{ws}*\">]+   { /* got the include file name */
printf( "---> Entering INCLUDE\n" );
	if( include_stack_ptr >= MAX_INCLUDE_DEPTH ){
		fprintf( stderr, "Includes nested too deeply" );
		exit( 1 );
		}

	include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

	yyin = fopen( yytext, "r" );

	if( ! yyin ){ printf( "*****ERROR : No Input File - Aborting\n" ); exit; }

	yy_switch_to_buffer( yy_create_buffer( yyin, YY_BUF_SIZE ) );

	BEGIN(INITIAL);
	}

<<EOF>> {
printf( "<--- Exiting INCLUDE\n" );

   if( --include_stack_ptr < 0 ){ yyterminate(); }
	   else{
		   yy_delete_buffer( YY_CURRENT_BUFFER );
		   yy_switch_to_buffer( include_stack[include_stack_ptr] );
		   }
   }

	/*	+++++	DO NOT REMOVE THE NEXT LINE!!!	+++++	*/
	/*	BEGIN LEX	*/
"+"							{	printf("ENUM_PLUS_SIGN => %s\n", yytext); nchar += yyleng; return ENUM_PLUS_SIGN; }

"-"							{	printf("MINUS => %s\n", yytext); nchar += yyleng; return ENUM_MINUS_SIGN; }

"*"							{	printf("MULTIPLY => %s\n", yytext); nchar += yyleng; return ENUM_ASTERIK; }

"/"							{	printf("DIVIDE => %s\n", yytext); nchar += yyleng; return ENUM_SLASH_FORWARDS; }

"\\"						{	printf("INTEGER DIVISION => %s\n", yytext); nchar += yyleng; return ENUM_SLASH_BACK; }

"^"							{	printf("EXPONENTIAL => %s\n", yytext); nchar += yyleng; return ENUM_CARET; }

"="							{	printf("EQUAL SIGN => %s\n", yytext); nchar += yyleng; return ENUM_EQUAL; }

"<"							{	printf("LESS THAN => %s\n", yytext); nchar += yyleng; return ENUM_LESS_THAN; }

">"							{	printf("GREATER THAN => %s\n", yytext); nchar += yyleng; return ENUM_GREATER_THAN; }

"<="						{	printf("LESS THAN OR EQUAL TO => %s\n", yytext);

								nchar += yyleng; return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }

">="						{	printf("GREATER THAN OR EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }

"<>"						{	printf("NOT EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_NOT_EQUAL_TO; }

"\("						{	printf("OPEN PARENTHESIS => %s\n", yytext); nchar += yyleng; return ENUM_PAREN_OPEN; }

"\)"						{	printf("CLOSE PARENTHESIS => %s\n", yytext); nchar += yyleng; return ENUM_PAREN_CLOSED; }

"&"[bB]{binary}+			{	printf("BINARY NUMBER => %s\n", yytext); nchar += yyleng; return ENUM_QB_BINARY; }

"&"[oO]{octal}+				{	printf("OCTAL NUMBER => %s\n", yytext); nchar += yyleng; return ENUM_QB_OCTAL; }

"&"[hH]{xdigit}+			{	printf("HEXADECIMAL NUMBER => %s\n", yytext); nchar += yyleng; return ENUM_QB_HEXADECIMAL; }

{alpha}{alnum}*\$			{	printf("STRING VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING_VARIABLE; }

{alpha}{alnum}*\!			{	printf("SINGLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE_VARIABLE; }

{alpha}{alnum}*\#			{	printf("DOUBLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE_VARIABLE; }

{alpha}{alnum}*\#\#			{	printf("FLOAT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }

{alpha}{alnum}*\%			{	printf("INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER_VARIABLE; }

{alpha}{alnum}*\&			{	printf("LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }

{alpha}{alnum}*\&\&			{	printf("INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER64_VARIABLE; }

{alpha}{alnum}*\`			{	printf("BIT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BIT_VARIABLE; }

{alpha}{alnum}*\%\%			{	printf("BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BYTE_VARIABLE; }

{alpha}{alnum}*\%\&			{	printf("OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_OFFSET_VARIABLE; }

{alpha}{alnum}*\~			{	printf("UNSIGNED VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_VARIABLE; }

{alpha}{alnum}*\~\%			{	printf("UNSIGNED INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }

{alpha}{alnum}*\~\&			{	printf("UNSIGNED LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_LONG_VARIABLE; }

{alpha}{alnum}*\~\&\&		{	printf("UNSIGNED INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }

{alpha}{alnum}*\~\`			{	printf("UNSIGNED BIT VARIABLE => %s\n", yytext); nchar += yyleng; return

ENUM_QB_UNSIGNED_BIT_VARIABLE; }

{alpha}{alnum}*\~\%\%		{	printf("UNSIGNED BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }

{alpha}{alnum}*\~\%\&		{	printf("UNSIGNED OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }

{alpha}{alnum}*				{	printf("STANDARD QB VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STANDARD_VARIABLE; }

{digit}+					{	printf("INTEGER NUMBER => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }

{float}						{	printf("FLOAT NUMBER => %s\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }

[iI][fF]                                                    {	printf("IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_IF; }
[aA][sS]                                                    {	printf("AS => %s\n", yytext); nchar += yyleng; return ENUM_QB_AS; }
[tT][oO]                                                    {	printf("TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_TO; }
[oO][rR]                                                    {	printf("OR => %s\n", yytext); nchar += yyleng; return ENUM_QB_OR; }
[dD][oO]                                                    {	printf("DO => %s\n", yytext); nchar += yyleng; return ENUM_QB_DO; }
[eE][qQ][vV]                                                {	printf("EQV => %s\n", yytext); nchar += yyleng; return ENUM_QB_EQV; }
[eE][oO][fF]                                                {	printf("EOF => %s\n", yytext); nchar += yyleng; return ENUM_QB_EOF; }
[eE][rR][lL]                                                {	printf("ERL => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERL; }
[eE][xX][pP]                                                {	printf("EXP => %s\n", yytext); nchar += yyleng; return ENUM_QB_EXP; }
[fF][rR][eE]                                                {	printf("FRE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FRE; }
[gG][eE][tT]                                                {	printf("GET => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET; }
[fF][oO][rR]                                                {	printf("FOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_FOR; }
[fF][iI][xX]                                                {	printf("FIX => %s\n", yytext); nchar += yyleng; return ENUM_QB_FIX; }
[eE][nN][dD]                                                {	printf("END => %s\n", yytext); nchar += yyleng; return ENUM_QB_END; }
[eE][rR][rR]                                                {	printf("ERR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERR; }
[cC][vV][sS]                                                {	printf("CVS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVS; }
[aA][tT][nN]                                                {	printf("ATN => %s\n", yytext); nchar += yyleng; return ENUM_QB_ATN; }
[aA][sS][cC]                                                {	printf("ASC => %s\n", yytext); nchar += yyleng; return ENUM_QB_ASC; }
[aA][nN][yY]                                                {	printf("ANY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ANY; }
[aA][nN][dD]                                                {	printf("AND => %s\n", yytext); nchar += yyleng; return ENUM_QB_AND; }
[cC][lL][sS]                                                {	printf("CLS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLS; }
[cC][oO][sS]                                                {	printf("COS => %s\n", yytext); nchar += yyleng; return ENUM_QB_COS; }
[cC][vV][lL]                                                {	printf("CVL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVL; }
[cC][vV][iI]                                                {	printf("CVI => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVI; }
[cC][vV][dD]                                                {	printf("CVD => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVD; }
[dD][iI][mM]                                                {	printf("DIM => %s\n", yytext); nchar += yyleng; return ENUM_QB_DIM; }
[iI][nN][pP]                                                {	printf("INP => %s\n", yytext); nchar += yyleng; return ENUM_QB_INP; }
[sS][iI][nN]                                                {	printf("SIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SIN; }
[sS][pP][cC]                                                {	printf("SPC => %s\n", yytext); nchar += yyleng; return ENUM_QB_SPC; }
[sS][gG][nN]                                                {	printf("SGN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SGN; }
[rR][uU][nN]                                                {	printf("RUN => %s\n", yytext); nchar += yyleng; return ENUM_QB_RUN; }
[rR][nN][dD]                                                {	printf("RND => %s\n", yytext); nchar += yyleng; return ENUM_QB_RND; }
[sS][qQ][rR]                                                {	printf("SQR => %s\n", yytext); nchar += yyleng; return ENUM_QB_SQR; }
[sS][uU][bB]                                                {	printf("SUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_SUB; }
[xX][oO][rR]                                                {	printf("XOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_XOR; }
[vV][aA][lL]                                                {	printf("VAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_VAL; }
[tT][aA][nN]                                                {	printf("TAN => %s\n", yytext); nchar += yyleng; return ENUM_QB_TAN; }
[tT][aA][bB]                                                {	printf("TAB => %s\n", yytext); nchar += yyleng; return ENUM_QB_TAB; }
[rR][eE][mM]                                                {	printf("REM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REM; }
[pP][oO][sS]                                                {	printf("POS => %s\n", yytext); nchar += yyleng; return ENUM_QB_POS; }
[lL][eE][tT]                                                {	printf("LET => %s\n", yytext); nchar += yyleng; return ENUM_QB_LET; }
[lL][eE][nN]                                                {	printf("LEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_LEN; }
[iI][nN][tT]                                                {	printf("INT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INT; }
[aA][bB][sS]                                                {	printf("ABS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ABS; }
[lL][oO][cC]                                                {	printf("LOC => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOC; }
[lL][oO][fF]                                                {	printf("LOF => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOF; }
[oO][uU][tT]                                                {	printf("OUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_OUT; }
[oO][fF][fF]                                                {	printf("OFF => %s\n", yytext); nchar += yyleng; return ENUM_QB_OFF; }
[nN][oO][tT]                                                {	printf("NOT => %s\n", yytext); nchar += yyleng; return ENUM_QB_NOT; }
[mM][oO][dD]                                                {	printf("MOD => %s\n", yytext); nchar += yyleng; return ENUM_QB_MOD; }
[iI][mM][pP]                                                {	printf("IMP => %s\n", yytext); nchar += yyleng; return ENUM_QB_IMP; }
[lL][oO][gG]                                                {	printf("LOG => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOG; }
_[cC][vV]                                                   {	printf("_CV => %s\n", yytext); nchar += yyleng; return ENUM_QB__CV; }
[lL][iI][sS][tT]                                            {	printf("LIST => %s\n", yytext); nchar += yyleng; return ENUM_QB_LIST; }
[lL][oO][cC][kK]                                            {	printf("LOCK => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOCK; }
[lL][oO][nN][gG]                                            {	printf("LONG => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG; }
[lL][iI][nN][eE]                                            {	printf("LINE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE; }
[kK][iI][lL][lL]                                            {	printf("KILL => %s\n", yytext); nchar += yyleng; return ENUM_QB_KILL; }
_[rR][eE][dD]                                               {	printf("_RED => %s\n", yytext); nchar += yyleng; return ENUM_QB__RED; }
_[rR]2[gG]                                                  {	printf("_R2G => %s\n", yytext); nchar += yyleng; return ENUM_QB__R2G; }
_[rR]2[dD]                                                  {	printf("_R2D => %s\n", yytext); nchar += yyleng; return ENUM_QB__R2D; }
[lL][sS][eE][tT]                                            {	printf("LSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_LSET; }
[nN][aA][mM][eE]                                            {	printf("NAME => %s\n", yytext); nchar += yyleng; return ENUM_QB_NAME; }
_[bB][iI][tT]                                               {	printf("_BIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__BIT; }
[pP][sS][eE][tT]                                            {	printf("PSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_PSET; }
[rR][eE][aA][dD]                                            {	printf("READ => %s\n", yytext); nchar += yyleng; return ENUM_QB_READ; }
[pP][oO][kK][eE]                                            {	printf("POKE => %s\n", yytext); nchar += yyleng; return ENUM_QB_POKE; }
[pP][mM][aA][pP]                                            {	printf("PMAP => %s\n", yytext); nchar += yyleng; return ENUM_QB_PMAP; }
[gG][oO][tT][oO]                                            {	printf("GOTO => %s\n", yytext); nchar += yyleng; return ENUM_QB_GOTO; }
[oO][pP][eE][nN]                                            {	printf("OPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPEN; }
[pP][eE][eE][kK]                                            {	printf("PEEK => %s\n", yytext); nchar += yyleng; return ENUM_QB_PEEK; }
[rR][sS][eE][tT]                                            {	printf("RSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_RSET; }
[fF][rR][eE][eE]                                            {	printf("FREE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FREE; }
[cC][dD][bB][lL]                                            {	printf("CDBL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CDBL; }
[cC][iI][nN][tT]                                            {	printf("CINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_CINT; }
[cC][lL][nN][gG]                                            {	printf("CLNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLNG; }
[cC][aA][sS][eE]                                            {	printf("CASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE; }
[cC][aA][lL][lL]                                            {	printf("CALL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALL; }
_[dD]2[rR]                                                  {	printf("_D2R => %s\n", yytext); nchar += yyleng; return ENUM_QB__D2R; }
_[dD]2[gG]                                                  {	printf("_D2G => %s\n", yytext); nchar += yyleng; return ENUM_QB__D2G; }
[bB][eE][eE][pP]                                            {	printf("BEEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_BEEP; }
[cC][sS][nN][gG]                                            {	printf("CSNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_CSNG; }
_[cC][sS][cC]                                               {	printf("_CSC => %s\n", yytext); nchar += yyleng; return ENUM_QB__CSC; }
_[sS][eE][cC]                                               {	printf("_SEC => %s\n", yytext); nchar += yyleng; return ENUM_QB__SEC; }
[eE][xX][iI][tT]                                            {	printf("EXIT => %s\n", yytext); nchar += yyleng; return ENUM_QB_EXIT; }
_[rR][gG][bB]                                               {	printf("_RGB => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGB; }
[eE][lL][sS][eE]                                            {	printf("ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSE; }
[dD][rR][aA][wW]                                            {	printf("DRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB_DRAW; }
[dD][aA][tT][aA]                                            {	printf("DATA => %s\n", yytext); nchar += yyleng; return ENUM_QB_DATA; }
_[cC][oO][tT]                                               {	printf("_COT => %s\n", yytext); nchar += yyleng; return ENUM_QB__COT; }
[sS][aA][dD][dD]                                            {	printf("SADD => %s\n", yytext); nchar += yyleng; return ENUM_QB_SADD; }
[lL][pP][oO][sS]                                            {	printf("LPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPOS; }
[sS][wW][aA][pP]                                            {	printf("SWAP => %s\n", yytext); nchar += yyleng; return ENUM_QB_SWAP; }
[sS][tT][oO][pP]                                            {	printf("STOP => %s\n", yytext); nchar += yyleng; return ENUM_QB_STOP; }
[sS][tT][eE][pP]                                            {	printf("STEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_STEP; }
_[gG]2[dD]                                                  {	printf("_G2D => %s\n", yytext); nchar += yyleng; return ENUM_QB__G2D; }
[tT][rR][oO][nN]                                            {	printf("TRON => %s\n", yytext); nchar += yyleng; return ENUM_QB_TRON; }
[tT][yY][pP][eE]                                            {	printf("TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB_TYPE; }
[wW][eE][nN][dD]                                            {	printf("WEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_WEND; }
[wW][aA][iI][tT]                                            {	printf("WAIT => %s\n", yytext); nchar += yyleng; return ENUM_QB_WAIT; }
[vV][iI][eE][wW]                                            {	printf("VIEW => %s\n", yytext); nchar += yyleng; return ENUM_QB_VIEW; }
_[gG]2[rR]                                                  {	printf("_G2R => %s\n", yytext); nchar += yyleng; return ENUM_QB__G2R; }
[tT][hH][eE][nN]                                            {	printf("THEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_THEN; }
_[aA][cC][oO][sS]                                           {	printf("_ACOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__ACOS; }
[eE][rR][dD][eE][vV]                                        {	printf("ERDEV => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERDEV; }
[eE][rR][rR][oO][rR]                                        {	printf("ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERROR; }
_[sS][eE][cC][hH]                                           {	printf("_SECH => %s\n", yytext); nchar += yyleng; return ENUM_QB__SECH; }
[eE][rR][aA][sS][eE]                                        {	printf("ERASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERASE; }
_[cC][oO][tT][hH]                                           {	printf("_COTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__COTH; }
_[sS][iI][nN][hH]                                           {	printf("_SINH => %s\n", yytext); nchar += yyleng; return ENUM_QB__SINH; }
[tT][rR][oO][fF][fF]                                        {	printf("TROFF => %s\n", yytext); nchar += yyleng; return ENUM_QB_TROFF; }
_[eE][xX][iI][tT]                                           {	printf("_EXIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__EXIT; }
[iI][nN][pP][uU][tT]                                        {	printf("INPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT; }
[iI][nN][sS][tT][rR]                                        {	printf("INSTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_INSTR; }
[iI][oO][cC][tT][lL]                                        {	printf("IOCTL => %s\n", yytext); nchar += yyleng; return ENUM_QB_IOCTL; }
_[cC][lL][iI][pP]                                           {	printf("_CLIP => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLIP; }
[gG][oO][sS][uU][bB]                                        {	printf("GOSUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_GOSUB; }
[fF][iI][eE][lL][dD]                                        {	printf("FIELD => %s\n", yytext); nchar += yyleng; return ENUM_QB_FIELD; }
[fF][iI][lL][eE][sS]                                        {	printf("FILES => %s\n", yytext); nchar += yyleng; return ENUM_QB_FILES; }
_[cC][oO][sS][hH]                                           {	printf("_COSH => %s\n", yytext); nchar += yyleng; return ENUM_QB__COSH; }
[uU][nN][tT][iI][lL]                                        {	printf("UNTIL => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNTIL; }
[bB][yY][vV][aA][lL]                                        {	printf("BYVAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_BYVAL; }
[wW][hH][iI][lL][eE]                                        {	printf("WHILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHILE; }
[cC][aA][lL][lL][sS]                                        {	printf("CALLS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALLS; }
_[tT][aA][nN][hH]                                           {	printf("_TANH => %s\n", yytext); nchar += yyleng; return ENUM_QB__TANH; }
[bB][sS][aA][vV][eE]                                        {	printf("BSAVE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BSAVE; }
[wW][iI][dD][tT][hH]                                        {	printf("WIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB_WIDTH; }
[bB][lL][oO][aA][dD]                                        {	printf("BLOAD => %s\n", yytext); nchar += yyleng; return ENUM_QB_BLOAD; }
[sS][hH][eE][lL][lL]                                        {	printf("SHELL => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHELL; }
[cC][dD][eE][cC][lL]                                        {	printf("CDECL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CDECL; }
[cC][oO][lL][oO][rR]                                        {	printf("COLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_COLOR; }
[cC][oO][nN][sS][tT]                                        {	printf("CONST => %s\n", yytext); nchar += yyleng; return ENUM_QB_CONST; }
_[cC][sS][cC][hH]                                           {	printf("_CSCH => %s\n", yytext); nchar += yyleng; return ENUM_QB__CSCH; }
[cC][lL][oO][sS][eE]                                        {	printf("CLOSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLOSE; }
[cC][lL][eE][aA][rR]                                        {	printf("CLEAR => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLEAR; }
[cC][hH][aA][iI][nN]                                        {	printf("CHAIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHAIN; }
[cC][hH][dD][iI][rR]                                        {	printf("CHDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHDIR; }
_[cC][eE][iI][lL]                                           {	printf("_CEIL => %s\n", yytext); nchar += yyleng; return ENUM_QB__CEIL; }
_[rR][gG][bB][aA]                                           {	printf("_RGBA => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGBA; }
[aA][lL][iI][aA][sS]                                        {	printf("ALIAS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ALIAS; }
[rR][mM][dD][iI][rR]                                        {	printf("RMDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_RMDIR; }
[sS][oO][uU][nN][dD]                                        {	printf("SOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_SOUND; }
\$[iI][fF]                                                  {	printf("$IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_IF; }
[pP][rR][iI][nN][tT]                                        {	printf("PRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT; }
_[aA][sS][iI][nN]                                           {	printf("_ASIN => %s\n", yytext); nchar += yyleng; return ENUM_QB__ASIN; }
[mM][kK][dD][iI][rR]                                        {	printf("MKDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKDIR; }
_[hH][iI][dD][eE]                                           {	printf("_HIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__HIDE; }
[pP][oO][iI][nN][tT]                                        {	printf("POINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_POINT; }
[rR][eE][dD][iI][mM]                                        {	printf("REDIM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REDIM; }
_[iI][cC][oO][nN]                                           {	printf("_ICON => %s\n", yytext); nchar += yyleng; return ENUM_QB__ICON; }
_[bB][yY][tT][eE]                                           {	printf("_BYTE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BYTE; }
[sS][tT][iI][cC][kK]                                        {	printf("STICK => %s\n", yytext); nchar += yyleng; return ENUM_QB_STICK; }
_[bB][lL][uU][eE]                                           {	printf("_BLUE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLUE; }
[sS][lL][eE][eE][pP]                                        {	printf("SLEEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_SLEEP; }
[pP][cC][oO][pP][yY]                                        {	printf("PCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB_PCOPY; }
[rR][eE][sS][eE][tT]                                        {	printf("RESET => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESET; }
[pP][aA][iI][nN][tT]                                        {	printf("PAINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_PAINT; }
_[aA][xX][iI][sS]                                           {	printf("_AXIS => %s\n", yytext); nchar += yyleng; return ENUM_QB__AXIS; }
[vV][aA][rR][sS][eE][gG]                                    {	printf("VARSEG => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARSEG; }
[vV][aA][rR][pP][tT][rR]                                    {	printf("VARPTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARPTR; }
[rR][eE][tT][uU][rR][nN]                                    {	printf("RETURN => %s\n", yytext); nchar += yyleng; return ENUM_QB_RETURN; }
[cC][vV][dD][mM][bB][fF]                                    {	printf("CVDMBF => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVDMBF; }
[cC][sS][rR][lL][iI][nN]                                    {	printf("CSRLIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_CSRLIN; }
_[aA][lL][pP][hH][aA]                                       {	printf("_ALPHA => %s\n", yytext); nchar += yyleng; return ENUM_QB__ALPHA; }
[oO][uU][tT][pP][uU][tT]                                    {	printf("OUTPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_OUTPUT; }
_[aA][sS][iI][nN][hH]                                       {	printf("_ASINH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ASINH; }
[cC][oO][mM][mM][oO][nN]                                    {	printf("COMMON => %s\n", yytext); nchar += yyleng; return ENUM_QB_COMMON; }
[sS][hH][aA][rR][eE][dD]                                    {	printf("SHARED => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHARED; }
[wW][iI][nN][dD][oO][wW]                                    {	printf("WINDOW => %s\n", yytext); nchar += yyleng; return ENUM_QB_WINDOW; }
[bB][iI][nN][aA][rR][yY]                                    {	printf("BINARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_BINARY; }
_[aA][cC][oO][sS][hH]                                       {	printf("_ACOSH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ACOSH; }
[aA][pP][pP][eE][nN][dD]                                    {	printf("APPEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_APPEND; }
_[dD][eE][lL][aA][yY]                                       {	printf("_DELAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__DELAY; }
[rR][aA][nN][dD][oO][mM]                                    {	printf("RANDOM => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOM; }
[sS][iI][nN][gG][lL][eE]                                    {	printf("SINGLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE; }
_[aA][tT][aA][nN][hH]                                       {	printf("_ATANH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ATANH; }
[cC][hH][rR]\$                                              {	printf("CHR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHR_DS; }
[oO][nN]{ws}+[kK][eE][yY]                                   {	printf("ON KEY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_KEY; }
[pP][rR][eE][sS][eE][tT]                                    {	printf("PRESET => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRESET; }
[cC][iI][rR][cC][lL][eE]                                    {	printf("CIRCLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CIRCLE; }
[dD][eE][fF]{ws}+[fF][nN]                                   {	printf("DEF FN => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEF_FN; }
[lL][pP][rR][iI][nN][tT]                                    {	printf("LPRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPRINT; }
[sS][iI][gG][nN][aA][lL]                                    {	printf("SIGNAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_SIGNAL; }
[sS][tT][aA][tT][iI][cC]                                    {	printf("STATIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_STATIC; }
[mM][kK][dD]\$                                              {	printf("MKD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKD_DS; }
[rR][eE][sS][uU][mM][eE]                                    {	printf("RESUME => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESUME; }
[mM][kK][lL]\$                                              {	printf("MKL$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKL_DS; }
[mM][kK][iI]\$                                              {	printf("MKI$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKI_DS; }
_[aA][rR][cC][sS][cC]                                       {	printf("_ARCSC => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCSC; }
[sS][yY][sS][tT][eE][mM]                                    {	printf("SYSTEM => %s\n", yytext); nchar += yyleng; return ENUM_QB_SYSTEM; }
[sS][tT][rR]\$                                              {	printf("STR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_STR_DS; }
[lL][bB][oO][uU][nN][dD]                                    {	printf("LBOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_LBOUND; }
[lL][oO][cC][aA][tT][eE]                                    {	printf("LOCATE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOCATE; }
[hH][eE][xX]\$                                              {	printf("HEX$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_HEX_DS; }
_[aA][tT][aA][nN]2                                          {	printf("_ATAN2 => %s\n", yytext); nchar += yyleng; return ENUM_QB__ATAN2; }
[sS][tT][rR][iI][nN][gG]                                    {	printf("STRING => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING; }
[mM][kK][sS]\$                                              {	printf("MKS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKS_DS; }
[eE][nN][dD]{ws}+[iI][fF]                                   {	printf("END IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_END_IF; }
[dD][eE][fF][iI][nN][tT]                                    {	printf("DEFINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFINT; }
[dD][eE][fF][lL][nN][gG]                                    {	printf("DEFLNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFLNG; }
[dD][eE][fF][dD][bB][lL]                                    {	printf("DEFDBL => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFDBL; }
[uU][nN][lL][oO][cC][kK]                                    {	printf("UNLOCK => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNLOCK; }
[cC][vV][sS][mM][bB][fF]                                    {	printf("CVSMBF => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVSMBF; }
[oO][cC][tT]\$                                              {	printf("OCT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_OCT_DS; }
[dD][eE][fF][sS][nN][gG]                                    {	printf("DEFSNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFSNG; }
[dD][eE][fF][sS][tT][rR]                                    {	printf("DEFSTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFSTR; }
[sS][eE][tT][mM][eE][mM]                                    {	printf("SETMEM => %s\n", yytext); nchar += yyleng; return ENUM_QB_SETMEM; }
[eE][lL][sS][eE][iI][fF]                                    {	printf("ELSEIF => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSEIF; }
[uU][bB][oO][uU][nN][dD]                                    {	printf("UBOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_UBOUND; }
[dD][oO][uU][bB][lL][eE]                                    {	printf("DOUBLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE; }
[uU][eE][vV][eE][nN][tT]                                    {	printf("UEVENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_UEVENT; }
[dD][iI][rR]\$                                              {	printf("DIR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_DIR_DS; }
[oO][nN]{ws}+[cC][oO][mM]                                   {	printf("ON COM => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_COM; }
[oO][nN]{ws}+[pP][eE][nN]                                   {	printf("ON PEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_PEN; }
\$[lL][eE][tT]                                              {	printf("$LET => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_LET; }
_[rR][oO][uU][nN][dD]                                       {	printf("_ROUND => %s\n", yytext); nchar += yyleng; return ENUM_QB__ROUND; }
_[gG][rR][eE][eE][nN]                                       {	printf("_GREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__GREEN; }
_[lL][iI][mM][iI][tT]                                       {	printf("_LIMIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__LIMIT; }
_[rR][gG][bB]32                                             {	printf("_RGB32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGB32; }
_[oO][sS]\$                                                 {	printf("_OS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__OS_DS; }
_[mM][kK]\$                                                 {	printf("_MK$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__MK_DS; }
_[rR][eE][dD]32                                             {	printf("_RED32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RED32; }
_[tT][iI][tT][lL][eE]                                       {	printf("_TITLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__TITLE; }
_[hH][yY][pP][oO][tT]                                       {	printf("_HYPOT => %s\n", yytext); nchar += yyleng; return ENUM_QB__HYPOT; }
[aA][cC][cC][eE][sS][sS]                                    {	printf("ACCESS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ACCESS; }
\$[eE][nN][dD]                                              {	printf("$END => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_END; }
_[wW][iI][dD][tT][hH]                                       {	printf("_WIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__WIDTH; }
_[wW][hH][eE][eE][lL]                                       {	printf("_WHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__WHEEL; }
_[fF][lL][oO][aA][tT]                                       {	printf("_FLOAT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FLOAT; }
[lL][eE][fF][tT]\$                                          {	printf("LEFT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LEFT_DS; }
_[mM][oO][uU][sS][eE][xX]                                   {	printf("_MOUSEX => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEX; }
[dD][eE][cC][lL][aA][rR][eE]                                {	printf("DECLARE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE; }
_[mM][oO][uU][sS][eE][yY]                                   {	printf("_MOUSEY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEY; }
[dD][eE][fF]{ws}+[sS][eE][gG]                               {	printf("DEF SEG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEF_SEG; }
_[rR][eE][sS][iI][zZ][eE]                                   {	printf("_RESIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZE; }
_[bB][uU][tT][tT][oO][nN]                                   {	printf("_BUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__BUTTON; }
_[rR][gG][bB][aA]32                                         {	printf("_RGBA32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGBA32; }
[eE][nN][vV][iI][rR][oO][nN]                                {	printf("ENVIRON => %s\n", yytext); nchar += yyleng; return ENUM_QB_ENVIRON; }
[iI][nN][tT][eE][gG][eE][rR]                                {	printf("INTEGER => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER; }
[pP][aA][lL][eE][tT][tT][eE]                                {	printf("PALETTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PALETTE; }
_[hH][eE][iI][gG][hH][tT]                                   {	printf("_HEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__HEIGHT; }
_[kK][eE][yY][hH][iI][tT]                                   {	printf("_KEYHIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYHIT; }
_[aA][rR][cC][cC][oO][tT]                                   {	printf("_ARCCOT => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCCOT; }
\$[eE][lL][sS][eE]                                          {	printf("$ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSE; }
_glEnd                                                      {	printf("_glEnd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnd; }
[rR][eE][sS][tT][oO][rR][eE]                                {	printf("RESTORE => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESTORE; }
_[mM][eE][mM][nN][eE][wW]                                   {	printf("_MEMNEW => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMNEW; }
[oO][nN]{ws}+[gG][oO][tT][oO]                               {	printf("ON GOTO => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_GOTO; }
[oO][nN]{ws}+[pP][lL][aA][yY]                               {	printf("ON PLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_PLAY; }
[eE][lL][sS][eE]{ws}+[iI][fF]                               {	printf("ELSE IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSE_IF; }
_[sS][nN][dD][bB][aA][lL]                                   {	printf("_SNDBAL => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDBAL; }
_[mM][eE][mM][pP][uU][tT]                                   {	printf("_MEMPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMPUT; }
_[bB][lL][uU][eE]32                                         {	printf("_BLUE32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLUE32; }
_[aA][rR][cC][sS][eE][cC]                                   {	printf("_ARCSEC => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCSEC; }
_[sS][oO][uU][rR][cC][eE]                                   {	printf("_SOURCE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SOURCE; }
_[cC][wW][dD]\$                                             {	printf("_CWD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CWD_DS; }
_[sS][nN][dD][rR][aA][wW]                                   {	printf("_SNDRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAW; }
[cC][aA][sS][eE]{ws}+[iI][sS]                               {	printf("CASE IS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE_IS; }
_[sS][tT][rR][cC][mM][pP]                                   {	printf("_STRCMP => %s\n", yytext); nchar += yyleng; return ENUM_QB__STRCMP; }
_[dD][eE][fF][iI][nN][eE]                                   {	printf("_DEFINE => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEFINE; }
_[sS][nN][dD][lL][eE][nN]                                   {	printf("_SNDLEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLEN; }
_[sS][nN][dD][vV][oO][lL]                                   {	printf("_SNDVOL => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDVOL; }
[oO][nN]{ws}+[gG][oO][sS][uU][bB]                           {	printf("ON GOSUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_GOSUB; }
[oO][nN]{ws}+[tT][iI][mM][eE][rR]                           {	printf("ON TIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_TIMER; }
[oO][nN]{ws}+[eE][rR][rR][oO][rR]                           {	printf("ON ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_ERROR; }
_[sS][nN][dD][rR][aA][tT][eE]                               {	printf("_SNDRATE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRATE; }
[lL][tT][rR][iI][mM]\$                                      {	printf("LTRIM$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LTRIM_DS; }
[oO][nN]{ws}+[sS][tT][rR][iI][gG]                           {	printf("ON STRIG => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_STRIG; }
_[sS][nN][dD][pP][lL][aA][yY]                               {	printf("_SNDPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAY; }
[gG][eE][tT]{ws}+[qQ][bB]64                                 {	printf("GET QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET_QB64; }
[gG][eE][tT]{ws}+[fF][iI][lL][eE]                           {	printf("GET FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET_FILE; }
[fF][rR][eE][eE][fF][iI][lL][eE]                            {	printf("FREEFILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FREEFILE; }
[iI][nN][kK][eE][yY]\$                                      {	printf("INKEY$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_INKEY_DS; }
[iI][nN][pP][uU][tT]\$                                      {	printf("INPUT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_DS; }
[lL][cC][aA][sS][eE]\$                                      {	printf("LCASE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LCASE_DS; }
[kK][eE][yY]{ws}+[lL][iI][sS][tT]                           {	printf("KEY LIST => %s\n", yytext); nchar += yyleng; return ENUM_QB_KEY_LIST; }
[iI][oO][cC][tT][lL]\$                                      {	printf("IOCTL$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_IOCTL_DS; }
_glHint                                                     {	printf("_glHint => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glHint; }
_glFogf                                                     {	printf("_glFogf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogf; }
[sS][pP][aA][cC][eE]\$                                      {	printf("SPACE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_SPACE_DS; }
_[gG][rR][eE][eE][nN]32                                     {	printf("_GREEN32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__GREEN32; }
_[kK][eE][yY][dD][oO][wW][nN]                               {	printf("_KEYDOWN => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYDOWN; }
_[sS][tT][rR][iI][cC][mM][pP]                               {	printf("_STRICMP => %s\n", yytext); nchar += yyleng; return ENUM_QB__STRICMP; }
_[aA][lL][pP][hH][aA]32                                     {	printf("_ALPHA32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__ALPHA32; }
_[dD][eE][vV][iI][cC][eE][sS]                               {	printf("_DEVICES => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICES; }
[aA][bB][sS][oO][lL][uU][tT][eE]                            {	printf("ABSOLUTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ABSOLUTE; }
[uU][cC][aA][sS][eE]\$                                      {	printf("UCASE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_UCASE_DS; }
[rR][tT][rR][iI][mM]\$                                      {	printf("RTRIM$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_RTRIM_DS; }
[rR][iI][gG][hH][tT]\$                                      {	printf("RIGHT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_RIGHT_DS; }
_[sS][nN][dD][sS][tT][oO][pP]                               {	printf("_SNDSTOP => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDSTOP; }
[fF][oO][rR]{ws}+[fF][iI][lL][eE]                           {	printf("FOR FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FOR_FILE; }
[nN][eE][wW]{ws}+[lL][iI][nN][eE]                           {	printf("NEW LINE => %s\n", yytext); nchar += yyleng; return ENUM_QB_NEW_LINE; }
_[mM][eE][mM][fF][rR][eE][eE]                               {	printf("_MEMFREE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMFREE; }
_[mM][eE][mM][fF][iI][lL][lL]                               {	printf("_MEMFILL => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMFILL; }
_[mM][eE][mM][cC][oO][pP][yY]                               {	printf("_MEMCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMCOPY; }
[pP][uU][tT]{ws}+[qQ][bB]64                                 {	printf("PUT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_QB64; }
[pP][uU][tT]{ws}+[fF][iI][lL][eE]                           {	printf("PUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_FILE; }
[oO][pP][eE][nN]{ws}+[cC][oO][mM]                           {	printf("OPEN COM => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPEN_COM; }
_glFogi                                                     {	printf("_glFogi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogi; }
_[sS][nN][dD][lL][oO][oO][pP]                               {	printf("_SNDLOOP => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLOOP; }
_[sS][nN][dD][cC][oO][pP][yY]                               {	printf("_SNDCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDCOPY; }
_[cC][oO][nN][sS][oO][lL][eE]                               {	printf("_CONSOLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONSOLE; }
[fF][iI][lL][eE][aA][tT][tT][rR]                            {	printf("FILEATTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_FILEATTR; }
[eE][nN][dD]{ws}+[tT][yY][pP][eE]                           {	printf("END TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB_END_TYPE; }
_[sS][cC][rR][eE][eE][nN][yY]                               {	printf("_SCREENY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENY; }
[eE][rR][dD][eE][vV]\$                                      {	printf("ERDEV$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERDEV_DS; }
_[sS][cC][rR][eE][eE][nN][xX]                               {	printf("_SCREENX => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENX; }
_[sS][nN][dD][oO][pP][eE][nN]                               {	printf("_SNDOPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDOPEN; }
_[fF][rR][eE][eE][fF][oO][nN][tT]                           {	printf("_FREEFONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREEFONT; }
_[dD][oO][nN][tT][wW][aA][iI][tT]                           {	printf("_DONTWAIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DONTWAIT; }
_glFlush                                                    {	printf("_glFlush => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFlush; }
_glMap1f                                                    {	printf("_glMap1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap1f; }
_glRectf                                                    {	printf("_glRectf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectf; }
_[sS][eE][tT][aA][lL][pP][hH][aA]                           {	printf("_SETALPHA => %s\n", yytext); nchar += yyleng; return ENUM_QB__SETALPHA; }
_glMap2d                                                    {	printf("_glMap2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap2d; }
_[oO][pP][eE][nN][hH][oO][sS][tT]                           {	printf("_OPENHOST => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENHOST; }
_glRects                                                    {	printf("_glRects => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRects; }
_glAccum                                                    {	printf("_glAccum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAccum; }
\$[eE][lL][sS][eE][iI][fF]                                  {	printf("$ELSEIF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSEIF; }
_glClear                                                    {	printf("_glClear => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClear; }
_glFogiv                                                    {	printf("_glFogiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogiv; }
[oO][nN]{ws}+[uU][eE][vV][eE][nN][tT]                       {	printf("ON UEVENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_UEVENT; }
_glOrtho                                                    {	printf("_glOrtho => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glOrtho; }
\$[sS][tT][aA][tT][iI][cC]                                  {	printf("$STATIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_STATIC; }
[mM][kK][sS][mM][bB][fF]\$                                  {	printf("MKSMBF$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKSMBF_DS; }
_[sS][nN][dD][lL][iI][mM][iI][tT]                           {	printf("_SNDLIMIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLIMIT; }
_[nN][eE][wW][iI][mM][aA][gG][eE]                           {	printf("_NEWIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__NEWIMAGE; }
_[kK][eE][yY][cC][lL][eE][aA][rR]                           {	printf("_KEYCLEAR => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYCLEAR; }
[mM][kK][dD][mM][bB][fF]\$                                  {	printf("MKDMBF$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKDMBF_DS; }
_glFogfv                                                    {	printf("_glFogfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogfv; }
_glMap1d                                                    {	printf("_glMap1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap1d; }
_[mM][eE][mM][iI][mM][aA][gG][eE]                           {	printf("_MEMIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMIMAGE; }
_[sS][nN][dD][pP][aA][uU][sS][eE]                           {	printf("_SNDPAUSE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPAUSE; }
_[pP][uU][tT][iI][mM][aA][gG][eE]                           {	printf("_PUTIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PUTIMAGE; }
_glRecti                                                    {	printf("_glRecti => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRecti; }
_glBegin                                                    {	printf("_glBegin => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBegin; }
\$[rR][eE][sS][iI][zZ][eE]                                  {	printf("$RESIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_RESIZE; }
[vV][aA][rR][pP][tT][rR]\$                                  {	printf("VARPTR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARPTR_DS; }
_[lL][oO][aA][dD][fF][oO][nN][tT]                           {	printf("_LOADFONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__LOADFONT; }
[cC][aA][sS][eE]{ws}+[eE][lL][sS][eE]                       {	printf("CASE ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE_ELSE; }
_glRectd                                                    {	printf("_glRectd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectd; }
_[sS][nN][dD][cC][lL][oO][sS][eE]                           {	printf("_SNDCLOSE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDCLOSE; }
_[pP][rR][eE][sS][eE][rR][vV][eE]                           {	printf("_PRESERVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRESERVE; }
[rR][aA][nN][dD][oO][mM][iI][zZ][eE]                        {	printf("RANDOMIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOMIZE; }
_[uU][nN][sS][iI][gG][nN][eE][dD]                           {	printf("_UNSIGNED => %s\n", yytext); nchar += yyleng; return ENUM_QB__UNSIGNED; }
_glMap2f                                                    {	printf("_glMap2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap2f; }
_[lL][aA][sS][tT][aA][xX][iI][sS]                           {	printf("_LASTAXIS => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTAXIS; }
[sS][tT][rR][iI][nN][gG]\$                                  {	printf("STRING$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING_DS; }
[iI][nN][tT][eE][rR][rR][uU][pP][tT]                        {	printf("INTERRUPT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTERRUPT; }
_[iI][nN][tT][eE][gG][eE][rR]64                             {	printf("_INTEGER64 => %s\n", yytext); nchar += yyleng; return ENUM_QB__INTEGER64; }
_[mM][eE][mM][eE][xX][iI][sS][tT][sS]                       {	printf("_MEMEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMEXISTS; }
_[sS][nN][dD][gG][eE][tT][pP][oO][sS]                       {	printf("_SNDGETPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDGETPOS; }
[wW][hH][iI][lL][eE]{ws}+[wW][eE][nN][dD]                   {	printf("WHILE WEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHILE_WEND; }
[eE][nN][vV][iI][rR][oO][nN]\$                              {	printf("ENVIRON$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_ENVIRON_DS; }
_glEnable                                                   {	printf("_glEnable => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnable; }
_[lL][aA][sS][tT][wW][hH][eE][eE][lL]                       {	printf("_LASTWHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTWHEEL; }
_glFinish                                                   {	printf("_glFinish => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFinish; }
_[cC][oO][pP][yY][iI][mM][aA][gG][eE]                       {	printf("_COPYIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__COPYIMAGE; }
_[dD][eE][vV][iI][cC][eE]\$                                 {	printf("_DEVICE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICE_DS; }
_[sS][nN][dD][rR][aA][wW][lL][eE][nN]                       {	printf("_SNDRAWLEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAWLEN; }
_[dD][oO][nN][tT][bB][lL][eE][nN][dD]                       {	printf("_DONTBLEND => %s\n", yytext); nchar += yyleng; return ENUM_QB__DONTBLEND; }
[pP][rR][iI][nN][tT]{ws}+[qQ][bB]64                         {	printf("PRINT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_QB64; }
_[sS][hH][eE][lL][lL][hH][iI][dD][eE]                       {	printf("_SHELLHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SHELLHIDE; }
[pP][rR][iI][nN][tT]{ws}+[fF][iI][lL][eE]                   {	printf("PRINT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_FILE; }
_[dD][iI][rR][eE][xX][iI][sS][tT][sS]                       {	printf("_DIREXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__DIREXISTS; }
[vV][iI][eE][wW]{ws}+[pP][rR][iI][nN][tT]                   {	printf("VIEW PRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_VIEW_PRINT; }
\$[dD][yY][nN][aA][mM][iI][cC]                              {	printf("$DYNAMIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_DYNAMIC; }
[sS][hH][eE][lL][lL]{ws}+[qQ][bB]64                         {	printf("SHELL QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHELL_QB64; }
_[sS][nN][dD][sS][eE][tT][pP][oO][sS]                       {	printf("_SNDSETPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDSETPOS; }
_[mM][oO][uU][sS][eE][sS][hH][oO][wW]                       {	printf("_MOUSESHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSESHOW; }
_glIndexi                                                   {	printf("_glIndexi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexi; }
[iI][nN][tT][eE][rR][rR][uU][pP][tT][xX]                    {	printf("INTERRUPTX => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTERRUPTX; }
_[sS][nN][dD][pP][aA][uU][sS][eE][dD]                       {	printf("_SNDPAUSED => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPAUSED; }
\$[cC][oO][nN][sS][oO][lL][eE]                              {	printf("$CONSOLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_CONSOLE; }
_glIndexf                                                   {	printf("_glIndexf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexf; }
[lL][iI][nN][eE]{ws}+[iI][nN][pP][uU][tT]                   {	printf("LINE INPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE_INPUT; }
_[pP][iI][xX][eE][lL][sS][iI][zZ][eE]                       {	printf("_PIXELSIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PIXELSIZE; }
_[eE][rR][rR][oO][rR][lL][iI][nN][eE]                       {	printf("_ERRORLINE => %s\n", yytext); nchar += yyleng; return ENUM_QB__ERRORLINE; }
_glIndexs                                                   {	printf("_glIndexs => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexs; }
_glLightf                                                   {	printf("_glLightf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightf; }
_[cC][oO][nN][nN][eE][cC][tT][eE][dD]                       {	printf("_CONNECTED => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONNECTED; }
_glRectdv                                                   {	printf("_glRectdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectdv; }
_glRectfv                                                   {	printf("_glRectfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectfv; }
_glIsList                                                   {	printf("_glIsList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsList; }
[iI][nN][pP][uU][tT]{ws}+[qQ][bB]64                         {	printf("INPUT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_QB64; }
_glIndexd                                                   {	printf("_glIndexd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexd; }
[cC][oO][mM][mM][aA][nN][dD]\$                              {	printf("COMMAND$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_COMMAND_DS; }
_[fF][rR][eE][eE][tT][iI][mM][eE][rR]                       {	printf("_FREETIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREETIMER; }
_glRectiv                                                   {	printf("_glRectiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectiv; }
_[fF][rR][eE][eE][iI][mM][aA][gG][eE]                       {	printf("_FREEIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREEIMAGE; }
_[lL][oO][aA][dD][iI][mM][aA][gG][eE]                       {	printf("_LOADIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__LOADIMAGE; }
[wW][rR][iI][tT][eE]{ws}+[fF][iI][lL][eE]                   {	printf("WRITE FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WRITE_FILE; }
_[mM][oO][uU][sS][eE][hH][iI][dD][eE]                       {	printf("_MOUSEHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEHIDE; }
_[mM][oO][uU][sS][eE][mM][oO][vV][eE]                       {	printf("_MOUSEMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVE; }
_glScalef                                                   {	printf("_glScalef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScalef; }
_glBitmap                                                   {	printf("_glBitmap => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBitmap; }
_glLighti                                                   {	printf("_glLighti => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLighti; }
_glScaled                                                   {	printf("_glScaled => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScaled; }
\$[eE][lL][sS][eE]{ws}+[iI][fF]                             {	printf("$ELSE IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSE_IF; }
_glRectsv                                                   {	printf("_glRectsv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectsv; }
_[fF][oO][nN][tT][wW][iI][dD][tT][hH]                       {	printf("_FONTWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONTWIDTH; }
_glColor4i                                                  {	printf("_glColor4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4i; }
_glColor4b                                                  {	printf("_glColor4b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4b; }
_[fF][oO][nN][tT][hH][eE][iI][gG][hH][tT]                   {	printf("_FONTHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONTHEIGHT; }
_glColor3i                                                  {	printf("_glColor3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3i; }
_glPopName                                                  {	printf("_glPopName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopName; }
_glColor3f                                                  {	printf("_glColor3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3f; }
_[fF][iI][lL][eE][eE][xX][iI][sS][tT][sS]                   {	printf("_FILEEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__FILEEXISTS; }
_glColor4f                                                  {	printf("_glColor4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4f; }
[sS][eE][lL][eE][cC][tT]{ws}+[cC][aA][sS][eE]               {	printf("SELECT CASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SELECT_CASE; }
_[lL][aA][sS][tT][bB][uU][tT][tT][oO][nN]                   {	printf("_LASTBUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTBUTTON; }
_glTexGenf                                                  {	printf("_glTexGenf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGenf; }
_glColor4d                                                  {	printf("_glColor4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4d; }
_glColor3s                                                  {	printf("_glColor3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3s; }
_glTexGend                                                  {	printf("_glTexGend => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGend; }
[oO][pP][tT][iI][oO][nN]{ws}+[bB][aA][sS][eE]               {	printf("OPTION BASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPTION_BASE; }
_[mM][oO][uU][sS][eE][wW][hH][eE][eE][lL]                   {	printf("_MOUSEWHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEWHEEL; }
_glScissor                                                  {	printf("_glScissor => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScissor; }
_glRotatef                                                  {	printf("_glRotatef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRotatef; }
_glIndexub                                                  {	printf("_glIndexub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexub; }
_glFrustum                                                  {	printf("_glFrustum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFrustum; }
_[sS][cC][rR][eE][eE][nN][sS][hH][oO][wW]                   {	printf("_SCREENSHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENSHOW; }
_[mM][oO][uU][sS][eE][iI][nN][pP][uU][tT]                   {	printf("_MOUSEINPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEINPUT; }
_[sS][nN][dD][pP][lL][aA][yY][iI][nN][gG]                   {	printf("_SNDPLAYING => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYING; }
_glRotated                                                  {	printf("_glRotated => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRotated; }
_[oO][pP][eE][nN][cC][lL][iI][eE][nN][tT]                   {	printf("_OPENCLIENT => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENCLIENT; }
_glIndexiv                                                  {	printf("_glIndexiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexiv; }
_glLightfv                                                  {	printf("_glLightfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightfv; }
_glIndexsv                                                  {	printf("_glIndexsv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexsv; }
_glIndexfv                                                  {	printf("_glIndexfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexfv; }
_[pP][rR][iI][nN][tT][iI][mM][aA][gG][eE]                   {	printf("_PRINTIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTIMAGE; }
_glIndexdv                                                  {	printf("_glIndexdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexdv; }
\$[cC][hH][eE][cC][kK][iI][nN][gG]                          {	printf("$CHECKING => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_CHECKING; }
_glLightiv                                                  {	printf("_glLightiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightiv; }
_glTexEnvf                                                  {	printf("_glTexEnvf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvf; }
_[sS][cC][rR][eE][eE][nN][mM][oO][vV][eE]                   {	printf("_SCREENMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENMOVE; }
_[mM][eE][mM][eE][lL][eE][mM][eE][nN][tT]                   {	printf("_MEMELEMENT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMELEMENT; }
_glTexGeni                                                  {	printf("_glTexGeni => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGeni; }
_[pP][rR][iI][nN][tT][wW][iI][dD][tT][hH]                   {	printf("_PRINTWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTWIDTH; }
_glColor3d                                                  {	printf("_glColor3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3d; }
_[sS][nN][dD][oO][pP][eE][nN][rR][aA][wW]                   {	printf("_SNDOPENRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDOPENRAW; }
_glColor4s                                                  {	printf("_glColor4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4s; }
[wW][hH][iI][tT][eE]{ws}+[sS][pP][aA][cC][eE]               {	printf("WHITE SPACE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHITE_SPACE; }
[pP][rR][iI][nN][tT]{ws}+[uU][sS][iI][nN][gG]               {	printf("PRINT USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_USING; }
_glNewList                                                  {	printf("_glNewList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNewList; }
_glTexEnvi                                                  {	printf("_glTexEnvi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvi; }
_glLogicOp                                                  {	printf("_glLogicOp => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLogicOp; }
_glColor3b                                                  {	printf("_glColor3b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3b; }
_[sS][nN][dD][rR][aA][wW][dD][oO][nN][eE]                   {	printf("_SNDRAWDONE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAWDONE; }
_[sS][cC][rR][eE][eE][nN][hH][iI][dD][eE]                   {	printf("_SCREENHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENHIDE; }
_glDisable                                                  {	printf("_glDisable => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDisable; }
_glEndList                                                  {	printf("_glEndList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEndList; }
_glColor3fv                                                 {	printf("_glColor3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3fv; }
_glPushName                                                 {	printf("_glPushName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushName; }
_glColor3dv                                                 {	printf("_glColor3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3dv; }
_glColor3bv                                                 {	printf("_glColor3bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3bv; }
_glCallList                                                 {	printf("_glCallList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCallList; }
_glEdgeFlag                                                 {	printf("_glEdgeFlag => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlag; }
_glNormal3b                                                 {	printf("_glNormal3b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3b; }
_glLoadName                                                 {	printf("_glLoadName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadName; }
_glCullFace                                                 {	printf("_glCullFace => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCullFace; }
_glNormal3d                                                 {	printf("_glNormal3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3d; }
_glColor4us                                                 {	printf("_glColor4us => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4us; }
_glListBase                                                 {	printf("_glListBase => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glListBase; }
_glGenLists                                                 {	printf("_glGenLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGenLists; }
_glGetMapiv                                                 {	printf("_glGetMapiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapiv; }
_glIndexubv                                                 {	printf("_glIndexubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexubv; }
_glGetMapfv                                                 {	printf("_glGetMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapfv; }
_glGetMapdv                                                 {	printf("_glGetMapdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapdv; }
_glGetError                                                 {	printf("_glGetError => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetError; }
_glColor4ui                                                 {	printf("_glColor4ui => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ui; }
_glColor4ub                                                 {	printf("_glColor4ub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ub; }
_glColor3us                                                 {	printf("_glColor3us => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3us; }
_glColor4bv                                                 {	printf("_glColor4bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4bv; }
_glColor3ui                                                 {	printf("_glColor3ui => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ui; }
_glColor3ub                                                 {	printf("_glColor3ub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ub; }
_glColor3sv                                                 {	printf("_glColor3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3sv; }
_glNormal3s                                                 {	printf("_glNormal3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3s; }
_glNormal3i                                                 {	printf("_glNormal3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3i; }
_glNormal3f                                                 {	printf("_glNormal3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3f; }
_glColor4sv                                                 {	printf("_glColor4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4sv; }
_glColor4iv                                                 {	printf("_glColor4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4iv; }
_glColor4fv                                                 {	printf("_glColor4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4fv; }
_glColor4dv                                                 {	printf("_glColor4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4dv; }
_glColor3iv                                                 {	printf("_glColor3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3iv; }
_glViewport                                                 {	printf("_glViewport => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glViewport; }
[bB][iI][tT]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]           {	printf("BIT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BIT_VARIABLE; }
_glTexGenfv                                                 {	printf("_glTexGenfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGenfv; }
_[pP][rR][iI][nN][tT][sS][tT][rR][iI][nN][gG]               {	printf("_PRINTSTRING => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTSTRING; }
_glVertex3d                                                 {	printf("_glVertex3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3d; }
[pP][uU][tT]{ws}+[gG][rR][aA][pP][hH][iI][cC][sS]           {	printf("PUT GRAPHICS => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_GRAPHICS; }
[nN][oO][tT]{ws}+[eE][qQ][uU][aA][lL]{ws}+[tT][oO]          {	printf("NOT EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_NOT_EQUAL_TO; }
_[sS][cC][rR][eE][eE][nN][cC][lL][iI][cC][kK]               {	printf("_SCREENCLICK => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENCLICK; }
_glVertex4i                                                 {	printf("_glVertex4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4i; }
_glVertex4s                                                 {	printf("_glVertex4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4s; }
_glVertex2s                                                 {	printf("_glVertex2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2s; }
_[sS][tT][aA][rR][tT][dD][iI][rR]\$                         {	printf("_STARTDIR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__STARTDIR_DS; }
_[aA][uU][tT][oO][dD][iI][sS][pP][lL][aA][yY]               {	printf("_AUTODISPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__AUTODISPLAY; }
_[mM][aA][pP][tT][rR][iI][aA][nN][gG][lL][eE]               {	printf("_MAPTRIANGLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MAPTRIANGLE; }
_glVertex3f                                                 {	printf("_glVertex3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3f; }
_[sS][nN][dD][pP][lL][aA][yY][fF][iI][lL][eE]               {	printf("_SNDPLAYFILE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYFILE; }
_glTexEnvfv                                                 {	printf("_glTexEnvfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvfv; }
_glVertex3s                                                 {	printf("_glVertex3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3s; }
_[mM][oO][uU][sS][eE][bB][uU][tT][tT][oO][nN]               {	printf("_MOUSEBUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEBUTTON; }
_glVertex4d                                                 {	printf("_glVertex4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4d; }
_[sS][nN][dD][pP][lL][aA][yY][cC][oO][pP][yY]               {	printf("_SNDPLAYCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYCOPY; }
_glVertex3i                                                 {	printf("_glVertex3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3i; }
_glVertex4f                                                 {	printf("_glVertex4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4f; }
_[oO][fF][fF][sS][eE][tT]{ws}+[tT][yY][pP][eE]              {	printf("_OFFSET TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB__OFFSET_TYPE; }
[lL][pP][rR][iI][nN][tT]{ws}+[uU][sS][iI][nN][gG]           {	printf("LPRINT USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPRINT_USING; }
_glTexGeniv                                                 {	printf("_glTexGeniv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGeniv; }
_glTexGendv                                                 {	printf("_glTexGendv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGendv; }
_[rR][eE][sS][iI][zZ][eE][wW][iI][dD][tT][hH]               {	printf("_RESIZEWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZEWIDTH; }
[wW][rR][iI][tT][eE]{ws}+[sS][cC][rR][eE][eE][nN]           {	printf("WRITE SCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_WRITE_SCREEN; }
_[dD][eE][pP][tT][hH][bB][uU][fF][fF][eE][rR]               {	printf("_DEPTHBUFFER => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEPTHBUFFER; }
_[sS][cC][rR][eE][eE][nN][iI][mM][aA][gG][eE]               {	printf("_SCREENIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENIMAGE; }
_glVertex2f                                                 {	printf("_glVertex2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2f; }
_[sS][cC][rR][eE][eE][nN][pP][rR][iI][nN][tT]               {	printf("_SCREENPRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENPRINT; }
_[dD][eE][vV][iI][cC][eE][iI][nN][pP][uU][tT]               {	printf("_DEVICEINPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICEINPUT; }
_[cC][oO][pP][yY][pP][aA][lL][eE][tT][tT][eE]               {	printf("_COPYPALETTE => %s\n", yytext); nchar += yyleng; return ENUM_QB__COPYPALETTE; }
_glVertex2i                                                 {	printf("_glVertex2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2i; }
_glVertex2d                                                 {	printf("_glVertex2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2d; }
_glTexEnviv                                                 {	printf("_glTexEnviv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnviv; }
_glNormal3iv                                                {	printf("_glNormal3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3iv; }
_glVertex3iv                                                {	printf("_glVertex3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3iv; }
_glPopMatrix                                                {	printf("_glPopMatrix => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopMatrix; }
_glNormal3fv                                                {	printf("_glNormal3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3fv; }
_glIndexMask                                                {	printf("_glIndexMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexMask; }
_[bB][uU][tT][tT][oO][nN][cC][hH][aA][nN][gG][eE]           {	printf("_BUTTONCHANGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BUTTONCHANGE; }
_glVertex2dv                                                {	printf("_glVertex2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2dv; }
_glStencilOp                                                {	printf("_glStencilOp => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilOp; }
_glFrontFace                                                {	printf("_glFrontFace => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFrontFace; }
_glVertex3sv                                                {	printf("_glVertex3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3sv; }
_glPopAttrib                                                {	printf("_glPopAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopAttrib; }
[pP][aA][lL][eE][tT][tT][eE]{ws}+[uU][sS][iI][nN][gG]       {	printf("PALETTE USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_PALETTE_USING; }
_glVertex2fv                                                {	printf("_glVertex2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2fv; }
_glVertex3fv                                                {	printf("_glVertex3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3fv; }
_glNormal3sv                                                {	printf("_glNormal3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3sv; }
_glPixelZoom                                                {	printf("_glPixelZoom => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelZoom; }
_glPointSize                                                {	printf("_glPointSize => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPointSize; }
_glGetString                                                {	printf("_glGetString => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetString; }
_glVertex3dv                                                {	printf("_glVertex3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3dv; }
_glMapGrid2f                                                {	printf("_glMapGrid2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid2f; }
_glMaterialf                                                {	printf("_glMaterialf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialf; }
_glMateriali                                                {	printf("_glMateriali => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMateriali; }
_[cC][oO][nN][sS][oO][lL][eE][tT][iI][tT][lL][eE]           {	printf("_CONSOLETITLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONSOLETITLE; }
_glLineWidth                                                {	printf("_glLineWidth => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLineWidth; }
_[sS][cC][rR][eE][eE][nN][eE][xX][iI][sS][tT][sS]           {	printf("_SCREENEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENEXISTS; }
_glMapGrid1f                                                {	printf("_glMapGrid1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid1f; }
_glVertex2sv                                                {	printf("_glVertex2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2sv; }
\$[sS][cC][rR][eE][eE][nN][hH][iI][dD][eE]                  {	printf("$SCREENHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_SCREENHIDE; }
_glMapGrid2d                                                {	printf("_glMapGrid2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid2d; }
[pP][eE][nN]                                                {	printf("PEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_PEN_STATEMENT; }
_[rR][eE][sS][iI][zZ][eE][hH][eE][iI][gG][hH][tT]           {	printf("_RESIZEHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZEHEIGHT; }
_glNormal3bv                                                {	printf("_glNormal3bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3bv; }
_glMapGrid1d                                                {	printf("_glMapGrid1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid1d; }
[kK][eE][yY]                                                {	printf("KEY => %s\n", yytext); nchar += yyleng; return ENUM_QB_KEY_STATEMENT; }
_glNormal3dv                                                {	printf("_glNormal3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3dv; }
_glInitNames                                                {	printf("_glInitNames => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glInitNames; }
_glIsEnabled                                                {	printf("_glIsEnabled => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsEnabled; }
[lL][oO][nN][gG]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]       {	printf("LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }
_[cC][oO][mM][mM][aA][nN][dD][cC][oO][uU][nN][tT]           {	printf("_COMMANDCOUNT => %s\n", yytext); nchar += yyleng; return ENUM_QB__COMMANDCOUNT; }
_glIsTexture                                                {	printf("_glIsTexture => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsTexture; }
[bB][yY][tT][eE]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]       {	printf("BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BYTE_VARIABLE; }
\$[sS][cC][rR][eE][eE][nN][sS][hH][oO][wW]                  {	printf("$SCREENSHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_SCREENSHOW; }
_glGetFloatv                                                {	printf("_glGetFloatv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetFloatv; }
_glColor4uiv                                                {	printf("_glColor4uiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4uiv; }
_glColor4ubv                                                {	printf("_glColor4ubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ubv; }
_glVertex4fv                                                {	printf("_glVertex4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4fv; }
_glColor4usv                                                {	printf("_glColor4usv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4usv; }
_glColorMask                                                {	printf("_glColorMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorMask; }
_glEdgeFlagv                                                {	printf("_glEdgeFlagv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlagv; }
_glVertex4dv                                                {	printf("_glVertex4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4dv; }
_glDepthMask                                                {	printf("_glDepthMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthMask; }
[cC][aA][lL][lL]{ws}+[aA][bB][sS][oO][lL][uU][tT][eE]       {	printf("CALL ABSOLUTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALL_ABSOLUTE; }
_glVertex2iv                                                {	printf("_glVertex2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2iv; }
_[dD][eE][fF][aA][uU][lL][tT][cC][oO][lL][oO][rR]           {	printf("_DEFAULTCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEFAULTCOLOR; }
_[dD][iI][sS][pP][lL][aA][yY][oO][rR][dD][eE][rR]           {	printf("_DISPLAYORDER => %s\n", yytext); nchar += yyleng; return ENUM_QB__DISPLAYORDER; }
_glClipPlane                                                {	printf("_glClipPlane => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClipPlane; }
_glVertex4sv                                                {	printf("_glVertex4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4sv; }
_glColor3ubv                                                {	printf("_glColor3ubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ubv; }
_glVertex4iv                                                {	printf("_glVertex4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4iv; }
_glColor3usv                                                {	printf("_glColor3usv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3usv; }
_glColor3uiv                                                {	printf("_glColor3uiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3uiv; }
_glDepthFunc                                                {	printf("_glDepthFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthFunc; }
_glCallLists                                                {	printf("_glCallLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCallLists; }
_glEvalMesh1                                                {	printf("_glEvalMesh1 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalMesh1; }
_glEvalMesh2                                                {	printf("_glEvalMesh2 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalMesh2; }
_[dD][eE][sS][kK][tT][oO][pP][wW][iI][dD][tT][hH]           {	printf("_DESKTOPWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__DESKTOPWIDTH; }
_glAlphaFunc                                                {	printf("_glAlphaFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAlphaFunc; }
_glBlendFunc                                                {	printf("_glBlendFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBlendFunc; }
[fF][lL][oO][aA][tT]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]   {	printf("FLOAT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }
[sS][eE][eE][kK]                                            {	printf("SEEK => %s\n", yytext); nchar += yyleng; return ENUM_QB_SEEK_STATEMENT; }
_glClearColor                                               {	printf("_glClearColor => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearColor; }
_glReadBuffer                                               {	printf("_glReadBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glReadBuffer; }
_glClearAccum                                               {	printf("_glClearAccum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearAccum; }
_glClearDepth                                               {	printf("_glClearDepth => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearDepth; }
_glReadPixels                                               {	printf("_glReadPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glReadPixels; }
_glTexCoord1s                                               {	printf("_glTexCoord1s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1s; }
[nN][eE][xX][tT]                                            {	printf("NEXT => %s\n", yytext); nchar += yyleng; return ENUM_QB_NEXT_STATEMENT; }
_glTexCoord3d                                               {	printf("_glTexCoord3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3d; }
_glGetDoublev                                               {	printf("_glGetDoublev => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetDoublev; }
_glTexCoord2d                                               {	printf("_glTexCoord2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2d; }
_[mM][eE][mM]                                               {	printf("_MEM => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEM_STATEMENT; }
_glPushMatrix                                               {	printf("_glPushMatrix => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushMatrix; }
_glTexCoord2i                                               {	printf("_glTexCoord2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2i; }
_glMatrixMode                                               {	printf("_glMatrixMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMatrixMode; }
_glMaterialiv                                               {	printf("_glMaterialiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialiv; }
_glClearIndex                                               {	printf("_glClearIndex => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearIndex; }
_glTexCoord4s                                               {	printf("_glTexCoord4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4s; }
_glEvalPoint1                                               {	printf("_glEvalPoint1 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalPoint1; }
_glMaterialfv                                               {	printf("_glMaterialfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialfv; }
_glTexCoord2f                                               {	printf("_glTexCoord2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2f; }
_glEvalPoint2                                               {	printf("_glEvalPoint2 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalPoint2; }
_glPushAttrib                                               {	printf("_glPushAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushAttrib; }
[lL][oO][oO][pP]                                            {	printf("LOOP => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOOP_STATEMENT; }
_[dD][eE][sS][kK][tT][oO][pP][hH][eE][iI][gG][hH][tT]       {	printf("_DESKTOPHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DESKTOPHEIGHT; }
_glTexCoord2s                                               {	printf("_glTexCoord2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2s; }
_glTexCoord4i                                               {	printf("_glTexCoord4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4i; }
_glDrawPixels                                               {	printf("_glDrawPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawPixels; }
_glGetLightiv                                               {	printf("_glGetLightiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetLightiv; }
_glRenderMode                                               {	printf("_glRenderMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRenderMode; }
_glTexCoord3i                                               {	printf("_glTexCoord3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3i; }
_glDrawArrays                                               {	printf("_glDrawArrays => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawArrays; }
[pP][lL][aA][yY]                                            {	printf("PLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB_PLAY_STATEMENT; }
_[mM][oO][uU][sS][eE][pP][iI][pP][eE][oO][pP][eE][nN]       {	printf("_MOUSEPIPEOPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEPIPEOPEN; }
_glTexImage1D                                               {	printf("_glTexImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexImage1D; }
_glTexCoord1f                                               {	printf("_glTexCoord1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1f; }
_glTexCoord1i                                               {	printf("_glTexCoord1i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1i; }
_glTexCoord1d                                               {	printf("_glTexCoord1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1d; }
_glTexCoord3f                                               {	printf("_glTexCoord3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3f; }
_glShadeModel                                               {	printf("_glShadeModel => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glShadeModel; }
_glDepthRange                                               {	printf("_glDepthRange => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthRange; }
_glDrawBuffer                                               {	printf("_glDrawBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawBuffer; }
_glTexCoord4f                                               {	printf("_glTexCoord4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4f; }
_glTexCoord4d                                               {	printf("_glTexCoord4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4d; }
_glTranslated                                               {	printf("_glTranslated => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTranslated; }
_glTranslatef                                               {	printf("_glTranslatef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTranslatef; }
_glCopyPixels                                               {	printf("_glCopyPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyPixels; }
_glPixelMapfv                                               {	printf("_glPixelMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapfv; }
_glTexCoord3s                                               {	printf("_glTexCoord3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3s; }
_glTexImage2D                                               {	printf("_glTexImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexImage2D; }
_glGetLightfv                                               {	printf("_glGetLightfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetLightfv; }
[sS][iI][nN][gG][lL][eE]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("SINGLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE_VARIABLE; }
_glRasterPos2f                                              {	printf("_glRasterPos2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2f; }
_glRasterPos3s                                              {	printf("_glRasterPos3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3s; }
_glRasterPos2d                                              {	printf("_glRasterPos2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2d; }
_glRasterPos3i                                              {	printf("_glRasterPos3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3i; }
_glTexCoord4sv                                              {	printf("_glTexCoord4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4sv; }
_glRasterPos3d                                              {	printf("_glRasterPos3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3d; }
_glRasterPos3f                                              {	printf("_glRasterPos3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3f; }
_glRasterPos2s                                              {	printf("_glRasterPos2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2s; }
_glRasterPos2i                                              {	printf("_glRasterPos2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2i; }
_glTexCoord4iv                                              {	printf("_glTexCoord4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4iv; }
_glTexCoord3dv                                              {	printf("_glTexCoord3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3dv; }
_glTexCoord1fv                                              {	printf("_glTexCoord1fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1fv; }
_glTexCoord1dv                                              {	printf("_glTexCoord1dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1dv; }
_glStencilMask                                              {	printf("_glStencilMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilMask; }
_glTexCoord1iv                                              {	printf("_glTexCoord1iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1iv; }
_glTexCoord2sv                                              {	printf("_glTexCoord2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2sv; }
_glTexCoord2dv                                              {	printf("_glTexCoord2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2dv; }
_glTexCoord2fv                                              {	printf("_glTexCoord2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2fv; }
_glTexCoord2iv                                              {	printf("_glTexCoord2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2iv; }
_glTexCoord1sv                                              {	printf("_glTexCoord1sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1sv; }
_glStencilFunc                                              {	printf("_glStencilFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilFunc; }
_glTexCoord3fv                                              {	printf("_glTexCoord3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3fv; }
_glRasterPos4i                                              {	printf("_glRasterPos4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4i; }
[dD][oO][uU][bB][lL][eE]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("DOUBLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE_VARIABLE; }
_glRasterPos4f                                              {	printf("_glRasterPos4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4f; }
_glRasterPos4d                                              {	printf("_glRasterPos4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4d; }
_glRasterPos4s                                              {	printf("_glRasterPos4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4s; }
[oO][fF][fF][sS][eE][tT]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_OFFSET_VARIABLE; }
_glTexCoord3iv                                              {	printf("_glTexCoord3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3iv; }
_glTexCoord3sv                                              {	printf("_glTexCoord3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3sv; }
_glTexCoord4dv                                              {	printf("_glTexCoord4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4dv; }
_glTexCoord4fv                                              {	printf("_glTexCoord4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4fv; }
[sS][tT][rR][iI][nN][gG]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("STRING VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING_VARIABLE; }
_[fF][oO][nN][tT]                                           {	printf("_FONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONT_STATEMENT; }
_glGetTexEnvfv                                              {	printf("_glGetTexEnvfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexEnvfv; }
_glGetIntegerv                                              {	printf("_glGetIntegerv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetIntegerv; }
_glGetBooleanv                                              {	printf("_glGetBooleanv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetBooleanv; }
_glEvalCoord2f                                              {	printf("_glEvalCoord2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2f; }
_glGenTextures                                              {	printf("_glGenTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGenTextures; }
_glGetTexEnviv                                              {	printf("_glGetTexEnviv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexEnviv; }
_glGetTexGendv                                              {	printf("_glGetTexGendv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGendv; }
_glLightModelf                                              {	printf("_glLightModelf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModelf; }
_glLightModeli                                              {	printf("_glLightModeli => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModeli; }
_[dD][eE][sS][tT]                                           {	printf("_DEST => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEST_STATEMENT; }
_glGetTexImage                                              {	printf("_glGetTexImage => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexImage; }
_glGetTexGenfv                                              {	printf("_glGetTexGenfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGenfv; }
_glGetTexGeniv                                              {	printf("_glGetTexGeniv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGeniv; }
_glEvalCoord2d                                              {	printf("_glEvalCoord2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2d; }
_glEvalCoord1f                                              {	printf("_glEvalCoord1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1f; }
[rR][aA][nN][dD][oO][mM][iI][zZ][eE]{ws}+[uU][sS][iI][nN][gG]          {	printf("RANDOMIZE USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOMIZE_USING; }
[mM][iI][dD]{ws}+\$[sS][tT][aA][tT][mM][eE][nN][tT]         {	printf("MID_$STATMENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_MID_DS_STATMENT; }
[lL][iI][nN][eE]{ws}+[iI][nN][pP][uU][tT]{ws}+[fF][iI][lL][eE]          {	printf("LINE INPUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE_INPUT_FILE; }
[iI][nN][pP][uU][tT]{ws}+[fF][iI][lL][eE]{ws}+[mM][oO][dD][eE]          {	printf("INPUT FILE MODE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_FILE_MODE; }
[dD][eE][cC][lL][aA][rR][eE]{ws}+[lL][iI][bB][rR][aA][rR][yY]          {	printf("DECLARE LIBRARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE_LIBRARY; }
[sS][tT][rR][iI][gG]                                        {	printf("STRIG => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRIG_STATEMENT; }
[tT][iI][mM][eE][rR]                                        {	printf("TIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB_TIMER_STATEMENT; }
_[mM][oO][uU][sS][eE][mM][oO][vV][eE][mM][eE][nN][tT][xX]   {	printf("_MOUSEMOVEMENTX => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVEMENTX; }
_glEvalCoord1d                                              {	printf("_glEvalCoord1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1d; }
_[mM][oO][uU][sS][eE][mM][oO][vV][eE][mM][eE][nN][tT][yY]   {	printf("_MOUSEMOVEMENTY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVEMENTY; }
_glDeleteLists                                              {	printf("_glDeleteLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDeleteLists; }
_glBindTexture                                              {	printf("_glBindTexture => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBindTexture; }
_[oO][pP][eE][nN][cC][oO][nN][nN][eE][cC][tT][iI][oO][nN]   {	printf("_OPENCONNECTION => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENCONNECTION; }
_glLineStipple                                              {	printf("_glLineStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLineStipple; }
_glGetPointerv                                              {	printf("_glGetPointerv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPointerv; }
_glMultMatrixd                                              {	printf("_glMultMatrixd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMultMatrixd; }
_glLoadMatrixf                                              {	printf("_glLoadMatrixf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadMatrixf; }
_glPixelStoref                                              {	printf("_glPixelStoref => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelStoref; }
_glMultMatrixf                                              {	printf("_glMultMatrixf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMultMatrixf; }
_glPixelStorei                                              {	printf("_glPixelStorei => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelStorei; }
_glLoadMatrixd                                              {	printf("_glLoadMatrixd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadMatrixd; }
_glPixelMapusv                                              {	printf("_glPixelMapusv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapusv; }
_glPolygonMode                                              {	printf("_glPolygonMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonMode; }
_glPixelMapuiv                                              {	printf("_glPixelMapuiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapuiv; }
_glPassThrough                                              {	printf("_glPassThrough => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPassThrough; }
_glEvalCoord1fv                                             {	printf("_glEvalCoord1fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1fv; }
_glRasterPos2iv                                             {	printf("_glRasterPos2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2iv; }
_glRasterPos2sv                                             {	printf("_glRasterPos2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2sv; }
_glDrawElements                                             {	printf("_glDrawElements => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawElements; }
_glEvalCoord1dv                                             {	printf("_glEvalCoord1dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1dv; }
_glLightModeliv                                             {	printf("_glLightModeliv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModeliv; }
_glClearStencil                                             {	printf("_glClearStencil => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearStencil; }
[sS][cC][rR][eE][eE][nN]                                    {	printf("SCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SCREEN_STATEMENT; }
[pP][rR][iI][nN][tT]{ws}+[uU][sS][iI][nN][gG]{ws}+[fF][iI][lL][eE]          {	printf("PRINT USING FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_USING_FILE; }
_[bB][lL][eE][nN][dD]                                       {	printf("_BLEND => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLEND_STATEMENT; }
_[bB][aA][cC][kK][gG][rR][oO][uU][nN][dD][cC][oO][lL][oO][rR]          {	printf("_BACKGROUNDCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__BACKGROUNDCOLOR; }
_glRasterPos2dv                                             {	printf("_glRasterPos2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2dv; }
_glEvalCoord2dv                                             {	printf("_glEvalCoord2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2dv; }
_glRasterPos2fv                                             {	printf("_glRasterPos2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2fv; }
_glArrayElement                                             {	printf("_glArrayElement => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glArrayElement; }
_glColorPointer                                             {	printf("_glColorPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorPointer; }
_glRasterPos3dv                                             {	printf("_glRasterPos3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3dv; }
_glRasterPos4iv                                             {	printf("_glRasterPos4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4iv; }
_glRasterPos4fv                                             {	printf("_glRasterPos4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4fv; }
_glRasterPos3fv                                             {	printf("_glRasterPos3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3fv; }
_glRasterPos4dv                                             {	printf("_glRasterPos4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4dv; }
[iI][nN][tT][eE][gG][eE][rR]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER_VARIABLE; }
_glIndexPointer                                             {	printf("_glIndexPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexPointer; }
_glLoadIdentity                                             {	printf("_glLoadIdentity => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadIdentity; }
_glLightModelfv                                             {	printf("_glLightModelfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModelfv; }
_glRasterPos4sv                                             {	printf("_glRasterPos4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4sv; }
_glRasterPos3sv                                             {	printf("_glRasterPos3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3sv; }
_glSelectBuffer                                             {	printf("_glSelectBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glSelectBuffer; }
_glRasterPos3iv                                             {	printf("_glRasterPos3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3iv; }
_glEvalCoord2fv                                             {	printf("_glEvalCoord2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2fv; }
_glGetClipPlane                                             {	printf("_glGetClipPlane => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetClipPlane; }
_glNormalPointer                                            {	printf("_glNormalPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormalPointer; }
[tT][iI][mM][eE]\$                                          {	printf("TIME$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_TIME_DS_STATEMENT; }
_glVertexPointer                                            {	printf("_glVertexPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertexPointer; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_VARIABLE; }
_[mM][eE][mM][gG][eE][tT]                                   {	printf("_MEMGET => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMGET_STATEMENT; }
_glPolygonOffset                                            {	printf("_glPolygonOffset => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonOffset; }
[sS][tT][aA][nN][dD][aA][rR][dD]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("STANDARD VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STANDARD_VARIABLE; }
_glTexParameteri                                            {	printf("_glTexParameteri => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameteri; }
[dD][aA][tT][eE]\$                                          {	printf("DATE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_DATE_DS_STATEMENT; }
_glTexSubImage1D                                            {	printf("_glTexSubImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexSubImage1D; }
_glTexSubImage2D                                            {	printf("_glTexSubImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexSubImage2D; }
_glColorMaterial                                            {	printf("_glColorMaterial => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorMaterial; }
_glGetPixelMapfv                                            {	printf("_glGetPixelMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapfv; }
[uU][nN][kK][nN][oO][wW][nN]{ws}+[cC][hH][aA][rR][aA][cC][tT][eE][rR]          {	printf("UNKNOWN CHARACTER => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNKNOWN_CHARACTER; }
_glGetMaterialfv                                            {	printf("_glGetMaterialfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMaterialfv; }
_glGetMaterialiv                                            {	printf("_glGetMaterialiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMaterialiv; }
_glTexParameterf                                            {	printf("_glTexParameterf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameterf; }
_[dD][iI][sS][pP][lL][aA][yY]                               {	printf("_DISPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__DISPLAY_STATEMENT; }
\$[vV][iI][rR][tT][uU][aA][lL][kK][eE][yY][bB][oO][aA][rR][dD]          {	printf("$VIRTUALKEYBOARD => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_VIRTUALKEYBOARD; }
_[mM][iI][dD][dD][lL][eE]{ws}+[sS][cC][rR][eE][eE][nN][mM][oO][vV][eE]          {	printf("_MIDDLE SCREENMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MIDDLE_SCREENMOVE; }
[iI][nN][tT][eE][gG][eE][rR]64{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER64_VARIABLE; }
_glCopyTexImage1D                                           {	printf("_glCopyTexImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexImage1D; }
_glDeleteTextures                                           {	printf("_glDeleteTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDeleteTextures; }
_glPixelTransferi                                           {	printf("_glPixelTransferi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelTransferi; }
_glFeedbackBuffer                                           {	printf("_glFeedbackBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFeedbackBuffer; }
_glGetPixelMapuiv                                           {	printf("_glGetPixelMapuiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapuiv; }
_glGetPixelMapusv                                           {	printf("_glGetPixelMapusv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapusv; }
_glCopyTexImage2D                                           {	printf("_glCopyTexImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexImage2D; }
_glPixelTransferf                                           {	printf("_glPixelTransferf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelTransferf; }
_glTexParameterfv                                           {	printf("_glTexParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameterfv; }
_glPolygonStipple                                           {	printf("_glPolygonStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonStipple; }
_glTexParameteriv                                           {	printf("_glTexParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameteriv; }
_glPopClientAttrib                                          {	printf("_glPopClientAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopClientAttrib; }
_glEdgeFlagPointer                                          {	printf("_glEdgeFlagPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlagPointer; }
_glTexCoordPointer                                          {	printf("_glTexCoordPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoordPointer; }
[iI][nN][pP][uU][tT]{ws}+[fF][iI][lL][eE]                   {	printf("INPUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_FILE_STATEMENT; }
_glPushClientAttrib                                         {	printf("_glPushClientAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushClientAttrib; }
_[pP][rR][iI][nN][tT][mM][oO][dD][eE]                       {	printf("_PRINTMODE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTMODE_STATEMENT; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[bB][iI][tT]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED BIT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BIT_VARIABLE; }
_[cC][oO][nN][tT][rR][oO][lL][cC][hH][rR]                   {	printf("_CONTROLCHR => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONTROLCHR_STATEMENT; }
_glGetTexParameterfv                                        {	printf("_glGetTexParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexParameterfv; }
_[cC][oO][nN][nN][eE][cC][tT][iI][oO][nN][aA][dD][dD][rR][eE][sS][sS]\$          {	printf("_CONNECTIONADDRESS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONNECTIONADDRESS_DS; }
_glGetTexParameteriv                                        {	printf("_glGetTexParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexParameteriv; }
_glInterleavedArrays                                        {	printf("_glInterleavedArrays => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glInterleavedArrays; }
_[cC][lL][eE][aA][rR][cC][oO][lL][oO][rR]                   {	printf("_CLEARCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLEARCOLOR_STATEMENT; }
[lL][eE][sS][sS]{ws}+[tT][hH][aA][nN]{ws}+[oO][rR]{ws}+[eE][qQ][uU][aA][lL]{ws}+[tT][oO]          {	printf("LESS THAN OR EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }
_glGetPolygonStipple                                        {	printf("_glGetPolygonStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPolygonStipple; }
_[mM][aA][pP][uU][nN][iI][cC][oO][dD][eE]                   {	printf("_MAPUNICODE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MAPUNICODE_STATEMENT; }
_glCopyTexSubImage2D                                        {	printf("_glCopyTexSubImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexSubImage2D; }
_glEnableClientState                                        {	printf("_glEnableClientState => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnableClientState; }
_[fF][uU][lL][lL][sS][cC][rR][eE][eE][nN]                   {	printf("_FULLSCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__FULLSCREEN_STATEMENT; }
_glCopyTexSubImage1D                                        {	printf("_glCopyTexSubImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexSubImage1D; }
_[sS][cC][rR][eE][eE][nN][iI][cC][oO][nN]                   {	printf("_SCREENICON => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENICON_STATEMENT; }
_glPrioritizeTextures                                       {	printf("_glPrioritizeTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPrioritizeTextures; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[bB][yY][tT][eE]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }
_glDisableClientState                                       {	printf("_glDisableClientState => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDisableClientState; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[lL][oO][nN][gG]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_LONG_VARIABLE; }
[mM][uU][lL][tT][iI]{ws}+[lL][iI][nN][eE]{ws}+[cC][oO][mM][mM][eE][nN][tT]{ws}+[eE][nN][dD]          {	printf("MULTI LINE COMMENT END => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_END; }
_[pP][aA][lL][eE][tT][tT][eE][cC][oO][lL][oO][rR]           {	printf("_PALETTECOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__PALETTECOLOR_STATEMENT; }
_[cC][lL][iI][pP][bB][oO][aA][rR][dD]\$                     {	printf("_CLIPBOARD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLIPBOARD_DS_STATEMENT; }
[dD][eE][cC][lL][aA][rR][eE]{ws}+[dD][yY][nN][aA][mM][iI][cC]{ws}+[lL][iI][bB][rR][aA][rR][yY]          {	printf("DECLARE DYNAMIC LIBRARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE_DYNAMIC_LIBRARY; }
_glAreTexturesResident                                      {	printf("_glAreTexturesResident => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAreTexturesResident; }
[mM][uU][lL][tT][iI]{ws}+[lL][iI][nN][eE]{ws}+[cC][oO][mM][mM][eE][nN][tT]{ws}+[eE][rR][rR][oO][rR]          {	printf("MULTI LINE COMMENT ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_ERROR; }
[gG][rR][eE][aA][tT][eE][rR]{ws}+[tT][hH][aA][nN]{ws}+[oO][rR]{ws}+[eE][qQ][uU][aA][lL]{ws}+[tT][oO]          {	printf("GREATER THAN OR EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }
[mM][uU][lL][tT][iI]{ws}+[lL][iI][nN][eE]{ws}+[cC][oO][mM][mM][eE][nN][tT]{ws}+[bB][eE][gG][iI][nN]          {	printf("MULTI LINE COMMENT BEGIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_BEGIN; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[oO][fF][fF][sS][eE][tT]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[iI][nN][tT][eE][gG][eE][rR]{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }
_glGetTexLevelParameterfv                                   {	printf("_glGetTexLevelParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexLevelParameterfv; }
_glGetTexLevelParameteriv                                   {	printf("_glGetTexLevelParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexLevelParameteriv; }
[uU][nN][sS][iI][gG][nN][eE][dD]{ws}+[iI][nN][tT][eE][gG][eE][rR]64{ws}+[vV][aA][rR][iI][aA][bB][lL][eE]          {	printf("UNSIGNED INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }

	/*	END LEX	*/
	/*	+++++	DO NOT REMOVE THE PREVIOUS LINE!!!	+++++	*/

\n			{	printf("NEW LINE\n"); nline++; nchar++; return ENUM_QB_NEW_LINE; }
{ws}		{	printf("WHITE SPACE\n"); ws++; return ENUM_QB_WHITE_SPACE; }
.			{	printf("UNKNOWN CHARACTER\n"); nchar++; return ENUM_QB_UNKNOWN_CHARACTER; }


%%
	/*	Routines	*/

/*
	Main Program
*/
int main( void )
{
	int tok;

	while( tok = yylex() ){
		printf( "--->RETURNED : %d\n", tok );
		}

	printf( "\n\nCharacters : %d\nWords : %d\nLines : %d\nWhite Space : %d\n", nchar, nword, yylineno, ws );
	return 0;
}

