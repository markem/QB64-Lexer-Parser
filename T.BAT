cls
del lex.yy.c
del y.tab.c
del t.exe

flex bas.l
bison -d bas.y
gcc lex.yy.c -o t.exe > out.dat 2>&1
t.exe < test.bas > out.dat
