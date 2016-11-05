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
// This unit serves as a simple Interprocess Communication unit - it attempts
// to simplify the coding required to get information from one process to
// another. It's not the fastest solution in the world but it's not slow either
// and its performance is highly dependent on the amount of information being
// passed. It's a filebased solution.
//
//----
// Sample Config File (Name: jegas_ipc.cfg)
//
// IPCFIFOINDIR=c:/sample/in/         <--NOTE "In to Program 1"
// IPCFIFOOUTDIR==c:/sample/out/      <--NOTE "Oout to Program 2"
//
// Remember to think of the whole "Program1" and "Program2" bit to make sense
// of the direction of data flow.
//
//
//Change the debug code to not use sagelog, but to use what we
// use now - text out in (IO) uxxg_common.pp
//-------
Unit ug_ipc_ez;
//=============================================================================

//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_ipc_ez.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               Interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************




//=============================================================================
Uses 
//=============================================================================
sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_tokenizer
,ug_ipc_recv_file
,ug_ipc_send_file
,ug_ipc_wait_file
;
//=============================================================================






//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
// Name of the configuration file used by the unit.
Const csIPCConfigFileName='jegas_ipc.cfg';
// File extension of drop files created and read by this unit.
Const csIPCExt='FIFO';
//=============================================================================
{}
// this structure holds the configuration information required for the unit
// to operate.
Type rtIPCConfig=Record
  sFifoExt: String;
  saFifoInDir: AnsiString; //from darkgdk to laz
  saFifoOutDir: AnsiString;//from laz to darkgdk
  saFifoInNextCommId: AnsiString;
  i4MaxCBufLen: LongInt; // Max anticipated C++ String Buffer length
End;
//=============================================================================
{}
Var
  grIPCConfig: rtIPCConfig; //<global instance of the configuration record 
  gsaIPC_MessageBufferIn: AnsiString;//<Ansistring Message Buffer - inbound
  gsaIPC_MessageBufferOut: AnsiString;//<ansistring Message Buffer - outbound
{}
//=============================================================================
{}
// Loads this unit's configuration file
Function bIPCLoadConfigFile: Boolean;
//=============================================================================
{}
// Initializes this unit
Function ipc_init:Boolean;
//=============================================================================
{}
// This unit is designed to allow TWO applications to talk to one another. 
// Therefore one application should be decidedly "App 1" and the other "App 2"
// then this function should be used for "App 2" to send a message to "App 1"
Function ipc_sendmsg2(p_saMsg: AnsiString): LongInt;
//=============================================================================
{}
// This unit is designed to allow TWO applications to talk to one another. 
// Therefore one application should be decidedly "App 1" and the other "App 2"
// then this function should be used for "App 1" to send a message to "App 2"
Function ipc_sendmsg1(p_saMsg: AnsiString): LongInt;
//=============================================================================
{}
// This unit is designed to allow TWO applications to talk to one another. 
// Therefore one application should be decidedly "App 1" and the other "App 2"
// then this function should be used for "App 2" to get a message from "App 1"
Function ipc_getmsg2: AnsiString;
//=============================================================================
{}
// This unit is designed to allow TWO applications to talk to one another. 
// Therefore one application should be decidedly "App 1" and the other "App 2"
// then this function should be used for "App 1" to get a message from "App 2"
Function ipc_getmsg1: AnsiString;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                                Implementation
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
Function bIPCLoadConfigFile: Boolean;
//=============================================================================
Var
  bOk:Boolean;
  sa: AnsiString;
  ftext: text;
  saBeforeEqual: AnsiString;
  saFilename: AnsiString;
  //TK: JFC_TOKENIZER;
  u2IOResult: word;
Begin
  bOk:=true;u2IOREsult:=0;
  //TK:=JFC_TOKENIZER.Create;
  safileName:=csIPCConfigFileName;
  bOk:=FileExists(safileNAme);
  if bOk then
  begin
    assign(ftext, safileNAme);
    try reset(ftext); except on E:Exception do u2IOResult:=60000;end;//try
    u2IOResult+=ioresult;
    bOK:= u2IOResult=0;
  end;

  if bOk then
  begin
    While not Eof(ftext) Do
    Begin
      readln(ftext, sa);
      sa:= Trim(sa);
      If (Length(sa) <> 0) and (LeftStr(sa, 1) <> ';') Then
      Begin
        saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
        If saBeforeEqual='IPCFIFOINDIR' Then grIPCConfig.saFifoInDir:=saGetStringAfterEqualSign(sa);
        If saBeforeEqual='IPCFIFOOUTDIR' Then grIPCConfig.saFifoOutDir:=saGetStringAfterEqualSign(sa);
        If saBeforeEqual='IPCFIFOOUTDIR' Then grIPCConfig.saFifoOutDir:=saGetStringAfterEqualSign(sa);
      End;// if
    End;// while loop
  end;
  try Close(ftext); except on E:Exception do bOk:=false;end;//try
  Result:=bOk;
  //TK.Destroy;
End;
//=============================================================================



//=============================================================================
Function ipc_init:Boolean;
//=============================================================================
Begin
  Result:=bIPCLoadConfigFile;
End;
//=============================================================================



// Send Data from DarkGDK to Lazarus
//=============================================================================
Function ipc_sendmsg2(p_saMsg: AnsiString): LongInt;
//=============================================================================
Var
  sCommid: String[32];
Begin
  sCommId:='';
  If(bIPCSend(
      p_saMsg,
      sCommId,
      True,
      grIPCConfig.saFifoInDir,
      grIPCConfig.sFifoExt)
  )Then
  Begin
    Result:=1;
  End
  Else
  Begin
    Result:=0;
  End;
End;
//=============================================================================

//=============================================================================
// Send Data from Lazarus to DarkGDK
Function ipc_sendmsg1(p_saMsg: AnsiString): LongInt;
//=============================================================================
Var
  sCommid: String[32];
Begin
  sCommId:='';

  If(bIPCSend(
      p_saMsg,
      sCommId,
      True,
      grIPCConfig.saFifoOutDir,
      grIPCConfig.sFifoExt)
  )Then
  Begin
    Result:=1;
  End
  Else
  Begin
    Result:=0;
  End;
End;
//=============================================================================





//=============================================================================
// Get's stuff FROM Lazarus - Grabs WHOLE msg unlike dll version
//=============================================================================
Function ipc_getmsg2: AnsiString;
//=============================================================================
Var
  sCommid: String[32];
//  saDataIn: ansistring;
Begin
  sCommId:='';sCommId:=sCommId;//shut up compiler
  If(bIPCWait(
    sCommId,
    False,
    grIPCConfig.saFifoOutDir,
    grIPCConfig.sFifoExt,
    0)
  )Then
  Begin
    If(bIPCRecv(
      gsaIPC_MessageBufferOut,
      sCommId,
      grIPCConfig.saFifoOutDir,
      grIPCConfig.sFifoExt,True)
    )Then
    Begin
      Result:=gsaIPC_MessageBufferOut;
    End
    Else
    Begin
      Result:='IPC ERROR';//failed
    End;
  End
  Else
  Begin
    Result:='';// Nothing there
  End;
  gsaIPC_MessageBufferOut:='';
End;
//=============================================================================



//=============================================================================
// Get's stuff FROM DarkGDK - Grabs WHOLE msg unlike dll version
//=============================================================================
Function ipc_getmsg1: AnsiString;
//=============================================================================
Var
  sCommid: String;
//  saDataIn: ansistring;
Begin
  sCommId:='';sCommId:=sCommId;//shut up compiler
  If(bIPCWait(
    sCommId,
    False,
    grIPCConfig.saFifoInDir,
    grIPCConfig.sFifoExt,
    0)
  )Then
  Begin
    If(bIPCRecv(
      gsaIPC_MessageBufferOut,
      sCommId,
      grIPCConfig.saFifoInDir,
      grIPCConfig.sFifoExt,True)
    )Then
    Begin
      Result:=gsaIPC_MessageBufferIn;
    End
    Else
    Begin
      Result:='IPC ERROR';//failed
    End;
  End
  Else
  Begin
    Result:='';// Nothing there
  End;
  gsaIPC_MessageBufferIn:='';
End;
//=============================================================================




//=============================================================================
Begin
grIPCConfig.sFifoExt:=csIPCExt;
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
