<?php

	$a = <<<EOD
	ENUM_QB__ACOS
	ENUM_QB__ACOSH
	ENUM_QB__ALPHA
	ENUM_QB__ALPHA32
	ENUM_QB__ARCCOT
	ENUM_QB__ARCSC
	ENUM_QB__ARCSEC
	ENUM_QB__ASIN
	ENUM_QB__ASINH
	ENUM_QB__ATAN2
	ENUM_QB__ATANH
	ENUM_QB__AUTODISPLAY
	ENUM_QB__AXIS
	ENUM_QB__BACKGROUNDCOLOR
	ENUM_QB__BIT
	ENUM_QB__BLEND_STATEMENT
	ENUM_QB__BLEND_FUNCTION
	ENUM_QB__BLUE
	ENUM_QB__BLUE32
	ENUM_QB__BUTTON
	ENUM_QB__BUTTONCHANGE
	ENUM_QB__BYTE
	ENUM_QB_DS_CHECKING
	ENUM_QB__CEIL
	ENUM_QB__CLEARCOLOR_STATEMENT
	ENUM_QB__CLEARCOLOR_FUNCTION
	ENUM_QB__CLIP
	ENUM_QB__CLIPBOARD_DS_STATEMENT
	ENUM_QB__CLIPBOARD_DS_FUNCTION
	ENUM_QB__COMMANDCOUNT
	ENUM_QB__CONNECTED
	ENUM_QB__CONNECTIONADDRESS_DS
	ENUM_QB_DS_CONSOLE
	ENUM_QB__CONSOLE
	ENUM_QB__CONSOLETITLE
	ENUM_QB__CONTROLCHR_STATEMENT
	ENUM_QB__CONTROLCHR_FUNCTION
	ENUM_QB__COPYIMAGE
	ENUM_QB__COPYPALETTE
	ENUM_QB__COT
	ENUM_QB__COTH
	ENUM_QB__COSH
	ENUM_QB__CSC
	ENUM_QB__CSCH
	ENUM_QB__CV
	ENUM_QB__CWD_DS
	ENUM_QB__D2G
	ENUM_QB__D2R
	ENUM_QB__DEFAULTCOLOR
	ENUM_QB__DEFINE
	ENUM_QB__DELAY
	ENUM_QB__DEPTHBUFFER
	ENUM_QB__DESKTOPHEIGHT
	ENUM_QB__DESKTOPWIDTH
	ENUM_QB__DEST_STATEMENT
	ENUM_QB__DEST_FUNCTION
	ENUM_QB__DEVICE_DS
	ENUM_QB__DEVICEINPUT
	ENUM_QB__DEVICES
	ENUM_QB__DIREXISTS
	ENUM_QB__DISPLAY_STATEMENT
	ENUM_QB__DISPLAY_FUNCTION
	ENUM_QB__DISPLAYORDER
	ENUM_QB__DONTBLEND
	ENUM_QB__DONTWAIT
	ENUM_QB_DS_ELSE
	ENUM_QB_DS_ELSEIF
	ENUM_QB_DS_ELSE_IF
	ENUM_QB_DS_END
	ENUM_QB__ERRORLINE
	ENUM_QB__EXIT
	ENUM_QB__FILEEXISTS
	ENUM_QB__FLOAT
	ENUM_QB__FONT_STATEMENT
	ENUM_QB__FONT_FUNCTION
	ENUM_QB__FONTHEIGHT
	ENUM_QB__FONTWIDTH
	ENUM_QB__FREEFONT
	ENUM_QB__FREEIMAGE
	ENUM_QB__FREETIMER
	ENUM_QB__FULLSCREEN_STATEMENT
	ENUM_QB__FULLSCREEN_FUNCTION
	ENUM_QB__G2D
	ENUM_QB__G2R
	ENUM_QB__GREEN
	ENUM_QB__GREEN32
	ENUM_QB__HEIGHT
	ENUM_QB__HIDE
	ENUM_QB__HYPOT
	ENUM_QB_DS_IF
	ENUM_QB__ICON
	ENUM_QB__INTEGER64
	ENUM_QB__KEYCLEAR
	ENUM_QB__KEYHIT
	ENUM_QB__KEYDOWN
	ENUM_QB_DS_LET
	ENUM_QB__LASTAXIS
	ENUM_QB__LASTBUTTON
	ENUM_QB__LASTWHEEL
	ENUM_QB__LIMIT
	ENUM_QB__LOADFONT
	ENUM_QB__LOADIMAGE
	ENUM_QB__MAPTRIANGLE
	ENUM_QB__MAPUNICODE_STATEMENT
	ENUM_QB__MAPUNICODE_FUNCTION
	ENUM_QB__MEM_STATEMENT
	ENUM_QB__MEM_FUNCTION
	ENUM_QB__MEMCOPY
	ENUM_QB__MEMELEMENT
	ENUM_QB__MEMEXISTS
	ENUM_QB__MEMFILL
	ENUM_QB__MEMFREE
	ENUM_QB__MEMGET_STATEMENT
	ENUM_QB__MEMGET_FUNCTION
	ENUM_QB__MEMIMAGE
	ENUM_QB__MEMNEW
	ENUM_QB__MEMPUT
	ENUM_QB__MIDDLE_SCREENMOVE
	ENUM_QB__MK_DS
	ENUM_QB__MOUSEBUTTON
	ENUM_QB__MOUSEHIDE
	ENUM_QB__MOUSEINPUT
	ENUM_QB__MOUSEMOVE
	ENUM_QB__MOUSEMOVEMENTX
	ENUM_QB__MOUSEMOVEMENTY
	ENUM_QB__MOUSEPIPEOPEN
	ENUM_QB__MOUSESHOW
	ENUM_QB__MOUSEWHEEL
	ENUM_QB__MOUSEX
	ENUM_QB__MOUSEY
	ENUM_QB__NEWIMAGE
	ENUM_QB__OFFSET_FUNCTION
	ENUM_QB__OFFSET_TYPE
	ENUM_QB__OPENCLIENT
	ENUM_QB__OPENCONNECTION
	ENUM_QB__OPENHOST
	ENUM_QB__OS_DS
	ENUM_QB__PALETTECOLOR_STATEMENT
	ENUM_QB__PALETTECOLOR_FUNCTION
	ENUM_QB__PIXELSIZE
	ENUM_QB__PRESERVE
	ENUM_QB__PRINTIMAGE
	ENUM_QB__PRINTMODE_STATEMENT
	ENUM_QB__PRINTMODE_FUNCTION
	ENUM_QB__PRINTSTRING
	ENUM_QB__PRINTWIDTH
	ENUM_QB__PUTIMAGE
	ENUM_QB__R2D
	ENUM_QB__R2G
	ENUM_QB__RED
	ENUM_QB__RED32
	ENUM_QB_DS_RESIZE
	ENUM_QB__RESIZE
	ENUM_QB__RESIZEHEIGHT
	ENUM_QB__RESIZEWIDTH
	ENUM_QB__RGB
	ENUM_QB__RGB32
	ENUM_QB__RGBA
	ENUM_QB__RGBA32
	ENUM_QB__ROUND
	ENUM_QB__SEC
	ENUM_QB__SECH
	ENUM_QB__SCREENCLICK
	ENUM_QB__SCREENEXISTS
	ENUM_QB_DS_SCREENHIDE
	ENUM_QB__SCREENHIDE
	ENUM_QB__SCREENICON_STATEMENT
	ENUM_QB__SCREENICON_FUNCTION
	ENUM_QB__SCREENIMAGE
	ENUM_QB__SCREENMOVE
	ENUM_QB__SCREENPRINT
	ENUM_QB_DS_SCREENSHOW
	ENUM_QB__SCREENSHOW
	ENUM_QB__SCREENX
	ENUM_QB__SCREENY
	ENUM_QB__SETALPHA
	ENUM_QB__SHELLHIDE
	ENUM_QB__SINH
	ENUM_QB__SNDBAL
	ENUM_QB__SNDCLOSE
	ENUM_QB__SNDCOPY
	ENUM_QB__SNDGETPOS
	ENUM_QB__SNDLEN
	ENUM_QB__SNDLIMIT
	ENUM_QB__SNDLOOP
	ENUM_QB__SNDOPEN
	ENUM_QB__SNDOPENRAW
	ENUM_QB__SNDPAUSE
	ENUM_QB__SNDPAUSED
	ENUM_QB__SNDPLAY
	ENUM_QB__SNDPLAYCOPY
	ENUM_QB__SNDPLAYFILE
	ENUM_QB__SNDPLAYING
	ENUM_QB__SNDRATE
	ENUM_QB__SNDRAW
	ENUM_QB__SNDRAWDONE
	ENUM_QB__SNDRAWLEN
	ENUM_QB__SNDSETPOS
	ENUM_QB__SNDSTOP
	ENUM_QB__SNDVOL
	ENUM_QB__SOURCE
	ENUM_QB__STARTDIR_DS
	ENUM_QB__STRCMP
	ENUM_QB__STRICMP
	ENUM_QB__TANH
	ENUM_QB__TITLE
	ENUM_QB__UNSIGNED
	ENUM_QB_DS_VIRTUALKEYBOARD
	ENUM_QB__WHEEL
	ENUM_QB__WIDTH
	ENUM_QB_ABS
	ENUM_QB_ABSOLUTE
	ENUM_QB_ACCESS
	ENUM_QB_ALIAS
	ENUM_QB_AND
	ENUM_QB_ANY
	ENUM_QB_APPEND
	ENUM_QB_AS
	ENUM_QB_ASC
	ENUM_QB_ATN
	ENUM_QB_BEEP
	ENUM_QB_BINARY
	ENUM_QB_BLOAD
	ENUM_QB_BSAVE
	ENUM_QB_BYVAL
	ENUM_QB_CALL
	ENUM_QB_CALL_ABSOLUTE
	ENUM_QB_CALLS
	ENUM_QB_CASE
	ENUM_QB_CASE_ELSE
	ENUM_QB_CASE_IS
	ENUM_QB_CDBL
	ENUM_QB_CDECL
	ENUM_QB_CHAIN
	ENUM_QB_CHDIR
	ENUM_QB_CHR_DS
	ENUM_QB_CINT
	ENUM_QB_CIRCLE
	ENUM_QB_CLEAR
	ENUM_QB_CLNG
	ENUM_QB_CLOSE
	ENUM_QB_CLS
	ENUM_QB_COLOR
	ENUM_QB_COMMAND_DS
	ENUM_QB_COMMON
	ENUM_QB_CONST
	ENUM_QB_COS
	ENUM_QB_CSNG
	ENUM_QB_CSRLIN
	ENUM_QB_CVD
	ENUM_QB_CVDMBF
	ENUM_QB_CVI
	ENUM_QB_CVL
	ENUM_QB_CVS
	ENUM_QB_CVSMBF
	ENUM_QB_DATA
	ENUM_QB_DATE_DS_STATEMENT
	ENUM_QB_DATE_DS_FUNCTION
	ENUM_QB_DECLARE
	ENUM_QB_DECLARE_C_FUNCTION
	ENUM_QB_DECLARE_LIBRARY
	ENUM_QB_DECLARE_DYNAMIC_LIBRARY
	ENUM_QB_DEF_FN
	ENUM_QB_DEF_SEG
	ENUM_QB_DEFDBL
	ENUM_QB_DEFINT
	ENUM_QB_DEFLNG
	ENUM_QB_DEFSNG
	ENUM_QB_DEFSTR
	ENUM_QB_DIM
	ENUM_QB_DIR_DS
	ENUM_QB_DO
	ENUM_QB_LOOP_STATEMENT
	ENUM_QB_DOUBLE
	ENUM_QB_DRAW
	ENUM_QB_DS_DYNAMIC
	ENUM_QB_ELSE
	ENUM_QB_ELSEIF
	ENUM_QB_END
	ENUM_QB_END_IF
	ENUM_QB_END_TYPE
	ENUM_QB_ENVIRON
	ENUM_QB_ENVIRON_DS
	ENUM_QB_EOF
	ENUM_QB_EQV
	ENUM_QB_ERASE
	ENUM_QB_ERDEV
	ENUM_QB_ERDEV_DS
	ENUM_QB_ERL
	ENUM_QB_ERR
	ENUM_QB_ERROR
	ENUM_QB_EXIT
	ENUM_QB_EXP
	ENUM_QB_FIELD
	ENUM_QB_FILEATTR
	ENUM_QB_FILES
	ENUM_QB_FIX
	ENUM_QB_FOR
	ENUM_QB_NEXT_STATEMENT
	ENUM_QB_FOR_FILE
	ENUM_QB_FRE
	ENUM_QB_FREE
	ENUM_QB_FREEFILE
	ENUM_QB_FUNCTION
	ENUM_QB_GET_FILE
	ENUM_QB_GET_QB64
	ENUM_QB_GET
	ENUM_QB_GOSUB
	ENUM_QB_GOTO
	ENUM_QB_HEX_DS
	ENUM_QB_IF
	ENUM_QB_IMP
	ENUM_QB_INKEY_DS
	ENUM_QB_INP
	ENUM_QB_INPUT
	ENUM_QB_INPUT_FILE_MODE
	ENUM_QB_INPUT_FILE_STATEMENT
	ENUM_QB_INPUT_QB64
	ENUM_QB_INPUT_DS
	ENUM_QB_INSTR
	ENUM_QB_INT
	ENUM_QB_INTEGER
	ENUM_QB_INTERRUPT
	ENUM_QB_INTERRUPTX
	ENUM_QB_IOCTL
	ENUM_QB_IOCTL_DS
	ENUM_QB_KEY_STATEMENT
	ENUM_QB_KEY_FUNCTION
	ENUM_QB_KEY_LIST
	ENUM_QB_KILL
	ENUM_QB_LBOUND
	ENUM_QB_LCASE_DS
	ENUM_QB_LEFT_DS
	ENUM_QB_LEN
	ENUM_QB_LET
	ENUM_QB_LINE
	ENUM_QB_LINE_INPUT
	ENUM_QB_LINE_INPUT_FILE
	ENUM_QB_LIST
	ENUM_QB_LOC
	ENUM_QB_LOCATE
	ENUM_QB_LOCK
	ENUM_QB_LOF
	ENUM_QB_LOG
	ENUM_QB_LONG
	ENUM_QB_LOOP_FUNCTION
	ENUM_QB_LPOS
	ENUM_QB_LPRINT
	ENUM_QB_LPRINT_USING
	ENUM_QB_LSET
	ENUM_QB_LTRIM_DS
	ENUM_QB_MID_DS_STATMENT
	ENUM_QB_MID_DS_FUNCTION
	ENUM_QB_MKD_DS
	ENUM_QB_MKDIR
	ENUM_QB_MKDMBF_DS
	ENUM_QB_MKI_DS
	ENUM_QB_MKL_DS
	ENUM_QB_MKS_DS
	ENUM_QB_MKSMBF_DS
	ENUM_QB_MOD
	ENUM_QB_NAME
	ENUM_QB_NEXT_FUNCTION
	ENUM_QB_NOT
	ENUM_QB_OCT_DS
	ENUM_QB_OFF
	ENUM_QB_ON_COM
	ENUM_QB_ON_ERROR
	ENUM_QB_ON_KEY
	ENUM_QB_ON_PEN
	ENUM_QB_ON_PLAY
	ENUM_QB_ON_STRIG
	ENUM_QB_ON_TIMER
	ENUM_QB_ON_UEVENT
	ENUM_QB_ON_GOSUB
	ENUM_QB_ON_GOTO
	ENUM_QB_OPEN
	ENUM_QB_OPEN_COM
	ENUM_QB_OPTION_BASE
	ENUM_QB_OR
	ENUM_QB_OUT
	ENUM_QB_OUTPUT
	ENUM_QB_PAINT
	ENUM_QB_PALETTE
	ENUM_QB_PALETTE_USING
	ENUM_QB_PCOPY
	ENUM_QB_PEEK
	ENUM_QB_PEN_STATEMENT
	ENUM_QB_PEN_FUNCTION
	ENUM_QB_PLAY_STATEMENT
	ENUM_QB_PLAY_FUNCTION
	ENUM_QB_PMAP
	ENUM_QB_POINT
	ENUM_QB_POKE
	ENUM_QB_POS
	ENUM_QB_PRESET
	ENUM_QB_PRINT
	ENUM_QB_PRINT_FILE
	ENUM_QB_PRINT_QB64
	ENUM_QB_PRINT_USING
	ENUM_QB_PRINT_USING_FILE
	ENUM_QB_PSET
	ENUM_QB_PUT_FILE
	ENUM_QB_PUT_QB64
	ENUM_QB_PUT_GRAPHICS
	ENUM_QB_RANDOM
	ENUM_QB_RANDOMIZE
	ENUM_QB_RANDOMIZE_USING
	ENUM_QB_READ
	ENUM_QB_REDIM
	ENUM_QB_RESET
	ENUM_QB_RESTORE
	ENUM_QB_RESUME
	ENUM_QB_RETURN
	ENUM_QB_RIGHT_DS
	ENUM_QB_RMDIR
	ENUM_QB_RND
	ENUM_QB_RSET
	ENUM_QB_RTRIM_DS
	ENUM_QB_RUN
	ENUM_QB_SADD
	ENUM_QB_SCREEN_STATEMENT
	ENUM_QB_SCREEN_FUNCTION
	ENUM_QB_SEEK_STATEMENT
	ENUM_QB_SEEK_FUNCTION
	ENUM_QB_SELECT_CASE
	ENUM_QB_SETMEM
	ENUM_QB_SGN
	ENUM_QB_SHARED
	ENUM_QB_SHELL
	ENUM_QB_SHELL_QB64
	ENUM_QB_SIGNAL
	ENUM_QB_SIN
	ENUM_QB_SINGLE
	ENUM_QB_SLEEP
	ENUM_QB_SOUND
	ENUM_QB_SPACE_DS
	ENUM_QB_SPC
	ENUM_QB_SQR
	ENUM_QB_STATIC
	ENUM_QB_DS_STATIC
	ENUM_QB_STEP
	ENUM_QB_STICK
	ENUM_QB_STOP
	ENUM_QB_STR_DS
	ENUM_QB_STRIG_STATEMENT
	ENUM_QB_STRIG_FUNCTION
	ENUM_QB_STRING
	ENUM_QB_STRING_DS
	ENUM_QB_SUB
	ENUM_QB_SWAP
	ENUM_QB_SYSTEM
	ENUM_QB_TAB
	ENUM_QB_TAN
	ENUM_QB_THEN
	ENUM_QB_TIME_DS_STATEMENT
	ENUM_QB_TIME_DS_FUNCTION
	ENUM_QB_TIMER_STATEMENT
	ENUM_QB_TIMER_FUNCTION
	ENUM_QB_TO
	ENUM_QB_TROFF
	ENUM_QB_TRON
	ENUM_QB_TYPE
	ENUM_QB_UBOUND
	ENUM_QB_UCASE_DS
	ENUM_QB_UEVENT
	ENUM_QB_UNLOCK
	ENUM_QB_UNTIL
	ENUM_QB_VAL
	ENUM_QB_VARPTR
	ENUM_QB_VARPTR_DS
	ENUM_QB_VARSEG
	ENUM_QB_VIEW
	ENUM_QB_VIEW_PRINT
	ENUM_QB_WAIT
	ENUM_QB_WEND
	ENUM_QB_WHILE
	ENUM_QB_WHILE_WEND
	ENUM_QB_WIDTH
	ENUM_QB_WINDOW
	ENUM_QB_WRITE_SCREEN
	ENUM_QB_WRITE_FILE
	ENUM_QB_XOR
	ENUM_OGL__glAccum
	ENUM_OGL__glAlphaFunc
	ENUM_OGL__glAreTexturesResident
	ENUM_OGL__glArrayElement
	ENUM_OGL__glBegin
	ENUM_OGL__glBindTexture
	ENUM_OGL__glBitmap
	ENUM_OGL__glBlendFunc
	ENUM_OGL__glCallList
	ENUM_OGL__glCallLists
	ENUM_OGL__glClear
	ENUM_OGL__glClearAccum
	ENUM_OGL__glClearColor
	ENUM_OGL__glClearDepth
	ENUM_OGL__glClearIndex
	ENUM_OGL__glClearStencil
	ENUM_OGL__glClipPlane
	ENUM_OGL__glColor3b
	ENUM_OGL__glColor3bv
	ENUM_OGL__glColor3d
	ENUM_OGL__glColor3dv
	ENUM_OGL__glColor3f
	ENUM_OGL__glColor3fv
	ENUM_OGL__glColor3i
	ENUM_OGL__glColor3iv
	ENUM_OGL__glColor3s
	ENUM_OGL__glColor3sv
	ENUM_OGL__glColor3ub
	ENUM_OGL__glColor3ubv
	ENUM_OGL__glColor3ui
	ENUM_OGL__glColor3uiv
	ENUM_OGL__glColor3us
	ENUM_OGL__glColor3usv
	ENUM_OGL__glColor4b
	ENUM_OGL__glColor4bv
	ENUM_OGL__glColor4d
	ENUM_OGL__glColor4dv
	ENUM_OGL__glColor4f
	ENUM_OGL__glColor4fv
	ENUM_OGL__glColor4i
	ENUM_OGL__glColor4iv
	ENUM_OGL__glColor4s
	ENUM_OGL__glColor4sv
	ENUM_OGL__glColor4ub
	ENUM_OGL__glColor4ubv
	ENUM_OGL__glColor4ui
	ENUM_OGL__glColor4uiv
	ENUM_OGL__glColor4us
	ENUM_OGL__glColor4usv
	ENUM_OGL__glColorMask
	ENUM_OGL__glColorMaterial
	ENUM_OGL__glColorPointer
	ENUM_OGL__glCopyPixels
	ENUM_OGL__glCopyTexImage1D
	ENUM_OGL__glCopyTexImage2D
	ENUM_OGL__glCopyTexSubImage1D
	ENUM_OGL__glCopyTexSubImage2D
	ENUM_OGL__glCullFace
	ENUM_OGL__glDeleteLists
	ENUM_OGL__glDeleteTextures
	ENUM_OGL__glDepthFunc
	ENUM_OGL__glDepthMask
	ENUM_OGL__glDepthRange
	ENUM_OGL__glDisable
	ENUM_OGL__glDisableClientState
	ENUM_OGL__glDrawArrays
	ENUM_OGL__glDrawBuffer
	ENUM_OGL__glDrawElements
	ENUM_OGL__glDrawPixels
	ENUM_OGL__glEdgeFlag
	ENUM_OGL__glEdgeFlagPointer
	ENUM_OGL__glEdgeFlagv
	ENUM_OGL__glEnable
	ENUM_OGL__glEnableClientState
	ENUM_OGL__glEnd
	ENUM_OGL__glEndList
	ENUM_OGL__glEvalCoord1d
	ENUM_OGL__glEvalCoord1dv
	ENUM_OGL__glEvalCoord1f
	ENUM_OGL__glEvalCoord1fv
	ENUM_OGL__glEvalCoord2d
	ENUM_OGL__glEvalCoord2dv
	ENUM_OGL__glEvalCoord2f
	ENUM_OGL__glEvalCoord2fv
	ENUM_OGL__glEvalMesh1
	ENUM_OGL__glEvalMesh2
	ENUM_OGL__glEvalPoint1
	ENUM_OGL__glEvalPoint2
	ENUM_OGL__glFeedbackBuffer
	ENUM_OGL__glFinish
	ENUM_OGL__glFlush
	ENUM_OGL__glFogf
	ENUM_OGL__glFogfv
	ENUM_OGL__glFogi
	ENUM_OGL__glFogiv
	ENUM_OGL__glFrontFace
	ENUM_OGL__glFrustum
	ENUM_OGL__glGenLists
	ENUM_OGL__glGenTextures
	ENUM_OGL__glGetBooleanv
	ENUM_OGL__glGetClipPlane
	ENUM_OGL__glGetDoublev
	ENUM_OGL__glGetError
	ENUM_OGL__glGetFloatv
	ENUM_OGL__glGetIntegerv
	ENUM_OGL__glGetLightfv
	ENUM_OGL__glGetLightiv
	ENUM_OGL__glGetMapdv
	ENUM_OGL__glGetMapfv
	ENUM_OGL__glGetMapiv
	ENUM_OGL__glGetMaterialfv
	ENUM_OGL__glGetMaterialiv
	ENUM_OGL__glGetPixelMapfv
	ENUM_OGL__glGetPixelMapuiv
	ENUM_OGL__glGetPixelMapusv
	ENUM_OGL__glGetPointerv
	ENUM_OGL__glGetPolygonStipple
	ENUM_OGL__glGetString
	ENUM_OGL__glGetTexEnvfv
	ENUM_OGL__glGetTexEnviv
	ENUM_OGL__glGetTexGendv
	ENUM_OGL__glGetTexGenfv
	ENUM_OGL__glGetTexGeniv
	ENUM_OGL__glGetTexImage
	ENUM_OGL__glGetTexLevelParameterfv
	ENUM_OGL__glGetTexLevelParameteriv
	ENUM_OGL__glGetTexParameterfv
	ENUM_OGL__glGetTexParameteriv
	ENUM_OGL__glHint
	ENUM_OGL__glIndexMask
	ENUM_OGL__glIndexPointer
	ENUM_OGL__glIndexd
	ENUM_OGL__glIndexdv
	ENUM_OGL__glIndexf
	ENUM_OGL__glIndexfv
	ENUM_OGL__glIndexi
	ENUM_OGL__glIndexiv
	ENUM_OGL__glIndexs
	ENUM_OGL__glIndexsv
	ENUM_OGL__glIndexub
	ENUM_OGL__glIndexubv
	ENUM_OGL__glInitNames
	ENUM_OGL__glInterleavedArrays
	ENUM_OGL__glIsEnabled
	ENUM_OGL__glIsList
	ENUM_OGL__glIsTexture
	ENUM_OGL__glLightModelf
	ENUM_OGL__glLightModelfv
	ENUM_OGL__glLightModeli
	ENUM_OGL__glLightModeliv
	ENUM_OGL__glLightf
	ENUM_OGL__glLightfv
	ENUM_OGL__glLighti
	ENUM_OGL__glLightiv
	ENUM_OGL__glLineStipple
	ENUM_OGL__glLineWidth
	ENUM_OGL__glListBase
	ENUM_OGL__glLoadIdentity
	ENUM_OGL__glLoadMatrixd
	ENUM_OGL__glLoadMatrixf
	ENUM_OGL__glLoadName
	ENUM_OGL__glLogicOp
	ENUM_OGL__glMap1d
	ENUM_OGL__glMap1f
	ENUM_OGL__glMap2d
	ENUM_OGL__glMap2f
	ENUM_OGL__glMapGrid1d
	ENUM_OGL__glMapGrid1f
	ENUM_OGL__glMapGrid2d
	ENUM_OGL__glMapGrid2f
	ENUM_OGL__glMaterialf
	ENUM_OGL__glMaterialfv
	ENUM_OGL__glMateriali
	ENUM_OGL__glMaterialiv
	ENUM_OGL__glMatrixMode
	ENUM_OGL__glMultMatrixd
	ENUM_OGL__glMultMatrixf
	ENUM_OGL__glNewList
	ENUM_OGL__glNormal3b
	ENUM_OGL__glNormal3bv
	ENUM_OGL__glNormal3d
	ENUM_OGL__glNormal3dv
	ENUM_OGL__glNormal3f
	ENUM_OGL__glNormal3fv
	ENUM_OGL__glNormal3i
	ENUM_OGL__glNormal3iv
	ENUM_OGL__glNormal3s
	ENUM_OGL__glNormal3sv
	ENUM_OGL__glNormalPointer
	ENUM_OGL__glOrtho
	ENUM_OGL__glPassThrough
	ENUM_OGL__glPixelMapfv
	ENUM_OGL__glPixelMapuiv
	ENUM_OGL__glPixelMapusv
	ENUM_OGL__glPixelStoref
	ENUM_OGL__glPixelStorei
	ENUM_OGL__glPixelTransferf
	ENUM_OGL__glPixelTransferi
	ENUM_OGL__glPixelZoom
	ENUM_OGL__glPointSize
	ENUM_OGL__glPolygonMode
	ENUM_OGL__glPolygonOffset
	ENUM_OGL__glPolygonStipple
	ENUM_OGL__glPopAttrib
	ENUM_OGL__glPopClientAttrib
	ENUM_OGL__glPopMatrix
	ENUM_OGL__glPopName
	ENUM_OGL__glPrioritizeTextures
	ENUM_OGL__glPushAttrib
	ENUM_OGL__glPushClientAttrib
	ENUM_OGL__glPushMatrix
	ENUM_OGL__glPushName
	ENUM_OGL__glRasterPos2d
	ENUM_OGL__glRasterPos2dv
	ENUM_OGL__glRasterPos2f
	ENUM_OGL__glRasterPos2fv
	ENUM_OGL__glRasterPos2i
	ENUM_OGL__glRasterPos2iv
	ENUM_OGL__glRasterPos2s
	ENUM_OGL__glRasterPos2sv
	ENUM_OGL__glRasterPos3d
	ENUM_OGL__glRasterPos3dv
	ENUM_OGL__glRasterPos3f
	ENUM_OGL__glRasterPos3fv
	ENUM_OGL__glRasterPos3i
	ENUM_OGL__glRasterPos3iv
	ENUM_OGL__glRasterPos3s
	ENUM_OGL__glRasterPos3sv
	ENUM_OGL__glRasterPos4d
	ENUM_OGL__glRasterPos4dv
	ENUM_OGL__glRasterPos4f
	ENUM_OGL__glRasterPos4fv
	ENUM_OGL__glRasterPos4i
	ENUM_OGL__glRasterPos4iv
	ENUM_OGL__glRasterPos4s
	ENUM_OGL__glRasterPos4sv
	ENUM_OGL__glReadBuffer
	ENUM_OGL__glReadPixels
	ENUM_OGL__glRectd
	ENUM_OGL__glRectdv
	ENUM_OGL__glRectf
	ENUM_OGL__glRectfv
	ENUM_OGL__glRecti
	ENUM_OGL__glRectiv
	ENUM_OGL__glRects
	ENUM_OGL__glRectsv
	ENUM_OGL__glRenderMode
	ENUM_OGL__glRotated
	ENUM_OGL__glRotatef
	ENUM_OGL__glScaled
	ENUM_OGL__glScalef
	ENUM_OGL__glScissor
	ENUM_OGL__glSelectBuffer
	ENUM_OGL__glShadeModel
	ENUM_OGL__glStencilFunc
	ENUM_OGL__glStencilMask
	ENUM_OGL__glStencilOp
	ENUM_OGL__glTexCoord1d
	ENUM_OGL__glTexCoord1dv
	ENUM_OGL__glTexCoord1f
	ENUM_OGL__glTexCoord1fv
	ENUM_OGL__glTexCoord1i
	ENUM_OGL__glTexCoord1iv
	ENUM_OGL__glTexCoord1s
	ENUM_OGL__glTexCoord1sv
	ENUM_OGL__glTexCoord2d
	ENUM_OGL__glTexCoord2dv
	ENUM_OGL__glTexCoord2f
	ENUM_OGL__glTexCoord2fv
	ENUM_OGL__glTexCoord2i
	ENUM_OGL__glTexCoord2iv
	ENUM_OGL__glTexCoord2s
	ENUM_OGL__glTexCoord2sv
	ENUM_OGL__glTexCoord3d
	ENUM_OGL__glTexCoord3dv
	ENUM_OGL__glTexCoord3f
	ENUM_OGL__glTexCoord3fv
	ENUM_OGL__glTexCoord3i
	ENUM_OGL__glTexCoord3iv
	ENUM_OGL__glTexCoord3s
	ENUM_OGL__glTexCoord3sv
	ENUM_OGL__glTexCoord4d
	ENUM_OGL__glTexCoord4dv
	ENUM_OGL__glTexCoord4f
	ENUM_OGL__glTexCoord4fv
	ENUM_OGL__glTexCoord4i
	ENUM_OGL__glTexCoord4iv
	ENUM_OGL__glTexCoord4s
	ENUM_OGL__glTexCoord4sv
	ENUM_OGL__glTexCoordPointer
	ENUM_OGL__glTexEnvf
	ENUM_OGL__glTexEnvfv
	ENUM_OGL__glTexEnvi
	ENUM_OGL__glTexEnviv
	ENUM_OGL__glTexGend
	ENUM_OGL__glTexGendv
	ENUM_OGL__glTexGenf
	ENUM_OGL__glTexGenfv
	ENUM_OGL__glTexGeni
	ENUM_OGL__glTexGeniv
	ENUM_OGL__glTexImage1D
	ENUM_OGL__glTexImage2D
	ENUM_OGL__glTexParameterf
	ENUM_OGL__glTexParameterfv
	ENUM_OGL__glTexParameteri
	ENUM_OGL__glTexParameteriv
	ENUM_OGL__glTexSubImage1D
	ENUM_OGL__glTexSubImage2D
	ENUM_OGL__glTranslated
	ENUM_OGL__glTranslatef
	ENUM_OGL__glVertex2d
	ENUM_OGL__glVertex2dv
	ENUM_OGL__glVertex2f
	ENUM_OGL__glVertex2fv
	ENUM_OGL__glVertex2i
	ENUM_OGL__glVertex2iv
	ENUM_OGL__glVertex2s
	ENUM_OGL__glVertex2sv
	ENUM_OGL__glVertex3d
	ENUM_OGL__glVertex3dv
	ENUM_OGL__glVertex3f
	ENUM_OGL__glVertex3fv
	ENUM_OGL__glVertex3i
	ENUM_OGL__glVertex3iv
	ENUM_OGL__glVertex3s
	ENUM_OGL__glVertex3sv
	ENUM_OGL__glVertex4d
	ENUM_OGL__glVertex4dv
	ENUM_OGL__glVertex4f
	ENUM_OGL__glVertex4fv
	ENUM_OGL__glVertex4i
	ENUM_OGL__glVertex4iv
	ENUM_OGL__glVertex4s
	ENUM_OGL__glVertex4sv
	ENUM_OGL__glVertexPointer
	ENUM_OGL__glViewport
	ENUM_QB_MULTI_LINE_COMMENT_BEGIN
	ENUM_QB_MULTI_LINE_COMMENT_END
	ENUM_QB_MULTI_LINE_COMMENT_ERROR
	ENUM_QB_STRING_VARIABLE
	ENUM_QB_SINGLE_VARIABLE
	ENUM_QB_DOUBLE_VARIABLE
	ENUM_QB_FLOAT_VARIABLE
	ENUM_QB_INTEGER_VARIABLE
	ENUM_QB_LONG_VARIABLE
	ENUM_QB_INTEGER64_VARIABLE
	ENUM_QB_BIT_VARIABLE
	ENUM_QB_BYTE_VARIABLE
	ENUM_QB_OFFSET_VARIABLE
	ENUM_QB_UNSIGNED_VARIABLE
	ENUM_QB_UNSIGNED_INTEGER_VARIABLE
	ENUM_QB_UNSIGNED_LONG_VARIABLE
	ENUM_QB_UNSIGNED_INTEGER64_VARIABLE
	ENUM_QB_UNSIGNED_BIT_VARIABLE
	ENUM_QB_UNSIGNED_BYTE_VARIABLE
	ENUM_QB_UNSIGNED_OFFSET_VARIABLE
	ENUM_QB_STANDARD_VARIABLE
	ENUM_QB_LESS_THAN_OR_EQUAL_TO
	ENUM_QB_GREATER_THAN_OR_EQUAL_TO
	ENUM_QB_NOT_EQUAL_TO
	ENUM_QB_ELSE_IF
	ENUM_QB_NEW_LINE
	ENUM_QB_WHITE_SPACE
	ENUM_QB_UNKNOWN_CHARACTER
EOD;

#
#	Put in the various single letter commands
#
	$lex = "";
	$test = "";

	$lex .= <<<EOD
"+"							{	printf("ENUM_PLUS_SIGN => %s\\n", yytext); nchar += yyleng; return ENUM_PLUS_SIGN; }
"-"							{	printf("MINUS => %s\\n", yytext); nchar += yyleng; return ENUM_MINUS_SIGN; }
"*"							{	printf("MULTIPLY => %s\\n", yytext); nchar += yyleng; return ENUM_ASTERIK; }
"/"							{	printf("DIVIDE => %s\\n", yytext); nchar += yyleng; return ENUM_SLASH_FORWARDS; }
"\\\\"						{	printf("INTEGER DIVISION => %s\\n", yytext); nchar += yyleng; return ENUM_SLASH_BACK; }
"^"							{	printf("EXPONENTIAL => %s\\n", yytext); nchar += yyleng; return ENUM_CARET; }
"="							{	printf("EQUAL SIGN => %s\\n", yytext); nchar += yyleng; return ENUM_EQUAL; }
"<"							{	printf("LESS THAN => %s\\n", yytext); nchar += yyleng; return ENUM_LESS_THAN; }
">"							{	printf("GREATER THAN => %s\\n", yytext); nchar += yyleng; return ENUM_GREATER_THAN; }
"<="						{	printf("LESS THAN OR EQUAL TO => %s\\n", yytext);
								nchar += yyleng; return ENUM_QB_LESS_THAN_OR_EQUAL_TO; }
">="						{	printf("GREATER THAN OR EQUAL TO => %s\\n", yytext); nchar += yyleng; return ENUM_QB_GREATER_THAN_OR_EQUAL_TO; }
"<>"						{	printf("NOT EQUAL TO => %s\\n", yytext); nchar += yyleng; return ENUM_QB_NOT_EQUAL_TO; }
"\\("						{	printf("OPEN PARENTHESIS => %s\\n", yytext); nchar += yyleng; return ENUM_PAREN_OPEN; }
"\\)"						{	printf("CLOSE PARENTHESIS => %s\\n", yytext); nchar += yyleng; return ENUM_PAREN_CLOSED; }
"&"[bB]{binary}+			{	printf("BINARY NUMBER => %s\\n", yytext); nchar += yyleng; return ENUM_QB_BINARY; }
"&"[oO]{octal}+				{	printf("OCTAL NUMBER => %s\\n", yytext); nchar += yyleng; return ENUM_QB_OCTAL; }
"&"[hH]{xdigit}+			{	printf("HEXADECIMAL NUMBER => %s\\n", yytext); nchar += yyleng; return ENUM_QB_HEXADECIMAL; }
{alpha}{alnum}*\\$			{	printf("STRING VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_STRING_VARIABLE; }
{alpha}{alnum}*\!			{	printf("SINGLE VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_SINGLE_VARIABLE; }
{alpha}{alnum}*\#			{	printf("DOUBLE VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_DOUBLE_VARIABLE; }
{alpha}{alnum}*\#\#			{	printf("FLOAT VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }
{alpha}{alnum}*\%			{	printf("INTEGER VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER_VARIABLE; }
{alpha}{alnum}*\&			{	printf("LONG VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }
{alpha}{alnum}*\&\&			{	printf("INTEGER64 VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_INTEGER64_VARIABLE; }
{alpha}{alnum}*\`			{	printf("BIT VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_BIT_VARIABLE; }
{alpha}{alnum}*\%\%			{	printf("BYTE VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_BYTE_VARIABLE; }
{alpha}{alnum}*\%\&			{	printf("OFFSET VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_OFFSET_VARIABLE; }
{alpha}{alnum}*\~			{	printf("UNSIGNED VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_VARIABLE; }
{alpha}{alnum}*\~\%			{	printf("UNSIGNED INTEGER VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER_VARIABLE; }
{alpha}{alnum}*\~\&			{	printf("UNSIGNED LONG VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_LONG_VARIABLE; }
{alpha}{alnum}*\~\&\&		{	printf("UNSIGNED INTEGER64 VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_INTEGER64_VARIABLE; }
{alpha}{alnum}*\~\`			{	printf("UNSIGNED BIT VARIABLE => %s\\n", yytext); nchar += yyleng; return
ENUM_QB_UNSIGNED_BIT_VARIABLE; }
{alpha}{alnum}*\~\%\%		{	printf("UNSIGNED BYTE VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_BYTE_VARIABLE; }
{alpha}{alnum}*\~\%\&		{	printf("UNSIGNED OFFSET VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_UNSIGNED_OFFSET_VARIABLE; }
{alpha}{alnum}*				{	printf("STANDARD QB VARIABLE => %s\\n", yytext); nchar += yyleng; return ENUM_QB_STANDARD_VARIABLE; }
{digit}+					{	printf("INTEGER NUMBER => %s\\n", yytext); nchar += yyleng; return ENUM_QB_LONG_VARIABLE; }
{float}						{	printf("FLOAT NUMBER => %s\\n", yytext); nchar += yyleng; return ENUM_QB_FLOAT_VARIABLE; }
^{ws}*rem					{	printf("REM => %s\\n", yytext); nchar += yyleng; return ENUM_QB_REM; }
^{ws}*'						{	printf("REM => %s\\n", yytext); nchar += yyleng; return ENUM_QB_REM; }
:{ws}*rem					{	printf("REM => %s\\n", yytext); nchar += yyleng; return ENUM_QB_REM; }
:{ws}*'						{	printf("REM => %s\\n", yytext); nchar += yyleng; return ENUM_QB_REM; }

EOD;

	$test .= <<<EOD

rem	This is a test
'	This is also a test

rem \$include	"./include.dat"
'	\$include	"./include.dat"

	A = B + C
	A = B - C
	A = B * C
	A = B / C
	A = B \ C
	A = B ^ C
	A = B & C
	A = B | C
	A = B && C
	A = B || C
	A = B < C
	A = B > C
	A = B <= C
	A = B >= C
	A = B <> C
	dim a$
	dim b!
	dim c#
	dim d##
	dim f%
	dim g&
	dim h&&
	dim i`
	dim j%%
	dim k%&
	dim e~
	dim f~%
	dim g~&
	dim h~&&
	dim i~`
	dim j~%%
	dim k~%&
	dim l
	a = (b + c)
	a = b +c
	a = b -c
	z = (a+b)*(c-d)+((sin(a)*3.14159265) + 5
	a = &b012345
	b = &o0123456789
	c = &h0123456789abcdefghijklmnop

EOD;

	$b = explode( "\n", $a );
	foreach( $b as $k=>$v ){ $b[$k] = trim($v); }
	usort( $b, 'mySort' );

	foreach( $b as $k=>$v ){
		$v = trim( $v );
		$tok = str_ireplace( "
", "", $v );
		if( preg_match("/_function/i", $v) ){ continue; }
		if( preg_match("/_statement/i", $v) ){ $v = str_ireplace("_statement","",$v); }
		if( preg_match("/_ds_/i", $v) ){ $v = str_ireplace( "_ds_", "_$", $v ); }
		if( preg_match("/_ds$/i", $v) ){ $v = str_ireplace( "_DS", "$", $v ); }
		$v = str_ireplace( "
", "", $v );

		if( preg_match("/^enum_qb_/i", $v) ){
			$v = trim( str_ireplace( "enum_qb_", "", $v ) );
#
#	Catch special commands
#
			$cmd = "";
			for( $i=0; $i<strlen($v); $i++ ){
				$l = substr( $v, $i, 1 );
				if( $l == '_' && $i < 1 ){ $cmd .= '_'; }
					else if( $l == '_' ){ $cmd .= '{ws}+'; }
					else if( $l == '$' ){ $cmd .= "\\$"; }
					else if( $l == "'" ){ $cmd .= "([rR][eE][mM]|'){ws}*"; $i++; }
					else if( is_numeric($l) ){ $cmd .= $l; }
#					else { $cmd .= '[' . strtolower($l) . strtoupper($l) . ']'; }
					else { $cmd .= $l; }
				}

			$cmd = "(^|{ws}*)$cmd{ws}*";
			$n = ((50 - strlen($cmd)) > 0) ? (50 - strlen($cmd)) : 10;
			$v = preg_replace( "/(\w)_(\w)/", "$1 $2", $v );
			$cmd .= str_repeat( ' ', $n );
			$cmd .= "{	printf(\"$v => %s\\n\", yytext); nchar += yyleng; return $tok; }\n";

			$lex .= $cmd;
#
#	Catch special commands
#
			if( preg_match("/^rem$/i", $v) ){ $test .= "rem	This is a test\n"; }
				else { $test .= "	a$ = $v\n"; }
			}
			else if( preg_match("/^enum_ogl_/i", $v) ){
				$v = str_ireplace( "enum_ogl_", "", $v );
				$cmd = "";
				for( $i=0; $i<strlen($v); $i++ ){
					$l = substr( $v, $i, 1 );
					if( $l == '_' && $i < 1 ){ $cmd .= '_'; }
						else if( $l == '_' ){ $cmd .= "{ws}+"; }
						else if( $l == '$' ){ $cmd .= "\\$"; }
						else { $cmd .= $l; }
					}

				$cmd .= "";
				$n = ((50 - strlen($cmd)) > 0) ? (50 - strlen($cmd)) : 10;
				$v = preg_replace( "/(\w)_(\w)/", "$1 $2", $v );
				$cmd .= str_repeat( ' ', $n );
				$cmd .= "{	printf(\"$v => %s\\n\", yytext); nchar += yyleng; return $tok; }\n";

				$lex .= $cmd;
				$test .= "	a$ = $v\n";
				}
		}

	$lex = str_replace( "
", "\n", $lex );
	$test = str_replace( "
", "\n", $test );

	$file = file_get_contents( "./bas.l" );
	$file = str_replace( "
", "", $file );
	$a = explode( "\n", $file );

	$line = 0;
	$flag = false;
	foreach( $a as $k=>$v ){
		if( preg_match("/begin lex/i", $v) ){ $flag = true; $line = $k+1; continue; }
		if( preg_match("/end lex/i", $v) ){ $flag = false; }
		if( $flag ){ unset($a[$k]); }
		}

	array_splice( $a, $line, 0, $lex );
	$b = implode( "\n", $a );
	file_put_contents( "./bas.l", $b );
	file_put_contents( "./test.bas", $test );

function mySort( $a, $b ){ return strlen($a) - strlen($b); }

