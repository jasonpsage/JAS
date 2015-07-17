//=============================================================================
// Note: History at end of File
//=============================================================================
// Search for !@! to get the various sections of interface
// Search for !#! to get the same secion of implmentation
// ^---- Trying to get this to be correct, not yet though
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{$DEFINE ENABLECYCLE}  // from gui/we/ajax/api
{$DEFINE ENABLESHUTDOWN} // from gui/we/ajax/api
//=============================================================================





//=============================================================================
{}
// Main UNIT for JAS Application
Unit uj_application;
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

{$INCLUDE i_jegas_macros.pp}
//=============================================================================
{$DEFINE SOURCEFILE:='uj_application.pp'}
{DEFINE DEBUGLOGBEGINEND} // use for debugging only
{DEFINE SAVE_ALL_OUTPUT}
{DEFINE SAVE_HTMLRIPPER_OUTPUT}
{DEFINE DIAGNOSTIC_LOG}
{DEFINE DIAGNOSTIC_WEB_MSG}
{DEFINE DBINDBOUT} // used for thread debugging, like begin and end sorta
                  // showthreads shows the threads progress with this.
                  // whereas debuglogbeginend is ONE log file for all.
                  // a bit messy for threads. See uxxg_jfc_threadmgr for
                  // mating define - to use this here, needs to be declared
                  // in uxxg_jfc_threadmgr also.
{DEFINE DEBUG_PARSEWEBSERVICEFILEDATA} // The ParseWebServiceFileData
                  // function has alot of JASDebugPrintLn commands that
                  // are great when debugging the parsing but overkill as
                  // debug output otherwise. Undefine to make those lines not
                  // get included in the compile.
//=============================================================================

//=============================================================================
// DEBUG/LOGGING Directives
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND}
{$ENDIF}
{$IFDEF DBINDBOUT}
  {$INFO | DBINDBOUT}
{$ENDIF}
{$IFDEF SAVE_HTMLRIPPER_OUTPUT}
  {$INFO | SAVE_HTMLRIPPER_OUTPUT}
{$ENDIF}
{$IFDEF SAVE_ALL_OUTPUT}
  {$INFO | SAVE_ALL_OUTPUT}
{$ENDIF}
{$IFDEF DIAGNOSTIC_LOG}
  {$INFO | DIAGNOSTIC_LOG}
{$ENDIF}
{$IFDEF DIAGNOSTIC_WEB_MSG}
  {$INFO | DIAGNOSTIC_WEB_MSG}
{$ENDIF}
{$IFDEF DEBUG_PARSEWEBSERVICEFILEDATA}
  {$INFO | DEBUG_PARSEWEBSERVICEFILEDATA}
{$ENDIF}
//=============================================================================

//=============================================================================
Uses 
//=============================================================================
classes
,syncobjs
,dos
,sysutils
,dateutils
,sockets
,process
,blcksock
,ssl_openssl
,Synautil
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_xml
,ug_jfc_tokenizer
,ug_jfc_dir
,ug_jfc_matrix
,ug_jfc_threadmgr
,ug_jfc_fifo
,ug_jfc_cgienv
,ug_tsfileio
,ug_jado
,uj_context
,uj_definitions
,uj_locking
,uj_fileserv
,uj_menusys
,uj_sessions
,uj_ui_stock
,uj_ui_screen
,uj_xml
,uj_menueditor
,uj_dbtools
,uj_permissions
,uj_iconhelper
,uj_jegas_customizations_empty
,uj_notes
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
// Dispatch of "Action" parameter to appropriate JAS App
procedure ExecuteJASApplication(p_Context: TCONTEXT);
//=============================================================================
{}
// Internal Test for uploading files to the system
// upload infrastructure is currently only a folder
// in [jasdir]upload
procedure MultipartUpload(p_Context: TCONTEXT);
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
function bJASMiniApps(p_Context: TCONTEXT; p_saAction: ansistring): boolean;
//=============================================================================
label donehere;
Var
  bOk:boolean;
  bCallResult: boolean;
  bGotOne: boolean;

  DBC: JADO_CONNECTION;
  RS: JADO_RECORDSET;
  XDL: JFC_XDL;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:=''; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203162129,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203162130, sTHIS_ROUTINE_NAME);{$ENDIF}

  bGotOne:=false;
  rs:=nil;
  DBC:=nil;
  XDL:=nil;

  if p_saAction='testjaslogthis' then
  begin
    bGotOne:=true;
    DBC:=p_Context.VHDBC;
    RS:=JADO_RECORDSET.Create;
    JAS_Log(p_Context,cnLog_Debug, 201001230228,'JAS_Logthis - Test Msg ONE','JAS_Logthis - Test More Info', SOURCEFILE);
    JAS_Log(p_Context,cnLog_Debug, 201001230228,'JAS_Logthis - Test Msg TWO','JAS_Logthis - Test More Info', SOURCEFILE, DBC);
    JAS_Log(p_Context,cnLog_Debug, 201001230228,'JAS_Logthis - Test Msg THREE','JAS_Logthis - Test More Info', SOURCEFILE, RS);
    JAS_Log(p_Context,cnLog_Debug, 201001230228,'JAS_Logthis - Test Msg FOUR','JAS_Logthis - Test More Info', SOURCEFILE, DBC,RS);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test JAS_LogThis</h1>'+
      '<p>Four entries were made in the log file with a Message ID of: 201001230228. Below is a dump' +
      'of the ErrorXXDL list in HTML format. If it has zero rows then no errors were reported.</p>'+
      p_Context.LogXXDL.saHTMLTable,123020100055
    );
    RS.Destroy;rs:=nil;
    DBC:=nil;
    goto DoneHere;
  end else

  if p_saAction='testbjaslockrecord' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_LockRecord(p_Context,'0','jcolumn', '1','0',201501020060);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_LockRecord</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_LockRecord(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020060)</p>',
      123020100056
    );
    goto DoneHere;
  end else

  if p_saAction='testbjasrecordlockvalid' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_RecordLockValid(p_Context,'0','jcolumn', '1','0',201501020061);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_RecordLockValid</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: RecordLockValid(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020061)</p>',
      123020100057
    );
    goto DoneHere;
  end else

  if p_saAction='testbjasunlockrecord' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_UnlockRecord(p_Context,'0','jcolumn', '1','0',201501020062);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_UnlockRecord</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_UnlockRecord(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020062)</p>',
      123020100058
    );
    goto DoneHere;
  end else

  if p_saAction='testbjaspurgelocks' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_PurgeLocks(p_Context,5);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_PurgeLocks</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_PurgeLocks(p_Context,5)</p>',
      123020100059
    );
    goto DoneHere;
  end else

  if p_saAction='testbjascreatesession' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_CreateSession(p_Context);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_CreateSession</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_CreateSession(p_Context)</p>',
      123020100060
    );
    goto DoneHere;
  end else

  if p_saAction='testbjasvalidatesession' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_ValidateSession(p_Context);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_ValidateSession</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_ValidateSession(p_Context)</p>',
      123020100061
    );
    goto DoneHere;
  end else

  if p_saAction='testbjasremovesession' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_RemoveSession(p_Context);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_RemoveSession</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_RemoveSession(p_Context)</p>',
      123020100062
    );
    goto DoneHere;
  end else

  if p_saAction='testsajasgetsessionkey' then
  begin
    bGotOne:=true;
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test saJAS_GetSessionKey</h1>'+
      '<p>Result: '+saJAS_GetSessionKey+'</p>'+
      '<p>Call Made: saJAS_GetSessionKey</p>',
      123020100063
    );
    goto DoneHere;
  end else

  if p_saAction='testbjaspurgeconnections' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_PurgeConnections(p_Context,5);
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_PurgeConnections</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_PurgeConnections(p_Context,5)</p>',
      123020100064
    );
    goto DoneHere;
  end else

  if p_saAction='testsandbox' then
  begin
    bGotOne:=true;
    // --test code to do with JADOC connection array
    //TEMPJADOC:=p_Context.DBCon('Vtiger');
    //p_Context.saPage:=TEMPJADOC.saName;
    //p_Context.saPage:=p_Context.DBCon('Vtiger').saName+' length(p_Context.JADOC):'+inttostr(length(p_Context.JADOC));
    p_Context.saPage:='<h1>Test Sandbox</h1>';
    p_Context.saPage+='<p>This action is reserved for internal testing of components in the system during development.</p>';
    p_Context.CGIENV.Header_Html(garJVHostLight[p_Context.i4VHost].saServerIdent);
    goto DoneHere;
  end else

  if p_saAction='cycleserver' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201008011633;
      p_Context.saErrMsg:='Valid Session required for this operation.';
      p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      p_Context.saOut:=p_Context.saPage;
    end;

    if bOk then
    begin
      {$IFDEF ENABLECYCLE}
        bOk:=bJAS_HasPermission(p_Context,cnJSecPerm_CycleServer);
        if not bOk then
        begin
          p_Context.u8ErrNo:=201008011639;
          p_Context.saErrMsg:='Required Permission not granted: Cycle JAS Server';
          p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ELSE}
        bOk:=false;
        if not bOk then
        begin
          p_Context.u8ErrNo:=201503071116;
          p_Context.saErrMsg:='Cycling the server is disabled.';
          p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ENDIF}
    end;

    if bOk then
    begin
      p_Context.XML.bParseXML('<Success />');
      p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      gbServerCycling:=true;
      p_Context.saOut:=p_Context.saPage;
    end;
    goto DoneHere;
  end else

  if p_saAction='shutdownserver' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201008011803;
      p_Context.saErrMsg:='Valid Session required for this operation.';
      p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      p_Context.saOut:=p_Context.saPage;
    end;

    if bOk then
    begin
      {$IFDEF ENABLESHUTDOWN}
        bOk:=bJAS_HasPermission(p_Context,cnJSecPerm_ShutDownServer);
        if not bOk then
        begin
          p_Context.u8ErrNo:=201008011804;
          p_Context.saErrMsg:='Required Permission not granted: Shutdown JAS Server';
          p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ELSE}
        bOk:=false;
        if not bOk then
        begin
          p_Context.u8ErrNo:=201503071204;
          p_Context.saErrMsg:='Shutdown feature disabled.';
          p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_500;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ENDIF}
    end;

    if bOk then
    begin
      p_Context.XML.bParseXML('<Success />');
      p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      gbServerShuttingDown:=true;
      p_Context.saOut:=p_Context.saPage;
    end;
    goto DoneHere;
  end else

  if p_saAction='tableexist' then
  begin //54
    bGotOne:=true;
    bCallResult:=bJAS_TableExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID'));
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test JAS_TableExist</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: JAS_TableExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID')+')</p>',
      201202251904
    );
    goto DoneHere;
  end else

  if p_saAction='columnexist' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_ColumnExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('JColu_JColumn_UID'));
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_ColumnExist</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_ColumnExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('JColu_JColumn_UID')+')</p>',
      201202251905
    );
    goto DoneHere;
  end else

  if p_saAction='rowexist' then
  begin
    bGotOne:=true;
    bCallResult:=bJAS_RowExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('UID'),p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID'));
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>Test bJAS_RowExist</h1>'+
      '<p>Result: '+saTrueFalse(bCallResult)+'</p>'+
      '<p>Call Made: bJAS_RowExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('UID')+','+p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID')+')</p>',
      201202251906
    );
    goto DoneHere;
  end else

  if p_saAction='generateseckeys' then
  begin 
    bGotOne:=true;
    p_Context.saPage:=saGetPage(p_Context,'','','',false,
      '<h1>GenerateSecKeys</h1>'+
      '<p>Result: '+saTrueFalse(bJAS_GenerateSecKeys(p_ContexT))+'</p>',123020100069);
    goto DoneHere;
  end else

  if p_saAction='redirect2google' then
  begin 
    bGotOne:=true;
    JAS_LOG(p_Context, cnLog_Debug, 201203311242, 'IN  p_Context.CGIENV.iHTTPResponse:'+inttostr(p_Context.CGIENV.iHTTPResponse),'',SOURCEFILE);
    p_Context.CGIENV.Header_Redirect('http://www.google.com',garJVHostLight[p_Context.i4VHost].saServerIdent);
    JAS_LOG(p_Context, cnLog_Debug, 201203311243, 'OUT p_Context.CGIENV.iHTTPResponse:'+inttostr(p_Context.CGIENV.iHTTPResponse),'',SOURCEFILE);
    goto DoneHere;
  end else

  if p_saAction='databasescrub' then 
  begin
    bGotOne:=true;
    //AS_LOG(p_COntext,cnLog_Debug,201503082119,'Database Scrub - requested','',SOURCEFILE);
    //p_Context.saPage:=saGetPage(p_Context,'','','',false,
    //  '<h1>Database Scrub</h1>'+
    //  '<p>Result: '+saTrueFalse(bDBM_DatabaseScrub(p_Context))+'</p>',201503082231);
    bDBM_DatabaseScrub(p_Context);
    goto DoneHere;
  end;
  
  
  
  
  if p_saAction='debugsession' then
  begin
    bGotOne:=true;
    p_Context.CGIENV.iHTTPResponse:=200;
    p_Context.saPage:='<h2>Session Debug</h2>';
    if p_Context.CGIENV.CkyIn.FoundItem_saName('JSID') then
    begin
      p_Context.saPage+='<p>CkyIn JSID Found: '+p_Context.CGIENV.CkyIn.Item_saValue+'</p>';
    end
    else
    begin
      p_Context.saPage+='<p>CkyIn JSID Not Found.</p>';
    end;
    
    if p_Context.CGIENV.DataIn.FoundItem_saName('JSID') then
    begin
      p_Context.saPage+='<p>DataIn JSID Found: '+p_Context.CGIENV.DataIn.Item_saValue+'</p>';
    end
    else
    begin
      p_Context.saPage+='<p>DataIn Not Found.</p>';
    end;
    p_Context.saPage+='<p>Session Valid: '+saYesNo(p_Context.bSessionValid)+'</p>'; 
    
    DBC:=p_Context.VHDBC;
    RS:=JADO_RECORDSET.Create;
    XDL:=JFC_XDL.Create;
    if rs.open('select JSess_JSession_UID, JSess_JUser_ID from jsession',DBC,201503161600) then
    begin
      if not rs.eol then
      begin
        repeat
          XDL.AppendItem_saName_N_saValue(rs.fields.Get_saValue('JSess_JSession_UID'),rs.fields.Get_savalue('JSess_JUser_ID'));
        until not rs.movenext;
      end;
    end;
    rs.close;
    p_Context.saPage+='<p>Session Table Results</p><p>'+XDL.saHTMLTable+'</p>';
    rs.destroy;
    xdl.destroy;
    goto DoneHere;
  end;
  



DoneHere: ;

  result:=bGotOne;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203162131,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





























//=============================================================================
procedure ExecuteJASApplication(p_Context: TCONTEXT);
//=============================================================================
label donehere;
Var
  bOk:boolean;
  saTempGetPageData: Ansistring;
  saAction: Ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:=''; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102750,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102751, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  p_Context.dtRequested:=now;
  //p_Context.saPage:='<html><body><h1>TESTING</h1></body></html>';

  {$IFDEF DIAGNOSTIC_WEB_MSG}
  JASPrintln('------------------------------------------------------------------');
  JASPrintln('ExecutingJegasApplication------------------------------------BEGIN');;
  JASPrintln('------------------------------------------------------------------');
  {$ENDIF}

  saAction:=lowercase(trim(p_Context.CGIENV.DataIn.Get_saValue('ACTION')));
  bOk:=not p_Context.bErrorCondition;
  if not bOk then
  begin
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    if saAction='welcome' then
    begin
      p_Context.saPage:=saGetPage(p_Context,'','','',false,'<h1>Welcome to JAS!</h1>',123020100054);
      p_Context.CGIENV.iHTTPResponse:=cnHTTP_Response_200;
      goto DoneHere;
    End;

    if saAction='csvimport' then                begin CSVImport(p_Context);                     goto donehere; end;
    if saAction='csvmapfields' then             begin CSVMapFields(p_Context);                  goto donehere; end;
    if saAction='csvupload' then                begin CSVupload(p_Context);                     goto donehere; end;
    if saAction='deleterecordlocks' then        begin JAS_DeleteRecordLocks_StockUI(p_Context); goto DoneHere; end;
    if saAction='diagnostichtmldump' then       begin JAS_DiagnosticHtmlDump(p_Context);        goto DoneHere; end;
    if saAction='emptytrash' then               begin DBM_EmptyTrash(p_Context);                goto DoneHere; end;
    if saAction='getnotesecure' then            begin JAS_NoteSecure(p_Context);                goto DoneHere; end;
    if saAction='jassqltool' then               begin JASSQLTool(p_Context);                    goto DoneHere; end;
    if saAction='jiconhelper' then              begin JIconHelper(p_Context);                   goto DoneHere; end;
    if saAction='createscreensfortable' then    begin JAS_CreateScreensForTable(p_Context);     goto DoneHere; end;
    if saAction='deletetable' then              begin JAS_DeleteTable(p_Context);               goto DoneHere; end;
    if saAction='killorphans' then              begin DBM_KillOrphans(p_Context);               goto DoneHere; end;
    if saAction='login' then                    begin Login(p_Context);                         goto DoneHere; End;
    if saAction='logout' then                   begin LogOut(p_Context);                        goto DoneHere; End;
    if saAction='menueditor' then               begin JAS_MenuEditor(p_Context);                goto DoneHere; end;
    if saAction='menuexport' then               begin JAS_MenuExport(p_Context);                goto DoneHere; end;
    if saAction='menuimport' then               begin JAS_MenuImport(p_Context);                goto DoneHere; end;
    if saAction='multipartupload' then          begin MultipartUpload(p_Context);               goto DoneHere; end;
    if saAction='rendermindmap' then            begin JAS_RenderMindMap(p_Context);             goto DoneHere; end;
    if saAction='syncdbmscolumns' then          begin DBM_Syncdbmscolumns(p_Context);           goto DoneHere; end;
    if saAction='syncscreenfields' then         begin DBM_SyncScreenFields(p_Context);          goto DoneHere; end;
    if saAction='xmltest' then                  begin JAS_XmlTest(p_Context);                   goto DoneHere; end;
    if saAction='jcaptionflagorphans' then      begin DBM_JCaptionFlagOrphans(p_Context);       goto DoneHere; end;
    if saAction='jnoteflagorphans' then         begin DBM_JNoteFlagOrphans(p_Context);          goto DoneHere; end;
    if saAction='promotelead' then              begin JAS_PromoteLead(p_Context);               goto DoneHere; end;
    if saAction='merge' then                    begin JAS_Merge(p_Context);                     goto DoneHere; end;
    if saAction='wipeallrecordlocks' then       begin DBM_WipeAllRecordLocks(p_Context);        goto DoneHere; end;
    if saAction='updatecompanymembers' then     begin DBM_UpdateJCompanyMember(p_Context);      goto donehere; end;
    if saAction='fileupload' then               begin FileUpload(p_Context);                    goto donehere; end;
    if saAction='filedownload' then             begin FileDownload(p_Context);                  goto donehere; end;
    if saAction='copysecuritygroup' then        begin JAS_CopySecurityGroup(p_Context);         goto donehere; end;
    if saAction='verifyemail' then              begin JAS_VerifyEmail(p_Context);               goto donehere; end;
    if saAction='deletescreen' then             begin JAS_DeleteScreen(p_Context);              goto donehere; end;
    if saAction='resetpassword' then            begin JAS_ResetPassword(p_Context);             goto donehere; end;
    if saAction='dbm_finddupeuid' then          begin DBM_FindDupeUID(p_Context);               goto donehere; end;
    if saAction='dbm_difftool' then             begin DBM_DiffTool(p_Context);                  goto donehere; end;
    if saAction='jas_calendar' then             begin JAS_Calendar(p_Context);                  goto donehere; end;
    if saAction='dbm_learntables' then          begin DBM_LearnTables(p_Context);               goto donehere; end;
    if saAction='flagjasrow' then               begin DBM_FlagJasRow(p_Context);                goto donehere; end;
    if saAction='flagjasrowexecute' then        begin DBM_FlagJasRowExecute(p_Context);         goto donehere; end;
    if saAction='createjet' then                begin JAS_CreateJet(p_Context);                 goto donehere; end;
    if saAction='removejet' then                begin DBM_RemoveJet(p_Context);                 goto donehere; end;
    if saAction='register' then                 begin JAS_Register(p_Context);                  goto donehere; end;
    if saAction='help' then                     begin JAS_Help(p_Context);                      goto donehere; end;

    if bJASMiniApps(p_Context,saAction) then goto DoneHere;

    //-------------------------------
    UserCustomizations(p_Context);
    //-------------------------------

donehere: ;

    {$IFDEF DIAGNOSTIC_WEB_MSG}
    JASPrintln(sTHIS_ROUTINE_NAME+'----After UserCustomizations----BEGIN');
    JASPrintln('p_Context.CGIENV.iHTTPResponse: '+inttostr(p_Context.CGIENV.iHTTPResponse));
    JASPrintln('p_Context.bOutputRaw: '+saTrueFalse(p_Context.bOutPutRaw));
    JASPrintln(sTHIS_ROUTINE_NAME+'----After UserCustomizations----END');
    {$ENDIF}

    If not p_Context.bOutputRaw Then
    Begin
      if p_Context.CGIENV.iHTTPResponse=0 then
      begin
        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPrintln('MENU ---------------------------------------BEGIN');
        {$ENDIF}
        p_Context.u8MenuTopID:=u8Val(p_Context.CGIENV.DATAIN.get_savalue('MT'));
        if (p_Context.u8MenuTopID=0) then
        begin
          p_Context.u8MenuTopID:=garJVhostLight[p_Context.i4VHost].u8DefaultTop_JMenu_ID;
        end;
        if (p_Context.u8MenuTopID=0) then
        begin
          p_Context.u8MenuTopID:=grJASConfig.u8DefaultTop_JMenu_ID;
        end;
        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPrintln('ReplaceJasMenu ---------------------------------------BEGIN');
        {$ENDIF}

        ReplaceJasMenuWithMenu(p_Context);

        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPrintln('ReplaceJasMenu ---------------------------------------END');
        {$ENDIF}
        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPrintln('MENU ---------------------------------------END');
        {$ENDIF}


        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPRintln('length(p_Context.saPage):'+saStr(length(p_Context.saPage)));
        {$ENDIF}

        If length(p_Context.saPage)=0 Then
        Begin
          If p_Context.CGIENV.DataIn.FoundItem_saName('SCREENID',false) or
             p_Context.CGIENV.DataIn.FoundItem_saName('SCREEN',false) Then
          Begin
            {$IFDEF DIAGNOSTIC_WEB_MSG}
            JASPrintln('SCREEN ---------------------------------------BEGIN');
            {$ENDIF}
            DynamicScreen(p_Context);
            //JASprintln('Page Len: '+inttostR(length(p_Context.saPage)));
            //JASprintln('Out Len: '+inttostR(length(p_Context.saOut)));
            //if length(p_Context.saPage)=0 then
            //begin
            //  RenderHTMLErrorPage(p_Context);
            //end;
            {$IFDEF DIAGNOSTIC_WEB_MSG}
            JASPrintln('SCREEN ---------------------------------------END');
            {$ENDIF}
          End;
        End;

        // HTML RIPPER CALL - When application hasn't generated error or p_Context.saPage data
        If (length(p_Context.saPage)=0) and (p_Context.bErrorCondition=false) Then
        Begin
          p_Context.bNoWebCache:=true;//qqq
          if p_Context.bMenuHasPanels then p_Context.saHTMLRipper_Section:='BLANK';
          saTempGetPageData:=saHtmlRipper(p_Context,123020100071);
          if(not p_Context.bErrorCondition)then
          begin
            if (p_Context.CGIEnv.iHttpResponse=0) then p_Context.CGIEnv.iHttpResponse:=200;
            p_Context.saPage:=saTempGetPageData;
          end;
        End;
        

        // SCAN OUTPUT PAGE FOR BLOCKS
        // if there are BLOCKS we can handle - do them until there are not anymore unhandled.
        // NOTE: Default "Can't do this now" or "You need to be logged in" or just BLANKS
        // need to replace blocks that can't be honored based on p_Context information.

        // Finishing up Here
        If length(p_Context.sapage)=0 Then
        Begin
          JAS_Log(p_Context,cnLog_Error,200609251532,'No Result Page Being Sent. This error can occur '+
            'from an invalid hyperlink or a bug in the software.','',SOURCEFILE);
          p_Context.bErrorCondition:=False; // We know there MAY have been an error but it didn't
          // create OUTPUT for the user. This error condition reset is to try to fool the system into rendering
          // an error page. Typically, well behaved code would have  already created an error
          // page and there isn't a need for this last ditch effort to let the user know what
          // is going on.
          //ASDebugPrintln('Last ditch effort - BEGIN - Page Length On enter:'+inttostr(length(p_Context.saPage)));
          RenderHtmlErrorPage(p_Context);
          //ASDebugPrintln('Last ditch effort - END - Page Length On enter:'+inttostr(length(p_Context.saPage)));
        End;
      end;  // p_Context.CGIENV.iHTTPResponse=0 then
      // FINAL Search-N-Replace for p_Context Stuff in User Pages.
      //ASDebugPrintln('DEBUG Begin adding p_Context stuff to PAGESNRXDL ');
    End;

    {$IFDEF SAVE_HTMLRIPPER_OUTPUT}
    If (p_Context.saHTMLRIPPER_Area<>'') and
       (p_Context.saHTMLRIPPER_Page<>'') and
       (p_Context.saHTMLRIPPER_Section<>'') Then
    Begin
      If p_Context.saHTMLRIPPER_Area='htmlripper' Then
      Begin
        p_Context.saHTMLRIPPER_Area:='';
      End
      Else
      Begin
        p_Context.saHTMLRIPPER_Area+='_';
      End;
      bTSIOAppend(
        grJASConfig.saLogDir+LowerCase(p_Context.saHTMLRIPPER_Area)+LowerCase(p_Context.saHTMLRIPPER_Page)+'_'+LowerCase(p_Context.saHTMLRIPPER_Section)+csJASFileExt,
        p_Context.saPage
      );
    End;
    {$ENDIF}
    p_Context.dtFinished:=now;

    if p_Context.bSaveSessionData then
    begin
      bOk:=bJas_SaveSessionData(p_Context);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201202261101, 'uj_application - call to bJAS_SaveSessionData failed.','',SOURCEFILE);
      end;
    end;
  end;

  {$IFDEF DIAGNOSTIC_WEB_MSG}
  JASPrintln('.................................................................');
  JASPrintln(sTHIS_ROUTINE_NAME+'-------------------------------------End');;
  JASPrintln('.................................................................');
  {$ENDIF}



{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102752,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
procedure MultipartUpload(p_Context: TCONTEXT);
//=============================================================================
var   bOk:boolean;
  saFilename: ansistring;
  u2IOResult: word;
  flog: text;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='MultipartUpload(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102753,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102754, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201110162222,
      'Session not valid, upload not permitted.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
    p_Context.saPage:='<html><h1>Multi-Part Received.</h1>';
    if p_Context.CGIENV.FilesIn.MoveFirst then
    begin
      repeat
        if p_Context.CGIENV.DataIn.FoundItem_saName(p_Context.CGIENV.FilesIn.Item_saName) then
        begin
          p_Context.saPage+='<p>File:'+p_Context.CGIENV.DataIn.Item_saValue+'</p>';
        end;
        p_Context.saPage+='<hr />';
        //p_Context.saPage+='<textarea>'+p_Context.CGIENV.FilesIn.Item_saValue+'</textarea>';
        saFilename:=garJVHostLight[p_Context.i4VHost].saFileDir+p_Context.CGIENV.DataIn.Item_saValue;
        bOk:=bTSOpenTextFile(
          saFilename,
          u2IOResult,
          FLog,
          false,
          false);
        if not bok then
        begin
          JAS_Log(p_Context,cnLog_Error,201110161638,'Unable to save uploaded file.','',SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;

        if bOk then
        begin
          write(flog,p_Context.CGIENV.FilesIn.Item_saValue);
          bOk:=bTSCloseTextFile(safilename,u2IOResult,FLog)
        end;

        if not bok then
        begin
          JAS_Log(p_Context,cnLog_Error,201110161639,
            'Unable to closed open file: '+saFilename,'',SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;
      until not p_Context.CGIENV.FilesIn.Movenext;
      if bOk then p_Context.saPage+='</html>';

    end
    else
    begin
      p_Context.saPage+='<h1>No File(s) Received.</h1>';
    end;
  end;
  //p_Context.bOutputRaw:=true;
  p_Context.CGIENV.Header_Html(garJVHostLight[p_Context.i4VHost].saServerIdent);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102755,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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

//=============================================================================
// History (Please Insert Historic Entries at top)
//=============================================================================
// Date        Who             Notes
//=============================================================================
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
