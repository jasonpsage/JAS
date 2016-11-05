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
// Tests Jegas' Filebased Interprocess Communication Suite
program test_ug_ipc_file;
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
  u8Err: uint64;
  rMyCGI: rtCGI;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  rMyCGI.uEnvVarCount:=0;//shut up compiler
  Writeln(saCGIHdrPlainText);
  u8Err:=u8CGIIN;
  if u8Err=0 then
  Begin
    saFIFO_OUT:='.'+DOSSLASH+'data'+DOSSLASH+'fifo'+DOSSLASH+'out'+DOSSLASH;
    //saFIFO_IN:= '.'+DOSSLASH+'data'+DOSSLASH+'fifo'+DOSSLASH+'in'+DOSSLASH;

    //saCommID:=saFIFO_OUT;
    Writeln('I have ',rcgiin.uEnvVarCount,' ');
    sCommID:='';//shutup compiler


    if bIPCSendCGI(rMyCGI,sCommid,true,saFIFO_OUT,'FIFO') then
    Begin
      Writeln('sCommID returned from SendCGI:',sCommid);
      //sCommID:='200607231434090711171815599';
      if bIPCRecvCGI(rMyCGI,sCommID,saFIFO_OUT,'FIFO',true) then
      Begin
        Writeln('sCommID returned from RecvCGI:',sCommid);
        Writeln('Um.. guess it worked');
      End
      else
      Begin
        Writeln('bIPCRecvCGI failed');
      End;
    End
    else
    Begin
      Writeln('bIPCSendCGI Failed');
    End;
  End
  else
  Begin
    Writeln('u8Err: ',u8Err);
  End;   
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

