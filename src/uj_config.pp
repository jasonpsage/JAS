{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// JAS Specific Functions, Consolidation of JAS configuration
Unit uj_config;
//=============================================================================



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
,ug_jfc_tokenizer
,ug_jfc_threadmgr
,ug_jfc_matrix
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

var bMainSystemOnly: boolean;

type rtConfigOverridden = Record
  bCacheMaxAgeInSeconds                     : boolean;
  bConvert                                  : boolean;
  bCreateSocketRetry                        : boolean;
  bCreateSocketRetryDelayInMSec             : boolean;
  bDebugMode                                : boolean;
  bDebugServerConsoleMessagesEnabled        : boolean;
  bDeleteLogFile                            : boolean;
  bBlackListEnabled                         : boolean;
  bWhiteListEnabled                         : boolean;
  bErrorReportingMode                       : boolean;
  bErrorReportingSecureMessage              : boolean;
  bFFMPEG                                   : boolean;
  bHOOK_ACTION_CREATESESSION_FAILURE        : boolean;
  bHOOK_ACTION_CREATESESSION_SUCCESS        : boolean;
  bHOOK_ACTION_REMOVESESSION_FAILURE        : boolean;
  bHOOK_ACTION_REMOVESESSION_SUCCESS        : boolean;
  bHOOK_ACTION_SESSIONTIMEOUT               : boolean;
  bHOOK_ACTION_VALIDATESESSION_FAILURE      : boolean;
  bHOOK_ACTION_VALIDATESESSION_SUCCESS      : boolean;
  bJobQEnabled                              : boolean;
  bJobQIntervalInMSec                       : boolean;
  bLogLevel                                 : boolean;
  bLogMessagesShowOnServerConsole           : boolean;
  bMaximumRequestHeaderLength               : boolean;
  bThreadPoolMaximumRunTimeInMSec           : boolean;
  bMaxFileHandles                           : boolean;
  bThreadPoolNoOfThreads                    : boolean;
  bPerl                                     : boolean;
  bPHP                                      : boolean;
  bProtectJASRecords                        : boolean;
  bClientToVICIServerIP                     : boolean;
  bJASServertoVICIServerIP                  : boolean;
  bLockRetriesBeforeFailure                 : boolean;
  bLockRetryDelayInMSec                     : boolean;
  bLockTimeoutInMinutes                     : boolean;
  bRetryDelayInMSec                         : boolean;
  bRetryLimit                               : boolean;
  bSafeDelete                               : boolean;
  bServerConsoleMessagesEnabled             : boolean;
  bSessionTimeoutInMinutes                  : boolean;
  bSMTPHost                                 : boolean;
  bSMTPPassword                             : boolean;
  bSMTPUsername                             : boolean;
  bSocketTimeOutInMSec                      : boolean;
  bTimeZoneOffSet                           : boolean;
  bValidateSessionRetryLimit                : boolean;
  bWebShareAlias                            : boolean;
  bDirectoryListing                         : boolean;
  bJASFooter                                : boolean;
  bPasswordKey                              : boolean;
  bAllowVirtualHostCreation                 : boolean;
  bCreateHybridJets                         : boolean;
  bSIPURL                                   : boolean;
end;
var rConfigOverridden: rtConfigOverridden;


// ============================================================================
procedure ResetConfigOverRidden;
// ============================================================================
begin
  with rConfigOverridden do begin
    bCacheMaxAgeInSeconds                     := false ;
    bConvert                                  := false ;
    bCreateSocketRetry                        := false ;
    bCreateSocketRetryDelayInMSec             := false ;
    bDebugMode                                := false ;
    bDebugServerConsoleMessagesEnabled        := false ;
    bDeleteLogFile                            := false ;
    bBlackListEnabled                         := false ;
    bWhiteListEnabled                         := false ;
    bErrorReportingMode                       := false ;
    bErrorReportingSecureMessage              := false ;
    bFFMPEG                                   := false ;
    bHOOK_ACTION_CREATESESSION_FAILURE        := false ;
    bHOOK_ACTION_CREATESESSION_SUCCESS        := false ;
    bHOOK_ACTION_REMOVESESSION_FAILURE        := false ;
    bHOOK_ACTION_REMOVESESSION_SUCCESS        := false ;
    bHOOK_ACTION_SESSIONTIMEOUT               := false ;
    bHOOK_ACTION_VALIDATESESSION_FAILURE      := false ;
    bHOOK_ACTION_VALIDATESESSION_SUCCESS      := false ;
    bJobQEnabled                              := false ;
    bJobQIntervalInMSec                       := false ;
    bLogLevel                                 := false ;
    bLogMessagesShowOnServerConsole           := false ;
    bMaximumRequestHeaderLength               := false ;
    bThreadPoolMaximumRunTimeInMSec           := false ;
    bMaxFileHandles                           := false ;
    bThreadPoolNoOfThreads                    := false ;
    bPerl                                     := false ;
    bPHP                                      := false ;
    bProtectJASRecords                        := false ;
    bClientToVICIServerIP                     := false ;
    bJASServertoVICIServerIP                  := false ;
    bLockRetriesBeforeFailure                 := false ;
    bLockretryDelayInMSec                     := false ;
    bLockTimeoutInMinutes                     := false ;
    bRetryDelayInMSec                         := false ;
    bRetryLimit                               := false ;
    bSafeDelete                               := false ;
    bServerConsoleMessagesEnabled             := false ;
    bSessionTimeoutInMinutes                  := false ;
    bSMTPHost                                 := false ;
    bSMTPPassword                             := false ;
    bSMTPUsername                             := false ;
    bSocketTimeOutInMSec                      := false ;
    bTimeZoneOffSet                           := false ;
    bValidateSessionRetryLimit                := false ;
    bWebShareAlias                            := false ;
    bDirectoryListing                         := false ;
    bWhiteListEnabled                         := false ;
    bBlackListEnabled                         := false ;
    bJASFooter                                := false ;
    bPasswordKey                              := false ;
    bAllowVirtualHostCreation                 := false ;
    bCreateHybridJets                         := false ;
    bSIPURL                                   := false ;
  end;// with
end;
// ============================================================================








// ============================================================================
type rtJVHostOverridden = record
// ============================================================================
  bVHost_WebRootDir               : boolean;
  bVHost_ServerName               : boolean;
  bVHost_ServerIdent              : boolean;
  bVHost_ServerDomain             : boolean;
  bVHost_ServerIP                 : boolean;
  bVHost_ServerPort               : boolean;
  bVHost_DefaultLanguage          : boolean;
  bVHost_DefaultColorTheme        : boolean;
  bVHost_MenuRenderMethod         : boolean;
  bVHost_DefaultArea              : boolean;
  bVHost_DefaultPage              : boolean;
  bVHost_DefaultSection           : boolean;
  bVHost_DefaultTop_JMenu_ID      : boolean;
  bVHost_DefaultLoggedInPage      : boolean;
  bVHost_DefaultLoggedOutPage     : boolean;
  bVHost_DataOnRight_b            : boolean;
  bVHost_CacheMaxAgeInSeconds     : boolean;
  bVHost_SystemEmailFromAddress   : boolean;
  bVHost_EnableSSL_b              : boolean;
  bVHost_SharesDefaultDomain_b    : boolean;
  bVHost_DefaultIconTheme         : boolean;
  bVHost_DirectoryListing_b       : boolean;
  bVHost_FileDir                  : boolean;
  bVHost_AccessLog                : boolean;
  bVHost_ErrorLog                 : boolean;
  bVHost_JDConnection_ID          : boolean;
  bVHost_Enabled_b                : boolean;
  bVHost_CacheDir                 : boolean;
  bVHost_TemplateDir              : boolean;
  bVHost_CreateHybridJets_b       : boolean;
  bVHost_SIPURL                   : Boolean;
end;
var rJVHostOverridden: rtJVHostOverridden;
var rJVHostOverride: rtJVHostLight;
// ============================================================================

// ============================================================================
procedure ResetJVHostOverridden;
// ============================================================================
begin
  with rJVHostOverridden do begin
    bVHost_WebRootDir               := false;
    bVHost_ServerName               := false;
    bVHost_ServerIdent              := false;
    bVHost_ServerDomain             := false;
    bVHost_ServerIP                 := false;
    bVHost_ServerPort               := false;
    bVHost_DefaultLanguage          := false;
    bVHost_DefaultColorTheme        := false;
    bVHost_MenuRenderMethod         := false;
    bVHost_DefaultArea              := false;
    bVHost_DefaultPage              := false;
    bVHost_DefaultSection           := false;
    bVHost_DefaultTop_JMenu_ID      := false;
    bVHost_DefaultLoggedInPage      := false;
    bVHost_DefaultLoggedOutPage     := false;
    bVHost_DataOnRight_b            := false;
    bVHost_CacheMaxAgeInSeconds     := false;
    bVHost_SystemEmailFromAddress   := false;
    bVHost_EnableSSL_b              := false;
    bVHost_SharesDefaultDomain_b    := false;
    bVHost_DefaultIconTheme         := false;
    bVHost_DirectoryListing_b       := false;
    bVHost_FileDir                  := false;
    bVHost_AccessLog                := false;
    bVHost_ErrorLog                 := false;
    bVHost_JDConnection_ID          := false;
    bVHost_Enabled_b                := false;
    bVHost_CacheDir                 := false;
    bVHost_TemplateDir              := false;
    bVHost_CreateHybridJets_b       := false;
    bVHost_SIPURL                   := false;
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
  i,t: longint;
  iXCon: longint;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bCreatePHPJASTableDef';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  rs:=JADO_RECORDSET.create;
  rs2:=JADO_RECORDSET.create;
  bOk:=true;
  saFilename:=grJASConfig.saSysDir+csDOSSLASH+'php'+csDOSSLASH+'config.jastabledef.php';

  if bOk then
  begin
    bOk:= bTSOpenTextFile( safilename, u2IOResult, f, false, false);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_Error, 201006262033, 'bCreatePHPJASTableDef trouble with bTSOpenTextFile. IOResult:'+
        inttostr(u2IOResult)+' '+saIOResult(u2IOResult)+' Filename:'+saFilename,SOURCEFILE);
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

    for i:=0 to length(garJVHostLight)-1 do
    begin
      //ASPrintln('PHP - Top of Main Loop: ' + inttostr(i));
      iXCon:=-1;
      for t:=0 to length(gajCon)-1 do
      begin
        //ASPrintln('PHP - Top of Inner Loop: '+inttostr(t)+' '+gaJCon[t].ID+'='+inttostr(garJVHostLight[i].u8JDConnection_ID));
        if gaJCon[t].ID=inttostr(garJVHostLight[i].u8JDConnection_ID) then
        begin
          //ASPrintln('Got Correct Connection for VHost! :)');
          iXCon:=t; break;
        end;
      end;
      //ASPrintln('PHP - Done Inner Loop');

      bOk:=iXCon<>-1;
      if not bOk then
      begin
        bLogEntryMadeDuringStartUp:=true;
        JLog(cnLog_ERROR, 201211241136, 'Unable to locate a Database connection for a VHOST: '+garJVHostLight[i].saServerName,SOURCEFILE);
        break;
      end;

      if bOk then
      begin
        saQry:='select JDCon_JDConnection_UID, JDCon_Name from jdconnection '+
          'where ((JDCon_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(JDCon_Deleted_b IS NULL)) and '+
          '(JDCon_Enabled_b='+gaJCon[0].saDBMSBoolScrub(true)+') AND '+
          '(JDCon_JDConnection_UID='+gaJCon[0].saDBMSUintScrub(garJVHostLight[iXCon].u8JDConnection_ID)+') '+
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
              gaJCon[iXCon].saDBMSUIntScrub(rs.fields.Get_saValue('JDCon_JDConnection_UID'))+') AND '+
              '((JTabl_Deleted_b<>'+gaJCon[iXCon].saDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) '+
              'ORDER BY JTabl_Name';
            //ASPrintln('TBL: '+saQry);
            bOk:=rs2.open(saQry,gaJCon[iXCon],201503161668);
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
        inttostr(u2IOResult)+' '+saIOResult(u2IOResult)+' Filename:'+saFilename,SOURCEFILE);
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
  sa: AnsiString;
  ftext: text;
  saBeforeEqual: AnsiString;

  sDIR: String;
  sName: String;
  sExt: String;
  
  //saValue: AnsiString;
  //satemp: AnsiString;
  
  TK: JFC_TOKENIZER;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bLoadConfigurationFile';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //ASDebugPrintln('BEGIN ------------ bLoadConfig');

  Result:= False;
  TK:=JFC_TOKENIZER.Create;
  
  FSplit(argv[0],sDir,sName,sExt);
  grJASConfig.saConfigDir:=sDir+'..'+csDOSSLASH+'config'+csDOSSLASH;
  grJASConfig.saConfigDir:=saSolveRelativePath(grJASConfig.saConfigDir);
  //ASPrintln(' fsplit got us saDir:'+sDir+' saName:'+sName+' saExt:'+sExt);
  grJASConfig.saConfigFile:=grJASConfig.saConfigDir+grJASConfig.saConfigFile;
  //ASPrintln(' config file sought:'+grJASConfig.saConfigFile);
  
  If not FileExists(grJASConfig.saConfigFile) Then
  begin
    grJASConfig.saConfigFile:='../' + grJASConfig.saConfigFile;
  end;

  If FileExists(grJASConfig.saConfigFile) Then
  Begin
    //ASPrintln('');
    //ASPrintln('Configuration File: '+grJASConfig.saConfigFile);

    //CSECTION_FILEREADMODEFLAG.Enter;
    FileMode:=READ_ONLY;
    assign(ftext, grJASConfig.saConfigFile);
    reset(ftext);
    //CSECTION_FILEREADMODEFLAG.Leave;
    // BEGIN ---- Load Config Loop
    While not Eof(ftext) Do
    Begin
      readln(ftext, sa);
      //riteln('READ:',sa);
      sa:= Trim(sa);
      If (Length(sa) <> 0) and (LeftStr(sa, 1) <> ';') and (LeftStr(sa, 1) <> '//') Then
      Begin
        // MsgBox sGetStringBeforeEqualSign(s)
        saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
        //riteln('KEY:',saBeforeEqual);
        //riteln('VALUE:',saGetStringAfterEqualSign(sa));

        // ----------------------------------------------------------------------
        // BEGIN - REQUIRED OPTIONS ONLY AVAILABLE FROM jas.cfg
        // ----------------------------------------------------------------------
        If saBeforeEqual='MAINSYSTEMONLY' Then bMainSystemOnly:=bVal(saGetStringAfterEqualSign(sa)) else
        If saBeforeEqual='SYSDIR' Then
        Begin
          grJASConfig.saSysDir:=saGetStringAfterEqualSign(sa);
          if saRightStr(grJASConfig.saSysDir,1)<>csDOSSLASH then grJASConfig.saSysDir+=csDOSSLASH;
          // update other contingent direcory paths
          grJASConfig.saBinDir:=         grJASConfig.saSysDir+'bin'+csDOSSLASH;
          grJASConfig.saCacheDir:=       grJASConfig.saSysDir+'cache'+csDOSSLASH;
          grJASConfig.saConfigDir:=      grJASConfig.saSysDir+'config'+csDOSSLASH;// Jegas Configuration Directory (DNS, jas  .cfg etc.)
          grJASConfig.saDatabaseDir:=    grJASConfig.saSysDir+'database'+csDOSSLASH;
          grJASConfig.saLogDir:=         grJASConfig.saSysDir+'log'+csDOSSLASH;// Jegas default log directory
          grJASConfig.saPHPDir:=         grJASConfig.saSysDir+'php'+csDOSSLASH;
          grJASConfig.saSetupDir:=       grJASConfig.saSysDir+'setup'+csDOSSLASH;
          grJASConfig.saSoftwareDir:=    grJASConfig.saSysDir+'software'+csDOSSLASH;
          grJASConfig.saSrcDir:=         grJASConfig.saSysDir+'src'+csDOSSLASH;
          //grJASConfig.saTemplatesDir:=   grJASConfig.saSysDir+'templates'+csDOSSLASH;
          grJASConfig.saFileDir:=        grJASConfig.saSysDir+'file'+csDOSSLASH;
          grJASConfig.saWebshareDir:=    grJASConfig.saSysDir+'webshare'+csDOSSLASH;
          grJASConfig.saThemeDir:=       grJASConfig.saWebshareDir+'themes'+csDOSSLASH;
        End else
        If saBeforeEqual='SERVERNAME' Then grJASConfig.saServerName:=saGetStringAfterEqualSign(sa) else
        If saBeforeEqual='SERVERIDENT' Then grJASConfig.saServerIdent:=trim(upcase(saGetStringAfterEqualSign(sa))) else
        if saBeforeEqual='SERVERURL' then
        begin
          grJASConfig.saServerURL:=saGetStringAfterEqualSign(sa);
        end else
        If saBeforeEqual='SERVERIP' Then grJASConfig.saServerIP:=saGetStringAfterEqualSign(sa) else
        If saBeforeEqual='SERVERPORT' Then grJASConfig.u2ServerPort:=iVal(saGetStringAfterEqualSign(sa)) else
        If saBeforeEqual='DATABASECONFIGFILE' Then grJASconfig.saDBCFilename:=saGetStringAfterEqualSign(sa) else
        // ----------------------------------------------------------------------
        // END - REQUIRED OPTIONS ONLY AVAILABLE FROM jas.cfg
        // ----------------------------------------------------------------------





        // ----------------------------------------------------------------------
        // BEGIN - OVERRIDE OPTIONS - OPTIONS HERE OVERRIDE DATABASE OPTIONS
        // ----------------------------------------------------------------------
        If saBeforeEqual='CACHEMAXAGEINSECONDS' then
        begin
          rConfigOverridden.bCacheMaxAgeInSeconds:=true;
          grJASConfig.sCacheMaxAgeInSeconds:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='CREATESOCKETRETRY' then
        begin
          rConfigOverridden.bCreateSocketRetry:=true;
          grJASConfig.iCreateSocketRetry:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='CREATESOCKETRETRYDELAYINMSEC' then
        begin
          rConfigOverridden.bCreateSocketRetryDelayInMSec:=true;
          grJASConfig.iCreateSocketRetryDelayInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='DEBUGMODE' then
        begin
          rConfigOverridden.bDebugMode:=true;
          sa:=UpCase(saGetStringAfterEqualSign(sa));
          if sa='VERBOSE' then
          begin
            grJASConfig.iDebugMode:=cnSYS_INFO_MODE_VERBOSE;
          end
          else

          if sa='VERBOSELOCAL' then
          begin
            grJASConfig.iDebugMode:=cnSYS_INFO_MODE_VERBOSELOCAL;
          end
          else
          begin
            grJASConfig.iDebugMode:=cnSYS_INFO_MODE_SECURE;
          end;
        end else

        If saBeforeEqual='DEBUGSERVERCONSOLEMESSAGESENABLED' then
        begin
          rConfigOverridden.bDebugServerConsoleMessagesEnabled:=true;
          grJASConfig.bDebugServerConsoleMessagesEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='DELETELOGFILE' then
        begin
          rConfigOverridden.bDeleteLogFile:=true;
          grJASConfig.bDeleteLogFile:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='BLACKLISTENABLED' then
        begin
          rConfigOverridden.bBlackListEnabled:=true;
          grJASConfig.bBlackListEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='WHITELISTENABLED' then
        begin
          rConfigOverridden.bWhiteListEnabled:=true;
          grJASConfig.bWhiteListEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='ERRORREPORTINGMODE' then
        begin
          rConfigOverridden.bErrorReportingMode:=true;
          sa:=upcase(saGetStringAfterEqualSign(sa));
          if sa='VERBOSE' then
          begin
            //ASPrintln('Error Rep Mode: Verbose');
            grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
          end
          else

          if sa='VERBOSELOCAL' then
          begin
            //ASPrintln('Error Rep Mode: Verbose Local');
            grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_VERBOSELOCAL;
          end
          else
          begin
            //ASPrintln('Error Rep Mode: Secure');
            grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
          end;
        end else

        If saBeforeEqual='ERRORREPORTINGSECUREMESSAGE' then
        begin
          rConfigOverridden.bErrorReportingSecureMessage:=true;
          grJASConfig.saErrorReportingSecureMessage:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_CREATESESSION_FAILURE' then
        begin
          rConfigOverridden.bHOOK_ACTION_CREATESESSION_FAILURE:=true;
          grJASConfig.saHOOK_ACTION_CREATESESSION_FAILURE:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_CREATESESSION_SUCCESS' then
        begin
          rConfigOverridden.bHOOK_ACTION_CREATESESSION_SUCCESS:=true;
          grJASConfig.saHOOK_ACTION_CREATESESSION_SUCCESS:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_REMOVESESSION_FAILURE' then
        begin
          rConfigOverridden.bHOOK_ACTION_REMOVESESSION_FAILURE:=true;
          grJASConfig.saHOOK_ACTION_REMOVESESSION_FAILURE:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_REMOVESESSION_SUCCESS' then
        begin
          rConfigOverridden.bHOOK_ACTION_REMOVESESSION_SUCCESS:=true;
          grJASConfig.saHOOK_ACTION_REMOVESESSION_SUCCESS:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_SESSIONTIMEOUT' then
        begin
          rConfigOverridden.bHOOK_ACTION_SESSIONTIMEOUT:=true;
          grJASConfig.saHOOK_ACTION_SESSIONTIMEOUT:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_VALIDATESESSION_FAILURE' then
        begin
          rConfigOverridden.bHOOK_ACTION_VALIDATESESSION_FAILURE:=true;
          grJASConfig.saHOOK_ACTION_VALIDATESESSION_FAILURE:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='HOOK_ACTION_VALIDATESESSION_SUCCESS' then
        begin
          rConfigOverridden.bHOOK_ACTION_VALIDATESESSION_SUCCESS:=true;
          grJASConfig.saHOOK_ACTION_VALIDATESESSION_SUCCESS:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='JOBQENABLED' then
        begin
          rConfigOverridden.bJobQEnabled:=true;
          grJASConfig.bJobQEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='JOBQINTERVALINMSEC' then
        begin
          rConfigOverridden.bJobQIntervalInMSec:=true;
          grJASConfig.iJobQIntervalInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='LOGLEVEL' then
        begin
          rConfigOverridden.bLogLevel:=true;
          grJASConfig.iLogLevel:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='LOGMESSAGESSHOWONSERVERCONSOLE' then
        begin
          rConfigOverridden.bLogMessagesShowOnServerConsole:=true;
          grJASConfig.bLogMessagesShowOnServerConsole:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='MAXIMUMREQUESTHEADERLENGTH' then
        begin
          rConfigOverridden.bMaximumRequestHeaderLength:=true;
          grJASConfig.i8MaximumRequestHeaderLength:=u8Val(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='THREADPOOLMAXIMUMRUNTIMEINMSEC' then
        begin
          rConfigOverridden.bThreadPoolMaximumRunTimeInMSec:=true;
          grJASConfig.iThreadPoolMaximumRunTimeInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='MAXFILEHANDLES' then
        begin
          rConfigOverridden.bMaxFileHandles:=true;
          grJASConfig.iMaxFileHandles:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='THREADPOOLNOOFTHREADS' then
        begin
          rConfigOverridden.bThreadPoolNoOfThreads:=true;
          grJASConfig.iThreadPoolNoOfThreads:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='PERL' then
        begin
          rConfigOverridden.bPerl:=true;
          grJASConfig.saPerl:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='PHP' then
        begin
          rConfigOverridden.bPHP:=true;
          grJASConfig.saPHP:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='PROTECTJASRECORDS' then
        begin
          rConfigOverridden.bProtectJASRecords:=true;
          grJASConfig.bProtectJASRecords:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='CLIENTTOVICISERVERIP' then
        begin
          rConfigOverridden.bClientToVICIServerIP:=true;
          grJASConfig.saClientToVICIServerIP:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='JASSERVERTOVICISERVERIP' then
        begin
          rConfigOverridden.bJASServertoVICIServerIP:=true;
          grJASConfig.saJASServertoVICIServerIP:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='LOCKRETRIESBEFOREFAILURE' then
        begin
          rConfigOverridden.bLOCKRETRIESBEFOREFAILURE:=true;
          grJASConfig.iLockRetriesBeforeFailure:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='LOCKRETRYDELAYINMSEC' then
        begin
          rConfigOverridden.bLOCKRETRYDELAYINMSEC:=true;
          grJASConfig.iLockRetryDelayInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='LOCKTIMEOUTINMINUTES' then
        begin
          rConfigOverridden.bLOCKTIMEOUTINMINUTES:=true;
          grJASConfig.iLockTimeOutInMinutes:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='RETRYDELAYINMSEC' then
        begin
          rConfigOverridden.bRetryDelayInMSec:=true;
          grJASConfig.iLockRetryDelayInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='RETRYLIMIT' then
        begin
          rConfigOverridden.bRetryLimit:=true;
          grJASConfig.iRetryLimit:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='SAFEDELETE' then
        begin
          rConfigOverridden.bSafeDelete:=true;
          grJASConfig.bSafeDelete:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='SERVERCONSOLEMESSAGESENABLED' then
        begin
          rConfigOverridden.bServerConsoleMessagesEnabled:=true;
          grJASConfig.bServerConsoleMessagesEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='SESSIONTIMEOUTINMINUTES' then
        begin
          rConfigOverridden.bSESSIONTIMEOUTINMINUTES:=true;
          grJASConfig.iSessionTimeOutInMinutes:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='SMTPHOST' then
        begin
          rConfigOverridden.bSMTPHost:=true;
          grJASConfig.sSMTPHost:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='SMTPPASSWORD' then
        begin
          rConfigOverridden.bSMTPPassword:=true;
          grJASConfig.sSMTPPassword:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='SMTPUSERNAME' then
        begin
          rConfigOverridden.bSMTPUsername:=true;
          grJASConfig.sSMTPUserName:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='SOCKETTIMEOUTINMSEC' then
        begin
          rConfigOverridden.bSocketTimeOutInMSec:=true;
          grJASConfig.iSocketTimeOutInMSec:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='TIMEZONEOFFSET' then
        begin
          rConfigOverridden.bTimeZoneOffSet:=true;
          grJASConfig.iTimeZoneOffSet:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='VALIDATESESSIONRETRYLIMIT' then
        begin
          rConfigOverridden.bVALIDATESESSIONRETRYLIMIT:=true;
          grJASConfig.iValidateSessionRetryLimit:=iVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='WEBSHAREALIAS' then
        begin
          rConfigOverridden.bWebShareAlias:=true;
          grJASConfig.saWebShareAlias:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='DIRECTORYLISTING' then
        begin
          rConfigOverridden.bDirectoryListing:=true;
          grJASConfig.bDirectoryListing:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='WHITELISTENABLED' then
        begin
          rConfigOverridden.bWhiteListEnabled:=true;
          grJASConfig.bWhiteListEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='BLACKLISTENABLED' then
        begin
          rConfigOverridden.bBlackListEnabled:=true;
          grJASConfig.bBlackListEnabled:=bVal(saGetStringAfterEqualSign(sa));
        end else

        If saBeforeEqual='JASFOOTER' then
        begin
          rConfigOverridden.bJASFooter:=true;
          grJASConfig.saJASFooter:=saGetStringAfterEqualSign(sa);
        end else

        If saBeforeEqual='PASSWORDKEY' then
        begin
          rConfigOverridden.bPasswordKey:=true;
          grJASConfig.u1PasswordKey:=u1Val(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='ALLOWVIRTUALHOSTCREATION' then
        begin
          rConfigOverridden.bAllowVirtualHostCreation:=true;
          grJASConfig.bAllowVirtualHostCreation:=bVal(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='CREATEHYBRIDJETS' then
        begin
          rConfigOverridden.bCreateHybridJets:=true;
          grJASConfig.bCreateHybridJets:=bVal(saGetStringAfterEqualSign(sa));
        end else

        // ----------------------------------------------------------------------
        // END - OVERRIDE OPTIONS - OPTIONS HERE OVERRIDE DATABASE OPTIONS
        // ----------------------------------------------------------------------






        // ----------------------------------------------------------------------
        // BEGIN - Virtual Host Overrides
        // ----------------------------------------------------------------------
        if saBeforeEqual='VHOST_WEBROOTDIR' then
        begin
          rJVHostOverridden.bVHost_WebRootDir:=true;
          rJVHostOverride.saWebRootDir:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SERVERNAME' then
        begin
          rJVHostOverridden.bVHost_ServerName:=true;
          rJVHostOverride.saServerName:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SERVERIDENT' then
        begin
          rJVHostOverridden.bVHost_ServerIdent:=true;
          rJVHostOverride.saServerIdent:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SERVERDOMAIN' then
        begin
          rJVHostOverridden.bVHost_ServerDomain:=true;
          rJVHostOverride.saServerDomain:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SERVERIP' then
        begin
          rJVHostOverridden.bVHost_ServerIP:=true;
          rJVHostOverride.saServerIP:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SERVERPORT' then
        begin
          rJVHostOverridden.bVHost_ServerPort:=true;
          rJVHostOverride.u2ServerPort:=u2Val(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_DEFAULTLANGUAGE' then
        begin
          rJVHostOverridden.bVHost_DefaultLanguage:=true;
          rJVHostOverride.saDefaultLanguage:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DEFAULTCOLORTHEME' then
        begin
          rJVHostOverridden.bVHost_DefaultColorTheme:=true;
          rJVHostOverride.saDefaultColorTheme:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_MENURENDERMETHOD' then
        begin
          rJVHostOverridden.bVHost_MenuRenderMethod:=true;
          rJVHostOverride.u1MenuRenderMethod:=u1Val(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_DEFAULTAREA' then
        begin
          rJVHostOverridden.bVHost_DefaultArea:=true;
          rJVHostOverride.saDefaultArea:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DEFAULTPAGE' then
        begin
          rJVHostOverridden.bVHost_DefaultPage:=true;
          rJVHostOverride.saDefaultPage:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DEFAULTSECTION' then
        begin
          rJVHostOverridden.bVHost_DefaultSection:=true;
          rJVHostOverride.saDefaultSection:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DEFAULTTOP_JMENU_ID' then
        begin
          rJVHostOverridden.bVHost_DefaultTop_JMenu_ID:=true;
          rJVHostOverride.u8DefaultTop_JMenu_ID:=u8Val(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_DEFAULTLOGGEDINPAGE' then
        begin
          rJVHostOverridden.bVHost_DefaultLoggedInPage:=true;
          rJVHostOverride.saDefaultLoggedInPage:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DEFAULTLOGGEDOUTPAGE' then
        begin
          rJVHostOverridden.bVHost_DefaultLoggedOutPage:=true;
          rJVHostOverride.saDefaultLoggedOutPage:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DATAONRIGHT_B' then
        begin
          rJVHostOverridden.bVHost_DataOnRight_b:=true;
          rJVHostOverride.bDataOnRight:=bVal(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_CACHEMAXAGEINSECONDS' then
        begin
          rJVHostOverridden.bVHost_CacheMaxAgeInSeconds:=true;
          rJVHostOverride.sCacheMaxAgeInSeconds:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_SYSTEMEMAILFROMADDRESS' then
        begin
          rJVHostOverridden.bVHost_SystemEmailFromAddress:=true;
          rJVHostOverride.sSystemEmailFromAddress:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_ENABLESSL_B' then
        begin
          rJVHostOverridden.bVHost_EnableSSL_b:=true;
          rJVHostOverride.bEnableSSL:=bVal(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_SHARESDEFAULTDOMAIN_B' then
        begin
          rJVHostOverridden.bVHost_SharesDefaultDomain_b:=true;
          rJVHostOverride.bSharesDefaultDomain:=bVal(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_DEFAULTICONTHEME' then
        begin
          rJVHostOverridden.bVHost_DefaultIconTheme:=true;
          rJVHostOverride.saDefaultIconTheme:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_DIRECTORYLISTING_B' then
        begin
          rJVHostOverridden.bVHost_DirectoryListing_b:=true;
          rJVHostOverride.bDirectoryListing:=bVal(saGetStringAfterEqualSign(sa));
        end else

        if saBeforeEqual='VHOST_FILEDIR' then
        begin
          rJVHostOverridden.bVHost_FileDir:=true;
          rJVHostOverride.saFileDir:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_ACCESSLOG' then
        begin
          rJVHostOverridden.bVHost_AccessLog:=true;
          rJVHostOverride.saAccessLog:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_ERRORLOG' then
        begin
          rJVHostOverridden.bVHost_ErrorLog:=true;
          rJVHostOverride.saErrorLog:=saGetStringAfterEqualSign(sa);
        end else

        if saBeforeEqual='VHOST_JDCONNECTION_ID' then
        begin
          rJVHostOverridden.bVHost_JDConnection_ID:=true;
          rJVHostOverride.u8JDConnection_ID:=u8Val(saGetStringAfterEqualSign(sa));
        end else

        //if saBeforeEqual='VHOST_ENABLED_B' then
        //begin
        //  rJVHostOverridden.bVHost_Enabled_b:=true;
        //  rJVHostOverride.bEnabled:=bVal(saGetStringAfterEqualSign(sa));
        //end;

        if saBeforeEqual='VHOST_CACHEDIR' then
        begin
          rJVHostOverridden.bVHost_CacheDir:=true;
          rJVHostOverride.saCacheDir:=saGetStringAfterEqualSign(sa);
        end else
        
        if saBeforeEqual='VHOST_TEMPLATEDIR' then 
        begin
          rJVHostOverridden.bVHost_TemplateDir:=true;
          rJVHostOverride.saTemplateDir:=saGetStringAfterEqualSign(sa);
        end;

        if saBeforeEqual='VHOST_SIPURL' then
        begin
          rJVHostOverridden.bVHost_SIPURL:=true;
          rJVHostOverride.saSIPURL:=saGetStringAfterEqualSign(sa);
        end;

      End;// if
    End;// while loop
    Close(ftext);
    // END   ---- Load Config Loop

    grJASconfig.saDBCFilename:=grJASConfig.saConfigDir+grJASconfig.saDBCFilename;
    Result:= True;
  End 
  Else
  Begin
    // do nothing - this function should return false then!
    grJASConfig.saConfigFile:=saRightStr(grJASConfig.saConfigFile,length(grJASConfig.saConfigFile)-3);
    JASPrintln('Config File Missing:'+grJASConfig.saConfigFile);
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
  i: longint;
  saQry: ansistring;
  saDBCFilename: ansistring;
  bUnableToOpen: boolean;
  saMsg:ansistring;
  u8DataIn: UInt64;
  saDataIn: ansistring;
  u8VHostID_DEFAULT: uint64;
  i4DefaultHostIndex: longint;
  bGotOne: boolean;
  i4DefaultHostCount: longint;
  bDone: boolean;
  iDBX: longint;// used during menu loading and PER JET preference Loading
  iHost: longint;
  sa: ansistring;
  u2IOResult: word;
  u8: UInt64;
  
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bOpenDatabaseConnections';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.create;
  i4DefaultHostIndex:=-1;
  u8VHostID_DEFAULT:=0;
  i4DefaultHostCount:=0;
  If bOk Then
  Begin
    setlength(gaJCon,1);
    gaJCon[0]:=JADO_CONNECTION.Create;
    // Force Connection to behave as a JAS connection which means
    // when it connects it will initially load the JADO_CONNECTION.JASTABLEMATRIX
    // with table names, uids and jdconnection values for each table in jtable
    gaJCon[0].bJas:=true;
    gaJCon[0].JDCon_JSecPerm_ID:=inttostr(cnJSecPerm_JASDBCon);// 2012101522403599143 = DB Connection JAS
    bOk:=gaJCon[0].bLoad(grJASConfig.saDBCFilename);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      JLog(cnLog_FATAL, 200609161542, '****Unable to LOAD MAIN Database Connection file:'+grJASConfig.saDBCFilename, SOURCEFILE);
    end;
  end;

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

  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  // BEGIN ------------------------------------------ USER PREF SETTINGS (MAIN JET)
  if bOk then
  begin
    saQry:='select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from '+
           'juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and '+
           'UsrPL_User_ID=1 and ((UserP_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(UserP_Deleted_b IS NULL))';
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
    Writeln('open db con failing');
  end;

  if bOk and (not rs.EOL) then
  begin
    repeat
      u8DataIn:=u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID'));
      saDataIn:=rs.fields.Get_saValue('UsrPL_Value');
      //ASPrintln(rs.fields.Get_saValue('UserP_Name')+' - '+inttostr(u8DataIn) +' - '+saDataIn);

      //in 2.6.x fpc, comparing constant 64bit to variable was failing
      // the fix is assign to in64 then compare the variables.
      u8:=2012100614040179599;
      if (u8DataIn=u8) and (not rConfigOverridden.bCacheMaxAgeInSeconds) then // JAS Cache Max Age In Seconds  admin   3600
      begin
        grJASCOnfig.sCacheMaxAgeInSeconds:=inttostr(u8val(saDataIn));
        //ASPrintln('sCacheMaxAgeInSeconds');
      end;

      u8:=2012100614045994520;
      if (u8DataIn=u8) and (not rConfigOverridden.bCreateSocketRetry) then // JAS Create Socket Retry   admin   60
      begin
        grJASConfig.iCreateSocketRetry:=iVal(saDataIn);
        //JASPrintln('iCreateSocketRetry');
      end;

      u8:=2012100614052025145;
      if (u8DataIn=u8) and (not rConfigOverridden.bCreateSocketRetryDelayInMSec) then // JAS Create Socket Retry Delay In MSec   admin   1000
      begin
        grJASConfig.iCreateSocketRetryDelayInMSec:=iVal(saDataIn);
        //ASPrintln('iCreateSocketRetryDelayInMSec');
      end;

      u8:=2012100614053914241;
      if (u8DataIn=u8) and (not rConfigOverridden.bDebugMode) then // JAS Debug Mode  admin   secure
      begin
        saDataIn:=UpperCase(saDataIn);
        if(saDataIn = 'VERBOSELOCAL') then
        begin
          grJASConfig.iDebugMode:=cnSYS_INFO_MODE_VERBOSELOCAL
        end
        else
        begin
          if(saDataIn = 'VERBOSE') then
          begin
            grJASConfig.iDebugMode:=cnSYS_INFO_MODE_VERBOSE
          end
          else
          begin
            grJASConfig.iDebugMode:=cnSYS_INFO_MODE_SECURE;
          end;
        end;
        //ASPrintln('iDebugMode');
      end;

      u8:=2012100614061800671;
      if (u8DataIn=u8) and (not rConfigOverridden.bDebugServerConsoleMessagesEnabled) then // JAS Debug Server Console Messages Enabled   admin   Yes
      begin
        grJASConfig.bDebugServerConsoleMessagesEnabled:=bVal(saDataIn);
        //ASPrintln('bDebugServerConsoleMessagesEnabled');
      end;

      u8:=2012100614072805008;
      if (u8DataIn=u8) and (not rConfigOverridden.bDeleteLogFile) then // JAS Delete Log  admin   Yes
      begin
        grJASConfig.bDeleteLogFile:=bVal(saDataIn);
        //ASPrintln('bDeleteLogFile');
      end;

      u8:=2012100614074544424;
      if (u8DataIn=u8) and (not rConfigOverridden.bBlackListEnabled) then // JAS Enable IP Blacklist   admin   Yes
      begin
        grJASConfig.bBlackListEnabled:=bVal(saDataIn);
        //ASPrintln('bBlackListEnabled');
      end;

      u8:=2012100614080255621;
      if (u8DataIn=u8) and (not rConfigOverridden.bWhiteListEnabled) then // JAS Enable IP Whitelist   admin   No
      begin
        grJASConfig.bWhiteListEnabled:=bVal(saDataIn);
        //ASPrintln('bWhiteListEnabled');
      end;

      u8:=2012100614090714788;
      if (u8DataIn=u8) and (not rConfigOverridden.bErrorReportingMode) then // JAS Error Reporting Mode  admin   secure
      begin
        saDataIn:=upcase(trim(saDataIn));
        if(saDataIn = 'VERBOSE') then
        begin
          grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
        end else
        if(saDataIn = 'VERBOSELOCAL') then
        begin
          grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_VERBOSELOCAL
        end
        else
        begin
          grJASConfig.iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
        end;
        //ASPrintln('iErrorReportingMode');
      end;

      u8:=2012100614101453914;
      if (u8DataIn=u8) and (not rConfigOverridden.bErrorReportingSecureMessage) then // JAS Error Reporting Secure Mode Message   NULL  Please note the error number shown in this message and record it. Your system administrator can use that number to help remedy system problems.
      begin
        grJASConfig.saErrorReportingSecureMessage:=saDataIn;
        //ASPrintln('saErrorReportingSecureMessage');
      end else

      u8:=2012100614124173033;
      if (u8DataIn=u8) and (not rConfigOverridden.bHOOK_ACTION_CREATESESSION_FAILURE) then // JAS HOOK_ACTION_CREATESESSION_FAILURE   admin   0
      begin
        grJASConfig.saHOOK_ACTION_CREATESESSION_FAILURE :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_CREATESESSION_FAILURE');
      end;

      u8:=2012100614125179884;
      if (u8DataIn=u8) and (not rConfigOverridden.bHOOK_ACTION_CREATESESSION_SUCCESS) then // JAS HOOK_ACTION_CREATESESSION_SUCCESS   admin   0
      begin
        grJASConfig.saHOOK_ACTION_CREATESESSION_SUCCESS :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_CREATESESSION_SUCCESS');
      end;

      u8:=2012100614130177790;
      if (u8DataIn=u8)  and (not rConfigOverridden.bHOOK_ACTION_REMOVESESSION_FAILURE) then // JAS HOOK_ACTION_REMOVESESSION_FAILURE   admin   0
      begin
        grJASConfig.saHOOK_ACTION_REMOVESESSION_FAILURE :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_REMOVESESSION_FAILURE');
      end;

      u8:=2012100614131550006;
      if (u8DataIn=u8)  and (not rConfigOverridden.bHOOK_ACTION_REMOVESESSION_SUCCESS) then // JAS HOOK_ACTION_REMOVESESSION_SUCCESS   admin   0
      begin
        grJASConfig.saHOOK_ACTION_REMOVESESSION_SUCCESS :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_REMOVESESSION_SUCCESS');
      end;

      u8:=2012100614132661440;
      if (u8DataIn=u8) and (not rConfigOverridden.bHOOK_ACTION_SESSIONTIMEOUT) then // JAS HOOK_ACTION_SESSIONTIMEOUT  admin   0
      begin
        grJASConfig.saHOOK_ACTION_SESSIONTIMEOUT :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_SESSIONTIMEOUT');
      end;

      u8:=2012100614134121397;
      if (u8DataIn=u8) and (not rConfigOverridden.bHOOK_ACTION_VALIDATESESSION_FAILURE) then // JAS HOOK_ACTION_VALIDATESESSION_FAILURE   admin   0
      begin
        grJASConfig.saHOOK_ACTION_VALIDATESESSION_FAILURE :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_VALIDATESESSION_FAILURE');
      end;

      u8:=2012100614135620684;
      if (u8DataIn=u8) and (not rConfigOverridden.bHOOK_ACTION_VALIDATESESSION_SUCCESS) then // JAS HOOK_ACTION_VALIDATESESSION_SUCCESS   admin   0
      begin
        grJASConfig.saHOOK_ACTION_VALIDATESESSION_SUCCESS :=trim(saDataIn);
        //ASPrintln('saHOOK_ACTION_VALIDATESESSION_SUCCESS');
      end;

      u8:=2012100614150622123;
      if (u8DataIn=u8) and (not rConfigOverridden.bJobQEnabled) then // JAS Job Queue Enabled   admin   Yes
      begin
        grJASConfig.bJobQEnabled:=bVal(saDataIn);
        //ASPrintln('bJobQEnabled');
      end;

      u8:=2012100614165072216;
      if (u8DataIn=u8) and (not rConfigOverridden.bJobQIntervalInMSec) then // JAS Job Queue Interval In Milli Seconds   admin   10000
      begin
        grJASConfig.iJobQIntervalInMSec:=iVal(saDataIn);
        //ASPrintln('iJobQIntervalInMSec');
      end;

      u8:=2012100614171518219;
      if (u8DataIn=u8) and (not rConfigOverridden.bLogLevel) then // JAS Log Level   admin   0
      begin
        grJASConfig.iLogLevel:=iVal(saDataIn);
        //ASPrintln('iLogLevel');
      end;

      u8:=2012100614204192426;
      if (u8DataIn=u8) and (not rConfigOverridden.bLogMessagesShowOnServerConsole) then // JAS Log Messages Show On Server Console   admin   No
      begin
        grJASConfig.bLogMessagesShowOnServerConsole:=bVal(saDataIn);
        //ASPrintln('bLogMessagesShowOnServerConsole');
      end;

      u8:=2012100614291882510;
      if (u8DataIn=u8) and (not rConfigOverridden.bMaximumRequestHeaderLength) then // JAS Max Request Header Length   admin   1500000000
      begin
        grJASConfig.i8MaximumRequestHeaderLength:=i8Val(saDataIn);
        //ASPrintln('i8MaximumRequestHeaderLength');
      end;

      u8:=2012100614484499907;
      if (u8DataIn=u8) and (not rConfigOverridden.bThreadPoolMaximumRunTimeInMSec) then // JAS Max Thread Run Time MSec  admin   60000
      begin
        grJASConfig.iThreadPoolMaximumRunTimeInMSec:=iVal(saDataIn);
        //ASPrintln('iThreadPoolMaximumRunTimeInMSec');
      end;

      u8:=2012100614490660469;
      if (u8DataIn=u8) and (not rConfigOverridden.bMaxFileHandles) then // JAS Maximum File Handles  NULL  200
      begin
        grJASConfig.iMaxFileHandles:=iVal(saDataIn);
        //ASPrintln('iMaxFileHandles');
      end;

      u8:=2012100614492220150;
      if (u8DataIn=u8) and (not rConfigOverridden.bThreadPoolNoOfThreads) then // JAS Number of Threads   admin   40
      begin
        grJASConfig.iThreadPoolNoOfThreads:=iVal(saDataIn);
        //ASPrintln('iThreadPoolNoOfThreads');
      end;

      u8:=2012100614500246737;
      if (u8DataIn=u8) and (not rConfigOverridden.bPerl) then // JAS Perl  admin   /usr/bin/perl
      begin
        grJASConfig.saPerl:=trim(saDataIn);
        //ASPrintln('saPerl');
      end;

      u8:=2012100614502815902;
      if (u8DataIn=u8) and (not rConfigOverridden.bPHP) then // JAS PHP   admin   /usr/bin/php-cgi
      begin
        grJASConfig.saPHP:=trim(saDataIn);
        //ASPrintln('saPHP');
      end;

      u8:=2012100614504757616;
      if (u8DataIn=u8) and (not rConfigOverridden.bProtectJASRecords) then // JAS Protect JAS Records   admin   True
      begin
        grJASConfig.bProtectJASRecords:=bVal(saDataIn);
        //ASPrintln('bProtectJASRecords');
      end;

      u8:=2012100614510501178;
      if (u8DataIn=u8) and (not rConfigOverridden.bClientToVICIServerIP) then // JAS RC VICI Client To Server Address  admin
      begin
        grJASConfig.saClientToVICIServerIP:=trim(saDataIn);
        //ASPrintln('saClientToVICIServerIP');
      end;

      u8:=2012100614511733687;
      if (u8DataIn=u8) and (not rConfigOverridden.bJASServertoVICIServerIP) then // JAS RC VICI Server To Server Address  admin
      begin
        grJASConfig.saJASServertoVICIServerIP:=trim(saDataIn);
        //ASPrintln('saJASServertoVICIServerIP');
      end;

      u8:=2012100706052712248;
      if (u8DataIn=u8) and (not rConfigOverridden.bLockRetriesBeforeFailure) then // JAS Record Lock Retries Before Failure
      begin
        grJASConfig.iLockRetriesBeforeFailure:=iVal(saDataIn);
        //ASPrintln('iLockRetriesBeforeFailure');
      end;

      u8:=2012100615120666942;
      if (u8DataIn=u8) and (not rConfigOverridden.bLockRetryDelayInMSec) then // JAS Record Lock Retry Delay In Milli Seconds  admin   20
      begin
        grJASConfig.iLockRetryDelayInMSec:=iVal(saDataIn);
        //ASPrintln('iLockRetryDelayInMSec');
      end;

      u8:=2012100615123707971;
      if (u8DataIn=u8) and (not rConfigOverridden.bLockTimeoutInMinutes) then // JAS Record Lock Time Out In Minutes   admin   30
      begin
        grJASConfig.iLockTimeoutInMinutes:=iVal(saDataIn);
        //ASPrintln('iLockTimeoutInMinutes');
      end;

      u8:=2012100615140260928;
      if (u8DataIn=u8) and (not rConfigOverridden.bRetryDelayInMSec) then // JAS Retry Delay In Milli Seconds  admin   100
      begin
        grJASConfig.iRetryDelayInMSec:=iVal(saDataIn);
        //ASPrintln('iRetryDelayInMSec');
      end;

      u8:=2012100615142419915;
      if (u8DataIn=u8) and (not rConfigOverridden.bRetryLimit) then // JAS Retry Limit   admin   20
      begin
        grJASConfig.iRetryLimit:=iVal(saDataIn);
        //ASPrintln('iRetryLimit');
      end;

      u8:=2012100615145637878;
      if (u8DataIn=u8) and (not rConfigOverridden.bSafeDelete) then // JAS Safe Delete   admin   True
      begin
        grJASConfig.bSafeDelete:=bVal(saDataIn);
        //ASPrintln('bSafeDelete');
      end;

      u8:=2012100615152356082;
      if (u8DataIn=u8) and (not rConfigOverridden.bServerConsoleMessagesEnabled) then // JAS Server Console Messages Enabled   admin   Yes
      begin
        //ASPrintln('Got 2012100615152356082 - bServerConsoleMessagesEnabled:'+saDataIn+':');
        grJASConfig.bServerConsoleMessagesEnabled:=bVal(saDataIn);
        //ASPrintln('Assigned 2012100615152356082 - bServerConsoleMessagesEnabled');
        //ASPrintln('bServerConsoleMessagesEnabled');
      end;

      u8:=2012100615160460912;
      if (u8DataIn=u8) and (not rConfigOverridden.bSessionTimeoutInMinutes) then // JAS SessionTime Out In Minutes  admin   240
      begin
        grJASConfig.iSessionTimeoutInMinutes:=iVal(saDataIn);
        //ASPrintln('iSessionTimeoutInMinutes');
      end;

      u8:=2012100615162043726;
      if (u8DataIn=u8) and (not rConfigOverridden.bSMTPHost) then // JAS SMTP Host   admin
      begin
        grJASCOnfig.sSMTPHost:=trim(saDataIn);
        //ASPrintln('sSMTPHost');
      end;

      u8:=2012100615163514292;
      if (u8DataIn=u8)  and (not rConfigOverridden.bSMTPPassword) then // JAS SMTP Password   admin
      begin
        grJASCOnfig.sSMTPPassword:=trim(saDataIn);
        //ASPrintln('sSMTPPassword');
      end;

      u8:=2012100615164495133;
      if (u8DataIn=u8) and (not rConfigOverridden.bSMTPUsername) then // JAS SMTP Username   admin
      begin
        grJASCOnfig.sSMTPUsername:=trim(saDataIn);
        //ASPrintln('sSMTPUsername');
      end;

      u8:=2012100615172828038;
      if (u8DataIn=u8) and (not rConfigOverridden.bSocketTimeOutInMSec) then // JAS Socket Timeout In Milli Seconds   admin   12000
      begin
        grJASConfig.iSocketTimeOutInMSec:=iVal(saDataIn);
        //ASPrintln('iSocketTimeOutInMSec');
      end;

      u8:=2012100615180834150;
      if (u8DataIn=u8) and (not rConfigOverridden.bTimeZoneOffSet) then // JAS Timezone Offset   admin   -5
      begin
        grJASConfig.iTimeZoneOffSet:=iVal(saDataIn);
        //ASPrintln('iTimeZoneOffSet');
      end;

      u8:=2012100615183451070;
      if (u8DataIn=u8) and (not rConfigOverridden.bValidateSessionRetryLimit) then // JAS Validate Session Retry Limit  admin   50
      begin
        grJASConfig.iValidateSessionRetryLimit:=iVal(saDataIn);
        //ASPrintln('iValidateSessionRetryLimit');
      end;

      u8:=2012100706402078540;
      if (u8DataIn=u8) and (not rConfigOverridden.bWebShareAlias) then // JAS Webshare Alias
      begin
        grJASConfig.saWebShareAlias:=saTrim(saDataIn);
        //ASPrintln('-----------WEBSHARE------------');
        //ASPrintln(grJASConfig.saWebShareAlias);
        //ASPrintln('-----------WEBSHARE------------');
        //ASPrintln('saWebShareAlias');
      end;

      u8:=1511140035347260001;
      if (u8DataIn=u8) and (not rConfigOverridden.bDirectoryListing) then // JAS Allow Directory Listing
      begin
        grJASConfig.bDirectoryListing:=bVal(saDataIn);
        //ASPrintln('bDirectoryListing');
      end;

      u8:=2012100523502800347;
      if (u8DataIn=u8) and (not rConfigOverridden.bWhiteListEnabled) then
      begin
        grJASConfig.bWhiteListEnabled:=bVal(saDataIn);
        //ASPrintln('bWhiteListEnabled');
      end;

      u8:=2012100523493783574;
      if (u8DataIn=u8) and (not rConfigOverridden.bBlackListEnabled) then
      begin
        grJASConfig.bBlackListEnabled:=bVal(saDataIn);
        //ASPrintln('bBlackListEnabled');
      end;

      u8:=2012100906502356513;
      if (u8DataIn=u8) and (not rConfigOverridden.bJASFooter) then
      begin
        grJASConfig.saJASFooter:=trim(saDataIn);
        //ASPrintln('saJASFooter');
      end;

      u8:=2012100723482235916;
      if (u8DataIn=u8) and (not rConfigOverridden.bPasswordKey) then
      begin
        grJASConfig.u1PasswordKey:=u1Val(saDataIn);
        //ASPrintln('u1PasswordKey');
      end;

      u8:=1211061858501530001;
      if(u8DataIn=u8) and  (not rConfigOverridden.bAllowVirtualHostCreation) then
      begin
        grJASConfig.bAllowVirtualHostCreation:=bVal(saDataIn);
        //ASPrintln('bAllowVirtualHostCreation');
      end;

      u8:=1211231539180430025;
      if(u8DataIn=u8) and  (not rConfigOverridden.bCreateHybridJets) then
      begin
        grJASConfig.bCreateHybridJets:=bVal(saDataIn);
        //ASPrintln('bCreateHybridJets');
      end;

      u8:=1511122305040190001;
      if(u8DataIn=u8) and  (not rConfigOverridden.bSIPURL) then
      begin
        //ASPrintln('saDataIn:'+saDataIn);JASPrintln('u8DataIn:'+inttostr(u8DataIn));
        //ASPRintLn('rConfigOverridden.bSIPURL: '+saTrueFalse(rConfigOverridden.bSIPURL));
        //ASPrintln('grJASConfig.saSIPURL on entry: '+grJASConfig.saSIPURL);
        //grJASConfig.saSIPURL:=saDataIn;
        //ASPrintln('grJASConfig.saSIPURL: '+grJASConfig.saSIPURL+'   201511132231');
        //ASPrintln('saSIPURL');
      end;
    until (not bOK) or (not rs.movenext);
    //ASPRintln('Ok:'+saTrueFalse(bOk));
  end;
  rs.close;
  //ASPrintln('PAST Loading Pref Settings');
  grJegasCommon.rJegasLog.saFileName:=grJASConfig.saSysDir+csDOSSLASH+'log'+csDOSSLASH+csLOG_FILENAME_DEFAULT;
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
    //ASPrintln('System VHost Only: '+satrueFalse(bMainSystemOnly));
    saQry:=
      'SELECT '+
        'VHost_JVHost_UID,'+
        'VHost_WebRootDir,'+
        'VHost_ServerName,'+
        'VHost_ServerIdent,'+
        'VHost_ServerDomain,'+
        'VHost_ServerIP,'+
        'VHost_ServerPort,'+
        'VHost_DefaultLanguage,'+
        'VHost_DefaultColorTheme,'+
        'VHost_MenuRenderMethod,'+
        'VHost_DefaultArea,'+
        'VHost_DefaultPage,'+
        'VHost_DefaultSection,'+
        'VHost_DefaultTop_JMenu_ID,'+
        'VHost_DefaultLoggedInPage,'+
        'VHost_DefaultLoggedOutPage,'+
        'VHost_DataOnRight_b,'+
        'VHost_CacheMaxAgeInSeconds,'+
        'VHost_SystemEmailFromAddress,'+
        'VHost_EnableSSL_b,'+
        'VHost_SharesDefaultDomain_b,'+
        'VHost_DefaultIconTheme,'+
        'VHost_DirectoryListing_b,'+
        'VHost_FileDir,'+
        'VHost_AccessLog,'+
        'VHost_ErrorLog,'+
        'VHost_JDConnection_ID, '+
        'VHost_CacheDir, '+
        'VHost_TemplateDir, '+
        'VHost_SIPURL '+
      'FROM jvhost '+
      'WHERE ((VHost_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL)) AND '+
        ' VHOST_Enabled_b='+gaJCon[0].saDBMSBoolScrub(true);
    bOk:=rs.Open(saQry,gaJCon[0],201503161670);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load virtual host records. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210070950,saMsg , SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      //ASPrintln('Loading VHost: '+rs.fields.Get_saValue('VHost_ServerName'));
      setlength(garJVHostLight, length(garJVHostLight)+1);
      i:=length(garJVHostLight)-1;
      clear_JVhostLight(garJVHostLight[i]);
      with garJVHostLight[i] do begin
        u8JVHost_UID               :=u8Val(rs.fields.Get_saValue('VHost_JVHost_UID'));
        saWebRootDir               :=rs.fields.Get_saValue('VHost_WebRootDir');
        saServerName               :=rs.fields.Get_saValue('VHost_ServerName');
        saServerIdent              :=trim(upcase(rs.fields.Get_saValue('VHost_ServerIdent')));
        saServerDomain             :=lowercase(rs.fields.Get_saValue('VHost_ServerDomain'));
        saServerIP                 :=rs.fields.Get_saValue('VHost_ServerIP');
        u2ServerPort               :=u2Val(rs.fields.Get_saValue('VHost_ServerPort'));
        saDefaultLanguage          :=lowercase(rs.fields.Get_saValue('VHost_DefaultLanguage'));
        saDefaultColorTheme        :=rs.fields.Get_saValue('VHost_DefaultColorTheme');
        u1MenuRenderMethod         :=u1Val(rs.fields.Get_saValue('VHost_MenuRenderMethod'));
        saDefaultArea              :=rs.fields.Get_saValue('VHost_DefaultArea');
        saDefaultPage              :=rs.fields.Get_saValue('VHost_DefaultPage');
        saDefaultSection           :=rs.fields.Get_saValue('VHost_DefaultSection');
        u8DefaultTop_JMenu_ID      :=u8Val(rs.fields.Get_saValue('VHost_DefaultTop_JMenu_ID'));
        saDefaultLoggedInPage      :=rs.fields.Get_saValue('VHost_DefaultLoggedInPage');
        saDefaultLoggedOutPage     :=rs.fields.Get_saValue('VHost_DefaultLoggedOutPage');
        bDataOnRight               :=bVal(rs.fields.Get_saValue('VHost_DataOnRight_b'));
        sCacheMaxAgeInSeconds      :=rs.fields.Get_saValue('VHost_CacheMaxAgeInSeconds');
        sSystemEmailFromAddress    :=rs.fields.Get_saValue('VHost_SystemEmailFromAddress');
        bEnableSSL                 :=bVal(rs.fields.Get_saValue('VHost_EnableSSL_b'));
        bSharesDefaultDomain       :=bVal(rs.fields.Get_saValue('VHost_SharesDefaultDomain_b'));
        saDefaultIconTheme         :=rs.fields.Get_saValue('VHost_DefaultIconTheme');
        bDirectoryListing          :=bVal(rs.fields.Get_saValue('VHost_DirectoryListing_b'));
        saFileDir                  :=rs.fields.Get_saValue('VHost_FileDir');
        saAccessLog                :=rs.fields.Get_saValue('VHost_AccessLog');
        saErrorLog                 :=rs.fields.Get_saValue('VHost_ErrorLog');
        u8JDConnection_ID          :=u8Val(rs.fields.Get_saValue('VHost_JDConnection_ID'));
        saCacheDir                 :=rs.fields.Get_saValue('VHost_CacheDir');
        saTemplateDir              :=rs.fields.Get_saValue('VHost_TemplateDir');
        saSIPURL                   :=rs.fields.Get_saValue('VHost_SIPURL');
        if upcase(saServerdomain)='DEFAULT' then i4DefaultHostCount+=1;
      end;
    until (not bOk) or (not rs.MoveNext) or (bMainSystemOnly);
  end;
  rs.close;

  if bOk then
  begin
    if length(garJVHostLight)=0 then
    begin
      JASDebugPrintln('no vhosts in garJVHostLight un uj_config');
      setlength(garJVHostLight,1);
      i4DefaultHostCount+=1;
      with garJVHostLight[0] do begin
        u8JVHost_UID               :=0;
        saWebRootDir               :=grJASConfig.saWebRootDir;
        saServerName               :=grJASConfig.saServerName;
        saServerIdent              :=grJASConfig.saServerIdent;
        saServerDomain             :='default';
        saServerIP                 :=grJASConfig.saServerIP;
        u2ServerPort               :=grJASConfig.u2ServerPort;
        saDefaultLanguage          :=lowercase(grJASConfig.saDefaultLanguage);
        saDefaultColorTheme        :=grJASConfig.saDefaultColorTheme;
        u1MenuRenderMethod         :=grJASConfig.u1DefaultMenuRenderMethod;
        saDefaultArea              :=grJASConfig.saDefaultArea;
        saDefaultPage              :=grJASConfig.saDefaultPage;
        saDefaultSection           :=grJASConfig.saDefaultSection;
        u8DefaultTop_JMenu_ID      :=grJASConfig.u8DefaultTop_JMenu_ID;
        bDataOnRight               :=grJASConfig.bDataOnRight;
        sCacheMaxAgeInSeconds      :=grJASConfig.sCacheMaxAgeInSeconds;
        sSystemEmailFromAddress    :=grJASConfig.sSystemEmailFromAddress;
        bEnableSSL                 :=grJASConfig.bEnableSSL;
        bSharesDefaultDomain       :=grJASConfig.bDefaultSharesDefaultDomain;
        saDefaultIconTheme         :=grJASConfig.saDefaultIConTheme;
        bDirectoryListing          :=grJASConfig.bDirectoryListing;
        saAccessLog                :=grJASConfig.saDefaultAccessLog;
        saErrorLog                 :=grJASConfig.saDefaultErrorLog;
        saFileDir                  :=grJASConfig.saFileDir;
        saCacheDir                 :=grJASConfig.saCacheDir;
        u8JDConnection_ID          :=0;
      end;//with
    end;

    if i4DefaultHostCount>1 then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Multiple Virtual Host Found in database.';
      JASPrintln(saMsg);
      JLog(cnLog_Warn, 201210170805,saMsg , SOURCEFILE);
    end else

    if i4DefaultHostCount=0 then
    begin
      bLogEntryMadeDuringStartUp:=true;
      bOk:=false;
      saMsg:='No default virtual host available.';
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210170806,saMsg , SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    for i:=0 to length(garJVHostLight)-1 do
    begin
      if UPCASE(garJVHostLight[i].saServerDomain)='DEFAULT' then
      begin
        u8VHostID_DEFAULT:=garJVHostLight[i].u8JVHost_UID;
        i4DefaultHostIndex:=i;
      end;
    end;
  end;

  if bOk then
  begin
    with rJVHostOverridden do begin
      if bVHost_WebRootDir                then
      begin
        garJVHostLight[i4DefaultHostIndex].saWebRootDir:=rJVHostOverride.saWebRootDir;
      end;
      if bVHost_DefaultLanguage           then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultLanguage:=rJVHostOverride.saDefaultLanguage;
      end;
      if bVHost_Defaultcolortheme         then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultColorTheme:=rJVHostOverride.saDefaultColorTheme;
      end;
      if bVHost_DefaultArea               then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultArea:=rJVHostOverride.saDefaultArea;
      end;
      if bVHost_DefaultPage               then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultPage:=rJVHostOverride.saDefaultPage;
      end;
      if bVHost_DefaultSection            then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultSection:=rJVHostOverride.saDefaultSection;
      end;
      if bVHost_DefaultTop_JMenu_ID         then
      begin
        garJVHostLight[i4DefaultHostIndex].u8DefaultTop_JMenu_ID:=rJVHostOverride.u8DefaultTop_JMenu_ID;
      end;
      if bVHost_DefaultLoggedInPage       then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultLoggedInPage:=rJVHostOverride.saDefaultLoggedInPage;
      end;
      if bVHost_DefaultLoggedOutPage      then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultLoggedOutPage:=rJVHostOverride.saDefaultLoggedOutPage;
      end;
      if bVHost_DataOnRight_b             then
      begin
        garJVHostLight[i4DefaultHostIndex].bDataOnRight:=rJVHostOverride.bDataOnRight;
      end;
      if bVHost_CacheMaxAgeInSeconds      then
      begin
        garJVHostLight[i4DefaultHostIndex].sCacheMaxAgeInSeconds:=rJVHostOverride.sCacheMaxAgeInSeconds;
      end;
      if bVHost_SystemEmailFromAddress    then
      begin
        garJVHostLight[i4DefaultHostIndex].sSystemEmailFromAddress:=rJVHostOverride.sSystemEmailFromAddress;
      end;
      if bVHost_EnableSSL_b                 then
      begin
        garJVHostLight[i4DefaultHostIndex].bEnableSSL:=rJVHostOverride.bEnableSSL;
      end;
      if bVHost_SharesDefaultDomain_b       then
      begin
        garJVHostLight[i4DefaultHostIndex].bSharesDefaultDomain:=rJVHostOverride.bSharesDefaultDomain;
      end;
      if bVHost_DefaultIconTheme          then
      begin
        garJVHostLight[i4DefaultHostIndex].saDefaultIconTheme:=rJVHostOverride.saDefaultIconTheme;
      end;
      if bVHost_DirectoryListing_b          then
      begin
        garJVHostLight[i4DefaultHostIndex].bDirectoryListing:=rJVHostOverride.bDirectoryListing;
      end;
      if bVHost_FileDir                 then
      begin
        garJVHostLight[i4DefaultHostIndex].saFileDir:=rJVHostOverride.saFileDir;
      end;
      if bVHost_AccessLog                 then
      begin
        garJVHostLight[i4DefaultHostIndex].saAccessLog:=rJVHostOverride.saAccessLog;
      end;
      if bVHost_ErrorLog                  then
      begin
        garJVHostLight[i4DefaultHostIndex].saErrorLog:=rJVHostOverride.saErrorLog;
      end;
      if bVHost_JDConnection_ID            then
      begin
        garJVHostLight[i4DefaultHostIndex].u8JDConnection_ID:=rJVHostOverride.u8JDConnection_ID;
      end;
      if bVHost_ServerIP                  then
      begin
        garJVHostLight[i4DefaultHostIndex].saServerIP:=rJVHostOverride.saServerIP;
      end;
      if bVHost_ServerPort                then
      begin
        garJVHostLight[i4DefaultHostIndex].u2ServerPort:=rJVHostOverride.u2ServerPort;
      end;
      if bVHost_DefaultTop_JMenu_ID          then
      begin
        garJVHostLight[i4DefaultHostIndex].u8DefaultTop_JMenu_ID:=rJVHostOverride.u8DefaultTop_JMenu_ID;
      end;
      if bVHost_MenuRenderMethod          then
      begin
        garJVHostLight[i4DefaultHostIndex].u1MenuRenderMethod:=rJVHostOverride.u1MenuRenderMethod;
      end;
    end;//with
  end;

  if bOk then
  begin
    grJASConfig.saWebRootDir:=garJVHostLight[i4DefaultHostIndex].saWebRootDir;
  end;
 
 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;
 // END ---------------------------------------- garJVHost: array of rtJVHost;












  // BEGIN ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // BEGIN ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // BEGIN ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // BEGIN ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'THCOL_JThemeColor_UID,'+
        'THCOL_Name,'+
        'THCOL_Template_Header '+
      'FROM jthemecolor '+
      'WHERE ((THCOL_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(THCOL_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry,gaJCon[0],201503161654);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load themecolor list. Query: '+saQry;
      JASPrintln(saMsg);
      JLog(cnLog_FATAL, 201210090601, saMsg, SOURCEFILE);
    end;
  end;

  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJThemeColorLight, length(garJThemeColorLight)+1);
      i:=length(garJThemeColorLight)-1;
      clear_JThemeColorLight(garJThemeColorLight[i]);
      with garJThemeColorLight[i] do begin
        u8JThemeColor_UID       := u8Val(rs.fields.get_saValue('THCOL_JThemeColor_UID'));
        saName                  := rs.fields.get_saValue('THCOL_Name');
        saTemplate_Header       := rs.fields.get_saValue('THCOL_Template_Header');
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
  // END ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // END ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // END ---------------------------------------- garJThemeColor: array of rtJThemeColor;
  // END ---------------------------------------- garJThemeColor: array of rtJThemeColor;






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
      'WHERE ((JLang_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(JLang_Deleted_b IS NULL))';
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
      i:=length(garJLanguageLight)-1;
      clear_JLanguageLight(garJLanguageLight[i]);
      with garJLanguageLight[i] do begin
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
      'WHERE ((JIDX_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(JIDX_Deleted_b IS NULL)) '+
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
      i:=length(garJIndexFileLight)-1;
      clear_JIndexFileLight(garJIndexFileLight[i]);
      with garJIndexFileLight[i] do begin
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
  if bOk then
  begin
    saQry:=
      'SELECT '+
        'JIPL_JIPList_UID,'+
        'JIPL_IPListType_u,'+
        'JIPL_IPAddress '+
      'FROM jiplist';
    bOk:=rs.Open(saQry,gaJCon[0],201503161657);
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to load IP Lists. Query: '+saQry;
      JASPrintln(saMSG);
      JLog(cnLog_FATAL, 201210070847, 'Unable to load configuration settings. Query: '+saQry, SOURCEFILE);
    end;
  end;


  if bOk and (NOT rs.EOL) THEN
  begin
    repeat
      setlength(garJIPListLight, length(garJIPListLight)+1);
      i:=length(garJIPListLight)-1;
      clear_JIPListLight(garJIPListLight[i]);
      with garJIPListLight[i] do begin
        u8JIPList_UID            :=u8Val(rs.fields.get_saValue('JIPL_JIPList_UID'));
        u1IPListType             :=u1Val(rs.fields.get_saValue('JIPL_IPListType_u'));
        saIPAddress              :=rs.fields.get_saValue('JIPL_IPAdress');
      end;
    until (not bOk) or (not rs.MoveNext)
  end;
  rs.close;
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
      'WHERE ((Alias_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(Alias_Deleted_b IS NULL))';
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
      i:=length(garJAliasLight)-1;
      clear_JAliasLight(garJAliasLight[i]);
      with garJAliasLight[i] do begin
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

  bGotOne:=false;
  if length(garJAliasLight)>0 then
  begin
    bGotOne:=false;
    for i:=0 to length(garJAliasLight)-1 do
    begin
      bGotOne:=(garJAliasLight[i].u8JVHost_ID=u8VHostID_DEFAULT) and
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
      'WHERE ((MIME_Deleted_b<>'+gaJCon[0].saDBMSBoolScrub(true)+')OR(MIME_Deleted_b IS NULL)) AND '+
        'MIME_Enabled_b='+gaJCon[0].saDBMSBoolScrub(true);
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
      i:=length(garJMimeLight)-1;
      clear_JMimeLight(garJMimeLight[i]);
      with garJMimeLight[i] do begin
        u8JMime_UID             :=u8Val(rs.fields.get_saValue('MIME_JMime_UID'));
        saName                  :=rs.fields.get_saValue('MIME_Name');
        saType                  :=rs.fields.get_saValue('MIME_Type');
        bSNR                    :=bVal(rs.fields.get_saValue('MIME_SNR_b'));
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
    // We Enforce this for JDConnection UID ZERO ALSO
    gaJCon[0].saName:='JAS';
    if gaJCon[0].u8GetRowCount('jdconnection','JDCon_JDConnection_UID=0',201506171780)=0 then
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
          gaJCon[0].saDBMSUIntScrub(0)+','+
          gaJCon[0].saDBMSScrub('JAS')+','+
          gaJCon[0].saDBMSScrub('JAS Default Connection.')+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saDSN)+','+
          gaJCon[0].saDBMSBoolScrub(gaJCon[0].bFileBasedDSN)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saDSNFilename)+','+
          gaJCon[0].saDBMSBoolScrub(true)+','+
          gaJCon[0].saDBMSUIntScrub(gaJCon[0].u2DbmsID)+','+
          gaJCon[0].saDBMSUIntScrub(gaJCon[0].u2DrivID)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saUsername)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saPassword)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saDriver)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saServer)+','+
          gaJCon[0].saDBMSScrub(gaJCon[0].saDatabase)+','+
          gaJCon[0].saDBMSScrub(grJASConfig.saDBCFilename)+','+
          gaJCon[0].saDBMSUIntScrub(gaJCon[0].JDCon_JSecPerm_ID)+','+
          gaJCon[0].saDBMSUIntScrub(0)+','+
          gaJCon[0].saDBMSDateScrub(now)+','+
          gaJCon[0].saDBMSUIntScrub('NULL')+','+
          gaJCon[0].saDBMSDateScrub('NULL')+','+
          gaJCon[0].saDBMSUIntScrub('NULL')+','+
          gaJCon[0].saDBMSDateScrub('NULL')+','+
          gaJCon[0].saDBMSBoolScrub(false)+','+
          gaJCon[0].saDBMSBoolScrub(true)+
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
          'JDCon_DSN='                    +gaJCon[0].saDBMSScrub(gaJCon[0].saDSN)+','+
          'JDCon_DBC_Filename='           +gaJCon[0].saDBMSScrub(grJASConfig.saDBCFilename)+','+
          'JDCon_Enabled_b='              +gaJCon[0].saDBMSBoolScrub(true)+','+
          'JDCon_DBMS_ID='                +gaJCon[0].saDBMSUIntScrub(gaJCon[0].u2DbmsID)+','+
          'JDCon_Driver_ID='              +gaJCon[0].saDBMSIntScrub(gaJCon[0].u2DrivID)+','+
          'JDCon_Username='               +gaJCon[0].saDBMSScrub(gaJCon[0].saUsername)+','+
          'JDCon_Password='               +gaJCon[0].saDBMSScrub(gaJCon[0].saPassword)+','+
          'JDCon_ODBC_Driver='            +gaJCon[0].saDBMSScrub(gaJCon[0].saDriver)+','+
          'JDCon_Server='                 +gaJCon[0].saDBMSScrub(gaJCon[0].saServer)+','+
          'JDCon_Database='               +gaJCon[0].saDBMSScrub(gaJCon[0].saDatabase)+','+
          'JDCon_DSN_FileBased_b='        +gaJCon[0].saDBMSBoolScrub(gaJCon[0].bFileBasedDSN)+','+
          'JDCon_DSN_Filename='           +gaJCon[0].saDBMSScrub(gaJCon[0].saDSNFilename)+','+
          'JDCon_JSecPerm_ID='            +gaJCon[0].saDBMSUIntScrub(gaJCon[0].JDCon_JSecPerm_ID)+','+
          'JDCon_ModifiedBy_JUser_ID='    +gaJCon[0].saDBMSUIntScrub(0)+','+
          'JDCon_Modified_DT='            +gaJCon[0].saDBMSDateScrub(now)+','+
          'JDCon_DeletedBy_JUser_ID='     +gaJCon[0].saDBMSUIntScrub('NULL')+','+
          'JDCon_Deleted_DT='             +gaJCon[0].saDBMSDateScrub('NULL')+','+
          'JDCon_Deleted_b='              +gaJCon[0].saDBMSBoolScrub(false)+','+
          'JAS_Row_b='                    +gaJCon[0].saDBMSBoolScrub(true)+' '+
        'WHERE JDCon_JDConnection_UID='+gaJCon[0].saDBMSUIntScrub(0);
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

  if not bMainSystemOnly then
  begin
    if bOk then
    begin
      saQry:='select * from jdconnection where JDCon_Deleted_b<>'+
        gaJCon[0].saDBMSBoolScrub(true)+' and '+
        'JDCon_JDConnection_UID>0 and '+
        'JDCon_Enabled_b='+gaJCon[0].saDBMSBoolScrub(true)+' order by JDCon_Name';
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
        i:=1;
        repeat
          setlength(gaJCon,i+1);
          gaJCon[i]:=JADO_CONNECTION.Create;
          gaJCon[i].ID:=                  rs.Fields.Get_saValue('JDCon_JDConnection_UID');
          gaJCon[i].JDCon_JSecPerm_ID:=   rs.fields.Get_saValue('JDCon_JSecPerm_ID');
          gaJCon[i].saName:=              upcase(rs.Fields.Get_saValue('JDCon_Name'));
          gaJCon[i].saDesc:=              rs.Fields.Get_saValue('JDCon_Desc');
          gaJCon[i].saDSN:=               rs.Fields.Get_saValue('JDCon_DSN');
          gaJCon[i].saUserName:=          rs.Fields.Get_saValue('JDCon_Username');
          gaJCon[i].saPassword:=          rs.Fields.Get_saValue('JDCon_Password');
          gaJCon[i].saDriver:=            rs.Fields.Get_saValue('JDCon_ODBC_Driver');
          gaJCon[i].saServer:=            rs.Fields.Get_saValue('JDCon_Server');
          gaJCon[i].saDatabase:=          rs.Fields.Get_saValue('JDCon_Database');
          gaJCon[i].u2DrivID:=            u2Val(rs.Fields.Get_saValue('JDCon_Driver_ID'));
          gaJCon[i].u2DbmsID:=            u2Val(rs.Fields.Get_saValue('JDCon_DBMS_ID'));
          gaJCon[i].bFileBasedDSN:=       bVal(rs.Fields.Get_saValue('JDCon_DSN_FileBased_b'));
          gaJCon[i].saDSNFileName:=       rs.Fields.Get_saValue('JDCon_DSN_Filename');
          gaJCon[i].bJas:=                bVal(rs.Fields.Get_saValue('JDCon_JAS_b'));

          saDBCFilename:=rs.Fields.Get_saValue('JDCon_DBC_Filename');
          saMsg:='Database Name : '+gaJCon[i].saName+' ';
          saMsg+='Description: '+gaJCon[i].saDesc+' ';
          saMsg+='DBC File: '+saDBCFilename+' ';
          //ASPrintln(saMsg);JLog(cnLog_DEBUG, 201002091726, saMsg, SOURCEFILE);
          bOk:=fileexists(saDBCFilename);
          if bOk then
          begin
            bOk:=gaJCon[i].bLoad(saDBCFilename);
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
            gaJCon[i].bFileBasedDSN := bVal(rs.Fields.Get_saValue('JDCon_DSN_FileBased_b'));
            gaJCon[i].saDSNFileName := rs.Fields.Get_saValue('JDCon_DSN_Filename');
          end;

          bOk:=gaJCon[i].saName<>'JAS';
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
            bOk:=gaJCon[i].OpenCon;
            if not bOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              bUnableToOpen:=true;
              JLog(cnLog_FATAL, 201002061633, '*** Unable to connect to JDConnection: '+gaJCon[i].saName, SOURCEFILE);
            end;
          end;
          i:=i+1;
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
    for iHost:=0 to length(garJVHostLight)-1 do
    begin
      //ASPrintln('Host #:'+inttostr(iHost));
      iDBX:=0;bDone:=false;
      repeat
        //ASPrintln('VHDBC REPEAT');
        if u8val(gaJCon[iDBX].ID)=garJVHostLight[iHost].u8JDConnection_ID then
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
        if not bCreateAndLoadJMenuIntoDL(garJVHostLight[iHost].MenuDL, gaJCon[iDBX]) then
        Begin
          bLogEntryMadeDuringStartUp:=true;
          saMSG:='Unable to load JMenuIntoDL Host: '+garJVHostLight[iHost].saServerDomain;
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
          //ASPrintln('Check Length garJVHostLight: '+inttostr(length(garJVHostLight)));
          //ASPrintln('JAS IDENT - Begin first assignment to garJVHostLight[iHost].');
          garJVHostLight[iHost].bIdentOk:=true;
          //ASPrintln('JAS IDENT - Past first assignment to garJVHostLight[iHost].');
          
          saQry:='select count(*) as MyCount from jasident';
          garJVHostLight[iHost].bIdentOk:=rs.Open(saQry,gaJCon[iDBX],201503161664);
          if not garJVHostLight[iHost].bIdentOk then
          begin
            bLogEntryMadeDuringStartUp:=true;
            JLog(cnLog_FATAL, 201007231729, 'Host: '+garJVHostLight[iHost].saServerDomain+' Unable to load JAS Server ID from jasident table. Query: '+saQry, SOURCEFILE);
          end;
          //ASPRintln('IDENT 1');

          if garJVHostLight[iHost].bIdentOk then
          begin
            garJVHostLight[iHost].bIdentOk:=(i8Val(rs.Fields.Get_saValue('MyCount')) = 1);
            if not garJVHostLight[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231730, 'Host: '+garJVHostLight[iHost].saServerDomain+' Invalid record count in jasident table. Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 2');

          if garJVHostLight[iHost].bIdentOk then
          begin
            rs.close;
            saQry:='select JASID_ServerIdent from jasident';
            garJVHostLight[iHost].bIdentOk:=rs.Open(saQry, gaJCon[iDBX],201503161665);
            if not garJVHostLight[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231731, 'Host: '+garJVHostLight[iHost].saServerDomain+' Unable to load JAS Server Ident. Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 3');

          if garJVHostLight[iHost].bIdentOk then
          begin
            garJVHostLight[iHost].bIdentOk:=rs.EOL=false;
            if not garJVHostLight[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231732, 'JET: '+garJVHostLight[iHost].saServerName+' Zero records returned trying to check JAS Ident Query: '+saQry, SOURCEFILE);
            end;
          end;
          //ASPRintln('IDENT 4');

          if garJVHostLight[iHost].bIdentOk then
          begin
            garJVHostLight[iHost].bIdentOk:=trim(upcase(rs.Fields.Get_saValue('JASID_ServerIdent')))=garJVHostLight[iHost].saServerIdent;
            if not garJVHostLight[iHost].bIdentOk then
            begin
              bLogEntryMadeDuringStartUp:=true;
              JLog(cnLog_FATAL, 201007231733, 'Host: '+garJVHostLight[iHost].saServerDomain+
                ' Invalid JAS Server Ident! Do not have a jasident on my watch! '+
                'Configured Ident: '+garJVHostLight[iHost].saServerIdent+' Database Ident: '+
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

        if garJVHostLight[iHost].bIdentOK then
        begin
          // NOTE: These Settings do not have a configuration file override
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          // BEGIN ------------------------------------------ USER PREF SETTINGS (ALL JETS)
          //ASPrintln('BEGIN - Load Host Specific Preferences');
          if bOk then
          begin
            if JADO.bFoundConnectionByID(garJVHostLight[iHost].u8JDConnection_ID,pointer(gaJCon),iDBX) then
            begin
              saQry:='select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from '+
                    'juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and '+
                    'UsrPL_User_ID=1 and ((UserP_Deleted_b<>'+gaJCon[iDBX].saDBMSBoolScrub(true)+')OR(UserP_Deleted_b IS NULL))';
              bOk:=rs.open(saQry, gaJCon[iDBX],201503161666);
              if not bOk then
              begin
                bLogEntryMadeDuringStartUp:=true;
                saMsg:='Unable to load admin configuration preferences for JET '+garJVHostLight[iHost].saServerName+'. Query: '+saQry;
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
                    garJVHostLight[iHost].bAllowRegistration:=bVal(saDataIn);
                    //ASPrintLn('Got bAllow Registration for VHost: ' +inttostr(iHost)+' saDataIn: '+ saDataIn+' bVal: '+saYesNo(bVal(saDataIn)));
                  end else
                  if (u8DataIn=1211061843220630009) then
                  begin
                    garJVHostLight[iHost].bRegistrationReqCellPhone:=bVal(saDataIn);
                  end else
                  if (u8DataIn=1211061843072620008) then
                  begin
                    garJVHostLight[iHost].bRegistrationReqBirthday:=bVal(saDataIn);
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
            sa:=garJVHostLight[iHost].saCacheDir+'jas-menu';
            if FileExists(sa) then
            begin
              u2IOResult:=u2Shell('../bin/rmdir.sh', sa);
              bOk:=(u2IOResult=0) or (u2IOResult=1);
              if not bOk then
              begin
                if u2IOResult>32768 then u2IOResult-=32768;
                JLOG(cnLog_Error, 201212021152, 'Unable to remove menu cache for Server Ident: '+garJVHostLight[iHost].saServerIdent+
                  ' Result: '+inttostr(u2IOResult)+' '+saIOResult(u2IOResult)+' Dir: '+sa,SOURCEFILE);
              end;
            end;
            //ASPrintln('END - Wipe Menu Cache');
          end;


          
        end;
      end;
      if bMainSystemOnly then break;
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
    grJASConfig.saDiagnosticLogFileName:=grJASConfig.saLogDir+'jegasweb_diagnostic.log';
    {$ENDIF}
    grJASConfig.saServerSoftware:=csINET_JAS_SERVER_SOFTWARE;
    saJegasSigFilename:=grJASConfig.saSysDir+'templates'+csDOSSLASH+ grJASConfig.saJASFooter;
    gsaJASFooter:='';
    if not bLoadTextFile(saJegasSigFileName,gsaJASFooter)then
    begin
      gsaJASFooter:='<hr /><center>Copyright&copy;2015 - Jegas, LLC</center>';
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
  iCreateHttpWorkerThreads: integer;
  iBindCount:integer;
  i4ThreadsToMake: longint;
  bServerCyclingNow: boolean;
  saMsg: ansistring;
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
  //if bOk then
  //begin
    with JTI do begin
      bCreateCriticalSection:=true;
      bLoopContinuously:=true;
      bCreateSuspended:=true;
      UID:=0;
    end;//end with
    //asprintln('b4 make listener');
    gListener:=TListen.create(JTI);
    //asprintln('after make listener');

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
    //gListener.ListenSock.SSL.CertCAFile := grJASConfig.saConfigDir + 'cert' + csDOSSLASH + 's_cabundle.pem';
    //gListener.ListenSock.SSL.CertificateFile := grJASConfig.saConfigDir + 'cert' + csDOSSLASH +  's_cacert.pem';
    //gListener.ListenSock.SSL.PrivateKeyFile := grJASConfig.saConfigDir + 'cert' + csDOSSLASH + 's_cakey.pem';
    //gListener.ListenSock.SSL.KeyPassword := 's_cakey';
    //gListener.ListenSock.SSL.verifyCert := True;
    // TODO: revisit SSL

    //ListenSock.NonBlockMode:=true;
    if not bServerCyclingNow then
    begin

      JASPrint('Binding:'+grJASConfig.saServerIP+':'+inttostr(grJASConfig.u2ServerPort)+' Please Wait... ');
      iBindCount:=0;
      repeat
        gListener.ListenSock.bind(grJASConfig.saServerIP,inttostr(grJASConfig.u2ServerPort));
        if gListener.ListenSock.lasterror<> 0 then
        begin
          Yield(grJASConfig.iCreateSocketRetryDelayInMSec);
          iBindCount:=iBindCount+1;
        end;
      until (gListener.ListenSock.lasterror=0) or (iBindCount>grJASConfig.iCreateSocketRetry);
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
    end;
    JASPrintln('Got it!');
  //end;

  // Create HTTP Workers
  if bOk then
  begin
    //asprintln('make workers');

    bOk:=grJASConfig.iThreadPoolNoOfThreads>0;
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
      JASPrint('Creating '+inttostr(grJASConfig.iThreadPoolNoOfThreads)+' worker threads: ');
      with JTI do begin
        bCreateCriticalSection:=false;
        bLoopContinuously:=false;
        bCreateSuspended:=true;
      end;
      i4ThreadsToMake:=grJASConfig.iThreadPoolNoOfThreads;
      setlength(aWorker,i4ThreadsToMake);
      for iCreateHttpWorkerThreads:=-1 to i4ThreadsToMake-1 do
      begin
        if (iCreateHttpWorkerThreads>-1) and (bOk) then
        begin
          JASPrint(inttostr(iCreateHttpWorkerThreads+1));
          JTI.UID:=iCreateHttpWorkerThreads+1;
          try
            bOk:=false;
            aWorker[iCreateHttpWorkerThreads]:=TWorker.Create(JTI);
            JASPrint('.');
            aWorker[iCreateHttpWorkerThreads].iMyID:=iCreateHttpWorkerThreads+1;
            bOk:=true;// only stays true if succeeds
          except on E: EThread do
            begin
              JASPrintln('Exception ETHREAD THROWN - 201012191646');
            end;
          end;
        end;
      end;
      if not bOk then
      begin
        JASPRintln('');
        JASPRintln('FATAL - (But Simple Fix) - JAS Was unable to Allocate Threads - Please Restart Application.');
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
  //i: longint;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bCore_Init';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=true;
  gbServerShuttingDown:=false;
  ResetConfigOverRidden;
  ResetJVHostOverridden;
  clear_JVHostLight(rJVHostOverride);
  
  if bOk then
  begin
    bOk:=bLoadConfigurationFile;
    If not bOk Then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Unable to Load configuration file successfully.';
      JLog(cnLog_FATAL, 201002061640, saMsg, SOURCEFILE);
      JASPrintln(saMsg);
    End;
  end;
  //riteln('Loaded Config');

  if bOk then
  begin
    bOk:=bOpenDatabaseConnections;
    if not bOk then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Database connection of reading configuration failed.';
      JLog(cnLog_FATAL, 201203121034, saMsg, SOURCEFILE);
      JASPrintln(saMSg);
    end;
  end;

  JASPrint(saJegasLogoRawText(csCRLF,true));
  JASPrintln('');
  JASPrintln(grJASConfig.saServerSoftware);
  JASPrintln('Configuration File: '+grJASConfig.saConfigFile);
  if bOk then
  begin
    //ASPrintln('Lead Jet Only: '+satrueFalse(bMainSystemOnly));
    //for i:=0 to length(garJVHostLight)-1 do
    //begin
    //  ASPrintln('Jet: '+garJVHostLight[i].saServerName);
    //end;
    //for i:=0 to length(gaJCon)-1 do
    //begin
    //  ASPrintln('DB: '+gaJCon[i].saName);
    //end;
  end;

  if bOk then
  begin
    bOk:=bApplyBasicConfigSettings;
    if not bOK then
    begin
      bLogEntryMadeDuringStartUp:=true;
      saMsg:='Trouble applying basic config settings.';
      JLog(cnLog_FATAL, 201203121033, saMsg, SOURCEFILE);
      JASPrintln(saMsg);
    end;
  end;

  if bOk then
  Begin
    bOk:=bCreateThreads;
    If not bOk Then
    Begin
      bLogEntryMadeDuringStartUp:=true;
      saMSg:='Unable to load create listener or worker threads.';
      JLog(cnLog_FATAL, 201203121143, saMSg, SOURCEFILE);
      JASPrintln(saMSG);
    End;
  End;

  if bOk then
  begin
    JASPrintln('');
    //JASPrintln('IP:'+grJASConfig.saServerIP+' Port:'+inttostr(grJASConfig.u2ServerPort)+ ' Threads:'+inttostr(grJASConfig.iThreadPoolNoOfThreads)+' '+DateTimeToStr(Date)+', '+TimeToStr(Time));
    JASPrintln('');
    JASPrintln(DateTimeToStr(Date)+' '+TimeToStr(Time)+' JAS Ready For Business!');
    //JASPrint(saJegasLogoRawText(csCRLF,true));
    JASPrintln('');
  end;

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
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: string;{$ENDIF}
begin
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME:='bJAS_ShutDown';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saDone:='Done.';
  // Shut Down All Threads and Parent "Listener Thread"
  
  // handle last request during listener lock up for shutdown
  if (gListener <> nil)then
  begin
    JASPrint('Shutting down listener...');
    gListener.terminate;
    JASPrintln(saDone);
  
    if (not gbServerCycling) then
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
    jasprintln('1');
    if(gListener.Worker<>nil)then
    begin
      jasprintln('2');
      gListener.Worker.ConnectionSocket:=nil;
      jasprintln('6');
    end;
   
    jASPrintln(saDone);

    JASPrint('Shutting down and terminating threads ... ');
    bThreadsStillRunning:=true;
    Yield(100);
    
    repeat
      try
        bThreadsStillRunning:=false;
        for i:=0 to grJASConfig.iThreadPoolNoOfThreads-1 do
        begin 
          if(aWorker[i]<>nil)then
          begin
            aWorker[i].Freeonterminate:=true;  
            aWorker[i].Terminate;//TODO: 200908031804 - revisit - Verify That Terminate is handling the destroy (I believe it does but there might be a flag "destroyOnTerminate")
            aWorker[i].Destroy;
            aWorker[i]:=nil;
          end
          else
          begin
            jasprintln(' aWorker['+inttostr(i)+'] is nil');
          end;
        end;
      finally
        //ASPrint('8.');
        //gListener.CSECTION.Leave;
      end;

      //ASPrint('10.');
      if(bThreadsStillRunning) then Yield(100);// allow some processing to occur
      //ASPrint('11.');

    until bThreadsStillRunning = false;

    setlength(aWorker,0);
    
    JASPrintln(saDone);

    // Destroy Listener
    JASPrint('Destroy Listener Thread ... ');
    
    //gListener.Terminate;gListener:=nil;
    gListener.destroy;gListener:=nil;     
    JASPrintln(saDone);
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
  for i:=0 to length(garJVHostLight)-1 do
  begin
    if not bEmptyAndDestroyJMenuDL(garJVHostLight[i].MenuDL) then
    begin
      JLOG(cnLog_Error, 201210242314,'Unable to empty menu instance garJVHostLight['+inttostr(i)+'].MenuDL',SOURCEFILE);
    end;
  end;
  setlength(garJVHostLight,0);
  setlength(garJMimeLight,0);
  setlength(garJIndexFileLight,0);
  setlength(garJLanguageLight,0);
  setlength(garJThemeColorLight,0);

  JASPrintln(saDone);
  
  //if(gJMenuDL<>nil)then
  //begin
  //  JASPrint('Destroying JMenuDL Navigation System...');
  //  if(false=bEmptyAndDestroyJMenuDL(gJMenuDL))then
  //  begin
  //    JLog(cnLog_ERROR,200902081956,'Error returned from bEmptyAndDestroyJMenuDL',SOURCEFILE);
  //    JASPrintln('Error Encountered: 200902081956');
  //  end
  //  else
  //  begin
  //    JASPrintln(saDone);
  //  end;
  //end;

  
  //DoneTSFileIO;
  DoneThreadManager;
  if(gbServerCycling=false)then
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
  end
  else
  begin
    rNow:=now;
    JASPrintln('');
    JASPrintln('-=-=-=-=-  SERVER CYCLED '+ JDate('',cnDateFormat_11,cnDateFormat_00,rNow) +' -=-=-=-=-=-=-=-=-=-=-');
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
  bMainSystemOnly:=false;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
