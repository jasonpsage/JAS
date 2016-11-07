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
// JAS Structures and Constants
Unit uj_definitions;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_definitions.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND}
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
uses
//=============================================================================
classes
,syncobjs
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_matrix
,ug_jado
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

//=============================================================================
//{}
//Constant to decide if automatic vhost generation is targeted for CGI BASED
//Installation or not.
const cbCGIBased = true;
//=============================================================================
const cnMaxGuestJMails = 4; // Limit of how many JMails an individual IP can
// send logged in as a guest. this is too "custom" at the moment to warrant
// adding this value to the system configuration paradigm


//=============================================================================
Var
//=============================================================================
  {}
  gsaPath: AnsiString;
  gsaExt: AnsiString;
  {}
  giTotalThreads: integer;
  giTotalThreadsIdle: integer;
  gaJCon: array of JADO_CONNECTION;
  //gPunkXDL: JFC_XDL;
  gasPunkBait: array of string;
  //gi8JipListLightSync: uint64;
  var gbMainSystemOnly: boolean;
//=============================================================================



//---- Sample windows ansi to utf-8
//
{
FUNCTION  AnsiToUtf8 (Source : ANSISTRING) : STRING;
          (* Converts the given Windows ANSI (Win1252) String <strong class="highlight">to</strong> UTF-8. *)
VAR
  I   : INTEGER;  // Loop counter
  U   : WORD;     // Current Unicode value
  Len : INTEGER;  // Current real length of "Result" string
BEGIN
  SetLength (Result, Length (Source) * 3);   // Worst case
  Len := 0;
  FOR I := 1 <strong class="highlight">TO</strong> Length (Source) DO BEGIN
    U := WIN1252_UNICODE [ORD (Source [I])];
    CASE U OF
      $0000..$007F : BEGIN
                       INC (Len);
                       Result [Len] := CHR (U);
                     END;
      $0080..$07FF : BEGIN
                       INC (Len);
                       Result [Len] := CHR ($C0 OR (U SHR 6));
                       INC (Len);
                       Result [Len] := CHR ($80 OR (U AND $3F));
                     END;
      $0800..$FFFF : BEGIN
                       INC (Len);
                       Result [Len] := CHR ($E0 OR (U SHR 12));
                       INC (Len);
                       Result [Len] := CHR ($80 OR ((U SHR 6) AND $3F));
                       INC (Len);
                       Result [Len] := CHR ($80 OR (U AND $3F));
                     END;
      END;
    END;
  SetLength (Result, Len);
END;
}

//=============================================================================
{}
// These Constants are Session Responses from create session which is called by
// the login function.
const cnSession_MeansErrorOccurred         = 0;
const cnSession_Success                    = 1;
const cnSession_UserNotEnabled             = 2;
const cnSession_NumAllowedSessionExceeded  = 3;
const cnSession_InvalidCredentials         = 4;
const cnSession_PasswordsDoNotMatch        = 5;
const cnSession_PasswordsIdenticalNoChange = 6;
const cnSession_PasswordChangeSuccess      = 7;
const cnSession_LockedOut                  = 8;
const cnSession_InsecurePassword           = 9;
//=============================================================================

//=============================================================================
{}
// These Constants are human language identifiers
const cnLang_English = 1;
const cnLang_Spanish = 2;
//=============================================================================


//=============================================================================
{}
//=============================================================================
// This is to be use
// this could be any UID (primary key value) but Zero
                       // is a typical default value so what not make it the guest
                       // and then have a way to control permissions  for
                       // anonymous the same way we do for users :)
//=============================================================================
const cnJUserID_Admin=1;
const cnJUserID_Guest=2;
//=============================================================================

//=============================================================================
{}
// Default file extension for JAS content files. Causes MIME type to be
// execute/jegas which causes the JAS application to be invoked. Other
// file types are served like a traditional web server.
const csJASFileExt = '.jas';
//=============================================================================


//=======================================================================
// These Constants are Registration Responses from Register call
const cnRegister_MeansErrorOccurred	  = 0; //internal use for fall thru, still zero = Error
const cnRegister_Success			        = 1;
const cnRegister_InvalidEmail 		    = 2;
const cnRegister_EmailExists 		      = 3;
const cnRegister_InvalidPassword 	    = 4;
const cnRegister_PasswordsDoNotMatch  = 5;
const cnRegister_InvalidFirstname		  = 6;
const cnRegister_InvalidLastname		  = 7;
const cnRegister_NameExists		        = 8;
const cnRegister_InvalidCellPhone	    = 9;
const cnRegister_CellPhoneExists		  = 10;
const cnRegister_InvalidBirthday		  = 11;
const cnRegister_InvalidUsername	    = 12;
//=============================================

//=============================================================================
{}
// Found in the jtabletype lookup table, these are pretty self explanatory
// with the note that this value needs to match the UID value
// (Unique Identifier Value that is)
const cnTableType_Table = 1;
{}
// Found in the jtabletype lookup table, these are pretty self explanatory
// with the note that this value needs to match the UID value
// (Unique Identifier Value that is)
const cnTableType_View = 2;
//=============================================================================


//=============================================================================


//=============================================================================
{}
// These are constants that represent the types of bloks (they map to
// jbloktype table's uid values
const cnJBlokType_Filter=1;
const cnJBlokType_Grid  =2;
const cnJBlokType_Data  =3;
const cnJBlokType_Custom=4;
//=============================================================================

//=============================================================================
{}
// These are constants that represent the types of screens (they map to
// jscreentype table's uid values
const cnJScreenType_FilterGrid=1;
const cnJScreenType_Data=2;
const cnJScreenType_Custom=3;
//=============================================================================


//=============================================================================
{}
// jblokfield.JBlkF_ClickAction_ID constants - default - nothing - just display data
const cnJBlkF_ClickAction_None = 0;

// jblokfield.JBlkF_ClickAction_ID constants - pop open a detail screen for current record
const cnJBlkF_ClickAction_DetailScreen = 1;

// Custom - same as <a href="????">Column Data</a> where ???? = your click action data field value
const cnJBlkF_ClickAction_Link = 2;

// CustomNewWindow - same as <a href="????" target="_blank">Column Data</a> where ???? = your click action data field value
const cnJBlkF_ClickAction_LinkNewWindow = 3;

// Custom ClickAction Data = COMPLETELY CUSTOM - With SNR of fields - RISKY!
// In this one you literally must render your entire grid column (html?) yourself entirely!
const cnJBlkF_ClickAction_Custom = 4;

//=============================================================================

//=============================================================================
{}
// Button Types
const cnJBlokButtonType_ResetForm    = 1;
const cnJBlokButtonType_ReloadPage   = 2;
const cnJBlokButtonType_Find         = 3;
const cnJBlokButtonType_New          = 4;
const cnJBlokButtonType_Save         = 5;
const cnJBlokButtonType_Delete       = 6;
const cnJBlokButtonType_Cancel       = 7;//abort too
const cnJBlokButtonType_Edit         = 8;
const cnJBlokButtonType_Custom       = 9;
const cnJBlokButtonType_Close        = 10;
const cnJBlokButtonType_SaveNClose   = 11;
const cnJBlokButtonType_CancelNClose = 12;
const cnJBlokButtonType_SaveNNew     = 13;
//--
const csJBlokButtonType_ResetForm    = '1';
const csJBlokButtonType_ReloadPage   = '2';
const csJBlokButtonType_Find         = '3';
const csJBlokButtonType_New          = '4';
const csJBlokButtonType_Save         = '5';
const csJBlokButtonType_Delete       = '6';
const csJBlokButtonType_Cancel       = '7';//abort too
const csJBlokButtonType_Edit         = '8';
const csJBlokButtonType_Custom       = '9';
const csJBlokButtonType_Close        = '10';
const csJBlokButtonType_SaveNClose   = '11';
const csJBlokButtonType_CancelNClose = '12';
const csJBlokButtonType_SaveNNew     = '13';
//=============================================================================


//=============================================================================
{}
// Constants for Detail Mode
const cnJBlokMode_View = 1;
const cnJBlokMode_New = 2;
const cnJBlokMode_Delete = 3;
const cnJBlokMode_Save = 4;
const cnJBlokMode_Edit = 5;
const cnJBlokMode_Deleted = 6;// Past Tense - Give user a screen letting them know.
const cnJBlokMode_Cancel = 7;
const cnJBlokMode_SaveNClose=8;
const cnJBlokMode_CancelNClose=9;
const cnJBlokMode_Merge=10;
const cnJBlokMode_SaveNNew=11;
//=============================================================================




//=============================================================================
{}
// Stock Priorities
const cnJPriority_Emergency = 1;
const cnJPriority_Highest   = 2;
const cnJPriority_High      = 3;
const cnJPriority_Normal    = 4;
const cnJPriority_Low       = 5;
//=============================================================================

//=============================================================================
{}
// IP List Types
const cnJIPListLU_WhiteList = 1;
const cnJIPListLU_BlackList = 2;
const cnJIPListLU_InvalidLogin = 3;
const cnJIPListLU_Downloader = 4;

const csJIPListLU_WhiteList = '1';
const csJIPListLU_BlackList = '2';
const csJIPListLU_InvalidLogin = '3';
const csJIPListLU_Downloader='4';
//=============================================================================





//=============================================================================
{}
// JobQ Job Types
const cnJJobType_General = 1;
//=============================================================================



//=============================================================================
{}
// Default jvhost record ID for MAIN JAS Instance Configuration
const cnDefault_JVHost_ID = 2012100904220966328;
//=============================================================================

//=============================================================================
{}
// Placeholder Value in juser table vhost column, for when a CRM JAS JET is
// being built.
const cnJUser_JVHost_Processing = 00001010101010101010;
//=============================================================================






//=============================================================================
{}
// STOCK Security Groups
const cnJSecGrp_Administrators       = 2012050101074327302;
const cnJSecGrp_Officiers            = 2012050101195606231;
const cnJSecGrp_AccountingManagers   = 2012050101211743006;
const cnJSecGrp_Accounting           = 2012050101212756319;
const cnJSecGrp_PurchasingManagers   = 2012050101230137251;
const cnJSecGrp_Purchasing           = 2012050101230956099;
const cnJSecGrp_AdvertisingManagers  = 2012050101232352113;
const cnJSecGrp_Advertising          = 2012050101233114253;
const cnJSecGrp_WarehousingManagers  = 2012050101240958288;
const cnJSecGrp_Warehousing          = 2012050101241850336;
const cnJSecGrp_SalesManagers        = 2012050101243932330;
const cnJSecGrp_Sales                = 2012050101244800362;
const cnJSecGrp_LogisticManagers     = 2012050101252655689;
const cnJSecGrp_Logistics            = 2012050101253486343;
const cnJSecGrp_MaintenanceManagers  = 2012050101260994002;
const cnJSecGrp_Maintenance          = 2012050101263089437;
const cnJSecGrp_ProjectManagers      = 2012050101300920215;
const cnJSecGrp_Projects             = 2012050101302529234;
const cnJSecGrp_CaseManagers         = 2012050101303370240;
const cnJSecGrp_Cases                = 2012050101305244561;
const cnJSecGrp_Standard             = 2012050302591185660;
//=============================================================================





//=============================================================================
{}
// Table Types
const cnJTableType_Table=1;
const cnJTableType_View=2;
//=============================================================================


//=============================================================================
{}
// Stock Task Categories
const cnJTaskCategory_Task = 1;
const cnJTaskCategory_Meeting = 2;
const cnJTaskCategory_Call = 3;
//=============================================================================


//=============================================================================
{}
// Stock Task Status
const cnJStatus_NotStarted   =1;
const cnJStatus_InProgress   =2;
const cnJStatus_Completed    =3;
const cnJStatus_PendingInput =4;
const cnJStatus_Deferred     =5;
const cnJStatus_Planned      =6;
const cnJStatus_Cancelled    =7;
const cnJStatus_Rescheduled  =8;
//=============================================================================


//=============================================================================
{}
// User Preferences (juserpref table)
const cnJUserPref_Available=1;
const cnJUserPref_GridRowsPerPage=2;
//=============================================================================



//=============================================================================
{}
// JAS User Interface Settings that eventually should be moved to a per user
// type of thing.
Const cnGrid_RowsPerPage = 20;
//=============================================================================




{
// ----------- JAS TABLE UIDs --------------------
const cs_jblok               = 3                  ;
const cs_jblokbutton         = 4                  ;
const cs_jblokfield          = 5                  ;
const cs_jbloktype           = 6                  ;
const cs_jcaption            = 8                  ;
const cs_jlanguage           = 190                ;
const cs_jcase               = 10                 ;
const cs_jcasecategory       = 11                 ;
const cs_jcasepriority       = 12                 ;
const cs_jcasesource         = 13                 ;
const cs_jcasesubject        = 15                 ;
const cs_jcasetype           = 16                 ;
const cs_jadodbms            = 136                ;
const cs_jcolumn             = 19                 ;
const cs_jorg                = 23                 ;
const cs_jorgpers            = 25                 ;
const cs_jdconnection        = 28                 ;
const cs_jdtype              = 29                 ;
const cs_jindustry           = 31                 ;
const cs_jinstalled          = 32                 ;
const cs_jinterface          = 33                 ;
const cs_jinvoice            = 34                 ;
const cs_jinvoicelines       = 35                 ;
const cs_jlead               = 36                 ;
const cs_jleadsource         = 37                 ;
const cs_jlock               = 38                 ;
const cs_jmenu               = 39                 ;
const cs_jmodc               = 40                 ;
const cs_jmodule             = 41                 ;
const cs_jnote               = 42                 ;
const cs_jsession            = 43                 ;
const cs_jperson             = 44                 ;
const cs_jprinter            = 45                 ;
const cs_jproduct            = 46                 ;
const cs_jproductgrp         = 47                 ;
const cs_jproductqty         = 48                 ;
const cs_jsessiontype        = 49                 ;
const cs_jscreen             = 51                 ;
const cs_jscreentype         = 53                 ;
const cs_jsecgrp             = 54                 ;
const cs_jsecgrplink         = 55                 ;
const cs_jsecgrpuserlink     = 56                 ;
const cs_jsecperm            = 57                 ;
const cs_jsecpermuserlink    = 58                 ;
const cs_jsysmodule          = 59                 ;
const cs_jsysmodulelink      = 60                 ;
const cs_jtable              = 61                 ;
const cs_jtabletype          = 62                 ;
const cs_jteam               = 63                 ;
const cs_jteammember         = 64                 ;
const cs_jtrak               = 66                 ;
const cs_juser               = 68                 ;
const cs_juserpref           = 69                 ;
const cs_juserpreflink       = 70                 ;
const cs_jwidget             = 72                 ;
const cs_jfiltersave         = 2012040316073121951;
const cs_jsessiondata        = 75                 ;
const cs_jlog                = 76                 ;
const cs_jjobq               = 77                 ;
const cs_jtimecard           = 120                ;
const cs_jstatus             = 114                ;
const cs_jpriority           = 2012042817255160951;               ;
const cs_jtaskcategory       = 111                ;
const cs_jprojectpriority    = 110                ;
const cs_jprojectcategory    = 108                ;
const cs_jproject            = 107                ;
const cs_jtask               = 121                ;
const cs_jmoduleconfig       = 123                ;
const cs_jmodulesetting      = 124                ;
const cs_jjobtype            = 125                ;
const cs_jdebug              = 127                ;
const cs_jadodriver          = 137                ;
const cs_jiconcontext        = 156                ;
const cs_jiconmaster         = 157                ;
const cs_jseckey             = 159                ;
const cs_jasident            = 160                ;
const cs_jbuttontype         = 167                ;
const cs_jquicklink          = 171                ;
const cs_jtheme              = 172                ;
const cs_jquicknote          = 173                ;
const cs_jclickaction        = 174                ;
const cs_jlogtype            = 175                ;
const cs_jprojectstatus      = 179                ;
const cs_jskill              = 182                ;
const cs_jpersonskill        = 184                ;
const cs_jmail               = 186                ;
const cs_jtestone            = 189                ;
const cs_jpassword           = 193                ;
const cs_jfiltersavedef      = 2012040623132886330;
const cs_jlookup             = 2012041419425450119;
const cs_jpriority           = 2012042817255160951;
const cs_jfile               = 2012042909243674213;
const cs_jsync               = 2012053009342801999;
// ----------- JAS TABLE UIDs --------------------


// ------------ CUSTOM TABLE UIDs ----------------
const cs_vrevent             = 2012081905595204953;
const cs_vrvideo             = 2012090314265724440;
// ------------ CUSTOM TABLE UIDs ----------------
}











// --- JAS SCREEN UIDs ----------------------------------------------
const cs_jblok_Search                          = 5                  ;  // JBloks    Filter + Grid           Yes
const cs_jadodbms_Data                         = 224                ;  // Database    Data
const cs_jadodbms_Search                       = 223                ;  // Databases     Filter + Grid
const cs_jadodriver_Data                       = 226                ;  // Database Driver     Data
const cs_jadodriver_Search                     = 225                ;  // Database Drivers    Filter + Grid
const cs_jblok_Data                            = 6                  ;  // JBlok     Data
const cs_jblokbutton_Data                      = 8                  ;  // JBlok Button    Data
const cs_jblokbutton_Search                    = 7                  ;  // JBlok Buttons     Filter + Grid
const cs_jblokfield_Data                       = 10                 ;  // JBlok Field     Data
const cs_jblokfield_Search                     = 9                  ;  // JBlok Fields    Filter + Grid
const cs_jbloktype_Data                        = 12                 ;  // JBlok Type    Data
const cs_jbloktype_Search                      = 11                 ;  // JBlok Types     Filter + Grid
const cs_jbuttontype_Data                      = 295                ;  // Button Type     Data
const cs_jbuttontype_Search                    = 294                ;  // Button Types    Filter + Grid
const cs_jcaptgrp_Data                         = 14                 ;  // Caption Group     Data
const cs_jcaptgrp_Search                       = 13                 ;  // Caption Groups    Filter + Grid
const cs_jcaption_Data                         = 16                 ;  // Caption     Data
const cs_jcaption_Search                       = 15                 ;  // Captions    Filter + Grid
const cs_jcapttype_Data                        = 394                ;  // Caption Type    Data
const cs_jcapttype_Search                      = 393                ;  // Caption Types     Filter + Grid
const cs_jcase_Data                            = 134                ;  // Case    Data
const cs_jcase_Search                          = 133                ;  // Cases     Filter + Grid
const cs_jcasecategory_Data                    = 136                ;  // Case Category     Data
const cs_jcasecategory_Search                  = 135                ;  // Case Categories     Filter + Grid
const cs_jcasepriority_Data                    = 138                ;  // Case Priority     Data
const cs_jcasepriority_Search                  = 137                ;  // Case Priorities     Filter + Grid
const cs_jcasesource_Data                      = 140                ;  // Case Source     Data
const cs_jcasesource_Search                    = 139                ;  // Case Sources    Filter + Grid
const cs_jcasestatus_Data                      = 142                ;  // Case Status     Data
const cs_jcasestatus_Search                    = 141                ;  // Case Statuses     Filter + Grid
const cs_jcasesubject_Data                     = 144                ;  // Subject     Data
const cs_jcasesubject_Search                   = 143                ;  // Case Subjects     Filter + Grid
const cs_jcasetype_Data                        = 146                ;  // Case Type     Data
const cs_jcasetype_Search                      = 145                ;  // Case Types    Filter + Grid
const cs_jclickaction_Data                     = 321                ;  // Click Action    Data
const cs_jclickaction_Search                   = 320                ;  // Click Actions     Filter + Grid
const cs_jcolumn_Data                          = 152                ;  // Column    Data
const cs_jcolumn_Search                        = 151                ;  // Columns     Filter + Grid
const cs_jorg_Data                             = 218                ;  // Organization     Data
const cs_jorg_Search                           = 217                ;  // Organizations     Filter + Grid
const cs_jorgpers_Data                         = 164                ;  // Organization Person    Data
const cs_jorgpers_Search                       = 163                ;  // Organization People    Filter + Grid
const cs_jdconnection_Data                     = 369                ;  // Data Source Connection    Data
const cs_jdconnection_Search                   = 368                ;  // Data Source Connections     Filter + Grid
const cs_jdebug_Data                           = 172                ;  // Debug Entry     Data
const cs_jdebug_Search                         = 171                ;  // Debug Entries     Filter + Grid
const cs_jdtype_Data                           = 174                ;  // Datatype    Data
const cs_jdtype_Search                         = 173                ;  // Datatypes     Filter + Grid
const cs_jfile_Data                            = 2012042910012189283;  // File    Data
const cs_jfile_Search                          = 2012042910012187624;  // Files     Filter + Grid
const cs_jfiltersave_Data                      = 2012040317480569415;  // Saved Filter    Data
const cs_jfiltersave_Search                    = 2012040317480568538;  // Saved Filters     Filter + Grid
const cs_jfiltersavedef_Data                   = 2012040623330405633;  // Filter Default    Data
const cs_jfiltersavedef_Search                 = 2012040623330403052;  // Filter Defaults     Filter + Grid
const cs_jiconcontext_Data                     = 258                ;  // Theme Icon Category     Data
const cs_jiconcontext_Search                   = 257                ;  // Theme Icon Categories     Filter + Grid
const cs_jiconmaster_Data                      = 260                ;  // Theme Icon Type     Data
const cs_jiconmaster_Search                    = 259                ;  // Theme Icon Types    Filter + Grid
const cs_jindustry_Data                        = 180                ;  // Industry    Data
const cs_jindustry_Search                      = 179                ;  // Industries    Filter + Grid
const cs_jinstalled_Data                       = 182                ;  // Module Installation     Data
const cs_jinstalled_Search                     = 181                ;  // Module Installations    Filter + Grid
const cs_jinterface_Data                       = 184                ;  // System Interface    Data
const cs_jinterface_Search                     = 183                ;  // System Interfaces     Filter + Grid
const cs_jinvoice_Data                         = 186                ;  // Invoice     Data
const cs_jinvoice_Search                       = 185                ;  // Invoices    Filter + Grid
const cs_jinvoicelines_Data                    = 188                ;  // Invoice Line    Data
const cs_jinvoicelines_Search                  = 187                ;  // Invoice Lines     Filter + Grid
const cs_jjobq_Data                            = 190                ;  // Job Queue Item    Data
const cs_jjobq_Search                          = 189                ;  // Job Queue Items     Filter + Grid
const cs_jjobtype_Data                         = 192                ;  // Job Type    Data
const cs_jjobtype_Search                       = 191                ;  // Job Types     Filter + Grid
const cs_jlanguage_Data                        = 392                ;  // Language    Data
const cs_jlanguage_Search                      = 391                ;  // Languages     Filter + Grid
const cs_jlead_Data                            = 194                ;  // Lead    Data
const cs_jlead_Search                          = 193                ;  // Leads     Filter + Grid
const cs_jleadsource_Data                      = 196                ;  // Lead Source     Data
const cs_jleadsource_Search                    = 195                ;  // Lead Sources    Filter + Grid
const cs_jlock_Data                            = 390                ;  // Lock    Data
const cs_jlock_Search                          = 389                ;  // Locks     Filter + Grid
const cs_jlog_Data                             = 360                ;  // Log Entry     Data
const cs_jlog_Search                           = 359                ;  // Log Entries     Filter + Grid
const cs_jlogtype_Data                         = 319                ;  // Log Entry Type    Data
const cs_jlogtype_Search                       = 318                ;  // Log Entry Types     Filter + Grid
const cs_jlookup_Data                          = 2012041419563999980;  // Lookup Record     Data
const cs_jlookup_Search                        = 2012041419563991193;  // Lookup Records    Filter + Grid
const cs_jmail_Data                            = 354                ;  // Mail Item     Data
const cs_jmail_Search                          = 353                ;  // Mail Items    Filter + Grid
const cs_jmenu_Data                            = 202                ;  // Menu Item     Data
const cs_jmenu_Search                          = 201                ;  // Menu Items    Filter + Grid
const cs_jmodc_Data                            = 18                 ;  // Module Column     Data
const cs_jmodc_Search                          = 17                 ;  // Module Columns    Filter + Grid
const cs_jmodule_Data                          = 366                ;  // Module    Data
const cs_jmodule_Search                        = 365                ;  // Modules     Filter + Grid
const cs_jmoduleconfig_Data                    = 22                 ;  // Module Configuration    Data
const cs_jmoduleconfig_Search                  = 21                 ;  // Module Configurations     Filter + Grid
const cs_jmodulesetting_Data                   = 24                 ;  // Module Setting    Data
const cs_jmodulesetting_Search                 = 23                 ;  // Module Settings     Filter + Grid
const cs_jnote_Data                           = 26                 ;  // Note    Dats
const cs_jnote_Search                         = 25                 ;  // JNote    Filter + Grid
const cs_jpassword_Data                        = 398                ;  // Password    Data
const cs_jpassword_Search                      = 397                ;  // Passwords     Filter + Grid
const cs_jperson_Data                          = 30                 ;  // Person    Data
const cs_jperson_Search                        = 29                 ;  // People    Filter + Grid
const cs_jpersonskill_Data                     = 352                ;  // Person's Skill    Data
const cs_jpersonskill_Search                   = 351                ;  // People's Skills     Filter + Grid
const cs_jprinter_Data                         = 32                 ;  // Printer     Data
const cs_jprinter_Search                       = 31                 ;  // Printers    Filter + Grid
const cs_jpriority_Data                        = 2012042817344536307;  // Priority    Data
const cs_jpriority_Search                      = 2012042817344534295;  // Priorities    Filter + Grid
const cs_jproduct_Data                         = 34                 ;  // Product     Data
const cs_jproduct_Search                       = 33                 ;  // Products    Filter + Grid
const cs_jproductgrp_Data                      = 36                 ;  // Product Group     Data
const cs_jproductgrp_Search                    = 35                 ;  // Product Groups    Filter + Grid
const cs_jproductqty_Data                      = 299                ;  // Product Quantity    Data
const cs_jproductqty_Search                    = 298                ;  // Product Quantities    Filter + Grid
const cs_jproject_Data                         = 40                 ;  // Project     Data
const cs_jproject_Search                       = 39                 ;  // Projects    Filter + Grid
const cs_jprojectcategory_Data                 = 42                 ;  // Project Category    Data
const cs_jprojectcategory_Search               = 41                 ;  // Project Categories    Filter + Grid
const cs_jprojectstatus_Data                   = 333                ;  // Project Status    Data
const cs_jprojectstatus_Search                 = 332                ;  // Project Statuses    Filter + Grid
const cs_jquicklink_Data                       = 308                ;  // Quick Link    Data
const cs_jquicklink_Search                     = 307                ;  // Quick Links     Filter + Grid
const cs_jquicknote_Data                       = 313                ;  // Quick Note    Data
const cs_jquicknote_Search                     = 312                ;  // Quick Notes     Filter + Grid
const cs_jscreen_Data                          = 58                 ;  // Screen    Data
const cs_jscreen_Search                        = 57                 ;  // Search Screens    Filter + Grid
const cs_jscreentype_Data                      = 62                 ;  // Screen Type     Data
const cs_jscreentype_Search                    = 61                 ;  // Screen Types    Filter + Grid
const cs_jsecgrp_Data                          = 64                 ;  // Security Group    Data
const cs_jsecgrp_Search                        = 63                 ;  // Security Groups     Filter + Grid
const cs_jsecgrplink_Data                      = 66                 ;  // Security Group Link     Data
const cs_jsecgrplink_Search                    = 65                 ;  // Security Group Links    Filter + Grid
const cs_jsecgrpuserlink_Data                  = 68                 ;  // Security Group User Link    Data
const cs_jsecgrpuserlink_Search                = 67                 ;  // Security Group User Links     Filter + Grid
const cs_jseckey_Data                          = 2012040619282957973;  // Security Key    Data
const cs_jseckey_Search                        = 2012040619282957127;  // Security Keys     Filter + Grid
const cs_jsecperm_Data                         = 70                 ;  // System Permission     Data
const cs_jsecperm_Search                       = 69                 ;  // System Permissions    Filter + Grid
const cs_jsecpermuserlink_Data                 = 72                 ;  // Security Permission User Link     Data
const cs_jsecpermuserlink_Search               = 71                 ;  // Security Permission User Links    Filter + Grid
const cs_jsession_Data                         = 28                 ;  // User Connection     Data
const cs_jsession_Search                       = 27                 ;  // Sessions    Filter + Grid
const cs_jsessiondata_Data                     = 74                 ;  // Session Data Record     Data
const cs_jsessiondata_Search                   = 73                 ;  // Session     Filter + Grid
const cs_jsessiontype_Data                     = 48                 ;  // Session Type    Data
const cs_jsessiontype_Search                   = 47                 ;  // Session Types     Filter + Grid
const cs_jskill_Data                           = 350                ;  // Skill     Data
const cs_jskill_Search                         = 349                ;  // Skills    Filter + Grid
const cs_jsync_Data                            = 2012053010035089714;  // NULL    Data
const cs_jsync_Search                          = 2012053010035084922;  // NULL    Filter + Grid
const cs_jsysmodule_Data                       = 78                 ;  // System Module     Data
const cs_jsysmodule_Search                     = 77                 ;  // System Modules    Filter + Grid
const cs_jsysmodulelink_Data                   = 80                 ;  // System Module Link    Data
const cs_jsysmodulelink_Search                 = 79                 ;  // System Module Links     Filter + Grid
const cs_jtable_Data                           = 82                 ;  // Table     Data
const cs_jtable_Search                         = 81                 ;  // Tables    Filter + Grid
const cs_jtabletype_Data                       = 84                 ;  // Table Type    Data
const cs_jtabletype_Search                     = 83                 ;  // Table Types     Filter + Grid
const cs_jtask_Data                            = 86                 ;  // Task    Data
const cs_jtask_Search                          = 85                 ;  // Tasks     Filter + Grid
const cs_jtaskcategory_Data                    = 88                 ;  // Task Category     Data
const cs_jtaskcategory_Search                  = 87                 ;  // Task Categories     Filter + Grid
const cs_jtaskstatus_Data                      = 94                 ;  // Task Status     Data
const cs_jtaskstatus_Search                    = 93                 ;  // Task Statuses     Filter + Grid
const cs_jteam_Data                            = 108                ;  // Team    Data
const cs_jteam_Search                          = 107                ;  // Teams     Filter + Grid
const cs_jteammember_Data                      = 110                ;  // Team Member     Data
const cs_jteammember_Search                    = 109                ;  // Team Members    Filter + Grid
const cs_jtheme_Data                           = 310                ;  // Theme     Data
const cs_jtheme_Search                         = 309                ;  // Themes    Filter + Grid
const cs_jtimecard_Data                        = 106                ;  // Time Card Entry     Data
const cs_jtimecard_Search                      = 105                ;  // Timecard Entries    Filter + Grid
const cs_jtrak_Data                            = 396                ;  // JTrak Audit Record    Data
const cs_jtrak_Search                          = 395                ;  // JTrak Audit Trail     Filter + Grid
const cs_juser_Data                            = 118                ;  // User    Data
const cs_juser_Search                          = 117                ;  // Users     Filter + Grid
const cs_juserpref_Data                        = 120                ;  // User Preference     Data
const cs_juserpref_Search                      = 119                ;  // User Preferences    Filter + Grid
const cs_juserpreflink_Data                    = 122                ;  // User Preference Link    Data
const cs_juserpreflink_Search                  = 121                ;  // User Preference Links     Filter + Grid
const cs_jwidget_Data                          = 126                ;  // Widget    Data
const cs_jwidget_Search                        = 125                ;  // Widgets     Filter + Grid
// --- JAS SCREEN UIDs ----------------------------------------------












//=============================================================================
{}
// audit record - these fields are used for record auditing in each table...
// well the value fields are... the FieldName fields are dynamically created
// by concatenating the table's column prefix and the tail end of the field
// names... Example: jtask table has JTask as column prefix... so
// JTask_CreatedBy_JUser_ID is the resultant field name for the CreatedBy field
// for that particular table. See JADO.saGetColumnPrefix
type rtAudit=record
  u8UID                                   : uInt64;
  saFieldName_CreatedBy_JUser_ID          : ansistring;
  saFieldName_Created_DT                  : string[19];
  saFieldName_ModifiedBy_JUser_ID         : ansistring;
  saFieldName_Modified_DT                 : string[19];
  saFieldName_DeletedBy_JUser_ID          : ansistring;
  saFieldName_Deleted_DT                  : string[19];
  saFieldName_Deleted_b                   : ansistring;
  bUse_CreatedBy_JUser_ID                 : boolean;
  bUse_Created_DT                         : boolean;
  bUse_ModifiedBy_JUser_ID                : boolean;
  bUse_Modified_DT                        : boolean;
  bUse_DeletedBy_JUser_ID                 : boolean;
  bUse_Deleted_DT                         : boolean;
  bUse_Deleted_b                          : boolean;
end;
procedure clear_audit(var p_raudit: rtAudit; p_saColumnPrefix: ansistring);
//=============================================================================



//=============================================================================
{}
// JAS Single - This structure is used for standalone JAS Applications run
// as CGI applications. Note this is a way to leverage the JAS Database,
// JegasAPI, JAS API, Security, Configured Database connections etc.
// Now JAS Single applications do NOT handle things that the JAS Application
// exclusively manages - however it does allow testing and development
// of code without compiling the code directly into the JAS server which
// makes it stellar for testing, and making scheduled tasks for the JAS JobQ
// subsystem.
//
// NOTE: This structure is passed by reference - and the i8CgiResult variable
//       gets modified in the InitSingle function. For this particular
//       variable - ZERO means success - so the reason for passing it back
//       is to allow acting upon error codes in a reasonable manner.
//
// How you use this record structure is basically populate all the values with
// the defaults you'd like and then you call the Single_Init function in the
// uxxj_single unit. Note - the jegas_application.pas file is not the same
// as the jegas_application_server file. The jegas_application.pas file is the
// prototype for building JAS SINGLE applications.
//
// Integration JAS SINGLE applications into JAS takes a little work because
// you need to choose WHAT kind of "program it is" (xml api or a standard
// Jegas Application) - and make it so your "single" app runs under the correct
// circumstances.
type rtJASSingle = record
  saServerSoftware            :ansistring;  // 'JAS CGI Application';
  iTimeZoneOffset             :longint;  // -5; //EST
  i8CgiResult                 :int64;       // SET TO ZERO (This value
end;
procedure clear_JASSingle(var p_rJASSingle: rtJASSingle);
//=============================================================================











//=============================================================================
// Database Tables
//=============================================================================

//=============================================================================
{}
Type rtJADODBMS=record
  JADB_JADODBMS_UID        : UInt64;
  JADB_Name                : ansistring;
  JADB_CreatedBy_JUser_ID  : UInt64;
  JADB_Created_DT          : string[19];
  JADB_ModifiedBy_JUser_ID : UInt64;
  JADB_Modified_DT         : string[19];
  JADB_DeletedBy_JUser_ID  : UInt64;
  JADB_Deleted_DT          : string[19];
  JADB_Deleted_b           : Boolean;
  JAS_Row_b                : Boolean;
end;
procedure clear_JADODBMS(var p_rJADODBMS: rtJADODBMS);
//=============================================================================


//=============================================================================
{}
Type rtJADODriver=record
  JADV_JADODriver_UID      : UInt64;
  JADV_Name                : string[32];
  JADV_CreatedBy_JUser_ID  : UInt64;
  JADV_Created_DT          : string[19];
  JADV_ModifiedBy_JUser_ID : UInt64;
  JADV_Modified_DT         : string[19];
  JADV_DeletedBy_JUser_ID  : UInt64;
  JADV_Deleted_DT          : string[19];
  JADV_Deleted_b           : Boolean;
  JAS_Row_b                : Boolean;
end;
procedure clear_JADODriver(var p_rJADODriver: rtJADODriver);
//=============================================================================




//=============================================================================
{}
type rtJAlias = Record
  Alias_JAlias_UID            : UInt64;
  Alias_JVHost_ID             : UInt64;
  Alias_Alias                 : ansistring;
  Alias_Path                  : ansistring;
  Alias_VHost_b               : boolean;
  Alias_CreatedBy_JUser_ID    : UInt64;
  Alias_Created_DT            : string[19];
  Alias_ModifiedBy_JUser_ID   : UInt64;
  Alias_Modified_DT           : string[19];
  Alias_DeletedBy_JUser_ID    : UInt64;
  Alias_Deleted_DT            : string[19];
  Alias_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JAlias(var p_rJAlias: rtJAlias);
//=============================================================================

//=============================================================================
{}
type rtJAliasLight = Record
  u8JAlias_UID            : UInt64;
  u8JVHost_ID             : UInt64;
  saAlias                 : ansistring;
  saPath                  : ansistring;
  bVHost                  : boolean;
end;
procedure clear_JAliasLight(var p_rJAliasLight: rtJAliasLight);
//=============================================================================



//=============================================================================
{}
Type rtJBlok=Record
  JBlok_JBlok_UID                   : Uint64;
  JBlok_JScreen_ID                  : Uint64;
  JBlok_JTable_ID                   : UInt64;
  JBlok_Name                        : string[32];
  JBlok_Columns_u                   : word;
  JBlok_JBlokType_ID                : Uint64;
  JBlok_Custom                      : AnsiString;
  JBlok_JCaption_ID                 : Uint64;
  JBlok_IconSmall                   : AnsiString;
  JBlok_IconLarge                   : AnsiString;
  JBlok_Position_u                  : byte;
  JBlok_Help_ID                     : Uint64;
  JBlok_CreatedBy_JUser_ID          : Uint64;
  JBlok_Created_DT                  : string[19];
  JBlok_ModifiedBy_JUser_ID         : UInt64;
  JBlok_Modified_DT                 : string[19];
  JBlok_DeletedBy_JUser_ID          : UInt64;
  JBlok_Deleted_DT                  : string[19];
  JBlok_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
End;
procedure clear_JBlok(var p_rJBlok: rtJBlok);
//=============================================================================


//=============================================================================
{}
Type rtJBlokButton=Record
  JBlkB_JBlokButton_UID             : UInt64;
  JBlkB_JBlok_ID                    : UInt64;
  JBlkB_JCaption_ID                 : UInt64;
  JBlkB_Name                        : string[32];
  JBlkB_GraphicFileName             : AnsiString;
  JBlkB_Position_u                  : byte;
  JBlkB_JButtonType_ID              : Uint64;
  JBlkB_CustomURL                   : ansistring;
  JBlkB_CreatedBy_JUser_ID          : Uint64;
  JBlkB_Created_DT                  : string[19];
  JBlkB_ModifiedBy_JUser_ID         : Uint64;
  JBlkB_Modified_DT                 : string[19];
  JBlkB_DeletedBy_JUser_ID          : Uint64;
  JBlkB_Deleted_DT                  : string[19];
  JBlkB_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
End;
procedure clear_JBlokButton(var p_rJBlokButton: rtJBlokButton);
//=============================================================================

//=============================================================================
{}
type rtJButtonType=record
  JBtnT_JButtonType_UID       : Uint64;
  JBtnT_Name                  : string[32];
  JBtnT_CreatedBy_JUser_ID    : Uint64;
  JBtnT_Created_DT            : string[19];
  JBtnT_ModifiedBy_JUser_ID   : Uint64;
  JBtnT_Modified_DT           : string[19];
  JBtnT_DeletedBy_JUser_ID    : Uint64;
  JBtnT_Deleted_DT            : string[19];
  JBtnT_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
End;
procedure clear_JButtonType(var p_rJButtonType: rtJButtonType);



//=============================================================================
{}
Type rtJBlokField=Record
  JBlkF_JBlokField_UID              : Uint64;
  JBlkF_JBlok_ID                    : Uint64;
  JBlkF_JColumn_ID                  : Uint64;
  JBlkF_Position_u                  : word;
  JBlkF_ReadOnly_b                  : boolean;
  JBlkF_JWidget_ID                  : Uint64;
  JBlkF_Widget_MaxLength_u          : Uint64;
  JBlkF_Widget_Width                : word;
  JBlkF_Widget_Height               : word;
  JBlkF_Widget_Password_b           : boolean;
  JBlkF_Widget_Date_b               : boolean;
  JBlkF_Widget_Time_b               : boolean;
  JBlkF_Widget_Mask                 : string;
  JBlkF_Widget_OnBlur               : ansistring;
  JBlkF_Widget_OnChange             : ansistring;
  JBlkF_Widget_OnClick              : ansistring;
  JBlkF_Widget_OnDblClick           : ansistring;
  JBlkF_Widget_OnFocus              : ansistring;
  JBlkF_Widget_OnKeyDown            : ansistring;
  JBlkF_Widget_OnKeypress           : ansistring;
  JBlkF_Widget_OnKeyUp              : ansistring;
  JBlkF_Widget_OnSelect             : ansistring;
  JBlkF_ColSpan_u                   : byte;
  JBlkF_Width_is_Percent_b          : boolean;
  JBlkF_Height_is_Percent_b         : boolean;
  JBlkF_Required_b                  : boolean;
  JBlkF_MultiSelect_b               : boolean;
  JBlkF_ClickAction_ID              : UInt64;
  JBlkF_ClickActionData             : AnsiString;
  JBlkF_JCaption_ID                 : UInt64;
  JBlkF_Visible_b                   : boolean;
  JBlkF_CreatedBy_JUser_ID          : UInt64;
  JBlkF_Created_DT                  : string[19];
  JBlkF_ModifiedBy_JUser_ID         : Uint64;
  JBlkF_Modified_DT                 : string[19];
  JBlkF_DeletedBy_JUser_ID          : Uint64;

  // This field was getting corrupted as string[19], so I set it to ansistring
  // and it worked. Go Figure.
  JBlkF_Deleted_DT                  : ansistring;//[19];

  JBlkF_Deleted_b                   : Boolean;
  JAS_Row_b                         : Boolean;

end;
procedure clear_JBlokField(var p_rJBlokField: rtJBlokField);
//=============================================================================

//=============================================================================
{}
type rtJBlokType=record
  JBkTy_JBlokType_UID               : Uint64;
  JBkTy_Name                        : string[32];
  JBkTy_CreatedBy_JUser_ID          : Uint64;
  JBkTy_Created_DT                  : string[19];
  JBkTy_ModifiedBy_JUser_ID         : Uint64;
  JBkTy_Modified_DT                 : string[19];
  JBkTy_DeletedBy_JUser_ID          : Uint64;
  JBkTy_Deleted_DT                  : string[19];
  JBkTy_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JBlokType(var p_rJBlokType: rtJBlokType);
//=============================================================================




//=============================================================================
{}
type rtJCaption=record
  JCapt_JCaption_UID          : Uint64;
  JCapt_Orphan_b              : boolean;
  JCapt_Value                 : ansistring;
  JCapt_en                    : ansistring;
  JCapt_CreatedBy_JUser_ID    : Uint64;
  JCapt_Created_DT            : string[19];
  JCapt_ModifiedBy_JUser_ID   : Uint64;
  JCapt_Modified_DT           : string[19];
  JCapt_DeletedBy_JUser_ID    : Uint64;
  JCapt_Deleted_DT            : string[19];
  JCapt_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JCaption(var p_rJCaption: rtJCaption);
//=============================================================================



//=============================================================================
{}
type rtJCase=record
  JCase_JCase_UID                 : Uint64;
  JCase_Name                      : string[64];
  JCase_JOrg_ID                   : Uint64;
  JCase_JPerson_ID                : Uint64;
  JCase_Responsible_Grp_ID        : Uint64;
  JCase_Responsible_Person_ID     : Uint64;
  JCase_JCaseSource_ID            : Uint64;
  JCase_JCaseCategory_ID          : Uint64;
  JCase_JCasePriority_ID          : Uint64;
  JCase_JCaseStatus_ID            : Uint64;
  JCase_JCaseType_ID              : Uint64;
  JCase_JSubject_ID               : Uint64;
  JCase_Desc                      : ansistring;
  JCase_Resolution                : ansistring;
  JCase_Due_DT                    : string[19];
  JCase_ResolvedBy_JUser_ID       : Uint64;
  JCase_Resolved_DT               : string[19];
  JCase_CreatedBy_JUser_ID        : Uint64;
  JCase_Created_DT                : string[19];
  JCase_ModifiedBy_JUser_ID       : Uint64;
  JCase_Modified_DT               : string[19];
  JCase_DeletedBy_JUser_ID        : Uint64;
  JCase_Deleted_DT                : string[19];
  JCase_Deleted_b                 : boolean;
  JAS_Row_b                       : boolean;
end;
procedure clear_JCase(var p_rJCase: rtJCase);
//=============================================================================


//=============================================================================
{}
type rtJCaseCategory=record
  JCACT_JCaseCategory_UID           : Uint64;
  JCACT_Name                        : string[32];
  JCACT_CreatedBy_JUser_ID          : Uint64;
  JCACT_Created_DT                  : string[19];
  JCACT_ModifiedBy_JUser_ID         : Uint64;
  JCACT_Modified_DT                 : string[19];
  JCACT_DeletedBy_JUser_ID          : Uint64;
  JCACT_Deleted_DT                  : string[19];
  JCACT_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JCaseCategory(var p_rJCaseCategory: rtJCaseCategory);
//=============================================================================


//=============================================================================
{}
type rtJCasePriority=record
  JCAPR_JCasePriority_UID           : Uint64;
  JCAPR_Name                        : string[32];
  JCAPR_CreatedBy_JUser_ID          : Uint64;
  JCAPR_Created_DT                  : string[19];
  JCAPR_ModifiedBy_JUser_ID         : Uint64;
  JCAPR_Modified_DT                 : string[19];
  JCAPR_DeletedBy_JUser_ID          : Uint64;
  JCAPR_Deleted_DT                  : string[19];
  JCAPR_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JCasePriority(var p_rJCasePriority: rtJCasePriority);
//=============================================================================

//=============================================================================
{}
type rtJCaseSource=record
  JCASR_JCaseSource_UID     : Uint64;
  JCASR_Name                : string[32];
  JCASR_CreatedBy_JUser_ID  : Uint64;
  JCASR_Created_DT          : string[19];
  JCASR_ModifiedBy_JUser_ID : Uint64;
  JCASR_Modified_DT         : string[19];
  JCASR_DeletedBy_JUser_ID  : Uint64;
  JCASR_Deleted_DT          : string[19];
  JCASR_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JCaseSource(var p_rJCaseSource: rtJCaseSource);
//=============================================================================



//=============================================================================
{}
type rtJCaseSubject=record
  JCASB_JCaseSubject_UID    : Uint64;
  JCASB_Name                : string[32];
  JCASB_CreatedBy_JUser_ID  : Uint64;
  JCASB_Created_DT          : string[19];
  JCASB_ModifiedBy_JUser_ID : Uint64;
  JCASB_Modified_DT         : string[19];
  JCASB_DeletedBy_JUser_ID  : Uint64;
  JCASB_Deleted_DT          : string[19];
  JCASB_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JCaseSubject(var p_rJCaseSubject: rtJCaseSubject);
//=============================================================================

//=============================================================================
{}
type rtJCaseType=record
  JCATY_JCaseType_UID       : Uint64;
  JCATY_Name                : string[32];
  JCATY_CreatedBy_JUser_ID  : Uint64;
  JCATY_Created_DT          : string[19];
  JCATY_ModifiedBy_JUser_ID : Uint64;
  JCATY_Modified_DT         : string[19];
  JCATY_DeletedBy_JUser_ID  : Uint64;
  JCATY_Deleted_DT          : string[19];
  JCATY_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JCaseType(var p_rJCaseType: rtJCaseType);
//=============================================================================



//=============================================================================
{}
Type rtJColumn=Record
  JColu_JColumn_UID             : Uint64;
  JColu_Name                    : string[64];
  JColu_JTable_ID               : Uint64;
  JColu_JDType_ID               : Uint64;
  JColu_AllowNulls_b            : boolean;
  JColu_DefaultValue            : ansistring;
  JColu_PrimaryKey_b            : boolean;
  JColu_JAS_b                   : boolean;
  JColu_JCaption_ID             : Uint64;
  JColu_DefinedSize_u           : Uint64;
  JColu_NumericScale_u          : byte;
  JColu_Precision_u             : byte;
  JColu_Boolean_b               : boolean;
  JColu_JAS_Key_b               : boolean;
  JColu_AutoIncrement_b         : boolean;
  JColu_LUF_Value               : ansistring;
  JColu_LD_CaptionRules_b       : boolean;
  JColu_JDConnection_ID         : Uint64;
  JColu_Desc                    : ansistring;
  JColu_Weight_u                : word;
  JColu_LD_SQL                  : ansistring;
  JColu_LU_JColumn_ID           : Uint64;
  JColu_CreatedBy_JUser_ID      : Uint64;
  JColu_Created_DT              : string[19];
  JColu_ModifiedBy_JUser_ID     : Uint64;
  JColu_Modified_DT             : string[19];
  JColu_DeletedBy_JUser_ID      : Uint64;
  JColu_Deleted_DT              : string[19];
  JColu_Deleted_b               : boolean;
  JAS_Row_b                     : boolean;
End;
procedure clear_JColumn(var p_rJColumn: rtJColumn);
//=============================================================================


//=============================================================================
{}
type rtJOrg=record
  JOrg_JOrg_UID                  : Uint64;
  JOrg_Name                      : string[64];
  JOrg_Desc                      : ansistring;
  JOrg_Primary_Person_ID         : Uint64;
  JOrg_Phone                     : string[32];
  JOrg_Fax                       : string[32];
  JOrg_Email                     : string[64];
  JOrg_Website                   : string[128];
  JOrg_Parent_ID                 : Uint64;
  JOrg_Owner_JUser_ID            : Uint64;
  JOrg_Main_Addr1                : string[64];
  JOrg_Main_Addr2                : string[64];
  JOrg_Main_Addr3                : string[64];
  JOrg_Main_City                 : string[32];
  JOrg_Main_State                : string[32];
  JOrg_Main_PostalCode           : string[16];
  JOrg_Main_Country              : string[32];
  JOrg_Ship_Addr1                : string[64];
  JOrg_Ship_Addr2                : string[64];
  JOrg_Ship_Addr3                : string[64];
  JOrg_Ship_City                 : string[32];
  JOrg_Ship_State                : string[32];
  JOrg_Ship_PostalCode           : string[16];
  JOrg_Ship_Country              : string[32];
  JOrg_Main_Longitude_d          : double;
  JOrg_Main_Latitude_d           : double;
  JOrg_Ship_Longitude_d          : double;
  JOrg_Ship_Latitude_d           : double;
  JOrg_Country                   : string[32];
  JOrg_Customer_b                : boolean;
  JOrg_Vendor_b                  : boolean;
  JOrg_CreatedBy_JUser_ID        : UInt64;
  JOrg_Created_DT                : string[19];
  JOrg_ModifiedBy_JUser_ID       : UInt64;
  JOrg_Modified_DT               : string[19];
  JOrg_DeletedBy_JUser_ID        : UInt64;
  JOrg_Deleted_DT                : string[19];
  JOrg_Deleted_b                 : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JOrg(var p_rJOrg: rtJOrg);
//=============================================================================


//=============================================================================
{}
type rtJOrgPers=record
  JCpyP_JOrgPers_UID        : UInt64;
  JCpyP_JOrg_ID             : UInt64;
  JCpyP_JPerson_ID          : UInt64;
  JCpyP_DepartmentLU_ID     : UInt64;
  JCpyP_Title               : string[32];
  JCpyP_ReportsTo_Person_ID : Uint64;
  JCpyP_CreatedBy_JUser_ID  : Uint64;
  JCpyP_Created_DT          : string[19];
  JCpyP_ModifiedBy_JUser_ID : Uint64;
  JCpyP_Modified_DT         : string[19];
  JCpyP_DeletedBy_JUser_ID  : Uint64;
  JCpyP_Deleted_DT          : string[19];
  JCpyP_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JOrgPers(var p_rJOrgPers: rtJOrgPers);
//=============================================================================


//=============================================================================
{}
type rtJDConnection=record
  JDCon_JDConnection_UID                  : Uint64;
  JDCon_Name                              : String[32];
  JDCon_Desc                              : ansistring;
  JDCon_DBC_Filename                      : ansistring;
  JDCon_DSN                               : string;
  JDCon_DSN_FileBased_b                   : boolean;
  JDCon_DSN_Filename                      : ansistring;
  JDCon_Enabled_b                         : boolean;
  JDCon_DBMS_ID                           : Uint64;
  JDCon_Driver_ID                         : Uint64;
  JDCon_Username                          : string[32];
  JDCon_Password                          : string;
  JDCon_ODBC_Driver                       : string[32];
  JDCon_Server                            : string[32];
  JDCon_Database                          : string[32];
  JDCon_JSecPerm_ID                       : Uint64;
  JDCon_JAS_b                             : boolean;
  JDCon_CreatedBy_JUser_ID                : Uint64;
  JDCon_Created_DT                        : string[19];
  JDCon_ModifiedBy_JUser_ID               : Uint64;
  JDCon_Modified_DT                       : string[19];
  JDCon_DeletedBy_JUser_ID                : Uint64;
  JDCon_Deleted_DT                        : string[19];
  JDCon_Deleted_b                         : boolean;
  JAS_Row_b                               : boolean;
end;
procedure clear_JDConnection(var p_rJDConnection: rtJDConnection);
//=============================================================================


//=============================================================================
{}
// This table/structure is for debugging - so it's usage is meant to be lightweight
// user just passes "CODE" which is actually a Time stamp of when they were
// creating the code to write to this database in a YYYYMMDDHHMM format. We
// do this to keep entries unique enough so we can search systems for the
// "CODE" to find where a forgotten debug entry might be living unwanted in
// any of the attached systems.
type rtJDebug=record
  JDBug_JDebug_UID               : Uint64; //< NOTE: DBMS autonumber - Not a Jegas UID autonumber field!
  JDBug_Code_u                   : word;
  JDBug_Message                  : ansistring;
end;
procedure clear_JDebug(var p_rJDebug: rtJDebug);
//=============================================================================


//=============================================================================
{}
type rtJDType=record
  JDTyp_JDType_UID               : Uint64;
  JDTyp_Desc                     : ansistring;
  JDTyp_Notation                 : string[8];
  JDTyp_CreatedBy_JUser_ID       : Uint64;
  JDTyp_Created_DT               : string[19];
  JDTyp_ModifiedBy_JUser_ID      : Uint64;
  JDTyp_Modified_DT              : string[19];
  JDTyp_DeletedBy_JUser_ID       : Uint64;
  JDTyp_Deleted_DT               : string[19];
  JDTyp_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JDType(var p_rJDType: rtJDType);
//=============================================================================



//=============================================================================
{}
type rtJFile=record
  JFile_JFile_UID                : Uint64;
  JFile_en                       : ansistring;
  JFile_Name                     : ansistring;
  JFile_Path                     : ansistring;
  JFile_JTable_ID                : Uint64;
  JFile_JColumn_ID               : Uint64;
  JFile_Row_ID                   : Uint64;
  JFile_Orphan_b                 : boolean;
  JFile_JSecPerm_ID              : Uint64;
  JFile_FileSize_u               : Uint64;
  JFile_Downloads                : UInt64;
  JFile_CreatedBy_JUser_ID       : Uint64;
  JFile_Created_DT               : string[19];
  JFile_ModifiedBy_JUser_ID      : Uint64;
  JFile_Modified_DT              : string[19];
  JFile_DeletedBy_JUser_ID       : Uint64;
  JFile_Deleted_DT               : string[19];
  JFile_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JFile(var p_rJFile: rtJFile);
//=============================================================================



//=============================================================================
{}
type rtJFilterSave=record
  JFtSa_JFilterSave_UID          : Uint64;
  JFtSa_Name                     : string[64];
  JFtSa_JBlok_ID                 : Uint64;
  JFtSa_Public_b                 : boolean;
  JFTSa_XML                      : ansistring;
  JFtSa_CreatedBy_JUser_ID       : Uint64;
  JFtSa_Created_DT               : string[19];
  JFtSa_ModifiedBy_JUser_ID      : Uint64;
  JFtSa_Modified_DT              : string[19];
  JFtSa_DeletedBy_JUser_ID       : Uint64;
  JFtSa_Deleted_DT               : string[19];
  JFtSa_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JFilterSave(var p_rJFilterSave: rtJFilterSave);
//=============================================================================

//=============================================================================
{}
type rtJFilterSaveDef=record
  JFtSD_JFilterSaveDef_UID       : Uint64;
  JFtSD_JBlok_ID                 : Uint64;
  JFtSD_JFilterSave_ID           : Uint64;
  JFtSD_CreatedBy_JUser_ID       : Uint64;
  JFtSD_Created_DT               : string[19];
  JFtSD_ModifiedBy_JUser_ID      : Uint64;
  JFtSD_Modified_DT              : string[19];
  JFtSD_DeletedBy_JUser_ID       : Uint64;
  JFtSD_Deleted_DT               : string[19];
  JFtSD_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JFilterSaveDef(var p_rJFilterSaveDef: rtJFilterSaveDef);
//=============================================================================


// ============================================================================
{}
type rtJHelp=record
  Help_JHelp_UID            : Uint64;
  Help_VideoMP4_en          : ansistring;  
  Help_HTML_en              : ansistring;  
  Help_HTML_Adv_en          : ansistring;  
  Help_Name                 : string[64];
  Help_Poster               : ansistring;  
  Help_CreatedBy_JUser_ID   : Uint64;
  Help_Created_DT           : string[19];
  Help_ModifiedBy_JUser_ID  : Uint64;
  Help_Modified_DT          : string[19];
  Help_DeletedBy_JUser_ID   : Uint64;
  Help_Deleted_DT           : string[19];
  Help_Deleted_b            : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JHelp(p_rJHelp: rtJHelp);
// ============================================================================







// ============================================================================
{}
type rtJIndexFile = record
  JIDX_JIndexFile_UID        : Uint64;
  JIDX_JVHost_ID             : Uint64;
  JIDX_Filename              : ansistring;
  JIDX_Order_u               : byte;
  JIDX_CreatedBy_JUser_ID    : Uint64;
  JIDX_Created_DT            : string[19];
  JIDX_ModifiedBy_JUser_ID   : Uint64;
  JIDX_Modified_DT           : string[19];
  JIDX_DeletedBy_JUser_ID    : Uint64;
  JIDX_Deleted_DT            : string[19];
  JIDX_Deleted_b             : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JIndexFile(var p_rJIndexFile: rtJIndexFile);
// ============================================================================

// ============================================================================
{}
type rtJIndexFileLight = record
  u8JIndexFile_UID        : UInt64;
  u8JVHost_ID             : UInt64;
  saFilename              : ansistring;
end;
procedure clear_JIndexFileLight(var p_rJIndexFileLight: rtJIndexFileLight);
// ============================================================================



//=============================================================================
{}
type rtJIndustry=record
  JIndu_JIndustry_UID            : UInt64;
  JIndu_Name                     : string[32];
  JIndu_CreatedBy_JUser_ID       : UInt64;
  JIndu_Created_DT               : string[19];
  JIndu_ModifiedBy_JUser_ID      : UInt64;
  JIndu_Modified_DT              : string[19];
  JIndu_DeletedBy_JUser_ID       : UInt64;
  JIndu_Deleted_DT               : string[19];
  JIndu_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JIndustry(var p_rJIndustry: rtJIndustry);
//=============================================================================

//=============================================================================
{}
type rtJInstalled=record
  JInst_JInstalled_UID           : UInt64;
  JInst_JModule_ID               : UInt64;
  JInst_Name                     : string[32];
  JInst_Desc                     : ansistring;
  JInst_JNote_ID                 : UInt64;
  JInst_Enabled_b                : boolean;
  JInst_CreatedBy_JUser_ID       : UInt64;
  JInst_Created_DT               : string[19];
  JInst_ModifiedBy_JUser_ID      : UInt64;
  JInst_Modified_DT              : string[19];
  JInst_DeletedBy_JUser_ID       : UInt64;
  JInst_Deleted_DT               : string[19];
  JInst_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JInstalled(var p_rJInstalled: rtJInstalled);
//=============================================================================

//=============================================================================
{}
type rtJInterface=record
  JIntF_JInterface_UID           : UInt64;
  JIntF_Name                     : string[32];
  JIntF_Desc                     : ansistring;
  JIntF_CreatedBy_JUser_ID       : UInt64;
  JIntF_Created_DT               : string[19];
  JIntF_ModifiedBy_JUser_ID      : UInt64;
  JIntF_Modified_DT              : string[19];
  JIntF_DeletedBy_JUser_ID       : UInt64;
  JIntF_Deleted_DT               : string[19];
  JIntF_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;
end;
procedure clear_JInterface(var p_rJInterface: rtJInterface);
//=============================================================================


//=============================================================================
{}
Type rtJInvoice=record
  JIHdr_JInvoice_UID         : UInt64;
  JIHdr_DateInv_DT           : string[19];
  JIHdr_DateShip_DT          : string[19];
  JIHdr_DateOrd_DT           : string[19];
  JIHdr_POCust               : string[32];
  JIHdr_POInternal           : string[32];
  JIHdr_ShipVia              : string[32];
  JIHdr_Note01               : string;
  JIHdr_Note02               : string;
  JIHdr_Note03               : string;
  JIHdr_Note04               : string;
  JIHdr_Note05               : string;
  JIHdr_Note06               : string;
  JIHdr_Terms01              : string;
  JIHdr_Terms02              : string;
  JIHdr_Terms03              : string;
  JIHdr_Terms04              : string;
  JIHdr_Terms05              : string;
  JIHdr_Terms06              : string;
  JIHdr_Terms07              : string;
  JIHdr_SalesAmt_d           : currency;
  JIHdr_MiscAmt_d            : currency;
  JIHdr_SalesTaxAmt_d        : currency;
  JIHdr_ShipAmt_d            : currency;
  JIHdr_TotalAmt_d           : currency;
  JIHdr_BillToAddr01         : string[64];
  JIHdr_BillToAddr02         : string[64];
  JIHdr_BillToAddr03         : string[64];
  JIHdr_BillToCity           : string[32];
  JIHdr_BillToState          : string[32];
  JIHdr_BillToPostalCode     : string[16];
  JIHdr_ShipToAddr01         : string[64];
  JIHdr_ShipToAddr02         : string[64];
  JIHdr_ShipToAddr03         : string[64];
  JIHdr_ShipToCity           : string[32];
  JIHdr_ShipToState          : string[32];
  JIHdr_ShipToPostalCode     : string[16];
  JIHDr_JOrg_ID              : Uint64;
  JIHDr_JPerson_ID           : Uint64;
  JIHdr_CreatedBy_JUser_ID   : Uint64;
  JIHdr_Created_DT           : string[19];
  JIHdr_ModifiedBy_JUser_ID  : Uint64;
  JIHdr_Modified_DT          : string[19];
  JIHdr_DeletedBy_JUser_ID   : Uint64;
  JIHdr_Deleted_DT           : string[19];
  JIHdr_Deleted_b            : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JInvoice(var p_rJInvoice: rtJInvoice);
//=============================================================================

//=============================================================================
{}
Type rtJInvoiceLines=record
  JILin_JInvoiceLines_UID    : Uint64;
  JILin_JInvoice_ID          : Uint64;
  JILin_ProdNoInternal       : string[32];
  JILin_ProdNoCust           : string[32];
  JILin_JProduct_ID          : Uint64;
  JILin_QtyOrd_d             : currency;
  JILin_DescA                : string;
  JILin_DescB                : string;
  JILin_QtyShip_d            : currency;
  JILin_PrcUnit_d            : currency;
  JILin_PrcExt_d             : currency;
  JILin_SEQ_u                : word;
  JILin_CreatedBy_JUser_ID   : Uint64;
  JILin_Created_DT           : string[19];
  JILin_ModifiedBy_JUser_ID  : Uint64;
  JILin_Modified_DT          : string[19];
  JILin_DeletedBy_JUser_ID   : Uint64;
  JILin_Deleted_DT           : string[19];
  JILin_Deleted_b            : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JInvoiceLines(var p_rJInvoiceLines: rtJInvoiceLines);
//=============================================================================



//=============================================================================
{}
type rtJIPList = Record
  JIPL_JIPList_UID            : Uint64;
  JIPL_IPListType_u           : byte;
  JIPL_IPAddress              : string[15];
  JIPL_InvalidLogins_u        : byte;
  JIPL_Reason                 : string;
  JIPL_CreatedBy_JUser_ID     : Uint64;
  JIPL_Created_DT             : string[19];
  JIPL_ModifiedBy_JUser_ID    : Uint64;
  JIPL_Modified_DT            : string[19];
  JIPL_DeletedBy_JUser_ID     : Uint64;
  JIPL_Deleted_DT             : string[19];
  JIPL_Deleted_b              : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JIPList(var p_rJIPList: rtJIPList);
//=============================================================================

//=============================================================================
{}
type rtJIPListLight = Record
  u8JIPList_UID            : UInt64;
  u1IPListType             : byte;
  sIPAddress               : string[15];
  u1InvalidLogins          : byte;
  u2Downloads              : word;
  bRequestedRobotsTxt      : boolean;
  dtDownLoad               : TDateTime;
  u1JMails                 : byte;
end;
procedure clear_JIPListLight(var p_rJIPListLight: rtJIPListLight);
//=============================================================================


//=============================================================================
{}
type rtJIPListLU = record
  IPLU_JIPListLU_UID           : Uint64;
  IPLU_Name                    : string[32];
  IPLU_CreatedBy_JUser_ID      : Uint64;
  IPLU_Created_DT              : string[19];
  IPLU_DeletedBy_JUser_ID      : Uint64;
  IPLU_Deleted_b               : boolean;
  IPLU_Deleted_DT              : string[19];
  IPLU_ModifiedBy_JUser_ID     : Uint64;
  IPLU_Modified_DT             : string[19];
  JAS_Row_b                    : boolean;
end;
procedure clear_JIPListLU(var p_rJIPListLU: rtJIPListLU);
//=============================================================================




//=============================================================================
{}
type rtJIPStat = record
IPST_Jipstat_UID        : Uint64; // Unsigned 08 Bytes
IPST_CreatedBy_JUser_ID : Uint64; // Unsigned 08 Bytes
IPST_Created_DT         : string[19]; // DateTime
IPST_ModifiedBy_JUser_ID: Uint64; // Unsigned 08 Bytes
IPST_Modified_DT        : string[19]; // DateTime
IPST_DeletedBy_JUser_ID : Uint64; // Unsigned 08 Bytes
IPST_Deleted_DT         : string[19]; // DateTime
IPST_Deleted_b          : boolean; // Boolean
JAS_Row_b               : boolean; // Boolean
IPST_IPAddress          : string[15]; // Text - ASCII,15
IPST_Downloads          : word; // Word - 02 Bytes
IPST_Errors             : word; // Word - 02 bytes
end;//type
procedure clear_JIPStat(var p_rJIPStat: rtJIPStat);

//=============================================================================




//=============================================================================
{}
type rtJJobQ=record
  JJobQ_JJobQ_UID           : Uint64;
  JJobQ_JUser_ID            : Uint64;
  JJobQ_JJobType_ID         : Uint64;
  JJobQ_Start_DT            : string[19];
  JJobQ_ErrorNo_u           : word;
  JJobQ_Started_DT          : string[19];
  JJobQ_Running_b           : boolean;
  JJobQ_Finished_DT         : string[19];
  JJobQ_Name                : string[32];
  JJobQ_Repeat_b            : boolean;
  JJobQ_RepeatMinute        : string[8];
  JJobQ_RepeatHour          : string[8];
  JJobQ_RepeatDayOfMonth    : string[8];
  JJobQ_RepeatMonth         : string[8];
  JJobQ_Completed_b         : boolean;
  JJobQ_Result_URL          : ansistring;
  JJobQ_ErrorMsg            : ansistring;
  JJobQ_ErrorMoreInfo       : ansistring;
  JJobQ_Enabled_b           : boolean;
  JJobQ_Job                 : ansistring;
  JJobQ_Result              : ansistring;
  JJobQ_CreatedBy_JUser_ID  : Uint64;
  JJobQ_Created_DT          : string[19];
  JJobQ_ModifiedBy_JUser_ID : Uint64;
  JJobQ_Modified_DT         : string[19];
  JJobQ_DeletedBy_JUser_ID  : Uint64;
  JJobQ_Deleted_DT          : string[19];
  JJobQ_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
  JJobQ_JTask_ID            : Uint64;
end;
procedure clear_JJobQ(var p_rJJobQ: rtJJobQ);
//=============================================================================

//=============================================================================
type rtJLanguage = record
//=============================================================================
 	JLang_JLanguage_UID        : Uint64;
 	JLang_Name                 : string[32];
 	JLang_NativeName           : string[32];
 	JLang_Code                 : string[3];
 	JLang_CreatedBy_JUser_ID   : Uint64;
 	JLang_Created_DT           : string[19];
 	JLang_ModifiedBy_JUser_ID  : Uint64;
 	JLang_Modified_DT          : string[19];
 	JLang_DeletedBy_JUser_ID   : Uint64;
 	JLang_Deleted_DT           : string[19];
 	JLang_Deleted_b            : boolean;
 	JAS_Row_b                  : boolean;
end;
procedure clear_JLanguage(var p_rJLanguage: rtJLanguage);
//=============================================================================



//=============================================================================
type rtJLanguageLight = record
//=============================================================================
  u8JLanguage_UID        : UInt64;
  saName                 : string[32];
  saNativeName           : string[32];
  saCode                 : string[3];
end;
procedure clear_JLanguageLight(var p_rJLanguageLight: rtJLanguageLight);
//=============================================================================


//=============================================================================
{}
type rtJLead=record
  JLead_JLead_UID           : Uint64;
  JLead_JLeadSource_ID      : Uint64;
  JLead_Owner_JUser_ID      : Uint64;
  JLead_Private_b           : boolean;
  JLead_OrgName             : string[32];
  JLead_NameSalutation      : string[16];
  JLead_NameFirst           : string[32];
  JLead_NameMiddle          : string[32];
  JLead_NameLast            : string[32];
  JLead_NameSuffix          : string[16];
  JLead_Desc                : ansistring;
  JLead_Gender              : string[1];
  JLead_Home_Phone          : string[32];
  JLead_Mobile_Phone        : string[32];
  JLead_Work_Email          : string[64];
  JLead_Work_Phone          : string[32];
  JLead_Fax                 : string[32];
  JLead_Home_Email          : string[64];
  JLead_Website             : string[128];
  JLead_Main_Addr1          : string[64];
  JLead_Main_Addr2          : string[64];
  JLead_Main_Addr3          : string[64];
  JLead_Main_City           : string[32];
  JLead_Main_State          : string[32];
  JLead_Main_PostalCode     : string[16];
  JLead_Main_Country        : string[32];
  JLead_Ship_Addr1          : string[64];
  JLead_Ship_Addr2          : string[64];
  JLead_Ship_Addr3          : string[64];
  JLead_Ship_City           : string[32];
  JLead_Ship_State          : string[32];
  JLead_Ship_PostalCode     : string[16];
  JLead_Ship_Country        : string[32];
  JLead_Exist_JOrg_ID       : Uint64;
  JLead_Exist_JPerson_ID    : Uint64;
  JLead_LeadSourceAddl      : string[32];
  JLead_CreatedBy_JUser_ID  : Uint64;
  JLead_Created_DT          : string[19];
  JLead_ModifiedBy_JUser_ID : Uint64;
  JLead_Modified_DT         : string[19];
  JLead_DeletedBy_JUser_ID  : Uint64;
  JLead_Deleted_DT          : string[19];
  JLead_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JLead(var p_rJLead: rtJLead);
//=============================================================================

//=============================================================================
{}
type rtJLeadSource=record
  JLDSR_JLeadSource_UID     : Uint64;
  JLDSR_Name                : string[32];
  JLDSR_CreatedBy_JUser_ID  : Uint64;
  JLDSR_Created_DT          : string[19];
  JLDSR_ModifiedBy_JUser_ID : Uint64;
  JLDSR_Modified_DT         : string[19];
  JLDSR_DeletedBy_JUser_ID  : Uint64;
  JLDSR_Deleted_DT          : string[19];
  JLDSR_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JLeadSource(var p_rJLeadSource: rtJLeadSource);
//=============================================================================

//=============================================================================
{}
type rtJLock=record
  JLock_JLock_UID           : Uint64;
  JLock_JSession_ID         : Uint64;
  JLock_JDConnection_ID     : Uint64;
  JLock_Locked_DT           : string[19];
  JLock_Table_ID            : Uint64;
  JLock_Row_ID              : Uint64;
  JLock_Col_ID              : Uint64;
  JLock_Username            : string[32];
  JLock_CreatedBy_JUser_ID  : Uint64;
end;
procedure clear_JLock(var p_rJLock: rtJLock);
//=============================================================================

//=============================================================================
{}
type rtJLog=record
  JLOG_JLog_UID              : Uint64;
  JLOG_DateNTime_DT          : string[19];
  JLOG_JLogType_ID           : Uint64;
  JLOG_Entry_ID              : Uint64;
  JLOG_EntryData_s           : ansistring;
  JLOG_SourceFile_s          : ansistring;
  JLOG_User_ID               : Uint64;
  JLOG_CmdLine_s             : ansistring;
end;
procedure clear_JLog(var p_rJLog: rtJLog);
//=============================================================================

//=============================================================================
{}
type rtJLookup=record
  JLook_JLookup_UID         : Uint64;
  JLook_Name                : string[32];
  JLook_Value               : ansistring;
  JLook_Position_u          : word;// unsure if byte to small here
  JLook_en                  : string[3];
  JLook_Created_DT          : string[19];
  JLook_ModifiedBy_JUser_ID : Uint64;
  JLook_Modified_DT         : string[19];
  JLook_DeletedBy_JUser_ID  : Uint64;
  JLook_Deleted_DT          : string[19];
  JLook_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JLookup(var p_rJLookup: rtJLookup);
//=============================================================================



//=============================================================================
{}
type rtJMail=record
  JMail_JMail_UID              : Uint64;
  JMail_To_User_ID             : Uint64;
  JMail_From_User_ID           : Uint64;
  JMail_Message                : ansistring;
  JMail_Message_Code           : ansistring;
  JMail_CreatedBy_JUser_ID     : Uint64;
  JMail_Created_DT             : string[19];
  JMail_ModifiedBy_JUser_ID    : Uint64;
  JMail_Modified_DT            : string[19];
  JMail_DeletedBy_JUser_ID     : Uint64;
  JMail_Deleted_DT             : string[19];
  JMail_Deleted_b              : boolean;
  JAS_Row_b                    : boolean;
end;
procedure clear_jmail(var p_rJMail: rtJMail);
//=============================================================================






//=============================================================================
{}
type rtJMenu=record
  JMenu_JMenu_UID                   : Uint64; //< This is stored as integer For binary Search reasons. See JMenuDL.
  JMenu_JMenuParent_ID              : UInt64; //< This is stored as integer for binary search reasons. See JMenuDL.
  JMenu_JSecPerm_ID                 : Uint64;
  JMenu_Name                        : string[64];
  JMenu_URL                         : ansistring;
  JMenu_NewWindow_b                 : boolean;
  JMenu_IconSmall                   : ansistring;
  JMenu_IconLarge                   : ansistring;
  JMenu_ValidSessionOnly_b          : boolean;
  JMenu_SEQ_u                       : word;
  JMenu_DisplayIfNoAccess_b         : boolean;
  JMenu_DisplayIfValidSession_b     : boolean;
  JMenu_IconLarge_Theme_b           : boolean;
  JMenu_IconSmall_Theme_b           : boolean;
  JMenu_ReadMore_b                  : boolean;
  JMenu_Title_en                    : string[64];
  JMenu_Data_en                     : ansistring;
  JMenu_CreatedBy_JUser_ID          : Uint64;
  JMenu_Created_DT                  : string[19];
  JMenu_ModifiedBy_JUser_ID         : Uint64;
  JMenu_Modified_DT                 : string[19];
  JMenu_DeletedBy_JUser_ID          : Uint64;
  JMenu_Deleted_DT                  : ansistring;
  JMenu_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JMenu(var p_rJMenu: rtJMenu);
//=============================================================================


// ============================================================================
{}
Type rtJMime=record
  MIME_JMime_UID             : Uint64;
  MIME_Name                  : string[32];
  MIME_Type                  : string[32];
  MIME_Enabled_b             : boolean;
  MIME_SNR_b                 : boolean;
  MIME_CreatedBy_JUser_ID    : Uint64;
  MIME_Created_DT            : string[19];
  MIME_ModifiedBy_JUser_ID   : Uint64;
  MIME_Modified_DT           : string[19];
  MIME_DeletedBy_JUser_ID    : Uint64;
  MIME_Deleted_DT            : string[19];
  MIME_Deleted_b             : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JMime(var p_rJMime: rtJMime);
// ============================================================================

// ============================================================================
{}
Type rtJMimeLight=record
  u8JMime_UID             : UInt64;
  sName                   : string[32];
  sType                   : string[32];
  bSNR                    : boolean;
end;
procedure clear_JMimeLight(var p_rJMimeLight: rtJMimeLight);
// ============================================================================



//=============================================================================
{}
type rtJModC=record
  JModC_JModC_UID           : Uint64;
  JModC_JInstalled_ID       : Uint64;
  JModC_Column_ID           : Uint64;
  JModC_Row_ID              : Uint64;
  JModC_CreatedBy_JUser_ID  : Uint64;
  JModC_Created_DT          : string[19];
  JModC_ModifiedBy_JUser_ID : Uint64;
  JModC_Modified_DT         : string[19];
  JModC_DeletedBy_JUser_ID  : Uint64;
  JModC_Deleted_DT          : string[19];
  JModC_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JModC(var p_rJModC: rtJModC);
//=============================================================================

//=============================================================================
{}
type rtJModule=record
  JModu_JModule_UID         : Uint64;
  JModu_Name                : string[32];
  JModu_Version_Major_u     : byte;
  JModu_Version_Minor_u     : byte;
  JModu_Version_Revision_u  : word;
  JModu_CreatedBy_JUser_ID  : Uint64;
  JModu_Created_DT          : string[19];
  JModu_ModifiedBy_JUser_ID : Uint64;
  JModu_Modified_DT         : string[19];
  JModu_DeletedBy_JUser_ID  : Uint64;
  JModu_Deleted_DT          : string[19];
  JModu_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JModule(var p_rJModule: rtJModule);
//=============================================================================

//=============================================================================
{}
type rtJModuleConfig=record
  JMCfg_JModuleConfig_UID   : Uint64;
  JMCfg_JModuleSetting_ID   : Uint64;
  JMCfg_Value               : ansistring;
  JMCfg_JNote_ID            : Uint64;
  JMCfg_JInstalled_ID       : Uint64;
  JMCfg_JUser_ID            : Uint64;
  JMCfg_Read_JSecPerm_ID    : Uint64;
  JMCfg_Write_JSecPerm_ID   : Uint64;
  JMCfg_CreatedBy_JUser_ID  : Uint64;
  JMCfg_Created_DT          : string[19];
  JMCfg_ModifiedBy_JUser_ID : Uint64;
  JMCfg_Modified_DT         : string[19];
  JMCfg_DeletedBy_JUser_ID  : Uint64;
  JMCfg_Deleted_DT          : string[19];
  JMCfg_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JModuleConfig(var p_rJModuleConfig: rtJModuleConfig);
//=============================================================================


//=============================================================================
{}
type rtJModuleSetting=record
  JMSet_JModuleSetting_UID  : Uint64;
  JMSet_Name                : string[32];
  JMSet_JCaption_ID         : Uint64;
  JMSet_JNote_ID            : Uint64;
  JMSet_JModule_ID          : Uint64;
  JMSet_CreatedBy_JUser_ID  : Uint64;
  JMSet_Created_DT          : string[19];
  JMSet_ModifiedBy_JUser_ID : Uint64;
  JMSet_Modified_DT         : string[19];
  JMSet_DeletedBy_JUser_ID  : Uint64;
  JMSet_Deleted_DT          : string[19];
  JMSet_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JModuleSetting(var p_rJModuleSetting: rtJModuleSetting);
//=============================================================================




//=============================================================================
{}
type rtJNote=record
  JNote_JNote_UID           : Uint64;
  JNote_JTable_ID           : Uint64;
  JNote_JColumn_ID          : Uint64;
  JNote_Row_ID              : Uint64;
  JNote_Orphan_b            : boolean;
  JNote_en                  : string[3];
  JNote_CreatedBy_JUser_ID  : Uint64;
  JNote_Created_DT          : string[19];
  JNote_ModifiedBy_JUser_ID : Uint64;
  JNote_Modified_DT         : string[19];
  JNote_DeletedBy_JUser_ID  : Uint64;
  JNote_Deleted_DT          : string[19];
  JNote_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JNote(var p_rJNote: rtJNote);
//=============================================================================





//=============================================================================
{}
type rtJPassword=record
  JPass_JPassword_UID        : Uint64;
  JPass_Name                 : string[64];
  JPass_Desc                 : ansistring;
  JPass_URL                  : ansistring;
  JPass_Owner_JUser_ID       : Uint64;
  JPass_Private_Memo         : ansistring;
  JPass_JSecPerm_ID          : Uint64;
  JPass_CreatedBy_JUser_ID   : Uint64;
  JPass_Created_DT           : string[19];
  JPass_ModifiedBy_JUser_ID  : Uint64;
  JPass_Modified_DT          : string[19];
  JPass_DeletedBy_JUser_ID   : Uint64;
  JPass_Deleted_DT           : string[19];
  JPass_Deleted_b            : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JPassword(var p_rJPassword: rtJPassword);
//=============================================================================





//=============================================================================
{}
type rtJPerson=record
  JPers_JPerson_UID                 : Uint64;
  JPers_Desc                        : ansistring;
  JPers_NameSalutation              : string[10];
  JPers_NameFirst                   : string[32];
  JPers_NameMiddle                  : string[32];
  JPers_NameLast                    : string[32];
  JPers_NameSuffix                  : string[10];
  JPers_NameDear                    : string[32];
  JPers_Gender                      : string[1];
  JPers_Private_b                   : boolean;
  JPers_Addr1                       : string[64];
  JPers_Addr2                       : string[64];
  JPers_Addr3                       : string[64];
  JPers_City                        : string[32];
  JPers_State                       : string[32];
  JPers_PostalCode                  : string[16];
  JPers_Country                     : string[32];
  JPers_Home_Email                  : string[64];
  JPers_Home_Phone                  : string[32];
  JPers_Latitude_d                  : double;
  JPers_Longitude_d                 : double;
  JPers_Mobile_Phone                : string[32];
  JPers_Work_Email                  : string[64];
  JPers_Work_Phone                  : string[32];
  JPers_Primary_Org_ID              : Uint64;
  JPers_Customer_b                  : boolean;
  JPers_Vendor_b                    : boolean;
  JPers_DOB_DT                      : string[19];
  JPers_CC                          : string[24];//NOTE: mGenerally 16 digits (left room for expansion and dashes ;)
  JPers_CCExpire                    : string[8];
  JPers_CCSecCode                   : string[8];//usually 3 digits
  JPers_CreatedBy_JUser_ID          : Uint64;
  JPers_Created_DT                  : string[19];
  JPers_ModifiedBy_JUser_ID         : Uint64;
  JPers_Modified_DT                 : string[19];
  JPers_DeletedBy_JUser_ID          : Uint64;
  JPers_Deleted_DT                  : string[19];
  JPers_Deleted_b                   : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JPerson(var p_rJPerson: rtJPerson);
//=============================================================================


//=============================================================================
{}
type rtJPriority=record
  JPrio_JPriority_UID       : Uint64;
  JPrio_en                  : string[32];
  JPrio_CreatedBy_JUser_ID  : Uint64;
  JPrio_Created_DT          : string[19];
  JPrio_ModifiedBy_JUser_ID : Uint64;
  JPrio_Modified_DT         : string[19];
  JPrio_DeletedBy_JUser_ID  : Uint64;
  JPrio_Deleted_DT          : string[19];
  JPrio_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JPriority(var p_rJPriority: rtJPriority);
//=============================================================================






//=============================================================================
{}
type rtJProduct=record
  JProd_JProduct_UID          : Uint64;
  JProd_Number                : string[32];
  JProd_Name                  : string[64];
  JProd_Desc                  : ansistring;
  JProd_CreatedBy_JUser_ID    : Uint64;
  JProd_Created_DT            : string[19];
  JProd_ModifiedBy_JUser_ID   : Uint64;
  JProd_Modified_DT           : string[19];
  JProd_DeletedBy_JUser_ID    : Uint64;
  JProd_Deleted_DT            : string[19];
  JProd_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JProduct(var p_rJProduct: rtJProduct);
//=============================================================================

//=============================================================================
{}
type rtJProductGrp=record
  JPrdG_JProductGrp_UID     : Uint64;
  JPrdG_Name                : string[32];
  JPrdG_Desc                : ansistring;
  JPrdG_CreatedBy_JUser_ID  : Uint64;
  JPrdG_Created_DT          : string[19];
  JPrdG_ModifiedBy_JUser_ID : Uint64;
  JPrdG_Modified_DT         : string[19];
  JPrdG_DeletedBy_JUser_ID  : Uint64;
  JPrdG_Deleted_DT          : string[19];
  JPrdG_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JProductGrp(var p_rJProductGrp: rtJProductGrp);
//=============================================================================

//=============================================================================
{}
type rtJProductQty=record
  JPrdQ_JProductQty_UID     : Uint64;
  JPrdQ_Location_JOrg_ID    : Uint64;
  JPrdQ_QtyOnHand_d         : currency;// need decimal fixed again here because some folks sell partial products - like labor 1.5 hours of labor is example.
  JPrdQ_QtyOnOrder_d        : currency;
  JPrdQ_QtyOnBackOrder_d    : currency;
  JPrdQ_JProduct_ID         : Uint64;
  JPrdQ_CreatedBy_JUser_ID  : Uint64;
  JPrdQ_Created_DT          : string[19];
  JPrdQ_ModifiedBy_JUser_ID : Uint64;
  JPrdQ_Modified_DT         : string[19];
  JPrdQ_DeletedBy_JUser_ID  : Uint64;
  JPrdQ_Deleted_DT          : string[19];
  JPrdQ_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JProductQty(var p_rJProductQty: rtJProductQty);
//=============================================================================

//=============================================================================
{}
type rtJProject=record
  JProj_JProject_UID          : Uint64;
  JProj_Name                  : string[64];
  JProj_Owner_JUser_ID        : Uint64;
  JProj_URL                   : ansistring;
  JProj_URL_Stage             : ansistring;
  JProj_JProjectStatus_ID     : Uint64;
  JProj_JProjectPriority_ID   : Uint64;
  JProj_JProjectCategory_ID   : Uint64;
  JProj_Progress_PCT_d        : currency;
  JProj_Hours_Worked_d        : currency;
  JProj_Hours_Sched_d         : currency;
  JProj_Hours_Project_d       : currency;
  JProj_Desc                  : ansistring;
  JProj_Start_DT              : string[19];
  JProj_Target_End_DT         : string[19];
  JProj_Actual_End_DT         : string[19];
  JProj_Target_Budget_d       : currency;
  JProj_JOrg_ID               : Uint64;
  JProj_JPerson_ID            : Uint64;
  JProj_CreatedBy_JUser_ID    : Uint64;
  JProj_Created_DT            : string[19];
  JProj_ModifiedBy_JUser_ID   : Uint64;
  JProj_Modified_DT           : string[19];
  JProj_DeletedBy_JUser_ID    : Uint64;
  JProj_Deleted_DT            : string[19];
  JProj_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JProject(var p_rJProject: rtJProject);
//=============================================================================


//=============================================================================
{}
type rtJProjectCategory=record
  JPjCt_JProjectCategory_UID : Uint64;
  JPjCt_Name                 : string[32];
  JPjCt_Desc                 : ansistring;
  JPjCt_JCaption_ID          : Uint64;
  JPjCt_CreatedBy_JUser_ID   : Uint64;
  JPjCt_Created_DT           : string[19];
  JPjCt_ModifiedBy_JUser_ID  : Uint64;
  JPjCt_Modified_DT          : string[19];
  JPjCt_DeletedBy_JUser_ID   : Uint64;
  JPjCt_Deleted_DT           : string[19];
  JPjCt_Deleted_b            : boolean;
  JAS_Row_b                  : boolean;
end;
procedure clear_JProjectCategory(var p_rJProjectCategory: rtJProjectCategory);
//=============================================================================



//=============================================================================
{}
type rtJQuickLink=record
  JQLnk_JQuickLink_UID          : Uint64;
  JQLnk_Name                    : string[32];
  JQLnk_SecPerm_ID              : Uint64;
  JQLnk_Desc                    : ansistring;
  JQLnk_URL                     : ansistring;
  JQLnk_Icon                    : ansistring;
  JQLnk_Owner_JUser_ID          : Uint64;
  JQLnk_Position_u              : word;
  JQLnk_ValidSessionOnly_b      : boolean;
  JQLnk_DisplayIfNoAccess_b     : boolean;
  JQLnk_DisplayIfValidSession_b : boolean;
  JQLnk_RenderAsUniqueDiv_b     : boolean;
  JQLnk_Private_Memo            : ansistring;
  JQLnk_Private_b               : boolean;
  JQLnk_CreatedBy_JUser_ID      : Uint64;
  JQLnk_Created_DT              : string[19];
  JQLnk_ModifiedBy_JUser_ID     : Uint64;
  JQLnk_Modified_DT             : string[19];
  JQLnk_DeletedBy_JUser_ID      : Uint64;
  JQLnk_Deleted_b               : boolean;
  JQLnk_Deleted_DT              : string[19];
  JAS_Row_b                     : boolean;
end;
procedure clear_JQuickLink(p_rJQuickLink: rtJQuickLink);
//=============================================================================

//=============================================================================
{}
type rtJRedirect = record
  REDIR_Jredirect_UID       : Uint64;
  REDIR_CreatedBy_JUser_ID  : Uint64;
  REDIR_Created_DT          : string[19];
  REDIR_ModifiedBy_JUser_ID : Uint64;
  REDIR_Modified_DT         : string[19];
  REDIR_DeletedBy_JUser_ID  : Uint64;
  REDIR_Deleted_DT          : string[19];
  REDIR_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
  REDIR_JRedirectLU_ID      : Uint64;
  REDIR_Location            : ansistring;
  REDIR_NewLocation         : ansistring;
  REDIR_JVHost_ID           : Uint64;
end;
procedure clear_JRedirect(var p_rJRedirect: rtJRedirect);
//=============================================================================
{}
// this mini version of the structure above is to save space, as we need this
// list memory resident, so we do not want unneccessary data wasting RAM.
type rtJRedirectLight = record
  REDIR_JRedirectLU_ID      : Uint64;
  REDIR_Location            : ansistring;
  REDIR_NewLocation         : ansistring;
  VHostIndex                : Uint64;
end;
//=============================================================================








//=============================================================================
{}
Type rtJScreen=Record
  JScrn_JScreen_UID         : Uint64;
  JScrn_Name                : string[64];
  JScrn_Desc                : ansistring;
  JScrn_JCaption_ID         : Uint64;
  JScrn_JScreenType_ID      : Uint64;
  JScrn_Template            : AnsiString;
  JScrn_ValidSessionOnly_b  : boolean;
  JScrn_JSecPerm_ID         : Uint64;
  JScrn_Detail_JScreen_ID   : Uint64;
  JScrn_IconSmall           : AnsiString;
  JScrn_IconLarge           : AnsiString;
  JScrn_TemplateMini        : ansistring;
  JScrn_Help_ID             : Uint64;
  JScrn_Modify_JSecPerm_ID  : Uint64;
  JScrn_CreatedBy_JUser_ID  : Uint64;
  JScrn_Created_DT          : string[19];
  JScrn_ModifiedBy_JUser_ID : Uint64;
  JScrn_Modified_DT         : string[19];
  JScrn_DeletedBy_JUser_ID  : Uint64;
  JScrn_Deleted_DT          : string[19];
  JScrn_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
End;
procedure clear_JScreen(var p_rJScreen: rtJScreen);
//=============================================================================


//=============================================================================
{}
type rtJScreenType=record
  JScTy_JScreenType_UID     : Uint64;
  JScTy_Name                : string[32];
  JScTy_CreatedBy_JUser_ID  : Uint64;
  JScTy_Created_DT          : string[19];
  JScTy_ModifiedBy_JUser_ID : Uint64;
  JScTy_Modified_DT         : string[19];
  JScTy_DeletedBy_JUser_ID  : Uint64;
  JScTy_Deleted_DT          : string[19];
  JScTy_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JScreenType(var p_rJScreenType: rtJScreenType);
//=============================================================================

//=============================================================================
{}
type rtJSecGrp=record
  JSGrp_JSecGrp_UID           : Uint64;
  JSGrp_Name                  : string[32];
  JSGrp_Desc                  : ansistring;
  JSGrp_CreatedBy_JUser_ID    : Uint64;
  JSGrp_Created_DT            : string[19];
  JSGrp_ModifiedBy_JUser_ID   : Uint64;
  JSGrp_Modified_DT           : string[19];
  JSGrp_DeletedBy_JUser_ID    : Uint64;
  JSGrp_Deleted_DT            : string[19];
  JSGrp_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JSecGrp(var p_rJSecGrp: rtJSecGrp);
//=============================================================================


//=============================================================================
{}
type rtJSecGrpLink=record
  JSGLk_JSecGrpLink_UID     : Uint64;
  JSGLk_JSecPerm_ID         : Uint64;
  JSGLk_JSecGrp_ID          : Uint64;
  JSGLk_CreatedBy_JUser_ID  : Uint64;
  JSGLk_Created_DT          : string[19];
  JSGLk_ModifiedBy_JUser_ID : Uint64;
  JSGLk_Modified_DT         : string[19];
  JSGLk_DeletedBy_JUser_ID  : Uint64;
  JSGLk_Deleted_DT          : string[19];
  JSGLk_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JSecGrpLink(var p_rJSecGrpLink: rtJSecGrpLink);
//=============================================================================

//=============================================================================
{}
type rtJSecGrpUserLink=record
  JSGUL_JSecGrpUserLink_UID   : Uint64;
  JSGUL_JSecGrp_ID            : Uint64;
  JSGUL_JUser_ID              : Uint64;
  JSGUL_CreatedBy_JUser_ID    : Uint64;
  JSGUL_Created_DT            : string[19];
  JSGUL_ModifiedBy_JUser_ID   : Uint64;
  JSGUL_Modified_DT           : string[19];
  JSGUL_DeletedBy_JUser_ID    : Uint64;
  JSGUL_Deleted_DT            : string[19];
  JSGUL_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JSecGrpUserLink(var p_rJSecGrpUserLink: rtJSecGrpUserLink);
//=============================================================================

//=============================================================================
{}
type rtJSecKey=record
  JSKey_JSecKey_UID           : Uint64;
  JSKey_KeyPub                : ansistring;
  JSKey_KeyPvt                : ansistring;
  JSKey_CreatedBy_JUser_ID    : Uint64;
  JSKey_Created_DT            : string[19];
  JSKey_ModifiedBy_JUser_ID   : Uint64;
  JSKey_Modified_DT           : string[19];
  JSKey_DeletedBy_JUser_ID    : Uint64;
  JSKey_Deleted_DT            : string[19];
  JSKey_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JSecKey(var p_rJSecKey: rtJSecKey);
//=============================================================================

//=============================================================================
{}
type rtJSecPerm=record
  Perm_JSecPerm_UID        : Uint64;
  Perm_Name                : string[32];
  Perm_CreatedBy_JUser_ID  : Uint64;
  Perm_Created_DT          : string[19];
  Perm_ModifiedBy_JUser_ID : Uint64;
  Perm_Modified_DT         : string[19];
  Perm_DeletedBy_JUser_ID  : Uint64;
  Perm_Deleted_DT          : string[19];
  Perm_Deleted_b           : boolean;
  JAS_Row_b                : boolean;
end;
procedure clear_JSecPerm(var p_rJSecPerm: rtJSecPerm);
//=============================================================================

//=============================================================================
{}
type rtJSecPermUserLink=record
  JSPUL_JSecPermUserLink_UID  : Uint64;
  JSPUL_JSecPerm_ID           : Uint64;
  JSPUL_JUser_ID              : Uint64;
  JSPUL_CreatedBy_JUser_ID    : Uint64;
  JSPUL_Created_DT            : string[19];
  JSPUL_ModifiedBy_JUser_ID   : Uint64;
  JSPUL_Modified_DT           : string[19];
  JSPUL_DeletedBy_JUser_ID    : Uint64;
  JSPUL_Deleted_DT            : string[19];
  JSPUL_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JSecPermUserLink(var p_rJSecPermUserLink: rtJSecPermUserLink);
//=============================================================================



//=============================================================================
{}
type rtJSession=REcord
//=============================================================================
  {}
  JSess_JSession_UID        : Uint64;
  JSess_JSessionType_ID     : Uint64;
  JSess_JUser_ID            : Uint64;
  JSess_Connect_DT          : string[19];
  JSess_LastContact_DT      : string[19];
  JSess_IP_ADDR             : string[15];
  JSess_PORT_u              : word;
  JSess_Username            : string[32];
  JSess_JJobQ_ID            : Uint64;
  JSess_HTTP_USER_AGENT     : ansistring;
  JSess_HTTP_ACCEPT         : ansistring;
  JSess_HTTP_ACCEPT_LANGUAGE: ansistring;
  JSess_HTTP_ACCEPT_ENCODING: ansistring;
  JSess_HTTP_CONNECTION     : ansistring;
end;
procedure clear_JSession(var p_rJSession: rtJSession);
//=============================================================================



//=============================================================================
{}
type rtJSessionData=record
  JSDat_JSessionData_UID      : Uint64;
  JSDat_JSession_ID           : Uint64;
  JSDat_Name                  : string[64];
  JSDat_Value                 : ansistring;
  JSDat_CreatedBy_JUser_ID    : Uint64;
  JSDat_Created_DT            : string[19];
end;
procedure clear_JSessionData(var p_rJSessionData: rtJSessionData);
//=============================================================================



//=============================================================================
{}
type rtJSessionType=record
  JSTyp_JSessionType_UID    : Uint64;
  JSTyp_Name                : string[32];
  JSTyp_Desc                : ansistring;
  JSTyp_CreatedBy_JUser_ID  : Uint64;
  JSTyp_Created_DT          : string[19];
  JSTyp_ModifiedBy_JUser_ID : Uint64;
  JSTyp_Modified_DT         : string[19];
  JSTyp_DeletedBy_JUser_ID  : Uint64;
  JSTyp_Deleted_DT          : string[19];
  JSTyp_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JSessionType(var p_rJSessionType: rtJSessionType);
//=============================================================================



//=============================================================================
{}
type rtJSysModule=record
  JSysM_JSysModule_UID      : Uint64;
  JSysM_Name                : string[32];
  JSysM_CreatedBy_JUser_ID  : Uint64;
  JSysM_Created_DT          : string[19];
  JSysM_ModifiedBy_JUser_ID : Uint64;
  JSysM_Modified_DT         : string[19];
  JSysM_DeletedBy_JUser_ID  : Uint64;
  JSysM_Deleted_DT          : string[19];
  JSysM_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JSysModule(var p_rJSysModule: rtJSysModule);
//=============================================================================

//=============================================================================
{}
type rtJTable=record
  JTabl_JTable_UID          : Uint64;
  JTabl_Name                : string[64];
  JTabl_Desc                : ansistring;
  JTabl_JTableType_ID       : Uint64;
  JTabl_JDConnection_ID     : Uint64;
  JTabl_ColumnPrefix        : string[5];
  JTabl_DupeScore_u         : word;
  JTabl_Perm_JColumn_ID     : Uint64;
  JTabl_Owner_Only_b        : boolean;
  JTabl_View_MySQL          : ansistring;
  JTabl_View_MSSQL          : ansistring;
  JTabl_View_MSAccess       : ansistring;
  JTabl_Add_JSecPerm_ID     : Uint64;
  JTabl_Update_JSecPerm_ID  : Uint64;
  JTabl_View_JSecPerm_ID    : Uint64;
  JTabl_Delete_JSecPerm_ID  : Uint64;
  JTabl_CreatedBy_JUser_ID  : Uint64;
  JTabl_Created_DT          : string[19];
  JTabl_ModifiedBy_JUser_ID : Uint64;
  JTabl_Modified_DT         : string[19];
  JTabl_DeletedBy_JUser_ID  : Uint64;
  JTabl_Deleted_DT          : string[19];
  JTabl_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JTable(var p_rJTable: rtJTable);
//=============================================================================

//=============================================================================
{}
type rtJTableType=record
  JTTyp_JTableType_UID      : Uint64;
  JTTyp_Name                : string[32];
  JTTyp_Desc                : ansistring;
  JTTyp_CreatedBy_JUser_ID  : Uint64;
  JTTyp_Created_DT          : string[19];
  JTTyp_ModifiedBy_JUser_ID : Uint64;
  JTTyp_Modified_DT         : string[19];
  JTTyp_DeletedBy_JUser_ID  : Uint64;
  JTTyp_Deleted_DT          : string[19];
  JTTyp_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JTableType(var p_rJTableType: rtJTableType);
//=============================================================================

//=============================================================================
{}
type rtJTask=record
  JTask_JTask_UID                  : Uint64;
  JTask_Name                       : string[64];
  JTask_Desc                       : ansistring;
  JTask_JTaskCategory_ID           : Uint64;
  JTask_JProject_ID                : Uint64;
  JTask_JStatus_ID                 : Uint64;
  JTask_Due_DT                     : string[19];
  JTask_Duration_Minutes_Est       : word;
  JTask_JPriority_ID               : Uint64;
  JTask_Start_DT                   : string[19];
  JTask_Owner_JUser_ID             : Uint64;
  JTask_SendReminder_b             : boolean;
  JTask_ReminderSent_b             : boolean;
  JTask_ReminderSent_DT            : string[19];
  JTask_Remind_DaysAhead_u         : word;
  JTask_Remind_HoursAhead_u        : word;
  JTask_Remind_MinutesAhead_u      : word;
  JTask_Remind_Persistantly_b      : boolean;
  JTask_Progress_PCT_d             : currency;
  JTask_JCase_ID                   : Uint64;
  JTask_Directions_URL             : ansistring;
  JTask_URL                        : ansistring;
  JTask_Milestone_b                : boolean;
  JTask_Budget_d                   : currency;
  JTask_ResolutionNotes            : ansistring;
  JTask_Completed_DT               : string[19];
  JTask_CreatedBy_JUser_ID         : Uint64;
  JTask_Related_JTable_ID          : Uint64;
  JTask_Related_Row_ID             : Uint64;
  JTask_Created_DT                 : string[19];
  JTask_ModifiedBy_JUser_ID        : Uint64;
  JTask_Modified_DT                : string[19];
  JTask_DeletedBy_JUser_ID         : Uint64;
  JTask_Deleted_DT                 : string[19];
  JTask_Deleted_b                  : boolean;
  JAS_Row_b                        : boolean;
end;
procedure clear_JTask(var p_rJTask: rtJTask);
//=============================================================================


//=============================================================================
{}
type rtJTaskCategory=record
  JTCat_JTaskCategory_UID   : Uint64;
  JTCat_Name                : string[32];
  JTCat_Desc                : ansistring;
  JTCat_JCaption_ID         : Uint64;
  JTCat_CreatedBy_JUser_ID  : Uint64;
  JTCat_Created_DT          : string[19];
  JTCat_ModifiedBy_JUser_ID : Uint64;
  JTCat_Modified_DT         : string[19];
  JTCat_DeletedBy_JUser_ID  : Uint64;
  JTCat_Deleted_DT          : string[19];
  JTCat_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JTaskCategory(var p_rJTaskCategory: rtJTaskCategory);
//=============================================================================

//=============================================================================
{}
type rtJStatus=record
  JStat_JStatus_UID         : Uint64;
  JStat_Name                : string[32];
  JStat_Desc                : ansistring;
  JStat_JCaption_ID         : Uint64;
  JStat_CreatedBy_JUser_ID  : Uint64;
  JStat_Created_DT          : string[19];
  JStat_ModifiedBy_JUser_ID : Uint64;
  JStat_Modified_DT         : string[19];
  JStat_DeletedBy_JUser_ID  : Uint64;
  JStat_Deleted_DT          : string[19];
  JStat_Deleted_b           : boolean;
  JAS_Row_b                 : boolean;
end;
procedure clear_JStatus(var p_rJStatus: rtJStatus);
//=============================================================================


//=============================================================================
{}
type rtJTimecard=record
  TMCD_TimeCard_UID                 : Uint64;
  TMCD_Name                         : string[64];
  TMCD_In_DT                        : string[19];
  TMCD_Out_DT                       : string[19];
  TMCD_JNote_Public_ID              : Uint64;
  TMCD_JNote_Internal_ID            : Uint64;
  TMCD_Reference                    : string[64];
  TMCD_JProject_ID                  : Uint64;
  TMCD_JTask_ID                     : Uint64;
  TMCD_Billable_b                   : boolean;
  TMCD_ManualEntry_b                : boolean;
  TMCD_ManualEntry_DT               : string[19];
  TMCD_Exported_b                   : boolean;
  TMCD_Exported_DT                  : string[19];
  TMCD_Uploaded_b                   : boolean;
  TMCD_Uploaded_DT                  : string[19];
  TMCD_PayrateName                  : string[32];
  TMCD_Payrate_d                    : currency;
  TMCD_Expense_b                    : boolean;
  TMCD_Imported_b                   : boolean;
  TMCD_Imported_DT                  : string[19];
  TMCD_BillTo_Entity_ID             : Uint64;
  TMCD_Client_Entity_ID             : Uint64;
  TMCD_Note_Internal                : ansistring; 
  TMCD_Note_Public                  : ansistring;  
  TMCD_Invoice_Sent_b               : boolean;
  TMCD_Invoice_Paid_b               : boolean;
  TMCD_Invoice_No                   : ansistring;
  TMCD_CreatedBy_JUser_ID           : UInt64;
  TMCD_Created_DT                   : string[19];
  TMCD_ModifiedBy_JUser_ID          : UInt64;
  TMCD_Modified_DT                  : string[19];
  TMCD_DeletedBy_JUser_ID           : UInt64;
  TMCD_Deleted_DT                   : string[19];
  TMCD_Deleted_b                    : boolean;
  JAS_Row_b                         : boolean;
end;
procedure clear_JTimecard(var p_rJTimecard: rtJTimecard);
//=============================================================================

//=============================================================================
{}
type rtJTeam=record
  JTeam_JTeam_UID             : Uint64;
  JTeam_Parent_JTeam_ID       : Uint64;
  JTeam_JOrg_ID               : Uint64;
  JTeam_Name                  : string[32];
  JTeam_Desc                  : ansistring;
  JTeam_CreatedBy_JUser_ID    : Uint64;
  JTeam_Created_DT            : string[19];
  JTeam_ModifiedBy_JUser_ID   : Uint64;
  JTeam_Modified_DT           : string[19];
  JTeam_DeletedBy_JUser_ID    : Uint64;
  JTeam_Deleted_DT            : string[19];
  JTeam_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JTeam(var p_rJTeam: rtJTeam);
//=============================================================================

//=============================================================================
{}
type rtJTeamMember=record
  JTMem_JTeamMember_UID       : Uint64;
  JTMem_JTeam_ID              : Uint64;
  JTMem_JPerson_ID            : Uint64;
  JTMem_JOrg_ID               : Uint64;
  JTMem_JUser_ID              : Uint64;
  JTMem_CreatedBy_JUser_ID    : Uint64;
  JTMem_Created_DT            : string[19];
  JTMem_ModifiedBy_JUser_ID   : Uint64;
  JTMem_Modified_DT           : string[19];
  JTMem_DeletedBy_JUser_ID    : Uint64;
  JTMem_Deleted_DT            : string[19];
  JTMem_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JTeamMember(var p_rJTeamMember: rtJTeamMember);
//=============================================================================


//=============================================================================
{}
// because this a test table, the testing fields are still all ansistrings
// just so mods are faster for this fluid table used for development.
type rtJTestOne=record
  JTes1_JTestOne_UID          : Uint64;
  JTes1_Text                  : ansistring;
  JTes1_Boolean_b             : ansistring;
  JTes1_Memo                  : ansistring;
  JTes1_DateTime_DT           : string[19];
  JTes1_Integer_i             : ansistring;
  JTes1_Currency_d            : currency;
  JTes1_Memo2                 : ansistring;
  JTes1_Added_DT              : string[19];
  JTes1_RemoteIP              : ansistring;
  JTes1_RemotePort_u          : ansistring;
  JTes1_CreatedBy_JUser_ID    : Uint64;
  JTes1_Created_DT            : string[19];
  JTes1_ModifiedBy_JUser_ID   : Uint64;
  JTes1_Modified_DT           : string[19];
  JTes1_DeletedBy_JUser_ID    : Uint64;
  JTes1_Deleted_DT            : string[19];
  JTes1_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JTestOne(var p_rJTestOne: rtJTestOne);
//=============================================================================





//=============================================================================
{}
type rtJTheme=record
  Theme_JTheme_UID            : Uint64;
  Theme_Name                  : string[32];
  Theme_Desc                  : ansistring;
  Theme_Template_Header       : ansistring;
  Theme_CreatedBy_JUser_ID    : Uint64;
  Theme_Created_DT            : string[19];
  Theme_ModifiedBy_JUser_ID   : Uint64;
  Theme_Modified_DT           : string[19];
  Theme_DeletedBy_JUser_ID    : Uint64;
  Theme_Deleted_DT            : string[19];
  Theme_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_jtheme(var p_rJTheme: rtJTheme);
//=============================================================================



//=============================================================================
{}
type rtJThemeLight=record
  u8JTheme_UID       : Uint64;
  saName                  : string[32];
  saTemplate_Header       : ansistring;
end;
procedure clear_jthemelight(var p_rJThemeLight: rtJThemeLight);
//=============================================================================




//=============================================================================
{}
type rtJTrak=record
  JTrak_JTrak_UID           : Uint64;
  JTrak_JDConnection_ID     : Uint64;
  JTrak_JSession_ID         : Uint64;
  JTrak_JTable_ID           : Uint64;
  JTrak_Row_ID              : Uint64;
  JTrak_Col_ID              : Uint64;
  JTrak_JUser_ID            : Uint64;
  JTrak_Create_b            : boolean;
  JTrak_Modify_b            : boolean;
  JTrak_Delete_b            : boolean;
  JTrak_When_DT             : string[19];
  JTrak_Before              : ansistring;
  JTrak_After               : ansistring;
  JTrak_SQL                 : ansistring;
end;
procedure clear_JTrak(var p_rJTrak: rtJTrak);
//=============================================================================


//=============================================================================
{}
type rtJUser=Record
//=============================================================================
  {}
  JUser_JUser_UID              : Uint64;
  JUser_Name                   : ansistring;
  JUser_Password               : ansistring;
  JUser_JPerson_ID             : Uint64;
  JUser_Enabled_b              : boolean;
  JUser_Admin_b                : Boolean;
  JUser_Login_First_DT         : string[19];
  JUser_Login_Last_DT          : string[19];
  JUser_Logins_Successful_u    : cardinal;
  JUser_Logins_Failed_u        : cardinal;
  JUser_Password_Changed_DT    : string[19];
  JUser_AllowedSessions_u      : byte;
  JUser_DefaultPage_Login      : ansistring;
  JUser_DefaultPage_Logout     : ansistring;
  JUser_JLanguage_ID           : UInt64;
  JUser_Audit_b                : Boolean;
  JUser_ResetPass_u            : UInt64;
  JUser_JVHost_ID              : Uint64;
  JUser_TotalJetUsers_u        : word;
  JUser_SIP_Exten              : string[32];
  JUser_SIP_Pass               : string[32];
  JUser_Headers_b              : boolean;
  JUser_QuickLinks_b           : boolean;
  JUser_IconTheme              : string[32];
  JUser_Theme                  : string[32];
  JUser_CreatedBy_JUser_ID     : Uint64;
  JUser_Created_DT             : string[19];
  JUser_Background             : ansistring;
  JUser_BackgroundRepeat_b     : boolean;
  JUser_ModifiedBy_JUser_ID    : Uint64;
  JUser_Modified_DT            : string[19];
  JUser_DeletedBy_JUser_ID     : Uint64;
  JUser_Deleted_DT             : string[19];
  JUser_Deleted_b              : boolean;
  JAS_Row_b                    : boolean;
end;
procedure clear_JUser(var p_rJUser: rtJUser);
//=============================================================================



//=============================================================================
{}
type rtJUserPref=record
  UserP_UserPref_UID          : Uint64;
  UserP_Name                  : string[32];
  UserP_Desc                  : ansistring;
  UserP_CreatedBy_JUser_ID    : Uint64;
  UserP_Created_DT            : string[19];
  UserP_ModifiedBy_JUser_ID   : Uint64;
  UserP_Modified_DT           : string[19];
  UserP_DeletedBy_JUser_ID    : Uint64;
  UserP_Deleted_DT            : string[19];
  UserP_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JUserPref(var p_rJUserPref: rtJUserPref);
//=============================================================================

//=============================================================================
{}
type rtJUserPrefLink=record
  UsrPL_UserPrefLink_UID      : Uint64;
  UsrPL_UserPref_ID           : Uint64;
  UsrPL_User_ID               : Uint64;
  UsrPL_Value                 : ansistring;
  UsrPL_CreatedBy_JUser_ID    : Uint64;
  UsrPL_Created_DT            : string[19];
  UsrPL_ModifiedBy_JUser_ID   : Uint64;
  UsrPL_Modified_DT           : string[19];
  UsrPL_DeletedBy_JUser_ID    : Uint64;
  UsrPL_Deleted_DT            : string[19];
  UsrPL_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JUserPrefLink(var p_rJUserPrefLink: rtJUserPrefLink);
//=============================================================================




//=============================================================================
{}
type rtJVHost=record
  //realtime --- not in database
  MenuDL                    : JFC_DL;
  bIdentOk                  : boolean;
  //realtime --- not in database

  //-----New fields
  VHost_AllowRegistration_b    : Boolean;
  VHost_RegisterReqCellPhone_b : boolean;
  VHost_RegisterReqBirthday_b  : boolean;
  //-----New fields


  VHost_JVHost_UID               : UInt64;
  VHost_WebRootDir               : ansistring;
  VHost_ServerName               : string[32];
  VHost_ServerIdent              : string[32];
  VHost_ServerURL                : ansistring; //< this field may seem redundant however, enable-ssl flag isn't usable for deciding http or https here so domain is used to id the vhost but this is the url tossed back to the client all the time.
  VHost_ServerDomain             : string[64];
  VHost_DefaultLanguage          : string[3];
  VHost_DefaultTheme             : string[32];
  VHost_MenuRenderMethod         : word;
  VHOST_DefaultArea              : String[32];//< Name of the DEFAULT AREA template used throughout the system. This is one of this file graphics folks use to toally change how JAs is presented.
  VHOST_DefaultPage              : String[32];//< Name of the DEFAULT PAGE template used throughout the system. PAGE'S can have pultiple sections making development easy - modifify one page and the system chops it up at run time. This is one of this file graphics folks use to toally change how JAs is presented.
  VHOST_DefaultSection           : string[32]; //< Name of the DEFAULT SECTIONAREA of the PAGE template currently being processed. This file can havle multiple sections and the HTMLRIPPER system handles taking your teplate, populating them with date, breaking apart the secion you want to go out andaway it goes. This is one of this file graphics folks use to toally change how JAs is presented.
  VHost_DefaultTop_JMenu_ID      : Uint64;
  VHost_DefaultLoggedInPage      : ansistring;
  VHost_DefaultLoggedOutPage     : ansistring;
  VHost_DataOnRight_b            : boolean;
  VHost_CacheMaxAgeInSeconds     : word;
  VHost_SystemEmailFromAddress   : string[64];
  VHost_SharesDefaultDomain_b    : boolean;
  VHost_DefaultIconTheme         : string[32];
  VHost_DirectoryListing_b       : boolean;
  VHost_FileDir                  : ansistring;
  VHost_AccessLog                : ansistring;
  VHost_ErrorLog                 : ansistring;
  VHost_JDConnection_ID          : Uint64;
  VHost_Enabled_b                : boolean;
  VHost_TemplateDir              : ansistring;
  VHOST_SipURL                   : ansistring;
  { }
  { Directory of the Jegas WebShare Folder - this is where all the graphics,
    icons, documentation, html, css, and more. Generally I don''t recommend
    using this folder for secure information if using this online as its
    generally a public folder.
  }
  { Directory used by the server to avoid unnecessarily calculated and
  rendering pages that a cache makes sense is omproves performance.}

  VHOST_CacheDir                 : ansiString;
  //VHOST _LogDir                   : ansistring;//< Directory where the log files are stored.
  //VHOST _ThemeDir                 : ansistring;//< os location
  { }

  // Web Paths ----------------------------------------------------------------
  VHOST_WebshareDir              : ansistring;
  VHOST_WebShareAlias            : string[32]; //< Aliased Directory "webshare". Usually: jws
  VHOST_JASDirTheme              : ansistring;//< Directory of the themes
  // Web Paths ----------------------------------------------------------------

  VHOST_PasswordKey_u1           : Byte;//< XOR - key for password light encryption. Slated for upgrade

  VHost_LogToDataBase_b          : boolean;//< less overhead if off. convenient if on as web browser error viewing. maybe a special text log viwer for the web would be nice - TODO
  VHost_LogToConsole_b           : boolean;//< If Enabled messages sent to the log file are also sent to the console.
  VHost_LogRequestsToDatabase_b  : boolean;//< highly detailed request or access log - resource instensive. Useful for development and analysis.

  VHost_Headers_b    :boolean;
  VHost_QuickLinks_b :boolean;
  VHost_DefaultDateMask: string[32];
  VHost_Background: ansistring;
  VHost_BackgroundRepeat_b: boolean;

  VHost_CreatedBy_JUser_ID       : Uint64;
  VHost_Created_DT               : string[19];
  VHost_ModifiedBy_JUser_ID      : Uint64;
  VHost_Modified_DT              : string[19];
  VHost_DeletedBy_JUser_ID       : Uint64;
  VHost_Deleted_DT               : string[19];
  VHost_Deleted_b                : boolean;
  JAS_Row_b                      : boolean;

end;
procedure clear_JVHost(var p_rJVHost: rtJVHost);
//=============================================================================





//=============================================================================
{}
type rtJWidget=record
  JWidg_JWidget_UID           : Uint64;
  JWidg_Name                  : string[32];
  JWidg_Procedure             : ansistring;
  JWidg_Desc                  : ansistring;
  JWidg_CreatedBy_JUser_ID    : Uint64;
  JWidg_Created_DT            : string[19];
  JWidg_ModifiedBy_JUser_ID   : Uint64;
  JWidg_Modified_DT           : string[19];
  JWidg_DeletedBy_JUser_ID    : Uint64;
  JWidg_Deleted_DT            : string[19];
  JWidg_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JWidget(var p_rJWidget: rtJWidget);
//=============================================================================

//=============================================================================
{}
type rtJWidgetLink=record
  JWLnk_JWidgetLink_UID       : Uint64;
  JWLnk_JWidget_ID            : Uint64;
  JWLnk_JDType_ID             : Uint64;
  JWLnk_JBlokType_ID          : Uint64;
  JWLnk_JInterface_ID         : Uint64;
  JWLnk_CreatedBy_JUser_ID    : Uint64;
  JWLnk_Created_DT            : string[19];
  JWLnk_ModifiedBy_JUser_ID   : Uint64;
  JWLnk_Modified_DT           : string[19];
  JWLnk_DeletedBy_JUser_ID    : Uint64;
  JWLnk_Deleted_DT            : string[19];
  JWLnk_Deleted_b             : boolean;
  JAS_Row_b                   : boolean;
end;
procedure clear_JWidgetLink(var p_rJWidgetLink: rtJWidgetLink);
//=============================================================================

//=============================================================================
{}
type rtJWorkQueue=record
  JWrkQ_JWorkQueue_UID          : Uint64; //uid
  JWrkQ_JUser_ID                : Uint64; //user who caused job
  JWrkQ_Posted_DT               : string[19]; //when job submitted
  JWrkQ_Started_DT              : string[19]; //when actual processing of job started
  JWrkQ_Finished_DT             : string[19]; //when actual processing of job finished
  JWrkQ_Delivered_DT            : string[19]; //when results of job delivered
  JWrkQ_Job_GUID                : Uint64; // GUID for the job
  JWrkQ_Confirmed_b             : boolean; // boolean indicating job confirmed as successful via GUID exchange
  JWrkQ_Confirmed_DT            : string[19]; // datetime job success confirmed. Note, if this datetime is not null but confirmed = false then this means job failed
  JWrkQ_JobType_ID              : Uint64; // Job Type ID
  JWrkQ_JobDesc                 : ansistring; // Short Description of job (255 char max)
  JWrkQ_Src_JUser_ID            : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_JDConnection_ID     : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_JTable_ID           : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Row_ID              : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Column_ID           : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Data                : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_RemoteIP            : string[15]; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_RemotePort_u        : word; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JUser_ID           : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JDConnection_ID    : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JTable_ID          : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Row_ID             : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Column_ID          : Uint64; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Data               : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_RemoteIP           : string[15]; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_RemotePort_u       : word; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_CreatedBy_JUser_ID      : Uint64;
  JWrkQ_Created_DT              : string[19];
  JWrkQ_ModifiedBy_JUser_ID     : Uint64;
  JWrkQ_Modified_DT             : string[19];
  JWrkQ_DeletedBy_JUser_ID      : Uint64;
  JWrkQ_Deleted_DT              : string[19];
  JWrkQ_Deleted_b               : boolean;
  JAS_Row_b                     : boolean;
end;
procedure clear_JWorkQueue(var p_rJWorkQueue: rtJWorkQueue);
//=============================================================================













//=============================================================================
{}
// Permissions - see jsecperm table
const
  cnPerm_Admin                                 =1211050031076870001;
  cnPerm_API_backupdatabase                    =1608232111146070147;
  cnPerm_API_columnexist                       =1608232111146090149;
  cnPerm_API_copyscreen                        =1608232111146100151;
  cnPerm_API_copysecuritygroup                 =1608232111146110152;
  cnPerm_API_createscreensfortable             =1608232111146170154;
  cnPerm_API_createvirtualhost                 =1608232111146290156;
  cnPerm_API_csvimport                         =1608232111146310157;
  cnPerm_API_csvmapfields                      =1608232111146320158;
  cnPerm_API_csvupload                         =1608232111146320159;
  cnPerm_API_cycleserver                       =1608232111146330160;
  cnPerm_API_databasescrub                     =1608232111146340161;
  cnPerm_API_dbmasterutility                   =1608232111146370165;
  cnPerm_API_dbm_difftool                      =1608232111146350162;
  cnPerm_API_dbm_finddupeuid                   =1608232111146360163;
  cnPerm_API_dbm_learntables                   =1608232111146370164;
  cnPerm_API_debugsession                      =1608232111146380166;
  cnPerm_API_deleterecordlocks                 =1608232111146400167;
  cnPerm_API_deletescreen                      =1608232111146410168;
  cnPerm_API_deletetable                       =1608232111146420169;
  cnPerm_API_diagnostichtmldump                =1608232111146430170;
  cnPerm_API_DiffTool                          =1608241456241230195;
  cnPerm_API_emptycache                        =1608232111146450173;
  cnPerm_API_emptytrash                        =1608232111146480174;
  cnPerm_API_filedownload                      =1608232111146500175;
  cnPerm_API_fileupload                        =1608232111146510176;
  cnPerm_API_FindDupeUID                       =1608241457390290206;
  cnPerm_API_flagjasrow                        =1608232111146520178;
  cnPerm_API_flagjasrowexecute                 =1608232111146530179;
  cnPerm_API_generateseckeys                   =1608232111146540180;
  cnPerm_API_getnotesecure                     =1608232111146550181;
  cnPerm_API_helloworld                        =1608241612101140388;
  cnPerm_API_jassqltool                        =1608232111146580186;
  cnPerm_API_JASSync                           =1608241514362790233;
  cnPerm_API_jas_calendar                      =1608232111146570185;
  cnPerm_API_jcaptionflagorphans               =1608232111146590187;
  cnPerm_API_jetbilling                        =1608232111146600188;
  cnPerm_API_jiconhelper                       =1608232111146600189;
  cnPerm_API_jnoteflagorphans                  =1608232111146610190;
  cnPerm_API_killorphans                       =1608232111146620191;
  cnPerm_API_LearnTables                       =1608241515445420244;
  cnPerm_API_makecolumn                        =1608232111146640194;
  cnPerm_API_maketable                         =1608232111146650195;
  cnPerm_API_menueditor                        =1608232111146650196;
  cnPerm_API_menuexport                        =1608232111146660197;
  cnPerm_API_menuimport                        =1608232111146670198;
  cnPerm_API_merge                             =1608232111146680199;
  cnPerm_API_multipartupload                   =1608232111146700201;
  cnPerm_API_promotelead                       =1608232111146710203;
  cnPerm_API_punklist                          =1608232111146720204;
  cnPerm_API_redirect2google                   =1608232111146730205;
  cnPerm_API_removejet                         =1608232111146750208;
  cnPerm_API_rowexist                          =1608232111146800213;
  cnPerm_API_sendemail                         =1608232111146810215;
  cnPerm_API_settheme                          =1608232111146860220;
  cnPerm_API_shutdownserver                    =1608232111146860221;
  cnPerm_API_syncdbmscolumns                   =1608232111146870222;
  cnPerm_API_syncscreenfields                  =1608232111146880223;
  cnPerm_API_tableexist                        =1608232111146880224;
  cnPerm_API_testbjascreatesession             =1608232111146910226;
  cnPerm_API_testbjaslockrecord                =1608232111146920227;
  cnPerm_API_testbjaspurgeconnections          =1608232111146930228;
  cnPerm_API_testbjaspurgelocks                =1608232111146940229;
  cnPerm_API_testbjasrecordlockvalid           =1608232111146960230;
  cnPerm_API_testbjasremovesession             =1608232111146970231;
  cnPerm_API_testbjasunlockrecord              =1608232111146980232;
  cnPerm_API_testbjasvalidatesession           =1608232111146990233;
  cnPerm_API_testjaslogthis                    =1608232111147000234;
  cnPerm_API_testsajasgetsessionkey            =1608232111147010235;
  cnPerm_API_testsandbox                       =1608232111147020236;
  cnPerm_API_updateorgmembers                  =1608232111147020237;
  cnPerm_API_welcome                           =1608232111147060241;
  cnPerm_API_wipeallrecordlocks                =1608232111147070242;
  cnPerm_API_xmltest                           =1608232111147070243;
  cnPerm_DB_Connection_JAS                     =1211050031076870004;
  cnPerm_DB_Connection_jet01                   =1212110945281440034;
  cnPerm_DB_Connection_jet02                   =1503060436587670044;
  cnPerm_DB_Connection_jet03                   =1503061305367120016;
  cnPerm_DB_Connection_jet04                   =1503070215515700034;
  cnPerm_DB_Connection_jet05                   =1503071641093070013;
  cnPerm_DB_Connection_jet06                   =1503080918561300067;
  cnPerm_DB_Connection_jet07                   =1503081043107360013;
  cnPerm_DB_Connection_jet08                   =1503160832268920014;
  cnPerm_Export_Cases                          =1605121154188960854;
  cnPerm_Export_Companies                      =1605121147251300772;
  cnPerm_Export_Inventory                      =1605121156552450892;
  cnPerm_Export_Invoices                       =1605121156295740885;
  cnPerm_Export_Leads                          =1605121150357290803;
  cnPerm_Export_Menu_Items                     =1605121155456600873;
  cnPerm_Export_People                         =1605121148505080784;
  cnPerm_Export_Projects                       =1605121154446210858;
  cnPerm_Export_Teams                          =1605121150446560806;
  cnPerm_Export_Timecards                      =1605121153203180842;
  cnPerm_Export_Vendors                        =1605121152413940831;
  cnPerm_Icon_Helper                           =1211050031076870008;
  cnPerm_jblog_Add                             =1605161932107760032;
  cnPerm_jblog_Delete                          =1605161932107940035;
  cnPerm_jblog_Edit                            =1605161932107830033;
  cnPerm_jblog_Export                          =1605161932108050037;
  cnPerm_jblog_Modify                          =1605161932108000036;
  cnPerm_jblog_View                            =1605161932107880034;
  cnPerm_jredirect_Add                         =1605140010585260543;
  cnPerm_jredirect_Delete                      =1605140010585450546;
  cnPerm_jredirect_Edit                        =1605140010585340544;
  cnPerm_jredirect_Export                      =1605140010585550548;
  cnPerm_jredirect_Modify                      =1605140010585500547;
  cnPerm_jredirect_View                        =1605140010585400545;
  cnPerm_jredirectlu_Add                       =1605141049147830019;
  cnPerm_jredirectlu_Delete                    =1605141049148040022;
  cnPerm_jredirectlu_Edit                      =1605141049147930020;
  cnPerm_jredirectlu_Export                    =1605141049148150024;
  cnPerm_jredirectlu_Modify                    =1605141049148090023;
  cnPerm_jredirectlu_View                      =1605141049147990021;
  cnPerm_Master_Admin                          =1211050031076870000;
  cnPerm_Modify_jaccesslog_Data                =1605112030210950351;
  cnPerm_Modify_jaccesslog_Search              =1605112030282180354;
  cnPerm_Modify_jetname_Data                   =1605112004218650071;
  cnPerm_Modify_jetname_Search                 =1605112004307820074;
  cnPerm_Modify_jprojectpriority_Data          =1605111930471620719;
  cnPerm_Modify_jprojectpriority_Search        =1605111931114370722;
  cnPerm_Modify_jprojectstatus_Data            =1605111844268640564;
  cnPerm_Modify_jprojectstatus_Search          =1605111843456610552;
  cnPerm_Modify_jrequestlog_Data               =1605111847042540593;
  cnPerm_Modify_jrequestlog_Search             =1605111846561780590;
  cnPerm_Modify_Screen_jadodbms_Data           =1212041011114020001;
  cnPerm_Modify_Screen_jadodbms_Search         =1212041011114040003;
  cnPerm_Modify_Screen_jadodriver_Data         =1212041011114070005;
  cnPerm_Modify_Screen_jadodriver_Search       =1212041011114080007;
  cnPerm_Modify_Screen_jalias_Data             =1212041011114100009;
  cnPerm_Modify_Screen_jalias_Search           =1212041011114110011;
  cnPerm_Modify_Screen_jasident_Data           =1212041011114130013;
  cnPerm_Modify_Screen_jasident_Search         =1212041011114140015;
  cnPerm_Modify_Screen_jblok_Data              =1212041011114160017;
  cnPerm_Modify_Screen_jblok_Search            =1212041011114180019;
  cnPerm_Modify_Screen_jblok_Search2           =1212041011114210021;
  cnPerm_Modify_Screen_jblokbutton_Data        =1212041011114220023;
  cnPerm_Modify_Screen_jblokbutton_Search      =1212041011114240025;
  cnPerm_Modify_Screen_jblokfield_Data         =1212041011114260027;
  cnPerm_Modify_Screen_jblokfield_Search       =1212041011114280029;
  cnPerm_Modify_Screen_jbloktype_Data          =1212041011114290031;
  cnPerm_Modify_Screen_jbloktype_Search        =1212041011114310033;
  cnPerm_Modify_Screen_jbuttontype_Data        =1212041011114330035;
  cnPerm_Modify_Screen_jbuttontype_Search      =1212041011114350037;
  cnPerm_Modify_Screen_jcaption_Data           =1212041011114370039;
  cnPerm_Modify_Screen_jcaption_Search         =1212041011114390041;
  cnPerm_Modify_Screen_jcase_Data              =1212041011114410043;
  cnPerm_Modify_Screen_jcase_Search            =1212041011114430045;
  cnPerm_Modify_Screen_jcasecategory_Data      =1212041011114460047;
  cnPerm_Modify_Screen_jcasecategory_Search    =1212041011114470049;
  cnPerm_Modify_Screen_jcasesource_Data        =1212041011114520055;
  cnPerm_Modify_Screen_jcasesource_Search      =1212041011114530057;
  cnPerm_Modify_Screen_jcasesubject_Data       =1212041011114540059;
  cnPerm_Modify_Screen_jcasesubject_Search     =1212041011114550061;
  cnPerm_Modify_Screen_jcasetype_Data          =1212041011114570063;
  cnPerm_Modify_Screen_jcasetype_Search        =1212041011114580065;
  cnPerm_Modify_Screen_jclickaction_Data       =1212041011114590067;
  cnPerm_Modify_Screen_jclickaction_Search     =1212041011114610069;
  cnPerm_Modify_Screen_jcolumn_Data            =1212041011114620071;
  cnPerm_Modify_Screen_jcolumn_Search          =1212041011114630073;
  cnPerm_Modify_Screen_jdconnection_Data       =1212041011114690083;
  cnPerm_Modify_Screen_jdconnection_Search     =1212041011114710085;
  cnPerm_Modify_Screen_jdebug_Data             =1212041011114720087;
  cnPerm_Modify_Screen_jdebug_Search           =1212041011114740089;
  cnPerm_Modify_Screen_jdtype_Data             =1212041011114750091;
  cnPerm_Modify_Screen_jdtype_Search           =1212041011114770093;
  cnPerm_Modify_Screen_jfile_Data              =1212041011114780095;
  cnPerm_Modify_Screen_jfile_Search            =1212041011114800097;
  cnPerm_Modify_Screen_jfiltersave_Data        =1212041011114810099;
  cnPerm_Modify_Screen_jfiltersave_Search      =1212041011114830101;
  cnPerm_Modify_Screen_jfiltersavedef_Data     =1212041011114850103;
  cnPerm_Modify_Screen_jfiltersavedef_Search   =1212041011114870105;
  cnPerm_Modify_Screen_jiconcontext_Data       =1212041011114880107;
  cnPerm_Modify_Screen_jiconcontext_Search     =1212041011114900109;
  cnPerm_Modify_Screen_jiconmaster_Data        =1212041011114910111;
  cnPerm_Modify_Screen_jiconmaster_Search      =1212041011114920113;
  cnPerm_Modify_Screen_jindexfile_Data         =1212041011114940115;
  cnPerm_Modify_Screen_jindexfile_Search       =1212041011114950117;
  cnPerm_Modify_Screen_jindustry_Data          =1212041011114970119;
  cnPerm_Modify_Screen_jindustry_Search        =1212041011114980121;
  cnPerm_Modify_Screen_jinstalled_Data         =1212041011114990123;
  cnPerm_Modify_Screen_jinstalled_Search       =1212041011115000125;
  cnPerm_Modify_Screen_jinterface_Data         =1212041011115010127;
  cnPerm_Modify_Screen_jinterface_Search       =1212041011115030129;
  cnPerm_Modify_Screen_jinvoice_Data           =1212041011115040131;
  cnPerm_Modify_Screen_jinvoice_Search         =1212041011115050133;
  cnPerm_Modify_Screen_jinvoicelines_Data      =1212041011115060135;
  cnPerm_Modify_Screen_jinvoicelines_Search    =1212041011115080137;
  cnPerm_Modify_Screen_jiplist_Data            =1212041011115090139;
  cnPerm_Modify_Screen_jiplist_Search          =1212041011115110141;
  cnPerm_Modify_Screen_jjobq_Data              =1212041011115130143;
  cnPerm_Modify_Screen_jjobq_Search            =1212041011115160145;
  cnPerm_Modify_Screen_jjobtype_Data           =1212041011115170147;
  cnPerm_Modify_Screen_jjobtype_Search         =1212041011115190149;
  cnPerm_Modify_Screen_jlanguage_Data          =1212041011115200151;
  cnPerm_Modify_Screen_jlanguage_Search        =1212041011115220153;
  cnPerm_Modify_Screen_jlead_Data              =1212041011115230155;
  cnPerm_Modify_Screen_jlead_Search            =1212041011115260157;
  cnPerm_Modify_Screen_jleadsource_Data        =1212041011115270159;
  cnPerm_Modify_Screen_jleadsource_Search      =1212041011115290161;
  cnPerm_Modify_Screen_jlock_Data              =1212041011115310163;
  cnPerm_Modify_Screen_jlock_Search            =1212041011115320165;
  cnPerm_Modify_Screen_jlog_Data               =1212041011115330167;
  cnPerm_Modify_Screen_jlog_Search             =1212041011115350169;
  cnPerm_Modify_Screen_jlogtype_Data           =1212041011115360171;
  cnPerm_Modify_Screen_jlogtype_Search         =1212041011115380173;
  cnPerm_Modify_Screen_jlookup_Data            =1212041011115400175;
  cnPerm_Modify_Screen_jlookup_Search          =1212041011115410177;
  cnPerm_Modify_Screen_jmail_Data              =1212041011115420179;
  cnPerm_Modify_Screen_jmail_Search            =1212041011115440181;
  cnPerm_Modify_Screen_jmenu_Data              =1212041011115450183;
  cnPerm_Modify_Screen_jmenu_Search            =1212041011115460185;
  cnPerm_Modify_Screen_jmime_Data              =1212041011115480187;
  cnPerm_Modify_Screen_jmime_Search            =1212041011115490189;
  cnPerm_Modify_Screen_jmodc_Data              =1212041011115510191;
  cnPerm_Modify_Screen_jmodc_Search            =1212041011115520193;
  cnPerm_Modify_Screen_jmodule_Data            =1212041011115540195;
  cnPerm_Modify_Screen_jmodule_Search          =1212041011115560197;
  cnPerm_Modify_Screen_jmoduleconfig_Data      =1212041011115570199;
  cnPerm_Modify_Screen_jmoduleconfig_Search    =1212041011115580201;
  cnPerm_Modify_Screen_jmodulesetting_Data     =1212041011115600203;
  cnPerm_Modify_Screen_jmodulesetting_Search   =1212041011115610205;
  cnPerm_Modify_Screen_jnote_Data              =1212041011115630207;
  cnPerm_Modify_Screen_jnote_Search            =1212041011115650209;
  cnPerm_Modify_Screen_jorg_Data               =1212041011114640075;
  cnPerm_Modify_Screen_jorg_Search             =1212041011114660077;
  cnPerm_Modify_Screen_jorgpers_Data           =1212041011114670079;
  cnPerm_Modify_Screen_jorgpers_Search         =1212041011114680081;
  cnPerm_Modify_Screen_jpassword_Data          =1212041011115670211;
  cnPerm_Modify_Screen_jpassword_Search        =1212041011115690213;
  cnPerm_Modify_Screen_jperson_Data            =1212041011115700215;
  cnPerm_Modify_Screen_jperson_Search          =1212041011115720217;
  cnPerm_Modify_Screen_jpersonskill_Data       =1212041011115730219;
  cnPerm_Modify_Screen_jpersonskill_Search     =1212041011115740221;
  cnPerm_Modify_Screen_jprinter_Data           =1212041011115760223;
  cnPerm_Modify_Screen_jprinter_Search         =1212041011115770225;
  cnPerm_Modify_Screen_jpriority_Data          =1212041011115780227;
  cnPerm_Modify_Screen_jpriority_Search        =1212041011115790229;
  cnPerm_Modify_Screen_jproduct_Data           =1212041011115810231;
  cnPerm_Modify_Screen_jproduct_Search         =1212041011115820233;
  cnPerm_Modify_Screen_jproductgrp_Data        =1212041011115830235;
  cnPerm_Modify_Screen_jproductgrp_Search      =1212041011115840237;
  cnPerm_Modify_Screen_jproductqty_Data        =1212041011115860239;
  cnPerm_Modify_Screen_jproductqty_Search      =1212041011115870241;
  cnPerm_Modify_Screen_jproject_Data           =1212041011115880243;
  cnPerm_Modify_Screen_jproject_Search         =1212041011115900245;
  cnPerm_Modify_Screen_jprojectcategory_Data   =1212041011115910247;
  cnPerm_Modify_Screen_jprojectcategory_Search =1212041011115920249;
  cnPerm_Modify_Screen_jquicklink_Data         =1212041011115980255;
  cnPerm_Modify_Screen_jquicklink_Search       =1212041011116000257;
  cnPerm_Modify_Screen_jquicknote_Data         =1212041011116010259;
  cnPerm_Modify_Screen_jquicknote_Search       =1212041011116030261;
  cnPerm_Modify_Screen_jscreen_Data            =1212041011116050263;
  cnPerm_Modify_Screen_jscreen_Search          =1212041011116070265;
  cnPerm_Modify_Screen_jscreentype_Data        =1212041011116090267;
  cnPerm_Modify_Screen_jscreentype_Search      =1212041011116100269;
  cnPerm_Modify_Screen_jsecgrp_Data            =1212041011116110271;
  cnPerm_Modify_Screen_jsecgrp_Search          =1212041011116130273;
  cnPerm_Modify_Screen_jsecgrplink_Data        =1212041011116140275;
  cnPerm_Modify_Screen_jsecgrplink_Search      =1212041011116150277;
  cnPerm_Modify_Screen_jsecgrpuserlink_Data    =1212041011116170279;
  cnPerm_Modify_Screen_jsecgrpuserlink_Search  =1212041011116180281;
  cnPerm_Modify_Screen_jseckey_Data            =1212041011116190283;
  cnPerm_Modify_Screen_jseckey_Search          =1212041011116210285;
  cnPerm_Modify_Screen_jsecperm_Data           =1212041011116220287;
  cnPerm_Modify_Screen_jsecperm_Search         =1212041011116230289;
  cnPerm_Modify_Screen_jsecpermuserlink_Data   =1212041011116240291;
  cnPerm_Modify_Screen_jsecpermuserlink_Search =1212041011116260293;
  cnPerm_Modify_Screen_jsession_Data           =1212041011116270295;
  cnPerm_Modify_Screen_jsession_Search         =1212041011116280297;
  cnPerm_Modify_Screen_jsessiondata_Data       =1212041011116300299;
  cnPerm_Modify_Screen_jsessiondata_Search     =1212041011116320301;
  cnPerm_Modify_Screen_jsessiontype_Data       =1212041011116330303;
  cnPerm_Modify_Screen_jsessiontype_Search     =1212041011116350305;
  cnPerm_Modify_Screen_jskill_Data             =1212041011116360307;
  cnPerm_Modify_Screen_jskill_Search           =1212041011116380309;
  cnPerm_Modify_Screen_jstatus_Data            =1212041011116390311;
  cnPerm_Modify_Screen_jstatus_Search          =1212041011116400313;
  cnPerm_Modify_Screen_jsync_Data              =1212041011116420315;
  cnPerm_Modify_Screen_jsync_Search            =1212041011116440317;
  cnPerm_Modify_Screen_jsysmodule_Data         =1212041011116460319;
  cnPerm_Modify_Screen_jsysmodule_Search       =1212041011116480321;
  cnPerm_Modify_Screen_jsysmodulelink_Data     =1212041011116490323;
  cnPerm_Modify_Screen_jsysmodulelink_Search   =1212041011116500325;
  cnPerm_Modify_Screen_jtable_Data             =1212041011116510327;
  cnPerm_Modify_Screen_jtable_Search           =1212041011116530329;
  cnPerm_Modify_Screen_jtabletype_Data         =1212041011116540331;
  cnPerm_Modify_Screen_jtabletype_Search       =1212041011116550333;
  cnPerm_Modify_Screen_jtask_Data              =1212041011116570335;
  cnPerm_Modify_Screen_jtask_Search            =1212041011116580337;
  cnPerm_Modify_Screen_jtaskcategory_Data      =1212041011116590339;
  cnPerm_Modify_Screen_jtaskcategory_Search    =1212041011116600341;
  cnPerm_Modify_Screen_jteam_Data              =1212041011116620343;
  cnPerm_Modify_Screen_jteam_Search            =1212041011116630345;
  cnPerm_Modify_Screen_jteammember_Data        =1212041011116650347;
  cnPerm_Modify_Screen_jteammember_Search      =1212041011116660349;
  cnPerm_Modify_Screen_jtestone_Data           =1212041011116670351;
  cnPerm_Modify_Screen_jtestone_Search         =1212041011116690353;
  cnPerm_Modify_Screen_jtheme_Data             =1212041011116700355;
  cnPerm_Modify_Screen_jtheme_Search           =1212041011116740357;
  cnPerm_Modify_Screen_jthemeicon_Data         =1212041011116760359;
  cnPerm_Modify_Screen_jthemeicon_Search       =1212041011116780361;
  cnPerm_Modify_Screen_jtimecard_Data          =1212041011116790363;
  cnPerm_Modify_Screen_jtimecard_Search        =1212041011116810365;
  cnPerm_Modify_Screen_jtrak_Data              =1212041011116820367;
  cnPerm_Modify_Screen_jtrak_Search            =1212041011116840369;
  cnPerm_Modify_Screen_juser_Data              =1212041011116860371;
  cnPerm_Modify_Screen_juser_Search            =1212041011116880373;
  cnPerm_Modify_Screen_juserpref_Data          =1212041011116900375;
  cnPerm_Modify_Screen_juserpref_Search        =1212041011116910377;
  cnPerm_Modify_Screen_juserpreflink_Data      =1212041011116920379;
  cnPerm_Modify_Screen_juserpreflink_Search    =1212041011116940381;
  cnPerm_Modify_Screen_jvhost_Data             =1212041011116960383;
  cnPerm_Modify_Screen_jvhost_Search           =1212041011116970385;
  cnPerm_Modify_Screen_jwidget_Data            =1212041011116980387;
  cnPerm_Modify_Screen_jwidget_Search          =1212041011117000389;
  cnPerm_Modify_Screen_view_case_Data          =1212041011117040395;
  cnPerm_Modify_Screen_view_case_Search        =1212041011117050397;
  cnPerm_Modify_Screen_view_inventory_Data     =1212041011117090403;
  cnPerm_Modify_Screen_view_inventory_Search   =1212041011117110405;
  cnPerm_Modify_Screen_view_invoice_Data       =1212041011117120407;
  cnPerm_Modify_Screen_view_invoice_Search     =1212041011117140409;
  cnPerm_Modify_Screen_view_lead_Data          =1212041011117160411;
  cnPerm_Modify_Screen_view_lead_Search        =1212041011117180413;
  cnPerm_Modify_Screen_view_menu_Data          =1212041011117190415;
  cnPerm_Modify_Screen_view_menu_Search        =1212041011117210417;
  cnPerm_Modify_Screen_view_org_Data           =1212041011117070399;
  cnPerm_Modify_Screen_view_org_Search         =1212041011117080401;
  cnPerm_Modify_Screen_view_person_Data        =1212041011117220419;
  cnPerm_Modify_Screen_view_person_Search      =1212041011117240421;
  cnPerm_Modify_Screen_view_project_Data       =1212041011117260423;
  cnPerm_Modify_Screen_view_project_Search     =1212041011117280425;
  cnPerm_Modify_Screen_view_task_Data          =1212041011117300427;
  cnPerm_Modify_Screen_view_task_Search        =1212041011117310429;
  cnPerm_Modify_Screen_view_team_Data          =1212041011117330431;
  cnPerm_Modify_Screen_view_team_Search        =1212041011117340433;
  cnPerm_Modify_Screen_view_time_Data          =1212041011117360435;
  cnPerm_Modify_Screen_view_time_Search        =1212041011117370437;
  cnPerm_Modify_Screen_view_vendor_Data        =1212041011117380439;
  cnPerm_Modify_Screen_view_vendor_Search      =1212041011117400441;
  cnPerm_Modify_Screen_vrevent_Data            =1212041011117410443;
  cnPerm_Modify_Screen_vrevent_Search          =1212041011117420445;
  cnPerm_Modify_Screen_vrvideo_Data            =1212041011117440447;
  cnPerm_Modify_Screen_vrvideo_Search          =1212041011117450449;
  cnPerm_Screen_jaccesslog_Data                =1605112030078020348;
  cnPerm_Screen_jaccesslog_Search              =1605112029394220345;
  cnPerm_Screen_jadodbms_Data                  =1212041011114010000;
  cnPerm_Screen_jadodbms_Search                =1212041011114030002;
  cnPerm_Screen_jadodriver_Data                =1212041011114050004;
  cnPerm_Screen_jadodriver_Search              =1212041011114070006;
  cnPerm_Screen_jalias_Data                    =1212041011114090008;
  cnPerm_Screen_jalias_Search                  =1212041011114110010;
  cnPerm_Screen_jasident_Data                  =1212041011114120012;
  cnPerm_Screen_jasident_Search                =1212041011114140014;
  cnPerm_Screen_jblok_Data                     =1212041011114150016;
  cnPerm_Screen_jblok_Search                   =1212041011114170018;
  cnPerm_Screen_jblok_Search2                  =1212041011114180020;
  cnPerm_Screen_jblokbutton_Data               =1212041011114220022;
  cnPerm_Screen_jblokbutton_Search             =1212041011114230024;
  cnPerm_Screen_jblokfield_Data                =1212041011114250026;
  cnPerm_Screen_jblokfield_Search              =1212041011114270028;
  cnPerm_Screen_jbloktype_Data                 =1212041011114280030;
  cnPerm_Screen_jbloktype_Search               =1212041011114310032;
  cnPerm_Screen_jbuttontype_Data               =1212041011114320034;
  cnPerm_Screen_jbuttontype_Search             =1212041011114340036;
  cnPerm_Screen_jcaption_Data                  =1212041011114360038;
  cnPerm_Screen_jcaption_Search                =1212041011114380040;
  cnPerm_Screen_jcase_Data                     =1212041011114400042;
  cnPerm_Screen_jcase_Search                   =1212041011114420044;
  cnPerm_Screen_jcasecategory_Data             =1212041011114440046;
  cnPerm_Screen_jcasecategory_Search           =1212041011114470048;
  cnPerm_Screen_jcasepriority_Data             =1605111827207940411;
  cnPerm_Screen_jcasepriority_Search           =1605111827134450408;
  cnPerm_Screen_jcasesource_Data               =1212041011114510054;
  cnPerm_Screen_jcasesource_Search             =1212041011114520056;
  cnPerm_Screen_jcasesubject_Data              =1212041011114540058;
  cnPerm_Screen_jcasesubject_Search            =1212041011114550060;
  cnPerm_Screen_jcasetype_Data                 =1212041011114560062;
  cnPerm_Screen_jcasetype_Search               =1212041011114570064;
  cnPerm_Screen_jclickaction_Data              =1212041011114590066;
  cnPerm_Screen_jclickaction_Search            =1212041011114600068;
  cnPerm_Screen_jcolumn_Data                   =1212041011114610070;
  cnPerm_Screen_jcolumn_Search                 =1212041011114620072;
  cnPerm_Screen_jdconnection_Data              =1212041011114690082;
  cnPerm_Screen_jdconnection_Search            =1212041011114700084;
  cnPerm_Screen_jdebug_Data                    =1212041011114710086;
  cnPerm_Screen_jdebug_Search                  =1212041011114730088;
  cnPerm_Screen_jdtype_Data                    =1212041011114750090;
  cnPerm_Screen_jdtype_Search                  =1212041011114760092;
  cnPerm_Screen_jetname_Data                   =1605112004152210068;
  cnPerm_Screen_jetname_Search                 =1605112004044050065;
  cnPerm_Screen_jfile_Data                     =1212041011114780094;
  cnPerm_Screen_jfile_Search                   =1212041011114790096;
  cnPerm_Screen_jfiltersave_Data               =1212041011114810098;
  cnPerm_Screen_jfiltersave_Search             =1212041011114820100;
  cnPerm_Screen_jfiltersavedef_Data            =1212041011114840102;
  cnPerm_Screen_jfiltersavedef_Search          =1212041011114860104;
  cnPerm_Screen_jhelp_Data                     =1605111831432290448;
  cnPerm_Screen_jhelp_Search                   =1605111831495820452;
  cnPerm_Screen_jiconcontext_Data              =1212041011114870106;
  cnPerm_Screen_jiconcontext_Search            =1212041011114890108;
  cnPerm_Screen_jiconmaster_Data               =1212041011114900110;
  cnPerm_Screen_jiconmaster_Search             =1212041011114920112;
  cnPerm_Screen_jindexfile_Data                =1212041011114930114;
  cnPerm_Screen_jindexfile_Search              =1212041011114950116;
  cnPerm_Screen_jindustry_Data                 =1212041011114960118;
  cnPerm_Screen_jindustry_Search               =1212041011114970120;
  cnPerm_Screen_jinstalled_Data                =1212041011114980122;
  cnPerm_Screen_jinstalled_Search              =1212041011115000124;
  cnPerm_Screen_jinterface_Data                =1212041011115010126;
  cnPerm_Screen_jinterface_Search              =1212041011115020128;
  cnPerm_Screen_jinvoice_Data                  =1212041011115030130;
  cnPerm_Screen_jinvoice_Search                =1212041011115050132;
  cnPerm_Screen_jinvoicelines_Data             =1212041011115060134;
  cnPerm_Screen_jinvoicelines_Search           =1212041011115070136;
  cnPerm_Screen_jiplist_Data                   =1212041011115090138;
  cnPerm_Screen_jiplist_Search                 =1212041011115100140;
  cnPerm_Screen_jiplistlu_Data                 =1605111834358800474;
  cnPerm_Screen_jiplistlu_Search               =1605111834290270471;
  cnPerm_Screen_jjobq_Data                     =1212041011115120142;
  cnPerm_Screen_jjobq_Search                   =1212041011115150144;
  cnPerm_Screen_jjobtype_Data                  =1212041011115170146;
  cnPerm_Screen_jjobtype_Search                =1212041011115180148;
  cnPerm_Screen_jlanguage_Data                 =1212041011115200150;
  cnPerm_Screen_jlanguage_Search               =1212041011115210152;
  cnPerm_Screen_jlead_Data                     =1212041011115220154;
  cnPerm_Screen_jlead_Search                   =1212041011115240156;
  cnPerm_Screen_jleadsource_Data               =1212041011115270158;
  cnPerm_Screen_jleadsource_Search             =1212041011115280160;
  cnPerm_Screen_jlock_Data                     =1212041011115300162;
  cnPerm_Screen_jlock_Search                   =1212041011115310164;
  cnPerm_Screen_jlog_Data                      =1212041011115330166;
  cnPerm_Screen_jlog_Search                    =1212041011115340168;
  cnPerm_Screen_jlogtype_Data                  =1212041011115350170;
  cnPerm_Screen_jlogtype_Search                =1212041011115380172;
  cnPerm_Screen_jlookup_Data                   =1212041011115390174;
  cnPerm_Screen_jlookup_Search                 =1212041011115400176;
  cnPerm_Screen_jmail_Data                     =1212041011115420178;
  cnPerm_Screen_jmail_Search                   =1212041011115430180;
  cnPerm_Screen_jmenu_Data                     =1212041011115440182;
  cnPerm_Screen_jmenu_Search                   =1212041011115460184;
  cnPerm_Screen_jmime_Data                     =1212041011115470186;
  cnPerm_Screen_jmime_Search                   =1212041011115480188;
  cnPerm_Screen_jmodc_Data                     =1212041011115500190;
  cnPerm_Screen_jmodc_Search                   =1212041011115520192;
  cnPerm_Screen_jmodule_Data                   =1212041011115540194;
  cnPerm_Screen_jmodule_Search                 =1212041011115550196;
  cnPerm_Screen_jmoduleconfig_Data             =1212041011115560198;
  cnPerm_Screen_jmoduleconfig_Search           =1212041011115580200;
  cnPerm_Screen_jmodulesetting_Data            =1212041011115590202;
  cnPerm_Screen_jmodulesetting_Search          =1212041011115610204;
  cnPerm_Screen_jnote_Data                     =1212041011115620206;
  cnPerm_Screen_jnote_Search                   =1212041011115640208;
  cnPerm_Screen_jorg_Data                      =1212041011114640074;
  cnPerm_Screen_jorg_Search                    =1212041011114650076;
  cnPerm_Screen_jorgpers_Data                  =1212041011114660078;
  cnPerm_Screen_jorgpers_Search                =1212041011114670080;
  cnPerm_Screen_jpassword_Data                 =1212041011115660210;
  cnPerm_Screen_jpassword_Search               =1212041011115680212;
  cnPerm_Screen_jperson_Data                   =1212041011115700214;
  cnPerm_Screen_jperson_Search                 =1212041011115710216;
  cnPerm_Screen_jpersonskill_Data              =1212041011115720218;
  cnPerm_Screen_jpersonskill_Search            =1212041011115740220;
  cnPerm_Screen_jprinter_Data                  =1212041011115750222;
  cnPerm_Screen_jprinter_Search                =1212041011115760224;
  cnPerm_Screen_jpriority_Data                 =1212041011115770226;
  cnPerm_Screen_jpriority_Search               =1212041011115790228;
  cnPerm_Screen_jproduct_Data                  =1212041011115800230;
  cnPerm_Screen_jproduct_Search                =1212041011115810232;
  cnPerm_Screen_jproductgrp_Data               =1212041011115820234;
  cnPerm_Screen_jproductgrp_Search             =1212041011115840236;
  cnPerm_Screen_jproductqty_Data               =1212041011115850238;
  cnPerm_Screen_jproductqty_Search             =1212041011115860240;
  cnPerm_Screen_jproject_Data                  =1212041011115880242;
  cnPerm_Screen_jproject_Search                =1212041011115890244;
  cnPerm_Screen_jprojectcategory_Data          =1212041011115900246;
  cnPerm_Screen_jprojectcategory_Search        =1212041011115920248;
  cnPerm_Screen_jprojectpriority_Data          =1605111928475470702;
  cnPerm_Screen_jprojectpriority_Search        =1605111928379390699;
  cnPerm_Screen_jprojectstatus_Data            =1605111843258670545;
  cnPerm_Screen_jprojectstatus_Search          =1605111843175520542;
  cnPerm_Screen_jquicklink_Data                =1212041011115970254;
  cnPerm_Screen_jquicklink_Search              =1212041011115990256;
  cnPerm_Screen_jquicknote_Data                =1212041011116000258;
  cnPerm_Screen_jquicknote_Search              =1212041011116020260;
  cnPerm_Screen_jrequestlog_Data               =1605111846352850584;
  cnPerm_Screen_jrequestlog_Search             =1605111846470670587;
  cnPerm_Screen_jscreen_Data                   =1212041011116040262;
  cnPerm_Screen_jscreen_Search                 =1212041011116060264;
  cnPerm_Screen_jscreentype_Data               =1212041011116080266;
  cnPerm_Screen_jscreentype_Search             =1212041011116090268;
  cnPerm_Screen_jsecgrp_Data                   =1212041011116110270;
  cnPerm_Screen_jsecgrp_Search                 =1212041011116120272;
  cnPerm_Screen_jsecgrplink_Data               =1212041011116130274;
  cnPerm_Screen_jsecgrplink_Search             =1212041011116150276;
  cnPerm_Screen_jsecgrpuserlink_Data           =1212041011116160278;
  cnPerm_Screen_jsecgrpuserlink_Search         =1212041011116170280;
  cnPerm_Screen_jseckey_Data                   =1212041011116190282;
  cnPerm_Screen_jseckey_Search                 =1212041011116200284;
  cnPerm_Screen_jsecperm_Data                  =1212041011116210286;
  cnPerm_Screen_jsecperm_Search                =1212041011116230288;
  cnPerm_Screen_jsecpermuserlink_Data          =1212041011116240290;
  cnPerm_Screen_jsecpermuserlink_Search        =1212041011116250292;
  cnPerm_Screen_jsession_Data                  =1212041011116260294;
  cnPerm_Screen_jsession_Search                =1212041011116280296;
  cnPerm_Screen_jsessiondata_Data              =1212041011116290298;
  cnPerm_Screen_jsessiondata_Search            =1212041011116310300;
  cnPerm_Screen_jsessiontype_Data              =1212041011116320302;
  cnPerm_Screen_jsessiontype_Search            =1212041011116340304;
  cnPerm_Screen_jskill_Data                    =1212041011116360306;
  cnPerm_Screen_jskill_Search                  =1212041011116370308;
  cnPerm_Screen_jstatus_Data                   =1212041011116380310;
  cnPerm_Screen_jstatus_Search                 =1212041011116400312;
  cnPerm_Screen_jsync_Data                     =1212041011116410314;
  cnPerm_Screen_jsync_Search                   =1212041011116420316;
  cnPerm_Screen_jsysmodule_Data                =1212041011116450318;
  cnPerm_Screen_jsysmodule_Search              =1212041011116470320;
  cnPerm_Screen_jsysmodulelink_Data            =1212041011116480322;
  cnPerm_Screen_jsysmodulelink_Search          =1212041011116500324;
  cnPerm_Screen_jtable_Data                    =1212041011116510326;
  cnPerm_Screen_jtable_Search                  =1212041011116520328;
  cnPerm_Screen_jtabletype_Data                =1212041011116530330;
  cnPerm_Screen_jtabletype_Search              =1212041011116550332;
  cnPerm_Screen_jtask_Data                     =1212041011116560334;
  cnPerm_Screen_jtask_Search                   =1212041011116570336;
  cnPerm_Screen_jtaskcategory_Data             =1212041011116580338;
  cnPerm_Screen_jtaskcategory_Search           =1212041011116600340;
  cnPerm_Screen_jteam_Data                     =1212041011116610342;
  cnPerm_Screen_jteam_Search                   =1212041011116630344;
  cnPerm_Screen_jteammember_Data               =1212041011116640346;
  cnPerm_Screen_jteammember_Search             =1212041011116650348;
  cnPerm_Screen_jtestone_Data                  =1212041011116670350;
  cnPerm_Screen_jtestone_Search                =1212041011116680352;
  cnPerm_Screen_jtheme_Data                    =1212041011116690354;
  cnPerm_Screen_jthemecolor_Search             =1212041011116730356;
  cnPerm_Screen_jthemeicon_Data                =1212041011116750358;
  cnPerm_Screen_jthemeicon_Search              =1212041011116770360;
  cnPerm_Screen_jtimecard_Data                 =1212041011116780362;
  cnPerm_Screen_jtimecard_Search               =1212041011116800364;
  cnPerm_Screen_jtrak_Data                     =1212041011116810366;
  cnPerm_Screen_jtrak_Search                   =1212041011116830368;
  cnPerm_Screen_juser_Data                     =1212041011116850370;
  cnPerm_Screen_juser_Search                   =1212041011116870372;
  cnPerm_Screen_juserpref_Data                 =1212041011116890374;
  cnPerm_Screen_juserpref_Search               =1212041011116900376;
  cnPerm_Screen_juserpreflink_Data             =1212041011116920378;
  cnPerm_Screen_juserpreflink_Search           =1212041011116930380;
  cnPerm_Screen_jvhost_Data                    =1212041011116950382;
  cnPerm_Screen_jvhost_Search                  =1212041011116960384;
  cnPerm_Screen_jwidget_Data                   =1212041011116980386;
  cnPerm_Screen_jwidget_Search                 =1212041011116990388;
  cnPerm_Screen_view_case_Data                 =1212041011117030394;
  cnPerm_Screen_view_case_Search               =1212041011117050396;
  cnPerm_Screen_view_inventory_Data            =1212041011117090402;
  cnPerm_Screen_view_inventory_Search          =1212041011117100404;
  cnPerm_Screen_view_invoice_Data              =1212041011117120406;
  cnPerm_Screen_view_invoice_Search            =1212041011117130408;
  cnPerm_Screen_view_lead_Data                 =1212041011117150410;
  cnPerm_Screen_view_lead_Search               =1212041011117170412;
  cnPerm_Screen_view_menu_Data                 =1212041011117180414;
  cnPerm_Screen_view_menu_Search               =1212041011117200416;
  cnPerm_Screen_view_org_Data                  =1212041011117060398;
  cnPerm_Screen_view_org_Search                =1212041011117070400;
  cnPerm_Screen_view_person_Data               =1212041011117210418;
  cnPerm_Screen_view_person_Search             =1212041011117230420;
  cnPerm_Screen_view_project_Data              =1212041011117250422;
  cnPerm_Screen_view_project_Search            =1212041011117270424;
  cnPerm_Screen_view_task_Data                 =1212041011117290426;
  cnPerm_Screen_view_task_Search               =1212041011117310428;
  cnPerm_Screen_view_team_Data                 =1212041011117320430;
  cnPerm_Screen_view_team_Search               =1212041011117330432;
  cnPerm_Screen_view_time_Data                 =1212041011117350434;
  cnPerm_Screen_view_time_Search               =1212041011117360436;
  cnPerm_Screen_view_vendor_Data               =1212041011117380438;
  cnPerm_Screen_view_vendor_Search             =1212041011117390440;
  cnPerm_Screen_vrevent_Data                   =1212041011117400442;
  cnPerm_Screen_vrevent_Search                 =1212041011117420444;
  cnPerm_Screen_vrvideo_Data                   =1212041011117430446;
  cnPerm_Screen_vrvideo_Search                 =1212041011117450448;
  cnPerm_Send_Email                            =1607122116580710982;
  cnPerm_Shutdown_Server                       =1211050031076870003;
  cnPerm_SQL_Tool                              =1211050031076870005;
  cnPerm_Squadron_Leader_Team                  =1503061331026150006;
  cnPerm_Suicide                               =1609031303553770132;
  cnPerm_System_DBM_FindDupeUID                =1605121143417040747;
  cnPerm_System_Update_Organization_Members    =1605121141451820722;
  cnPerm_Table_Add_jaccesslog                  =1602232217233670014;
  cnPerm_Table_Add_jadodbms                    =1212041011117470450;
  cnPerm_Table_Add_jadodriver                  =1212041011117510454;
  cnPerm_Table_Add_jalias                      =1212041011117540458;
  cnPerm_Table_Add_jasident                    =1212041011117600462;
  cnPerm_Table_Add_jblok                       =1212041011117620466;
  cnPerm_Table_Add_jblokbutton                 =1212041011117670470;
  cnPerm_Table_Add_jblokfield                  =1212041011117700474;
  cnPerm_Table_Add_jbloktype                   =1212041011117730478;
  cnPerm_Table_Add_jbuttontype                 =1212041011117750482;
  cnPerm_Table_Add_jcaption                    =1212041011117780486;
  cnPerm_Table_Add_jcase                       =1212041011117800490;
  cnPerm_Table_Add_jcasecategory               =1212041011117830494;
  cnPerm_Table_Add_jcasesource                 =1212041011117860498;
  cnPerm_Table_Add_jcasesubject                =1212041011117880502;
  cnPerm_Table_Add_jcasetype                   =1212041011117910506;
  cnPerm_Table_Add_jclickaction                =1212041011117960510;
  cnPerm_Table_Add_jcolumn                     =1212041011118030514;
  cnPerm_Table_Add_jdconnection                =1212041011118130526;
  cnPerm_Table_Add_jdebug                      =1212041011118160530;
  cnPerm_Table_Add_jdtype                      =1212041011118180534;
  cnPerm_Table_Add_jetname                     =1605112004460610077;
  cnPerm_Table_Add_jfile                       =1212041011118210538;
  cnPerm_Table_Add_jfiltersave                 =1212041011118240542;
  cnPerm_Table_Add_jfiltersavedef              =1212041011118260546;
  cnPerm_Table_Add_jhelp                       =1212041011118290550;
  cnPerm_Table_Add_jiconcontext                =1212041011118320554;
  cnPerm_Table_Add_jiconmaster                 =1212041011118350558;
  cnPerm_Table_Add_jindexfile                  =1212041011118380562;
  cnPerm_Table_Add_jindustry                   =1212041011118410566;
  cnPerm_Table_Add_jinstalled                  =1212041011118440570;
  cnPerm_Table_Add_jinterface                  =1212041011118480574;
  cnPerm_Table_Add_jinvoice                    =1212041011118500578;
  cnPerm_Table_Add_jinvoicelines               =1212041011118530582;
  cnPerm_Table_Add_jiplist                     =1212041011118550586;
  cnPerm_Table_Add_jiplistlu                   =1308261506589160003;
  cnPerm_Table_Add_jjobq                       =1212041011118580590;
  cnPerm_Table_Add_jjobtype                    =1212041011118610594;
  cnPerm_Table_Add_jlanguage                   =1212041011118630598;
  cnPerm_Table_Add_jlead                       =1212041011118660602;
  cnPerm_Table_Add_jleadsource                 =1212041011118680606;
  cnPerm_Table_Add_jlock                       =1212041011118710610;
  cnPerm_Table_Add_jlog                        =1212041011118750614;
  cnPerm_Table_Add_jlogtype                    =1212041011118780618;
  cnPerm_Table_Add_jlookup                     =1212041011118800622;
  cnPerm_Table_Add_jmail                       =1212041011118830626;
  cnPerm_Table_Add_jmenu                       =1212041011118880630;
  cnPerm_Table_Add_jmime                       =1212041011118900634;
  cnPerm_Table_Add_jmodc                       =1212041011118930638;
  cnPerm_Table_Add_jmodule                     =1212041011118960642;
  cnPerm_Table_Add_jmoduleconfig               =1212041011118980646;
  cnPerm_Table_Add_jmodulesetting              =1212041011119010650;
  cnPerm_Table_Add_jnote                       =1212041011119030654;
  cnPerm_Table_Add_jorg                        =1212041011118080518;
  cnPerm_Table_Add_jorgpers                    =1212041011118100522;
  cnPerm_Table_Add_jpassword                   =1212041011119060658;
  cnPerm_Table_Add_jperson                     =1212041011119080662;
  cnPerm_Table_Add_jpersonskill                =1212041011119110666;
  cnPerm_Table_Add_jprinter                    =1212041011119140670;
  cnPerm_Table_Add_jpriority                   =1212041011119180674;
  cnPerm_Table_Add_jproduct                    =1212041011119210678;
  cnPerm_Table_Add_jproductgrp                 =1212041011119260682;
  cnPerm_Table_Add_jproductqty                 =1212041011119300686;
  cnPerm_Table_Add_jproject                    =1212041011119320690;
  cnPerm_Table_Add_jprojectcategory            =1212041011119350694;
  cnPerm_Table_Add_jprojectpriority            =1605111933188550743;
  cnPerm_Table_Add_jprojectstatus              =1605111958585470996;
  cnPerm_Table_Add_jquicklink                  =1212041011119420706;
  cnPerm_Table_Add_jquicknote                  =1212041011119450710;
  cnPerm_Table_Add_jrequestlog                 =1605112008087350125;
  cnPerm_Table_Add_jscreen                     =1212041011119480714;
  cnPerm_Table_Add_jscreentype                 =1212041011119510718;
  cnPerm_Table_Add_jsecgrp                     =1212041011119540722;
  cnPerm_Table_Add_jsecgrplink                 =1212041011119570726;
  cnPerm_Table_Add_jsecgrpuserlink             =1212041011119600730;
  cnPerm_Table_Add_jseckey                     =1212041011119620734;
  cnPerm_Table_Add_jsecperm                    =1212041011119660738;
  cnPerm_Table_Add_jsecpermuserlink            =1212041011119690742;
  cnPerm_Table_Add_jsession                    =1212041011119720746;
  cnPerm_Table_Add_jsessiondata                =1212041011119750750;
  cnPerm_Table_Add_jsessiontype                =1212041011119770754;
  cnPerm_Table_Add_jskill                      =1212041011119800758;
  cnPerm_Table_Add_jstatus                     =1212041011119820762;
  cnPerm_Table_Add_jsync                       =1212041011119840766;
  cnPerm_Table_Add_jsysmodule                  =1212041011119870770;
  cnPerm_Table_Add_jsysmodulelink              =1212041011119900774;
  cnPerm_Table_Add_jtable                      =1212041011119930778;
  cnPerm_Table_Add_jtabletype                  =1212041011119950782;
  cnPerm_Table_Add_jtask                       =1212041011119980786;
  cnPerm_Table_Add_jtaskcategory               =1212041011120010790;
  cnPerm_Table_Add_jteam                       =1212041011120040794;
  cnPerm_Table_Add_jteammember                 =1212041011120080798;
  cnPerm_Table_Add_jtestone                    =1212041011120110802;
  cnPerm_Table_Add_jtheme                      =1212041011120140806;
  cnPerm_Table_Add_jthemeicon                  =1212041011120160810;
  cnPerm_Table_Add_jtimecard                   =1212041011120190814;
  cnPerm_Table_Add_jtrak                       =1212041011120220818;
  cnPerm_Table_Add_juser                       =1212041011120250822;
  cnPerm_Table_Add_juserpref                   =1212041011120270826;
  cnPerm_Table_Add_juserpreflink               =1212041011120300830;
  cnPerm_Table_Add_jvhost                      =1212041011120320834;
  cnPerm_Table_Add_jwidget                     =1212041011120350838;
  cnPerm_Table_Add_view_case                   =1212041011120390842;
  cnPerm_Table_Add_view_inventory              =1212041011120460850;
  cnPerm_Table_Add_view_invoice                =1212041011120500854;
  cnPerm_Table_Add_view_lead                   =1212041011120530858;
  cnPerm_Table_Add_view_menu                   =1212041011120550862;
  cnPerm_Table_Add_view_org                    =1212041011120420846;
  cnPerm_Table_Add_view_person                 =1212041011120580866;
  cnPerm_Table_Add_view_project                =1212041011120610870;
  cnPerm_Table_Add_view_task                   =1212041011120640874;
  cnPerm_Table_Add_view_team                   =1212041011120660878;
  cnPerm_Table_Add_view_time                   =1212041011120690882;
  cnPerm_Table_Add_view_vendor                 =1212041011120720886;
  cnPerm_Table_Delete_jaccesslog               =1602232217233700017;
  cnPerm_Table_Delete_jadodbms                 =1212041011117490453;
  cnPerm_Table_Delete_jadodriver               =1212041011117530457;
  cnPerm_Table_Delete_jalias                   =1212041011117590461;
  cnPerm_Table_Delete_jasident                 =1212041011117620465;
  cnPerm_Table_Delete_jblok                    =1212041011117660469;
  cnPerm_Table_Delete_jblokbutton              =1212041011117690473;
  cnPerm_Table_Delete_jblokfield               =1212041011117720477;
  cnPerm_Table_Delete_jbloktype                =1212041011117750481;
  cnPerm_Table_Delete_jbuttontype              =1212041011117770485;
  cnPerm_Table_Delete_jcaption                 =1212041011117800489;
  cnPerm_Table_Delete_jcase                    =1212041011117820493;
  cnPerm_Table_Delete_jcasecategory            =1212041011117850497;
  cnPerm_Table_Delete_jcasesource              =1212041011117880501;
  cnPerm_Table_Delete_jcasesubject             =1212041011117910505;
  cnPerm_Table_Delete_jcasetype                =1212041011117950509;
  cnPerm_Table_Delete_jclickaction             =1212041011118020513;
  cnPerm_Table_Delete_jcolumn                  =1212041011118070517;
  cnPerm_Table_Delete_jdconnection             =1212041011118150529;
  cnPerm_Table_Delete_jdebug                   =1212041011118180533;
  cnPerm_Table_Delete_jdtype                   =1212041011118200537;
  cnPerm_Table_Delete_jetname                  =1605112005124740086;
  cnPerm_Table_Delete_jfile                    =1212041011118230541;
  cnPerm_Table_Delete_jfiltersave              =1212041011118260545;
  cnPerm_Table_Delete_jfiltersavedef           =1212041011118280549;
  cnPerm_Table_Delete_jhelp                    =1212041011118320553;
  cnPerm_Table_Delete_jiconcontext             =1212041011118350557;
  cnPerm_Table_Delete_jiconmaster              =1212041011118370561;
  cnPerm_Table_Delete_jindexfile               =1212041011118400565;
  cnPerm_Table_Delete_jindustry                =1212041011118430569;
  cnPerm_Table_Delete_jinstalled               =1212041011118470573;
  cnPerm_Table_Delete_jinterface               =1212041011118500577;
  cnPerm_Table_Delete_jinvoice                 =1212041011118520581;
  cnPerm_Table_Delete_jinvoicelines            =1212041011118550585;
  cnPerm_Table_Delete_jiplist                  =1212041011118580589;
  cnPerm_Table_Delete_jiplistlu                =1308261506589610006;
  cnPerm_Table_Delete_jjobq                    =1212041011118600593;
  cnPerm_Table_Delete_jjobtype                 =1212041011118630597;
  cnPerm_Table_Delete_jlanguage                =1212041011118650601;
  cnPerm_Table_Delete_jlead                    =1212041011118670605;
  cnPerm_Table_Delete_jleadsource              =1212041011118700609;
  cnPerm_Table_Delete_jlock                    =1212041011118740613;
  cnPerm_Table_Delete_jlog                     =1212041011118770617;
  cnPerm_Table_Delete_jlogtype                 =1212041011118800621;
  cnPerm_Table_Delete_jlookup                  =1212041011118820625;
  cnPerm_Table_Delete_jmail                    =1212041011118870629;
  cnPerm_Table_Delete_jmenu                    =1212041011118900633;
  cnPerm_Table_Delete_jmime                    =1212041011118920637;
  cnPerm_Table_Delete_jmodc                    =1212041011118950641;
  cnPerm_Table_Delete_jmodule                  =1212041011118980645;
  cnPerm_Table_Delete_jmoduleconfig            =1212041011119000649;
  cnPerm_Table_Delete_jmodulesetting           =1212041011119030653;
  cnPerm_Table_Delete_jnote                    =1212041011119050657;
  cnPerm_Table_Delete_jorg                     =1212041011118100521;
  cnPerm_Table_Delete_jorgpers                 =1212041011118120525;
  cnPerm_Table_Delete_jpassword                =1212041011119080661;
  cnPerm_Table_Delete_jperson                  =1212041011119100665;
  cnPerm_Table_Delete_jpersonskill             =1212041011119130669;
  cnPerm_Table_Delete_jprinter                 =1212041011119170673;
  cnPerm_Table_Delete_jpriority                =1212041011119210677;
  cnPerm_Table_Delete_jproduct                 =1212041011119240681;
  cnPerm_Table_Delete_jproductgrp              =1212041011119290685;
  cnPerm_Table_Delete_jproductqty              =1212041011119310689;
  cnPerm_Table_Delete_jproject                 =1212041011119340693;
  cnPerm_Table_Delete_jprojectcategory         =1212041011119370697;
  cnPerm_Table_Delete_jprojectpriority         =1605111933494920752;
  cnPerm_Table_Delete_jprojectstatus           =1605112000085280011;
  cnPerm_Table_Delete_jquicklink               =1212041011119450709;
  cnPerm_Table_Delete_jquicknote               =1212041011119470713;
  cnPerm_Table_Delete_jrequestlog              =1605112008325200134;
  cnPerm_Table_Delete_jscreen                  =1212041011119500717;
  cnPerm_Table_Delete_jscreentype              =1212041011119530721;
  cnPerm_Table_Delete_jsecgrp                  =1212041011119560725;
  cnPerm_Table_Delete_jsecgrplink              =1212041011119590729;
  cnPerm_Table_Delete_jsecgrpuserlink          =1212041011119610733;
  cnPerm_Table_Delete_jseckey                  =1212041011119650737;
  cnPerm_Table_Delete_jsecperm                 =1212041011119680741;
  cnPerm_Table_Delete_jsecpermuserlink         =1212041011119710745;
  cnPerm_Table_Delete_jsession                 =1212041011119740749;
  cnPerm_Table_Delete_jsessiondata             =1212041011119760753;
  cnPerm_Table_Delete_jsessiontype             =1212041011119790757;
  cnPerm_Table_Delete_jskill                   =1212041011119810761;
  cnPerm_Table_Delete_jstatus                  =1212041011119840765;
  cnPerm_Table_Delete_jsync                    =1212041011119860769;
  cnPerm_Table_Delete_jsysmodule               =1212041011119890773;
  cnPerm_Table_Delete_jsysmodulelink           =1212041011119920777;
  cnPerm_Table_Delete_jtable                   =1212041011119950781;
  cnPerm_Table_Delete_jtabletype               =1212041011119970785;
  cnPerm_Table_Delete_jtask                    =1212041011120000789;
  cnPerm_Table_Delete_jtaskcategory            =1212041011120030793;
  cnPerm_Table_Delete_jteam                    =1212041011120070797;
  cnPerm_Table_Delete_jteammember              =1212041011120100801;
  cnPerm_Table_Delete_jtheme                   =1212041011120150809;
  cnPerm_Table_Delete_jthemeicon               =1212041011120190813;
  cnPerm_Table_Delete_jtimecard                =1212041011120210817;
  cnPerm_Table_Delete_jtrak                    =1212041011120240821;
  cnPerm_Table_Delete_juser                    =1212041011120260825;
  cnPerm_Table_Delete_juserpref                =1212041011120290829;
  cnPerm_Table_Delete_juserpreflink            =1212041011120310833;
  cnPerm_Table_Delete_jvhost                   =1212041011120350837;
  cnPerm_Table_Delete_jwidget                  =1212041011120380841;
  cnPerm_Table_Delete_view_case                =1212041011120410845;
  cnPerm_Table_Delete_view_inventory           =1212041011120490853;
  cnPerm_Table_Delete_view_invoice             =1212041011120520857;
  cnPerm_Table_Delete_view_lead                =1212041011120550861;
  cnPerm_Table_Delete_view_menu                =1212041011120580865;
  cnPerm_Table_Delete_view_org                 =1212041011120450849;
  cnPerm_Table_Delete_view_person              =1212041011120600869;
  cnPerm_Table_Delete_view_project             =1212041011120630873;
  cnPerm_Table_Delete_view_task                =1212041011120660877;
  cnPerm_Table_Delete_view_team                =1212041011120680881;
  cnPerm_Table_Delete_view_time                =1212041011120710885;
  cnPerm_Table_Delete_view_vendor              =1212041011120740889;
  cnPerm_Table_Edit_jiplistlu                  =1308261506589310004;
  cnPerm_Table_Export_jaccesslog               =1602232217233730019;
  cnPerm_Table_Export_jiplistlu                =1308261506589920008;
  cnPerm_Table_jdownloadfilelist_Add           =1604090052296450010;
  cnPerm_Table_jdownloadfilelist_Delete        =1604090052296500013;
  cnPerm_Table_jdownloadfilelist_Edit          =1604090052296460011;
  cnPerm_Table_jdownloadfilelist_Export        =1604090052296540015;
  cnPerm_Table_jdownloadfilelist_Modify        =1604090052296520014;
  cnPerm_Table_jdownloadfilelist_View          =1604090052296480012;
  cnPerm_Table_jegaslog_Add                    =1602241655549040244;
  cnPerm_Table_jegaslog_Delete                 =1602241655549090247;
  cnPerm_Table_jegaslog_Edit                   =1602241655549060245;
  cnPerm_Table_jegaslog_Export                 =1602241655549110249;
  cnPerm_Table_jegaslog_Modify                 =1602241655549100248;
  cnPerm_Table_jegaslog_View                   =1602241655549080246;
  cnPerm_Table_jerrorlog_Add                   =1602232240308510112;
  cnPerm_Table_jerrorlog_Delete                =1602232240308550115;
  cnPerm_Table_jerrorlog_Edit                  =1602232240308520113;
  cnPerm_Table_jerrorlog_Export                =1602232240308570117;
  cnPerm_Table_jerrorlog_Modify                =1602232240308560116;
  cnPerm_Table_jerrorlog_View                  =1602232240308530114;
  cnPerm_Table_jipstat_Add                     =1602161551395970009;
  cnPerm_Table_jipstat_Delete                  =1602161551396040012;
  cnPerm_Table_jipstat_Edit                    =1602161551395990010;
  cnPerm_Table_jipstat_Export                  =1602161551396090014;
  cnPerm_Table_jipstat_Modify                  =1602161551396070013;
  cnPerm_Table_jipstat_View                    =1602161551396010011;
  cnPerm_Table_jpunkbait_Add                   =1603102354376970055;
  cnPerm_Table_jpunkbait_Delete                =1603102354377060058;
  cnPerm_Table_jpunkbait_Edit                  =1603102354377010056;
  cnPerm_Table_jpunkbait_Export                =1603102354377110060;
  cnPerm_Table_jpunkbait_Modify                =1603102354377080059;
  cnPerm_Table_jpunkbait_View                  =1603102354377040057;
  cnPerm_Table_Update_jaccesslog               =1602232217233720018;
  cnPerm_Table_Update_jadodbms                 =1212041011117480452;
  cnPerm_Table_Update_jadodriver               =1212041011117520456;
  cnPerm_Table_Update_jalias                   =1212041011117580460;
  cnPerm_Table_Update_jasident                 =1212041011117610464;
  cnPerm_Table_Update_jblok                    =1212041011117650468;
  cnPerm_Table_Update_jblokbutton              =1212041011117690472;
  cnPerm_Table_Update_jblokfield               =1212041011117710476;
  cnPerm_Table_Update_jbloktype                =1212041011117740480;
  cnPerm_Table_Update_jbuttontype              =1212041011117760484;
  cnPerm_Table_Update_jcaption                 =1212041011117790488;
  cnPerm_Table_Update_jcase                    =1212041011117820492;
  cnPerm_Table_Update_jcasecategory            =1212041011117840496;
  cnPerm_Table_Update_jcasesource              =1212041011117870500;
  cnPerm_Table_Update_jcasesubject             =1212041011117900504;
  cnPerm_Table_Update_jcasetype                =1212041011117940508;
  cnPerm_Table_Update_jclickaction             =1212041011118010512;
  cnPerm_Table_Update_jcolumn                  =1212041011118050516;
  cnPerm_Table_Update_jdconnection             =1212041011118140528;
  cnPerm_Table_Update_jdebug                   =1212041011118170532;
  cnPerm_Table_Update_jdtype                   =1212041011118200536;
  cnPerm_Table_Update_jetname                  =1605112005016490083;
  cnPerm_Table_Update_jfile                    =1212041011118220540;
  cnPerm_Table_Update_jfiltersave              =1212041011118250544;
  cnPerm_Table_Update_jfiltersavedef           =1212041011118270548;
  cnPerm_Table_Update_jhelp                    =1212041011118310552;
  cnPerm_Table_Update_jiconcontext             =1212041011118340556;
  cnPerm_Table_Update_jiconmaster              =1212041011118360560;
  cnPerm_Table_Update_jindexfile               =1212041011118390564;
  cnPerm_Table_Update_jindustry                =1212041011118420568;
  cnPerm_Table_Update_jinstalled               =1212041011118460572;
  cnPerm_Table_Update_jinterface               =1212041011118490576;
  cnPerm_Table_Update_jinvoice                 =1212041011118520580;
  cnPerm_Table_Update_jinvoicelines            =1212041011118540584;
  cnPerm_Table_Update_jiplist                  =1212041011118570588;
  cnPerm_Table_Update_jiplistlu                =1308261506589800007;
  cnPerm_Table_Update_jjobq                    =1212041011118590592;
  cnPerm_Table_Update_jjobtype                 =1212041011118620596;
  cnPerm_Table_Update_jlanguage                =1212041011118640600;
  cnPerm_Table_Update_jlead                    =1212041011118670604;
  cnPerm_Table_Update_jleadsource              =1212041011118690608;
  cnPerm_Table_Update_jlock                    =1212041011118730612;
  cnPerm_Table_Update_jlog                     =1212041011118760616;
  cnPerm_Table_Update_jlogtype                 =1212041011118790620;
  cnPerm_Table_Update_jlookup                  =1212041011118820624;
  cnPerm_Table_Update_jmail                    =1212041011118860628;
  cnPerm_Table_Update_jmenu                    =1212041011118890632;
  cnPerm_Table_Update_jmime                    =1212041011118920636;
  cnPerm_Table_Update_jmodc                    =1212041011118940640;
  cnPerm_Table_Update_jmodule                  =1212041011118970644;
  cnPerm_Table_Update_jmoduleconfig            =1212041011118990648;
  cnPerm_Table_Update_jmodulesetting           =1212041011119020652;
  cnPerm_Table_Update_jnote                    =1212041011119050656;
  cnPerm_Table_Update_jorg                     =1212041011118090520;
  cnPerm_Table_Update_jorgpers                 =1212041011118120524;
  cnPerm_Table_Update_jpassword                =1212041011119070660;
  cnPerm_Table_Update_jperson                  =1212041011119100664;
  cnPerm_Table_Update_jpersonskill             =1212041011119120668;
  cnPerm_Table_Update_jprinter                 =1212041011119160672;
  cnPerm_Table_Update_jpriority                =1212041011119200676;
  cnPerm_Table_Update_jproduct                 =1212041011119230680;
  cnPerm_Table_Update_jproductgrp              =1212041011119280684;
  cnPerm_Table_Update_jproductqty              =1212041011119310688;
  cnPerm_Table_Update_jproject                 =1212041011119340692;
  cnPerm_Table_Update_jprojectcategory         =1212041011119360696;
  cnPerm_Table_Update_jprojectpriority         =1605111933330450746;
  cnPerm_Table_Update_jprojectstatus           =1605111959556760008;
  cnPerm_Table_Update_jquicklink               =1212041011119440708;
  cnPerm_Table_Update_jquicknote               =1212041011119460712;
  cnPerm_Table_Update_jrequestlog              =1605112008250100131;
  cnPerm_Table_Update_jscreen                  =1212041011119490716;
  cnPerm_Table_Update_jscreentype              =1212041011119530720;
  cnPerm_Table_Update_jsecgrp                  =1212041011119550724;
  cnPerm_Table_Update_jsecgrplink              =1212041011119580728;
  cnPerm_Table_Update_jsecgrpuserlink          =1212041011119610732;
  cnPerm_Table_Update_jseckey                  =1212041011119640736;
  cnPerm_Table_Update_jsecperm                 =1212041011119680740;
  cnPerm_Table_Update_jsecpermuserlink         =1212041011119700744;
  cnPerm_Table_Update_jsession                 =1212041011119730748;
  cnPerm_Table_Update_jsessiondata             =1212041011119760752;
  cnPerm_Table_Update_jsessiontype             =1212041011119780756;
  cnPerm_Table_Update_jskill                   =1212041011119810760;
  cnPerm_Table_Update_jstatus                  =1212041011119830764;
  cnPerm_Table_Update_jsync                    =1212041011119860768;
  cnPerm_Table_Update_jsysmodule               =1212041011119880772;
  cnPerm_Table_Update_jsysmodulelink           =1212041011119910776;
  cnPerm_Table_Update_jtable                   =1212041011119940780;
  cnPerm_Table_Update_jtabletype               =1212041011119970784;
  cnPerm_Table_Update_jtask                    =1212041011119990788;
  cnPerm_Table_Update_jtaskcategory            =1212041011120020792;
  cnPerm_Table_Update_jteam                    =1212041011120060796;
  cnPerm_Table_Update_jteammember              =1212041011120090800;
  cnPerm_Table_Update_jtheme                   =1212041011120150808;
  cnPerm_Table_Update_jthemeicon               =1212041011120180812;
  cnPerm_Table_Update_jtimecard                =1212041011120210816;
  cnPerm_Table_Update_jtrak                    =1212041011120230820;
  cnPerm_Table_Update_juser                    =1212041011120260824;
  cnPerm_Table_Update_juserpref                =1212041011120280828;
  cnPerm_Table_Update_juserpreflink            =1212041011120310832;
  cnPerm_Table_Update_jvhost                   =1212041011120340836;
  cnPerm_Table_Update_jwidget                  =1212041011120370840;
  cnPerm_Table_Update_view_case                =1212041011120400844;
  cnPerm_Table_Update_view_inventory           =1212041011120480852;
  cnPerm_Table_Update_view_invoice             =1212041011120510856;
  cnPerm_Table_Update_view_lead                =1212041011120540860;
  cnPerm_Table_Update_view_menu                =1212041011120570864;
  cnPerm_Table_Update_view_org                 =1212041011120440848;
  cnPerm_Table_Update_view_person              =1212041011120590868;
  cnPerm_Table_Update_view_project             =1212041011120620872;
  cnPerm_Table_Update_view_task                =1212041011120650876;
  cnPerm_Table_Update_view_team                =1212041011120680880;
  cnPerm_Table_Update_view_time                =1212041011120700884;
  cnPerm_Table_Update_view_vendor              =1212041011120730888;
  cnPerm_Table_View_jaccesslog                 =1602232217233690016;
  cnPerm_Table_View_jadodbms                   =1212041011117480451;
  cnPerm_Table_View_jadodriver                 =1212041011117520455;
  cnPerm_Table_View_jalias                     =1212041011117550459;
  cnPerm_Table_View_jasident                   =1212041011117600463;
  cnPerm_Table_View_jblok                      =1212041011117640467;
  cnPerm_Table_View_jblokbutton                =1212041011117680471;
  cnPerm_Table_View_jblokfield                 =1212041011117710475;
  cnPerm_Table_View_jbloktype                  =1212041011117730479;
  cnPerm_Table_View_jbuttontype                =1212041011117760483;
  cnPerm_Table_View_jcaption                   =1212041011117780487;
  cnPerm_Table_View_jcase                      =1212041011117810491;
  cnPerm_Table_View_jcasecategory              =1212041011117840495;
  cnPerm_Table_View_jcasesource                =1212041011117860499;
  cnPerm_Table_View_jcasesubject               =1212041011117890503;
  cnPerm_Table_View_jcasetype                  =1212041011117920507;
  cnPerm_Table_View_jclickaction               =1212041011118000511;
  cnPerm_Table_View_jcolumn                    =1212041011118040515;
  cnPerm_Table_View_jdconnection               =1212041011118140527;
  cnPerm_Table_View_jdebug                     =1212041011118160531;
  cnPerm_Table_View_jdtype                     =1212041011118190535;
  cnPerm_Table_View_jetname                    =1605112004539920080;
  cnPerm_Table_View_jfile                      =1212041011118220539;
  cnPerm_Table_View_jfiltersave                =1212041011118240543;
  cnPerm_Table_View_jfiltersavedef             =1212041011118270547;
  cnPerm_Table_View_jhelp                      =1212041011118300551;
  cnPerm_Table_View_jiconcontext               =1212041011118330555;
  cnPerm_Table_View_jiconmaster                =1212041011118360559;
  cnPerm_Table_View_jindexfile                 =1212041011118390563;
  cnPerm_Table_View_jindustry                  =1212041011118410567;
  cnPerm_Table_View_jinstalled                 =1212041011118450571;
  cnPerm_Table_View_jinterface                 =1212041011118480575;
  cnPerm_Table_View_jinvoice                   =1212041011118510579;
  cnPerm_Table_View_jinvoicelines              =1212041011118540583;
  cnPerm_Table_View_jiplist                    =1212041011118560587;
  cnPerm_Table_View_jiplistlu                  =1308261506589480005;
  cnPerm_Table_View_jjobq                      =1212041011118590591;
  cnPerm_Table_View_jjobtype                   =1212041011118610595;
  cnPerm_Table_View_jlanguage                  =1212041011118640599;
  cnPerm_Table_View_jlead                      =1212041011118660603;
  cnPerm_Table_View_jleadsource                =1212041011118690607;
  cnPerm_Table_View_jlock                      =1212041011118720611;
  cnPerm_Table_View_jlog                       =1212041011118750615;
  cnPerm_Table_View_jlogtype                   =1212041011118780619;
  cnPerm_Table_View_jlookup                    =1212041011118810623;
  cnPerm_Table_View_jmail                      =1212041011118840627;
  cnPerm_Table_View_jmenu                      =1212041011118890631;
  cnPerm_Table_View_jmime                      =1212041011118910635;
  cnPerm_Table_View_jmodc                      =1212041011118940639;
  cnPerm_Table_View_jmodule                    =1212041011118960643;
  cnPerm_Table_View_jmoduleconfig              =1212041011118990647;
  cnPerm_Table_View_jmodulesetting             =1212041011119010651;
  cnPerm_Table_View_jnote                      =1212041011119040655;
  cnPerm_Table_View_jorg                       =1212041011118080519;
  cnPerm_Table_View_jorgpers                   =1212041011118110523;
  cnPerm_Table_View_jpassword                  =1212041011119060659;
  cnPerm_Table_View_jperson                    =1212041011119090663;
  cnPerm_Table_View_jpersonskill               =1212041011119120667;
  cnPerm_Table_View_jprinter                   =1212041011119150671;
  cnPerm_Table_View_jpriority                  =1212041011119190675;
  cnPerm_Table_View_jproduct                   =1212041011119220679;
  cnPerm_Table_View_jproductgrp                =1212041011119270683;
  cnPerm_Table_View_jproductqty                =1212041011119300687;
  cnPerm_Table_View_jproject                   =1212041011119330691;
  cnPerm_Table_View_jprojectcategory           =1212041011119350695;
  cnPerm_Table_View_jprojectpriority           =1605111933420880749;
  cnPerm_Table_View_jprojectstatus             =1605111959319320003;
  cnPerm_Table_View_jquicklink                 =1212041011119430707;
  cnPerm_Table_View_jquicknote                 =1212041011119460711;
  cnPerm_Table_View_jrequestlog                =1605112008162590128;
  cnPerm_Table_View_jscreen                    =1212041011119480715;
  cnPerm_Table_View_jscreentype                =1212041011119520719;
  cnPerm_Table_View_jsecgrp                    =1212041011119550723;
  cnPerm_Table_View_jsecgrplink                =1212041011119570727;
  cnPerm_Table_View_jsecgrpuserlink            =1212041011119600731;
  cnPerm_Table_View_jseckey                    =1212041011119630735;
  cnPerm_Table_View_jsecperm                   =1212041011119670739;
  cnPerm_Table_View_jsecpermuserlink           =1212041011119700743;
  cnPerm_Table_View_jsession                   =1212041011119720747;
  cnPerm_Table_View_jsessiondata               =1212041011119750751;
  cnPerm_Table_View_jsessiontype               =1212041011119780755;
  cnPerm_Table_View_jskill                     =1212041011119800759;
  cnPerm_Table_View_jstatus                    =1212041011119830763;
  cnPerm_Table_View_jsync                      =1212041011119850767;
  cnPerm_Table_View_jsysmodule                 =1212041011119880771;
  cnPerm_Table_View_jsysmodulelink             =1212041011119910775;
  cnPerm_Table_View_jtable                     =1212041011119930779;
  cnPerm_Table_View_jtabletype                 =1212041011119960783;
  cnPerm_Table_View_jtask                      =1212041011119990787;
  cnPerm_Table_View_jtaskcategory              =1212041011120010791;
  cnPerm_Table_View_jteam                      =1212041011120050795;
  cnPerm_Table_View_jteammember                =1212041011120090799;
  cnPerm_Table_View_jtestone                   =1212041011120110803;
  cnPerm_Table_View_jtheme                     =1212041011120140807;
  cnPerm_Table_View_jthemeicon                 =1212041011120170811;
  cnPerm_Table_View_jtimecard                  =1212041011120200815;
  cnPerm_Table_View_jtrak                      =1212041011120230819;
  cnPerm_Table_View_juser                      =1212041011120250823;
  cnPerm_Table_View_juserpref                  =1212041011120280827;
  cnPerm_Table_View_juserpreflink              =1212041011120300831;
  cnPerm_Table_View_jvhost                     =1212041011120330835;
  cnPerm_Table_View_jwidget                    =1212041011120360839;
  cnPerm_Table_View_view_case                  =1212041011120390843;
  cnPerm_Table_View_view_inventory             =1212041011120470851;
  cnPerm_Table_View_view_invoice               =1212041011120510855;
  cnPerm_Table_View_view_lead                  =1212041011120530859;
  cnPerm_Table_View_view_menu                  =1212041011120560863;
  cnPerm_Table_View_view_org                   =1212041011120430847;
  cnPerm_Table_View_view_person                =1212041011120590867;
  cnPerm_Table_View_view_project               =1212041011120610871;
  cnPerm_Table_View_view_task                  =1212041011120640875;
  cnPerm_Table_View_view_team                  =1212041011120670879;
  cnPerm_Table_View_view_time                  =1212041011120700883;
  cnPerm_Table_View_view_vendor                =1212041011120730887;
  cnPerm_test_Add                              =1603020450226700012;
  cnPerm_test_Delete                           =1603020450226790015;
  cnPerm_test_Edit                             =1603020450226740013;
  cnPerm_test_Export                           =1603020450226840017;
  cnPerm_test_Modify                           =1603020450226810016;
  cnPerm_test_View                             =1603020450226760014;
  //=============================================================================







//=============================================================================
// Global Arrays used by JAS to hold Dynamic config info in mem
//=============================================================================
var
  garJAliasLight: array of rtJAliasLight;
  garJIPListLight: array of rtJIPListLight;
  garJVHost: array of rtJVHost;
  garJMimeLight: array of rtJMimeLight;
  garJIndexFileLight: array of rtJIndexfileLight;
  garJLanguageLight: array of rtJLanguageLight;
  garJThemeLight: array of rtJThemeLight;
  garJReDirectLight: array of rtJRedirectLight;
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
procedure clear_audit(var p_raudit: rtAudit;p_saColumnPrefix: ansistring);
//=============================================================================
begin
  with p_raudit do begin
    u8UID                            :=0;
	  saFieldName_CreatedBy_JUser_ID   :=p_saColumnPrefix+'_CreatedBy_JUser_ID';
	  saFieldName_Created_DT           :=p_saColumnPrefix+'_Created_DT';
	  saFieldName_ModifiedBy_JUser_ID  :=p_saColumnPrefix+'_ModifiedBy_JUser_ID';
	  saFieldName_Modified_DT          :=p_saColumnPrefix+'_Modified_DT';
	  saFieldName_DeletedBy_JUser_ID   :=p_saColumnPrefix+'_DeletedBy_JUser_ID';
	  saFieldName_Deleted_DT           :=p_saColumnPrefix+'_Deleted_DT';
	  saFieldName_Deleted_b            :=p_saColumnPrefix+'_Deleted_b';
    bUse_CreatedBy_JUser_ID          :=false;
    bUse_Created_DT                  :=false;
    bUse_ModifiedBy_JUser_ID         :=false;
    bUse_Modified_DT                 :=false;
    bUse_DeletedBy_JUser_ID          :=false;
    bUse_Deleted_DT                  :=false;
    bUse_Deleted_b                   :=false;
	end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JASSingle(var p_rJASSingle: rtJASSingle);
//=============================================================================
begin
  with p_rJASSingle do begin
	  saServerSoftware            :='';
	  iTimeZoneOffset             :=0;
	  i8CgiResult                 :=0;
	end;
end;
//=============================================================================


//=============================================================================
procedure clear_JADODBMS(var p_rJADODBMS: rtJADODBMS);
//=============================================================================
begin
  with p_rJADODBMS do begin
    JADB_JADODBMS_UID                 :=0;
    JADB_Name                         :='';
    JADB_CreatedBy_JUser_ID           :=0;
    JADB_Created_DT                   :='';
    JADB_ModifiedBy_JUser_ID          :=0;
    JADB_Modified_DT                  :='';
    JADB_DeletedBy_JUser_ID           :=0;
    JADB_Deleted_DT                   :='';
    JADB_Deleted_b                    :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JADODriver(var p_rJADODriver: rtJADODriver);
//=============================================================================
begin
  with p_rJADODriver do begin
    JADV_JADODriver_UID               :=0;
    JADV_Name                         :='';
    JADV_CreatedBy_JUser_ID           :=0;
    JADV_Created_DT                   :='';
    JADV_ModifiedBy_JUser_ID          :=0;
    JADV_Modified_DT                  :='';
    JADV_DeletedBy_JUser_ID           :=0;
    JADV_Deleted_DT                   :='';
    JADV_Deleted_b                    :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JBlok(var p_rJBlok: rtJBlok);
//=============================================================================
begin
  with p_rJBlok do begin
    JBlok_JBlok_UID                   :=0;
    JBlok_JScreen_ID                  :=0;
    JBlok_JTable_ID                   :=0;
    JBlok_Name                        :='';
    JBlok_Columns_u                   :=0;
	  JBlok_JBlokType_ID                :=0;
	  JBlok_Custom                      :='';
	  JBlok_JCaption_ID                 :=0;
	  JBlok_IconSmall                   :='';
	  JBlok_IconLarge                   :='';
    JBlok_Position_u                  :=0;
    JBlok_Help_ID                     :=0;
    JBlok_CreatedBy_JUser_ID          :=0;
	  JBlok_Created_DT                  :='';
	  JBlok_ModifiedBy_JUser_ID         :=0;
	  JBlok_Modified_DT                 :='';
	  JBlok_DeletedBy_JUser_ID          :=0;
	  JBlok_Deleted_DT                  :='';
	  JBlok_Deleted_b                   :=false;
	end;//with
End;
//=============================================================================

//=============================================================================
procedure clear_JBlokButton(var p_rJBlokButton: rtJBlokButton);
//=============================================================================
begin
  with p_rJBlokButton do begin
	  JBlkB_JBlokButton_UID             :=0;
	  JBlkB_JBlok_ID                    :=0;
	  JBlkB_JCaption_ID                 :=0;
	  JBlkB_Name                        :='';
	  JBlkB_GraphicFileName             :='';
	  JBlkB_Position_u                  :=0;
	  JBlkB_JButtonType_ID              :=0;
	  JBlkB_CustomURL                   :='';
	  JBlkB_CreatedBy_JUser_ID          :=0;
	  JBlkB_Created_DT                  :='';
	  JBlkB_ModifiedBy_JUser_ID         :=0;
	  JBlkB_Modified_DT                 :='';
	  JBlkB_DeletedBy_JUser_ID          :=0;
	  JBlkB_Deleted_DT                  :='';
	  JBlkB_Deleted_b                   :=false;
	end;
End;
//=============================================================================

//=============================================================================
procedure clear_JBlokField(var p_rJBlokField: rtJBlokField);
//=============================================================================
begin
  with p_rJBlokField do begin
	  JBlkF_JBlokField_UID              :=0;
	  JBlkF_JBlok_ID                    :=0;
	  JBlkF_JColumn_ID                  :=0;
	  JBlkF_Position_u                  :=0;
	  JBlkF_ReadOnly_b                  :=false;
	  JBlkF_JWidget_ID                  :=0;
	  JBlkF_Widget_MaxLength_u          :=0;
	  JBlkF_Widget_Width                :=0;
	  JBlkF_Widget_Height               :=0;
	  JBlkF_Widget_Password_b           :=false;
	  JBlkF_Widget_Date_b               :=false;
	  JBlkF_Widget_Time_b               :=false;
	  JBlkF_Widget_Mask                 :='';
    JBlkF_Widget_OnBlur               :='';
    JBlkF_Widget_OnChange             :='';
    JBlkF_Widget_OnClick              :='';
    JBlkF_Widget_OnDblClick           :='';
    JBlkF_Widget_OnFocus              :='';
    JBlkF_Widget_OnKeyDown            :='';
    JBlkF_Widget_OnKeypress           :='';
    JBlkF_Widget_OnKeyUp              :='';
    JBlkF_Widget_OnSelect             :='';
	  JBlkF_ColSpan_u                   :=0;
	  JBlkF_ClickAction_ID              :=0;
	  JBlkF_ClickActionData             :='';
	  JBlkF_JCaption_ID                 :=0;
	  JBlkF_Visible_b                   :=false;
	  JBlkF_CreatedBy_JUser_ID          :=0;
	  JBlkF_Created_DT                  :='';
	  JBlkF_ModifiedBy_JUser_ID         :=0;
	  JBlkF_Modified_DT                 :='';
	  JBlkF_DeletedBy_JUser_ID          :=0;
	  JBlkF_Deleted_DT                  :='';
	  JBlkF_Deleted_b                   :=false;
	  JBlkF_Width_is_Percent_b          :=false;
	  JBlkF_Height_is_Percent_b         :=false;
    JBlkF_MultiSelect_b               :=false;
    JBlkF_Required_b                  :=false;
    JAS_Row_b                         :=false;
	end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JBlokType(var p_rJBlokType: rtJBlokType);
//=============================================================================
begin
  with p_rJBlokType do begin
    JBkTy_JBlokType_UID               :=0;
    JBkTy_Name                        :='';
    JBkTy_CreatedBy_JUser_ID          :=0;
    JBkTy_Created_DT                  :='';
    JBkTy_ModifiedBy_JUser_ID         :=0;
    JBkTy_Modified_DT                 :='';
    JBkTy_DeletedBy_JUser_ID          :=0;
    JBkTy_Deleted_DT                  :='';
    JBkTy_Deleted_b                   :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JButtonType(var p_rJButtonType: rtJButtonType);
//=============================================================================
begin
  with p_rJButtonType do begin
    JBtnT_JButtonType_UID       :=0;
    JBtnT_Name                  :='';
    JBtnT_CreatedBy_JUser_ID    :=0;
    JBtnT_Created_DT            :='';
    JBtnT_ModifiedBy_JUser_ID   :=0;
    JBtnT_Modified_DT           :='';
    JBtnT_DeletedBy_JUser_ID    :=0;
    JBtnT_Deleted_DT            :='';
    JBtnT_Deleted_b             :=false;
    JAS_Row_b                   :=false;
	end;
End;
//=============================================================================



//=============================================================================
procedure clear_JCaption(var p_rJCaption: rtJCaption);
//=============================================================================
begin
  with p_rJCaption do begin
    JCapt_JCaption_UID          :=0;
    JCapt_Orphan_b              :=false;
    JCapt_Value                 :='';
    JCapt_en                    :='';
    JCapt_CreatedBy_JUser_ID    :=0;
    JCapt_Created_DT            :='';
    JCapt_ModifiedBy_JUser_ID   :=0;
    JCapt_Modified_DT           :='';
    JCapt_DeletedBy_JUser_ID    :=0;
    JCapt_Deleted_DT            :='';
    JCapt_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JCase(var p_rJCase: rtJCase);
//=============================================================================
begin
  with p_rJCase do begin
    JCase_JCase_UID                 :=0;
    JCase_Name                      :='';
    JCase_JOrg_ID                   :=0;
    JCase_JPerson_ID                :=0;
    JCase_Responsible_Grp_ID        :=0;
    JCase_Responsible_Person_ID     :=0;
    JCase_JCaseSource_ID            :=0;
    JCase_JCaseCategory_ID          :=0;
    JCase_JCasePriority_ID          :=0;
    JCase_JCaseStatus_ID            :=0;
    JCase_JCaseType_ID              :=0;
    JCase_JSubject_ID               :=0;
    JCase_Desc                      :='';
    JCase_Resolution                :='';
    JCase_Due_DT                    :='';
    JCase_ResolvedBy_JUser_ID       :=0;
    JCase_Resolved_DT               :='';
    JCase_CreatedBy_JUser_ID        :=0;
    JCase_Created_DT                :='';
    JCase_ModifiedBy_JUser_ID       :=0;
    JCase_Modified_DT               :='';
    JCase_DeletedBy_JUser_ID        :=0;
    JCase_Deleted_DT                :='';
    JCase_Deleted_b                 :=false;
    JAS_Row_b                       :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseCategory(var p_rJCaseCategory: rtJCaseCategory);
//=============================================================================
begin
  with p_rJCaseCategory do begin
    JCACT_JCaseCategory_UID           :=0;
    JCACT_Name                        :='';
    JCACT_CreatedBy_JUser_ID          :=0;
    JCACT_Created_DT                  :='';
    JCACT_ModifiedBy_JUser_ID         :=0;
    JCACT_Modified_DT                 :='';
    JCACT_DeletedBy_JUser_ID          :=0;
    JCACT_Deleted_DT                  :='';
    JCACT_Deleted_b                   :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCasePriority(var p_rJCasePriority: rtJCasePriority);
//=============================================================================
begin
  with p_rJCasePriority do begin
    JCAPR_JCasePriority_UID           :=0;
    JCAPR_Name                        :='';
    JCAPR_CreatedBy_JUser_ID          :=0;
    JCAPR_Created_DT                  :='';
    JCAPR_ModifiedBy_JUser_ID         :=0;
    JCAPR_Modified_DT                 :='';
    JCAPR_DeletedBy_JUser_ID          :=0;
    JCAPR_Deleted_DT                  :='';
    JCAPR_Deleted_b                   :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseSource(var p_rJCaseSource: rtJCaseSource);
//=============================================================================
begin
  with p_rJCaseSource do begin
    JCASR_JCaseSource_UID     :=0;
    JCASR_Name                :='';
    JCASR_CreatedBy_JUser_ID  :=0;
    JCASR_Created_DT          :='';
    JCASR_ModifiedBy_JUser_ID :=0;
    JCASR_Modified_DT         :='';
    JCASR_DeletedBy_JUser_ID  :=0;
    JCASR_Deleted_DT          :='';
    JCASR_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseSubject(var p_rJCaseSubject: rtJCaseSubject);
//=============================================================================
begin
  with p_rJCaseSubject do begin
    JCASB_JCaseSubject_UID    :=0;
    JCASB_Name                :='';
    JCASB_CreatedBy_JUser_ID  :=0;
    JCASB_Created_DT          :='';
    JCASB_ModifiedBy_JUser_ID :=0;
    JCASB_Modified_DT         :='';
    JCASB_DeletedBy_JUser_ID  :=0;
    JCASB_Deleted_DT          :='';
    JCASB_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseType(var p_rJCaseType: rtJCaseType);
//=============================================================================
begin
  with p_rJCaseType do begin
    JCATY_JCaseType_UID       :=0;
    JCATY_Name                :='';
    JCATY_CreatedBy_JUser_ID  :=0;
    JCATY_Created_DT          :='';
    JCATY_ModifiedBy_JUser_ID :=0;
    JCATY_Modified_DT         :='';
    JCATY_DeletedBy_JUser_ID  :=0;
    JCATY_Deleted_DT          :='';
    JCATY_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JColumn(var p_rJColumn: rtJColumn);
//=============================================================================
begin
  with p_rJColumn do begin
    JColu_JColumn_UID             :=0;
    JColu_Name                    :='';
    JColu_JTable_ID               :=0;
    JColu_JDType_ID               :=0;
    JColu_AllowNulls_b            :=false;
    JColu_DefaultValue            :='';
    JColu_PrimaryKey_b            :=false;
    JColu_JAS_b                   :=false;
    JColu_JCaption_ID             :=0;
    JColu_DefinedSize_u           :=0;
    JColu_NumericScale_u          :=0;
    JColu_Precision_u             :=0;
    JColu_Boolean_b               :=false;
    JColu_JAS_Key_b               :=false;
    JColu_AutoIncrement_b         :=false;
    JColu_LUF_Value               :='';
    JColu_LD_CaptionRules_b       :=false;
    JColu_JDConnection_ID         :=0;
    JColu_Desc                    :='';
    JColu_Weight_u                :=0;
    JColu_LD_SQL                  :='';
    JColu_LU_JColumn_ID           :=0;
    JColu_CreatedBy_JUser_ID      :=0;
    JColu_Created_DT              :='';
    JColu_ModifiedBy_JUser_ID     :=0;
    JColu_Modified_DT             :='';
    JColu_DeletedBy_JUser_ID      :=0;
    JColu_Deleted_DT              :='';
    JColu_Deleted_b               :=false;
  End;//with
end;
//=============================================================================



//=============================================================================
//procedure clear_JCommControl(var p_rJCommControl: rtJCommControl);
//=============================================================================
//begin
//  with p_rJCommControl do begin
//    JCCtl_JCommControl_UID          :='';
//    JCCtl_JCommType_ID              :='';
//    JCCtl_JCommSubType_ID           :='';
//    JCCtl_Value                     :='';
//    JCCtl_CreatedBy_JUser_ID        :='';
//    JCCtl_Created_DT                :='';
//    JCCtl_ModifiedBy_JUser_ID       :='';
//    JCCtl_Modified_DT               :='';
//    JCCtl_DeletedBy_JUser_ID        :='';
//    JCCtl_Deleted_DT                :='';
//    JCCtl_Deleted_b                 :='';
//  end;//with
//end;
//=============================================================================

//=============================================================================
//procedure clear_JCommControlLink(var p_rJCommControlLink: rtJCommControlLink);
//=============================================================================
//begin
//  with p_rJCommControlLink do begin
//    JCCLi_JCommControlLink_UID  :='';
//    JCCLi_JCommControl_ID       :='';
//    JCCLi_JPerson_ID            :='';
//    JCCLi_JOrg_ID           :='';
//    JCCLi_CreatedBy_JUser_ID    :='';
//    JCCLi_Created_DT            :='';
//    JCCLi_ModifiedBy_JUser_ID   :='';
//    JCCLi_Modified_DT           :='';
//    JCCLi_DeletedBy_JUser_ID    :='';
//    JCCLi_Deleted_DT            :='';
//    JCCLi_Deleted_b             :='';
//  end;//with
//end;
//=============================================================================



//=============================================================================
//procedure clear_JCommSubType(var p_rJCommSubType: rtJCommSubType);
//=============================================================================
//begin
//  with p_rJCommSubType do begin
//    JCCST_JCommSubType_UID      :='';
//    JCCST_Name                  :='';
//    JCCST_CreatedBy_JUser_ID    :='';
//    JCCST_Created_DT            :='';
//    JCCST_ModifiedBy_JUser_ID   :='';
//    JCCST_Modified_DT           :='';
//    JCCST_DeletedBy_JUser_ID    :='';
//    JCCST_Deleted_DT            :='';
//    JCCST_Deleted_b             :='';
//    JAS_Row_b                   :='';
//  end;//with
//end;
//=============================================================================

//=============================================================================
//procedure clear_JCommType(var p_rJCommType: rtJCommType);
////=============================================================================
//begin
//  with p_rJCommType do begin
//    JComT_JCommType_UID         :='';
//    JComT_Name                  :='';
//    JComT_CreatedBy_JUser_ID    :='';
//    JComT_Created_DT            :='';
//    JComT_ModifiedBy_JUser_ID   :='';
//    JComT_Modified_DT           :='';
//    JComT_DeletedBy_JUser_ID    :='';
//    JComT_Deleted_DT            :='';
//    JComT_Deleted_b             :='';
//    JAS_Row_b                   :='';
//  end;//with
//end;
//=============================================================================




//=============================================================================
procedure clear_JOrg(var p_rJOrg: rtJOrg);
//=============================================================================
begin
  with p_rJOrg do begin
    JOrg_JOrg_UID               :=0;
    JOrg_Name                   :='';
    JOrg_Primary_Person_ID      :=0;
    JOrg_Phone                  :='';
    JOrg_Fax                    :='';
    JOrg_Email                  :='';
    JOrg_Website                :='';
    JOrg_Parent_ID              :=0;
    JOrg_Owner_JUser_ID         :=0;
    JOrg_Desc                   :='';
    JOrg_Main_Addr1             :='';
    JOrg_Main_Addr2             :='';
    JOrg_Main_Addr3             :='';
    JOrg_Main_City              :='';
    JOrg_Main_State             :='';
    JOrg_Main_PostalCode        :='';
    JOrg_Main_Country           :='';
    JOrg_Ship_Addr1             :='';
    JOrg_Ship_Addr2             :='';
    JOrg_Ship_Addr3             :='';
    JOrg_Ship_City              :='';
    JOrg_Ship_State             :='';
    JOrg_Ship_PostalCode        :='';
    JOrg_Ship_Country           :='';
    JOrg_Main_Longitude_d       :=0;
    JOrg_Main_Latitude_d        :=0;
    JOrg_Ship_Longitude_d       :=0;
    JOrg_Ship_Latitude_d        :=0;
    JOrg_Customer_b             :=false;
    JOrg_Vendor_b               :=false;
    JOrg_CreatedBy_JUser_ID     :=0;
    JOrg_Created_DT             :='';
    JOrg_ModifiedBy_JUser_ID    :=0;
    JOrg_Modified_DT            :='';
    JOrg_DeletedBy_JUser_ID     :=0;
    JOrg_Deleted_DT             :='';
    JOrg_Deleted_b              :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JOrgPers(var p_rJOrgPers: rtJOrgPers);
//=============================================================================
begin
  with p_rJOrgPers do begin
    JCpyP_JOrgPers_UID        :=0;
    JCpyP_JOrg_ID             :=0;
    JCpyP_JPerson_ID          :=0;
    JCpyP_DepartmentLU_ID     :=0;
    JCpyP_Title               :='';
    JCpyP_ReportsTo_Person_ID :=0;
    JCpyP_CreatedBy_JUser_ID  :=0;
    JCpyP_Created_DT          :='';
    JCpyP_ModifiedBy_JUser_ID :=0;
    JCpyP_Modified_DT         :='';
    JCpyP_DeletedBy_JUser_ID  :=0;
    JCpyP_Deleted_DT          :='';
    JCpyP_Deleted_b           :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JDConnection(var p_rJDConnection: rtJDConnection);
//=============================================================================
begin
  with p_rJDConnection do begin
    JDCon_Name                              :='';
    JDCon_Desc                              :='';
    JDCon_DBC_Filename                      :='';
    JDCon_DSN                               :='';
    JDCon_DSN_FileBased_b                   :=false;
    JDCon_DSN_Filename                      :='';
    JDCon_Enabled_b                         :=false;
    JDCon_DBMS_ID                           :=0;
    JDCon_Driver_ID                         :=0;
    JDCon_Username                          :='';
    JDCon_Password                          :='';
    JDCon_ODBC_Driver                       :='';
    JDCon_Server                            :='';
    JDCon_Database                          :='';
    JDCon_JSecPerm_ID                       :=0;
    JDCon_CreatedBy_JUser_ID                :=0;
    JDCon_Created_DT                        :='';
    JDCon_ModifiedBy_JUser_ID               :=0;
    JDCon_Modified_DT                       :='';
    JDCon_DeletedBy_JUser_ID                :=0;
    JDCon_Deleted_DT                        :='';
    JDCon_Deleted_b                         :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JDebug(var p_rJDebug: rtJDebug);
//=============================================================================
begin
  with p_rJDebug do begin
    JDBug_JDebug_UID               :=0;
    JDBug_Code_u                   :=0;
    JDBug_Message                  :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JDType(var p_rJDType: rtJDType);
//=============================================================================
begin
  with p_rJDType do begin
    JDTyp_JDType_UID               :=0;
    JDTyp_Desc                     :='';
    JDTyp_Notation                 :='';
    JDTyp_CreatedBy_JUser_ID       :=0;
    JDTyp_Created_DT               :='';
    JDTyp_ModifiedBy_JUser_ID      :=0;
    JDTyp_Modified_DT              :='';
    JDTyp_DeletedBy_JUser_ID       :=0;
    JDTyp_Deleted_DT               :='';
    JDTyp_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JFile(var p_rJFile: rtJFile);
//=============================================================================
begin
  with  p_rJFile do begin
    JFile_JFile_UID                :=0;
    JFile_en                       :='';
    JFile_Name                     :='';
    JFile_Path                     :='';
    JFile_JTable_ID                :=0;
    JFile_JColumn_ID               :=0;
    JFile_Row_ID                   :=0;
    JFile_Orphan_b                 :=false;
    JFile_JSecPerm_ID              :=0;
    JFile_FileSize_u               :=0;
    JFile_Downloads                :=0;
    JFile_CreatedBy_JUser_ID       :=0;
    JFile_Created_DT               :='';
    JFile_ModifiedBy_JUser_ID      :=0;
    JFile_Modified_DT              :='';
    JFile_DeletedBy_JUser_ID       :=0;
    JFile_Deleted_DT               :='';
    JFile_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;







//=============================================================================
procedure clear_JFilterSave(var p_rJFilterSave: rtJFilterSave);
//=============================================================================
begin
  with p_rJFilterSave do begin
    JFtSa_JFilterSave_UID          :=0;
    JFtSa_Name                     :='';
    JFtSa_JBlok_ID                 :=0;
    JFtSa_Public_b                 :=false;
    JFTSa_XML                      :='';
    JFtSa_CreatedBy_JUser_ID       :=0;
    JFtSa_Created_DT               :='';
    JFtSa_ModifiedBy_JUser_ID      :=0;
    JFtSa_Modified_DT              :='';
    JFtSa_DeletedBy_JUser_ID       :=0;
    JFtSa_Deleted_DT               :='';
    JFtSa_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JFilterSaveDef(var p_rJFilterSaveDef: rtJFilterSaveDef);
//=============================================================================
begin
  with p_rJFilterSaveDef do begin
    JFtSD_JFilterSaveDef_UID       :=0;
    JFtSD_JBlok_ID                 :=0;
    JFtSD_JFilterSave_ID           :=0;
    JFtSD_CreatedBy_JUser_ID       :=0;
    JFtSD_Created_DT               :='';
    JFtSD_ModifiedBy_JUser_ID      :=0;
    JFtSD_Modified_DT              :='';
    JFtSD_DeletedBy_JUser_ID       :=0;
    JFtSD_Deleted_DT               :='';
    JFtSD_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;
end;
//=============================================================================




//=============================================================================
procedure clear_JHelp(p_rJHelp: rtJHelp);
//=============================================================================
begin
  with p_rJHelp do begin
    Help_JHelp_UID            :=0;
    Help_VideoMP4_en          :='';
    Help_HTML_en              :='';
    Help_HTML_Adv_en          :='';
    Help_Name                 :='';
    Help_Poster               :='';
    Help_CreatedBy_JUser_ID   :=0;
    Help_Created_DT           :='';
    Help_ModifiedBy_JUser_ID  :=0;
    Help_Modified_DT          :='';
    Help_DeletedBy_JUser_ID   :=0;
    Help_Deleted_DT           :='';
    Help_Deleted_b            :=false;
    JAS_Row_b                 :=false;
  end;
end;
//=============================================================================




//=============================================================================
procedure clear_JIndustry(var p_rJIndustry: rtJIndustry);
//=============================================================================
begin
  with p_rJIndustry do begin
    JIndu_JIndustry_UID            :=0;
    JIndu_Name                     :='';
    JIndu_CreatedBy_JUser_ID       :=0;
    JIndu_Created_DT               :='';
    JIndu_ModifiedBy_JUser_ID      :=0;
    JIndu_Modified_DT              :='';
    JIndu_DeletedBy_JUser_ID       :=0;
    JIndu_Deleted_DT               :='';
    JIndu_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInstalled(var p_rJInstalled: rtJInstalled);
//=============================================================================
begin
  with p_rJInstalled do begin
    JInst_JInstalled_UID           :=0;
    JInst_JModule_ID               :=0;
    JInst_Name                     :='';
    JInst_Desc                     :='';
    JInst_JNote_ID                 :=0;
    JInst_Enabled_b                :=false;
    JInst_CreatedBy_JUser_ID       :=0;
    JInst_Created_DT               :='';
    JInst_ModifiedBy_JUser_ID      :=0;
    JInst_Modified_DT              :='';
    JInst_DeletedBy_JUser_ID       :=0;
    JInst_Deleted_DT               :='';
    JInst_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInterface(var p_rJInterface: rtJInterface);
//=============================================================================
begin
  with p_rJInterface do begin
    JIntF_JInterface_UID           :=0;
    JIntF_Name                     :='';
    JIntF_Desc                     :='';
    JIntF_CreatedBy_JUser_ID       :=0;
    JIntF_Created_DT               :='';
    JIntF_ModifiedBy_JUser_ID      :=0;
    JIntF_Modified_DT              :='';
    JIntF_DeletedBy_JUser_ID       :=0;
    JIntF_Deleted_DT               :='';
    JIntF_Deleted_b                :=false;
    JAS_Row_b                      :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInvoice(var p_rJInvoice: rtJInvoice);
//=============================================================================
begin
  with p_rJInvoice do begin
    JIHdr_JInvoice_UID         :=0;
    JIHdr_DateInv_DT           :='';
    JIHdr_DateShip_DT          :='';
    JIHdr_DateOrd_DT           :='';
    JIHdr_POCust               :='';
    JIHdr_POInternal           :='';
    JIHdr_ShipVia              :='';
    JIHdr_Note01               :='';
    JIHdr_Note02               :='';
    JIHdr_Note03               :='';
    JIHdr_Note04               :='';
    JIHdr_Note05               :='';
    JIHdr_Note06               :='';
    JIHdr_Terms01              :='';
    JIHdr_Terms02              :='';
    JIHdr_Terms03              :='';
    JIHdr_Terms04              :='';
    JIHdr_Terms05              :='';
    JIHdr_Terms06              :='';
    JIHdr_Terms07              :='';
    JIHdr_SalesAmt_d           :=0;
    JIHdr_MiscAmt_d            :=0;
    JIHdr_SalesTaxAmt_d        :=0;
    JIHdr_ShipAmt_d            :=0;
    JIHdr_TotalAmt_d           :=0;
    JIHdr_BillToAddr01         :='';
    JIHdr_BillToAddr02         :='';
    JIHdr_BillToAddr03         :='';
    JIHdr_BillToCity           :='';
    JIHdr_BillToState          :='';
    JIHdr_BillToPostalCode     :='';
    JIHdr_ShipToAddr01         :='';
    JIHdr_ShipToAddr02         :='';
    JIHdr_ShipToAddr03         :='';
    JIHdr_ShipToCity           :='';
    JIHdr_ShipToState          :='';
    JIHdr_ShipToPostalCode     :='';
    JIHDr_JOrg_ID              :=0;
    JIHDr_JPerson_ID           :=0;
    JIHdr_CreatedBy_JUser_ID   :=0;
    JIHdr_Created_DT           :='';
    JIHdr_ModifiedBy_JUser_ID  :=0;
    JIHdr_Modified_DT          :='';
    JIHdr_DeletedBy_JUser_ID   :=0;
    JIHdr_Deleted_DT           :='';
    JIHdr_Deleted_b            :=false;
    JAS_Row_b                  :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInvoiceLines(var p_rJInvoiceLines: rtJInvoiceLines);
//=============================================================================
begin
  with p_rJInvoiceLines do begin
    JILin_JInvoiceLines_UID    :=0;
    JILin_JInvoice_ID          :=0;
    JILin_ProdNoInternal       :='';
    JILin_ProdNoCust           :='';
    JILin_JProduct_ID          :=0;
    JILin_QtyOrd_d             :=0;
    JILin_DescA                :='';
    JILin_DescB                :='';
    JILin_QtyShip_d            :=0;
    JILin_PrcUnit_d            :=0;
    JILin_PrcExt_d             :=0;
    JILin_SEQ_u                :=0;
    JILin_CreatedBy_JUser_ID   :=0;
    JILin_Created_DT           :='';
    JILin_ModifiedBy_JUser_ID  :=0;
    JILin_Modified_DT          :='';
    JILin_DeletedBy_JUser_ID   :=0;
    JILin_Deleted_DT           :='';
    JILin_Deleted_b            :=false;
    JAS_Row_b                  :=false;
  end;//with
end;
//=============================================================================






//=============================================================================
procedure clear_JJobQ(var p_rJJobQ: rtJJobQ);
//=============================================================================
begin
  with p_rJJobQ do begin
    JJobQ_JJobQ_UID           :=0;
    JJobQ_JUser_ID            :=0;
    JJobQ_JJobType_ID         :=0;
    JJobQ_Start_DT            :='';
    JJobQ_ErrorNo_u           :=0;
    JJobQ_Started_DT          :='';
    JJobQ_Running_b           :=false;
    JJobQ_Finished_DT         :='';
    JJobQ_Name                :='';
    JJobQ_Repeat_b            :=false;
    JJobQ_RepeatMinute        :='';
    JJobQ_RepeatHour          :='';
    JJobQ_RepeatDayOfMonth    :='';
    JJobQ_RepeatMonth         :='';
    JJobQ_Completed_b         :=false;
    JJobQ_Result_URL          :='';
    JJobQ_ErrorMsg            :='';
    JJobQ_ErrorMoreInfo       :='';
    JJobQ_Enabled_b           :=false;
    JJobQ_Job                 :='';
    JJobQ_Result              :='';
    JJobQ_CreatedBy_JUser_ID  :=0;
    JJobQ_Created_DT          :='';
    JJobQ_ModifiedBy_JUser_ID :=0;
    JJobQ_Modified_DT         :='';
    JJobQ_DeletedBy_JUser_ID  :=0;
    JJobQ_Deleted_DT          :='';
    JJobQ_Deleted_b           :=false;
    JAS_Row_b                 :=false;
    JJobQ_JTask_ID            :=0;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JLanguage(var p_rJLanguage: rtJLanguage);
//=============================================================================
begin
  with p_rJLanguage do begin
 	  JLang_JLanguage_UID        :=0;
 	  JLang_Name                 :='';
 	  JLang_NativeName           :='';
    JLang_Code                 :='';
 	  JLang_CreatedBy_JUser_ID   :=0;
 	  JLang_Created_DT           :='';
 	  JLang_ModifiedBy_JUser_ID  :=0;
 	  JLang_Modified_DT          :='';
 	  JLang_DeletedBy_JUser_ID   :=0;
 	  JLang_Deleted_DT           :='';
    JLang_Deleted_b            :=false;
 	  JAS_Row_b                  :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JLanguageLight(var p_rJLanguageLight: rtJLanguageLight);
//=============================================================================
begin
  with p_rJLanguageLight do begin
    u8JLanguage_UID        :=0;
    saName                 :='';
    saNativeName           :='';
    saCode                 :='';
  end;
end;
//=============================================================================




//=============================================================================
procedure clear_JLead(var p_rJLead: rtJLead);
//=============================================================================
begin
  with p_rJLead do begin
    JLead_JLead_UID           :=0;
    JLead_JLeadSource_ID      :=0;
    JLead_Owner_JUser_ID      :=0;
    JLead_Private_b           :=false;
    JLead_OrgName             :='';
    JLead_NameSalutation      :='';
    JLead_NameFirst           :='';
    JLead_NameMiddle          :='';
    JLead_NameLast            :='';
    JLead_NameSuffix          :='';
    JLead_Desc                :='';
    JLead_Gender              :='';
    JLead_Home_Phone          :='';
    JLead_Mobile_Phone        :='';
    JLead_Work_Email          :='';
    JLead_Work_Phone          :='';
    JLead_Fax                 :='';
    JLead_Home_Email          :='';
    JLead_Website             :='';
    JLead_Main_Addr1          :='';
    JLead_Main_Addr2          :='';
    JLead_Main_Addr3          :='';
    JLead_Main_City           :='';
    JLead_Main_State          :='';
    JLead_Main_PostalCode     :='';
    JLead_Main_Country        :='';
    JLead_Ship_Addr1          :='';
    JLead_Ship_Addr2          :='';
    JLead_Ship_Addr3          :='';
    JLead_Ship_City           :='';
    JLead_Ship_State          :='';
    JLead_Ship_PostalCode     :='';
    JLead_Ship_Country        :='';
    JLead_Exist_JOrg_ID       :=0;
    JLead_Exist_JPerson_ID    :=0;
    JLead_LeadSourceAddl      :='';
    JLead_CreatedBy_JUser_ID  :=0;
    JLead_Created_DT          :='';
    JLead_ModifiedBy_JUser_ID :=0;
    JLead_Modified_DT         :='';
    JLead_DeletedBy_JUser_ID  :=0;
    JLead_Deleted_DT          :='';
    JLead_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLeadSource(var p_rJLeadSource: rtJLeadSource);
//=============================================================================
begin
  with p_rJLeadSource do begin
    JLDSR_JLeadSource_UID     :=0;
    JLDSR_Name                :='';
    JLDSR_CreatedBy_JUser_ID  :=0;
    JLDSR_Created_DT          :='';
    JLDSR_ModifiedBy_JUser_ID :=0;
    JLDSR_Modified_DT         :='';
    JLDSR_DeletedBy_JUser_ID  :=0;
    JLDSR_Deleted_DT          :='';
    JLDSR_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLock(var p_rJLock: rtJLock);
//=============================================================================
begin
  with p_rJLock do begin
    JLock_JLock_UID           :=0;
    JLock_JSession_ID         :=0;
    JLock_JDConnection_ID     :=0;
    JLock_Locked_DT           :='';
    JLock_Table_ID            :=0;
    JLock_Row_ID              :=0;
    JLock_Col_ID              :=0;
    JLock_Username            :='';
    JLock_CreatedBy_JUser_ID  :=0;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLog(var p_rJLog: rtJLog);
//=============================================================================
begin
  with p_rJLog do begin
    JLOG_JLog_UID              :=0;
    JLOG_DateNTime_dt          :='';
    JLOG_JLogType_ID           :=0;
    JLOG_Entry_ID              :=0;
    JLOG_EntryData_s           :='';
    JLOG_SourceFile_s          :='';
    JLOG_User_ID               :=0;
    JLOG_CmdLine_s             :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLookup(var p_rJLookup: rtJLookup);
//=============================================================================
begin
  with p_rJLookup do begin
    JLook_JLookup_UID         :=0;
    JLook_Name                :='';
    JLook_Value               :='';
    JLook_Position_u          :=0;
    JLook_en                  :='';
    JLook_Created_DT          :='';
    JLook_ModifiedBy_JUser_ID :=0;
    JLook_Modified_DT         :='';
    JLook_DeletedBy_JUser_ID  :=0;
    JLook_Deleted_DT          :='';
    JLook_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JMail(var p_rJMail: rtJMail);
//=============================================================================
begin
  with p_rJMail do begin
    JMail_JMail_UID             := 0;
    JMail_Message               := '';
    JMail_To_User_ID            := 0;
    JMail_From_User_ID          := 0;
    JMail_Message               := '';
    JMail_Message_Code          := '';
    JMail_CreatedBy_JUser_ID    := 0;
    JMail_Created_DT            := '';
    JMail_ModifiedBy_JUser_ID   := 0;
    JMail_Modified_DT           := '';
    JMail_DeletedBy_JUser_ID    := 0;
    JMail_Deleted_DT            := '';
    JMail_Deleted_b             := false;
    JAS_Row_b                   := false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JMenu(var p_rJMenu: rtJMenu);
//=============================================================================
begin
  with p_rJMenu do begin
    JMenu_JMenu_UID                   :=0;
    JMenu_JMenuParent_ID              :=0;
    JMenu_JSecPerm_ID                 :=0;
    JMenu_Name                        :='';
    JMenu_URL                         :='';
    JMenu_NewWindow_b                 :=false;
    JMenu_IconSmall                   :='';
    JMenu_IconLarge                   :='';
    JMenu_ValidSessionOnly_b          :=false;
    JMenu_SEQ_u                       :=0;
    JMenu_DisplayIfNoAccess_b         :=false;
    JMenu_DisplayIfValidSession_b     :=false;
    JMenu_IconLarge_Theme_b           :=false;
    JMenu_IconSmall_Theme_b           :=false;
    JMenu_ReadMore_b                  :=false;
    JMenu_Title_en                    :='';
    JMenu_Data_en                     :='';
    JMenu_CreatedBy_JUser_ID          :=0;
    JMenu_Created_DT                  :='';
    JMenu_ModifiedBy_JUser_ID         :=0;
    JMenu_Modified_DT                 :='';
    JMenu_DeletedBy_JUser_ID          :=0;
    JMenu_Deleted_DT                  :='';
    JMenu_Deleted_b                   :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModC(var p_rJModC: rtJModC);
//=============================================================================
begin
  with p_rJModC do begin
    JModC_JModC_UID           :=0;
    JModC_JInstalled_ID       :=0;
    JModC_Column_ID           :=0;
    JModC_Row_ID              :=0;
    JModC_CreatedBy_JUser_ID  :=0;
    JModC_Created_DT          :='';
    JModC_ModifiedBy_JUser_ID :=0;
    JModC_Modified_DT         :='';
    JModC_DeletedBy_JUser_ID  :=0;
    JModC_Deleted_DT          :='';
    JModC_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModule(var p_rJModule: rtJModule);
//=============================================================================
begin
  with p_rJModule do begin
    JModu_JModule_UID         :=0;
    JModu_Name                :='';
    JModu_Version_Major_u     :=0;
    JModu_Version_Minor_u     :=0;
    JModu_Version_Revision_u  :=0;
    JModu_CreatedBy_JUser_ID  :=0;
    JModu_Created_DT          :='';
    JModu_ModifiedBy_JUser_ID :=0;
    JModu_Modified_DT         :='';
    JModu_DeletedBy_JUser_ID  :=0;
    JModu_Deleted_DT          :='';
    JModu_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModuleConfig(var p_rJModuleConfig: rtJModuleConfig);
//=============================================================================
begin
  with p_rJModuleConfig do begin
    JMCfg_JModuleConfig_UID   :=0;
    JMCfg_JModuleSetting_ID   :=0;
    JMCfg_Value               :='';
    JMCfg_JNote_ID            :=0;
    JMCfg_JInstalled_ID       :=0;
    JMCfg_JUser_ID            :=0;
    JMCfg_Read_JSecPerm_ID    :=0;
    JMCfg_Write_JSecPerm_ID   :=0;
    JMCfg_CreatedBy_JUser_ID  :=0;
    JMCfg_Created_DT          :='';
    JMCfg_ModifiedBy_JUser_ID :=0;
    JMCfg_Modified_DT         :='';
    JMCfg_DeletedBy_JUser_ID  :=0;
    JMCfg_Deleted_DT          :='';
    JMCfg_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModuleSetting(var p_rJModuleSetting: rtJModuleSetting);
//=============================================================================
begin
  with p_rJModuleSetting do begin
    JMSet_JModuleSetting_UID  :=0;
    JMSet_Name                :='';
    JMSet_JCaption_ID         :=0;
    JMSet_JNote_ID            :=0;
    JMSet_JModule_ID          :=0;
    JMSet_CreatedBy_JUser_ID  :=0;
    JMSet_Created_DT          :='';
    JMSet_ModifiedBy_JUser_ID :=0;
    JMSet_Modified_DT         :='';
    JMSet_DeletedBy_JUser_ID  :=0;
    JMSet_Deleted_DT          :='';
    JMSet_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JNote(var p_rJNote: rtJNote);
//=============================================================================
begin
  with p_rJNote do begin
    JNote_JNote_UID           :=0;
    JNote_JTable_ID           :=0;
    JNote_JColumn_ID          :=0;
    JNote_Row_ID              :=0;
    JNote_Orphan_b            :=false;
    JNote_en                  :='';
    JNote_Created_DT          :='';
    JNote_CreatedBy_JUser_ID  :=0;
    JNote_Modified_DT         :='';
    JNote_ModifiedBy_JUser_ID :=0;
    JNote_DeletedBy_JUser_ID  :=0;
    JNote_Deleted_DT          :='';
    JNote_Deleted_b           :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JPassword(var p_rJPassword: rtJPassword);
//=============================================================================
begin
  with p_rJPassword do begin
    JPass_JPassword_UID         :=0;
    JPass_Name                  :='';
    JPass_Desc                  :='';
    JPass_URL                   :='';
    JPass_Owner_JUser_ID        :=0;
    JPass_Private_Memo          :='';
    JPass_JSecPerm_ID           :=0;
    JPass_CreatedBy_JUser_ID    :=0;
    JPass_Created_DT            :='';
    JPass_ModifiedBy_JUser_ID   :=0;
    JPass_Modified_DT           :='';
    JPass_DeletedBy_JUser_ID    :=0;
    JPass_Deleted_DT            :='';
    JPass_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JPerson(var p_rJPerson: rtJPerson);
//=============================================================================
begin
  with p_rJPerson do begin
    JPers_JPerson_UID                 :=0;
    JPers_Desc                        :='';
    JPers_NameSalutation              :='';
    JPers_NameFirst                   :='';
    JPers_NameMiddle                  :='';
    JPers_NameLast                    :='';
    JPers_NameSuffix                  :='';
    JPers_NameDear                    :='';
    JPers_Gender                      :='';
    JPers_Private_b                   :=false;
    JPers_Addr1                       :='';
    JPers_Addr2                       :='';
    JPers_Addr3                       :='';
    JPers_City                        :='';
    JPers_State                       :='';
    JPers_PostalCode                  :='';
    JPers_Country                     :='';
    JPers_Home_Email                  :='';
    JPers_Home_Phone                  :='';
    JPers_Latitude_d                  :=0;
    JPers_Longitude_d                 :=0;
    JPers_Mobile_Phone                :='';
    JPers_Work_Email                  :='';
    JPers_Work_Phone                  :='';
    JPers_Customer_b                  :=false;
    JPers_Vendor_b                    :=false;
    JPers_Primary_Org_ID              :=0;
    JPers_DOB_DT                      :='';
    JPers_CC                          :='';
    JPers_CCExpire                    :='';
    JPers_CCSecCode                   :='';
    JPers_CreatedBy_JUser_ID          :=0;
    JPers_Created_DT                  :='';
    JPers_ModifiedBy_JUser_ID         :=0;
    JPers_Modified_DT                 :='';
    JPers_DeletedBy_JUser_ID          :=0;
    JPers_Deleted_DT                  :='';
    JPers_Deleted_b                   :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JPriority(var p_rJPriority: rtJPriority);
//=============================================================================
begin
  with p_rJPriority do begin
    JPrio_JPriority_UID       :=0;
    JPrio_en                  :='';
    JPrio_CreatedBy_JUser_ID  :=0;
    JPrio_Created_DT          :='';
    JPrio_ModifiedBy_JUser_ID :=0;
    JPrio_Modified_DT         :='';
    JPrio_DeletedBy_JUser_ID  :=0;
    JPrio_Deleted_DT          :='';
    JPrio_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JProduct(var p_rJProduct: rtJProduct);
//=============================================================================
begin
  with p_rJProduct do begin
    JProd_JProduct_UID          :=0;
    JProd_Number                :='';
    JProd_Name                  :='';
    JProd_Desc                  :='';
    JProd_CreatedBy_JUser_ID    :=0;
    JProd_Created_DT            :='';
    JProd_ModifiedBy_JUser_ID   :=0;
    JProd_Modified_DT           :='';
    JProd_DeletedBy_JUser_ID    :=0;
    JProd_Deleted_DT            :='';
    JProd_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProductGrp(var p_rJProductGrp: rtJProductGrp);
//=============================================================================
begin
  with p_rJProductGrp do begin
    JPrdG_JProductGrp_UID     :=0;
    JPrdG_Name                :='';
    JPrdG_Desc                :='';
    JPrdG_CreatedBy_JUser_ID  :=0;
    JPrdG_Created_DT          :='';
    JPrdG_ModifiedBy_JUser_ID :=0;
    JPrdG_Modified_DT         :='';
    JPrdG_DeletedBy_JUser_ID  :=0;
    JPrdG_Deleted_DT          :='';
    JPrdG_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProductQty(var p_rJProductQty: rtJProductQty);
//=============================================================================
begin
  with p_rJProductQty do begin
    JPrdQ_JProductQty_UID     :=0;
    JPrdQ_Location_JOrg_ID    :=0;
    JPrdQ_QtyOnHand_d         :=0;
    JPrdQ_QtyOnOrder_d        :=0;
    JPrdQ_QtyOnBackOrder_d    :=0;
    JPrdQ_JProduct_ID         :=0;
    JPrdQ_CreatedBy_JUser_ID  :=0;
    JPrdQ_Created_DT          :='';
    JPrdQ_ModifiedBy_JUser_ID :=0;
    JPrdQ_Modified_DT         :='';
    JPrdQ_DeletedBy_JUser_ID  :=0;
    JPrdQ_Deleted_DT          :='';
    JPrdQ_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProject(var p_rJProject: rtJProject);
//=============================================================================
begin
  with p_rJProject do begin
    JProj_JProject_UID          :=0;
    JProj_Name                  :='';
    JProj_Owner_JUser_ID        :=0;
    JProj_URL                   :='';
    JProj_URL_Stage             :='';
    JProj_JProjectStatus_ID     :=0;
    JProj_JProjectPriority_ID   :=0;
    JProj_JProjectCategory_ID   :=0;
    JProj_Progress_PCT_d        :=0;
    JProj_Hours_Worked_d        :=0;
    JProj_Hours_Sched_d         :=0;
    JProj_Hours_Project_d       :=0;
    JProj_Desc                  :='';
    JProj_Start_DT              :='';
    JProj_Target_End_DT         :='';
    JProj_Actual_End_DT         :='';
    JProj_Target_Budget_d       :=0;
    JProj_JOrg_ID               :=0;
    JProj_JPerson_ID            :=0;
    JProj_CreatedBy_JUser_ID    :=0;
    JProj_Created_DT            :='';
    JProj_ModifiedBy_JUser_ID   :=0;
    JProj_Modified_DT           :='';
    JProj_DeletedBy_JUser_ID    :=0;
    JProj_Deleted_DT            :='';
    JProj_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProjectCategory(var p_rJProjectCategory: rtJProjectCategory);
//=============================================================================
begin
  with p_rJProjectCategory do begin
    JPjCt_JProjectCategory_UID :=0;
    JPjCt_Name                 :='';
    JPjCt_Desc                 :='';
    JPjCt_JCaption_ID          :=0;
    JPjCt_CreatedBy_JUser_ID   :=0;
    JPjCt_Created_DT           :='';
    JPjCt_ModifiedBy_JUser_ID  :=0;
    JPjCt_Modified_DT          :='';
    JPjCt_DeletedBy_JUser_ID   :=0;
    JPjCt_Deleted_DT           :='';
    JPjCt_Deleted_b            :=false;
    JAS_Row_b                  :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JQuickLink(p_rJQuickLink: rtJQuickLink);
//=============================================================================
begin
  with p_rJQuickLink do begin
    JQLnk_JQuickLink_UID          := 0;
    JQLnk_Name                    := '';
    JQLnk_SecPerm_ID              := 0;
    JQLnk_Desc                    := '';
    JQLnk_URL                     := '';
    JQLnk_Icon                    := '';
    JQLnk_Owner_JUser_ID          := 0;
    JQLnk_Position_u              := 0;
    JQLnk_ValidSessionOnly_b      := false;
    JQLnk_DisplayIfNoAccess_b     := false;
    JQLnk_DisplayIfValidSession_b := false;
    JQLnk_RenderAsUniqueDiv_b     := false;
    JQLnk_Private_Memo            := '';
    JQLnk_Private_b               := false;
    JQLnk_CreatedBy_JUser_ID      := 0;
    JQLnk_Created_DT              := '';
    JQLnk_ModifiedBy_JUser_ID     := 0;
    JQLnk_Modified_DT             := '';
    JQLnk_DeletedBy_JUser_ID      := 0;
    JQLnk_Deleted_b               := false;
    JQLnk_Deleted_DT              := '';
    JAS_Row_b                     := false;
  end;
end;
//=============================================================================


//=============================================================================
procedure clear_JRedirect(var p_rJRedirect: rtJRedirect);
//=============================================================================
begin
  with p_rJRedirect do begin
    REDIR_Jredirect_UID       :=0;
    REDIR_CreatedBy_JUser_ID  :=0;
    REDIR_Created_DT          :='';
    REDIR_ModifiedBy_JUser_ID :=0;
    REDIR_Modified_DT         :='';
    REDIR_DeletedBy_JUser_ID  :=0;
    REDIR_Deleted_DT          :='';
    REDIR_Deleted_b           :=false;
    JAS_Row_b                 :=false;;
    REDIR_JRedirectLU_ID      :=0;
    REDIR_Location            :='';
    REDIR_NewLocation         :='';
    REDIR_JVHost_ID           :=0;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JScreen(var p_rJScreen: rtJScreen);
//=============================================================================
begin
  with p_rJScreen do begin
    JScrn_JScreen_UID         :=0;
    JScrn_Name                :='';
    JScrn_Desc                :='';
    JScrn_JCaption_ID         :=0;
    JScrn_JScreenType_ID      :=0;
    JScrn_Template            :='';
    JScrn_ValidSessionOnly_b  :=false;
    JScrn_JSecPerm_ID         :=0;
    JScrn_Detail_JScreen_ID   :=0;
    JScrn_IconSmall           :='';
    JScrn_IconLarge           :='';
    JScrn_TemplateMini        :='';
    JScrn_Modify_JSecPerm_ID  :=0;
    JScrn_Help_ID             :=0;
    JScrn_CreatedBy_JUser_ID  :=0;
    JScrn_Created_DT          :='';
    JScrn_ModifiedBy_JUser_ID :=0;
    JScrn_Modified_DT         :='';
    JScrn_DeletedBy_JUser_ID  :=0;
    JScrn_Deleted_DT          :='';
    JScrn_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JScreenType(var p_rJScreenType: rtJScreenType);
//=============================================================================
begin
  with p_rJScreenType do begin
    JScTy_JScreenType_UID     :=0;
    JScTy_Name                :='';
    JScTy_CreatedBy_JUser_ID  :=0;
    JScTy_Created_DT          :='';
    JScTy_ModifiedBy_JUser_ID :=0;
    JScTy_Modified_DT         :='';
    JScTy_DeletedBy_JUser_ID  :=0;
    JScTy_Deleted_DT          :='';
    JScTy_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrp(var p_rJSecGrp: rtJSecGrp);
//=============================================================================
begin
  with p_rJSecGrp do begin
    JSGrp_JSecGrp_UID           :=0;
    JSGrp_Name                  :='';
    JSGrp_Desc                  :='';
    JSGrp_CreatedBy_JUser_ID    :=0;
    JSGrp_Created_DT            :='';
    JSGrp_ModifiedBy_JUser_ID   :=0;
    JSGrp_Modified_DT           :='';
    JSGrp_DeletedBy_JUser_ID    :=0;
    JSGrp_Deleted_DT            :='';
    JSGrp_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrpLink(var p_rJSecGrpLink: rtJSecGrpLink);
//=============================================================================
begin
  with p_rJSecGrpLink do begin
    JSGLk_JSecGrpLink_UID     :=0;
    JSGLk_JSecPerm_ID         :=0;
    JSGLk_JSecGrp_ID          :=0;
    JSGLk_CreatedBy_JUser_ID  :=0;
    JSGLk_Created_DT          :='';
    JSGLk_ModifiedBy_JUser_ID :=0;
    JSGLk_Modified_DT         :='';
    JSGLk_DeletedBy_JUser_ID  :=0;
    JSGLk_Deleted_DT          :='';
    JSGLk_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrpUserLink(var p_rJSecGrpUserLink: rtJSecGrpUserLink);
//=============================================================================
begin
  with p_rJSecGrpUserLink do begin
    JSGUL_JSecGrpUserLink_UID   :=0;
    JSGUL_JSecGrp_ID            :=0;
    JSGUL_JUser_ID              :=0;
    JSGUL_CreatedBy_JUser_ID    :=0;
    JSGUL_Created_DT            :='';
    JSGUL_ModifiedBy_JUser_ID   :=0;
    JSGUL_Modified_DT           :='';
    JSGUL_DeletedBy_JUser_ID    :=0;
    JSGUL_Deleted_DT            :='';
    JSGUL_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JSecKey(var p_rJSecKey: rtJSecKey);
//=============================================================================
begin
  with p_rJSecKey do begin
    JSKey_JSecKey_UID           :=0;
    JSKey_KeyPub                :='';
    JSKey_KeyPvt                :='';
    JSKey_CreatedBy_JUser_ID    :=0;
    JSKey_Created_DT            :='';
    JSKey_ModifiedBy_JUser_ID   :=0;
    JSKey_Modified_DT           :='';
    JSKey_DeletedBy_JUser_ID    :=0;
    JSKey_Deleted_DT            :='';
    JSKey_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;
end;
//=============================================================================


//=============================================================================
procedure clear_JSecPerm(var p_rJSecPerm: rtJSecPerm);
//=============================================================================
begin
  with p_rJSecPerm do begin
    Perm_JSecPerm_UID        :=0;
    Perm_Name                :='';
    Perm_CreatedBy_JUser_ID  :=0;
    Perm_Created_DT          :='';
    Perm_ModifiedBy_JUser_ID :=0;
    Perm_Modified_DT         :='';
    Perm_DeletedBy_JUser_ID  :=0;
    Perm_Deleted_DT          :='';
    Perm_Deleted_b           :=false;
    JAS_Row_b                :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecPermUserLink(var p_rJSecPermUserLink: rtJSecPermUserLink);
//=============================================================================
begin
  with p_rJSecPermUserLink do begin
    JSPUL_JSecPermUserLink_UID  :=0;
    JSPUL_JSecPerm_ID           :=0;
    JSPUL_JUser_ID              :=0;
    JSPUL_CreatedBy_JUser_ID    :=0;
    JSPUL_Created_DT            :='';
    JSPUL_ModifiedBy_JUser_ID   :=0;
    JSPUL_Modified_DT           :='';
    JSPUL_DeletedBy_JUser_ID    :=0;
    JSPUL_Deleted_DT            :='';
    JSPUL_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSession(var p_rJSession: rtJSession);
//=============================================================================
begin
  with p_rJSession do begin
    JSess_JSession_UID        :=0;
    JSess_JSessionType_ID     :=0;
    JSess_JUser_ID            :=0;
    JSess_Connect_DT          :='';
    JSess_LastContact_DT      :='';
    JSess_IP_ADDR             :='';
    JSess_PORT_u              :=0;
    JSess_Username            :='';
    JSess_JJobQ_ID            :=0;
    JSess_HTTP_USER_AGENT     :='';
    JSess_HTTP_ACCEPT         :='';
    JSess_HTTP_ACCEPT_LANGUAGE:='';
    JSess_HTTP_ACCEPT_ENCODING:='';
    JSess_HTTP_CONNECTION     :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JSessionData(var p_rJSessionData: rtJSessionData);
//=============================================================================
begin
  with p_rJSessionData do begin
    JSDat_JSessionData_UID      :=0;
    JSDat_JSession_ID           :=0;
    JSDat_Name                  :='';
    JSDat_Value                 :='';
    JSDat_CreatedBy_JUser_ID    :=0;
    JSDat_Created_DT            :='';
  end;
end;
//=============================================================================



//=============================================================================
procedure clear_JSessionType(var p_rJSessionType: rtJSessionType);
//=============================================================================
begin
  with p_rJSessionType do begin
    JSTyp_JSessionType_UID    :=0;
    JSTyp_Name                :='';
    JSTyp_Desc                :='';
    JSTyp_CreatedBy_JUser_ID  :=0;
    JSTyp_Created_DT          :='';
    JSTyp_ModifiedBy_JUser_ID :=0;
    JSTyp_Modified_DT         :='';
    JSTyp_DeletedBy_JUser_ID  :=0;
    JSTyp_Deleted_DT          :='';
    JSTyp_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JSysModule(var p_rJSysModule: rtJSysModule);
//=============================================================================
begin
  with p_rJSysModule do begin
    JSysM_JSysModule_UID      :=0;
    JSysM_Name                :='';
    JSysM_CreatedBy_JUser_ID  :=0;
    JSysM_Created_DT          :='';
    JSysM_ModifiedBy_JUser_ID :=0;
    JSysM_Modified_DT         :='';
    JSysM_DeletedBy_JUser_ID  :=0;
    JSysM_Deleted_DT          :='';
    JSysM_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JTable(var p_rJTable: rtJTable);
//=============================================================================
begin
  with p_rJTable do begin
    JTabl_JTable_UID          :=0;
    JTabl_Name                :='';
    JTabl_Desc                :='';
    JTabl_JTableType_ID       :=0;
    JTabl_JDConnection_ID     :=0;
    JTabl_ColumnPrefix        :='';
    JTabl_DupeScore_u         :=0;
    JTabl_Perm_JColumn_ID     :=0;
    JTabl_Owner_Only_b        :=false;
    JTabl_View_MySQL          :='';
    JTabl_View_MSSQL          :='';
    JTabl_View_MSAccess       :='';
    JTabl_Add_JSecPerm_ID     :=0;
    JTabl_Update_JSecPerm_ID  :=0;
    JTabl_View_JSecPerm_ID    :=0;
    JTabl_Delete_JSecPerm_ID  :=0;
    JTabl_CreatedBy_JUser_ID  :=0;
    JTabl_Created_DT          :='';
    JTabl_ModifiedBy_JUser_ID :=0;
    JTabl_Modified_DT         :='';
    JTabl_DeletedBy_JUser_ID  :=0;
    JTabl_Deleted_DT          :='';
    JTabl_Deleted_b           :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JTableType(var p_rJTableType: rtJTableType);
//=============================================================================
begin
  with p_rJTableType do begin
    JTTyp_JTableType_UID      :=0;
    JTTyp_Name                :='';
    JTTyp_Desc                :='';
    JTTyp_CreatedBy_JUser_ID  :=0;
    JTTyp_Created_DT          :='';
    JTTyp_ModifiedBy_JUser_ID :=0;
    JTTyp_Modified_DT         :='';
    JTTyp_DeletedBy_JUser_ID  :=0;
    JTTyp_Deleted_DT          :='';
    JTTyp_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTask(var p_rJTask: rtJTask);
//=============================================================================
begin
  with p_rJTask do begin
    JTask_JTask_UID                  :=0;
    JTask_Name                       :='';
    JTask_Desc                       :='';
    JTask_JTaskCategory_ID           :=0;
    JTask_JProject_ID                :=0;
    JTask_JStatus_ID                 :=0;
    JTask_Due_DT                     :='';
    JTask_Duration_Minutes_Est       :=0;
    JTask_JPriority_ID               :=0;
    JTask_Start_DT                   :='';
    JTask_Owner_JUser_ID             :=0;
    JTask_SendReminder_b             :=false;
    JTask_ReminderSent_b             :=false;
    JTask_ReminderSent_DT            :='';
    JTask_Remind_DaysAhead_u         :=0;
    JTask_Remind_HoursAhead_u        :=0;
    JTask_Remind_MinutesAhead_u      :=0;
    JTask_Remind_Persistantly_b      :=false;
    JTask_Progress_PCT_d             :=0;
    JTask_JCase_ID                   :=0;
    JTask_Directions_URL             :='';
    JTask_URL                        :='';
    JTask_Milestone_b                :=false;
    JTask_Budget_d                   :=0;
    JTask_ResolutionNotes            :='';
    JTask_Completed_DT               :='';
    JTask_Related_JTable_ID          :=0;
    JTask_Related_Row_ID             :=0;
    JTask_CreatedBy_JUser_ID         :=0;
    JTask_Created_DT                 :='';
    JTask_ModifiedBy_JUser_ID        :=0;
    JTask_Modified_DT                :='';
    JTask_DeletedBy_JUser_ID         :=0;
    JTask_Deleted_DT                 :='';
    JTask_Deleted_b                  :=false;
    JAS_Row_b                        :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTaskCategory(var p_rJTaskCategory: rtJTaskCategory);
//=============================================================================
begin
  with p_rJTaskCategory do begin
    JTCat_JTaskCategory_UID   :=0;
    JTCat_Name                :='';
    JTCat_Desc                :='';
    JTCat_JCaption_ID         :=0;
    JTCat_CreatedBy_JUser_ID  :=0;
    JTCat_Created_DT          :='';
    JTCat_ModifiedBy_JUser_ID :=0;
    JTCat_Modified_DT         :='';
    JTCat_DeletedBy_JUser_ID  :=0;
    JTCat_Deleted_DT          :='';
    JTCat_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JStatus(var p_rJStatus: rtJStatus);
//=============================================================================
begin
  with p_rJStatus do begin
    JStat_JStatus_UID         :=0;
    JStat_Name                :='';
    JStat_Desc                :='';
    JStat_JCaption_ID         :=0;
    JStat_CreatedBy_JUser_ID  :=0;
    JStat_Created_DT          :='';
    JStat_ModifiedBy_JUser_ID :=0;
    JStat_Modified_DT         :='';
    JStat_DeletedBy_JUser_ID  :=0;
    JStat_Deleted_DT          :='';
    JStat_Deleted_b           :=false;
    JAS_Row_b                 :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTimecard(var p_rJTimecard: rtJTimecard);
//=============================================================================
begin
  with p_rJTimecard do begin
    TMCD_TimeCard_UID                 :=0;
    TMCD_Name                         :='';
    TMCD_In_DT                        :='';
    TMCD_Out_DT                       :='';
    TMCD_JNote_Public_ID              :=0;
    TMCD_JNote_Internal_ID            :=0;
    TMCD_Reference                    :='';
    TMCD_JProject_ID                  :=0;
    TMCD_JTask_ID                     :=0;
    TMCD_Billable_b                   :=false;
    TMCD_ManualEntry_b                :=false;
    TMCD_ManualEntry_DT               :='';
    TMCD_Exported_b                   :=false;
    TMCD_Exported_DT                  :='';
    TMCD_Uploaded_b                   :=false;
    TMCD_Uploaded_DT                  :='';
    TMCD_PayrateName                  :='';
    TMCD_Payrate_d                    :=0;
    TMCD_Expense_b                    :=false;
    TMCD_Imported_b                   :=false;
    TMCD_Imported_DT                  :='';
    TMCD_Note_Internal                :='';
    TMCD_Note_Public                  :='';
    TMCD_Invoice_Sent_b               :=false;
    TMCD_Invoice_Paid_b               :=false;
    TMCD_Invoice_No                   :='';
    TMCD_CreatedBy_JUser_ID           :=0;
    TMCD_Created_DT                   :='';
    TMCD_ModifiedBy_JUser_ID          :=0;
    TMCD_Modified_DT                  :='';
    TMCD_DeletedBy_JUser_ID           :=0;
    TMCD_Deleted_DT                   :='';
    TMCD_Deleted_b                    :=false;
    JAS_Row_b                         :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTeam(var p_rJTeam: rtJTeam);
//=============================================================================
begin
  with p_rJTeam do begin
    JTeam_JTeam_UID             :=0;
    JTeam_Parent_JTeam_ID       :=0;
    JTeam_JOrg_ID               :=0;
    JTeam_Name                  :='';
    JTeam_Desc                  :='';
    JTeam_CreatedBy_JUser_ID    :=0;
    JTeam_Created_DT            :='';
    JTeam_ModifiedBy_JUser_ID   :=0;
    JTeam_Modified_DT           :='';
    JTeam_DeletedBy_JUser_ID    :=0;
    JTeam_Deleted_DT            :='';
    JTeam_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTeamMember(var p_rJTeamMember: rtJTeamMember);
//=============================================================================
begin
  with p_rJTeamMember do begin
    JTMem_JTeamMember_UID       :=0;
    JTMem_JTeam_ID              :=0;
    JTMem_JPerson_ID            :=0;
    JTMem_JOrg_ID               :=0;
    JTMem_JUser_ID              :=0;
    JTMem_CreatedBy_JUser_ID    :=0;
    JTMem_Created_DT            :='';
    JTMem_ModifiedBy_JUser_ID   :=0;
    JTMem_Modified_DT           :='';
    JTMem_DeletedBy_JUser_ID    :=0;
    JTMem_Deleted_DT            :='';
    JTMem_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTestOne(var p_rJTestOne: rtJTestOne);
//=============================================================================
begin
  with p_rJTestOne do begin
    JTes1_JTestOne_UID          :=0;
    JTes1_Text                  :='';
    JTes1_Boolean_b             :='';
    JTes1_Memo                  :='';
    JTes1_DateTime_DT           :='';
    JTes1_Integer_i             :='';
    JTes1_Currency_d            :=0;
    JTes1_Memo2                 :='';
    JTes1_Added_DT              :='';
    JTes1_RemoteIP              :='';
    JTes1_RemotePort_u          :='';
    JTes1_CreatedBy_JUser_ID    :=0;
    JTes1_Created_DT            :='';
    JTes1_ModifiedBy_JUser_ID   :=0;
    JTes1_Modified_DT           :='';
    JTes1_DeletedBy_JUser_ID    :=0;
    JTes1_Deleted_DT            :='';
    JTes1_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_jtheme(var p_rJTheme: rtJTheme);
//=============================================================================
begin
  with p_rJTheme do begin
    Theme_Name                  :='';
    Theme_Desc                  :='';
    Theme_Template_Header       :='';
    Theme_CreatedBy_JUser_ID    :=0;
    Theme_Created_DT            :='';
    Theme_ModifiedBy_JUser_ID   :=0;
    Theme_Modified_DT           :='';
    Theme_DeletedBy_JUser_ID    :=0;
    Theme_Deleted_DT            :='';
    Theme_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;
end;
//=============================================================================



//=============================================================================
{}
procedure clear_jthemelight(var p_rJThemeLight: rtJThemeLight);
//=============================================================================
begin
  with p_rJThemeLight do begin
    u8JTheme_UID       :=0;
    saName             :='';
    saTemplate_Header  :='';
  end;
end;
//=============================================================================



//=============================================================================
procedure clear_JTrak(var p_rJTrak: rtJTrak);
//=============================================================================
begin
  with p_rJTrak do begin
    JTrak_JTrak_UID           :=0;
    JTrak_JDConnection_ID     :=0;
    JTrak_JSession_ID         :=0;
    JTrak_JTable_ID           :=0;
    JTrak_Row_ID              :=0;
    JTrak_Col_ID              :=0;
    JTrak_JUser_ID            :=0;
    JTrak_Create_b            :=false;
    JTrak_Modify_b            :=false;
    JTrak_Delete_b            :=false;
    JTrak_When_DT             :='';
    JTrak_Before              :='';
    JTrak_After               :='';
    JTrak_SQL                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JUser(var p_rJUser: rtJUser);
//=============================================================================
begin
  with p_rJUser do begin
    JUser_JUser_UID              :=0;
    JUser_Name                   :='';
    JUser_Password               :='';
    JUser_JPerson_ID             :=0;
    JUser_Enabled_b              :=false;
    JUser_Admin_b                :=false;
    JUser_Login_First_DT         :='';
    JUser_Login_Last_DT          :='';
    JUser_Logins_Successful_u    :=0;
    JUser_Logins_Failed_u        :=0;
    JUser_Password_Changed_DT    :='';
    JUser_AllowedSessions_u      :=0;
    JUser_DefaultPage_Login      :='';
    JUser_DefaultPage_Logout     :='';
    JUser_JLanguage_ID           :=0;
    JUser_Audit_b                :=false;
    JUser_ResetPass_u            :=0;
    JUser_JVHost_ID              :=0;
    JUser_TotalJetUsers_u        :=0;
    JUser_SIP_Exten              :='';
    JUser_SIP_Pass               :='';
    JUser_Headers_b              :=true;
    JUser_QuickLinks_b           :=true;
    JUser_IconTheme              :='';
    JUser_Theme                  :='';
    JUser_Background             :='';
    JUser_BackgroundRepeat_b     :=false;
    JUser_CreatedBy_JUser_ID     :=0;
    JUser_Created_DT             :='';
    JUser_ModifiedBy_JUser_ID    :=0;
    JUser_Modified_DT            :='';
    JUser_DeletedBy_JUser_ID     :=0;
    JUser_Deleted_DT             :='';
    JUser_Deleted_b              :=false;
    JAS_Row_b                    :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JUserPref(var p_rJUserPref: rtJUserPref);
//=============================================================================
begin
  with p_rJUserPref do begin
    UserP_UserPref_UID          :=0;
    UserP_Name                  :='';
    UserP_Desc                  :='';
    UserP_CreatedBy_JUser_ID    :=0;
    UserP_Created_DT            :='';
    UserP_ModifiedBy_JUser_ID   :=0;
    UserP_Modified_DT           :='';
    UserP_DeletedBy_JUser_ID    :=0;
    UserP_Deleted_DT            :='';
    UserP_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JUserPrefLink(var p_rJUserPrefLink: rtJUserPrefLink);
//=============================================================================
begin
  with p_rJUserPrefLink do begin
    UsrPL_UserPrefLink_UID      :=0;
    UsrPL_UserPref_ID           :=0;
    UsrPL_User_ID               :=0;
    UsrPL_Value                 :='';
    UsrPL_CreatedBy_JUser_ID    :=0;
    UsrPL_Created_DT            :='';
    UsrPL_ModifiedBy_JUser_ID   :=0;
    UsrPL_Modified_DT           :='';
    UsrPL_DeletedBy_JUser_ID    :=0;
    UsrPL_Deleted_DT            :='';
    UsrPL_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JWidget(var p_rJWidget: rtJWidget);
//=============================================================================
begin
  with p_rJWidget do begin
    JWidg_JWidget_UID           :=0;
    JWidg_Name                  :='';
    JWidg_Procedure             :='';
    JWidg_Desc                  :='';
    JWidg_CreatedBy_JUser_ID    :=0;
    JWidg_Created_DT            :='';
    JWidg_ModifiedBy_JUser_ID   :=0;
    JWidg_Modified_DT           :='';
    JWidg_DeletedBy_JUser_ID    :=0;
    JWidg_Deleted_DT            :='';
    JWidg_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JWidgetLink(var p_rJWidgetLink: rtJWidgetLink);
//=============================================================================
begin
  with p_rJWidgetLink do begin
    JWLnk_JWidgetLink_UID       :=0;
    JWLnk_JWidget_ID            :=0;
    JWLnk_JDType_ID             :=0;
    JWLnk_JBlokType_ID          :=0;
    JWLnk_JInterface_ID         :=0;
    JWLnk_CreatedBy_JUser_ID    :=0;
    JWLnk_Created_DT            :='';
    JWLnk_ModifiedBy_JUser_ID   :=0;
    JWLnk_Modified_DT           :='';
    JWLnk_DeletedBy_JUser_ID    :=0;
    JWLnk_Deleted_DT            :='';
    JWLnk_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JWorkQueue(var p_rJWorkQueue: rtJWorkQueue);
//=============================================================================
begin
  with p_rJWorkQueue do begin
    JWrkQ_JWorkQueue_UID          :=0; //uid
    JWrkQ_JUser_ID                :=0; //user who caused job
    JWrkQ_Posted_DT               :=''; //when job submitted
    JWrkQ_Started_DT              :=''; //when actual processing of job started
    JWrkQ_Finished_DT             :=''; //when actual processing of job finished
    JWrkQ_Delivered_DT            :=''; //when results of job delivered
    JWrkQ_Job_GUID                :=0; // GUID for the job
    JWrkQ_Confirmed_b             :=false; // boolean indicating job confirmed as successful via GUID exchange
    JWrkQ_Confirmed_DT            :=''; // datetime job success confirmed. Note, if this datetime is not null but confirmed = false then this means job failed
    JWrkQ_JobType_ID              :=0; // Job Type ID
    JWrkQ_JobDesc                 :=''; // Short Description of job (255 char max)
    JWrkQ_Src_JUser_ID            :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_JDConnection_ID     :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_JTable_ID           :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Row_ID              :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Column_ID           :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Data                :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_RemoteIP            :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_RemotePort_u        :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JUser_ID           :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JDConnection_ID    :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JTable_ID          :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Row_ID             :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Column_ID          :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Data               :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_RemoteIP           :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_RemotePort_u       :=0; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_CreatedBy_JUser_ID      :=0;
    JWrkQ_Created_DT              :='';
    JWrkQ_ModifiedBy_JUser_ID     :=0;
    JWrkQ_Modified_DT             :='';
    JWrkQ_DeletedBy_JUser_ID      :=0;
    JWrkQ_Deleted_DT              :='';
    JWrkQ_Deleted_b               :=false;
    JAS_Row_b                     :=false;
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JVHost(var p_rJVHost: rtJVHost);
//=============================================================================
begin
  with p_rJVHost do begin
    VHost_JVHost_UID               := 0;
    VHost_WebRootDir               := '';
    VHost_ServerName               := '';
    VHost_ServerIdent              := '';
    VHost_ServerDomain             := '';
    VHost_DefaultLanguage          := '';
    VHost_DefaultTheme             := '';
    VHost_MenuRenderMethod         := 0;
    VHost_DefaultArea              := '';
    VHost_DefaultPage              := '';
    VHost_DefaultSection           := '';
    VHost_DefaultTop_JMenu_ID      := 0;
    VHost_DefaultLoggedInPage      := '';
    VHost_DefaultLoggedOutPage     := '';
    VHost_DataOnRight_b            := false;
    VHost_CacheMaxAgeInSeconds     := 0;
    VHost_SystemEmailFromAddress   := '';
    VHost_SharesDefaultDomain_b    := false;
    VHost_DefaultIconTheme         := '';
    VHost_DirectoryListing_b       := false;
    VHost_FileDir                  := '';
    VHost_AccessLog                := '';
    VHost_ErrorLog                 := '';
    VHost_JDConnection_ID          := 0;
    VHost_Enabled_b                := false;
    VHost_CacheDir                 := '';
    VHost_TemplateDir              := '';
    VHOST_SipURL                   := '';
    VHOST_FileDir                  := ''; //< Where JAS file store is for uploads and downloads in JegasCRM e.g.='';
    { }
    { Directory of the Jegas WebShare Folder - this is where all the graphics,
      icons, documentation, html, css, and more. Generally I don''t recommend
      using this folder for secure information if using this online as its
      generally a public folder.
    }
    VHOST_WebshareDir              := '';
    { Directory used by the server to avoid unnecessarily calculated and
    rendering pages that a cache makes sense is omproves performance.}
    
    VHOST_CacheDir                 := '';
    //VHOST _LogDir                   := '';//< Directory where the log files are stored.
    //VHOST _ThemeDir                 := '';//< os location
    VHOST_WebRootDir               := ''; //< actual file system path to default webroot

    // Web Paths ----------------------------------------------------------------
    VHOST_WebShareAlias            := ''; //< Aliased Directory "webshare". Usually: jws
    VHOST_JASDirTheme              := ''; //< Directory of the themes
    // Web Paths ----------------------------------------------------------------
    
    VHOST_DefaultArea             := '';//< Name of the DEFAULT AREA template used throughout the system. This is one of this file graphics folks use to toally change how JAs is presented.
    VHOST_DefaultPage             := '';//< Name of the DEFAULT PAGE template used throughout the system. PAGE'S can have pultiple sections making development easy - modifify one page and the system chops it up at run time. This is one of this file graphics folks use to toally change how JAs is presented.
    VHOST_DefaultSection          := '';//< Name of the DEFAULT SECTIONAREA of the PAGE template currently being processed. This file can havle multiple sections and the HTMLRIPPER system handles taking your teplate, populating them with date, breaking apart the secion you want to go out andaway it goes. This is one of this file graphics folks use to toally change how JAs is presented.
    VHOST_PasswordKey_u1           := 0;//< XOR - key for password light encryption. Slated for upgrade
    VHost_DefaultTop_JMenu_ID      := 0;//< The menu system is like a hierarchial, the menu renders from the starting point here by default. This can bounce around depending how the administrator sets up the menu system. Onemenu can contain al the menus in the system. It flexible and the interface is simple amd consistant.
    VHost_DirectoryListing_b       := false;//< When enabled, and a user finds a directory on your webserver it is rendered to allow point-click navigation with pictures thumbs nails. Note this is the system default, each vhost has thier own directory listing flag that will overrise this one if set.
    VHost_DataOnRight_b            := false;//< This is the default way text is rendered in html certain input elements: input, drop-down, "combination (combo) list and input box"
    VHost_CacheMaxAgeInSeconds     := 0;//< How long to send out cache max ages on out pages in the header there is cache info you can pass to help make things run faster for the end user.
    VHost_SystemEmailFromAddress   := '';//< When JAS sends an email, this is the from email (mycomputersentthis@yourDomain.com)
    // is revealed that may be considered a security risk. So you can provide an alternate message in place of what
    // was a place to display error information. E.g. Please contact your admiinistrator with the error number and any other information you might find germane.
    
    VHost_LogToDataBase_b          := false;//< less overhead if off. convenient if on as web browser error viewing. maybe a special text log viwer for the web would be nice - TODO
    VHost_LogToConsole_b           := false;//< If Enabled messages sent to the log file are also sent to the console.
    VHost_LogRequestsToDatabase_b  := false;//< highly detailed request or access log - resource instensive. Useful for development and analysis.
    VHost_DefaultTheme             := '';
    VHost_DefaultIconTheme         := '';
    //END -=-=-=-=-=-=- NEW TO VHOST table-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    VHost_LogToConsole_b           := false;
    VHost_Headers_b                :=true;
    VHost_QuickLinks_b             :=true;
    VHost_DefaultDateMask          :='';
    VHost_Background               :='';
    VHost_BackgroundRepeat_b       :=false;

    VHost_CreatedBy_JUser_ID       := 0;
    VHost_Created_DT               := '';
    VHost_ModifiedBy_JUser_ID      := 0;
    VHost_Modified_DT              := '';
    VHost_DeletedBy_JUser_ID       := 0;
    VHost_Deleted_DT               := '';
    VHost_Deleted_b                := false;
    JAS_Row_b                      := false;
  end;
end;
//=============================================================================
















// ============================================================================
procedure clear_JIPLIST(var p_rJIPList: rtJIPLIST);
// ============================================================================
begin
  with p_rJIPList do begin
    JIPL_JIPList_UID            :=0;
    JIPL_IPListType_u           :=0;
    JIPL_IPAddress              :='';
    JIPL_InvalidLogins_u        :=0;
    JIPL_Reason                 :='';
    JIPL_CreatedBy_JUser_ID     :=0;
    JIPL_Created_DT             :='';
    JIPL_ModifiedBy_JUser_ID    :=0;
    JIPL_Modified_DT            :='';
    JIPL_DeletedBy_JUser_ID     :=0;
    JIPL_Deleted_DT             :='';
    JIPL_Deleted_b              :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
// ============================================================================


//=============================================================================
{}
procedure clear_JIPListLight(var p_rJIPListLight: rtJIPListLight);
//=============================================================================
begin
  with p_rJIPListLight do begin
    u8JIPList_UID            :=0;
    u1IPListType             :=0;
    sIPAddress               :='';
    u1InvalidLogins          :=0;
    u2Downloads              :=0;
    dtDownLoad               :=TDAteTime(0);//might choke here
    bRequestedRobotsTxt      :=false;
    u1JMails                 :=0;
  end;
end;
//=============================================================================


//=============================================================================
{}
procedure clear_JIPListLU(var p_rJIPListLU: rtJIPListLU);
begin
  with p_rJIPListLU do begin
    IPLU_JIPListLU_UID           :=0;
    IPLU_Name                    :='';
    IPLU_CreatedBy_JUser_ID      :=0;
    IPLU_Created_DT              :='';
    IPLU_DeletedBy_JUser_ID      :=0;
    IPLU_Deleted_b               :=false;
    IPLU_Deleted_DT              :='';
    IPLU_ModifiedBy_JUser_ID     :=0;
    IPLU_Modified_DT             :='';
    JAS_Row_b                    :=false;
  end;//with
end;
//=============================================================================





//=============================================================================
{}
procedure clear_JIPStat(var p_rJIPStat: rtJIPSTat);
begin
  with p_rJIPStat do begin
    IPST_Jipstat_UID        :=0 ; // Integer Unsigned 08 Bytes
    IPST_CreatedBy_JUser_ID :=0 ; // Integer Unsigned 08 Bytes
    IPST_Created_DT         :='' ; // DateTime
    IPST_ModifiedBy_JUser_ID:=0 ; // Integer Unsigned 08 Bytes
    IPST_Modified_DT        :='' ; // DateTime
    IPST_DeletedBy_JUser_ID :=0 ; // Integer Unsigned 08 Bytes
    IPST_Deleted_DT         :='' ; // DateTime
    IPST_Deleted_b          :=false ; // Boolean
    JAS_Row_b               :=false ; // Boolean
    IPST_IPAddress          :='' ; // Text - ASCII,15
    IPST_Downloads          :=0 ; // Integer 02 Bytes
    IPST_Errors             :=0 ; // Integer 02 bytes
  end;//with
end;
//=============================================================================










// ============================================================================
procedure clear_JAlias(var p_rJAlias: rtJAlias);
// ============================================================================
begin
  with p_rJAlias do begin
    Alias_JAlias_UID            :=0;
    Alias_JVHost_ID             :=0;
    Alias_Alias                 :='';
    Alias_Path                  :='';
    Alias_VHost_b               :=false;
    Alias_CreatedBy_JUser_ID    :=0;
    Alias_Created_DT            :='';
    Alias_ModifiedBy_JUser_ID   :=0;
    Alias_Modified_DT           :='';
    Alias_DeletedBy_JUser_ID    :=0;
    Alias_Deleted_DT            :='';
    Alias_Deleted_b             :=false;
    JAS_Row_b                   :=false;
  end;//with
end;
// ============================================================================



//=============================================================================
{}
procedure clear_JAliasLight(var p_rJAliasLight: rtJAliasLight);
//=============================================================================
begin
  with p_rJAliasLight do begin
    u8JAlias_UID            :=0;
    u8JVHost_ID             :=0;
    saAlias                 :='';
    saPath                  :='';
    bVHost                  :=false;
  end;
end;
//=============================================================================




// ============================================================================
procedure clear_JMime(var p_rJMime: rtJMime);
// ============================================================================
begin
  with p_rJMime do begin
    MIME_JMime_UID             :=0;
    MIME_Name                  :='';
    MIME_Type                  :='';
    MIME_Enabled_b             :=false;
    MIME_SNR_b                 :=false;
    MIME_CreatedBy_JUser_ID    :=0;
    MIME_Created_DT            :='';
    MIME_ModifiedBy_JUser_ID   :=0;
    MIME_Modified_DT           :='';
    MIME_DeletedBy_JUser_ID    :=0;
    MIME_Deleted_DT            :='';
    MIME_Deleted_b             :=false;
    JAS_Row_b                  :=false;
  end;//end with
end;
// ============================================================================



// ============================================================================
{}
procedure clear_JMimeLight(var p_rJMimeLight: rtJMimeLight);
// ============================================================================
begin
  with p_rJMimeLight do begin
    u8JMime_UID             :=0;
    sName                   :='';
    sType                   :='';
    bSNR                    :=false;
  end;
end;
// ============================================================================



// ============================================================================
procedure clear_JIndexfile(var p_rJIndexFile: rtJIndexFile);
// ============================================================================
begin
  with p_rJIndexFile do begin
    JIDX_JIndexFile_UID        :=0;
    JIDX_JVHost_ID             :=0;
    JIDX_Filename              :='';
    JIDX_Order_u               :=0;
    JIDX_CreatedBy_JUser_ID    :=0;
    JIDX_Created_DT            :='';
    JIDX_ModifiedBy_JUser_ID   :=0;
    JIDX_Modified_DT           :='';
    JIDX_DeletedBy_JUser_ID    :=0;
    JIDX_Deleted_DT            :='';
    JIDX_Deleted_b             :=false;
    JAS_Row_b                  :=false;
  end;//with
end;
// ============================================================================


// ============================================================================
{}
procedure clear_JIndexFileLight(var p_rJIndexFileLight: rtJIndexFileLight);
// ============================================================================
begin
  with p_rJIndexFileLight do begin
    u8JIndexFile_UID        :=0;
    u8JVHost_ID             :=0;
    saFilename              :='';
  end;
end;
// ============================================================================






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

