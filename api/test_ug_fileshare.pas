{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{ }
// Tests Jegas' FileShare Unit
program test_ug_fileshare;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================




//=============================================================================
uses 
//=============================================================================
  ug_fileshare;
//=============================================================================



//=============================================================================
// MAIN 
//=============================================================================

//=============================================================================
var
//=============================================================================
  ch: char;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  InitFileShare;
  Writeln('s=share, l=lock');
  readln (ch);
  if ch='s' then Begin  
    if bsharefile('testlock','') then Begin
      Writeln('I''m sharing');
      readln;
      ReleaseFile('testlock','');
    End else Begin
      Writeln('I couldn''t get it!');
      readln;  
    End;
  End else Begin
    if bLockFile('testlock','') then Begin
      Writeln('I Own it');
      readln;
      ReleaseFile('testlock','');
    End else Begin
      Writeln('I couldn''t get it!');
      readln;  
    End;
  End;
  DoneFileShare;

//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
