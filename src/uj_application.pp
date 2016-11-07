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
,uj_email
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
// Dispatch of "Action" parameter to appropriate JAS App
procedure ExecuteJASApplication(p_Context: TCONTEXT);
//=============================================================================
{}
// Internal Test for uploading files to the system
// upload infrastructure is currently only a folder
// in [jasdir]upload
procedure MultipartUpload(p_Context: TCONTEXT);
//=============================================================================
{}
// allows user to change thier background
procedure JASAPI_JUser_Background(p_Context: TCONTEXT);
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
{}
// change the logged in user's background color.
procedure JASAPI_JUser_Background(p_Context: TCONTEXT);
//=============================================================================
var
  saQry: AnsiString;
  rs: JADO_RECORDSET;
  //bDone: Boolean;
  DBC: JADO_CONNECTION;

  DirDL: JFC_DIR;
  //saFancyYes: ansistring;
  //saFancyNo: ansistring;
  //saFancyFolder: ansistring;
  //saFancyFile: ansistring;
  saDirRender: ansistring;
  sFileSpec: string[5];

  sDIR: String;
  sName: String;
  sExt: String;
  sExtLower: string;

  //saLinkFragment: ansistring;
  bOk: boolean;
  saChose: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='JASAPI_JUser_Background';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102648,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102649, sTHIS_ROUTINE_NAME);{$ENDIF}
  //bDone:=False;
  DBC:=p_Context.VHDBC;
  if not p_Context.bSessionValid then
  begin
    p_Context.u8ErrNo:=201610301449;
    p_Context.saPageTitle:='Access Denied';
    p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181704);
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
    p_Context.bNoWebCache:=true;
  end
  else
  begin
    if p_COntext.CGIENV.DataIn.FoundItem_saName('CHOSE') then
    begin
      saChose:=p_COntext.CGIENV.DataIn.Item_saValue;
      if saChose='!!!NO-BACKGROUNDS.PNG' then saChose:='' else
      if saChose<>'' then saChose:='/jws/img/backgrounds/'+saChose;
      saQry:='update juser set JUser_Background='+DBC.saDBMSScrub(saChose) + ' ' +
        'where ((JUser_Deleted_b=false)OR(JUser_Deleted_b IS NULL)) and (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUSer_UID)+')';
      rs:=JADO_RECORDSET.Create;
      bOk:=rs.open(saQry,DBC,201610301810);
      rs.destroy;rs:=nil;
      //bok:=false;
      if not bOk then
      begin
        p_Context.u8ErrNo:=201610301811;
        p_Context.saPageTitle:='Error updating your user record.';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181704);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Unable to change background image.</h1> File >'+saChose+'< Note: Nothing is a valid selection. If this problem persists, report it to your administrator.');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
      end
      else
      begin
        p_Context.saPageTitle:='Clear Your Cache Now!';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181704);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Background Image Saved!</h1> Clear your Cache, just the cache, '+
          'keep your cookies and things, we just want the next JAS page you load to use your new background image versus the previous one. You can close this window now.');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
      end;
    end
    else
    begin
      {$IFDEF WINDOWS}
        sFileSpec:='*.*';
      {$ELSE}
        sFileSpec:='*';
      {$ENDIF}


      //Type JFC_DIRENTRY = Class
      ////=============================================================================
      //  u1Attr : Byte; {attribute of found file}
      //  i4Time : LongInt; {last modify date of found file}
      //  i4Size : LongInt; {file size of found file}
      //  u2Reserved : Word; {future use}
      //  saName : AnsiString; {name of found file}
      //  saSearchSpec: AnsiString; {search pattern}
      //  u2NamePos: Word; {end of path, start of name position}
      //
      //  {$IFDEF LINUX}
      //  i4SearchNum: LongInt; {to track which search this is}
      //  i4SearchPos: LongInt; {directory position}
      //  i4DirPtr: LongInt; {directory pointer for reading directory}
      //  u1SearchType: Byte; {0=normal, 1=open will close}
      //  u1SearchAttr: Byte; {attribute we are searching for}
      //  {$ENDIF}
      //End;

      if p_Context.sIconTheme='' then p_Context.sIconTheme := garJVHost[p_Context.u2Vhost].VHost_DefaultIconTheme;
      if p_Context.sIconTheme='' then p_Context.sIconTheme := 'Nuvola';
      //saFancyFolder:='<img title="No" class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+p_Context.sIconTheme+'/22/places/folder.png" />';
      //saFancyFile:='<img title="No" class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+p_Context.sIconTheme+'/22/actions/document-new.png" />';

      //DBC:=p_Context.VHDBC;
      //rs:= JADO_RECORDSET.Create;

      DirDL:=JFC_DIR.Create;
      DirDL.saPath:=saAddSlash(FEXPAND(garJVHost[p_Context.u2VHost].VHost_WebShareDir))+'img'+DOSSLASH+'backgrounds'+DOSSLASH;
      DirDL.bDirOnly:=false;
      DirDL.saFileSpec:=sFileSpec;
      DirDL.bSort:=true;
      DirDL.bSortAscending:=true;
      DirDL.bSortCaseSensitive:=false;
      DirDL.LoadDir;

      //saDirRender:=
      //'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'+csCRLF+
      //  '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >'+
      //  '<head><title>[@PAGETITLE@]</title></head><body>'+
      //saDirRender:='<h2>'+FEXPAND(garJVHost[p_Context.u2VHost].VHost_WebShareDir)+'</h2>'+
      //  'ListCount: '+inttostr(DirDL.ListCount)+'<br />'+
      //  '<table>';
      saDirRender:='<h3>Chose your background image below.</h1><p>Remember you '+
        'can select repeating backgrounds for ones you wish to tile; also you '+
        'have to clear your cache to see your new background.</p>';// UID: '+inttostr(p_Context.rJUser.JUser_JUSer_UID)+'<br />';
      if DirDL.movefirst then
      begin
        repeat
          FSplit(DirDL.Item_saName,sDir,sName,sExtLower);
          sExt:=Uppercase(sExtLower);
          //saDirRender+='<tr><td>'+sName+'</td><td>'+sExt+'</td></tr>';
          if (LeftStr(sName,6)='thumb_') and (DirDL.Item_bDir=false) and ((sExt='.SVG') or (sExt='.GIF') or (sExt='.BMP') or (sExt='.PNG') or (sExt='.JPG') or (sExt='.JPEG') or (sExt='.ICO')) then
          begin
            ////////////////
            ////////////////
            ////////////////
            saDirRender+='<a href="?action=userbackground&JSID='+inttostr(p_Context.rJSession.JSess_JSession_UID)+'&CHOSE='+rightstr(sName,length(sName)-6)+sExtLower+'"><img class="image" width="256px" src="/jws/img/backgrounds/'+DirDL.Item_saName+'" /></a>';
            ////////////////
            ////////////////
            ////////////////


            saDirRender+='</td></tr>'+csCRLF;

            //if DirDL.Item_bReadOnly then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
            //saDirRender+='</td><td>';
            //if DirDL.Item_bHidden then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
            //saDirRender+='</td><td>';
            //if DirDL.Item_bSysFile then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
            //saDirRender+='</td><td>';
            //if DirDL.Item_bVolumeID then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
            //saDirRender+='</td><td>';
            //if DirDL.Item_bDir then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
            //saDirRender+='</td><td>';
            //if DirDL.Item_bArchive then saDirRender+=saFancyYes else saDirRender+=saFancyNo;
          end;
        until not DirDL.MoveNext;
      end;
      saDirRender+='</table></body></html>';
      p_Context.saPageTitle:='Choose Background';
      p_Context.saPage:=saDirRender;//saGetPage(p_Context,'','sys_page_message','',false,201605181704);
      //p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',saDirRender);
      //p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      DirDL.Destroy;DirDL:=nil;
    end;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201610301443,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












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
  saQry: ansistring;
  XDL: JFC_XDL;

  //saSrc,saDest: ansistring;
  uListLen: UINT;
  u:uint;
  saHTML: ansistring;
  u2IOResult:word;
  sSenderEmailAddress: string;
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
    bOk:=p_Context.bSessionValid;//lockdown
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141611;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181346);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testjaslogthis);
      p_Context.u8ErrNo:=201607141612;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181346);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      DBC:=p_Context.VHDBC;
      RS:=JADO_RECORDSET.Create;
      JAS_Log(p_Context,cnLog_Debug, 201001230228,'JAS_Logthis - Test Msg ONE','JAS_Logthis - Test More Info', SOURCEFILE);
      JAS_Log(p_Context,cnLog_Debug, 201001230229,'JAS_Logthis - Test Msg TWO','JAS_Logthis - Test More Info', SOURCEFILE, DBC);
      JAS_Log(p_Context,cnLog_Debug, 201001230230,'JAS_Logthis - Test Msg THREE','JAS_Logthis - Test More Info', SOURCEFILE, RS);
      JAS_Log(p_Context,cnLog_Debug, 201001230231,'JAS_Logthis - Test Msg FOUR','JAS_Logthis - Test More Info', SOURCEFILE, DBC,RS);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test JAS_LogThis</h1>'+
        '<p>Four entries were made in the log file with a Message ID of: 201001230228. Below is a dump' +
        'of the ErrorXXDL list in HTML format. If it has zero rows then no errors were reported.</p>'+
        p_Context.LogXXDL.saHTMLTable,123020100055
      );
      RS.Destroy;rs:=nil;
      DBC:=nil;
      goto DoneHere;
    end;
  end else

  if p_saAction='testbjaslockrecord' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141647;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181348);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjaslockrecord);
      p_Context.u8ErrNo:=201607141649;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181350);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_LockRecord(p_Context,0,'jcolumn', 1,0,201501020060);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_LockRecord</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_LockRecord(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020060)</p>',
        123020100056
      );
      goto DoneHere;
    end;
  end else

  if p_saAction='testbjasrecordlockvalid' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141651;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181352);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjasrecordlockvalid);
      p_Context.u8ErrNo:=201607141653;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181354);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_RecordLockValid(p_Context,0,'jcolumn', 1,0,201501020061);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_RecordLockValid</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: RecordLockValid(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020061)</p>',
        123020100057
      );
      goto DoneHere;
    end;
  end else




  if p_saAction='testbjasunlockrecord' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141655;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181356);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjasunlockrecord);
      p_Context.u8ErrNo:=201607141657;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181358);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_UnlockRecord(p_Context,0,'jcolumn', 1,0,201501020062);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_UnlockRecord</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_UnlockRecord(p_Context,''0'',csTable_jcolumn, ''1'',''0'',201501020062)</p>',
        123020100058
      );
      goto DoneHere;
    end;
  end else





  if p_saAction='testbjaspurgelocks' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141659;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181360);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjaspurgelocks);
      p_Context.u8ErrNo:=201607141661;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181362);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_PurgeLocks(p_Context,5);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_PurgeLocks</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_PurgeLocks(p_Context,5)</p>',
        123020100059
      );
      goto DoneHere;
    end;
  end else






  if p_saAction='testbjascreatesession' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141663;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181364);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjascreatesession);
      p_Context.u8ErrNo:=201607141665;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181366);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_CreateSession(p_Context);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_CreateSession</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_CreateSession(p_Context)</p>',
        123020100060
      );
      goto DoneHere;
    end;
  end else






  if p_saAction='testbjasvalidatesession' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141667;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181368);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjasvalidatesession);
      p_Context.u8ErrNo:=201607141669;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181370);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_ValidateSession(p_Context);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_ValidateSession</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_ValidateSession(p_Context)</p>',
        123020100061
      );
      goto DoneHere;
    end;
  end else





  if p_saAction='testbjasremovesession' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141671;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181372);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjasremovesession);
      p_Context.u8ErrNo:=201607141673;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181374);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_RemoveSession(p_Context);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_RemoveSession</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_RemoveSession(p_Context)</p>',
        123020100062
      );
      goto DoneHere;
    end;
  end else






  if p_saAction='testsajasgetsessionkey' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141675;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181376);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testsajasgetsessionkey);
      p_Context.u8ErrNo:=201607141677;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181378);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test saJAS_GetSessionKey</h1>'+
        '<p>Result: '+inttostr(u8JAS_GetSessionKey)+'</p>'+
        '<p>Call Made: saJAS_GetSessionKey</p>',
        123020100063
      );
      goto DoneHere;
    end;
  end else




  if p_saAction='testbjaspurgeconnections' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141679;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181380);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testbjaspurgeconnections);
      p_Context.u8ErrNo:=201607141681;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181382);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_PurgeConnections(p_Context,5);
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_PurgeConnections</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_PurgeConnections(p_Context,5)</p>',
        123020100064
      );
      goto DoneHere;
    end;
  end else


  if p_saAction='testsandbox' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141683;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181384);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_testsandbox);
      p_Context.u8ErrNo:=201607141685;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181386);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      p_Context.saPage:='<h1>Test Sandbox</h1>';
      p_Context.saPage+='<p>This action is reserved for internal testing of components in the system during development.</p>';
      p_Context.CGIENV.Header_Html(garJVHost[p_Context.u2VHost].VHost_ServerIdent);
      goto DoneHere;
    end;
  end else





  if p_saAction='cycleserver' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201008011633;
      p_Context.saErrMsg:='Valid Session required for this operation.';
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      p_Context.saOut:=p_Context.saPage;
    end;

    if bOk then
    begin
      {$IFDEF ENABLECYCLE}
        bOk:=bJAS_HasPermission(p_Context,cnPerm_API_CycleServer);
        if not bOk then
        begin
          p_Context.u8ErrNo:=201008011639;
          p_Context.saErrMsg:='Required Permission not granted: Cycle JAS Server';
          p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ELSE}
        bOk:=false;
        if not bOk then
        begin
          p_Context.u8ErrNo:=201503071116;
          p_Context.saErrMsg:='Cycling the server is disabled.';
          p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ENDIF}
    end;

    if bOk then
    begin
      p_Context.XML.bParseXML('<Success />');
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      gbServerCycling:=true;
      p_Context.saOut:=p_Context.saPage;
    end;
    goto DoneHere;
  end else




  if p_saAction='backupdatabase' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201607141900,'Valid Session required for this operation.','', SOURCEFILE, DBC,RS);
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_backupdatabase);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201607141901,'You do not have permission to perform this operation.','', SOURCEFILE, DBC,RS);
      end;
    end;

    if bOk then
    begin
      {$IFDEF WINDOWS}
      u2IOResult:=u2Shell(grJASConfig.saSysDir+'bin\backupdatabase.bat','');
      {$else}
      u2IOResult:=u2Shell(grJASConfig.saSysDir+'bin/backupdatabase.sh','');
      {$EndiF}
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Backup Database</h1>'+
        '<p>IO Result(zero is good): '+inttostr(u2IOResult)+'</p>'+
        '<p>'+sIOResult(u2IOResult)+'</p>'+
        '<p>See your administrator for the location of the '+
        'generated backup, the scripts that do the work, for the JAS Action '+
        '"backupdatabase", are in the system bin directory.</p>'
        ,
        123020100064
      );

      goto DoneHere;
    end;
  end else


  if p_saAction='shutdownserver' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201008011803;
      p_Context.saErrMsg:='Valid Session required for this operation.';
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      p_Context.saOut:=p_Context.saPage;
    end;

    if bOk then
    begin
      {$IFDEF ENABLESHUTDOWN}
        bOk:=bJAS_HasPermission(p_Context,cnPerm_API_ShutDownServer);
        if not bOk then
        begin
          p_Context.u8ErrNo:=201008011804;
          p_Context.saErrMsg:='Required Permission not granted: Shutdown JAS Server';
          p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ELSE}
        bOk:=false;
        if not bOk then
        begin
          p_Context.u8ErrNo:=201503071204;
          p_Context.saErrMsg:='Shutdown feature disabled.';
          p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_500;
          p_Context.CreateIWFXML;
          p_Context.saOut:=p_Context.saPage;
        end;
      {$ENDIF}
    end;

    if bOk then
    begin
      p_Context.XML.bParseXML('<Success />');
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      gbServerShuttingDown:=true;
      p_Context.saOut:=p_Context.saPage;
    end;
    goto DoneHere;
  end else

  if p_saAction='tableexist' then
  begin //54
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141683;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181384);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_tableexist);
      p_Context.u8ErrNo:=201607141685;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181386);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_TableExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID'));
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test JAS_TableExist</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: JAS_TableExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID')+')</p>',
        201202251904
      );
      goto DoneHere;
    end;
  end else

  if p_saAction='columnexist' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141687;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181388);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_ColumnExist);
      p_Context.u8ErrNo:=201607141689;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181390);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_ColumnExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('JColu_JColumn_UID'));
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_ColumnExist</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_ColumnExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('JColu_JColumn_UID')+')</p>',
        201202251905
      );
      goto DoneHere;
    end;
  end else




  if p_saAction='rowexist' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141691;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181392);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_RowExist);
      p_Context.u8ErrNo:=201607141693;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181394);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bCallResult:=bJAS_RowExist(p_Context,p_Context.CGIENV.DATAIN.Get_saValue('UID'),p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID'));
      p_Context.saPage:=saGetPage(p_Context,'','','',false,
        '<h1>Test bJAS_RowExist</h1>'+
        '<p>Result: '+sTrueFalse(bCallResult)+'</p>'+
        '<p>Call Made: bJAS_RowExist(p_Context,'+p_Context.CGIENV.DATAIN.Get_saValue('UID')+','+p_Context.CGIENV.DATAIN.Get_saValue('JTabl_JTable_UID')+')</p>',
        201202251906
      );
      goto DoneHere;
    end;
  end else






  if p_saAction='generateseckeys' then
  begin
    bGotOne:=true;
    //riteln('generate security keys on entry p_Context.bSessionValid: ',p_Context.bSessionValid);
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141695;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181396);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1><p>Session is not Valid.</p>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      //riteln('app - genseckey - user admin flagged: ' ,syesno(p_Context.rJUser.JUser_Admin_b));

      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_generateseckeys);
      if not bOk then
      begin
        p_Context.u8ErrNo:=201607141697;
        p_Context.saPageTitle:='Access Denied';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181398);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1><p>Missing required permission: Generate Security Keys.</p>');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
        goto DoneHere;
      end;
    end;

    if bOk then
    begin
      bOk:=bJAS_GenerateSecKeys(p_ContexT);
      p_Context.saPageTitle:='Security Keys Utility';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,123020100069);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      if bOk then
      begin
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Successful: ' +sYesNo(bJAS_GenerateSecKeys(p_ContexT))+'</h1>');
      end
      else
      begin
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1><p>'+inttostr(p_COntext.u8ErrNo)+' '+p_Context.saErrMsg+'</p>');
      end;
    end;
    goto DoneHere;
  end else

  //===========================================
  //const cnJIPListLU_WhiteList = 1;
  //const cnJIPListLU_BlackList = 2;
  //const cnJIPListLU_InvalidLogin = 3;
  //const cnJIPListLU_Downloader = 4;
  //type rtJIPListLight = Record
  //  u8JIPList_UID            : UInt64;
  //  u1IPListType             : byte;
  //  saIPAddress              : ansistring;
  //  u1InvalidLogins          : byte;
  //  u2Downloads              : word;
  //  dtDownLoad               : TDATETIME;
  //end;
  //===========================================
  if p_saAction='punklist' then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141699;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181700);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_punklist);
      p_Context.u8ErrNo:=201607141701;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181702);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      XDL:=JFC_XDL.Create;
      uListLen:=length(garJIPListLight);
      if uListLen>0 then
      begin
        for u:=0 to uListLen-1 do
        begin
          with garJIPListLight[u] do begin
            if (u1IPListType=cnJIPListLU_BlackList) or
               (u1IPListType=cnJIPListLU_InvalidLogin) then
            begin
              //case u1IPListType of
              //cnJIPListLU_BlackList:  s:='Blacklisted';
              //cnJIPListLU_InvalidLogin: s:='Attempted Logins';
              //end;//case
              //XDL.AppendItem_saName_N_saValue(sIPAddress,s);
              XDL.AppendItem_saName(sIPAddress)
            end;
          end;//with
        end;
      end;
      saHTML:=XDL.saHTMLTable(
        '',//table tag insert
        true,//enable table caption
        'Maliceous Activity from these IP Addresses',//table caption
        true,//show row count in caption spot
        true, //p_bTableHEAD: Boolean;
        '',//p_saNHEADText: AnsiString;
         0,// p_u1NCol: byte;
        '',//p_salpPTRHEADText: AnsiString;
        0,//p_u1lpPtrCol: byte;// zero = Don't Display
        '',//p_saUIDHEADText: AnsiString;
        0,//p_u1UIDCol: byte;
        'IP',//p_sasaNameHEADText: AnsiString;
        2,//p_u1saNameCol: byte;
        '',//p_sasaValueHEADText: AnsiString;
        0,//p_u1saValueCol: byte;
        '',//p_sasaDescHEADText: AnsiString;
        0,//p_u1saDescCol: byte;
        '',//p_sai8UserHEADText: AnsiString;
        0,//p_u1i8UserCol: byte;
        '',//p_saTSHEADText: AnsiString;
        0 //p_u1TSCol: byte
      );
      p_Context.saPageTitle:='The "Punk List" or Banned IP List';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,123020100069);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',saHTML);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRIMG@]logo/jegas/punkbegone.png');
      p_Context.bNoWebCache:=true;
      XDL.Destroy;XDL:=nil;
    end;
  end else
  //===========================================





  if p_saAction='redirect2google' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141703;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181704);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_redirect2google);
      p_Context.u8ErrNo:=201607141705;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181706);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      JAS_LOG(p_Context, cnLog_Debug, 201203311242, 'IN  p_Context.CGIENV.uHTTPResponse:'+inttostr(p_Context.CGIENV.uHTTPResponse),'',SOURCEFILE);
      p_Context.CGIENV.Header_Redirect('http://www.google.com',garJVHost[p_Context.u2VHost].VHost_ServerIdent);
      JAS_LOG(p_Context, cnLog_Debug, 201203311243, 'OUT p_Context.CGIENV.uHTTPResponse:'+inttostr(p_Context.CGIENV.uHTTPResponse),'',SOURCEFILE);
      goto DoneHere;
    end;
  end else

  if p_saAction='databasescrub' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607141707;
      p_Context.saPageTitle:='Access Denied';
      p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181708);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
      p_Context.bNoWebCache:=true;
      goto DoneHere;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_databasescrub);
      if not bOk then
      begin
        p_Context.u8ErrNo:=201607141709;
        p_Context.saPageTitle:='Access Denied';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181710);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
        goto DoneHere;
      end;
    end;

    if bOk then
    begin
      //AS_LOG(p_COntext,cnLog_Debug,201503082119,'Database Scrub - requested','',SOURCEFILE);
      //p_Context.saPage:=saGetPage(p_Context,'','','',false,
      //  '<h1>Database Scrub</h1>'+
      //  '<p>Result: '+sTrueFalse(bDBM_DatabaseScrub(p_Context))+'</p>',201503082231);
      bDBM_DatabaseScrub(p_Context);
      goto DoneHere;
    end;
  end else

  if p_saAction='sendemail' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201607110904;
      p_Context.saErrMsg:='Valid Session required for this operation.';
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.CreateIWFXML;
      p_Context.saOut:=p_Context.saPage;
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_sendemail);
      if not bOk then
      begin
        p_Context.u8ErrNo:=201607141709;
        p_Context.saPageTitle:='Access Denied';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181710);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Access Denied</h1>');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
        goto DoneHere;
      end;
    end;

    if bOk then
    begin
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.saPage:='<h2>Send Email</h2>';
      DBC:=p_Context.VHDBC;
      RS:=JADO_RECORDSET.Create;
      saQry:='select JPers_Work_Email from jperson where (JPers_JPerson_UID=' + DBC.sDBMSUIntScrub(p_Context.rJuser.JUser_JPerson_ID)+')';
      saQry+='and((JPers_Deleted_b=false)or(JPers_Deleted_b is null))';
      if rs.open(saQry,DBC,201605181433) and (not rs.eol) then
      begin
        sSenderEmailAddress:=rs.fields.Get_saValue('JPers_Work_Email');
      end
      else
      begin
        JAS_Log(p_Context,cnLog_Warn, 20160171446,'Unable to get your email address.','Recordset trouble.', SOURCEFILE);
      end;
      rs.close;rs.destroy;rs:=nil;
      if not bJAS_Sendmail(
        p_Context,
        sSenderEmailAddress,
        p_context.cgienv.datain.Get_saValue('to'),
        p_context.cgienv.datain.Get_saValue('subject'),
        p_context.cgienv.datain.Get_saValue('msg')) then
      begin
        p_Context.saPageTitle:='Trouble Sending Your Message.';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181346);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','<h1>Save your work!</h1><br /><p>Hitting the backbutton on your browser will bring you to the message before you sent it. You should be able to copy and paste your text for safekeeping until this problem is resolved.');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/categories/applications-utilities.png');
        p_Context.bNoWebCache:=true;
        goto DoneHere;
      end
      else
      begin
        p_Context.saPageTitle:='Sent Email Successfully';
        p_Context.saPage:=saGetPage(p_Context,'','sys_page_message','',false,201605181346);
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]','');
        p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','[@JASDIRICONTHEME@]128/apps/internet-email-client.png');
        p_Context.bNoWebCache:=true;
        goto DoneHere;
      end;
    end;
  end else

  if p_saAction='debugsession' then
  begin
    bGotOne:=true;
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201607102211,'Valid Session required for this operation.','', SOURCEFILE, DBC,RS);
    end;

    if bOk then
    begin
      bOk:=bJAS_HasPermission(p_Context,cnPerm_API_debugsession);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201607102212,'You do not have permission to perform this operation.','', SOURCEFILE, DBC,RS);
      end;
    end;

    if bOk then
    begin
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      p_Context.saPage:='<h2>Session Debug</h2>';
      //if p_Context.CGIENV.Cky In.FoundItem_saName('JSID') then
      //begin
      //  p_Context.saPage+='<p>Cky In JSID Found: '+p_Context.CGIENV.Cky In.Item_saValue+'</p>';
      //end
      //else
      //begin
      //  p_Context.saPage+='<p>Cky In JSID Not Found.</p>';
      //end;
    
      //if p_Context.CGIENV.DataIn.FoundItem_saName('JSID') then
      //begin
      //  p_Context.saPage+='<p>DataIn JSID Found: '+p_Context.CGIENV.DataIn.Item_saValue+'</p>';
      //end
      //else
      //begin
      //  p_Context.saPage+='<p>DataIn Not Found.</p>';
      //end;
      p_Context.saPage+='<p>Session Valid: '+sYesNo(p_Context.bSessionValid)+'</p>';
    
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

  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - BEGIN');

  saAction:=lowercase(trim(p_Context.CGIENV.DataIn.Get_saValue('ACTION')));
  bOk:=not p_Context.bErrorCondition;
  if not bOk then
  begin
    RenderHtmlErrorPage(p_Context);
  end;
  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - Action: '+saAction);

  if bOk then
  begin
    if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - B');
    if saAction='welcome' then
    begin
      p_Context.saPage:=saGetPage(p_Context,'','','',false,'<h1>Welcome to JAS!</h1>',123020100054);
      p_Context.CGIENV.uHTTPResponse:=cnHTTP_Response_200;
      goto DoneHere;
    End else
    if saAction='csvimport' then                begin CSVImport(p_Context);                     goto donehere; end else
    if saAction='csvmapfields' then             begin CSVMapFields(p_Context);                  goto donehere; end else
    if saAction='csvupload' then                begin CSVupload(p_Context);                     goto donehere; end else
    if saAction='deleterecordlocks' then        begin JAS_DeleteRecordLocks_StockUI(p_Context); goto DoneHere; end else
    if saAction='diagnostichtmldump' then       begin JAS_DiagnosticHtmlDump(p_Context);        goto DoneHere; end else
    if saAction='emptytrash' then               begin DBM_EmptyTrash(p_Context);                goto DoneHere; end else
    if saAction='getnotesecure' then            begin JAS_NoteSecure(p_Context);                goto DoneHere; end else
    if saAction='jassqltool' then               begin JASSQLTool(p_Context);                    goto DoneHere; end else
    if saAction='jiconhelper' then              begin JIconHelper(p_Context);                   goto DoneHere; end else
    if saAction='createscreensfortable' then    begin JAS_CreateScreensForTable(p_Context);     goto DoneHere; end else
    if saAction='deletetable' then              begin JAS_DeleteTable(p_Context);               goto DoneHere; end else
    if saAction='killorphans' then              begin DBM_KillOrphans(p_Context);               goto DoneHere; end else
    if saAction='login' then                    begin Login(p_Context);                         goto DoneHere; End else
    if saAction='logout' then                   begin LogOut(p_Context);                        goto DoneHere; End else
    if saAction='menueditor' then               begin JAS_MenuEditor(p_Context);                goto DoneHere; end else
    if saAction='menuexport' then               begin JAS_MenuExport(p_Context);                goto DoneHere; end else
    if saAction='menuimport' then               begin JAS_MenuImport(p_Context);                goto DoneHere; end else
    if saAction='multipartupload' then          begin MultipartUpload(p_Context);               goto DoneHere; end else
    if saAction='rendermindmap' then            begin JAS_RenderMindMap(p_Context);             goto DoneHere; end else
    if saAction='syncdbmscolumns' then          begin DBM_Syncdbmscolumns(p_Context);           goto DoneHere; end else
    if saAction='syncscreenfields' then         begin DBM_SyncScreenFields(p_Context);          goto DoneHere; end else
    if saAction='xmltest' then                  begin JAS_XmlTest(p_Context);                   goto DoneHere; end else
    if saAction='jcaptionflagorphans' then      begin DBM_JCaptionFlagOrphans(p_Context);       goto DoneHere; end else
    if saAction='jnoteflagorphans' then         begin DBM_JNoteFlagOrphans(p_Context);          goto DoneHere; end else
    if saAction='promotelead' then              begin JAS_PromoteLead(p_Context);               goto DoneHere; end else
    if saAction='merge' then                    begin JAS_Merge(p_Context);                     goto DoneHere; end else
    if saAction='wipeallrecordlocks' then       begin DBM_WipeAllRecordLocks(p_Context);        goto DoneHere; end else
    if saAction='updateorgmembers' then         begin DBM_UpdateOrgMembers(p_Context);          goto donehere; end else
    if saAction='fileupload' then               begin FileUpload(p_Context);                    goto donehere; end else
    if saAction='filedownload' then             begin FileDownload(p_Context);                  goto donehere; end else
    if saAction='copysecuritygroup' then        begin JAS_CopySecurityGroup(p_Context);         goto donehere; end else
    if saAction='verifyemail' then              begin JAS_VerifyEmail(p_Context);               goto donehere; end else
    if saAction='deletescreen' then             begin JAS_DeleteScreen(p_Context);              goto donehere; end else
    if saAction='resetpassword' then            begin JAS_ResetPassword(p_Context);             goto donehere; end else
    if saAction='dbm_finddupeuid' then          begin DBM_FindDupeUID(p_Context);               goto donehere; end else
    if saAction='dbm_difftool' then             begin DBM_DiffTool(p_Context);                  goto donehere; end else
    if saAction='jas_calendar' then             begin JAS_Calendar(p_Context);                  goto donehere; end else
    if saAction='dbm_learntables' then          begin DBM_LearnTables(p_Context);               goto donehere; end else
    if saAction='flagjasrow' then               begin DBM_FlagJasRow(p_Context);                goto donehere; end else
    if saAction='flagjasrowexecute' then        begin DBM_FlagJasRowExecute(p_Context);         goto donehere; end else
    if saAction='createjet' then                begin JAS_CreateJet(p_Context);                 goto donehere; end else
    if saAction='removejet' then                begin DBM_RemoveJet(p_Context);                 goto donehere; end else
    if saAction='register' then                 begin JAS_Register(p_Context);                  goto donehere; end else
    if saAction='help' then                     begin JAS_Help(p_Context);                      goto donehere; end else
    if saAction='emptycache' then               begin JAS_EmptyCache(p_Context);                goto donehere; end else
    if saAction='userbackground' then           begin JASAPI_JUser_Background(p_Context);       goto donehere; end else


    if bJASMiniApps(p_Context,saAction) then goto DoneHere;
    //-------------------------------
    if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - C');

    if not bUserCustomizations(p_Context) then    //< true means the usercustomization handled the request. It does not mean the user function succeeded or failed.
    begin
      //JAS_Log(p_Context,cnLog_warn,201604071326,'Invalid Request: '+ p_Context.CGIENV.saPostData,'',SOURCEFILE);
      //p_COntext.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_500;//Server cannot fulfill the request.

    end;
  end;
  //-------------------------------
  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - D');

donehere: ;

  {$IFDEF DIAGNOSTIC_WEB_MSG}
  JASPrintln(sTHIS_ROUTINE_NAME+'----After UserCustomizations----BEGIN');
  JASPrintln('p_Context.CGIENV.uHTTPResponse: '+inttostr(p_Context.CGIENV.uHTTPResponse));
  JASPrintln('p_Context.bOutputRaw: '+sTrueFalse(p_Context.bOutPutRaw));
  JASPrintln(sTHIS_ROUTINE_NAME+'----After UserCustomizations----END');
  {$ENDIF}

  If not p_Context.bOutputRaw Then
  Begin
    if p_Context.bErrorCondition then RenderHtmlErrorPage(p_Context);
    if p_Context.CGIENV.uHTTPResponse=0 then
    begin
      {$IFDEF DIAGNOSTIC_WEB_MSG}
      JASPrintln('MENU ---------------------------------------BEGIN');
      {$ENDIF}
      p_Context.u8MenuTopID:=u8Val(p_Context.CGIENV.DATAIN.get_savalue('MT'));
      if (p_Context.u8MenuTopID=0) then
      begin
        p_Context.u8MenuTopID:=garJVHost[p_Context.u2VHost].VHost_DefaultTop_JMenu_ID;
      end;
      if (p_Context.u8MenuTopID=0) then
      begin
        p_Context.u8MenuTopID:=garJVHost[p_Context.u2VHost].VHost_DefaultTop_JMenu_ID;
      end;
      {$IFDEF DIAGNOSTIC_WEB_MSG}
      JASPrintln('ReplaceJasMenu ---------------------------------------BEGIN');
      {$ENDIF}

      if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - E');
      ReplaceJasMenuWithMenu(p_Context);
      if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - F');

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
          if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - G');
          DynamicScreen(p_Context);
          if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - H');
          //ASprintln('Page Len: '+inttostR(length(p_Context.saPage)));
          //ASprintln('Out Len: '+inttostR(length(p_Context.saOut)));
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
      if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - I');

      If (length(p_Context.saPage)=0) then
      begin
        if (p_Context.bErrorCondition=false) Then
        Begin
          p_Context.bNoWebCache:=true;
          if p_Context.bMenuHasPanels then p_Context.saHTMLRipper_Section:='BLANK';
          saTempGetPageData:=saHtmlRipper(p_Context,123020100071);
          if(not p_Context.bErrorCondition)then
          begin
            if (p_Context.CGIEnv.uHTTPResponse=0) then p_Context.CGIEnv.uHTTPResponse:=cnHTTP_RESPONSE_200;
            p_Context.saPage:=saTempGetPageData;
          end;
        end
        else
        begin
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
        end;
      End;
      if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - J');

      // SCAN OUTPUT PAGE FOR BLOCKS
      // if there are BLOCKS we can handle - do them until there are not anymore unhandled.
      // NOTE: Default "Can't do this now" or "You need to be logged in" or just BLANKS
      // need to replace blocks that can't be honored based on p_Context information.

    end;  // p_Context.CGIENV.uHTTPResponse=0 then
    // FINAL Search-N-Replace for p_Context Stuff in User Pages.
    //ASDebugPrintln('DEBUG Begin adding p_Context stuff to PAGESNRXDL ');
  End;
  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - K');

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
  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - L');

  if p_Context.bSaveSessionData then
  begin
    bOk:=bJas_SaveSessionData(p_Context);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202261101, 'uj_application - call to bJAS_SaveSessionData failed.','',SOURCEFILE);
    end;
  end;
  if p_context.bInternalJob then JASPRintln('ExecuteJASApplication - END');

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
var
  bOk:boolean;
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
    bOk:=bJAS_HasPermission(p_COntext, cnPerm_API_MultiPartUpload);
    JAS_Log(p_Context,cnLog_Error,201608241426,
      'You are not authorized to upload currently.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
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
        saFilename:=garJVHost[p_Context.u2VHost].VHost_FileDir+p_Context.CGIENV.DataIn.Item_saValue;
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
  p_Context.CGIENV.Header_Html(garJVHost[p_Context.u2VHost].VHost_ServerIdent);
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
