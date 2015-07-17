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
// Purpose : Move various routines needed by jas-cgi out of the original Jegas
//           API for compiled size reasons. That is the only reason. Rather
//           than duplicate code We have a place to put functions jas-cgi
//           needs.
//
// Original Little Boy-Big Boy CGI paradigm: 2006-07-13 This used a SAM (ISAM
// with no "I") to handle IPC between CGI server and JAS. Then in Linux a 
// memory semaphore system was built. Now we are moving to a IP based solution
// 2009-07-26 :)
// 
// Note: The purpose of this UNIT is to make a CGI application that
// is lean as possible - in that its purpose is to gather all the environment 
// information, send it to another application that will do the actual work,
// and wait for (predetermined maximum wait time) the response and output
// it correctly. In short - trying to offset a BIG application's start up
// time and shut down time - which is normally the Achilles heel of CGI.
//
// So Some routines purposely have been pulled out of the Jegas API and placed
// here specifically to help the CGI app stay small as possible (even Freepascal's
// smart linking technology isn't perfect, so the less unit's we "use" in 
// the CGI app, the smaller the EXE will be - we hope :)
//
// Since the original goal of this file has been tossed to the wind somewhat
// in favor of an IP solution (CGI->TCP/IP->Jegas Application Server),
// we now have classes in the CGI "LittleBoy" Filename: jas-cgi

// The theory is that if I can write a thin enough client that can load quickly
// like a tiny CGI APP... that doens't do a whole hell-uv-a-lot - this might
// be a viable alternative to writing FastCGI hooks, and Apache, IIS  Specific 
// hooks etc. all the while retaining CGI portability.
//
// Because I can't expect the Free Pascal (unpaid) world to respond to my 
// every technical hurdle - I am going to try to make the simplest self
// contained code I can... That is my goal....
// Let's see how this ends up looking. --- Jason P Sage 2006-07-11
Unit ug_misc;
//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_misc.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$DEFINE CGITHIN_TIGHTCODE}
{$IFDEF CGITHIN_TIGHTCODE}
  {$INFO CGITHIN_TIGHTCODE}
{$ENDIF}
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
//Uses //WANT THIS LEAN AS POSSIBLE!
//=============================================================================
{$IFNDEF CGITHIN_TIGHTCODE}
{$ENDIF}
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

var gi4FileIO_BufferSize: longint;

{}
Function saTrim(p_sa: AnsiString):AnsiString;//<Trims white space from both sides of a string
Function saLTrim(p_sa: AnsiString):AnsiString;//<Trims whitespace from left side of a string
Function saRTrim(p_sa: AnsiString):AnsiString;//<Trims whitespace from right side of a string
Function saGetStringBeforeEqualSign(p_sa: AnsiString): AnsiString;//< Hopefully the name is self explanatory. If you pass it "name=value" (without the quotes) you'll get name back.
Function saGetStringAfterEqualSign(p_sa: AnsiString): AnsiString;//< Hopefully the name is self explanatory. If you pass it "name=value" (without the quotes) you'll get value back.
Function saLeftStr(p_sa: AnsiString; p_i: Integer): AnsiString;//< Returns p_i characters from the left side of p_sa
Function saRightStr(p_sa: AnsiString; p_i: Integer): AnsiString;//< Returns p_i characters from the right side of p_sa
Function iVal(p_sa:AnsiString):Longint;//<Converts string to Integer value
Function bFileExists(p_saFileName: AnsiString):Boolean;//<Checks if file exists. Returns true if it does.
//=============================================================================
{}
// for formatting - use freepascal's str directly with
// str(number:digits:decimals, stringresult);
Function saStr(p_i8:Int64):AnsiString;







//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Function saTrim(p_sa: AnsiString):AnsiString;
//=============================================================================
Begin
  Result:=saRTrim(saLTrim(p_sa));
End;
//=============================================================================

//=============================================================================
Function saLTrim(p_sa: AnsiString):AnsiString;
//=============================================================================
Begin
  While (length(p_sa)>0) and (copy(p_sa,1,1)=' ') Do delete(p_sa,1,1);
  Result:=p_sa;
End;
//=============================================================================

//=============================================================================
Function saRTrim(p_sa: AnsiString):AnsiString;
//=============================================================================
Begin
  While (length(p_sa)>0) and (copy(p_sa,length(p_sa),1)=' ') Do delete(p_sa,length(p_sa),1);
  result:=p_sa;
End;
//=============================================================================

//=============================================================================
// for formatting - use freepascal's str directly with
// str(number:digits:decimals, stringresult);
Function saStr(p_i8:Int64):AnsiString;
//=============================================================================
Var sa: AnsiString;
Begin
  str(p_i8, sa);
  Result:=sa;
End;
//=============================================================================

//==========================================================================
Function saGetStringBeforeEqualSign(p_sa: AnsiString): AnsiString;
//==========================================================================
Var
  sa: AnsiString;
  ix: LongInt;
  l: LongInt;
Begin
  l := Length(p_sa);
  sa := '';
  If l > 0 Then
  Begin
    ix := pos('=',p_sa);
    //riteln('jegas-saGetStringBeforeEqual:',p_sa);
    //riteln('ix:',ix);
    If ix > 0 Then
    Begin
      If ix <= l Then
      Begin
        sa:= saLeftStr(p_sa, ix - 1);
      End;
    End;
  End;
  Result:=sa;
End;
//==========================================================================

//==========================================================================
Function saGetStringAfterEqualSign(p_sa: AnsiString): AnsiString;
//==========================================================================
Var
  sa: AnsiString;
  ix: LongInt;
  l: LongInt;
Begin
  l := Length(p_sa);
  sa := '';
  If l > 0 Then
  Begin
    ix := pos('=',p_sa);
    If ix > 0 Then
    Begin
      If ix < l Then
      Begin
        sa := saRightStr(p_sa, l - ix);
      End;
    End;
  End;
  Result:=sa;
End;
//==========================================================================

//=============================================================================
Function saRightStr(p_sa: AnsiString; p_i: Integer): AnsiString;
//=============================================================================
Begin
  Result:=copy(p_sa,length(p_sa)-p_i+1,p_i)
End;
//=============================================================================

//=============================================================================
Function saLeftStr(p_sa: AnsiString; p_i: Integer): AnsiString;
//=============================================================================
Begin
  Result:=copy(p_sa,1,p_i)
End;
//=============================================================================


//=============================================================================
// Convert string to integer
Function iVal(p_sa:AnsiString):Longint;
//=============================================================================
Var iBadChar: Integer;
    iResult: integer;
Begin
  iBadChar:=0;iBadChar:=iBadChar;
  val(p_sa, iResult,iBadChar);
  result:=iResult;
End;
//=============================================================================


//=============================================================================
// NOT THREAD SAFE - FPC Filemode global can be in unpredictable state.
// This Version of fileexists returns true IF the file can be opened with
// assign and reset. (Matters on unix/linux. If readonly - can't seem
// to do blockread (even readonly mode). So this is a way to check.
Function bFileExists(p_saFileName: AnsiString):Boolean;
//=============================================================================
Var F:File;
Begin
  {$I-}
  assign(f,p_saFileName);
  reset(f);
  {$I+}
  Result:=(ioresult=0) and (p_saFileName<>'');
  close(f);
End;
//=============================================================================




//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  gi4FileIO_BufferSize := 65536;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
