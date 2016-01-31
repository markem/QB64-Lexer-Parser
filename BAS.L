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
nl				(\n)
notnl			(.)
any				({notnl}|{nl})

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

^{ws}*(rem|'){ws}+\$[iI][nN][cC][lL][uU][dD][eE]{ws}*[\"<]	{	BEGIN INCL;	}

<INCL>[^{ws}*\">]+   { /* got the include file name */
printf( "---> Entering INCLUDE(%s)\n", yytext );
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

^{ws}*rem					{	printf("REM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REM; }

^{ws}*'						{	printf("REM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REM; }

:{ws}*rem					{	printf("REM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REM; }

:{ws}*'						{	printf("REM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REM; }

(^|{ws}*)IF{ws}*                                  {	printf("IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_IF; }
(^|{ws}*)TO{ws}*                                  {	printf("TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_TO; }
(^|{ws}*)AS{ws}*                                  {	printf("AS => %s\n", yytext); nchar += yyleng; return ENUM_QB_AS; }
(^|{ws}*)DO{ws}*                                  {	printf("DO => %s\n", yytext); nchar += yyleng; return ENUM_QB_DO; }
(^|{ws}*)OR{ws}*                                  {	printf("OR => %s\n", yytext); nchar += yyleng; return ENUM_QB_OR; }
(^|{ws}*)EQV{ws}*                                 {	printf("EQV => %s\n", yytext); nchar += yyleng; return ENUM_QB_EQV; }
(^|{ws}*)FIX{ws}*                                 {	printf("FIX => %s\n", yytext); nchar += yyleng; return ENUM_QB_FIX; }
(^|{ws}*)ERL{ws}*                                 {	printf("ERL => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERL; }
(^|{ws}*)EXP{ws}*                                 {	printf("EXP => %s\n", yytext); nchar += yyleng; return ENUM_QB_EXP; }
(^|{ws}*)ERR{ws}*                                 {	printf("ERR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERR; }
(^|{ws}*)EOF{ws}*                                 {	printf("EOF => %s\n", yytext); nchar += yyleng; return ENUM_QB_EOF; }
(^|{ws}*)INT{ws}*                                 {	printf("INT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INT; }
(^|{ws}*)CVL{ws}*                                 {	printf("CVL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVL; }
(^|{ws}*)DIM{ws}*                                 {	printf("DIM => %s\n", yytext); nchar += yyleng; return ENUM_QB_DIM; }
(^|{ws}*)POS{ws}*                                 {	printf("POS => %s\n", yytext); nchar += yyleng; return ENUM_QB_POS; }
(^|{ws}*)FOR{ws}*                                 {	printf("FOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_FOR; }
(^|{ws}*)END{ws}*                                 {	printf("END => %s\n", yytext); nchar += yyleng; return ENUM_QB_END; }
(^|{ws}*)_CV{ws}*                                 {	printf("_CV => %s\n", yytext); nchar += yyleng; return ENUM_QB__CV; }
(^|{ws}*)FRE{ws}*                                 {	printf("FRE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FRE; }
(^|{ws}*)IMP{ws}*                                 {	printf("IMP => %s\n", yytext); nchar += yyleng; return ENUM_QB_IMP; }
(^|{ws}*)LOC{ws}*                                 {	printf("LOC => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOC; }
(^|{ws}*)INP{ws}*                                 {	printf("INP => %s\n", yytext); nchar += yyleng; return ENUM_QB_INP; }
(^|{ws}*)LET{ws}*                                 {	printf("LET => %s\n", yytext); nchar += yyleng; return ENUM_QB_LET; }
(^|{ws}*)LEN{ws}*                                 {	printf("LEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_LEN; }
(^|{ws}*)LOF{ws}*                                 {	printf("LOF => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOF; }
(^|{ws}*)LOG{ws}*                                 {	printf("LOG => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOG; }
(^|{ws}*)OFF{ws}*                                 {	printf("OFF => %s\n", yytext); nchar += yyleng; return ENUM_QB_OFF; }
(^|{ws}*)RND{ws}*                                 {	printf("RND => %s\n", yytext); nchar += yyleng; return ENUM_QB_RND; }
(^|{ws}*)NOT{ws}*                                 {	printf("NOT => %s\n", yytext); nchar += yyleng; return ENUM_QB_NOT; }
(^|{ws}*)MOD{ws}*                                 {	printf("MOD => %s\n", yytext); nchar += yyleng; return ENUM_QB_MOD; }
(^|{ws}*)GET{ws}*                                 {	printf("GET => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET; }
(^|{ws}*)OUT{ws}*                                 {	printf("OUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_OUT; }
(^|{ws}*)CVS{ws}*                                 {	printf("CVS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVS; }
(^|{ws}*)TAN{ws}*                                 {	printf("TAN => %s\n", yytext); nchar += yyleng; return ENUM_QB_TAN; }
(^|{ws}*)ATN{ws}*                                 {	printf("ATN => %s\n", yytext); nchar += yyleng; return ENUM_QB_ATN; }
(^|{ws}*)TAB{ws}*                                 {	printf("TAB => %s\n", yytext); nchar += yyleng; return ENUM_QB_TAB; }
(^|{ws}*)CVI{ws}*                                 {	printf("CVI => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVI; }
(^|{ws}*)SQR{ws}*                                 {	printf("SQR => %s\n", yytext); nchar += yyleng; return ENUM_QB_SQR; }
(^|{ws}*)ASC{ws}*                                 {	printf("ASC => %s\n", yytext); nchar += yyleng; return ENUM_QB_ASC; }
(^|{ws}*)ANY{ws}*                                 {	printf("ANY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ANY; }
(^|{ws}*)XOR{ws}*                                 {	printf("XOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_XOR; }
(^|{ws}*)ABS{ws}*                                 {	printf("ABS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ABS; }
(^|{ws}*)VAL{ws}*                                 {	printf("VAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_VAL; }
(^|{ws}*)AND{ws}*                                 {	printf("AND => %s\n", yytext); nchar += yyleng; return ENUM_QB_AND; }
(^|{ws}*)SPC{ws}*                                 {	printf("SPC => %s\n", yytext); nchar += yyleng; return ENUM_QB_SPC; }
(^|{ws}*)SUB{ws}*                                 {	printf("SUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_SUB; }
(^|{ws}*)CVD{ws}*                                 {	printf("CVD => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVD; }
(^|{ws}*)CLS{ws}*                                 {	printf("CLS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLS; }
(^|{ws}*)COS{ws}*                                 {	printf("COS => %s\n", yytext); nchar += yyleng; return ENUM_QB_COS; }
(^|{ws}*)SGN{ws}*                                 {	printf("SGN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SGN; }
(^|{ws}*)RUN{ws}*                                 {	printf("RUN => %s\n", yytext); nchar += yyleng; return ENUM_QB_RUN; }
(^|{ws}*)SIN{ws}*                                 {	printf("SIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SIN; }
(^|{ws}*)CSNG{ws}*                                {	printf("CSNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_CSNG; }
(^|{ws}*)GOTO{ws}*                                {	printf("GOTO => %s\n", yytext); nchar += yyleng; return ENUM_QB_GOTO; }
(^|{ws}*)DATA{ws}*                                {	printf("DATA => %s\n", yytext); nchar += yyleng; return ENUM_QB_DATA; }
(^|{ws}*)_SEC{ws}*                                {	printf("_SEC => %s\n", yytext); nchar += yyleng; return ENUM_QB__SEC; }
(^|{ws}*)_R2G{ws}*                                {	printf("_R2G => %s\n", yytext); nchar += yyleng; return ENUM_QB__R2G; }
(^|{ws}*)_RED{ws}*                                {	printf("_RED => %s\n", yytext); nchar += yyleng; return ENUM_QB__RED; }
(^|{ws}*)_RGB{ws}*                                {	printf("_RGB => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGB; }
(^|{ws}*)FREE{ws}*                                {	printf("FREE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FREE; }
(^|{ws}*)DRAW{ws}*                                {	printf("DRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB_DRAW; }
(^|{ws}*)CASE{ws}*                                {	printf("CASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE; }
(^|{ws}*)CDBL{ws}*                                {	printf("CDBL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CDBL; }
(^|{ws}*)EXIT{ws}*                                {	printf("EXIT => %s\n", yytext); nchar += yyleng; return ENUM_QB_EXIT; }
(^|{ws}*)CINT{ws}*                                {	printf("CINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_CINT; }
(^|{ws}*)CALL{ws}*                                {	printf("CALL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALL; }
(^|{ws}*)BEEP{ws}*                                {	printf("BEEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_BEEP; }
(^|{ws}*)CLNG{ws}*                                {	printf("CLNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLNG; }
(^|{ws}*)_G2R{ws}*                                {	printf("_G2R => %s\n", yytext); nchar += yyleng; return ENUM_QB__G2R; }
(^|{ws}*)ELSE{ws}*                                {	printf("ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSE; }
(^|{ws}*)_G2D{ws}*                                {	printf("_G2D => %s\n", yytext); nchar += yyleng; return ENUM_QB__G2D; }
(^|{ws}*)KILL{ws}*                                {	printf("KILL => %s\n", yytext); nchar += yyleng; return ENUM_QB_KILL; }
(^|{ws}*)READ{ws}*                                {	printf("READ => %s\n", yytext); nchar += yyleng; return ENUM_QB_READ; }
(^|{ws}*)RSET{ws}*                                {	printf("RSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_RSET; }
(^|{ws}*)STEP{ws}*                                {	printf("STEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_STEP; }
(^|{ws}*)PSET{ws}*                                {	printf("PSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_PSET; }
(^|{ws}*)_COT{ws}*                                {	printf("_COT => %s\n", yytext); nchar += yyleng; return ENUM_QB__COT; }
(^|{ws}*)_D2G{ws}*                                {	printf("_D2G => %s\n", yytext); nchar += yyleng; return ENUM_QB__D2G; }
(^|{ws}*)POKE{ws}*                                {	printf("POKE => %s\n", yytext); nchar += yyleng; return ENUM_QB_POKE; }
(^|{ws}*)_CSC{ws}*                                {	printf("_CSC => %s\n", yytext); nchar += yyleng; return ENUM_QB__CSC; }
(^|{ws}*)STOP{ws}*                                {	printf("STOP => %s\n", yytext); nchar += yyleng; return ENUM_QB_STOP; }
(^|{ws}*)SWAP{ws}*                                {	printf("SWAP => %s\n", yytext); nchar += yyleng; return ENUM_QB_SWAP; }
(^|{ws}*)VIEW{ws}*                                {	printf("VIEW => %s\n", yytext); nchar += yyleng; return ENUM_QB_VIEW; }
(^|{ws}*)WAIT{ws}*                                {	printf("WAIT => %s\n", yytext); nchar += yyleng; return ENUM_QB_WAIT; }
(^|{ws}*)WEND{ws}*                                {	printf("WEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_WEND; }
(^|{ws}*)TYPE{ws}*                                {	printf("TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB_TYPE; }
(^|{ws}*)TRON{ws}*                                {	printf("TRON => %s\n", yytext); nchar += yyleng; return ENUM_QB_TRON; }
(^|{ws}*)_BIT{ws}*                                {	printf("_BIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__BIT; }
(^|{ws}*)THEN{ws}*                                {	printf("THEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_THEN; }
(^|{ws}*)_D2R{ws}*                                {	printf("_D2R => %s\n", yytext); nchar += yyleng; return ENUM_QB__D2R; }
(^|{ws}*)SADD{ws}*                                {	printf("SADD => %s\n", yytext); nchar += yyleng; return ENUM_QB_SADD; }
(^|{ws}*)LPOS{ws}*                                {	printf("LPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPOS; }
(^|{ws}*)NAME{ws}*                                {	printf("NAME => %s\n", yytext); nchar += yyleng; return ENUM_QB_NAME; }
(^|{ws}*)LONG{ws}*                                {	printf("LONG => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG; }
(^|{ws}*)OPEN{ws}*                                {	printf("OPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPEN; }
(^|{ws}*)LIST{ws}*                                {	printf("LIST => %s\n", yytext); nchar += yyleng; return ENUM_QB_LIST; }
(^|{ws}*)_R2D{ws}*                                {	printf("_R2D => %s\n", yytext); nchar += yyleng; return ENUM_QB__R2D; }
(^|{ws}*)PMAP{ws}*                                {	printf("PMAP => %s\n", yytext); nchar += yyleng; return ENUM_QB_PMAP; }
(^|{ws}*)PEEK{ws}*                                {	printf("PEEK => %s\n", yytext); nchar += yyleng; return ENUM_QB_PEEK; }
(^|{ws}*)LOCK{ws}*                                {	printf("LOCK => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOCK; }
(^|{ws}*)LINE{ws}*                                {	printf("LINE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE; }
(^|{ws}*)LSET{ws}*                                {	printf("LSET => %s\n", yytext); nchar += yyleng; return ENUM_QB_LSET; }
(^|{ws}*)GOSUB{ws}*                               {	printf("GOSUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_GOSUB; }
(^|{ws}*)BYVAL{ws}*                               {	printf("BYVAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_BYVAL; }
(^|{ws}*)STICK{ws}*                               {	printf("STICK => %s\n", yytext); nchar += yyleng; return ENUM_QB_STICK; }
(^|{ws}*)CALLS{ws}*                               {	printf("CALLS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALLS; }
(^|{ws}*)TROFF{ws}*                               {	printf("TROFF => %s\n", yytext); nchar += yyleng; return ENUM_QB_TROFF; }
(^|{ws}*)BSAVE{ws}*                               {	printf("BSAVE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BSAVE; }
(^|{ws}*)BLOAD{ws}*                               {	printf("BLOAD => %s\n", yytext); nchar += yyleng; return ENUM_QB_BLOAD; }
(^|{ws}*)ALIAS{ws}*                               {	printf("ALIAS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ALIAS; }
(^|{ws}*)_RGBA{ws}*                               {	printf("_RGBA => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGBA; }
(^|{ws}*)WHILE{ws}*                               {	printf("WHILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHILE; }
(^|{ws}*)WIDTH{ws}*                               {	printf("WIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB_WIDTH; }
(^|{ws}*)INSTR{ws}*                               {	printf("INSTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_INSTR; }
(^|{ws}*)_SECH{ws}*                               {	printf("_SECH => %s\n", yytext); nchar += yyleng; return ENUM_QB__SECH; }
(^|{ws}*)CDECL{ws}*                               {	printf("CDECL => %s\n", yytext); nchar += yyleng; return ENUM_QB_CDECL; }
(^|{ws}*)_TANH{ws}*                               {	printf("_TANH => %s\n", yytext); nchar += yyleng; return ENUM_QB__TANH; }
(^|{ws}*)_SINH{ws}*                               {	printf("_SINH => %s\n", yytext); nchar += yyleng; return ENUM_QB__SINH; }
(^|{ws}*)UNTIL{ws}*                               {	printf("UNTIL => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNTIL; }
(^|{ws}*)MKDIR{ws}*                               {	printf("MKDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKDIR; }
(^|{ws}*)PCOPY{ws}*                               {	printf("PCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB_PCOPY; }
(^|{ws}*)PAINT{ws}*                               {	printf("PAINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_PAINT; }
(^|{ws}*)REDIM{ws}*                               {	printf("REDIM => %s\n", yytext); nchar += yyleng; return ENUM_QB_REDIM; }
(^|{ws}*)RESET{ws}*                               {	printf("RESET => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESET; }
(^|{ws}*)PRINT{ws}*                               {	printf("PRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT; }
(^|{ws}*)FILES{ws}*                               {	printf("FILES => %s\n", yytext); nchar += yyleng; return ENUM_QB_FILES; }
(^|{ws}*)ERDEV{ws}*                               {	printf("ERDEV => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERDEV; }
(^|{ws}*)ERASE{ws}*                               {	printf("ERASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERASE; }
(^|{ws}*)POINT{ws}*                               {	printf("POINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_POINT; }
(^|{ws}*)FIELD{ws}*                               {	printf("FIELD => %s\n", yytext); nchar += yyleng; return ENUM_QB_FIELD; }
(^|{ws}*)RMDIR{ws}*                               {	printf("RMDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_RMDIR; }
(^|{ws}*)IOCTL{ws}*                               {	printf("IOCTL => %s\n", yytext); nchar += yyleng; return ENUM_QB_IOCTL; }
(^|{ws}*)SOUND{ws}*                               {	printf("SOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_SOUND; }
(^|{ws}*)CLEAR{ws}*                               {	printf("CLEAR => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLEAR; }
(^|{ws}*)ERROR{ws}*                               {	printf("ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERROR; }
(^|{ws}*)CHDIR{ws}*                               {	printf("CHDIR => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHDIR; }
(^|{ws}*)CLOSE{ws}*                               {	printf("CLOSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CLOSE; }
(^|{ws}*)SLEEP{ws}*                               {	printf("SLEEP => %s\n", yytext); nchar += yyleng; return ENUM_QB_SLEEP; }
(^|{ws}*)_ACOS{ws}*                               {	printf("_ACOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__ACOS; }
(^|{ws}*)SHELL{ws}*                               {	printf("SHELL => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHELL; }
(^|{ws}*)CONST{ws}*                               {	printf("CONST => %s\n", yytext); nchar += yyleng; return ENUM_QB_CONST; }
(^|{ws}*)COLOR{ws}*                               {	printf("COLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB_COLOR; }
(^|{ws}*)CHAIN{ws}*                               {	printf("CHAIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHAIN; }
(^|{ws}*)INPUT{ws}*                               {	printf("INPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT; }
(^|{ws}*)_ICON{ws}*                               {	printf("_ICON => %s\n", yytext); nchar += yyleng; return ENUM_QB__ICON; }
(^|{ws}*)_COSH{ws}*                               {	printf("_COSH => %s\n", yytext); nchar += yyleng; return ENUM_QB__COSH; }
(^|{ws}*)_ASIN{ws}*                               {	printf("_ASIN => %s\n", yytext); nchar += yyleng; return ENUM_QB__ASIN; }
(^|{ws}*)_COTH{ws}*                               {	printf("_COTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__COTH; }
(^|{ws}*)_CEIL{ws}*                               {	printf("_CEIL => %s\n", yytext); nchar += yyleng; return ENUM_QB__CEIL; }
(^|{ws}*)_AXIS{ws}*                               {	printf("_AXIS => %s\n", yytext); nchar += yyleng; return ENUM_QB__AXIS; }
(^|{ws}*)_EXIT{ws}*                               {	printf("_EXIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__EXIT; }
(^|{ws}*)_CSCH{ws}*                               {	printf("_CSCH => %s\n", yytext); nchar += yyleng; return ENUM_QB__CSCH; }
(^|{ws}*)\$IF{ws}*                                {	printf("$IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_IF; }
(^|{ws}*)_BYTE{ws}*                               {	printf("_BYTE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BYTE; }
(^|{ws}*)_CLIP{ws}*                               {	printf("_CLIP => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLIP; }
(^|{ws}*)_HIDE{ws}*                               {	printf("_HIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__HIDE; }
(^|{ws}*)_BLUE{ws}*                               {	printf("_BLUE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLUE; }
(^|{ws}*)ACCESS{ws}*                              {	printf("ACCESS => %s\n", yytext); nchar += yyleng; return ENUM_QB_ACCESS; }
(^|{ws}*)LBOUND{ws}*                              {	printf("LBOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_LBOUND; }
(^|{ws}*)_FLOAT{ws}*                              {	printf("_FLOAT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FLOAT; }
(^|{ws}*)APPEND{ws}*                              {	printf("APPEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_APPEND; }
(^|{ws}*)\$END{ws}*                               {	printf("$END => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_END; }
(^|{ws}*)MKL\${ws}*                               {	printf("MKL$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKL_DS; }
(^|{ws}*)MKS\${ws}*                               {	printf("MKS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKS_DS; }
(^|{ws}*)OCT\${ws}*                               {	printf("OCT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_OCT_DS; }
(^|{ws}*)ON{ws}+COM{ws}*                          {	printf("ON COM => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_COM; }
(^|{ws}*)MKI\${ws}*                               {	printf("MKI$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKI_DS; }
(^|{ws}*)MKD\${ws}*                               {	printf("MKD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKD_DS; }
(^|{ws}*)_WHEEL{ws}*                              {	printf("_WHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__WHEEL; }
(^|{ws}*)LOCATE{ws}*                              {	printf("LOCATE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOCATE; }
(^|{ws}*)_TITLE{ws}*                              {	printf("_TITLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__TITLE; }
(^|{ws}*)LPRINT{ws}*                              {	printf("LPRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPRINT; }
(^|{ws}*)_WIDTH{ws}*                              {	printf("_WIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__WIDTH; }
(^|{ws}*)BINARY{ws}*                              {	printf("BINARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_BINARY; }
(^|{ws}*)DEFLNG{ws}*                              {	printf("DEFLNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFLNG; }
(^|{ws}*)CIRCLE{ws}*                              {	printf("CIRCLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CIRCLE; }
(^|{ws}*)DEFSNG{ws}*                              {	printf("DEFSNG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFSNG; }
(^|{ws}*)CHR\${ws}*                               {	printf("CHR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_CHR_DS; }
(^|{ws}*)DEFINT{ws}*                              {	printf("DEFINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFINT; }
(^|{ws}*)DEFDBL{ws}*                              {	printf("DEFDBL => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFDBL; }
(^|{ws}*)CVDMBF{ws}*                              {	printf("CVDMBF => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVDMBF; }
(^|{ws}*)CVSMBF{ws}*                              {	printf("CVSMBF => %s\n", yytext); nchar += yyleng; return ENUM_QB_CVSMBF; }
(^|{ws}*)COMMON{ws}*                              {	printf("COMMON => %s\n", yytext); nchar += yyleng; return ENUM_QB_COMMON; }
(^|{ws}*)DEF{ws}+FN{ws}*                          {	printf("DEF FN => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEF_FN; }
(^|{ws}*)DEFSTR{ws}*                              {	printf("DEFSTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEFSTR; }
(^|{ws}*)_MK\${ws}*                               {	printf("_MK$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__MK_DS; }
(^|{ws}*)\$LET{ws}*                               {	printf("$LET => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_LET; }
(^|{ws}*)_HYPOT{ws}*                              {	printf("_HYPOT => %s\n", yytext); nchar += yyleng; return ENUM_QB__HYPOT; }
(^|{ws}*)ON{ws}+KEY{ws}*                          {	printf("ON KEY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_KEY; }
(^|{ws}*)_GREEN{ws}*                              {	printf("_GREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__GREEN; }
(^|{ws}*)END{ws}+IF{ws}*                          {	printf("END IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_END_IF; }
(^|{ws}*)ELSEIF{ws}*                              {	printf("ELSEIF => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSEIF; }
(^|{ws}*)DIR\${ws}*                               {	printf("DIR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_DIR_DS; }
(^|{ws}*)DOUBLE{ws}*                              {	printf("DOUBLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE; }
(^|{ws}*)_LIMIT{ws}*                              {	printf("_LIMIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__LIMIT; }
(^|{ws}*)HEX\${ws}*                               {	printf("HEX$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_HEX_DS; }
(^|{ws}*)ON{ws}+PEN{ws}*                          {	printf("ON PEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_PEN; }
(^|{ws}*)UBOUND{ws}*                              {	printf("UBOUND => %s\n", yytext); nchar += yyleng; return ENUM_QB_UBOUND; }
(^|{ws}*)UEVENT{ws}*                              {	printf("UEVENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_UEVENT; }
(^|{ws}*)_ROUND{ws}*                              {	printf("_ROUND => %s\n", yytext); nchar += yyleng; return ENUM_QB__ROUND; }
(^|{ws}*)_ATAN2{ws}*                              {	printf("_ATAN2 => %s\n", yytext); nchar += yyleng; return ENUM_QB__ATAN2; }
(^|{ws}*)_ATANH{ws}*                              {	printf("_ATANH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ATANH; }
(^|{ws}*)STR\${ws}*                               {	printf("STR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_STR_DS; }
(^|{ws}*)CSRLIN{ws}*                              {	printf("CSRLIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_CSRLIN; }
(^|{ws}*)SYSTEM{ws}*                              {	printf("SYSTEM => %s\n", yytext); nchar += yyleng; return ENUM_QB_SYSTEM; }
(^|{ws}*)UNLOCK{ws}*                              {	printf("UNLOCK => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNLOCK; }
(^|{ws}*)_ASINH{ws}*                              {	printf("_ASINH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ASINH; }
(^|{ws}*)_ALPHA{ws}*                              {	printf("_ALPHA => %s\n", yytext); nchar += yyleng; return ENUM_QB__ALPHA; }
(^|{ws}*)WINDOW{ws}*                              {	printf("WINDOW => %s\n", yytext); nchar += yyleng; return ENUM_QB_WINDOW; }
(^|{ws}*)_ACOSH{ws}*                              {	printf("_ACOSH => %s\n", yytext); nchar += yyleng; return ENUM_QB__ACOSH; }
(^|{ws}*)_RED32{ws}*                              {	printf("_RED32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RED32; }
(^|{ws}*)_ARCSC{ws}*                              {	printf("_ARCSC => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCSC; }
(^|{ws}*)_RGB32{ws}*                              {	printf("_RGB32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGB32; }
(^|{ws}*)VARPTR{ws}*                              {	printf("VARPTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARPTR; }
(^|{ws}*)VARSEG{ws}*                              {	printf("VARSEG => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARSEG; }
(^|{ws}*)STATIC{ws}*                              {	printf("STATIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_STATIC; }
(^|{ws}*)STRING{ws}*                              {	printf("STRING => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING; }
(^|{ws}*)SINGLE{ws}*                              {	printf("SINGLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE; }
(^|{ws}*)RETURN{ws}*                              {	printf("RETURN => %s\n", yytext); nchar += yyleng; return ENUM_QB_RETURN; }
(^|{ws}*)SETMEM{ws}*                              {	printf("SETMEM => %s\n", yytext); nchar += yyleng; return ENUM_QB_SETMEM; }
(^|{ws}*)RANDOM{ws}*                              {	printf("RANDOM => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOM; }
(^|{ws}*)PRESET{ws}*                              {	printf("PRESET => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRESET; }
(^|{ws}*)OUTPUT{ws}*                              {	printf("OUTPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_OUTPUT; }
(^|{ws}*)_DELAY{ws}*                              {	printf("_DELAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__DELAY; }
(^|{ws}*)SHARED{ws}*                              {	printf("SHARED => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHARED; }
(^|{ws}*)RESUME{ws}*                              {	printf("RESUME => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESUME; }
(^|{ws}*)SIGNAL{ws}*                              {	printf("SIGNAL => %s\n", yytext); nchar += yyleng; return ENUM_QB_SIGNAL; }
(^|{ws}*)_OS\${ws}*                               {	printf("_OS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__OS_DS; }
(^|{ws}*)DEF{ws}+SEG{ws}*                         {	printf("DEF SEG => %s\n", yytext); nchar += yyleng; return ENUM_QB_DEF_SEG; }
(^|{ws}*)_ARCCOT{ws}*                             {	printf("_ARCCOT => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCCOT; }
(^|{ws}*)PALETTE{ws}*                             {	printf("PALETTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PALETTE; }
(^|{ws}*)_BUTTON{ws}*                             {	printf("_BUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__BUTTON; }
(^|{ws}*)DECLARE{ws}*                             {	printf("DECLARE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE; }
_glEnd                                            {	printf("_glEnd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnd; }
(^|{ws}*)ON{ws}+PLAY{ws}*                         {	printf("ON PLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_PLAY; }
(^|{ws}*)ON{ws}+GOTO{ws}*                         {	printf("ON GOTO => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_GOTO; }
(^|{ws}*)_HEIGHT{ws}*                             {	printf("_HEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__HEIGHT; }
(^|{ws}*)_CWD\${ws}*                              {	printf("_CWD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CWD_DS; }
(^|{ws}*)ELSE{ws}+IF{ws}*                         {	printf("ELSE IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_ELSE_IF; }
(^|{ws}*)LEFT\${ws}*                              {	printf("LEFT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LEFT_DS; }
(^|{ws}*)ENVIRON{ws}*                             {	printf("ENVIRON => %s\n", yytext); nchar += yyleng; return ENUM_QB_ENVIRON; }
(^|{ws}*)_BLUE32{ws}*                             {	printf("_BLUE32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLUE32; }
(^|{ws}*)RESTORE{ws}*                             {	printf("RESTORE => %s\n", yytext); nchar += yyleng; return ENUM_QB_RESTORE; }
(^|{ws}*)_KEYHIT{ws}*                             {	printf("_KEYHIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYHIT; }
(^|{ws}*)\$ELSE{ws}*                              {	printf("$ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSE; }
(^|{ws}*)INTEGER{ws}*                             {	printf("INTEGER => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER; }
(^|{ws}*)_ARCSEC{ws}*                             {	printf("_ARCSEC => %s\n", yytext); nchar += yyleng; return ENUM_QB__ARCSEC; }
(^|{ws}*)_DEFINE{ws}*                             {	printf("_DEFINE => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEFINE; }
(^|{ws}*)_MOUSEY{ws}*                             {	printf("_MOUSEY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEY; }
(^|{ws}*)CASE{ws}+IS{ws}*                         {	printf("CASE IS => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE_IS; }
(^|{ws}*)_RGBA32{ws}*                             {	printf("_RGBA32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__RGBA32; }
(^|{ws}*)_SNDLEN{ws}*                             {	printf("_SNDLEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLEN; }
(^|{ws}*)_MEMNEW{ws}*                             {	printf("_MEMNEW => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMNEW; }
(^|{ws}*)_MOUSEX{ws}*                             {	printf("_MOUSEX => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEX; }
(^|{ws}*)_MEMPUT{ws}*                             {	printf("_MEMPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMPUT; }
(^|{ws}*)_RESIZE{ws}*                             {	printf("_RESIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZE; }
(^|{ws}*)_STRCMP{ws}*                             {	printf("_STRCMP => %s\n", yytext); nchar += yyleng; return ENUM_QB__STRCMP; }
(^|{ws}*)_SNDBAL{ws}*                             {	printf("_SNDBAL => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDBAL; }
(^|{ws}*)_SNDVOL{ws}*                             {	printf("_SNDVOL => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDVOL; }
(^|{ws}*)_SOURCE{ws}*                             {	printf("_SOURCE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SOURCE; }
(^|{ws}*)_SNDRAW{ws}*                             {	printf("_SNDRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAW; }
(^|{ws}*)FILEATTR{ws}*                            {	printf("FILEATTR => %s\n", yytext); nchar += yyleng; return ENUM_QB_FILEATTR; }
(^|{ws}*)_KEYDOWN{ws}*                            {	printf("_KEYDOWN => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYDOWN; }
(^|{ws}*)ERDEV\${ws}*                             {	printf("ERDEV$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_ERDEV_DS; }
(^|{ws}*)ON{ws}+GOSUB{ws}*                        {	printf("ON GOSUB => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_GOSUB; }
(^|{ws}*)OPEN{ws}+COM{ws}*                        {	printf("OPEN COM => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPEN_COM; }
(^|{ws}*)_SNDRATE{ws}*                            {	printf("_SNDRATE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRATE; }
(^|{ws}*)INPUT\${ws}*                             {	printf("INPUT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_DS; }
(^|{ws}*)LCASE\${ws}*                             {	printf("LCASE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LCASE_DS; }
(^|{ws}*)FOR{ws}+FILE{ws}*                        {	printf("FOR FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FOR_FILE; }
(^|{ws}*)ON{ws}+STRIG{ws}*                        {	printf("ON STRIG => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_STRIG; }
_glFogf                                           {	printf("_glFogf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogf; }
(^|{ws}*)ON{ws}+ERROR{ws}*                        {	printf("ON ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_ERROR; }
(^|{ws}*)_SNDSTOP{ws}*                            {	printf("_SNDSTOP => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDSTOP; }
(^|{ws}*)INKEY\${ws}*                             {	printf("INKEY$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_INKEY_DS; }
(^|{ws}*)_DEVICES{ws}*                            {	printf("_DEVICES => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICES; }
(^|{ws}*)GET{ws}+QB64{ws}*                        {	printf("GET QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET_QB64; }
(^|{ws}*)GET{ws}+FILE{ws}*                        {	printf("GET FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_GET_FILE; }
(^|{ws}*)LTRIM\${ws}*                             {	printf("LTRIM$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_LTRIM_DS; }
_glFogi                                           {	printf("_glFogi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogi; }
(^|{ws}*)ON{ws}+TIMER{ws}*                        {	printf("ON TIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_TIMER; }
(^|{ws}*)FREEFILE{ws}*                            {	printf("FREEFILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FREEFILE; }
(^|{ws}*)_GREEN32{ws}*                            {	printf("_GREEN32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__GREEN32; }
(^|{ws}*)END{ws}+TYPE{ws}*                        {	printf("END TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB_END_TYPE; }
(^|{ws}*)_CONSOLE{ws}*                            {	printf("_CONSOLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONSOLE; }
(^|{ws}*)RTRIM\${ws}*                             {	printf("RTRIM$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_RTRIM_DS; }
(^|{ws}*)NEW{ws}+LINE{ws}*                        {	printf("NEW LINE => %s\n", yytext); nchar += yyleng; return ENUM_QB_NEW_LINE; }
(^|{ws}*)_MEMFREE{ws}*                            {	printf("_MEMFREE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMFREE; }
(^|{ws}*)RIGHT\${ws}*                             {	printf("RIGHT$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_RIGHT_DS; }
(^|{ws}*)_SCREENX{ws}*                            {	printf("_SCREENX => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENX; }
(^|{ws}*)_SNDCOPY{ws}*                            {	printf("_SNDCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDCOPY; }
(^|{ws}*)ABSOLUTE{ws}*                            {	printf("ABSOLUTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_ABSOLUTE; }
(^|{ws}*)_MEMCOPY{ws}*                            {	printf("_MEMCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMCOPY; }
(^|{ws}*)_SCREENY{ws}*                            {	printf("_SCREENY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENY; }
(^|{ws}*)KEY{ws}+LIST{ws}*                        {	printf("KEY LIST => %s\n", yytext); nchar += yyleng; return ENUM_QB_KEY_LIST; }
(^|{ws}*)_MEMFILL{ws}*                            {	printf("_MEMFILL => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMFILL; }
(^|{ws}*)_ALPHA32{ws}*                            {	printf("_ALPHA32 => %s\n", yytext); nchar += yyleng; return ENUM_QB__ALPHA32; }
(^|{ws}*)IOCTL\${ws}*                             {	printf("IOCTL$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_IOCTL_DS; }
(^|{ws}*)_SNDPLAY{ws}*                            {	printf("_SNDPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAY; }
(^|{ws}*)UCASE\${ws}*                             {	printf("UCASE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_UCASE_DS; }
(^|{ws}*)PUT{ws}+FILE{ws}*                        {	printf("PUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_FILE; }
(^|{ws}*)PUT{ws}+QB64{ws}*                        {	printf("PUT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_QB64; }
(^|{ws}*)_SNDLOOP{ws}*                            {	printf("_SNDLOOP => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLOOP; }
_glHint                                           {	printf("_glHint => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glHint; }
(^|{ws}*)_SNDOPEN{ws}*                            {	printf("_SNDOPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDOPEN; }
(^|{ws}*)SPACE\${ws}*                             {	printf("SPACE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_SPACE_DS; }
(^|{ws}*)_STRICMP{ws}*                            {	printf("_STRICMP => %s\n", yytext); nchar += yyleng; return ENUM_QB__STRICMP; }
_glRects                                          {	printf("_glRects => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRects; }
_glRecti                                          {	printf("_glRecti => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRecti; }
(^|{ws}*)MKDMBF\${ws}*                            {	printf("MKDMBF$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKDMBF_DS; }
(^|{ws}*)\$ELSEIF{ws}*                            {	printf("$ELSEIF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSEIF; }
(^|{ws}*)_OPENHOST{ws}*                           {	printf("_OPENHOST => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENHOST; }
(^|{ws}*)_DONTWAIT{ws}*                           {	printf("_DONTWAIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DONTWAIT; }
_glAccum                                          {	printf("_glAccum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAccum; }
(^|{ws}*)_SNDLIMIT{ws}*                           {	printf("_SNDLIMIT => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDLIMIT; }
(^|{ws}*)RANDOMIZE{ws}*                           {	printf("RANDOMIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOMIZE; }
(^|{ws}*)STRING\${ws}*                            {	printf("STRING$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING_DS; }
(^|{ws}*)\$STATIC{ws}*                            {	printf("$STATIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_STATIC; }
(^|{ws}*)_SETALPHA{ws}*                           {	printf("_SETALPHA => %s\n", yytext); nchar += yyleng; return ENUM_QB__SETALPHA; }
(^|{ws}*)_SNDCLOSE{ws}*                           {	printf("_SNDCLOSE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDCLOSE; }
(^|{ws}*)_PRESERVE{ws}*                           {	printf("_PRESERVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRESERVE; }
(^|{ws}*)VARPTR\${ws}*                            {	printf("VARPTR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_VARPTR_DS; }
_glClear                                          {	printf("_glClear => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClear; }
(^|{ws}*)ON{ws}+UEVENT{ws}*                       {	printf("ON UEVENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_ON_UEVENT; }
_glBegin                                          {	printf("_glBegin => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBegin; }
(^|{ws}*)_PUTIMAGE{ws}*                           {	printf("_PUTIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PUTIMAGE; }
(^|{ws}*)_SNDPAUSE{ws}*                           {	printf("_SNDPAUSE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPAUSE; }
(^|{ws}*)\$RESIZE{ws}*                            {	printf("$RESIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_RESIZE; }
(^|{ws}*)MKSMBF\${ws}*                            {	printf("MKSMBF$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_MKSMBF_DS; }
(^|{ws}*)_UNSIGNED{ws}*                           {	printf("_UNSIGNED => %s\n", yytext); nchar += yyleng; return ENUM_QB__UNSIGNED; }
(^|{ws}*)_FREEFONT{ws}*                           {	printf("_FREEFONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREEFONT; }
_glMap1f                                          {	printf("_glMap1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap1f; }
_glMap1d                                          {	printf("_glMap1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap1d; }
_glFlush                                          {	printf("_glFlush => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFlush; }
(^|{ws}*)_LOADFONT{ws}*                           {	printf("_LOADFONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__LOADFONT; }
_glOrtho                                          {	printf("_glOrtho => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glOrtho; }
(^|{ws}*)_NEWIMAGE{ws}*                           {	printf("_NEWIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__NEWIMAGE; }
(^|{ws}*)_LASTAXIS{ws}*                           {	printf("_LASTAXIS => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTAXIS; }
(^|{ws}*)_KEYCLEAR{ws}*                           {	printf("_KEYCLEAR => %s\n", yytext); nchar += yyleng; return ENUM_QB__KEYCLEAR; }
_glRectf                                          {	printf("_glRectf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectf; }
_glMap2f                                          {	printf("_glMap2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap2f; }
_glFogiv                                          {	printf("_glFogiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogiv; }
_glMap2d                                          {	printf("_glMap2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMap2d; }
_glFogfv                                          {	printf("_glFogfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFogfv; }
(^|{ws}*)_MEMIMAGE{ws}*                           {	printf("_MEMIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMIMAGE; }
(^|{ws}*)CASE{ws}+ELSE{ws}*                       {	printf("CASE ELSE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CASE_ELSE; }
_glRectd                                          {	printf("_glRectd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectd; }
(^|{ws}*)INTERRUPT{ws}*                           {	printf("INTERRUPT => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTERRUPT; }
(^|{ws}*)WHILE{ws}+WEND{ws}*                      {	printf("WHILE WEND => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHILE_WEND; }
(^|{ws}*)WRITE{ws}+FILE{ws}*                      {	printf("WRITE FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WRITE_FILE; }
(^|{ws}*)_CONNECTED{ws}*                          {	printf("_CONNECTED => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONNECTED; }
(^|{ws}*)ENVIRON\${ws}*                           {	printf("ENVIRON$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_ENVIRON_DS; }
(^|{ws}*)COMMAND\${ws}*                           {	printf("COMMAND$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_COMMAND_DS; }
_glIndexi                                         {	printf("_glIndexi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexi; }
_glIndexs                                         {	printf("_glIndexs => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexs; }
(^|{ws}*)_MEMEXISTS{ws}*                          {	printf("_MEMEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMEXISTS; }
_glScalef                                         {	printf("_glScalef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScalef; }
_glBitmap                                         {	printf("_glBitmap => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBitmap; }
(^|{ws}*)_SHELLHIDE{ws}*                          {	printf("_SHELLHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SHELLHIDE; }
(^|{ws}*)SHELL{ws}+QB64{ws}*                      {	printf("SHELL QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_SHELL_QB64; }
_glIsList                                         {	printf("_glIsList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsList; }
(^|{ws}*)\$CONSOLE{ws}*                           {	printf("$CONSOLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_CONSOLE; }
(^|{ws}*)_MOUSEMOVE{ws}*                          {	printf("_MOUSEMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVE; }
_glIndexd                                         {	printf("_glIndexd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexd; }
(^|{ws}*)\$DYNAMIC{ws}*                           {	printf("$DYNAMIC => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_DYNAMIC; }
(^|{ws}*)_MOUSEHIDE{ws}*                          {	printf("_MOUSEHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEHIDE; }
(^|{ws}*)_PIXELSIZE{ws}*                          {	printf("_PIXELSIZE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PIXELSIZE; }
(^|{ws}*)_COPYIMAGE{ws}*                          {	printf("_COPYIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__COPYIMAGE; }
(^|{ws}*)_LOADIMAGE{ws}*                          {	printf("_LOADIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__LOADIMAGE; }
_glScaled                                         {	printf("_glScaled => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScaled; }
(^|{ws}*)_SNDGETPOS{ws}*                          {	printf("_SNDGETPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDGETPOS; }
(^|{ws}*)VIEW{ws}+PRINT{ws}*                      {	printf("VIEW PRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB_VIEW_PRINT; }
_glLighti                                         {	printf("_glLighti => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLighti; }
_glIndexf                                         {	printf("_glIndexf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexf; }
(^|{ws}*)PRINT{ws}+FILE{ws}*                      {	printf("PRINT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_FILE; }
(^|{ws}*)_LASTWHEEL{ws}*                          {	printf("_LASTWHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTWHEEL; }
(^|{ws}*)PRINT{ws}+QB64{ws}*                      {	printf("PRINT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_QB64; }
(^|{ws}*)_SNDPAUSED{ws}*                          {	printf("_SNDPAUSED => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPAUSED; }
(^|{ws}*)_INTEGER64{ws}*                          {	printf("_INTEGER64 => %s\n", yytext); nchar += yyleng; return ENUM_QB__INTEGER64; }
(^|{ws}*)_DIREXISTS{ws}*                          {	printf("_DIREXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__DIREXISTS; }
(^|{ws}*)INPUT{ws}+QB64{ws}*                      {	printf("INPUT QB64 => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_QB64; }
_glFinish                                         {	printf("_glFinish => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFinish; }
_glLightf                                         {	printf("_glLightf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightf; }
(^|{ws}*)LINE{ws}+INPUT{ws}*                      {	printf("LINE INPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE_INPUT; }
_glRectiv                                         {	printf("_glRectiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectiv; }
(^|{ws}*)\$ELSE{ws}+IF{ws}*                       {	printf("$ELSE IF => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_ELSE_IF; }
_glRectsv                                         {	printf("_glRectsv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectsv; }
(^|{ws}*)_DONTBLEND{ws}*                          {	printf("_DONTBLEND => %s\n", yytext); nchar += yyleng; return ENUM_QB__DONTBLEND; }
(^|{ws}*)INTERRUPTX{ws}*                          {	printf("INTERRUPTX => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTERRUPTX; }
_glEnable                                         {	printf("_glEnable => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnable; }
(^|{ws}*)_DEVICE\${ws}*                           {	printf("_DEVICE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICE_DS; }
(^|{ws}*)_FONTWIDTH{ws}*                          {	printf("_FONTWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONTWIDTH; }
(^|{ws}*)_ERRORLINE{ws}*                          {	printf("_ERRORLINE => %s\n", yytext); nchar += yyleng; return ENUM_QB__ERRORLINE; }
(^|{ws}*)_FREEIMAGE{ws}*                          {	printf("_FREEIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREEIMAGE; }
(^|{ws}*)_FREETIMER{ws}*                          {	printf("_FREETIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB__FREETIMER; }
(^|{ws}*)_MOUSESHOW{ws}*                          {	printf("_MOUSESHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSESHOW; }
(^|{ws}*)_SNDRAWLEN{ws}*                          {	printf("_SNDRAWLEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAWLEN; }
_glRectdv                                         {	printf("_glRectdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectdv; }
_glRectfv                                         {	printf("_glRectfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRectfv; }
(^|{ws}*)_SNDSETPOS{ws}*                          {	printf("_SNDSETPOS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDSETPOS; }
_glIndexfv                                        {	printf("_glIndexfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexfv; }
(^|{ws}*)_SCREENHIDE{ws}*                         {	printf("_SCREENHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENHIDE; }
_glDisable                                        {	printf("_glDisable => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDisable; }
_glIndexdv                                        {	printf("_glIndexdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexdv; }
(^|{ws}*)_SCREENSHOW{ws}*                         {	printf("_SCREENSHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENSHOW; }
_glPopName                                        {	printf("_glPopName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopName; }
_glIndexsv                                        {	printf("_glIndexsv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexsv; }
_glIndexub                                        {	printf("_glIndexub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexub; }
_glIndexiv                                        {	printf("_glIndexiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexiv; }
(^|{ws}*)_MEMELEMENT{ws}*                         {	printf("_MEMELEMENT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMELEMENT; }
_glLightfv                                        {	printf("_glLightfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightfv; }
(^|{ws}*)_SCREENMOVE{ws}*                         {	printf("_SCREENMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENMOVE; }
_glColor4s                                        {	printf("_glColor4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4s; }
(^|{ws}*)_PRINTIMAGE{ws}*                         {	printf("_PRINTIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTIMAGE; }
_glColor3i                                        {	printf("_glColor3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3i; }
_glColor3s                                        {	printf("_glColor3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3s; }
_glColor4b                                        {	printf("_glColor4b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4b; }
_glColor3f                                        {	printf("_glColor3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3f; }
_glFrustum                                        {	printf("_glFrustum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFrustum; }
_glScissor                                        {	printf("_glScissor => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glScissor; }
_glNewList                                        {	printf("_glNewList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNewList; }
_glColor3d                                        {	printf("_glColor3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3d; }
_glColor4d                                        {	printf("_glColor4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4d; }
_glColor4f                                        {	printf("_glColor4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4f; }
_glRotatef                                        {	printf("_glRotatef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRotatef; }
(^|{ws}*)_PRINTWIDTH{ws}*                         {	printf("_PRINTWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTWIDTH; }
(^|{ws}*)WHITE{ws}+SPACE{ws}*                     {	printf("WHITE SPACE => %s\n", yytext); nchar += yyleng; return ENUM_QB_WHITE_SPACE; }
_glLightiv                                        {	printf("_glLightiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightiv; }
_glColor3b                                        {	printf("_glColor3b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3b; }
_glColor4i                                        {	printf("_glColor4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4i; }
_glEndList                                        {	printf("_glEndList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEndList; }
_glLogicOp                                        {	printf("_glLogicOp => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLogicOp; }
_glRotated                                        {	printf("_glRotated => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRotated; }
(^|{ws}*)\$CHECKING{ws}*                          {	printf("$CHECKING => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_CHECKING; }
(^|{ws}*)_SNDOPENRAW{ws}*                         {	printf("_SNDOPENRAW => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDOPENRAW; }
(^|{ws}*)OPTION{ws}+BASE{ws}*                     {	printf("OPTION BASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_OPTION_BASE; }
(^|{ws}*)PRINT{ws}+USING{ws}*                     {	printf("PRINT USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_USING; }
(^|{ws}*)_LASTBUTTON{ws}*                         {	printf("_LASTBUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__LASTBUTTON; }
_glTexGend                                        {	printf("_glTexGend => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGend; }
(^|{ws}*)_MOUSEINPUT{ws}*                         {	printf("_MOUSEINPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEINPUT; }
(^|{ws}*)_SNDRAWDONE{ws}*                         {	printf("_SNDRAWDONE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDRAWDONE; }
(^|{ws}*)_MOUSEWHEEL{ws}*                         {	printf("_MOUSEWHEEL => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEWHEEL; }
(^|{ws}*)_OPENCLIENT{ws}*                         {	printf("_OPENCLIENT => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENCLIENT; }
(^|{ws}*)_FILEEXISTS{ws}*                         {	printf("_FILEEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__FILEEXISTS; }
_glTexEnvf                                        {	printf("_glTexEnvf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvf; }
_glTexEnvi                                        {	printf("_glTexEnvi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvi; }
(^|{ws}*)_FONTHEIGHT{ws}*                         {	printf("_FONTHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONTHEIGHT; }
_glTexGenf                                        {	printf("_glTexGenf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGenf; }
(^|{ws}*)_SNDPLAYING{ws}*                         {	printf("_SNDPLAYING => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYING; }
_glTexGeni                                        {	printf("_glTexGeni => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGeni; }
(^|{ws}*)SELECT{ws}+CASE{ws}*                     {	printf("SELECT CASE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SELECT_CASE; }
_glColor3us                                       {	printf("_glColor3us => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3us; }
_glVertex4d                                       {	printf("_glVertex4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4d; }
_glNormal3f                                       {	printf("_glNormal3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3f; }
_glColor3ui                                       {	printf("_glColor3ui => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ui; }
_glGenLists                                       {	printf("_glGenLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGenLists; }
(^|{ws}*)_DEVICEINPUT{ws}*                        {	printf("_DEVICEINPUT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEVICEINPUT; }
_glColor4dv                                       {	printf("_glColor4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4dv; }
(^|{ws}*)_STARTDIR\${ws}*                         {	printf("_STARTDIR$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__STARTDIR_DS; }
_glColor4bv                                       {	printf("_glColor4bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4bv; }
_glColor3ub                                       {	printf("_glColor3ub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ub; }
_glColor3sv                                       {	printf("_glColor3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3sv; }
_glTexGenfv                                       {	printf("_glTexGenfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGenfv; }
_glColor3bv                                       {	printf("_glColor3bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3bv; }
_glIndexubv                                       {	printf("_glIndexubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexubv; }
_glGetError                                       {	printf("_glGetError => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetError; }
_glColor3fv                                       {	printf("_glColor3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3fv; }
_glVertex4i                                       {	printf("_glVertex4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4i; }
_glColor4fv                                       {	printf("_glColor4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4fv; }
_glNormal3d                                       {	printf("_glNormal3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3d; }
_glColor3iv                                       {	printf("_glColor3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3iv; }
_glVertex4s                                       {	printf("_glVertex4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4s; }
_glColor4sv                                       {	printf("_glColor4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4sv; }
_glNormal3s                                       {	printf("_glNormal3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3s; }
(^|{ws}*)BIT{ws}+VARIABLE{ws}*                    {	printf("BIT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BIT_VARIABLE; }
_glCullFace                                       {	printf("_glCullFace => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCullFace; }
_glTexEnvfv                                       {	printf("_glTexEnvfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnvfv; }
_glPushName                                       {	printf("_glPushName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushName; }
_glVertex2i                                       {	printf("_glVertex2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2i; }
(^|{ws}*)_OFFSET{ws}+TYPE{ws}*                    {	printf("_OFFSET TYPE => %s\n", yytext); nchar += yyleng; return ENUM_QB__OFFSET_TYPE; }
_glEdgeFlag                                       {	printf("_glEdgeFlag => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlag; }
_glNormal3i                                       {	printf("_glNormal3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3i; }
_glVertex4f                                       {	printf("_glVertex4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4f; }
_glTexEnviv                                       {	printf("_glTexEnviv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexEnviv; }
_glColor4ub                                       {	printf("_glColor4ub => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ub; }
_glNormal3b                                       {	printf("_glNormal3b => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3b; }
_glColor4ui                                       {	printf("_glColor4ui => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ui; }
_glVertex3s                                       {	printf("_glVertex3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3s; }
(^|{ws}*)LPRINT{ws}+USING{ws}*                    {	printf("LPRINT USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_LPRINT_USING; }
(^|{ws}*)NOT{ws}+EQUAL{ws}+TO{ws}*                {	printf("NOT EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_NOT_EQUAL_TO; }
_glColor4us                                       {	printf("_glColor4us => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4us; }
_glColor4iv                                       {	printf("_glColor4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4iv; }
_glColor3dv                                       {	printf("_glColor3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3dv; }
(^|{ws}*)_COPYPALETTE{ws}*                        {	printf("_COPYPALETTE => %s\n", yytext); nchar += yyleng; return ENUM_QB__COPYPALETTE; }
(^|{ws}*)PUT{ws}+GRAPHICS{ws}*                    {	printf("PUT GRAPHICS => %s\n", yytext); nchar += yyleng; return ENUM_QB_PUT_GRAPHICS; }
_glLoadName                                       {	printf("_glLoadName => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadName; }
_glListBase                                       {	printf("_glListBase => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glListBase; }
(^|{ws}*)_RESIZEWIDTH{ws}*                        {	printf("_RESIZEWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZEWIDTH; }
_glVertex2s                                       {	printf("_glVertex2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2s; }
(^|{ws}*)_SCREENPRINT{ws}*                        {	printf("_SCREENPRINT => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENPRINT; }
_glVertex3i                                       {	printf("_glVertex3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3i; }
_glVertex2f                                       {	printf("_glVertex2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2f; }
(^|{ws}*)_SCREENCLICK{ws}*                        {	printf("_SCREENCLICK => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENCLICK; }
_glVertex3f                                       {	printf("_glVertex3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3f; }
_glTexGendv                                       {	printf("_glTexGendv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGendv; }
(^|{ws}*)_SCREENIMAGE{ws}*                        {	printf("_SCREENIMAGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENIMAGE; }
_glViewport                                       {	printf("_glViewport => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glViewport; }
_glVertex3d                                       {	printf("_glVertex3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3d; }
(^|{ws}*)_AUTODISPLAY{ws}*                        {	printf("_AUTODISPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__AUTODISPLAY; }
(^|{ws}*)_MOUSEBUTTON{ws}*                        {	printf("_MOUSEBUTTON => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEBUTTON; }
(^|{ws}*)_MAPTRIANGLE{ws}*                        {	printf("_MAPTRIANGLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MAPTRIANGLE; }
_glVertex2d                                       {	printf("_glVertex2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2d; }
_glTexGeniv                                       {	printf("_glTexGeniv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexGeniv; }
(^|{ws}*)_SNDPLAYFILE{ws}*                        {	printf("_SNDPLAYFILE => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYFILE; }
(^|{ws}*)_SNDPLAYCOPY{ws}*                        {	printf("_SNDPLAYCOPY => %s\n", yytext); nchar += yyleng; return ENUM_QB__SNDPLAYCOPY; }
(^|{ws}*)_PRINTSTRING{ws}*                        {	printf("_PRINTSTRING => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTSTRING; }
(^|{ws}*)WRITE{ws}+SCREEN{ws}*                    {	printf("WRITE SCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_WRITE_SCREEN; }
_glGetMapiv                                       {	printf("_glGetMapiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapiv; }
_glGetMapfv                                       {	printf("_glGetMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapfv; }
(^|{ws}*)_DEPTHBUFFER{ws}*                        {	printf("_DEPTHBUFFER => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEPTHBUFFER; }
_glGetMapdv                                       {	printf("_glGetMapdv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMapdv; }
_glCallList                                       {	printf("_glCallList => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCallList; }
_glIsTexture                                      {	printf("_glIsTexture => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsTexture; }
_glEvalMesh2                                      {	printf("_glEvalMesh2 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalMesh2; }
_glNormal3bv                                      {	printf("_glNormal3bv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3bv; }
_glNormal3iv                                      {	printf("_glNormal3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3iv; }
_glIndexMask                                      {	printf("_glIndexMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexMask; }
_glEvalMesh1                                      {	printf("_glEvalMesh1 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalMesh1; }
_glVertex3dv                                      {	printf("_glVertex3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3dv; }
_glPopAttrib                                      {	printf("_glPopAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopAttrib; }
_glPopMatrix                                      {	printf("_glPopMatrix => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopMatrix; }
_glPointSize                                      {	printf("_glPointSize => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPointSize; }
_glGetFloatv                                      {	printf("_glGetFloatv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetFloatv; }
_glPixelZoom                                      {	printf("_glPixelZoom => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelZoom; }
_glNormal3sv                                      {	printf("_glNormal3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3sv; }
_glLineWidth                                      {	printf("_glLineWidth => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLineWidth; }
_glMapGrid1f                                      {	printf("_glMapGrid1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid1f; }
_glVertex3fv                                      {	printf("_glVertex3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3fv; }
_glVertex3iv                                      {	printf("_glVertex3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3iv; }
_glFrontFace                                      {	printf("_glFrontFace => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFrontFace; }
_glVertex2iv                                      {	printf("_glVertex2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2iv; }
_glMapGrid1d                                      {	printf("_glMapGrid1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid1d; }
_glVertex2sv                                      {	printf("_glVertex2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2sv; }
(^|{ws}*)CALL{ws}+ABSOLUTE{ws}*                   {	printf("CALL ABSOLUTE => %s\n", yytext); nchar += yyleng; return ENUM_QB_CALL_ABSOLUTE; }
_glNormal3dv                                      {	printf("_glNormal3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3dv; }
_glMapGrid2d                                      {	printf("_glMapGrid2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid2d; }
_glIsEnabled                                      {	printf("_glIsEnabled => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIsEnabled; }
_glGetString                                      {	printf("_glGetString => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetString; }
_glNormal3fv                                      {	printf("_glNormal3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormal3fv; }
_glInitNames                                      {	printf("_glInitNames => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glInitNames; }
_glMateriali                                      {	printf("_glMateriali => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMateriali; }
_glMapGrid2f                                      {	printf("_glMapGrid2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMapGrid2f; }
_glMaterialf                                      {	printf("_glMaterialf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialf; }
_glVertex3sv                                      {	printf("_glVertex3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex3sv; }
_glColor4usv                                      {	printf("_glColor4usv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4usv; }
(^|{ws}*)_DESKTOPWIDTH{ws}*                       {	printf("_DESKTOPWIDTH => %s\n", yytext); nchar += yyleng; return ENUM_QB__DESKTOPWIDTH; }
_glStencilOp                                      {	printf("_glStencilOp => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilOp; }
_glCallLists                                      {	printf("_glCallLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCallLists; }
_glBlendFunc                                      {	printf("_glBlendFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBlendFunc; }
_glClipPlane                                      {	printf("_glClipPlane => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClipPlane; }
_glVertex4iv                                      {	printf("_glVertex4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4iv; }
_glColor3uiv                                      {	printf("_glColor3uiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3uiv; }
_glColor3ubv                                      {	printf("_glColor3ubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3ubv; }
(^|{ws}*)_SCREENEXISTS{ws}*                       {	printf("_SCREENEXISTS => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENEXISTS; }
_glVertex4dv                                      {	printf("_glVertex4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4dv; }
(^|{ws}*)PALETTE{ws}+USING{ws}*                   {	printf("PALETTE USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_PALETTE_USING; }
(^|{ws}*)_RESIZEHEIGHT{ws}*                       {	printf("_RESIZEHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__RESIZEHEIGHT; }
(^|{ws}*)\$SCREENHIDE{ws}*                        {	printf("$SCREENHIDE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_SCREENHIDE; }
_glVertex2dv                                      {	printf("_glVertex2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2dv; }
_glVertex4sv                                      {	printf("_glVertex4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4sv; }
(^|{ws}*)_DEFAULTCOLOR{ws}*                       {	printf("_DEFAULTCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEFAULTCOLOR; }
(^|{ws}*)_CONSOLETITLE{ws}*                       {	printf("_CONSOLETITLE => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONSOLETITLE; }
_glAlphaFunc                                      {	printf("_glAlphaFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAlphaFunc; }
(^|{ws}*)PEN{ws}*                                 {	printf("PEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_PEN_STATEMENT; }
_glColor3usv                                      {	printf("_glColor3usv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor3usv; }
(^|{ws}*)_BUTTONCHANGE{ws}*                       {	printf("_BUTTONCHANGE => %s\n", yytext); nchar += yyleng; return ENUM_QB__BUTTONCHANGE; }
(^|{ws}*)KEY{ws}*                                 {	printf("KEY => %s\n", yytext); nchar += yyleng; return ENUM_QB_KEY_STATEMENT; }
_glDepthMask                                      {	printf("_glDepthMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthMask; }
_glDepthFunc                                      {	printf("_glDepthFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthFunc; }
(^|{ws}*)_COMMANDCOUNT{ws}*                       {	printf("_COMMANDCOUNT => %s\n", yytext); nchar += yyleng; return ENUM_QB__COMMANDCOUNT; }
_glEdgeFlagv                                      {	printf("_glEdgeFlagv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlagv; }
(^|{ws}*)BYTE{ws}+VARIABLE{ws}*                   {	printf("BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_BYTE_VARIABLE; }
(^|{ws}*)LONG{ws}+VARIABLE{ws}*                   {	printf("LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }
(^|{ws}*)\$SCREENSHOW{ws}*                        {	printf("$SCREENSHOW => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_SCREENSHOW; }
_glVertex2fv                                      {	printf("_glVertex2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex2fv; }
_glColor4uiv                                      {	printf("_glColor4uiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4uiv; }
_glColorMask                                      {	printf("_glColorMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorMask; }
_glColor4ubv                                      {	printf("_glColor4ubv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColor4ubv; }
(^|{ws}*)_DISPLAYORDER{ws}*                       {	printf("_DISPLAYORDER => %s\n", yytext); nchar += yyleng; return ENUM_QB__DISPLAYORDER; }
_glVertex4fv                                      {	printf("_glVertex4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertex4fv; }
_glTexCoord2s                                     {	printf("_glTexCoord2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2s; }
_glTexCoord1s                                     {	printf("_glTexCoord1s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1s; }
_glTexCoord3i                                     {	printf("_glTexCoord3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3i; }
_glTexCoord2f                                     {	printf("_glTexCoord2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2f; }
(^|{ws}*)FLOAT{ws}+VARIABLE{ws}*                  {	printf("FLOAT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }
_glTexCoord3f                                     {	printf("_glTexCoord3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3f; }
_glTexCoord2i                                     {	printf("_glTexCoord2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2i; }
_glTexImage2D                                     {	printf("_glTexImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexImage2D; }
_glTranslated                                     {	printf("_glTranslated => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTranslated; }
_glTexCoord3d                                     {	printf("_glTexCoord3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3d; }
_glTexCoord2d                                     {	printf("_glTexCoord2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2d; }
_glMaterialiv                                     {	printf("_glMaterialiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialiv; }
_glTexImage1D                                     {	printf("_glTexImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexImage1D; }
_glRenderMode                                     {	printf("_glRenderMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRenderMode; }
_glTexCoord4s                                     {	printf("_glTexCoord4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4s; }
_glReadPixels                                     {	printf("_glReadPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glReadPixels; }
_glReadBuffer                                     {	printf("_glReadBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glReadBuffer; }
_glPushAttrib                                     {	printf("_glPushAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushAttrib; }
_glPushMatrix                                     {	printf("_glPushMatrix => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushMatrix; }
_glPixelMapfv                                     {	printf("_glPixelMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapfv; }
_glTexCoord4i                                     {	printf("_glTexCoord4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4i; }
_glShadeModel                                     {	printf("_glShadeModel => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glShadeModel; }
_glTranslatef                                     {	printf("_glTranslatef => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTranslatef; }
_glTexCoord4f                                     {	printf("_glTexCoord4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4f; }
_glTexCoord4d                                     {	printf("_glTexCoord4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4d; }
_glTexCoord1i                                     {	printf("_glTexCoord1i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1i; }
_glTexCoord1f                                     {	printf("_glTexCoord1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1f; }
_glMatrixMode                                     {	printf("_glMatrixMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMatrixMode; }
_glTexCoord1d                                     {	printf("_glTexCoord1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1d; }
_glMaterialfv                                     {	printf("_glMaterialfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMaterialfv; }
_glTexCoord3s                                     {	printf("_glTexCoord3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3s; }
(^|{ws}*)SEEK{ws}*                                {	printf("SEEK => %s\n", yytext); nchar += yyleng; return ENUM_QB_SEEK_STATEMENT; }
_glDepthRange                                     {	printf("_glDepthRange => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDepthRange; }
_glCopyPixels                                     {	printf("_glCopyPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyPixels; }
(^|{ws}*)NEXT{ws}*                                {	printf("NEXT => %s\n", yytext); nchar += yyleng; return ENUM_QB_NEXT_STATEMENT; }
(^|{ws}*)LOOP{ws}*                                {	printf("LOOP => %s\n", yytext); nchar += yyleng; return ENUM_QB_LOOP_STATEMENT; }
_glDrawBuffer                                     {	printf("_glDrawBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawBuffer; }
_glDrawArrays                                     {	printf("_glDrawArrays => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawArrays; }
_glClearIndex                                     {	printf("_glClearIndex => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearIndex; }
_glClearDepth                                     {	printf("_glClearDepth => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearDepth; }
_glGetLightiv                                     {	printf("_glGetLightiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetLightiv; }
_glClearAccum                                     {	printf("_glClearAccum => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearAccum; }
(^|{ws}*)PLAY{ws}*                                {	printf("PLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB_PLAY_STATEMENT; }
_glGetDoublev                                     {	printf("_glGetDoublev => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetDoublev; }
_glClearColor                                     {	printf("_glClearColor => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearColor; }
_glGetLightfv                                     {	printf("_glGetLightfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetLightfv; }
(^|{ws}*)_MOUSEPIPEOPEN{ws}*                      {	printf("_MOUSEPIPEOPEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEPIPEOPEN; }
(^|{ws}*)_DESKTOPHEIGHT{ws}*                      {	printf("_DESKTOPHEIGHT => %s\n", yytext); nchar += yyleng; return ENUM_QB__DESKTOPHEIGHT; }
_glEvalPoint1                                     {	printf("_glEvalPoint1 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalPoint1; }
_glDrawPixels                                     {	printf("_glDrawPixels => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawPixels; }
(^|{ws}*)_MEM{ws}*                                {	printf("_MEM => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEM_STATEMENT; }
_glEvalPoint2                                     {	printf("_glEvalPoint2 => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalPoint2; }
_glTexCoord1dv                                    {	printf("_glTexCoord1dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1dv; }
_glTexCoord2dv                                    {	printf("_glTexCoord2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2dv; }
_glTexCoord1sv                                    {	printf("_glTexCoord1sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1sv; }
_glTexCoord1fv                                    {	printf("_glTexCoord1fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1fv; }
_glTexCoord1iv                                    {	printf("_glTexCoord1iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord1iv; }
(^|{ws}*)TIMER{ws}*                               {	printf("TIMER => %s\n", yytext); nchar += yyleng; return ENUM_QB_TIMER_STATEMENT; }
_glDeleteLists                                    {	printf("_glDeleteLists => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDeleteLists; }
_glRasterPos3s                                    {	printf("_glRasterPos3s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3s; }
_glRasterPos3i                                    {	printf("_glRasterPos3i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3i; }
_glRasterPos3f                                    {	printf("_glRasterPos3f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3f; }
_glRasterPos3d                                    {	printf("_glRasterPos3d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3d; }
_glRasterPos4d                                    {	printf("_glRasterPos4d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4d; }
_glRasterPos4f                                    {	printf("_glRasterPos4f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4f; }
_glStencilFunc                                    {	printf("_glStencilFunc => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilFunc; }
_glTexCoord2fv                                    {	printf("_glTexCoord2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2fv; }
_glRasterPos4s                                    {	printf("_glRasterPos4s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4s; }
_glRasterPos4i                                    {	printf("_glRasterPos4i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4i; }
_glBindTexture                                    {	printf("_glBindTexture => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glBindTexture; }
(^|{ws}*)_MOUSEMOVEMENTY{ws}*                     {	printf("_MOUSEMOVEMENTY => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVEMENTY; }
(^|{ws}*)_MOUSEMOVEMENTX{ws}*                     {	printf("_MOUSEMOVEMENTX => %s\n", yytext); nchar += yyleng; return ENUM_QB__MOUSEMOVEMENTX; }
(^|{ws}*)_OPENCONNECTION{ws}*                     {	printf("_OPENCONNECTION => %s\n", yytext); nchar += yyleng; return ENUM_QB__OPENCONNECTION; }
(^|{ws}*)DECLARE{ws}+LIBRARY{ws}*                 {	printf("DECLARE LIBRARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE_LIBRARY; }
(^|{ws}*)LINE{ws}+INPUT{ws}+FILE{ws}*             {	printf("LINE INPUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_LINE_INPUT_FILE; }
(^|{ws}*)INPUT{ws}+FILE{ws}+MODE{ws}*             {	printf("INPUT FILE MODE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_FILE_MODE; }
(^|{ws}*)_FONT{ws}*                               {	printf("_FONT => %s\n", yytext); nchar += yyleng; return ENUM_QB__FONT_STATEMENT; }
(^|{ws}*)_DEST{ws}*                               {	printf("_DEST => %s\n", yytext); nchar += yyleng; return ENUM_QB__DEST_STATEMENT; }
(^|{ws}*)OFFSET{ws}+VARIABLE{ws}*                 {	printf("OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_OFFSET_VARIABLE; }
(^|{ws}*)DOUBLE{ws}+VARIABLE{ws}*                 {	printf("DOUBLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE_VARIABLE; }
(^|{ws}*)SINGLE{ws}+VARIABLE{ws}*                 {	printf("SINGLE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE_VARIABLE; }
(^|{ws}*)STRING{ws}+VARIABLE{ws}*                 {	printf("STRING VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRING_VARIABLE; }
_glTexCoord4sv                                    {	printf("_glTexCoord4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4sv; }
(^|{ws}*)MID{ws}+\$STATMENT{ws}*                  {	printf("MID_$STATMENT => %s\n", yytext); nchar += yyleng; return ENUM_QB_MID_DS_STATMENT; }
_glRasterPos2s                                    {	printf("_glRasterPos2s => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2s; }
_glTexCoord3fv                                    {	printf("_glTexCoord3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3fv; }
_glTexCoord3dv                                    {	printf("_glTexCoord3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3dv; }
(^|{ws}*)STRIG{ws}*                               {	printf("STRIG => %s\n", yytext); nchar += yyleng; return ENUM_QB_STRIG_STATEMENT; }
_glTexCoord2sv                                    {	printf("_glTexCoord2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2sv; }
_glTexCoord3iv                                    {	printf("_glTexCoord3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3iv; }
(^|{ws}*)RANDOMIZE{ws}+USING{ws}*                 {	printf("RANDOMIZE USING => %s\n", yytext); nchar += yyleng; return ENUM_QB_RANDOMIZE_USING; }
_glTexCoord4iv                                    {	printf("_glTexCoord4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4iv; }
_glTexCoord4fv                                    {	printf("_glTexCoord4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4fv; }
_glTexCoord4dv                                    {	printf("_glTexCoord4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord4dv; }
_glTexCoord3sv                                    {	printf("_glTexCoord3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord3sv; }
_glTexCoord2iv                                    {	printf("_glTexCoord2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoord2iv; }
_glStencilMask                                    {	printf("_glStencilMask => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glStencilMask; }
_glGetTexImage                                    {	printf("_glGetTexImage => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexImage; }
_glGetTexGeniv                                    {	printf("_glGetTexGeniv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGeniv; }
_glPassThrough                                    {	printf("_glPassThrough => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPassThrough; }
_glLineStipple                                    {	printf("_glLineStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLineStipple; }
_glLoadMatrixf                                    {	printf("_glLoadMatrixf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadMatrixf; }
_glGenTextures                                    {	printf("_glGenTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGenTextures; }
_glEvalCoord1d                                    {	printf("_glEvalCoord1d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1d; }
_glEvalCoord2f                                    {	printf("_glEvalCoord2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2f; }
_glEvalCoord2d                                    {	printf("_glEvalCoord2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2d; }
_glPixelMapuiv                                    {	printf("_glPixelMapuiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapuiv; }
_glPixelStoref                                    {	printf("_glPixelStoref => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelStoref; }
_glLightModelf                                    {	printf("_glLightModelf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModelf; }
_glPixelStorei                                    {	printf("_glPixelStorei => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelStorei; }
_glEvalCoord1f                                    {	printf("_glEvalCoord1f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1f; }
_glGetTexEnvfv                                    {	printf("_glGetTexEnvfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexEnvfv; }
_glPixelMapusv                                    {	printf("_glPixelMapusv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelMapusv; }
_glPolygonMode                                    {	printf("_glPolygonMode => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonMode; }
_glGetBooleanv                                    {	printf("_glGetBooleanv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetBooleanv; }
_glLightModeli                                    {	printf("_glLightModeli => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModeli; }
_glGetTexGenfv                                    {	printf("_glGetTexGenfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGenfv; }
_glRasterPos2f                                    {	printf("_glRasterPos2f => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2f; }
_glMultMatrixd                                    {	printf("_glMultMatrixd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMultMatrixd; }
_glGetPointerv                                    {	printf("_glGetPointerv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPointerv; }
_glGetTexGendv                                    {	printf("_glGetTexGendv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexGendv; }
_glGetTexEnviv                                    {	printf("_glGetTexEnviv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexEnviv; }
_glRasterPos2i                                    {	printf("_glRasterPos2i => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2i; }
_glLoadMatrixd                                    {	printf("_glLoadMatrixd => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadMatrixd; }
_glRasterPos2d                                    {	printf("_glRasterPos2d => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2d; }
_glGetIntegerv                                    {	printf("_glGetIntegerv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetIntegerv; }
_glMultMatrixf                                    {	printf("_glMultMatrixf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glMultMatrixf; }
(^|{ws}*)SCREEN{ws}*                              {	printf("SCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB_SCREEN_STATEMENT; }
_glEvalCoord2fv                                   {	printf("_glEvalCoord2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2fv; }
_glLightModeliv                                   {	printf("_glLightModeliv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModeliv; }
_glRasterPos2sv                                   {	printf("_glRasterPos2sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2sv; }
_glGetClipPlane                                   {	printf("_glGetClipPlane => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetClipPlane; }
_glLoadIdentity                                   {	printf("_glLoadIdentity => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLoadIdentity; }
(^|{ws}*)INTEGER{ws}+VARIABLE{ws}*                {	printf("INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER_VARIABLE; }
_glEvalCoord2dv                                   {	printf("_glEvalCoord2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord2dv; }
(^|{ws}*)PRINT{ws}+USING{ws}+FILE{ws}*            {	printf("PRINT USING FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_PRINT_USING_FILE; }
_glLightModelfv                                   {	printf("_glLightModelfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glLightModelfv; }
_glRasterPos4fv                                   {	printf("_glRasterPos4fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4fv; }
_glRasterPos4dv                                   {	printf("_glRasterPos4dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4dv; }
_glDrawElements                                   {	printf("_glDrawElements => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDrawElements; }
_glRasterPos4iv                                   {	printf("_glRasterPos4iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4iv; }
_glRasterPos4sv                                   {	printf("_glRasterPos4sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos4sv; }
_glRasterPos2dv                                   {	printf("_glRasterPos2dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2dv; }
_glRasterPos3sv                                   {	printf("_glRasterPos3sv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3sv; }
_glRasterPos3dv                                   {	printf("_glRasterPos3dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3dv; }
_glRasterPos2iv                                   {	printf("_glRasterPos2iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2iv; }
_glRasterPos3fv                                   {	printf("_glRasterPos3fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3fv; }
_glRasterPos2fv                                   {	printf("_glRasterPos2fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos2fv; }
_glRasterPos3iv                                   {	printf("_glRasterPos3iv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glRasterPos3iv; }
(^|{ws}*)_BLEND{ws}*                              {	printf("_BLEND => %s\n", yytext); nchar += yyleng; return ENUM_QB__BLEND_STATEMENT; }
(^|{ws}*)_BACKGROUNDCOLOR{ws}*                    {	printf("_BACKGROUNDCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__BACKGROUNDCOLOR; }
_glColorPointer                                   {	printf("_glColorPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorPointer; }
_glSelectBuffer                                   {	printf("_glSelectBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glSelectBuffer; }
_glClearStencil                                   {	printf("_glClearStencil => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glClearStencil; }
_glArrayElement                                   {	printf("_glArrayElement => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glArrayElement; }
_glEvalCoord1dv                                   {	printf("_glEvalCoord1dv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1dv; }
_glEvalCoord1fv                                   {	printf("_glEvalCoord1fv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEvalCoord1fv; }
_glIndexPointer                                   {	printf("_glIndexPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glIndexPointer; }
_glVertexPointer                                  {	printf("_glVertexPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glVertexPointer; }
_glTexParameterf                                  {	printf("_glTexParameterf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameterf; }
(^|{ws}*)_MEMGET{ws}*                             {	printf("_MEMGET => %s\n", yytext); nchar += yyleng; return ENUM_QB__MEMGET_STATEMENT; }
_glTexSubImage2D                                  {	printf("_glTexSubImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexSubImage2D; }
_glTexSubImage1D                                  {	printf("_glTexSubImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexSubImage1D; }
_glTexParameteri                                  {	printf("_glTexParameteri => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameteri; }
(^|{ws}*)DATE\${ws}*                              {	printf("DATE$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_DATE_DS_STATEMENT; }
_glNormalPointer                                  {	printf("_glNormalPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glNormalPointer; }
_glGetMaterialiv                                  {	printf("_glGetMaterialiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMaterialiv; }
_glPolygonOffset                                  {	printf("_glPolygonOffset => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonOffset; }
_glGetMaterialfv                                  {	printf("_glGetMaterialfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetMaterialfv; }
_glColorMaterial                                  {	printf("_glColorMaterial => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glColorMaterial; }
(^|{ws}*)TIME\${ws}*                              {	printf("TIME$ => %s\n", yytext); nchar += yyleng; return ENUM_QB_TIME_DS_STATEMENT; }
_glGetPixelMapfv                                  {	printf("_glGetPixelMapfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapfv; }
(^|{ws}*)UNSIGNED{ws}+VARIABLE{ws}*               {	printf("UNSIGNED VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_VARIABLE; }
(^|{ws}*)UNKNOWN{ws}+CHARACTER{ws}*               {	printf("UNKNOWN CHARACTER => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNKNOWN_CHARACTER; }
(^|{ws}*)STANDARD{ws}+VARIABLE{ws}*               {	printf("STANDARD VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_STANDARD_VARIABLE; }
(^|{ws}*)_DISPLAY{ws}*                            {	printf("_DISPLAY => %s\n", yytext); nchar += yyleng; return ENUM_QB__DISPLAY_STATEMENT; }
_glPolygonStipple                                 {	printf("_glPolygonStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPolygonStipple; }
_glCopyTexImage2D                                 {	printf("_glCopyTexImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexImage2D; }
_glDeleteTextures                                 {	printf("_glDeleteTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDeleteTextures; }
(^|{ws}*)_MIDDLE{ws}+SCREENMOVE{ws}*              {	printf("_MIDDLE SCREENMOVE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MIDDLE_SCREENMOVE; }
_glCopyTexImage1D                                 {	printf("_glCopyTexImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexImage1D; }
_glPixelTransferi                                 {	printf("_glPixelTransferi => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelTransferi; }
_glGetPixelMapuiv                                 {	printf("_glGetPixelMapuiv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapuiv; }
(^|{ws}*)\$VIRTUALKEYBOARD{ws}*                   {	printf("$VIRTUALKEYBOARD => %s\n", yytext); nchar += yyleng; return ENUM_QB_DS_VIRTUALKEYBOARD; }
_glGetPixelMapusv                                 {	printf("_glGetPixelMapusv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPixelMapusv; }
(^|{ws}*)INTEGER64{ws}+VARIABLE{ws}*              {	printf("INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER64_VARIABLE; }
_glFeedbackBuffer                                 {	printf("_glFeedbackBuffer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glFeedbackBuffer; }
_glTexParameterfv                                 {	printf("_glTexParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameterfv; }
_glPixelTransferf                                 {	printf("_glPixelTransferf => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPixelTransferf; }
_glTexParameteriv                                 {	printf("_glTexParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexParameteriv; }
_glEdgeFlagPointer                                {	printf("_glEdgeFlagPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEdgeFlagPointer; }
_glPopClientAttrib                                {	printf("_glPopClientAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPopClientAttrib; }
_glTexCoordPointer                                {	printf("_glTexCoordPointer => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glTexCoordPointer; }
(^|{ws}*)INPUT{ws}+FILE{ws}*                      {	printf("INPUT FILE => %s\n", yytext); nchar += yyleng; return ENUM_QB_INPUT_FILE_STATEMENT; }
(^|{ws}*)_PRINTMODE{ws}*                          {	printf("_PRINTMODE => %s\n", yytext); nchar += yyleng; return ENUM_QB__PRINTMODE_STATEMENT; }
_glPushClientAttrib                               {	printf("_glPushClientAttrib => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPushClientAttrib; }
(^|{ws}*)_SCREENICON{ws}*                         {	printf("_SCREENICON => %s\n", yytext); nchar += yyleng; return ENUM_QB__SCREENICON_STATEMENT; }
_glInterleavedArrays                              {	printf("_glInterleavedArrays => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glInterleavedArrays; }
(^|{ws}*)_CONNECTIONADDRESS\${ws}*                {	printf("_CONNECTIONADDRESS$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONNECTIONADDRESS_DS; }
(^|{ws}*)UNSIGNED{ws}+BIT{ws}+VARIABLE{ws}*       {	printf("UNSIGNED BIT VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BIT_VARIABLE; }
_glGetPolygonStipple                              {	printf("_glGetPolygonStipple => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetPolygonStipple; }
_glCopyTexSubImage2D                              {	printf("_glCopyTexSubImage2D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexSubImage2D; }
(^|{ws}*)_FULLSCREEN{ws}*                         {	printf("_FULLSCREEN => %s\n", yytext); nchar += yyleng; return ENUM_QB__FULLSCREEN_STATEMENT; }
(^|{ws}*)_CLEARCOLOR{ws}*                         {	printf("_CLEARCOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLEARCOLOR_STATEMENT; }
_glGetTexParameterfv                              {	printf("_glGetTexParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexParameterfv; }
(^|{ws}*)_MAPUNICODE{ws}*                         {	printf("_MAPUNICODE => %s\n", yytext); nchar += yyleng; return ENUM_QB__MAPUNICODE_STATEMENT; }
(^|{ws}*)LESS{ws}+THAN{ws}+OR{ws}+EQUAL{ws}+TO{ws}*          {	printf("LESS THAN OR EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }
_glGetTexParameteriv                              {	printf("_glGetTexParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexParameteriv; }
_glCopyTexSubImage1D                              {	printf("_glCopyTexSubImage1D => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glCopyTexSubImage1D; }
_glEnableClientState                              {	printf("_glEnableClientState => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glEnableClientState; }
(^|{ws}*)_CONTROLCHR{ws}*                         {	printf("_CONTROLCHR => %s\n", yytext); nchar += yyleng; return ENUM_QB__CONTROLCHR_STATEMENT; }
(^|{ws}*)UNSIGNED{ws}+LONG{ws}+VARIABLE{ws}*      {	printf("UNSIGNED LONG VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_LONG_VARIABLE; }
(^|{ws}*)UNSIGNED{ws}+BYTE{ws}+VARIABLE{ws}*      {	printf("UNSIGNED BYTE VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }
_glPrioritizeTextures                             {	printf("_glPrioritizeTextures => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glPrioritizeTextures; }
_glDisableClientState                             {	printf("_glDisableClientState => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glDisableClientState; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+END{ws}*  {	printf("MULTI LINE COMMENT END => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_END; }
(^|{ws}*)DECLARE{ws}+DYNAMIC{ws}+LIBRARY{ws}*     {	printf("DECLARE DYNAMIC LIBRARY => %s\n", yytext); nchar += yyleng; return ENUM_QB_DECLARE_DYNAMIC_LIBRARY; }
(^|{ws}*)_CLIPBOARD\${ws}*                        {	printf("_CLIPBOARD$ => %s\n", yytext); nchar += yyleng; return ENUM_QB__CLIPBOARD_DS_STATEMENT; }
_glAreTexturesResident                            {	printf("_glAreTexturesResident => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glAreTexturesResident; }
(^|{ws}*)_PALETTECOLOR{ws}*                       {	printf("_PALETTECOLOR => %s\n", yytext); nchar += yyleng; return ENUM_QB__PALETTECOLOR_STATEMENT; }
(^|{ws}*)GREATER{ws}+THAN{ws}+OR{ws}+EQUAL{ws}+TO{ws}*          {	printf("GREATER THAN OR EQUAL TO => %s\n", yytext); nchar += yyleng; return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+BEGIN{ws}*          {	printf("MULTI LINE COMMENT BEGIN => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_BEGIN; }
(^|{ws}*)MULTI{ws}+LINE{ws}+COMMENT{ws}+ERROR{ws}*          {	printf("MULTI LINE COMMENT ERROR => %s\n", yytext); nchar += yyleng; return ENUM_QB_MULTI_LINE_COMMENT_ERROR; }
(^|{ws}*)UNSIGNED{ws}+OFFSET{ws}+VARIABLE{ws}*    {	printf("UNSIGNED OFFSET VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }
(^|{ws}*)UNSIGNED{ws}+INTEGER{ws}+VARIABLE{ws}*   {	printf("UNSIGNED INTEGER VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }
_glGetTexLevelParameterfv                         {	printf("_glGetTexLevelParameterfv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexLevelParameterfv; }
_glGetTexLevelParameteriv                         {	printf("_glGetTexLevelParameteriv => %s\n", yytext); nchar += yyleng; return ENUM_OGL__glGetTexLevelParameteriv; }
(^|{ws}*)UNSIGNED{ws}+INTEGER64{ws}+VARIABLE{ws}* {	printf("UNSIGNED INTEGER64 VARIABLE => %s\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }

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

