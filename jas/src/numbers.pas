{=============================================================================
|    _________ _______  _______  ______  _______  Get out of the Mainstream, |
|   /___  ___// _____/ / _____/ / __  / / _____/    Mainstream Jetstream!    |
|      / /   / /__    / / ___  / /_/ / / /____         and into the          |
|     / /   / ____/  / / /  / / __  / /____  /            Jetstream! (tm)    |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                        Jason@Jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}


//=============================================================================
{}
// Utility to simply create a file with a list on numbers in it.
// it has random usefulness - beat typing them if you need them in a pinch.
// Hi Tech Quantum algorythm - use caution =|:^)>
program numbers;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================



const cnLinesYouNeed = 1000;



//=============================================================================
var
//=============================================================================
  f: text;
  i: longint;
//=============================================================================

//=============================================================================
Begin // Main Program
//=============================================================================
  assign(f,'numbers.txt');
  rewrite(f);
  for i:=1 to cnLinesYouNeed do writeln(f,i);
  close(f);  
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

