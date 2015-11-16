{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  Jason@jegas.com             |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|        Virtually Everything IT(tm)                                          |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}
// !@! - Find Category Routine Definitions
// !#! - Find Categorized Routine Source Code


//=============================================================================
{}
Unit ug_jegas;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jegas.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE DIAGNOSTICMESSAGES}
{$IFDEF DIAGNOSTICMESSAGES}
  {$INFO | DIAGNOSTICMESSAGES: TRUE}
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
  classes,
  base64,
  variants,
  ug_misc,
  ug_common,
  ug_jfc_dir,
  ug_jfc_xdl,
  ug_jfc_tokenizer,
  ug_tsfileio,
  process,
  sysutils,
  dos;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//=============================================================================



//=============================================================================
// IOAppendLog 
//=============================================================================
{}
// Alternate Temp Value for quotes found
Const cs_IOAppendLog_QuoteBeginTemp='[JQUOTE_BEGIN]'; 

// Alternate Temp Value for quotes found
Const cs_IOAppendLog_QuoteEndTemp='[JQUOTE_END]'; 


Type rtIOAppendLog = Record
  bLoggingDisabled: Boolean; {< Set to TRUE to Disable Logging for THIS 
                              instance of rtIOAppendLog - PERIOD}
  
  u2LogType_ID: word;        {< this allows you control what "log Levels"
                              get filtered - 0 means nothing, 1 Debug,
                              2-Fatal, 3-Err, 4=warn 5=info,  so you
                              use these, or start your own - each log file
                              can have its own - "set" - Jegas uses some
                              out the box. 
                             
                              Defined in i_jegas_macros.pp are these
                              defines.
                              0:= NO Logging [default]
                              The rest - you should look in the file
                              stated above.}
                             
  bSendColumnHeadersAsFirstRow: Boolean;
  
  saFilename: AnsiString;
  saQuoteBegin: AnsiString; {< Use to denote how you want the left Quote
                             to appear on text based columns. }
  saQuoteEnd: AnsiString;  {< Use to denote how you want the right Quote
                             to appear on text based columns. If this
                             is empty, then saQuoteBegin will be used 
                             to terminate the string in the output.}
  saQuoteBeginEsc: AnsiString; {< This is the text that is to REPLACE instances
                           of saQuoteBegin WHEN they are found in passed
                           string data.}
  saQuoteEndEsc: AnsiString; {< This is the text that is to REPLACE instances
                           of saQuoteEnd WHEN they are found in passed
                           string data.}
  saDateQuoteBegin: AnsiString; {< Same as Text Quotes, but for Dates.
     Some DBMS apps and the like prefer Dates like #2006-05-03# or whatever}
  saDateQuoteEnd: AnsiString;//< if empty, saDateQuoteBegin value is used
  saDateFormat: AnsiString; //< See ixx_jegas_macros.pp for some more info.
  iColumns: Longint; //< YOU MUST SET THIS to <= # of arColumns(x) you declare!
  arColumns: array Of rtJegasField;//was rtJegasColumn
  iLogEntries_Total: LongInt;//< Total count, incremented each time a specific log is written to
  iLogEntries_NONE: LongInt; //<DEFAULT LOGGING LEVEL
  iLogEntries_DEBUG: LongInt;//< 1
  iLogEntries_FATAL: LongInt;//< 2
  iLogEntries_ERROR: LongInt;//< 3
  iLogEntries_WARN: LongInt; //< 4
  iLogEntries_INFO: LongInt; //< 5
  iLogEntries_RESERVED: LongInt;//< 6   RESERVED by JEGAS 6 thru 99}
  iLogEntries_USERDEFINED: LongInt;//< 100  USER CODES 100 thru 255}

  dtLogEntryFirst: TDATETIME; //< per invocation
  dtLogEntryLast: TDATETIME; //< per invocation
  u2IOResult: Word; //< holds last IOResult Value.
End;




//=============================================================================
// TODO: These ARE JAS Globals - Need to find a better place for these to live.
//=============================================================================
var
  gbServerCycling: boolean;
  gbServerShuttingDown: boolean;
  gsaJASFooter: Ansistring;
//=============================================================================



//*****************************************************************************
// Jegas Common - Glued Together
//*****************************************************************************
{}
Const cnJegasLogColumns = 8;
//=============================================================================
{}
// This record is designed to contain information about the user, the 
// application itself, and the main log file.
type rtJegasCommon = Record
  dtStart: TDATETIME; //< When the Unit was invoked (fired when application starts)

  saCmdLine: AnsiString;{< Command line used to invoke application
   Returns the command line as one ansistring. You can still do this via 
   PASCAL ParamCount and ParamStr(index) methods, but I found that this is 
   one of those things that occurs enough (multipled by logs etc that might
   want the entire string), to make using this method a little more 
   one more efficient: Build it once, make a string of it, one time. 
   This gets populated once - during this unit's init.}

  u8JegasUserID: Uint64; {< Specific to Jegas API - ID traceable back to the
   database/source containing Jegas Managed Users and their ID's security
   etc.}
  
  saOSUserLogin: AnsiString; //< OS Dependant - username (application ran as ...)
  saOSUserFullName: AnsiString; //< OS Dependant - username (application ran as ...)
  saOSNetworkLogin: AnsiString; //< OS Dependant Network Login Name
  saOSNetworkUserFullName: AnsiString;//< OS Dependant Network User Full Name
  
  rJegasLog: rtIOAppendLog; //< Information about the configuration etc
  // used by the Jegas API for its own native log file.
  {}
  // These are here, so far only JADO uses - but they are here.
  {}
  saAppTitle: AnsiString;//<application title
  saAppEXEName: AnsiString;//<exe name
  saAppPath: AnsiString;
  saAppProductName: AnsiString;
  saAppMajor: AnsiString;//< Version major
  saAppMinor: AnsiString;//< version minor
  saAppRevision: AnsiString;//<version revision
End;
//=============================================================================
{}
Var grJegasCommon: rtJegasCommon;
//=============================================================================


//=============================================================================
{}
// returns command line when program invoked.
// saves user and other portions of app to piece back
// together the parameters - useful for logging purposes so
// is in mem as one string - not a loop every time the string
// needs to be placed back together
Function saCmdLine: AnsiString;
//=============================================================================




//=============================================================================
{}
// JAS Configuration Record
// NOTE/TODO: As JAS begins to support multiple "installations" on 
// one host, then a mechanism will need to be created to handle
// the multiple DSN connections - preferably a POOLED system
// So connections are made on demand, reused if possible, 
// and disposed if left idle to long.
Type rtJASConfig=Record
  // Physical Dir -------------------------------------------------------------
  saSysDir: AnsiString; //< Directory where JAS is installed
  //saTemplatesDir: AnsiString;
  saConfigDir: AnsiString; // JAS Configuration Directory (DNS, jegas.cfg etc.)
  saFileDir: ansistring;
  saWebshareDir: ansistring;
  saCacheDir: AnsiString;
  saLogDir: ansistring;
  saThemeDir: ansistring;//os location
  saWebRootDir: ansistring; // actual file system path to default webroot
  saBinDir: ansistring;
  saSetupDir: ansistring;
  saSoftwaredir: ansistring;
  saSrcDir: ansistring;
  saDataBaseDir: ansistring;
  saPHPDir: ansistring;
  // Physical Dir -------------------------------------------------------------

  // Filenames ----------------------------------------------------------------
  saDBCFilename: ansistring;
  saConfigFile: Ansistring;//usually jas.cfg at this point.
  saPHP: AnsiString; //< Full Path to PHP php-cgi.exe for launching CGI based PHP
  saPerl: AnsiString; //< Full Path to Perl exe for launching CGI based Perl
  //saMenuTemplateFilename: ansistring;
  //saMenuTemplate: ansistring;
  saDiagnosticLogFileName: ansistring;// SEE DIAGNOSTIC_LOG PRE-COMPILE Directive
  saJASFooter: ansistring;
  // Filenames ----------------------------------------------------------------


  // Web Paths ----------------------------------------------------------------
  saWebShareAlias: AnsiString; //< Aliased Directory "webshare". Usually: jws
  saJASDirTheme: ansistring;//web view
  // Web Paths ----------------------------------------------------------------

  // Threading --------------------------------------------------------------
  iThreadPoolNoOfThreads: Longint;
  iThreadPoolMaximumRunTimeInMSec: Longint;
  // Threading --------------------------------------------------------------

  // Misc Settings ----------------------------------------------------------
  saServerURL: ansistring;// should not have trailing slash
  saServerName: ansistring;
  saServerIdent: AnsiString;
  saServerSoftware: ansistring;//<not a config thing as much as vari is more space efficient than constants in exe creation (same string repeated all over in binary executable)
  saDefaultArea: AnsiString;
  saDefaultPage: AnsiString;
  saDefaultSection: AnsiString;
  u1PasswordKey: Byte;
  saDefaultLanguage: AnsiString; //< DEFAULT should be 'en' for english naturally. Note: In filenames, and code - lowercase. In JAS MySQL jcaption table, upper case for field names. e.g. JCapt_EN = English Caption
  u1DefaultMenuRenderMethod: byte;
  saServerIP: AnsiString;
  u2ServerPort: Word;
  iRetryLimit: Longint;
  iRetryDelayInMSec: Longint;
  iTIMEZONEOFFSET: Longint;
  iMaxFileHandles: longint;//< NOT OS FILEHANDLES! Max Reservations for Jegas Threadsafe File Handles.
  bBlacklistEnabled: boolean;
  bWhiteListEnabled: boolean;
  bJobQEnabled: boolean;
  iJobQIntervalInMSec: Longint;
  u8DefaultTop_JMenu_ID: Uint64;
  bDirectoryListing: boolean;
  bDataOnRight: boolean;
  sCacheMaxAgeInSeconds: string;
  sSMTPHost: string;
  sSMTPUsername: string;
  sSMTPPassword: string;
  sSystemEmailFromAddress: string;
  bProtectJASRecords: boolean;
  bSafeDelete: boolean;
  bAllowVirtualHostCreation: boolean;  
  // Misc Settings ----------------------------------------------------------

  // Error and Log Settings -------------------------------------------------

  iLogLevel: Longint;{< Everything -1 keep metrics but no log,
                                    0 - no log,
                                    1 - log everything,
                                    2 - Fatal ONLY,
                                    3 - Fatal & Errors,
                                    4 - Fatal,Errors, Warnings,
                                    5 - Fatal, Errors, Warnings, Information Entries,
                                    6+ User Defined Log Entry Types, and log level
                                    pattern starting at 2 and up continues to
                                    work with user levels. This allows various
                                    levels of custom logging using existing system}



  bLogMessagesShowOnServerConsole: boolean;
  bDeleteLogFile: Boolean;
  iErrorReportingMode: Longint;
  saErrorReportingSecureMessage: Ansistring;
  bServerConsoleMessagesEnabled: boolean;
  bDebugServerConsoleMessagesEnabled: boolean;
  iDebugMode: longint;
  // Error and Log Settings -------------------------------------------------

  // Session and Record Locking ---------------------------------------------
  iSessionTimeOutInMinutes: Longint;
  iLockTimeOutInMinutes: Longint;
  iLockRetriesBeforeFailure: Longint;
  iLockRetryDelayInMSec:Longint;
  iValidateSessionRetryLimit: Longint;
  // Session and Record Locking ---------------------------------------------

  // IP Protocol Related ----------------------------------------------------
  i8MaximumRequestHeaderLength: Int64;
  iCreateSocketRetry: Longint;
  iCreateSocketRetryDelayInMSec: Longint;
  iSocketTimeOutInMSec: Longint;
  bEnableSSL: boolean;
  // IP Protocol Related ----------------------------------------------------

  // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
  // Programmable Session Custom Hooks - Names for Actions that might
  // be coded into the u01g_sessions file. Useful for working with
  // integrated systems.
  saHOOK_ACTION_CREATESESSION_FAILURE: ansistring;
  saHOOK_ACTION_CREATESESSION_SUCCESS: ansistring;
  saHOOK_ACTION_REMOVESESSION_FAILURE: ansistring;
  saHOOK_ACTION_REMOVESESSION_SUCCESS: ansistring;
  saHOOK_ACTION_SESSIONTIMEOUT: ansistring;
  saHOOK_ACTION_VALIDATESESSION_FAILURE: ansistring;
  saHOOK_ACTION_VALIDATESESSION_SUCCESS: ansistring;
  saClientToVICIServerIP: ansistring;
  saJASServertoVICIServerIP: ansistring;
  // ADVANCED CUSTOM PROGRAMMING --------------------------------------------

  saDefaultColorTheme         : ansistring;
  bDefaultSharesDefaultDomain : boolean;
  saDefaultIconTheme          : ansistring;
  saDefaultAccessLog          : ansistring;
  saDefaultErrorLog           : ansistring;
  bCreateHybridJets           : boolean;
End;
Var grJASConfig: rtJASConfig;
//=============================================================================
{}
// Resets JAS Configuration to its default app start up state
Procedure InitJASConfigRecord;
//=============================================================================








//=============================================================================
//=============================================================================
//=============================================================================
// !@!DEBUG RELATED
//=============================================================================
//=============================================================================
//=============================================================================


//=============================================================================
{}
// used for debugging - Nesting Count (Not ideal for threaded apps yet)
Var giDebugNestLevel: longint;
{}
// FOR DEBUGGING With the DEBUGBEGINANDEND Logging "Tools" - Should be called when function or procedure starts. (Not ideal for threaded apps yet)
Procedure DebugIN(saSection: AnsiString; p_saSourceFile: AnsiString);
//=============================================================================
{}
// FOR DEBUGGING With the DEBUGBEGINANDEND Logging "Tools" - Should be called last function or procedure exits. (Not ideal for threaded apps yet)
Procedure DebugOUT(saSection: AnsiString; p_saSourceFile: AnsiString);
//=============================================================================

//=============================================================================
{}
// Specifically Sending messages to the console and controlled
// by the configuration file's ServerConsoleMessagesEnabled=Yes option , and 
// is internally controlled by the resulting: 
// grJASConfig.bServerConsoleMessagesEnabled value at runtime.
Procedure JASPrint(p_sa:ansistring); inline;
//=============================================================================

//=============================================================================
{}
// Specifically Sending messages to the console and controlled
// by the configuration file's ServerConsoleMessagesEnabled=Yes option , and 
// is internally controlled by the resulting: 
// grJASConfig.bServerConsoleMessagesEnabled value at runtime.
Procedure JASPrintln(p_sa:ansistring);inline;
//=============================================================================

//=============================================================================
{}
// For Debugging, however these two are toggled via the 
// DebugServerConsoleMessagesEnabled=Yes option in the config file, and 
// are internally controlled by the resulting: 
// grJASConfig.bDebugServerConsoleMessagesEnabled value.
Procedure JASDebugPrint(p_sa:ansistring);inline;
//=============================================================================

//=============================================================================
{}
// For Debugging, however these two are toggled via the 
// DebugServerConsoleMessagesEnabled=Yes option in the config file, and 
// are internally controlled by the resulting: 
// grJASConfig.bDebugServerConsoleMessagesEnabled value.
Procedure JASDebugPrintln(p_sa:ansistring);inline;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!File Related
//*****************************************************************************
//==========================================================================
//*****************************************************************************

//=============================================================================
{}
// Returns ExitCode - Works for DOS and Linux. Note: Linux just
// appends the two parameters with a space separator. Using this
// gives you a platform independant way to execute shell commands.
// See uc_library.iCShell functions
// WARNING: Using this particular function with the console unit renders
//          the mouse unusable in DOS(At least if you call another FPC app
//          already using it). That in MIND that there may be different
//          precautions that need platform specific "safety" code to handling
//          shelling out, it is recommended you use the iCShell function
//          which does the same thing with precautionary code. (Which last
//          I checked didn't exist cuz I'm waiting on a solution from FPC site)
// I don't like making routines you use in one case and not in another but
// any other way would require circular references OR including units in
// a less than optimized manner just to see if they are IN USE or not.
//
// NOTE: The mouse dying warning was on 1.9.? FreePascal and Windows ME - 
// and refers to the CONSOLE (dos) window only - it's hopefully fixed
// now - but might be different PERIOD in newer Win platforms and this 
// FreePascal 2.?.? version(s) 2006-05-07 Jason P Sage
// THE FIX: You have to use the mouse unit directly in your program
// and then follow these steps after shelling out:
//         DoneMouse;
//         InitMouse;
//         RedrawConsole;
Function u2Shell(p_saCommand: AnsiString; p_saParam: AnsiString): word;
//=============================================================================
{}
// NOTE: See ug_common for light weight (code size wise) bLoadTextfile
// variety, does a line by line using readln generically.
// Uses block read/write with a Constant determined buffer size.
// See cnFileIO_BufferSize
Function bCopyFile(Var p_saSrc: AnsiString; Var p_saDest: AnsiString):Boolean;
Function bCopyFile(Var p_saSrc: AnsiString; Var p_saDest: AnsiString; Var p_u2IOREsult: Word):Boolean;
//--------
{}
// Basically these call the bCopyfile functions but remove the source file
// if successful.
Function bMoveFile(p_saSrc: AnsiString; p_saDest: AnsiString):Boolean;
Function bMoveFile(p_saSrc: AnsiString; p_saDest: AnsiString; p_u2IOREsult: Word):Boolean;
//=============================================================================
{}
// This function returns the first filename in a sequence like this:
// FILENAME.###.EXTENSION
// where ### are fixed length Zero Padded #. Sequenced based on File Presense.
// Only fails on 999 roll over. Starts at 001
// To explain a little clear. If you have SomeFile.001.txt and call this
// function like: saMyResult:=saSequencedFilename('SomeFile','txt'); and
// then if there isn't a file named: SomeFile.002.txt already in existance, 
// this is the value you will get back in saMyResult. This function can be useful
// so make revisions on disk - think VAX if you can go back that far.
Function saSequencedFilename(p_saFilename: AnsiString;p_saExtension: AnsiString): AnsiString;
//=============================================================================


//=============================================================================
{}
// (Originated in Wimble Project as _bPicExists_)
// This function returns TRUE if the passed pic file in p_saPicFileName
// (filename only) exists in the "pic Database" (so to speak) on the
// harddrive. If it does exist, (function returns true) the p_saPath parameter
// returns with the RELATIVE path of the pic's directory so the results can be
// used for both web and DOS operations. Note: p_saPath is NOT touched UNLESS the
// picture is found. This makes it easy for weboperations to have a default
// "NO PICTURE PRESENT" default that gets overrided if the image DOES exist! :)
Function bFileExistsInTree(
  p_saMakeTreeWithThis: ansistring;  // Can be filename or your own string to create nested dir
  p_saFilename: AnsiString;
  p_saTreeTop: AnsiString;
  Var p_saRelPath: AnsiString;
  p_i4Size: longint;
  p_i4Levels: longint
):Boolean;
//=============================================================================
{}
// (Originated in Wimble project as _bStorePic_)
// This function returns TRUE if the passed pic file in p_sapicFile
// (filename only) can be successfully stored in the "pic Database"
// (so to speak). This was originally designed for the mlsimport.pas 
// application.
//
// It relies on the pic sitting in the [mlsdir]import= directory
Function bStoreFileInTree(
  p_saMakeTreeWithThis: ansistring; // Can be filename or your own string to create nested dir
  p_saSourceDirectory: AnsiString; //< Containing file to store
  p_saSourceFileName: AnsiString; //< Filename to copy and store (unless p_sadata is used)
  p_saDestTreeTop: AnsiString; //< Top of STORAGE TREE
  p_saData: AnsiString; {< If this variable is not empty - then it is used in place
   of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
   saved as the p_saDestFilename in the calculated tree's relative path.}
  Var p_saRelPath: AnsiString; //< This gets the saRelPath when its created.
  p_i4Size: longint;
  p_i4Levels: longint
):Boolean;
//=============================================================================
{}
// This function deletes all contents of the supplied directory matching 
// filespec. It Does not delete the directories. NOT related to TREE STORAGE
// routines: bFileExistsInTree or bStoreFileInTree but can be used in their
// directories if proper path is supplied. See: saFileToTreeDos function
// in ug_common.pp
Function bDeleteFilesInTree(p_saDirectory: AnsiString; p_saFileSpec: AnsiString):Boolean;
//=============================================================================
{}
function saFileNameNoExt(p_saFileName: ansistring): ansistring;
//=============================================================================
{}
// File Saving function. Uses TEXT mode with a Write (versus a 
// writeln) so in theory should be useful for various file types even though
// creates file of text.
function bSaveFile(
  p_saFilename: ansistring;
  p_saFileData: ansistring;
  p_iRetryLimit: longint;
  p_iRetryDelayInMSecs: longint;
  var p_u2IOResult: word;
  p_bAppend: boolean
):boolean;
//=============================================================================
{}
// Return DateTime file created
function dtGetFileCreated(p_saFilename: ansistring): TDATETIME;
//=============================================================================
{}
// return the path from a full pathnfile
function saExtractDir(p_sa: ansistring): ansistring;
//=============================================================================



//=============================================================================
{}
//  This function allows you to ask for a file you need from the system
// or a theme etc...
// and it will follow a series of locations to attempt to satisfy that request
// taking into account the current language, current theme, etc... and work its
// way back to the stock theme, then the built in templates that are not
// generally "directly accessible" like the theme bits might be. (It;s like the
// built in CORE UI for JAS - so - we have a fall back or two to try to keep
// running - even when things get misconfigured, forgotten or something.
//
//       IN: RELPATHNFILE ( e.g.: './en/error/somefile????' );
//       OUT: Full pathnfile to first version of file in order of precendence
//
//       (Current Theme Dir)
//       CURRENT LANG (??) Folder
//       DEFAULTLANGUAGE (EN)
//       ROOT of Theme   (  './' )
//
//       If NOT ALREADY IN 'stock' theme - check that next....
//       ('stock' Theme Dir)
//       CURRENT LANG (??) Folder
//       DEFAULTLANGUAGE (EN)
//       ROOT of Theme   (  './' )
//
//       LAST RESORT:
//       ('templates' Dir) - Which unlike themes - are not generally set up for folks on the outside to access directly.
//       CURRENT LANG (??) Folder
//       DEFAULTLANGUAGE (EN)
//       ROOT of Theme   (  './' )
//
//       IF NOT TEMPLATE Exists - then an empty string is returned
// NOTE: if either or both p_saCurrentLang, p_saCurrentTheme are sent blank,
//       than tests reliant on those will be skipped.
//=============================================================================
function saJasLocateTemplate(
  p_saREL_PATH_N_FILE,
  p_saCurrentLang,
  p_saCurrentTheme,
  p_saRequestedDir: ansistring;
  p_i8Caller: int64;
  p_VHostTemplateDir: Ansistring
): ansistring;



Function saGetUniqueCommID(p_saPath: AnsiString):AnsiString;




//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Date-n-Time 
//*****************************************************************************
//==========================================================================
//*****************************************************************************
Var 
  asaDateFormat: array[0..22] Of AnsiString;
  asaMonth: array[1..12] Of AnsiString;
  asaDay: array[1..7] Of AnsiString;

Const cnDateFormat_Elements=11;
{}
// Or implement VARIANT parameter to allow both TDATETIME and ANSISTRING like
// the JAVASCRIPT implementation.
//
// Take the comments for these date tihings with grain of salt - converted 
// from JavaScript, and I haven't gone thorugh this with finetoothed comb.
{}
Const csDateFormat_00='?';            
const cnDateFormat_00=0;//< 0 for when you pass DATE OBJECT, use this as format in, just so routine doesn't kick you out.

Const csDateFormat_01='MM/DD/YYYY HH:NN AM';
const cnDateFormat_01=1; //<1 ADO Friendly for SAVING TO MSSQL 5/1/2005 12:00 am (or Zero Padded not  sure if matters)
                                      
Const csDateFormat_02='MM/DD/YYYY';  
const cnDateFormat_02=2;

Const csDateFormat_03='YYYY-MM-DD';
const cnDateFormat_03=3;//< BlueShoes Date Picker Format for isoInit and CGI Params

Const csDateFormat_04='DDD MMM DD HH:NN:SS EDT YYYY';
const cnDateFormat_04=4;
  //4

Const csDateFormat_05='DDD, DD MMM YYYY HH:NN:SS';
const cnDateFormat_05=5; //< 5 JavaScript date object - can be used to set time, I think 

Const csDateFormat_06='DDD, DD MMM YYYY HH:NN:SS UTC';
const cnDateFormat_06=6;//< 6 - NOTE: Your date must already be fixed up to take into account UTC time differences. This function formats it, it doesn't translate the date to your UTC locale etc.

Const csDateFormat_07='DDDD, DD MMM, YYYY HH:NN:SS AM';
const cnDateFormat_07=7; //< 7 javascript date.toLocaleString() format  DDDD=day name spelled out

Const csDateFormat_08='HH:NN:SS';
const cnDateFormat_08=8; //<8

Const csDateFormat_09='HH:NN:SS EDT';
const cnDateFormat_09=9; //<9

Const csDateFormat_10='MMM DDD DD YYYY';
const cnDateFormat_10=10; //<10 'Mon May 20 2002'

Const csDateFormat_11='YYYY-MM-DD HH:NN:SS';
const cnDateFormat_11=11; //<11 '2005-01-30 14:15:12'

Const csDateFormat_12='MM/DD/YY';
const cnDateFormat_12=12;//< 12 '01/30/05' USA Short Format

Const csDateFormat_13='DD/MMM/YYYY'; 
const cnDateFormat_13=13; //< 13 '17/Jan/2007' European TODO: Implement this format in FPC JDATE

Const csDateformat_14='DD/MMM/YYYY HH:MM AM';
const cnDateFormat_14=14; //< 14 'DD/MMM/YYYY HH:MM AM' or '17/Jan/2007 03:08 PM'

Const csDateFormat_15='DD/MMM/YYYY HH:MM';
const cnDateFormat_15=15;//< 15 'DD/MMM/YYYY HH:MM'    or '17/Jan/2007 23:00' Military

Const csDateFormat_16='HH:NN AM';
const cnDateFormat_16=16;//< 16 'HH:MM AM'             or '03:08 PM'

Const csDateFormat_17='HH:NN';
const cnDateFormat_17=17;//< 17 'HH:MM'                or '23:00' 

Const csDateFormat_18='DD/MMM/YYYY:HH:NN:SS';
const cnDateFormat_18=18;

Const csDateFormat_19='MM/DD/YYYY HH:NN'; // NOT ZERO PADDED
const cnDateFormat_19=19;

Const csDateFormat_20='MM/DD/YYYY HH:NN'; // ZERO PADDED
const cnDateFormat_20=20;

Const csDateFormat_21='YYYY-MM-DD HH:NN';//ZERO PADDED Military time
const cnDateFormat_21=21; //<11 '2005-01-30 14:15'

const csDateFormat_22='DD/YYYY/MM HH:NN AM';
const cnDateFormat_22=22;

//=============================================================================
{}
// Date String to String conversion (can optionally pass date object, but 
// send '?' as p_FormatIn parameter.
//
// REQ PARAMETERS: 
//  p_saDate - DATE IN STRING FORMAT
//  p_iFormatOut - DESIRED OUTPUT FORMAT    ---- unless using  TDATETIME
//  p_iFormatIn -  Format of date coming in ----  unless using TDATETIME
//
//  If Using TDATETIME, For Input/output, or who knows why you'd
//  do both.... Send ZERO in the Appropriate  p_iFormatIn and p_iFormatOut
//  parameters.
//
//  var p_dtDateTime - TDATETIME. (Dual Purpose) in/out depending on
//    passed p_saFormatIn and p_saFormatOut Parameters.
//    which case pass '?'.
//
Function JDate(
  p_saDate: AnsiString; 
  p_iFormatOut: longint;
  p_iFormatIn: longint;
  Var p_dt: TDATETIME
): AnsiString;
//=============================================================================
{}
// Variety Without Passing Date Object In OR Out - See other JDATE routine for more info.
Function JDate(
  p_saDate: AnsiString; 
  p_iFormatOut: longint;
  p_iFormatIn: longint
): AnsiString;
//=============================================================================
{}
// returns numbers to their non-military counterpart: e.g: 13 becomes 1
Function iMilitaryToNormalHours(p_iHours:longint):longint;
//=============================================================================




//--------------------------------------------------
{}
Const csDateMonth_01='January';
Const csDateMonth_02='Febuary';
Const csDateMonth_03='March';
Const csDateMonth_04='April';
Const csDateMonth_05='May';
Const csDateMonth_06='June';
Const csDateMonth_07='July';
Const csDateMonth_08='August';
Const csDateMonth_09='September';
Const csDateMonth_10='October';
Const csDateMonth_11='November';
Const csDateMonth_12='December';
{}
//--------------------------------------------------
{}
Const csDateDay_1='Sunday';
Const csDateDay_2='Monday';
Const csDateDay_3='Tuesday';
Const csDateDay_4='Wednesday';
Const csDateDay_5='Thursday';
Const csDateDay_6='Friday';
Const csDateDay_7='Saturday';
{}
//--------------------------------------------------

//=============================================================================
{}
Function tsAddYears(p_tsFrom: TTIMESTAMP; p_iYears: longint): TTIMESTAMP;
//=============================================================================
{}
Function tsAddMonths( p_tsFrom: TTIMESTAMP;  p_iMonths: longint): TTIMESTAMP;
//=============================================================================
{}
Function tsAddDays(p_tsFrom: TTIMESTAMP; p_iDays: longint): TTIMESTAMP;
//=============================================================================
{}
Function tsAddHours(p_tsFrom: TTIMESTAMP; p_Comp_Hours: Comp): TTIMESTAMP;
//=============================================================================
{}
Function tsAddMinutes(p_tsFrom: TTIMESTAMP; p_Comp_Minutes: Comp): TTIMESTAMP;
//=============================================================================
{}
Function tsAddSec(p_tsFrom: TTIMESTAMP; p_Comp_Seconds: Comp): TTIMESTAMP;
//=============================================================================
{}
Function tsAddMSec( p_tsFrom: TTIMESTAMP; p_Comp_MSec: Comp): TTIMESTAMP;
//=============================================================================
{}
Function iDiffYears(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP):longint ;
//=============================================================================
{}
Function iDiffMonths(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
Function iDiffDays(p_tsFrom: TTIMESTAMP;p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
Function iDiffHours(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
Function iDiffMinutes(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
Function iDiffSeconds(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
Function iDiffMSec(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
{}
// Time Difference function between FPC TTIMESTAMPS. Note in testing
// it was discovered that YEAR differences didn't come back properly (zeroed)
// and the same for millisecond differences. HOURS, MINUTES and SECONDS do
// appear to work properly. This may be a flaw in our code, a bug in FPC
// lower level timestamp conversion routines this library wraps, or could 
// be to exact spec and more work needs to be done on our end to make this 
// function work the way we'd like. At the moment it's hardly in our critical
// path - but if it becomes so or you want to take a stab at fixing this - 
// let us know! --Jason P Sage
Function tsDiff(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): TTIMESTAMP;
//=============================================================================
{}
Function saFormatTimeStamp(p_saFormat: AnsiString; p_ts: TTIMESTAMP): AnsiString;
//=============================================================================
{}
// This function takes a string and parses and converts it to a TTIMESTAMP 
// Note that when I tried to convert 2005-01-01 05:30 AM I got erroneous
// results - yet when I tried '1/1/5 5:30 PM' I got '2005-01-01 17:30:00' as 
// my timestamp. the point is you want to test to make sure the string format
// are using works correctly before you move forward. See the JDATE function
// to convert to and from various date formats.
Function StrToTimeStamp(p_sa: AnsiString):TTIMESTAMP;
//=============================================================================
{}
Function saFormatDateTime(p_saFormat: AnsiString; p_dt: TDATETIME): AnsiString;
//=============================================================================
{}
Function dtAddYears(p_dtFrom: TDATETIME; p_iYears: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddMonths(p_dtFrom: TDATETIME; p_iMonths: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddDays(p_dtFrom: TDATETIME; p_iDays: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddHours(p_dtFrom: TDATETIME;p_iHours: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddMinutes(p_dtFrom: TDATETIME; p_iMinutes: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddSec(p_dtFrom: TDATETIME; p_iSeconds: Longint): TDATETIME;
//=============================================================================
{}
Function dtAddMSec(p_dtFrom: TDATETIME; p_iMSec: longint): TDATETIME;
//=============================================================================
{}
Function iDiffYears(p_dtFrom: TDATETIME; p_dtTo: TDATETIME):Longint ;
//=============================================================================
{}
// This is a funky way to do it, but necessary as far as I know because
// it manages to handle the leap year stuff by leveraging the FreePascal
// IncMonth Function. This works out to be accurate, versus day math like
// days divided by some guess'timate like 30 days a month - which is skewed.
Function iDiffMonths(p_dtFrom: TDATETIME;p_dtTo: TDATETIME): Longint;
//=============================================================================
{}
// This looks recursive but its not - there are two versions of many of the 
// datetime functions - one for freepascal TDATETIME and one for OS TIMESTAMPS.
Function iDiffDays(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Longint;
//=============================================================================
{}
Function iDiffHours(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Longint;
//=============================================================================
{}
Function iDiffMinutes(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
//=============================================================================
{}
Function iDiffSeconds(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Longint;
//=============================================================================
{}
Function iDiffMSec(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Longint;
//=============================================================================
{}
// cheap milli sec thing - returns milliseconds since midnight.
Function iMSec(p_dt: TDATETIME):Longint;
//=============================================================================
{}
// cheap milli sec thing - returns milliseconds since midnight
// This is the Same as the above version of this routine except this one
// uses the system clock with the sysutils' NOW function.
Function iMSec:Longint;
//=============================================================================
{}
Procedure WaitInMSec(p_iMilliSeconds: longint);
//=============================================================================
{}
// sysutils consts
{SecsPerDay = 24 * 60 * 60; // Seconds and milliseconds per day
MSecsPerDay = SecsPerDay * 1000;
DateDelta = 693594; // Days between 1/1/0001 and 12/31/1899}
Procedure WaitInSec(p_iSeconds:Longint);
//=============================================================================










//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Logging
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
{}
// NOTE: Used internally by IOAppendLog
// This was internally Encapsulated but - returns column headers
// prepared to be outed by IOAppend after an EOL is appendeded for
// the correct OS implementation.
Function saIOAppendLogColumnHeaders(Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
//=============================================================================

//=============================================================================
{}
// NOTE: Used internally by IOAppendLog
// This was internally Encapsulated but - returns column data
// prepared to be outed by IOAppend after an EOL is appendeded for
// the correct OS implementation.
Function saIOAppendLogColumnData(Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
//-----------------------------------------------------------------------------
{}
// Purpose: To make the most compatible "generic" logging format for importing 
// data into various applications.
Function bIOAppendLog(Var p_rIOAppendLog: rtIOAppendLog):Boolean;
//function bIOAppendLog(var p_rIOAppendLog: rtIOAppendLog; var p_u2IOResult: word):boolean;
//-----------------------------------------------------------------------------

//=============================================================================
{}
// INTERNAL
Function JLog(
  p_u2LogType_ID: word;
  p_u8Entry_ID: UInt64; 
  p_saEntryData: AnsiString;
  p_saSourceFile: AnsiString
): Boolean;
//=============================================================================
{}
// This function is used by internal JLOG logging function and is made
// available externally for ug_jfc_threadmgr's internal debugging infrastructure.
Function saDebugNest(p_saSectionName: AnsiString; p_bBegin: Boolean; var p_iNestLevel: longint): AnsiString;
//=============================================================================








//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Strings
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Function saJegasLogoRawText(p_saEOL: AnsiString; p_bShowJASServerID: boolean): AnsiString;
Function saJegasLogoRawText(p_saEOL: AnsiString): AnsiString;
Function saJegasLogoRawHtml: AnsiString;
//==========================================================================
{}
Function saWindowStateToString(p_i4WindowState: LongInt): AnsiString;
//==========================================================================
{}
Function i4WindowStateToInt(p_saWindowState: AnsiString): LongInt;
//==========================================================================
{}
// Returns English "Yes" or "No " The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "Yes" or "No "
Function saYesNo(p_b:Boolean): AnsiString;
//==========================================================================
{}
// Returns English "True" or "False" The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "True " or "False"
Function saTrueFalse(p_b: Boolean): AnsiString;
//==========================================================================
{}
// NOTE: For (Function bOnOff(p_saOnOff: AnsiString): Boolean;) Use bVal()
//       in ug_common.pp I believe - Jason
Function saOnOff(p_b:Boolean): AnsiString;
//==========================================================================
{}
// This function XORs an entire string using the passed key parameter.
Function saXorString(p_sa: AnsiString; p_u1Key: Byte):AnsiString;
//==========================================================================
{}
// pass a char and how many of it you want back - "Repated" ...
// and that's what you get.
Function saRepeatChar(p_ch: Char; p_iHowMany: longint): AnsiString;
//==========================================================================
{}
Function saNextRevisionKey(p_sa: AnsiString):AnsiString;
//=============================================================================
{}
// Returns a '1' or a '0' as an ansistring
Function saOneZero(p_b: Boolean):AnsiString;
//=============================================================================
{}
// Use to Copy a PASCAL ANSISTRING to a "C++" String Buffer.
// returns length actually copied for the benfit of said 
// C++ routines.
Function i4PToC(p_sa: AnsiString; Var p_cdest: PChar; p_i4DestCBuflen: LongInt):LongInt;
//=============================================================================
{}
// This routine takes a C++ sz and copies it into a Pascal Ansistring.
Function saCToP(Var p_csrc: PChar):AnsiString;
//=============================================================================
{}
// This function takes a "DOS RELATIVE PATH" and attempts to solve it
// by removing the single and double dots ('.', '..') to give a solid
// path. This function does not verify with the operating system that
// this is valid, nor can it turn a dir of pure relative information
// into directory names. 
//
// TODO: Make work by verifying the PATH EXISTS as sent, and if it does, 
// getting that information by merely changing to that path, and extracting
// the results. e.q. getCurDir, switch to path dir, read getdir again, 
// go back to dir we started in (saved with first get dir) If directory
// can not be resolved, returned passed directory unchanged I suppose.
//
function saSolveRelativePath(p_sa: AnsiString):ansistring;
//=============================================================================
{}
//function saReverse(p_sa: ansistring): ansistring; - I think its broken
//=============================================================================
//=============================================================================
{}
Function saProper(p_saSentence: ansistring): ansistring;
//=============================================================================
{}
Function saParseLastName(p_saName: ansistring): ansistring;
//=============================================================================
{}
Function saBuildName( 
  p_saDear: AnsiString; 
  p_saFirst: AnsiString; 
  p_saMiddle: AnsiString; 
  p_saLast: AnsiString; 
  p_saSuffix: ansiString 
):ansistring;
//=============================================================================
{}
Function saPhoneConCat(p_saPhone: ansistring; p_saExt: ansistring): ansistring;
//=============================================================================
{}
Procedure ParseName(
  p_In_saName: ansistring;
  var p_Out_saFirst: ansistring; 
  var p_Out_saMiddle: ansistring;
  var p_Out_saLast: ansistring
);
//=============================================================================
{}
function saMid(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
//=============================================================================
{}
function saCut(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
//=============================================================================
{}
function saInsert(p_saSrc: ansistring; p_saInsertMe: ansistring; p_i8Start: int64): ansistring;
//=============================================================================
{}
// Encodes passed string to base64 encoding.
//
// Freepascal has classes for this but I just wanted a simple function I could
// call to get data from one format to another without to much fuss. Now... 
// because streams can get large; if you find this function needs some 
// optimization or something, consider making an overloaded version of this  
// function that accepts the TStringStream class instances you might have in 
// memory already to avoid having to copy said data in memory again before it 
// can be used.
//
// NOTE: an oddity for this function that isn't related to this function but
// instead the underlying code. Freepascal has base64 encoding and decoding
// classes and we are using them. The strange thing was how in some situations 
// a freepascal user reported missing bytes at the end of a base64 decoding.
// The reason has to do with the way base64 encoding more or less does groups 
// of three bytes at a time. If the number of bytes in a stream is not evenly
// divisible by 3, you end up with 1 or two stragglers. Turns out.. the
// weird thing is that those last one or two bytes will get processed when 
// the class destructor (destroy) is called. Here is the article:
// http://community.freepascal.org:10000/bboards/message?message_id=243020&forum_id=24088
function saBase64Encode(p_sa: ansistring): ansistring;
//=============================================================================
{}
// Decodes passed string to base64 encoding.
//
//
// Freepascal has classes for this but I just wanted a simple function I could
// call to get data from one format to another without to much fuss. Now... 
// because streams can get large; if you find this function needs some 
// optimization or something, consider making an overloaded version of this  
// function that accepts the TStringStream class instances you might have in 
// memory already to avoid having to copy said data in memory again before it 
// can be used.
//
// NOTE: an oddity for this function that isn't related to this function but
// instead the underlying code. Freepascal has base64 encoding and decoding
// classes and we are using them. The strange thing was how in some situations 
// a freepascal user reported missing bytes at the end of a base64 decoding.
// The reason has to do with the way base64 encoding more or less does groups 
// of three bytes at a time. If the number of bytes in a stream is not evenly
// divisible by 3, you end up with 1 or two stragglers. Turns out.. the
// weird thing is that those last one or two bytes will get processed when 
// the class destructor (destroy) is called. Here is the article:
function saBase64Decode(p_sa: ansistring): ansistring;
//=============================================================================

//=============================================================================
{}
// Converts a single to a string
function saSingle(p_fValue: single; p_iDigits: longint; p_iDecimals: longint): ansistring;
//=============================================================================

//=============================================================================
{}
// Converts a double to a string
function saDouble(p_fValue: double; p_iDigits: longint; p_iDecimals: longint): ansistring;
//=============================================================================
{}
// Double Escapes a String. finds a char then replaces it with two of them.
function saDoubleEscape(p_saEscapeThis: ansistring; p_chCharToEscape: char): ansistring;
//=============================================================================
{}
// Escapes a String. Finds a char and replaces it with string.
// eg: 'Isn/'t' = saEscape('Isn''t','/''');
function saEscape(p_saEscapeThis: ansistring; p_chCharToEscape: char; p_saReplaceWith: ansistring): ansistring;
//=============================================================================
{}
function bGoodEmail(p_sa: ansistring): boolean;
//=============================================================================
{}
function bGoodPassword(p_sa: ansistring): boolean;
//=============================================================================
{}
function bGoodUsername(p_sa: ansistring): boolean;
//=============================================================================












//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Jegas Field Functions (rtJegasField type=record)
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
{}
// Returns true for passed Jegas Types that are numeric. Int, Uint, Decimals,
// currency BUT NOT BOOLEAN.
// See ug_common for definitions of jegas types
Function bIsJDTypeNumber(p_u2JDType:word):Boolean;
//=============================================================================

//=============================================================================
{}
// Returns true for any passed Jegas Type that is TEXT: this includes char,
// strings and memos.
// See ug_common for definitions of jegas types
Function bIsJDTypeText(p_u2JDType:word):Boolean;
//=============================================================================



//=============================================================================
{}
// Returns true for passed Jegas Types that are strings.
// See ug_common for definitions of jegas types
Function bIsJDTypeString(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are memos.
// See ug_common for definitions of jegas types
Function bIsJDTypeMemo(p_u2JDType:word): boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are binary.
// See ug_common for definitions of jegas types
Function bIsJDTypeBinary(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are boolean.
// See ug_common for definitions of jegas types
Function bIsJDTypeBoolean(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are dates.
// See ug_common for definitions of jegas types
Function bIsJDTypeDate(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are characters.
// See ug_common for definitions of jegas types
Function bIsJDTypeChar(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are unsigned integers.
// See ug_common for definitions of jegas types
Function bIsJDTypeUInt(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are integers.
// See ug_common for definitions of jegas types
Function bIsJDTypeInt(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are fixed or floating point
// decimal numbers. Not Currency Data types however.
// See ug_common for definitions of jegas types
Function bIsJDTypeDec(p_u2JDType:word):Boolean;
//=============================================================================
{}
// Returns true for passed Jegas Types that are of the Currency data type.
// See ug_common for definitions of jegas types
Function bIsJDTypeCurrency(p_u2JDType:word):Boolean;
//=============================================================================
{}
// diagnostic Aid: Send it the Jegas Data Type - it will return its NAME as text
Function saJDType(p_u2JDType:word): AnsiString;
//=============================================================================
{}
// p_SrcXDL and p_DestXDL
//
// XDL: Item_i8User = Weight 0-4,000,000,000   (REcommend lower values (B^)>
//                    ONLY HONORED IN SrcXDL. This Value is ignored in DestXDL.
//                    Range: 4 Byte Unsigned Integer - Don't Exceed.
// XDL: Item_saName = Field Name (not Caption ideally but would work if both
//                    had the same naming. Which Means if DeDuping different
//                    tables, the DestXDL Item_saName's should be that of the
//                    SrcXDL.
// XDL: Item_saValue= Value to be compared
// XDL: Item_saDesc = Undefined.
//
// NOTE: For Merge - the DestXDL will be Populated. So The Values after this
// routine performs a merge, that you'll want, will be in DestXDL.
//
// If you have a small number of fields you wish to merge with a larger Table,
// only include the fields that exist in both tables.
//
// The dupe Score is the Score to beat to be considered a DUPE. this is not
// an exact science - so this is how we learn to tweak settings to get
// acceptable results. Each kind of dupe checking will have unique WEIGHTS
// and a DupeScore.
//
// If Both XDL Do No have identical COUNT of Items; also more than ZERO,
// otherwise the routine will fail.
//
// p_ColXDL
//
// The Collision XDL Returns Colisions Preventing a Full Merge.
// You Will Get a List of Column Names in p_ColXDL.Item_saName
// For diagnostic reasons, you will get Src Value in Item_saValue
// and Dest value in Item_saDesc. This might be useful to make user interface
// to selectively resolve colisions.
//
// Naturally sending uninitialized XDLs will cause a CRASH.
//
procedure Merge(
  p_bPerformMerge: boolean;
  p_uDupeScore: cardinal;
  p_bCaseSensitive: boolean;
  var p_bDupe: boolean;
  p_SrcXDL: JFC_XDL;
  p_DestXDL: JFC_XDL;
  p_ColXDL: JFC_XDL
);
//=============================================================================









//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#! Email
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
function bSendMail(
  p_saTo: ansistring;
  p_saFrom: ansistring;
  p_saSubject: ansistring;
  p_saMsg: ansistring
):boolean;
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


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************






//=============================================================================
//=============================================================================
//=============================================================================
// !#!DEBUG RELATED
//=============================================================================
//=============================================================================
//=============================================================================
Function saDebugNest(p_saSectionName: AnsiString; p_bBegin: Boolean; var p_iNestLevel: longint): AnsiString;
Const csBEGIN=' Begin';
Const csEND=  ' End  ';
Begin
  If p_bbegin Then
  Begin
    Result:=csBegin;
  End
  Else
  Begin
    p_iNestLevel-=1;
    If p_iNestLevel<0 Then
    Begin
      Result:=' NEST LEVEL < 0 ('+inttostr(p_iNestLevel)+')!! ';
    End;
    Result:=Result+csEnd;
  End;


  Result:=
    '|'+StringOfChar('.',p_iNestLevel)+p_saSectionName+ ' ' + 
    StringOfChar('-',128-length(p_saSectionName))+
    Result;
    
  If p_bBegin Then 
  begin
    p_iNestLevel+=1;
    Result:=' -   --->> '+Result; 
  end  
  Else
  begin
    Result:=' <<---   - '+Result;
  end;



End; 
//=============================================================================


//=============================================================================
{ DEPRECIATED: LEGACY CONSTRUCT
Procedure SageLog(
  p_iSeverity: Integer; 
  p_saMsg: AnsiString; 
  p_saSourceFile: AnsiString
);
//=============================================================================
Begin
  JLog(cnLog_ERROR, 200609152044, p_saMSG, 'USED OLD "SAGELOG":'+ SOURCEFILE);
End;
//=============================================================================
// DEPRECIATED
Procedure SageLogI(sa: AnsiString);
//=============================================================================
Begin
  DebugIn(sa,'?? SageLogI Used ?? - Use DeBugIn(p_sa,p_saSourceFile) Now.');
End;
//=============================================================================
// DEPRECIATED
Procedure SageLogO(sa: AnsiString);
//=============================================================================
Begin
  DebugOut(sa,'?? SageLogO Used ?? - Use DeBugIn(p_sa,p_saSourceFile) Now.');
End;
//=============================================================================
}

//=============================================================================
Procedure DebugIN(saSection: AnsiString; p_saSourceFile: AnsiString);
//=============================================================================
Begin
  JLOG(cnLog_DEBUG, 200609191352,
    saDebugNest(saSection,True,giDebugNestLevel),p_saSourceFile);
  //Inc(giDebugNestLevel);//+=1;
End;
//=============================================================================
Procedure DebugOUT(saSection: AnsiString; p_saSourceFile: AnsiString);
//=============================================================================
Begin
  JLOG(cnLog_DEBUG, 200609191353,
    saDebugNest(saSection,False,giDebugNestLevel),p_saSourceFile);
  //dec(giDebugNestLevel);//+=1;
End;
//=============================================================================















//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!File Related
//*****************************************************************************
//==========================================================================
//*****************************************************************************
//=============================================================================
Function u2Shell(p_saCommand: AnsiString; p_saParam: AnsiString): word;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iShell',SOURCEFILE);
  {$ENDIF}
  Exec(p_saCommand, ' '+p_saParam);
  If Doserror= 0 Then
  Begin
    Result:=DosExitCode;
  End
  Else
  Begin
    Result:=DosError+32768; // So Errors can be differentiated from Dos Exit
  End;
  {$IFDEF DEBUGBEGINEND}
    DebugOut('iShell',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function bCopyFile(  Var p_saSrc: AnsiString;   Var p_saDest: AnsiString):Boolean;
Var u2IOResult: Word;
Begin 
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bCopyFile 200609191836',SOURCEFILE);
  {$ENDIF}

  u2IOResult:=0;
  Result:=bCopyFile(p_saSrc, p_saDest, u2IOResult);

 {$IFDEF DEBUGBEGINEND}
    DebugOut('bCopyFile 200609191836',SOURCEFILE);
  {$ENDIF}
End;


//----
Function bCopyFile(Var p_saSrc: AnsiString; Var p_saDest: AnsiString; Var p_u2IOREsult: Word):Boolean;
//=============================================================================
Var fin, fout: File Of Byte;
//    u1: Byte;
    iNumREad: longint;
    iNumWritten:longint;
    //au1Buf: array [0..65536] Of Byte;//64k
    //au1Buf: array [0..524266] Of Byte;//half meg
    au1Buf: array [0..1048576] Of Byte;//meg
    //au1Buf: array [0..16777216] Of Byte;//16 megs
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bCopyFile 200609191944',SOURCEFILE);
  {$ENDIF}
  p_u2IOResult:=0;
  If FileExists(p_saDest) Then deletefile(p_saDest);
  try
    CSECTION_FILEREADMODEFLAG.Enter;
    filemode:=READ_WRITE;
  finally
    CSECTION_FILEREADMODEFLAG.Leave;
  end;
  assign(fin, p_saSrc);
  Assign(fout, p_saDest);
  {$I-}
  reset(fin,1);
  {$I+}
  p_u2IOResult:=ioresult;
  If p_u2IOResult=0 Then
  Begin
    {$I-}
    rewrite(fout,1);
    {$I+}
    p_u2IOResult:=ioresult;
    If p_u2IOResult=0 Then
    Begin
      repeat
        {$I-}
        BlockRead(fin, au1buf, sizeof(au1buf), inumread);
        {$I+}
        p_u2IOResult:=ioresult;
        If p_u2IOResult=0 Then
        Begin
          {$I-}
          BlockWrite(fout,au1buf,iNumRead,iNumWritten);
          {$I+}
          p_u2IOResult:=ioresult;
        End;
      Until (inumread=0) OR (inumwritten<>inumread) OR (p_u2IOResult<>0);
      {$I-}

      If p_saSrc<>'' Then close(fin);
      //asprint('B');
      If p_saDest<>'' Then close(fout);
      //asprint('C');
      {$I+}
    End;
  End;
  Result:=p_u2IOResult=0;
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bCopyFile 200609191944',SOURCEFILE);
  {$ENDIF}
   //asprintln('|done|');
End;
//=============================================================================

//=============================================================================
Function bMoveFile(p_saSrc: AnsiString; p_saDest: AnsiString):Boolean;
Var u2IOResult: Word;
Begin u2IOResult:=0;Result:=bMoveFile(p_saSrc, p_saDest, u2IOResult);End;
//----
Function bMoveFile(p_saSrc: AnsiString; p_saDest: AnsiString; p_u2IOREsult: Word):Boolean;
//=============================================================================
Var 
  bSuccess: Boolean;
  f: File;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bmoveFile',SOURCEFILE);
  {$ENDIF}
  
  bSuccess:=False;
  If bCopyFile(p_saSrc, p_saDest, p_u2IOResult) Then
  Begin
    {$I-}
    assign(f,p_saSrc);
    p_u2IOResult:=IOResult;
    {$I+}
    
    If p_u2IOResult=0 Then
    Begin
      {$I-}
      erase(f);
      p_u2IOResult:=IOResult;
      {$I+}
    End;
    bSuccess:=p_u2IOResult=0;
  End;
  Result:=bSuccess;
  
   {$IFDEF DEBUGBEGINEND}
    DebugOUT('bmoveFile',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================











//=============================================================================
// This function returns the first filename in a sequence like this:
// FILENAME.###.EXTENSION
// where ### are fixed length Zero Padded #. Sequenced based on File Presense.
// Only fails on 999 roll over. Starts at 001
Function saSequencedFilename(p_saFilename: AnsiString;p_saExtension: AnsiString): AnsiString;
//=============================================================================
Var 
  iCounter: longint;
  sa: AnsiString;
  saFmtNo: AnsiString;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saSequencedFilename',SOURCEFILE);
  {$ENDIF} 
  iCounter:=1;
  repeat
    saFmtNo:=saZeroPadInt(iCounter,3);
    sa:=p_safilename + '.' + saFmtNo + '.' + p_saExtension;
    Inc(iCounter);
  Until (iCounter>999) OR (not FileExists(sa));
  Result:=sa;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saSequencedFilename',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================








//=============================================================================
// (Originated in Wimble Project as _bPicExists_)
// This function returns TRUE if the passed pic file in p_saPicFileName
// (filename only) exists in the "pic Database" (so to speak) on the
// harddrive. If it does exist, (function returns true) the p_saPath parameter
// returns with the RELATIVE path of the pic's directory so the results can be
// used for both web and DOS operations. Note: p_saPath is NOT touched UNLESS the
// picture is found. This makes it easy for weboperations to have a default
// "NO PICTURE PRESENT" default that gets overrided if the image DOES exist! :)
Function bFileExistsInTree(
  p_saMakeTreeWithThis: ansistring;
  p_saFilename: AnsiString;
  p_saTreeTop: AnsiString;
  Var p_saRelPath: AnsiString;
  p_i4Size: longint;
  p_i4Levels: longint
):Boolean;
//=============================================================================
Var saRelPath: AnsiString;
Begin
  saRelPath:=saFileToTreeDos(p_saMakeTreeWithThis, p_i4Size, p_i4Levels);
  Result:=fileexists(p_saTreeTop+saRelPAth+p_saFilename);
  If Result Then p_saRelPath:=saRelpath;
End;
//=============================================================================

//=============================================================================
// (Originated in Wimble project as _bStorePic_)
// This function returns TRUE if the passed pic file in p_sapicFile
// (filename only) can be successfully stored in the "pic Database"
// (so to speak). This was originally designed for the mlsimport.pas 
// application.
//
// It relies on the pic sitting in the [mlsdir]import= directory
Function bStoreFileInTree(
  p_saMakeTreeWithThis: ansistring;
  p_saSourceDirectory: AnsiString; // Containing file to store
  p_saSourceFileName: AnsiString; // Filename to copy and store (unless p_sadata is used)
  p_saDestTreeTop: AnsiString; // Top of STORAGE TREE
  p_saData: AnsiString; // If this variable is not empty - then it is used in place
  // of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
  // saved as the p_saDestFilename in the calculated tree's relative path.
  Var p_saRelPath: AnsiString; // This gets the saRelPath when its created.
  p_i4Size: longint;
  p_i4Levels: longint
):Boolean;
//=============================================================================
Var
  saImportFileNPAth:AnsiString;
  iLen: longint;
  saPath: AnsiString;
  i: longint;
  saDestination: AnsiString;
  
  u2IoResult: Word;
  
  bFileExistsAlready: Boolean;
  bOk: Boolean;
  
Begin
  bOk:=True;
  u2IOResult:=0;
  saImportFileNPath:=p_saSourceDirectory+p_saSourceFilename;
  bFileExistsAlready:=bFileExistsInTree(p_saMakeTreeWithThis,p_saSourceFilename, p_saDestTreeTop, p_saRelPath, p_i4Size, p_i4Levels);
  
  If not bFileExistsAlready Then
  Begin
    For i:= 1 To p_i4Levels Do Begin
      p_saRelPath:=saFileToTreeDos(p_saMakeTreeWithThis, p_i4Size, i);
      iLen:=length(p_saRelPAth);
      If ilen>1 Then Begin
        Delete(p_saRelPAth,iLen,1);//remove slash
        saPath:=p_saDestTreeTop+p_saRelPAth;
        // check if directory exists
        If not fileexists(saPath) Then Begin
          If not  CreateDir(saPath) Then Begin
            //jlogcnLog__WARN, 200702022142,'bStoreFileInTree Unable to create directory : ' + saPath, SOURCEFILE);
          End;
        End;
      End;
    End;
    saDestination:=saPath+csDOSSLASH+p_saSourceFilename;
  End
  Else
  Begin
    saDestination:=p_saDestTreeTop+p_saRelPAth+p_saSourceFilename;
  End;

  // Decide if we are copying a file or creating one.
  If p_saData='' Then
  Begin
    // "MOVE" file from source to destination because "tree" already built
    bOk:=bCopyFile(saImportFileNPath, saDestination);
    If not bOk Then
    Begin
      jlog(cnLog_ERROR, 20070210025,'bStoreFileInTree Unable to copy file: ' + saImportFileNPAth + ' Destination: ' + saDestination, SOURCEFILE);
    End;
    If bOk Then // don't delete if errors occurred.
    Begin
      If not DeleteFile(saImportFileNPAth) Then
      Begin
        jlog(cnLog_WARN, 20070202141,'bStoreFileInTree Unable to Delete source file: ' + saImportFileNPAth, SOURCEFILE);
      End;
    End;
  End
  Else
  Begin
    // create file in "tree" because tree built - and p_saData has data which overrides the 
    // the SOURCE file to DEST copy and creates a new file instead.
    //jlog(cnLog_DEBUG, 20070210110,'TRY SAVE Data In File Exists Already:'+satrueFalse(bFileExistsalready)+' Dest:' + saDestination, SOURCEFILE);
    If bFileExistsAlready Then 
    Begin
      bOk:=DeleteFile(saDestination);
      If not bOk Then
      Begin
        jlog(cnLog_ERROR, 201204291334,'bStoreFileInTree Unable to Delete file prior to write new one: ' + saDestination, SOURCEFILE);
      End;
    End;
    
    If bOk Then
    Begin
      bOk:=bTSIOAppend(saDestination, p_saData, u2IOResult);
      If not bOk Then
      Begin
        jlog(cnLog_ERROR, 20070202318,'bStoreFileInTree bTSIOAppend failed to save file. IORESULT:'+ saIOResult(u2IOResult)+' File: ' + saDestination , SOURCEFILE);
      End;
    End;
  End;
    
  {$IFDEF LINUX}
  u2IOResult:=u2Shell('/bin/chmod','644 "'+saDestination+'"');
  If u2IOResult<>0 Then
  Begin
    jlog(cnLog_ERROR, 20070202143,'LINUX SPECIFIC ERROR: bStoreFileInTree shell call for file permissions chmod returned non ZERO:'+ inttostr(u2IOResult)+' IOResult:'+saIOREsult(u2IOResult), SOURCEFILE);
  End;
  {$ENDIF}

  // if delete fails - oh well - not a failure necessarily.
  
  Result:=bOk;
  
End;
//=============================================================================


//=============================================================================
// This function deletes all contents of the supplied directory matching
// filespec. It Does not delete the directories. NOT related to TREE STORAGE
// routines: bFileExistsInTree or bStoreFileInTree but can be used in their
// directories if proper path is supplied. See: saFileToTreeDos function
// in ug_common.pp
Function bDeleteFilesInTree(
  p_saDirectory: AnsiString; 
  p_saFileSpec: AnsiString
):Boolean;
//=============================================================================
Var 
  JDIR: JFC_DIR;
  bSuccess: Boolean;
Begin
  bSuccess:=True;
  JDIR:=JFC_DIR.Create;
  JDIR.saFileSpec:=p_safileSpec;
  JDir.saPath:=p_saDirectory;
  if(saRightStr(JDir.saPath,1)<>csDOSSLASH) then JDir.saPath+=csDOSSLASH;
  JDir.LoadDir;
  JDir.MoveFirst;
  //riteln('Begin Loop - JDIR.Listcount:'+saStr(jdir.listcount)+' Path:'+p_saDirectory);
  repeat
    If JDir.Item_bDir Then
    Begin
      If (JDir.Item_saName<>'.') and (JDir.Item_saName<>'..') Then
      Begin
        //riteln('Nesting to:'+p_saDirectory + JDir.Item_saName);
        bSuccess:=bDeleteFilesInTree(p_saDirectory + JDir.Item_saName+csDOSSLASH, p_safileSpec);
      End;
    End
    Else
    Begin
      //riteln('WHAT:'+p_saDirectory +JDir.Item_saName);
      //if FileExists(p_saDirectory + JDir.Item_saName) then ritelN('FILE EXISTS') else riteln('FILE NOT EXIST:'+p_saDirectory + JDir.Item_saName);
      //riteln('Deleting:'+p_saDirectory + JDir.Item_saName);
      DeleteFile(p_saDirectory + JDir.Item_saName);
      bSuccess:=not FileExists(p_saDirectory + JDir.Item_saName);
    End;
    //riteln(JDIR.Item_saName);
  Until not JDIR.MoveNext;
  JDIR.Destroy;
  Result:=bSuccess;
End;
//=============================================================================

//=============================================================================
function saFileNameNoExt(p_saFileName: ansistring): ansistring;
//=============================================================================
var
  i4Len: longint;
  saFileNameOnly: ansistring;
  i4Pos: longint;
begin
  result:=p_saFilename;  
  i4Len:=length(p_saFileName);
  //riteln('length(p_saFileName):',length(p_saFileName));
  if(i4Len>0)then
  begin
    saFilenameOnly:=ExtractFileName(p_saFilename);
    //riteln('saFilenameOnly:',saFilenameOnly);
    //riteln('p_saFilename:',p_saFilename);
    i4Pos:=pos('.',saFilenameOnly);
    //riteln('i4Pos:',i4Pos);
    if(i4Pos>0)then
    begin
      result:=saLeftStr(p_saFilename,i4Len - (length(saFilenameOnly)-i4Pos+1));
    end;
  end;
  //riteln('result:',result);
end;
//=============================================================================


//=============================================================================
{}
// File Saving function. Uses TEXT mode with a Write (versus a 
// writeln) so in theory should be useful for various file types even though
// creates file of text.
function bSaveFile(
  p_saFilename: ansistring;
  p_saFileData: ansistring;
  p_iRetryLimit: longint;
  p_iRetryDelayInMSecs: longint;
  var p_u2IOResult: word;
  p_bAppend: boolean
):boolean;
//=============================================================================
var 
  bOk: boolean;
  f: text;
  iRetries: longint;
  //u4Numread: cardinal;
  //b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  //lpB: pointer;
  //lpSA: pointer;
  //u4OldLen: LongWord;
  pvt_u1OldFileMode: byte;
begin
  iRetries:=0;
  //u4Numread:=0;
  //u4OldLen:=0;
  bOk:=false;

  {$I-}
  assign(f,p_saFilename);
  {$I+}
  p_u2IOResult:=ioresult;
  bOk:=(p_u2IOResult=0);

  if bOk then 
  begin
    //p_u2IOResult:=0;// Make sure its ZERO is all.
    repeat 
      try
        pvt_u1OldFileMode := filemode;
        //filemode := WRITE_ONLY;
        filemode:=READ_WRITE;
        {$I-}
        if(p_bAppend)then
        begin
          append(f);
        end
        else
        begin
          rewrite(f);
        end;
        {$I+}
      finally  
        p_u2IOResult:=ioresult;
        filemode := pvt_u1OldFileMode;
      end;
      if p_u2IOResult<>0 then 
      begin
        bOk:=false;
        iRetries+=1; 
        Yield(p_iRetryDelayInMSecs);
      end
      else
      begin
        bOk:=true;
      end;    
    until bOk or (iRetries>p_iRetryLimit);
  end;

  if bOk then
  begin
    {$I-}
    write(f,p_saFileData);
    {$I+}
    p_u2IOResult:=ioresult;
    bOk:=(p_u2IOResult=0);
    try
      {$I-}
      close(f);
      {$I+}
    finally
      if(bOk)then
      begin
        p_u2IOResult:=ioresult;
        bOk:=(p_u2IOResult=0);
      end;
    end;
  end;
  Result:=bOk;
end;
//=============================================================================



//=============================================================================
function dtGetFileCreated(p_saFilename: ansistring):TDateTime;
//=============================================================================
var rDirBuf:SearchRec;
//    TS: TTIMESTAMP;
begin
  FindFirst(p_saFilename,anyfile, rDirBuf);
  result:=FileDateToDateTime(rDirBuf.Time);
  FindClose(rDirBuf);
end;
//=============================================================================


//=============================================================================
function saExtractDir(p_sa: ansiString): ansistring;
//=============================================================================
var
  sDir:  string[255]; 
  sName: string[255];
  sExt: string[255];
begin
  FSplit(p_sa,sDir,sName,sExt);
  result:=sDir;
end;

//=============================================================================















//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Logging
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Function saIOAppendLogColumnHeaders(
  Var p_rIOAppendLog: rtIOAppendLog
): AnsiString;
//=============================================================================
Var i: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saIOAppendLogColumnHeaders',SOURCEFILE);
  {$ENDIF}
  
  Result:='';
  With p_rIOAppendLog Do Begin
    If iColumns>0 Then Begin
      For i:=0 To iColumns-1 Do Begin
        Result:=Result + saQuoteBegin + arColumns[i].saName;
        If length(saQuoteEnd)>0 Then Begin
          Result:=Result + saQuoteEnd;
        End Else Begin
          Result:=Result + saQuoteBegin;
        End;
        If i<(iColumns-1) Then Result:=Result+',';         
      End;
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saIOAppendLogColumnHeaders',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function saIOAppendLogColumnData(
  Var p_rIOAppendLog: rtIOAppendLog
): AnsiString;
//=============================================================================
Var i: longint;
  // These are functions within a function. Note that the "V"
  // represents Variant on these functions.
  //----
  Function DoVNumber(p_i: longint; Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
  Begin  Result:=p_rIOAppendLog.arColumns[p_i].vValue;  End;
  //----
  Function DoVText(p_i: longint; Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
  Var
    sa: AnsiString;
    il: longint; // length of vdata string of somesort
    iqb: longint;// length of saquotebegin
    iqe: longint;// length of quote end
  Begin
    // In theory, this assures conversion to Ansistring
    sa:=p_rIOAppendLog.arColumns[i].vValue;
    il:=length(sa);
    iqb:=length(p_rIOAppendLog.saQuoteBegin);
    iqe:=length(p_rIOAppendLog.saQuoteEnd);
    // NOTE: Routine Presumes you have readable quote delimiters, or none at all.
    // there isn't a conversion of saQuoteBegin and saQuoteEnd
    Result:='';
    If il>0 Then Begin
      If iqb>0 Then Begin // NOTE: If saQuoteBegin Is Zero Length, then saQuoteEnd is ignored 100%
        Result:=saSNRStr(sa, p_rIOAppendLog.saQuoteBegin, cs_IOAppendLog_QuoteBeginTemp);
        If iqe>0 Then Begin 
          Result:=saSNRStr(Result, p_rIOAppendLog.saQuoteEnd, cs_IOAppendLog_QuoteEndTemp);
        End;//if
      End;//if
      //Result:=saSNRStr(saHumanReadable(Result),',','(comma)');
      Result:=saSNRStr(sa, cs_IOAppendLog_QuoteBeginTemp,p_rIOAppendLog.saQuoteBeginEsc);
      Result:=saSNRStr(Result, cs_IOAppendLog_QuoteEndTemp, p_rIOAppendLog.saQuoteEndEsc);
      If iqb>0 Then Begin 
        Result:=p_rIOAppendLog.saQuoteBegin + Result;
        If iqe>0 Then Begin
          Result:=Result + p_rIOAppendLog.saQuoteEnd;
        End Else Begin
          Result:=Result + p_rIOAppendLog.saQuoteBegin;
        End;//if
      End;//if
    End;//if       
  End;
 
  //----
  // NOTE: Don't use a Date format with Commas!!! 
  // We are making a comma delimited file afterall.
  // Inside of String and Date Quotes? Don't care.
  // No String and Date Quotes? No COMMAS!
  Function DoDate(p_i: longint; Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
  Var sa: AnsiString;
      dt: TDATETIME;
  Begin
    dt:=p_rIOAppendLog.arColumns[i].vValue;
    DateTimeToString(sa, p_rIOAppendLog.saDateFormat,dt);
    Result:=p_rIOAppendLog.saDateQuoteBegin + sa;
            
    If length(p_rIOAppendLog.saDateQuoteEnd)>0 Then Begin
      Result:=Result+p_rIOAppendLog.saDateQuoteEnd;
    End Else Begin
      Result:=Result+p_rIOAppendLog.saDateQuoteBegin;
    End;
  End;


Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saIOAppendLogColumnData',SOURCEFILE);
  {$ENDIF}
  
  Result:='';
  With p_rIOAppendLog Do Begin
    If iColumns>0 Then Begin
      For i:=0 To iColumns-1 Do Begin
        With arColumns[i] Do Begin
          Case u2JDType Of
          cnJDType_i1       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_i2       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_i4       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_i8       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
        //cnJDType_i16      :result:= result + DoJI16Number(i,p_rIOAppendLog);
        //cnJDType_i32      :result:= result + DoJI32Number(i,p_rIOAppendLog);
          cnJDType_u1       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_u2       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_u4       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_u8       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
        //cnJDType_u16      :result:= result + DoJI16Number(i,p_rIOAppendLog);
        //cnJDType_u32      :result:= result + DoJI32Number(i,p_rIOAppendLog);
          cnJDType_fp       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_fd       :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_cur      :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_ch       :Result:= Result + DoVText(i,p_rIOAppendLog);
          cnJDType_chu      :Result:= Result + DoVText(i,p_rIOAppendLog);
          cnJDType_b        :Result:= Result + DoVNumber(i,p_rIOAppendLog);
          cnJDType_dt       :Result:= Result + DoDate(i,p_rIOAppendLog);
          cnJDType_s        :Result:= Result + DoVText(i,p_rIOAppendLog);
          cnJDType_su       :Result:= Result + DoVText(i,p_rIOAppendLog);
          cnJDType_sn       :Result:= Result + DoVText(i,p_rIOAppendLog);
          cnJDType_sun      :Result:= Result + DoVText(i,p_rIOAppendLog);
          Else
            // cnJegasType_Unknown  or not yet supported
            Result:= Result + ''; // just for documentation purposes
            // NOTE: Commented out lines in case statement above are unsupported
            // in freepascal and JEGAS at this time. It is possible to
            // add support for this in freepascal easily enough, but as a time saver
            // because this lib needs to be made usable sooner than later, 
            // I'll be a revisit kind of thing. (Mostly because of the 
            // value to text representation/and back conversion routines
            // that would need to be written.
          End; //case
          If i<iColumns-1 Then Begin
            Result:=Result + ',';
          End;
        End;//with
      End;//for
    End;//if
  End;//with
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saIOAppendLogColumnData',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
//function bIOAppendLog(
//  var p_rIOAppendLog: rtIOAppendLog
//):boolean;
////=============================================================================
//var u2IoResultDummy: word;
//Begin
//  u2IoResultDummy:=0;
//  Result:=bIOAppendLog(p_rIOAppendLog, u2IoResultDummy);
//End;
//-----
Function bIOAppendLog(
  Var p_rIOAppendLog: rtIOAppendLog
):Boolean;
//=============================================================================
Var bSuccess: Boolean;
    u2LastIOResult: Word;
    sa: AnsiString;    
    bOkToLog: Boolean;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bIOAppendLog',SOURCEFILE);
  {$ENDIF}
  bSuccess:=True;
  If not p_rIOAppendLog.bLoggingDisabled Then 
  Begin  
    // Severity happens at a lower level - Severity of ZERO logs EVERYTHING!
    // TRICK: You can get your "would be logging metrics"
    // by setting logging bLoggingDisabled false(default) to TRUE, but 
    // setting the u2LogType filter to -1
    // Good for still getting metrics.
    
    
    bOkToLog:=((p_rIOAppendLog.u2LogType_ID=1) or  
              (p_rIOAppendLog.u2LogType_ID<=grJASConfig.iLogLevel));
              
    
    //bOkToLog:=true;
    writeln('201501180914 - Ok to Log?: ',saTrueFalse(bOkToLog),' Log Type:',p_rIOAppendLog.u2LogType_ID,' LogLevel: '+inttostr(grJASConfig.iLogLevel));
    //riteln('ENTRY:'+saIOAppendLogColumnData(p_rIOAppendLog)+csEOL);
    
    
    If bOKtoLog Then 
    Begin
      u2LastIOResult:=0;
      If not FileExists(p_rIOAppendLog.saFilename) Then  
      Begin
        sa:=saIOAppendLogColumnHeaders(p_rIOAppendLog) + csEOL;
        
        // ORIGINAL
        //bSuccess := bIOAppend(p_rIOAppendLog.saFilename, 
        //                      sa,
        //                      u2LastIOResult);
        
        // Hopefully a Thread Safe alternative
        //DEBUG ----- Test code that to see why FileExist Was failing on some files --- BEGIN
        //riteln;
        //riteln('Column headers asked to be written to log file.');
        //riteln('gu2LastFileExistIOResult = ',gu2LastFileExistIOResult);
        //riteln(saIOResult(gu2LastFileExistIOResult));
        //halt(0);
        //DEBUG ----- Test code that to see why FileExist Was failing on some files --- END
        
        bSuccess := bTSIOAppend(p_rIOAppendLog.saFilename, 
                              sa,
                              u2LastIOResult);
      End;
      If bSuccess Then 
      Begin
        sa:=saIOAppendLogColumnData(p_rIOAppendLog)+csEOL;
        
        // ORIGINAL
        //bSuccess := bIOAppend(p_rIOAppendLog.saFilename, 
        //                      sa,
        //                      u2LastIOResult);
        
        // Hopefully a Thread Safe alternative
        bSuccess := bTSIOAppend(p_rIOAppendLog.saFilename, 
                              sa,
                              u2LastIOResult);
      End;
      p_rIOAppendLog.u2IOResult:=u2LastIOResult;  
      if grJASConfig.bLogMessagesShowOnServerConsole then JASPrintln(sa);
    End;
        
  End;

  // Metrics :)
  p_rIOAppendLog.iLogEntries_Total+=1;// Total count, incremented each time a specific log is written to
  case p_rIOAppendLog.u2LogType_ID of
  cnLog_NONE:      p_rIOAppendLog.iLogEntries_NONE+=1; //DEFAULT LOGGING LEVEL
  cnLog_DEBUG:     p_rIOAppendLog.iLogEntries_DEBUG+=1;
  cnLog_FATAL:     p_rIOAppendLog.iLogEntries_FATAL+=1;
  cnLog_ERROR:     p_rIOAppendLog.iLogEntries_ERROR+=1;
  cnLog_WARN:      p_rIOAppendLog.iLogEntries_WARN+=1;
  cnLog_INFO:      p_rIOAppendLog.iLogEntries_INFO+=1;
  else begin
    if (p_rIOAppendLog.u2LogType_ID >= cnLog_RESERVED) and (p_rIOAppendLog.u2LogType_ID < cnLog_USERDEFINED)then
    begin
      p_rIOAppendLog.iLogEntries_RESERVED+=1;
    end
    else
    begin
      p_rIOAppendLog.iLogEntries_USERDEFINED+=1;
    end;
  end;
  end;//endcase
  
  
  p_rIOAppendLog.dtLogEntryLast:=now; // NOW is DateTime already no conversion needed
  If (p_rIOAppendLog.iLogEntries_Total=1) Then 
  begin
    p_rIOAppendLog.dtLogEntryFirst:=now;
  end;

  Result:=bSuccess;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bIOAppendLog',SOURCEFILE);
  {$ENDIF}
End;  
//=============================================================================






//=============================================================================
// INTERNAL
Function JLog(
  p_u2LogType_ID: word;
  p_u8Entry_ID: UInt64; // Probably Integer on many DBMS - Oh Well, never negative..so..
  p_saEntryData: AnsiString;
  p_saSourceFile: AnsiString
): Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('JLog200609191910',SOURCEFILE);
  {$ENDIF}
  Result:=True;
  //riteln('grJegasCommon.rJegasLog.bLoggingDisabled:',grJegasCommon.rJegasLog.bLoggingDisabled);
  // Same Filter Logic as other bIOAppendLog ... to prevent needless 
  // CPU cycles because this gets called alot.
  With grJegasCommon.rJegasLog Do Begin
    If not bLoggingDisabled Then
    Begin  
      // Severity happens at a lower level - Severity of ZERO logs EVERYTHING!
      // TRICK: You can get your "would be logging metrics"
      // by setting logging bLoggingDisabled false(default) to TRUE, but 
      // setting the SeverityLogLevel filter to -1
      // Good for still getting metrics.

      
      // Date and Time the Log Entry was created
      With arColumns[00] Do Begin
        //saColumnName:='JLOGT_DateNTime_dt';
        //u2JDType:=cnJegasType_jdt;
        vValue:=now;
      End;

      With arColumns[01] Do Begin
        //saColumnName:='JLOGT_Severity_u1';
        //u2JDType:=cnJegasType_u1;
        vValue:=p_u2LogType_ID;
      End;

      With arColumns[02] Do Begin
        //saColumnName:='JLOGT_Entry_ID';
        //u2JDType:=cnJegasType_u;
        vValue:=p_u8Entry_ID;
      End;

      With arColumns[03] Do Begin
        //saColumnName:='JLOGT_EntryData_s';
        //u2JDType:=cnJegasType_s;
        vValue:=p_saEntryData;
      End;
      
      // Actual Program Source File that has made the
      // call. Note: When releasing systems, you may not
      // want this field populated, however I have found
      // it invaluable with debugging.
      With arColumns[04] Do Begin
        //saColumnName:='JLOGT_SourceFile_s';
        //u2JDType:=cnJegasType_s;
        vValue:=p_saSourceFile;
      End;
    

      // This is to contain the user id as JEGAS sees
      // it, as it relates to the Jegas System.
      // See rtJegasCommon - as it has this field,
      // as well as the system user name (os dependant),
      // and where applicable, the network login name
      // which can be different as well (os and os config
      // dependant)
      With arColumns[05] Do Begin
        //saColumnName:='JLOGT_JUser_u';
        //u2JDType:=cnJegasType_u;
        vValue:=grJegasCommon.u8JegasUserID;
      End;

    
      // To Username as Operating System Sees it (when implemented)
      With arColumns[06] Do Begin
        //saColumnName:='JLOGT_OS_Login_s';
        //u2JDType:=cnJegasType_s;
        // vData:="Not Supported Yet"
        // Default already Assigned ;)
        // Not implemented yet
      End;
    
      // is populated with the commandline used to invoke the app.
      With arColumns[07] Do Begin
        //saColumnName:='JLOGT_CmdLine_s';
        //u2JDType:=cnJegasType_s;
        vValue:=grJegasCommon.saCmdLine;
      End;
    
      //with arColumns[] do begin
      //  saColumnName:=
      //  i4JDType:=
      //  saData:=""
      //end;
      //riteln('appending the log');
      result:=bIOAppendLog(grJegasCommon.rJegasLog);
      if result then 
      begin
        Result:=grJegasCommon.rJegasLog.u2IOResult=0;
      end;
    End;
  End;
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('JLog200609191910',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


















//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Date-n-Time 
//*****************************************************************************
//==========================================================================
//*****************************************************************************
//=============================================================================
//=============================================================================
Function tsAddYears(p_tsFrom: TTIMESTAMP; p_iYears: longint): TTIMESTAMP;
//=============================================================================
Var iMonthsToAdd: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddYears',SOURCEFILE);
  {$ENDIF}
  
  iMonthsToAdd:=p_iYears * 12;
  Result:=tsAddMonths(p_tsFrom, iMonthsToAdd);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddYears',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tsAddMonths(p_tsFrom: TTIMESTAMP; p_iMonths: longint): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddMonths',SOURCEFILE);
  {$ENDIF}
  
  Result:=DateTimeToTimeStamp(
        IncMonth(
          TimeStampToDateTime(p_tsFrom),
          p_iMonths)
      );
  Result.time:=p_tsfrom.time;
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddMonths',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tsAddDays(
p_tsFrom: TTIMESTAMP; // Value gets hacked - Use BY VALUE
p_iDays: longint): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddDays',SOURCEFILE);
  {$ENDIF}
  p_tsFrom.Date+=p_iDays;
  Result:=p_tsFrom;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddDays',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tsAddHours(p_tsFrom: TTIMESTAMP; p_Comp_Hours: Comp): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddHours',SOURCEFILE);
  {$ENDIF}
  
  Result:=tsaddmsec(p_tsfrom, p_Comp_Hours*60*60*1000);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddHours',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tsAddMinutes(p_tsFrom: TTIMESTAMP; p_Comp_Minutes: Comp): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddMinutes',SOURCEFILE);
  {$ENDIF}
  
  Result:=tsaddmsec(p_tsfrom, p_Comp_Minutes*60*1000);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddMinutes',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tsAddSec(p_tsFrom: TTIMESTAMP; p_Comp_Seconds: Comp): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddSec',SOURCEFILE);
  {$ENDIF}
  
  Result:=tsaddmsec(p_tsfrom, p_Comp_Seconds*1000);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddSec',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tsAddMSec( 
  p_tsFrom: TTIMESTAMP; // PASS BY Value - Gets Hacked
  p_Comp_MSec: Comp
): TTIMESTAMP;
//=============================================================================
//Var 
//  TSMilliSeconds: Comp;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsAddMSec',SOURCEFILE);
  {$ENDIF}
  
  Result:=MSecsToTimeStamp(TimeStampToMSecs(p_tsFrom)+p_Comp_MSec);

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsAddMSec',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

{
//=============================================================================
Function tsAdd(p_tsFrom, p_tsTo: TTIMESTAMP): TTIMESTAMP;
//=============================================================================
Begin
  Result:=MSecsToTimeStamp(TimeStampToMsecs(p_tsTo)+TimeStampToMSecs(p_tsTo));
End;
//=============================================================================
}
//=============================================================================
Function iDiffYears(p_tsFrom: TTIMESTAMP;p_tsTo: TTIMESTAMP):longint ;
//=============================================================================
Var
  stFrom, stTo: TSYSTEMTIME;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffYears',SOURCEFILE);
  {$ENDIF}
  
  DateTimeToSystemTime(TimeStampToDateTime(p_tsTo), stTo);
  DateTimeToSystemTime(TimeStampToDateTime(p_tsFrom), stFrom);
  Result:=stTo.Year - stFrom.Year;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffYears',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMonths(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffMonths',SOURCEFILE);
  {$ENDIF}
  
  Result:=iDiffMonths(TimeStampToDateTime(p_tsFrom),
                      TimeStampToDateTime(p_tsTo));
                      
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMonths',SOURCEFILE);
  {$ENDIF}                   
End;
//=============================================================================


//=============================================================================
Function iDiffDays(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffDays',SOURCEFILE);
  {$ENDIF}
  
  Result:=p_tsTo.Date-p_tsFrom.Date;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffDays',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffHours(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Var ts: TTIMESTAMP;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffHours',SOURCEFILE);
  {$ENDIF}
  
  ts:=tsDiff(p_tsFrom, p_tsTo);
  Result:=(ts.date*24)+(ts.time Div (1000*60*60) );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffHours',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMinutes(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Var
  ts: TTIMESTAMP;
  i8Result: int64;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffMinutes',SOURCEFILE);
  {$ENDIF}

  ts:=tsDiff(p_tsFrom, p_tsTo);
  //Result:=(ts.date*24*60)+(ts.time Div (1000*60) );
  //i8Result:=(ts.date*1440)+(ts.time Div (60000) );
  //ts.date:=ts.date-1440;

  //if (ts.date<=0) then
  //begin
  //  if (ts.date<0) then
  //  begin
  //    ts.Time:=ts.Time*-1;
  //  end;
  //  ts.Date+=1;
  //end;
  i8Result:=((ts.date)*1440)+(ts.time Div (60000) );

  result:=i8Result;

  {
  riteln('-----------------');
  riteln('ts.date:',ts.date, ' from: ',formatdatetime('yyyy-mm-dd hh:nn:ss',TimeStamptodatetime(p_tsFrom)));
  riteln('ts.time:',ts.time, ' to: ',formatdatetime('yyyy-mm-dd hh:nn:ss',TimeStamptodatetime(p_tsTo)));
  riteln('(ts.date)*1440: ',(ts.date)*1440);
  riteln('(ts.time Div (60000) ):',(ts.time Div (60000)));
  riteln('result:',result,' divided by 60: ',result div 60,' r:',result mod 60);
  riteln('-----------------');
  }

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMinutes',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function iDiffSeconds(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Var ts: TTIMESTAMP;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffSeconds',SOURCEFILE);
  {$ENDIF}

  ts:=tsDiff(p_tsFrom, p_tsTo);
  //Result:=(ts.date*24*60*60)+(ts.time Div 1000 );
  Result:=(ts.date*86400)+(ts.time Div 1000 );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffSeconds',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMSec(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): longint;
//=============================================================================
Var ts: TTIMESTAMP;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffMSec',SOURCEFILE);
  {$ENDIF}

  ts:=tsDiff(p_tsFrom, p_tsTo);
  //Result:=(ts.date*24*60*60*1000)+ts.time;
  Result:=(ts.date*86400000)+ts.time;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMSec',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tsDiff(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): TTIMESTAMP;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('tsDiff',SOURCEFILE);
  {$ENDIF}

  Result.date:=p_tsTo.Date-p_tsFrom.Date;
  Result.time:=p_tsTo.Time-p_tsFrom.Time;  

{
  If Result.time<0 Then Begin
    Result.Time:=Result.Time*-1;
    Result.Date-=1;
  End Else If Result.time>MSecsPerDay Then Begin
    Result.time-=MSecsPerDay;
    Result.Date+=1;
  End;
}

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('tsDiff',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function saFormatTimeStamp(
  p_saFormat: AnsiString; 
  p_ts: TTIMESTAMP
): AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saFormatTimeStamp',SOURCEFILE);
  {$ENDIF}
 
  Result:=FormatDateTime(p_saFormat,TimeStampToDateTime(p_ts));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saFormatTimeStamp',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function StrToTimeStamp(p_sa: AnsiString):TTIMESTAMP;
//=============================================================================
Var dt: TDATETIME;
    //ts: TTIMESTAMP;
    //st: TSYSTEMTIME;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('StrToTimeStamp',SOURCEFILE);
  {$ENDIF}
 
  Try 
    dt:=StrToDateTime(p_sa)
  Except 
    On eConvertError Do 
    Begin
      Result:=DateTimeToTimeStamp(now());
      JLog(cnLog_ERROR, 200609131523, 'Passed String could not be converted to TimeStamp Properly!! Passed String to Convert Ultimately to TimeStamp:' + p_sa, SOURCEFILE);
      Exit;// Abort
    End;
  End;
  // This does not generate errors according to fpc PRE 2.0.4 docs 
  // I've read... namely 2.0.2 docs I think.
  Result:=DateTimeToTimeStamp(dt);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('StrToTimeStamp',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function saFormatDateTime(p_saFormat: AnsiString; p_dt: TDATETIME): AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saFormatDateTime',SOURCEFILE);
  {$ENDIF}

  Result:=FormatDateTime(p_saFormat, p_dt);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saFormatDateTime',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function dtAddYears(p_dtFrom: TDATETIME; p_iYears: longint): TDATETIME;
//=============================================================================
Var iMonthsToAdd: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddYears',SOURCEFILE);
  {$ENDIF}

  iMonthsToAdd:=p_iYears*12;
  Result:=TimeStampToDateTime(
    tsAddMonths(
      DateTimeToTimeStamp(p_dtFrom), 
      iMonthsToAdd
    )
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddYears',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddMonths(p_dtFrom: TDATETIME; p_iMonths: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddMonths',SOURCEFILE);
  {$ENDIF}
  
  Result:=IncMonth(p_dtFrom, p_iMonths);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddMonths',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddDays(p_dtFrom: TDATETIME; p_iDays: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddDays',SOURCEFILE);
  {$ENDIF}

  Result:=TimeStampToDateTime(
    tsAddDays(DateTimeToTimeStamp(p_dtFrom), p_iDays)
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddDays',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddHours(p_dtFrom: TDATETIME; p_iHours: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddHours',SOURCEFILE);
  {$ENDIF}

  Result:=TimeStampToDateTime(
    tsAddHours(DateTimeToTimeStamp(p_dtFrom), p_iHours)
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddHours',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddMinutes(p_dtFrom: TDATETIME; p_iMinutes: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddMinutes',SOURCEFILE);
  {$ENDIF}

  Result:=TimeStampToDateTime(
    tsAddMinutes(DateTimeToTimeStamp(p_dtFrom), p_iMinutes)
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddMinutes',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddSec(p_dtFrom: TDATETIME; p_iSeconds: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddSec',SOURCEFILE);
  {$ENDIF}

  Result:=TimeStampToDateTime(
    tsAddSEC(DateTimeToTimeStamp(p_dtFrom), p_iSeconds)
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddSec',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function dtAddMSec(p_dtFrom: TDATETIME; p_iMSec: longint): TDATETIME;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('dtAddMSec',SOURCEFILE);
  {$ENDIF}

  Result:=TimeStampToDateTime(
    tsAddMSEC(DateTimeToTimeStamp(p_dtFrom), p_iMSEc)
  );
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('dtAddMSec',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function iDiffYears(p_dtFrom: TDATETIME; p_dtTo: TDATETIME):longint ;
//=============================================================================
Var
  stFrom, stTo: TSYSTEMTIME;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffYears',SOURCEFILE);
  {$ENDIF}

  DateTimeToSystemTime(p_dtTo, stTo);
  DateTimeToSystemTime(p_dtFrom, stFrom);
  Result:=stTo.Year - stFrom.Year;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffYears',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMonths(
  p_dtFrom: TDATETIME; // Pass BY VALUE, gets hacked
  p_dtTo: TDATETIME    // Pass by VALUE, gets hacked
): longint;
// This is a funky way to do it, but necessary as far as I know because
// it manages to handle the leap year stuff by leveraging the FreePascal
// IncMonth Function. This works out to be accurate, versus day math like
// days divided by some guess'timate like 30 days a month - which is skewed.
//=============================================================================
 Begin
   {$IFDEF DEBUGBEGINEND}
     DebugIN('iDiffMonths(p_dtFrom: TDATETIME;p_dtTo: TDATETIME):longint',SOURCEFILE);
   {$ENDIF}
 
  Result:=0;
  If p_dtFrom<p_dtTo Then Begin
    repeat
      //riteln(DateToStr(p_dtFrom));
      p_dtFrom:=IncMonth(p_dtFrom,1);
      If p_dtFrom<=p_dtTo Then Result+=1;
    Until p_dtFrom>=p_dtTo;
  End Else If p_dtFrom>p_dtTo Then Begin
    repeat
      p_dtFrom:=IncMonth(p_dtFrom,-1);
      If p_dtFrom>=p_dtTo Then Result-=1;
    Until p_dtFrom<=p_dtTo;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMonths(p_dtFrom: TDATETIME;p_dtTo: TDATETIME):longint',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function iDiffDays(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
// This looks recursive but its not - there are two versions of many of the 
// datetime functions - one for freepascal TDATETIME and one for OS TIMESTAMPS.
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffDays',SOURCEFILE);
  {$ENDIF}

  Result:=iDiffDays(DateTimeToTimeStamp(p_dtFrom), DateTimeToTimeStamp(p_dtTo));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffDays',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
// by val - both
Function iDiffHours(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffHours',SOURCEFILE);
  {$ENDIF}

  Result:=iDiffHours(DateTimeToTimeStamp(p_dtFrom), DateTimeToTimeStamp(p_dtTo));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffHours',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMinutes(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffMinutes',SOURCEFILE);
  {$ENDIF}

  Result:=iDiffMinutes(DateTimeToTimeStamp(p_dtFrom), DateTimeToTimeStamp(p_dtTo));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMinutes',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffSeconds(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffSeconds',SOURCEFILE);
  {$ENDIF}

  Result:=iDiffSeconds(DateTimeToTimeStamp(p_dtFrom), DateTimeToTimeStamp(p_dtTo));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffSeconds',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDiffMSec(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDiffMSec',SOURCEFILE);
  {$ENDIF}

  Result:=iDiffMSec(DateTimeToTimeStamp(p_dtFrom), DateTimeToTimeStamp(p_dtTo));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDiffMSec',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
// cheap milli sec thing - returns milliseconds since midnight.
Function iMSec(p_dt: TDATETIME):longint;
//=============================================================================
Var
  TS:TTIMESTAMP;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iMSec(p_dt: TDATETIME):longint',SOURCEFILE);
  {$ENDIF}

  TS:=DateTimeToTimeStamp(p_dt);
  iMSec:=TS.Time;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iMSec(p_dt: TDATETIME):longint',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
// cheap milli sec thing - returns milliseconds since midnight
// This is the Same as the above version of this routine except this one
// uses the system clock with the sysutils' NOW function.
Function iMSec:longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iMSec:longint',SOURCEFILE);
  {$ENDIF}

  Result:=imsec(now);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iMSec:longint',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure WaitInMSec(p_iMilliSeconds: longint);
//=============================================================================
// Had to mod this routine to not use Windows kernal32 call 20060428
{$IFDEF linux}
Var
  TS:TTIMESTAMP;
  iDone: longint;
  bFlipped: Boolean;
{$ENDIF}


Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('WaitInMSec',SOURCEFILE);
  {$ENDIF}

  {$IFDEF Win32}
  Sleep(p_iMilliseconds);
  {$ENDIF}

  {$IFDEF LINUX}
    If p_iMilliseconds>=1000 Then Begin
      TS:=DateTimeToTimeStamp(Now);
      iDone:=TS.Time+p_iMilliSeconds;
      If iDone<0 Then iDone:=iDone*-1;
      If iDone<TS.Time Then bFlipped:=False Else bFlipped:=True;
      repeat
        TS:=DateTimeToTimeStamp(Now);
        If TS.Time=0 Then bFlipped:=True;
      Until (TS.Time>=iDone) and (bFlipped);
    End;
  {$ENDIF}
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('WaitInMSec',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

// sysutils consts
{SecsPerDay = 24 * 60 * 60; // Seconds and milliseconds per day
MSecsPerDay = SecsPerDay * 1000;
DateDelta = 693594; // Days between 1/1/0001 and 12/31/1899}
//=============================================================================
Procedure WaitInSec(p_iSeconds:longint);
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('WaitInSec',SOURCEFILE);
  {$ENDIF}

  WaitInMSec(p_iSeconds * 1000);
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('WaitInSec',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
// Private Functions for JDATE
Function iMilitaryHours(
  p_saAMPMFLAG: AnsiString; 
  p_iHours: longint):longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iMilitaryHours',SOURCEFILE);
  {$ENDIF}
   p_saAMPMFLAG:=uppercase(p_saAMPMFLAG);

  //asPrintln('Military hours params: ampm:'+p_saAMPMFlag +' hours: '+inttostr(p_iHours));

  If((p_saAMPMFLAG='PM') and ((p_iHours)<12)) Then
  Begin
    Result:=(p_iHours+12);//Make Military HOURS
  End
  Else
  Begin
    If(p_saAMPMFLAG='AM') and (p_iHours=12) Then
    Begin
      Result:=0;//Make Military HOURS
    End
    Else
    Begin
      Result:=p_iHours;
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iMilitaryHours',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function iNormalHours(p_saAMPMFLAG: AnsiString; p_iHours: longint): longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iNormalHours',SOURCEFILE);
  {$ENDIF}

   p_saAMPMFLAG:=uppercase(p_saAMPMFLAG);

  If(p_saAMPMFLAG='PM') and (p_iHours>12) Then
  Begin
    Result:=p_iHours-12;//Make Normal Hours
  End
  Else
  Begin
    If(p_saAMPMFLAG='AM') and (p_iHours=0)Then
    Begin
      Result:=12;//Make normal hours
    End
    Else
    Begin
      Result:=p_iHours;
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iNormalHours',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function iMilitaryToNormalHours(p_iHours:longint):longint;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iMilitaryToNormalHours',SOURCEFILE);
  {$ENDIF}

  If(p_iHours>12) Then
  Begin
    Result:=p_iHours-12;
  End
  Else
  Begin
    If(p_iHours=0) Then
    Begin
      Result:=12;
    End
    Else
    Begin
      Result:=p_iHours;// make normal hours
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iMilitaryToNormalHours',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function saAMPM(p_iMilitaryHours:longint): AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saAMPM',SOURCEFILE);
  {$ENDIF}

  If(p_iMilitaryHours>11) Then Result:='PM' Else Result:='AM';
  //ASPrintln('Military Hours: '+inttostr(p_iMilitaryHours));
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saAMPM',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function iMonth(p_saMonthName:AnsiString): longint;
//=============================================================================
Var sa: AnsiString;
    i: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iMonth',SOURCEFILE);
  {$ENDIF}

  sa:=UpperCase(leftstr(p_saMonthName,3));
  Result:=0;
  For i:=1 To 12 Do
  Begin
    If(uppercase(leftstr(asaMonth[i],3))=sa)Then
    Begin
      Result:=i;//set month
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iMonth',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function iDay(p_saDayName:AnsiString): longint;
//=============================================================================
Var sa: AnsiString;
    i: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('iDay',SOURCEFILE);
  {$ENDIF}

  sa:=UpperCase(leftstr(p_saDayName,3));
  Result:=0;
  For i:=1 To 7 Do 
  Begin 
    If(uppercase(leftstr(asaDay[i],3))=sa)Then
    Begin
      Result:=i;//set Day
    End;
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('iDay',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================


{
//=============================================================================
// Compares only first theree letters
Function iAlphaMonthToNumber(p_saMonth: AnsiString): longint;
//=============================================================================
Var i: longint;
Begin
  Result:=0;
  For i=1 To 12 Do
  Begin
    If (Uppercase(saLeftStr(asaMonth[i],3))=UpperCase(saLeftStr(p_saMonth)) Then
    Begin
      Result:=i;
    End;
  End;
End;
//=============================================================================
}


////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//=============================================================================
// Variety Without Passing Date Object In OR Out
Function JDate(
  p_saDate: AnsiString; 
  p_iFormatOut: longint;
  p_iFormatIn: longint
): AnsiString;
//=============================================================================
Var dt: TDATETIME;
Begin
  dt:=0;
  Result:=JDate(p_saDate,p_iFormatOut,p_iFormatIn,dt);
End;
//=============================================================================

//=============================================================================
Function JDate(
  p_saDate: AnsiString; 
  p_iFormatOut: longint;
  p_iFormatIn: longint;
  Var p_dt: TDATETIME
): AnsiString;
//=============================================================================
Var 
  //sain: AnsiString;
  //iFmt: longint; //in format array index
  //oFmt: longint; //out format array index
  TK: JFC_TOKENIZER; // For The FORMAT INFO
  TKD: JFC_TOKENIZER; // For The Date Values
    

  m:Word;//month (1=January)
  d:Word;//days
  y:Word;//years
  h:Word;//hours
  n:Word;//minutes
  s:Word;//seconds
  mh:Word;//military hours
  ms:Word;// milliseconds (Not reall implemented yet anywhere (Used in 
  // sysutils.decodetime call though.
  dow: longint; // Day Of Week (Going out)

  //iTemp: longint;
  saTemp: ansistring;
  
  dtDate: TDATETIME;
  //sa:Ansistring;
  
  Function saZP(p_i: longint):AnsiString;
  Begin
    Result:=saZeroPadInt(p_i,2);
  End;


Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('JDate',SOURCEFILE);
  {$ENDIF}
  //asprintln('begin jdate------------------------------------------');
  //////////////////////////////////////////////////////////////////
  // This block of code is a reference to the issues found going
  // from Win32 FPC default install to linux i386 default install.
  //////////////////////////////////////////////////////////////////
  {
  IFNDEF LINUX
  //yyyy-mm-dd hh:nn:ss - Special handling for this format
  // by converting it to mm/dd/yyyy hh:nn:ss
  //function saFixedLength(p_sa: AnsiString; p_s, p_l: longint): AnsiString;
  //riteln('ug_jegas.StrToTimeStamp(',p_sa,')');
  If (p_sa[5]='-') and (p_sa[8]='-') Then
  Begin
    p_sa:=
      saFixedLength(p_sa,6,2) +'/' + 
      saFixedLength(p_sa,9,2) + '/' + 
      saFixedLength(p_sa,1,4) + ' ' + 
      saFixedLength(p_sa,12,8);
  End;
  Else
    //yyyy-mm-dd hh:nn:ss - Special handling for this format
    // by converting it to d-m-yy hh:nn because in Fedora, it 
    // seems to be default for FPC 2.0.4 in linux distro
    If (p_sa[5]='-') and (p_sa[8]='-') Then
    Begin
      p_sa:=
        Trim(saStr(iVal(saFixedLength(p_sa,9,2)))) + '-' + 
        Trim(saStr(iVal(saFixedLength(p_sa,6,2)))) +'-' + 
        saFixedLength(p_sa,3,2) + ' ' + 
        saFixedLength(p_sa,12,5);
    End;
  ENDIF
  }
  //////////////////////////////////////////////////////////////////
  
  //riteln('----JDate(p_saDate, p_saFormatOut,p_saFormatIn): AnsiString;');
  //riteln('--Diagnostics Begin---');
  //rite('p_saDate:',p_saDate,' ');
  //rite('p_iFormatIn:',p_iFormatIn,' ');
  //riteln('p_iFormatOut:',p_iFormatOut);
  //riteln('--Diagnostics End---');
  //riteln('----JDate(p_saDate, p_saFormatOut,p_saFormatIn): AnsiString;');

  
  // ///////////////////////////////////////////////////////////////////////
  // This Block was to allow for either STRING or Numeric Parameters
  // like array index of asaDateFormat[0..11] (meaning 0 thru 11)
  // or sending the actually format text itself. JavaScript Version of JDATE
  // allows for this construct. This version as of 2006-09-13 14:17 does
  // Not. Javascript is untyped, and as such, has different needs.
  // Variants add overhead in FPC I don't want to deal with unless necessary.
  //
  // Three main variables to set up, what we got, what we think it is, what 
  // we want it to become
  //sain := '';
  //iFmt := -1; //in format array index
  //oFmt := -1; //out format array index
  //If(iFmt=-1)Then 
  //Begin
  //  saFormatIn:=UpperCase(Trim(p_saFormatIn));
  //  For i:=0 To cnDateFormat_Elements Do 
  //  Begin
  //    If(saFormatIn=asaDateFormat[i])Then iFmt:=i;
  //  End;
  //  If(iFmt=-1) Then 
  //  begin
  //    Result:='BAD DATE FORMAT IN JDate() - Value Passed:'+saFormatIn;
  //    Exit Function;
  //  End;
  //End;

  //If(oFmt=-1)Then 
  //Begin
  //  saFormatOut:=UpperCase(Trim(p_saFormatOut));
  //  For i:=0 To cnDateFormat_Elements Do 
  //  Begin
  //    If(saFormatOut==asaDateFormat[i])Then oFmt:=i;
  //  End;
  //  If(oFmt==-1) Then 
  //  Begin
  //    Result:='BAD DATE FORMAT IN JDate() - Value Passed:'+saFormatIn;
  //    Exit Function;
  //  End;
  //End;

  // fill these variables - all date conversion revolve around these being set right
  m:=0;//month (1=January)
  d:=0;//days
  y:=0;//years
  h:=0;//hours
  n:=0;//minutes
  s:=0;//seconds
  mh:=0;//military hours
  ms:=0;//milli seconds
  
  TK:=JFC_TOKENIZER.Create;
  If p_iFormatIn<>0 Then // csDateFormat_00/asaDateFormats[0] is '?' for Using TDATETIME
  Begin
    TK.SetDefaults;
    //TK.saQuotes:=' /:,-';
    TK.saSeparators:=' /:,-';
    TK.saWhiteSpace:=' /:,-';  
    TK.BKeepDebugInfo:=True;
    TK.Tokenize(asaDateFormat[p_iFormatIn]);
    //TK.DumpToTextfile('JDATE_TK.txt');
    TK.BKeepDebugInfo:=False;
  End;  

  TKD:=JFC_TOKENIZER.Create;
  If p_iFormatIn<>0 Then // csDateFormat_00/asaDateFormats[0] is '?' for Using TDATETIME
  Begin
    TKD.SetDefaults;
    //TKD.saQuotes:=' /:,-';
    TKD.saSeparators:=' /:,-';
    TKD.saWhiteSpace:=' /:,-';  
    TKD.BKeepDebugInfo:=True;
    TKD.Tokenize(p_saDate);
    //TKD.DumpToTextfile('JDATE_TKD.txt');
    //ASPrintln(tkd.saHTMLTABLE);
    TKD.BKeepDebugInfo:=False;
  End;  
  
  
  Case p_iFormatIn Of
  0://date object csDateFormat_00
    Begin
      DecodeDate(p_dt,y,m,d);
      DeCodetime(p_dt,mh,n,s,ms);
      h:= iMilitaryToNormalHours(mh);//hours (Mh or Military Hours still set to original value so no data loss)
    End;
  Else
    Begin
      // MM (Month) Numeric
      If TK.FoundItem_saToken('MM',True) Then
      Begin
        m:=iVal(TKD.NthItem_saToken(TK.N));
      End;
      
      // MMM Alpha Month
      If TK.FoundItem_saToken('MMM',True) Then
      Begin
        m:=iMonth(TKD.NthItem_saToken(TK.N));
      End;
      
      // DDD Alpha Day
      //if TK.FoundItem_saToken('DDD',TRUE) then
      //begin
      //  d:=iDay(TKD.NthItem_saToken(TK.N);
      //end;


      // DD (Day) Numeric
      If TK.FoundItem_saToken('DD',True) Then
      Begin
        d:=iVal(TKD.NthItem_saToken(TK.N));
      End;
            
      // YY (Year) Numeric (2 Digit - y2k, if <80 then year 2000+)
      If TK.FoundItem_saToken('YY',True) Then
      Begin
        y:=iVal(TKD.NthItem_saToken(TK.N));
        If y<80 Then y:=y+2000 Else y:=y+1900;
      End;
            
      // YYYY (Year) Numeric (4 Digit) No Y2K
      If TK.FoundItem_saToken('YYYY',True) Then
      Begin
        y:=iVal(TKD.NthItem_saToken(TK.N));
      End;
      
      // HH (Hours) Numeric
      If TK.FoundItem_saToken('HH',True) Then
      Begin
        h:=iVal(TKD.NthItem_saToken(TK.N));
        mh:=h;
        If (TK.FoundItem_saToken('AM',True))then // OR (mh>12)) Then
        Begin
          mh:=iMilitaryHours(TKD.NthItem_saToken(TK.N), h);
          h:=iMilitaryToNormalHours(mh);
        End;
      End;

      // NN (Minutes) Numeric 
      If TK.FoundItem_saToken('NN',True) Then
      Begin
        n:=iVal(TKD.NthItem_saToken(TK.N));
      End;

      // SS (Seconds) Numeric
      If TK.FoundItem_saToken('SS',True) Then
      Begin
        s:=iVal(TKD.NthItem_saToken(TK.N));
      End;

    End;
  End;//case

  // clean up am/pm flag issue that occurs due to order
  // of above code - some values get modified - need originals for this
  // safety check
  {
  If (TK.FoundItem_saToken('AM',True)) then
  begin
    sa:=TKD.NthItem_saToken(TK.N);
    if sa='PM' then
    begin
      If TK.FoundItem_saToken('HH',True) Then
      Begin
        h:=iVal(TKD.NthItem_saToken(TK.N));
        mh:=iMilitaryHours(sa, h);
      end;
    end;
  end;
  }
  
  //riteln('--- More JDATE Diagnostics---Begin');
  //riteln('y:',y);
  //riteln('m:',m);
  //riteln('d:',d);
  //riteln('h:',h);
  //riteln('n:',n);
  //riteln('s:',s);
  //riteln('mh:',mh);
  //riteln('--- More JDATE Diagnostics---end');
  
  
  //If(y=1899)Then // handle nulls coming in (in ado anyways)
  //Begin
  //  Result:='';
  //  Exit Function;
  //End;

  Try
  dtDate:= EnCodeDate(y,m,d);
  Except
  End;
  
  Try
  dtDate:= dtDate + EnCodeTime(mh,n,s,ms);
  Except
  End;
  
  Try
  dow:=DayOfWeek(dtDate); 
  Except
  End;


  Case p_iFormatOut Of
  0: 
    Begin
      Result:='DATE RETURNED IN p_dt (3rd Param of JDATE)';
      p_dt:=dtDate;
    End;
  1://'MM/DD/YYYY HH:NN AM'
    Begin
      Result:= saZP(m)+'/'+saZP(d)+'/'+saZP(y)+' ';
      saTemp:=saAMPM(mh);
      Result+=saZP(iNormalHours(saTemp,mh))+':'+saZP(n)+' '+saTemp;
      if(Result='1899-12-30 12:00:00 PM')then
      begin
        Result:='1899-12-30 12:00:00 AM';// <---- Windows .Net Minimum Date Value (null sorta)
      end;
    End;
  2://'MM/DD/YYYY'
    Begin
      Result:= saZP(m)+'/'+saZP(d)+'/'+saZP(y);
    End;
  3://'YYYY-MM-DD'
    Begin
      Result:= saZP(y)+'-'+saZP(m)+'-'+saZP(d);
    End;
  4://'DDD MMM DD HH:MM:SS EDT YYYY'
    Begin
      //Result:='NO SUPPORT YET in FPC JDATE for format 4:' + asaDateFormat[4];
      Result:=saLeftStr(asaDay[dow],3) + ' ' + 
              saLeftStr(asaMonth[m],3) +' '+
              saZP(d)+' '+
              saZP(mh)+':'+saZP(n)+':'+saZP(s)+' EDT'+' '+saZP(y);     
    End;
  5://'DDD, DD MMM YYYY HH:MM:SS'
    Begin
      //Var ts=dtDate.toUTCString();
      //ts = ts.substr(0,ts.length-4)
      //return ts;
      //Result:='NO SUPPORT YET in FPC JDATE for format 5:' + asaDateFormat[5];
      Result:=saLeftStr(asaDay[dow],3) + ', ' + 
              saZP(d)+' '+
              saLeftStr(asaMonth[m],3) +' '+
              saZP(y)+' '+      
              saZP(mh)+':'+saZP(n)+':'+saZP(s);
    End;
  6://'DDD, DD MMM YYYY HH:MM:SS UTC'
    Begin
      //Result:='NO SUPPORT YET in FPC JDATE for format 6:' + asaDateFormat[6];
      Result:=saLeftStr(asaDay[dow],3) + ', ' + 
              saZP(d)+' '+
              saLeftStr(asaMonth[m],3) +' '+
              saZP(y)+' '+      
              saZP(mh)+':'+saZP(n)+':'+saZP(s)+' UTC';      
    End;
  7://'DDDD, DD MMM, YYYY HH:MM:SS AM'
    Begin
      //return dtDate.toLocaleDateString();
      //Result:='NO SUPPORT YET in FPC JDATE for format 7:' + asaDateFormat[7];
      Result:=saLeftStr(asaDay[dow],4) + ', ' + 
              saZP(d)+' '+
              saLeftStr(asaMonth[m],3) +' '+
              saZP(y)+' '+      
              saZP(h)+':'+saZP(n)+':'+saZP(s)+' '+saAMPM(mh);      
    End;   
  8://'HH:NN:SS'
    Begin
      Result:=saZP(mh)+':'+saZP(n)+':'+saZP(s);
    End;
  9://'HH:NN:SS EDT'
    Begin
      Result:= saZP(mh)+':'+saZP(n)+':'+saZP(s)+' EDT';
    End;
  10://'MMM DDD DD YYYY'
    Begin
      //Result:='NO SUPPORT YET in FPC JDATE for format 10:' + asaDateFormat[10];
      //Result:= String(aMonth[m-1]).substr(0,3)+' '+
      //  String(aDay[dtDate.getDay()]).substr(0,3)+' '+saZP(d)+' '+y.toString();
      Result:=saLeftStr(asaMonth[m],3) +' '+
              saLeftStr(asaDay[dow],3) + ' ' +       
              saZP(d)+' '+
              saZP(y);
    End;
  11://yyyy-mm-dd hh:nn:ss
    Begin
      Result:=saZP(Y)+'-'+saZP(M)+'-'+saZP(d)+' '+saZP(mh)+':'+saZP(n)+':'+saZP(s);
      
    End;
  12:// MM/DD/YY
    Begin
      Result:= saZP(m)+'/'+saZP(d)+'/'+saFixedLength(saZP(y),3,2);
    End;

  13:// DD/MMM/YYYY
    Begin
      Result:=saZP(d)+'/'+saLeftStr(asaMonth[m],3)+'/'+saZP(y);
    End;
  14:// DD/MMM/YYYY HH:MM AM
    Begin
      Result:=saZP(d)+'/'+saLeftStr(asaMonth[m],3)+'/'+saZP(y)+' '+
              saZP(h)+':'+saZP(n)+' '+saAMPM(mh);       
    End;
  15:// DD/MMM/YYYY HH:MM (Military)
    Begin
      Result:=saZP(d)+'/'+saLeftStr(asaMonth[m],3)+'/'+saZP(y)+' '+
              saZP(mh)+':'+saZP(n);//+':'+saZP(s);
    End;
  16:// HH:MM AM
    Begin
      Result:=saZP(h)+':'+saZP(n)+' '+saAMPM(mh);       
    End;
  17:// HH:MM
    Begin
      Result:=saZP(mh)+':'+saZP(n);
    End;
  18:// 04/Feb/2007:08:21:23  <--- Modeled after Apache Log file: [04/Feb/2007:08:21:23 -0500]
    Begin
      Result:=saZP(d)+'/'+
              saLeftStr(asaMonth[m],3)+'/'+
              saZP(y)+':'+
              saZP(mh)+':'+saZP(n)+':'+saZP(s);
    End;
  19:// 1/9/2012 13:21 <-- From Export out of Excel m/d/y hh:nn
    begin
      result:=inttostr(m)+'/'+inttostr(d)+'/'+inttostr(y)+' '+saZP(mh)+':'+saZP(n);

    end;
  20:// 01/09/2012 13:21
    begin
      result:=saZP(m)+'/'+saZP(d)+'/'+saZP(y)+' '+saZP(mh)+':'+saZP(n);
    end;
  21:// YYYY-MM-DD HH:NN Zero Padded Military Time
    Begin
      Result:=saZP(Y)+'-'+saZP(M)+'-'+saZP(d)+' '+saZP(mh)+':'+saZP(n);
    End;
  22: //DD/YYYY/MM HH:NN AM
    begin
      result:=saZP(d)+'/'+saZP(y)+'/'+saZP(m)+' '+saZP(h)+':'+saZP(n)+' '+saAMPM(mh);
    end;
  End;//case
  //asprintln('end jdate------------------------------------------');
  TK.Destroy;TKD.Destroy;Exit;
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('JDate',SOURCEFILE)
  {$ENDIF}
End;
//=============================================================================
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

















//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Strings
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Function saJegasLogoRawText(p_saEOL: AnsiString; p_bShowJASServerID: boolean): AnsiString;
//=============================================================================
Begin
  //Result:=p_saEOL+
  Result:=
    '     _________ _______  _______  ______  _______'+p_saEOL+
    '    /___  ___// _____/ / _____/ / __  / / _____/'+p_saEOL+
    '       / /   / /__    / / ___  / /_/ / / /____  '+p_saEOL+
    '      / /   / ____/  / / /  / / __  / /____  /  ';
  if p_bShowJASServerID then
  begin
    Result+=' Server ID: '+grJASConfig.saServerIdent;
  end;
  Result+=p_saEOL+
    ' ____/ /   / /___   / /__/ / / / / / _____/ /   '+p_saEOL+
    '/_____/   /______/ /______/ /_/ /_/ /______/    '+p_saEOL+
    '          Virtually Everything IT(TM)            '+p_saEOL;
End;
//=============================================================================

//=============================================================================
Function saJegasLogoRawText(p_saEOL: AnsiString): AnsiString;
//=============================================================================
begin
  result:=saJegasLogoRawText(p_saEOL, false);
end;
//=============================================================================



//=============================================================================
Function saJegasLogoRawHtml: AnsiString;
//=============================================================================
Begin
  Result:='';
  Result+='<font style="font-family: monospace; font-weight: strong;">';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;________&nbsp;&nbsp;_______&nbsp;&nbsp;_______&nbsp;&nbsp;______&nbsp;&nbsp;_______<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;/___  ___/&nbsp;/ _____/&nbsp;/ _____/&nbsp;/&nbsp;__&nbsp;&nbsp;/&nbsp;/&nbsp;_____/<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;/__&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;___&nbsp;&nbsp;/&nbsp;/_/&nbsp;/&nbsp;/&nbsp;/____&nbsp;&nbsp;<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;____/&nbsp;&nbsp;/&nbsp;/&nbsp;/&nbsp;&nbsp;/&nbsp;/&nbsp;__&nbsp;&nbsp;/&nbsp;/____&nbsp;&nbsp;/&nbsp;&nbsp;<br />';
  Result+='&nbsp;____/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;/___&nbsp;&nbsp;&nbsp;/&nbsp;/__/&nbsp;/&nbsp;/&nbsp;/&nbsp;/&nbsp;/&nbsp;_____/&nbsp;/&nbsp;&nbsp;&nbsp;<br />';
  Result+='/_____/&nbsp;&nbsp;&nbsp;/______/&nbsp;/______/&nbsp;/_/&nbsp;/_/&nbsp;/______/&nbsp;&nbsp;&nbsp;&nbsp;<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Under the Hood</font><br />';
End;
//=============================================================================

//==========================================================================
Function saOnOff(p_b:Boolean): AnsiString;
//==========================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saOnOff',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='On ' Else Result:='Off';
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saOnOff',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

//==========================================================================
Function saOneZero(p_b: Boolean):AnsiString;
//==========================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saOneZero',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='1' Else Result:='0';
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saOneZero',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

//==========================================================================
{}
// Returns English "Yes" or "No " The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "Yes" or "No "
Function saYesNo(p_b:Boolean): AnsiString;
//==========================================================================
begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saYesNo',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='Yes' Else Result:='No ';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saYesNo',SOURCEFILE)
  {$ENDIF}
end;
//==========================================================================


//==========================================================================
// Returns English "True" or "False" The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "True " or "False"
Function saTrueFalse(p_b: Boolean): AnsiString;
//==========================================================================
begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saTrueFalse',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='True ' Else Result:='False';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saYesNo',SOURCEFILE)
  {$ENDIF}
end;
//==========================================================================



//==========================================================================
Function saWindowStateToString(p_i4WindowState: LongInt): AnsiString;
//==========================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saWindowState',SOURCEFILE);
  {$ENDIF}

  Case p_i4WindowState Of 
  0: Result:= 'Normal';
  2: Result:= 'Maximized';
  1: Result:= 'Minimized';
  Else 
    Result:='Unknown';
  End;// case
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saWindowState',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

//==========================================================================
Function i4WindowStateToInt(p_saWindowState: AnsiString): LongInt;
//==========================================================================
Var sa: AnsiString;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('i4WindowState',SOURCEFILE);
  {$ENDIF}

  sa:=UpCase(p_saWindowState);
  Result:=-1;
  If sa='NORMAL' Then Result:=0;
  If sa='MAXIMIZED' Then Result:=2;
  If sa='MINIMIZED' Then Result:=1;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('i4WindowState',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

// seeuxg_common.pp for replacement
////==========================================================================
////Function saYesNo(p_bBoolean:Boolean): AnsiString;
////==========================================================================
//Begin
//  {$IFDEF DEBUGBEGINEND}
//    DebugIN('saYesNo',SOURCEFILE);
//  {$ENDIF}
//
//  If p_bBoolean Then Result:='Yes' Else Result:='No ';
//  
//  {$IFDEF DEBUGBEGINEND}
//    DebugOUT('saYesNo',SOURCEFILE)
//  {$ENDIF}
//End;
////==========================================================================

// see ug_common.pp for replacement
////==========================================================================
//Function saTrueFalse(p_bBoolean: Boolean): AnsiString;
////==========================================================================
//Begin
//  {$IFDEF DEBUGBEGINEND}
//    DebugIN('saTrueFalse', SOURCEFILE)
//  {$ENDIF}
//
//  If p_bBoolean Then Result:='True ' Else Result:='False';
// 
//  {$IFDEF DEBUGBEGINEND}
//    DebugOUT('saTrueFalse',SOURCECODE)
//  {$ENDIF}
//End;
////==========================================================================

//==========================================================================
Function saXorString(p_sa: AnsiString; p_u1Key: Byte):AnsiString;
//==========================================================================
Var i: longint;
    iLen: longint;
Begin
  Result:='';
  iLen:=length(p_sa);
  If iLen>0 Then
  Begin
    i:=0;
    repeat
      Inc(i);
      Result+=Char(Byte(p_sa[i]) xor p_u1Key);
    Until i=iLen;
  End;
End;
//==========================================================================


//==========================================================================
Function saRepeatChar(p_ch: Char; p_iHowMany: longint): AnsiString;
//==========================================================================
Begin
  Result:='';
  If p_iHowMany>0 Then 
  Begin
    repeat
      Result+=p_ch;
      dec(p_iHowMany);
    Until p_iHowMany=0;
  End;
End;
//==========================================================================

//=============================================================================
Function saNextRevisionKey(p_sa: AnsiString):AnsiString;
//=============================================================================
Var iLen: longint;
    ix: longint;
Begin
  iLen:=length(p_sa);
  If iLen=0 Then 
  Begin
    Result:='-';
  End
  Else
  Begin
    If p_sa='-' Then 
    Begin
      Result:='A';
    End
    Else
    Begin
      // Make REVISION uppercase.. period.
      p_sa:=uppercase(p_sa);
      iX:=iLen;
      repeat 
        If p_sa[iX]='Z' Then
        Begin
          p_sa[iX]:='A';
          If iX=1 Then
          Begin
            p_sa:='A' + p_sa;
          End;
        End
        Else
        Begin
          p_sa[iX]:=Char(Byte(p_sa[iX])+1);      
          iX:=1;
        End;
        dec(iX);
      Until ix=0;
      Result:=p_sa;
    End;
  End;
End;
//=============================================================================





//=============================================================================
// Passcal to C String converter
Function i4PToC(p_sa: AnsiString; Var p_cdest: PChar; p_i4DestCBuflen: LongInt):LongInt;
//=============================================================================
Var 
  iLen: LongInt;
  //i: LongInt;
Begin
  iLen:= Length(p_sa);  
  If(iLen<p_i4DestCBuflen)Then
  Begin
    strcopy(p_cdest,PChar(p_sa));
    //For i:=0 To iLen-1 Do
    //Begin
    //  p_cdest[i]:=p_sa[i+1];
    //End;
    //p_cdest[iLen]:=#0;
  End
  Else
  Begin
    iLen:=p_i4DestCBuflen-1;
    strlcopy(p_cdest,PChar(p_sa),iLen);
    //For i:=0 To iLen-1 Do
    //Begin
    //  p_cdest[i]:=p_sa[i+1];
    //End;
  End;
  p_cdest[iLen+1]:=#0;
  Result:=ilen;
End;
//=============================================================================

//=============================================================================
// C to Pascal String Converter
Function saCToP(Var p_csrc: PChar):AnsiString;
//=============================================================================
Var sa: AnsiString;
Begin
  SetLength(sa,strlen(p_csrc));
  strcopy(PChar(sa),p_csrc);
  Result:=sa;
End;
//=============================================================================







// This function takes a "DOS RELATIVE PATH" and attempts to solve it
// by removing the single and double dots ('.', '..') to give a solid
// path. This function does not verify with the operating system that
// this is valid, nor can it turn a dir of pure relative information
// into directory names. 
//
// TODO: Make work by verifying the PATH EXISTS as sent, and if it does, 
// getting that information by merely changing to that path, and extracting
// the results. e.q. getCurDir, switch to path dir, read getdir again, 
// go back to dir we started in (saved with first get dir) If directory
// can not be resolved, returned passed directory unchanged I suppose.
//
function saSolveRelativePath(p_sa: AnsiString):ansistring;
//=============================================================================
var
  TK: JFC_TOKENIZER;
  saOutDir: ansistring;
  //saTemp: ansistring;
begin
  // Fix a relative path
  TK := JFC_TOKENIZER.Create;
  TK.SetDefaults;
  TK.saSeparators:='\/';
  TK.saWhiteSpace:='\/';
  TK.Tokenize(p_sa);
  saOutDir:='';
  //riteln('saTemp:'+ saTemp);
  //riteln('TK.ListCount:', TK.ListCount);
  If TK.ListCount>0 Then
  Begin
    TK.MoveLast;
    repeat
      if(TK.item_saToken = '.') then 
      begin
        TK.DeleteItem(); // means same directory - just kill it 
      end
      else
      begin
        if(TK.item_saToken = '..') then 
        begin
          if(Tk.BOL = false) then
          begin
            Tk.DeleteItem;
            Tk.MovePrevious;
            Tk.DeleteItem;
          end;
        end;
     end;   
     //riteln('First Loop Nth:',inttostr(TK.N)); 
    until not TK.MovePrevious;          
    if TK.MoveFirst then
    begin
      repeat
        saOutDir+=TK.Item_saToken + csDOSSLASH;
      until not TK.MoveNext;          
    end;
  end;
  tk.destroy;//tk:=nil;
  Result:=saOutDir;
end;
//=============================================================================




//=============================================================================
Function saProper(p_saSentence: ansistring): ansistring;
//=============================================================================
var 
  iSpacepointer: longint;
  ip: longint;
begin
  result:=Trim(LowerCase(p_saSentence));
  If Length(Result) = 0 Then Exit;
  Result[1]:= UpCase(Result[1]);
  iSpacepointer := Pos(Result, ' ');
  repeat 
    result[iSpacepointer + 1]:=UpCase(Result[iSpacepointer + 1]);
    ip:=pos(' ',saLeftStr(result,iSpacepointer + 1));
    iSpacePointer+=ip;
  Until ip = 0;
end;   
//=============================================================================



  
  

//=============================================================================
Function saParseLastName(p_saName: ansistring): ansistring;
//=============================================================================
var
  X: longint;
  iPointer:longint;
  saTemp: ansistring;
  saName: ansistring;
  sa: ansistring;
begin   
  saName := Trim(p_saName);
  If saRightStr(saName, 1) = ',' Then saName := saLeftStr(saName, Length(saName) - 1);
  iPointer := 0;
  
  For X := Length(saName) downTo 1 do  //Step -1
  begin
    case saName[x] of
    ' ', ',': begin
      iPointer := X + 1;
      Exit;
    end;//case
    end;//switch
  end;
  
  If iPointer > 0 Then
  begin
    Result := saRightStr(saName, length(saName)-iPointer);
    saTemp := '';
    sa:=UpCase(Trim(Result));
    if (sa='JR') or (sa='JR.') or (sa='SR') or (sa='SR.') then
    begin
      saTemp:=saParseLastName(saLeftStr(saName, iPointer - 1));
    end
    else
    begin
      if (sa='II') or (sa='III') or (sa='MD') or (sa='MD.') or (sa='M.D.') or (sa='DDS') then
      begin    
        saTemp := saParseLastName(saLeftStr(saName, iPointer - 1));
      end;
    End;
    If saTemp <> '' Then Result:= saTemp;
  end
  Else
  begin
    result:='';
  end;
End;
//=============================================================================






//=============================================================================
Function saBuildName( 
  p_saDear: AnsiString; 
  p_saFirst: AnsiString; 
  p_saMiddle: AnsiString; 
  p_saLast: AnsiString; 
  p_saSuffix: ansiString 
):ansistring;
//=============================================================================
var
  r: ansistring;
begin
  r := '';
  If Length(Trim(p_saDear)) > 0 Then    r := saProper(p_saDear);
  If Length(Trim(p_saFirst)) > 0 Then   r := Trim(r) + ' ' + saProper(Trim(p_saFirst));
  If Length(Trim(p_saMiddle)) > 0 Then  r := Trim(r) + ' ' + saProper(Trim(p_saMiddle));
  If Length(Trim(p_saLast)) > 0 Then    r := Trim(r) + ' ' + saProper(Trim(p_saLast));
  If Length(Trim(p_saSuffix)) > 0 Then  r := Trim(r) + ' ' + saProper(Trim(p_saSuffix));
  result:=Trim(r);
End;
//=============================================================================


//=============================================================================
Function saPhoneConCat(p_saPhone: ansistring; p_saExt: ansistring): ansistring;
//=============================================================================
var 
  sa: ansistring;
  t: ansistring;
begin
  sa:='';
  t:=trim(p_saPhone);
  if t<>'NULL' then 
  begin
    sa:=t;
  end;
  
  t:=trim(p_saExt);
  if t<>'NULL' then
  begin
    if length(t)>0 then
    begin
      sa+=' x'+t;
    end;
  End;
  result:=sa;
End;
//=============================================================================






//=============================================================================
Procedure ParseName(
  p_In_saName: ansistring;
  var p_Out_saFirst: ansistring; 
  var p_Out_saMiddle: ansistring;
  var p_Out_saLast: ansistring
);
//=============================================================================
var 
  bOk: boolean;
  z: ansistring;
  //iTokens: longint;
  //iX: longint;
  //b: longint;
  TK: JFC_TOKENIZER;
  sa0: ansistring;
  sa1: ansistring;
  sa2: ansistring;
begin
  p_Out_saFirst:='';
  p_Out_saMiddle:='';
  p_Out_saLast:='';
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=' ';
  TK.saWhitespace:=' ';
  //TK.bKeepDebugInfo:=true;
  
  p_In_saName:=trim(p_In_saName);
  bOk:= (p_In_saName<>'NULL') and (p_In_saName<>'');
  if bOk then
  begin
    if Pos(' ',p_In_saName)<=0 then
    begin
      p_Out_saLast:=p_In_saName;
    end;
  end;
        
  p_In_saName := UpCase(Trim(p_In_saName));
  p_In_saName := saSNRStr(p_In_saName, 'MR. & MRS.','');
  p_In_saName := saSNRStr(p_In_saName, 'MR.& MRS.','');
  p_In_saName := saSNRStr(p_In_saName, 'MR.&MRS.','');
  p_In_saName := saSNRStr(p_In_saName, 'MR.& MRS.','');
  p_In_saName := saSNRStr(p_In_saName, 'MR.','');
  p_In_saName := saSNRStr(p_In_saName, 'MRS.','');
  p_In_saName := saSNRStr(p_In_saName, 'MS.','');
  // Trim last Scrub
  p_In_saName := Trim(saSNRStr(p_In_saName, 'MISS',''));
  
  z := Trim(saSNRStr(p_In_saName, ',',''));
  If Pos('&',Z) > 0 Then
  begin
    z := Trim(saLeftStr(z, pos('&',z) - 1)); //Mr. David G. Blackburn & Mrs. Virginia C. Blackbur
  End;
  TK.Tokenize(Z);
  //iTokens := TK.Tokens;
  If TK.MoveFirst Then
  begin
    TK.MoveLast;
    TK.Item_saToken:=saSNRStr(TK.Item_saToken,'.','');
    If (UpCase(TK.Item_saToken) = 'JR') Or 
       (UpCase(TK.Item_saToken) = 'SR') Or 
       (UpCase(TK.Item_saToken) = 'I') Or 
       (UpCase(TK.Item_saToken) = 'II') Or 
       (UpCase(TK.Item_saToken) = 'III') Or 
       (UpCase(TK.Item_saToken) = 'IV') Or 
       (UpCase(TK.Item_saToken) = 'M.D.') Or 
       (UpCase(TK.Item_saToken) = 'V') Then
    begin
      TK.DeleteItem;
    End;
       
    if TK.MoveFirst then
    begin
      If (UpCase(TK.Item_saToken) = 'MS.') Or 
         (UpCase(TK.Item_saToken) = 'MR.') Or 
         (UpCase(TK.Item_saToken) = 'MISS') Or 
         (UpCase(TK.Item_saToken) = 'MRS.') Or 
         (UpCase(TK.Item_saToken) = 'DR.') Or 
         (UpCase(TK.Item_saToken) = 'LT.') Then
      begin
        TK.DeleteItem;
      End;
    end;
    
    if TK.MoveFirst then p_Out_saFirst := TK.Item_saToken;
  
    // handle MARY LYNN 2 part first name
    if TK.MoveNext then
    begin
      if (Upcase(p_Out_saFirst)='MARY') and (UpCase(TK.Item_saToken) = 'LYNN') and (TK.ListCount>TK.N) then
      begin
        TK.DeleteItem;
        TK.MoveFirst;
        TK.Item_saName:='Mary Lynn';
      end;
    end;  
      
    
    If (TK.N + 2 <= TK.ListCount) Then
    begin
      sa0:=TK.Item_saToken;
      TK.MoveNExt;sa1:=TK.Item_saToken;
      TK.MoveNExt;sa2:=TK.Item_saToken;
      If (Length(sa1) > 2) And (pos('.',sa2) > 0) Then
      begin
        p_Out_saFirst := sa0 + ' ' + sa1;
      End;
    End;
    If TK.N=(TK.ListCount-1) Then
    begin
      TK.MoveNext;
      p_Out_saLast := TK.Item_saToken;
      TK.MovePrevious;
    End;
    //TK.DumpToTextFile('tk.parsename.txt');
    
    If TK.N=(TK.ListCount-2) Then
    begin
      // this logic is: 1 letter=middle initial, 2 letters-part of last name
      // 3 or more, full middle name - NOTE: Sample Data provided did not have
      // periods after middle initial
      
      //TK.DumpToTextFile('tk.parsename2.txt');
      
      sa0:=TK.Item_saToken;
      TK.MoveNext;sa1:=TK.Item_saToken;
      TK.MoveNext;sa2:=TK.Item_saToken;

      If ((Length(sa1) = 1) Or ((Length(sa1) = 2)) And (saRightStr(sa1, 1) = '.')) Or (Length(sa1) > 2) Then
      begin
        p_Out_saMiddle := saSNRStr(sa1, '.','');
        p_Out_saLast := sa2;
      end
      else
      begin
        If Length(sa1) = 2 Then // as in LA BONTE (removes Space)
        begin
          p_Out_saLast := sa1+sa2;
        end;
      End;
    End
    else
    begin
      if TK.ListCount=3 then
      begin
        Tk.movefirst;
        p_Out_saFirst :=TK.Item_saToken;
        TK.MoveNext;p_Out_saMiddle :=TK.Item_saToken;
        TK.MoveNext;p_Out_saLast :=TK.Item_saToken;
      end;
    end;
    
    
  End;
  p_Out_saFirst := saProper(p_Out_saFirst);
  p_Out_saMiddle := saProper(p_Out_saMiddle);
  p_Out_saLast := saProper(p_Out_saLast);
  TK.Destroy;
end;  
//=============================================================================

//=============================================================================
function saMid(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
//=============================================================================
var 
  i8Len: int64;
  bOk: boolean;
begin
  result:='';
  i8Len:=Length(p_saSrc);
  bOk:=(i8Len>0) and (p_i8Start<=i8Len);
  if bOk then
  begin
    result:=copy(p_saSrc, p_i8Start, p_i8Length);
  end;
end;
//=============================================================================

//=============================================================================
function saCut(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
//=============================================================================
var 
  i8Len: int64;
  bOk: boolean;
begin
  result:=p_saSrc;
  i8Len:=Length(p_saSrc);
  bOk:=(i8Len>0) and (p_i8Start<=i8Len);
  if bOk then
  begin
    delete(result, p_i8Start, p_i8Length);
  end;
end;
//=============================================================================

//=============================================================================
function saInsert(p_saSrc: ansistring; p_saInsertMe: ansistring; p_i8Start: int64): ansistring;
//=============================================================================
var
  i8Len: int64;
  bOk: boolean;
  saLeftSide: ansistring;
  saRightSide: ansistring;

begin
  result:=p_saSrc;
  i8Len:=Length(p_saSrc);
  bOk:=true;//(i8Len>0);// and (p_i8Start<=i8Len);
  if bOk then
  begin
    if length(p_saSrc)<(p_i8Start-1) then
    begin
      //riteln('repeating char: ' ,p_i8Start- length(p_sasrc));
      p_saSrc:=p_saSrc+saRepeatChar(' ',p_i8Start- length(p_sasrc));
    end;
    saLeftside:=copy(p_saSrc, 1, p_i8Start-1);
    //riteln('leftside:'+saLeftside+':');
    saRightSide:=copy(p_saSrc, p_i8Start,i8Len-p_i8Start+1);
    //riteln('rightside:'+saRightside+':');
    result:=saLeftSide+p_saInsertMe+saRightSide;
  end;
end;
//=============================================================================


//=============================================================================
function saBase64Encode(p_sa: ansistring): ansistring;
//=============================================================================
var
  DecodedStream: TStringStream;
  EncodedStream: TStringStream;
  Encoder: TBase64EncodingStream;
begin
  DecodedStream := TStringStream.Create(p_sa);    
  EncodedStream := TStringStream.Create('');
  Encoder       := TBase64EncodingStream.Create(EncodedStream);
  Encoder.CopyFrom(DecodedStream, DecodedStream.Size);
  result:=EncodedStream.DataString;
  DecodedStream.Free;
  EncodedStream.Free;
  Encoder.Free;
end;
//=============================================================================

//=============================================================================
function saBase64Decode(p_sa: ansistring): ansistring;
//=============================================================================
var
  EncodedStream: TStringStream;
  //DecodedStream: TStringStream;
  b_ErrorTrapped1: boolean;
  b_ErrorTrapped2: boolean;
  
   
begin
  b_ErrorTrapped1:=true;
  b_ErrorTrapped2:=true;
  EncodedStream := TStringStream.Create(p_sa);
  try
    with TBase64DecodingStream.Create(EncodedStream) do begin
      try
        setlength(result, size);
        readbuffer(result[1], size);
        b_ErrorTrapped1:=false;
      finally
       free;
      end;
    end;//with
    b_ErrorTrapped2:=false;
  finally
    EncodedStream.free;
  end;
  if(b_ErrorTrapped1 =true ) OR (b_ErrorTrapped2 = true ) then
  begin
    result:='***BASE64 CONVERSION ERROR***';
    if b_ErrorTrapped1 then
    begin
     JLog(cnLog_Warn,201012111222, result+' trap 1 in base64 conversion', SOURCEFILE);
    end;

    if b_ErrorTrapped2 then
    begin
      JLog(cnLog_Warn,201012111223, result+' trap 2in base64 conversion', SOURCEFILE);
    end;
  end;
end;
//=============================================================================




//=============================================================================
function saSingle(p_fValue: single; p_iDigits: longint; p_iDecimals: longint): ansistring;
//=============================================================================
var sa: ansistring;
begin
  str(p_fValue:p_iDigits:p_iDecimals, sa);
  result:=sa;
end;
//=============================================================================


//=============================================================================
function saDouble(p_fValue: double; p_iDigits: longint; p_iDecimals: longint): ansistring;
//=============================================================================
var sa: ansistring;
begin
  str(p_fValue:p_iDigits:p_iDecimals, sa);
  result:=sa;
end;
//=============================================================================


//=============================================================================
function saDoubleEscape(p_saEscapeThis: ansistring; p_chCharToEscape: char): ansistring;
//=============================================================================
var sa: ansistring;
begin
  sa:=saSNRStr(p_saEscapeThis, p_chCharToEscape, #0);
  result:=saSNRStr(sa, #0, p_chCharToEscape+p_chCharToEscape);
end;
//=============================================================================

//=============================================================================
function saEscape(
  p_saEscapeThis: ansistring;
  p_chCharToEscape: char;
  p_saReplaceWith: ansistring
): ansistring;
//=============================================================================
var sa: ansistring;
begin
  sa:=saSNRStr(p_saEscapeThis, p_chCharToEscape, #0);
  result:=saSNRStr(sa, #0, p_saReplaceWith);
end;
//=============================================================================




//=============================================================================
{}
function bGoodEmail(p_sa: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  iPos: longint;
  saRight: ansistring;
  i: longint;
  ch: char;
begin
  //riteln('BEGIN ------- bGoodEmail');
  bOk:=length(p_sa)>0;
  //if not bOk then riteln('Length failed');
  
  if bOk then 
  begin
    i:=1;
    repeat
      ch:= UpCASE(p_sa[i]);
      bOk:=((ch>='A') and (ch<='Z')) or
           ((ch>='a') and (ch<='z')) or
          (ch='.') or (ch='@') or (ch='_') or (ch='-') or 
          ((ch>='0') and (ch<='9'));
      //if not bOk then riteln('BAD CHAR:'+ch);
      i+=1;
    until (i=length(p_sa)) or (bOk=false);
  end;

  if bOk then
  begin
    iPos:=pos('@',p_sa);
    bOk:=iPos>1;
    //if not bOk then
    //begin
    //  riteln('No @ sign. POS:',iPos);
    //end;
  end;

  if bOk then
  begin
    saright:=saRightStr(p_sa, length(p_sa)-iPos);
    //riteln('DIAG: saRight:',saRight);
    bOk:=(Pos('@',saRight)=0) and (Pos(' ',saRight)=0);
    //if not bOk then
    //begin
    //  riteln('spaces or @ sign on right side of address');
    //end;
  end;

  if bOk then
  begin
    iPos:=Pos('.',saRight);
    bOk:=iPos>1;
    //if not bOk then
    //begin
    //  riteln('no period on right side');
    //end;
  end;

  //if bOk then
  //begin
  //  saRight:=saRightStr(saRight, length(saright)-iPos);
  //  bOk:=Pos('.',saRight)=0;
  //  //if not bOk then
  //  //begin
  //  //  riteln('Period after domain name''s period iPOS:',iPos,' saright:',saRight);
  //  //end;
  //end;
  //riteln('END ------- bGoodEmail');
  result:=bOk;
end;
//=============================================================================




//=============================================================================
{}
function bGoodPassword(p_sa: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  i: longint;
  ch: char;
begin
  bOk:=(length(p_sa)>=8) and (length(p_sa)<=32);
  if bOk then
  begin
    i:=1;
    repeat
      ch:= UpCASE(p_sa[i]);
      bOk:= ch in ['A'..'Z','a'..'z','0'..'9','~','`','!','@','#','$','%','^',
        '&','*','(',')','-','_','=','+','[',']',';','''',',','.','/','\','|',
        '}','{','"',':','>','<','?'];
      i+=1;
    until (i=length(p_sa)) or (bOk=false);
  end;
  result:=bOk;
end;
//=============================================================================

//=============================================================================
{}
function bGoodUsername(p_sa: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  i: longint;
  ch: char;
begin
  bOk:=(length(p_sa)>=1) and (length(p_sa)<=32);
  if bOk then
  begin
    i:=1;
    repeat
      ch:= UpCASE(p_sa[i]);
      bOk:= ch in ['A'..'Z','0'..'9'];
      i+=1;
    until (i=length(p_sa)) or (bOk=false);
  end;
  result:=bOk;
end;
//=============================================================================






















//=============================================================================
Procedure InitJASConfigRecord;
//=============================================================================
begin
  with grJASConfig do begin
    // Physical Dir -------------------------------------------------------------
    saSysDir:='../';
    saConfigDir:=saSysDir+'config'+csDOSSLASH;// Jegas Configuration Directory (DSN's, jas.cfg etc.)
    saFileDir:=saSysDir+'file'+csDOSSLASH;
    saWebShareDir:=saSysDIR+'webshare'+csDOSSLASH;
    saCacheDir:= saSysDir+'cache'+csDOSSLASH;
    saLogDir:=saSysDir+'log'+csDOSSLASH;// Jegas default log directory
    saThemeDir:=saWebShareDir+'themes'+csDOSSLASH;
    saWebRootDir:=saSysDir+'webroot'+csDOSSLASH;
    saBinDir:=saSysDir+'bin'+csDOSSLASH;
    saSetupDir:=saSysDir+'setup'+csDOSSLASH;
    saSoftwaredir:=saSysDir+'software'+csDOSSLASH;
    saSrcDir:=saSysDir+'src'+csDOSSLASH;
    saDataBaseDir:=saSysDir+'database'+csDOSSLASH;
    saPHPDir:= saSysDir+'php'+csDOSSLASH;
    // Physical Dir -------------------------------------------------------------
  
    // Filenames ----------------------------------------------------------------
    saDBCFilename:='jas.dbc';
    saConfigFile:='jas.cfg';
    {$IFDEF WIN32}
      saPHP:='"c:\program files\php\php-cgi.exe"';// Full Path to PHP php-cgi.exe for launching CGI based PHP
      saPerl:='c:\perl\bin\perl.exe'; // Full Path to Perl exe for launching CGI based Perl
    {$ELSE}
      saPHP:='/usr/bin/php-cgi';// Full Path to PHP php-cgi.exe for launching CGI based PHP
      saPerl:='/usr/bin/perl'; // Full Path to Perl exe for launching CGI based Perl
    {$ENDIF}
    saDiagnosticLogFileName:='';
    saJASFooter:='jassig';
    // Filenames ----------------------------------------------------------------
  
  
    // Web Paths ----------------------------------------------------------------
    saWebShareAlias:='/jws/';// Aliased Directory "webshare". Usually: jws
    saJASDirTheme:=saWebShareAlias+'themes/';
    // Web Paths ----------------------------------------------------------------
  
    // Threading --------------------------------------------------------------
    iThreadPoolNoOfThreads:=1;
    iThreadPoolMaximumRunTimeInMSec:= 5000;
    // Threading --------------------------------------------------------------
  
    // Misc Settings ----------------------------------------------------------
    saServerURL:='http://localhost/';
    saServerName:='Jegas Application Server';
    saServerIdent:='JEGAS';
    saServerSoftware:='Jegas Application Server / Jegas, LLC Version 1.0 -en';
    saDefaultArea:='sys_area';
    saDefaultPage:='index';
    saDefaultSection:='main';
    u1PasswordKey:=141;
    saDefaultLanguage:='en';//lowercase
    u1DefaultMenuRenderMethod:=3;
    saServerIP:='127.0.0.1';
    u2ServerPort:=8080;
    iRetryLimit:=10;
    iRetryDelayInMSec:=10;
    iTIMEZONEOFFSET:=-5;
    iMaxFileHandles:=iThreadPoolNoOfThreads*2+1;// 1 for diagnostic Log if enabled, pairs for file served, host log (worst case scenario)
    bBlackListEnabled:=true;
    bWhiteListEnabled:=false;
    bJobQEnabled:=false;
    iJobQIntervalInMSec:= 10000; // Ten Seconds
    u8DefaultTop_JMenu_ID:=1;//stock default is menu Id #1 :)
    bDirectoryListing:=true;
    bDataOnRight:=false;
    sCacheMaxAgeInSeconds:='3600';
    sSMTPHost:='';
    sSMTPUsername:='';
    sSMTPPassword:='';
    sSystemEmailFromAddress:='from@notspecified.com';
    bProtectJASRecords:=true;
    bSafeDelete:=true;
    bAllowVirtualHostCreation   :=false;
    // Misc Settings ----------------------------------------------------------
  
  
    // Error and Log Settings -------------------------------------------------
    iLogLevel:=1;
    bLogMessagesShowOnServerConsole:=false;
    bDeleteLogFile:=true;
    iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
    saErrorReportingSecureMessage:='Please note the error number shown in this '+
      'message and record it. Your system administrator can use that number to '+
      'help remedy system problems.';
    bServerConsoleMessagesEnabled:=true;
    bDebugServerConsoleMessagesEnabled:=false;
    iDebugMode:=cnSYS_INFO_MODE_SECURE;
    // Error and Log Settings -------------------------------------------------
  
    // Session and Record Locking ---------------------------------------------
    iSessionTimeOutInMinutes:=60;
    iLockTimeOutInMinutes:=30;
    iLockRetriesBeforeFailure:=50;
    iLockRetryDelayInMSec:=20;
    iValidateSessionRetryLimit:=50;
    // Session and Record Locking ---------------------------------------------
  
    // IP Protocol Related ----------------------------------------------------
    //i8MaximumRequestHeaderLength: Int64;
    i8MaximumRequestHeaderLength:=8192;
    iCreateSocketRetry:=100;
    iCreateSocketRetryDelayInMSec:=5;
    iSocketTimeOutInMSec:=12000;
    bEnableSSL:=false;
    // IP Protocol Related ----------------------------------------------------
  
    // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
    // Programmable Session Custom Hooks - Names for Actions that might
    // be coded into the u01g_sessions file. Useful for working with
    // integrated systems.
    saHOOK_ACTION_CREATESESSION_FAILURE:='';
    saHOOK_ACTION_CREATESESSION_SUCCESS:='';
    saHOOK_ACTION_REMOVESESSION_FAILURE:='';
    saHOOK_ACTION_REMOVESESSION_SUCCESS:='';
    saHOOK_ACTION_SESSIONTIMEOUT:='';
    saHOOK_ACTION_VALIDATESESSION_FAILURE:='';
    saHOOK_ACTION_VALIDATESESSION_SUCCESS:='';
    // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
  
    saDefaultColorTheme         :='default';
    bDefaultSharesDefaultDomain :=true;
    saDefaultIconTheme          :='Crystal Clear';
    saDefaultAccessLog          :='access.default.log';
    saDefaultErrorLog           :='error.default.log';
    bCreateHybridJets           :=false;
  end;// with
  // This line below assures that JAS can cycle properly by resetting the config file name
  // to it's initial state at original ug_jegas.pp startup.
  grJegasCommon.rJegasLog.saFileName:=grJASConfig.saSysDir+'log'+csDOSSLASH+grJegasCommon.rJegasLog.saFileName;
end;
//=============================================================================









////=============================================================================
//// NOTE: I think this is broken
//function saReverse(p_sa: ansistring): ansistring;
////=============================================================================
//var
//  i4Len: longint;
//  i: longint;
//  b: longint;
//begin
//  result:='';
//  i4Len:=length(p_sa);
//  if(i4Len>0)then
//  begin
//    setlength(result,i4Len);
//    b:=i4Len-1;
//    for i:=0 to i4Len-1 do
//    begin
//      result[b]:=p_sa[i];
//      b-=1;
//    end;
//  end;
//end;
////=============================================================================



//=============================================================================
// INTERNAL
// JegasLog Implementation
//=============================================================================
Procedure JegasLogInit;
//=============================================================================
Begin
  With grJegasCommon.rJegasLog Do Begin
    bLoggingDisabled:= False;
    u2LogType_ID:=0;
    bSendColumnHeadersAsFirstRow:=True;
    saFilename:=csLOG_FILENAME_DEFAULT;
    saQuoteBegin:= '"';
    saQuoteEnd:= '';
    saQuoteBeginEsc:='(#34)'; // Follows Regular Expressions Syntax (TODO: Um... yeah)
                          // Make this consistant - character escaping I guess.
    saQuoteEndEsc:='(#34)'; // Follows Regular Expressions Syntax (TODO: Um... yeah)
                          // Make this consistant - character escaping I guess.
    saDateQuoteBegin:='';
    saDateQuoteEnd:='';
    saDateFormat:=csDATETIMEFORMAT;
    iColumns:=cnJegasLogColumns;
    SetLength(arColumns, cnJegasLogColumns);
    
    // Date and Time the Log Entry was created
    With arColumns[00] Do Begin
      saName:='JLOGT_DateNTime_dt';
      u2JDType:=cnJDType_dt;
      vValue:=TDATETIME(#0);
    End;
    
    With arColumns[01] Do Begin
      saName:='JLOGT_Severity_u1';
      u2JDType:=cnJDType_u1;
      vValue:=Word(0);
    End;
    
    // # used to make the actual call unique for text 
    //searching your source files - note - using
    // (approx) line number where the call is made
    // would suit the purpose during development.
    //
    // Ideally - this would link back to a database
    // table - describing exactly what may have caused
    // the error. Each POSSIBLE write to a log would
    // have its own ID in said database table.
    // useful for debugging, support, writing help
    // etc.
    With arColumns[02] Do Begin
      saName:='JLOGT_Entry_ID';
      u2JDType:=cnJDType_u8;
      vValue:=Int64(0);
    End;

    With arColumns[03] Do Begin
      saName:='JLOGT_EntryData_s';
      u2JDType:=cnJDType_s;
      vValue:=AnsiString('');
    End;
  
    // Actual Program Source File that has made the 
    // call. Note: When releasing systems, you may not
    // want this field populated, however I have found
    // it invaluable with debugging.   
    With arColumns[04] Do Begin
      saName:='JLOGT_SourceFile_s';
      u2JDType:=cnJDType_s;
      vValue:=AnsiString('');
    End;

    // This is to contain the user id as JEGAS sees
    // it, as it relates to the Jegas System.
    // See rtJegasCommon - as it has this field, 
    // as well as the system user name (os dependant),
    // and where applicable, the network login name
    // which can be different as well (os and os config
    // dependant)
    With arColumns[05] Do Begin
      saName:='JLOGT_User_ID';
      u2JDType:=cnJDType_u4;
      vValue:=Cardinal(0);
    End;
    
    // Populated with the username provided when the operating system 
    // was interrogated.
    With arColumns[06] Do Begin
      saName:='JLOGT_OS_Login_s';
      u2JDType:=cnJDType_s;
      vValue:=AnsiString('(?)');// TODO: Add Support for this
    End;

    // is populated with the commandline used to invoke the app.
    With arColumns[07] Do Begin
      saName:='JLOGT_CmdLine_s';
      u2JDType:=cnJDType_s;
      vValue:=AnsiString('(?)');
    End;
    
    iLogEntries_Total:=0;
    iLogEntries_NONE:=0;
    iLogEntries_DEBUG:=0;
    iLogEntries_FATAL:=0;
    iLogEntries_ERROR:=0;
    iLogEntries_WARN:=1;
    iLogEntries_INFO:=1;
    iLogEntries_RESERVED:=0;
    iLogEntries_USERDEFINED:=0;
    dtLogEntryFirst:=TDATETIME(#0); 
    dtLogEntryLast:=TDATETIME(#0); 
  End;
End;
//=============================================================================




//=============================================================================
// This should stay private to prevent the stupidity of calling the same code 
// more than once - its called - its done - the key is to make it easy to 
// find in the reference manuals so that people know its there if they need it.
// I always find I need to recreate the command line - for logs or something
// enough that this made enough sense to do. Does impact start up a teensie
// bit I guess. 
// TODO: I might depreciate it to something user needs to request and 
// make it so it only truly executes once - even if called subsequently
// in same invocation via a binary flag or something.
Function saJegas_CmdLine_Private: AnsiString;
//=============================================================================
Var i: longint;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saJegas_CmdLine_Private', SOURCEFILE)
  {$ENDIF}

  Result:=Paramstr(0);
  If paramcount>0 Then Begin
    For i:=1 To paramcount Do Result:=Result+' '+paramstr(i);
  End;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saJegas_CmdLine_Private',SOURCECODE)
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function saCmdLine: AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('saCmdLine', SOURCEFILE)
  {$ENDIF}

  Result:=grJegasCommon.saCmdLine;
  
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('saCmdLine',SOURCECODE)
  {$ENDIF}
End;
//=============================================================================





//=============================================================================
// Specifically Sending messages to the console and controlled
// by the configuration file's ServerConsoleMessagesEnabled=Yes option , and 
// is internally controlled by the resulting: 
// grJASConfig.bServerConsoleMessagesEnabled value at runtime.
//=============================================================================
Procedure JASPrint(p_sa:ansistring);inline;
//=============================================================================
begin
  if grJASConfig.bServerConsoleMessagesEnabled then write(p_sa);
end;
//=============================================================================

//=============================================================================
// Specifically Sending messages to the console and controlled
// by the configuration file's ServerConsoleMessagesEnabled=Yes option , and 
// is internally controlled by the resulting: 
// grJASConfig.bServerConsoleMessagesEnabled value at runtime.
//=============================================================================
Procedure JASPrintln(p_sa:ansistring);inline;
//=============================================================================
begin
  if grJASConfig.bServerConsoleMessagesEnabled then write(p_sa+csCRLF);
end;
//=============================================================================

//=============================================================================
// For Debugging, however these two are toggled via the 
// DebugServerConsoleMessagesEnabled=Yes option in the config file, and 
// are internally controlled by the resulting: 
// grJASConfig.bDebugServerConsoleMessagesEnabled value.
//=============================================================================
Procedure JASDebugPrint(p_sa:ansistring);inline;
//=============================================================================
begin
  if(grJASConfig.bDebugServerConsoleMessagesEnabled) then JASPrint(p_sa);
end;
//=============================================================================

//=============================================================================
// For Debugging, however these two are toggled via the 
// DebugServerConsoleMessagesEnabled=Yes option in the config file, and 
// are internally controlled by the resulting: 
// grJASConfig.bDebugServerConsoleMessagesEnabled value.
//=============================================================================
Procedure JASDebugPrintln(p_sa:ansistring);inline;
//=============================================================================
begin
  if(grJASConfig.bDebugServerConsoleMessagesEnabled)then
    JASPrintln(p_sa);
end;
//=============================================================================



//=============================================================================
Procedure InitJegasUnit;
//=============================================================================
Var saDir: String; saName: String; saExt: String;
Begin
  // Force Formatting Defaults to be the Same on both Linux And windows.
  // These are the Defaults that were in place for windows in 2.4.2
  // of Freepascal - Presumably much earlier versions. Since there is a
  // alot of code based on these defaults, and recently (2012-02-07)
  // I've run into a problem where StrToDateTime function dies on Linux but
  // Not Linux, Due to different formatting defaults - I've added this code
  // to force me hand - and make the windows Linux Differences that much
  // Less. FreePascal does a good job of this - here is a slight "Gotcha"
  // but this should fix it.
  with DefaultFormatSettings do begin
    CurrencyFormat:= 0;
    NegCurrFormat:= 0;
    ThousandSeparator:= ',';
    DecimalSeparator:= '.';
    CurrencyDecimals:= 2;
    DateSeparator:= '/';
    TimeSeparator:= ':';
    ListSeparator:= ',';
    CurrencyString:= '$';
    ShortDateFormat:= 'M/d/yyyy';
    LongDateFormat:= 'dddd, MMMM dd, yyyy';
    TimeAMString:='AM';
    TimePMString:='PM';
    ShortTimeFormat:= 'h:nn';
    LongTimeFormat:= 'h:nn:ss';
    ShortMonthNames[1]:='Jan';
    ShortMonthNames[2]:='Feb';
    ShortMonthNames[3]:='Mar';
    ShortMonthNames[4]:='Apr';
    ShortMonthNames[5]:='May';
    ShortMonthNames[6]:='Jun';
    ShortMonthNames[7]:='Jul';
    ShortMonthNames[8]:='Aug';
    ShortMonthNames[9]:='Sep';
    ShortMonthNames[10]:='Oct';
    ShortMonthNames[11]:='Nov';
    ShortMonthNames[12]:='Dec';
    LongMonthNames[1]:='January';
    LongMonthNames[2]:='February';
    LongMonthNames[3]:='March';
    LongMonthNames[4]:='April';
    LongMonthNames[5]:='May';
    LongMonthNames[6]:='June';
    LongMonthNames[7]:='July';
    LongMonthNames[8]:='August';
    LongMonthNames[9]:='September';
    LongMonthNames[10]:='October';
    LongMonthNames[11]:='November';
    LongMonthNames[12]:='December';
    ShortDayNames[1]:= 'Sun';
    ShortDayNames[2]:= 'Mon';
    ShortDayNames[3]:= 'Tue';
    ShortDayNames[4]:= 'Wed';
    ShortDayNames[5]:= 'Thu';
    ShortDayNames[6]:= 'Fri';
    ShortDayNames[7]:= 'Sat';
    LongDayNames[1]:='Sunday';
    LongDayNames[2]:='Monday';
    LongDayNames[3]:='Tuesday';
    LongDayNames[4]:='Wednesday';
    LongDayNames[5]:='Thursday';
    LongDayNames[6]:='Friday';
    LongDayNames[7]:='Saturday';
    TwoDigitYearCenturyWindow:=50;
  end;//with

  // FOR DEBUGGING -  ug_Jegas.pp has the DebugNestLevel I and DebugNestLevelOut
  //                  routines that use this and bring it to the LOG.
  with grJegasCommon do begin
    dtStart:=now;
    saCmdLine:=saJegas_CmdLine_Private;
    saOSUserLogin:='OSUserLogin'; //< OS Dependant - username (application ran as ...)
    saOSUserFullName:='OSUserFullName';//< OS Dependant - username (application ran as ...)
    saOSNetworkLogin:='OSNetworkLogin'; //< OS Dependant Network Login Name
    saOSNetworkUserFullName:='OSNetworkUserFullname';//< OS Dependant Network User Full Name
    //rJegasLog: rtIOAppendLog; //< Information about the configuration etc
    FSplit(argv[0],saDir,saName,saExt);
    saAppPath:=saDir;
    saAppExeName:=argv[0];
    saAppTitle:='AppTitle';//<application title
    saAppProductName:='AppProductName';
    saAppMajor:='0';
    saAppMinor:='0';
    saAppRevision:='0';
  end;//with
  
  InitTSFileIO(500,50,100);
  JegasLogInit;
  giDebugNestLevel:=0;
  {$IFDEF DEBUGBEGINEND}
    DebugIN('InitJegasUnit', SOURCEFILE)
  {$ENDIF}

  InitJASConfigRecord;
  asaDateFormat[00]:=csDateFormat_00;
  asaDateFormat[01]:=csDateFormat_01;
  asaDateFormat[02]:=csDateFormat_02;
  asaDateFormat[03]:=csDateFormat_03;
  asaDateFormat[04]:=csDateFormat_04;
  asaDateFormat[05]:=csDateFormat_05;
  asaDateFormat[06]:=csDateFormat_06;
  asaDateFormat[07]:=csDateFormat_07;
  asaDateFormat[08]:=csDateFormat_08;
  asaDateFormat[09]:=csDateFormat_09;
  asaDateFormat[10]:=csDateFormat_10;
  asaDateFormat[11]:=csDateFormat_11;
  asaDateFormat[12]:=csDateFormat_12;
  asaDateFormat[13]:=csDateFormat_13;
  asaDateFormat[14]:=csDateFormat_14;
  asaDateFormat[15]:=csDateFormat_15;
  asaDateFormat[16]:=csDateFormat_16;
  asaDateFormat[17]:=csDateFormat_17;
  asaDateFormat[18]:=csDateFormat_18;
  asaDateFormat[19]:=csDateFormat_19;
  asaDateFormat[20]:=csDateFormat_20;
  asaDateFormat[21]:=csDateFormat_21;
  asaDateFormat[22]:=csDateFormat_22;

  asaMonth[01]:=csDateMonth_01;// january etc
  asaMonth[02]:=csDateMonth_02;
  asaMonth[03]:=csDateMonth_03;
  asaMonth[04]:=csDateMonth_04;
  asaMonth[05]:=csDateMonth_05;
  asaMonth[06]:=csDateMonth_06;
  asaMonth[07]:=csDateMonth_07;
  asaMonth[08]:=csDateMonth_08;
  asaMonth[09]:=csDateMonth_09;
  asaMonth[10]:=csDateMonth_10;
  asaMonth[11]:=csDateMonth_11;
  asaMonth[12]:=csDateMonth_12;
  
  asaDay[1]:=csDateDay_1;
  asaDay[2]:=csDateDay_2;
  asaDay[3]:=csDateDay_3;
  asaDay[4]:=csDateDay_4;
  asaDay[5]:=csDateDay_5;
  asaDay[6]:=csDateDay_6;
  asaDay[7]:=csDateDay_7;

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('InitJegasUnit',SOURCECODE)
  {$ENDIF}
End;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Jegas Field Functions (rtJegasField type=record)
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
{}
Function bIsJDTypeString(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_s              : b:=true;
  cnJDType_su             : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
Function bIsJDTypeMemo(p_u2JDType:word): boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_sn             : b:=true;
  cnJDType_sun            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================


//=============================================================================
{}
Function bIsJDTypeBinary(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_bin            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================


//=============================================================================
{}
Function bIsJDTypeBoolean(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_b              : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================


//=============================================================================
{}
Function bIsJDTypeDate(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_dt             : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
Function bIsJDTypeChar(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_ch             : b:=true;
  cnJDType_chu            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================



//=============================================================================
{}
Function bIsJDTypeUInt(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_u1             : b:=true;
  cnJDType_u2             : b:=true;
  cnJDType_u4             : b:=true;
  cnJDType_u8             : b:=true;
  cnJDType_u16            : b:=true;
  cnJDType_u32            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
Function bIsJDTypeInt(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_i1             : b:=true;
  cnJDType_i2             : b:=true;
  cnJDType_i4             : b:=true;
  cnJDType_i8             : b:=true;
  cnJDType_i16            : b:=true;
  cnJDType_i32            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
Function bIsJDTypeDec(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_fp             : b:=true;
  cnJDType_fd             : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
Function bIsJDTypeCurrency(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_cur            : b:=true;
  end;//case
  result:=b;
end;
//=============================================================================


//=============================================================================
{}
// Returns true for passed Jegas Types that are numeric. Int, Uint, Decimals,
// currency BUT NOT BOOLEAN.
// See ug_common for definitions of jegas types
Function bIsJDTypeNumber(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_i1             : b:=true;
  cnJDType_i2             : b:=true;
  cnJDType_i4             : b:=true;
  cnJDType_i8             : b:=true;
  cnJDType_i16            : b:=true;
  cnJDType_i32            : b:=true;
  cnJDType_u1             : b:=true;
  cnJDType_u2             : b:=true;
  cnJDType_u4             : b:=true;
  cnJDType_u8             : b:=true;
  cnJDType_u16            : b:=true;
  cnJDType_u32            : b:=true;
  cnJDType_fp             : b:=true;
  cnJDType_fd             : b:=true;
  cnJDType_cur            : b:=true;
  end;//switch
  result:=b;
end;
//=============================================================================

//=============================================================================
{}
// Returns true for any passed Jegas Type that is TEXT: this includes char,
// strings and memos.
// See ug_common for definitions of jegas types
Function bIsJDTypeText(p_u2JDType:word):Boolean;
//=============================================================================
var b: boolean;
begin
  b:=false;
  Case p_u2JDType Of
  cnJDType_ch             : b:=true;
  cnJDType_chu            : b:=true;
  cnJDType_s              : b:=true;
  cnJDType_su             : b:=true;
  cnJDType_sn             : b:=true;
  cnJDType_sun            : b:=true;
  end;//switch
  result:=b;
end;
//=============================================================================





//=============================================================================
{}
// diagnostic Aid: Send it the Jegas Data Type - it will return its NAME as text
Function saJDType(p_u2JDType:word): AnsiString;
//=============================================================================
Begin
  Case p_u2JDType Of
  cnJDType_Unknown        :Result:='JDType_Unknown';
  cnJDType_i1             :Result:='JDType_i1';
  cnJDType_i2             :Result:='JDType_i2';
  cnJDType_i4             :Result:='JDType_i4';
  cnJDType_i8             :Result:='JDType_i8';
  cnJDType_i16            :Result:='JDType_i16';
  cnJDType_i32            :Result:='JDType_i32';
  cnJDType_u1             :Result:='JDType_u1';
  cnJDType_u2             :Result:='JDType_u2';
  cnJDType_u4             :Result:='JDType_u4';
  cnJDType_u8             :Result:='JDType_u8';
  cnJDType_u16            :Result:='JDType_u16';
  cnJDType_u32            :Result:='JDType_u32';
  cnJDType_fp             :Result:='JDType_fp';
  cnJDType_fd             :Result:='JDType_fd';
  cnJDType_cur            :Result:='JDType_cur';
  cnJDType_ch             :Result:='JDType_ch';
  cnJDType_chu            :Result:='JDType_chu';
  cnJDType_b              :Result:='JDType_b';
  cnJDType_dt             :Result:='JDType_dt';
  cnJDType_s              :Result:='JDType_s';
  cnJDType_su             :Result:='JDType_su';
  cnJDType_sn             :Result:='JDType_sn';
  cnJDType_sun            :Result:='JDType_sun';
  Else Result:='Unknown Jegas Data Type: '+saStr(p_u2JDType);
  End;
End;
//=============================================================================




















//=============================================================================
{}
// p_SrcXDL and p_DestXDL
//
// XDL: Item_i8User = Weight 0-4,000,000,000   (REcommend lower values (B^)>
//                    ONLY HONORED IN SrcXDL. This Value is ignored in DestXDL.
//                    Range: 4 Byte Integer - Don't Exeed.
// XDL: Item_saName = Field Name (not Caption ideally but would work if both
//                    had the same naming. Which Means if DeDuping different
//                    tables, the DestXDL Item_saName's should be that of the
//                    SrcXDL.
// XDL: Item_saValue= Value to be compared
// XDL: Item_saDesc = Undefined.
//
// NOTE: For Merge - the DestXDL will be Populated. So The Values after this
// routine performs a merge, that you'll want, will be in DestXDL.
//
// If you have a small number of fields you wish to merge with a larger Table,
// only include the fields that exist in both tables.
//
// The dupe Score is the Score to beat to be considered a DUPE. this is not
// an exact science - so this is how we learn to tweak settings to get
// acceptable results. Each kind of dupe checking will have unique WEIGHTS
// and a DupeScore.
//
// Both XDL MUST have identical COUNT of Items, ZERO Items in unacceptable.
// otherwise the routine will fail.
//
// p_ColXDL
//
// The Collision XDL Returns Colisions Preventing a Fulll Merge.
// You Will Get a List of Column Names in p_ColXDL.Item_saName
// For diagnostic reasons, you will get Src Value in Item_saValue
// and Dest value in Item_saDesc. This might be useful to make user interface
// to selectively resolve colisions.
//
// Naturally sending uninitialized XDLs will cause a CRASH.
//
procedure Merge(
  p_bPerformMerge: boolean;
  p_uDupeScore: cardinal;
  p_bCaseSensitive: boolean;
  var p_bDupe: boolean;
  p_SrcXDL: JFC_XDL;
  p_DestXDL: JFC_XDL;
  p_ColXDL: JFC_XDL
);
//=============================================================================
var
  iScore: longint;
  saUpSrc: ansistring;
  saUpDest: ansistring;
  sa: ansistring;
Begin
 
  iScore:=0;
  p_bDupe:=false;
  p_ColXDL.DeleteAll;

  if p_SrcXDL.MoveFirst then
  begin
    sa:='';
    repeat
      if p_DestXDL.FoundItem_saName(p_SrcXDL.Item_saName) then
      begin
        saUpSrc:=trim(p_SrcXDL.Item_saValue);
        saUpDest:=trim(p_DestXDL.Item_saValue);
        if not p_bCaseSensitive then
        begin
          saUpSrc:=UpCase(saUpSrc);
          saUpDest:=UpCase(saUpDest);
        end;
        sa+='Src Name: '+p_SrcXDL.Item_saName+' Value: '+saUpSrc+' Dest Name: '+p_DestXDL.Item_saName+' Dest: '+saUpDest+csCRLF;
        if (saUpSrc=saUpDest) and
           (NOT ((saUpSrc='NULL') OR (saUpDest='NULL'))) and
           (NOT ((saUpSrc='') OR (saUpDest=''))) then
        begin
          sa+='Score b4: '+inttostR(iScore);
          iScore+=p_SrcXDL.Item_i8User;
          sa+=' Score Field: '+p_SrcXDL.Item_saName+' Data: '+p_SrcXDL.Item_saValue+' #Value: '+inttostR(p_SrcXDL.Item_i8User)+' New Score: '+inttostR(iScore)+csCRLF;
        end;
        //riteln(p_SrcXDL.Item_saName,' Score: ', iScore,' saUpSrc: [',saUpSrc,'] saUpDest: ['+saUpDest+']');
      end;
    until (not p_SrcXDL.MoveNext);
  end;

  p_bDupe:=iScore>=p_uDupeScore;

  if p_bDupe then
  begin
    writeln(sa);
    writeln;
  end;
  
  if p_bPerformMerge and p_bDupe then
  begin
    if p_SrcXDL.MoveFirst then
    begin
      repeat
        if p_DestXDL.FoundItem_saName(p_SrcXDL.Item_saName) then
        begin
          saUpSrc:=trim(p_SrcXDL.Item_saValue);
          saUpDest:=(p_DestXDL.Item_saValue);
          if not p_bCaseSensitive then
          begin
            saUpSrc:=UpCase(saUpSrc);
            saUpDest:=UpCase(saUpDest);
          end;
          //riteln('MERGING:  saUpSrc: [',saUpSrc,'] saUpDest: ['+saUpDest+']');
          if (saUpSrc<>'NULL') and (saUpSrc<>'') Then
          begin
            if (saUpDest='') or (saUpDest='NULL') then
            begin
              p_DestXDL.Item_saValue:=p_SrcXDL.Item_saValue;
            end else

            if (saUpSrc=saUpDest) then
            begin
              // Nothing To Do
            end else

            begin
              p_ColXDL.AppendItem_saName_N_saValue(
                p_SrcXDL.Item_saName, p_SrcXDL.Item_saValue);
              p_ColXDL.Item_saDesc:=p_DestXDL.Item_saValue;
            end;
          end;
        end;
      until not p_SrcXDL.MoveNext;
    end;
  end;
end;
//=============================================================================


























//=============================================================================
{}
// This function's job is to make sure the DEST
// Structure is large enough or can be converted such that
// data FROM SRC will fit.
//
// If No Change is required, then the function returns TRUE
// and p_bModified is set to false on exit.
//
// If it can, be converted, then DEST field Definition is modified
// to accodate SRC and p_Modified is set to True.
// 
// If it can not be accomodated, then the function returns false
// indicating it can't be done. Perhaps you should make another field.
Function bJegasFieldSync( 
  var p_rJegasFieldSrc: rtJegasField;
  var p_rJegasFieldDest: rtJegasField;
  var p_bModified:Boolean
): boolean;
//=============================================================================
var
  bOk:Boolean;
  rJegasFieldDestCopy: rtJegasField;
begin
  bOk := True;
  p_bModified := False;
  With rJegasFieldDestCopy do begin 
    bTrueFalse     := p_rJegasFieldDest.bTrueFalse;
    u8DefinedSize := p_rJegasFieldDest.u8DefinedSize;
    u2JDType    := p_rJegasFieldDest.u2JDType;
    i4NumericScale := p_rJegasFieldDest.i4NumericScale;
    i4Precision    := p_rJegasFieldDest.i4Precision;
    saName     := p_rJegasFieldDest.saName;
    //.vValue := p_rJegasFieldDest.vValue
  End;//with
  
  //--------------------------------------------------------------------
  //If (JADO.bIsJDTypeNumber(p_rJegasFieldSrc.u2JDType)) And _
  //   (JADO.bIsJDTypeNumber(p_rJegasFieldDest.u2JDType)) Then
  //  // Both Fields are Number, Fine. Need to Make Sure
  //  // That the SRC # type can Squeeze into the DEST Datatype
  //  // without data loss.
  //
  //End If
  //
  // If (Not JADO.bIsJDTypeNumber(p_rJegasFieldSrc.u2JDType)) And _
  //    (JADO.bIsJDTypeNumber(p_rJegasFieldDest.u2JDType)) Then
  //   // Ok, SRC is NOT a Number but the Destination is a Number.
  //   // In this Case, convert the DEST into an accommodating
  //   // String for both.
  //   // That the SRC # type can Squeeze into the DEST Datatype
  //   // without data loss.
  // End If
  //
  // If (JADO.bIsJDTypeNumber(p_rJegasFieldSrc.u2JDType)) And _
  //    (Not JADO.bIsJegasFieldNumber(p_rJegasFieldDest.u2JDType)) Then
  //   // Is this case, the Source Field is a Number but
  //   // The Dest field is not. In this case, we need to make
  //   // sure the dest text field is big enough to hold all the
  //   // digits (and SIGN, and decimal) of the SRC number field
  // End If
  //
  //With p_rJegasFieldSrc
  //  Debug.Print "-----------------BEGIN JEGAS FIELD SRC"
  //  Debug.Print "TRUEFALSE: " & .bTrueFalse
  //  Debug.Print "Defined Size: " & .u8DefinedSize
  //  Debug.Print "JegasType: " & .u2JDType
  //  Debug.Print "Numeric Scale:" & .i4NumericScale
  //  Debug.Print "Precision:" & .i4Precision
  //  Debug.Print "Field Name:" & .sFieldName
  //  Debug.Print "Value: " & .vValue
  //  Debug.Print "-----------------BEGIN JEGAS FIELD SRC"
  //  Debug.Print
  //End With
  //With p_rJegasFieldDest
  //  Debug.Print "-----------------BEGIN JEGAS FIELD DEST"
  //  Debug.Print "TRUEFALSE: " & .bTrueFalse
  //  Debug.Print "Defined Size: " & .u8DefinedSize
  //  Debug.Print "JegasType: " & .u2JDType
  //  Debug.Print "Numeric Scale:" & .i4NumericScale
  //  Debug.Print "Precision:" & .i4Precision
  //  Debug.Print "Field Name:" & .sFieldName
  //  Debug.Print "Value: " & .vValue
  //  Debug.Print "-----------------BEGIN JEGAS FIELD DEST"
  //  Debug.Print
  //End With
  
  Case p_rJegasFieldSrc.u2JDType of
  cnJDType_Unknown: begin
    With p_rJegasFieldDest do begin
      Case u2JDType  of
      cnJDType_Unknown:  bOk := False;
      cnJDType_i1:       bOk := False;
      cnJDType_i2:       bOk := False;
      cnJDType_i4:       bOk := False;
      cnJDType_i8:       bOk := False;
      cnJDType_i16:      bOk := False;
      cnJDType_i32:      bOk := False;
      cnJDType_u1:       bOk := False;
      cnJDType_u2:       bOk := False;
      cnJDType_u4:       bOk := False;
      cnJDType_u8:       bOk := False;
      cnJDType_u16:      bOk := False;
      cnJDType_u32:      bOk := False;
      cnJDType_fp:       bOk := False;
      cnJDType_fd:       bOk := False;
      cnJDType_cur:      bOk := False;
      cnJDType_ch:       bOk := False;
      cnJDType_chu:      bOk := False;
      cnJDType_b:        bOk := False;
      cnJDType_dt:       bOk := False;
      cnJDType_s:        bOk := False;
      cnJDType_su:       bOk := False;
      cnJDType_sn:       bOk := False;
      cnJDType_sun:      bOk := False;
      cnJDType_bin:      bOk := False;
      End;//switch
    End;// With
  end;//case
  
  cnJDType_i1: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType  of
      cnJDType_Unknown:   bOk:= False;
      cnJDType_i1:;        // No Change
      cnJDType_i2:;        // No Change
      cnJDType_i4:;        // No Change
      cnJDType_i8:;        // No Change
      cnJDType_i16:;       // No Change
      cnJDType_i32:;       // No Change
      cnJDType_u1: begin  u2JDType := cnJDType_i2; p_bModified := True; end;
      cnJDType_u2:        u2JDType := cnJDType_i4;
      cnJDType_u4:        u2JDType := cnJDType_i8;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // No change
      cnJDType_cur:;       // No change
      cnJDType_ch: begin  u2JDType := cnJDType_s;  u8DefinedSize := cnMaxDigitsFor01ByteUInt; end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt; end;
      cnJDType_b:         u2JDType := cnJDType_i2;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText; end;
      cnJDType_s:;         // No change
      cnJDType_su:;        // no change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor01ByteUInt Then u8DefinedSize := cnMaxDigitsFor01ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor01ByteUInt Then u8DefinedSize := cnMaxDigitsFor01ByteUInt;
      cnJDType_bin:; // No Change
      End;//switch
    End;// With
  end;//case 
  
  cnJDType_i2: begin
    With p_rJegasFieldDest do begin
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:        u2JDType := cnJDType_i2;
      cnJDType_i2:;        // No change
      cnJDType_i4:;        // No change
      cnJDType_i8:;        // No change
      cnJDType_i16:;       // No change
      cnJDType_i32:;       // No change
      cnJDType_u1:        u2JDType := cnJDType_i2;
      cnJDType_u2:        u2JDType := cnJDType_i4;
      cnJDType_u4:        u2JDType := cnJDType_i8;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp:;        // No Change
      cnJDType_fd:;        // No Change
      cnJDType_cur:;       // no change
      cnJDType_ch: begin  u2JDType := cnJDType_s;  u8DefinedSize := cnMaxDigitsFor01ByteUInt; end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt; end;
      cnJDType_b:         u2JDType := cnJDType_i2;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // no change
      cnJDType_su:;        // no change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor02ByteUInt Then u8DefinedSize := cnMaxDigitsFor02ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor02ByteUInt Then u8DefinedSize := cnMaxDigitsFor02ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 2) And (u8DefinedSize <> 0) Then u8DefinedSize := 2;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_i4: begin
    With p_rJegasFieldDest do begin
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:        u2JDType := cnJDType_i4;
      cnJDType_i2:        u2JDType := cnJDType_i4;
      cnJDType_i4:;        // No change
      cnJDType_i8:;        // no change
      cnJDType_i16:;       // no Change
      cnJDType_i32:;       // No Change
      cnJDType_u1:        u2JDType := cnJDType_i4;
      cnJDType_u2:        u2JDType := cnJDType_i4;
      cnJDType_u4:        u2JDType := cnJDType_i8;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // No Change
      cnJDType_cur:;       // No change
      cnJDType_ch: begin  u2JDType := cnJDType_s;  u8DefinedSize := cnMaxDigitsFor04ByteUInt;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i4;
      cnJDType_dt: begin  u2JDType := cnJDType_s;  u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // no change
      cnJDType_su:;        // no change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor04ByteUInt Then u8DefinedSize := cnMaxDigitsFor04ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor04ByteUInt Then u8DefinedSize := cnMaxDigitsFor04ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 4) And (u8DefinedSize <> 0) Then u8DefinedSize := 4;
      End;//switch
    End;// With
  end;//case  
  
  cnJDType_i8: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:        u2JDType := cnJDType_i8;
      cnJDType_i2:        u2JDType := cnJDType_i8;
      cnJDType_i4:        u2JDType := cnJDType_i8;
      cnJDType_i8:;        // no change
      cnJDType_i16:;       // no change
      cnJDType_i32:;       // no change
      cnJDType_u1:        u2JDType := cnJDType_i8;
      cnJDType_u2:        u2JDType := cnJDType_i8;
      cnJDType_u4:        u2JDType := cnJDType_i8;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32: begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // No change
      cnJDType_cur:;       // No change
      cnJDType_ch:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i8;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_s:;         // No change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor08ByteUInt Then u8DefinedSize := cnMaxDigitsFor08ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor08ByteUInt Then u8DefinedSize := cnMaxDigitsFor08ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 8) And (u8DefinedSize <> 0) Then u8DefinedSize := 8;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_i16: begin
    With p_rJegasFieldDest do begin
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_i16;
      cnJDType_i2:        u2JDType := cnJDType_i16;
      cnJDType_i4:        u2JDType := cnJDType_i16;
      cnJDType_i8:        u2JDType := cnJDType_i16;
      cnJDType_i16:       u2JDType := cnJDType_i16;
      cnJDType_i32:;       // no change
      cnJDType_u1:        u2JDType := cnJDType_i16;
      cnJDType_u2:        u2JDType := cnJDType_i16;
      cnJDType_u4:        u2JDType := cnJDType_i16;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32: begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // No change
      cnJDType_cur:;       // No Change
      cnJDType_ch:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i16;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_s:;         // no change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor16ByteUInt Then u8DefinedSize := cnMaxDigitsFor16ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor16ByteUInt Then u8DefinedSize := cnMaxDigitsFor16ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 16) And (u8DefinedSize <> 0) Then u8DefinedSize := 16;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_i32: begin
    With p_rJegasFieldDest do begin
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_i32;
      cnJDType_i2:        u2JDType := cnJDType_i32;
      cnJDType_i4:        u2JDType := cnJDType_i32;
      cnJDType_i8:        u2JDType := cnJDType_i32;
      cnJDType_i16:       u2JDType := cnJDType_i32;
      cnJDType_i32:       u2JDType := cnJDType_i32;
      cnJDType_u1:        u2JDType := cnJDType_i32;
      cnJDType_u2:        u2JDType := cnJDType_i32;
      cnJDType_u4:        u2JDType := cnJDType_i32;
      cnJDType_u8:        u2JDType := cnJDType_i32;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32: begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // No change
      cnJDType_cur:;       // No change
      cnJDType_ch:  begin u2JDType := cnJDType_s;  u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_b:         u2JDType := cnJDType_i32;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_s:;         // No change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor32ByteUInt Then u8DefinedSize := cnMaxDigitsFor32ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor32ByteUInt Then u8DefinedSize := cnMaxDigitsFor32ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 32) And (u8DefinedSize <> 0) Then u8DefinedSize := 32;
      End;//switch
    End;//With
  end;//case
    
  
  cnJDType_u1: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:        u2JDType := cnJDType_i2;
      cnJDType_i2:;        // No change
      cnJDType_i4:;        // No change
      cnJDType_i8:;        // No change
      cnJDType_i16:;       // no change
      cnJDType_i32:;       // No change
      cnJDType_u1:;        // No change
      cnJDType_u2:;        // No change
      cnJDType_u4:;        // No change
      cnJDType_u8:;        // No change
      cnJDType_u16:;       // no change
      cnJDType_u32:;       // No change
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // no change
      cnJDType_cur:;       // No change
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i2;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // No change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor01ByteUInt Then u8DefinedSize := cnMaxDigitsFor01ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor01ByteUInt Then u8DefinedSize := cnMaxDigitsFor01ByteUInt;
      cnJDType_bin:;       // No Change
      End;//switch
    End;//With
  end;//case
    
  cnJDType_u2: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_i4;
      cnJDType_i2:        u2JDType := cnJDType_i4;
      cnJDType_i4:;        // No change
      cnJDType_i8:;        // No change
      cnJDType_i16:;       // No change
      cnJDType_i32:;       // No change
      cnJDType_u1:        u2JDType := cnJDType_u2;
      cnJDType_u2:;        // No change
      cnJDType_u4:;        // No change
      cnJDType_u8:;        // No change
      cnJDType_u16:;       // No change
      cnJDType_u32:;       // No change
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // no change
      cnJDType_cur:;       // No change
      cnJDType_ch:  begin u2JDType := cnJDType_s; u8DefinedSize  := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i4;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // no change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor02ByteUInt Then u8DefinedSize := cnMaxDigitsFor02ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor02ByteUInt Then u8DefinedSize := cnMaxDigitsFor02ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 2) And (u8DefinedSize <> 0) Then u8DefinedSize := 2;
      End;//switch
    End;//With
  end;//case
    
  cnJDType_u4: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_i8;
      cnJDType_i2:        u2JDType := cnJDType_i8;
      cnJDType_i4:        u2JDType := cnJDType_i8;
      cnJDType_i8:;        // no change
      cnJDType_i16:;       // No change
      cnJDType_i32:;       // No change
      cnJDType_u1:        u2JDType := cnJDType_u4;
      cnJDType_u2:        u2JDType := cnJDType_u4;
      cnJDType_u4:        u2JDType := cnJDType_u4;
      cnJDType_u8:;        // No change
      cnJDType_u16:;       // No change
      cnJDType_u32:;       // no change
      cnJDType_fp:;        // No change
      cnJDType_fd:;        // no change
      cnJDType_cur:;       // no change
      cnJDType_ch:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor04ByteUInt; end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor04ByteUInt; end;
      cnJDType_b:         u2JDType := cnJDType_i8;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText; end;
      cnJDType_s:;         // no change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor04ByteUInt Then u8DefinedSize := cnMaxDigitsFor04ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor04ByteUInt Then u8DefinedSize := cnMaxDigitsFor04ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 4) And (u8DefinedSize <> 0) Then u8DefinedSize := 4;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_u8: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk:= False;
      cnJDType_i1:       u2JDType := cnJDType_i16;
      cnJDType_i2:        u2JDType := cnJDType_i16;
      cnJDType_i4:        u2JDType := cnJDType_i16;
      cnJDType_i8:        u2JDType := cnJDType_i16;
      cnJDType_i16:;       // No change
      cnJDType_i32:;       // no change
      cnJDType_u1:        u2JDType := cnJDType_u8;
      cnJDType_u2:        u2JDType := cnJDType_u8;
      cnJDType_u4:        u2JDType := cnJDType_u8;
      cnJDType_u8:        u2JDType := cnJDType_u8;
      cnJDType_u16:;       // no change
      cnJDType_u32:;       // no change
      cnJDType_fp:;        // no Change
      cnJDType_fd:;        // No change
      cnJDType_cur:;       // no change
      cnJDType_ch:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt; end;
      cnJDType_chu: begin u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor08ByteUInt; end;
      cnJDType_b:         u2JDType := cnJDType_i16;
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt; end;
      cnJDType_s:;         // No change
      cnJDType_su:;        // No change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor08ByteUInt Then u8DefinedSize := cnMaxDigitsFor08ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor08ByteUInt Then u8DefinedSize := cnMaxDigitsFor08ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 8) And (u8DefinedSize <> 0) Then u8DefinedSize := 8;
      End;//switch
    End;//with
  end;//case
  
  cnJDType_u16: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_i32;
      cnJDType_i2:        u2JDType := cnJDType_i32;
      cnJDType_i4:        u2JDType := cnJDType_i32;
      cnJDType_i8:        u2JDType := cnJDType_i32;
      cnJDType_i16:       u2JDType := cnJDType_i32;
      cnJDType_i32:;       // No change
      cnJDType_u1:        u2JDType := cnJDType_u16;
      cnJDType_u2:        u2JDType := cnJDType_u16;
      cnJDType_u4:        u2JDType := cnJDType_u16;
      cnJDType_u8:        u2JDType := cnJDType_u16;
      cnJDType_u16:;      // No change
      cnJDType_u32:;      // No change
      cnJDType_fp:;       // No change
      cnJDType_fd:;       // no change
      cnJDType_cur:;      // No change
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize:= cnMaxDigitsFor16ByteUInt;end;
      cnJDType_b:         u2JDType := cnJDType_i32;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_s:;        // no change
      cnJDType_su:;       // no change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor16ByteUInt Then u8DefinedSize := cnMaxDigitsFor16ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor16ByteUInt Then u8DefinedSize := cnMaxDigitsFor16ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 16) And (u8DefinedSize <> 0) Then u8DefinedSize := 16;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_u32: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_i2: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_i4: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_i8: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_i16:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_i32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_u1:        u2JDType := cnJDType_u32;
      cnJDType_u2:        u2JDType := cnJDType_u32;
      cnJDType_u4:        u2JDType := cnJDType_u32;
      cnJDType_u8:        u2JDType := cnJDType_u32;
      cnJDType_u16:       u2JDType := cnJDType_u32;
      cnJDType_u32:       u2JDType := cnJDType_u32;
      cnJDType_fp:;        // No Change
      cnJDType_fd:;        // No Change
      cnJDType_cur:;       // No Change
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt; end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_b:  begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_s:;         // No Chang:e
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsFor32ByteUInt Then u8DefinedSize := cnMaxDigitsFor32ByteUInt;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsFor32ByteUInt Then u8DefinedSize := cnMaxDigitsFor32ByteUInt;
      cnJDType_bin:       If (u8DefinedSize < 32) And (u8DefinedSize <> 0) Then u8DefinedSize := 32;
      End;//switch
    End;//With
  end;//case
    
  cnJDType_fp: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin
       u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i2: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i4: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i8: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i16: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i32: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u1: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u2: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u4: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u8: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u16: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u32: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_fp: begin
        u2JDType :=            cnJDType_fp;
        If i4NumericScale < p_rJegasFieldSrc.i4NumericScale Then i4NumericScale := p_rJegasFieldSrc.i4NumericScale;
        If i4Precision < p_rJegasFieldSrc.i4Precision Then i4Precision := p_rJegasFieldSrc.i4Precision;
        If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_fd: begin
        u2JDType :=            cnJDType_fd;
        If i4NumericScale < p_rJegasFieldSrc.i4NumericScale Then i4NumericScale := p_rJegasFieldSrc.i4NumericScale;
        If i4Precision < p_rJegasFieldSrc.i4Precision Then i4Precision := p_rJegasFieldSrc.i4Precision;
        If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_cur:;       // No Change - preserve accuracy if possible
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFPtoText;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForFPtoText;end;
      cnJDType_b: begin
        u2JDType :=            cnJDType_fp;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFPtoText;end;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsForFPtoText Then u8DefinedSize := cnMaxDigitsForFPtoText;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsForFPtoText Then u8DefinedSize := cnMaxDigitsForFPtoText;
      cnJDType_bin:       bOk := False;// Not Sure how to handle this.
      End;//switch
    End;//with
  end;//case
    
  cnJDType_fd: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin
       u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i2: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i4: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i8: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i16: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_i32: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u1: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u2: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u4: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u8: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u16: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_u32: begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_fp: begin
        u2JDType :=            cnJDType_fd;
        If i4NumericScale < p_rJegasFieldSrc.i4NumericScale Then i4NumericScale := p_rJegasFieldSrc.i4NumericScale;
        If i4Precision < p_rJegasFieldSrc.i4Precision Then i4Precision := p_rJegasFieldSrc.i4Precision;
        If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_fd: begin
        bOk := False;
        u2JDType :=       cnJDType_fd;
        If i4NumericScale < p_rJegasFieldSrc.i4NumericScale Then i4NumericScale := p_rJegasFieldSrc.i4NumericScale;
        If i4Precision < p_rJegasFieldSrc.i4Precision Then i4Precision := p_rJegasFieldSrc.i4Precision;
        If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_cur:;       // No Change - preserve accuracy if possible
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFDtoText;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForFDtoText;end;
      cnJDType_b:  begin
        u2JDType :=            cnJDType_fd;
        i4NumericScale :=         p_rJegasFieldSrc.i4NumericScale;
        i4Precision :=            p_rJegasFieldSrc.i4Precision;
        u8DefinedSize :=         p_rJegasFieldSrc.u8DefinedSize;
        bTrueFalse :=             p_rJegasFieldSrc.bTrueFalse;
      end;//case
      cnJDType_dt:  begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFDtoText;end;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsForFDtoText Then u8DefinedSize := cnMaxDigitsForFDtoText;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsForFDtoText Then u8DefinedSize := cnMaxDigitsForFDtoText;
      cnJDType_bin:       bOk := False; // Not sure how to handle this
      End;//switch
    End;// With
  end;//case
    
  cnJDType_cur: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_cur;
      cnJDType_i2:        u2JDType := cnJDType_cur;
      cnJDType_i4:        u2JDType := cnJDType_cur;
      cnJDType_i8:        u2JDType := cnJDType_cur;
      cnJDType_i16:       u2JDType := cnJDType_cur;
      cnJDType_i32:       u2JDType := cnJDType_cur;
      cnJDType_u1:        u2JDType := cnJDType_cur;
      cnJDType_u2:        u2JDType := cnJDType_cur;
      cnJDType_u4:        u2JDType := cnJDType_cur;
      cnJDType_u8:        u2JDType := cnJDType_cur;
      cnJDType_u16:       u2JDType := cnJDType_cur;
      cnJDType_u32:       u2JDType := cnJDType_cur;
      cnJDType_fp:        u2JDType := cnJDType_cur;
      cnJDType_fd:        u2JDType := cnJDType_cur;
      cnJDType_cur:;       // No Change
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText; end;
      cnJDType_chu:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText; end;
      cnJDType_b:  begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText; end;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText; end;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsForCurtoText Then u8DefinedSize := cnMaxDigitsForCurtoText;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsForCurtoText Then u8DefinedSize := cnMaxDigitsForCurtoText;
      cnJDType_bin:       bOk := False; // Not sure how to handle this
      End;//switch
    End;// With
  end;//case
    
  cnJDType_ch: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_i2: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_i4: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor04ByteUInt;end;
      cnJDType_i8: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_i16:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_i32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_u1: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_u2: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_u4: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor04ByteUInt;end;
      cnJDType_u8: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_u16:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_u32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFPtoText  ;end;
      cnJDType_fd: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFDtoText  ;end;
      cnJDType_cur:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText ;end;
      cnJDType_ch:;        // No Change
      cnJDType_chu:;       // No Change
      cnJDType_b:  begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_dt: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < 1 Then u8DefinedSize := 1;
      cnJDType_sun:       If u8DefinedSize < 1 Then u8DefinedSize := 1;
      cnJDType_bin:;       // No Change
      End;//switch
    End;// With
  end;//case
    
  cnJDType_chu: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_i2: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_i4: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor04ByteUInt;end;
      cnJDType_i8: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_i16:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_i32:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_u1: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_u2: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor02ByteUInt;end;
      cnJDType_u4: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor04ByteUInt;end;
      cnJDType_u8: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_u16:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_u32:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForFPtoText  ;end;
      cnJDType_fd: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForFDtoText  ;end;
      cnJDType_cur:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForCurtoText ;end;
      cnJDType_ch: begin  u2JDType := cnJDType_su; If u8DefinedSize < 1 Then u8DefinedSize := 1;end;
      cnJDType_chu:;       // No Change
      cnJDType_b:  begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsFor01ByteUInt;end;
      cnJDType_dt: begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:         u2JDType := cnJDType_su;
      cnJDType_su:;        // No Change
      cnJDType_sn: begin  u2JDType := cnJDType_sun; If u8DefinedSize < 1 Then u8DefinedSize := 1;end;
      cnJDType_sun:       If u8DefinedSize < 1 Then u8DefinedSize := 1;
      cnJDType_bin:       If (u8DefinedSize < 2) And (u8DefinedSize <> 0) Then u8DefinedSize := 2;
      End;//switch
    End;//With
  end;//case
    
  cnJDType_b: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:;        // No Change
      cnJDType_i2:;        // No Change
      cnJDType_i4:;        // No Change
      cnJDType_i8:;        // No Change
      cnJDType_i16:;       // No Change
      cnJDType_i32:;       // No Change
      cnJDType_u1:       u2JDType := cnJDType_i2 ;
      cnJDType_u2:        u2JDType := cnJDType_i4 ;
      cnJDType_u4:        u2JDType := cnJDType_i8 ;
      cnJDType_u8:        u2JDType := cnJDType_i16;
      cnJDType_u16:       u2JDType := cnJDType_i32;
      cnJDType_u32:begin  u2JDType := cnJDType_s ;u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp:;        // No Change
      cnJDType_fd:;        // No Change
      cnJDType_cur:;       // No Change
      cnJDType_ch:        begin u2JDType := cnJDType_s; u8DefinedSize := 1;end;
      cnJDType_chu:       begin u2JDType := cnJDType_su;u8DefinedSize := 1;end;
      cnJDType_b:;         // No Change
      cnJDType_dt:        begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_s:;         // NoChange
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < 1 Then u8DefinedSize := 1;
      cnJDType_sun:       If u8DefinedSize < 1 Then u8DefinedSize := 1;
      cnJDType_bin:;       // No Change - 1 bit per byte
      End;//switch
    End;//With
  end;//case
    

  cnJDType_dt: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_i2: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_i4: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_i8: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_i16:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_i32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_u1: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_u2: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_u4: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_u8: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor08ByteUInt;end;
      cnJDType_u16:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor16ByteUInt;end;
      cnJDType_u32:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsFor32ByteUInt;end;
      cnJDType_fp: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFPtoText  ;end;
      cnJDType_fd: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForFDtoText  ;end;
      cnJDType_cur:begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForCurtoText ;end;
      cnJDType_ch: begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_chu:begin  u2JDType := cnJDType_su; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_b:  begin  u2JDType := cnJDType_s; u8DefinedSize := cnMaxDigitsForDateToText;end;
      cnJDType_dt:;        // No Change
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < cnMaxDigitsForDateToText Then u8DefinedSize := cnMaxDigitsForDateToText;
      cnJDType_sun:       If u8DefinedSize < cnMaxDigitsForDateToText Then u8DefinedSize := cnMaxDigitsForDateToText;
      cnJDType_bin:       bOk := False;
      End;//switch
    End;//with
  end;//case
    
  cnJDType_s: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_s ;
      cnJDType_i2:        u2JDType := cnJDType_s ;
      cnJDType_i4:        u2JDType := cnJDType_s ;
      cnJDType_i8:        u2JDType := cnJDType_s ;
      cnJDType_i16:       u2JDType := cnJDType_s ;
      cnJDType_i32:       u2JDType := cnJDType_s ;
      cnJDType_u1:        u2JDType := cnJDType_s ;
      cnJDType_u2:        u2JDType := cnJDType_s ;
      cnJDType_u4:        u2JDType := cnJDType_s ;
      cnJDType_u8:        u2JDType := cnJDType_s ;
      cnJDType_u16:       u2JDType := cnJDType_s ;
      cnJDType_u32:       u2JDType := cnJDType_s ;
      cnJDType_fp:        u2JDType := cnJDType_s ;
      cnJDType_fd:        u2JDType := cnJDType_s ;
      cnJDType_cur:       u2JDType := cnJDType_s ;
      cnJDType_ch:        u2JDType := cnJDType_s ;
      cnJDType_chu:       u2JDType := cnJDType_su;
      cnJDType_b:         u2JDType := cnJDType_s ;
      cnJDType_dt:        u2JDType := cnJDType_s ;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        u2JDType := cnJDType_s;
      cnJDType_sun:       u2JDType := cnJDType_su;
      cnJDType_bin:       u8DefinedSize := 0 ;// Unspecified length
      End;//switch
    End;// With
  end;//case
    
  cnJDType_su: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_su;
      cnJDType_i2:        u2JDType := cnJDType_su;
      cnJDType_i4:        u2JDType := cnJDType_su;
      cnJDType_i8:        u2JDType := cnJDType_su;
      cnJDType_i16:       u2JDType := cnJDType_su;
      cnJDType_i32:       u2JDType := cnJDType_su;
      cnJDType_u1:        u2JDType := cnJDType_su;
      cnJDType_u2:        u2JDType := cnJDType_su;
      cnJDType_u4:        u2JDType := cnJDType_su;
      cnJDType_u8:        u2JDType := cnJDType_su;
      cnJDType_u16:       u2JDType := cnJDType_su;
      cnJDType_u32:       u2JDType := cnJDType_su;
      cnJDType_fp:        u2JDType := cnJDType_su;
      cnJDType_fd:        u2JDType := cnJDType_su;
      cnJDType_cur:       u2JDType := cnJDType_su;
      cnJDType_ch:        u2JDType := cnJDType_su;
      cnJDType_chu:       u2JDType := cnJDType_su;
      cnJDType_b:         u2JDType := cnJDType_su;
      cnJDType_dt:        u2JDType := cnJDType_su;
      cnJDType_s:         u2JDType := cnJDType_su;
      cnJDType_su:;        // No Change
      cnJDType_sn:        u2JDType := cnJDType_su;
      cnJDType_sun:       u2JDType := cnJDType_su;
      cnJDType_bin:       u8DefinedSize := 0; // UnSpecified length
      End;//switch
    End;// With
  end;//case
    
  cnJDType_sn: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:       u2JDType := cnJDType_sn ;
      cnJDType_i2:        u2JDType := cnJDType_sn ;
      cnJDType_i4:        u2JDType := cnJDType_sn ;
      cnJDType_i8:        u2JDType := cnJDType_sn ;
      cnJDType_i16:       u2JDType := cnJDType_sn ;
      cnJDType_i32:       u2JDType := cnJDType_sn ;
      cnJDType_u1:        u2JDType := cnJDType_sn ;
      cnJDType_u2:        u2JDType := cnJDType_sn ;
      cnJDType_u4:        u2JDType := cnJDType_sn ;
      cnJDType_u8:        u2JDType := cnJDType_sn ;
      cnJDType_u16:       u2JDType := cnJDType_sn ;
      cnJDType_u32:       u2JDType := cnJDType_sn ;
      cnJDType_fp:        u2JDType := cnJDType_sn ;
      cnJDType_fd:        u2JDType := cnJDType_sn ;
      cnJDType_cur:       u2JDType := cnJDType_sn ;
      cnJDType_ch:        u2JDType := cnJDType_sn ;
      cnJDType_chu:       u2JDType := cnJDType_sun;
      cnJDType_b:         u2JDType := cnJDType_sn ;
      cnJDType_dt:        u2JDType := cnJDType_sn ;
      cnJDType_s:;         // No Change
      cnJDType_su:;        // No Change
      cnJDType_sn:        If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      cnJDType_sun:       If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      cnJDType_bin:       If (u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize) And (u8DefinedSize <> 0) Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      End;//switch
    End;// With
  end;//case
    
  cnJDType_sun: begin
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1:        u2JDType := cnJDType_sun;
      cnJDType_i2:        u2JDType := cnJDType_sun;
      cnJDType_i4:        u2JDType := cnJDType_sun;
      cnJDType_i8:        u2JDType := cnJDType_sun;
      cnJDType_i16:       u2JDType := cnJDType_sun;
      cnJDType_i32:       u2JDType := cnJDType_sun;
      cnJDType_u1:        u2JDType := cnJDType_sun;
      cnJDType_u2:        u2JDType := cnJDType_sun;
      cnJDType_u4:        u2JDType := cnJDType_sun;
      cnJDType_u8:        u2JDType := cnJDType_sun;
      cnJDType_u16:       u2JDType := cnJDType_sun;
      cnJDType_u32:       u2JDType := cnJDType_sun;
      cnJDType_fp:        u2JDType := cnJDType_sun;
      cnJDType_fd:        u2JDType := cnJDType_sun;
      cnJDType_cur:       u2JDType := cnJDType_sun;
      cnJDType_ch:        u2JDType := cnJDType_sun;
      cnJDType_chu:       u2JDType := cnJDType_sun;
      cnJDType_b:         u2JDType := cnJDType_sun;
      cnJDType_dt:        u2JDType := cnJDType_sun;
      cnJDType_s:         u2JDType := cnJDType_sun;
      cnJDType_su:;        // No Change
      cnJDType_sn: begin  u2JDType := cnJDType_sun; If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_sun:       If u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      cnJDType_bin:       If (u8DefinedSize < (p_rJegasFieldSrc.u8DefinedSize * 2)) And (u8DefinedSize <> 0) Then u8DefinedSize := (p_rJegasFieldSrc.u8DefinedSize * 2);
      End;//switch
    End;// With
  end;//case
    

  cnJDType_bin: begin // Bin Length ZERO Means Unspecified.
    With p_rJegasFieldDest do begin 
      Case u2JDType of
      cnJDType_Unknown:   bOk := False;
      cnJDType_i1: begin u2JDType := cnJDType_bin; u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_i2: begin  u2JDType := cnJDType_bin; If (p_rJegasFieldSrc.u8DefinedSize < 2) And (p_rJegasFieldSrc.u8DefinedSize <> 0) Then u8DefinedSize := 2 Else u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_i4: begin  u2JDType := cnJDType_bin; If (p_rJegasFieldSrc.u8DefinedSize < 4) And (p_rJegasFieldSrc.u8DefinedSize <> 0) Then u8DefinedSize := 4 Else u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_i8: begin  u2JDType := cnJDType_bin; If (p_rJegasFieldSrc.u8DefinedSize < 8) And (p_rJegasFieldSrc.u8DefinedSize <> 0) Then u8DefinedSize := 8 Else u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_i16:begin  u2JDType := cnJDType_bin; If (p_rJegasFieldSrc.u8DefinedSize < 16) And (p_rJegasFieldSrc.u8DefinedSize <> 0) Then u8DefinedSize := 16 Else u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_i32:begin  u2JDType := cnJDType_bin; If (p_rJegasFieldSrc.u8DefinedSize < 32) And (p_rJegasFieldSrc.u8DefinedSize <> 0) Then u8DefinedSize := 32 Else u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_u1: begin  u2JDType := cnJDType_bin; u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_u2: begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 2) And (u8DefinedSize <> 0) Then u8DefinedSize := 2;end;
      cnJDType_u4: begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 4) And (u8DefinedSize <> 0) Then u8DefinedSize := 4;end;
      cnJDType_u8: begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 8) And (u8DefinedSize <> 0) Then u8DefinedSize := 8;end;
      cnJDType_u16:begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 16) And (u8DefinedSize <> 0) Then u8DefinedSize := 16;end;
      cnJDType_u32:begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 32) And (u8DefinedSize <> 0) Then u8DefinedSize := 32;end;
      cnJDType_fp:        bOk := False;
      cnJDType_fd:        bOk := False;
      cnJDType_cur:       bOk := False;
      cnJDType_ch: begin  u2JDType := cnJDType_bin; u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_chu:begin  u2JDType := cnJDType_bin; If (u8DefinedSize < 2) Then u8DefinedSize := 2;end;
      cnJDType_b:  begin  u2JDType := cnJDType_bin; u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;end;
      cnJDType_dt:        bOk := False;
      cnJDType_s:         u8DefinedSize := 0;// Unspecified
      cnJDType_su:        u8DefinedSize := 0;// UnSpecified
      cnJDType_sn:        If (u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize) And (u8DefinedSize <> 0) Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      cnJDType_sun:       If (u8DefinedSize < (p_rJegasFieldSrc.u8DefinedSize * 2)) And (u8DefinedSize <> 0) Then u8DefinedSize := (p_rJegasFieldSrc.u8DefinedSize * 2);
      cnJDType_bin:       If (u8DefinedSize < p_rJegasFieldSrc.u8DefinedSize) And (u8DefinedSize <> 0) Then u8DefinedSize := p_rJegasFieldSrc.u8DefinedSize;
      End;//switch
    End;// With
  end;//case
  End;//switch
  
  
  If bOk Then
  begin 
    // We do this check because its possible that a
    // a MODIFIED can be forced. this code will work
    // if this never becomes the case.
    If Not p_bModified Then
    begin
      With rJegasFieldDestCopy do begin 
        p_bModified := 
          (bTrueFalse     <> p_rJegasFieldDest.bTrueFalse) Or 
          (u8DefinedSize <> p_rJegasFieldDest.u8DefinedSize) Or 
          (u2JDType    <> p_rJegasFieldDest.u2JDType) Or
          (i4NumericScale <> p_rJegasFieldDest.i4NumericScale) Or 
          (i4Precision    <> p_rJegasFieldDest.i4Precision) Or 
          (saName     <> p_rJegasFieldDest.saName) 
          // Or (.vValue <> p_rJegasFieldDest.vValue)
      End;// With
    End;
  end
  Else
  begin
    p_bModified := False;
  End;
  result:= bOk;
End;
//=============================================================================






//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#! Email
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
function bSendMail(
  p_saTo: ansistring;
  p_saFrom: ansistring;
  p_saSubject: ansistring;
  p_saMsg: ansistring
):boolean;
//=============================================================================
var
  PROCESS: TProcess;
  saPayLoad: ansistring;
  bOk: boolean;
begin
  bOk:=true;
  saPayLoad:='To: '+ p_saTo + csCRLF + 'From: '+p_saFrom+csCRLF+'Subject: '+p_saSubject+csCRLF+csCRLF+p_saMsg+#26;
  PROCESS:=TProcess.Create(nil);
  Process.options:=Process.options+[pousepipes];
  {$IFNDEF LINUX}
  Process.Currentdirectory:=grJASConfig.saSysDir+'sendmail'+csDOSSLASH;
  Process.CommandLine:=Process.Currentdirectory+'sendmail.exe';
  {$ELSE}
  Process.CommandLine:='sendmail';
  {$ENDIF}
  //ASPrintln('SENDMAIL---------BEGIN');
  //ASPrintln('Payload:'+saPayLoad);
  //ASPrintln('');
  //ASPrintln('Process.CommandLine:'+Process.CommandLine);
  try
    Process.Execute;
  except
    bOk:=false; // um - just don't stop running :)
  end;
  Process.Input.Write(PCHAR(saPayload)^,length(saPayload));
  While Process.Running Do Sleep(1);
  //ASPrintln('Process Finished!');
  //ASPrintln('SENDMAIL---------END');
  PROCESS.Destroy;
  result:=bOk;
end;
//=============================================================================














//=============================================================================
{}
//  This function allows you to ask for a file you need from the system
// or a theme etc...
// and it will follow a series of locations to attempt to satisfy that request
// taking into account the current language, current theme, etc... and work its
// way back to the default theme, then the built in templates that are not
// generally "directly accessible" like the theme bits might be. (It;s like the
// built in CORE UI for JAS - so - we have a fall back or two to try to keep
// running - even when things get misconfigured, forgotten or something.
//
//       IN: RELPATHNFILE ( e.g.: './en/error/somefile????' );
//       OUT: Full pathnfile to first version of file in order of precendence
//
//       (Current Theme Dir)
//       CURRENT LANG (??) Folder
//       DEFAULTLANG (EN)
//       ROOT of Theme   (  './' )
//
//       If NOT ALREADY IN 'default' theme - check that next....
//       ('default' Theme Dir)
//       CURRENT LANG (??) Folder
//       DEFAULTLANG (EN)
//       ROOT of Theme   (  './' )
//
//       LAST RESORT:
//       ('templates' Dir) - Which unlike themes - are not generally set up for folks on the outside to access directly.
//       CURRENT LANG (??) Folder
//       DEFAULTLANG (EN)
//       ROOT of Theme   (  './' )
//
//       IF NOT TEMPLATE Exists - then an empty string is returned
//=============================================================================
function saJasLocateTemplate(
  p_saREL_PATH_N_FILE,
  p_saCurrentLang,
  p_saCurrentTheme,
  p_saRequestedDir: ansistring;
  p_i8Caller: int64;
  p_VHostTemplateDir: ansistring
): ansistring;
var saFile: ansistring;
    bGotOne: boolean;
    iLenCurrentLang: longint;
    iLenCurrentTheme: longint;
    bTestForJASTheme: boolean;
begin
  {$IFDEF DIAGNOSTICMESSAGES}
  writeln('        saJasLocateTemplate ENTRY ------ '+inttostr(p_i8Caller));
  writeln('            p_saREL_PATH_N_FILE: '+p_saREL_PATH_N_FILE);
  writeln('            p_saCurrentLang: '+p_saCurrentLang);
  writeln('            p_saCurrentTheme: '+p_saCurrentTheme);
  writeln('            p_saRequestedDir: '+p_saRequestedDir);
  writeln('        saJasLocateTemplate BEGIN ------ ');
  {$ENDIF}

  bGotOne:=false;//riteln('bGotOne set to false');
  iLenCurrentLang:=length(p_saCurrentLang);//riteln('iLenCurrentLang: ',iLenCurrentLang);
  iLenCurrentTheme:=length(p_saCurrentTheme);//riteln('iLenCurrentTheme: ',iLenCurrentTheme);

  bTestForJASTheme:=(rightstr(p_saREL_PATH_N_FILE,4)='.jas');

  if (not bGotOne) then;//and (iLenCurrentLang>0) and (iLenCurrentTheme>0) then
  begin
    saFile:=p_saRequestedDir +p_saREL_PATH_N_FILE;
    bGotOne:=bFileExists(saFile);
    {$IFDEF DIAGNOSTICMESSAGES}
    writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
    {$ENDIF}
    if (not bGotOne) and (bTestForJASTheme) then
    begin
      saFile+='theme';
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
  end;

  //riteln('First See If there is a Theme in Play - if so - see if a language specific version exists...');
  if (not bGotOne) and (iLenCurrentLang>0) and (iLenCurrentTheme>0) then
  begin
    saFile:=grJASCOnfig.saWebShareDir + 'themes/'+p_saCurrentTheme+'/templates/'+p_saCurrentLang+'/'+p_saREL_PATH_N_FILE;
    bGotOne:=bFileExists(saFile);
    {$IFDEF DIAGNOSTICMESSAGES}
    writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
    {$ENDIF}
    if (not bGotOne) and (bTestForJASTheme) then
    begin
      saFile+='theme';
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
  end;




  if (not bGotOne) and (iLenCurrentLang>0) and (iLenCurrentTheme>0) then
  begin
    saFile:=grJASCOnfig.saWebShareDir + 'themes/'+p_saCurrentTheme+'/templates/'+p_saCurrentLang+'/'+p_saREL_PATH_N_FILE;
    bGotOne:=bFileExists(saFile);
    {$IFDEF DIAGNOSTICMESSAGES}
    writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
    {$ENDIF}
    if (not bGotOne)  and (bTestForJASTheme) then
    begin
      saFile+='theme';
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
  end;


  //riteln('If Not There - And NOT English already then Try en (English) folder  folder...');
  if (not bGotOne) and (iLenCurrentLang>0) then
  begin
    if p_saCurrentLang<>'en' then
    begin
      saFile:=grJASCOnfig.saWebShareDir + 'themes/'+p_saCurrentTheme+'/templates/en/'+p_saREL_PATH_N_FILE;
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
    if (not bGotOne)  and (bTestForJASTheme) then
    begin
      saFile+='theme';
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
  end;


  if (not bGotOne) and (iLenCurrentTheme>0) then
  begin
    saFile:=grJASCOnfig.saWebShareDir + 'themes/'+p_saCurrentTheme+'/templates/'+p_saREL_PATH_N_FILE;
    //riteln('if not there - try up directory....: ',saFile);
    bGotOne:=bFileExists(saFile);
    {$IFDEF DIAGNOSTICMESSAGES}
    writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
    {$ENDIF}
    if (not bGotOne) and (bTestForJASTheme) then
    begin
      saFile+='theme';
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
    end;
  end;

{
  //riteln('---------- NOW TRY THE SAME THING IN DEFAULT TEMPLATE ( ''default'' )');
  //riteln(' First See If there is a Theme in Play - if so - see if a language specific version exists...');
  if not bGotOne then
  begin
    if (not bGotOne) and (iLenCurrentLang>0) and (p_saCurrentTheme<>'default') then
    begin
      saFile:=grJASConfig.saThemeDir+'default/templates/' + p_saCurrentLang +'/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      bGotOne:=bFileExists(saFile);
      riteln('Exist? '+saYesNo(bGotOne)+' '+saFile);
      //riteln(' If Not There - Try ''en'' folder...');
      if not bGotOne then
      begin
        if p_saCurrentLang<>'en' then
        begin
          saFile:=grJASConfig.saThemeDir+'default/templates/en/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
          bGotOne:=bFileExists(saFile);
          riteln('Exist? '+saYesNo(bGotOne)+' '+saFile);
        end;
      end;

      //riteln(' if not there - try up directory....');
      if not bGotOne then
      begin
        saFile:=grJASConfig.saThemeDir+p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
        bGotOne:=bFileExists(saFile);
        riteln('Exist? '+saYesNo(bGotOne)+' '+saFile);
      end;
    end;
  end;
}

  //riteln('----------  NOW Try in the (system) templates dir');
  //riteln(' if STILL not around - Rinse and repeat in the system templates folder');
  //riteln(' First See If there is a Theme in Play - if so - see if a language specific version exists...');
  if not bGotOne then
  begin
    if (iLenCurrentLang>0)then
    begin
      //saFile:=grJASConfig.saTemplatesDir + p_saCurrentLang +'/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      saFile:=p_VHostTemplateDir + p_saCurrentLang +'/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
      if (not bGotOne) and (bTestForJASTheme) then
      begin
        saFile+='theme';
        bGotOne:=bFileExists(saFile);
        {$IFDEF DIAGNOSTICMESSAGES}
        writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
        {$ENDIF}
      end;
    end;

    //riteln(' If Not There - Try ''en'' folder...');
    if (not bGotOne) and (p_saCurrentLang<>'en') then
    begin
      //saFile:=grJASConfig.saTemplatesDir+'en/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      saFile:=p_VHostTemplateDir+'en/'+ p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
      if (not bGotOne) and (bTestForJASTheme) then
      begin
        saFile+='theme';
        bGotOne:=bFileExists(saFile);
        {$IFDEF DIAGNOSTICMESSAGES}
        writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
        {$ENDIF}
      end;
    end;

    //riteln(' if not there - try up directory....');
    if not bGotOne then
    begin
      //saFile:=grJASConfig.saTemplatesDir+p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      saFile:=p_VHostTemplateDir+p_saREL_PATH_N_FILE;// EXPECTS p_saREL_PATH_N_FILE to not start with a leading slash. e.g. 'somedir/file.html' is perfect!
      bGotOne:=bFileExists(saFile);
      {$IFDEF DIAGNOSTICMESSAGES}
      writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
      {$ENDIF}
      if (not bGotOne) and (bTestForJASTheme) then
      begin
        saFile+='theme';
        bGotOne:=bFileExists(saFile);
        {$IFDEF DIAGNOSTICMESSAGES}
        writeln('        Exist? '+saYesNo(bGotOne)+' '+saFile);
        {$ENDIF}
      end;
    end;
  end;

  if bGotOne then
  begin
    result:=saFile;
  end
  else
  begin
    result:='';
  end;
  {$IFDEF DIAGNOSTICMESSAGES}
  writeln('        END ------ RESULT: '+result);
  {$ENDIF}
end;
//=============================================================================






Const csLockfile = 'zzSystemLockfile.lock';
Const csSystemAutonumberFilename = 'zzSystemAutonumber.txt';
Const cnRetryLimit=20;
Const cnRetryDelayInMilliseconds=20;
Function saGetUniqueCommID(p_saPath: AnsiString):AnsiString;
Var
 flock: text;
 fautonum: text;
 iRetries: longint;
 bGotIt: Boolean;
 u2IOResult: Word;
 saLineIn: AnsiString;
 iAutoOut: longint;

Begin
  iRetries:=0;
  bGotit:=False;
  assign(flock, p_saPath + csLockFile);
  assign(fautonum, p_saPAth+csSystemAutonumberFilename);
  repeat
    {$I-}
    rewrite(flock);
    u2IOResult:=IOResult;
    {$I+}
    bGotIt:=u2IOResult=0;
    If not bGotIt Then
    Begin
      Inc(iRetries);
      Yield(cnRetryDelayInMilliseconds);
    End;
  Until bgotIt OR (iRetries>=cnRetryLimit);

  If bGotIt Then
  Begin
    saLineIn:='';
    {$I-}
    reset(fautonum);
    u2IOResult:=IOResult;
    {$I+}
    If u2IOResult<>0 Then // Make a new File?
    Begin
      // no problem... We are going to any way.
    End;

    If u2IOResult=0 Then
    Begin
      {$I-}
      readln(fautonum,saLineIn);
      {$I+}
      // Don''t care what we actually get. Just convert to a number,
      // and add one Then Write it back out and release the lock! :)
      close(fAutoNum);
    End;
    iAutoOut:=iVal(saLineIn);

    {$I-}
    rewrite(fautonum);
    //u2IOResult:=IOResult; /// Don''t care - but if a problem and you're
    // debugging - LOOK this over.
    {$I+}

    {$I-}
    Writeln(fautonum, saZeroPadInt(iAutoOut+1,7));
    //riteln(fautoNum, 'iAutoOut:',iAutoOut,' saLineIn:',saLineIn, ' saZeroPadInt(iAutoOut+1,7):',saZeroPadInt(iAutoOut+1,7),' bGotIt:',satrueFalse(bGotit));

    //u2IOResult:=IOResult; /// Don''t care - but if a problem and you're
    // debugging - LOOK this over.
    {$I+}
    close(fautonum);
    close(flock);// release the Lock
    Result:=saZeroPadInt(iAutoOut,7);
  End
  Else
  Begin
    Result:=saZeroPADInt(999999,7);
  End;
End;






















//=============================================================================
// This Function Interpolates Linear Data to numerically
// "Guess" what the missing data is.
// The Formula Semantics are to Find "Y", but by swapping the parameters
// you can find Your own "X" just as easily.
//=============================================================================
// y1|-------------O   In The Diagram we know everything except y
//   |             |   e.g. y1, y0, x0, x1, x WE KNOW THEM ALL
// y |      x,y    |        y = ?????
//   |        ^    |
// y0|---O    |    |
//   |___|____|____|
//      x0    x   x1
//
//=============================================================================
function Interpolate(x0:double; x1:double; x:double; y0:double; y1:double): double;
//=============================================================================
begin
  result:=y0+((x-x0)*((y1-y0)/(x1-x0)));
end;
//=============================================================================



//=============================================================================
{}
// converts from degrees to radians
function DEGTORAD(p_fDegree: double):double;
//=============================================================================
begin
 result:=((PI / 180.0) * (p_fDegree));
end;
//=============================================================================

//=============================================================================
{}
// converts from radians to degrees
function RADTODEG(p_fRadian: double):double;
//=============================================================================
begin
 result:= ((180.0 / PI) * (p_fRadian));
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Millimeters(p_Meters: double): double;
//=============================================================================
begin
  result:=p_Meters * cnMillimeters;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Centimeters(p_Meters:double): double;
//=============================================================================
begin
  result:= p_Meters * cnCentimeters;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Feet(p_Meters:double ): double;
//=============================================================================
begin
  result:= p_Meters * cnFeet;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Yards(p_Meters:double): double;
//=============================================================================
begin
  result:= p_Meters * cnYards;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Miles(p_Meters:double): double;
//=============================================================================
begin
  result:= p_Meters * cnMiles;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Inches(p_Meters:double): double;
//=============================================================================
begin
  result:= p_Meters * cnInches;
end;
//=============================================================================

//=============================================================================
function Convert_Meters_To_Kilometers(p_Meters:double):double;
//=============================================================================
begin
  result:= p_Meters * cnKilometers;
end;
//=============================================================================

//=============================================================================
function Convert_Millimeters_To_Meters(p_Millimeters:double):double;
//=============================================================================
begin
  result:= p_Millimeters / cnMillimeters;
end;
//=============================================================================

//=============================================================================
function Convert_Centimeters_To_Meters(p_Centimeters:double):double;
//=============================================================================
begin
  result:= p_Centimeters / cnCentimeters;
end;
//=============================================================================

//=============================================================================
function Convert_Feet_To_Meters(p_Feet:double):double;
//=============================================================================
begin
  result:= p_Feet / cnFeet;
end;
//=============================================================================

//=============================================================================
function Convert_Yards_To_Meters(p_Yards:double):double;
//=============================================================================
begin
  result:= p_Yards / cnYards;
end;
//=============================================================================

//=============================================================================
function Convert_Miles_To_Meters(p_Miles:double):double;
//=============================================================================
begin
  result:= p_Miles / cnMiles;
end;
//=============================================================================

//=============================================================================
function Convert_Inches_To_Meters(p_Inches:double):double;
//=============================================================================
begin
  result:= p_Inches / cnInches;
end;
//=============================================================================

//=============================================================================
function Convert_Kilometers_To_Meters(p_Kilometers:double):double;
//=============================================================================
begin
  result:= p_Kilometers / cnKilometers;
end;
//=============================================================================

//=============================================================================
function Convert_Seconds_To_MilliSeconds(p_Seconds:double):double;
//=============================================================================
begin
  result:= p_Seconds * cnMilliseconds;
end;
//=============================================================================

//=============================================================================
function Convert_Seconds_To_Minutes(p_Seconds:double):double;
//=============================================================================
begin
  result:= p_Seconds * cnMinutes;
end;
//=============================================================================

//=============================================================================
function Convert_Seconds_To_Hours(p_Seconds:double):double;
//=============================================================================
begin
  result:= p_Seconds * cnHours;
end;
//=============================================================================

//=============================================================================
function Convert_Seconds_To_Days(p_Seconds:double):double;
//=============================================================================
begin
  result:= p_Seconds * cnDays;
end;
//=============================================================================

//=============================================================================
function Convert_Milliseconds_To_Seconds(p_Milliseconds:double):double;
//=============================================================================
begin
  result:= p_Milliseconds * cnMilliseconds;
end;
//=============================================================================

//=============================================================================
function Convert_Milliseconds_To_Minutes(p_Milliseconds:double):double;
//=============================================================================
begin
  result:= p_Milliseconds * cnMilliseconds * cnMinutes;
end;
//=============================================================================

//=============================================================================
function Convert_Milliseconds_To_Hours(p_Milliseconds:double):double;
//=============================================================================
begin
  result:= p_Milliseconds * cnMilliseconds * cnHours;
end;
//=============================================================================

//=============================================================================
function Convert_Minutes_To_Seconds(p_Minutes:double):double;
//=============================================================================
begin
  result:= p_Minutes * cnMinutes;
end;
//=============================================================================

//=============================================================================
function Convert_Hours_To_Seconds(p_Hours:double): double;
//=============================================================================
begin
  result:= p_Hours * cnSecondsPerHour;
end;
//=============================================================================

//=============================================================================
function Convert_Days_To_Hours(p_Days:double): double;
//=============================================================================
begin
  result:=p_Days * cnHoursPerDay;
end;
//=============================================================================

//=============================================================================
// End                  Measurement conversion routines
//=============================================================================


//=============================================================================
function ABS(i:longint): longint;
//=============================================================================
begin
  if(i<0)then
  begin
    result:= -i;
  end
  else
  begin
    result := i;
  end;
end;
//=============================================================================

//=============================================================================
function ABS(f: double): double;
//=============================================================================
begin
  if(f<0)then
  begin
    result:= -f;
  end
  else
  begin
    result:=f;
  end;
end;
//=============================================================================




//=============================================================================
function Distance(
  p_xpos:  single;
  p_ypos:  single;
  p_zpos:  single;
  p_xpos2: single;
  p_ypos2: single;
  p_zpos2: single
): double;
//=============================================================================
var
  nx: single;
  ny: single;
  nz: single;
begin
 // SQRT Way
 nx:=p_xpos - p_xpos2;
 ny:=p_ypos - p_xpos2;
 nz:=p_zpos - p_zpos2;
 result:=sqrt((nx*nx)+(ny*ny)+(nz*nz));
 // VECTOR WAY
 //dbSetVector3(JGC::mthDistanceVector->ID,p_xpos-p_xpos2, p_ypos-p_ypos2, p_zpos-p_zpos2);
 //return dbLengthVector3(JGC::mthDistanceVector->ID);
end;
//=============================================================================






//=============================================================================
//D3DXMATRIX *D3DXMATRIX_angleBetween(D3DXVECTOR3 v1,D3DXVECTOR3 v2) {
//=============================================================================
//	// turn vectors into unit vectors
//	D3DXVECTOR3 n1;
//  D3DXVECTOR3 n2;
//  D3DXVec3Normalize(&n1,&v1);
//  D3DXVec3Normalize(&n2,&v2);
//
//  D3DXVECTOR3 vs=n1;
//  D3DXVec3Cross(&vs,&vs,&n2);// axis multiplied by sin
//
//  D3DXVECTOR3 v=vs;
//  D3DXVec3Normalize(&v,&v); // axis of rotation
//
//	float ca = D3DXVec3Dot(&n1, &n2);// cos angle
//  D3DXVECTOR3 vt = v;
//  D3DXVec3Scale(&vt,&vt,1.0f-ca);
//  D3DXMATRIX *rotM = new D3DXMATRIX();
//	rotM->_11 = vt.x * v.x + ca;
//	rotM->_22 = vt.y * v.y + ca;
//	rotM->_33 = vt.z * v.z + ca;	vt.x *= v.y;
//	vt.z *= v.x;
//	vt.y *= v.z;	rotM->_12 = vt.x - vs.z;
//	rotM->_13 = vt.z + vs.y;
//	rotM->_21 = vt.x + vs.z;
//	rotM->_23 = vt.y - vs.x;
//	rotM->_31 = vt.z - vs.y;
//	rotM->_32 = vt.y + vs.x;
//	return rotM;
//};
//=============================================================================


//=============================================================================
//neQ JFC::Convert_EularAnglesToQuaternion(float p_X, float p_Y, float p_Z){
//----------------------------------------------------------------------------
//  JFC_XYZFLOAT jv3=JFC_XYZFLOAT();
//  jv3.X =p_X;jv3.Y=p_Y;jv3.Z=p_Z;
//  return JFC::Convert_EularAnglesToQuaternion(&jv3);
//};
//=============================================================================

//=============================================================================
//neQ JFC::Convert_EularAnglesToQuaternion(JFC_XYZFLOAT *p_jv3){
//=============================================================================
//  float e1=p_jv3->X;
//  float e2=p_jv3->Y;
//  float e3=p_jv3->Z;
//
//  //ORIGINAL
//  float u0 = sqrt(cos(e2*PI/180)*cos(e1*PI/180)+cos(e2*PI/180)*cos(e3*PI/180)-sin(e2*PI/180)*sin(e1*PI/180)*sin(e3*PI/180)+cos(e1*PI/180)* cos(e3*PI/180)+1)/2;
//  float u1 = (cos(e1*PI/180)*sin(e3*PI/180)+cos(e2*PI/180)*sin(e3*PI/180)+sin(e2*PI/180)*sin(e1*PI/180)*cos(e3*PI/180))/sqrt(cos(e2*PI/180)* cos(e1*PI/180)+cos(e2*PI/180)*cos(e3*PI/180)-sin(e2*PI/180)*sin(e1*PI/180)*sin(e3*PI/180)+cos(e1*PI/180)*cos(e3*PI/180)+1)/2;
//  float u2 = (sin(e2*PI/180)*sin(e3*PI/180)-cos(e2*PI/180)*sin(e1*PI/180)*cos(e3*PI/180)-sin(e1*PI/180))/sqrt(cos(e2*PI/180)*cos(e1*PI/180)+ cos(e2*PI/180)*cos(e3*PI/180)-sin(e2*PI/180)*sin(e1*PI/180)*sin(e3*PI/180)+cos(e1*PI/180)*cos(e3*PI/180)+1)/2;
//  float u3 = (sin(e2*PI/180)*cos(e1*PI/180)+sin(e2*PI/180)*cos(e3*PI/180)+cos(e2*PI/180)*sin(e1*PI/180)*sin(e3*PI/180))/sqrt(cos(e2*PI/180)* cos(e1*PI/180)+cos(e2*PI/180)*cos(e3*PI/180)-sin(e2*PI/180)*sin(e1*PI/180)*sin(e3*PI/180)+cos(e1*PI/180)*cos(e3*PI/180)+1)/2;
//
//  neQ q(u0,u1,u2,u3);
//  return q;
//};
////=============================================================================

//=============================================================================
//JFC_XYZFLOAT JFC::Convert_QuaternionToEulerAngles( neQ q ){
//=============================================================================
//  JFC_XYZFLOAT EulerAngles;// darkgdk way: dbAtanFull
//  EulerAngles.X = dbAtanFull((2*(q.W*q.X + q.Y*q.Z)),(1 - (2*(q.X*q.X + q.Y*q.Y))));
//  EulerAngles.Y = dbAsin(2*(q.W*q.Y - q.Z*q.X));
//  EulerAngles.Z = dbAtanFull ((2*(q.W*q.Z + q.X*q.Y)),(1 - (2*(q.Y*q.Y + q.Z*q.Z))));
//  return EulerAngles;
//};
////=============================================================================



//=============================================================================
//void JFC::Convert_QuaternionToEulerAngles( neQ q, float *p_X, float *p_Y, float *p_Z){
//=============================================================================
//  JFC_XYZFLOAT jv3=Convert_QuaternionToEulerAngles(q);
//  p_X=&jv3.X;
//  p_Y=&jv3.Y;
//  p_Z=&jv3.Z;
//};
//=============================================================================

//=============================================================================
//neQ JFC::QCrossProduct(neQ q1, neQ q2){
//=============================================================================
//  neQ r;
//  r.W = q1.W * q2.W - q1.X * q2.X - q1.Y * q2.Y - q1.Z * q2.Z;
//  r.X = q1.W * q2.X + q1.X * q2.W + q1.Y * q2.Z - q1.Z * q2.Y;
//  r.Y = q1.W * q2.Y + q1.Y * q2.W + q1.Z * q2.X - q1.X * q2.Z;
//  r.Z = q1.W * q2.Z + q1.Z * q2.W + q1.X * q2.Y - q1.Y * q2.X;
//  return r;
//};
//=============================================================================


//=============================================================================
//neQ JFC::CreateAxisRotationQuaternion( float fTheta, float fX, float fY, float fZ ){
//=============================================================================
//  neQ q;
//  q.W = cos( fTheta / 2 );
//  q.X = sin( fTheta / 2 ) * fX;
//  q.Y = sin( fTheta / 2 ) * fY;
//  q.Z = sin( fTheta / 2 ) * fZ;
//  return q;
//};
//=============================================================================

//=============================================================================
//float JFC::ATANFULLDEG(float x,float y){
//=============================================================================
//  //return dbAtanFull(x,y);
//  return RADTODEG(atan2(DEGTORAD(x),DEGTORAD(y)));
//};
//=============================================================================



//=============================================================================
// Initialization
//=============================================================================
Begin
  InitJegasUnit;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
