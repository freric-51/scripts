# 1996

Montar computadores é algo que faço para meu uso pessoal desde longo tempo.
Previamente eu havia montado um computador com o processsador NEC V20 que era um clone do 8088 rodando a 8 MHz, depois passei para um 386SX, época dos PCs onde o estado de arte ficava a cargo da dupla DOS 6 e Windows 3.11.

Para cada aplicação deveria-se iniciar o computador com um limite de drivers e variáveis de sistema para que os 640 KBytes de RAM ( *memória baixa* ) pudessem ser reservados para a aplicação a ser usada.
<br /> **acad12.bat** é o típico exemplo onde na primeira linha eu ajustava o mouse para o autocad.
<br />Nada de multimidia on board. Som e video só em placas separadas colocadas no barramento ISA e eu só liberava a placa de som para os joguinhos dos meus filhos.
<br />O DOS/WINDOWS carregava, por padrão, tudo na *memória baixa* e todo os periféricos com as respecivas ROMs e área de transferência de dados ficavam na *memória alta*, endereçados dos 640 KB até os 1024 KB ( 384 KB ).
**DEVICEHIGH** apareceu como uma diretiva *fantástica* do config.sys. No computador eu instalava 1024 MB de RAM e a *memória alta* era como um espelhamento desta RAM com o IO, isso mesmo, eu não tinha disponíveis 384 KB de RAM, eu tinha 384 KB menos o usado pelo IO. Assim, a **DEVICEHIGH** direcionava os **drivers** para a memória não usada pelo IO.
Os **drivers** eram carregados na ordem que estavam no arquivo config.sys e isso fazia a diferença entre o driver funcionar ou não. Os trechos usáveis de RAM concorriam com o IO e os drivers não se segmentavam na RAM, então tinha muita tentativa e erro até o sistema se estabilizar.
<br />Os arquivos config.sys e autoexec.bat, que eu usava, possuiam um menu de escolha sincronizada para o momento do boot. Coloco eles aqui **lado a lado** para de ter uma idéia de como eram montados:

## Obs:.

- O comando para colocar drivers na *memória alta* no autoexec.bat era o **LH**.
- nu = Norton Utilities
- ndd.exe = Norton Disk Doctor
- Desde aquele tempo o **Bradesco** era chato com o uso do aplicativo do banco.

|config.sys|autoexec.bat|
|:-|:-|
|[MENU]|@ECHO Off|
|Menuitem=Games|VERIFY=ON|
|Menuitem=Dos|PATH C:\DOS;C:\WIN;C:\SOFW\EXCEL;C:\;C:\UTI\NU;C:\UTI\ZIP;C:\UTI\DOS|
|Menuitem=Bradesco|PROMPT $P$G|
|Menuitem=Windows311|SET TEMP=c:\dos\tmp|
||c:|
||cd\dos\tmp|
||c:\dos\attrib -r|
||del *.tmp|
||del ~*.*|
||cd\|
||c:\uti\nu\ndd /quick|
||GOTO %CONFIG%|
|||
|[Dos]|:Dos|
|rem DEVICE=C:\DOS\SETVER.EXE|MODE CON CODEPAGE PREPARE=((850) C:\DOS\EGA.CPI)|
|DEVICE=C:\dos\HIMEM.SYS|MODE CON CODEPAGE SELECT=850|
|DEVICE=C:\dos\EMM386.EXE AUTO NOEMS X=E000-EFFF|SET SOUND=C:\UTI\SB16|
|DOS=HIGH,UMB|SET BLASTER=A220 I5 D1 H5 P330 E620 T6|
|COUNTRY=055,,C:\DOS\COUNTRY.SYS|SET MIDI=SYNTH:1 MAP:E MODE:0|
|**DEVICEHIGH**=C:\DOS\DISPLAY.SYS CON=(EGA,,2)|c:\UTI\SB16\DIAGNOSE /S|
|FILES=40|C:\UTI\SB16\AWEUTIL /S|
|SHELL=C:\COMMAND.COM C:\ /E:512 /P|C:\UTI\SB16\MIXERSET /P /Q|
|BREAK=ON|**LH** C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:8 /V /E /S /L:E|
|BUFFERS=15|C:\dos\SMARTDRV.EXE /X 2048 128|
|FCBS=4,0|c:\uti\vir\vshield /lock /only A: /bootaccess /noexpire|
|LASTDRIVE=Z|c:\uti\sb16\ct3dse on|
|STACKS=9,256|rem lh c:\uti\mou\gmouse *41|
|**DEVICEHIGH**=C:\UTI\PLUGPLAY\DRIVERS\DOS\DWCFGMG.SYS|GOTO END|
|**DEVICEHIGH**=C:\UTI\SBCD\DRV\SBIDE.SYS /D:MSCD001 /V /P:170,14||
|rem /P:1E8,11,3EE||
|||
|[Games]|:Games|
|REM DEVICE=C:\dos\HIMEM.SYS|SET SOUND=C:\UTI\SB16|
|DOS=UMB,HIGH|SET BLASTER=A220 I5 D1 H5 P330 E620 T6|
|FILES=20|SET MIDI=SYNTH:1 MAP:E MODE:0|
|BREAK=ON|C:\UTI\SB16\DIAGNOSE /S|
|BUFFERS=5|C:\UTI\SB16\AWEUTIL /S|
|FCBS=4,0|C:\UTI\SB16\MIXERSET /P /Q|
|LASTDRIVE=F|**LH** C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:4 /V /E /S /L:E|
|SHELL=C:\COMMAND.COM C:\ /E:1024 /P|rem c:\uti\mou\gmouse *41|
|DEVICE=C:\UTI\PLUGPLAY\DRIVERS\DOS\DWCFGMG.SYS|c:\uti\sb16\ct3dse on|
|DEVICE=C:\UTI\SBCD\DRV\SBIDE.SYS /D:MSCD001 /V /P:170,14|cd\gam|
|rem /P:1E8,11,3EE|GOTO END|
|||
|[Bradesco]|:Bradesco|
|DEVICE=C:\dos\HIMEM.SYS|lh c:\uti\mou\gmouse *41|
|DEVICE=C:\dos\EMM386.EXE RAM 1024 X=E000-EFFF|cd\bradesco|
|DOS=UMB,HIGH|GOTO END|
|FILES=80||
|BREAK=ON||
|BUFFERS=40||
|FCBS=4,0||
|LASTDRIVE=E||
|SHELL=C:\COMMAND.COM C:\ /E:2048 /P||
|||
|[Windows311]|:Windows311|
|rem DEVICE=C:\DOS\SETVER.EXE|MODE CON CODEPAGE PREPARE=((850) C:\DOS\EGA.CPI)|
|DEVICE=C:\dos\HIMEM.SYS|MODE CON CODEPAGE SELECT=850|
|DEVICE=C:\dos\EMM386.EXE AUTO noems X=E000-EFFF|SET SOUND=C:\UTI\SB16|
|DOS=HIGH,UMB|SET BLASTER=A220 I5 D1 H5 P330 E620 T6|
|COUNTRY=055,,C:\DOS\COUNTRY.SYS|SET MIDI=SYNTH:1 MAP:E MODE:0|
|**DEVICEHIGH**=C:\DOS\DISPLAY.SYS CON=(EGA,,2)|C:\UTI\SB16\DIAGNOSE /S /W=C:\WIN|
|FILES=40|C:\UTI\SB16\AWEUTIL /S|
|SHELL=C:\COMMAND.COM C:\ /E:512 /P|C:\UTI\SB16\MIXERSET /P /Q|
|BREAK=ON|**LH** C:\uti\sbcd\drv\MSCDEX.EXE /D:MSCD001 /M:16 /V /E /S /L:E|
|BUFFERS=15|C:\dos\SMARTDRV.EXE /X 4096 4096|
|FCBS=4,0|c:\uti\vir\vshield /lock /only A: /bootaccess|
|LASTDRIVE=Z|c:\uti\sb16\ct3dse on|
|STACKS=9,256|rem lh c:\uti\mou\gmouse *41|
|**DEVICEHIGH**=C:\UTI\PLUGPLAY\DRIVERS\DOS\DWCFGMG.SYS|win|
|**DEVICEHIGH**=C:\UTI\SBCD\DRV\SBIDE.SYS /D:MSCD001 /V /P:170,14|GOTO END|
|**DEVICEHIGH**=C:\WIN\IFSHLP.SYS||
|||
|[COMMON]||
|rem **DEVICEHIGH**=C:\UTI\SB16\DRV\CTSB16.SYS /UNIT=0 /BLASTER=A:220 I:5 D:1 H:5 T6||
|rem **DEVICEHIGH**=C:\UTI\SB16\DRV\CTMMSYS.SYS|:END|
