
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
// Jegas Core is the Main System Layer Below UI Level. It is a wrapper for all
// DATA COMING IN AND OUT OF its managed connections.
Unit uj_core;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_core.pp'}
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
  {$INFO | DEBUGTHREADBEGINEND: TRUE }
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
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_threadmgr
,ug_tsfileio
,ug_jado
,uj_definitions
,uj_worker
,uj_listener
,uj_config
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
// This function is the main entry point for JAS. 
Function bJAS_Run:Boolean;
//=============================================================================

















//=============================================================================
//procedure ExecuteJASApplication(p_Context: TCONTEXT);
//=============================================================================

//=============================================================================
{}
// This CLASS isn't finished yet, but wil be THE container for each vHOST
// So each vhost is self contained.
//Type THOST=class(JFC_DLITEM) 
//=============================================================================
//  ALIAS_MATRIX: JFC_MATRIX;
//  csLOG: TCriticalSection;
//  constructor create;
//  Destructor Destroy; override;
//end;
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
procedure showthreads;
//=============================================================================
var 
  i,iidle: longint;

  Wrkr: TWORKER;
  bShowThreadReport: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='showthreads;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  try
    JASPrintln('Show threads...');
    gListener.CSECTION.Enter;
    Wrkr:=gListener.Worker;
    JASPrintln('ThreadpoolNoOfThreads:'+inttostr(grJASConfig.iThreadPoolNoOfThreads));
    JASPrintln('FreeFileHandles:'+inttostr(iTSFileHandlesLeft));
    JASPrintln('Worker On deck (0=none):'+inttostr(UINT(Wrkr)));
    JASPrintLn('Worker Threads: '+inttostr(length(aworker)));
    iIdle:=0;
    for i:=0 to length(aWorker)-1 do 
    begin    
      Wrkr:=aWorker[i];
      bShowThreadReport:=false;
      if(Wrkr.suspended)then
      begin
        iIdle+=1;
      end
      else
      begin
        bShowThreadReport:=true;
      end;

      
      if bShowthreadreport then 
      begin
        Wrkr.DEBUGCS.Enter;
        JASPrintln('Thread #'+inttostr(wrkr.uid)+' Time:'+inttostr(iDiffMSec(Wrkr.dtExecuteBegin,now))+
                   ' Suspended:'+saTrueFalse(Wrkr.suspended)+' Stage: '+inttostr(WrKr.i8Stage));
        JASPrintln('Thread #'+inttostr(wrkr.uid)+' Note: '+WrKr.saStageNote);
        Wrkr.DEBUGCS.Leave;
        {$IFDEF DEBUGTHREADBEGINEND}
        //if Wrkr.DEBUGCS<>nil then
        //begin
        //  try
        //    WrKr.DEBUGCS.Enter;
        //    JASPrintln('Debug List DBXXDL - start list:');
        //    if(WrKr.DBXXDL.MoveFirst)then
        //    begin
        //      repeat
        //        JASPrintLn('THREAD#:'+inttostr(gListener.Children.N)
        //          +' '+inttostr(WrKr.DBXXDL.Item_i8User)
        //          +' '+WrKr.DBXXDL.Item_saName
        //          +' '+WrKr.DBXXDL.Item_saDesc
        //          
        //        );
        //      until not WrKr.DBXXDL.MoveNext;
        //    end
        //    else
        //    begin
        //      JASPrintln('Debug List DBXXDL is empty.');
        //    end;
        //  finally
        //    WrKr.DEBUGCS.Leave;  
        //  end;
        //end
        //else
        //begin
        //  JASPrintln('Wrkr.DEBUGCS = nil');    
        //end;
        {$ENDIF}
      end;
    end;
  finally
    gListener.CSECTION.Leave;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
procedure showworkerthreads;
//=============================================================================
var i: longint;

{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='showworkerthreads';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  try  
    //CSECTION_MAINPROCESS.Enter;
    for i:=0 to length(aWorker)-1 do 
    begin
      JASPrint('Thread UID:'+inttostr(aWorker[i].UID)+' ');
      if aWorker[i].DEBUGCS<>nil then
      begin
        aWorker[i].DEBUGCS.Enter;
        JASPrint('Stage:'+inttostr(aWorker[i].i8Stage)+' ');
        JASPrint('StageNote:'+aWorker[i].saStageNote+' ');
        JASPrint('Suspended: '+saYesNo(aWorker[i].suspended)+' ');
        JASPrint('Finished: '+saYesNo(aWorker[i].bFinished)+' ');
        aWorker[i].DEBUGCS.Leave;
      end
      else
      begin
        JASPrint('Thread DEBUGCS = nil ');
      end;
      jasprintln('');
    end;
    
  finally
    //CSECTION_MAINPROCESS.Leave;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
Procedure ShowJASConfigRecord;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ShowJASConfigRecord;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  with grJASConfig do begin
    JASPrintln('BEGIN--- JAS Config --');
    JASPrintln('saServerName:'+saServerName);
    JASPrintln('saServerIdent:'+saServerIdent);
    JASPrintln('saServerSoftware:'+saServerSoftware);
    //JASPrintln('saDefaultPage:'+saDefaultPage);
    //JASPrintln('saDefaultArea:'+saDefaultArea);
    //JASPrintln('saDefaultSection:'+saDefaultSection);
    JASPrintln('iLogLevel:'+inttostr(iLogLevel));
    JASPrintln('bLogMessagesShowOnServerConsole:'+saTRueFalse(bLogMessagesShowOnServerConsole));
    JASPrintln('iThreadPoolNoOfThreads:'+inttostr(iThreadPoolNoOfThreads));
    JASPrintln('iThreadPoolMaximumRunTimeInMSec:'+inttostr(iThreadPoolMaximumRunTimeInMSec));
    JASPrintln('saSysDir:'+saSysDir);
    JASPrintln('saWebShareAlias:'+saWebShareAlias);
    JASPrintln('saConfigDir:'+saConfigDir);
    JASPrintln('saConfigFile:'+saConfigFile);
    JASPrintln('saDBCFileName:'+saDBCFileName);
    //JASPrintln('saTemplatesDir:'+saTemplatesDir);
    JASPrintln('iSessionTimeOutInMinutes:'+inttostr(iSessionTimeOutInMinutes));
    JASPrintln('iLockTimeOutInMinutes:'+inttostr(iLockTimeOutInMinutes));
    JASPrintln('iLockRetriesBeforeFailure:'+inttostr(iLockRetriesBeforeFailure));
    JASPrintln('iLockRetryDelayInMSec:'+inttostr(iLockRetryDelayInMSec));
    JASPrintln('u1PasswordKey: '+inttostr(u1PasswordKey));
    JASPrintln('iValidateSessionRetryLimit:'+inttostr(iValidateSessionRetryLimit));
    JASPrintln('saDefaultLanguage:'+saDefaultLanguage);
    JASPrintln('saCacheDir:'+saCacheDir);
    JASPrintln('saServerIP:'+saServerIP);
    JASPrintln('u2ServerPort:'+inttostr(u2ServerPort));
    JASPrintln('bDeleteLogFile:'+satruefalse(bDeleteLogFile));
    JASPrintln('saPHP:'+saPHP);
    JASPrintln('saPerl:'+saPerl);
    JASPrintln('iTIMEZONEOFFSET:'+inttostr(iTIMEZONEOFFSET));
    JASPrintln('iErrorReportingMode:'+inttostr(iErrorReportingMode));
    JASPrintln('saErrorReportingSecureMessage:'+saErrorReportingSecureMessage);
    JASPrintln('iDebugMode:'+inttostr(iDebugMode));
    JASPrintln('bServerConsoleMessagesEnabled:'+satruefalse(bServerConsoleMessagesEnabled));
    JASPrintln('bDebugServerConsoleMessagesEnabled:'+satruefalse(bDebugServerConsoleMessagesEnabled));
    JASPrintln('i8MaximumRequestHeaderLength:'+inttostr(i8MaximumRequestHeaderLength));
    JASPrintln('iRetryLimit:'+inttostr(iRetryLimit));
    JASPrintln('iRetryDelayInMSec:'+inttostr(iRetryDelayInMSec));
    JASPrintln('iCreateSocketRetry:'+inttostr(iCreateSocketRetry));
    JASPrintln('iCreateSocketRetryDelayInMSec:'+inttostr(iCreateSocketRetryDelayInMSec));
    JASPrintln('iSocketTimeOutInMSec:'+inttostr(iSocketTimeOutInMSec));
    JASPrintln('iMaxFileHandles:'+inttostr(iMaxFileHandles));
    //JASPrintln('saMenuTemplateFilename:'+saMenuTemplateFilename);
    //JASPrintln('saMenuTemplate:'+saMenuTemplate);
    JASPrintln('saLogDir:'+saLogDir);
    JASPrintln('u1SessionKey: Not Disclosed');
    JASPrintln('bBlacklistEnabled:'+saTrueFalse(bBlacklistEnabled));
    JASPrintln('bWhiteListEnabled:'+saTrueFalse(bWhiteListEnabled));
    JASPrintln('bEnableSSL:'+saTrueFalse(bEnableSSL));
    JASPrintln('saFileDir:'+saFileDir);
    JASPrintln('saWebshareDir:'+saWebshareDir);
    JASPrintln('bJobQEnabled:'+saTrueFalse(bJobQEnabled));
    JASPrintln('iJobQIntervalInMSec:'+inttostr(iJobQIntervalInMSec));
    JASPrintln('saDiagnosticLogFileName:'+saDiagnosticLogFileName);
    JASPrintln('saJASFooter:'+saJASFooter);
    JASPrintln('u8DefaultTop_JMenu_ID:'+inttostr(u8DefaultTop_JMenu_ID));
    JASPrintln('saJASDirTheme:'+saJASDirTheme);
    JASPrintln('saThemeDir:'+saThemeDir);
    //ASPrintln('saDefaultTheme:'+saDefaultTheme);
    //ASPrintln('saDefaultThemeName:'+saDefaultThemeName);
    //ASPrintln('saDefaultThemeAuthor:'+saDefaultThemeAuthor);
    //ASPrintln('u8DefaultThemeRenderMethod:'+inttostr(u8DefaultThemeRenderMethod));
    JASPrintln('END  --- JAS Config --');
  end;// with 
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
Procedure ShowJASTableMatrix;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ShowJASTableMatrix';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if gaJCon[0].JASTABLEMATRIX.Movefirst then
  begin
    repeat
      with gaJCon[0].JASTABLEMATRIX do begin
        JASprintln(inttostr(iNth)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(1)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(2)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(3)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(4)+' '
        );
      end;//with
    until not gaJCon[0].JASTABLEMATRIX.MoveNext;
  end
  else
  begin
    JASPrintln(' -- No Tables in JAS TABLE MATRIX -- ');
  end;
  JASPrintln(' -- JAS TABLE MATRIX -- ');
  with gaJCon[0].JASTABLEMATRIX do begin
    JASPrint(' OrigMTX: ');
    if OrigMTX=nil then JASPrintln('nil') else JASPrintln(inttostr(UINT(OrigMTX)));
    JASPrintln(' iCols: '+inttostr(iCols));
    JASPrintln(' iRows: '+inttostr(iRows));
    JASPrintln(' iNth: '+inttostr(iNth));
    JASPrintln(' length(asaColumns): '+ inttostr(length(asaColumns)));
    JASPrintln(' length(asaMatrix): '+ inttostr(length(asaMatrix)));
    JASPrintln(' ListCount: '+ inttostr(ListCount));
    JASPrintln(' bIsCopy: '+ saTrueFalse(bIsCopy));
    JASPrintln(' -- JAS TABLE MATRIX -- ');
  end;//with
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
Procedure ShowJASConnections;
//=============================================================================
var i: longint;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ShowJASConnections';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if length(gaJCon)=0 then
  begin
    JASPrintLn('ZERO Connections. Nothing to display.');
  end
  else
  begin
    for i:=0 to length(gaJCon)-1 do begin
      JASPrintLn(
        'ID: '+gaJCon[i].ID+
        ' DB: '+gaJCon[i].saDatabase+
        //' State: '+ JADO.saObjectState(gaJCon[i].i4State)+
        ' Name: '+gaJCon[i].saName+
        ' Server: '+gaJCon[i].saServer+
        ' User: '+gaJCon[i].saUserName+
        ' Connected: '+saTRuefalsE(gaJCon[i].bConnected)
      );
    end;
  end;    
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
Procedure ClearJASConsole;
//=============================================================================
var i: longint;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ClearJASConsole';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  for i:=0 to 80 do begin
    JASPrintLn('');
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
procedure WriteCLIHelp;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='WriteCLIHelp';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  writeln('---------------------------------------------------------------------');
  writeln('JAS Console HELP - Note: Only first letter of command required.');
  writeln('---------------------------------------------------------------------');
  writeln('Clear    : Clear Console - via line-feeds');
  Writeln('Databases: Database Connections');
  writeln('Jegas    : Jegas, LLC Logo');
  Writeln('Logging  : Logging Statistics');
  Writeln('Matrix   : Show JASTABLEMATRIX contents');
  Writeln('Quit     : Shut JAS Server Down.');
  Writeln('Restart  : Cycle JAS Server');
  Writeln('Setup    : Show JAS Configuration details.');
  Writeln('Threads  : Show diagnostic information worker threads.');
  Writeln('Workers  : Show worker thread status information');
  writeln('---------------------------------------------------------------------');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
Procedure ShowLoggingStatus;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='LoggingStatus';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  with grJegasCommon.rJegasLog do begin
    writeln('Total      : ',iLogEntries_Total);//< Total count, incremented each time a specific log is written to
    writeln('Generic    : ',iLogEntries_NONE);//<DEFAULT LOGGING LEVEL
    writeln('Debug      : ',iLogEntries_DEBUG);//< 1
    writeln('Fatal      : ',iLogEntries_FATAL);//< 2
    writeln('Errors     : ',iLogEntries_ERROR);//< 3
    writeln('Warnings   : ',iLogEntries_WARN);//< 4
    writeln('Information: ',iLogEntries_INFO);//< 5
    writeln('Reserved   : ',iLogEntries_RESERVED);//< 6   RESERVED by JEGAS 6 thru 99}
    writeln('User Def   : ',iLogEntries_USERDEFINED);//< 100  USER CODES 100 thru 255}
    if Int64(dtLogEntryFirst)<>0 then
    begin
      writeln('First Entry: ',FormatDateTime(csDATETIMEFORMAT,dtLogEntryFirst));// : TDATETIME; //< per invocation
      writeln('Last Entry : ',FormatDateTime(csDATETIMEFORMAT,dtLogEntryLast));// : TDATETIME; //< per invocation
    end;
  end;//with
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================








//=============================================================================
Function needStop(p: pointer): INT;
//=============================================================================
label top;
Var
  str: AnsiString;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='needStop(p: pointer): INT;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}


top:
  repeat
    str:='';
    readln(str);str:=UpCase(trim(str));
    STR:=Leftstr(str,1);
    if (str='H') or (str='?') then
    begin
      WriteCLIHelp;
    end else 

    If (str = 'Q') Then gbServerShuttingDown := True else 

    If(str='T')Then
    Begin
      Showthreads;
      //WriteCLIHelp
    End else

    If(str='W')Then
    Begin
      showworkerthreads;
      //WriteCLIHelp
    End else 

    if(str='S') then //setup
    begin
      ShowJASConfigRecord;
      //WriteCLIHelp
    end else 

    if(str='M') then
    begin
      ShowJASTableMatrix;
      //WriteCLIHelp
    end else 

    if(str='D') then
    begin
      ShowJASConnections;
      //WriteCLIHelp
    end else 

    if(str='C') then
    begin
      ClearJASConsole;
    end else 


    if(str='J') then
    begin
      JASPrint(saJegasLogoRawText(csCRLF,true));
    end else 

    if(str='L') then
    begin
      ShowLoggingStatus;
      //WriteCLIHelp;
    end else 

    if(str='R')then
    begin
      Writeln('!!!Restart Cycle Request Received!!!');
      gbServerCycling:=true;
    end;
    //write('Yield...');
    //Yield(100);
    //writeln('done yield.');
  Until gbServerShuttingDown or gbServerCycling;
  repeat
    yield(1000);
  until not (gbServerShuttingDown or gbServerCycling);
  goto top;
  result:=0;  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
End;
//=============================================================================































  


//=============================================================================
function bJAS_MainLoop: boolean;
//=============================================================================
{$IFDEF ROUTINENAMES}var  sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJAS_MainLoop';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  while (gbServerShuttingDown = FALSE) and (gbServerCycling=false) do begin
    Yield(100);
  end;
  result:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================





//=============================================================================
Function bJAS_Run:Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='bJAS_Run';
{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //DateSeparator := '.';
  //ShortDateFormat := 'd.m.yy';
  //LongDateFormat := 'yyyy-mm-dd hh:nn:ss';


  TEMP_CYCLE_LISTENSOCK:=nil;//located in uj_listener.pp
  gbServerCycling:=false;
  repeat
    gbServerShuttingDown:=false;
    InitJASConfigRecord;
    BeginThread(@needStop, nil);  

    bOk:=bJAS_Init;
    if(bOk=false) then 
    begin
      JASPrintln('!! Error(s) Reported by Core_Init !!');
    end;
    
    gbServerCycling:=false;
    
    If bOk Then
    Begin
      bOk:=bJAS_MainLoop; //-------------- MAIN LOOP  2
      if(bOk=false) then JASPrintln('!! Error(s) Reported by Core_MainLoop !!');
    End;
    
    if(bOk) then
    begin
      bOk:=bJAS_ShutDown; //--- SHUT DOWN  3
      if(bOk=false)then JASPrintln('!! Error(s) Reported by Core_ShutDown !!');
    end;    
  until gbServerCycling=false;
  Result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
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

//*****************************************************************************
// eof
//*****************************************************************************
