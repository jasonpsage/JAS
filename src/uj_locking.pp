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
  p_JLock_JDConnection_ID: UInt64;//< UID from jdconnection table
  p_JLock_Table_ID: uInt64;//< UID from jtable
  p_JLock_Row_ID: uInt64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uInt64;//< UID from jcolumn that represents the column containing the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;


Function bJAS_LockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: UInt64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uInt64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uInt64;//< UID from jcolumn that represents the column containing the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;


//=============================================================================
{}
// This function just validates that the LOCK indeed belongs to this session.



// TODO: THIS ROUTINE Currently CRIPPLED - CIRCLE BACK



function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uInt64;//< UID from jdconnection table
  p_JLock_Table_ID: uInt64;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;

function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uInt64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
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
  p_JLock_JDConnection_ID: uint64;//< UID from jdconnection table
  p_JLock_Table_ID: uint64;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
):boolean;


function bJAS_UnlockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uint64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
):boolean;


//=============================================================================
{}
// like its name says - it purges locks older than p_iMinutesOld from jlock table
function bJAS_PurgeLocks(p_Context: TCONTEXT; p_u2MinutesOld: word):boolean;
//=============================================================================

 

//=============================================================================
{}
// This procedure  is called primarily from the error page when a user 
// encounters problems performing an action and chooses to try deleting their 
// own record locks as a way of remedying a problem themselves before 
// contacting their administrator. An error will result if the session is 
// not valid. To Be clear: This function deletes all locks associated with 
// the current session (user or application).
procedure JAS_DeleteRecordLocks(p_Context: TCONTEXT);
//=============================================================================
{}
// Using this takes into account the configuration setting grJASConfig.bSafeDelete
// which decides if records get flagged as deleted or just deleted outright
// When you have the system configured to use the recycle bin setting where
// records are flagged deleted versus being deleted, you can run into duplicates
// when adding a new record that violates a key (because its supposed to be good)
// So, if you're unable to delete and its not clear why in this recycle mode,
// Check for this possibility. (Empty the Trash!)
function bDeleteRecord(
  p_Con: JADO_Connection;
  p_sTable: string;
  p_sColumnPrefix: string;
  p_saWhereClause: ansistring;
  p_u8UserID: UInt64
): boolean;
//=============================================================================
{}
// This deletes tablelike its name says but it does not provide output however
// it will generate errors if something bombs like you'd expect and the caller
// side (you) will render it unless you clear it and keep going
// with your code. Such errors will still be logged if logging is enabled so
// your code WILL continue if you override an error but you can go back and
// look for any trouble in the log and fix things or what have you after the
// fact.
function bJAS_DeleteRecord(
  p_Context: TCONTEXT;
  p_TGT: JADO_CONNECTION;
  p_sTableName: string;
  p_u8UID: uint64
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
function bJAS_PurgeLocks(p_Context: TCONTEXT; p_u2MinutesOld: word): boolean;
//=============================================================================
var 
    bOk: boolean;
    saQry: ansistring;
    rs: JADO_RECORDSET;
    DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_PurgeLocks(...): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102392,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102393, sTHIS_ROUTINE_NAME);{$ENDIF}

  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;


  DBC:=p_Context.VHDBC;
  bOk:=true;
  rs:=JADO_RECORDSET.create;

  Case DBC.u8DBMSID Of
  cnDBMS_MSAccess: Begin
    saQry:='DELETE FROM jlock WHERE (datediff(''n'', JLock_Locked_DT, now) > '+DBC.sDBMSUIntScrub(p_u2MinutesOld)+')';
  End;
  cnDBMS_MySQL: Begin
    saQry:='DELETE FROM jlock where (JLock_Locked_DT < date_sub(now(), interval '+DBC.sDBMSUIntScrub(p_u2MinutesOld)+' minute)) ';
  End;
  cnDBMS_MSSQL: Begin
    saQry:='DELETE FROM jlock WHERE (datediff(n, JLock_Locked_DT, {fn now()}) > '+DBC.sDBMSUIntScrub(p_u2MinutesOld)+')';
  End;
  Else Begin
    bOk:=false;
    JAS_Log(
      p_Context,
      cnLog_ERROR,
      200912251046,
      'Unsupported*DBMS JAS.u2DBMSID:'+inttostr(DBC.u8DBMSID),
      'bJAS_PurgeLocks('+inttostr(p_u2MinutesOld)+')',
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
        'bJAS_PurgeLocks('+inttostr(p_u2MinutesOld)+') Query: '+saQry,
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
  p_JLock_JDConnection_ID: UInt64;//< UID from jdconnection table
  p_JLock_Table_ID: uInt64;//< UID from jtable
  p_JLock_Row_ID: uInt64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uInt64;//< UID from jcolumn that represents the column containing the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================


Var
    saQry: AnsiString;
    rs: JADO_RECORDSET;
    u2Retry: word;
    bOk: Boolean;
    bOk2: boolean;
    bTableLocked: boolean;
    u8Row: uInt64;
    u8Col: uInt64;
    DBC: JADO_CONNECTION;
    DT: TDateTime;
    bKeepTableLock: boolean;
    bGotLock: boolean;
    sa: ansistring;
    {$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}


    function saLockInsertQuery(p_saRowID: UInt64; p_saColID: UInt64): ansistring;
    begin
      result:=
        'INSERT INTO jlock ('+
          'JLock_JSession_ID,'+
          'JLock_JDConnection_ID,'+
          'JLock_Locked_DT,'+
          'JLock_Table_ID,'+
          'JLock_Row_ID,'+
          'JLock_Col_ID,'+
          'JLock_CreatedBy_JUser_ID,'+
          'JLock_Username'+
        ')VALUES('+
          DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+','+
          DBC.sDBMSUIntScrub(p_JLock_JDConnection_ID)+','+
          DBC.sDBMSDateScrub(DT)+','+
          DBC.sDBMSUIntScrub(p_JLock_Table_ID)+','+
          DBC.sDBMSUIntScrub(p_saRowID)+','+
          DBC.sDBMSUIntScrub(p_saColID)+','+
          DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
          DBC.saDBMSScrub(p_Context.rJUser.JUser_Name)+
        ')';
        //asprintln(saRepeatChar('+',79));
        //ASPrintln(result);
        //asprintln(saRepeatChar('+',79));
    end;



Begin
//result:=true;
//exit;




{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_LockRecord(p_Context: TCONTEXT;p_JLock_JDConnection_ID: ansistring;'+
  'p_JLock_TableName:ansistring;p_JLock_Row_ID:ansistring;p_JLock_Col_ID: ansistring): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+inttostr(p_JLock_JDConnection_ID)+' '+
    'p_JLock_Table_ID:'+inttostr(p_JLock_Table_ID)+' '+
    'p_JLock_Row_ID:'+inttostr(p_JLock_Row_ID)+' '+
    'p_JLock_Col_ID:'+inttostr(p_JLock_Col_ID)
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102395,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102396, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;

  //asprintln(saRepeatChar('=',79));
  //ASPRintln('-------------------------------- TABLE ID - LOCK BEGIN -----------------------');
  //asprintln(saRepeatChar('=',79));



  DT:=now;
  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bTableLocked:=false;
  bKeepTableLock:=false;
  bGotLock:=false;

  //asPrintln('===========');
  //asPrintln('===========');
  //asprintln(    'p_JLock_JDConnection_ID:'+p_JLock_JDConnection_ID+' '+
  //    'p_JLock_TableName:'+p_JLock_TableName+' '+
  //    'p_JLock_Row_ID:'+p_JLock_Row_ID+' '+
  //    'p_JLock_Col_ID:'+p_JLock_Col_ID);
  //asPrintln('===========');
  //asPrintln('===========');


  //if bOk then
  //begin
    bGotLock:=bJAS_RecordLockValid(
      p_Context,
      p_JLock_JDConnection_ID,
      p_JLock_Table_ID,
      p_JLock_Row_ID,
      p_JLock_Col_ID,
      p_u8Caller
    );
  //end;

  if not bGotLock then
  begin
    // --------------------------------------------------------------------------
    // PART 1: First TRY to LOCK entire Table - if can't - someone else has it.
    //    (Loop to try a couple times) (TABLE LOCK= TABLE ID, ROWID=0)
    // --------------------------------------------------------------------------
    saQry:=saLockInsertQuery(0,0);// Lock Table
    u2Retry:=0;
    repeat
      bTableLocked:=rs.Open(saQry, DBC,false,201602171427);rs.Close;
      If not bTableLocked Then
      Begin
        u2Retry+=1;
        If u2Retry=grJASConfig.u2LockRetriesBeforeFailure Then
        Begin
          // We Want a FAIL, not a Error Condition.
          // So We LEave bSuccess = false
        End
        Else
        Begin
          //bSuccess:=True; We let this stay false so loop continues.
          Yield(grJASConfig.u2LockRetryDelayInMSec);
        End;
      End;
    Until bTableLocked OR (u2Retry=grJASConfig.u2LockRetriesBeforeFailure);
    bOk:=bTableLocked;

    
    // --------------------------------------------------------------------------
    // Check if can lock our desired Row/Column Combo or the Entire Row
    // depending on request.
    // --------------------------------------------------------------------------
    if bOk then
    begin
      u8Row:=p_JLock_Row_ID;
      u8Col:=p_JLock_Col_ID;
      if (u8Row=0) and (u8Col=0) then
      begin
         // REQUEST FOR TABLE LOCK - WE HAVE IT - WE ARE DONE HERE
        bKeepTableLock:=true;bGotLock:=true;
      end else
    
      if (u8Row>0) and (u8Col>0) then
      begin
        // REQUEST IF FOR SPECIFIC FIELD on SPECIFIC ROW
        saQry:=saLockInsertQuery(p_JLock_Row_ID,p_JLock_Col_ID);// Lock Table
        bOk:=rs.open(saQry, DBC, false,201503161804);
        if bOk then
        begin
          bGotLock:=true;
        end else
        begin
          JAS_Log(p_Context,cnLOG_Warn,200912251922,
            'bJAS_LockRecord - Unable to create field lock','Query: '+saQry,SOURCEFILE,DBC,rs);
        end;
        rs.close;
      end else
    
      if (u8Row>0) and (u8Col=0) then
      begin
        // REQUEST FOR ROW LEVEL LOCK
        saQry:=saLockInsertQuery(p_JLock_Row_ID,p_JLock_Col_ID);// Lock Row and or a specific field on a Given row
    
        //   QUERY , DB-Connection, LOG-Errors, UniqueCallerID
        bOk:=rs.open(saQry, DBC, false,201503161805);
        //bOk:=rs.open(saQry, DBC, true,201503161805);
        if bOk then
        begin
          bGotLock:=true;
        end
        else
        begin
          sa:= ' p_JLock_JDConnection_ID:'+inttostr(p_JLock_JDConnection_ID)+' '+
               'p_JLock_TableName:'+inttostr(p_JLock_Table_ID)+' '+
               'p_JLock_Row_ID:'+inttostr(p_JLock_Row_ID)+' '+
               'p_JLock_Col_ID:'+inttostr(p_JLock_Col_ID);
          JAS_Log(p_Context,cnLOG_WARN,201203031422, 'bJAS_LockRecord - Unable to create row lock. '+sa,'Query: '+saQry,SOURCEFILE,DBC,rs);
        end;
        rs.close;
      end else
      begin
        // UNSUPPORTED REQUEST
        bOk:=false;
      end;
    end;
    
    //ASPRINTLN('bTableLocked:'+sYesNo(bTableLocked)+' bKeepTableLock:'+sYesNo(bKeepTableLock));
    if (bTableLocked) and (bKeepTableLock=false) then
    begin
      saQry:='DELETE FROM jlock where '+
        'JLock_JDConnection_ID='+DBC.sDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
        'JLock_Table_ID='+DBC.sDBMSUIntScrub(p_JLock_Table_ID)+' and '+
        'JLock_Row_ID='+DBC.sDBMSUIntScrub(0)+' and '+
        'JLock_Col_ID='+DBC.sDBMSUIntScrub(0);
      //asprintln(saRepeatchar('-',79));
      //asprintln(saQry);
      //asprintln(saRepeatchar('-',79));
      bOk2:=rs.Open(saQry,DBC, false,201503161806);
      if not bOk2 then
      Begin
        JAS_Log(p_Context,cnLOG_ERROR,200912251718,'bJAS_LockRecord  - Error attempting to remove table lock',
          'Query: '+saQry,SOURCEFILE,DBC, rs);
      End;
      rs.Close;
      if bOk2<>true then bOk:=false;
    end;
  end;
  rs.Destroy;
  // ------------------------------------
  // PART 7: return true or false to indicate lock granted
  // ------------------------------------
  Result:=bOk and bGotLock;

  //asprintln(saRepeatChar('=',79));
  //ASPRintln('-------------------------------- TABLE ID - LOCK END -----------------------');
  //asprintln(saRepeatChar('=',79));

{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102397,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================






























//=============================================================================
Function bJAS_LockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: UInt64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uInt64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uInt64;//< UID from jcolumn that represents the column containing the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
var u8Caller: UInt64;
Begin
//result:=true;
//exit;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_LockRecord(p_Context: TCONTEXT;p_JLock_JDConnection_ID: uint64;'+
  'p_JLock_TableName:string;p_JLock_Row_ID:u8Int64;p_JLock_Col_ID:u8Int64): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+inttostr(p_JLock_JDConnection_ID)+' '+
    'p_JLock_TableName:'+p_JLock_TableName+' '+
    'p_JLock_Row_ID:'+inttostr(p_JLock_Row_ID)+' '+
    'p_JLock_Col_ID:'+inttostr(p_JLock_Col_ID)+
    'p_u8Caller: '+inttostr(p_u8Caller)
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201608081710,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201608081711, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;

  //asprintln(saRepeatChar('=',79));
  //ASPRintln('-------------------------------- STRING TABLE - LOCK BEGIN -----------------------');
  //asprintln(saRepeatChar('=',79));

  u8Caller:=p_u8Caller;
  result:=bJAS_LockRecord(
     p_Context,
     p_JLock_JDConnection_ID,
     //p_Context.VHDBC.u8GetTableID(p_JLock_JDConnection_ID,p_JLock_TableName,201608081713),
     p_Context.VHDBC.u8GetTableID(p_JLock_TableName,u8Caller),
     p_JLock_Row_ID,
     p_JLock_Col_ID,
     p_u8Caller
  );

  //asprintln(saRepeatChar('=',79));
  //ASPRintln('-------------------------------- STRING TABLE - LOCK END -----------------------');
  //asprintln(saRepeatChar('=',79));



{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201608081712,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================







































//=============================================================================
// This function just validates that the LOCK indeed belongs to this session.
function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uInt64;//< UID from jdconnection table
  p_JLock_Table_ID: uInt64;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
Var
  saQry: ansistring;
  bOk: Boolean;
  DBC: JADO_CONNECTION;
  //JLock_Table_ID: string[64];
  //JLock_Col_ID: string[64];
{$IFDEF ROUTINENAMES}  Var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_RecordLockValid(p_Context: TCONTEXT;p_JLock_JDConnection_ID: ansistring;'+
  'p_JLock_Table_ID: u8Val;p_JLock_Row_ID:ansistring;p_JLock_Col_ID:ansistring): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102398,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102399, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;

  DBC:=p_Context.VHDBC;
  p_JLock_Col_ID:=u8Val(DBC.sGetColumnID(p_JLock_JDConnection_ID,inttostr(p_JLock_Table_ID),inttostr(p_JLock_Col_ID)));
  saQry:=
    'JLock_JSession_ID='+DBC.sDBMSUIntScrub(p_context.rJSession.JSess_JSession_UID)+' and '+
    'JLock_JDConnection_ID='+DBC.sDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
    'JLock_Table_ID='+DBC.sDBMSUIntScrub(p_JLock_Table_ID)+' and '+
    'JLock_Row_ID='+DBC.sDBMSUIntScrub(p_JLock_Row_ID)+' and '+
    'JLock_Col_ID='+DBC.sDBMSUIntScrub(p_JLock_Col_ID);

  bOk:=DBC.u8GetRecordCount('jlock',saQry,201607311017)>0;
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102400,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================












//=============================================================================
// This function just validates that the LOCK indeed belongs to this session.
function bJAS_RecordLockValid(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uInt64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
): Boolean;
//=============================================================================
var
  u8JTableID: uint64;
{$IFDEF ROUTINENAMES}  Var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_RecordLockValid(p_Context: TCONTEXT;p_JLock_JDConnection_ID: ansistring;'+
  'p_JLock_TableName: ansistring;p_JLock_Row_ID:ansistring;p_JLock_Col_ID:ansistring): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102398,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102399, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;
  u8JTableID:=p_COntext.VHDBC.u8GetTableID(p_JLock_TableName,p_u8Caller);
  result:=bJAS_RecordLockValid(
    p_Context,
    p_JLock_JDConnection_ID,
    u8JTableID,//< UID from jtable
    p_JLock_Row_ID,//< UID of Row in the Table you wish to lock
    p_JLock_Col_ID,//< UID from jcolumn that represents the column containg the field you wish to lock.
    p_u8Caller
  );
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
function bJAS_UnlockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uint64;//< UID from jdconnection table
  p_JLock_Table_ID: uint64;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
):boolean;
//=============================================================================
Var
  rs: JADO_RECORDSET;
  saQry: AnsiString;
  DBC: JADO_CONNECTION;
  //JLock_Table_ID: ansistring;
  JLock_Col_ID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
//result:=true;
//exit;


{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_UnlockRecord';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+inttostr(p_JLock_JDConnection_ID)+' '+
    'p_JLock_Table_ID:'+inttostr(p_JLock_Table_ID)+' '+
    'p_JLock_Row_ID:'+inttostr(p_JLock_Row_ID)+' '+
    'p_JLock_Col_ID:'+inttostr(p_JLock_Col_ID)
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102400,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102401, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;

  DBC:=p_Context.VHDBC;
  //JLock_Table_ID:=DBC.saGetTableID(p_JLock_JDConnection_ID,p_JLock_TableName,201210020202);
  JLock_Col_ID:=DBC.sGetColumnID(p_JLock_JDConnection_ID,inttoStr(p_JLock_Table_ID),inttostr(p_JLock_Col_ID));
  rs:=JADO_RECORDSET.Create;
  //saQry:='DELETE FROM jlock where '+
  //  'JLock_JSession_ID='+JAS.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+' and '+
  //  'JLock_JDConnection_ID='+JAS.sDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
  //  'JLock_Table_ID='+JAS.sDBMSUIntScrub(JLock_Table_ID)+' and ';
  //  'JLock_Row_ID='+JAS.sDBMSUIntScrub(p_JLock_Row_ID)+' and '+
  //  'JLock_Col_ID='+JAS.sDBMSUIntScrub(JLock_Col_ID);
  //p_JLock_Row_ID:=p_JLock_Row_ID;
  //if p_JLock_Row_ID='' then p_JLock_Row_ID:=0;
  saQry:='DELETE FROM jlock where '+
    'JLock_JSession_ID='+DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID)+' and '+
    'JLock_JDConnection_ID='+DBC.sDBMSUIntScrub(p_JLock_JDConnection_ID)+' and '+
    'JLock_Table_ID='+DBC.sDBMSUIntScrub(p_JLock_Table_ID)+' and '+
    'JLock_Row_ID='+DBC.sDBMSUIntScrub(p_JLock_Row_ID)+' and '+
    'JLock_Col_ID='+DBC.sDBMSUIntScrub(JLock_Col_ID);
  //asprintln(saRepeatChar('=',79));
  //asprintln(saQry);
  //asprintln(saRepeatChar('=',79));
  Result:=rs.Open(saQry,DBC,201503161807);
  if not result then
  begin
    JAS_Log(p_Context, cnLog_Error,201004202221, 'JAS_Unlockrecord - Unable to execute query.','Query: '+saQry,SOURCEFILE);
  end;
  //ASPrintln('UNLOCK ROW: '+ p_JLock_Row_ID +' Success? '+sYesNo(result)+' '+DBC.sDBMSUIntScrub(p_JLock_Row_ID)+' Query:' +saQRY);
  rs.Close;
  rs.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102402,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================
















//=============================================================================
// Do to the Nature of this function, the result is not as important
// as the lockrecord one.
// Note: that there are no protections in place from folks deleting records
// belonging to others and or other data connections so the responsibility of
// data integrity remains with the programmer.
function bJAS_UnlockRecord(
  p_Context: TCONTEXT;
  p_JLock_JDConnection_ID: uint64;//< UID from jdconnection table
  p_JLock_TableName: string;//< UID from jtable
  p_JLock_Row_ID: uint64;//< UID of Row in the Table you wish to lock
  p_JLock_Col_ID: uint64;//< UID from jcolumn that represents the column containg the field you wish to lock.
  p_u8Caller: Uint64
):boolean;
//=============================================================================
Var
  //rs: JADO_RECORDSET;
  //saQry: AnsiString;
  //DBC: JADO_CONNECTION;
  u8JTableiD: uInt64;
  //JLock_Col_ID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
//result:=true;
//exit;


{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Function bJAS_UnlockRecord';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME+
    'p_JLock_JDConnection_ID:'+inttostr(p_JLock_JDConnection_ID)+' '+
    'p_JLock_TableName:'+p_JLock_TableName+' '+
    'p_JLock_Row_ID:'+inttostr(p_JLock_Row_ID)+' '+
    'p_JLock_Col_ID:'+inttostr(p_JLock_Col_ID)
    ,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201608081714,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201608081715, sTHIS_ROUTINE_NAME);{$ENDIF}
  if not grJASConfig.bRecordLockingEnabled then
  begin
    result:=true;
    exit;
  end;

  u8JTableID:=p_COntext.VHDBC.u8GetTableID(p_JLock_TableName,p_u8Caller);
  result:=bJAS_UnlockRecord(
    p_Context,
    p_JLock_JDConnection_ID,
    u8JTableID,
    p_JLock_Row_ID,
    p_JLock_Col_ID,
    p_u8Caller
  );
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201608081716,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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

  if not grJASConfig.bRecordLockingEnabled then
  begin
    exit;
  end;

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.create;
  
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201004202218, 'JAS_DeleteRecordLocks - Unable to comply - session is not valid.','',SOURCEFILE);
  end;
  
  if bOk then
  begin
    saQry:='delete from jlock where JLock_JSession_ID='+DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JSession_UID);
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
{}
// Using this takes into account the configuration setting grJASConfig.bSafeDelete
// which decides if records get flagged as deleted or just deleted outright
function bDeleteRecord(
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
  //u8UID: ansistring;
  //u8len: Uint64;
  //u: UInt;
  //u8RowCount: UInt64;
  saWhereClause: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bDeleteRecord:boolean;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  saWhereclause:=
      ' ( ' + p_saWhereClause + ' ) and (('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+'='+
      p_Con.sDBMSBoolScrub(false)+') or ('+p_Con.sDBMSEncloseObjectName(p_sColumnPrefix+'_Deleted_b')+' IS NULL))';

  bOk:= (grJASConfig.bProtectJASRecords=false) or bVal(p_Con.saGetValue(p_sTable,'JAS_Row_b',saWhereClause,201608231620));
  if not bOk then
  begin
    JLog(cnLog_Error,201608221636,'The system is configured so that system records can not be deleted.',SOURCEFILE);
  end;


  //riteln('----------');
  //riteln('----------');
  //riteln('locking test-=-');
  //riteln('del rec jas_row_b: '+sYesNo(bVal(p_Con.saGetValue(p_sTable,'JAS_Row_b',saWhereClause,201608231621)))+' Table: ' + p_sTable + ' Where Clause: ' + saWhereClause);
  //log(cnLog_error,201608191836,'del rec jas_row_b: '+sYesNo(bVal(p_Con.saGetValue(p_sTable,'JAS_Row_b',saWhereClause,201608231622)))+' Table: ' + p_sTable + ' Where Clause: ' + saWhereClause,SOURCEFILE);
  //riteln('----------');
  //riteln('----------');
  //riteln('----------');
  //riteln('----------');


  if bOk then
  begin
    saWhereClause:=' WHERE ' + saWhereClause;
    if grJASConfig.bSafeDelete then
    begin
      saQry:='update '+p_Con.sDBMSEncloseObjectName(p_sTable)+ ' SET '+
        p_sColumnPrefix+'_Deleted_dt='+p_Con.sDBMSDateScrub(now)+', '+
        p_sColumnPrefix+'_Deleted_b='+p_Con.sDBMSBoolScrub(true)+', '+
        p_sColumnPrefix+'_DeletedBy_JUser_ID='+p_Con.sDBMSUIntScrub(p_u8UserID) +' '+
        saWhereClause;
    end
    else
    begin
      saQry:='delete from '+p_Con.sDBMSEncloseObjectName(p_sTable)+saWhereClause;
    end;
    //JLog(cnLog_Debug,201602281034,'dbtools.bDeleteRecord Query: '+ saQry,SOURCEFILE);
    rs:=JADO_RECORDSET.Create;
    bOk:=rs.open(saQry,p_Con,201602272215);
    if not bOk then
    begin
      JLog(cnLog_Warn,201602272216,'Trouble Deleting. Query: '+ saQry,SOURCEFILE);
    end;
  end;
  rs.close;
  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================













//=============================================================================

function bJAS_DeleteRecord(
  p_Context: TCONTEXT;
  p_TGT: JADO_CONNECTION;
  p_sTableName: string;
  p_u8UID: uint64
): boolean;
//=============================================================================
var
  bOk:boolean;
  saQry: ansistring;
  rAudit: rtAudit;
  //DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  sPKeyColName: string;
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
  //DBC:=p_Context.VHDBC;

  rs:=JADO_RECORDSET.Create;
  sPKeyColName:=p_TGT.sGetPKeyColumnName(p_sTableName,2012100256);
  //if (p_sTableName='jtask') and (UPCASE(sPKeyColName)<>'JTASK_JTASK_UID') then ----bah
  if (sPKeyColName='') and (p_sTableName='jcolumn') then sPKeyColName:='JColu_JColumn_UID';
  bRowIsJasRow:=p_TGT.bColumnExists(p_sTableName,'JAS_Row_b',201210020037) and
    (0<p_TGT.u8GetRecordCount(p_sTableName,sPKeyColname+'='+p_TGT.sDBMSUIntScrub(p_u8UID)+' and JAS_Row_b='+p_TGT.sDBMSBoolScrub(true),201506171710));


  // OLD----------
  //bOk:= (NOT grJASCOnfig.bProtectJASRecords) or
  //
  //      (NOT (grJASCOnfig.bProtectJASRecords and  bRowIsJasRow)) OR
  //
  //      (grJASCOnfig.bProtectJASRecords and
  //        p_Context.rJUser.JUser_Admin_b and
  //        grJASConfig.bSafeDelete and
  //        bRowIsJasRow and
  //        (garJVHost[p_Context.u2VHost].VHost_ServerDomain='default')
  //      );
  // OLD----------

  bOk:= (NOT grJASCOnfig.bProtectJASRecords) or
        (NOT (grJASCOnfig.bProtectJASRecords and  bRowIsJasRow));

  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201203262012, 'Unable to comply. Will not delete JAS System Records.','',SOURCEFILE);
  end;

  if bOk then
  begin
    if NOT grJASConfig.bSafeDelete then
    begin
      saQry:='DELETE FROM '+p_TGT.sDBMSEncloseObjectName(p_sTableName)+' WHERE '+p_TGT.sDBMSEncloseObjectName(sPKeyColName)+'='+p_TGT.sDBMSUIntScrub(p_u8UID);
    end
    else
    begin
      clear_audit(rAudit,p_TGT.sGetColumnPrefix(p_sTableName));
      with rAudit do begin
        bUse_DeletedBy_JUser_ID := p_TGT.bColumnExists(p_sTableName, saFieldName_DeletedBy_JUser_ID,201210020038);
        bUse_Deleted_DT         := p_TGT.bColumnExists(p_sTableName, saFieldName_Deleted_DT,201210020039);
        bUse_Deleted_b          := p_TGT.bColumnExists(p_sTableName, saFieldName_Deleted_b,201210020040);
        if (not bUse_DeletedBy_JUser_ID) and (not bUse_Deleted_DT) and (not bUse_Deleted_b) then
        begin
          saQry:='DELETE FROM '+p_TGT.sDBMSEncloseObjectName(p_sTableName)+' WHERE '+p_TGT.sDBMSEncloseObjectName(sPKeyColName)+'='+p_TGT.sDBMSUIntScrub(p_u8UID);
        end
        else
        begin
          saQry:='';
          if bUse_DeletedBy_JUser_ID then saQry+=saFieldName_DeletedBy_JUser_ID+'='+p_TGT.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
          if bUse_Deleted_DT then
          begin
            if saQRY<>'' then saQRY+=', ';
            saQry+=saFieldName_Deleted_DT+'='+p_TGT.sDBMSDateScrub(now);
          end;
          if bUse_Deleted_b then
          begin
            if saQRY<>'' then saQRY+=', ';
            saQry+=saFieldName_Deleted_b+'='+p_TGT.sDBMSBoolScrub(true);
          end;
          saQry:='UPDATE '+p_TGT.sDBMSEncloseObjectName(p_sTableName)+' set ' + saQry + ' WHERE '+p_TGT.sDBMSEncloseObjectName(sPKeyColName)+'='+p_TGT.sDBMSUIntScrub(p_u8UID);
        end;
      end;//end with
    end;
    p_Context.JTrakBegin(p_TGT,p_sTableName,p_u8UID);
    bOk:=rs.Open(saQry,p_TGT,201503161809);rs.close;
    p_Context.JTrakEnd(p_u8UID,saQry);
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
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
