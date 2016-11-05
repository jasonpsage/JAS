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
,uj_locking
,uj_dbtools
,uj_tables_loadsave
,uj_sessions
//,uc_animate
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
  u2Idle: word;
  u2: word;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='showthreads;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  writeln(saRepeatChar('=',40));
  writeln('BEGIN - THREADS (Running or Stuck)');
  writeln(saRepeatChar('=',40));
  try
    JASPrintln('Show threads...');
    gListener.CSECTION.Enter;
    JASPrintln('Listener Note: '+' Suspended:'+sTrueFalse(gListener.suspended)+' Stage: '+inttostr(gListener.u8Stage)+' Note: '+gListener.saStageNote);

    JASPrintln('ThreadpoolNoOfThreads:'+inttostr(grJASConfig.u2ThreadPoolNoOfThreads));
    JASPrintln('FreeFileHandles:'+inttostr(iTSFileHandlesLeft));
    JASPrintln('Worker On deck (0=none):'+inttostr(UINT(gListener.Worker)));
    JASPrintLn('Worker Threads: '+inttostr(length(aworker)));
    u2Idle:=0;
    for u2:=0 to length(aWorker)-1 do
    begin    
      if (aWorker[u2]=nil) or ((aWorker[u2]<>nil)and(aWorker[u2].suspended)) then
      begin
        u2Idle+=1;
      end
      else
      begin
        aWorker[u2].DEBUGCS.Enter;
        JASPrintln('Thread #'+inttostr(aWorker[u2].uid)+' Time:'+inttostr(iDiffMSec(aWorker[u2].dtExecuteBegin,now))+
                   ' Suspended:'+sTrueFalse(aWorker[u2].suspended)+' Stage: '+inttostr(aWorker[u2].u8Stage));
        JASPrintln('Thread #'+inttostr(aWorker[u2].uid)+' Note: '+aWorker[u2].saStageNote);
        JASPrintln('Milliseconds until WE KILL IT: '+inttostr(  grJASConfig.uThreadPoolMaximumRunTimeInMSec-(iDiffMSec(aWorker[u2].dtExecuteBegin,now))));
        aWorker[u2].DEBUGCS.Leave;
      end;
    end;
  finally
    gListener.CSECTION.Leave;
  end;
  writeln(saRepeatChar('=',40));
  writeln('END  (Idle: '+inttostr(u2Idle)+') Max Allowed Runtime per thread is configured at: ',grJASConfig.uThreadPoolMaximumRunTimeInMSec, ' milliseconds.');
  writeln(saRepeatChar('=',40));

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
procedure showworkerthreads;
//=============================================================================
var u2: word;

{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='showworkerthreads';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  try  
    //CSECTION_MAINPROCESS.Enter;
    for u2:=0 to length(aWorker)-1 do
    begin
      if aWorker[u2]<>nil then
      begin
        JASPrint('Worker UID:'+inttostr(aWorker[u2].UID)+' #:'+inttostR(aWorker[u2].uMyId));
        if aWorker[u2].DEBUGCS<>nil then
        begin
          aWorker[u2].DEBUGCS.Enter;
          JASPrint(' Stage:'+inttostr(aWorker[u2].u8Stage)+' ');
          JASPrint('Stage-Note:'+aWorker[u2].saStageNote+' ');
          JASPrint('Suspended: '+sYesNo(aWorker[u2].suspended)+' ');
          JASPrint('Finished: '+sYesNo(aWorker[u2].bFinished)+' ');
          aWorker[u2].DEBUGCS.Leave;
        end
        else
        begin
          JASPrint('Thread DEBUGCS = nil ');
        end;
      end
      else
      begin
        JASPrint('Worker Cubical # '+inttostr(u2)+' is vacant.');
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
var s: string='Press [ENTER] to Continue: '; sLogLvl: string;

  procedure MyPressEnter;
  begin
    JASPrint(s);readln; JASPrintln;
  end;

{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ShowJASConfigRecord;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JASPRintln(saRepeatChar('=',79));
  JASPrintln('BEGIN - JAS Configuration Record');
  JASPRintln(saRepeatChar('=',79));

  with grJASConfig do begin
    JASPrintln('saSysDir............................:'+  saSysDir                            );
    JASPrintln('saPHPDir............................:'+  saPHPDir                            );
    JASPrintln('saPHP...............................:'+  saPHP                               );
    JASPrintln('saPerl..............................:'+  saPerl                              );
    JASPrintln('saJASFooter.........................:'+  saJASFooter                         );
    JASPrintln('u2ThreadPoolNoOfThreads.............:'+  inttostr(u2ThreadPoolNoOfThreads          )   );
    JASPrintln('uThreadPoolMaximumRunTimeInMSec.....:'+  inttostr(uThreadPoolMaximumRunTimeInMSec)     );
    //JASPrintln('sServerURL.........................:'+  sServerURL                         );
    //JASPrintln('sServerName.........................:'+  sServerName                         );
    JASPrintln('sServerIdent........................:'+  sServerIdent                        );
    JASPrintln('sServerSoftware.....................:'+  sServerSoftware                     );
    JASPrintln('sDefaultLanguage....................:'+  sDefaultLanguage                    );
    JASPrintln('bEnableSSL..........................:'+  sYesNo(bEnableSSL                    ));
    JASPrintln('u1DefaultMenuRenderMethod...........:'+  inttostr(u1DefaultMenuRenderMethod       )    );
    JASPrintln('sServerIP...........................:'+  sServerIP                           );
    JASPrintln('u2ServerPort........................:'+  inttostr(u2ServerPort              )          );
    JASPrintln('u2RetryLimit........................:'+  inttostr(u2RetryLimit                )        );
    JASPrintln('u4RetryDelayInMSec..................:'+  inttostr(u4RetryDelayInMSec          )        );
    JASPrintln('i1TIMEZONEOFFSET....................:'+  inttostr(i1TIMEZONEOFFSET            )        );
    JASPrintln('u4MaxFileHandles....................:'+  inttostr(u4MaxFileHandles             )       );
    MyPressEnter;
    JASPrintln('bBlacklistEnabled...................:'+  sYesNo(bBlacklistEnabled               )    );
    JASPrintln('bWhiteListEnabled...................:'+  sYesNo(bWhiteListEnabled               )    );
    JASPrintln('bBlacklistIPExpire..................:'+  sYesNo(bBlacklistIPExpire              )    );
    JASPrintln('bWhitelistIPExpire..................:'+  sYesNo(bWhitelistIPExpire              )    );
    JASPrintln('bInvalidLoginsExpire................:'+  sYesNo(bInvalidLoginsExpire            )    );
    JASPrintln('u2BlacklistDaysUntilExpire..........:'+  inttostr(u2BlacklistDaysUntilExpire    )      );
    JASPrintln('u2WhitelistDaysUntilExpire..........:'+  inttostr(u2WhitelistDaysUntilExpire    )      );
    JASPrintln('u2InvalidLoginsDaysUntilExpire......:'+  inttostr(u2InvalidLoginsDaysUntilExpire)      );
    JASPrintln('bJobQEnabled........................:'+  sYesNo(bJobQEnabled                 )       );
    JASPrintln('u4JobQIntervalInMSec................:'+  inttostr(u4JobQIntervalInMSec      )          );
    JASPrintln('sSMTPHost...........................:'+  sSMTPHost                           );
    JASPrintln('sSMTPUsername.......................:'+  sSMTPUsername                       );
    JASPrintln('sSMTPPassword.......................: *** withheld ***');
    //ASPrintln('sSMTPPassword.......................:'+  sSMTPPassword                       );
    JASPrintln('bProtectJASRecords..................:'+  sYesNo(bProtectJASRecords           )       );
    JASPrintln('bSafeDelete.........................:'+  sYesNo(bSafeDelete                  )       );
    JASPrintln('bAllowVirtualHostCreation...........:'+  sYesNo(bAllowVirtualHostCreation    )       );
    JASPrintln('bPunkBeGoneEnabled..................:'+  sYesNo(bPunkBeGoneEnabled           )       );
    JASPrintln('u2PunkBeGoneMaxErrors...............:'+  inttostr(u2PunkBeGoneMaxErrors      )         );
    JASPrintln('u2PunkBeGoneMaxMinutes..............:'+  inttostr(u2PunkBeGoneMaxMinutes     )         );
    MyPressEnter;
    JASPrintln('u4PunkBeGoneIntervalInMSec..........:'+  inttostr(u4PunkBeGoneIntervalInMSec     )     );
    JASPrintln('u2PunkBeGoneIPHoldTimeInDays........:'+  inttostr(u2PunkBeGoneIPHoldTimeInDays   )     );
    JASPrintln('u2PunkBeGoneMaxDownloads............:'+  inttostr(u2PunkBeGoneMaxDownloads       )     );
    JASPrintln('bPunkBeGoneSmackBadBots.............:'+  sYesNo(bPunkBeGoneSmackBadBots          )   );
    //-- log level
    { Everything 65535 = keep metrics but no log,
      0 - no log,
      1 - log everything,
      2 - Fatal ONLY,
      3 - Fatal & Errors,
      4 - Fatal,Errors, Warnings,
      5 - Fatal, Errors, Warnings, Information Entries,
      6+ User Defined Log Entry Types, and log level
      pattern starting at 2 and up continues to
      work with user levels. This allows various
      levels of custom logging using existing system }
    case u2LogLevel of
    65535: sLogLvl:='Gather metrics, but no log';
    0: sLogLvl:='No Log';
    1: sLogLvl:='Log Everything';
    2: sLogLvl:='Fatal Only';
    3: sLogLvl:='Fatal and Errors';
    4: sLogLvl:='Fatal, Errors, and Warnings.';
    5: sLogLvl:='Fatal, Errors, Warnings, Information Entries';
    else sLogLvl:='6+ User Defined Log Entry Types';
    end;//case
    JASPrintln('u2LogLevel..........................:'+  inttostr(u2LogLevel)+':'+sLogLvl);
    //--log level
    JASPrintln('bDeleteLogFile......................:'+  sYesNo(bDeleteLogFile                  )    );
    JASPrintln('u2ErrorReportingMode................:'+  inttostr(u2ErrorReportingMode         )       );
    JASPrintln('saErrorReportingSecureMessage.......:'+  saErrorReportingSecureMessage       );
    JASPrintln('bSQLTraceLogEnabled.................:'+  sYesNo(bSQLTraceLogEnabled            )     );
    JASPrintln('bServerConsoleMessagesEnabled.......:'+  sYesNo(bServerConsoleMessagesEnabled )      );
    JASPrintln('bDebugServerConsoleMessagesEnabled..:'+  sYesNo(bDebugServerConsoleMessagesEnabled)  );
    JASPrintln('u2DebugMode.........................:'+  inttostr(u2DebugMode                   )      );
    JASPrintln('u2SessionTimeOutInMinutes...........:'+  inttostr(u2SessionTimeOutInMinutes     )      );
    JASPrintln('u2LockTimeOutInMinutes..............:'+  inttostr(u2LockTimeOutInMinutes        )      );
    JASPrintln('u2LockRetriesBeforeFailure..........:'+  inttostr(u2LockRetriesBeforeFailure    )      );
    JASPrintln('u2LockRetryDelayInMSec..............:'+  inttostr(u2LockRetryDelayInMSec        )      );
    JASPRintln('>>> MAIN SYSTEM ONLY <<< ...........:'+  sYesNo(gbMainSystemOnly));
    MyPressEnter;
    JASPrintln('u2ValidateSessionRetryLimit.........:'+  inttostr(u2ValidateSessionRetryLimit    )     );
    JASPrintln('uMaximumRequestHeaderLength.........:'+  inttostr(uMaximumRequestHeaderLength    )     );
    JASPrintln('u2CreateSocketRetry.................:'+  inttostr(u2CreateSocketRetry            )     );
    JASPrintln('u2CreateSocketRetryDelayInMSec......:'+  inttostr(u2CreateSocketRetryDelayInMSec)      );
    JASPrintln('u2SocketTimeOutInMSec...............:'+  inttostr(u2SocketTimeOutInMSec)               );
    JASPrintln('bEnableSSL..........................:'+  sYesNo(bEnableSSL)                          );
    JASPrintln('sHOOK_ACTION_CREATESESSION_FAILURE..:'+  sHOOK_ACTION_CREATESESSION_FAILURE  );
    JASPrintln('sHOOK_ACTION_CREATESESSION_SUCCESS..:'+  sHOOK_ACTION_CREATESESSION_SUCCESS  );
    JASPrintln('sHOOK_ACTION_REMOVESESSION_FAILURE..:'+  sHOOK_ACTION_REMOVESESSION_FAILURE  );
    JASPrintln('sHOOK_ACTION_REMOVESESSION_SUCCESS..:'+  sHOOK_ACTION_REMOVESESSION_SUCCESS  );
    JASPrintln('sHOOK_ACTION_SESSIONTIMEOUT.........:'+  sHOOK_ACTION_SESSIONTIMEOUT         );
    JASPrintln('sHOOK_ACTION_VALIDATESESSION_FAILURE:'+  sHOOK_ACTION_VALIDATESESSION_FAILURE);
    JASPrintln('sHOOK_ACTION_VALIDATESESSION_SUCCESS:'+  sHOOK_ACTION_VALIDATESESSION_SUCCESS);
    JASPrintln('sClientToVICIServerIP...............:'+  sClientToVICIServerIP               );
    JASPrintln('sJASServertoVICIServerIP............:'+  sJASServertoVICIServerIP            );
    JASPrintln('bCreateHybridJets...................:'+  sYesNo(bCreateHybridJets));
    JASPrintln('bRecordLockingEnabled...............:'+  sYesNo(bRecordLockingEnabled));
    JASPrintln('u4ListenDurationInMSec..............:'+  inttostr(u4ListenDurationInMSec));
    JASPrintln('bRecycleSessions....................:'+  sYesNo(bRecycleSessions));
    JASPRintln(saRepeatChar('=',79));
    JASPrintln('END   - JAS Configuration Record');
    JASPRintln(saRepeatChar('=',79));
    MyPressEnter;
  end;// with







  with garJVHost[0] do begin
    JASPrintln('');
    JASPRintln(saRepeatChar('=',79));
    JASPrintln('BEGIN - jvhost - main host');
    JASPRintln(saRepeatChar('=',79));
    JASPrintln('VHost_AllowRegistration_b    :' + sYesNo(garJVHost[0].VHost_AllowRegistration_b));
    JASPrintln('VHost_RegisterReqCellPhone_b :' + sYesNo(garJVHost[0].VHost_RegisterReqCellPhone_b));
    JASPrintln('VHost_RegisterReqBirthday_b  :' + sYesNo(garJVHost[0].VHost_RegisterReqBirthday_b));
    JASPrintln('VHost_JVHost_UID             :' + inttostr(garJVHost[0].VHost_JVHost_UID));
    JASPrintln('VHost_WebRootDir             :' + garJVHost[0].VHost_WebRootDir);
    JASPrintln('VHost_ServerName             :' + garJVHost[0].VHost_ServerName);
    JASPrintln('VHost_ServerIdent            :' + garJVHost[0].VHost_ServerIdent);
    JASPrintln('VHost_ServerURL              :' + garJVHost[0].VHost_ServerURL);
    JASPrintln('VHost_ServerDomain           :' + garJVHost[0].VHost_ServerDomain);
    JASPrintln('VHost_DefaultLanguage        :' + garJVHost[0].VHost_DefaultLanguage          );
    JASPrintln('VHost_DefaultTheme           :' + garJVHost[0].VHost_DefaultTheme             );
    JASPrintln('VHost_MenuRenderMethod       :' + inttostr(garJVHost[0].VHost_MenuRenderMethod));
    MyPressEnter;
    JASPrintln('VHost_DefaultArea            :' + garJVHost[0].VHost_DefaultArea              );
    JASPrintln('VHost_DefaultPage            :' + garJVHost[0].VHost_DefaultPage              );
    JASPrintln('VHost_DefaultSection         :' + garJVHost[0].VHost_DefaultSection           );
    JASPrintln('VHost_DefaultTop_JMenu_ID    :' + inttostr(garJVHost[0].VHost_DefaultTop_JMenu_ID));
    JASPrintln('VHost_DefaultLoggedInPage    :' + garJVHost[0].VHost_DefaultLoggedInPage      );
    JASPrintln('VHost_DefaultLoggedOutPage   :' + garJVHost[0].VHost_DefaultLoggedOutPage     );
    JASPrintln('VHost_DataOnRight_b          :' + sYesNo(garJVHost[0].VHost_DataOnRight_b));
    JASPrintln('VHost_CacheMaxAgeInSeconds   :' + inttostr(garJVHost[0].VHost_CacheMaxAgeInSeconds));
    JASPrintln('VHost_SystemEmailFromAddress :' + garJVHost[0].VHost_SystemEmailFromAddress);
    JASPrintln('VHost_SharesDefaultDomain_b  :' + sYesNo(garJVHost[0].VHost_SharesDefaultDomain_b)    );
    JASPrintln('VHost_DefaultIconTheme       :' + garJVHost[0].VHost_DefaultIconTheme         );
    JASPrintln('VHost_DirectoryListing_b     :' + sYesNo(garJVHost[0].VHost_DirectoryListing_b)       );
    JASPrintln('VHost_FileDir                :' + garJVHost[0].VHost_FileDir                  );
    JASPrintln('VHost_AccessLog              :' + garJVHost[0].VHost_AccessLog                );
    JASPrintln('VHost_ErrorLog               :' + garJVHost[0].VHost_ErrorLog                 );
    JASPrintln('VHost_JDConnection_ID        :' + inttostr(garJVHost[0].VHost_JDConnection_ID));
    JASPrintln('VHost_Enabled_b              :' + sYesNo(garJVHost[0].VHost_Enabled_b));
    JASPrintln('VHost_TemplateDir            :' + garJVHost[0].VHost_TemplateDir              );
    MyPressEnter;
    JASPrintln('VHOST_SipURL                 :' + garJVHost[0].VHOST_SipURL                   );
    JASPrintln('VHOST_WebshareDir            :' + garJVHost[0].VHOST_WebshareDir              );
    JASPrintln('VHOST_CacheDir               :' + garJVHost[0].VHOST_CacheDir                 );
    //JASPrintln('VHOST _LogDir                 :' + garJVHost[0].VHOST _LogDir                   );
    //JASPrintln('VHOST _ThemeDir               :' + garJVHost[0].VHOST _ThemeDir                 );
    //JASPrintln('VHOST_DiagnosticLogFileName  :' + garJVHost[0].VHOST_DiagnosticLogFileName    );
    JASPrintln('VHOST_WebShareAlias          :' + garJVHost[0].VHOST_WebShareAlias            );
    JASPrintln('VHOST_JASDirTheme            :' + garJVHost[0].VHOST_JASDirTheme              );
    JASPrintln('VHOST_DefaultArea           :' + garJVHost[0].VHOST_DefaultArea             );
    JASPrintln('VHOST_DefaultPage           :' + garJVHost[0].VHOST_DefaultPage             );
    JASPrintln('VHOST_DefaultSection        :' + garJVHost[0].VHOST_DefaultSection          );
    JASPrintln('VHOST_PasswordKey_u1         :' + inttostr(garJVHost[0].VHOST_PasswordKey_u1));
    JASPrintln('VHost_LogToDataBase_b        :' + sYesNo(garJVHost[0].VHost_LogToDataBase_b)          );
    JASPrintln('VHost_LogToConsole_b         :' + sYesNo(garJVHost[0].VHost_LogToConsole_b )          );
    JASPrintln('VHost_LogRequestsToDatabase_b:' + sYesNo(garJVHost[0].VHost_LogRequestsToDatabase_b)  );
    JASPrintln('VHost_AccessLog       :' + garJVHost[0].VHost_AccessLog         );
    JASPrintln('VHost_ErrorLog        :' + garJVHost[0].VHost_ErrorLog          );
    JASPRintln(saRepeatChar('=',79));
    JASPrintln('END   - jvhost - main host');
    JASPRintln(saRepeatChar('=',79));
  end;// with




{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
Procedure ShowJASTableMatrix;
//=============================================================================
var
  u1Line: byte;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ShowJASTableMatrix';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if gaJCon[0].JASTABLEMATRIX.Movefirst then
  begin
    u1Line:=0;
    repeat
      with gaJCon[0].JASTABLEMATRIX do begin
        JASprintln(inttostr(N)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(1)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(2)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(3)+' '+
          gaJCon[0].JASTABLEMATRIX.Get_saMatrix(4)+' '
        );
        u1Line+=1;
        if u1Line=20 then begin JASPrint('Press [ENTER] to Continue: ');readln;u1Line:=0;end;
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
    JASPrintln(' uCols: '+inttostr(uCols));
    JASPrintln(' uRows: '+inttostr(uRows));
    JASPrintln(' N: '+inttostr(N));
    JASPrintln(' length(asaColumns): '+ inttostr(length(asaColumns)));
    JASPrintln(' length(asaMatrix): '+ inttostr(length(asaMatrix)));
    JASPrintln(' ListCount: '+ inttostr(ListCount));
    JASPrintln(' bIsCopy: '+ sTrueFalse(bIsCopy));
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
        'ID: '+inttostr(gaJCon[i].ID)+
        //' DB: '+gaJCon[i].saDatabase+
        //' State: '+ JADO.saObjectState(gaJCon[i].i4State)+
        ' Name: '+gaJCon[i].sName+
        ' Server: '+gaJCon[i].sServer+
        ' User: '+gaJCon[i].sUserName+
        ' Connected: '+sTrueFalse(gaJCon[i].bConnected)
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
  writeln(saRepeatChar('-',79));
  writeln('JAS Console HELP - Note: Only first letter of command required.');
  writeln(saRepeatChar('-',79));
  //writeln('Animations   : Toggles Animations - Purely a fun thing');
  writeln('Empty        : Empty/Clear Console - via line-feeds');
  Writeln('Databases    : Database Connections');
  writeln('Jegas        : Jegas, LLC Logo');
  Writeln('Logging      : Logging Statistics');
  Writeln('Matrix       : Show JASTABLEMATRIX contents');
  Writeln('Setup        : Show JAS Configuration details.');
  Writeln('Threads      : Show diagnostic information worker threads.');
  Writeln('Workers      : Show worker thread status information');
  Writeln('Kill   [UID] : Terminate worker. Use Workers command to get the UID');
  writeln('Ban     [IP] : Adds specified IP to the Black-List.');
  writeln('Promote [IP] : Adds specified IP to the White-List.');
  writeln('Forget  [IP] : Removes specified IP from the whitelist.');
  writeln('IP      [IP] : Info on IP DB and MEMORY');
  Writeln('Cycle        : Cycle Server, Keep Open Port(s), Re-Read Configuration');
  Writeln('Quit         : Shut JAS Server Down.');
  writeln(saRepeatChar('-',79));

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
    writeln(saRepeatChar('=',60));
    writeln('Logging Statistic as of ',FormatDateTime(CSDATETIMEFORMAT, now));
    writeln(saRepeatChar('=',60));
    writeln('Total      : ',uLogEntries_Total);//< Total count, incremented each time a specific log is written to
    writeln('Generic    : ',uLogEntries_NONE);//<DEFAULT LOGGING LEVEL
    writeln('Debug      : ',uLogEntries_DEBUG);//< 1
    writeln('Fatal      : ',uLogEntries_FATAL);//< 2
    writeln('Errors     : ',uLogEntries_ERROR);//< 3
    writeln('Warnings   : ',uLogEntries_WARN);//< 4
    writeln('Information: ',uLogEntries_INFO);//< 5
    writeln('Reserved   : ',uLogEntries_RESERVED);//< 6   RESERVED by JEGAS 6 thru 99}
    writeln('User Def   : ',uLogEntries_USERDEFINED);//< 100  USER CODES 100 thru 255}
    if Int64(dtLogEntryFirst)<>0 then
    begin
      writeln('First Entry: ',FormatDateTime(csDATETIMEFORMAT,dtLogEntryFirst));// : TDATETIME; //< per invocation
      writeln('Last Entry : ',FormatDateTime(csDATETIMEFORMAT,dtLogEntryLast));// : TDATETIME; //< per invocation
    end;
    writeln(saRepeatChar('=',60));
  end;//with
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================













//=============================================================================
procedure IPInquiry(p_sIP: string);
//=============================================================================
Var
  DBC: JADO_CONNECTION;
  u: UInt;
  dt: TDateTime;
  rJIPList: rtJIPList;
  rs: JADO_RECORDSET;
  saQry:ansistring;

  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='IPInquiry';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  dt:=now;
  writeln;
  writeln(saRepeatChar('=',55));
  writeln('BEGIN - IP Inquiry: '+ p_sIP + ' '+formatdatetime(csDATETIMEFORMAT,dt));
  writeln(saRepeatChar('=',55));


  DBC:=gaJCon[0];
  if length(garJIPListLight)>0 then
  begin
    for u:=0 to length(garJIPListLight)-1 do
    begin
      if leftstr(garJIPListLight[u].sIPAddress,length(p_sIP))=p_sIP then
      begin
        with garJIPListLight[u] do begin
          write('IN MEMORY: '+garJIPListLight[u].sIPAddress+ ' - ');
          case u1IPListType of
          cnJIPListLU_WhiteList: write('Whitelisted');
          cnJIPListLU_BlackList: write('Blacklisted');
          cnJIPListLU_InvalidLogin: write('Invalid Logins');
          cnJIPListLU_Downloader: write('Downloader');
          end;//case
          write(' - ');
          write('Logins:',u1InvalidLogins );
          write(' - ');
          write('Downloads:',u2Downloads);
          write(' - ');
          write('JMails:',u1JMails);
          write(' - ');
          writeln('Last Download: ',FORMATDATETIME(csDATETIMEFORMAT,dtDownLoad));
        end;//with
      end;
    end;
  end
  else
  begin
    Writeln('No IP Addresses in memory at this time.');
  end;
  writeln;
  if u>0 then
  begin
    saQry:='((JIPL_Deleted_b is null) or (JIPL_Deleted_b=false)) and (JIPL_IPAddress like '+DBC.saDBMSScrub('%'+p_sIP+'%')+')';
    if DBC.u8GetRecordCount('jiplist',saQry, 201602181456)>0 then
    begin
      saQry:='select JIPL_JIPList_UID from jiplist where '+saQry;
      rs:=JADO_RECORDSET.Create;
      if rs.open(saQry,DBC,201602181512) then
      begin
        repeat
          rJIPList.JIPL_JIPList_UID:=u8Val(rs.fields.Get_saValue('JIPL_JIPList_UID'));
          if bJAS_Load_jiplist(DBC,rJIPList,201608310500) then
          begin
            with rJIPList do begin
              write('UID: '+inttostr(JIPL_JIPList_UID)+' IP:'+JIPL_IPAddress+' ');
              if JIPL_IPListType_u = cnJIPListLU_WhiteList then write('Whitelisted') else
              if JIPL_IPListType_u = cnJIPListLU_BlackList then write('Blacklisted') else
              if JIPL_IPListType_u = cnJIPListLU_InvalidLogin then write('Invalid Logins ('+inttostr(JIPL_InvalidLogins_u)+') ') else
              if JIPL_IPListType_u = cnJIPListLU_Downloader then write('Downloader') else
                 write(' INVALID IP ADDRESS TYPE (Not any of these: Whitelist, Blacklist, Downloader or Invalid Logins.');

              writeln('Reason: '+ JIPL_Reason);
            end;//with
          end;
        until not rs.movenext;
      end
      else
      begin
        Writeln('Unable to query the database for the IP Address.');
      end;
      rs.close;
      rs.destroy;rs:=nil;
    end
    else
    begin
      Writeln('No IP Addresses in the database at this time.');
    end;
  end;

  writeln(saRepeatChar('=',55));
  writeln('END   - IP Inquiry: '+ p_sIP + ' '+formatdatetime(csDATETIMEFORMAT,dt));
  writeln(saRepeatChar('=',55));
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================















//=============================================================================
procedure KillWorker(p_sUID: string);
//=============================================================================
var
  i: longint;
  bGotIt: boolean;
  JTI: rtJThreadInit;


{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='KillWorker';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  bGotIt:=false;
  try
    //CSECTION_MAINPROCESS.Enter;
    for i:=0 to length(aWorker)-1 do
    begin
      if aWorker[i]<>nil then
      begin
        if aWorker[i].UID = u8Val(p_sUID) then
        begin
          //aWorker[i].bFinished:=true;//flagged for execution, he is mean too
          with JTI do begin
            bCreateCriticalSection:=true;
            bLoopContinuously:=true;
            bCreateSuspended:=true;
            bFreeOnTerminate:=false;
            UID:=0;
          end;//end with
          aWorker[i].FREE;aWorker[i]:=TWorker.Create(JTI);
          aWorker[i].UID:=u8GetUID;
          aWorker[i].uMyId:=i;
          bGotIt:=true;
          break;
        end;
      end;
    end;
  except on E:Exception do ;
    //CSECTION_MAINPROCESS.Leave;
  end;
  if bGotIt then writeln('Blasted it out of the sky!') else writeln('Thread '+p_sUID+' not found.');
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
  s: string[1];//its being a pain
  sParam1: string;
  sReason: string;
  bParam1Given: boolean;
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
    readln(str);
    s:=upcase(Leftstr(trim(str),1));

    sParam1:=trim(RightStr(str, length(str)-pos(' ',str)));
    bParam1Given :=(pos(' ',str)>0) and (sParam1<>'');
    if (s='H') or (s='?') then
    begin
      WriteCLIHelp;
    end else 

    If (s = 'Q') Then gbServerShuttingDown := True else
    If (s = 'C') Then gbServerCycling := True else

    If(s='T')Then Showthreads else
    If(s='W')Then showworkerthreads else
    if(s='K') then begin if bParam1Given then killworker(sParam1) else writeln('Missing UID (Unique Identifier Parameter.'); end else
    if(s='S') then ShowJASConfigRecord else
    if(s='M') then ShowJASTableMatrix else
    if(s='D') then ShowJASConnections else
    if(s='E') then ClearJASConsole else
    if(s='J') then JASPrint(saJegasLogoRawText(csCRLF,true)) else
    if(s='L') then ShowLoggingStatus else
    if(s='I') then
    begin
      if bParam1Given then IPInquiry(sParam1) else writeln('Missing IP Address');
    end else

    //------------------------ Handled together
    // blacklist ip address
    // whitelist ip address
    // unban/un-blacklist
    // forget - remove ip from white list
    //------------------------
    if (s='B') or (s='P') or (s='F') then
    begin
      if s='B' then begin sReason:='Console - Manual Ban'; writeln('!! Banning/BLACKLISTING '+sParam1+' !!') end else
      if s='P' then begin sReason:='Console - Manual Promote/Whitelist'; writeln('-=-=-=< Promoting/WHITELISTING '+sParam1+' >=-=-=-') end else
      if s='F' then begin sReason:='Console - Forget/Forgive'; writeln('-!-!- Removing '+sParam1+' from Database - Forget/Forgive -!-!-'); end;
      if bParam1Given then
      begin
        if not JIPListControl(gaJCon[0],s,sParam1,sReason,1) then writeln('IP List Table Update Failed.');
      end else writeln('Missing IP address operand.');
    end else
  Until (gbServerShuttingDown or gbServerCycling);
  repeat
    yield(1000);
  until not (gbServerShuttingDown);
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
    Yield(0);
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

  repeat
    gbServerShuttingDown:=false;
    gbServerCycling:=false;
    InitJASConfigRecord;
    BeginThread(@needStop, nil);
    //BeginThread(@AnimateJAS, nil);

    bOk:=bJAS_Init;
    if(bOk=false) then
    begin
      JASPrintln('!! Error(s) Reported by Core_Init !!');
    end;
    
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
  until not gbServerCycling;


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
