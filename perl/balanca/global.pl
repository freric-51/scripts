#!/usr/bin/perl

   # variaveis globais ;
   $True = 1 ;
   $False = 0 ;


sub ProximaPos
{
   $_ = shift;
   $chr = shift ;
   /($chr)/gc;
   return( pos() );
}

######
# Limpa uma regiao da tela
#passada como parametro (Linha Inicio, Linha Final)
######

sub Clear
{
  my($LinIni) = shift;
  my($LinFim) = shift;
  print "\033[".$LinIni.";1H";
  for ($i=1;$i<=$LinFim;$i++) {
      print "\033[0J";
      print "\033E";
  }
  print "\033[".$LinIni.";1H";
}

######
# Seta a Posicao do cursor na tela, parametro (Linha,Coluna)
######

sub SetPos
{
  my($Lin)=shift;
  my($Col)=shift;
  print "\033[".$Lin.";".$Col."H";
}

   # devo retornar verdadeiro nos modulos
   1;
