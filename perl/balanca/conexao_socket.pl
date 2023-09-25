#!/usr/bin/perl

   # este eh o script que roda a conexao com
   # o programa da portaria

   require "global.pl" ;
   require "configuracao.pl" ;
   require "txrx_arq.pl" ;
   require "server_sockets.pl" ;

   # variaveis locais
   $Erro = $False ;
   $Msg = "";


   # sockets
   Inicia_Socket_Servidor();

   # Loop da maquina de estados
   while (1 == 1)
   {
      # espera tempo
      select(undef,undef,undef,1.20);

      Maq_Sockets();

   # fim do while
   }

   # fechar tudo
   Fechar_Socket_Servidor();
