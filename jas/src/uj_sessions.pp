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

{DEFINE DEBUGMESSAGES}
{$IFDEF DEBUGMESSAGES}
  {$INFO | DEBUGMESSAGES: TRUE}
{$ENDIF}


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
// Upon successful session creation, JSID (session id) is persisted without
// cook ies or html5 storage (which is neat). Its done through standard GETs
// and POSTS using form data or the url itself.
//
// Values are defined in uxxj_definitions.pp Example: cnSession_PasswordsDoNotMatch
function bJAS_CreateSession(p_Context: TCONTEXT):boolean;
//==============================================================================
{}
// Validate session does what it's name implies but it also removes old sessions
// from the database; in effect as the system is used, it takes care of itself.
// Validate Session gather the Session ID from the request to verify the
// Session ID (jdconnection.JDCon_JDConnection_UID)
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
//function saJAS_GetSessionKey: ansistring;  inline;
function u8JAS_GetSessionKey: uint64; inline;
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
function bJAS_ValidateSessionPeek(p_Context: TCONTEXT; p_JSess_JSession_UID: uint64; var p_JUser_Name_ReturnedHere: ansistring): boolean;
//==============================================================================
{}
// this function takes the encrypted data and the UID passed as saSecKey
// and loads the record from the jseckey table and uses the public key to
// call uxxg_jcrypt.saJegasEncryptSingleKey to decrypt the passed data.
function saJAS_DecryptSingleKey(p_Context: TCONTEXT; p_saData: ansistring; p_u8SecKey: uint64): ansistring;
//=============================================================================
{}
// returns true if the passed ip (pattern, left string style) if found in
// garJIPListLight array of rtJIPLISTLight - see ug_definitions.pp
//
// the p_uOffset is passed by value, so use the UINT macro fot the endian correct
// datatype (to use full bus and numeric range). This value after the call to this
// function, providing the function returns true, is the offset into the
// garJIPListLight array. (zero based array) ...1 based  i call those index.
function bFoundIPInJipListLight(p_sIP: string; var p_uOffset: Uint):boolean;
//=============================================================================
{}
// Quick way to take immediate charge of the JIPLIST for banning, unbanning etc.
// This effect both the database and memory. No Cycling.
// B = Ban
// P = Promote or Whitelist
// F = Forget or Remove from jiplist
// D = Downloader (Note: Download IP List Type also means it could be a bot being monitored "Robots Text" Counting also
// R = RobotTxt Downloaded. This works in conjunction with the SmacKBadBots Function of PBG
// M = Guest JMail
function JIPListControl(p_Con: JADO_CONNECTION; p_sAction: string; p_sIP: string; p_sReason: string; p_u8UserID: UInt64):boolean;
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
{}
// Using this takes into account the configuration setting grJASConfig.bSafeDelete
// which decides if records get flagged as deleted or just deleted outright
function bDeleteRecord2(
  p_Con: JADO_Connection;
  p_sTable: string;
  p_sColumnPrefix: string;
  p_saWhereClause: ansistring;
  p_u8UserID: UInt64
): boolean;
//=============================================================================
var
  bOK: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  //saUID: ansistring;
  //u8len: Uint64;
  //u: UInt;
  //u8RowCount: UInt64;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bDeleteRecord2:boolean;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  if grJASConfig.bSafeDelete then
  begin
    saQry:='update '+p_Con.sDBMSEncloseObjectName(p_sTable)+ ' SET '+
      p_sColumnPrefix+'_Deleted_dt='+p_Con.sDBMSDateScrub(now)+', '+
      p_sColumnPrefix+'_Deleted_b='+p_Con.sDBMSBoolScrub(true)+', '+
      p_sColumnPrefix+'_DeletedBy_JUser_ID='+p_Con.sDBMSUIntScrub(p_u8UserID) +' '+
      'WHERE  ( ' + p_saWhereClause + ' ) and (('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+'='+
      p_Con.sDBMSBoolScrub(false)+') or ('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+' IS NULL))';
  end
  else
  begin
    saQry:='delete from '+p_Con.sDBMSEncloseObjectName(p_sTable)+
     'WHERE  ( ' + p_saWhereClause + ' ) and (('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+'='+
      p_Con.sDBMSBoolScrub(false)+') or ('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+' IS NULL))';
  end;

  //JLog(cnLog_Debug,201602281034,'bDeleteRecord2 Query: '+ saQry,SOURCEFILE);



  rs:=JADO_RECORDSET.Create;
  bOk:=rs.open(saQry,p_Con,201602272215);
  if not bOk then
  begin
    JLog(cnLog_Error,201602272216,'Trouble Deleting. Query: '+ saQry,SOURCEFILE);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================





























////=============================================================================
{}
// Quick way to take immediate charge of the JIPLIST for banning, unbanning etc.
// This effect both the database and memory. No Cycling.
// B = Ban
// P = Promote or Whitelist
// F = Forget or Remove from jiplist (same as DBM_JIPList in dbtools but circular reference)
//                                   named SES_JipList to kinda follow the convention SES = session unit dbm= dbtools
//function SES_JipList(p_Con: JADO_CONNECTION; p_saAction: ansistring; p_sIP: string; p_sReason: string; p_u8userID: UInt64):boolean;
//=============================================================================
//var
//  bOK: boolean;
//  saQry: ansistring;
//  rs: JADO_RECORDSET;
//  u8UID: uint64;
//  //u8len: Uint64;
//  u: UInt;
//  u8RecordCount: UInt64;
//  sIPListType: string[1];
//{IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{ENDIF}
//Begin
//{IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JIPPunk(stuff):boolean;';{ENDIF}
//{IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{ENDIF}
//{IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
//{ENDIF}
////const cnJIPListLU_WhiteList = 1;
////const cnJIPListLU_BlackList = 2;
////const cnJIPListLU_InvalidLogin = 3;
//  bOk:=true;
//  rs:=JADO_RECORDSET.Create;
//  // if there already, mark as deleted
//
//  if p_saAction='F' {FORGET} then
//  begin
//    bOk:=bDeleteRecord2(p_Con,'jiplist','JIPL','JIPL_IPADDRESS like '+p_Con.saDBMSScrub(p_sIP+'%'),p_u8userID);
//    if not bok then
//    begin
//      riteln('201512031831: Unable to update record. Unable to remove IP from jiplist table.');
//    end;
//    for u:=0 to length(garJIPListLight)-1 do
//    begin
//      if leftStr(garJIPListLight[u].sIPAddress,length(p_sIP))=p_sIP then
//      begin
//        garJIPListLight[u].sIPAddress:='CONSOLE WIPED';
//      end;
//    end;
//  end else
//
//  begin
//    if p_saAction='B' then sIPListType:=inttostr(cnJIPListLU_BlackList)else sIPListType:=inttostr(cnJIPListLU_WhiteList);
//    u8RecordCount:=p_Con.u8GetRecordCount('jiplist','((JIPL_Deleted_b=false)or(JIPL_Deleted_b is null)) and '+
//      '(JIPL_IPAddress='+p_Con.saDBMSScrub(p_sIP)+')AND(JIPL_IPListType_u='+sIPListType+')',201512031730);
//    if u8RecordCount=0 then
//    begin
//      u8UID:=u8GetUID;//sGetUID;
//      for u:=0 to length(garJIPListLight)-1 do
//      begin
//        with garJIPListLight[u] do begin
//          if (sIPAddress='') or (sIPAddress='CONSOLE WIPED') then
//          begin
//            u8JIPList_UID:=u8UID;
//            sIPAddress:=p_sIP;
//            u1IPListType:=cnJIPListLU_BlackList;
//            break;
//          end;
//        end;//with
//      end;
//      saQry:=
//        'INSERT INTO jiplist SET '+
//        ' JIPL_JIPList_UID='         + inttostr(u8UID)+
//        ',JIPL_IPListType_u='        + sIPListType+
//        ',JIPL_IPAddress= '          + p_Con.saDBMSScrub(p_sIP)+
//        ',JIPL_InvalidLogins_u= '    + '0'+
//        ',JIPL_Reason='              + p_Con.saDBMSScrub('JIPPUNK:'+p_sReason)+
//        ',JIPL_CreatedBy_JUser_ID= ' + '1'+
//        ',JIPL_Created_DT= '         + p_Con.sDBMSDateScrub(now)+
//        ',JIPL_ModifiedBy_JUser_ID= '+ 'NULL'+
//        ',JIPL_Modified_DT= '        + 'NULL'+
//        ',JIPL_DeletedBy_JUser_ID= ' + 'NULL'+
//        ',JIPL_Deleted_DT= '         + 'NULL'+
//        ',JIPL_Deleted_b= '          + 'NULL'+
//        ',JAS_Row_b= '               + 'false';
//      bOk:=rs.open(saQry, p_Con,201512031841);
//      if not bOk then
//      begin
//        riteln('201512031842: Unable to insert new record into jiplist table.');
//      end;
//    end;
//    rs.close;
//  end;
//  rs.destroy;
//  //Log(cnLog_Info,201602280331,'JIPLIST - '+p_saAction+' Success:'+sYesNo(bOk)+'  '+p_sIP+' '+inttostr(p_u8UserID)+' Reason: '+ p_sReason,SOURCEFILE);
//  JASPrintln('Punk-Be-Gone Sessions: '+p_saAction+' '+p_sIP+' '+p_sReason);
//  result:=bOk;
//
//{IFDEF DEBUGLOGBEGINEND}
//  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
//{ENDIF}
//end;
////=============================================================================






















////=============================================================================
//function saJAS_GetSessionKey: ansistring;
////=============================================================================
//var
//  saResult: ansistring;
//begin
//  saResult:=inttostr(random(B30));
//  //JAS_LOG(cnLog_EBUG,200907211715,'saGetSessionKey Result:'+saResult,SOURCEFILE);
//  result:=saResult;
//end;
////=============================================================================

//=============================================================================
function u8JAS_GetSessionKey: uint64;
//=============================================================================
begin
  result:=random(B30);
  //JAS_LOG(cnLog_EBUG,201608092122,'saGetSessionKey Result:'+inttostr(Result),SOURCEFILE);
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
    bOk:=bJAS_HasPermission(p_Context,cnPerm_Admin) or bJAS_HasPermission(p_Context,cnPerm_Master_Admin);
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
    saQry:='select * from jseckey where (JSKey_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') or (JSKey_Deleted_b is NULL)';
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
        bOk:=bJAS_Save_JSecKey(p_Context,DBC, rJSecKey,false,false,201608310004);
      until (bOk=false) or (rJSecKey.JSKey_JSecKey_UID=1024);
    end;
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select JSKey_JSecKEy_UID from jseckey where (JSKey_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') or (JSKey_Deleted_b IS NULL)';
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
      rJSecKey.JSKey_JSecKey_UID:=u8Val(rs.fields.Get_saValue('JSKey_JSecKey_UID'));
      bOk:=bJAS_Load_JSecKey(p_Context, DBC, rJSecKey,false,201608310005);
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201009021811, 'Trouble loading record with bJAS_Load_JSecKey.',sTHIS_ROUTINE_NAME,SOURCEFILE);
      end;

      if bOk then
      begin
        JegasCrypt(NVP);
        rJSecKey.JSKey_KeyPub:=NVP.saName;
        rJSecKey.JSKey_KeyPvt:=NVP.saValue;
        bOk:=bJAS_Save_JSecKey(p_Context,DBC, rJSecKey,false,false,201608310006);
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

  bOk:=bJAS_LockRecord(p_Context,DBC.ID,'jsession',0,0,201501011001);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_WARN,201005011843,'bJAS_PurgeConnections - Unable to lock jsession table','',SOURCEFILE);
  end;

  if bOk then
  begin
    Case DBC.u8DBMSID Of
    cnDBMS_MSAccess: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'WHERE datediff(''n'', JSess_LastContact_DT, now) > '+inttostr(p_iMinutesOld);
    End;
    cnDBMS_MySQL: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'where JSess_LastContact_DT  < date_sub(now(), interval '+inttostr(p_iMinutesOld)+' minute)';
    End;
    cnDBMS_MSSQL: Begin
      saQry:='SELECT JSess_JSession_UID FROM jsession '+
        'WHERE datediff(n, JSess_LastContact_DT, {fn now()}) > '+inttostr(p_iMinutesOld);

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
      saQry:='delete from jsession where JSess_JSession_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JSess_JSession_UID'));
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
  bJAS_UnLockRecord(p_Context,DBC.ID,'jsession',0,0,201501011002);
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
      saQry:='delete from jsessiondata where JSDat_JSessionData_UID='+DBC.sDBMSUIntScrub(rs1.Fields.Get_saValue('JSDat_JSessionData_UID'));
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
function sSessionState(p_SS: byte): string;
//=============================================================================
begin
  case p_ss of
  cnSession_MeansErrorOccurred         : result:='Well, it didn''t explode yet.';
  cnSession_Success                    : result:='Success';
  cnSession_UserNotEnabled             : result:='UserNotEnabled';
  cnSession_NumAllowedSessionExceeded  : result:='NumAllowedSessionExceeded';
  cnSession_InvalidCredentials         : result:='InvalidCredentials';
  cnSession_PasswordsDoNotMatch        : result:='PasswordsDoNotMatch';
  cnSession_PasswordsIdenticalNoChange : result:='PasswordsIdenticalNoChange';
  cnSession_PasswordChangeSuccess      : result:='PasswordChangeSuccess';
  cnSession_LockedOut                  : result:='LockedOut';
  cnSession_InsecurePassword           : result:='Insecure Password.';
  end;//case
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
  JUser_Logins_Successful_u: byte;
  JUser_Logins_Failed_u: byte;
  saQrySelect: ansistring;
  sTHIS_ROUTINE_NAME: String;
  saUserID: ansistring;// used during change password
  //saPubKey: ansistring;
  //rJIPList: rtJIPList;
  //u1invalidLogins: byte;
  bFoundIPInList: boolean;
  u: uint;
  //saPass: ansistring;
Begin
sTHIS_ROUTINE_NAME:='bJAS_CreateSession(p_Context: TCONTEXT):boolean;';
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102487,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102488, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  //saPass:='';
  //u1invalidLogins:=0;
  //DT:=now;
  p_Context.rJSession.JSess_JSession_UID:=0;
  p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;//ZERO B^)
  p_Context.bLoginAttempt:=True;

  {$IFDEF DEBUGMESSAGES}
  if p_Context.CGIENV.DataIn.movefirst then
  begin
    repeat
      JASPrintln('Name:'+p_Context.CGIENV.DataIn.Item_saName+
        ' Value:'+p_Context.CGIENV.DataIn.Item_saValue);
    until not p_Context.CGIENV.DataIn.moveNext;
  end;
  {$ENDIF}


  If p_Context.CGIENV.DataIn.FoundItem_saName('USERNAME',False) Then
  Begin
    p_Context.rJUser.JUser_Name:=p_Context.CGIENV.DataIn.Item_saValue;
  End;
  p_Context.rJUser.JUser_Password:='';

  If p_Context.CGIENV.DataIn.FoundItem_saName('PASSWORD',False) Then
  Begin
    p_Context.rJUser.JUser_Password:=saScramble(p_Context.CGIENV.DataIn.Item_saValue);
  End;


  //p_Context.rJSession.JSess_IP_ADDR:='';
  If p_Context.CGIENV.ENVVAR.FoundItem_saName('REMOTE_ADDR',False) Then
  Begin
    p_Context.rJSession.JSess_IP_ADDR:=p_Context.CGIENV.ENVVAR.Item_saValue;
  End;

  saQrySelect:=
    'select '+
    '  JUser_JUser_UID '+
    ', JUser_Enabled_b'+
    ', JUser_AllowedSessions_u'+
    ', JUser_Login_First_DT'+
    ', JUser_Logins_Successful_u'+
    ', JUser_DefaultPage_Login'+
    ', JUser_DefaultPage_Logout '+
    ', JUser_Logins_Failed_u ';
  saQrySelect+=
    ', JUser_Headers_b '+
    ', JUser_QuickLinks_b '+
    ', JUser_Headers_b '+
    ', JUser_Theme '+
    ', JUser_Background '+
    ', JUser_BackgroundRepeat_b '+
    ', JUser_Admin_b';
  saQrySelect+=
    ' from juser where ((JUser_Deleted_b<>'+DBC.sDBMSBoolScrub(true) +') or (JUser_Deleted_b IS NULL)) AND ';

  if p_Context.bInternalJob then
  begin
    saqry:=saQrySelect + ' JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name);
  end
  else
  begin

    {$IFDEF DEBUGMESSAGES}
    JASPRIntln('p_Context.rJUser.JUser_Password: '+p_Context.rJUser.JUser_Password);
    {$ENDIF}
    saqry:=saQrySelect +
      '(JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name)+') and '+
      '(JUser_Password='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Password)+')';

    {$IFDEF DEBUGMESSAGES}jASPrintln('B>'+saQry+'<');{$ENDIF}
  end;
  jAS_LOG(p_Context,cnLog_Debug,201210171304,'bJAS_CreateSession Credential Query: '+saQry,'',SOURCEFILE);
  {$IFDEF DEBUGMESSAGES}
  jasprintln('Login Credential Check ----------->');
  jasprintln(saQry);
  jasprintln('Login Credential Check ----------->');
  {$ENDIF}
  rs.Open(saQry, DBC,201503161156);
  bOk:=(rs.EOL=False);

  {$IFDEF DEBUGMESSAGES}jaSprintln('B bJAS_CreateSession bOk(' + sYesNo(bOk)+') sSessionState: '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}

  If bOk Then
  Begin
    {$IFDEF DEBUGMESSAGES}jasprintln('Credentials Are Good');{$ENDIF}
    p_Context.rJUser.JUser_JUser_UID:=u8Val(rs.Fields.Get_saValue('JUser_JUser_UID'));
    p_Context.rJUser.JUser_Admin_b:=bVal(rs.Fields.Get_saValue('JUser_Admin_b'));
    p_Context.rJUser.JUser_DefaultPage_Login:=rs.Fields.Get_saValue('JUser_DefaultPage_Login');
    p_Context.rJUser.JUser_DefaultPage_Logout:=rs.Fields.Get_saValue('JUser_DefaultPage_Logout');
    p_Context.rJUser.JUser_Headers_b   := bVal(rs.Fields.Get_saValue('JUser_Headers_b'));
    p_Context.rJUser.JUser_QuickLinks_b:= bVal(rs.Fields.Get_saValue('JUser_QuickLinks_b'));
    p_Context.rJUser.JUser_Headers_b   := bVal(rs.Fields.Get_saValue('JUser_Headers_b'));
    p_Context.rJUser.JUser_Theme       := rs.Fields.Get_saValue('JUser_Theme');
    p_Context.rJUser.JUser_Background  := rs.Fields.Get_saValue('JUser_Background');
    p_Context.rJUser.JUser_BackgroundRepeat_b  := bVal(rs.Fields.Get_saValue('JUser_BackgroundRepeat_b'));

    if p_Context.rJUser.JUser_DefaultPage_Login='NULL' then p_Context.rJUser.JUser_DefaultPage_Login:='';
    if p_Context.rJUser.JUser_DefaultPage_Logout='NULL' then p_Context.rJUser.JUser_DefaultPage_Logout:='';
    bJUser_Enabled_b:=bVal(rs.Fields.Get_saValue('JUser_Enabled_b'));
    JUser_AllowedSessions_u:= u4Val(rs.Fields.Get_saValue('JUser_AllowedSessions_u'));
    JUser_Login_First_DT:=rs.Fields.Get_saValue('JUser_Login_First_DT');
    JUser_Logins_Successful_u:=u4Val(rs.Fields.Get_saValue('JUser_Logins_Successful_u'));
    JUser_Logins_Failed_u:=u4Val(rs.Fields.Get_saValue('JUser_Logins_Failed_u'));

    //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '100 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
  End
  Else
  Begin
    {$IFDEF DEBUGMESSAGES}jASprintln('C bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
    p_Context.iSessionResultCode:=cnSession_InvalidCredentials;
  End;                           
  rs.Close;                      
                                 
  if bOk then                    
  begin                          
    bOk:=bJUser_Enabled_b;       
{$IFDEF DEBUGMESSAGES}jASprintln('D bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
    if not bOk then              
    begin                        
      JasPrintln('User Not Enabled');
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
      bOk:=JUser_Logins_Failed_u<=cnMaxLoginAttempts;
      if not bOk then
      begin
        p_Context.iSessionResultCode:=cnSession_UserNotEnabled;
        {$IFDEF DEBUGMESSAGES}
        jASprintln('DD bJAS_CreateSession bOk: ' + sYesNo(bOk)+
        ' Login fails for user exceeded. JUser.JUser_Logins_Failed_u '+
        'for this user is too high. see cnMaxLoginAttempts');
        {$ENDIF}
      end;
    end;

    if bOk then
    begin
      saQry:='select count(*) as MyCount from jsession where '+
        'JSess_JUser_ID='+inttostr(p_Context.rJUser.JUser_JUser_UID);
      bOk:=rs.Open(saQry, DBC,201503161157);
{$IFDEF DEBUGMESSAGES}jASprintln('E bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
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
{$IFDEF DEBUGMESSAGES}jASprintln('F bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
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
{$IFDEF DEBUGMESSAGES}jASprintln('G bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
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
{$IFDEF DEBUGMESSAGES}jASprintln('H bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
                    if not bOk then
                    begin        
                      JAS_LOG(p_Context, cnLog_Error, 201203010927,sTHIS_ROUTINE_NAME+' - Trouble executing query.','Query: '+saQry,SOURCEFILE,DBC,rs);
                      p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;
                    end;         
                    rs2.Close;   
                  end;           
                until (not bOk) or (not rs.MoveNext);
{$IFDEF DEBUGMESSAGES}jASprintln('I bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
                rs.Close;
                rs.Open(saQry, DBC,201503161161);
              end;               
            end;                 
          end                    
          else                   
          begin                  
{$IFDEF DEBUGMESSAGES}jASprintln('J bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
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
                                 
  //AS_LOG(p_Context, cnLog_ebug, 201203311900, '200 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
  {$IFDEF DEBUGMESSAGES}jASprintln('K bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}

  If bOk Then                    
  Begin                          
    p_Context.rJSession.JSess_JSession_UID:=u8Val(sGetUID);//(p_Context,JAS.ID,'jsession');
    bOk:=p_Context.rJSession.JSess_JSession_UID<>0;
{$IFDEF DEBUGMESSAGES}jASprintln('L bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));{$ENDIF}
    If not bOk Then
    Begin                        
      JAS_Log(p_Context, cnLog_ERROR,200912260049,
        sTHIS_ROUTINE_NAME+' - Unable to Get New jsession UID from saGetNextUID Function.','',SOURCEFILE);
    End;                         
  End;                           
                                 
  {$IFDEF DEBUGMESSAGES}JASPrintLn('Do We Try to make the session record? '+sYesNo(bOk));{$ENDIF}
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
      'JSess_HTTP_USER_AGENT,'+
      'JSess_HTTP_ACCEPT,'+
      'JSess_HTTP_ACCEPT_LANGUAGE,'+
      'JSess_HTTP_ACCEPT_ENCODING,'+
      'JSess_HTTP_CONNECTION,'+
      'JSess_Username ';
    if p_Context.bInternalJob then
    begin                        
      saQry+=', JSess_JJobQ_ID'; 
    end;                         
    saQry+=') VALUES ( '+        
      DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID) + ','+
      '1,'+                      
      DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
    Case DBC.u8DBMSID Of
    cnDBMS_MSSQL: Begin          
      saQry+=',{fn now()},{fn now()},';
    end;                         
    cnDBMS_MSAccess,cnDBMS_MySQL: Begin
      saQry+=',now(),now(),';    
    end;                         
    end;//endswitch              
    saQry+=DBC.saDBMSScrub(p_Context.rJSession.JSess_IP_ADDR)+','+
      DBC.saDBMSScrub(p_Context.REQVAR_XDL.Get_saValue('HTTP_USER_AGENT'))+','+
      DBC.saDBMSScrub(p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT'))+','+
      DBC.saDBMSScrub(p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_LANGUAGE'))+','+
      DBC.saDBMSScrub(p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_ENCODING'))+','+
      DBC.saDBMSScrub(p_Context.REQVAR_XDL.Get_saValue('HTTP_CONNECTION'))+','+
      DBC.saDBMSScrub(p_Context.rJUser.JUser_Name);
    if p_Context.bInternalJob then
    begin                        
      saQry+=','+DBC.sDBMSUIntScrub(p_Context.CGIENV.DataIn.Get_saValue('JJobQ_JJobQ_UID'));
    end;                         
    saQry+=')';                  
    Case DBC.u8DBMSID Of
    cnDBMS_MSSQL, cnDBMS_MSAccess,cnDBMS_MySQL:;
    else saQry:='UNSUPPORTED DBMS';
    end;//endswitch              
    bOk:=rs.Open(saQry,DBC,201503161162);
//ASprintln('M bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
    If not bOk Then
    Begin                        
      // Unable to Create Session record for some reason.
      JAS_Log(p_Context,cnLog_WARN,201001262106,'bJAS_CreateSession - Problem - Unable to create a session record. Query:'+saQry,'',SOURCEFILE);
    End                          
  end;

  if bOk then
  Begin
    //JAS_Log(p_Context,cnLog_ebug,201203311301,'bJAS_CreateSession - SUCCESS MAKING SESSION: '+p_Context.rJSession.JSess_JSession_UID,'',SOURCEFILE);

    p_Context.iSessionResultCode:=cnSession_Success;
    p_Context.bSessionValid:=true;
    //p_Context.CGIENV.AddCook ie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,grJASConfig.u2SessionTimeOutInMinutes),false);
    // DEBUGGING cook ies thing
    //for i:=1 to 20 do p_Context.CGIENV.AddCook ie('JSID'+inttostr(i),p_Context.saSession,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,grJASConfig.iSessionTimeOutInMinutes),false);
    p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,p_Context.rJUser.JUser_JUser_UID);




    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    bOk:=bJAS_LockRecord(p_Context, DBC.ID,'juser',p_context.rJuser.JUser_JUser_UID,0,201501011003);
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=
    //-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-= qqq -=-=-=-=-=-=-=-=--=-=-=-==-=-=-=-====-==-=-=






//ASprintln('N bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_WARN,201001262109,
        sTHIS_ROUTINE_NAME+' - Unable to lock record to update user stats.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saQry:='update juser set JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' ';
    if length(trim(JUser_Login_First_DT))=0 then
    begin
      saQry+=', JUser_Login_First_DT='+DBC.sDBMSDateScrub(FormatDateTime(csDATETIMEFORMAT,now));
    end;
    saQry+=
      ', JUser_Login_Last_DT='+DBC.sDBMSDateScrub(FormatDateTime(csDATETIMEFORMAT,now))+
      ', JUser_Logins_Successful_u='+DBC.sDBMSUIntScrub(JUser_Logins_Successful_u+1)+' '+
      ', JUser_Logins_Failed_u='+DBC.sDBMSUIntScrub(0)+' '+
      'where JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJuser.JUser_JUser_UID);
    rs.Close;
    bOk:=rs.Open(saQry,DBC,201503161163);
//ASprintln('O bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_WARN,201001262108,'bJAS_CreateSession - Unable to update user stats. saQry:'+saQry,'',SOURCEFILE);
    end;
  end;
  rs.Close;
                                 
  if bOk then
  begin
    bOk:=bJAS_UnLockRecord(p_Context, DBC.ID,'juser',p_context.rJuser.JUser_JUser_UID,0,201501011004);
//ASprintln('P bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_WARN,201203011119,
        sTHIS_ROUTINE_NAME+' - Unable to unlock record after updating user stats.','',SOURCEFILE);
    end;
  end;
  rs.Close;

  //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '300 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
                                 
  //if bOk then                  
  if p_Context.iSessionResultCode=cnSession_Success then
  begin                          
    saNewPassword1:='';saNewPassword2:='';
    If uppercase(p_Context.CGIENV.DataIn.Get_saValue('CHANGEPASSWORD'))='ON' Then
    Begin                        
      //asprintln('PASSWORD CHANGE PASSWORD CHANGE PASSWORD CHANGE PASSWORD CHANGE ');
      p_Context.iSessionResultCode:=cnSession_MeansErrorOccurred;// Error didn't occur - but resetting success Status
      saNewPassword1:=saScramble(p_Context.CGIENV.DataIn.Get_saValue('NEWPASSWORD1'));
      saNewPassword2:=saScramble(p_Context.CGIENV.DataIn.Get_saValue('NEWPASSWORD2'));
      ////if bEncryptedDataIn then
      ////begin                      
      //  //ASPRINTLN('201203311849-----------------------BEFORE-------------');
      //  //if length(saNewPassword1)>0 then saNewPassword1:=saJAS_DecryptSingleKey(p_Context, saNewPassword1, saSecKeyIn);
      //  //if length(saNewPassword2)>0 then saNewPassword2:=saJAS_DecryptSingleKey(p_Context, saNewPassword2, saSecKeyIn);
      //  //ASPRINTLN('201203311849-----------------------AFTER--------------');
      ////end;

      bOk:=bGoodPassword(saNewPassword1);
      JASPrintln('Password Change - bGoodPAssword:'+sYesNo(bOk));

      //ASPRINTLN('bOK goodpassword:'+sYesNo(bOk));
      if not bOk then
      begin
        p_Context.iSessionResultCode:=cnSession_InsecurePassword;
        bJAS_RemoveSession(p_Context);
      end;

      if bOk then
      begin
        bOk:=saNewPAssword1=saNewPassword2;
        if not bOk then
        Begin
          p_Context.iSessionResultCode:=cnSession_PasswordsDoNotMatch;
          bJAS_RemoveSession(p_Context);
//ASprintln('Q bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
        End;
      end;

      if bOk then
      begin
        bOk:=(saNewPassword1 <> p_Context.rJUser.JUser_Password);
        if not bOk then
        Begin
          p_Context.iSessionResultCode:=cnSession_PasswordsIdenticalNoChange;
          bJAS_RemoveSession(p_Context);
//ASprintln('R bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
        End;
      end;

      if bOk then
      begin
        //JAS_LOG(p_Context, cnLog_ebug, 201203311900, '400 JUser_JUser_UID: '+p_Context.rJUser.JUser_JUser_UID+' Session UID: '+p_Context.rJSession.JSess_JSession_UID,'', SOURCEFILE);
        saUserID:=inttostr(p_Context.rJUser.JUser_JUser_UID);
        if not bJAS_RemoveSession(p_Context) then
        begin
          JAS_LOG(p_Context, cnLog_Warn,201203010918,'bJAS_CreateSession unable to remove session during password change. '+
            'Session UID: '+inttostr(p_Context.rJSession.JSess_JSession_UID),'',SOURCEFILE);
        end;
                                 
        saQry:='UPDATE juser SET JUser_Password='+DBC.saDBMSScrub(saNewPassword1)+', JUser_Password_Changed_DT='+
          DBC.sDBMSDateScrub(FormatDateTime(csDATETIMEFORMAT,now))+' where JUser_JUser_UID='+DBC.sDBMSUIntScrub(saUserID);

        If rs.Open(saQry, DBC,201503161164) Then
        Begin
          p_Context.iSessionResultCode:=cnSession_PasswordChangeSuccess;
          bOk:=false;
        End
        else
        begin
          JAS_LOG(p_Context, cnLog_Error,201203311843,'bJAS_CreateSession - Query Trouble during password change: '+saQry,'',SOURCEFILE);
        end;
        //ASprintln('T bJAS_CreateSession bOk: ' + sYesNo(bOk));
        rs.Close;
      End;
    End;
  End;

  //if not p_Context.iSessionResultCode=cnSession_Success then
  //begin                          
  //  p_Context.CGIENV.AddCook ie('JSID',DBC.ID,p_Context.CGIENV.saRequestURIwithoutparam,dtAddMinutes(now,-1) ,False);
  //end else
                                 
  // Record and Eventually block cnSession_InvalidCredentials or cnSession_UserNotEnabled
  if (( p_Context.iSessionResultCode = cnSession_InvalidCredentials) or
     ( p_Context.iSessionResultCode = cnSession_UserNotEnabled)) and
     (p_Context.rJSession.JSess_IP_ADDR<>'0.0.0.0') then
  begin
    bFoundIPInList:=false;
    for u:=0 to length(garJIPListLight)-1 do
    begin
      if garJIPListLight[u].sIPAddress=p_Context.rJSession.JSess_IP_ADDR then
      begin
         bFoundIPInList:=true;
         if garJIPListLight[u].u1IPListType=cnJIPListLU_InvalidLogin then
         begin
           garJIPListLight[u].u1InvalidLogins+=1;
           if garJIPListLight[u].u1InvalidLogins>cnMaxLoginAttempts then
           begin
             garJIPListLight[u].sIPAddress:='';//makes same record available for ban process.
             //riteln('session - invalid logins ',garJIPListLight[u].u1InvalidLogins,' max: ',cnMaxLoginAttempts);
             JIPLISTCONTROL(DBC,'B', p_Context.rJSession.JSess_IP_ADDR, 'Invalid Logins Limit Exceeded: '+inttostr(cnMaxLoginAttempts),p_Context.rJUser.JUser_JUser_UID);
           end;
         end;
         break;
      end;
    end;


    if not bFoundIPInList then
    begin
      for u:=0 to length(garJIPListLight)-1 do
      begin
        if garJIPListLight[u].sIPAddress='' then
        begin
          garJIPListLight[u].sIPAddress:=p_Context.rJSession.JSess_IP_ADDR;
          garJIPListLight[u].u1InvalidLogins:=1;
          garJIPListLight[u].u1IPListType:=cnJIPListLU_InvalidLogin;
          break;
        end;
      end;
    end;

    if not p_Context.rJUser.JUser_JUser_UID=cnJUserID_Guest then
    begin
      saQry:='UPDATE juser SET JUser_Logins_Failed_u = JUser_Logins_Failed_u+1 where JUser_Name='+DBC.saDBMSScrub(p_Context.rJUser.JUser_Name);
      bOk:=rs.Open(saQry,DBC,201503161165);
  //ASprintln('Q bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Warn, 201211061105,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
      end;
      rs.close;
      // BEGIN ------------------------------------------------- MAINTENANCE STUFF
      if bOk then
      begin
        bOk:=bJAS_PurgeConnections(p_Context,grJASConfig.u2SessionTimeOutInMinutes);
  //ASprintln('U bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
        If not bOk Then
        Begin
          JAS_Log(p_Context,cnLog_ERROR,200912291109,sTHIS_ROUTINE_NAME+' - trying to clean old Sessions past timeout interval.',
            'Call to bPurgeConnections_MinutesoldAndOlder failed.',SOURCEFILE);
        End;
                                 
        if bOk then
        begin
          bOk:=bJAS_PurgeOrphanedSessionData(p_Context);
  //ASprintln('V bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
          If not bOk Then
          Begin
            JAS_Log(p_Context,cnLog_ERROR,201004102154,sTHIS_ROUTINE_NAME+' - trying to clean orphaned session data.',
            'Call to bJAS_PurgeOrphanedSessionData failed.',SOURCEFILE);
          End;
        end;
      end;
    end;
  end;



  // ------------------------------------
  // Blast ANY OLD LOCKS - system mainentance - not a login issue perse
  // ------------------------------------
  bOk:=bJAS_PurgeLocks(p_Context, grJASConfig.u2LockTimeOutInMinutes);
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
  //  - system mainentance - not a login issue perse
  // Locks without corresponding Session ID's (p_JLock_JSession_ID)
  // ------------------------------------
//ASprintln('X bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
  case DBC.u8DBMSID Of
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

  if bOk then
  begin
    // NOTE: The ZERO connection ID's are there WHILE creating sessions, so can't blast those. Worst case they time out.
    bOk:=rs2.Open(saQry, DBC,201503161168);
//ASprintln('Y bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
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
//ASprintln('Z bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
          If not bOk Then
          Begin
            JAS_Log(p_Context,cnLog_ERROR,200912251702,
              sTHIS_ROUTINE_NAME+' - Error trying to delete orphaned record locks whose session (JLock_JSession_ID) is no longer valid.',
              'saQry: '+saQry,SOURCEFILE,rs);
          End;
          rs.Close;
        End;
      Until (not bOk) OR (not rs2.MoveNext);
//ASprintln('AA bJAS_CreateSession bOk: ' + sYesNo(bOk)+' '+sSessionState(p_Context.iSessionResultCode));
    End;
  End;
  rs2.Close;
  // END   ------------------------------------------------- MAINTENANCE STUFF
  rs.Destroy;rs:=nil;
  rs2.destroy;rs2:=nil;
  Result:=(p_Context.iSessionResultCode=cnSession_Success);
//ASPrintln('CreateSession:'+sYesNo(bOk)+' Result: '+sYesNo(result)+' '+sSessionState(p_Context.iSessionResultCode));

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
  sIncomingIP:string[15];
  rJMail: rtJMAil;
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

  // Get Cook ie Session info if out there
  if bOk then
  begin
    //If p_Context.CGIENV.Cky In.FoundItem_saName('JSID',False) Then
    //Begin
    //  p_Context.rJSession.JSess_JSession_UID:=p_Context.CGIENV.Cky In.Item_saValue;
    //end;
    //
    If p_Context.CGIENV.DataIn.FoundItem_saName('JSID',False) Then
    Begin
      p_Context.rJSession.JSess_JSession_UID:=u8Val(p_Context.CGIENV.DataIn.Item_saValue);
    end;
    bOk:=p_Context.rJSession.JSess_JSession_UID>0;
  end;

  if bOk then
  begin
    sIncomingIP:=p_Context.rJSession.JSess_IP_Addr;
    //load record from db - overw rites previously gathered IP in worker unit.
    bOk:=bJAS_Load_JSession(p_Context,DBC,p_Context.rJSession,false,201609231202);
    if not bOk then
    begin
      JAS_Log(p_COntext, cnLog_Error, 201609231203, sThis_ROUTINE_NAME+' unable to load JSession Record.','',SOURCEFILE);
    end;
  end;

  // QQQ
  // check session timeout (if not already in here) length
  // check new toggle for recycle, if ok - reuse and resurrect timedout session, otherwise tell them to log in via Error Msg
  // Note to viewers: Punk-Be-Gone "module" monitors for excessive errors as one of its strategies :)
  // ...

  {$IFDEF DEBUGMESSAGES}
  if p_Context.CGIENV.DataIn.movefirst then
  begin
    repeat
      JASPrintln('DATAIN Name:'+p_Context.CGIENV.DataIn.Item_saName+
        ' Value:'+p_Context.CGIENV.DataIn.Item_saValue);
    until not p_Context.CGIENV.DataIn.moveNext;
  end;
  if p_Context.CGIENV.EnvVar.movefirst then
  begin
    repeat
      JASPrintln('ENVVAR:'+p_Context.CGIENV.EnvVar.Item_saName+
        ' Value:'+p_Context.CGIENV.EnvVar.Item_saValue);
    until not p_Context.CGIENV.EnvVar.moveNext;
  end;
  {$ENDIF}

  if bOk then
  begin
    bOk:= (p_Context.rJSession.JSess_IP_ADDR                       = sIncomingIP) AND
          (p_Context.REQVAR_XDL.Get_saValue('HTTP_USER_AGENT')     = p_Context.rJSession.JSess_HTTP_USER_AGENT) AND
          (p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT')         = p_Context.rJSession.JSess_HTTP_ACCEPT) AND
          (p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_LANGUAGE')= p_Context.rJSession.JSess_HTTP_ACCEPT_LANGUAGE) AND
          //(p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_ENCODING')= p_Context.rJSession.JSess_HTTP_ACCEPT_ENCODING) AND
          (p_Context.REQVAR_XDL.Get_saValue('HTTP_CONNECTION')     = p_Context.rJSession.JSess_HTTP_CONNECTION);
    if not bOk then
    begin
      //-----------------------------------------------------------------------
      // BAN THE SOB - lying stealing %$%@%@ kick his or her ^$#^%$^#@ then take em and %$@#%#@%$%@% then... nvm. :)
      //-----------------------------------------------------------------------
      if (p_Context.rJSession.JSess_IP_ADDR                      <> sIncomingIP) then
      begin
        JIPListControl(DBC,'B',sIncomingIP,'Masquerading as Session '+
          p_Context.rJSession.JSess_Username+' '+p_Context.rJSession.JSess_IP_ADDR+
          ' from IP: '+ sIncomingIP,p_Context.rJUser.JUser_JUser_UID);
      end;
      //-----------------------------------------------------------------------


      //-----------------------------------------------------------------------
      // HACKER! Force Logout Method
      //
      // this way works by making the session invalid. Annoying to real user,
      // it alerts them to someone tampering with thier stuff
      //-----------------------------------------------------------------------
      //bOk:=bJAS_RemoveSession(p_Context);
      //if not bOk then
      //begin
      //  JAS_Log(p_Context,cnLog_ERROR,201610171755, sTHIS_ROUTINE_NAME+
      //    ' unable to remove session that appears to be getting spoofed. '+
      //    'Session: '+inttostr(p_Context.rJSession.JSess_JSession_UID)+' User: '+
      //    p_Context.rJUser.JUser_Name,sTHIS_ROUTINE_NAME,SOURCEFILE);
      //end;
      //bOk:=false;
      //-----------------------------------------------------------------------


      clear_JMail(rJMail);
      with rJMail do begin
        JMail_From_User_ID:=1;
        JMail_To_User_ID:=p_Context.rJSession.JSess_JUser_ID;
        JMail_Message:='Someone is attempting to masquerade as you. The Log has more detail but the offender came in on IP ' + sIncomingIP;
        JMail_Message_Code:=sGetUID;
      end;
      bJAS_Save_jmail(p_Context, DBC, rJMail, false, false, 201610241913);// fire and forget - attempt to "J-Mail" user about the pest cockroach
      JAS_Log(
        p_Context,
        cnLog_ERROR,
        201609231436,
        'Unable to validate Session. '+
        'Masquerading as Session '+p_Context.rJSession.JSess_Username+' '+
        p_Context.rJSession.JSess_IP_ADDR+' from IP: '+ sIncomingIP,
        '<b>MORE INFO</b><br />'+csCRLF+'<table>'+
        '<tr><td>HTTP_USER_AGENT</td><td>'+p_Context.REQVAR_XDL.Get_saValue('HTTP_USER_AGENT')+'</td><td>'+p_Context.rJSession.JSess_HTTP_USER_AGENT+'</td></tr>'+csCRLF+
        '<tr><td>HTTP_ACCEPT</td><td>'+p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT')+'</td><td>'+p_Context.rJSession.JSess_HTTP_ACCEPT+'</td></tr>'+csCRLF+
        '<tr><td>HTTP_ACCEPT_LANGUAGE</td><td>'+p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_LANGUAGE')+'</td><td>'+p_Context.rJSession.JSess_HTTP_ACCEPT_LANGUAGE+'</td></tr>'+csCRLF+
        '<tr><td>HTTP_ACCEPT_ENCODING</td><td>'+p_Context.REQVAR_XDL.Get_saValue('HTTP_ACCEPT_ENCODING')+'</td><td>'+p_Context.rJSession.JSess_HTTP_ACCEPT_ENCODING+'</td></tr>'+csCRLF+
        '<tr><td>HTTP_CONNECTION</td><td>'+p_Context.REQVAR_XDL.Get_saValue('HTTP_CONNECTION')+'</td><td>'+p_Context.rJSession.JSess_HTTP_CONNECTION+'</td></tr>'+csCRLF+
        '</table>'+csCRLF,
        SOURCEFILE
      );
      //p_COntext.bErrorCondition:=false;
      p_Context.bHavePunkAmongUs:=true;
    end;
  end;

  if bOk then
  begin
    p_Context.rJUser.JUser_JUser_UID:=p_Context.rJSession.JSess_JUser_ID;
    bOk:=bJAS_Load_JUser(p_Context,DBC,p_Context.rJUser, false,201608310007);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,201002101616, sTHIS_ROUTINE_NAME+' unable to load user info from Session Info: '+inttostr(p_Context.rJUser.JUser_JUser_UID),sTHIS_ROUTINE_NAME,SOURCEFILE);
    end;
  end;
  //JAS_Log(p_Context,cnLog_ebug,201203311343,'bJAS_ValidateSession - VALID: '+sYesNo(bOk)+' AFTER bJAS_Load_JUser','',SOURCEFILE);
  rs.close;

  if bOk then
  begin
    Case DBC.u8DBMSID Of
    cnDBMS_MSAccess: sSQLDateFn:='now()';
    cnDBMS_MySQL: sSQLDateFn:='now()';
    cnDBMS_MSSQL: sSQLDateFn:='{fn now()}'
    Else sSQLDateFn:='now()';
    End; //switch

    saQry:='UPDATE jsession SET JSess_LastContact_DT='+sSQLDateFn+' '+
           'WHERE JSess_JSession_UID='+DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID);
    bOk:=rs.Open(saQry,DBC,201503161171);
    if not bOk then
    begin
      //JASLog(p_Context,cnLog_EBUG,201001271924,'bJAS_ValidateSession - LOST saQry:'+saQry,'',SOURCEFILE);
    end;
    rs.Close;
  end;
  //JAS_Log(p_Context,cnLog_ebug,201203311344,'bJAS_ValidateSession - VALID: '+sYesNo(bOk)+' AFTER UPDATE jsession QUERY ','',SOURCEFILE);

  If bOk Then
  Begin
    //JAS_Log(p_Context,cnLog_ebug,201203311304,'bJAS_ValidateSession - Valid Session: '+p_Context.rJSession.JSess_JSession_UID,'',SOURCEFILE);
    //riteln('sessions - validate - Session VALID');
    p_Context.bSessionValid:=true;
    //p_Context.CGIENV.AddCook ie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIWithoutparam,dtAddMinutes(now,grJASConfig.u2SessionTimeOutInMinutes) ,False);
    bOk:=bJAS_LoadSessionData(p_Context);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR,201004102336,'Unable to Load Session Data',sTHIS_ROUTINE_NAME+' Session ID:'+inttostr(p_Context.rJSession.JSess_JSession_UID),SOURCEFILE);
    end;
    //ASPrintln('bJAS_ValidateSession - p_Context.rJUser.JUser_JLanguage_ID: '+inttostr(p_Context.rJUser.JUser_JLanguage_ID));
    p_Context.sLang:=p_Context.sJLanguageLookup(p_Context.rJUser.JUser_JLanguage_ID);
  End
  Else
  Begin
    //ASPrintln('bJAS_ValidateSession - FAILED - Not Logged In');
    clear_juser(p_Context.rJUser);
    p_Context.rJUser.JUser_Name:='Anonymous';
    with p_Context.rJSession do begin
      JSess_JSession_UID:=0;
      //JSess_JSessionType_ID
      JSess_JUser_ID:=0;
      //JSess_Connect_DT
      //JSess_LastContact_DT
      //JSess_IP_ADDR
      //JSess_PORT_u
      JSess_Username:=p_Context.rJUser.JUser_Name;
      //JSess_JJobQ_ID
    end;//with
  End;

  //ASPrintln('bJAS_ValidateSession - saLangCode: '+p_Context.saLang);
  //JAS_Log(p_Context,cnLog_ebug,201203311345,'bJAS_ValidateSession - VALID: '+sYesNo(bOk)+' AFTER Add Cook ie AND bJAS_LoadSessionData','',SOURCEFILE);
  p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,p_Context.rJUser.JUser_JUser_UID);
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
  bOk:=p_Context.rJSession.JSess_JSession_UID>0;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_WARN,200609271005,'RemoveSession - called with invalid JSess_JSession_UID in p_Context.','',sourcefile);
  End;

  If bOk Then
  Begin
    bOk:=bJAS_LockRecord(p_Context,DBC.ID,'jsession', p_Context.rJSession.JSess_JSession_UID,0,201501011005);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200609271007,'RemoveSession - tried to lock the jsession table '+
        'to remove a session.','Could not for session p_Context.JSess_JSession_UID='+inttostr(p_Context.rJSession.JSess_JSession_UID),sourcefile);
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
    saQry:='DELETE FROM jsession where JSess_JSession_UID='+DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID);
    bOk:=rs.Open(saQry, DBC,201503161172);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200609271012,'RemoveSession - Unable to delete record for passed session id',
        'p_Context.JSess_JSession_UID:'+inttostr(p_Context.rJSession.JSess_JSession_UID)+' Query:'+saQry,sourcefile,DBC,rs);
    End;
    rs.Close;
  End;

  // REMOVE ANY/ALL Locks In Use By The Session.
  If bOk Then
  Begin
    rs:=JADO_RECORDSET.create;
    saQry:='DELETE FROM jlock where JLock_JSession_ID='+DBC.sDBMSUintScrub(p_Context.rJSession.JSess_JSession_UID);
    bOk:=rs.Open(saQry, DBC,201503161173);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_WARN,200610031946,'RemoveSession - Unable to remove record locks associated with this session.',
        'p_Context.JSess_JSession_UID:'+inttostr(p_Context.rJSession.JSess_JSession_UID)+' Query: '+ saQry,sourcefile,DBC,rs);
    End;
    rs.Close;
  End;

  // NOTE: No other cleanup (at least for record locks) is necessary because EACH record lock
  // call blasts locks without matching sessions UNLESS session ID value in JSession table is ZERO.

  If rs<>nil Then rs.Destroy;

  p_Context.bSessionValid:=false;
  p_Context.rJSession.JSess_JSession_UID:=0;
  p_Context.rJUser.JUser_JUser_UID:=0;
  p_Context.rJUser.JUser_Name:='Anonymous';
  p_Context.saUserCacheDir:=saJASGetUserCacheDir(p_Context,0);
  //p_Context.CGIENV.AddCook ie('JSID',p_Context.rJSession.JSess_JSession_UID,p_Context.CGIENV.saRequestURIWithoutparam,dtAddMinutes(now,-1) ,False);

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
      'WHERE jsessiondata.JSDat_JSession_ID='+DBC.sDBMSUintScrub(p_Context.rJSession.JSess_JSession_UID);
      bOk:=rs1.Open(saQry, DBC,201503161174);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_ERROR,201004102218,'bJAS_LoadSessionData','Query: '+saQry,sourcefile,DBC,rs1);
      end;
    
      if bOk and (rs1.eol=false) then
      begin
        repeat
          p_Context.SessionXDL.AppendItem;
          p_Context.SessionXDL.Item_i8User:=Int64(u8Val(rs1.fields.Get_saValue('JSDat_JSessionData_UID')));
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
      'JSDat_JSession_ID='+DBC.sDBMSUintScrub(p_Context.rJSession.JSess_JSession_UID);
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
          'JSDat_JSession_ID='+DBC.sDBMSIntScrub(p_Context.rJSession.JSess_JSession_UID)+','+
          'JSDat_Name='+DBC.saDBMSScrub(p_Context.SessionXDL.Item_saName)+','+
          'JSDat_Value='+DBC.saDBMSScrub(p_Context.SessionXDL.Item_saValue)+','+
          'JSDat_CreatedBy_JUser_ID='+DBC.sDBMSIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
          'JSDat_Created_DT='+DBC.sDBMSDateScrub(DT);
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
  p_JSess_JSession_UID: uint64;
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
    'where JSess_JSession_UID=' + DBC.sDBMSUIntScrub(p_JSess_JSession_UID);
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
function saJAS_DecryptSingleKey(p_Context: TCONTEXT; p_saData: ansistring; p_u8SecKey: uint64): ansistring;
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
  rJSecKey.JSKey_JSecKey_UID:=p_u8SecKey;
  bOK:=bJAS_Load_JSecKey(p_Context, DBC, rJSecKey, false,201608310008);
  if not bOk then
  begin
    jas_log(p_Context,cnLog_ERROR,201009051219,'saJAS_DecryptSingleKey - Trouble with loading jseckey.',
      'rJSecKey.JSKey_JSecKey_UID: '+inttostr(rJSecKey.JSKey_JSecKey_UID),sourcefile);
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











//-=-=-=-=-=-=-=-=-=-=-=-=-=--=-==-=-new








//=============================================================================
function bFoundIPInJipListLight(p_sIP: string; var p_uOffset: Uint):boolean;
//=============================================================================
var
  u: uint;
begin
  p_uOffset:=0;
  result:=false;
  for u:=0 to length(garJIPListLight)-1 do
  begin
    if leftStr(garJIPListLight[u].sIPAddress,length(p_sIP))=p_sIP then
    begin
      p_uOffset:=u;
      result:=true;
    end;
  end;
end;
//=============================================================================

















/// right heremake sur garJIPList array gets found, inserted, update correctly
// go thru it all - started to fade finishing it - up - wait until tomorrow :)





//=============================================================================
{}
// Quick way to take immediate charge of the JIPLIST for banning, unbanning etc.
// This effect both the database and memory. No Cycling.
// B = Ban
// P = Promote or Whitelist
// F = Forget or Remove from jiplist
// D = Downloader (Note: Download IP List Type also means it could be a bot being monitored "Robots Text" Counting also
//     as well as beingmonitored for sending JMails while a guest.
// R = RobotTxt Downloaded. This works in conjunction with the SmacKBadBots Function of PBG
// M = Guest JMail
function JIPListcontrol(p_Con: JADO_CONNECTION; p_sAction: string; p_sIP: string; p_sReason: string; p_u8userID: UInt64):boolean;
//=============================================================================
var
  bOK: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  u8UID: uint64;
  //u8len: Uint64;
  //u: UInt;
  u8RowCount: UInt64;
  //u1TempIPListType: byte;
  bSaveInDatabase: boolean;
  //u2LocalDownloads: byte;//<local as in part of this function not part of a class etc its confusing below
  //bRobotsTxtDownloaded: boolean;
  bAlreadySaved: boolean;

  bFoundIPInList: boolean;

  uListOfs: uint;


{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JIPListControl(stuff):boolean;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//const cnJIPListLU_WhiteList = 1;
//const cnJIPListLU_BlackList = 2;
//const cnJIPListLU_InvalidLogin = 3;
  bOk:=true;
  //u2LocalDownloads:=0;
  //bRobotsTxtDownloaded:=false;
  rs:=JADO_RECORDSET.Create;
  // if there already, mark as deleted
  bSaveInDataBase:=true;

  p_sAction:=upcase(p_sAction);
  if p_sAction='F' {FORGET} then
  begin
    bOk:=bDeleteRecord2(p_Con,'jiplist','JIPL','JIPL_IPADDRESS like '+p_Con.saDBMSScrub(p_sIP+'%'),p_u8userID);
    if not bok then
    begin
      writeln('201512031831: Unable to update record. Unable to remove IP from jiplist table.');
    end;
    if bOk then
    begin
      bFoundIPInList:=bFoundIPInJipListLight(p_sIP,uListOfs);
      if bFoundIPInList then
      begin
        clear_JIPListLight(garJIPListLight[uListOfs]);
        if grPunkBeGoneStats.uBanned>0 then grPunkBeGoneStats.uBanned-=1;
      end;
    end;
  end else

  begin
    // if loop for the offeset into the array sems odd not range chacked,
    // you might follow how the code pans out.... when its full MAXED in
    // memory, a resize would break my Thread-Lucky set up (all threads read
    // that array - i have to stop server .. or - not resize - and let it max
    // out - then what?  The HIGHEST array element is the value of uListOfs
    // (garJIPLListLight Array of rtJIPLIstLight. So on entries that are
    // to get written to the database, that happens.. but it doesn't hang on to
    // it in memory because the next one will also end up in the last position
    // so- yes you can fill the "jiplist" array - but you wont lose bans or
    // promotes - so Punk Be Gone doesn't quit. A Cycle of the server would
    // automatically make the array all that much bigger next start up.
    // it adds a third empty slows of your total :) So you can monitor lots
    // of traffic - in mem - heavy - i think its faster :) So - worth it.
    bAlreadySaved:=bFoundIPInJIPListLight(p_sIP,uListOfs);//listofs gets set a value here if TRUE result...
    if not bAlreadySaved then
    begin
      u8UID:=u8GetUID;
      for uListOfs:=0 to length(garJIPListLight)-1 do
      begin
        with garJIPListLight[uListOfs] do begin
          if (sIPAddress='') then
          begin
            clear_JIPListLight(garJIPListLight[uListOfs]);
            break;
          end;
        end;//with
      end;
    end;
    // here no matter what we should be able to trust uListOFS   BRB
    // will work in all situations :) Even ARRAY full (though
    // slightly crippled - all database stuff makes it ;) )

    // type rtJIPListLight = Record
    //   u8JIPList_UID            : UInt64;
    //   u1IPListType             : byte;
    //   sIPAddress               : string;
    //   u1InvalidLogins          : byte;
    //   u2Downloads              : word;
    //   bRequestedRobotsTxt      : boolean;
    //   dtDownLoad               : TDATETIME;
    // end;

    garJIPListLight[uListOfs].sIPAddress:=p_sIP;
    if p_sAction='B' then // BAN
    begin
      grPunkBeGoneStats.uBanned+=1;
      grPunkBeGoneStats.uBannedSinceServerStart+=1;
      grPunkBeGoneStats.uBlockedSinceServerStart+=1;
      garJIPListLight[uListOfs].u1IPListType:=cnJIPListLU_BlackList;
    end
    else

    if p_sAction='P' then // PROMOTE / Whitelist
    begin
      garJIPListLight[uListOfs].u1IPListType:=cnJIPListLU_WhiteList;
    end else

    if (p_sAction='D') or (p_sAction='M') then // Downloader ( Or Robot.txt monitoring )
    begin
      bSaveInDatabase:=false;
      if garJIPListLight[uListOfs].u1IPListType<>cnJIPListLU_BlackList then
      begin
        garJIPListLight[uListOfs].u1IPListType:=cnJIPListLU_Downloader;
      end;
      if p_sAction='D' then
      begin
        garJIPListLight[uListOfs].u2Downloads+=1;
        garJIPListLight[uListOfs].dtDownload:=now;
      end
      else
      begin
        garJIPListLight[uListOfs].u1JMails:=1;
      end;
    end else

    if p_sAction='R' then
    begin
      JASPRINTLN('robot.txt (disallow) served. listofs:'+inttostr(uListOfs));
      bSaveInDatabase:=false;
      if garJIPListLight[uListOfs].u1IPListType<>cnJIPListLU_BlackList then
      begin
        garJIPListLight[uListOfs].u1IPListType:=cnJIPListLU_Downloader;
      end;
      garJIPListLight[uListOfs].bRequestedRobotsTxt:=true;
    end;

    if bSaveInDatabase then
    begin
      if bAlreadySaved then
      begin
        saQry:='update jiplist set JIPL_IPListType_u='+p_Con.sDBMSUIntScrub(garJIPListLight[uListOfs].u1IPListType) +
          ' WHERE JIPL_JIPList_UID='+p_Con.sDBMSUIntScrub(garJIPListLight[uListOfs].u8JIPList_UID);
        bOk:=rs.open(saQry, p_Con,201605031254);
        if not bOk then
        begin
          writeln('201512031842: Unable to UPDATE an existing record in the jiplist table.');
        end;
        rs.close;
      end
      else
      begin
        u8RowCount:=p_Con.u8GetRecordCount('jiplist','((JIPL_Deleted_b=false)or(JIPL_Deleted_b is null)) and '+
          '(JIPL_IPAddress='+p_Con.saDBMSScrub(p_sIP)+')AND(JIPL_IPListType_u='+inttostr(garJIPListLight[uListOfs].u1IPListType)+')',201512031730);
        if u8RowCount=0 then
        begin
          u8UID:=u8GetUID;
          saQry:=
            'INSERT INTO jiplist SET '+
            ' JIPL_JIPList_UID='         + inttostr(u8UID)+
            ',JIPL_IPListType_u='        + inttostr(garJIPListLight[uListOfs].u1IPListType)+
            ',JIPL_IPAddress= '          + p_Con.saDBMSScrub(p_sIP)+
            ',JIPL_InvalidLogins_u= '    + p_Con.sDBMSUIntScrub('0')+
            ',JIPL_Reason='              + p_Con.saDBMSScrub(p_sReason)+
            ',JIPL_Keep_b='              + p_Con.sDBMSBoolScrub(false)+
            ',JIPL_CreatedBy_JUser_ID= ' + p_Con.sDBMSUIntScrub('1')+
            ',JIPL_Created_DT= '         + p_Con.sDBMSDateScrub(now)+
            ',JIPL_ModifiedBy_JUser_ID= '+ 'NULL'+
            ',JIPL_Modified_DT= '        + 'NULL'+
            ',JIPL_DeletedBy_JUser_ID= ' + 'NULL'+
            ',JIPL_Deleted_DT= '         + 'NULL'+
            ',JIPL_Deleted_b= '          + 'NULL'+
            ',JAS_Row_b= '               + p_Con.sDBMSBoolScrub(false);
          bOk:=rs.open(saQry, p_Con,201512031841);
          if not bOk then
          begin
            writeln('201512031842: Unable to insert new record into jiplist table.');
          end;
          rs.close;
        end;
      end;
    end;
  end;
  rs.destroy;
  //Log(cnLog_Info,201602280331,'JIPLIST - '+p_saAction+' Success:'+sYesNo(bOk)+'  '+p_sIP+' '+inttostr(p_u8UserID)+' Reason: '+ p_sReason,SOURCEFILE);
  JASPrintln('Punk-Be-Gone: '+p_sAction+' '+p_sIP+' '+p_sReason);
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
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
