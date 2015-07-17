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
Unit uj_locking;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_locking.pp'}
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
,ug_common
,ug_jegas
,ug_jado
,uj_context
,uj_definitions
,ug_misc
;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//==============================================================================
{}
// Generates Unique Record Identifiers.
Function saJAS_GetNextUID:AnsiString;
//=============================================================================


//=============================================================================
{}
// Lock Works like this:
// PART 1-A: Blast ANY OLD LOCKS 
// PART 1-B: Locks without corresponding Session ID's
//
// PART 2: First TRY to LOCK entire Table - if can't - someone else has it.
//    (Loop to try a couple times) (TABLE LOCK= TABLE ID, ROWID=0)
//
// PART 3: Once Table Lock Established, IF ROWID=0 - see if other locks row level exist,
//    if they do - lose the table lock... keeping table locked not permitted, others own rows.
//
// PART 4: If a ROW ID is Specified, lock the ROW and then Lose the Table Lock. 
//
// PART 5: If a COL ID is Specified, lock the COL and then Lose the Table Lock. 
//
// PART 6: If a ROW and COL ID Are Specified, lock the COL and then Lose the Table Lock. 
//
// PART 7: return true or false to indicate lock granted
Function bJAS_LockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;//< UID from jdconnection table
  p_JLock_TableName: ansistring;//< UID from jtable
  p_JLock_Row_ID: ansistring;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;//< UID from jcolumn that represents the column containing the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
{}
// This function just validates that the LOCK indeed belongs to this session.
function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;//< UID from jdconnection table
  p_JLock_TableName: ansistring;//< UID from jtable
  p_JLock_Row_ID: ansistring;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
{}
// Do to the Nature of this function, the result is not as important
// as the lockrecord one. 
// Note: that there are no protections in place from folks deleting records 
// belonging to others and or other data connections so the responsibility of 
// data integrity remains with the programmer. 
function bJAS_UnlockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;//< UID from jdconnection table
  p_JLock_TableName: ansistring;//< UID from jtable
  p_JLock_Row_ID: ansistring;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
):boolean;
//=============================================================================
{}
// like its name says - it purges locks older than p_iMinutesOld from jlock table
function bJAS_PurgeLocks(p_Context: TCONTEXT; p_iMinutesOld: integer):boolean;
//=============================================================================

 

//=============================================================================
{}
// This procedure  is called primarily from the error page when a user 
// encounters problems performing an action and chooses to try deleting their 
// own record locks as a way of remedying a problem themselves before 
// contacting their administrator. An error will result if the session is 
// not valid. To Be clear: This function deletes all locks associated with 
// the current session.
procedure JAS_DeleteRecordLocks(p_Context: TCONTEXT);
//=============================================================================


//=============================================================================
{}
function bJAS_DeleteRecord(
  p_Context: TCONTEXT;
  p_TGT: JADO_CONNECTION;
  p_saTable: ansistring;
  p_saUID: ansistring
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


var i4UIDCounter: longint;


//=============================================================================
function bJAS_PurgeLocks(p_Context: TCONTEXT; p_iMinutesOld: integer): boolean;
//=============================================================================
var 
    bOk: boolean;
    saQry: ansistring;
    rs: JADO_RECORDSET;
    DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_PurgeLocks(p_Context: TCONTEXT; p_iMinutesOld: integer): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102392,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102393, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  bOk:=true;
  rs:=JADO_RECORDSET.create;

  Case DBC.u2DBMSID Of
  cnDBMS_MSAccess: Begin
    saQry:='DELETE FROM jlock WHERE (datediff(''n'', JLock_Locked_DT, now) > '+DBC.saDBMSIntScrub(p_iMinutesOld)+')';
  End;
  cnDBMS_MySQL: Begin
    saQry:='DELETE FROM jlock where (JLock_Locked_DT < date_sub(now(), interval '+DBC.saDBMSIntScrub(p_iMinutesOld)+' minute)) ';
  End;
  cnDBMS_MSSQL: Begin
    saQry:='DELETE FROM jlock WHERE (datediff(n, JLock_Locked_DT, {fn now()}) > '+DBC.saDBMSIntScrub(p_iMinutesOld)+')';
  End;
  Else Begin
    bOk:=false;
    JAS_Log(
      p_Context,
      cnLog_ERROR,
      200912251046,
      'Unsupported*DBMS JAS.u2DBMSID:'+inttostr(DBC.u2DBMSID),
      'bJAS_PurgeLocks('+inttostr(p_iMinutesOld)+')',
      SOURCEFILE,DBC
    );
  End;
  End; //switch
  if(bOk)then
  begin
    bOk:=rs.Open(saQry, DBC,201503161803);
    if not bOk then
    begin
      JAS_Log(
        p_Context,
        cnLog_ERROR,
        200912251547,
        'Error removing old record locks from database.',
        'bJAS_PurgeLocks('+inttostr(p_iMinutesOld)+') Query: '+saQry,
        SOURCEFILE,DBC, rs
      );
    end;
  end;
  rs.destroy;
  result:=bOk;
  //result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102394,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
// PART 2: First TRY to LOCK entire Table - if can't - someone else has it.
//    (Loop to try a couple times) (TABLE LOCK= TABLE ID, ROWID=0)
//
// PART 3: Once Table Lock Established, IF ROWID=0 - see if other locks row level exist,
//    if they do - lose the table lock... keeping table locked not permitted, others own rows.
//
// PART 4: If a ROW ID is Specified, lock the ROW and then Lose the Table Lock.
//
// PART 5: If a COL ID is Specified, lock the COL and then Lose the Table Lock.
//
// PART 6: If a ROW and COL ID Are Specified, lock the COL and then Lose the Table Lock.
//
// PART 7: return true or false to indicate lock granted
Function bJAS_LockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;// UID from jdconnection table
  p_JLock_TableName: ansistring;// Name of target table to lock
  p_JLock_Row_ID: ansistring;// UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;// UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
Var
    saQry: AnsiString;
    rs: JADO_RECORDSET;
    iRetry: Integer;
    bOk: Boolean;
    bOk2: boolean;
    bTableLocked: boolean;
    i8Row: Int64;
    i8Col: Int64;
    DBC: JADO_CONNECTION;
    JLock_Table_ID: ansistring;
    DT: TDateTime;
    bKeepTableLock: boolean;
    bGotLock: boolean;
    sa: ansistring;
    {$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}


    function saLockInsertQuery(p_saRowID: ansistring; p_saColID: ansistring): ansistring;
    begin
      result:=
        'INSERT INTO jlock ('+
          'JLock_JSession_ID,'+
          'JLock_JDConnection_ID,'+
          'JLock_Locked_DT,'+
          'JLock_Table_ID,'+
          'JLock_Row_ID,'+
          'JLock_Col_ID,'+
          'JLock_Username,'+
          'JLock_CreatedBy_JUser_ID'+
        ')VALUES('+
          DBC.saDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+','+
          DBC.saDBMSUIntScrub(p_JLock_JDConnection_ID)+','+
          DBC.saDBMSDateScrub(DT)+','+
          DBC.saDBMSUIntScrub(JLock_Table_ID)+','+
          DBC.saDBMSUIntScrub(p_saRowID)+','+
          DBC.saDBMSUIntScrub(p_saColID)+','+
          DBC.saDBMSScrub(p_Context.rJUser.JUser_Name)+','+
          DBC.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+
        ')';
    end;



Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_LockRecord(p_Context: TCONTEXT;p_JLock_JDConnection_ID: ansistring;'+
  'p_JLock_TableName:ansistring;p_JLock_Row_ID:ansistring;p_JLock_Col_ID: ansistring): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+p_JLock_JDConnection_ID+' '+
    'p_JLock_TableName:'+p_JLock_TableName+' '+
    'p_JLock_Row_ID:'+p_JLock_Row_ID+' '+
    'p_JLock_Col_ID:'+p_JLock_Col_ID
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102395,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102396, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  JLock_Table_ID:=DBC.saGetTableID(p_JLock_JDConnection_ID,p_JLock_TableName,201210020200);
  bTableLocked:=false;
  bKeepTableLock:=false;
  bGotLock:=false;

  // --------------------------------------------------------------------------
  // PART 1: First TRY to LOCK entire Table - if can't - someone else has it.
  //    (Loop to try a couple times) (TABLE LOCK= TABLE ID, ROWID=0)
  // --------------------------------------------------------------------------
  If bOk Then
  Begin
    saQry:=saLockInsertQuery('0','0');// Lock Table
    iRetry:=0;
    repeat
      bTableLocked:=rs.Open(saQry, DBC,false,201503161803);rs.Close;
      If not bTableLocked Then
      Begin
        iRetry+=1;
        If iRetry=grJASConfig.iLockRetriesBeforeFailure Then
        Begin
          // We Want a FAIL, not a Error Condition.
          // So We LEave bSuccess = false
        End
        Else
        Begin
          //bSuccess:=True; We let this stay false so loop continues.
          Yield(grJASConfig.iLockRetryDelayInMSec);
        End;
      End;
    Until bTableLocked OR (iRetry=grJASConfig.iLockRetriesBeforeFailure);
    bOk:=bTableLocked;
  End;

  // --------------------------------------------------------------------------
  // Check if can lock our desired Row/Column Combo or the Entire Row
  // depending on request.
  // --------------------------------------------------------------------------
  if bOk then
  begin
    i8Row:=i8Val(p_JLock_Row_ID);
    i8Col:=i8Val(p_JLock_Col_ID);
    if (i8Row=0) and (i8Col=0) then
    begin
      // REQUEST FOR TABLE LOCK - WE HAVE IT - WE ARE DONE HERE
      bKeepTableLock:=true;bGotLock:=true;
    end else

    if (i8Row>0) and (i8Col>0) then
    begin
      // REQUEST IF FOR SPECIFIC FIELD on SPECIFIC ROW
      saQry:=saLockInsertQuery(p_JLock_Row_ID,p_JLock_Col_ID);// Lock Table
      bOk:=rs.open(saQry, DBC, false,201503161804);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLOG_Warn,200912251922,
          'bJAS_LockRecord - Unable to create field lock','Query: '+saQry,SOURCEFILE,DBC,rs);
      end else
      begin
        bGotLock:=true;
      end;
      rs.close;
    end else

    if (i8Row>0) and (i8Col<=0) then
    begin
      // REQUEST for ROW LEVEL LOCK
      saQry:=saLockInsertQuery(p_JLock_Row_ID,p_JLock_Col_ID);// Lock Table
      bOk:=rs.open(saQry, DBC, false,201503161805);
      if not bOk then
      begin
        sa:= ' p_JLock_JDConnection_ID:'+p_JLock_JDConnection_ID+' '+
             'p_JLock_TableName:'+p_JLock_TableName+' '+
             'p_JLock_Row_ID:'+p_JLock_Row_ID+' '+
             'p_JLock_Col_ID:'+p_JLock_Col_ID;
        JAS_Log(p_Context,cnLOG_WARN,201203031422,
          'bJAS_LockRecord - Unable to create row lock. '+sa,'Query: '+saQry,SOURCEFILE,DBC,rs);
      end
      else
      begin
        bGotLock:=true;
      end;
      rs.close;
    end else
    begin
      // UNSUPPORTED REQUEST
      bOk:=false;
    end;
  end;

  if (bTableLocked) and (bKeepTableLock=false) then
  begin
    saQry:='DELETE FROM jlock where '+
      'JLock_JDConnection_ID='+DBC.saDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
      'JLock_Table_ID='+DBC.saDBMSUIntScrub(JLock_Table_ID)+' and '+
      'JLock_Row_ID='+DBC.saDBMSUIntScrub(0)+' and '+
      'JLock_Col_ID='+DBC.saDBMSUIntScrub(0);
    bOk2:=rs.Open(saQry,DBC, false,201503161806);
    if not bOk2 then
    Begin
      JAS_Log(p_Context,cnLOG_ERROR,200912251718,'bJAS_LockRecord  - Error attempting to remove table lock',
        'Query: '+saQry,SOURCEFILE,DBC, rs);
    End;
    rs.Close;
    if bOk2<>true then bOk:=false;
  end;
  rs.Destroy;
  // ------------------------------------
  // PART 7: return true or false to indicate lock granted
  // ------------------------------------
  Result:=bOk and bGotLock;


{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102397,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
// This function just validates that the LOCK indeed belongs to this session.
Function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;// UID from jdconnection table
  p_JLock_TableName: ansistring;// UID from jtable
  p_JLock_Row_ID: ansistring;// UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;// UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
Var
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  bOk: Boolean;
  DBC: JADO_CONNECTION;
  JLock_Table_ID: ansistring;
  JLock_Col_ID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_RecordLockValid(p_Context: TCONTEXT;p_JLock_JDConnection_ID: ansistring;'+
  'p_JLock_TableName: ansistring;p_JLock_Row_ID:ansistring;p_JLock_Col_ID:ansistring): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102398,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102399, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  JLock_Table_ID:=DBC.saGetTableID(p_JLock_JDConnection_ID,p_JLock_TableName,201210020201);
  JLock_Col_ID:=DBC.saGetColumnID(p_JLock_JDConnection_ID,JLock_Table_ID,p_JLock_Col_ID);
  
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT '+
    'JLock_JSession_ID '+
    'from jlock where '+
    'JLock_JSession_ID='+DBC.saDBMSUIntScrub(p_context.rJSession.JSess_JSession_UID)+' and '+
    'JLock_JDConnection_ID='+DBC.saDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
    'JLock_Table_ID='+DBC.saDBMSUIntScrub(JLock_Table_ID)+' and '+
    'JLock_Row_ID='+DBC.saDBMSUIntScrub(p_JLock_Row_ID)+' and '+
    'JLock_Col_ID='+DBC.saDBMSUIntSCrub(JLock_Col_ID);
  bOk:=rs.Open(saQry,DBC,201503161807);
  If not bOk Then
  Begin
    JAS_Log(
      p_Context,
      cnLog_ERROR,
      200912252151,
      'bRecordLockValid  - Problem Executing Query.',
      'saQry:'+saQry,
      SOURCEFILE,DBC,RS
    );
  end;
  If bOk Then
  Begin
    bOk:=(rs.EOL=False);
    If not bOk Then
    Begin
      //log(cnLog_WARN, 200810031830,'bRecordLockValid returned false. Zero Rows Returned when calling this query:'+saQry, Sourcefile);
      //JAS_Log(p_Context,cnLog_WARN, 200910031830,'bRecordLockValid returned false. Zero Rows Returned when calling query.','Query: '+saQry, SOURCEFILE, JADOR);
    End;        
  End;
  
  rs.Close;
  rs.Destroy;
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102400,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
// Do to the Nature of this function, the result is not as important
// as the lockrecord one. 
// Note: that there are no protections in place from folks deleting records 
// belonging to others and or other data connections so the responsibility of 
// data integrity remains with the programmer. 
Function bJAS_UnlockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: ansistring;// UID from jdconnection table
  p_JLock_TableName: ansistring;// UID from jtable
  p_JLock_Row_ID: ansistring;// UID of Row in the Table you wish to lock
  p_JLock_Col_ID: ansistring;// UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
Var
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  DBC: JADO_CONNECTION;
  JLock_Table_ID: ansistring;
  JLock_Col_ID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_UnlockRecord';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+p_JLock_JDConnection_ID+' '+
    'p_JLock_TableName:'+p_JLock_TableName+' '+
    'p_JLock_Row_ID:'+p_JLock_Row_ID+' '+
    'p_JLock_Col_ID:'+p_JLock_Col_ID
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102400,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102401, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  JLock_Table_ID:=DBC.saGetTableID(p_JLock_JDConnection_ID,p_JLock_TableName,201210020202);
  JLock_Col_ID:=DBC.saGetColumnID(p_JLock_JDConnection_ID,JLock_Table_ID,p_JLock_Col_ID);
  rs:=JADO_RECORDSET.Create;
  //saQry:='DELETE FROM jlock where '+
  //  'JLock_JSession_ID='+JAS.saDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+' and '+
  //  'JLock_JDConnection_ID='+JAS.saDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
  //  'JLock_Table_ID='+JAS.saDBMSUIntScrub(JLock_Table_ID)+' and ';
  //  'JLock_Row_ID='+JAS.saDBMSUIntScrub(p_JLock_Row_ID)+' and '+
  //  'JLock_Col_ID='+JAS.saDBMSUIntSCrub(JLock_Col_ID);
  p_JLock_Row_ID:=trim(p_JLock_Row_ID);
  if p_JLock_Row_ID='' then p_JLock_Row_ID:='0';
  saQry:='DELETE FROM jlock where '+
    'JLock_JSession_ID='+DBC.saDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+' and '+
    'JLock_JDConnection_ID='+DBC.saDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
    'JLock_Table_ID='+DBC.saDBMSUIntScrub(JLock_Table_ID)+' and '+
    'JLock_Row_ID='+DBC.saDBMSUIntScrub(p_JLock_Row_ID)+' and '+
    'JLock_Col_ID='+DBC.saDBMSUIntScrub(JLock_Col_ID);
  Result:=rs.Open(saQry,DBC,201503161807);
  //ASPrintln('UNLOCK ROW: '+ p_JLock_Row_ID +' Success? '+JAS.saDBMSUIntScrub(p_JLock_Row_ID)+' Query:' +saQRY);
  rs.Close;
  rs.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102402,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





//=============================================================================
Function saJAS_GetNextUID:AnsiString;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saJAS_GetNextUID'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}DebugIn(sTHIS_ROUTINE_NAME,SourceFile);{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ELSE}
  {$IFDEF DEBUGTHREADBEGINEND}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$ENDIF}

  //Result:=FormatDateTime(csUIDFormat,now)+saZeroPadInt(random(100),2);
  //Result:=inttostr(random(184))+FormatDateTime(csUIDFormat,now);
  result:=saRightStr(FormatDateTime(csUIDFormat,now),16)+saZeroPadInt(i4UIDCounter,4);
  i4UIDCounter+=1;
  if i4UIDCounter>999 then i4UIDCounter:=0;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
// This procedure  is called primarily from the error page when a user 
// encounters problems performing an action and chooses to try deleting their 
// own record locks as a way of remedying a problem themselves before 
// contacting their administrator. An error will result if the session is 
// not valid. To Be clear: This function deletes all locks associated with 
// the current session.
procedure JAS_DeleteRecordLocks(p_Context: TCONTEXT);
//=============================================================================
var 
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_DeleteRecordLocks(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102406,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102407, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.create;
  
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201004202218, 'JAS_DeleteRecordLocks - Unable to comply - session is not valid.','',SOURCEFILE);
  end;
  
  if bOk then
  begin
    saQry:='delete from jlock where JLock_JSession_ID='+DBC.saDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID);
    //JAS_Log(p_Context, nLog_Debug,201004202219, 'JAS_DeleteRecordLocks - Query: '+saQry,'',SOURCEFILE);
    bOk:=rs.open(saQry,DBC,201503161808);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201004202219, 'JAS_DeleteRecordLocks - Unable to execute query.','Query: '+saQry,SOURCEFILE);
    end;
    rs.close;
  end;
  rs.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102408,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
function bJAS_DeleteRecord(
  p_Context: TCONTEXT;
  p_TGT: JADO_CONNECTION;
  p_saTable: ansistring;
  p_saUID: ansistring
): boolean;
//=============================================================================
var
  bOk:boolean;
  saQry: ansistring;
  rAudit: rtAudit;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saPKeyCol: ansistring;
  //bJASROWcolExist: boolean;
  bRowIsJasRow: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJAS_DeleteRecord';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203261048,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203261048, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saPKeyCol:=DBC.saGetPKeyColumn(pointer(p_TGT),p_saTable,2012100256);
  if (saPKeyCol='') and (p_saTable='jcolumn') then saPKeyCol:='JColu_JColumn_UID';
  bRowIsJasRow:=p_TGT.bColumnExists(p_saTable,'JAS_Row_b',201210020037) and
                (0<p_TGT.u8GetRowCount(p_saTable,saPKeyCol+'='+p_TGT.saDBMSUIntScrub(p_saUID)+' and JAS_Row_b='+p_TGT.saDBMSBoolScrub(true),201506171710));
                

  
  bOk:= (NOT grJASCOnfig.bProtectJASRecords) or
  
        (NOT (grJASCOnfig.bProtectJASRecords and  bRowIsJasRow)) OR
        
        (grJASCOnfig.bProtectJASRecords and
          p_Context.rJUser.JUser_Admin_b and
          grJASConfig.bSafeDelete and
          bRowIsJasRow and
          (garJVHostLight[p_Context.i4VHost].saServerDomain='default')
        );
        
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201203262012, 'Unable to comply. Will not delete JAS System Records.','',SOURCEFILE);
  end;

  if bOk then
  begin
    if NOT grJASConfig.bSafeDelete then
    begin
      saQry:='DELETE FROM '+p_saTable+' WHERE '+saPKeyCol+'='+p_TGT.saDBMSUIntScrub(p_saUID);
    end
    else
    begin
      clear_audit(rAudit,DBC.saGetColumnPrefix(p_TGT.ID, p_saTable));
      with rAudit do begin
        bUse_DeletedBy_JUser_ID := p_TGT.bColumnExists(p_saTable, saFieldName_DeletedBy_JUser_ID,201210020038);
        bUse_Deleted_DT         := p_TGT.bColumnExists(p_saTable, saFieldName_Deleted_DT,201210020039);
        bUse_Deleted_b          := p_TGT.bColumnExists(p_saTable, saFieldName_Deleted_b,201210020040);
        if (not bUse_DeletedBy_JUser_ID) and (not bUse_Deleted_DT) and (not bUse_Deleted_b) then
        begin
          saQry:='DELETE FROM '+p_saTable+' WHERE '+saPKeyCol+'='+p_TGT.saDBMSUIntScrub(p_saUID);
        end
        else
        begin
          saQry:='';
          if bUse_DeletedBy_JUser_ID then saQry+=saFieldName_DeletedBy_JUser_ID+'='+p_TGT.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
          if bUse_Deleted_DT then
          begin
            if saQRY<>'' then saQRY+=', ';
            saQry+=saFieldName_Deleted_DT+'='+p_TGT.saDBMSDateScrub(now);
          end;
          if bUse_Deleted_b then
          begin
            if saQRY<>'' then saQRY+=', ';
            saQry+=saFieldName_Deleted_b+'='+p_TGT.saDBMSBoolScrub(true);
          end;
          saQry:='UPDATE '+p_saTable+' set ' + saQry + ' WHERE '+saPKeyCol+'='+p_TGT.saDBMSUIntScrub(p_saUID);
        end;
      end;//end with 
    end;
    p_Context.JTrakBegin(p_TGT, p_saTable,p_saUID);
    bOk:=rs.Open(saQry,p_TGT,201503161809);rs.close;
    p_Context.JTrakEnd(p_saUID);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201203261049, 'Trouble deleting record.','Query: '+saQry,SOURCEFILE,p_TGT, rs);
    end;
  end;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203261050,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  i4UIDCounter:=0;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
