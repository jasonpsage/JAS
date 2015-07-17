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
// JAS Specific Functions
Unit uj_sessions;
//=============================================================================




//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_sessions.pp'}
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
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jcrypt
,ug_jado
,uj_locking
,uj_user
,uj_tables_loadsave
,uj_context
,uj_definitions
,uj_custom
,uj_permissions
;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations
//*****************************************************************************
//=============================================================================
//*****************************************************************************

const cnMaxLoginAttempts=10;//before blacklisted

//==============================================================================
{}
// JASAPI function
// This function uses the following information from p_Context to decide if
// creating a session for a particular user will be attempted:@br@br
// Required: p_Context.CGIENV.DataIn.FoundItem_saName('USERNAME',False)@br
// Required: p_Context.CGIENV.DataIn.FoundItem_saName('PASSWORD',False)@br
// Required: p_Context.CGIENV.ENVVAR.FoundItem_saName('REMOTE_ADDR',False)@br
// Optional: p_Context.CGIENV.DataIn.FoundItem_saName('CHANGEPASSWORD',False)@br
// Optional: p_Context.CGIENV.DataIn.FoundItem_saName('NEWPASSWORD1',False)@br
// Optional: p_Context.CGIENV.DataIn.FoundItem_saName('NEWPASSWORD2',False)@br@br
//
// Additionally, the user's AllowedSessions field in the juser table is taken
// into account. If the user's AllowedSessions field is set to 1, then if
// an existing session will be removed and the user is granted a new session.@br@br
//
// IF a user is allowed numerous sessions, then a new session will be created
// unless they have exceeded their allowed number of logins. If they do exceed
// there AllowedSessions, then they will not be granted anymore.@br@br
//
// We'd like to add a user interface so this scenario can be resolved by the
// user themselves but this is on our todo list. Systems such as VICI do not
// generally allow users multiple logins, and for telemarketing scenarios
// where VICI is used, it is easier to tie VICI logins to JAS users by
// limiting their AllowedSessions to one.@br@br
//
// Above you might have noticed the IP address bit that this function analyzes.
// Basically if a request comes in from an IP address other than that of the
// session's originator - then access to the system is denied.@br@br
//
// If the function returns true you are good to go. If you like, for instance
// an error is returned, you can interrogate what happened by getting the
// result code from: p_Context.rSession.i4ResultCode
//
// Upon successful session creation, a cookie with the SESSION ID
// (jdconnection.JDCon_JDConnection_UID) is stored on the client named JSID.
// Note that form variables override COOKIE. So, it's actually cleaner to not
// send JSID yourself in forms posts etc unless you have a good reason. If you do
// not follow this advice, have a web page up and your session times out, you
// can not login in another page and then refresh the page you were at because
// you essentially hardcoded the session id into the webpage.
//
// Values are defined in uxxj_definitions.pp Example: cnSession_PasswordsDoNotMatch
function bJAS_CreateSession(p_Context: TCONTEXT):boolean;
//==============================================================================
{}
// Validate session does what it's name implies but it also removes old sessions
// from the database; in effect as the system is used, it takes care of itself.
// Validate Session gather the Session ID from either the request itself or from
// the cookie verifies the Session ID (jdconnection.JDCon_JDConnection_UID)
// exists.
//
// If the remote ip address doesn't match the session creator's, then access
// is denied. If the session has gone beyond it's configured timeout period
// its removed BY this function before this function attempts to look it up
// so timeout periods are enforced.
function bJAS_ValidateSession(p_Context: TCONTEXT): boolean;
//==============================================================================
{}
// Removes current user's session - essentially logging them out.
Function bJAS_RemoveSession(p_Context: TCONTEXT):Boolean;
//==============================================================================
{}
// This is just a random number generator
function saJAS_GetSessionKey: ansistring;
//==============================================================================
{}
// This loads the jseckey table with BOTH public and private keys - 512 bytes saved
// as contiguas hex pairs per key. (1024 char/1K each key). One Row has two keys.
function bJAS_GenerateSecKeys(p_Context: TCONTEXT): boolean;
//==============================================================================
{}
// This function is what does the old session clean up, called internally by
// bJAS_ValidateSession.
function bJAS_PurgeConnections(p_Context: TCONTEXT; p_iMinutesOld: integer):boolean;
//==============================================================================
{}
// this function purges orphaned session data.
// Currently session data is database driven. Making a likely faster filebased
// session data mechanism is slated for developement.
function bJAS_PurgeOrphanedSessionData(p_Context: TCONTEXT): boolean;
//==============================================================================
{}
// this function saves session data
// Currently session data is database driven. Making a likely faster filebased
// session data mechanism is slated for developement.
function bJAS_LoadSessionData(p_Context: TCONTEXT): boolean;
//==============================================================================
{}
// this function saves session data
// Currently session data is database driven. Making a likely faster filebased
// session data mechanism is slated for developement.
function bJAS_SaveSessionData(p_Context: TCONTEXT): boolean;
//==============================================================================
{}
// This function allows "peeking" to see if a passed session id (JSession
// UID) is valid and returns the user name owning the session.
function bJAS_ValidateSessionPeek(p_Context: TCONTEXT; p_JSess_JSession_UID: ansistring; var p_JUser_Name_ReturnedHere: ansistring): boolean;
//==============================================================================
{}
// this function takes the encrypted data and the UID passed as saSecKey
// and loads the record from the jseckey table and uses the public key to
// call uxxg_jcrypt.saJegasEncryptSingleKey to decrypt the passed data.
function saJAS_DecryptSingleKey(p_Context: TCONTEXT; p_saData: ansistring; p_saSecKey: ansistring): ansistring;
//==============================================================================




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
function saJAS_GetSessionKey: ansistring;
//=============================================================================
var
  saResult: ansistring;
begin
  saResult:=inttostr(random(B30));
  //JAS_LOG(cnLog_EBUG,200907211715,'saGetSessionKey Result:'+saResult,SOURCEFILE);
  result:=saResult;
end;
//=============================================================================

//=============================================================================
function bJAS_GenerateSecKeys(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  RS: JADO_RECORDSET;
  saQry: ansistring;
  rJSecKey: rtJSecKey;
  NVP: rtNameValuePair;
  sTHIS_ROUTINE_NAME: String;
Begin
  sTHIS_ROUTINE_NAME:='bJAS_GenerateSecKeys';
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102478,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102479, sTHIS_ROUTINE_NAME);{$ENDIF}


  bOk:=true;
  rs:=JADO_RECORDSET.CREATE;
  DBC:=p_Context.VHDBC;

  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201009021600, 'Unable to comply - session is not valid.',sTHIS_ROUTINE_NAME,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnJSecPerm_Admin) or bJAS_HasPermission(p_Context,cnJSecPerm_MasterAdmin);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201009021601, 'Unable to comply - Admin Permission not granted.',sTHIS_ROUTINE_NAME,SOURCEFILE);
    end;
  end;

  //if bOk then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,'JAS','jseckey','0','0',201501011000);
  //  if bOk then bGotLock:=true;
  //  if not bOk then
  //  begin
  //    JAS_Log(p_Context, cnLog_Error,201009021806, 'bJAS_GenerateSecKeys - Unable to lock jseckey table.','',SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    saQry:='select * from jseckey where JSKey_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
    bOk:=rs.open(saQry, DBC,201503161150);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201009021807, 'Trouble with query.',sTHIS_ROUTINE_NAME+' Query: '+saQRy,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    if rs.eol then
    begin
      repeat
        clear_JSecKey(rJSecKey);
        bOk:=bJAS_Save_JSecKey(p_Context,DBC, rJSecKey,false,false);
      until (bOk=false) or (u8Val(rJSecKey.JSKey_JSecKey_UID)=1024);
    end;
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select JSKey_JSecKEy_UID from jseckey where JSKey_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
    bOk:=rs.open(saQry, DBC,201503161151);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201009021808, 'Trouble with query.',sTHIS_ROUTINE_NAME+' Query: '+saQRy,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.eol = false;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201009021810, 'Zero Records returned when there should be records.',sTHIS_ROUTINE_NAME+' Query: '+saQRy,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    repeat
      clear_JSecKey(rJSecKey);
      rJSecKey.JSKey_JSecKey_UID:=rs.fields.Get_saValue('JSKey_JSecKey_UID');
      bOk:=bJAS_Load_JSecKey(p_Context, DBC, rJSecKey,false);
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201009021811, 'Trouble loading record with bJAS_Load_JSecKey.',sTHIS_ROUTINE_NAME,SOURCEFILE);
      end;

      if bOk then
      begin
        JegasCrypt(NVP);
        rJSecKey.JSKey_KeyPub:=NVP.saName;
        rJSecKey.JSKey_KeyPvt:=NVP.saValue;
        bOk:=bJAS_Save_JSecKey(p_Context,DBC, rJSecKey,false,false);
      end;
    until (bOk=false) or (not rs.movenext);
  end;

  result:=bOk;
  if bOk then
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102480,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_PurgeConnections(p_Context: TCONTEXT; p_iMinutesOld: integer):boolean;
//=============================================================================
var
  bOk: boolean;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_PurgeConnections(p_Context: TCONTEXT; p_iMinutesOld: integer):boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(2012032481,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102482, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.create;
  rs2:=JADO_RECORDSET.create;

  bOk:=bJAS_LockRecord(p_Context,DBC.ID,'jsession','0','0',201501011001);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_WARN,201005011843,'bJAS_PurgeConnections - Unable to lock jsession table','',SOURCEFILE);
  end;

  if bOk then
  begin
    Case DBC.u2DBMSID Of
    cnDBMS_MSAccess: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'WHERE datediff(''n'', JSess_LastContact_DT, now) > '+saStr(p_iMinutesOld);
    End;
    cnDBMS_MySQL: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'where JSess_LastContact_DT  < date_sub(now(), interval '+saSTR(p_iMinutesOld)+' minute)';
    End;
    cnDBMS_MSSQL: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'WHERE datediff(n, JSess_LastContact_DT, {fn now()}) > '+saStr(p_iMinutesOld);

    End;
    else begin
      saQry:='UNSUPPORTED DBMS';
    end;
    end;//case
    bOk:=rs.Open(saQry,DBC,201503161152);
    if not bOk then
    begin
      JAS_Log(
        p_Context,
        cnLog_ERROR,
        200912291106,
        'bPurgeConnections - Error Executing Query.',
        'saQry: '+saQry,
        SOURCEFILE, DBC, rs
      );
    end;
  end;

  if bOk and (rs.EOL=false) then
  begin
    repeat
      //function bJAS_PurgeConnection_Custom_Hook(p_Context: TCONTEXT; p_JSess_JSession_UID: ansistring):boolean;
      if not bJAS_PurgeConnection_Custom_Hook(p_Context, rs.fields.Get_saValue('JSess_JSession_UID')) then
      begin
        JAS_Log(
          p_Context,
          cnLog_ERROR,
          201005011843,
          'bPurgeConnections - bJAS_PurgeConnection_Custom_Hook returned false',
          'JSession.JSess_JSession_UID: '+rs.fields.Get_saValue('JSess_JSession_UID'),
          SOURCEFILE
        );
      end;
      saQry:='delete from jsession where JSess_JSession_UID='+rs.fields.Get_saValue('JSess_JSession_UID');
      bOk:=rs2.Open(saQry,DBC,201503161153);
      if not bOk then
      begin
        JAS_Log(
          p_Context,
          cnLog_ERROR,
          201005011844,
          'bPurgeConnections - Error Executing Query.',
          'saQry: '+saQry,
          SOURCEFILE, DBC, rs2
        );
      end;
      rs2.close;
    until (not bok) or (not rs.movenext);
  end;
  rs.Close;
  bJAS_UnLockRecord(p_Context,DBC.ID,'jsession','0','0',201501011002);
  rs.Destroy;
  rs2.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102483,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_PurgeOrphanedSessionData(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  rs1: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_PurgeOrphanedSessionData(p_Context: TCONTEXT): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102484,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102485, sTHIS_ROUTINE_NAME);{$ENDIF}

  rs1:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  DBC:=p_Context.VHDBC;

  bOk:=true;

  if bOk then
  begin
    //saQry:='select JSDat_JSessionData_UID '+
    //  'from jsessiondata left join jsession on '+
    //  'JSDat_JSession_ID=JSess_JSession_UID '+
    //  'where (JSess_JSession_UID is null)';

    saQry:='SELECT JSDat_JSessionData_UID '+
      'FROM jsessiondata LEFT JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID '+
      'where jsession.JSess_JSession_UID is null';

    bOk:=rs1.Open(saQry,DBC,201503161154);
    if not bOk then
    begin
      JAS_Log(
        p_Context,
        cnLog_ERROR,
        201004102130,
        'Error Executing Query.',
        'saQry: '+saQry,
        SOURCEFILE, DBC, rs1
      );
    end;
  end;

  if bOk and (rs1.eol=false) then
  begin
    repeat
      saQry:='delete from jsessiondata where JSDat_JSessionData_UID='+DBC.saDBMSUIntScrub(rs1.Fields.Get_saValue('JSDat_JSessionData_UID'));
      bOk:=rs2.Open(saQry,DBC,201503161155);
      if not bOk then
      begin
        JAS_Log(
          p_Context,
          cnLog_ERROR,
          201004102131,
          'Error Executing Query.',
          'saQry: '+saQry,
          SOURCEFILE, DBC, rs2
        );
      end;
      rs2.close;
    until (not rs1.MoveNext) or (bOk=false);
  end;
  rs1.close;
  rs1.destroy;
  rs2.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102486,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
// Returns TEXT version of new UID in JSession Table (aka session table)
function bJAS_CreateSession(p_Context: TCONTEXT):boolean;
//=============================================================================
Var
  bOk:Boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;//defined in uxxg_jado.pp
  rs2: JADO_RECORDSET;//defined in uxxg_jado.pp
  saQry: AnsiString;

  bJUser_Enabled_b: boolean;
  JUser_AllowedSessions_u: cardinal;
  saNewPassword1: ansistring;
  saNewPassword2: ansistring;
  JUser_Login_First_DT: ansistring;
  JUser_Logins_Successful_u: cardinal;
  bEncryptedDataIn: boolean;
  saSecKeyIn: ansistring;
  saQrySelect: ansistring;
  //rJUser: rtJUser;
  //f: text;
  //DT: TDateTIme;
  sTHIS_ROUTINE_NAME: String;
  saUserID: ansistring;// used during change password
  rJIPList: rtJIPList;
Begin
sTHIS_ROUTINE_NAME:='bJAS_CreateSession(p_Context: TCONTEXT):boolean;';
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102487,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102488, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  //DT:=now;

  p_Context.rJSession.JSess_JSession_UID:='0';
  p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;//ZERO B^)
  p_Context.bLoginAttempt:=True;

  If p_Context.CGIENV.DataIn.FoundItem_saName('USERNAME',False) Then
  Begin
    p_Context.rJUser.JUser_Name:=p_Context.CGIENV.DataIn.Item_saValue;
  End;
  p_Context.rJUser.JUser_Password:='';
  If p_Context.CGIENV.DataIn.FoundItem_saName('PASSWORD',False) Then
  Begin
    p_Context.rJUser.JUser_Password:=p_Context.CGIENV.DataIn.Item_saValue;
  End;

  //p_Context.rJSession.JSess_IP_ADDR:='';
  If p_Context.CGIENV.ENVVAR.FoundItem_saName('REMOTE_ADDR',False) Then
  Begin
    p_Context.rJSession.JSess_IP_ADDR:=p_Context.CGIENV.ENVVAR.Item_saValue;
  End;

  bEncryptedDataIn := p_Context.CGIENV.DATAIN.FoundItem_saName('loginkey');
  if bEncryptedDataIn then
  begin
    saSecKeyIn:=p_Context.CGIENV.DATAIN.Item_saValue;
    if length(p_Context.rJUser.JUser_Password)>0 then
    begin
      p_Context.rJUser.JUser_Password:=
        saJAS_DecryptSingleKey(p_Context, p_Context.rJUser.JUser_Password, saSecKeyIn);
    end;
  end;

  saQrySelect:=
    'select '+
    ' JUser_JUser_UID '+
    ', JUser_Enabled_b'+
    ', JUser_AllowedSessions_u'+
    ', JUser_Login_First_DT'+
    ', JUser_Logins_Successful_u'+
    ', JUser_DefaultPage_Login'+
    ', JUser_DefaultPage_Logout '+
    ' from juser where JUser_Deleted_b<>'+DBC.saDBMSBoolScrub(true) +' and ';

  if p_Context.bInternalJob then
  begin
    saqry:=saQrySelect + 'JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name);
  end
  else
  begin
    If p_Context.rJUser.JUser_Password='' Then
    Begin
      saqry:=saQrySelect +
        'JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name)+' and '+
        '((JUser_Password='''') or (JUser_Password is null))';
    End
    Else
    Begin
      saqry:=saQrySelect +
        'JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name)+' and '+
        'JUser_Password='+DBC.saDBMSScrub(
          saXorString(p_Context.rJUser.JUser_Password, grJASConfig.u1PasswordKey));
    End;
  end;
  //AS_LOG(p_Context,cnLog_Debug,201210171304,'bJAS_CreateSession Credential Query: '+saQry,'',SOURCEFILE);
  rs.Open(saQry, DBC,201503161156);
  bOk:=(rs.EOL=False);
  If bOk Then
  Begin
    // Credentials Are Good
    p_Context.rJUser.JUser_JUser_UID:=u8Val(rs.Fields.Get_saValue('JUser_JUser_UID'));
    p_Context.rJUser.JUser_DefaultPage_Login:=rs.Fields.Get_saValue('JUser_DefaultPage_Login');
    p_Context.rJUser.JUser_DefaultPage_Logout:=rs.Fields.Get_saValue('JUser_DefaultPage_Logout');
    if p_Context.rJUser.JUser_DefaultPage_Login='NULL' then p_Context.rJUser.JUser_DefaultPage_Login:='';
    if p_Context.rJUser.JUser_DefaultPage_Logout='NULL' then p_Context.rJUser.JUser_DefaultPage_Logout:='';
    bJUser_Enabled_b:=bVal(rs.Fields.Get_saValue('JUser_Enabled_b'));
    JUser_AllowedSessions_u:= u4Val(rs.Fields.Get_saValue('JUser_AllowedSessions_u'));
    JUser_Login_First_DT:=rs.Fields.Get_saValue('JUser_Login_First_DT');
    JUser_Logins_Successful_u:=u4Val(rs.Fields.Get_saValue('JUser_Logins_Successful_u'));
 
    //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '100 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);

  End
  Else
  Begin
    p_Context.iSessionResultCode:=cnSession_InvalidCredentials;
  End;
  rs.Close;

  if bOk then
  begin
    bOk:=bJUser_Enabled_b;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_WARN,200912261125,
        'bJAS_CreateSession - Invalid Login (User not Enabled)',
        'UID: '+ inttostR(p_Context.rJUser.JUser_JUser_UID) +
        ' U:'+p_Context.rJUser.JUser_Name +
        ' JUser_Enabled_b: '+rs.Fields.Get_saValue('JUser_Enabled_b'),SOURCEFILE);
      p_Context.iSessionResultCode:=cnSession_UserNotEnabled;
    end;
  end;

  if not p_Context.bInternalJob then
  begin
    if bOk then
    begin
      saQry:='select count(*) as MyCount from jsession where '+
        'JSess_JUser_ID='+inttostr(p_Context.rJUser.JUser_JUser_UID);
      bOk:=rs.Open(saQry, DBC,201503161157);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_ERROR,200609252037,
          'bJAS_CreateSession - Error Executing Query',
          ' UID: '+ inttostr(p_Context.rJUser.JUser_JUser_UID) +
          ' U:'+p_Context.rJUser.JUser_Name+
          ' Query: '+saQry,SOURCEFILE, DBC, rs);
      end;
      if bOk then
      begin
        if iVal(rs.Fields.Get_saValue('MyCount'))>=JUser_AllowedSessions_u then
        begin
          if(JUser_AllowedSessions_u=1) then
          begin
            // If you log in while already logged in, and you are only allowed to have one session,
            // then your previous login session is rendered old; so are locks owned by previous login.
            // This scenario or set up SHOULD coincide with VICI dialer needs where the user can only
            // be logged in once anyway.
            // TODO: For situations where multi-sessions are allowed; a mechanism for folks to select
            // and maybe resume previous sessions and/or remove them from the login screen (with valid
            // credentials should maybe be written. Currently now they are simply out of luck until
            // one or more of their sessions are removed
            rs.Close;
            saQry:='select JSess_JSession_UID from jsession '+
              'where JSess_JUser_ID='+inttostR(p_Context.rJUser.JUser_JUser_UID);

            bOk:=rs.Open(saQry, DBC,201503161158);
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201203010925,sTHIS_ROUTINE_NAME+' - Trouble executing query.','Query: '+saQry,SOURCEFILE,DBC,rs);
              p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;
            end;

            if bOk then
            begin
              if not rs.EOL then
              begin
                repeat
                  saQry:='delete from jlock where JLock_JSession_ID='+rs.Fields.Get_saValue('JSess_JSession_UID');
                  bOk:=rs2.Open(saQry, DBC,201503161159);
                  if not bOk then
                  begin
                    JAS_LOG(p_Context, cnLog_Error, 201203010926,sTHIS_ROUTINE_NAME+' - Trouble executing query.','Query: '+saQry,SOURCEFILE,DBC,rs);
                    p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;
                  end;
                  rs2.Close;

                  if bOk then
                  begin
                    saQry:='delete from jsession where JSess_JUser_ID='+inttostR(p_Context.rJUser.JUser_JUser_UID);
                    bOk:=rs2.Open(saQry, DBC,201503161160);
                    if not bOk then
                    begin
                      JAS_LOG(p_Context, cnLog_Error, 201203010927,sTHIS_ROUTINE_NAME+' - Trouble executing query.','Query: '+saQry,SOURCEFILE,DBC,rs);
                      p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;
                    end;
                    rs2.Close;
                  end;
                until (not bOk) or (not rs.MoveNext);
                rs.Close;
                rs.Open(saQry, DBC,201503161161);
              end;
            end;
          end
          else
          begin
            bOk := false;
            JAS_Log(p_Context,cnLog_WARN,200912261135,sTHIS_ROUTINE_NAME+' - User Allowed Sessions Exceeded','UID: '+
              inttostr(p_Context.rJUser.JUser_JUser_UID) +' U:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
            p_Context.iSessionResultCode:=cnSession_NumAllowedSessionExceeded;
          end;
        end;
      end;
      rs.Close;
    end;
  end;

  //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '200 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);

  If bOk Then
  Begin
    p_Context.rJSession.JSess_JSession_UID:=saJAS_GetNextUID;//(p_Context,JAS.ID,'jsession');
    bOk:=p_Context.rJSession.JSess_JSession_UID<>'';
    If not bOk Then
    Begin
      JAS_Log(p_Context, cnLog_ERROR,200912260049,
        sTHIS_ROUTINE_NAME+' - Unable to Get New jsession UID from saGetNextUID Function.','',SOURCEFILE);
    End;
  End;

  If bOk Then
  Begin
    // Now we add the record to the jsession table with all the info we gathered.
    saQry:='INSERT INTO jsession ('+
      'JSess_JSession_UID, '+
      'JSess_JSessionType_ID, '+
      'JSess_JUser_ID, ' +
      'JSess_Connect_DT, '+
      'JSess_LastContact_DT, '+
      'JSess_IP_ADDR, '+
      'JSess_Username ';
    if p_Context.bInternalJob then
    begin
      saQry+=', JSess_JJobQ_ID';
    end;
    saQry+=') VALUES ( '+
      p_Context.rJSession.JSess_JSession_UID + ','+
      '1,'+
      inttostr(p_Context.rJUser.JUser_JUser_UID);
    Case DBC.u2DBMSID Of
    cnDBMS_MSSQL: Begin
      saQry+=',{fn now()},{fn now()},';
    end;
    cnDBMS_MSAccess,cnDBMS_MySQL: Begin
      saQry+=',now(),now(),';
    end;
    end;//endswitch
    saQry+=''''+p_Context.rJSession.JSess_IP_ADDR+''','+
           ''''+p_Context.rJUser.JUser_Name+'''';
    if p_Context.bInternalJob then
    begin
      saQry+=','+p_Context.CGIENV.DataIn.Get_saValue('JJobQ_JJobQ_UID');
    end;
    saQry+=')';

    Case DBC.u2DBMSID Of
    cnDBMS_MSSQL, cnDBMS_MSAccess,cnDBMS_MySQL:;
    else saQry:='UNSUPPORTED DBMS';
    end;//endswitch
    bOk:=rs.Open(saQry,DBC,201503161162);
    If not bOk Then
    Begin
      // Unable to Create Session record for some reason.
      JAS_Log(p_Context,cnLog_WARN,201001262106,'bJAS_CreateSession - Problem - Unable to create a session record. Query:'+saQry,'',SOURCEFILE);
    End
    Else
    Begin
      //JAS_Log(p_Context,cnLog_ebug,201203311301,'bJAS_CreateSession - SUCCESS MAKING SESSION: '+p_Context.rJSession.JSess_JSession_UID,'',SOURCEFILE);

      p_Context.iSessionResultCode:=cnSession_Success;
      p_Context.bSessionValid:=true;
      p_Context.CGIENV.AddCookie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,grJASConfig.iSessionTimeOutInMinutes),false);
      // DEBUGGING cookies thing
      //for i:=1 to 20 do p_Context.CGIENV.AddCookie('JSID'+inttostr(i),p_Context.saSession,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,grJASConfig.iSessionTimeOutInMinutes),false);
      p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,inttostR(p_Context.rJUser.JUser_JUser_UID));
      bOk:=bJAS_LockRecord(p_Context, DBC.ID,'juser',inttostr(p_context.rJuser.JUser_JUser_UID),'0',201501011003);
      if not bOK then
      begin
        JAS_Log(p_Context,cnLog_WARN,201001262109,
          sTHIS_ROUTINE_NAME+' - Unable to lock record to update user stats.','',SOURCEFILE);
      end;

      if bOk then
      begin
        saQry:='update juser set JUser_JUser_UID='+DBC.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' ';
        if length(trim(JUser_Login_First_DT))=0 then
        begin
          saQry+=', JUser_Login_First_DT='+DBC.saDBMSDateScrub(saFormatDateTime(csDATETIMEFORMAT,now));
        end;
        saQry+=
          ', JUser_Login_Last_DT='+DBC.saDBMSDateScrub(saFormatDateTime(csDATETIMEFORMAT,now))+
          ', JUser_Logins_Successful_u='+DBC.saDBMSUIntScrub(JUser_Logins_Successful_u+1)+' '+
          ', JUser_Logins_Failed_u='+DBC.saDBMSUIntScrub(0)+' '+
          'where JUser_JUser_UID='+DBC.saDBMSUIntScrub(p_Context.rJuser.JUser_JUser_UID);
        rs.Close;
        bOk:=rs.Open(saQry,DBC,201503161163);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_WARN,201001262108,'bJAS_CreateSession - Unable to update user stats. saQry:'+saQry,'',SOURCEFILE);
        end;
      end;
      rs.Close;

      if bOk then
      begin
        bOk:=bJAS_UnLockRecord(p_Context, DBC.ID,'juser',inttostr(p_context.rJuser.JUser_JUser_UID),'0',201501011004);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_WARN,201203011119,
            sTHIS_ROUTINE_NAME+' - Unable to unlock record after updating user stats.','',SOURCEFILE);
        end;
      end;
    End;
    rs.Close;
  End;

  //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '300 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);

  //if bOk then
  if p_Context.iSessionResultCode=cnSession_Success then
  begin
    saNewPassword1:='';saNewPassword2:='';
    If uppercase(p_Context.CGIENV.DataIn.Get_saValue('CHANGEPASSWORD'))='ON' Then
    Begin
      p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;// Error didn't occur - but resetting success Status
      saNewPassword1:=p_Context.CGIENV.DataIn.Get_saValue('NEWPASSWORD1');
      saNewPassword2:=p_Context.CGIENV.DataIn.Get_saValue('NEWPASSWORD2');
      if bEncryptedDataIn then
      begin
        //ASPRINTLN('201203311849-----------------------BEFORE-------------');
        if length(saNewPassword1)>0 then saNewPassword1:=saJAS_DecryptSingleKey(p_Context, saNewPassword1, saSecKeyIn);
        if length(saNewPassword2)>0 then saNewPassword2:=saJAS_DecryptSingleKey(p_Context, saNewPassword2, saSecKeyIn);
        //ASPRINTLN('201203311849-----------------------AFTER--------------');
      end;
      If saNewPAssword1<>saNewPassword2 Then
      Begin
        p_Context.iSessionResultCode:=cnSession_PasswordsDoNotMatch;
        bJAS_RemoveSession(p_Context);
        bOk:=false;
      End
      Else
      Begin
        If saNewPassword1=p_Context.rJUser.JUser_Password Then
        Begin
          p_Context.iSessionResultCode:=cnSession_PasswordsIdenticalNoChange;
          bJAS_RemoveSession(p_Context);
          bOk:=false;
        End
        Else
        Begin
          //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '400 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
          saUserID:=inttostr(p_Context.rJUser.JUser_JUser_UID);
          if not bJAS_RemoveSession(p_Context) then
          begin
            JAS_LOG(p_Context, cnLog_Warn,201203010918,'bJAS_CreateSession unable to remove session during password change. '+
              'Session UID: '+p_Context.rJSession.JSess_JSession_UID,'',SOURCEFILE);
          end;
          
          //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '500 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
          saQry:='UPDATE juser SET JUser_Password='''+saxorstring(trim(saNewPassword1),grJASConfig.u1passwordkey)+''', JUser_Password_Changed_DT='+
                 DBC.saDBMSDateScrub(saFormatDateTime(csDATETIMEFORMAT,now))+' where JUser_JUser_UID='+saUserID;
          //JAS_LOG(p_Context, cnLog_ebug,201203311844,'bJAS_CreateSession - Query for password change: '+saQry,'',SOURCEFILE);

          If rs.Open(saQry, DBC,201503161164) Then
          Begin
            p_Context.iSessionResultCode:=cnSession_PasswordChangeSuccess;
            bOk:=false;
          End
          else
          begin
            JAS_LOG(p_Context, cnLog_Error,201203311843,'bJAS_CreateSession - Query Trouble during password change: '+saQry,'',SOURCEFILE);
          end;
          rs.Close;
        End;
      End;
    End;
  End;

  if not p_Context.iSessionResultCode=cnSession_Success then
  begin
    p_Context.CGIENV.AddCookie('JSID',DBC.ID,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,-1) ,False);
  end;

  // Record and Eventually block cnSession_InvalidCredentials or cnSession_UserNotEnabled
  if (( p_Context.iSessionResultCode = cnSession_InvalidCredentials) or
     ( p_Context.iSessionResultCode = cnSession_UserNotEnabled)) and
     (p_Context.rJSession.JSess_IP_ADDR<>'0.0.0.0') then
  begin
    saQry:='UPDATE juser SET JUser_Logins_Failed_u = JUser_Logins_Failed_u+1 where JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name);
    bOk:=rs.Open(saQry,DBC,201503161165);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Warn, 201211061105,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
    rs.close;


    if bOk then
    begin
      saQry:=
        'select '+
        '  JIPL_JIPList_UID, '+
        '  JIPL_InvalidLogins_u '+
        'from jiplist '+
        'where '+
        '  (JIPL_IPAddress='+DBC.saDBMSScrub(p_Context.rJSession.JSess_IP_ADDR)+') AND '+
        '  (JIPL_IPListType_u='+DBC.saDBMSUIntScrub(cnJIPListLU_InvalidLogin)+') and '+
        '  ((JIPL_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JIPL_Deleted_b IS NULL))';
      bOk:=rs.Open(saQry,DBC,201503161166);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_WARN,201001262248,
          sTHIS_ROUTINE_NAME+' - Unable to open query preparing to record invalid login.',
          'IP:'+p_Context.rJSession.JSess_IP_ADDR+' Query: '+saQry,SOURCEFILE,DBC,rs);
      end;
    end;

    if bOk then
    begin
      clear_JIPList(rJIPList);
      with rJIPList do begin
        if rs.eol then
        begin
          JIPL_JIPList_UID            :='0';
        end
        else
        begin
          rJIPList.JIPL_JipList_UID:=rs.fields.Get_saValue('JIPL_JipList_UID');
        end;
        JIPL_IPListType_u           :=inttostr(cnJIPListLU_InvalidLogin);
        JIPL_IPAddress              :=p_Context.rJSession.JSess_IP_ADDR;
        if rs.eol then
        begin
          JIPL_InvalidLogins_u        :='1';
        end
        else
        begin
          JIPL_InvalidLogins_u:=inttostr(u1Val(rs.fields.Get_saValue('JIPL_InvalidLogins_u'))+1);
        end;
      end;//with
      bOk:=bJAS_Save_JIPList(p_Context, DBC, rJIPList,false,false);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_WARN,201203010957,sTHIS_ROUTINE_NAME+' - Unable to save NEW JIPList Record for unknown.',
          'IP:'+p_Context.rJSession.JSess_IP_ADDR,SOURCEFILE);
      end;

      if bOk and (u1Val(rJIPList.JIPL_InvalidLogins_u)>cnMaxLoginAttempts) and grJASConfig.bBlackListEnabled then
      begin
        p_Context.iSessionResultCode:=cnSession_LockedOut;
        setlength(garJIPListLight,length(garJIPListLight)+1);
        with garJIPListLight[length(garJIPListLight)-1] do begin
          u8JIPList_UID            :=0;
          u1IPListType             :=cnJIPListLU_BlackList;
          saIPAddress              :=p_Context.rJSession.JSess_IP_ADDR;
        end;//with
      end;
    end;
    rs.close;
  end;


  // BEGIN ------------------------------------------------- MAINTENANCE STUFF
  if bOk then
  begin
    bOk:=bJAS_PurgeConnections(p_Context,grJASConfig.iSessionTimeOutInMinutes);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_ERROR,200912291109,sTHIS_ROUTINE_NAME+' - trying to clean old Sessions past timeout interval.',
        'Call to bPurgeConnections_MinutesoldAndOlder failed.',SOURCEFILE);
    End;

    if bOk then
    begin
      bOk:=bJAS_PurgeOrphanedSessionData(p_Context);
      If not bOk Then
      Begin
        JAS_Log(p_Context,cnLog_ERROR,201004102154,sTHIS_ROUTINE_NAME+' - trying to clean orphaned session data.',
        'Call to bJAS_PurgeOrphanedSessionData failed.',SOURCEFILE);
      End;
    end;
  end;




  // ------------------------------------
  // Blast ANY OLD LOCKS
  // ------------------------------------
  bOk:=bJAS_PurgeLocks(p_Context, grJASConfig.iLockTimeOutInMinutes);
  if not bOk then
  begin
    JAS_Log(
      p_Context,
      cnLog_ERROR,
      200912251559,
      sTHIS_ROUTINE_NAME+' - Error locking record.',
      'bJAS_PurgeLocks returned error',
      SOURCEFILE
    );
  end;


  // ------------------------------------
  // Locks without corresponding Session ID's (p_JLock_JSession_ID)
  // ------------------------------------
  If bOk Then
  Begin
    Case DBC.u2DBMSID Of
    cnDBMS_MSAccess,cnDBMS_MSSQL:
    Begin
      saQry:='SELECT JLock_JSession_ID FROM jlock LEFT JOIN jsession ON jlock.JLock_JSession_ID = jsession.JSess_JSession_UID '+
        'WHERE (JSess_JSession_UID is null) and (JLock_JSession_ID<>0)';
    End;
    cnDBMS_MySQL:
    Begin
      saQry:='SELECT JLock_JSession_ID from jlock inner join jsession on JLock_JSession_ID=JSess_JSession_UID ' +
        'WHERE (JSess_JSession_UID is null) and (JLock_JSession_ID<>0)';
    End;
    Else Begin
      bOk:=false;
      JAS_Log(p_Context,cnLog_ERROR,200912251600,sTHIS_ROUTINE_NAME+' - Unsupported*DBMS','',SOURCEFILE);
    end;
    End; //switch
  end;

  if bOk then
  begin
    // NOTE: The ZERO connection ID's are there WHILE creating sessions, so can't blast those. Worst case they time out.
    bOk:=rs2.Open(saQry, DBC,201503161168);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_ERROR,200912251657,
        sTHIS_ROUTINE_NAME+' - Error trying to find orphaned record locks whose session is no longer valid.',
        'Query: '+saQry,SOURCEFILE,rs2);
    End;
  End;

  If bOk Then
  Begin
    If not rs2.EOL Then
    Begin
      repeat
        If rs2.Fields.FoundItem_saName('JLock_JSession_ID',False) Then
        Begin
          saQry:='DELETE FROM jlock where JLock_JSession_ID='+rs2.Fields.Item_saValue;
          bOk:=rs.Open(saQry, DBC,201503161169);
          If not bOk Then
          Begin
            JAS_Log(p_Context,cnLog_ERROR,200912251702,
              sTHIS_ROUTINE_NAME+' - Error trying to delete orphaned record locks whose session (JLock_JSession_ID) is no longer valid.',
              'saQry: '+saQry,SOURCEFILE,rs);
          End;
          rs.Close;
        End;
      Until (not bOk) OR (not rs2.MoveNext);
    End;
  End;
  rs2.Close;
  // END   ------------------------------------------------- MAINTENANCE STUFF


  rs.Destroy;rs:=nil;
  rs2.destroy;rs2:=nil;
  Result:=(p_Context.iSessionResultCode=cnSession_Success);
  //riteln('CreateSession:',bSuccess);

  if not bJAS_CreateSession_Custom_Hook(p_Context, result) then
  begin
    JAS_Log(p_Context, cnLog_WARN,201005011834,'bJAS_CreateSession - call to bJAS_CreateSession_Custom_Hook returned false.','',SOURCEFILE);
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102489,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================




//=============================================================================
// The purpose of this function is faceted. Removed DATED Sessions,
// Validate that the REMOTE_ADDR of the user has not changed.
// If the parameters passed return a record, and the rest of the function
// doesn't run into errors then the other fields in this structure will
// be populated with data from the database.
//
// Note: The JSess_LastContact_DT gets updated in the database by this
//       function. So you could liken this call to UNIX "touch" command
//       where the modified date of a file is set to "now"
//
//  JSess_JSession_UID: ansistring;  Parameter In
//  JSess_JSessionType_ID: ansistring;         out
//  JSess_JUser_ID: ansistring;          out
//  JSess_Connect_DT: ansistring;        out
//  JSess_LastContact_DT: ansistring;    out
//  JSess_IP_ADDR: ansistring;           Parameter In
//  JSess_Username: ansistring;          Parameter In
//  JSess_SessionKey: ansistring;        Parameter In
//
//
//  rJSession.JSess_JSession_UID:=p_Context.JUser_JUser_UID;
//  rJSession.JSess_IP_ADDR:=p_Context.saRemoteIP;
//  rJSession.JSess_Username:=p_Context.JUser_Name;
//  rJSession.JSess_SessionKey:=p_Context.saKeyIn;
function bJAS_ValidateSession(p_Context: TCONTEXT):boolean;
//=============================================================================
Var
  rs: JADO_RECORDSET;
  bOk: Boolean;
  saQry: AnsiString;
  DBC: JADO_CONNECTION;
  sTHIS_ROUTINE_NAME: String;
  sSQLDateFn: string;
Begin
  sTHIS_ROUTINE_NAME:='bJAS_ValidateSession';
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102489,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102490, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  //JAS_Log(p_Context,cnLog_ebug,201203311349,'bJAS_ValidateSession - Request: '+p_Context.saOriginallyRequestedFile+' QueryString: '+p_Context.saQueryString,'',SOURCEFILE);
  //ASPrintln('bValidateSession On Entry p_Context.saLang: '+p_context.saLang);

  // Get Cookie Session info if out there
  if bOk then
  begin
    If p_Context.CGIENV.CkyIn.FoundItem_saName('JSID',False) Then
    Begin
      p_Context.rJSession.JSess_JSession_UID:=p_Context.CGIENV.CkyIn.Item_saValue;
    end;

    // Allow passed (post or get) Session Information to Win over Cookie...
    If p_Context.CGIENV.DataIn.FoundItem_saName('JSID',False) Then
    Begin
      p_Context.rJSession.JSess_JSession_UID:=p_Context.CGIENV.DataIn.Item_saValue;
    end;
    bOk:=u8Val(p_Context.rJSession.JSess_JSession_UID)>0;
  end;

  If bOk Then
  Begin
    saQry:='SELECT JSess_JUser_ID from jsession where JSess_JSession_UID='+DBC.saDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID);
    bOk:=rs.Open(saQry, DBC,201503161170);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,200912291146,sTHIS_ROUTINE_NAME+' unable to query for session JSID: '+
        p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=not rs.eol;
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_WARN,201204142351,sTHIS_ROUTINE_NAME+' Bad JSID arrived - Session wasn''t '+
      //  'valid any longer or never was. JSID: '+p_Context.rJSession.JSess_JSession_UID,
      //  'DBC.saName: '+DBC.saName+' '+csCRLF+
      //  'VHost ServerDomain: '+garJVHostLight[p_Context.i4VHost].saServerDomain+' '+csCRLF+
      //  'Internal Job: '+saTrueFalse((p_Context.bInternalJob))+' '+csCRLF+
      //  'saOriginallyRequestedFile: '+p_Context.saOriginallyRequestedFile+' '+csCRLF+
      //  'saRequestedHost: '+p_Context.saRequestedHost+' '+csCRLF+
      //  'saQueryString: '+p_COntext.saQueryString+' '+csCRLF+
      //  'Query: '+saQry+' '+csCRLF+
      //  'In: '+ p_Context.saIn
      //  , SOURCEFILE
      //);
    end;
  end;


  if bOk then
  begin
    with p_Context.rJSession do begin
    //JSess_JSession_UID
    //JSess_JSessionType_ID
    JSess_JUser_ID:=rs.fields.Get_saValue('JSess_JUser_ID');
    //JSess_Connect_DT
    //JSess_LastContact_DT
    //JSess_IP_ADDR
    //JSess_PORT_u
    //JSess_Username
    //JSess_JJobQ_ID
    end;//with
    p_Context.rJUser.JUser_JUser_UID:=u8val(p_Context.rJSession.JSess_JUser_ID);
    bOk:=bJAS_Load_JUser(p_Context,DBC,p_Context.rJUser, false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,201002101616, sTHIS_ROUTINE_NAME+' unable to load user info from Session Info: '+inttostr(p_Context.rJUser.JUser_JUser_UID),sTHIS_ROUTINE_NAME,SOURCEFILE);
    end;
  end;
  //JAS_Log(p_Context,cnLog_ebug,201203311343,'bJAS_ValidateSession - VALID: '+saYesNo(bOk)+' AFTER bJAS_Load_JUser','',SOURCEFILE);
  rs.close;

  if bOk then
  begin
    Case DBC.u2DBMSID Of
    cnDBMS_MSAccess: sSQLDateFn:='now()';
    cnDBMS_MySQL: sSQLDateFn:='now()';
    cnDBMS_MSSQL: sSQLDateFn:='{fn now()}'
    Else sSQLDateFn:='now()';
    End; //switch

    saQry:='UPDATE jsession SET JSess_LastContact_DT='+sSQLDateFn+' '+
           'WHERE JSess_JSession_UID='+p_Context.rJSession.JSess_JSession_UID;
    bOk:=rs.Open(saQry,DBC,201503161171);
    if not bOk then
    begin
      //JASLog(p_Context,cnLog_EBUG,201001271924,'bJAS_ValidateSession - LOST saQry:'+saQry,'',SOURCEFILE);
    end;
    rs.Close;
  end;
  //JAS_Log(p_Context,cnLog_ebug,201203311344,'bJAS_ValidateSession - VALID: '+saYesNo(bOk)+' AFTER UPDATE jsession QUERY ','',SOURCEFILE);

  If bOk Then
  Begin
    //JAS_Log(p_Context,cnLog_ebug,201203311304,'bJAS_ValidateSession - Valid Session: '+p_Context.rJSession.JSess_JSession_UID,'',SOURCEFILE);
    p_Context.bSessionValid:=true;
    p_Context.CGIENV.AddCookie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIWithoutparam,dtAddMinutes(now,grJASConfig.iSessionTimeOutInMinutes) ,False);
    bOk:=bJAS_LoadSessionData(p_Context);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,201004102336,'Unable to Load Session Data',sTHIS_ROUTINE_NAME+' Session ID:'+p_Context.rJSession.JSess_JSession_UID,SOURCEFILE);
    end;
    //ASPrintln('bJAS_ValidateSession - p_Context.rJUser.JUser_JLanguage_ID: '+inttostr(p_Context.rJUser.JUser_JLanguage_ID));
    p_Context.saLang:=p_Context.saJLanguageLookup(p_Context.rJUser.JUser_JLanguage_ID);
  End
  Else
  Begin
    //ASPrintln('bJAS_ValidateSession - FAILED - Not Logged In');
    clear_juser(p_Context.rJUser);
    p_Context.rJUser.JUser_Name:='Anonymous';
    with p_Context.rJSession do begin
      JSess_JSession_UID:='0';
      //JSess_JSessionType_ID
      JSess_JUser_ID:='0';
      //JSess_Connect_DT
      //JSess_LastContact_DT
      //JSess_IP_ADDR
      //JSess_PORT_u
      JSess_Username:=p_Context.rJUser.JUser_Name;
      //JSess_JJobQ_ID
    end;//with
  End;
  
  //ASPrintln('bJAS_ValidateSession - saLangCode: '+p_Context.saLang);


  
  //JAS_Log(p_Context,cnLog_ebug,201203311345,'bJAS_ValidateSession - VALID: '+saYesNo(bOk)+' AFTER Add Cookie AND bJAS_LoadSessionData','',SOURCEFILE);


  p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,inttostr(p_Context.rJUser.JUser_JUser_UID));
  rs.close;
  rs.Destroy;
  result:=bOk;

  if not bJAS_ValidateSession_Custom_Hook(p_Context, result) then
  begin
    JAS_Log(p_Context, cnLog_ERROR,201005011835,'bJAS_ValidateSession - call to bJAS_ValidateSession_Custom_Hook returned false.','',SOURCEFILE);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102491,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================




//=============================================================================
Function bJAS_RemoveSession(p_Context: TCONTEXT):Boolean;
//=============================================================================
Var
  bOk:Boolean;
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_RemoveSession(p_Context: TCONTEXT):Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102492,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102493, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=nil;saQry:='';
  bOk:=u8Val(p_Context.rJSession.JSess_JSession_UID)>0;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_WARN,200609271005,'RemoveSession - called with invalid JSess_JSession_UID in p_Context.','',sourcefile);
  End;

  If bOk Then
  Begin
    bOk:=bJAS_LockRecord(p_Context,DBC.ID,'jsession', p_Context.rJSession.JSess_JSession_UID,'0',201501011005);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200609271007,'RemoveSession - tried to lock the jsession table '+
        'to remove a session.','Could not for session p_Context.JSess_JSession_UID='+p_Context.rJSession.JSess_JSession_UID,sourcefile);
    End;
  End;

  if bOk then
  begin
    if not bJAS_RemoveSession_Custom_Hook(p_Context, bOk) then
    begin
      JAS_Log(p_Context,cnLog_WARN,201005011836,'bJAS_RemoveSession - call to bJAS_RemoveSession_Custom_Hook returned false.','',SOURCEFILE);
    end;
  end;

  If bOk Then
  Begin
    rs:=JADO_RECORDSET.create;
    saQry:='DELETE FROM jsession where JSess_JSession_UID='+p_Context.rJSession.JSess_JSession_UID;
    bOk:=rs.Open(saQry, DBC,201503161172);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200609271012,'RemoveSession - Unable to delete record for passed session id',
        'p_Context.JSess_JSession_UID:'+p_Context.rJSession.JSess_JSession_UID+' Query:'+saQry,sourcefile,DBC,rs);
    End;
    rs.Close;
  End;

  // REMOVE ANY/ALL Locks In Use By The Session.
  If bOk Then
  Begin
    rs:=JADO_RECORDSET.create;
    saQry:='DELETE FROM jlock where JLock_JSession_ID='+p_Context.rJSession.JSess_JSession_UID;
    bOk:=rs.Open(saQry, DBC,201503161173);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200610031946,'RemoveSession - Unable to remove record locks associated with this session.',
        'p_Context.JSess_JSession_UID:'+p_Context.rJSession.JSess_JSession_UID+' Query: '+ saQry,sourcefile,DBC,rs);
    End;
    rs.Close;
  End;

  // NOTE: No other cleanup (at least for record locks) is necessary because EACH record lock
  // call blasts locks without matching sessions UNLESS session ID value in JSession table is ZERO.

  If rs<>nil Then rs.Destroy;

  p_Context.bSessionValid:=false;
  p_Context.rJSession.JSess_JSession_UID:='0';
  p_Context.rJUser.JUser_JUser_UID:=0;
  p_Context.rJUser.JUser_Name:='Anonymous';
  p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,'0');
  p_Context.CGIENV.AddCookie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIWithoutparam,dtAddMinutes(now,-1) ,False);

  Result:=bOk;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102494,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





//=============================================================================
// this function saves session data
// Currently session data is database driven. Making a likely faster filebased
// session data mechanism is slated for developement.
function bJAS_LoadSessionData(p_Context: TCONTEXT): boolean;
//==============================================================================
var
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  bOk: boolean;
  rs1: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_LoadSessionData(p_Context: TCONTEXT): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102496,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102497, sTHIS_ROUTINE_NAME);{$ENDIF}


  //AS_Log(p_Context,cnLog_Debug,201209031724,'bJAS_LoadSessionData - CALLED ----','',sourcefile);

  DBC:=p_Context.VHDBC;
  rs1:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_ERROR,201004102216,'bJAS_LoadSessionData - Session Not Valid - This function should not of been called.','',sourcefile);
  end;

  if bOk then
  begin
    if (p_Context.SessionXDL.ListCount=0) then
    begin
      saQry:='SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value '+
      'FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID '+
      'WHERE jsessiondata.JSDat_JSession_ID='+p_Context.rJSession.JSess_JSession_UID;
      bOk:=rs1.Open(saQry, DBC,201503161174);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_ERROR,201004102218,'bJAS_LoadSessionData','Query: '+saQry,sourcefile,DBC,rs1);
      end;
    
      if bOk and (rs1.eol=false) then
      begin
        repeat
          p_Context.SessionXDL.AppendItem;
          p_Context.SessionXDL.Item_i8User:=i8Val(rs1.fields.Get_saValue('JSDat_JSessionData_UID'));
          p_Context.SessionXDL.Item_saName:=rs1.fields.Get_saValue('JSDat_Name');
          p_Context.SessionXDL.Item_saValue:=rs1.fields.Get_saValue('JSDat_Value');
        until not rs1.movenext;
      end;
      rs1.close;
    end;
  end;

  rs1.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102498,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================




//=============================================================================
function bJAS_SaveSessionData(p_Context: TCONTEXT): boolean;
//==============================================================================
var
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  bOk: boolean;
  rs: JADO_RECORDSET;
  DT: TDateTime;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_SaveSessionData(p_Context: TCONTEXT): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102499,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102500, sTHIS_ROUTINE_NAME);{$ENDIF}

  DT:=now;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_ERROR,201004102217,'bJAS_SaveSessionData - Session Not Valid - This function should not of been called.','',sourcefile);
  end;

  if bOk then
  begin
    saQry:=
      'delete from jsessiondata where '+
      'JSDat_JSession_ID='+p_Context.rJSession.JSess_JSession_UID;
    bOk:=rs.Open(saQry, DBC,201503161175);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,201004102242,'bJAS_SaveSessionData - Trouble with Query.','Query: '+saQry,sourcefile,DBC,rs);
    end;
    rs.close;
  end;

  if bOk then
  begin
    if p_Context.SessionXDL.MoveFirst then
    begin
      repeat
        saQry:='insert into jsessiondata set '+
          'JSDat_JSession_ID='+DBC.saDBMSIntScrub(p_Context.rJSession.JSess_JSession_UID)+','+
          'JSDat_Name='+DBC.saDBMSScrub(p_Context.SessionXDL.Item_saName)+','+
          'JSDat_Value='+DBC.saDBMSScrub(p_Context.SessionXDL.Item_saValue)+','+
          'JSDat_CreatedBy_JUser_ID='+DBC.saDBMSIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
          'JSDat_Created_DT='+DBC.saDBMSDateScrub(DT);
        bOk:=rs.open(saQry, DBC,201503161176);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201202261313,
            'Unable to Save Session Data Record','',SOURCEFILE, DBC, RS);
        end;
        rs.close;
      until (not bOk) or (not p_Context.SessionXDL.MoveNext);
    end;
  end;
  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102501,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================




//=============================================================================
function bJAS_ValidateSessionPeek(
  p_Context: TCONTEXT;
  p_JSess_JSession_UID: ansistring;
  var p_JUser_Name_ReturnedHere: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  RS: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_ValidateSessionPeek(p_Context: TCONTEXT; p_JSess_JSession_UID: ansistring; var p_JUser_Name_ReturnedHere: ansistring): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102502,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102503, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  p_JUser_Name_ReturnedHere:='';
  saQry:= 'select JSess_Username '+
    'FROM jsession '+
    'where JSess_JSession_UID=' + DBC.saDBMSScrub(p_JSess_JSession_UID);
  bOk:=rs.Open(saQry,DBC,201503161177);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_ERROR,201005031323,'bJAS_ValidateSessionPeek - Trouble with database query.','Query: '+saQry,sourcefile);
  end;

  if bOk then
  begin
    bOk:=(rs.eol=false);
    // make function return false - but don't generate an error persay
  end;

  if bOk then
  begin
    p_JUser_Name_ReturnedHere:=rs.fields.Get_saValue('JSess_Username');
  end;
  rs.close;
  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102504,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



//=============================================================================
function saJAS_DecryptSingleKey(p_Context: TCONTEXT; p_saData: ansistring; p_saSecKey: ansistring): ansistring;
//=============================================================================
var
  bOk: boolean;
  //saQry: ansistring;
  DBC: JADO_CONNECTION;
  //RS: JADO_RECORDSET;
  rJSecKey: rtJSecKey;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saJAS_DecryptSingleKey(p_Context: TCONTEXT; p_saData: ansistring; p_saSecKey: ansistring): ansistring;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102505,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102506, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:='';
  DBC:=p_Context.VHDBC;
  clear_jseckey(rJSecKey);
  rJSecKey.JSKey_JSecKey_UID:=p_saSecKey;
  bOK:=bJAS_Load_JSecKey(p_Context, DBC, rJSecKey, false);
  if not bOk then
  begin
    jas_log(p_Context,cnLog_ERROR,201009051219,'saJAS_DecryptSingleKey - Trouble with loading jseckey.','rJSecKey.JSKey_JSecKey_UID: '+rJSecKey.JSKey_JSecKey_UID,sourcefile);
  end;
  if bOk then
  begin
    result:=saJegasDecryptSingleKey(p_saData, rJSecKey.JSKey_KeyPub);
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102507,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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

//=============================================================================
// History (Please Insert Historic Entries at top)
//=============================================================================
// Date        Who             Notes
//=============================================================================
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
