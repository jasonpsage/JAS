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
,ug_jcrypt
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
type TJBlokButton = class
//=============================================================================
  Public
  Constructor Create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: uInt64);
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
  Constructor Create(p_lpJBlok: pointer; p_JBlkF_JBlokfField_UID: uInt64);
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
  u8LU_Table_PKeyID: uInt64;
  saLU_Column_SQL: Ansistring;

  saCaption: AnsiString;// from Column (Or jblokfield)
  saValue: AnsiString; // Default
  saValue2: AnsiString; // Used for Things like Date Range
  sAlignment: string[10];//left right center generally
  saQuery: ansistring;
  ListXDL: JFC_XDL;// For Loading Lists for widgets that need it

  bSort: boolean;
  bAscending: boolean;
  uSortPosition: word;// Sort Order of Column versus other columns
  bPopulateListTrouble: boolean; //set to true when trouble populating List.

  sColumnAlias: string;

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
  Constructor Create(p_lpDS: pointer;p_JBlok_JBlok_UID: uint64);
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
    function bRecord_PreUpdate(p_QXDL: JFC_XDL; p_UID: uInt64): boolean;
    function bRecord_PostUpdate(p_UID: uInt64): boolean;
    function bRecord_PreAdd: boolean;
    function bRecord_LoadDataIntoWidgets: boolean;

  function bExecuteCustomBlok: boolean;
  procedure RenderButtons;//renders all buttons

  function bEdit_AddDelete: boolean;// for Editting the JBlok
  function bEdit_Move: boolean;// for Editting the JBlok

  function sMode: string;
  function bRecord_SecurityCheck(p_u8UID: uint64; p_iRecordAction: smallint; p_u8Caller: uint64): boolean;

  function bPreDelete(
    p_saTable: ansistring;
    p_UID: UInt64
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

  sPerm_JColu_Name: string[64];
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
  function saSIP_URL_Assembled(p_saPhoneNumber: ansistring): ansistring;

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
  bRecycleBinMode: boolean;

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
  u8BackTask: uInt64;
  u2GridRowsPerPage: word;
  uRPage: UInt;
  uRTotalPages: UInt;
  uRTotalRecords: UInt;
  u8RecordCount: UInt64;
  u8PageRowMath: UInt64;
  // GRID Related --------------
  //------------------------------------------------------------

  //----editting the screens
  EDIT_ACTION: string;
  EDIT_JBLOK_JBLOK_UID: UInt64;
  EDIT_JBLKF_JBLOKFIELD_UID: UInt64;
  //----editting the screens
  rJBlok: rtJBlok;
  rJColumn: rtJColumn;
  rJBlokField: rtJBlokField;
  sNEWCOLUMNID: Uint64;
  //sNEWCOLUMNFORBLOKID: string;
  sAddBlokField: string;
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
constructor TJBlokButton.create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: Uint64);
//=============================================================================
var
  Context: TCONTEXT;
  JBlok: TJBLOK;
  JScreen: TJSCREEN;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokButton.create(p_lpJBlok: pointer; p_JBlkB_JBlokButton_UID: Uint64);'; {$ENDIF}
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
  bProblem:=not bJAS_Load_JBlokButton(Context, JBlok.DBC, rJBlokButton, false,201603310300);
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
  {IFDEF DEBUGTHREADBEGINEND}
    Context: TCONTEXT;
  {ELSE}
     {IFDEF TRACKTHREAD}
        //Context: TCONTEXT;
     {ENDIF}
  {ENDIF}

  saName: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOKBUTTON.saRender'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  {IFDEF DEBUGTHREADBEGINEND}
    Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
  {ELSE}
     {IFDEF TRACKTHREAD}
       //Context:=TJSCREEN(TJBLOK(lpJBLOK).lpDS).Context;
     {ENDIF}
  {ENDIF}
  if context.binternaljob then jasprintln('TJBlokButton.saRender - Begin');



{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203189018,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203189018, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:='[UNKNOWN BUTTON TYPE]';
  
  saName:=rJBlokButton.JBlkB_Name;
  case rJBlokButton.JBlkB_JButtonType_ID of
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
        Result:='<li><a href="javascript: NewWindow(''[@ALIAS@].?[@DETAILSCREENID@]&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''')"><img class="image" src="'+
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
  
  if context.binternaljob then jasprintln('TJBlokButton.saRender - End');

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
constructor TJBlokField.create(p_lpJBlok: pointer; p_JBlkF_JBlokfField_UID: Uint64);
//=============================================================================
var
  JBLok: TJBLOK;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBlokField.create(p_lpJBlok: pointer; p_JBlkF_JBlokfField_UID: Uint64);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JBlok:=TJBLOK(p_lpJBlok);
  JScreen:=TJSCREEN(JBlok.lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201203191951,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201203191951, sTHIS_ROUTINE_NAME);{$ENDIF}

  if context.binternaljob then jasprintln('TJBlokField.create - Begin');

  ListXDL:=JFC_XDL.Create;
  lpJBlok:=p_lpJBlok;
  Reset;
  rJBlokField.JBlkF_JBlokField_UID:=p_JBlkF_JBlokfField_UID;
  bProblem:=not bLoad;
  if bProblem then
  begin
    JAS_Log(Context,cnLog_Error,201210011750,'TJBlokfield.Create call to bLoad Failed - ScreenID:' +
      inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+' JBlok: '+TJBLOK(lpJBlok).rJBlok.JBlok_Name+
      ' JBlokField: '+inttostr(rJBlokField.JBlkF_JBlokField_UID),'',SOURCEFILE);
  end;

  if context.binternaljob then jasprintln('TJBlokField.create - End');
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
  sAlignment:='';
  saQuery:='';
  bSort:=false;
  bAscending:=true;
  uSortPosition:=0;
  bPopulateListTrouble:=false;
  ListXDL.DeleteAll;

  sLU_Table_Name:='';
  sLU_Table_ColumnPrefix:='';
  u8LU_Table_PKeyID:=0;
  saLU_Column_SQL:='';

  sColumnAlias:='';
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

  bOk:=bJAS_Load_JBlokField(Context, JBlok.DBC, rJBlokField,false,201603310301);
  if not bOk then
  begin
    JAS_LOG(Context,cnLog_Error,201203161105,'Trouble loading JBlokField Record','',SOURCEFILE);
  end;

  if bOk then
  begin
    if rJBlokField.JBlkF_JColumn_ID>0 then
    begin
      rJColumn.JColu_JColumn_UID:=rJBlokField.JBlkF_JColumn_ID;
      bOk:=bJAS_Load_JColumn(Context,JBlok.DBC, rJColumn,false,201603310302);
      if not bOk then
      begin
        bOk:=true;
        JAS_LOG(Context,cnLog_Warn,201203161106,'Trouble loading JColumn Record. '+
          'JBlkF_JBlokField_UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID)+' '+
          'JBlkF_JColumn_ID:'+inttostr(rJBlokField.JBlkF_JColumn_ID),'',SOURCEFILE);
        with rJColumn do begin
          JColu_Name                    :=inttostr(JColu_JColumn_UID);//TODO: NAME and UID? dual purpose field like some others? does either name or id - hmm
          JColu_JCaption_ID             :=2012040717150310253;
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
      if rJBlokField.JBlkF_JCaption_ID>0 then
      begin
        bOk:=bJASCaption(Context,rJBlokField.JBlkF_JCaption_ID, saCaption, inttostr(rJBlokField.JBlkF_JBlokField_UID));
        if not bOk then
        begin
          JAS_LOG(Context,cnLog_Error,201203162121,'Trouble loading JCaption','',SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        if (rJBlokField.JBlkF_JColumn_ID>0) and ((saCaption='') or (saCaption=inttostr(rJBlokField.JBlkF_JBlokField_UID))) then
        begin
          if (rJColumn.JColu_JCaption_ID>0) then
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
constructor TJBLOK.create(p_lpDS: pointer; p_JBlok_JBlok_UID: uInt64);
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
  //saContent:='<!-- I did this awful thing -->';
  saFooter:='';
  // ------------- OUTPUT

  saButtons:=''; // Where buttons Are Rendered then placed into templates
  uMode:=cnJBlokMode_View;
  bMultiMode:=false;
  bPreventSaveButton:=false;

  clear_JBlok(rJBlok);
  rJBlok.JBlok_JBlok_UID:=p_JBlok_JBlok_UID;
  bOk:=bJAS_Load_JBlok(Context, DBC, rJBlok, false,201603310303);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201210011751,'TJBLOK.create call to bJAS_Load_JBlok Failed - ScreenID:' +
      inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
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
  //const cnJBlokType_Filter=1;  <<<--- reference from uj_definitions.pp
  //const cnJBlokType_Grid  =2;
  //const cnJBlokType_Data  =3;
  //const cnJBlokType_Custom=4;

  if bOk and (rJBlok.JBlok_JTable_ID>0) and
    (rJBlok.JBlok_JBlokType_ID=cnJBlokType_Filter)or
    (rJBlok.JBlok_JBlokType_ID=cnJBlokType_Grid)or
    (rJBlok.JBlok_JBlokType_ID=cnJBlokType_Data)then
  begin
    //JAS_LOG(Context, nLog_Debug, 201203172032, 'TJBLOK.create - Loading JTable into JScreen.rJTable.','',SOURCEFILE);
    clear_jtable(rJTable);
    rJTable.JTabl_JTable_UID:=rJBlok.JBlok_JTable_ID;
    bOk:=bJAS_Load_JTable(Context, DBC, rJTable, false,201603310304);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203172032, 'Trouble loading JTable for current JBlok.','',SOURCEFILE);
    end;

    if bOk then
    begin
      bOk:= trim(rJTable.JTabl_Name)<>'';
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201608101429, 'Table Name Field is Empty. Table ID: '+inttostr(rjTable.JTabl_JTable_UID),'',SOURCEFILE);
      end;
    end;



    if bOk then
    begin
      //ASPrintln('asking for permission: rJTable.JTabl_View_JSecPerm_ID:'+inttostr(rJTable.JTabl_View_JSecPerm_ID));//extra to make data correct i see
      bOk:=bJAS_HasPermission(Context, rJTable.JTabl_View_JSecPerm_ID);
      //ASPrintln('asking for permission - did it work: '+sYesNo(bOk));//extra to make data correct i see
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201211051336,'You are not authorized to view data from the table in this screen.',
          'Table: '+rJTable.JTabl_Name+' View Perm Req: '+inttostr(rJTable.JTabl_View_JSecPerm_ID),SOURCEFILE);
      end;
    end;
      
    if bOk then
    begin
      clear_Audit(rAudit,rJTable.JTabl_ColumnPrefix);
      rAudit.u8UID:=u8Val(Context.CGIENV.DataIn.Get_saValue('UID'));
      bView:=(rJTable.JTabl_JTableType_ID=2);// 2=VIEW TYPE (1=Table)
      // session required for editing
      if not Context.bSessionValid then bView:=true;
      //bOk:=rAudit.u8UID>0;
      //if not bOk then
      //begin
      //  JAS_LOG(Context, cnLog_Error, 201608101701,'UID Value Is ZERO.',
      //    'Table: '+rJTable.JTabl_Name,SOURCEFILE);
      //end;
    end;

    //else
    //begin
    //  JAS_LOG(Context, nLog_Debug, 201209280347,'No TABLE associated with JBlok: '+rJBlok.JBlok_JBlok_UID, '',SOURCEFILE);
    //end;
    sPerm_JColu_Name:=DBC.sGetColumnNAme(rJTable.JTabl_Perm_JColumn_ID,201210020208);
    if rJTable.JTabl_JDConnection_ID=0 then rJTable.JTabl_JDConnection_ID:=1;//fudge
    TGT:=Context.DBCon(rJTable.JTabl_JDConnection_ID,201610311000);
    // LOAD JTable --------------------------------------------------------------


    // LOAD BUTTONS --------------------------------------------------------------
    if bOk then
    begin
      saQry:='select '+DBC.sDBMSEncloseObjectName('JBlkB_JBlokButton_UID')+' from '+DBC.sDBMSEncloseObjectName('jblokbutton')+' '+
        'where '+DBC.sDBMSEncloseObjectName('JBlkB_JBlok_ID')+'='+
        DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) +' AND '+DBC.sDBMSEncloseObjectName('JBlkB_Deleted_b')+'<>'+
        DBC.sDBMSBoolScrub(true)+' ORDER BY '+DBC.sDBMSEncloseObjectName('JBlkB_Position_u');
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
          jbb:=TJBlokButton.Create(self, u8Val(rs.fields.Get_saValue('JBlkB_JBlokButton_UID')));
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
            BXDL.Item_saDesc:=inttostr(jbb.rJBlokButton.JBlkB_JButtonType_ID);
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
          inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
      end;
    end;

    // LOAD FIELDS --------------------------------------------------------------
    if bOk and (not JScreen.bPAgeCompleted) then
    begin
      saQry:='select '+DBC.sDBMSEncloseObjectName('JBlkF_JBlokField_UID')+' from '+DBC.sDBMSEncloseObjectName('jblokfield')+
        ' where '+DBC.sDBMSEncloseObjectName('JBlkF_JBlok_ID')+'='+
         DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) +' AND '+DBC.sDBMSEncloseObjectName('JBlkF_Deleted_b')+'<>'+
        DBC.sDBMSBoolScrub(true)+' ORDER BY '+DBC.sDBMSEncloseObjectName('JBlkF_Position_u');
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
            jbf:=TJBlokField.Create(self,u8Val(rs.fields.Get_saValue('JBlkF_JBlokField_UID')));
            bOk:=not jbf.bProblem;
            if not bOk then
            begin
              jbf.destroy;
            end;

            if bOk then
            begin
              if jbf.rJBlokField.JBlkF_Position_u<>u2Pos then
              begin
                jbf.rJBlokField.JBlkF_Position_u:=u2Pos;
                bOk:=bJAS_Save_JBlokField(Context,DBC, jbf.rJBlokField,false,false,201603310305);
                if not bOk then
                begin
                  JAS_LOG(Context, cnLog_Error, 201203201727,'Unable to fix bad JBlokField Position.',
                    'JBlkF_JBlokField_UID: '+inttostr(jbf.rJBlokField.JBlkF_JBlokField_UID),SOURCEFILE);
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

              JFC_XDLITEM(FXDL.lpItem).UID:=jbf.rJBlokField.JBlkF_JBlokField_UID;
              if jbf.rJBlokField.JBlkF_JColumn_ID>0 then
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
      saQry:='select '+DBC.sDBMSEncloseObjectName('JColu_JColumn_UID')+' from '+DBC.sDBMSEncloseObjectName('jcolumn')+
        ' where '+DBC.sDBMSEncloseObjectName('JColu_JTable_ID')+'='+DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID)+
        ' and '+DBC.sDBMSEncloseObjectName('JColu_PrimaryKey_b')+'='+DBC.sDBMSBoolScrub(true);
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
      rJColumn_Primary.JColu_JColumn_UID:=u8Val(rs.fields.Get_saValue('JColu_JColumn_UID'));
      bOk:=bJAS_Load_JColumn(Context, DBC, rJColumn_Primary, false,201603310306);
      if not bOk then
      begin
        JAS_LOG(TJSCREEN(lpDS).Context, cnLog_Error, 201203172046,
          'Trouble loading Primary Key column.','Table ID:'+inttostr(rJTable.JTabl_JTable_UID)+
          ' ColID:'+inttostr(rJColumn_Primary.JColu_JColumn_UID)+' rs.eol:'+sTrueFalse(rs.eol),SOURCEFILE);
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
          inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
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

        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.u8UID                          '+ saUID                                       ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_CreatedBy_JUser_ID '+ saFieldName_CreatedBy_JUser_ID              ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Created_DT         '+ saFieldName_Created_DT                      ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_ModifiedBy_JUser_ID'+ saFieldName_ModifiedBy_JUser_ID             ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Modified_DT        '+ saFieldName_Modified_DT                     ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_DeletedBy_JUser_ID '+ saFieldName_DeletedBy_JUser_ID              ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Deleted_DT         '+ saFieldName_Deleted_DT                      ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.saFieldName_Deleted_b          '+ saFieldName_Deleted_b                       ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_CreatedBy_JUser_ID        '+ sTrueFalse(bUse_CreatedBy_JUser_ID)        ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Created_DT                '+ sTrueFalse(bUse_Created_DT)                ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_ModifiedBy_JUser_ID       '+ sTrueFalse(bUse_ModifiedBy_JUser_ID)       ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Modified_DT               '+ sTrueFalse(bUse_Modified_DT)               ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_DeletedBy_JUser_ID        '+ sTrueFalse(bUse_DeletedBy_JUser_ID)        ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Deleted_DT                '+ sTrueFalse(bUse_Deleted_DT)                ,'',SOURCEFILE);
        //JAS_LOG(Context, nLog_Debug, 201210012110, 'TJBLOK.rAudit.bUse_Deleted_b                 '+ sTrueFalse(bUse_Deleted_b)                 ,'',SOURCEFILE);
      end;
    end;
    // DOUBLE CHECK for Deleted_b field if not found yet
  end
  else
  begin
    //check for custom here
  end;
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
   //Context.JThread.DBIN(2-01203171046,sTHIS_ROUTINE_NAME,SOURCEFILE);
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
function TJBLOK.sMode: string;
//=============================================================================
begin
  case integer(uMode) of
  cnJBlokMode_View        : result:='View';
  cnJBlokMode_New         : result:='New';
  cnJBlokMode_Delete      : result:='Delete';
  cnJBlokMode_Save        : result:='Save';
  cnJBlokMode_Edit        : result:='Edit';
  cnJBlokMode_Deleted     : result:='Deleted';
  cnJBlokMode_Cancel      : result:='Cancel';
  cnJBlokMode_SaveNClose  : result:='SaveNClose';
  cnJBlokMode_CancelNClose: result:='CancelNClose';
  cnJBlokMode_Merge       : result:='Merge';
  cnJBlokMode_SaveNNew    : result:='SaveNNew';
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
  case rJBlok.JBlok_JBlokType_ID of
  cnJBlokType_Filter: begin
    Context.bNoWebCache:=true;
    ExecuteFilterBlok;
    Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@JBLOK_JBLOK_UID_FILTER@]',inttostr(rJBlok.JBlok_JBlok_UID));
  end;
  cnJBlokType_Grid  : begin
    Context.bNoWebCache:=true;
    bOk:=bExecuteGridBlok;
    Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@JBLOK_JBLOK_UID_GRID@]',inttostr(rJBlok.JBlok_JBlok_UID));
  end;
  cnJBlokType_Data  : begin
    Context.bNoWebCache:=true;
    bOk:=bExecuteDataBlok;
    Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@JBLOK_JBLOK_UID_DATA@]',inttostr(rJBlok.JBlok_JBlok_UID));
    //if not bOk then
    //begin
    //  AS_LOG(CONTEXT, cnLog_Error, 201210011859,'TJBLOK.bExecute Call to bExecuteDataBlok failed. JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
    //end;
  end;
  cnJBlokType_Custom: begin
    bOk:=bExecuteCustomBlok;
    Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@JBLOK_JBLOK_UID_DATA@]',inttostr(rJBlok.JBlok_JBlok_UID));
    //if not bOk then
    //begin
    //  AS_LOG(CONTEXT, cnLog_Error, 201210011900,'TJBLOK.bExecute Call to bExecuteCustomBlok failed. JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
    //end;
  end;
  else
    begin
      bOk:=false;// Invalid JBlokType ID
      JAS_LOG(CONTEXT, cnLog_Error, 201210011901,'TJBLOK.bExecute - Invalid JBlokType: '+
        inttostr(rJBlok.JBlok_JBlokType_ID)+'  JBlok:'+rJBlok.JBlok_Name,'',SOURCEFILE);
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
  JColu_JCaption_ID: uInt64;
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

  //asprintln('uj_ui_screen - TJBLOK.bEdit_AddDelete BEGIN. JScreen.EDIT_ACTION: '+JScreen.EDIT_ACTION);
  //asprintln('uj_ui_screen - TJBLOK.bEdit_AddDelete BEGIN. Found ADDBLOKFIELD: ' + sYesNo(Context.CGIENV.DataIn.FoundItem_saName('ADDBLOKFIELD',true)));

  // EDIT_JBLKF_JBLOKFIELD_UID
  if JScreen.EDIT_ACTION='ADD' then
  begin
    if not Context.CGIENV.DataIn.FoundItem_saName('ADDBLOKFIELD',true) then
    begin
      XDL:=JFC_XDL.Create;

      // LOAD UP XDL
      XDL.AppendItem_saName_N_saValue('','0');
      XDL.Item_i8User:=B00;//SELECTABLE
      saQry:='SELECT '+
        DBC.sDBMSEncloseObjectName('JColu_JColumn_UID')+','+
        DBC.sDBMSEncloseObjectName('JColu_JCaption_ID')+','+
        DBC.sDBMSEncloseObjectName('JColu_Name')+' '+
        'from '+DBC.sDBMSEncloseObjectName('jcolumn')+' '+
        'WHERE '+DBC.sDBMSEncloseObjectName('JColu_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true) + ' AND '+
        DBC.sDBMSEncloseObjectName('JColu_JTable_ID')+'=' + DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID);
      bOk:=rs.Open(saQry, DBC,201503161506);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203201336,'Trouble with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
      end;
      if bOk and (not rs.Eol) then
      begin
        repeat
          JColu_JCaption_ID:=u8Val(rs.fields.Get_saValue('JColu_JCaption_ID'));
          saJColu_Name:=rs.fields.Get_saValue('JColu_Name');
          if JColu_JCaption_ID>0 then
          begin
            bOk:=bJASCaption(Context, JColu_JCaption_ID, saMyCaption,saJColu_Name);
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
        saQry:='select '+DBC.sDBMSEncloseObjectName('JBlkF_JColumn_ID')+
          ' from '+DBC.sDBMSEncloseObjectName('jblokfield')+' '+
          'WHERE '+DBC.sDBMSEncloseObjectName('JBlkF_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true) + ' AND '+
          DBC.sDBMSEncloseObjectName('JBlkF_JBlok_ID')+'='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+' AND '+
          DBC.sDBMSEncloseObjectName('JBlkF_JColumn_ID')+'<>0';
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
          XDL.ListCount,                   //  p_sSize: string;
          true,                            //  p_bMultiple: boolean;
          true,                            //  p_bEditMode: Boolean;
          garJVHost[Context.u2VHost].VHost_DataOnRight_b,
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
      Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDIT_JBLOK_JBLOK_UID@]',inttostr(rJBlok.JBlok_JBlok_UID));
      if JScreen.bMiniMode then
      begin
        Context.saPage:=saGetPage(Context,'sys_area_bare','sys_page_screenblokfieldadd','MAIN',false,'',201203201441);
      end
      else
      begin
        Context.saPage:=saGetPage(Context,'sys_area','sys_page_screenblokfieldadd','MAIN',false,'',201203201441);
      end;
      JScreen.bPageCompleted:=bOk;
    end
    else
    begin
      u2Pos:=1+DBC.u8GetRecordCount('jblokfield','JBlkF_JBlok_ID='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+' AND '+
        'JBlkF_Deleted_b<>'+DBC.sDBMSBoolScrub(true),201506171770);

      repeat
        clear_jblokfield(rJBlokField_New);
        //JBlkF_JBlokField_UID              : AnsiString;
        rJBlokField_New.JBlkF_JBlok_ID                    :=rJBlok.JBlok_JBlok_UID;
        rJBlokField_New.JBlkF_JColumn_ID                  :=u8Val(Context.CGIENV.DataIn.Item_saValue);
        rJBlokField_New.JBlkF_Position_u                  :=u2Pos;u2Pos+=1;
        rJBlokField_New.JBlkF_ReadOnly_b                  :=false;

        if u8Val(Context.CGIENV.DataIn.Item_saValue)>0 then
        begin
          saQry:='select '+
            DBC.sDBMSEncloseObjectName('JColu_JDType_ID')+', '+
            DBC.sDBMSEncloseObjectName('JColu_DefinedSize_u')+','+
            DBC.sDBMSEncloseObjectName('JColu_Boolean_b')+' '+
            'from '+DBC.sDBMSEncloseObjectName('jcolumn')+' where '+
            DBC.sDBMSEncloseObjectName('JColu_JColumn_UID')+'='+DBC.sDBMSUIntScrub(Context.CGIENV.DataIn.Item_saValue);
          bOk:=rs.Open(saQry, DBC,201503161508);
          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201203201548,'Trouble with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
          end;
          if bOk then
          begin
            rJBlokField_New.JBlkF_JWidget_ID:=u8Val(rs.fields.Get_saValue('JColu_JDType_ID'));
            rJBlokField_New.JBlkF_Widget_MaxLength_u:=uVal(rs.fields.Get_saValue('JColu_DefinedSize_u'));

            if rJBlokField_New.JBlkF_Widget_MaxLength_u>40 then
              rJBlokField_New.JBlkF_Widget_Width:=40
            else
              rJBlokField_New.JBlkF_Widget_Width:=rJBlokField_New.JBlkF_Widget_MaxLength_u;

            if bIsJDTypeDate(rJBlokField_New.JBlkF_JWidget_ID) then
            begin
              rJBlokField_New.JBlkF_Widget_Date_b:=true;
              rJBlokField_New.JBlkF_Widget_Time_b:=true;
            end;
          end;
          rs.close;
        end;

        if bOk then
        begin
          rJBlokField_New.JBlkF_ColSpan_u                   :=1;
          rJBlokField_New.JBlkF_CreatedBy_JUser_ID          :=Context.rJUser.JUser_Juser_UID;
          rJBlokField_New.JBlkF_Created_DT                  :=DBC.sDBMSDateScrub(now);
          rJBlokField_New.JBlkF_Deleted_b                   :=false;
          rJBlokField_New.JBlkF_Width_is_Percent_b          :=false;
          rJBlokField_New.JBlkF_Height_is_Percent_b         :=false;
          rJBlokField_New.JBlkF_Required_b                  :=false;
          rJBlokField_New.JBlkF_Visible_b                   :=true;
          rJBlokField_New.JAS_Row_b                         :=false;
          bOk:=bJAS_Save_JBlokField(Context, DBC, rJBlokField_New, false,false,201603310307);
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
    bOk:=bJAS_LockRecord(Context, DBC.ID,  'jblokfield', JScreen.EDIT_JBLKF_JBLOKFIELD_UID,0,201501020030);
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
    bJAS_UnLockRecord(Context, DBC.ID, 'jblokfield', JScreen.EDIT_JBLKF_JBLOKFIELD_UID,0,201501020031);
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
  u8: uint64;//s:string;
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

  bOk:=FXDL.FoundItem_UID(JScreen.EDIT_JBLKF_JBLOKFIELD_UID);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201203201741,'Unable to locate submitted JBlokfield.','',SOURCEFILE);
  end;

  if bOk and (FXDL.ListCount>1) then
  begin
    u2Cols:=rJBlok.JBlok_Columns_u;
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
      u8:=JBlokField1.rJBlokField.JBlkF_Position_u;
      JBlokField1.rJBlokField.JBlkF_Position_u:=JBlokField2.rJBlokField.JBlkF_Position_u;
      JBlokField2.rJBlokField.JBlkF_Position_u:=u8;
      FXDL.SwapItems(lpItem1, lpItem2);

      bOk:=bJAS_Save_JBlokField(Context, DBC, JBlokField1.rJBlokField,false,false,201603310308);
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203201845,'Unable to Save JBlokfield #1','',SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_Save_JBlokField(Context,DBC, JBlokField2.rJBlokField,false,false,201603310309);
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
var
  bOk: boolean;
  saDetailBlok: ansistring;
  saDetailBloks: ansistring;
  JScreen: TJSCREEN;
  Context: TCONTEXT;
  //sa: ansistring;
  u8JButtonTypeID: int64;
  bDone: boolean;
  sButton: String;
  //saME: ansistring;// Multi Edit Items getting stuffed into FORM
  //u8JScreenID: uint64;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJBLOK.bExecuteCustomBlok: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JScreen:=TJSCREEN(lpDS);
  Context:=JScreen.Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201610181900,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201610181901, sTHIS_ROUTINE_NAME);{$ENDIF}

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
  //u8JScreenID:=JScreen.rJScreen.JScrn_JScreen_UID;
  uMode:=cnJBlokMode_View;

  Context.PAGESNRXDL.AppendItem_SNRPair('[@DETAIL_HELP_ID@]',inttostr(rJBlok.JBlok_Help_ID));

  If not bDone then
  begin
    if Context.CGIENV.DataIn.FoundItem_saName('button',False) Then
    Begin
      sButton:=JFC_XDLITEM(Context.CGIENV.DataIn.lpItem).saValue;
      if sButton='CANCELNCLOSE' Then uMode:=cnJBlokMode_CancelNClose;
    end;
  End;


  if not bDone then
  begin
    if JScreen.bEditmode then
    begin
      saHeader:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILHEADERADMIN',true,201610181902);
      saSectionTop:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILSECTION',true,201610181903);
      saSectionMiddle:=saGetPage(Context, 'sys_area_bare',JScreen.rJScreen.JScrn_Template,'DETAILBLOK',true,201610181904);
    end
    else
    begin
      saHeader:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILHEADER',true,201610181905);
      saSectionTop:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILSECTION',true,201610181906);
      saSectionMiddle:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'DETAILBLOK',true,201610181907);
    end;

    Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDIT@]','');
    Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDITITEMS@]','');

    //------------------------------------------------------------------------------- PERFORM DETAIL SCREEN ACTIONS
    If bOk and (uMode=cnJBlokMode_CancelNClose)  and (not JScreen.bPageCompleted) Then
    begin
      DataBlok_DetailCancel;
    end;

    If bOk and (not JScreen.bPageCompleted)Then
    Begin
      bOk:=bRecord_LoadDataIntoWidgets;
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201610181925,'bRecord_LoadDataIntoWidgets','',SOURCEFILE);
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
          u8JButtonTypeID:=TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_JButtonType_ID;
          //sa:='';
          //if (u8JButtonTypeID=cnJBlokButtonType_Save) or
          //   (u8JButtonTypeID=cnJBlokButtonType_SaveNClose) or
          //   (u8JButtonTypeID=cnJBlokButtonType_SaveNNew) then
          //begin
          //  if bPreventSaveButton then
          //  begin
          //    sa:='<li><a href="javascript: alert(''Please resolve JWidget Errors. We are preventing you from saving for fear of corrupting your data.'');">'+
          //      '<img class="image" src="'+TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_GraphicFileName+'" />'+
          //      '<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
          //  end;
          //end;

          Case u8JButtonTypeID Of
          cnJBlokButtonType_Save:;
          cnJBlokButtonType_SaveNClose:;
          cnJBlokButtonType_SaveNNew:;
          cnJBlokButtonType_Delete:;
          cnJBlokButtonType_Cancel: If (uMode=cnJBlokMode_New) OR (uMode=cnJBlokMode_Edit) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
          cnJBlokButtonType_CancelNClose: If ((uMode=cnJBlokMode_Edit)or(uMode=cnJBlokMode_New)) and (not bMultiMode) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Edit: If ((uMode=cnJBlokMode_View)or(uMode=cnJBlokMode_Save)) and ((rJTable.JTabl_Update_JSecPerm_ID=0) or
                         (bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID))) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

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
      Context.PAGESNRXDL.AppendItem_SNRPair('[@UID@]',inttostr(rAudit.u8UID));
      Context.PAGESNRXDL.AppendItem_SNRPair('[@MULTIEDITHEADER@]',saFooter);
      //JAS_Log(Context,cnLog_EBUG,201610181926,'uid SENT:'+rAudit.u8UID,'',SOURCEFILE);
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
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201610181927,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//==============================================================================
function TJBLOK.bPreDelete(
  p_saTable: ansistring;
  p_UID: UInt64
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
  if TGT.sName='JAS' then
  begin
    if p_saTable = 'jadodbms'         then begin end else

    //    if p_saTable = 'jaccesslog' then begin end else
    //    if p_saTable = 'jadodbms' then begin end else
    //    if p_saTable = 'jadodriver' then begin end else
    //    if p_saTable = 'jalias' then begin end else
    //    if p_saTable = 'jasident' then begin end else
    //    if p_saTable = 'jblog' then begin end else
    if p_saTable = 'jblok'            then begin bOk:=bPreDel_JBlok(Context, TGT, p_UID); end else
    //    if p_saTable = 'jblokbutton' then begin end else
    //    if p_saTable = 'jblokfield' then begin end else
    //    if p_saTable = 'jbloktype' then begin end else
    //    if p_saTable = 'jbuttontype' then begin end else
    //    if p_saTable = 'jcaption' then begin end else
    if p_saTable = 'jcase'            then begin bOk:=bPreDel_JCase(Context, TGT, p_UID); end else
    //    if p_saTable = 'jcasecategory' then begin end else
    //    if p_saTable = 'jcasesource' then begin end else
    //    if p_saTable = 'jcasesubject' then begin end else
    //    if p_saTable = 'jcasetype' then begin end else
    //    if p_saTable = 'jclickaction' then begin end else
    //    if p_saTable = 'jcolumn' then begin end else
    //    if p_saTable = 'jdconnection' then begin end else
    //    if p_saTable = 'jdebug' then begin end else
    //    if p_saTable = 'jdownloadfilelist' then begin end else
    //    if p_saTable = 'jdtype' then begin end else
    //    if p_saTable = 'jegaslog' then begin end else
    //    if p_saTable = 'jerrorlog' then begin end else
    //    if p_saTable = 'jetname' then begin end else
    if p_saTable = 'jfile'            then begin bOk:=bPreDel_JFile(Context, TGT, p_UID); end else
    if p_saTable = 'jfiltersave'      then begin bOk:=bPreDel_JFilterSave(Context, TGT, p_UID); end else
    //    if p_saTable = 'jfiltersavedef' then begin end else
    //    if p_saTable = 'jhelp' then begin end else
    if p_saTable = 'jiconcontext'     then begin bOk:=bPreDel_JIconContext(Context, TGT, p_UID); end else
    //    if p_saTable = 'jiconmaster' then begin end else
    //    if p_saTable = 'jindexfile' then begin end else
    //    if p_saTable = 'jindustry' then begin end else
    if p_saTable = 'jinstalled'       then begin bOk:=bPreDel_JInstalled(Context, TGT, p_UID); end else
    //    if p_saTable = 'jinterface' then begin end else
    if p_saTable = 'jinvoice'         then begin bOk:=bPreDel_JInvoice(Context, TGT, p_UID); end else
    //    if p_saTable = 'jinvoicelines' then begin end else
    //    if p_saTable = 'jiplist' then begin end else
    //    if p_saTable = 'jiplistlu' then begin end else
    //    if p_saTable = 'jipstat' then begin end else
    //    if p_saTable = 'jjobq' then begin end else
    //    if p_saTable = 'jjobtype' then begin end else
    //    if p_saTable = 'jlanguage' then begin end else
    if p_saTable = 'jlead'            then begin bOk:=bPreDel_JLead(Context, TGT, p_UID); end else
    //    if p_saTable = 'jleadsource' then begin end else
    //    if p_saTable = 'jlock' then begin end else
    //    if p_saTable = 'jlog' then begin end else
    //    if p_saTable = 'jlogtype' then begin end else
    //    if p_saTable = 'jlookup' then begin end else
    //    if p_saTable = 'jmail' then begin end else
    //    if p_saTable = 'jmenu' then begin end else
    //    if p_saTable = 'jmime' then begin end else
    //    if p_saTable = 'jmodc' then begin end else
    if p_saTable = 'jmodule'          then begin bOk:=bPreDel_JModule(Context, TGT, p_UID); end else
    //    if p_saTable = 'jmoduleconfig' then begin end else
    if p_saTable = 'jmodulesetting'   then begin bOk:=bPreDel_JModuleSetting(Context, TGT, p_UID); end else
    //    if p_saTable = 'jnote' then begin end else
    if p_saTable = 'jorg'         then begin bOk:=bPreDel_JOrg(Context, TGT, p_UID); end else
    //    if p_saTable = 'jorgpers' then begin end else
    //    if p_saTable = 'jpassword' then begin end else
    if p_saTable = 'jperson'          then begin bOk:=bPreDel_JPerson(Context, TGT, p_UID); end else
    //    if p_saTable = 'jpersonskill' then begin end else
    //    if p_saTable = 'jprinter' then begin end else
    //    if p_saTable = 'jpriority' then begin end else
    if p_saTable = 'jproduct'         then begin bOk:=bPreDel_JProduct(Context, TGT, p_UID);  end else
    //    if p_saTable = 'jproductgrp' then begin end else
    //    if p_saTable = 'jproductqty' then begin end else
    if p_saTable = 'jproject'         then begin bOk:=bPreDel_JProject(Context, TGT, p_UID); end else
    //    if p_saTable = 'jprojectcategory' then begin end else
    //    if p_saTable = 'jprojectpriority' then begin end else
    //    if p_saTable = 'jprojectstatus' then begin end else
    //    if p_saTable = 'jpunkbait' then begin end else
    //    if p_saTable = 'jquicklink' then begin end else
    //    if p_saTable = 'jquicknote' then begin end else
    //    if p_saTable = 'jredirect' then begin end else
    //    if p_saTable = 'jredirectlu' then begin end else
    //    if p_saTable = 'jrequestlog' then begin end else
    if p_saTable = 'jscreen'          then begin bOk:=bPreDel_JScreen(Context,TGT,p_UID); end else
    //    if p_saTable = 'jscreentype' then begin end else
    if p_saTable = 'jsecgrp'          then begin bOk:=bPreDel_JSecGrp(Context,TGT,p_UID); end else
    //    if p_saTable = 'jsecgrplink' then begin end else
    //    if p_saTable = 'jsecgrpuserlink' then begin end else
    //    if p_saTable = 'jseckey' then begin end else
    if p_saTable = 'jsecperm'         then begin bOk:=bPreDel_JSecPerm(Context,TGT,p_UID); end else
    //    if p_saTable = 'jsecpermuserlink' then begin end else
    if p_saTable = 'jsession'         then begin bOk:=bPreDel_JSession(Context,TGT,p_UID); end else
    //    if p_saTable = 'jsessiondata' then begin end else
    //    if p_saTable = 'jsessiontype' then begin end else
    //    if p_saTable = 'jskill' then begin end else
    //    if p_saTable = 'jstatus' then begin end else
    //    if p_saTable = 'jsync' then begin end else
    if p_saTable = 'jsysmodule'       then begin bOk:=bPreDel_JSysModule(Context,TGT,p_UID); end else
    if p_saTable = 'jsysmodulelink'   then begin bOk:=bPreDel_JSysModuleLink(Context,TGT,p_UID); end else
    if p_saTable = 'jtable'           then begin bOk:=bPreDel_JTable(Context,TGT,p_UID); end else
    //    if p_saTable = 'jtabletype' then begin end else
    if p_saTable = 'jtask'            then begin bOk:=bPreDel_JTask(Context, TGT, p_UID); end else
    //    if p_saTable = 'jtaskcategory' then begin end else
    if p_saTable = 'jteam'            then begin bOk:=bPreDel_JTeam(Context, TGT, p_UID); end else
    //    if p_saTable = 'jteammember' then begin end else
    //    if p_saTable = 'jtheme' then begin end else
    //    if p_saTable = 'jthemeicon' then begin end else
    //    if p_saTable = 'jtimecard' then begin end else
    //    if p_saTable = 'jtrak' then begin end else
    if p_saTable = 'juser'            then begin bOk:=bPreDel_JTeam(Context, TGT, p_UID); end;
    //    if p_saTable = 'juserpref' then begin end else
    //    if p_saTable = 'juserpreflink' then begin end else
    //    if p_saTable = 'jvhost' then begin end else
    //    if p_saTable = 'jwidget' then begin end else
    //    if p_saTable = 'livecode' then begin end else
    //    if p_saTable = 'public_view_jproject' then begin end else
    //    if p_saTable = 'public_view_jtask' then begin end else
    //    if p_saTable = 'test' then begin end else
    //    if p_saTable = 'view_case' then begin end else
    //    if p_saTable = 'view_inventory' then begin end else
    //    if p_saTable = 'view_invoice' then begin end else
    //    if p_saTable = 'view_lead' then begin end else
    //    if p_saTable = 'view_menu' then begin end else
    //    if p_saTable = 'view_org' then begin end else
    //    if p_saTable = 'view_person' then begin end else
    //    if p_saTable = 'view_project' then begin end else
    //    if p_saTable = 'view_task' then begin end else
    //    if p_saTable = 'view_team' then begin end else
    //    if p_saTable = 'view_time' then begin end else
    //    if p_saTable = 'view_vendor' then begin end else
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
  u2Column: word;
  u8JDTypeID: UInt64;
  u8JWidgetID: UInt64;

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
  FSaveUID: UInt64;//sFSaveUID: string;
  rJFilterSave: rtJFilterSave;
  saFilterSaveFeedback: ansistring;
  bFilterDupe: boolean;
  XML: JFC_XML;
  bFirstLoad: Boolean;//for loading default
  bIncomingFilterFields: boolean;// used to avoice default filters overriding
  // direct URLS meant to show a certain result set.
  bHasPerm_Update_jfiltersave: boolean;
  bHasPerm_Delete_jfiltersave: boolean;

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
  bHasPerm_Update_jfiltersave:=bJAS_HasPermission(Context,1212041011118250544);//table_update_jfiltersave=1212041011118250544
  bHasPerm_Delete_jfiltersave:=bJAS_HasPermission(Context,1212041011118260545);//table_delete_jfiltersave=1212041011118260545

  if (not TJSCREEN(lpDS).bExportingNow) then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERSHOWING@]',
      trim(lowercase(sTrueFalse(bval(Context.CGIENV.DATAIN.Get_saValue('filtershowing'))))));
  end;
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERADMIN_JBLOK_JBLOK_UID@]',inttostr(rJBlok.JBlok_JBlok_UID));
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTERCAPTION@]',saCaption);
  Context.PAGESNRXDL.AppendItem_SNRPair('[@DETAILSCREENID@]','SCREENID='+inttostr(TJSCREEN(lpDS).rJScreen.JScrn_Detail_JScreen_ID));
  Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREEN_HELP_ID@]',inttostr(TJSCREEN(lpDS).rJScreen.JScrn_Help_ID));
  
  
  
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
      AppendItem_SNRPair('[@FILTERADMIN_JBLOK_JBLOK_UID@]',inttostr(rJBlok.JBlok_JBlok_UID));
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
  
  Context.PAGESNRXDL.AppendItem_SNRPair('[@FILTER_HELP_ID@]',inttostr(rJBlok.JBlok_Help_ID));
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
    FSaveUID:=u8Val(Context.CGIENV.DataIn.Get_saValue('FILTERSELECTION'));
  end
  else
  begin
    FSaveUID:=0;
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
  if Context.bSessionValid and(Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='SAVE') and bHasPerm_Update_jfiltersave then
  begin
    if not (length(rJFilterSave.JFtSa_Name)>0) then
    begin
      saFilterSaveFeedback:='Filters require a name to be entered.';
    end
    else
    begin
      bFilterDupe:=false;
      saQry:='SELECT '+
        DBC.sDBMSEncloseObjectName('JFtSa_JFilterSave_UID')+', '+
        DBC.sDBMSEncloseObjectName('JFtSa_CreatedBy_JUser_ID')+' from '+DBC.sDBMSEncloseObjectName('jfiltersave')+' '+
        ' WHERE ';
      saqry+=
        '(('+DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+'='+DBC.sDBMSBoolScrub(false)+') and ('+
        DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+' IS NULL))'+
        ' AND '+
        ' '+DBC.sDBMSEncloseObjectName('JFtSa_Name')+'='+DBC.saDBMSScrub(rJFilterSave.JFtSa_Name) + ' AND '+
        ' '+DBC.sDBMSEncloseObjectName('JFtSa_JBlok_ID')+'='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) + ' AND ';
      saQry+=
        ' (('+DBC.sDBMSEncloseObjectName('JFtSa_CreatedBy_JUser_ID')+'='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID)+') OR '+
        ' ('+DBC.sDBMSEncloseObjectName('JFtSa_Public_b')+'='+DBC.sDBMSBoolScrub(true)+'))';
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
          saQry:='SELECT '+DBC.sDBMSEncloseObjectName('JFtSa_JFilterSave_UID')+
            ' FROM '+DBC.sDBMSEncloseObjectName('jfiltersave')+' '+
            ' WHERE (('+DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+'='+DBC.sDBMSBoolScrub(false)+') OR '+
            '('+DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+' IS NULL)) AND '+
            '(('+DBC.sDBMSEncloseObjectName('JFtSa_Name')+'='+DBC.saDBMSScrub(rJFilterSave.JFtSa_Name) + ') AND '+
            ' ('+DBC.sDBMSEncloseObjectName('JFtSa_JBlok_ID')+'='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID) + ') AND '+
            ' ('+DBC.sDBMSEncloseObjectName('JFtSa_CreatedBy_JUser_ID')+'='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID)+'))';
          bOk:=rs.open(saQry, DBC,201503161510);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Warn, 201204032047, 'Problem with Query','Query: '+saQry,SOURCEFILE,DBC,rs);
          end;

          if bOk then
          begin
            if not rs.eol then
            begin
              rJFilterSave.JFtSa_JFilterSave_UID:=u8Val(rs.fields.Get_saValue('JFtSa_JFilterSave_UID'));
            end;
            // name set already
            rJFilterSave.JFtSa_JBlok_ID:=rJBlok.JBlok_JBlok_UID;
            rJFilterSave.JFtSa_Public_b:=bVal(Context.CGIENV.DataIn.Get_saValue('FSAVEPUBLIC'));
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
            bOk:=bJAS_Save_JFilterSave(Context, DBC, rJFilterSave,false,false,201603310310);
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

  if Context.bSessionValid and ((bFirstLoad or (Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='APPLY')) and
     bHasPerm_Update_jfiltersave and (not bIncomingFilterFields)) then
  begin
    if bFirstLoad then
    begin
      saQry:='select '+DBC.sDBMSEncloseObjectName('JFtSD_JFilterSave_ID')+' '+
        'FROM '+DBC.sDBMSEncloseObjectName('jfiltersavedef')+' '+
        'WHERE '+
        '(('+DBC.sDBMSEncloseObjectName('JFtSD_Deleted_b')+'='+DBC.sDBMSBoolScrub(false)+') OR ('+
          DBC.sDBMSEncloseObjectName('JFtSD_Deleted_b')+' is NULL)) AND '+
        DBC.sDBMSEncloseObjectName('JFtSD_CreatedBy_JUser_ID')+'='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID)+' AND '+
        DBC.sDBMSEncloseObjectName('JFtSD_JBlok_ID')+'='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID);
      bOk:=rs.open(saQry,DBC,201503161511);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Warn, 201204071156, 'Problem with Query loading default saved filter.','Query: '+saQry,SOURCEFILE);
      end;

      if bOk and (not rs.eol) then
      begin
        FSaveUID:=u8Val(rs.fields.Get_saValue('JFtSD_JFilterSave_ID'));
      end;
      rs.close;
    end;



    if FSaveUID<>0 then
    begin
      rJFilterSave.JFtSa_JFilterSave_UID:=FSaveUID;
      bOk:=bJAS_Load_JFilterSave(Context, DBC, rJFilterSave, false,201603310311);
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

  if Context.bSessionValid and(Context.CGIENV.DataIn.Get_saValue('FILTERBUTTON')='DELETE') and bHasPerm_Delete_jfiltersave then
  begin
    //asprintln('TRYING to KILL a FILTER');
    saQry:='((JFtSa_Deleted_b='+DBC.sDBMSBoolScrub(false)+') or (JFtSa_Deleted_b is null)) AND '+
           '(JFtSa_JFilterSave_UID='+DBC.sDBMSUIntScrub(FSaveUID)+')';

    if not Context.rJUser.JUser_Admin_b then
      saQry+=' AND (JFtSa_CreatedBy_JUser_ID='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID)+')';

    //riteln('Qry:>',saQry,'<qry ');
    //riteln('RowCount:',DBC.u8GetRecordCount('jfiltersave',saQry,201506171772));
    if DBC.u8GetRecordCount('jfiltersave',saQry,201506171771)=1 then
    begin
      //riteln('kill a filter a');

      bOk:=bJAS_DeleteRecord(Context,DBC,'jfiltersave',FSaveUID);
      if bOk then
      begin
        //riteln('kill a filter b');
        saQry:='DELETE FROM '+DBC.sDBMSEncloseObjectName('jfiltersavedef')+
          ' WHERE '+DBC.sDBMSEncloseObjectName('JFtSD_JFilterSave_ID')+'='+DBC.sDBMSUIntScrub(FSaveUID);
        bOk:=rs.open(saQry, DBC,201503161512);
        if not bOK then
        begin
         //riteln('kill a filter c');
          saFilterSaveFeedback:='Trouble removing default filter settings for the deleted filter.';
        end
        else
        begin
        //riteln('kill a filter d');
          saFilterSaveFeedback:='Filter deleted successfully.';
        end;
        rs.close;
      end
      else
      begin
      //riteln('kill a filter e');
        saFilterSaveFeedback:='Trouble deleting filter.';
      end;
    end
    else
    begin
      //riteln('kill a filter f');
      saFilterSaveFeedback:='Unable to comply.';
    end;
  end;

  //riteln('kill a filter done: '+saFilterSaveFeedBack);


  //============ LOADING SELECTION OF SAVED FILTERS
  // We don't want the bOK from Above effecting this part here so we disregard previous value
  saQry:='SELECT '+
    DBC.sDBMSEncloseObjectName('JFtSa_JFilterSave_UID')+', '+
    DBC.sDBMSEncloseObjectName('JFtSa_Name')+', '+
    DBC.sDBMSEncloseObjectName('JFtSa_XML')+', '+
    DBC.sDBMSEncloseObjectName('JFtSa_Public_b')+' '+
    'FROM '+DBC.sDBMSEncloseObjectName('jfiltersave')+' ';
  saQry+=
    'WHERE '+
    '(('+DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+'='+DBC.sDBMSBoolScrub(false) + ') or ' +
    '('+DBC.sDBMSEncloseObjectName('JFtSa_Deleted_b')+' is null )) AND ';
  saQry+=' ('+DBC.sDBMSEncloseObjectName('JFtSa_JBlok_ID')+'='+DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+') AND ' +
    ' (('+DBC.sDBMSEncloseObjectName('JFtSa_CreatedBy_JUser_ID')+'='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID)+') OR ';
  saQry+=' ('+DBC.sDBMSEncloseObjectName('JFtSa_Public_b')+'='+DBC.sDBMSBoolScrub('true')+')) '+
    ' ORDER BY '+DBC.sDBMSEncloseObjectName('JFtSa_Name');
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
      if FSaveUID=u8Val(FSaveXDL.Item_saValue) then
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
    inttostr(FSaveUID),
    1,//height
    false,//multiselect
    true,//editmode
    garJVHost[Context.u2VHost].VHost_DataOnRight_b,
    FSaveXDL, //caption (seen)//value (returned)// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
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
    50,
    50,
    false,
    true,
    garJVHost[Context.u2VHost].VHost_DataOnRight_b,
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
    1,
    true,
    false,
    garJVHost[Context.u2VHost].VHost_DataOnRight_b,
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



  JScreen.saQueryFrom:=' FROM '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' ';

  if NOT FXDL.MoveFirst then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[#FBLOK#]','');
  end
  else
  begin
    u2Column:=1;
    saContent+='<table border="1">'+csCRLF;
    //saContent+='<table border="0">'+csCRLF;
    repeat
      JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
      //====================================================== QUERY BUILD ===================================================================================================
      JBlokField.saValue:=Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID));
      //saValueBeforeHandled:=JBlokfield.saValue;
      bExclude:=(Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT');
      If JBlokField.rJBlokField.JBlkF_ColSpan_u<1 Then JBlokField.rJBlokField.JBlkF_ColSpan_u:=1;
      u8JDTypeID:=JBlokField.rJColumn.JColu_JDType_ID;
      u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;
      if u8JWidgetID=0 then u8JWidgetID:=u8JDTypeID;
      If u2Column=1 Then saContent+='<tr>'+csCRLF;

      // GATHER MULTI SELECT VALUES-------------------------------------------
      MXDL.DeleteAll;
      saIncomingName:='FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID);
      if Context.CGIENV.DataIn.FoundItem_saName(saIncomingName) then
      begin
        repeat
          MXDL.AppendItem_saValue(Context.CGIENV.DataIn.Item_saValue);
        until not Context.CGIENV.DataIn.FNextItem_saName(saIncomingName);
      end;
      // GATHER MULTI SELECT VALUES-------------------------------------------

      if (bIsJDTypeBoolean(u8JWidgetID) or
          bIsJDTypeBoolean(u8JDTypeID) or
          JBlokField.rJColumn.JColu_Boolean_b) and (JBlokField.saValue<>'') then
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
            JScreen.saQueryWhere+=DBC.sDBMSBoolScrub(JBlokField.saValue) + ')';
          end;
          if (MXDL.ListCount>0) and (MXDL.ListCount>MXDL.N) then JScreen.saQueryWhere+=' AND ';
        until not MXDL.MoveNext;
        JScreen.saQueryWhere+=')';
      end else

      if bIsJDTypeNumber(u8JDTypeID) and (JBlokField.saValue<>'') then
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
            if bIsJDTypeUInt(u8JDTypeID) then
            begin
              JScreen.saQueryWhere+=DBC.sDBMSUIntScrub(JBlokField.saValue) + ')';
            end
            else
            begin
              JScreen.saQueryWhere+=DBC.sDBMSIntScrub(JBlokField.saValue) + ')';
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

      if bIsJDTypeDate(u8JWidgetID) then
      Begin
        JBlokField.saValue2:=Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'LIMIT');
        If (JBlokField.saValue='') and (JBlokField.saValue2<>'') Then
        Begin
          // DATE <= VALUE2
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+' <= '+DBC.sDBMSDateScrub(JDate(JBlokField.saValue2, 11,1))+')';
        End else

        If (JBlokField.saValue<>'') and (JBlokField.saValue2='') Then
        Begin
          // DATE >= VALUE1
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+'  >= '+DBC.sDBMSDateScrub(JDate(JBlokField.saValue, 11,1))+')';
        End else

        If (JBlokField.saValue<>'') and (JBlokField.saValue2<>'') Then
        Begin
          // DATE >= VALUE1  AND DATE <= VALUE2
          if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
          JScreen.saQueryWhere+='( '+JBlokField.rJColumn.JColu_Name+' >= '+DBC.sDBMSDateScrub(JDate(JBlokField.saValue, 11,1))+')';
          JScreen.saQueryWhere+=' AND ( '+JBlokField.rJColumn.JColu_Name+' <= '+ DBC.sDBMSDateScrub(JDate(JBlokField.saValue2, 11,1))+')';
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
            JScreen.saQueryWhere+=' like '+DBC.saDBMSScrub(DBC.sDBMSWild+JBlokField.saValue+DBC.sDBMSWild)+')';
          end;
        end;
      End;

      //====================================================== QUERY BUILD ===================================================================================================


      saContent+='<td';
      If JBlokField.rJBlokField.JBlkF_ColSpan_u>1 Then
      begin
        saContent+=' colspan="'+inttostr(JBlokField.rJBlokField.JBlkF_ColSpan_u)+'" ';
      end;
      saContent+=' valign="top" >';

      FilterBlok_CreateWidgets(JBlokField, MXDL);

      if(TJSCREEN(lpDS).bEditMode)then
      begin
        //saContent+='<table border="1"><tr><td>';
        saContent+='<table border="0"><tr><td>';
      end;
      saContent+='[#'+'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'#]';

      // SPECIAL Case For Dual Controls (Date range)
      //saContent+='['+saJDType(iJWidgetID);
      If (u8JWidgetID=cnJDType_dt) Then
      Begin
        saContent+='[#'+'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'LIMIT#]';
      End;
      //saContent+=']';

      {
      saContent+=
        '<br />'+
        'JBlokfield.saValue: '+JBlokfield.saValue+'<br />'+
        'u8JDTypeID: '+saJDType(u8JDTypeID)+'<br />'+
        'u2JDWidgetID: '+saJDType(u2JWidgetID)+'<br />'+
        'u2JDWidgetID: '+saJDType(u2JWidgetID)+'<br />'+
        'saValueBeforeHandled: '+saValueBeforeHandled+'<br />'+
        MXDL.saHTMLTable;
      }


      if(TJSCREEN(lpDS).bEditMode)then
      begin
        saContent+='</td></tr><tr><td>FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'</td></tr><tr><td><table><tr>';
        saContent+='<td><a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+
          inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+
          ''');"><img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a></td>';
        if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
        begin
          saContent+='<td><a title="Edit JColumn"    href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+
            inttostr(JBlokField.rJBlokField.JBlkF_JColumn_ID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''');">'+
            '<img class="image" title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a></td>';
        end;

        saContent+=
          '<td><a title="Left" href="javascript: editcol_left('''+    inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" title="Left" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a></td>'+
          '<td><a title="Up" href="javascript: editcol_up('''+        inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" title="Up" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></a></td>'+
          '<td><a title="Down" href="javascript: editcol_down('''+    inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" title="Down" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></a></td>'+
          '<td><a title="Right" href="javascript: editcol_right('''+  inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" title="Right" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a></td>'+
          '<td><a title="Delete" href="javascript: editcol_delete('''+inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" title="Delete" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a></td>'+
          '</tr></table></td></tr></table>';
      end;


      {$IFDEF DEBUGHTML}
      saContent+=
        'DataType:'+                saJDType(JBlokField.rJBlokField.JBlkF_JWidget_ID)       +'<br />'+csCRLF+
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

      If JBlokField.rJBlokField.JBlkF_ColSpan_u>1 Then
      Begin
        u2Column:=u2Column+JBlokField.rJBlokField.JBlkF_ColSpan_u;
      End
      Else
      Begin
        u2Column+=1;
      End;
      saContent+='</td>'+csCRLF;
      If u2Column>rJBlok.JBlok_Columns_u Then
      Begin
        saContent+='</tr>'+csCRLF;
        u2Column:=1;
      End;
    Until (not FXDL.MoveNext);

    If FXDL.N<=rJBlok.JBlok_Columns_u Then
    Begin
      u2Column:=FXDL.N;
      repeat
        u2Column+=1;
        {$IFDEF DEBUGHTML}
        saContent+='<td>filler</td>'+csCRLF;
        {$ELSE}
        saContent+='<td></td>'+csCRLF;
        {$ENDIF}
      Until u2Column>rJBlok.JBlok_Columns_u;
      saContent+='</tr>'+csCRLF;
    End;
    saContent+='</table>'+csCRLF;
  end;
  saContent+='<script>function Custom(p_url){window.open(p_url,"","width=700,scrollbars=yes,resizable=yes");};</script>'+csCRLF;
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
  u8JWidgetID: uint64;
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

  If JBlokField.rJBlokField.JBlkF_JColumn_ID>0 Then
  Begin
    // Assign Default Widget and Parameters for Column Data Type in question.
    // Note: Administration Page For Creating Screen Blocks, specifically
    // the part where individual fields are added - need to flow same logic -
    // for default parameters and Widget Types as coded here.
    u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;
    If u8JWidgetID=0 then JBlokField.rJBlokField.JBlkF_JWidget_ID:=JBlokField.rJColumn.JColu_JDType_ID;
    u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;

    // 19/2015/03 12:25 PM
    if pos('/',JBlokField.saValue)=3 then
    begin
      JBlokField.saValue:=JDATE(JBlokField.saValue,1,22);
    end;

    if bIsJDTypeDate(u8JWidgetID) then
    Begin
      WidgetDateTime(Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Date_b,
        JBlokField.rJBlokField.JBlkF_Widget_Time_b,
        JBlokField.rJBlokField.JBlkF_Widget_Mask,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
      WidgetDateTime(
        Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'LIMIT',
        'Select Date Range',
        Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'LIMIT'),
        JBlokField.rJBlokField.JBlkF_Widget_Date_b,
        JBlokField.rJBlokField.JBlkF_Widget_Time_b,
        JBlokField.rJBlokField.JBlkF_Widget_Mask,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'LIMIT").value="";';
    End else


    if bIsJDTypeBoolean(u8JWidgetID) then
    Begin
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=1;
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u>JBlokField.rJColumn.JColu_DefinedSize_u Then
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=1;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=1;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
      WidgetBoolean(
        Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Height,
        true,
        True,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
        JBlokfield.rJBlokField.JBlkF_MultiSelect_b,
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").selectedIndex=0;';
    End else

    if bIsJDTypeNumber(u8JWidgetID) then
    Begin
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=22;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=22;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
      WidgetInputBox(
        Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        JBlokField.rJBlokField.JBlkF_Widget_Password_b,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
    End else

    if bIsJDTypeMemo(u8JWidgetID) or (u8JWidgetID=cnJWidget_Content)then
    Begin
      If (JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1) OR
        (JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u>JBlokField.rJColumn.JColu_DefinedSize_u) Then
      Begin
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=JBlokField.rJColumn.JColu_DefinedSize_u;
      End;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=4;
      WidgetTextArea(Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        JBlokField.rJBlokField.JBlkF_Widget_Height,
        true,
        false,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
        JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
        JBlokField.rJBlokField.JBlkF_Widget_OnChange,
        JBlokField.rJBlokField.JBlkF_Widget_OnClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
        JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
        JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
      );
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
    End else

    if (cnJWidget_DropDown=u8JWidgetID) or
       (cnJWidget_Lookup=u8JWidgetID) or
       (cnJWidget_ComboBox=u8JWidgetID) or
       (cnJWidget_LookupComboBox=u8JWidgetID) then
    begin
      if Context.bPopulateLookUpList(
        rJTable.JTabl_Name,
        JBlokField.rJColumn.JColu_Name,
        JBlokField.ListXDL,
        JBlokfield.saValue,
        ((cnJWidget_Lookup=u8JWidgetID) or (cnJWidget_LookupComboBox=u8JWidgetID))
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


        if (cnJWidget_DropDown=u8JWidgetID) or
           (cnJWidget_Lookup=u8JWidgetID) or
           (cnJWidget_LookupComboBox=u8JWidgetID) then
        begin
          //JAS_LOG(Context,cnLog_ebug,201204021957,'Filter WidgetDropDown Field: '+JBlokField.saCaption+
          //  ' JBlokField.ListXDL.ListCount: '+inttostr(JBlokField.ListXDL.ListCount),'',SOURCEFILE);
          //JAS_LOG(Context,cnLog_ebug,201204021957,'JBlokField.rJBlokField.JBlkF_ReadOnly_b: '+JBlokField.rJBlokField.JBlkF_ReadOnly_b+
          //  'bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b): '+sYesNo(bVal(JBlokField.rJBlokField.JBlkF_ReadOnly_b))+
          //  'JBlokField.rJBlokField.JBlkF_JBlokField_UID: '+JBlokField.rJBlokField.JBlkF_JBlokField_UID,'',SOURCEFILE);

          if (cnJWidget_LookupComboBox=u8JWidgetID) then
          begin
            widgetComboBox(Context,
              'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              not JBlokField.rJBlokField.JBlkF_ReadOnly_b,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.ListXDL, //caption (seen)//value (returned)// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
              false,
              false,
              true,
              (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
            JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';            
          end
          else
          begin
            widgetdropdown(Context,
              'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Height,
              JBlokfield.rJBlokField.JBlkF_MultiSelect_b,
              not JBlokField.rJBlokField.JBlkF_ReadOnly_b,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.ListXDL, //caption (seen)//value (returned)// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
              false,
              false,
              true,
              (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp
            );
            JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").selectedIndex=0;';
          end;
        end
        else
        begin
          widgetComboBox(Context,
            'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
            JBlokField.saCaption,
            JBlokField.saValue,
            JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
            JBlokField.rJBlokField.JBlkF_Widget_Width,
            not JBlokField.rJBlokField.JBlkF_ReadOnly_b,
            garJVHost[Context.u2VHost].VHost_DataOnRight_b,
            JBlokField.ListXDL, //caption (seen)//value (returned)// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
            false,
            false,
            true,
            (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
          JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'cbo").selectedIndex=0;';
        end;
        
      end
      else
      begin
        Context.PAGESNRXDL.AppendItem_SNRPair('[#'+'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'#]','(JWidget Troubles LU)');
      end;
    end else

    if cnJWidget_URL=u8JWidgetID then
    begin
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
      WidgetURL(Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
    end else

    if cnJWidget_Email=u8JWidgetID then
    begin
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
      WidgetEmail(Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
    end else

    Begin  // CATCH ALL - AND TEXT FIELDS
      If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=20;
      If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
      WidgetInputBox(Context,
        'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID),
        JBlokField.saCaption,
        JBlokField.saValue,
        JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
        JBlokField.rJBlokField.JBlkF_Widget_Width,
        JBlokField.rJBlokField.JBlkF_Widget_Password_b,
        true,
        garJVHost[Context.u2VHost].VHost_DataOnRight_b,
        false,
        true,
        (Context.CGIENV.DataIn.Get_saValue('FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'FT')='NOT'),
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
      JScreen.saResetForm+='document.getElementById("FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'").value="";';
    End;
  End
  else
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[#'+'FBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'#]',
      JBlokField.rJBlokField.JBlkF_ClickActionData);
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
  //bPerm: boolean;
  
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
  if (JScreen.bBackgroundPrepare) then
  begin
    dt:=now;
    // MAKE TASK FOR THIS EXPORT for LATER retrieval
    clear_JTask(rJTask);
    with rJTask do begin
      JTask_JTask_UID                  :=0;
      JTask_Name                       :=rJTable.JTabl_Name+' export';
      JTask_Desc                       :='Task created to allow exporting records for retrieval at a later time when the process has completed.';
      JTask_JTaskCategory_ID           :=cnJTaskCategory_Task;
      JTask_JProject_ID                :=0;
      JTask_JStatus_ID                 :=cnJStatus_NotStarted;
      JTask_Due_DT                     :=FormatDateTime(csDateTimeFormat,dt);
      JTask_Duration_Minutes_Est       :=0;
      JTask_JPriority_ID               :=cnJPriority_Normal;
      JTask_Start_DT                   :=FormatDateTime(csDateTimeFormat,dt);
      JTask_Owner_JUser_ID             :=Context.rJSession.JSess_JUser_ID;
      JTask_SendReminder_b             :=false;
      JTask_ReminderSent_b             :=false;
      JTask_ReminderSent_DT            :='NULL';
      JTask_Remind_DaysAhead_u         :=0;
      JTask_Remind_HoursAhead_u        :=0;
      JTask_Remind_MinutesAhead_u      :=0;
      JTask_Remind_Persistantly_b      :=false;
      JTask_Progress_PCT_d             :=0;
      JTask_JCase_ID                   :=0;
      JTask_Directions_URL             :='NULL';
      JTask_URL                        :='NULL';
      JTask_Milestone_b                :=false;
      JTask_Budget_d                   :=0;
      JTask_ResolutionNotes            :='';
      JTask_Completed_DT               :='NULL';
      JTask_Related_JTable_ID          :=rJTable.JTabl_JTable_UID;
      JTask_Related_Row_ID             :=0;
    end;//with
    bOk:=bJAS_Save_JTask(Context, Context.VHDBC, rJTask, false,false,201603310312);
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
        JJobQ_JJobQ_UID           :=0;
        JJobQ_JUser_ID            :=Context.rJSession.JSess_JUser_ID;
        JJobQ_JJobType_ID         :=cnJJobType_General;
        JJobQ_Start_DT            :=FormatDateTime(csDateTimeFormat,dt);
        JJobQ_ErrorNo_u           :=0;
        JJobQ_Started_DT          :='NULL';
        JJobQ_Running_b           :=false;
        JJobQ_Finished_DT         :='NULL';
        JJobQ_Name                :=rJTable.JTabl_Name+' export';
        JJobQ_Repeat_b            :=false;
        JJobQ_RepeatMinute        :='NULL';
        JJobQ_RepeatHour          :='NULL';
        JJobQ_RepeatDayOfMonth    :='NULL';
        JJobQ_RepeatMonth         :='NULL';
        JJobQ_Completed_b         :=false;
        JJobQ_Result_URL          :='NULL';
        JJobQ_ErrorMsg            :='NULL';
        JJobQ_ErrorMoreInfo       :='NULL';
        JJobQ_Enabled_b           :=true;

        // POPULATE THIS WITH ALL CGIENV.DataIn parameters
        // But ADD the TASK ID so we can...
        // 1: Update task record as we progress
        // 2: Route Output to a file versus a webpage for download
        // 3: Update Task with URL for the download.
        JJobQ_Job:=
        '<CONTEXT>'+csCRLF+
        '  <saRequestMethod>POST</saRequestMethod>'+csCRLF+
        '  <saRequestType>HTTP/1.0</saRequestType>'+csCRLF+
        '  <saRequestedFile>'+Context.sAlias+'</saRequestedFile>'+csCRLF+
        '  <saQueryString>screen='+saEncodeURI(JScreen.rJScreen.JScrn_Name)+'</saQueryString>'+csCRLF+
        '  <REQVAR_XDL>'+csCRLF+
        '    <ITEM>'+csCRLF+
        '      <saName>HTTP_HOST</saName>'+csCRLF+
        '      <saValue>'+garJVHost[Context.u2VHost].VHost_ServerDomain+'</saValue>'+csCRLF+
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
          '       <saValue>'+inttostr(rJTask.JTask_JTask_UID)+'</saValue>'+csCRLF+
          '     </ITEM>'+csCRLF;
        end;
        JJobQ_Job+=
        '   </DATAIN>'+csCRLF+
        '  </CGIENV>'+csCRLF+
        '</CONTEXT>';
        JJobQ_Result              :='NULL';
        JJobQ_JTask_ID            :=rJTask.JTask_JTask_UID;

        bOk:=bJAS_Save_JJobQ(Context, Context.VHDBC, rJJobQ, false,false,201603310313);
        if not bOk then
        begin
          JAS_LOG(Context, cnLog_Error, 201210231334,'Unable to save JobQ record for background data export of '+rJTable.JTabl_Name,'',SOURCEFILE);
        end;

        if bOk then
        begin
          Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGEICON@]','[@JASDIRICONTHEME@]64/mimetypes/x-office-spreadsheet.png');
          Context.saPage:=saGetPage(Context,'sys_area','sys_page_message','MESSAGE',false,'',201210231345);
          sa:='Your export has been placed into a queue to be processed. '+
            '<a target="_blank" href="[@ALIAS@].?screen=jtask+Data&UID='+inttostr(rJTask.JTask_JTask_UID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+'">'+
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

    //asPrintln(saRepeatChar('=',79));
    //asPrintln(saRepeatChar('=',79));
    //if bMultiMode then
    //begin
    //  case uMode of
    //  //cnJBlokMode_Deleted - past tense
    //  //cnJBlokMode_Cancel       :
    //  //cnJBlokMode_CancelNClose :
    //  cnJBlokMode_View         : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_View_JSecPerm_ID)   ; bOk:=(rJTable.JTabl_View_JSecPerm_ID  =0) or bPerm; end;
    //  cnJBlokMode_Delete       : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Delete_JSecPerm_ID) ; bOk:=(rJTable.JTabl_Delete_JSecPerm_ID=0) or bPerm; end;
    //  cnJBlokMode_New          : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Add_JSecPerm_ID)    ; bOk:=(rJTable.JTabl_Add_JSecPerm_ID   =0) or bPerm; end;
    //  cnJBlokMode_Edit         : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID) ; bOk:=(rJTable.JTabl_Update_JSecPerm_ID=0) or bPerm; end;
    //  cnJBlokMode_Save         : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID) ; bOk:=(rJTable.JTabl_Update_JSecPerm_ID=0) or bPerm; end;
    //  cnJBlokMode_SaveNClose   : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID) ; bOk:=(rJTable.JTabl_Update_JSecPerm_ID=0) or bPerm; end;
    //  cnJBlokMode_SaveNNew     : begin bPerm:=bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID) ; bOk:=(rJTable.JTabl_Update_JSecPerm_ID=0) or bPerm; end;
    //  else bPerm:=false;//else
    //  end;//case
    //  ASPrintln('bOk: '+sYesNo(bOK)+' saMulti: '+sYesNo(bMultiMode)+' Table:' + rJTable.JTabl_Name+' has Perm:'+sYesNo(bPerm));
    //end;
    //asprintln('bMultiMode:'+sYesNo(bMultiMode));
    //asPrintln(saRepeatChar('=',79));
    //asPrintln(saRepeatChar('=',79));
  end;

  if bOk and (not JScreen.bPageCompleted) Then
  begin
    //asPrintln(saRepeatChar('=',79));
    //asprintln('Begin bGrid call');
    //asPrintln(saRepeatChar('=',79));
    bOk:=bGrid;
    //asPrintln(saRepeatChar('=',79));
    //asprintln('End bGrid call');
    //asPrintln(saRepeatChar('=',79));
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011855,'TJBLOK.bExecuteGridBlok - bGrid Call Failed. Screen: '+inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+
        ' JBlok: '+rJBlok.JBlok_Name,'',SOURCEFILE);
    end;
  end;

  If bOk and (not JScreen.bPageCompleted) Then
  Begin
    if JScreen.bExportingNow then
    begin
      if JScreen.saExportMode='TABULAR' then
      begin
        if trim(saSectionMiddle)<>'' then
        begin
          JScreen.saTemplate:=saSNRStr(saSectionMiddle, '[$BLOKGRID$]',saContent);
        end
        else
        begin
          JScreen.saTemplate:=saContent;
        end;
        JScreen.saTemplate+='</body></html>';
      end else

      if JScreen.saExportMode='CSV' then
      begin
        JScreen.saTemplate:=saContent;
        //Context.CGIENV.Header_PlainText;
      end else

      begin // Unknown? Treat as pure html tabular output without style
        if trim(saSectionMiddle)<>'' then
        begin
          JScreen.saTemplate:=saSNRStr(saSectionMiddle, '[$BLOKGRID$]',saContent);
        end
        else
        begin
          JScreen.saTemplate:=saContent;
        end;
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
  u8JWidgetID: uint64;
  u8JDTypeID: uint64;
  rs: JADO_RECORDSET;

  JScreen: TJSCREEN;
  Context: TCONTEXT;
  JBlokField: TJBLOKFIELD;
  PosXDL: JFC_XDL;
  s,sBFS: string;
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
  saContent:='';//<input type="hidden" id="JSID" name="SID" value="'+Context.rJSession.JSess_JSession_UID+'"/>';


  JScreen.u2GridRowsPerPage:=u4Val(saJASUserPref(Context,bOk,cnJUserPref_GridRowsPerPage, Context.rJUser.JUser_JUser_UID));
  if JScreen.u2GridRowsPerPage<1 then
  begin
    JScreen.u2GridRowsPerPage:=cnGrid_RowsPerPage;
  end;

  if FXDL.MoveFirst then
  begin
    repeat
      JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
      if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
      begin
        PosXDL.AppendItem;
        PosXDL.Item_saName:=inttostr(PosXDL.N);
        PosXDL.Item_saValue:=inttostr(PosXDL.N);
        PosXDL.Item_i8User:=B00;//bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
        JBlokField.bSort:=false;
        if Context.CGIENV.DataIn.FoundItem_saName('bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'U') then
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
        if Context.CGIENV.DataIn.FoundItem_saName('bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'P') then
        begin
          JBlokField.uSortPosition:=u2Val(Context.CGIENV.DataIn.Item_saValue);
        end;
        //Context.PageSNRXDL.AppendItem_saName_N_saValue('[@BFS'+JBlokfield.rJColumn.JColu_JColumn_UID+'S@]', inttostr(JBlokField.uSortPosition));
      end;
    until not FXDL.MoveNext;
  end;


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
      AppendItem_SNRPair('[@GRIDADMIN_JBLOK_JBLOK_UID@]',inttostr(rJBlok.JBlok_JBlok_UID));
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
      saSectionMiddle:=saGetPage(Context, '','sys_page_screenfiltergrid_export_html','',true,123020100011);
    end;
  end;

  //saContent+='';//<br />Query:<b>'+saQry+'</b><br />';
  if (not JScreen.bExportingNow) and (not bView) then
  begin
    saContent+='<input type="hidden" id="multi" name="multi" />'+
               '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-copy.png" '+
               'title="Click to edit selected records simultaneously." '+
               'onclick="document.getElementById(''multi'').value=''EDIT'';SubmitForm();" />&nbsp;&nbsp;&nbsp;'+
               '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/media-playback-pause.png" '+
               'title="Click to merge TWO selected records into one." ';
    saContent+='onclick="document.getElementById(''multi'').value=''MERGE'';SubmitForm();" />&nbsp;&nbsp;&nbsp;'+
               '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" '+
               'title="Click to delete selected records. " '+
               'onclick="if(confirm(''Delete ALL selected Records?'')){'+
               'document.getElementById(''multi'').value=''DELETE'';SubmitForm();}else{return false;}" />&nbsp;'+
               'Multi-Selection Tools&nbsp;&nbsp;&nbsp;&nbsp;<a target="_blank" href="[@ALIAS@].?action=help&helpid='+
                 inttostr(rJBlok.JBlok_Help_ID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+
               '" title="Generic Result Grid Help">'+
               '<img class="image" src="<? echo $JASDIRICONTHEME; ?>32/actions/help-contents.png" title="Generic Result Grid Help" /></a>';

    saContent+='<table class="jasgridnoborder">'+csCRLF;

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
    begin // Unknown? Treat as pure html tabular output without style (Heathens! No Style,No Class)
      //saContent+='<table><thead><tr>';
      saContent+='<table border="1"><thead><tr>';
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

        sBFS:='bfs'+inttostr(JBlokField.rJBlokField.JBlkF_JColumn_ID);
        JScreen.saResetForm+='ResetSwitch("'+sBFS+'");';

        //saContent+='<td align="left" valign="middle" ><table><tr><td>';
        saContent+='<td align="left" valign="middle" ><table border="0"><tr><td>';

        if (JBlokField.rJBlokField.JBlkF_JColumn_ID>0)  then
        begin
          //saContent+='FXDL.Item_i8User:'+inttostr(FXDL.Item_i8User)+' ';
          //saContent+='JBlokField.uSortPosition:'+inttostr(JBlokField.uSortPosition);
          s:='Click icon to sort. The numbers decide what column is sorted first.';
          saContent+=csCRLF+'<div id="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'" ';
          if not (FXDL.Item_i8User=0) then saContent+=' style="display: none;"';
          saContent+='><img title="'+s+'" class="image" onclick="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x = sortswitch(''bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+''',bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-no.png" /></div>'+
                   csCRLF+'<div id="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'A" ';
          if not (FXDL.Item_i8User=1) then saContent+=' style="display: none;"';
          saContent+='><img title="'+s+'" class="image" onclick="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x = sortswitch(''bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+''',bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></div>'+
                   csCRLF+'<div id="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'D" ';
          if not (FXDL.Item_i8User=2) then saContent+=' style="display: none;"';
          saContent+='><img title="'+s+'" class="image" onclick="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x = sortswitch(''bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+''',bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></div>'+
                   csCRLF+'<input type="hidden" name="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'U" id="bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'U" value="'+inttostr(FXDL.Item_i8User)+'" /><script language="javascript">var bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'x=2;</script>'+
                   csCRLF+'</td><td>[#bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'P#]</td></tr>';

          if PosXDL.FoundItem_saValue(inttostr(JBlokField.uSortPosition)) then
          begin
            PosXDL.Item_i8User:=B00+B01+B02;
          end;

                 // // u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
          WidgetList(                                          // Procedure WidgetList(
            Context,                                           //   p_Context: TCONTEXT;
            'bfs'+inttostr(JBlokfield.rJColumn.JColu_JColumn_UID)+'P',   //   p_sWidgetName: String;
            '',                                                //   p_sWidgetCaption: String;
            inttostr(JBlokField.uSortPosition),                //   p_saDefaultValue: AnsiString;
            1,                                               //   p_sSize: String;
            false,                                             //   p_bMultiple: boolean;
            true,                                              //   p_bEditMode: Boolean;
            garJVHost[Context.u2VHost].VHost_DataOnRight_b,                          //   Data on right
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
            saContent+='"';//left quote
          end else

          begin // Unknown? Treat as pure html tabular output without style

          end;
        end;

        // if the Widgettype is non-zero, then widget type can dictate alignment
        u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;
        u8JDTypeID:=JBlokField.rJColumn.JColu_JDType_ID;
        if u8JWidgetID=0 then u8JWidgetID:=u8JDTypeID;
        if bIsJDTypeMemo(u8JWidgetID) then
        begin
          // Note: This code makes a scrollable table cell.
          // Width and Height are px (ignores JBlkF_Width_is_Percent_b flag.
          // if eight with or height is zero then 300px x 100px is used as a default failsafe
          if JBlokField.rJBlokField.JBlkF_Widget_Width<=0 then
          begin
            JBlokField.rJBlokField.JBlkF_Widget_Width:=300;
          end;
          if JBlokField.rJBlokField.JBlkF_Widget_Height<=0 then
          begin
            JBlokField.rJBlokField.JBlkF_Widget_Height:=100;
          end;
        end else

        if bIsJDTypeNumber(u8JWidgetID) then
        begin
          JBlokField.sAlignment:='right';
        End else

        if (bIsJDTypeText(u8JWidgetID) or (u8JWidgetID=cnJWidget_URL) or (u8JWidgetID=cnJWidget_Email)) then
        Begin
          JBlokField.sAlignment:='left';
        End else

        if bIsJDTypeBoolean(u8JWidgetID) then
        Begin
          JBlokField.sAlignment:='center';
        End else

        if bIsJDTypeDate(u8JWidgetID) then
        begin
          JBlokField.sAlignment:='center';
        End else

        if (u8JWidgetID=cnJWidget_Lookup) or
           (u8JWidgetID=cnJWidget_Dropdown) or
           (u8JWidgetID=cnJWidget_ComboBox) then
        begin
          JBlokField.sAlignment:='left';
        end;

        if not JScreen.bExportingNow then
        begin
          saContent+='<td style="text-align:'+JBlokField.sAlignment+';" valign="middle" >';
        end
        else
        begin
          if JScreen.saExportMode='TABULAR' then
          begin
            saContent+='<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:1px;text-align:'+JBlokField.sAlignment+';" valign="middle" >';
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
          saContent+='<a href="#" title="';
          if JBlokfield.rJColumn.JColu_Name<>'' then
          begin
            saContent+=JBlokfield.rJColumn.JColu_Name;
          end
          else
          begin
            saContent+='[Custom]';
          end;
          saContent+='">'+JBlokField.saCaption+'</a>';
        end
        else

        if JScreen.saExportMode='TABULAR' then
        begin
          saContent+=JBlokField.saCaption;//This is the column Caption
          //ASPRintln(saRepeatChar('=',79));
          //ASPrintln('Tabular Caption Read: '+JBlokField.saCaption);
          //ASPRintln(saRepeatChar('=',79));
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
          saContent+='<a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+
            inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+
            '&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''');"><img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a>';
          if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
          begin
            saContent+='<a title="Edit JColumn" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+
              inttostr(JBlokField.rJBlokField.JBlkF_JColumn_ID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''');"><img class="image" '+
              'title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a>';
          end;
          saContent+='<a title="Left" href="javascript: editcol_left('''+inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a>';
          saContent+='<a title="Right" href="javascript: editcol_right('''+inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a>';
          saContent+='<a title="Delete" href="javascript: editcol_delete('''+inttostr(rJBlok.JBlok_JBlok_UID)+''','''+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a>';
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
          saContent+=saLeftStr(saContent,length(saContent)-1);
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
      if not JScreen.bRecycleBinMode then
      begin
        if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
        JScreen.saQueryWhere+='(('+DBC.sDBMSEncloseObjectName(rJTable.JTabl_ColumnPrefix+'_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true) +
          ') or ('+DBC.sDBMSEncloseObjectName(rJTable.JTabl_ColumnPrefix+'_Deleted_b')+' is null)) ';
        Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@RECYCLEBINICON@]','');
      end
      else
      begin
        if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
        JScreen.saQueryWhere+='('+DBC.sDBMSEncloseObjectName(rJTable.JTabl_ColumnPrefix+'_Deleted_b')+'='+DBC.sDBMSBoolScrub(true) +')';
        Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@RECYCLEBINICON@]','<img class="image" src="'+garJVHost[Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+context.sIconTheme+'/64/places/user-trash.png" /><p>You are viewing records set to be deleted.</p>');
      end;
    end
    else Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@RECYCLEBINICON@]','');

    if rJTable.JTabl_Owner_Only_b and (NOT (Context.rJUser.JUser_Admin_b and (garJVHost[Context.u2VHost].VHost_ServerName='default'))) and
      (NOT bJAS_HasPermission(Context, cnPerm_Master_Admin)) and (NOT bJAS_HasPermission(Context,cnPerm_Admin)) and
       rAudit.bUse_CreatedBy_JUser_ID then
    begin
      if JScreen.saQueryWhere<>'' then JScreen.saQueryWhere+=' AND ';
      JScreen.saQueryWhere+=' '+DBC.sDBMSEncloseObjectName(rAudit.saFieldName_CreatedBy_JUser_ID)+'='+DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID);
    end;
    
    if JScreen.saQueryWhere<>'' then
    begin
      //AS_Log(Context,cnLog_Debug,201210220334,'Where clause before adding new WHERE: '+JScreen.saQueryWhere,'',SOURCEFILE);
      JScreen.saQueryWhere:=' WHERE '+JScreen.saQueryWhere;
    end;


    //if trim(JScreen.saQueryFrom)='' then
    //begin
    JScreen.saQueryFrom:=' FROM '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' ';
    //end;
    
    case TGT.u8DBMSID of
    cnDBMS_MSAccess: saQry:=' SELECT count(*) as mycount ' + JScreen.saQueryFrom + JScreen.saQueryWhere;
    else saQry:=' SELECT count(*) as mycount ' + JScreen.saQueryFrom + JScreen.saQueryWhere;
    end;//switch
    bOk:=rs.Open(saQry, TGT,201503161514);
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200702271300,'Dynamic Query for counting records failed.','Query: '+saQry,SOURCEFILE,TGT,rs);
      //riteln('uj_ui_screen --- trying to log 200702271300');
    End;
    //AS_Log(Context,cnLog_ebug,201203201155,'Filter Blok record Count: '+rs.fields.Get_saValue('mycount')+' Query: '+saQry,'',SOURCEFILE);
  end
  else
  begin
    if FXDL.MoveFirst then
    begin
      // no html setup for exports because output in tests show the starting
      // tags as being rendered already.
      repeat
        JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        if JScreen.saExportMode='TABULAR' then
        begin
          saContent+='<th>'+JBlokField.rJColumn.JColu_Name+'</th>'+csCRLF;
        end else

        if JScreen.saExportMode='CSV' then
        begin
          if (not FXDL.BOL) and (not FXDL.EOL) then saContent+=',';
          JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
          saContent+=JBlokField.rJColumn.JColu_Name;
        end else

        begin // Unknown? Treat as pure html tabular output without style
          saContent+='<th>'+JBlokField.rJColumn.JColu_Name+'</th>'+csCRLF;
        end;
      until (not FXDL.MoveNExt);

      if JScreen.saExportMode='TABULAR' then
      begin
        saContent+='</tr></thead>'+csCRLF;
      end else

      if JScreen.saExportMode='CSV' then
      begin
        saContent+=csCRLF;
      end else

      begin // Unknown? Treat as pure html tabular output without style
        saContent+='</tr></thead>'+csCRLF;
      end;
    end
    else
    begin
      saContent:='Error Code: 201607101340 - You do not appear to have any columns to export. I did try though.';
    end;
  end;

  if bOk then
  begin
    JScreen.u8RecordCount:=uVal(rs.Fields.Get_saValue('mycount'));
  end;
  rs.close;

  if bOk then
  begin
    //ASPrintln(' about to hit bGridQuery. content: '+saContent);
    bOk:=bGridQuery;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201202242100,'Query Failed','bGrid_ExecuteQuery failed.',SOURCEFILE);
      //riteln('uj_ui_screen --- trying to log 201202242100');
    end;
  end;

  saContent+='<script>function ResetForm(){'+JScreen.saResetForm+'};</script>';



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
  u8RecordID: UInt64;
  sRecordID: string[21];
//  sRecordIDWrap: string[64];// made longer than 64bit 19 char cuz widget names are wrapped around this variable in the same variable - recycled.
  saCheck: ansistring;
  saUncheck: ansistring;
  sMEKey: string[21];
  bOkToMultiEdit: boolean;
  sMergeRecord1: string;
  sMergeRecord2: string;
  uMERGErecords: cardinal;
  u8JWidgetID: uint64;
  saLUSQL: ansistring;
  sLUTable: string;
  u8ClickActionID: UInt64;
  dt: TDATETIME;
  bDateOk: boolean;
  sDateMask: string;
  bSecAdd,bSecView,bSecDelete,bSecUpdate: boolean;
  sPermColumnName: string;
  uTempWidgetWidth: UInt;
  uDivided: uint;
  u8JSessionID: uint64;
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

  if context.bInternalJob then JASPRintln('bGridQuery - BEGIN');

  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  SXDL:=JFC_XDL.Create;
  bShowRow:=false;
  bUIDINQuery:=false;
  saCheck:='';
  saUnCheck:='';
  sPermColumnName:=DBC.saGetValue('jcolumn','JColu_Name','JColu_JColumn_UID='+DBC.sDBMSUIntScrub(rJTable.JTabl_Perm_JColumn_ID),201608230013);
  u8JSessionID:=Context.rJSession.JSess_JSession_UID;
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
    if context.bInternalJob then JASPRintln('bGridQuery - A');

    bUIDINQuery:=false;
    repeat
      JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
      if (JBlokField.rJBlokField.JBlkF_JColumn_ID>0) then
      begin
        JBlokField.sColumnAlias:=JBlokField.rJColumn.JColu_Name;
        if not bUIDINQuery then bUIDINQuery:= (JBlokField.rJColumn.JColu_Name=rJColumn_Primary.JColu_Name);
        if JScreen.saQuerySelect<>'' then JScreen.saQuerySelect+=', ';
        //----------------------------------------------------------------
        JScreen.saQuerySelect+=DBC.sDBMSEncloseObjectName(JBlokField.sColumnAlias);
        //JScreen.saQuerySelect+=JBlokField.sColumnAlias;
        //----------------------------------------------------------------
        if JBlokField.rJColumn.JColu_LU_JColumn_ID>0 then
        begin
            saLUSQL:=Context.saLookUpSQL(
            rJTable.JTabl_Name,
            JBlokField.rJColumn.JColu_Name,
            sLUTable
          );
          saLUSQL:=saSNRStr(saLUSQL, 'DisplayMe','[@NEWNAME@]');
          saLUSQL:=saSNRStr(saLUSQL, '[@NEWNAME@]',sLUTable+inttostr(FXDL.N)+'_DisplayMe');

          JBlokField.sColumnAlias:=sLUTable+inttostr(FXDL.N)+'_DisplayMe';
          JScreen.saQueryFrom += ' LEFT JOIN ( '+saLUSQL+') AS '+sLUTable+inttostr(FXDL.N) +' '+
            'ON '+DBC.sDBMSEncloseObjectName(JBlokField.rJColumn.JColu_Name)+'='+sLUTable+inttostr(FXDL.N)+'.ColumnValue';
          JScreen.saQuerySelect+=', '+DBC.sDBMSEncloseObjectName(JBlokField.sColumnAlias);
        end;
        if (JBlokField.bSort) then
        begin
          SXDL.AppendItem_saName(sZeroPadUInt(JBlokField.uSortPosition,8));
          SXDL.Item_i8User:=FXDL.N;
        end;
      end;
    until not FXDL.MoveNext;
    if context.bInternalJob then JASPRintln('bGridQuery - B');

    if not bUIDINQuery then
    begin
      if context.bInternalJob then JASPRintln('bGridQuery - C');

      if length(trim(rJColumn_Primary.JColu_Name))>0 then
      begin
        if JScreen.saQuerySelect<>'' then JScreen.saQuerySelect+=', ';
        JScreen.saQuerySelect+=DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name);
      end;
    end;

    if context.bInternalJob then JASPRintln('bGridQuery - D');

    SXDL.SortItem_saName(true,true);
    //AS_LOG(Context,cnLog_ebug,201203210353,SXDL.saHTMLTABLE,'',SOURCEFILE);
    if SXDL.MoveFirst then
    begin
      if context.bInternalJob then JASPRintln('bGridQuery - E');
      sa:='';
      repeat
        if FXDL.FoundNth(SXDL.Item_i8User) then
        begin
          JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
          if sa='' then sa:='ORDER BY ' else sa+=',';
          if JBlokField.rJColumn.JColu_LU_JColumn_ID>0 then
          begin
            sa+=DBC.sDBMSEncloseObjectName(JBlokField.sColumnAlias);
          end
          else
          begin
            sa+=DBC.sDBMSEncloseObjectName(JBlokField.sColumnAlias);
          end;
          if NOT JBlokField.bAscending then sa+=' DESC ';
        end;
      until not SXDL.MoveNext;
      JScreen.saQueryOrder:=sa;
      if context.bInternalJob then JASPRintln('bGridQuery - F');

    end;
  end;

  if context.bInternalJob then JASPRintln('bGridQuery - G');

  if JScreen.saQuerySelect='' then
  begin
    JScreen.saQuerySelect:='SELECT 1 as OneColumn, 201607080616 as MarkerInSourcecode';
  end
  else
  begin
    JScreen.saQuerySelect:='SELECT '+JScreen.saQuerySelect;
  end;




  //saQry:='SELECT '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name) + ' '+JScreen.saQueryFrom + JScreen.saQueryWhere + ' GROUP BY '+rJColumn_Primary.JColu_Name+JScreen.saQueryOrder;
  saQry:='SELECT '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name) + ' '+
    JScreen.saQueryFrom + JScreen.saQueryWhere +
    ' GROUP BY '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+' '+JScreen.saQueryOrder;


  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));
  //riteln('GridQuery: '+saQry);
  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));
  if context.bInternalJob then JASPRintln('bGridQuery - H');

  if(Context.u2DebugMode <> cnSYS_INFO_MODE_SECURE) then
  begin
    JScreen.Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SCREENQUERY@]',saQry+'  rJColumn_Primary.JColu_Name:'+rJColumn_Primary.JColu_Name);
  end
  else
  begin
    JScreen.Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SCREENQUERY@]','');
  end;

  if context.bInternalJob then JASPRintln('bGridQuery - I');

  
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
      //riteln('uj_ui_screen - trying to log 200701061347');
    End;
  end;



  if context.bInternalJob then JASPRintln('bGridQuery - J');



  If bOk Then
  Begin
    if context.bInternalJob then JASPRintln('bGridQuery - K');

    JScreen.uRPage:=u4Val(JScreen.Context.CGIENV.DATAIN.Get_saValue('RPAGE'));
    JScreen.uRTotalPages:=u4Val(JScreen.Context.CGIENV.DATAIN.Get_saValue('RTOTALPAGES'));
    JScreen.uRTotalRecords:=0;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='firstpage') Then JScreen.uRPage:=1;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='lastpage') Then JScreen.uRPage:=JScreen.uRTotalPages;
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='backpage') Then dec(JScreen.uRPage);
    If (JScreen.Context.CGIENV.DataIn.Get_saValue('gridnav')='nextpage') Then Inc(JScreen.uRPage);
    JScreen.uRTotalPages:=JScreen.u8RecordCount Div JScreen.u2GridRowsPerPage;
    If (JScreen.u8RecordCount Mod JScreen.u2GridRowsPerPage)>0 Then
    Begin
      Inc(JScreen.uRTotalPages);
    End;
    If JScreen.uRPage>JScreen.uRTotalPages Then JScreen.uRPage:=JScreen.uRTotalPages;
    If JScreen.uRTotalPages=0 Then JScreen.uRTotalPages:=1;
    If JScreen.uRPage=0 Then JScreen.uRPage:=1;


    bColorRed:=false;
    If not rs2.EOL Then
    Begin
      if context.bInternalJob then JASPRintln('bGridQuery - L');
      bDoneQuery:=false;
      repeat
        if context.bInternalJob then JASPRintln('bGridQuery - L A');
        //ASPrintln('JScreen.bBackgroundExporting: '+sTrueFalse(JScreen.bBackgroundExporting)+' JScreen.uRTotalRecords: '+inttostr(JScreen.uRTotalRecords)+' Mod 200:'+inttostR(JScreen.uRTotalRecords mod 200));
        if bOk and JScreen.bBackgroundExporting and ((JScreen.uRTotalRecords mod 200)=0) and (JScreen.uRTotalRecords>0) then
        begin
          if context.bInternalJob then JASPRintln('bGridQuery - L B - JScreen.u8RecordCount:'+inttostr(JScreen.u8RecordCount));

          if JScreen.u8RecordCount>0 then
            uDivided:=JScreen.uRTotalRecords div JScreen.u8RecordCount
          else
            uDivided:=1;


          saQry:='UPDATE jtask SET JTask_JStatus_ID='+DBC.sDBMSUIntScrub(cnJStatus_InProgress)+', '+
            'JTask_Progress_PCT_d='+DBC.sDBMSDecScrub(saDouble((uDivided*100.0),5,2))+' '+
            'WHERE JTask_JTask_UID='+DBC.sDBMSUIntScrub(JSCreen.u8BackTask);
          //ASPrintln('JTask update: '+saQry);
          if context.bInternalJob then JASPRintln('bGridQuery - L C');

          bOk:=rs3.open(saQry, DBC,201503161516);

          if context.bInternalJob then JASPRintln('bGridQuery - L D');

          if not bOk then
          begin
            //riteln('uj_ui_screen - trying to log 201210241239');
            JAS_LOG(Context, cnLog_Error, 201210241239,'Unable to load update JTask Record: '+inttostr(JSCreen.u8BackTask),'Query: '+saQry,SOURCEFILE);
          end;
          rs3.close;
        end;

        if context.bInternalJob then JASPRintln('bGridQuery - L E');

        if bOk then
        begin
          bOk:=bJAS_TablePermission(
            Context,
            rJTable,
            u8Val(rs2.fields.Get_saValue(rJColumn_Primary.JColu_Name)),
            u8Val(rs2.fields.Get_saValue(sPermColumnName)),
            bSecAdd, bSecView,bSecUpdate,bSecDelete,
            false,true,false,false
          );
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201211051433,'Unable to check permissions for table '+rJTable.JTabl_Name+
              ' Row: '+rs2.fields.Get_saValue(sPermColumnName),'',SOURCEFILE);
            //riteln('uj_ui_screen - trying to log 201211051433');
          end;
        end;

        if context.bInternalJob then JASPRintln('bGridQuery - L F');

        if bOk then
        begin
          if context.bInternalJob then JASPRintln('bGridQuery - L G');

          if bSecView then
          begin

            if context.bInternalJob then JASPRintln('bGridQuery - L H');

            // bShow Row - Page Number PAss----------------------------------------
            Inc(JScreen.uRTotalRecords);
            JScreen.u8PageRowMath:=((JScreen.uRTotalRecords-1) Div JScreen.u2GridRowsPerPage);
            if not JScreen.bExportingNow then
            begin

              if context.bInternalJob then JASPRintln('bGridQuery - L I');


              bShowRow:=(JScreen.u8PageRowMath=(JScreen.uRPage-1));
              if JScreen.u8PageRowMath>(JScreen.uRPage-1) then bDoneQuery:=true;
            end
            else
            begin
              if context.bInternalJob then JASPRintln('bGridQuery - L J');

              if (JScreen.saExportPage='ALL') then
              begin
                bShowRow:=true;
              end
              else
              begin
                bShowRow:=(JScreen.u8PageRowMath=(iVal(JScreen.saExportPage)-1));
                //JAS_LOG(JScreen.Context, cnLog_Debug, 201204301358,
                //  'bShowRow: '+sYesNo(bShowRow)+' '+
                //  'JScreen.uPageRowMath: '+inttostR(JScreen.uPageRowMath)+' '+
                //  'JScreen.saExportPage: '+JScreen.saExportPage+' '+
                //  'iVal(JScreen.saExportPage): '+inttostr(iVal(JScreen.saExportPage)),'',SOURCEFILE);
                if JScreen.u8PageRowMath>(iVal(JScreen.saExportPage)-1) then bDoneQuery:=true;
                //if bShowRow then
                //begin
                //  bShowRow:=Context.CGIENV.DataIn.FoundItem_saName('MS'+rs.fields.Get_saValue(rJColumn_Primary.JColu_Name));
                //end;
              end;

              if context.bInternalJob then JASPRintln('bGridQuery - L K');

            end;
            // bShow Row - Page Number PAss----------------------------------------
          end;

          // Render Pass --------------------------------------------------------

          if context.bInternalJob then JASPRintln('bGridQuery - L J');

          If bShowRow Then
          Begin
            saQry:=JScreen.saQuerySelect + JScreen.saQueryFRom + ' WHERE '+
              DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+'='+DBC.sDBMSUIntScrub(rs2.fields.Get_saValue(rJColumn_Primary.JColu_Name));

            bOk:=rs.open(saQry, TGT,201503161517);
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Error,201204161650, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
              //riteln('uj_ui_screen - trying to log 201204161650');
            end;

            if bOk then
            begin
              // name is correct, this is for when uid in the query (means loss the one we used behind scenes)
              sRecordID:=rs.Fields.Get_saValue(rJColumn_Primary.JColu_Name);
              u8RecordID:=u8Val(sRecordID);
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

              if context.bInternalJob then JASPRintln('bGridQuery - L K');

              if FXDL.MoveFirst then
              begin
                if context.bInternalJob then JASPRintln('bGridQuery - L L');

                if not JScreen.bExportingNow then
                begin
                  saContent+='<td><input type="checkbox" name="ms'+sRecordID+'" id="ms'+sRecordID+'" ';
                  if Context.CGIENV.DataIn.Get_saValue('ms'+sRecordID)='on' then saContent+='checked ';
                  saContent+='/></td>';
                  saCheck+='document.getElementById("ms'+sRecordID+'").checked=true;';
                  saUncheck+='document.getElementById("ms'+sRecordID+'").checked=false;';

                  saContent+=
                    '<td><a href="javascript: NewWindow(''[@ALIAS@].?UID='+sRecordID+'&[@DETAILSCREENID@]&BUTTON=EDIT&JSID='+
                      inttostr(u8JSessionID)+''');">'+
                    '<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/document-open.png" '+
                    'title="Click to edit this record." /></a></td>';
                end;

                repeat
                  if context.bInternalJob then JASPRintln('bGridQuery - L M');


                  JBlokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPTR);
                  u8ClickActionID:=JBlokField.rJBlokField.JBlkF_ClickAction_ID;
                  u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;
                  if u8JWidgetID=0 then u8JWidgetID:=JBlokField.rJColumn.JColu_JDType_ID;

                  if not JScreen.bExportingNow then
                  begin
                    if (cnJDType_sn=u8JWidgetID) or
                      (cnJDType_sun=u8JWidgetID) then
                    begin
                      // Note: This code makes a scrollable table cell.
                      // Width and Height are px (ignores JBlkF_Width_is_Percent_b flag.
                      // if eight with or height is zero then 300px x 100px is used as a default failsafe
                      saContent+='<td style="text-align:'+JBlokField.sAlignment+';" valign="top" >'+
                                '<div style="width: '+inttostr(JBlokField.rJBlokField.JBlkF_Widget_Width)+'px;'+
                                'height: '+inttostr(JBlokField.rJBlokField.JBlkF_Widget_Height)+'px;'+
                                'overflow: auto;" >';
                    end
                    else
                    begin
                      // Newer (NoWrap could use a better control mechanism but it's a start.
                      saContent+='<td style="text-align:'+JBlokField.sAlignment+';" valign="top" ';
                      if JBlokField.rJBlokField.JBlkF_Widget_Width>0 then
                      begin
                        saContent+='width="'+inttostr(JBlokField.rJBlokField.JBlkF_Widget_Width);
                        if JBlokField.rJBlokField.JBlkF_Width_is_Percent_b then
                        begin
                          saContent+='%';
                        end
                        else
                        begin
                          saContent+='px';
                        end;
                        saContent+='" ';
                      end;

                      if JBlokField.rJBlokField.JBlkF_Widget_Height>0 then
                      begin
                        saContent+='height="'+inttostr(JBlokField.rJBlokField.JBlkF_Widget_Height);
                        if JBlokField.rJBlokField.JBlkF_Height_is_Percent_b then
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
                    case u8ClickActionID of  // no SNR for this one (this clickaction)
                    cnJBlkF_ClickAction_None: ;
                    cnJBlkF_ClickAction_DetailScreen: begin // Detail Screen
                        saContent+='<a href="javascript: NewWindow(''[@ALIAS@].?UID='+inttostr(u8RecordID)+'&[@DETAILSCREENID@]&JSID='+inttostr(u8JSessionID)+''');">';
                    end;
                    cnJBlkF_ClickAction_Link: begin // Custom ClickAction Data  (Lines below take current record unique ID and puts it in place of those tokens) one for session id and the other the record id
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',trim(sRecordID));
                      sa:=saSNRStr(sa,'[@JSID@]',inttostr(u8JSessionID));
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
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',trim(sRecordID));
                      sa:=saSNRStr(sa,'[@JSID@]',inttostr(u8JSessionID));
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
                      //asprintln(saRepeatChar('=',79));
                      //asprintln('GRIDTEST: saRecordID: '+saRecordID);
                      //asprintln('click action: '+JBlokField.rJBlokField.JBlkF_ClickActionData);
                      //asprintln(saRepeatChar('=',79));
                      sa:=saSNRStr(JBlokField.rJBlokField.JBlkF_ClickActionData,'[@UID@]',sRecordID);
                      sa:=saSNRStr(sa,'[@JSID@]',inttostr(u8jSessionID));
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
                        JBlokField.sAlignment+';" valign="top" nowrap="nowrap">';
                    end else

                    if JScreen.saExportMode='CSV' then
                    begin
                      if (bIsJDTypeText(u8JWidgetID)) or
                        (u8JWidgetID=cnJWidget_DropDown) or
                        (u8JWidgetID=cnJWidget_Lookup) then
                      begin
                        saContent+='"';//right quote
                      end;
                    end else

                    begin // Unknown? Treat as pure html tabular output without style
                      saContent+='<td>';
                    end;
                  end;

                  If (trim(rs.fields.Get_saValue(JBlokField.sColumnAlias))='') or
                    (trim(rs.fields.Get_saValue(JBlokField.sColumnAlias))='NULL') Then
                  Begin
                    if not JScreen.bExportingNow then
                    begin
                      if u8ClickActionID<>cnJBlkF_ClickAction_Custom then
                      begin
                        if (trim(rs.fields.Get_saValue(JBlokField.sColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                          //end
                          //else
                          //begin
                          //saContent+='';
                        end;
                      end;
                    end
                    else
                    begin
                      if JScreen.saExportMode='TABULAR' then
                      begin
                        if (trim(rs.fields.Get_saValue(JBlokField.sColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                          //end
                          //else
                          //begin
                          //  saContent+='';
                        end;
                      end else

                      if JScreen.saExportMode='CSV' then
                      begin

                      end else

                      begin // Unknown? Treat as pure html tabular output without style
                        if (trim(rs.fields.Get_saValue(JBlokField.sColumnAlias))='NULL') then
                        begin
                          saContent+='NULL';
                          //end
                          //else
                          //begin
                          saContent+='';
                        end;
                      end;
                    end;
                  End
                  Else
                  Begin
                    if (JScreen.bExportingNow) or (u8ClickActionID<>cnJBlkF_ClickAction_Custom) then
                    begin
                      if bIsJDTypeDate(u8JWidgetID) then
                      begin
                        if '0000-00-00 00:00:00'<>trim(rs.fields.Get_saValue(JBlokField.sColumnAlias)) then
                        begin
                          bDateOk:= JBlokField.rJBlokField.JBlkF_Widget_Mask<>'NULL';
                          if bDateOk then
                          begin
                            try
                              dt:=StrToDateTime(JDATE(trim(rs.fields.Get_saValue(JBlokField.sColumnAlias)),1,11));
                            except on E : EConvertError do bDateOk:=false;
                            end;
                          end;
                          if bDateOk then
                          begin
                            JBlokField.rJBlokField.JBlkF_Widget_Mask:=trim(JBlokField.rJBlokField.JBlkF_Widget_Mask);
                            if (length(JBlokField.rJBlokField.JBlkF_Widget_Mask)>0) then
                            begin
                              //saContent+='[m2:'+JBlokField.rJBlokField.JBlkF_Widget_Mask+':]'+FormatDatetime(JBlokField.rJBlokField.JBlkF_Widget_Mask,dt)+'[m2]';
                              saContent+=FormatDatetime(JBlokField.rJBlokField.JBlkF_Widget_Mask,dt);
                            end
                            else
                            begin
                              sDateMask:='';
                              if JBlokField.rJBlokField.JBlkF_Widget_Date_b then
                              begin
                                sDateMask:='MM/DD/YYYY ';
                              end;
                              if JBlokField.rJBlokField.JBlkF_Widget_Time_b then
                              begin
                                sDateMask+='HH:NN AMPM';
                              end;
                              if sDateMask='' then sDateMask:= 'MM/DD/YYYY HH:NN AMPM';
                              //saContent+='[my]'+FormatDatetime(sDateMask,dt)+'[my]';
                              saContent+=FormatDatetime(sDateMask,dt);
                            end;
                          end
                          else
                          begin
                            //saContent+='['+rs.fields.Get_saValue(JBlokField.sColumnAlias)+']';
                            saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                          end;
                        end;
                      End else

                      if bIsJDTypeBoolean(u8JWidgetID) then
                      begin
                        if not JScreen.bExportingNow then
                        begin
                          if bVal(rs.fields.Get_saValue(JBlokField.sColumnAlias)) then
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
                            saContent+= trim(sYesNo(bVal(rs.fields.Get_saValue(JBlokField.sColumnAlias))));
                          end else

                          if JScreen.saExportMode='CSV' then
                          begin
                            saContent+= trim(sYesNo(bVal(rs.fields.Get_saValue(JBlokField.sColumnAlias))));
                          end else

                          begin
                            saContent+= trim(sYesNo(bVal(rs.fields.Get_saValue(JBlokField.sColumnAlias))));
                          end;
                        end;
                      End else

                      if bIsJDTypeNumber(u8JWidgetID) then
                      begin
                        if not JBlokField.rJColumn.JColu_Boolean_b then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                        end
                        else
                        begin
                          // supports non boolean types to serve as boolean flags e.g. 1, 0 (no words like true false .. good iea tho)
                          if rs.fields.Get_saValue(JBlokField.sColumnAlias)='NULL' then
                          begin
                            saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                          end
                          else
                          begin
                            saContent+=rs.fields.Get_saValue(sTrueFalse(bVal(JBlokField.sColumnAlias)));
                          end;
                        end;
                      End else

                      if (cnJWidget_Lookup=u8JWidgetID) or (cnJWidget_LookupComboBox=u8JWidgetID) then
                      begin
                        //saContent+=JBlokField.saLookUp(rs.fields.Get_saValue(JBlokField.sColumnAlias));
                        //saContent+=Context.saLookUp(
                        //  rJTable.JTabl_Name,
                        //  JBlokField.sColumnAlias,
                        //  rs.fields.Get_saValue(JBlokField.sColumnAlias)
                        //);
                        if rs.fields.Get_saValue(JBlokField.sColumnAlias)='NULL' then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokfield.rJColumn.JColu_Name)+' ]';
                        end
                        else
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                        end;
                      end else

                      if (cnJWidget_URL=u8JWidgetID) then
                      begin
                        //saContent+='<h3>got 2 1 bExport:'+sYesNo(JScreen.bExportingNow)+ 'iClickAction: '+inttostr(iClickAction) +'</h3>';
                        //if (JScreen.bExportingNow) or (iClickAction>0) then
                        if (JScreen.bExportingNow) or (u8ClickActionID=cnJBlkF_ClickAction_Custom) then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                        end
                        else
                        begin
                          sa:=trim(rs.fields.Get_saValue(JBlokField.sColumnAlias));
                          if (uppercase(saLeftStr(sa,7))<>'HTTP://') and
                            (uppercase(saLeftStr(sa,8))<>'HTTPS://') and
                            (uppercase(saLeftStr(sa,6))<>'FTP://') and
                            (saLeftStr(sa,1)<>'/') then
                          begin
                            sa:='http://'+sa;
                          end;
                          uTempWidgetWidth:=JBlokField.rJBlokField.JBlkF_Widget_Width;
                          saContent+='<a target="_blank" href="'+sa+'&JSID='+inttostr(u8JSessionID)+'" title="Click to go to '+JBlokField.saCaption+' in a new window or tab." >';
                          if length(sa)>uTempWidgetWidth then sa:=saLeftStr(sa,uTempWidgetWidth-3)+'...';
                          saContent+=sa+'</a>';
                        end;
                      end else




                      if (cnJWidget_Email=u8JWidgetID) then
                      begin
                        if (JScreen.bExportingNow) or (u8ClickActionID>0) then
                        begin
                          saContent+=rs.fields.Get_saValue(JBlokField.sColumnAlias);
                        end
                        else
                        begin
                          sa:=trim(rs.fields.Get_saValue(JBlokField.sColumnAlias));
                          if (uppercase(saLeftStr(sa,7))<>'mailto://') then
                          begin
                            sa:='mailto://'+sa;
                          end;
                          saContent+='<a target="_blank" href="'+sa+'&JSID='+inttostr(u8JSessionID)+'" title="Click to send and email to '+
                            JBlokField.saCaption+' with your default Email client." >';
                          if length(sa)>40 then sa:=saLeftStr(sa,37)+'...';
                          saContent+=sa+'</a>';
                        end;
                      end else

                      if (cnJWidget_Phone=u8JWidgetID) then
                      begin
                        if (JScreen.bExportingNow) or (u8ClickActionID>0) then
                        begin
                          saContent+=trim(rs.fields.Get_saValue(JBlokField.sColumnAlias));
                        end
                        else
                        begin
                          sa:=trim(rs.fields.Get_saValue(JBlokField.sColumnAlias));
                          saContent+='<a target="_blank" href="'+JScreen.saSIP_URL_Assembled(sa)+'&JSID='+inttostr(u8JSessionID)+'" title="Click to Dial" >';
                          if length(sa)>40 then sa:=saLeftStr(sa,37)+'...';
                          saContent+=sa+'</a>';
                        end;
                      end else

                      //if bIsJDTypeText(u2Val(JBlokField.rJBlokfield.JBlkF_JWidget_ID)) then
                      begin
                        if not JScreen.bExportingNow then
                        begin
                          //saContent+=saJDType(u2Val(JBlokField.rJBlokfield.JBlkF_JWidget_ID))+' : ';
                          saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.sColumnAlias),#10,'<br />');
                        end
                        else
                        begin
                          if JScreen.saExportMode='TABULAR' then
                          begin
                            saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.sColumnAlias),#10,'<br />');
                          end else

                          if JScreen.saExportMode='CSV' then
                          begin
                            saContent+=saDoubleEscape(rs.fields.Get_saValue(JBlokField.sColumnAlias),'"');
                          end else

                          begin
                            saContent+=saSNRStr(rs.fields.Get_saValue(JBlokField.sColumnAlias),#10,'<br />');
                          end;
                        end;
                      end;
                    end;
                  End;

                  if not JScreen.bExportingNow then
                  begin
                    case u8ClickActionID of
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

                    //case JBlokField.rJBlokField.JBlkF_JWidget_ID of
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
                      if bIsJDTypetext(JBlokField.rJColumn.JColu_JDType_ID) or
                        (u8JWidgetID=cnJWidget_DropDown) or
                        (u8JWidgetID=cnJWidget_Lookup) then
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
      if context.bInternalJob then JASPRintln('bGridQuery - N');
    End;
    rs2.Close;


    if context.bInternalJob then JASPRintln('bGridQuery - O');


    if bOk then
    begin

      if context.bInternalJob then JASPRintln('bGridQuery - P');

      if not JScreen.bExportingNow then
      begin
        if context.bInternalJob then JASPRintln('bGridQuery - Q');

        saContent+='</tbody></table>'+csCRLF;

        // MULTI EDIT ---------------------------------------------------------
        if bMultiMode and (uMode=cnJBlokMode_EDIT) then
        begin
          sMEKey:=inttostr(u8JAS_GetSessionKey);
          if Context.CGIENV.DataIn.MoveFirst then
          begin
            bOkToMultiEdit:=true;
            repeat
              sRecordID:=Context.CGIENV.DataIn.Item_saName;
              if saLeftStr(sRecordID,2)='MS' then
              begin
                sRecordID:=saRightStr(sRecordID, length(sRecordID)-2);
                if bJAS_LockRecord(Context,TGT.ID, rJTable.JTabl_Name, u8Val(sRecordID), 0,201501020032) then
                begin
                  Context.SessionXDL.AppendItem_saName_N_saValue('MEDIT'+sMEKey,sRecordID);
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
            bOkToMultiEdit:=Context.SessionXDL.FoundItem_saName('MEDIT'+sMEKey,true);
            if not bOkToMultiEdit then
            begin
              saSectionTop:='No records selected for multi-edit.';
            end
            else
            begin
              //SUCCESS
              Context.bSaveSessionData:=true;
              saSectionTop:='All selected records locked for multi-edit. Make sure your browser allows pop-ups from this site. '+
                'If you just got a pop-up blocked message, and you don''t see the edit screen, you will need to remove all your '+
                'record locks. <a href=".?ACTION=DeleteRecordLocks&JSID=[@JSID@]">REMOVE YOUR RECORD LOCKS</a> if necessary.';
              saContent+='<script language="javascript">NewWindow("[@ALIAS@].?MULTIEDIT='+sMEKey+'&JSID='+inttostr(u8JSessionID)+
                '&[@DETAILSCREENID@]");</script>';
            end;
          end
          else
          begin
            if Context.SessionXDL.MoveFirst then
            begin
              repeat
                if Context.SessionXDL.Item_saName='MEDIT'+sMEKey then
                begin
                  bJAS_UnlockRecord(Context,DBC.ID, rJTable.JTabl_Name, u8Val(Context.SessionXDL.Item_saValue), 0,201501020033);
                end;
              until not Context.SessionXDL.MoveNext;
            end;
          end;
        end else
        // MULTI EDIT ---------------------------------------------------------


        // MERGE --------------------------------------------------------------
        //if context.bInternalJob then
        //ASPRintln('bGridQuery - R');

        if bMultiMode and (uMode=cnJBlokMode_MERGE) then
        begin

          //if context.bInternalJob then
          //ASPRintln('bGridQuery - S');

          if Context.CGIENV.DataIn.MoveFirst then
          begin
            sMergeRecord1:='';sMergeRecord2:='';uMergeRecords:=0;

            //if context.bInternalJob then
            //ASPRintln('bGridQuery - T');

            repeat
              sRecordID:=Context.CGIENV.DataIn.Item_saName;
              if saLeftStr(sRecordID,2)='MS' then
              begin
                uMergeRecords+=1;
                if sMergeRecord1='' then
                begin
                  sMergeRecord1:=RightStr(sRecordID, length(sRecordID)-2);
                end
                else
                begin
                  sMergeRecord2:=RightStr(sRecordID, length(sRecordID)-2);
//qqq
                end;
              end;
            until (not Context.CGIENV.DataIn.MoveNext);
            if context.bInternalJob then JASPRintln('bGridQuery - U');
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
              saContent+='<script language="javascript">NewWindow("[@ALIAS@].?Action=MERGE&JTable='+inttostr(rJTable.JTabl_JTable_UID)+
                '&R1='+sMergeRecord1+'&R2='+sMergeRecord2+'&JSID='+IntToStr(u8JSessionID)+'");</script>';
            end;
          end;
        end;
        // MERGE --------------------------------------------------------------

        //if context.bInternalJob then
        //ASPRintln('bGridQuery - V');

      end
      else
      begin
        //if context.bInternalJob then
        //ASPRintln('bGridQuery - W');

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
      Context.PAGESNRXDL.AppendItem_SNRPair('[@RTOTALRECORDS@]',inttostr(JScreen.u8RecordCount));
      if context.bInternalJob then JASPRintln('bGridQuery - X');
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

  //if context.bInternalJob then
  //ASPRintln('bGridQuery - END');

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
  sRecordIDWrap: string[64];//long cuz its used with text getting prepended etc
  u8RecordID: uint64;//used to convert to number less in here
  u4Found: Cardinal;
  u4Removed: Cardinal;
  s: string;
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
      sRecordIDWrap:=Context.CGIENV.DataIn.Item_saName;
      if LeftStr(sRecordIDWrap,2)='MS' then
      begin
        u4Found+=1;
        sRecordIDWrap:=RightStr(sRecordIDWrap, length(sRecordIDWrap)-2);
        u8RecordID:=u8Val(sRecordIDWrap);
        if bJAS_HasPermission(Context,rJTable.JTabl_Delete_JSecPerm_ID) and
           bJAS_LockRecord(Context,TGT.ID, rJTable.JTabl_Name, u8RecordID, 0,201501020034) then
        begin
          bOk:=bRecord_SecurityCheck(u8RecordID,cnRecord_Delete,201608101651);
          //ASPrintln(saRepeatChar('=',79));
          //ASPrintln('back from bRecord_SecurityCheck('+saRecordID+','+inttostr(cnRecord_Delete)+' bOk:'+sYesNo(bOk));
          //ASPrintln(saRepeatChar('=',79));

          if not bOk then
          begin
            JAS_Log(Context,cnLog_Error,201203241110,'You are not permitted to delete one or more of these selected record(s).',
              'Table: '+rJTable.JTabl_Name+' UID: '+srecordIDWrap,SOURCEFILE);
          end;

          if bOk then
          begin
            bOk:=bPreDelete(rJTable.JTabl_Name,u8RecordID);
            if not bOk then
            begin
              JAS_LOG(Context, cnLog_Warn, 201205300847,'bPreDelete called from Multi-Delete in Grid Failed: Table: '+rJTable.JTabl_Name+' UID: '+sRecordIDWrap,'',SOURCEFILE);
            end;
          end;

          if bOk then
          begin
            s:=' b4 delete call table name >'+rJTable.JTabl_Name+'<';
            bOk:=bJAS_DeleteRecord(Context,TGT, rJTable.JTabl_Name,u8RecordID);
            if not bOk then
            begin
              if Context.u8ErrNo<>201203262012 then
              begin
                JAS_Log(Context,cnLog_Error,201203221908,'Trouble deleting record. s:'+s,'rJTable.JTabl_Name:'+rJTable.JTabl_Name+' Record ID:'+inttostr(u8RecordID),SOURCEFILE);
              end;
            end;
          end;
          //rs.Close;
          bJAS_UnlockRecord(Context,TGT.ID, rJTable.JTabl_Name, u8RecordID, 0,201501020035);
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



// .[127.0.0.1] 2016-11-03 18:36:07 200 execute/jegas www.jegas.com index.jas ?
// SCREENID=313&
// JSID=1611031349397920041&
// BUTTON=SAVE&
// UID=0&
// MULTIEDIT=318094375&
// MEDIT318094375=1611031111346930016&
// MEDIT318094375=1611031814072500204&
// MECHK_6185=TRUE&DBLOK6185=test&
// MECHK_1611031835233260104=FALSE&
// DBLOK1611031835233260104=



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
  u8JButtonTypeID: int64;
  bDone: boolean;
  sButton: String;
  saME: ansistring;// Multi Edit Items getting stuffed into FORM
  u8JScreenID: uint64;
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
  u8JScreenID:=JScreen.rJScreen.JScrn_JScreen_UID;
  
  Context.PAGESNRXDL.AppendItem_SNRPair('[@DETAIL_HELP_ID@]',inttostr(rJBlok.JBlok_Help_ID));
  


  // First, Figure out what the user is trying to do from the BUTTON TYPE, and the PASSED UID
  //-------------------------------
  If rAudit.u8UID=0 Then
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

      //========== original ================
      //if sButton='CANCEL' Then uMode:=cnJBlokMode_Cancel else
      //if sButton='CANCELNCLOSE' Then uMode:=cnJBlokMode_CancelNClose else
      //if sButton='SAVE' Then uMode:=cnJBlokMode_Save else
      //if sButton='SAVENCLOSE' Then uMode:=cnJBlokMode_SaveNClose else
      //if sButton='SAVENNEW' then uMode:=cnJBlokMode_SaveNNew else
      //if uMode=cnJBlokMode_New then
      //begin
      //  if sButton='DELETE' Then uMode:=cnJBlokMode_Deleted;
      //  if sButton='EDIT' Then uMode:=cnJBlokMode_Edit;
      //end else
      //if sButton='DELETE' Then uMode:=cnJBlokMode_Delete else
      //if sButton='EDIT' Then uMode:=cnJBlokMode_Edit;
      //========== original ================

      //========== new =====================
      if sButton='VIEW' then umode:=cnJBlokMode_View  else
      if sButton='NEW' then umode:=cnJBlokMode_New  else
      if sButton='DELETE' then umode:=cnJBlokMode_Delete  else
      if sButton='SAVE' then umode:=cnJBlokMode_Save  else
      if sButton='EDIT' then umode:=cnJBlokMode_Edit  else
      if sButton='DELETED' then umode:=cnJBlokMode_Deleted  else
      if sButton='CANCEL' then umode:=cnJBlokMode_Cancel  else
      if sButton='SAVENCLOSE' then umode:=cnJBlokMode_SaveNClose else
      if sButton='CANCELNCLOSE' then umode:=cnJBlokMode_CancelNClose else
      if sButton='MERGE' then umode:=cnJBlokMode_Merge else
      if sButton='SAVENNEW' then umode:=cnJBlokMode_SaveNNew;
      //========== new =====================
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
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    bMultiMode:=Context.CGIENV.DataIn.FoundItem_saName('MULTIEDIT');
    //riteln('Execute data blk bMultiMode: ' + sYesNo(bMultiMode));
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    //riteln(saRepeatChar('=',70));
    // Note: saFooter - is OUR Spot For [@MULTIEDITHEADER@] text etc.
    // Note: Don't Mess with uMode for Detail screens in Multi-Edit mode - we are piggy backing working
    // functionality for normal detail screens.
    if bMultiMode then
    begin
      Context.PageSNRXDL.AppendItem_SNRPair('[@MULTIEDIT@]','<input type=hidden name="MULTIEDIT" value="'+Context.CGIENV.DataIn.Item_saValue+'" />');
      saSectionBottom:='MEDIT'+Context.CGIENV.DataIn.Item_saValue;

      //riteln('TJBLOK.bExecuteDataBlok saSectionBottom: ' + saSectionBottom);
      //ritelN('Context.CGIENV.DataIn.Item_saName: '+Context.CGIENV.DataIn.Item_saName);
      //ritelN('Context.CGIENV.DataIn.Item_saValue: '+Context.CGIENV.DataIn.Item_saValue);

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
      bOk:=Context.bSessionValid and ((rJTable.JTabl_Add_JSecPerm_ID=0) or (bJAS_HasPermission(Context,rJTable.JTabl_Add_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200219,'You are not authorized to ADD records in this screen.'+
          'Screen ID:'+inttostr(u8JScreenID)+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMOde_Edit) then
    begin
      bOk:=Context.bSessionValid and ((rJTable.JTabl_Update_JSecPerm_ID=0) or (bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200220,'You are not authorized to EDIT records in this screen. '+
          'Screen ID:'+inttostr(u8JScreenID)+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMode_Delete) then
    begin
      bOk:=Context.bSessionValid and ((rJTable.JTabl_Delete_JSecPerm_ID=0) or (bJAS_HasPermission(Context,rJTable.JTabl_Delete_JSecPerm_ID)));
      if not bOk then
      begin
        JAS_Log(Context,cnLog_Error,201203200221,'You are not authorized to DELETE records in this screen. '+
          'Screen ID:'+inttostr(u8JScreenID)+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
      end;
    end;

    if bOk and (uMode = cnJBlokMode_Edit) and (not bJAS_RecordLockValid(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201605201006)) then
    begin
      bOk:=bJAS_LockRecord(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020036);
      //ASPRintln('Locked after attempt?' + sYesNo(bJAS_RecordLockValid(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.u8UID,'0',201501020050)));
      If not bOk Then
      Begin
        JAS_Log(Context,cnLog_Error,200701071725,'This RECORD is already locked by some one. Mode: '+sMode+' '+
          '<a href="javascript: window.history.back()">Go Back To View Mode.</a> <br /><br />Diagnostic '+
          'Info: Table:'+rJTable.JTabl_Name+' UID:'+inttostr(rAudit.u8UID)+' JSess_JSession_UID:'+inttostr(Context.rJSession.JSess_JSession_UID)+
          ' Session Valid:'+sYesNo(Context.bSessionValid),'',SOURCEFILE);
      End;
    end;

    if bOk and ((uMode = cnJBlokMode_Save) or (uMode = cnJBlokMode_SaveNClose) or (uMode=cnJBlokMode_SaveNNew))and (rAudit.u8UID>0)then
    begin
      bOk:=bJAS_RecordLockValid(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020050);
      if not bOk then
      begin
        //bOk:=bJAS_LockRecord(Context, TGT.ID,rJBlok.JBlok_JTable_ID, rAudit.u8UID,'0',201501020037);
        //if not bOk then
        //begin
          JAS_Log(Context,cnLog_Error,201002022345,'This RECORD LOCK could not be verified. Mode: '+sMode+' '+
             '<a href="javascript: window.history.back()">Go Back To View Mode.</a> <br /><br />Diagnostic '+
            'Info: Table:'+rJTable.JTabl_Name+' UID:'+inttostr(rAudit.u8UID)+' JSess_JSession_UID:'+inttostr(Context.rJSession.JSess_JSession_UID)+
            ' Session Valid:'+sYesNo(Context.bSessionValid),'',SOURCEFILE);
        //end;
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
              bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, u8Val(Context.SessionXDL.Item_saValue),0,201501020037);
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
          rAudit.u8UID:=0;
          //AS_Log(Context,cnLog_ebug,201203040537,' ABOUT to call DetailCancel after Save uMode:'+ IntToStr(uMode),'',SOURCEFILE);
          if (uMode<>cnJBlokMode_SaveNNew) then
          begin
            DataBlok_DetailCancel;
          end
          else
          begin
            bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020038);
            JScreen.bPageCompleted:=false;
            uMode:=cnJBlokMode_New;
            rAudit.u8UID:=0;
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
          u8JButtonTypeID:=TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_JButtonType_ID;
          sa:='';
          if (u8JButtonTypeID=cnJBlokButtonType_Save) or
             (u8JButtonTypeID=cnJBlokButtonType_SaveNClose) or
             (u8JButtonTypeID=cnJBlokButtonType_SaveNNew) then
          begin
            if bPreventSaveButton then
            begin
              sa:='<li><a href="javascript: alert(''Please resolve JWidget Errors. We are preventing you from saving for fear of corrupting your data.'');">'+
                '<img class="image" src="'+TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_GraphicFileName+'" />'+
                '<span class="jasbutspan">'+saCaption+'</span></a></li>'+csCRLF;
            end;
          end;

          Case u8JButtonTypeID Of
          cnJBlokButtonType_Save: begin
            if (uMode=cnJBlokMode_New) and
               ((rJTable.JTabl_Add_JSecPerm_ID=0) or
               (bJAS_HasPermission(Context,rJTable.JTabl_Add_JSecPerm_ID))) then
            begin
              if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
            end
            else
            begin
              if (uMode=cnJBlokMode_Edit) and
               ((rJTable.JTabl_Update_JSecPerm_ID=0) or
               (bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID))) then
              begin
                if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
              end;
            end;
          end;
          cnJBlokButtonType_SaveNClose,cnJBlokButtonType_SaveNNew: begin
            if ((uMode=cnJBlokMode_Edit) or (uMode=cnJBlokMode_New))and (not bMultiMode) and
             ((rJTable.JTabl_Update_JSecPerm_ID=0) or
             (bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID))) then
            begin
              if bPreventSaveButton then saButtons+=sa else saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;
            end;
          end;
          cnJBlokButtonType_Delete: If (uMode=cnJBlokMode_View) and ((rJTable.JTabl_Delete_JSecPerm_ID=0) or
                              (bJAS_HasPermission(Context,rJTable.JTabl_Delete_JSecPerm_ID))) then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Cancel: If (uMode=cnJBlokMode_New) OR (uMode=cnJBlokMode_Edit) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_CancelNClose: If ((uMode=cnJBlokMode_Edit)or(uMode=cnJBlokMode_New)) and (not bMultiMode) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

          cnJBlokButtonType_Edit: If ((uMode=cnJBlokMode_View)or(uMode=cnJBlokMode_Save)) and ((rJTable.JTabl_Update_JSecPerm_ID=0) or
                         (bJAS_HasPermission(Context,rJTable.JTabl_Update_JSecPerm_ID))) Then saButtons+=TJBLOKBUTTON(BXDL.Item_lpPtr).saRender;

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
      Context.PAGESNRXDL.AppendItem_SNRPair('[@UID@]',inttostr(rAudit.u8UID));
      Context.PAGESNRXDL.AppendItem_SNRPair('[@MULTIEDITHEADER@]',saFooter);
      //JAS_Log(Context,cnLog_EBUG,201003040537,'uid SENT:'+rAudit.u8UID,'',SOURCEFILE);
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

  bOk:=(rJTable.JTabl_Delete_JSecPerm_ID=0) or (bJAS_HasPermission(Context,rJTable.JTabl_Delete_JSecPerm_ID));
  //if bok then JAS_Log(Context,cnLog_Debug,201503121512,'bRecord_DetailDeleteRecord - req Delete Perm ID: '+rJTable.JTabl_Delete_JSecPerm_ID,'',SOURCEFILE);
  if not bOk then
  begin
    JAS_Log(Context,cnLog_Error,201203070814,'You are not authorized to delete records in this screen. '+
      'Screen ID:'+inttostr(JScreen.rJScreen.JScrn_JScreen_UID)+' Name: '+JScreen.rJScreen.JScrn_Name,'',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_LockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020039);
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200701071246,'Unable to Lock Record at this time. Table: ' + rJTable.JTabl_Name +
        ' Record UID: ' + inttostr(rAudit.u8UID),'',SOURCEFILE);
    End;
  end;

  if bOk then
  begin
    bOk:=bRecord_SecurityCheck(rAudit.u8UID,cnRecord_Delete,201608101652);
    //if bok then JAS_Log(Context,cnLog_Debug,201503121513,'bRecord_SecurityCheck rAudit.u8UID: '+rAudit.u8UID,'',SOURCEFILE);
    //JAS_Log(Context,cnLog_Debug,201503121448,'Deleting if bRecord_SecurityScheck('+rAudit.u8UID,'',SOURCEFILE);
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201003241044,'You are not authorized to delete this record.','Table: ' + rJTable.JTabl_Name+' UID: '+inttostr(rAudit.u8UID), SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bPreDelete(rJTable.JTabl_Name,rAudit.u8UID);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201205300848,'bPreDelete called from Detail Screen Failed. Table: '+
        rJTable.JTabl_Name+' UID: '+ inttostr(rAudit.u8UID),'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_DeleteRecord(Context,TGT, rJTable.JTabl_Name,rAudit.u8UID);
    if not bOk then
    begin
      if Context.u8ErrNo<>201203262012 then
      begin
        JAS_Log(Context,cnLog_Error,200701071250,'Unable to delete record from table: ' + rJTable.JTabl_Name +
            ' UID Column: '+rJColumn_Primary.JColu_Name +' Record UID: ' + inttostr(rAudit.u8UID),'',SOURCEFILE);
      end;
    End;
  end;
  bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020040);
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
    Context.CGIENV.Header_Redirect(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL,garJVHost[Context.u2VHost].VHost_ServerIdent);
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
          bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, u8Val(Context.CGIENV.DataIn.Item_saValue),0,201501020041);
        end;
      until not Context.CGIENV.DataIn.MoveNext;
      Context.saPage:=saGetPage(Context, 'sys_area',JScreen.rJScreen.JScrn_Template,'ADDNEWCANCEL',False,123020100017);
      JScreen.bPageCompleted:=True;
    end;
  end else

  If (rAudit.u8UID=0) or (uMode=cnJBlokMode_CancelNClose) or (uMode=cnJBlokMode_SaveNClose) Then // CANCEL ADDNEW
  Begin
    if (uMode=cnJBlokMode_CancelNClose) then
    begin
      bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020042);
      i4FindMe:=cnJBlokButtonType_CancelNClose;
    end else

    // NOT NEEDED HERE - happens in the SAVE Portion and seems to have ZERO in rAudit.u8UID
    // HERE in this mode.
    //if (uMode=cnJBlokMode_SaveNClose) then
    //begin
    //  ASPrintln('JASON - 0015 - UNLOCK');
    //  bJAS_UnLockRecord(Context, JScreen.DBC.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,'0',201501020043);
    //  i4FindMe:=cnJBlokButtonType_CancelNClose;
    //end else

    begin
      i4FindMe:=cnJBlokButtonType_Cancel;
    end;
    if BXDL.FoundBinary(@i4FindMe, SizeOf(i4FindMe), @TJBLOKBUTTON(nil).rJBlokButton.JBlkB_JButtonType_ID, true, true)  AND
      (length(trim(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL))>0)
    Then
    Begin
      Context.CGIENV.Header_Redirect(TJBLOKBUTTON(BXDL.Item_lpPtr).rJBlokButton.JBlkB_CustomURL,garJVHost[Context.u2VHost].VHost_ServerIdent);
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
    bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020044);
    uMode:=cnJBlokMode_View;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOut(201203102561,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================










//==============================================================================
function TJBLOK.bRecord_PreUpdate(p_QXDL: JFC_XDL; p_UID: uInt64): boolean;
//==============================================================================
var
  bOk: Boolean;
  JScreen: TJSCREEN;
  Context:TCONTEXT;
  JBlokField: TJBLOKFIELD;
  s: string;
  u1: byte;
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
  if bOk then
  begin
    //rs:=jado_recordset.create;
    //ASPRintLn('TJBLOK.bRecord_PreUpdate - JScreen.rJScreen.JScrn_JScreen_UID: '+JScreen.rJScreen.JScrn_JScreen_UID);
    case JScreen.rJScreen.JScrn_JScreen_UID of

    //debug aid
    //if FXDL.MoveFirst then
    //begin
    //  repeat
    //    riteln(FXDL.Item_saName,' <=> ',FXDL.Item_saValue);
    //  until not FXDL.MoveNext;
    //end;


    //---------------------------------------------------------------------------
    // jmail PRE SAVE
    //---------------------------------------------------------------------------
    353: begin //cs_jmail_search: begin
      bOk:=false;
      JAS_LOG(Context, cnLog_Error,201607201503,'Modifiying JMail records from this screen is not permitted. It can easily break the JMail system.',
        'If this becomes an issue, change the JAS code to allow this for admin or have some permission made to allow it by authorized folks and use that.'+
        ' See uj_sessions.pp - bJAS_HasPermission function. That''s how you check.',SOURCEFILE);
    end;
    354: begin //cs_jmail_Data: begin // JMail Detail Screen
      if not p_QXDL.FoundItem_saName('JMail_From_User_ID') then
      begin
        p_QXDL.Appenditem_saName_N_saValue('JMail_From_User_ID',inttostr(Context.rJSession.JSess_JUser_ID));
        p_QXDL.Item_lpPtr:=TJBLOKFIELD.Create(self,1234);
        JBlokField:=TJBLOKFIELD(JFC_XDLITEM(p_QXDL.lpItem).lpPtr);
        JBlokField.rJColumn.JColu_Name:='JMail_From_User_ID';
        JBlokField.rJColumn.JColu_JDType_ID:=cnJDType_u8;
        JBlokField.saValue:=inttostr(Context.rJSession.JSess_JUser_ID);
      end
      else
      begin
        p_QXDL.Item_saValue:=inttostr(Context.rJSession.JSess_JUser_ID);
        JBlokField:=TJBLOKFIELD(JFC_XDLITEM(p_QXDL.lpItem).lpPtr);
        JBlokField.saValue:=inttostr(Context.rJSession.JSess_JUser_ID);
      end;

    end;//case




    //---------------------------------------------------------------------------
    // juser PRE SAVE
    //---------------------------------------------------------------------------
    //cs_juser_Data,cs_juser_Search: begin
      //if p_QXDL.FoundItem_saName('JUser_SIP_PASS') then
      //begin
      //  s:=p_QXDL.Item_saValue;
      //  if (s<>'') and (leftstr(s,7)<>'[JEGAS]') then
      //  begin
      //    for u1:=1 to length(s) do s[u1]:=char(byte(s[u1]) xor garJVHost[Context.u2VHOST].VHost_PasswordKey_u1);
      //    s:='[JEGAS]'+s;
      //  end;
      //  p_QXDL.Item_saValue:=Context.VHDBC.saDBMSScrub(s);
      //end;
    //end;//case
    //---------------------------------------------------------------------------




    // cheap encryption - not finished yet
    ////=============================================================================
    ////cs_JUserPrefLink:                        //2012100615163514292 smtp pass
    ////                                         //2012100615162043726 	smtp host
    ////                                         //2012100615164495133 smtp user name
    //121,122:begin  //screen ids: search and detail screens of userpreflink respectively
    ////=============================================================================
    //  //asprintln('userpref - going in');
    //  if Context.cgienv.datain.founditem_saValue('2012100615163514292') or
    //     Context.cgienv.datain.founditem_saValue('2012100615162043726') or
    //     Context.cgienv.datain.founditem_savalue('2012100615164495133') then
    //  begin
    //    if p_QXDL.founditem_saName('UsrPL_Value')and
    //       (length(p_QXDL.Item_saValue)>0) then
    //    begin
    //  //asprintln('userpref -  2');
    //      if LeftStr(p_QXDL.Item_saValue,7)<>'[JEGAS]' then
    //      begin
    //  //asprintln('userpref -  3');
    //
    //        //MySQL Data is quoted here so...
    //        //ASPrintln('BEFORE p_QXDL.Item_saValue:'+p_QXDL.Item_saValue);
    //        p_QXDL.Item_saValue:=trim(p_QXDL.Item_saValue);
    //        if leftStr(p_QXDL.Item_saValue,1)='''' then p_QXDL.Item_saValue:=rightstr(p_QXDL.Item_saValue,length(p_QXDL.Item_saValue)-1);
    //        if rightStr(p_QXDL.Item_saValue,1)='''' then p_QXDL.Item_saValue:=leftstr(p_QXDL.Item_saValue,length(p_QXDL.Item_saValue)-1);
    //        //ASPrintln('AFTER p_QXDL.Item_saValue:'+p_QXDL.Item_saValue);
    //
    //        p_QXDL.Item_saValue:=Context.VHDBC.saDBMSScrub('[JEGAS]'+saScramble(p_QXDL.Item_saValue));
    //  //asprintln('userpref -  4');
    //      end;
    //    end
    //    else
    //    begin
    //      JAS_LOG(Context, cnLog_Error,201607261448,'UsrPL_Value field not in fxdl.','',SOURCEFILE);
    //    end;
    //  end;
    //  //=============================================================================
    //end;//case

    end;//switch
    ////rs.destroy;
  end;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(201209131348,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================












//==============================================================================
function TJBLOK.bRecord_PostUpdate(p_UID: uInt64): boolean;
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
  //saPubKey: ansistring;
  i8: Int64;// this one does negative integer math

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
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  case JScreen.rJScreen.JScrn_JScreen_UID of
  //---------------------------------------------------------------------------
  // JTASK POST SAVE
  //---------------------------------------------------------------------------
  //cs_jtask_SEarch: simply is not going to generate emails from a multi-edit -
  // one per row - nope. This isn't meant to spam out users. So
  // purposefully skipped search screen multi-edit post_edits
  cs_jtask_Data: begin // JTask Detail Screen
    if Context.CGIENV.DataIn.FoundItem_saName('DBLOK1751') then // "assigned to" field jtask.JTask_JUser_ID
    begin
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================
      //==================================================== JTASK MULTI ASSIGNMENT LOOP TASKS =========================================
      // this allows assigning one task to multiple people and each get their own "copy" so their reminders are separate, timeclock, etc.
      clear_jtask(rJTask);
      rJTask.JTask_JTask_UID:=p_UID;
      //ASPrintLn('rJTask.JTask_JTask_UID: >'+rJTask.JTask_JTask_UID+'<\');
      bOk:=true;
      //if not bOk then
      //begin
      //  JAS_Log(Context,cnLog_Error,201110121313,'Trouble loading record via bJAS_Load_JTask p_saUID: '+inttostr(rAudit.u8UID),'',SOURCEFILE);
      //end;
      //ASPrintLn('Context.CGIENV.DataIn.Item_saValue: >'+Context.CGIENV.DataIn.Item_saValue+'<\');
      //ASPrintLn('rJTask.JTask_Owner_JUser_ID: >'+rJTask.JTask_Owner_JUser_ID+'<\');
      if bJAS_Load_JTask(Context, DBC, rJTask, false,201603310314) then
      begin
        bCreator:=Context.CGIENV.DataIn.Item_saValue=inttostr(rJTask.JTask_Owner_JUser_ID);
        if not bCreator then
        begin
          rJTask.JTask_Owner_JUser_ID:=u8Val(Context.CGIENV.DataIn.Item_saValue);
          rJTask.JTask_JTask_UID:=0;//force new record
          bOk:=bJAS_Save_Jtask(context,dbc,rJTask,false,false,201603310315);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,201507010324,'Trouble saving task with multiple owners rJTask.JTask_JTask_UID: '+inttostr(rJTask.JTask_JTask_UID),'',SOURCEFILE);
          end;
        end;
        //ASPrintln('Creator: '+sYesNo(bCreator));
        //ASPrintLn('rJTask.JTask_JTask_UID: >'+rJTask.JTask_JTask_UID+'<\');
        //ASPRintln('rJTask.JTask_Owner_JUser_ID:'+rJTask.JTask_Owner_JUser_ID);
      end;

      // Wipe out jobq with this task id - should work after multi-user assign cuz the task uid
      // field is updated on a save (on save new the new one is returned, not the zero)
      if bOk then
      begin
        saQry:='select '+DBC.sDBMSEncloseObjectName('JJobQ_JJobQ_UID')+' '+
          ' from '+DBC.sDBMSEncloseObjectName('jjobq')+' where '+DBC.sDBMSEncloseObjectName('JJobQ_JTask_ID')+'='+DBC.sDBMSUIntScrub(rJTask.JTask_JTask_UID)+
          ' AND '+DBC.sDBMSEncloseObjectName('JJobQ_Completed_b')+'<>'+DBC.sDBMSBoolScrub(true)+
          ' AND '+DBC.sDBMSEncloseObjectName('JJobQ_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true);
        bOk:=rs.open(saQry, DBC,201503161519);
        if not bOk then
        begin
          JAS_LOG(Context, cnLog_Error, 201203261217,'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
        end;
        if bOk and (not rs.eol) then
        begin
          repeat
            bOk:=bJAS_DeleteRecord(Context,DBC, 'jjobq',u8Val(rs.fields.Get_saValue('JJobQ_JJobQ_UID')));
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201110121317,'Trouble deleting from jjobq table. JJobQ_JJobQ_UID: '+rs.fields.Get_saValue('JJobQ_JJobQ_UID'),'',SOURCEFILE);
            end;
          until (not bOk) or (not rs.movenext);
        end;
        rs.close;
        // Make sure message should be sent but wasnt sent already AND that the TASK isn't completed.
        if bOk and rJTask.JTask_SendReminder_b and (not rJTask.JTask_ReminderSent_b) and (rJTask.JTask_JStatus_ID<>3) then
        begin
          try
            dt:=StrToDateTime(JDATE(rJTask.JTask_Start_DT,1,11));
          except on E : EConvertError do begin
            dt:=now;
            rJTask.JTask_Start_DT:=JDATE('',11,0,dt);
            saQry:='update jtask set JTask_Start_DT='+DBC.sDBMSDateScrub(rJTask.JTask_Start_DT)+' where JTask_JTask_UID='+DBC.sDBMSUIntScrub(rJTask.JTask_JTask_UID);
            bOk:=rs.open(saQry,DBC,201506132229);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201506132230,'Unable to save start date in jtask record. UID: '+inttostr(rJTask.JTask_JTask_UID),'',SOURCEFILE);
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
          i8:=rJTask.JTask_Remind_DaysAhead_u;
          dt:=dtAddDays(dt,-1*i8);
          i8:=rJTask.JTask_Remind_HoursAhead_u;
          dt:=dtAddHours(dt,-1*i8);
          i8:=rJTask.JTask_Remind_MinutesAhead_u;
          dt:=dtAddMinutes(dt,-1*i8);
          clear_JJobQ(rJJobQ);
          with rJJobQ do begin
            //JJobQ_JJobQ_UID           :=
            JJobQ_JUser_ID            :=rJTask.JTask_Owner_JUser_ID;
            JJobQ_JJobType_ID         :=1;//General
            JJobQ_Start_DT            :=FormatDateTime(csDATETIMEFORMAT,DT);
            JJobQ_ErrorNo_u           :=0;
            JJobQ_Started_DT          :='NULL';
            JJobQ_Running_b           :=false;
            JJobQ_Finished_DT         :='NULL';
            JJobQ_Name                :=rJTask.JTask_Name;
            JJobQ_Repeat_b            :=rJTask.JTask_Remind_Persistantly_b;
            JJobQ_RepeatMinute        :='10/*';
            JJobQ_RepeatHour          :='*';
            JJobQ_RepeatDayOfMonth    :='*';
            JJobQ_RepeatMonth         :='*';
            JJobQ_Completed_b         :=false;
            JJobQ_Result_URL          :='';
            JJobQ_ErrorMsg            :='';
            JJobQ_ErrorMoreInfo       :='';
            JJobQ_Enabled_b           :=true;
            JJobQ_Job                 :=
              '<CONTEXT>'+
              '  <saRequestMethod>GET</saRequestMethod>'+
              '  <saQueryString>jasapi=email&type=taskreminder&UID='+
              inttostr(rJTask.JTask_JTask_UID)+'</saQueryString>'+
              '  <saRequestedFile>'+Context.sAlias+'</saRequestedFile>'+
              '</CONTEXT>';
            JJobQ_Result              :='NULL';
            //JJobQ_CreatedBy_JUser_ID  :=
            //JJobQ_Created_DT          :=
            //JJobQ_ModifiedBy_JUser_ID :=
            //JJobQ_Modified_DT         :=
            //JJobQ_DeletedBy_JUser_ID  :=
            //JJobQ_Deleted_DT          :=
            //JJobQ_Deleted_b           :=
            JAS_Row_b                 :=false;
            JJobQ_JTask_ID            :=rJTask.JTask_JTask_UID;
          end;//with
          if bOk then
          begin
            bOk:=bJAS_Save_JJobQ(Context, DBC, rJJobQ, false,false,201603310316);
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
  end;//case
  //---------------------------------------------------------------------------
  // JTASK POST SAVE
  //---------------------------------------------------------------------------

  //cs_juserpref_Data,cs_juserpref_Search: begin
    // add smtp password thing here
  //end;



  //---------------------------------------------------------------------------
  // JUSER POST SAVE
  //---------------------------------------------------------------------------
  cs_juser_Data,cs_juser_Search: begin
    //if DBC.u8GetRecordCount(
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
  end;//case
  //---------------------------------------------------------------------------
  // JUSER POST SAVE
  //---------------------------------------------------------------------------

  
  
  //
  //    //with rJMail do begin
  //    //  asprintln('-begin-');
  //    //  asprintln('JMail_JMail_UID:'+JMail_JMail_UID);
  //    //  asprintln('JMail_Message:'+JMail_Message                );
  //    //  asprintln('JMail_To_User_ID:'+JMail_To_User_ID              );
  //    //  asprintln('JMail_From_User_ID:'+JMail_From_User_ID            );
  //    //  asprintln('JMail_Message_Code:'+JMail_Message_Code            );
  //    //  asprintln('JMail_CreatedBy_JUser_ID:'+JMail_CreatedBy_JUser_ID      );
  //    //  asprintln('JMail_Created_DT:'+JMail_Created_DT              );
  //    //  asprintln('JMail_ModifiedBy_JUser_ID:'+JMail_ModifiedBy_JUser_ID     );
  //    //  asprintln('JMail_Modified_DT:'+JMail_Modified_DT             );
  //    //  asprintln('JMail_DeletedBy_JUser_ID:'+JMail_DeletedBy_JUser_ID      );
  //    //  asprintln('JMail_Deleted_DT:'+JMail_DeletedBy_JUser_ID              );
  //    //  asprintln('JMail_Deleted_b:'+JMail_DeletedBy_JUser_ID               );
  //    //  asprintln('JAS_Row_b:'+JMail_DeletedBy_JUser_ID                     );
  //    //  asprintln('-end-');
  //    //end;
  //



  //
  //      //with rJMail do begin
  //      //  asprintln('-begin-after updaTE record 1');
  //      //  asprintln('JMail_JMail_UID:'+JMail_JMail_UID);
  //      //  asprintln('JMail_Message:'+JMail_Message                );
  //      //  asprintln('JMail_To_User_ID:'+JMail_To_User_ID              );
  //      //  asprintln('JMail_From_User_ID:'+JMail_From_User_ID            );
  //      //  asprintln('JMail_Message_Code:'+JMail_Message_Code            );
  //      //  asprintln('JMail_CreatedBy_JUser_ID:'+JMail_CreatedBy_JUser_ID      );
  //      //  asprintln('JMail_Created_DT:'+JMail_Created_DT              );
  //      //  asprintln('JMail_ModifiedBy_JUser_ID:'+JMail_ModifiedBy_JUser_ID     );
  //      //  asprintln('JMail_Modified_DT:'+JMail_Modified_DT             );
  //      //  asprintln('JMail_DeletedBy_JUser_ID:'+JMail_DeletedBy_JUser_ID      );
  //      //  asprintln('JMail_Deleted_DT:'+JMail_DeletedBy_JUser_ID              );
  //      //  asprintln('JMail_Deleted_b:'+JMail_DeletedBy_JUser_ID               );
  //      //  asprintln('JAS_Row_b:'+JMail_DeletedBy_JUser_ID                     );
  //      //  asprintln('-end-');
  //      //end;
  //
  //

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


  //---------------------------------------------------------------------------
  // JMAIL 
  //---------------------------------------------------------------------------
  cs_jmail_Search:begin
    bOk:=false;
    JAS_Log(Context,cnLog_Error,201607201522,'Saving JMail from multi-edits is not permitted.','post update - cs_jmail_search',SOURCEFILE);
  end;
  cs_jmail_Data: begin
    clear_JMail(rJMail);
    rJMail.JMail_JMail_UID:=p_UID;
    bOk:=bJAS_Load_jmail(Context, DBC, rJMail,false,201603310317);
    if not bok then
    begin
      JAS_Log(Context,cnLog_Error,201506111316,'post update failed to load jmail UID: '+inttostr(p_UID),'',SOURCEFILE);
    end;

    if bOk then
    begin
      if u8Val(rJMail.JMail_Message_Code)=0 then
      begin
        rJMail.JMail_Message_Code:=sGetUID;
        rJMAil.JMail_From_User_ID:=Context.rJUser.JUser_JUser_UID;
        if bOk then
        begin
          bOk:=bJAS_Save_jmail(Context, DBC, rJMail,true,false,201603310318);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,200106111317,'main new mail rec did not update: '+inttostr(p_UID),'',SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          rJMail.JMail_JMail_UID:=0;
          bOk:=bJAS_Save_jmail(Context, DBC, rJMail,true,false,201603310319);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,200106111318,'second mail rec did not save.','',SOURCEFILE);
          end;
        end;

        if bOk then
        begin
          saQry:='update jmail set JMail_CreatedBy_JUser_ID='+inttostr(rJMail.JMail_To_User_ID)+' where JMail_JMail_UID='+inttostr(rJMail.JMail_JMail_UID);
          bOk:=rs.open(saQry,dbc,201506112019);
          if not bok then
          begin
            JAS_Log(Context,cnLog_Error,201506112020,'unable to assign mail to recipient: '+inttostr(rJMail.JMail_To_User_ID),'',SOURCEFILE);
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
  Context:=JScreen.Context;Context:=Context;
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(201212101656,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(201212101657, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  case JScreen.rJScreen.JScrn_JScreen_UID of
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
  u8JDTypeID: uint64;
  bPrimaryKey: boolean;
  bFoundItem: Boolean;
  saMyFields: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  JBlokField: TJBLOKFIELD;
  QXDL: JFC_XDL;
  bHaveKeyInFXDL: boolean;
  u8NewKeyValue: uint64;
  bOkToAddColumn: boolean;
  bNewRecord: boolean;
  JScreen: TJSCREEN;
  Context:TCONTEXT;
  bVisible: boolean;
  u8BookMark: uint64;
 
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
  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));
  //riteln('BEGIN TJBLOK.bRecord_Query MultiMode: '+sYesNo(bMultiMode));
  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));

  //bHaveSecPermColumnInSelect:=false;

  {
  JAS_LOG(Context, cnLog_debug, 201203211450, csCRLF+
    'JADOC Name:'+DBC.saName+csCRLF+
    'JADOC ID:'+DBC.ID+csCRLF+
    'Table Name:'+rJTable.JTabl_Name+csCRLF+
    'Table Con ID:'+rJTable.JTabl_JDConnection_ID+csCRLF+
    'TJBlok.bRecord_Query Entry'+csCRLF+
    'Mode: ' +saMode+csCRLF+
    'rAudit.u8UID: '+rAudit.u8UID+csCRLF+
    'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
    'rJColumn_Primary.JColu_JAS_Key_b: '+rJColumn_Primary.JColu_JAS_Key_b+csCRLF+
    'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
    'FXDL: '+FXDL.saHTMLTable+csCRLF
    ,'',SOURCEFILE);
  }

  if (not bMultiMode) and ((uMode=cnJBlokMode_Save)or(uMode=cnJBlokMode_SaveNClose)or(uMode=cnJBlokMode_SaveNNew)) then
  begin
    if (rAudit.u8UID=0) then
    begin
      //bNewRecord:=bVal(rJColumn_Primary.JColu_JAS_Key_b) and (rAudit.u8UID='');
      bNewRecord:=rJColumn_Primary.JColu_PrimaryKey_b and (rAudit.u8UID=0);
      if bNewRecord then
      begin
        rAudit.u8UID:=u8GetUID;//(Context,DBC.ID,rJBlok.JBlok_JTable_ID);
        //riteln('NEW RECORD - getting new rAudit.u8UID: ',rAudit.u8UID  );
        bOk:=rAudit.u8UID>0;
        If not bOk Then
        Begin
          JAS_Log(Context,cnLog_Error,201003011349,'Unable to Create a New Unique Identifier (UID) for Table: ' + rJTable.JTabl_Name + ' TableID:'+
            inttostr(rJBlok.JBlok_JTable_ID),'',SOURCEFILE);
        End;
        if bOk then
        begin
          if QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name) then
          begin
            QXDL.Item_saValue:=inttostr(rAudit.u8UID);
            //riteln('--------------------- STUFFED Value in QXDL.Item_saName: '+QXDL.ITem_saName+' QXDL.Item_saValue: '+QXDL.Item_saValue);
          end
          else
          begin
            QXDL.AppendItem_saName_N_saValue(rJColumn_Primary.JColu_Name,inttostr(rAudit.u8UID));
            //riteln('--------------------- STUFFED NEW UID QXDL.Item_saValue: '+QXDL.Item_saValue);
          end;
        end;
      end;
    end;
  end;

  If bOk Then
  Begin
    //riteln('Gonna loop FXDL field list');
    if FXDL.MoveFirst then
    begin
      bHaveKeyInFXDL:=false;
      u8NewKeyValue:=0;
      repeat
        FXDL.Item_saName:=TJBlokField(FXDL.Item_lpPtr).rJColumn.JColu_Name;
        FXDL.Item_saValue:=TJBlokField(FXDL.Item_lpPtr).saValue;
        //iteln('--- Name: '+FXDL.Item_saName+' Value: '+FXDL.Item_saValue);

        JBlokfield:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        bVisible:=JBlokField.rJBlokField.JBlkF_Visible_b;
        bPrimaryKey:=JBlokfield.rJColumn.JColu_Name=rJColumn_Primary.JColu_Name;
        if bPrimaryKey then bHaveKeyInFXDL:=true;


        bFoundItem:=Context.CGIENV.DataIn.FoundItem_saName('DBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID));
        //riteln('FOUND: ',bFoundItem,' JBlkF_JColumn_ID: ',jblokfield.rJBLokfield.JBlkF_JColumn_ID);


        //riteln('JBlokField.rJBlokField.JBlkF_JColumn_ID: ',JBlokField.rJBlokField.JBlkF_JColumn_ID);
        if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
        begin
          //riteln('multi A');
          if bFoundItem then
          begin
            //riteln('multi B');
            if not bNewRecord then
            begin
              //riteln('multi C');
              if bPrimaryKey then u8NewKeyValue:=u8Val(JBlokfield.saValue);
            end;
            JBlokfield.saValue:=JFC_XDLITEM(Context.CGIENV.DataIn.lpItem).saValue;
            //riteln('multi D');
          End
          Else
          Begin
            //riteln('multi E');
            if (bNewRecord or (uMode=cnJBlokMode_New)) and (not bMultiMode) then
            begin
              //riteln('multi F');
              JBlokfield.saValue:=JBlokField.rJColumn.JColu_DefaultValue;
            end;
          end;

          //riteln('multi G');
          bOkToAddColumn:=false;
          case uMode of
          cnJBlokMode_New:  bOkToAddColumn:=(not bPrimaryKey);
          cnJBlokMode_Save, cnJBlokMode_SaveNClose, cnJBlokMode_SaveNNew: begin
            //riteln('multi H');
            if (not JBlokField.rJBlokField.JBlkF_ReadOnly_b) and (not ((bNewRecord) and (bPrimaryKey))) and (bVisible) then
            begin
              //riteln('multi I');
              if not bMultiMode then
              begin
                //riteln('multi J');
                bOkToAddColumn:=true;
              end
              else
              begin
                //riteln('multi K');
                if Context.CGIENV.DataIn.FoundItem_saName('MECHK_'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)) then
                begin
                  //riteln('======');
                  //riteln('MECHK_'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+': '+Context.CGIENV.DataIn.Item_saValue);
                  //riteln('======');
                  bOkToAddColumn:=bVal(Context.CGIENV.DataIn.Item_saValue);
                end
              end;
            end;
          end;
          cnJBlokMode_View: bOkToAddColumn:=true;//bFoundItem;
          cnJBlokMode_Edit: bOkToAddColumn:=true;//bFoundItem;
          end;//switch;

          //riteln('multi L');
          if bOkToAddColumn then
          begin
            QXDL.AppendItem_saName(JBlokField.rJColumn.JColu_Name);
            //riteln('QXDL.Append name:'+JBlokField.rJColumn.JColu_Name);
            u8JDTypeID:=JBlokField.rJColumn.JColu_JDType_ID;

            if bIsJDTypeBoolean(u8JDTypeID) or bIsJDTypeBoolean(JBlokField.rJBlokField.JBlkF_JWidget_ID) then
            begin
              //riteln('multi M');
              QXDL.Item_saValue:=DBC.sDBMSBoolScrub(JBlokfield.saValue);
            End else

            if bIsJDTypeInt(u8JDTypeID) then
            begin
              //riteln('multi N');
              QXDL.Item_saValue:=DBC.sDBMSIntScrub(JBlokfield.saValue)+' ';
            end else

            if bIsJDTypeUInt(u8JDTypeID) then
            begin
              //riteln('multi O');
              QXDL.Item_saValue:=DBC.sDBMSUIntScrub(JBlokfield.saValue)+' ';
            end else

            if bIsJDTypeDec(u8JDTypeID) or bIsJDTypeCurrency(u8JDTypeID) then
            begin
              //riteln('multi P');
              QXDL.Item_saValue:=DBC.sDBMSDecScrub(JBlokfield.saValue);
            End else

            if bIsJDTypeDate(u8JDTypeID) then
            begin
              //JBlokField.saValue:=JDate(JBlokfield.saValue,1,11);///qqq
              //riteln('multi Q');
              QXDL.Item_saValue:=DBC.sDBMSDateScrub(JDate(JBlokfield.saValue,11,1));
              //riteln('SCREENUI - (Date) QXDL.Item_saValue:',QXDL.Item_saValue,' JBlokfield.saValue: ',JBlokfield.saValue);
            End
            else
            begin // treat as text
              //riteln('multi R');
              QXDL.Item_saValue:=DBC.saDBMSScrub(JBlokfield.saValue)+' ';
            End;
          End;
        end;
      Until not FXDL.MoveNext;
    end;
//riteln('multi S');
    {
    JAS_LOG(Context, cnLog_ebug, 201203211450,}//riteln( csCRLF+'-=-TOP-=-');
    //riteln(
    //  'TJBlok.bRecord_Query MIDDLE'+csCRLF+
    //  'bMultiMode: ' +sYesNo(bMultiMode)+csCRLF+
    //  'sMode: ' +sMode+csCRLF+
    //  'rAudit.u8UID: '+inttostr(rAudit.u8UID)+csCRLF+
    //  'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
    //  'rJColumn_Primary.JColu_JAS_Key_b: '+sYesNo(rJColumn_Primary.JColu_JAS_Key_b)+csCRLF+
    //  'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
    //  'QXDL: '+QXDL.saHTMLTable+csCRLF+
    //  'FXDL: '+FXDL.saHTMLTable+csCRLF
    //);
      {,'',SOURCEFILE);
    }

// - THIS is where the saving starts


    if uMode<>cnJBlokMode_New then
    begin
      //riteln('multi T');
      saQry:='';
      saMyFields:='';
      case uMode of
      cnJBlokMode_Save, cnJBlokMode_SaveNClose, cnJBlokMode_SaveNNew: begin
        //riteln('multi U');
        if bNewRecord then //and (uMode=cnJBlokMode_Save) then
        begin
          //riteln('multi V');
          if rAudit.bUse_CreatedBy_JUser_ID then
          begin
            //riteln('multi W');
            if QXDL.FoundItem_saName(rAudit.saFieldName_CreatedBy_JUser_ID) then
            begin
              //riteln('multi X');
              QXDL.DeleteItem;
            end;
            //riteln('multi Y');
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_CreatedBy_JUser_ID, DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID));
          end;
          //riteln('multi Z');
          if rAudit.bUse_Created_DT then
          begin
            //riteln('multi AA');
            if QXDL.FoundItem_saName(rAudit.saFieldName_Created_DT) then
            begin
              QXDL.DeleteItem;
              //riteln('multi AB');
            end;
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Created_DT,DBC.sDBMSDateScrub(now));
          end;
          //riteln('multi AC');
          if rAudit.bUse_Deleted_b then
          begin
            //riteln('multi AD');
            if QXDL.FoundItem_saName(rAudit.saFieldName_Deleted_b) then
            begin
              QXDL.DeleteItem;
              //riteln('multi AE');
            end;
            QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Deleted_b,DBC.sDBMSBoolScrub(false));
          end;
          //riteln('multi AF');
          if rJColumn_Primary.JColu_JAS_Key_b then
          begin
            //riteln('multi AG');
            if (not QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name)) then
            begin
              //riteln('multi AH');
              QXDL.AppendItem_saName_N_saValue(rJColumn_Primary.JColu_Name, inttostr(rAudit.u8UID));
            end;
          end
          else
          begin
            //riteln('multi AI');
            if rJColumn_Primary.JColu_AutoIncrement_b then
            begin
              //riteln('multi AJ');
              if QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name) then
              begin
                //riteln('multi AK');
                QXDL.DeleteItem;
              end;
            end;
          end;

          //if (not QXDL.FoundItem_saName(rJColumn_Primary.JColu_Name)) and (bVal(rJColumn_Primary.JColu_JAS_Key_b)) and
          //   (bVal(rJColumn_Primary.JColu_AutoIncrement_b)) then
          //riteln('multi AL');
          QXDL.MoveFirst;
          //riteln('multi AM');
          repeat
            if saMyFields<>'' then saMyFields+=', ';
            saMyFields+=DBC.sDBMSEncloseObjectName(QXDL.Item_saName);
            if saQry<>'' then saQry+=', ';
            saQry+=QXDL.Item_saValue;
          until not QXDL.MoveNext;
          saQry:='INSERT INTO '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' ( '+saMyFields+' ) VALUES ( '+saQry+' ) ';
          //ASprintln('insert JBLOK record: '+saQry);
          //insert JBLOK record: 
          //
          //INSERT INTO jtask ( `JTask_JTask_UID`, `JTask_Name`,    `JTask_Start_DT`,      `JTask_Due_DT`,`JTask_Completed_DT`, `JTask_Owner_JUser_ID`, `JTask_JStatus_ID`, `JTask_JPriority_ID`, `JTask_JTaskCategory_ID`, `JTask_Desc`, `JTask_ResolutionNotes`, `JTask_JProject_ID`, `JTask_Progress_PCT_d`, `JTask_JCase_ID`, `JTask_URL`, `JTask_Directions_URL`, `JTask_Milestone_b`, `JTask_Duration_Minutes_Est`, `JTask_SendReminder_b`, `JTask_Remind_DaysAhead_u`, `JTask_Remind_HoursAhead_u`, `JTask_Remind_MinutesAhead_u`, `JTask_Remind_Persistantly_b`, `JTask_ReminderSent_b`, `JTask_Related_JTable_ID`, `JTask_Related_Row_ID`, `JTask_CreatedBy_JUser_ID`,    `JTask_Created_DT`, `JTask_Deleted_b` ) VALUES 
          //               ( 01506302043498460000,      'test' , '00-00-00 00:00:00', '00-00-00 00:00:00', '00-00-00 00:00:00',                  null ,                 7 ,                   1 ,                       3 ,          '' ,                     '' ,               null ,                   null,            null ,         '' ,                    '' ,                   0,                           0 ,                      0,                         0 ,                          0 ,                            0 ,                             0,                      0,                     null ,                     0 ,                          1, '2015-06-30 20:43:49',                 0 ) 
        end
        else
        begin
          //riteln('multi BA');
          if not bMultiMode then
          begin
            //riteln('multi BB');
            bOk:=bRecord_SecurityCheck(rAudit.u8UID,cnRecord_Edit,201608101654);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201003241045,'You are not authorized to modify this record.','Table: ' + rJTable.JTabl_Name+' UID: '+inttostr(rAudit.u8UID), SOURCEFILE);
            end;
          end;
          //riteln('multi BC');

          if bOk then
          begin
            //riteln('multi BD');
            bOk:=bRecord_PreUpdate(QXDL, rAudit.u8UID);
            if not bOk then
            begin
              JAS_LOG(Context,cnLog_Warn,201503121913,'PreUpdate Failed. Table:'+rJTable.JTabl_Name+' UID:'+inttostr(rAudit.u8UID),'',SOURCEFILE);
            end;
          end;
          //riteln('multi BE');

          if bOk then
          begin
            //riteln('multi BF');
            if rAudit.bUse_ModifiedBy_JUser_ID then
            begin
              //riteln('multi BG');
              if QXDL.FoundItem_saName(rAudit.saFieldName_ModifiedBy_JUser_ID) then
              begin
                //riteln('multi BH');
                QXDL.DeleteItem;
              end;
              QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_ModifiedBy_JUser_ID, DBC.sDBMSUIntScrub(Context.rJUser.JUser_JUser_UID));
            end;
            //riteln('multi BI');
            if rAudit.bUse_Modified_DT then
            begin
              //riteln('multi BJ');
              if QXDL.FoundItem_saName(rAudit.saFieldName_Modified_DT) then
              begin
                //riteln('multi BK');
                QXDL.DeleteItem;
              end;
              QXDL.AppendItem_saName_N_saValue(rAudit.saFieldName_Modified_DT,DBC.sDBMSDateScrub(now));
            end;
            ///riteln('multi BL');
            saQry:='UPDATE ' +DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' SET ' ;
            if QXDL.MoveFirst then
            begin
              //riteln('multi BM');
              repeat
                //if (not (QXDL.Item_saName=rJColumn_Primary.JColu_Name)) then
                //begin
                  if saMyFields<>'' then saMyFields+=', ';
                  saMyFields+=DBC.sDBMSEncloseObjectName(QXDL.Item_saName)+'='+QXDL.Item_saValue;
                //end;
              until not QXDL.MoveNext;
              saQry+=saMyFields;
              if bMultiMode then saQrySNR:=saQry;
              //Asprint('Update JBlok REcord: '+saQry);
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
              //riteln('multi BO');
              saQry:='NOTHING TO SAVE';
            end;
          end;
        end;
      end;
      cnJBlokMode_View, cnJBlokMode_Edit: begin
        //riteln('multi CA');
        // -- STOCK -->>>  bOk:=bRecord_SecurityCheck(rAudit.u8UID,cnRecord_Edit,201608101656);

        // --test below--
        //bOk:=bRecord_SecurityCheck(u8Val(Context.CGIENV.DataIn.Get_saValue('UID')),cnRecord_Edit,201608232024);

        // test2 - CODENAME: Alien Hybrid... ok I'll work on it
        if rAudit.u8UID=0 then rAudit.u8UID:=u8Val(Context.CGIENV.DataIn.Get_saValue('UID'));
        bOk:=bRecord_SecurityCheck(rAudit.u8UID,cnRecord_Edit,201608101656);
        //----




        //if not bOk then
        //begin
          //JAS_Log(Context,cnLog_Error,201003241053,'You are not authorized to view or edit this record.','Table: ' + rJTable.JTabl_Name+' UID: '+rAudit.u8UID, SOURCEFILE);
        //end;

        if bOk then
        begin
          saQry:='SELECT ';
          // Build Select
          if QXDL.MoveFirst then
          begin
            repeat
              if saMyFields<>'' then saMyFields+=', ';
              saMyFields+= DBC.sDBMSEncloseObjectName(QXDL.Item_saName);
              //saMyFields+= QXDL.Item_saName;
            until not QXDL.MoveNext;
            saQry+=saMyFields+' FROM ' + DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name);
          end
          else
          begin
            saQry+=' 1 as One FROM ' + DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name);
          end;
        end;
      end;
      end;//switch

      if (not bNewRecord) and (bOk)  then
      begin
        if ((rAudit.u8UID>0) and
           (rJColumn_Primary.JColu_Name<>'') and
           (rJColumn_Primary.JColu_Name<>'NULL')) or (bMultiMode) then
        begin
          if not bMultiMode then
          begin
            //riteln('MAKING WHERE CLAUSE - NOT MULTI MODE - rAudit.u8UID: ',rAudit.u8UID);
            saQRY+=' WHERE '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+'='+DBC.sDBMSUintScrub(inttostr(rAudit.u8UID));
          end
          else
          begin
            //riteln('MAKING WHERE CLAUSE - !!MULTI MODE!! - Stuffing SNR Token [@UID@]');
            saQRY+=' WHERE '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+'=[@UID@]';
            //riteln('>>>>>>>> MADE IT: '+saQry);
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
          Context.JTrakBegin(TGT, rJTable.JTabl_Name, 0);
        end
        else
        begin
          Context.JTrakBegin(TGT, rJTable.JTabl_Name, rAudit.u8UID);
        end;

        //JAS_LOG(Context, cnLog_ebug, 201204030144, 'rAudit.u8UID: '+rAudit.u8UID+' DETAIL QUERY: '+saQry,'',SOURCEFILE);
        //riteln('rAudit.u8UID: ',rAudit.u8UID,' DETAIL QUERY: '+saQry);
        bOk:=rs.Open(saQry, TGT,201503161522);
        If not bOk Then
        Begin
          JAS_Log(Context,cnLog_Error,200701082228,'Detail Screen - Dynamic Query Failed.','Query: '+ saQry,SOURCEFILE, TGT,rs);
        End;

        if bOk then
        begin
          if bNewRecord and
             (not rJColumn_Primary.JColu_JAS_Key_b) and
             (rJColumn_Primary.JColu_AutoIncrement_b) then
          begin
            // SPECIAL CASE - Table using DBMS autonumber - not perfect
            // but need to TRY to recoupe our new autonumber so JTrak works and detail screen
            // can show more than a empty record.
            case DBC.u8DBMSID of
            cnDBMS_MySQL: begin
              saQry2:='SELECT '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+' FROM '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name) +
                      ' ORDER BY '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+' DESC LIMIT 1';
            end;
            cnDBMS_MSAccess, cnDBMS_MSSQL: begin
              saQry2:='SELECT TOP 1 '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+
                ' FROM '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name) +
                      ' ORDER BY '+DBC.sDBMSEncloseObjectName('rJColumn_Primary.JColu_Name')+' DESC';
            end
            else
            begin
              // gets whole result set but we can refine as more DBMS type added
              saQry2:='SELECT '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+' FROM '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name) +
                      ' ORDER BY '+DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+' DESC';
            end;
            end;//switch
            bOk:=rs2.open(saQry2, TGT,201503161521);
            if not bOk then
            begin
              JAS_Log(Context,cnLog_Error,201204041734,'Query failed - DBMS managed autonumber retrival query after addnew.','Query: '+saQry2,SOURCEFILE, TGT, rs2);
            end;
            if bOk and (not rs2.eol) then
            begin
              rAudit.u8UID:=u8Val(rs2.fields.Get_saValue(inttostr(rJColumn_Primary.JColu_JColumn_UID)));
            end;
            rs2.close;
          end;

          if (uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (uMOde=cnJBlokMode_SaveNNew) then
          begin
            if QXDL.FoundItem_saName(rJColumn_PRimary.JColu_name) then
            begin
              rAudit.u8UID:=u8Val(QXDL.Item_saValue);
            end;
          end;

        end;
        //ASPrintln('Calling Context.JTrakEnd(rAudit.u8UID,saQry2) now.');
        Context.JTrakEnd(rAudit.u8UID,saQry2);
        if bOk and ((uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (umode=cnJBlokMode_SaveNNew)) then
        begin
          bOk:=bRecord_PostUpdate(rAudit.u8UID);
          If not bOk Then
          Begin
            JAS_Log(Context,cnLog_Error,201203231930,'DataBlok Post Update Operation Failed. ','',SOURCEFILE);
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
          //ASPrintln('JASON - 1206 - Table: '+rJBlok.JBlok_JTable_ID+' UID: '+rAudit.u8UID);
          if not bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020045) then
          begin
            //ASPrintln('JASON - TRYING UNLOCK - WHOA DIDNT WORK');
          end;
          //ASPrintln('Lock Exist:'+inttostr(DBC.u8GetRecordCount('jlock','JLock_Row_ID='+rAudit.u8UID)));
          //ASPrintln('Lock Valid:'+sTrueFalse(JAS_RecordLockValid(Context, DBC.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,'0')));
        end;
        if bHaveKeyInFXDL and (u8NewKeyValue>0) then
        begin
          rAudit.u8UID:=u8NewKeyValue;
          //riteln('have key in FXDL. rAudit.u8UID: ',rAudit.u8UID);
          if (uMode=cnJBlokMode_Save) then
          begin
            uMode:=cnJBlokMode_View;
          end;
        end;
      end;
    End;
  end;

  //riteln('multi-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=');

  if bOk and bMultiMode and (uMode=cnJBlokMode_Save) then
  begin
    saQrySNR:=saQry;
    //riteln('multi-=-=-= - save - saQry=saQrySNR:=',saQrySNR);
    //JAS_Log(Context,cnLog_ebug,201104080802,'MultiEdit - saSectionBottom: '+saSectionBottom,'',SOURCEFILE);
    if Context.CGIENV.DataIn.MoveFirst then
    begin
      //riteln('multi-=-=-=- A');
      repeat
        //riteln('multi-=-=-=-=-=-=-=-=-=-= B =-=-=-=-=-=-=-=--===-=');
        //JAS_Log(Context,cnLog_ebug,201104080802,'MultiEdit - SessionXDL.ITem_saName: '+Context.SessionXDL.ITem_saName,'',SOURCEFILE);
        //riteln('Context.CGIENV.DataIn.ITem_saValue: '+Context.CGIENV.DataIn.ITem_saValue);
        //riteln('MultiEdit - SessionXDL.ITem_saName: '+Context.SessionXDL.ITem_saName);
        //ritelN('saSectionBottom: '+saSectionBottom);
        //riteln('saSectionBottom=Context.CGIENV.DataIn.ITem_saNAme: '+Context.CGIENV.DataIn.ITem_saNAme);
        //riteln('multi-=-=-=-=-=-=-=-=-=-= B =-=-=-=-=-=-=-=--===-=');
        //riteln;
        if Context.CGIENV.DataIn.ITem_saName=saSectionBottom then
        begin
          rAudit.u8UID:=u8Val(Context.CGIENV.DataIn.Item_saValue);
          //riteln('multi-=-=-=- Context.CGIENV.DataIn.Item_saValue: '+Context.CGIENV.DataIn.Item_saValue+'  rAudit.u8UID: ',rAudit.u8UID);
          bOk:=true;
          if bOk then
          begin
            //riteln('saQry: ',saQry);
            //riteln('rAudit.u8UID: ',rAudit.u8UID);
            saQry:=saSNRStr(saQRYSNR,'[@UID@]',inttostr(rAudit.u8UID));
            //riteln('multi-=-=-=- D - QRY: '+saQry);
            Context.JTrakBegin(TGT, rJTable.JTabl_Name, rAudit.u8UID);
            bOk:=rs.open(saQry, TGT,201605171853);
            //ASPrintln('note 2: Calling Context.JTrakEnd(rAudit.u8UID,saQry2) now.');
            Context.JTrakEnd(rAudit.u8UID,saQry);
            If not bOk Then
            Begin
              JAS_Log(Context,cnLog_Error,201203231201,'Dynamic Query Failed.','Query: '+ saQry,SOURCEFILE, TGT,rs);
            End;
            rs.close;
          end;
          //riteln('multi-=-=-=- E');
          if bOk then
          begin
            //riteln('multi-=-=-=- F');
            u8bookMark:=Context.CGIENV.DataIn.N;
            bOk:=bRecord_PostUpdate(rAudit.u8UID);
            Context.CGIENV.DataIn.FoundNth(u8BookMark);
            If not bOk Then
            Begin
              JAS_Log(Context,cnLog_Error,201203231931,'bRecord_Query failed '+
                'calling bRecord_PostUpdate with rAudit.u8UID: '+
                inttostr(rAudit.u8UID),'',SOURCEFILE);
            End;
          end;
          bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, u8Val(Context.CGIENV.DataIn.Item_saValue),0,201501020046);
        end;
      until (not bOk) or (not Context.CGIENV.DataIn.MoveNext);
    end;
  end;


  {
  JAS_LOG(Context, cnLog_ebug, 201203211450,}

  //riteln( csCRLF+
  //  'bOk: '+sYesNo(bOk)+csCRLF+
  //  'bMultiMode: ' +sYesNo(bMultiMode)+csCRLF+
  //  'TJBlok.bRecord_Query Exit'+csCRLF+
  //  'Mode: ' +sMode+csCRLF+
  //  'rAudit.u8UID: '+inttostr(rAudit.u8UID)+csCRLF+
  //  'saQry: '+saQry+csCRLF+
  //  'rJColumn_Primary.JColu_Name: '+rJColumn_Primary.JColu_Name+csCRLF+
  //  'rJColumn_Primary.JColu_JAS_Key_b: '+sYesNo(rJColumn_Primary.JColu_JAS_Key_b)+csCRLF+
  //  'bHaveKeyInFXDL: '+sYesNo(bHaveKeyInFXDL)+csCRLF+
  //  'bNewRecord: '+sYesNo(bNewRecord)+csCRLF+
  //  'u8NewKeyValue: '+inttostr(u8NewKeyValue)+csCRLF+
  //  'QXDL.ListCount: '+inttostr(QXDL.ListCount)+csCRLF+
  //  'QXDL: '+QXDL.saHTMLTable+csCRLF+
  //  'FXDL: '+FXDL.saHTMLTable+csCRLF);
  { ,'',SOURCEFILE); }

  if (uMode=cnJBlokMode_View) or (uMode=cnJBlokMode_Edit) then
  begin
    if FXDL.MoveFirst then
    begin
      repeat
        JBlokfield:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
        if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
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
    bJAS_UnLockRecord(Context, TGT.ID, rJBlok.JBlok_JTable_ID, rAudit.u8UID,0,201501020047);
  end;
  

  QXDL.Destroy;
  rs.Close;
  rs.Destroy;
  rs2.Destroy;

  //AS_Log(Context,cnLog_Ebug,201001082228,'Dynamic Query from TJBLOK.bRecord_Query :'+saQry,'',SOURCEFILE);
  result:=bOk;
  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));
  //riteln('END TJBLOK.bRecord_Query MultiMode: '+sYesNo(bMultiMode));
  //riteln(saRepeatChar('=',70));
  //riteln(saRepeatChar('=',70));
  //riteln;riteln;riteln;

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
  u8Column: UInt64;
  u8JWidgetID: word;
  u8JDTypeID: word;
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
  u8ClickActionID: UInt64;
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
    u8Column:=1;

    saContent:='';

    // Debug thing
    //case uMode of
    //cnJBlokMode_View: saContent+='View';
    //cnJBlokMode_New: saContent+='New';
    //cnJBlokMode_Delete: saContent+='Delete';
    //cnJBlokMode_Save: saContent+='Save';
    //cnJBlokMode_Edit: saContent+='Edit';
    //cnJBlokMode_Deleted: saContent+='Deleted';
    //cnJBlokMode_Cancel: saContent+='Cancel';
    //cnJBlokMode_SaveNClose: saContent+='SaveNClose';
    //cnJBlokMode_CancelNClose: saContent+='CancelNClose';
    //cnJBlokMode_SaveNNew: saContent+='SaveNNew';
    //end;//switch

    Context.PAGESNRXDL.AppendItem_SNRPair('[#JBLOKMODE#]',inttostr(uMode));

    saContent+='<table border="1">'+csCRLF;
    //saContent+='<table border="0">'+csCRLF;

    repeat
      JBLokField:=TJBLOKFIELD(JFC_XDLITEM(FXDL.lpItem).lpPtr);
      u8ClickActionID:=JBlokField.rJBlokField.JBlkF_ClickAction_ID;
      bVisible:=JBlokField.rJBlokField.JBlkF_Visible_b;
      if u8Column=1 then saContent+='<tr>'+csCRLF;
      if JBlokField.rJBlokField.JBlkF_ColSpan_u=0 then JBlokField.rJBlokField.JBlkF_ColSpan_u:=1;
      u8JWidgetID:=JBlokField.rJBlokField.JBlkF_JWidget_ID;
      u8JDTypeID:=JBlokField.rJColumn.JColu_JDType_ID;
      if u8JWidgetID=0 then u8JWidgetID:=u8JDTypeID;

      if(JScreen.bEditMode)then
      begin
        saContent+='<td ';
        If JBlokField.rJBlokField.JBlkF_ColSpan_u>1 Then saContent+=' colspan="'+inttostr(JBlokField.rJBlokField.JBlkF_ColSpan_u)+'" ';
        saContent+='><table border="1"><tr>';
      end;

      if bVisible or JScreen.bEditMode then
      begin
        saContent+='<td valign="top" ';
        if not JScreen.bEditMode then
        begin
          If JBlokField.rJBlokField.JBlkF_ColSpan_u>1 Then saContent+=' colspan="'+inttostr(JBlokField.rJBlokField.JBlkF_ColSpan_u)+'" ';
        end;
        saContent+='>'+csCRLF;
      end;

      bDetailEditMode:=(not JBlokField.rJBlokField.JBlkF_ReadOnly_b) and
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
          saDetailWidgetSNRName:='DBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID);
          if bMultiMode then
          begin
            saMESNRName:='MECHK_'+inttostr(JBLokField.rJBlokField.JBlkF_JBlokField_UID);
          end;
        End
        Else
        Begin
          saDetailWidgetSNRName:='RO_'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID);
        End;
      end;

      if not bMultiMode then
      begin
        sa:=JBlokField.rJBlokField.JBlkF_ClickActionData;
        //JAS_LOG(Context,cnLOG_Debug,201209201955,'==============' +sa,'',SOURCEFILE);
        //JAS_LOG(Context,cnLOG_Debug,201209201952,'Caption: '+JBlokField.saCaption+
        //  ' - CAD: '+sa,'',SOURCEFILE);
        sa:=saSNRStr(sa,'[@UID@]',rAudit.u8UID);
        sa:=saSNRSTR(sa,'[@JSID@]',inttostr(Context.rJSession.JSess_JSession_UID));
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
          case u8ClickActionID of
          cnJBlkF_ClickAction_DetailScreen: ;
          cnJBlkF_ClickAction_Link: begin ;
            if not u8JWidgetID=cnJWidget_Phone then
            begin
              JBlokField.saCaption:='<a href="'+sa+'">'+JBlokField.saCaption+'</a>'+csCRLF;
            end;
          end;
          cnJBlkF_ClickAction_LinkNewWindow: begin // Custom ClickAction Data - Target = New Window = _blank
            JBlokField.saCaption:='<a target="_blank" href="'+sa+'">'+JBlokField.saCaption+'</a>'+csCRLF;
          end;
          cnJBlkF_ClickAction_Custom: begin // 4 = Custom ClickAction Data = COMPLETELY CUSTOM - With SNR of fields - RISKY!
            //if JBlokField.rJBlokField.JBlkF_JColumn_ID>0 then
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






      If (u8ClickActionID=cnJBlkF_ClickAction_Custom) or (JBlokField.rJBlokField.JBlkF_JColumn_ID=0) Then
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
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b) and
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
              1,//height
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



          if u8JWidgetID=cnJWidget_URL then
          begin
            If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u=0 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=50;
            If JBlokField.rJBlokField.JBlkF_Widget_Width=0       Then JBlokField.rJBlokField.JBlkF_Widget_Width:=32;
            If JBlokField.rJBlokField.JBlkF_Widget_Height=0      Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
            WidgetURL(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bDetailEditMode,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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

          if (cnJWidget_Content=u8JWidgetID) and (not bDetailEditMode) then //(not JScreen.bEditMode) then
          begin
            Context.PAGESNRXDL.AppendItem_SNRPair('[#RO_'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'#]',JBlokField.saValue);
          end else

          if u8JWidgetID=cnJWidget_Email then
          begin
            If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u=0 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=50;
            If JBlokField.rJBlokField.JBlkF_Widget_Width=0     Then JBlokField.rJBlokField.JBlkF_Widget_Width:=32;
            If JBlokField.rJBlokField.JBlkF_Widget_Height=0    Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
            WidgetEmail(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bDetailEditMode,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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


          if u8JWidgetID=cnJWidget_Phone then
          begin
            //ASPrintln('!@!@!@!@!@!@@!@  PHONE !@!@!@!!@!@');
            //ASPrintln('!@!@!@!@!@!@@!@  '+garJVhostLight[Context.i4VHost].saSipURL);
            //ASPrintln('!@!@!@!@!@!@@!@  '+JBlokField.saValue);
            //ASPrintln('!@!@!@!@!@!@@!@  '+Context.rJUser.JUser_SIP_Exten);
            //ASPrintln('!@!@!@!@!@!@@!@  '+Context.rJUser.JUser_SIP_Pass);
            If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u=0 Then JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=11;
            If JBlokField.rJBlokField.JBlkF_Widget_Width=0     Then JBlokField.rJBlokField.JBlkF_Widget_Width:=11;
            If JBlokField.rJBlokField.JBlkF_Widget_Height=0    Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;


            //riteln('-=-=-= ',garJVhostLight[Context.i4VHost].saSipURL);
            WidgetPhone(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              saSNRStr(
                saSNRStr(
                  saSNRSTR(
                    garJVHost[Context.u2VHost].VHost_SipURL,
                    '[@PHONENUMBER@]',JBlokField.saValue
                  ),
                  '[@SIPEXTEN@]',
                  Context.rJUser.JUser_SIP_Exten
                ),
                '[@SIPPASS@]',
                Context.rJUser.JUser_SIP_Pass
              ),
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              bDetailEditMode,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
              false,
              false,
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


          if bIsJDTypeNumber(u8JWidgetID) or bIsJDTypeString(u8JWidgetID) or bIsJDTypeChar(u8JWidgetID) then
          begin
            If JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u=0 Then
            begin
              if bIsJDTypeNumber(u8JWidgetID) then
              begin
                JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=22;
              end
              else
              begin
                JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=50;
              end;
            end;
            If JBlokField.rJBlokField.JBlkF_Widget_Width=0     Then JBlokField.rJBlokField.JBlkF_Widget_Width:=50;
            If JBlokField.rJBlokField.JBlkF_Widget_Height=0    Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
            WidgetInputBox(
              Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              JBlokField.rJBlokField.JBlkF_Widget_Password_b,
              bDetailEditMode,
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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

          if bIsJDTypeBoolean(u8JWidgetID) then
          begin
            if JBlokField.saValue='' then JBlokField.saValue:='NULL';
            If JBlokField.rJBlokField.JBlkF_Widget_Height<1    Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;
            WidgetBoolean(
              Context,                                                                                   // p_Context: TCONTEXT;
              saDetailWidgetSNRName,                                                                     // p_saWidgetName: ansiString;
              JBlokField.saCaption,                                                                      // p_saWidgetCaption: AnsiString;
              JBlokField.saValue,                                                                        // p_saDefaultValue: AnsiString; // TRUE, FALSE, NULL
              JBlokField.rJBlokField.JBlkF_Widget_Height,                                                // p_u2Size: word; // Widget Height Property - effect SELECT Tag's Size
              bDetailEditMode,                                                                           // p_bEditMode: Boolean;
              False,                                                                                     // p_bFilter: Boolean; // If Used as a filter, 3 options Yes, No, Blank
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,                                            // p_bDataOnRight: Boolean;
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b), // p_bRequired: boolean;
              false,                                                                                     // p_bFilterTools: boolean;
              false,                                                                                     // p_bFilterNot: boolean;
              false,                                                                                     // p_bMultiple: boolean;
              false,                                                                                     // p_bBlankSelected: boolean;// THESE ARE FOR MULTIPLE SELECTION ONLY
              false,                                                                                     // p_bNULLSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
              false,                                                                                     // p_bTrueSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
              false,                                                                                     // p_bFalseSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
              JBlokField.rJBlokField.JBlkF_Widget_OnBlur,                                                // p_saOnBlur: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnChange,                                              // p_saOnChange: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnClick,                                               // p_saOnClick: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnDblClick,                                            // p_saOnDblClick: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnFocus,                                               // p_saOnFocus: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyDown,                                             // p_saOnKeyDown: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnKeypress,                                            // p_saOnKeypress: ansistring;
              JBlokField.rJBlokField.JBlkF_Widget_OnKeyUp                                                // p_saOnKeyUp: ansistring
            );                                                                                           //
          End else

          if bIsJDTypeDate(u8JWidgetID) then
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
              garJVHost[Context.u2VHost].VHost_DataOnRight_b,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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

          if bIsJDTypeMemo(u8JWidgetID) or bIsJDTypeBinary(u8JWidgetID) or ((cnJWidget_Content=u8JWidgetID) and (bDetailEditMode)) then
          begin
            If (JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u<1) OR
              (JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u>JBlokField.rJColumn.JColu_DefinedSize_u) Then
            Begin
              JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:=JBlokField.rJColumn.JColu_DefinedSize_u;
            End;
            If JBlokField.rJBlokField.JBlkF_Widget_Width<1 Then JBlokField.rJBlokField.JBlkF_Widget_Width:=40;
            If JBlokField.rJBlokField.JBlkF_Widget_Height<1 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=4;
            WidgetTextArea(Context,
              saDetailWidgetSNRName,
              JBlokField.saCaption,
              JBlokField.saValue,
              JBlokField.rJBlokField.JBlkF_Widget_Width,
              JBlokField.rJBlokField.JBlkF_Widget_Height,
              bDetailEditMode,
              JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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

          if (u8JWidgetID=cnJWidget_DropDown) or (u8JWidgetID=cnJWidget_ComboBox) then
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
              if u8JWidgetID=cnJWidget_DropDown then
              begin
                widgetdropdown(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_Height,
                  JBlokField.rJBlokField.JBlkF_MultiSelect_b,
                  bDetailEditMode,
                  garJVHost[Context.u2VHost].VHost_DataOnRight_b,
                  JBlokField.ListXDL, //caption (seen)//value (returned)// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  JBlokField.rJColumn.JColu_PrimaryKey_b,
                  JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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
                  garJVHost[Context.u2VHost].VHost_DataOnRight_b,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  JBlokField.rJColumn.JColu_PrimaryKey_b,
                  JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b), //p_bRequired: boolean;
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
              Context.PAGESNRXDL.AppendItem_saName_N_saValue('[#'+saDetailWidgetSNRName+'#]','(Populate list failed)');
            end;
          end else

          if (u8JWidgetID=cnJWidget_Lookup) or (u8JWidgetID=cnJWidget_LookupComboBox) then
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
              bIfInReadOnly_UseDefaultValueOnly:=JBlokField.rJColumn.JColu_PrimaryKey_b and (not bDetailEditMode);
              If JBlokField.rJBlokField.JBlkF_Widget_Height=0 Then JBlokField.rJBlokField.JBlkF_Widget_Height:=1;


              if (u8JWidgetID=cnJWidget_Lookup) then
              begin
                widgetdropdown(Context,
                  saDetailWidgetSNRName,
                  JBlokField.saCaption,
                  JBlokField.saValue,
                  JBlokField.rJBlokField.JBlkF_Widget_Height,
                  JBlokField.rJBlokField.JBlkF_MultiSelect_b,
                  bDetailEditMode,
                  garJVHost[Context.u2VHost].VHost_DataOnRight_b,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bIfInReadOnly_UseDefaultValueOnly,
                  JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b),
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
                  garJVHost[Context.u2VHost].VHost_DataOnRight_b,
                  JBlokField.ListXDL, // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
                  bIfInReadOnly_UseDefaultValueOnly,
                  JBlokField.rJBlokField.JBlkF_Required_b and (not JBlokField.rJBlokField.JBlkF_ReadOnly_b), //p_bRequired: boolean;
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
              Context.PAGESNRXDL.AppendItem_saName_N_saValue('[#'+saDetailWidgetSNRName+'#]','(Lookup Troubles)');
            end;
          end else

          begin
            Context.PAGESNRXDL.AppendItem_SNRPair('[#'+saDetailWidgetSNRName+'#]','(Unknown Widget Type)');
            bPreventSaveButton:=true;
          end;
        end;
      End;

      if bVisible or JScreen.bEditMode then
      begin
        if bMultiMode then saContent+='[#'+saMESNRName+'#]';
        saContent+='[#'+saDetailWidgetSNRName+'#]';

        If JBlokField.rJBlokField.JBlkF_ColSpan_u>1 Then
        Begin
          u8Column:=u8Column+JBlokField.rJBlokField.JBlkF_ColSpan_u;
        End
        Else
        Begin
          u8Column:=u8Column+1;
        End;

        {$IFDEF DEBUGHTML}
        saContent+='DataType:'+saJDType(JBlokField.rJColumn.JColu_JDType_ID)+'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_ReadOnly_b:' +          sYesNo(JBlokField.rJBlokField.JBlkF_ReadOnly_b)            +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u:' +  inttostr(JBlokField.rJBlokField.JBlkF_Widget_MaxLength_u)  +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Width:' +        inttostr(JBlokField.rJBlokField.JBlkF_Widget_Width)        +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Height:' +       inttostr(iJBlokField.rJBlokField.JBlkF_Widget_Height)      +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Password_b:' +   sYesNo(JBlokField.rJBlokField.JBlkF_Widget_Password_b)     +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Date_b:' +       sYesNo(JBlokField.rJBlokField.JBlkF_Widget_Date_b)         +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Time_b:' +       sYesNo(JBlokField.rJBlokField.JBlkF_Widget_Time_b)         +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_Widget_Mask:' +         JBlokField.rJBlokField.JBlkF_Widget_Mask                   +'<br />'+csCRLF;
        saContent+='JBlokField.rJBlokField.JBlkF_ColSpan_u:' +           inttostr(JBlokField.rJBlokField.JBlkF_ColSpan_u)           +'<br />'+csCRLF;
        saContent+='JBlokField.saValue:' +                               JBlokField.rJBlokField.saValue                             +'<br />'+csCRLF;
        saContent+='JBlokField.saRequired:' +                            sYesNo(JBlokField.rJBlokField.rJBlokField.JBlkF_Required_b)+'<br />'+csCRLF;
        {$ENDIF}
      end;
      
      if(JScreen.bEditMode)then
      begin
        saContent+=
          '</td></tr>'+
          '<tr><td>DBLOK'+inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'</td></tr>'+
          '<tr><td><table class="jasgrid"><tr>'+
          '<td><a title="Edit JBlokField" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jblokfield%20Data&UID='+
          inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''');">'+
            '<img class="image" title="JBlokField" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit.png" /></a></td>';
        if JBlokField.rJColumn.JColu_JColumn_UID>0 then
        begin
          saContent+=
            '<td><a title="Edit JColumn" href="javascript: edit_init(); NewWindow(''[@ALIAS@].?SCREEN=jcolumn%20Data&UID='+
            inttostr(JBlokField.rJColumn.JColu_JColumn_UID)+'&JSID='+inttostr(Context.rJSession.JSess_JSession_UID)+''')">'+
            '<img class="image" title="JColumn" src="<? echo $JASDIRICONTHEME; ?>16/actions/view-pane-text.png" /></a></td>';
        end;
        // End fix

        saContent+=
          '<td><a title="Left" href="javascript: editcol_left('''+     inttostr(rJBlok.JBlok_JBlok_UID) +''','''+ inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID) +''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-previous.png" /></a></td>'+
          '<td><a title="Up"  href="javascript: editcol_up('''+        inttostr(rJBlok.JBlok_JBlok_UID) +''','''+ inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID) +''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></a></td>'+
          '<td><a title="Down"  href="javascript: editcol_down('''+    inttostr(rJBlok.JBlok_JBlok_UID) +''','''+ inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID) +''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></a></td>'+
          '<td><a title="Right"  href="javascript: editcol_right('''+  inttostr(rJBlok.JBlok_JBlok_UID) +''','''+ inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID) +''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-next.png" /></a></td>'+
          '<td><a title="Delete"  href="javascript: editcol_delete('''+inttostr(rJBlok.JBlok_JBlok_UID) +''','''+ inttostr(JBlokField.rJBlokField.JBlkF_JBlokField_UID) +''');"><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" /></a></td>'+
          '</tr></table></td></tr></table>';
      end;

      if bVisible or JScreen.bEditMode then
      begin
        saContent+='</td>'+csCRLF;
        If u8Column>rJBlok.JBlok_Columns_u Then
        Begin
          saContent+='</tr>'+csCRLF;
          u8Column:=1;
        End;
      end;
    Until not FXDL.MoveNext;
  end;

  If u8Column<=rJBlok.JBlok_Columns_u Then
  Begin
    //if iColumn=1 then saContent+='<tr>'+csCRLF;
    if u8Column>1 then
    begin
      repeat
        u8Column+=1;
        {$IFDEF DEBUGHTML}
        saContent+='<td>filler</td>'+csCRLF;
        {$ELSE}
        saContent+='<td></td>'+csCRLF;
        {$ENDIF}
      Until u8Column>rJBlok.JBlok_Columns_u;
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
function TJBLOK.bRecord_SecurityCheck(p_u8UID: Uint64; p_iRecordAction: smallint; p_u8Caller: uint64): boolean;
//==============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  JScreen: TJSCREEN;
  Context: TCONTEXT;

  //bOwnerOnly: boolean;
  u8PermID: uint64;

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

  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  u8PermID:=0;

  if not Context.rJUser.JUser_Admin_b then
  begin
    saQry:='select '+
      DBC.sDBMSEncloseObjectName('JTabl_Add_JSecPerm_ID')+', '+
      DBC.sDBMSEncloseObjectName('JTabl_Update_JSecPerm_ID')+', '+
      DBC.sDBMSEncloseObjectName('JTabl_View_JSecPerm_ID')+', '+
      DBC.sDBMSEncloseObjectName('JTabl_Delete_JSecPerm_ID')+' '+
      'FROM '+DBC.sDBMSEncloseObjectName('jtable')+' '+
//      'WHERE UCASE('+DBC.sDBMSEncloseObjectName('JTabl_Name')+')=UCASE('''+rJTable.JTabl_Name+''')'+
      'WHERE JTabl_JTable_UID='+TGT.sDBMSUIntScrub(rJTable.JTabl_JTable_UID)+
      ' AND ((JTabl_Deleted_b=false)or(JTabl_Deleted_b is null))';
    bOk:=rs.open(saQry,TGT,201503161523);
    if not bOk then
    begin
      JAS_LOG(Context,cnLog_Error,201506121449,'Query Failed',saQry,SOURCEFILE);
    end;

    if bOk then
    begin
      case p_iRecordaction of
      cnRecord_Add:    u8PermID:= u8Val(rs.fields.Get_saValue('JTabl_Add_JSecPerm_ID'));
      cnRecord_Edit:   u8PermID:= u8Val(rs.fields.Get_saValue('JTabl_Update_JSecPerm_ID'));
      cnRecord_View:   u8PermID:= u8Val(rs.fields.Get_saValue('JTabl_View_JSecPerm_ID'));
      cnRecord_Delete: u8PermID:= u8Val(rs.fields.Get_saValue('JTabl_Delete_JSecPerm_ID'));
      end;//end switch
      bOk:=(u8PermID=0) or bJAS_HasPermission(Context,u8PermID);
      if not bOk then
      begin
        JAS_LOG(Context,cnLog_Error,201503121912,'Access Denied - Permission ID: ' +
          inttostr(u8PermID)+' User: '+Context.rJUser.JUser_Name+' Caller: '+inttostr(p_u8Caller),'',SOURCEFILE);
      end;
    end;
    rs.close;
  end;
  //if bOK and (uMode=cnJBlokMode_Save) or (uMode=cnJBlokMode_SaveNClose) or (uMode=cnJBlokMode_SaveNNew) then //((p_iRecordAction=cnRecord_Add)or(p_iRecordAction=cnRecord_Edit))then
  //begin
  //  bOk:=bRecord_PreUpdate(QXDL, p_sUID);
  //  if not bOk then
  //  begin
  //    JAS_LOG(Context,cnLog_Warn,201503121913,'PreUpdate Failed. Table:'+rJTable.JTabl_Name+' UID:'+p_sUID+' PermID:' + saPermID+' User: '+Context.rJUser.JUser_Name+' UID:'+p_sUID,'',SOURCEFILE);
  //  end;
  //end;                  select JColu_CreatedBy_JUser_ID from `jcolumn` where `JColu_JColumn_UID`=0



  if bOk then  
  begin
    // test for rAudit.saFieldName_CreatedBy_JUser_ID    in table rJTable.JTabl_Name
    if JADO.bColumnExists(rJTable.JTabl_Name,rAudit.saFieldName_CreatedBy_JUser_ID,TGT,201506141036) and 
       JADO.bColumnExists(rJTable.JTabl_Name,rJColumn_Primary.JColu_Name,TGT,201506141037) then
    begin
      saQry:='select '+rAudit.saFieldName_CreatedBy_JUser_ID+' '+
        'from '+DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' where '+
        DBC.sDBMSEncloseObjectName(rJColumn_Primary.JColu_Name)+'='+inttostr(p_u8UID);
      bOk:=rs.open(saQry,TGT,201503161524);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201503122025, 'Query Field',saQry,SOURCEFILE);
        //riteln('ok has died A');
      end;

      bOk:=NOT rs.EOL;
      if not bOK then
      begin
        //riteln('ok has died B');
        JAS_LOG(Context,cnLog_Error,201503122027,'201503122027 - Missing Record. Record Action(add 0,edit 1,view 2,delete 3): '+
          inttostr(p_iRecordAction)+' Query: '+saQry+' CALLER: '+inttostr(p_u8Caller),'',SOURCEFILE);
      end;  
    
      if bOk then
      begin 
        if rJTable.JTabl_Owner_Only_b then
        begin
          bOk:=uVal(rs.fields.Get_saValue(rAudit.saFieldName_CreatedBy_JUser_ID))=Context.rJUser.JUser_JUser_UID;
          if not bOK then
          begin
            //riteln('ok has died C');
            JAS_LOG(Context,cnLog_Error,201503122029,'201503122029 - User tried to '+
              'access a record owned by another on an owner controlled table. Owner: '+
              rs.fields.Get_saValue(rAudit.saFieldName_CreatedBy_JUser_ID)+' '+
              rJTable.JTabl_Name+' User:'+Context.rjuser.juser_name+' User ID:'+
              inttostr(Context.rjuser.juser_juser_uid)+' CALLER: '+inttostr(p_u8Caller),'',SOURCEFILE);
          end;  
        end;
      end;         
    end;
  end;
  
  rs.Destroy;
  result:=bOk;
  //result:=true;
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
  sAddBlokField:='';

  // GRID RELATED - SPANS FILTER and GRID Bloks
  u2GridRowsPerPage:=0;
  uRPage:=0;
  uRTotalPages:=0;
  uRTotalRecords:=0;
  u8RecordCount:=0;
  u8PageRowMath:=0;
  saExportPage:='';
  saExportMode:='';
  bExportingNow:=false;
  bBackgroundPrepare:=false;
  bBackgroundExporting:=false;
  u8BackTask:=0;
  bRecycleBinMode:=bVal(p_Context.CGIENV.DataIn.Get_saValue('RECYCLEBINMODE'));


  EDIT_ACTION:='';
  EDIT_JBLOK_JBLOK_UID:=0;
  EDIT_JBLKF_JBLOKFIELD_UID:=0;

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

  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - A');
  bOk:=bLoadJScreenRecord;
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - B');
  //if not bOk then
  //begin
  //  JAS_Log(Context,cnLog_Error,201210011745,'TJSCREEN.bExecute call to bLoadJScreenRecord Failed for ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
  //end;
  
  if bOk then
  begin
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - C');
    bOk:=bValidate;
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - D');
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011746,
        'Access Denied',
        'TJSCREEN.bExecute call to bValidate Failed for ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID),
      SOURCEFILE);
    end;
  end;

  // Make Sure Template Loaded Ok
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - E');
  if bOk then
  begin
    bOk:=not Context.bErrorCondition;
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201203032220,'Trouble loading Template:'+rJScreen.JScrn_Template+' ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID),'',SOURCEFILE);
    end;
  end;
  //AS_Log(Context,cnLog_ebug,201203192358,'Before bPlaceScreenHeaderInPageSNRXDL bOK: '+sYesNo(bOk)+' bPageCompleted: '+sYesNo(bPageCompleted),'',SOURCEFILE);
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - F');
  if bOk then
  begin
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - G');
    bOk:=bPlaceScreenHeaderInPageSNRXDL;
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - H');
    if not bOk then
    begin
      JAS_Log(Context,cnLog_Error,201210011747,'TJSCREEN.bExecute call to bPlaceScreenHeaderInPageSNRXDL Failed - ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID),'',SOURCEFILE);
    end;
  end;

    
  Context.saPagetitle:=saCaption;

  //AS_Log(Context,cnLog_ebug,201203192358,'Before TJBLOK bLoadJBloks. bOK: '+sYesNo(bOk)+' bPageCompleted: '+sYesNo(bPageCompleted),'',SOURCEFILE);
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - I');
  if bOk then
  begin
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - J');
    bOk:=bLoadJBloks;
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - K');
    if not bOk then
    begin
      //JAS_Log(Context,cnLog_Error,201210011748,'Unable to display screen. Please make sure the table has a primary key and JAS knows about it.',
      //  'TJSCREEN.bExecute call to bLoadJBloks Failed - ScreenID:' + rJScreen.JScrn_JScreen_UID,SOURCEFILE);
    end;
  end;

  //AS_Log(Context,cnLog_ebug,201203192358,'Before TJBLOK Execute. bOK: '+sYesNo(bOk)+' bPageCompleted: '+sYesNo(bPageCompleted),'',SOURCEFILE);
  if bOk and (not bPageCompleted) then
  begin
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - L');
    if JBXDL.MoveFirst then
    begin
      if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Executing JBloks');
      repeat
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Executing JBlok: '+TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPTR).saCaption);
        bOk:=TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPTR).bExecute;
        if not bOk then
        begin
          //AS_Log(Context,cnLog_Error,201210011749,'TJSCREEN.bExecute call to '+TJBLOK(JFC_XDLITEM(JBXDL.lpItem).lpPTR).rJBlok.JBlok_Name+
          //  '.bExecute Failed - ScreenID:' + rJScreen.JScrn_JScreen_UID,'',SOURCEFILE);
        end;
        //AS_Log(Context,cnLog_ebug,201203192358,'Finished TJBLOK Execute. bOK: '+sYesNo(bOk)+' bPageCompleted: '+sYesNo(bPageCompleted),'',SOURCEFILE);
      until (not bOk) or (not JBXDL.MoveNext);
    end;
  end;
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - M');

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
      Context.u2DebugMode:=cnSYS_INFO_MODE_SECURE;

      //=========================================== HEADER
      Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      Context.CGIENV.HEADER.MoveFirst;
      Context.CGIENV.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,Context.CGIENV.saHttpResponse);
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,Context.CGIENV.saServerSoftware);
      Context.CGIENV.Header_Date;
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,saMimeType);
      //header('Content-Type: text/csv; charset=utf-8');
      //header('Content-Disposition: data.csv');
      Context.CGIENV.HEADER.AppendItem_saName_N_saValue('Content-Disposition: ','attachment; filename="'+saOrigFilename+'"');
      //Context.CGIENV.Header_Co okies(garJVHost[Context.u2VHost].VHost_ServerIdent);
      Context.CGIENV.Header_HTML(garJVHost[Context.u2VHost].VHost_ServerIdent);
      //=========================================== HEADER
      Context.sMimeType:=saMimeType;
      if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - N');

      if bBackgroundExporting then
      begin
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - O');
        bOk:=bStoreFileInTree(
          saOrigfilename,
          '',//  p_saSourceDirectory: AnsiString; // Containing file to store
          saOrigfilename,//  p_saSourceFileName: AnsiString; // Filename to copy and store (unless p_sadata is used)
          garJVHost[Context.u2VHost].VHost_FileDir,//  p_saDestTreeTop: AnsiString; // Top of STORAGE TREE
          Context.saPage,//  p_saData: AnsiString; // If this variable is not empty - then it is used in place
            //  // of the p_saSourceDirectory and p_saSourceFilename parameters - and is basically
            //  // saved as the p_saDestFilename in the calculated tree's relative path.
          saRelPath,//  Var p_saRelPath: AnsiString; // This gets the saRelPath when its created.
          2,//  p_i4Size: longint;
          3//  p_i4Levels: longint
        );//):Boolean;
        //ASPrintln('i4VRO_SaveEvent - ICON - G');
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - P');

        if not bOk then
        begin
          JAS_Log(Context,cnLog_Error,201210231853,'Unable to store data export file during background process.',
            'TJSCREEN.bExecute - Filename: '+saOrigFilename+' - ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID),SOURCEFILE);
        end;
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q');

        if bOk then
        begin
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q1');
          path:=saOrigFilename;
          FSplit(path,dir,name,ext);
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q2');
          saStoredFile:=saAddSlash(garJVHost[Context.u2VHost].VHost_FileDir)+saAddSlash(saRelPath)+saOrigFilename;
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q3');
          if saLeftStr(ext,1)='.' then ext:=saRightStr(ext,length(ext)-1);
          saFilename:=saSequencedFilename(saAddSlash(garJVHost[Context.u2VHost].VHost_FileDir)+saAddSlash(saRelPath)+name,ext);
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q4 - saStoredFile:'+saStoredFile);
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q4 - saFileName:'+saFileName);
          bOk:=bMoveFile(saStoredFile, saFilename);
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Q5');
          if not bOk then
          begin
            JAS_Log(Context, cnLog_Error,201210250147, 'Trouble moving file. Src: '+saStoredFile+' Dest: '+saFilename,'',SOURCEFILE);
            RenderHTMLErrorPage(Context);
          end;
        end;
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - R');

        if bOk then
        begin
          path:=safilename;
          FSplit(path,dir,name,ext);
          clear_JFile(rJFile);
          with rJFile do begin
            JFile_JFile_UID    :=0;
            JFile_en           :='Export from '+rJScreen.JScrn_Name+' screen.';
            JFile_Name         :=Name+ext;
            JFile_Path         :=saRelPath+DOSSLASH+name+ext;
            JFile_JTable_ID    :=DBC.u8GetTableID('jtask',201210150154);
            JFile_JColumn_ID   :=0;
            JFile_Row_ID       :=u8BackTask;
            JFile_Orphan_b     :=false;
            JFile_JSecPerm_ID  :=0;
            JFile_FileSize_u   :=length(Context.saPage);
          end;//with
          bOk:=bJAS_Save_JFile(Context, DBC, rJFile, false,false,201603310320);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error,201210231911,'Unable to save file information about data export file '+
              'during background process.','TJSCREEN.bExecute - Filename: '+saFilename+' - ScreenID:' +
              inttostr(rJScreen.JScrn_JScreen_UID),SOURCEFILE);
          end;
        end;
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - S');

        if bOk then
        begin
          clear_JTask(rJTask);
          rJTask.JTask_JTask_UID:=u8BackTask;
          bOk:=bJAS_Load_JTask(Context, DBC, rJTask, true,201603310321);
          if not bOk then
          begin
            JAS_LOG(Context, cnLog_Error, 201210231927,'Unable to load JTask Record: '+inttostr(u8BackTask),'',SOURCEFILE);
          end;
        end;
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - T');

        if bOk then
        begin
          // 1: Update Task fields
          with rJTask do begin
            //JTask_JTask_UID                  : ansistring;
            //JTask_Name                       : ansistring;
            //JTask_Desc                       : ansistring;
            //JTask_JTaskCategory_ID           : ansistring;
            //JTask_JProject_ID                : ansistring;
            JTask_JStatus_ID                   :=cnJStatus_Completed;
            //JTask_Due_DT                     : ansistring;
            //JTask_Duration_Minutes_Est       : ansistring;
            //JTask_JPriority_ID               : ansistring;
            //JTask_Start_DT                   : ansistring;
            //JTask_Owner_JUser_ID             : ansistring;
            JTask_SendReminder_b             :=true;
            JTask_ReminderSent_b             :=true;
            JTask_ReminderSent_DT            :=FormatDateTime(csDATETIMEFORMAT,now);
            JTask_Remind_DaysAhead_u         :=0;
            JTask_Remind_HoursAhead_u        :=0;
            JTask_Remind_MinutesAhead_u      :=0;
            JTask_Remind_Persistantly_b      :=false;
            JTask_Progress_PCT_d             :=100;
            //JTask_JCase_ID                   : ansistring;
            //JTask_Directions_URL             : ansistring;
            JTask_URL                        :=garJVHost[COntext.u2VHost].VHost_ServerURL+Context.sAlias+'.?action=filedownload&UID='+inttostr(rJFile.JFile_JFile_UID)+'&JSID=[@JSID@]';
            //JTask_Milestone_b                : ansistring;
            //JTask_Budget_d                   : ansistring;
            JTask_ResolutionNotes            :='Export Completed Successfully';
            JTask_Completed_DT               :=FormatDateTime(csDATETIMEFORMAT,now);
            //JTask_CreatedBy_JUser_ID         : ansistring;
            JTask_Related_JTable_ID          :=DBC.u8GetTableID('jfile',201210150155);
            JTask_Related_Row_ID             :=rJFile.JFile_JFile_UID;
            //JTask_Created_DT                 : ansistring;
            //JTask_ModifiedBy_JUser_ID        : ansistring;
            //JTask_Modified_DT                : ansistring;
            //JTask_DeletedBy_JUser_ID         : ansistring;
            //JTask_Deleted_DT                 : ansistring;
            //JTask_Deleted_b                  : ansistring;
            //JAS_Row_b                        : ansistring;
          end;//with
          bOk:=bJAS_Save_JTask(Context, DBC, rJTask,true,false,201603310322);
          if not bOk then
          begin
            JAS_LOG(Context,cnLog_Error,201210231930,'Unable to Save JTask Record: '+inttostr(u8BackTask),'',SOURCEFILE);
          end;
        end;
        if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - U');

        if bOk then
        begin
          // 2: Job Queue Email Notifcation
          with rJJobQ do begin
            JJobQ_JJobQ_UID           :=0;
            JJobQ_JUser_ID            :=Context.rJSession.JSess_JUser_ID;
            JJobQ_JJobType_ID         :=cnJJobType_General;
            JJobQ_Start_DT            :=FormatDateTime(csDateTimeformat,now);
            //JJobQ_ErrorNo_u           : ansistring;
            //JJobQ_Started_DT          : ansistring;
            JJobQ_Running_b           :=false;
            //JJobQ_Finished_DT         : ansistring;
            JJobQ_Name                :='Email - Data Export';
            JJobQ_Repeat_b            :=false;
            //JJobQ_RepeatMinute        : ansistring;
            //JJobQ_RepeatHour          : ansistring;
            //JJobQ_RepeatDayOfMonth    : ansistring;
            //JJobQ_RepeatMonth         : ansistring;
            JJobQ_Completed_b         :=false;
            //JJobQ_Result_URL          : ansistring;
            //JJobQ_ErrorMsg            : ansistring;
            //JJobQ_ErrorMoreInfo       : ansistring;
            JJobQ_Enabled_b           :=true;

            JJobQ_Job                 :=
              '<CONTEXT>'+csCRLF+
              '  <saRequestMethod>GET</saRequestMethod>'+csCRLF+
              '  <saQueryString>jasapi=email&type=DataExportComplete&uid='+inttostr(rJFile.JFile_JFile_UID)+'</saQueryString>'+csCRLF+
              '  <saRequestedFile>'+Context.sAlias+'</saRequestedFile>'+csCRLF+
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
            JJobQ_JTask_ID            :=u8BackTask;
          end;// with
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - V');
          bOk:=bJAS_Save_JJobQ(Context,DBC,rJJobQ,false,false,201603310323);
          if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - W');
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
    if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - X');
    if Context.bErrorCondition then
    begin
      RenderHTMLErrorPage(Context);
    end;
  end;
  if Context.bInternalJob then JASPRintln('TJSCreen.bExecute - Y - END');
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
  saQry:=
    'SELECT '+DBC.sDBMSEncloseObjectName('JScrn_JScreen_UID')+' '+
    'FROM '+DBC.sDBMSEncloseObjectName('jscreen')+' '+
    'WHERE (('+DBC.sDBMSEncloseObjectName('JScrn_Deleted_b')+'='+DBC.sDBMSBoolScrub(false)+') OR '+
    '('+DBC.sDBMSEncloseObjectName('JScrn_Deleted_b')+' IS NULL)) ';
  if Context.CGIENV.DataIn.FoundItem_saName('SCREENID',FALSE) then
  begin
    saQry+=' AND '+DBC.sDBMSEncloseObjectName('JScrn_JScreen_UID')+'=' + DBC.sDBMSUIntScrub(Context.CGIENV.DataIn.Item_saValue);
  end else

  if Context.CGIENV.DataIn.FoundItem_saName('SCREEN',FALSE) then
  begin
    saQry+=' and JScrn_Name=' + DBC.saDBMSScrub(Context.CGIENV.DataIn.Item_saValue);
  end;

  bOk:=(rs.Open(saQry, DBC,201503161525) and (rs.EOL=False));
  If not bOk Then
  Begin
    JAS_Log(Context,cnLog_Error,201203171426,'Specified Screen Missing',
      'Sought Screen Name: '+ Context.CGIENV.DataIn.Get_saValue('Screen')+' '+
      'Sought Screen ID: '+ Context.CGIENV.DataIn.Get_saValue('ScreenID') +' '+
      'Qry:' + saQry,SOURCEFILE,DBC,rs
    );
    //Context.CGIENV.uHTTPResponse:=cnHTTP_Response_404;
  end;

  If bOk Then
  Begin
    clear_JScreen(rJScreen);
    rJScreen.JScrn_JScreen_UID:=u8Val(rs.Fields.Get_saValue('JScrn_JScreen_UID'));
    bOk:=bJAS_Load_JScreen(Context,DBC,rJScreen, false,201603310324);
    if not bOk then
    begin
      JAS_LOG(Context, cnLog_Error, 201203171427, 'Trouble loading Screen','JScrn_JScreen_UID: '+inttostr(rJScreen.JScrn_JScreen_UID),SOURCEFILE);
    end;
  end;
  rs.close;
  rs.destroy;

  if rJScreen.JScrn_IconSmall='NULL' then rJScreen.JScrn_IconSmall:='';
  if rJScreen.JScrn_IconLarge='NULL' then rJScreen.JScrn_IconLarge:='';
  if bOk then
  begin
    Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREEN_HELP_ID@]',inttostr(rJScreen.JScrn_Help_ID));
    //ASPrintln('-------------------screen id: ' + rJScreen.JScrn_JScreen_UID);
    //ASPrintln('-------------------screen help id: ' + rJScreen.JScrn_Help_ID);
    //asPrintln('');    
    
    if bMiniMode then
    begin
      saFileName:=
        saJasLocateTemplate(
          rJScreen.JScrn_TemplateMini+csJASFileExt,
          Context.sLANG,
          Context.sTheme,
          COntext.sarequestedDir,
          201210011935,
          garJVHost[Context.u2VHost].VHost_TemplateDir,
          garJVHost[Context.u2VHost].VHost_WebShareDir
        );
      bOk:=FileExists(saFilename);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201210011919, 'Template not found. JScreen: '+rJScreen.JScrn_Name+
          ' Template: '+safilename,'JScrn_JScreen_UID: '+inttostr(rJScreen.JScrn_JScreen_UID),SOURCEFILE);
      end;
    end
    else
    begin
      saFileName:=
        saJasLocateTemplate(
          rJScreen.JScrn_Template+csJASFileExt,
          Context.sLANG,
          Context.sTheme,
          COntext.sarequestedDir,201210011935,
          garJVHost[Context.u2VHost].VHost_TemplateDir,
          garJVHost[Context.u2VHost].VHost_WebShareDir
        );
      bOk:=FileExists(saFilename);
      if not bOk then
      begin
        JAS_LOG(Context, cnLog_Error, 201210011920, 'Template not found: '+rJScreen.JScrn_Template+csJASFileExt+' JScreen: '+rJScreen.JScrn_Name+
          ' Located Filename: '+saFilename,'JScrn_JScreen_UID: '+inttostr(rJScreen.JScrn_JScreen_UID),SOURCEFILE);
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
  bOk:=Context.bSessionValid OR (not rJScreen.JScrn_ValidSessionOnly_b);
  If not bOk Then
  Begin
    JAS_Log(Context,cnLog_Error,200701041928,'Session is not Valid. You need to be logged in to view this page.',
      'ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID) + ' from jscreen table. JScrn_ValidSessionOnly_b field returned: '+ sYesNo(rJScreen.JScrn_ValidSessionOnly_b),SOURCEFILE);
  End;

  If bOk Then
  Begin
    bOk:=(not rJScreen.JScrn_ValidSessionOnly_b) or
         (((rJScreen.JScrn_JSecPerm_ID>0) or bJAS_HasPermission(Context,rJScreen.JScrn_JSecPerm_ID)));
    If not bOk Then
    Begin
      JAS_Log(Context,cnLog_Error,200701252204,'You are not authorized to access this area.',
        'ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID) + '. Permission ID:'+inttostr(rJScreen.JScrn_JSecPerm_ID),SOURCEFILE);
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
          u8BackTask:=u8Val(Context.CGIENV.DataIn.Item_saValue);
        end;
      end;
    end;
  end;

  if bOk then
  begin
    if not bExportingNow then
    begin
      bEditMode:=Context.bSessionValid and context.rJUser.JUser_Admin_b and
         (UPPERCASE(Context.CGIENV.DATAIN.Get_saValue('EDITSCREEN'))='ON');
      if bEditMode then
      begin
        //bOk:=(rJScreen.JScrn_Modify_JSecPerm_ID=0) or
        //     (bJAS_HasPermission(Context,rJScreen.JScrn_Modify_JSecPerm_ID)));
        //if not bOk then
        //begin
        //  JAS_Log(Context,cnLog_Error,201203070758,'You are not authorized to modify this screen.',
        //    'ScreenID:' + rJScreen.JScrn_JScreen_UID + ' '+'Screen Name: '+rJScreen.JScrn_Name+
        //    ' Required Permission: '+rJScreen.JScrn_Modify_JSecPerm_ID,SOURCEFILE);
        //end;

        EDIT_ACTION:=Context.CGIENV.DataIn.Get_saValue('EDIT_ACTION');
        EDIT_JBLOK_JBLOK_UID:=u8Val(Context.CGIENV.DataIn.Get_saValue('EDIT_JBLOK_JBLOK_UID'));
        EDIT_JBLKF_JBLOKFIELD_UID:=u8Val(Context.CGIENV.DataIn.Get_saValue('EDIT_JBLKF_JBLOKFIELD_UID'));
        Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDITSCREEN@]','checked');
      end
      else
      begin
        Context.PageSNRXDL.AppendItem_saName_N_saValue('[@EDITSCREEN@]','');
      end;
    end;
  end;

  if bOk then
  begin
    //case rJScreen.JScrn_JScreenType_ID of
    //cnJScreenType_FilterGrid,cnJScreenType_Data: begin
      if bMiniMode then
      begin
        saTemplate:=saGetPage(Context, 'sys_area_bare', rJScreen.JScrn_TemplateMini,'SCREEN',False,123020100004);
      end
      else
      begin
        saTemplate:=saGetPage(Context, 'sys_area', rJScreen.JScrn_Template,'SCREEN',False,123020100004);
      end;
    //end;
    //else begin
    //  bOk:=false;
    //  JAS_Log(Context,cnLog_Error,201203032230,
    //    'Invalid Dynamic Screen Type: '+inttostr(rJScreen.JScrn_JScreenType_ID)+' '+
    //    'ScreenID:' + inttostr(rJScreen.JScrn_JScreen_UID)+' Name:'+rJScreen.JScrn_Name,
    //    '',SOURCEFILE);
    //end;
    //end;//switch
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
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JSCREEN_UID@]',inttostr(rJScreen.JScrn_JScreen_UID));
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_NAME@]',rJScreen.JScrn_Name);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_TEMPLATE@]',rJScreen.JScrn_Template);
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_VALIDSESSIONONLY_B@]',sYesNo(rJScreen.JScrn_ValidSessionOnly_b));
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JSECPERM_ID@]',inttostr(rJScreen.JScrn_JSecPerm_ID));
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_DETAILSCREENID@]',inttostr(rJScreen.JScrn_JCaption_ID));
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_DESC@]',inttostr(rJScreen.JScrn_JCaption_ID));
        AppendItem_SNRPair('[@SCREENADMIN_JSCRN_JCAPTION_ID@]',inttostr(rJScreen.JScrn_JCaption_ID));
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
    AppendItem_SNRPair('[@JSCRN_JSCREEN_UID@]',inttostr(rJScreen.JScrn_JScreen_UID));
    AppendItem_SNRPair('[@JSCRN_NAME@]',rJScreen.JScrn_Name);
    AppendItem_SNRPair('[@JSCRN_JSCREENTYPE_ID@]',inttostr(rJScreen.JScrn_JScreenType_ID));
    AppendItem_SNRPair('[@JSCRN_TEMPLATE@]',rJScreen.JScrn_Template);
    AppendItem_SNRPair('[@JSCRN_JSECPERM_ID@]',inttostr(rJScreen.JScrn_JSecPerm_ID));
    AppendItem_SNRPair('[@JScrn_ValidSessionOnly_b@]',sYesNo(rJScreen.JScrn_ValidSessionOnly_b));
    AppendItem_SNRPair('[@JSCRN_JCAPTION_ID@]',inttostr(rJScreen.JScrn_JCaption_ID));
    AppendItem_SNRPair('[@JSCRN_JCAPTION_ID@]',inttostr(rJScreen.JScrn_JCaption_ID));
    AppendItem_SNRPair('[@JSCRN_ICONSMALL@]',rJScreen.JScrn_IconSmall);
    AppendItem_SNRPair('[@JSCRN_ICONLARGE@]',rJScreen.JScrn_IconLarge);
    AppendItem_SNRPair('[@SCREENID@]',inttostr(rJScreen.JScrn_JScreen_UID));
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
    '  '+DBC.sDBMSEncloseObjectName('JBlok_JBlok_UID')+' '+
    'from '+DBC.sDBMSEncloseObjectName('jblok')+' '+
    'where '+
    '  '+DBC.sDBMSEncloseObjectName('JBlok_JScreen_ID')+'='+DBC.sDBMSUIntScrub(rJScreen.JScrn_JScreen_UID) + ' AND ' +
    '  '+DBC.sDBMSEncloseObjectName('JBlok_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true) + ' ' +
    'ORDER BY '+DBC.sDBMSEncloseObjectName('JBlok_Position_u');
  bOk:=rs.Open(saQry, DBC,201503161526);
  if not bOk then
  begin
    JAS_LOG(Context, cnLog_Error, 201203171721, 'Trouble with Query.','Query: '+saQry, SOURCEFILE, DBC, rs);
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      JBlok:=TJBlok.Create(pointer(self),u8Val(rs.fields.Get_saValue('JBlok_JBlok_UID')));
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



//==============================================================================
function TJScreen.saSIP_URL_Assembled(p_saPhoneNumber: ansistring): ansistring;
//==============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saASSEMBLED_SIP_URL: ansistring'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBIN(20151130124,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}Context.JThread.TrackThread(20151130125, sTHIS_ROUTINE_NAME);{$ENDIF}

  //JBlok:=TJBLOK(p_lpJBlok);



  result:=
    saSNRStr(
      saSNRStr(
        saSNRSTR(
          garJVHost[Context.u2VHost].VHost_SIPURL,
          '[@PHONENUMBER@]',
          p_saPhoneNumber
        ),
        '[@SIPEXTEN@]',
        Context.rJUser.JUser_SIP_Exten
      ),
      '[@SIPPASS@]',
      Context.rJUser.JUser_SIP_Pass
    );

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}Context.JThread.DBOUT(20151130125,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//==============================================================================






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
  if p_Context.bInternalJob then JASPRintln('DynamicScreen - Begin');
  ds:=TJSCREEN.create(p_Context);
  if p_Context.bInternalJob then JASPRintln('DynamicScreen - A');
  ds.bExecute;
  if p_Context.bInternalJob then JASPRintln('DynamicScreen - B');
  ds.Destroy;
  if p_Context.bInternalJob then JASPRintln('DynamicScreen - C');
  if (not p_Context.bErrorCondition) and (p_Context.CGIENV.uHTTPResponse=0) then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  end;
  if p_Context.bInternalJob then JASPRintln('DynamicScreen - End');



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
