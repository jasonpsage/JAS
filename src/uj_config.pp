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
// JAS Specific Functions, Consolidation of JAS configuration
//
// Note: in 2.6.x fpc, comparing constant 64bit values to variables was failing
// regardless of the data, the fix is to assign constants to a variable then
// test. This sucks so I skipped Free Pascal >2.4.4 until they fixed it in Version 3.0
// now freepascal is on track again ;) Note, unfortunately now it doesn't like
// long run on constanats for makinglong ansistrings. I found doing smaller chunks
// (guessing 256 most reliable size?) and any weirdess I may encounter now -
// chopping it up seems the fix or workaround anyways - it doesn't comealot but
// it is a little off.
Unit uj_config;
//=============================================================================
                                  //1605030308324720288   smackbot bPunkBeGoneSmackBadBots
                                  //User-agent: *
                                  //Disallow: /
                                  //Disallow: /
//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_config.pp'}
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
,dos
,sysutils
,blcksock
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jfc_tokenizer
,ug_jfc_threadmgr
,ug_jfc_matrix
,ug_jfc_dir
,ug_tsfileio
,ug_jado
,uj_menusys
,uj_definitions
,uj_listener
,uj_worker
,uj_tables_loadsave
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
function bLoadConfigurationFile:boolean; 
//=============================================================================
 
//=============================================================================
{}
function bJAS_Init: boolean;
//=============================================================================

//=============================================================================
{}
function bJAS_ShutDown: boolean;
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

type rtConfigOverridden = Record
  //bsaSysDir                            : boolean;
  //bsaConfigDir                         : boolean;
  //bsaBinDir                            : boolean;
  //bsaSetupDir                          : boolean;
  //bsaSoftwaredir                       : boolean;
  //bsaSrcDir                            : boolean;
  bsaPHPDir                            : boolean;
  bsaDBCFilename                       : boolean;
  //bsaConfigFile                        : boolean;
  bsaPHP                               : boolean;
  bsaPerl                              : boolean;
  bsaJASFooter                         : boolean;
  bu2ThreadPoolNoOfThreads             : boolean;
  buThreadPoolMaximumRunTimeInMSec     : boolean;
  bsServerURL                         : boolean;
  bsServerName                         : boolean;
  bsServerIdent                        : boolean;
  bsDefaultLanguage                    : boolean;
  bbEnableSSL                          : boolean;
  bbRedirectToPort443                  : boolean;
  bu1DefaultMenuRenderMethod           : boolean;
  bsServerIP                           : boolean;
  bu2ServerPort                        : boolean;
  bu2RetryLimit                        : boolean;
  bu4RetryDelayInMSec                  : boolean;
  bi1TIMEZONEOFFSET                    : boolean;
  bu4MaxFileHandles                    : boolean;
  bbBlacklistEnabled                   : boolean;
  bbWhiteListEnabled                   : boolean;
  bbBlacklistIPExpire                  : boolean;
  bbWhitelistIPExpire                  : boolean;
  bbInvalidLoginsExpire                : boolean;
  bu2BlacklistDaysUntilExpire          : boolean;
  bu2WhitelistDaysUntilExpire          : boolean;
  bu2InvalidLoginsDaysUntilExpire      : boolean;
  bbJobQEnabled                        : boolean;
  bu4JobQIntervalInMSec                : boolean;
  bsSMTPHost                           : boolean;
  bsSMTPUsername                       : boolean;
  bsSMTPPassword                       : boolean;
  bbProtectJASRecords                  : boolean;
  bbSafeDelete                         : boolean;
  bbAllowVirtualHostCreation           : boolean;
  bbPunkBeGoneEnabled                  : boolean;
  bu2PunkBeGoneMaxErrors               : boolean;
  bu2PunkBeGoneMaxMinutes              : boolean;
  bu4PunkBeGoneIntervalInMSec          : boolean;
  bu2PunkBeGoneIPHoldTimeInDays        : boolean;
  bu2PunkBeGoneMaxDownloads            : boolean;
  bbPunkBeGoneSmackBadBots             : boolean;
  bu2LogLevel                          : boolean;
  bbDeleteLogFile                      : boolean;
  bu2ErrorReportingMode                : boolean;
  bsaErrorReportingSecureMessage       : boolean;
  bbSQLTraceLogEnabled                 : boolean;
  bbServerConsoleMessagesEnabled       : boolean;
  bbDebugServerConsoleMessagesEnabled  : boolean;
  bu2DebugMode                         : boolean;
  bbRecycleSessions                    : boolean;
  bu2SessionTimeOutInMinutes           : boolean;
  bu2LockTimeOutInMinutes              : boolean;
  bu2LockRetriesBeforeFailure          : boolean;
  bu2LockRetryDelayInMSec              : boolean;
  bu2ValidateSessionRetryLimit         : boolean;
  buMaximumRequestHeaderLength         : boolean;
  bu2CreateSocketRetry                 : boolean;
  bu2CreateSocketRetryDelayInMSec      : boolean;
  bu2SocketTimeOutInMSec               : boolean;
  bsHOOK_ACTION_CREATESESSION_FAILURE  : boolean;
  bsHOOK_ACTION_CREATESESSION_SUCCESS  : boolean;
  bsHOOK_ACTION_REMOVESESSION_FAILURE  : boolean;
  bsHOOK_ACTION_REMOVESESSION_SUCCESS  : boolean;
  bsHOOK_ACTION_SESSIONTIMEOUT         : boolean;
  bsHOOK_ACTION_VALIDATESESSION_FAILURE: boolean;
  bsHOOK_ACTION_VALIDATESESSION_SUCCESS: boolean;
  bsClientToVICIServerIP               : boolean;
  bsJASServertoVICIServerIP            : boolean;
  bbCreateHybridJets                   : boolean;
  bbRecordLockingEnabled               : boolean;
  bsaLogDir                            : boolean;
  bu4ListenDurationInMSec              : boolean;
End;


var rConfigOverridden: rtConfigOverridden;


// ============================================================================
procedure ResetConfigOverRidden;
// ============================================================================
begin
  with rConfigOverridden do begin
    //bsaSysDir                            := false;
    bsaPHPDir                            := false;
    bsaDBCFilename                       := false;
    bsaPHP                               := false;
    bsaPerl                              := false;
    bsaJASFooter                         := false;
    bu2ThreadPoolNoOfThreads             := false;
    buThreadPoolMaximumRunTimeInMSec     := false;
    bsServerURL                          := false;
    bsServerName                         := false;
    bsServerIdent                        := false;
    bsDefaultLanguage                    := false;
    bbEnableSSL                          := false;
    bbRedirectToPort443                  := false;
    bu1DefaultMenuRenderMethod           := false;
    bsServerIP                           := false;
    bu2ServerPort                        := false;
    bu2RetryLimit                        := false;
    bu4RetryDelayInMSec                  := false;
    bi1TIMEZONEOFFSET                    := false;
    bu4MaxFileHandles                    := false;
    bbBlacklistEnabled                   := false;
    bbWhiteListEnabled                   := false;
    bbBlacklistIPExpire                  := false;
    bbWhitelistIPExpire                  := false;
    bbInvalidLoginsExpire                := false;
    bu2BlacklistDaysUntilExpire          := false;
    bu2WhitelistDaysUntilExpire          := false;
    bu2InvalidLoginsDaysUntilExpire      := false;
    bbJobQEnabled                        := false;
    bu4JobQIntervalInMSec                := false;
    bsSMTPHost                           := false;
    bsSMTPUsername                       := false;
    bsSMTPPassword                       := false;
    bbProtectJASRecords                  := false;
    bbSafeDelete                         := false;
    bbAllowVirtualHostCreation           := false;
    bbPunkBeGoneEnabled                  := false;
    bu2PunkBeGoneMaxErrors               := false;
    bu2PunkBeGoneMaxMinutes              := false;
    bu4PunkBeGoneIntervalInMSec          := false;
    bu2PunkBeGoneIPHoldTimeInDays        := false;
    bu2PunkBeGoneMaxDownloads            := false;
    bbPunkBeGoneSmackBadBots             := false;
    bu2LogLevel                          := false;
    bbDeleteLogFile                      := false;
    bu2ErrorReportingMode                := false;
    bsaErrorReportingSecureMessage       := false;
    bbSQLTraceLogEnabled                 := false;
    bbServerConsoleMessagesEnabled       := false;
    bbDebugServerConsoleMessagesEnabled  := false;
    bu2DebugMode                         := false;
    bbRecycleSessions                    := false;
    bu2SessionTimeOutInMinutes           := false;
    bu2LockTimeOutInMinutes              := false;
    bu2LockRetriesBeforeFailure          := false;
    bu2LockRetryDelayInMSec              := false;
    bu2ValidateSessionRetryLimit         := false;
    buMaximumRequestHeaderLength         := false;
    bu2CreateSocketRetry                 := false;
    bu2CreateSocketRetryDelayInMSec      := false;
    bu2SocketTimeOutInMSec               := false;
    bbEnableSSL                          := false;
    bbRedirectToPort443                  := false;
    bsHOOK_ACTION_CREATESESSION_FAILURE  := false;
    bsHOOK_ACTION_CREATESESSION_SUCCESS  := false;
    bsHOOK_ACTION_REMOVESESSION_FAILURE  := false;
    bsHOOK_ACTION_REMOVESESSION_SUCCESS  := false;
    bsHOOK_ACTION_SESSIONTIMEOUT         := false;
    bsHOOK_ACTION_VALIDATESESSION_FAILURE:= false;
    bsHOOK_ACTION_VALIDATESESSION_SUCCESS:= false;
    bsClientToVICIServerIP               := false;
    bsJASServertoVICIServerIP            := false;
    bbCreateHybridJets                   := false;
    bbRecordLockingEnabled               := false;
    bsaLogDir                            := false;
    bu4ListenDurationInMSec              := false;
  end;// with
end;
// ============================================================================








// ============================================================================
type rtJVHostOverridden = record
// ============================================================================
  bVHost_AllowRegistration_b     :boolean;
  bVHost_RegisterReqCellPhone_b  :boolean;
  bVHost_RegisterReqBirthday_b   :boolean;
  bVHost_JVHost_UID              :boolean;
  bVHost_WebRootDir              :boolean;
  bVHost_ServerName              :boolean;
  bVHost_ServerIdent             :boolean;
  bVHost_ServerURL               :boolean;
  bVHost_ServerDomain            :boolean;
  bVHost_ServerIP                :boolean;
  bVHost_ServerPort              :boolean;
  bVHOST_RedirectToPort443_b     :boolean;
  bVHost_DefaultLanguage         :boolean;
  bVHost_DefaultTheme            :boolean;
  bVHost_MenuRenderMethod        :boolean;
  bVHost_DefaultArea             :boolean;
  bVHost_DefaultPage             :boolean;
  bVHost_DefaultSection          :boolean;
  bVHost_DefaultTop_JMenu_ID     :boolean;
  bVHost_DefaultLoggedInPage     :boolean;
  bVHost_DefaultLoggedOutPage    :boolean;
  bVHost_DataOnRight_b           :boolean;
  bVHost_CacheMaxAgeInSeconds    :boolean;
  bVHost_SystemEmailFromAddress  :boolean;
  bVHost_SharesDefaultDomain_b   :boolean;
  bVHost_DefaultIconTheme        :boolean;
  bVHost_DirectoryListing_b      :boolean;
  bVHost_FileDir                 :boolean;
  bVHost_AccessLog               :boolean;
  bVHost_ErrorLog                :boolean;
  bVHost_JDConnection_ID         :boolean;
  bVHost_Enabled_b               :boolean;
  bVHost_TemplateDir             :boolean;
  bVHOST_SipURL                  :boolean;
  bVHOST_WebshareDir             :boolean;
  bVHOST_CacheDir                :boolean;
//  bVHOST _LogDir                  :boolean;
//  bVHOST _ThemeDir                :boolean;
  bVHOST_WebShareAlias           :boolean;
  bVHOST_JASDirTheme             :boolean;
  bVHOST_PasswordKey_u1          :boolean;
  bVHost_LogToDataBase_b         :boolean;
  bVHost_LogToConsole_b          :boolean;
  bVHost_LogRequestsToDatabase_b :boolean;
  bVHOST_WebShareAlias_b         :boolean;
  bVHost_WebShareDir_b           :boolean;
  bVHost_Headers_b               :boolean;
  bVHost_QuickLinks_b            :boolean;
  bVHost_DefaultDateMask         :boolean;
  bVHost_Background              :boolean;
  bVHost_BackgroundRepeat_b      :boolean;
end;
var rJVHostOverridden: rtJVHostOverridden;
var rJVHostOverride: rtJVHost;
// ============================================================================

// ============================================================================
procedure ResetJVHostOverridden;
// ============================================================================
begin
  with rJVHostOverridden do begin
    bVHost_AllowRegistration_b      := false ;
    bVHost_RegisterReqCellPhone_b   := false ;
    bVHost_RegisterReqBirthday_b    := false ;
    bVHost_JVHost_UID               := false ;
    bVHost_WebRootDir               := false ;
    bVHost_ServerName               := false ;
    bVHost_ServerIdent              := false ;
    bVHost_ServerURL                := false ;
    bVHost_ServerDomain             := false ;
    bVHost_ServerIP                 := false ;
    bVHost_ServerPort               := false ;
    bVHOST_RedirectToPort443_b      := false ;
    bVHost_DefaultLanguage          := false ;
    bVHost_DefaultTheme             := false ;
    bVHost_MenuRenderMethod         := false ;
    bVHost_DefaultArea              := false ;
    bVHost_DefaultPage              := false ;
    bVHost_DefaultSection           := false ;
    bVHost_DefaultTop_JMenu_ID      := false ;
    bVHost_DefaultLoggedInPage      := false ;
    bVHost_DefaultLoggedOutPage     := false ;
    bVHost_DataOnRight_b            := false ;
    bVHost_CacheMaxAgeInSeconds     := false ;
    bVHost_SystemEmailFromAddress   := false ;
    bVHost_SharesDefaultDomain_b    := false ;
    bVHost_DefaultIconTheme         := false ;
    bVHost_DirectoryListing_b       := false ;
    bVHost_FileDir                  := false ;
    bVHost_AccessLog                := false ;
    bVHost_ErrorLog                 := false ;
    bVHost_JDConnection_ID          := false ;
    bVHost_Enabled_b                := false ;
    bVHost_TemplateDir              := false ;
    bVHOST_SipURL                   := false ;
    bVHOST_WebshareDir              := false ;
    bVHOST_CacheDir                 := false ;
//    bVHOST _LogDir                   := false ;
//    bVHOST _ThemeDir                 := false ;
    bVHOST_WebShareAlias            := false ;
    bVHOST_JASDirTheme              := false ;
    bVHOST_DefaultArea             := false ;
    bVHOST_DefaultPage             := false ;
    bVHOST_DefaultSection          := false ;
    bVHOST_PasswordKey_u1           := false ;
    bVHost_LogToDataBase_b          := false ;
    bVHost_LogToConsole_b           := false ;
    bVHost_LogRequestsToDatabase_b  := false ;
    bVHost_AccessLog         := false ;
    bVHost_ErrorLog          := false ;
    bVHOST_WebShareAlias_b          := false ;
    bVHost_Headers_b                :=false;
    bVHost_QuickLinks_b             :=false;
    bVHost_DefaultDateMask :=false;
    bVHost_Background:=false;
    bVHost_BackgroundRepeat_b:=false;
  end;//with
end;
// ============================================================================


var bLogEntryMadeDuringStartUp: boolean;






















//=============================================================================
function bCreatePHPJASTableDef: boolean;
//=============================================================================
var
  F: text;
  RS: JADO_RECORDSET;
  RS2:  JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  saFileName: ansistring;
  u2IOResult: word;
  u: uint;
  uVHostOfs: uint;
  uXCon: uint;
  bgotIt: boolean;

{$IFDEF DEBUGLOGBEGINEND}
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: string;{$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bCreatePHPJASTableDef';{$ENDIF}
DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  rs:=JADO_RECORDSET.create;
  rs2:=JADO_RECORDSET.create;
  bOk:=true;
  //ASPrintLn('uj_config - Createphp - grJASConfig.saSysDir: '+grJASConfig.saSysDir);
  //saFilename:=grJASConfig.saSysDir+DOSSLASH+'php'+DOSSLASH+'config.jastabledef.php';
  saFilename:='..'+DOSSLASH+'php'+DOSSLASH+'config.jastabledef.php';

  if bOk then
  begin
    bOk:= bTSOpenTextFile( safilename, u2IOResult, f, false, false);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_Error, 201006262033, 'bCreatePHPJASTableDef trouble with bTSOpenTextFile. IOResult:'+
        inttostr(u2IOResult)+' '+sIOResult(u2IOResult)+' Filename:'+saFilename,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    rewrite(f);
    writeln(f,'<?PHP');
    writeln(f,'// =================================================================');
    writeln(f,'// |    _________ _______  _______  ______  _______                |');
    writeln(f,'// |   /___  ___// _____/ / _____/ / __  / / _____/                |');
    writeln(f,'// |      / /   / /__    / / ___  / /_/ / / /____                  |');
    writeln(f,'// |     / /   / ____/  / / /  / / __  / /____  /                  |');
    writeln(f,'// |____/ /   / /___   / /__/ / / / / / _____/ / By: Jegas, LLC    |');
    writeln(f,'// /_____/   /______/ /______/ /_/ /_/ /______/                    |');
    writeln(f,'// |                 Under the Hood            JasonPSage@jegas.com|');
    writeln(f,'// =================================================================');
    writeln(f,'// Jegas Application Server Table Definitions');
    writeln(f,'// =================================================================');
    writeln(f,'// NOTE: This file is created when JAS is started - Manual Edits');
    writeln(f,'//       will be lost!');
    writeln(f,'// NOTE: If you are using the nph-jas.cgi (JAS Proxy Tool) and the ');
    writeln(f,'//       php folder for JAS is on a different machine... then you');
    writeln(f,'//       will want to copy this file from the JAS php folder to ');
    writeln(f,'//       here whenever new tables are added to the JAS database.');
    writeln(f,'// =================================================================');

    for uVHostOfs:=0 to length(garJVHost)-1 do
    begin
      //ASPrintln('PHP - Top of Main Loop: ' + inttostr(i));
      uXCon:=0;bGotIt:=false;
      for u:=0 to length(gajCon)-1 do
      begin
        //ASPrintln('PHP Drop File - Top of Inner Loop: '+inttostr(u)+' '+inttostr(gaJCon[u].ID)+'='+inttostr(garJVHost[uVHostOfs].VHost_JDConnection_ID));
        if gaJCon[u].ID=garJVHost[uVHostOfs].VHost_JDConnection_ID then
        begin
          //ASPrintln('Got Correct Connection for VHost! :)');
          bGotIt:=true;
          uXCon:=u; break;
        end;
      end;
      //ASPrintln('PHP - Done Inner Loop');

      bOk:=bGotIt;
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        JLog(cnLog_ERROR, 201211241136, 'Unable to locate a Database connection for a VHOST: '+garJVHost[uVHostOfs].VHost_ServerName,SOURCEFILE);
        break;
      end;

      if bOk then
      begin
        saQry:='select JDCon_JDConnection_UID, JDCon_Name from jdconnection '+
          'where ((JDCon_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(JDCon_Deleted_b IS NULL)) and '+
          '(JDCon_Enabled_b='+gaJCon[0].sDBMSBoolScrub(true)+') AND '+
          '(JDCon_JDConnection_UID='+gaJCon[0].sDBMSUIntScrub(garJVHost[uXCon].VHost_JDConnection_ID)+') '+
          'ORDER BY JDCon_Name';
        //ASPrintln('CON: '+saQry);
        bOK:=rs.open(saQry, gaJCon[0],201503161667);
        if not bOk then
        begin
          bLogEntryMadeDuringStartUp:=true;
          JLog(cnLog_ERROR, 201003211647, 'Trouble with Query:'+saQry,SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        if (rs.eol=false) then
        begin
          repeat
            saQry:='select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID='+
              gaJCon[uXCon].sDBMSUIntScrub(rs.fields.Get_saValue('JDCon_JDConnection_UID'))+') AND '+
              '((JTabl_Deleted_b<>'+gaJCon[uXCon].sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) '+
              'ORDER BY JTabl_Name';
            //ASPrintln('TBL: '+saQry);
            bOk:=rs2.open(saQry,gaJCon[uXCon],201503161668);
            if not bOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_ERROR, 201003211648, 'Trouble with query:'+saQry,SOURCEFILE);
            end;

            if bOk and (rs2.eol=false) then
            begin
              repeat
                write(f,'define (''');
                write(f,rs.fields.Get_saValue('JDCon_Name'));
                write(f,'_');
                write(f,rs2.fields.Get_saValue('JTabl_Name'));
                writeln(f,''','''+rs2.fields.Get_saValue('JTabl_JTable_UID')+''');');
              until not rs2.movenext;
            end;
            rs2.close;
          until not rs.movenext;
        end;
      end;
      rs.close;
      if not bOk then break;
      //ASPrintLn('PHP - Bottom of Main Loop');
    end;
  end;

  if bOk then
  begin
    writeln(f,'// =================================================================');
    writeln(f,'// eof');
    writeln(f,'// =================================================================');
    write(f,'?>');
    bOk:=bTSCloseTextFile(saFilename, u2IOResult, f);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_Error, 201006262034, 'bCreatePHPJASTableDef trouble with bTSCloseTextFile. IOResult:'+
        inttostr(u2IOResult)+' '+sIOResult(u2IOResult)+' Filename:'+saFilename,SOURCEFILE);
    end;
  end;

  
  result:=bOk;
  rs.Destroy;
  rs2.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================










//=============================================================================
Function bLoadConfigurationFile: Boolean;
//=============================================================================
Var
  bOk: boolean;
  sa: AnsiString;
  ftext: text;
  saBeforeEqual: AnsiString;
  saAfterEqual: ansistring;
  sDIR: String;
  sName: String;
  sExt: String;
  
  //saValue: AnsiString;
  //satemp: AnsiString;
  
  TK: JFC_TOKENIZER;
  saConfigFile: ansistring;
{$IFDEF DEBUGLOGBEGINEND}
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bLoadConfigurationFile';{$ENDIF}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //ASDebugPrintln('BEGIN ------------ bLoadConfig');

  TK:=JFC_TOKENIZER.Create;
  FSplit(argv[0],sDir,sName,sExt);
  if paramcount=0 then
  begin
    saConfigFile:='..'+DOSSLASH+'config'+DOSSLASH+'jas.cfg';
  end
  else
  begin
    // allow hot switching config files, pass config file name
    // it stil expects it in the config directory.
    saConfigFile:='..'+DOSSLASH+'config'+DOSSLASH+paramstr(1);
  end;
  bOk:=FileExists(saConfigFile);
  If bOk Then
  Begin
    //ASPrintln('');
    //ASPrintln('Configuration File: '+grJASConfig.saConfigFile);

    //CSECTION_FILEREADMODEFLAG.Enter;
    FileMode:=READ_ONLY;
    assign(ftext, saConfigFile);
    try reset(ftext); except on e:exception do bOk:=false;end;//try

    //CSECTION_FILEREADMODEFLAG.Leave;
    // BEGIN ---- Load Config Loop
    While bOk and (not Eof(ftext)) Do
    Begin
      try readln(ftext, sa); except on e:exception do bOk:=false;end;//try
      if not bOk then break;
      //riteln('READ:',sa);
      sa:= Trim(sa);
      If (Length(sa) <> 0) and (LeftStr(sa, 1) <> ';') and (LeftStr(sa, 1) <> '//') Then
      Begin
        // MsgBox sGetStringBeforeEqualSign(s)
        saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
        saAfterEqual:=saGetStringAfterEqualSign(sa);
        //riteln('KEY:',saBeforeEqual);
        //riteln('VALUE:',saGetStringAfterEqualSign(sa));

        // ----------------------------------------------------------------------
        // BEGIN - REQUIRED OPTIONS ONLY AVAILABLE FROM jas.cfg
        // ----------------------------------------------------------------------
        If saBeforeEqual='MAINSYSTEMONLY' Then gbMainSystemOnly:=bVal(saAfterEqual) else
        If saBeforeEqual='SYSDIR' Then
        Begin
          grJASConfig.saSysDir:=saAfterEqual;
          if saRightStr(grJASConfig.saSysDir,1)<>DOSSLASH then grJASConfig.saSysDir+=DOSSLASH;
          //ASPrintln('Reading jas.cfg grJASConfig.saSysDir: '+grJASConfig.saSysDir);

          {==================================================================
          commented out for debugging purposes 2016-08-24
          ===================================================================
          // update other contingent direcory paths
          grJASConfig.saBinDir:=         grJASConfig.saSysDir+'bin'+DOSSLASH;
          grJASConfig.saCacheDir:=       grJASConfig.saSysDir+'cache'+DOSSLASH;
          grJASConfig.saConfigDir:=      grJASConfig.saSysDir+'config'+DOSSLASH;// Jegas Configuration Directory (DNS, jas  .cfg etc.)
          //grJASConfig.saDatabaseDir:=    grJASConfig.saSysDir+'database'+DOSSLASH;
          grJASConfig.saLogDir:=         grJASConfig.saSysDir+'log'+DOSSLASH;// Jegas default log directory
          grJASConfig.saPHPDir:=         grJASConfig.saSysDir+'php'+DOSSLASH;
          grJASConfig.saSetupDir:=       grJASConfig.saSysDir+'setup'+DOSSLASH;
          grJASConfig.saSoftwareDir:=    grJASConfig.saSysDir+'software'+DOSSLASH;
          grJASConfig.saSrcDir:=         grJASConfig.saSysDir+'src'+DOSSLASH;
          //grJASConfig.saTemplatesDir:=   grJASConfig.saSysDir+'templates'+DOSSLASH;
          grJASConfig.saFileDir:=        grJASConfig.saSysDir+'file'+DOSSLASH;
          grJASConfig.saWebshareDir:=    grJASConfig.saSysDir+'webshare'+DOSSLASH;
          grJASConfig.saThemeDir:=       grJASConfig.saWebshareDir+'themes'+DOSSLASH;
          ==================================================================
          }



        End else
        //If saBeforeEqual='SERVERNAME' Then grJASConfig.sServerName:=saAfterEqual else
        If saBeforeEqual='SERVERIDENT' Then grJASConfig.sServerIdent:=trim(upcase(saAfterEqual)) else
        //if saBeforeEqual='SERVERURL' then grJASConfig.sServerURL:=saAfterEqual else
        If saBeforeEqual='SERVERIP' Then grJASConfig.sServerIP:=saAfterEqual else
        If saBeforeEqual='SERVERPORT' Then grJASConfig.u2ServerPort:=u2Val(saAfterEqual) else
        // ----------------------------------------------------------------------
        // END - REQUIRED OPTIONS ONLY AVAILABLE FROM jas.cfg
        // ----------------------------------------------------------------------

        // ----------------------------------------------------------------------
        // BEGIN - OVERRIDE OPTIONS - OPTIONS HERE OVERRIDE DATABASE OPTIONS
        // ----------------------------------------------------------------------
        if saBeforeEqual='SYSDIR'                              then grJASConfig.saSysDir:=saAfterEqual else
        if saBeforeEqual='PHPDIR'                              then begin rConfigOverridden.bsaPHPDir                              :=true; grJASConfig.saPHPDir                            :=      saAfterEqual;end else
        if saBeforeEqual='LOGDIR'                              then begin rConfigOverridden.bsaLogDir                              :=true; grJASConfig.saLogDir                              :=      saAfterEqual;end else
        if saBeforeEqual='PHP'                                 then begin rConfigOverridden.bsaPHP                                 :=true; grJASConfig.saPHP                               :=      saAfterEqual;end else
        if saBeforeEqual='PERL'                                then begin rConfigOverridden.bsaPerl                                :=true; grJASConfig.saPerl                              :=      saAfterEqual;end else
        if saBeforeEqual='JASFOOTER'                           then begin rConfigOverridden.bsaJASFooter                           :=true; grJASConfig.saJASFooter                         :=      saAfterEqual;end else
        if saBeforeEqual='THREADPOOLNOOFTHREADS'               then begin rConfigOverridden.bu2ThreadPoolNoOfThreads               :=true; grJASConfig.u2ThreadPoolNoOfThreads             :=u2Val(saAfterEqual);end else
        if saBeforeEqual='THREADPOOLMAXIMUMRUNTIMEINMSEC'      then begin rConfigOverridden.buThreadPoolMaximumRunTimeInMSec       :=true; grJASConfig.uThreadPoolMaximumRunTimeInMSec     :=uVal( saAfterEqual);end else
        //if saBeforeEqual='SERVERURL'                           then begin rConfigOverridden.bsServerURL                            :=true; grJASConfig.sServerURL                           :=      saAfterEqual;end else
        //if saBeforeEqual='SERVERNAME'                          then begin rConfigOverridden.bsServerName                           :=true; grJASConfig.sServerName                         :=      saAfterEqual;end else
        if saBeforeEqual='SERVERIDENT'                         then begin rConfigOverridden.bsServerIdent                          :=true; grJASConfig.sServerIdent                        :=      saAfterEqual;end else
        if saBeforeEqual='DEFAULTLANGUAGE'                     then begin rConfigOverridden.bsDefaultLanguage                      :=true; grJASConfig.sDefaultLanguage                    :=      saAfterEqual;end else
        if saBeforeEqual='ENABLESSL'                           then begin rConfigOverridden.bbEnableSSL                            :=true; grJASConfig.bEnableSSL                          :=bVal( saAfterEqual);end else
        if saBeforeEqual='REDIRECTTOPORT443'                   then begin rConfigOverridden.bbRedirectToPort443                    :=true; grJASConfig.bRedirectToPort443                  :=bVal( saAfterEqual);end else
        if saBeforeEqual='DEFAULTMENURENDERMETHOD'             then begin rConfigOverridden.bu1DefaultMenuRenderMethod             :=true; grJASConfig.u1DefaultMenuRenderMethod           :=u1Val(saAfterEqual);end else
        if saBeforeEqual='SERVERIP'                            then begin rConfigOverridden.bsServerIP                             :=true; grJASConfig.sServerIP                           :=      saAfterEqual;end else
        if saBeforeEqual='SERVERPORT'                          then begin rConfigOverridden.bu2ServerPort                          :=true; grJASConfig.u2ServerPort                        :=u2Val(saAfterEqual);end else
        if saBeforeEqual='RETRYLIMIT'                          then begin rConfigOverridden.bu2RetryLimit                          :=true; grJASConfig.u2RetryLimit                        :=u2Val(saAfterEqual);end else
        if saBeforeEqual='RETRYDELAYINMSEC'                    then begin rConfigOverridden.bu4RetryDelayInMSec                    :=true; grJASConfig.u4RetryDelayInMSec                  :=u4Val(saAfterEqual);end else
        if saBeforeEqual='TIMEZONEOFFSET'                      then begin rConfigOverridden.bi1TIMEZONEOFFSET                      :=true; grJASConfig.i1TIMEZONEOFFSET                    :=i1Val(saAfterEqual);end else
        if saBeforeEqual='MAXFILEHANDLES'                      then begin rConfigOverridden.bu4MaxFileHandles                      :=true; grJASConfig.u4MaxFileHandles                    :=u4Val(saAfterEqual);end else
        if saBeforeEqual='BLACKLISTENABLED'                    then begin rConfigOverridden.bbBlacklistEnabled                     :=true; grJASConfig.bBlacklistEnabled                   :=bVal( saAfterEqual);end else
        if saBeforeEqual='WHITELISTENABLED'                    then begin rConfigOverridden.bbWhiteListEnabled                     :=true; grJASConfig.bWhiteListEnabled                   :=bVal( saAfterEqual);end else
        if saBeforeEqual='BLACKLISTIPEXPIRE'                   then begin rConfigOverridden.bbBlacklistIPExpire                    :=true; grJASConfig.bBlacklistIPExpire                  :=bVal( saAfterEqual);end else
        if saBeforeEqual='WHITELISTIPEXPIRE'                   then begin rConfigOverridden.bbWhitelistIPExpire                    :=true; grJASConfig.bWhitelistIPExpire                  :=bVal( saAfterEqual);end else
        if saBeforeEqual='INVALIDLOGINSEXPIRE'                 then begin rConfigOverridden.bbInvalidLoginsExpire                  :=true; grJASConfig.bInvalidLoginsExpire                :=bVal( saAfterEqual);end else
        if saBeforeEqual='BLACKLISTDAYSUNTILEXPIRE'            then begin rConfigOverridden.bu2BlacklistDaysUntilExpire            :=true; grJASConfig.u2BlacklistDaysUntilExpire          :=u2Val(saAfterEqual);end else
        if saBeforeEqual='WHITELISTDAYSUNTILEXPIRE'            then begin rConfigOverridden.bu2WhitelistDaysUntilExpire            :=true; grJASConfig.u2WhitelistDaysUntilExpire          :=u2Val(saAfterEqual);end else
        if saBeforeEqual='INVALIDLOGINSDAYSUNTILEXPIRE'        then begin rConfigOverridden.bu2InvalidLoginsDaysUntilExpire        :=true; grJASConfig.u2InvalidLoginsDaysUntilExpire      :=u2Val(saAfterEqual);end else
        if saBeforeEqual='JOBQENABLED'                         then begin rConfigOverridden.bbJobQEnabled                          :=true; grJASConfig.bJobQEnabled                        :=bVal( saAfterEqual);end else
        if saBeforeEqual='JOBQINTERVALINMSEC'                  then begin rConfigOverridden.bu4JobQIntervalInMSec                  :=true; grJASConfig.u4JobQIntervalInMSec                :=u4Val(saAfterEqual);end else
        if saBeforeEqual='SMTPHOST'                            then begin rConfigOverridden.bsSMTPHost                             :=true; grJASConfig.sSMTPHost                           :=      saAfterEqual;end else
        if saBeforeEqual='SMTPUSERNAME'                        then begin rConfigOverridden.bsSMTPUsername                         :=true; grJASConfig.sSMTPUsername                       :=      saAfterEqual;end else
        if saBeforeEqual='SMTPPASSWORD'                        then begin rConfigOverridden.bsSMTPPassword                         :=true; grJASConfig.sSMTPPassword                       :=      saAfterEqual;end else
        if saBeforeEqual='PROTECTJASRECORDS'                   then begin rConfigOverridden.bbProtectJASRecords                    :=true; grJASConfig.bProtectJASRecords                  :=bVal( saAfterEqual);end else
        if saBeforeEqual='SAFEDELETE'                          then begin rConfigOverridden.bbSafeDelete                           :=true; grJASConfig.bSafeDelete                         :=bVal( saAfterEqual);end else
        if saBeforeEqual='ALLOWVIRTUALHOSTCREATION'            then begin rConfigOverridden.bbAllowVirtualHostCreation             :=true; grJASConfig.bAllowVirtualHostCreation           :=bVal( saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEENABLED'                   then begin rConfigOverridden.bbPunkBeGoneEnabled                    :=true; grJASConfig.bPunkBeGoneEnabled                  :=bVal( saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEMAXERRORS'                 then begin rConfigOverridden.bu2PunkBeGoneMaxErrors                 :=true; grJASConfig.u2PunkBeGoneMaxErrors               :=u2Val(saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEMAXMINUTES'                then begin rConfigOverridden.bu2PunkBeGoneMaxMinutes                :=true; grJASConfig.u2PunkBeGoneMaxMinutes              :=u2Val(saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEINTERVALINMSEC'            then begin rConfigOverridden.bu4PunkBeGoneIntervalInMSec            :=true; grJASConfig.u4PunkBeGoneIntervalInMSec          :=u4Val(saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEIPHOLDTIMEINDAYS'          then begin rConfigOverridden.bu2PunkBeGoneIPHoldTimeInDays          :=true; grJASConfig.u2PunkBeGoneIPHoldTimeInDays        :=u2Val(saAfterEqual);end else
        if saBeforeEqual='PUNKBEGONEMAXDOWNLOADS'              then begin rConfigOverridden.bu2PunkBeGoneMaxDownloads              :=true; grJASConfig.u2PunkBeGoneMaxDownloads            :=u2Val(saAfterEqual);end else
        if saBeforeEqual='UNKBEGONESMACKBADBOTS'               then begin rConfigOverridden.bbPunkBeGoneSmackBadBots               :=true; grJASConfig.bPunkBeGoneSmackBadBots             :=bVal( saAfterEqual);end else
        if saBeforeEqual='LOGLEVEL'                            then begin rConfigOverridden.bu2LogLevel                            :=true; grJASConfig.u2LogLevel                          :=u2Val(saAfterEqual);end else
        if saBeforeEqual='DELETELOGFILE'                       then begin rConfigOverridden.bbDeleteLogFile                        :=true; grJASConfig.bDeleteLogFile                      :=bVal( saAfterEqual);end else
        If saBeforeEqual='ERRORREPORTINGMODE' then
        begin
          rConfigOverridden.bu2ErrorReportingMode:=true;
          sa:=upcase(saAfterEqual);
          if sa='VERBOSE' then
          begin
            //ASPrintln('Error Rep Mode: Verbose');
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
          end
          else

          if sa='VERBOSELOCAL' then
          begin
            //ASPrintln('Error Rep Mode: Verbose Local');
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_VERBOSELOCAL;
          end
          else
          begin
            //ASPrintln('Error Rep Mode: Secure');
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
          end;
        end else
        if saBeforeEqual='ERRORREPORTINGSECUREMESSAGE'         then begin rConfigOverridden.bsaErrorReportingSecureMessage         :=true; grJASConfig.saErrorReportingSecureMessage       :=saAfterEqual;end else
        if saBeforeEqual='SQLTRACELOGENABLED'                  then begin rConfigOverridden.bbSQLTraceLogEnabled                   :=true; grJASConfig.bSQLTraceLogEnabled                 :=bVal(saAfterEqual);end else
        if saBeforeEqual='SERVERCONSOLEMESSAGESENABLED'        then begin rConfigOverridden.bbServerConsoleMessagesEnabled         :=true; grJASConfig.bServerConsoleMessagesEnabled       :=bVal(saAfterEqual);end else
        if saBeforeEqual='DEBUGSERVERCONSOLEMESSAGESENABLED'   then begin rConfigOverridden.bbDebugServerConsoleMessagesEnabled    :=true; grJASConfig.bDebugServerConsoleMessagesEnabled  :=bVal(saAfterEqual);end else
        if saBeforeEqual='DEBUGMODE'                           then
        begin
          rConfigOverridden.bu2DebugMode                           :=true;
          sa:=UpCase(saAfterEqual);
          if sa='VERBOSE' then
          begin
            grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_VERBOSE;
          end
          else

          if sa='VERBOSELOCAL' then
          begin
            grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_VERBOSELOCAL;
          end
          else
          begin
            grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_SECURE;
          end;
        end else
        if saBeforeEqual='RECYCLESESSIONS'                     then begin rConfigOverridden.bbRecycleSessions                      :=true; grJASCOnfig.bRecycleSessions                    :=bVal(saAfterEqual);end else
        if saBeforeEqual='SESSIONTIMEOUTINMINUTES'             then begin rConfigOverridden.bu2SessionTimeOutInMinutes             :=true; grJASConfig.u2SessionTimeOutInMinutes           :=u2Val(saAfterEqual);end else
        if saBeforeEqual='LOCKTIMEOUTINMINUTES'                then begin rConfigOverridden.bu2LockTimeOutInMinutes                :=true; grJASConfig.u2LockTimeOutInMinutes              :=u2Val(saAfterEqual);end else
        if saBeforeEqual='LOCKRETRIESBEFOREFAILURE'            then begin rConfigOverridden.bu2LockRetriesBeforeFailure            :=true; grJASConfig.u2LockRetriesBeforeFailure          :=u2Val(saAfterEqual);end else
        if saBeforeEqual='LOCKRETRYDELAYINMSEC'                then begin rConfigOverridden.bu2LockRetryDelayInMSec                :=true; grJASConfig.u2LockRetryDelayInMSec              :=u2Val(saAfterEqual);end else
        if saBeforeEqual='VALIDATESESSIONRETRYLIMIT'           then begin rConfigOverridden.bu2ValidateSessionRetryLimit           :=true; grJASConfig.u2ValidateSessionRetryLimit         :=u2Val(saAfterEqual);end else
        If saBeforeEqual='MAXIMUMREQUESTHEADERLENGTH' then
        begin
          rConfigOverridden.buMaximumRequestHeaderLength:=true;
          {$IFDEF CPU32}
          grJASConfig.uMaximumRequestHeaderLength:=u4Val(saAfterEqual);
          {$ELSE}
          grJASConfig.uMaximumRequestHeaderLength:=u8Val(saAfterEqual);
          {$ENDIF}
        end else
        if saBeforeEqual='CREATESOCKETRETRY'                   then begin rConfigOverridden.bu2CreateSocketRetry                   :=true; grJASConfig.u2CreateSocketRetry                 :=u2Val(saAfterEqual);end else
        if saBeforeEqual='CREATESOCKETRETRYDELAYINMSEC'        then begin rConfigOverridden.bu2CreateSocketRetryDelayInMSec        :=true; grJASConfig.u2CreateSocketRetryDelayInMSec      :=u2Val(saAfterEqual);end else
        if saBeforeEqual='SOCKETTIMEOUTINMSEC'                 then begin rConfigOverridden.bu2SocketTimeOutInMSec                 :=true; grJASConfig.u2SocketTimeOutInMSec               :=u2Val(saAfterEqual);end else
        if saBeforeEqual='ENABLESSL'                           then begin rConfigOverridden.bbEnableSSL                            :=true; grJASConfig.bEnableSSL                          :=bVal(saAfterEqual);end else
        if saBeforeEqual='HOOK_ACTION_CREATESESSION_FAILURE'   then begin rConfigOverridden.bsHOOK_ACTION_CREATESESSION_FAILURE    :=true; grJASConfig.sHOOK_ACTION_CREATESESSION_FAILURE  :=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_CREATESESSION_SUCCESS'   then begin rConfigOverridden.bsHOOK_ACTION_CREATESESSION_SUCCESS    :=true; grJASConfig.sHOOK_ACTION_CREATESESSION_SUCCESS  :=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_REMOVESESSION_FAILURE'   then begin rConfigOverridden.bsHOOK_ACTION_REMOVESESSION_FAILURE    :=true; grJASConfig.sHOOK_ACTION_REMOVESESSION_FAILURE  :=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_REMOVESESSION_SUCCESS'   then begin rConfigOverridden.bsHOOK_ACTION_REMOVESESSION_SUCCESS    :=true; grJASConfig.sHOOK_ACTION_REMOVESESSION_SUCCESS  :=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_SESSIONTIMEOUT'          then begin rConfigOverridden.bsHOOK_ACTION_SESSIONTIMEOUT           :=true; grJASConfig.sHOOK_ACTION_SESSIONTIMEOUT         :=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_VALIDATESESSION_FAILURE' then begin rConfigOverridden.bsHOOK_ACTION_VALIDATESESSION_FAILURE  :=true; grJASConfig.sHOOK_ACTION_VALIDATESESSION_FAILURE:=saAfterEqual;end else
        if saBeforeEqual='HOOK_ACTION_VALIDATESESSION_SUCCESS' then begin rConfigOverridden.bsHOOK_ACTION_VALIDATESESSION_SUCCESS  :=true; grJASConfig.sHOOK_ACTION_VALIDATESESSION_SUCCESS:=saAfterEqual;end else
        if saBeforeEqual='CLIENTTOVICISERVERIP'                then begin rConfigOverridden.bsClientToVICIServerIP                 :=true; grJASConfig.sClientToVICIServerIP               :=saAfterEqual;end else
        if saBeforeEqual='JASSERVERTOVICISERVERIP'             then begin rConfigOverridden.bsJASServertoVICIServerIP              :=true; grJASConfig.sJASServertoVICIServerIP            :=saAfterEqual;end else
        if saBeforeEqual='CREATEHYBRIDJETS'                    then begin rConfigOverridden.bbCreateHybridJets                     :=true; grJASConfig.bCreateHybridJets                   :=bVal(saAfterEqual);end else
        if saBeforeEqual='RECORDLOCKINGENABLED'                then begin rConfigOverridden.bbRecordLockingEnabled                 :=true; grJASConfig.bRecordLockingEnabled               :=bVal(saAfterEqual);end else
        if saBeforeEqual='LISTENDURATIONINMSEC'                then begin rConfigOverridden.bu4ListenDurationInMSec                :=true; grJASConfig.u4ListenDurationInMSec              :=u4Val(saAfterEqual);end else
        // ----------------------------------------------------------------------
        // END - OVERRIDE OPTIONS - OPTIONS HERE OVERRIDE DATABASE OPTIONS
        // ----------------------------------------------------------------------











        //Finish THIS BELOW then do the same for the Config Strutre grJASConfig


        // ----------------------------------------------------------------------
        // BEGIN - Virtual Host Overrides
        // ----------------------------------------------------------------------
        if saBeforeEqual='VHOST_ALLOWREGISTRATION_B'     then begin rJVHostOverridden.bVHost_AllowRegistration_b     :=true; rJVHostOverride.VHost_AllowRegistration_b     :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_REGISTERREQCELLPHONE_B'  then begin rJVHostOverridden.bVHost_RegisterReqCellPhone_b  :=true; rJVHostOverride.VHost_RegisterReqCellPhone_b  :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_REGISTERREQBIRTHDAY_B'   then begin rJVHostOverridden.bVHost_RegisterReqBirthday_b   :=true; rJVHostOverride.VHost_RegisterReqBirthday_b   :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_JVHOST_UID'              then begin rJVHostOverridden.bVHost_JVHost_UID              :=true; rJVHostOverride.VHost_JVHost_UID              :=u8Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_WEBROOTDIR'              then begin rJVHostOverridden.bVHost_WebRootDir              :=true; rJVHostOverride.VHost_WebRootDir              :=saFixSlash(saAfterEqual); end else
        if saBeforeEqual='VHOST_SERVERNAME'              then begin rJVHostOverridden.bVHost_ServerName              :=true; rJVHostOverride.VHost_ServerName              :=saGetStringAfterEqualSign(sa); end else
        if saBeforeEqual='VHOST_SERVERIDENT'             then begin rJVHostOverridden.bVHost_ServerIdent             :=true; rJVHostOverride.VHost_ServerIdent             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_SERVERURL'               then begin rJVHostOverridden.bVHost_ServerURL               :=true; rJVHostOverride.VHost_ServerURL               :=saAfterEqual; end else
        if saBeforeEqual='VHOST_SERVERDOMAIN'            then begin rJVHostOverridden.bVHost_ServerDomain            :=true; rJVHostOverride.VHost_ServerDomain            :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTLANGUAGE'         then begin rJVHostOverridden.bVHost_DefaultLanguage         :=true; rJVHostOverride.VHost_DefaultLanguage         :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTTHEME'            then begin rJVHostOverridden.bVHost_DefaultTheme            :=true; rJVHostOverride.VHost_DefaultTheme            :=saAfterEqual; end else
        if saBeforeEqual='VHOST_MENURENDERMETHOD'        then begin rJVHostOverridden.bVHost_MenuRenderMethod        :=true; rJVHostOverride.VHost_MenuRenderMethod        :=u2Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_DEFAULTAREA'             then begin rJVHostOverridden.bVHost_DefaultArea             :=true; rJVHostOverride.VHost_DefaultArea             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTPAGE'             then begin rJVHostOverridden.bVHost_DefaultPage             :=true; rJVHostOverride.VHost_DefaultPage             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTSECTION'          then begin rJVHostOverridden.bVHost_DefaultSection          :=true; rJVHostOverride.VHost_DefaultSection          :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTTOP_JMENU_ID'     then begin rJVHostOverridden.bVHost_DefaultTop_JMenu_ID     :=true; rJVHostOverride.VHost_DefaultTop_JMenu_ID     :=u8Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_DEFAULTLOGGEDINPAGE'     then begin rJVHostOverridden.bVHost_DefaultLoggedInPage     :=true; rJVHostOverride.VHost_DefaultLoggedInPage     :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTLOGGEDOUTPAGE'    then begin rJVHostOverridden.bVHost_DefaultLoggedOutPage    :=true; rJVHostOverride.VHost_DefaultLoggedOutPage    :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DATAONRIGHT_B'           then begin rJVHostOverridden.bVHost_DataOnRight_b           :=true; rJVHostOverride.VHost_DataOnRight_b           :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_CACHEMAXAGEINSECONDS'    then begin rJVHostOverridden.bVHost_CacheMaxAgeInSeconds    :=true; rJVHostOverride.VHost_CacheMaxAgeInSeconds    :=u2Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_SYSTEMEMAILFROMADDRESS'  then begin rJVHostOverridden.bVHost_SystemEmailFromAddress  :=true; rJVHostOverride.VHost_SystemEmailFromAddress  :=saAfterEqual; end else
        if saBeforeEqual='VHOST_SHARESDEFAULTDOMAIN_B'   then begin rJVHostOverridden.bVHost_SharesDefaultDomain_b   :=true; rJVHostOverride.VHost_SharesDefaultDomain_b   :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_DEFAULTICONTHEME'        then begin rJVHostOverridden.bVHost_DefaultIconTheme        :=true; rJVHostOverride.VHost_DefaultIconTheme        :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DIRECTORYLISTING_B'      then begin rJVHostOverridden.bVHost_DirectoryListing_b      :=true; rJVHostOverride.VHost_DirectoryListing_b      :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_FILEDIR'                 then begin rJVHostOverridden.bVHost_FileDir                 :=true; rJVHostOverride.VHost_FileDir                 :=saFixSlash(saAfterEqual); end else
        if saBeforeEqual='VHOST_ACCESSLOG'               then begin rJVHostOverridden.bVHost_AccessLog               :=true; rJVHostOverride.VHost_AccessLog               :=saFixSlash(saAfterEqual); end else
        if saBeforeEqual='VHOST_ERRORLOG'                then begin rJVHostOverridden.bVHost_ErrorLog                :=true; rJVHostOverride.VHost_ErrorLog                :=saFixSlash(saAfterEqual); end else
        if saBeforeEqual='VHOST_JDCONNECTION_ID'         then begin rJVHostOverridden.bVHost_JDConnection_ID         :=true; rJVHostOverride.VHost_JDConnection_ID         :=u8Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_ENABLED_B'               then begin rJVHostOverridden.bVHost_Enabled_b               :=true; rJVHostOverride.VHost_Enabled_b               :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_TEMPLATEDIR'             then begin rJVHostOverridden.bVHost_TemplateDir             :=true; rJVHostOverride.VHost_TemplateDir             :=saFixSlash(saAfterEqual); end else
        if saBeforeEqual='VHOST_SIPURL'                  then begin rJVHostOverridden.bVHOST_SipURL                  :=true; rJVHostOverride.VHOST_SipURL                  :=saAfterEqual; end else
        if saBeforeEqual='VHOST_WEBSHAREDIR'             then begin rJVHostOverridden.bVHOST_WebshareDir             :=true; rJVHostOverride.VHOST_WebshareDir             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_WEBSHAREALIAS'           then begin rJVHostOverridden.bVHOST_WebShareAlias           :=true; rJVHostOverride.VHOST_WebShareAlias           :=saAfterEqual; end else
        if saBeforeEqual='VHOST_CACHEDIR'                then begin rJVHostOverridden.bVHOST_CacheDir                :=true; rJVHostOverride.VHOST_CacheDir                :=saFixSlash(saAfterEqual); end else
        //if saBeforeEqual='VHOST _LOGDIR'                  then begin rJVHostOverridden.bVHOST _LogDir                  :=true; rJVHostOverride.VHOST _LogDir                  :=saFixSlash(saAfterEqual); end else
        //if saBeforeEqual='VHOST _THEMEDIR'                then begin rJVHostOverridden.bVHOST _ThemeDir                :=true; rJVHostOverride.VHOST _ThemeDir                :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTAREA'            then begin rJVHostOverridden.bVHOST_DefaultArea              :=true; rJVHostOverride.VHOST_DefaultArea             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTPAGE'            then begin rJVHostOverridden.bVHOST_DefaultPage              :=true; rJVHostOverride.VHOST_DefaultPage             :=saAfterEqual; end else
        if saBeforeEqual='VHOST_DEFAULTSECTION'         then begin rJVHostOverridden.bVHOST_DefaultSection           :=true; rJVHostOverride.VHOST_DefaultSection          :=saAfterEqual; end else
        if saBeforeEqual='VHOST_PASSWORDKEY_U1'         then begin rJVHostOverridden.bVHOST_PasswordKey_u1           :=true; rJVHostOverride.VHOST_PasswordKey_u1          :=u1Val(saAfterEqual); end else
        if saBeforeEqual='VHOST_LOGTODATABASE_B'        then begin rJVHostOverridden.bVHost_LogToDataBase_b          :=true; rJVHostOverride.VHost_LogToDataBase_b         :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_LOGTOCONSOLE_B'         then begin rJVHostOverridden.bVHost_LogToConsole_b           :=true; rJVHostOverride.VHost_LogToConsole_b          :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_LOGREQUESTSTODATABASE_B'then begin rJVHostOverridden.bVHost_LogRequestsToDatabase_b  :=true; rJVHostOverride.VHost_LogRequestsToDatabase_b :=bVal(saAfterEqual); end else
        if saBeforeEqual='VHOST_ACCESSLOG'              then begin rJVHostOverridden.bVHost_AccessLog                :=true; rJVHostOverride.VHost_AccessLog               :=saAfterEqual; end else
        if saBeforeEqual='VHOST_ERRORLOG'               then begin rJVHostOverridden.bVHost_ErrorLog                 :=true; rJVHostOverride.VHost_ErrorLog                :=saAfterEqual; end;
        if saBeforeEqual='VHOST_HEADERS_B'              then begin rJVHostOverridden.bVHost_Headers_b                :=true; rJVHostOverride.VHost_Headers_b               :=bVal(saAfterEqual); end;
        if saBeforeEqual='VHOST_QUICKLINKS_B'           then begin rJVHostOverridden.bVHost_QuickLinks_b             :=true; rJVHostOverride.VHost_QuickLinks_b            :=bVal(saAfterEqual); end;
        if saBeforeEqual='VHOST_DEFAULTDATEMASK'        then begin rJVHostOverridden.bVHost_DefaultDateMask          :=true; rJVHostOverride.VHost_DefaultDateMask         :=saAfterEqual; end;
        if saBeforeEqual='VHOST_BACKGROUND'             then begin rJVHostOverridden.bVHost_Background               :=true; rJVHostOverride.VHost_Background              :=saAfterEqual; end;
        if saBeforeEqual='VHOST_BACKGROUNDREPEAT_B'     then begin rJVHostOverridden.bVHost_BackgroundRepeat_b       :=true; rJVHostOverride.VHost_BackgroundRepeat_b      :=bVal(saAfterEqual); end;

      End;// if
    End;// while loop
    try close(ftext); except on E:Exception do bOk:=false; end;//try
    // END   ---- Load Config Loop
    Result:=bOk;
  End 
  Else
  Begin
    JASPrintln('Config File Missing:'+saConfigFile);
    Result:=False;
  End;
  TK.Destroy;
  //ASDebugPrintln('END ------------ bLoadConfig');
{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================







































//=============================================================================
function bOpenDatabaseConnections: boolean;
//=============================================================================
var
  bOk: boolean;
  rs: JADO_RECORDSET;
  i4: longint;
  saQry: ansistring;
  saDBCFilename: ansistring;
  bUnableToOpen: boolean;
  saMsg:ansistring;
  u8DataIn: UInt64;
  saDataIn: ansistring;
  //bGotOne: boolean;
  //i4DefaultHostCount: longint;
  bDone: boolean;
  iDBX: longint;// used during menu loading and PER JET preference Loading
  iHost: longint;
  sa: ansistring;
  //u2IOResult: word;
 // u8: UInt64;
  u8RowsOfIP: UInt64;
  saDBCFile: ansistring;
  DIR: JFC_DIR;
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bOpenDatabaseConnections';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.create;
  If bOk Then
  Begin
    setlength(gaJCon,1);
    gaJCon[0]:=JADO_CONNECTION.Create;
    gaJCon[0].ID:=1;
    // Force Connection to behave as a JAS connection which means
    // when it connects it will initially load the JADO_CONNECTION.JASTABLEMATRIX
    // with table names, uids and jdconnection values for each table in jtable
    gaJCon[0].bJas:=true;
    gaJCon[0].JDCon_JSecPerm_ID:=cnPerm_DB_Connection_JAS;// 2012101522403599143 = DB Connection JAS
    saDBCFile:=grJASConfig.saSysDir+DOSSLASH+'config'+DOSSLASH+'jas.dbc';
    bOk:=gaJCon[0].bLoad(saDBCFile);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_FATAL, 200609161542, '****Unable to LOAD MAIN Database Connection file:'+saDBCFile, SOURCEFILE);
    end;
  end;

  //riteln(saRepeatchar('=',79));
  //riteln(saRepeatchar('=',79));
  //ASPrintln('Core_Init Opening MAIN database connection');
  if bOk then
  begin
    bOk:=gaJCon[0].OpenCon;
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_FATAL, 201002061630, '****Unable to OPEN MAIN Database Connection. '+GetCurrentDir, SOURCEFILE);
    end;
  end;
  //ASPrintln('Success Opening main Database:'+sYesNo(bok));
  //riteln(saRepeatchar('=',79));
  //riteln(saRepeatchar('=',79));
  if bOk then
  begin
    if bOk then bok:=rs.open('select 1 from jaccesslog'       , gaJCon[0],201610180322);
    if bOk then bok:=rs.open('select 1 from jadodbms'         , gaJCon[0],201610180323);
    if bOk then bok:=rs.open('select 1 from jadodriver'       , gaJCon[0],201610180324);
    if bOk then bok:=rs.open('select 1 from jalias'           , gaJCon[0],201610180325);
    if bOk then bok:=rs.open('select 1 from jasident'         , gaJCon[0],201610180326);
    if bOk then bok:=rs.open('select 1 from jblog'            , gaJCon[0],201610180327);
    if bOk then bok:=rs.open('select 1 from jblok'            , gaJCon[0],201610180328);
    if bOk then bok:=rs.open('select 1 from jblokbutton'      , gaJCon[0],201610180329);
    if bOk then bok:=rs.open('select 1 from jblokfield'       , gaJCon[0],201610180330);
    if bOk then bok:=rs.open('select 1 from jbloktype'        , gaJCon[0],201610180331);
    if bOk then bok:=rs.open('select 1 from jbuttontype'      , gaJCon[0],201610180332);
    if bOk then bok:=rs.open('select 1 from jcaption'         , gaJCon[0],201610180333);
    if bOk then bok:=rs.open('select 1 from jcase'            , gaJCon[0],201610180334);
    if bOk then bok:=rs.open('select 1 from jcasecategory'    , gaJCon[0],201610180335);
    if bOk then bok:=rs.open('select 1 from jcasesource'      , gaJCon[0],201610180336);
    if bOk then bok:=rs.open('select 1 from jcasesubject'     , gaJCon[0],201610180337);
    if bOk then bok:=rs.open('select 1 from jcasetype'        , gaJCon[0],201610180338);
    if bOk then bok:=rs.open('select 1 from jclickaction'     , gaJCon[0],201610180339);
    if bOk then bok:=rs.open('select 1 from jcolumn'          , gaJCon[0],201610180340);
    if bOk then bok:=rs.open('select 1 from jdconnection'     , gaJCon[0],201610180341);
    if bOk then bok:=rs.open('select 1 from jdebug'           , gaJCon[0],201610180342);
    if bOk then bok:=rs.open('select 1 from jdownloadfilelist', gaJCon[0],201610180343);
    if bOk then bok:=rs.open('select 1 from jdtype'           , gaJCon[0],201610180344);
    if bOk then bok:=rs.open('select 1 from jegaslog'         , gaJCon[0],201610180345);
    if bOk then bok:=rs.open('select 1 from jerrorlog'        , gaJCon[0],201610180346);
    if bOk then bok:=rs.open('select 1 from jetname'          , gaJCon[0],201610180347);
    if bOk then bok:=rs.open('select 1 from jfile'            , gaJCon[0],201610180348);
    if bOk then bok:=rs.open('select 1 from jfiltersave'      , gaJCon[0],201610180349);
    if bOk then bok:=rs.open('select 1 from jfiltersavedef'   , gaJCon[0],201610180350);
    if bOk then bok:=rs.open('select 1 from jhelp'            , gaJCon[0],201610180351);
    if bOk then bok:=rs.open('select 1 from jiconcontext'     , gaJCon[0],201610180352);
    if bOk then bok:=rs.open('select 1 from jiconmaster'      , gaJCon[0],201610180353);
    if bOk then bok:=rs.open('select 1 from jindexfile'       , gaJCon[0],201610180354);
    if bOk then bok:=rs.open('select 1 from jindustry'        , gaJCon[0],201610180355);
    if bOk then bok:=rs.open('select 1 from jinstalled'       , gaJCon[0],201610180356);
    if bOk then bok:=rs.open('select 1 from jinterface'       , gaJCon[0],201610180357);
    if bOk then bok:=rs.open('select 1 from jinvoice'         , gaJCon[0],201610180358);
    if bOk then bok:=rs.open('select 1 from jinvoicelines'    , gaJCon[0],201610180359);
    if bOk then bok:=rs.open('select 1 from jiplist'          , gaJCon[0],201610180360);
    if bOk then bok:=rs.open('select 1 from jiplistlu'        , gaJCon[0],201610180361);
    if bOk then bok:=rs.open('select 1 from jipstat'          , gaJCon[0],201610180362);
    if bOk then bok:=rs.open('select 1 from jjobq'            , gaJCon[0],201610180363);
    if bOk then bok:=rs.open('select 1 from jjobtype'         , gaJCon[0],201610180364);
    if bOk then bok:=rs.open('select 1 from jlanguage'        , gaJCon[0],201610180365);
    if bOk then bok:=rs.open('select 1 from jlead'            , gaJCon[0],201610180366);
    if bOk then bok:=rs.open('select 1 from jleadsource'      , gaJCon[0],201610180367);
    if bOk then bok:=rs.open('select 1 from jlock'            , gaJCon[0],201610180368);
    if bOk then bok:=rs.open('select 1 from jlog'             , gaJCon[0],201610180369);
    if bOk then bok:=rs.open('select 1 from jlogtype'         , gaJCon[0],201610180370);
    if bOk then bok:=rs.open('select 1 from jlookup'          , gaJCon[0],201610180371);
    if bOk then bok:=rs.open('select 1 from jmail'            , gaJCon[0],201610180372);
    if bOk then bok:=rs.open('select 1 from jmenu'            , gaJCon[0],201610180373);
    if bOk then bok:=rs.open('select 1 from jmime'            , gaJCon[0],201610180374);
    if bOk then bok:=rs.open('select 1 from jmodc'            , gaJCon[0],201610180375);
    if bOk then bok:=rs.open('select 1 from jmodule'          , gaJCon[0],201610180376);
    if bOk then bok:=rs.open('select 1 from jmoduleconfig'    , gaJCon[0],201610180377);
    if bOk then bok:=rs.open('select 1 from jmodulesetting'   , gaJCon[0],201610180378);
    if bOk then bok:=rs.open('select 1 from jnote'            , gaJCon[0],201610180379);
    if bOk then bok:=rs.open('select 1 from jorg'             , gaJCon[0],201610180380);
    if bOk then bok:=rs.open('select 1 from jorgpers'         , gaJCon[0],201610180381);
    if bOk then bok:=rs.open('select 1 from jpassword'        , gaJCon[0],201610180382);
    if bOk then bok:=rs.open('select 1 from jperson'          , gaJCon[0],201610180383);
    if bOk then bok:=rs.open('select 1 from jpersonskill'     , gaJCon[0],201610180384);
    if bOk then bok:=rs.open('select 1 from jprinter'         , gaJCon[0],201610180385);
    if bOk then bok:=rs.open('select 1 from jpriority'        , gaJCon[0],201610180386);
    if bOk then bok:=rs.open('select 1 from jproduct'         , gaJCon[0],201610180387);
    if bOk then bok:=rs.open('select 1 from jproductgrp'      , gaJCon[0],201610180388);
    if bOk then bok:=rs.open('select 1 from jproductqty'      , gaJCon[0],201610180389);
    if bOk then bok:=rs.open('select 1 from jproject'         , gaJCon[0],201610180390);
    if bOk then bok:=rs.open('select 1 from jprojectcategory' , gaJCon[0],201610180391);
    if bOk then bok:=rs.open('select 1 from jprojectpriority' , gaJCon[0],201610180392);
    if bOk then bok:=rs.open('select 1 from jprojectstatus'   , gaJCon[0],201610180393);
    if bOk then bok:=rs.open('select 1 from jpunkbait'        , gaJCon[0],201610180394);
    if bOk then bok:=rs.open('select 1 from jquicklink'       , gaJCon[0],201610180395);
    if bOk then bok:=rs.open('select 1 from jquicknote'       , gaJCon[0],201610180396);
    if bOk then bok:=rs.open('select 1 from jredirect'        , gaJCon[0],201610180397);
    if bOk then bok:=rs.open('select 1 from jredirectlu'      , gaJCon[0],201610180398);
    if bOk then bok:=rs.open('select 1 from jrequestlog'      , gaJCon[0],201610180399);
    if bOk then bok:=rs.open('select 1 from jscreen'          , gaJCon[0],201610180400);
    if bOk then bok:=rs.open('select 1 from jscreentype'      , gaJCon[0],201610180401);
    if bOk then bok:=rs.open('select 1 from jsecgrp'          , gaJCon[0],201610180402);
    if bOk then bok:=rs.open('select 1 from jsecgrplink'      , gaJCon[0],201610180403);
    if bOk then bok:=rs.open('select 1 from jsecgrpuserlink'  , gaJCon[0],201610180404);
    if bOk then bok:=rs.open('select 1 from jseckey'          , gaJCon[0],201610180405);
    if bOk then bok:=rs.open('select 1 from jsecperm'         , gaJCon[0],201610180406);
    if bOk then bok:=rs.open('select 1 from jsecpermuserlink' , gaJCon[0],201610180407);
    if bOk then bok:=rs.open('select 1 from jsession'         , gaJCon[0],201610180408);
    if bOk then bok:=rs.open('select 1 from jsessiondata'     , gaJCon[0],201610180409);
    if bOk then bok:=rs.open('select 1 from jsessiontype'     , gaJCon[0],201610180410);
    if bOk then bok:=rs.open('select 1 from jskill'           , gaJCon[0],201610180411);
    if bOk then bok:=rs.open('select 1 from jstatus'          , gaJCon[0],201610180412);
    if bOk then bok:=rs.open('select 1 from jsync'            , gaJCon[0],201610180413);
    if bOk then bok:=rs.open('select 1 from jsysmodule'       , gaJCon[0],201610180414);
    if bOk then bok:=rs.open('select 1 from jsysmodulelink'   , gaJCon[0],201610180415);
    if bOk then bok:=rs.open('select 1 from jtable'           , gaJCon[0],201610180416);
    if bOk then bok:=rs.open('select 1 from jtabletype'       , gaJCon[0],201610180417);
    if bOk then bok:=rs.open('select 1 from jtask'            , gaJCon[0],201610180418);
    if bOk then bok:=rs.open('select 1 from jtaskcategory'    , gaJCon[0],201610180419);
    if bOk then bok:=rs.open('select 1 from jteam'            , gaJCon[0],201610180420);
    if bOk then bok:=rs.open('select 1 from jteammember'      , gaJCon[0],201610180421);
    if bOk then bok:=rs.open('select 1 from jtheme'           , gaJCon[0],201610180422);
    if bOk then bok:=rs.open('select 1 from jthemeicon'       , gaJCon[0],201610180423);
    if bOk then bok:=rs.open('select 1 from jtimecard'        , gaJCon[0],201610180424);
    if bOk then bok:=rs.open('select 1 from jtrak'            , gaJCon[0],201610180425);
    if bOk then bok:=rs.open('select 1 from juser'            , gaJCon[0],201610180426);
    if bOk then bok:=rs.open('select 1 from juserpref'        , gaJCon[0],201610180427);
    if bOk then bok:=rs.open('select 1 from juserpreflink'    , gaJCon[0],201610180428);
    if bOk then bok:=rs.open('select 1 from jvhost'           , gaJCon[0],201610180429);
    if bOk then bok:=rs.open('select 1 from jwidget'          , gaJCon[0],201610180430);

    if not bOk then
    begin
      writeln(' ----- !!! SIGNATURE TABLE(S) MISSING  !!! ----- ');
      writeln(' ----- !!!   Your Database is Toast    !!! ----- ');
    end;
  end;


  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  if bOk then
  begin
    saQry:='select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from '+
           'juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and '+
           'UsrPL_User_ID=1 and ((UserP_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(UserP_Deleted_b IS NULL))';
    //ASPrintln('---');
    //ASPrintln(saQry);
    //ASPrintln('---');
    bOk:=rs.open(saQry, gaJCon[0],201503161669);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load admin configuration preferences. Query: '+saQry;
      //ASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210061919, saMsg, SOURCEFILE);
    end;
  end
  else
  begin
    Writeln('Unable to open main database connection.');
  end;

  if bOk and (not rs.EOL) then
  begin
    repeat
      u8DataIn:=u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID'));
      saDataIn:=rs.fields.Get_saValue('UsrPL_Value');
      //ASPrintln(rs.fields.Get_saValue('UserP_Name')+' - '+inttostr(u8DataIn) +' - '+saDataIn);

      //if (u8DataIn=) then
      //begin
      //  if (not rConfigOverridden.bRedirectToPort443) then
      //  begin
      //    grJASConfig.bRedirectToPort443:=bVal(saDataIn);
      //  end;
      //end;


      //TODO: qqq - bRedirectToPort443
      if (u8DataIn=2012100614090714788) then
      begin
        if (not rConfigOverridden.bu2ErrorReportingMode) then // JAS Error Reporting Mode  admin   secure
        begin
          saDataIn:=upcase(trim(saDataIn));
          if(saDataIn = 'VERBOSE') then
          begin
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
          end else
          if(saDataIn = 'VERBOSELOCAL') then
          begin
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_VERBOSELOCAL
          end
          else
          begin
            grJASConfig.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
          end;
          //ASPrintln('iErrorReportingMode');
        end;
      end else

      if (u8DataIn=2012100614053914241) then
      begin
        if (not rConfigOverridden.bu2DebugMode) then // JAS Debug Mode  admin   secure
        begin
          saDataIn:=UpperCase(saDataIn);
          if(saDataIn = 'VERBOSELOCAL') then
          begin
            grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_VERBOSELOCAL
          end
          else
          begin
            if(saDataIn = 'VERBOSE') then
            begin
              grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_VERBOSE
            end
            else
            begin
              grJASConfig.u2DebugMode:=cnSYS_INFO_MODE_SECURE;
            end;
          end;
          //ASPrintln('iDebugMode');
        end;
      end else

      if (u8DataIn=2012100614291882510) then begin if (not rConfigOverridden.buMaximumRequestHeaderLength) then begin
          {$IFDEF CPU32}
            grJASConfig.uMaximumRequestHeaderLength:=u4Val(saDataIn);
          {$ELSE}
            grJASConfig.uMaximumRequestHeaderLength:=u8Val(saDataIn);
          {$ENDIF}
        end;
      end else

      if (u8DataIn=1607071400079330432) then begin if (not rConfigOverridden.bbRedirectToPort443                   ) then begin grJASConfig.bRedirectToPort443:=bVal(saDataIn) end; end else
      if (u8DataIn=1608101808427620362) then begin if (not rConfigOverridden.bsaLogDir                             ) then begin grJASConfig.saLogDir:=saDataIn; end; end else
      if (u8DataIn=1607071420291730763) then begin if (not rConfigOverridden.bsaPHPDir                             ) then begin grJASConfig.saPHPDir:=saDataIn; end; end else
      //if (u8DataIn=1607071417387540735) then begin if (not rConfigOverridden.bsServerURL                           ) then begin grJASConfig.sServerURL:=saDataIn; end; end else
      //if (u8DataIn=1607071415148670687) then begin if (not rConfigOverridden.bsServerName                          ) then begin grJASConfig.sServerName:=saDataIn; end; end else
      if (u8DataIn=1607071412473910656) then begin if (not rConfigOverridden.bsServerIdent                         ) then begin grJASConfig.sServerIdent:=saDataIn; end; end else
      if (u8DataIn=1607071333353300198) then begin if (not rConfigOverridden.bu1DefaultMenuRenderMethod            ) then begin grJASConfig.u1DefaultMenuRenderMethod:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100614052025145) then begin if (not rConfigOverridden.bu2CreateSocketRetryDelayInMSec       ) then begin grJASConfig.u2CreateSocketRetryDelayInMSec:=u2Val(saDataIn);end; end else
      if (u8DataIn=2012100614061800671) then begin if (not rConfigOverridden.bbDebugServerConsoleMessagesEnabled   ) then begin grJASConfig.bDebugServerConsoleMessagesEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100614072805008) then begin if (not rConfigOverridden.bbDeleteLogFile                       ) then begin grJASConfig.bDeleteLogFile:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100614074544424) then begin if (not rConfigOverridden.bbBlackListEnabled                    ) then begin grJASConfig.bBlackListEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100614080255621) then begin if (not rConfigOverridden.bbWhiteListEnabled                    ) then begin grJASConfig.bWhiteListEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=1603031034256160001) then begin if (not rConfigOverridden.bbBlacklistIPExpire                   ) then begin grJASConfig.bBlacklistIPExpire:=bVal(saDataIn); end; end else
      if (u8DataIn=1603031037349270002) then begin if (not rConfigOverridden.bbWhitelistIPExpire                   ) then begin grJASConfig.bWhitelistIPExpire:=bVal(saDataIn); end; end else
      if (u8DataIn=1603031038289700003) then begin if (not rConfigOverridden.bbInvalidLoginsExpire                 ) then begin grJASConfig.bInvalidLoginsExpire:=bVal(saDataIn); end; end else
      if (u8DataIn=1603031039502890004) then begin if (not rConfigOverridden.bu2BlacklistDaysUntilExpire           ) then begin grJASConfig.u2BlacklistDaysUntilExpire:=u2Val(saDataIn); end;end else
      if (u8DataIn=1603031040390760005) then begin if (not rConfigOverridden.bu2WhitelistDaysUntilExpire           ) then begin grJASConfig.u2WhitelistDaysUntilExpire:=u2Val(saDataIn); end; end else
      if (u8DataIn=1603031041222320006) then begin if (not rConfigOverridden.bu2InvalidLoginsDaysUntilExpire       ) then begin grJASConfig.u2InvalidLoginsDaysUntilExpire:=u2Val(saDataIn); end; end else
      if (u8DataIn=2012100614101453914) then begin if (not rConfigOverridden.bsaErrorReportingSecureMessage        ) then begin grJASConfig.saErrorReportingSecureMessage:=saDataIn; end; end else
      if (u8DataIn=2012100614124173033) then begin if (not rConfigOverridden.bsHOOK_ACTION_CREATESESSION_FAILURE   ) then begin grJASConfig.sHOOK_ACTION_CREATESESSION_FAILURE :=trim(saDataIn); end; end else
      if (u8DataIn=2012100614125179884) then begin if (not rConfigOverridden.bsHOOK_ACTION_CREATESESSION_SUCCESS   ) then begin grJASConfig.sHOOK_ACTION_CREATESESSION_SUCCESS :=trim(saDataIn); end;end else
      if (u8DataIn=2012100614130177790) then begin if (not rConfigOverridden.bsHOOK_ACTION_REMOVESESSION_FAILURE   ) then begin grJASConfig.sHOOK_ACTION_REMOVESESSION_FAILURE :=trim(saDataIn); end;end else
      if (u8DataIn=2012100614131550006) then begin if (not rConfigOverridden.bsHOOK_ACTION_REMOVESESSION_SUCCESS   ) then begin grJASConfig.sHOOK_ACTION_REMOVESESSION_SUCCESS :=trim(saDataIn); end; end else
      if (u8DataIn=2012100614132661440) then begin if (not rConfigOverridden.bsHOOK_ACTION_SESSIONTIMEOUT          ) then begin grJASConfig.sHOOK_ACTION_SESSIONTIMEOUT :=trim(saDataIn); end; end else
      if (u8DataIn=2012100614134121397) then begin if (not rConfigOverridden.bsHOOK_ACTION_VALIDATESESSION_FAILURE ) then begin grJASConfig.sHOOK_ACTION_VALIDATESESSION_FAILURE :=trim(saDataIn); end; end else
      if (u8DataIn=2012100614135620684) then begin if (not rConfigOverridden.bsHOOK_ACTION_VALIDATESESSION_SUCCESS ) then begin grJASConfig.sHOOK_ACTION_VALIDATESESSION_SUCCESS :=trim(saDataIn); end; end else
      if (u8DataIn=2012100614150622123) then begin if (not rConfigOverridden.bbJobQEnabled                         ) then begin grJASConfig.bJobQEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100614165072216) then begin if (not rConfigOverridden.bu4JobQIntervalInMSec                 ) then begin grJASConfig.u4JobQIntervalInMSec:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100614171518219) then begin if (not rConfigOverridden.bu2LogLevel                           ) then begin grJASConfig.u2LogLevel:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100614484499907) then begin if (not rConfigOverridden.buThreadPoolMaximumRunTimeInMSec      ) then begin grJASConfig.uThreadPoolMaximumRunTimeInMSec:=u4Val(saDataIn); end; end else
      if (u8DataIn=2012100614490660469) then begin if (not rConfigOverridden.bu4MaxFileHandles                     ) then begin grJASConfig.u4MaxFileHandles:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100614492220150) then begin if (not rConfigOverridden.bu2ThreadPoolNoOfThreads              ) then begin grJASConfig.u2ThreadPoolNoOfThreads:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100614500246737) then begin if (not rConfigOverridden.bsaPerl                               ) then begin grJASConfig.saPerl:=trim(saDataIn); end; end else
      if (u8DataIn=2012100614502815902) then begin if (not rConfigOverridden.bsaPHP                                ) then begin grJASConfig.saPHP:=trim(saDataIn); end; end else
      if (u8DataIn=2012100614504757616) then begin if (not rConfigOverridden.bbProtectJASRecords                   ) then begin grJASConfig.bProtectJASRecords:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100614510501178) then begin if (not rConfigOverridden.bsClientToVICIServerIP                ) then begin grJASConfig.sClientToVICIServerIP:=trim(saDataIn); end; end else
      if (u8DataIn=2012100614511733687) then begin if (not rConfigOverridden.bsJASServertoVICIServerIP             ) then begin grJASConfig.sJASServertoVICIServerIP:=trim(saDataIn); end; end else
      if (u8DataIn=2012100706052712248) then begin if (not rConfigOverridden.bu2LockRetriesBeforeFailure           ) then begin grJASConfig.u2LockRetriesBeforeFailure:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615120666942) then begin if (not rConfigOverridden.bu2LockRetryDelayInMSec               ) then begin grJASConfig.u2LockRetryDelayInMSec:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615123707971) then begin if (not rConfigOverridden.bu2LockTimeoutInMinutes               ) then begin grJASConfig.u2LockTimeoutInMinutes:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615140260928) then begin if (not rConfigOverridden.bu4RetryDelayInMSec                   ) then begin grJASConfig.u4RetryDelayInMSec:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615142419915) then begin if (not rConfigOverridden.bu2RetryLimit                         ) then begin grJASConfig.u2RetryLimit:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615145637878) then begin if (not rConfigOverridden.bbSafeDelete                          ) then begin grJASConfig.bSafeDelete:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100615152356082) then begin if (not rConfigOverridden.bbServerConsoleMessagesEnabled        ) then begin grJASConfig.bServerConsoleMessagesEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=1609241241104730045) then begin if (not rConfigOverridden.bbRecycleSessions                     ) then begin grJASConfig.bRecycleSessions:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100615160460912) then begin if (not rConfigOverridden.bu2SessionTimeoutInMinutes            ) then begin grJASConfig.u2SessionTimeoutInMinutes:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615162043726) then begin if (not rConfigOverridden.bsSMTPHost                            ) then begin grJASCOnfig.sSMTPHost:=trim(saDataIn); end; end else
      if (u8DataIn=2012100615163514292) then begin if (not rConfigOverridden.bsSMTPPassword                        ) then begin grJASCOnfig.sSMTPPassword:=trim(saDataIn); end; end else
      if (u8DataIn=2012100615164495133) then begin if (not rConfigOverridden.bsSMTPUsername                        ) then begin grJASCOnfig.sSMTPUsername:=trim(saDataIn); end; end else
      if (u8DataIn=2012100615172828038) then begin if (not rConfigOverridden.bu2SocketTimeOutInMSec                ) then begin grJASConfig.u2SocketTimeOutInMSec:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615180834150) then begin if (not rConfigOverridden.bi1TimeZoneOffSet                     ) then begin grJASConfig.i1TimeZoneOffSet:=iVal(saDataIn); end; end else
      if (u8DataIn=2012100615183451070) then begin if (not rConfigOverridden.bu2ValidateSessionRetryLimit          ) then begin grJASConfig.u2ValidateSessionRetryLimit:=u2Val(saDataIn); end; end else
      if (u8DataIn=2012100523502800347) then begin if (not rConfigOverridden.bbWhiteListEnabled                    ) then begin grJASConfig.bWhiteListEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100523493783574) then begin if (not rConfigOverridden.bbBlackListEnabled                    ) then begin grJASConfig.bBlackListEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=2012100906502356513) then begin if (not rConfigOverridden.bsaJASFooter                          ) then begin grJASConfig.saJASFooter:=trim(saDataIn); end; end else
      if (u8DataIn=1211061858501530001) then begin if (not rConfigOverridden.bbAllowVirtualHostCreation            ) then begin grJASConfig.bAllowVirtualHostCreation:=bVal(saDataIn); end; end else
      if (u8DataIn=1211231539180430025) then begin if (not rConfigOverridden.bbCreateHybridJets                    ) then begin grJASConfig.bCreateHybridJets:=bVal(saDataIn); end; end else
      if (u8DataIn=1601091043380330002) then begin if (not rConfigOverridden.bbPunkBeGoneEnabled                   ) then begin grJASConfig.bPunkBeGoneEnabled:=bVal(saDataIn); end; end else
      if (u8DataIn=1601101324551180008) then begin if (not rConfigOverridden.bu2PunkBeGoneMaxErrors                ) then begin grJASConfig.u2PunkBeGoneMaxErrors:=u2Val(saDataIn); end; end else
      if (u8DataIn=1601101330094200011) then begin if (not rConfigOverridden.bu2PunkBeGoneMaxMinutes               ) then begin grJASConfig.u2PunkBeGoneMaxMinutes:=u2Val(saDataIn); end; end else
      if (u8DataIn=1601101333591580013) then begin if (not rConfigOverridden.bu4PunkBeGoneIntervalInMSec           ) then begin grJASConfig.u4PunkBeGoneIntervalInMSec:=u4Val(saDataIn); end; end else
      if (u8DataIn=1601101336077570015) then begin if (not rConfigOverridden.bu2PunkBeGoneIPHoldTimeInDays         ) then begin grJASConfig.u2PunkBeGoneIPHoldTimeInDays:=u2Val(saDataIn); end; end else
      if (u8DataIn=1601101549172620002) then begin if (not rConfigOverridden.bu2PunkBeGoneMaxDownloads             ) then begin grJASConfig.u2PunkBeGoneMaxDownloads:=i4Val(saDataIn); end; end else
      if (u8DataIn=1605030308324720288) then begin if (not rConfigOverridden.bbPunkBeGoneSmackBadBots              ) then begin grJASConfig.bPunkBeGoneSmackBadBots:=bVal(saDataIn); end; end else
      if (u8DataIn=1604091604536840007) then begin if (not rConfigOverridden.bbSQLTraceLogEnabled                  ) then begin grJASConfig.bSQLTraceLogEnabled:=bVal(saDataIn); end; end;
      if (u8DataIn=1608040933154770164) then begin if (not rConfigOverridden.bbRecordLockingEnabled                ) then begin grJASConfig.bRecordLockingEnabled:=bVal(saDataIn); end; end;
      if (u8DataIn=1609262241492740102) then begin if (not rConfigOverridden.bu4ListenDurationInMSec               ) then begin grJASConfig.u4ListenDurationInMSec:=u4Val(saDataIn); end; end;
    until (not bOK) or (not rs.movenext);
    //ASPRintln('Ok:'+sTrueFalse(bOk));
  end;
  rs.close;

  grJegasCommon.rJegasLog.saFileName:=grJASConfig.saSysDir+DOSSLASH+'log'+DOSSLASH+csLOG_FILENAME_DEFAULT;
  If grJASConfig.bDeleteLogFile and (not bLogEntryMadeDuringStartUp) Then
  Begin
    deletefile(grJegasCommon.rJegasLog.saFileName);
    JLog(cnLog_Info,201203091110,'Deleted Log File as instructed in JAS configuration.',SOURCEFILE);
  End;
  // END ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // END ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // END ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // END ------------------------------------------ USER PREF SETTINGS (MAIN JET)










  // BEGIN ---------------------------------------- garJVHost: array of rtJVHost;
  // BEGIN ---------------------------------------- garJVHost: array of rtJVHost;
  // BEGIN ---------------------------------------- garJVHost: array of rtJVHost;
  // BEGIN ---------------------------------------- garJVHost: array of rtJVHost;
  if bOk then
  begin
    if not rs.Open('select * from jvhost',gaJCon[0],10101010) then writeln('RS open simple failed too');
    rs.close;
    if gbMainSystemOnly then writeln('Scramble!') else writeln('Squadron Scrambled!'); // =|:^)>
    //ASPrintln('System VHost Only: '+sTrueFalse(bMainSystemOnly));
    saQry:='SELECT * FROM jvhost '+
      'WHERE ((VHost_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL)) AND '+
        ' (VHOST_Enabled_b='+gaJCon[0].sDBMSBoolScrub(true)+')';
    bOk:=rs.Open(saQry,gaJCon[0],201503161670);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load virtual host records. Query: '+saQry;
      JASPrintln('Msg: '+saMsg);
      JLog(cnLog_FATAL, 201210070950,saMsg , SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      //ASPrintln('Loading VHost: '+rs.fields.Get_saValue('VHost_ServerName'));
      setlength(garJVHost, length(garJVHost)+1);
      i4:=length(garJVHost)-1;
      clear_JVhost(garJVHost[i4]);
      with garJVHost[i4] do begin
        VHost_JVHost_UID                := u8Val(rs.fields.Get_saValue('VHost_JVHost_UID'));
        VHost_DefaultLanguage           := rs.fields.Get_saValue('VHost_DefaultLanguage');
        VHost_ServerName                := rs.fields.Get_saValue('VHost_ServerName');
        VHost_ServerIdent               := rs.fields.Get_saValue('VHost_ServerIdent');
        VHost_ServerDomain              := rs.fields.Get_saValue('VHost_ServerDomain');
        VHost_DefaultTheme              := rs.fields.Get_saValue('VHost_DefaultTheme');
        VHost_MenuRenderMethod          := u2Val(rs.fields.Get_saValue('VHost_MenuRenderMethod'));
        VHost_DefaultArea               := rs.fields.Get_saValue('VHost_DefaultArea');
        VHost_DefaultPage               := rs.fields.Get_saValue('VHost_DefaultPage');
        VHost_DefaultSection            := rs.fields.Get_saValue('VHost_DefaultSection');
        VHost_DefaultTop_JMenu_ID       := u8Val(rs.fields.Get_saValue('VHost_DefaultTop_JMenu_ID'));
        VHost_DefaultLoggedInPage       := rs.fields.Get_saValue('VHost_DefaultLoggedInPage');
        VHost_DefaultLoggedOutPage      := rs.fields.Get_saValue('VHost_DefaultLoggedOutPage');
        VHost_DataOnRight_b             := bVal(rs.fields.Get_saValue('VHost_DataOnRight_b'));
        VHost_CacheMaxAgeInSeconds      := u2Val(rs.fields.Get_saValue('VHost_CacheMaxAgeInSeconds'));
        VHost_SystemEmailFromAddress    := rs.fields.Get_saValue('VHost_SystemEmailFromAddress,');
        VHost_SharesDefaultDomain_b     := bVal(rs.fields.Get_saValue('VHost_SharesDefaultDomain_b'));
        VHost_DirectoryListing_b        := bVal(rs.fields.Get_saValue('VHost_DirectoryListing_b'));
        VHost_WebRootDir                := rs.fields.Get_saValue('VHost_WebRootDir');
        VHost_AccessLog                 := rs.fields.Get_saValue('VHost_AccessLog');
        VHost_ErrorLog                  := rs.fields.Get_saValue('VHost_ErrorLog');
        VHost_DefaultIconTheme          := rs.fields.Get_saValue('VHost_DefaultIconTheme');
        VHost_FileDir                   := rs.fields.Get_saValue('VHost_FileDir');
        VHost_JDConnection_ID           := u8Val(rs.fields.Get_saValue('VHost_JDConnection_ID'));
        VHost_Enabled_b                 := bVal(rs.fields.Get_saValue('VHost_Enabled_b'));
        VHost_CacheDir                  := rs.fields.Get_saValue('VHost_CacheDir');
        VHost_TemplateDir               := rs.fields.Get_saValue('VHost_TemplateDir');
        VHost_SIPURL                    := rs.fields.Get_saValue('VHost_SIPURL');
        VHost_AllowRegistration_b       := bVal(rs.fields.Get_saValue('VHost_AllowRegistration_b'));
        VHost_RegisterReqBirthday_b     := bVal(rs.fields.Get_saValue('VHost_RegisterReqBirthday_b'));
        VHost_RegisterReqCellPhone_b    := bVal(rs.fields.Get_saValue('VHost_RegisterReqCellPhone_b'));
        VHost_ServerURL                 := rs.fields.Get_saValue('VHost_ServerURL');
        VHost_LogToConsole_b            := bVal(rs.fields.Get_saValue('VHost_LogToConsole_b'));
        VHost_PasswordKey_u1            := u1Val(rs.fields.Get_saValue('VHost_PasswordKey_u1'));
        VHost_LogRequestsToDatabase_b   := bVal(rs.fields.Get_saValue('VHost_LogRequestsToDatabase_b'));
        VHost_WebSharedir               := rs.fields.Get_saValue('VHost_WebShareDir');
        VHOST_WebShareAlias             := rs.fields.Get_saValue('VHOST_WebShareAlias');
        VHost_JASDirTheme               := rs.fields.Get_saValue('VHost_JASDirTheme');
        VHost_Headers_b                 := bVal(rs.fields.Get_saValue('VHost_Headers_b'));
        VHost_QuickLinks_b              := bVal(rs.fields.Get_saValue('VHost_QuickLinks_b'));
        VHost_DefaultDateMask           := rs.fields.Get_saValue('VHost_DefaultDateMask');
        VHost_Background                := rs.fields.Get_saValue('VHost_Background');
        VHost_BackgroundRepeat_b        := bVal(rs.fields.Get_saValue('VHost_BackgroundRepeat_b'));



        if (i4=0) and rJVHostOverridden.bVHost_DefaultLanguage         then VHost_DefaultLanguage          := rJVHostOverride.VHost_DefaultLanguage          else VHost_DefaultLanguage         :=rs.fields.Get_saValue('VHost_DefaultLanguage'        );
        if (i4=0) and rJVHostOverridden.bVHost_ServerName              then VHost_ServerName               := rJVHostOverride.VHost_ServerName               else VHost_ServerName              :=rs.fields.Get_saValue('VHost_ServerName'             );
        if (i4=0) and rJVHostOverridden.bVHost_ServerIdent             then VHost_ServerIdent              := rJVHostOverride.VHost_ServerIdent              else VHost_ServerIdent             :=rs.fields.Get_saValue('VHost_ServerIdent'            );
        if (i4=0) and rJVHostOverridden.bVHost_ServerDomain            then VHost_ServerDomain             := rJVHostOverride.VHost_ServerDomain             else VHost_ServerDomain            :=rs.fields.Get_saValue('VHost_ServerDomain'           );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultTheme            then VHost_DefaultTheme             := rJVHostOverride.VHost_DefaultTheme             else VHost_DefaultTheme            :=rs.fields.Get_saValue('VHost_DefaultTheme'           );
        if (i4=0) and rJVHostOverridden.bVHost_MenuRenderMethod        then VHost_MenuRenderMethod         := rJVHostOverride.VHost_MenuRenderMethod         else VHost_MenuRenderMethod        :=u2Val(rs.fields.Get_saValue('VHost_MenuRenderMethod'));
        if (i4=0) and rJVHostOverridden.bVHost_DefaultArea             then VHost_DefaultArea              := rJVHostOverride.VHost_DefaultArea              else VHost_DefaultArea             :=rs.fields.Get_saValue('VHost_DefaultArea'            );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultPage             then VHost_DefaultPage              := rJVHostOverride.VHost_DefaultPage              else VHost_DefaultPage             :=rs.fields.Get_saValue('VHost_DefaultPage'            );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultSection          then VHost_DefaultSection           := rJVHostOverride.VHost_DefaultSection           else VHost_DefaultSection          :=rs.fields.Get_saValue('VHost_DefaultSection'         );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultTop_JMenu_ID     then VHost_DefaultTop_JMenu_ID      := rJVHostOverride.VHost_DefaultTop_JMenu_ID      else VHost_DefaultTop_JMenu_ID     :=u8Val(rs.fields.Get_saValue('VHost_DefaultTop_JMenu_ID'));
        if (i4=0) and rJVHostOverridden.bVHost_DefaultLoggedInPage     then VHost_DefaultLoggedInPage      := rJVHostOverride.VHost_DefaultLoggedInPage      else VHost_DefaultLoggedInPage     :=rs.fields.Get_saValue('VHost_DefaultLoggedInPage'    );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultLoggedOutPage    then VHost_DefaultLoggedOutPage     := rJVHostOverride.VHost_DefaultLoggedOutPage     else VHost_DefaultLoggedOutPage    :=rs.fields.Get_saValue('VHost_DefaultLoggedOutPage'   );
        if (i4=0) and rJVHostOverridden.bVHost_DataOnRight_b           then VHost_DataOnRight_b            := rJVHostOverride.VHost_DataOnRight_b            else VHost_DataOnRight_b           :=bVal(rs.fields.Get_saValue('VHost_DataOnRight_b'));
        if (i4=0) and rJVHostOverridden.bVHost_CacheMaxAgeInSeconds    then VHost_CacheMaxAgeInSeconds     := rJVHostOverride.VHost_CacheMaxAgeInSeconds     else VHost_CacheMaxAgeInSeconds    :=u2Val(rs.fields.Get_saValue('VHost_CacheMaxAgeInSeconds'));
        if (i4=0) and rJVHostOverridden.bVHost_SystemEmailFromAddress  then VHost_SystemEmailFromAddress   := rJVHostOverride.VHost_SystemEmailFromAddress   else VHost_SystemEmailFromAddress  :=rs.fields.Get_saValue('VHost_SystemEmailFromAddress');
        if (i4=0) and rJVHostOverridden.bVHost_SharesDefaultDomain_b   then VHost_SharesDefaultDomain_b    := rJVHostOverride.VHost_SharesDefaultDomain_b    else VHost_SharesDefaultDomain_b   :=bVal(rs.fields.Get_saValue('VHost_SharesDefaultDomain_b')  );
        if (i4=0) and rJVHostOverridden.bVHost_DirectoryListing_b      then VHost_DirectoryListing_b       := rJVHostOverride.VHost_DirectoryListing_b       else VHost_DirectoryListing_b      :=bVal(rs.fields.Get_saValue('VHost_DirectoryListing_b'     ));
        if (i4=0) and rJVHostOverridden.bVHost_WebRootDir              then VHost_WebRootDir               := rJVHostOverride.VHost_WebRootDir               else VHost_WebRootDir              :=rs.fields.Get_saValue('VHost_WebRootDir'             );
        if (i4=0) and rJVHostOverridden.bVHost_AccessLog               then VHost_AccessLog                := rJVHostOverride.VHost_AccessLog                else VHost_AccessLog               :=rs.fields.Get_saValue('VHost_AccessLog'              );
        if (i4=0) and rJVHostOverridden.bVHost_ErrorLog                then VHost_ErrorLog                 := rJVHostOverride.VHost_ErrorLog                 else VHost_ErrorLog                :=rs.fields.Get_saValue('VHost_ErrorLog'               );
        if (i4=0) and rJVHostOverridden.bVHost_DefaultIconTheme        then VHost_DefaultIconTheme         := rJVHostOverride.VHost_DefaultIconTheme         else VHost_DefaultIconTheme        :=rs.fields.Get_saValue('VHost_DefaultIconTheme'       );
        if (i4=0) and rJVHostOverridden.bVHost_FileDir                 then VHost_FileDir                  := rJVHostOverride.VHost_FileDir                  else VHost_FileDir                 :=rs.fields.Get_saValue('VHost_FileDir'                );
        if (i4=0) and rJVHostOverridden.bVHost_JDConnection_ID         then VHost_JDConnection_ID          := rJVHostOverride.VHost_JDConnection_ID          else VHost_JDConnection_ID         :=u8Val(rs.fields.Get_saValue('VHost_JDConnection_ID'));
        if (i4=0) and rJVHostOverridden.bVHost_Enabled_b               then VHost_Enabled_b                := rJVHostOverride.VHost_Enabled_b                else VHost_Enabled_b               :=bVal(rs.fields.Get_saValue('VHost_Enabled_b'));
        if (i4=0) and rJVHostOverridden.bVHost_CacheDir                then VHost_CacheDir                 := rJVHostOverride.VHost_CacheDir                 else VHost_CacheDir                :=rs.fields.Get_saValue('VHost_CacheDir'               );
        if (i4=0) and rJVHostOverridden.bVHost_TemplateDir             then VHost_TemplateDir              := rJVHostOverride.VHost_TemplateDir              else VHost_TemplateDir             :=rs.fields.Get_saValue('VHost_TemplateDir'            );
        if (i4=0) and rJVHostOverridden.bVHost_SIPURL                  then VHost_SIPURL                   := rJVHostOverride.VHost_SIPURL                   else VHost_SIPURL                  :=rs.fields.Get_saValue('VHost_SIPURL'                 );
        if (i4=0) and rJVHostOverridden.bVHost_AllowRegistration_b     then VHost_AllowRegistration_b      := rJVHostOverride.VHost_AllowRegistration_b      else VHost_AllowRegistration_b     :=bVal(rs.fields.Get_saValue('VHost_AllowRegistration_b'));
        if (i4=0) and rJVHostOverridden.bVHost_RegisterReqBirthday_b   then VHost_RegisterReqBirthday_b    := rJVHostOverride.VHost_RegisterReqBirthday_b    else VHost_RegisterReqBirthday_b   :=bVal(rs.fields.Get_saValue('VHost_RegisterReqBirthday_b'));
        if (i4=0) and rJVHostOverridden.bVHost_RegisterReqCellPhone_b  then VHost_RegisterReqCellPhone_b   := rJVHostOverride.VHost_RegisterReqCellPhone_b   else VHost_RegisterReqCellPhone_b  :=bVal(rs.fields.Get_saValue('VHost_RegisterReqCellPhone_b'));
        if (i4=0) and rJVHostOverridden.bVHost_ServerURL               then VHost_ServerURL                := rJVHostOverride.VHost_ServerURL                else VHost_ServerURL               :=rs.fields.Get_saValue('VHost_ServerURL');
        if (i4=0) and rJVHostOverridden.bVHost_LogToConsole_b          then VHost_LogToConsole_b           := rJVHostOverride.VHost_LogToConsole_b           else VHost_LogToConsole_b          :=bVal(rs.fields.Get_saValue('VHost_LogToConsole_b'));
        if (i4=0) and rJVHostOverridden.bVHost_PasswordKey_u1          then VHost_PasswordKey_u1           := rJVHostOverride.VHost_PasswordKey_u1           else VHost_PasswordKey_u1          :=u1Val(rs.fields.Get_saValue('VHost_PasswordKey_u1'));
        if (i4=0) and rJVHostOverridden.bVHost_LogRequestsToDatabase_b then VHost_LogRequestsToDatabase_b  := rJVHostOverride.VHost_LogRequestsToDatabase_b  else VHost_LogRequestsToDatabase_b :=bVal(rs.fields.Get_saValue('VHost_LogRequestsToDatabase_b'));
        if (i4=0) and rJVHostOverridden.bVHost_WebShareDir_b           then VHost_WebShareDir              := rJVHostOverride.VHost_WebSharedir              else VHost_WebShareDir             :=rs.fields.Get_saValue('VHost_WebshareDir');
        if (i4=0) and rJVHostOverridden.bVHOST_WebShareAlias_b         then VHOST_WebShareAlias            := rJVHostOverride.VHOST_WebShareAlias            else VHOST_WebShareAlias           :=rs.fields.Get_saValue('VHOST_WebShareAlias');
        if (i4=0) and rJVHostOverridden.bVHost_JASDirTheme             then VHost_JASDirTheme              := rJVHostOverride.VHost_JASDirTheme              else VHost_JASDirTheme             :=rs.fields.Get_saValue('VHost_JASDirTheme');
        if (i4=0) and rJVHostOverridden.bVHost_Headers_b               then VHost_Headers_b                := rJVHostOverride.VHost_Headers_b                else VHost_Headers_b               :=bVal(rs.fields.Get_saValue('VHost_Headers_b'));
        if (i4=0) and rJVHostOverridden.bVHost_QuickLinks_b            then VHost_QuickLinks_b             := rJVHostOverride.VHost_QuickLinks_b             else VHost_QuickLinks_b            :=bVal(rs.fields.Get_saValue('VHost_QuickLinks_b'));
        if (i4=0) and rJVHostOverridden.bVHost_DEfaultDateMask         then VHost_DefaultDateMask          := rJVHostOverride.VHost_DefaultDateMask          else VHost_DefaultDateMask         :=rs.fields.Get_saValue('VHost_DefaultDateMask');
        if (i4=0) and rJVHostOverridden.bVHost_Background              then VHost_Background               := rJVHostOverride.VHost_Background               else VHost_Background              :=rs.fields.Get_saValue('VHost_Background');
        if (i4=0) and rJVHostOverridden.bVHost_BackgroundRepeat_b      then VHost_BackgroundRepeat_b       := rJVHostOverride.VHost_BackgroundRepeat_b       else VHost_BackgroundRepeat_b      :=bVal(rs.fields.Get_saValue('VHost_BackgroundRepeat_b'));
        // -- STOCK -----------------------------------------------------------
      end;
    until (not bOk) or (not rs.MoveNext) or (gbMainSystemOnly);
  end;
  rs.close;

  if bOk then
  begin
    if length(garJVHost)=0 then
    begin
      JASDebugPrintln('no vhosts in garJVHost array. uj_config');
      setlength(garJVHost,1);
      with garJVHost[0] do begin
        VHost_DefaultLanguage:=grJASConfig.sDefaultLanguage;
        VHost_ServerName:='MissingVhostServer';
        VHost_ServerIdent:='JEGAS';//if lucky they didnt change it, if smart they did :) (if using more than one instance)
        VHost_ServerDomain:='localhost';
        VHost_DefaultTheme:='brown';
        VHost_MenuRenderMethod:=grJASConfig.u1DefaultMenuRenderMethod;
        VHost_DefaultArea:='sys_area';
        VHost_DefaultPage:='sys_page';
        VHost_DefaultSection:='MAIN';
        VHost_DefaultTop_JMenu_ID:=1;
        VHost_DefaultLoggedInPage:='[@ALIAS@]';// if this doesnt work out with the SNR - use just / instead
        VHost_DefaultLoggedOutPage:='[@ALIAS@]';// if this doesnt work out with the SNR - use just / instead
        VHost_DataOnRight_b:=false;//changes how the web widget are laid out. label on top is my fave. (not data on right...below instead - your call ):)
        VHost_CacheMaxAgeInSeconds:=3600;
        VHost_SystemEmailFromAddress:='notset@systemfrom.um';
        VHost_SharesDefaultDomain_b:=false;//not applicable really in this one - its the main host (last resort make one if on not in database) :)
        VHost_DirectoryListing_b:=false;
        VHost_WebRootDir:='..'+DOSSLASH+'webroot'+DOSSLASH;
        VHost_AccessLog:='..'+DOSSLASH+'log'+DOSSLASH+'access.'+VHost_ServerDomain+'.log';
        VHost_ErrorLog:='..'+DOSSLASH+'log'+DOSSLASH+'error.'+VHost_ServerDomain+'.log';
        VHost_DefaultIconTheme:='Nuvola';
        VHost_FileDir:='..'+DOSSLASH+'file'+DOSSLASH;
        VHost_JDConnection_ID:=0;
        VHost_Enabled_b:=true;
        VHost_CacheDir:='..'+DOSSLASH+'cache'+DOSSLASH;
        VHost_TemplateDir:='..'+DOSSLASH+'templates'+DOSSLASH;
        VHost_SIPURL:='sip.yourphonesystem.com';
        VHost_AllowRegistration_b:=false;
        VHost_RegisterReqBirthday_b:=false;
        VHost_RegisterReqCellPhone_b:=false;
        VHost_ServerURL:='localhost';
        VHost_LogToConsole_b:=true;
        VHost_PasswordKey_u1:=128+64+8+4;
        VHost_LogRequestsToDatabase_b:=false;
        VHost_WebShareDir:='..'+DOSSLASH+'webshare'+DOSSLASH;
        VHost_JASDirTheme:='/jws/themes/';
        VHOST_WebShareAlias:='/jws/';
        VHost_Headers_b:=true;
        VHost_QuickLinks_b:=true;
        VHost_DefaultDateMask:='';
        VHost_Background:='/jws/img/backgrounds/13a.jpg';
        VHost_BackgroundRepeat_b:=false;
      end;//with
    end;

    if length(garJVHost)>1 then
    begin
      saMsg:='Multiple Virtual Hosts Found in database.';
      JLog(cnLog_Info, 201210170805,saMsg , SOURCEFILE);
    end
    else
    begin
      saMsg:='Single Host Mode';
      JLog(cnLog_Info, 201210170806,saMsg , SOURCEFILE);
    end;
    bLogEntryMadeDuringStartUp:=true;
    JASPrintln('Msg text: '+saMsg);

  end;

  if bOk then
  begin
    with rJVHostOverridden do begin
      if bVHost_AllowRegistration_b     then begin garJVhost[0].VHost_AllowRegistration_b      := rJVHostOverride.VHost_AllowRegistration_b     ; end;
      if bVHost_RegisterReqCellPhone_b  then begin garJVhost[0].VHost_RegisterReqCellPhone_b   := rJVHostOverride.VHost_RegisterReqCellPhone_b  ; end;
      if bVHost_RegisterReqBirthday_b   then begin garJVhost[0].VHost_RegisterReqBirthday_b    := rJVHostOverride.VHost_RegisterReqBirthday_b   ; end;
      if bVHost_JVHost_UID              then begin garJVhost[0].VHost_JVHost_UID               := rJVHostOverride.VHost_JVHost_UID              ; end;
      if bVHost_WebRootDir              then begin garJVhost[0].VHost_WebRootDir               := rJVHostOverride.VHost_WebRootDir              ; end;
      if bVHost_ServerName              then begin garJVhost[0].VHost_ServerName               := rJVHostOverride.VHost_ServerName              ; end;
      if bVHost_ServerIdent             then begin garJVhost[0].VHost_ServerIdent              := rJVHostOverride.VHost_ServerIdent             ; end;
      if bVHost_ServerURL               then begin garJVhost[0].VHost_ServerURL                := rJVHostOverride.VHost_ServerURL               ; end;
      if bVHost_ServerDomain            then begin garJVhost[0].VHost_ServerDomain             := rJVHostOverride.VHost_ServerDomain            ; end;
      if bVHost_DefaultLanguage         then begin garJVhost[0].VHost_DefaultLanguage          := rJVHostOverride.VHost_DefaultLanguage         ; end;
      if bVHost_DefaultTheme            then begin garJVhost[0].VHost_DefaultTheme             := rJVHostOverride.VHost_DefaultTheme            ; end;
      if bVHost_MenuRenderMethod        then begin garJVhost[0].VHost_MenuRenderMethod         := rJVHostOverride.VHost_MenuRenderMethod        ; end;
      if bVHost_DefaultArea             then begin garJVhost[0].VHost_DefaultArea              := rJVHostOverride.VHost_DefaultArea             ; end;
      if bVHost_DefaultPage             then begin garJVhost[0].VHost_DefaultPage              := rJVHostOverride.VHost_DefaultPage             ; end;
      if bVHost_DefaultSection          then begin garJVhost[0].VHost_DefaultSection           := rJVHostOverride.VHost_DefaultSection          ; end;
      if bVHost_DefaultTop_JMenu_ID     then begin garJVhost[0].VHost_DefaultTop_JMenu_ID      := rJVHostOverride.VHost_DefaultTop_JMenu_ID     ; end;
      if bVHost_DefaultLoggedInPage     then begin garJVhost[0].VHost_DefaultLoggedInPage      := rJVHostOverride.VHost_DefaultLoggedInPage     ; end;
      if bVHost_DefaultLoggedOutPage    then begin garJVhost[0].VHost_DefaultLoggedOutPage     := rJVHostOverride.VHost_DefaultLoggedOutPage    ; end;
      if bVHost_DataOnRight_b           then begin garJVhost[0].VHost_DataOnRight_b            := rJVHostOverride.VHost_DataOnRight_b           ; end;
      if bVHost_CacheMaxAgeInSeconds    then begin garJVhost[0].VHost_CacheMaxAgeInSeconds     := rJVHostOverride.VHost_CacheMaxAgeInSeconds    ; end;
      if bVHost_SystemEmailFromAddress  then begin garJVhost[0].VHost_SystemEmailFromAddress   := rJVHostOverride.VHost_SystemEmailFromAddress  ; end;
      if bVHost_SharesDefaultDomain_b   then begin garJVhost[0].VHost_SharesDefaultDomain_b    := rJVHostOverride.VHost_SharesDefaultDomain_b   ; end;
      if bVHost_DefaultIconTheme        then begin garJVhost[0].VHost_DefaultIconTheme         := rJVHostOverride.VHost_DefaultIconTheme        ; end;
      if bVHost_DirectoryListing_b      then begin garJVhost[0].VHost_DirectoryListing_b       := rJVHostOverride.VHost_DirectoryListing_b      ; end;
      if bVHost_FileDir                 then begin garJVhost[0].VHost_FileDir                  := rJVHostOverride.VHost_FileDir                 ; end;
      if bVHost_AccessLog               then begin garJVhost[0].VHost_AccessLog                := rJVHostOverride.VHost_AccessLog               ; end;
      if bVHost_ErrorLog                then begin garJVhost[0].VHost_ErrorLog                 := rJVHostOverride.VHost_ErrorLog                ; end;
      if bVHost_JDConnection_ID         then begin garJVhost[0].VHost_JDConnection_ID          := rJVHostOverride.VHost_JDConnection_ID         ; end;
      if bVHost_Enabled_b               then begin garJVhost[0].VHost_Enabled_b                := rJVHostOverride.VHost_Enabled_b               ; end;
      if bVHost_TemplateDir             then begin garJVhost[0].VHost_TemplateDir              := rJVHostOverride.VHost_TemplateDir             ; end;
      if bVHOST_SipURL                  then begin garJVhost[0].VHOST_SipURL                   := rJVHostOverride.VHOST_SipURL                  ; end;
      if bVHOST_WebshareDir             then begin garJVhost[0].VHOST_WebshareDir              := rJVHostOverride.VHOST_WebshareDir             ; end;
      if bVHOST_CacheDir                then begin garJVhost[0].VHOST_CacheDir                 := rJVHostOverride.VHOST_CacheDir                ; end;
      //if bVHOST _LogDir                  then begin garJVhost[0].VHOST _LogDir                   := rJVHostOverride.VHOST _LogDir                  ; end;
      //if bVHOST _ThemeDir                then begin garJVhost[0].VHOST _ThemeDir                 := rJVHostOverride.VHOST _ThemeDir                ; end;
      if bVHOST_WebShareAlias           then begin garJVhost[0].VHOST_WebShareAlias            := rJVHostOverride.VHOST_WebShareAlias           ; end;
      if bVHOST_JASDirTheme             then begin garJVhost[0].VHOST_JASDirTheme              := rJVHostOverride.VHOST_JASDirTheme             ; end;
      if bVHOST_DefaultArea             then begin garJVhost[0].VHOST_DefaultArea             := rJVHostOverride.VHOST_DefaultArea            ; end;
      if bVHOST_DefaultPage             then begin garJVhost[0].VHOST_DefaultPage             := rJVHostOverride.VHOST_DefaultPage            ; end;
      if bVHOST_DefaultSection          then begin garJVhost[0].VHOST_DefaultSection          := rJVHostOverride.VHOST_DefaultSection         ; end;
      if bVHOST_PasswordKey_u1          then begin garJVhost[0].VHOST_PasswordKey_u1           := rJVHostOverride.VHOST_PasswordKey_u1          ; end;
      if bVHost_LogToDataBase_b         then begin garJVhost[0].VHost_LogToDataBase_b          := rJVHostOverride.VHost_LogToDataBase_b         ; end;
      if bVHost_LogToConsole_b          then begin garJVhost[0].VHost_LogToConsole_b           := rJVHostOverride.VHost_LogToConsole_b          ; end;
      if bVHost_LogRequestsToDatabase_b then begin garJVhost[0].VHost_LogRequestsToDatabase_b  := rJVHostOverride.VHost_LogRequestsToDatabase_b ; end;
      if bVHost_AccessLog               then begin garJVhost[0].VHost_AccessLog                := rJVHostOverride.VHost_AccessLog        ; end;
      if bVHost_ErrorLog                then begin garJVhost[0].VHost_ErrorLog                 := rJVHostOverride.VHost_ErrorLog         ; end;
      if bVHost_Headers_b               then begin garJVHost[0].VHost_Headers_b                := rJVHostOverride.VHost_Headers_b        ; end;
      if bVHost_QuickLinks_b            then begin garJVHost[0].VHost_QuickLinks_b             := rJVHostOverride.VHost_QuickLinks_b     ; end;
    end;//with
  end;

 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;











  // BEGIN ---------------------------------------- garJTheme: array of rtJTheme;
  // BEGIN ---------------------------------------- garJTheme: array of rtJTheme;
  // BEGIN ---------------------------------------- garJTheme: array of rtJTheme;
  // BEGIN ---------------------------------------- garJTheme: array of rtJTheme;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'Theme_JTheme_UID,'+
        'Theme_Name,'+
        'Theme_Template_Header '+
      'FROM jtheme '+
      'WHERE ((Theme_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(Theme_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry,gaJCon[0],201503161654);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load theme list. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210090601, saMsg, SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJThemeLight, length(garJThemeLight)+1);
      i4:=length(garJThemeLight)-1;
      clear_JThemeLight(garJThemeLight[i4]);
      with garJThemeLight[i4] do begin
        u8JTheme_UID      := u8Val(rs.fields.get_saValue('Theme_JTheme_UID'));
        saName            := rs.fields.get_saValue('Theme_Name');
        saTemplate_Header := rs.fields.get_saValue('Theme_Template_Header');
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
  // END ---------------------------------------- garJTheme: array of rtJTheme;
  // END ---------------------------------------- garJTheme: array of rtJTheme;
  // END ---------------------------------------- garJTheme: array of rtJTheme;
  // END ---------------------------------------- garJTheme: array of rtJTheme;






  // BEGIN ---------------------------------------- garJLanguage: array of rtJLanguage;
  // BEGIN ---------------------------------------- garJLanguage: array of rtJLanguage;
  // BEGIN ---------------------------------------- garJLanguage: array of rtJLanguage;
  // BEGIN ---------------------------------------- garJLanguage: array of rtJLanguage;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'JLang_JLanguage_UID,'+
        'JLang_Name,'+
        'JLang_NativeName,'+
        'JLang_Code '+
      'FROM jlanguage '+
      'WHERE ((JLang_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(JLang_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry,gaJCon[0],201503161655);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load language list. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210071019, saMsg, SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJLanguageLight, length(garJLanguageLight)+1);
      i4:=length(garJLanguageLight)-1;
      clear_JLanguageLight(garJLanguageLight[i4]);
      with garJLanguageLight[i4] do begin
        u8JLanguage_UID := u8Val(rs.fields.get_saValue('JLang_JLanguage_UID'));
        saName          := rs.fields.get_saValue('JLang_Name');
        saNativeName    := rs.fields.get_saValue('JLang_NativeName');
        saCode          := lowercase(rs.fields.get_saValue('JLang_Code'));
        //ASPrintln('Config - Lang #'+inttostr(i)+' code: '+saCode);
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
  // END ---------------------------------------- garJLanguage: array of rtJLanguage;
  // END ---------------------------------------- garJLanguage: array of rtJLanguage;
  // END ---------------------------------------- garJLanguage: array of rtJLanguage;
  // END ---------------------------------------- garJLanguage: array of rtJLanguage;








  // BEGIN ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // BEGIN ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // BEGIN ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // BEGIN ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'JIDX_JIndexFile_UID,'+
        'JIDX_JVHost_ID,'+
        'JIDX_Filename '+
      'FROM jindexfile '+
      'WHERE ((JIDX_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(JIDX_Deleted_b IS NULL)) '+
      'ORDER BY JIDX_Order_u';
    bOk:=rs.Open(saQry,gaJCon[0],201503161656);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load index file list. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210071006, saMsg, SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJIndexFileLight, length(garJIndexFileLight)+1);
      i4:=length(garJIndexFileLight)-1;
      clear_JIndexFileLight(garJIndexFileLight[i4]);
      with garJIndexFileLight[i4] do begin
        u8JIndexFile_UID        :=u8Val(rs.fields.Get_saValue('JIDX_JIndexFile_UID'));
        u8JVHost_ID             :=u8Val(rs.fields.Get_saValue('JIDX_JVHost_ID'));
        saFilename              :=rs.fields.Get_saValue('JIDX_Filename');
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
  if bOk and (length(garJIndexfileLight)=0) then
  begin
    setlength(garJIndexFileLight, 1);
    clear_JIndexFileLight(garJIndexFileLight[0]);
    with garJIndexFileLight[0] do begin
      u8JIndexFile_UID        :=0;
      u8JVHost_ID             :=cnDefault_JVHost_ID;
      saFilename              :='index.jas';
    end;
  end;
  // END ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // END ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // END ---------------------------------------- garJIndexFile: array of rtJIndexfile;
  // END ---------------------------------------- garJIndexFile: array of rtJIndexfile;















  // BEGIN ---------------------------------------- garJIPList: array of rtJIPList;
  // BEGIN ---------------------------------------- garJIPList: array of rtJIPList;
  // BEGIN ---------------------------------------- garJIPList: array of rtJIPList;
  // BEGIN ---------------------------------------- garJIPList: array of rtJIPList;
  //ASPRintln('Load jiplist 1st time');
  if bOk then
  begin
    u8RowsOfIP:=gaJCon[0].u8GetRecordCount('jiplist','(JIPL_Deleted_b is null) or (JIPL_Deleted_b = false)',201602272040);
    if u8RowsOfIP=0 then
    begin
      setlength(garJIPListLight,4096);
    end
    else
    begin
      setlength(garJIPListLight,u8RowsOfIP +4096);
      saQry:=
        'SELECT '+
          'JIPL_JIPList_UID,'+
          'JIPL_IPListType_u,'+
          'JIPL_IPAddress '+
        'FROM jiplist '+
        'WHERE ((JIPL_IPAddress IS NOT NULL) and (JIPL_IPAddress <> '''')) and  ((JIPL_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+') or (JIPL_Deleted_b IS NULL))';
      bOk:=rs.Open(saQry,gaJCon[0],201503161657);
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        saMsg:='Unable to load IP Lists. Query: '+saQry;
        JASPrintln(saMSG);
        JLog(cnLog_FATAL, 201210070847, 'Unable to load configuration settings. Query: '+saQry, SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      i4:=0;
      repeat
        //setlength(garJIPListLight, length(garJIPListLight)+1);
        clear_JIPListLight(garJIPListLight[i4]);
        with garJIPListLight[i4] do begin
          u8JIPList_UID            :=u8Val(rs.fields.get_saValue('JIPL_JIPList_UID'));
          u1IPListType             :=u1Val(rs.fields.get_saValue('JIPL_IPListType_u'));
          sIPAddress               :=rs.fields.get_saValue('JIPL_IPAddress');
          //riteln(u8JIPList_UID,' ',u1IPListType,' ',saIPAddress);
        end;
        i4+=1;
      until (not bOk) or (not rs.MoveNext);
    end;
  end;
  rs.close;
  //ASPRintln('past Loading jiplist 1st time');
  // END ---------------------------------------- garJIPList: array of rtJIPList;
  // END ---------------------------------------- garJIPList: array of rtJIPList;
  // END ---------------------------------------- garJIPList: array of rtJIPList;
  // END ---------------------------------------- garJIPList: array of rtJIPList;






  // BEGIN ---------------------------------------- garJAlias: array of rtJAlias;
  // BEGIN ---------------------------------------- garJAlias: array of rtJAlias;
  // BEGIN ---------------------------------------- garJAlias: array of rtJAlias;
  // BEGIN ---------------------------------------- garJAlias: array of rtJAlias;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'Alias_JAlias_UID,'+
        'Alias_JVHost_ID,'+             
        'Alias_Alias,'+
        'Alias_Path, '+
        'Alias_VHost_b '+
      'FROM jalias '+
      'WHERE ((Alias_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(Alias_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry,gaJCon[0],201503161658);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load aliases. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210070948, 'Unable to load configuration settings. Query: '+saQry, SOURCEFILE);
    end;
  end;


  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJAliasLight, length(garJAliasLight)+1);
      i4:=length(garJAliasLight)-1;
      clear_JAliasLight(garJAliasLight[i4]);
      with garJAliasLight[i4] do begin
        u8JAlias_UID  :=u8Val(rs.fields.get_saValue('Alias_JAlias_UID'));
        u8JVHost_ID   :=u8Val(rs.fields.get_saValue('Alias_JVHost_ID'));
        saAlias       :=rs.fields.get_saValue('Alias_Alias');
        if saLeftStr(saAlias,1)<>'/' then saAlias:='/'+saAlias;
        if saRightStr(saAlias,1)<>'/' then saAlias:=saAlias+'/';
        //if saRightStr(saAlias,1)='/' then saAlias:=saLeftstr(saAlias,length(saAlias)-1);
        saPath        :=rs.fields.get_saValue('Alias_Path');
        bVHost        :=bVal(rs.fields.get_saValue('Alias_VHost_b'));
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;

  {
  bGotOne:=false;
  if length(garJAliasLight)>0 then
  begin
    bGotOne:=false;
    for i:=0 to length(garJAliasLight)-1 do
    begin
      bGotOne:=(garJAliasLight[i].u8JVHost_ID=0) and
               (garJAliasLight[i].saAlias='jws');
      if bGotOne then
      begin
        //ASPrintln('Found jws alias for default VHOST');
        grJASConfig.saWebshareDir:=garJAliasLight[i].saPath;
        break;
      end;
    end;
  end;
  if NOT bGotOne then
  begin
    //ASPrintln('DID NOT FIND jws alias for default VHOST - adding it');
    setlength(garJAliasLight, length(garJAliasLight)+1);
    clear_JAliasLight(garJAliasLight[length(garJAliasLight)-1]);
    with garJAliasLight[length(garJAliasLight)-1] do begin
      u8JAlias_UID            :=0;
      u8JVHost_ID             :=cnDefault_JVHost_ID;
      saAlias                 :='/jws/';
      saPath                  :=grJASConfig.saWebshareDir;
    end;
  end;
  }
  
  // END ---------------------------------------- garJAlias: array of rtJAlias;
  // END ---------------------------------------- garJAlias: array of rtJAlias;
  // END ---------------------------------------- garJAlias: array of rtJAlias;
  // END ---------------------------------------- garJAlias: array of rtJAlias;






  // BEGIN ---------------------------------------- garJMime: array of rtJMime;
  // BEGIN ---------------------------------------- garJMime: array of rtJMime;
  // BEGIN ---------------------------------------- garJMime: array of rtJMime;
  // BEGIN ---------------------------------------- garJMime: array of rtJMime;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'MIME_JMime_UID,'+
        'MIME_Name,'+
        'MIME_Type,'+
        'MIME_SNR_b '+
      'FROM jmime '+
      'WHERE ((MIME_Deleted_b<>'+gaJCon[0].sDBMSBoolScrub(true)+')OR(MIME_Deleted_b IS NULL)) AND '+
        'MIME_Enabled_b='+gaJCon[0].sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry,gaJCon[0],201503161659);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load mime type settings. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210070952, saMsg, SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJMimeLight, length(garJMimeLight)+1);
      i4:=length(garJMimeLight)-1;
      clear_JMimeLight(garJMimeLight[i4]);
      with garJMimeLight[i4] do begin
        u8JMime_UID :=u8Val(rs.fields.get_saValue('MIME_JMime_UID'));
        sName       :=rs.fields.get_saValue('MIME_Name');
        sType       :=rs.fields.get_saValue('MIME_Type');
        bSNR        :=bVal(rs.fields.get_saValue('MIME_SNR_b'));
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
  // END ---------------------------------------- garJMime: array of rtJMime;
  // END ---------------------------------------- garJMime: array of rtJMime;
  // END ---------------------------------------- garJMime: array of rtJMime;
  // END ---------------------------------------- garJMime: array of rtJMime;






  //-------------------------------------------------  JAS DEFAULT CONNECTION ROW
  if bOk then
  begin
    // IMPORTANT - FIRST CONNECTION GETS NAMED JAS
    // We Enforce for JDConnection UID is ONE for the main JAS connection
    gaJCon[0].ID:=1;
    gaJCon[0].sName:='JAS';
    if gaJCon[0].u8GetRecordCount('jdconnection','JDCon_JDConnection_UID=1',201506171780)=0 then
    begin
      saQry:=
        'INSERT INTO jdconnection ('+
          'JDCon_JDConnection_UID,'+
          'JDCon_Name,'+
          'JDCon_Desc,'+
          'JDCon_DSN,'+
          'JDCon_DSN_FileBased_b,'+
          'JDCon_DSN_Filename,'+
          'JDCon_Enabled_b,'+
          'JDCon_DBMS_ID,'+
          'JDCon_Driver_ID,'+
          'JDCon_Username,'+
          'JDCon_Password,'+
          'JDCon_ODBC_Driver,'+
          'JDCon_Server,'+
          'JDCon_Database,'+
          'JDCon_DBC_Filename,'+
          'JDCon_JSecPerm_ID,'+
          'JDCon_CreatedBy_JUser_ID,'+
          'JDCon_Created_DT,'+
          'JDCon_ModifiedBy_JUser_ID,'+
          'JDCon_Modified_DT,'+
          'JDCon_DeletedBy_JUser_ID,'+
          'JDCon_Deleted_DT,'+
          'JDCon_Deleted_b,'+
          'JAS_Row_b'+
        ')VALUES('+
          gaJCon[0].sDBMSUIntScrub(1)+','+
          gaJCon[0].saDBMSScrub('JAS')+','+
          gaJCon[0].saDBMSScrub('JAS Default Connection.')+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sDSN)+','+
          gaJCon[0].sDBMSBoolScrub(gaJCon[0].bFileBasedDSN)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saDSNFilename)+','+
          gaJCon[0].sDBMSBoolScrub(true)+','+
          gaJCon[0].sDBMSUIntScrub(gaJCon[0].u8DbmsID)+','+
          gaJCon[0].sDBMSUIntScrub(gaJCon[0].u8DriverID)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sUsername)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sPassword)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sDriver)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sServer)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].sDatabase)+','+
          gaJCon[0].saDBMSScrub(saDBCFile)+','+
          gaJCon[0].sDBMSUIntScrub(gaJCon[0].JDCon_JSecPerm_ID)+','+
          gaJCon[0].sDBMSUIntScrub(0)+','+
          gaJCon[0].sDBMSDateScrub(now)+','+
          gaJCon[0].sDBMSUIntScrub('NULL')+','+
          gaJCon[0].sDBMSDateScrub('NULL')+','+
          gaJCon[0].sDBMSUIntScrub('NULL')+','+
          gaJCon[0].sDBMSDateScrub('NULL')+','+
          gaJCon[0].sDBMSBoolScrub(false)+','+
          gaJCon[0].sDBMSBoolScrub(true)+
        ')';
      bOk:=rs.open(saQRY,gaJCon[0],201503161660);
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        JLog(cnLog_FATAL, 201203121227, 'Unable to Insert MAIN JAS Connection Record into Database: '+saQry, SOURCEFILE);
      end;
      rs.close;
    end
    else
    begin
      saQry:=
        'UPDATE jdconnection SET '+
          'JDCon_Name='                   +gaJCon[0].saDBMSScrub('JAS')+','+
          'JDCon_DSN='                    +gaJCon[0].saDBMSScrub(gaJCon[0].sDSN)+','+
          'JDCon_DBC_Filename='           +gaJCon[0].saDBMSScrub(saDBCFile)+','+
          'JDCon_Enabled_b='              +gaJCon[0].sDBMSBoolScrub(true)+','+
          'JDCon_DBMS_ID='                +gaJCon[0].sDBMSUIntScrub(gaJCon[0].u8DbmsID)+','+
          'JDCon_Driver_ID='              +gaJCon[0].sDBMSIntScrub(gaJCon[0].u8DriverID)+','+
          'JDCon_Username='               +gaJCon[0].saDBMSScrub(gaJCon[0].sUsername)+','+
          'JDCon_Password='               +gaJCon[0].saDBMSScrub(gaJCon[0].sPassword)+','+
          'JDCon_ODBC_Driver='            +gaJCon[0].saDBMSScrub(gaJCon[0].sDriver)+','+
          'JDCon_Server='                 +gaJCon[0].saDBMSScrub(gaJCon[0].sServer)+','+
          'JDCon_Database='               +gaJCon[0].saDBMSScrub(gaJCon[0].sDatabase)+','+
          'JDCon_DSN_FileBased_b='        +gaJCon[0].sDBMSBoolScrub(gaJCon[0].bFileBasedDSN)+','+
          'JDCon_DSN_Filename='           +gaJCon[0].saDBMSScrub(gaJCon[0].saDSNFilename)+','+
          'JDCon_JSecPerm_ID='            +gaJCon[0].sDBMSUIntScrub(gaJCon[0].JDCon_JSecPerm_ID)+','+
          'JDCon_ModifiedBy_JUser_ID='    +gaJCon[0].sDBMSUIntScrub(0)+','+
          'JDCon_Modified_DT='            +gaJCon[0].sDBMSDateScrub(now)+','+
          'JDCon_DeletedBy_JUser_ID='     +gaJCon[0].sDBMSUIntScrub('NULL')+','+
          {$IFNDEF WINDOWS}
            'JDCon_Deleted_DT='+gaJCon[0].sDBMSDateScrub('NULL')+','+
          {$ENDIF}
          'JDCon_Deleted_b='              +gaJCon[0].sDBMSBoolScrub(false)+','+
          'JAS_Row_b='                    +gaJCon[0].sDBMSBoolScrub(true)+' '+
        'WHERE JDCon_JDConnection_UID='+gaJCon[0].sDBMSUIntScrub(1);
      bOk:=rs.open(saQRY,gaJCon[0],201503161661);
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        JLog(cnLog_FATAL, 201203121228, 'Unable to Update MAIN JAS Connection Record into Database: '+saQry, SOURCEFILE);
      end;
      rs.close;
    end;
  end;
  //-------------------------------------------------  JAS DEFAULT CONNECTION ROW

  if not gbMainSystemOnly then
  begin
    if bOk then
    begin
      saQry:='select * from jdconnection where JDCon_Deleted_b<>'+
        gaJCon[0].sDBMSBoolScrub(true)+' and '+
        'JDCon_JDConnection_UID>1 and '+
        'JDCon_Enabled_b='+gaJCon[0].sDBMSBoolScrub(true)+' order by JDCon_Name';
      bOk:=rs.Open(saQry,gaJCon[0],201503161662);
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        JLog(cnLog_FATAL, 201002061631, 'Unable to Query Connections:'+saQry, SOURCEFILE);
      end;
    end;

    bUnableToOpen:=false;
    if bOk then
    begin
      if rs.EOL=false then
      begin
        i4:=1;
        repeat
          setlength(gaJCon,i4+1);
          gaJCon[i4]:=JADO_CONNECTION.Create;
          gaJCon[i4].ID:=                  u8Val(rs.Fields.Get_saValue('JDCon_JDConnection_UID'));
          gaJCon[i4].JDCon_JSecPerm_ID:=   u8Val(rs.fields.Get_saValue('JDCon_JSecPerm_ID'));
          gaJCon[i4].sName:=              upcase(rs.Fields.Get_saValue('JDCon_Name'));
          gaJCon[i4].saDesc:=              rs.Fields.Get_saValue('JDCon_Desc');
          gaJCon[i4].sDSN:=               rs.Fields.Get_saValue('JDCon_DSN');
          gaJCon[i4].sUserName:=          rs.Fields.Get_saValue('JDCon_Username');
          gaJCon[i4].sPassword:=          rs.Fields.Get_saValue('JDCon_Password');
          gaJCon[i4].sDriver:=            rs.Fields.Get_saValue('JDCon_ODBC_Driver');
          gaJCon[i4].sServer:=            rs.Fields.Get_saValue('JDCon_Server');
          gaJCon[i4].sDatabase:=          rs.Fields.Get_saValue('JDCon_Database');
          gaJCon[i4].u8DriverID:=            u8Val(rs.Fields.Get_saValue('JDCon_Driver_ID'));
          gaJCon[i4].u8DbmsID:=            u8Val(rs.Fields.Get_saValue('JDCon_DBMS_ID'));
          gaJCon[i4].bFileBasedDSN:=       bVal(rs.Fields.Get_saValue('JDCon_DSN_FileBased_b'));
          gaJCon[i4].saDSNFileName:=       rs.Fields.Get_saValue('JDCon_DSN_Filename');
          gaJCon[i4].bJas:=                bVal(rs.Fields.Get_saValue('JDCon_JAS_b'));

          saDBCFilename:=rs.Fields.Get_saValue('JDCon_DBC_Filename');
          saMsg:='Database Name : '+gaJCon[i4].sName+' ';
          saMsg+='Description: '+gaJCon[i4].saDesc+' ';
          saMsg+='DBC File: '+saDBCFilename+' ';
          //ASPrintln(saMsg);JLog(cnLog_DEBUG, 201002091726, saMsg, SOURCEFILE);
          bOk:=fileexists(saDBCFilename);
          if bOk then
          begin
            bOk:=gaJCon[i4].bLoad(saDBCFilename);
            if not bOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              bUnableToOpen:=true;
              JLog(cnLog_FATAL, 201002061751, '****Unable to load DBC configuration file: ' + saDBCFilename, SOURCEFILE);
            end;
          end
          else
          begin
            bOk:=true;
            //ASPrintln('Connection: ' + gaJCon[i].saName);
            gaJCon[i4].bFileBasedDSN := bVal(rs.Fields.Get_saValue('JDCon_DSN_FileBased_b'));
            gaJCon[i4].saDSNFileName := rs.Fields.Get_saValue('JDCon_DSN_Filename');
          end;

          bOk:=gaJCon[i4].sName<>'JAS';
          if not bOk then
          begin
            bLogEntryMadeDuringStartUp:=true;
            bUnableToOpen:=true;
            JLog(cnLog_FATAL, 201210271550, '****Duplicate JAS Connection: ' + saDBCFilename, SOURCEFILE);
          end;

          if bOk then
          begin
            //ASPrintln('Opening Connection: '+inttostr(i));
            //Log(cnLog_Debug, 201204071354, 'About to Open Connection: '+gaJCon[i].saName, SOURCEFILE);
            bOk:=gaJCon[i4].OpenCon;
            if not bOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              bUnableToOpen:=true;
              JLog(cnLog_FATAL, 201002061633, '*** Unable to connect to JDConnection: '+gaJCon[i4].sName, SOURCEFILE);
            end;
          end;
          i4+=1;
        //until (bOk=false) or (JADOR.MoveNext=false);
        until (rs.MoveNext=false);
        if bUnableToOpen then
        begin
          JASPrintln('One or more additional database connections couldn''t connect.');
        end;
        //ASPrintln('gaJCon length:'+inttostr(length(gaJCon)));
        bOk:=true;// allow JAS to run with the connection issues
      end;
    end;
    rs.close;
  end;

  if bOk then
  Begin
    for iHost:=0 to length(garJVHost)-1 do
    begin
      //ASPrintln('Host #:'+inttostr(iHost));
      iDBX:=0;bDone:=false;
      repeat
        //ASPrintln('VHDBC REPEAT');
        if gaJCon[iDBX].ID=garJVHost[iHost].VHost_JDConnection_ID then
        begin
          bDone:=true;
        end
        else
        begin
          iDBX+=1;
        end;
      until bDone or (iDBX=length(gaJCon));

      if iDBX<length(gaJCon) then
      begin
        //ASDebugPrintln('config-menu-create iHost: '+inttostr(iHost)+' gaCon:'+inttostr(iDBX)+
        //  ' vhost length:'+inttostr(length(garJVHostLight))+' gaJCon length:'+inttostr(length(gaJCon)));
        //ASPrintln('Begin Menu Load');
        if not bCreateAndLoadJMenuIntoDL(garJVHost[iHost].MenuDL, gaJCon[iDBX]) then
        Begin
          bLogEntryMadeDuringStartUp:=true;
          saMSG:='Unable to load JMenuIntoDL Host: '+garJVHost[iHost].VHost_ServerDomain;
          JLog(cnLog_Warn, 201001151805, saMsg, SOURCEFILE);
          JASPrintln(saMsg);
        End;
        //ASPrintln('End Menu Load');


        // Don't want to delete log file if wrong server configuration, that's why we place this AFTER
        // the IDENT check.
        if bOk then
        begin
          If grJASConfig.bDeleteLogFile and (NOT bLogEntryMadeDuringStartUp) Then
          begin
            JASPrintln('Core_Init delete log');
            saQry:='delete from jlog';
            bOk:=rs.Open(saQry,gaJCon[iDBX],201503161663);
            if not bOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201004110138, 'Unable to empty jlog table:'+saQry, SOURCEFILE);
            end;
          end;
        end;
        rs.Close;



        // BEGIN ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // BEGIN ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // BEGIN ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // BEGIN ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        if bOk then
        begin
          //ASPrintln('Begin JAS IDENT');
          //ASPrintln('Check Length garJVHost: '+inttostr(length(garJVHost)));
          //ASPrintln('JAS IDENT - Begin first assignment to garJVHost[iHost].');
          garJVHost[iHost].bIdentOk:=true;
          //ASPrintln('JAS IDENT - Past first assignment to garJVHost[iHost].');
          
          saQry:='select count(*) as MyCount from jasident';
          garJVHost[iHost].bIdentOk:=rs.Open(saQry,gaJCon[iDBX],201503161664);
          if not garJVHost[iHost].bIdentOk then
          begin
            bLogEntryMadeDuringStartUp:=true;
            JLog(cnLog_FATAL, 201007231729, 'Host: '+garJVHost[iHost].VHost_ServerDomain+' Unable to load JAS Server ID from jasident table. Query: '+saQry, SOURCEFILE);
          end;
          //ASPRintln('IDENT 1');

          if garJVHost[iHost].bIdentOk then
          begin
            garJVHost[iHost].bIdentOk:=(i8Val(rs.Fields.Get_saValue('MyCount')) = 1);
            if not garJVHost[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231730, 'Host: '+garJVHost[iHost].VHost_ServerDomain+' Invalid record count in jasident table. Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 2');

          if garJVHost[iHost].bIdentOk then
          begin
            rs.close;
            saQry:='select JASID_ServerIdent from jasident';
            garJVHost[iHost].bIdentOk:=rs.Open(saQry, gaJCon[iDBX],201503161665);
            if not garJVHost[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231731, 'Host: '+garJVHost[iHost].VHost_ServerDomain+' Unable to load JAS Server Ident. Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 3');

          if garJVHost[iHost].bIdentOk then
          begin
            garJVHost[iHost].bIdentOk:=rs.EOL=false;
            if not garJVHost[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231732, 'JET: '+garJVHost[iHost].VHost_ServerName+' Zero records returned trying to check JAS Ident Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 4');

          if garJVHost[iHost].bIdentOk then
          begin
            garJVHost[iHost].bIdentOk:=trim(upcase(rs.Fields.Get_saValue('JASID_ServerIdent')))=garJVHost[iHost].VHost_ServerIdent;
            if not garJVHost[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231733, 'Host: '+garJVHost[iHost].VHost_ServerDomain+
                ' Invalid JAS Server Ident! Do not have a jasident on my watch! '+
                'Configured Ident: '+garJVHost[iHost].VHost_ServerIdent+' Database Ident: '+
                trim(upcase(rs.Fields.Get_saValue('JASID_ServerIdent'))), SOURCEFILE);
            end;
          end;
          rs.close;
          //ASPrintln('End JAS IDENT Check');
        end;
        // END ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // END ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // END ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---
        // END ------------- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK --- IDENT CHECK ---

        if garJVHost[iHost].bIdentOK then
        begin
          // NOTE: These Settings do not have a configuration file override
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          //ASPrintln('BEGIN - Load Host Specific Preferences');
          if bOk then
          begin
            if JADO.bFoundConnectionByID(garJVHost[iHost].VHost_JDConnection_ID,pointer(gaJCon),iDBX) then
            begin
              saQry:='select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from '+
                    'juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and '+
                    'UsrPL_User_ID=1 and ((UserP_Deleted_b<>'+gaJCon[iDBX].sDBMSBoolScrub(true)+')OR(UserP_Deleted_b IS NULL))';
              bOk:=rs.open(saQry, gaJCon[iDBX],201503161666);
              if not bOk then
              begin
                bLogEntryMadeDuringStartUp:=true;
                saMsg:='Unable to load admin configuration preferences for JET '+garJVHost[iHost].VHost_ServerName+'. Query: '+saQry;
                JASPrintln(saMsg);
                JLog(cnLog_FATAL, 201210061919, saMsg, SOURCEFILE);
              end;

              if bOk and (not rs.EOL) then
              begin
                //ASPrintln('Reading per host prefs');
                repeat
                  u8DataIn:=u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID'));
                  saDataIn:=rs.fields.Get_saValue('UsrPL_Value');
                  if (u8DataIn=1211061842380300007) then
                  begin
                    garJVHost[iHost].VHost_AllowRegistration_b:=bVal(saDataIn);
                    //ASPrintLn('Got bAllow Registration for VHost: ' +inttostr(iHost)+' saDataIn: '+ saDataIn+' bVal: '+sYesNo(bVal(saDataIn)));
                  end else
                  if (u8DataIn=1211061843220630009) then
                  begin
                    garJVHost[iHost].VHost_RegisterReqCellPhone_b:=bVal(saDataIn);
                  end else
                  if (u8DataIn=1211061843072620008) then
                  begin
                    garJVHost[iHost].VHost_RegisterReqBirthday_b:=bVal(saDataIn);
                  end;
                until not rs.movenext;
              end;
              rs.close;
            end;
          end;
          //ASPrintln('END - Load Host Specific Preferences');
          // END ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // END ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // END ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // END ------------------------------------------ USER PREF SETTINGS (ALL JETS)


          // Wipe Menu Cache
          if bOk then
          begin
            //ASPrintln('BEGIN - Wipe Menu Cache');
            sa:=saAddSlash(garJVHost[iHost].VHost_CacheDir)+'jas-menu';
            //if FileExists(sa) then
            if directoryexists(sa) then
            begin
              //u2IOResult:=u2Shell('../bin/rmdir.sh', sa);
              //bOk:=(u2IOResult=0) or (u2IOResult=1);
              DIR:=JFC_DIR.Create;
              bOk:=DIR.DeleteThis(sa) and (RemoveDir(sa)) and ( not directoryExists(sa) );
              DIR.Destroy;
              if not bOk then
              begin
                JLOG(cnLog_Error, 201212021152, 'Unable to remove menu cache for Server Ident: '+garJVHost[iHost].VHost_ServerIdent+' Dir: '+sa,SOURCEFILE);
              end;
            end;
            //ASPrintln('END - Wipe Menu Cache');
          end;

        end;
      end;
      if gbMainSystemOnly then break;
    end;
  End;

  if bOk then
  begin
    //ASPrintln('Begin - bCreatePHPJASTableDef');
    bOk:=bCreatePHPJASTableDef;
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_WARN, 201003211612, 'Unable to create config.jastabledef.php file', SOURCEFILE);
    end;
    //ASPrintln('END - bCreatePHPJASTableDef');
  end;

  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================
















//=============================================================================
function bApplyBasicConfigSettings: boolean;
//=============================================================================
var
  bOk: boolean;
  saJegasSigFilename: ansistring;

{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bApplyBasicConfigSettings';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  If bOk Then
  Begin
    {$IFDEF DIAGNOSTIC_LOG}
    grJASConfig.saDiagnosticLogFileName:=grJASConfig.saLogDir+'jas-diagnostic.log';
    {$ENDIF}
    grJASConfig.sServerSoftware:=csINET_JAS_SERVER_SOFTWARE;
    saJegasSigFilename:=grJASConfig.saSysDir+'templates'+DOSSLASH+ grJASConfig.saJASFooter;
    gsaJASFooter:='';
    if not bLoadTextFile(saJegasSigFileName,gsaJASFooter)then
    begin
      gsaJASFooter:='<hr /><center>Copyright&copy;2016 - Jegas, LLC</center>';
    end;
  end;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================












//=============================================================================
function bCreateThreads:boolean;
//=============================================================================
var
  bOk: boolean;
  JTI: rtJThreadInit;
  u2CreateHttpWorkerThreads: word;
  iBindCount:integer;
  u2ThreadsToMake: word;
  bServerCyclingNow: boolean;
  saMsg: ansistring;
  bThreadExceptionThrown: boolean; //generally the OS is not liking our configured threadcount.
  //u8RowsOfIP: uint64;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bCreateThreads';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //bOk:=true;
  //if bOk then
  //begin
    InitThreadManager;
    //asprintln('initthreadmanager complete');
  //end;

  // Create HTTP Listener
  gListener:=nil;
  bThreadExceptionThrown:=false;
  //if bOk then
  //begin
    with JTI do begin
      bCreateCriticalSection:=true;
      bLoopContinuously:=true;
      bCreateSuspended:=true;
      bFreeOnTerminate:=false;
      UID:=0;
    end;//end with
    gListener:=TListen.create(JTI);

    if TEMP_CYCLE_LISTENSOCK=nil then
    begin
      bServerCyclingNow:=false;
      gListener.ListenSock:=TTCPBlockSocket.Create;
      TEMP_CYCLE_LISTENSOCK:=gListener.ListenSock;
    end
    else
    begin
      bServerCyclingNow:=true;
      gListener.ListenSock:=TEMP_CYCLE_LISTENSOCK;
    end;

    // TODO: revisit SSL
    //gListener.ListenSock.SSL.CertCAFile := grJASConfig.saConfigDir + 'cert' + DOSSLASH + 's_cabundle.pem';
    //gListener.ListenSock.SSL.CertificateFile := grJASConfig.saConfigDir + 'cert' + DOSSLASH +  's_cacert.pem';
    //gListener.ListenSock.SSL.PrivateKeyFile := grJASConfig.saConfigDir + 'cert' + DOSSLASH + 's_cakey.pem';
    //gListener.ListenSock.SSL.KeyPassword := 's_cakey';
    //gListener.ListenSock.SSL.verifyCert := True;
    // TODO: revisit SSL

    //ListenSock.NonBlockMode:=true;
    if not bServerCyclingNow then
    begin
      JASPrint('Binding:'+grJASConfig.sServerIP+':'+inttostr(grJASConfig.u2ServerPort)+' Please Wait');
      iBindCount:=0;
      repeat
        gListener.ListenSock.bind(grJASConfig.sServerIP,inttostr(grJASConfig.u2ServerPort));
        JASPRINT('.');
        if gListener.ListenSock.lasterror<> 0 then
        begin
          Yield(grJASConfig.u2CreateSocketRetryDelayInMSec);
          iBindCount:=iBindCount+1;
        end;
      until (gListener.ListenSock.lasterror=0) or (iBindCount>grJASConfig.u2CreateSocketRetry);
      bOk:=gListener.ListenSock.lasterror=0;
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        saMsg:='(Bind)ListenSock.LastError:'+inttostr(gListener.ListenSock.lasterror);
        JASPrintln(saMsg);
        JLog(cnLog_FATAL, 201203121138, saMsg, SOURCEFILE);
      end;

      if bOk then
      begin
        gListener.ListenSock.listen;
        bOk:=gListener.ListenSock.lasterror=0;
        if not bOk then
        begin
          bLogEntryMadeDuringStartUp:=true;
          saMsg:='(Listen)ListenSock.LastError:'+inttostr(gListener.ListenSock.lasterror);
          JASPrintln(saMsg);
          JLog(cnLog_FATAL, 201203121139, saMsg, SOURCEFILE);
        end;
      end;
    end
    else
    begin
      gListener.ListenSock:=TEMP_CYCLE_LISTENSOCK;
      TEMP_CYCLE_LISTENSOCK:=nil;
    end;
    JASPrintln('Got it!');
  //end;

  // Create HTTP Workers
  if bOk then
  begin
    //asprintln('make workers');

    bOk:=grJASConfig.u2ThreadPoolNoOfThreads>0;
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='ZERO THREADS CONFIGURED. Set ThreadPool_NoOfThreads greater than zero.';
      JASPrintln('');
      JASPrintln(saMsg);
      JASPrintln('');
      JLog(cnLog_FATAL, 201203121138, saMsg, SOURCEFILE);
    end;

    
    if bOk then
    begin
      JASPrint('Creating '+inttostr(grJASConfig.u2ThreadPoolNoOfThreads)+' worker threads: ');
      with JTI do begin
        bCreateCriticalSection:=false;
        bLoopContinuously:=false;
        bCreateSuspended:=true;
        bFreeOnTerminate:=true;
      end;
      u2ThreadsToMake:=grJASConfig.u2ThreadPoolNoOfThreads;
      setlength(aWorker,u2ThreadsToMake);
      for u2CreateHttpWorkerThreads:=0 to u2ThreadsToMake-1 do
      begin
        JASPrint(inttostr(u2CreateHttpWorkerThreads+1));
        JTI.UID:=u2CreateHttpWorkerThreads+1;
        try
          bOk:=false;
          aWorker[u2CreateHttpWorkerThreads]:=TWorker.Create(JTI);
          JASPrint('.');
          aWorker[u2CreateHttpWorkerThreads].uMyID:=u2CreateHttpWorkerThreads;
          bOk:=true;// only stays true if succeeds
        except on E: EThread do
          begin
            bThreadExceptionThrown:=true;
            //ASPrintln('Exception ETHREAD THROWN - 201012191646');
            break;
          end;
        end;
      end;

      if (bThreadExceptionThrown) then
      begin
        if (u2CreateHttpWorkerThreads>0) then
        begin
          bOk:=true;
          JASPrintln(CRLF);
          JASPrintln(saRepeatchar('=',79));
          JASPrint('Only able to create '+inttostr(u2CreateHttpWorkerThreads-1));
          JASPrintln(' of '+inttostr(grJASConfig.u2ThreadPoolNoOfThreads)+' Worker threads.');
          grJASConfig.u2ThreadPoolNoOfThreads:=u2CreateHttpWorkerThreads-1;
          JASPrintln(saRepeatchar('=',79));
          JASPrintln;
          bOk:=false;
        end;
      end;
      if not bOk then
      begin
        JASPRintln('');
        JASPRintln('FATAL - Unable to Allocate Threads - Restart Application; '+
          'Try lowering the thread count if this problem persists.');
      end;
    end;
  end;

  if bOk then
  begin
    //gListener.suspended:=false;
    gListener.start;
  end;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================











//=============================================================================
function bJAS_Init: boolean;
//=============================================================================
var
  bOk: boolean;
  saMsg: ansistring;
  //tk: JFC_TOKENIZER;
  i4: longint;
  rs: JADO_RECORDSET;
  saQry: string;
  //s: string;
  u,x: uint;
  u8UID: uint;
  bTemp: boolean;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bCore_Init';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  gbServerShuttingDown:=false;
  gbServerCycling:=false;
  ResetConfigOverRidden;
  ResetJVHostOverridden;
  clear_JVHost(rJVHostOverride);

  //gi8JipListLightSync:=0;
  if bOk then
  begin
    JASPrint('Loading Configuration, ');
    bOk:=bLoadConfigurationFile;
    If not bOk Then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to Load configuration file successfully.';
      JLog(cnLog_FATAL, 201002061640, saMsg, SOURCEFILE);
      JASPrintln(csCRLF+saMsg);
    End;
  end;
  //riteln('Loaded Config');

  if bOk then
  begin
    if gbMainSystemOnly then
    begin
      JASPrint('Opening Main Database only...');
    end
    else
    begin
      JASPrint('Opening Database(s)...');
    end;
    bOk:=bOpenDatabaseConnections;
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to open database connection(s).';
      JLog(cnLog_FATAL, 201203121034, saMsg, SOURCEFILE);
      JASPrintln(csCRLF+saMSg);
    end;
  end;




  // LOAD REDIRECT LIST ================
  if bOk then
  begin
    saQry:='select REDIR_JRedirect_UID, REDIR_JRedirectLU_ID,REDIR_Location,REDIR_NewLocation from jredirect ';
    saQry+='where (REDIR_Deleted_b=false)or(REDIR_Deleted_b is null)';
    bOk:=rs.open(saQry,gaJCon[0],201605141410);
    if not bOk then
    begin
      saMsg:='Trouble loading the file redirection list.';
      writeln('MSG:',saMsg);
      JLog(cnLog_Error, 201605141411, saMsg, SOURCEFILE);
    end;
  end;
  setlength(garJReDirectLight,0);
  if bOk then
  begin
    if not rs.eol then
    begin
      repeat
        u8UID:=u8Val(rs.fields.get_saValue('REDIR_JRedirect_UID'));
        setlength(garJReDirectLight,length(garJReDirectLight)+1);
        x:=length(garJReDirectLight)-1;
        garJReDirectLight[x].REDIR_JRedirectLU_ID:=u8Val(rs.fields.Get_saValue('REDIR_JRedirectLU_ID'));
        garJReDirectLight[x].REDIR_Location:=rs.fields.Get_saValue('REDIR_Location');
        if leftstr(garJReDirectLight[x].REDIR_Location,1)='/' then
        begin
          garJReDirectLight[x].REDIR_Location:=
            rightstr(garJReDirectLight[x].REDIR_Location,length(garJReDirectLight[x].REDIR_Location)-1);
        end;
        garJReDirectLight[length(garJReDirectLight)-1].REDIR_NewLocation:=rs.fields.Get_saValue('REDIR_NewLocation');
        for u:=0 to length(garJVHost)-1 do
        begin
          if garJVHost[u].VHost_JVHost_UID=u8UID then
          begin
            garJReDirectLight[length(garJReDirectLight)-1].VHostIndex:=u;
            break;
          end;
        end;
        //riteln(garJReDirectLight[length(garJReDirectLight)-1].REDIR_NewLocation);
      until (not bOk) or (not rs.movenext);
    end;
  end;
  rs.close;
  // LOAD REDIRECT LIST ================


  if bOk then
  begin
    with grPunkBeGoneStats do begin
      uBanned:=0;
      // csJIPListLU_WhiteList = '1';
      // csJIPListLU_BlackList = '2';
      // csJIPListLU_InvalidLogin = '3';
      // csJIPListLU_Downloader='4';
      rs:=JADO_RECORDSET.Create;
      saQry:='select JIPL_IPAddress from jiplist where '+
        '((JIPL_Deleted_b = false)or(JIPL_Deleted_b is null)) and ' +
        '((JIPL_IPListType_u='+csJIPListLU_BlackList+' ) or '+
        '(JIPL_IPListType_u='+csJIPListLU_InvalidLogin+' ))';
      bOk:=rs.open(saQry,gaJCon[0],201605010443);
      if not bOk then
      begin
        saMsg:='Trouble getting IP List statistics.';
        writeln('MSG:',saMsg);
        JLog(cnLog_Error, 201605010444, saMsg, SOURCEFILE);
      end;

      if bOk then
      begin
        if not rs.eol then
        begin
          repeat
            uBanned+=uIPAddressCount(rs.fields.Get_saValue('JIPL_IPAddress'));
          until (not bOK) or (not rs.movenext);
        end;
      end;
      rs.close;
      uBannedSinceServerStart:=0;
      dtServerStarted:=now;
      uBlockedSinceServerStart:=0;
    end;
  end;
  //ASPrintln;
  //ASPrintln('Server Software diag: '+grJASConfig.sServerSoftware);

  if bOk then
  begin
    JASPrintln('Applying Configuration Settings.');
    bOk:=bApplyBasicConfigSettings;
    if not bOK then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Trouble applying basic config settings.';
      JLog(cnLog_FATAL, 201203121033, saMsg, SOURCEFILE);
      JASPrintln(saMsg);
    end;
  end;

  if bok then
  begin
    saQry:='select Punk_Bait from jpunkbait where (Punk_Deleted_b<>true) or (Punk_Deleted_b is null)';
    bOk:=rs.open(saQry,gaJCon[0],201604081702);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Trouble loading PunkBait. You did refridgerate it right?';
      JLog(cnLog_FATAL, 201604081703, saMsg, SOURCEFILE);
      JASPrintln(saMsg);
    end;
  end;

  if bOk then
  begin
    if not rs.eol then
    begin
      setlength(gasPunkBait,0);
      i4:=0;
      repeat
        setlength(gasPunkBait,length(gasPunkBait)+1);
        gasPunkBait[i4]:=rs.fields.Get_saValue('Punk_Bait');
        //ASPrintln('uj_config - gasPunkBait['+inttostr(i4)+']:'+gasPunkBait[i4]);
        i4+=1;
      until not rs.movenext;
    end;
  end;
  rs.close;

  if bOk then
  Begin
    JASPrintln('Creating Listener and threads.');
    bOk:=bCreateThreads;
    If not bOk Then
    Begin
      bLogEntryMadeDuringStartUp:=true;
      saMSg:='Unable to load create listener or worker threads.';
      JLog(cnLog_FATAL, 201203121143, saMSg, SOURCEFILE);
    End;
  End;

  if bOk then
  begin
    JASPrint(ENDLINE+saJegasLogoRawText(ENDLINE,true));
    JASPrint('IP:'+grJASConfig.sServerIP+' Port:'+inttostr(grJASConfig.u2ServerPort)+
      ' Threads:'+inttostr(grJASConfig.u2ThreadPoolNoOfThreads)+' ');
    if gbMainSystemOnly then JASPrintln('You''re Flying Now.') else JASPrintln('Squadron Airborne.'); // =|:^)>
    JASPrintln('Type ? and press [ENTER] for help.');

    bTemp:=grJASCOnfig.bServerConsoleMessagesEnabled;
    grJASCOnfig.bServerConsoleMessagesEnabled:=true;
    JASPrintln(FormatDateTime(csDATETIMEFORMAT,now)+' JAS is Ready For Business!');
    grJASCOnfig.bServerConsoleMessagesEnabled:=bTemp;
    //JASPrint(saJegasLogoRawText(csCRLF,true));
    JASPrintln;
  end;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================
















//=============================================================================
function bJAS_ShutDown: boolean;
//=============================================================================
var i:integer;
    bThreadsStillRunning: Boolean;
    //Wrkr: TWORKER;
    saDone: ansistring;
    rNow: TDATETIME;
    bKill: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME:='bJAS_ShutDown';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saDone:='Done.';
  // Shut Down All Threads and Parent "Listener Thread"
  If gbServercycling then
  begin
    TEMP_CYCLE_LISTENSOCK:=gListener.ListenSock;
  end;
  
  // handle last request during listener lock up for shutdown
  if (gListener <> nil)then
  begin
    JASPrint('Allowing listener time to respond...');
    yield(1000);
    //gListener.terminate;
    JASPrintln(saDone);

    if not gbServerCycling then
    begin
      JASPrint('Shutting down IP socket...');
      gListener.ListenSock.CloseSocket;
      if gListener.ListenSock.lasterror <> 0 then
      begin
        JASPrint('(CloseSocket)ListenSock.LastError:'+
        inttostr(gListener.ListenSock.lasterror)+' ');
      end;
      JASPrintln(saDone);
    end;

    // Take On Deck Worker Thread offline if poised to go.
    if(gListener.Worker<>nil)then
    begin
      gListener.Worker.ConnectionSocket:=nil;
    end;
    JASPrint('Shutting down and terminating threads ... (Use CNTL-C to force it)');
    bThreadsStillRunning:=true;
    repeat
      try
        bThreadsStillRunning:=false;
        for i:=0 to grJASConfig.u2ThreadPoolNoOfThreads-1 do
        begin 
          bKill:=(aWorker[i]<>nil);// and (aWorker[i].Suspended or (iDiffMSec(aWorker[i].dtExecuteBegin,now)>grJASCOnfig.iThreadPoolMaximumRunTimeInMSec));
          //if bKill then
          //begin
          //  if aWorker[i].FreeOnTerminate then
          //  begin
          if bKill then
          begin
            //riteln('Killing '+intTostr(i));
            aWorker[i].FREE;aWorker[i]:=nil;
          end;
          //  end
          //  else
          //  begin
          //    aWorker[i].terminate; yield(0); aWorker[i].Destroy;
          //  end;
          //  aWorker[i]:=nil;
          //end;
          bThreadsStillRunning:=bThreadsStillRunning or (aWorker[i]<>nil);
        end;
      Except on E:Exception do ;
      end;
      if(bThreadsStillRunning) then begin jasprint('.');Yield(250);end;// allow some processing to occur
    until bThreadsStillRunning = false;
    setlength(aWorker,0);
    JASPrintln('saDone:'+saDone);
    JASPrint('Destroy Local Database Connection ... ');
    gListener.LDBC.Destroy;JASPrintln(saDone);
    JASPrint('Destroy Listener ... ');
    gListener.terminate;
    gListener.destroy;
    gListener:=nil;
    JAsPrintln(saDone);
  end
  else
  begin
    JASPrintln('Listener Not Instantiated ... Skipping.');
  end;

  for i:=0 to length(gaJCon)-1 do
  begin
   gaJCon[i].DEstroy;gaJCon[i]:=nil;
  end;


  setlength(garJAliasLight,0);
  setlength(garJIPListLight,0);
  for i:=0 to length(garJVHost)-1 do
  begin
    if not bEmptyAndDestroyJMenuDL(garJVHost[i].MenuDL) then
    begin
      JLOG(cnLog_Error, 201210242314,'Unable to empty menu instance garJVHost['+inttostr(i)+'].MenuDL',SOURCEFILE);
    end;
  end;
  setlength(garJVHost,0);
  setlength(garJMimeLight,0);
  setlength(garJIndexFileLight,0);
  setlength(garJLanguageLight,0);
  setlength(garJThemeLight,0);

  //DoneTSFileIO;
  //ASPrintln('Shutting down Thread Manager');
  DoneThreadManager;
  rNow:=now;
  JASPrintln;
  JASPrint('-=-=-=-=-  SERVER ');
  if gbServerCycling then JASPrint('CYCLED') else JASPrint('SHUTDOWN');
  JASPRintln(' - '+ JDate('',cnDateFormat_11,cnDateFormat_00,rNow) +' -=-=-=-=-');
  JASPrintln;

  if not gbServerCycling then
  begin
    JASPrintln('Good Bye!');
    JASPrintln('........');
    JASPrintln('.......');
    JASPrintln('......');
    JASPrintln('.....');
    JASPrintln('....');
    JASPrintln('...');
    JASPrintln('..');
    JASPrintln('.');
    JASPrintln('');
    JASPrintln('');
  end;
  result:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================









//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  bLogEntryMadeDuringStartUp:=false;
  gbMainSystemOnly:=false;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
