@ECHO Off
VERIFY=ON
PATH C:\DOS;C:\WIN;C:\SOFW\EXCEL;C:\;C:\UTI\NU;C:\UTI\ZIP;C:\UTI\DOS
PROMPT $P$G
SET TEMP=c:\dos\tmp
c:
cd\dos\tmp
c:\dos\attrib -r
del *.tmp
del ~*.*
cd\
c:\uti\nu\ndd /quick
GOTO %CONFIG%

:Dos
MODE CON CODEPAGE PREPARE=((850) C:\DOS\EGA.CPI)
MODE CON CODEPAGE SELECT=850
SET SOUND=C:\UTI\SB16
SET BLASTER=A220 I5 D1 H5 P330 E620 T6
SET MIDI=SYNTH:1 MAP:E MODE:0
c:\UTI\SB16\DIAGNOSE /S
C:\UTI\SB16\AWEUTIL /S
C:\UTI\SB16\MIXERSET /P /Q
LH C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:8 /V /E /S /L:E
C:\dos\SMARTDRV.EXE /X 2048 128
c:\uti\vir\vshield /lock /only A: /bootaccess /noexpire
c:\uti\sb16\ct3dse on
rem lh c:\uti\mou\gmouse *41
GOTO END

:Games
SET SOUND=C:\UTI\SB16
SET BLASTER=A220 I5 D1 H5 P330 E620 T6
SET MIDI=SYNTH:1 MAP:E MODE:0
C:\UTI\SB16\DIAGNOSE /S
C:\UTI\SB16\AWEUTIL /S
C:\UTI\SB16\MIXERSET /P /Q
LH C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:4 /V /E /S /L:E
rem c:\uti\mou\gmouse *41
c:\uti\sb16\ct3dse on
cd\gam
GOTO END

:Bradesco
lh c:\uti\mou\gmouse *41
cd\bradesco
GOTO END

:Windows311
MODE CON CODEPAGE PREPARE=((850) C:\DOS\EGA.CPI)
MODE CON CODEPAGE SELECT=850
SET SOUND=C:\UTI\SB16
SET BLASTER=A220 I5 D1 H5 P330 E620 T6
SET MIDI=SYNTH:1 MAP:E MODE:0
C:\UTI\SB16\DIAGNOSE /S /W=C:\WIN
C:\UTI\SB16\AWEUTIL /S
C:\UTI\SB16\MIXERSET /P /Q
LH C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:16 /V /E /S /L:E
C:\dos\SMARTDRV.EXE /X 4096 4096
c:\uti\vir\vshield /lock /only A: /bootaccess
c:\uti\sb16\ct3dse on
rem lh c:\uti\mou\gmouse *41
win
GOTO END

:END
