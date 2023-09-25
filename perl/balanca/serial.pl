#!/usr/bin/perl

use Device::SerialPort qw( :PARAM :STAT 0.07 ) ;

# ==========

sub Inicia_Serial
{
   $Erro = $False ;
   $Msg = "OK" ;

   # abre a porta serial conforme arquivo de configuracao
   $Configuration_File_Name = "conf_serial.ini" ;

   # Constructors
   ($PortObj = tie (*FHSerial, 'Device::SerialPort', $Configuration_File_Name))
      or $Erro = $True ;

   if ($Erro == $True)
   {
      $Msg = "Nao iniciei serial com $Configuration_File_Name" ;
      print "(Inicia serial) $Erro $Msg \n";
   }
   else
   {
      $PortObj->write_settings;
   }

   # preciso saber para o calculo de BCC (0 a 127) ou (0 a 255)
   $SerialDataBits = $PortObj->databits;

   return($Erro,$Msg) ;
}

# ==========

sub Fechar_Serial
{
   undef $PortObj ;
   untie *FHSerial ;
}

# ==========

sub Escrever_Serial
{

   $String_Saida = shift;
   $Erro = $False ;
   $Msg = $String_Saida;

   (syswrite FHSerial,$String_Saida,length($String_Saida),0) or $Erro = $True ;

   if ($Erro == $True )
   {
      $Msg = "Falhou escrita de serial = $String_Saida" ;
      print "(Escrever_Serial) $Erro $Msg \n";
   }
   # print "Escrito na serial $Erro $Msg \n";
   return($Erro,$Msg) ;
}

# ==========

sub Ler_Serial
{
   $Erro = $False ;
   $String_Entrada = "" ;

   (sysread FHSerial,$String_Entrada,255,0) or $Erro = $True ;
   # se erro normalmente nao leu nada e nao devo fazer nada
   # print "\nLido da serial $Erro --- $String_Entrada \n";
   return($Erro,$String_Entrada) ;
}

# ==========

   # devo retornar verdadeiro nos modulos
   1 ;
