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
// Test FreePascall PROCESS Unit and TPROCESS Class
program testtprocess;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
//=============================================================================


//=============================================================================
uses
//=============================================================================
 Classes,
 SysUtils,
 process,
 ug_common;
//=============================================================================


//=============================================================================
var
//=============================================================================
  p: TProcess;
  
  M: TMemoryStream;
  BytesRead: Integer;
  N: Integer; 
  //ix:Integer;
  sa:ansistring;
  saOut: ansistring;

  Const READ_BYTES=2048;
//=============================================================================

//=============================================================================
begin
//=============================================================================
 sa:='hello';
 p:=TProcess.create(nil);
 m:=TMemoryStream.create;
 p.commandline:='teststdinout';
 p.options:=p.options+[pousepipes];
 P.execute;
 P.Input.Write(pchar(sa)^,length(sa));
 bytesread:=0;
  While P.Running Do
  Begin          
    M.SetSize(BytesRead + READ_BYTES);// make sure we have room
    n := P.Output.Read((M.Memory + BytesRead)^, READ_BYTES);//// try reading it
    If n > 0 Then Begin Inc(BytesRead, n); End Else Begin Yield(100); End;
  End;

  // read last part
  repeat
    M.SetSize(BytesRead + READ_BYTES);// make sure we have room
    n := P.Output.Read((M.Memory + BytesRead)^, READ_BYTES);// try reading it
    If n > 0 Then Inc(BytesRead, n); 
  Until n <= 0;
  M.SetSize(BytesRead);
  setlength(saOut,M.Size);
  M.ReadBuffer(PCHAR(saOut)^, M.Size);
  M.Destroy;M:=nil;
  P.Destroy;P:=nil;
  writeln('output:',saout);
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

