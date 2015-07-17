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
Unit uj_menusys;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_menusys.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE CACHEJASMENU}
{$IFDEF CACHEJASMENU}
  {$INFO | CACHEJASMENU: TRUE}
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
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jado
,ug_tsfileio
,uj_context
,uj_definitions
,uj_captions
,uj_permissions
,uj_notes
,uj_user
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
// This function handles rendering and caching the global nav menu
//
// Drawing method used for GlobalNav (S-N-R <!--@JAS-MENU@-->) is method 3
// Horizontal - 2 level Tab navigation (Worked with original JAS theme)
// Horizontal - 3 TRaditional Menu Navigation
Procedure ReplaceJASMenuWithMenu(p_Context: TCONTEXT);
//=============================================================================
{}
// This routine "primes the pump" for a recursive loop that does the
// traversing thorugh the menu hierarchy.
Function bJMenuRender(
  p_Context: TCONTEXT;
  Var p_saResult: AnsiString; //< This gets the XHTML to render the menu
  Var p_saPanel: AnsiString; // This gets the XHTML to render AFTER the menu
  Var p_saMenutitle: AnsiString; // This gets the XHTML to render AFTER the menu
  p_MENUDL: JFC_DL; //< if NIL then p_Context.JMenuDL is used as the default.
  p_u8MenuID: Uint64; //< This indicates Current Location in menu to render for.
  p_u8UserID: Uint64; {< 0="Current UserID" - Normal Rendering
                      -1="Not Logged In" Rendering  for anonymous users
                      >0 = User ID to render (masquerade) for.}
  p_u8Method: UInt64; {< 0: is a FULL render but plain list
                      1: is a PATH render but plain list (Breadcrumb'ish)
                      2: is the horizontal tabbed menu with special path render
                            -all nest 1, but highlight "active" tab
                            -All Nest 2 within "ACTIVE" parent
                            -All Nest 3 & 4 within "Active parent" to render
                            panels.}
  p_u8MenuRootID: Uint64 //< Use this to control the TOP of the menu or list to render.
): Boolean;
//=============================================================================
{}
// This function Instantiates and loads the the PASSED JFC_XDL class
// with the jmenu table from the default global connection information
// loaded and assigned to gaJCon in the jcore module.
//
// Again - Call this function with a UN-INSTANTIATED JFC_XDL
// NOTE: To Properly Clean Up This JFC_XDL, Call the oppposite routine
//       bEmptyAndDestroyJMenuDL which handles the house work.
//       The house work has to do with the rtJMenu structure being
//       allocated in memory dynamically, and the pointers are
//       maintained in the JFC_XDL.Item_lpPtr.
Function bCreateAndLoadJMenuIntoDL(Var p_DL: JFC_DL; p_DBC: JADO_CONNECTION):Boolean;
//=============================================================================
{}
// NOTE: This function does Check that the passed p_DL is not NILL upon
// entry and will return false (failed) if that is the case but the nature of
// pointers in general is that if you aren't caustious and call this
// function when the class wasn't instantiated properly you will bomb out
// of the program likely. See: bCreateAndLoadJMenuIntoDL
Function bEmptyAndDestroyJMenuDL(Var p_DL: JFC_DL):Boolean;
//=============================================================================
{}
// NOTE: This Menu PATH DL is not Related to the gJMenuDL or the
// rContext.JMenuDL (copies of the master gJMenuDL), and is actually
// for storing information about the full path of a given MENU ID.
// The storage mechanism is "Use a lean JFC_DL, but typecast the
// JFC_DL.Item_lpPTR field as an LongInt, and store the JMenu_JMenu_UID's
// there.
//
// This function is recursive so it is important that the menu it's
// diciphering is correct or you get into an infinate loop.
// The menu needs to be hierarchial.
//
// You need to call this procedure with:
// p_Context structure alive and well as done by JAS when creating CGI threads.
// p_PATHDL instantiated as JFC_DL to be loaded with menu ids in lpPTR field
// p_JMenuDL either NIL (Then it uses the p_Context.JMenuDL) or a
// JFC_DL instantiated specifically by the bCreateAndLoadJMenuIntoDL function.
// p_iMenuID to begin bottom up path interrogation.
Procedure LoadJMenuPath(
  p_Context: TCONTEXT;
  Var p_PATHXDL: JFC_XDL; //< Previously Instantiated EMPTY JFC_DL
  p_MenuDL: JFC_DL; //< JMenuDL to interrogate.
  p_u8MenuID: Uint64 //< This indicates Starting point for Bottom Up Search
);
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
// NOTE: This Menu PATH DL is for storing information about the full path of a
// given MENU ID.
// The storage mechanism is placing the MenuID in Item_saValue
//
// This function is recursive so it is important that the menu it's
// diciphering is correct or you get into an infinate loop.
// The menu needs to be hierarchial.
//
// You need to call this procedure with:
//
// p_Context structure alive and well as done by JAS when creating CGI threads.
//
// p_PATHDL instantiated as JFC_DL to be loaded with menu ids in lpPTR field
//
// p_JMenuDL a JFC_DL instantiated specifically by the bCreateAndLoadJMenuIntoDL
//  function.
//
// p_iMenuID to begin bottom up path interrogation.
//
Procedure LoadJMenuPath(
  p_Context: TCONTEXT;
  Var p_PATHXDL: JFC_XDL; // Previously Instantiated EMPTY JFC_XDL
  p_MenuDL: JFC_DL; // MenuDL to interrogate.
  p_u8MenuID: Uint64 // This indicates Starting point for Bottom Up Search
);
//=============================================================================
{$IFDEF ROUTINENAMES}Var   sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='LoadJMenuPath';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102431,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102432, sTHIS_ROUTINE_NAME);{$ENDIF}
  If p_MenuDL.FoundBinary(@p_u8MenuID, SizeOf(p_u8MenuID), @rtJMenu(nil^).JMenu_JMenu_UID,True,True) Then
  Begin
    p_PATHXDL.AppendItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID));
    LoadJMenuPath(p_Context,p_PathXDL, p_MenuDL, rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenuParent_ID);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102433,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================


//=============================================================================
// This function Instantiates and loads the the PASSED JFC_XDL class
// with the jmenu table from the default global connection information
// loaded and assigned to gaJCon in the jcore module.
//
// Again - Call this function with a UN-INSTANTIATED JFC_XDL
// NOTE: To Properly Clean Up This JFC_XDL, Call the oppposite routine
//       bEmptyAndDestroyJMenuDL which handles the house work.
//       The house work has to do with the rtJMenu structure being
//       allocated in memory dynamically, and the pointers are
//       maintained in the JFC_XDL.Item_lpPtr. Note: JFC_DL could
//       have been used also -
//
Function bCreateAndLoadJMenuIntoDL(Var p_DL: JFC_DL; p_DBC: JADO_CONNECTION):Boolean;
//=============================================================================
Var
  bOk: Boolean;
  saQry: AnsiString;
  rs: JADO_RecordSet;
  rJMenu: ^rtJMenu;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bCreateAndLoadJMenuIntoDL(Var p_DL: JFC_DL):Boolean;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102434,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102435, sTHIS_ROUTINE_NAME);{ENDIF}

  //ASPrintln('C&L Menu Begin');
  bOk:=p_DL=nil;
  if not bOk then
  begin
    //ASPrintln('C&L Menu Called with non nil DL');
    JLog(cnLog_FATAL,200702131347,'bCreateAndLoadJMenuIntoDL called and the passed JFC_DL was not NIL.',SOURCEFILE);
  end;

  if bOk then
  begin
    //ASPrintln('C&L Menu Query menu table in DB');
    rs:=JADO_RECORDSET.Create;
    p_DL:=JFC_DL.Create;
    saQry:='SELECT * '+
      ' FROM jmenu '+
      ' WHERE ((JMenu_Deleted_b<>'+p_DBC.saDBMSBoolScrub(true)+')OR(JMenu_Deleted_b IS NULL)) '+
      ' ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u';
    bOk:=rs.Open(saQry, p_DBC,201503161200);
    If not bOk Then
    Begin
      JLog(cnLog_FATAL,200702131851,'bCreateAndLoadJMenuIntoDL had trouble loading menu at start up. Qry: ' +saQry,SOURCEFILE);
    End;
  End;

  If bOk Then
  Begin
    // Debug Snippet to show loaded fields in fields DL
    //if(rs.Fields.MoveFirst())then
    //begin
    //  repeat
    //    riteln(' '+ rs.Fields.Item_saName);
    //  until not rs.Fields.MoveNext();
    //end;

    If not rs.EOL Then
    Begin
      //ASPrintln('C&L Menu Reading DB Data');
      repeat
        //ASPrintln('C&L Menu About to append to DL');
        p_DL.AppendItem;

        //ASPrintln('C&L Menu About to append to getmem');
        rJMenu:= getmem(sizeof(rtJMenu));

        // Force PROPER Clearing of the structure. Failure to initialize
        // the ANSISTRING vars this way results in intermittant
        // exception errors that are a pain to chase down.
        //ASPrintln('C&L Menu Clear Menu Record Structure In Mem');
        pointer(rJMenu^.JMenu_DisplayIfNoAccess_b)        := nil;
        pointer(rJMenu^.JMenu_Title_en)                   := nil;
        pointer(rJMenu^.JMenu_IconLarge)                  := nil;
        pointer(rJMenu^.JMenu_IconSmall)                  := nil;
        pointer(rJMenu^.JMenu_IconLarge_Theme_b)          := nil;
        pointer(rJMenu^.JMenu_IconSmall_Theme_b)          := nil;
        rJMenu^.JMenu_JMenu_UID                           := 0; // This is stored as LongInt For binary Search reasons. See JMenuDL.
        rJMenu^.JMenu_JMenuParent_ID                      := 0; // This is stored as LongInt for binary search reasons. See JMenuDL.
        pointer(rJMenu^.JMenu_Data_en)                    := nil;
        pointer(rJMenu^.JMenu_JSecPerm_ID)                := nil;
        pointer(rJMenu^.JMenu_Name_en)                    := nil;
        pointer(rJMenu^.JMenu_NewWindow_b)                := nil;
        pointer(rJMenu^.JMenu_SEQ_u)                      := nil;
        pointer(rJMenu^.JMenu_URL)                        := nil;
        pointer(rJMenu^.JMenu_ValidSessionOnly_b)         := nil;
        pointer(rJMenu^.JMenu_DisplayIfValidSession_b)    := nil;
        pointer(rJMenu^.JMenu_ReadMore_b)                 := nil;

        //ASPrintln('C&L Menu Load Menu Record Structure with Data');
        rJMenu^.JMenu_DisplayIfNoAccess_b                 :=rs.Fields.Get_saValue('JMenu_DisplayIfNoAccess_b');
        rJMenu^.JMenu_Title_en                            :=rs.Fields.Get_saValue('JMenu_Title_en');
        rJMenu^.JMenu_IconLarge                           :=rs.Fields.Get_saValue('JMenu_IconLarge');
        rJMenu^.JMenu_IconSmall                           :=rs.Fields.Get_saValue('JMenu_IconSmall');
        rJMenu^.JMenu_IconLarge_Theme_b                   :=rs.Fields.Get_saValue('JMenu_IconLarge_Theme_b');
        rJMenu^.JMenu_IconSmall_Theme_b                   :=rs.Fields.Get_saValue('JMenu_IconSmall_Theme_b');
        rJMenu^.JMenu_JMenu_UID                           :=u8Val(rs.Fields.Get_saValue('JMenu_JMenu_UID'));
        rJMenu^.JMenu_JMenuParent_ID                      :=u8Val(rs.Fields.Get_saValue('JMenu_JMenuParent_ID'));
        rJMenu^.JMenu_Data_en                             :=rs.Fields.Get_saValue('JMenu_Data_en');
        rJMenu^.JMenu_JSecPerm_ID                         :=rs.Fields.Get_saValue('JMenu_JSecPerm_ID');
        rJMenu^.JMenu_Name_en                             :=rs.Fields.Get_saValue('JMenu_Name_en');
        rJMenu^.JMenu_NewWindow_b                         :=rs.Fields.Get_saValue('JMenu_NewWindow_b');
        rJMenu^.JMenu_SEQ_u                               :=rs.Fields.Get_saValue('JMenu_SEQ_u');
        rJMenu^.JMenu_URL                                 :=saSNRStr(rs.Fields.Get_saValue('JMenu_URL'),'[@MID@]','MID='+inttostr(rJMenu^.JMenu_JMenu_UID));
        rJMenu^.JMenu_ValidSessionOnly_b                  :=rs.Fields.Get_saValue('JMenu_ValidSessionOnly_b');
        rJMenu^.JMenu_DisplayIfValidSession_b             :=rs.Fields.Get_saValue('JMenu_DisplayIfValidSession_b');
        rJMenu^.JMenu_ReadMore_b                          :=rs.Fields.Get_saValue('JMenu_ReadMore_b');
        //ASPrintln('C&L Menu Assign Item Pointer with menu data structure');
        p_DL.Item_lpPtr:=rJMenu;
      Until not rs.MoveNext;
    End;
    //ASPrintln('C&L Menu Finish with Destroy of RecordSet');
    rs.Destroy;rs:=nil;
  End;
  Result:=bOk;
  //ASPrintln('C&L Menu End');
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102436,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
End;
//=============================================================================

//=============================================================================
// NOTE: This function does Check that the passed p_DL is not NILL upon
// entry and will return false (failed) if that is the case but the nature of
// pointers in general is that if you aren't caustious and call this
// function when the class wasn't instantiated properly you will bomb out
// of the program likely. See: bCreateAndLoadJMenuIntoDL
Function bEmptyAndDestroyJMenuDL(Var p_DL: JFC_DL):Boolean;
//=============================================================================
Var bSuccess: Boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bEmptyAndDestroyJMenuDL(Var p_DL: JFC_DL):Boolean;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102436,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102437, sTHIS_ROUTINE_NAME);{ENDIF}

  bSuccess:=p_DL<>nil;
  If not bSuccess Then
  Begin
    JLog(cnLog_FATAL,200702132002,'bEmptyAndDestroyJMenuDL(p_XDL) was NIL on entry.',SOURCEFILE);
  End;

  If bSuccess Then
  Begin
    While p_DL.ListCount>0 Do
    Begin
      // Frees rtJMenu record structure stored there
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_DisplayIfNoAccess_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_Title_en:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_IconLarge:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_IconSmall:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_IconLarge_Theme_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_IconSmall_Theme_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_JMenu_UID:=0;
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_JMenuParent_ID:=0;
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_Data_en:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_JSecPerm_ID:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_Name_en:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_NewWindow_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_SEQ_u:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_URL:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_ValidSessionOnly_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_DisplayIfValidSession_b:='';
      rtJMenu(JFC_DLITEM(p_DL.lpItem).lpPtr^).JMenu_ReadMore_b:='';
      freemem(JFC_DLITEM(p_DL.lpItem).lpPtr);JFC_DLITEM(p_DL.lpItem).lpPtr:=nil;
      p_DL.DeleteItem;
    End;
    p_DL.Destroy;p_DL:=nil;
  End;
  Result:=bSuccess;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102438,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
End;
//=============================================================================




//=============================================================================
Function bJMenuRecurse(
  p_Context: TCONTEXT;
  Var p_saResult: AnsiString;// HTML List Result
  Var p_saPanel: AnsiString;// Panel REsult - gets renders AFTER p_saResult
  var p_saMenuTitle: ansistring;
  p_MENUDL: JFC_DL;
  p_PATHXDL: JFC_XDL;
  p_u8UserID: Uint64;
  p_u8ParentID: Uint64;
  p_u8Method: Uint64; // 0: is a FULL render but plain list
                      // 1: is a PATH render but plain list (Breadcrumb'ish)
                      // 2: is the horizontal tabbed menu with special path render
                      //      -all nest 1, but highlight "Active" tab
                      //      -All Nest 2 within "ACTIVE" parent
                      //      -All Nest 3 & 4 within "ACTIVE parent" to render
                      //       panels.
  p_iNestLevel: Longint
):Boolean;
//=============================================================================
Var
  bSuccess: Boolean;
  iBookMark: Longint;
//  iMethod: LongInt;
  bRenderAsLink: Boolean;
  u8ParentID: Uint64;
  iNestLevel: Longint;
  saRecurse: AnsiString;
  saRecursePanel: ansistring;
  saResult: AnsiString;
  saPanel: ansistring;
//  saElement: ansistring;
//  saDefault: ansistring;
  u8FieldData: Uint64;
  bNeedPerm: Boolean;
  bHasPerm: Boolean;
  bValidSessionOnly:Boolean;
  bRender:Boolean;

  //bCaption: Boolean;
  saCaption: AnsiString;

  //bNotes:Boolean;
  //saNotes: AnsiString;

  //saTitle: AnsiString;




  bImages: Boolean;
  bHere: Boolean;
  saWrapper: AnsiString;
  saPanelWrap: ansistring;
  saLink: AnsiString;
  bDisplayIfValidSession: Boolean;
  saAnchor:ansistring;
  saMenuTitle: ansistring;
  saReadmore: ansistring;

  bHandled: boolean;
  bListClosed: boolean;//<< indicates you closed a unordered list - for example - so it doesn't need doing
  bPanelClosed: boolean;//<< indicates you closed a panel - for example - so it doesn't need doing. Panels are
  // HTML snippets that we might need to render but isn't technically a html list
  bRenderPanel: boolean;

  iCol: longint;// Count how many icons across on panel - hopefully we can wrap at 4 across

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}

const
  cnRenderMethod_Full = 0;
  cnRenderMethod_BreadCrumb = 1;
  cnRenderMethod_Stock = 2;
  cnRenderMethod_Theme = 3;


  function saLinkScrub(p_saLink: ansistring): ansistring;
  begin
    if saLeftStr(p_saLink,1)='?' then result:=grJASConfig.saServerURL+'/'+p_saLink else result:=p_saLink;
  end;



Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJMenuRecurse';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102439,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102440, sTHIS_ROUTINE_NAME);{$ENDIF}

  saMenuTitle:='';
  bSuccess:=(p_MenuDL<>nil) and (p_PathXDL <> Nil);
  //ASPrintln(' - bJMenuRecurse(p_Context: TCONTEXT;Var p_saResult: AnsiString;p_MENUDL: JFC_DL;p_PATHDL: JFC_DL;p_iUserID: LongInt;p_iParentID: LongInt;p_iMethod: LongInt;p_iNestLevel:LongInt):Boolean');
  //ASPrintln(' - p_saResult:'+p_saResult);
  //ASPrintln(' - p_UserID:'+inttostr(p_iUserID));
  //ASPrintln(' - p_iParentID:'+inttostr(p_iParentID));
  //ASPrintln(' - p_iMethod:'+inttostr(p_iMethod));
  //ASPrintln(' - p_iNestLevel:'+inttostr(p_iNestLevel));
  //ASPrintln(' - Success meaning MENUDL and PATHDL are not null:'+saTrueFalse(bSuccess));

  if(bSuccess)then
  begin
    //ASPrintln(' - p_MENUDL.listcount:'+inttostr(p_MenuDL.listcount));
    //ASPrintln(' - p_PATHDL.listcount:'+inttostr(p_PathDL.listcount));

    iNestLevel:=p_iNestLevel+1;
  //  iMethod:=0;
    bRenderAsLink:=True;
    iBookMark:=p_MENUDL.N;
    u8ParentID:=p_u8ParentID;
    saResult:='';
    saPanel:='';
    bHere:=False;
    saCaption:='';
    //saDefault:='';
    saWrapper:='';
    saPanelWrap:='';
    saLink:='#';

    iCol:=0;

    // What PARENT Group Are We Hunting?
    //saResult+='<!--bJMenuRecurse NestLevel:'+inttostr(iNestLevel)+'-->'+csCRLF;
    //saPanel+='<!--bJMenuRecurse NestLevel:'+inttostr(iNestLevel)+'-->'+csCRLF;

    //AS_Log(p_Context,cnLog_Debug,201201310213,'bJMenuRecurse - About to test if FoundBinary will Pass','',SOURCEFILE);

    // Where are We in PATHDL?
    If p_MENUDL.FoundBinary(@u8ParentID,SizeOf(u8ParentID),@rtJMenu(nil^).JMenu_JMenuParent_ID, True, True)Then
    Begin
      //AS_Log(p_Context,cnLog_Debug,201201310210,'bJMenuRecurse - FoundBinary Passed','',SOURCEFILE);
      repeat
        bRenderPanel:=true;

        // SECURITY -------------------------------------BEGIN
        // Logic To Decide IF to Render
        u8FieldData:=u8Val(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JSecPerm_ID);
        bNeedPerm:=not (u8FieldData=0);
        If bNeedPerm Then
        Begin
          bHasPerm:=bJAS_HasPermission(p_Context,u8FieldData);
          bSuccess:=(p_Context.bErrorCondition=false);
        End
        Else
        Begin
          bValidSessionOnly:=bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_ValidSessionOnly_b);
        End;

        bDisplayIfValidSession:=bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_DisplayIfValidSession_b);
        bRenderAsLink:=(bNeedPerm and bHasPerm) OR
                 ((not bNeedPerm) and bValidSessionOnly and p_Context.bSessionValid) OR
                 ((not bNeedPerm) and (not bValidSessionOnly));

        bRender:=bRenderAsLink OR bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_DisplayIfNoAccess_b);
        If p_Context.bSessionValid Then
        Begin
          bRender:=bRender and bDisplayIfValidSession;
        End;
        if (p_u8Method = cnRenderMethod_Theme) and (not bRenderAsLink ) then bRender:=false;
        
        // SECURITY -------------------------------------END

        // NOTE: In PATHDL, the Item's lpPtr field contains UID's of the menu, not actual pointers.
        bHere:=p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenu_UID));

        //if bHere then
        //begin
        //  ASPrintLn('MID HEre: ' + inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenu_UID));
        //end
        //else
        //begin
        //  ASPrintLn('MID Not Here: ' + inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenu_UID));
        //end;

        // METHOD
        //bCaption:=True; // Pretty much always
        Case p_u8Method Of
        cnRenderMethod_FULL: Begin
          //bRender:=bRender;
          //bNotes:=False;
          bImages:=False;
        End;//case
        cnRenderMethod_BreadCrumb: Begin
          bRender:=bRender and bHere;
          //bNotes:=False;
          bImages:=False;
        End;//case
        cnRenderMethod_Stock: Begin
          Case iNestLevel Of
          1: Begin//case
            // bRender:=bRender;
            //bNotes:=False;
            bImages:=False;
          End;//case
          2: Begin
            //bRender:=brender and bHere;
            bRender:=bRender and p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            //bNotes:=False;
            bImages:=False;
          End;//case
          3: Begin
            // need logic here to see if Parent is Parent "ACTIVE" to
            // get multiple panels. For Now - Do Breadcrumb'ish style

            // BEGIN ---ORIGINAL
            // bRender:=brender and bHere;
            // bRenderAsLink:=False;
            // bNotes:=True;
            // bImages:=True;
            // END ---ORIGINAL
            bRender:=bRender and p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRenderPanel:=bRender and p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRenderAsLink:=true;
            //bNotes:=true;
            bImages:=true;
          End;//case
          4: Begin
            // need logic here to see if Parent is Parent "ACTIVE" to
            // get multiple panels. For Now - Do Breadcrumb'ish style
            bRenderPanel:=true;//p_PATHDL.FoundItem_lpPtr(pointer(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRender:=bRender;// and bHere;
            bRenderAsLink:=true;
            //bNotes:=true;
            bImages:=true;
          End;//case
          end;//switch
        end;//case

        cnRenderMethod_Theme: Begin
          Case iNestLevel Of
          1: Begin
            // bRender:=bRender;
            //bNotes:=False;
            bImages:=False;
          End;//case
          2: Begin
            //bRender:=brender and bHere;
            bRenderPanel:=p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRender:=bRender;// and p_PATHDL.FoundItem_lpPtr(pointer(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            //bNotes:=False;
            bImages:=False;
          End;//case
          3: Begin
            // need logic here to see if Parent is Parent "ACTIVE" to
            // get multiple panels. For Now - Do Breadcrumb'ish style

            // BEGIN ---ORIGINAL
            // bRender:=brender and bHere;
            // bRenderAsLink:=False;
            // bNotes:=True;
            // bImages:=True;
            // END ---ORIGINAL
            bRenderPanel:=p_PATHXDL.FoundItem_saValue(inttostr(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRender:=bRender;// and p_PATHDL.FoundItem_lpPtr(pointer(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            bRenderAsLink:=bRenderAsLink;
            //bNotes:=true;
            bImages:=true;
          End;//case
          4: Begin
            // need logic here to see if Parent is Parent "ACTIVE" to
            // get multiple panels. For Now - Do Breadcrumb'ish style
            bRenderPanel:=true;//p_PATHDL.FoundItem_lpPtr(pointer(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
            // BEGIN ---ORIGINAL
            // bRender:=brender and bHere;
            // bRenderAsLink:=True;
            // bNotes:=True;
            // bImages:=True;
            // END ---ORIGINAL
            bRender:=bRender;
            bRenderAsLink:=bRenderAsLink;
            //bNotes:=true;
            bImages:=true;
          End;//case
          Else Begin
            bRender:=False;
            //bRenderPanel:=p_PATHDL.FoundItem_lpPtr(pointer(rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));
          End;//case
          End;//switch
        End;//case
        Else Begin
          bRender:=True;
          // FLAGS To allow database look ups
          //bCaption:=True;
          //bNotes:=False;
          bImages:=False;// Set to True for either small icon or big - if to be displayed
        End;//case
        End;//switch


        If bRender Then
        Begin
          // DEFAULTS----------------------------------------------------------BEGIN
          // CAPTION DEFAULT
          If (not bNeedPerm) OR (bHasPerm) Then
          Begin
            saCaption:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Name_en;
          End
          Else
          Begin
            saCaption:='NO ACCESS';// Make Multi-Language caption based if need arises.
          End;

          // Image ALT text default
          //saTitle:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en;
          // DEFAULTS----------------------------------------------------------END


          // CAPTION------------------------------------------BEGIN
          if bHere then
          begin
            p_saMenuTitle:='<script>document.title="'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Name_en+'";</script>'+
              '<!--PAGETITLE "'+saCaption+'"-->';
              //'<!--MENUTITLE "'+saCaption+'"-->'+
            //p_Context.PageSNRXDL.AppendItem_saName_N_saValue('JASMENUCAPTION',saCaption);
            // was going to add this here but... doesn't help in a cached system.
          end;
          // CAPTION------------------------------------------END


          // NOTES------------------------------------------BEGIN
          If bSuccess Then
          Begin
            //bNotes:=True;
          End;
          // NOTES------------------------------------------END

          // IMAGES ALT TEXT ------------------------------------------BEGIN
          If bSuccess Then
          Begin
            // this determines whether or not to load the ALT text from the database
            If bImages Then
            Begin
              //bSuccess:=bJASCaption(p_Context, rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconAltText_JCaption_ID, saImgAltTextCaption, saImgAltTextCaption);
            End;
          End;
          // IMAGES ALT TEXT ------------------------------------------BEGIN



          // FIRST PART OF ELEMENT-----BEGIN
          bHandled:=false;
          bListClosed:=false;//<< indicates you closed a unordered list - for example - so it doesn't need doing
          bPanelClosed:=false;//<< indicates you closed a panel - for example - so it doesn't need doing. Panels are
          case p_u8Method of
          cnRenderMethod_Full: begin
          end;//case
          cnRenderMethod_BreadCrumb: begin
          end;//case
          cnRenderMethod_Stock: begin
            case iNestLevel of
            3: begin
              bHandled:=true;
              if bRenderPanel then
              begin
                // PANEL Header
                saAnchor:='';
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL))>0 Then
                Begin
                  saLink:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL;
                End
                Else
                Begin
                  saLink:='#';
                  bRenderAsLink:=false;
                  // TODO: Make system Link function
                  //saLink:='?MID='+inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID);
                  //if p_Context.bSessionValid then
                  //begin
                  //  saLink+='&amp;JSID='+p_Context.saSessionID;
                  //end;
                End;

                If bRenderAsLink Then
                Begin
                  saAnchor+='<a href="'+saLinkScrub(saLink)+'"';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_NewWindow_b) then
                  begin
                    saAnchor+=' target="_blank"';
                  end;
                  saAnchor+=' title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" >';
                End;

                saPanel+='<div class="panel" align="left">'+csCRLF;
                saPanel+='  <div class="panelheader"><table><tr><td valign="middle">';
                If bRenderAsLink Then
                Begin
                  saPanel+=saAnchor;
                end;

                // Favor SMALLER Icon
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall))>0 Then
                begin
                  saPanel+='<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall_Theme_b)then  saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                end else

                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge))>0 Then
                begin
                  saPanel+='<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge_Theme_b)then  saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                end;

                If bRenderAsLink Then
                Begin
                  saPanel+='</a>';
                End;
                saPanel+='</td><td valign="middle">';
                If bRenderAsLink Then
                Begin
                  saPanel+=saAnchor;
                end;
                saPanel+='<h1>'+saCaption+'</h1>';
                If bRenderAsLink Then
                Begin
                  saPanel+='</a>';
                End;
                saPanel+='</td></tr></table></div>'+csCRLF;
                saPanel+='  <div class="panelcontent">'+csCRLF;
                if length(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en)>0 then
                begin
                  saPanel+='<p>'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+'</p>';
                end;
                saPanel+='    <div class="jasbigbutton">'+csCRLF;
                saPanel+='      <ul>'+csCRLF;
              end;
              //Log(cnLog_DEBUG,201002250044,'PanelShell:'+saPanel,SOURCEFILE);
            end;//case

            4: begin
              bHandled:=true;
              if bRenderPanel then
              begin
                // PANEL ICONS
                saAnchor:='';
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL))>0 Then
                Begin
                  saLink:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL;
                End
                Else
                Begin
                  saLink:='#';
                  bRenderAsLink:=false;
                  // TODO: Make system Link function
                  //saLink:='?MID='+inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID);
                  //if p_Context.bSessionValid then
                  //begin
                  //  saLink+='&amp;JSID='+p_Context.saSessionID;
                  //end;
                End;
                If bRenderAsLink Then
                Begin
                  saAnchor+='<a href="'+saLinkScrub(saLink)+'"';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_NewWindow_b) then
                  begin
                    saAnchor+=' target="_blank"';
                  end;
                  saAnchor+='>';
                End;


                saPanel+='<li><table align="left" width="300px"><tr><td rowspan="2" valign="top" align="left" width="66px">';
                If bRenderAsLink Then
                Begin
                  saPanel+=saAnchor;
                end;

                // FAVOR Large Icon
                if length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge))>0 then
                begin
                  saPanel+='<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge_Theme_b) then saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                end
                else
                begin
                  If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall))>0 Then
                  begin
                    saPanel+='<img class="image" src="<? echo $JASDIRICON';
                    if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall_Theme_b) then saPanel+='THEME';
                    saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                  end
                  else
                  begin
                    saPanel+='<img class="image" src="<? echo $JASDIRWEBSHARE; ?><? echo $JASTHEME; ?>/images/postheadericon.png" width="26" height="26" alt="postheadericon" />'+csCRLF;
                  end;
                end;

                If bRenderAsLink Then
                Begin
                  saPanel+='</a>';
                End;
                saPanel+='</td><td valign="top" align="left">';
                If bRenderAsLink Then
                Begin
                  saPanel+=saAnchor;
                end;
                saPanel+=saCaption;
                If bRenderAsLink Then
                Begin
                  saPanel+='</a>';
                End;
                if (length(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en)<=128) or (false = bVAL(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_ReadMore_b)) then
                begin
                  saPanel+='</td></tr><tr><td valign="top" align="left"><p>'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+'</p></td></tr>';
                end
                else
                begin
                  saReadMore:='<script>function readmore'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="none";};'+
                               'function hiderm'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="none";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="";};</script>'+
                    '<div class="menureadmore" id="rmdiv'+inttostr(p_MENUDL.N)+'" style="display: none;overflow: show;">'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+
                      '<a onclick="hiderm'+inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to hide information." style="position: relative;top: 10px;left: 6px;" src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-delete.png" /></a></div>';
                  saPanel+='</td></tr><tr><td valign="top" align="left"><p><div id="rmnorm'+inttostr(p_MENUDL.N)+'" >'+LeftStr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en,128)+'<a title="Click to read more information." onclick="readmore'+
                  inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to read more." style="position: relative;top: 10px;left: 6px;"  src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-add.png" /></a></div>'+saReadMore+'</p></td></tr>';
                end;

                {  this will make extra admin edit menu item link that shows in overflow panels.
                saPanel+='<tr><td><a title="Edit Menu Item" target="_blank" href="?screen=jmenu%20Data&UID='+
                  inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID)+
                  '" /><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/document-edit.png" /></a>'+
                  '</td></tr>';
                }
                saPanel+='</table>';
              end;//case
              end;//switch
            end;
          end;//case






          cnRenderMethod_Theme: begin
            case iNestLevel of
            3: begin
              if bRenderPanel then
              begin
                saPanel+=
                  '<div class="jas-layout-row jas-content">'+csCRLF+ // WAS toying with changing this cell to row - seemed promising!!!
                  '  <div class="jas-post">'+csCRLF+
                  '    <div class="jas-post-tl"></div>'+csCRLF+
                  '    <div class="jas-post-tr"></div>'+csCRLF+
                  '    <div class="jas-post-bl"></div>'+csCRLF+
                  '    <div class="jas-post-br"></div>'+csCRLF+
                  '    <div class="jas-post-tc"></div>'+csCRLF+
                  ''+csCRLF+
                  '    <div class="jas-post-bc"></div>'+csCRLF+
                  '    <div class="jas-post-cl"></div>'+csCRLF+
                  '    <div class="jas-post-cr"></div>'+csCRLF+
                  '    <div class="jas-post-cc"></div>'+csCRLF+
                  '    <div class="jas-post-body">'+csCRLF+
                  '      <div class="jas-post-inner jas-article">'+csCRLF+
                  '        <h2 class="jas-postheader">';

                // PANEL Header
                saAnchor:='';
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL))>0 Then
                Begin
                  saLink:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL;
                End
                Else
                Begin
                  saLink:='#';
                  bRenderAsLink:=true;
                  // TODO: Make system Link function
                  //saLink:='?MID='+inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID);
                  //if p_Context.bSessionValid then
                  //begin
                  //  saLink+='&amp;JSID='+p_Context.saSessionID;
                  //end;
                End;

                If bRenderAsLink Then
                Begin
                  saAnchor+='<a href="'+saLinkScrub(saLink)+'"';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_NewWindow_b) then
                  begin
                    saAnchor+=' target="_blank"';
                  end;
                  saAnchor+=' title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" >';
                End;

                If bRenderAsLink Then
                Begin
                  saPanel+=saAnchor;
                end;

                saPanel+='';
                // Favor Smaller Icon
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall))>0 Then
                begin
                  saPanel+='<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall_Theme_b)then  saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                end else

                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge))>0 Then
                begin
                  saPanel+='<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge_Theme_b)then  saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" />';
                end;

                saPanel+='&nbsp;'+saCaption;

                If bRenderAsLink Then
                Begin
                  saPanel+='</a>';
                end;

                saPanel+='</h2>';
                saPanel+=
                  '        <div class="jas-postcontent">'+csCRLF+
                  '          <!-- article-content -->'+csCRLF;

                if (length(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en)<=128) or (false = bVAL(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_ReadMore_b)) then
                begin
                  saPanel+='          <p>'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+'</p>'+csCRLF
                end
                else
                begin
                  //saPanel+='          <p>Readmore here</p>'+csCRLF;
                  saReadMore:='<script>function readmore'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="none";};'+
                               'function hiderm'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="none";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="";};</script>'+
                    '<div class="menureadmore" id="rmdiv'+inttostr(p_MENUDL.N)+'" style="display: none;overflow: show;">'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+
                      '<a onclick="hiderm'+inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to hide information." style="position: relative;top: 10px;left: 6px;" src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-delete.png" /></a></div>';
                  saPanel+='<p><div id="rmnorm'+inttostr(p_MENUDL.N)+'" >'+LeftStr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en,128)+'<a title="Click to read more information." onclick="readmore'+
                  inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to read more." style="position: relative;top: 10px;left: 6px;"  src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-add.png" /></a></div>'+saReadMore+'</p>';
                end;

                {  Note that the HTML tags etc need to be blended nice - method 2 is table'ish
                   while this method 3 is more conventional html/css combo paradigm
                   this will make extra admin edit menu item link that shows in overflow panels.
                saPanel+='<tr><td><a title="Edit Menu Item" target="_blank" href="?screen=jmenu%20Data&UID='+
                  inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID)+
                  '" /><img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/document-edit.png" /></a>'+
                  '</td></tr>';
                }



                saPanel+=
                  '          <div class="cleared"></div>'+csCRLF+
                  '          <div class="jas-content-layout overview-table">'+csCRLF;
                  //'            <div class="jas-content-layout-row">'+csCRLF;
              end;
            end;//case
            4: begin
              // Favor Bigger Icon
              if bRenderPanel then
              begin
                iCol+=1;
                if iCol>4 then
                begin
                  iCol:=1;
                  saPanel+='</div>'+csCRLF;
                end;
                if(iCol=1)then saPanel+='<div class="jas-content-layout-row">'+csCRLF;



                saAnchor:='';
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL))>0 Then
                Begin
                  saLink:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL;
                End
                Else
                Begin
                  saLink:='#';
                  bRenderAsLink:=true;
                End;

                If bRenderAsLink Then
                Begin
                  saAnchor+='<a href="'+saLinkScrub(saLink)+'"';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_NewWindow_b) then
                  begin
                    saAnchor+=' target="_blank"';
                  end;
                  saAnchor+=' title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" >';
                End;

                saPanel+=
                  '          		<div class="jas-layout-cell">'+csCRLF+
                  '                <div class="overview-table-inner">'+csCRLF;
                  //'                  '+saAnchor+'<h4>'+saCaption+'</h4></a>'+csCRLF;
                If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge))>0 Then
                begin
                  saPanel+='          '+saAnchor+'<img class="image" src="<? echo $JASDIRICON';
                  if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge_Theme_b)then  saPanel+='THEME';
                  saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconLarge)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" /></a>';
                end
                else
                begin
                  If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall))>0 Then
                  begin
                    saPanel+='        '+saAnchor+'<img class="image" src="<? echo $JASDIRICON';
                    if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall_Theme_b)then  saPanel+='THEME';
                    saPanel+='; ?>'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_IconSmall)+'" title="'+trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Title_en)+'" /></a>';
                  end
                  else
                  begin
                    saPanel+=saAnchor+'<img src="images/01.png" width="55px" height="55px" alt="" class="image" /></a>'+csCRLF;
                  end;
                end;
                saPanel+=saAnchor+'<h4>'+saCaption+'</h4></a>';
                if (length(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en)<=128) or (false = bVAL(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_ReadMore_b)) then
                begin
                  saPanel+='          <p>'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+'</p>'+csCRLF
                end
                else
                begin
                  //saPanel+='          <p>Readmore here</p>'+csCRLF;
                  saReadMore:='<script>function readmore'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="none";};'+
                               'function hiderm'+inttostr(p_MENUDL.N)+'(){var el=document.getElementById("rmdiv'+inttostr(p_MENUDL.N)+'");el.style.display="none";el=document.getElementById("rmnorm'+inttostr(p_MENUDL.N)+'");el.style.display="";};</script>'+
                    '<div class="menureadmore" id="rmdiv'+inttostr(p_MENUDL.N)+'" style="display: none;overflow: show;">'+rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en+
                      '<a onclick="hiderm'+inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to hide information." style="position: relative;top: 10px;left: 6px;" src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-delete.png" /></a></div>';
                  saPanel+='<p><div id="rmnorm'+inttostr(p_MENUDL.N)+'" >'+LeftStr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_Data_en,128)+'<a title="Click to read more information." onclick="readmore'+
                  inttostr(p_MENUDL.N)+'();" /><img class="image" title="Click to read more." style="position: relative;top: 10px;left: 6px;"  src="<? echo $JASDIRICONTHEME; ?>32/actions/edit-add.png" /></a></div>'+saReadMore+'</p>';
                end;
              end;
            end;//case
            end;//switch
          end;//case
          end;//switch

          if not bHandled then
          begin
            // REGULAR RENDERING
            saResult+='<li>';
            If length(trim(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL))>0 Then
            Begin
              saLink:=rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_URL;
            End
            Else
            Begin
              saLink:='#';
              // TODO: Make system Link function
              //saLink:='?MID='+inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID);
              //if p_Context.bSessionValid then
              //begin
              //  saLink+='&amp;JSID='+p_Context.saSessionID;
              //end;
            End;
            //If (p_iMethod=cnRenderMethod_Stock) and (iNestLevel=1) and (not bRenderAsLink) Then
            //Begin
            //  bRenderaslink:=True;
            //  saLink:='#';
            //End;
            case p_u8Method of
            cnRenderMethod_Stock: begin
              If (iNestLevel=1) and (not bRenderAsLink) Then
              Begin
                bRenderaslink:=True;
                saLink:='#';
              End;
            end;//case
            cnRenderMethod_Theme: begin
              If (iNestLevel=1) and (not bRenderAsLink) Then
              Begin
                bRenderaslink:=True;
                saLink:='#';
              End;
            end;//case
            end;//switch

            // LEFT SIDE of ANCHOR
            If bRenderAsLink Then
            Begin
              saResult+='<a href="'+saLinkScrub(saLink)+'"';
              If bHere Then
              Begin
                saResult+=' class="active"';
              End;
              if bVal(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_NewWindow_b) then
              begin
                saResult+=' target="_blank"';
              end;
              saresult+='>';
            End;

            if (p_u8Method=cnRenderMethod_Theme) and (iNestLevel=1) then
            begin
              saResult+='<span class="l"></span><span class="r"></span><span class="t">';
            end
            else
            begin
              //saResult+='<p>p_iMethod:'+inttostr(p_iMethod)+' iNestLevel:'+inttostr(iNestLevel)+'</p>';
            end;

            // CAPTION
            If bHere Then saResult+='[';
            saResult+=saCaption;
            If bHere Then saResult+=']';

            if (p_u8Method=cnRenderMethod_Theme) and (iNestLevel=1) then
            begin
              saResult+='</span>';
            end;

            // RIGHT SIDE of ANCHOR
            If bRenderAsLink Then
            Begin
              saResult+='</a>';
            End;
          end;
          // FIRST PART OF ELEMENT-----END



          saRecurse:='';
          saRecursePanel:='';
          saMenuTitle:='';
          bSuccess:=bJMenuRecurse(
            p_Context,
            saRecurse,
            saRecursePanel,
            saMenuTitle,
            p_MenuDL,
            p_PathXDL,
            p_u8UserID,
            rtJMenu(JFC_DLITEM(p_MenuDL.lpItem).lpPtr^).JMenu_JMenu_UID,
            p_u8Method,
            iNestLevel
          );
          if (saMenuTitle<>'') then p_saMenutitle:=saMenutitle;


          bHandled:=false;
          bListClosed:=false;//<< indicates you closed a unordered list - for example - so it doesn't need doing
          bPanelClosed:=false;//<< indicates you closed a panel - for example - so it doesn't need doing. Panels are
          If bSuccess Then
          Begin
            case p_u8Method of
            cnRenderMethod_Full: begin
            end;//case
            cnRenderMethod_BreadCrumb: begin
            end;//case
            cnRenderMethod_Stock: begin
              case iNestLevel of
              3: begin
                // PANEL HEADER
                If length(saRecursePanel)>0 Then
                Begin
                  saPanel+=saRecursePanel;
                End;
                saPanel+='      </ul>'+csCRLF;
                saPanel+='    </div>'+csCRLF;
                saPanel+='  </div>'+csCRLF;
                saPanel+='</div>'+csCRLF;

                //AS_Log(p_Context,cnLog_DEBUG,201202211555,'PanelHeaderOut:'+saPanel,'',SOURCEFILE);

                bPanelClosed:=true;
              end;//case
              4: begin
                // PANEL ICONS
                If length(saRecursePanel)>0 Then
                Begin
                  saPanel+=saRecursePanel;
                End;
                saPanel+='</li>'+csCRLF;
                bPanelClosed:=true;
                //Log(cnLog_DEBUG,201202211556,'PanelIconsOut:'+saPanel,SOURCEFILE);
              end;//case
              end;//switch
            end;//case
            cnRenderMethod_Theme: begin
              case iNestLevel of
              3: begin
                // PANEL HEADER
                if bRenderPanel then
                begin
                  If length(saRecursePanel)>0 Then
                  Begin
                    saPanel+=saRecursePanel;
                  End;
                  saPanel+=
                    '           </div><!-- end row -->'+csCRLF+
                    '          </div><!-- end table -->'+csCRLF+
                    '          <!-- /article-content -->'+csCRLF+
                    '        </div>'+csCRLF+
                    '        <div clas="cleared"></div>'+csCRLF+
                    '      </div>'+csCRLF+
                    '      <div class="cleared"></div>'+csCRLF+
                    '    </div>'+csCRLF+
                    '  </div>'+csCRLF+
                    '</div><br />'+csCRLF;
                end;
                //Log(cnLog_DEBUG,201202211557,'PanelHeaderOut:'+saPanel,SOURCEFILE);
                bPanelClosed:=true;
              end;//case
              4: begin
                if bRenderPanel then
                begin
                  // PANEL ICONS
                  If length(saRecursePanel)>0 Then
                  Begin
                    saPanel+=saRecursePanel;
                  End;
                  saPanel+='                 </div>'+csCRLF;
                  saPanel+='          		</div><!-- end cell -->'+csCRLF;
                  //Log(cnLog_DEBUG,201202211558,'PanelIconsOut:'+saPanel,SOURCEFILE);
                end;
                bPanelClosed:=true;
              end;//case
              end;//switch
            end;//case
            end;//switch
          end;//if bSuccess

          if not bListClosed then
          begin
            If length(saRecurse)>0 Then
            Begin
              saResult+=saRecurse;
            End;
            saResult+='</li>'+csCRLF;
          end;
          if not bPanelClosed then
          begin
            // REGULAR RENDERING
            saPanel+=saRecursePanel;
          end;
        End;
      Until (not p_MENUDL.FoundBinary(@u8ParentID, SizeOf(u8ParentID), @rtJMenu(nil^).JMenu_JMenuParent_ID, False, True)) OR
            (not bSuccess);

      // Here We Render the "GROUP" or <ul> in most cases
      If bSuccess Then
      Begin
        Case p_u8Method Of
        cnRenderMethod_Full:       if length(saResult)>0 then saWrapper+='<ul>'+saResult+'</ul>';
        cnRenderMethod_BreadCrumb: if length(saResult)>0 then saWrapper+='<ul>'+saResult+'</ul>';
        cnRenderMethod_Stock: Begin
          Case iNestLevel Of
          1: Begin
            if length(saResult)>0 then saWrapper+='<ul class="jas-menu">'+saResult+'</ul>';
            saPanelWrap:=saPanel;
          End;
          2: Begin
            if length(saResult)>0 then saWrapper+='<ul>'+saResult+'</ul>';
            saPanelWrap:=saPanel;
          End;
          3: Begin
            saPanelWrap:=''+saPanel+'';
            //AS_Log(p_Context,cnLog_DEBUG,201202211559,'PanelWrap nest3:'+saPanelWrap,'',SOURCEFILE);
          End;
          4: Begin
            saPanelWrap:=''+saPanel+'';
            //AS_Log(p_Context,cnLog_DEBUG,201202211600,'PanelWrap nest4:'+saPanelWrap,'',SOURCEFILE);
          End;//case
          end;//switch
        end;//case
        cnRenderMethod_Theme: Begin
          if length(saResult)>0 then
          begin
            if iNestLevel=1 then
            begin
               saWrapper+='<ul class="jas-menu">'+saResult+'</ul>';
            end
            else
            begin
              saWrapper+='<ul>'+saResult+'</ul>';
            end;
          end;

          Case iNestLevel Of
          1: Begin
            saPanelWrap:=saPanel;
          End;
          2: Begin
            saPanelWrap:=saPanel;
          End;
          3: Begin
            if bRenderPanel then
            begin
              saPanelWrap:=''+saPanel+'';
            end;
            //AS_Log(p_Context,cnLog_DEBUG,201202211601,'PanelWrap nest3:'+saPanelWrap,'',SOURCEFILE);
          End;
          4: Begin
            if bRenderPanel then
            begin
              saPanelWrap:=''+saPanel+'';
            end;
            //AS_Log(p_Context,cnLog_DEBUG,201202211602,'PanelWrap nest4:'+saPanelWrap,'',SOURCEFILE);
          End;
          End;//switch
        End;//case
        End;//switch
      End;
      If bSuccess Then
      Begin
        p_saResult:=saWrapper;
        p_saPanel:=saPanelWrap;
        //AS_Log(
        //  p_Context,
        //  cnLog_DEBUG,
        //  201202211603,
        //  'Leaving bJMenuRecurse:'+p_saPanel+' MID:'+inttostr(rtJMenu(JFC_DLITEM(p_MENUDL.lpItem).lpPtr^).JMenu_JMenu_UID)+' NestLevel:'+inttostr(iNestLevel),
        //  '',
        //  SOURCEFILE
        //);
      End;
    End;
    p_MenuDL.FoundNth(iBookMark);
    //AS_Log(p_Context,cnLog_Debug,201201310211,'bJMenuRecurse - Result: '+p_saResult+' Panel: '+p_saPanel,'',SOURCEFILE);
  end;
  Result:=bSuccess;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102441,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================














//=============================================================================
// This routine "primes the pump" for a recursive loop that does the
// traversing thorugh the menu hierarchy.
Function bJMenuRender(
  p_Context: TCONTEXT;
  Var p_saResult: AnsiString; // This gets the XHTML to render the menu
  Var p_saPanel: AnsiString; // This gets the XHTML to render AFTER the menu
  Var p_saMenuTitle: ansistring;//used to attempt to create menu sensitive Page Title to make system easier to use in the browser by labeling tabs correctly.
  p_MENUDL: JFC_DL; 
  p_u8MenuID: UInt64; // This indicates Current Location in menu to render for.
  p_u8UserID: Uint64; // 0="Current UserID" - Normal Rendering
                      // -1="Not Logged In" Rendering  for anonymous users
                      // >0 = User ID to render (masquerade) for.
  p_u8Method: Uint64; // 0: is a FULL render but plain list
                      // 1: is a PATH render but plain list (Breadcrumb'ish)
                      // 2: is the horizontal tabbed menu with special path render
                      //      -all nest 1, but highlight "active" tab
                      //      -All Nest 2 within "ACTIVE" parent
                      //      -All Nest 3 & 4 within "ACTIVE parent" to render
                      //       panels.
  p_u8MenuRootID: Uint64 // Use this to control the TOP of the menu or list
    // to render.
): Boolean;
//=============================================================================
Var
  bSuccess:Boolean;
  PATHXDL: JFC_XDL;
  u8ParentID: UInt64;
  saWorkArea: AnsiString;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJMenuRender';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102442,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102443, sTHIS_ROUTINE_NAME);{$ENDIF}

  bSuccess:=True;
  p_saResult:='';
  p_saPanel:='';
  saWorkArea:=csCRLF;
  saWorkArea+=csCRLF;
  //saWorkArea+='<div class="jmenu">'+csCRLF;
  saWorkArea+='<!--JEGAS MENU RENDERER START-->'+csCRLF;
  saWorkArea+='<!--JEGAS MENU ID: '+inttostr(p_u8MenuID)+'-->'+csCRLF;
  saWorkArea+='<!--JEGAS USER ID: '+inttostr(p_u8UserID)+'-->'+csCRLF;

  // Load the Menu Path
  PATHXDL:=JFC_XDL.Create;
  LoadJMenuPath(p_Context, PATHXDL, p_MENUDL, p_u8MenuID);
  saWorkArea+='<!--JEGAS PATHDL.ListCount:'+inttostr(PATHXDL.ListCount)+'-->'+csCRLF;

  u8ParentID:=p_u8MenuRootID;
  saWorkArea+='<!--JEGAS Initial MENU PARENT ID to Traverse:'+inttostr(u8ParentID)+'-->'+csCRLF;
  //ASPrintln(' bJMenuRecurse(p_Context, p_saResult, MENUDL, PATHDL, p_iUserID, p_iMethod, 0)');
  //ASPrintln(' bJMenuRecurse(p_Context, p_saResult, MENUDL, PATHDL, '+inttostr(p_iUserID)+', '+inttostr(p_iMethod)+', 0)');
  If bJMenuRecurse(p_Context, p_saResult, p_saPanel,p_saMenuTitle, p_MenuDL, PATHXDL, p_u8UserID, u8ParentID, p_u8Method, 0) Then
  Begin
    saWorkArea+=p_saResult+csCRLF;
  End;
  saWorkArea+='<!--JEGAS MENU RENDERER END-->'+csCRLF;
  p_saResult:=saWorkArea;
  PATHXDL.Destroy;
  Result:=bSuccess;
  //Log(cnLog_Debug,201202020255,'Begin: '+FormatDateTime(csDATETIMEFORMAT,dtBegin)+ 'End: '+FormatDateTime(csDATETIMEFORMAT,dtEnd),SOURCEFILE);
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102444,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





//=============================================================================
// This function handles rendering and caching the JAS-MENU
//
// Drawing method used for JAS-MENU (S-N-R <!--@JAS-MENU@-->) is method 2
// Horizontal - 2 level Tab navigation
Procedure ReplaceJASMenuWithMenu(p_Context: TCONTEXT);
//=============================================================================
Var
  bGotMenu: Boolean;
  u8MenuID: Uint64;
  bMenuRenderSuccessful: Boolean;
  saRenderedMenu: AnsiString;
  saRenderedPanel: ansistring;
  MenuDL: JFC_DL;


  {$IFDEF CACHEJASMENU }
  saFinalDestination: AnsiString;
  saFinalDestination2: AnsiString;
  saPath: AnsiString;
  u2IOResult: Word;
  saCacheFilename: AnsiString;
  //saRelPath: ansistring;
  {$ENDIF}
  saMenuTitle: ansistring;
  sa: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='ReplaceJASMenuWithMenu(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102445,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102446, sTHIS_ROUTINE_NAME);{$ENDIF}

  //asdebugprintln('Entering replaceJASMenuWithMenu. vhost: ' + inttostr(p_Context.i4VHost));
  
  saMenuTitle:='';
  MenuDL:=JFC_DL.CreateCopy(garJVHostLight[p_Context.i4VHost].MenuDL);
  //asDebugPrintLn('Got Menu request for vhost: '+inttostr(p_Context.i4VHost));  
 
  // MENU RELATED
  bGotMenu:=p_Context.CGIENV.DataIn.FoundItem_saName('MID',False);
  If bGotMenu Then
  Begin
    u8MenuID:=u8Val(p_Context.CGIENV.DataIn.Item_saValue);
  End
  Else
  Begin
    u8MenuID:=grJASConfig.u8DefaultTop_JMenu_ID;
  End;
  if p_Context.u8MenuTopID=0 then p_Context.u8MenuTopID:=grJASConfig.u8DefaultTop_JMenu_ID;
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@MT@]','MT='+inttostr(p_Context.u8MenuTopID));
  //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@MID@]','&MID='+inttostr(u8MenuID));
  //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@HERE@]','MT='+inttostr(p_Context.u8MenuTopID)+'&MID='+inttostr(u8MenuID));



  {$IFDEF CACHEJASMENU }
  saPath:=saJASGetUserCacheDir(p_Context,inttostR(p_Context.rJUser.JUser_JUser_UID));
  saCacheFileName:=p_Context.saLang+'_MT' + inttostr(p_Context.u8MenuTopID)+'_MID'+inttostr(u8MenuID)+'_USER'+inttostr(p_Context.rJUser.JUser_JUser_UID);
  saFinalDestination:=saPath+saCacheFileName+'_menu'+csJASFileExt;
  saFinalDestination2:=saPath+saCacheFileName+'_panel'+csJASFileExt;
  
  If not ((FileExists(saFinalDestination)) and (FileExists(saFinalDestination2))) Then
  Begin
    u2IOResult:=0;//shutup compiler
    u2IOResult:=u2IOResult;//shutup compiler
    CreateDir(saPath);
  {$ENDIF}
    
    bMenuRenderSuccessful:=bJMenuRender(
      p_Context,
      saRenderedMenu,
      saRenderedPanel,
      saMenuTitle,
      MenuDL,
      u8MenuID,
      p_Context.rJuser.JUser_JUser_UID,
      garJVHostLight[p_Context.i4Vhost].u1MenuRenderMethod,//3, // grJASConfig.u8DefaultThemeRenderMethod
      p_Context.u8MenuTopID
    );
    If bMenuRenderSuccessful Then
    Begin
      saRenderedMenu:=saMenutitle+saRenderedMenu;

      // CACHE IT
      {$IFDEF CACHEJASMENU}
      bMenuRenderSuccessful := bTSIOAppend(saFinalDestination, saRenderedMenu,u2IOResult);
      If not bMenuRenderSuccessful Then
      Begin
        JAS_Log(p_Context,cnLog_ERROR,200702210057,'Menu didn''t get stored correctly. CACHEFILENAME:'+saCacheFilename+
          ' Destination:'+saFinalDestination,'',SOURCEFILE);
      End;
      
      If bMenuRenderSuccessful Then
      begin
        bMenuRenderSuccessful := bTSIOAppend(saFinalDestination2, saRenderedPanel,u2IOResult);
        If not bMenuRenderSuccessful Then
        Begin
          JAS_Log(p_Context,cnLog_ERROR,200702210058,'Panel(s) didn''t get stored correctly. CACHEFILENAME:'+saCacheFilename+
            ' Destination:'+saFinalDestination2,'',SOURCEFILE);
        End;
      end;
      {$ENDIF}
    End
    Else
    Begin
      JAS_Log(p_Context, cnLog_ERROR,200702210056,'Menu didn''t render correctly.','',SOURCEFILE);
    End;
  {$IFDEF CACHEJASMENU}
  End
  Else
  Begin
    //bMenuRenderSuccessful:=bLoadTextFile(saFinalDestination, saRenderedMenu, u2IOREsult);
    bMenuRenderSuccessful := bTSLoadEntireFile(saFinalDestination, u2IOREsult, saRenderedMenu) and bTSLoadEntireFile(saFinalDestination2, u2IOREsult, saRenderedPanel);
    //JASPrintln('USED MENU CACHE! YAY');
  End;
  {$ENDIF}

  If bMenuRenderSuccessful Then
  Begin
    //saRenderedMenu:=saSNRStr(grJASConfig.saMenuTemplate,'<!--@JAS-MENU-INSERT@-->',saRenderedMenu);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('<!--@JAS-MENU@-->','<!--JAS-MENU BEGIN-->'+saRenderedMenu+'<!--JAS-MENU END-->');
    p_Context.PAGESNRXDL.AppendItem_SNRPair('<!--@PANELS@-->','<!--PANELS BEGIN-->'+saRenderedPanel+'<!--PANELS END-->');
    p_COntext.bMenuHasPanels:=length(saRenderedPanel)>0;
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JASHASPANELS@]',TRIM(UPPERCASE(saTRueFalse(p_Context.bMenuHasPanels))));
    //AS_Log(p_Context,cnLog_DEBUG,201001151842,'Global NAV (saRenderedMenu):'+saRenderedMenu,'',SOURCEFILE);
    //AS_Log(p_Context,cnLog_DEBUG,201001151842,'Panels (saRenderedPanel):'+saRenderedPanel,'',SOURCEFILE);
    //rContext.PAGESNRXDL.AppendItem_SNRPair('<!--@JAS-  MENU@-->',saGetPage(rcontext, 'htmlripper', 'menu_htab_3_0','',true));
  End
  Else
  Begin
    {$IFDEF CACHEJASMENU}sa:=saFinalDestination;{$ELSE}sa:='';{$ENDIF}
    p_Context.PAGESNRXDL.AppendItem_SNRPair('<!--@JAS-MENU@-->','<p>Problem Loading JAS-MENU - '+sa+'</p>');
    {$IFDEF CACHEJASMENU}sa:=saFinalDestination2;{$ELSE}sa:='';{$ENDIF}
    p_Context.PAGESNRXDL.AppendItem_SNRPair('<!--@PANELS@-->','<p>problem loading PANELS(s) - '+sa+'</p>');
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JASHASPANELS@]','FALSE');
  End;
  MenuDL.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102447,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
