#!/usr/bin/perl

   # este programa serve para preparar o arquivo de configuracao
   # da porta serial

use Device::SerialPort qw( :PARAM :STAT 0.07 );

   # Constructors
   # $quiet and $lockfile are optional
   $PortName = "/dev/ttyS0" ;
   $quite = "false" ;
   $PortObj = new Device::SerialPort ($PortName,$quite)
      || die "Can't open $PortName: $!\n";

   # defino a serial
   $PortObj->baudrate(9600);
   $PortObj->parity("none"); # "none", "odd", "even"
   $PortObj->databits(8); # 5 to 8
   $PortObj->stopbits(1); # 1 and 2
   $PortObj->handshake("none"); # "none", "rts", "xoff"
   $PortObj->alias("COM1");

   # escreve no arquivo
   $Configuration_File_Name = "conf_serial.ini";
   $PortObj->save($Configuration_File_Name)
      || warn "Can't save $Configuration_File_Name: $!\n";

   # libera porta para uso
   $PortObj->close;
   undef $PortObj; # frees memory back to perl

   print "\nGerado arquivo $Configuration_File_Name\n\n";
