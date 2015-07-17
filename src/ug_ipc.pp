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
// Memory Semaphore Based Interprocess Communication built on top of FreePascal
// simpleipc unit.
//
// FileName: YYYYMMDDHHNNSSCCCRRRRRRRRRR.extension
// YYYY = YEAR     CCC = Milli Seconds
// MM = Month      RRRRRRRRRR = RANDOM NUMBER (31 bit range)
// DD = DAY
// HH = HOUR
// NN = MINUTES
// SS = SECONDS
//
unit ug_ipc;
//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_template.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{INCLUDE i_jegas_ipc_file.pp}
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
uses 
//=============================================================================
  classes,
  sysutils,
  dos, 
  simpleipc,
  ug_ipc_send_file,
  ug_jegas,
  ug_common;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
{}
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_saCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saSendToWhom: ansistring;
  p_saPath: ansistring
): Boolean;
//=============================================================================

//function saGetUniqueCommID: ansistring;


//=============================================================================
{}
// in this implementation - this is the FULL FILENAME AND PATH
// LESS the Extension. c:\fifopath\4312412334312421432141414
// -
// the p_bExact means you aren't polling for a filespec within
// the current 
// - 
// NOTE: Wild Card "time range" resolution is hardcoded in this routine
// and is easy enough to tighten up... but its based on YYYYMM
// TODO: Logic to handle crossing "boundries" like a New year
// or month, or day or whatever the resolution is should be handled
// by EXACT CALL that is p_saComm='*', p_bExact=true.
// this will bring all *.FIFO in the path sent WHICH could
// make an infinate loop if files aren't delete after being processed 
// OR an error condition!!! This can get dicey. A manner to fix this sounds
// simple enough - just delete the file or rename if error... BUT.... 
// the advanced FPC file handling - uses SYSUTILS unit which brings
// with it OOP support internally to itself, BUT causes the runtime EXE size
// to get big - this is fine usually - but not with the thin layer design for 
// the CGI. This should be OK for now because of the fact that I personally
// play on FIFO going out, and a separate FIFO coming in. (2 directories)
// which makes allowance for "problem situations" to be handled by the 
// BIG applications that are OOP anyway and don't have the problem
// of using the FPC sysutils overhead.
//
// NOTE: You know - I don't know which units may or may not require 
// (internally) the OOP support in linux. Hmm.
{
Function bIPCWait(
  Var p_saCommID: AnsiString; 
  p_bExact: Boolean; 
  p_saPath: AnsiString;
  Var p_saExt: AnsiString;
  p_iMaxWaitInMilliSeconds:Integer
): Boolean;

}


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
//=============================================================================
//=============================================================================


//=============================================================================
//function saGetUniqueCommID: ansistring;
//=============================================================================
//begin
//  result:=FloattoStr(TimeStampToMsecs(DateTimeToTimeStamp(now)))+
//          '_'+saZeroFillInt(Random(99999)+1,6);
//end;
//=============================================================================


//=============================================================================
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_saCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saSendToWhom: ansistring;
  p_saPath: ansistring
): Boolean;
//=============================================================================
var bServerOffline: boolean;
begin
  bServerOffline:=false;
  If p_bGenerateCommID Then
  Begin
    p_saCommID:=saGetUniqueCommID(p_saPath);
  End;

  With TSimpleIPCClient.Create(Nil) do 
  begin
    ServerID:=p_saSendToWhom;
    try
      Active:=True;
    except
      bServerOffline:=true;
    end;  
    if not bServerOffline then
    begin
      SendStringMessage(p_sa);
      Active:=False;
    end;
    Free;
  end;
  result:=(bServerOffline=false);
end;
//=============================================================================



//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
