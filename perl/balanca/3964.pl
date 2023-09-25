#!/usr/bin/perl

sub Define_Constantes
{
   # define as variaveis globais usadas na comunicacao
   $SOH = "\x01" ; # start of heading
   $STX = "\x02" ; # start of text
   $ETX = "\x03" ; # end of text
   $EOT = "\x04" ; # end of transmission
   $ACK = "\x06" ; # acknoledge
   $DLE = "\x10" ; # data link escape 16d
   $NAK = "\x15" ; # not ack or BCC error 21d
   $FF  = "\xff" ;

   $Passo_3964  = "Rx20" ;
   $Buffer_Serial = "" ;
}

# ==========

sub Maq_3964
{
   # sempre leio a serial para nao estourar o buffer
   # eu sei que a maior mensagem tem 256 elementos, leio o dobro

   ($Erro,$Msg) = Ler_Serial() ;
   if ($Erro == $False)
   {
      $Buffer_Serial = $Buffer_Serial . $Msg ;
      if (length($Buffer_Serial) > 512)
      {
         #print "buffer passou de 512 elementos\n";
         $Buffer_Serial = substr($Buffer_Serial,(length($Buffer_Serial)-512));
      }
   }

   if ($Passo_3964 eq "Rx20")
   {
      Escrever_Serial($STX);

      Clear(1,24);
      SetPos(3,30);
      ($seg,$min,$hora,$mdia,$mes,$ano,$diasem,$diaano) = gmtime(time);
      print " ".($hora).":".$min.":".$seg." \n"; #GMT
      # SetPos(2,30);
      # print "Inatividade_Balanca = $Inatividade_Balanca";
      $Inatividade_Balanca = $Inatividade_Balanca + 1 ;

      SetPos(5,30);
      print "PESO = $Peso_Balanca Kg\n";
      # o que mostro na tela eh o que vai pra frente
      Grava_Dado_Arquivo($Peso_Balanca,$Arquivo_Troca_Dados);

      if($Inatividade_Balanca > 10)
      {
         $Inatividade_Balanca = 0 ;
         $Peso_Balanca=0;
         SetPos(5,30);
         print "PESO = $Peso_Balanca\n";
         print "Nao estou recebendo sinal da balanca\n";
      }
      # print "(1) enviei stx espero DLE\n";
      $Passo_3964 = "Rx21";
   }
   elsif ($Passo_3964 eq "Rx21")
   {
      ($PosicaoDLE) = ProximaPos($Buffer_Serial,$DLE);
      if ( !$PosicaoDLE )
      {
         # zerar o buffer
         # $Buffer_Serial="";
         # tentar de novo
         $Passo_3964 = "Rx20";
      }
      else
      {
         #Limpando o buffer
         $Buffer_Serial = substr($Buffer_Serial,($PosicaoDLE + 1));

         $Msg = "01#TG#" ; # a mensagem em si
         $Msg = $Msg.$DLE.$ETX ; # o fim $Msg.$STX.$DLE.$ETX
         $iBCC = Calcula_BCC($Msg);
         $Msg = $Msg.chr($iBCC);
         Escrever_Serial($Msg);

         #print "BCC = $iBCC  msg = +$Msg+ tamanho=".length($Msg)."\n";
         #print "---------------------------------------\n";
         $Passo_3964  = "Rx22" ;

      }
   }

   elsif ($Passo_3964 eq "Rx22")
   {
      # se nao reconhecer recebo NAK
      ($PosicaoNAK) = ProximaPos($Buffer_Serial,$NAK);
      if ( !$PosicaoNAK )
      {
         #$Passo_3964 = "Rx23";
      }
      else
      {
         $Buffer_Serial = substr($Buffer_Serial,($PosicaoNAK + 1));
         $Passo_3964 = "Rx20";
      }

      # se reconhecer recebo DLE
      ($PosicaoDLE) = ProximaPos($Buffer_Serial,$DLE);
      if ( !$PosicaoDLE )
      {
         # print "\nnao recebi DLE cheguei ate aqui\n";
         # $Buffer_Serial = "" ;
         $Passo_3964 = "Rx20";
      }
      else
      {
         # print "GANHEI UM DLE ! A BALANCA ME ENTENDEU\n";
         $Buffer_Serial = substr($Buffer_Serial,($PosicaoDLE + 1));
         $Passo_3964 = "Rx01";
         $Inatividade_Balanca = 0 ;
      }
   }

   #
   # agora a balanca responde
   #
   elsif ($Passo_3964 eq "Rx01")
   {
      ($PosicaoSTX) = ProximaPos($Buffer_Serial,$STX);
      if ( !$PosicaoSTX )
      {
         # print "A BALANCA ESTA QUIETA ?????\n$Buffer_Serial\n";
         $Passo_3964 = "Rx20";

      }
      else
      {
         # print "balanca inicia transmissao\n";
         # retirar o stx
         $Buffer_Serial = substr($Buffer_Serial,($PosicaoSTX + 1));
         # respondo
         Escrever_Serial($DLE);

         $Time_Out_3964 = 0;
         $Passo_3964 = "Rx02" ;
      }
   }

   # aguardo fim da mensagem ou time out
   elsif ($Passo_3964 eq "Rx02")
   {
      # pego informacao quando houver ETX

      $Time_Out_3964 = $Time_Out_3964 + 1;

      if($Time_Out_3964 > 60)
      {
         $Passo_3964 = "Rx20";
         # print "RETORNO POR ESTOURO DE TEMPO\N";
      }

      ($PosicaoETX) = ProximaPos($Buffer_Serial,$ETX);
      if ( !$PosicaoETX )
      {
         #print "Nao existe etx\n";
      }
      else
      {
         #print "A BALANCA ENVIOU\n$Buffer_Serial\n\n";

         ($Erro,$Msg) = Retorna_Peso($Buffer_Serial) ;
         if ($Erro == $False)
         {
            $Peso_Balanca = $Msg ;
            Escrever_Serial($DLE);
            # esta la em cima
            # print "Peso = $Peso_Balanca \n";
            #SetPos(5,30);
            #print "PESO = $Peso_Balanca\n";
         }
         else
         {
            Escrever_Serial($NAK);
         }
         # limpo os dados ja lidos
         $Buffer_Serial = "";
         # volto para o inicio
         $Passo_3964 = "Rx20" ;

      } # fim achei fim
   } # fim passo

}

# ==========

sub Verifica_BCC
{
   #   se erro msg = erro else msg = dados
   $DadosBCC = shift ;
   #   print "a analizar=$DadosBCC=".length($DadosBCC). "\n";
   #   pego o BCC
   #   ($PosicaoETX) = ProximaPos($DadosBCC,$ETX);
   #   $BCC_Serial = substr($DadosBCC,$PosicaoETX,1);
   #   print "bcc serial = " . ord($BCC_Serial)." \nposicao $PosicaoETX\n";

   #   $Msg=substr($DadosBCC,0,($PosicaoETX - 1));
   #   print"eh isto que eu eu estou=$Msg   ".length($Msg)."\n";
   #   ($BCC_Calc) = Calcula_BCC($Msg);
   #   print "bcc calculado = $BCC_Calc \n";

   $Erro = $False ;
   $Msg = $DadosBCC ;

   return($Erro,$Msg) ;
}

# ==========

sub Calcula_BCC
{
   $Dados_Calc = shift;
   $i1=0;
   $iCalc=0;
   $ValorLimite = 2 ** $SerialDataBits ;
   # posso fazer o BCC a partir de 11111111
   # $Dados_Calc = $FF.$Dados_Calc ;

   while ($i1 < length($Dados_Calc))
   {
      $Chr1=ord(substr($Dados_Calc,$i1,1));
      $iCalc = $iCalc ^ $Chr1;
      if ( $iCalc > $ValorLimite )
      {
         $iCalc = $iCalc - $ValorLimite ;
      }
      $i1 = $i1 + 1 ;
   }
   return($iCalc);
}

# ==========

sub Analiza_Mensagem
{
   # se erro msg = erro else msg = dados
   $DadosAM = shift ;
   $Tamanho_Recebe_Serial = 36 ;
   $Erro = $False ;
   $Msg = $DadosAM ;
   if (length ($DadosAM) < $Tamanho_Recebe_Serial)
   {
      $Erro = $True ;
      $Msg = "Erro de Tamanho " .length($DadosAM) ."<" .$Tamanho_Recebe_Serial;
      print "\n" .$Msg ."\n" ;
   }
   return($Erro,$Msg) ;
}

sub Retorna_Peso
{
   # se erro msg = erro else msg = dados
   $DadosRP = shift ;

   $Erro = $False ;
   $Msg = $DadosRP ;
   $Peso = 0 ;

   $Posicao_Inicio_Peso = (length("01#TG#")) ;
   $Tamanho_Peso = 7 ;

   ($Erro,$Msg) = Analiza_Mensagem ($DadosRP);

   if ($Erro == $False)
   {
      ($Erro,$Msg) = Verifica_BCC ($DadosRP);
   }

   if ($Erro == $False)
   {
      $Msg = substr($DadosRP,$Posicao_Inicio_Peso,$Tamanho_Peso) ;
      #print"$Msg\n";
      $Peso = $Msg * 1 ;
      #print"PESO =$Peso\n";
   }

   return($Erro,$Peso) ;

}

   # devo retornar verdadeiro nos modulos
   1;
