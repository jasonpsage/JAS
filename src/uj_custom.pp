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
Unit uj_custom;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_custom.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
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
Uses
//=============================================================================
classes
,syncobjs
,ug_jegas
,uj_context
;
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
// This function is called AFTER the internals of the bJAS_CreateSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_CreateSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_CreateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):boolean;
//=============================================================================
{} 
// This function is called AFTER the internals of the bJAS_ValidateSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_ValidateSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_ValidateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean): boolean;
//=============================================================================
{} 
// This function is called AFTER the internals of the bJAS_RemoveSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_RemoveSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
Function bJAS_RemoveSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):Boolean;
//=============================================================================
{} 
// This function is called DURING the bJAS_PurgeConnections call EACH TIME
// a Session (jsession table record) is slated to be removed.
// This hook is then called with TCONTEXT and the UID of the jsession
// record about to get destroyed.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_PurgeConnection_Custom_Hook(p_Context: TCONTEXT; p_JSess_JSession_UID: ansistring):boolean;
//=============================================================================




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
{} 
// This function is called AFTER the internals of the bJAS_CreateSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_CreateSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_CreateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJAS_CreateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102269,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102270, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=true;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102271,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
{} 
// This function is called AFTER the internals of the bJAS_ValidateSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_ValidateSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_ValidateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean): boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}var  sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJAS_ValidateSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102271,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102272, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=true;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102273,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
{} 
// This function is called AFTER the internals of the bJAS_RemoveSession
// function are completed. This hook is then called with TCONTEXT and the 
// result of the bJAS_RemoveSession that is about to be returned to the caller.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
Function bJAS_RemoveSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):Boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME:='bJAS_RemoveSession_Custom_Hook(p_Context: TCONTEXT; p_Result: boolean):Boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102274,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102275, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=true;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102276,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
{} 
// This function is called DURING the bJAS_PurgeConnections call EACH TIME
// a Session (jsession table record) is slated to be removed.
// This hook is then called with TCONTEXT and the UID of the jsession
// record about to get destroyed.
// Coding to this hook allows putting custom code into the JAS API directly
// without creating circular references which would occur if we tried to put this
// sort of code into the regular user_customization source files.
function bJAS_PurgeConnection_Custom_Hook(
  p_Context: TCONTEXT;
  p_JSess_JSession_UID: ansistring
):boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_PurgeConnection_Custom_Hook(p_Context: TCONTEXT;p_JSess_JSession_UID: ansistring):boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102277,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102278, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=true;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102279,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
