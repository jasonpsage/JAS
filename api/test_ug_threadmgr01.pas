{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{ }
// Tests Jegas' thread Manager
program test_ug_threadmgr01;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_ug_threadmgr01.pas'}
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
//=============================================================================

//=============================================================================
var
//=============================================================================
  JTI: rtJThreadInit;


  s1: TJThread;
  t: Array of TJThread;
  sa: ansistring;
  iThreads: integer;
  i: integer;
  iKilled:integer;
  iKilledBefore:integer;
//=============================================================================


//=============================================================================
begin
//=============================================================================

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
    bCreateCriticalSection:=true;
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
    write('yield');
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

  yield(1000);
  try
    writeln('About to enter CSection');
    s1.CSection.Enter;
    writeln('Back from CSection.Enter');
  finally
    writeln('Calling CSection.Leave');
    s1.CSection.leave;
    writeln('Back from CSection.Leave');
  end;
  writeln('calling s1.terminate');
  s1.terminate;
  writeln('back from calling s1.terminate');
    
  write('Killing Down Parent...');
  //while not s1.bShuttingDown do 
  write('Parent Said Last Words...');
  while not s1.bshuttingdown do Yield(10);
  writeln('Parent Dead!');
  s1.destroy;
  writeln('Done ThreadManager');
  DoneThreadManager;
  Writeln('Cool!');
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

