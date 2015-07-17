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
// Tests Jegas' Thread Manager
program test_ug_threadmgr02;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_ug_threadmgr02.pas'}
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
  TMI: rtThreadManagerInit;
  JTI: rtJThreadInit;

  s1: TJThread;
  s2: TJThread;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  with TMI.rMainJtMsgFifoInit do begin
    iAllocationSize:=1;
    iInitialNoOfAllocationUnits:=1;
    bAddAllocationUnitsWhenFIFOFull:=false;
    bAutoNumberUIDField:=true;
    bAutoRecordDateNTimeInSentField:=true;
  end;
  InitThreadManager(TMI);
  
  with JTI do begin
    bCreateJThreadMessageQueue:=true;
    with rJTMsgFifoInit do begin
      iAllocationSize:=1;
      iInitialNoOfAllocationUnits:=1;
      bAddAllocationUnitsWhenFIFOFull:=false;
      bAutoNumberUIDField:=true;
      bAutoRecordDateNTimeInSentField:=true;
    end;
    bCreateCriticalSection:=true;
    iResendRetries:=0;
    iResendRetryDelayMSec:=0;
    bCanHaveChildren:=true;
    lpParentThread_or_Nil:=nil;
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;
  s1:=TJThread.create(JTI);
  
  with JTI do begin
    bCreateJThreadMessageQueue:=true;
    with rJTMsgFifoInit do begin
      iAllocationSize:=1;
      iInitialNoOfAllocationUnits:=1;
      bAddAllocationUnitsWhenFIFOFull:=false;
      bAutoNumberUIDField:=true;
      bAutoRecordDateNTimeInSentField:=true;
    end;
    bCreateCriticalSection:=true;
    iResendRetries:=0;
    iResendRetryDelayMSec:=0;
    bCanHaveChildren:=false;
    lpParentThread_or_Nil:=pointer(s1);
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;
  s2:=TJThread.create(JTI);



  try
    writeln('About to enter CSection');
    s1.CSection.Enter;
    writeln('Back from CSection.Enter');
    writeln('s1.JTMSGFIFO Max Messages in Queue Reached:',s1.JTMSGFIFO.MaximumNumberOfItemsReached);
    writeln('s1.JTMSGFIFO Max # Allocated Units Reached:',s1.JTMSGFIFO.MaximumNumberOfUnitsAllocated);
    writeln('s1.JTMSGFIFO SendFailures:',s1.JTMSGFIFO.SendFailures);
  finally
    writeln('Calling CSection.Leave');
    s1.CSection.leave;
    writeln('Back from CSection.Leave');
  end;
  
  readln;
  s2.terminate;
  
  
  writeln('calling s1.terminate');
  s1.terminate;
  writeln('back from calling s1.terminate');
    
  write('Killing Down Parent...');
  while not s1.bShuttingDown do 
  //while not s1.bOkToDestroy do
  begin
    writeln('s1.Children.N:',s1.Children.N);
    //writeln('s1.DEBUGXDL ptr:',cardinal(s1.DEBUGXDL));
    yield(1000);
  end;
  write('Parent Said Last Words...');
  while not s1.bOkToDestroy do Yield(10);
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

