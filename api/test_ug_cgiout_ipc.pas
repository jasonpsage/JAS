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
{ }
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
{$INCLUDE i_jegas_macros.pp}
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
  scommid: String;
  saFIFO_OUT: AnsiString;
  saFIFO_IN: AnsiString;
  u8Err: Uint64;
  rMyCGI: rtCGI;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  Writeln;
  Writeln;
  Writeln('PROGRAM: test_ug_cgiout_ipc');
  Writeln;
  Writeln('NOTE: You will need to look at the source code and modify the ');
  writeln('      hardcoded directories. The file based CGI IPC needs two ');
  writeln('      folders for its bidirectional communication.');
  Writeln('                                        -- Jason P Sage');
  Writeln;
  Writeln('-------OUTPUT BELOW--------');
  rMyCGI.uEnvVarCount:=0;//shut up compiler
  //Writeln(saCGIHdrPlainText);
  u8Err:=i8CGIIN;
  if u8Err=0 then
  Begin
    saFIFO_OUT:='c:\FIFO_cgiin\';
    saFIFO_IN:= 'c:\FIFO_cgiout\';
    //saCommID:=saFIFO_OUT;
    Writeln('I have ',rcgiin.uEnvVarCount,' ');
    sCommID:='';//shutup compiler
    //if bIPCSendCGI(rCGIIN,saCommid) then
    Begin
      //Writeln('saCommID returned from SendCGI:',saCommid);
      sCommID:='200607241344150211479154115';
      if bIPCRecvCGI(rMyCGI,sCommID,saFIFO_OUT,'FIFO',true) then
      Begin
        Writeln('saCommID returned from RecvCGI:',sCommid);
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
    Writeln('Got u8CGIIN err:',u8Err);
  End;   
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

