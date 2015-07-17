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
// JAS Setup
program setup;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='setup.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================



//=============================================================================
Uses 
//=============================================================================
classes
,syncobjs
,sysutils
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_dir
,uc_console
,uc_sageui
,uc_animate
,ug_jado
,ug_jfc_tokenizer
,ug_misc
,mouse
,process
{$IFDEF LINUX}
,baseunix
{$ENDIF}
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
// Setup Script Command Constants
//=============================================================================
const 
  SS_NOP=0;// No Operation
  SS_INPUT=1;// InputBox
  SS_MSGBOX=2;//Msgbox
  SS_SHELL=3;//Execute Outside Process 
  SS_MAKEDIR=4;//create a directory
  SS_COMPLETED=5;// Completed Result 
  SS_ONTRUEGOTO=6; //TRUE LOGIC BRANCH (branch if true)
  SS_ONFALSEGOTO=7; //FALSE LOGIC BRANCH (branch if false)
  SS_ONFILEEXISTGOTO=8; // if File Exist then Branch 
  SS_ONDIREXISTGOTO=9; // if DIR Exist then Branch 
  SS_COPYFILE=10;
  SS_MOVEFILE=11;
  SS_DELETEFILE=12;
  SS_DELETEDIR=13;
  SS_FAIL=14;
  SS_CONSTANT=15;
  SS_COPYFILESNR=16;
  SS_CONSTANTFINAL=17;// final pass constants for SS_COPYFILESNR 
//=============================================================================




//=============================================================================
// MenuBar Constants
Const
    cnLanguage=1;//1=english
    
    // Setup
    mnuSetupJAS = 100;
    
    mnuExit = 220;

    // Migration
    mnuExecute = 230;

    // Help
    mnuHelp = 690;

//=============================================================================

//=============================================================================
// Public variables and GUI Elements
//=============================================================================
var 
  
  // WinDBMS Login window for MySQL Connections
  gWinDBMS: TWINDOW;
  gWinDBMS_btnOK: TCTLBUTTON;
  gWinDBMS_btnCancel: TCTLBUTTON;
  gWinDBMS_lblUser: TCTLLABEL;
  gWinDBMS_lblPassword: TCTLLABEL;
  gWinDBMS_lblHost: TCTLLABEL;
  gWinDBMS_lblDatabase: TCTLLABEL;
  gWinDBMS_inpUser: TCTLINPUT;
  gWinDBMS_inpPassword: TCTLINPUT;
  gWinDBMS_inpHost: TCTLINPUT;
  gWinDBMS_inpDatabase: TCTLINPUT;
  
  // WinEx Window - Progress Bars etc.
  gWinEx: TWindow;
  gWinEx_PBarMain: TCTLPROGRESSBAR;
  //gWinEx_PBar: TCTLPROGRESSBAR;
  gWinEx_lbl01: TCTLLABEL;
  gWinEx_lbl02: TCTLLABEL;
  gWinEx_btnCancel: TCTLBUTTON;
  

  // Scratch JADO_CONNECTION
  Con: JADO_CONNECTION;
  JASSetupXXDL: JFC_XXDL;
//=============================================================================




//=============================================================================
procedure WriteJASConfigFiles;
//=============================================================================
var
  f: text;
  iResult: longint;
  saMySQLHost: ansistring;
  saMySqlPort: ansistring;
  saMySqlRootName: ansistring;
  saMySqlRootPass: ansistring;
  saMySQLUserName: ansistring;
  saMySQLUserPass: ansistring;
  saJASInstallDir: ansistring;
  saFilenameJASConfig:ansistring;
  saFilenameJASDSN: ansistring;
  saFilenamePopDB: ansistring;
  bWriteFile: boolean;
begin
  saMySQLHost    :=JASSetupXXDL.Get_saValue('MYSQLHOST');
  saMySqlPort    :=JASSetupXXDL.Get_saValue('MYSQLPORT');
  saMySqlRootName:=JASSetupXXDL.Get_saValue('MYSQLROOTNAME');
  saMySqlRootPass:=JASSetupXXDL.Get_saValue('MYSQLROOTPASS');
  saMySQLUserName:=JASSetupXXDL.Get_saValue('MYSQLUSERNAME');
  saMySQLUserPass:=JASSetupXXDL.Get_saValue('MYSQLUSERPASS');
  saJASInstallDir:=JASSetupXXDL.Get_saValue('JASINSTALLDIR');
  saFilenameJASConfig:=saJASInstallDir+'config'+csDOSSLASH+'jas.cfg';

  bWriteFile:=bFileExists(saFilenameJASConfig)=false;
  if not bWritefile then
  begin
    if MsgBox('JAS Configuration file exists. Overwrite?','Overwrite jas.cfg?',MB_YESNO)=IDYES then
    begin
      bWriteFile:=true;
    end;
  end;

  if bWriteFile then
  begin
    // OK To write out a new configuration file
    assign(f,saFilenameJASConfig);
    rewrite(f);



    writeln(f,'//==============================================================================');
    writeln(f,'//|    _________ _______  _______  ______  ______|  Jegas Application Server');
    writeln(f,'//|   /___  ___// _____/ / _____/ / __  / / _____/');
    writeln(f,'//|      / /   / /__    / / ___  / /_/ / / /____ |  Main Configuration File');
    writeln(f,'//|     / /   / ____/  / / /  / / __  / /____  / |');
    writeln(f,'//|____/ /   / /___   / /__/ / / / / / _____/ /  |');
    writeln(f,'///_____/   /______/ /______/ /_/ /_/ /______/   |');
    writeln(f,'//|                 Under the Hood               |');
    writeln(f,'//==============================================================================');
    writeln(f,'// Copyright(c)2015 Jegas, LLC - All Rights Reserved');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Optionally force only Main System To be started up.');
    writeln(f,'//==============================================================================');
    writeln(f,'//MainSystemOnly=true');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Directory Where Jegas is INSTALLED  (SYSDIR)');
    writeln(f,'//==============================================================================');
    writeln(f,'SYSDIR=/xfiles/inet/jas/jegascrm/');
    writeln(f,'//SYSDIR=c:\wfiles\code\jas\');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Name of the Server');
    writeln(f,'//==============================================================================');
    writeln(f,'// Note: ServerID must not have spaces in it NOR be long at all because it''s');
    writeln(f,'// used to build field names on external systems that synchronize with JAS.');
    writeln(f,'ServerName=Jegas CRM');
    writeln(f,'ServerIdent=JEGAS');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// SERVER URL ---- Do Not Put a Trailing Slash.');
    writeln(f,'//==============================================================================');
    writeln(f,'ServerURL=http://localhost:8080');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Server IP and PORT');
    writeln(f,'//==============================================================================');
    writeln(f,'ServerIP=127.0.0.1');
    writeln(f,'ServerPort=8080');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Main Database JEGAS DSN FILE (Jegas Proprietary DSN Format)');
    writeln(f,'//==============================================================================');
    writeln(f,'// Needs to be located in JASDir/config/');
    writeln(f,'// This is a separate file because you can have multiple database connections.');
    writeln(f,'// This file dictates what database the Jegas application runs on');
    writeln(f,'// and keeps creds tucked away - this is the "TEXT" (safer)" way. hide these');
    writeln(f,'// files in safe place !');
    writeln(f,'//==============================================================================');
    writeln(f,'DatabaseConfigFile=jas.dbc');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'//******************************************************************************');
    writeln(f,'//==============================================================================');
    writeln(f,'// The Following Settings are used to override the settings in the database');
    writeln(f,'// within JAS. Do NOT uncomment these settings unless you wish to OVERRIDE');
    writeln(f,'// the settings stored in the system.');
    writeln(f,'//==============================================================================');
    writeln(f,'//******************************************************************************');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// WhiteList');
    writeln(f,'//==============================================================================');
    writeln(f,'// Enabling the white list blocks ALL IP''s EXCEPT those granted access. Of THOSE');
    writeln(f,'// Granted Access, if they are also blacklisted, the won''t be able to get it if');
    writeln(f,'// blacklist also enabled. Blacklist "RULES". Whitelist allows basically');
    writeln(f,'// locking out the world except for the IP''s you specifically allow.');
    writeln(f,'// Note: This isn''t masquarade proof, but it''s still a nice feature.');
    writeln(f,'//==============================================================================');
    writeln(f,'//WhiteListEnabled=no');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Blacklist Enabled');
    writeln(f,'//==============================================================================');
    writeln(f,'// When BlackListEnabled=yes or true, then any Blacklist IP addresses in the');
    writeln(f,'// jiplist table are refused access to the system. Further, if someone tries to');
    writeln(f,'// login to the system with any invalid combinations of username and/or password');
    writeln(f,'// their IP address is added to the blacklist table in an effort to thwart');
    writeln(f,'// evil hackers trying to break in.');
    writeln(f,'//==============================================================================');
    writeln(f,'//BlackListEnabled=no');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// External Applications');
    writeln(f,'//==============================================================================');
    writeln(f,'//FFMPEG=/usr/local/bin/ffmpeg');
    writeln(f,'//Convert=/usr/bin/convert');
    writeln(f,'//Perl=/usr/bin/perl');
    writeln(f,'//PHP=/usr/bin/php-cgi');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// Web Page Cache Age in seconds. This is how many seconds cachable pages are');
    writeln(f,'// set to be cached by browsers.');
    writeln(f,'//==============================================================================');
    writeln(f,'//CacheMaxAgeInSeconds=3600');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// When JAS starts it need to get the desired PORT from the operating system.');
    writeln(f,'// Sometimes JAS has to wait. The CreateSocket Settings control the number');
    writeln(f,'// of retries and the delay between them before giving up and failing to run.');
    writeln(f,'//==============================================================================');
    writeln(f,'//CreateSocketRetry=60');
    writeln(f,'//CreateSocketRetryDelayInMSec=1000');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// BASIC DATABASE CONFIGURATION OVERRIDE');
    writeln(f,'//==============================================================================');
    writeln(f,'//DebugMode=secure');
    writeln(f,'//DebugServerConsoleMessagesEnabled=yes');
    writeln(f,'//DeleteLogFile=yes');
    writeln(f,'//ErrorReportingMode=secure');
    writeln(f,'//ErrorReportingSecureMessage=Please note the error number shown in this message and record it. Your system administrator can use that number to help remedy system problems.');
    writeln(f,'//HOOK_ACTION_CREATESESSION_FAILURE=');
    writeln(f,'//HOOK_ACTION_CREATESESSION_SUCCESS=');
    writeln(f,'//HOOK_ACTION_REMOVESESSION_FAILURE=');
    writeln(f,'//HOOK_ACTION_REMOVESESSION_SUCCESS=');
    writeln(f,'//HOOK_ACTION_SESSIONTIMEOUT=');
    writeln(f,'//HOOK_ACTION_VALIDATESESSION_FAILURE=');
    writeln(f,'//HOOK_ACTION_VALIDATESESSION_SUCCESS=');
    writeln(f,'//JobQEnabled=yes');
    writeln(f,'//JobQIntervalInMSec=10000');
    writeln(f,'//LogLevel=0');
    writeln(f,'//LogMessagesShowOnServerConsole=no');
    writeln(f,'//MaximumRequestHeaderLength=1500000000');
    writeln(f,'//ThreadPoolMaximumRunTimeInMSec=60000');
    writeln(f,'//MaxFileHandles=200');
    writeln(f,'//ThreadPoolNoOfThreads=1');
    writeln(f,'//ProtectJASRecords=yes');
    writeln(f,'//ClientToVICIServerIP=127.0.0.2');
    writeln(f,'//JASServertoVICIServerIP=127.0.0.1');
    writeln(f,'//LockRetriesBeforeFailure=50');
    writeln(f,'//LockRetryDelayInMSec=20');
    writeln(f,'//LockTimeoutInMinutes=30');
    writeln(f,'//RetryDelayInMSec=100');
    writeln(f,'//RetryLimit=20');
    writeln(f,'//DeleteRecordsPermanently=no');
    writeln(f,'//ServerConsoleMessagesEnabled=yes');
    writeln(f,'//SessionTimeoutInMinutes=240');
    writeln(f,'//SMTPHost=smtp.comcast.net');
    writeln(f,'//SMTPUsername=');
    writeln(f,'//SMTPPassword=');
    writeln(f,'//SocketTimeOutInMSec=12000');
    writeln(f,'//TimeZoneOffSet=-5');
    writeln(f,'//ValidateSessionRetryLimit=50');
    writeln(f,'//WebShareAlias=/jws/');
    writeln(f,'//DirectoryListing=true');
    writeln(f,'//JASFooter=jassig.jas');
    writeln(f,'//PasswordKey=147');
    writeln(f,'//CreateHybridJets=true');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// DEFAULT VHOST OVERRIDE');
    writeln(f,'//==============================================================================');
    writeln(f,'// VHost_WebRootDir');
    writeln(f,'// VHost_ServerName');
    writeln(f,'// VHost_ServerIdent');
    writeln(f,'// VHost_ServerDomain');
    writeln(f,'// VHost_ServerIP');
    writeln(f,'// VHost_ServerPort');
    writeln(f,'// VHost_DefaultLanguage');
    writeln(f,'// VHost_DefaultColorTheme');
    writeln(f,'// VHost_MenuRenderMethod');
    writeln(f,'// VHost_DefaultArea');
    writeln(f,'// VHost_DefaultPage');
    writeln(f,'// VHost_DefaultSection');
    writeln(f,'// VHost_DefaultTop_JMenu_ID');
    writeln(f,'// VHost_DefaultLoggedInPage');
    writeln(f,'// VHost_DefaultLoggedOutPage');
    writeln(f,'// VHost_DataOnRight_b');
    writeln(f,'// VHost_CacheMaxAgeInSeconds');
    writeln(f,'// VHost_SystemEmailFromAddress');
    writeln(f,'// VHost_EnableSSL_b');
    writeln(f,'// VHost_SharesDefaultDomain_b');
    writeln(f,'// VHost_DefaultIconTheme');
    writeln(f,'// VHost_DirectoryListing_b');
    writeln(f,'// VHost_DownloadDir');
    writeln(f,'// VHost_UploadDir');
    writeln(f,'// VHost_AccessLog');
    writeln(f,'// VHost_ErrorLog');
    writeln(f,'// VHost_JDConnection_ID');
    writeln(f,'// VHost_TemplateDir');
    writeln(f,'//==============================================================================');
    writeln(f,'');
    writeln(f,'//==============================================================================');
    writeln(f,'// EOF');
    writeln(f,'//==============================================================================');
    close(f);
    MsgBox('JAS Configuration file written','JAS Configuration file written: '+saFilenameJASConfig,IDOK);
  end;

  saFilenameJASDSN:=saJASInstallDir+'config'+csDOSSLASH+'database'+csDOSSLASH+'jas.dsn';
  bWriteFile:=bFileExists(saFilenameJASDSN)=false;
  if not bWritefile then
  begin
    if MsgBox('JAS DSN (Database connection) file exists. Overwrite?','Overwrite jas.dsn?',MB_YESNO)=IDYES then
    begin
      bWriteFile:=true;
    end;
  end;

  if bWriteFile then
  begin
    // OK To write out a new configuration file
    assign(f,saFilenameJASDSN);
    rewrite(f);
    
    writeln(f,';==============================================================================');
    writeln(f,';|    _________ _______  _______  ______  ______| This is a proprietary config-');
    writeln(f,';|   /___  ___// _____/ / _____/ / __  / / _____/ uration file designed for use');
    writeln(f,';|      / /   / /__    / / ___  / /_/ / / /____ | with Jegas, LLC Software');
    writeln(f,';|     / /   / ____/  / / /  / / __  / /____  / |');
    writeln(f,';|____/ /   / /___   / /__/ / / / / / _____/ /  |');
    writeln(f,';/_____/   /______/ /______/ /_/ /_/ /______/   |    http://www.jegas.com');
    writeln(f,';|         Virtually Everything IT(tm)          |');
    writeln(f,';==============================================================================');
    writeln(f,'; This file WAS not designed to be edited manually, however if you do wish to');
    writeln(f,'; edit this file manually, remember that WHITESPACE is not permitted after the');
    writeln(f,'; EQUAL (=) sign: e.g. Variable=Value  (THIS IS OK)');
    writeln(f,';                 e.g. Variable= Value (THIS IS NOT OK)');
    writeln(f,';==============================================================================');
    writeln(f,'; Copyright(c)2015 Jegas, LLC  - All Rights Reserved');
    writeln(f,';==============================================================================');
    writeln(f,'; Connection Name:         JAS');
    writeln(f,'; Connection Desc:         JAS Squadron Leader, Lead Jet, Master Database');
    writeln(f,'; Original Filename:       /xfiles/inet/jas/jegas/config/jas.dbc');
    writeln(f,'; Generated:               2012-10-28 12:17:31');
    writeln(f,'; Generating Application:  Jegas, LLC');
    writeln(f,';            EXE:          jas');
    writeln(f,';            Path:         /xfiles/inet/jas/bin/');
    writeln(f,';            Product Name: Jegas Application Server');
    writeln(f,';            Version:      0.0.1');
    writeln(f,';==============================================================================');
    writeln(f,'; DBMSID IS DBMS Dialect Selection (0=Not Set Yet)');
    writeln(f,';  1 =   Generic');
    writeln(f,';  2 =   MS-SQL');
    writeln(f,';  3 =   Access');
    writeln(f,';  4 =   MySQL');
    writeln(f,';  5 =   Excel');
    writeln(f,';  6 =   dBase');
    writeln(f,';  7 =   FoxPro');
    writeln(f,';  8 =   Oracle');
    writeln(f,';  9 =   Paradox');
    writeln(f,'; 10 =   Text');
    writeln(f,'; 11 =   PostGresSQL');
    writeln(f,'DbmsID=4');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'; DrivID is DBMS Driver ID of NON ODBC Connections.');
    writeln(f,';  1 =   ODBC');
    writeln(f,';  2 =   MySql');
    writeln(f,'DrivID=2');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'Name=JAS');
    writeln(f,'Desc=JAS Squadron Leader, Lead Jet, Master Database');
    writeln(f,'DSN=');
    writeln(f,'UserName='+saMySqlUserName);
    writeln(f,'Password='+saMySqlUserPass);
    writeln(f,'Driver=');
    writeln(f,'Server='+saMySQLHost+':'+saMySQLPort);
    writeln(f,'Database=jas_jegascrm');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,';FileBasedDSN has to do with the ODBC connection, not this file.');
    writeln(f,'FileBasedDSN=No');
    writeln(f,'; Filebased Databases are handled in this way during the actual connection:');
    writeln(f,'; FIRST:  if the the Database Variable above has a value at all, that is the');
    writeln(f,';         filename that is used for the database when the FileBased Variable');
    writeln(f,';         above is set to Yes.');
    writeln(f,'; SECOND: if the Database Variable Above is EMPTY and the FileBased Variable');
    writeln(f,';         above is set to Yes, then the FileName Variable''s value (below) is');
    writeln(f,';         used.');
    writeln(f,'; Therefore (psuedo-code to demonstrate logic):');
    writeln(f,'; IF FILEBASEDDSN = YES and DATABASENAME = SOMETHING THEN');
    writeln(f,';   DataBaseFileToOpen = SOMETHING');
    writeln(f,'; ELSE');
    writeln(f,';   DataBaseFileToOpen=DSNFILENAME''s VALUE');
    writeln(f,'; END IF');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'DSNFileName=');
    writeln(f,'');
    writeln(f,'');
    writeln(f,'');
    writeln(f,';==============================================================================');
    writeln(f,'; EOF');
    writeln(f,';==============================================================================');
    close(f);
    MsgBox('JAS DSN (Database) Configuration written','JAS DSN (database) Configuration file written:'+saFilenameJASDSN,IDOK);
  end;


  if (Msgbox('Load JAS Stock Database?','Would you like the stock JAS (jas_stock) database loaded?',MB_YESNO)=IDYES) then
  begin
    {$IFDEF WIN32}
    saFilenamePopDB:=saJASINstallDir+'database'+csDOSSLASH+'populate_database.bat';
    {$ELSE}
    saFilenamePopDB:=saJASINstallDir+'database'+csDOSSLASH+'populate_database.sh';
    {$ENDIF}

    if bFileExists(saFilenamePopDB) then
    begin
      Deletefile(saFilenamePopDB);
    end;

    assign(f,saFilenamePopDB);
    rewrite(f);
    {$IFNDEF WIN32}
    writeln(f,'#!/bin/sh');
    {$ENDIF}
    writeln(f,'mysql -u' + saMySqlRootName + ' -p'+saMySqlRootPass  + ' < '+
      saJASInstallDir+'database'+csDOSSLASH+'jas_stock.sql');
    close(f);
    {$IFNDEF WIN32}
    FpChmod(saFilenamePopDB, &744);
    {$ENDIF}
    iResult:=u2Shell(saFilenamePopDB,'');
    if iResult<>0 then
    begin
      msgbox(saFilenamePopDB+' Result:'+inttostr(iResult)+':'+saIOResult(iResult),'Trouble Loading Database',MB_OK);
    end
    else
    begin
      msgbox('Database seems to have imported Successfully!','',MB_OK);
    end;
  end;

end;
//=============================================================================










//=============================================================================
function bRunSetupStepXXDL(p_StepXXDL: JFC_XXDL):boolean;
//=============================================================================
  function bContinue: boolean;
  Var 
    rSageMsg: rtSageMsg;
  begin
    result:=Getmessage(rSageMsg) and gWinEx.Visible;
    if result then DispatchMessage(rSageMsg);
  end;


var StepBookMarkN: longint;
    saCmd: ansistring;    
    TK: JFC_TOKENIZER;
    bOk: boolean;
    iResult: integer;
    saParameters: ansistring;
    saErrMsg: ansistring;
    CurItem: JFC_XXDLITEM;
    TestItem: JFC_XXDLITEM;
    BranchItem: JFC_XXDLITEM;
    bResult: boolean;
    saSrc: ansistring;
    saDest: ansistring;
    u2IOResult: word;
    saFileData: ansistring;  
    f: text;


label top;

begin
  TK:= JFC_TOKENIZER.Create;
  gbModal:=true;
  WinLogo.WindowState:=WS_MINIMIZED;
  
  gWinEx.AlwaysOnTop:=true;
  gWinEx_PBARMain.MaxValue:=p_StepXXDL.ListCount;
  gWinEx.Visible:=true;
  gWinEx.SetFocus;
  
  if p_StepXXDL.MoveFirst then
  begin
    bOk:=true;
    repeat 
top: 
      gWinEx.Caption:=p_StepXXDL.saClassName;
      gWinEx_PBARMain.Value:=p_StepXXDL.N;      
      gWinEx_lbl01.Caption:='Processing Step '+inttostr(p_StepXXDL.N)+' of '+ inttostr(p_StepXXDL.listcount);
      gWinEx_lbl02.Caption:='Step: '+p_StepXXDL.Item_saName;
      gWinEX_btnCancel.Caption:='&Cancel';
      gWinEx.bRedraw:=true;
      gWinEx.PaintWindow;
      grGfxOps.bUpdateConsole:=true;
      
      // Begin---------JFC_XXDLITEM
      //   Note: The Token Replacement works by putting Item_saValue's from 
      //   and and all steps into the the data of the current step 
      //   when tokens set up like [#NAMEOFSTEPTOGETDATAFROM#] are encountered.
      //   basic SNR (Search-n-replace) is performed. Only Item_saValue's are used for this
      //   population of coded tokens.
      // 
      //   saName: Name of Step
      //   i8User: Command
      case p_StepXXDL.Item_i8User of

      //----------------------
      SS_NOP:;// No Operation
      //     SS_INPUT 1 = InputBox
      //          saDesc: Prompt
      //          saValue: Data In/Out
      //          ID1: MaxLength
      //          ID2: Flags (ZERO - as no flags for inputbox yet)
      //          ID3: 
      //          ID4: 
      SS_INPUT: begin // inputbox
        p_StepXXDL.Item_saValue:=Inputbox(p_StepXXDL.Item_saDesc, p_StepXXDL.Item_saValue, p_StepXXDL.Item_ID1,p_StepXXDL.Item_ID2);
      end;  
      //----------------------

      //----------------------
      //      SS_MSGBOX 2 = Msgbox - This is SNR's like SS_COPYFILESNR - but doesn't do a SS_CONSTANT pass, just a SS_CONSTANTFINAL pass
      //          saDesc: Prompt
      //          saValue: Caption
      //          ID1: Result
      //          ID2: Flags like MB_OK
      //          ID3: 
      //          ID4: 
      SS_MSGBOX: begin // msgbox 
        StepBookMarkN:=p_StepXXDL.N;
        saCmd:=p_StepXXDL.Item_saValue;//caption
        saSrc:=p_StepXXDL.Item_saDesc;//prompt
        
        // pass #1
        p_StepXXDL.MoveFirst;
        repeat
          saCmd:=saSNRStr(saCmd,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        
        p_StepXXDL.MoveFirst;
        repeat
          saSrc:=saSNRStr(saSrc,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        
        // pass #2        
        p_StepXXDL.MoveFirst;
        repeat
          if p_StepXXDL.Item_i8User=SS_CONSTANTFINAL then
          begin
            saCmd:=saSNRStr(saCmd,p_StepXXDL.Item_saName, p_StepXXDL.Item_saValue);
          end;
        until not p_StepXXDL.MoveNext;
        
        p_StepXXDL.MoveFirst;
        repeat
          if p_StepXXDL.Item_i8User=SS_CONSTANTFINAL then
          begin
            saSrc:=saSNRStr(saSrc,p_StepXXDL.Item_saName, p_StepXXDL.Item_saValue);
          end;  
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);
        p_StepXXDL.Item_ID1:=MsgBox(saCmd,saSrc, p_StepXXDL.Item_ID2);
      end;
      //----------------------

      //----------------------
      //      SS_SHELL 3 = Execute Outside Process (Note - command line gets SNR'd with saVALUE from entire XXDL before execution! Result of process execution placed in saValue.
      //          saDesc: Command
      //          saValue: Command line Parameters
      //          ID1: 0=Result Code
      //          ID2: Minimum allowed result code
      //          ID3: Maximum Allowed Result code
      //          ID4: 
      SS_SHELL: begin // execute external process
        StepBookMarkN:=p_StepXXDL.N;
        saCmd:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saCmd:=saSNRStr(saCmd,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);
        
        saParameters:=p_StepXXDL.Item_saValue;
        p_StepXXDL.MoveFirst;
        repeat
          saParameters:=saSNRStr(saParameters,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;

        p_StepXXDL.FoundNth(StepBookMarkN);
        iResult:=u2Shell(saCmd,saParameters);
        DoneMouse;
        InitMouse;
        RedrawConsole;
        bOk:=((iResult>=p_StepXXDL.Item_ID2) and (iResult<=p_StepXXDL.Item_ID3)) or 
             (((iResult-32768)>=p_StepXXDL.Item_ID2) and ((iResult-32768)<=p_StepXXDL.Item_ID3));
        if not bOk then
        begin
          saerrMsg:='Error returned from Shell operation: (cmd)' + saCmd + ' (param)'+saParameters+' Result code:'+inttostr(iResult);
          if(iResult>=32768) then
          begin
            saErrMsg+=' '+saIOResult(iResult-32768,cnLanguage);
          end;
        end;
      end;
      //----------------------

      //----------------------
      //      SS_MAKEDIR 4 = CreateDir
      //          saDesc: Directory to create (With Token Replacement Performed)
      //          saValue: 
      //          ID1: 0=Failure 1=Success
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_MAKEDIR: begin //create dir
        StepBookMarkN:=p_StepXXDL.N;
        saCmd:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saCmd:=saSNRStr(saCmd,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);
        bOk:=directoryexists(saCmd) or CreateDir(saCmd);
        if not bOk then
        begin
          saErrMsg:='Error creating directory: '+saCmd+' Directory Exists:'+saTrueFalse(directoryexists(saCmd));
        end;
      end;
      //----------------------

      //----------------------
      //      SS_COMPLETED 5 = Completed Result - This is a way of storing the results of the install in the install steps list
      //                             It doesn't matter where in the steps this appears, you should have a max of one
      //                             but if you don't care about saving the result - you don't need it.
      //          saDesc: Put whatever you like here - it's not used and could help make code and script easier to understand.
      //          saValue: 
      //          ID1: 0=Not Completed Successfully 1=Process Succeeded
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_COMPLETED: begin
        // this is a special command to record final results - as such - we do nothing here but AFTER the process completes
        // this step is passed over and sought later.
      end;
      //----------------------

      //----------------------
      //  SS_ONTRUEGOTO   6 = TRUE LOGIC BRANCH - this allows the script to make decisions. This command is like "IF value=this then branch else do this"
      //          saDesc: NAME of Step to BASE Logic Branch on - If EMPTY or not Found in list - Errors Out
      //          saValue: NAME of Step to Branch to if condition met - If EMPTY or not FOUND - Process Fails with error message.
      //          ID1: Field to interogate in the JFC_XXDLITEM (1=ID1, 2=ID2, 3=ID3, 4=ID4) (If ZERO - Error Out)
      //          ID2: Value sought (Numeric)
      //          ID3: Action to perform if condition NOT met: 
      //                 0 - do nothing, fall through
      //                 1 - Fail Process
      //                 >Highest defined action = FALL THROUGH
      //          ID4: 
      //
      SS_ONTRUEGOTO: begin
        StepBookMarkN:=p_StepXXDL.N;
        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if p_StepXXDL.FoundItem_saName(CurItem.saDesc,false)=false then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: ON-TRUE-GOTO Step named "'+CurItem.saName+'" references a step to base the logic test on named "'+CurItem.saDesc+'" that could not be found in the process step list.';
        end
        else
        begin
          TestItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        end;

        if bOk then
        begin
          if p_StepXXDL.FoundItem_saName(CurItem.saValue,false)=false then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-TRUE-GOTO Step named "'+CurItem.saName+'" references a step to BRANCH TO named "'+CurItem.saDesc+'" that could not be found in the process step list.';
          end
          else
          begin
            BranchItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
          end;
        end;
        
        if bOk then
        begin
          if ((CurItem.ID[1]>=1) and (CurItem.ID[1]<=4)) = FALSE then 
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-TRUE-GOTO Step named "'+CurItem.saName+'" ID1 Field Invalid:'+inttostr(curitem.id[1])+' Should be 1-4 to point to field in step named "'+curitem.saDesc+'" to whose value is to be interrogated.';
          end;
        end;
        
        if bOk then
        begin
          // Test Result
          bResult:=TestItem.ID[CurItem.ID[1]]=CurItem.ID[2];
          if bResult then 
          begin
            // BRANCH
            p_StepXXDL.FoundItem_saName(BranchItem.saName);
            goto top;
          end
          else
          begin
            case CurItem.ID[3] of
            0: ; // fall through
            1: begin
              bOk:=false;
              saErrMsg:='Setup Script cannot proceed. ON-TRUE-GOTO Condition that failed: "'+CurItem.saName+'"';
            end;
            else
            begin
              // else just fall through
            end;
            end;//switch
          end;
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------

      //----------------------
      // SS_ONFALSEGOTO 7 = FALSE LOGIC BRANCH - this allows the script to make decisions. This command is like "IF value<>this then branch else do this"
      //          saDesc: NAME of Step to BASE Logic Branch on - If EMPTY or not Found in list - Errors Out
      //          saValue: NAME of Step to Branch to if condition NOT met - If EMPTY or not FOUND - Process Fails with error message.
      //          ID1: Field to interogate in the JFC_XXDLITEM (1=ID1, 2=ID2, 3=ID3, 4=ID4) (If ZERO - Error Out)
      //          ID2: Value sought (Numeric)
      //          ID3: Action to perform if condition NOT met: 
      //                 0 - do nothing, fall through
      //                 1 - Fail Process
      //                 >Highest defined action = FALL THROUGH
      //          ID4: 
      SS_ONFALSEGOTO: begin
        StepBookMarkN:=p_StepXXDL.N;
        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if p_StepXXDL.FoundItem_saName(CurItem.saDesc,false)=false then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: ON-FALSE-GOTO Step named "'+CurItem.saName+'" references a step to base the logic test on named "'+CurItem.saDesc+'" that could not be found in the process step list.';
        end
        else
        begin
          TestItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        end;

        if bOk then
        begin
          if p_StepXXDL.FoundItem_saName(CurItem.saValue,false)=false then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-FALSE-GOTO Step named "'+CurItem.saName+'" references a step to BRANCH TO named "'+CurItem.saDesc+'" that could not be found in the process step list.';
          end
          else
          begin
            BranchItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
          end;
        end;
        
        if bOk then
        begin
          if ((CurItem.ID[1]>=1) and (CurItem.ID[1]<=4)) = FALSE then 
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-FALSE-GOTO Step named "'+CurItem.saName+'" ID1 Field Invalid:'+inttostr(curitem.id[1])+' Should be 1-4 to point to field in step named "'+curitem.saDesc+'" to whose value is to be interrogated.';
          end;
        end;
        
        if bOk then
        begin
          // Test Result
          bResult:=TestItem.ID[CurItem.ID[1]]=CurItem.ID[2];
          if bResult = FALSE then // Here's the big difference between command #6 and Command #7
          begin
            // BRANCH
            p_StepXXDL.FoundItem_UID(BranchItem.UID);
            goto top;
          end
          else
          begin
            case CurItem.ID[3] of
            0: ; // fall through
            1: begin
              bOk:=false;
              saErrMsg:='Setup Script cannot proceed. ON-FALSE-GOTO Condition that failed: "'+CurItem.saName+'"';
            end;
            else
            begin
              // else just fall through
            end;
            end;//switch
          end;
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------

      //----------------------
      //      SS_ONFILEEXISTGOTO 8 = File Exist Branch - this allows the script to branch if a file exists This command is like "IF filexists<>this then branch else do this"
      //          saDesc: Filename to test for - (token replacement performed) If EMPTY Errors Out
      //          saValue: NAME of Step to Branch to if condition NOT met - If EMPTY or not FOUND - Process Fails with error message.
      //          ID1: Field to interogate in the JFC_XXDLITEM (1=ID1, 2=ID2, 3=ID3, 4=ID4) (If ZERO - Error Out)
      //          ID2: 
      //          ID3: Action to perform if condition NOT met: 
      //                 0 - do nothing, fall through
      //                 1 - Fail Process
      //                 >Highest defined action = FALL THROUGH
      //          ID4: 
      SS_ONFILEEXISTGOTO: begin
        StepBookMarkN:=p_StepXXDL.N;

        saCmd:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saCmd:=saSNRStr(saCmd,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);



        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if length(saCmd)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: ON-FILE-EXIST-GOTO Step named "'+CurItem.saName+'" contains and empty filename parameter: "'+saCmd+'"';
        end;

        if bOk then
        begin
          if p_StepXXDL.FoundItem_saName(CurItem.saValue,false)=false then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-FILE-EXIST-GOTO Step named "'+CurItem.saName+'" references a step to BRANCH TO named "'+CurItem.saValue+'" that could not be found in the process step list.';
          end
          else
          begin
            BranchItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
          end;
        end;
        
        if bOk then
        begin
          if ((CurItem.ID[1]>=1) and (CurItem.ID[1]<=4)) = FALSE then 
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-FILE-EXIST-GOTO Step named "'+CurItem.saName+'" ID1 Field Invalid:'+inttostr(curitem.id[1])+' Should be 1-4 to point to field in step named "'+curitem.saDesc+'" to whose value is to be interrogated.';
          end;
        end;
        
        if bOk then
        begin
          // Test Result
          bResult:=fileexists(saCmd);
          if bResult then // Here's the big difference between command #6 and Command #7
          begin
            // BRANCH
            p_StepXXDL.FoundItem_UID(BranchItem.UID);
            goto top;
          end
          else
          begin
            case CurItem.ID[3] of
            0: ; // fall through
            1: begin
              bOk:=false;
              saErrMsg:='Setup Script cannot proceed. Step "'+CurItem.saName+'" Requires that the file named "'+saCmd+'" must exist. Please check file exists and security permissions.';
            end;
            else
            begin
              // else just fall through
            end;
            end;//switch
          end;
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------

      //----------------------
      //      SS_ONDIREXISTGOTO 9 = File Exist Branch - this allows the script to branch if a file exists This command is like "IF filexists<>this then branch else do this"
      //          saDesc: DIR to test for - (token replacement performed) If EMPTY Errors Out
      //          saValue: NAME of Step to Branch to if condition NOT met - If EMPTY or not FOUND - Process Fails with error message.
      //          ID1: 
      //          ID2: 
      //          ID3: Action to perform if condition NOT met: 
      //                 0 - do nothing, fall through
      //                 1 - Fail Process
      //                 >Highest defined action = FALL THROUGH
      //          ID4: 
      SS_ONDIREXISTGOTO: begin
        StepBookMarkN:=p_StepXXDL.N;
        saCmd:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saCmd:=saSNRStr(saCmd,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);

        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if length(saCmd)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: ON-DIR-EXIST-GOTO Step named "'+CurItem.saName+'" contains and empty directory parameter: "'+saCmd+'"';
        end;

        if bOk then
        begin
          if p_StepXXDL.FoundItem_saName(CurItem.saValue,false)=false then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: ON-DIR-EXIST-GOTO Step named "'+CurItem.saName+'" references a step to BRANCH TO named "'+CurItem.saValue+'" that could not be found in the process step list.';
          end
          else
          begin
            BranchItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
          end;
        end;
        
        if bOk then
        begin
          // Test Result
          bResult:=directoryexists(saCmd);
          if bResult then // Here's the big difference between command #6 and Command #7
          begin
            // BRANCH
            p_StepXXDL.FoundItem_UID(BranchItem.UID);
            goto top;
          end
          else
          begin
            case CurItem.ID[3] of
            0: ; // fall through
            1: begin
              bOk:=false;
              saErrMsg:='Setup Script cannot proceed. Step "'+CurItem.saName+'" Requires that the directory named "'+saCmd+'" must exist. Please check if directory exists and security permissions are set properly.';
            end;
            else
            begin
              // else just fall through
            end;
            end;//switch
          end;
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------

      //----------------------
      //      SS_COPYFILE 10 = Copy File 
      //          saDesc: SOURCE FILE
      //          saValue: Destination File
      //          ID1: 0=failed 1=success
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_COPYFILE: begin
        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        StepBookMarkN:=p_StepXXDL.N;

        saSrc:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saSrc:=saSNRStr(saSrc,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);

        if length(saSrc)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: COPY-FILE Step named "'+CurItem.saName+'" contains and empty source filename parameter: "'+saSrc+'"';
        end;

        if bOk then
        begin
          saDest:=p_StepXXDL.Item_saValue;
          p_StepXXDL.MoveFirst;
          repeat
            saDest:=saSNRStr(saDest,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
          until not p_StepXXDL.MoveNext;
          p_StepXXDL.FoundNth(StepBookMarkN);
  
          if length(saDest)=0 then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: COPY-FILE Step named "'+CurItem.saName+'" contains and empty destination filename parameter: "'+saSrc+'"';
          end;
        end;

        if bOk then
        begin
          bResult:=bCopyFile(saSrc,saDest, u2IOResult) and fileexists(saDest);
          if not bResult then // Here's the big difference between command #6 and Command #7
          begin
            bOk:=false;
            saErrMsg:='Unable to Copy source file "'+saSrc+'" to destination "'+saDest+'" in step named "'+CurItem.saName+'" IO Result: '+saIOResult(u2IOResult);
          end
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------
      
      //----------------------
      //      SS_MOVEFILE 11 = move file
      //          saDesc: SOURCE FILE
      //          saValue: Destination File
      //          ID1: 0=failed 1=success
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_MOVEFILE: begin
        StepBookMarkN:=p_StepXXDL.N;

        saSrc:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saSrc:=saSNRStr(saSrc,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);

        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if length(saSrc)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: MOVE-FILE Step named "'+CurItem.saName+'" contains and empty source filename parameter: "'+saSrc+'"';
        end;

        if bOk then
        begin
          saDest:=p_StepXXDL.Item_saDesc;
          p_StepXXDL.MoveFirst;
          repeat
            saDest:=saSNRStr(saDest,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
          until not p_StepXXDL.MoveNext;
          p_StepXXDL.FoundNth(StepBookMarkN);
  
          if length(saDest)=0 then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: MOVE-FILE Step named "'+CurItem.saName+'" contains and empty destination filename parameter: "'+saSrc+'"';
          end;
        end;

        if bOk then
        begin
          // Test Result
          bResult:=bMoveFile(saSrc,saDest,u2IOREsult) and fileexists(saDest);
          if not bResult then // Here's the big difference between command #6 and Command #7
          begin
            bOk:=false;
            saErrMsg:='Unable to Copy source file "'+saSrc+'" to destination "'+saDest+'" in step named "'+CurItem.saName+'" IO REsult:'+saIOResult(u2IOResult);
          end
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------
      
      
      //----------------------
      //      SS_DELETEFILE 12 = move file
      //          saDesc: SOURCE FILE
      //          saValue: Destination File
      //          ID1: 0=failed 1=success
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_DELETEFILE: begin
        StepBookMarkN:=p_StepXXDL.N;

        saSrc:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.MoveFirst;
        repeat
          saSrc:=saSNRStr(saSrc,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);

        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if length(saSrc)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: DELETE-FILE Step named "'+CurItem.saName+'" contains and empty filename parameter: "'+saSrc+'"';
        end;
        if bOk then
        begin
          // Test Result
          bResult:=deletefile(saSrc) and (not fileexists(saSrc));
          if not bResult then // Here's the big difference between command #6 and Command #7
          begin
            bOk:=false;
            saErrMsg:='Unable to delete file "'+saSrc+'" in step named "'+CurItem.saName+'"';
          end
        end;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------
      
      //----------------------
      //      SS_DELETEDIR 13 = move file
      //          saDesc: SOURCE FILE
      //          saValue: Destination File
      //          ID1: 0=failed 1=success
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_DELETEDIR: begin
        StepBookMarkN:=p_StepXXDL.N;
        bOk:=false;
        saErrMsg:='The Command SS_DELETEDIR is not yet implemented.';        
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------
      
      //----------------------
      //      SS_FAIL 14 = Cause Script to Fail with message
      //          saDesc: Error Message to display in progress box as to why the installation failed.
      //          saValue: 
      //          ID1:
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_FAIL: begin
        StepBookMarkN:=p_StepXXDL.N;
        bOk:=false;
        saErrMsg:=p_StepXXDL.Item_saDesc;
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------

      //----------------------
      //      SS_CONSTANT 15 = use to store values you might use for TOKEN search and replace for other commands.
      //          saDesc: 
      //          saValue: 
      //          ID1:
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_CONSTANT: begin
        // no code for this - honestly, a NOP would work the same way but having a specific command for
        // this particular purpose we can maybe extend functionality in a reasonable way - like add perhaps
        // another command like this called SS_VARIABLE - that would have mechanisms to copy to, from, 
        // manipulate etc. And this would be reserved for constants like it's name suggests.
        //
        // SS_COPYFILESNR uses this type of entry in a special way. First it loads the data in the file
        // then it searchs for all SS_CONSTANTS and replaces the NAME of the CONSTANT (if its located in saFileData)
        // with the Value. So, this way you can search for certain TEXT and replace it with the TOKEN you 
        // want to replace on the second pass it makes with data collected through the installation process.
      end;
      //----------------------

      
      //----------------------
      //      SS_COPYFILESNR 16 = use to load text files, Search-n-Replace them, and write out the finished product somewhere
      //          saDesc: Source File 
      //          saValue: Destination file
      //          ID1:
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_COPYFILESNR: begin
        StepBookMarkN:=p_StepXXDL.N;
        saSrc:=p_StepXXDL.Item_saDesc;
        //MSGBOX('Original saSrc',saSrc,MB_OK);
        p_StepXXDL.MoveFirst;
        repeat
          saSrc:=saSNRStr(saSrc,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
        until not p_StepXXDL.MoveNext;
        p_StepXXDL.FoundNth(StepBookMarkN);
        //MSGBOX('Modified saSrc',saSrc,MB_OK);

        CurItem:=JFC_XXDLITEM(p_StepXXDL.lpItem);
        if length(saSrc)=0 then
        begin
          bOk:=false;
          saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" contains and empty source filename parameter: "'+saSrc+'"';
        end;

        if bOk then
        begin
          saDest:=p_StepXXDL.Item_saValue;
          //MSGBOX('Original saDest',saDest,MB_OK);
          p_StepXXDL.MoveFirst;
          repeat
            saDest:=saSNRStr(saDest,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
          until not p_StepXXDL.MoveNext;
          p_StepXXDL.FoundNth(StepBookMarkN);
          //MSGBOX('Modified saDest',saDest,MB_OK);          
  
          if length(saDest)=0 then
          begin
            bOk:=false;
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" contains and empty destination filename parameter: "'+saSrc+'"';
          end;
        end;

        if bOk then
        begin
          //saSrc:=saSpecialSNR(saSrc,csDOSSLASH,csDOSSLASH);
          //saDest:=saSpecialSNR(saDest,csDOSSLASH,csDOSSLASH);
          //MSGBOX('Load Test File','Source:'+saSrc+' Dest:'+saDest,MB_OK);
          bOk:=bLoadTextFile(saSrc,saFileData,u2IOResult);
          if not bOk then 
          begin
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" was unable to load file: "'+saSrc+'" IO Result:'+saIOREsult(u2IOResult);
          end;
        end;
        //MSGBOX('COPYFILESNR raw saFileData',saFileData,MB_OK);
                  
        if bOk then
        begin
          p_StepXXDL.MoveFirst;
          repeat
            if p_StepXXDL.Item_i8User=SS_CONSTANT then
            begin
              saFileData:=saSNRStr(saFileData,p_StepXXDL.Item_saName, p_StepXXDL.Item_saValue);
            end;
          until not p_StepXXDL.MoveNext;
          //MSGBOX('constants saFiledata',saFileData,MB_OK);
          
          p_StepXXDL.MoveFirst;
          repeat
            saFileData:=saSNRStr(saFileData,'[#'+p_StepXXDL.Item_saName+'#]', p_StepXXDL.Item_saValue);
          until not p_StepXXDL.MoveNext;
          
          // SS_CONSTANTFINAL - Second PASS so These Constants have last word
          p_StepXXDL.MoveFirst;
          repeat
            if p_StepXXDL.Item_i8User=SS_CONSTANTFINAL then
            begin
              saFileData:=saSNRStr(saFileData,p_StepXXDL.Item_saName, p_StepXXDL.Item_saValue);
            end;
          until not p_StepXXDL.MoveNext;
          
          
          
          p_StepXXDL.FoundNth(StepBookMarkN);
          //MSGBOX('snr saFileData',saFileData,MB_OK);
          FILEMODE:=WRITE_ONLY;
          {$I-}
          assign(f,saDest);
          {$I+}
          u2IOREsult:=ioresult;
          
          bOk:=(u2IOREsult=0);
          if not bOk then
          begin
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" was unable to assign file handle for "'+saDest+'" IO Result:'+saIOREsult(u2IOResult);
          end;
        end;
        
        //MSGBOX('COPYFILESNR','PART 6',MB_OK); 
        if bOk then
        begin
          {$I-}
          rewrite(f);
          {$I+}
          u2IOREsult:=ioresult;
          bOk:=(u2IOREsult=0);
          if not bOk then
          begin
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" was unable to open for write file named "'+saDest+'" IO Result:'+saIOREsult(u2IOResult);
          end;
        end;            
        
        
        //MSGBOX('COPYFILESNR','PART 9',MB_OK); 
        if bOk then
        begin
          {$I-}
          write(f,saFileData);
          {$I+}
          u2IOREsult:=ioresult;
          bOk:=(u2IOREsult=0);
          if not bOk then
          begin
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" was unable to write to file named "'+saDest+'" IO Result:'+saIOREsult(u2IOResult);
          end;
        end;            
            
        //MSGBOX('COPYFILESNR','PART 10',MB_OK); 
        if bOk then
        begin
          {$I-}
          close(f);
          {$I+}
          u2IOREsult:=ioresult;
          bOk:=(u2IOREsult=0);
          if not bOk then
          begin
            saErrMsg:='Setup Script Failure: COPY-FILE-SNR Step named "'+CurItem.saName+'" was unable to close this file:"'+saDest+'" IO Result:'+saIOREsult(u2IOResult);
          end;
        end;            
        p_StepXXDL.FoundNth(StepBookMarkN);
      end;
      //----------------------
      
      
      
      
      //----------------------
      //      SS_CONSTANTFINAL 17 = use to store values you might use for TOKEN search and replace for other commands.
      //          saDesc: 
      //          saValue: 
      //          ID1:
      //          ID2: 
      //          ID3: 
      //          ID4: 
      SS_CONSTANTFINAL: begin
        // no code for this - honestly, a NOP would work the same way but having a specific command for
        // this particular purpose we can maybe extend functionality in a reasonable way - like add perhaps
        // another command like this called SS_VARIABLE - that would have mechanisms to copy to, from, 
        // manipulate etc. And this would be reserved for constants like it's name suggests.
        //
        // SS_COPYFILESNR uses this type of entry in a special way. First it loads the data in the file
        // then it searchs for all SS_CONSTANTS and replaces the NAME of the CONSTANT (if its located in saFileData)
        // with the Value. This differs from SS_CONSTANTS in that these are used for the final pass of the SNR process
        // so you can remove double // slashes from dynamically made paths etc.
      end;
      //----------------------
      end;//switch

      gWinEx.bRedraw:=true;
      gWinEx.SetFocus;
      gWinEx.PaintWindow;
      grGfxOps.bUpdateConsole:=true;

    until (bContinue=false) or (bOk=false) or (p_StepXXDL.MoveNext=false);
    if bOk then
    begin
      if p_StepXXDL.FoundItem_i8User(5) then
      begin
        p_StepXXDL.Item_ID1:=1;// Successful Process Completion
      end;
      gWinEX.Caption:='Success!';
      gWinEx_lbl01.Caption:='Process Completed Successfully!';
      gWinEx_lbl02.Caption:='All '+inttostr(p_StepXXDL.ListCount) + ' steps completed without errors.';
      gWinEx_btnCancel.Caption:='Done';
      gWinEx.bRedraw:=true;
      gWinEx.SetFocus;
      gWinEx.PaintWindow;
      grGfxOps.bUpdateConsole:=true;
      while bContinue do;
    end
    else
    begin
      gWinEX.Caption:='ERROR OCCURRED';
      gWinEx_lbl01.Caption:='Processing Step '+inttostr(p_StepXXDL.N)+' of '+ inttostr(p_StepXXDL.listcount);
      gWinEx_lbl02.Caption:='Result: '+saErrMsg;
      gWinEx.bRedraw:=true;
      gWinEx.SetFocus;
      gWinEx.PaintWindow;
      grGfxOps.bUpdateConsole:=true;
      while bContinue do;
    end;
  end
  else
  begin
    MsgBox('Problem','The List of steps to perform for this operation is empty.',MB_OK);
  end;
  gbModal:=false;
  gWinEx.Visible:=false;
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================





Function MainMsgHandler(p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
  Case p_rSageMsg.uMsg Of
  MSG_UNHANDLEDKEYPRESS: Begin
  End;

  MSG_UNHANDLEDMOUSE: Begin
  End;

  MSG_BUTTONDOWN: Begin
  End;

  MSG_MENU: Begin
    //grGFXops.b pDateConsole:=True;
    Case p_rSageMsg.uParam1 Of
    mnuSetupJAS: begin
      if bRunSetupStepXXDL(JASSetupXXDL) then
      begin
        WriteJASConfigFiles;
      end;
    end;

    mnuExit: begin
      With p_rSageMsg Do Begin
        uMsg   := MSG_SHUTDOWN;
        uParam1:= 0;
        uParam2:= 0;
        uObjType:= 0;
        lpptr:=nil;
        //saSender:='USER';
      End;//with
      PostMessage(p_rSageMsg);
    End;
    End; // case
  End;
  End; //case

  Result:=0;
End;
//=============================================================================



//=============================================================================
Function dbmsloginHandler(p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
begin
  // SUGAR CRM Database credentials
  Case p_rSageMsg.uMsg Of
  MSG_BUTTONDOWN: begin
    if p_rSageMsg.uParam2=gWinDBMS_btnOk.UID then
    begin
      Con.CloseCon;
      Con.u2DbmsID:=cnDBMS_MySQL;
      Con.u2DrivID:=cnDriv_MySQL;
      Con.saUserName:=gWinDBMS_inpUser.Data;
      Con.saPassword:=gWinDBMS_inpPassword.Data;
      Con.saServer:=gWinDBMS_inpHost.Data;
      Con.saDatabase:=gWinDBMS_inpDatabase.Data;
      if Con.OpenCon then
      begin
        MsgBox('Connection Made!','Excellent!',MB_OK);
        gbModal:=false;
        gWinDBMS.SetFocus;
        gWinDBMS.Visible:=false;
      end
      else
      begin
        MsgBox('Unable to Connect.',
          'Unable to make connection to database. '+
          'User: '+Con.saUserName+' '+
          'Server: '+Con.saServer+' '+
          'Database: '+Con.saDatabase+' '
          ,MB_OK);
          gbModal:=false;
          gWinDBMS.SetFocus;
          gWinDBMS.Visible:=false;
      end;
    end;
  end;//case
  end;//switch
  result:=0;
end;
//=============================================================================


//=============================================================================
procedure CreateDMBSLoginWindow;
//=============================================================================
var i4YPos: longint;
    i4LblX: longint;
    i4InpX: longint;
begin
  grCW.saCaption:='';
  grCW.Width:=40;
  grCW.Height:=10;
  grCW.X:=iPlotCenter(giConsoleWidth,grCW.Width);
  grCW.Y:=iPlotCenter(giConsoleHeight,grCW.Height);
  grCW.bFrame:=True;
  grCW.WindowState:=WS_NORMAL;
  grCW.bCaption:=True;
  grCW.bMinimizeButton:=False;
  grCW.bMaximizeButton:=False;
  grCW.bCloseButton:=False;
  grCW.bSizable:=False;
  grCW.bVisible:=false;
  grCW.bEnabled:=True;
  grCW.lpfnWndProc:=@dbmsloginHandler;
  grCW.bAlwaysOnTop:=True;
  gWinDBMS:=TWindow.create(grCW);

  i4YPos:=3;
  i4LblX:=3;
  i4InpX:=20;

  gWinDBMS_lblUser:=tctlLabel.create(gWinDBMS);
  gWinDBMS_lblUser.X:=i4LblX;
  gWinDBMS_lblUser.Y:=i4YPos;
  gWinDBMS_lblUser.Width:=20;
  gWinDBMS_lblUser.Height:=1;
  gWinDBMS_lblUser.Caption:='Username';
  gWinDBMS_lblUser.Enabled:=True;
  gWinDBMS_lblUser.Visible:=True;

  gWinDBMS_inpUser:=tctlInput.create(gWinDBMS);
  gWinDBMS_inpUser.X:=i4InpX;
  gWinDBMS_inpUser.Y:=i4YPos;
  gWinDBMS_inpUser.width:=20;
  gWinDBMS_inpUser.maxlength:=255;
  gWinDBMS_inpUser.Data:='';
  
  i4YPos+=1;
  
  gWinDBMS_lblPassword:=tctlLabel.create(gWinDBMS);
  gWinDBMS_lblPassword.X:=i4LblX;
  gWinDBMS_lblPassword.Y:=i4YPos;
  gWinDBMS_lblPassword.Width:=20;
  gWinDBMS_lblPassword.Height:=1;
  gWinDBMS_lblPassword.Caption:='Password';
  gWinDBMS_lblPassword.Enabled:=True;
  gWinDBMS_lblPassword.Visible:=True;

  gWinDBMS_inpPassword:=tctlInput.create(gWinDBMS);
  gWinDBMS_inpPassword.X:=i4InpX;
  gWinDBMS_inpPassword.Y:=i4YPos;
  gWinDBMS_inpPassword.width:=20;
  gWinDBMS_inpPassword.maxlength:=255;
  gWinDBMS_inpPassword.Data:='';
  gWinDBMS_inpPassword.IsPassword:=true;

  i4YPos+=1;
  
  gWinDBMS_lblHost:=tctlLabel.create(gWinDBMS);
  gWinDBMS_lblHost.X:=i4LblX;
  gWinDBMS_lblHost.Y:=i4YPos;
  gWinDBMS_lblHost.Width:=20;
  gWinDBMS_lblHost.Height:=1;//allow room for buttons
  gWinDBMS_lblHost.Caption:='Host:Port';
  gWinDBMS_lblHost.Enabled:=True;
  gWinDBMS_lblHost.Visible:=True;

  gWinDBMS_inpHost:=tctlInput.create(gWinDBMS);
  gWinDBMS_inpHost.X:=i4InpX;
  gWinDBMS_inpHost.Y:=i4YPos;
  gWinDBMS_inpHost.width:=20;
  gWinDBMS_inpHost.maxlength:=255;
  gWinDBMS_inpHost.Data:='';

  i4YPos+=1;
  
  gWinDBMS_lblDatabase:=tctlLabel.create(gWinDBMS);
  gWinDBMS_lblDatabase.X:=i4LblX;
  gWinDBMS_lblDatabase.Y:=i4YPos;
  gWinDBMS_lblDatabase.Width:=20;
  gWinDBMS_lblDatabase.Height:=1;
  gWinDBMS_lblDatabase.Caption:='Database';
  gWinDBMS_lblDatabase.Enabled:=True;
  gWinDBMS_lblDatabase.Visible:=True;

  gWinDBMS_inpDatabase:=tctlInput.create(gWinDBMS);
  gWinDBMS_inpDatabase.X:=i4InpX;
  gWinDBMS_inpDatabase.Y:=i4YPos;
  gWinDBMS_inpDatabase.width:=20;
  gWinDBMS_inpDatabase.maxlength:=255;
  gWinDBMS_inpDatabase.Data:='';

  i4YPos+=2;
  
  gWinDBMS_btnOk:=tCtlButton.create(gWinDBMS);
  gWinDBMS_btnOk.Caption:='Ok';
  gWinDBMS_btnOk.X:=10;
  gWinDBMS_btnOk.Y:=i4YPos;
  gWinDBMS_btnOk.Width:=8;
  gWinDBMS_btnOk.Enabled:=true;
  
  gWinDBMS_btnCancel:=tCtlButton.create(gWinDBMS);
  gWinDBMS_btnCancel.Caption:='Cancel';
  gWinDBMS_btnCancel.X:=25;
  gWinDBMS_btnCancel.Y:=i4YPos;
  gWinDBMS_btnCancel.Width:=8;
  gWinDBMS_btnCancel.Enabled:=true;
  
end;
//=============================================================================





//=============================================================================
Function WinExHandler(p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
begin
  Case p_rSageMsg.uMsg Of
  MSG_BUTTONDOWN: begin
    if p_rSageMsg.uParam2=gWinEx_btnCancel.UID then
    begin
      gWinEx.Visible:=false;
    end
    else
    begin
    end;
  end; 
  MSG_WINPAINTVCB4CTL: begin
  end;
  else
  begin
    //JLog(cnLog_Debug,201003132219,MsgToText(p_rSageMsg),SOURCEFILE);
  end;
  end;//switch
  result:=0;
end;
//=============================================================================



//=============================================================================
procedure CreateWinExWindow;
//=============================================================================
var i4YPos: longint;
    i4LblX: longint;
begin
  grCW.saCaption:='';
  grCW.Width:=76;
  grCW.Height:=20;
  grCW.X:=iPlotCenter(giConsoleWidth,grCW.Width);
  //grCW.Y:=iPlotCenter(giConsoleHeight,grCW.Height);
  grCW.Y:=3;
  grCW.bFrame:=True;
  grCW.WindowState:=WS_NORMAL;
  grCW.bCaption:=True;
  grCW.bMinimizeButton:=False;
  grCW.bMaximizeButton:=False;
  grCW.bCloseButton:=False;
  grCW.bSizable:=False;
  grCW.bVisible:=false;
  grCW.bEnabled:=True;
  grCW.lpfnWndProc:=@WinExHandler;
  grCW.bAlwaysOnTop:=True;
  gWinEx:=TWindow.create(grCW);


  i4YPos:=3;
  i4LblX:=3;

  gWinEx_lbl01:=tctlLabel.create(gWinEx);
  gWinEx_lbl01.X:=i4LblX;
  gWinEx_lbl01.Y:=i4YPos;
  gWinEx_lbl01.Width:=gWinEx.Width-4;
  gWinEx_lbl01.Height:=1;
  gWinEx_lbl01.Caption:='';
  gWinEx_lbl01.Enabled:=True;
  gWinEx_lbl01.Visible:=True;
  i4YPos+=1;
  
  gWinEx_PBarMain:=tctlProgressBar.create(gWinEx);
  gWinEx_PBarMain.X:=i4LblX;
  gWinEx_PBarMain.Y:=i4YPos;
  gWinEx_PBarMain.Width:=gWinEx.Width-4;
  gWinEx_PBarMain.Visible:=True;
  i4YPos+=2;

  gWinEx_lbl02:=tctlLabel.create(gWinEx);
  gWinEx_lbl02.X:=i4LblX;
  gWinEx_lbl02.Y:=i4YPos;
  gWinEx_lbl02.Width:=gWinEx.Width-4;
  gWinEx_lbl02.Height:=10;
  gWinEx_lbl02.Caption:='';
  gWinEx_lbl02.Enabled:=True;
  gWinEx_lbl02.Visible:=True;
  i4YPos+=2;

  //gWinEx_PBar:=tctlProgressBar.create(gWinEx);
  //gWinEx_PBar.X:=i4LblX;
  //gWinEx_PBar.Y:=i4YPos;
  //gWinEx_PBar.Width:=gWinEx.Width-4;
  //gWinEx_PBar.Visible:=True;
  //i4YPos+=2;
  
  gWinEx_btnCancel:=tCtlButton.create(gWinEx);
  gWinEx_btnCancel.Caption:='Cancel';
  gWinEx_btnCancel.Width:=8;
  gWinEx_btnCancel.X:=iPlotCenter(grCW.Width,gWinEx_btnCancel.Width);
  gWinEx_btnCancel.Y:=i4YPos;
  gWinEx_btnCancel.Enabled:=true;
  
end;
//=============================================================================















//=============================================================================
Procedure CreateHelp;
//=============================================================================
begin
  WinHelpAppendToExistingTopic('[HOME]','[Installation Help]','[Installation Help]');
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,'[Installation Help]','[Back]','[HOME]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Jegas Application Server (JAS)','[JAS Setup]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  
  
  //--------------------------
  // BEGIN           JAS Setup
  //--------------------------
  WinHelpTopicXDL.AppendItem_XDL(nil,'[JAS Setup]','[Back]','[Installation Help]',0);
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'                             Not Written Yet','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  //--------------------------
  // END             JAS Setup
  //--------------------------

  WinHelpLoadListBox('[HOME]');
end;
//=============================================================================



//=============================================================================
procedure PopulateJASSetupXXDL;
//=============================================================================
begin
  with JASSetupXXDL do begin
    saClassName:='JAS - Jegas Application Server by Jegas, LLC - www.jegas.com - Setup';// name of Setup Process
    // Install?
    AppendItem_XXDL(nil,'MSGBOX01','Are you sure you wish to install JAS?','Install JAS?',SS_MSGBOX,0,MB_YESNO,0,0);
    AppendItem_XXDL(nil,'TRUE','MSGBOX01','NOP1',SS_ONTRUEGOTO,1,IDYES,0,0);
    AppendItem_XXDL(nil,'UserFail1','User opted to quit.','',SS_FAIL,0,0,0,0);
    AppendItem_XXDL(nil,'NOP1','NOP','',SS_NOP,0,0,0,0);

    AppendItem_XXDL(nil,'JASINSTALLDIR','The directory you would like JAS installed (trailing slash required):','',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'CREATEJASINSTALLDIR','[#JASINSTALLDIR#]','',SS_MAKEDIR,0,0,0,0);



    AppendItem_XXDL(nil,'MSGBOXINFO','Next we are going to decompress many files. This next step might take a few minutes.','File Copying might take awhile.',SS_MSGBOX,0,MB_OK,0,0);
    AppendItem_XXDL(nil,'DECOMPRESSFILES','NOP','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','bin', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS binaries','junzip', 'jas_0.0.4.386_bin.zip [#JASINSTALLDIR#]bin',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','software', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'bundled software','junzip', 'jas_0.0.4.386_software.zip [#JASINSTALLDIR#]software',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','cgi-bin', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS cgi-bin folder','junzip', 'jas_0.0.4.386_cgi-bin.zip [#JASINSTALLDIR#]cgi-bin',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','src', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Source Code','junzip', 'jas_0.0.4.386_src.zip [#JASINSTALLDIR#]src',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','config', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Configuration','junzip', 'jas_0.0.4.386_config.zip [#JASINSTALLDIR#]config',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','templates', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Templates','junzip', 'jas_0.0.4.386_templates.zip [#JASINSTALLDIR#]templates',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','database', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Stock database','junzip', 'jas_0.0.4.386_database.zip [#JASINSTALLDIR#]database',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','webroot', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Default Web Root folder','junzip', 'jas_0.0.4.386_webroot.zip [#JASINSTALLDIR#]webroot',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','dev', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Dev folder','junzip', 'jas_0.0.4.386_dev.zip [#JASINSTALLDIR#]dev',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','webshare', '',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS Support files for the HTML UI','junzip', 'jas_0.0.4.386_webshare.zip [#JASINSTALLDIR#]webshare',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'make dir','php','',SS_MAKEDIR,0,0,0,0);
    AppendItem_XXDL(nil,'JAS PHP Integration - allows writing JAS applications in PHP.','junzip', 'jas_0.0.4.386_php.zip [#JASINSTALLDIR#]php',SS_SHELL,0,0,0,0);



    {$IFDEF WIN32}
    // Have MySQL
    AppendItem_XXDL(nil,'MSGBOX02','Do you have MySQL already installed? MySQL is required by JAS.','MySQL Installed?',SS_MSGBOX,0,MB_YESNO,0,0);
    AppendItem_XXDL(nil,'TRUE','MSGBOX02','STARTCONFIG',SS_ONTRUEGOTO,1,IDYES,0,0);

    // If not, do you want us to launch the MySQL Installer?
    AppendItem_XXDL(nil,'MSGBOX03','Do you wish to install MySQL?','Install MySQL?',SS_MSGBOX,0,MB_YESNO,0,0);
    AppendItem_XXDL(nil,'TRUE','MSGBOX03','STARTCONFIG',SS_ONFALSEGOTO,1,IDYES,0,0);
    AppendItem_XXDL(nil,'Launch MySQL Installation.','[#JASINSTALLDIR#]\software\win32\mysql\Setup_mysql-5.2.3-falcon-alpha-win32.exe', '',SS_SHELL,0,0,0,0);
    AppendItem_XXDL(nil,'MSGBOX04','Only continue HERE after your MySQL installation has finished.','Waiting for your MySQL Installation to Finish',SS_MSGBOX,0,MB_YESNO,0,0);
    {$ENDIF}

    AppendItem_XXDL(nil,'STARTCONFIG','config','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLHOST','MySQL Host:','localhost',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLPORT','MySQL port:','3306',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLROOTNAME','MySQL root Username','root',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLROOTPASS','MySQL root password [!!! WARNING - PASSWORD VISIBLE !!! ]','',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLUSERNAME','MySQL JAS Username','jas',SS_INPUT,0,0,0,0);
    AppendItem_XXDL(nil,'MYSQLUSERPASS','MySQL JAS password [!!! WARNING - PASSWORD VISIBLE !!! ]','',SS_INPUT,0,0,0,0);

    AppendItem_XXDL(nil,'NOP','NOP','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'NOP','NOP','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'NOP','NOP','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'NOP','NOP','',SS_NOP,0,0,0,0);
    AppendItem_XXDL(nil,'COMPLETED','','',SS_COMPLETED,0,0,0,0);
  end;//with
end;
//=============================================================================





//=============================================================================
Procedure InitProgram;
//=============================================================================
var
  u4Menu: cardinal;
Begin
  gbMenuEnabled:=true;
  u4Menu:=AddMenuBarItem('&Setup',True);
  AddMenuPopUpItem(u4Menu,'&Jegas Application Server',True,mnuSetupJAS);
  AddMenuPopUpItem(u4Menu,'-',True,0);
  AddMenuPopUpItem(u4Menu,'E&xit',True,mnuExit);
  
  //u4Menu:=AddMenuBarItem('&Utilities',true);
  //AddMenuPopUpItem(u4Menu,'E&xecute Job',false,mnuExecute);
  
  CreateDMBSLoginWindow;
  CreateWinExWindow;
  CreateHelp;  

  JASSetupXXDL:=JFC_XXDL.Create;
  PopulateJASSetupXXDL;
End;
//=============================================================================


//=============================================================================
Procedure RunApplication;
//=============================================================================
Var 
  rSageMsg: rtSageMsg;
Begin
  While Getmessage(rSageMsg) do begin
      DispatchMessage(rSageMsg);
  end;//while
End;
//=============================================================================


//=============================================================================
Procedure DoneProgram;
//=============================================================================
begin
  gWinDBMS.Destroy;
  JASSetupXXDL.Destroy;
  DoneSageUI;
end;
//=============================================================================










//=============================================================================
// Main
//=============================================================================
procedure Main;
var bOk: boolean;
begin
  with grJegasCommon do begin
    saAppTitle:='JAS Setup Utility';//<application title
    saAppProductName:='JAS';
    saAppMajor:='0';
    saAppMinor:='0';
    saAppRevision:='4';
  end;//with  
  with grJegasCommon do begin
    JegasLogoSplash(
      saAppTitle,
      saAppProductName+' Version: '+saAppMajor+'.'+saAppMinor+'.'+saAppRevision, 
      'By: Jason P Sage',
      'jasonpsage@jegas.com',
      'http://www.jegas.com'
    );
  end;//with
  
  bOk:=InitSageUI(@MainMsgHandler);
  if not bOk then
  begin
    JLog(cnLog_Fatal,201003022123,'setup - InitSageUI create Failed',sourcefile);
    writeln('Internal Error: Unable to start SageUI');
  end;
  
  if bOk then 
  begin
    InitProgram; 
    RunApplication;
    DoneProgram;    
  End
  Else
  Begin
    JLog(cnLog_Fatal,201003022123,'setup - Unable to initialize user interface',sourcefile);
  End;
end;
//=============================================================================





//=============================================================================
// Program Starts Here
//=============================================================================
Begin
  Main;
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
