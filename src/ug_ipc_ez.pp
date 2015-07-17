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
  saFifoExt: AnsiString;
  saFifoInDir: AnsiString; //from darkgdk to laz
  saFifoOutDir: AnsiString;//from laz to darkgdk
  saFifoInNextCommId: AnsiString;
  i4MaxCBufLen: LongInt; // Max anticipated C++ String Buffer length
End;
//=============================================================================
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
  sa: AnsiString;
  ftext: text;
  saBeforeEqual: AnsiString;
  saFilename: AnsiString;
  TK: JFC_TOKENIZER;
Begin
  Result:= False;
  TK:=JFC_TOKENIZER.Create;
  safileName:=csIPCConfigFileName;
  If bFileExists(safileNAme) Then
  Begin
    assign(ftext, safileNAme);
    reset(ftext);
    While not Eof(ftext) Do
    Begin
      readln(ftext, sa);
      //riteln('READ:',sa);
      sa:= Trim(sa);
      If (Length(sa) <> 0) and (LeftStr(sa, 1) <> ';') Then
      Begin
        // MsgBox sGetStringBeforeEqualSign(s)
        saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
        //riteln('KEY:',saBeforeEqual);
        //riteln('VALUE:',saGetStringAfterEqualSign(sa));
        If saBeforeEqual='IPCFIFOINDIR' Then grIPCConfig.saFifoInDir:=saGetStringAfterEqualSign(sa);
        If saBeforeEqual='IPCFIFOOUTDIR' Then grIPCConfig.saFifoOutDir:=saGetStringAfterEqualSign(sa);
        If saBeforeEqual='IPCFIFOOUTDIR' Then grIPCConfig.saFifoOutDir:=saGetStringAfterEqualSign(sa);
      End;// if
    End;// while loop
    Close(ftext);
    Result:= True;
  End
  Else
  Begin
    // do nothing - this function should return false then!
    //Writeln('Config File Missing:',saFilename);
    Result:=False;
  End;
  TK.Destroy;
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
  saCommid: AnsiString;
Begin
  saCommId:='';
  If(bIPCSend(
      p_saMsg,
      saCommId,
      True,
      grIPCConfig.saFifoInDir,
      grIPCConfig.saFifoExt)
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
  saCommid: AnsiString;
Begin
  saCommId:='';

  If(bIPCSend(
      p_saMsg,
      saCommId,
      True,
      grIPCConfig.saFifoOutDir,
      grIPCConfig.saFifoExt)
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
  saCommid: AnsiString;
//  saDataIn: ansistring;
Begin
  saCommId:='';saCommId:=saCommId;//shut up compiler
  If(bIPCWait(
    saCommId,
    False,
    grIPCConfig.saFifoOutDir,
    grIPCConfig.saFifoExt,
    0)
  )Then
  Begin
    If(bIPCRecv(
      gsaIPC_MessageBufferOut,
      saCommId,
      grIPCConfig.saFifoOutDir,
      grIPCConfig.saFifoExt,True)
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
  saCommid: AnsiString;
//  saDataIn: ansistring;
Begin
  saCommId:='';saCommId:=saCommId;//shut up compiler
  If(bIPCWait(
    saCommId,
    False,
    grIPCConfig.saFifoInDir,
    grIPCConfig.saFifoExt,
    0)
  )Then
  Begin
    If(bIPCRecv(
      gsaIPC_MessageBufferOut,
      saCommId,
      grIPCConfig.saFifoInDir,
      grIPCConfig.saFifoExt,True)
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
grIPCConfig.saFifoExt:=csIPCExt;
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
