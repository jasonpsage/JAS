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
// JAS Specific Functions
Unit uj_ui_screen;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_ui_screen.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND}
{$ENDIF}

{$IFDEF DEBUGTHREADBEGINEND}
  {$INFO | DEBUGTHREADBEGINEND}
{$ENDIF}



{DEFINE DEBUGHTML}
{$IFDEF DEBUGHTML}
  {$INFO | DEBUGHTML: TRUE}
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
,dos
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xml
,ug_jado
,ug_tsfileio
,ug_jfc_threadmgr
,uj_tables_loadsave
,uj_locking
,uj_permissions
,uj_captions
,uj_user
,uj_definitions
,uj_webwidgets
,uj_sessions
,uj_xml
,uj_context
,uj_fileserv
,uj_ui_stock
,uj_dbtools
,uj_jegas_customizations_empty
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
// This function is the first verion of JAS DynamicScreen functionality. Although
// to date it's been working great, we intend to make a newer version that is
// broken up into smaller modules and is not user interface specific as much,
// at least so the same code can be used to make screens using various user
// interfaces.
//
// Note that this function is responsible for both displaying custom screens,
// editting data and viewing query results, as well as screen editting. The
// screen editting works in a WYSIWYG fashion. You Need ADMIN permissions
// to modify the Screens in JAS at this time. Eventually this will be a specific
// Permission that is appropriately named so you do not need to specifically
// be a system administrator to customize screens.
//
// You can call up a screen and inadvertanly use this function by calling either:
// http://jas/?SCREENID=(SCREENID) or ?Screen=NameHEre
// Where screenid is the UID of the SCREEN you wish to view. If you call up
// a DETAIL screen in this manner without passing also the UID parameter for
// the record you wish to view/edit, clicking the save button will fail: no
// assumption is made that adding a record in this circumstance is desired.
// If you want to add a new record, try: // http://jas/?SCREENID=1&UID=0
//
// You can call up screens by name as well:
// http://jas/?screen=jaddress%20Search
//
// If you have the correct user permission, you will see a edit mode checkbox
// that will place the screen into edit mode so you can customize it as
// you see fit.
//
Procedure DynamicScreen(p_Context: TCONTEXT);
//==============================================================================







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
{}
// Button Types
const cnJBlokButtonType_ResetForm  = 0;
const cnJBlokButtonType_ReloadPage = 1;
const cnJBlokButtonType_Find       = 2;
const cnJBlokButtonType_New        = 3;
const cnJBlokButtonType_Save       = 4;
const cnJBlokButtonType_Delete     = 5;
const cnJBlokButtonType_Cancel     = 6;//abort too
const cnJBlokButtonType_Edit       = 7;
const cnJBlokButtonType_Custom     = 8;
const cnJBlokButtonType_Close      = 9;
const cnJBlokButtonType_SaveNClose = 10;
const cnJBlokButtonType_CancelNClose = 11;
const cnJBlokButtonType_SaveNNew = 12;
//=============================================================================


//=============================================================================
{}
// Constants for Detail Mode
Const cnJBlokMode_View = 0;
Const cnJBlokMode_New = 1;
Const cnJBlokMode_Delete = 2;
Const cnJBlokMode_Save = 3;
Const cnJBlokMode_Edit = 4;
Const cnJBlokMode_Deleted = 5;// Past Tense - Give user a screen letting them know.
Const cnJBlokMode_Cancel = 6;
const cnJBlokMode_SaveNClose=7;
const cnJBlokMode_CancelNClose=8;
const cnJBlokMode_Merge=9;
const cnJBlokMode_SaveNNew=10;
//=============================================================================


//=============================================================================
{}
type TJBlokButton = class
//=============================================================================
  Public
  Constructor Create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: ansistring);
  Destructor Destroy; override;
  function saRender: ansistring;

  public
  lpJBlok: pointer;
  bProblem: Boolean;
  rJBlokButton: rtJBlokButton;
  saCaption: ansistring;
end;
//=============================================================================






//=============================================================================
{}
type TJBlokField = class
//=============================================================================
  Public
  Constructor Create(p_lpJBlok: pointer; p_saJBlkF_JBlokfField_UID: ansistring);
  Destructor Destroy; override;
  procedure Reset;
  function bLoad: boolean;

  public
  lpJBlok: pointer;
  bProblem: boolean;

  rJBlokField: rtJBlokField;
  rJColumn: rtJColumn;

  sLU_Table_Name: string;
  sLU_Table_ColumnPrefix: string;
  sLU_Table_PKey: string;
  saLU_Column_SQL: Ansistring;

  saCaption: AnsiString;// from Column (Or jblokfield)
  saValue: AnsiString; // Default
  saValue2: AnsiString; // Used for Things like Date Range
  saAlignment: ansistring;
  saQuery: ansistring;
  ListXDL: JFC_XDL;// For Loading Lists for widgets that need it

  bSort: boolean;
  bAscending: boolean;
  uSortPosition: word;// Sort Order of Column versus other columns
  bPopulateListTrouble: boolean; //set to true when trouble populating List.

  saColumnAlias: ansistring;

end;
//=============================================================================



{}
const cnRecord_Add = 0;
const cnRecord_Edit = 1;
const cnRecord_View = 2;
const cnRecord_Delete = 3;



//==============================================================================
{}
type TJBLok = class
//==============================================================================
  Public
  Constructor Create(p_lpDS: pointer;p_JBlok_JBlok_UID: ansistring);
  Destructor Destroy; override;

  function bExecute: boolean;
  procedure ExecuteFilterBlok;
    procedure FilterBlok_CreateWidgets(JBlokField: TJBLOKFIELD; p_MXDL: JFC_XDL);

  function bExecuteGridBlok: boolean;
    function bGrid: boolean;
    function bGridQuery: boolean;
    function bGrid_MultiDelete: boolean;

  function bExecuteDataBlok: boolean;
    function bRecord_DetailDeleteRecord: boolean;
    procedure DataBlok_DetailDeletedRecord;
    procedure DataBlok_DetailCancel;
    function bRecord_Query: boolean;
    function bRecord_PreUpdate(p_saUID: ansistring): boolean;
    function bRecord_PostUpdate(p_saUID: ansistring): boolean;
    function bRecord_PreAdd: boolean;
    function bRecord_LoadDataIntoWidgets: boolean;

  function bExecuteCustomBlok: boolean;
  procedure RenderButtons;//renders all buttons

  function bEdit_AddDelete: boolean;// for Editting the JBlok
  function bEdit_Move: boolean;// for Editting the JBlok

  function saMode: ansistring;
  function bRecord_SecurityCheck(p_saUID: ansistring; p_iRecordAction: smallint): boolean;

  function bPreDelete(
    p_saTable: ansistring;
    p_saUID: ansistring
  ): boolean;

  public
  lpDS: pointer;
  bProblem: boolean;
  saCaption: Ansistring;
  rJBlok: rtJBlok;
  rJTable: rtJTable;
  bView: boolean;
  rJColumn_Primary: rtJColumn;
  rAudit: rtAudit;
  FXDL: JFC_XDL;// JBlokFields
  BXDL: JFC_XDL;// JBlokButtons

  uMode: word;
  bMultiMode: boolean;

  // Used To Prepare Output
  saHeader: ansistring;
  saSectionTop: ansistring;
  saSectionMiddle: ansistring;
  saSectionBottom: ansistring;
  saContent: ansistring;
  saFooter: ansistring;

  saButtons: ansistring; // Where buttons Are Rendered then placed into templates
  bPreventSaveButton: boolean;

  saPerm_JColu_Name: ansistring;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  
end;
//==============================================================================








//=============================================================================
type TJScreen = class
  Public
  Constructor Create(p_Context:TCONTEXT);
  Destructor Destroy; override;
  {}
  function bExecute: boolean;
  function bLoadJScreenRecord:boolean;
  function bValidate:boolean;// Checks Screen Type, if Exporting, and Permissions
  function bPlaceScreenHeaderInPageSNRXDL: boolean;
  function bLoadJBloks: boolean;
  public
  DT: TDATETIME;
  Context: TCONTEXT;//reference
  JBXDL: JFC_XDL;// Used for holding JBloks that are part of the screen.
  saCaption: ansistring;
  saScreenHeader: ansistring; // Information and controls for and about the screen itself
  // This is where the TEMPLATE htmlripper page goes.
  // After Rendering - it is populated with the generated bloks and then becomes the output
  // html page.
  saTemplate: AnsiString;
  bEditMode: boolean;
  bPageCompleted: boolean;
  bMiniMode: boolean;

  //------------------------------------------------------------
  rJScreen: rtJScreen; // From the Database
  saBlokFilter: ansistring;
  saBlokGrid: ansistring; // Generated Grid Block
  saBlokDetail: ansistring; // Generated Data Entry/View Block
  saBlokButtons: ansistring; // generated Buttons
  saResetForm: ansistring; // Where Javascript bits are placed so reset form
                           // button can reset all desired fields
  saQueryLimit: ansistring; // LIMIT 1000 (MySQL) or TOP 200 (MSSQL/ACCESS)
  saQuerySelect: ansistring;
  saQueryFrom: ansistring;
  saQueryWhere: ansistring;
  saQueryOrder: ansistring;

  // GRID RELATED --------------
  saExportPage: ansistring;
  bExportingNow: boolean;
  saExportMode: ansistring;
  bBackgroundPrepare: Boolean;
  bBackgroundExporting: Boolean;
  saBackTask: ansistring;
  uGridRowsPerPage: word;
  uRPage: cardinal;
  uRTotalPages: cardinal;
  uRTotalRecords: Cardinal;
  uRecordCount: Cardinal;
  uPageRowMath: Cardinal;
  // GRID Related --------------
  //------------------------------------------------------------

  //----editting the screens
  EDIT_ACTION: ansistring;
  EDIT_JBLOK_JBLOK_UID: ansistring;
  EDIT_JBLKF_JBLOKFIELD_UID: ansistring;
  //----editting the screens
  rJBlok: rtJBlok;
  rJColumn: rtJColumn;
  rJBlokField: rtJBlokField;
  saNEWCOLUMNID: ansistring;
  saNEWCOLUMNFORBLOKID: ansistring;
  saAddBlokField: ansistring;
  //rJTable: rtJTable;
  rJDConnection: rtJDConnection;
  Widget: TJBLOKFIELD;

end;
//=============================================================================
//==============================================================================
//==============================================================================











//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF

//=============================================================================
constructor TJBlokButton.create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: Ansistring);
//=============================================================================
var
  Context: TCONTEXT;
  JBlok: TJBLOK;
  JScreen: TJSCREEN;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokButton.create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: Ansistring);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  lpJBlok:=p_lpJBlok;
  JBlok:=TJBLOK(lpJBlok);
  JScreen:=TJSCREEN(JBlok.lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203191947,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203191947, sTHIS_ROUTINE_NAME);{$ENDIF}

  clear_JBlokButton(rJBlokButton);
  rJBlokButton.JBlkB_JBlokButton_UID:=p_JBlkB_JBlokButton_UID;
  bProblem:=not bJAS_Load_JBlokButton(Context, JBlok.DBC, rJBlokButton, false);
  if not bProblem then
  begin
    saCaption:='';
    bProblem:=not bJASCaption(Context,rJBlokButton.JBlkB_JCaption_ID,saCaption, rJBlokButton.JBlkB_Name);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203191948,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
destructor TJBlokButton.Destroy;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; Context: TCONTEXT;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokButton.Destroy;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}
Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
Context.JThread.DBIN(201203191949,sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
{$IFDEF TRACKTHREAD}Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;{$ENDIF}



{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203191949, sTHIS_ROUTINE_NAME);{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203191950,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function TJBLOKBUTTON.saRender: ansistring;
//=============================================================================
var
  {$IFDEF DEBUGTHREADBEGINEND}
    Context: TCONTEXT;
  {$ELSE}
     {$IFDEF TRACKTHREAD}
        Context: TCONTEXT;
     {$ENDIF}
  {$ENDIF}

  saName: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOKBUTTON.saRender'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  {$IFDEF DEBUGTHREADBEGINEND}
    Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
  {$ELSE}
     {$IFDEF TRACKTHREAD}
       Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
     {$ENDIF}
  {$ENDIF}




{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203189018,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203189018, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:='[UNKNOWN BUTTON TYPE]';
  
  saName:=rJBlokButton.JBlkB_Name;
  case u8Val(rJBlokButton.JBlkB_JButtonType_ID) of
  cnJBlokButtonType_ResetForm:
    Begin
      Result:='<li><a href="javascript: ResetForm();"><img class="image" src="'+
                 rJBlokButton.JBlkB_GraphicFileName+'" />'+
                 '<span class="jasbutspan">&nbsp;'+saCaption+'</span></a></li>'+csCRLF;
    End;

  cnJBlokButtonType_ReloadPage:
    Begin
      Result:='<li><a href="javascript: window.location.reload();"><img class="image" src="'+
                 rJBlokButton.JBlkB_GraphicFileName+'" />'+
                 '<span class="jasbutspan">&nbsp;'+saCaption+'</span></a></li>'+csCRLF;
    End;

  cnJBlokButtonType_Find:
    Begin
      Result:='<li><a href="javascript: SubmitForm();"><img class="image" src="'+
                 rJBlokButton.JBlkB_GraphicFileName+'" />'+
                 '<span class="jasbutspan">&nbsp;'+saCaption+'</span></a></li>'+csCRLF;
    End;

  cnJBlokButtonType_New:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        Result:='<li><a href="javascript: NewWindow(''[@ALIAS@].?[@DETAILSCREENID@]'')"><img class="image" src="'+
                  rJBlokButton.JBlkB_GraphicFileName+'" />'+
                  '<span class="jasbutspan">&nbsp;'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;

  cnJBlokButtonType_Save: // Save;
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        saName:='SAVE';
        Result:='<li><a href="javascript: JButton('''+saName+
          ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;

  cnJBlokButtonType_Delete:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        Result:='<li><a href="javascript: if(confirm(''Are you sure you wish to delete this record?'')){JButton('''+
          saName+''');};"><img class="image" src="'+
          rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;

  cnJBlokButtonType_Cancel:
    Begin
      saName:='CANCEL';
      Result:='<li><a href="javascript: JButton('''+saName+
        ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
      Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
    End;

  cnJBlokButtonType_Edit:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        saName:='EDIT';
        Result:='<li><a href="javascript: JButton('''+saName+
          ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;

  cnJBlokButtonType_Custom: // Custom
    Begin
      Result:='<li><a href="'+rJBlokButton.JBlkB_CustomURL+'"><img class="image" src="'+
                  rJBlokButton.JBlkB_GraphicFileName+'" /><span class="jasbutspan">'+
                  '<b>'+saCaption+'</b></span></a></li>';
    End;
  cnJBlokButtonType_Close: // Close;
    Begin
      Result:='<li><a href="javascript: self.close();"><img class="image" src="'+
                  rJBlokButton.JBlkB_GraphicFileName+'" />'+csCRLF+
                  '<span class="jasbutspan">&nbsp;'+saCaption+'</span></a></li>'+csCRLF;
    End;
  cnJBlokButtonType_SaveNClose:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        saName:='SAVENCLOSE';
        Result:='<li><a href="javascript: JButton('''+saName+
          ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;
  cnJBlokButtonType_CancelNClose:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        saName:='CANCELNCLOSE';
        Result:='<li><a href="javascript: JButton('''+saName+
          ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;
  cnJBlokButtonType_SaveNNew:
    Begin
      if not TJBLOK(lpJBLOK).bView then
      begin
        saName:='SAVENNEW';
        Result:='<li><a href="javascript: JButton('''+saName+
          ''');"><img class="image" src="'+rJBlokButton.JBlkB_GraphicFileName+'" />';
        Result+='<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
      end
      else
      begin
        Result:='';
      end;
    End;
  End;// case
  

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203189119,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokButton STUFF









//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//=============================================================================
constructor TJBlokField.create(p_lpJBlok: pointer; p_saJBlkF_JBlokfField_UID: ansistring);
//=============================================================================
var
  JBLok: TJBLOK;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokField.create(p_lpJBlok: pointer; p_saJBlkF_JBlokfField_UID: ansistring);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JBlok:=TJBLOK(p_lpJBlok);
  JScreen:=TJSCREEN(JBlok.lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203191951,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203191951, sTHIS_ROUTINE_NAME);{$ENDIF}

  ListXDL:=JFC_XDL.Create;
  lpJBlok:=p_lpJBlok;
  Reset;
  rJBlokField.JBlkF_JBlokField_UID:=p_saJBlkF_JBlokfField_UID;
  bProblem:=not bLoad;
  if bProblem then
  begin
    JAS_Log(Context,cnLog_Error,201210011750,'TJBlokfield.Create call to bLoad Failed - ScreenID:' +
      JScreen.rJScreen.JScrn_JScreen_UID+' JBlok: '+TJBLOK(lpJBlok).rJBlok.JBlok_Name+
      ' JBlokField: '+rJBlokField.JBlkF_JBlokField_UID,'',SOURCEFILE);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203191952,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
destructor TJBlokField.Destroy;
//=============================================================================
begin
  ListXDL.Destroy;
end;
//=============================================================================



//=============================================================================
Procedure TJBlokField.Reset;
//=============================================================================
begin
  bProblem:=false;
  clear_JBlokField(rJBlokField);
  clear_JColumn(rJColumn);

  saCaption:='';
  saValue:='';
  saValue2:='';
  saAlignment:='';
  saQuery:='';
  bSort:=false;
  bAscending:=true;
  uSortPosition:=0;
  bPopulateListTrouble:=false;
  ListXDL.DeleteAll;

  sLU_Table_Name:='';
  sLU_Table_ColumnPrefix:='';
  sLU_Table_PKey:='';
  saLU_Column_SQL:='';

  saColumnAlias:='';
end;
//=============================================================================




//=============================================================================
function TJBlokField.bLoad: boolean;
//=============================================================================
var
  bOk: boolean;
  Context: TCONTEXT;
  JBlok: TJBLOK;
  JScreen: TJSCREEN;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokField.bLoad(p_saJBlkF_JBlokfField_UID: ansistring): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JBlok:=TJBLOK(lpJBlok);
  JScreen:=TJSCREEN(JBlok.lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203161825,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203161826, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=bJAS_Load_JBlokField(Context, JBlok.DBC, rJBlokField,false);
  if not bOk then
  begin
    JAS_LOG(Context,cnLog_Error,201203161105,'Trouble loading JBlokField Record','',SOURCEFILE);
  end;

  if bOk then
  begin
    if u8Val(rJBlokField.JBlkF_JColumn_ID)>0 then
    begin
      rJColumn.JColu_JColumn_UID:=rJBlokField.JBlkF_JColumn_ID;
      bOk:=bJAS_Load_JColumn(Context,JBlok.DBC, rJColumn,false);
      if not bOk then
      begin
        bOk:=true;
        JAS_LOG(Context,cnLog_Warn,201203161106,'Trouble loading JColumn Record. '+
          'JBlkF_JBlokField_UID: '+rJBlokField.JBlkF_JBlokField_UID+' '+
          'JBlkF_JColumn_ID:'+rJBlokField.JBlkF_JColumn_ID,'',SOURCEFILE);
        with rJColumn do begin
          JColu_Name                    :=JColu_JColumn_UID;
          JColu_JCaption_ID             :='2012040717150310253';// ansistring;
        end;//with
      end;

      if bOk then
      begin
        if rJColumn.JColu_LUF_Value='NULL' then
        begin
          rJColumn.JColu_LUF_Value:='';
        end;
      end;
    end;

    if bOk then
    begin
      saCaption:='';
      if u8Val(rJBlokField.JBlkF_JCaption_ID)>0 then
      begin
        bOk:=bJASCaption(Context,rJBlokField.JBlkF_JCaption_ID, saCaption, rJBlokField.JBlkF_JBlokField_UID);
        if not bOk then
        begin
          JAS_LOG(Context,cnLog_Error,201203162121,'Trouble loading JCaption','',SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        if (u8Val(rJBlokField.JBlkF_JColumn_ID)>0) and ((saCaption='') or (saCaption=rJBlokField.JBlkF_JBlokField_UID)) then
        begin
          if (u8Val(rJColumn.JColu_JCaption_ID)>0) then
          begin
            bOk:=bJASCaption(Context,rJColumn.JColu_JCaption_ID, saCaption, rJColumn.JColu_Name);
            if not bOk then
            begin
              JAS_LOG(TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context,cnLog_Error,201203162122,'Trouble loading JCaption','',SOURCEFILE);
            end;
          end
          else
          begin
            saCaption:=rJColumn.JColu_Name;
          end;
        end;
      end;
    end;
  end;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203161827,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



















//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBlokField STUFF








//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//=============================================================================
constructor TJBLOK.create(p_lpDS: pointer; p_JBlok_JBlok_UID: ansistring);
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  jbf: TJBlokfield;
  jbb: TJBlokButton;
  u2Pos: word;

  // SHORTHAND
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  // SHORTHAND


{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.create(p_lpDS: pointer; p_JBlok_JBlok_UID: ansistring);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(p_lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171744,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171744, sTHIS_ROUTINE_NAME);{$ENDIF}

  lpDS:=p_lpDS;
  DBC:=Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  FXDL:=JFC_XDL.Create;
  BXDL:=JFC_XDL.Create;

  // ------------- OUTPUT
  saHeader:='';
  saSectionTop:='';
  saSectionMiddle:='';
  saSectionBottom:='';
  saContent:='';
  saFooter:='';
  // ------------- OUTPUT

  saButtons:=''; // Where buttons Are Rendered then placed into templates
  uMode:=cnJBlokMode_View;
  bMultiMode:=false;
  bPreventSaveButton:=false;

  clear_JBlok(rJBlok);
  rJBlok.JBlok_JBlok_UID:=p_JBlok_JBlok_UID;
  bOk:=bJAS_Load_JBlok(Context, DBC, rJBlok, false);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201210011751,'TJBLOK.create call to bJAS_Load_JBlok Failed - ScreenID:' +
      JScreen.rJScreen.JScrn_JScreen_UID+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
  end;


  // Fix Up icons and Load the Caption
  if bOk then
  begin
    if rJBlok.JBlok_IconSmall='NULL' then rJBlok.JBlok_IconSmall:='';
    if rJBlok.JBlok_IconLarge='NULL' then rJBlok.JBlok_IconLarge:='';

    bOk:=bJASCaption(Context, rJBlok.JBlok_JCaption_ID, saCaption, rJBlok.JBlok_Name);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203172056, 'Trouble loading JBlok Caption.','',SOURCEFILE);
    end;
  end;
  // Fix Up icons and Load the Caption

  // LOAD JTable --------------------------------------------------------------
  if bOk then
  begin
    if u8Val(rJBlok.JBlok_JTable_ID)>0 then
    begin
      //JAS_LOG(Context, nLog_Debug, 201203172032, 'TJBLOK.create - Loading JTable into JScreen.rJTable.','',SOURCEFILE);
      clear_jtable(rJTable);
      rJTable.JTabl_JTable_UID:=rJBlok.JBlok_JTable_ID;
      bOk:=bJAS_Load_JTable(Context, DBC, rJTable, false);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201203172032, 'Trouble loading JTable for current JBlok.','',SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_HasPermission(Context, u8Val(rJTable.JTabl_View_JSecPerm_ID));
        if not bOk then
        begin
          JAS_LOG(Context, cnLog_Error, 201211051336,'You are not authorized to view data from the table in this screen.',
            'Table: '+rJTable.JTabl_Name+' View Perm Req: '+rJTable.JTabl_View_JSecPerm_ID,SOURCEFILE);
        end;
      end;
      
      if bOk then
      begin
        clear_Audit(rAudit,rJTable.JTabl_ColumnPrefix);
        rAudit.saUID:=Context.CGIENV.DataIn.Get_saValue('UID');
        bView:=u8Val(rJTable.JTabl_JTableType_ID)=2;// 2=VIEW TYPE (1=Table)
      end;
    end;
    //else
    //begin
    //  JAS_LOG(Context, nLog_Debug, 201209280347,'No TABLE associated with JBlok: '+rJBlok.JBlok_JBlok_UID, '',SOURCEFILE);
    //end;
  end;
  saPerm_JColu_Name:=DBC.saGetColumn(pointer(DBC), rJTable.JTabl_Perm_JColumn_ID,201210020208);
  TGT:=Context.DBCon(u8Val(rJTable.JTabl_JDConnection_ID));
  // LOAD JTable --------------------------------------------------------------


  // LOAD BUTTONS --------------------------------------------------------------
  if bOk then
  begin
    saQry:='select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID='+
      DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) +' AND JBlkB_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true)+' ORDER BY JBlkB_Position_u';
    //AS_LOG(Context, cnLog_ebug, 201203171926,'Button Query: '+saQry, '',SOURCEFILE);
    bOk:=rs.open(saQry, DBC,201503161503);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203171926,'Trouble with Query.', '',SOURCEFILE, DBC, rs);
    end;
  end;

  if bOk then
  begin
    if not rs.eol then
    begin
      repeat
        jbb:=TJBlokButton.Create(self, rs.fields.Get_saValue('JBlkB_JBlokButton_UID'));
        bOk:=not jbb.bProblem;
        if not bOk then
        begin
          JAS_LOG(Context, cnLog_Warn, 201003171926,'BAD Button: '+rs.fields.Get_saValue('JBlkB_Name'), '',SOURCEFILE);
          jbb.destroy;
        end;
        if bOk then
        begin
          //AS_LOG(Context, cnLog_ebug, 201103171926,'GOOD Button: '+rs.fields.Get_saValue('JBlkB_Name'), '',SOURCEFILE);
          BXDL.AppendItem_lpPtr(pointer(jbb));
          BXDL.Item_saName:=jbb.rJBlokButton.JBlkB_Name;
          BXDL.Item_saValue:=jbb.rJBlokButton.JBlkB_CustomURL;
          BXDL.Item_saDesc:=jbb.rJBlokButton.JBlkB_JButtonType_ID;
        end;
      until (not bOk) or (not rs.movenext);
    end;
  end;
  rs.close;
  // LOAD BUTTONS --------------------------------------------------------------

  if bOk and JScreen.bEditMode and (JScreen.EDIT_JBLOK_JBLOK_UID=rJBlok.JBlok_JBlok_UID) and
    ((JScreen.EDIT_ACTION='ADD') or (JScreen.EDIT_ACTION='DELETE')) then
  begin
    bOk:=bEdit_AddDelete;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011752,'TJBLOK.create bEdit_AddDelete is false - ScreenID:' +
        JScreen.rJScreen.JScrn_JScreen_UID+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
    end;
  end;  

  // LOAD FIELDS --------------------------------------------------------------
  if bOk and (not JScreen.bPAgeCompleted) then
  begin
    saQry:='select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID='+
      DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) +' AND JBlkF_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true)+' ORDER BY JBlkF_Position_u';
    bOk:=rs.open(saQry, DBC,201503161504);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203162237,'Trouble with Query.','',SOURCEFILE, DBC, rs);
    end;

    if bOk then
    begin
      if not rs.eol then
      begin
        u2Pos:=1;
        repeat
          jbf:=TJBlokField.Create(self,rs.fields.Get_saValue('JBlkF_JBlokField_UID'));
          bOk:=not jbf.bProblem;
          if not bOk then
          begin
            jbf.destroy;
          end;

          if bOk then
          begin
            if u2Val(jbf.rJBlokField.JBlkF_Position_u)<>u2Pos then
            begin
              jbf.rJBlokField.JBlkF_Position_u:=inttostr(u2Pos);
              bOk:=bJAS_Save_JBlokField(Context,DBC, jbf.rJBlokField,false,false);
              if not bOk then
              begin
                JAS_LOG(Context, cnLog_Error, 201203201727,'Unable to fix bad JBlokField Position.',
                  'JBlkF_JBlokField_UID: '+jbf.rJBlokField.JBlkF_JBlokField_UID,SOURCEFILE);
                jbf.destroy;
              end;
            end;
            u2Pos+=1;
          end;

          if bOk then
          begin
            FXDL.AppendItem_lpPtr(pointer(jbf));
            FXDL.Item_saName:=TJBlokField(FXDL.Item_lpPtr).rJColumn.JColu_Name;
            FXDL.Item_saValue:=TJBlokField(FXDL.Item_lpPtr).saValue;
            
            JFC_XDLITEM(FXDL.lpItem).UID:=u8Val(jbf.rJBlokField.JBlkF_JBlokField_UID);
            if u8Val(jbf.rJBlokField.JBlkF_JColumn_ID)>0 then
            begin
              if not rAudit.bUse_CreatedBy_JUser_ID  then
              begin
                if rAudit.saFieldName_CreatedBy_JUser_ID  = JBF.rJColumn.JColu_Name then
                begin
                  rAudit.bUse_CreatedBy_JUser_ID :=true;
                end;
              end;
              if not rAudit.bUse_Created_DT then rAudit.bUse_Created_DT         :=( rAudit.saFieldName_Created_DT          = JBF.rJColumn.JColu_Name );
              if not rAudit.bUse_ModifiedBy_JUser_ID then
              begin
                if rAudit.saFieldName_ModifiedBy_JUser_ID = JBF.rJColumn.JColu_Name then
                begin
                  rAudit.bUse_ModifiedBy_JUser_ID:=true;
                end;
              end;
              if not rAudit.bUse_Modified_DT         then rAudit.bUse_Modified_DT        :=( rAudit.saFieldName_Modified_DT         = JBF.rJColumn.JColu_Name );
              if not rAudit.bUse_DeletedBy_JUser_ID  then
              begin
                rAudit.bUse_DeletedBy_JUser_ID :=( rAudit.saFieldName_DeletedBy_JUser_ID  = JBF.rJColumn.JColu_Name );
              end;
              if not rAudit.bUse_Deleted_DT          then rAudit.bUse_Deleted_DT         :=( rAudit.saFieldName_Deleted_DT          = JBF.rJColumn.JColu_Name );
              if not rAudit.bUse_Deleted_b           then rAudit.bUse_Deleted_b          :=( rAudit.saFieldName_Deleted_b           = JBF.rJColumn.JColu_Name );
            end;
          end;
        until (not bOk) or (not rs.movenext);
      end;
    end;
    rs.Close;
  end;
  // LOAD FIELDS --------------------------------------------------------------

  // GET PRIMARY KEY COLUMN ---------------------------------------------------
  if bOk then
  begin
    saQry:='select JColu_JColumn_UID from jcolumn where JColu_JTable_ID='+DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID)+
      ' and JColu_PrimaryKey_b='+DBC.saDBMSBoolScrub(true);
    bOk:=rs.open(saQry, DBC,201503161505);
    if not bOk then
    begin
      JAS_LOG(TJSCREEN(lpDS).Context, cnLog_Error, 201203220156,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_LOG(TJSCREEN(lpDS).Context, cnLog_Error, 201212052350,
        'Unable to locate primary key column for table: '+rJTable.JTabl_Name,
        'Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    clear_jcolumn(rJColumn_Primary);
    rJColumn_Primary.JColu_JColumn_UID:=rs.fields.Get_saValue('JColu_JColumn_UID');
    bOk:=bJAS_Load_JColumn(Context, DBC, rJColumn_Primary, false);
    if not bOk then
    begin
      JAS_LOG(TJSCREEN(lpDS).Context, cnLog_Error, 201203172046,
        'Trouble loading Primary Key column.','Table ID:'+rJTable.JTabl_JTable_UID+' ColID:'+rJColumn_Primary.JColu_JColumn_UID+' rs.eol:'+saTRueFalse(rs.eol),SOURCEFILE);
    end;
  end;
  rs.close;
  // GET PRIMARY KEY COLUMN ---------------------------------------------------

  if bOk and (not JScreen.bPageCompleted) and JScreen.bEditMode and (JScreen.EDIT_JBLOK_JBLOK_UID=rJBlok.JBlok_JBlok_UID) AND
    ((JScreen.EDIT_ACTION='MOVEDOWN')or(JScreen.EDIT_ACTION='MOVEUP')or(JScreen.EDIT_ACTION='MOVELEFT')or(JScreen.EDIT_ACTION='MOVERIGHT')) then
  begin
    bOk:=bEdit_Move;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011753,'TJBLOK.create bEdit_Move is false - ScreenID:' +
        JScreen.rJScreen.JScrn_JScreen_UID+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
    end;
  end;

  // DOUBLE CHECK for Deleted_b field if not found yet (done this way to avoid extra db calls)
  if bOk and (not JScreen.bPageCompleted) then
  begin
    with rAudit do begin
      if not bUse_CreatedBy_JUser_ID  then bUse_CreatedBy_JUser_ID   := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_CreatedBy_JUser_ID  ,201210020051);
      if not bUse_Created_DT          then bUse_Created_DT           := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_Created_DT          ,201210020052);
      if not bUse_ModifiedBy_JUser_ID then bUse_ModifiedBy_JUser_ID  := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_ModifiedBy_JUser_ID ,201210020053);
      if not bUse_Modified_DT         then bUse_Modified_DT          := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_Modified_DT         ,201210020054);
      if not bUse_DeletedBy_JUser_ID  then bUse_DeletedBy_JUser_ID   := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_DeletedBy_JUser_ID  ,201210020055);
      if not bUse_Deleted_DT          then bUse_Deleted_DT           := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_Deleted_DT          ,201210020056);
      if not bUse_Deleted_b           then bUse_Deleted_b            := TGT.bColumnExists(rJTable.JTabl_Name, saFieldName_Deleted_b           ,201210020057);

      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saUID                          '+ saUID                                       ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_CreatedBy_JUser_ID '+ saFieldName_CreatedBy_JUser_ID              ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Created_DT         '+ saFieldName_Created_DT                      ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_ModifiedBy_JUser_ID'+ saFieldName_ModifiedBy_JUser_ID             ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Modified_DT        '+ saFieldName_Modified_DT                     ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_DeletedBy_JUser_ID '+ saFieldName_DeletedBy_JUser_ID              ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Deleted_DT         '+ saFieldName_Deleted_DT                      ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Deleted_b          '+ saFieldName_Deleted_b                       ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_CreatedBy_JUser_ID        '+ saTrueFalse(bUse_CreatedBy_JUser_ID)        ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Created_DT                '+ saTrueFalse(bUse_Created_DT)                ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_ModifiedBy_JUser_ID       '+ saTrueFalse(bUse_ModifiedBy_JUser_ID)       ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Modified_DT               '+ saTrueFalse(bUse_Modified_DT)               ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_DeletedBy_JUser_ID        '+ saTrueFalse(bUse_DeletedBy_JUser_ID)        ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Deleted_DT                '+ saTrueFalse(bUse_Deleted_DT)                ,'',SOURCEFILE);
      //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Deleted_b                 '+ saTrueFalse(bUse_Deleted_b)                 ,'',SOURCEFILE);
    end;
  end;
  // DOUBLE CHECK for Deleted_b field if not found yet

  rs.Destroy;
  bProblem:=not bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}{Context.JThread.DBOUT(201203171745,sTHIS_ROUTINE_NAME,SOURCEFILE);}{$ENDIF}
end;
//=============================================================================




//=============================================================================
destructor TJBLOK.Destroy;
//=============================================================================
{IFDEF DEBUGTHREADBEGINEND}
  //var Context: TContext;
{ELSE}
   {IFDEF TRACKTHREAD}
   //  var Context: TContext;
   {ENDIF}
{ENDIF}




{IFDEF ROUTINENAMES}
//  var sTHIS_ROUTINE_NAME: String;
{ENDIF}
Begin
{IFDEF ROUTINENAMES}
//sTHIS_ROUTINE_NAME:='TJBLOK.Destroy;';
{ENDIF}
{IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}

{IFDEF DEBUGTHREADBEGINEND}
//  Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
{ELSE}
   {IFDEF TRACKTHREAD}
   //  Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
   {ENDIF}
{ENDIF}


{IFDEF DEBUGTHREADBEGINEND}
   //Context.JThread.DBIN(201203171046,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
{IFDEF TRACKTHREAD}
  //Context.JThread.TrackThread(201203171047, sTHIS_ROUTINE_NAME);
{ENDIF}

  if FXDL.MoveFirst then
  begin
    repeat
      TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr).Destroy;
    until not fxdl.movenext;
  end;
  FXDL.Destroy;

  if BXDL.MoveFirst then
  begin
    repeat
      TJBLOKBUTTON(JFC_XDLITEM(BXDL.lpItem).lpPtr).Destroy;
    until not Bxdl.movenext;
  end;
  BXDL.Destroy;
{IFDEF DEBUGLOGBEGINEND}
//  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
{IFDEF DEBUGTHREADBEGINEND}
  //Context.JThread.DBOUT(201203171747,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
end;
//=============================================================================



//=============================================================================
function TJBLOK.saMode: ansistring;
//=============================================================================
begin
  case integer(uMode) of
  cnJBlokMode_View      : result:='View';
  cnJBlokMode_New       : result:='New';
  cnJBlokMode_Delete    : result:='Delete';
  cnJBlokMode_Save      : result:='Save';
  cnJBlokMode_Edit      : result:='Edit';
  cnJBlokMode_Deleted   : result:='Deleted';
  cnJBlokMode_Cancel    : result:='Cancel';
  else result:='Undefined JBlok Mode';
  end;//switch
end;
//=============================================================================






//=============================================================================
function TJBLOK.bExecute: boolean;
//=============================================================================
var
  bOk: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bExecute: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171748,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171748, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  case u8Val(rJBlok.JBlok_JBlokType_ID) of
  cnJBlokType_Filter: begin Context.bNoWebCache:=true; ExecuteFilterBlok;       end;
  cnJBlokType_Grid  : begin
    Context.bNoWebCache:=true;
    bOk:=bExecuteGridBlok;
  end;
  cnJBlokType_Data  : begin
    Context.bNoWebCache:=true;
    bOk:=bExecuteDataBlok;
    //if not bOk then
    //begin
    //  AS_LOG(CONTEXT, cnLog_Error, 201210011859,'TJBLOK.bExecute Call to bExecuteDataBlok failed. JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
    //end;
  end;
  cnJBlokType_Custom: begin
    bOk:=bExecuteCustomBlok;
    //if not bOk then
    //begin
    //  AS_LOG(CONTEXT, cnLog_Error, 201210011900,'TJBLOK.bExecute Call to bExecuteCustomBlok failed. JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
    //end;
  end;
  else
    begin
      bOk:=false;// Invalid JBlokType ID
      JAS_LOG(CONTEXT, cnLog_Error, 201210011901,'TJBLOK.bExecute - Invalid JBlokType: '+
        rJBlok.JBlok_JBlokType_ID+'  JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
    end;
  end;//switch
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171749,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
procedure TJBLOK.RenderButtons;
//=============================================================================
{IFDEF ROUTINENAMES}
//var sTHIS_ROUTINE_NAME: String;
{ENDIF}
Begin
{IFDEF ROUTINENAMES}
//sTHIS_ROUTINE_NAME:='TJBLOK.bExecute: boolean;';
{ENDIF}
{IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
  //JScreen:=TJSCREEN(lpDS);
  //Context:=JScreen.Context;
{IFDEF DEBUGTHREADBEGINEND}
//Context.JThread.DBIN(201203180818,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
{IFDEF TRACKTHREAD}
//Context.JThread.TrackThread(201203180818, sTHIS_ROUTINE_NAME);
{ENDIF}

  If BXDL.MoveFirst Then
  Begin
    saButtons+='<ul class="jas-blok-buttons">'+csCRLF;
    repeat
      saButtons+=TJBLOKBUTTON(JFC_XDLITEM(BXDL.lpItem).lpPtr).saRender;
    Until (not BXDL.MoveNext);
    saButtons+='</ul>'+csCRLF;
  End;

{IFDEF DEBUGLOGBEGINEND}
// DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
{IFDEF DEBUGTHREADBEGINEND}
//Context.JThread.DBOUT(201203180819,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
end;
//=============================================================================

















//=============================================================================
function TJBLOK.bEdit_AddDelete: boolean;
//=============================================================================
var
  bOk: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  XDL: JFC_XDL;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  saJColu_JCaption_ID: ansistring;
  saMyCaption: ansistring;
  saJColu_Name: ansistring;
  rJBlokField_New: rtJBlokfield;
  u2Pos: word;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bEdit_AddDelete: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203201303,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203201303, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;
  XDL:=nil;
  rs:=JADO_RECORDSET.Create;
  // EDIT_JBLKF_JBLOKFIELD_UID
  if JScreen.EDIT_ACTION='ADD' then
  begin
    if not Context.CGIENV.DataIn.FoundItem_saName('ADDBLOKFIELD',true) then
    begin
      XDL:=JFC_XDL.Create;

      // LOAD UP XDL
      XDL.AppendItem_saName_N_saValue('','0');
      XDL.Item_i8User:=B00;//SELECTABLE
      saQry:='SELECT JColu_JColumn_UID, JColu_JCaption_ID, JColu_Name from jcolumn '+
        'WHERE JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true) + ' AND '+
        'JColu_JTable_ID=' + DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID);
      bOk:=rs.Open(saQry, DBC,201503161506);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203201336,'Trouble with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
      end;
      if bOk and (not rs.Eol) then
      begin
        repeat
          saJColu_JCaption_ID:=rs.fields.Get_saValue('JColu_JCaption_ID');
          saJColu_Name:=rs.fields.Get_saValue('JColu_Name');
          if u8Val(saJColu_JCaption_ID)>0 then
          begin
            bOk:=bJASCaption(Context, saJColu_JCaption_ID, saMyCaption,saJColu_Name);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201203201337,'Trouble getting Caption','',SOURCEFILE);
            end;
          end
          else
          begin
            saMyCaption:=saJColu_Name;
          end;
          if bOk then
          begin
            XDL.AppendItem_saName_N_saValue(saMyCaption,rs.Fields.Get_saValue('JColu_JColumn_UID'));
            XDL.Item_i8User:=B00;//SELECTABLE
          end;
        until (not bOk) or (not rs.movenext);
      end;
      rs.close;

      // NOW REMOVE ONES ALREADY IN OUR JBLOKFIELDS for this JBlok
      if bOk then
      begin
        saQry:='select JBlkF_JColumn_ID from jblokfield '+
          'WHERE JBlkF_Deleted_b<>'+DBC.saDBMSBoolScrub(true) + ' AND '+
          'JBlkF_JBlok_ID='+DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+' AND '+
          'JBlkF_JColumn_ID<>0';
        bOk:=rs.open(saQry, DBC,201503161507);
        if not bOk then
        begin
          JAS_Log(Context,cnLog_Error,201203201338,'Trouble with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
        end;
      end;

      if bOk and (not rs.eol) then
      begin
        repeat
          if XDL.FoundItem_saValue(rs.fields.Get_saValue('JBlkF_JColumn_ID')) then
          begin
            XDL.DeleteItem;
          end;
        until (not bOk) or (not rs.movenext);
      end;
      rs.Close;
      XDL.SortItem_saName(false,true);
      XDL.MoveFirst;
      XDL.Item_saName:='Custom JBlokField';
      if bOk then
      begin
        WidgetList(
          Context,                         //  p_Context: TCONTEXT;
          'ADDBLOKFIELD',                  //  p_sWidgetName: String;
          'Select JBlokField Type to Add', //  p_sWidgetCaption: String;
          '',                              //  p_saDefaultValue: AnsiString;
          inttostr(XDL.ListCount),         //  p_sSize: string;
          true,                            //  p_bMultiple: boolean;
          true,                            //  p_bEditMode: Boolean;
          grJASConfig.bDataOnRight,
          XDL,                             //  p_XDL: JFC_XDL;
          false,                           //  p_bRequired: boolean
          false,
          false,
          '',//p_saOnBlur: ansistring;
          '',//p_saOnChange: ansistring;
          '',//p_saOnClick: ansistring;
          '',//p_saOnDblClick: ansistring;
          '',//p_saOnFocus: ansistring;
          '',//p_saOnKeyDown: ansistring;
          '',//p_saOnKeypress: ansistring;
          '' //p_saOnKeyUp: ansistring
        );
      end;
      XDL.Destroy;XDL:=nil;
      Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDIT_ACTION@]','ADD');
      Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JBLOK_NAME@]',rJBlok.JBlok_Name);
      Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDIT_JBLOK_JBLOK_UID@]',rJBlok.JBlok_JBlok_UID);
      if JScreen.bMiniMode then
      begin
        Context.saPage:=saGetPage(Context,'sys_area_bare','screenblokfieldadd','MAIN',false,'',201203201441);
      end
      else
      begin
        Context.saPage:=saGetPage(Context,'sys_area','screenblokfieldadd','MAIN',false,'',201203201441);
      end;
      JScreen.bPageCompleted:=bOk;
    end
    else
    begin
      u2Pos:=1+DBC.u8GetRowCount('jblokfield','JBlkF_JBlok_ID='+DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+' AND '+
        'JBlkF_Deleted_b<>'+DBC.saDBMSBoolScrub(true),201506171770);

      repeat
        clear_jblokfield(rJBlokField_New);
        //JBlkF_JBlokField_UID              : AnsiString;
        rJBlokField_New.JBlkF_JBlok_ID                    :=rJBlok.JBlok_JBlok_UID;
        rJBlokField_New.JBlkF_JColumn_ID                  :=Context.CGIENV.DataIn.Item_saValue;
        rJBlokField_New.JBlkF_Position_u                  :=inttostr(u2Pos);u2Pos+=1;
        rJBlokField_New.JBlkF_ReadOnly_b                  :='false';

        if u8Val(Context.CGIENV.DataIn.Item_saValue)>0 then
        begin
          saQry:='select '+
            'JColu_JDType_ID, '+
            'JColu_DefinedSize_u,'+
            'JColu_Boolean_b '+
            'from jcolumn where JColu_JColumn_UID='+DBC.saDBMSUIntScrub(Context.CGIENV.DataIn.Item_saValue);
          bOk:=rs.Open(saQry, DBC,201503161508);
          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201203201548,'Trouble with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
          end;
          if bOk then
          begin
            rJBlokField_New.JBlkF_JWidget_ID:=rs.fields.Get_saValue('JColu_JDType_ID');
            rJBlokField_New.JBlkF_Widget_MaxLength_u:=rs.fields.Get_saValue('JColu_DefinedSize_u');
            if u4Val(rJBlokField_New.JBlkF_Widget_MaxLength_u)>40 then rJBlokField_New.JBlkF_Widget_Width:='40' else rJBlokField_New.JBlkF_Widget_Width:=rJBlokField_New.JBlkF_Widget_MaxLength_u;
            if bIsJDTypeDate(u2Val(rJBlokField_New.JBlkF_JWidget_ID)) then
            begin
              rJBlokField_New.JBlkF_Widget_Date_b:='true';
              rJBlokField_New.JBlkF_Widget_Time_b:='true';
            end;
          end;
          rs.close;
        end;

        if bOk then
        begin
          rJBlokField_New.JBlkF_ColSpan_u                   :='1';
          rJBlokField_New.JBlkF_CreatedBy_JUser_ID          :=inttostr(Context.rJUser.JUser_Juser_UID);
          rJBlokField_New.JBlkF_Created_DT                  :=DBC.saDBMSDateScrub(now);
          rJBlokField_New.JBlkF_Deleted_b                   :='false';
          rJBlokField_New.JBlkF_Width_is_Percent_b          :='false';
          rJBlokField_New.JBlkF_Height_is_Percent_b         :='false';
          rJBlokField_New.JBlkF_Required_b                  :='false';
          rJBlokField_New.JBlkF_Visible_b                   :='true';
          rJBlokField_New.JAS_Row_b                         :='false';
          bOk:=bJAS_Save_JBlokField(Context, DBC, rJBlokField_New, false,false);
          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201203201602,'Save JBlokField Failed.','',SOURCEFILE);
          end;
        end;
      until not Context.CGIENV.DataIn.FNextItem_saName('ADDBLOKFIELD',true);
    end;
  end else

  if JScreen.EDIT_ACTION='DELETE' then
  begin
    // GET LOCK
    bOk:=bJAS_LockRecord(Context, DBC.ID,  'jblokfield', JScreen.EDIT_JBLKF_JBLOKFIELD_UID,'0',201501020030);
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201203201653,'Unable to lock record of JBlokField you wish to delete.','',SOURCEFILE);
    end;

    if bOk then
    begin
      bOk:=bJAS_DeleteRecord(Context,DBC, 'jblokfield',JScreen.EDIT_JBLKF_JBLOKFIELD_UID);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203201654,'Trouble removing JBlokField.','',SOURCEFILE);
      end;
    end;

    //KILL LOCK
    bJAS_UnLockRecord(Context, DBC.ID, 'jblokfield', JScreen.EDIT_JBLKF_JBLOKFIELD_UID,'0',201501020031);
  end;

  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203201304,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================















//=============================================================================
function TJBLOK.bEdit_Move: boolean;
//=============================================================================
var
  bOk: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  u2Cols: word;
  u2Pos1: word;
  JBlokField1: TJBLOKFIELD;
  JBlokField2: TJBLOKFIELD;
  s:string;
  lpItem1: pointer;
  lpItem2: pointer;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bEdit_Move: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203201731,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203201731, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  //JAS:=JScreen.JAS;
  //rs:=JADO_RECORDSET.Create;
  JBlokField1:=nil;JBlokField2:=nil;lpItem1:=nil;lpItem2:=nil;

  bOk:=FXDL.FoundItem_UID(u8Val(JScreen.EDIT_JBLKF_JBLOKFIELD_UID));
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201203201741,'Unable to locate submitted JBlokfield.','',SOURCEFILE);
  end;

  if bOk and (FXDL.ListCount>1) then
  begin
    u2Cols:=u2Val(rJBlok.JBlok_Columns_u);
    JBlokField1:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
    u2Pos1:=FXDL.N;
    lpItem1:=FXDL.lpItem;

    if JScreen.EDIT_ACTION='MOVEUP' then
    begin
      if (u2Pos1>u2Cols) and (FXDL.FoundNth(u2Pos1-u2Cols)) then
      begin
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end;
    end else

    if JScreen.EDIT_ACTION='MOVELEFT' then
    begin
      if (u2Pos1>1) and (FXDL.FoundNth(u2Pos1-1)) then
      begin
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end else
      if (u2Pos1=1) then
      begin
        FXDL.MoveLast;
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end;
    end else

    if JScreen.EDIT_ACTION='MOVERIGHT' then
    begin
      if (u2Pos1<FXDL.ListCount) and (FXDL.FoundNth(u2Pos1+1)) then
      begin
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end else
      if (u2Pos1=FXDL.ListCount) then
      begin
        FXDL.MoveFirst;
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end;
    end else

    if JScreen.EDIT_ACTION='MOVEDOWN' then
    begin
      if (u2Pos1<=(FXDL.ListCount-u2Cols)) and (FXDL.FoundNth(u2Pos1+u2Cols)) then
      begin
        JBlokField2:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        lpItem2:=FXDL.lpItem;
      end;
    end;

    if (JBlokField2<>nil) then
    begin
      // SAVE BOTH JBlokField with their new positions
      s:=JBlokField1.rJBlokField.JBlkF_Position_u;
      JBlokField1.rJBlokField.JBlkF_Position_u:=JBlokField2.rJBlokField.JBlkF_Position_u;
      JBlokField2.rJBlokField.JBlkF_Position_u:=s;
      FXDL.SwapItems(lpItem1, lpItem2);

      bOk:=bJAS_Save_JBlokField(Context, DBC, JBlokField1.rJBlokField,false,false);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203201845,'Unable to Save JBlokfield #1','',SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_Save_JBlokField(Context,DBC, JBlokField2.rJBlokField,false,false);
        if not bOk then
        begin
          JAS_Log(Context,cnLog_Error,201203201846,'Unable to Save JBlokfield #2','',SOURCEFILE);
        end;
      end;
    end;
  end;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203201732,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






















//=============================================================================
function TJBLOK.bExecuteCustomBlok: boolean;
//=============================================================================
{IFDEF ROUTINENAMES}
//var sTHIS_ROUTINE_NAME: String;
{ENDIF}
Begin
{IFDEF ROUTINENAMES}
//sTHIS_ROUTINE_NAME:='TJBLOK.bExecuteCustomBlok: boolean;';
{ENDIF}
{IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
  //JScreen:=TJSCREEN(lpDS);
  //Context:=JScreen.Context;
{IFDEF DEBUGTHREADBEGINEND}
//Context.JThread.DBIN(201203171756,sTHIS_ROUTINE_NAME,SOURCEFILE);
{//ENDIF}
{IFDEF TRACKTHREAD}
//Context.JThread.TrackThread(201203171756, sTHIS_ROUTINE_NAME);
{ENDIF}


  result:=true;


{IFDEF DEBUGLOGBEGINEND}
//  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
{IFDEF DEBUGTHREADBEGINEND}
//Context.JThread.DBOUT(201203171757,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
end;
//=============================================================================

















//==============================================================================
function TJBLOK.bPreDelete(
  p_saTable: ansistring;
  p_saUID: ansistring
): boolean;
//==============================================================================
var
  bOk: boolean;
  //JAS: JADO_CONNECTION;
  //rs: JADO_RECORDSET;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  //saRecordID: ansistring;
  //u4Found: Cardinal;
  //u4Removed: Cardinal;
  //bRemoveLast: boolean;
  //i: longint;

  
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bPreDelete: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201205300858,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201205300859, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  //JAS:=JScreen.JAS;
  if TGT.saName='JAS' then
  begin
    if p_saTable = 'jadodbms'         then begin end else
    if p_saTable = 'jadodriver'       then begin end else
    if p_saTable = 'jasident'         then begin end else
    if p_saTable = 'jblok'            then begin bOk:=bPreDel_JBlok(Context, TGT, p_saUID); end else
    if p_saTable = 'jblokbutton'      then begin end else
    if p_saTable = 'jblokfield'       then begin end else
    if p_saTable = 'jbloktype'        then begin end else
    if p_saTable = 'jbuttontype'      then begin end else
    if p_saTable = 'jcaption'         then begin end else
    if p_saTable = 'jcase'            then begin bOk:=bPreDel_JCase(Context, TGT, p_saUID); end else
    if p_saTable = 'jcasecategory'    then begin end else
    if p_saTable = 'jcasepriority'    then begin end else
    if p_saTable = 'jcasesource'      then begin end else
    if p_saTable = 'jcasesubject'     then begin end else
    if p_saTable = 'jcasetype'        then begin end else
    if p_saTable = 'jclickaction'     then begin end else
    if p_saTable = 'jcolumn'          then begin end else
    if p_saTable = 'jcompany'         then begin bOk:=bPreDel_JCompany(Context, TGT, p_saUID); end else
    if p_saTable = 'jcompanypers'     then begin end else
    if p_saTable = 'jdconnection'     then begin end else
    if p_saTable = 'jdebug'           then begin end else
    if p_saTable = 'jdtype'           then begin end else
    if p_saTable = 'jfile'            then begin bOk:=bPreDel_JFile(Context, TGT, p_saUID); end else
    if p_saTable = 'jfiltersave'      then begin bOk:=bPreDel_JFilterSave(Context, TGT, p_saUID); end else
    if p_saTable = 'jfiltersavedef'   then begin end else
    if p_saTable = 'jiconcontext'     then begin bOk:=bPreDel_JIconContext(Context, TGT, p_saUID); end else
    if p_saTable = 'jiconmaster'      then begin end else
    if p_saTable = 'jindustry'        then begin end else
    if p_saTable = 'jinstalled'       then begin bOk:=bPreDel_JInstalled(Context, TGT, p_saUID); end else
    if p_saTable = 'jinterface'       then begin end else
    if p_saTable = 'jinvoice'         then begin bOk:=bPreDel_JInvoice(Context, TGT, p_saUID); end else
    if p_saTable = 'jinvoicelines'    then begin end else
    if p_saTable = 'jjobq'            then begin end else
    if p_saTable = 'jjobtype'         then begin end else
    if p_saTable = 'jlanguage'        then begin end else
    if p_saTable = 'jlead'            then begin bOk:=bPreDel_JLead(Context, TGT, p_saUID); end else
    if p_saTable = 'jleadsource'      then begin end else
    if p_saTable = 'jlock'            then begin end else
    if p_saTable = 'jlog'             then begin end else
    if p_saTable = 'jlogtype'         then begin end else
    if p_saTable = 'jlookup'          then begin end else
    if p_saTable = 'jmail'            then begin end else
    if p_saTable = 'jmenu'            then begin end else // *** TODO ***
    if p_saTable = 'jmodc'            then begin end else
    if p_saTable = 'jmodule'          then begin bOk:=bPreDel_JModule(Context, TGT, p_saUID); end else
    if p_saTable = 'jmoduleconfig'    then begin end else
    if p_saTable = 'jmodulesetting'   then begin bOk:=bPreDel_JModuleSetting(Context, TGT, p_saUID); end else
    if p_saTable = 'jnote'            then begin end else
    if p_saTable = 'jpassword'        then begin end else
    if p_saTable = 'jperson'          then begin bOk:=bPreDel_JPerson(Context, TGT, p_saUID); end else
    if p_saTable = 'jpersonskill'     then begin end else
    if p_saTable = 'jprinter'         then begin end else
    if p_saTable = 'jpriority'        then begin end else
    if p_saTable = 'jproduct'         then begin bOk:=bPreDel_JProduct(Context, TGT, p_saUID);  end else
    if p_saTable = 'jproductgrp'      then begin end else
    if p_saTable = 'jproductqty'      then begin end else
    if p_saTable = 'jproject'         then begin bOk:=bPreDel_JProject(Context, TGT, p_saUID); end else
    if p_saTable = 'jprojectcategory' then begin end else
    if p_saTable = 'jprojectpriority' then begin end else
    if p_saTable = 'jprojectstatus'   then begin end else
    if p_saTable = 'jquicklink'       then begin end else
    if p_saTable = 'jquicknote'       then begin end else
    if p_saTable = 'jscreen'          then begin bOk:=bPreDel_JScreen(Context,TGT,p_saUID); end else
    if p_saTable = 'jscreentype'      then begin end else
    if p_saTable = 'jsecgrp'          then begin bOk:=bPreDel_JSecGrp(Context,TGT,p_saUID); end else
    if p_saTable = 'jsecgrplink'      then begin end else
    if p_saTable = 'jsecgrpuserlink'  then begin end else
    if p_saTable = 'jseckey'          then begin end else
    if p_saTable = 'jsecperm'         then begin bOk:=bPreDel_JSecPerm(Context,TGT,p_saUID); end else
    if p_saTable = 'jsecpermuserlink' then begin end else
    if p_saTable = 'jsession'         then begin bOk:=bPreDel_JSession(Context,TGT,p_saUID); end else
    if p_saTable = 'jsessiondata'     then begin end else
    if p_saTable = 'jsessiontype'     then begin end else
    if p_saTable = 'jskill'           then begin end else
    if p_saTable = 'jstatus'          then begin end else
    if p_saTable = 'jsync'            then begin end else
    if p_saTable = 'jsysmodule'       then begin bOk:=bPreDel_JSysModule(Context,TGT,p_saUID); end else
    if p_saTable = 'jsysmodulelink'   then begin bOk:=bPreDel_JSysModuleLink(Context,TGT,p_saUID); end else
    if p_saTable = 'jtable'           then begin bOk:=bPreDel_JTable(Context,TGT,p_saUID); end else
    if p_saTable = 'jtabletype'       then begin end else
    if p_saTable = 'jtask'            then begin bOk:=bPreDel_JTask(Context, TGT, p_saUID); end else
    if p_saTable = 'jtaskcategory'    then begin end else
    if p_saTable = 'jtaskpriority'    then begin end else
    if p_saTable = 'jteam'            then begin bOk:=bPreDel_JTeam(Context, TGT, p_saUID); end else
    if p_saTable = 'jteammember'      then begin end else
    if p_saTable = 'jtestone'         then begin end else
    if p_saTable = 'jtheme'           then begin end else
    if p_saTable = 'jtimecard'        then begin end else
    if p_saTable = 'jtrak'            then begin end else
    if p_saTable = 'juser'            then begin bOk:=bPreDel_JTeam(Context, TGT, p_saUID); end else
    if p_saTable = 'juserpref'        then begin end else
    if p_saTable = 'juserpreflink'    then begin end else
    if p_saTable = 'jwidget'          then begin end;


  end;// else
  //begin
  //  if TGT.saName='Some Other Connection' then
  //  begin
  //  end;
  //end;
  
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201205300900,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================















/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF






//=============================================================================
procedure TJBLOK.ExecuteFilterBlok;
//=============================================================================
var
  iColumn: longint;
  u2JDTypeID: word;
  u2JWidgetID: word;

  MXDL: JFC_XDL; //For Multiple Values/Multi-Select
  saIncomingName: ansistring;
  bExclude: boolean;

  // SHORTHAND
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  JBlokField: TJBLOKFIELD;
  // SHORTHAND

  //------ FILTER SAVE ABILITY
  bOk: boolean;
  rs: JADO_RECORDSET;
  FSaveXDL: JFC_XDL;
  saQry: ansistring;
  sFSaveUID: string;
  rJFilterSave: rtJFilterSave;
  saFilterSaveFeedback: ansistring;
  bFilterDupe: boolean;
  XML: JFC_XML;
  bFirstLoad: Boolean;//for loading default
  bIncomingFilterFields: boolean;// used to avoice default filters overriding
  // direct URLS meant to show a certain result set.
  //------ FILTER SAVE ABILITY

  //saValueBeforeHandled: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.ExecuteFilterBlok;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171750,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171750, sTHIS_ROUTINE_NAME);{$ENDIF}

  MXDL:=JFC_XDL.Create;
  FSaveXDL:=JFC_XDL.Create;

  if (not TJSCREEN(lpDS).bExportingNow) then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERSHOWING@]',
      trim(lowercase(saTruefalse(bval(Context.CGIENV.DATAIN.Get_saValue('filtershowing'))))));
  end;
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERADMIN_JBLOK_JBLOK_UID@]',rJBlok.JBlok_JBlok_UID);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERCAPTION@]',saCaption);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@DETAILSCREENID@]','SCREENID='+TJSCREEN(lpDS).rJScreen.JScrn_Detail_JScreen_ID);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREEN_HELP_ID@]',TJSCREEN(lpDS).rJScreen.JScrn_Help_ID);
  
  
  
  if Jscreen.bEditMode then
  begin
    if JScreen.bMiniMode then
    begin
      saHeader:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_TemplateMini,'FILTERHEADERADMIN',true,923020100005);
    end
    else
    begin
      saHeader:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'FILTERHEADERADMIN',true,123020100005);
    end;
    with Context.PAGESNRXDL do begin
      AppendItem_SNRPair('[@FILTERADMIN_JBLOK_JBLOK_UID@]',rJBlok.JBlok_JBlok_UID);
    end;//with
  end
  else
  begin
    if JScreen.bMiniMode then
    begin
      saHeader:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_TemplateMini,'FILTERHEADER',true,923020100006);
    end
    else
    begin
      saHeader:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'FILTERHEADER',true,123020100006);
    end;
  end;
  
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTER_HELP_ID@]',rJBlok.JBlok_Help_ID);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTER_JBLOK_ICONLARGE@]',rJBlok.JBlok_IconLarge);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTER_JBLOK_ICONSMALL@]',rJBlok.JBlok_IconSmall);
  if JScreen.bMiniMode then
  begin
    saSectionTop:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_TemplateMini,'FILTERSECTION',true,923020100007);
  end
  else
  begin
    saSectionTop:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'FILTERSECTION',true,123020100007);
  end;

  //------ FILTER SAVE ABILITY ------------------------------------------------------------------------------------------------------
  bFirstLoad:=false;
  bFirstLoad:=NOT Context.CGIENV.DataIn.FoundItem_saName('FILTERSELECTION');
  if not bFirstLoad then
  begin
    sFSaveUID:=Context.CGIENV.DataIn.Get_saValue('FILTERSELECTION');
  end
  else
  begin
    sFSaveUID:='';
  end;
  
  bIncomingFilterFields:=false;
  if bFirstLoad then
  begin
    if Context.CGIENV.DataIn.MoveFirst then
    begin
      repeat
        bIncomingFilterFields:=saLeftStr(Context.CGIENV.DataIn.Item_saName,5)='FBLOK';
      until bIncomingFilterFields or (not Context.CGIENV.DataIn.MoveNext);
    end;
  end;

  rs:=JADO_RECORDSET.Create;
  saFilterSaveFeedback:='';
  clear_jfiltersave(rJFilterSave);
  rJFilterSave.JFtSa_Name:=trim(Context.CGIENV.DataIn.Get_saValue('FSAVENAME'));
  if Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='SAVE' then
  begin
    if not (length(rJFilterSave.JFtSa_Name)>0) then
    begin
      saFilterSaveFeedback:='Filters require a name to be entered.';
    end
    else
    begin
      bFilterDupe:=false;
      saQry:='SELECT JFtSa_JFilterSave_UID, JFtSa_CreatedBy_JUser_ID from jfiltersave '+
        ' WHERE JFtSa_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
        ' JFtSa_Name='+DBC.saDBMSScrub(rJFilterSave.JFtSa_Name) + ' AND '+
        ' JFtSa_JBlok_ID='+DBC.saDBMSUintScrub(rJBlok.JBlok_JBlok_UID) + ' AND '+
        ' (JFtSa_CreatedBy_JUser_ID='+DBC.saDBMSUintScrub(Context.rJUser.JUser_JUser_UID)+' OR '+
        ' JFtSa_Public_b=true)';
      bOk:=rs.open(saQry, DBC,201503161509);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Warn, 201204032030, 'Problem with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
      end;

      if bOk and (not rs.eol) then
      begin
        repeat
          if not bFilterDupe then bFilterDupe:=(u8VAL(rs.fields.Get_saValue('JFtSa_CreatedBy_JUser_ID'))<>Context.rJUser.JUser_JUser_UID);
        until not rs.movenext;
      end;
      rs.close;

      if bOk then
      begin
        if bFilterDupe then
        begin
          saFilterSaveFeedback:='Filter with that name already exists.';
        end
        else
        begin
          saFilterSaveFeedback:='Attempt to save failed.';
          saQry:='SELECT JFtSa_JFilterSave_UID from jfiltersave '+
            ' WHERE JFtSa_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
            ' JFtSa_Name='+DBC.saDBMSScrub(rJFilterSave.JFtSa_Name) + ' AND '+
            ' JFtSa_JBlok_ID='+DBC.saDBMSUintScrub(rJBlok.JBlok_JBlok_UID) + ' AND '+
            ' JFtSa_CreatedBy_JUser_ID='+DBC.saDBMSUintScrub(Context.rJUser.JUser_JUser_UID);
          bOk:=rs.open(saQry, DBC,201503161510);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Warn, 201204032047, 'Problem with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
          end;

          if bOk then
          begin
            if not rs.eol then
            begin
              rJFilterSave.JFtSa_JFilterSave_UID:=rs.fields.Get_saValue('JFtSa_JFilterSave_UID');
            end;
            // name set already
            rJFilterSave.JFtSa_JBlok_ID:=rJBlok.JBlok_JBlok_UID;
            rJFilterSave.JFtSa_Public_b:=Context.CGIENV.DataIn.Get_saValue('FSAVEPUBLIC');
            XML:=JFC_XML.Create;
            if Context.CGIENV.DataIn.MoveFirst then
            begin
              repeat
                if (saLeftStr(Context.CGIENV.DataIn.Item_saName,5)='FBLOK') or
                  (saLeftStr(Context.CGIENV.DataIn.Item_saName,3)='BFS') then
                begin
                  XML.AppendItem_saName_N_saValue(Context.CGIENV.DataIn.Item_saName, Context.CGIENV.DataIn.Item_saValue);
                  XML.Item_bCDATA:=true;
                end;
              until not Context.CGIENV.DataIn.MoveNext;
            end;
            rJFilterSave.JFTSa_XML:=XML.saXML(false,false);
            XML.destroy;XML:=nil;
            bOk:=bJAS_Save_JFilterSave(Context, DBC, rJFilterSave,false,false);
            if not bOk then
            begin
              saFilterSaveFeedback:='Unable to save filter.';
              JAS_LOG(Context, cnLog_Warn, 201204032054, 'Trouble saving jfiltersave','',SOURCEFILE);
            end
            else
            begin
              saFilterSaveFeedback:='Filter Saved Successfully.';
            end;
          end;
          rs.close;
        end;
      end;
    end;
  end else

  if (bFirstLoad or (Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='APPLY')) and (not bIncomingFilterFields) then
  begin
    if bFirstLoad then
    begin
      saQry:='select JFtSD_JFilterSave_ID from jfiltersavedef where '+
        'JFtSD_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
        'JFtSD_CreatedBy_JUser_ID='+DBC.saDBMSUintScrub(Context.rJUser.JUser_JUser_UID)+' AND '+
        'JFtSD_JBlok_ID='+rJBlok.JBlok_JBlok_UID;
      bOk:=rs.open(saQry,DBC,201503161511);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Warn, 201204071156, 'Problem with Query loading default saved filter.','Query: '+saQry,SOURCEFILE);
      end;

      if bOk and (not rs.eol) then
      begin
        sFSaveUID:=rs.fields.Get_saValue('JFtSD_JFilterSave_ID');
      end;
      rs.close;
    end;



    if sFSaveUID<>'' then
    begin
      rJFilterSave.JFtSa_JFilterSave_UID:=sFSaveUID;
      bOk:=bJAS_Load_JFilterSave(Context, DBC, rJFilterSave, false);
      if not bOk then
      begin
        saFilterSaveFeedback:='Unable to load selected filter.';
      end;

      if bOk then
      begin
        if Context.CGIENV.DataIn.Movefirst then
        begin
          //saFilterSaveFeedback:='<br /><b>Before</b><br />'+Context.CGIENV.DataIn.saHTMLTable;
          repeat
            while (saLeftStr(Context.CGIENV.DataIn.Item_saName,5)='FBLOK') or
                  (saLeftStr(Context.CGIENV.DataIn.Item_saName,3)='BFS') or
                  (Context.CGIENV.DataIn.Item_saName='FILTERBUTTON') or
                  (Context.CGIENV.DataIn.Item_saName='FSAVEPUBLIC') or
                  (Context.CGIENV.DataIn.Item_saName='FSAVENAME') or
                  (Context.CGIENV.DataIn.Item_saName='FILTERSELECTION') do
            begin
              Context.CGIENV.DataIn.DeleteItem;
            end;
          until (not Context.CGIENV.DataIn.MoveNext);
          //saFilterSaveFeedback+='<br /><b>Cleaned</b><br />'+Context.CGIENV.DataIn.saHTMLTable;
        end;
        XML:=JFC_XML.Create;
        if XML.bParseXML(rJFilterSave.JFtSa_XML) then
        begin
          if XML.MoveFirst then
          begin
            repeat
              Context.CGIENV.DataIn.AppendItem_saName_N_saValue(XML.Item_saName, XML.Item_saValue);
            until not XML.MoveNext;
          end;
          saFilterSaveFeedback:='Filter Applied Successfully.';
          //saFilterSaveFeedback+='<br /><b>APPLIED FILTER</b><br />'+Context.CGIENV.DataIn.saHTMLTable;
          //saFilterSaveFeedback+='<textarea rows="8" cols="80">'+XML.saXML(false,false)+'</textarea>';
        end
        else
        begin
          saFilterSaveFeedback:='Unable to parse saved filter data.';
        end;
        XML.Destroy;XML:=nil;
      end;
    end;
  end else

  if Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='DELETE' then
  begin
    saQry:='JFtSa_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
          'JFtSa_CreatedBy_JUser_ID='+DBC.saDBMSUintScrub(Context.rJUser.JUser_JUser_UID)+' AND '+
          'JFtSa_JFilterSave_UID='+DBC.saDBMSUIntScrub(sFSaveUID);
    if DBC.u8GetRowCount('jfiltersave',saQry,201506171771)=1 then
    begin
      bOk:=bJAS_DeleteRecord(Context,DBC,'jfiltersave',sFSaveUID);
      if bOk then
      begin
        saQry:='DELETE FROM jfiltersavedef WHERE JFtSD_JFilterSave_ID='+DBC.saDBMSUIntScrub(sFSaveUID);
        bOk:=rs.open(saQry, DBC,201503161512);
        if not bOK then
        begin
          saFilterSaveFeedback:='Trouble removing default filter settings for the deleted filter.';
        end
        else
        begin
          saFilterSaveFeedback:='Filter deleted successfully.';
        end;
        rs.close;
      end
      else
      begin
        saFilterSaveFeedback:='Trouble deleting filter.';
      end;
    end
    else
    begin
      saFilterSaveFeedback:='Unable to comply.';
    end;
  end;



  //============ LOADING SELECTION OF SAVED FILTERS
  // We don't want the bOK from Above effecting this part here so we disregard previous value
  saQry:='SELECT JFtSa_JFilterSave_UID,JFtSa_Name,JFtSa_XML,JFtSa_Public_b from jfiltersave '+
    ' WHERE JFtSa_Deleted_b<>'+DBC.saDBMSBoolScrub(true) + ' AND ' +
    ' JFtSa_JBlok_ID='+DBC.saDBMSUintScrub(rJBlok.JBlok_JBlok_UID)+' AND ' +
    ' (JFtSa_CreatedBy_JUser_ID='+DBC.saDBMSUintScrub(Context.rJUser.JUser_JUser_UID)+' OR '+
    ' JFtSa_Public_b=true) ORDER BY JFtSa_Name';
  bOk:=rs.Open(saQry, DBC,201503161513);
  if not bOk then
  begin
    JAS_LOG(Context, cnLog_Warn, 201204031702, 'Problem with Query related to Saving Filters','Query: '+saQry,SOURCEFILE);
  end;

  FSaveXDL.AppendItem_saName_N_saValue('','');
  FSaveXDL.Item_i8User:=B00+B01+B02;
  if bOk and (not rs.eol) then
  begin
    repeat
      FSaveXDL.AppendItem;
      if bVal(rs.fields.Get_saValue('JFtSa_Public_b')) then
      begin
        FSaveXDL.Item_saName:= '[ '+rs.fields.Get_saValue('JFtSa_Name')+' ]';
      end
      else
      begin
        FSaveXDL.Item_saName:=rs.fields.Get_saValue('JFtSa_Name');
      end;
      FSaveXDL.Item_saValue:=rs.fields.Get_saValue('JFtSa_JFilterSave_UID');
      FSaveXDL.Item_saDesc:=rs.fields.Get_saValue('JFtSa_XML');
      if sFSaveUID=FSaveXDL.Item_saValue then
      begin
        FSaveXDL.Item_i8User:=B00+B01+B02;
      end
      else
      begin
        FSaveXDL.Item_i8User:=B00;
      end;
    until (not rs.movenext);
  end;

  widgetdropdown(Context,
    'FILTERSELECTION',
    'Saved Filters',
    sFSaveUID,
    '1',//height
    false,//multiselect
    true,//editmode
    grJASConfig.bDataOnRight,
    FSaveXDL, //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
    false,  //p_bIfInReadOnly_UseDefaultValueOnly: boolean;
    false, //p_bRequired: boolean;
    false,  //p_bFilterTools: boolean;
    false,  //p_bFilterNot: boolean
    '',//p_saOnBlur: ansistring;
    'FILTERSELECTION_OnChange();',//p_saOnChange: ansistring;
    '',//p_saOnClick: ansistring;
    '',//p_saOnDblClick: ansistring;
    '',//p_saOnFocus: ansistring;
    '',//p_saOnKeyDown: ansistring;
    '',//p_saOnKeypress: ansistring;
    '' //p_saOnKeyUp: ansistring
  );

  WidgetInputBox(
    Context,
    'FSAVENAME',
    'Enter Filter Name',
    'Saved Filter',
    '50',
    '50',
    false,
    true,
    grJASConfig.bDataOnRight,
    true,
    false,
    false,
    '',//p_saOnBlur: ansistring;
    '',//p_saOnChange: ansistring;
    '',//p_saOnClick: ansistring;
    '',//p_saOnDblClick: ansistring;
    '',//p_saOnFocus: ansistring;
    '',//p_saOnKeyDown: ansistring;
    '',//p_saOnKeypress: ansistring;
    '',//p_saOnKeyUp: ansistring;
    '' //p_saOnSelect: ansistring
  );


  WidgetBoolean(
    Context,
    'FSAVEPUBLIC',
    'Public',
    'false',
    '1',
    true,
    false,
    grJASConfig.bDataOnRight,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    '',//p_saOnBlur: ansistring;
    '',//p_saOnChange: ansistring;
    '',//p_saOnClick: ansistring;
    '',//p_saOnDblClick: ansistring;
    '',//p_saOnFocus: ansistring;
    '',//p_saOnKeyDown: ansistring;
    '',//p_saOnKeypress: ansistring;
    '' //p_saOnKeyUp: ansistring
  );

  Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@FILTERSAVEFEEDBACK@]','<div id="FILTERFEEDBACK">'+saFilterSaveFeedback+'</div>');
  rs.close;
  rs.destroy;rs:=nil;
  //------ FILTER SAVE ABILITY (Failure here won't impact rest of screen - logging issues - not raising errors)
  //------ FILTER SAVE ABILITY ------------------------------------------------------------------------------------------------------










  JScreen.saQueryFrom:=' FROM '+rJTable.JTabl_Name+' ';

  if NOT FXDL.MoveFirst then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[#FBLOK#]','');
  end
  else
  begin
    iColumn:=1;
    saContent+='<table border="1">'+csCRLF;
    repeat
      JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
      //====================================================== QUERY BUILD ===================================================================================================
      JBlokField.saValue:=Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID);
      //saValueBeforeHandled:=JBlokfield.saValue;
      bExclude:=(Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT');
      If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)<1 Then JBlokField.rJBlokField.JBlkF_ColSpan_u:='1';
      u2JDTypeID:=u2Val(JBlokField.rJColumn.JColu_JDType_ID);
      u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);
      if u2JWidgetID=0 then u2JWidgetID:=u2JDTypeID;
      If iColumn=1 Then saContent+='<tr>'+csCRLF;

      // GATHER MULTI SELECT VALUES-------------------------------------------
      MXDL.DeleteAll;
      saIncomingName:='FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID;
      if Context.CGIENV.DataIn.FoundItem_saName(saIncomingName) then
      begin
        repeat
          MXDL.AppendItem_saValue(Context.CGIENV.DataIn.Item_saValue);
        until not Context.CGIENV.DataIn.FNextItem_saName(saIncomingName);
      end;
      // GATHER MULTI SELECT VALUES-------------------------------------------

      if (bIsJDTypeBoolean(u2JWidgetID) or
          bIsJDTypeBoolean(u2JDTypeID) or
          bVal(JBlokField.rJColumn.JColu_Boolean_b)) and (JBlokField.saValue<>'') then
      begin
        if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
        JScreen.saQueryWhere+='(';
        MXDL.Movefirst;
        repeat
          if MXDL.ListCount>0 then JBlokField.saValue:=MXDL.Item_saValue;
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name;
          if JBlokField.saValue='NULL' then
          begin
            if bExclude then JScreen.saQueryWhere+=' IS NOT ' else JScreen.saQueryWhere+=' IS ';
            JScreen.saQueryWhere+=JBlokField.saValue + ')';
          end
          else
          begin
            if bExclude then JScreen.saQueryWhere+=' <> ' else JScreen.saQueryWhere+=' = ';
            JScreen.saQueryWhere+=DBC.saDBMSBoolScrub(JBlokField.saValue) + ')';
          end;
          if (MXDL.ListCount>0) and (MXDL.ListCount>MXDL.N) then JScreen.saQueryWhere+=' AND ';
        until not MXDL.MoveNext;
        JScreen.saQueryWhere+=')';
      end else

      if bIsJDTypeNumber(u2JDTypeID) and (JBlokField.saValue<>'') then
      begin
        if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
        JScreen.saQueryWhere+='(';
        MXDL.Movefirst;
        repeat
          if MXDL.ListCount>0 then JBlokField.saValue:=MXDL.Item_saValue;
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name;
          if JBlokField.saValue='NULL' then
          begin
            if bExclude then JScreen.saQueryWhere+=' IS NOT ' else JScreen.saQueryWhere+=' IS ';
            JScreen.saQueryWhere+=JBlokField.saValue + ')';
          end
          else
          begin
            if bExclude then JScreen.saQueryWhere+=' <> ' else JScreen.saQueryWhere+=' = ';
            if bIsJDTypeUInt(u2JDTypeID) then
            begin
              JScreen.saQueryWhere+=DBC.saDBMSUintScrub(JBlokField.saValue) + ')';
            end
            else
            begin
              JScreen.saQueryWhere+=DBC.saDBMSIntScrub(JBlokField.saValue) + ')';
            end;
          end;
          //if (MXDL.ListCount>0) and (MXDL.ListCount>MXDL.N) then JScreen.saQueryWhere+=' AND ';
          if (MXDL.ListCount>0) and (MXDL.ListCount>MXDL.N) then
          begin
            if bExclude then
            begin
              JScreen.saQueryWhere+=' AND ';
            end
            else
            begin
              JScreen.saQueryWhere+=' OR ';
            end;
          end;
        until not MXDL.MoveNext;
        JScreen.saQueryWhere+=')';
      End else

      if bIsJDTypeDate(u2JWidgetID) then
      Begin
        JBlokField.saValue2:=Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'LIMIT');
        If (JBlokField.saValue='') and (JBlokField.saValue2<>'') Then
        Begin
          // DATE <= VALUE2
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+' <= '+DBC.saDBMSDateScrub(JDate(JBlokField.saValue2, 11,1))+')';
        End else

        If (JBlokField.saValue<>'') and (JBlokField.saValue2='') Then
        Begin
          // DATE >= VALUE1
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+'  >= '+DBC.saDBMSDateScrub(JDate(JBlokField.saValue, 11,1))+')';
        End else

        If (JBlokField.saValue<>'') and (JBlokField.saValue2<>'') Then
        Begin
          // DATE >= VALUE1  AND DATE <= VALUE2
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+' >= '+DBC.saDBMSDateScrub(JDate(JBlokField.saValue, 11,1))+')';
          JScreen.saQueryWhere+=' AND ( '+JBlokField.rJColumn.JColu_Name+' <= '+ DBC.saDBMSDateScrub(JDate(JBlokField.saValue2, 11,1))+')';
        End;
      end else

      // If Both Empty - Do Nothing to effect Query filter.
      Begin // treat rest like text
        if  (JBlokField.saValue<>'') then
        begin
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name;
          if JBlokField.saValue='NULL' then
          begin
            if bExclude then JScreen.saQueryWhere+=' IS NOT null )' else JScreen.saQueryWhere+=' IS null )'
          end
          else
          begin
            if bExclude then JScreen.saQueryWhere+=' NOT ';
            JScreen.saQueryWhere+=' like '+DBC.saDBMSScrub(DBC.saDBMSWild+JBlokField.saValue+DBC.saDBMSWild)+')';
          end;
        end;
      End;

      //====================================================== QUERY BUILD ===================================================================================================


      saContent+='<td';
      If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)>1 Then
      begin
        saContent+=' colspan="'+JBlokField.rJBlokField.JBlkF_ColSpan_u+'" ';
      end;
      saContent+=' valign="top" >';

      FilterBlok_CreateWidgets(JBlokField, MXDL);

      if(TJSCREEN(lpDS).bEditMode)then
      begin
        saContent+='<table border="1"><tr><td>';
      end;
      saContent+='[#'+'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'#]';

      // SPECIAL Case For Dual Controls (Date range)
      //saContent+='['+saJDType(iJWidgetID);
      If (u2JWidgetID=cnJDType_dt) Then
      Begin
        saContent+='[#'+'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'LIMIT#]';
      End;
      //saContent+=']';

      {
      saContent+=
        '<br />'+
        'JBlokfield.saValue: '+JBlokfield.saValue+'<br />'+
        'u2JDTypeID: '+saJDType(u2JDTypeID)+'<br />'+
        'u2JDWidgetID: '+saJDType(u2JWidgetID)+'<br />'+
        'u2JDWidgetID: '+saJDType(u2JWidgetID)+'<br />'+
        'saValueBeforeHandled: '+saValueBeforeHandled+'<br />'+
        MXDL.saHTMLTable;
      }


      if(TJSCREEN(lpDS).bEditMode)then
      begin
        saContent+='</td></tr><tr><td>FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'</td></tr><tr><td><table><tr>';
        saContent+='<td><a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+
          JBlokField.rJBlokField.JBlkF_JBlokField_UID+
            ''');"><img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a></td>';
        if u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
        begin
          saContent+='<td><a title="Edit JColumn"    href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+
            JBlokField.rJBlokField.JBlkF_JColumn_ID+''');">'+
            '<img class="image" title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a></td>';
        end;

        saContent+=
          '<td><a title="Left" href="javascript: editcol_left('''+    rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="Left" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a></td>'+
          '<td><a title="Up" href="javascript: editcol_up('''+        rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="Up" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></a></td>'+
          '<td><a title="Down" href="javascript: editcol_down('''+    rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="Down" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></a></td>'+
          '<td><a title="Right" href="javascript: editcol_right('''+  rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="Right" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a></td>'+
          '<td><a title="Delete" href="javascript: editcol_delete('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="Delete" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a></td>'+
          '</tr></table></td></tr></table>';
      end;


      {$IFDEF DEBUGHTML}
      saContent+=
        'DataType:'+                saJDType(u8Val(JBlokField.rJBlokField.JBlkF_JWidget_ID))       +'<br />'+csCRLF+
        'ds.Widget.JBlkF_ReadOnly_b:' +           JBlokField.rJBlokField.JBlkF_ReadOnly_b         +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_MaxLength_u:' +   JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Width:' +       JBlokField.rJBlokField.JBlkF_Widget_Width     +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Height:' +      JBlokField.rJBlokField.JBlkF_Widget_Height    +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Password_b:' +    JBlokField.rJBlokField.JBlkF_Widget_Password_b  +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Date_b:' +        JBlokField.rJBlokField.JBlkF_Widget_Date_b      +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Time_b:' +        JBlokField.rJBlokField.JBlkF_Widget_Time_b      +'<br />'+csCRLF+
        'ds.Widget.JBlkF_Widget_Mask:' +          JBlokField.rJBlokField.JBlkF_Widget_Mask        +'<br />'+csCRLF+
        'ds.Widget.JBlkF_ColSpan_u:' +            JBlokField.rJBlokField.JBlkF_ColSpan_u          +'<br />'+csCRLF+
        'ds.Widget.saValue:' +                    JBlokField.saValue                              +'<br />'+csCRLF;
      {$ENDIF}

      If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)>1 Then
      Begin
        iColumn:=iColumn+iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u);
      End
      Else
      Begin
        iColumn:=iColumn+1;
      End;
      saContent+='</td>'+csCRLF;
      If iColumn>iVal(rJBlok.JBlok_Columns_u) Then
      Begin
        saContent+='</tr>'+csCRLF;
        iColumn:=1;
      End;
    Until (not FXDL.MoveNext);

    If FXDL.N<=iVal(rJBlok.JBlok_Columns_u)Then
    Begin
      iColumn:=FXDL.N;
      repeat
        iColumn:=iColumn+1;
        {$IFDEF DEBUGHTML}
        saContent+='<td>filler</td>'+csCRLF;
        {$ELSE}
        saContent+='<td></td>'+csCRLF;
        {$ENDIF}
      Until iColumn>iVal(rJBlok.JBlok_Columns_u);
      saContent+='</tr>'+csCRLF;
    End;
    saContent+='</table>'+csCRLF;
  end;
  saContent+='<script>function ResetForm(){'+JScreen.saResetForm+'};'+
    'function Custom(p_url){window.open(p_url,"","width=700,scrollbars=yes,resizable=yes");};</script>'+csCRLF;
  RenderButtons;

  JScreen.saTemplate:=saSNRStr(TJSCREEN(lpDS).saTemplate, '[$SCREENHEADER$]', JScreen.saScreenHeader);
  JScreen.saTemplate:=saSNRStr(TJSCREEN(lpDS).saTemplate, '[$BLOKBUTTONS$]', saButtons);
  JScreen.saTemplate:=saSNRStr(TJSCREEN(lpDS).saTemplate, '[$BLOKFILTERSECTION$]',
    saSNRStr(saSNRStr(saSectionTop,'[$BLOKFILTERHEADER$]',saHeader),'[$BLOKFILTER$]',saContent));

  MXDL.Destroy;
  FSaveXDL.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171751,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
procedure TJBLOK.FilterBlok_CreateWidgets(JBlokField: TJBLOKFIELD; p_MXDL: JFC_XDL);
//=============================================================================
var
  u2JWidgetID: word;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  //sa: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bCreateWidgets(JBlokField: TJBLOKFIELD);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171833,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171834, sTHIS_ROUTINE_NAME);{$ENDIF}

  If u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 Then
  Begin
    // Assign Default Widget and Parameters for Column Data Type in question.
    // Note: Administration Page For Creating Screen Blocks, specifically
    // the part where individual fields are added - need to flow same logic -
    // for default parameters and Widget Types as coded here.
    u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);
    If u2JWidgetID=0 then JBlokField.rJBlokField.JBlkF_JWidget_ID:=JBlokField.rJColumn.JColu_JDType_ID;
    u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);

    // 19/2015/03 12:25 PM
    if pos('/',JBlokField.saValue)=3 then
    begin
      JBlokField.saValue:=JDATE(JBlokField.saValue,1,22);
    end;


    if bIsJDTypeDate(u2JWidgetID) then
    Begin
      WidgetDateTime(Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Date_b,
        JBlokField.rJBlokField.JBlkF_Widget_Time_b,
        JBlokField.rJBlokField.JBlkF_Widget_Mask,
        true,
        grJASConfig.bDataOnRight,
        false,
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
      // TODO: Make hardcoded caption come from the CAPTIONS TABLE to
      // make way for lanuguage specific stuff.
      WidgetDateTime(
        Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'LIMIT',
        'Select Date Range',
        Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'LIMIT'),
        JBlokField.rJBlokField.JBlkF_Widget_Date_b,
        JBlokField.rJBlokField.JBlkF_Widget_Time_b,
        JBlokField.rJBlokField.JBlkF_Widget_Mask,
        true,
        grJASConfig.bDataOnRight,
        false,
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'LIMIT").value="";';
    End else


    if bIsJDTypeBoolean(u2JWidgetID) then
    Begin
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='1';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)>iVal(JBlokField.rJColumn.JColu_DefinedSize_u) Then
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='1';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='1';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
      WidgetBoolean(
        Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Height,
        true,
        True,
        grJASConfig.bDataOnRight,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        bVal(JBlokfield.rJBlokField.JBlkF_MultiSelect_b),
        JBlokField.ListXDL.FoundItem_saValue(''),
        JBlokField.ListXDL.FoundItem_saValue('NULL'),
        JBlokField.ListXDL.FoundItem_saValue('TRUE'),
        JBlokField.ListXDL.FoundItem_saValue('FALSE'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").selectedIndex=0;';
    End else

    if bIsJDTypeNumber(u2JWidgetID) then
    Begin
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
      WidgetInputBox(
        Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        bval(JBlokField.rJBlokField.JBlkF_Widget_Password_b),
        true,
        grJASConfig.bDataOnRight,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
        JBlokField.rJBlokField.JBlkF_Widget_OnSelect
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
    End else

    if bIsJDTypeMemo(u2JWidgetID) then
    Begin
      If (iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1) OR
        (iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)>iVal(JBlokField.rJColumn.JColu_DefinedSize_u)) Then
      Begin
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=JBlokField.rJColumn.JColu_DefinedSize_u;
      End;
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='4';
      WidgetTextArea(Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        JBlokField.rJBlokField.JBlkF_Widget_Height,
        true,
        false,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
    End else

    if (cnJWidget_DropDown=u2JWidgetID) or
       (cnJWidget_Lookup=u2JWidgetID) or
       (cnJWidget_ComboBox=u2JWidgetID) or
       (cnJWidget_LookupComboBox=u2JWidgetID) then
    begin
      if Context.bPopulateLookUpList(
        rJTable.JTabl_Name,
        JBlokField.rJColumn.JColu_Name,
        JBlokField.ListXDL,
        JBlokfield.saValue,
        ((cnJWidget_Lookup=u2JWidgetID) or (cnJWidget_LookupComboBox=u2JWidgetID))
      ) then
      begin
        //------------------------------------------------------------------
        // MAKE OPTIONS SELECTED THAT SHOULD BE: NOT Just JBlokField.saValue
        //------------------------------------------------------------------
        if JBlokField.ListXDL.Movefirst then
        begin
          repeat
            if p_MXDL.FoundItem_saValue(JBlokField.ListXDL.Item_saValue) then
            begin
              JBlokField.ListXDL.Item_i8User:=(JBlokField.ListXDL.Item_i8User and (B00+B02)) + B01;
            end;
            if JBlokField.ListXDL.Item_saValue=JBlokField.saValue then
            begin
              JBlokField.ListXDL.Item_i8User:=(JBlokField.ListXDL.Item_i8User and (B00+B01)) + B02;
            end;
          until (not JBlokField.ListXDL.MoveNext);
        end;
        //------------------------------------------------------------------


        if (cnJWidget_DropDown=u2JWidgetID) or
           (cnJWidget_Lookup=u2JWidgetID) or
           (cnJWidget_LookupComboBox=u2JWidgetID) then
        begin
          //JAS_LOG(Context,cnLog_ebug,201204021957,'Filter WidgetDropDown Field: '+JBlokField.saCaption+
          //  ' JBlokField.ListXDL.ListCount: '+inttostr(JBlokField.ListXDL.ListCount),'',SOURCEFILE);
          //JAS_LOG(Context,cnLog_ebug,201204021957,'JBlokField.rJBlokField.JBlkF_ReadOnly_b: '+JBlokField.rJBlokField.JBlkF_ReadOnly_b+
          //  'bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b): '+saYesNo(bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b))+
          //  'JBlokField.rJBlokField.JBlkF_JBlokField_UID: '+JBlokField.rJBlokField.JBlkF_JBlokField_UID,'',SOURCEFILE);

          if (cnJWidget_LookupComboBox=u2JWidgetID) then
          begin
            widgetComboBox(Context,
              'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b),
              grJASConfig.bDataOnRight,
              JBlokField.ListXDL, //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
              false,
              false,
              true,
              (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
              JBlokField.rJBlokField.JBlkF_Widget_OnSelect
            );
            JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';            
          end
          else
          begin
            widgetdropdown(Context,
              'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Height,
              bVal(JBlokfield.rJBlokField.JBlkF_MultiSelect_b),
              not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b),
              grJASConfig.bDataOnRight,
              JBlokField.ListXDL, //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
              false,
              false,
              true,
              (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
            );
            JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").selectedIndex=0;';
          end;
        end
        else
        begin
          widgetComboBox(Context,
            'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
            JBlokField.saCaption,
            JBlokField.saValue,
            JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
            JBlokField.rJBlokField.JBlkF_Widget_Width,
            not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b),
            grJASConfig.bDataOnRight,
            JBlokField.ListXDL, //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
            false,
            false,
            true,
            (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
            JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
            JBlokField.rJBlokField.JBlkF_Widget_OnChange,
            JBlokField.rJBlokField.JBlkF_Widget_OnClick,
            JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
            JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
            JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
            JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
            JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
            JBlokField.rJBlokField.JBlkF_Widget_OnSelect
          );
          JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'cbo").selectedIndex=0;';
        end;
        
      end
      else
      begin
        Context.PAGESNRXDL.AppendItem_SNRPair('[#'+'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'#]','(JWidget Troubles)');
      end;
    end else

    if cnJWidget_URL=u2JWidgetID then
    begin
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
      WidgetURL(Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        true,
        grJASConfig.bDataOnRight,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
        JBlokField.rJBlokField.JBlkF_Widget_OnSelect
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
    end else

    if cnJWidget_Email=u2JWidgetID then
    begin
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
      WidgetEmail(Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        true,
        grJASConfig.bDataOnRight,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
        JBlokField.rJBlokField.JBlkF_Widget_OnSelect
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
    end else

    Begin  // CATCH ALL - AND TEXT FIELDS
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='20';
      If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
      WidgetInputBox(Context,
        'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID,
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        bval(JBlokField.rJBlokField.JBlkF_Widget_Password_b),
        true,
        grJASConfig.bDataOnRight,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
        JBlokField.rJBlokField.JBlkF_Widget_OnSelect
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'").value="";';
    End;
  End
  else
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[#'+'FBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'#]',JBlokField.rJBlokField.JBlkF_ClickActionData);
  end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171835,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// FILTER STUFF







/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF



//=============================================================================
function TJBLOK.bExecuteGridBlok: boolean;
//=============================================================================
var
  bOk: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  saMulti: ansistring;
  rJTask: rtJTask;
  rJJobQ: rtJJobQ;
  dt: TDATETIME;
  sa: ansistring;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bExecuteGridBlok: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171752,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171752, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  saContent:='';

  saMulti:=Context.CGIENV.DataIn.Get_saValue('MULTI');
  saSectionTop:='';


  // BEGIN ------------------------------------------------------- PREP for BACKGROUND EXPORT
  if bOk and (JScreen.bBackgroundPrepare) then
  begin
    dt:=now;
    // MAKE TASK FOR THIS EXPORT for LATER retrieval
    clear_JTask(rJTask);
    with rJTask do begin
      JTask_JTask_UID                  :='0';
      JTask_Name                       :=rJTable.JTabl_Name+' export';
      JTask_Desc                       :='Task created to allow exporting records for retrieval at a later time when the process has completed.';
      JTask_JTaskCategory_ID           :=inttostr(cnJTaskCategory_Task);
      JTask_JProject_ID                :='NULL';
      JTask_JStatus_ID                 :=inttostR(cnJStatus_NotStarted);
      JTask_Due_DT                     :=saFormatDateTime(csDateTimeFormat,dt);
      JTask_Duration_Minutes_Est       :='NULL';
      JTask_JPriority_ID               :=inttostR(cnJPriority_Normal);
      JTask_Start_DT                   :=saFormatDateTime(csDateTimeFormat,dt);
      JTask_Owner_JUser_ID             :=Context.rJSession.JSess_JUser_ID;
      JTask_SendReminder_b             :='false';
      JTask_ReminderSent_b             :='false';
      JTask_ReminderSent_DT            :='NULL';
      JTask_Remind_DaysAhead_u         :='0';
      JTask_Remind_HoursAhead_u        :='0';
      JTask_Remind_MinutesAhead_u      :='0';
      JTask_Remind_Persistantly_b      :='false';
      JTask_Progress_PCT_d             :='0';
      JTask_JCase_ID                   :='NULL';
      JTask_Directions_URL             :='NULL';
      JTask_URL                        :='NULL';
      JTask_Milestone_b                :='false';
      JTask_Budget_d                   :='NULL';
      JTask_ResolutionNotes            :='';
      JTask_Completed_DT               :='NULL';
      JTask_Related_JTable_ID          :=rJTable.JTabl_JTable_UID;
      JTask_Related_Row_ID             :='NULL';
    end;//with
    bOk:=bJAS_Save_JTask(Context, Context.VHDBC, rJTask, false,false);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201210231218,'Unable to save task record for background data export of '+rJTable.JTabl_Name,'',SOURCEFILE);
    end;

    // MAKE JobQ Item linked to task, copy all CGIENV in
    // so it's used for the export - strip out right side of the
    // export mode.
    if bOk then
    begin
      clear_JJobQ(rJJobQ);
      with rJJobQ do begin
        JJobQ_JJobQ_UID           :='0';
        JJobQ_JUser_ID            :=Context.rJSession.JSess_JUser_ID;
        JJobQ_JJobType_ID         :=inttostr(cnJJobType_General);
        JJobQ_Start_DT            :=saFormatDateTime(csDateTimeFormat,dt);
        JJobQ_ErrorNo_u           :='NULL';
        JJobQ_Started_DT          :='NULL';
        JJobQ_Running_b           :='false';
        JJobQ_Finished_DT         :='NULL';
        JJobQ_Name                :=rJTable.JTabl_Name+' export';
        JJobQ_Repeat_b            :='false';
        JJobQ_RepeatMinute        :='NULL';
        JJobQ_RepeatHour          :='NULL';
        JJobQ_RepeatDayOfMonth    :='NULL';
        JJobQ_RepeatMonth         :='NULL';
        JJobQ_Completed_b         :='false';
        JJobQ_Result_URL          :='NULL';
        JJobQ_ErrorMsg            :='NULL';
        JJobQ_ErrorMoreInfo       :='NULL';
        JJobQ_Enabled_b           :='true';

        // POPULATE THIS WITH ALL CHIENV.DataIn parameters
        // But ADD the TASK ID so we can...
        // 1: Update task record as we progress
        // 2: Route Output to a file versus a webpage for download
        // 3: Update Task with URL for the download.
        JJobQ_Job:=
        '<CONTEXT>'+csCRLF+
        '  <saRequestMethod>POST</saRequestMethod>'+csCRLF+
        '  <saRequestType>HTTP/1.0</saRequestType>'+csCRLF+
        '  <saRequestedFile>'+Context.saAlias+'</saRequestedFile>'+csCRLF+
        '  <saQueryString>screen='+saEncodeURI(JScreen.rJScreen.JScrn_Name)+'</saQueryString>'+csCRLF+
        '  <REQVAR_XDL>'+csCRLF+
        '    <ITEM>'+csCRLF+
        '      <saName>HTTP_HOST</saName>'+csCRLF+
        '      <saValue>'+garJVHostLight[Context.i4VHost].saServerDomain+'</saValue>'+csCRLF+
        '    </ITEM>'+csCRLF+
        '  </REQVAR_XDL>'+csCRLF+
        '  <CGIENV>'+csCRLF+
        //'   <ENVVAR>'+csCRLF+
        //'     <ITEM>'+csCRLF+
        //'       <saName>QUERY_STRING</saName>'+csCRLF+
        //'       <saValue>screen='+saEncodeURI(JScreen.rJScreen.JScrn_Name)+'</saValue>'+csCRLF+
        //'     </ITEM>'+csCRLF+
        //'   </ENVVAR>'+csCRLF+
        '   <DATAIN>'+csCRLF;
        if Context.CGIENV.DataIn.MoveFirst then
        begin
          repeat
            JJobQ_Job+=
            '     <ITEM>'+csCRLF+
            '       <saName>'+Context.CGIENV.DataIn.Item_saName+'</saName>'+csCRLF+
            '       <saValue>'+Context.CGIENV.DataIn.Item_saValue+'</saValue>'+csCRLF+
            '     </ITEM>'+csCRLF;
          until not Context.CGIENV.DataIn.MoveNext;
          JJobQ_Job+=
          '     <ITEM>'+csCRLF+
          '       <saName>BACKTASK</saName>'+csCRLF+
          '       <saValue>'+rJTask.JTask_JTask_UID+'</saValue>'+csCRLF+
          '     </ITEM>'+csCRLF;
        end;
        JJobQ_Job+=
        '   </DATAIN>'+csCRLF+
        '  </CGIENV>'+csCRLF+
        '</CONTEXT>';
        JJobQ_Result              :='NULL';
        JJobQ_JTask_ID            :=rJTask.JTask_JTask_UID;

        bOk:=bJAS_Save_JJobQ(Context, Context.VHDBC, rJJobQ, false,false);
        if not bOk then
        begin
          JAS_LOG(Context, cnLog_Error, 201210231334,'Unable to save JobQ record for background data export of '+rJTable.JTabl_Name,'',SOURCEFILE);
        end;

        if bOk then
        begin
          Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGEICON@]','[@JASDIRICONTHEME@]64/mimetypes/x-office-spreadsheet.png');
          Context.saPage:=saGetPage(Context,'sys_area','sys_message','MESSAGE',false,'',201210231345);
          sa:='Your export has been placed into a queue to be processed. '+
            '<a target="_blank" href="[@ALIAS@].?screen=jtask+Data&UID='+rJTask.JTask_JTask_UID+'">'+
            'You can monitor it''s progress by clicking here.</a><br />'+csCRLF+
            '<strong>Do NOT refresh this page unless you want to export your data again!</strong><br />'+csCRLF+
            '<strong>Use the back button to return to the '+JScreen.rJScreen.JScrn_Name+' screen.</strong><br /><br />'+csCRLF+csCRLF+
            '<a title="Go Back to '+JScreen.rJScreen.JScrn_Name+' Screen" href="javascript: window.history.go(-1);">'+csCRLF+
            '  <table>'+csCRLF+
            '  <tbody>'+csCRLF+
            '    <tr>'+csCRLF+
            '      <td><img class="image" src="[@JASDIRICONTHEME@]32/actions/go-previous.png" /></td>'+csCRLF+
            '      <td>&nbsp;&nbsp;</td>'+csCRLF+
            '      <td><font size="4">Go Back</font></td>'+csCRLF+
            '    </tr>'+csCRLF+
            '  </tbody>'+csCRLF+
            '</table>'+csCRLF+
            '</a>';
          Context.PageSNRXDL.AppendItem_SNRPAir('[@MESSAGE@]',sa);
          JScreen.bPageCompleted:=true;
        end;
      end;
    end;

  end else
  // BEGIN ------------------------------------------------------- PREP for BACKGROUND EXPORT


  if bOk and (not JScreen.bPageCompleted) then
  begin
    if (saMulti='DELETE') then
    begin
      bMultiMode:=true;
      uMode:=cnJBlokMode_Delete;
      bOk:=bGrid_MultiDelete;
    end else

    if (saMulti='EDIT') then
    begin
      bMultiMode:=true;
      uMode:=cnJBlokMode_Edit;
    end else

    if (saMulti='MERGE') then
    begin
      bMultiMode:=true;
      uMode:=cnJBlokMode_Merge;
    end;
  end;

  if bOk and (not JScreen.bPageCompleted) Then
  begin
    bOk:=bGrid;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011855,'TJBLOK.bExecuteGridBlok - bGrid Call Failed. Screen: '+JScreen.rJScreen.JScrn_JScreen_UID+
        ' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
    end;
  end;

  If bOk and (not JScreen.bPageCompleted) Then
  Begin
    if JScreen.bExportingNow then
    begin
      if JScreen.saExportMode='TABULAR' then
      begin
        JScreen.saTemplate:=saSNRStr(saSectionMiddle, '[$BLOKGRID$]',saContent);
        JScreen.saTemplate+='</body></html>';
      end else

      if JScreen.saExportMode='CSV' then
      begin
        JScreen.saTemplate:=saContent;
        //Context.CGIENV.Header_PlainText;
      end else

      begin // Unknown? Treat as pure html tabular output without style
        JScreen.saTemplate:=saSNRStr(saSectionMiddle, '[$BLOKGRID$]',saContent);
        JScreen.saTemplate+='</body></html>';
      end;
    end;
  end;

  Context.PAGESNRXDL.AppendItem_SNRPair('[@MULTIFEEDBACK@]',saSectionTop);
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171753,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//==============================================================================
function TJBLOK.bGrid: boolean;
//==============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  u2JWidgetID: word;
  u2JDTypeID: word;
  rs: JADO_RECORDSET;

  JScreen: TJSCREEN;
  Context: TCONTEXT;
  JBlokField: TJBLOKFIELD;
  PosXDL: JFC_XDL;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bGrid: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102542,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102543, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  PosXDL:=JFC_XDL.create;

  JScreen.uGridRowsPerPage:=u4Val(saJASUserPref(Context,bOk,cnJUserPref_GridRowsPerPage, Context.rJUser.JUser_JUser_UID));
  if JScreen.uGridRowsPerPage<1 then
  begin
    JScreen.uGridRowsPerPage:=cnGrid_RowsPerPage;
  end;

  if bOk then
  begin
    if FXDL.MoveFirst then
    begin
      repeat
        JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        if u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
        begin
          PosXDL.AppendItem;
          PosXDL.Item_saName:=inttostr(PosXDL.N);
          PosXDL.Item_saValue:=inttostr(PosXDL.N);
          PosXDL.Item_i8User:=B00;//bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default

          JBlokField.bSort:=false;
          if Context.CGIENV.DataIn.FoundItem_saName('bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'U') then
          begin
            FXDL.Item_i8User:=iVal(Context.CGIENV.DataIn.Item_saValue);
            //if Context.CGIENV.DataIn.Item_saValue='0' then
            //begin
            //  JBlokField.bSort:=false;
            //end
            //else
            if Context.CGIENV.DataIn.Item_saValue='1' then
            begin
              JBlokField.bSort:=true;
              JBlokField.bAscending:=true;
            end
            else

            if Context.CGIENV.DataIn.Item_saValue='2' then
            begin
              JBlokField.bSort:=true;
              JBlokField.bAscending:=false;
            end;

          end;

          //Context.PageSNRXDL.AppendItem_saName_N_saValue('[@BFS'+JBlokfield.rJColumn.JColu_JColumn_UID+'U@]', sa);
          if Context.CGIENV.DataIn.FoundItem_saName('bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'P') then
          begin
            JBlokField.uSortPosition:=u2Val(Context.CGIENV.DataIn.Item_saValue);
          end;


          //Context.PageSNRXDL.AppendItem_saName_N_saValue('[@BFS'+JBlokfield.rJColumn.JColu_JColumn_UID+'S@]', inttostr(JBlokField.uSortPosition));
        end;
      until not FXDL.MoveNext;
    end;
  end;






  if bOk then
  begin
    if JScreen.bEditMode and (not JScreen.bExportingNow) then
    begin
      if JScreen.bMiniMode then
      begin
        saHeader:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_TemplateMini,'GRIDHEADERADMIN',true,923020100008);
      end
      else
      begin
        saHeader:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'GRIDHEADERADMIN',true,123020100008);
      end;
      with Context.PAGESNRXDL do begin
        AppendItem_SNRPair('[@GRIDADMIN_JBLOK_JBLOK_UID@]',rJBlok.JBlok_JBlok_UID);
      end; //with
    end
    else
    begin
      saHeader:='';
    end;

    if not JScreen.bExportingNow then
    begin
      if JScreen.bMiniMode then
      begin
        saSectionMiddle:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_TemplateMini,'GRIDSECTION',true,923020100010);
        //JAS_LOG(Context, nLog_Debug, 201209282048,'File: '+JScreen.rJScreen.JScrn_TemplateMini+' saSectionMiddle Mini:'+saSectionMiddle,'', SOURCEFILE);
      end
      else
      begin
        saSectionMiddle:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'GRIDSECTION',true,123020100010);
        //JAS_LOG(Context, nLog_Debug, 201209282049,'File: '+JScreen.rJScreen.JScrn_Template+' saSectionMiddle:'+saSectionMiddle, '',SOURCEFILE);
      end;
    end
    else
    begin
      // CSV needs to end up raw text so no template needed for it.
      if (JScreen.saExportMode<>'CSV') then
      begin
        saSectionMiddle:=saGetPage(Context, '','screenfiltergrid_export_html','',true,123020100011);
      end;
    end;
  end;

  if bOk then
  begin
    saContent+='';//<br />Query:<b>'+saQry+'</b><br />';
    if (not JScreen.bExportingNow) and (not bView) then
    begin
    
    
      saContent+='<input type="hidden" id="multi" name="multi" />'+
                 '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-copy.png" '+
                 'title="Click to edit selected records simultaneously." '+
                 'onclick="document.getElementById(''multi'').value=''EDIT'';SubmitForm();" />&nbsp;'+
                 '<img class="image" src="<? echo $JASDIRICON; ?>iconarchive/must_have_icon_set/16/Pause.png" '+
                 'title="Click to merge TWO selected records into one." '+
                 'onclick="document.getElementById(''multi'').value=''MERGE'';SubmitForm();" />&nbsp;'+
                 '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" '+
                 'title="Click to delete selected records. " '+
                 'onclick="if(confirm(''Delete ALL selected Records?'')){'+
                 'document.getElementById(''multi'').value=''DELETE'';SubmitForm();}else{return false;}" />&nbsp;'+
                 'Multi-Selection Tools&nbsp;&nbsp;&nbsp;&nbsp;<a target="_blank" href="[@ALIAS@].?action=help&helpid='+
                   rJBlok.JBlok_Help_ID+
                 '" title="Generic Result Grid Help">'+
                 '<img class="image" src="<? echo $JASDIRICONTHEME; ?>32/actions/help-contents.png" title="Generic Result Grid Help" /></a>';
      saContent+='<table class="jasgrid" >'+csCRLF;
      saContent+='<thead><tr>'+csCRLF;
    end
    else
    begin
      if JScreen.saExportMode='TABULAR' then
      begin
        saContent+='<table style="background:#aaaaaa;margin:4px;" align="left">'+csCRLF;
        saContent+='<thead style="color:#000000;background:#eeeeee;font-weight:bold;"><tr>'+csCRLF;
      end else
      if JScreen.saExportMode='CSV' then
      begin

      end else
      begin // Unknown? Treat as pure html tabular output without style
        saContent+='<table><thead><tr>';
      end;
    end;


    // FIRST HEADER ROW ----------------------------------------------------------------------------------------
    if not JScreen.bExportingNow then
    begin
      if FXDL.MoveFirst then
      begin
        saContent+=csCRLF+'<tr>';
        // Multi-Select All Button  (Should alternate with edit-redo.png icon when clicked)

        //saContent+='<td><input type="hidden" id="multi" name="multi" />'+
        //           '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" '+
        //           'title="Click to edit selected records simultaneously." '+
        //           'onclick="document.getElementById(''multi'').value=''EDIT'';SubmitForm();" /><br />'+
        //           '<img class="image" src="<? echo $JASDIRICON; ?>iconarchive\must_have_icon_set\16\Pause.png" '+
        //           'title="Click to merge TWO selected records into one." '+
        //           'onclick="document.getElementById(''multi'').value=''MERGE'';SubmitForm();" /><br />'+
        //           '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" '+
        //           'title="Click to delete selected records. " '+
        //           'onclick="if(confirm(''Delete ALL selected Records?'')){'+
        //           'document.getElementById(''multi'').value=''DELETE'';SubmitForm();}else{return false;}" />'+
        //           '</td><td></td>';
        saContent+='<td></td><td></td>';
        repeat
          JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
          saContent+='<td align="left" valign="middle" ><table><tr><td>';
          if (u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0)  then
          begin
            //saContent+='FXDL.Item_i8User:'+inttostr(FXDL.Item_i8User)+' ';
            //saContent+='JBlokField.uSortPosition:'+inttostr(JBlokField.uSortPosition);

            saContent+=csCRLF+'<div id="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'" ';
            if not (FXDL.Item_i8User=0) then saContent+=' style="display: none;"';
            saContent+='><img class="image" onclick="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x = sortswitch(''bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+''',bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-no.png" /></div>'+
                     csCRLF+'<div id="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'A" ';
            if not (FXDL.Item_i8User=1) then saContent+=' style="display: none;"';
            saContent+='><img class="image" onclick="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x = sortswitch(''bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+''',bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></div>'+
                     csCRLF+'<div id="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'D" ';
            if not (FXDL.Item_i8User=2) then saContent+=' style="display: none;"';
            saContent+='><img class="image" onclick="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x = sortswitch(''bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+''',bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></div>'+
                     csCRLF+'<input type="hidden" name="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'U" id="bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'U" value="'+inttostr(FXDL.Item_i8User)+'" /><script language="javascript">var bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'x=2;</script>'+
                     csCRLF+'</td><td>[#bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'P#]</td></tr>';

            if PosXDL.FoundItem_saValue(inttostr(JBlokField.uSortPosition)) then
            begin
              PosXDL.Item_i8User:=B00+B01+B02;
            end;

                   // // u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
            WidgetList(                                          // Procedure WidgetList(
              Context,                                           //   p_Context: TCONTEXT;
              'bfs'+JBlokfield.rJColumn.JColu_JColumn_UID+'P',   //   p_sWidgetName: String;
              '',                                                //   p_sWidgetCaption: String;
              inttostr(JBlokField.uSortPosition),                //   p_saDefaultValue: AnsiString;
              '1',                                               //   p_sSize: String;
              false,                                             //   p_bMultiple: boolean;
              true,                                              //   p_bEditMode: Boolean;
              grJASConfig.bDataOnRight,                          //   Data on right
              PosXDL,                                            //   p_XDL: JFC_XDL;
              false,                                             //   p_bRequired: boolean
              false,
              false,
              '',//OnBlur,
              '',//OnChange,
              '',//OnClick,
              '',//OnDblClick,
              '',//OnFocus,
              '',//OnKeyDown,
              '',//OnKeypress,
              ''//OnKeyUp,
            );
            if PosXDL.MoveFirst then
            begin
              repeat
                PosXDL.Item_i8User:=B00;
              until not PosXDL.movenext;
            end;
          end;
          saContent+='</table></td>'+csCRLF;
        until (not FXDL.MoveNext);
        saContent+='</tr>'+csCRLF;
      end;
    end;
    // FIRST HEADER ROW ----------------------------------------------------------------------------------------





    // SECOND HEADER ROW ----------------------------------------------------------------------------------------
    // Multi-Select All Button  (Should alternate with edit-redo.png icon when clicked)
    if not JScreen.bExportingNow then
    begin
      //saContent+='<tr><td><input type="hidden" id="sab" name="sab" value="'+Context.CGIENV.DataIn.Get_saValue('sab')+'" />'+
      //           '<div id="sab1" ';
      saContent+='<tr><td><input type="hidden" id="sab" name="sab" value="" />'+
                 '<div id="sab1" /><img class="image" onclick="sabswitch();mscheck();" title="Click to Check all rows on this page" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-add.png" /></div>'+
                 '<div id="sab2" style="display: none;" ';
      saContent+='/><img class="image" onclick="sabswitch();msuncheck();" title="Click to Uncheck all rows on this page" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-redo.png" /></div>'+
        '</td>'+

        '<td><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/document-open.png" '+
        'title="Click icons below to open record in edit mode." /></td>';
    end else

    if JScreen.saExportMode='TABULAR' then
    begin
      saContent+='<tr>';
    end else
    if JScreen.saExportMode='CSV' then
    begin

    end else
    begin // Unknown? Treat as pure html tabular output without style
      saContent+='<tr>';
    end;


    

    if FXDL.MoveFirst then
    begin
      repeat
        JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
        if JScreen.bExportingNow then
        begin
          if JScreen.saExportMode='CSV' then
          begin
            saContent+='"';
          end else

          begin // Unknown? Treat as pure html tabular output without style

          end;
        end;

        // if the Widgettype is non-zero, then widget type can dictate alignment
        u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);
        u2JDTypeID:=u2Val(JBlokField.rJColumn.JColu_JDType_ID);
        if u2JWidgetID=0 then u2JWidgetID:=u2JDTypeID;
        if bIsJDTypeMemo(u2JWidgetID) then
        begin
          // Note: This code makes a scrollable table cell.
          // Width and Height are px (ignores JBlkF_Width_is_Percent_b flag.
          // if eight with or height is zero then 300px x 100px is used as a default failsafe
          if iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<=0 then
          begin
            JBlokField.rJBlokField.JBlkF_Widget_Width:='300';
          end;
          if iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<=0 then
          begin
            JBlokField.rJBlokField.JBlkF_Widget_Height:='100';
          end;
        end else

        if bIsJDTypeNumber(u2JWidgetID) then
        begin
          JBlokField.saAlignment:='right';
        End else

        if (bIsJDTypeText(u2JWidgetID) or (u2JWidgetID=cnJWidget_URL) or (u2JWidgetID=cnJWidget_Email)) then
        Begin
          JBlokField.saAlignment:='left';
        End else

        if bIsJDTypeBoolean(u2JWidgetID) then
        Begin
          JBlokField.saAlignment:='center';
        End else

        if bIsJDTypeDate(u2JWidgetID) then
        begin
          JBlokField.saAlignment:='center';
        End else

        if (u2JWidgetID=cnJWidget_Lookup) or
           (u2JWidgetID=cnJWidget_Dropdown) or
           (u2JWidgetID=cnJWidget_ComboBox) then
        begin
          JBlokField.saAlignment:='left';
        end;

        if not JScreen.bExportingNow then
        begin
          saContent+='<td style="text-align:'+JBlokField.saAlignment+';" valign="middle" >';
        end
        else
        begin
          if JScreen.saExportMode='TABULAR' then
          begin
            saContent+='<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:1px;text-align:'+JBlokField.saAlignment+';" valign="middle" >';
          end else

          if JScreen.saExportMode='CSV' then
          begin

          end else

          begin // Unknown? Treat as pure html tabular output without style
            saContent+='<td>';
          end;
        end;


        if not JScreen.bExportingNow then
        begin
          saContent+=JBlokField.saCaption;
        end
        else

        if JScreen.saExportMode='TABULAR' then
        begin
          saContent+=JBlokField.saCaption;//This is the column Caption
        end else

        if JScreen.saExportMode='CSV' then
        begin
          saContent+=saSNRSTR(saSNRSTR(JBlokfield.saCaption,#10,' '),#13,'');//This is the column Caption
        end else

        begin // Unknown? Treat as pure html tabular output without style
          saContent+=JBlokField.saCaption;//This is the column Caption
        end;

        if(JScreen.bEditMode) and (not JScreen.bExportingNow) then
        begin
          saContent+='<br />';
          saContent+='<a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a>';
          if i8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
          begin
            saContent+='<a title="Edit JColumn" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+JBlokField.rJBlokField.JBlkF_JColumn_ID+''');"><img class="image" title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a>';
          end;
          saContent+='<a title="Left" href="javascript: editcol_left('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a>';
          saContent+='<a title="Right" href="javascript: editcol_right('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a>';
          saContent+='<a title="Delete" href="javascript: editcol_delete('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a>';
          saContent+='';
        end;

        if not JScreen.bExportingNow then
        begin
          saContent+='</td>'+csCRLF;
        end
        else
        begin
          if JScreen.saExportMode='TABULAR' then
          begin
            saContent+='</td>'+csCRLF;
          end else

          if JScreen.saExportMode='CSV' then
          begin
            saContent+='",';
          end else

          begin // Unknown? Treat as pure html tabular output without style
            saContent+='</td>';
          end;
        end;
      until (not FXDL.MoveNext);
    end;

    if not JScreen.bExportingNow then
    begin
      //ds.saBlokGrid+='<td>&nbsp;</td></tr></thead><tbody>'+csCRLF;
      saContent+='</tr></thead><tbody>'+csCRLF;
    end
    else
    begin
      if JScreen.saExportMode='TABULAR' then
      begin
        saContent+='</tr></thead><tbody>'+csCRLF;
      end else

      if JScreen.saExportMode='CSV' then
      begin
        if saRightStr(saContent, 1)=',' then
        begin
          saContent:=saLeftStr(saContent,length(saContent)-1);
          {$IFDEF LINUX}
          saContent+=#10;
          {$ELSE}
          saContent+=csCRLF;
          {$ENDIF}
        end;
      end else

      begin // Unknown? Treat as pure html tabular output without style
        saContent+='</tr></thead><tbody>';
      end;
    end;
    // SECOND HEADER ROW ----------------------------------------------------------------------------------------



    if rAudit.bUse_Deleted_b then
    begin
      if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
      JScreen.saQueryWhere+='(('+DBC.saDBMSEncloseObjectName(rJTable.JTabl_ColumnPrefix+'_Deleted_b')+'<>'+DBC.saDBMSBoolScrub(true) +
        ') or ('+DBC.saDBMSEncloseObjectName(rJTable.JTabl_ColumnPrefix+'_Deleted_b')+' is null)) ';
    end;

    if bVal(rJTable.JTabl_Owner_Only_b) and (NOT ((Context.rJUser.JUser_Admin_b) and (garJVHostLight[Context.i4VHost].saServerName='default'))) and
      (NOT bJAS_HasPermission(Context, cnJSecPerm_MasterAdmin)) and (NOT bJAS_HasPermission(Context,cnJSecPerm_Admin)) and
       rAudit.bUse_CreatedBy_JUser_ID then
    begin
      if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
      JScreen.saQueryWhere+=' '+rAudit.saFieldName_CreatedBy_JUser_ID+'='+DBC.saDBMSUIntScrub(Context.rJUser.JUser_JUser_UID);
    end;
    
    if JScreen.saQueryWhere<>'' then
    begin
      //AS_Log(Context,cnLog_Debug,201210220334,'Where clause before adding new WHERE: '+JScreen.saQueryWhere,'',SOURCEFILE);
      JScreen.saQueryWhere:=' WHERE '+JScreen.saQueryWhere;
    end;


    //if trim(JScreen.saQueryFrom)='' then
    //begin
    JScreen.saQueryFrom:=' FROM '+rJTable.JTabl_Name+' ';
    //end;
    
    case TGT.u2DBMSID of
    cnDBMS_MSAccess: saQry:=' SELECT count(*) as mycount ' + JScreen.saQueryFrom + JScreen.saQueryWhere;
    else saQry:=' SELECT count(*) as mycount ' + JScreen.saQueryFrom + JScreen.saQueryWhere;
    end;//switch
    bOk:=rs.Open(saQry, TGT,201503161514);
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200702271300,'Dynamic Query for counting records failed.','Query: '+saQry,SOURCEFILE,TGT,rs);
    End;
    //AS_Log(Context,cnLog_ebug,201203201155,'Filter Blok record Count: '+rs.fields.Get_saValue('mycount')+' Query: '+saQry,'',SOURCEFILE);
  end;

  if bOk then
  begin
    JScreen.uRecordCount:=iVal(rs.Fields.Get_saValue('mycount'));
  end;
  rs.close;

  if bOk then
  begin
    bOk:=bGridQuery;
    //if not bOk then
    //begin
    //  AS_Log(Context,cnLog_Error,201202242100,'Query Failed','bGrid_ExecuteQuery failed.',SOURCEFILE);
    //end;
  end;

  if bOk then
  begin
    JScreen.saTemplate:=saSNRStr(JScreen.saTemplate, '[$SCREENHEADER$]', JScreen.saScreenHeader);
    JScreen.saTemplate:=saSNRStr(JScreen.saTemplate, '[$BLOKBUTTONS$]', saButtons);
    JScreen.saTemplate:=saSNRStr(JScreen.saTemplate, '[$BLOKGRIDSECTION$]',
      saSNRStr( saSNRStr(saSectionMiddle,'[$BLOKGRIDHEADER$]',saHeader),'[$BLOKGRID$]',saContent));
  end;

  PosXDL.destroy;
  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102544,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================







//==============================================================================
function TJBLOK.bGridQuery: boolean;
//==============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  bColorRed: boolean;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  sa: ansistring;
  bShowRow: boolean;
  bDoneQuery: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  JBlokField: TJBLOKFIELD;
  SXDL: JFC_XDL;
  bUIDINQuery: boolean;
  saRecordID: ansistring;
  saCheck: ansistring;
  saUncheck: ansistring;
  saMEKey: ansistring;
  bOkToMultiEdit: boolean;
  sMergeRecord1: string;
  sMergeRecord2: string;
  uMERGErecords: cardinal;
  u2JWidgetID: word;
  saLUSQL: ansistring;
  saLUTable: ansistring;
  iClickAction: longint;
  dt: TDATETIME;
  bDateOk: boolean;
  saDateMask: ansistring;
  bSecAdd,bSecView,bSecDelete,bSecUpdate: boolean;
  saPermColumnName: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bGridQuery: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102539,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102540, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  SXDL:=JFC_XDL.Create;
  bShowRow:=false;
  bUIDINQuery:=false;
  saCheck:='';
  saUnCheck:='';
  saPermColumnName:=DBC.saGetValue('jcolumn','JColu_Name','JColu_JColumn_UID='+DBC.saDBMSUIntScrub(rJTable.JTabl_Perm_JColumn_ID));
  //saSessionKey:='';//multi edit uses this

  // =======================================================================
  // SELECT
  //   jsecgrp1.JSGrp_Name,
  //   juser1.JUser_Name as juser1_JUserName,
  //   juser2.JUser_Name as juser2_JUserName,
  //   JSGUL_JSecGrpUserLink_UID
  // FROM jsecgrpuserlink_742680510
  // LEFT JOIN (select JSGrp_JSecGrp_UID, JSGrp_Name from jsecgrp) as jsecgrp1 on JSGUL_JSecGrp_ID=JSGrp_JSecGrp_UID
  // LEFT JOIN (select * from juser) as juser1 on JSGUL_JUser_ID = juser1.JUser_JUser_UID
  // LEFT JOIN (select * from juser) as juser2 on JSGUL_JUser_ID = juser2.JUser_JUser_UID
  // ORDER BY juser1.JUser_Name
  // =======================================================================

  //FXDL.SortBinary(SizeOf(TJBLOKFIELD(nil).uSortPosition),@TJBLOKFIELD(nil).uSortPosition, true, true);
  if FXDL.MoveFirst then
  begin
    bUIDINQuery:=false;
    repeat
      JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
      if (u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0) then
      begin
        JBlokField.saColumnAlias:=JBlokField.rJColumn.JColu_Name;
        if not bUIDINQuery then bUIDINQuery:= (JBlokField.rJColumn.JColu_Name=rJColumn_Primary.JColu_Name);
        if JScreen.saQuerySelect<>'' then JScreen.saQuerySelect+=', ';
        //----------------------------------------------------------------
        JScreen.saQuerySelect+=DBC.saDBMSEncloseObjectName(JBlokField.saColumnAlias);
        if u8Val(JBlokField.rJColumn.JColu_LU_JColumn_ID)>0 then
        begin
            saLUSQL:=Context.saLookUpSQL(
            rJTable.JTabl_Name,
            JBlokField.rJColumn.JColu_Name,
            saLUTable
          );
          saLUSQL:=saSNRStr(saLUSQL, 'DisplayMe','[@NEWNAME@]');
          saLUSQL:=saSNRStr(saLUSQL, '[@NEWNAME@]',saLUTable+inttostr(FXDL.N)+'_DisplayMe');

          JBlokField.saColumnAlias:=saLUTable+inttostr(FXDL.N)+'_DisplayMe';
          JScreen.saQueryFrom += ' LEFT JOIN ( '+saLUSQL+') AS '+saLUTable+inttostr(FXDL.N) +' '+
            'ON '+JBlokField.rJColumn.JColu_Name+'='+saLUTable+inttostr(FXDL.N)+'.ColumnValue';
          JScreen.saQuerySelect+=', '+JBlokField.saColumnAlias;
        end;
        if (JBlokField.bSort) then
        begin
          SXDL.AppendItem_saName(saZeroPadInt(JBlokField.uSortPosition,8));
          SXDL.Item_i8User:=FXDL.N;
        end;
      end;
    until not FXDL.MoveNext;

    if not bUIDINQuery then
    begin
      if length(trim(rJColumn_Primary.JColu_Name))>0 then
      begin
        if JScreen.saQuerySelect<>'' then JScreen.saQuerySelect+=', ';
        JScreen.saQuerySelect+=rJColumn_Primary.JColu_Name;
      end;
    end;


    SXDL.SortItem_saName(true,true);
    //AS_LOG(Context,cnLog_ebug,201203210353,SXDL.saHTMLTABLE,'',SOURCEFILE);
    if SXDL.MoveFirst then
    begin
      sa:='';
      repeat
        if FXDL.FoundNth(SXDL.Item_i8User) then
        begin
          JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
          if sa='' then sa:=' ORDER BY ' else sa+=',';
          sa+=DBC.saDBMSEncloseObjectName(JBlokField.saColumnAlias);
          if NOT JBlokField.bAscending then sa+=' DESC ';
        end;
      until not SXDL.MoveNext;
      JScreen.saQueryOrder:=sa;
    end;
  end;


  if JScreen.saQuerySelect='' then
  begin
    JScreen.saQuerySelect:='SELECT 1 as OneColumn';
  end
  else
  begin
    JScreen.saQuerySelect:='SELECT '+JScreen.saQuerySelect;
  end;




  saQry:='SELECT '+DBC.saDBMSEncloseObjectName(rJColumn_Primary.JColu_Name) + ' '+JScreen.saQueryFrom + JScreen.saQueryWhere + ' GROUP BY '+rJColumn_Primary.JColu_Name+JScreen.saQueryOrder;



  if(Context.iDebugMode <> cnSYS_INFO_MODE_SECURE) then
  begin
    JScreen.Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SCREENQUERY@]',saQry+'  rJColumn_Primary.JColu_Name:'+rJColumn_Primary.JColu_Name);
  end
  else
  begin
    JScreen.Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SCREENQUERY@]','');
  end;

  
  {
  JAS_Log(JScreen.Context,cnLog_Debug,201203201150,'TJBLok.bGridQuery '+
    'saQuerySelect:'+JScreen.saQuerySelect+' | '+
    'saQueryFrom: '+JScreen.saQueryFrom+' | '+
    'saQueryWhere: ' + JScreen.saQueryWhere + ' | '  +
    'saQueryOrder: ' + JScreen.saQueryOrder+' | '+
    'rJTable.JTabl_Name: ' + rJTable.JTabl_Name
  ,'Query: '+saQry,SOURCEFILE);
  }



  if bOk then
  begin
    bOk:=rs2.Open(saQry, TGT,201503161515);
    If not bOk Then
    Begin
      JAS_Log(JScreen.Context,cnLog_Error,200701061347,'Dynamic Query failed.','Query: '+saQry,SOURCEFILE,TGT,rs);
    End;
  end;






  If bOk Then
  Begin
    JScreen.uRPage:=u4Val(JScreen.Context.CGIENV.DATAIN.Get_saValue('RPAGE'));
    JScreen.uRTotalPages:=u4Val(JScreen.Context.CGIENV.DATAIN.Get_saValue('RTOTALPAGES'));
    JScreen.uRTotalRecords:=0;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='firstpage') Then JScreen.uRPage:=1;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='lastpage') Then JScreen.uRPage:=JScreen.uRTotalPages;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='backpage') Then dec(JScreen.uRPage);
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='nextpage') Then Inc(JScreen.uRPage);
    JScreen.uRTotalPages:=JScreen.uRecordCount Div JScreen.uGridRowsPerPage;
    If (JScreen.uRecordCount Mod JScreen.uGridRowsPerPage)>0 Then
    Begin
      Inc(JScreen.uRTotalPages);
    End;
    If JScreen.uRPage>JScreen.uRTotalPages Then JScreen.uRPage:=JScreen.uRTotalPages;
    If JScreen.uRTotalPages=0 Then JScreen.uRTotalPages:=1;
    If JScreen.uRPage=0 Then JScreen.uRPage:=1;


    bColorRed:=false;
    If not rs2.EOL Then
    Begin
      bDoneQuery:=false;
      repeat
        //ASPrintln('JScreen.bBackgroundExporting: '+saTrueFalse(JScreen.bBackgroundExporting)+' JScreen.uRTotalRecords: '+inttostr(JScreen.uRTotalRecords)+' Mod 200:'+inttostR(JScreen.uRTotalRecords mod 200));
        if bOk and JScreen.bBackgroundExporting and ((JScreen.uRTotalRecords mod 200)=0) and (JScreen.uRTotalRecords>0) then
        begin
          saQry:='UPDATE jtask SET JTask_JStatus_ID='+DBC.saDBMSUIntScrub(cnJStatus_InProgress)+', '+
            'JTask_Progress_PCT_d='+DBC.saDBMSDecScrub(saDouble(((JScreen.uRTotalRecords/JScreen.uRecordCount)*100.0),5,2))+' '+
            'WHERE JTask_JTask_UID='+DBC.saDBMSUIntScrub(JSCreen.saBackTask);
          //ASPrintln('JTask update: '+saQry);
          bOk:=rs3.open(saQry, DBC,201503161516);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201210241239,'Unable to load update JTask Record: '+JSCreen.saBackTask,'Query: '+saQry,SOURCEFILE);
          end;
          rs3.close;
        end;

        if bOk then
        begin
          bOk:=bJAS_TablePermission(
            Context,
            rJTable,
            rs2.fields.Get_saValue(rJColumn_Primary.JColu_Name),
            rs2.fields.Get_saValue(saPermColumnName),
            bSecAdd, bSecView,bSecUpdate,bSecDelete,
            false,true,false,false
          );
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201211051433,'Unable to check permissions for table '+rJTable.JTabl_Name+' Row: '+rs2.fields.Get_saValue(saPermColumnName),'',SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          if bSecView then
          begin
            // bShow Row - Page Number PAss----------------------------------------
            Inc(JScreen.uRTotalRecords);
            JScreen.uPageRowMath:=((JScreen.uRTotalRecords-1) Div JScreen.uGridRowsPerPage);
            if not JScreen.bExportingNow then
            begin
              bShowRow:=(JScreen.uPageRowMath=(JScreen.uRPage-1));
              if JScreen.uPageRowMath>(JScreen.uRPage-1) then bDoneQuery:=true;
            end
            else
            begin
              if (JScreen.saExportPage='ALL') then
              begin
                bShowRow:=true;
              end
              else
              begin
                bShowRow:=(JScreen.uPageRowMath=(iVal(JScreen.saExportPage)-1));
                //JAS_LOG(JScreen.Context, cnLog_Debug, 201204301358,
                //  'bShowRow: '+saYesNo(bShowRow)+' '+
                //  'JScreen.uPageRowMath: '+inttostR(JScreen.uPageRowMath)+' '+
                //  'JScreen.saExportPage: '+JScreen.saExportPage+' '+
                //  'iVal(JScreen.saExportPage): '+inttostr(iVal(JScreen.saExportPage)),'',SOURCEFILE);
                if JScreen.uPageRowMath>(iVal(JScreen.saExportPage)-1) then bDoneQuery:=true;
                //if bShowRow then
                //begin
                //  bShowRow:=Context.CGIENV.DataIn.FoundItem_saName('MS'+rs.fields.Get_saValue(rJColumn_Primary.JColu_Name));
                //end;
              end;
            end;
            // bShow Row - Page Number PAss----------------------------------------
          end;

          // Render Pass --------------------------------------------------------
          If bShowRow Then
          Begin
            saQry:=JScreen.saQuerySelect + JScreen.saQueryFRom + ' WHERE '+
              rJColumn_Primary.JColu_Name+'='+DBC.saDBMSUIntScrub(rs2.fields.Get_saValue(rJColumn_Primary.JColu_Name));
            bOk:=rs.open(saQry, TGT,201503161517);
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Error,201204161650, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
            end;

            if bOk then
            begin
              saRecordID:=saStr(u8Val(rs.Fields.Get_saValue(rJColumn_Primary.JColu_Name)));
              if not JScreen.bExportingNow then
              begin
                If bColorRed Then saContent+='<tr class="r1">'+csCRLF Else saContent+='<tr class="r2">'+csCRLF;
              end
              else
              begin
                if JScreen.saExportMode='TABULAR' then
                begin
                  If bColorRed Then
                  begin
                    saContent+='<tr style="color:#000000;background: #c0f0c0;">'+csCRLF
                  end
                  else
                  begin
                    saContent+='<tr style="color:#000000;background: #ffffff;">'+csCRLF
                  end;
                end else

                if JScreen.saExportMode='CSV' then
                begin

                end else

                begin // Unknown? Treat as pure html tabular output without style
                  saContent+='<tr>';
                end;
              end;

              bColorRed:=not bColorRed;
              if FXDL.MoveFirst then
              begin
                if not JScreen.bExportingNow then
                begin
                  saContent+='<td><input type="checkbox" name="ms'+saRecordID+'" id="ms'+saRecordID+'" ';
                  if Context.CGIENV.DataIn.Get_saValue('ms'+saRecordID)='on' then saContent+='checked ';
                  saContent+='/></td>';
                  saCheck+='document.getElementById("ms'+saRecordID+'").checked=true;';
                  saUncheck+='document.getElementById("ms'+saRecordID+'").checked=false;';

                  saContent+=
                    '<td><a href="javascript: NewWindow(''[@ALIAS@].?UID='+saRecordID+'&[@DETAILSCREENID@]&BUTTON=EDIT'');">'+
                    '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/document-open.png" '+
                    'title="Click to edit this record." /></a></td>';
                end;
                repeat
                  JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
                  iClickAction:=u8Val(JBlokField.rJBlokField.JBlkF_ClickAction_ID);
                  u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);
                  if u2JWidgetID=0 then u2JWidgetID:=u2Val(JBlokField.rJColumn.JColu_JDType_ID);

                  if not JScreen.bExportingNow then
                  begin
                    if (cnJDType_sn=u2JWidgetID) or
                      (cnJDType_sun=u2JWidgetID) then
                    begin
                      // Note: This code makes a scrollable table cell.
                      // Width and Height are px (ignores JBlkF_Width_is_Percent_b flag.
                      // if eight with or height is zero then 300px x 100px is used as a default failsafe
                      saContent+='<td style="text-align:'+JBlokField.saAlignment+';" valign="top" >'+
                                '<div style="width: '+JBlokField.rJBlokField.JBlkF_Widget_Width+'px;'+
                                'height: '+JBlokField.rJBlokField.JBlkF_Widget_Height+'px;'+
                                'overflow: auto;" >';
                    end
                    else
                    begin
                      // Newer (NoWrap could use a better control mechanism but it's a start.
                      saContent+='<td style="text-align:'+JBlokField.saAlignment+';" valign="top" ';
                      if iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)>0 then
                      begin
                        saContent+='width="'+JBlokField.rJBlokField.JBlkF_Widget_Width;
                        if bVal(JBlokField.rJBlokField.JBlkF_Width_is_Percent_b) then
                        begin
                          saContent+='%';
                        end
                        else
                        begin
                          saContent+='px';
                        end;
                        saContent+='" ';
                      end;

                      if iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)>0 then
                      begin
                        saContent+='height="'+JBlokField.rJBlokField.JBlkF_Widget_Height;
                        if bVal(JBlokField.rJBlokField.JBlkF_Height_is_Percent_b) then
                        begin
                          saContent+='%';
                        end
                        else
                        begin
                          saContent+='px';
                        end;
                        saContent+='"';
                      end;
                      saContent+=' nowrap="nowrap" >';
                    end;






                    //=======================================================================================
                    case iClickAction of
                    cnJBlkF_ClickAction_None: ;
                    cnJBlkF_ClickAction_DetailScreen: begin // Detail Screen
                        saContent+='<a href="javascript: NewWindow(''[@ALIAS@].?UID='+saRecordID+'&[@DETAILSCREENID@]'');">';
                    end;
                    cnJBlkF_ClickAction_Link: begin // Custom ClickAction Data
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',saRecordID);
                      if rs.Fields.MoveFirst then
                      begin
                        repeat
                          sa:=saSNRStr(sa,'[@'+rs.fields.Item_saName+'@]',rs.fields.Item_saValue);
                        until not rs.fields.MoveNext;
                      end;
                      saContent+='<a href="'+sa+'">';//+csCRLF;
                    end;
                    cnJBlkF_ClickAction_LinkNewWindow: begin // Custom ClickAction Data - Target = New Window = _blank
                      //JAS_LOG(Context, cnLog_Debug, 201208210613,'----DEBUG cnJBlkF_ClickAction_CustomNewWindow----','',SOURCEFILE);
                      //JAS_LOG(Context, cnLog_Debug, 201208210613,'ClickActionData: '+JBlokField.rJBlokField.JBlkF_ClickActionData,'',SOURCEFILE);
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',saRecordID);
                      //JAS_LOG(Context, cnLog_Debug, 201208210613,'UID Replaced: '+sa,'',SOURCEFILE);
                      if rs.fields.MoveFirst then
                      begin
                        repeat
                          sa:=saSNRStr(sa,'[@'+rs.fields.Item_saName+'@]',rs.fields.Item_saValue);
                          //JAS_LOG(Context, cnLog_Debug, 201208210613,'FIELD: '+rs.fields.Item_saName,'',SOURCEFILE);
                          //JAS_LOG(Context, cnLog_Debug, 201208210613,'RESULT: '+sa,'',SOURCEFILE);
                        until not rs.fields.MoveNext;
                      end;
                      saContent+='<a target="_blank" href="'+sa+'">';//+csCRLF;
                    end;
                    cnJBlkF_ClickAction_Custom: begin // 4 = Custom ClickAction Data = COMPLETELY CUSTOM - With SNR of fields - RISKY!
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',saRecordID);
                      if rs.Fields.MoveFirst then
                      begin
                        repeat
                          sa:=saSNRStr(sa,'[@'+rs.fields.Item_saName+'@]',rs.fields.Item_saValue);
                          sa:=saSNRStr(sa,'[!'+rs.fields.Item_saName+'!]',saEncodeURI(rs.fields.Item_saValue));
                        until not rs.fields.MoveNext;
                      end;
                      saContent+=csCRLF+sa+csCRLF;
                    end;
                    end;//switch
                    //=======================================================================================

                  end
                  else
                  begin
                    if JScreen.saExportMode='TABULAR' then
                    begin
                      saContent+='<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:3px;text-align:'+
                        JBlokField.saAlignment+';" valign="top" nowrap="nowrap">';
                    end else

                    if JScreen.saExportMode='CSV' then
                    begin
                      if (bIsJDTypeText(u2JWidgetID)) or
                        (u2JWidgetID=cnJWidget_DropDown) or
                        (u2JWidgetID=cnJWidget_Lookup) then
                      begin
                        saContent+='"';
                      end;
                    end else

                    begin // Unknown? Treat as pure html tabular output without style
                      saContent+='<td>';
                    end;
                  end;

                  If (trim(rs.fields.Get_saValue(JBlokField.saColumnAlias))='') or
                    (trim(rs.fields.Get_saValue(JBlokField.saColumnAlias))='NULL') Then
                  Begin
                    if not JScreen.bExportingNow then
                    begin
                      if iClickAction<>cnJBlkF_ClickAction_Custom then
                      begin
                        if (trim(rs.fields.Get_saValue(JBlokField.saColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                        end
                        else
                        begin
                          saContent+='';
                        end;
                      end;
                    end
                    else
                    begin
                      if JScreen.saExportMode='TABULAR' then
                      begin
                        if (trim(rs.fields.Get_saValue(JBlokField.saColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                        end
                        else
                        begin
                          saContent+='';//purposely nothing - here for documentation (and expansion)
                        end;
                      end else

                      if JScreen.saExportMode='CSV' then
                      begin
                        saContent+='';
                      end else

                      begin // Unknown? Treat as pure html tabular output without style
                        if (trim(rs.fields.Get_saValue(JBlokField.saColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                        end
                        else
                        begin
                          saContent+='';//purposely nothing - here for documentation (and expansion)
                        end;
                      end;
                    end;
                  End
                  Else
                  Begin
                    if (JScreen.bExportingNow) or (iClickAction<>cnJBlkF_ClickAction_Custom) then
                    begin
                      if bIsJDTypeDate(u2JWidgetID) then
                      begin
                        if '0000-00-00 00:00:00'<>trim(rs.fields.Get_saValue(JBlokField.saColumnAlias)) then
                        begin
                          bDateOk:=true;
                          try
                            dt:=StrToDateTime(JDATE(trim(rs.fields.Get_saValue(JBlokField.saColumnAlias)),1,11));
                          except on E : EConvertError do bDateOk:=false;
                          end;
                          if bDateOk then
                          begin
                            JBlokField.rJBlokField.JBlkF_Widget_Mask:=trim(JBlokField.rJBlokField.JBlkF_Widget_Mask);
                            if (length(JBlokField.rJBlokField.JBlkF_Widget_Mask)>0) then
                            begin
                              saContent+=FormatDatetime(JBlokField.rJBlokField.JBlkF_Widget_Mask,dt);
                            end
                            else
                            begin
                              saDateMask:='';
                              if bVal(JBlokField.rJBlokField.JBlkF_Widget_Date_b) then
                              begin
                                saDateMask:='MM/DD/YYYY ';
                              end;
                              if bVal(JBlokField.rJBlokField.JBlkF_Widget_Time_b) then
                              begin
                                saDateMask+='HH:NN AMPM';
                              end;
                              if saDateMask='' then saDateMask:= 'MM/DD/YYYY HH:NN AMPM';
                              saContent+=FormatDatetime(saDateMask,dt);
                            end;
                          end
                          else
                          begin
                            saContent+='['+rs.fields.Get_saValue(JBlokField.saColumnAlias)+']';
                          end;
                        end;
                      End else

                      if bIsJDTypeBoolean(u2JWidgetID) then
                      begin
                        if not JScreen.bExportingNow then
                        begin
                          if bVal(rs.fields.Get_saValue(JBlokField.saColumnAlias)) then
                          begin
                            saContent+='Yes&nbsp;<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-ok.png" />&nbsp;';
                          end
                          else
                          begin
                            saContent+='No&nbsp;<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-no.png" />&nbsp;';
                          end;
                        end
                        else
                        begin
                          if JScreen.saExportMode='TABULAR' then
                          begin
                            saContent+= trim(saYesNo(bVal(rs.fields.Get_saValue(JBlokField.saColumnAlias))));
                          end else

                          if JScreen.saExportMode='CSV' then
                          begin
                            saContent+= trim(saYesNo(bVal(rs.fields.Get_saValue(JBlokField.saColumnAlias))));
                          end else

                          begin
                            saContent+= trim(saYesNo(bVal(rs.fields.Get_saValue(JBlokField.saColumnAlias))));
                          end;
                        end;
                      End else

                      if bIsJDTypeNumber(u2JWidgetID) then
                      begin
                        if false = bVal(JBlokField.rJColumn.JColu_Boolean_b) then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.saColumnAlias);
                        end
                        else
                        begin
                          if rs.fields.Get_saValue(JBlokField.saColumnAlias)='NULL' then
                          begin
                            saContent+=rs.fields.Get_saValue(JBlokField.saColumnAlias);
                          end
                          else
                          begin
                            saContent+=rs.fields.Get_saValue(saTrueFalse(bVal(JBlokField.saColumnAlias)));
                          end;
                        end;
                      End else

                      if (cnJWidget_Lookup=u2JWidgetID) or (cnJWidget_LookupComboBox=u2JWidgetID) then
                      begin
                        //saContent+=JBlokField.saLookUp(rs.fields.Get_saValue(JBlokField.saColumnAlias));
                        //saContent+=Context.saLookUp(
                        //  rJTable.JTabl_Name,
                        //  JBlokField.saColumnAlias,
                        //  rs.fields.Get_saValue(JBlokField.saColumnAlias)
                        //);
                        if rs.fields.Get_saValue(JBlokField.saColumnAlias)='NULL' then
                        begin
                          saContent+='[ '+rs.fields.Get_saValue(JBlokfield.rJColumn.JColu_Name)+' ]';
                        end
                        else
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.saColumnAlias);
                        end;
                      end else

                      if (cnJWidget_URL=u2JWidgetID) then
                      begin
                        if (JScreen.bExportingNow) or (iClickAction>0) then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.saColumnAlias);
                        end
                        else
                        begin
                          sa:=trim(rs.fields.Get_saValue(JBlokField.saColumnAlias));
                          if (uppercase(saLeftStr(sa,7))<>'HTTP://') and
                            (uppercase(saLeftStr(sa,8))<>'HTTPS://') and
                            (uppercase(saLeftStr(sa,6))<>'FTP://') and
                            (saLeftStr(sa,1)<>'/') then
                          begin
                            sa:='http://'+sa;
                          end;
                          saContent+='<a target="_blank" href="'+sa+'" title="Click to go to '+JBlokField.saCaption+' in a new window or tab." >';
                          if length(sa)>40 then sa:=saLeftStr(sa,37)+'...';
                          saContent+=sa+'</a>';
                        end;
                      end else

                      if (cnJWidget_Email=u2JWidgetID) then
                      begin
                        if (JScreen.bExportingNow) or (iClickAction>0) then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.saColumnAlias);
                        end
                        else
                        begin
                          sa:=trim(rs.fields.Get_saValue(JBlokField.saColumnAlias));
                          if (uppercase(saLeftStr(sa,7))<>'mailto://') then
                          begin
                            sa:='mailto://'+sa;
                          end;
                          saContent+='<a target="_blank" href="'+sa+'" title="Click to send and email to '+JBlokField.saCaption+' with your default Email client." >';
                          if length(sa)>40 then sa:=saLeftStr(sa,37)+'...';
                          saContent+=sa+'</a>';
                        end;
                      end else

                      //if bIsJDTypeText(u2Val(JBlokField.rJBlokfield.JBlkF_JWidget_ID)) then
                      begin
                        if not JScreen.bExportingNow then
                        begin
                          //saContent+=saJDType(u2Val(JBlokField.rJBlokfield.JBlkF_JWidget_ID))+' : ';
                          saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.saColumnAlias),#10,'<br />');
                        end
                        else
                        begin
                          if JScreen.saExportMode='TABULAR' then
                          begin
                            saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.saColumnAlias),#10,'<br />');
                          end else

                          if JScreen.saExportMode='CSV' then
                          begin
                            saContent+=saDoubleEscape(rs.fields.Get_saValue(JBlokField.saColumnAlias),'"');
                          end else

                          begin
                            saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.saColumnAlias),#10,'<br />');
                          end;
                        end;
                      end;
                    end;
                  End;

                  if not JScreen.bExportingNow then
                  begin
                    case iClickAction of
                    cnJBlkF_ClickAction_None: ;
                    cnJBlkF_ClickAction_DetailScreen: begin // Detail Screen
                        saContent+='</a>';//+csCRLF;
                    end;
                    cnJBlkF_ClickAction_Link: begin // Custom ClickAction Data
                        saContent+='</a>';//+csCRLF;
                    end;
                    cnJBlkF_ClickAction_LinkNewWindow: begin // Custom ClickAction Data - Target = New Window = _blank
                      saContent+='</a>';//+csCRLF;
                    end;
                    cnJBlkF_ClickAction_Custom: begin // Custom ClickAction Data = COMPLETELY CUSTOM - With SNR of fields - RISKY!
                      // Nothing
                    end;
                    end;//switch

                    //case u8Val(JBlokField.rJBlokField.JBlkF_JWidget_ID) of
                    //cnJDType_s: begin
                    //  saContent+='</div>';
                    //end;//case
                    //end//switch
                  end;

                  if not JScreen.bExportingNow then
                  begin
                    saContent+='</td>'+csCRLF;
                  end
                  else
                  begin
                    if JScreen.saExportMode='TABULAR' then
                    begin
                      saContent+='</td>'+csCRLF
                    end else

                    if JScreen.saExportMode='CSV' then
                    begin
                      if bIsJDTypetext(u2Val(JBlokField.rJColumn.JColu_JDType_ID)) or
                        (u2JWidgetID=cnJWidget_DropDown) or
                        (u2JWidgetID=cnJWidget_Lookup) then
                      begin
                        saContent+='"';
                      end;
                      if FXDL.N<FXDL.ListCount then
                      begin
                        saContent+=',';
                      end
                      else
                      begin
                        {$IFDEF LINUX}
                        saContent+=#10;
                        {$ELSE}
                        saContent+=csCRLF;
                        {$ENDIF}
                      end;

                    end else

                    begin // Unknown? Treat as pure html tabular output without style
                      saContent+='</td>';
                    end;

                  end;
                until (not bOk) or (not FXDL.MoveNext);
              end;


              if not JScreen.bExportingNow then
              begin
                saContent+='</tr>'+csCRLF;
              end
              else
              begin
                if JScreen.saExportMode='TABULAR' then
                begin
                  saContent+='</tr>'+csCRLF
                end else

                if JScreen.saExportMode='CSV' then
                begin

                end else

                begin // Unknown? Treat as pure html tabular output without style
                  saContent+='</tr>';
                end;
              end;
            end;
            rs.close;
          End;
          // Render Pass --------------------------------------------------------
        end;
      Until (not bOk) or bDoneQuery or (not rs2.MoveNext);
    End;
    rs2.Close;


    if bOk then
    begin
      if not JScreen.bExportingNow then
      begin
        saContent+='</tbody></table>'+csCRLF;

        // MULTI EDIT ---------------------------------------------------------
        if bMultiMode and (uMode=cnJBlokMode_EDIT) then
        begin
          saMEKey:=saJAS_GetSessionKey;
          if Context.CGIENV.DataIn.MoveFirst then
          begin
            bOkToMultiEdit:=true;
            repeat
              saRecordID:=Context.CGIENV.DataIn.Item_saName;
              if saLeftStr(saRecordID,2)='MS' then
              begin
                saRecordID:=saRightStr(saRecordID, length(saRecordID)-2);
                if bJAS_LockRecord(Context,TGT.ID, rJTable.JTabl_Name, saRecordID, '0',201501020032) then
                begin
                  Context.SessionXDL.AppendItem_saName_N_saValue('MEDIT'+saMEKey,saRecordID);
                end
                else
                begin
                  bOkToMultiEdit:=false;
                  saSectionTop:='Unable to lock all records selected for multi-edit.';
                end;
              end;
            until not Context.CGIENV.DataIn.MoveNext;
          end;

          if bOkToMultiEdit then
          begin
            bOkToMultiEdit:=Context.SessionXDL.FoundItem_saName('MEDIT'+saMEKey,true);
            if not bOkToMultiEdit then
            begin
              saSectionTop:='No records selected for multi-edit.';
            end
            else
            begin
              //SUCCESS
              Context.bSaveSessionData:=true;
              saSectionTop:='All selected records locked for multi-edit. Make sure your browser allows pop-ups from this site.';
              saContent+='<script language="javascript">NewWindow("[@ALIAS@].?MULTIEDIT='+saMEKey+'&[@DETAILSCREENID@]");</script>';
            end;
          end;

          if not bOkToMultiEdit then
          begin
            if Context.SessionXDL.MoveFirst then
            begin
              repeat
                if Context.SessionXDL.Item_saName='MEDIT'+saMEKey then
                begin
                  bJAS_UnlockRecord(Context,DBC.ID, rJTable.JTabl_Name, Context.SessionXDL.Item_saValue, '0',201501020033);
                end;
              until not Context.SessionXDL.MoveNext;
            end;
          end;
        end else
        // MULTI EDIT ---------------------------------------------------------


        // MERGE --------------------------------------------------------------
        if bMultiMode and (uMode=cnJBlokMode_MERGE) then
        begin
          if Context.CGIENV.DataIn.MoveFirst then
          begin
            sMergeRecord1:='';sMergeRecord2:='';uMergeRecords:=0;
            repeat
              saRecordID:=Context.CGIENV.DataIn.Item_saName;
              if saLeftStr(saRecordID,2)='MS' then
              begin
                uMergeRecords+=1;
                if sMergeRecord1='' then
                begin
                  sMergeRecord1:=saRightStr(saRecordID, length(saRecordID)-2);
                end
                else
                begin
                  sMergeRecord2:=saRightStr(saRecordID, length(saRecordID)-2);
                end;
              end;
            until (not Context.CGIENV.DataIn.MoveNext);
            if uMERGErecords>2 then
            begin
              saContent+='<script language="javascript">alert("You can only have TWO records selected to perform a MERGE operation.");</script>';
            end else
            if uMERGErecords<2 then
            begin
              saContent+='<script language="javascript">alert("You need to have TWO records selected in order to perform a MERGE operation.");</script>';
            end
            else
            begin
              saContent+='<script language="javascript">NewWindow("[@ALIAS@].?Action=MERGE&JTable='+rJTable.JTabl_JTable_UID+
                '&R1='+sMergeRecord1+'&R2='+sMergeRecord2+'");</script>';
            end;
          end;
        end;
        // MERGE --------------------------------------------------------------
      end
      else
      begin
        if JScreen.saExportMode='TABULAR' then
        begin
          saContent+='</tbody></table>'+csCRLF;
        end else

        if JScreen.saExportMode='CSV' then
        begin

        end else

        begin // Unknown? Treat as pure html tabular output without style
          saContent+='</tbody></table>'+csCRLF;
        end;
      end;
      Context.PAGESNRXDL.AppendItem_SNRPair('[@RPAGE@]'      ,inttostr(JScreen.uRPage));
      Context.PAGESNRXDL.AppendItem_SNRPair('[@RTOTALPAGES@]',inttostr(JScreen.uRTotalPages));
      //Context.PAGESNRXDL.AppendItem_SNRPair('[@RTOTALRECORDS@]',inttostr(JScreen.uRTotalRecords));
      Context.PAGESNRXDL.AppendItem_SNRPair('[@RTOTALRECORDS@]',inttostr(JScreen.uRecordCount));
    end;
  end;
  if not JScreen.bExportingNow then
  begin
    saContent+='<script language="javascript">function mscheck(){'+saCheck+'}; '+
               'function msuncheck(){'+saUncheck+'};</script>';
  end;

  {
  if bOk then
  begin

  saQry:='DROP TABLE ' + saTempTable;
    bOk:=rs.Open(saQry, JAS,201503161518);
    if not bOk then
    begin
      JAS_Log(JScreen.Context,cnLog_Error,200701061347,'Unable to DROP Temp Table.','Query: '+saQryTemp,SOURCEFILE,JScreen.JAS,rs);
    end;
  end;
  }


  rs.Destroy;
  rs2.destroy;
  rs3.destroy;
  SXDL.Destroy;
  result:=bOk;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102541,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================

















//==============================================================================
function TJBLOK.bGrid_MultiDelete: boolean;
//==============================================================================
var
  bOk: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  saRecordID: ansistring;
  u4Found: Cardinal;
  u4Removed: Cardinal;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bGrid_MultiDelete: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203221818,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203221818, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  u4Found:=0;
  u4Removed:=0;

  if Context.CGIENV.DataIn.MoveFirst then
  begin
    repeat
      saRecordID:=Context.CGIENV.DataIn.Item_saName;
      if saLeftStr(saRecordID,2)='MS' then
      begin
        u4Found+=1;
        saRecordID:=saRightStr(saRecordID, length(saRecordID)-2);
        if bJAS_LockRecord(Context,TGT.ID, rJTable.JTabl_Name, saRecordID, '0',201501020034) then
        begin
          bOk:=bRecord_SecurityCheck(saRecordID,cnRecord_Delete);
          
          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201203241110,'You are not permitted to delete one or more of these selected record(s).',
              'Table: '+rJTable.JTabl_Name+' UID: '+sarecordID,SOURCEFILE);
          end;

          if bOk then
          begin
            bOk:=bPreDelete(rJTable.JTabl_Name,saRecordID);
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Warn, 201205300847,'bPreDelete called from Multi-Delete in Grid Failed: Table: '+rJTable.JTabl_Name+' UID: '+sarecordID,'',SOURCEFILE);
            end;
          end;

          if bOk then
          begin
            bOk:=bJAS_DeleteRecord(Context,TGT, rJTable.JTabl_Name,saRecordID);
            if not bOk then
            begin
              if Context.u8ErrNo<>201203262012 then
              begin
                JAS_Log(Context,cnLog_Error,201203221908,'Trouble deleting record.','',SOURCEFILE);
              end;
            end;
          end;
          //rs.Close;
          bJAS_UnlockRecord(Context,TGT.ID, rJTable.JTabl_Name, saRecordID, '0',201501020035);
          if bOk then u4Removed+=1;
        end;
      end;
    until (not bOk) or (not Context.CGIENV.DataIn.MoveNext);
  end;

  if bOk then
  begin
    if u4Found=0 then
    begin
      saSectionTop:='No records selected for multi-delete.';
    end
    else
    begin
      saSectionTop:=inttostr(u4Removed)+' of '+inttostr(u4Found)+
        ' records were deleted successfully.';
    end;
  end;

  //rs.Destroy;
  result:=bOk;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102541,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================

/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// GRID STUFF














/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF



//=============================================================================
function TJBLOK.bExecuteDataBlok: boolean;
//=============================================================================
var
  bOk: boolean;
  saDetailBlok: ansistring;
  saDetailBloks: ansistring;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  sa: ansistring;
  u2JButtonType: word;
  bDone: boolean;
  sButton: String;
  saME: ansistring;// Multi Edit Items getting stuffed into FORM
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bExecuteDataBlok: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171754,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171754, sTHIS_ROUTINE_NAME);{$ENDIF}

  //saHeader             =    saBlokDetailHeader
  //saSectionTop:        =    saBlokDetailSection
  //saSectionMiddle:     =    saDetailBlokTemplate
  //saSectionBottom:
  //saContent:           =    saBlokDetail
  //saFooter:
  saDetailBlok:='';
  saDetailBloks:='';
  bOk:=true;
  bDone:=false;
  
  
  Context.PAGESNRXDL.AppendItem_SNRPair('[@DETAIL_HELP_ID@]',rJBlok.JBlok_Help_ID);
  


  // First, Figure out what the user is trying to do from the BUTTON TYPE, and the PASSED UID
  //-------------------------------
  If rAudit.saUID='' Then
  begin
    uMode:=cnJBlokMode_New;
    if not bRecord_PreAdd then
    begin
      bDone:=true;
    end;
  end
  else
  begin
    uMode:=cnJBlokMode_View;
  end;
    

  If not bDone then
  begin
    if Context.CGIENV.DataIn.FoundItem_saName('button',False) Then
    Begin
      sButton:=JFC_XDLITEM(Context.CGIENV.DataIn.lpItem).saValue;
      //IF sButton='PROMOTELEAD' then
      //begin
      //  Context.CGIENV.Header_Redirect('http://www.google.com');
      //  bDone:=true;
      //end else
      if sButton='CANCEL' Then uMode:=cnJBlokMode_Cancel else
      if sButton='CANCELNCLOSE' Then uMode:=cnJBlokMode_CancelNClose else
      if sButton='SAVE' Then uMode:=cnJBlokMode_Save else
      if sButton='SAVENCLOSE' Then uMode:=cnJBlokMode_SaveNClose else
      if sButton='SAVENNEW' then uMode:=cnJBlokMode_SaveNNew else
      if uMode=cnJBlokMode_New then
      begin
        if sButton='DELETE' Then uMode:=cnJBlokMode_Deleted;
        if sButton='EDIT' Then uMode:=cnJBlokMode_Edit;
      end else
      if sButton='DELETE' Then uMode:=cnJBlokMode_Delete else
      if sButton='EDIT' Then uMode:=cnJBlokMode_Edit;
    end;
  End;


  if not bDone then
  begin
    if JScreen.bEditmode then
    begin
      saHeader:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILHEADERADMIN',true,123020100013);
      saSectionTop:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILSECTION',true,123020100015);
      saSectionMiddle:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILBLOK',true,123020100012);
    end
    else
    begin
      saHeader:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILHEADER',true,123020100014);
      saSectionTop:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILSECTION',true,123020100015);
      saSectionMiddle:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILBLOK',true,123020100012);
    end;

    // MULTI-EDIT Check
    bMultiMode:=Context.CGIENV.DataIn.FoundItem_saName('MULTIEDIT');
    // Note: saFooter - is OUR Spot For [@MULTIEDITHEADER@] text etc.
    // Note: Don't Mess with uMode for Detail screens in Multi-Edit mode - we are piggy backing working
    // functionality for normal detail screens.
    if bMultiMode then
    begin
      Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDIT@]','<input type=hidden name="MULTIEDIT" value="'+Context.CGIENV.DataIn.Item_saValue+'" />');
      saSectionBottom:='MEDIT'+Context.CGIENV.DataIn.Item_saValue;
      saFooter:='<h1>MULTI-EDIT MODE!</h1>';
      saME:=csCRLF;
      if Context.SessionXDL.MoveFirst then
      begin
        repeat
          if Context.SessionXDL.Item_saName=saSectionBottom then
          begin
            saME+='<input type=hidden name="'+saSectionBottom+'" value="'+Context.SessionXDL.Item_saValue+'" />'+csCRLF;
          end;
        until not Context.SessionXDL.MoveNext;
      end;
      Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDITITEMS@]',saME);
      if Context.SessionXDL.MoveFirst then
      begin
        while Context.SessionXDL.FoundItem_saName(saSectionBottom) do begin
          Context.SessionXDL.DeleteItem;
          //AS_LOG(Context, cnLog_Debug, 201204150209,'Deleted a Item from SessionXDL','',SOURCEFILE);
        end;
      end;
      Context.bSaveSessionData:=true;
    end
    else
    begin
      Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDIT@]','');
      Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDITITEMS@]','');
    end;

    //------------------------------------------------------------------------------- EDIT MODE
    if bOk and (uMode=cnJBlokMode_New) then
    begin
      bOk:=(u8Val(rJTable.JTabl_Add_JSecPerm_ID)=0) or (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Add_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200219,'You are not authorized to ADD records in thie screen.'+
          'Screen ID:'+JScreen.rJScreen.JScrn_JScreen_UID+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMOde_Edit) then
    begin
      bOk:=(u8Val(rJTable.JTabl_Update_JSecPerm_ID)=0) or (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Update_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200220,'You are not authorized to EDIT records in this screen. '+
          'Screen ID:'+JScreen.rJScreen.JScrn_JScreen_UID+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMode_Delete) then
    begin
      bOk:=(u8Val(rJTable.JTabl_Delete_JSecPerm_ID)=0) or (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Delete_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200221,'You are not authorized to DELETE records in this screen. '+
          'Screen ID:'+JScreen.rJScreen.JScrn_JScreen_UID+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMode_Edit) then
    begin
      bOk:=bJAS_LockRecord(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020036);
      If not bOk Then
      Begin
        JAS_Log(Context,cnLog_Error,200701071725,'This RECORD is already locked by some one. Mode: '+saMode+' '+
          '<a href="javascript: window.history.back()">Go Back To View Mode.</a> <br /><br />Diagnostic '+
          'Info: Table:'+rJTable.JTabl_Name+' UID:'+rAudit.saUID+' JSess_JSession_UID:'+Context.rJSession.JSess_JSession_UID+
          ' Session Valid:'+saYesNo(Context.bSessionValid),'',SOURCEFILE);
      End;
    end;

    if bOk and ((uMode = cnJBlokMode_Save) or (uMode = cnJBlokMode_SaveNClose) or (uMode=cnJBlokMode_SaveNNew))and (rAudit.saUID<>'')then
    begin
      bOk:=bJAS_RecordLockValid(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020050);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201002022345,'This RECORD LOCK could not be verified. Mode: '+saMode+' '+
          '<a href="javascript: window.history.back()">Go Back To View Mode.</a> <br /><br />Diagnostic '+
          'Info: Table:'+rJTable.JTabl_Name+' UID:'+rAudit.saUID+' JSess_JSession_UID:'+Context.rJSession.JSess_JSession_UID+
          ' Session Valid:'+saYesNo(Context.bSessionValid),'',SOURCEFILE);
      end;
    end;
    //------------------------------------------------------------------------------- EDIT MODE



    //------------------------------------------------------------------------------- PERFORM DETAIL SCREEN ACTIONS
    If bOk and (uMode=cnJBlokMode_Delete) then bOk:=bRecord_DetailDeleteRecord;
    If bOk and (uMode=cnJBlokMode_Deleted) and (not JScreen.bPageCompleted) Then DataBlok_DetailDeletedRecord;
    If bOk and ((uMode=cnJBlokMode_Cancel)or(uMode=cnJBlokMode_CancelNClose))  and (not JScreen.bPageCompleted) Then
    begin
      if bMultiMode then
      begin
        if Context.SessionXDL.MoveFirst then
        begin
          repeat
            if Context.SessionXDL.ITem_saName=saSectionBottom then
            begin
              //Context.SessionXDL.Item_saValue;
              bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, Context.SessionXDL.Item_saValue,'0',201501020037);
            end;
          until (not bOk) or (not Context.SessionXDL.MoveNext);
        end;
      end;
      DataBlok_DetailCancel;
    end;
    if bOk and (uMode=cnJBlokMode_New)     and (not JScreen.bPageCompleted) then bOk:=bRecord_Query;

    If bOk and ((uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (uMode=cnJBlokMode_SaveNNew)) and (not JScreen.bPageCompleted) then
    begin
      //AS_Log(Context,cnLog_ebug,201203040537,' ABOUT to SAVE bRecordQuery uMode:'+ IntToStr(uMode),'',SOURCEFILE);
      bOk:=bRecord_Query;
      if bOk then
      begin
        //AS_Log(Context,cnLog_ebug,201203040537,' after SAve New Choice uMode:'+ IntToStr(uMode),'',SOURCEFILE);
        if (not bMultiMode) and (uMode=cnJBlokMode_Save) then
        begin
          //AS_Log(Context,cnLog_ebug,201203040537,' Choice go to view mode uMode:'+ IntToStr(uMode),'',SOURCEFILE);
          uMode:=cnJBlokMode_View;
        end
        else
        begin
          rAudit.saUID:='';
          //AS_Log(Context,cnLog_ebug,201203040537,' ABOUT to call DetailCancel after Save uMode:'+ IntToStr(uMode),'',SOURCEFILE);
          if (uMode<>cnJBlokMode_SaveNNew) then
          begin
            DataBlok_DetailCancel;
          end
          else
          begin
            bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020038);
            JScreen.bPageCompleted:=false;
            uMode:=cnJBlokMode_New;
            rAudit.saUID:='';
          end;
        end;
      end;
      //else
      //begin
      //  JAS_LOG(Context, cnLOG_Debug,201209242354,'bRecord_Query in Execute Datablock failed, skipping unlock','',SOURCEFILE);
      //end;
    end;
    If bOk and (uMODE=cnJBlokMode_View)    and (not JScreen.bPageCompleted) Then bOk:=bRecord_Query;
    If bOk and (uMODE=cnJBlokMode_Edit)    and (not JScreen.bPageCompleted) Then bOk:=bRecord_Query;
    If bOk and (not JScreen.bPageCompleted)Then
    Begin
      bOk:=bRecord_LoadDataIntoWidgets;
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203040537,'bRecord_LoadDataIntoWidgets','',SOURCEFILE);
      end;
    End;
    //------------------------------------------------------------------------------- PERFORM DETAIL SCREEN ACTIONS


    if bOk then
    begin
      //------------------------------------------------------------------------------- RENDER BUTTONS
      if BXDL.MoveFirst then
      begin
        saButtons+='<ul class="jas-blok-buttons">'+csCRLF;
        repeat
          u2JButtonType:=u2Val(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_JButtonType_ID);
          sa:='';
          if (u2JButtonType=cnJBlokButtonType_Save) or
             (u2JButtonType=cnJBlokButtonType_SaveNClose) or
             (u2JButtonType=cnJBlokButtonType_SaveNNew) then
          begin
            if bPreventSaveButton then
            begin
              sa:='<li><a href="javascript: alert(''Please resolve JWidget Errors. We are preventing you from saving for fear of corrupting your data.'');">'+
                '<img class="image" src="'+TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_GraphicFileName+'" />'+
                '<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
            end;
          end;

          Case u2JButtonType Of
          cnJBlokButtonType_Save: begin
            if (uMode=cnJBlokMode_New) and
               ((u8Val(rJTable.JTabl_Add_JSecPerm_ID)=0) or
               (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Add_JSecPerm_ID)))) then
            begin
              if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
            end
            else
            begin
              if (uMode=cnJBlokMode_Edit) and
               ((u8Val(rJTable.JTabl_Update_JSecPerm_ID)=0) or
               (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Update_JSecPerm_ID)))) then
              begin
                if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
              end;
            end;
          end;
          cnJBlokButtonType_SaveNClose,cnJBlokButtonType_SaveNNew: begin
            if ((uMode=cnJBlokMode_Edit) or (uMode=cnJBlokMode_New))and (not bMultiMode) and
             ((u8Val(rJTable.JTabl_Update_JSecPerm_ID)=0) or
             (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Update_JSecPerm_ID)))) then
            begin
              if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
            end;
          end;
          cnJBlokButtonType_Delete: If (uMode=cnJBlokMode_View) and ((u8Val(rJTable.JTabl_Delete_JSecPerm_ID)=0) or
                              (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Delete_JSecPerm_ID)))) then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Cancel: If (uMode=cnJBlokMode_New) OR (uMode=cnJBlokMode_Edit) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_CancelNClose: If ((uMode=cnJBlokMode_Edit)or(uMode=cnJBlokMode_New)) and (not bMultiMode) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Edit: If ((uMode=cnJBlokMode_View)or(uMode=cnJBlokMode_Save)) and ((u8Val(rJTable.JTabl_Update_JSecPerm_ID)=0) or
                         (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Update_JSecPerm_ID)))) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Close: If (uMode=cnJBlokMode_View) or (uMode=cnJBlokMode_Save) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
          cnJBlokButtonType_Custom: If (uMode=cnJBlokMode_View) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
          cnJBlokButtonType_ReloadPage: If (uMode=cnJBlokMode_View) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          End;// case
        until not BXDL.MoveNext;
        saButtons+='</ul>'+csCRLF;
      end
      else
      begin
        saButtons+='<p>---</p>';
      end;
      //------------------------------------------------------------------------------- RENDER BUTTONS


      //------------------------------------------------------------------------------- PREPARE OUTPUT
      saHeader:=saSNRStr(saHeader,'[@DETAILCAPTION@]',saCaption);
      if JScreen.bEditMode then
      begin
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_JBLOK_UID@]',rJBlok.JBlok_JBlok_UID);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_JTABLE_ID@]',rJBlok.JBlok_JTable_ID);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_NAME@]',rJBlok.JBlok_Name);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBlok_JBlokType_ID@]',rJBlok.JBlok_JBlokType_ID);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_CUSTOM@]',rJBlok.JBlok_Custom);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_JCAPTION_ID@]',rJBlok.JBlok_JCaption_ID);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_ICONSMALL@]',rJBlok.JBlok_IconSmall);
        saHeader:=saSNRStr(saHeader,'[@DETAILADMIN_JBLOK_ICONLARGE@]',rJBlok.JBlok_IconLarge);
      end;
      saSectionTop:=saSNRStr(saSectionTop,'[$BLOKDETAILHEADER$]',saHeader);
      saSectionTop:=saSNRSTR(saSectionTop,'[$BLOKDETAIL$]',saContent);
      saDetailBlok:=saSNRStr(saSectionMiddle, '[$BLOKBUTTONS$]',saButtons);
      saDetailBlok:=saSNRStr(saDetailBlok, '[$BLOKDETAILSECTION$]',saSectionTop);

      saDetailBloks:=saDetailBloks+saDetailBlok;
      JScreen.saTemplate:=saSNRStr(JScreen.saTemplate, '[$SCREENHEADER$]', JScreen.saScreenHeader);
      JScreen.saTemplate:=saSNRStr(JScreen.saTemplate, '[$DETAILBLOKS$]', saDetailBloks);
      Context.PAGESNRXDL.AppendItem_SNRPair('[@UID@]',rAudit.saUID);
      Context.PAGESNRXDL.AppendItem_SNRPair('[@MULTIEDITHEADER@]',saFooter);
      //JAS_Log(Context,cnLog_EBUG,201003040537,'uid SENT:'+rAudit.saUID,'',SOURCEFILE);
      If (not JScreen.bPageCompleted) and (uMode=cnJBlokMode_New) Then
      Begin
        Context.saPagetitle:='NEW - ' +Context.saPagetitle;
      End;
      //------------------------------------------------------------------------------- PREPARE OUTPUT
    end;
  end;//if not bDone from top
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102577,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//==============================================================================
function TJBLOK.bRecord_DetailDeleteRecord: boolean;
//==============================================================================
var
  bOk: boolean;
  //saQry: Ansistring;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.DataBlok_DetailDeleteRecord: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102554,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102555, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=(u8Val(rJTable.JTabl_Delete_JSecPerm_ID)=0) or (bJAS_HasPermission(Context,u8Val(rJTable.JTabl_Delete_JSecPerm_ID)));
  if bok then JAS_Log(Context,cnLog_Debug,201503121512,'bRecord_DetailDeleteRecord - req Delete Perm ID: '+rJTable.JTabl_Delete_JSecPerm_ID,'',SOURCEFILE);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201203070814,'You are not authorized to delete records in this screen. '+
      'Screen ID:'+JScreen.rJScreen.JScrn_JScreen_UID+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
  end;

  if bOk then
  begin
    // Attempt The Delete Here
    bOk:=bJAS_LockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020039);
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200701071246,'Unable to Lock Record at this time. Table: ' + rJTable.JTabl_Name +
        ' Record UID: ' + rAudit.saUID,'',SOURCEFILE);
    End;
  end;

  if bOk then
  begin
    bOk:=bRecord_SecurityCheck(rAudit.saUID,cnRecord_Delete);
    if bok then JAS_Log(Context,cnLog_Debug,201503121513,'bRecord_SecurityCheck rAudit.saUID: '+rAudit.saUID,'',SOURCEFILE);
    JAS_Log(Context,cnLog_Debug,201503121448,'Deleting if bRecord_SecurityScheck('+rAudit.saUID,'',SOURCEFILE);
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201003241044,'You are not authorized to delete this record.','Table: ' + rJTable.JTabl_Name+' UID: '+rAudit.saUID, SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bPreDelete(rJTable.JTabl_Name,rAudit.saUID);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201205300848,'bPreDelete called from Detail Screen Failed. Table: '+
        rJTable.JTabl_Name+' UID: '+ rAudit.saUID,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_DeleteRecord(Context,TGT, rJTable.JTabl_Name,rAudit.saUID);
    if not bOk then
    begin
      if Context.u8ErrNo<>201203262012 then
      begin
        JAS_Log(Context,cnLog_Error,200701071250,'Unable to delete record from table: ' + rJTable.JTabl_Name +
            ' UID Column: '+rJColumn_Primary.JColu_Name +' Record UID: ' + rAudit.saUID,'',SOURCEFILE);
      end;
    End;
  end;
  bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020040);
  If bOk Then
  Begin
    uMode:=cnJBlokMode_Deleted;
  End;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102556,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================






//==============================================================================
Procedure TJBLOK.DataBlok_DetailDeletedRecord;
//==============================================================================
var
  JScreen: TJSCREEN;
  Context:TCONTEXT;
  i4FindMe: longint;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='DataBlok_DetailDeletedRecord'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102556,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102557, sTHIS_ROUTINE_NAME);{$ENDIF}

  i4FindMe:=cnJBlokButtonType_Delete;
  if BXDL.FoundBinary(@i4FindMe, SizeOf(i4FindMe), @TJBLOKBUTTON(nil).rJBlokButton.JBlkB_JButtonType_ID, true, true)  AND
    (length(trim(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL))>0)
  Then
  Begin
    Context.CGIENV.Header_Redirect(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL,garJVHostLight[Context.i4VHost].saServerIdent);
    JScreen.bPageCompleted:=True;//NOTE: Only When REALLY Done.
  End
  Else
  Begin
    Context.saPage:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DELETED',False,123020100016);
    JScreen.bPageCompleted:=True;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102558,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================





//==============================================================================
Procedure TJBLOK.DataBlok_DetailCancel;
//==============================================================================
var
  i4FindMe: longint;
  JScreen: TJSCREEN;
  Context:TCONTEXT;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.DataBlok_DetailCancel;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102559,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102560, sTHIS_ROUTINE_NAME);{$ENDIF}

  if bMultiMode then
  begin
    if Context.CGIENV.DataIn.MoveFirst then
    begin
      repeat
        //JAS_Log(Context,cnLog_ebug,201104080802,'MultiEdit - SessionXDL.ITem_saName: '+Context.SessionXDL.ITem_saName,'',SOURCEFILE);
        if Context.CGIENV.DataIn.ITem_saName=saSectionBottom then
        begin
          bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, Context.CGIENV.DataIn.Item_saValue,'0',201501020041);
        end;
      until not Context.CGIENV.DataIn.MoveNext;
      Context.saPage:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'ADDNEWCANCEL',False,123020100017);
      JScreen.bPageCompleted:=True;
    end;
  end else

  If (u8Val(rAudit.saUID)=0) or (uMode=cnJBlokMode_CancelNClose) or (uMode=cnJBlokMode_SaveNClose) Then // CANCEL ADDNEW
  Begin
    if (uMode=cnJBlokMode_CancelNClose) then
    begin
      bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020042);
      i4FindMe:=cnJBlokButtonType_CancelNClose;
    end else

    // NOT NEEDED HERE - happens in the SAVE Portion and seems to have ZERO in rAUDIT.saUID
    // HERE in this mode.
    //if (uMode=cnJBlokMode_SaveNClose) then
    //begin
    //  ASPrintln('JASON - 0015 - UNLOCK');
    //  bJAS_UnLockRecord(Context, JScreen.DBC.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020043);
    //  i4FindMe:=cnJBlokButtonType_CancelNClose;
    //end else

    begin
      i4FindMe:=cnJBlokButtonType_Cancel;
    end;
    if BXDL.FoundBinary(@i4FindMe, SizeOf(i4FindMe), @TJBLOKBUTTON(nil).rJBlokButton.JBlkB_JButtonType_ID, true, true)  AND
      (length(trim(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL))>0)
    Then
    Begin
      Context.CGIENV.Header_Redirect(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL,garJVHostLight[Context.i4VHost].saServerIdent);
      JScreen.bPageCompleted:=True;//NOTE: Only When REALLY Done.
    End
    Else
    Begin
      Context.saPage:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'ADDNEWCANCEL',False,123020100017);
      JScreen.bPageCompleted:=True;
    End;
  End
  Else
  Begin
    // User Canceled from EDIT MODE. So, Make it VIEW MODE
    bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020044);
    uMode:=cnJBlokMode_View;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOut(201203102561,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================










//==============================================================================
function TJBLOK.bRecord_PreUpdate(p_saUID: ansistring): boolean;
//==============================================================================
var
  bOk: Boolean;
  JScreen: TJSCREEN;
  Context:TCONTEXT;
  
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bRecord_PreUpdate: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201209131346,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201209131347, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  //ASPRintLn('TJBLOK.bRecord_PreUpdate - JScreen.rJScreen.JScrn_JScreen_UID: '+JScreen.rJScreen.JScrn_JScreen_UID);
  case u8Val(JScreen.rJScreen.JScrn_JScreen_UID) of
  //---------------------------------------------------------------------------
  // juser PRE SAVE
  //---------------------------------------------------------------------------
  cs_juser_Data: begin // JUser Detail Screen
    if FXDL.FoundItem_saName('JUser_Name') then
    begin
      //ASPrintln('TJBLOK.bRecord_PreUpdate - FXDL: JUser_Name: '+FXDL.Item_saValue);
      bOk:=DBC.u8GetRowCount('juser','((JUser_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+
        ')or(JUser_Deleted_b IS NULL)) AND JUser_Name='+DBC.saDBMSScrub(FXDL.Item_saValue),201506171778)=0;
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error,201212040908,'Duplicate Username. Please enter a new username.','',SOURCEFILE);
      end;
    end;
  end;//case
  //---------------------------------------------------------------------------
  // juser PRE SAVE
  //---------------------------------------------------------------------------
  
  
  
  end;//switch
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201209131348,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================












//==============================================================================
function TJBLOK.bRecord_PostUpdate(p_saUID: ansistring): boolean;
//==============================================================================
var
  bOk: Boolean;
  JScreen: TJSCREEN;
  Context:TCONTEXT;
  saQry: ansistring;
  dt: TDateTime;// used for Date Math with JTask Special Code
  rJTask: rtJTask;
  rJJobQ: rtJJobQ;
  rJMail: rtJMAil;
  rs: JADO_RECORDSET;
  //rJSecGrpUserLink: rtJSecGrpUserLink;
  //saJMailFrom: ansistring;
  bCreator: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bRecord_PostUpdate: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102545,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102546, sTHIS_ROUTINE_NAME);{$ENDIF}
  
  p_saUID:=saStr(u8Val(p_saUID));
  
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  case u8Val(JScreen.rJScreen.JScrn_JScreen_UID) of
  //---------------------------------------------------------------------------
  // JTASK POST SAVE
  //---------------------------------------------------------------------------
  cs_jtask_Data: begin // JTask Detail Screen
    // JAS Version of bJAS_Load_JTask will do well loading fields into record
    // JTask_Owner_JUser_ID - this is the assigned user in the form
    if Context.CGIENV.DataIn.MoveFirst then
    begin
      repeat
        if Context.CGIENV.DataIn.Item_saName='DBLOK1751' then 
        begin
          //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
          //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
          //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
          //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
          clear_jtask(rJTask);
          rJTask.JTask_JTask_UID:=p_saUID;//make sure no left padded zeros
          //ASPrintLn('rJTask.JTask_JTask_UID: >'+rJTask.JTask_JTask_UID+'<\');
          bOk:=bJAS_Load_JTask(Context, DBC, rJTask, false);
          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201110121313,'Trouble loading record via bJAS_Load_JTask p_saUID: '+rAudit.saUID,'',SOURCEFILE);
          end;
          bCreator:=Context.CGIENV.DataIn.Item_saValue=rJTask.JTask_Owner_JUser_ID;
          //ASPrintLn('Context.CGIENV.DataIn.Item_saValue: >'+Context.CGIENV.DataIn.Item_saValue+'<\');
          //ASPrintLn('rJTask.JTask_Owner_JUser_ID: >'+rJTask.JTask_Owner_JUser_ID+'<\');
                  
          if bOk then
          begin
             
            if not bCreator then           
            begin
              rJTask.JTask_Owner_JUser_ID:=Context.CGIENV.DataIn.Item_saValue;                 
              rJTask.JTask_JTask_UID:='0';//force new record
              bOk:=bJAS_Save_Jtask(context,dbc,rJTask,false,false);
              if not bok then
              begin
                JAS_Log(Context,cnLog_Error,201507010324,'Trouble saving task with multiple owners rJTask.JTask_JTask_UID: '+rJTask.JTask_JTask_UID,'',SOURCEFILE);
              end;
            end;  
            //ASPrintln('Creator: '+saYesNo(bCreator));
            //ASPrintLn('rJTask.JTask_JTask_UID: >'+rJTask.JTask_JTask_UID+'<\');
            //ASPRintln('rJTask.JTask_Owner_JUser_ID:'+rJTask.JTask_Owner_JUser_ID);
            
          end;
    
          // Wipe out jobq with this task id - should work after multi-user assign cuz the task uid
          // field is updated on a save (on save new the new one is returned, not the zero)
          if bOk then
          begin
            saQry:='select JJobQ_JJobQ_UID from jjobq where JJobQ_JTask_ID='+rJTask.JTask_JTask_UID+
              ' AND JJobQ_Completed_b<>'+DBC.saDBMSBoolScrub(true)+' AND JJobQ_Deleted_b<>'+DBC.saDBMSBOOLSCrub(true);
            bOk:=rs.open(saQry, DBC,201503161519);
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Error, 201203261217,'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
            end;

            if bOk and (not rs.eol) then
            begin
              repeat
                bOk:=bJAS_DeleteRecord(Context,DBC, 'jjobq',rs.fields.Get_saValue('JJobQ_JJobQ_UID'));
                if not bOk then
                begin
                  JAS_Log(Context,cnLog_Error,201110121317,'Trouble deleting from jjobq table. JJobQ_JJobQ_UID: '+rs.fields.Get_saValue('JJobQ_JJobQ_UID'),'',SOURCEFILE);
                end;
              until (not bOk) or (not rs.movenext);
            end;
            rs.close;

            // Make sure message should be sent but wasnt sent already AND that the TASK isn't completed.
            if bOk and bVal(rJTask.JTask_SendReminder_b) and (not bVal(rJTask.JTask_ReminderSent_b)) and (iVal(rJTask.JTask_JStatus_ID)<>3) then
            begin
              try
                dt:=StrToDateTime(JDATE(rJTask.JTask_Start_DT,1,11));
              except on E : EConvertError do begin  
                dt:=now;
                rJTask.JTask_Start_DT:=JDATE('',11,0,dt);
                saQry:='update jtask set JTask_Start_DT='+DBC.saDBMSDateScrub(rJTask.JTask_Start_DT)+' where JTask_JTask_UID='+DBC.saDBMSUIntScrub(rJTask.JTask_JTask_UID);
                bOk:=rs.open(saQry,DBC,201506132229);
                if not bOk then 
                begin
                  JAS_Log(Context,cnLog_Error,201506132230,'Unable to save start date in jtask record. UID: '+rJTask.JTask_JTask_UID,'',SOURCEFILE);
                end;
                rs.close;
              end;//try
            end;

            try
              dt:=StrToDateTime(JDATE(rJTask.JTask_Start_DT,1,11));
            except on E : EConvertError do bOk:=false;
            end;//try
        
        
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Error, 201205302108, 'Invalid Start Date - Unable to schedule Reminder Email','',SOURCEFILE);
            end;

            if bOk then
            begin
              dt:=dtAddDays(dt,-1*ival(rJTask.JTask_Remind_DaysAhead_u));
              dt:=dtAddHours(dt,-1*ival(rJTask.JTask_Remind_HoursAhead_u));
              dt:=dtAddMinutes(dt,-1*ival(rJTask.JTask_Remind_MinutesAhead_u));
              clear_JJobQ(rJJobQ);
              with rJJobQ do begin
                //JJobQ_JJobQ_UID           :=
                JJobQ_JUser_ID            :=rJTask.JTask_Owner_JUser_ID;
                JJobQ_JJobType_ID         :='1';//General
                JJobQ_Start_DT            :=saFormatDateTime(csDATETIMEFORMAT,DT);
                JJobQ_ErrorNo_u           :='0';
                JJobQ_Started_DT          :='NULL';
                JJobQ_Running_b           :='false';
                JJobQ_Finished_DT         :='NULL';
                JJobQ_Name                :=rJTask.JTask_Name;
                JJobQ_Repeat_b            :=rJTask.JTask_Remind_Persistantly_b;
                JJobQ_RepeatMinute        :='10/*';
                JJobQ_RepeatHour          :='*';
                JJobQ_RepeatDayOfMonth    :='*';
                JJobQ_RepeatMonth         :='*';
                JJobQ_Completed_b         :='false';
                JJobQ_Result_URL          :='';
                JJobQ_ErrorMsg            :='';
                JJobQ_ErrorMoreInfo       :='';
                JJobQ_Enabled_b           :='true';
                JJobQ_Job                 :=
                  '<CONTEXT>'+
                  '  <saRequestMethod>GET</saRequestMethod>'+
                  '  <saQueryString>jasapi=email&type=taskreminder&UID='+
                  rJTask.JTask_JTask_UID+'</saQueryString>'+
                  '  <saRequestedFile>'+Context.saAlias+'</saRequestedFile>'+
                  '</CONTEXT>';
                JJobQ_Result              :='NULL';
                //JJobQ_CreatedBy_JUser_ID  :=
                //JJobQ_Created_DT          :=
                //JJobQ_ModifiedBy_JUser_ID :=
                //JJobQ_Modified_DT         :=
                //JJobQ_DeletedBy_JUser_ID  :=
                //JJobQ_Deleted_DT          :=
                //JJobQ_Deleted_b           :=
                JAS_Row_b                 :='false';
                JJobQ_JTask_ID            :=rJTask.JTask_JTask_UID;
              end;//with

              if bOk then
              begin
                bOk:=bJAS_Save_JJobQ(Context, DBC, rJJobQ, false,false);
                if not bOk then
                begin
                  JAS_Log(Context,cnLog_Error,201110121734,'Unable to SAVE the jobq reminder email record.','',SOURCEFILE);
                end;
              end;
            end;
          end;
        end;
      end;
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================    
    until not Context.CGIENV.DataIn.Movenext;
    end;
  end;//case
  //---------------------------------------------------------------------------
  // JTASK POST SAVE
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // JUSER POST SAVE
  //---------------------------------------------------------------------------
  cs_juser_Data: begin
    //if DBC.u8GetRowCount(
    //  'jsecgrpuserlink',
    //  'JSGUL_JUser_ID='+p_saUID+' and JSGUL_JSecGrp_ID='+inttostR(cnJSecGrp_Standard)
    //)=0 then
    //begin
    //  clear_JSecGrpUserLink(rJSecGrpUserLink);
    //  rJSecGrpUserLink.JSGUL_JUser_ID:=p_saUID;
    //  rJSecGrpUserLink.JSGUL_JSecGrp_ID:=inttostR(cnJSecGrp_Standard);
    //  bOk:=bJAS_Save_JSecGrpUserLink(Context, DBC, rJSecGrpUserLink, false, false);
    //  if not bOk then
    //  begin
    //    JAS_Log(Context,cnLog_Error,201205022347,'Trouble adding new user to Standard Security Group. p_saUID: '+p_saUID,'',SOURCEFILE);
    //  end;
    //end;
  end;
  //---------------------------------------------------------------------------
  // JUSER POST SAVE
  //---------------------------------------------------------------------------

  
  
  
  //---------------------------------------------------------------------------
  // JMAIL 
  //---------------------------------------------------------------------------
  cs_jmail_Data: begin
    clear_JMail(rJMail);
    rJMail.JMail_JMail_UID:=p_saUID;
    bOk:=bJAS_Load_jmail(Context, DBC, rJMail,false);
    if not bok then
    begin
      JAS_Log(Context,cnLog_Error,201506111316,'post update failed to load jmail UID: '+p_saUID,'',SOURCEFILE);
    end;
    
    if bOk then
    begin
      //with rJMail do begin
      //  asprintln('-begin-');
      //  asprintln('JMail_JMail_UID:'+JMail_JMail_UID);
      //  asprintln('JMail_Message:'+JMail_Message                ); 
      //  asprintln('JMail_To_User_ID:'+JMail_To_User_ID              );
      //  asprintln('JMail_From_User_ID:'+JMail_From_User_ID            );
      //  asprintln('JMail_Message_Code:'+JMail_Message_Code            );
      //  asprintln('JMail_CreatedBy_JUser_ID:'+JMail_CreatedBy_JUser_ID      );
      //  asprintln('JMail_Created_DT:'+JMail_Created_DT              );
      //  asprintln('JMail_ModifiedBy_JUser_ID:'+JMail_ModifiedBy_JUser_ID     );
      //  asprintln('JMail_Modified_DT:'+JMail_Modified_DT             );
      //  asprintln('JMail_DeletedBy_JUser_ID:'+JMail_DeletedBy_JUser_ID      );
      //  asprintln('JMail_Deleted_DT:'+JMail_DeletedBy_JUser_ID              );
      //  asprintln('JMail_Deleted_b:'+JMail_DeletedBy_JUser_ID               );
      //  asprintln('JAS_Row_b:'+JMail_DeletedBy_JUser_ID                     );
      //  asprintln('-end-');
      //end;
    
      if u8Val(rJMail.JMail_Message_Code)=0 then
      begin
        rJMail.JMail_Message_Code:=saJAS_GetNextUID;
        rJMAil.JMail_From_User_ID:=saStr(Context.rJUser.JUser_JUser_UID);
        bOk:=bJAS_Save_jmail(Context, DBC, rJMail,true,false);
        if not bok then
        begin
          JAS_Log(Context,cnLog_Error,200106111317,'main new mail rec did not update: '+p_saUID,'',SOURCEFILE);
        end;

        //with rJMail do begin
        //  asprintln('-begin-after updaTE record 1');
        //  asprintln('JMail_JMail_UID:'+JMail_JMail_UID);
        //  asprintln('JMail_Message:'+JMail_Message                ); 
        //  asprintln('JMail_To_User_ID:'+JMail_To_User_ID              );
        //  asprintln('JMail_From_User_ID:'+JMail_From_User_ID            );
        //  asprintln('JMail_Message_Code:'+JMail_Message_Code            );
        //  asprintln('JMail_CreatedBy_JUser_ID:'+JMail_CreatedBy_JUser_ID      );
        //  asprintln('JMail_Created_DT:'+JMail_Created_DT              );
        //  asprintln('JMail_ModifiedBy_JUser_ID:'+JMail_ModifiedBy_JUser_ID     );
        //  asprintln('JMail_Modified_DT:'+JMail_Modified_DT             );
        //  asprintln('JMail_DeletedBy_JUser_ID:'+JMail_DeletedBy_JUser_ID      );
        //  asprintln('JMail_Deleted_DT:'+JMail_DeletedBy_JUser_ID              );
        //  asprintln('JMail_Deleted_b:'+JMail_DeletedBy_JUser_ID               );
        //  asprintln('JAS_Row_b:'+JMail_DeletedBy_JUser_ID                     );
        //  asprintln('-end-');
        //end;
        
        
        if bOk then
        begin
          rJMail.JMail_JMail_UID:='';
          bOk:=bJAS_Save_jmail(Context, DBC, rJMail,true,false);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,200106111318,'second mail rec did not save.','',SOURCEFILE);
          end;
          //with rJMail do begin
          //  asprintln('-begin-after record 2');
          //  asprintln('JMail_JMail_UID:'+JMail_JMail_UID);
          //  asprintln('JMail_Message:'+JMail_Message                ); 
          //  asprintln('JMail_To_User_ID:'+JMail_To_User_ID              );
          //  asprintln('JMail_From_User_ID:'+JMail_From_User_ID            );
          //  asprintln('JMail_Message_Code:'+JMail_Message_Code            );
          //  asprintln('JMail_CreatedBy_JUser_ID:'+JMail_CreatedBy_JUser_ID      );
          //  asprintln('JMail_Created_DT:'+JMail_Created_DT              );
          //  asprintln('JMail_ModifiedBy_JUser_ID:'+JMail_ModifiedBy_JUser_ID     );
          //  asprintln('JMail_Modified_DT:'+JMail_Modified_DT             );
          //  asprintln('JMail_DeletedBy_JUser_ID:'+JMail_DeletedBy_JUser_ID      );
          //  asprintln('JMail_Deleted_DT:'+JMail_DeletedBy_JUser_ID              );
          //  asprintln('JMail_Deleted_b:'+JMail_DeletedBy_JUser_ID               );
          //  asprintln('JAS_Row_b:'+JMail_DeletedBy_JUser_ID                     );
          //  asprintln('-end-');
          //end;
        end;
        
      
        if bOk then
        begin
          saQry:='update jmail set JMail_CreatedBy_JUser_ID='+rJMail.JMail_To_User_ID+' where JMail_JMail_UID='+rJMail.JMail_JMail_UID;
          bOk:=rs.open(saQry,dbc,201506112019);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,201506112020,'unable to assign mail to recipient: '+rJMail.JMail_To_User_ID,'',SOURCEFILE);
          end;
        end;  
      end;
    end;
    //---------------------------------------------------------------------------
    // JMAIL
    //---------------------------------------------------------------------------
  end;//case
  
  
  
  
  
  
  
  
  
  
  
  
  
  end;//switch
  //--- POST-UPDATE ----END

  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102547,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================






















//==============================================================================
function TJBLOK.bRecord_PreAdd: boolean;
//==============================================================================
var
  bOk: Boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bRecord_PreAdd: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  //Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201212101656,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201212101657, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  case u8Val(JScreen.rJScreen.JScrn_JScreen_UID) of
  cs_juser_Data: begin end;
  end;//switch
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201212101658,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================

























//==============================================================================
function TJBLOK.bRecord_Query: boolean;
//==============================================================================
var
  bOk: boolean;
  saQry: ansistring;    // rs2, saqry2 are for DBMS managed autonumber for new records
  saQry2: ansistring;
  saQrySNR: ansistring;
  u2JDTypeID: word;
  bPrimaryKey: boolean;
  bFoundItem: Boolean;
  saMyFields: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  JBlokField: TJBLOKFIELD;
  QXDL: JFC_XDL;
  bHaveKeyInFXDL: boolean;
  saNewKeyValue: ansistring;
  bOkToAddColumn: boolean;
  bNewRecord: boolean;

  JScreen: TJSCREEN;
  Context:TCONTEXT;
  bVisible: boolean;
 
  //bHaveSecPermColumnInSelect: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bRecord_DetailAddNew: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102565,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102566, sTHIS_ROUTINE_NAME);{$ENDIF}

  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  QXDL:=JFC_XDL.Create;
  bOk:=true;
  bNewRecord:=false;
  //bHaveSecPermColumnInSelect:=false;

  {
  JAS_LOG(Context, cnLog_debug, 201203211450, csCRLF+
    'JADOC Name:'+DBC.saName+csCRLF+
    'JADOC ID:'+DBC.ID+csCRLF+
    'Table Name:'+rJTable.JTabl_Name+csCRLF+
    'Table Con ID:'+rJTable.JTabl_JDConnection_ID+csCRLF+
    'TJBlok.bRecord_Query Entry'+csCRLF+
    'Mode: ' +saMode+csCRLF+
    'rAudit.saUID: '+rAudit.saUID+csCRLF+
    'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
    'rJColumn_Primary.JColu_JAS_Key_b: '+rJColumn_Primary.JColu_JAS_Key_b+csCRLF+
    'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
    'FXDL: '+FXDL.saHTMLTable+csCRLF
    ,'',SOURCEFILE);
  }
  

  if (not bMultiMode) and ((uMode=cnJBlokMode_Save)or(uMode=cnJBlokMode_SaveNClose)or(uMode=cnJBlokMode_SaveNNew)) then
  begin
    if (rAudit.saUID='') then
    begin
      //bNewRecord:=bVal(rJColumn_Primary.JColu_JAS_Key_b) and (rAudit.saUID='');
      bNewRecord:=bVal(rJColumn_Primary.JColu_PrimaryKey_b) and (rAudit.saUID='');
      if bNewRecord then
      begin
        rAudit.saUID:=saJAS_GetNextUID;//(Context,DBC.ID,rJBlok.JBlok_JTable_ID);
        bOk:=trim(rAudit.saUID)<>'';
        If not bOk Then
        Begin
          JAS_Log(Context,cnLog_Error,201003011349,'Unable to Create a New Unique Identifier (UID) for Table: ' + rJTable.JTabl_Name + ' TableID:'+
            rJBlok.JBlok_JTable_ID,'',SOURCEFILE);
        End;
        if bOk then
        begin
          if QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name) then
          begin
            QXDL.Item_saValue:=rAudit.saUID;
          end
          else
          begin
            QXDL.AppendItem_saName_N_saValue(rJColumn_Primary.JColu_Name,rAudit.saUID);
          end;
        end;
      end;
    end;
  end;

  If bOk Then
  Begin
    if FXDL.MoveFirst then
    begin
      bHaveKeyInFXDL:=false;
      saNewKeyValue:='';
      repeat
        FXDL.Item_saName:=TJBlokField(FXDL.Item_lpPtr).rJColumn.JColu_Name;
        FXDL.Item_saValue:=TJBlokField(FXDL.Item_lpPtr).saValue;

        JBlokfield:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        bVisible:=bVal(JBlokField.rJBlokField.JBlkF_Visible_b);
        bPrimaryKey:=JBlokfield.rJColumn.JColu_Name=rJColumn_Primary.JColu_Name;
        if bPrimaryKey then bHaveKeyInFXDL:=true;
        bFoundItem:=Context.CGIENV.DataIn.FoundItem_saName('DBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID);
        if u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
        begin
          if bFoundItem then
          begin
            if not bNewRecord then
            begin
              if bPrimaryKey then saNewKeyValue:=JBlokfield.saValue;
            end;
            JBlokfield.saValue:=JFC_XDLITEM(Context.CGIENV.DataIn.lpItem).saValue;
          End
          Else
          Begin
            if (bNewRecord or (uMode=cnJBlokMode_New)) and (not bMultiMode) then
            begin
              JBlokfield.saValue:=JBlokField.rJColumn.JColu_DefaultValue;
            end;
          end;

          bOkToAddColumn:=false;
          case uMode of
          cnJBlokMode_New:  bOkToAddColumn:=(not bPrimaryKey);
          cnJBlokMode_Save, cnJBlokMode_SaveNClose, cnJBlokMode_SaveNNew: begin
            if (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)) and (not ((bNewRecord) and (bPrimaryKey))) and (bVisible) then
            begin
              if not bMultiMode then
              begin
                bOkToAddColumn:=true;
              end
              else
              begin
                if Context.CGIENV.DataIn.FoundItem_saName('MECHK_'+JBlokField.rJBlokField.JBlkF_JBlokField_UID) then
                begin
                  bOkToAddColumn:=bVal(Context.CGIENV.DataIn.Item_saValue);
                end
              end;
            end;
          end;
          cnJBlokMode_View: bOkToAddColumn:=true;//bFoundItem;
          cnJBlokMode_Edit: bOkToAddColumn:=true;//bFoundItem;
          end;//switch;

          if bOkToAddColumn then
          begin
            QXDL.AppendItem_saName(JBlokField.rJColumn.JColu_Name);
            u2JDTypeID:=u2Val(JBlokField.rJColumn.JColu_JDType_ID);

            if bIsJDTypeBoolean(u2JDTypeID) or bIsJDTypeBoolean(u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID)) then
            begin
              QXDL.Item_saValue:=DBC.saDBMSBoolScrub(JBlokfield.saValue);
            End else

            if bIsJDTypeInt(u2JDTypeID) then
            begin
              QXDL.Item_saValue:=DBC.saDBMSIntScrub(JBlokfield.saValue)+' ';
            end else

            if bIsJDTypeUInt(u2JDTypeID) then
            begin
              QXDL.Item_saValue:=DBC.saDBMSUIntScrub(JBlokfield.saValue)+' ';
            end else

            if bIsJDTypeDec(u2JDTypeID) or bIsJDTypeCurrency(u2JDTypeID) then
            begin
              QXDL.Item_saValue:=DBC.saDBMSDecScrub(JBlokfield.saValue);
            End else

            if bIsJDTypeDate(u2JDTypeID) then
            begin
              QXDL.Item_saValue:=DBC.saDbmsDateScrub(JDate(JBlokfield.saValue,11,1));
            End
            else
            begin // treat as text
              QXDL.Item_saValue:=DBC.saDBMSScrub(JBlokfield.saValue)+' ';
            End;
          End;
        end;
      Until not FXDL.MoveNext;
    end;

    {
    JAS_LOG(Context, cnLog_ebug, 201203211450, csCRLF+
      'TJBlok.bRecord_Query MIDDLE'+csCRLF+
      'bMultiMode: ' +saYesNo(bMultiMode)+csCRLF+
      'Mode: ' +saMode+csCRLF+
      'rAudit.saUID: '+rAudit.saUID+csCRLF+
      'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
      'rJColumn_Primary.JColu_JAS_Key_b: '+rJColumn_Primary.JColu_JAS_Key_b+csCRLF+
      'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
      'QXDL: '+QXDL.saHTMLTable+csCRLF+
      'FXDL: '+FXDL.saHTMLTable+csCRLF
      ,'',SOURCEFILE);
    }

//qqq - THIS is where the saving starts


    if uMode<>cnJBlokMode_New then
    begin
      saQry:='';
      saMyFields:='';
      case uMode of
      cnJBlokMode_Save, cnJBlokMode_SaveNClose, cnJBlokMode_SaveNNew: begin
        if bNewRecord then //and (uMode=cnJBlokMode_Save) then
        begin
          if rAudit.bUse_CreatedBy_JUser_ID then
          begin
            if QXDL.FoundItem_saName(rAudit.saFieldName_CreatedBy_JUser_ID) then QXDL.DeleteItem;
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_CreatedBy_JUser_ID, DBC.saDBMSUIntScrub(Context.rJUser.JUser_JUser_UID));
          end;

          if rAudit.bUse_Created_DT then
          begin
            if QXDL.FoundItem_saName(rAudit.saFieldName_Created_DT) then QXDL.DeleteItem;
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Created_DT,DBC.saDBMSDateScrub(now));
          end;

          if rAudit.bUse_Deleted_b then
          begin
            if QXDL.FoundItem_saName(rAudit.saFieldName_Deleted_b) then QXDL.DeleteItem;
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Deleted_b,DBC.saDBMSBoolScrub(false));
          end;

          if bVal(rJColumn_Primary.JColu_JAS_Key_b) then
          begin
            if (not QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name)) then
            begin
              QXDL.AppendItem_saName_N_saValue(rJColumn_Primary.JColu_Name, rAudit.saUID);
            end;
          end
          else
          begin
            if bVal(rJColumn_Primary.JColu_AutoIncrement_b) then
            if QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name) then QXDL.DeleteItem;
          end;

          //if (not QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name)) and (bVal(rJColumn_Primary.JColu_JAS_Key_b)) and
          //   (bVal(rJColumn_Primary.JColu_AutoIncrement_b)) then

          QXDL.MoveFirst;
          repeat
            if saMyFields<>'' then saMyFields+=', ';
            saMyFields+=DBC.saDBMSEncloseObjectName(QXDL.Item_saName);
            if saQry<>'' then saQry+=', ';
            saQry+=QXDL.Item_saValue;
          until not QXDL.MoveNext;
          saQry:='INSERT INTO '+rJTable.JTabl_Name+' ( '+saMyFields+' ) VALUES ( '+saQry+' ) ';
          //JASprintln('insert JBLOK record: '+saQry);
          //insert JBLOK record: 
          //
          //INSERT INTO jtask ( `JTask_JTask_UID`, `JTask_Name`,    `JTask_Start_DT`,      `JTask_Due_DT`,`JTask_Completed_DT`, `JTask_Owner_JUser_ID`, `JTask_JStatus_ID`, `JTask_JPriority_ID`, `JTask_JTaskCategory_ID`, `JTask_Desc`, `JTask_ResolutionNotes`, `JTask_JProject_ID`, `JTask_Progress_PCT_d`, `JTask_JCase_ID`, `JTask_URL`, `JTask_Directions_URL`, `JTask_Milestone_b`, `JTask_Duration_Minutes_Est`, `JTask_SendReminder_b`, `JTask_Remind_DaysAhead_u`, `JTask_Remind_HoursAhead_u`, `JTask_Remind_MinutesAhead_u`, `JTask_Remind_Persistantly_b`, `JTask_ReminderSent_b`, `JTask_Related_JTable_ID`, `JTask_Related_Row_ID`, `JTask_CreatedBy_JUser_ID`,    `JTask_Created_DT`, `JTask_Deleted_b` ) VALUES 
          //               ( 01506302043498460000,      'test' , '00-00-00 00:00:00', '00-00-00 00:00:00', '00-00-00 00:00:00',                  null ,                 7 ,                   1 ,                       3 ,          '' ,                     '' ,               null ,                   null,            null ,         '' ,                    '' ,                   0,                           0 ,                      0,                         0 ,                          0 ,                            0 ,                             0,                      0,                     null ,                     0 ,                          1, '2015-06-30 20:43:49',                 0 ) 
    
    
          
        end
        else
        begin
          if not bMultiMode then
          begin
            bOk:=bRecord_SecurityCheck(rAudit.saUID,cnRecord_Edit);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201003241045,'You are not authorized to modify this record.','Table: ' + rJTable.JTabl_Name+' UID: '+rAudit.saUID, SOURCEFILE);
            end;
          end;

          if bOk then
          begin
            if rAudit.bUse_ModifiedBy_JUser_ID then
            begin
              if QXDL.FoundItem_saName(rAudit.saFieldName_ModifiedBy_JUser_ID) then QXDL.DeleteItem;
              QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_ModifiedBy_JUser_ID, DBC.saDBMSUIntScrub(Context.rJUser.JUser_JUser_UID));
            end;

            if rAudit.bUse_Modified_DT then
            begin
              if QXDL.FoundItem_saName(rAudit.saFieldName_Modified_DT) then QXDL.DeleteItem;
              QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Modified_DT,DBC.saDBMSDateScrub(now));
            end;

            saQry:='UPDATE ' +rJTable.JTabl_Name+' SET ' ;
            if QXDL.MoveFirst then
            begin
              repeat
                //if (not (QXDL.Item_saName=rJColumn_Primary.JColu_Name)) then
                //begin
                  if saMyFields<>'' then saMyFields+=', ';
                  saMyFields+=DBC.saDBMSEncloseObjectName(QXDL.Item_saName)+'='+QXDL.Item_saValue;
                //end;
              until not QXDL.MoveNext;
              saQry+=saMyFields;
              if bMultiMode then saQrySNR:=saQry;
              //JAsprint('Update JBlok REcord: '+saQry);
              // Update JBlok REcord: 
              // UPDATE jtask SET 
              //  `JTask_Name`='test' , 
              //  `JTask_Start_DT`='00-00-00 00:00:00', 
              //  `JTask_Due_DT`='00-00-00 00:00:00', 
              //  `JTask_Completed_DT`='00-00-00 00:00:00', 
              //  `JTask_Owner_JUser_ID`=null , 
              //  `JTask_JStatus_ID`=2 , 
              //  `JTask_JPriority_ID`=2 , 
              //  `JTask_JTaskCategory_ID`=3 , 
              //  `JTask_Desc`='' , 
              //  `JTask_ResolutionNotes`='' , 
              //  `JTask_JProject_ID`=null , 
              //  `JTask_Progress_PCT_d`=null, 
              //  `JTask_JCase_ID`=null , 
              //  `JTask_URL`='' , 
              //  `JTask_Directions_URL`='' , 
              //  `JTask_Milestone_b`=0, 
              //  `JTask_Duration_Minutes_Est`=0 , 
              //  `JTask_SendReminder_b`=0, 
              //  `JTask_Remind_DaysAhead_u`=0 , 
              //  `JTask_Remind_HoursAhead_u`=0 , 
              //  `JTask_Remind_MinutesAhead_u`=0 , 
              //  `JTask_Remind_Persistantly_b`=0, 
              //  `JTask_ReminderSent_b`=0, 
              //  `JTask_Related_JTable_ID`=null , 
              //  `JTask_Related_Row_ID`=0 , 
              //  `JTask_ModifiedBy_JUser_ID`=1, 
              //  `JTask_Modified_DT`='2015-06-30 20:54:40'
              
            end
            else
            begin
              saQry:='NOTHING TO SAVE';
            end;
          end;
        end;
      end;
      cnJBlokMode_View, cnJBlokMode_Edit: begin
        bOk:=bRecord_SecurityCheck(rAudit.saUID,cnRecord_Edit);
        //if not bOk then
        //begin
          //JAS_Log(Context,cnLog_Error,201003241053,'You are not authorized to view or edit this record.','Table: ' + rJTable.JTabl_Name+' UID: '+rAudit.saUID, SOURCEFILE);
        //end;

        if bOk then
        begin
          saQry:='SELECT ';
          // Build Select
          if QXDL.MoveFirst then
          begin
            repeat
              if saMyFields<>'' then saMyFields+=', ';
              saMyFields+= DBC.saDBMSEncloseObjectName(QXDL.Item_saName);
            until not QXDL.MoveNext;
            saQry+=saMyFields+' FROM ' + rJTable.JTabl_Name;
          end
          else
          begin
            saQry+=' 1 as One FROM ' + rJTable.JTabl_Name;
          end;
        end;
      end;
      end;//switch

      if (not bNewRecord) and (bOk)  then
      begin
        if ((rAudit.saUID<>'') and
           (rJColumn_Primary.JColu_Name<>'') and
           (rJColumn_Primary.JColu_Name<>'NULL')) or (bMultiMode) then
        begin
          if not bMultiMode then
          begin
            saQRY+=' WHERE '+rJColumn_Primary.JColu_Name+'='+rAudit.saUID;
          end
          else
          begin
            saQRY+=' WHERE '+rJColumn_Primary.JColu_Name+'=[@UID@]';
          end;
        end
        else
        begin
          //saQry+=' ';
        end;
      end;

      if (not bMultiMode) and bOk then
      begin
        if bNewRecord then
        begin
          Context.JTrakBegin(TGT, rJTable.JTabl_Name, '0');
        end
        else
        begin
          Context.JTrakBegin(TGT, rJTable.JTabl_Name, rAudit.saUID);
        end;

        //JAS_LOG(Context, cnLog_ebug, 201204030144, 'rAudit.saUID: '+rAudit.saUID+' DETAIL QUERY: '+saQry,'',SOURCEFILE);
        bOk:=rs.Open(saQry, TGT,201503161520);
        If not bOk Then
        Begin
          JAS_Log(Context,cnLog_Error,200701082228,'Detail Screen - Dynamic Query Failed.','Query: '+ saQry,SOURCEFILE, TGT,rs);
        End;

        if bOk then
        begin
          if bNewRecord and
             (not bVal(rJColumn_Primary.JColu_JAS_Key_b)) and
             (bVal(rJColumn_Primary.JColu_AutoIncrement_b)) then
          begin
            // SPECIAL CASE - Table using DBMS autonumber - not perfect
            // but need to TRY to recoupe our new autonumber so JTrak works and detail screen
            // can show more than a empty record.
            case DBC.u2DBMSID of
            cnDBMS_MySQL: begin
              saQry2:='SELECT '+rJColumn_Primary.JColu_Name+' FROM '+rJTable.JTabl_Name +
                      ' ORDER BY '+rJColumn_Primary.JColu_Name+' DESC LIMIT 1';
            end;
            cnDBMS_MSAccess, cnDBMS_MSSQL: begin
              saQry2:='SELECT TOP 1 '+rJColumn_Primary.JColu_Name+' FROM '+rJTable.JTabl_Name +
                      ' ORDER BY '+rJColumn_Primary.JColu_Name+' DESC';
            end
            else
            begin
              // gets whole result set but we can refine as more DBMS type added
              saQry2:='SELECT '+rJColumn_Primary.JColu_Name+' FROM '+rJTable.JTabl_Name +
                      ' ORDER BY '+rJColumn_Primary.JColu_Name+' DESC';
            end;
            end;//switch
            bOk:=rs2.open(saQry2, TGT,201503161521);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201204041734,'Query failed - DBMS managed autonumber retrival query after addnew.','Query: '+saQry2,SOURCEFILE, TGT, rs2);
            end;
            if bOk and (not rs2.eol) then
            begin
              rAudit.saUID:=rs2.fields.Get_saValue(rJColumn_Primary.JColu_JColumn_UID);
            end;
            rs2.close;
          end;

          if (uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (uMOde=cnJBlokMode_SaveNNew) then
          begin
            if QXDL.FoundItem_saName(rJColumn_PRimary.JColu_name) then
            begin
              rAudit.saUID:=QXDL.Item_saValue;
            end;
          end;

        end;
        Context.JTrakEnd(rAudit.saUID);
        if bOk and ((uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (umode=cnJBlokMode_SaveNNew)) then
        begin
          bOk:=bRecord_PostUpdate(rAudit.saUID);
          If not bOk Then
          Begin
            JAS_Log(Context,cnLog_Error,201203231930,'DataBlok Post Operation Failed. ','',SOURCEFILE);
          End;
        end;
      end;
    end;

    If bOk and (not bMultiMode) Then
    Begin
      if (uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (uMode=cnJBlokMode_SaveNNEw) then
      begin
        if (not bNewRecord) then
        begin
          //ASPrintln('JASON - TRYING UNLOCK 1206 - TJBLOK.bRecord_Query');
          //ASPrintln('JASON - 1206 - Table: '+rJBlok.JBlok_JTable_ID+' UID: '+rAudit.saUID);
          if not bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020045) then
          begin
            //ASPrintln('JASON - TRYING UNLOCK - WHOA DIDNT WORK');
          end;
          //ASPrintln('Lock Exist:'+inttostr(DBC.u8GetRowCount('jlock','JLock_Row_ID='+rAudit.saUID)));
          //ASPrintln('Lock Valid:'+saTrueFalse(bJAS_RecordLockValid(Context, DBC.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0')));
        end;
        if bHaveKeyInFXDL and (saNewKeyValue<>'') then
        begin
          rAudit.saUID:=saNewKeyValue;
          if (uMode=cnJBlokMode_Save) then
          begin
            uMode:=cnJBlokMode_View;
          end;
        end;
      end;
    End;
  end;



  if bOk and bMultiMode and (uMode=cnJBlokMode_Save) then
  begin
    saQrySNR:=saQry;
    //JAS_Log(Context,cnLog_ebug,201104080802,'MultiEdit - saSectionBottom: '+saSectionBottom,'',SOURCEFILE);
    if Context.CGIENV.DataIn.MoveFirst then
    begin
      repeat
        //JAS_Log(Context,cnLog_ebug,201104080802,'MultiEdit - SessionXDL.ITem_saName: '+Context.SessionXDL.ITem_saName,'',SOURCEFILE);
        if Context.CGIENV.DataIn.ITem_saName=saSectionBottom then
        begin
          rAudit.saUID:=Context.CGIENV.DataIn.Item_saValue;
          bOk:=true;
          if bOk then
          begin
            saQry:=saSNRStr(saQRYSNR,'[@UID@]',rAudit.saUID);
            Context.JTrakBegin(TGT, rJTable.JTabl_Name, rAudit.saUID);
            bOk:=rs.open(saQry, TGT,201503161522);
            Context.JTrakEnd(rAudit.saUID);
            If not bOk Then
            Begin
              JAS_Log(Context,cnLog_Error,201203231201,'Dynamic Query Failed.','Query: '+ saQry,SOURCEFILE, TGT,rs);
            End;
            rs.close;
          end;
          if bOk then
          begin
            bOk:=bRecord_PostUpdate(rAudit.saUID);
            If not bOk Then
            Begin
              JAS_Log(Context,cnLog_Error,201203231931,'DataBlok Post Operation Failed. ','',SOURCEFILE);
            End;
          end;
          bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, Context.CGIENV.DataIn.Item_saValue,'0',201501020046);
        end;
      until (not bOk) or (not Context.CGIENV.DataIn.MoveNext);
    end;
  end;




  {
  JAS_LOG(Context, cnLog_ebug, 201203211450, csCRLF+
    'bOk: '+saYesNo(bOk)+csCRLF+
    'bMultiMode: ' +saYesNo(bMultiMode)+csCRLF+
    'TJBlok.bRecord_Query Exit'+csCRLF+
    'Mode: ' +saMode+csCRLF+
    'rAudit.saUID: '+rAudit.saUID+csCRLF+
    'saQry: '+saQry+csCRLF+
    'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
    'rJColumn_Primary.JColu_JAS_Key_b: '+rJColumn_Primary.JColu_JAS_Key_b+csCRLF+
    'bHaveKeyInFXDL: '+saYesNo(bHaveKeyInFXDL)+csCRLF+
    'bNewRecord: '+saYesNo(bNewRecord)+csCRLF+
    'saNewKeyValue: '+saNewKeyValue+csCRLF+
    'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
    'QXDL: '+QXDL.saHTMLTable+csCRLF+
    'FXDL: '+FXDL.saHTMLTable+csCRLF
    ,'',SOURCEFILE);
  }

  if (uMode=cnJBlokMode_View) or (uMode=cnJBlokMode_Edit) then
  begin
    if FXDL.MoveFirst then
    begin
      repeat
        JBlokfield:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        if u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
        begin
          if rs.fields.FoundItem_saName(JBlokField.rJColumn.JColu_Name) then
          begin
            JBlokField.saValue:=rs.fields.Item_saValue;
          end;
        end;
      until not FXDL.MoveNext;
    end;
  end;

  if not bOk then
  begin
    bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.saUID,'0',201501020047);
  end;
  

  QXDL.Destroy;
  rs.Close;
  rs.Destroy;
  rs2.Destroy;

  //AS_Log(Context,cnLog_Ebug,201001082228,'Dynamic Query from TJBLOK.bRecord_Query :'+saQry,'',SOURCEFILE);
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102567,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================














//==============================================================================
function TJBLOK.bRecord_LoadDataIntoWidgets: boolean;
//==============================================================================
var
  bOk: boolean;
//  saQry: ansistring;
  iColumn: longint;
  u2JWidgetID: word;
  u2JDTypeID: word;
  JBlokField: TJBLOKFIELD;
  JField: TJBLOKFIELD;
  FCXDL: JFC_XDL;
  sa: ansistring;
  saReqFields: Ansistring;
  bDetailEditMode: boolean;
  saDetailWidgetSNRName: ansistring;
  saMESNRName: ansistring;
  bIfInReadOnly_UseDefaultValueOnly: boolean;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  iClickAction: longint;
  bVisible: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bDS_DetailLoadDataIntoWidgets(DS: TJSCREEN): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102548,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102549, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  FCXDL:=JFC_XDL.CreateCopy(FXDL);
  saReqFields:='';
  If FXDL.MoveFirst Then
  Begin
    iColumn:=1;

    saContent:='';

    // Debug thing
    case uMode of
    cnJBlokMode_View: saContent+='View';
    cnJBlokMode_New: saContent+='New';
    cnJBlokMode_Delete: saContent+='Delete';
    cnJBlokMode_Save: saContent+='Save';
    cnJBlokMode_Edit: saContent+='Edit';
    cnJBlokMode_Deleted: saContent+='Deleted';
    cnJBlokMode_Cancel: saContent+='Cancel';
    cnJBlokMode_SaveNClose: saContent+='SaveNClose';
    cnJBlokMode_CancelNClose: saContent+='CancelNClose';
    cnJBlokMode_SaveNNew: saContent+='SaveNNew';
    end;//switch

    Context.PAGESNRXDL.AppendItem_SNRPair('[#JBLOKMODE#]',inttostr(uMode));
    saContent+='<table border="1">'+csCRLF;
    repeat
      JBLokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
      iClickAction:=i4Val(JBlokField.rJBlokField.JBlkF_ClickAction_ID);
      bVisible:=bVal(JBlokField.rJBlokField.JBlkF_Visible_b);
      if iColumn=1 then saContent+='<tr>'+csCRLF;
      if i8Val(JBlokField.rJBlokField.JBlkF_ColSpan_u)=0 then JBlokField.rJBlokField.JBlkF_ColSpan_u:='1';
      u2JWidgetID:=u2Val(JBlokField.rJBlokField.JBlkF_JWidget_ID);
      u2JDTypeID:=u2Val(JBlokField.rJColumn.JColu_JDType_ID);
      if u2JWidgetID=0 then u2JWidgetID:=u2JDTypeID;

      if(JScreen.bEditMode)then
      begin
        saContent+='<td ';
        If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)>1 Then saContent+=' colspan="'+JBlokField.rJBlokField.JBlkF_ColSpan_u+'" ';
        saContent+='><table border="1"><tr>';
      end;

      if bVisible or JScreen.bEditMode then
      begin
        saContent+='<td valign="top" ';
        if not JScreen.bEditMode then
        begin
          If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)>1 Then saContent+=' colspan="'+JBlokField.rJBlokField.JBlkF_ColSpan_u+'" ';
        end;
        saContent+='>'+csCRLF;
      end;

      bDetailEditMode:=(not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)) and
                       ((uMode=cnJBlokMode_Edit) OR (uMode=cnJBlokMode_New));

      if bDetailEditMode then
      begin
        JBlokField.saValue:=saSNRStr(JBlokField.saValue, '@','&#64;');
        JBlokField.saValue:=saSNRStr(JBlokField.saValue, '[','&#91;');
        JBlokField.saValue:=saSNRStr(JBlokField.saValue, ']','&#93;');
      end;

      if bVisible or JScreen.bEditMode then
      begin
        If bDetailEditMode Then
        Begin
          saDetailWidgetSNRName:='DBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID;
          if bMultiMode then
          begin
            saMESNRName:='MECHK_'+JBLokField.rJBlokField.JBlkF_JBlokField_UID;
          end;
        End
        Else
        Begin
          saDetailWidgetSNRName:='RO_'+JBlokField.rJBlokField.JBlkF_JBlokField_UID;
        End;
      end;

      if not bMultiMode then
      begin
        sa:=JBlokField.rJBlokField.JBlkF_ClickActionData;
        //JAS_LOG(Context,cnLOG_Debug,201209201955,'==============' +sa,'',SOURCEFILE);
        //JAS_LOG(Context,cnLOG_Debug,201209201952,'Caption: '+JBlokField.saCaption+
        //  ' - CAD: '+sa,'',SOURCEFILE);
        sa:=saSNRStr(sa,'[@UID@]',rAudit.saUID);
        if FCXDL.MoveFirst then
        begin
          repeat
            JField:=TJBLOKFIELD(JFC_XDLITEM(FCXDL.lpItem).lpPtr);
            sa:=saSNRStr(sa,'[@'+JField.rJColumn.JColu_name+'@]',JField.saValue);
            sa:=saSNRStr(sa,'[!'+JField.rJColumn.JColu_name+'!]',saEncodeURI(JField.saValue));
            //JAS_LOG(Context,cnLOG_Debug,201209201953,'----------'+
            //  ' - SNRField: '+JField.rJColumn.JColu_name+' SNRValue: '+JField.saValue,'',SOURCEFILE);
          until not FCXDL.MoveNext;
        end;

        if bVisible or JScreen.bEditMode then
        begin
          sa:=saSNRStr(sa,'[@CAPTION@]',JBlokField.saCaption);
          case iClickAction of
          cnJBlkF_ClickAction_DetailScreen: ;
          cnJBlkF_ClickAction_Link: begin ;
            JBlokField.saCaption:='<a href="'+sa+'">'+JBlokField.saCaption+'</a>'+csCRLF;
          end;
          cnJBlkF_ClickAction_LinkNewWindow: begin // Custom ClickAction Data - Target = New Window = _blank
            JBlokField.saCaption:='<a target="_blank" href="'+sa+'">'+JBlokField.saCaption+'</a>'+csCRLF;
          end;
          cnJBlkF_ClickAction_Custom: begin // 4 = Custom ClickAction Data = COMPLETELY CUSTOM - With SNR of fields - RISKY!
            //if u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)>0 then
            //begin
            //  JBlokfield.saCaption:=sa;
            //end
            //else
            //begin
            //  // COMPLETE CUSTOM JBLOK
              JBlokField.rJBlokField.JBlkF_ClickActionData:=sa;
            //end;
          end;
          end;//switch
        end;
        //JAS_LOG(Context,cnLOG_Debug,201209201954,'Result: ' +sa,'',SOURCEFILE);
        //JAS_LOG(Context,cnLOG_Debug,201209201955,'==============' +sa,'',SOURCEFILE);
        //JAS_LOG(Context,cnLOG_Debug,201209201955,'' +sa,'',SOURCEFILE);
      end;






      If (iClickAction=cnJBlkF_ClickAction_Custom) or (u8Val(JBlokField.rJBlokField.JBlkF_JColumn_ID)=0) Then
      begin
        if bVisible or JScreen.bEditMode then
        begin
          Context.PAGESNRXDL.AppendItem_SNRPair('[#'+saDetailWidgetSNRName+'#]',JBlokField.rJBlokField.JBlkF_ClickActionData);
        end;
      end
      else
      Begin
        if bVisible or JScreen.bEditMode then
        begin
          If ((uMode=cnJBlokMode_New)or(uMode=cnJBlokMode_Edit)) and
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)) and
              (Not bMultiMode) then
          begin
            if length(trim(saReqFields))=0 then
            begin
              saReqFields:=csCRLF+'<script language="javascript">'+csCRLF;
            end;
            saReqFields+='gaoReqFields[gaoReqFields.length]="'+saDetailWidgetSNRName+'RF";'+csCRLF;
          end;

          if bMultiMode then
          begin
            WidgetBoolean(
              Context,
              saMESNRName,
              'Multi-Edit',
              'false',
              '1',//height
              true,//editmode
              false,
              true,// data on right always
              false, // required
              false,false,false,false,false,false,false,
              '',//OnBlur,
              '',//OnChange,
              '',//OnClick,
              '',//OnDblClick,
              '',//OnFocus,
              '',//OnKeyDown,
              '',//OnKeypress,
              ''//OnKeyUp,
            );
          end;



          if u2JWidgetID=cnJWidget_URL then
          begin
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='50';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1     Then JBlokField.rJBlokField.JBlkF_Widget_Width:='32';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1    Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
            WidgetURL(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bDetailEditMode,
              grJASConfig.bDataOnRight,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              false,false,
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
              JBlokField.rJBlokField.JBlkF_Widget_OnSelect
            );
          end else

          if u2JWidgetID=cnJWidget_Email then
          begin
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='50';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1     Then JBlokField.rJBlokField.JBlkF_Widget_Width:='32';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1    Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
            WidgetEmail(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bDetailEditMode,
              grJASConfig.bDataOnRight,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              false,false,
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
              JBlokField.rJBlokField.JBlkF_Widget_OnSelect
            );
          end else

          if bIsJDTypeNumber(u2JWidgetID) or bIsJDTypeString(u2JWidgetID) or bIsJDTypeChar(u2JWidgetID) then
          begin
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:='50';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1     Then JBlokField.rJBlokField.JBlkF_Widget_Width:='32';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1    Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
            WidgetInputBox(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bval(JBlokField.rJBlokField.JBlkF_Widget_Password_b),
              bDetailEditMode,
              grJASConfig.bDataOnRight,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              false,false,
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
              JBlokField.rJBlokField.JBlkF_Widget_OnSelect
            );
          End else

          if bIsJDTypeBoolean(u2JWidgetID) then
          begin
            if JBlokField.saValue='' then JBlokField.saValue:='NULL';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1    Then JBlokField.rJBlokField.JBlkF_Widget_Height:='1';
            WidgetBoolean(
              Context,
              saDetailWidgetSNRName,
                JBlokField.saCaption,
                JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Height,
              bDetailEditMode,
              False,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              grJASConfig.bDataOnRight,false,false,false,false,false,false,false,
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
            );
          End else

          if bIsJDTypeDate(u2JWidgetID) then
          begin
            if (JBlokField.saValue<>'') then JBlokField.saValue:=JDate(JBlokField.saValue, 1,11);
            WidgetDateTime(
              Context,
              saDetailWidgetSNRName,
                JBlokField.saCaption,
                JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Date_b,
              JBlokField.rJBlokField.JBlkF_Widget_Time_b,
              JBlokField.rJBlokField.JBlkF_Widget_Mask,
              bDetailEditMode,
              grJASConfig.bDataOnRight,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
            );
          End else

          if bIsJDTypeMemo(u2JWidgetID) or bIsJDTypeBinary(u2JWidgetID) then
          begin
            If (iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)<1) OR
              (iVal(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)>iVal(JBlokField.rJColumn.JColu_DefinedSize_u)) Then
            Begin
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=JBlokField.rJColumn.JColu_DefinedSize_u;
            End;
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Width)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:='40';
            If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='4';
            WidgetTextArea(Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              JBlokField.rJBlokField.JBlkF_Widget_Height,
              bDetailEditMode,
              bVal(JBlokField.rJBlokField.JBlkF_Required_b)and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
              true,
              false,false,
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
            );
          End else

          if (u2JWidgetID=cnJWidget_DropDown) or (u2JWidgetID=cnJWidget_ComboBox) then
          begin // Same Table Look Up (picklist of existing values)
            if Context.bPopulateLookUpList(
              rJTable.JTabl_Name,
              JBlokField.rJColumn.JColu_Name,
              JBlokfield.ListXDL,
              JBlokField.saValue,
              false
            ) then
            begin
              if JBlokField.ListXDL.founditem_saValue(JBlokField.saValue) then
              begin
                if (JBlokField.ListXDL.Item_i8User and b02)=0 then JBlokField.ListXDL.Item_i8User:=JBlokField.ListXDL.Item_i8User+b02;
                if (JBlokField.ListXDL.Item_i8User and b01)=0 then JBlokField.ListXDL.Item_i8User:=JBlokField.ListXDL.Item_i8User+b01;
              end;
              if u2JWidgetID=cnJWidget_DropDown then
              begin
                widgetdropdown(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_Height,
                  bVal(JBlokField.rJBlokField.JBlkF_MultiSelect_b),
                  bDetailEditMode,
                  grJASConfig.bDataOnRight,
                  JBlokField.ListXDL, //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bVal(JBlokField.rJColumn.JColu_PrimaryKey_b),
                  bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
                  false,false,
                  JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
                  JBlokField.rJBlokField.JBlkF_Widget_OnChange,
                  JBlokField.rJBlokField.JBlkF_Widget_OnClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
                );
              end
              else
              begin
                WidgetComboBox(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
                  JBlokField.rJBlokField.JBlkF_Widget_Width,
                  bDetailEditMode,// p_bEditMode: Boolean;
                  grJASConfig.bDataOnRight,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bVal(JBlokField.rJColumn.JColu_PrimaryKey_b),
                  bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)), //p_bRequired: boolean;
                  false,//p_bFilterTools: boolean;
                  false,//p_bFilterNot: boolean;
                  JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
                  JBlokField.rJBlokField.JBlkF_Widget_OnChange,
                  JBlokField.rJBlokField.JBlkF_Widget_OnClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
                  JBlokField.rJBlokField.JBlkF_Widget_OnSelect
                );
              end;
            end
            else
            begin
              // populate list failed - bummer
              Context.PAGESNRXDL.AppendItem_saName_N_saValue('[#'+saDetailWidgetSNRName+'#]','(JWidget Troubles)');
            end;
          end else

          if (u2JWidgetID=cnJWidget_Lookup) or (u2JWidgetID=cnJWidget_LookupComboBox) then
          begin
            if Context.bPopulateLookUpList(
              rJTable.JTabl_Name,
              JBlokField.rJColumn.JColu_Name,
              JBlokfield.ListXDL,
              JBlokField.saValue,
              true
            ) then
            begin
              if JBlokField.ListXDL.founditem_saValue(JBlokField.saValue) then
              begin
                if (JBlokField.ListXDL.Item_i8User and b02)=0 then JBlokField.ListXDL.Item_i8User:=JBlokField.ListXDL.Item_i8User+b02;
                if (JBlokField.ListXDL.Item_i8User and b01)=0 then JBlokField.ListXDL.Item_i8User:=JBlokField.ListXDL.Item_i8User+b01;
              end;
              bIfInReadOnly_UseDefaultValueOnly:=bVal(JBlokField.rJColumn.JColu_PrimaryKey_b) and not (bDetailEditMode);
              If iVal(JBlokField.rJBlokField.JBlkF_Widget_Height)<0 Then JBlokField.rJBlokField.JBlkF_Widget_Height:='0';


              if (u2JWidgetID=cnJWidget_Lookup) then
              begin
                widgetdropdown(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_Height,
                  bVal(JBlokField.rJBlokField.JBlkF_MultiSelect_b),
                  bDetailEditMode,
                  grJASConfig.bDataOnRight,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bIfInReadOnly_UseDefaultValueOnly,
                  bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)),
                  false,false,
                  JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
                  JBlokField.rJBlokField.JBlkF_Widget_OnChange,
                  JBlokField.rJBlokField.JBlkF_Widget_OnClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
                );
              end
              else
              begin
                WidgetComboBox(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
                  JBlokField.rJBlokField.JBlkF_Widget_Width,
                  bDetailEditMode,// p_bEditMode: Boolean;
                  grJASConfig.bDataOnRight,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bIfInReadOnly_UseDefaultValueOnly,
                  bVal(JBlokField.rJBlokField.JBlkF_Required_b) and (not bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b)), //p_bRequired: boolean;
                  false,//p_bFilterTools: boolean;
                  false,//p_bFilterNot: boolean;
                  JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
                  JBlokField.rJBlokField.JBlkF_Widget_OnChange,
                  JBlokField.rJBlokField.JBlkF_Widget_OnClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
                  JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
                  JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp,
                  JBlokField.rJBlokField.JBlkF_Widget_OnSelect
                );
              end;

            end
            else
            begin
              Context.PAGESNRXDL.AppendItem_saName_N_saValue('[#'+saDetailWidgetSNRName+'#]','(JWidget Troubles)');
            end;
          end
          else
          begin
            Context.PAGESNRXDL.AppendItem_SNRPair('[#'+saDetailWidgetSNRName+'#]','(JWidget Troubles)');
            bPreventSaveButton:=true;
          end;
        end;
      End;

      if bVisible or JScreen.bEditMode then
      begin
        if bMultiMode then saContent+='[#'+saMESNRName+'#]';
        saContent+='[#'+saDetailWidgetSNRName+'#]';

        If iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u)>1 Then
        Begin
          iColumn:=iColumn+iVal(JBlokField.rJBlokField.JBlkF_ColSpan_u);
        End
        Else
        Begin
          iColumn:=iColumn+1;
        End;

        {$IFDEF DEBUGHTML}
        saContent+='DataType:'+saJDType(u2Val(JBlokField.rJColumn.JColu_JDType_ID))+'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_ReadOnly_b:' +          JBlokField.rJBlokField.JBlkF_ReadOnly_b        +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:' +  JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Width:' +      JBlokField.rJBlokField.JBlkF_Widget_Width     +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Height:' +     JBlokField.rJBlokField.JBlkF_Widget_Height    +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Password_b:' +   JBlokField.rJBlokField.JBlkF_Widget_Password_b  +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Date_b:' +       JBlokField.rJBlokField.JBlkF_Widget_Date_b      +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Time_b:' +       JBlokField.rJBlokField.JBlkF_Widget_Time_b      +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Mask:' +         JBlokField.rJBlokField.JBlkF_Widget_Mask      +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_ColSpan_u:' +           JBlokField.rJBlokField.JBlkF_ColSpan_u         +'<br />'+csCRLF;
        saContent+='JBlokField.saValue:' +                               JBlokField.rJBlokField.saValue           +'<br />'+csCRLF;
        saContent+='JBlokField.saRequired:' +                            JBlokField.rJBlokField.rJBlokField.JBlkF_Required_b+'<br />'+csCRLF;
        {$ENDIF}
      end;
      
      if(JScreen.bEditMode)then
      begin
        saContent+=
          '</td></tr>'+
          '<tr><td>DBLOK'+JBlokField.rJBlokField.JBlkF_JBlokField_UID+'</td></tr>'+
          '<tr><td><table class="jasgrid"><tr>'+
          '<td><a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+
          JBlokField.rJBlokField.JBlkF_JBlokField_UID+
          ''');"><img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a></td>';
        if u8Val(JBlokField.rJColumn.JColu_JColumn_UID)>0 then
        begin
          saContent+=
            '<td><a title="Edit JColumn" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+
            JBlokField.rJColumn.JColu_JColumn_UID+
            ''')"><img class="image" title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a></td>';
        end;
        // End fix

        saContent+=
          '<td><a title="Left" href="javascript: editcol_left('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a></td>'+
          '<td><a title="Up"  href="javascript: editcol_up('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></a></td>'+
          '<td><a title="Down"  href="javascript: editcol_down('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></a></td>'+
          '<td><a title="Right"  href="javascript: editcol_right('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a></td>'+
          '<td><a title="Delete"  href="javascript: editcol_delete('''+rJBlok.JBlok_JBlok_UID+''','''+JBlokField.rJBlokField.JBlkF_JBlokField_UID+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a></td>'+
          '</tr></table></td></tr></table>';
      end;

      if bVisible or JScreen.bEditMode then
      begin
        saContent+='</td>'+csCRLF;
        If iColumn>iVal(rJBlok.JBlok_Columns_u) Then
        Begin
          saContent+='</tr>'+csCRLF;
          iColumn:=1;
        End;
      end;
    Until not FXDL.MoveNext;
  end;

  If iColumn<=iVal(rJBlok.JBlok_Columns_u) Then
  Begin
    //if iColumn=1 then saContent+='<tr>'+csCRLF;
    if iColumn>1 then
    begin
      repeat
        iColumn:=iColumn+1;
        {$IFDEF DEBUGHTML}
        saContent+='<td>filler</td>'+csCRLF;
        {$ELSE}
        saContent+='<td></td>'+csCRLF;
        {$ENDIF}
      Until iColumn>iVal(rJBlok.JBlok_Columns_u);
      saContent+='</tr>'+csCRLF;
    End;
    saContent+='</table>'+csCRLF;
    if length(trim(saReqFields))>0 then
    begin
      saReqFields+='</script>';
    end;
    saContent+=saReqFields;
  end;

  FCXDL.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102550,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================
















//==============================================================================
function TJBLOK.bRecord_SecurityCheck(p_saUID: ansistring; p_iRecordAction: smallint): boolean;
//==============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  JScreen: TJSCREEN;
  Context: TCONTEXT;

  //bOwnerOnly: boolean;
  saPermID: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bRecord_SecurityCheck: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102548,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102549, sTHIS_ROUTINE_NAME);{$ENDIF}

  rs:=JADO_RECORDSET.Create;

  bOk:=bRecord_PreUpdate(p_saUID);
  if bOk then
  begin
    saQry:='select JTabl_Add_JSecPerm_ID, '+
                  'JTabl_Update_JSecPerm_ID, '+
                  'JTabl_View_JSecPerm_ID, '+
                  'JTabl_Delete_JSecPerm_ID '+
                  ' FROM jtable WHERE UCASE(JTabl_Name)=UCASE('''+rJTable.JTabl_Name+''')';
    bOk:=rs.open(saQry,TGT,201503161523);
    if not bOk then
    begin
      JAS_LOG(Context,cnLog_Error,201506121449,'Query Failed',saQry,SOURCEFILE); 
    end;
  end;
  
  if bOk then
  begin
    case p_iRecordaction of
    cnRecord_Add: begin
      if iVal(rs.Get_saValue('JTabl_Add_JSecPerm_ID'))<>0 then
      begin
        saPermId:=rs.Get_saValue('JTabl_Add_JSecPerm_ID');
      end;
    end;//end case
    cnRecord_Edit: begin
      if iVal(rs.Get_saValue('JTabl_Update_JSecPerm_ID'))<>0 then
      begin
        saPermId:=rs.Get_saValue('JTabl_Update_JSecPerm_ID');
      end;
    end;//end case
    cnRecord_View: begin
      if iVal(rs.Get_saValue('JTabl_View_JSecPerm_ID'))<>0 then
      begin
        saPermId:=rs.Get_saValue('JTabl_View_JSecPerm_ID');
      end;
    end;//end case
    cnRecord_Delete: begin
      if iVal(rs.Get_saValue('JTabl_Delete_JSecPerm_ID'))<>0 then
      begin
        saPermId:=rs.Get_saValue('JTabl_Delete_JSecPerm_ID');
      end;
    end;//end case
    end;//end switch
  end;
  rs.close;
  
  if bOk then
  begin
    bOk:=bJAS_HasPermission(Context,u8Val(saPermID));
    if not bOk then 
    begin
      JAS_LOG(Context,cnLog_Warn,201503121912,'Access Denied - Permission ID' + saPermID+' User: '+Context.rJUser.JUser_Name,'',SOURCEFILE);
    end;
  end;
  
  if bOk then  
  begin
    // test for rAudit.saFieldName_CreatedBy_JUser_ID    in table rJTable.JTabl_Name
    if JADO.bColumnExists(rJTable.JTabl_Name,rAudit.saFieldName_CreatedBy_JUser_ID,TGT,201506141036) and 
       JADO.bColumnExists(rJTable.JTabl_Name,rJColumn_Primary.JColu_Name,TGT,201506141037) then
    begin
      saQry:='select '+
        JADO.saDBMSEncloseObjectName(rAudit.saFieldName_CreatedBy_JUser_ID,TGT.u2DBMSID)+' '+
        'from '+JADO.saDBMSEncloseObjectName(rJTable.JTabl_Name,TGT.u2DBMSID)+
        ' where '+JADO.saDBMSEncloseObjectName(rJColumn_Primary.JColu_Name,TGT.u2DBMSID)+'='+p_saUID;
      bOk:=rs.open(saQry,TGT,201503161524);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201503122025, 'Query Field',saQry,SOURCEFILE);
      end;

      bOk:=NOT rs.EOL;
      if not bOK then
      begin
        JAS_LOG(Context,cnLog_Warn,201503122027,'201503122027 - Missing Record that we were in the middle of deleting.','',SOURCEFILE);
      end;  
    
      if bOk then
      begin 
        if bVal(rJTable.JTabl_Owner_Only_b) then
        begin
          bOk:=Context.rJUser.JUser_JUser_UID=Context.rJUser.JUser_JUser_UID;
          if not bOK then
          begin
            JAS_LOG(Context,cnLog_Warn,201503122029,'201503122029 - User tried to delete record owned by another on an owner controlled table. '+rJTable.JTabl_Name+' User:'+Context.rjuser.juser_name,'',SOURCEFILE);
          end;  
        end;
      end;         
    end;
  end;
  
  rs.Destroy;
  result:=bOk;
  result:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102550,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================









/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
/////////////////////////////////////////////////////////////////////////////////////////////////// DETAIL STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJBLOK STUFF











//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF

//=============================================================================
Constructor TJSCREEN.create(p_COntext:TCONTEXT);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.create(p_COntext:TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102507,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102508, sTHIS_ROUTINE_NAME);{$ENDIF}

  Context:=p_Context;//reference
  JBXDL:=JFC_XDL.Create;
  DT:=now;

  bEditMode:=false;

  saTemplate:='';
  saBlokFilter:='<b>Filter Goes Here</b>'+csCRLF; // Generated Filter Blok
  saBlokGrid:='<b>Grid goes Here</b>'+csCRLF; // Generated Grid Block
  saBlokDetail:='<B>Data Screen Goes Here</b>'+csCRLF; // Generated Data Entry/View Block
  saBlokButtons:='<b>Buttons Go Here</b>'+csCRLF; // generated Buttons
  saScreenHeader:='<b>Screen Header Goes Here</b>'+csCRLF;
  saResetForm:='';
  bPageCompleted:=False;
  saAddBlokField:='';

  // GRID RELATED - SPANS FILTER and GRID Bloks
  uGridRowsPerPage:=0;
  uRPage:=0;
  uRTotalPages:=0;
  uRTotalRecords:=0;
  uRecordCount:=0;
  uPageRowMath:=0;
  saExportPage:='';
  saExportMode:='';
  bExportingNow:=false;
  bBackgroundPrepare:=false;
  bBackgroundExporting:=false;
  saBackTask:='';


  EDIT_ACTION:='';
  EDIT_JBLOK_JBLOK_UID:='';
  EDIT_JBLKF_JBLOKFIELD_UID:='';

  saResetForm:=''; // Where Javascript bits are placed so reset form
                           // button can reset all desired fields
  saQueryLimit:=''; // LIMIT 1000 (MySQL) or TOP 200 (MSSQL/ACCESS)
  saQuerySelect:='';
  saQueryFrom:='';
  saQueryWhere:='';
  saQueryOrder:='';

  if Context.CGIENV.DataIn.FoundItem_saName('mini',false) then
  begin
    bMiniMode:=bVal(Context.CGIENV.DataIn.Item_saValue);// mini=true
    Context.CGIENV.DataIn.DeleteItem;
  end
  else
  begin
    bMiniMode:=false;
  end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102509,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
Destructor TJSCREEN.destroy;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.destroy;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203102510,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203102511, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------
  // Have TJSCREENField Class Instances potentially in FXDL.. Must be Sure there are none
  // This is a safe way to empty the FXDL class without writing a whole new class to add this one bit
  // of functionality.
  //-----------
  if JBXDL.MoveFirst then
  begin
    repeat
      if JFC_XDLITEM(JBXDL.lpItem).lpPtr<>nil then
      begin
        TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPtr).Destroy;
        JFC_XDLITEM(JBXDL.lpItem).lpPtr:=nil;
      end;
    until not JBXDL.MoveNext;
    JBXDL.DeleteAll;//Now Safe to delete them all.
  end;
  JBXDL.Destroy;
  //-----------

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102512,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function TJSCREEN.bExecute:boolean;
//=============================================================================
var
  bOk: boolean;
  saOrigfilename: ansistring;
  saFilename: ansistring;
  saStoredfile: ansistring;
  path: string;
  dir: string;
  name: string;
  ext: string;
  
  saMimeType: ansistring;
  rJFile: rtJFile;
  rJTask: rtJTask;
  rJJobQ: rtJJobQ;
  saRelPath: ansistring;
  DBC: JADO_CONNECTION;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.bExecute'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171425,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171425, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=Context.VHDBC;

  bOk:=bLoadJScreenRecord;
  //if not bOk then
  //begin
  //  JAS_Log(Context,cnLog_Error,201210011745,'TJSCREEN.bExecute call to bLoadJScreenRecord Failed for ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
  //end;
  
  if bOk then
  begin
    bOk:=bValidate;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011746,
        'Access Denied',
        'TJSCREEN.bExecute call to bValidate Failed for ScreenID:' + rJScreen.JScrn_JScreen_UID,
      SOURCEFILE);
    end;
  end;

  // Make Sure Template Loaded Ok
  if bOk then
  begin
    bOk:=not Context.bErrorCondition;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201203032220,'Trouble loading Template:'+rJScreen.JScrn_Template+' ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
    end;
  end;
  //AS_Log(Context,cnLog_ebug,201203192358,'Before bPlaceScreenHeaderInPageSNRXDL bOK: '+saYesNo(bOk)+' bPageCompleted: '+saYesNo(bPageCompleted),'',SOURCEFILE);
  if bOk then
  begin
    bOk:=bPlaceScreenHeaderInPageSNRXDL;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011747,'TJSCREEN.bExecute call to bPlaceScreenHeaderInPageSNRXDL Failed - ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
    end;
  end;

    
  Context.saPagetitle:=saCaption;

  //AS_Log(Context,cnLog_ebug,201203192358,'Before TJBLOK bLoadJBloks. bOK: '+saYesNo(bOk)+' bPageCompleted: '+saYesNo(bPageCompleted),'',SOURCEFILE);
  if bOk then
  begin
    bOk:=bLoadJBloks;
    if not bOk then
    begin
      //JAS_Log(Context,cnLog_Error,201210011748,'Unable to display screen. Please make sure the table has a primary key and JAS knows about it.',
      //  'TJSCREEN.bExecute call to bLoadJBloks Failed - ScreenID:' + rJScreen.JScrn_JScreen_UID,SOURCEFILE);
    end;
  end;

  //AS_Log(Context,cnLog_ebug,201203192358,'Before TJBLOK Execute. bOK: '+saYesNo(bOk)+' bPageCompleted: '+saYesNo(bPageCompleted),'',SOURCEFILE);
  if bOk and (not bPageCompleted) then
  begin
    if JBXDL.MoveFirst then
    begin
      repeat
        bOk:=TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPTR).bExecute;
        if not bOk then
        begin
          //AS_Log(Context,cnLog_Error,201210011749,'TJSCREEN.bExecute call to '+TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPTR).rJBlok.JBlok_Name+
          //  '.bExecute Failed - ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
        end;
        //AS_Log(Context,cnLog_ebug,201203192358,'Finished TJBLOK Execute. bOK: '+saYesNo(bOk)+' bPageCompleted: '+saYesNo(bPageCompleted),'',SOURCEFILE);
      until (not bOk) or (not JBXDL.MoveNext);
    end;
  end;

  if bok then
  begin
    if not bPageCompleted then
    Begin
      Context.saPage:=saTemplate;
    End;
    Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]',Context.saPagetitle);

    if saExportMode='TABULAR' then
    begin
      //Context.saPage:=saSNRSTR(Context.saPage,'[@PAGETITLE@]',saCaption);
      Context.saPage:=saSNRSTR(Context.saPage,'[@PAGETITLE@]',Context.saPageTitle);
    end;

    if bExportingNow then
    begin
      saMimeType:='application/force-download';
      saOrigfilename:=rJScreen.JScrn_Name+'.';
      if saExportMode='TABULAR' then
      begin
        saOrigfilename+='html';
        saMimeType:=csMIME_TextHTML;
      end else
      if saExportMode='CSV' then
      begin
        saOrigfilename+='csv';
        saMimeType:=csMIME_TextPlain;
      end else
      begin
        saOrigfilename+='txt';
        saMimeType:=csMIME_TextPlain;
      end;
      Context.iDebugMode:=cnSYS_INFO_MODE_SECURE;

      //=========================================== HEADER
      Context.CGIENV.iHttpResponse:=200;
      Context.CGIENV.HEADER.MoveFirst;
      Context.CGIENV.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,Context.CGIENV.saHttpResponse);
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,Context.CGIENV.saServerSoftware);
      Context.CGIENV.Header_Date;
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,saMimeType);
      //header('Content-Type: text/csv; charset=utf-8');
      //header('Content-Disposition: data.csv');
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue('Content-Disposition: ','attachment; filename="'+saOrigFilename+'"');
      Context.CGIENV.Header_Cookies(garJVHostLight[Context.i4VHost].saServerIdent);
      //=========================================== HEADER
      Context.saMimeType:=saMimeType;

      if bBackgroundExporting then
      begin
        bOk:=bStoreFileInTree(
          saOrigfilename,
          '',//  p_saSourceDirectory: AnsiString; // Containing file to store
          saOrigfilename,//  p_saSourceFileName: AnsiString; // Filename to copy and store (unless p_sadata is used)
          garJVHostLight[Context.i4VHost].saFileDir,//  p_saDestTreeTop: AnsiString; // Top of STORAGE TREE
          Context.saPage,//  p_saData: AnsiString; // If this variable is not empty - then it is used in place
            //  // of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
            //  // saved as the p_saDestFilename in the calculated tree's relative path.
          saRelPath,//  Var p_saRelPath: AnsiString; // This gets the saRelPath when its created.
          2,//  p_i4Size: longint;
          3//  p_i4Levels: longint
        );//):Boolean;
        //ASPrintln('i4VRO_SaveEvent - ICON - G');
        if not bOk then
        begin
          JAS_Log(Context,cnLog_Error,201210231853,'Unable to store data export file during background process.',
            'TJSCREEN.bExecute - Filename: '+saOrigFilename+' - ScreenID:' + rJScreen.JScrn_JScreen_UID,SOURCEFILE);
        end;
        
        if bOk then
        begin
          path:=saOrigFilename;
          FSplit(path,dir,name,ext);
          saStoredFile:=garJVHostLight[Context.i4VHost].saFileDir+saRelPath+csDOSSLASH+saOrigFilename;
          if saLeftStr(ext,1)='.' then ext:=saRightStr(ext,length(ext)-1);
          saFilename:=saSequencedFilename(garJVHostLight[Context.i4VHost].saFileDir+saRelPath+csDOSSLASH+name,ext);
          bOk:=bMoveFile(saStoredFile, saFilename);
          if not bOk then
          begin
            JAS_Log(Context, cnLog_Error,201210250147, 'Trouble moving file. Src: '+saStoredFile+' Dest: '+saFilename,'',SOURCEFILE);
            RenderHTMLErrorPage(Context);
          end;
        end;

        if bOk then
        begin
          path:=safilename;
          FSplit(path,dir,name,ext);
          clear_JFile(rJFile);
          with rJFile do begin
            JFile_JFile_UID    :='0';
            JFile_en           :='Export from '+rJScreen.JScrn_Name+' screen.';
            JFile_Name         :=Name+ext;
            JFile_Path         :=saRelPath+csDOSSLASH+name+ext;
            JFile_JTable_ID    :=DBC.saGetTableID(DBC.ID,'jtask',201210150154);
            JFile_JColumn_ID   :='NULL';
            JFile_Row_ID       :=saBackTask;
            JFile_Orphan_b     :='false';
            JFile_JSecPerm_ID  :='NULL';
            JFile_FileSize_u   :=inttostr(length(Context.saPage));
          end;//with
          bOk:=bJAS_Save_JFile(Context, DBC, rJFile, false,false);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error,201210231911,'Unable to save file information about data export file '+
              'during background process.','TJSCREEN.bExecute - Filename: '+saFilename+' - ScreenID:' +
              rJScreen.JScrn_JScreen_UID,SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          clear_JTask(rJTask);
          rJTask.JTask_JTask_UID:=saBackTask;
          bOk:=bJAS_Load_JTask(Context, DBC, rJTask, true);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201210231927,'Unable to load JTask Record: '+saBackTask,'',SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          // 1: Update Task fields
          with rJTask do begin
            //JTask_JTask_UID                  : ansistring;
            //JTask_Name                       : ansistring;
            //JTask_Desc                       : ansistring;
            //JTask_JTaskCategory_ID           : ansistring;
            //JTask_JProject_ID                : ansistring;
            JTask_JStatus_ID                   :=inttostR(cnJStatus_Completed);
            //JTask_Due_DT                     : ansistring;
            //JTask_Duration_Minutes_Est       : ansistring;
            //JTask_JPriority_ID               : ansistring;
            //JTask_Start_DT                   : ansistring;
            //JTask_Owner_JUser_ID             : ansistring;
            JTask_SendReminder_b             :='true';
            JTask_ReminderSent_b             :='true';
            JTask_ReminderSent_DT            :=saformatdatetime(csDATETIMEFORMAT,now);
            JTask_Remind_DaysAhead_u         :='0';
            JTask_Remind_HoursAhead_u        :='0';
            JTask_Remind_MinutesAhead_u      :='0';
            JTask_Remind_Persistantly_b      :='false';
            JTask_Progress_PCT_d             :='100';
            //JTask_JCase_ID                   : ansistring;
            //JTask_Directions_URL             : ansistring;
            JTask_URL                        :=grJASConfig.saServerURL+Context.saAlias+'.?action=filedownload&UID='+rJFile.JFile_JFile_UID;
            //JTask_Milestone_b                : ansistring;
            //JTask_Budget_d                   : ansistring;
            JTask_ResolutionNotes            :='Export Completed Successfully';
            JTask_Completed_DT               :=saformatdatetime(csDATETIMEFORMAT,now);
            //JTask_CreatedBy_JUser_ID         : ansistring;
            JTask_Related_JTable_ID          :=DBC.saGetTableID(DBC.ID,'jfile',201210150155);
            JTask_Related_Row_ID             :=rJFile.JFile_JFile_UID;
            //JTask_Created_DT                 : ansistring;
            //JTask_ModifiedBy_JUser_ID        : ansistring;
            //JTask_Modified_DT                : ansistring;
            //JTask_DeletedBy_JUser_ID         : ansistring;
            //JTask_Deleted_DT                 : ansistring;
            //JTask_Deleted_b                  : ansistring;
            //JAS_Row_b                        : ansistring;
          end;//with
          bOk:=bJAS_Save_JTask(Context, DBC, rJTask,true,false);
          if not bOk then
          begin
            JAS_LOG(Context,cnLog_Error,201210231930,'Unable to Save JTask Record: '+saBackTask,'',SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          // 2: Job Queue Email Notifcation
          with rJJobQ do begin
            JJobQ_JJobQ_UID           :='0';
            JJobQ_JUser_ID            :=Context.rJSession.JSess_JUser_ID;
            JJobQ_JJobType_ID         :=inttostr(cnJJobType_General);
            JJobQ_Start_DT            :=saFormatDatetime(csDateTimeformat,now);
            //JJobQ_ErrorNo_u           : ansistring;
            //JJobQ_Started_DT          : ansistring;
            JJobQ_Running_b           :='false';
            //JJobQ_Finished_DT         : ansistring;
            JJobQ_Name                :='Email - Data Export';
            JJobQ_Repeat_b            :='false';
            //JJobQ_RepeatMinute        : ansistring;
            //JJobQ_RepeatHour          : ansistring;
            //JJobQ_RepeatDayOfMonth    : ansistring;
            //JJobQ_RepeatMonth         : ansistring;
            JJobQ_Completed_b         :='false';
            //JJobQ_Result_URL          : ansistring;
            //JJobQ_ErrorMsg            : ansistring;
            //JJobQ_ErrorMoreInfo       : ansistring;
            JJobQ_Enabled_b           :='true';

            JJobQ_Job                 :=
              '<CONTEXT>'+csCRLF+
              '  <saRequestMethod>GET</saRequestMethod>'+csCRLF+
              '  <saQueryString>jasapi=email&type=DataExportComplete&uid='+rJFile.JFile_JFile_UID+'</saQueryString>'+csCRLF+
              '  <saRequestedFile>'+Context.saAlias+'</saRequestedFile>'+csCRLF+
              '</CONTEXT>'+csCRLF;

            //JJobQ_Result              : ansistring;
            //JJobQ_CreatedBy_JUser_ID  : ansistring;
            //JJobQ_Created_DT          : ansistring;
            //JJobQ_ModifiedBy_JUser_ID : ansistring;
            //JJobQ_Modified_DT         : ansistring;
            //JJobQ_DeletedBy_JUser_ID  : ansistring;
            //JJobQ_Deleted_DT          : ansistring;
            //JJobQ_Deleted_b           : ansistring;
            //JAS_Row_b                 : ansistring;
            JJobQ_JTask_ID            :=saBackTask;
          end;// with
          bOk:=bJAS_Save_JJobQ(Context,DBC,rJJobQ,false,false);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201210231932,'Unable to save JJobQ record for email notifcation that export finished.','',SOURCEFILE);
          end;
        end;
      end;
    end;
  end
  else
  begin
    if Context.bErrorCondition then
    begin
      RenderHTMLErrorPage(Context);
    end;
  end;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102524,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function TJSCREEN.bLoadJScreenRecord:boolean;
//=============================================================================
var
  bOk: boolean;
  RS: JADO_RECORDSET;
  saQry: Ansistring;
  safilename: ansistring;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.bLoadJScreenRecord:boolean'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171425,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171425, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JScrn_JScreen_UID from jscreen WHERE JScrn_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' and ';
  if Context.CGIENV.DataIn.FoundItem_saName('SCREENID',FALSE) then
  begin
    saQry+='JScrn_JScreen_UID=' + DBC.saDBMSUIntScrub(Context.CGIENV.DataIn.Item_saValue);
  end else

  if Context.CGIENV.DataIn.FoundItem_saName('SCREEN',FALSE) then
  begin
    saQry+='JScrn_Name=' + DBC.saDBMSScrub(Context.CGIENV.DataIn.Item_saValue);
  end;

  bOk:=(rs.Open(saQry, DBC,201503161525) and (rs.EOL=False));
  If not bOk Then
  Begin
    JAS_Log(Context,cnLog_Error,201203171426,'Specified Screen Missing',
      'Sought Screen Name: '+ Context.CGIENV.DataIn.Get_saValue('Screen')+' '+
      'Sought Screen ID: '+ Context.CGIENV.DataIn.Get_saValue('ScreenID') +' '+
      'Qry:' + saQry,SOURCEFILE,DBC,rs
    );
    //Context.CGIENV.iHTTPResponse:=cnHTTP_Response_404;
  end;

  If bOk Then
  Begin
    clear_JScreen(rJScreen);
    rJScreen.JScrn_JScreen_UID:=rs.Fields.Get_saValue('JScrn_JScreen_UID');
    bOk:=bJAS_Load_JScreen(Context,DBC,rJScreen, false);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203171427, 'Trouble loading Screen','JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID,SOURCEFILE);
    end;
  end;
  rs.close;
  rs.destroy;

  if rJScreen.JScrn_IconSmall='NULL' then rJScreen.JScrn_IconSmall:='';
  if rJScreen.JScrn_IconLarge='NULL' then rJScreen.JScrn_IconLarge:='';
  if bOk then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREEN_HELP_ID@]',rJScreen.JScrn_Help_ID);
    //ASPrintln('-------------------screen id: ' + rJScreen.JScrn_JScreen_UID);
    //ASPrintln('-------------------screen help id: ' + rJScreen.JScrn_Help_ID);
    //asPrintln('');    
    
    if bMiniMode then
    begin
      saFileName:=saJasLocateTemplate(rJScreen.JScrn_TemplateMini+csJASFileExt,Context.saLANG, Context.saColorTheme,COntext.sarequestedDir,201210011935,garJVHostLight[Context.i4VHost].saTemplateDir);
      bOk:=FileExists(saFilename);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201210011919, 'Template not found. JScreen: '+rJScreen.JScrn_Name+
          ' Template: '+safilename,'JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID,SOURCEFILE);
      end;
    end
    else
    begin
      saFileName:=saJasLocateTemplate(rJScreen.JScrn_Template+csJASFileExt,Context.saLANG, Context.saColorTheme,COntext.sarequestedDir,201210011935,garJVHostLight[Context.i4VHost].saTemplateDir);
      bOk:=FileExists(saFilename);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201210011920, 'Template not found. JScreen: '+rJScreen.JScrn_Name+
          ' Template: '+saFilename,'JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID,SOURCEFILE);
      end;
    end;
  end;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203102524,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function TJSCREEN.bValidate:boolean;
//=============================================================================
var
  bOk: boolean;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.bValidate:boolean'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171540,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171540, sTHIS_ROUTINE_NAME);{$ENDIF}

  //---------------------------------------------------------------------------
  // Check User/Session/Export/Modify Permissions
  //---------------------------------------------------------------------------
  bOk:=Context.bSessionValid OR (iVal(rJScreen.JScrn_ValidSessionOnly_b)=0);
  If not bOk Then
  Begin
    JAS_Log(Context,cnLog_Error,200701041928,'Session is not Valid. You need to be logged in to view this page.',
      'ScreenID:' + rJScreen.JScrn_JScreen_UID + ' from jscreen table. JScrn_ValidSessionOnly_b field returned: '+ rJScreen.JScrn_ValidSessionOnly_b,SOURCEFILE);
  End;

  If bOk Then
  Begin
    bOk:=((u8Val(rJScreen.JScrn_JSecPerm_ID)>0) or bJAS_HasPermission(Context,u8Val(rJScreen.JScrn_JSecPerm_ID)));
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200701252204,'You are not authorized to access this area.',
        'ScreenID:' + rJScreen.JScrn_JScreen_UID + '. Permission ID:'+rJScreen.JScrn_JSecPerm_ID,SOURCEFILE);
    End;
  End;


  if bOk then
  begin
    saExportMode:=Uppercase(Context.CGIENV.DataIn.Get_saValue('exportmode'));
    saExportPage:=Uppercase(Context.CGIENV.DataIn.Get_saValue('export'));
    if (trim(saExportMode)<>'') and ((trim(saExportPage)='ALL') or (iVal(saExportPage)>0))then
    begin
      if saRightStr(saExportMode,10)='BACKGROUND' then
      begin
        bBackgroundPrepare:=true;
        if Context.CGIENV.DataIn.FoundItem_saName('exportmode') then
        begin
          Context.CGIENV.DataIn.Item_saValue:=saLeftstr(Context.CGIENV.DataIn.Item_saValue,length(Context.CGIENV.DataIn.Item_saValue)-11);
        end;
      end
      else

      begin
        bExportingNow:=true;
        if Context.CGIENV.DataIn.FoundItem_saName('BACKTASK') then
        begin
          bBackgroundExporting:=true;
          saBackTask:=Context.CGIENV.DataIn.Item_saValue;
        end;
      end;
    end;
  end;

  if bOk then
  begin
    if not bExportingNow then
    begin
      bEditMode:=UPPERCASE(Context.CGIENV.DATAIN.Get_saValue('EDITSCREEN'))='ON';
      if bEditMode then
      begin
        bOk:=(u8Val(rJScreen.JScrn_Modify_JSecPerm_ID)=0) or
             (bJAS_HasPermission(Context,u8Val(rJScreen.JScrn_Modify_JSecPerm_ID)));
        if not bOk then
        begin
          JAS_Log(Context,cnLog_Error,201203070758,'You are not authorized to modify this screen.',
            'ScreenID:' + rJScreen.JScrn_JScreen_UID + ' '+'Screen Name: '+rJScreen.JScrn_Name+
            ' Required Permission: '+rJScreen.JScrn_Modify_JSecPerm_ID,SOURCEFILE);
        end;

        EDIT_ACTION:=Context.CGIENV.DataIn.Get_saValue('EDIT_ACTION');
        EDIT_JBLOK_JBLOK_UID:=Context.CGIENV.DataIn.Get_saValue('EDIT_JBLOK_JBLOK_UID');
        EDIT_JBLKF_JBLOKFIELD_UID:=Context.CGIENV.DataIn.Get_saValue('EDIT_JBLKF_JBLOKFIELD_UID');
        Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDITSCREEN@]','checked');
      end;
    end;
  end;

  if bOk then
  begin
    case u8Val(rJScreen.JScrn_JScreenType_ID) of
    cnJScreenType_FilterGrid,cnJScreenType_Data: begin
      if bMiniMode then
      begin
        saTemplate:=saGetPage(Context, 'sys_area_bare', rJScreen.JScrn_TemplateMini,'SCREEN',False,123020100004);
      end
      else
      begin
        saTemplate:=saGetPage(Context, 'sys_area', rJScreen.JScrn_Template,'SCREEN',False,123020100004);
      end;
    end;
    else begin
      bOk:=false;
      JAS_Log(Context,cnLog_Error,201203032230,
        'Invalid Dynamic Screen Type: '+rJScreen.JScrn_JScreenType_ID+' '+
        'ScreenID:' + rJScreen.JScrn_JScreen_UID+' Name:'+rJScreen.JScrn_Name,
        '',SOURCEFILE);
    end;
    end;//switch
  end;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171541,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function TJSCREEN.bPlaceScreenHeaderInPageSNRXDL: boolean;
//=============================================================================
var
  bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJSCREEN.bPlaceScreenHeaderInPageSNRXDL: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171647,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171647, sTHIS_ROUTINE_NAME);{$ENDIF}


  //---------------------------------------------------------------------------
  // Load up (ORIGINAL) Screen HEader Info in PAGESNRXDL
  //---------------------------------------------------------------------------
  if not bExportingNow then
  begin
    if bEditMode then
    begin
      if bMiniMode then
      begin
        saScreenHeader:=saGetPage(Context,'sys_area_bare',rJScreen.JScrn_TemplateMini,'SCREENHEADERADMIN',true,201203192217);
      end
      else
      begin
        saScreenHeader:=saGetPage(Context,'sys_area',rJScreen.JScrn_Template,'SCREENHEADERADMIN',true,201203192217);
      end;
      with Context.PAGESNRXDL do begin
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JSCREEN_UID@]',rJScreen.JScrn_JScreen_UID);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_NAME@]',rJScreen.JScrn_Name);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_TEMPLATE@]',rJScreen.JScrn_Template);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_VALIDSESSIONONLY_B@]',rJScreen.JScrn_ValidSessionOnly_b);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JSECPERM_ID@]',rJScreen.JScrn_JSecPerm_ID);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_DETAILSCREENID@]',rJScreen.JScrn_JCaption_ID);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_DESC@]',rJScreen.JScrn_JCaption_ID);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JCAPTION_ID@]',rJScreen.JScrn_JCaption_ID);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_ICONSMALL@]',rJScreen.JScrn_IconSmall);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_ICONLARGE@]',rJScreen.JScrn_IconLarge);
      end;//with
    end
    else
    begin
      if bMiniMode then
      begin
        saScreenHeader:=saGetPage(Context,'sys_area_bare',rJScreen.JScrn_TemplateMini,'SCREENHEADER',true,901203192217);
      end
      else
      begin
        saScreenHeader:=saGetPage(Context,'sys_area',rJScreen.JScrn_Template,'SCREENHEADER',true,201203192217);
      end;
    end;
  end;
  //---------------------------------------------------------------------------
  // Load up (ORIGINAL) Screen HEader Info in PAGESNRXDL
  //---------------------------------------------------------------------------



  //---------------------------------------------------------------------------
  // Load up Screen HEader Info in PAGESNRXDL
  //---------------------------------------------------------------------------
  with Context.PAGESNRXDL do begin
    AppendItem_SNRPair('[@JSCRN_JSCREEN_UID@]',rJScreen.JScrn_JScreen_UID);
    AppendItem_SNRPair('[@JSCRN_NAME@]',rJScreen.JScrn_Name);
    AppendItem_SNRPair('[@JSCRN_JSCREENTYPE_ID@]',rJScreen.JScrn_JScreenType_ID);
    AppendItem_SNRPair('[@JSCRN_TEMPLATE@]',rJScreen.JScrn_Template);
    AppendItem_SNRPair('[@JSCRN_JSECPERM_ID@]',rJScreen.JScrn_JSecPerm_ID);
    AppendItem_SNRPair('[@JScrn_ValidSessionOnly_b@]',rJScreen.JScrn_ValidSessionOnly_b);
    AppendItem_SNRPair('[@JSCRN_JCAPTION_ID@]',rJScreen.JScrn_JCaption_ID);
    AppendItem_SNRPair('[@JSCRN_JCAPTION_ID@]',rJScreen.JScrn_JCaption_ID);
    AppendItem_SNRPair('[@JSCRN_ICONSMALL@]',rJScreen.JScrn_IconSmall);
    AppendItem_SNRPair('[@JSCRN_ICONLARGE@]',rJScreen.JScrn_IconLarge);
    AppendItem_SNRPair('[@SCREENID@]',rJScreen.JScrn_JScreen_UID);
    AppendItem_SNRPair('[@JSCRN_ICONSMALL@]',rJScreen.JScrn_IconSmall);
    AppendItem_SNRPair('[@JSCRN_ICONLARGE@]',rJScreen.JScrn_IconLarge);
  end;//with

  bOk:=bJASCaption(Context,rJScreen.JScrn_JCaption_ID,saCaption,rJScreen.JScrn_Name);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201002131011,'Error trying to retrieve caption via bJASCaption function.','',SOURCEFILE);
  end
  else
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREENCAPTION@]',saCaption);
  end;
  //JAS_Log(Context,cnLog_EBUG,201002131011,'Screen Name:'+rJScreen.JScrn_Name+' Screen Caption:'+saCaption+' JScrn_JCaption_ID: '+rJScreen.JScrn_JCaption_ID,'',SOURCEFILE);

  //---------------------------------------------------------------------------
  // Load up Screen HEader Info in PAGESNRXDL
  //---------------------------------------------------------------------------

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOut(201203171648,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
function TJScreen.bLoadJBloks: Boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  JBlok: TJBlok;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJScreen.bLoadJBloks: Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203171717,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203171717, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=Context.VHDBC;

  rs:=JADO_RECORDSET.cReate;
  saQry:=
    'SELECT '+
    '  JBlok_JBlok_UID '+
    'from jblok '+
    'where '+
    '  JBlok_JScreen_ID='+DBC.saDBMSUIntScrub(rJScreen.JScrn_JScreen_UID) + ' AND ' +
    '  JBlok_Deleted_b<>'+DBC.saDBMSBoolScrub(true) + ' ' +
    'ORDER BY JBlok_Position_u';
  bOk:=rs.Open(saQry, DBC,201503161526);
  if not bOk then
  begin
    JAS_LOG(Context, cnLog_Error, 201203171721, 'Trouble with Query.','Query: '+saQry, SOURCEFILE, DBC, rs);
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      JBlok:=TJBlok.Create(pointer(self),rs.fields.Get_saValue('JBlok_JBlok_UID'));
      bOk:=not JBlok.bProblem;
      if not bOk then
      begin
        JBlok.Destroy;
      end;
      if bOk then JBXDL.AppendItem_lpPTR(JBlok);
    until (not bOk) or (not rs.movenext);
  end;
  rs.Close;

  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201203171718,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF
//////////////////////////////////////////////////////////////////////////////////////////////////////    TJSCREEN STUFF






//=============================================================================
Procedure DynamicScreen(p_Context: TCONTEXT);
//=============================================================================
Var
  DS: TJSCREEN;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='DynamicScreen(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102578,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102579, sTHIS_ROUTINE_NAME);{$ENDIF}

  ds:=TJSCREEN.create(p_Context);
  ds.bExecute;
  ds.Destroy;

  if (not p_Context.bErrorCondition) and (p_Context.CGIENV.iHTTPResponse=0) then
  begin
    p_Context.CGIENV.iHTTPResponse:=200;
  end;



{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102580,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
