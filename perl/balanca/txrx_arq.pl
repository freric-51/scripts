#!/usr/bin/perl

sub Grava_Dado_Arquivo
{
   $Dado = shift ;
   $Arq  = shift ;
   open (FileHw, "> $Arq");
   print FileHw $Dado;
   close(FileHw);
   # devo dar chance para o outro
   # programa ler os dados
   select(undef,undef,undef,0.01);
}

sub Ler_Dado_Arquivo
{
   $Arq = shift ;
   $Ret = "";
   $Tentativas = 0 ;
   while (($Ret eq "") and ($Tentativas < 20 ))
   {
      $Msg = "OK" ;
      $Tentativas = $Tentativas + 1 ;
      open (FileHr, "< $Arq") or $Msg="ERRO";

      while (<FileHr>)
      {
         $Ret = $_  ;
      }
      close(FileHr);

      if ($Ret eq "")
      {
         # rapido e cpu = 0
         select(undef,undef,undef,0.01);
      }
   }
   return($Ret,$Msg) ;
}

1;
