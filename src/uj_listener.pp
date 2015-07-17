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
,ug_jegas
,ug_jfc_xdl
,ug_jfc_threadmgr
//,ug_jfc_fifo
,uj_worker
,uj_definitions
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
  procedure OnTerminate; override;
  public
  Procedure ExecuteMyThread; override;
  public
  i4VHostJobQIndex: longint;
  icursorspin: longint;// for text output - diagnostic in nature
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
  Worker:=nil;
  i4VHostJobQIndex:=0;
  iCursorSpin:=0;
  
  ListenSock:=TTCPBlockSocket.create;
  ListenSock.CreateSocket;
  if ListenSock.lasterror <> 0 then writeln('TListen.create(CreateSocket)ListenSock.LastError:'+inttostr(ListenSock.lasterror));
  //ListenSock.setLinger(true,10);
  //if gListener.ListenSock.lasterror <> 0 then writeln('(SetLinger)ListenSock.LastError:'+inttostr(gListener.ListenSock.lasterror));
  
  
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102382,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TLISTEN.OnTerminate;
//=============================================================================

{$IFDEF ROUTINENAMES} var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TLISTEN.OnTerminate;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102383,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102384, sTHIS_ROUTINE_NAME);{$ENDIF}

  //jasprintln('b4 tlisten.onterminate, listensock.destroy');
  //if listensock=nil then jasprintln('listen soc is nil');
  //listensock.destroy;listensock:=nil;
  //jasprintln('after tlisten.onterminate, listensock.destroy');

  
  //ASPrintln('200906272357 - TListen.OnTerminate - FIFO Destroyed Successfully!');
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102385,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
Procedure TLISTEN.ExecuteMyThread;
//=============================================================================
var 
  bOk:boolean;  
  JTI: rtJThreadInit;
 
  {IFDEF LINUX}
  //bGotOne: boolean;  
  {ENDIF}
  i: integer;
//  bValid: boolean;
  bCanRead: boolean;
  //dtNow: TDateTime;
  //iMilliSeconds: integer;
  TempWorker: TWORKER;
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
   

  //ASPrintLn('TLISTEN.ExecuteMyThread');

  {$IFDEF DEBUGTHREADBEGINEND}
  //DBIN(201002030075,'TLISTEN.ExecuteMyThread;', SOURCEFILE);
  {$ENDIF}
  if (gbServerShuttingDown=false) and (gbServerCycling=false) then
  begin
    //ASPrintLn('TLISTEN.Server Not Shutting Down');
    if (Worker=nil)then
    begin
      // hunt for suspended workers first
      for i:=0 to length(aWorker)-1 do 
      begin
        if aWorker[i].Suspended then
        begin
          //asprintln('Found suspended worker');
          worker:=aWorker[i]; bOk:=true;
          break;
        end;
      end;
      
      // if no suspended workers found, make one.
      if worker=nil then
      begin
        for i:=0 to length(aWorker)-1 do
        begin
          if aWorker[i].bFinished then
          begin
            aWorker[i].terminate;
            aWorker[i].destroy;
            //----------------------------------------- make a worker
            //self.CSECTION.Enter;
            with JTI do begin
              bCreateCriticalSection:=false;
              bLoopContinuously:=false;
              bCreateSuspended:=true;
              UID:=imsec;
            end;
            try
              bOk:=false;
              Worker:=TWorker.Create(JTI);   
              Worker.iMyID:=1234;
              aWorker[i]:=Worker;
              bOk:=true;// only stays true if succeeds
            except on E: EThread do JASPrintln('Exception ETHREAD THROWN - 201012191646');
            end;
            break;
          end;
        end; 
      end;
      //self.CSECTION.Leave;
      //----------------------------------------- make a worker
    end;



    if (Worker <> nil) and bOk then
    begin
      //ASPrintLn('Worker Ready');
      if grJASConfig.bJobQEnabled then
      begin
        //ASDebugPrintLn('bJobQEnabled = TRUE');
        self.CSECTION.Enter;
        if iDiffMSec(dtLastInternalJobScan,now)>grJASConfig.iJobQIntervalInMSec then
        begin
          if i4VHostJobQIndex>=length(garJVhostLight) then
          begin
            dtLastInternalJobScan:=now;
            i4VHostJobQIndex:=0;
          end
          else
          begin
            Worker.Context.i4Vhost:=i4VHostJobQIndex;
            i4VHostJobQIndex+=1;
            Worker.CheckJobQ;//This procedure will populate and set the Worker.bInternalJob flag accordingly
          end;
        end;
        self.CSECTION.Leave;
      end;
      
      if not Worker.bInternalJob then
      begin
        //case icursorspin of
        //0: asprint('-');
        //1: asprint('\');
        //2: asprint('|');
        //3: asprint('/');
        //end;//switch
        //iCursorSpin+=1;
        //if icursorspin>3 then icursorspin:=0;

        bCanRead:=ListenSock.canread(1000);//Loops once per second (1000 MSEC) when no requests
        //aSPrint(#8); 
        if bCanRead then
        begin
          self.CSECTION.Enter;
          //ASPrintln('Got Request!');
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
          self.CSECTION.Leave; 
        end
        else
        begin
          //asprintln('2 entering housekeeping, make new workers: '+inttostr(length(aWorker)));
          for i:=0 to length(aWorker)-1 do
          begin 
            if aWorker[i].bFinished then
            begin
              aWorker[i].terminate;
              aWorker[i].destroy;
              //----------------------------------------- make a worker
              //self.CSECTION.Enter;
              with JTI do begin
                bCreateCriticalSection:=false;
                bLoopContinuously:=false;
                bCreateSuspended:=true;
                UID:=imsec;
              end;
              try
                bOk:=false;
                Worker:=TWorker.Create(JTI);   
                Worker.iMyID:=1234;
                aWorker[i]:=Worker;
                bOk:=true;// only stays true if succeeds
              except on E: EThread do JASPrintln('Exception ETHREAD THROWN - 201012191646');
              end;
              break;
            end;    
          end; 
        end;
      end
      else
      begin
        JASPrintLn('FIRE OFF INTERNAL JOB');
        // FIRE OFF Internal Job
        self.CSECTION.Enter;
        Worker.start;   
        Worker:=nil;
        self.CSECTION.Leave; 
      end;
    end
    else
    begin
      //ASPrintln('All '+inttostr(length(aWorker))+' worker threads are busy.');
    end;
  end;// if Server Shutting down
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
