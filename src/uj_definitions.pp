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
//=============================================================================

//=============================================================================
{}
// These Constants are human language identifiers
const cnLang_English = 1;
const cnLang_Spanish = 2;
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
// Permissions
Const cnJSecPerm_MasterAdmin         = 01211050031076870000;
Const cnJSecPerm_Admin               = 01211050031076870001;
Const cnJSecPerm_JASSQLTool          = 01211050031076870005;
Const cnJSecPerm_MenuEditor          = 01211050031076870007;
Const cnJSecPerm_CycleServer         = 01211050031076870002;
Const cnJSecPerm_ShutDownServer      = 01211050031076870003;
Const cnJSecPerm_IconHelper          = 01211050031076870008;
Const cnJSecPerm_JASDBCon            = 01211050031076870004;
Const cnJSecPerm_CopySecurityGroups  = 01211051746190940000;
Const cnJSecPerm_DatabaseMaintenance = 01211050031076870006;
const cnJSecPerm_TableViewjuserpref  = 01212041011120280827;
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
const cs_jcompany            = 23                 ;
const cs_jcompanypers        = 25                 ;
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
const cs_jtaskpriority       = 113                ;
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
const cs_jcompany_Data                         = 218                ;  // Company     Data
const cs_jcompany_Search                       = 217                ;  // Companies     Filter + Grid
const cs_jcompanypers_Data                     = 164                ;  // Company Person    Data
const cs_jcompanypers_Search                   = 163                ;  // Company People    Filter + Grid
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
  saUID                                   : ansistring;
  saFieldName_CreatedBy_JUser_ID          : ansistring;
  saFieldName_Created_DT                  : ansistring;
  saFieldName_ModifiedBy_JUser_ID         : ansistring;
  saFieldName_Modified_DT                 : ansistring;
  saFieldName_DeletedBy_JUser_ID          : ansistring;
  saFieldName_Deleted_DT                  : ansistring;
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
  JADB_JADODBMS_UID :ansistring;
  JADB_Name           :ansistring;
  JADB_CreatedBy_JUser_ID          : ansistring;
  JADB_Created_DT                  : ansistring;
  JADB_ModifiedBy_JUser_ID         : ansistring;
  JADB_Modified_DT                 : ansistring;
  JADB_DeletedBy_JUser_ID          : ansistring;
  JADB_Deleted_DT                  : ansistring;
  JADB_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JADODBMS(var p_rJADODBMS: rtJADODBMS);
//=============================================================================


//=============================================================================
{}
Type rtJADODriver=record
  JADV_JADODriver_UID :ansistring;
  JADV_Name           :ansistring;
  JADV_CreatedBy_JUser_ID          : ansistring;
  JADV_Created_DT                  : ansistring;
  JADV_ModifiedBy_JUser_ID         : ansistring;
  JADV_Modified_DT                 : ansistring;
  JADV_DeletedBy_JUser_ID          : ansistring;
  JADV_Deleted_DT                  : ansistring;
  JADV_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JADODriver(var p_rJADODriver: rtJADODriver);
//=============================================================================




//=============================================================================
{}
type rtJAlias = Record
  Alias_JAlias_UID            : ansistring;
  Alias_JVHost_ID             : ansistring;
  Alias_Alias                 : ansistring;
  Alias_Path                  : ansistring;
  Alias_VHost_b               : ansistring;
  Alias_CreatedBy_JUser_ID    : ansistring;
  Alias_Created_DT            : ansistring;
  Alias_ModifiedBy_JUser_ID   : ansistring;
  Alias_Modified_DT           : ansistring;
  Alias_DeletedBy_JUser_ID    : ansistring;
  Alias_Deleted_DT            : ansistring;
  Alias_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
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
  JBlok_JBlok_UID                   : AnsiString;
  JBlok_JScreen_ID                  : Ansistring;
  JBlok_JTable_ID                   : AnsiString;
  JBlok_Name                        : AnsiString;
  JBlok_Columns_u                   : AnsiString;
  JBlok_JBlokType_ID                : AnsiString;
  JBlok_Custom                      : AnsiString;
  JBlok_JCaption_ID                 : AnsiString;
  JBlok_IconSmall                   : AnsiString;
  JBlok_IconLarge                   : AnsiString;
  JBlok_Position_u                  : Ansistring;
  JBlok_Help_ID                     : ansistring;
  JBlok_CreatedBy_JUser_ID          : ansistring;
  JBlok_Created_DT                  : ansistring;
  JBlok_ModifiedBy_JUser_ID         : ansistring;
  JBlok_Modified_DT                 : ansistring;
  JBlok_DeletedBy_JUser_ID          : ansistring;
  JBlok_Deleted_DT                  : ansistring;
  JBlok_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
End;
procedure clear_JBlok(var p_rJBlok: rtJBlok);
//=============================================================================


//=============================================================================
{}
Type rtJBlokButton=Record
  JBlkB_JBlokButton_UID             : AnsiString;
  JBlkB_JBlok_ID                    : AnsiString;
  JBlkB_JCaption_ID                 : AnsiString;
  JBlkB_Name                        : AnsiString;
  JBlkB_GraphicFileName             : AnsiString;
  JBlkB_Position_u                  : AnsiString;
  JBlkB_JButtonType_ID              : AnsiString;
  JBlkB_CustomURL                   : ansistring;
  JBlkB_CreatedBy_JUser_ID          : ansistring;
  JBlkB_Created_DT                  : ansistring;
  JBlkB_ModifiedBy_JUser_ID         : ansistring;
  JBlkB_Modified_DT                 : ansistring;
  JBlkB_DeletedBy_JUser_ID          : ansistring;
  JBlkB_Deleted_DT                  : ansistring;
  JBlkB_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
End;
procedure clear_JBlokButton(var p_rJBlokButton: rtJBlokButton);
//=============================================================================

//=============================================================================
{}
type rtJButtonType=record
  JBtnT_JButtonType_UID       : ansistring;
  JBtnT_Name                  : ansistring;
  JBtnT_CreatedBy_JUser_ID    : ansistring;
  JBtnT_Created_DT            : ansistring;
  JBtnT_ModifiedBy_JUser_ID   : ansistring;
  JBtnT_Modified_DT           : ansistring;
  JBtnT_DeletedBy_JUser_ID    : ansistring;
  JBtnT_Deleted_DT            : ansistring;
  JBtnT_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
End;
procedure clear_JButtonType(var p_rJButtonType: rtJButtonType);



//=============================================================================
{}
Type rtJBlokField=Record
  JBlkF_JBlokField_UID              : AnsiString;
  JBlkF_JBlok_ID                    : ansistring;
  JBlkF_JColumn_ID                  : ansistring;
  JBlkF_Position_u                  : AnsiString;
  JBlkF_ReadOnly_b                  : AnsiString;
  JBlkF_JWidget_ID                  : AnsiString;
  JBlkF_Widget_MaxLength_u          : AnsiString;
  JBlkF_Widget_Width                : AnsiString;
  JBlkF_Widget_Height               : AnsiString;
  JBlkF_Widget_Password_b           : AnsiString;
  JBlkF_Widget_Date_b               : AnsiString;
  JBlkF_Widget_Time_b               : AnsiString;
  JBlkF_Widget_Mask                 : AnsiString;
  JBlkF_Widget_OnBlur               : ansistring;
  JBlkF_Widget_OnChange             : ansistring;
  JBlkF_Widget_OnClick              : ansistring;
  JBlkF_Widget_OnDblClick           : ansistring;
  JBlkF_Widget_OnFocus              : ansistring;
  JBlkF_Widget_OnKeyDown            : ansistring;
  JBlkF_Widget_OnKeypress           : ansistring;
  JBlkF_Widget_OnKeyUp              : ansistring;
  JBlkF_Widget_OnSelect             : ansistring;
  JBlkF_ColSpan_u                   : AnsiString;
  JBlkF_Width_is_Percent_b          : ansistring;
  JBlkF_Height_is_Percent_b         : ansistring;
  JBlkF_Required_b                  : ansistring;
  JBlkF_MultiSelect_b               : ansistring;
  JBlkF_ClickAction_ID              : AnsiString;
  JBlkF_ClickActionData             : AnsiString;
  JBlkF_JCaption_ID                 : ansistring;
  JBlkF_Visible_b                   : ansistring;
  JBlkF_CreatedBy_JUser_ID          : ansistring;
  JBlkF_Created_DT                  : ansistring;
  JBlkF_ModifiedBy_JUser_ID         : ansistring;
  JBlkF_Modified_DT                 : ansistring;
  JBlkF_DeletedBy_JUser_ID          : ansistring;
  JBlkF_Deleted_DT                  : ansistring;
  JBlkF_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;

end;
procedure clear_JBlokField(var p_rJBlokField: rtJBlokField);
//=============================================================================

//=============================================================================
{}
type rtJBlokType=record
  JBkTy_JBlokType_UID               : ansistring;
  JBkTy_Name                        : ansistring;
  JBkTy_CreatedBy_JUser_ID          : ansistring;
  JBkTy_Created_DT                  : ansistring;
  JBkTy_ModifiedBy_JUser_ID         : ansistring;
  JBkTy_Modified_DT                 : ansistring;
  JBkTy_DeletedBy_JUser_ID          : ansistring;
  JBkTy_Deleted_DT                  : ansistring;
  JBkTy_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JBlokType(var p_rJBlokType: rtJBlokType);
//=============================================================================




//=============================================================================
{}
type rtJCaption=record
  JCapt_JCaption_UID          : ansistring;
  JCapt_Orphan_b              : ansistring;
  JCapt_Value                 : ansistring;
  JCapt_en                    : ansistring;
  JCapt_CreatedBy_JUser_ID    : ansistring;
  JCapt_Created_DT            : ansistring;
  JCapt_ModifiedBy_JUser_ID   : ansistring;
  JCapt_Modified_DT           : ansistring;
  JCapt_DeletedBy_JUser_ID    : ansistring;
  JCapt_Deleted_DT            : ansistring;
  JCapt_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JCaption(var p_rJCaption: rtJCaption);
//=============================================================================



//=============================================================================
{}
type rtJCase=record
  JCase_JCase_UID                 : ansistring;
  JCase_Name                      : ansistring;
  JCase_JCompany_ID               : ansistring;
  JCase_JPerson_ID                : ansistring;
  JCase_Responsible_Grp_ID        : ansistring;
  JCase_Responsible_Person_ID     : ansistring;
  JCase_JCaseSource_ID            : ansistring;
  JCase_JCaseCategory_ID          : ansistring;
  JCase_JCasePriority_ID          : ansistring;
  JCase_JCaseStatus_ID            : ansistring;
  JCase_JCaseType_ID              : ansistring;
  JCase_JSubject_ID               : ansistring;
  JCase_Desc                      : ansistring;
  JCase_Resolution                : ansistring;
  JCase_Due_DT                    : ansistring;
  JCase_ResolvedBy_JUser_ID       : ansistring;
  JCase_Resolved_DT               : ansistring;
  JCase_CreatedBy_JUser_ID        : ansistring;
  JCase_Created_DT                : ansistring;
  JCase_ModifiedBy_JUser_ID       : ansistring;
  JCase_Modified_DT               : ansistring;
  JCase_DeletedBy_JUser_ID        : ansistring;
  JCase_Deleted_DT                : ansistring;
  JCase_Deleted_b                 : ansistring;
  JAS_Row_b                       : ansistring;
end;
procedure clear_JCase(var p_rJCase: rtJCase);
//=============================================================================


//=============================================================================
{}
type rtJCaseCategory=record
  JCACT_JCaseCategory_UID           : ansistring;
  JCACT_Name                        : ansistring;
  JCACT_CreatedBy_JUser_ID          : ansistring;
  JCACT_Created_DT                  : ansistring;
  JCACT_ModifiedBy_JUser_ID         : ansistring;
  JCACT_Modified_DT                 : ansistring;
  JCACT_DeletedBy_JUser_ID          : ansistring;
  JCACT_Deleted_DT                  : ansistring;
  JCACT_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JCaseCategory(var p_rJCaseCategory: rtJCaseCategory);
//=============================================================================


//=============================================================================
{}
type rtJCasePriority=record
  JCAPR_JCasePriority_UID           : ansistring;
  JCAPR_Name                        : ansistring;
  JCAPR_CreatedBy_JUser_ID          : ansistring;
  JCAPR_Created_DT                  : ansistring;
  JCAPR_ModifiedBy_JUser_ID         : ansistring;
  JCAPR_Modified_DT                 : ansistring;
  JCAPR_DeletedBy_JUser_ID          : ansistring;
  JCAPR_Deleted_DT                  : ansistring;
  JCAPR_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JCasePriority(var p_rJCasePriority: rtJCasePriority);
//=============================================================================

//=============================================================================
{}
type rtJCaseSource=record
  JCASR_JCaseSource_UID     : ansistring;
  JCASR_Name                : ansistring;
  JCASR_CreatedBy_JUser_ID  : ansistring;
  JCASR_Created_DT          : ansistring;
  JCASR_ModifiedBy_JUser_ID : ansistring;
  JCASR_Modified_DT         : ansistring;
  JCASR_DeletedBy_JUser_ID  : ansistring;
  JCASR_Deleted_DT          : ansistring;
  JCASR_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JCaseSource(var p_rJCaseSource: rtJCaseSource);
//=============================================================================



//=============================================================================
{}
type rtJCaseSubject=record
  JCASB_JCaseSubject_UID    : ansistring;
  JCASB_Name                : ansistring;
  JCASB_CreatedBy_JUser_ID  : ansistring;
  JCASB_Created_DT          : ansistring;
  JCASB_ModifiedBy_JUser_ID : ansistring;
  JCASB_Modified_DT         : ansistring;
  JCASB_DeletedBy_JUser_ID  : ansistring;
  JCASB_Deleted_DT          : ansistring;
  JCASB_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JCaseSubject(var p_rJCaseSubject: rtJCaseSubject);
//=============================================================================

//=============================================================================
{}
type rtJCaseType=record
  JCATY_JCaseType_UID       : ansistring;
  JCATY_Name                : ansistring;
  JCATY_CreatedBy_JUser_ID  : ansistring;
  JCATY_Created_DT          : ansistring;
  JCATY_ModifiedBy_JUser_ID : ansistring;
  JCATY_Modified_DT         : ansistring;
  JCATY_DeletedBy_JUser_ID  : ansistring;
  JCATY_Deleted_DT          : ansistring;
  JCATY_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JCaseType(var p_rJCaseType: rtJCaseType);
//=============================================================================



//=============================================================================
{}
Type rtJColumn=Record
  JColu_JColumn_UID             : ansistring;
  JColu_Name                    : ansistring;
  JColu_JTable_ID               : ansistring;
  JColu_JDType_ID               : ansistring;
  JColu_AllowNulls_b            : ansistring;
  JColu_DefaultValue            : ansistring;
  JColu_PrimaryKey_b            : ansistring;
  JColu_JAS_b                   : ansistring;
  JColu_JCaption_ID             : ansistring;
  JColu_DefinedSize_u           : ansistring;
  JColu_NumericScale_u          : ansistring;
  JColu_Precision_u             : ansistring;
  JColu_Boolean_b               : ansistring;
  JColu_JAS_Key_b               : ansistring;
  JColu_AutoIncrement_b         : ansistring;
  JColu_LUF_Value               : ansistring;
  JColu_LD_CaptionRules_b       : ansistring;
  JColu_JDConnection_ID         : ansistring;
  JColu_Desc                    : ansistring;
  JColu_Weight_u                : ansistring; // int 04
  JColu_LD_SQL                  : ansistring;
  JColu_LU_JColumn_ID           : ansistring;
  JColu_CreatedBy_JUser_ID      : ansistring;
  JColu_Created_DT              : ansistring;
  JColu_ModifiedBy_JUser_ID     : ansistring;
  JColu_Modified_DT             : ansistring;
  JColu_DeletedBy_JUser_ID      : ansistring;
  JColu_Deleted_DT              : ansistring;
  JColu_Deleted_b               : ansistring;
  JAS_Row_b                     : ansistring;
End;
procedure clear_JColumn(var p_rJColumn: rtJColumn);
//=============================================================================


//=============================================================================
{}
type rtJCompany=record
  JComp_JCompany_UID              : ansistring;
  JComp_Name                      : ansistring;
  JComp_Desc                      : ansistring;
  JComp_Primary_Person_ID         : ansistring;
  JComp_Phone                     : ansistring;
  JComp_Fax                       : ansistring;
  JComp_Email                     : ansistring;
  JComp_Website                   : ansistring;
  JComp_Parent_ID                 : ansistring;
  JComp_Owner_JUser_ID            : ansistring;
  JComp_Main_Addr1                : ansistring;
  JComp_Main_Addr2                : ansistring;
  JComp_Main_Addr3                : ansistring;
  JComp_Main_City                 : ansistring;
  JComp_Main_State                : ansistring;
  JComp_Main_PostalCode           : ansistring;
  JComp_Main_Country              : ansistring;
  JComp_Ship_Addr1                : ansistring;
  JComp_Ship_Addr2                : ansistring;
  JComp_Ship_Addr3                : ansistring;
  JComp_Ship_City                 : ansistring;
  JComp_Ship_State                : ansistring;
  JComp_Ship_PostalCode           : ansistring;
  JComp_Ship_Country              : ansistring;
  JComp_Main_Longitude_d          : ansistring;
  JComp_Main_Latitude_d           : ansistring;
  JComp_Ship_Longitude_d          : ansistring;
  JComp_Ship_Latitude_d           : ansistring;
  JComp_Country                   : ansistring;
  JComp_Customer_b                : ansistring;
  JComp_Vendor_b                  : ansistring;
  JComp_CreatedBy_JUser_ID        : ansistring;
  JComp_Created_DT                : ansistring;
  JComp_ModifiedBy_JUser_ID       : ansistring;
  JComp_Modified_DT               : ansistring;
  JComp_DeletedBy_JUser_ID        : ansistring;
  JComp_Deleted_DT                : ansistring;
  JComp_Deleted_b                 : ansistring;
  JAS_Row_b                       : ansistring;
end;
procedure clear_JCompany(var p_rJCompany: rtJCompany);
//=============================================================================


//=============================================================================
{}
type rtJCompanyPers=record
  JCpyP_JCompanyPers_UID    : ansistring;
  JCpyP_JCompany_ID         : ansistring;
  JCpyP_JPerson_ID          : ansistring;
  JCpyP_DepartmentLU_ID     : ansistring;
  JCpyP_Title               : ansistring;
  JCpyP_ReportsTo_Person_ID : ansistring;
  JCpyP_CreatedBy_JUser_ID  : ansistring;
  JCpyP_Created_DT          : ansistring;
  JCpyP_ModifiedBy_JUser_ID : ansistring;
  JCpyP_Modified_DT         : ansistring;
  JCpyP_DeletedBy_JUser_ID  : ansistring;
  JCpyP_Deleted_DT          : ansistring;
  JCpyP_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JCompanyPers(var p_rJCompanyPers: rtJCompanyPers);
//=============================================================================


//=============================================================================
{}
type rtJDConnection=record
  JDCon_JDConnection_UID                  : ansistring;
  JDCon_Name                              : ansistring;
  JDCon_Desc                              : ansistring;
  JDCon_DBC_Filename                      : ansistring;
  JDCon_DSN                               : ansistring;
  JDCon_DSN_FileBased_b                   : ansistring;
  JDCon_DSN_Filename                      : ansistring;
  JDCon_Enabled_b                         : ansistring;
  JDCon_DBMS_ID                           : ansistring;
  JDCon_Driver_ID                         : ansistring;
  JDCon_Username                          : ansistring;
  JDCon_Password                          : ansistring;
  JDCon_ODBC_Driver                       : ansistring;
  JDCon_Server                            : ansistring;
  JDCon_Database                          : ansistring;
  JDCon_JSecPerm_ID                       : ansistring;
  JDCon_JAS_b                             : ansistring;
  JDCon_CreatedBy_JUser_ID                : ansistring;
  JDCon_Created_DT                        : ansistring;
  JDCon_ModifiedBy_JUser_ID               : ansistring;
  JDCon_Modified_DT                       : ansistring;
  JDCon_DeletedBy_JUser_ID                : ansistring;
  JDCon_Deleted_DT                        : ansistring;
  JDCon_Deleted_b                         : ansistring;
  JAS_Row_b                               : ansistring;
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
  JDBug_JDebug_UID               : ansistring; //< NOTE: DBMS autonumber - Not a Jegas UID autonumber field!
  JDBug_Code_u                   : ansistring;
  JDBug_Message                  : ansistring;
end;
procedure clear_JDebug(var p_rJDebug: rtJDebug);
//=============================================================================


//=============================================================================
{}
type rtJDType=record
  JDTyp_JDType_UID               : ansistring;
  JDTyp_Desc                     : ansistring;
  JDTyp_Notation                 : ansistring;
  JDTyp_CreatedBy_JUser_ID       : ansistring;
  JDTyp_Created_DT               : ansistring;
  JDTyp_ModifiedBy_JUser_ID      : ansistring;
  JDTyp_Modified_DT              : ansistring;
  JDTyp_DeletedBy_JUser_ID       : ansistring;
  JDTyp_Deleted_DT               : ansistring;
  JDTyp_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JDType(var p_rJDType: rtJDType);
//=============================================================================



//=============================================================================
{}
type rtJFile=record
  JFile_JFile_UID                : ansistring;
  JFile_en                       : ansistring;
  JFile_Name                     : ansistring;
  JFile_Path                     : ansistring;
  JFile_JTable_ID                : ansistring;
  JFile_JColumn_ID               : ansistring;
  JFile_Row_ID                   : ansistring;
  JFile_Orphan_b                 : ansistring;
  JFile_JSecPerm_ID              : ansistring;
  JFile_FileSize_u               : ansistring;
  JFile_CreatedBy_JUser_ID       : ansistring;
  JFile_Created_DT               : ansistring;
  JFile_ModifiedBy_JUser_ID      : ansistring;
  JFile_Modified_DT              : ansistring;
  JFile_DeletedBy_JUser_ID       : ansistring;
  JFile_Deleted_DT               : ansistring;
  JFile_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JFile(var p_rJFile: rtJFile);
//=============================================================================



//=============================================================================
{}
type rtJFilterSave=record
  JFtSa_JFilterSave_UID          : ansistring;
  JFtSa_Name                     : ansistring;
  JFtSa_JBlok_ID                 : ansistring;
  JFtSa_Public_b                 : ansistring;
  JFTSa_XML                      : ansistring;
  JFtSa_CreatedBy_JUser_ID       : ansistring;
  JFtSa_Created_DT               : ansistring;
  JFtSa_ModifiedBy_JUser_ID      : ansistring;
  JFtSa_Modified_DT              : ansistring;
  JFtSa_DeletedBy_JUser_ID       : ansistring;
  JFtSa_Deleted_DT               : ansistring;
  JFtSa_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JFilterSave(var p_rJFilterSave: rtJFilterSave);
//=============================================================================

//=============================================================================
{}
type rtJFilterSaveDef=record
  JFtSD_JFilterSaveDef_UID       : ansistring;
  JFtSD_JBlok_ID                 : ansistring;
  JFtSD_JFilterSave_ID           : ansistring;
  JFtSD_CreatedBy_JUser_ID       : ansistring;
  JFtSD_Created_DT               : ansistring;
  JFtSD_ModifiedBy_JUser_ID      : ansistring;
  JFtSD_Modified_DT              : ansistring;
  JFtSD_DeletedBy_JUser_ID       : ansistring;
  JFtSD_Deleted_DT               : ansistring;
  JFtSD_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JFilterSaveDef(var p_rJFilterSaveDef: rtJFilterSaveDef);
//=============================================================================


// ============================================================================
{}
type rtJHelp=record
  Help_JHelp_UID            : ansistring;  
  Help_VideoMP4_en          : ansistring;  
  Help_HTML_en              : ansistring;  
  Help_HTML_Adv_en          : ansistring;  
  Help_Name                 : ansistring;  
  Help_Poster               : ansistring;  
  Help_CreatedBy_JUser_ID   : ansistring;  
  Help_Created_DT           : ansistring;  
  Help_ModifiedBy_JUser_ID  : ansistring;  
  Help_Modified_DT          : ansistring;  
  Help_DeletedBy_JUser_ID   : ansistring;  
  Help_Deleted_DT           : ansistring;  
  Help_Deleted_b            : ansistring;   
  JAS_Row_b                 : ansistring;
end;
procedure clear_JHelp(p_rJHelp: rtJHelp);
// ============================================================================







// ============================================================================
{}
type rtJIndexFile = record
  JIDX_JIndexFile_UID        : ansistring;
  JIDX_JVHost_ID             : ansistring;
  JIDX_Filename              : ansistring;
  JIDX_Order_u               : ansistring;
  JIDX_CreatedBy_JUser_ID    : ansistring;
  JIDX_Created_DT            : ansistring;
  JIDX_ModifiedBy_JUser_ID   : ansistring;
  JIDX_Modified_DT           : ansistring;
  JIDX_DeletedBy_JUser_ID    : ansistring;
  JIDX_Deleted_DT            : ansistring;
  JIDX_Deleted_b             : ansistring;
  JAS_Row_b                  : ansistring;
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
  JIndu_JIndustry_UID            : ansistring;
  JIndu_Name                     : ansistring;
  JIndu_CreatedBy_JUser_ID       : ansistring;
  JIndu_Created_DT               : ansistring;
  JIndu_ModifiedBy_JUser_ID      : ansistring;
  JIndu_Modified_DT              : ansistring;
  JIndu_DeletedBy_JUser_ID       : ansistring;
  JIndu_Deleted_DT               : ansistring;
  JIndu_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JIndustry(var p_rJIndustry: rtJIndustry);
//=============================================================================

//=============================================================================
{}
type rtJInstalled=record
  JInst_JInstalled_UID           : ansistring;
  JInst_JModule_ID               : ansistring;
  JInst_Name                     : ansistring;
  JInst_Desc                     : ansistring;
  JInst_JNote_ID                : ansistring;
  JInst_Enabled_b                : ansistring;
  JInst_CreatedBy_JUser_ID       : ansistring;
  JInst_Created_DT               : ansistring;
  JInst_ModifiedBy_JUser_ID      : ansistring;
  JInst_Modified_DT              : ansistring;
  JInst_DeletedBy_JUser_ID       : ansistring;
  JInst_Deleted_DT               : ansistring;
  JInst_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JInstalled(var p_rJInstalled: rtJInstalled);
//=============================================================================

//=============================================================================
{}
type rtJInterface=record
  JIntF_JInterface_UID           : ansistring;
  JIntF_Name                     : ansistring;
  JIntF_Desc                     : ansistring;
  JIntF_CreatedBy_JUser_ID       : ansistring;
  JIntF_Created_DT               : ansistring;
  JIntF_ModifiedBy_JUser_ID      : ansistring;
  JIntF_Modified_DT              : ansistring;
  JIntF_DeletedBy_JUser_ID       : ansistring;
  JIntF_Deleted_DT               : ansistring;
  JIntF_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JInterface(var p_rJInterface: rtJInterface);
//=============================================================================


//=============================================================================
{}
Type rtJInvoice=record
  JIHdr_JInvoice_UID         : ansistring;
  JIHdr_DateInv_DT           : ansistring;
  JIHdr_DateShip_DT          : ansistring;
  JIHdr_DateOrd_DT           : ansistring;
  JIHdr_POCust               : ansistring;
  JIHdr_POInternal           : ansistring;
  JIHdr_ShipVia              : ansistring;
  JIHdr_Note01               : ansistring;
  JIHdr_Note02               : ansistring;
  JIHdr_Note03               : ansistring;
  JIHdr_Note04               : ansistring;
  JIHdr_Note05               : ansistring;
  JIHdr_Note06               : ansistring;
  JIHdr_Terms01              : ansistring;
  JIHdr_Terms02              : ansistring;
  JIHdr_Terms03              : ansistring;
  JIHdr_Terms04              : ansistring;
  JIHdr_Terms05              : ansistring;
  JIHdr_Terms06              : ansistring;
  JIHdr_Terms07              : ansistring;
  JIHdr_SalesAmt_d           : ansistring;
  JIHdr_MiscAmt_d            : ansistring;
  JIHdr_SalesTaxAmt_d        : ansistring;
  JIHdr_ShipAmt_d            : ansistring;
  JIHdr_TotalAmt_d           : ansistring;
  JIHdr_BillToAddr01         : ansistring;
  JIHdr_BillToAddr02         : ansistring;
  JIHdr_BillToAddr03         : ansistring;
  JIHdr_BillToCity           : ansistring;
  JIHdr_BillToState          : ansistring;
  JIHdr_BillToPostalCode     : ansistring;
  JIHdr_ShipToAddr01         : ansistring;
  JIHdr_ShipToAddr02         : ansistring;
  JIHdr_ShipToAddr03         : ansistring;
  JIHdr_ShipToCity           : ansistring;
  JIHdr_ShipToState          : ansistring;
  JIHdr_ShipToPostalCode     : ansistring;
  JIHDr_JCompany_ID          : ansistring;
  JIHDr_JPerson_ID           : ansistring;
  JIHdr_CreatedBy_JUser_ID   : ansistring;
  JIHdr_Created_DT           : ansistring;
  JIHdr_ModifiedBy_JUser_ID  : ansistring;
  JIHdr_Modified_DT          : ansistring;
  JIHdr_DeletedBy_JUser_ID   : ansistring;
  JIHdr_Deleted_DT           : ansistring;
  JIHdr_Deleted_b            : ansistring;
  JAS_Row_b                  : ansistring;
end;
procedure clear_JInvoice(var p_rJInvoice: rtJInvoice);
//=============================================================================

//=============================================================================
{}
Type rtJInvoiceLines=record
  JILin_JInvoiceLines_UID    : ansistring;
  JILin_JInvoice_ID          : ansistring;
  JILin_ProdNoInternal       : ansistring;
  JILin_ProdNoCust           : ansistring;
  JILin_JProduct_ID          : ansistring;
  JILin_QtyOrd_d             : ansistring;
  JILin_DescA                : ansistring;
  JILin_DescB                : ansistring;
  JILin_QtyShip_d            : ansistring;
  JILin_PrcUnit_d            : ansistring;
  JILin_PrcExt_d             : ansistring;
  JILin_SEQ_u                : ansistring;
  JILin_CreatedBy_JUser_ID   : ansistring;
  JILin_Created_DT           : ansistring;
  JILin_ModifiedBy_JUser_ID  : ansistring;
  JILin_Modified_DT          : ansistring;
  JILin_DeletedBy_JUser_ID   : ansistring;
  JILin_Deleted_DT           : ansistring;
  JILin_Deleted_b            : ansistring;
  JAS_Row_b                  : ansistring;
end;
procedure clear_JInvoiceLines(var p_rJInvoiceLines: rtJInvoiceLines);
//=============================================================================



//=============================================================================
{}
type rtJIPList = Record
  JIPL_JIPList_UID            : ansistring;
  JIPL_IPListType_u           : ansistring;
  JIPL_IPAddress              : ansistring;
  JIPL_InvalidLogins_u        : ansistring;
  JIPL_CreatedBy_JUser_ID     : ansistring;
  JIPL_Created_DT             : ansistring;
  JIPL_ModifiedBy_JUser_ID    : ansistring;
  JIPL_Modified_DT            : ansistring;
  JIPL_DeletedBy_JUser_ID     : ansistring;
  JIPL_Deleted_DT             : ansistring;
  JIPL_Deleted_b              : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JIPList(var p_rJIPList: rtJIPList);
//=============================================================================

//=============================================================================
{}
type rtJIPListLight = Record
  u8JIPList_UID            : UInt64;
  u1IPListType             : byte;
  saIPAddress              : ansistring;
end;
procedure clear_JIPListLight(var p_rJIPListLight: rtJIPListLight);
//=============================================================================


//=============================================================================
{}
type rtJIPListLU = record
  IPLU_JIPListLU_UID           : ansistring;
  IPLU_Name                    : ansistring;
  IPLU_CreatedBy_JUser_ID      : ansistring;
  IPLU_Created_DT              : ansistring;
  IPLU_DeletedBy_JUser_ID      : ansistring;
  IPLU_Deleted_b               : ansistring;
  IPLU_Deleted_DT              : ansistring;
  IPLU_ModifiedBy_JUser_ID     : ansistring;
  IPLU_Modified_DT             : ansistring;
  JAS_Row_b                    : ansistring;
end;
procedure clear_JIPListLU(var p_rJIPListLU: rtJIPListLU);
//=============================================================================




//=============================================================================
{}
type rtJJobQ=record
  JJobQ_JJobQ_UID           : ansistring;
  JJobQ_JUser_ID            : ansistring;
  JJobQ_JJobType_ID         : ansistring;
  JJobQ_Start_DT            : ansistring;
  JJobQ_ErrorNo_u           : ansistring;
  JJobQ_Started_DT          : ansistring;
  JJobQ_Running_b           : ansistring;
  JJobQ_Finished_DT         : ansistring;
  JJobQ_Name                : ansistring;
  JJobQ_Repeat_b            : ansistring;
  JJobQ_RepeatMinute        : ansistring;
  JJobQ_RepeatHour          : ansistring;
  JJobQ_RepeatDayOfMonth    : ansistring;
  JJobQ_RepeatMonth         : ansistring;
  JJobQ_Completed_b         : ansistring;
  JJobQ_Result_URL          : ansistring;
  JJobQ_ErrorMsg            : ansistring;
  JJobQ_ErrorMoreInfo       : ansistring;
  JJobQ_Enabled_b           : ansistring;
  JJobQ_Job                 : ansistring;
  JJobQ_Result              : ansistring;
  JJobQ_CreatedBy_JUser_ID  : ansistring;
  JJobQ_Created_DT          : ansistring;
  JJobQ_ModifiedBy_JUser_ID : ansistring;
  JJobQ_Modified_DT         : ansistring;
  JJobQ_DeletedBy_JUser_ID  : ansistring;
  JJobQ_Deleted_DT          : ansistring;
  JJobQ_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
  JJobQ_JTask_ID            : ansistring;
end;
procedure clear_JJobQ(var p_rJJobQ: rtJJobQ);
//=============================================================================

//=============================================================================
type rtJLanguage = record
//=============================================================================
 	JLang_JLanguage_UID        : ansistring;
 	JLang_Name                 : ansistring;
 	JLang_NativeName           : ansistring;
 	JLang_Code                 : ansistring;
 	JLang_CreatedBy_JUser_ID   : ansistring;
 	JLang_Created_DT           : ansistring;
 	JLang_ModifiedBy_JUser_ID  : ansistring;
 	JLang_Modified_DT          : ansistring;
 	JLang_DeletedBy_JUser_ID   : ansistring;
 	JLang_Deleted_DT           : ansistring;
 	JLang_Deleted_b            : ansistring;
 	JAS_Row_b                  : ansistring;
end;
procedure clear_JLanguage(var p_rJLanguage: rtJLanguage);
//=============================================================================



//=============================================================================
type rtJLanguageLight = record
//=============================================================================
  u8JLanguage_UID        : UInt64;
  saName                 : ansistring;
  saNativeName           : ansistring;
  saCode                 : ansistring;
end;
procedure clear_JLanguageLight(var p_rJLanguageLight: rtJLanguageLight);
//=============================================================================


//=============================================================================
{}
type rtJLead=record
  JLead_JLead_UID           : ansistring;   //
  JLead_JLeadSource_ID      : ansistring;   //
  JLead_Owner_JUser_ID      : ansistring;   //
  JLead_Private_b           : ansistring;   //
  JLead_CompanyName         : ansistring;
  JLead_NameSalutation      : ansistring;   //
  JLead_NameFirst           : ansistring;   //
  JLead_NameMiddle          : ansistring;   //
  JLead_NameLast            : ansistring;   //
  JLead_NameSuffix          : ansistring;   //
  JLead_Desc                : ansistring;   //
  JLead_Gender              : ansistring;   //
  JLead_Home_Phone          : ansistring;   //
  JLead_Mobile_Phone        : ansistring;   //
  JLead_Work_Email          : ansistring;   //
  JLead_Work_Phone          : ansistring;   //
  JLead_Fax                 : ansistring;   //
  JLead_Home_Email          : ansistring;   //
  JLead_Website             : ansistring;   //
  JLead_Main_Addr1          : ansistring;   //
  JLead_Main_Addr2          : ansistring;   //
  JLead_Main_Addr3          : ansistring;   //
  JLead_Main_City           : ansistring;   //
  JLead_Main_State          : ansistring;   //
  JLead_Main_PostalCode     : ansistring;   //
  JLead_Main_Country        : ansistring;
  JLead_Ship_Addr1          : ansistring;   //
  JLead_Ship_Addr2          : ansistring;   //
  JLead_Ship_Addr3          : ansistring;   //
  JLead_Ship_City           : ansistring;   //
  JLead_Ship_State          : ansistring;   //
  JLead_Ship_PostalCode     : ansistring;   //
  JLead_Ship_Country        : ansistring;
  JLead_Exist_JCompany_ID   : ansistring;
  JLead_Exist_JPerson_ID    : ansistring;
  JLead_LeadSourceAddl      : ansistring;
  JLead_CreatedBy_JUser_ID  : ansistring;   //
  JLead_Created_DT          : ansistring;   //
  JLead_ModifiedBy_JUser_ID : ansistring;   //
  JLead_Modified_DT         : ansistring;   //
  JLead_DeletedBy_JUser_ID  : ansistring;   //
  JLead_Deleted_DT          : ansistring;   //
  JLead_Deleted_b           : ansistring;   //
  JAS_Row_b                 : ansistring;   //
end;
procedure clear_JLead(var p_rJLead: rtJLead);
//=============================================================================

//=============================================================================
{}
type rtJLeadSource=record
  JLDSR_JLeadSource_UID     : ansistring;
  JLDSR_Name                : ansistring;
  JLDSR_CreatedBy_JUser_ID  : ansistring;
  JLDSR_Created_DT          : ansistring;
  JLDSR_ModifiedBy_JUser_ID : ansistring;
  JLDSR_Modified_DT         : ansistring;
  JLDSR_DeletedBy_JUser_ID  : ansistring;
  JLDSR_Deleted_DT          : ansistring;
  JLDSR_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JLeadSource(var p_rJLeadSource: rtJLeadSource);
//=============================================================================

//=============================================================================
{}
type rtJLock=record
  JLock_JLock_UID           : ansistring;
  JLock_JSession_ID         : ansistring;
  JLock_JDConnection_ID     : ansistring;
  JLock_Locked_DT           : ansistring;
  JLock_Table_ID            : ansistring;
  JLock_Row_ID              : ansistring;
  JLock_Col_ID              : ansistring;
  JLock_Username            : ansistring;
  JLock_CreatedBy_JUser_ID  : ansistring;
end;
procedure clear_JLock(var p_rJLock: rtJLock);
//=============================================================================

//=============================================================================
{}
type rtJLog=record
  JLOG_JLog_UID              : ansistring;
  JLOG_DateNTime_DT          : ansistring;
  JLOG_JLogType_ID           : ansistring;
  JLOG_Entry_ID              : ansistring;
  JLOG_EntryData_s           : ansistring;
  JLOG_SourceFile_s          : ansistring;
  JLOG_User_ID               : ansistring;
  JLOG_CmdLine_s             : ansistring;
end;
procedure clear_JLog(var p_rJLog: rtJLog);
//=============================================================================

//=============================================================================
{}
type rtJLookup=record
  JLook_JLookup_UID         : ansistring;
  JLook_Name                : ansistring;
  JLook_Value               : ansistring;
  JLook_Position_u          : ansistring;
  JLook_en                  : ansistring;
  JLook_Created_DT          : ansistring;
  JLook_ModifiedBy_JUser_ID : ansistring;
  JLook_Modified_DT         : ansistring;
  JLook_DeletedBy_JUser_ID  : ansistring;
  JLook_Deleted_DT          : ansistring;
  JLook_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JLookup(var p_rJLookup: rtJLookup);
//=============================================================================



//=============================================================================
{}
type rtJMail=record
  JMail_JMail_UID              : ansistring;        
  JMail_To_User_ID             : ansistring;  
  JMail_From_User_ID           : ansistring;
  JMail_Message                : ansistring;
  JMail_Message_Code           : ansistring;
  JMail_CreatedBy_JUser_ID     : ansistring;        
  JMail_Created_DT             : ansistring;
  JMail_ModifiedBy_JUser_ID    : ansistring;
  JMail_Modified_DT            : ansistring;
  JMail_DeletedBy_JUser_ID     : ansistring;
  JMail_Deleted_DT             : ansistring;
  JMail_Deleted_b              : ansistring;
  JAS_Row_b                    : ansistring;
end;
procedure clear_jmail(var p_rJMail: rtJMail);
//=============================================================================






//=============================================================================
{}
type rtJMenu=record
  JMenu_JMenu_UID                   : Uint64; //< This is stored as integer For binary Search reasons. See JMenuDL.
  JMenu_JMenuParent_ID              : UInt64; //< This is stored as integer for binary search reasons. See JMenuDL.
  JMenu_JSecPerm_ID                 : ansistring;
  JMenu_Name_en                     : ansistring;
  JMenu_URL                         : ansistring;
  JMenu_NewWindow_b                 : ansistring;
  JMenu_IconSmall                   : ansistring;
  JMenu_IconLarge                   : ansistring;
  JMenu_ValidSessionOnly_b          : ansistring;
  JMenu_SEQ_u                       : ansistring;
  JMenu_DisplayIfNoAccess_b         : ansistring;
  JMenu_DisplayIfValidSession_b     : ansistring;
  JMenu_IconLarge_Theme_b           : ansistring;
  JMenu_IconSmall_Theme_b           : ansistring;
  JMenu_ReadMore_b                  : ansistring;
  JMenu_Title_en                    : ansistring;
  JMenu_Data_en                     : ansistring;
  JMenu_CreatedBy_JUser_ID          : ansistring;
  JMenu_Created_DT                  : ansistring;
  JMenu_ModifiedBy_JUser_ID         : ansistring;
  JMenu_Modified_DT                 : ansistring;
  JMenu_DeletedBy_JUser_ID          : ansistring;
  JMenu_Deleted_DT                  : ansistring;
  JMenu_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JMenu(var p_rJMenu: rtJMenu);
//=============================================================================


// ============================================================================
{}
Type rtJMime=record
  MIME_JMime_UID             : ansistring;
  MIME_Name                  : ansistring;
  MIME_Type                  : ansistring;
  MIME_Enabled_b             : ansistring;
  MIME_SNR_b                 : ansistring;
  MIME_CreatedBy_JUser_ID    : ansistring;
  MIME_Created_DT            : ansistring;
  MIME_ModifiedBy_JUser_ID   : ansistring;
  MIME_Modified_DT           : ansistring;
  MIME_DeletedBy_JUser_ID    : ansistring;
  MIME_Deleted_DT            : ansistring;
  MIME_Deleted_b             : ansistring;
  JAS_Row_b                  : ansistring;
end;
procedure clear_JMime(var p_rJMime: rtJMime);
// ============================================================================

// ============================================================================
{}
Type rtJMimeLight=record
  u8JMime_UID             : UInt64;
  saName                  : ansistring;
  saType                  : ansistring;
  bSNR                    : boolean;
end;
procedure clear_JMimeLight(var p_rJMimeLight: rtJMimeLight);
// ============================================================================



//=============================================================================
{}
type rtJModC=record
  JModC_JModC_UID           : ansistring;
  JModC_JInstalled_ID       : ansistring;
  JModC_Column_ID           : ansistring;
  JModC_Row_ID              : ansistring;
  JModC_CreatedBy_JUser_ID  : ansistring;
  JModC_Created_DT          : ansistring;
  JModC_ModifiedBy_JUser_ID : ansistring;
  JModC_Modified_DT         : ansistring;
  JModC_DeletedBy_JUser_ID  : ansistring;
  JModC_Deleted_DT          : ansistring;
  JModC_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JModC(var p_rJModC: rtJModC);
//=============================================================================

//=============================================================================
{}
type rtJModule=record
  JModu_JModule_UID         : ansistring;
  JModu_Name                : ansistring;
  JModu_Version_Major_u     : ansistring;
  JModu_Version_Minor_u     : ansistring;
  JModu_Version_Revision_u  : ansistring;
  JModu_CreatedBy_JUser_ID  : ansistring;
  JModu_Created_DT          : ansistring;
  JModu_ModifiedBy_JUser_ID : ansistring;
  JModu_Modified_DT         : ansistring;
  JModu_DeletedBy_JUser_ID  : ansistring;
  JModu_Deleted_DT          : ansistring;
  JModu_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JModule(var p_rJModule: rtJModule);
//=============================================================================

//=============================================================================
{}
type rtJModuleConfig=record
  JMCfg_JModuleConfig_UID   : ansistring;
  JMCfg_JModuleSetting_ID   : ansistring;
  JMCfg_Value               : ansistring;
  JMCfg_JNote_ID           : ansistring;
  JMCfg_JInstalled_ID       : ansistring;
  JMCfg_JUser_ID            : ansistring;
  JMCfg_Read_JSecPerm_ID    : ansistring;
  JMCfg_Write_JSecPerm_ID   : ansistring;
  JMCfg_CreatedBy_JUser_ID  : ansistring;
  JMCfg_Created_DT          : ansistring;
  JMCfg_ModifiedBy_JUser_ID : ansistring;
  JMCfg_Modified_DT         : ansistring;
  JMCfg_DeletedBy_JUser_ID  : ansistring;
  JMCfg_Deleted_DT          : ansistring;
  JMCfg_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JModuleConfig(var p_rJModuleConfig: rtJModuleConfig);
//=============================================================================


//=============================================================================
{}
type rtJModuleSetting=record
  JMSet_JModuleSetting_UID  : ansistring;
  JMSet_Name                : ansistring;
  JMSet_JCaption_ID         : ansistring;
  JMSet_JNote_ID           : ansistring;
  JMSet_JModule_ID          : ansistring;
  JMSet_CreatedBy_JUser_ID  : ansistring;
  JMSet_Created_DT          : ansistring;
  JMSet_ModifiedBy_JUser_ID : ansistring;
  JMSet_Modified_DT         : ansistring;
  JMSet_DeletedBy_JUser_ID  : ansistring;
  JMSet_Deleted_DT          : ansistring;
  JMSet_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JModuleSetting(var p_rJModuleSetting: rtJModuleSetting);
//=============================================================================




//=============================================================================
{}
type rtJNote=record
  JNote_JNote_UID           : ansistring;
  JNote_JTable_ID           : ansistring;
  JNote_JColumn_ID          : ansistring;
  JNote_Row_ID              : ansistring;
  JNote_Orphan_b            : ansistring;
  JNote_en                  : ansistring;
  JNote_Created_DT          : ansistring;
  JNote_CreatedBy_JUser_ID  : ansistring;
  JNote_Modified_DT         : ansistring;
  JNote_ModifiedBy_JUser_ID : ansistring;
  JNote_DeletedBy_JUser_ID  : ansistring;
  JNote_Deleted_DT          : ansistring;
  JNote_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JNote(var p_rJNote: rtJNote);
//=============================================================================





//=============================================================================
{}
type rtJPassword=record
  JPass_JPassword_UID        : ansistring;
  JPass_Name                 : ansistring;
  JPass_Desc                 : ansistring;
  JPass_URL                  : ansistring;
  JPass_Owner_JUser_ID       : ansistring;
  JPass_Private_Memo         : ansistring;
  JPass_JSecPerm_ID          : ansistring;
  JPass_CreatedBy_JUser_ID   : ansistring;
  JPass_Created_DT           : ansistring;
  JPass_ModifiedBy_JUser_ID  : ansistring;
  JPass_Modified_DT          : ansistring;
  JPass_DeletedBy_JUser_ID   : ansistring;
  JPass_Deleted_DT           : ansistring;
  JPass_Deleted_b            : ansistring;
  JAS_Row_b                  : ansistring;
end;
procedure clear_JPassword(var p_rJPassword: rtJPassword);
//=============================================================================





//=============================================================================
{}
type rtJPerson=record
  JPers_JPerson_UID                 : ansistring;
  JPers_Desc                        : ansistring;
  JPers_NameSalutation              : ansistring;
  JPers_NameFirst                   : ansistring;
  JPers_NameMiddle                  : ansistring;
  JPers_NameLast                    : ansistring;
  JPers_NameSuffix                  : ansistring;
  JPers_NameDear                    : ansistring;
  JPers_Gender                      : ansistring;
  JPers_Private_b                   : ansistring;
  JPers_Addr1                       : ansistring;
  JPers_Addr2                       : ansistring;
  JPers_Addr3                       : ansistring;
  JPers_City                        : ansistring;
  JPers_State                       : ansistring;
  JPers_PostalCode                  : ansistring;
  JPers_Country                     : ansistring;
  JPers_Home_Email                  : ansistring;
  JPers_Home_Phone                  : ansistring;
  JPers_Latitude_d                  : ansistring;
  JPers_Longitude_d                 : ansistring;
  JPers_Mobile_Phone                : ansistring;
  JPers_Work_Email                  : ansistring;
  JPers_Work_Phone                  : ansistring;
  JPers_Primary_Company_ID          : ansistring;
  JPers_Customer_b                  : ansistring;
  JPers_Vendor_b                    : ansistring;
  JPers_DOB_DT                      : ansistring;
  JPers_CC                          : ansistring;
  JPers_CCExpire                    : ansistring;
  JPers_CCSecCode                   : ansistring;
  JPers_CreatedBy_JUser_ID          : ansistring;
  JPers_Created_DT                  : ansistring;
  JPers_ModifiedBy_JUser_ID         : ansistring;
  JPers_Modified_DT                 : ansistring;
  JPers_DeletedBy_JUser_ID          : ansistring;
  JPers_Deleted_DT                  : ansistring;
  JPers_Deleted_b                   : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JPerson(var p_rJPerson: rtJPerson);
//=============================================================================


//=============================================================================
{}
type rtJPriority=record
  JPrio_JPriority_UID       : ansistring;
  JPrio_en                  : ansistring;
  JPrio_CreatedBy_JUser_ID  : ansistring;
  JPrio_Created_DT          : ansistring;
  JPrio_ModifiedBy_JUser_ID : ansistring;
  JPrio_Modified_DT         : ansistring;
  JPrio_DeletedBy_JUser_ID  : ansistring;
  JPrio_Deleted_DT          : ansistring;
  JPrio_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JPriority(var p_rJPriority: rtJPriority);
//=============================================================================






//=============================================================================
{}
type rtJProduct=record
  JProd_JProduct_UID          : ansistring;
  JProd_Number                : ansistring;
  JProd_Name                  : ansistring;
  JProd_Desc                  : ansistring;
  JProd_CreatedBy_JUser_ID    : ansistring;
  JProd_Created_DT            : ansistring;
  JProd_ModifiedBy_JUser_ID   : ansistring;
  JProd_Modified_DT           : ansistring;
  JProd_DeletedBy_JUser_ID    : ansistring;
  JProd_Deleted_DT            : ansistring;
  JProd_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JProduct(var p_rJProduct: rtJProduct);
//=============================================================================

//=============================================================================
{}
type rtJProductGrp=record
  JPrdG_JProductGrp_UID     : ansistring;
  JPrdG_Name                : ansistring;
  JPrdG_Desc                : ansistring;
  JPrdG_CreatedBy_JUser_ID  : ansistring;
  JPrdG_Created_DT          : ansistring;
  JPrdG_ModifiedBy_JUser_ID : ansistring;
  JPrdG_Modified_DT         : ansistring;
  JPrdG_DeletedBy_JUser_ID  : ansistring;
  JPrdG_Deleted_DT          : ansistring;
  JPrdG_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JProductGrp(var p_rJProductGrp: rtJProductGrp);
//=============================================================================

//=============================================================================
{}
type rtJProductQty=record
  JPrdQ_JProductQty_UID     : ansistring;
  JPrdQ_Location_JCompany_ID: ansistring;
  JPrdQ_QtyOnHand_d         : ansistring;
  JPrdQ_QtyOnOrder_d        : ansistring;
  JPrdQ_QtyOnBackOrder_d    : ansistring;
  JPrdQ_JProduct_ID         : ansistring;
  JPrdQ_CreatedBy_JUser_ID  : ansistring;
  JPrdQ_Created_DT          : ansistring;
  JPrdQ_ModifiedBy_JUser_ID : ansistring;
  JPrdQ_Modified_DT         : ansistring;
  JPrdQ_DeletedBy_JUser_ID  : ansistring;
  JPrdQ_Deleted_DT          : ansistring;
  JPrdQ_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JProductQty(var p_rJProductQty: rtJProductQty);
//=============================================================================

//=============================================================================
{}
type rtJProject=record
  JProj_JProject_UID          : ansistring;
  JProj_Name                  : ansistring;
  JProj_Owner_JUser_ID        : ansistring;
  JProj_URL                   : ansistring;
  JProj_URL_Stage             : ansistring;
  JProj_JProjectStatus_ID     : ansistring;
  JProj_JProjectPriority_ID   : ansistring;
  JProj_JProjectCategory_ID   : ansistring;
  JProj_Progress_PCT_d        : ansistring;
  JProj_Hours_Worked_d        : ansistring;
  JProj_Hours_Sched_d         : ansistring;
  JProj_Hours_Project_d       : ansistring;
  JProj_Desc                  : ansistring;
  JProj_Start_DT              : ansistring;
  JProj_Target_End_DT         : ansistring;
  JProj_Actual_End_DT         : ansistring;
  JProj_Target_Budget_d       : ansistring;
  JProj_JCompany_ID           : ansistring;
  JProj_JPerson_ID            : ansistring;
  JProj_CreatedBy_JUser_ID    : ansistring;
  JProj_Created_DT            : ansistring;
  JProj_ModifiedBy_JUser_ID   : ansistring;
  JProj_Modified_DT           : ansistring;
  JProj_DeletedBy_JUser_ID    : ansistring;
  JProj_Deleted_DT            : ansistring;
  JProj_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JProject(var p_rJProject: rtJProject);
//=============================================================================


//=============================================================================
{}
type rtJProjectCategory=record
  JPjCt_JProjectCategory_UID : ansistring;
  JPjCt_Name                 : ansistring;
  JPjCt_Desc                 : ansistring;
  JPjCt_JCaption_ID          : ansistring;
  JPjCt_CreatedBy_JUser_ID   : ansistring;
  JPjCt_Created_DT           : ansistring;
  JPjCt_ModifiedBy_JUser_ID  : ansistring;
  JPjCt_Modified_DT          : ansistring;
  JPjCt_DeletedBy_JUser_ID   : ansistring;
  JPjCt_Deleted_DT           : ansistring;
  JPjCt_Deleted_b            : ansistring;
  JAS_Row_b                  : ansistring;
end;
procedure clear_JProjectCategory(var p_rJProjectCategory: rtJProjectCategory);
//=============================================================================



//=============================================================================
{}
type rtJQuickLink=record
  JQLnk_JQuickLink_UID          : ansistring;
  JQLnk_Name                    : ansistring;
  JQLnk_SecPerm_ID              : ansistring;
  JQLnk_Desc                    : ansistring;
  JQLnk_URL                     : ansistring;
  JQLnk_Icon                    : ansistring;
  JQLnk_Owner_JUser_ID          : ansistring;
  JQLnk_Position_u              : ansistring;
  JQLnk_ValidSessionOnly_b      : ansistring;
  JQLnk_DisplayIfNoAccess_b     : ansistring;
  JQLnk_DisplayIfValidSession_b : ansistring;
  JQLnk_RenderAsUniqueDiv_b     : ansistring;
  JQLnk_Private_Memo            : ansistring;
  JQLnk_Private_b               : ansistring;
  JQLnk_CreatedBy_JUser_ID      : ansistring;
  JQLnk_Created_DT              : ansistring;
  JQLnk_ModifiedBy_JUser_ID     : ansistring;
  JQLnk_Modified_DT             : ansistring;
  JQLnk_DeletedBy_JUser_ID      : ansistring;
  JQLnk_Deleted_b               : ansistring;
  JQLnk_Deleted_DT              : ansistring;
  JAS_Row_b                     : ansistring;
end;
procedure clear_JQuickLink(p_rJQuickLink: rtJQuickLink);
//=============================================================================



//=============================================================================
{}
Type rtJScreen=Record
  JScrn_JScreen_UID         : AnsiString;
  JScrn_Name                : AnsiString;
  JScrn_Desc                : ansistring;
  JScrn_JCaption_ID         : ansistring;
  JScrn_JScreenType_ID      : AnsiString;
  JScrn_Template            : AnsiString;
  JScrn_ValidSessionOnly_b  : ansistring;
  JScrn_JSecPerm_ID         : ansistring;
  JScrn_Detail_JScreen_ID   : Ansistring;
  JScrn_IconSmall           : AnsiString;
  JScrn_IconLarge           : AnsiString;
  JScrn_TemplateMini        : ansistring;
  JScrn_Help_ID            : ansistring;
  JScrn_Modify_JSecPerm_ID  : ansistring;
  JScrn_CreatedBy_JUser_ID  : ansistring;
  JScrn_Created_DT          : ansistring;
  JScrn_ModifiedBy_JUser_ID : ansistring;
  JScrn_Modified_DT         : ansistring;
  JScrn_DeletedBy_JUser_ID  : ansistring;
  JScrn_Deleted_DT          : ansistring;
  JScrn_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
End;
procedure clear_JScreen(var p_rJScreen: rtJScreen);
//=============================================================================


//=============================================================================
{}
type rtJScreenType=record
  JScTy_JScreenType_UID     : ansistring;
  JScTy_Name                : ansistring;
  JScTy_CreatedBy_JUser_ID  : ansistring;
  JScTy_Created_DT          : ansistring;
  JScTy_ModifiedBy_JUser_ID : ansistring;
  JScTy_Modified_DT         : ansistring;
  JScTy_DeletedBy_JUser_ID  : ansistring;
  JScTy_Deleted_DT          : ansistring;
  JScTy_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JScreenType(var p_rJScreenType: rtJScreenType);
//=============================================================================

//=============================================================================
{}
type rtJSecGrp=record
  JSGrp_JSecGrp_UID           : ansistring;
  JSGrp_Name                  : ansistring;
  JSGrp_Desc                  : ansistring;
  JSGrp_CreatedBy_JUser_ID    : ansistring;
  JSGrp_Created_DT            : ansistring;
  JSGrp_ModifiedBy_JUser_ID   : ansistring;
  JSGrp_Modified_DT           : ansistring;
  JSGrp_DeletedBy_JUser_ID    : ansistring;
  JSGrp_Deleted_DT            : ansistring;
  JSGrp_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JSecGrp(var p_rJSecGrp: rtJSecGrp);
//=============================================================================


//=============================================================================
{}
type rtJSecGrpLink=record
  JSGLk_JSecGrpLink_UID     : ansistring;
  JSGLk_JSecPerm_ID         : ansistring;
  JSGLk_JSecGrp_ID          : ansistring;
  JSGLk_CreatedBy_JUser_ID  : ansistring;
  JSGLk_Created_DT          : ansistring;
  JSGLk_ModifiedBy_JUser_ID : ansistring;
  JSGLk_Modified_DT         : ansistring;
  JSGLk_DeletedBy_JUser_ID  : ansistring;
  JSGLk_Deleted_DT          : ansistring;
  JSGLk_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JSecGrpLink(var p_rJSecGrpLink: rtJSecGrpLink);
//=============================================================================

//=============================================================================
{}
type rtJSecGrpUserLink=record
  JSGUL_JSecGrpUserLink_UID   : ansistring;
  JSGUL_JSecGrp_ID            : ansistring;
  JSGUL_JUser_ID              : ansistring;
  JSGUL_CreatedBy_JUser_ID    : ansistring;
  JSGUL_Created_DT            : ansistring;
  JSGUL_ModifiedBy_JUser_ID   : ansistring;
  JSGUL_Modified_DT           : ansistring;
  JSGUL_DeletedBy_JUser_ID    : ansistring;
  JSGUL_Deleted_DT            : ansistring;
  JSGUL_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JSecGrpUserLink(var p_rJSecGrpUserLink: rtJSecGrpUserLink);
//=============================================================================

//=============================================================================
{}
type rtJSecKey=record
  JSKey_JSecKey_UID           : ansistring;
  JSKey_KeyPub                : ansistring;
  JSKey_KeyPvt                : ansistring;
  JSKey_CreatedBy_JUser_ID    : ansistring;
  JSKey_Created_DT            : ansistring;
  JSKey_ModifiedBy_JUser_ID   : ansistring;
  JSKey_Modified_DT           : ansistring;
  JSKey_DeletedBy_JUser_ID    : ansistring;
  JSKey_Deleted_DT            : ansistring;
  JSKey_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JSecKey(var p_rJSecKey: rtJSecKey);
//=============================================================================

//=============================================================================
{}
type rtJSecPerm=record
  JSPrm_JSecPerm_UID        : ansistring;
  JSPrm_Name                : ansistring;
  JSPrm_CreatedBy_JUser_ID  : ansistring;
  JSPrm_Created_DT          : ansistring;
  JSPrm_ModifiedBy_JUser_ID : ansistring;
  JSPrm_Modified_DT         : ansistring;
  JSPrm_DeletedBy_JUser_ID  : ansistring;
  JSPrm_Deleted_DT          : ansistring;
  JSPrm_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JSecPerm(var p_rJSecPerm: rtJSecPerm);
//=============================================================================

//=============================================================================
{}
type rtJSecPermUserLink=record
  JSPUL_JSecPermUserLink_UID  : ansistring;
  JSPUL_JSecPerm_ID           : ansistring;
  JSPUL_JUser_ID              : ansistring;
  JSPUL_CreatedBy_JUser_ID    : ansistring;
  JSPUL_Created_DT            : ansistring;
  JSPUL_ModifiedBy_JUser_ID   : ansistring;
  JSPUL_Modified_DT           : ansistring;
  JSPUL_DeletedBy_JUser_ID    : ansistring;
  JSPUL_Deleted_DT            : ansistring;
  JSPUL_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JSecPermUserLink(var p_rJSecPermUserLink: rtJSecPermUserLink);
//=============================================================================



//=============================================================================
{}
type rtJSession=REcord
//=============================================================================
  {}
  JSess_JSession_UID        : ansistring;
  JSess_JSessionType_ID     : ansistring;
  JSess_JUser_ID            : ansistring;
  JSess_Connect_DT          : ansistring;
  JSess_LastContact_DT      : ansistring;
  JSess_IP_ADDR             : ansistring;
  JSess_PORT_u              : ansistring;
  JSess_Username            : ansistring;
  JSess_JJobQ_ID            : ansistring;
end;
procedure clear_JSession(var p_rJSession: rtJSession);
//=============================================================================



//=============================================================================
{}
type rtJSessionData=record
  JSDat_JSessionData_UID      : ansistring;
  JSDat_JSession_ID           : ansistring;
  JSDat_Name                  : ansistring;
  JSDat_Value                 : ansistring;
  JSDat_CreatedBy_JUser_ID    : ansistring;
  JSDat_Created_DT            : ansistring;
end;
procedure clear_JSessionData(var p_rJSessionData: rtJSessionData);
//=============================================================================



//=============================================================================
{}
type rtJSessionType=record
  JSTyp_JSessionType_UID    : ansistring;
  JSTyp_Name                : ansistring;
  JSTyp_Desc                : ansistring;
  JSTyp_CreatedBy_JUser_ID  : ansistring;
  JSTyp_Created_DT          : ansistring;
  JSTyp_ModifiedBy_JUser_ID : ansistring;
  JSTyp_Modified_DT         : ansistring;
  JSTyp_DeletedBy_JUser_ID  : ansistring;
  JSTyp_Deleted_DT          : ansistring;
  JSTyp_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JSessionType(var p_rJSessionType: rtJSessionType);
//=============================================================================



//=============================================================================
{}
type rtJSysModule=record
  JSysM_JSysModule_UID      : ansistring;
  JSysM_Name                : ansistring;
  JSysM_CreatedBy_JUser_ID  : ansistring;
  JSysM_Created_DT          : ansistring;
  JSysM_ModifiedBy_JUser_ID : ansistring;
  JSysM_Modified_DT         : ansistring;
  JSysM_DeletedBy_JUser_ID  : ansistring;
  JSysM_Deleted_DT          : ansistring;
  JSysM_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JSysModule(var p_rJSysModule: rtJSysModule);
//=============================================================================

//=============================================================================
{}
type rtJTable=record
  JTabl_JTable_UID          : ansistring;
  JTabl_Name                : ansistring;
  JTabl_Desc                : ansistring;
  JTabl_JTableType_ID       : ansistring;
  JTabl_JDConnection_ID     : ansistring;
  JTabl_ColumnPrefix        : ansistring;
  JTabl_DupeScore_u         : ansistring;
  JTabl_Perm_JColumn_ID     : ansistring;
  JTabl_Owner_Only_b        : ansistring;
  JTabl_View_MySQL          : ansistring;
  JTabl_View_MSSQL          : ansistring;
  JTabl_View_MSAccess       : ansistring;
  JTabl_Add_JSecPerm_ID     : ansistring;
  JTabl_Update_JSecPerm_ID  : ansistring;
  JTabl_View_JSecPerm_ID    : ansistring;
  JTabl_Delete_JSecPerm_ID  : ansistring;
  JTabl_CreatedBy_JUser_ID  : ansistring;
  JTabl_Created_DT          : ansistring;
  JTabl_ModifiedBy_JUser_ID : ansistring;
  JTabl_Modified_DT         : ansistring;
  JTabl_DeletedBy_JUser_ID  : ansistring;
  JTabl_Deleted_DT          : ansistring;
  JTabl_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JTable(var p_rJTable: rtJTable);
//=============================================================================

//=============================================================================
{}
type rtJTableType=record
  JTTyp_JTableType_UID      : ansistring;
  JTTyp_Name                : ansistring;
  JTTyp_Desc                : ansistring;
  JTTyp_CreatedBy_JUser_ID  : ansistring;
  JTTyp_Created_DT          : ansistring;
  JTTyp_ModifiedBy_JUser_ID : ansistring;
  JTTyp_Modified_DT         : ansistring;
  JTTyp_DeletedBy_JUser_ID  : ansistring;
  JTTyp_Deleted_DT          : ansistring;
  JTTyp_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JTableType(var p_rJTableType: rtJTableType);
//=============================================================================

//=============================================================================
{}
type rtJTask=record
  JTask_JTask_UID                  : ansistring;
  JTask_Name                       : ansistring;
  JTask_Desc                       : ansistring;
  JTask_JTaskCategory_ID           : ansistring;
  JTask_JProject_ID                : ansistring;
  JTask_JStatus_ID                 : ansistring;
  JTask_Due_DT                     : ansistring;
  JTask_Duration_Minutes_Est       : ansistring;
  JTask_JPriority_ID               : ansistring;
  JTask_Start_DT                   : ansistring;
  JTask_Owner_JUser_ID             : ansistring;
  JTask_SendReminder_b             : ansistring;
  JTask_ReminderSent_b             : ansistring;
  JTask_ReminderSent_DT            : ansistring;
  JTask_Remind_DaysAhead_u         : ansistring;
  JTask_Remind_HoursAhead_u        : ansistring;
  JTask_Remind_MinutesAhead_u      : ansistring;
  JTask_Remind_Persistantly_b      : ansistring;
  JTask_Progress_PCT_d             : ansistring;
  JTask_JCase_ID                   : ansistring;
  JTask_Directions_URL             : ansistring;
  JTask_URL                        : ansistring;
  JTask_Milestone_b                : ansistring;
  JTask_Budget_d                   : ansistring;
  JTask_ResolutionNotes            : ansistring;
  JTask_Completed_DT               : ansistring;
  JTask_CreatedBy_JUser_ID         : ansistring;
  JTask_Related_JTable_ID          : ansistring;
  JTask_Related_Row_ID             : ansistring;
  JTask_Created_DT                 : ansistring;
  JTask_ModifiedBy_JUser_ID        : ansistring;
  JTask_Modified_DT                : ansistring;
  JTask_DeletedBy_JUser_ID         : ansistring;
  JTask_Deleted_DT                 : ansistring;
  JTask_Deleted_b                  : ansistring;
  JAS_Row_b                        : ansistring;
end;
procedure clear_JTask(var p_rJTask: rtJTask);
//=============================================================================


//=============================================================================
{}
type rtJTaskCategory=record
  JTCat_JTaskCategory_UID   : ansistring;
  JTCat_Name                : ansistring;
  JTCat_Desc                : ansistring;
  JTCat_JCaption_ID         : ansistring;
  JTCat_CreatedBy_JUser_ID  : ansistring;
  JTCat_Created_DT          : ansistring;
  JTCat_ModifiedBy_JUser_ID : ansistring;
  JTCat_Modified_DT         : ansistring;
  JTCat_DeletedBy_JUser_ID  : ansistring;
  JTCat_Deleted_DT          : ansistring;
  JTCat_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JTaskCategory(var p_rJTaskCategory: rtJTaskCategory);
//=============================================================================

//=============================================================================
{}
type rtJStatus=record
  JStat_JStatus_UID         : ansistring;
  JStat_Name                : ansistring;
  JStat_Desc                : ansistring;
  JStat_JCaption_ID         : ansistring;
  JStat_CreatedBy_JUser_ID  : ansistring;
  JStat_Created_DT          : ansistring;
  JStat_ModifiedBy_JUser_ID : ansistring;
  JStat_Modified_DT         : ansistring;
  JStat_DeletedBy_JUser_ID  : ansistring;
  JStat_Deleted_DT          : ansistring;
  JStat_Deleted_b           : ansistring;
  JAS_Row_b                 : ansistring;
end;
procedure clear_JStatus(var p_rJStatus: rtJStatus);
//=============================================================================


//=============================================================================
{}
type rtJTimecard=record
  TMCD_TimeCard_UID                 : ansistring;
  TMCD_Name                         : ansistring;
  TMCD_In_DT                        : ansistring;
  TMCD_Out_DT                       : ansistring;
  TMCD_JNote_Public_ID              : ansistring;
  TMCD_JNote_Internal_ID            : ansistring;
  TMCD_Reference                    : ansistring;
  TMCD_JProject_ID                  : ansistring;
  TMCD_JTask_ID                     : ansistring;
  TMCD_Billable_b                   : ansistring;
  TMCD_ManualEntry_b                : ansistring;
  TMCD_ManualEntry_DT               : ansistring;
  TMCD_Exported_b                   : ansistring;
  TMCD_Exported_DT                  : ansistring;
  TMCD_Uploaded_b                   : ansistring;
  TMCD_Uploaded_DT                  : ansistring;
  TMCD_PayrateName                  : ansistring;
  TMCD_Payrate_d                    : ansistring;
  TMCD_Expense_b                    : ansistring;
  TMCD_Imported_b                   : ansistring;
  TMCD_Imported_DT                  : ansistring;
  TMCD_BillTo_Entity_ID             : ansistring;
  TMCD_Client_Entity_ID             : ansistring;
  TMCD_Note_Internal                : ansistring; 
  TMCD_Note_Public                  : ansistring;  
  TMCD_Invoice_Sent_b               : ansistring;
  TMCD_Invoice_Paid_b               : ansistring;
  TMCD_Invoice_No                   : ansistring;
  TMCD_CreatedBy_JUser_ID           : ansistring;
  TMCD_Created_DT                   : ansistring;
  TMCD_ModifiedBy_JUser_ID          : ansistring;
  TMCD_Modified_DT                  : ansistring;
  TMCD_DeletedBy_JUser_ID           : ansistring;
  TMCD_Deleted_DT                   : ansistring;
  TMCD_Deleted_b                    : ansistring;
  JAS_Row_b                         : ansistring;
end;
procedure clear_JTimecard(var p_rJTimecard: rtJTimecard);
//=============================================================================

//=============================================================================
{}
type rtJTeam=record
  JTeam_JTeam_UID             : ansistring;
  JTeam_Parent_JTeam_ID       : ansistring;
  JTeam_JCompany_ID           : ansistring;
  JTeam_Name                  : ansistring;
  JTeam_Desc                  : ansistring;
  JTeam_CreatedBy_JUser_ID    : ansistring;
  JTeam_Created_DT            : ansistring;
  JTeam_ModifiedBy_JUser_ID   : ansistring;
  JTeam_Modified_DT           : ansistring;
  JTeam_DeletedBy_JUser_ID    : ansistring;
  JTeam_Deleted_DT            : ansistring;
  JTeam_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JTeam(var p_rJTeam: rtJTeam);
//=============================================================================

//=============================================================================
{}
type rtJTeamMember=record
  JTMem_JTeamMember_UID       : ansistring;
  JTMem_JTeam_ID              : ansistring;
  JTMem_JPerson_ID            : ansistring;
  JTMem_JCompany_ID           : ansistring;
  JTMem_JUser_ID              : ansistring;
  JTMem_CreatedBy_JUser_ID    : ansistring;
  JTMem_Created_DT            : ansistring;
  JTMem_ModifiedBy_JUser_ID   : ansistring;
  JTMem_Modified_DT           : ansistring;
  JTMem_DeletedBy_JUser_ID    : ansistring;
  JTMem_Deleted_DT            : ansistring;
  JTMem_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JTeamMember(var p_rJTeamMember: rtJTeamMember);
//=============================================================================


//=============================================================================
{}
type rtJTestOne=record
  JTes1_JTestOne_UID          : ansistring;
  JTes1_Text                  : ansistring;
  JTes1_Boolean_b             : ansistring;
  JTes1_Memo                  : ansistring;
  JTes1_DateTime_DT           : ansistring;
  JTes1_Integer_i             : ansistring;
  JTes1_Currency_d            : ansistring;
  JTes1_Memo2                 : ansistring;
  JTes1_Added_DT              : ansistring;
  JTes1_RemoteIP              : ansistring;
  JTes1_RemotePort_u          : ansistring;
  JTes1_CreatedBy_JUser_ID    : ansistring;
  JTes1_Created_DT            : ansistring;
  JTes1_ModifiedBy_JUser_ID   : ansistring;
  JTes1_Modified_DT           : ansistring;
  JTes1_DeletedBy_JUser_ID    : ansistring;
  JTes1_Deleted_DT            : ansistring;
  JTes1_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JTestOne(var p_rJTestOne: rtJTestOne);
//=============================================================================





//=============================================================================
{}
type rtJThemeColor=record
  THCOL_JThemeColor_UID       : ansistring;
  THCOL_Name                  : ansistring;
  THCOL_Desc                  : ansistring;
  THCOL_Template_Header       : ansistring;
  THCOL_CreatedBy_JUser_ID    : ansistring;
  THCOL_Created_DT            : ansistring;
  THCOL_ModifiedBy_JUser_ID   : ansistring;
  THCOL_Modified_DT           : ansistring;
  THCOL_DeletedBy_JUser_ID    : ansistring;
  THCOL_Deleted_DT            : ansistring;
  THCOL_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_jthemecolor(var p_rJThemeColor: rtJThemeColor);
//=============================================================================



//=============================================================================
{}
type rtJThemeColorLight=record
  u8JThemeColor_UID       : Uint64;
  saName                  : ansistring;
  saTemplate_Header       : ansistring;
end;
procedure clear_jthemecolorlight(var p_rJThemeColorLight: rtJThemeColorLight);
//=============================================================================




//=============================================================================
{}
type rtJTrak=record
  JTrak_JTrak_UID           : ansistring;
  JTrak_JDConnection_ID     : ansistring;
  JTrak_JSession_ID         : ansistring;
  JTrak_JTable_ID           : ansistring;
  JTrak_Row_ID              : ansistring;
  JTrak_Col_ID              : ansistring;
  JTrak_JUser_ID            : ansistring;
  JTrak_Create_b            : ansistring;
  JTrak_Modify_b            : ansistring;
  JTrak_Delete_b            : ansistring;
  JTrak_When_DT             : ansistring;
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
  JUser_Login_First_DT         : ansistring;
  JUser_Login_Last_DT          : ansistring;
  JUser_Logins_Successful_u    : cardinal;
  JUser_Logins_Failed_u        : cardinal;
  JUser_Password_Changed_DT    : ansistring;
  JUser_AllowedSessions_u      : byte;
  JUser_DefaultPage_Login      : ansistring;
  JUser_DefaultPage_Logout     : ansistring;
  JUser_JLanguage_ID           : UInt64;
  JUser_Audit_b                : Boolean;
  JUser_ResetPass_u            : UInt64;
  JUser_JVHost_ID              : ansistring;
  JUser_TotalJetUsers_d        : ansistring;
  JUser_SIP_Exten              : ansistring;
  JUser_SIP_Pass               : ansistring;
  JUser_CreatedBy_JUser_ID     : ansistring;
  JUser_Created_DT             : ansistring;
  JUser_ModifiedBy_JUser_ID    : ansistring;
  JUser_Modified_DT            : ansistring;
  JUser_DeletedBy_JUser_ID     : ansistring;
  JUser_Deleted_DT             : ansistring;
  JUser_Deleted_b              : ansistring;
  JAS_Row_b                    : boolean;
end;
procedure clear_JUser(var p_rJUser: rtJUser);
//=============================================================================



//=============================================================================
{}
type rtJUserPref=record
  UserP_UserPref_UID          : ansistring;
  UserP_Name                  : ansistring;
  UserP_Desc                  : ansistring;
  UserP_CreatedBy_JUser_ID    : ansistring;
  UserP_Created_DT            : ansistring;
  UserP_ModifiedBy_JUser_ID   : ansistring;
  UserP_Modified_DT           : ansistring;
  UserP_DeletedBy_JUser_ID    : ansistring;
  UserP_Deleted_DT            : ansistring;
  UserP_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JUserPref(var p_rJUserPref: rtJUserPref);
//=============================================================================

//=============================================================================
{}
type rtJUserPrefLink=record
  UsrPL_UserPrefLink_UID      : ansistring;
  UsrPL_UserPref_ID           : ansistring;
  UsrPL_User_ID               : ansistring;
  UsrPL_Value                 : ansistring;
  UsrPL_CreatedBy_JUser_ID    : ansistring;
  UsrPL_Created_DT            : ansistring;
  UsrPL_ModifiedBy_JUser_ID   : ansistring;
  UsrPL_Modified_DT           : ansistring;
  UsrPL_DeletedBy_JUser_ID    : ansistring;
  UsrPL_Deleted_DT            : ansistring;
  UsrPL_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JUserPrefLink(var p_rJUserPrefLink: rtJUserPrefLink);
//=============================================================================




//=============================================================================
{}
type rtJVHost=record
  VHost_JVHost_UID               : ansistring;
  VHost_WebRootDir               : ansistring;
  VHost_ServerName               : ansistring;
  VHost_ServerIdent              : ansistring;
  VHost_ServerDomain             : ansistring;
  VHost_ServerIP                 : ansistring;
  VHost_ServerPort               : ansistring;
  VHost_DefaultLanguage          : ansistring;
  VHost_DefaultColorTheme        : ansistring;
  VHost_MenuRenderMethod         : ansistring;
  VHost_DefaultArea              : ansistring;
  VHost_DefaultPage              : ansistring;
  VHost_DefaultSection           : ansistring;
  VHost_DefaultTop_JMenu_ID      : ansistring;
  VHost_DefaultLoggedInPage      : ansistring;
  VHost_DefaultLoggedOutPage     : ansistring;
  VHost_DataOnRight_b            : ansistring;
  VHost_CacheMaxAgeInSeconds     : ansistring;
  VHost_SystemEmailFromAddress   : ansistring;
  VHost_EnableSSL_b              : ansistring;
  VHost_SharesDefaultDomain_b    : ansistring;
  VHost_DefaultIconTheme         : ansistring;
  VHost_DirectoryListing_b       : ansistring;
  VHost_FileDir                  : ansistring;
  VHost_AccessLog                : ansistring;
  VHost_ErrorLog                 : ansistring;
  VHost_JDConnection_ID          : ansistring;
  VHost_Enabled_b                : ansistring;
  VHost_CacheDir                 : ansistring;
  VHost_TemplateDir              : ansistring;
  VHOST_SipURL                   : ansistring;
  VHost_CreatedBy_JUser_ID       : ansistring;
  VHost_Created_DT               : ansistring;
  VHost_ModifiedBy_JUser_ID      : ansistring;
  VHost_Modified_DT              : ansistring;
  VHost_DeletedBy_JUser_ID       : ansistring;
  VHost_Deleted_DT               : ansistring;
  VHost_Deleted_b                : ansistring;
  JAS_Row_b                      : ansistring;
end;
procedure clear_JVHost(var p_rJVHost: rtJVHost);
//=============================================================================

//=============================================================================
{}
type rtJVHostLight=record
  u8JVHost_UID               : UInt64;
  saWebRootDir               : ansistring;
  saServerName               : ansistring;
  saServerIdent              : ansistring;
  saServerDomain             : ansistring;
  saServerIP                 : ansistring;
  u2ServerPort               : Word;
  saDefaultLanguage          : ansistring;
  saDefaultColorTheme        : ansistring;
  u1MenuRenderMethod         : byte;
  saDefaultArea              : ansistring;
  saDefaultPage              : ansistring;
  saDefaultSection           : ansistring;
  u8DefaultTop_JMenu_ID      : UInt64;
  saDefaultLoggedInPage      : ansistring;
  saDefaultLoggedOutPage     : ansistring;
  bDataOnRight               : Boolean;
  sCacheMaxAgeInSeconds      : string;
  sSystemEmailFromAddress    : ansistring;
  bEnableSSL                 : boolean;
  bSharesDefaultDomain       : boolean;
  saDefaultIconTheme         : ansistring;
  bDirectoryListing          : boolean;
  saFileDir                  : ansistring;
  saAccessLog                : ansistring;
  saErrorLog                 : ansistring;
  u8JDConnection_ID          : UInt64;
  MenuDL                     : JFC_DL;
  bIdentOk                   : boolean;
  saCacheDir                 : ansistring;
  saTemplateDir              : ansistring;
  // OPTIONS BELOW COME FROM User Preferences Assigned to ADMIN
  // NOT FROM THE VHOST TABLE
  bAllowRegistration         : Boolean;
  bRegistrationReqCellPhone  : boolean;
  bRegistrationReqBirthday   : boolean;
  saSIPURL                   : ansistring;
end;
procedure clear_JVHostLight(var p_rJVHostLight: rtJVHostLight);
//=============================================================================




//=============================================================================
{}
type rtJWidget=record
  JWidg_JWidget_UID           : ansistring;
  JWidg_Name                  : ansistring;
  JWidg_Procedure             : ansistring;
  JWidg_Desc                  : ansistring;
  JWidg_CreatedBy_JUser_ID    : ansistring;
  JWidg_Created_DT            : ansistring;
  JWidg_ModifiedBy_JUser_ID   : ansistring;
  JWidg_Modified_DT           : ansistring;
  JWidg_DeletedBy_JUser_ID    : ansistring;
  JWidg_Deleted_DT            : ansistring;
  JWidg_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JWidget(var p_rJWidget: rtJWidget);
//=============================================================================

//=============================================================================
{}
type rtJWidgetLink=record
  JWLnk_JWidgetLink_UID       : ansistring;
  JWLnk_JWidget_ID            : ansistring;
  JWLnk_JDType_ID             : ansistring;
  JWLnk_JBlokType_ID          : ansistring;
  JWLnk_JInterface_ID         : ansistring;
  JWLnk_CreatedBy_JUser_ID    : ansistring;
  JWLnk_Created_DT            : ansistring;
  JWLnk_ModifiedBy_JUser_ID   : ansistring;
  JWLnk_Modified_DT           : ansistring;
  JWLnk_DeletedBy_JUser_ID    : ansistring;
  JWLnk_Deleted_DT            : ansistring;
  JWLnk_Deleted_b             : ansistring;
  JAS_Row_b                   : ansistring;
end;
procedure clear_JWidgetLink(var p_rJWidgetLink: rtJWidgetLink);
//=============================================================================

//=============================================================================
{}
type rtJWorkQueue=record
  JWrkQ_JWorkQueue_UID          : ansistring; //uid
  JWrkQ_JUser_ID                : ansistring; //user who caused job
  JWrkQ_Posted_DT               : ansistring; //when job submitted
  JWrkQ_Started_DT              : ansistring; //when actual processing of job started
  JWrkQ_Finished_DT             : ansistring; //when actual processing of job finished
  JWrkQ_Delivered_DT            : ansistring; //when results of job delivered
  JWrkQ_Job_GUID                : ansistring; // GUID for the job
  JWrkQ_Confirmed_b             : ansistring; // boolean indicating job confirmed as successful via GUID exchange
  JWrkQ_Confirmed_DT            : ansistring; // datetime job success confirmed. Note, if this datetime is not null but confirmed = false then this means job failed
  JWrkQ_JobType_ID              : ansistring; // Job Type ID
  JWrkQ_JobDesc                 : ansistring; // Short Description of job (255 char max)
  JWrkQ_Src_JUser_ID            : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_JDConnection_ID     : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_JTable_ID           : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Row_ID              : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Column_ID           : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_Data                : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_RemoteIP            : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Src_RemotePort_u        : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JUser_ID           : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JDConnection_ID    : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_JTable_ID          : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Row_ID             : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Column_ID          : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_Data               : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_RemoteIP           : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_Dest_RemotePort_u       : ansistring; // Fields available for job processing - implementation - jobtype dependent
  JWrkQ_CreatedBy_JUser_ID      : ansistring;
  JWrkQ_Created_DT              : ansistring;
  JWrkQ_ModifiedBy_JUser_ID     : ansistring;
  JWrkQ_Modified_DT             : ansistring;
  JWrkQ_DeletedBy_JUser_ID      : ansistring;
  JWrkQ_Deleted_DT              : ansistring;
  JWrkQ_Deleted_b               : ansistring;
  JAS_Row_b                     : ansistring;
end;
procedure clear_JWorkQueue(var p_rJWorkQueue: rtJWorkQueue);
//=============================================================================













//=============================================================================
// Global Arrays used by JAS to hold Dynamic config info in mem
//=============================================================================
var
  garJAliasLight: array of rtJAliasLight;
  garJIPListLight: array of rtJIPListLight;
  garJVHostLight: array of rtJVHostLight;
  garJMimeLight: array of rtJMimeLight;
  garJIndexFileLight: array of rtJIndexfileLight;// done
  garJLanguageLight: array of rtJLanguageLight; // done    
  garJThemeColorLight: array of rtJThemeColorLight;  // DONE
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
	  saFieldName_CreatedBy_JUser_ID          :=p_saColumnPrefix+'_CreatedBy_JUser_ID';
	  saFieldName_Created_DT                  :=p_saColumnPrefix+'_Created_DT';
	  saFieldName_ModifiedBy_JUser_ID         :=p_saColumnPrefix+'_ModifiedBy_JUser_ID';
	  saFieldName_Modified_DT                 :=p_saColumnPrefix+'_Modified_DT';
	  saFieldName_DeletedBy_JUser_ID          :=p_saColumnPrefix+'_DeletedBy_JUser_ID';
	  saFieldName_Deleted_DT                  :=p_saColumnPrefix+'_Deleted_DT';
	  saFieldName_Deleted_b                   :=p_saColumnPrefix+'_Deleted_b';
    bUse_CreatedBy_JUser_ID                 :=false;
    bUse_Created_DT                         :=false;
    bUse_ModifiedBy_JUser_ID                :=false;
    bUse_Modified_DT                        :=false;
    bUse_DeletedBy_JUser_ID                 :=false;
    bUse_Deleted_DT                         :=false;
    bUse_Deleted_b                          :=false;
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
    JADB_JADODBMS_UID                 :='';
    JADB_Name                         :='';
    JADB_CreatedBy_JUser_ID           :='';
    JADB_Created_DT                   :='';
    JADB_ModifiedBy_JUser_ID          :='';
    JADB_Modified_DT                  :='';
    JADB_DeletedBy_JUser_ID           :='';
    JADB_Deleted_DT                   :='';
    JADB_Deleted_b                    :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JADODriver(var p_rJADODriver: rtJADODriver);
//=============================================================================
begin
  with p_rJADODriver do begin
    JADV_JADODriver_UID               :='';
    JADV_Name                         :='';
    JADV_CreatedBy_JUser_ID           :='';
    JADV_Created_DT                   :='';
    JADV_ModifiedBy_JUser_ID          :='';
    JADV_Modified_DT                  :='';
    JADV_DeletedBy_JUser_ID           :='';
    JADV_Deleted_DT                   :='';
    JADV_Deleted_b                    :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JBlok(var p_rJBlok: rtJBlok);
//=============================================================================
begin
  with p_rJBlok do begin
    JBlok_JBlok_UID                   :='';
    JBlok_JScreen_ID                  :='';
    JBlok_JTable_ID                   :='';
    JBlok_Name                        :='';
    JBlok_Columns_u                   :='';
	  JBlok_JBlokType_ID                :='';
	  JBlok_Custom                      :='';
	  JBlok_JCaption_ID                 :='';
	  JBlok_IconSmall                   :='';
	  JBlok_IconLarge                   :='';
    JBlok_Position_u                  :='';
    JBlok_Help_ID                     :='';
    JBlok_CreatedBy_JUser_ID          :='';
	  JBlok_Created_DT                  :='';
	  JBlok_ModifiedBy_JUser_ID         :='';
	  JBlok_Modified_DT                 :='';
	  JBlok_DeletedBy_JUser_ID          :='';
	  JBlok_Deleted_DT                  :='';
	  JBlok_Deleted_b                   :='';
	end;//with
End;
//=============================================================================

//=============================================================================
procedure clear_JBlokButton(var p_rJBlokButton: rtJBlokButton);
//=============================================================================
begin
  with p_rJBlokButton do begin
	  JBlkB_JBlokButton_UID             :='';
	  JBlkB_JBlok_ID                    :='';
	  JBlkB_JCaption_ID                 :='';
	  JBlkB_Name                        :='';
	  JBlkB_GraphicFileName             :='';
	  JBlkB_Position_u                  :='';
	  JBlkB_JButtonType_ID              :='';
	  JBlkB_CustomURL                   :='';
	  JBlkB_CreatedBy_JUser_ID          :='';
	  JBlkB_Created_DT                  :='';
	  JBlkB_ModifiedBy_JUser_ID         :='';
	  JBlkB_Modified_DT                 :='';
	  JBlkB_DeletedBy_JUser_ID          :='';
	  JBlkB_Deleted_DT                  :='';
	  JBlkB_Deleted_b                   :='';
	end;
End;
//=============================================================================

//=============================================================================
procedure clear_JBlokField(var p_rJBlokField: rtJBlokField);
//=============================================================================
begin
  with p_rJBlokField do begin
	  JBlkF_JBlokField_UID              :='';
	  JBlkF_JBlok_ID                    :='';
	  JBlkF_JColumn_ID                  :='';
	  JBlkF_Position_u                  :='';
	  JBlkF_ReadOnly_b                  :='';
	  JBlkF_JWidget_ID                  :='';
	  JBlkF_Widget_MaxLength_u          :='';
	  JBlkF_Widget_Width                :='';
	  JBlkF_Widget_Height               :='';
	  JBlkF_Widget_Password_b           :='';
	  JBlkF_Widget_Date_b               :='';
	  JBlkF_Widget_Time_b               :='';
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
	  JBlkF_ColSpan_u                   :='';
	  JBlkF_ClickAction_ID              :='';
	  JBlkF_ClickActionData             :='';
	  JBlkF_JCaption_ID                 :='';
	  JBlkF_Visible_b                   :='';
	  JBlkF_CreatedBy_JUser_ID          :='';
	  JBlkF_Created_DT                  :='';
	  JBlkF_ModifiedBy_JUser_ID         :='';
	  JBlkF_Modified_DT                 :='';
	  JBlkF_DeletedBy_JUser_ID          :='';
	  JBlkF_Deleted_DT                  :='';
	  JBlkF_Deleted_b                   :='';
	  JBlkF_Width_is_Percent_b          :='';
	  JBlkF_Height_is_Percent_b         :='';
    JBlkF_MultiSelect_b               :='';
    JBlkF_Required_b                  :='';
	end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JBlokType(var p_rJBlokType: rtJBlokType);
//=============================================================================
begin
  with p_rJBlokType do begin
    JBkTy_JBlokType_UID               :='';
    JBkTy_Name                        :='';
    JBkTy_CreatedBy_JUser_ID          :='';
    JBkTy_Created_DT                  :='';
    JBkTy_ModifiedBy_JUser_ID         :='';
    JBkTy_Modified_DT                 :='';
    JBkTy_DeletedBy_JUser_ID          :='';
    JBkTy_Deleted_DT                  :='';
    JBkTy_Deleted_b                   :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JButtonType(var p_rJButtonType: rtJButtonType);
//=============================================================================
begin
  with p_rJButtonType do begin
    JBtnT_JButtonType_UID       :='';
    JBtnT_Name                  :='';
    JBtnT_CreatedBy_JUser_ID    :='';
    JBtnT_Created_DT            :='';
    JBtnT_ModifiedBy_JUser_ID   :='';
    JBtnT_Modified_DT           :='';
    JBtnT_DeletedBy_JUser_ID    :='';
    JBtnT_Deleted_DT            :='';
    JBtnT_Deleted_b             :='';
    JAS_Row_b                   :='';
	end;
End;
//=============================================================================



//=============================================================================
procedure clear_JCaption(var p_rJCaption: rtJCaption);
//=============================================================================
begin
  with p_rJCaption do begin
    JCapt_JCaption_UID          :='';
    JCapt_Orphan_b              :='';
    JCapt_Value                 :='';
    JCapt_en                    :='';
    JCapt_CreatedBy_JUser_ID    :='';
    JCapt_Created_DT            :='';
    JCapt_ModifiedBy_JUser_ID   :='';
    JCapt_Modified_DT           :='';
    JCapt_DeletedBy_JUser_ID    :='';
    JCapt_Deleted_DT            :='';
    JCapt_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JCase(var p_rJCase: rtJCase);
//=============================================================================
begin
  with p_rJCase do begin
    JCase_JCase_UID                 :='';
    JCase_Name                      :='';
    JCase_JCompany_ID               :='';
    JCase_JPerson_ID                :='';
    JCase_Responsible_Grp_ID        :='';
    JCase_Responsible_Person_ID     :='';
    JCase_JCaseSource_ID            :='';
    JCase_JCaseCategory_ID          :='';
    JCase_JCasePriority_ID          :='';
    JCase_JCaseStatus_ID            :='';
    JCase_JCaseType_ID              :='';
    JCase_JSubject_ID               :='';
    JCase_Desc                      :='';
    JCase_Resolution                :='';
    JCase_Due_DT                    :='';
    JCase_ResolvedBy_JUser_ID       :='';
    JCase_Resolved_DT               :='';
    JCase_CreatedBy_JUser_ID        :='';
    JCase_Created_DT                :='';
    JCase_ModifiedBy_JUser_ID       :='';
    JCase_Modified_DT               :='';
    JCase_DeletedBy_JUser_ID        :='';
    JCase_Deleted_DT                :='';
    JCase_Deleted_b                 :='';
    JAS_Row_b                       :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseCategory(var p_rJCaseCategory: rtJCaseCategory);
//=============================================================================
begin
  with p_rJCaseCategory do begin
    JCACT_JCaseCategory_UID           :='';
    JCACT_Name                        :='';
    JCACT_CreatedBy_JUser_ID          :='';
    JCACT_Created_DT                  :='';
    JCACT_ModifiedBy_JUser_ID         :='';
    JCACT_Modified_DT                 :='';
    JCACT_DeletedBy_JUser_ID          :='';
    JCACT_Deleted_DT                  :='';
    JCACT_Deleted_b                   :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCasePriority(var p_rJCasePriority: rtJCasePriority);
//=============================================================================
begin
  with p_rJCasePriority do begin
    JCAPR_JCasePriority_UID           :='';
    JCAPR_Name                        :='';
    JCAPR_CreatedBy_JUser_ID          :='';
    JCAPR_Created_DT                  :='';
    JCAPR_ModifiedBy_JUser_ID         :='';
    JCAPR_Modified_DT                 :='';
    JCAPR_DeletedBy_JUser_ID          :='';
    JCAPR_Deleted_DT                  :='';
    JCAPR_Deleted_b                   :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseSource(var p_rJCaseSource: rtJCaseSource);
//=============================================================================
begin
  with p_rJCaseSource do begin
    JCASR_JCaseSource_UID     :='';
    JCASR_Name                :='';
    JCASR_CreatedBy_JUser_ID  :='';
    JCASR_Created_DT          :='';
    JCASR_ModifiedBy_JUser_ID :='';
    JCASR_Modified_DT         :='';
    JCASR_DeletedBy_JUser_ID  :='';
    JCASR_Deleted_DT          :='';
    JCASR_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseSubject(var p_rJCaseSubject: rtJCaseSubject);
//=============================================================================
begin
  with p_rJCaseSubject do begin
    JCASB_JCaseSubject_UID    :='';
    JCASB_Name                :='';
    JCASB_CreatedBy_JUser_ID  :='';
    JCASB_Created_DT          :='';
    JCASB_ModifiedBy_JUser_ID :='';
    JCASB_Modified_DT         :='';
    JCASB_DeletedBy_JUser_ID  :='';
    JCASB_Deleted_DT          :='';
    JCASB_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JCaseType(var p_rJCaseType: rtJCaseType);
//=============================================================================
begin
  with p_rJCaseType do begin
    JCATY_JCaseType_UID       :='';
    JCATY_Name                :='';
    JCATY_CreatedBy_JUser_ID  :='';
    JCATY_Created_DT          :='';
    JCATY_ModifiedBy_JUser_ID :='';
    JCATY_Modified_DT         :='';
    JCATY_DeletedBy_JUser_ID  :='';
    JCATY_Deleted_DT          :='';
    JCATY_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JColumn(var p_rJColumn: rtJColumn);
//=============================================================================
begin
  with p_rJColumn do begin
    JColu_JColumn_UID             :='';
    JColu_Name                    :='';
    JColu_JTable_ID               :='';
    JColu_JDType_ID               :='';
    JColu_AllowNulls_b            :='';
    JColu_DefaultValue            :='';
    JColu_PrimaryKey_b            :='';
    JColu_JAS_b                   :='';
    JColu_JCaption_ID             :='';
    JColu_DefinedSize_u           :='';
    JColu_NumericScale_u          :='';
    JColu_Precision_u             :='';
    JColu_Boolean_b               :='';
    JColu_JAS_Key_b               :='';
    JColu_AutoIncrement_b         :='';
    JColu_LUF_Value               :='';
    JColu_LD_CaptionRules_b       :='';
    JColu_JDConnection_ID         :='';
    JColu_Desc                    :='';
    JColu_Weight_u                :='';
    JColu_LD_SQL                  :='';
    JColu_LU_JColumn_ID           :='';
    JColu_CreatedBy_JUser_ID      :='';
    JColu_Created_DT              :='';
    JColu_ModifiedBy_JUser_ID     :='';
    JColu_Modified_DT             :='';
    JColu_DeletedBy_JUser_ID      :='';
    JColu_Deleted_DT              :='';
    JColu_Deleted_b               :='';
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
//    JCCLi_JCompany_ID           :='';
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
procedure clear_JCompany(var p_rJCompany: rtJCompany);
//=============================================================================
begin
  with p_rJCompany do begin
    JComp_JCompany_UID           :='';
    JComp_Name                   :='';
    JComp_Primary_Person_ID      :='';
    JComp_Phone                  :='';
    JComp_Fax                    :='';
    JComp_Email                  :='';
    JComp_Website                :='';
    JComp_Parent_ID              :='';
    JComp_Owner_JUser_ID         :='';
    JComp_Desc                   :='';
    JComp_Main_Addr1             :='';
    JComp_Main_Addr2             :='';
    JComp_Main_Addr3             :='';
    JComp_Main_City              :='';
    JComp_Main_State             :='';
    JComp_Main_PostalCode        :='';
    JComp_Main_Country           :='';
    JComp_Ship_Addr1             :='';
    JComp_Ship_Addr2             :='';
    JComp_Ship_Addr3             :='';
    JComp_Ship_City              :='';
    JComp_Ship_State             :='';
    JComp_Ship_PostalCode        :='';
    JComp_Ship_Country           :='';
    JComp_Main_Longitude_d       :='';
    JComp_Main_Latitude_d        :='';
    JComp_Ship_Longitude_d       :='';
    JComp_Ship_Latitude_d        :='';
    JComp_Customer_b             :='';
    JComp_Vendor_b               :='';
    JComp_CreatedBy_JUser_ID     :='';
    JComp_Created_DT             :='';
    JComp_ModifiedBy_JUser_ID    :='';
    JComp_Modified_DT            :='';
    JComp_DeletedBy_JUser_ID     :='';
    JComp_Deleted_DT             :='';
    JComp_Deleted_b              :='';
    JAS_Row_b                    :='';
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JCompanyPers(var p_rJCompanyPers: rtJCompanyPers);
//=============================================================================
begin
  with p_rJCompanyPers do begin
    JCpyP_JCompanyPers_UID    :='';
    JCpyP_JCompany_ID         :='';
    JCpyP_JPerson_ID          :='';
    JCpyP_DepartmentLU_ID     :='';
    JCpyP_Title               :='';
    JCpyP_ReportsTo_Person_ID :='';
    JCpyP_CreatedBy_JUser_ID  :='';
    JCpyP_Created_DT          :='';
    JCpyP_ModifiedBy_JUser_ID :='';
    JCpyP_Modified_DT         :='';
    JCpyP_DeletedBy_JUser_ID  :='';
    JCpyP_Deleted_DT          :='';
    JCpyP_Deleted_b           :='';
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
    JDCon_DSN_FileBased_b                   :='';
    JDCon_DSN_Filename                      :='';
    JDCon_Enabled_b                         :='';
    JDCon_DBMS_ID                           :='';
    JDCon_Driver_ID                         :='';
    JDCon_Username                          :='';
    JDCon_Password                          :='';
    JDCon_ODBC_Driver                       :='';
    JDCon_Server                            :='';
    JDCon_Database                          :='';
    JDCon_JSecPerm_ID                       :='';
    JDCon_CreatedBy_JUser_ID                :='';
    JDCon_Created_DT                        :='';
    JDCon_ModifiedBy_JUser_ID               :='';
    JDCon_Modified_DT                       :='';
    JDCon_DeletedBy_JUser_ID                :='';
    JDCon_Deleted_DT                        :='';
    JDCon_Deleted_b                         :='';
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JDebug(var p_rJDebug: rtJDebug);
//=============================================================================
begin
  with p_rJDebug do begin
    JDBug_JDebug_UID               :='';
    JDBug_Code_u                   :='';
    JDBug_Message                  :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JDType(var p_rJDType: rtJDType);
//=============================================================================
begin
  with p_rJDType do begin
    JDTyp_JDType_UID               :='';
    JDTyp_Desc                     :='';
    JDTyp_Notation                 :='';
    JDTyp_CreatedBy_JUser_ID       :='';
    JDTyp_Created_DT               :='';
    JDTyp_ModifiedBy_JUser_ID      :='';
    JDTyp_Modified_DT              :='';
    JDTyp_DeletedBy_JUser_ID       :='';
    JDTyp_Deleted_DT               :='';
    JDTyp_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JFile(var p_rJFile: rtJFile);
//=============================================================================
begin
  with  p_rJFile do begin
    JFile_JFile_UID                :='';
    JFile_en                       :='';
    JFile_Name                     :='';
    JFile_Path                     :='';
    JFile_JTable_ID                :='';
    JFile_JColumn_ID               :='';
    JFile_Row_ID                   :='';
    JFile_Orphan_b                 :='';
    JFile_JSecPerm_ID              :='';
    JFile_FileSize_u               :='';
    JFile_CreatedBy_JUser_ID       :='';
    JFile_Created_DT               :='';
    JFile_ModifiedBy_JUser_ID      :='';
    JFile_Modified_DT              :='';
    JFile_DeletedBy_JUser_ID       :='';
    JFile_Deleted_DT               :='';
    JFile_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;







//=============================================================================
procedure clear_JFilterSave(var p_rJFilterSave: rtJFilterSave);
//=============================================================================
begin
  with p_rJFilterSave do begin
    JFtSa_JFilterSave_UID          :='';
    JFtSa_Name                     :='';
    JFtSa_JBlok_ID                 :='';
    JFtSa_Public_b                 :='';
    JFTSa_XML                      :='';
    JFtSa_CreatedBy_JUser_ID       :='';
    JFtSa_Created_DT               :='';
    JFtSa_ModifiedBy_JUser_ID      :='';
    JFtSa_Modified_DT              :='';
    JFtSa_DeletedBy_JUser_ID       :='';
    JFtSa_Deleted_DT               :='';
    JFtSa_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JFilterSaveDef(var p_rJFilterSaveDef: rtJFilterSaveDef);
//=============================================================================
begin
  with p_rJFilterSaveDef do begin
    JFtSD_JFilterSaveDef_UID       :='';
    JFtSD_JBlok_ID                 :='';
    JFtSD_JFilterSave_ID           :='';
    JFtSD_CreatedBy_JUser_ID       :='';
    JFtSD_Created_DT               :='';
    JFtSD_ModifiedBy_JUser_ID      :='';
    JFtSD_Modified_DT              :='';
    JFtSD_DeletedBy_JUser_ID       :='';
    JFtSD_Deleted_DT               :='';
    JFtSD_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;
end;
//=============================================================================




//=============================================================================
procedure clear_JHelp(p_rJHelp: rtJHelp);
//=============================================================================
begin
  with p_rJHelp do begin
    Help_JHelp_UID            :='';
    Help_VideoMP4_en          :='';
    Help_HTML_en              :='';
    Help_HTML_Adv_en          :='';
    Help_Name                 :='';
    Help_Poster               :='';
    Help_CreatedBy_JUser_ID   :='';
    Help_Created_DT           :='';
    Help_ModifiedBy_JUser_ID  :='';
    Help_Modified_DT          :='';
    Help_DeletedBy_JUser_ID   :='';
    Help_Deleted_DT           :='';
    Help_Deleted_b            :='';
    JAS_Row_b                 :='';
  end;
end;
//=============================================================================




//=============================================================================
procedure clear_JIndustry(var p_rJIndustry: rtJIndustry);
//=============================================================================
begin
  with p_rJIndustry do begin
    JIndu_JIndustry_UID            :='';
    JIndu_Name                     :='';
    JIndu_CreatedBy_JUser_ID       :='';
    JIndu_Created_DT               :='';
    JIndu_ModifiedBy_JUser_ID      :='';
    JIndu_Modified_DT              :='';
    JIndu_DeletedBy_JUser_ID       :='';
    JIndu_Deleted_DT               :='';
    JIndu_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInstalled(var p_rJInstalled: rtJInstalled);
//=============================================================================
begin
  with p_rJInstalled do begin
    JInst_JInstalled_UID           :='';
    JInst_JModule_ID               :='';
    JInst_Name                     :='';
    JInst_Desc                     :='';
    JInst_JNote_ID                :='';
    JInst_Enabled_b                :='';
    JInst_CreatedBy_JUser_ID       :='';
    JInst_Created_DT               :='';
    JInst_ModifiedBy_JUser_ID      :='';
    JInst_Modified_DT              :='';
    JInst_DeletedBy_JUser_ID       :='';
    JInst_Deleted_DT               :='';
    JInst_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInterface(var p_rJInterface: rtJInterface);
//=============================================================================
begin
  with p_rJInterface do begin
    JIntF_JInterface_UID           :='';
    JIntF_Name                     :='';
    JIntF_Desc                     :='';
    JIntF_CreatedBy_JUser_ID       :='';
    JIntF_Created_DT               :='';
    JIntF_ModifiedBy_JUser_ID      :='';
    JIntF_Modified_DT              :='';
    JIntF_DeletedBy_JUser_ID       :='';
    JIntF_Deleted_DT               :='';
    JIntF_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInvoice(var p_rJInvoice: rtJInvoice);
//=============================================================================
begin
  with p_rJInvoice do begin
    JIHdr_JInvoice_UID         :='';
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
    JIHdr_SalesAmt_d           :='';
    JIHdr_MiscAmt_d            :='';
    JIHdr_SalesTaxAmt_d        :='';
    JIHdr_ShipAmt_d            :='';
    JIHdr_TotalAmt_d           :='';
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
    JIHDr_JCompany_ID          :='';
    JIHDr_JPerson_ID           :='';
    JIHdr_CreatedBy_JUser_ID   :='';
    JIHdr_Created_DT           :='';
    JIHdr_ModifiedBy_JUser_ID  :='';
    JIHdr_Modified_DT          :='';
    JIHdr_DeletedBy_JUser_ID   :='';
    JIHdr_Deleted_DT           :='';
    JIHdr_Deleted_b            :='';
    JAS_Row_b                  :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JInvoiceLines(var p_rJInvoiceLines: rtJInvoiceLines);
//=============================================================================
begin
  with p_rJInvoiceLines do begin
    JILin_JInvoiceLines_UID    :='';
    JILin_JInvoice_ID          :='';
    JILin_ProdNoInternal       :='';
    JILin_ProdNoCust           :='';
    JILin_JProduct_ID          :='';
    JILin_QtyOrd_d             :='';
    JILin_DescA                :='';
    JILin_DescB                :='';
    JILin_QtyShip_d            :='';
    JILin_PrcUnit_d            :='';
    JILin_PrcExt_d             :='';
    JILin_SEQ_u                :='';
    JILin_CreatedBy_JUser_ID   :='';
    JILin_Created_DT           :='';
    JILin_ModifiedBy_JUser_ID  :='';
    JILin_Modified_DT          :='';
    JILin_DeletedBy_JUser_ID   :='';
    JILin_Deleted_DT           :='';
    JILin_Deleted_b            :='';
    JAS_Row_b                  :='';
  end;//with
end;
//=============================================================================






//=============================================================================
procedure clear_JJobQ(var p_rJJobQ: rtJJobQ);
//=============================================================================
begin
  with p_rJJobQ do begin
    JJobQ_JJobQ_UID           :='';
    JJobQ_JUser_ID            :='';
    JJobQ_JJobType_ID         :='';
    JJobQ_Start_DT            :='';
    JJobQ_ErrorNo_u           :='';
    JJobQ_Started_DT          :='';
    JJobQ_Running_b           :='';
    JJobQ_Finished_DT         :='';
    JJobQ_Name                :='';
    JJobQ_Repeat_b            :='';
    JJobQ_RepeatMinute        :='';
    JJobQ_RepeatHour          :='';
    JJobQ_RepeatDayOfMonth    :='';
    JJobQ_RepeatMonth         :='';
    JJobQ_Completed_b         :='';
    JJobQ_Result_URL          :='';
    JJobQ_ErrorMsg            :='';
    JJobQ_ErrorMoreInfo       :='';
    JJobQ_Enabled_b           :='';
    JJobQ_Job                 :='';
    JJobQ_Result              :='';
    JJobQ_CreatedBy_JUser_ID  :='';
    JJobQ_Created_DT          :='';
    JJobQ_ModifiedBy_JUser_ID :='';
    JJobQ_Modified_DT         :='';
    JJobQ_DeletedBy_JUser_ID  :='';
    JJobQ_Deleted_DT          :='';
    JJobQ_Deleted_b           :='';
    JAS_Row_b                 :='';
    JJobQ_JTask_ID            :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JLanguage(var p_rJLanguage: rtJLanguage);
//=============================================================================
begin
  with p_rJLanguage do begin
 	  JLang_JLanguage_UID        :='';
 	  JLang_Name                 :='';
 	  JLang_NativeName           :='';
    JLang_Code                 :='';
 	  JLang_CreatedBy_JUser_ID   :='';
 	  JLang_Created_DT           :='';
 	  JLang_ModifiedBy_JUser_ID  :='';
 	  JLang_Modified_DT          :='';
 	  JLang_DeletedBy_JUser_ID   :='';
 	  JLang_Deleted_DT           :='';
    JLang_Deleted_b            :='';
 	  JAS_Row_b                  :='';
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
    JLead_JLead_UID           :='';
    JLead_JLeadSource_ID      :='';
    JLead_Owner_JUser_ID      :='';
    JLead_Private_b           :='';
    JLead_CompanyName         :='';
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
    JLead_Exist_JCompany_ID   :='';
    JLead_Exist_JPerson_ID    :='';
    JLead_LeadSourceAddl      :='';
    JLead_CreatedBy_JUser_ID  :='';
    JLead_Created_DT          :='';
    JLead_ModifiedBy_JUser_ID :='';
    JLead_Modified_DT         :='';
    JLead_DeletedBy_JUser_ID  :='';
    JLead_Deleted_DT          :='';
    JLead_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLeadSource(var p_rJLeadSource: rtJLeadSource);
//=============================================================================
begin
  with p_rJLeadSource do begin
    JLDSR_JLeadSource_UID     :='';
    JLDSR_Name                :='';
    JLDSR_CreatedBy_JUser_ID  :='';
    JLDSR_Created_DT          :='';
    JLDSR_ModifiedBy_JUser_ID :='';
    JLDSR_Modified_DT         :='';
    JLDSR_DeletedBy_JUser_ID  :='';
    JLDSR_Deleted_DT          :='';
    JLDSR_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLock(var p_rJLock: rtJLock);
//=============================================================================
begin
  with p_rJLock do begin
    JLock_JLock_UID           :='';
    JLock_JSession_ID         :='';
    JLock_JDConnection_ID     :='';
    JLock_Locked_DT           :='';
    JLock_Table_ID            :='';
    JLock_Row_ID              :='';
    JLock_Col_ID              :='';
    JLock_Username            :='';
    JLock_CreatedBy_JUser_ID  :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLog(var p_rJLog: rtJLog);
//=============================================================================
begin
  with p_rJLog do begin
    JLOG_JLog_UID              :='';
    JLOG_DateNTime_dt          :='';
    JLOG_JLogType_ID           :='';
    JLOG_Entry_ID              :='';
    JLOG_EntryData_s           :='';
    JLOG_SourceFile_s          :='';
    JLOG_User_ID               :='';
    JLOG_CmdLine_s             :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JLookup(var p_rJLookup: rtJLookup);
//=============================================================================
begin
  with p_rJLookup do begin
    JLook_JLookup_UID         :='';
    JLook_Name                :='';
    JLook_Value               :='';
    JLook_Position_u          :='';
    JLook_en                  :='';
    JLook_Created_DT          :='';
    JLook_ModifiedBy_JUser_ID :='';
    JLook_Modified_DT         :='';
    JLook_DeletedBy_JUser_ID  :='';
    JLook_Deleted_DT          :='';
    JLook_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JMail(var p_rJMail: rtJMail);
//=============================================================================
begin
  with p_rJMail do begin
    JMail_JMail_UID             := '';
    JMail_Message               := '';
    JMail_To_User_ID            := '';
    JMail_From_User_ID          := '';
    JMail_Message               := '';
    JMail_Message_Code          := '';
    JMail_CreatedBy_JUser_ID    := '';
    JMail_Created_DT            := '';
    JMail_ModifiedBy_JUser_ID   := '';
    JMail_Modified_DT           := '';
    JMail_DeletedBy_JUser_ID    := '';
    JMail_Deleted_DT            := '';
    JMail_Deleted_b             := ''; 
    JAS_Row_b                   := '';
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
    JMenu_JSecPerm_ID                 :='';
    JMenu_Name_en                     :='';
    JMenu_URL                         :='';
    JMenu_NewWindow_b                 :='';
    JMenu_IconSmall                   :='';
    JMenu_IconLarge                   :='';
    JMenu_ValidSessionOnly_b          :='';
    JMenu_SEQ_u                       :='';
    JMenu_DisplayIfNoAccess_b         :='';
    JMenu_DisplayIfValidSession_b     :='';
    JMenu_IconLarge_Theme_b           :='';
    JMenu_IconSmall_Theme_b           :='';
    JMenu_ReadMore_b                  :='';
    JMenu_Title_en                    :='';
    JMenu_Data_en                     :='';
    JMenu_CreatedBy_JUser_ID          :='';
    JMenu_Created_DT                  :='';
    JMenu_ModifiedBy_JUser_ID         :='';
    JMenu_Modified_DT                 :='';
    JMenu_DeletedBy_JUser_ID          :='';
    JMenu_Deleted_DT                  :='';
    JMenu_Deleted_b                   :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModC(var p_rJModC: rtJModC);
//=============================================================================
begin
  with p_rJModC do begin
    JModC_JModC_UID           :='';
    JModC_JInstalled_ID       :='';
    JModC_Column_ID           :='';
    JModC_Row_ID              :='';
    JModC_CreatedBy_JUser_ID  :='';
    JModC_Created_DT          :='';
    JModC_ModifiedBy_JUser_ID :='';
    JModC_Modified_DT         :='';
    JModC_DeletedBy_JUser_ID  :='';
    JModC_Deleted_DT          :='';
    JModC_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModule(var p_rJModule: rtJModule);
//=============================================================================
begin
  with p_rJModule do begin
    JModu_JModule_UID         :='';
    JModu_Name                :='';
    JModu_Version_Major_u     :='';
    JModu_Version_Minor_u     :='';
    JModu_Version_Revision_u  :='';
    JModu_CreatedBy_JUser_ID  :='';
    JModu_Created_DT          :='';
    JModu_ModifiedBy_JUser_ID :='';
    JModu_Modified_DT         :='';
    JModu_DeletedBy_JUser_ID  :='';
    JModu_Deleted_DT          :='';
    JModu_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModuleConfig(var p_rJModuleConfig: rtJModuleConfig);
//=============================================================================
begin
  with p_rJModuleConfig do begin
    JMCfg_JModuleConfig_UID   :='';
    JMCfg_JModuleSetting_ID   :='';
    JMCfg_Value               :='';
    JMCfg_JNote_ID           :='';
    JMCfg_JInstalled_ID       :='';
    JMCfg_JUser_ID            :='';
    JMCfg_Read_JSecPerm_ID    :='';
    JMCfg_Write_JSecPerm_ID   :='';
    JMCfg_CreatedBy_JUser_ID  :='';
    JMCfg_Created_DT          :='';
    JMCfg_ModifiedBy_JUser_ID :='';
    JMCfg_Modified_DT         :='';
    JMCfg_DeletedBy_JUser_ID  :='';
    JMCfg_Deleted_DT          :='';
    JMCfg_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JModuleSetting(var p_rJModuleSetting: rtJModuleSetting);
//=============================================================================
begin
  with p_rJModuleSetting do begin
    JMSet_JModuleSetting_UID  :='';
    JMSet_Name                :='';
    JMSet_JCaption_ID         :='';
    JMSet_JNote_ID           :='';
    JMSet_JModule_ID          :='';
    JMSet_CreatedBy_JUser_ID  :='';
    JMSet_Created_DT          :='';
    JMSet_ModifiedBy_JUser_ID :='';
    JMSet_Modified_DT         :='';
    JMSet_DeletedBy_JUser_ID  :='';
    JMSet_Deleted_DT          :='';
    JMSet_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JNote(var p_rJNote: rtJNote);
//=============================================================================
begin
  with p_rJNote do begin
    JNote_JNote_UID           :='';
    JNote_JTable_ID           :='';
    JNote_JColumn_ID          :='';
    JNote_Row_ID              :='';
    JNote_Orphan_b            :='';
    JNote_en                  :='';
    JNote_Created_DT          :='';
    JNote_CreatedBy_JUser_ID  :='';
    JNote_Modified_DT         :='';
    JNote_ModifiedBy_JUser_ID :='';
    JNote_DeletedBy_JUser_ID  :='';
    JNote_Deleted_DT          :='';
    JNote_Deleted_b           :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JPassword(var p_rJPassword: rtJPassword);
//=============================================================================
begin
  with p_rJPassword do begin
    JPass_JPassword_UID         :='';
    JPass_Name                  :='';
    JPass_Desc                  :='';
    JPass_URL                   :='';
    JPass_Owner_JUser_ID        :='';
    JPass_Private_Memo          :='';
    JPass_JSecPerm_ID           :='';
    JPass_CreatedBy_JUser_ID    :='';
    JPass_Created_DT            :='';
    JPass_ModifiedBy_JUser_ID   :='';
    JPass_Modified_DT           :='';
    JPass_DeletedBy_JUser_ID    :='';
    JPass_Deleted_DT            :='';
    JPass_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JPerson(var p_rJPerson: rtJPerson);
//=============================================================================
begin
  with p_rJPerson do begin
    JPers_JPerson_UID                 :='';
    JPers_Desc                        :='';
    JPers_NameSalutation              :='';
    JPers_NameFirst                   :='';
    JPers_NameMiddle                  :='';
    JPers_NameLast                    :='';
    JPers_NameSuffix                  :='';
    JPers_NameDear                    :='';
    JPers_Gender                      :='';
    JPers_Private_b                   :='';
    JPers_Addr1                       :='';
    JPers_Addr2                       :='';
    JPers_Addr3                       :='';
    JPers_City                        :='';
    JPers_State                       :='';
    JPers_PostalCode                  :='';
    JPers_Country                     :='';
    JPers_Home_Email                  :='';
    JPers_Home_Phone                  :='';
    JPers_Latitude_d                  :='';
    JPers_Longitude_d                 :='';
    JPers_Mobile_Phone                :='';
    JPers_Private_b                   :='';
    JPers_Work_Email                  :='';
    JPers_Work_Phone                  :='';
    JPers_Customer_b                  :='';
    JPers_Vendor_b                    :='';
    JPers_Primary_Company_ID          :='';
    JPers_DOB_DT                      :='';
    JPers_CC                          :='';
    JPers_CCExpire                    :='';
    JPers_CCSecCode                   :='';
    JPers_CreatedBy_JUser_ID          :='';
    JPers_Created_DT                  :='';
    JPers_ModifiedBy_JUser_ID         :='';
    JPers_Modified_DT                 :='';
    JPers_DeletedBy_JUser_ID          :='';
    JPers_Deleted_DT                  :='';
    JPers_Deleted_b                   :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JPriority(var p_rJPriority: rtJPriority);
//=============================================================================
begin
  with p_rJPriority do begin
    JPrio_JPriority_UID   :='';
    JPrio_en                  :='';
    JPrio_CreatedBy_JUser_ID  :='';
    JPrio_Created_DT          :='';
    JPrio_ModifiedBy_JUser_ID :='';
    JPrio_Modified_DT         :='';
    JPrio_DeletedBy_JUser_ID  :='';
    JPrio_Deleted_DT          :='';
    JPrio_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================




//=============================================================================
procedure clear_JProduct(var p_rJProduct: rtJProduct);
//=============================================================================
begin
  with p_rJProduct do begin
    JProd_JProduct_UID          :='';
    JProd_Number                :='';
    JProd_Name                  :='';
    JProd_Desc                  :='';
    JProd_CreatedBy_JUser_ID    :='';
    JProd_Created_DT            :='';
    JProd_ModifiedBy_JUser_ID   :='';
    JProd_Modified_DT           :='';
    JProd_DeletedBy_JUser_ID    :='';
    JProd_Deleted_DT            :='';
    JProd_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProductGrp(var p_rJProductGrp: rtJProductGrp);
//=============================================================================
begin
  with p_rJProductGrp do begin
    JPrdG_JProductGrp_UID     :='';
    JPrdG_Name                :='';
    JPrdG_Desc                :='';
    JPrdG_CreatedBy_JUser_ID  :='';
    JPrdG_Created_DT          :='';
    JPrdG_ModifiedBy_JUser_ID :='';
    JPrdG_Modified_DT         :='';
    JPrdG_DeletedBy_JUser_ID  :='';
    JPrdG_Deleted_DT          :='';
    JPrdG_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProductQty(var p_rJProductQty: rtJProductQty);
//=============================================================================
begin
  with p_rJProductQty do begin
    JPrdQ_JProductQty_UID     :='';
    JPrdQ_Location_JCompany_ID:='';
    JPrdQ_QtyOnHand_d         :='';
    JPrdQ_QtyOnOrder_d        :='';
    JPrdQ_QtyOnBackOrder_d    :='';
    JPrdQ_JProduct_ID         :='';
    JPrdQ_CreatedBy_JUser_ID  :='';
    JPrdQ_Created_DT          :='';
    JPrdQ_ModifiedBy_JUser_ID :='';
    JPrdQ_Modified_DT         :='';
    JPrdQ_DeletedBy_JUser_ID  :='';
    JPrdQ_Deleted_DT          :='';
    JPrdQ_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProject(var p_rJProject: rtJProject);
//=============================================================================
begin
  with p_rJProject do begin
    JProj_JProject_UID          :='';
    JProj_Name                  :='';
    JProj_Owner_JUser_ID        :='';
    JProj_URL                   :='';
    JProj_URL_Stage             :='';
    JProj_JProjectStatus_ID     :='';
    JProj_JProjectPriority_ID   :='';
    JProj_JProjectCategory_ID   :='';
    JProj_Progress_PCT_d        :='';
    JProj_Hours_Worked_d        :='';
    JProj_Hours_Sched_d         :='';
    JProj_Hours_Project_d       :='';
    JProj_Desc                  :='';
    JProj_Start_DT              :='';
    JProj_Target_End_DT         :='';
    JProj_Actual_End_DT         :='';
    JProj_Target_Budget_d       :='';
    JProj_JCompany_ID           :='';
    JProj_JPerson_ID            :='';
    JProj_CreatedBy_JUser_ID    :='';
    JProj_Created_DT            :='';
    JProj_ModifiedBy_JUser_ID   :='';
    JProj_Modified_DT           :='';
    JProj_DeletedBy_JUser_ID    :='';
    JProj_Deleted_DT            :='';
    JProj_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JProjectCategory(var p_rJProjectCategory: rtJProjectCategory);
//=============================================================================
begin
  with p_rJProjectCategory do begin
    JPjCt_JProjectCategory_UID :='';
    JPjCt_Name                 :='';
    JPjCt_Desc                 :='';
    JPjCt_JCaption_ID          :='';
    JPjCt_CreatedBy_JUser_ID   :='';
    JPjCt_Created_DT           :='';
    JPjCt_ModifiedBy_JUser_ID  :='';
    JPjCt_Modified_DT          :='';
    JPjCt_DeletedBy_JUser_ID   :='';
    JPjCt_Deleted_DT           :='';
    JPjCt_Deleted_b            :='';
    JAS_Row_b                  :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JQuickLink(p_rJQuickLink: rtJQuickLink);
//=============================================================================
begin
  with p_rJQuickLink do begin
    JQLnk_JQuickLink_UID          := '';
    JQLnk_Name                    := '';
    JQLnk_SecPerm_ID              := '';
    JQLnk_Desc                    := '';
    JQLnk_URL                     := '';
    JQLnk_Icon                    := '';
    JQLnk_Owner_JUser_ID          := '';
    JQLnk_Position_u              := '';
    JQLnk_ValidSessionOnly_b      := '';
    JQLnk_DisplayIfNoAccess_b     := '';
    JQLnk_DisplayIfValidSession_b := '';
    JQLnk_RenderAsUniqueDiv_b     := '';
    JQLnk_Private_Memo            := '';
    JQLnk_Private_b               := '';
    JQLnk_CreatedBy_JUser_ID      := '';
    JQLnk_Created_DT              := '';
    JQLnk_ModifiedBy_JUser_ID     := '';
    JQLnk_Modified_DT             := '';
    JQLnk_DeletedBy_JUser_ID      := '';
    JQLnk_Deleted_b               := '';
    JQLnk_Deleted_DT              := '';
    JAS_Row_b                     := '';
  end;
end;
//=============================================================================


//=============================================================================
procedure clear_JScreen(var p_rJScreen: rtJScreen);
//=============================================================================
begin
  with p_rJScreen do begin
    JScrn_JScreen_UID         :='';
    JScrn_Name                :='';
    JScrn_Desc                :='';
    JScrn_JCaption_ID         :='';
    JScrn_JScreenType_ID      :='';
    JScrn_Template            :='';
    JScrn_ValidSessionOnly_b  :='';
    JScrn_JSecPerm_ID         :='';
    JScrn_Detail_JScreen_ID   :='';
    JScrn_IconSmall           :='';
    JScrn_IconLarge           :='';
    JScrn_TemplateMini        :='';
    JScrn_Modify_JSecPerm_ID  :='';
    JScrn_Help_ID            :='';
    JScrn_CreatedBy_JUser_ID  :='';
    JScrn_Created_DT          :='';
    JScrn_ModifiedBy_JUser_ID :='';
    JScrn_Modified_DT         :='';
    JScrn_DeletedBy_JUser_ID  :='';
    JScrn_Deleted_DT          :='';
    JScrn_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JScreenType(var p_rJScreenType: rtJScreenType);
//=============================================================================
begin
  with p_rJScreenType do begin
    JScTy_JScreenType_UID     :='';
    JScTy_Name                :='';
    JScTy_CreatedBy_JUser_ID  :='';
    JScTy_Created_DT          :='';
    JScTy_ModifiedBy_JUser_ID :='';
    JScTy_Modified_DT         :='';
    JScTy_DeletedBy_JUser_ID  :='';
    JScTy_Deleted_DT          :='';
    JScTy_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrp(var p_rJSecGrp: rtJSecGrp);
//=============================================================================
begin
  with p_rJSecGrp do begin
    JSGrp_JSecGrp_UID           :='';
    JSGrp_Name                  :='';
    JSGrp_Desc                  :='';
    JSGrp_CreatedBy_JUser_ID    :='';
    JSGrp_Created_DT            :='';
    JSGrp_ModifiedBy_JUser_ID   :='';
    JSGrp_Modified_DT           :='';
    JSGrp_DeletedBy_JUser_ID    :='';
    JSGrp_Deleted_DT            :='';
    JSGrp_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrpLink(var p_rJSecGrpLink: rtJSecGrpLink);
//=============================================================================
begin
  with p_rJSecGrpLink do begin
    JSGLk_JSecGrpLink_UID     :='';
    JSGLk_JSecPerm_ID         :='';
    JSGLk_JSecGrp_ID          :='';
    JSGLk_CreatedBy_JUser_ID  :='';
    JSGLk_Created_DT          :='';
    JSGLk_ModifiedBy_JUser_ID :='';
    JSGLk_Modified_DT         :='';
    JSGLk_DeletedBy_JUser_ID  :='';
    JSGLk_Deleted_DT          :='';
    JSGLk_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecGrpUserLink(var p_rJSecGrpUserLink: rtJSecGrpUserLink);
//=============================================================================
begin
  with p_rJSecGrpUserLink do begin
    JSGUL_JSecGrpUserLink_UID   :='';
    JSGUL_JSecGrp_ID            :='';
    JSGUL_JUser_ID              :='';
    JSGUL_CreatedBy_JUser_ID    :='';
    JSGUL_Created_DT            :='';
    JSGUL_ModifiedBy_JUser_ID   :='';
    JSGUL_Modified_DT           :='';
    JSGUL_DeletedBy_JUser_ID    :='';
    JSGUL_Deleted_DT            :='';
    JSGUL_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JSecKey(var p_rJSecKey: rtJSecKey);
//=============================================================================
begin
  with p_rJSecKey do begin
    JSKey_JSecKey_UID           :='';
    JSKey_KeyPub                :='';
    JSKey_KeyPvt                :='';
    JSKey_CreatedBy_JUser_ID    :='';
    JSKey_Created_DT            :='';
    JSKey_ModifiedBy_JUser_ID   :='';
    JSKey_Modified_DT           :='';
    JSKey_DeletedBy_JUser_ID    :='';
    JSKey_Deleted_DT            :='';
    JSKey_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;
end;
//=============================================================================


//=============================================================================
procedure clear_JSecPerm(var p_rJSecPerm: rtJSecPerm);
//=============================================================================
begin
  with p_rJSecPerm do begin
    JSPrm_JSecPerm_UID        :='';
    JSPrm_Name                :='';
    JSPrm_CreatedBy_JUser_ID  :='';
    JSPrm_Created_DT          :='';
    JSPrm_ModifiedBy_JUser_ID :='';
    JSPrm_Modified_DT         :='';
    JSPrm_DeletedBy_JUser_ID  :='';
    JSPrm_Deleted_DT          :='';
    JSPrm_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSecPermUserLink(var p_rJSecPermUserLink: rtJSecPermUserLink);
//=============================================================================
begin
  with p_rJSecPermUserLink do begin
    JSPUL_JSecPermUserLink_UID  :='';
    JSPUL_JSecPerm_ID           :='';
    JSPUL_JUser_ID              :='';
    JSPUL_CreatedBy_JUser_ID    :='';
    JSPUL_Created_DT            :='';
    JSPUL_ModifiedBy_JUser_ID   :='';
    JSPUL_Modified_DT           :='';
    JSPUL_DeletedBy_JUser_ID    :='';
    JSPUL_Deleted_DT            :='';
    JSPUL_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JSession(var p_rJSession: rtJSession);
//=============================================================================
begin
  with p_rJSession do begin
    JSess_JSession_UID        :='';
    JSess_JSessionType_ID     :='';
    JSess_JUser_ID            :='';
    JSess_Connect_DT          :='';
    JSess_LastContact_DT      :='';
    JSess_IP_ADDR             :='';
    JSess_PORT_u              :='';
    JSess_Username            :='';
    JSess_JJobQ_ID            :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JSessionData(var p_rJSessionData: rtJSessionData);
//=============================================================================
begin
  with p_rJSessionData do begin
    JSDat_JSessionData_UID      :='';
    JSDat_JSession_ID           :='';
    JSDat_Name                  :='';
    JSDat_Value                 :='';
    JSDat_CreatedBy_JUser_ID    :='';
    JSDat_Created_DT            :='';
  end;
end;
//=============================================================================



//=============================================================================
procedure clear_JSessionType(var p_rJSessionType: rtJSessionType);
//=============================================================================
begin
  with p_rJSessionType do begin
    JSTyp_JSessionType_UID    :='';
    JSTyp_Name                :='';
    JSTyp_Desc                :='';
    JSTyp_CreatedBy_JUser_ID  :='';
    JSTyp_Created_DT          :='';
    JSTyp_ModifiedBy_JUser_ID :='';
    JSTyp_Modified_DT         :='';
    JSTyp_DeletedBy_JUser_ID  :='';
    JSTyp_Deleted_DT          :='';
    JSTyp_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JSysModule(var p_rJSysModule: rtJSysModule);
//=============================================================================
begin
  with p_rJSysModule do begin
    JSysM_JSysModule_UID      :='';
    JSysM_Name                :='';
    JSysM_CreatedBy_JUser_ID  :='';
    JSysM_Created_DT          :='';
    JSysM_ModifiedBy_JUser_ID :='';
    JSysM_Modified_DT         :='';
    JSysM_DeletedBy_JUser_ID  :='';
    JSysM_Deleted_DT          :='';
    JSysM_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JTable(var p_rJTable: rtJTable);
//=============================================================================
begin
  with p_rJTable do begin
    JTabl_JTable_UID          :='';
    JTabl_Name                :='';
    JTabl_Desc                :='';
    JTabl_JTableType_ID       :='';
    JTabl_JDConnection_ID     :='';
    JTabl_ColumnPrefix        :='';
    JTabl_DupeScore_u         :='';
    JTabl_Perm_JColumn_ID     :='';
    JTabl_Owner_Only_b        :='';
    JTabl_View_MySQL          :='';
    JTabl_View_MSSQL          :='';
    JTabl_View_MSAccess       :='';
    JTabl_Add_JSecPerm_ID     :='';
    JTabl_Update_JSecPerm_ID  :='';
    JTabl_View_JSecPerm_ID    :='';
    JTabl_Delete_JSecPerm_ID  :='';
    JTabl_CreatedBy_JUser_ID  :='';
    JTabl_Created_DT          :='';
    JTabl_ModifiedBy_JUser_ID :='';
    JTabl_Modified_DT         :='';
    JTabl_DeletedBy_JUser_ID  :='';
    JTabl_Deleted_DT          :='';
    JTabl_Deleted_b           :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JTableType(var p_rJTableType: rtJTableType);
//=============================================================================
begin
  with p_rJTableType do begin
    JTTyp_JTableType_UID      :='';
    JTTyp_Name                :='';
    JTTyp_Desc                :='';
    JTTyp_CreatedBy_JUser_ID  :='';
    JTTyp_Created_DT          :='';
    JTTyp_ModifiedBy_JUser_ID :='';
    JTTyp_Modified_DT         :='';
    JTTyp_DeletedBy_JUser_ID  :='';
    JTTyp_Deleted_DT          :='';
    JTTyp_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTask(var p_rJTask: rtJTask);
//=============================================================================
begin
  with p_rJTask do begin
    JTask_JTask_UID                  :='';
    JTask_Name                       :='';
    JTask_Desc                       :='';
    JTask_JTaskCategory_ID           :='';
    JTask_JProject_ID                :='';
    JTask_JStatus_ID                 :='';
    JTask_Due_DT                     :='';
    JTask_Duration_Minutes_Est       :='';
    JTask_JPriority_ID               :='';
    JTask_Start_DT                   :='';
    JTask_Owner_JUser_ID             :='';
    JTask_SendReminder_b             :='';
    JTask_ReminderSent_b             :='';
    JTask_ReminderSent_DT            :='';
    JTask_Remind_DaysAhead_u         :='';
    JTask_Remind_HoursAhead_u        :='';
    JTask_Remind_MinutesAhead_u      :='';
    JTask_Remind_Persistantly_b      :='';
    JTask_Progress_PCT_d             :='';
    JTask_JCase_ID                   :='';
    JTask_Directions_URL             :='';
    JTask_URL                        :='';
    JTask_Milestone_b                :='';
    JTask_Budget_d                   :='';
    JTask_ResolutionNotes            :='';
    JTask_Completed_DT               :='';
    JTask_Related_JTable_ID          :='';
    JTask_Related_Row_ID             :='';
    JTask_CreatedBy_JUser_ID         :='';
    JTask_Created_DT                 :='';
    JTask_ModifiedBy_JUser_ID        :='';
    JTask_Modified_DT                :='';
    JTask_DeletedBy_JUser_ID         :='';
    JTask_Deleted_DT                 :='';
    JTask_Deleted_b                  :='';
    JAS_Row_b                        :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTaskCategory(var p_rJTaskCategory: rtJTaskCategory);
//=============================================================================
begin
  with p_rJTaskCategory do begin
    JTCat_JTaskCategory_UID   :='';
    JTCat_Name                :='';
    JTCat_Desc                :='';
    JTCat_JCaption_ID         :='';
    JTCat_CreatedBy_JUser_ID  :='';
    JTCat_Created_DT          :='';
    JTCat_ModifiedBy_JUser_ID :='';
    JTCat_Modified_DT         :='';
    JTCat_DeletedBy_JUser_ID  :='';
    JTCat_Deleted_DT          :='';
    JTCat_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JStatus(var p_rJStatus: rtJStatus);
//=============================================================================
begin
  with p_rJStatus do begin
    JStat_JStatus_UID     :='';
    JStat_Name                :='';
    JStat_Desc                :='';
    JStat_JCaption_ID         :='';
    JStat_CreatedBy_JUser_ID  :='';
    JStat_Created_DT          :='';
    JStat_ModifiedBy_JUser_ID :='';
    JStat_Modified_DT         :='';
    JStat_DeletedBy_JUser_ID  :='';
    JStat_Deleted_DT          :='';
    JStat_Deleted_b           :='';
    JAS_Row_b                 :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTimecard(var p_rJTimecard: rtJTimecard);
//=============================================================================
begin
  with p_rJTimecard do begin
    TMCD_TimeCard_UID                 :='';
    TMCD_Name                         :='';
    TMCD_In_DT                        :='';
    TMCD_Out_DT                       :='';
    TMCD_JNote_Public_ID              :='';
    TMCD_JNote_Internal_ID            :='';
    TMCD_Reference                    :='';
    TMCD_JProject_ID                  :='';
    TMCD_JTask_ID                     :='';
    TMCD_Billable_b                   :='';
    TMCD_ManualEntry_b                :='';
    TMCD_ManualEntry_DT               :='';
    TMCD_Exported_b                   :='';
    TMCD_Exported_DT                  :='';
    TMCD_Uploaded_b                   :='';
    TMCD_Uploaded_DT                  :='';
    TMCD_PayrateName                  :='';
    TMCD_Payrate_d                    :='';
    TMCD_Expense_b                    :='';
    TMCD_Imported_b                   :='';
    TMCD_Imported_DT                  :='';
    TMCD_Note_Internal                :='';
    TMCD_Note_Public                  :='';
    TMCD_Invoice_Sent_b               :='';
    TMCD_Invoice_Paid_b               :='';
    TMCD_Invoice_No                   :='';
    TMCD_CreatedBy_JUser_ID           :='';
    TMCD_Created_DT                   :='';
    TMCD_ModifiedBy_JUser_ID          :='';
    TMCD_Modified_DT                  :='';
    TMCD_DeletedBy_JUser_ID           :='';
    TMCD_Deleted_DT                   :='';
    TMCD_Deleted_b                    :='';
    JAS_Row_b                         :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTeam(var p_rJTeam: rtJTeam);
//=============================================================================
begin
  with p_rJTeam do begin
    JTeam_JTeam_UID             :='';
    JTeam_Parent_JTeam_ID       :='';
    JTeam_JCompany_ID           :='';
    JTeam_Name                  :='';
    JTeam_Desc                  :='';
    JTeam_CreatedBy_JUser_ID    :='';
    JTeam_Created_DT            :='';
    JTeam_ModifiedBy_JUser_ID   :='';
    JTeam_Modified_DT           :='';
    JTeam_DeletedBy_JUser_ID    :='';
    JTeam_Deleted_DT            :='';
    JTeam_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTeamMember(var p_rJTeamMember: rtJTeamMember);
//=============================================================================
begin
  with p_rJTeamMember do begin
    JTMem_JTeamMember_UID       :='';
    JTMem_JTeam_ID              :='';
    JTMem_JPerson_ID            :='';
    JTMem_JCompany_ID           :='';
    JTMem_JUser_ID              :='';
    JTMem_CreatedBy_JUser_ID    :='';
    JTMem_Created_DT            :='';
    JTMem_ModifiedBy_JUser_ID   :='';
    JTMem_Modified_DT           :='';
    JTMem_DeletedBy_JUser_ID    :='';
    JTMem_Deleted_DT            :='';
    JTMem_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JTestOne(var p_rJTestOne: rtJTestOne);
//=============================================================================
begin
  with p_rJTestOne do begin
    JTes1_JTestOne_UID          :='';
    JTes1_Text                  :='';
    JTes1_Boolean_b             :='';
    JTes1_Memo                  :='';
    JTes1_DateTime_DT           :='';
    JTes1_Integer_i             :='';
    JTes1_Currency_d            :='';
    JTes1_Memo2                 :='';
    JTes1_Added_DT              :='';
    JTes1_RemoteIP              :='';
    JTes1_RemotePort_u          :='';
    JTes1_CreatedBy_JUser_ID    :='';
    JTes1_Created_DT            :='';
    JTes1_ModifiedBy_JUser_ID   :='';
    JTes1_Modified_DT           :='';
    JTes1_DeletedBy_JUser_ID    :='';
    JTes1_Deleted_DT            :='';
    JTes1_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_jthemecolor(var p_rJThemecolor: rtJThemecolor);
//=============================================================================
begin
  with p_rJThemeColor do begin
    THCOL_Name                  :='';
    THCOL_Desc                  :='';
    THCOL_Template_Header       :='';
    THCOL_CreatedBy_JUser_ID    :='';
    THCOL_Created_DT            :='';
    THCOL_ModifiedBy_JUser_ID   :='';
    THCOL_Modified_DT           :='';
    THCOL_DeletedBy_JUser_ID    :='';
    THCOL_Deleted_DT            :='';
    THCOL_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;
end;
//=============================================================================



//=============================================================================
{}
procedure clear_jthemecolorlight(var p_rJThemeColorLight: rtJThemeColorLight);
//=============================================================================
begin
  with p_rJThemeColorLight do begin
    u8JThemeColor_UID       :=0;
    saName                  :='';
    saTemplate_Header       :='';
  end;
end;
//=============================================================================



//=============================================================================
procedure clear_JTrak(var p_rJTrak: rtJTrak);
//=============================================================================
begin
  with p_rJTrak do begin
    JTrak_JTrak_UID           :='';
    JTrak_JDConnection_ID     :='';
    JTrak_JSession_ID         :='';
    JTrak_JTable_ID           :='';
    JTrak_Row_ID              :='';
    JTrak_Col_ID              :='';
    JTrak_JUser_ID            :='';
    JTrak_Create_b            :='';
    JTrak_Modify_b            :='';
    JTrak_Delete_b            :='';
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
    JUser_JVHost_ID              :='';
    JUser_TotalJetUsers_d        :='';
    JUser_SIP_Exten              :='';
    JUser_SIP_Pass               :='';
    JUser_CreatedBy_JUser_ID     :='';
    JUser_Created_DT             :='';
    JUser_ModifiedBy_JUser_ID    :='';
    JUser_Modified_DT            :='';
    JUser_DeletedBy_JUser_ID     :='';
    JUser_Deleted_DT             :='';
    JUser_Deleted_b              :='';
    JAS_Row_b                    :=false;
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JUserPref(var p_rJUserPref: rtJUserPref);
//=============================================================================
begin
  with p_rJUserPref do begin
    UserP_UserPref_UID          :='';
    UserP_Name                  :='';
    UserP_Desc                  :='';
    UserP_CreatedBy_JUser_ID    :='';
    UserP_Created_DT            :='';
    UserP_ModifiedBy_JUser_ID   :='';
    UserP_Modified_DT           :='';
    UserP_DeletedBy_JUser_ID    :='';
    UserP_Deleted_DT            :='';
    UserP_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JUserPrefLink(var p_rJUserPrefLink: rtJUserPrefLink);
//=============================================================================
begin
  with p_rJUserPrefLink do begin
    UsrPL_UserPrefLink_UID      :='';
    UsrPL_UserPref_ID           :='';
    UsrPL_User_ID               :='';
    UsrPL_Value                 :='';
    UsrPL_CreatedBy_JUser_ID    :='';
    UsrPL_Created_DT            :='';
    UsrPL_ModifiedBy_JUser_ID   :='';
    UsrPL_Modified_DT           :='';
    UsrPL_DeletedBy_JUser_ID    :='';
    UsrPL_Deleted_DT            :='';
    UsrPL_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JWidget(var p_rJWidget: rtJWidget);
//=============================================================================
begin
  with p_rJWidget do begin
    JWidg_JWidget_UID           :='';
    JWidg_Name                  :='';
    JWidg_Procedure             :='';
    JWidg_Desc                  :='';
    JWidg_CreatedBy_JUser_ID    :='';
    JWidg_Created_DT            :='';
    JWidg_ModifiedBy_JUser_ID   :='';
    JWidg_Modified_DT           :='';
    JWidg_DeletedBy_JUser_ID    :='';
    JWidg_Deleted_DT            :='';
    JWidg_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================

//=============================================================================
procedure clear_JWidgetLink(var p_rJWidgetLink: rtJWidgetLink);
//=============================================================================
begin
  with p_rJWidgetLink do begin
    JWLnk_JWidgetLink_UID       :='';
    JWLnk_JWidget_ID            :='';
    JWLnk_JDType_ID             :='';
    JWLnk_JBlokType_ID          :='';
    JWLnk_JInterface_ID         :='';
    JWLnk_CreatedBy_JUser_ID    :='';
    JWLnk_Created_DT            :='';
    JWLnk_ModifiedBy_JUser_ID   :='';
    JWLnk_Modified_DT           :='';
    JWLnk_DeletedBy_JUser_ID    :='';
    JWLnk_Deleted_DT            :='';
    JWLnk_Deleted_b             :='';
    JAS_Row_b                   :='';
  end;//with
end;
//=============================================================================


//=============================================================================
procedure clear_JWorkQueue(var p_rJWorkQueue: rtJWorkQueue);
//=============================================================================
begin
  with p_rJWorkQueue do begin
    JWrkQ_JWorkQueue_UID          :=''; //uid
    JWrkQ_JUser_ID                :=''; //user who caused job
    JWrkQ_Posted_DT               :=''; //when job submitted
    JWrkQ_Started_DT              :=''; //when actual processing of job started
    JWrkQ_Finished_DT             :=''; //when actual processing of job finished
    JWrkQ_Delivered_DT            :=''; //when results of job delivered
    JWrkQ_Job_GUID                :=''; // GUID for the job
    JWrkQ_Confirmed_b             :=''; // boolean indicating job confirmed as successful via GUID exchange
    JWrkQ_Confirmed_DT            :=''; // datetime job success confirmed. Note, if this datetime is not null but confirmed = false then this means job failed
    JWrkQ_JobType_ID              :=''; // Job Type ID
    JWrkQ_JobDesc                 :=''; // Short Description of job (255 char max)
    JWrkQ_Src_JUser_ID            :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_JDConnection_ID     :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_JTable_ID           :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Row_ID              :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Column_ID           :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_Data                :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_RemoteIP            :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Src_RemotePort_u        :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JUser_ID           :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JDConnection_ID    :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_JTable_ID          :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Row_ID             :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Column_ID          :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_Data               :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_RemoteIP           :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_Dest_RemotePort_u       :=''; // Fields available for job processing - implementation - jobtype dependent
    JWrkQ_CreatedBy_JUser_ID      :='';
    JWrkQ_Created_DT              :='';
    JWrkQ_ModifiedBy_JUser_ID     :='';
    JWrkQ_Modified_DT             :='';
    JWrkQ_DeletedBy_JUser_ID      :='';
    JWrkQ_Deleted_DT              :='';
    JWrkQ_Deleted_b               :='';
    JAS_Row_b                     :='';
  end;//with
end;
//=============================================================================



//=============================================================================
procedure clear_JVHost(var p_rJVHost: rtJVHost);
//=============================================================================
begin
  with p_rJVHost do begin
    VHost_JVHost_UID               :='';
    VHost_WebRootDir               :='';
    VHost_ServerName               :='';
    VHost_ServerIdent              :='';
    VHost_ServerDomain             :='';
    VHost_ServerIP                 :='';
    VHost_ServerPort               :='';
    VHost_DefaultLanguage          :='';
    VHost_DefaultColorTheme        :='';
    VHost_MenuRenderMethod         :='';
    VHost_DefaultArea              :='';
    VHost_DefaultPage              :='';
    VHost_DefaultSection           :='';
    VHost_DefaultTop_JMenu_ID      :='';
    VHost_DefaultLoggedInPage      :='';
    VHost_DefaultLoggedOutPage     :='';
    VHost_DataOnRight_b            :='';
    VHost_CacheMaxAgeInSeconds     :='';
    VHost_SystemEmailFromAddress   :='';
    VHost_EnableSSL_b              :='';
    VHost_SharesDefaultDomain_b    :='';
    VHost_DefaultIconTheme         :='';
    VHost_DirectoryListing_b       :='';
    VHost_FileDir                  :='';
    VHost_AccessLog                :='';
    VHost_ErrorLog                 :='';
    VHost_JDConnection_ID          :='';
    VHost_Enabled_b                :='';
    VHost_CacheDir                 :='';
    VHost_TemplateDir              :='';
    VHost_SIPURL                   :='';
    VHost_CreatedBy_JUser_ID       :='';
    VHost_Created_DT               :='';
    VHost_ModifiedBy_JUser_ID      :='';
    VHost_Modified_DT              :='';
    VHost_DeletedBy_JUser_ID       :='';
    VHost_Deleted_DT               :='';
    VHost_Deleted_b                :='';
    JAS_Row_b                      :='';
  end;
end;
//=============================================================================








//=============================================================================
{}
procedure clear_JVHostLight(var p_rJVHostLight: rtJVHostLight);
//=============================================================================
begin
  with p_rJVHostLight do begin
    u8JVHost_UID               :=0;
    saWebRootDir               :='';
    saServerName               :='';
    saServerIdent              :='';
    saServerDomain             :='';
    saServerIP                 :='';
    u2ServerPort               :=0;
    saDefaultLanguage          :='';
    saDefaultColorTheme        :='';
    u1MenuRenderMethod         :=0;
    saDefaultArea              :='';
    saDefaultPage              :='';
    saDefaultSection           :='';
    u8DefaultTop_JMenu_ID      :=0;
    saDefaultLoggedInPage      :='';
    saDefaultLoggedOutPage     :='';
    bDataOnRight               :=false;
    sCacheMaxAgeInSeconds      :='0';
    sSystemEmailFromAddress    :='';
    bEnableSSL                 :=false;
    bSharesDefaultDomain       :=false;
    saDefaultIconTheme         :='';
    bDirectoryListing          :=false;
    saFileDir                  :='';
    saAccessLog                :='';
    saErrorLog                 :='';
    u8JDConnection_ID          :=0;
    MenuDL                     :=nil;
    bIdentOk                   :=false;
    saCacheDir                 :='';
    // OPTIONS BELOW NOT FROM JVHOST but INSTEAD
    // ADMIN OWNED Preferences
    bAllowRegistration         :=false;
    bRegistrationReqCellPhone  :=false;
    bRegistrationReqBirthday   :=false;
    saSIPURL                   :='';
  end;
end;
//=============================================================================











// ============================================================================
procedure clear_JIPLIST(var p_rJIPList: rtJIPLIST);
// ============================================================================
begin
  with p_rJIPList do begin
    JIPL_JIPList_UID            :='';
    JIPL_IPListType_u           :='';
    JIPL_IPAddress              :='';
    JIPL_InvalidLogins_u        :='';
    JIPL_CreatedBy_JUser_ID     :='';
    JIPL_Created_DT             :='';
    JIPL_ModifiedBy_JUser_ID    :='';
    JIPL_Modified_DT            :='';
    JIPL_DeletedBy_JUser_ID     :='';
    JIPL_Deleted_DT             :='';
    JIPL_Deleted_b              :='';
    JAS_Row_b                   :='';
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
    saIPAddress              :='';
  end;
end;
//=============================================================================


//=============================================================================
{}
procedure clear_JIPListLU(var p_rJIPListLU: rtJIPListLU);
begin
  with p_rJIPListLU do begin
    IPLU_JIPListLU_UID           :='';
    IPLU_Name                    :='';
    IPLU_CreatedBy_JUser_ID      :='';
    IPLU_Created_DT              :='';
    IPLU_DeletedBy_JUser_ID      :='';
    IPLU_Deleted_b               :='';
    IPLU_Deleted_DT              :='';
    IPLU_ModifiedBy_JUser_ID     :='';
    IPLU_Modified_DT             :='';
    JAS_Row_b                    :='';
  end;//with
end;
//=============================================================================






// ============================================================================
procedure clear_JAlias(var p_rJAlias: rtJAlias);
// ============================================================================
begin
  with p_rJAlias do begin
    Alias_JAlias_UID            :='';
    Alias_JVHost_ID             :='';
    Alias_Alias                 :='';
    Alias_Path                  :='';
    Alias_VHost_b               :='';
    Alias_CreatedBy_JUser_ID    :='';
    Alias_Created_DT            :='';
    Alias_ModifiedBy_JUser_ID   :='';
    Alias_Modified_DT           :='';
    Alias_DeletedBy_JUser_ID    :='';
    Alias_Deleted_DT            :='';
    Alias_Deleted_b             :='';
    JAS_Row_b                   :='';
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
    MIME_JMime_UID             :='';
    MIME_Name                  :='';
    MIME_Type                  :='';
    MIME_Enabled_b             :='';
    MIME_SNR_b                 :='';
    MIME_CreatedBy_JUser_ID    :='';
    MIME_Created_DT            :='';
    MIME_ModifiedBy_JUser_ID   :='';
    MIME_Modified_DT           :='';
    MIME_DeletedBy_JUser_ID    :='';
    MIME_Deleted_DT            :='';
    MIME_Deleted_b             :='';
    JAS_Row_b                  :='';
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
    saName                  :='';
    saType                  :='';
    bSNR                    :=false;
  end;
end;
// ============================================================================



// ============================================================================
procedure clear_JIndexfile(var p_rJIndexFile: rtJIndexFile);
// ============================================================================
begin
  with p_rJIndexFile do begin
    JIDX_JIndexFile_UID        :='';
    JIDX_JVHost_ID             :='';
    JIDX_Filename              :='';
    JIDX_Order_u               :='';
    JIDX_CreatedBy_JUser_ID    :='';
    JIDX_Created_DT            :='';
    JIDX_ModifiedBy_JUser_ID   :='';
    JIDX_Modified_DT           :='';
    JIDX_DeletedBy_JUser_ID    :='';
    JIDX_Deleted_DT            :='';
    JIDX_Deleted_b             :='';
    JAS_Row_b                  :='';
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
