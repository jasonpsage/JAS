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
Unit uj_permissions;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_permissions.pp'}
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
,ug_common
,ug_jegas
,ug_jado
,uj_context
,uj_definitions
,sysutils
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
// Returns true if the user has permission with ID passed in the first parameter.
// OR if user they are an administrator. (juser record system admin flag)
Function bJAS_HasPermission(p_Context: TCONTEXT; p_u8PermissionID: Uint64): Boolean;
{}
// Returns true if the user has permission with ID passed in the first parameter.
Function bJAS_HasPermissionAssigned(p_Context: TCONTEXT; p_u8PermissionID: Uint64): Boolean;

//=============================================================================
{}
// DEPRECIATING - EXPECTING CALLS to HAVE the UID of the Permission From now on
// Returns true if the user has permission with the name passed in the first parameter.
// OR if user is an administrator.
//Function bJAS_HasPermission(p_Context: TCONTEXT; p_saPermissionName: ansistring): Boolean;
//=============================================================================
{}
// Returns Security Flags for a given table/row combination. If the ROW
// passed is ZERO then the check is only for basic access to the table
// and not the extra BY row information.
//
// Four TABLE Permissions: Add, View, Update, Delete
//
// The other TABLE wide check that is made is related to the OwnerOnly
// Flag. If this Flag is true, than no access is given.
//
// The Row Level check looks at the Table permission Column and
// checks if the user has the required permission to DO ANYTHING AT ALL
// with that Row.
//
// If you Pass a ROW ID and a PermColumnID, then you save some database
// requests. If you pass the RowID ONLY then more work is required
// including a data request from the databse to get the columns permission
// value.
//
// The Override that WILL grant permission ANYWAYS for all of these are the
// following:
//
// MASTER DATABASE USER FLAGGED as Admin in thier User Record (juser)
//
// Any Database (Jets) or client databases: Any User with the ADMIN
// permission.
//
// All flags passed By Reference, so you must declare the flags and send them
// in the call to this routine.
//
// Function returns true if successful, false if not due to errors usually
// from accessing the Database for one reason or another.
function bJAS_TablePermission(
  p_Context: TCONTEXT;
  var p_rJTable: rtJTable;
  p_u8RowID: Uint64;
  p_u8PermID: UInt64;
  var p_bAdd: boolean;
  var p_bView: boolean;
  var p_bUpdate: boolean;
  var p_bDelete: boolean;
  p_bCheck_Add: Boolean;
  p_bCheck_View: Boolean;
  p_bCheck_Update: Boolean;
  p_bCheck_Delete: Boolean
): boolean;  
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
Function bJAS_HasPermission(p_Context: TCONTEXT; p_u8PermissionID: UInt64): Boolean;
//=============================================================================
var
  bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bHasPermission(p_Context: TCONTEXT; p_uPermissionID: Cardinal): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201303102473,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201303102474, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=bJAS_HasPermissionAssigned(p_Context, p_u8PermissionID) OR p_Context.rJUser.JUser_Admin_b;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201303102475,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function bJAS_HasPermissionAssigned(p_Context: TCONTEXT; p_u8PermissionID: UInt64): Boolean;
//=============================================================================
Var
  bOk: Boolean;
  bHasPerm: Boolean;
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  JUser_JUser_UID: uint64;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bHasPermissionAssigned(p_Context: TCONTEXT; p_uPermissionID: Cardinal): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102473,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102474, sTHIS_ROUTINE_NAME);{$ENDIF}
  {$IFDEF DIAGNOSTIC_WEB_MSG}
  JASPrintln('bHasPermissionAssigned----------------Begin (err:'+saTrueFalse(p_Context.bErrorCondition)+')');
  {$ENDIF}
  bHasPerm:= p_Context.rJUser.JUser_Admin_b;
  if not bHasPerm then
  begin
    if (p_u8PermissionID>0) and (p_Context.bSessionValid) then
    begin
      DBC:=p_Context.VHDBC;
      JUser_JUser_UID:= p_Context.rJUser.JUser_JUser_UID;
      rs:=JADO_RECORDSET.create;
      saQry:=
        'SELECT JSPUL_JUser_ID FROM jsecpermuserlink '+
        'WHERE (JSPUL_JUser_ID=' +DBC.sDBMSUINTScrub(JUser_JUser_UID) + ') AND '+
              '(JSPUL_JSecPerm_ID=' + DBC.sDBMSUINTScrub(p_u8PermissionID) +') AND '+
              '((JSPUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSPUL_Deleted_b IS NULL))';
      bOk:=rs.Open(saQry, DBC,201503161800);
      //if bok then JAS_Log(p_Context,nLog_Debug,201503121518,'has perm user: '+JUser_JUser_UID+ ' SecPerm: '+DBC.sDBMSUINTScrub(p_u8PermissionID)+'   QUERY:'+saQry,'',SOURCEFILE);
      If not bOk Then
      Begin
        JAS_Log(p_Context,cnLog_Error,200612270928,'Error Encountered attempting to run query while testing for permission.',
          'Permission ID: '+inttostr(p_u8PermissionID)+' Query: '+saQry,SOURCEFILE);
        //RenderHtmlErrorPage(p_Context);
      End;

      If bOk Then
      Begin
        bHasPerm:= not rs.EOL;
      End;
      rs.Close;


      If bOk and (not bHasPerm) Then
      Begin
        Case DBC.u8DBMSID Of
        cnDBMS_MSAccess: Begin
          saQry:=
            'SELECT '+
              'jsecgrplink.JSGLk_JSecPerm_ID ' +
            'FROM jsecgrpuserlink '+
              'LEFT JOIN jsecgrplink ON ' +
                'jsecgrpuserlink.JSGUL_JSecGrp_ID = jsecgrplink.JSGLk_JSecGrp_ID ';
          saQry+='WHERE '+
            'jsecgrpuserlink.JSGUL_JUser_ID='+DBC.sDBMSUINTScrub(JUser_JUser_UID)+' AND '+
              'jsecgrplink.JSGLk_JSecPerm_ID=' + DBC.sDBMSUINTScrub(p_u8PermissionID) + ' AND ' +
              'jsecgrplink.JSGLk_JSecPerm_ID=' + DBC.sDBMSUINTScrub(p_u8PermissionID) +' AND '+
              '((JSGUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGUL_Deleted_b IS NULL)) AND '+
              '((JSGLk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGLk_Deleted_b IS NULL)) ';
          saQry+='GROUP BY jsecgrplink.JSGLk_JSecPerm_ID';
        End;
        cnDBMS_MySQL: Begin
          saQry:=
            'SELECT '+
              'jsecgrplink.JSGLk_JSecPerm_ID ' +
            'FROM jsecgrpuserlink '+
              'INNER JOIN jsecgrplink ON ' +
            'jsecgrpuserlink.JSGUL_JSecGrp_ID = jsecgrplink.JSGLk_JSecGrp_ID ';
          saQry+='WHERE '+
            'jsecgrpuserlink.JSGUL_JUser_ID='+DBC.sDBMSUINTScrub(JUser_JUser_UID)+' AND '+
            'jsecgrplink.JSGLk_JSecPerm_ID=' + DBC.sDBMSUINTScrub(p_u8PermissionID) +' AND '+
            '((JSGUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGUL_Deleted_b IS NULL)) AND '+
            '((JSGLk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGLk_Deleted_b IS NULL)) ';
          saQry+='GROUP BY jsecgrplink.JSGLk_JSecPerm_ID';
        End;
        cnDBMS_MSSQL: Begin
          saQry:=
            'SELECT '+
              'jsecgrplink.JSGLk_JSecPerm_ID ' +
            'FROM jsecgrpuserlink '+
              'LEFT JOIN jsecgrplink ON ' +
                'jsecgrpuserlink.JSGUL_JSecGrp_ID = jsecgrplink.JSGLk_JSecGrp_ID ';
          saQry+='WHERE '+
              'jsecgrpuserlink.JSGUL_JUser_ID='+DBC.sDBMSUINTScrub(JUser_JUser_UID)+' AND '+
              'jsecgrplink.JSGLk_JSecPerm_ID=' + DBC.sDBMSUINTScrub(p_u8PermissionID) + ' AND '+
              '((JSGUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGUL_Deleted_b IS NULL)) AND '+
              '((JSGLk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JSGLk_Deleted_b IS NULL)) ';
          saQry+='GROUP BY jsecgrplink.JSGLk_JSecPerm_ID';
        End;
        Else Begin
            saQry:='Unsupported*DBMS';
        End;
        End; //case
        bOk:=rs.Open(saQry, DBC,201503161801);
        //if bok then JAS_Log(p_Context,nLog_Debug,201503121518,'has grp perm user: '+JUser_Juser_UID+ ' SecPErm: '+DBC.sDBMSUINTScrub(p_u8PermissionID),saQry,SOURCEFILE);
        If not bOk Then
        Begin
          JAS_Log(p_Context,cnLog_Error,200612271006,'Error Encountered attempting to run query while testing for permission',
            'Permission ID: '+inttostr(p_u8PermissionID) + ' Query:' + saQry,SOURCEFILE,DBC,rs);
           //RenderHtmlErrorPage(p_Context);
        End;
        If bOk Then
        Begin
          bHasPerm:=not rs.eol;
        End;
        rs.Close;
      End;
      rs.Destroy;
    end
    else
    begin
      bHasPerm:=true;
    end;
  end;
  Result:=bHasPerm;
  {$IFDEF DIAGNOSTIC_WEB_MSG}
  JASPrintln('bHasPermissionAssigned----------------End (err:'+saTrueFalse(p_Context.bErrorCondition)+')');
  {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102475,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================




{
//=============================================================================
Function bJAS_HasPermission(p_Context: TCONTEXT; p_saPermissionName: ansistring): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  Perm_JSecPerm_UID: Uint64;
  DBC: JADO_CONNECTION;
$IFDEF ROUTINENAMES  sTHIS_ROUTINE_NAME: String; $ENDIF
Begin
$IFDEF ROUTINENAMES  sTHIS_ROUTINE_NAME:='bHasPermission(p_Context: TCONTEXT;p_saPermissionName: ansistring): Boolean;'; $ENDIF
$IFDEF DEBUGLOGBEGINEND
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
$ENDIF
$IFDEF DEBUGTHREADBEGINEND p_Context.JThread.DBIN(201203102476,sTHIS_ROUTINE_NAME,SOURCEFILE);$ENDIF
$IFDEF TRACKTHREAD p_Context.JThread.TrackThread(201203102477, sTHIS_ROUTINE_NAME);$ENDIF

  result:=false;
  $IFDEF DIAGNOSTIC_WEB_MSG
  ASPrintln('bHasPermission----------------Begin (err:'+saTrueFalse(p_Context.bErrorCondition)+')');
  $ENDIF
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.create;
  saQry:='SELECT Perm_JSecPerm_UID FROM jsecperm WHERE ((Perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(Perm_Deleted_b IS NULL)) '+
    'AND Perm_Name='+DBC.saDBMSScrub(p_saPermissionName);
  bOk:=rs.Open(saQry, DBC,201503161802);
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,200906212118,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  End;

  if bOk and (not rs.EOL) then
  begin
    Perm_JSecPerm_UID:=u8Val(rs.fields.Get_saValue('Perm_JSecPerm_UID'));
    result:=bJAS_HasPermission(p_Context,Perm_JSecPerm_UID);
  end;
  rs.close;
  rs.destroy;
  $IFDEF DIAGNOSTIC_WEB_MSG
  ASPrintln('bHasPermission----------------End (err:'+saTrueFalse(p_Context.bErrorCondition)+')');
  $ENDIF
$IFDEF DEBUGLOGBEGINEND
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
$ENDIF
$IFDEF DEBUGTHREADBEGINEND p_Context.JThread.DBOUT(201203102478,sTHIS_ROUTINE_NAME,SOURCEFILE);$ENDIF
End;
//=============================================================================
}


//=============================================================================
function bJAS_TablePermission(
  p_Context: TCONTEXT;
  var p_rJTable: rtJTable;
  p_u8RowID: UInt64;
  p_u8PermID: UInt64;
  var p_bAdd: boolean;
  var p_bView: boolean;
  var p_bUpdate: boolean;
  var p_bDelete: boolean;
  p_bCheck_Add: Boolean;
  p_bCheck_View: Boolean;
  p_bCheck_Update: Boolean;
  p_bCheck_Delete: Boolean
): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  u8PermColumnValue: UInt64;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_TablePermission'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211042358,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211042359, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  bOk:=true;

  p_bAdd:=false;
  p_bView:=false;
  p_bUpdate:=false;
  p_bDelete:=false;

  if (garJVHost[p_Context.u2VHost].VHost_ServerDomain='default') and p_Context.rJUser.JUser_Admin_b then
  begin
    p_bAdd:=true;
    p_bView:=true;
    p_bUpdate:=true;
    p_bDelete:=true;
  end else

  if bJAS_HasPermission(p_Context,cnPerm_Admin) then
  begin
    p_bAdd:=true;
    p_bView:=true;
    p_bUpdate:=true;
    p_bDelete:=true;
  end else

  begin
    if p_bCheck_Add then p_bAdd:=bJAS_HasPermission(p_Context, p_rJTable.JTabl_Add_JSecPerm_ID);
    if p_bCheck_View then p_bView:=bJAS_HasPermission(p_Context, p_rJTable.JTabl_View_JSecPerm_ID);
    if p_bCheck_Update then p_bUpdate:=bJAS_HasPermission(p_Context, p_rJTable.JTabl_Update_JSecPerm_ID);
    if p_bCheck_Delete then p_bDelete:=bJAS_HasPermission(p_Context, p_rJTable.JTabl_Delete_JSecPerm_ID);
    
    if p_u8RowID>0 then
    begin
      if p_rJTable.JTabl_Perm_JColumn_ID>0 then
      begin
        u8PermColumnValue:=p_u8PermID;
        if u8PermColumnValue=0 then
        begin
          if NOT bJAS_HasPermission(
            p_Context,
            u8Val(DBC.saGetValue(
              p_rJTable.JTabl_Name,
              DBC.sGetColumnName(p_rJTable.JTabl_Perm_JColumn_ID, 201211050016),
              inttostr(DBC.u8GetPKeyColumnWTableID(p_rJTable.JTabl_JTable_UID,201211050020))+'='+DBC.sDBMSUINTScrub(p_u8RowID)
            ,201608231617)
          )) then
          begin
            p_bAdd:=false;
            p_bView:=false;
            p_bUpdate:=false;
            p_bDelete:=false;
          end;
        end
        else
        begin
          if NOT bJAS_HasPermission(p_Context, u8PermColumnValue) then
          begin
            p_bAdd:=false;
            p_bView:=false;
            p_bUpdate:=false;
            p_bDelete:=false;
          end;
        end;
      end;
    end;
  end;

  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211040000,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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

//=============================================================================
// History (Please Insert Historic Entries at top)
//=============================================================================
// Date        Who             Notes
//=============================================================================
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
