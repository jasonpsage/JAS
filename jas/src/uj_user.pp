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
{}
// JAS Specific Functions
Unit uj_user;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_user.pp'}
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
,dos
,process
,ug_common
,ug_jegas
,ug_jado
,uj_context
,ug_jfc_dir
,sysutils
,uj_definitions
,uj_fileserv
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
// Takes information from CGIENV and ascertains if the "session" is 
// valid/logged in.
// 
// In either case it returns the cache Directory for a given user. 
// If the folder doesn't exist, it is created.
Function saJASGetUserCacheDir(p_Context: TCONTEXT; p_JUser_JUser_UID: uint64):AnsiString;
//=============================================================================
{}
// User Preferences function. Basically this code returns the user preference 
// based on the specified user id. If the preference cannot be associated 
// directly with the user, than the preference is sought from the default 
// preferences instead, if the preference can not be found either way,
// a blank is returned. It is up to the caller to decide how to deal with
// a returned empty value.
Function saJASUserPref(p_Context: TCONTEXT; Var p_bOk: Boolean;
                    p_u8PrefID, p_u8UserID: UInt64): AnsiString;
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
Function saJASGetUserCacheDir(p_Context: TCONTEXT; p_JUser_JUser_UID: uint64):AnsiString;
//=============================================================================
Var saRelPath: AnsiString;
    saFilename: AnsiString;
    saFilePath: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saJASGetUserCacheDir(p_saJUser_JUser_UID: Ansistring):AnsiString;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102645,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102646, sTHIS_ROUTINE_NAME);{ENDIF}

  safileName:=sZeroPadInt(p_JUser_JUser_UID,19)+'.txt';
  saFilePath:=garJVHost[p_Context.u2VHost].VHost_CacheDir+'jas-menu'+DOSSLASH;
  if not FileExists(saFilePAth) then CreateDir(saFilePath);
  If not fileexistsintree(safileName,safileName,saFilePath, saRelPath,4,4) Then
  Begin
    //function bStoreFileInTree(
    //  p_saSourceDirectory: Ansistring; // Containing file to store
    //  p_saSourceFileName: AnsiString; // Filename to copy and store (unless p_sadata is used)
    //  p_saDestTreeTop: ansistring; // Top of STORAGE TREE
    //  p_saData: ansistring; // If this variable is not empty - then it is used in place
    //  // of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
    //  // saved as the p_saDestFilename in the calculated tree's relative path.
    //  var p_saRelPath: ansistring // This gets the saRelPath when its created.
    //):boolean;
    bStoreFileInTree(
          saFileName,
          '',  // Containing file to store
          saFileName,// Filename to copy and store (unless p_sadata is used)
          saFilePath,// Top of STORAGE TREE
          'This file was used to create the cache entry. You can delete it.',
          // If this variable is not empty - then it is used in place
          // of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
          // saved as the p_saDestFilename in the calculated tree's relative path.
          saRelPath,// This gets the saRelPath when its created.
          4,4
    );
  End;
  Result:=saFilePath + DOSSlash+saRelpath;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102647,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
End;
//=============================================================================


//=============================================================================
// User Preferences function. Basically this code returns the user preference 
// based on the specified user id. If the preference cannot be associated 
// directly with the user, than the preference is sought from the default 
// preferences instead, if the preference can not be found either way,
// a blank is returned. It is up to the caller to decide how to deal with
// a returned empty value.
Function saJASUserPref(p_Context: TCONTEXT; Var p_bOk: Boolean;
                    p_u8PrefID, p_u8UserID: UInt64): AnsiString;
//=============================================================================
Var 
  saQry: AnsiString;
  rs: JADO_RECORDSET;
  bDone: Boolean;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='saJASUserPref';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102648,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102649, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  Result:='';
  rs:= JADO_RECORDSET.Create;
  bDone:=False;
  p_bOk:=p_Context.bSessionValid;
  //If not p_bOk Then 
  //Begin
    // In this case, we fall through and just return empty ansistring
  //End;

  If p_bOk Then
  Begin
    saQry:='SELECT UsrPL_Value FROM juserpreflink WHERE '+
      'UsrPL_UserPref_ID='+inttostr(p_u8PrefID)+' AND '+
      'UsrPL_User_ID='+inttostr(p_u8UserID);//+' AND '+
      //'UsrPL_Deleted_b<>'+JAS.saDBMSBoolScrub(true);
    p_bOk:=rs.Open(saQry, DBC,201503161140);
    If not p_bOk Then
    Begin
      JAS_Log(p_Context,cnLog_Error,200601252238,'Problem Seeking User Preference:'+
        inttostr(p_u8PrefID)+' for user:'+ inttostr(p_u8UserID),'Query: '+saQry,SOURCEFILE,DBC,rs);
      //RenderHtmlErrorPage(p_Context);
    End;
  End;
  
  If p_bOk Then
  Begin
    If not rs.EOL Then
    Begin
      bDone:=True;
      Result:=rs.Fields.Get_saValue('UsrPL_Value');
    End;
    rs.Close;
  End;  
  

  If p_bOk and (not bDone) Then
  Begin
    // OK, we could not find User preference for user, see if default
    // value exists.
    saQry:='SELECT UsrPL_Value FROM juserpreflink '+
      'WHERE UsrPL_UserPref_ID='+DBC.sDBMSUIntScrub(p_u8PrefID)+' AND '+
      '(UsrPL_User_ID=0 or UsrPL_User_ID is null)';
      //'((UsrPL_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(UsrPL_Deleted_b IS NULL))';
    p_bOk:=rs.Open(saQry, DBC,201503161141);
    If not p_bOk Then
    Begin
      JAS_Log(p_Context,cnLog_Error,200601252242,'Problem Seeking DEFAULT User Preference:'+
        inttostr(p_u8PrefID),'Query: '+saQry,SOURCEFILE);
      //RenderHtmlErrorPage(p_Context);
    End;
  End; 
  
  If p_bOk and (not bDone) Then
  Begin
    If not rs.EOL Then
    Begin
      bDone:=True;
      Result:=rs.Fields.Get_saValue('UsrPL_Value');
      //AS_Log(p_COntext,cnLog_DEBUG,200701252306,
      //  ' GOT IT:'+result +' saUserPref Function:'+saStr(p_iprefid)+' for user:'+
      //  saStr(p_iuserid),' Query: '+saQry,SOURCEFILE,JAS,JADOR);
    End;
    rs.Close;
  End;  
  rs.Destroy;
  //AS_Log(p_Context,cnLog_DEBUG,200701252306,
  //  ' saUserPref Function:'+saStr(p_iprefid)+' for user:'+
  //  saStr(p_iuserid),' Query: '+saQry,SOURCEFILE);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102650,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
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
