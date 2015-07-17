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
// Main UNIT for JAS
Unit uj_worker;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_worker.pp'}
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

{DEFINE DIAGNOSTIC_LOG}
{$IFDEF DIAGNOSTIC_LOG}
  {$INFO | DIAGNOSTIC_LOG: TRUE}
{$ENDIF}

{DEFINE DIAGMSG}
{$IFDEF DIAGMSG}
  {$INFO | DIAGMSG: TRUE}
{$ENDIF}


{DEFINE SAVE_HTMLRIPPER_OUTPUT}
{$IFDEF SAVE_HTMLRIPPER_OUTPUT}
  {$INFO | SAVE_HTMLRIPPER_OUTPUT: TRUE}
{$ENDIF}

{DEFINE SAVE_ALL_OUTPUT}
{$IFDEF SAVE_ALL_OUTPUT}
  {$INFO | SAVE_ALL_OUTPUT: TRUE}
{$ENDIF}


{DEFINE DIAGNOSTIC_WEB_MSG}
{$IFDEF DIAGNOSTIC_WEB_MSG}
  {$INFO | DIAGNOSTIC_WEB_MSG: TRUE}
{$ENDIF}

{DEFINE DEBUG_PARSEWEBSERVICEFILEDATA} // The ParseWebServiceFileData
                  // function has alot of JASDebugPrintLn commands that
                  // are great when debugging the parsing but overkill as
                  // debug output otherwise. Undefine to make those lines not
                  // get included in the compile.
{$IFDEF DEBUG_PARSEWEBSERVICEFILEDATA}
  {$INFO | DEBUG_PARSEWEBSERVICEFILEDATA: TRUE}
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
,dateutils
,sockets
,blcksock
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jfc_xml
,ug_jfc_tokenizer
,ug_jfc_dir
,ug_jfc_threadmgr
,ug_tsfileio
,uj_executecgi
,uj_definitions
,uj_context
,uj_fileserv
,uj_ui_stock
,ug_jado
,uj_locking
,uj_tables_loadsave
,uj_sessions
,uj_xml
,uj_jegas_customizations_empty
,uj_permissions
,uj_menueditor
,uj_dbtools
,uj_iconhelper
,uj_menusys
,uj_notes
,uj_application
,uj_ui_screen
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
// TWORKER - Is a class based on TJTHREAD. This class represents the worker threads
// for JAS applications and web server operations.
type TWORKER=class(TJTHREAD)
//=============================================================================
  iMyID: integer;
  dtResumed: TDateTime;
  bInternalJob: boolean;
  procedure OnCreate;override;
  procedure OnTerminate; override;
  Procedure ExecuteMyThread; override;
  Procedure ResetThread; override;//< Prepared Variables for a New Firing of the thread.
  {}
  //saRequest: ansistring;
  //saBufferIn: ansistring;

  //Function getfile(p_saFilename: AnsiString; var p_saHTTPStatusCode: AnsiString; p_saQuery: AnsiString = ''): AnsiString;
  {}
  //Process: TPROCESS;
  public
  Context: TCONTEXT;
  rJJobQ: rtJJobQ;
  {}
  // LOADS MYCGI and Context.REQVAR_XDL;
  {}
  procedure SetErrorReportingModeAndDebugModeFlags;
  procedure ParseRequest;//< modifies self.Context.CGIENV.iHTTPResponse
  procedure ParseJASCGI;//< Makes JAS CGI PROXY Requests usuable locally
  {}
  public
  Connectionsocket: TTCPBlockSocket;
  bMultiPart: boolean;
  iReqOrigLength: Longint;
  iReqFileNameLength: Longint;
  bReqDirExist: boolean;
  saDirNFile: ansistring;
  bDirNFileExist: boolean;
  bReqFileIsFile: boolean;
  bFileSoughtExists: boolean;

  {}
  Procedure CheckJobQ;
  Procedure CompleteJobQTask;
  Procedure DirectoryListing;
  procedure GrabIncomingData;
  procedure ParseAndVerifyGoodremoteAddress;
  Procedure VirtualHostTranslation;
  Procedure TranslateRequestToFilename;
  Procedure CheckIfTrailSlashOrRedirect;
  procedure ResolveDefaultFileIfNoneGiven;
  procedure CleanUpAndVerifyCompleteFilename;
  procedure DispatchRequest;

  {$IFDEF DIAGNOSTIC_LOG}
  procedure DiagnosticLog;
  {$ENDIF}
  Procedure LogRequest;



end;
//=============================================================================
var aWorker: array of TWorker;





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
procedure TWORKER.OnCreate();
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.OnCreate();'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102712,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102713, sTHIS_ROUTINE_NAME);{$ENDIF}
  
  Context:=TCONTEXT.Create(
    grJASCOnfig.saServerSoftware,
    grJASConfig.iTimeZoneOffset,
    TJTHREAD(self)
  );
  bInternalJob:=false;
  ResetThread;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102714,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
procedure TWORKER.OnTerminate;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
//asprintln('TWORKER.OnTerminate - begin');

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.OnTerminate;'; {$ENDIF}

{IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}
  DBIN(201203102715,sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
{$IFDEF TRACKTHREAD}
  TrackThread(201203102716, sTHIS_ROUTINE_NAME);
{$ENDIF}
  //asprintln('Context in worker: ' + inttostr(uint(context)));
  Context.Destroy;Context:=nil;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{IFDEF DEBUGTHREADBEGINEND}
//DBOUT(201203102717,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
  //asprintln('TWORKER.OnTerminate - end');
end;
//=============================================================================


//=============================================================================
Procedure TWORKER.ResetThread; // Prepared Variables for a New Firing of the thread.
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ResetThread;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102718,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102719, sTHIS_ROUTINE_NAME);{$ENDIF}


  {$IFDEF DIAGMSG}
    //ASPrintLn('TWorker.ResetThread-Enter');
  {$ENDIF}
  Context.Reset;
  bInternalJob:=false;
  iReqOrigLength:=0;
  iReqFileNameLength:=0;
  bReqDirExist:=false;
  saDirNFile:='';
  bDirNFileExist:=false;
  bReqFileIsFile:=false;
  bMultiPart:=false;
  bFileSoughtExists:=false;
  clear_JJobQ(rJJobQ);
  dtResumed:=0;


  {$IFDEF TRACKTHREAD}TrackThread(201211291228, sTHIS_ROUTINE_NAME+' RESET b4 Inherited');{$ENDIF}


  
  //NOTE: Connectionsocket: TTCPBlockSocket;
  //      This Item is handled before thread resumed in TListen.ExecuteMyThread
  //      And Cleaned up at end of TWorker.ExecuteMyThread
  {$IFDEF DEBUGTHREADBEGINEND}DBIN(201002062018,'Inherited',SOURCEFILE);{$ENDIF}
  inherited;
  {$IFDEF DEBUGTHREADBEGINEND}DBOUT(201002062019,'Inherited',SOURCEFILE);{$ENDIF}
  {$IFDEF TRACKTHREAD}TrackThread(201211291228, sTHIS_ROUTINE_NAME+' RESET Complete');{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102720,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





























//=============================================================================
Procedure TWORKER.DirectoryListing;
//=============================================================================
var
  DirDL: JFC_DIR;
  //saFancyYes: ansistring;
  //saFancyNo: ansistring;
  saFancyFolder: ansistring;
  saFancyFile: ansistring;
  saDirRender: ansistring;


  sDIR: String;
  sName: String;
  sExt: String;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.DirectoryListing';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161912,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  //saFancyYes:='<img title="Yes" class="image" src="[@JASDIRICONTHEME@]16/actions/dialog-ok.png" />';
  //saFancyNo:='<img title="No" class="image" src="[@JASDIRICONTHEME@]16/actions/dialog-no.png" />';
  saFancyFolder:='<img title="No" class="image" src="'+grJASConfig.saWebShareAlias+'img/icon/themes/'+Context.sIconTheme+'/22/places/folder.png" />';
  saFancyFile:='<img title="No" class="image" src="'+grJASConfig.saWebShareAlias+'img/icon/themes/'+Context.sIconTheme+'/22/actions/document-new.png" />';

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

  self.Context.CGIENV.iHTTPResponse:=200;//ok
  DirDL:=JFC_DIR.Create;
  DirDL.saPath:=self.Context.saRequestedDir;
  DirDL.bDirOnly:=false;
  {$IFDEF WIN32}
    DirDL.saFileSpec:='*.*';
  {$ELSE}
    DirDL.saFileSpec:='*';
  {$ENDIF}
  DirDL.bSort:=true;
  DirDL.bSortAscending:=true;
  DirDL.bSortCaseSensitive:=false;

  DirDL.LoadDir;
  saDirRender:=
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'+csCRLF+
    '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >'+
    '<head><title>/'+self.Context.saOriginallyRequestedFile+'</title></head><body>'+
    '<h2>'+self.Context.saOriginallyRequestedFile+'</h2>'+
    '<table>';
  if DirDL.movefirst then
  begin
    repeat
      saDirRender+='<tr><td>';
      saDirRender+='<a href="'+DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='/';
      end;
      saDirRender+='" title="';
      if DirDL.Item_bDir then
      begin
        saDirRender+='[&nbsp;';
      end;
      saDirRender+=DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='&nbsp;]';
      end;
      saDirRender+='" >';
      if DirDL.Item_bDir then
      begin
        saDirRender+=saFancyFolder;
      end
      else
      begin
        saDirRender+=saFancyFile;
      end;
      saDirRender+='</a></td><td>';


      saDirRender+='<a href="'+DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='/';
      end;
      saDirRender+='" title="';
      if DirDL.Item_bDir then
      begin
        saDirRender+='[&nbsp;';
      end;
      saDirRender+=DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='&nbsp;]';
      end;
      saDirRender+='" ><font size="4">';
      if DirDL.Item_bDir then
      begin
        saDirRender+='[&nbsp;';
      end;
      saDirRender+=DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='&nbsp;]';
      end;
      saDirRender+='</font></a>';
      saDirRender+='</td><td>';

      FSplit(DirDL.Item_saName,sDir,sName,sExt);
      sExt:=Uppercase(sExt);
      if (sExt='.GIF') or (sExt='.BMP') or (sExt='.PNG') then
      begin
        saDirRender+='<img class="image" src="'+DirDL.Item_saName+'" />';
      end;
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

    until not DirDL.MoveNext;
  end;
  saDirRender+='</table></body></html>';
  self.Context.saOut:=saDirRender;
  self.Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
  self.context.CGIENV.Header_Html(garJVHostLight[Context.i4VHost].saServerIdent);
  DirDL.Destroy;DirDL:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161913,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




























//=============================================================================
// TODO: Make Blacklisting functionality (for webserver mode) available for CGI
// mode also.
Procedure TWORKER.ExecuteMyThread; // to be overridden
//=============================================================================
Var
  saHeaders: ansistring;
  sColorThemeNameInCookie: string;
  sIconThemeNameInCookie: string;
  sCacheControl: string;
  sa: ansistring;
  bPhantomRequest: boolean;
  iLen: longint;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ExecuteMyThread;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102720,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102721, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintln('TWORKER.ExecuteMyThread BEGIN');

  Context.bInternalJob:=self.bInternalJob;

  //--------------------------- GET REQUEST
  //ASPrintln('CALLING GrabIncomingData');
  GrabIncomingData;
  
  bPhantomRequest:=(Context.saIN='') and (NOT Context.bInternalJob);

  //JLOG(Context,cnLog_Debug,201209241024,'ExecuteMyThread DEBUG: Context.saIN: '+Context.saIN,'',SOURCEFILE);
  if (not bPhantomRequest) then
  begin
    //ASPrintln('CALLING ParseAndVerifyGoodremoteAddress');
    if not bInternalJob then ParseAndVerifyGoodremoteAddress;
    //--------------------------- GET REQUEST

    //--------------------------- DETERMINE WHAT REQUEST IS AND DISPATCH
    //ASPrintln('CALLING VirtualHostTranslation');
    if self.Context.CGIENV.iHTTPResponse = 0  then 
    begin
      VirtualHostTranslation;
      //ASPrintln('CALLING TranslateRequestToFilename');
      if self.Context.CGIENV.iHTTPResponse = 0  then 
      begin
        TranslateRequestToFilename;
        //ASPrintln('CALLING CheckIfTrailSlashOrRedirect');
        if self.Context.CGIENV.iHTTPResponse = 0  then 
        begin
          CheckIfTrailSlashOrRedirect;
          //ASPrintln('CALLING ResolveDefaultFileIfNoneGiven');
          if self.Context.CGIENV.iHTTPResponse = 0  then 
          begin
            ResolveDefaultFileIfNoneGiven;
            //ASPrintln('CALLING CleanUpAndVerifyCompleteFilename');
            if self.Context.CGIENV.iHTTPResponse = 0  then CleanUpAndVerifyCompleteFilename;
          end;
        end;
      end;
    end;
 
    //ASPrintln('ServerIdent: '+garJVHostLight[Context.i4VHost].saServerIdent);
    // COOKIE SCRUB [ ServerIdent_COOKINENAME ]
    if self.Context.CGIENV.iHTTPResponse = 0  then
    begin
      if Context.CGIENV.CKYIN.MoveFirst then
      begin
        iLen:=length(garJVHostLight[Context.i4VHost].saServerIdent);
        repeat
          //ASPrintln('CKYIN: '+Context.CGIENV.CKYIN.Item_saName);
          if saLeftStr(Context.CGIENV.CKYIN.Item_saName,iLen)=garJVHostLight[Context.i4VHost].saServerIdent then
          begin
            //ASPrintln('CORRECT CKY IDENT');
            Context.CGIENV.CKYIN.Item_i8User:=0;
            Context.CGIENV.CKYIN.Item_saName:=saRightStr(Context.CGIENV.CKYIN.Item_saName,length(Context.CGIENV.CKYIN.Item_saName)-iLen-1);
          end
          else
          begin
            //ASPrintln('WRONG CKY IDENT');
            Context.CGIENV.CKYIN.Item_i8User:=1;
          end;
          //ASPrintln('CKYDONE: '+Context.CGIENV.CKYIN.Item_saName);
        until not Context.CGIENV.CKYIN.MoveNext;
        while Context.CGIENV.CKYIN.FoundItem_i8User(1) do Context.CGIENV.CkyIn.DeleteItem;
        //ASPrintln('Cookies Left After Processing: '+inttostr(Context.CGIENV.CKYIN.ListCount));
      end;

      //-------------------------- THEME RELATED ----------------------------------
      sColorThemeNameInCookie:=trim(Context.CGIENV.CKYIN.Get_saValue('JASCOLORTHEME'));
      if sColorThemeNameInCookie<>'' then
      begin
        Context.saColorTheme:=sColorThemeNameInCookie;
      end
      else
      begin
        //Context.saColorTheme:='default';
        Context.saColorTheme:='black';
        //Context.saColorTheme:=garJVHostLight[0].saDefaultColorTheme;
      end;
      /////////////////   Icon Theme
      Context.sIconTheme:='CrystalClear';
      sIconThemeNameInCookie:=trim(Context.CGIENV.CKYIN.Get_saValue('JASICONTHEME'));
      if sIconThemeNameInCookie<>'' then Context.sIconTheme:=sIconThemeNameInCookie;
      /////////////////
      //-------------------------- THEME RELATED ----------------------------------
    end;

    
    //ASPrintln('CALLING DispatchRequest');
    if self.Context.CGIENV.iHTTPResponse = 0  then DispatchRequest;
    //--------------------------- DETERMINE WHAT REQUEST IS AND DISPATCH



    //ASPrintln('Part #10 is Next');
    //-----------------------------------------------------------------------------------------
    //PART #10 ---------- Handle Rendering Errors and server messages
    //-----------------------------------------------------------------------------------------
    if (Context.bErrorCondition) and (length(Context.saOut)=0) then
    begin
      RenderHtmlErrorPage(Context);
    end else

    if (length(trim(Context.saOut))=0) and (Context.CGIENV.ihttpresponse<300) then
    begin
      // render 204 no content error (not really an error but...)
      //p_Context.CGIENV.ihttpresponse:=cnHTTP_RESPONSE_204;
      Context.CGIENV.ihttpresponse:=cnHTTP_RESPONSE_204;
      Context.saOut:=saGetErrorPage(Context);
    end else

    if(Context.CGIENV.iHTTPResponse>=300) and  (Context.CGIENV.iHTTPResponse<400) then
    begin
      // REDIRECT - LET IT BE
    end else

    if (Context.CGIENV.iHTTPResponse>cnHTTP_RESPONSE_200) then
    begin
      Context.saOut:=saGetErrorPage(Context);
    end;
    //-----------------------------------------------------------------------------------------

    
    //---------------------------------------------------------- JAS SNR
    Context.JAS_SNR;//Search-n-Replace
    //---------------------------------------------------------- JAS SNR
    //ASPrintln(Context.saIn);

    if not ((Context.saMimeType='execute/cgi') or
       (Context.bMIME_execute_PHP) or
       (Context.bMIME_execute_Perl)) then
    begin
      //ASPrintln('MIME TYPE b4 Call to DebugHTML: >'+Context.saMimeType+'< csMIME_TextHtml: >'+csMIME_TextHtml+'<');
      if (Context.saMimeType=csMIME_ExecuteJegas) or
         (Context.saMimeType=csMIME_TextHtml) or
         (Context.saMimeType=csMIME_TextHtm) then
      begin
        //ASPrintLn('Context.DebugHTMLOutput - CALLED from Context: '+Context.saIn);
        Context.DebugHTMLOutput;
      end;

      //========================================================= HEADERS (and Cookies)
      sCacheControl:='no-cache';
      if (NOT Context.bNoWebCache) and (grJASConfig.sCacheMaxAgeInSeconds<>'0') then
      begin
        sCacheControl:='max-age='+grJASConfig.sCacheMaxAgeInSeconds+', must-revalidate';
      end;
      saHeaders:=Context.CGIENV.saGetHeaders(Context.saMimeType,length(Context.saOut),sCacheControl,grJASConfig.saServerSoftware,garJVHostLight[Context.i4VHost].saServerIdent);
      //===============================================================================

      //-------------------------CONSOLE OUTPUT----------------------------------------
      if trim(self.Context.rJSession.JSess_IP_ADDR)<>'' then
      begin
        //sa:='['+Context.rJSession.JSess_IP_ADDR+'] - '+inttostr(Context.CGIENV.iHTTPResponse)+' '+Context.saMimeType+' '+Context.saRequestedFile;
        //sa:='['+Context.rJSession.JSess_IP_ADDR+'] - '+inttostr(Context.CGIENV.iHTTPResponse)+' '+Context.saMimeType+' '+Context.saRequestedFile+' '+Context.saOriginallyRequestedFile;
        sa:='['+Context.rJSession.JSess_IP_ADDR+'] - '+inttostr(Context.CGIENV.iHTTPResponse)+' '+Context.saMimeType+' '+Context.saOriginallyRequestedFile;
      end
      else
      begin
        sa:=inttostr(Context.CGIENV.iHTTPResponse)+' '+Context.saMimeType+' ';
        if Context.CGIENV.DataIn.MoveFirst then
        begin
          //repeat
            sa+=Context.CGIENV.DataIn.Item_saName+'='+Context.CGIENV.DataIn.Item_saValue;
            {$IFDEF LINUX}sa+=csLF;{$ELSE}sa+=csCRLF;{$ENDIF}
          //until not Context.CGIENV.DataIn.MoveNext;
        end;
      end;
      JASPrintLn(sa);
    end;


    if (false=bInternalJob) then
    begin
      if (length(saHeaders)>0) then
      begin
        ConnectionSocket.SendString(saHeaders);
      end;
      if(length(self.Context.saOut)>0)then ConnectionSocket.SendString(self.Context.saOut);
    end
    else
    begin
      CompleteJobQTask;
    end;
  end;
  //else
  //begin
  //  //ASPrintln('['+NetAddrToStr(in_addr(self.Connectionsocket.RemoteSin.sin_addr))+'] - ??? Phantom - Internal: '+satrueFalse(Context.bInternalJob));
  //  //ASPrintln('['+NetAddrToStr(in_addr(self.Connectionsocket.RemoteSin.sin_addr))+'] - ??? Phantom');
  //end;
  if ConnectionSocket<>nil then
  begin
    ConnectionSocket.Destroy;ConnectionSocket:=nil;
  end;
  //--------------------------- SEND OUT THE RESULTS OF THE REQUEST

  {$IFDEF DIAGNOSTIC_LOG}DiagnosticLog;{$ENDIF}
  LogRequest;
    
  //asprintln('TWORKER.ExecuteMyThread END');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(2012031027222,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
procedure TWORKER.GrabIncomingData;
//=============================================================================
var
  bReadStop_WaitingDataZero: boolean;
  bReadStop_MaxRequestHeaderLength: boolean;
  i4PacketCount: longint;
  iRetries: longint;
  saPacketData: Ansistring;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.GrabIncomingData';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161904,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203161904, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #1 --------- GRAB the INCOMING DATA and Record the Networking information we need.
  //-----------------------------------------------------------------------------------------
  //ASPrintLn('TWORKER.GrabIncomingData ENTER');
  if (NOT bInternalJob)then
  begin
    self.Context.rJSession.JSess_IP_ADDR:=NetAddrToStr(in_addr(self.Connectionsocket.RemoteSin.sin_addr));
    self.Context.rJSession.JSess_PORT_u:=inttostr(self.Connectionsocket.RemoteSin.sin_port);
    self.Context.saServerIP:=grJASConfig.saServerIP;// We do this because future versions may support multiple listening sockets/ip addresses
    self.Context.saServerPort:=inttostr(grJASConfig.u2ServerPort);// We do this because future versions may support multiple listening sockets/ip addresses
  end
  else
  begin
    self.Context.rJSession.JSess_IP_ADDR:='0.0.0.0';
    self.Context.rJSession.JSess_PORT_u:='0';
    self.Context.saServerIP:='0.0.0.0';
    self.Context.saServerPort:='0';
  end;
  //ASPrintLn('TWORKER.GrabIncomingData PORTS Stuff Done');
  self.Context.dtRequested:=now;
  //ASPrintLn('TWORKER.GrabIncomingData  Calling TWORKER.SetErrorReportingModeAndDebugModeFlags');
  self.SetErrorReportingModeAndDebugModeFlags;
  if (NOT bInternalJob) then
  begin
    bReadStop_WaitingDataZero:=false;
    bReadStop_MaxRequestHeaderLength:=false;
    i4PacketCount:=0;
    iRetries:=0;
    //ASPrintLn('TWORKER.GrabIncomingData Repeat loop');
    repeat
      saPacketData:='';
      saPacketData:=self.ConnectionSocket.RecvPacket(grJASConfig.iSocketTimeOutInMSec);
      if length(saPacketdata)>0 then
      begin
        i4PacketCount+=1;
        iRetries:=0;
      end;
      self.Context.saIN+=saPacketData;
      {$IFDEF DIAGMSG}
      JASPrintln('length(self.Context.saIN):'+inttostr(length(self.Context.saIN)));
      {$ENDIF}
      while (not bReadStop_WaitingDataZero) and (self.ConnectionSocket.WaitingData=0) do
      begin
        sleep(25);
        iRetries+=1;
        if iRetries>20 then bReadStop_WaitingDataZero:=true;
      end;

      if not bMultipart then
      begin
        bMultiPart:=(pos('Content-Type: multipart/form-data;',self.Context.saIN)>0) or 
                    (pos('CONTENT_TYPE=multipart/form-data;',self.Context.saIN)>0);
      end;

      bReadStop_MaxRequestHeaderLength:=(length(self.Context.saIN)>grJASConfig.i8MaximumRequestHeaderLength);
    until (bReadStop_WaitingDataZero) or (bReadStop_MaxRequestHeaderLength);
    //ASPrintLn('TWORKER.GrabIncomingData Repeat loop Finished');
    if bReadStop_MaxRequestHeaderLength then
    begin
      //ASPrintLn('TWORKER.GrabIncomingData MaxRequestHeaderLength Exceeded');
      JAS_Log(Context,cnLog_Error,201204080927,'MaxRequestHeaderLength ('+inttostr(grJASConfig.i8MaximumRequestHeaderLength)+') EXCEEDED!','',sourcefile);
    end;

    //ASPrintLn('TWORKER.GrabIncomingData Setting Bytes REad');
    self.Context.u8BytesRead:=length(self.Context.saIN);

    //AS_Log(Context,cnLog_Debug,201204080927,'Bytes Read In: '+inttostr(self.Context.u8BytesRead)+csCRLF+self.Context.saIN+csCRLF,'',sourcefile);
  end;
  //JAS_LOG(Context, cnLog_ebug, 201203312222, 'Multi-Part: '+ saYesNo(bMultiPart)+' Incoming Data Begin:'+self.Context.saIN+':END Incoming.','',SOURCEFILE);
  //-----------------------------------------------------------------------------------------
  //PART #1 --------- GRAB the INCOMING DATA and Record the Networking information we need.
  //-----------------------------------------------------------------------------------------
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161905,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















//=============================================================================
procedure TWorker.ParseAndVerifyGoodremoteAddress;
//=============================================================================
var
  i: longint;
  bGotOne: boolean;
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWorker.ParseAndVerifyGoodremoteAddress';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161910,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203161910, sTHIS_ROUTINE_NAME);{$ENDIF}


  //-----------------------------------------------------------------------------------------
  //PART #2 ---------- Parse the Request and See what the Client is asking for
  //-----------------------------------------------------------------------------------------
  {$IFDEF DIAGMSG}
  //ASPrintln('Part 2 Enter - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  if (self.Context.CGIENV.iHTTPResponse=0) and (not Context.bInternalJob) then
  begin
    self.ParseRequest;
  end;


  {$IFDEF DIAGMSG}
  //ASPrintln('Part 2 Exit - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  //-----------------------------------------------------------------------------------------
  //PART #2 ---------- PArse the Request and See what the Client is asking for
  //-----------------------------------------------------------------------------------------



  //-----------------------------------------------------------------------------------------
  //----- The Part 2.5 Wedge :)
  // If the Request coming in is a JAS-CGI request, then turn that request into a local request.
  //-----------------------------------------------------------------------------------------
  //ASPrintln('JAS Wedge');
  if self.Context.CGIENV.iHTTPResponse = 0  then
  begin
    if self.Context.REQVAR_XDL.FoundItem_saName(csCGI_JEGAS,true) then
    begin
      self.Context.bJASCGI:=true;
      if self.Context.REQVAR_XDL.Item_saValue<>csCGI_JEGAS_CGI_1_0_0 then
      begin
        self.Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_412;// Pre Condition Failed (Version Not Supported)
      end;

      if self.Context.CGIENV.iHTTPResponse = 0  then
      begin
        self.ParseJASCGI;
        {$IFDEF DIAGMSG}
        JASPrintLn(self.Context.CGIENV.saPostData);
        {$ENDIF}
      end;
    end;
  end;
  //ASPrintln('JAS Wedge Complete');
  //-----------------------------------------------------------------------------------------
  //----- The Part 2.5 Wedge :)
  // If the Request coming in is a JAS-CGI request, then turn that request into a local request.
  //-----------------------------------------------------------------------------------------


  //-----------------------------------------------------------------------------------------
  //PART #3 ---------- See IF the client has been black or white listed before we waste time
  //        We actually let Internal Jobs go through this filter because it is ONE way to
  //        prevent or ONLY AUTHORIZE internal jobs to run on the server.
  //-----------------------------------------------------------------------------------------
  //ASPrintln('WhiteList');
  if grJASConfig.bWhiteListEnabled then
  begin
    if length(garJIPListLight)>0 then
    begin
      bGotOne:=false;
      for i:=0 to length(garJIPListLight)-1 do
      begin
        bGotOne:=(garJIPListLight[i].u1IPListType=cnJIPListLU_WhiteList) and
                 (garJIPListLight[i].saIPAddress=self.Context.rJSession.JSess_IP_ADDR);
        if bGotOne then break;
      end;
      if not bGotOne then
      begin
        self.Context.CGIENV.iHTTPResponse:=403; // Forbidden
        JAS_LOG(Context, cnLog_Warn, 201208182126, 'White List Prevented: '+self.Context.rJSession.JSess_IP_ADDR,'',SOURCEFILE);
      end;
    end;
  end;
  //ASPrintln('WhiteList Complete');

  //ASPrintln('BlackList');
  if grJASConfig.bBlackListEnabled and (self.Context.CGIENV.iHTTPResponse=0) then
  begin
    if length(garJIPListLight)>0 then
    begin
      bGotOne:=false;
      for i:=0 to length(garJIPListLight)-1 do
      begin
        bGotOne:=(garJIPListLight[i].u1IPListType=cnJIPListLU_BlackList) and
                 (garJIPListLight[i].saIPAddress=self.Context.rJSession.JSess_IP_ADDR);
        if bGotOne then break;
      end;
      if bGotOne then
      begin
        self.Context.CGIENV.iHTTPResponse:=403; // Forbidden
        JAS_LOG(Context, cnLog_Warn, 201208182127, 'Black List Prevented: '+self.Context.rJSession.JSess_IP_ADDR,'',SOURCEFILE);
      end;
    end;
  end;
  //ASPrintln('BlackList Complete');
  //-----------------------------------------------------------------------------------------
  //PART #3 ---------- See IF the client has been black or white listed before we waste time
  //-----------------------------------------------------------------------------------------
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161911,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


























//=============================================================================
Procedure TWORKER.VirtualHostTranslation;
//=============================================================================
var
  i: Longint;
  sa: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.VirtualHostTranslation';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161913,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintln('-----------------');
  //-----------------------------------------------------------------------------------------
  //PART #4 ---------- Virtual HOST translation
  //-----------------------------------------------------------------------------------------
  {$IFDEF DIAGMSG}
  JASPrintln('Part 4 Enter - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    // NOTE: This part of some ugly debugging trying to get PHP-CGI to work correctly.
    // Almost got it too - sessions would save, but would never reload right.. still open
    // issue as of 2009-07-28. That Plus writing a JAS "Mod_Rewrite" module SHOULD get
    // this server capable of running almost anything I believe. FreePascal DOES HAVE
    // a Regular Expression Library which might help quite a bit on that endeavor should
    // I undertake it... So Anyways... This is ugly but it's in use elsewhere ATM.
    // Note also this is related to the various issues surrounding many a bug report or
    // complain about apache and php - the PATH_TRANSLATED and PATH_INFO, and SCRIPT_NAME
    // and SCRIPT_FILENAME not returning information people wanted.. like WHERE is the
    // FILE EXACTLY? Like REALLY? I solved this issue for jas-cgi on linux by using a
    // symlink where alias was used in apache config - just to make
    // DOCUMENT_ROOT + PATH_INFO = filename of script file.. anyways.. back to it...
    self.Context.saOriginallyRequestedFile:=self.Context.saRequestedFile;
    {$IFDEF DIAGMSG} 
    jASPrintln('worker-vhost self.Context.saOriginallyRequestedFile: '+self.Context.saOriginallyRequestedFile);
    {$ENDIF}
    // VIRTUAL HOST TRANSLATED TO DIRECTORY
    self.Context.saRequestedHost:=self.Context.REQVAR_XDL.Get_saValue('HTTP_HOST');
    if length(garJVHostLight)>0 then
    begin
      sa:=upcase(self.Context.saRequestedHost);
      {$IFDEF DIAGMSG}
      JASDebugPrintln('Requested Host: '+sa);
      {$ENDIF}
      
      for i:=0 to length(garJVHostLight)-1 do
      begin
        {$IFDEF DIAGMSG}
        JASDebugPrintln('Testing vHost: '+upcase(garJVHostLight[i].saServerDomain)+' = '+sa);
        {$ENDIF}
        if upcase(garJVHostLight[i].saServerDomain)=sa then
        begin
          self.Context.i4VHost:=i;
          self.Context.saRequestedDir:=garJVHostLight[i].saWebRootDir;
          {$IFDEF DIAGMSG}
            jasDebugPRintln('self.Context.saRequestedDir: '+self.Context.saRequestedDir);
            jASPrintln('uj_worker - self.Context.saRequestedDir:=garJVHostLight['+inttostr(i)+'].saWebRootDir:'+self.Context.saRequestedDir);
          {$ENDIF}
          self.Context.saLogfile:=garJVHostLight[i].saAccessLog;
          break;
        end;
      end;
    end;

    // VIRTUAL HOST as Subdirectory MECHANISM
    self.Context.saRequestedHost:=self.Context.REQVAR_XDL.Get_saValue('HTTP_HOST');
    if length(garJVHostLight)>0 then
    begin
      sa:=upcase(self.Context.saRequestedFile);
      sa:=saSNRStr(sa,'/','');
      for i:=0 to length(garJVHostLight)-1 do
      begin
        //asdebugprintln('a:' + garJVHostLight[i].saServerDomain + ' b: '+sa);
        if upcase(garJVHostLight[i].saServerDomain)=sa then
        begin
          //asDebugPrintln('got vhost: '+ inttostr(i)+' '+garJVHostLight[i].saServerIdent );
          self.Context.i4VHost:=i;
          self.Context.saRequestedDir:=garJVHostLight[i].saWebRootDir;
          //ASPrintln('uj_worker2 - self.Context.saRequestedDir:=garJVHostLight['+inttostr(i)+'].saWebRootDir:'+self.Context.saRequestedDir);          
          
          //asDebugPRintln('self.Context.saRequestedDir: '+self.Context.saRequestedDir);
          self.Context.saLogfile:=garJVHostLight[i].saAccessLog;
          break;
        end;
      end;
    end;
    
    
    
    
    
    
    
    // If Virtual Host Entry Not Found Via Request, use default.
    If  self.Context.saRequestedDir='' Then
    Begin
      if length(garJVHostLight)>0 then
      begin
        for i:=0 to length(garJVHostLight)-1 do
        begin
          //ASPrintln('VHOST - DEFAULT CHECK: '+upcase(self.Context.saRequestedHost));
          if 'DEFAULT'=upcase(garJVHostLight[i].saServerDomain) then           //upcase(self.Context.saRequestedHost) then
          begin
            //ASDebugPrintln('VHOST - Found and went with DEFAULT!: '+inttostr(i));
            self.Context.i4VHost:=i;
            self.Context.saRequestedDir:=garJVHostLight[i].saWebRootDir;
            //ASPrintln('uj_worker3 - self.Context.saRequestedDir:=garJVHostLight['+inttostr(i)+'].saWebRootDir:'+self.Context.saRequestedDir);            
            self.Context.saLogfile:=garJVHostLight[i].saAccessLog;
            //asDebugPrintln('self.Context.saRequestedDir: '+self.Context.saRequestedDir);
            break;
          end;
        end;
      end;
    End;
    Context.saLang:=garJVHostLight[Context.i4VHost].saDefaultLanguage;
    Context.saRequestedHostRootDir:=Context.saRequestedDir;//because alias below can "change" this

    if not garJVHostLight[Context.i4VHost].bIdentOk then
    begin
      Context.saPage:=saGetPage(Context,'sys_area_bare','sys_jasident','MAIN',false,'',201210211315);
      //self.Context.CGIENV.iHTTPResponse:=200;
    end;
    //ASPrintln('VirtualHostTranslation: '+garJVHostLight[Context.i4VHost].saServerDomain);
  end;
  //-----------------------------------------------------------------------------------------
  //PART #4 ---------- Virtual HOST translation
  //-----------------------------------------------------------------------------------------
  //ASPrintln('END - VirtualHostTranslation');
  //ASPrintln('-----------------');
  //ASPrintln('');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161914,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


























//=============================================================================
Procedure TWORKER.TranslateRequestToFilename;
//=============================================================================
var
  iPosSlash: Integer;
  i,t: Longint;
  saCompareThis: ansistring;
  saUp: ansistring;
  bAliasHost: boolean;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.TranslateRequestToFilename';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161915,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #5 ---------- Resolve File REQUEST to actual Filename
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    bAliasHost:=false;
    if length(garJAliasLight)>0 then
    begin
      //ASPrintln('self.Context.saOriginallyRequestedFile: '+self.Context.saOriginallyRequestedFile);
      //ASPrintLn('self.Context.saRequestedFile: '+self.Context.saRequestedFile);
      iPosSlash:=pos('/',self.Context.saRequestedFile);
      if iPosSlash>1 then // <>0
      begin
        saCompareThis:=saLeftStr(self.Context.saRequestedFile,iPosSlash);
      end
      else
      begin
        saComparethis:=self.Context.saRequestedFile;
      end;
      if saLeftstr(saCompareThis,1)<>'/' then saCompareThis:='/'+saComparethis;
      for i:=0 to length(garJAliasLight)-1 do
      begin
        //ASPrintln('Alias: '+garJAliasLight[i].saAlias+' = '+saCompareThis);
        if ( garJAliasLight[i].saAlias     = saCompareThis ) then
        begin
          //ASPrintln('Found: '+garJAliasLight[i].saAlias);
          if garJAliasLight[i].bVHost then
          begin
            //ASPrintln('Is VHOST! '+garJAliasLight[i].saAlias+' VHosts: '+inttostr(length(garJVHostLight)));
            for t:=0 to length(garJVHostLight)-1 do
            begin
              //ASPrintln('Try to connect alias and vhost: '+inttostr(garJAliasLight[i].u8JVHost_ID)+' = '+inttostr(garJVHostLight[t].u8JVHost_UID));
              if garJAliasLight[i].u8JVHost_ID = garJVHostLight[t].u8JVHost_UID then
              begin
                //ASPrintln('VHOST AND MAIN Alias are Connected! '+garJVHostLight[t].saServerDomain+' and '+garJAliasLight[i].saAlias);
                self.Context.i4VHost:=t;
                //self.Context.saRequestedDir:=garJVHostLight[t].saWebRootDir;
                self.Context.saRequestedDir:=garJAliasLight[i].saPath;
                
                //ASPrintln('uj_worker5 - self.Context.saRequestedDir:=garJVHostLight['+inttostr(t)+'].saWebRootDir:'+self.Context.saRequestedDir);
                //ASPrintln('self.Context.saRequestedDir after assign: '+self.Context.saRequestedDir);
                // For the VHost+Alias combo - we want to use VHOST as the source of the Path
                //self.Context.saRequestedDir:=garJAliasLight[i].saPath;

                self.Context.saLogfile:=garJVHostLight[t].saAccessLog;
                self.Context.saAlias:=garJAliasLight[i].saAlias;
                //self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-iPosSlash);
                self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-length(self.Context.saAlias)+1);
                //asprintln('worker-diceup - after worker-alias dice up: ' + self.Context.saRequestedFile);
                
                
                
                
                bAliasHost:=true;
                break;
              end;
            end;
          end
          else
          begin
            if ( garJAliasLight[i].u8JVHost_ID = garJVHostLight[Context.i4VHost].u8JVHost_UID) then
            begin
              //ASPrintln('CURRENT vHost and Alias Connected');
              self.Context.saRequestedDir:=garJAliasLight[i].saPath;
              //ASPrintln('uj_worker6 - self.Context.saRequestedDir:=garJAliasLight['+inttostr(t)+'].saPath:'+self.Context.saRequestedDir);
              self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-iPosSlash);
              //ASPrintln('self.Context.saRequestedDir after assign: '+self.Context.saRequestedDir);
              //self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-length(garJAliasLight[i].saAlias));
              break;
            end;
          end;
        end;
      end;

      self.Context.saServerURL:=garJVHostLight[Context.i4VHost].saServerDomain;
      saUP:=upcase(self.Context.saServerURL);
      
      if (saUP='DEFAULT') or (bAliasHost) then
      begin
        self.Context.saServerURL:=grJASConfig.saServerURL;
      end else

      if garJVHostLight[Context.i4VHost].bEnableSSL then
      begin
        self.Context.saServerURL:='https://'+self.Context.saServerURL;
        if garJVHostLight[Context.i4VHost].u2ServerPort<>443 then
        begin
          self.Context.saServerURL+=':'+inttostr(garJVHostLight[Context.i4VHost].u2ServerPort);
        end;
      end
      else
      begin
        self.Context.saServerURL:='http://'+self.Context.saServerURL;
        if garJVHostLight[Context.i4VHost].u2ServerPort<>80 then
        begin
          self.Context.saServerURL+=':'+inttostr(garJVHostLight[Context.i4VHost].u2ServerPort);
        end;
      end;
    end;

    {$IFDEF DIAGMSG}
    JASPrintln('Before Fixup-----------------------');
    JASPrintln('Dir:'+self.Context.saRequestedDir);
    JASPrintln('File:'+self.Context.saRequestedFile);
    JASPrintln('Orig:'+self.Context.saOriginallyRequestedFile);
    {$ENDIF}
    iReqOrigLength:=length(self.Context.saOriginallyRequestedFile);
    iReqFileNameLength:=length(self.Context.saRequestedFile);
    self.Context.saRequestedFile:=saReverse(self.Context.saRequestedFile);
    
    iPosSlash:=pos('/',self.Context.saRequestedFile);
    If(iposslash>0)Then
    Begin
      self.Context.saRequestedDir+=saReverse(copy(self.Context.saRequestedFile,iPosSlash,iReqFileNameLength));
      deletestring(self.Context.saRequestedFile,iPosSlash,iReqFileNameLength);
      self.Context.saRequestedFile:=saReverse(self.Context.saRequestedFile);
    End
    else
    begin
      self.Context.saRequestedFile:=saReverse(self.Context.saRequestedFile);
    end;
    //self.Context.saRequestedDir:=saSNRSTR(self.Context.saRequestedDir,csDOSSLASH+csDOSSLASH,#0);
    //self.Context.saRequestedDir:=saSNRSTR(self.Context.saRequestedDir,#0,csDOSSLASH);
    bReqDirExist:= DirectoryExists(self.Context.saRequestedDir);
    saDirNFile:=self.Context.saRequestedDir+self.Context.saRequestedFile;
    bDirNFileExist:=FileExists(saDirNFile);
    bReqFileIsFile:=(bDirNFileExist and (not DirectoryExists(saDirNFile)));

    {$IFDEF DIAGMSG}
      JASPrintLn(sTHIS_ROUTINE_NAME +': After Fixup-----------------------');
      JASPrintLn(sTHIS_ROUTINE_NAME +': self.Context.saRequestedDir:'+self.Context.saRequestedDir);
      JASPrintLn(sTHIS_ROUTINE_NAME +': bReqDirExist:'+sayesno(bReqDirExist));
      JASPrintLn(sTHIS_ROUTINE_NAME +': self.Context.saRequestedFile: '+self.Context.saRequestedFile);
      JASPrintLn(sTHIS_ROUTINE_NAME +': bDirNFileExist:'+saYesNo(bDirNFileExist));
      JASPrintLn(sTHIS_ROUTINE_NAME +': bReqFileIsFile:'+saYesNo(bReqFileIsFile));
    {$ENDIF}
  end;
  //-----------------------------------------------------------------------------------------
  //PART #5 ---------- Resolve File REQUEST to actual Filename
  //-----------------------------------------------------------------------------------------
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161916,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



















//=============================================================================
Procedure TWORKER.CheckIfTrailSlashOrRedirect;
//=============================================================================
var sa: ansistring;
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.CheckIfTrailSlashOrRedirect';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161917,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  //ASPrintln('-----------------');
  //ASPrintln('Enter - CheckIfTrailSlashOrRedirect - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  //-----------------------------------------------------------------------------------------
  //PART #6 ---------- Is a redirection needed? Like lack of a trailing slash on a directory?
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    {$IFDEF DIAGMSG}
    JASPrintln('iReqOrigLength:'+inttostr(iReqOrigLength));
    JASPrintln('bDirNFileExist:'+saTRueFalse(bDirNFileExist));
    JASPrintln('bReqDirExist:'+saTrueFalse(bReqDirExist));
    JASPrintln('bReqFileIsFile:'+saTrueFalse(bReqFileIsFile));
    JASPrintln('saRequestedHost:'+self.Context.saRequestedHost);
    {$ENDIF}

    If (iReqOrigLength>0) and
    (not bDirNFileExist) and
    (not bReqFileIsFile) and
    (bReqDirExist) then
    //(pos('.',self.Context.saRequestedFile)=0) then
    Begin
      self.Context.saRequestedDir+= self.Context.saRequestedFile;// + grJASConfig.saDirectoryIndexFile;
      self.Context.saRequestedFile:='';
      //If saRightStr(self.Context.saRequestedDir,1)<>'/' Then
      If saRightStr(self.Context.saRequestedDir,1)<>csDOSSLASH Then
      Begin
        // Ok Here - we have a request, that is a directory only and it DOES NOT
        // have the trailing slash. This makes the Browser make the assumption
        // the last part of text is a file, not a directory, and all subsequent
        // "relative" path requests - say:   ./img/somepic.jpg get hosed:
        // www.myweb.com   <---Comes In... we get Here. Then
        // subequent browser relative path requests for things end up looking
        // like this: www.myweb/img/somepic.jpg   THIS IS WRONG!
        // How do we fix? We give the browser a redirect to the SAME URL
        // with a slash appended to the end. Then the browser won't be hosed.
        {IFDEF DIAGMSG}
        //ASPrintln('REDIRECTION FROM:'+self.Context.saOriginallyRequestedFile+csCRLF);
        {ENDIF}
        if saRightStr(self.Context.saOriginallyRequestedFile,1)<>'/' then
        begin
          self.Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_307;//temporary redirect
          sa:=self.Context.saOriginallyRequestedFile+'/';
          if saLeftStr(sa,1)<>'/' then sa:='/'+sa;
          self.Context.CGIENV.Header_Redirect(sa,garJVHostLight[Context.i4VHost].saServerIdent);
          //if self.Context.saOriginallyRequestedFile='' then
          //begin
          //  ASPrintln('REDIRECT Original Requested File');
          //  self.Context.CGIENV.Header_Redirect('/'+self.Context.saOriginallyRequestedFile+'/');
          //end
          //else
          //begin
          //  ASPrintln('REDIRECT SLASH');
          //  self.Context.CGIENV.Header_Redirect('/');
          //end;
        end;
      End;
      //else
      //begin
      //  ASPrintln('Redirection Failed Second IF');
      //end;
    End;
    //else
    //begin
    //  ASPrintln('Redirection Failed First IF');
    //end;
  end;
  //ASPrintln('END - CheckIfTrailSlashOrRedirect');
  //ASPrintln('-----------------');
  //ASPrintln('');
  //-----------------------------------------------------------------------------------------
  //PART #6 ---------- Is a redirection needed? Like lack of a trailing slash on a directory?
  //-----------------------------------------------------------------------------------------

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161918,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



























//=============================================================================
procedure TWORKER.ResolveDefaultFileIfNoneGiven;
//=============================================================================
var
  iX: longint;
  saIndexFileName: ansistring;
//  sa: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.ResolveDefaultFileIfNoneGiven';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161919,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #7 ---------- Figure out Default File (Directory Index) if filename not given
  //-----------------------------------------------------------------------------------------
  //ASPrintln('-----------------');
  //ASPrintln('ENTER - ResolveDefaultFileIfNoneGiven - HttpResponse:'+inttostr(self.Context.CGIENV.iHTTPResponse));
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    //ASPrintln('ResolveDefaultFileIfNoneGiven req File: '+self.Context.saREquestedFile);
    If (self.Context.saREquestedFile='/') or (self.Context.saREquestedFile='//') Then self.Context.saREquestedFile:='';
    //If self.Context.saREquestedFile='/' Then self.Context.saREquestedFile:='';
    If self.Context.saREquestedFile='' Then
    Begin
      // TRY to find existing DIRECTORYINDEXMATRIX file
      //SPRintln('Testing whether to look for index file. indexfiles:'+inttostr(length(garJIndexFileLight)));
      //ASPrintln('Context.i4VHost:'+inttostr(Context.i4VHost)+' (Context.i4VHost<=(length(garJVHostLight)-1):'+satrueFalse((Context.i4VHost<=(length(garJVHostLight)-1))));
      If (length(garJIndexFileLight)>0) and (Context.i4VHost>-1) and (Context.i4VHost<=(length(garJVHostLight)-1)) then
      Begin
        {$IFDEF DIAGMSG}
        JASPrint('We have '+inttostr(length(garJIndexFileLight))+' garJIndexFileLight(s) to search'+csCRLF);
        {$ENDIF}
        ix:=0;
        repeat
          if garJIndexfileLight[iX].u8JVHost_ID=garJVHostLight[Context.i4VHost].u8JVHost_UID then
          begin
            saIndexFileName:=self.Context.saRequestedDir + garJIndexfileLight[iX].saFilename;
            {$IFDEF DIAGMSG}
              JASPrintln(sTHIS_ROUTINE_NAME+': Checking for Index file:<BOL>'+saIndexFilename+'<EOL>');
              JASPrintln(sTHIS_ROUTINE_NAME+': saRequestedDir:<BOL>'+self.Context.saRequestedDir+'<EOL>');
              JASPrintln(sTHIS_ROUTINE_NAME+': garJIndexfileLight[iX].saFilename:<BOL>'+garJIndexfileLight[iX].saFilename+'<EOL>');
            {$ENDIF}
            If FileExists(saIndexFilename) Then
            Begin
              self.Context.saRequestedFile:=garJIndexfileLight[iX].saFilename;
              {$IFDEF DIAGMSG}
                jASPrintln(sTHIS_ROUTINE_NAME+': index file hunt - FOUND IT!:'+garJIndexfileLight[iX].saFilename);
                jasprintln(sTHIS_ROUTINE_NAME+': '+self.Context.saRequestedDir);
                jasprintln(sTHIS_ROUTINE_NAME+': Tested for this file: '+saIndexFilename+' And found it');
              {$ENDIF}
            End
            Else
            Begin
              {$IFDEF DIAGMSG}
              JASPrint(sTHIS_ROUTINE_NAME+': index file hunt - Not there :'+saIndexFileName+csCRLF);
              {$ENDIF}
            End;
          end;
          ix+=1;
        Until (self.Context.saRequestedFile<>'') OR (ix>=length(garJIndexFileLight));
        if(ix=length(garJIndexFileLight))then //qqq
        begin
          saIndexFileName:='[NO INDEX FILE EXISTS]';
          //ASPrintln('INDEX HUNT FAILED ix:'+inttostr(ix)+' length(garJIndexFileLight): '+ inttostr(length(garJIndexFileLight)));
          if bReqDirExist then
          begin
            //ASPrintln('Requested DIR Exists. garJVHostLight[Context.i4VHost].bDirectoryListing: '+saYesNo(garJVHostLight[Context.i4VHost].bDirectoryListing));
            if garJVHostLight[Context.i4VHost].bDirectoryListing then
            begin
              //ASPrintln('Calling Directory Listing');
              DirectoryListing;
            end;
            //else
            //begin
            //  //ASPrintln('Directory Listing not allowed');
            //end;
          end
          else
          begin
            JAS_Log(Context,cnLog_WARN,201012291442,'Requested Dir not found:'+self.Context.saRequestedDir,'',sourcefile);
            self.Context.CGIENV.iHTTPResponse:=404;
          end;
        End;
        //else
        //begin
        //  ASPRintln('No DIR List Check. ix: '+inttostr(ix)+' length(garJIndexFileLight):'+inttostr(length(garJIndexFileLight)));
        //end;
      end
      else
      begin
        //config mishap likely
        //ASPrintln('Forcing index.jas because no index files, i4VHost=1 or i4VHost>array bounds');
        saIndexFileName:=self.Context.saRequestedDir + 'index.jas';
        If FileExists(saIndexFilename) Then
        begin
          self.Context.saRequestedFile:='index.jas';
        end
        else
        begin
          if bReqDirExist then
          begin
            if grJASConfig.bDirectoryListing then DirectoryListing;
          end;
        end;
        {$IFDEF DIAGMSG}
          JASPrintln('------------------------------------------------------');
          JASPrintln('JIndexFile / VHost Config Issue - attempting to use index.jas for default');
          JASPrintln('saIndexFileName: '+ saIndexFileName);
          JASPrintln('------------------------------------------------------');
        {$ENDIF}
      end;
    End;
  end;
  //-----------------------------------------------------------------------------------------
  //PART #7 ---------- Figure out Default File (Directory Index) if filename not given
  //-----------------------------------------------------------------------------------------
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161920,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================























//=============================================================================
procedure TWORKER.CleanUpAndVerifyCompleteFilename;
//=============================================================================
var
  i: longint;
  //sa: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.CleanUpAndVerifyCompleteFilename';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161921,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //ASPrintln('BEGIN PART #8 ---------- Clean up the filename and disallow backward relative paths');
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    {$IFDEF DIAGMSG}
    JASPrintln(sTHIS_ROUTINE_NAME+':After Adding a Default File if necessary');
    JASPrintln(sTHIS_ROUTINE_NAME+':Dir:'+self.Context.saRequestedDir);
    JASPrintln(sTHIS_ROUTINE_NAME+':Dir Exists?:'+saYesNo(DirectoryExists(self.Context.saRequestedDir)));
    JASPrintln(sTHIS_ROUTINE_NAME+':file:'+self.Context.saRequestedFile);
    {$ENDIF}

    self.Context.saFileSought:=self.Context.saRequestedDir + self.Context.saRequestedFile;
    self.Context.saFileSought:=saSNR(self.Context.saFileSought,'\','/');

    {$IFDEF DIAGMSG}
    if not FileExists(self.Context.saFileSought) then
    begin
      //ASPrintln(self.context.rjsession.JSess_Remote_IP+' Missing:'+self.Context.saFileSought);
    end;
    {$ENDIF}

    //ASPrintln('PART #8 - BEGIN TOP CHUNK');
    //ASPrintln('PART #8 - A');
    Context.saFileSoughtNoExt:=saFileNameNoExt(self.Context.saFileSought);
    //ASPrintln('PART #8 - B');
    Context.saFileSoughtExt:=ExtractFileExt(self.Context.saFileSought);
    //ASPrintln('PART #8 - C');
    Context.saFileSoughtExt:=saRightStr(Context.saFileSoughtExt,length(Context.saFileSoughtExt)-1);
    //ASPrintln('PART #8 - D');
    Context.saFileNameOnly:=ExtractFileName(self.Context.saFileSought);
    //ASPrintln('PART #8 - E');
    Context.saFileNameOnlyNoExt:=saLeftStr(Context.saFileNameOnly,length(Context.saFileNameOnly)-length(Context.saFileSoughtExt)-1);
    //ASPrintln('PART #8 - F');

    // Have to stuff the querystring here because translate function parses querystring and passed postdata
    Context.CGIENV.ENVVAR.AppendItem_saName_N_saValue('QUERY_STRING',Context.saQueryString);
    //ASPrintln('PART #8 - G - Translate Param: '+Context.CGIENV.saPostData);
    Context.CGIENV.TranslateParameters(Context.CGIENV.saPostData, Context.REQVAR_XDL.Get_saValue(csCGI_CONTENT_TYPE));
    //ASPrintln('PART #8 - END TOP CHUNK');
    

    //if Context.CGIENV.DataIn.FoundItem_saName('ACTION') then
    //begin
    //  Context.bMimeSNR:=true;
    //  Context.saMimeType:='execute/jegas';
    //  Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    //end else
 
    // See if this is an JASAPI Request
    if(Context.CGIENV.DATAIN.FoundItem_saName('JASAPI',false))then
    begin
      Context.bMimeSNR:=true;
      Context.saMimeType:='execute/jasapi';
      Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    end else

    if(Context.CGIENV.DATAIN.FoundItem_saName('USERAPI',false))then
    begin
      Context.bMimeSNR:=true;
      Context.saMimeType:='execute/userapi';
      Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    end else

    begin
      //ASPrintln('PART #8 - Determine MIME Type');
      // DETERMINE MIME TYPE BASED ON RESOLVED FILE EXTENSION
      if length(garJMimeLight)>0 then
      begin
        for i:=0 to length(garJMimeLight)-1 do
        begin
          if garJMimeLight[i].saName=Context.saFileSoughtExt then
          begin
            Context.saMimeType:=garJMimeLight[i].saType;
            Context.bMimeSNR:=garJMimeLight[i].bSNR;
          end;
        end;
      end;

      bFileSoughtExists:=FileExists(self.Context.saFileSought);// or (length(self.Context.saAction)>0);
      if (not bFileSoughtExists) then
      begin
        //ASPrintln('bFileSoughtExists Failed: '+self.Context.saFileSought);
        Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_404;//not found
        JAS_Log(Context,cnLog_WARN,200912291442,'File Not Found :'+self.Context.saFileSought,'',sourcefile);
      end;
    end;
      //bFileSoughtExists:=FileExists(self.Context.saFileSought) and (self.Context.saRequestedFile<>'');
  end;

  // Make sure they didn't toss in some hopeful hacker backwards relative path gibberish
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    //ASPrintln('PART #8 - Extracting Rel Path');
    If (pos('/../', ExtractRelativepath(self.Context.saRequestedDir, self.Context.saFileSought)) <> 0) then
    begin
      self.Context.CGIENV.iHTTPResponse:=403; // Forbidden
      JAS_LOG(Context, cnLog_Warn, 201208182128, 'Attempt to traverse higher directory: '+
        self.Context.rJSession.JSess_IP_ADDR+' PATH: '+self.Context.saRequestedDir,'',SOURCEFILE);
    end;
  end;
  {$IFDEF DIAGMSG}JASPrintln('Part 8 Exit - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));{$ENDIF}
  //-----------------------------------------------------------------------------------------
  //ASPrintln('END PART #8 ---------- Clean up the filename and disallow backward relative paths');
  //-----------------------------------------------------------------------------------------
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161922,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================















//=============================================================================
procedure TWORKER.DispatchRequest;
//=============================================================================
var
  sVal: string;
  bOk: boolean;
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.DispatchRequest;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161923,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #9 ---------- Prepare for Direct Handling or CGI Invocation (Mime based)
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    if(Context.saMimeType='execute/jasapi')then
    begin
      //PrepareWebBasedJegasApplication(self.Context);
      bJAS_ValidateSession(Context);
      Context.saMimeType:=csMime_TextXML;
      JASAPI_Dispatch(Context);
      Context.CreateIWFXML;
      self.Context.saOut:=self.Context.saPage;
    end else

    if(Context.saMimeType='execute/userapi')then
    begin
      //PrepareWebBasedJegasApplication(Context);
      bJAS_ValidateSession(Context);
      Context.saMimeType:=csMime_TextXML;
      UserAPI_Dispatch(Context);
      Context.CreateIWFXML;
      self.Context.saOut:=self.Context.saPage;
    end
    else

    if(Context.saMimeType='execute/jegas')then
    begin
      //PrepareWebBasedJegasApplication(Context);
      //ASPrintln('EXECUTING JAS APPLICATION');
      bJAS_ValidateSession(Context);
      // BEGIN -------------------------  Send Out Cookies for User Preferences
      if Context.bSessionValid then
      begin
        //   2012102114260173351   Headers Off
        if not Context.CGIENV.CKYIN.FoundItem_saName('JASDISPLAYHEADERS') then
        begin
          if not bVal(saJASUserPref(Context,bOk,2012102114260173351,u8Val(Context.rJSession.JSess_JUser_ID))) then sVal:='on' else sVal:='off';
          Context.CGIENV.AddCookie(
            'JASDISPLAYHEADERS',
            sVal,
            Context.CGIENV.saRequestURIWithoutParam,
            dtAddMonths(now,1),
            false
          );
        end;

        //   2012102114270325598   Quick-Links
        if not Context.CGIENV.CKYIN.FoundItem_saName('JASDISPLAYQUICKLINKS') then
        begin
          if not bVal(saJASUserPref(Context,bOk,2012102114270325598,u8Val(Context.rJSession.JSess_JUser_ID))) then sVal:='on' else sVal:='off';
          Context.CGIENV.AddCookie(
            'JASDISPLAYQUICKLINKS',
            sVal,
            Context.CGIENV.saRequestURIWithoutParam,
            dtAddMonths(now,1),
            false
          );
        end;

        //   2012102114273212996   Color Theme
        if not Context.CGIENV.CKYIN.FoundItem_saName('JASCOLORTHEME') then
        begin
          sVal:=saJASUserPref(Context,bOk,2012102114273212996,u8Val(Context.rJSession.JSess_JUser_ID));
          if sVal<>'' then
          begin
            Context.CGIENV.AddCookie(
              'JASCOLORTHEME',
              sval,
              Context.CGIENV.saRequestURIWithoutParam,
              dtAddMonths(now,1),
              false
            );
          end;
        end;

        //   2012102114480970555   Icon Theme
        if not Context.CGIENV.CKYIN.FoundItem_saName('JASICONTHEME') then
        begin
          sVal:=saJASUserPref(Context,bOk,2012102114480970555,u8Val(Context.rJSession.JSess_JUser_ID));
          if sVal<>'' then
          begin
            Context.CGIENV.AddCookie(
              'JASICONTHEME',
              sVal,
              Context.CGIENV.saRequestURIWithoutParam,
              dtAddMonths(now,1),
              false
            );
          end;
        end;
      end;
      // END -------------------------  Send Out Cookies for User Preferences
      
      ExecuteJASApplication(Context);
      if self.Context.CGIENV.iHTTPResponse=0 then self.Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;
      self.Context.saOut:=self.Context.saPage;
      //ASPrintLn('u01j_worker - back from ExecuteJASApplication. PageLen:'+inttostR(length(self.Context.saPage)));
    end
    else

    if(Context.saMimeType='execute/cgi')then
    begin
      ExecuteCGI(Context);// Sets p_Context.CGIENV.iHTTPResponse accordingly.
      //AS_LOG(Context, cnLog_Debug, 201007281330,'Back from ExecuteCGI call','',SOURCEFILE);
    end
    else
    
    if(Context.saMimeType='execute/php')then
    begin
      Context.bMIME_execute_PHP:=true;
      ExecuteCGI(Context);// Sets p_Context.CGIENV.iHTTPResponse accordingly.
    end
    else
    
    if(Context.saMimeType='execute/perl')then
    begin
      Context.bMIME_execute_Perl:=true;
      ExecuteCGI(Context);// Sets p_Context.CGIENV.iHTTPResponse accordingly.
    end
    else
    
    if bFileSoughtExists then
    begin
      self.Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;//ok
      self.Context.saOut:=getfile(self.Context, self.Context.saFileSought, self.Context.CGIENV.iHTTPResponse);
    end;
    
  End;
  {$IFDEF DIAGMSG}
  JASPrintln(sTHIS_ROUTINE_NAME+': Part 9 Exit - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  //-----------------------------------------------------------------------------------------
  //PART #9 ---------- Prepare for Direct Handling or CGI Invocation (Mime based)
  //-----------------------------------------------------------------------------------------

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161924,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















{$IFDEF DIAGNOSTIC_LOG}
//=============================================================================
procedure TWORKER.DiagnosticLog;
//=============================================================================
var
  bOk: Boolean;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.OnTerminate;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161925,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  JASDebugPrintln(sThis_routine_name+' :Writing to diagnostic log:'+grJASConfig.saDiagnosticLogFileName);
  if bTSOpenTextFile(grJASConfig.saDiagnosticLogFileName,u2IOResult,FLog,false,true) then
  begin
    ////If IOResult <> 0 Then Rewrite(fl);
    //JASDebugPrintln('diagnostic log: 100');
    Writeln(FLog,'DEBUG LOG ---------------------------------------------BEGIN');
    Writeln(FLog,'Context -------------------------------------BEGIN');
    Writeln(FLog,'Context.bSessionValid                         :',Context.bSessionValid);
    Writeln(FLog,'Context.bErrorCondition                       :',Context.bErrorCondition);
    Writeln(FLog,'Context.u8ErrNo                               :',Context.u8ErrNo);
    Writeln(FLog,'Context.saErrMsg                              :',Context.saErrMsg);
    Writeln(FLog,'Context.saRemoteIP                            :',Context.saRemoteIP);
    Writeln(FLog,'Context.saRemotePort                          :',Context.saRemotePort);
    Writeln(FLog,'Context.saServerIP                            :',Context.saServerIP);
    Writeln(FLog,'Context.saServerPort                          :',Context.saServerPort);
    //Writeln(FLog,'Context.saPage                                :',Context.saPage);
    Writeln(FLog,'Context.saPage                                :','withheld');
    Writeln(FLog,'Context.bLoginAttempt                         :',Context.bLoginAttempt);
    Writeln(FLog,'Context.saLoginMsg                            :',Context.saLoginMsg);
    Writeln(FLog,'Context.PAGESNRXDL                            :Instantiated');
    if self.Context.PAGESNRXDL.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.PAGESNRXDL.NAME:',self.Context.PAGESNRXDL.Item_saName);
        Writeln(FLog,'Context.PAGESNRXDL.DESC:',self.Context.PAGESNRXDL.Item_saDesc);
        Writeln(FLog,'Context.PAGESNRXDL.VALU:',self.Context.PAGESNRXDL.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.PAGESNRXDL.MoveNext;
    end;
    Writeln(FLog,'Context.bRedirection                          :',Context.bRedirection);
    Writeln(FLog,'Context.saPageTitle                           :',Context.saPageTitle);
    Writeln(FLog,'Context.JADOC[0]                              :Instantiated - JADO Enabled');
    Writeln(FLog,'Context.dtRequested                           :',saFormatDateTime(csDATETIMEFORMAT,Context.dtRequested));
    Writeln(FLog,'Context.dtServed                              :',saFormatDateTime(csDATETIMEFORMAT,Context.dtServed));
    Writeln(FLog,'Context.dtFinished                            :',saFormatDateTime(csDATETIMEFORMAT,Context.dtFinished));
    Writeln(FLog,'Context.saLanguage                            :',Context.saLanguage);
    //riteln(FLog,'Context.JMenuDL                               :Instantiated - JADO Installed');
    Writeln(FLog,'Context.bOutputRaw                            :',Context.bOutputRaw);
    Writeln(FLog,'Context.saHTMLRIPPER_Area                     :',Context.saHTMLRIPPER_Area);
    Writeln(FLog,'Context.saHTMLRIPPER_Page                     :',Context.saHTMLRIPPER_Page);
    Writeln(FLog,'Context.saHTMLRIPPER_Section                  :',Context.saHTMLRIPPER_Section);
    Writeln(FLog,'Context.iMenuTopID                            :',Context.iMenuTopID);
    Writeln(FLog,'Context.saUserCacheDir                        :',Context.saUserCacheDir);
    Writeln(FLog,'Context.iErrorReportingMode                   :',Context.iErrorReportingMode);
    Writeln(FLog,'Context.iDebugMode                            :',Context.iDebugMode);
    Writeln(FLog,'Context.bMIME_execute                         :',Context.bMIME_execute);
    Writeln(FLog,'Context.bMIME_execute_Jegas                   :',Context.bMIME_execute_Jegas);
    Writeln(FLog,'Context.bMIME_execute_JegasWebService         :',Context.bMIME_execute_JegasWebService);
    Writeln(FLog,'Context.bMIME_execute_php                     :',Context.bMIME_execute_php);
    Writeln(FLog,'Context.bMIME_execute_perl                    :',Context.bMIME_execute_perl);
    Writeln(FLog,'Context.saMimeType                            :',Context.saMimeType);
    Writeln(FLog,'Context.bMimeSNR:                             :',saTrueFalse(Context.bMimeSNR));
    Writeln(FLog,'Context.saFileSoughtNoExt                     :',Context.saFileSoughtNoExt);
    Writeln(FLog,'Context.saFileSoughtExt                       :',Context.saFileSoughtExt);
    Writeln(FLog,'Context.saFileNameOnly                        :',Context.saFileNameOnly);
    Writeln(FLog,'Context.saFileNameOnlyNoExt                   :',Context.saFileNameOnlyNoExt);
    Writeln(FLog,'Context.saKeyIn                               :', Context.saKeyIn);
    Writeln(FLog,'Context.saKeyOut                              :',Context.saKeyOut);
    //Writeln(FLog,'Context -------------------------------------END');
    Writeln(FLog,'');
    //JASDebugPrintln('diagnostic log: 200');

    //Writeln(FLog,'Context -------------------------------------BEGIN');
    Writeln(FLog,'saIN:',Context.saIN);
    Writeln(flog,'saOUT:','Withheld for your sanitity');
    //Writeln(flog,'saOUT:',Context.saOUT);
    if self.Context.REQVAR_XDL.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.REQVAR_XDL.NAME:',self.Context.REQVAR_XDL.Item_saName);
        Writeln(FLog,'Context.REQVAR_XDL.DESC:',self.Context.REQVAR_XDL.Item_saDesc);
        Writeln(FLog,'Context.REQVAR_XDL.VALU:',self.Context.REQVAR_XDL.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.REQVAR_XDL.MoveNext;
    end;
    Writeln(FLog,'i4BytesRead                                   :',Context.i4BytesRead);
    Writeln(FLog,'i4BytesSent                                   :',Context.i4BytesSent);
    Writeln(FLog,'saRequestedHost                               :',Context.saRequestedHost);
    Writeln(FLog,'saRequestedHostRootDir                        :',Context.saRequestedHostRootDir);
    Writeln(FLog,'saRequestMethod                               :',Context.saRequestMethod);
    Writeln(FLog,'saRequestType                                 :',Context.saRequestType);
    Writeln(FLog,'saRequestedFile                               :',Context.saRequestedFile);
    Writeln(FLog,'saOriginallyREquestedFile                     :',Context.saOriginallyREquestedFile);
    Writeln(FLog,'saRequestedName                               :',Context.saRequestedName);
    Writeln(FLog,'saRequestedDir                                :',Context.saRequestedDir);
    Writeln(FLog,'saFileSought                                  :',Context.saFileSought);
    //Writeln(FLog,'FileFound:',saTRueFalsE(FileExists(Context.saFileSought)));
    Writeln(FLog,'saQueryString                                 :',Context.saQueryString);
    Writeln(FLog,'i4ErrorCode                                   :',inttostr(Context.i4ErrorCode));
    Writeln(FLog,'saLogFile                                     :',Context.saLogFile);
    Writeln(FLog,'bJASCGI (only true if JAS proxy req)          :',saTrueFalse(Context.bJASCGI));
    if self.Context.XML.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.XML.NAME:',self.Context.XML.Item_saName);
        Writeln(FLog,'Context.XML.DESC:',self.Context.XML.Item_saDesc);
        Writeln(FLog,'Context.XML.VALU:',self.Context.XML.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.XML.MoveNext;
    end;
    if self.Context.CGIENV.ENVVAR.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.ENVVAR.NAME:',self.Context.CGIENV.ENVVAR.Item_saName);
        Writeln(FLog,'Context.CGIENV.ENVVAR.DESC:',self.Context.CGIENV.ENVVAR.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.ENVVAR.VALU:',self.Context.CGIENV.ENVVAR.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.ENVVAR.MoveNext;
    end;
    if self.Context.CGIENV.DATAIN.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.DATAIN.NAME:',self.Context.CGIENV.DATAIN.Item_saName);
        Writeln(FLog,'Context.CGIENV.DATAIN.DESC:',self.Context.CGIENV.DATAIN.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.DATAIN.VALU:',self.Context.CGIENV.DATAIN.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.DATAIN.MoveNext;
    end;
    if self.Context.CGIENV.CKYIN.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.CKYIN.NAME:',self.Context.CGIENV.CKYIN.Item_saName);
        Writeln(FLog,'Context.CGIENV.CKYIN.DESC:',self.Context.CGIENV.CKYIN.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.CKYIN.VALU:',self.Context.CGIENV.CKYIN.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.CKYIN.MoveNext;
    end;
    if self.Context.CGIENV.CKYOUT.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.CKYOUT.NAME:',self.Context.CGIENV.CKYOUT.Item_saName);
        Writeln(FLog,'Context.CGIENV.CKYOUT.DESC:',self.Context.CGIENV.CKYOUT.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.CKYOUT.VALU:',self.Context.CGIENV.CKYOUT.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.CKYOUT.MoveNext;
    end;
    if self.Context.CGIENV.HEADER.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.HEADER.NAME:',self.Context.CGIENV.HEADER.Item_saName);
        Writeln(FLog,'Context.CGIENV.HEADER.DESC:',self.Context.CGIENV.HEADER.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.HEADER.VALU:',self.Context.CGIENV.HEADER.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.HEADER.MoveNext;
    end;
    //Writeln(FLog,'Context.CGIENV.saCommID                       :',Context.CGIENV.saCommID);
    Writeln(FLog,'Context.CGIENV.bPost                          :',saTrueFalse(Context.CGIENV.bPost));
    Writeln(FLog,'Context.CGIENV.saPostContentType              :',Context.CGIENV.saPostContentType);
    Writeln(FLog,'Context.CGIENV.iPostContentLength             :',inttostr(Context.CGIENV.iPostContentLength));
    Writeln(FLog,'Context.CGIENV.saPostData                     :BEGIN');
    Write(FLog,Context.CGIENV.saPostData);
    Writeln(FLog,'');
    Writeln(FLog,'Context.CGIENV.saPostData                     :END');



    Writeln(FLog,'Context.CGIENV.iTimeZoneOffset                :',inttostr(Context.CGIENV.iTimeZoneOffset));
    Writeln(FLog,'Context.CGIENV.iHTTPResponse                  :',inttostr(Context.CGIENV.iHTTPResponse));
    Writeln(FLog,'Context.CGIENV.saServerSoftware               :',Context.CGIENV.saServerSoftware);


    Writeln(FLog,'saActionType (IWF Specific)                   :',Context.saActionType);
    writeln(FLog,'MATRIX                                        :','Not Implemented in this log');
    writeln(FLog,'ErrorXXDL                                     :','Not Implemented in this log');
    writeln(FLog,'Context.iSessionResultCode                    :',Context.iSessionResultCode);
    writeln(FLog,'Context.rJSession.JSess_JSession_UID          :',Context.rSession.JSess_JSession_UID);
    writeln(FLog,'Context.rJSession.JSess_JSessionType_ID       :',Context.rJSession.JSess_JSessionType_ID);
    writeln(FLog,'Context.rJSession.JUser_JUser_UID             :',Context.rJSession.JUser_JUser_UID);
    writeln(FLog,'Context.rJSession.JUser_Name                  :',Context.rJSession.JUser_Name);
    writeln(FLog,'Context.rJSession.JUser_Password              :',Context.rJSession.JUser_Password);
    writeln(FLog,'Context.rJSession.JSess_IP_ADDR               :',Context.rJSession.JSess_IP_ADDR);
    writeln(FLog,'Context.rJSession.JSess_Connect_DT            :',Context.rJSession.JSess_Connect_DT);
    writeln(FLog,'Context.rJSession.JSess_LastContact_DT        :',Context.rJSession.JSess_LastContact_DT);
    writeln(FLog,'Context.rJSession.JSess_IP_ADDR               :',Context.rJSession.JSess_IP_ADDR);
    writeln(FLog,'Context.rJSession.JSess_Username              :',Context.rJSession.JSess_Username);
    writeln(FLog,'Context.rJUser.JUser_JUser_UID                :',Context.rJUser.JUser_JUser_UID);
    writeln(FLog,'Context.rJUser.JUser_Name                     :',Context.rJUser.JUser_Name);
    writeln(FLog,'Context.rJUser.JUser_Password                 :',Context.rJUser.JUser_Password);
    writeln(FLog,'Context.rJUser.JUser_JPerson_ID               :',Context.rJUser.JUser_JPerson_ID);
    writeln(FLog,'Context.rJUser.JUser_Enabled_b                :',Context.rJUser.JUser_Enabled_b);
    writeln(FLog,'Context.rJUser.JUser_Admin_b                  :',Context.rJUser.JUser_Admin_b);
    writeln(FLog,'Context.rJUser.JUser_Login_First_DT           :',Context.rJUser.JUser_Login_First_DT);
    writeln(FLog,'Context.rJUser.JUser_Login_Last_DT            :',Context.rJUser.JUser_Login_Last_DT);
    writeln(FLog,'Context.rJUser.JUser_Logins_Successful        :',Context.rJUser.JUser_Logins_Successful);
    writeln(FLog,'Context.rJUser.JUser_Logins_Failed            :',Context.rJUser.JUser_Logins_Failed);
    writeln(FLog,'Context.rJUser.JUser_Password_Changed_DT      :',Context.rJUser.JUser_Password_Changed_DT);
    writeln(FLog,'Context.rJUser.JUser_NumAllowedSessions       :',Context.rJUser.JUser_NumAllowedSessions);
    Writeln(FLog,'Context -------------------------------------END');
    Writeln(FLog,'DEBUG LOG ---------------------------------------------END');
    Writeln(FLog,'');
    bTSCloseTextFile(grJASConfig.saDiagnosticLogFileName, u2IOResult, FLOg);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161926,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
{$ENDIF}


















//=============================================================================
Procedure TWORKER.LogRequest;
//=============================================================================
var
  u2IOResult: word;
  dtLog: TDATETIME;// Used by logging code.
  FLog: text;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.LogRequest;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161927,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  if Context.saLogFile<>'' then
  begin
    if bTSOpenTextFile(
      Context.saLogFile,
      u2IOResult,
      FLog,
      false,
      true) then
    begin
      {$I-}
      //127.0.0.1 - -
      Write(FLog,Context.rJSession.JSess_IP_ADDR,' - - ');
      If IOResult=0 Then  //[04/Feb/2007:08:21:23 -0500]
        dtLog:=dtAddHours(Context.dtRequested,grJASConfig.iTIMEZONEOFFSET);
      If IOResult=0 Then
        Write(FLog,'['+JDate('',18,0,dtLog)+' '+saZeroPadInt(grJASConfig.iTIMEZONEOFFSET,2)+'00'+'] ');
      // "GET /robots.txt HTTP/1.0"
      If IOResult=0 Then
        Write(FLog, '"'+Context.REQVAR_XDL.Get_saDesc('REQUEST_METHOD')+'" ');
      If IOResult=0 Then
        Write(FLog,Context.i4ErrorCode,' ');
      If IOResult=0 Then
        Write(FLog,Context.u8BytesSent,' ');
      If IOResult=0 Then
      Begin
        If Context.REQVAR_XDL.Founditem_saName('HTTP_REFERER',True) Then
          Write(FLog, '"'+Context.REQVAR_XDL.Get_saDesc('HTTP_REFERER')+'" ')
        Else
          Write(FLog,'"-" ');
      End;
      If IOResult=0 Then
      Begin
        If Context.REQVAR_XDL.Founditem_saName('HTTP_USER_AGENT',True) Then
          Write(FLog, '"'+Context.REQVAR_XDL.Get_saValue('HTTP_USER_AGENT')+'"')
        Else
          Write(FLog,'"-"');
      End;
      If IOResult=0 Then
      begin
        {$IFDEF WIN32}
        Write(FLog,#13);
        {$ENDIF}
        Write(FLog,#10);
      end;
      {$I+}
      if bTSCloseTextFile(Context.saLogFile,u2IOResult,FLog)=FALSE then
      begin
        JAS_Log(Context,cnLog_WARN,200811081243,'Unable to properly Close :'+Context.saLogFile,'',sourcefile);
      end;
    end
    else
    begin
      // TODO: What do you do if unable to open log file? Currently, nothing.
    end;
  end;
  // LOGFILE END-----

  //if (Context.CGIENV.ihttpresponse<>200) and (length(grJASConfig.saErrLogFile)>0)then
  {
  if (Context.CGIENV.ihttpresponse>=400) then
  begin
    JAS_Log(CONTEXT,cnLog_WARN,201001222155,
      csCRLF+'HTTPResponse: '+ inttostr(Context.CGIENV.ihttpresponse) + ' '+
      csCRLF+'FileSought: '+Context.saFileSought+' '+
      csCRLF+'RequestMethod: '+Context.saRequestMethod+' '+
      csCRLF+'RequestType: '+ Context.saRequestType+' '+
      csCRLF+'RequestedHost: '+Context.saRequestedHost+' '+
      csCRLF+'RequestedHostRootDir: '+Context.saRequestedHostRootDir+' '+
      csCRLF+'RequestedDir: '+Context.saRequestedDir+' '+
      csCRLF+'RequestedName: '+Context.saRequestedName+' '+
      csCRLF+'RequestedFile: ' + Context.saRequestedFile + ' '+
      csCRLF+'Requested: '+datetostr(Context.dtrequested)+' '+
      csCRLF+'RemoteIP: '+Context.rJSession.JSess_IP_ADDR+' '+
      csCRLF+'RemotePort: '+Context.rJSession.JSess_PORT_u+' '+
      csCRLF+'ServerIP: '+Context.saServerIP+' '+
      csCRLF+'ServerPort: '+Context.saServerPort+' '+
      csCRLF+'BytesRead: '+inttostr(Context.u8BytesRead)+' '+
      csCRLF+'BytesSent: '+inttostr(Context.u8BytesSent)+' '+
      csCRLF+'OriginallyRequestedFile: '+Context.saOriginallyRequestedFile+' '+
      csCRLF+'QueryString: '+Context.saQueryString+' '+
      csCRLF+'LogFile: '+Context.saLogFile+' '+
      csCRLF+'Mime Type: '+Context.saMimeType+' '+
      csCRLF+'saPostData: '+Context.CGIENV.saPostData+' '+
      csCRLF+'saIN:'+Context.saIn,
      '',SOURCEFILE
    );
  end;
  }
  
  //if bInternalJob then
  //begin
  //  if bTSOpenTextFile(
  //    grJASConfig.saLogDir+'context.xml',
  //    u2IOResult,
  //    FLog,
  //    false,
  //    false) then
  //  begin
  //    ASPrintLn('ABOUT to Render CONTEXT as XML');
  //    write(flog,CONTEXT.saXML);
  //    ASPrintLn('DONE Rendering CONTEXT as XML');
  //    bTSCloseTextFile(grJASConfig.saLogDir+'context.xml',u2IOResult,FLog)
  //  end;
  //end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161928,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




























//=============================================================================
Procedure TWORKER.CheckJobQ;
//=============================================================================
var
  RS: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  bOk: boolean;//in this proc, bOk can mean error if true or just NOT a Job to do
  XML: JFC_XML;
  saUserName: ansistring;
  //flog: text;
  //u2IOREsult: word;
  //bNothingToDo: Boolean;
  bHaveLock: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.CheckJobQ'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102723,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102724, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintLn('TWorker.CheckJobQ - BEGIN -=========================');
  //AS_Log(CONTEXT,cnLog_DEBUG,201004212013,'TWORKER.CheckJobQ - BEGIN','',sourcefile);
  //bNothingToDo:=true;


  XML:=JFC_XML.Create;
  rs:=JADO_RECORDSET.Create;
  DBC:=Context.VHDBC;
  bHaveLock:=false;

  // Lock Entire Table
  //bOk:=bJAS_LockRecord(Worker.Context, '0','jjobq','0','0',201501020070);
  //if not bOk then
  //begin
  //  JAS_Log(CONTEXT,cnLog_ERROR,201004212013,'TWORKER.CheckJobQ - Unable to lock jjobq table.','',sourcefile);
  //end;

  bOk:=true;

  //ASPrintln('TWorker.CheckJobQ - run First Query');
  if bOk then
  begin
    saQry:='select * from jjobq where '+
      '(JJobQ_Completed_b <> true) and '+
      '(JJobQ_Start_DT<=now()) and '+
      '((JJobQ_Started_DT is null) or (JJobQ_Started_DT=''0000-00-00 00:00:00'')) and '+
      '(JJobQ_Enabled_b=true) and '+
      '(JJobQ_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')';
    bOk:=rs.open(saQry,DBC,201503161610);
    //ASPrintln('JOBQ['+saQRY+']');
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004212014,'TWORKER.CheckJobQ - Trouble executing query.','Query: '+saQry,sourcefile, DBC, rs);
      JASPrintln('201004212014 - TWORKER.CheckJobQ - Trouble executing query:'+saQry);
    end;
  end;

  if bOk then
  begin
    bOk:= (rs.eol=false);
    if bOk then
    begin
      //ASPrintln('TWorker.CheckJobQ - Loading a JOB');
      //bNothingToDo:=false;
      with rJJobQ do begin
        JJobQ_JJobQ_UID          :=rs.fields.Get_saValue('JJobQ_JJobQ_UID');
        JJobQ_JUser_ID           :=rs.fields.Get_saValue('JJobQ_JUser_ID');
        JJobQ_JJobType_ID        :=rs.fields.Get_saValue('JJobQ_JJobType_ID');
        JJobQ_Start_DT           :=rs.fields.Get_saValue('JJobQ_Start_DT');
        JJobQ_ErrorNo_u          :=rs.fields.Get_saValue('JJobQ_ErrorNo_u');

        //JJobQ_Started_DT         :=rs.fields.Get_saValue('JJobQ_Started_DT');
        JJobQ_Started_DT:=saFormatDateTime(csDATETIMEFORMAT,now);

        //JJobQ_Running_b            :=rs.fields.Get_saValue('JJobQ_Running_b');
        JJobQ_Running_b:=DBC.saDBMSBoolScrub(true);

        JJobQ_Finished_DT           :=rs.fields.Get_saValue('JJobQ_Finished_DT');
        JJobQ_Name                  :=rs.fields.Get_saValue('JJobQ_Name');
        JJobQ_Repeat_b              :=rs.fields.Get_saValue('JJobQ_Repeat_b');
        JJobQ_RepeatMinute          :=rs.fields.Get_saValue('JJobQ_RepeatMinute');
        JJobQ_RepeatHour            :=rs.fields.Get_saValue('JJobQ_RepeatHour');
        JJobQ_RepeatDayOfMonth      :=rs.fields.Get_saValue('JJobQ_RepeatDayOfMonth');
        JJobQ_RepeatMonth           :=rs.fields.Get_saValue('JJobQ_RepeatMonth');
        JJobQ_Completed_b           :=rs.fields.Get_saValue('JJobQ_Completed_b');
        JJobQ_Result_URL            :=rs.fields.Get_saValue('JJobQ_Result_URL');
        JJobQ_ErrorMsg              :=rs.fields.Get_saValue('JJobQ_ErrorMsg');
        JJobQ_ErrorMoreInfo         :=rs.fields.Get_saValue('JJobQ_ErrorMoreInfo');
        JJobQ_Enabled_b             :=rs.fields.Get_saValue('JJobQ_Enabled_b');
        JJobQ_Job                   :=rs.fields.Get_saValue('JJobQ_Job');
        JJobQ_Result                :=rs.fields.Get_saValue('JJobQ_Result');
        JJobQ_JTask_ID              :=rs.fields.Get_saValue('JJobQ_JTask_ID');
      end;//with
    end
    else
    begin
      //ASPrintln('TWorker.CheckJobQ - Recordset empty. saQry: '+ saQry);
    end;
  end;
  rs.close;

  if bOk then
  begin
    bOk:=u8Val(rJJobQ.JJobQ_JUser_ID)>0;
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_WARN,201004230127,'TWORKER.CheckJobQ - rJJobQ.JJobQ_JUser_ID equates to Zero:'+rJJobQ.JJobQ_JUser_ID+' for jjobq.JJobQ_JJobQ_UID:'+rJJobQ.JJobQ_JJobQ_UID,'',sourcefile);
      //ASPrintln('TWorker.CheckJobQ - UserID is Zero.');
    end;
  end;

  if bOk then
  begin
    //ASPrintln('TWorker.CheckJobQ - Running User Query');
    saQry:='select JUser_Name from juser '+
      'where JUser_JUser_UID='+DBC.saDBMSScrub(rJJobQ.JJobQ_JUser_ID)+' and '+
      ' ((JUser_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry, DBC,201503161611);
    if not bOk then
    begin
      JAS_Log(CONTEXt,cnLog_ERROR,201004230128,'TWORKER.CheckJobQ - trouble with Query.','Query: '+saQry,sourcefile,DBC,rs);
      //ASPrintln('201004230128 TWORKER.CheckJobQ - trouble with Query: '+saQry);
    end;
  end;

  if bOk then
  begin
    bOk:=not rs.eol;
    if not bOk then
    begin
      JAS_Log(CONTEXt,cnLog_Warn,201204170841,'TWORKER.CheckJobQ - Looked up user - record missing.','Query: '+saQry,sourcefile);
      //ASPrintln('201204170842 TWORKER.CheckJobQ - User Record missing. Query: '+saQry);
    end;
  end;



  if bOk then
  begin
    saUserName:=rs.Fields.Get_saValue('JUser_Name');
    Context.bInternalJob:=true;
    Context.CGIENV.DataIn.AppendItem_saName_N_saValue('USERNAME',saUserName);
    Context.CGIENV.DataIn.AppendItem_saName_N_saValue('JJobQ_JJobQ_UID',rJJobQ.JJobQ_JJobQ_UID);
    //ASPrintln('201204170843 TWORKER.CheckJobQ - Calling CreateSession');
    bOk:=bJAS_CreateSession(Context);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004230129,'TWORKER.CheckJobQ - Unable to Create Session.','Query: '+saQry,sourcefile);
      JASPrintln('201004230129 TWORKER.CheckJobQ - Unable to Create Session. Query: '+saQry+' USERNAME:'+saUsername+' JJobQ UID:'+rJJobQ.JJobQ_JJobQ_UID);
    end;
  end;
  rs.close;

  if bOk then
  begin
    Context.CGIENV.DataIn.AppendItem_saName_N_saValue('JSID',Context.rJSession.JSess_JSession_UID);
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Calling ValidateSession');
    bOk:=bJAS_ValidateSession(Context);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004230130,'TWORKER.CheckJobQ - Unable to Validate Session.','Query: '+saQry,sourcefile);
      JASPrintLn('201004230130 TWORKER.CheckJobQ - Unable to Validate Session. Query: '+saQry);
    end;
  end;

  if bOk then
  begin
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Locking JOB Record');
    bOk:=bJAS_LockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,'0',201501020071);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_Warn,201004212013,'TWORKER.CheckJobQ - Unable to lock jjobq record rJJobQ.JJobQ_JJobQ_UID:'+rJJobQ.JJobQ_JJobQ_UID,'',sourcefile);
      //ASPrintln('201004212013 TWORKER.CheckJobQ - Unable to lock jjobq record rJJobQ.JJobQ_JJobQ_UID:'+rJJobQ.JJobQ_JJobQ_UID);
    end
    else
    begin
      bHaveLock:=true;
    end;
  end;

  if bOk then
  begin
    //bOk:=XML.bParseXML(rJJobQ.JJobQ_Job);
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Loading Context with XML');
    bOk:=Context.bLoadContextWithXML(rJJobQ.JJobQ_Job);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004212121,'TWORKER.CheckJobQ - Problem Parsing JobQ Task in jjobq.JJobQ_JJobQ_UID:'+rJJobQ.JJobQ_JJobQ_UID+' XML.saLastError:'+XML.saLastError,'',sourcefile);
      //ASPrintln('201004212121 TWORKER.CheckJobQ - Problem Parsing JobQ Task in jjobq.JJobQ_JJobQ_UID:'+rJJobQ.JJobQ_JJobQ_UID+' XML.saLastError:'+XML.saLastError);
    end;

    //if bTSOpenTextFile(
    //  grJASConfig.saLogDir+'context_newjobq.xml',
    //  u2IOResult,
    //  FLog,
    //  false,
    //  false) then
    //begin
    //  ASPrintLn('ABOUT to Render CONTEXT as XML after parsing task');
    //  write(flog,CONTEXT.saXML);
    //  ASPrintLn('DONE Rendering CONTEXT as XML after parsing task');
    //  bTSCloseTextFile(grJASConfig.saLogDir+'context_newjobq.xml',u2IOResult,FLog)
    //end;

    // HERE turn TASK into usable stuff by TCONTEXT.. load up things like session info, reqvar, etc.
    //Context.bMimeSNR:=true;
    //Context.saMimeType:='execute/jasapi';
    //Context.CGIENV.DATAIN.AppendItem_saName_N_saValue('JASAPI','helloworld');
    //Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
  end;

  if bOk then
  begin
    // update record but do not unlock yet
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Saving JOBQ Record UID: '+rJJobQ.JJobQ_JJobQ_UID);
    bOk:=bJAS_Save_jjobq(Context, DBC, rJJobQ, true, true);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004212120,'TWORKER.CheckJobQ - Unable to save jjobq after locking and loading record of new job to perform.','',sourcefile);
      //ASPrintln('201004212120 TWORKER.CheckJobQ - Unable to save jjobq after locking and loading record of new job to perform.');
    end;
  end;

  // Unlock Table
  //bJAS_UnLockRecord(Worker.Context, '0','jjobq','0','0',201501020072);

  rs.destroy;
  XML.Destroy;
  bInternalJob:=bOk;
  if not bOk then
  begin
    // if we can't run the thing - unlock it
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Can not run Job so unlocking record');
    //ASDebugPrintln('TWorker.CheckJobQ - Unlocking JOBQ Record: '+rJJobQ.JJobQ_JJobQ_UID);
    if bHaveLock then bJAS_UnLockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,'0',201501020073);
  
    //if bNothingToDo then
    //begin
    //  JASPrintln('JOB-Q - CheckJobQ - Nothing to do.');
    //end
    //else
    //begin
    //  JASPrintln('JOB-Q - CheckJobQ - POSSIBLE ERROR - Check Log');
    //end;
    //ResetThread;
  end
  else
  begin
    JASPrintln('JOB-Q - CheckJobQ - !!!! TASK LAUNCHED !!!!');
  end;

  //JAS_Log(CONTEXT,nLog_DEBUG,201210011740,'TWORKER.CheckJobQ - END','',sourcefile);

  //ASPrintLn('TWorker.CheckJobQ - FINISH -=========================');
  //ASPrintln('');
  //ASPrintln('');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102725,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
procedure TWorker.CompleteJobQTask;
//=============================================================================
var
  DBC: JADO_CONNECTION;
  bOk: boolean;
  dt: TDateTime;

  u1StartMinute: byte;
  u1StartHour: byte;
  u1StartDayOfMonth: byte;
  u1StartMonth: byte;
  u2StartYear: word;

  TK: JFC_TOKENIZER;

  m:Word;//month (1=January)
  d:Word;//days
  y:Word;//years
  //h:Word;//hours
  n:Word;//minutes
  s:Word;//seconds
  mh:Word;//military hours
  ms:Word;// milliseconds (Not reall implemented yet anywhere (Used in
  // sysutils.decodetime call though.
  //dow: longint; // Day Of Week (Going out)



{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWorker.CompleteJobQTask'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102726,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102727, sTHIS_ROUTINE_NAME);{$ENDIF}

  JASDebugPrintln('TWorker.CompleteJobQTask');
  //JAS_Log(CONTEXT,nLog_DEBUG,201210011741,'TWorker.CompleteJobQTask - BEGIN - UID: '+rJJobQ.JJobQ_JJobQ_UID,'',sourcefile);
  dt:=now;
  DBC:=Context.VHDBC;
  with rJJobQ do begin
    JJobQ_ErrorNo_u     :=inttostr(Context.u8ErrNo);
    JJobQ_Running_b     :=DBC.saDBMSBoolScrub(false);
    JJobQ_Finished_DT   :=saFormatDateTime(csDATETIMEFORMAT,dt);
    JJobQ_Completed_b   :=DBC.saDBMSBoolScrub(true);
    JJobQ_ErrorMsg      :=Context.saErrMsg;
    JJobQ_ErrorMoreInfo :=Context.saErrMsgMoreInfo;
    JJobQ_Result        :=self.Context.saOut;
  end;//with
  //ASPrintln('CompleteJOBQTask - Err: '+inttostr(Context.u8ErrNo)+' Msg: '+Context.saErrMsg+' More Info: '+Context.saErrMsgMoreInfo);

  //JAS_Log(CONTEXT,nLog_DEBUG,201210191510,'TWorker.CompleteJobQTask rJJobQ.JJobQ_Finished_DT: '+rJJobQ.JJobQ_Finished_DT,'',sourcefile);

  // Assure the correct Session UID is placed into Context.rJSession.JSess_JSession_UID before calling bJAS_Save_jjobq(?,?,?,false)
  //ASPrintln('CompleteJOBQTask - Saving JobQ Info');
  bOk:=bJAS_Save_jjobq(Context, DBC, rJJobQ, true, false);
  if not bOk then
  begin
    //ASPrintln('CompleteJOBQTask - Problem Saving JobQ Info');
    JAS_Log(CONTEXT,cnLog_ERROR,201005021659,'TWorker.CompleteJobQTask - bJAS_Save_jjobq Failed','',sourcefile);
    // TODO: This unlock shouldn't be needed based on how bJAS_Save_jjobq is written
    // but we've noticed the lock being stuck after a JOB run so we
    // need to figure this out.
    //bJAS_UnLockRecord(Context, '0','jjobq',rJJobQ.JJobQ_JJobQ_UID,'0',201501020074);
  end;

  //if bTSOpenTextFile(
  //  grJASConfig.saLogDir+'context.xml',
  //  u2IOResult,
  //  FLog,
  //  false,
  //  false) then
  //begin
  //  ASPrintLn('ABOUT to Render CONTEXT as XML at CompleteJobQTask');
  //  write(flog,CONTEXT.saXML);
  //  ASPrintLn('DONE Rendering CONTEXT as XML at CompleteJobQTask');
  //  bTSCloseTextFile(grJASConfig.saLogDir+'context.xml',u2IOResult,FLog)
  //end;
  //ASPrintln('CompleteJOBQTask - Removing Session');
  bOk:= bJAS_RemoveSession(Context);
  if not bOk then
  begin
    //ASPrintln('CompleteJOBQTask - Problem Removing Session');
    JAS_Log(CONTEXT,cnLog_ERROR,201103011506,'TWorker.CompleteJobQTask - bJAS_RemoveSession failed.','',sourcefile);
  end;

  if bOk and bVal(rJJobQ.JJobQ_Repeat_b) then
  begin
    //ASPrintln('CompleteJOBQTask - Handle JobQ Repeat');
    //AS_Log(CONTEXT,cnLog_Debug,201210191502,'TWorker.CompleteJobQTask - Entered REPEAT JOBQ CODE BLOCK.','',sourcefile);
    with rJJobQ do begin
      JJobQ_JJobQ_UID           :='0';
      //JJobQ_JUser_ID            : ansistring;
      //JJobQ_JJobType_ID         : ansistring;
      //JJobQ_Start_DT            : ansistring;
      JJobQ_ErrorNo_u           :='';// ansistring;
      JJobQ_Started_DT          :='';// ansistring;
      JJobQ_Running_b           :='false';
      JJobQ_Finished_DT         :='';
      //JJobQ_Name                : ansistring;
      //JJobQ_Repeat_b            : ansistring;
      //JJobQ_RepeatMinute        : ansistring;
      //JJobQ_RepeatHour          : ansistring;
      //JJobQ_RepeatDayOfMonth    : ansistring;
      //JJobQ_RepeatMonth         : ansistring;
      JJobQ_Completed_b         :='false';
      JJobQ_Result_URL          :='';
      JJobQ_ErrorMsg            :='';
      JJobQ_ErrorMoreInfo       :='';
      JJobQ_Enabled_b           :='true';
      //JJobQ_Job                 :='';
      JJobQ_Result              :='';
      JJobQ_CreatedBy_JUser_ID  :='';
      JJobQ_Created_DT          :='';
      JJobQ_ModifiedBy_JUser_ID :='';
      JJobQ_Modified_DT         :='';
      JJobQ_DeletedBy_JUser_ID  :='';
      JJobQ_Deleted_DT          :='';
      JJobQ_Deleted_b           :='';
      JAS_Row_b                 :='';
      //JJobQ_JTask_ID            : ansistring;
    end;//with


    DecodeDate(dt,y,m,d);
    DeCodetime(dt,mh,n,s,ms);
    //h:=iMilitaryToNormalHours(mh);//hours (Mh or Military Hours still set to original value so no data loss)
    u2StartYear:=y;

    TK:=JFC_TOKENIZER.Create;
    TK.saWhiteSpace:=' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'+csCRLF+'!@#$%^&()_+=-,./\;''<>:";';
    TK.saSeparators:='/\';

    TK.Tokenize(rJJobQ.JJobQ_RepeatMinute);
    if TK.MoveFirst then
    begin
      u1StartMinute:=u1Val(TK.Item_saToken);
      if TK.Tokens>1 then
      begin
        u1StartMinute:= n + u1StartMinute;
      end;
    end;
    TK.DeleteAll;

    TK.Tokenize(rJJobQ.JJobQ_RepeatHour);
    if TK.MoveFirst then
    begin
      u1StartHour:=u1Val(TK.Item_saToken);
      if TK.Tokens>1 then
      begin
        u1StartHour:= mh + u1StartHour;
      end;
    end;
    if u1StartHour=0 then u1StartHour:=mh;
    TK.DeleteAll;

    TK.Tokenize(rJJobQ.JJobQ_RepeatDayOfMonth);
    if TK.MoveFirst then
    begin
      u1StartDayOfMonth:=u1Val(TK.Item_saToken);
      if TK.Tokens>1 then
      begin
        u1StartDayOfMonth:= d + u1StartDayOfMonth;
      end;
    end;
    if u1StartDayOfMonth=0 then u1StartDayOfMonth:=d;
    TK.DeleteAll;

    TK.Tokenize(rJJobQ.JJobQ_RepeatMonth);
    if TK.MoveFirst then
    begin
      u1StartMonth:=u1Val(TK.Item_saToken);
      if TK.Tokens>1 then
      begin
        u1StartMonth:= m + u1StartMonth;
      end;
    end;
    if u1StartMonth=0 then u1StartMonth:=m;
    TK.DeleteAll;


    if u1StartMinute>59 then
    begin
      u1StartHour+=u1StartMinute div 60;
      u1StartMinute:=u1StartMinute mod 60;
    end;

    if u1StartHour>23 then
    begin
      u1StartDayOfMonth+=u1StartHour div 24;
      u1StartHour:=u1StartHour mod 24;
    end;

    while u1StartDayOfMonth > DaysInAMonth(y, u1StartMonth) do
    begin
      u1StartDayOfMonth:=u1StartDayOfMonth-DaysInAMonth(y, u1StartMonth);
      u1StartMonth+=1;
      if u1StartMonth>12 then
      begin
        u1StartMonth:=1;
        u2StartYear+=1;
      end;
    end;

    rJJobQ.JJobQ_Start_DT:=saZeroPadInt(u2StartYear,4)+'-'+saZeroPadInt(u1StartMonth,2)+'-'+saZeroPadInt(u1StartDayOfMonth,2)+' '+
      saZeroPadInt(u1StartHour,2)+':'+saZeroPadInt(u1StartMinute,2)+':00';
    bOk:=bJAS_Save_JJobQ(Context, DBC, rJJobQ, false, false);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201205291427,'TWorker.CompleteJobQTask - bSave_JJobQ failed.','',sourcefile);
    end;
    TK.Destroy;
  end;

  //ASPrintln('CompleteJOBQTask - Unlocking JobQ Record');
  // Make sure JJobQ Record Unlocked
  if not bJAS_UnLockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,'0',201501020075) then
  begin
    //ASPrintln('CompleteJOBQTask - Problem Unlocking JobQ Record');
    JAS_Log(CONTEXT,cnLog_Warn,201210191531,'TWorker.CompleteJobQTask - Unable to unlock record: '+rJJobQ.JJobQ_JJobQ_UID,'',sourcefile);
  end;
  

  //ASPrintln('JOB-Q - Completed JobQueue Task. OK: '+saYesNo(bOk));
  //AS_Log(CONTEXT,cnLog_DEBUG,201004212016,'TWorker.CompleteJobQTask - END bOk: '+saTrueFalse(bOk),'rJJobQ.JJobQ_JJobQ_UID - UID: '+rJJobQ.JJobQ_JJobQ_UID,sourcefile);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102728,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
//Const cnMAXHEADERLENGTH=8192;
Procedure TWORKER.ParseRequest;
//=============================================================================
Var
  bHandled: Boolean;
  i: Integer;
  iPosQuestionMark: Integer;
  saFirstchar: AnsiString;
//  bPostOrGet: Boolean;
  TK: JFC_TOKENIZER;
  iEQ: integer;

  saHeader: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ParseRequest'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102729,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102730, sTHIS_ROUTINE_NAME);{$ENDIF}

  //riteln('Parsing Request');
  //bPostOrGet:=False;

  {$IFDEF DIAGMSG}
  JASPrintLn('---TWORKER.iParseRequest---ENTER');
  {$ENDIF}


  //AS_Log(self.Context,cnLog_DEBUG,201002071736,Context.saIN,'',SOURCEFILE);

  // Check Header size and for the position of the CRLFCRLF terminator
  {$IFDEF DIAGMSG}
  JASPrintln('ParseA00 - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  //self.Context.CGIENV.iHTTPResponse:=cnHTTP_Response_400;//<------TEST by FORCEFUL Breaking :D
  if (self.Context.CGIENV.iHTTPResponse = 0) then
  begin
    i:=pos(#13#10#13#10, Context.saIN);
    {$IFDEF DIAGMSG}
    //ASPrintln('ParseA01 - i:'+saStr(i)+' Context.i4BytesRead:'+saStr(Context.i4BytesRead));
    {$ENDIF}
    {$IFDEF DIAGMSG}
    //ASPrintln('ParseA02 - i:'+saStr(i)+' grJASConfig.i4MaximumRequestHeaderLength:'+saStr(grJASConfig.i4MaximumRequestHeaderLength));
    {$ENDIF}
    if (i<=1) or ((i>(Context.u8BytesRead-3))and (Context.u8BytesRead>=3)) or (i>(grJASConfig.i8MaximumRequestHeaderLength-3)) then
    begin
      self.Context.CGIENV.iHTTPResponse:=cnHTTP_Response_400;
    end
    else
    begin
      saHeader:=copy(Context.saIN, 1, i + 1);
    end;
  end;

  {$IFDEF DIAGMSG}
  //ASPrintln('ParseB00 - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  // Check for Nulls, this is pascal but I still don't want inserted nulls... chr(0) bad form!
  // also need to weed out "mistake" or "binary" hits from where ever. I did have a bug where thread was
  // getting hung due to some unchecked binary in a header.. it was my own header - but we can't
  // let that happen!
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    i:=pos(#0,saHeader);
    if i>0 then self.Context.CGIENV.iHTTPResponse:=cnHTTP_Response_400;
  end;

  {$IFDEF DIAGMSG}
  //ASPrintln('ParseC00 - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  // The only hardcore testing I have time for ATM is done.
  // TODO: Revisit parsing the GET line for URI/RFC Compliancy
  // TODO: Add other request types - I think "PUT" is for uploading files.. haven't needed it yet
  if self.Context.CGIENV.iHTTPResponse=0 then
  begin
    if not ((saLeftStr(saHeader,3)='GET')or(saLeftStr(saHeader,4)='POST')) then self.Context.CGIENV.iHTTPResponse:=cnHTTP_Response_400;
  end;


  {$IFDEF DIAGMSG}
  //ASPrintln('ParseD00 - HTTP Response Code:'+saStr(self.Context.CGIENV.iHTTPResponse));
  {$ENDIF}
  if self.Context.CGIENV.iHTTPResponse=0 then
  Begin
    // This packages Up each header line into the REQVAR_XDL double linked list
    // for later retrieval etc. Note we are first putting the data in the description
    // field. NExt step is we parse the Desc, and put the header "name" in the name field
    // of the record/item in the REQUEST_XDL double linked list.
    // We put the value in the value field the same way. Ending up with a nice list of all
    // the headers, their values, the original text in the description column for reference
    // if want it.
    i := pos(#13#10, saHeader);
    While i<>0 Do
    Begin
      Context.REQVAR_XDL.AppendItem;
      Context.REQVAR_XDL.Item_saDesc:=copy(saHeader, 1, i - 1);
      {$IFDEF DIAGMSG}
      //ASPrintLn('Header Var:'+Context.REQVAR_XDL.Item_saDesc);
      {$ENDIF}
      delete(saHeader, 1, i + 1);
      i := pos(#13#10, saHeader);
    End;

    // OK - Now See what each of the headers actually is and if its one of the ones we are on the
    // look out for, do what we need.
    If Context.REQVAR_XDL.MoveFirst Then
    Begin
      repeat
        bHandled:=False;
        // First Line Specific
        If Context.REQVAR_XDL.N=1 Then
        Begin
          If (not bHandled) Then
          Begin
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_REQUEST_METHOD;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;

            If (pos(csINET_HDR_METHOD_GET+csSpace, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1) Then
            Begin
              //bPostOrGet:=True;
              Context.saRequestMethod:=csINET_HDR_METHOD_GET;
              Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,4);
            End;

            If (pos(csINET_HDR_METHOD_POST+csSpace, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1) Then
            Begin
              //bPostOrGet:=True;
              Context.saRequestMethod:=csINET_HDR_METHOD_POST;
              Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,5);
              Context.CGIENV.saPostData:=copy(Context.saIN, pos(#13#10#13#10, Context.saIN)+4, length(Context.saIN));
              Context.CGIENV.iPostContentLength:=length(Context.CGIENV.saPostData);
              Context.CGIENV.bPost:=True;
            End;

            //If (pos(csINET_HDR_METHOD_JASCGI+csSpace, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1) Then
            //Begin
            //  //bPostOrGet:=True;
            //  Context.saRequestMethod:=csINET_HDR_METHOD_JASCGI;
            //  Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,7);
            //  Context.CGIENV.scaPostData:=copy(Context.saIN, pos(#13#10#13#10, Context.saIN)+4, length(Context.saIN));
            //  Context.CGIENV.iPostContentLength:=length(Context.CGIENV.saPostData);
            //  Context.CGIENV.bPost:=True;
            //End;

            // via bPostOrGet: boolean.
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,
              pos(' ',JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue),
              length(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue));

            // GRAB the HTTP type
            Context.saRequestType:=JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc;
            delete(Context.saRequestType,1,pos(' ',Context.saRequestType));
            delete(Context.saRequestType,1,pos(' ',Context.saRequestType));

            // Grab the requested file info
            Context.saRequestedFile:=JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue;
            //ASPrintln('ParseJASCGI - Top - Req File: '+Context.saRequestedFile);
            if Context.saRequestedFile='NULL' then
            begin
              JAS_Log(Context,cnLog_Debug, 201202222348,'ParseRequest - File Came In As NULL','', SOURCEFILE);
            end;


            // ---good Place for some Info About Request to be displayed on console.
            //ASPrintLn(' - Context.saRequestedFile:'+Context.saRequestedFile);
            //ASPrintLn(Context.saRequestedFile);
            //if Context.bJASCGI then ASPrint('JASCGI ');
            //if Context.bInternalJob then ASPrint('JOBQ ');

            // snag any url parameters whether GET or POST
            iPosQuestionMark:=pos('?',Context.saRequestedFile);
            If iPosQuestionMark>0 Then
            Begin
              Context.saQueryString:=copy(Context.saRequestedFile,iPosQuestionMark+1,length(Context.saRequestedFile));
              Context.saRequestedFile:=copy(Context.saRequestedFile,1,iPosQuestionMark-1);
              //ASPrintLn('worker - parserequest - ?? Found: Context.saQueryString:'+Context.saQueryString);
            End
            Else
            Begin
              //ASPrintLn('worker - parserequest - ?? NOT Found');
              Context.saQueryString:='';
            End;
            saFirstchar:=saLeftStr(self.Context.saRequestedFile,1);
            If (saFirstchar='/') OR (saFirstchar='.') Then
            Begin
              self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile, length(self.Context.saRequestedFile)-1);
            End;
            //aSPrintLn('jcore - parse request - self.Context.saRequestedFile:'+self.Context.saRequestedFile);
            self.Context.saRequestedFile:=saDecodeURI(self.Context.saRequestedFile);
            //ASPrintLn('jcore - parse request - after decode: self.Context.saRequestedFile:'+self.Context.saRequestedFile);
            bHandled:=True;
          End;
        End
        Else
        Begin // This block is for parsing any header text NOT IN FIRST ROW.
          // Other Stuff
          {$IFDEF DIAGMSG}
          JASPrintLn('INTERROGATING:' + JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc);
          {$ENDIF}
          If (not bHandled) and
             (pos(csINET_HDR_JEGAS, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Jegas :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_JEGAS;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,7);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_USER_AGENT, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('USER AGENT :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_USER_AGENT;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,12);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_HOST, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('HOST :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_HOST;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,6);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_REFERER, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('REFERRER :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_REFERER;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,9);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos('Accept: ', JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Accept :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_ACCEPT;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,8);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_ACCEPT_LANGUAGE, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Accept Language :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_ACCEPT_LANGUAGE;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,17);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_CONTENT_TYPE, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Content Type :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_CONTENT_TYPE;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,14);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_ACCEPT_ENCODING, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Accept Encoding :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_ACCEPT_ENCODING;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,17);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_CONTENT_LENGTH, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Content Length :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_CONTENT_LENGTH;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,16);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_CONNECTION, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Connection :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_CONNECTION;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,12);
            bHandled:=True;
          End;


          If (not bHandled) and
             (pos(csINET_HDR_ACCEPT_CHARSET, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Accept Charset :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_ACCEPT_CHARSET;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,16);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_KEEPALIVE, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Accept Charset :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_KEEPALIVE;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,12);
            bHandled:=True;
          End;


          // NOTE: Here is the Cache Header Value that vs2005 pro uses for the dev
          // server you use to test .net web apps with uses for ZERO TIME Cache:
          // Cache-Control: private, max-age=0
          //
          // These two are from joomla running php
          // Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
          // Pragma: no-cache

          If (not bHandled) and
             (pos(csINET_HDR_CACHE_CONTROL, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Cache Control :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csJAS_CACHE_CONTROL;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,15);
            bHandled:=True;
          End;

          If (not bHandled) and
             (pos(csINET_HDR_COOKIE, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          Then
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('Cookie :)');
            {$ENDIF}
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_COOKIE;
            JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
            Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,8);
            // OK - NOW - to save processing time... stuff this directly into MYCGI
            If length(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue)>0 Then
            Begin
              TK:=JFC_TOKENIZER.Create;
              TK.SetDefaults;
              TK.saSeparators:=';';
              TK.saWhiteSpace:=';';
              TK.Tokenize(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue);
              //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_webrequest_cookie.txt');
              If TK.ListCount>0 Then
              Begin
                TK.MoveFirst;
                repeat
                  i:=length(TK.Item_saToken);
                  iEQ:=pos('=',TK.Item_saToken);
                  If iEQ>1 Then
                  Begin
                    self.Context.CGIENV.CKYIN.AppendItem_saName_N_saValue(
                      Trim(Upcase(leftstr(TK.Item_saToken, iEQ-1))),
                      trim(rightstr(TK.Item_saToken, i-iEQ)));
                  End;
                Until not tk.movenext;
              End;
              TK.Destroy;
            End;

            bHandled:=True;
          End;
        End;
      Until not Context.REQVAR_XDL.MoveNext;
    End
    else
    begin
      self.Context.CGIENV.iHTTPResponse:=cnHTTP_Response_400;
      {$IFDEF DIAGMSG}
      JASPrintLn('!!!PARSE REQUEST: Context.REQVAR_XDL.MoveFirst returned FALSE!!!');
      {$ENDIF}
    end;
  End;
  {$IFDEF DIAGMSG}
  JASPrintLn('---TWORKER.iParseRequest---EXIT');
  {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102731,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



































//=============================================================================
// NOTE: Context.saUserIPAddress MUST be set before this call
procedure TWORKER.SetErrorReportingModeAndDebugModeFlags;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:=''; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102744,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102745, sTHIS_ROUTINE_NAME);{$ENDIF}

  Context.iErrorReportingMode:=grJASConfig.iErrorReportingMode;

  if(Context.iErrorReportingMode=cnSYS_INFO_MODE_VERBOSELOCAL)then
  begin
    if(Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP) or
      (Context.rJSession.JSess_IP_ADDR='127.0.0.1') or
      (Context.rJSession.JSess_IP_ADDR='173.9.43.105') or    // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='10.1.10.3') or    // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='173.9.43.106') then  // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
    begin
      Context.iErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
    end
    else
    begin
      Context.iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
    end;
  end;

  Context.iDebugMode:=grJASConfig.iDebugMode;

  if(Context.iDebugMode=cnSYS_INFO_MODE_VERBOSELOCAL)then
  begin
    if(Context.rJSession.JSess_IP_ADDR=grJASConfig.saServerIP) or
      (Context.rJSession.JSess_IP_ADDR='127.0.0.1') or
      (Context.rJSession.JSess_IP_ADDR='173.9.43.105') or   // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='10.1.10.3') or    // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='173.9.43.106') then // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
    begin
      Context.iDebugMode:=cnSYS_INFO_MODE_VERBOSE;
    end
    else
    begin
      Context.iDebugMode:=cnSYS_INFO_MODE_SECURE;
    end;
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102746,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
//----------------------
// SAMPLE JAS CGI INPUT
//----------------------
// REDIRECT_HANDLER=application/x-httpd-jas
// REDIRECT_STATUS=200
// HTTP_HOST=www.jegas.net
// HTTP_USER_AGENT=Mozilla/4.0 (compatible; Synapse)
// PATH=/sbin:/usr/sbin:/bin:/usr/bin
// SERVER_SIGNATURE=<address>Apache/2.2.3 (CentOS) Server at www.jegas.net Port 80</address>
// SERVER_SOFTWARE=Apache/2.2.3 (CentOS)
// SERVER_NAME=www.jegas.net
//
// SERVER_ADDR=173.9.43.105
// SERVER_PORT=80
// REMOTE_ADDR=173.9.43.105
// DOCUMENT_ROOT=/xfiles/inet/web/root80vhost
// SERVER_ADMIN=webmaster@jegas.com
// SCRIPT_FILENAME=/xfiles/code/fpc/cgi-bin/jas-cgi
// REMOTE_PORT=60793
// REDIRECT_URL=/novo1/home_main.jas
// GATEWAY_INTERFACE=CGI/1.1
// SERVER_PROTOCOL=HTTP/1.0
// REQUEST_METHOD=GET
// QUERY_STRING=
// REQUEST_URI=/novo1/home_main.jas
// SCRIPT_NAME=/jws/jas-cgi
// PATH_INFO=/novo1/home_main.jas
procedure TWORKER.ParseJASCGI;
//=============================================================================
var
  TK: JFC_TOKENIZER;
  TK2: JFC_TOKENIZER;
  saName: ansistring;
  saValue: ansistring;
  i,iEQ: integer;
  saHeader: ansistring;
  iPosQuestionMark:integer;
  saFirstchar: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ParseJASCGI'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102747,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102748, sTHIS_ROUTINE_NAME);{$ENDIF}


  {
  //ASPrintln('Context b4 JASCGI -------------------------------BEGIN');
  //ASPrintln('saIN:',Context.saIN);
  //ASPrintln('saOUT:','Withheld for your sanitity');
  //ASPrintln('saOUT:',Context.saOUT);
  if self.Context.REQVAR_XDL.MoveFirst then
  begin
    repeat
      //ASPrintln('NAME:'+self.Context.REQVAR_XDL.Item_saName);
      //ASPrintln('DESC:'+self.Context.REQVAR_XDL.Item_saDesc);
      //ASPrintln('VALU:'+self.Context.REQVAR_XDL.Item_saValue);
      //ASPrintln('');
    Until not self.Context.REQVAR_XDL.MoveNext;
  end;
  //ASPrintln('saRemoteIP:'+Context.saRemoteIP);
  //ASPrintln('saRemotePort:'+Context.saremotePort);
  //ASPrintln('saServerIP:'+Context.saServerIP);
  //ASPrintln('saServerPort:'+Context.saServerPort);
  //ASPrintln('i4BytesRead:'+saStr(Context.i4BytesRead));
  //ASPrintln('i4BytesSent:'+sastr(Context.i4BytesSent));
  //ASPrintln('iHTTPResponse:'+saStr(Context.CGIENV.iHTTPResponse));
  //ASPrintln('dtRequested:'+datetostr(Context.dtrequested));
  //ASPrintln('saRequestedHost:'+Context.saRequestedHost);
  //ASPrintln('saRequestedHostRootDir:'+Context.saRequestedHostRootDir);
  //ASPrintln('saRequestMethod:'+Context.saRequestMethod);
  //ASPrintln('saRequestType:'+Context.saRequestType);
  //ASPrintln('saRequestedFile:'+Context.saRequestedFile);
  //ASPrintln('saOriginallyREquestedFile:'+Context.saOriginallyREquestedFile);
  //ASPrintln('saRequestedName:'+Context.saRequestedName);
  //ASPrintln('saRequestedDir:'+Context.saRequestedDir);
  //ASPrintln('saFileSought:'+Context.saFileSought);
  //ASPrintln('saQueryString:'+Context.saQueryString);
  //ASPrintln('saLogFile:'+Context.saLogFile);
  //ASPrintln('bJASCGI:'+saTrueFalse(Context.bJASCGI));
  //ASPrintln('Context b4 JASCGI -------------------------------END');
  }

  TK:=JFC_TOKENIZER.create;
  TK.saSeparators:=#13;
  TK.saWhitespace:=#13#10;
  if (self.Context.CGIENV.iHTTPResponse = 0) then
  begin
    i:=pos(#13#10#13#10, Context.CGIENV.saPostData);
    saHeader:=copy(Context.CGIENV.saPostData, 1, i + 1);
    Context.CGIENV.saPostData:=copy(Context.CGIENV.saPostData, i+4, length(Context.CGIENV.saPostData)-i+4);
    Context.CGIENV.iPostContentLength:=length(Context.CGIENV.saPostData);

    TK.Tokenize(saHeader);
    if TK.MoveFirst then
    begin
      repeat
        saName:=saGetStringBeforeEqualSign(tk.Item_saToken);
        saValue:=saGetStringAfterEqualSign(tk.Item_saToken);
        //ASPrintLn('JASCGI PARSE Token:'+tk.Item_saToken+' Name:'+saName+' Value:'+saValue);

        if saName=csCGI_REQUEST_METHOD then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_REQUEST_METHOD,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
          Context.saRequestMethod:=saValue;
          Context.CGIENV.bPost:=(Context.saRequestMethod=csINET_HDR_METHOD_POST);
        end;

        // REQUEST TYPE (HTTP Version e.g. "HTTP/1.0" or "HTTP/1.1" Not handled, not sure we need to yet

        if saName=csCGI_HTTP_USER_AGENT then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_USER_AGENT,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        //if saName=csCGI_HTTP_HOST then
        //begin
        //  if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_HOST,true) then
        //  begin
        //    Context.REQVAR_XDL.Item_saValue:=saValue;
        //  end;
        //end
        //else
        //begin
        //  Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
        //end;

        if saName=csCGI_HTTP_REFERER then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_REFERER,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_ACCEPT then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_ACCEPT,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_ACCEPT_LANGUAGE then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_ACCEPT_LANGUAGE,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_CONTENT_TYPE then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_CONTENT_TYPE,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_ACCEPT_ENCODING then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_ACCEPT_ENCODING,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_CONNECTION then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_CONNECTION,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_ACCEPT_CHARSET then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_ACCEPT_CHARSET,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_KEEPALIVE then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_KEEPALIVE,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csJAS_CACHE_CONTROL then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csJAS_CACHE_CONTROL,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;

        if saName=csCGI_HTTP_COOKIE then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_COOKIE,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
          If length(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue)>0 Then
          Begin
            TK2:=JFC_TOKENIZER.Create;
            TK2.SetDefaults;
            TK2.saSeparators:=';';
            TK2.saWhiteSpace:=';';
            TK2.Tokenize(saValue);
            //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_webrequest_cookie.txt');
            If TK2.ListCount>0 Then
            Begin
              TK2.MoveFirst;
              repeat
                i:=length(TK2.Item_saToken);
                iEQ:=pos('=',TK2.Item_saToken);
                If iEQ>1 Then
                Begin
                  self.Context.CGIENV.CKYIN.AppendItem_saName_N_saValue(
                    trim(Upcase(leftstr(TK2.Item_saToken, iEQ-1))),
                    trim(rightstr(TK2.Item_saToken, i-iEQ)));
                End;
              Until not tk2.movenext;
            End;
            TK2.Destroy;
          End;
        end;

        // Become the original Server (obviously will break networking but will allow
        // filtering by remote information
        if saName=csCGI_REMOTE_ADDR then Context.rJSession.JSess_IP_ADDR:=saValue;
        // Make current remote port still ok to use by commenting line below
        //if saName=csCGI_REMOTE_PORT then Context.saRemotePort:=saValue;

        // Let's keep the stock server info intact - as a form of masquerade
        //if XDL.FoundItem_saNAME(csCGI_SERVER_ADDR) then Context.saServerIP:=saValue;
        //if XDL.FoundItem_saNAME(csCGI_SERVER_PORT) then Context.saServerPort=saValue;

        // Can't do this yet - TODO: Make possible the relaying of the server software info - preserve
        // acrross the proxy
        //if XDL.FoundItem_saNAME(csCGI_SERVER_SOFTWARE) then Context.saServerSoftware=saValue;

        //if saName=csCGI_DOCUMENT_ROOT then Context.saRequestedDir:=saValue;
        if saName=csCGI_REQUEST_URI then
        begin
          Context.saRequestedFile:=saValue;
          //ASPrintln('ParseJASCGI - Req File b4 processing: '+Context.saRequestedFile);
          iPosQuestionMark:=pos('?',Context.saRequestedFile);
          If iPosQuestionMark>0 Then
          Begin
            Context.saQueryString:=copy(Context.saRequestedFile,iPosQuestionMark+1,length(Context.saRequestedFile));
            Context.saRequestedFile:=copy(Context.saRequestedFile,1,iPosQuestionMark-1);
            {$IFDEF DIAGMSG}
            JASPrintLn('jcore - parserequest - Context.saQueryString:'+Context.saQueryString);
            {$ENDIF}
          End
          Else
          Begin
            {$IFDEF DIAGMSG}
            JASPrintLn('jcore - parserequest - NO QueryString');
            {$ENDIF}
            Context.saQueryString:='';
          End;
          saFirstchar:=saLeftStr(self.Context.saRequestedFile,1);
          If (saFirstchar='/') OR (saFirstchar='.') Then
          Begin
            self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile, length(self.Context.saRequestedFile)-1);
          End;
          {$IFDEF DIAGMSG}
          JASPrintLn('jcore - parse request - self.Context.saRequestedFile:'+self.Context.saRequestedFile);
          {$ENDIF}
          self.Context.saRequestedFile:=saDecodeURI(self.Context.saRequestedFile);
          //ASPrintln('ParseJASCGI - Req File After processing: '+Context.saRequestedFile);
        end;
        if saName=csCGI_QUERY_STRING then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_QUERY_STRING,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end
          else
          begin
            Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
          end;
        end;
      until not TK.MoveNext;


      if Context.REQVAR_XDL.FoundItem_saName(csCGI_CONTENT_LENGTH,true) then
      begin
        Context.REQVAR_XDL.Item_saValue:=saStr(Context.CGIENV.iPostContentLength);
      end
      else
      begin
        Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(csCGI_CONTENT_LENGTH,saStr(Context.CGIENV.iPostContentLength),'JAS CGI');
      end;

      //Context.saOriginallyRequestedFile:=Context.saFileSought;
      //Context.saRequestedFile:=Context.saFileSought;
      {$IFDEF DIAGMSG}
      JASPrintLn('JAS CGI saRequestedFile:'+Context.saRequestedFile);
      {$ENDIF}
    end;//======
  end;
  //Context.saRequestedFile:='index.jas';// This forces JAS application execution PROVIDING the file exists

  {
  //ASPrintln('Context AFTER JASCGI -------------------------------BEGIN');
  //ASPrintln('saIN:',Context.saIN);
  //ASPrintln('saOUT:','Withheld for your sanitity');
  //ASPrintln('saOUT:',Context.saOUT);
  if self.Context.REQVAR_XDL.MoveFirst then
  begin
    repeat
      //ASPrintln('NAME:'+self.Context.REQVAR_XDL.Item_saName);
      //ASPrintln('DESC:'+self.Context.REQVAR_XDL.Item_saDesc);
      //ASPrintln('VALU:'+self.Context.REQVAR_XDL.Item_saValue);
      //ASPrintln('');
    Until not self.Context.REQVAR_XDL.MoveNext;
  end;
  //ASPrintln('saRemoteIP:'+Context.saRemoteIP);
  //ASPrintln('saRemotePort:'+Context.saremotePort);
  //ASPrintln('saServerIP:'+Context.saServerIP);
  //ASPrintln('saServerPort:'+Context.saServerPort);
  //ASPrintln('i4BytesRead:'+saStr(Context.i4BytesRead));
  //ASPrintln('i4BytesSent:'+sastr(Context.i4BytesSent));
  //ASPrintln('iHTTPResponse:'+saStr(Context.CGIENV.iHTTPResponse));
  //ASPrintln('dtRequested:'+datetostr(Context.dtrequested));
  //ASPrintln('saRequestedHost:'+Context.saRequestedHost);
  //ASPrintln('saRequestedHostRootDir:'+Context.saRequestedHostRootDir);
  //ASPrintln('saRequestMethod:'+Context.saRequestMethod);
  //ASPrintln('saRequestType:'+Context.saRequestType);
  //ASPrintln('saRequestedFile:'+Context.saRequestedFile);
  //ASPrintln('saOriginallyREquestedFile:'+Context.saOriginallyREquestedFile);
  //ASPrintln('saRequestedName:'+Context.saRequestedName);
  //ASPrintln('saRequestedDir:'+Context.saRequestedDir);
  //ASPrintln('saFileSought:'+Context.saFileSought);
  //ASPrintln('saQueryString:'+Context.saQueryString);
  //ASPrintln('saLogFile:'+Context.saLogFile);
  //ASPrintln('bJASCGI:'+saTrueFalse(Context.bJASCGI));
  //ASPrintln('Context After JASCGI -------------------------------END');
  }


  TK.Destroy; TK:=nil;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203102747,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
