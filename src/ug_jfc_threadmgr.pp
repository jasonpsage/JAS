{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  Jason@jegas.com             |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|         Virtually Everything IT(tm)                                         |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// For Writing Multi-Threaded Applications
Unit ug_jfc_threadmgr;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_threadmgr.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
{$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE DEBUGTHREADBEGINEND} // used for thread debugging, like begin and end sorta
                             // showthreads shows the threads progress with this.
                             // whereas debuglogbeginend is ONE log file for all.
                             // a bit messy for threads.
{$IFDEF DEBUGTHREADBEGINEND}
{$INFO | DEBUGTHREADBEGINEND: TRUE}
{$ENDIF}


{DEFINE JLOGSPECIFICCLASSNAME:='TWORKER'}
{$IFDEF JLOGSPECIFICCLASSNAME}
{$INFO | JLOG DEBUG SPECIFIC CLASSNAME: TRUE}
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
uses 
//=============================================================================
classes
,syncobjs
,ug_common
,ug_jegas
,ug_jfc_fifo
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_tsfileio
,sysutils;
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
// JThread StartUpParameters
type rtJThreadInit=record
//=============================================================================
{}
  // This is a way the user making a thread can mark them uniquely. This 
  // DBIN and DBOUT thread filenames.
  UID: int64;

  // For individual thread Critical section control 
  bCreateCriticalSection: boolean;

  
  {}
  // TRUE - Then the thread's main execute loop will 
  // loop nonstop, calling your ExecuteMyThread procedure repeatedly for the
  // life of the thread. 
  //
  // FALSE - makes the thread Call ExecuteMyThread,
  // and the JTParent code (Message Dispatch/HouseKeeping) and then suspends
  // itself.  If this option is set, then it is up to another thread or the 
  // main process to reawaken the thread for another go around. 
  bLoopContinuously: boolean; 

  bCreateSuspended: Boolean;  
  
  // when the thread is created, the constructor will set the thread's priorirty 
  // to the value passed here. Usually tpNormal is what you want.
  // Valid Values:
  //   tpIdle - Thread only runs when other processes are idle.
  //   tpLowest - Thread runs at the lowest priority.
  //   tpLower - Thread runs at a lower priority.
  //   tpNormal - Thread runs at normal process priority.
  //   tpHigher - Thread runs at high priority
  //   tpHighest - Thread runs at highest possible priority.
  //   tpTimeCritical - Thread runs at realtime priority.
  InitialPriority: TThreadPriority;
end;
//=============================================================================




//=============================================================================
// Multi-threading considerations
//=============================================================================
{}
// TCriticalSection in syncobjs unit.
// Create, Destroy. Enter, Leave.
var 
  CSECTION_MAINPROCESS: TCriticalSection;
  CSECTION_FILEREADMODEFLAG: TCriticalSection;
procedure InitThreadManager;
procedure DoneThreadManager;
//=============================================================================




//=============================================================================
{}
// This class is a descendant of FreePascal's RTL TThread 
type TJThread=class(TThread)
//=============================================================================
 
  public DEBUGCS:TCriticalSection;
  {$IFDEF DEBUGTHREADBEGINEND}
  //public DBXXDL: JFC_XXDL;
  public procedure DBIN(p_i8Code: int64; p_saFunction: ansistring; p_saSourceFile: ansistring);
  public procedure DBOUT(p_i8Code: int64; p_saFunction: ansistring; p_saSourcefile: ansistring);
  public iNestLevel: integer;
  {$ENDIF}
  
  // Used by TrackThread
  public i8Stage:int64;
  // Used by TrackThread
  public saStageNote: ansistring;
  
  public CSECTION: TCriticalSection;
  
  {}
  // Unique Identifier (user set) 
  public UID: int64;


  lpParent: TJThread;
  iExecuteIterations: integer;//< # times ExecuteMyThread Called.
  dtCreated: TDateTime;//< when this class was created
  dtExecuteBegin: TDateTime;
  dtExecuteEnd: TDateTime;
  
  bShuttingDown: boolean;//< Means Main Execute Loop Acknowleded the Termination.
  
  bLoopContinuously: Boolean;

  bFinished: boolean;//set true only after executethread completes
  
  Protected procedure OnCreate;virtual;
  public Constructor create(p_rJThreadInit: rtJThreadInit);//< STOCK TTHread
  procedure Execute; override;//< STOCK TTHread
  procedure Terminate;//< STOCK TTHread
  
  
  
  public procedure ExecuteMyThread;virtual;
  protected procedure OnTerminate;virtual;
  
  // Prepared Variables for a New Firing of the thread.
  // Note: You want to override this. Note its called AFTER each Execute my
  // thread, AND in the constructor. This is to make it so if thhe thread has 
  // a lot of initialization, its "ready to go" when you fire it off, does its
  // task, then setups for the next go around. Seems more efficient then
  // waiting for init code at the start of each "FIRING" of the thread.  
  public procedure ResetThread; virtual;
  

  {}
  // Used for a light weight debugging tool - in favor of DBIN/DBOUT
  // for thread management. This allows uniquely marking where in code
  // individual threads managed to get to to help track down problems.
  public procedure trackthread(p_i8Stage: int64; p_saStageNote: ansistring);
end;
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


var pvt_bThreadManagerInitialized:boolean;

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================

//=============================================================================
procedure InitThreadManager;
//=============================================================================
begin
  if not pvt_bThreadManagerInitialized then 
  begin
    CSECTION_MAINPROCESS:=TCriticalSection.Create();
    CSECTION_FILEREADMODEFLAG:=TCriticalSection.Create();
    pvt_bThreadManagerInitialized:=true;
  end;
end;
//=============================================================================

//=============================================================================
procedure DoneThreadManager;
//=============================================================================
begin
  if pvt_bThreadManagerInitialized then 
  begin
    CSECTION_MAINPROCESS.Destroy;CSECTION_MAINPROCESS:=nil;
    CSECTION_FILEREADMODEFLAG.Destroy;CSECTION_FILEREADMODEFLAG:=nil;
    pvt_bThreadManagerInitialized:=false;
  end;
end;
//=============================================================================



//=============================================================================
procedure TJThread.TrackThread(p_i8Stage: int64; p_saStageNote: ansistring);
//=============================================================================
begin
  DEBUGCS.Enter;
  i8Stage:=p_i8Stage;
  saStageNote:=p_saStageNote;
  DEBUGCS.Leave;
end;
//=============================================================================





//=============================================================================
procedure TJThread.OnCreate;
//=============================================================================
begin
  //riteln('in default TJTHREAD.oncreate');
end;
//=============================================================================

//=============================================================================
Constructor TJThread.create(p_rJThreadInit: rtJThreadInit);
//=============================================================================
begin

  dtCreated:=now;// when this class was created
  //riteln('TJThread.create(p_rJThreadInit: rtJThreadInit)');
  DEBUGCS:=TCriticalSection.Create;
  DEBUGCS.Enter;
  i8Stage:=0;
  saStageNote:='';
  DEBUGCS.Leave;
  
  {$IFDEF DEBUGTHREADBEGINEND}
  iNestLevel:=0;
  {$ENDIF}

  iExecuteIterations:=0;
  bFinished:=false;
  if p_rJThreadInit.bCreateCriticalSection then 
  begin
    CSECTION:=TCriticalSection.Create;
  end
  else
  begin
    CSECTION:=nil;
  end;
  //riteln('Past CriticalSection init');


  bLoopContinuously:=p_rJThreadInit.bLoopContinuously;

  bShuttingDown:=false;
  FreeOnTerminate:=false;
  UID:=p_rJThreadInit.UID;
  
  //riteln('jthread calling oncreate virt func');
  OnCreate;
  //riteln('jthread back from calling oncreate virt func');

  //riteln('call Inherited Create');
  inherited Create(p_rJThreadInit.bCreateSuspended);
  //riteln('Past Inherited Create');
  
end;
//=============================================================================


{$IFDEF DEBUGTHREADBEGINEND}
//=============================================================================
procedure TJTHREAD.DBIN(p_i8Code: int64; p_saFunction: ansistring; p_saSourceFile: ansistring);
//=============================================================================
var f: text;
    saFilename: ansistring;
begin
  //riteln('DBIN-->',p_saFunction,' ',p_i8Code);
  //try
  //  DEBUGCS.Enter;
  //  DBXXDL.AppendItem_saName_N_saDesc(p_saFunction,p_saSourceFile);
  //  DBXXDL.Item_i8User:=p_i8Code;
  //  DBXXDL.Item_DT:=now;
  //finally
  //  DEBUGCS.Leave;
  //end;
  TrackThread(p_i8Code,'DBIN: '+p_saFunction+' '+p_saSourceFile);
  
  self.iNestLevel+=1;
  safilename:=grJASCOnfig.saLogDir + 'TJTHREAD_'+inttostr(UID) + '_'+inttostr(UINT(self))+'.txt';
  try
    CSECTION_FILEREADMODEFLAG.Enter;
    FileMode:=READ_WRITE;
    {$I-}
    assign(f,safilename);
    {$I+}
    if(fileexists(safilename)) then 
    begin
    {$I-}
      append(f);
    {$I+}
    end
    else
    begin
    {$I-}
      rewrite(f);
    {$I+}
    end;
  finally
    CSECTION_FILEREADMODEFLAG.leave;
  end;
  // Don't really care if something changes the FILEMODE flag now because my file is open in the mode I want
  // Of course I could add better IO handling here - like messing with IORESULT... which is again
  // another FREEPASCAL global needing the same special attention. So, because I don't want a huge bottle
  // neck accessing files - I limit the critical bit for the flag switch and the file open.
  // I'm sure there is a better way - but this technique has solved many headaches.
  {$I-}
  writeln(f,p_i8Code,' ',saDebugNest(p_saFunction,true,self.iNestLevel),' ',p_saSourcefile);
  close(f);
  {$I+}
end;
//=============================================================================
{$ENDIF}

{$IFDEF DEBUGTHREADBEGINEND}
//=============================================================================
procedure TJTHREAD.DBOUT(p_i8Code: int64; p_saFunction: ansistring; p_saSourceFile: ansistring);
//=============================================================================
var 
  //dt: TDatetime;
  //itempMSec: integer;
  //iRndRunNo: integer;
  f: text;
  saFilename: ansistring;
begin
  //riteln('DBOUT<--');
  //try
  //  DEBUGCS.Enter;
  //  if DBXXDL.MoveLast then DBXXDL.DeleteItem;
  //finally
  //  DEBUGCS.Leave;
  //end;
  TrackThread(p_i8Code,'DBOUT: '+p_saFunction+' '+p_saSourceFile);

  saFileName:=grJASCOnfig.saLogDir + 'TJTHREAD_'+inttostr(UID) + '_'+inttostr(UINT(self))+'.txt';
  try
    CSECTION_FILEREADMODEFLAG.Enter;
    FileMode:=READ_WRITE;
    {$I-}
    assign(f,safilename);
    if(fileexists(safilename)) then append(f) else rewrite(f);
    writeln(f,p_i8Code,' ',saDebugNest(p_saFunction,false,self.iNestLevel),' ',p_saSourcefile);
    close(f);
    {$I+}
  finally
    CSECTION_FILEREADMODEFLAG.leave;
  end;
  self.iNestLevel-=1;  

end;
//=============================================================================
{$ENDIF}

//=============================================================================
procedure TJThread.ExecuteMyThread;
//=============================================================================
begin
  {$IFDEF DEBUGTHREADBEGINEND}
  DBIN(201202230829,'TJThread.ExecuteMyThread',SOURCEFILE);
  {$ENDIF}
  //riteln('TJThread.ExecuteMyThread FIRED! Pointer:',cardinal(self));
  //Yield(1);
  {$IFDEF DEBUGTHREADBEGINEND}
  DBOUT(201202230829,'TJThread.ExecuteMyThread',SOURCEFILE);
  {$ENDIF}
end;
//=============================================================================




//=============================================================================
procedure TJThread.Execute; 
//=============================================================================
begin
  //asprintln('TJThread.Execute - begin');
  {$IFDEF DEBUGTHREADBEGINEND}
  DBIN(201002031620,'TJThread.Execute',SOURCEFILE);
  {$ENDIF}
  repeat
    if not terminated then 
    begin
      dtExecuteBegin:=now;
      dtExecuteEnd:=0;
      iExecuteIterations+=1;
      //asprintln('TJThread -> executemythread virtual');
      ExecuteMyThread;  
      //asprintln('TJThread <- executemythread virtual');
      dtExecuteEnd:=now;
    end;
    ResetThread;//reset after - but called on create to make sure ready for first run
    // must call resetthread in the decendant class' executemythread
    //asprintln('tjthread.execute loop');
  until terminated or (not bLoopContinuously);
  bFinished:=true;
  {$IFDEF DEBUGTHREADBEGINEND}
  DBOUT(201002031620,'TJThread.Execute',SOURCEFILE);
  {$ENDIF}
  //asprintln('TJThread.Execute - end');
end;
//=============================================================================

//=============================================================================
procedure TJThread.OnTerminate;
//=============================================================================
begin
  {$IFDEF DEBUGTHREADBEGINEND}
  DBIN(201002031624,'TJThread.OnTerminate;',SOURCEFILE);
  {$ENDIF}
  //riteln('tjthread.OnTerminate begin');
  //if(FreeOnTerminate)then
  //begin
  //  riteln('Free on terminate?');
  //end;
  //riteln('tjthread.OnTerminate end');
  {$IFDEF DEBUGTHREADBEGINEND}
  DBOUT(201002031624,'TJThread.OnTerminate;',SOURCEFILE);
  {$ENDIF}
end;
//=============================================================================

//=============================================================================
Procedure TJThread.Terminate;
//=============================================================================
begin


  {$IFDEF JLOGSPECIFICCLASSNAME}
  if self.ClassName=JLOGSPECIFICCLASSNAME then JLog(cnLog_DEBUG,201005021707,'TJThread.Execute Terminated Flag true - shutting thread down',sourcefile);
  {$ENDIF}
  {$IFDEF DEBUGTHREADBEGINEND}
  //DBOUT(201002031621,'TJThread.Execute (repeat Loop)',SOURCEFILE);
  {$ENDIF}

  {$IFDEF DEBUGTHREADBEGINEND}
  //DBIN(201002031623,'TJThread.Execute (Shutting Down Tasks)',SOURCEFILE);
  {$ENDIF}
  bShuttingDown:=true;
  




  //riteln('TJTHREAD.Terminate Begin');
  //riteln('TTHREAD.Terminate Inherited Begin');
  Inherited Terminate;
  //riteln('TTHREAD.Terminate Inherited End');
  
  //riteln('TJTHREAD.OnTerminate Virtual Call begin');
  OnTerminate;
  //riteln('TJTHREAD.OnTerminate Virtual Call end');
  
  

  if CSECTION<>nil then begin CSECTION.Destroy;CSECTION:=nil; end;

  {$IFDEF DEBUGTHREADBEGINEND}
  //DBOUT;
  //try
  //  DEBUGCS.Enter;
  //  DBXXDL.Destroy;DBXXDL:=nil;
  //finally
  //  DEBUGCS.Leave;
  //end;
  DEBUGCS.Destroy;DEBUGCS:=nil;
  {$ENDIF}


  //riteln('TerminateEnd');
end;
//=============================================================================

//=============================================================================
Procedure TJThread.ResetThread; // Prepared Variables for a New Firing of the thread.
// Note: You want to override this. Note its called AFTER each Execute my
// thread, AND in the constructor. This is to make it so if thhe thread has 
// a lot of initialization, its "ready to go" when you fire it off, does its
// task, then setups for the next go around. Seems more efficient then
// waiting for init code at the start of each "FIRING" of the thread.
//=============================================================================
begin
  {$IFDEF DEBUGTHREADBEGINEND}
  DBIN(201002031627,'TJThread.ResetThread',SOURCEFILE);
  {$ENDIF}
  

  {$IFDEF DEBUGTHREADBEGINEND}
  DBOUT(201002031627,'TJThread.ResetThread',SOURCEFILE);
  {$ENDIF}
end;
//=============================================================================


//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  pvt_bThreadManagerInitialized:=false;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
