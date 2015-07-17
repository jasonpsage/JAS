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
Unit uj_ui_stock;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_ui_stock.pp'}
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
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xml
,ug_tsfileio
,ug_jfc_threadmgr
,ug_jado
,uj_tables_loadsave
,uj_locking
,uj_permissions
,uj_captions
,uj_user
,uj_definitions
,uj_webwidgets
,uj_sessions
//,uj_xml
,uj_email
,uj_context
,uj_fileserv
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
// This function is used internally by JAS to serve error pages the server may
// have generated based on the circumstances of the request. Pages such as
// Error 404 - Page Not Found for example. The files it uses are located
// in the (jas dir)templates/en/error/ folder. Where "en" can be whatever the
// current language is. So expanding JAS' error pages to other languages or
// customizing them is possible and fairly striaght forward.
function saGetErrorPage(p_Context: TCONTEXT): ansistring;
//=============================================================================
{}
// Typically you call JASError first, the call this function if you have an
// HTML interface.
Procedure RenderHtmlErrorPage(p_Context: TCONTEXT);
//=============================================================================
{}
// This is a powerful tool for administrators to allow managing and analyzing
// data directly from any DBMS data source connected to JAS.
// To call it up: http://jas/?action=JASSQLTool
Procedure JASSQLTool(p_Context: TCONTEXT);
//=============================================================================
// This function handles the userinterface and responses for the user login
// functionality for JAS. To cause ther code to fire directly use:
// http://jas/?action=Login
// But note that calling it alone won't do much UNLESS you are logged in
// when you call it. How this function works is internally it calls
// bJAS_CreateSession and if the session is valid upon it's return,
// Login redirects to the URL indicated in the (jas dir)/config/jas.cfg
// file's DefaultLoggedInPage's value.
//
// Note this function does respond with context specific data in the form of
// text stuffed into the SNR mechanism in JAS. To see what these values are,
// the stock sys_login.jas html template has a fully functioning login
// dialog and is integrated with Login responses so they get to the user.
// For example: Invalid Password message
// See bJAS_CreateSession for more information.
procedure Login(p_Context: TCONTEXT );
//=============================================================================
{}
// This function handles the userinterface for users logging out.
// Internally it calls bJAS_RemoveSession, if that function fails for any
// reason an error dialog is rendered. If it is successful, then the user is
// directed to the page indicated in the (jas dir)/config/jas.cfg
// file's DefaultLoggedOutPage's value.
Procedure LogOut(p_Context:TCONTEXT);
//=============================================================================
{}
// This function calls the JAS API call JAS_DeleteRecordLocks to delete the
// all the record locks owned by the currently logged in user.
// This function puts a face on it so there is output so that the user knows
// the action was performed.
procedure JAS_DeleteRecordLocks_StockUI(p_Context: TCONTEXT);
//=============================================================================

//=============================================================================
{}
procedure JAS_DeleteTable(p_Context: TCONTEXT);
//=============================================================================


//=============================================================================
{}
// URI Parameters:
// JTabl_JTable_UID = JTable Record containing table or view you wish to make
//   a search screen and a data screen for. Connection is figured out from
//   this information. a data connection doesn't need to be active to make a
//   screen for it.
// Name = If not passed resorts to JTable Table Name. Whether
//  passed or not however, if the Screen Name + ' ' + 'Search' or
//  Screen Name + ' ' + 'Data' already exists then an error is thrown.
//
// This function might not belong in this unit - as it does it's task and
// returns an XML document - however because it is so integral to the
// User Interface - it's here.
//
// TODO: Move this to the JASAPI side of things and make it work using the
//       extensible xml mechanisms. e.g. i01j_api_xml.pp
procedure JAS_CreateScreensForTable(p_Context: TCONTEXT);
//=============================================================================
{}
// URI Parameters:
// JScrn_JScreen_UID = JScreen UID you wish to delete
//
// TODO: Move this to the JASAPI side of things and make it work using the
//       extensible xml mechanisms. e.g. i01j_api_xml.pp
procedure JAS_DeleteScreen(p_Context: TCONTEXT);
//=============================================================================
{}
// I was having trouble toggling the debug output today - verbose, verbose local,
// and things weren't revealing what was wrong aside from the fact I broke it.
// This diagnostic tool is an attempt to FORCE the issue and end up with a useful
// leftover tidbit for administrators needing to look about
procedure JAS_DiagnosticHTMLDump(p_Context: TCONTEXT);
//=============================================================================
{}
// Merges two records into one with interaction from user
procedure JAS_Merge(p_Context: TCONTEXT);
//=============================================================================
{}
// Promotes a lead to appropriate Company and Person records, creating or
// merging as directed by user.
procedure JAS_PromoteLead(p_Context: TCONTEXT);
//=============================================================================
{}
// This function copies an existing security group's settings into a new
// security group, essentially using the source group as a template.
procedure JAS_CopySecurityGroup(p_Context: TCONTEXT);
//=============================================================================
{}
// This routine is used by the registration process to verify a user's email
// address
Procedure JAS_verifyemail(p_Context:TCONTEXT);
//=============================================================================
{}
// This routine facilitates resetting a password for a user automatically if
// they forgot their password.
Procedure JAS_ResetPassword(p_Context: TCONTEXT);
//=============================================================================
{}
// This function renders an interactive month calendar that shows colored
// dates where open items (tasks, meetings, and calls) exist. From it you can
// create new tasks, calls, meetings and jump to existing ones.
Procedure JAS_Calendar(p_Context: TCONTEXT);
//=============================================================================
{}
// This function interactively works with the user to gather information needed
// to create a new JAS Jet (new system). this routine handles preventing
// duplicates and verifying the alias name is valid and that the from email
// address looks like a valid email address. This function also PREVENTS a
// USER from creating more than one system.
Procedure JAS_CreateJet(p_Context: TCONTEXT);
//=============================================================================
{}
// This function toss out the sys_register.jas template which uses the jasapi
// call "register" so that dynamic toggle/hiding of the register button can
// be performed according to the JET's settings without needing GLOBAL SNR
// variables.
procedure JAS_Register(p_Context: TCONTEXT);
//=============================================================================
{}
// This function is part of the help frame work. When linked to from various
// pages throughout the system, a HELPID (Help_JHelp_UID) is passed which
// allows looking up the jhelp table to get language sensitive HTML text,
// and VIDEOS to assist users with the system.
procedure JAS_Help(p_COntext: TCONTEXT);
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
function saGetErrorPage(p_Context: TCONTEXT): ansistring;
//=============================================================================
var
  saCaption: ansistring;
  sa: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='saGetErrorPage(p_Context: TCONTEXT; var p_iHTTPResponse: integer): ansistring;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102592,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102593, sTHIS_ROUTINE_NAME);{$ENDIF}

   p_Context.saMimeType:=csMIME_TextHtml;

    if bJASNote(p_Context,inttostr(p_Context.CGIENV.iHTTPResponse),sa,p_Context.CGIENV.saHTTPResponse) and
       bJASCaption(p_Context,inttostr(p_Context.CGIENV.iHTTPResponse),saCaption,inttostr(p_Context.CGIENV.iHTTPResponse)+' Error') then
    begin
      result:=saGetPage(p_Context, 'sys_area','sys_message','',false,201203122212);
      result:=saSNRStr(result, '[@MESSAGE@]',sa);
      result:=saSNRStr(result, '[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/status/dialog-error.png');
      result:=saSNRStr(result, '[@PAGETITLE@]',saCaption);
    end
    else

    begin
      result:=getfile(p_Context,
                garJVHostLight[p_Context.i4VHost].saTemplateDir+
                lowercase(grJASConfig.saDefaultLanguage) + csDOSSLASH+'error'+
                csDOSSLASH+'error'+inttostr(p_Context.CGIENV.iHTTPResponse)+'.jas',
                p_Context.CGIENV.iHTTPResponse);
      if length(result)=0 then
      begin
        result:='<h1>'+inttostr(p_Context.CGIENV.iHTTPResponse)+' - Error</h1><br /><p>201110120216</p>';
      end;
    end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102594,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
Procedure RenderHtmlErrorPage(p_Context: TCONTEXT);
//=============================================================================
Var saErrTemplate: AnsiString;
    bLoadedTemplateSuccessfully: boolean;
    u2IOResult: word;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='RenderHtmlErrorPage(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102597,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102598, sTHIS_ROUTINE_NAME);{$ENDIF}

  //if p_Context.CGIENV.iHTTPResponse=0 then p_Context.CGIENV.iHTTPResponse:=200;
  //JASPrintln('CGIError Page - ENTERING ErrorNo:'+saStr(p_Context.u8ErrNo)+' p_Context.bErrorcondition:'+saTrueFalse(p_Context.bErrorCondition)+' and length(p_Context.saPage):'+saStr(length(p_Context.saPage)));

  //JAS_Log(p_COntext,cnLog_ERROR,p_Context.u8ErrNo,p_Context.saErrMsg,'',SOURCEFILE);

  // then this
  saErrTemplate:=saJASLocateTemplate('sys_error.jas',p_Context.saLang, p_Context.saColorTheme,p_Context.saRequestedDir,201012301753,garJVHostLight[p_Context.i4VHost].saTemplateDir);
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]','Error '+inttostr(p_Context.u8ErrNo));
  p_Context.saMimeType:=csMIME_TextHtml;
  p_Context.bNoWebCache:=true;
  p_Context.saPage:='';
  //bLoadedTemplateSuccessfully:=bLoadTextFile(saErrTemplate,p_Context.saPage);
  if length(saErrTemplate)>0 then
  begin
    bLoadedTemplateSuccessfully:=bTSLoadEntireFile(saErrTemplate,u2IOResult,p_Context.saPage);
  end
  else
  begin
    bLoadedTemplateSuccessfully:=false;
  end;

  //riteln('201012261751 - TEST - bLoadedTemplateSuccessfully: ' + saYesNo(bLoadedTemplateSuccessfully));

  if(bLoadedTemplateSuccessfully)then
  begin
    if NOT ((p_Context.iErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
      ((((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
      (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSE) ) ) then
    begin
      p_Context.saErrMsgMoreInfo:=grJASConfig.saErrorReportingSecureMessage;
      //ASPrintln('RenderHTMLErrorPage - NOT Accepted: '+p_Context.saErrMsgMoreInfo);
    end
    else
    begin
      //ASPrintln('RenderHTMLErrorPage - Accepted');
    end;
    //p_Context.saErrMsg+='Error Message Dispatched Properly via System Template.';
    //p_Context.CGIENV.Header_HtmlNoCookies;
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORNUMBER@]',inttostr(p_Context.u8ErrNo),True);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORMESSAGE@]',p_Context.saErrMsg,True);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORMESSAGEMOREINFO@]',p_Context.saErrMsgMoreInfo,True);
    if ((p_Context.iDebugMode <> cnSYS_INFO_MODE_SECURE) and
      ((((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (p_Context.iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
      (p_Context.iDebugMode = cnSYS_INFO_MODE_VERBOSE) ) ) then
    begin
      //ASPrintln('MORE INFO LOGXXDL Sent');
      p_Context.saPage:=saSNRStr(p_Context.saPage,'[@LOGXXDL@]',p_Context.LogXXDL.saHTMLTable,True);
    end
    else
    begin
      //ASPrintln('MORE INFO LOGXXDL NOT Sent');
      p_Context.saPage:=saSNRStr(p_Context.saPage,'[@LOGXXDL@]','',True);
    end;
  end
  else
  begin
    p_Context.saErrMsg+='Note: Resorted to raw text response. Unable to dispatch error using configured template:'+saErrTemplate;
    JAS_Log(p_COntext,cnLog_ERROR,p_Context.u8ErrNo,p_Context.saErrMsg,'',SOURCEFILE);
    if NOT ((p_Context.iErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
      ((((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
      (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSE) ) ) then
    begin
      p_Context.saErrMsg:=grJASConfig.saErrorReportingSecureMessage;
    end;
    //p_Context.CGIENV.Header_HtmlNoCookies;
    p_Context.saPage:=
      saJegasLogoRawHTML+csCRLF+
      '<font style="font-family: monospace">'+
      'Error<br />-----<br />'+
      'Error #:'+inttostr(p_Context.u8ErrNo)+'<br />'+
      'Error Msg:' + p_Context.saErrMsg + '<br /><br />';

    if NOT ((p_Context.iErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
      ((((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
      (p_Context.iErrorReportingMode = cnSYS_INFO_MODE_VERBOSE) )) then
    begin
      p_Context.saPage+='More Info:' + p_Context.saErrMsgMoreInfo + '<br /><br />';
    end;
    p_Context.saPage+='P.S. Unable to find suitable sys_error.jas file in the templating system if you are viewing this.</font>';
  End;
  //riteln('CGIError Page - LEAVING p_Context.bErrorcondition:',p_Context.bErrorCondition, ' and length(p_Context.saPage):',length(p_Context.saPage));
  //riteln('201012261751 - TEST');
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102599,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================




















//=============================================================================
Procedure JASSQLTool(p_Context: TCONTEXT);
//=============================================================================
Var saQry: AnsiString;
  rs: JADO_RECORDSET;
  bOk: Boolean;
  saResult: AnsiString;
  saRTCONNECTION: AnsiString;
  saJADO_ERRORS: AnsiString;
  saJADO_RECORDSET: AnsiString;
//  saJADO_FIELDS: ansistring;
  saJADO_CONNECTION: AnsiString;
  bR1: Boolean;  // for the alternating color of the grid
  iRecordsread: Integer;

  // DSN Selector
  saDSNSelector: ansistring;
  u8DSNSelected: Uint64;
  i: longint;
  bDSNSElectedIsValidForCurrentUser: boolean;
  saExport: ansistring;
  rs2: jado_recordset;
  //u8JSecPermID: uint64;
  //bRenderOption: boolean;




{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASSQLTool(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102600,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102601, sTHIS_ROUTINE_NAME);{$ENDIF}


  bR1:=True;
  iRecordsread:=0;
  u8DSNSelected:=0;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201002062022,'Session is not valid. You need to be logged in '+
      'and have permission to access this resource. JUser_JUser_UID:' +
      inttostR(p_Context.rJUser.JUser_JUser_UID),'',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context,cnJSecPerm_JASSQLTool);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_Error,201002062023,'You are not authorized to view this page.',
        'JUser_JUser_UID:' + inttostR(p_Context.rJUser.JUser_JUser_UID),SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    End;
  End;

  saExport:=  p_Context.CGIENV.DATAIN.Get_saValue('export');


  if bOk then
  begin
    if(p_Context.CGIENV.DATAIN.FoundItem_saName('DSNSELECTOR',true))then
    begin
      u8DSNSelected:=u8Val(p_Context.CGIENV.DATAIN.Item_saValue);
    end
    else
    begin
      u8DSNSelected:=0;
    end;



    if saExport='' then
    begin
      bDSNSelectedIsValidForCurrentUser:=false;
      saDSNSelector:='<select name="DSNSELECTOR" id="DSNSELECTOR">';
      for i:=0 to length(p_Context.JADOC)-1 do
      begin
        if bJAS_HasPermission(p_Context,u8Val(p_Context.JADOC[i].JDCon_JSecPerm_ID)) then
        begin
          saDSNSelector+='<option ';
          if i=u8DSNSelected then
          begin
            saDSNSelector+='selected ';
            bDSNSElectedIsValidForCurrentUser:=true;
          end;
          saDSNSelector+=' value='+saStr(i)+'>'+p_Context.JADOC[i].saName + ': '+ p_Context.JADOC[i].saDatabase+'</option>';
        end;
        //else
        //begin
        //  saDSNSelector+='<option>DENIED: '+p_Context.JADOC[i].saName+' PermID: '+p_Context.JADOC[i].JDCon_JSecPerm_ID+'</option>';
        //end;
      end;
      saDSNSelector+='</select>';
    end;
  end;


  if bOk then
  begin
    saRTCONNECTION:='';
    if saExport='' then
    begin
      With p_Context.JADOC[u8DSNSelected] Do Begin
        saRTCONNECTION+='WITH grCon DO BEGIN<br />'+csCRLF;
        saRTCONNECTION+='&nbsp;&nbsp;u2DbmsID:<b> '+saStr(u2DbmsID)+'</b><br />'+csCRLF;
        saRTCONNECTION+='&nbsp;&nbsp;u2DrivID:<b> '+saStr(u2DrivID)+'</b><br />'+csCRLF;
        saRTCONNECTION+='&nbsp;&nbsp;saName:<b> '+saName+'</b><br />'+csCRLF;
        saRTCONNECTION+='&nbsp;&nbsp;saDesc:<b> '+saDesc+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saDSN:<b> ' + saDSN+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saUserName:<b> ' + saUserName+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saPassword:<b> ' + saPassword+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saDriver:<b> ' + saDriver+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saServer:<b> ' + saServer+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saDataBase:<b> ' + saDataBase+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;bConnected:<b> ' + satrueFalse(bConnected)+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;bConnecting:<b> ' + satrueFalse(bConnecting)+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;bInUse:<b> ' + saTrueFalse(bInUse)+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;bFileBasedDSN:<b> ' + saTrueFalse(bFileBasedDSN)+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;saDSNFileName:<b> ' + saDSNFileName+'</b><br />'+csCRLF;
        saRTConnection+='&nbsp;&nbsp;ID (jdconnection id):<b> ' + ID+'</b><br />'+csCRLF;
        saRTConnection+='END; //WITH';
      End;//end with
    end;
  end;




  if bOk then
  begin
    saQry:=p_Context.CGIENV.DataIn.Get_saValue('QUERY');
    if saExport='' then
    begin
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@QUERY@]',saQry);
    end;
    if (u8DSNSelected>=0) and (u8DSNSelected<length(p_Context.JADOC)) then
    begin
      if bDSNSelectedIsValidForCurrentUser then
      begin
        If (length(saQry)>0)  Then
        Begin
          //Log(cnLog_Debug, 201007082040,'Debug JASSqlTool - Opening Query: '+saQry,SOURCEFILE);
          bOk:=rs.Open(saQry,p_Context.JADOC[u8DSNSelected],201503161190);
          //Log(cnLog_Debug, 201007082040,'Debug JASSqlTool - Back from opening Query.',SOURCEFILE);
          if saExport='' then
          begin
            saJADO_ERRORS:=p_Context.JADOC[u8DSNSelected].saRenderHTMLErrors;
          end
          else
          begin
            if p_Context.JADOC[u8DSNSelected].Errors.ListCount>0 then
            begin
              saJADO_ERRORS:=p_Context.JADOC[u8DSNSelected].saRenderHTMLErrors;
            end
            else
            begin
              saJADO_ERRORS:='';
            end;
          end;
          saJADO_RECORDSET:='';
          if saExport='' then
          begin
            saJADO_RECORDSET+='ActiveConnection:<b>'+saSTR(UINT(rs.ActiveConnection))+'</b><br />'+csCRLF+
                              'i4EditMode:<b>'+saSTR(rs.i4EditMode)+'</b><br />'+csCRLF+
                              'EOL:<b>'+saTrueFalse(rs.EOL)+'</b><br />'+csCRLF+
                              'i4LockType:<b>'+saStr(rs.i4LockType)+'</b><br />'+csCRLF+
                              'u8MaxRecords:<b>'+saStr(rs.u8MaxRecords)+'</b><br />'+csCRLF+
                              'i4State:<b>'+saSTR(rs.i4State)+'</b><br />'+csCRLF+
                              'i4Status:<b>'+saSTR(rs.i4Status)+'</b><br />'+csCRLF+
                              'u2DrivID:<b>'+saSTR(rs.u2DrivID)+'</b><br />'+csCRLF;
            {$IFDEF ODBC}
            saJADO_RECORDSET+='ODBCSQLHSTMT:<b>'+saSTR(UINT(rs.ODBCSQLHSTMT))+'</b><br />'+csCRLF;
            {$ENDIF}

            If p_Context.JADOC[u8DSNSelected].u2DbmsID=cnDBMS_MySQL Then
            Begin
              saJADO_RECORDSET+='rMySQL BEGIN--: <b>(TMYSQL or st_mysql struct)</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;NET:<b>??? No idea how to display this ???</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;connector_fd:<b>'+saSTR(UINT(rs.rMySQL.connector_fd))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;host:<b>'+rs.rMySQL.host+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;user:<b>'+rs.rMySQL.user+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;passwd:<b>'+rs.rMySQL.passwd+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;unix_socket:<b>'+rs.rMySQL.unix_socket+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;server_version:<b>'+rs.rMySQL.server_version+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;host_info:<b>'+rs.rMySQL.host_info+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;info:<b>'+rs.rMySQL.info+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;db:<b>'+rs.rMySQL.db+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;charset:<b>'+saSTR(UINT(rs.rMySQL.charset))+' (lp)</b><br />'+csCRLF;
              // --!! This Fields Record causes access violations - so not Valid in this context evidently.
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.name:<b>'+rs.rMySQL.fields^.name+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.table:<b>'+rs.rMySQL.fields^.table+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.org_table:<b>'+rs.rMySQL.fields^.org_table+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.db:<b>'+rs.rMySQL.fields^.db+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.def:<b>'+rs.rMySQL.fields^.def+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.length:<b>'+saSTR(rs.rMySQL.fields^.length)+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.max_length:<b>'+saSTR(rs.rMySQL.fields^.max_length)+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.flags:<b>'+saSTR(rs.rMySQL.fields^.flags)+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.decimals:<b>'+saSTR(rs.rMySQL.fields^.decimals)+'</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;fields.ftype:<b>'+saSTR(byte(rs.rMySQL.fields^.ftype))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;field_alloc:<b>??? No Idea how to display MEM_ROOT ???</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;affected_rows:<b>'+saSTR(rs.rMySQL.affected_rows)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;insert_id:<b>'+saSTR(rs.rMySQL.insert_id)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;extra_info:<b>'+saSTR(rs.rMySQL.extra_info)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;thread_id:<b>'+saSTR(rs.rMySQL.thread_id)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;packet_length:<b>'+saSTR(rs.rMySQL.packet_length)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;port:<b>'+saSTR(rs.rMySQL.port)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;client_flag:<b>'+saSTR(rs.rMySQL.client_flag)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;server_capabilities:<b>'+saSTR(rs.rMySQL.server_capabilities)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;protocol_version:<b>'+saSTR(rs.rMySQL.protocol_version)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;field_count:<b>'+saSTR(rs.rMySQL.field_count)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;server_status:<b>'+saSTR(rs.rMySQL.server_status)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;server_language:<b>'+saSTR(rs.rMySQL.server_language)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.connect_timeout:<b>'+saSTR(rs.rMySQL.options.connect_timeout)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.client_flag:<b>'+saSTR(rs.rMySQL.options.client_flag)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.port:<b>'+saSTR(rs.rMySQL.options.port)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.host:<b>'+rs.rMySQL.options.host+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.init_command:<b>??? Not Recognized though declared in mysql.pp for version 4???</b><br />'+csCRLF;
              //saJADO_RECORDSET+='&nbsp;&nbsp;options.init_command:<b>'+rs.rMySQL.options.init_command+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.user:<b>'+rs.rMySQL.options.user+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.password:<b>'+rs.rMySQL.options.password+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.unix_socket:<b>'+rs.rMySQL.options.unix_socket+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.db:<b>'+rs.rMySQL.options.db+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.my_cnf_file:<b>'+rs.rMySQL.options.my_cnf_file+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.my_cnf_group:<b>'+rs.rMySQL.options.my_cnf_group+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.charset_dir:<b>'+rs.rMySQL.options.charset_dir+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.charset_name:<b>'+rs.rMySQL.options.charset_name+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.ssl_key:<b>'+rs.rMySQL.options.ssl_key+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.ssl_cert:<b>'+rs.rMySQL.options.ssl_cert+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.ssl_ca:<b>'+rs.rMySQL.options.ssl_ca+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.ssl_capath:<b>'+rs.rMySQL.options.ssl_capath+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.ssl_cipher:<b>'+rs.rMySQL.options.ssl_cipher+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.max_allowed_packet:<b>'+saSTR(rs.rMySQL.options.max_allowed_packet)+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.use_ssl:<b>'+saTrueFalse(rs.rMySQL.options.use_ssl='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.compress:<b>'+saTrueFalse(rs.rMySQL.options.compress='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.named_pipe:<b>'+saTrueFalse(rs.rMySQL.options.named_pipe='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.rpl_probe:<b>'+saTrueFalse(rs.rMySQL.options.rpl_probe='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.rpl_parse:<b>'+saTrueFalse(rs.rMySQL.options.rpl_parse='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;options.no_master_reads:<b>'+saTrueFalse(rs.rMySQL.options.no_master_reads='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;status:<b>'+saSTR(Byte(rs.rMySQL.status))+'</b><br />'+csCRLF;
              //mysql_status = (MYSQL_STATUS_READY,MYSQL_STATUS_GET_RESULT, MYSQL_STATUS_USE_RESULT);
              saJADO_RECORDSET+='&nbsp;&nbsp;free_me:<b>'+saTrueFalse(rs.rMySQL.free_me='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;reconnect:<b>'+rs.rMySQL.reconnect+'</b><br />'+csCRLF;
              if rs.ODBCCommandTYPE=cnODBC_SQL then
              begin
                saJADO_RECORDSET+='&nbsp;&nbsp;scramble_buff:<b>'+
                  saSTR(Byte(rs.rMySQL.scramble_buff[0]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[1]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[2]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[3]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[4]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[5]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[6]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[7]))+' '+
                  saSTR(Byte(rs.rMySQL.scramble_buff[8]))+' '+
                  '</b><br />'+csCRLF;
              end
              else
              begin
                saJADO_RECORDSET+='&nbsp;&nbsp;scramble_buff:<b>Withheld - Jegas Wedge Command In Progress (Not a true MySQL Query Under the hood)</b><br />';
              end;
              saJADO_RECORDSET+='&nbsp;&nbsp;rpl_pivot:<b>'+saTrueFalse(rs.rMySQL.rpl_pivot='0')+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;master:<b>'+saSTR(UINT(rs.rMySQL.master))+'(lp to Master st_mysql struct) </b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;next_slave:<b>'+saSTR(UINT(rs.rMySQL.next_slave))+'(lp to next slave st_mysql struct) </b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;last_used_slave:<b>'+saSTR(UINT(rs.rMySQL.last_used_slave))+'(lp to last used slave st_mysql struct) </b><br />'+csCRLF;
              saJADO_RECORDSET+='&nbsp;&nbsp;last_used_con:<b>'+saSTR(UINT(rs.rMySQL.last_used_con))+'(lp to last used connection st_mysql struct) </b><br />'+csCRLF;
              saJADO_RECORDSET+='rMySQL END--: <b>(TMYSQL or st_mysql struct)</b><br />'+csCRLF;
              saJADO_RECORDSET+='lpMySQLResults:<b>'+saSTR(UINT(rs.lpMySQLResults))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='lpMySQLPTR:<b>'+saSTR(UINT(rs.lpMySQLPTR))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='lpMySQLHost:<b>'+saSTR(UINT(rs.lpMySQLHost))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='lpMySQLUser:<b>'+saSTR(UINT(rs.lpMySQLUser))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='lpMySQLPasswd:<b>'+saSTR(UINT(rs.lpMySQLPasswd))+'</b><br />'+csCRLF;
              saJADO_RECORDSET+='aRowBuf: <b>(TMySQLRow)'+saSTR(UINT(rs.aRowBuf))+'</b><br />'+csCRLF;
            End;

            saJADO_RECORDSET+='u4Columns: <b>'+saSTR(UINT(rs.u4Columns))+'</b><br />'+csCRLF;
            saJADO_RECORDSET+='u4Rows: <b>'+saSTR(UINT(rs.u4Rows))+'</b><br />'+csCRLF;
            saJADO_RECORDSET+='u4RowsLeft: <b>'+saSTR(UINT(rs.u4RowsLeft))+'</b><br />'+csCRLF;
            saJADO_RECORDSET+='u4RowsRead: <b>'+saSTR(UINT(rs.u4RowsRead))+'</b><br />'+csCRLF;
            saJADO_RECORDSET+='Fields.ListCount:<b>'+saSTR(rs.Fields.ListCount)+'</b><br />'+csCRLF;
            If rs.Fields.ListCount>0 Then
            Begin
              saJADO_RECORDSET+='<br />';
              rs.Fields.MoveFirst;
              saJADO_RECORDSET+='<h2>Field Statistics: First Row</h2>';
              saJADO_RECORDSET+='<div class="jasgrid"><table><thead><tr>'+csCRLF;
              saJADO_RECORDSET+='<td>Field #</td>'+csCRLF;
              saJADO_RECORDSET+='<td>saName</td>'+csCRLF;
              saJADO_RECORDSET+='<td>saValue</td>'+csCRLF;
              saJADO_RECORDSET+='<td>saDesc</td>'+csCRLF;
              saJADO_RECORDSET+='<td>u8DefinedSize</td>'+csCRLF;
              saJADO_RECORDSET+='<td>i4NumericScale</td>'+csCRLF;
              saJADO_RECORDSET+='<td>i4Precision</td>'+csCRLF;
              saJADO_RECORDSET+='<td>Properties Count</td>'+csCRLF;
              saJADO_RECORDSET+='<td>i4Status</td>'+csCRLF;
              saJADO_RECORDSET+='<td>i4Type</td>'+csCRLF;
              saJADO_RECORDSET+='<td>u2JDType</td>'+csCRLF;
              saJADO_RECORDSET+='<td>u2DrivID</td>'+csCRLF;
              If rs.u2DrivID=cnDriv_ODBC Then
              Begin
                saJADO_RECORDSET+='<td>ODBCSQLHSTMT</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCColumnNumber</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCColumnName</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCColNameBufLen</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCNameLength</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCDataType</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCTargetType</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCColumnSize</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCDecimalDigits</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCNullable:</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCDataPointer</td>'+csCRLF;
                saJADO_RECORDSET+='<td>ODBCLOB</td>'+csCRLF;
              End;
              If rs.u2DrivID=cnDriv_MySQL Then
              Begin
                saJADO_RECORDSET+='<td>rMySQLField.name</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.table</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.org_table</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.db</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.def</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.length</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.max_length</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.flags</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.decimals</td>'+csCRLF;
                saJADO_RECORDSET+='<td>rMySQLField.ftype</td>'+csCRLF;
              End;
              saJADO_RECORDSET+='</td></thead><tbody>'+csCRLF;
              br1:=True;
              repeat
                  If bR1 Then saJADO_RECORDSET+='<tr class="r1">' Else saJADO_RECORDSET+='<tr class="r2">';
                  bR1:=not bR1;
                  saJADO_RECORDSET+='<td>'+saSTR(rs.Fields.N)+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).saName+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+saHTMLScrub(JADO_FIELD(rs.Fields.lpItem).saValue)+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).saDesc+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).u8DefinedSize)+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).i4NumericScale)+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).i4Precision)+'</td>'+csCRLF;
                  saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).u2JDType)+'</td>'+csCRLF;
                  {$IFDEF ODBC}
                  If rs.u2DrivID=cnDriv_ODBC Then
                  Begin
                    saJADO_RECORDSET+='<td>'+saSTR(UINT(JADO_FIELD(rs.Fields.lpItem).ODBCSQLHSTMT))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(Word(JADO_FIELD(rs.Fields.lpItem).ODBCColumnNumber))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).ODBCColumnName+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCColNameBufLen))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCNameLength))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCDataType))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCTargetType))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(UINT(JADO_FIELD(rs.Fields.lpItem).ODBCColumnSize))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCDecimalDigits))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(ShortInt(JADO_FIELD(rs.Fields.lpItem).ODBCNullable))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saSTR(UINT(JADO_FIELD(rs.Fields.lpItem).ODBCDataPointer))+'</td>'+csCRLF;
                    saJADO_RECORDSET+='<td>'+saTrueFalse(JADO_FIELD(rs.Fields.lpItem).ODBCLOB)+'</td>'+csCRLF;
                  End;
                  {$ENDIF}
                  If rs.u2DrivID=cnDriv_MySQL Then
                  Begin
                    if rs.ODBCCommandType=cnODBC_SQL then
                    begin
                      saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).rMySQLField^.name+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).rMySQLField^.table+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).rMySQLField^.org_table+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).rMySQLField^.db+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+JADO_FIELD(rs.Fields.lpItem).rMySQLField^.def+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).rMySQLField^.length)+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).rMySQLField^.max_length)+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).rMySQLField^.flags)+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+saSTR(JADO_FIELD(rs.Fields.lpItem).rMySQLField^.decimals)+'</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>'+saSTR(Byte(JADO_FIELD(rs.Fields.lpItem).rMySQLField^.ftype))+'</td>'+csCRLF;
                    end
                    else
                    begin
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                      saJADO_RECORDSET+='<td>Jegas Wedge Command In Progress</td>'+csCRLF;
                    end;
                  End;
                saJADO_RECORDSET+='</tr>'+csCRLF;
              Until not rs.Fields.MoveNext;
              saJADO_RECORDSET+='</tbody></table></div>'+csCRLF;
            End;

            saJADO_Connection:=
              'u2DbmsID: <b>' + saSTR(p_Context.JADOC[u8DSNSelected].u2DbmsID)+'</b><br />'+csCRLF+
              'saConnectionString: <b>' + p_Context.JADOC[u8DSNSelected].saConnectionString+'</b><br />'+csCRLF+
              'saDefaultDatabase: <b>' + p_Context.JADOC[u8DSNSelected].saDefaultDatabase+'</b><br />'+csCRLF+
              'Errors.Listcount:<b>' + saSTR(p_Context.JADOC[u8DSNSelected].Errors.ListCount)+'</b><br />'+csCRLF+
              'saProvider:<b>' + p_Context.JADOC[u8DSNSelected].saProvider+'</b><br />'+csCRLF+
              'i4State:<b>' + saSTR(p_Context.JADOC[u8DSNSelected].i4State)+'</b><br />'+csCRLF+
              'saVersion:<b>' + p_Context.JADOC[u8DSNSelected].saVersion+'</b><br />'+csCRLF+
              'u2DrivID:<b>' + saSTR(p_Context.JADOC[u8DSNSelected].u2DrivID)+'</b><br />'+csCRLF+
              'saMyUserName:<b>' + p_Context.JADOC[u8DSNSelected].saMyUserName+'</b><br />'+csCRLF+
              // 'saMyPassword:<b>' + p_Context.JADOC[u8DSNSelected].saMyPassword+'</b><br />'+csCRLF+
              'saMyPassword:<b>Withheld</b><br />'+csCRLF+
              'saMyConnectString:<b>' + p_Context.JADOC[u8DSNSelected].saMyConnectString+'</b><br />'+csCRLF+
              'saMyDatabase:<b>' + p_Context.JADOC[u8DSNSelected].saMyDatabase+'</b><br />'+csCRLF+
              'saMyServer:<b>' + p_Context.JADOC[u8DSNSelected].saMyServer+'</b><br />'+csCRLF;
            {$IFDEF ODBC}
            If p_Context.JADOC[u8DSNSelected].u2DrivID=cnDriv_ODBC Then
            Begin
              saJADO_Connection+='ODBCDBHandle:<b>' + saSTR(UINT(p_Context.JADOC[u8DSNSelected].ODBCDBHandle))+'</b><br />'+csCRLF;
              saJADO_Connection+='ODBCStmtHandle:<b>' + saSTR(UINT(p_Context.JADOC[u8DSNSelected].ODBCStmtHandle))+'</b><br />'+csCRLF;
            End;
            {$ENDIF}
          end;

          If bOk Then
          Begin
            saResult:='';
            if saExport='' then saresult+='Query Succeeded';
            If not rs.EOL Then
            Begin
              if saExport='' then
              begin
                saResult+='<br />'+csCRLF;
                saResult+='<div class="jasgrid">';
                saResult+='<table><thead><tr>';
              end
              else
              begin
                saResult+='<table align="left" style="background: #aaaaaa;margin: 4px;"><thead style="color: #000000;background: #eeeeee;font-weight: bold;"><tr>';
              end;
              rs.Fields.MoveFirst;
              if saExport='' then
              begin
                repeat
                  saResult+='<td>';
                  saResult+=saHTMLScrub(JADO_FIELD(rs.Fields.lpItem).saName);
                  saResult+='</td>';
                Until not rs.Fields.MoveNext;
                saResult+='<td>&nbsp;</td>';
              end
              else
              begin
                repeat
                  saResult+='<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:3px;text-align:left;">';
                  saResult+=saHTMLScrub(JADO_FIELD(rs.Fields.lpItem).saName);
                  saResult+='</td>';
                Until not rs.Fields.MoveNext;
              end;
              saResult+='</tr></thead><tbody>';
              bR1:=True;
              repeat
                iRecordsRead+=1;
                if saExport='' then
                begin
                  If bR1 Then saResult+='<tr class="r1">' Else saResult+='<tr class="r2">';
                end
                else
                begin
                  If bR1 Then
                  begin
                    saResult+='<tr style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:3px;text-align:left;color: #000000;background: #c0f0c0;">';
                  end
                  Else
                  begin
                    saResult+='<tr style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:3px;text-align:left;color: #000000;background: #ffffff;">';
                  end;
                end;
                bR1:=not bR1;
                rs.Fields.MoveFirst;
                repeat
                  saResult+='<td valign="top">';
                  saResult+=saHTMLScrub(JADO_FIELD(rs.Fields.lpItem).saValue);
                  saResult+='</td>';
                Until not rs.Fields.MoveNext;
                if saExport='' then saResult+='<td>&nbsp;</td>';
                saresult+='</tr>';
              Until not rs.MoveNext;
              saresult+='</tbody></table>';
              if saExport='' then saResult+='</div>';
            End
            else
            begin
              if saExport<>'' then
              begin
                saResult+='ZERO ROWS RETURNED for Query:' + saHTMLSCrub(saQry);
              end;
            end;
          End
          Else
          Begin
            saResult:='Error Encountered.';
          End;
          rs.Close;
        End
        Else
        Begin
          saresult:='Nothing to report yet. Query Zero Length.';
        End;
      end
      else
      begin
        saresult:='Not Authorized to Query Specified DSN Connection.';
      end;
    end
    else
    begin
      saresult:='Invalid DSN Selector passed.';
    end;
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[#RESULTS#]',saResult);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@RTCONNECTION@]',saRTConnection);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JADO_ERRORS@]',saJADO_ERRORS);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JADO_RECORDSET@]',saJADO_RECORDSET);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JADO_CONNECTION@]',saJADO_CONNECTION);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@RECORDSREAD@]',saSTR(iRecordsRead));
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@DSNSELECTOR@]',saDSNSelector);
    if saExport='' then
    begin
      p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_sqltool','MAIN',False,123020100019);
    end
    else
    begin
      p_Context.saPage:=saGetPage(p_Context, '','sys_sqltool_export_html','MAIN',true,123020100020);
      p_Context.iDebugMode:=cnSYS_INFO_MODE_SECURE; // Prevent debug info from screwing up the output for the client getting this data
    end;
  end;

  rs.Destroy;
  rs2.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102602,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================

























//=============================================================================
procedure Login(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saLoginMsg: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='Login(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102617,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102618, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=false;
  if not p_Context.bSessionValid then
  begin
    if p_Context.CGIENV.DataIn.FoundItem_saName('login') then
    begin
      bOk:=bJAS_CreateSession(p_Context);
      if bOk Then
      begin
        if(length(trim(p_Context.rJUser.JUser_DefaultPage_Login))>0) and 
          (p_Context.rJUser.JUser_DefaultPage_Login<>'NULL')
        then
        begin
          p_Context.CGIENV.Header_Redirect(p_Context.rJUser.JUser_DefaultPage_Login,garJVHostLight[p_Context.i4VHost].saServerIdent);
          JAS_LOG(p_Context,cnLog_DEBUG,200703141532,'Login - Chose User Default','',sourcefile);
        end
        else

        begin
          p_Context.CGIENV.Header_Redirect(garJVHostLight[p_Context.i4VHost].saDefaultLoggedOutPage,garJVHostLight[p_Context.i4VHost].saServerIdent);
          //JAS_LOG(p_Context,cnLog_DEBUG,200703141532,'Login - Went With Last Resport system URL option','',sourcefile);
        end;
        //JAS_LOG(p_Context,cnLog_DEBUG,200703141532,'Login - Headers: '+p_Context.CGIENV.Header.saHTMLTable,'',sourcefile);


        //p_Context.CGIENV.iHttpResponse:=200;
        //p_Context.saPage:='<h2>Logged In</h2><a href="/">Root</a>';
      end
      else
      begin
        // We're not logged in - but Why? LOL
        JAS_LOG(p_Context,cnLog_DEBUG,201203311512,'INVALID LOGIN: '+ inttostR(p_Context.iSessionResultcode),'',sourcefile);

        case p_Context.iSessionResultcode of
        cnSession_InvalidCredentials: saLoginMsg:='Invalid Login';
        cnSession_UserNotEnabled: saLoginMsg:='Account Disabled.';
        cnSession_NumAllowedSessionExceeded: saLoginMsg:='Maximum number of sessions exceeded.';
        cnSession_Success: ; // Nothing do do - we are good! :)
        cnSession_PasswordsDoNotMatch: saLoginMsg:='New Passwords do NOT match.';
        cnSession_PasswordsIdenticalNoChange: saLoginMsg:='Password not changed. New and Old passwords match.';
        cnSession_PasswordChangeSuccess: saLoginMsg+='Password Changed Successfully. <br /> Please login in with your new password.';
        cnSession_LockedOut: ;
        //cnSession_MeansErrorOccurred:
        else begin
          JAS_Log(p_Context,cnLog_Error,201001261558,
            'An Error Occurred attempting to log in.',
            'p_Context.rSession.i4Resultcode:'+
            inttostr(p_Context.iSessionResultcode),SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;//case
        end;//switch

        if p_Context.iSessionResultcode=cnSession_LockedOut then
        begin
          p_Context.CGIENV.Header_HTML(garJVHostLight[p_Context.i4VHost].saServerIdent);
          p_Context.saPage:=
            '<h1>YOUR IP HAS BEEN BANNED</h1>'+csCRLF+
            '<p>You have repeatedly failed to log in properly.</p>'+csCRLF+
            '<p>Have a Nice Day!</p>';
        end;
      end;
    end;
    if bOk = false then
    begin
      p_Context.saPage:=saGetPage(p_Context, 'sys_area_panel','sys_login','MAIN',False,201211281212);
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@ALLOWREGISTRATION@]',saTruefalse(garJVHostLight[p_Context.i4VHost].bAllowRegistration));
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@LOGINMESSAGE@]',saLoginMsg);
    end;
  end
  else
  begin
    p_Context.CGIENV.Header_Redirect(p_Context.saAlias,garJVHostLight[p_Context.i4VHost].saServerIdent);
  end;
  p_Context.bNoWebCache:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102619,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
procedure LogOut(p_Context:TCONTEXT);
//=============================================================================
var bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='LogOut(p_Context:TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102620,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102621, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=bJAS_RemoveSession(p_Context);
  if not bOk then
  begin
    if p_Context.rJUser.JUser_JUser_UID>0 then
    begin
      JAS_Log(p_Context,cnLog_info, 200610031958, 'LogOut''s call to Remove session failed.','UserID:' + inttostR(p_Context.rJUser.JUser_JUser_UID), SOURCEFILE);
    end;
  End;

  if (length(trim(p_Context.rJUser.JUser_DefaultPage_LogOut))>0) and
     (p_Context.rJUser.JUser_DefaultPage_LogOut<>'NULL') then 
  begin
    jasprintln('log out - user has JUser_DefaultPage_Logout:'+p_Context.rJUser.JUser_DefaultPage_Logout);
    p_Context.CGIENV.Header_Redirect(p_Context.rJUser.JUser_DefaultPage_Logout,garJVHostLight[p_Context.i4VHost].saServerIdent);
  end
  else
  begin
    jasprintln('log out - garJVHostLight[p_Context.i4VHost].saDefaultLoggedOutPage:'+garJVHostLight[p_Context.i4VHost].saDefaultLoggedOutPage);
    p_Context.CGIENV.Header_Redirect(
      garJVHostLight[p_Context.i4VHost].saDefaultLoggedOutPage,
      garJVHostLight[p_Context.i4VHost].saServerIdent);
    //p_Context.CGIENV.Header_Redirect(
    //  grJASConfig.saDefaultLoggedOutPage,
    //  garJVHostLight[p_Context.i4VHost].saServerIdent);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102622,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



















//=============================================================================
{}
// This function calls the JAS API call JAS_DeleteRecordLocks to delete the
// all the record locks owned by the currently logged in user.
// This function puts a face on it so there is output so that the user knows
// the action was performed.
procedure JAS_DeleteRecordLocks_StockUI(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_DeleteRecordLocks_StockUI(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102625,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102626, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204140322,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  JAS_DeleteRecordLocks(p_Context);
  if p_Context.bErrorCondition then
  begin
    RenderHtmlErrorPage(p_Context);
  end
  else
  begin
    bOk:=bJASNote(p_Context,'6437',sa,'Record Locks for current session deleted');
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_WARN,201203141024,'Missing Note for JAS_DeleteRecordLocks','',SOURCEFILE);
    end;
    //sa+='<br />['+p_Context.rJSession.JSess_JSession_UID+']';
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false,123020100033);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/categories/system-help.png');
    p_Context.saPageTitle:='Success';
  end;
  p_Context.bNoWebCache:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102627,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
{}
procedure JAS_DeleteTable(p_Context: TCONTEXT);
//=============================================================================
//p_Context.saPage:=saGetPage(p_Context,'','','',false,'<h1>Screen Editor</h1><p>Not Implemented Yet. Though taking some shape</p><a href="#" onclick="self.close()">Click here to close this window.</a><br /><br />',123020100038);
Var bOk: Boolean;
    rs: JADO_RECORDSET;
    rs2: JADO_RECORDSET;
    saQry: AnsiString;
    rJTable: rtJTable;
    DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_DeleteTable(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102631,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102632, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  p_Context.bNoWebCache:=true;

  //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE TABLE - BEGIN','',SOURCEFILE);

  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201007121200,'Invalid Session. You are not logged in.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE TABLE - Session Good','',SOURCEFILE);

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_Admin);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_Error,201007121201,'You are not authorized to view this page.','Missing Admin Permission. JUser_JUser_UID:' + inttostR(p_Context.rJUser.JUser_JUser_UID),SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    End;
  End;

  //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE TABLE - Have Permission','',SOURCEFILE);

  if bOk then
  begin
    if p_Context.CGIENV.DataIn.FoundItem_saName('UNLOCK',false) then
    begin
      rJTable.JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Item_saValue;
      bOk:=bJAS_UnlockRecord(p_Context, DBC.ID, 'jtable',rJTable.JTabl_JTable_UID,'0',201501011020);
      If not bOk Then
      Begin
        JAS_Log(p_Context,cnLog_Error,201007121202,'Trouble unlocking JTable Record.','rJTable.JTabl_JTable_UID:' + rJTable.JTabl_JTable_UID,SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      End;

      if bOk then
      begin
        p_Context.saPage:=saGetPage(p_Context,'','sys_deletetableconfirm','CANCEL',false,'', 201212040823);
      end;      
      //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE TABLE - UNLOCK - Unlocked Table. bOk: '+saYesNo(bOk),'',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    if (false=p_Context.CGIENV.DataIn.FoundItem_saName('DELETE',false)) and
       (true=p_Context.CGIENV.DataIn.FoundItem_saName('CONFIRM',false)) then
    begin
      // Load Info and Ask for Confirmation - Redirect back to here if user chooses NO
      rJTable.JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('CONFIRM');
      bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable,true);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201007121203,'Trouble Loading Specified JTable Record.','rJTable.JTabl_JTable_UID:' + rJTable.JTabl_JTable_UID,SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
      //JAS_Log(p_Context,nLog_Debug,201204140452,'CONFIRM MODE - Loaded-n-Locked tablebOk: '+saYesNo(bOk),'',SOURCEFILE);

      if bOk then
      begin
        p_Context.saPage:=saGetPage(p_Context,'','sys_deletetableconfirm','CONFIRMDELETE',false,'',123020100039);
        with rJTable do begin
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_JTABLE_UID@]',JTabl_JTable_UID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_NAME@]',JTabl_Name);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_DESC@]',JTabl_Desc);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_JDCONNECTION_ID@]',JTabl_JDConnection_ID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_JTABLETYPE_ID@]',JTabl_JTableType_ID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_COLUMNPREFIX@]',JTabl_ColumnPrefix);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_CREATEDBY_JUSER_ID@]',JTabl_CreatedBy_JUser_ID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_CREATED_DT@]',JTabl_Created_DT);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_MODIFIEDBY_JUSER_ID@]',JTabl_ModifiedBy_JUser_ID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_MODIFIED_DT@]',JTabl_Modified_DT);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_DELETEDBY_JUSER_ID@]',JTabl_DeletedBy_JUser_ID);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_DELETED_DT@]',JTabl_Deleted_DT);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_DELETED_B@]',JTabl_Deleted_b);
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JAS_ROW_B@]',JTabl_Deleted_b);
        end;//with
        //bDone:=true;
      end;
      // Redirect back to here with CONFIRM flag set if user chooses to delete screen
    end else

    if (true=p_Context.CGIENV.DataIn.FoundItem_saName('DELETE',false)) and (false=p_Context.CGIENV.DataIn.FoundItem_saName('CONFIRM',false))then
    begin
      // Check Lock is Valid Still first then...
      rJTable.JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('DELETE');
      bOk:=bJAS_RecordLockValid(p_Context, DBC.ID, 'jtable',rJTable.JTabl_JTable_UID,'0',201501011050);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201007121204,'Record Lock Not Valid.','rJTable.JTabl_JTable_UID:' + rJTable.JTabl_JTable_UID,SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
      //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - Checked Lock Valid Still bOk: '+saYesNo(bOk),'',SOURCEFILE);


      if bOk then
      begin
        bOk:=bJAS_Load_JTable(p_Context,DBC,rJTable, false);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error,201007121205,'Trouble Loading JTable Record with bJAS_Load_JTable','rJTable.JTabl_JTable_UID:' + rJTable.JTabl_JTable_UID,SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;
      end;
      //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - Loaded Table bOk: '+saYesNo(bOk),'',SOURCEFILE);

      if bOk then
      begin
        saQry:='select JColu_JColumn_UID from jcolumn where JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+
          ' and JColu_JTable_ID='+DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID);
        bOk:=rs.Open(saQry,DBC,201503161191);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error,201007121208,'Trouble with Query on jcolumn.','Query: ' + saQry,SOURCEFILE,DBC,rs);
          RenderHtmlErrorPage(p_Context);
        end;
        //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - Queryied columns bOk: '+saYesNo(bOk),'',SOURCEFILE);

        if bOk and (rs.eol=false) then
        begin
          repeat
            bOk:=bJAS_Lockrecord(p_Context, DBC.ID, 'jcolumn',rs.Fields.Get_saValue('JColu_JColumn_UID'),'0',201501011021);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error,201204061526,'Unable to lock column Column UID: '+rs.Fields.Get_saValue('JColu_JColumn_UID'),'',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end
            else
            begin
              bOk:=bJAS_DeleteRecord(p_Context,DBC,'jcolumn',rs.Fields.Get_saValue('JColu_JColumn_UID'));
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error,201007121605,'Trouble deleting column from jcolumn table. Column UID: '+rs.Fields.Get_saValue('JColu_JColumn_UID'),'',SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              end;
            end;
            //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - Lock -n- delete Column bOk: '+saYesNo(bOk),'',SOURCEFILE);


            if bOk then
            begin
              bOk:=bJAS_UnlockRecord(p_Context, DBC.ID, 'jcolumn',rs.Fields.Get_saValue('JColu_JColumn_UID'),'0',201501011022);
              If not bOk Then
              Begin
                JAS_Log(p_Context,cnLog_Error,201204140437,'Trouble unlocking jcolumn Record.','jcolumn.JColu_JColumn_UID:' + rs.Fields.Get_saValue('JColu_JColumn_UID'),SOURCEFILE);
                RenderHtmlErrorPage(p_Context);
              End;
            end;

            //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - unlocked Column bOk: '+saYesNo(bOk),'',SOURCEFILE);

          until (not bOk) or (not rs.movenext);
          rs.close;
        end;
      end;

      // Delete Record - Redirect back to here so URI is clean.
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jtable',rJTable.JTabl_JTable_UID);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error,201007121232,'Trouble deleting JTable record.','',SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;
        //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - Delted Table bOk: '+saYesNo(bOk),'',SOURCEFILE);

      end;

      if bOk then
      begin
        bOk:=bJAS_UnlockRecord(p_Context, DBC.ID, 'jtable',rJTable.JTabl_JTable_UID, '0',201501011023);
        If not bOk Then
        Begin
          JAS_Log(p_Context,cnLog_Error,201204140438,'Trouble unlocking jtable Record after removing the table from JAS.',
            'jtable.JTabl_JTable_UID:' + rJTable.JTabl_JTable_UID,SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        End;
        //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - removed Lock on table bOk: '+saYesNo(bOk),'',SOURCEFILE);
      end;

      if bOk then
      begin
        p_Context.saPage:=saGetPage(p_Context,'','sys_deletetablecomplete','DELETESUCCESS',false,'', 123020100039);
        p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JTABL_NAME@]',rJTable.JTabl_Name);
        //JAS_Log(p_Context,nLog_Debug,201204140452,'DELETE MODE  - grabbed our output page bOk: '+saYesNo(bOk),'',SOURCEFILE);
      end;
    end else

    begin
      JAS_Log(p_Context,cnLog_Error,201204061535,'Invalid parameters sent to DeleteTable function.','',SOURCEFILE);
    end;
  end;
  rs.Destroy;
  rs2.Destroy;
  //rs3.Destroy;
  //rs4.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102633,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================






//=============================================================================
{}
// URI Parameters:
// JTabl_JTable_UID = JTable Record containing table or view you wish to make
//   a search screen and a data screen for. Connection is figured out from
//   this information. a data connection doesn't need to be active to make a
//   screen for it.
// Name = If not passed resorts to JTable Table Name. Whether
//  passed or not however, if the Screen Name + ' ' + 'Search' or
//  Screen Name + ' ' + 'Data' already exists then an error is thrown.
//
// This function might not belong in this unit - as it does it's task and
// returns an XML document - however because it is so integral to the
// User Interface - it's here.
//
// TODO: Move this to the JASAPI side of things and make it work using the
//       extensible xml mechanisms. e.g. i01j_api_xml.pp
procedure JAS_CreateScreensForTable(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saErrCode: ansistring;
  saErrMsg: ansistring;
  saActionType: ansistring;
  saData: Ansistring;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rJTable: rtJTable;
  rJScreenSearch: rtJScreen;
  rJScreenData: rtJScreen;
  rJBlokFilter: rtJBlok;
  rJBlokGrid: rtJBlok;
  rJBlokData: rtJBlok;
  rJBlokButton: rtJBlokButton;
  rJBlokField: rtJBlokField;
  //rJCaption: rtJCaption;
  rJColumn: rtJColumn;
  saScreenBaseName: ansistring;
  i4FieldPos: longint;
  u2JDType: word;// used for the block field inserts

  saJSecPerm_ID  : Ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_JScreenWizard(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102634,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102635, sTHIS_ROUTINE_NAME);{$ENDIF}

  saActionType:='xml';
  saErrCode:='';
  saErrMsg:='';
  saData:='';

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;

  If not bOk Then
  Begin
    saErrCode:='201007130244';
    saErrMsg:='JAS_CreateScreensForTable - Invalid Session. You are not logged in.'+' '+SOURCEFILE;
  End;

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_Admin);
    If not bOk Then
    Begin
      saErrCode:='201007130245';
      saErrMsg:='JAS_CreateScreensForTable - You are not authorized to view this page. Missing Admin Permission. JUser_JUser_UID:' + inttostR(p_Context.rJUser.JUser_JUser_UID)+' '+SOURCEFILE;
    End;
  End;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('JTabl_JTable_UID');
    if not bOk then
    begin
      saErrCode:='201007130246';
      saErrMsg:='JAS_CreateScreensForTable - Missing JTabl_JTable_UID Parameter.'+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    rJTable.JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Item_saValue;
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable, false);
    if not bOk then
    begin
      saErrCode:='201007130246';
      saErrMsg:='JAS_CreateScreensForTable - Unable to load jtable record. rJTable.JTabl_JTable_UID: '+rJTable.JTabl_JTable_UID+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    // ---- GET VIEW PERMISSION FOR TABLE IF AVAILABLE
    saQry:='JSPrm_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND JSPrm_Name='+DBC.saDBMSScrub(rJTable.JTabl_Name+' View');
    saJSecPerm_ID:=DBC.saGetValue('jsecperm', 'JSPrm_JSecPerm_UID', saQry);
    // ---- GET VIEW PERMISSION FOR TABLE IF AVAILABLE

    saScreenBaseName:=rJTable.JTabl_Name;
    if p_Context.CGIENV.DataIn.FoundItem_saName('Name') then
    begin
      saScreenBaseName:=p_Context.CGIENV.DataIn.Item_saValue;
    end;

    saQry:='select count(*) as MyCount from jscreen where '+
      '(UPPER(JScrn_Name)='+DBC.saDBMSScrub(upcase(saScreenBaseName+' SEARCH')) + ' or '+
      'UPPER(JScrn_Name)='+DBC.saDBMSScrub(upcase(saScreenBaseName+' DATA'))+') and JScrn_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
    bOk:=rs.Open(saQry,DBC,201503161192);
    if not bOk then
    begin
      saErrCode:='201007130247';
      saErrMsg:='Trouble with query.';
    end;

    if bOk then
    begin
      bOk:= iVal(rs.fields.get_savalue('MyCount'))=0;
      if not bOk then
      begin
        saErrCode:='201007130248';
        saErrMsg:='Screen(s) already exist.';
      end;
    end;
    rs.close;
  end;

  if bOk then
  begin
    rJScreenSearch.JScrn_JScreen_UID:='0';
    bOk:=bJAS_Save_JScreen(p_Context, DBC, rJScreenSearch, false,false);
    if not bOk then
    begin
      saErrCode:='201007130249';
      saErrMsg:='Unable to create new Search Screen. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    rJScreenData.JScrn_JScreen_UID:='0';

    bOk:=bJAS_Save_JScreen(p_Context, DBC, rJScreenData, false,false);
    if not bOk then
    begin
      saErrCode:='201007130250';
      saErrMsg:='Unable to create new Data Screen '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJScreenSearch do begin
      JScrn_Name                := saScreenBaseName+' Search';
      JScrn_Desc                := rJTable.JTabl_Desc;
      JScrn_JCaption_ID         := 'NULL';//TODO: Add Captions
      JScrn_JScreenType_ID      := inttostR(cnJScreenType_FilterGrid);// Filter Grid (or Search)
      JScrn_Template            := 'screenfiltergrid';
      JScrn_ValidSessionOnly_b  := 'true';
      JScrn_JSecPerm_ID         := saJSecPerm_ID;
      JScrn_Detail_JScreen_ID   := rJScreenData.JScrn_JScreen_UID;
      JScrn_IconSmall           := '<? echo $JASDIRICONTHEME; ?>32/apps/accessories-terminal.png';
      JScrn_IconLarge           := '<? echo $JASDIRICONTHEME; ?>64/apps/accessories-terminal.png';
    end;//with


    with rJScreenData do begin
      JScrn_Name                := saScreenBaseName+' Data';
      JScrn_Desc                := rJTable.JTabl_Desc;
      JScrn_JCaption_ID         := 'NULL';//TODO: Add Captions
      JScrn_JScreenType_ID      := inttostR(cnJScreenType_Data);// Data (or Detail)
      JScrn_Template            := 'screendetail';
      JScrn_ValidSessionOnly_b  := 'true';
      JScrn_JSecPerm_ID         := saJSecPerm_ID;
      JScrn_Detail_JScreen_ID   := '0';//Doesn't Apply
      JScrn_IconSmall           := '<? echo $JASDIRICONTHEME; ?>32/apps/accessories-terminal.png';
      JScrn_IconLarge           := '<? echo $JASDIRICONTHEME; ?>64/apps/accessories-terminal.png';
    end;//with

    bOk:=bJAS_Save_JScreen(p_Context, DBC, rJScreenSearch, true, true);
    if not bOk then
    begin
      saErrCode:='201007130251';
      saErrMsg:='JAS_JScreenWizard - Unable to save new Search Screen '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_Save_JScreen(p_Context, DBC, rJScreenData, true, true);
    if not bOk then
    begin
      saErrCode:='201007130252';
      saErrMsg:='JAS_JScreenWizard - Unable to save new Data Screen '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokFilter do begin
      JBlok_JBlok_UID     := '0';
      JBlok_JScreen_ID    := rJScreenSearch.JScrn_JScreen_UID;
      JBlok_JCaption_ID   := 'NULL';
      JBlok_Columns_u     := '3';
      JBlok_Custom        := '';
      JBlok_IconSmall     := '<? echo $JASDIRICONTHEME; ?>32/apps/accessories-terminal.png';
      JBlok_IconLarge     := '<? echo $JASDIRICONTHEME; ?>64/apps/accessories-terminal.png';
      JBlok_JTable_ID     := rJTable.JTabl_JTable_UID;
      JBlok_Name          := saScreenBaseName + ' Filter';
      JBlok_JBlokType_ID  := inttostR(cnJBlokType_Filter);// Filter Type
      JBlok_Position_u    := '0';
    end;
    bOk:=bJAS_Save_JBlok(p_Context, DBC, rJBlokFilter, false,false);
    if not bOk then
    begin
      saErrCode:='201007130253';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlok (Filter) Record. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokGrid do begin
      JBlok_JBlok_UID     := '0';
      JBlok_JScreen_ID    := rJScreenSearch.JScrn_JScreen_UID;
      JBlok_JCaption_ID   := 'NULL';
      JBlok_Columns_u     := '0';//Doesnt apply
      JBlok_Custom        := '';
      JBlok_IconSmall     := '<? echo $JASDIRICONTHEME; ?>32/apps/accessories-terminal.png';
      JBlok_IconLarge     := '<? echo $JASDIRICONTHEME; ?>64/apps/accessories-terminal.png';
      JBlok_JTable_ID     := rJTable.JTabl_JTable_UID;
      JBlok_Name          := saScreenBaseName + ' Grid';
      JBlok_JBlokType_ID  := inttostR(cnJBlokType_Grid);// Grid Type
      JBlok_Position_u    := '1';
    end;
    bOk:=bJAS_Save_JBlok(p_Context, DBC, rJBlokGrid, false,false);
    if not bOk then
    begin
      saErrCode:='201007130254';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlok (Grid) Record. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokData do begin
      JBlok_JBlok_UID     := '0';
      JBlok_JScreen_ID    := rJScreenData.JScrn_JScreen_UID;
      JBlok_JCaption_ID   := 'NULL';
      JBlok_Columns_u     := '4';
      JBlok_Custom        := '';
      JBlok_IconSmall     := '<? echo $JASDIRICONTHEME; ?>32/apps/accessories-terminal.png';
      JBlok_IconLarge     := '<? echo $JASDIRICONTHEME; ?>64/apps/accessories-terminal.png';
      JBlok_JTable_ID     := rJTable.JTabl_JTable_UID;
      JBlok_Name          := saScreenBaseName + ' Data';
      JBlok_JBlokType_ID  := inttostR(cnJBlokType_Data);// Data Type (Detail Screen)
      JBlok_Position_u      := '0';
    end;
    bOk:=bJAS_Save_JBlok(p_Context, DBC, rJBlokData, false,false);
    if not bOk then
    begin
      saErrCode:='201007130254';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlok (Grid) Record. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '0';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/document-revert.png';
      JBlkB_JBlok_ID        := rJBlokFilter.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '1';
      JBlkB_Name            := 'RESET';
      JBlkB_Position_u      := '2';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130255';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID          := '1';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/edit-redo.png';
      JBlkB_JBlok_ID        := rJBlokFilter.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '2';
      JBlkB_Name            := 'RELOAD';
      JBlkB_Position_u      := '3';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130256';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;


  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID          := '2';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/system-search.png';
      JBlkB_JBlok_ID        := rJBlokFilter.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '3';
      JBlkB_Name            := 'FIND';
      JBlkB_Position_u      := '5';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130257';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID          := '3';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/window-new.png';
      JBlkB_JBlok_ID        := rJBlokFilter.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '4';
      JBlkB_Name            := 'ADDNEW';
      JBlkB_Position_u      := '4';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130258';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID          := '9';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/document-close.png';
      JBlkB_JBlok_ID        := rJBlokFilter.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '10';
      JBlkB_Name            := 'CLOSE';
      JBlkB_Position_u      := '1';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130259';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;



  // Detail RECORD Buttons ----------------------------------------------------
  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '9';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/document-close.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '10';
      JBlkB_Name            := 'CLOSE';
      JBlkB_Position_u      := '1';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130304';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '4';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/document-save.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '5';
      JBlkB_Name            := 'SAVE';
      JBlkB_Position_u      := '2';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130300';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '10';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/document-save.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '4054';
      JBlkB_Name            := 'SAVE AND CLOSE';
      JBlkB_Position_u      := '3';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201203250951';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;


  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '6';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/dialog-cancel.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '7';
      JBlkB_Name            := 'CANCEL';
      JBlkB_Position_u      := '4';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130302';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '11';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/dialog-cancel.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '4055';
      JBlkB_Name            := 'CANCEL AND CLOSE';
      JBlkB_Position_u      := '5';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201203250952';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '7';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/edit.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '8';
      JBlkB_Name            := 'EDIT';
      JBlkB_Position_u      := '6';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130303';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    with rJBlokButton do begin
      JBlkB_JButtonType_ID  := '5';
      JBlkB_CustomURL       := '';
      JBlkB_GraphicFileName := '<? echo $JASDIRICONTHEME; ?>32/actions/edit-delete.png';
      JBlkB_JBlok_ID        := rJBlokData.JBlok_JBlok_UID;
      JBlkB_JBlokButton_UID := '0';
      JBlkB_JCaption_ID     := '6';
      JBlkB_Name            := 'DELETE';
      JBlkB_Position_u      := '7';
    end;//with
    bOk:=bJAS_Save_JBlokButton(p_Context, DBC, rJBlokButton, false,false);
    if not bOk then
    begin
      saErrCode:='201007130301';
      saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokButton. '+SOURCEFILE;
    end;
  end;



  // Detail RECORD Buttons ----------------------------------------------------

















  // BEGIN ----  SCREEN WIZARD --------------------  JBlokFilter
  if bOk then
  begin
    saQry:='SELECT JColu_JColumn_UID FROM jcolumn WHERE JColu_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true)+' and JColu_JTable_ID=' +
      DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID);
    bOk:=rs.Open(saQry, DBC,201503161193);
    if not bOk then
    begin
      saErrCode:='201007130308';
      saErrMsg:='JAS_JScreenWizard - Trouble with Query: '+saQry+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      i4FieldPos:=1;
      repeat
        rJColumn.JColu_JColumn_UID:=rs.fields.get_saValue('JColu_JColumn_UID');
        bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false);
        if not bOk then
        begin
          saErrCode:='201007130309';
          saErrMsg:='JAS_JScreenWizard - Unable to load JColumn record. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
        end;

        if bOk then
        begin
          u2JDType:=u2Val(rJColumn.JColu_JDType_ID);
          case u2JDType of
          // SEARCH
          cnJDType_Unknown: begin // Failsafe for where this stuff is hardcoded
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i1: begin // Integer - 1 Byte  i1
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i2: begin // Integer - 2 Bytes i2
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i4: begin       //Integer - 4 Bytes i4
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i8:   begin       //Integer - 8 Bytes i8
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i16: begin        //Integer - 16 Bytes  i16
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i32: begin        //Integer - 32 Bytes  i32
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u1: begin         //Integer - Unsigned - 1 Byte u1
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u2: begin         //Integer - Unsigned - 2 Bytes  u2
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u4: begin         //Integer - Unsigned - 4 Bytes  u4
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u8: begin        //Integer - Unsigned - 8 Bytes  u8
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u16: begin       //Integer - Unsigned - 16 Bytes u16
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u32: begin       //Integer - Unsigned - 32 Bytes u32
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fp:  begin       //Floating Point - Largest Supported by Platform  IEEE
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fd:  begin       //Floating Point - Fixed Decimal Places f??
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_cur:  begin      //Currency - Base U.S. Dollars  cur
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_s:  begin       //String - Ascii - x:=Fixed Max Length
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := rJColumn.JColu_DefinedSize_u;
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := rJColumn.JColu_DefinedSize_u;
              If iVal(JBlkF_Widget_Width) > 30 Then JBlkF_Widget_Width := '30';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_su:  begin      //String - Unicode - ?:=Max Length su?
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_ch:  begin       //Char - One Byte ch
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_chu:  begin      //Char - Unicode  chu
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_b: begin         //Boolean - Byte  b
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_dt:  begin       //Timestamp dt
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sn:  begin       //String - Ascii - Note/Glob/Memo sn
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sun:  begin      //String - Unicode - Note/Glob/Memo sun
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_bin:  begin      //Binary - Unspecified Length Binary Large Object
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          Else begin
            with rJBlokField do begin
              JBlkF_ColSpan_u           := '0';
              JBlkF_JBlok_ID            := rJBlokFilter.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID      := '0';
              JBlkF_JColumn_ID          := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID          := '0';
              JBlkF_Position_u          := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b          := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height     := '0';
              JBlkF_Widget_Mask         := '';
              JBlkF_Widget_MaxLength_u  := '0';
              JBlkF_Widget_Password_b   := 'false';
              JBlkF_Widget_Time_b       := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width      := '0';
              JBlkF_ClickAction_ID      := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData     := '';
              JBlkF_Width_is_Percent_b  :='false';
              JBlkF_Height_is_Percent_b :='false';
              JBlkF_Visible_b           :='true';
            end;//with
          End;
          end;//switch
          if bOk then
          begin
            bOk:=bJAS_Save_JBlokField(p_Context, DBC, rJBlokField, false,false);
            if not bOk then
            begin
              saErrCode:='201007130310';
              saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokField for current column. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
            end;
          end;

          i4FieldPos := i4FieldPos + 1;
        end;
      until (not bOk) or (not rs.movenext);
    end;
  end;

  rs.close;
  // END ------  SCREEN WIZARD --------------------  JBlokFilter














  // BEGIN ----  SCREEN WIZARD --------------------  JBlokGrid
  if bOk then
  begin
    saQry:='SELECT JColu_JColumn_UID FROM jcolumn WHERE JColu_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true)+' and JColu_JTable_ID=' +
      DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID);
    bOk:=rs.Open(saQry, DBC,201503161194);
    if not bOk then
    begin
      saErrCode:='201007130311';
      saErrMsg:='JAS_JScreenWizard - Trouble with Query: '+saQry+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      i4FieldPos:=1;
      repeat
        rJColumn.JColu_JColumn_UID:=rs.fields.get_saValue('JColu_JColumn_UID');
        bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false);
        if not bOk then
        begin
          saErrCode:='201007130312';
          saErrMsg:='JAS_JScreenWizard - Unable to load JColumn record. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
        end;

        if bOk then
        begin
          u2JDType:=u2Val(rJColumn.JColu_JDType_ID);
          case u2JDType of
          // SEARCH
          cnJDType_Unknown: begin // Failsafe for where this stuff is hardcoded
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i1: begin // Integer - 1 Byte  i1
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i2: begin // Integer - 2 Bytes i2
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i4: begin       //Integer - 4 Bytes i4
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i8:   begin       //Integer - 8 Bytes i8
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i16: begin        //Integer - 16 Bytes  i16
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i32: begin        //Integer - 32 Bytes  i32
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u1: begin         //Integer - Unsigned - 1 Byte u1
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u2: begin         //Integer - Unsigned - 2 Bytes  u2
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u4: begin         //Integer - Unsigned - 4 Bytes  u4
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u8: begin        //Integer - Unsigned - 8 Bytes  u8
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u16: begin       //Integer - Unsigned - 16 Bytes u16
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u32: begin       //Integer - Unsigned - 32 Bytes u32
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fp:  begin       //Floating Point - Largest Supported by Platform  IEEE
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fd:  begin       //Floating Point - Fixed Decimal Places f??
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_cur:  begin      //Currency - Base U.S. Dollars  cur
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_s:  begin       //String - Ascii - x:=Fixed Max Length
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := rJColumn.JColu_DefinedSize_u;
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := rJColumn.JColu_DefinedSize_u;
              If iVal(JBlkF_Widget_Width) > 40 Then JBlkF_Widget_Width := '40';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_su:  begin      //String - Unicode - ?:=Max Length su?
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_ch:  begin       //Char - One Byte ch
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_chu:  begin      //Char - Unicode  chu
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_b: begin         //Boolean - Byte  b
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_dt:  begin       //Timestamp dt
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sn:  begin       //String - Ascii - Note/Glob/Memo sn
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sun:  begin      //String - Unicode - Note/Glob/Memo sun
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_bin:  begin      //Binary - Unspecified Length Binary Large Object
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          Else begin
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokGrid.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          End;
          end;//switch
          if bOk then
          begin
            bOk:=bJAS_Save_JBlokField(p_Context, DBC, rJBlokField, false,false);
            if not bOk then
            begin
              saErrCode:='201007130313';
              saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokField for current column. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
            end;
          end;

          i4FieldPos := i4FieldPos + 1;
        end;
      until (not bOk) or (not rs.movenext);
    end;
  end;

  rs.close;
  // END ------  SCREEN WIZARD --------------------  JBlokGrid






















  // BEGIN ----  SCREEN WIZARD --------------------  JBlokData
  if bOk then
  begin
    saQry:='SELECT JColu_JColumn_UID FROM jcolumn WHERE JColu_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true)+' and JColu_JTable_ID=' +
      DBC.saDBMSUIntScrub(rJTable.JTabl_JTable_UID);
    bOk:=rs.Open(saQry, DBC,201503161195);
    if not bOk then
    begin
      saErrCode:='201007130314';
      saErrMsg:='JAS_JScreenWizard - Trouble with Query: '+saQry+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      i4FieldPos:=1;
      repeat
        rJColumn.JColu_JColumn_UID:=rs.fields.get_saValue('JColu_JColumn_UID');
        bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false);
        if not bOk then
        begin
          saErrCode:='201007130315';
          saErrMsg:='JAS_JScreenWizard - Unable to load JColumn record. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
        end;

        if bOk then
        begin
          u2JDType:=u2Val(rJColumn.JColu_JDType_ID);
          case u2JDType of
          // SEARCH
          cnJDType_Unknown: begin // Failsafe for where this stuff is hardcoded
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i1: begin // Integer - 1 Byte  i1
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i2: begin // Integer - 2 Bytes i2
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i4: begin       //Integer - 4 Bytes i4
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i8:   begin       //Integer - 8 Bytes i8
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i16: begin        //Integer - 16 Bytes  i16
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_i32: begin        //Integer - 32 Bytes  i32
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u1: begin         //Integer - Unsigned - 1 Byte u1
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u2: begin         //Integer - Unsigned - 2 Bytes  u2
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u4: begin         //Integer - Unsigned - 4 Bytes  u4
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u8: begin        //Integer - Unsigned - 8 Bytes  u8
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u16: begin       //Integer - Unsigned - 16 Bytes u16
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_u32: begin       //Integer - Unsigned - 32 Bytes u32
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fp:  begin       //Floating Point - Largest Supported by Platform  IEEE
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_fd:  begin       //Floating Point - Fixed Decimal Places f??
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_cur:  begin      //Currency - Base U.S. Dollars  cur
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_s:  begin       //String - Ascii - x:=Fixed Max Length
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := rJColumn.JColu_DefinedSize_u;
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := rJColumn.JColu_DefinedSize_u;
              If iVal(JBlkF_Widget_Width) > 40 Then JBlkF_Widget_Width := '40';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_su:  begin      //String - Unicode - ?:=Max Length su?
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_ch:  begin       //Char - One Byte ch
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_chu:  begin      //Char - Unicode  chu
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_b: begin         //Boolean - Byte  b
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_dt:  begin       //Timestamp dt
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sn:  begin       //String - Ascii - Fixed
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_sun:  begin      //String - Unicode - Fixed
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          cnJDType_bin:  begin      //Binary - Unspecified Length Binary Large Object
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b :=  saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          end;//case
          Else begin
            with rJBlokField do begin
              JBlkF_ColSpan_u := '0';
              JBlkF_JBlok_ID := rJBlokData.JBlok_JBlok_UID;
              JBlkF_JBlokField_UID := '0';
              JBlkF_JColumn_ID := rJColumn.JColu_JColumn_UID;
              JBlkF_JWidget_ID := '0';
              JBlkF_Position_u := inttostr(i4FieldPos);
              JBlkF_ReadOnly_b := saTrueFalse(saRightStr(rJColumn.JColu_Name,4)='_UID');
              JBlkF_Widget_Date_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Height := '0';
              JBlkF_Widget_Mask := '';
              JBlkF_Widget_MaxLength_u := '0';
              JBlkF_Widget_Password_b := 'false';
              JBlkF_Widget_Time_b := 'true'; // Only applies to Date/Time fields - making default yes
              JBlkF_Widget_Width := '0';
              JBlkF_ClickAction_ID := inttostr(cnJBlkF_ClickAction_DetailScreen);
              JBlkF_ClickActionData := '';
              JBlkF_Width_is_Percent_b:='false';
              JBlkF_Height_is_Percent_b:='false';
              JBlkF_Visible_b           :='true';
            end;//with
          End;
          end;//switch
          if bOk then
          begin
            bOk:=bJAS_Save_JBlokField(p_Context, DBC, rJBlokField, false,false);
            if not bOk then
            begin
              saErrCode:='201007130316';
              saErrMsg:='JAS_JScreenWizard - Unable to save new JBlokField for current column. rJColumn.JColu_JColumn_UID: '+rJColumn.JColu_JColumn_UID+' '+SOURCEFILE;
            end;
          end;

          i4FieldPos := i4FieldPos + 1;
        end;
      until (not bOk) or (not rs.movenext);
    end;
  end;

  rs.close;
  // END ------  SCREEN WIZARD --------------------  JBlokData




  if bOk then
  begin
    saData:='Success';
  end
  else
  begin
    JAS_LOG(p_Context, cnLog_Warn, u8Val(saErrCode), saErrMsg,'',SOURCEFILE);
  end;

  p_Context.bOutputRaw:=true;
  p_context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
  p_Context.saPage+='<?xml version="1.0" encoding="UTF-8" ?>' + csLF;
  p_Context.saPage+='<response>';
  p_Context.saPage+='<action type="'+saActionType+'" errorCode="'+saErrCode+'" errorMessage="'+saHTMLScrub(saErrMsg)+'" >';
  p_Context.saPage+=    saData;
  p_Context.saPage+='</action>';
  p_Context.saPage+='</response>' + csLF+csLF+csLF;
  p_Context.saMimeType:=csMIME_TextXML;
  p_Context.iDebugMode:=cnSYS_INFO_MODE_SECURE; // Prevent debug info from screwing up the output for the client getting this data

  rs.destroy;
  rs2.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102636,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
{}
procedure JAS_DeleteScreen(p_Context: TCONTEXT);
var
  bOk: boolean;
  saErrCode: ansistring;
  saErrMsg: ansistring;
  saActionType: ansistring;
  saData: Ansistring;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rJScreen: rtJScreen;
  rJBlok: rtJBlok;
  rJBlokButton: rtJBlokButton;
  rJBlokField: rtJBlokField;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_DeleteScreen(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201209031307,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201209031308, sTHIS_ROUTINE_NAME);{$ENDIF}


  saActionType:='xml';
  saErrCode:='';
  saErrMsg:='';
  saData:='';

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;

  If not bOk Then
  Begin
    saErrCode:='201209031310';
    saErrMsg:='JAS_DeleteScreen - Invalid Session. You are not logged in.'+' '+SOURCEFILE;
  End;

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_Admin);
    If not bOk Then
    Begin
      saErrCode:='201209031311';
      saErrMsg:='JAS_DeleteScreen - You are not authorized to view this page. Missing Admin Permission. JUser_JUser_UID:' + inttostR(p_Context.rJUser.JUser_JUser_UID)+' '+SOURCEFILE;
    End;
  End;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('JScrn_JScreen_UID');
    if not bOk then
    begin
      saErrCode:='201209031312';
      saErrMsg:='JAS_DeleteScreen - Missing JScrn_JScreen_UID Parameter.'+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    rJScreen.JScrn_JScreen_UID:=p_Context.CGIENV.DataIn.Item_saValue;
    bOk:=bJAS_Load_JScreen(p_Context, DBC, rJScreen, true);
    if not bOk then
    begin
      saErrCode:='201209031313';
      saErrMsg:='JAS_DeleteScreen - Unable to load jscreen record. JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    saQry:='select JBlok_JBlok_UID from jblok where ((JBlok_Deleted_b = '+
      DBC.saDBMSBoolScrub(false)+') or (JBlok_Deleted_b is NULL)) AND '+
      '(JBlok_JScreen_ID = '+DBC.saDBMSUIntScrub(rJScreen.JScrn_JScreen_UID)+' )';
    bOk:=rs.open(saQry, DBC,201503161196);
    if not bOk then
    begin
      saErrCode:='201209031340';
      saErrMsg:='JAS_DeleteScreen - Trouble with query on jblok table. JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID+' '+SOURCEFILE;
    end;
  end;

  if bOk then
  begin
    if not rs.eol then
    begin
      repeat
        clear_jblok(rJBlok);
        rJBlok.JBlok_JBlok_UID:=rs.fields.get_saValue('JBlok_JBlok_UID');
        bOk:=bJAS_Load_JBlok(p_Context, DBC, rJBlok, true);
        if not bOk then
        begin
          saErrcode:=inttostr(p_Context.u8ErrNo);
          saErrMsg:=p_Context.saErrMsg;
        end;

        //------------------------ JBLOKFIELD -------------------------------------------
        if bOk then
        begin
          saQry:='select JBlkF_JBlokField_UID from jblokfield where ((JBlkF_Deleted_b='+
            DBC.saDBMSBoolScrub(false)+
            ') or (JBlkF_Deleted_b is NULL)) and (JBlkF_JBlok_ID='+
            DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+')';
          bOk:=rs2.open(saQry, DBC,201503161197);
          if not bOk then
          begin
            saErrCode:='201209031346';
            saErrMsg:='JAS_DeleteScreen - Trouble with query on jblokfield table. JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID+' '+SOURCEFILE;
          end;
        
          if not rs2.eol then
          begin
            repeat
              clear_jblokfield(rJBlokField);
              rJBlokField.JBlkF_JBlokField_UID:=rs2.fields.Get_saValue('JBlkF_JBlokField_UID');
              bOk:=bJAS_LockRecord(p_Context, DBC.ID, 'jblokfield',rJBlokField.JBlkF_JBlokField_UID,'0',201501011024);
              if not bOk then
              begin
                saErrCode:='201209031353';
                saErrMsg:='JAS_DeleteScreen - Unable to lock JBlokField record. JBlkF_JBlokField_UID: '+rJBlokField.JBlkF_JBlokField_UID+' '+SOURCEFILE;
              end;

              if bOk then
              begin
                bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblokfield', rJBlokField.JBlkF_JBlokField_UID);
                if not bOk then
                begin
                  saErrCode:='201209031356';
                  saErrMsg:='JAS_DeleteScreen - Unable to delete JBlokField record. JBlkF_JBlokField_UID: '+rJBlokField.JBlkF_JBlokField_UID+' '+SOURCEFILE;
                end;
                bJAS_UnLockRecord(p_Context, DBC.ID, 'jblokfield',rJBlokField.JBlkF_JBlokField_UID,'0',201501011025);
              end;  
            until (not bOk) or (not rs2.movenext);
          end;
          rs2.close;
        end;
        //------------------------ JBLOKFIELD -------------------------------------------




        //------------------------ JBLOKBUTTON -------------------------------------------
        if bOk then
        begin
          saQry:='select JBlkB_JBlokButton_UID from jblokbutton where ((JBlkB_Deleted_b='+
            DBC.saDBMSBoolScrub(false)+') or (JBlkB_Deleted_b is NULL)) and (JBlkB_JBlok_ID='+
            DBC.saDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+')';
          bOk:=rs2.open(saQry, DBC,201503161198);
          if not bOk then
          begin
            saErrCode:='201209031412';
            saErrMsg:='JAS_DeleteScreen - Trouble with query on jblokbutton table. JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID+' '+SOURCEFILE;
          end;

          if not rs2.eol then
          begin
            repeat
              clear_jblokbutton(rJBlokButton);
              rJBlokButton.JBlkB_JBlokButton_UID:=rs2.fields.Get_saValue('JBlkB_JBlokButton_UID');
              bOk:=bJAS_LockRecord(p_Context, DBC.ID, 'jblokbutton',rJBlokButton.JBlkB_JBlokButton_UID,'0',201501011026);
              if not bOk then
              begin
                saErrCode:='201209031413';
                saErrMsg:='JAS_DeleteScreen - Unable to lock JBlokButton record. JBlkB_JBlokButton_UID: '+rJBlokButton.JBlkB_JBlokButton_UID+' '+SOURCEFILE;
              end;

              if bOk then
              begin
                bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblokbutton', rJBlokButton.JBlkB_JBlokButton_UID);
                if not bOk then
                begin
                  saErrCode:='201209031414';
                  saErrMsg:='JAS_DeleteScreen - Unable to delete JBlokButton record. JBlkB_JBlokButton_UID: '+rJBlokButton.JBlkB_JBlokButton_UID+' '+SOURCEFILE;
                end;
                bJAS_UnLockRecord(p_Context, DBC.ID, 'jblokbutton',rJBlokButton.JBlkB_JBlokButton_UID,'0',201501011027);
              end;
            until (not bOk) or (not rs2.movenext);
          end;
          rs2.close;
        end;
        //------------------------ JBLOKBUTTON -------------------------------------------






        if bOk then
        begin
          bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblok', rJBlok.JBlok_JBlok_UID);
          if not bOk then
          begin
            saErrCode:='201209031359';
            saErrMsg:='JAS_DeleteScreen - Unable to delete JBlok record. JBlok_JBlok_UID: '+rJBlok.JBlok_JBlok_UID+' '+SOURCEFILE;
          end;
          bJAS_UnLockRecord(p_Context, DBC.ID, 'jblok',rJBlok.JBlok_JBlok_UID,'0',201501011028);
        end;
      until (not bOk) or (not rs.movenext);
    end;
  end;
  rs.close;
  
  if bOk then
  begin
    bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jscreen', rJScreen.JScrn_JScreen_UID);
    if not bOk then
    begin
      saErrCode:='201209031400';
      saErrMsg:='JAS_DeleteScreen - Unable to delete JScreen record. JScrn_JScreen_UID: '+rJScreen.JScrn_JScreen_UID+' '+SOURCEFILE;
    end;
    bJAS_UnLockRecord(p_Context, DBC.ID, 'jscreen',rJScreen.JScrn_JScreen_UID,'0',201501011029);
  end;

  if bOk then
  begin
    saData:='Success';
  end
  else
  begin
    JAS_LOG(p_Context, cnLog_Warn, u8Val(saErrCode), saErrMsg,'',SOURCEFILE);
  end;

  p_Context.bOutputRaw:=true;
  p_context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
  p_Context.saPage+='<?xml version="1.0" encoding="UTF-8" ?>' + csLF;
  p_Context.saPage+='<response>';
  p_Context.saPage+='<action type="'+saActionType+'" errorCode="'+saErrCode+'" errorMessage="'+saHTMLScrub(saErrMsg)+'" >';
  p_Context.saPage+=    saData;
  p_Context.saPage+='</action>';
  p_Context.saPage+='</response>' + csLF+csLF+csLF;
  p_Context.saMimeType:=csMIME_TextXML;
  p_Context.iDebugMode:=cnSYS_INFO_MODE_SECURE; // Prevent debug info from screwing up the output for the client getting this data

  rs.destroy;
  rs2.destroy;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201209031309,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




















//=============================================================================
{}
// I was having trouble toggling the debug output today - verbose, verbose local,
// and things weren't revealing what was wrong aside from the fact I broke it.
// This diagnostic tool is an attempt to FORCE the issue and end up with a useful
// leftover tidbit for administrators needing to look about
procedure JAS_DiagnosticHTMLDump(p_Context: TCONTEXT);
var
  bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_DiagnosticHTMLDump(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102642,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102643, sTHIS_ROUTINE_NAME);{$ENDIF}

  //cnAction_DiagnosticHtmlDump
  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    //AS_Log(p_Context,nLog_DEBUG,201012231200,'Invalid Session. You are not logged in.','',SOURCEFILE);
  End;

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_Admin);
    If not bOk Then
    Begin
      //AS_Log(p_Context,nLog_DEBUG,201012231201,'You are not authorized to view this page.','Missing Admin Permission. JUser_JUser_UID:' + inttostr(p_Context.rJUser.JUser_JUser_UID),SOURCEFILE);
    End;
  End;

  if bOk then
  begin
    p_Context.iDebugMode:=cnSYS_INFO_MODE_VERBOSE;
    //p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page','MAIN',false,123020100041);

    p_Context.saPage:=saGetPage(
      p_Context,
      'sys_area_bare',
      'sys_page',
      '',
      false,
      '<CENTER><h1>Diagnostic State and System Configuration</h1></center>',
      123020100041
    );




  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102644,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================














//=============================================================================
{}
procedure JAS_Merge(p_Context: TCONTEXT);
var
  bOk: boolean;
  rJTable: rtJTable;
  sR1: string;
  sR2: string;
  arJColumn: Array of rtJColumn;
  asCaption: array of string;
  aR1: Array of ansistring;
  aR2: Array of ansistring;
  iX: longint;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  sa: ansistring;
  sa2: ansistring;
  rAudit: rtAudit;
  saContent: ansistring;
  sPKeyName: ansistring;
  saButtons: ansistring;
  sButton: string;//incoming

  //sOutName: string;
  saOutValue: ansistring;
  sOutKey: string;

  bAdd, bView, bUpdate, bDelete: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_Merge(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204122039,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204122040, sTHIS_ROUTINE_NAME);{$ENDIF}

  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  DBC:=p_Context.VHDBC;
  setlength(arJColumn,0);
  setlength(aR1,0);
  setlength(aR2,0);
  setlength(asCaption,0);

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204122043,'Invalid Session. You are not logged in.','',SOURCEFILE);
    RenderHTMLErrorPage(p_Context);
  End;

  If bOk Then
  Begin
    //bOk:=p_Context.rJUser.JUser_Admin_b;
    //If not bOk Then
    //Begin
    //  JAS_Log(p_Context,nLog_DEBUG,201204122044,'You are not authorized to view this page.','Missing Admin Permission. JUser_JUser_UID:' + inttostR(p_Context.rJUser.JUser_JUser_UID),SOURCEFILE);
    //End;
  End;

  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('JTABLE');
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable, false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204122047,'Unable to load jtable record: '+p_Context.CGIENV.DataIn.Get_saValue('JTABLE'),'',SOURCEFILE);
      RenderHTMLErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    TGT:=p_Context.DBCON(u8Val(rJTable.JTabl_JDConnection_ID));
    sR1:=p_Context.CGIENV.DataIn.Get_saValue('R1');
    sR2:=p_Context.CGIENV.DataIn.Get_saValue('R2');

    bOk:=bJAS_TablePermission(
      p_Context,
      rJTable,
      sR1,
      '',
      bAdd,bView,bUpdate,bDelete,
      false,true,true,true
    );
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211051206,'Unable to get permissions for table to authorize the merge.','Table: '+rJTable.JTabl_Name+' Row: '+sR1,SOURCEFILE);
      renderHTMLErrorPage(p_ContexT);
    end;
  end;

  if bOk then
  begin
    bOk:=bView and bUpdate and bDelete;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211051207,'You are not authorized to either view, update or delete the first record in the merge.','Table: '+rJTable.JTabl_Name+' Row: '+sR1,SOURCEFILE);
      renderHTMLErrorPage(p_ContexT);
    end;
  end;      

  if bOk then
  begin
    bOk:=bJAS_TablePermission(
      p_Context,
      rJTable,
      sR2,
      '',
      bAdd,bView,bUpdate,bDelete,
      false,true,true,true
    );  
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211051208,'Unable to get permissions for table to authorize the merge.','Table: '+rJTable.JTabl_Name,SOURCEFILE);
      renderHTMLErrorPage(p_ContexT);
    end;
  end;

  if bOk then
  begin
    bOk:=bView and bUpdate and bDelete;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211051209,'You are not authorized to either view, update or delete the second record in the merge.','Table: '+rJTable.JTabl_Name+' Row: '+sR2,SOURCEFILE);
      renderHTMLErrorPage(p_ContexT);
    end;
  end;

  if bOk then
  begin
    sButton:=p_Context.CGIENV.DataIn.Get_saValue('BUTTON');
    if sButton='CANCEL' then
    begin
      if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011052) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011030);
      if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011053) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011031);
      bOk:=bJASNote(p_Context,'2012041302161780767',sa,'Merge Cancelled.');
      sa+='<script language="javascript">self.close();</script>';
      p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false, 201204130208);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>32/actions/dialog-cancel.png');
      p_Context.saPageTitle:='Merge Cancelled';
    end else
    begin
      if bOk then
      begin
        clear_Audit(rAudit, rJTable.JTabl_ColumnPrefix);
        if not (bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011054) and bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011055)) then
        begin
          if bOk then
          begin
            bOk:=bJAS_LockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011032);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_ERROR,201204122048,'Unable to lock record '+sR1+' in the '+rJTable.JTabl_Name+' table.','',SOURCEFILE);
              RenderHTMLErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            bOk:=bJAS_LockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011033);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_ERROR,201204122049,'Unable to lock record '+sR2+' in the '+rJTable.JTabl_Name+' table.','',SOURCEFILE);
              RenderHTMLErrorPage(p_Context);
            end;
          end;
        end;
      end;


      if bOk then
      begin
        saQry:='SELECT JColu_JColumn_UID FROM jcolumn WHERE JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
          'JColu_JTable_ID='+rJTable.JTabl_JTable_UID;
        bOk:=rs.open(saQry,DBC,201503161199);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_ERROR,201204122105,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
          RenderHTMLErrorPage(p_Context);
        end;
      end;

      if bOk then
      begin
        repeat
          setlength(arJColumn,length(arJColumn)+1);
          clear_jcolumn(arJColumn[length(arJColumn)-1]);
          arJColumn[length(arJColumn)-1].JColu_JColumn_UID:=rs.fields.Get_saValue('JColu_JColumn_UID');
          bOk:=bJAS_Load_JColumn(p_Context,DBC,arJColumn[length(arJColumn)-1],false);
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_ERROR,201204122106,'Unable to load jcolumn record.','',SOURCEFILE);
            RenderHTMLErrorPage(p_Context);
          end;

          if bOk then
          begin
            if not rAudit.bUse_CreatedBy_JUser_ID then rAudit.bUse_CreatedBy_JUser_ID:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_CreatedBy_JUser_ID;
            if not rAudit.bUse_Created_DT then rAudit.bUse_Created_DT:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_Created_DT;
            if not rAudit.bUse_ModifiedBy_JUser_ID then rAudit.bUse_ModifiedBy_JUser_ID:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_ModifiedBy_JUser_ID;
            if not rAudit.bUse_Modified_DT then rAudit.bUse_Modified_DT:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_Modified_DT;
            if not rAudit.bUse_DeletedBy_JUser_ID then rAudit.bUse_DeletedBy_JUser_ID:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_DeletedBy_JUser_ID;
            if not rAudit.bUse_Deleted_DT then rAudit.bUse_Deleted_DT:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_Deleted_DT;
            if not rAudit.bUse_Deleted_b then rAudit.bUse_Deleted_b:=arJColumn[length(arJColumn)-1].JColu_Name=rAudit.saFieldName_Deleted_b;
            if bVal(arJColumn[length(arJColumn)-1].JColu_PrimaryKey_b) then sPKeyName:=arJColumn[length(arJColumn)-1].JColu_Name;
          end;

          if bOk then
          begin
            setlength(asCaption,length(arJColumn));
            bOk:=bJASCaption(p_Context,arJColumn[length(arJColumn)-1].JColu_JCaption_ID,sa,arJColumn[length(arJColumn)-1].JColu_Name);
            asCaption[length(asCaption)-1]:=sa;
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_ERROR,201204122107,'Unable to load caption.','',SOURCEFILE);
              RenderHTMLErrorPage(p_Context);
            end;
          end;
        until (not bOk) or (not rs.movenext);
      end;
      rs.close;

      if bOk then
      begin
        saQry:='select * from '+rJTable.JTabl_Name+' WHERE '+sPKeyName+'='+TGT.saDBMSUIntScrub(sR1);
        if rAudit.bUse_Deleted_b then saQry+=' AND '+rAudit.saFieldName_Deleted_b+'<>'+TGT.saDBMSBoolScrub(true);
        bOk:=rs.open(saQry, TGT,201503161200);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_ERROR,201204122108,'Trouble with query.','Query: '+saQry,SOURCEFILE, TGT, rs);
          RenderHTMLErrorPage(p_Context);
        end;
      end;

      if bOk then
      begin
        saQry:='select * from '+rJTable.JTabl_Name+' WHERE '+sPKeyName+'='+TGT.saDBMSUIntScrub(sR2);
        if rAudit.bUse_Deleted_b then saQry+=' AND '+rAudit.saFieldName_Deleted_b+'<>'+TGT.saDBMSBoolScrub(true);
        bOk:=rs2.open(saQry, TGT,201503161201);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_ERROR,201204122109,'Trouble with query.','Query: '+saQry,SOURCEFILE, TGT, rs);
          RenderHTMLErrorPage(p_Context);
        end;
      end;

      if bOk then
      begin
        bOk:=(not rs.eol) and (not rs2.eol);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_ERROR,201204122109,'One or both records could not be loaded for the merge.','',SOURCEFILE);
          RenderHTMLErrorPage(p_Context);
        end;
      end;

      if sButton='' then
      begin
        if bOk then
        begin
          saContent:=
            '<form action="." method="POST" id="JASFORM" name="JASFORM" enctype="application/x-www-form-urlencoded" />'+csCRLF+
            '<input type="hidden" name="BUTTON" id="BUTTON" value="" />'+csCRLF+
            '<input type="hidden" name="Action" value="merge" />'+csCRLF+
            '<input type="hidden" name="jtable" value="'+rJTable.JTabl_JTable_UID+'" />'+csCRLF+
            '<input type="hidden" name="r1" value="'+sR1+'" />'+csCRLF+
            '<input type="hidden" name="r2" value="'+sR2+'" />'+csCRLF+
            '<script language="javascript">'+csCRLF+
            '  function JButton(p_b){ document.getElementById("BUTTON").value=p_b; document.getElementById("JASFORM").submit(); }'+csCRLF+
            '</script>'+csCRLF+
            '<table>'+
              '<tr><td colspan="5"><strong>Select Record to Keep - #1 or #2</strong></td></tr>'+
              '<tr><td colspan="5"><hr /></td></tr>'+
              '<tr>'+
                '<td></td>'+
                '<td><input checked type="radio" name="keep" value="r1" /></td>'+
                '<td>Record #1</td>'+
                '<td><input type="radio" name="keep" value="r2" /></td>'+
                '<td>Record #2</td>'+
              '</tr>'+
              '<tr><td colspan="5"><strong>Select Data to keep from either record.</strong></td></tr>'+
              '<tr><td colspan="5"><hr /></td></tr>';

          iX:=0;
          repeat
            if bVal(arJColumn[iX].JColu_PrimaryKey_b) then
            begin
              saContent+=
                '<tr>'+
                  '<td>'+saHTMLScrub(asCaption[iX])+'</td>'+
                  '<td></td>'+
                  '<td width="30%">'+rs.fields.Get_saValue(arJColumn[iX].JColu_Name)+'</td>'+
                  '<td></td>'+
                  '<td width="30%">'+rs2.fields.Get_saValue(arJColumn[iX].JColu_Name)+'</td>'+
                '</tr>'+
                '<tr><td colspan="5"><hr /></td></tr>';
            end
            else
            if (arJColumn[iX].JColu_Name<>rAudit.saFieldName_CreatedBy_JUser_ID) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_Created_DT) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_ModifiedBy_JUser_ID) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_Modified_DT) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_DeletedBy_JUser_ID) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_Deleted_DT) and
               (arJColumn[iX].JColu_Name<>rAudit.saFieldName_Deleted_b) and
               (arJColumn[iX].JColu_Name<>'JAS_Row_b') then
            begin
              if u8Val(arJColumn[iX].JColu_LU_JColumn_ID)>0 then
              begin
                sa:=p_Context.saLookUp(rJTable.JTabl_Name,arJColumn[iX].JColu_Name,rs.fields.Get_saValue(arJColumn[iX].JColu_Name));
              end
              else
              begin
                sa:=rs.fields.Get_saValue(arJColumn[iX].JColu_Name);
                if ((bVal(arJColumn[iX].JColu_Boolean_b))OR(u2Val(arJColumn[iX].JColu_JDtype_ID)=cnJDType_b)) and (sa<>'NULL') then sa:=saYesNo(bVal(sa));
              end;

              if u8Val(arJColumn[iX].JColu_LU_JColumn_ID)>0 then
              begin
                sa2:=p_Context.saLookUp(rJTable.JTabl_Name,arJColumn[iX].JColu_Name,rs2.fields.Get_saValue(arJColumn[iX].JColu_Name));
              end
              else
              begin
                sa2:=rs2.fields.Get_saValue(arJColumn[iX].JColu_Name);
                if ((bVal(arJColumn[iX].JColu_Boolean_b))OR(u2Val(arJColumn[iX].JColu_JDtype_ID)=cnJDType_b)) and (sa2<>'NULL') then sa2:=saYesNo(bVal(sa2));
              end;

              saContent+=
                '<tr>'+
                  '<td>'+saHTMLScrub(asCaption[iX])+'</td>'+
                  '<td><input checked type="radio" name="'+arJColumn[iX].JColu_Name+'" value="r1" /></td>'+
                  '<td width="30%">'+sa+'</td>'+
                  '<td><input type="radio" name="'+arJColumn[iX].JColu_Name+'" value="r2" /></td>'+
                  '<td width="30%">'+sa2+'</td>'+
                '</tr>'+
                '<tr><td colspan="5"><hr /></td></tr>';
            end;
            iX+=1;
          until iX>=length(arJColumn);
          saContent+='</table></form>';
          saContent+='<p>Length arJColumn:'+inttostr(length(aRJColumn))+'</p>';
        end;
      end
      else
      begin
        // MERGE OPERATION HERE - Record Sets Open, Array Built - Ready for action
        iX:=0;saQry:='';
        repeat
          if p_Context.CGIENV.DataIn.FoundItem_saName(arJColumn[iX].JColu_Name) then
          begin
            //sOutName:=arJColumn[iX].JColu_Name;
            if p_Context.CGIENV.DataIn.Item_saValue='r1' then
              saOutValue:=rs.fields.Get_saValue(arJColumn[iX].JColu_Name)
            else
              saOutValue:=rs2.fields.Get_saValue(arJColumn[iX].JColu_Name);
            case u2Val(arJColumn[iX].JColu_JDType_ID) of
            cnJDType_i1,
            cnJDType_i2,
            cnJDType_i4,
            cnJDType_i8,
            cnJDType_i16,
            cnJDType_i32:begin
              saOutValue:=TGT.saDBMSIntScrub(saOutValue);
            end;
            cnJDType_u1,
            cnJDType_u2,
            cnJDType_u4,
            cnJDType_u8,
            cnJDType_u16,
            cnJDType_u32:begin
              saOutValue:=TGT.saDBMSUIntScrub(saOutValue);
            end;
            cnJDType_fp,
            cnJDType_fd,
            cnJDType_cur:begin
              saOutValue:=TGT.saDBMSDecScrub(saOutValue);
            end;
            cnJDType_Unknown,
            cnJDType_s,
            cnJDType_su,
            cnJDType_ch,
            cnJDType_chu,
            cnJDType_sn,
            cnJDType_sun,
            cnJDType_bin:begin // 37 Jegas Data Type - Binary - Unspecified Length Binary Large Object
              saOutValue:=TGT.saDBMSScrub(saOutValue);
            end;
            cnJDType_b        :begin // 20 Jegas Data Type - Boolean - Byte	b
              saOutValue:=TGT.saDBMSBoolScrub(saOutValue);
            end;
            cnJDType_dt       :begin // 23 Jegas Data Type - Timestamp	dt
              saOutValue:=TGT.saDBMSDateScrub(saOutValue);
            end;
            end;//case
            if saQry<>'' then saQry+=', ';
            saQry+=arJColumn[iX].JColu_Name+'='+saOutValue;
          end;
          iX+=1;
        until iX>=length(arJColumn);
        if p_Context.CGIENV.DataIn.Get_saValue('KEEP')='r1' then sOutKey:=sR1 else sOutKey:=sR2;
        saQry:='UPDATE ' + rJTable.JTabl_Name +' SET ' + saQry + ' WHERE ' + sPKeyName + '='+TGT.saDBMSUIntScrub(sOutKey);
        rs.close;
        p_Context.JTrakBegin(TGT,rJTable.JTabl_Name, sOutKey);
        bOk:=rs.open(saQry, TGT,201503161202);
        p_Context.JTrakEnd(sOutKey);
        if not bOk then
        begin
          JAS_LOG(p_COntext, cnLog_error, 201204130256, 'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT,rs);
          RenderHTMLErrorPage(p_Context);
        end;

        if bOk then
        begin
          // Notice the swap of r1 and r2
          if p_Context.CGIENV.DataIn.Get_saValue('KEEP')='r1' then sOutKey:=sR2 else sOutKey:=sR1;
          p_Context.JTrakBegin(TGT,rJTable.JTabl_Name, sOutKey);
          bOk:=bJAS_DeleteRecord(p_Context,TGT,rJTable.JTabl_Name,sOutKey);
          p_Context.JTrakEnd(sOutKey);
          if not bOk then
          begin
            JAS_LOG(p_COntext, cnLog_error, 201204130256, 'Trouble deleting record.','',SOURCEFILE);
            RenderHTMLErrorPage(p_Context);
          end;
        end;
      end;
      rs.close;rs2.close;

      if bOk then
      begin
        if sButton='' then
        begin
          saButtons:=csCRLF+
            '<a href="javascript: JButton(''CANCEL'');" title="Cancel Merge">'+csCRLF+
            '  <table>'+csCRLF+
            '  <tr>'+csCRLF+
            '    <td><img class="image" src="<? echo $JASDIRICONTHEME; ?>32/actions/dialog-cancel.png" /></td>'+csCRLF+
            '    <td>&nbsp;&nbsp;</td>'+csCRLF+
            '    <td><font size="4">Cancel</font></td>'+csCRLF+
            '  </tr>'+csCRLF+
            '  </table>'+csCRLF+
            '</a>'+csCRLF+
            '<a href="javascript: if(confirm(''Are you sure you wish to continue with this merge?'')){JButton(''MERGE'');}" title="Perform Merge">'+csCRLF+
            '  <table>'+csCRLF+
            '  <tr>'+csCRLF+
            '    <td><img class="image" src="<? echo $JASDIRICONTHEME; ?>32/actions/document-save.png" /></td>'+csCRLF+
            '    <td>&nbsp;&nbsp;</td>'+csCRLF+
            '    <td><font size="4">Save</font></td>'+csCRLF+
            '  </tr>'+csCRLF+
            '  </table>'+csCRLF+
            '</a>';
          p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_panel','',false,'',201204122200);
          p_Context.saPage:=saSNRStr(p_Context.saPage,'[@CONTENT@]',saContent);
          p_Context.saPage:=saSNRStr(p_Context.saPage,'[@PAGEICON@]','[@JASDIRICON@]iconarchive/must_have_icon_set/48/Pause.png');
          p_Context.saPage:=saSNRStr(p_Context.saPage,'[@BUTTONS@]',saButtons);
          p_Context.saPageTitle:='Merge Records - '+rJTable.JTabl_Name;
        end
        else
        begin
          if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011056) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011034);
          if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011057) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011035);
          bOk:=bJASNote(p_Context,'2012041302245673975',sa,'Merge successful');
          sa+='<script language="javascript">self.close();</script>';
          p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false, 201204130208);
          p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
          p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>32/actions/document-save.png');
          p_Context.saPageTitle:='Merge successful';
        end;
      end;
      if not bOk then
      begin
        if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011058) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR1,'0',201501011036);
        if bJAS_RecordLockValid(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011059) then bJAS_UnlockRecord(p_Context, TGT.ID, rJTable.JTabl_Name, sR2,'0',201501011037);
      end;
    end;
  end;
  if not bOk and (length(p_COntext.saPage)=0) then
  begin
    RenderHTMLErrorPage(p_Context);
  end;

  rs.Destroy;
  rs2.Destroy;
  setlength(arJColumn,0);
  setlength(aR1,0);
  setlength(aR2,0);
  setlength(asCaption,0);
  p_Context.bNoWebCache:=true;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204122042,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









































//=============================================================================
{}
procedure JAS_PromoteLead(p_Context: TCONTEXT);
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rJLead: rtJLead;
  rJPerson: rtJPerson;
  rJCompany: rtJCompany;
  //lprJPerson: ^rtJPerson;
  //lprJCompany: ^rtJCompany;
  //sUIDDupePerson: string;
  //uPersonDupes: Uint64;
  //sUIDDupeCompany: string;
  //uCompanyDupes: Uint64;
  saCompUID: ansistring;
  saPersUID: ansistring;

  ColXDL: JFC_XDL;
  PersXDL: JFC_XDL; //for Merge
  LeadXDL: JFC_XDL; //for Merge
  CompXDL: JFC_XDL;
  JCompanyXDL: JFC_XDL; //For In-Memory copy
  JPersonXDL: JFC_XDL; //For In-Memory copy


  uCompanyDupeCount: cardinal;
  bCompanyDupeFound: boolean;
  u4CompanyDupeScore: Cardinal;
  bAddCompany: boolean;
  bMergeCompany: boolean;
  bUseExistingCompany: boolean;
  //bMultipleCompanydupesfound: boolean;
  bHaveCompany: boolean;
  
  uPersonDupeCount: cardinal;
  bPersonDupeFound: boolean;
  u4PersonDupeScore: Cardinal;
  bAddPerson: boolean;
  bMergePerson: boolean;
  bUseExistingPerson: boolean;
  //bMultiplePersonDupesFound: boolean;
  bHavePerson: boolean;

  //sa: ansistring;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_PromoteLead'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204091550,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204091551, sTHIS_ROUTINE_NAME);{$ENDIF}

  p_Context.saPage:='<h1>Promote Lead</h1><br />';
  
  ColXDL:=JFC_XDL.Create;
  PersXDL:=JFC_XDL.Create;//for Merge
  LeadXDL:=JFC_XDL.Create;//for Merge
  CompXDL:=JFC_XDL.Create;
  JCompanyXDL:=JFC_XDL.Create;//For In-Memory copy
  JPersonXDL:=JFC_XDL.Create;//For In-Memory copy
  
  clear_JCompany(rJCompany);
  clear_JPerson(rJPerson);
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  uCompanyDupeCount:=0;
  bCompanyDupeFound:=false;
  u4CompanyDupeScore:=0;
  bAddCompany:=false;
  bMergeCompany:=false;
  bUseExistingCompany:=false;
  //bMultipleCompanydupesfound:= false;
  bHaveCompany:=true;

  uPersonDupeCount:=0;
  bPersonDupeFound:=false;
  u4PersonDupeScore:=0;
  bAddPerson:=false;
  bMergePerson:=false;
  bUseExistingPerson:=false;
  //bMultiplePersonDupesFound:=false;
  bHAvePerson:=true;
  

  //cnAction_DiagnosticHtmlDump
  bOk:=p_Context.bSessionValid;
  //p_Context.saPage+='Session Valid: '+saYesNo(bOk)+'<br />';
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204091553, 'Session not valid. Unable to perform this action.','',SOURCEFILE);
    RenderHTMLErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('Lead');
    //p_Context.saPage+='Found DataIn "LEAD" Parameter: '+saYesNo(bOk)+'<br />';
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204091553, 'Missing required parameter.','',SOURCEFILE);
      RenderHTMLErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    clear_JLead(rJLead);
    rJLead.JLead_JLead_UID:=p_Context.CGIENV.DataIn.Item_saValue;
    bOk:=bJAS_Load_JLead(p_Context, DBC, rJLead, false);
    //p_Context.saPage+='Lead Loaded: '+saYesNo(bOk)+'<br />';
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204091554, 'Unable to load specified lead.','',SOURCEFILE);
      RenderHTMLErrorPage(p_Context);
    end;
  end;

  // BEGIN ================================COMPANY DISCOVERY================================
  if bOk then
  begin
    if u8Val(rJLead.JLead_Exist_JCompany_ID)>0 then
    begin
      rJCompany.JComp_JCompany_UID:=rJLead.JLead_Exist_JCompany_ID;
      bOk:=bJAS_Load_JCompany(p_Context, DBC, rJCompany, false);
      //p_Context.saPage+='Existing Company Associated with Load Loaded: '+saYesNo(bOk)+'<br />';
      if (not bOk) then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201204091555, 'Unable to load company selected in lead record: '+rJLead.JLead_Exist_JCompany_ID,'',SOURCEFILE);
        RenderHTMLErrorPage(p_Context);
      end
      else
      begin
        bUseExistingCompany:=true;
      end;
    end;
    //else
    //begin
    //  p_Context.saPage+='No EXISTING Company Associated with lead.<br />';
    //end;
  end;


  if not bUseExistingCompany then
  begin
    if bOk and (u8Val(rJCompany.JComp_JCompany_UID)=0) and
    (NOT (trim(rJLead.JLead_CompanyName)='') or (upcase(trim(rJLead.JLead_CompanyName))='NULL')) and
    (0<DBC.u8GetRowCount('jcompany','((JComp_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JComp_Deleted_b IS NULL)) ',201506171712)) then
    //' AND JComp_Name LIKE '+DBC.saDBMSScrub('%'+trim(rJLead.JLead_CompanyName)+'%'))) then
    begin
      //p_Context.saPage+='Loading LeadXDL with Company Field Names and Lead Values<br />';
      LeadXDL.DeleteAll;
      LeadXDL.AppendItem_saName_N_saValue('JComp_Name'            ,rJLead.JLead_CompanyName    );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Email'           ,rJLead.JLead_Work_Email     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Phone'           ,rJLead.JLead_Work_Phone     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Fax'             ,rJLead.JLead_Fax            );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Website'         ,rJLead.JLead_Website        );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Main_Addr1'      ,rJLead.JLead_Main_Addr1     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Main_Addr2'      ,rJLead.JLead_Main_Addr2     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Main_Addr3'      ,rJLead.JLead_Main_Addr3     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Main_City'       ,rJLead.JLead_Main_City      );
      LeadXDL.AppendItem_saName_N_saValue('JComp_State'           ,rJLead.JLead_Main_State     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Main_PostalCode' ,rJLead.JLead_Main_PostalCode);
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_Addr1'      ,rJLead.JLead_Ship_Addr1     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_Addr2'      ,rJLead.JLead_Ship_Addr2     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_Addr3'      ,rJLead.JLead_Ship_Addr3     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_City'       ,rJLead.JLead_Ship_City      );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_State'      ,rJLead.JLead_Ship_State     );
      LeadXDL.AppendItem_saName_N_saValue('JComp_Ship_PostalCode' ,rJLead.JLead_Ship_PostalCode);

      saQry:=
        'SELECT JComp_JCompany_UID ' + csCRLF +
        'FROM jcompany '+ csCRLF +
        'WHERE ((JComp_Deleted_b<>' + DBC.saDBMSBoolScrub(true)+')OR(JComp_Deleted_b IS NULL)) AND '+ csCRLF +
          '((JComp_Name='            + DBC.saDBMSScrub(rJLead.JLead_CompanyName)     +') AND (JComp_Name <> '''')            AND (JComp_Name IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Email='           + DBC.saDBMSScrub(rJLead.JLead_Work_Email)      +') AND (JComp_Email <> '''')           AND (JComp_Email IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Phone='           + DBC.saDBMSScrub(rJLead.JLead_Work_Phone)      +') AND (JComp_Phone <> '''')           AND (JComp_Phone IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Fax='             + DBC.saDBMSScrub(rJLead.JLead_Fax)             +') AND (JComp_Fax <> '''')             AND (JComp_Fax IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Website='         + DBC.saDBMSScrub(rJLead.JLead_Website)         +') AND (JComp_Website <> '''')         AND (JComp_Website IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_Addr1='      + DBC.saDBMSScrub(rJLead.JLead_Main_Addr1)      +') AND (JComp_Main_Addr1 <> '''')      AND (JComp_Main_Addr1 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_Addr2='      + DBC.saDBMSScrub(rJLead.JLead_Main_Addr2)      +') AND (JComp_Main_Addr2 <> '''')      AND (JComp_Main_Addr2 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_Addr3='      + DBC.saDBMSScrub(rJLead.JLead_Main_Addr3)      +') AND (JComp_Main_Addr3 <> '''')      AND (JComp_Main_Addr3 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_City='       + DBC.saDBMSScrub(rJLead.JLead_Main_City)       +') AND (JComp_Main_City <> '''')       AND (JComp_Main_City IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_State='      + DBC.saDBMSScrub(rJLead.JLead_Main_State)      +') AND (JComp_Main_State <> '''')      AND (JComp_Main_State IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Main_PostalCode=' + DBC.saDBMSScrub(rJLead.JLead_Main_PostalCode) +') AND (JComp_Main_PostalCode <> '''') AND (JComp_Main_PostalCode IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_Addr1='      + DBC.saDBMSScrub(rJLead.JLead_Ship_Addr1)      +') AND (JComp_Ship_Addr1 <> '''')      AND (JComp_Ship_Addr1 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_Addr2='      + DBC.saDBMSScrub(rJLead.JLead_Ship_Addr2)      +') AND (JComp_Ship_Addr2 <> '''')      AND (JComp_Ship_Addr2 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_Addr3='      + DBC.saDBMSScrub(rJLead.JLead_Ship_Addr3)      +') AND (JComp_Ship_Addr3 <> '''')      AND (JComp_Ship_Addr3 IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_City='       + DBC.saDBMSScrub(rJLead.JLead_Ship_City)       +') AND (JComp_Ship_City <> '''')       AND (JComp_Ship_City IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_State='      + DBC.saDBMSScrub(rJLead.JLead_Ship_State)      +') AND (JComp_Ship_State <> '''')      AND (JComp_Ship_State IS NOT NULL)) OR ' + csCRLF +
          '((JComp_Ship_PostalCode=' + DBC.saDBMSScrub(rJLead.JLead_Ship_PostalCode) +') AND (JComp_Ship_PostalCode <> '''') AND (JComp_Ship_PostalCode IS NOT NULL))' + csCRLF;
        

      bOk:=rs.Open(saQry,DBC,201503161203);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201212140455, 'Unable to load company record(s) using lead data as criteria.','',SOURCEFILE);
        RenderHTMLErrorPage(p_Context);
      end;

      if bOk then
      begin
        if rs.eol then
        begin
          bAddCompany:=true;
          //p_Context.saPage+='No Lead Values Match Existing Company, Have a new Company Name, merge not required, just add.<br />';
        end
        else
        begin
          repeat
            bCompanyDupeFound:=false;
            saCompUID:=rs.fields.Get_saValue('JComp_JCompany_UID');
            rJCompany.JComp_JCompany_UID:=saCompUID;
            bOk:=bJAS_Load_JCompany(p_Context, DBC, rJCompany, false);
            //p_Context.saPage+='Existing Company Associated with Load Loaded: '+saYesNo(bOk)+'<br />';
            if (not bOk) then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201212170511, 'Unable to load company selected in lead record: '+saCompUID,'',SOURCEFILE);
              RenderHTMLErrorPage(p_Context);
            end;

            if bOk then
            begin
              if upcase(trim(rJLead.JLead_CompanyName))=upcase(trim(rJCompany.JComp_Name)) then
              begin
                bCompanyDupeFound:=true;
                uCompanyDupeCount+=1;
                JCompanyXDL.AppendItem_saName_N_saValue(rJCompany.JComp_Name,rJCompany.JComp_JCompany_UID);
              end
              else
              begin
                bOk:=p_Context.bLoadXDLForMerge('jcompany',saCompUID,CompXDL,u4CompanyDupeScore);
                //p_Context.saPage+='Have potential, must prep for merge. dupeScore: '+inttostR(u4CompanyDupeScore)+' Loading CompXDL success: '+saYesNo(bOk)+'<br />';
                if not bOk then
                begin
                  JAS_LOG(p_Context, cnLog_Error, 201204091556, 'Trouble loading XDL for merge.','',SOURCEFILE);
                  RenderHTMLErrorPage(p_Context);
                end;

                if bOk then
                begin
                  Merge(False, u4CompanyDupeScore, false, bCompanyDupeFound, CompXDL, LeadXDL, ColXDL);
                  //p_Context.saPage+='Executed Company Merge. DupeScore: '+inttostR(u4CompanyDupeScore)+' CompanyDupeFound: '+saYesno(bCompanyDupeFound)+'<br />';
                end;

                if bOk then
                begin
                  if bCompanyDupeFound then
                  begin
                    uCompanyDupeCount+=1;
                    JCompanyXDL.AppendItem_saName_N_saValue(rJCompany.JComp_Name,rJCompany.JComp_JCompany_UID);
                  end;
                  //p_Context.saPage+='CompanyDupeCount: '+inttostr(uCompanyDupeCount)+'<br />';
                end;
              end;
            end;
          until (not bOk) or (not rs.movenext);
        end;
      end;
      rs.close;


{
      if bOk then
      begin
        bAddCompany:=(uCompanyDupeCount=0);
        //p_Context.saPage+='bAddCompany set TRUE if uDupeCount = 0. uDupeCount: '+inttostr(uCompanyDupeCount)+'<br />';
        if (not bAddCompany) and (uCompanyDupeCount=1) then
        begin
          bOk:=rs.Open(saQry,DBC,201503161204);
          //p_Context.saPage+='Query run again, bAddCompany=false, DupeCount=1 Qry Success: '+saYesNo(bOk)+'<br />';
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201204091558, 'Pass 2 Unable to load company selected in lead record.','',SOURCEFILE);
            RenderHTMLErrorPage(p_Context);
          end;

          if bOk then
          begin
            if rs.eol then
            begin
              bAddCompany:=true;
              //p_Context.saPage+='Qry no results - so Add Company<br />';
            end
            else
            begin
              //p_Context.saPage+='Potential company dupe found - do merge logic for each returned row<br />';
              repeat
                saCompUID:=rs.fields.Get_saValue('JComp_JCompany_UID');
                bOk:=p_Context.bLoadXDLForMerge('jcompany',saCompUID,CompXDL,u4CompanyDupeScore);
                //p_Context.saPage+='LoadXDLForMerge in CompXDL called. u4DupeScore: '+inttostr(u4CompanyDupeScore)+' Success: '+saYesNo(bOk)+'<br />';
                if not bOk then
                begin
                  JAS_LOG(p_Context, cnLog_Error, 201204091559, 'Pass 2 Trouble loading XDL for merge.','',SOURCEFILE);
                  RenderHTMLErrorPage(p_Context);
                end;

                if bOk then
                begin
                  Merge(true, u4CompanyDupeScore, false, bCompanyDupeFound, CompXDL, LeadXDL, ColXDL);
                  if bCompanyDupeFound then JCompanyXDL.AppendItem_saName(saCompUID);
                  //p_Context.saPage+='Merge called CompXDL, LeadXDL, ColXDL. CompanyDupeScore: '+inttostr(u4CompanyDupeScore)+' bCompanyDupeFound: '+saYesNo(bCompanyDupeFound)+'<br />';
                end;
              until (not bOk) or (not rs.movenext);

              if bCompanyDupeFound then // should be
              begin
                bMergeCompany:=true;
                //p_Context.saPage+='Because company dupe found, flag set to merge company.<br />';
              end;
            end;
          end;
          rs.close;
        end
        else
        begin
          bMultipleCompanydupesfound:=true;
        end;
      end;
}      
    end
    else
    begin
      bHaveCompany:=False;
    end;
  end;
  // END ================================COMPANY DISCOVERY================================



















  // BEGIN ================================PERSON DISCOVERY================================
  if bOk then
  begin
    uPersonDupecount:=0;
    if u8Val(rJLead.JLead_Exist_JPerson_ID)>0 then
    begin
      rJPerson.JPers_JPerson_UID:=rJLead.JLead_Exist_JPerson_ID;
      bOk:=bJAS_Load_JPerson(p_Context, DBC, rJPerson, false);
      p_Context.saPage+='Existing Person Associated with Load Loaded: '+saYesNo(bOk)+'<br />';
      if (not bOk) then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201212140441, 'Unable to load person selected in lead record.','',SOURCEFILE);
        RenderHTMLErrorPage(p_Context);
      end
      else
      begin
        bUseExistingPerson:=true;
      end;
    end;
    //else
    //begin
    //  p_Context.saPage+='No EXISTING Person Associated with lead.<br />';
    //end;
  end;


  if not bUseExistingPerson then
  begin
    // Make sure we have SOME Data to work with
    if bOk and (u8Val(rJPerson.JPers_JPerson_UID)=0) and 
    ((trim(rJLead.JLead_NameSalutation)<>'')    and (upcase(trim(rJLead.JLead_NameSalutation))='NULL')) or
    ((trim(rJLead.JLead_NameFirst)<>'')         and  (upcase(trim(rJLead.JLead_NameFirst))='NULL')) or
    ((trim(rJLead.JLead_NameMiddle)<>'')        and  (upcase(trim(rJLead.JLead_NameMiddle))='NULL')) or
    ((trim(rJLead.JLead_NameLast)<>'')          and  (upcase(trim(rJLead.JLead_NameLast))='NULL')) or
    ((trim(rJLead.JLead_NameSuffix)<>'')        and  (upcase(trim(rJLead.JLead_NameSuffix))='NULL')) or
    ((trim(rJLead.JLead_Desc)<>'')              and  (upcase(trim(rJLead.JLead_Desc))='NULL')) or
    ((trim(rJLead.JLead_Gender)<>'')            and  (upcase(trim(rJLead.JLead_Gender))='NULL')) or
    ((trim(rJLead.JLead_Home_Phone)<>'')        and  (upcase(trim(rJLead.JLead_Home_Phone))='NULL')) or
    ((trim(rJLead.JLead_Mobile_Phone)<>'')      and  (upcase(trim(rJLead.JLead_Mobile_Phone))='NULL')) or
    ((trim(rJLead.JLead_Work_Email)<>'')        and  (upcase(trim(rJLead.JLead_Work_Email))='NULL')) or
    ((trim(rJLead.JLead_Work_Phone)<>'')        and  (upcase(trim(rJLead.JLead_Work_Phone))='NULL')) or
    ((trim(rJLead.JLead_Fax)<>'')               and  (upcase(trim(rJLead.JLead_Fax))='NULL')) or
    ((trim(rJLead.JLead_Home_Email)<>'')        and (upcase(trim(rJLead.JLead_Home_Email))='NULL')) or
    ((trim(rJLead.JLead_Website)<>'')           and  (upcase(trim(rJLead.JLead_Website))='NULL')) or
    ((trim(rJLead.JLead_Main_Addr1)<>'')        and  (upcase(trim(rJLead.JLead_Main_Addr1))='NULL')) or
    ((trim(rJLead.JLead_Main_Addr2)<>'')        and  (upcase(trim(rJLead.JLead_Main_Addr2))='NULL')) or
    ((trim(rJLead.JLead_Main_Addr3)<>'')        and  (upcase(trim(rJLead.JLead_Main_Addr3))='NULL')) or
    ((trim(rJLead.JLead_Main_City)<>'')         and  (upcase(trim(rJLead.JLead_Main_City))='NULL')) or
    ((trim(rJLead.JLead_Main_State)<>'')        and  (upcase(trim(rJLead.JLead_Main_State))='NULL')) or
    ((trim(rJLead.JLead_Main_PostalCode)<>'')   and  (upcase(trim(rJLead.JLead_Main_PostalCode))='NULL')) or
    ((trim(rJLead.JLead_Main_Country)<>'')      and  (upcase(trim(rJLead.JLead_Main_Country))='NULL')) or
    ((trim(rJLead.JLead_Ship_Addr1)<>'')        and  (upcase(trim(rJLead.JLead_Ship_Addr1))='NULL')) or
    ((trim(rJLead.JLead_Ship_Addr2)<>'')        and  (upcase(trim(rJLead.JLead_Ship_Addr2))='NULL')) or
    ((trim(rJLead.JLead_Ship_Addr3)<>'')        and  (upcase(trim(rJLead.JLead_Ship_Addr3))='NULL')) or
    ((trim(rJLead.JLead_Ship_City)<>'')         and  (upcase(trim(rJLead.JLead_Ship_City))='NULL')) or
    ((trim(rJLead.JLead_Ship_State)<>'')        and  (upcase(trim(rJLead.JLead_Ship_State))='NULL')) or
    ((trim(rJLead.JLead_Ship_PostalCode)<>'')   and  (upcase(trim(rJLead.JLead_Ship_PostalCode))='NULL')) or
    ((trim(rJLead.JLead_Ship_Country)<>'')      and  (upcase(trim(rJLead.JLead_Ship_Country))='NULL')) or
    ((trim(rJLead.JLead_Exist_JCompany_ID)<>'') and  (upcase(trim(rJLead.JLead_Exist_JCompany_ID))='NULL')) or
    ((trim(rJLead.JLead_Exist_JPerson_ID)<>'')  and  (upcase(trim(rJLead.JLead_Exist_JPerson_ID))='NULL')) or
    ((trim(rJLead.JLead_LeadSourceAddl)<>'')    and  (upcase(trim(rJLead.JLead_LeadSourceAddl))='NULL')) then
    begin
      //p_Context.saPage+='Loading LeadXDL with JPerson Field Names and Lead Values<br />';
      LeadXDL.DeleteAll;
      LeadXDL.AppendItem_saName_N_saValue('JPers_Desc'                  , rJLead.JLead_Desc);
      LeadXDL.AppendItem_saName_N_saValue('JPers_NameSalutation'        , rJLead.JLead_NameSalutation);
      LeadXDL.AppendItem_saName_N_saValue('JPers_NameFirst'             , rJLead.JLead_NameFirst);
      LeadXDL.AppendItem_saName_N_saValue('JPers_NameMiddle'            , rJLead.JLead_NameMiddle);
      LeadXDL.AppendItem_saName_N_saValue('JPers_NameLast'              , rJLead.JLead_NameLast);
      LeadXDL.AppendItem_saName_N_saValue('JPers_NameSuffix'            , rJLead.JLead_NameSuffix);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Gender'                , rJLead.JLead_Gender);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Private_b'             , rJLead.JLead_Private_b);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Addr1'                 , rJLead.JLead_Main_Addr1);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Addr2'                 , rJLead.JLead_Main_Addr2);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Addr3'                 , rJLead.JLead_Main_Addr3);
      LeadXDL.AppendItem_saName_N_saValue('JPers_City'                  , rJLead.JLead_Main_City);
      LeadXDL.AppendItem_saName_N_saValue('JPers_State'                 , rJLead.JLead_Main_State);
      LeadXDL.AppendItem_saName_N_saValue('JPers_PostalCode'            , rJLead.JLead_Main_PostalCode);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Country'               , rJLead.JLead_Main_Country);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Home_Email'            , rJLead.JLead_Home_Email);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Home_Phone'            , rJLead.JLead_Home_Phone);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Mobile_Phone'          , rJLead.JLead_Mobile_Phone);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Work_Email'            , rJLead.JLead_Work_Email);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Work_Phone'             , rJLead.JLead_Work_Phone);
      LeadXDL.AppendItem_saName_N_saValue('JPers_Primary_Company_ID'    , rJLead.JLead_Exist_JCompany_ID);

      saQry:=
        'SELECT JPers_JPerson_UID, JPers_NameFirst, JPers_NameLast '+
        'FROM jperson '+
        'WHERE ((JPers_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JPers_Deleted_b IS NULL)) AND '+
          '((JPers_Desc='               + DBC.saDBMSScrub(rJLead.JLead_Desc)               +') AND (JPers_Desc <> '''')               AND (JPers_Desc IS NOT NULL)) OR ' + csCRLF +
          '((JPers_NameSalutation='     + DBC.saDBMSScrub(rJLead.JLead_NameSalutation)     +') AND (JPers_NameSalutation <> '''')     AND (JPers_NameSalutation IS NOT NULL)) OR ' + csCRLF +
          '((JPers_NameFirst='          + DBC.saDBMSScrub(rJLead.JLead_NameFirst)          +') AND (JPers_NameFirst <> '''')          AND (JPers_NameFirst IS NOT NULL)) OR ' + csCRLF +
          '((JPers_NameMiddle='         + DBC.saDBMSScrub(rJLead.JLead_NameMiddle)         +') AND (JPers_NameMiddle <> '''')         AND (JPers_NameMiddle IS NOT NULL)) OR ' + csCRLF +
          '((JPers_NameLast='           + DBC.saDBMSScrub(rJLead.JLead_NameLast)           +') AND (JPers_NameLast <> '''')           AND (JPers_NameLast IS NOT NULL)) OR ' + csCRLF +
          '((JPers_NameSuffix='         + DBC.saDBMSScrub(rJLead.JLead_NameSuffix)         +') AND (JPers_NameSuffix <> '''')         AND (JPers_NameSuffix IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Gender='             + DBC.saDBMSScrub(rJLead.JLead_Gender)             +') AND (JPers_Gender <> '''')             AND (JPers_Gender IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Private_b='          + DBC.saDBMSScrub(rJLead.JLead_Private_b)          +') AND (JPers_Private_b <> '''')          AND (JPers_Private_b IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Addr1='              + DBC.saDBMSScrub(rJLead.JLead_Main_Addr1)         +') AND (JPers_Addr1 <> '''')              AND (JPers_Addr1 IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Addr2='              + DBC.saDBMSScrub(rJLead.JLead_Main_Addr2)         +') AND (JPers_Addr2 <> '''')              AND (JPers_Addr2 IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Addr3='              + DBC.saDBMSScrub(rJLead.JLead_Main_Addr3)         +') AND (JPers_Addr3 <> '''')              AND (JPers_Addr3 IS NOT NULL)) OR ' + csCRLF +
          '((JPers_City='               + DBC.saDBMSScrub(rJLead.JLead_Main_City)          +') AND (JPers_City <> '''')               AND (JPers_City IS NOT NULL)) OR ' + csCRLF +
          '((JPers_State='              + DBC.saDBMSScrub(rJLead.JLead_Main_State)         +') AND (JPers_State <> '''')              AND (JPers_State IS NOT NULL)) OR ' + csCRLF +
          '((JPers_PostalCode='         + DBC.saDBMSScrub(rJLead.JLead_Main_PostalCode)    +') AND (JPers_PostalCode <> '''')         AND (JPers_PostalCode IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Country='            + DBC.saDBMSScrub(rJLead.JLead_Main_Country)       +') AND (JPers_Country <> '''')            AND (JPers_Country IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Home_Email='         + DBC.saDBMSScrub(rJLead.JLead_Home_Email)         +') AND (JPers_Home_Email <> '''')         AND (JPers_Home_Email IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Home_Phone='         + DBC.saDBMSScrub(rJLead.JLead_Home_Phone)         +') AND (JPers_Home_Phone <> '''')         AND (JPers_Home_Phone  IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Mobile_Phone='       + DBC.saDBMSScrub(rJLead.JLead_Mobile_Phone)       +') AND (JPers_Mobile_Phone <> '''')       AND (JPers_Mobile_Phone  IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Work_Email='         + DBC.saDBMSScrub(rJLead.JLead_Work_Email)         +') AND (JPers_Work_Email <> '''')         AND (JPers_Work_Email IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Work_Phone='         + DBC.saDBMSScrub(rJLead.JLead_Work_Phone)         +') AND (JPers_Work_Phone <> '''')         AND (JPers_Work_Phone IS NOT NULL)) OR ' + csCRLF +
          '((JPers_Primary_Company_ID=' + DBC.saDBMSScrub(rJLead.JLead_Exist_JCompany_ID)  +') AND (JPers_Primary_Company_ID <> '''') AND (JPers_Primary_Company_ID  IS NOT NULL))' + csCRLF;

      bOk:=rs.Open(saQry,DBC,201503161205);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201212140442, 'Unable to load person record(s) using lead data as criteria.','',SOURCEFILE);
        RenderHTMLErrorPage(p_Context);
      end;

      if bOk then
      begin
        if rs.eol then
        begin
          bAddPerson:=true;
          //p_Context.saPage+='No Lead Values Match Existing Person, Have a new Person Name, merge not required, just add.<br />';
        end
        else
        begin
          repeat
            bPersonDupeFound:=false;
            saPersUID:=rs.fields.Get_saValue('JPers_JPerson_UID');
            bOk:=p_Context.bLoadXDLForMerge('jperson',saPersUID,PersXDL,u4PersonDupeScore);
            //p_Context.saPage+='Have potential, must prep for merge. dupeScore: '+inttostR(u4PersonDupeScore)+' Loading PersXDL success: '+saYesNo(bOk)+'<br />';
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201212140443, 'Trouble loading XDL for merge.','',SOURCEFILE);
              RenderHTMLErrorPage(p_Context);
            end;

            if bOk then
            begin
              Merge(False, u4PersonDupeScore, false, bPersonDupeFound, PersXDL, LeadXDL, ColXDL);
              //p_Context.saPage+='Executed JPerson Merge. DupeScore: '+inttostR(u4PersonDupeScore)+' PersonDupeFound: '+saYesno(bPersonDupeFound)+'<br />';
            end;

            if bOk then
            begin
              if bPersonDupeFound then
              begin
                // TODO: Load Person REcord into Array for later processing
                JPersonXDL.AppendItem_saName_N_saValue(rs.fields.Get_saValue('JPers_NameFirst')+' '+rs.fields.Get_saValue('JPers_NameLast'),saPersUID);
                JPersonXDL.Item_saDesc:=inttostr(u4PersonDupeScore);
                uPersonDupeCount+=1;
              end;
              //p_Context.saPage+='PersonDupeCount: '+inttostr(uPersonDupeCount)+'<br />';
            end;
          until (not bOk) or (not rs.movenext);
        end;
      end;
      rs.close;


{
      if bOk then
      begin
        bAddPerson:=(uPersonDupeCount=0);
        //p_Context.saPage+='bAddPerson set TRUE if uDupeCount = 0. uDupeCount: '+inttostr(uPersonDupeCount)+'<br />';
        if (not bAddPerson) and (uPersonDupeCount=1) then
        begin
          bOk:=rs.Open(saQry,DBC,201503161206);
          //p_Context.saPage+='Query run again, bAddPerson=false, DupeCount=1 Qry Success: '+saYesNo(bOk)+'<br />';
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201212140444, 'Pass 2 Unable to load person selected in lead record.','',SOURCEFILE);
            RenderHTMLErrorPage(p_Context);
          end;

          if bOk then
          begin
            if rs.eol then
            begin
              bAddCompany:=true;
              //p_Context.saPage+='Qry no results - so Add Person<br />';
            end
            else
            begin
              //p_Context.saPage+='Potential person dupe found - do merge logic for each returned row<br />';
              bPersonDupeFound:=false;
              repeat
                if not bPersonDupeFound then
                begin
                  bOk:=p_Context.bLoadXDLForMerge('jperson',rs.fields.Get_saValue('JPers_JPerson_UID'),PersXDL,u4PersonDupeScore);
                  //p_Context.saPage+='LoadXDLForMerge in PersXDL called. u4PersonDupeScore: '+inttostr(u4PersonDupeScore)+' Success: '+saYesNo(bOk)+'<br />';
                  if not bOk then
                  begin
                    JAS_LOG(p_Context, cnLog_Error, 201212140445, 'Pass 2 Trouble loading XDL for merge.','',SOURCEFILE);
                    RenderHTMLErrorPage(p_Context);
                  end;

                  if bOk then
                  begin
                    Merge(true, u4PersonDupeScore, false, bPersonDupeFound, PersXDL, LeadXDL, ColXDL);
                    //p_Context.saPage+='Merge called PersXDL, LeadXDL, ColXDL. PersonDupeScore: '+inttostr(u4PersonDupeScore)+' bPersonDupeFound: '+saYesNo(bPersonDupeFound)+'<br />';
                  end;
                end;
              until (not bOk) or (not rs.movenext);

              if bPersonDupeFound then // should be
              begin
                bMergePerson:=true;
                //p_Context.saPage+='Because person dupe found, flag set to merge person.<br />';
              end;
            end;
          end;
          rs.close;
        end
        else
        begin
          bMultiplePersonDupesfound:=true;
        end;
      end;
}
    end
    else
    begin
      bHAvePerson:=false;
    end;
  end;
  // END ================================PERSON DISCOVERY================================





















  //================================COMPANY ACTIONS==================================
  // At This Point:

  // bMultipleCompanydupesfound = TRUE - Provide User ability to select which
  // company to use and add to lead Existing company record and run routine again

  // bAddCompany = Use Lead Info To Create Company Record, No Merge Necessary

  // bUseExistingCompany = rJCompany loaded with UID of Company to use (No data in - just UID
  // to make a member record if there is Person Data we can use together for the required "Pair"
  // MergeFirst

  // bMergeCompany = LeadXDL Has the VALUEs that need to be SAVED into Company before
  // removing the lead we are promoting.

  // DON'T FORGET Company and Person Link to each Other - Persons' Primary company
  // and companies primary person if empty
  //================================COMPANY ACTIONS==================================




  //================================PERSON ACTIONS==================================
  // At This Point:

  // bMultiplePersonDupesfound = TRUE - Provide User ability to select which
  // Person to use and add to lead Existing person record and run routine again

  // bAddPerson = Use Lead Info To Create Person Record, No Merge Necessary

  // bUseExistingPerson = rJPerson loaded with UID of Person to use (No data in - just UID
  // to make a member record if there is Company Data we can use together for the required "Pair"
  // MergeFirst

  // bMergePerson = LeadXDL Has the VALUEs that need to be SAVED into Person before
  // removing the lead we are promoting.

  // DON'T FORGET Company and Person Link to each Other - Persons' Primary company
  // and Companies primary person if empty
  //================================PERSON ACTIONS==================================





  p_Context.saPage+='<p>Have Company at all: '+saYesNo(bHaveCompany); 
  p_Context.saPage+='<p>Company uDupeCount: '+inttostr(uCompanyDupeCount)+'</p>';
  if JCompanyXDL.movefirst then
  begin
    p_Context.saPage+='<ul>';
    repeat
      p_Context.saPage+='<li>'+JCompanyXDL.Item_saName+' '+JCompanyXDL.Item_saValue+'</li>';
    until not JCompanyXDL.MoveNext;
    p_Context.saPage+='</ul>';
  end;
  p_Context.saPage+='<p>Company bAddCompany: '+saYesNo(bAddCompany)+'</p>';
  p_Context.saPage+='<p>Company bUseExistingCompany: '+saYesNo(bUseExistingCompany)+'</p>';
  p_Context.saPage+='<p>Company bMergeCompany: '+saYesNo(bMergeCompany)+'</p>';
  if bMergeCompany then
  begin
    p_Context.saPage+=CompXDL.saHTMLTable;
  end;
  p_Context.saPage+='<br /><br /><br />';

  p_Context.saPage+='<p>Have Person at all: '+saYesNo(bHavePerson);
  p_Context.saPage+='<p>Person uPersonDupeCount: '+inttostr(uPersonDupeCount)+'</p>';
  if JPersonXDL.movefirst then
  begin
    p_Context.saPage+='<ul>';
    repeat
      p_Context.saPage+='<li>'+JPersonXDL.Item_saName+' '+JPersonXDL.Item_saValue+' Dupe Score: '+JPersonXDL.Item_saDesc+'</li>';
    until not JPersonXDL.MoveNext;
    p_Context.saPage+='</ul>';
  end;
  p_Context.saPage+='<p>Person bAddPerson: '+saYesNo(bAddPerson)+'</p>';
  p_Context.saPage+='<p>Person bUseExistingPerson: '+saYesNo(bUseExistingPerson)+'</p>';
  p_Context.saPage+='<p>Person bMergePerson: '+saYesNo(bMergePerson)+'</p>';
  if bMergePerson then
  begin
    p_Context.saPage+=PersXDL.saHTMLTable;
  end;


  rs.destroy;
  LeadXDL.Destroy;
  CompXDL.Destroy;
  PersXDL.Destroy;
  ColXDL.Destroy;
  JCompanyXDL.Destroy;
  JPersonXDL.Destroy;

  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204091552,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















//=============================================================================
{}
procedure JAS_CopySecurityGroup(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;

  rJSecGrp: rtJSecGrp;
  rJSecGrpCopy: rtJSecGrp;
  rJSecGrpLink: rtJSecGrpLink;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_CopySecurityGroup(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205020717,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205020718, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201205020721,'Invalid Session. You are not logged in.','',SOURCEFILE);
  End;

  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_CopySecurityGroups);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_DEBUG,201012231201,'You are not authorized to copy a security group. You need the "Copy Security Group" permission.','',SOURCEFILE);
    End;
  End;

  if bOk then
  begin
    clear_JSecGrp(rJSecGrp);
    rJSecGrp.JSGrp_JSecGrp_UID:=p_Context.CGIENV.DataIn.Get_saValue('JSGrp_JSecGrp_UID');
    bOk:=bJAS_Load_JSecGrp(p_Context, DBC, rJSecGrp, false);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201205020727, 'Unable to load Source Security Group','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    clear_JSecGrp(rJSecGrpCopy);
    rJSecGrpCopy.JSGrp_Name:=p_Context.CGIENV.DataIn.Get_saValue('DestSecGrp');
    saQry:='JSGrp_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND UCASE(JSGrp_Name)='+uppercase(rJSecGrpCopy.JSGrp_Name);
    bOk:= 0 = DBC.u8GetRowCount('jsecgrp',saQry,201506171713);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201205020730, 'Security Group '+ rJSecGrpCopy.JSGrp_Name + ' already exists. Duplicates are not allowed.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    rJSecGrpCopy.JSGrp_Desc:='Copy of '+rJSecGrp.JSGrp_Name;
    bOk:=bJAS_Save_JSecGrp(p_Context, DBC, rJSecGrpCopy, false, false);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201205020731, 'Trouble saving '+ rJSecGrpCopy.JSGrp_Name,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saQry:='select JSGLk_JSecPerm_ID from jsecgrplink where JSGLk_Deleted_b<>'+DBC.saDBMSBoolScrub(true) + ' AND '+
      'JSGLk_JSecGrp_ID='+DBC.saDBMSUIntScrub(rJSecGrp.JSGrp_JSecGrp_UID);
    bOk:=rs.open(saQry, DBC,201503161207);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201205020732, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      clear_JSecGrpLink(rJSecGrpLink);
      rJSecGrpLink.JSGLk_JSecPerm_ID         :=rs.fields.Get_saValue('JSGLk_JSecPerm_ID');
      rJSecGrpLink.JSGLk_JSecGrp_ID          :=rJSecGrpCopy.JSGrp_JSecGrp_UID;
      bOk:=bJAS_Save_JSecGrpLink(p_Context, DBC, rJSecGrpLink, false, false);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205020803, 'Trouble saving Security Group Link while copying security group '+rJSecGrp.JSGrp_Name+' to '+rJSecGrpCopy.JSGrp_Name,'',SOURCEFILE);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  if bOk then
  begin
    p_Context.CGIENV.iHTTPResponse:=200;
    p_Context.XML.AppendItem_saName_N_saDesc('result','true');
    p_Context.CreateIWFXML;
    p_Context.iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

  end;
  rs.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205020720,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
Procedure JAS_verifyemail(p_Context:TCONTEXT);
//=============================================================================
Var
  bOk: Boolean;
  rJUser: rtJUser;
  DBC: JADO_CONNECTION;
  sa: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_verifyemail(p_Context:TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201208181930,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201208181931, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  clear_JUser(rJUser);
  rJUser.JUser_JUser_UID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('UID'));
  bOk:=bJAS_Load_JUser(p_Context, DBC, rJUser, true);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error, 201208181932, 'Unable to lock and load user record.','UID: '+inttostr(rJUser.JUser_JUser_UID),SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=rJUser.JUser_DefaultPage_Login='newuser';
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error, 201208181933, 'JUser_DefaultPage_Login field not set appropriately.','UID: '+inttostR(rJUser.JUser_JUser_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=not rJUser.JUser_Enabled_b;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error, 201208181934, 'Unable to enable user.','(User already enabled) UID: '+inttostR(rJUser.JUser_JUser_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    rJUser.JUser_DefaultPage_Login:='';
    rJUser.JUser_Enabled_b:=true;
    bOk:=bJAS_Save_JUser(p_Context, DBC, rJUser, true,true);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error, 201208181935, 'Unable to save user record.','UID: '+inttostr(rJUser.JUser_JUser_UID),SOURCEFILE);
    end;
  end;
  bJAS_UnlockRecord(p_Context,DBC.ID,'juser',inttostr(rJUser.JUser_JUser_UID),'0',201501011038);

  //p_Context.XML.AppendItem_saName_N_saValue('verifyemail',saTrueFalse(bOk));
  //p_Context.CGIENV.iHTTPResponse:=200;
  //p_Context.iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  if bOk then
  begin
    bOk:=bJASNote(p_Context,'2012081822111214213',sa,'Account Verified.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false, 201208182211);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/apps/graphics-image-viewer.png');
    p_Context.saPageTitle:='Account verified!';
  end
  else
  begin
    p_Context.bErrorCondition:=false;
    bOk:=bJASNote(p_Context,'2012081822163934012',sa,'Unable to verify account.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false, 201203122216);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/apps/graphics-image-viewer.png');
    p_Context.saPageTitle:='Unable to verify account.';
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201208181940,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================











//=============================================================================
Procedure JAS_ResetPassword(p_Context: TCONTEXT);
//=============================================================================
Var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  sa: ansistring;
  rJPerson: rtJPerson;
  rJUser: rtJUser;
  bEmail: boolean;
  bHaveJUserLock: boolean;
  bHaveJPersonLock: Boolean;
  u8UserCount: UInt64;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='JAS_ResetPassword';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201209131242,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201209131243, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  bOk:=true;bEmail:=false;
  clear_JUser(rJUser);
  clear_JPerson(rJPerson);

  if p_Context.CGIENV.DataIn.FoundItem_saName('JPers_Work_Email') or
     p_Context.CGIENV.DataIn.FoundItem_saName('JUser_Name') then
  begin
    //ASPrintln('User Submitted Email and/or Username');
    rJPerson.JPers_Work_Email:=p_Context.CGIENV.DataIn.Get_saValue('JPers_Work_Email');
    rJUser.JUser_Name:=p_Context.CGIENV.DataIn.Get_saValue('JUser_Name');
    if bOk then
    begin
      //ASPrintln('Testing if Email Valid');
      bOk:=bGoodEmail(rJPerson.JPers_Work_Email);bEmail:=bOk;
      if not bOk then
      begin
        //ASPrintln('Nope, Testing if Username Valid');
        bOk:=bGoodUserName(rJUser.JUser_Name);
        if not bOk then
        begin
          //ASPrintln('NOPE - Username and Email weren''t even worth looking up in DB');
          JAS_Log(p_Context,cnLog_Error,201203242136,'Invalid Email and/or Username entered.',
            'JPers_Work_Email: '+rJPerson.JPers_Work_Email+' JUser_Name: '+rJUser.JUser_Name,SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;
      end;
    end;

    if bOk then
    begin
      if bEmail then
      begin
        //ASPrintln('Have Email Worth Looking Up - Counting People with that email - Want 1');
        u8UserCount:=DBC.u8GetRowCount('jperson','((JPers_Deleted_b<>'+
          DBC.saDBMSBoolScrub(true)+')OR(JPers_Deleted_b IS NULL)) AND '+
          'JPers_Work_Email='+DBC.saDBMSScrub(rJPerson.JPers_Work_Email),201506171714);
        bOk:=u8UserCount=1;
        if not bOk then
        begin
          if u8UserCount=0 then
          begin
            //ASPrintln('UTOH - Nobody has that Email');
            JAS_Log(p_Context,cnLog_Error,201203242135,'Sorry, Email not found.',
              'JPers_Work_Email: '+rJPerson.JPers_Work_Email+' JUser_Name: '+rJUser.JUser_Name,SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end
          else
          begin
            //ASPrintln('UTOH - Multiple people have that Email');
            JAS_Log(p_Context,cnLog_Error,201210222013,'Sorry, duplicate emails exist in database. Unable to assist further.',
              'JPers_Work_Email: '+rJPerson.JPers_Work_Email+' JUser_Name: '+rJUser.JUser_Name,SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;
        end;

        if bOk then
        begin
          //ASPrintln('Email Good, 1 Person with it, Grabbing Person UID');
          rJPerson.JPers_JPerson_UID:=DBC.saGetValue('jperson','JPers_JPerson_UID',
            '((JPers_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JPers_Deleted_b IS NULL)) AND '+
            '(JPers_Work_Email='+DBC.saDBMSScrub(rJPerson.JPers_Work_Email)+')');

          //ASPrintln('Grabbing User UID that has the Person UID we just grabbed');
          rJUser.JUser_JUser_UID:=u8Val(DBC.saGetValue('juser','JUser_JUser_UID','((JUser_Deleted_b<>'+
            DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
            'JUser_JPerson_ID='+DBC.saDBMSScrub(rJPerson.JPers_JPerson_UID)));
        end;
      end
      else
      begin
        //ASPrintln('No Email - Got Username - Checking we HAVE ONE valid record Only');
        u8UserCount:=DBC.u8GetRowCount('juser','((JUser_Deleted_b<>'+
          DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
          'JUser_Name='+DBC.saDBMSScrub(rJUser.JUser_Name),201506171715);
        bOk:=u8UserCount=1;
        if not bOk then
        begin
          //ASPrintln('Have ZERO or Multiple Users with that name - BAD - Epic Fail');
          if u8UserCount>1 then
          begin
            JAS_Log(p_Context,cnLog_Error,201203242138,'Duplicate user found.',
              'JUser_Name: '+rJUser.JUser_Name+' UID:'+inttostr(rJUser.JUser_JUser_UID),SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end
          else
          begin
            JAS_Log(p_Context,cnLog_Error,201210221703,'User not found.',
              'JUser_Name: '+rJUser.JUser_Name+' UID:'+inttostr(rJUser.JUser_JUser_UID),SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;
        end;

        if bOk then
        begin
          //ASPrintln('Grabbing User UID for passed username');
          rJUser.JUser_JUser_UID:=u8Val(DBC.saGetValue('juser','JUser_JUser_UID','((JUser_Deleted_b<>'+
            DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
            'JUser_Name='+DBC.saDBMSScrub(rJUser.JUser_Name)));
        end;
      end;
    end;

    if bOk then
    begin
      //ASPrintln('Have USER UID: '+rJUser.JUser_JUser_UID + ' Formal Loading of Record');
      bOk:=bJAS_Load_JUser(p_Context,DBC,rJUser,true);
      bHaveJUserLock:=bOk;
      if not bOk then
      begin
        //ASPrintln('Unable to load user record');
        JAS_Log(p_Context,cnLog_Error,201203242139,'Unable to load user record.',
          'JUser_Name: '+rJUser.JUser_Name+' UID:'+inttostR(rJUser.JUser_JUser_UID),SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      //ASPrintln('Have Person UID: '+inttostr(rJUser.JUser_JPerson_ID) + ' Formal Loading of Record');
      rJPerson.JPers_JPerson_UID:=inttostr(rJUser.JUser_JPerson_ID);
      bOk:=bJAS_Load_JPerson(p_Context,DBC,rJPerson,true);
      bHaveJPersonLock:=bOk;
      if not bOk then
      begin
        //ASPrintln('Unable to load person record');
        JAS_Log(p_Context,cnLog_Error,201203242140,'Unable to load person record.',
          'JUser_Name: '+rJUser.JUser_Name+' User UID:'+Inttostr(rJUser.JUser_JUser_UID)+
          ' Person UID: '+IntToStr(rJUser.JUser_JPerson_ID),SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      //ASPrintln('Making sure only one user associated with our Person ID');
      bOk:=DBC.u8GetRowCount('juser','((JUser_Deleted_b<>'+
        DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
        'JUser_JPerson_ID='+DBC.saDBMSScrub(rJPerson.JPers_JPerson_UID),201506171716)=1;
      if not bOk then
      begin
        //ASPrintln('Multiple Users Associated with this Person - OH the Shame');
        JAS_Log(p_Context,cnLog_Error,201203242137,'Multiple users share email - Ambiguity.',
          'JPers_Work_Email: '+rJPerson.JPers_Work_Email+' JUser_Name: '+rJUser.JUser_Name,SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      rJUser.JUser_ResetPass_u:=u8Val(saJAS_GetNextUID);
      //ASPrintln('Saving User Reset Key: '+inttostr(rJUser.JUser_ResetPass_u));
      bOk:=bJAS_Save_JUser(p_Context,DBC,rJUser,true,true);
      if not bOk then
      begin
        //ASPrintln('Trouble saving user record with new key');
        JAS_Log(p_Context,cnLog_Error,201209141218,'Unable to save user record. JUser_Name: '+rJUser.JUser_Name,'',SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      //ASPrintln('Things are looking up - Sending PASSWORd RESET EMAIL');
      bOk:=bEmail_ResetPassword(p_Context,inttostr(rJUser.JUser_JUser_UID), inttostr(rJUser.JUser_ResetPass_u), rJPerson.JPers_Work_Email,'',p_Context.saAlias);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201203242141,'Unable to send reset password email. UserID: '+inttostr(rJUser.JUser_JUser_UID)+' '+
          'Work Email :'+rJPerson.JPers_Work_Email,
        '',SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;
    end;

    //ASPrintln('Unlocking Records if locked');
    if bHaveJUserLock then bJAS_UnlockRecord(p_Context,DBC.ID, 'juser',inttostr(rJUser.JUser_JUser_UID),'0',201501011039);
    if bHaveJPersonLock then bJAS_UnlockRecord(p_Context,DBC.ID, 'jperson',rJPerson.JPers_JPerson_UID,'0',201501011040);

    if bOk then
    begin
      //ASPrintln('Sending Password Reset Email Sent Page');
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
      bOk:=bJASNote(p_Context,'2012091321230356837',sa,'Password Reset Email sent.');
      if not bOk then
      begin
        //ASPrintln('Failed getting text for Password Reset Email Sent Page');
        JAS_Log(p_Context,cnLog_Error,201203242142,'Trouble reading note table.','',SOURCEFILE);
        RenderHtmlErrorPage(p_Context);
      end;

      if bOk then
      begin
        //ASPrintln('Rendering Password Reset Email Sent Page');
        p_Context.saPage:=saGetPage(p_Context, '','sys_message','',false, 201209132119);
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/folder-remote.png');
        p_Context.saPageTitle:='Success';
      end;
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
      // SEND WEBPAGE that PASSWORd RESET EMAIL has Been Sent
    end;
  end
  else
  begin
    // Do We Have the UID (user) and Password Reset Key?
    if p_Context.CGIENV.DataIn.FoundItem_saName('uid') or
       p_Context.CGIENV.DataIn.FoundItem_saName('key') then
    begin
      //ASPrintln('We Have a UID or KEY');
      if (not p_Context.CGIENV.DataIn.FoundItem_saName('newpassword1')) or
         (not p_Context.CGIENV.DataIn.FoundItem_saName('newpassword1')) then
      begin
        //ASPrintln('Gonna give em a change password form - no newpasswords sent');
        // SEND WEB PAGE ASKING FOR NEW PASSWORD
        // SEND WEB PAGE ASKING FOR NEW PASSWORD
        // SEND WEB PAGE ASKING FOR NEW PASSWORD 
        p_Context.saPage:=saGetPage(p_Context, 'sys_area_panel','sys_resetpassword','',false, 201209132119);
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@KEY@]',p_Context.CGIENV.DataIn.Get_saValue('key'));
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@UID@]',p_Context.CGIENV.DataIn.Get_saValue('uid'));
        p_Context.saPageTitle:='Enter New Password';
        // SEND WEB PAGE ASKING FOR NEW PASSWORD
        // SEND WEB PAGE ASKING FOR NEW PASSWORD
        // SEND WEB PAGE ASKING FOR NEW PASSWORD
      end
      else
      begin
        //ASPrintln('Got Passwords - gonna load user record');
        // VALIDATE UID and KEY - CHANGE PASSWORD if all VALID
        clear_Juser(rJUser);
        rJUser.JUser_JUser_UID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('uid'));
        bOk:=bJAS_Load_Juser(p_Context,DBC,rJUser,true);
        bHaveJUserLock:=bOk;
        if not bok then
        begin
          JAS_Log(p_Context,cnLog_Error,201203242144,'Unable to load user record. UID: '+inttostr(rJUser.JUser_JUser_UID),'',SOURCEFILE);
          RenderHtmlErrorPage(p_Context);
        end;

        if bOk then
        begin
          //ASPrintln('Checking if KEY is Correct for given user');
          bOk:=(rJUser.JUser_ResetPass_u=u8Val(p_Context.CGIENV.DataIn.Get_saValue('key'))) and
              (u8Val(p_Context.CGIENV.DataIn.Get_saValue('key'))<>0);
          if not bOk then
          begin
            //ASPrintln('FAIL: Key not correct for given user');
            JAS_Log(p_Context,cnLog_Error,201209132049,'Invalid Password Reset Key - try resetting password again.','',SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;
        end;

        if bOk then
        begin
          //ASPrintln('Make Sure Passwords Match');
          // ACTUAL PASSWORD CHANGE: UID, KEY, NEWPASSWAORD1, NEWPASSWORD2
          bOk:=p_Context.CGIENV.DataIn.Get_saValue('newpassword1')=
              p_Context.CGIENV.DataIn.Get_saValue('newpassword1');
          if not bOk then
          begin
            //ASPrintln('Passwords Don''t match');
            JAS_Log(p_Context,cnLog_Error,201203242145,'Password Reset - Passwords do not match.','',SOURCEFILE);
            RenderHtmlErrorPage(p_Context);
          end;

          if bOk then
          begin
            //ASPrintln('Make sure passwords well formed');
            bOk:=bGoodPassword(p_Context.CGIENV.DataIn.Get_saValue('newpassword1')) and
                bGoodPassword(p_Context.CGIENV.DataIn.Get_saValue('newpassword2'));
            if not bOk then
            begin
              //ASPrintln('Passwords NOT well formed');
              JAS_Log(p_Context,cnLog_Error,201203242146,'Invalid Password. Mixedcase Letters, Numbers, and Punctuation are allowed. '+
                'Password Length must be 8 - 32 characters long.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            //ASPrintln('Update User Passwords and ZERO KEY and SAVE RECORD');
            rJUser.JUser_Password:=saXorString(p_Context.CGIENV.DataIn.Get_saValue('newpassword1'), grJASConfig.u1PasswordKey);
            rJUser.JUser_ResetPass_u:=0;
            bOk:=bJAS_Save_JUser(p_Context,DBC,rJUser,true,true);
            if not bOk then
            begin
              //ASPrintln('Unable to save User record after password changed');
              JAS_Log(p_Context,cnLog_Error,201209132132,'Password Reset - Unable to save new Password.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
          end;

          if bOk then
          begin
            //ASPrintln('Sending Message that password was changed');
            // SEND WEBPAGE - PASSWORD Changed Successfully
            // SEND WEBPAGE - PASSWORD Changed Successfully
            // SEND WEBPAGE - PASSWORD Changed Successfully
            bOk:=bJASNote(p_Context,'2012091321155541196',sa,'Password changed successfully.');
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error,201209132133,'Trouble reading note table.','',SOURCEFILE);
              RenderHtmlErrorPage(p_Context);
            end;
            if bOk then
            begin
              p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_message','',false, 201209132118);
              p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
              p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/apps/office-organizer.png');
              p_Context.saPageTitle:='Success';
            end;
            // SEND WEBPAGE - PASSWORD Changed Successfully
            // SEND WEBPAGE - PASSWORD Changed Successfully
            // SEND WEBPAGE - PASSWORD Changed Successfully
          end;
        end;
        //ASPrintln('Unlocking user record if locked');
        if bHaveJUserLock then bJAS_UnlockRecord(p_Context,DBC.ID, 'juser',inttostR(rJUser.JUser_JUser_UID),'0',201501011041);
      end;
    end
    else
    begin
      //ASPrintln('Sending Web page asking for username and email');
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
      p_Context.saPage:=saGetPage(p_Context, 'sys_area_panel','sys_forgotpassword','',false, 201209132303);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@KEY@]',p_Context.CGIENV.DataIn.Get_saValue('key'));
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@UID@]',p_Context.CGIENV.DataIn.Get_saValue('uid'));
      p_Context.saPageTitle:='Enter New Password';
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
      // SEND WEB PAGE ASKING FOR USERNAME OR EMAIL
    end;
  end;
  p_Context.bNoWebCache:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201209131244,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================


















//=============================================================================
Procedure JAS_Calendar(p_Context: TCONTEXT);
//=============================================================================
var
  //saCaption: ansistring;
  sa: ansistring;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  bOk: boolean;
  iRow: longint;
  dt: TDATETIME;
  saDT: ansistring;
  saStatus: ansistring;
  saCategory: ansistring;
  saUser: ansistring;
  u2Year, u2Month, u2Day: word;
  iMonth: longint;iYear: longint;

  u2Hour: Word;
  u2Minute: Word;
  u2Second: Word;
  u2MilliSecond: Word;
  saTime: ansistring;
  saAMPM: ansistring;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_Calendar'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201209292223,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201209292224, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;
  
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context,cnLog_Error,201210010047,'You need to be logged in to use this feature.','',SOURCEFILE);
    RenderHTMLErrorPage(p_ContexT);
  end;

  if bOk then
  begin
    DBC:=p_Context.VHDBC;
    rs:=JADO_RECORDSET.Create;
    iMonth:=iVal(p_Context.CGIENV.DataIn.Get_saValue('MONTHINPUT'));
    iYear:=iVal(p_Context.CGIENV.DataIn.Get_saValue('YEARINPUT'));

    if (iYear=0) or (iMonth=0) then
    begin
      DecodeDate(now,u2Year, u2Month, u2Day);
      iYear:=u2Year;
      iMonth:=u2Month;
    end;


    //ASPrintln('Calendar Year/Month: '+inttostr(iYear)+'/'+inttostr(iMonth));
    saQry:=
      'SELECT '+
      '  JTask_JTask_UID, JTask_Start_DT ,JTask_Name, JTask_JTaskCategory_ID, JTask_JStatus_ID, JTask_Owner_JUser_ID '+
      'FROM jtask '+
      ' WHERE (MONTH(JTask_Start_DT)='+DBC.saDBMSIntScrub(iMonth)+') AND (YEAR(JTask_Start_DT)='+DBC.saDBMSIntScrub(iYear)+') AND '+
      //' (JTask_JStatus_ID<>3) and '+
      ' (JTask_Start_DT IS NOT NULL) AND (JTask_Start_DT<>'+DBC.saDBMSScrub('0000-00-00 00:00:00')+') AND '+
      ' (JTask_Owner_JUser_ID='+DBC.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+ ') AND '+
      ' ((JTask_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JTask_Deleted_b IS NULL))'+
      ' ORDER BY JTask_Start_DT';
    //ASPrintln(saQry);
    bOk:=rs.open(saQry,DBC,201503161208);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201209302733,'Trouble opening query','Query: '+saQry,SOURCEFILE,DBC,rs);
      RenderHTMLErrorPage(p_COntext);
    end;

    if bOk and (not rs.eol) then
    begin
      iRow:=0;sa:=csCRLF;
      repeat
        u2Day:=0;
        saDT:=rs.fields.get_saValue('JTask_Start_DT');
        //ASPrintln('Date: '+saDT);
        if (UPCASE(saDT)<>'NULL') then
        begin
          try
            bOk:=false;
            dt:=StrToDateTime(JDate(saDT,1,11));
            DecodeDate(dt,u2Year, u2Month, u2Day);
            DecodeTime(dt,u2Hour,u2Minute,u2Second,u2MilliSecond);
            if(u2Hour>11)then
            begin
              saAMPM:=' PM';
              if u2Hour>12 then u2Hour-=12;
            end
            else
            begin
              saAMPM:=' AM';
            end;
            saTime:='';
            if u2Hour<10 then saTime+=' ';
            saTime+=inttostr(u2Hour)+':';
            if u2Minute<10 then saTime+='0';
            saTime+=inttostr(u2Minute)+saAMPM;
            bOk:=true
          finally
          end;
        end;
        //ASPrintln('Converted Day: '+inttostr(u2Day));

        saStatus:=DBC.saGetValue('jstatus','JStat_Name','((JStat_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JStat_Deleted_b IS NULL)) AND '+
          'JStat_JStatus_UID='+DBC.saDBMSUIntScrub(rs.fields.Get_saValue('JTask_JStatus_ID')));

        saCategory:=DBC.saGetValue('jtaskcategory','JTCat_Name','((JTCat_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JTCat_Deleted_b IS NULL)) AND '+
          'JTCat_JTaskCategory_UID='+DBC.saDBMSUIntScrub(rs.fields.Get_saValue('JTask_JTaskCategory_ID')));

        saUser:=DBC.saGetValue('juser','JUser_Name','((JUser_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
          'JUser_JUser_UID='+DBC.saDBMSUIntScrub(rs.fields.Get_saValue('JTask_Owner_JUser_ID')));

        //ASPrintln('Build Javascript');
        sa+=
          '  arTask['+inttostr(iRow)+']=new Array(7);'+csCRLF+
          '  arTask['+inttostr(iRow)+'][0]= '+inttostr(u2Day)+';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][1]= '''+rs.fields.Get_saValue('JTask_JTask_UID')+''';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][2]= '''+saEscape(rs.fields.Get_saValue('JTask_Name'),'''','\''')+''';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][3]= '''+saEscape(saCategory,'''','\''')+''';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][4]= '''+saEscape(saStatus,'''','\''')+''';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][5]= '''+saEscape(saUser,'''','\''')+''';'+csCRLF+
          '  arTask['+inttostr(iRow)+'][6]= '''+saTime+''';'+csCRLF+
          csCRLF;
        //ASPrintln('NAME: '+saDoubleEscape(rs.fields.Get_saValue('JTask_Name'),''''));
        iRow+=1;
      until (not bOK) or (not rs.movenext);
    end;
    rs.close;
    //ASPrintln('Closing Down');


    p_Context.saPagetitle:='JAS Calendar';
    p_Context.saMimeType:=csMIME_TextHtml;
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_calendar','',false,201203122212);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'// ADD TASKS HERE-DO NOT REMOVE THIS LINE',sa);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@YEAR@]',inttostr(iYear));
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@MONTH@]',inttostr(iMonth));
    //p_Context.saPage:=saSNRStr(p_Context.saPage,'[@QUERY@]',saQry);
    p_Context.CGIENV.iHTTPResponse:=200;
    p_Context.bNoWebCache:=true;
    rs.destroy;
  end;
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201209292225,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
// This function interactively works with the user to gather information needed
// to create a new JAS Jet (new system). this routine handles preventing
// duplicates and verifying the alias name is valid and that the from email
// address looks like a valid email address. This function also PREVENTS a
// USER from creating more than one system.
Procedure JAS_CreateJet(p_Context: TCONTEXT);
//=============================================================================
var
  //saQry: ansistring;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  bOk: boolean;
  bDone: boolean;
  saName: ansistring;
  saServerName: ansistring;
  saFromEmail: ansistring;
  saMessage: ansistring;
  rJPerson: rtJPerson;
  rJJobQ: rtJJObQ;
  sa: ansistring;
  dt: TDATETIME;
  i: longint;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_CreateJet'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211130949,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211130950, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;bDone:=false;
  saMessage:='';
  DBC:=p_Context.VHDBC;
  rs:= JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context,cnLog_Error,201211130951,'You need to be logged in to use this feature.','',SOURCEFILE);
  end;

  if bOk then
  begin
    //saName:=p_Context.CGIENV.DataIn.get_saValue('name');
    saServerName:=p_Context.CGIENV.DataIn.get_saValue('servername');
    saFromEmail:=p_COntext.CGIENV.DataIn.get_saValue('fromemail');
    //bDone:=(saName='') and (saServerName='') and (saFromEmail='');
    //AS_LOG(p_Context, cnLog_Debug, 201211260246, 'CreateJet Input: '+saServerName+' and '+saFromEmail,'',SOURCEFILE);
    bDone:= (saServerName='') and (saFromEmail='');
  end;

  //if bOk and (not bDone) then
  //begin
  //  bDone:=NOT bGoodUserName(saName);
  //  if bDone then saMessage:='Invalid Alias. Please use only letters and numbers; no spaces or puncuation.';
  //end;

  //if bOk and (not bDone) then
  //begin
  //  bDone:=( 0 < DBC.u8GetRowCount('jvhost','VHost_ServerDomain='+DBC.saDBMSScrub(saName)+' AND '+
  //    '((VHost_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL))'));
  //  if bDone then saMessage:='A system already exists with that name.';
  //end;
  
  if bOk and (not bDone) then
  begin
    bDone:=NOT bGoodEmail(saFromEmail);
    if bDone then saMessage:='Invalid email address.';
  end;

  if bOk and (not bDone) then
  begin
    clear_JPerson(rJPerson);
    rJPerson.JPers_JPerson_UID:=inttostr(p_Context.rJUser.JUser_JPerson_ID);
    bOK:=bJAS_Load_JPerson(p_Context, DBC, rJPerson, false);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211131229, 'User attempting to create a new JAS JET '+
        'is missing their Person Record. User: '+p_Context.rJUser.JUser_Name,'',SOURCEFILE);
    end;  
  end;

  if bOk and (not bDone) then
  begin
    bDone:=length(trim(rJPerson.JPers_NameFirst))=0;
    if bDone then saMessage:='Your person record is missing First Name.';
  end;
  
  if bOk and (not bDone) then
  begin
    bDone:=length(trim(rJPerson.JPers_NameLast))=0;
    if bDone then saMessage:='Your person record is missing Last Name.';
  end;

  if bOk and (not bDone) then
  begin
    bDone:=not bGoodEmail(rJPerson.JPers_Work_Email);
    if bDone then saMessage:='Your person record does not contain a valid work email address.';
  end;

  if bOk and (not bDone) then
  begin
    bDone:= 0 < DBC.u8GetRowCount('juser','((JUser_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
      '(JUser_JVHost_ID>0) and (JUser_JUser_UID='+DBC.saDBMSUIntScrub(p_COntext.rJUser.JUser_JUser_UID)+')',201506171717);
    if bDone then saMessage:='You appear to already have a JAS Jet in flight.';
  end;

  if bOk then
  begin
    i:=1;
    repeat
      saName:='jet'+saZeroPadInt(i,2);
      if DBC.u8GetRowCount(
        'jvhost',
        'VHost_ServerDomain='+DBC.saDBMSScrub(saName)+' AND '+
        '((VHost_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL))',
      201506171718)=0 then break;
      i+=1;
    until (not bOk) or (i>=100);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211180151, 'There isn''t room for another JAS jet '+
        'in this squadron. Please contact administrator.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    if bDone then
    begin
      //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@NAME@]',saName);
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@SERVERNAME@]',saServerName);
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@FROMEMAIL@]',saFromEmail);
      p_Context.PAGESNRXDL.AppendItem_SNRPair('[@MESSAGE@]',saMessage);
      p_Context.saPage:=saGetPage(p_Context, 'sys_area_bare','sys_createjet','MAIN',false,201211131017);
    end
    else
    begin
      dt:=now;
      clear_JJobQ(rJJobQ);
      with rJJobQ do begin
        JJobQ_JJobQ_UID           :='0';
        JJobQ_JUser_ID            :=p_Context.rJSession.JSess_JUser_ID;
        JJobQ_JJobType_ID         :=inttostr(cnJJobType_General);
        JJobQ_Start_DT            :=saFormatDateTime(csDateTimeFormat,dt);
        JJobQ_ErrorNo_u           :='NULL';
        JJobQ_Started_DT          :='NULL';
        JJobQ_Running_b           :='false';
        JJobQ_Finished_DT         :='NULL';
        JJobQ_Name                :='New JAS Jet: '+saName;
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
        JJobQ_Job:=
        '<CONTEXT>'+csCRLF+
        '  <saRequestMethod>POST</saRequestMethod>'+csCRLF+
        '  <saRequestType>HTTP/1.0</saRequestType>'+csCRLF+
        '  <saRequestedFile>'+p_Context.saAlias+'</saRequestedFile>'+csCRLF+
        '  <saQueryString>jasapi=createvirtualhost</saQueryString>'+csCRLF+
        '  <REQVAR_XDL>'+csCRLF+
        '    <ITEM>'+csCRLF+
        '      <saName>HTTP_HOST</saName>'+csCRLF+
        '      <saValue>'+garJVHostLight[p_Context.i4VHost].saServerDomain+'</saValue>'+csCRLF+
        '    </ITEM>'+csCRLF+
        '  </REQVAR_XDL>'+csCRLF+
        '  <CGIENV>'+csCRLF+
        '   <DATAIN>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>name</saName>'+csCRLF+
        '       <saValue>'+saName+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>servername</saName>'+csCRLF+
        '       <saValue>'+saEncodeURI(saServerName)+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>firstname</saName>'+csCRLF+
        '       <saValue>'+saEncodeURI(rJPerson.JPers_NameFirst)+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>lastname</saName>'+csCRLF+
        '       <saValue>'+rJPerson.JPers_NameLast+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>fromemail</saName>'+csCRLF+
        '       <saValue>'+saEncodeURI(saFromEmail)+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>workemail</saName>'+csCRLF+
        '       <saValue>'+rJPerson.JPers_Work_Email+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '     <ITEM>'+csCRLF+
        '       <saName>cgibased</saName>'+csCRLF+
        '       <saValue>'+satruefalse(cbCGIBased)+'</saValue>'+csCRLF+
        '     </ITEM>'+csCRLF+
        '  </CGIENV>'+csCRLF+
        '</CONTEXT>';
        JJobQ_Result              :='NULL';
        JJobQ_JTask_ID            :='0';

        bOk:=bJAS_Save_JJobQ(p_Context, p_Context.VHDBC, rJJobQ, false,false);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211131393,'Unable to save JobQ record - CreateVirtualHost','',SOURCEFILE);
        end;

        if bOk then
        begin
          saQry:='UPDATE juser set JUser_JVHost_ID='+DBC.saDBMSUIntScrub(cnJUser_JVHost_Processing)+' WHERE JUser_JUser_UID='+DBC.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
          bOk:=rs.open(saQry, DBC,201503161209);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211272241, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
          end;
          rs.close;
        end;

        if bOk then
        begin
          p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGEICON@]','[@JASDIRWEBSHARE@]img/logo/jegas/jjet_topside_sm.png');
          p_Context.saPage:=saGetPage(p_Context,'sys_area','sys_messagewr','MESSAGE',false,'',201210231345);
          sa:='Congratulations! Your JAS JET is being prepared for flight!<br /><br /> '+
            'You will receive an email when it''s ready for flight. Your username in the system is "admin" by default '+
            'but you can optionally change this to your preferred username and still have your admin privileges. The '+
            'email will be a link to set your password. After you set it you can login as admin with the password you set.';
          p_Context.PageSNRXDL.AppendItem_SNRPAir('[@MESSAGE@]',sa);
        end
        else
        begin
          RenderHTMLErrorPage(p_Context);
        end;
      end;
    end;
  end
  else
  begin
    RenderHTMLErrorPage(p_Context);
  end;
  p_Context.bNoWebCache:=true;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211130952,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
Procedure JAS_Register(p_Context: TCONTEXT);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_Register'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211280922,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211280923, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.saPage:=saGetPage(p_Context, 'sys_area_panel','sys_register','MAIN',False,201211280925);
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@ALLOWREGISTRATION@]',saTruefalse(garJVHostLight[p_Context.i4VHost].bAllowRegistration));
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@REGISTRATIONREQCELLPHONE@]',saTruefalse(garJVHostLight[p_Context.i4VHost].bRegistrationReqCellPhone));
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@REGISTRATIONREQBIRTHDAY@]',saTruefalse(garJVHostLight[p_Context.i4VHost].bRegistrationReqBirthday));
  p_Context.bNoWebCache:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211280924,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
Procedure JAS_Help(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  Help_JHelp_UID: ansistring;
  //saHelpHTMLDefaultADV: ansistring;
  saHelpHTMLDefault: ansistring;
  saHelpHTMLAdv: ansistring;
  saHelpHTML: ansistring;
  //saHelpVideoMP4Default: ansistring;
  //saHelpVideoMP4: ansistring;
  //saHelpPoster: ansistring;
  saHelpNameDefault: ansistring;
  saHelpName: ansistring;
  saDefaultText: ansistring;
  sa: ansistring;
  bHaveHelp: boolean;
  
  saHTML: ansistring;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_Help'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211290303,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211290304, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_COntext.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saDefaultText:='Help Not Found';
  bOk:=true;
  bHaveHelp:=true;

{
  Help_JHelp_UID            : ansistring;
  Help_VideoMP4_en          : ansistring;
  Help_HTML_en              : ansistring;
  Help_Name                 : ansistring;
  Help_Poster               : ansistring;
}

  //saHelpHTMLDefaultAdv :='';
  saHelpHTMLDefault    :='';
  saHelpHTML           :='';
  //saHelpVideoMP4Default:='';
  //saHelpVideoMP4       :='';
  //saHelpPoster         :='';
  saHelpNameDefault    :='';
  saHelpName           :='';


  Help_JHelp_UID:=p_Context.CGIENV.DataIn.Get_saValue('HELPID');
  saQry:='SELECT '+
    //'Help_VideoMP4_en as VideoMP4Default, '+
    //'Help_VideoMP4_'+p_Context.saLang+' as VideoMP4, '+
    'Help_HTML_Adv_en as HTMLDefaultAdv, '+
    'Help_HTML_en as HTMLDefault, '+
    'Help_HTML_'+p_Context.saLang+' as HTML, '+
    'Help_Name_en as HelpNameDefault, '+
    'Help_Name_'+p_Context.saLang+' as HelpName '+
    //'Help_Poster '+
    ' FROM jhelp '+
    'WHERE ((Help_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(Help_Deleted_b IS NULL)) AND '+
    '  Help_JHelp_UID='+DBC.saDBMSUintScrub(Help_JHelp_UID);
  bOk:=rs.Open(saQry, DBC,201503161210);
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201212031249,'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
    RenderHTMLErrorPage(p_Context);
  end;

  if bOk then
  begin
    if not rs.eol then
    begin
      saHelpHTMLAdv        :=rs.fields.get_savalue('HTMLDefaultAdv');
      saHelpHTMLDefault    :=rs.fields.Get_saValue('HTMLDefault');
      saHelpHTML           :=rs.fields.Get_saValue('HTML');
      //saHelpVideoMP4Default:=rs.fields.Get_saValue('VideoMP4Default');
      //saHelpVideoMP4       :=rs.fields.Get_saValue('VideoMP4');
      //saHelpPoster         :=rs.fields.Get_saValue('Help_Poster');
      saHelpNameDefault    :=rs.fields.Get_saValue('HelpNameDefault');
      saHelpName           :=rs.fields.Get_saValue('HelpName');
    end
    else
    begin
      bHaveHelp:=false;
    end;
  end;

  rs.close;

  if bOk then
  begin
    if (trim(saHelpHTML)='') or (trim(saHelpHTML)='NULL') then
    begin
      if (trim(saHelpHTMLDefault)='') or (trim(saHelpHTMLDefault)='NULL') then
      begin
        bHaveHelp:=false;
      end
      else
      begin
        saHelpHTML:=saHelpHTMLDefault;
      end;
    end;

    if (trim(saHelpHtml)='NULL') then saHelpHtml:='';
    if (trim(saHelpHTMLDefault)='NULL') then saHelpHtmlAdv:='';

    if (trim(saHelpName)='') or (trim(saHelpName)='NULL') then
    begin
      if (trim(saHelpNameDefault)='') or (trim(saHelpNameDefault)='NULL') then
      begin
        bHaveHelp:=false;
      end
      else
      begin
        saHelpName:=saHelpNameDefault;
      end;
    end;

    if (trim(saHelpName)='NULL') then saHelpName:='';
    

    //if (trim(saHelpVideoMP4)='') or (trim(saHelpVideoMP4)='NULL') then
    //begin
    //  if NOT (trim(saHelpVideoMP4Default)='') or (trim(saHelpVideoMP4Default)='NULL') then
    //  begin
    //    saHelpVideoMP4:=saHelpVideoMP4Default;
    //  end;
    //end;

    //if (trim(saHelpVideoMP4)='NULL') then saHelpVideoMP4:='';


    if trim(saHelpName)='NULL' then saHelpName:='';
    if bHaveHelp then
    begin
      sa:=saGetPage(p_Context, '','sys_page_help','MAIN',true,201212030409);
      saHTML:=saHelpHTML;
      if (p_Context.rJUser.JUser_Admin_b) and (trim(saHelpHTMLAdv)<>'') and (trim(saHelpHTMLAdv)<>'NULL') then
      begin
        saHTML+='<hr /><center><h2>Advanced Help Below</h2></center></hr />'+saHelpHTMLAdv;
      end;
      sa:=saSNRStr(sa,'[@HTML@]',saHTML);
    end
    else
    begin
      saHelpName:=saDefaultText;
      sa:=saGetPage(p_Context, '','sys_page_helpnone','MAIN',true,201212031417);
    end;
    p_Context.saPage:=saGetPage(p_Context, 'sys_area_help','sys_message','MESSAGE',false,201211290305);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]',saHelpName);
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/actions/help-contents.png');
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@MESSAGE@]',sa);
    //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@VIDEOMP4@]',saHelpVideoMP4);
    //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@POSTER@]',saHelpPoster);
  end;
  
  p_Context.bNoWebCache:=true;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211290306,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
