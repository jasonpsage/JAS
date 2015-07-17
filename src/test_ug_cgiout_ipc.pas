{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2012 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// Program: test_uxxg_cgiout
// This application simply reads in the drop file
// created by uxxxg_ipc_send_file.pas's bIPCSendCGI.
// Note: as of 2007-06-24 - I (Jason Sage) was making
// little test programs like this as I was adding to Jegas.
// I just wanted to warn ya that - as of today anyways, there 
// are many hardcoded values in this app, so you will need to 
// either refine it to ask the user for details, or do what I did,
// just cut-n-paste filenames or parts of them where I needed,
// preconfigured my FIFO directories, and then recompile it before running.
program test_ug_cgiout_ipc;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  ug_common,
  ug_jfilesys,
  ug_cgiin,
  ug_ipc_send_file,
  ug_ipc_recv_file;
//=============================================================================

//=============================================================================
var
//=============================================================================
  sacommid: AnsiString;
  saFIFO_OUT: AnsiString;
  saFIFO_IN: AnsiString;
  i8Err: int64;
  rMyCGI: rtCGI;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  Writeln;
  Writeln;
  Writeln('PROGRAM: test_uxxg_cgiout');
  Writeln;
  Writeln('NOTE: Look at source code before you judge this program as broken!');
  Writeln('has a lot of hardcoded stuff last I knew... Jason P Sage');
  Writeln;
  Writeln('-------OUTPUT BELOW--------');
  rMyCGI.iEnvVarCount:=0;//shut up compiler
  //Writeln(saCGIHdrPlainText);
  i8Err:=i8CGIIN;
  if i8Err=0 then
  Begin
    saFIFO_OUT:='c:\FIFO_cgiin\';
    saFIFO_IN:= 'c:\FIFO_cgiout\';
    //saCommID:=saFIFO_OUT;
    Writeln('I have ',rcgiin.iEnvVarCount,' ');
    saCommID:='';//shutup compiler
    //if bIPCSendCGI(rCGIIN,saCommid) then
    Begin
      //Writeln('saCommID returned from SendCGI:',saCommid);
      saCommID:='200607241344150211479154115';
      if bIPCRecvCGI(rMyCGI,saCommID,saFIFO_OUT,'FIFO',true) then
      Begin
        Writeln('saCommID returned from RecvCGI:',saCommid);
        Writeln('Um.. guess it worked');
      End
      else
      Begin
        Writeln('bIPCRecvCGI failed');
      End;
    End
    //else
    //Begin
    //  Writeln('bIPCSendCGI Failed');
    //End;
  End
  else
  Begin
    Writeln('Got i8CGIIN err:',i8Err);
  End;   
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

