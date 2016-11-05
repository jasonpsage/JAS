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
{ }
// Tests Jegas' thread manager class.
program test_ug_threadmgr;
//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_ug_threadmgr.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{$IFDEF DEBUGLOGBEGINEND}
{$INFO | DEBUG FEATURE: DEBUGLOGBEGINEND}
{$ENDIF}
//=============================================================================



//=============================================================================
uses 
//=============================================================================
{$IFDEF LINUX}
cthreads,
{$ENDIF}
classes
,sysutils
,ug_common
,ug_jegas
,ug_jfc_threadmgr
;

var 
JTI: rtJThreadInit;


s1: TJThread;
t: Array of TJThread; 
sa: ansistring;
iThreads: integer;
i: integer;
iKilled:integer;
iKilledBefore:integer;
begin
  InitThreadManager;
  
  iKilled:=0;
  iKilledBefore:=0;
  repeat
    write('Enter # Threads, Start Small, or it could take awhile. (1-5000):');
    readln(sa);
    ithreads:=iVal(sa);
  until (iThreads>=1) and (ithreads<=5000);


  write('Create Parent...');
  with JTI do begin
    bCreateCriticalSection:=true;
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;
  s1:=TJThread.create(JTI);
  writeln('Done');

  
  setlength(t,iThreads);
  write('Creating your ',iThreads,' threads...');
  with JTI do begin
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;

  for i:=1 to iThreads do
  begin
    t[i-1]:=TJThread.create(JTI);
  end;
  writeln('Done.');

  Writeln('Running Threads and randomly shutting them down.');
  repeat
    //write('yield');
    yield(1);
    i:=random(iThreads)+1;    
    if (i>=1) and (i<=ithreads)then
    begin
      t[i-1].terminate;
      iKilled+=1;
    end;      
    if(iKilled<>iKilledBefore)then 
    begin
      write(saRepeatChar(#8,80));
      Write('Left to Kill:',ithreads-iKilled,'   ');
    end;
    iKilledBefore:=iKilled;
    
  until iKilled=iThreads;
  writeln;
  writeln('All Threads terminated Properly. Allowing "Settle Time" for Parent.');
  writeln('just to get good FIFO Metrics.');

  s1.terminate;
  
  write('Killing Down Parent...');
  while not s1.bShuttingDown do yield(10);
  s1.destroy;
  writeln('Parent Dead!');
  DoneThreadManager;
  writeln('Done ThreadManager');
  Writeln('Cool!');
end. 
