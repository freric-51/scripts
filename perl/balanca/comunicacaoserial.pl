#!/usr/bin/perl

   # este eh o script que roda a leitura continua da porta serial
   # acrescente um caracter 13 (0D hex) no final da transmissao do scanner
   # pois eh isto que este programa procura
   # nao esqueca de dar permissao para o usuario acessar a porta !

   require "global.pl" ;
   require "serial.pl" ;

   # define as variaveis globais usadas na comunicacao
   $SOH = "\x01" ; # start of heading
   $STX = "\x02" ; # start of text
   $ETX = "\x03" ; # end of text
   $EOT = "\x04" ; # end of transmission
   $ACK = "\x06" ; # acknoledge
   $DLE = "\x10" ; # data link escape 16d
   $NAK = "\x15" ; # not ack or BCC error 21d
   $FF  = "\xff" ;
   $CR  = "\x0D" ; # seja o prefixo usado no scanner

   # variaveis locais
   $Erro = $False ;
   $Msg = "";
   my $Buffer_Serial = "" ;
   my $PosicaoFim = 0 ;

   # serial
   ($Erro,$Msg) = Inicia_Serial();
   if ($Erro == $True)
   {
      # log
      die ;
   }

   # Loop da maquina de estados
   $Dado="1";
   while ($Dado < 4)
   {
      # espera tempo
      select(undef,undef,undef,0.50);
      #Maq_Estado() ;
     Escrever_Serial("Oi mundo $Dado\x0A\x0D");
     $Dado = $Dado + 1;

   # fim do while
   }
   while (1==1)
   {
      # espera tempo
      select(undef,undef,undef,0.30);

      ($Erro,$Msg) = Ler_Serial() ;
      if ($Erro == $False)
      {
         if ( $Msg eq "")
         {
            # nao recebi nada
         }
         else
         {
            $Buffer_Serial =$Buffer_Serial . $Msg ;
            if (length($Buffer_Serial) > 512)
            {
               #print "buffer passou de 512 elementos\n";
               $Buffer_Serial = substr($Buffer_Serial,(length($Buffer_Serial)-512));
            }
         }
       }

      ($PosicaoFim) = ProximaPos($Buffer_Serial,$CR);
      if ( !$PosicaoFim )
      {
         # nao veio o fim ainda
      }
      else
      {
        $Buffer_Serial = substr( $Buffer_Serial,0,($PosicaoFim -1) );
        $Buffer_Serial = "-" . $Buffer_Serial . "-" ;


         print "Lido:$Buffer_Serial \n";
         $Buffer_Serial = "" ;
      }

   }

   # fechar tudo
   Fechar_Serial();
