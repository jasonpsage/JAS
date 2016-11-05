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
  JTI: rtJThreadInit;

  s1: TJThread;
  s2: TJThread;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  InitThreadManager;
  
  with JTI do begin
    bCreateCriticalSection:=true;
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;
  s1:=TJThread.create(JTI);
  
  with JTI do begin
    bCreateCriticalSection:=true;
    bLoopContinuously:=true;
    bCreateSuspended:=false;
    InitialPriority:=tpNormal;
  end;
  s2:=TJThread.create(JTI);



  try
    writeln('About to enter CSection');
    s1.CSection.Enter;
    writeln('Back from CSection.Enter');
  finally
    writeln('Calling CSection.Leave');
    s1.CSection.leave;
    writeln('Back from CSection.Leave');
  end;
  writeln('Press ENTER:');
  readln;
  s2.terminate;
  
  
  writeln('calling s1.terminate');
  s1.terminate;
  writeln('back from calling s1.terminate');
    
  write('Killing Down Parent...');
  while not s1.bShuttingDown do 
  //while not s1.bOkToDestroy do
  begin
    //writeln('s1.DEBUGXDL ptr:',cardinal(s1.DEBUGXDL));
    yield(1000);
  end;
  s1.destroy;
  writeln('Parent Dead!');
  writeln('Done ThreadManager');
  DoneThreadManager;
  Writeln('Cool!');
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

