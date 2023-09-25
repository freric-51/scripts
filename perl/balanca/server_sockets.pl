#!/usr/bin/perl

use IO::Socket;

sub Inicia_Socket_Servidor
{  # 192.168.2.184
   $Socket_Servidor = IO::Socket::INET->new(
             LocalAddr => $IP_Servidor,
	     LocalPort => $Porta_Servidor,
	     Proto    => "tcp",
	     Listen   => 5);

   $Passo_Socket_Servidor  = "Escuta" ;
}

# ==========

sub Maq_Sockets
{
   if ($Passo_Socket_Servidor eq "Escuta")
   {
      $SIG{ALRM} = sub { die "timeout" };
         eval
       	 {
            alarm(5);
            $Sck_Serv = ( $Socket_Servidor->accept() );
            alarm(0);
            $Passo_Socket_Servidor  = "Conectado" ;
            # print "conexao pode ter sido aceita\n";
            # eu so vou saber em :
            # print "a conexao nao deu certo ou nunca existiu\n";
         };
         # exception
         if ($@)
         {
            if ($@ =~ /timeout/)
            {
               alarm(0);
               $Passo_Socket_Servidor  = "Escuta" ;
               # nada aconteceu
            }
            else
	    {
               # algo aconteceu mas nao me interessa
               alarm(0);
               $Passo_Socket_Servidor  = "Escuta" ;
	    }
         }
      # fim SIG
   }

   elsif ($Passo_Socket_Servidor eq "Conectado")
   {
      $SIG{ALRM} = sub { die "timeout" };
         eval
       	 {
            alarm(20);
            $Sck_Serv->recv($Answer,8192);
            alarm(0);
            # print "Recebi do socket = $Answer \n";
            if ($Answer eq "\x02;?PESO1=;10;\x03")
            {
               $Passo_Socket_Servidor = "Escreve_Peso";
            }
            else
            {
               print "requisicao invalida do programa : $Answer\n";
            }
         };
         # exception
         if ($@)
         {
            if ($@ =~ /timeout/)
            {
               alarm(0);
               $Passo_Socket_Servidor = "Escuta";
               # print "Sai via timeout = $@\n";
            }
            else
	    {
               alarm(0);
               $Passo_Socket_Servidor = "Escuta";
               # print "a conexao nao deu certo ou nunca existiu\n";
	    }
         }
      # fim SIG


   } # fim escuta
   elsif($Passo_Socket_Servidor eq "Escreve_Peso")
   {

      eval
      {
        ($Peso_Lido,$Msg) = Ler_Dado_Arquivo($Arquivo_Troca_Dados);
        if ($Msg ne "OK")
        {
           $Peso_Lido= -1;
        }

        $Msg = "\x02;PESO1=$Peso_Lido;"  ;
        $Msg = $Msg . length($Msg) ;
        $Msg = $Msg . ";\x03" ;
        $Sck_Serv->send($Msg);
        # print "Enviei $Msg\n";
      };
      # exception
      if ($@)
      {
         print "erro no send $Msg = $@\n";
      }
      # estou retornando
      $Passo_Socket_Servidor = "Escuta"
   }
}

# ==========

sub Fechar_Socket_Servidor
{
   close ($Socket_Servidor);
}

# ==========

   # devo retornar verdadeiro nos modulos
   1;
