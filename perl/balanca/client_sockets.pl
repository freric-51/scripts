#!/usr/bin/perl

sub Inicia_Socket_Cliente
{
   use IO::Socket;

   $Socket_Cliente = IO::Socket::INET->new(
             PeerAddr => $IP_Cliente ,
             PeerPort => $Porta_Cliente,
             Proto    => "tcp",
             type     => SOCK_STREAM,
             Timeout  => 50 );
             #  or die "processo nao conectado \n";

   #aguarda resposta
   $SIG{ALRM} = sub { die "timeout" };
   eval
   {
      alarm(10); # tempo em segundos
      $Socket_Cliente->recv($Answer,8192) or die "Can't recv: $!\n";
      alarm(0);
   };

   if ($@)
   {
      if ($@ =~ /timeout/)
      {
         print "Sai via timeout\n";
      }
      else
      {
         alarm(0);
      }
   }

   print "A conexao foi feita e respondeu : $answer\n";
}

# ==========
   # devo retornar verdadeiro nos modulos
   1;
