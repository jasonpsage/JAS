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
// JAS Menu Editor
Unit uj_menueditor;
//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_menueditor.pp'}
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
  {$INFO | DEBUGTHREADBEGINEND: TRUE}
{$ENDIF}


{DEFINE DIAGMSG}
{$IFDEF DIAGMSG}
  {$INFO | DIAGMSG: TRUE}
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
,dos
,syncobjs
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_xml
,ug_tsfileio
,ug_jado
,uj_definitions
,uj_context
,uj_locking
,uj_tables_loadsave
,uj_notes
,uj_captions
,uj_permissions
,uj_fileserv
,uj_ui_stock
;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations
//*****************************************************************************
//=============================================================================
//*****************************************************************************

{}
// This is how you invoke the JAS menu editor
procedure JAS_MenuEditor(p_Context: TCONTEXT);
{}
// Imports a JAS Menu to the Main Root Node or a selected node based on
// input passed from the client. (CGIENV.DATAIN)
procedure JAS_MenuImport(p_Context: TCONTEXT);
{}
// Exports a JAS Menu from any level.
procedure JAS_MenuExport(p_Context: TCONTEXT);
{}
// Returns XML of JMenu starting at node specified in Menu ID parameter
// named p_saMID
function saRenderMenuAsXML(p_Context: TCONTEXT; p_u8MenuID: uint64): ansistring;






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
function saLoadTree(
  p_Context: TCONTEXT;
  p_u8ParentID: uint64
): ansistring;
//=============================================================================
var
  bOk: boolean;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  sa: ansistring;
  bHasChildren: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saLoadTree(p_Context:TCONTEXT;p_u8ParentID:ansistring): ansistring;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102409,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102410, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:='';
  if p_Context.bErrorCondition then exit;

  bOk:=true;
  sa:='';

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=nil;
  //bFirst:= True;
  saQry:= 'select * from jmenu where '+
    'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' and '+
    'JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(p_u8ParentID) + ' order by JMenu_SEQ_u';
  bOk:=rs.Open(saQry, DBC,201503161500);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201004112231, 'saLoadTree function is having trouble loading Menu Items','Query: '+saQry,SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    If (rs.EOL=falsE) Then
    begin
      repeat
        bHasChildren:=false;
        saQry:='select count(*) as MyCount from jmenu '+
          'where JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(rs.Fields.Get_saValue('JMenu_JMenu_UID'))+' and '+
          'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
        rs2:=JADO_RECORDSET.Create;
        bOk:=rs2.Open(saQry,DBC,201503161501);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error, 201004112246, 'saLoadTree function is having trouble counting children Menu Items','Query: '+saQry,SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;
        if bOk then
        begin
          bHasChildren:=(iVal(rs2.Fields.Get_saValue('MyCount'))>0);
        end;
        rs2.close;
        rs2.Destroy;
        rs2:=nil;

        //p_Context.saPage+='         aux1 = insFld(foldersTree, gFld("Flags", "[@ALIAS@].?ACTION=MenuEditor&ME=LF&NODE=1"));'+csCRLF;
        //p_Context.saPage+='         aux1.xID="1";'+csCRLF;
        //p_Context.saPage+='           aux2 = insFld(aux1, gFld("Main", "[@ALIAS@].?ACTION=MenuEditor&ME=LF&NODE=23"));'+csCRLF;
        //p_Context.saPage+='           aux2.xID="23";'+csCRLF;
        if p_u8ParentID=0 then
        begin
          if bHasChildren then
          begin
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+' = insFld(foldersTree, '+
                'gFld("'+rs.fields.get_savalue('JMenu_Name')+'", ''javascript:clickJNode("'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+
                '");''));mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.xID="'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'";'+csCRLF;
          end
          else
          begin
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+' = insFld(foldersTree, '+
                'gFld("'+rs.fields.get_savalue('JMenu_Name')+'", ''javascript:clickJNode("'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+
                '");''));mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.xID="'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'";'+csCRLF;
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.iconSrcClosed=ICONPATH + "ftv2doc.gif";'+csCRLF;
          end;
        end
        else
        begin
          if bHasChildren then
          begin
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+' = insFld(mi'+inttostr(p_u8ParentID)+', '+
                'gFld("'+rs.fields.get_savalue('JMenu_Name')+'", ''javascript:clickJNode("'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+
                '");''));mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.xID="'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'";'+csCRLF;
          end
          else
          begin
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+' = insFld(mi'+inttostr(p_u8ParentID)+', '+
                'gFld("'+rs.fields.get_savalue('JMenu_Name')+'", ''javascript:clickJNode("'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+
                '");''));mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.xID="'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'";'+csCRLF;
            sa+='mi'+rs.Fields.Get_saValue('JMenu_JMenu_UID')+'.iconSrcClosed=ICONPATH + "ftv2doc.gif";'+csCRLF;
          end;
        end;

        if bOk and bHasChildren then
        begin
          sa+=saLoadTree(p_Context, u8Val(rs.Fields.Get_saValue('JMenu_JMenu_UID')));
          bOk:= p_Context.bErrorCondition=false;
        end;

        //bFirst:= False;
      Until (bOK=false)or(not rs.MoveNext);
    End;
  end;
  rs.Close;
  rs.destroy;

  result:=sa;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102411,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================














//=============================================================================
function bCopyMenuNode(p_Context: TCONTEXT; p_u8SrcNode: uint64; p_u8DestNode: uint64): boolean;
//=============================================================================
var
  rJMenu: rtJMenu;
  saQry: ansistring;
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  //rs2: JADO_RECORDSET;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bCopyMenuNode(p_Context: TCONTEXT; p_u8SrcNode: ansistring; p_u8DestNode: ansistring): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102412,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102413, sTHIS_ROUTINE_NAME);{$ENDIF}

  rs:=JADO_RECORDSET.Create;
  //rs2:=JADO_RECORDSET.Create;
  DBC:=p_Context.VHDBC;

  // BEGIN ----------- COPY Menu Item Itself First
  rJMenu.JMenu_JMenu_UID:=p_u8SrcNode;
  bOk:=bJAS_Load_JMenu(p_Context, DBC, rJMenu,false, 20160331200);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201004151244, 'bCopyMenuNode - Unable to load jmenu via bJAS_Load_JMenu','p_u8SrcNode:'+inttostr(p_u8SrcNode),SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    with rJMenu do begin
      JMenu_JMenu_UID                  :=0; //< This is stored as integer For binary Search reasons. See JMenuDL.
      JMenu_JMenuParent_ID             :=p_u8DestNode; //< This is stored as integer for binary search reasons. See JMenuDL.
    end;//with
    //JAS_LOG(p_Context,cnLog_Debug,201203241549,'JMenu UID:'+inttostR(rJMenu.JMenu_JMenu_UID)+'  SEQ:'+rJMenu.JMenu_Seq_u,'',SOURCEFILE);
    bOk:=bJAS_Save_JMenu(p_Context, DBC, rJMenu,false,false,20160331201);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004151250, 'bCopyMenuNode - Unable to save Menu Item record via bJAS_Save_JMenu','p_u8SrcNode:'+inttostr(p_u8SrcNode)+' p_u8DestNode:'+inttostr(p_u8DestNode),SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
  // END ----------- COPY Menu Item Itself First



  // BEGIN ----------- Next this routine loads children as a recordset and calls it self to recursively copy
  if bOk then
  begin
    saQry:='select JMenu_JMenu_UID from jmenu '+
      'where JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(p_u8SrcNode)+' and '+
      'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161502);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004151252, 'bCopyMenuNode - Successfully copied current menu item but unable to query for potential children to copy.','Query: '+saQry,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (rs.eol=false)then
  begin
    repeat
      bOk:=bCopyMenuNode(p_Context, u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID')), rJMenu.JMenu_JMenu_UID);
    until (not rs.movenext) or (bOk=false);
  end;
  rs.close;
  // END   ----------- Next this routine loads children as a recordset and calls it self to recursively copy
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102414,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




















//=============================================================================
procedure JAS_MenuEditor(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  saQry: ansistring;
  saMode: ansistring;
  u8NODE: uint64;
  //saNodeOpen: ansistring;
  rJMenu: rtJMenu;
  saLoadResult: ansistring;
//  saMenuCaption: ansistring;
//  saMenuIconAltTextCaption: ansistring;
  saMenuNotes: ansistring;
  saJSecPermOptions: ansistring;

  //---ADD
//  u8CaptionUID: Uint64;
//  u8AltTextCaptionUID: Uint64;
  u8MenuWorkUID:Uint64;
  i4Children: longint;

  //---Cancel

  //---Save
  bRenderDetail: boolean;

  //---Delete
  u8MyParentID: Uint64;
  i4MyCount: longint;
  i: longint;

  //---Up
  au8UID: array of UInt64;
  ai4SEQ: array of longint;
  //i4UIDSWAP: longint;
  bSwappedItAlready: Boolean;

  //--Paste
  u8CopyNode: Uint64;

  //--Menu Export
  saMenuExport: Ansistring;
  u2IOResult: word;
  f: text;
  saFilename: ansistring;
  u2IOResult_FailSafe: word;

  DT: TDateTime;

  dir,sFile,ext: string;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_MenuEditor(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102415,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102416, sTHIS_ROUTINE_NAME);{$ENDIF}

  // Been getting this unable to validate session flash...
  // thinking we have a spot where error occurs - then is cleared - but the html
  // might be stuck or something.
  p_Context.saOut:='';
  p_Context.saPage:='';

  DT:=now;
  u8Node:=0;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  bRenderDetail:=true;
  i4MyCount:=0;
  saJSecPermOptions:='';
  p_Context.bNoWebCache:=true;
  //p_Context.saPage:=saGetPage(p_Context,'','','',false,'<h1>Menu Editor</h1><p>Not Implemented Yet.</p><a href="#" onclick="self.close()">Click here to close this window.</a><br /><br />',123020100042);

  // Function saGetPage(
  //   p_Context:tContext;
  //   //Var p_bErrorOccurred:boolean;
  //   p_saArea: AnsiString;
  //   p_saPage: AnsiString;
  //   p_saSection: AnsiString;
  //   p_bSectionOnly: Boolean;
  //   p_saCustomSection: AnsiString;
  //   p_i8Caller: int64
  // ): AnsiString;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201004092327, 'Menu Editor Not Available Unless you are logged in.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_MenuEditor);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201006211658,
        'Access Denied - You do not have "JAS Menu Editor" privilege.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;



  if bOk then
  begin
    // Make it So EACH file needed by the menu editor (main, frame left, frame right, even the javascript)
    // gets loaded through this function so the code works in a reasonable way.
    saMode:=upcase(p_Context.SessionXDL.Get_saValue('MODE'));
    p_Context.bSaveSessionData:=true;
    if p_Context.CGIENV.DataIn.FoundItem_saName('NODE') then
    begin
      if (saMode='') or (saMode='CUT') or (saMode='COPY') then
      begin
        u8Node:=u8Val(p_Context.CGIENV.DataIn.Item_saValue);
        if p_Context.SessionXDL.FoundItem_saName('NODE') then
        begin
          p_Context.SessionXDL.Item_saValue:=inttostr(u8Node);
        end
        else
        begin
          p_Context.SessionXDL.Appenditem_saName_N_saValue('NODE',inttostr(u8Node));
        end;
      end;
    end;
    if p_Context.SessionXDL.FoundItem_saName('NODE') then
    begin
      u8Node:=u8Val(p_Context.SessionXDL.Item_saValue);
    end;
  end;


  if bOk then
  begin
    if upcase(p_Context.CGIENV.DataIn.Get_saValue('ME'))='LF' then // sys_menueditor_LeftFrame.jas
    begin
      p_Context.saPage:=
        '<html>'+csCRLF+
        '  <head>'+csCRLF+
        '    <style>'+csCRLF+
        '     BODY {'+csCRLF+
        '       background-color: white;}'+csCRLF+
        '     TD {'+csCRLF+
        '       font-size: 10pt; '+csCRLF+
        '       font-family: verdana,helvetica;'+csCRLF+
        '       text-decoration: none;'+csCRLF+
        '       white-space: nowrap;}'+csCRLF+
        '     A {'+csCRLF+
        '       text-decoration: none;'+csCRLF+
        '       color: black;}'+csCRLF+
        '    </style>'+csCRLF+
        ''+csCRLF+
        '    <!-- Code for browser detection. DO NOT REMOVE.             -->'+csCRLF+
        '    <script src="<? echo $JASDIRWEBSHARE; ?>widgets/treeview/ua.js"></script>'+csCRLF+
        ''+csCRLF+
        '    <!-- Infrastructure code for the TreeView. DO NOT REMOVE.   -->'+csCRLF+
        '    <script src="<? echo $JASDIRWEBSHARE; ?>widgets/treeview/ftiens4.js"></script>'+csCRLF+
        '    <script src="<? echo $JASDIRWEBSHARE; ?>widgets/treeview/helper.js"></script>'+csCRLF+
        ''+csCRLF+
        '    <!-- Scripts that define the tree. DO NOT REMOVE.           -->'+csCRLF+
        '    <script>'+csCRLF+
        '       // Decide if the names are links or just the icons'+csCRLF+
        '       USETEXTLINKS = 1;  //replace 0 with 1 for hyperlinks'+csCRLF+csCRLF+
        '       // Decide if the tree is to start all open or just showing the root folders'+csCRLF+
        '       STARTALLOPEN = 1; //replace 0 with 1 to show the whole tree'+csCRLF+csCRLF+
        '       HIGHLIGHT = 1; '+csCRLF+
        '       ICONPATH="'+saAddSlash(garJVHost[p_COntext.u2VHost].VHost_WebShareAlias)+'widgets/treeview/";'+csCRLF+
        '       foldersTree = gFld("<b>JAS Menu Root</b>", ''javascript:clickJNode("0");'');'+csCRLF+
        '       foldersTree.treeID = "MenuTree";foldersTree.xID = "0";//root'+csCRLF+
        '       function clickJNode(p_Node){'+
        //'alert(''clickJNode(''+p_Node+'')'');'+
        '         var el=parent.basefrm.document.getElementById(''container'');'+csCRLF+
        '         el.style.filter=''alpha(opacity=50);'';'+csCRLF+
        '         el.style.opacity=''.50'';'+csCRLF+
        '         document.location.href="[@ALIAS@].?ACTION=MenuEditor&ME=LF&NODE="+p_Node+"&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";'+csCRLF+
        '       };'+csCRLF+
        '       // Begin ---- Contents ----'+csCRLF;
      saLoadresult:=saLoadTree(p_Context, 0);
      bOk:=p_Context.bErrorCondition=false;
      if bOk then
      begin
        p_Context.saPage+=
          saLoadResult+
          '       // End   ---- Contexts ----'+csCRLF+
          '    </script>'+csCRLF+
          ' </head>'+csCRLF+
          ''+csCRLF+
          '  <body topmargin="16" marginheight="16">'+csCRLF+
          '    <a style="display: none;" href="http://www.treemenu.net/"></a>'+csCRLF+
          '    <!-- Build the browser''s objects and display default view  -->'+csCRLF+
          '    <!-- of the tree.                                          -->'+csCRLF+
          '    <script>'+csCRLF+
          '      initializeDocument();'+csCRLF+
          '      var selObj=findObj("'+inttostr(u8Node)+'");'+csCRLF+
          '      highlightObjLink(selObj);'+csCRLF+
          '      // NODE:'+inttostr(u8Node)+csCRLF+
          '      // MODE:'+saMode+csCRLF+
          '      // p_Context.CGIENV.DataIn.FoundItem_saName(''NOREFRESH'')=false):'+
          sTrueFalse((p_Context.CGIENV.DataIn.FoundItem_saName('NOREFRESH')=false))+csCRLF;
        if (saMode='') or (saMode='CUT') or (saMode='COPY') then
        begin
          //p_Context.saPage+='alert(''Trying to Load Right Frame:''+parent.basefrm.location.href);'+csCRLF;
          //p_Context.saPage+='      parent.basefrm.location.href=parent.basefrm.location.href;'+csCRLF;
          p_Context.saPage+='      parent.basefrm.location.href="'+p_Context.sAlias+'.?ACTION=MenuEditor&ME=RF&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";'+csCRLF;
        end;
        p_Context.saPage+=
          '      collapseTree("0");'+csCRLF+
          '      loadSynchPage("'+inttostr(u8Node)+'");'+csCRLF+
          '    </script>'+csCRLF+
          '    <noscript>'+csCRLF+
          '      A tree for site navigation will open here if you enable JavaScript in your browser.'+csCRLF+
          '    </noscript>'+csCRLF+
          '  </body>'+csCRLF+
          '</html>'+csCRLF;
        p_Context.u2DebugMode:=cnSYS_INFO_MODE_SECURE; //prevent debug stuff being sent
      end;
    end
    else
    begin
      if upcase(p_Context.CGIENV.DataIn.Get_saValue('ME'))='RF' then // sys_menueditor_RightFrame.jas
      begin
        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='ADD' then
        begin
          if bOk then
          begin
            i4Children:=DBC.u8GetRecordCount('jmenu','JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(u8Node)+' and '+
              '((JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JMenu_Deleted_b IS NULL))',201506171762);

            // Query for the menu record
            clear_jmenu(rJMenu);
            with rJMenu do Begin
              JMenu_JMenu_UID:=0;
              JMenu_JMenuParent_ID:=u8Node;
              JMenu_JSecPerm_ID:=0;
              JMenu_Name:='Name';
              JMenu_Title_en:='Title';
              JMenu_URL:='';
              JMenu_NewWindow_b:=false;
              JMenu_IconSmall:='32/apps/utilities-terminal.png';
              JMenu_IconLarge:='64/apps/utilities-terminal.png';
              JMenu_IconSmall_Theme_b:=true;
              JMenu_IconLarge_Theme_b:=true;
              JMenu_ValidSessionOnly_b:=false;
              JMenu_SEQ_u:=i4Children+1;
              JMenu_DisplayIfNoAccess_b:=false;
              JMenu_Data_en:='';
              JMenu_DisplayIfValidSession_b:=true;
              JMenu_ReadMore_b:=true;
            end;//with

            //JAS_Log(p_Context,cnLog_Debug, 201203241538, 'JMenu UID: '+inttostr(rJMenu.JMenu_JMenu_UID)+'  Menu SEQ: '+rJMenu.JMenu_SEQ_u,'',SOURCEFILE);
            bOk:=bJAS_Save_jmenu(p_Context,DBC,rJMenu,false,false,20160331202);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004121527, 'Unable to Save New Menu Record','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
            u8MenuWorkUID:=rJMenu.JMenu_JMenu_UID;
          end;

          if bOk then
          begin
            saMode:='EDIT';
            u8Node:=u8MenuWorkUID;
            if p_Context.SessionXDL.FoundItem_saName('NODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=inttostr(u8Node);
            end
            else
            begin
              p_Context.SessionXDL.Appenditem_saName_N_saValue('NODE',inttostr(u8Node));
            end;

            if p_Context.SessionXDL.FoundItem_saName('MODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=saMode;
            end
            else
            begin
              p_Context.SessionXDL.Appenditem_saName_N_saValue('MODE',saMode);
            end;
          End;

          //if length(p_Context.saPage)=0 then
          //begin
          //  JAS_Log(p_Context,cnLog_Error, 201106270757, 'In menueditor ME=RF (Right Frame ADD) and no content but no error code? Not Good.','',SOURCEFILE);
          //  RenderHtmlErrorPage(p_Context);
          //end;
          // END -- ADD
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='SAVE' then
        begin
          // begin --- save
          clear_JMenu(rJMenu);
          rJMenu.JMenu_JMenu_UID:=u8Node;
          bOk:=bJAS_Load_JMenu(p_Context,DBC,rJMenu, false,20160331203);
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error, 201004122253, 'Trouble loading menu item from database.','',SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;

          if bOk then
          begin
            rJMenu.JMenu_JSecPerm_ID              := u8Val(p_Context.CGIENV.DataIn.Get_saValue('secperm'));
            rJMenu.JMenu_Name                  := p_Context.CGIENV.DataIn.Get_saValue('JMenu_Name');
            rJMenu.JMenu_URL                      := p_Context.CGIENV.DataIn.Get_saValue('JMenu_URL');
            rJMenu.JMenu_NewWindow_b              := (p_Context.CGIENV.DATAIN.Get_saValue('JMenu_NewWindow_b')='on');
            rJMenu.JMenu_IconSmall                := p_Context.CGIENV.DATAIN.Get_saValue('JMenu_IconSmall');
            rJMenu.JMenu_IconLarge                := p_Context.CGIENV.DATAIN.Get_saValue('JMenu_IconLarge');
            rJMenu.JMenu_IconSmall_Theme_b        := bVal(p_Context.CGIENV.DATAIN.Get_saValue('JMenu_IconSmall_Theme_b'));
            rJMenu.JMenu_IconLarge_Theme_b        := bVal(p_Context.CGIENV.DATAIN.Get_saValue('JMenu_IconLarge_Theme_b'));
            rJMenu.JMenu_Title_en                 := p_Context.CGIENV.DATAIN.Get_saValue('JMenu_Title_en');
            rJMenu.JMenu_ValidSessionOnly_b       := (p_Context.CGIENV.DATAIN.Get_saValue('JMenu_ValidSessionOnly_b')='on');
            rJMenu.JMenu_SEQ_u                    := uVal(p_Context.CGIENV.DATAIN.Get_saValue('JMenu_SEQ_u'));
            rJMenu.JMenu_DisplayIfNoAccess_b      := (p_Context.CGIENV.DATAIN.Get_saValue('JMenu_DisplayIfNoAccess_b')='on');
            rJMenu.JMenu_DisplayIfValidSession_b  := (p_Context.CGIENV.DATAIN.Get_saValue('JMenu_DisplayIfValidSession_b')='on');
            rJMenu.JMenu_ReadMore_b               := (p_Context.CGIENV.DATAIN.Get_saValue('JMenu_ReadMore_b')='on');
            rJMenu.JMenu_Data_en                  := p_Context.CGIENV.DATAIN.Get_saValue('JMenu_Data_en');
            bOk:=bJAS_Save_JMenu(p_Context, DBC, rJMenu, false, false,20160331204);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004122317, 'Unable to update jmenu record for current menu item being saved with it''s new data.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            saMode:='';
            if p_Context.SessionXDL.FoundItem_saName('MODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=saMode;
            end;

            bRenderDetail:=false;
            p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+
              inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
          end;
          // END ---- Save
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='EDIT' then
        begin
          saMode:='EDIT';
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='DELETE' then
        begin
          clear_JMenu(rJMenu);
          rJMenu.JMenu_JMenu_UID:=u8Node;
          bOk:=bJAS_Load_JMenu(p_Context, DBC, rJMenu, false,20160331205);
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error, 201004131226, 'Unable to Load Menu Item prior to delete.','',SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;

          If bOk Then
          begin
            u8MyParentID:= rJMenu.JMenu_JMenuParent_ID;
            rs.Close;
            bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jmenu',u8Node);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131237, 'Trouble removing Menu Item Record.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          End;

          // OK, Now We need to try and SEQUENCE the REMAINING records (if any) in this branch.
          If bOk Then
          begin
            saQry := 'SELECT count(JMenu_JMenu_UID) as MyCount FROM jmenu '+
              'WHERE JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(u8MyParentID)+' and '+
              'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
            rs.close;
            bOk:=rs.Open(saQry, DBC,201503161503);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131239, 'Unable to execute query needed '+
                'for the resequencing operation. This means the sequence may be off for '+
                'remaining siblings - if any exist.','Query: '+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            i4MyCount:= iVal(rs.Fields.Get_saValue('MyCount'));
            If i4MyCount > 0 Then
            begin
              saQry := 'SELECT JMenu_JMenu_UID FROM jmenu '+
                'WHERE JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(u8MyParentID) + ' and '+
                'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true) +
                ' ORDER BY JMenu_SEQ_u';
              rs.Close;
              bOk:=rs.Open(saQry, DBC,201503161504);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004131240, 'Unable to execute query '+
                  'during resequencing operation. This means the sequence may be off '+
                  'for remaining siblings - if any exist.','Query: '+saQry,SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;

              if bOk then
              begin
                For i := 1 To i4MyCount do
                begin
                  //AS_Log(p_Context,cnLog_Debug, 201203241544, 'JMenu UID:'+ rs.fields.Get_saValue('JMenu_JMenu_UID') +
                  //  '  Menu SEQ: '+p_Context.CGIENV.DATAIN.Get_saValue('JMenu_SEQ_u'),'',SOURCEFILE);
                  saQry := 'UPDATE jmenu SET '+
                    'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i) + ', '+
                    'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                    'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                    'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JMenu_JMenu_UID'))+' and '+
                    'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
                  bOk:=rs3.Open(saQry,DBC,201503161505);rs3.close;
                  if not bOk then
                  begin
                    JAS_Log(p_Context,cnLog_Error, 201004131241, 'Trouble updating sequence values.','saQry: '+saQry,SOURCEFILE);
                    RenderHtmlErrorPage(p_Context);
                    rs.Close;
                  end;
                  rs3.close;
                  if not bOk then exit;
                  rs.MoveNext;
                end;//for loop
              end;
              rs.Close;
            End;
          End;
          u8Node:=0;
          if p_Context.SessionXDL.FoundItem_saName('NODE') then
          begin
            p_Context.SessionXDL.Item_saValue:=inttostr(u8Node);
          end;

          saMode:='';
          if p_Context.SessionXDL.FoundItem_saName('MODE') then
          begin
            p_Context.SessionXDL.Item_saValue:=saMode;
          end;
          bRenderDetail:=false;
          if bOk then
          begin
            p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+
              inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
          end;
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='UP' then
        begin
          // make sure its there
          If bOk Then
          begin
            saQry := 'SELECT JMenu_JMenu_UID, JMenu_JMenuParent_ID FROM jmenu '+
              'WHERE JMenu_JMenu_UID='+DBC.sDBMSUIntScrub(u8Node)+' and '+
              ' JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
            bOk:=rs.Open(saQry, DBC,201503161506);
            If Not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131805, 'Trouble opening Menu Item Record','Query: '+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            bOk:= (rs.EOL = False);
            If Not bOk Then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131806, 'This jmenu item doesn''t really exist. You may need to refresh the page.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            End;
          End;

          // its there still
          If bOk Then
          begin
            u8MyParentID := u8Val(rs.fields.Get_saValue('JMenu_JMenuParent_ID'));
          End;
          rs.Close;

          // Are there siblings?
          If bOk Then
          begin
            i4MyCount:=DBC.u8GetRecordCount('jmenu','JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(u8MyParentID)+' and '+
              '((JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JMenu_Deleted_b IS NULL))',201506171763);
            bOk:= (i4MyCount > 1);
            If Not bOk Then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131809, 'Nothing to do. There is only '+
                'one menu item in this node. Move Item Up Sequence operation aborted.',
                'Sibling Count not greater than 1. If there aren''t siblings, then the '+
                'idea of moving a menu item up is silly.',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            End;
          End;
          rs.Close;

          // load the parts we need to swap position - all siblings uid and SEQ
          setlength(au8UID,i4MyCount + 1);// Working one based for this dilly
          setlength(ai4SEQ,i4MyCount + 1);

          If bOk Then
          begin
            saQry:='SELECT JMenu_JMenu_UID, JMenu_SEQ_u FROM jmenu '+
              'WHERE JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(u8MyParentID) + ' and '+
              'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+
              ' ORDER BY JMenu_SEQ_u';
            bOk:=rs.Open(saQry, DBC,201503161507);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131810, 'trouble querying jmenu table '+
                'during Move Item Up Sequence operation.','Query:'+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            For i:=1 To i4MyCount do
            begin
              au8UID[i] := u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID'));
              ai4SEQ[i] := iVal(rs.fields.Get_saValue('JMenu_SEQ_u'));
              rs.MoveNext;
            end;
            rs.Close;

            // Make sure they are in SEQ order starting with 1 - kind of an ongoing repair
            For i:= 1 To i4MyCount do
            begin
              //JAS_Log(p_Context,cnLog_Debug, 201203241545, 'JMenu UID:'+ inttostR(ai4UID[i]) +'  Menu SEQ: '+inttostr(i),'',SOURCEFILE);
              saQry:='UPDATE jmenu SET '+
                'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i) + ', '+
                'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i])+ ' and '+
                'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
              bOk:=rs3.Open(saQry,DBC,201503161508);rs3.close;
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004131811, 'Trouble updating new SEQUENCE '+
                  'value to Menu Item Record during Move Item Up Sequence operation.',
                  'saQry: '+saQry,SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
              rs3.close;
              if not bOk then exit;
            end;

            // is our target to move up on top already?
            If u8Node = au8UID[1] Then
            begin
              //MsgBox "Nothing to Do - its on the top of this node already."
            end
            Else
            begin
              // Swap it
              bSwappedItAlready := False;
              For i := 2 To i4MyCount do
              begin
                if bOk then
                begin
                  If Not bSwappedItAlready Then
                  begin
                    If u8Node = au8UID[i] Then
                    begin
                      bSwappedItAlready := True;
                      //AS_Log(p_Context,cnLog_Debug, 201203241546, 'JMenu UID:'+ inttostR(ai4UID[i]) +'  Menu SEQ: '+inttostr(i-1),'',SOURCEFILE);
                      saQry:= 'UPDATE jmenu SET '+
                        'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i - 1) +', '+
                        'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                        'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                        'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i]) + ' and '+
                        'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
                      bOk:=rs3.Open(saQry,DBC,201607220717);
                      if not bOk then
                      begin
                        JAS_Log(p_Context,cnLog_Error, 201004131813, 'Trouble executing querying '+
                          'swapping menu items during Move Item Up Sequence operation.',
                          'Query: '+saQry,SOURCEFILE);
                        RenderHtmlErrorPage(p_Context);
                      end;
                      rs3.close;
                      if bOk then
                      begin
                        //AS_Log(p_Context,cnLog_Debug, 201203241547, 'JMenu UID:'+ inttostR(ai4UID[i-1]) +'  Menu SEQ: '+inttostr(i),'',SOURCEFILE);
                        saQry:= 'UPDATE jmenu SET '+
                          'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i) +', '+
                          'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                          'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                          'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i - 1])+' and '+
                          'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
                        bOk:=rs3.Open(saQry,DBC,201503161510);
                        if not bOk then
                        begin
                          JAS_Log(p_Context,cnLog_Error, 201004131814, 'Trouble executing querying '+
                            'swapping menu items during Move Item Up Sequence operation.',
                            'Query: '+saQry,SOURCEFILE);
                          RenderHtmlErrorPage(p_Context);
                        end;
                      end;
                      rs3.close;
                    End;
                  End;
                end;
              end;
            End;
          End;

          saMode:='';
          if p_Context.SessionXDL.FoundItem_saName('MODE') then
          begin
            p_Context.SessionXDL.Item_saValue:=saMode;
          end;
          bRenderDetail:=false;
          if bOk then
          begin
            p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
          end;

          // Might not be necessary, as FPC may remove allocated ram from array
          // when scope is lost - but to make sure...
          setlength(au8UID,0);
          setlength(ai4SEQ,0);
        end
        else

        // NOTE: Move Item Down code is nearly identical to move item up code. I've added a TODO to the JAS
        // Mind Map to merge these two "chunks of code" to make maintaining easier. Not a priority because
        // the code works at the moment.
        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='DOWN' then
        begin
          // make sure its there
          If bOk Then
          begin
            saQry := 'SELECT JMenu_JMenu_UID, JMenu_JMenuParent_ID FROM jmenu '+
              'WHERE JMenu_JMenu_UID='+DBC.sDBMSUIntScrub(u8Node)+' and ' +
              'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
            bOk:=rs.Open(saQry, DBC,201503161511);
            If Not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131817, 'Trouble opening '+
                'Menu Item Record','Query: '+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            bOk:= (rs.EOL = False);
            If Not bOk Then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131818, 'This jmenu item doesn''t '+
                'really exist. You may need to refresh the page.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            End;
          End;

          // its there still
          If bOk Then
          begin
            u8MyParentID := u8Val(rs.fields.Get_saValue('JMenu_JMenuParent_ID'));
          End;

          // Are there siblings?
          If bOk Then
          begin
            i4MyCount:=DBC.u8GetRecordCount('jmenu','JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(u8MyParentID)+' and ' +
              '((JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JMenu_Deleted_b IS NULL))',201506171764);
            bOk:= (i4MyCount > 1);
            If Not bOk Then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131822, 'Nothing to do. There is only one '+
                'menu item in this node. Move Item Down Sequence operation aborted.','Sibling '+
                'Count not greater than 1. If there aren''t siblings, then the idea of moving '+
                'a menu item down is silly.',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            End;
          End;

          // load the parts we need to swap position - all siblings uid and SEQ
          setlength(au8UID,i4MyCount + 1);// Working one based for this dilly
          setlength(ai4SEQ,i4MyCount + 1);

          If bOk Then
          begin
            saQry:='SELECT JMenu_JMenu_UID, JMenu_SEQ_u FROM jmenu '+
              'WHERE JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(u8MyParentID)+' and '+
              'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+
              ' ORDER BY JMenu_SEQ_u';
            rs.close;
            bOk:=rs.Open(saQry, DBC,201503161512);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131823, 'Trouble querying jmenu '+
                'table during Move Item Down Sequence operation.','Query:'+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            For i:=1 To i4MyCount do
            begin
              au8UID[i] := u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID'));
              ai4SEQ[i] := iVal(rs.fields.Get_saValue('JMenu_SEQ_u'));
              rs.MoveNext;
            end;
            rs.close;

            // Make sure they are in SEQ order starting with 1 - kind of an ongoing repair
            For i:= 1 To i4MyCount do
            begin
              //AS_Log(p_Context,cnLog_Debug, 201203241548, 'JMenu UID:'+ inttostR(ai4UID[i]) +'  Menu SEQ: '+inttostr(i),'',SOURCEFILE);
              saQry:='UPDATE jmenu SET '+
                'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i) + ', '+
                'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i])+' and '+
                'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
              bOk:=rs3.Open(saQry,DBC,201503161513);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004131824, 'Trouble updating new SEQUENCE value '+
                  'to Menu Item Record during Move Item Down Sequence operation.','saQry: '+saQry,SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
              rs3.close;
              if not bOk then exit;
            end;

            // is our target to move up on top already?
            If u8Node = au8UID[i4MyCount] Then
            begin
              //MsgBox "Nothing to Do - its on the top of this node already."
            end
            Else
            begin
              // Swap it
              bSwappedItAlready := False;
              For i := 1 To i4MyCount-1 do
              begin
                if bOk then
                begin
                  If Not bSwappedItAlready Then
                  begin
                    If u8Node = au8UID[i] Then
                    begin
                      bSwappedItAlready := True;
                      //AS_Log(p_Context,cnLog_Debug, 201203241549, 'JMenu UID:'+ inttostR(ai4UID[i]) +'  Menu SEQ: '+inttostr(i+1),'',SOURCEFILE);
                      saQry:= 'UPDATE jmenu SET '+
                        'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i + 1) + ', '+
                        'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                        'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                        'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i])+' and '+
                        'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
                      bOk:=rs3.Open(saQry,DBC,201503161514);rs3.close;
                      if not bOk then
                      begin
                        JAS_Log(p_Context,cnLog_Error, 201004131826, 'Trouble executing querying swapping '+
                          'menu items during Move Item Down Sequence operation.','Query: '+saQry,SOURCEFILE);
                        RenderHtmlErrorPage(p_Context);
                      end;
                      if bOk then
                      begin
                        //JAS_Log(p_Context,cnLog_Debug, 201203241550, 'JMenu UID:'+ inttostR(ai4UID[i+1]) +'  Menu SEQ: '+inttostr(i),'',SOURCEFILE);
                        saQry:= 'UPDATE jmenu SET '+
                          'JMenu_SEQ_u=' + DBC.sDBMSUIntScrub(i) + ', '+
                          'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                          'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                          'WHERE JMenu_JMenu_UID=' + DBC.sDBMSUIntScrub(au8UID[i + 1])+' and '+
                          'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
                        bOk:=rs3.Open(saQry,DBC,201503162020);rs3.close;
                        if not bOk then
                        begin
                          JAS_Log(p_Context,cnLog_Error, 201004131827, 'Trouble executing querying '+
                            'swapping menu items during Move Item Down Sequence operation.',
                            'Query: '+saQry,SOURCEFILE);
                          RenderHtmlErrorPage(p_Context);
                        end;
                      end;
                    End;
                  End;
                end;
              end;
            End;
          End;

          saMode:='';
          if p_Context.SessionXDL.FoundItem_saName('MODE') then
          begin
            p_Context.SessionXDL.Item_saValue:=saMode;
          end;
          bRenderDetail:=false;
          if bOk then
          begin
            p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
          end;

          // Might not be necessary, as FPC may remove allocated ram from array
          // when scope is lost - but to make sure...
          setlength(au8UID,0);
          setlength(ai4SEQ,0);
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='CUT' then
        begin
          if saMode<>'CUT' then
          begin
            saMode:='CUT';
            if p_Context.SessionXDL.FoundItem_saName('MODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=saMode;
            end
            else
            begin
              p_Context.SessionXDL.AppendItem_saName_N_saValue('MODE',saMode);
            end;

            if p_Context.SessionXDL.FoundItem_saName('CNODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=inttostr(u8Node);
            end
            else
            begin
              p_Context.SessionXDL.AppendItem_saName_N_saValue('CNODE',inttostr(u8Node));
            end;
          end;
        end else

        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='COPY' then
        begin
          if saMode<>'COPY' then
          begin
            saMode:='COPY';
            if p_Context.SessionXDL.FoundItem_saName('MODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=saMode;
            end
            else
            begin
              p_Context.SessionXDL.AppendItem_saName_N_saValue('MODE',saMode);
            end;
            if p_Context.SessionXDL.FoundItem_saName('CNODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=inttostr(u8Node);
            end
            else
            begin
              p_Context.SessionXDL.AppendItem_saName_N_saValue('CNODE',inttostr(u8Node));
            end;
          end;
        end else


        if upcase(p_Context.CGIENV.DataIn.Get_saValue('BTN'))='PASTE' then
        begin
          //AS_LOG(p_Context, cnLog_Debug,201212130858,'MenuEditor - Enter Paste Mode BTN=PASTE Mode:'+saMode,'',SOURCEFILE);
          if saMode='CUT' then
          begin
            u8CopyNode:=u8Val(p_Context.SessionXDL.Get_saValue('CNODE'));

            if bOk then
            begin
              If u8CopyNode = u8Node Then
              begin
                bOk:=false;
                JAS_Log(p_Context,cnLog_Error, 201004151042, 'Unable to comply. Source Node and Move-To node are the same.',
                  'u8CopyNode:'+inttostr(u8CopyNode)+' u8Node:'+inttostr(u8Node) ,SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              End;
            end;

            if bOk then
            begin
              saQry := 'UPDATE jmenu SET '+
                'JMenu_JMenuParent_ID=' + DBC.sDBMSUIntScrub(u8Node)+', '+
                'JMenu_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+', '+
                'JMenu_Modified_DT='+DBC.sDBMSDateScrub(DT)+' '+
                'WHERE JMenu_JMenu_UID='+DBC.sDBMSUIntScrub(u8CopyNode)+' and '+
                'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
              bOk:=rs3.open(saQry,DBC,201503161516);rs3.close;
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004151050, 'Problem moving node; unable to update database.',
                  'u8CopyNode:'+inttostr(u8CopyNode)+' u8Node:'+inttostr(u8Node) +' Query: '+saQry,SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              End;
            end;

            If bOk Then
            begin
              saMode:='';
              if p_Context.SessionXDL.FoundItem_saName('MODE') then
              begin
                p_Context.SessionXDL.Item_saValue:=saMode;
              end;
              if p_Context.SessionXDL.FoundItem_saName('CNODE') then
              begin
                p_Context.SessionXDL.Item_saValue:='';
              end;
              bRenderDetail:=false;
              if bOk then
              begin
                p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
              end;
            End;
          end
          else
          begin
            u8CopyNode:=u8Val(p_Context.SessionXDL.Get_saValue('CNODE'));
            if bOk then
            begin
              bOk:=bCopyMenuNode(p_Context, u8Val(p_Context.SessionXDL.Get_saValue('CNODE')), u8Node);
            end;

            If bOk Then
            begin
              saMode:='';
              if p_Context.SessionXDL.FoundItem_saName('MODE') then
              begin
                p_Context.SessionXDL.Item_saValue:=saMode;
              end;
              if p_Context.SessionXDL.FoundItem_saName('CNODE') then
              begin
                p_Context.SessionXDL.Item_saValue:='';
              end;
              bRenderDetail:=false;
              if bOk then
              begin
                p_Context.saPage:='<html><body><script>parent.document.location.href="[@ALIAS@].?ACTION=MenuEditor&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'";</script></body></html>';
              end;
            End;
          end;
        end;

        if bRenderDetail then
        begin
          if bOk then
          begin
            saQry:='select * from jsecperm '+
              'where (Perm_Deleted_b='+DBC.sDBMSBoolScrub(false)+') or (Perm_Deleted_b is null) '+
              'order by Perm_Name';
            bOk:=rs.open(saQry,DBC,201503161517);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error, 201004131829, 'Unable to query security permissions.','Query: '+saQry,SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            clear_jmenu(rJMenu);
            rJMenu.JMenu_JMenu_UID:=u8Node;
            if rJMenu.JMenu_JMenu_UID>0 then
            begin
              bOk:=bJAS_Load_jmenu(p_Context, DBC,rJMenu,false,20160331206);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Info, 201004112032, 'JAS_MenuEditor unable to load menu item.',' JMenu_JMenu_UID (u8Node): '+inttostr(u8Node),SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
            end;
          end;


          if bOk then
          begin
            saJSecPermOptions:='<option ';
            if rJMenu.JMenu_JSecPerm_ID=0 then saJSecPermOptions+='selected ';
            saJSecPermOptions+='value="0">None Required</option>';
            if rs.eol=false then
            begin
              repeat
                saJSecPermOptions+='<option ';
                if rJMenu.JMenu_JSecPerm_ID=u8Val(rs.fields.Get_saValue('Perm_JSecPerm_UID')) then saJSecPermOptions+='selected ';
                saJSecPermOptions+='value="'+rs.fields.Get_saValue('Perm_JSecPerm_UID')+'">'+rs.fields.Get_saValue('Perm_Name')+'</option>';
              until not rs.movenext;
            end;
          end;
          rs.close;





          if (u8Node>0) or (saMode='CUT') or (saMode='COPY') then // If ROOT of Menu Tree - limit available actions
          begin
            if bOk then
            begin
              if (saMode='ADD') or (saMode='EDIT') then
              begin
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDADD@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEDIT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDELETE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDSAVE@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDUP@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDOWN@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDREFRESH@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCUT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCOPY@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDPASTE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCANCEL@]','');
                //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_JMENU_UID@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NAME@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SECPERM_ID@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL_THEME_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE_THEME_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_TITLE_en@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SEQ_U@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_URL@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NEWWINDOW_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_VALIDSESSIONONLY_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFNOACCESS_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFVALIDSESSION_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_READMORE_B@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DATA_en@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDIMPORT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEXPORT@]','disabled');
              end else

              if (saMode='COPY') or (saMode='CUT') then
              begin
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDADD@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEDIT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDELETE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDSAVE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDUP@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDOWN@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDREFRESH@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCUT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCOPY@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDPASTE@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCANCEL@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_JMENU_UID@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NAME@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SECPERM_ID@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL_THEME_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE_THEME_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_TITLE_en@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SEQ_U@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_URL@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NEWWINDOW_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_VALIDSESSIONONLY_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFNOACCESS_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFVALIDSESSION_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_READMORE_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DATA_en@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDIMPORT@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEXPORT@]','disabled');
              end else

              begin
                // NO MODE
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDADD@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEDIT@]','');
                saQry:='JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(rJMenu.JMenu_JMenu_UID);
                if DBC.u8GetRecordCount('jmenu',saQry,201506171765)>0 then
                begin
                  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDELETE@]','disabled');
                end
                else
                begin
                  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDELETE@]','');
                end;

                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDSAVE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDUP@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDOWN@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDREFRESH@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCUT@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCOPY@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDPASTE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCANCEL@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_JMENU_UID@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NAME@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SECPERM_ID@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL_THEME_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE_THEME_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_TITLE_en@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SEQ_U@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_URL@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NEWWINDOW_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_VALIDSESSIONONLY_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFNOACCESS_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFVALIDSESSION_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_READMORE_B@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DATA_en@]','disabled');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDIMPORT@]','');
                p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEXPORT@]','');
              end;
            end;
          end
          else
          begin
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDADD@]','');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEDIT@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDELETE@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDSAVE@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDUP@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDDOWN@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDREFRESH@]','');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCUT@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCOPY@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDPASTE@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDCANCEL@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_JMENU_UID@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NAME@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SECPERM_ID@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONSMALL_THEME_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_ICONLARGE_THEME_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_TITLE_en@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_SEQ_U@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_URL@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_NEWWINDOW_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_VALIDSESSIONONLY_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFNOACCESS_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DISPLAYIFVALIDSESSION_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_READMORE_B@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLED_JMENU_DATA_en@]','disabled');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDIMPORT@]','');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DISABLEDEXPORT@]','');
          end;

          if bOk then
          begin
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_JMENU_UID@]'       ,inttostr(rJMenu.JMenu_JMenu_UID));
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_JMENUPARENT_ID@]'  ,inttostr(rJMenu.JMenu_JMenuParent_ID));
            if rJMenu.JMenu_DisplayIfNoAccess_b then
            begin
              p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_DISPLAYIFNOACCESS_B@]'      ,'checked');
            end
            else
            begin
              p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_DISPLAYIFNOACCESS_B@]'      ,'');
            end;
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_TITLE_en@]'        ,rJMenu.JMenu_Title_en);
            // caption: JMenu_IconAltText_JCaption_ID
          end;

          if bOk then
          begin
            rJMenu.JMenu_IconLarge:=saSNRStr(rJMenu.JMenu_IconLarge, '@','&#64;');
            rJMenu.JMenu_IconLarge:=saSNRStr(rJMenu.JMenu_IconLarge, '[','&#91;');
            rJMenu.JMenu_IconLarge:=saSNRStr(rJMenu.JMenu_IconLarge, ']','&#93;');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_ICONLARGE@]'       ,rJMenu.JMenu_IconLarge);
            if rJMenu.JMenu_IconLarge_Theme_b then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_ICONLARGE_THEME_B@]'      ,'checked'); end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_ICONLARGE_THEME_B@]'      ,''); end;

            rJMenu.JMenu_IconSmall:=saSNRStr(rJMenu.JMenu_IconSmall, '@','&#64;');
            rJMenu.JMenu_IconSmall:=saSNRStr(rJMenu.JMenu_IconSmall, '[','&#91;');
            rJMenu.JMenu_IconSmall:=saSNRStr(rJMenu.JMenu_IconSmall, ']','&#93;');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_ICONSMALL@]'       ,rJMenu.JMenu_IconSmall);
            if rJMenu.JMenu_IconSmall_Theme_b then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_ICONSMALL_THEME_B@]'      ,'checked');end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_ICONSMALL_THEME_B@]'      ,''); end;
          end;

          if bOk then
          begin
            if rJMenu.JMenu_JMenu_UID=0 then
            begin
              saMenuNotes:='';
              saMenuNotes+='This is the Root Node of the Menu System. Adding a new Menu Item to this Node creates a whole new Menu.';
            end;
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_DATA_en@]'              ,rJMenu.JMenu_Data_en);
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_JSECPERM_ID@]'          ,inttostr(rJMenu.JMenu_JSecPerm_ID));
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_NAME@]'              ,rJMenu.JMenu_Name);
            if rJMenu.JMenu_NewWindow_b then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_NEWWINDOW_B@]'      ,'checked');end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_NEWWINDOW_B@]'      ,''); end;
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_SEQ_U@]'                ,inttostr(rJMenu.JMenu_SEQ_u));
            rJMenu.JMenu_URL:=saSNRStr(rJMenu.JMenu_URL, '@','&#64;');
            rJMenu.JMenu_URL:=saSNRStr(rJMenu.JMenu_URL, '[','&#91;');
            rJMenu.JMenu_URL:=saSNRStr(rJMenu.JMenu_URL, ']','&#93;');
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JMENU_URL@]'                  ,rJMenu.JMenu_URL);
            if rJMenu.JMenu_ValidSessionOnly_b then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_VALIDSESSIONONLY_B@]'      ,'checked'); end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_VALIDSESSIONONLY_B@]'      ,''); end;
            if rJMenu.JMenu_DisplayIfValidSession_b then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_DISPLAYIFVALIDSESSION_B@]'      ,'checked');end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_DISPLAYIFVALIDSESSION_B@]'      ,''); end;
            if rJMenu.JMenu_ReadMore_b            then begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_READMORE_B@]'      , 'checked'); end else begin p_Context.PAGESNRXDL.AppendItem_SNRPair('[@CHECKED_JMENU_READMORE_B@]'      ,''); end;
            p_Context.PAGESNRXDL.AppendItem_SNRPair('[@SECPERM_OPTIONS@]',saJSecPermOptions);
            p_Context.saPage:=saGetPage(p_Context,'sys_area','sys_page_menueditor_RightFrame','main',false,'', 123020100046);
            // Did this JASSIG removal versus using sys_area_nosig because form stopped working and I
            // could not see how or why. No errors - just a "disabled" frame for some reason. Dunno :(
            // this fixes it though - gives me working form without Jegas signature and Quicklinks.
            p_Context.saPage:=saSNRStr(p_Context.saPage,'[@JASSIG@]','');

          end;
        end;
      end
      else
      begin
        if upcase(p_Context.CGIENV.DataIn.Get_saValue('ME'))='IMPORT' then
        begin
          // Not actually part of the Menu Editing bit; instead renders a
          // a page that allows the user to select and upload a JAS
          // XML Menu file.
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@NODE@]',inttostr(u8Node));
          p_Context.saPage:=saGetPage(p_Context,'sys_area_nosig','sys_page_menueditor_import','',false,'',123020100047);
        end
        else
        begin
          if upcase(p_Context.CGIENV.DataIn.Get_saValue('ME'))='EXPORT' then
          begin
            // Not actually part of the Menu Editing bit; instead renders a
            // a page that allows the user to download a JAS XML Menu file.
            saMenuExport:=saRenderMenuAsXML(p_Context, u8Node);
            bOk:= (p_Context.bErrorCondition=false);
            if bOk then
            begin
              garJVHost[p_COntext.u2VHost].VHost_WebRootDir:=saAddSlash(garJVHost[p_COntext.u2VHost].VHost_WebRootDir);

              //saFilename:=saSequencedFilename(garJVHostLight[p_Context.i4VHost].saWebRootDir+'download'+DOSSLASH+'jasmenu', 'xml');
              saFilename:=garJVHost[p_COntext.u2VHost].VHost_WebRootDir+'download'+DOSSLASH+'jasmenu.'+sGetUID+'.xml';

              //riteln('=================================');
              //riteln('uj_menueditor - exporting to:'+saFilename);
              //riteln('=================================');
              bOk:=bTSOpenTextFile(safilename,u2IOResult,F,false,false);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004170150, 'JAS_MenuEditor unable to open new file for writing while trying to prepare menu export: ' + saFilename,'',SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
            end;

            if bOk then
            begin
              {$I-}
              write(f,saMenuExport);
              {$I+}
              u2IOREsult:=IOResult;
              bOk:=u2IOREsult=0;
              if not bOk then
              begin
                bTSCloseTextFile(saFilename, u2IOResult_FailSafe, F);
                JAS_Log(p_Context,cnLog_Error, 201004170151, 'JAS_MenuEditor unable to write to file while trying to prepare menu export: ' + saFilename+' IOResult:'+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),'',SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
            end;

            if bOk then
            begin
              bOk:=bTSCloseTextFile(saFilename, u2IOResult, F);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201004170152, 'JAS_MenuEditor unable to close file while trying to prepare menu export: ' + saFilename+' IOResult:'+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),'',SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
            end;

            if bOk then
            begin
              FSplit(saFilename,dir,sFile,ext);
              p_Context.PAGESNRXDL.AppendItem_SNRPair('[@FILENAME@]','/download/'+sFile+ext);
              p_Context.saPage:=saGetPage(p_Context,'sys_area_nosig','sys_page_menueditor_export','',false,'',123020100048);
            end;
          end
          else
          begin
            // this is for the whole frameset - note it cancels any current mode
            if p_Context.SessionXDL.FoundItem_saName('NODE') then
            begin
              u8Node:=u8Val(p_Context.SessionXDL.Item_saValue);
            end
            else
            begin
              p_Context.SessionXDL.AppendItem;
              p_Context.SessionXDL.Item_saName:='NODE';
              p_Context.SessionXDL.Item_saValue:='0';
            end;
            saMode:='';
            if p_Context.SessionXDL.FoundItem_saName('MODE') then
            begin
              p_Context.SessionXDL.Item_saValue:=saMode;
            end;
            if p_Context.SessionXDL.FoundItem_saName('CNODE') then
            begin
              p_Context.SessionXDL.Item_saValue:='';
            end;
            p_Context.saPage:=saGetPage(p_Context,'sys_page_menueditor','','',false,'',123020100049);
            p_Context.u2DebugMode:=cnSYS_INFO_MODE_SECURE; //prevent debug stuff being sent
          end;
        end;
      end;
    end;
  end;
  rs.destroy;
  rs2.destroy;
  rs3.destroy;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102417,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
function saRenderSubMenuAsXML(p_Context: TCONTEXT; p_u8MenuID: uint64): ansistring;
//=============================================================================
var
  rJMenu: rtJMenu;
  //rJCaption: rtJCaption;
  //rIconAltTextJCaption: rtJCaption;
  //rJNote: rtJNote;

  //rJMenuDest: rtJMenu;
  //rJCaptionDest: rtJCaption;
  //rIconAltTextJCaptionDest: rtJCaption;
  //rJNoteDest: rtJNote;

  saQry: ansistring;
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  //rs2: JADO_RECORDSET;
  sa: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saRenderSubMenuAsXML(p_Context: TCONTEXT; p_saMID: ansistring): ansistring;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102418,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102419, sTHIS_ROUTINE_NAME);{$ENDIF}


  rs:=JADO_RECORDSET.Create;
  //rs2:=JADO_RECORDSET.Create;
  DBC:=p_Context.VHDBC;
  p_Context.bNoWebCache:=true;

  // BEGIN ----------- LOAD Menu Item Itself First
  rJMenu.JMenu_JMenu_UID:=p_u8MenuID;
  bOk:=bJAS_Load_JMenu(p_Context, DBC, rJMenu,false,20160331207);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error, 201004151721, 'saRenderMenuAsXML - Unable to load jmenu via bJAS_Load_JMenu','p_u8MenuID:'+inttostr(p_u8MenuID),SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;


  if bOk then
  begin
    sa:=
      '<jmenu JMenu_JMenu_UID="'+saHTMLScrub(inttostr(rJMenu.JMenu_JMenu_UID))+'">'+csLF+
      '  <JMenu_JMenuParent_ID>'         +saHTMLScrub(inttostr(rJMenu.JMenu_JMenuParent_ID))   +'</JMenu_JMenuParent_ID>'       +csLF+
      '  <JMenu_DisplayIfNoAccess_b>'    +saHTMLScrub(sYesNo(rJMenu.JMenu_DisplayIfNoAccess_b))        +'</JMenu_DisplayIfNoAccess_b>'  +csLF+
      '  <JMenu_Title_en>'               +saHTMLScrub(rJMenu.JMenu_Title_en)                   +'</JMenu_Title_en>'             +csLF+
      '  <JMenu_IconLarge>'              +saHTMLScrub(rJMenu.JMenu_IconLarge)                  +'</JMenu_IconLarge>'            +csLF+
      '  <JMenu_IconSmall>'              +saHTMLScrub(rJMenu.JMenu_IconSmall)                  +'</JMenu_IconSmall>'            +csLF+
      '  <JMenu_IconLarge_Theme_b>'      +saHTMLScrub(sYesNo(rJMenu.JMenu_IconLarge_Theme_b))          +'</JMenu_IconLarge_Theme_b>'    +csLF+
      '  <JMenu_IconSmall_Theme_b>'      +saHTMLScrub(sYesNo(rJMenu.JMenu_IconSmall_Theme_b))          +'</JMenu_IconSmall_Theme_b>'    +csLF+
      '  <JMenu_Data_en><![CDATA['       +rJMenu.JMenu_Data_en+']]></JMenu_Data_en>'+csLF;
    sa+=
      '  <JMenu_JSecPerm_ID>'            +saHTMLScrub(inttostr(rJMenu.JMenu_JSecPerm_ID))                +'</JMenu_JSecPerm_ID>'          +csLF+
      '  <JMenu_Name>'                +saHTMLScrub(rJMenu.JMenu_Name)                    +'</JMenu_Name>'              +csLF+
      '  <JMenu_NewWindow_b>'            +saHTMLScrub(sYesNo(rJMenu.JMenu_NewWindow_b))                +'</JMenu_NewWindow_b>'          +csLF+
      '  <JMenu_SEQ_u>'                  +saHTMLScrub(inttostr(rJMenu.JMenu_SEQ_u))                      +'</JMenu_SEQ_u>'                +csLF+
      '  <JMenu_URL>'                    +saHTMLScrub(rJMenu.JMenu_URL)                        +'</JMenu_URL>'                  +csLF+
      '  <JMenu_ValidSessionOnly_b>'     +saHTMLScrub(sYesNo(rJMenu.JMenu_ValidSessionOnly_b))         +'</JMenu_ValidSessionOnly_b>'   +csLF+
      '  <JMenu_DisplayIfValidSession_b>'+saHTMLScrub(sYesNo(rJMenu.JMenu_DisplayIfValidSession_b))    +'</JMenu_DisplayIfValidSession_b>'+csLF+
      '  <JMenu_ReadMore_b>'             +saHTMLScrub(sYesNo(rJMenu.JMenu_ReadMore_b))                 +'</JMenu_ReadMore_b>'           +csLF;
    sa+=
      '  <JAS_Row_b>'                    +saHTMLScrub(sYesNo(rJMenu.JAS_Row_b))       +'</JAS_Row_b>'                  +csLF;

  end;
  // END ----------- Load Menu Item Itself First



  // BEGIN ----------- Next this routine loads children as a recordset and calls itself recursively
  if bOk then
  begin
    saQry:='select JMenu_JMenu_UID from jmenu '+
      'where JMenu_JMenuParent_ID='+DBC.sDBMSUIntScrub(p_u8MenuID)+' and '+
      ' JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161518);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004151725, 'saRenderMenuAsXML - Successfully '+
        'copied current menu item but unable to query for potential children to copy.',
        'Query: '+saQry,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol)then
  begin
    sa+='<children>'+csLF;
    repeat
      sa+=saRenderSubMenuAsXML(p_Context, u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID')));
      bOk:=(p_Context.bErrorCondition=false);
    until (not rs.movenext) or (bOk=false);
    sa+='</children>'+csLF;
  end;
  rs.close;

  // END   ----------- Next this routine loads children as a recordset and calls it self to recursively copy


  sa+='</jmenu>'+csCRLF;

  rs.destroy;
  result:=sa;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102420,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
function saRenderMenuAsXML(p_Context: TCONTEXT; p_u8MenuID: uint64): ansistring;
//=============================================================================
var
  sa: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saRenderMenuAsXML(p_Context: TCONTEXT; p_saMID: ansistring): ansistring;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102420,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102421, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:='';
  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  sa:='';
  p_Context.bNoWebCache:=true;

  if p_u8MenuID=0 then
  begin
    saQry:='select JMenu_JMenu_UID from jmenu '+
      'where JMenu_JMenuParent_ID=0 and '+
      'JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161519);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004151726, 'saRenderMenuAsXML - Trouble Querying Root Node of Menu system','Query: '+saQry,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;

    if bOk and (rs.eol=false)then
    begin
      repeat
        sa+=saRenderSubMenuAsXML(p_Context, u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID')));
        bOk:=(p_Context.bErrorCondition=false);
      until (not rs.movenext) or (bOk=false);
    end;
    rs.close;
  end
  else
  begin
    sa:=saRenderSubMenuAsXML(p_Context, p_u8MenuID);
  end;
  if not p_Context.bErrorCondition then
  begin
    result:='<?xml version="1.0" encoding="UTF-8" ?>' + csLF;
    result+='<xml>'+csLF;
    result+=sa;
    result+='</xml>'+csLF;
    result+=csLF+csLF+csLF;
  end;
  rs.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102422,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
procedure JAS_MenuExport(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  u8MenuID: uint64;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:=''; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102423,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102424, sTHIS_ROUTINE_NAME);{$ENDIF}

  p_Context.bNoWebCache:=true;
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Info, 201007250017, 'Menu Export Not Available Unless you are logged in.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_MenuExport);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Info, 201007250017,
        'Access Denied',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    sa:='';
    u8MenuID:= u8Val(p_Context.CGIENV.DataIn.Get_saValue('MID'));
    sa:=saRenderMenuAsXML(p_Context, u8MenuID);
    if not p_Context.bErrorCondition then
    begin
      p_Context.saPage:=sa;
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CGIENV.Header_XML(garJVHost[p_COntext.u2VHost].VHost_ServerIdent);
      p_Context.u2DebugMode:=cnSYS_INFO_MODE_SECURE; //prevent debug stuff being sent
      p_Context.bOutputRaw:=true;
    end;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102425,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
function bImportMenuNode(
  p_Context: TCONTEXT;
  p_XMLNODE:  JFC_XML;
  var p_bOk: boolean;
  p_u8RootNodeID: uint64;
  p_bAllNew: boolean;
  var p_uNestLevel: UINT
):boolean;
//=============================================================================
var
  bOk: boolean;
  rJMenu: rtJMenu;
  SubNode: JFC_XML;// reference only
  //SubNode2: JFC_XML;// reference only
  //bSubNodeHasMenuItems: boolean;
  //uTempID: UINT;
  DBC: JADO_CONNECTION;
  //saQry: Ansistring;
  //rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bImportMenuNode'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102426,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102427, sTHIS_ROUTINE_NAME);{$ENDIF}

  {$IFDEF DIAGMSG}
  JASPRintln('bImportMenuNode------------BEGIN');
  //ASPrintln(p_XMLNode.saXML(false,false));
  {$ENDIF}
  bOk:=true;
  p_uNestLevel+=1;
  DBC:=p_Context.VHDBC;
  p_Context.bNoWebCache:=true;
  if p_XMLNODE.MoveFirst then
  begin
    {$IFDEF DIAGMSG}Writeln('STARTING NEW NODE REPEAT LOOP. Count: ',p_XMLNODE.listcount);{$ENDIF}
    repeat
      {$IFDEF DIAGMSG}
      JASPrintln('bImportMenuNode - Top of loop p_XMLNODE.Item_saName: '+p_XMLNODE.Item_saName);
      {$ENDIF}
      if p_XMLNODE.Item_saName='jmenu' then
      begin
        clear_JMenu(rJMenu);
        rJMenu.JMenu_JMenu_UID:=0;
        if (JFC_XMLITEM(p_XMLNode.lpItem).AttrXDL <> nil) then
          rJMenu.JMenu_JMenu_UID:=u8Val(JFC_XMLITEM(p_XMLNode.lpItem).AttrXDL.Get_saValue('JMenu_JMenu_UID'));
        // Ok we have loaded data we are interested in into JMenu (A First pass if you will)
        // Next we need to look for TWO caption nodes and ONE Notes Node. Once those are located
        // we prepare for a database write applying the logic for the "ALLNEW" mode or "Update"
        // Mode. Once that is done, we recurse if there are sub menus, otherwise we continue
        // our loop at the current nest level.
        //bSubNodeHasMenuItems:=false;
        SubNode:=nil;
        if p_XMLNode.Item_lpPtr<>nil then
        begin
          SubNode:=JFC_XML(p_XMLNode.Item_lpPtr);
          with rJMenu do begin
            JMenu_JMenuParent_ID:=u8Val(SubNode.Get_saValue('JMenu_JMenuParent_ID'));
            if (p_XMLNode.N=1) and (p_uNestLevel=1) then
            begin
              if p_bAllNew then JMenu_JMenuParent_ID:=0 else JMenu_JMenuParent_ID:=u8Val(p_Context.SessionXDL.Get_saValue('NODE'));
            end;
            JMenu_DisplayIfNoAccess_b        :=bVal(SubNode.Get_saValue('JMenu_DisplayIfNoAccess_b'));
            JMenu_Title_en                   :=SubNode.Get_saValue('JMenu_Title_en');
            JMenu_IconLarge                  :=SubNode.Get_saValue('JMenu_IconLarge');
            JMenu_IconSmall                  :=SubNode.Get_saValue('JMenu_IconSmall');
            JMenu_IconLarge_Theme_b          :=bVal(SubNode.Get_saValue('JMenu_IconLarge_Theme_b'));
            JMenu_IconSmall_Theme_b          :=bVal(SubNode.Get_saValue('JMenu_IconSmall_Theme_b'));
            JMenu_Data_en                    :=trim(SubNode.Get_saValue('JMenu_Data_en'));
            //ASPrintln('uj_menueditor - import - cdata test. JMenu_Data_en: ' +JMenu_Data_en);
            if LeftStr(JMenu_Data_en,9)='<![CDATA[' then
            begin
              JMenu_Data_en:=rightstr(JMenu_Data_en,length(JMenu_Data_en)-9);
              JMenu_Data_en:=leftstr(JMenu_Data_en,length(JMenu_Data_en)-3);
            end;
            JMenu_JSecPerm_ID                :=u8Val(SubNode.Get_saValue('JMenu_JSecPerm_ID'));
            JMenu_Name                    :=SubNode.Get_saValue('JMenu_Name');
            JMenu_NewWindow_b                :=bVal(SubNode.Get_saValue('JMenu_NewWindow_b'));
            JMenu_SEQ_u                      :=uVal(SubNode.Get_saValue('JMenu_SEQ_u'));
            JMenu_URL                        :=SubNode.Get_saValue('JMenu_URL');
            JMenu_ValidSessionOnly_b         :=bVal(SubNode.Get_saValue('JMenu_ValidSessionOnly_b'));
            JMenu_DisplayIfValidSession_b    :=bVal(SubNode.Get_saValue('JMenu_DisplayIfValidSession_b'));
            JMenu_ReadMore_b                 :=bVal(SubNode.Get_saValue('JMenu_ReadMore_b'));
            JAS_Row_b                        :=bVal(SubNode.Get_saValue('JAS_Row_b'));
          end;//with
          if SubNode.FoundItem_saName('children') and (SubNode.Item_lpPtr<>nil) then
          begin
            // This means we have sub menu items to recurse. In Theory the SubNode object
            // is already pointed to the correct reference we need.
            {$IFDEF DIAGMSG}JASPRINTLN('Going Down a Level');{$ENDIF}
            bImportMenuNode(p_Context, JFC_XML(JFC_XMLITEM(SubNode.lpItem).lpPtr), bOk, rJMenu.JMenu_JMenu_UID,p_bAllNew,p_uNestLevel);
            {$IFDEF DIAGMSG}JASPRINTLN('Going Up a Level');{$ENDIF}
            //if not bOk then
            //begin
            //  JAS_Log(p_Context,cnLog_Error, 201605291815, 'bImportMenuNode Failed because bImportMenuNode failed.','',SOURCEFILE);
            //  RenderHtmlErrorPage(p_Context);
            //end;
          end;
        end;

        {$IFDEF DIAGMSG}
        JASPrintln('JMenu_JMenu_UID               :'+inttostr(rJMenu.JMenu_JMenu_UID));
        JASPrintln('JMenu_JMenuParent_ID          :'+inttostr(rJMenu.JMenu_JMenuParent_ID));
        JASPrintln('JMenu_DisplayIfNoAccess_b     :'+sYesNo(rJMenu.JMenu_DisplayIfNoAccess_b));
        JASPrintln('JMenu_Title_en                :'+rJMenu.JMenu_Title_en);
        JASPrintln('JMenu_IconLarge               :'+rJMenu.JMenu_IconLarge);
        JASPrintln('JMenu_IconLarge_Theme_b       :'+sYesNo(rJMenu.JMenu_IconLarge_Theme_b));
        JASPrintln('JMenu_IconSmall               :'+rJMenu.JMenu_IconSmall);
        JASPrintln('JMenu_IconSmall_Theme_b       :'+sYesNo(rJMenu.JMenu_IconSmall_Theme_b));
        JASPrintln('JMenu_Data_en                 :'+rJMenu.JMenu_Data_en);
        JASPrintln('JMenu_JSecPerm_ID             :'+inttostr(rJMenu.JMenu_JSecPerm_ID));
        JASPrintln('JMenu_Name                 :'+rJMenu.JMenu_Name);
        JASPrintln('JMenu_NewWindow_b             :'+sYesNo(rJMenu.JMenu_NewWindow_b));
        JASPrintln('JMenu_SEQ_u                   :'+inttostr(rJMenu.JMenu_SEQ_u));
        JASPrintln('JMenu_URL                     :'+rJMenu.JMenu_URL);
        JASPrintln('JMenu_ValidSessionOnly_b      :'+sYesNo(rJMenu.JMenu_ValidSessionOnly_b));
        JASPrintln('JMenu_DisplayIfValidSession_b :'+sYesNo(rJMenu.JMenu_DisplayIfValidSession_b));
        JASPrintln('JMenu_ReadMore_b              :'+sYesNo(rJMenu.JMenu_ReadMore_b));
        {$ENDIF}

        // p_Context.saPage+='<table border="1"><caption>rJMenu</caption>';
        // p_Context.saPage+='<tr><td>JMenu_JMenu_UID                  </td><td>'+inttostr(rJMenu.JMenu_JMenu_UID)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_JMenuParent_ID             </td><td>'+inttostr(rJMenu.JMenu_JMenuParent_ID)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_DisplayIfNoAccess_b        </td><td>'+sYesNo(rJMenu.JMenu_DisplayIfNoAccess_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_Title_en                   </td><td>'+rJMenu.JMenu_Title_en+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_IconLarge                  </td><td>'+rJMenu.JMenu_IconLarge+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_IconLarge_Theme_b          </td><td>'+sYesNo(rJMenu.JMenu_IconLarge_Theme_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_IconSmall                  </td><td>'+rJMenu.JMenu_IconSmall+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_IconSmall_Theme_b          </td><td>'+sYesNo(rJMenu.JMenu_IconSmall_Theme_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_Data_en                    </td><td>'+rJMenu.JMenu_Data_en+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_JSecPerm_ID                </td><td>'+inttostr(rJMenu.JMenu_JSecPerm_ID)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_Name                    </td><td>'+rJMenu.JMenu_Name+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_NewWindow_b                </td><td>'+sYesNo(rJMenu.JMenu_NewWindow_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_SEQ_u                      </td><td>'+inttostr(rJMenu.JMenu_SEQ_u)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_URL                        </td><td>'+rJMenu.JMenu_URL+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_ValidSessionOnly_b         </td><td>'+sYesNo(rJMenu.JMenu_ValidSessionOnly_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_DisplayIfValidSession_b    </td><td>'+sYesNo(rJMenu.JMenu_DisplayIfValidSession_b)+'</td></tr>';
        // p_Context.saPage+='<tr><td>JMenu_ReadMore_b                 </td><td>'+sYesNo(rJMenu.JMenu_ReadMore_b)+'</td></tr>';
        // p_Context.saPage+='</table>';

        // BEGIN ------- WRITE TO DATABASE COLLECTED INFORMATION
        JAS_Log(p_Context,cnLog_Debug, 201203241539, 'Writing to jmenu - JMenu UID:'+inttostr(rJMenu.JMenu_JMenu_UID)+'  Menu SEQ: '+inttostr(rJMenu.JMenu_SEQ_u),'',SOURCEFILE);



        // force Add New Here
        //if rJMenu.JMenu_JMenu_UID>0 then
        //begin
        //  uTempID:=rJMenu.JMenu_JMenu_UID;
        //  rJMenu.JMenu_JMenu_UID:=0;
        //  bOk:=bJAS_Save_JMenu(p_Context, DBC, rJMenu,false,false);
        //  {$IFDEF DIAGMSG}writeln('import call A - bJAS_Save_JMenu:',syesno(bOk),' UID:',rJMenu.JMenu_JMenu_UID,' Parent ID: ',rJMenu.JMenu_JMenuParent_ID);{$ENDIF}
        //  if not bOk then
        //  begin
        //    JAS_Log(p_Context,cnLog_Error, 201605292038, 'bImportMenuNode Failed - saving new jmenu record.','',SOURCEFILE);
        //    RenderHtmlErrorPage(p_Context);
        //  end;
        //  rs:=JADO_RECORDSET.Create;
        //  saQry:='update jmenu set JMenu_JMenu_UID='+DBC.sDBMSUIntScrub(uTempID)+' where JMenu_JMenu_UID='+DBC.sDBMSUIntScrub(rJMenu.JMenu_JMenu_UID);
        //  bOk:=rs.open(saQry,DBC,201605292036);
        //  {$IFDEF DIAGMSG}writeln('Did UID Follow up work? '+sYesNo(bOk));{$ENDIF}
        //  if not bOk then
        //  begin
        //    JAS_Log(p_Context,cnLog_Error, 201605292039, 'Unable to import node; usually due to a duplicate record ID. You can even have a duplicate in the recycle bin.','Query: '+saQry,SOURCEFILE);
        //    RenderHtmlErrorPage(p_Context);
        //  end;
        //  //rs.close;
        //  rs.destroy;
        //end
        //else
        begin
          bOk:=bJAS_Save_JMenu(p_Context, DBC, rJMenu,false,false,20160331208);
          {$IFDEF DIAGMSG}writeln('import call B - bJAS_Save_JMenu:',syesno(bOk),' UID:',rJMenu.JMenu_JMenu_UID,' Parent ID: ',rJMenu.JMenu_JMenuParent_ID);{$ENDIF}
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error, 201004201456, 'bImportMenuNode Failed - Unable to save NEW Menu Item','',SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;
        end;
      end;
      // END   ------- WRITE TO DATABASE COLLECTED INFORMATION
    until not p_XMLNODE.MoveNext;
    {$IFDEF DIAGMSG}Writeln('ENDING NEW NODE REPEAT LOOP');{$ENDIF}
   end;
  p_uNestLevel-=1;
  result:=bOk;
  {$IFDEF DIAGMSG}JASPRintln('bImportMenuNode------------END');{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102428,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
procedure JAS_MenuImport(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  bAllNew: boolean;
  XML: JFC_XML;
  XMLNode: JFC_XML;// used as a reference so never created or destroyed.
  saRootNode: ansistring;
  uNestLevel: uint;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_MenuImport(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102429,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102430, sTHIS_ROUTINE_NAME);{$ENDIF}

  {$IFDEF DIAGMSG}
  JASPrintln(saRepeatChar('=',79));
  JASPrintln('JAS_MenuImport - Begin');
  JASPrintln(saRepeatChar('=',79));
  {$ENDIF}

  XML:=JFC_XML.Create;
  p_Context.bNoWebCache:=true;

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204140328,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_MEnuImport);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201608241420, 'Access Denied.',
        'User: '+inttostr(p_COntext.rJUser.JUser_JUser_UID)+' '+
        p_Context.rJUser.JUSer_Name,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

{$IFDEF DIAGMSG}JASPrintln('JAS_MenuImport - A - bOk: '+sYesNo(bok));{$ENDIF}
  if bOk then
  begin
    bOk:=(p_Context.CGIENV.FilesIn.ListCount>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004191820, 'JAS_MenuImport Failed - File didn''t transmit successfully. Hint: Try refreshing this page.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
{$IFDEF DIAGMSG}JASPrintln('JAS_MenuImport - B - bOk: '+sYesNo(bok));{$ENDIF}
  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('uploadedfile');
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004191821, 'JAS_MenuImport Failed - File didn''t transmit successfully. Hint: Try refreshing this page.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
{$IFDEF DIAGMSG}JASPrintln('JAS_MenuImport - C - bOk: '+sYesNo(bok));{$ENDIF}
  if bOk then
  begin
    bOk:=p_Context.CGIENV.FilesIn.FoundItem_saName('uploadedfile');
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004191822, 'JAS_MenuImport Failed - File didn''t transmit successfully. Hint: Try refreshing this page.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
{$IFDEF DIAGMSG}JASPrintln('JAS_MenuImport - D - bOk: '+sYesNo(bok));{$ENDIF}
  if bOk then
  begin
    bAllNew:=p_Context.CGIENV.DataIn.Get_saValue('importmethod')='ALLNEW';
    {$IFDEF DIAGMSG}
      jASPrintln(saRepeatChar('+',79));
      jASPrintln('JAS_MenuImport - FILE BEGIN');
      jASPrintln(saRepeatChar('+',79));
      jASPRintln(p_Context.CGIENV.FilesIn.Get_saValue('uploadedfile'));
      jASPrintln(saRepeatChar('+',79));
      jASPrintln('JAS_MenuImport - FILE END');
      jASPrintln(saRepeatChar('+',79));
      //riteln('press enter');
      //readln;
    {$ENDIF}
    bOk:=XML.bParseXML(p_Context.CGIENV.FilesIn.Get_saValue('uploadedfile'));
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004201451, 'JAS_MenuImport Failed - XML Parsing Failed:'+XML.saLastError,'',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
    jas_log(p_COntext,cnLog_Debug,201608151857,'Menu Editor Import - XML REGURGITATED:'+XML.saXML(false,false),'',SOURCEFILE);
  end;
{$IFDEF DIAGMSG}JASPrintln('JAS_MenuImport - E - bOk: '+sYesNo(bok));{$ENDIF}
  if bOk then
  begin
    saRootNode:=inttostr(u8Val(p_Context.SessionXDL.Get_saValue('NODE')));
    bOk:=XML.MoveFirst;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004201452, 'JAS_MenuImport Failed - XML MoveFirst Failed.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=XML.Item_saName='xml';
    if not bOk then XML.DeleteItem;//MoveNext;//pass the xml spec line
    bOk:=XML.Item_saName='xml';
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004201453, 'JAS_MenuImport Failed - Invalid Node. Expected "xml" but got "'+XML.Item_saName+'"','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=XML.Item_lpPtr<>nil;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201004201454, 'JAS_MenuImport Failed - Missing Childnode(s).','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    XMLNode:=JFC_XML(XML.Item_lpPtr);
    uNestLevel:=0;
    bOk:=bImportMenuNode(p_Context, XMLNODE, bOk, u8Val(saRootNode), bAllNew, uNestLevel);
    if not bOk then
    begin
      // Gonna have the bImportMenuNode recursive function handle its own logging of errors.
      // JAS_Log(p_Context,cnLog_Error, 201004201455, 'JAS_MenuImport Failed - bImportMenuNode Returned with an error.','',SOURCEFILE);
      // RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    p_Context.saPage+='<html><body><h1>Menu imported</h1></body></html>';
    p_Context.saPage:=saGetPage(p_Context,'sys_area_nosig','sys_page_menueditor_import_complete','',false,'',123020100050);
  end;

  XML.Destroy;

  {$IFDEF DIAGMSG}
  JASPrintln(saRepeatChar('=',79));
  JASPrintln('JAS_MenuImport - END - bOk:'+sTrueFalse(bOk));
  JASPrintln(saRepeatChar('=',79));
  {$ENDIF}


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102431,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
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
