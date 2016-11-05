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
// JAS/Webserver Listener class
Unit uj_listener;

//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_listener.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{$IFDEF TRACKTHREAD}
  {$INFO | TRACKTHREAD: TRUE - system diagnostic/debug }
{$ENDIF}



{DEFINE DEBUGTHREADBEGINEND} // used for thread debugging, like begin and end sorta
                  // showthreads shows the threads progress with this.
                  // whereas debuglogbeginend is ONE log file for all.
                  // a bit messy for threads. See uxxg_jfc_threadmgr for
                  // mating define - to use this here, needs to be declared
                  // in uxxg_jfc_threadmgr also.
{$IFDEF DEBUGTHREADBEGINEND}
  {$INFO | DEBUGTHREADBEGINEND: TRUE}
{$ENDIF}

{DEFINE SAVE_HTMLRIPPER_OUTPUT}
{$IFDEF SAVE_HTMLRIPPER_OUTPUT}
  {$INFO | SAVE_HTMLRIPPER_OUTPUT: TRUE}
{$ENDIF}

{DEFINE SAVE_ALL_OUTPUT}
{$IFDEF SAVE_ALL_OUTPUT}
  {$INFO | SAVE_ALL_OUTPUT: TRUE}
{$ENDIF}

{DEFINE DIAGNOSTIC_LOG}
{$IFDEF DIAGNOSTIC_LOG}
  {$INFO | DIAGNOSTIC_LOG: TRUE}
{$ENDIF}

{DEFINE DIAGNOSTIC_WEB_MSG}
{$IFDEF DIAGNOSTIC_WEB_MSG}
  {$INFO | DIAGNOSTIC_WEB_MSG: TRUE}
{$ENDIF}

{DEFINE DEBUG_PARSEWEBSERVICEFILEDATA} // The ParseWebServiceFileData
                  // function has alot of JASDebugPrintLn commands that
                  // are great when debugging the parsing but overkill as
                  // debug output otherwise. Undefine to make those lines not
                  // get included in the compile.
{$IFDEF DEBUG_PARSEWEBSERVICEFILEDATA}
  {$INFO | DEBUG_PARSEWEBSERVICEFILEDATA: TRUE}
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
,blcksock
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jfc_threadmgr
,ug_jado
,uj_worker
,uj_definitions
,uj_dbtools
,uj_locking
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
Type TLISTEN= Class(TJTHREAD) 
//=============================================================================
  //rSocketInfo: rtSocketInfo;
  //rSocketNew: rtSocketInfo;
  {}
  Worker: TWorker;
  ListenSock:TTCPBlockSocket;
  NewSock:TTCPBlockSocket;
  dtLastInternalJobScan: TDATETIME;
  procedure OnCreate;override;
  //procedure OnTerminate; override;
  public
  Procedure ExecuteMyThread; override;
  public
  u2VHostJobQIndex: word;
  icursorspin: longint;// for text output - diagnostic in nature
  LDBC: JADO_CONNECTION;
  bHaveDBConnection: boolean;
  bWorkers: boolean;
  dtNoWorkers: TDateTime;
  dtLastJIPListLightRefresh: TDateTime;
  dtLastIPExpirationCheck: TDateTime;
End;
//=============================================================================
var 
  gListener: TLISTEN;
  TEMP_CYCLE_LISTENSOCK: TTCPBlockSocket;


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
procedure TLISTEN.OnCreate;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TLISTEN.OnCreate;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102380,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102381, sTHIS_ROUTINE_NAME);{$ENDIF}
  dtLastInternalJobScan:=now;
  dtLastJIPListLightRefresh:=now;
  bWorkers:=true;
  dtNoWorkers:=now;//just a default
  dtLastIPExpirationCheck:=dtAddYears(now,-1);
  Worker:=nil;
  u2VHostJobQIndex:=0;
  iCursorSpin:=0;
  ListenSock:=TTCPBlockSocket.create;
  ListenSock.CreateSocket;
  if ListenSock.lasterror <> 0 then writeln('TListen.create(CreateSocket)ListenSock.LastError:'+inttostr(ListenSock.lasterror));
  //ListenSock.setLinger(true,10);
  //if gListener.ListenSock.lasterror <> 0 then writeln('(SetLinger)ListenSock.LastError:'+inttostr(gListener.ListenSock.lasterror));
  LDBC:=JADO_Connection.createcopy(gaJCon[0]);

  //LDBC.saMyUsername:=         gaJCon[0].saMyUsername;
  //LDBC.saMyPassword:=         gaJCon[0].saMyPassword;
  //LDBC.saMyConnectString:=    gaJCon[0].saMyConnectString;
  //LDBC.saMyDatabase:=         gaJCon[0].saMyDatabase;
  //LDBC.saMyServer:=           gaJCon[0].saMyServer;

  bHaveDBConnection:=LDBC.OpenCon;
  if not bHaveDBConnection then
  begin
    //asPrintln('Listener GOT NOTHING :(');
    JLog(cnLog_ERROR, 201602180110, 'Unable to open Listener''s personal db connection.', SOURCEFILE);
  end
  else
  begin
    //asPrintln('Listener got a db connection open');
  end;

  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102382,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

////=============================================================================
//procedure TLISTEN.OnTerminate;
////=============================================================================
//
//{$IFDEF ROUTINENAMES} var sTHIS_ROUTINE_NAME: String; {$ENDIF}
//Begin
//{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TLISTEN.OnTerminate;'; {$ENDIF}
//{$IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
//{$ENDIF}
//{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102383,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
//{$IFDEF TRACKTHREAD}TrackThread(201203102384, sTHIS_ROUTINE_NAME);{$ENDIF}
//
//
//  // the destroy doesnt happen here so we can recycle the socket ;)
//
//
//  //asprintln('b4 tlisten.onterminate, listensock.destroy');
//  //if listensock=nil then asprintln('listen soc is nil');
//  //listensock.destroy;listensock:=nil;
//  //asprintln('after tlisten.onterminate, listensock.destroy');
//
//  
//  //ASPrintln('200906272357 - TListen.OnTerminate - FIFO Destroyed Successfully!');
//{$IFDEF DEBUGLOGBEGINEND}
//  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
//{$ENDIF}
//{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102385,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
//end;
/////=============================================================================





//=============================================================================
Procedure TLISTEN.ExecuteMyThread;
//=============================================================================
var 
  bOk:boolean;  
  JTI: rtJThreadInit;
  u: uint;
  bCanRead: boolean;
  //sIP: string[15];
  rs: JADO_RECORDSET;
  TempWorker: TWORKER;
  saQry: ansistring;
  saMsg: ansistring;
  bThreadIsOverTime: boolean;
  //u8JiplistLen: uint64;
  dt: TDateTime;
  u2DB, u2Host: word;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TLISTEN.ExecuteMyThread;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102389,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102390, sTHIS_ROUTINE_NAME);{$ENDIF}
  //Shut up compiler - this IS USED but it complains without this
  TempWorker:=nil;TempWorker:=TempWorker;
  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  //ASPrintLn('TLISTEN.ExecuteMyThread');

  {$IFDEF DEBUGTHREADBEGINEND}
  //DBIN(201002030075,'TLISTEN.ExecuteMyThread;', SOURCEFILE);
  {$ENDIF}
  if gbServerShuttingDown=false then
  begin
    //-------------------------------------------------------------------------
    //ASPrintln('Make Workers if there is room for them');
    ////-------------------------------------------------------------------------
    {$IFDEF TRACKTHREAD}TrackThread(201605021218, 'Making New Workers');{$ENDIF}

    for u:=0 to length(aWorker)-1 do
    begin
      if aWorker[u]<>nil then
      begin
        bThreadIsOverTime:=
          (not aWorker[u].Context.bSessionValid) and
          (aWorker[u].bFinished=true) and
          (aWorker[u].Suspended=false) and
          (iDiffMSec(aWorker[u].dtExecuteBegin,now)>grJASConfig.uThreadPoolMaximumRunTimeInMSec);
        if bThreadIsOverTime then JASPRintln('Assassin A - Trying to Kill Worker: '+inttostr(u));
        if aWorker[u].bFinished or bThreadisOverTime then
        begin
          try
            {$IFDEF TRACKTHREAD}TrackThread(201605021219, 'Attempting to terminate worker '+inttostr(aWorker[u].uMyId));{$ENDIF}
            if aWorker[u].FreeOnTerminate then
            begin
              aWorker[u].terminate;
            end
            else
            begin
              aWorker[u].terminate; aWorker[u].Destroy
            end;
            //aWorker[i]:=nil; // Proper Place but.. to keep going? Orphan it. see below
            //ASPrintln('Killed One!');
          except on E: EThread do JASPrintln('Exception ETHREAD THROWN - 201602261925');
          end;
          //aWorker[i]:=nil;//<--- Not the "right" thing - but I dont know what to do when they wont die! lol
          // Right thing? Currently? Leave it - try again later. Added the "Not bSessionValid" bit so logged
          // in it doesn't try to kill long jobs.

        end;
      end;

      if aWorker[u]=nil then
      begin
        //----------------------------------------- make a worker
        //self.CSECTION.Enter;
        with JTI do begin
          bCreateCriticalSection:=false;
          bLoopContinuously:=false;
          bCreateSuspended:=true;
          bFreeOnTerminate:=true;
          UID:=imsec;
        end;
        {$IFDEF TRACKTHREAD}TrackThread(201605021220, 'Attempting to create a new worker '+inttostr(u));{$ENDIF}
        try
          bOk:=false;
          Worker:=TWorker.Create(JTI);
          Worker.uMyID:=u;
          aWorker[u]:=Worker;
          bOk:=true;// only stays true if succeeds
          //ASPrintln('Created a Worker in the listener');
        except on E: EThread do JASPrintln('Exception ETHREAD THROWN - 201012191646');
        end;//try
      end;
    end;
    //-------------------------------------------------------------------------
    // Make Workers if there is room for them
    //-------------------------------------------------------------------------




    //-------------------------------------------------------------------------
    //ASPrintln('Hunt for Worker all set to go. b4 Worker:'+inttostr(uint(Worker))+' bOk:'+saYesNo(bOk));
    //-------------------------------------------------------------------------
    if bOk then  // hunt for suspended workers first
    begin
      {$IFDEF TRACKTHREAD}TrackThread(201605021221, 'Attempting to grab a worker to fulfill the current request.');{$ENDIF}
      bOk:=false;
      //ASPrintln('length of aWorker: '+inttostr(length(aWorker)));
      for u:=0 to length(aWorker)-1 do
      begin
        //ASPrint('wkr['+inttostr(i)+']='+inttostr(uint(aWorker[i])));
        //if (aWorker[i]<>nil) then asprint(' Suspended: '+saYesNo(aWorker[i].Suspended));
        //asprintln;
        if (aWorker[u]<>nil) and aWorker[u].Suspended then
        begin
          //asprintln('Found suspended worker');
          worker:=aWorker[u]; bOk:=true;
          break;
        end;
      end;
    end;
    //-------------------------------------------------------------------------
    //ASPrintln('Hunt for Worker all set to go. After Worker:'+inttostr(uint(Worker)));
    //-------------------------------------------------------------------------





    //-------------------------------------------------------------------------
    // No Workers? TRack That, gets to be issue? Cycle the server.
    //-------------------------------------------------------------------------
    if worker=nil then
    begin
      if bWorkers then
      begin
        bWorkers:=false;
        dtNoWorkers:=now;
      end
      else
      begin
        if (iDiffMSec(dtNoWorkers,now)>(grJASConfig.uThreadPoolMaximumRunTimeInMSec*length(aWorker))) then
        begin
          saMsg:='Server Out of Usable threads. Attempting a Shutdown.';
          JASPrintln(saMSG);
          JLog(cnLog_ERROR, 201602262037, saMsg, SOURCEFILE);
          gbServerShuttingDown:=true;
        end;
      end;
    end
    else
    begin
      bWorkers:=true;
    end;
    //-------------------------------------------------------------------------
    // No Workers? TRack That, gets to be issue? Cycle the server.
    //-------------------------------------------------------------------------




    if (Worker <> nil) and bOk then
    begin
      //-----------------------------------------------------------------------
      // Enough time elapse to try another internal job?
      //-----------------------------------------------------------------------
      //self.CSECTION.Enter;
      if grJASConfig.bJobQEnabled and (iDiffMSec(dtLastInternalJobScan,now)>grJASConfig.u4JobQIntervalInMSec) then
      begin
        //ASPrintln('201511232235 - JOBQ - Timer Durartion Met');
        //ASPRintln('JOBQ scan diffmsec listener: ' + inttostr(iDiffMSec(dtLastInternalJobScan,now)));
        //ASPrintln('i4VHostJobQIndex:'+inttostr(i4VHostJobQIndex));
        dtLastInternalJobScan:=now;
        if u2VHostJobQIndex>=length(garJVhost) then
        begin
          u2VHostJobQIndex:=0;
        end
        else
        begin
          Worker.Context.u2Vhost:=u2VHostJobQIndex;
          u2VHostJobQIndex+=1;
          JASPRint('.');
          Worker.CheckJobQ;//This procedure will populate and set the Worker.bInternalJob flag accordingly
        end;
      end;
      //else
      //begin
      //  writeln('iDiffMSec: ',iDiffMSec(dtLastInternalJobScan,now));
      //  writeln('dtLastInternalJobScan: ',dtLastInternalJobScan);
      //  writeln('grJASConfig.iJobQIntervalInMSec: ',grJASConfig.iJobQIntervalInMSec);
      //  writeln;
      //end;
      //self.CSECTION.Leave;
      //-----------------------------------------------------------------------
      //
      //-----------------------------------------------------------------------





      if not Worker.bInternalJob then
      begin
        //-----------------------------------------------------------------------
        //  LISTENER - HAS WORKER, Waiting for Request!
        //-----------------------------------------------------------------------
        //ASPrintln('Listening:'+inttostr(grJASConfig.u4ListenDurationInMSec));
        {$IFDEF TRACKTHREAD}TrackThread(201605021222, 'Waiting for requests');{$ENDIF}

        bCanRead:=ListenSock.canread(grJASConfig.u4ListenDurationInMSec);
        //bCanRead:=ListenSock.canread(1000);//Loops once per second (1000 MSEC) when no requests

        //ASPRint('bCanRead: '+sYesNo(bCanRead));
        //aSPrint(#8); 
        //-----------------------------------------------------------------------
        //  LISTENER - HAS WORKER, Waiting for Request!
        //-----------------------------------------------------------------------

        if bCanRead then
        begin
          //-----------------------------------------------------------------------
          //  Hand Request/Connection to out on deck Worker and send it on its way
          //-----------------------------------------------------------------------
          //self.CSECTION.Enter;
          //ASPrintln('Got Request!');
          {$IFDEF TRACKTHREAD}TrackThread(201605021223, 'Got Request');{$ENDIF}
          Worker.ConnectionSocket:=TTCPBlockSocket.Create;
          Worker.ConnectionSocket.socket:=ListenSock.accept;
          // Only SSL Specific Bit here so far
          if grJASConfig.bEnableSSL then
          begin
            JASPrintln('SSL Enabled');
            Worker.ConnectionSocket.SSLAcceptConnection;
          end;
          //Worker.ConnectionSocket.ExceptCheck;
          //asprint('start worker...');
          worker.start;
          //asprintln('success!');
          Worker:=nil;
          //self.CSECTION.Leave;
          //-----------------------------------------------------------------------
          //  Hand Request/Connection to out on deck Worker and send it on its way
          //-----------------------------------------------------------------------
        end
        else
        begin
          {$IFDEF TRACKTHREAD}TrackThread(201605021225, 'Housekeeping.');{$ENDIF}
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          // You'll notice ERRORS designed to be logged but fall thru and continue
          // trying unlike almost everywhere else where an Error usually interrupts
          // the ongoing tasks.
          If Not grJASCOnfig.bRecycleSessions then
          begin
            //ASPRintln('---- NOT RECYCLE SESSION LISTENER MAINTENTANCE FIRED ----');
            dt:=dtSubtractMinutes(Now,grJASConfig.u2SessionTimeOutInMinutes);
            u2DB:=0;
            u2Host:=0;
            if gbMainSystemOnly then
            begin
              saQry:='delete from jsession where JSess_LastContact_DT <= '+gaJCon[0].sDBMSDateScrub(dt);//+' and 1=1';
              bOk:=rs.open(saQry,gaJCon[u2DB],201609232302);
              if not bOk then
              begin
                JLog(cnLog_Error, 201609232303, 'Unable to execute Listener house-keeping query. Main System Only Mode.'+
                  ' Host: '+garJVHost[u2Host].VHost_ServerName+
                  ' Query: '+saQry, SOURCEFILE);
              end;
            end
            else
            begin
              for u2Host:=0 to length(garJVHost)-1 do
              begin
                //asprintln('u2Host:'+inttostr(u2host));
                if (garJVHost[u2Host].VHost_JDConnection_ID>0) and (garJVHost[u2Host].VHost_Enabled_b) then
                begin
                  for u2DB:=0 to length(gaJCon)-1 do
                  begin
                    //asprintln('u2DB:'+inttostr(u2DB));
                    if (gaJCon[u2DB] <> nil) and (garJVHost[u2Host].VHost_JDConnection_ID=gaJCon[u2DB].ID) and (gaJCon[u2DB].bConnected)then
                    begin
                      saQry:='delete from jsession where JSess_LastContact_DT <= '+gaJCon[u2DB].sDBMSDateScrub(dt);
                      bOk:=rs.open(saQry,gaJCon[u2DB],201609232300);
                      if not bOk then
                      begin
                        JLog(cnLog_Error, 201609232301, 'Unable to execute Listener house-keeping query.'+
                          ' Host: '+garJVHost[u2Host].VHost_ServerName+
                          ' Query: '+saQry, SOURCEFILE);
                      end;
                    end;
                  end;
                end;
              end;
            end;
            //ASPRintln('---- NOT RECYCLE SESSION LISTENER MAINTENTANCE DONE! ----');
          end;

          if (grJASConfig.bBlacklistIPExpire or grJASConfig.bWhitelistIPExpire or grJASConfig.bInvalidLoginsExpire) then
          begin
            if (iDiffDays(dtLastIPExpirationCheck,now)>1) then
            begin
              dtLastIPExpirationCheck:=now;
              saQry:='select JIPL_JIPList_UID from jiplist where ((JIPL_Deleted_b=false)OR(JIPL_Deleted_b IS NULL)) AND ';

              //============== Expire BlackListed IP's ========================
              if grJASConfig.bBlacklistIPExpire then
              begin
                bOk:=rs.Open(saQry+
                  '(JIPL_IPListType_u ='+gaJCon[0].sDBMSUIntScrub(csJIPListLU_BlackList)+') and '+
                  '(JIPL_Keep_b ='+gaJCon[0].sDBMSBoolScrub(false)+') and '+
                  '(JIPL_Modified_DT  <= '+gaJCON[0].sDBMSDateScrub(dtAddDays(now, grJASConfig.u2BlacklistDaysUntilExpire*-1))+')'
                  ,gaJCon[0],2016032200
                );

                if not bOk then
                begin
                  JLog(cnLog_ERROR, 201603022203, 'Expiring old blacklisted IPs the Query Failed: '+saQry, SOURCEFILE);
                end;

                if bOk and rs.movefirst then
                begin
                  repeat
                    if not bDeleteRecord(gaJCon[0],'jiplist','JIPL','JIPL_JIPList_UID='+gaJCon[0].sDBMSUIntScrub(rs.Get_saValue('JIPL_JIPList_UID')),201603022227) then
                    begin
                      JLog(cnLog_ERROR, 201603022204, 'Expiring old blacklisted IPs the dbtools call to delete the record came back false.', SOURCEFILE);
                    end;
                  until not rs.movenext;
                end;
                rs.close;
              end;
              //============== Expire BlackListed IP's ========================



              //============== Expire WhiteListed IP's ========================
              if grJASConfig.bWhitelistIPExpire then
              begin
                bOk:=rs.Open(saQry+
                  '(JIPL_IPListType_u ='+gaJCon[0].sDBMSUIntScrub(csJIPListLU_WhiteList)+') and '+
                  '(JIPL_Keep_b ='+gaJCon[0].sDBMSBoolScrub(false)+') and '+
                  '(JIPL_Created_DT  <= '+gaJCON[0].sDBMSDateScrub(dtAddDays(now, grJASConfig.u2WhitelistDaysUntilExpire*-1))+')'
                  ,gaJCon[0],2016032210
                );
                if not bOk then
                begin
                  JLog(cnLog_ERROR, 2016032211, 'Expiring old whitelisted IPs the Query Failed: '+saQry, SOURCEFILE);
                end;

                if bOk and rs.movefirst then
                begin
                  repeat
                    if not bDeleteRecord(gaJCon[0],'jiplist','JIPL','JIPL_JIPList_UID='+gaJCon[0].sDBMSUIntScrub(rs.Get_saValue('JIPL_JIPList_UID')),201603022229) then
                    begin
                      JLog(cnLog_ERROR, 2016032212, 'Expiring old whitelisted IPs the dbtools call to delete the record came back false.', SOURCEFILE);
                    end;
                  until not rs.movenext;
                end;
                rs.close;
              end;
              //============== Expire WhiteListed IP's ========================





              //============== Expire InvalidLogins IP's ========================
              if grJASConfig.bInvalidLoginsExpire then
              begin
                bOk:=rs.Open(saQry+
                  '(JIPL_IPListType_u ='+gaJCon[0].sDBMSUIntScrub(cnJIPListLU_InvalidLogin)+') and '+
                  '(JIPL_Keep_b ='+gaJCon[0].sDBMSBoolScrub(false)+') and '+
                  '(JIPL_Created_DT  <= '+gaJCON[0].sDBMSDateScrub(dtAddDays(now, grJASConfig.u2InvalidLoginsDaysUntilExpire*-1))+')'
                  ,gaJCon[0],2016032210
                );
                if not bOk then
                begin
                  JLog(cnLog_ERROR, 2016032211, 'Expiring old Invalid Login IPs the Query Failed: '+saQry, SOURCEFILE);
                end;

                if bOk and rs.movefirst then
                begin
                  repeat
                    if not bDeleteRecord(gaJCon[0],'jiplist','JIPL','JIPL_JIPList_UID='+gaJCon[0].sDBMSUIntScrub(rs.Get_saValue('JIPL_JIPList_UID')),201603022233) then
                    begin
                      JLog(cnLog_ERROR, 2016032212, 'Expiring old Invalid Login IPs the dbtools call to delete the record came back false.', SOURCEFILE);
                    end;
                  until not rs.movenext;
                end;
                rs.close;
              end;
              //============== Expire InvalidLogins IP's ========================
            end;
          end;

          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
          //============ HOUSE KEEPING WHEN LISTENER HAS NO DATA ==============
        end;
      end
      else
      begin
        JASPrintLn('FIRE OFF INTERNAL JOB');
        // FIRE OFF Internal Job
        //self.CSECTION.Enter;
        Worker.start;
        Worker:=nil;
        //self.CSECTION.Leave;
      end;
    end
    else
    begin
      //ASPrintln('All '+inttostr(length(aWorker))+' worker threads are busy.');
    end;
  end;// if Server Shutting down
  rs.destroy;rs:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102391,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================


//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  TEMP_CYCLE_LISTENSOCK:=nil;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
