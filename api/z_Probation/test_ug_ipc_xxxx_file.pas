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
program test_ug_ipc_xxxx_file;
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
  sCommID: String;
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
    saFIFO_OUT:='c:\FIFO_cgiin\';
    saFIFO_IN:= 'c:\FIFO_cgiout\';
    //saCommID:=saFIFO_OUT;
    Writeln('I have ',rcgiin.uEnvVarCount,' ');
    sCommID:='';//shutup compiler
    //if bIPCSendCGI(rCGIIN,saCommid) then
    Begin
      Writeln('sCommID returned from SendCGI:',sCommid);
      sCommID:='200607231434090711171815599';
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
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

