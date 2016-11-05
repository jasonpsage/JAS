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
,ug_cgiin
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
  uMyID: uint;
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
  procedure ParseRequest;//< modifies self.Context.CGIENV.uHTTPResponse
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
  procedure PunkBeGone;
  Procedure CompleteJobQTask;
  Procedure DirectoryListing; // directory browsing
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
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.OnCreate();'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102712,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102713, sTHIS_ROUTINE_NAME);{$ENDIF}
  Context:=TCONTEXT.Create(
    grJASCOnfig.sServerSoftware,
    grJASConfig.i1TimeZoneOffset,
    TJTHREAD(self)
  );
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
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.OnTerminate;'; saStageNote:=sTHIS_ROUTINE_NAME; {$ENDIF}

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
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ResetThread;';  saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}

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

  saLinkFragment: ansistring;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.DirectoryListing'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161912,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  //saFancyYes:='<img title="Yes" class="image" src="[@JASDIRICONTHEME@]16/actions/dialog-ok.png" />';
  //saFancyNo:='<img title="No" class="image" src="[@JASDIRICONTHEME@]16/actions/dialog-no.png" />';


  if Context.sIconTheme='' then Context.sIconTheme := garJVHost[Context.u2Vhost].VHost_DefaultIconTheme;
  if Context.sIconTheme='' then Context.sIconTheme := 'Nuvola';
  saFancyFolder:='<img title="No" class="image" src="'+garJVHost[Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+Context.sIconTheme+'/22/places/folder.png" />';
  saFancyFile:='<img title="No" class="image" src="'+garJVHost[Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+Context.sIconTheme+'/22/actions/document-new.png" />';

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

  self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;//ok
  DirDL:=JFC_DIR.Create;
  DirDL.saPath:=self.Context.saRequestedDir;
  DirDL.bDirOnly:=false;
  {$IFDEF WINDOWS}
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

      saLinkFragment:='<a href="'+DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saLinkFragment+='/';
      end;
      saLinkFragment+='" title="';
      if DirDL.Item_bDir then
      begin
        saLinkFragment+='[&nbsp;';
      end;
      saLinkFragment+=DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saLinkFragment+='&nbsp;]';
      end;
      saLinkFragment+='" >';
      saDirRender+=saLinkfragment;
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
      saDirRender+='" ><span style="font-size 12pt" >';
      if DirDL.Item_bDir then
      begin
        saDirRender+='[&nbsp;';
      end;
      saDirRender+=DirDL.Item_saName;
      if DirDL.Item_bDir then
      begin
        saDirRender+='&nbsp;]';
      end;
      saDirRender+='</span></a>';
      saDirRender+='</td><td>';

      FSplit(DirDL.Item_saName,sDir,sName,sExt);
      sExt:=Uppercase(sExt);
      if (sExt='.SVG') or (sExt='.GIF') or (sExt='.BMP') or (sExt='.PNG') or (sExt='.JPG') or (sExt='.JPEG') or (sExt='.ICO') then
      begin
        saDirRender+='<a target="_blank" href="'+DirDL.Item_saName+'"><img class="image" width="256px" src="'+DirDL.Item_saName+'" /></a>';
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
  self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  self.context.CGIENV.Header_Html(garJVHost[Context.u2VHost].VHost_ServerIdent);
  DirDL.Destroy;DirDL:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201203161913,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




























//=============================================================================
Procedure TWORKER.ExecuteMyThread; // to be overridden
//=============================================================================
Var
  saHeaders: ansistring;
  //sThemeNameInCook ie: string;
  //sIconThemeNameInCook ie: string;
  sCacheControl: string;
  sa: ansistring;
  bPhantomRequest: boolean;
  u: uint;
  i4Len: longint;
  i4: longint;
  //dt: tdatetime;
  bSNRNow: boolean;
  saRedirectToHere: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}


                                  //1605030308324720288   smackbot bPunkBeGoneSmackBadBots
                                  //User-agent: *
                                  //Disallow: /
                                  //Disallow: /



Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ExecuteMyThread;';  saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102720,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102721, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintln('TWORKER.ExecuteMyThread BEGIN');
  //riteln;
  //asprintln('===========================================================');
  //asprintln('===========================================================');
  //asprintln('===========================================================');
  //asprintln('===========================================================');

  if bInternalJob then
  begin
    JASPrintln(saRepeatChar('=',79));
    JASPrintln('TWORKER.ExecuteMyThread - Begin - INTERNAL JOB');
    JASPrintln(saRepeatChar('=',79));
  end;

  Context.bInternalJob:=self.bInternalJob;
  Context.u8RequestUID:=u8Val(sGetUID);
  //--------------------------- GET REQUEST
  //ASPrintln('CALLING GrabIncomingData');
  GrabIncomingData;
  //ASPrintln('PAST Grabing incoming Data');
  if bInternalJob then
  begin
    JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - A');
  end;

  bPhantomRequest:=(Context.saIN='') and (NOT Context.bInternalJob);
  if (not bPhantomRequest) then
  begin
    if not bInternalJob then
    begin
      //ASPrintln('CALLING ParseAndVerifyGoodremoteAddress');
      ParseAndVerifyGoodremoteAddress;
      //--------------------------- GET REQUEST
      //--------------------------- DETERMINE WHAT REQUEST IS AND DISPATCH
      //ASPRintln('BACK - uj_worker 4321 - Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
      if not Context.bHavePunkAmongUs then
      begin
        if grJASConfig.bPunkBeGoneEnabled then
        begin
          i4Len:=length(gasPunkBait);
          if i4Len>0 then
          begin
            for i4:=0 to i4len-1 do
            begin
              //ASPrintln('EARLY CATC>'+gasPunkBait[i4]+'< >'+Context.saOriginallyRequestedFile+'< Pos: '+inttostr(Pos(UPCASE(trim(gasPunkBait[i4])),upcase(Context.saOriginallyRequestedFile))));
              if Pos(UPCASE(trim(gasPunkBait[i4])),upcase('/'+Context.saRequestedFile))<>0 then
              begin
                if not Context.bWhiteListed then
                begin
                  JIPListControl(self.context.vhdbc,'B', Context.rJSession.JSess_IP_ADDR, 'The Reaper was summoned... '+gasPunkBait[i4],0);
                  Context.bHavePunkAmongUs:=true;
              //ASPRintln('uj_worker 43321 - Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
                  break;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    if not Context.bHavePunkAmongUs then
    begin
      if bInternalJob then
      begin
        JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - B');
      end;

      if self.Context.CGIENV.uHTTPResponse = 0  then
      begin
        //ASPrintln('CALLING VirtualHostTranslation: '+garJVHost[Context.u2VHOST].VHost_ServerName);
        VirtualHostTranslation;
        //ASPrintln('BACK    VirtualHostTranslastion: '+garJVHost[Context.u2VHOST].VHost_ServerName);
        if bInternalJob then
        begin
          JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - C');
        end;

        //ASPrintln('CALLING TranslateRequestToFilename');
        if self.Context.CGIENV.uHTTPResponse = 0  then
        begin
          //ASPrintln('CALLING CheckIfTrailSlashOrRedirect');
          if self.Context.CGIENV.uHTTPResponse = 0  then
          begin
            if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - D');
            CheckIfTrailSlashOrRedirect;
            if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - E');

            if self.Context.CGIENV.uHTTPResponse = 0  then
            begin
              if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - F');
              TranslateRequestToFilename;
              if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - G');
              i4Len:=length(garJRedirectLight);
              if i4Len>0 then
              begin
                //riteln('orig req>'+self.context.saOriginallyRequestedFile+'<');
                for u:=0 to i4Len-1 do
                begin
                  if context.u2VHost = garJRedirectLight[u].VHostIndex THEN
                  begin
                    //riteln(saRepeatChar('=',60));
                    //riteln('Redirection self.context.saOriginallyRequestedFile: ' +self.context.saOriginallyRequestedFile);
                    //riteln('garJRedirectLight[u].REDIR_Location:'+garJRedirectLight[u].REDIR_Location);
                    if self.context.saOriginallyRequestedFile=garJRedirectLight[u].REDIR_Location then
                    begin
                      self.Context.CGIENV.uHTTPResponse:=garJRedirectLight[u].REDIR_JRedirectLU_ID;  //cnHTTP_RESPONSE_307;//temporary redirect
                      self.Context.CGIENV.Header_Redirect(garJRedirectLight[u].REDIR_NewLocation,garJVHost[Context.u2VHost].VHost_ServerIdent);
                      break;
                    end;
                  end;
                end;
              end;
              if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - H');
              {$IFDEF DIAGMSG}
                JASPrintln('CALLING ResolveDefaultFileIfNoneGiven');
              {$ENDIF}
              ResolveDefaultFileIfNoneGiven;
              {$IFDEF DIAGMSG}
                JASPrintln('BACK from CALLING ResolveDefaultFileIfNoneGiven');
              {$ENDIF}
              if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - I');
              if self.Context.CGIENV.uHTTPResponse = 0  then
              begin
                //ASPrintln('CALLING CleanUpAndVerifyCompleteFilename');
                CleanUpAndVerifyCompleteFilename;
                //ASPrintln('back from CALLING CleanUpAndVerifyCompleteFilename');
              end;
              if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - J');
            end;
          end;
        end;
      end;

      if self.Context.CGIENV.uHTTPResponse = 0  then
      begin
        //-------------------------- THEME RELATED ----------------------------------
        Context.sTheme:=garJVHost[Context.u2VHost].VHost_DefaultTheme;
        Context.sIconTheme:=garJVHost[Context.u2VHost].VHost_DefaultIconTheme;
        if (Context.sTheme='NULL') or (Context.sTheme='') then Context.sTheme:='brown';
        if (Context.sIconTheme='NULL') or (Context.sIconTheme='') then Context.sTheme:='brown';
        //-------------------------- THEME RELATED ----------------------------------
      end;

if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - K');

      //riteln('CALLING DispatchRequest. sServerPortCGI: '+context.sServerPortCGI+' Redirect to 443 flag on?:'+sYesNo(garJVHostLight[Context.i4VHost].bRedirectToPort443));
      if self.Context.CGIENV.uHTTPResponse = 0  then
      begin
        if (NOT (grJASConfig.bRedirectToPort443 and
                (context.u2ServerPortCGI<>443))) or Context.bInternalJob then
        begin
          if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - L');
          DispatchRequest;
          if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - M');
        end
        else
        begin
          //=============================================================================
          //HTTP/1.1 302 Redirected
          //Server: Microsoft-IIS/5.0
          //Date: Mon, 24 Mar 2003 21:44:30 GMT
          //Location: http://lc1.law5.hotmail.passport.com/cgi-bin/login
          //<blank>
          //Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_302;dt:=now;sa:='';
          //Context.saOut:=saCGIHdrRedirect('https://'+Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_HOST)
          //  ,jdate(sa,cnDateFormat_06,0,dt));
          //=============================================================================

          //=============================================================================
          //Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
          //Context.saOut:='<h2>'+Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_HOST)+'</h2>'+
          //  'REDIRECT TO PORT 443 SIMULATION';


          if Context.u2VHost=0 then //default
          begin
            saRedirectToHere:=Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_HOST);
            Context.saOut:=
              '<html><head><meta http-equiv="Refresh" content="0; url='+
              'https://'+saRedirectToHere;
            Context.saOut+=
              '" /></head><body><p>  Switching to SSL - <a href="https://'+
              saRedirectToHere+'">'+saRedirectToHere+'</a>.</p>'+
              '</body></html>';
          end
          else
          begin
            saRedirectToHere:=garJVHost[Context.u2VHost].Vhost_ServerURL;
            Context.saOut:=
              '<html><head><meta http-equiv="Refresh" content="0; url='+saRedirectToHere;
            Context.saOut+=
              '" /></head><body><p>  Bringing you to <a href="'+
              saRedirectToHere+'">'+saRedirectToHere+'</a>.</p>'+
              '</body></html>';

          end;
        end;
        //--------------------------- DETERMINE WHAT REQUEST IS AND DISPATCH
      end;
    end;


    //ASPrintln('Part #10 is Next');
    //-----------------------------------------------------------------------------------------
    //PART #10 ---------- Handle Rendering Errors and server messages
    //-----------------------------------------------------------------------------------------
    //ASPRintln('uj_worker 5321 - right b4 ban page Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
    if Context.bHavePunkAmongUs then
    begin
      Context.BanPage;
    end else


    if (Context.bErrorCondition) and (length(Context.saOut)=0) then
    begin
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - N');
      RenderHtmlErrorPage(Context);
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - O');
    end else

    if (length(trim(Context.saOut))=0) and (Context.CGIENV.uHTTPResponse<300) then
    begin
      // render 204 no content error (not really an error but...)
      //p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_204;
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - P');
      Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_204;
      Context.saOut:=saGetErrorPage(Context);
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - Q');
    end else

    if(Context.CGIENV.uHTTPResponse>=300) and  (Context.CGIENV.uHTTPResponse<400) then
    begin
      // REDIRECT - LET IT BE
      // TODO: Count these
    end else

    if (Context.CGIENV.uHTTPResponse>cnHTTP_RESPONSE_200) then
    begin
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - R');
      Context.saOut:=saGetErrorPage(Context);
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - S');
      //if Context.CGIENV.uHTTPResponse=cnHTTP_RESPONSE_418 then Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200; // so they see it on firefox etc that try to render server errors
    end;
    //-----------------------------------------------------------------------------------------

    //ASPrintln('Search-n-Replace NExt');
    //---------------------------------------------------------- JAS SNR
    bSnrNow:=Context.CGIENV.DATAIN.FoundItem_saName('JASSNR');
    if bSNRNow then bSNRNow:=bVal(Context.CGIENV.DATAIN.Item_saValue) else bSNRNow:=true;
    if (not Context.bHavePunkAmongUs) and (bSNRNow) then
    begin
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - T');
      Context.JAS_SNR;//Search-n-Replace
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - U');
    end;
    //---------------------------------------------------------- JAS SNR
    //ASPrintln('Past SNR');

    if (not ((Context.sMIMEType='execute/cgi') or
       (Context.bMIME_execute_PHP) or
       (Context.bMIME_execute_Perl)))
       //AND (not Context.bHavePunkAmongUs)
    then
    begin
      //ASPrintln('MIME TYPE b4 Call to DebugHTML: >'+Context.sMIMEType+'< csMIME_TextHtml: >'+csMIME_TextHtml+'<');
      if ((Context.sMIMEType=csMIME_ExecuteJegas) or
         (Context.sMIMEType=csMIME_TextHtml) or
         (Context.sMIMEType=csMIME_TextHtm))
         AND (not Context.bHavePunkAmongUs)
      then
      begin
        //ASPrintLn('Context.DebugHTMLOutput - CALLED from Context: '+Context.saIn);
        if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - W');
        Context.DebugHTMLOutput;
        if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - X');
      end;

      //ASPrintln('cache area');
      //========================================================= HEADERS
      sCacheControl:='no-cache';
      if (NOT Context.bNoWebCache) then
      begin
        //sCacheControl:='max-age='+inttostr(garJVHost[Context.u2VHost].Vhost_CacheMaxAgeInSeconds)+', must-revalidate';
        sCacheControl:='max-age='+inttostr(garJVHost[Context.u2VHost].Vhost_CacheMaxAgeInSeconds);
      end;
      if Context.bHavePunkAmongUs then Context.u2VHost:=0;
      //ASPrintln('----cache headers----');
      //ASPrintln('p_sMimeType.........' + Context.sMIMEType);
      //ASPrintln('p_u4ContentLength...' + inttostr(length(Context.saOut)));
      //ASPrintln('p_sCacheControl.....' + sCacheControl);
      //ASPrintln('p_sServerSoftware...' + grJASConfig.sServerSoftware);
      //ASPRintln('Context.i4VHost.....' + inttostr(Context.i4VHost));
      //ASPrintln('p_sServerIdent......' + garJVHostLight[Context.i4VHost].sServerIdent);
      //ASPrintln('----cache headers----');
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - Y');
      saHeaders:=Context.CGIENV.saGetHeaders(
        Context.sMIMEType,
        length(Context.saOut),
        sCacheControl,
        grJASConfig.sServerSoftware,
        garJVHost[Context.u2VHost].Vhost_ServerIdent
      );
      //asprintln(saRepeatChar('=',79));
      //ASPRintln('wkr-saHeaders');
      //asprintln(saRepeatChar('=',79));
      //ASPRINTLN(saHeaders);
      //asprintln(saRepeatChar('=',79));
      //ASPRintln('wkr-saHeaders');
      //asprintln(saRepeatChar('=',79));

      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - Z');
      //===============================================================================
      //ASPrintln('cache area past');

      //-------------------------CONSOLE OUTPUT----------------------------------------
      if Context.bHavePunkAmongUs then sa:='>' else sa:='[';
      sa+=Context.rJSession.JSess_IP_ADDR;
      if Context.bHavePunkAmongUs then sa+='<' else sa+=']';
      sa+=' '+FormatDateTime(csDATETIMEFORMAT,now)+' '+inttostr(Context.CGIENV.uHTTPResponse)+' '+Context.sMIMEType+' '+
        garJVHost[Context.u2VHost].Vhost_ServerDomain   +' '+Context.saRequestedFile+' ';

      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - AA');
      if Context.CGIENV.DataIn.MoveFirst then
      begin
        sa+='?';
        repeat
          sa+=Context.CGIENV.DataIn.Item_saName+'='+Context.CGIENV.DataIn.Item_saValue;
          {IFDEF LINUX}
          //sa+=csLF;
          {ELSE}
          //sa+=csCRLF;
          {ENDIF}
          if not Context.CGIENV.DataIn.eol then sa+='&';
        until not Context.CGIENV.DataIn.MoveNext;
      end;
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - BB');
      if grJASConfig.bServerConsoleMessagesEnabled then JASPrintln(sa);
      //ASPrintLn(sa+' 5134 svrmsgenabled:'+sYesNo(grJASConfig.bServerConsoleMessagesEnabled));
    end;
    //ASPrintln('past normal web pages');

    if (false=bInternalJob) then
    begin
      if (length(saHeaders)>0) then
      begin
        if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - CC');
        ConnectionSocket.SendString(saHeaders);
        if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - DD');
      end;
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - EE');
      if(length(self.Context.saOut)>0)then ConnectionSocket.SendString(self.Context.saOut);
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - FF');
    end
    else
    begin
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - GG');
      CompleteJobQTask;
      if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - HH');
    end;
    //asprintln('past internal jobqtask');
  end;

  //else
  //begin
  //  //ASPrintln('['+NetAddrToStr(in_addr(self.Connectionsocket.RemoteSin.sin_addr))+'] - ??? Phantom - Internal: '+sTrueFalse(Context.bInternalJob));
  //  //ASPrintln('['+NetAddrToStr(in_addr(self.Connectionsocket.RemoteSin.sin_addr))+'] - ??? Phantom');
  //end;
  //asprintln('before kill socket:'+inttostr(UINT(ConnectionSocket)));
  if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - II');

  if ConnectionSocket<>nil then
  begin
    ConnectionSocket.Destroy;ConnectionSocket:=nil;
  end;

  if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - JJ');

  //--------------------------- SEND OUT THE RESULTS OF THE REQUEST
  //asprintln('past kill socket');

  {$IFDEF DIAGNOSTIC_LOG}DiagnosticLog;{$ENDIF}
  if (not Context.bHavePunkAmongUs) and ( not bPhantomRequest) then
  begin
    if grJASConfig.bPunkBeGoneEnabled and (not Context.bInternalJob) then PunkBeGone;
    LogRequest;
  end;

  if bInternalJob then JASPrintln('TWORKER.ExecuteMyThread - INTERNAL JOB - KK');

  //asprintln('TWORKER.ExecuteMyThread END wkr:'+inttostr(iMyID));
  //asprintln('FreeOnTerm:'+sYesNo(FreeOnTerminate));
  if FreeOnTerminate then
  begin
    aWorker[uMyId]:=nil;
  end;

  if bInternalJob then
  begin
    JASPrintln(saRepeatChar('=',79));
    JASPrintln('TWORKER.ExecuteMyThread - End - INTERNAL JOB');
    JASPrintln(saRepeatChar('=',79));
  end;


  //asprintln('===========================================================');
  //asprintln('===========================================================');
  //asprintln('===========================================================');
  //asprintln('===========================================================');
  //riteln;

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

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.GrabIncomingData'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
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
    self.Context.rJSession.JSess_PORT_u:=self.Connectionsocket.RemoteSin.sin_port;
    self.Context.sServerIP:=grJASConfig.sServerIP;// We do this because future versions may support multiple listening sockets/ip addresses
    self.Context.u2ServerPort:=grJASConfig.u2ServerPort;// We do this because future versions may support multiple listening sockets/ip addresses
  end
  else
  begin
    self.Context.rJSession.JSess_IP_ADDR:='0.0.0.0';
    self.Context.rJSession.JSess_PORT_u:=0;
    self.Context.sServerIP:='0.0.0.0';
    self.Context.u2ServerPort:=0;
  end;
  //ASPrintLn('TWORKER.GrabIncomingData PORTS Stuff Done');
  self.Context.dtRequested:=now;
  //ASPrintLn('TWORKER.GrabIncomingData  Calling TWORKER.SetErrorReportingModeAndDebugModeFlags');
  self.SetErrorReportingModeAndDebugModeFlags;
  if (NOT bInternalJob) then
  begin
    //==================================================================================================
    bReadStop_WaitingDataZero:=false;
    bReadStop_MaxRequestHeaderLength:=false;
    i4PacketCount:=0;
    iRetries:=0;
    //ASPrintLn('TWORKER.GrabIncomingData Repeat loop');
    repeat
      saPacketData:='';
      saPacketData:=self.ConnectionSocket.RecvPacket(grJASConfig.u2SocketTimeOutInMSec);
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

      bReadStop_MaxRequestHeaderLength:=(length(self.Context.saIN)>grJASConfig.uMaximumRequestHeaderLength);
    until (bReadStop_WaitingDataZero) or (bReadStop_MaxRequestHeaderLength);
    //========================================================================================================

    //ASPrintLn('TWORKER.GrabIncomingData Repeat loop Finished');
    if bReadStop_MaxRequestHeaderLength then
    begin
      //ASPrintLn('TWORKER.GrabIncomingData MaxRequestHeaderLength Exceeded');
      JAS_Log(Context,cnLog_Error,201204080927,'MaxRequestHeaderLength ('+inttostr(grJASConfig.uMaximumRequestHeaderLength)+') EXCEEDED!','',sourcefile);
    end;

    //ASPrintLn('TWORKER.GrabIncomingData Setting Bytes REad');
    self.Context.uBytesRead:=length(self.Context.saIN);


    //AS_Log(Context,cnLog_Debug,201204080927,'Bytes Read In: '+inttostr(self.Context.u8BytesRead)+csCRLF+self.Context.saIN+csCRLF,'',sourcefile);
  end;
  //JAS_LOG(Context, cnLog_ebug, 201203312222, 'Multi-Part: '+ sYesNo(bMultiPart)+' Incoming Data Begin:'+self.Context.saIN+':END Incoming.','',SOURCEFILE);
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
  i4Len,i4: longint;
  rs: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWorker.ParseAndVerifyGoodremoteAddress'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161910,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203161910, sTHIS_ROUTINE_NAME);{$ENDIF}
  rs:=nil;
  DBC:=Context.VHDBC;

  //-----------------------------------------------------------------------------------------
  //PART #2 ---------- Parse the Request and See what the Client is asking for
  //-----------------------------------------------------------------------------------------
  {$IFDEF DIAGMSG}
  jASPrintln('Part 2 Enter - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  jASPRintln('uj_worker 6531 ->parsereq Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
  {$ENDIF}
  if (self.Context.CGIENV.uHTTPResponse=0) and (not Context.bInternalJob) then
  begin
    self.ParseRequest;
  end;
  {$IFDEF DIAGMSG}
  jASPRintln('uj_worker 6532 <-parsereq Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
  //ASPrintln('Part 2 Exit - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  //-----------------------------------------------------------------------------------------
  //PART #2 ---------- PArse the Request and See what the Client is asking for
  //-----------------------------------------------------------------------------------------




    //-----------------------------------------------------------------------------------------
    //----- The Part 2.5 Wedge :)
    // If the Request coming in is a JAS-CGI request, then turn that request into a local request.
    //-----------------------------------------------------------------------------------------
    //ASPrintln('JAS Wedge');
    if self.Context.CGIENV.uHTTPResponse = 0  then
    begin
      if self.Context.REQVAR_XDL.FoundItem_saName(csCGI_JEGAS,true) then
      begin
        self.Context.bJASCGI:=true;
        //if self.Context.REQVAR_XDL.Item_saValue<>csCGI_JEGAS_CGI_1_0_0 then
        //begin
        //  self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_412;// Pre Condition Failed (Version Not Supported)
        //end;

        if self.Context.CGIENV.uHTTPResponse = 0  then
        begin
          self.ParseJASCGI;
          {$IFDEF DIAGMSG}
          JASPrintLn('<postdata>'+self.Context.CGIENV.saPostData+'<postdata>');
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
  //if grJASConfig.bWhiteListEnabled then
  //begin
    bGotOne:=false;
    for i:=0 to length(garJipListLight)-1 do
    begin
      bGotOne:=(garJIPListLight[i].u1IPListType=cnJIPListLU_WhiteList) and
               ((garJIPListLight[i].sIPAddress=leftstr(self.Context.rJSession.JSess_IP_ADDR,length(garJIPListLight[i].sIPAddress))));
      if bGotOne then
      begin
        Context.bWhiteListed:=true;
        break;
      end else
      if (garJIPListLight[i].sIPAddress='') then break;
    end;
    if (not bGotOne) and (grJASConfig.bWhiteListEnabled) then
    begin
      self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_403; // Forbidden
      //AS_LOG(Context, cnLog_Warn, 201208182126, 'White List Prevented: '+self.Context.rJSession.JSess_IP_ADDR,'',SOURCEFILE);
    end;
  //end;
  //ASPrintln('WhiteList Complete');

  //ASPrintln('BlackList');
  bGotOne:=false;
  if grJASConfig.bBlackListEnabled then
  begin
    bGotOne:=false;
    for i:=0 to length(garJipListLight)-1 do
    begin
      bGotOne:=(garJIPListLight[i].sIPAddress=leftstr(self.Context.rJSession.JSess_IP_ADDR,length(garJIPListLight[i].sIPAddress))) and
        (garJIPListLight[i].u1IPListType=cnJIPListLU_BlackList);
        //((garJIPListLight[i].u1IPListType=cnJIPListLU_BlackList) or (garJIPListLight[i].u1IPListType=cnJIPListLU_InvalidLogin));

      if bGotOne or (garJIPListLight[i].sIPAddress='') then
      begin
        if bGotOne then
        begin
          // Make previous WhiteList FIND Overrule this is case some strange things happening
          //  probably good you can't get banned while white listed - even if the ips some how
          // got in there twice. they should not - the IPADDESS field is indexed so no duplicates
          // can occur, but its text, so if its not exact text wise but IP wis this could be where
          //this override is a blessing...i hope :)
          if not Context.bWhiteListed then
          begin
            Context.bHavePunkAmongUs:=true;
            saQry :='update jiplist set JIPL_Modified_DT=now(),JIPL_ModifiedBy_JUser_ID=0 where '+
              '((JIPL_Deleted_b<>true)or (JIPL_Deleted_b is null)) and (JIPL_IPAddress = '+Context.VHDBC.saDBMSScrub(garJIPListLight[i].sIPAddress)+')';
            rs:=JADO_RecordSet.create;
            if not rs.open(saQry,DBC,201605191211) then
            begin
              JAS_Log(Context,cnLog_WARN,201605191212,'Attempting to touch the modify date on a banned ip record. Qry:'+saQry,'',sourcefile);
            end;
            rs.destroy;rs:=nil;
            //ASPRintln('uj_worker 7531 - Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
            grPunkBeGoneStats.uBlockedSinceServerStart+=1;
          end;
        end;
        break;
      end;
    end;
  end;

  if not Context.bHavePunkAmongUs then
  begin
    if grJASConfig.bPunkBeGoneEnabled and (not Context.bWhiteListed) then
    begin
      i4Len:=length(gasPunkBait);
      if i4Len>0 then
      begin
        for i4:=0 to i4len-1 do
        begin
          //ASPrintln('EARLY CATC>'+gasPunkBait[i4]+'< >'+Context.saOriginallyRequestedFile+'< Pos: '+inttostr(Pos(UPCASE(trim(gasPunkBait[i4])),upcase(Context.saOriginallyRequestedFile))));
          if Pos(UPCASE(trim(gasPunkBait[i4])),upcase('/'+Context.saRequestedFile))<>0 then
          begin
            JIPListControl(self.context.vhdbc,'B', Context.rJSession.JSess_IP_ADDR, 'The Reaper was summoned... '+gasPunkBait[i4],0);
            if not Context.bWhiteListed then Context.bHavePunkAmongUs:=true;
  //ASPRintln('uj_worker 5831 - Context.bHavePunkAmongUs: '+sYesNo(Context.bHavePunkAmongUs));
            break;
          end;
        end;
      end;
    end;
  end;






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
  u: UINT;
  bLocalHost: boolean;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.VirtualHostTranslation'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161913,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  u:=0;
  //ASPrintln('-----------------');
  //-----------------------------------------------------------------------------------------
  //PART #4 ---------- Virtual HOST translation
  //-----------------------------------------------------------------------------------------
  {$IFDEF DIAGMSG}
  JASPrintln('Part 4 Enter - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  if self.Context.CGIENV.uHTTPResponse=0 then
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
    jASPrintln('worker-vhost self.Context.saOriginallyRequestedFile >'+self.Context.saOriginallyRequestedFile+'<');
    {$ENDIF}
    // VIRTUAL HOST TRANSLATED TO DIRECTORY
    self.Context.saRequestedHost:=self.Context.REQVAR_XDL.Get_saValue('HTTP_HOST');
    {$IFDEF DIAGMSG}
    JASDebugPrintln('Requested Host: '+self.Context.saRequestedHost);
    {$ENDIF}
    bLocalHost:=upcase(self.Context.saRequestedHost)='LOCALHOST';
    if not bLocalHost then
    begin
      for u:=0 to length(garJVHost)-1 do
      begin
        {$IFDEF DIAGMSG}
        JASDebugPrintln('Testing vHost: '+upcase(garJVHost[u].VHost_ServerDomain)+' = '+Context.saRequestedHost);
        {$ENDIF}
        if upcase(garJVHost[u].Vhost_ServerDomain)=self.Context.saRequestedHost then
        begin
          Context.u2VHost:=u;
          Context.saRequestedDir:=saAddSlash(garJVHost[u].Vhost_WebRootDir);
          {$IFDEF DIAGMSG}
            jasDebugPRintln('self.Context.saRequestedDir: '+self.Context.saRequestedDir);
            jASPrintln('uj_worker - self.Context.saRequestedDir:=garJVHostLight['+inttostr(u)+'].saWebRootDir:'+Context.saRequestedDir);
          {$ENDIF}
          Context.saLogfile:=garJVHost[u].Vhost_AccessLog;
          break;
        end;
      end;
    end;

    // If Virtual Host Entry Not Found Via Request, use default.
    If bLocalhost or (self.Context.saRequestedDir='') Then
    Begin
      //asprintln('----- No Virtual Host Entry Found ----- : '+Context.saRequestedHost);
      Context.u2VHost:=0;
      Context.saRequestedDir:=garJVHost[0].VHost_WebRootDir;
      Context.saLogfile:=garJVHost[0].VHost_AccessLog;
    end;

    Context.sLang:=garJVHost[Context.u2VHost].VHost_DefaultLanguage;
    if (Context.sLang='') or (upcase(leftstr(Context.sLang,3))='NUL') then
    begin
      Context.sLang:='en';
    end;
    Context.saRequestedHostRootDir:=Context.saRequestedDir;//because alias below can "change" this

    if not garJVHost[Context.u2VHost].bIdentOk then
    begin
      Context.saPage:=saGetPage(Context,'sys_area_bare','sys_page_jasident','MAIN',false,'',201210211315);
      //self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
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
  u,t: UINT;
  saCompareThis: ansistring;
  //saUp: ansistring;
  //bAliasHost: boolean;
  //saTestForIndexJas: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.TranslateRequestToFilename'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161915,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #5 ---------- Resolve File REQUEST to actual Filename
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    //bAliasHost:=false;
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
      for u:=0 to length(garJAliasLight)-1 do
      begin
        //ASPrintln('[a]lias: '+garJAliasLight[u].saAlias+' = '+saCompareThis);
        if ( garJAliasLight[u].saAlias     = saCompareThis ) then
        begin
          //ASPrintln('Found: '+garJAliasLight[u].saAlias);
          if garJAliasLight[u].bVHost then
          begin
            //ASPrintln('Is VHOST! '+garJAliasLight[u].saAlias+' VHosts: '+inttostr(length(garJVHost)));
            for t:=0 to length(garJVHost)-1 do
            begin
              //ASPrintln('Try to connect alias and vhost: '+inttostr(garJAliasLight[u].u8JVHost_ID)+' = '+inttostr(garJVHost[t].VHost_JVHost_UID));
              if garJAliasLight[u].u8JVHost_ID = garJVHost[t].VHost_JVHost_UID then
              begin
                //ASPrintln('VHOST AND MAIN Alias are Connected! '+garJVHost[t].VHost_ServerDomain+' and '+garJAliasLight[u].saAlias);
                self.Context.u2VHost:=t;
                self.Context.saRequestedDir:=garJVHost[t].VHost_WebRootDir;
                self.Context.saRequestedDir:=garJAliasLight[u].saPath;
                //ASPrintln('uj_worker5 - self.Context.saRequestedDir:=garJVHost['+inttostr(t)+'].saWebRootDir:'+self.Context.saRequestedDir);
                //ASPrintln('self.Context.saRequestedDir after assign: '+self.Context.saRequestedDir);
                // For the VHost+Alias combo - we want to use VHOST as the source of the Path
                //self.Context.saRequestedDir:=garJAliasLight[i].saPath;
                self.Context.saLogfile:=garJVHost[t].VHost_AccessLog;
                self.Context.sAlias:=garJAliasLight[u].saAlias;
                //self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-iPosSlash);
                self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-length(self.Context.sAlias)+1);
                //asPrintln('worker-diceup - after worker-alias dice up: ' + self.Context.saRequestedFile);
                //bAliasHost:=true;
                break;
              end;
            end;
          end
          else
          begin
            //asprintln('in the alias hunt, the non vhost part');
            //asprintln('garJAliasLight[u].u8JVHost_ID:'+inttostr(garJAliasLight[u].u8JVHost_ID));
            //asprintln('garJVHost[Context.u2VHost].VHost_JVHost_UID:'+inttostr(garJVHost[Context.u2VHost].VHost_JVHost_UID));
            if ( garJAliasLight[u].u8JVHost_ID = garJVHost[Context.u2VHost].VHost_JVHost_UID) then
            begin
              //ASPrintln('CURRENT vHost and Alias Connected');
              self.Context.saRequestedDir:=garJAliasLight[u].saPath;
              //ASPrintln('uj_worker6 - self.Context.saRequestedDir:=garJAliasLight['+inttostr(t)+'].saPath:'+self.Context.saRequestedDir);
              self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-iPosSlash);
              //ASPrintln('self.Context.saRequestedDir after assign: '+self.Context.saRequestedDir);
              //self.Context.saRequestedFile:=saRightStr(self.Context.saRequestedFile,length(self.Context.saRequestedFile)-length(garJAliasLight[i].saAlias));
              break;
            end;
            //else
            //begin
            //  asprintln('This host and alias did not click');
            //end;
          end;
        end;
      end;

      //self.Context.saServerURL:=garJVHost[Context.u2VHost].VHost_ServerURL;//garJVHost[Context.u2VHost].VHost_ServerDomain;
      //saUP:=upcase(self.Context.saServerURL);
      //saUP:=upcase(garJVHost[Context.u2VHost].VHost_ServerURL);
      
      //if (saUP='DEFAULT') or (bAliasHost) then
      //begin
      //  self.Context.saServerURL:=grJASConfig.saServerURL;
      //end else

      //if garJVHost[Context.u2VHost].VHost_EnableSSL_b then
      //begin
      //  self.Context.saServerURL:='https://'+self.Context.saServerURL;
      //  if garJVHost[Context.u2VHost].VHost_ServerPort<>'443' then
      //  begin
      //    self.Context.saServerURL+=':'+garJVHost[Context.u2VHost].VHost_ServerPort;
      //  end;
      //end
      //else
      //begin
      //  self.Context.saServerURL:='http://'+self.Context.saServerURL;
      //  if garJVHost[Context.u2VHost].VHost_ServerPort<>'80' then
      //  begin
      //    self.Context.saServerURL+=':'+garJVHost[Context.u2VHost].VHost_ServerPort;
      //  end;
      //end;
    end;

    {$IFDEF DIAGMSG}
    JASPrintln('Before Fixup-----------------------');
    JASPrintln('Dir >'+self.Context.saRequestedDir+'<');
    JASPrintln('File >'+self.Context.saRequestedFile+'<');
    JASPrintln('Orig >'+self.Context.saOriginallyRequestedFile+'<');
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
    {$IFDEF WINDOWS}
      Context.saRequestedDir:=saSNRStr(Context.saRequestedDir,'/','\');
    {$ELSE}
      Context.saRequestedDir:=saSNRStr(Context.saRequestedDir,'\','/');
    {$ENDIF}

    bReqDirExist:= DirectoryExists(self.Context.saRequestedDir);
    //riteln('workerthang - self.Context.saRequestedDir: ',self.Context.saRequestedDir,' bReqDirExist:',bReqDirExist);

    // moved to check for ending slash
    //saDirNFile:=self.Context.saRequestedDir+self.Context.saRequestedFile;
    //bDirNFileExist:=FileExists(saDirNFile) and (not DirectoryExists(saDirNFile));
    //bReqFileIsFile:=(bDirNFileExist and (not DirectoryExists(saDirNFile)));

    {$IFDEF DIAGMSG}
      JASPrintLn(sTHIS_ROUTINE_NAME +': After Fixup-----------------------');
      JASPrintLn(sTHIS_ROUTINE_NAME +': self.Context.saRequestedDir >'+self.Context.saRequestedDir+'<');
      JASPrintLn(sTHIS_ROUTINE_NAME +': bReqDirExist:'+sYesNo(bReqDirExist));
      JASPrintLn(sTHIS_ROUTINE_NAME +': self.Context.saRequestedFile >'+self.Context.saRequestedFile+'<');
      JASPrintLn(sTHIS_ROUTINE_NAME +': bDirNFileExist:'+sYesNo(bDirNFileExist));
      JASPrintLn(sTHIS_ROUTINE_NAME +': bReqFileIsFile:'+sYesNo(bReqFileIsFile));
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
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.CheckIfTrailSlashOrRedirect'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161917,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  //ASPrintln('-----------------');
  //ASPrintln('Enter - CheckIfTrailSlashOrRedirect - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  //-----------------------------------------------------------------------------------------
  //PART #6 ---------- Is a redirection needed? Like lack of a trailing slash on a directory?
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin

    bReqDirExist:=DirectoryExists(self.Context.saRequestedDir);
    if bReqDirExist then
    begin
      sa:=saAddFwdSlash(self.Context.saRequestedDir)+self.Context.saRequestedFile;
      if directoryexists(sa) then
      begin
        //self.Context.saRequestedDir:=sa;
        //self.Context.saRequestedFile:='';
        //self.Context.saOriginallyRequestedFile:=sa;
        self.Context.saRequestedFile+='/';
      end;
    end;


    saDirNFile:=self.Context.saRequestedDir+self.Context.saRequestedFile;
    bDirNFileExist:=FileExists(saDirNFile);
    bReqFileIsFile:=(bDirNFileExist and (not DirectoryExists(saDirNFile)));




    {$IFDEF DIAGMSG}
    JASPrintln('iReqOrigLength:'+inttostr(iReqOrigLength));
    JASPrintln('bDirNFileExist:'+sTrueFalse(bDirNFileExist));
    JASPrintln('bReqDirExist:'+sTrueFalse(bReqDirExist));
    JASPrintln('bReqFileIsFile:'+sTrueFalse(bReqFileIsFile));
    JASPrintln('saRequestedHost:'+self.Context.saRequestedHost);
    JASPrintln('saRequestedHost:'+self.Context.saRequestedHost);
    {$ENDIF}




    If (iReqOrigLength>0) and
    (not bDirNFileExist) and
    (not bReqFileIsFile) and
    (bReqDirExist) then
    //(pos('.',self.Context.saRequestedFile)=0) then
    Begin
      self.Context.saRequestedDir+= saAddFwdSlash(self.Context.saRequestedFile);
      self.Context.saRequestedFile:='';
      //If saRightStr(self.Context.saRequestedDir,1)<>'/' Then
      If saRightStr(self.Context.saRequestedDir,1)<>DOSSLASH Then
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
          self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_307;//temporary redirect
          sa:=self.Context.saOriginallyRequestedFile+'/';
          if saLeftStr(sa,1)<>'/' then sa:='/'+sa;
          self.Context.CGIENV.Header_Redirect(sa,garJVHost[Context.u2VHost].VHost_ServerIdent);
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
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.ResolveDefaultFileIfNoneGiven'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161919,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //PART #7 ---------- Figure out Default File (Directory Index) if filename not given
  //-----------------------------------------------------------------------------------------
  //ASPrintln('-----------------');
  //ASPrintln('ENTER - ResolveDefaultFileIfNoneGiven - HttpResponse:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  saIndexFileNAme:='';
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    //ASPrintln('ResolveDefaultFileIfNoneGiven req File: '+self.Context.saREquestedFile);
    If (self.Context.saREquestedFile='/') or (self.Context.saREquestedFile='//') Then self.Context.saREquestedFile:='';
    //If self.Context.saREquestedFile='/' Then self.Context.saREquestedFile:='';
    If self.Context.saREquestedFile='' Then
    Begin
      // TRY to find existing DIRECTORYINDEXMATRIX file
      //ASPRintln('Testing whether to look for index file. indexfiles:'+inttostr(length(garJIndexFileLight)));
      //ASPrintln('Context.i4VHost:'+inttostr(Context.i4VHost)+' (Context.i4VHost<=(length(garJVHostLight)-1):'+sTrueFalse((Context.i4VHost<=(length(garJVHostLight)-1))));
      If (length(garJIndexFileLight)>0) and (Context.u2VHost<=(length(garJVHost)-1)) then
      Begin
        {$IFDEF DIAGMSG}
        JASPrint('We have '+inttostr(length(garJIndexFileLight))+' garJIndexFileLight(s) to search'+csCRLF);
        JASPrintln('Context.u2VHost: '+inttostr(Context.u2VHost));
        {$ENDIF}
        ix:=0;
        repeat
          {$IFDEF DIAGMSG}
          JASPrintln('TESTING garJIndexfileLight[iX].u8JVHost_ID: '+inttostr(garJIndexfileLight[iX].u8JVHost_ID)+' = garJVHost[Context.u2VHost].VHost_JVHost_UID: '+inttostr(garJVHost[Context.u2VHost].VHost_JVHost_UID));
          {$ENDIF}
          if garJIndexfileLight[iX].u8JVHost_ID=garJVHost[Context.u2VHost].VHost_JVHost_UID then
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
        if(ix=length(garJIndexFileLight))then
        begin
          saIndexFileName:='[NO INDEX FILE EXISTS]';
          //ASPrintln('INDEX HUNT FAILED ix:'+inttostr(ix)+' length(garJIndexFileLight): '+ inttostr(length(garJIndexFileLight)));
          if bReqDirExist then
          begin
            //ASPrintln('Requested DIR Exists. garJVHostLight[Context.i4VHost].bDirectoryListing: '+sYesNo(garJVHostLight[Context.i4VHost].bDirectoryListing));
            if garJVHost[Context.u2VHost].VHost_DirectoryListing_b and (not fileexists(self.Context.saRequestedDir + 'index.jas')) then
            begin
              //ASPrintln('Calling Directory Listing');
              DirectoryListing;
            end
            else
            begin
            //  //ASPrintln('Directory Listing not allowed');
              //saIndexfilename:='index.jas';//last resort
              self.Context.saRequestedFile:='index.jas';
            end;
          end
          else
          begin
            JAS_Log(Context,cnLog_WARN,201012291442,'Requested Dir not found:'+self.Context.saRequestedDir,'',sourcefile);
            self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_404;
          end;
        End;
        //else
        //begin
        //  ASPRintln('No DIR List Check. ix: '+inttostr(ix)+' length(garJIndexFileLight):'+inttostr(length(garJIndexFileLight)));
        //end;
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
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.CleanUpAndVerifyCompleteFilename'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161921,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  //-----------------------------------------------------------------------------------------
  //ASPrintln('BEGIN PART #8 ---------- Clean up the filename and disallow backward relative paths');
  //-----------------------------------------------------------------------------------------
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    {$IFDEF DIAGMSG}
    JASPrintln(sTHIS_ROUTINE_NAME+':After Adding a Default File if necessary');
    JASPrintln(sTHIS_ROUTINE_NAME+':Dir:'+self.Context.saRequestedDir);
    JASPrintln(sTHIS_ROUTINE_NAME+':Dir Exists?:'+sYesNo(DirectoryExists(self.Context.saRequestedDir)));
    JASPrintln(sTHIS_ROUTINE_NAME+':file:'+self.Context.saRequestedFile);
    {$ENDIF}

    self.Context.saFileSought:=saAddFwdSlash(self.Context.saRequestedDir);
    self.Context.saFileSought+=self.Context.saRequestedFile;
    //self.Context.saFileSought:=saSNR(self.Context.saFileSought,'\','/');

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
    Context.sFileSoughtExt:=ExtractFileExt(self.Context.saFileSought);
    //ASPrintln('PART #8 - C');
    Context.sFileSoughtExt:=saRightStr(Context.sFileSoughtExt,length(Context.sFileSoughtExt)-1);
    //ASPrintln('PART #8 - D');
    Context.sFileNameOnly:=ExtractFileName(self.Context.saFileSought);
    //ASPrintln('PART #8 - E');
    Context.sFileNameOnlyNoExt:=saLeftStr(Context.sFileNameOnly,length(Context.sFileNameOnly)-length(Context.sFileSoughtExt)-1);
    //ASPrintln('PART #8 - F');

    // Have to stuff the querystring here because translate function parses querystring and passed postdata
    Context.CGIENV.ENVVAR.AppendItem_saName_N_saValue('QUERY_STRING',Context.saQueryString);
    //ASPrintln('PART #8 - G - Translate Param: '+Context.CGIENV.saPostData);
    Context.CGIENV.TranslateParameters(Context.CGIENV.saPostData, Context.REQVAR_XDL.Get_saValue(csCGI_CONTENT_TYPE));
    //ASPrintln('PART #8 - END TOP CHUNK');
    

    //if Context.CGIENV.DataIn.FoundItem_saName('ACTION') then
    //begin
    //  Context.bMimeSNR:=true;
    //  Context.sMIMEType:='execute/jegas';
    //  Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    //end else
 
    // See if this is an JASAPI Request
    if(Context.CGIENV.DATAIN.FoundItem_saName('JASAPI',false))then
    begin
      Context.bMimeSNR:=true;
      Context.sMIMEType:='execute/jasapi';
      Context.sFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    end else

    if(Context.CGIENV.DATAIN.FoundItem_saName('USERAPI',false))then
    begin
      Context.bMimeSNR:=true;
      Context.sMIMEType:='execute/userapi';
      Context.sFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;
    end else

    begin
      //ASPrintln('PART #8 - Determine MIME Type');
      // DETERMINE MIME TYPE BASED ON RESOLVED FILE EXTENSION
      if length(garJMimeLight)>0 then
      begin
        for i:=0 to length(garJMimeLight)-1 do
        begin
          if garJMimeLight[i].sName=Context.sFileSoughtExt then
          begin
            Context.sMIMEType:=garJMimeLight[i].sType;
            Context.bMimeSNR:=garJMimeLight[i].bSNR;
          end;
        end;
      end;


      bFileSoughtExists:=
        ((self.Context.saFileSought='robots.txt') and grJASConfig.bPunkBeGoneSmackBadBots) or
        ((FileExists(self.Context.saFileSought)or(FileExists(self.Context.saFileSought+'/'))));
      //previous
      //bFileSoughtExists:=((self.Context.saFileSought='robots.txt') and grJASConfig.bPunkBeGoneSmackBadBots) or
      //                   FileExists(self.Context.saFileSought);
      //                   // or (length(self.Context.saAction)>0);
      //previous





      if (not bFileSoughtExists) then
      begin
        //ASPrintln('bFileSoughtExists Failed: '+self.Context.saFileSought);
        Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_404;//not found
        JAS_Log(Context,cnLog_WARN,200912291442,'File Not Found :'+self.Context.saFileSought,'',sourcefile);
      end;
    end;
      //bFileSoughtExists:=FileExists(self.Context.saFileSought) and (self.Context.saRequestedFile<>'');
  end;

  // Make sure they didn't toss in some hopeful hacker backwards relative path gibberish
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    //ASPrintln('PART #8 - Extracting Rel Path');
    If (pos('/../', ExtractRelativepath(self.Context.saRequestedDir, self.Context.saFileSought)) <> 0) then
    begin
      self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_403; // Forbidden
      JAS_LOG(Context, cnLog_Warn, 201208182128, 'Attempt to traverse higher directory: '+
        self.Context.rJSession.JSess_IP_ADDR+' PATH: '+self.Context.saRequestedDir,'',SOURCEFILE);
    end;
  end;
  {$IFDEF DIAGMSG}JASPrintln('Part 8 Exit - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));{$ENDIF}
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
//  sVal: string;
  bOk: boolean;
  saQry: ansistring;
  uListOfs: uint;
  sa: ansistring;
  bGotOne:boolean;
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.DispatchRequest;'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161923,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;

  if bInternalJob then JASPrintln('TWORKER.DispatchRequest - BEGIN');

  //-----------------------------------------------------------------------------------------
  //PART #9 ---------- Prepare for Direct Handling or CGI Invocation (Mime based)
  //-----------------------------------------------------------------------------------------
  if Context.CGIENV.uHTTPResponse=0 then
  begin
    if(Context.sMIMEType='execute/jasapi')then
    begin
      //PrepareWebBasedJegasApplication(self.Context);
     if bInternalJob then JASPrintln('TWORKER.DispatchRequest - B');
      bJAS_ValidateSession(Context);
      Context.sMIMEType:=csMime_TextXML;
      JASAPI_Dispatch(Context);
      Context.CreateIWFXML;
      Context.saOut:=self.Context.saPage;
     if bInternalJob then JASPrintln('TWORKER.DispatchRequest - C');
    end else

    if(Context.sMIMEType='execute/userapi')then
    begin
      //PrepareWebBasedJegasApplication(Context);
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - D');
      bJAS_ValidateSession(Context);
      Context.sMIMEType:=csMime_TextXML;
      bUserAPI_Dispatch(Context);
      Context.CreateIWFXML;
      Context.saOut:=self.Context.saPage;
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - E');
    end
    else

    if(Context.sMIMEType='execute/jegas')then
    begin
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - F');
      //PrepareWebBasedJegasApplication(Context);
      //ASPrintln('EXECUTING JAS APPLICATION');
      bJAS_ValidateSession(Context);
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - G');
      // BEGIN -------------------------  User Preferences
      if Context.bSessionValid then
      begin
        if bInternalJob then JASPrintln('TWORKER.DispatchRequest - H');
        //////////////// Theme (html/css)
        if (Context.rJUser.JUser_Theme<>'NULL') and (Context.rJUser.JUser_Theme<>'') then
        begin
          Context.sTheme:=Context.rJUser.JUser_Theme;
        end else
        if (garJVHost[Context.u2VHost].VHost_DefaultTheme='NULL') or
           (garJVHost[Context.u2VHost].VHost_DefaultTheme='') then
        begin
          Context.sTheme:=garJVHost[Context.u2VHost].VHost_DefaultTheme;
        end;

        if (Context.rJUser.JUser_IconTheme<>'NULL') and (Context.rJUser.JUser_IconTheme<>'') then
        begin
          Context.sIconTheme:=Context.rJUser.JUser_IconTheme;
        end else
        if (garJVHost[Context.u2VHost].VHost_DefaultIconTheme='NULL') or
           (garJVHost[Context.u2VHost].VHost_DefaultIconTheme='') then
        begin
          Context.sIconTheme:=garJVHost[Context.u2VHost].VHost_DefaultIconTheme;
        end;


        //   2012102114260173351   Headers Off
        //if not Context.CGIENV.CKY IN.FoundItem_saName('JASDISPLAYHEADERS') then
        //begin
        //  if not bVal(saJASUserPref(Context,bOk,2012102114260173351,u8Val(Context.rJSession.JSess_JUser_ID))) then sVal:='on' else sVal:='off';
        //  Context.CGIENV.AddCook ie(
        //  'JASDISPLAYHEADERS',
        //  sVal,
        //  Context.CGIENV.saRequestURIWithoutParam,
        //  dtAddMonths(now,1),
        //  false
        //);
        //end;

        //   2012102114270325598   Quick-Links
        //if not Context.CGIENV.CKY IN.FoundItem_saName('JASDISPLAYQUICKLINKS') then
        //begin
        //  if not bVal(saJASUserPref(Context,bOk,2012102114270325598,u8Val(Context.rJSession.JSess_JUser_ID))) then sVal:='on' else sVal:='off';
        //  Context.CGIENV.AddCook ie(
        //    'JASDISPLAYQUICKLINKS',
        //    sVal,
        //    Context.CGIENV.saRequestURIWithoutParam,
        //    dtAddMonths(now,1),
        //    false
        //  );
        //end;

      end;
      // END -------------------------  User Preferences
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - I');

      ExecuteJASApplication(Context);
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - J');
      if Context.CGIENV.uHTTPResponse=0 then Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
      Context.saOut:=self.Context.saPage;
      //ASPrintLn('u01j_worker - back from ExecuteJASApplication. PageLen:'+inttostR(length(self.Context.saPage)));
    end
    else

    if(Context.sMIMEType='execute/cgi')then
    begin
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - K');
      ExecuteCGI(Context);// Sets p_Context.CGIENV.uHTTPResponse accordingly.
      //AS_LOG(Context, cnLog_Debug, 201007281330,'Back from ExecuteCGI call','',SOURCEFILE);
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - L');
    end
    else
    
    if(Context.sMIMEType='execute/php')then
    begin
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - M');
      Context.bMIME_execute_PHP:=true;
      ExecuteCGI(Context);// Sets p_Context.CGIENV.uHTTPResponse accordingly.
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - N');
    end
    else
    
    if(Context.sMIMEType='execute/perl')then
    begin
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - O');
      Context.bMIME_execute_Perl:=true;
      ExecuteCGI(Context);// Sets p_Context.CGIENV.uHTTPResponse accordingly.
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - P');
    end
    else
    
    if bFileSoughtExists then
    begin
      if bInternalJob then JASPrintln('TWORKER.DispatchRequest - Q');
      self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;//ok
      bOk:=true;
      sa:=saSNRStr(self.Context.saFileSought,'/','[@SLASH@]');
      sa:=saSNRStr(sa,'[@SLASH@]','//');

      saQry:='(JDLFL_Filename='+Context.VHDBC.saDBMSScrub(self.Context.saFileSought)+
        ') and ((JDLFL_Deleted_b IS NULL) or (JDLFL_Deleted_b=false))';

      //asprintln(saRepeatChar('=',79));
      //ASPRintln('File Seeking where clause: ' +saQry);
      //asprintln(saRepeatChar('=',79));
      if Context.VHDBC.u8GetRecordCount('jdownloadfilelist', saQry, 2016040105)>=1 then
      begin
        //ASPRintln('File Seeking where clause: ' +saQry);
        bgotOne:=false;
        for uListOfs:=0 to length(garJipListLight)-1 do
        begin
          if garJIPListLight[uListOfs].sIPAddress=self.Context.rJSession.JSess_IP_ADDR then
          begin
            bGotOne:=true;
            //asprintln('Found em...');
            //asprintln('garJIPListLight[uListOfs].u2Downloads: '+inttostr(garJIPListLight[uListOfs].u2Downloads));
            //asprintln('grJASConfig.u2PunkBeGoneMaxDownloads: '+inttostr(grJASConfig.u2PunkBeGoneMaxDownloads));
            if garJIPListLight[uListOfs].u2Downloads>grJASConfig.u2PunkBeGoneMaxDownloads then
            begin
              // Ok - does the date save them? If So - maybe reset :)
              //riteln('garJIPListLight[uListOfs].dtDownLoad:',saFormatDateTime(csDATETIMEFORMAT,garJIPListLight[uListOfs].dtDownLoad));
              //riteln('now:',saFormatDateTime(csDATETIMEFORMAT,now));
              //riteln('iDiffDays(garJIPListLight[uListOfs].dtDownLoad, now):',iDiffDays(garJIPListLight[uListOfs].dtDownLoad, now));
              if iDiffDays(garJIPListLight[uListOfs].dtDownLoad, now)>1 then
              begin
                garJIPListLight[uListOfs].dtDownLoad:=now;
                garJIPListLight[uListOfs].u2Downloads:=0;//if this to "weak" we can tighten it up
              end
              else
              begin
                bOk:=false;
                JAS_Log(Context,cnLog_Error,201604281256,'Max Download Limit Reached. '+
                   'IP Address: '+Context.rJSession.JSess_IP_ADDR+' File: '+self.Context.saFileSought,'',sourcefile);
              end;
              break;
            end
            else
            begin
              garJIPListLight[uListOfs].u2Downloads+=1;
            end;
          end
        end;

        if (not bGotOne) and (not Context.bWhiteListed) then
        begin
          if not JIPListControl(Context.VHDBC,'D',Context.rJSession.JSess_IP_ADDR, 'Downloader', Context.rJSession.JSess_JUser_ID) then
          begin
            JAS_Log(Context,cnLog_Error,201604281258,'DBM_JIPList call failed creating download ip record.','',sourcefile);
          end;
        end;
      end
      else
      begin
      end;

  if bInternalJob then JASPrintln('TWORKER.DispatchRequest - R');

      if bOk then
      begin
        //ASPrintLn('grJASConfig.bPunkBeGoneSmackBadBots:'+sYesNo(grJASConfig.bPunkBeGoneSmackBadBots)+
        //  ' self.Context.saOriginallyRequestedFile:'+self.Context.saOriginallyRequestedFile);
        if grJASConfig.bPunkBeGoneSmackBadBots and (self.Context.saOriginallyRequestedFile = 'robots.txt') then
        begin
          if bFoundIPInJipListLight(Context.rJSession.JSess_IP_ADDR, uListOfs) and (garJIPListLight[uListOfs].bRequestedRobotsTxt)then
          begin
            Context.bHavePunkAmongUs:=true;
            JASPrintln('-<-<-<-<- BANNING BAD BOT ->->->->-');
            if not JIPListControl(Context.VHDBC,'B',Context.rJSession.JSess_IP_ADDR, 'Robot Ignored robots.txt DISALLOWED settings.', Context.rJSession.JSess_JUser_ID) then
            begin
              JAS_Log(Context,cnLog_Error,201605030451,'DBM_JIPList Smacking rude robot or user disregarding robots.txt.','',sourcefile);
            end
          end
          else
          begin
            JASPrintln('Observing Unwelcome bot, so far far they are being polite.');
            if not JIPListControl(Context.VHDBC,'R',Context.rJSession.JSess_IP_ADDR, 'robots.txt', Context.rJSession.JSess_JUser_ID) then
            begin
              JAS_Log(Context,cnLog_Error,201605030450,'DBM_JIPList call failed creating robot.txt download ip record.','',sourcefile);
            end;
            self.Context.saOut:='User-agent: *'+csCRLF+'Disallow: /'+csCRLF;
            self.Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
          end;
        end
        else
        begin
          //riteln('Normal get file serve');
          self.Context.saOut:=getfile(self.Context, self.Context.saFileSought, self.Context.CGIENV.uHTTPResponse);
        end;
      end
      else
      begin
        self.Context.saOut:='<html><center><h1>FILE DOWNLOAD LIMIT EXCEEDED</h1><br />'+
          '<a href="/" title="'+garJVHost[Context.u2VHost].VHost_ServerName+'">Home Page</a></center></html>'; // :)
      end;
    end;
  End;

  if bInternalJob then JASPrintln('TWORKER.DispatchRequest - END');


  //ASPrintln('bNoWebCache: '+sYesNo(self.Context.bNoWebCache));


  {$IFDEF DIAGMSG}
  JASPrintln(sTHIS_ROUTINE_NAME+': Part 9 Exit - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
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
  //bOk: Boolean;
  u2IOResult: word;
  flog: text;
  saFilename: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.OnTerminate;'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161925,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}

  saFileName:=grJASConfig.saSysDir+'log'+DOSSLASH+'diagnostic.'+Inttostr(Context.u8RequestUID)+'.log';
  JASDebugPrintln(sThis_routine_name+' :Writing to diagnostic log:'+saFileName);
  if bTSOpenTextFile(saFilename,u2IOResult,FLog,false,true) then
  begin
    ////If IOResult <> 0 Then Rewrite(fl);
    //JASDebugPrintln('diagnostic log: 100');
    Writeln(FLog,'DEBUG LOG ---------------------------------------------BEGIN');
    Writeln(FLog,'Context -------------------------------------BEGIN');
    writeln(flog,'Context.u8RequestUID                  : ',Context.u8RequestUID);
    Writeln(FLog,'Context.saRequestedHost               : ',Context.saRequestedHost);
    Writeln(FLog,'Context.saRequestedHostRootDir        : ',Context.saRequestedHostRootDir);
    Writeln(FLog,'Context.sRequestMethod                : ',Context.sRequestMethod);
    Writeln(FLog,'Context.sRequestType                  : ',Context.sRequestType);
    Writeln(FLog,'Context.saRequestedFile               : ',Context.saRequestedFile);
    Writeln(FLog,'Context.saOriginallyRequestedFile     : ',Context.saOriginallyRequestedFile);
    writeln(flog,'Context.saRequestURI                  : ',Context.saRequestURI);
    writeln(flog,'Context.saRequestedName               : ',Context.saRequestedName);
    writeln(flog,'Context.saRequestedDir                : ',Context.saRequestedDir);
    writeln(flog,'Context.saFileSought                  : ',Context.saFileSought);
    writeln(flog,'Context.saQueryString                 : ',Context.saQueryString);
    writeln(flog,'Context.u2HttpErrorCode               : ',Context.u2HttpErrorCode);
    writeln(flog,'Context.u2VHost                       : ',Context.u2VHost       );
    writeln(flog,'Context.sAlias                        : ',Context.sAlias        );
    writeln(flog,'Context.bMenuHasPAnels                : ',Context.bMenuHasPAnels);
    writeln(flog,'Context.sIconTheme                    : ',Context.sIconTheme    );
    Writeln(FLog,'Context.bSessionValid                 : ',Context.bSessionValid);
    Writeln(FLog,'Context.bErrorCondition               : ',Context.bErrorCondition);
    Writeln(FLog,'Context.u8ErrNo                       : ',Context.u8ErrNo);
    Writeln(FLog,'Context.saErrMsg                      : ',Context.saErrMsg);
    writeln(flog,'Context.saErrMsgMoreInfo              : ',Context.saErrMsgMoreInfo);
    Writeln(FLog,'Context.sServerIP                     : ',Context.sServerIP);
    Writeln(FLog,'Context.u2ServerPort                  : ',inttostr(Context.u2ServerPort));
    writeln(flog,'Context.sServerIPCGI                  : ',Context.sServerIPCGI);
    writeln(flog,'Context.u2ServerPortCGI               : ',inttostr(Context.u2ServerPortCGI));
    Writeln(FLog,'Context.saPage                        : ','withheld');
    Writeln(FLog,'Context.bLoginAttempt                 : ',Context.bLoginAttempt);
    Writeln(FLog,'Context.PAGESNRXDL                    : Instantiated');
    writeln(flog,'Context.saPageTitle                   : ',Context.saPageTitle);
    writeln(flog,'Context.JADOC Items                   : ',length(Context.JADOC));
    writeln(flog,'Context.dtRequested                   : ',formatdatetime(csDateTimeFormat,Context.dtRequested));
    writeln(flog,'Context.dtServed                      : ',formatdatetime(csDateTimeFormat,Context.dtServed));
    writeln(flog,'Context.dtFinished                    : ',formatdatetime(csDateTimeFormat,Context.dtFinished));
    writeln(flog,'Context.sLang                         : ',Context.sLang);
    Writeln(FLog,'Context.bOutputRaw                    : ',Context.bOutputRaw);
    Writeln(FLog,'Context.saHTMLRIPPER_Area             : ',Context.saHTMLRIPPER_Area);
    Writeln(FLog,'Context.saHTMLRIPPER_Page             : ',Context.saHTMLRIPPER_Page);
    Writeln(FLog,'Context.saHTMLRIPPER_Section          : ',Context.saHTMLRIPPER_Section);
    Writeln(FLog,'Context.u8MenuTopID                   : ',Context.u8MenuTopID);
    writeln(flog,'Context.saUserCacheDir                : ',Context.saUserCacheDir);
    writeln(flog,'Context.u8HelpID                      : ',inttostr(Context.u8HelpID));
    Writeln(FLog,'Context.u2ErrorReportingMode          : ',Context.u2ErrorReportingMode);
    Writeln(FLog,'Context.u2DebugMode                   : ',Context.u2DebugMode);
    writeln(flog,'Context.lpWorker                      : ',UINT(Context.lpWorker));
    Writeln(FLog,'Context.bMIME_execute                 : ',Context.bMIME_execute);
    Writeln(FLog,'Context.bMIME_execute_Jegas           : ',Context.bMIME_execute_Jegas);
    Writeln(FLog,'Context.bMIME_execute_JegasWebService : ',Context.bMIME_execute_JegasWebService);
    Writeln(FLog,'Context.bMIME_execute_php             : ',Context.bMIME_execute_php);
    Writeln(FLog,'Context.bMIME_execute_perl            : ',Context.bMIME_execute_perl);
    Writeln(FLog,'Context.sMIMEType                     : ',Context.sMIMEType);
    Writeln(FLog,'Context.bMimeSNR                      : ',sTrueFalse(Context.bMimeSNR));
    writeln(flog,'Context.saFileSoughtNoExt             : ',Context.saFileSoughtNoExt);
    writeln(flog,'Context.sFileSoughtExt                : ',Context.sFileSoughtExt);
    writeln(flog,'Context.sFileNameOnly                 : ',Context.sFileNameOnly);
    writelN(flog,'Context.sFileNameOnlyNoExt            : ',Context.sFileNameOnlyNoExt);
    Writeln(FLog,'Context.saIN                          : ',Context.saIN);
    Writeln(flog,'Context.saOUT                         : ','Withheld for your sanity');
    Writeln(FLog,'Context.uBytesRead                    : ',Context.uBytesRead);
    Writeln(FLog,'Context.uBytesSent                    : ',Context.uBytesSent);
    writeln(flog,'Context.saLogFile                     : ',Context.saLogFile);
    writeln(flog,'Context.bJASCGI                       : ',sYesNo(Context.bJASCGI));
    writeln(flog,'');
    Writeln(FLog,'Context.CGIENV.bPost                  : ',sTrueFalse(Context.CGIENV.bPost));
    Writeln(FLog,'Context.CGIENV.saPostContentType      : ',Context.CGIENV.saPostContentType);
    Writeln(FLog,'Context.CGIENV.iPostContentLength     : ',inttostr(Context.CGIENV.uPostContentLength));
    Writeln(FLog,'Context.CGIENV.saPostData             : BEGIN');
    Write(FLog,Context.CGIENV.saPostData);
    Writeln(FLog,'');
    Writeln(FLog,'Context.CGIENV.saPostData             : END');
    Writeln(FLog,'Context.CGIENV.iTimeZoneOffset        : ',inttostr(Context.CGIENV.iTimeZoneOffset));
    Writeln(FLog,'Context.CGIENV.uHTTPResponse          : ',inttostr(Context.CGIENV.uHTTPResponse));
    Writeln(FLog,'Context.CGIENV.saServerSoftware       : ',Context.CGIENV.saServerSoftware);
    writeln(flog,'');
    writeln(Flog,'Context.sActionType: ',Context.sActionType);
    writeln(FLog,'Context.MATRIX                          : Not Implemented in this log');
    writeln(FLog,'Context.LogXXDL                         : Not Implemented in this log');
    writeln(flog,'');
    writeln(FLog,'Context.rJSession.JSess_JSession_UID    : ',Context.rJSession.JSess_JSession_UID);
    writeln(FLog,'Context.rJSession.JSess_JSessionType_ID : ',Context.rJSession.JSess_JSessionType_ID);
    writeln(FLog,'Context.rJSession.JSess_IP_ADDR         : ',Context.rJSession.JSess_IP_ADDR);
    writeln(FLog,'Context.rJSession.JSess_PORT            : ',Context.rJSession.JSess_Port_u);
    writeln(FLog,'Context.rJSession.JSess_Connect_DT      : ',Context.rJSession.JSess_Connect_DT);
    writeln(FLog,'Context.rJSession.JSess_LastContact_DT  : ',Context.rJSession.JSess_LastContact_DT);
    writeln(FLog,'Context.rJSession.JSess_Username        : ',Context.rJSession.JSess_Username);
    writeln(flog,'Context.rJSession.JSess_JJobQ_ID        : ',Context.rJSession.JSess_JJobQ_ID);
    writeln(flog,'');
    writeln(FLog,'Context.rJUser.JUser_JUser_UID          : ',Context.rJUser.JUser_JUser_UID);
    writeln(FLog,'Context.rJUser.JUser_Name               : ',Context.rJUser.JUser_Name);
    writeln(FLog,'Context.rJUser.JUser_Password           : ',Context.rJUser.JUser_Password);
    writeln(FLog,'Context.rJUser.JUser_JPerson_ID         : ',Context.rJUser.JUser_JPerson_ID);
    writeln(FLog,'Context.rJUser.JUser_Enabled_b          : ',Context.rJUser.JUser_Enabled_b);
    writeln(FLog,'Context.rJUser.JUser_Admin_b            : ',Context.rJUser.JUser_Admin_b);
    writeln(FLog,'Context.rJUser.JUser_Login_First_DT     : ',Context.rJUser.JUser_Login_First_DT);
    writeln(FLog,'Context.rJUser.JUser_Login_Last_DT      : ',Context.rJUser.JUser_Login_Last_DT);
    writeln(FLog,'Context.rJUser.JUser_Password_Changed_DT: ',Context.rJUser.JUser_Password_Changed_DT);
    writeln(flog,'');
    writeln(FLog,'Context.iSessionResultCode              : ',Context.iSessionResultCode);
    writeln(flog,'');
    writeln(flog,'Context.JTrak_TableID      : ',Context.JTrak_TableID );
    writeln(flog,'Context.JTrak_JDType_u     : ',Context.JTrak_JDType_u);
    writeln(flog,'Context.JTRak_sPKeyColName : ',Context.JTRak_sPKeyColName);
    writeln(flog,'Context.JTrak_DBConOffset  : ',Context.JTrak_DBConOffset );
    writeln(flog,'Context.JTrak_Row_ID       : ',Context.JTrak_Row_ID  );
    writeln(flog,'Context.JTrak_bExist       : ',Context.JTrak_bExist  );
    writeln(flog,'Context.JTrak_sTable       : ',Context.JTrak_sTable  );
    writeln(flog,'');
    writeln(flog,'Context.sTheme           : ',Context.sTheme        );
    writeln(flog,'Context.u2LogType_ID     : ',Context.u2LogType_ID  );
    writeln(flog,'Context.bNoWebCache      : ',Context.bNoWebCache   );
    writeln(flog,'Context.bWhiteListed     : ',Context.bWhiteListed  );
    writeln(flog,'Context.bSaveSessionData : ',Context.bSaveSessionData);
    writeln(flog,'Context.bInternalJob     : ',Context.bInternalJob);
    writeln(flog,'');
    // JThread: TJTHREAD;
    if self.Context.REQVAR_XDL.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.REQVAR_XDL.NAME: ',Context.REQVAR_XDL.Item_saName);
        Writeln(FLog,'Context.REQVAR_XDL.DESC: ',Context.REQVAR_XDL.Item_saDesc);
        Writeln(FLog,'Context.REQVAR_XDL.VALU: ',Context.REQVAR_XDL.Item_saValue);
        Writeln(FLog,'');
      Until not Context.REQVAR_XDL.MoveNext;
    end;
    if self.Context.XML.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.XML.NAME: ',Context.XML.Item_saName);
        Writeln(FLog,'Context.XML.DESC: ',Context.XML.Item_saDesc);
        Writeln(FLog,'Context.XML.VALU: ',Context.XML.Item_saValue);
        Writeln(FLog,'');
      Until not Context.XML.MoveNext;
    end;
    if self.Context.CGIENV.ENVVAR.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.ENVVAR.NAME: ',self.Context.CGIENV.ENVVAR.Item_saName);
        Writeln(FLog,'Context.CGIENV.ENVVAR.DESC: ',self.Context.CGIENV.ENVVAR.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.ENVVAR.VALU: ',self.Context.CGIENV.ENVVAR.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.ENVVAR.MoveNext;
    end;
    if self.Context.CGIENV.DATAIN.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.DATAIN.NAME: ',self.Context.CGIENV.DATAIN.Item_saName);
        Writeln(FLog,'Context.CGIENV.DATAIN.DESC: ',self.Context.CGIENV.DATAIN.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.DATAIN.VALU: ',self.Context.CGIENV.DATAIN.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.DATAIN.MoveNext;
    end;
    //if self.Context.CGIENV.CKY IN.MoveFirst then
    //begin
    //  repeat
    //    Writeln(FLog,'Context.CGIENV.CKY IN.NAME: ',self.Context.CGIENV.CKY IN.Item_saName);
    //    Writeln(FLog,'Context.CGIENV.CKY IN.DESC: ',self.Context.CGIENV.CKY IN.Item_saDesc);
    //    Writeln(FLog,'Context.CGIENV.CKY IN.VALU: ',self.Context.CGIENV.CKY IN.Item_saValue);
    //    Writeln(FLog,'');
    //  Until not self.Context.CGIENV.CKY IN.MoveNext;
    //end;
    //if self.Context.CGIENV.CKY OUT.MoveFirst then
    //begin
    //  repeat
    //    Writeln(FLog,'Context.CGIENV.CKY OUT.NAME: ',self.Context.CGIENV.CKY OUT.Item_saName);
    //    Writeln(FLog,'Context.CGIENV.CKY OUT.DESC: ',self.Context.CGIENV.CKY OUT.Item_saDesc);
    //    Writeln(FLog,'Context.CGIENV.CKY OUT.VALU: ',self.Context.CGIENV.CKY OUT.Item_saValue);
    //    Writeln(FLog,'');
    //  Until not self.Context.CGIENV.CKY OUT.MoveNext;
    //end;
    if self.Context.CGIENV.HEADER.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.CGIENV.HEADER.NAME: ',self.Context.CGIENV.HEADER.Item_saName);
        Writeln(FLog,'Context.CGIENV.HEADER.DESC: ',self.Context.CGIENV.HEADER.Item_saDesc);
        Writeln(FLog,'Context.CGIENV.HEADER.VALU: ',self.Context.CGIENV.HEADER.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.CGIENV.HEADER.MoveNext;
    end;
    if self.Context.PAGESNRXDL.MoveFirst then
    begin
      repeat
        Writeln(FLog,'Context.PAGESNRXDL.NAME:',self.Context.PAGESNRXDL.Item_saName);
        Writeln(FLog,'Context.PAGESNRXDL.DESC:',self.Context.PAGESNRXDL.Item_saDesc);
        Writeln(FLog,'Context.PAGESNRXDL.VALU:',self.Context.PAGESNRXDL.Item_saValue);
        Writeln(FLog,'');
      Until not self.Context.PAGESNRXDL.MoveNext;
    end;
    if Context.SessionXDL.MoveFirst then
    begin
      repeat
        writeln(flog,'[SESSIONXDL Row ',Context.SessionXDL.N,']');
        writeln(flog,'Context.SessionXDL.UID: ',UID);
        writeln(flog,'Context.SessionXDL.saName: ', Context.SessionXDL.Item_saName);
        writeln(flog,'Context.SessionXDL.saValue: ',Context.SessionXDL.Item_saValue);
        writeln(flog,'Context.SessionXDL.saDesc: ', Context.SessionXDL.Item_saDesc);
        writeln(flog,'Context.SessionXDL.i8User: ', Context.SessionXDL.Item_i8User);
        writeln(flog,'Context.SessionXDL.TS', FormatDateTime(csDateTimeFormat,TimeStampToDateTime(JFC_XDLITEM(Context.SessionXDL.lpitem).TS)));//might need a tweak after
      until not Context.SessionXDL.Movenext;
    end;
    if Context.JTrakXDL.MoveFirst then
    begin
      repeat
        writeln(flog,'[JTRAKXDL Row ',Context.SessionXDL.N,']');
        writeln(flog,'Context.JTrakXDL.UID: ',Context.JTrakXDL.Item_UID);
        writeln(flog,'Context.JTrakXDL.saName: ', Context.JTrakXDL.Item_saName);
        writeln(flog,'Context.JTrakXDL.saValue: ',Context.JTrakXDL.Item_saValue);
        writeln(flog,'Context.JTrakXDL.saDesc: ', Context.JTrakXDL.Item_saDesc);
        writeln(flog,'Context.JTrakXDL.i8User: ', Context.JTrakXDL.Item_i8User);
        writeln(flog,'Context.JTrakXDL.TS', FormatDateTime(csDateTimeFormat,TimeStampToDateTime(JFC_XDLITEM(Context.JTrakXDL.lpitem).TS)));//might need a tweak after
      until not Context.SessionXDL.Movenext;
    end;
    Writeln(FLog,'Context -------------------------------------END');
    Writeln(FLog,'DEBUG LOG ---------------------------------------------END');
    Writeln(FLog,'');
    bTSCloseTextFile(saFilename, u2IOResult, FLog);
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
  rs:JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  sLogIPAddress: string[15];
  //sContextDropFileName: ansistring;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TWORKER.LogRequest;'; saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203161927,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(20120312, sTHIS_ROUTINE_NAME);{$ENDIF}
  rs:=nil;DBC:=nil;
  sLogIPAddress:='LogRequest';
  //if FileExists(Context.saLogFile) then
  //begin
    if bTSOpenTextFile(
      Context.saLogFile,
      u2IOResult,
      FLog,
      false,
      true) then
    begin
      {$I-}
      //127.0.0.1 - -
      //ASPrintln('access log top');
      if self.Context.bJASCGI then
        sLogIPAddress:=Context.CGIENV.ENVVAR.Get_saValue('REMOTE_ADDR')
      else
        sLogIPAddress:=Context.rJSession.JSess_IP_ADDR;
      Write(FLog,sLogIPAddress,' - - ');
      If IOResult=0 Then  //[04/Feb/2007:08:21:23 -0500]
        dtLog:=dtAddHours(Context.dtRequested,grJASConfig.i1TIMEZONEOFFSET);
      If IOResult=0 Then
        Write(FLog,'['+JDate('',18,0,dtLog)+' '+sZeroPadInt(grJASConfig.i1TIMEZONEOFFSET,2)+'00'+'] ');
      // "GET /robots.txt HTTP/1.0"
      If IOResult=0 Then
        Write(FLog, '"'+Context.REQVAR_XDL.Get_saDesc('REQUEST_METHOD')+'" ');
      If IOResult=0 Then
        Write(FLog,Context.u2HttpErrorCode,' ');
      If IOResult=0 Then
        Write(FLog,Context.uBytesSent,' ');
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
        {$IFDEF WINDOWS}
        Write(FLog,#13);
        {$ENDIF}
        Write(FLog,#10);
      end;
      {$I+}
      if bTSCloseTextFile(Context.saLogFile,u2IOResult,FLog)=FALSE then
      begin
        JAS_Log(Context,cnLog_WARN,200811081243,'Unable to properly Close :'+Context.saLogFile,'',sourcefile);
      end;
      //ASPrintln('access log bottom');
    end;
  //end;
  // LOGFILE END-----

  //ASPrintln('Log2Database Enabled: '+sYesNo(grJASConfig.bLogToDataBase));
  if garJVHost[Context.u2VHost].VHost_LogRequestsToDataBase_b then
  begin
    DBC:=Context.VHDBC;
    rs:=JADO_RECORDSET.create;
    saQry:=
      'INSERT INTO jrequestlog ('+
      'JRLOG_JRequestLog_UID,'+
      'JRLOG_DateNTime_DT,'+
      'JRLOG_JLogType_ID,'+
      'JRLOG_Entry_ID,'+
      'JRLOG_EntryData_sa,'+
      'JRLOG_SourceFile_s,'+
      'JRLOG_User_ID,'+
      'JRLOG_CmdLine,'+
      'JRLOG_SessionValid_b,'+
      'JRLOG_ErrorCondition_b,'+
      'JRLOG_ErrNo_u8,'+
      'JRLOG_ErrMsg_sa,'+
      'JRLOG_ErrMsgMoreInfo_sa,';
    saQry+='JRLOG_ServerIP,'+
      'JRLOG_ServerPort,'+
      //'JRLOG_Page_sa,'+
      'JRLOG_LoginAttempt_b,'+
      //'JRLOG_LogInMsg_sa,'+
      //'JRLOG_PageSNRXDL,'+
      'JRLOG_PageTitle_sa,'+
      'JRLOG_Requested_DT,'+
      'JRLOG_Served_DT,'+
      'JRLOG_Finished_DT,'+
      'JRLOG_Lang_s,'+
      'JRLOG_OutputRaw_b,'+
      'JRLOG_HtmlRipper_Area_sa,'+
      'JRLOG_HtmlRipper_Page_sa,'+
      'JRLOG_HtmlRipper_Section_sa,';
    saQry+=
      'JRLOG_MenuTopID_u8,'+
      'JRLOG_UserCacheDir_sa,'+
      'JRLOG_HelpID_s,'+
      'JRLOG_ErrorReportingMode_u2,'+
      'JRLOG_ErrorReportingSecureMessage_sa,'+
      'JRLOG_LogErrorsToDataBase_b,'+
      'JRLOG_LogMessagesShowOnServerConsole,';
    saQry+=
      'JRLOG_SQLTraceLogEnabled_b,'+
      'JRLOG_ServerConsoleMessagesEnabled,'+
      'JRLOG_DebugServerConsoleMessagesEnabled,'+
      'JRLOG_DebugMode_u2,'+
      'JRLOG_SessionTimeOutInMinutes_u2,';
    saQry+=
      'JRLOG_LockTimeOutInMinutes_u2,'+
      'JRLOG_LockRetriesBeforeFailure_u2,'+
      'JRLOG_LockRetryDelayInMSec_u2,'+
      'JRLOG_ValidateSessionRetryLimit_u2,'+
      'JRLOG_MaximumRequestHeaderLength_u,'+
      'JRLOG_CreateSocketRetry_u2,';
    saQry+=
      'JRLOG_CreateSocketRetryDelayInMSec,'+
      'JRLOG_SocketTimeOutInMSec_u2,'+
      'JRLOG_EnableSSL_b,'+
      'JRLOG_DefaultTheme_s,'+
      'JRLOG_DefaultIconTheme_s,'+
      'JRLOG_AccessLog_sa,'+
      'JRLOG_DefaultErrorLog_sa,'+
      'JRLOG_CreateHybridJets_b,'+
      'JRLOG_MimeType_s,'+
      'JRLOG_MimeSNR_b,'+
      'JRLOG_FileSoughtNoExt,'+
      'JRLOG_FileNameOnly,'+
      'JRLOG_FileSoughtExt,'+
      'JRLOG_FilenameOnlyNoExt,';
    saQry+=
      //'JRLOG_IN,'+
      //'JRLOG_OUT,'+
      //'JRLOG_REQVARXDL,'+
      'JRLOG_BytesRead,'+
      'JRLOG_BytesSent,'+
      'JRLOG_RequestedHost,'+
      'JRLOG_RequestedHostRootDir,'+
      'JRLOG_RequestMethod,'+
      'JRLOG_RequestType,'+
      'JRLOG_RequestedFile,'+
      'JRLOG_OriginallyRequestedFile,'+
      'JRLOG_RequestedName,'+
      'JRLOG_RequestedDir,'+
      'JRLOG_FileSought,'+
      'JRLOG_QueryString,';
    saQry+=
      'JRLOG_HttpErrorCode_u2,'+
      'JRLOG_LogFile,'+
      'JRLOG_JASCGI_b,'+
      //'JRLOG_XML,'+
      //'JRLOG_ENVVAR,'+
      //'JRLOG_DATAIN,'+
      //'JRLOG_CKY IN,'+
      //'JRLOG_CKY OUT,'+
      //'JRLOG_HEADER,'+
      //'JRLOG_FILESIN,'+
      'JRLOG_Post_b,'+
      'JRLOG_PostContentType,'+
      'JRLOG_PostContentLength,';



    saQry+=
      'JRLOG_PostData,'+
      'JRLOG_TimeZoneOffset_i2,'+
      'JRLOG_HttpResponse_u2,'+
      'JRLOG_ServerSoftware,'+
      'JRLOG_ActionType,'+
      //'JRLOG_MATRIX,'+
      //'JRLOG_LogXXDL,'+
      'JRLOG_JSession_ID,'+
      'JRLOG_SessionType_ID,'+
      'JRLOG_Sess_JUser_ID,'+
      'JRLOG_Connect_DT,'+
      'JRLOG_LastContact_DT,'+
      'JRLOG_IP_ADDR,';

    saQry+=
      'JRLOG_Port,'+
      'JRLOG_Username,'+
      'JRLOG_JobQ_ID,'+
      'JRLOG_SessionResultcode_i2,'+

      //'JRLOG_SessionXDL,'+
      'JRLOG_SaveSessionData_b,'+
      'JRLOG_InternalJob_b,'+
      //'JRLOG_JTrakXDL,'+
      'JRLOG_JTrak_Table_ID,'+
      'JRLOG_JTrak_JDType_u2,'+
      'JRLOG_JTrak_sPKeyCol,'+
      'JRLOG_JTrak_DBConID,';
    saQry+=
      'JRLOG_JTrak_Row_ID,'+
      'JRLOG_JTrak_Exist_b,'+
      'JRLOG_JTrak_Table_s,'+
      'JRLOG_Theme_s,'+
      'JRLog_VHost_i4,'+
      'JRLog_Alias,'+
      'JRLOG_ServerURL,'+
      'JRLOG_MenuHasPanels_b,'+
      'JRLOG_IconTheme_s,'+
      'JRLOG_LogType_ID,'+
      'JRLog_NoWebCache_b,'+
      'JRLog_WhiteListed_b';

    saQry+=
      ') VALUES ('+
      sGetUID +','+                                              //   JLOG_JLog_UID
      DBC.sDBMSDateScrub( now )+','+                                    //   JLOG_DateNTime_DT
      DBC.sDBMSUIntScrub( cnLog_REQUEST)+','+                        //   JLOG_JLogType_ID
      DBC.sDBMSUIntScrub( 0  )+','+                               //   JLOG_Entry_ID
      DBC.saDBMSScrub   ( 'Server Request Logged. grJASCOnfig.bLogToServer=TRUE')+','+                                 //   JLOG_EntryData_sa
      DBC.saDBMSScrub   ( SourceFile)+','+                           //   JLOG_SourceFile_s
      DBC.sDBMSUIntScrub( Context.rJUser.JUser_JUser_UID)+','+      //   JLOG_User_ID
      DBC.saDBMSScrub   ( saCmdLine)+',';                                //   JLOG_CmdLine
    saQry+=
      DBC.sDBMSBoolScrub( Context.bSessionValid)+','+                       //   JLOG_SessionValid_b
      DBC.sDBMSBoolScrub( Context.bErrorCondition)+','+                     //   JLOG_ErrorCondition_b
      DBC.sDBMSUIntScrub( Context.u8ErrNo)+','+                             //   JLOG_ErrNo_u8
      DBC.saDBMSScrub(    Context.saErrMsg)+','+                            //   JLOG_ErrMsg_sa
      DBC.saDBMSScrub(    Context.saErrMsgMoreInfo)+','+                    //   JLOG_ErrMsgMoreInfo_sa
      DBC.saDBMSScrub(    Context.sServerIP)+','+                           //   JLOG_ServerIP
      DBC.sDBMSUIntScrub(    Context.u2ServerPort)+','+                         //   JLOG_ServerPort
      //DBC.saDBMSScrub(    Context.saPage)+','+                              //   JLOG_Page_sa
      DBC.sDBMSBoolScrub( Context.bLoginAttempt)+',';                       //   JLOG_LoginAttempt_b
      //DBC.saDBMSScrub(  saLogInMsg)+','+                          //   JLOG_LogInMsg_sa
      //DBC.saDBMSScrub(    Context.PageSNRXDL.saHTMLTable)+',';        //   JLOG_PageSNRXDL
    saQry+=
      DBC.saDBMSScrub(    Context.saPageTitle)+','+                         //   JLOG_PageTitle_sa
      DBC.sDBMSDateScrub( Context.dtRequested)+','+                         //   JLOG_Requested_DT
      DBC.sDBMSDateScrub( Context.dtServed)+','+                            //   JLOG_Served_DT
      DBC.sDBMSDateScrub( Context.dtFinished)+','+                          //   JLOG_Finished_DT
      DBC.saDBMSScrub(    Context.sLang)+','+                               //   JLOG_Lang_s
      DBC.sDBMSBoolScrub( Context.bOutputRaw)+','+                          //   JLOG_OutputRaw_b
      DBC.saDBMSScrub(    Context.saHtmlRipper_Area)+','+                   //   JLOG_HtmlRipper_Area_sa
      DBC.saDBMSScrub(    Context.saHtmlRipper_Page)+','+                   //   JLOG_HtmlRipper_Page_sa
      DBC.saDBMSScrub(    Context.saHtmlRipper_Section)+','+                //   JLOG_HtmlRipper_Section_sa



      DBC.sDBMSUIntScrub( Context.u8MenuTopID)+','+                         //   JLOG_MenuTopID_u8
      DBC.saDBMSScrub(    Context.saUserCacheDir)+',';                      //   JLOG_UserCacheDir_sa
    saQry+=
      DBC.sDBMSUIntScrub(    Context.u8HelpID)+','+                             //   JLOG_HelpID_s
      DBC.sDBMSUIntScrub( grJASCOnfig.u2ErrorReportingMode)+','+                //   JLOG_ErrorReportingMode_u2
      DBC.saDBMSScrub(    grJASCOnfig.saErrorReportingSecureMessage)+','+       //   JLOG_ErrorReportingSecureMessage_sa
      DBC.sDBMSBoolScrub( garJVHost[Context.u2VHost].VHost_LogToDataBase_b)+','+                //   JLOG_LogErrorsToDataBase_b
      DBC.sDBMSBoolScrub( garJVHost[Context.u2VHost].VHost_LogToConsole_b)+','+     //   JLOG_LogMessagesShowOnServerConsole
      DBC.sDBMSBoolScrub( grJASCOnfig.bSQLTraceLogEnabled)+','+                 //   JLOG_SQLTraceLogEnabled_b
      DBC.sDBMSBoolScrub( grJASCOnfig.bServerConsoleMessagesEnabled)+','+       //   JLOG_ServerConsoleMessagesEnabled
      DBC.sDBMSBoolScrub( grJASCOnfig.bDebugServerConsoleMessagesEnabled)+','+  //   JLOG_DebugServerConsoleMessagesEnabled
      DBC.sDBMSUIntScrub( grJASCOnfig.u2DebugMode)+','+                         //   JLOG_DebugMode_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.u2SessionTimeOutInMinutes)+',';           //   JLOG_SessionTimeOutInMinutes_u2
    saQry+=
      DBC.sDBMSUIntScrub( grJASCOnfig.u2LockTimeOutInMinutes)+','+              //   JLOG_LockTimeOutInMinutes_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.u2LockRetriesBeforeFailure)+','+          //   JLOG_LockRetriesBeforeFailure_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.u2LockRetryDelayInMSec)+','+              //   JLOG_LockRetryDelayInMSec_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.u2ValidateSessionRetryLimit)+','+         //   JLOG_ValidateSessionRetryLimit_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.uMaximumRequestHeaderLength)+','+         //   JLOG_MaximumRequestHeaderLength_u
      DBC.sDBMSUIntScrub( grJASCOnfig.u2CreateSocketRetry)+','+                 //   JLOG_CreateSocketRetry_u2
      DBC.sDBMSUIntScrub( grJASCOnfig.u2CreateSocketRetryDelayInMSec)+','+      //   JLOG_CreateSocketRetryDelayInMSec
      DBC.sDBMSUIntScrub( grJASCOnfig.u2SocketTimeOutInMSec)+','+               //   JLOG_SocketTimeOutInMSec_u2
      DBC.sDBMSBoolScrub( grJASCOnfig.bEnableSSL)+','+                          //   JLOG_EnableSSL_b
      DBC.saDBMSScrub(    garJVHost[Context.u2VHost].VHost_DefaultTheme)+','+                       //   JLOG_DefaultTheme_s
      DBC.saDBMSScrub(    garJVHost[Context.u2VHost].VHost_DefaultIconTheme)+','+                   //   JLOG_DefaultIconTheme_s
      DBC.saDBMSScrub(    garJVHost[Context.u2VHost].VHost_AccessLog)+','+                  //   JLOG_AccessLog_sa
      DBC.saDBMSScrub(    garJVHost[Context.u2VHost].VHost_ErrorLog)+','+                   //   JLOG_ErrorLog_sa
      DBC.sDBMSBoolScrub( grJASCOnfig.bCreateHybridJets)+',';                       //   JLOG_CreateHybridJets_

    saQry+=
      DBC.saDBMSScrub(Context.sMimeType)+','+
      DBC.sDBMSBoolScrub(Context.bMimeSNR)+','+
      DBC.saDBMSScrub(Context.saFileSoughtNoExt)+','+
      DBC.saDBMSScrub(Context.sFileNameOnly)+','+
      DBC.saDBMSScrub(Context.sFileSoughtExt)+','+
      DBC.saDBMSScrub(Context.sFilenameOnlyNoExt)+',';
    //saQry+=DBC.saDBMSScrub(Context.saIN)+',';
    //saQry+=DBC.saDBMSScrub(Context.saOUT)+',';
    saQry+=
      //DBC.saDBMSScrub(Context.REQVAR_XDL.saHTMLTable)+','+
      DBC.sDBMSUIntScrub(Context.uBytesRead)+','+
      DBC.sDBMSUIntScrub(Context.uBytesSent)+','+
      DBC.saDBMSScrub(Context.saRequestedHost)+','+
      DBC.saDBMSScrub(Context.saRequestedHostRootDir)+','+
      DBC.saDBMSScrub(Context.sRequestMethod)+','+
      DBC.saDBMSScrub(Context.sRequestType)+','+
      DBC.saDBMSScrub(Context.saRequestedFile)+','+
      DBC.saDBMSScrub(Context.saOriginallyRequestedFile)+','+
      DBC.saDBMSScrub(Context.saRequestedName)+','+
      DBC.saDBMSScrub(Context.saRequestedDir)+','+
      DBC.saDBMSScrub(Context.saFileSought)+','+
      DBC.saDBMSScrub(Context.saQueryString)+','+
      DBC.sDBMSUIntScrub(Context.u2HttpErrorCode)+','+
      DBC.saDBMSScrub(Context.saLogFile)+','+
      DBC.sDBMSBoolScrub(Context.bJASCGI)+',';
    //saQry+=DBC.saDBMSScrub(Context.XML.saHTMLTable)+',';
    //saQry+=DBC.saDBMSScrub(Context.CGIENV.ENVVAR.saHTMLTable)+',';
    //saQry+=DBC.saDBMSScrub(Context.CGIENV.DATAIN.saHTMLTable)+',';
    //saQry+=
    //  DBC.saDBMSScrub(Context.CGIENV.CKY IN.saHTMLTable)+','+
    //  DBC.saDBMSScrub(Context.CGIENV.CKY OUT.saHTMLTable)+','+
    //  DBC.saDBMSScrub(Context.CGIENV.HEADER.saHTMLTable)+','+
    //  DBC.saDBMSScrub(Context.CGIENV.FILESIN.saHTMLTable)+',';
    saQry+=
      DBC.sDBMSBoolScrub(Context.CGIENV.bPost)+','+
      DBC.saDBMSScrub(Context.CGIENV.saPostContentType)+','+
      DBC.sDBMSUIntScrub(Context.CGIENV.uPostContentLength)+','+
    //
      DBC.saDBMSScrub(Context.CGIENV.saPostData)+','+
      DBC.sDBMSIntScrub(Context.CGIENV.iTimeZoneOffset)+','+
      DBC.sDBMSUIntScrub(Context.CGIENV.uHttpResponse)+','+
      DBC.saDBMSScrub(Context.CGIENV.saServerSoftware)+','+
      DBC.saDBMSScrub(Context.sActionType)+',';
    ////saQry+=DBC.saDBMSScrub(Context.MATRIX.saHTMLTable)+',';
    ////saQry+=DBC.saDBMSScrub(Context.LogXXDL.saHTMLTable)+',';
    saQry+=
      DBC.sDBMSUIntScrub(Context.rJSession.JSess_JSession_UID)+','+
      DBC.sDBMSUIntScrub(Context.rJSession.JSess_JSessionType_ID)+','+
      DBC.sDBMSUIntScrub(Context.rJSession.JSess_JUser_ID)+','+
      DBC.sDBMSDateScrub(Context.rJSession.JSess_Connect_DT)+','+
      DBC.sDBMSDateScrub(Context.rJSession.JSess_LastContact_DT)+','+
      DBC.saDBMSScrub(Context.rJSession.JSess_IP_ADDR)+','+
      DBC.sDBMSUIntScrub(Context.rJSession.JSess_Port_u)+','+
      DBC.saDBMSScrub(Context.rJSession.JSess_Username)+','+
      DBC.sDBMSUIntScrub(Context.rJSession.JSess_JJobQ_ID)+','+
      DBC.sDBMSIntScrub(Context.iSessionResultcode)+',';


    saQry+=
      //DBC.saDBMSScrub(Context.SessionXDL.saHTMLTable)+','+
      DBC.sDBMSBoolScrub(Context.bSaveSessionData)+','+
      DBC.sDBMSBoolScrub(Context.bInternalJob)+','+
      //DBC.saDBMSScrub(Context.JTrakXDL.saHTMLTable)+','+
      DBC.sDBMSUIntScrub(Context.JTrak_TableID)+','+
      DBC.sDBMSUIntScrub(Context.JTrak_JDType_u)+','+
      DBC.saDBMSScrub(Context.JTrak_sPKeyColName)+','+
      DBC.sDBMSUIntScrub(Context.JTrak_DBConOffset)+','+
      DBC.sDBMSUIntScrub(Context.JTrak_Row_ID)+','+
      DBC.sDBMSBoolScrub(Context.JTrak_bExist)+','+
      DBC.saDBMSScrub(Context.JTrak_sTable)+','+
      DBC.saDBMSScrub(Context.sTheme)+','+
      DBC.sDBMSIntScrub(Context.u2VHost)+','+
      DBC.saDBMSScrub(Context.sAlias)+','+
      DBC.saDBMSScrub(garJVHost[Context.u2VHost].VHost_ServerURL)+','+
      DBC.sDBMSBoolScrub(Context.bMenuHasPanels)+','+
      DBC.saDBMSScrub(Context.sIconTheme)+','+
      DBC.sDBMSUIntScrub(Context.u2LogType_ID)+','+
      DBC.sDBMSBoolScrub(Context.bNoWebCache)+','+
      DBC.sDBMSBoolScrub(Context.bWhiteListed)+
    ')';
    if not rs.open(saQry,DBC,201503161708) then
    begin
      JLOG(cnLog_Error,201008102109,'JAS_LOG is unable to record the current REQUEST entry into the database. Caller: '+SourceFile+' Query: '+saQry,SOURCEFILE);
    end;
    rs.Destroy;rs:=nil;
  end;



  //--DIAGNOSTIC--DIAGNOSTIC--
  //--DIAGNOSTIC--DIAGNOSTIC--
  //
  //if bInternalJob then
  //begin
  //  sContextDropFileName:=saAddSlash(grJASConfigsaLogDir)+'context-class-contents.xml';
  //  if bTSOpenTextFile(
  //    sContextDropFileName,
  //    u2IOResult,
  //    FLog,
  //    false,
  //    false) then
  //  begin
  //    //ASPrintLn('ABOUT to Render CONTEXT as XML');
  //    rite(flog,CONTEXT.saXML);
  //    //ASPrintLn('DONE Rendering CONTEXT as XML');
  //    bTSCloseTextFile(sContextDropFileName,u2IOResult,FLog)
  //  end;
  //end;
  //
  //--DIAGNOSTIC--DIAGNOSTIC--
  //--DIAGNOSTIC--DIAGNOSTIC--

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
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.CheckJobQ'; saStageNote:=sTHIS_ROUTINE_NAME; {$ENDIF}

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
    saQry:='select * from '+DBC.sDBMSEncloseObjectName('jjobq')+' where '+
      '(('+DBC.sDBMSEncloseObjectName('JJobQ_Completed_b')+' = false)or'+
      '('+DBC.sDBMSEncloseObjectName('JJobQ_Completed_b')+' is null)) and '+
      '('+DBC.sDBMSEncloseObjectName('JJobQ_Start_DT')+'<=now()) and ';
    saQry+=
      '(('+DBC.sDBMSEncloseObjectName('JJobQ_Started_DT')+' is null) or '+
      '('+DBC.sDBMSEncloseObjectName('JJobQ_Started_DT')+'=''0000-00-00 00:00:00'')) and '+
      '('+DBC.sDBMSEncloseObjectName('JJobQ_Enabled_b')+'=true) and '+
      '('+DBC.sDBMSEncloseObjectName('JJobQ_Deleted_b')+'<>'+DBC.sDBMSBoolScrub(true)+')';
    bOk:=rs.open(saQry,DBC,201503161610);
    //ASPRintln('==============================');
    //ASPrintln('201511232332 JOBQ CHECK SQL:');
    //ASPrintln(saQRY);
    //ASPRintln('==============================');
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004212014,'TWORKER.CheckJobQ - Trouble executing query.','Query: '+saQry,sourcefile, DBC, rs);
      //ASPrintln('201004212014 - TWORKER.CheckJobQ - Trouble executing query:'+saQry);
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
        JJobQ_JJobQ_UID        :=u8Val(rs.fields.Get_saValue('JJobQ_JJobQ_UID'));
        JJobQ_JUser_ID         :=u8Val(rs.fields.Get_saValue('JJobQ_JUser_ID'));
        JJobQ_JJobType_ID      :=u8Val(rs.fields.Get_saValue('JJobQ_JJobType_ID'));
        JJobQ_Start_DT         :=rs.fields.Get_saValue('JJobQ_Start_DT');
        JJobQ_ErrorNo_u        :=u8Val(rs.fields.Get_saValue('JJobQ_ErrorNo_u'));

        //JJobQ_Started_DT         :=rs.fields.Get_saValue('JJobQ_Started_DT');
        JJobQ_Started_DT:=FormatDateTime(csDATETIMEFORMAT,now);

        //JJobQ_Running_b            :=rs.fields.Get_saValue('JJobQ_Running_b');
        JJobQ_Running_b        :=true;

        JJobQ_Finished_DT      :=rs.fields.Get_saValue('JJobQ_Finished_DT');
        JJobQ_Name             :=rs.fields.Get_saValue('JJobQ_Name');
        JJobQ_Repeat_b         :=bVal(rs.fields.Get_saValue('JJobQ_Repeat_b'));
        JJobQ_RepeatMinute     :=rs.fields.Get_saValue('JJobQ_RepeatMinute');
        JJobQ_RepeatHour       :=rs.fields.Get_saValue('JJobQ_RepeatHour');
        JJobQ_RepeatDayOfMonth :=rs.fields.Get_saValue('JJobQ_RepeatDayOfMonth');
        JJobQ_RepeatMonth      :=rs.fields.Get_saValue('JJobQ_RepeatMonth');
        JJobQ_Completed_b      :=bVal(rs.fields.Get_saValue('JJobQ_Completed_b'));
        JJobQ_Result_URL       :=rs.fields.Get_saValue('JJobQ_Result_URL');
        JJobQ_ErrorMsg         :=rs.fields.Get_saValue('JJobQ_ErrorMsg');
        JJobQ_ErrorMoreInfo    :=rs.fields.Get_saValue('JJobQ_ErrorMoreInfo');
        JJobQ_Enabled_b        :=bVal(rs.fields.Get_saValue('JJobQ_Enabled_b'));
        JJobQ_Job              :=rs.fields.Get_saValue('JJobQ_Job');
        JJobQ_Result           :=rs.fields.Get_saValue('JJobQ_Result');
        JJobQ_JTask_ID         :=u8Val(rs.fields.Get_saValue('JJobQ_JTask_ID'));
      end;//with
    end;
    //else
    //begin
    //  ASPrintln('TWorker.CheckJobQ - Recordset empty. saQry: '+ saQry);
    //end;
  end;
  rs.close;

  if bOk then
  begin
    bOk:=rJJobQ.JJobQ_JUser_ID>0;
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_WARN,201004230127,'TWORKER.CheckJobQ - rJJobQ.JJobQ_JUser_ID equates to Zero:'+inttostr(rJJobQ.JJobQ_JUser_ID)+
        ' for jjobq.JJobQ_JJobQ_UID:'+inttostr(rJJobQ.JJobQ_JJobQ_UID),'',sourcefile);
      //ASPrintln('TWorker.CheckJobQ - UserID is Zero.');
    end;
  end;

  if bOk then
  begin
    //ASPrintln('TWorker.CheckJobQ - Running User Query');
    saQry:='select '+DBC.sDBMSEncloseObjectName('JUser_Name')+' from juser '+
      'where '+DBC.sDBMSEncloseObjectName('JUser_JUser_UID')+'='+DBC.sDBMSUIntScrub(rJJobQ.JJobQ_JUser_ID)+' and '+
      ' (('+DBC.sDBMSEncloseObjectName('JUser_Deleted_b')+'<>'+
      DBC.sDBMSBoolScrub(true)+')OR('+DBC.sDBMSEncloseObjectName('JUser_Deleted_b')+' IS NULL))';
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
    Context.CGIENV.DataIn.AppendItem_saName_N_saValue('JJobQ_JJobQ_UID',inttostr(rJJobQ.JJobQ_JJobQ_UID));
    //ASPrintln('201204170843 TWORKER.CheckJobQ - Calling CreateSession');
    bOk:=bJAS_CreateSession(Context);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004230129,'TWORKER.CheckJobQ - Unable to Create Session.','Query: '+saQry,sourcefile);
      //ASPrintln('201004230129 TWORKER.CheckJobQ - Unable to Create Session. Query: '+saQry+' USERNAME:'+saUsername+' JJobQ UID:'+rJJobQ.JJobQ_JJobQ_UID);
    end;
  end;
  rs.close;

  if bOk then
  begin
    Context.CGIENV.DataIn.AppendItem_saName_N_saValue('JSID',inttostr(Context.rJSession.JSess_JSession_UID));
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Calling ValidateSession');
    bOk:=bJAS_ValidateSession(Context);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201004230130,'TWORKER.CheckJobQ - Unable to Validate Session.','Query: '+saQry,sourcefile);
      //ASPrintLn('201004230130 TWORKER.CheckJobQ - Unable to Validate Session. Query: '+saQry);
    end;
  end;

  if bOk then
  begin
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Locking JOB Record');
    bOk:=bJAS_LockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,0,201501020071);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_Warn,201004212013,'TWORKER.CheckJobQ - Unable to lock jjobq record rJJobQ.JJobQ_JJobQ_UID:'+inttostr(rJJobQ.JJobQ_JJobQ_UID),'',sourcefile);
      //ASPrintln('201004212013 TWORKER.CheckJobQ - Unable to lock jjobq record rJJobQ.JJobQ_JJobQ_UID:'+inttostr(rJJobQ.JJobQ_JJobQ_UID));
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
      JAS_Log(CONTEXT,cnLog_ERROR,201004212121,'TWORKER.CheckJobQ - Problem Parsing JobQ Task in jjobq.JJobQ_JJobQ_UID:'+inttostr(rJJobQ.JJobQ_JJobQ_UID)+
        ' XML.saLastError:'+XML.saLastError,'',sourcefile);
      //ASPrintln('201004212121 TWORKER.CheckJobQ - Problem Parsing JobQ Task in jjobq.JJobQ_JJobQ_UID:'+inttostr(rJJobQ.JJobQ_JJobQ_UID)+' XML.saLastError:'+XML.saLastError);
    end;
  end;


    //if bTSOpenTextFile(
    //  grJASConfig.saLogDir+'context_newjobq.xml',
    //  u2IOResult,
    //  FLog,
    //  false,
    //  false) then
    //begin
    //  ASPrintLn('ABOUT to Render CONTEXT as XML after parsing task');
    //  rite(flog,CONTEXT.saXML);
    //  ASPrintLn('DONE Rendering CONTEXT as XML after parsing task');
    //  bTSCloseTextFile(grJASConfig.saLogDir+'context_newjobq.xml',u2IOResult,FLog)
    //end;

    // HERE turn TASK into usable stuff by TCONTEXT.. load up things like session info, reqvar, etc.
    //Context.bMimeSNR:=true;
    //Context.sMIMEType:='execute/jasapi';
    //Context.CGIENV.DATAIN.AppendItem_saName_N_saValue('JASAPI','helloworld');
    //Context.saFileNameOnlyNoExt:=Context.CGIENV.DATAIN.Item_saValue;

  if bOk then
  begin
    // update record but do not unlock yet
    //ASPrintln('201204170844 TWORKER.CheckJobQ - Saving JOBQ Record UID: '+rJJobQ.JJobQ_JJobQ_UID);
    bOk:=bJAS_Save_jjobq(Context, DBC, rJJobQ, true, true,201603310400);
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
    if bHaveLock then bJAS_UnLockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,0,201501020073);
  
    //if bNothingToDo then
    //begin
    //  ASPrintln('JOB-Q - CheckJobQ - Nothing to do.');
    //end
    //else
    //begin
    //  ASPrintln('JOB-Q - CheckJobQ - POSSIBLE ERROR - Check Log');
    //end;
    //ResetThread;// ResetThread was important when I could suspend thread but they took that away :(
  end
  else
  begin
    //ASPrintln('JOB-Q - CheckJobQ - !!!! TASK LAUNCHED !!!!');
  end;

  //AS_Log(CONTEXT,cnLog_DEBUG,201210011740,'TWORKER.CheckJobQ - END','',sourcefile);

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
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWorker.CompleteJobQTask';  saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}

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
    JJobQ_ErrorNo_u     :=Context.u8ErrNo;
    JJobQ_Running_b     :=false;
    JJobQ_Finished_DT   :=FormatDateTime(csDATETIMEFORMAT,dt);
    JJobQ_Completed_b   :=true;
    JJobQ_ErrorMsg      :=Context.saErrMsg;
    JJobQ_ErrorMoreInfo :=Context.saErrMsgMoreInfo;
    JJobQ_Result        :=self.Context.saOut;
  end;//with
  //ASPrintln('CompleteJOBQTask - Err: '+inttostr(Context.u8ErrNo)+' Msg: '+Context.saErrMsg+' More Info: '+Context.saErrMsgMoreInfo);

  //JAS_Log(CONTEXT,nLog_DEBUG,201210191510,'TWorker.CompleteJobQTask rJJobQ.JJobQ_Finished_DT: '+rJJobQ.JJobQ_Finished_DT,'',sourcefile);

  // Assure the correct Session UID is placed into Context.rJSession.JSess_JSession_UID before calling bJAS_Save_jjobq(?,?,?,false)
  //ASPrintln('CompleteJOBQTask - Saving JobQ Info');
  bOk:=bJAS_Save_jjobq(Context, DBC, rJJobQ, true, false,201603310401);
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
  //  rite(flog,CONTEXT.saXML);
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

  if bOk and rJJobQ.JJobQ_Repeat_b then
  begin
    //ASPrintln('CompleteJOBQTask - Handle JobQ Repeat');
    //AS_Log(CONTEXT,cnLog_Debug,201210191502,'TWorker.CompleteJobQTask - Entered REPEAT JOBQ CODE BLOCK.','',sourcefile);
    with rJJobQ do begin
      JJobQ_JJobQ_UID           :=0;
      //JJobQ_JUser_ID            :
      //JJobQ_JJobType_ID         :
      //JJobQ_Start_DT            :
      JJobQ_ErrorNo_u           :=0;
      JJobQ_Started_DT          :='';
      JJobQ_Running_b           :=false;
      JJobQ_Finished_DT         :='';
      //JJobQ_Name                : string;
      //JJobQ_Repeat_b            : string;
      //JJobQ_RepeatMinute        : string;
      //JJobQ_RepeatHour          : string;
      //JJobQ_RepeatDayOfMonth    : string;
      //JJobQ_RepeatMonth         : string;
      JJobQ_Completed_b         :=false;
      JJobQ_Result_URL          :='';
      JJobQ_ErrorMsg            :='';
      JJobQ_ErrorMoreInfo       :='';
      JJobQ_Enabled_b           :=true;
      //JJobQ_Job                 :='';
      JJobQ_Result              :='';
      JJobQ_CreatedBy_JUser_ID  :=0;
      JJobQ_Created_DT          :='';
      JJobQ_ModifiedBy_JUser_ID :=0;
      JJobQ_Modified_DT         :='';
      JJobQ_DeletedBy_JUser_ID  :=0;
      JJobQ_Deleted_DT          :='';
      JJobQ_Deleted_b           :=false;
      JAS_Row_b                 :=false;
      //JJobQ_JTask_ID            : ansistring;
    end;//with


    DecodeDate(dt,y,m,d);
    DeCodetime(dt,mh,n,s,ms);
    //h:=iMilitaryToNormalHours(mh);//hours (Mh or Military Hours still set to original value so no data loss)
    u2StartYear:=y;

    TK:=JFC_TOKENIZER.Create;
    TK.sWhiteSpace:=' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'+csCRLF+'!@#$%^&()_+=-,./\;''<>:";';
    TK.sSeparators:='/\';

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

    rJJobQ.JJobQ_Start_DT:=sZeroPadInt(u2StartYear,4)+'-'+sZeroPadInt(u1StartMonth,2)+'-'+sZeroPadInt(u1StartDayOfMonth,2)+' '+
      sZeroPadInt(u1StartHour,2)+':'+sZeroPadInt(u1StartMinute,2)+':00';
    bOk:=bJAS_Save_JJobQ(Context, DBC, rJJobQ, false, false,201603310402);
    if not bOk then
    begin
      JAS_Log(CONTEXT,cnLog_ERROR,201205291427,'TWorker.CompleteJobQTask - bSave_JJobQ failed.','',sourcefile);
    end;
    TK.Destroy;
  end;

  //ASPrintln('CompleteJOBQTask - Unlocking JobQ Record');
  // Make sure JJobQ Record Unlocked
  if not bJAS_UnLockRecord(Context, DBC.ID,'jjobq',rJJobQ.JJobQ_JJobQ_UID,0,201501020075) then
  begin
    //ASPrintln('CompleteJOBQTask - Problem Unlocking JobQ Record');
    JAS_Log(CONTEXT,cnLog_Warn,201210191531,'TWorker.CompleteJobQTask - Unable to unlock record: '+inttostr(rJJobQ.JJobQ_JJobQ_UID),'',sourcefile);
  end;
  

  //ASPrintln('JOB-Q - Completed JobQueue Task. OK: '+sYesNo(bOk));
  //AS_Log(CONTEXT,cnLog_DEBUG,201004212016,'TWorker.CompleteJobQTask - END bOk: '+sTrueFalse(bOk),'rJJobQ.JJobQ_JJobQ_UID - UID: '+inttostr(rJJobQ.JJobQ_JJobQ_UID),sourcefile);
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
  //TK: JFC_TOKENIZER;
  //iEQ: integer;

  saHeader: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ParseRequest';  saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}

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
  JASPrintln('ParseA00 - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  //self.Context.CGIENV.uHTTPResponse:=cnHTTP_Response_400;//<------TEST by FORCEFUL Breaking :D
  if (self.Context.CGIENV.uHTTPResponse = 0) then
  begin
    i:=pos(#13#10#13#10, Context.saIN);
    {$IFDEF DIAGMSG}
    //ASPrintln('ParseA01 - i:'+inttostr(i)+' Context.i4BytesRead:'+inttostr(Context.i4BytesRead));
    {$ENDIF}
    {$IFDEF DIAGMSG}
    //ASPrintln('ParseA02 - i:'+inttostr(i)+' grJASConfig.i4MaximumRequestHeaderLength:'+inttostr(grJASConfig.i4MaximumRequestHeaderLength));
    {$ENDIF}
    if (i<=1) or ((i>(Context.uBytesRead-3))and (Context.uBytesRead>=3)) or (i>(grJASConfig.uMaximumRequestHeaderLength-3)) then
    begin
      self.Context.CGIENV.uHTTPResponse:=cnHTTP_Response_400;
    end
    else
    begin
      saHeader:=copy(Context.saIN, 1, i + 1);
    end;
  end;

  {$IFDEF DIAGMSG}
  //ASPrintln('ParseB00 - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  // Check for Nulls, this is pascal but I still don't want inserted nulls... chr(0) bad form!
  // also need to weed out "mistake" or "binary" hits from where ever. I did have a bug where thread was
  // getting hung due to some unchecked binary in a header.. it was my own header - but we can't
  // let that happen!
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    i:=pos(#0,saHeader);
    if i>0 then self.Context.CGIENV.uHTTPResponse:=cnHTTP_Response_400;
  end;

  {$IFDEF DIAGMSG}
  //ASPrintln('ParseC00 - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  // The only hardcore testing I have time for ATM is done.
  // TODO: Revisit parsing the GET line for URI/RFC Compliancy
  // TODO: Add other request types - I think "PUT" is for uploading files.. haven't needed it yet
  if self.Context.CGIENV.uHTTPResponse=0 then
  begin
    if not ((saLeftStr(saHeader,3)='GET')or(saLeftStr(saHeader,4)='POST')) then self.Context.CGIENV.uHTTPResponse:=cnHTTP_Response_400;
  end;


  {$IFDEF DIAGMSG}
  //ASPrintln('ParseD00 - HTTP Response Code:'+inttostr(self.Context.CGIENV.uHTTPResponse));
  {$ENDIF}
  if self.Context.CGIENV.uHTTPResponse=0 then
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
              Context.sRequestMethod:=csINET_HDR_METHOD_GET;
              Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,4);
            End;

            If (pos(csINET_HDR_METHOD_POST+csSpace, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1) Then
            Begin
              //bPostOrGet:=True;
              Context.sRequestMethod:=csINET_HDR_METHOD_POST;
              Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,5);
              Context.CGIENV.saPostData:=copy(Context.saIN, pos(#13#10#13#10, Context.saIN)+4, length(Context.saIN));
              Context.CGIENV.uPostContentLength:=length(Context.CGIENV.saPostData);
              Context.CGIENV.bPost:=True;
            End;

            //If (pos(csINET_HDR_METHOD_JASCGI+csSpace, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1) Then
            //Begin
            //  //bPostOrGet:=True;
            //  Context.sRequestMethod:=csINET_HDR_METHOD_JASCGI;
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
            Context.sRequestType:=JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc;
            delete(Context.sRequestType,1,pos(' ',Context.sRequestType));
            delete(Context.sRequestType,1,pos(' ',Context.sRequestType));

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

          if (not bHandled) and
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

          //If (not bHandled) and
          //   (pos(csINET_HDR_COOK IE, JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saDesc)=1 )
          //Then
          //Begin
          //  {IFDEF DIAGMSG}
          //  ASPrintLn('Cook ie :)');
          //  {ENDIF}
          //  JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saName:=csCGI_HTTP_COOK IE;
          //  JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue:=JFC_XDLITEM( Context.REQVAR_XDL.lpItem ).saDesc;
          //  Delete(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue,1,8);
          //  // OK - NOW - to save processing time... stuff this directly into MYCGI
          //  If length(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue)>0 Then
          //  Begin
          //    TK:=JFC_TOKENIZER.Create;
          //    TK.SetDefaults;
          //    TK.sSeparators:=';';
          //    TK.sWhiteSpace:=';';
          //    TK.Tokenize(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue);
          //    //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_webrequest_cook ie.txt');
          //    If TK.ListCount>0 Then
          //    Begin
          //      TK.MoveFirst;
          //      repeat
          //        i:=length(TK.Item_saToken);
          //        iEQ:=pos('=',TK.Item_saToken);
          //        If iEQ>1 Then
          //        Begin
          //          self.Context.CGIENV.CKY IN.AppendItem_saName_N_saValue(
          //            Trim(Upcase(leftstr(TK.Item_saToken, iEQ-1))),
          //            trim(rightstr(TK.Item_saToken, i-iEQ)));
          //        End;
          //      Until not tk.movenext;
          //    End;
          //    TK.Destroy;
          //  End;
          //
          //  bHandled:=True;
          //End;
        End;
      Until not Context.REQVAR_XDL.MoveNext;
    End
    else
    begin
      self.Context.CGIENV.uHTTPResponse:=cnHTTP_Response_400;
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
procedure TWORKER.SetErrorReportingModeAndDebugModeFlags;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:=''; saStageNote:=sTHIS_ROUTINE_NAME; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201203102744,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201203102745, sTHIS_ROUTINE_NAME);{$ENDIF}

  Context.u2ErrorReportingMode:=grJASConfig.u2ErrorReportingMode;

  if(Context.u2ErrorReportingMode=cnSYS_INFO_MODE_VERBOSELOCAL)then
  begin
    if(Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP) or
      (Context.rJSession.JSess_IP_ADDR='127.0.0.1') then
    begin
      Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_VERBOSE;
    end
    else
    begin
      Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;
    end;
  end;

  Context.u2DebugMode:=grJASConfig.u2DebugMode;

  if(Context.u2DebugMode=cnSYS_INFO_MODE_VERBOSELOCAL)then
  begin
    if(Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP) or
      (Context.rJSession.JSess_IP_ADDR='127.0.0.1') or
      (Context.rJSession.JSess_IP_ADDR='173.9.43.105') or   // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='10.1.10.3') or    // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
      (Context.rJSession.JSess_IP_ADDR='173.9.43.106') then // JEGAS LLC 2010/2011  TODO: Un hardcode and make admin managable
    begin
      Context.u2DebugMode:=cnSYS_INFO_MODE_VERBOSE;
    end
    else
    begin
      Context.u2DebugMode:=cnSYS_INFO_MODE_SECURE;
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
  //TK2: JFC_TOKENIZER;
  saName: ansistring;
  saValue: ansistring;
  i:int;
  //iEQ: uint;
  saHeader: ansistring;
  iPosQuestionMark:int;
  saFirstchar: ansistring;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.ParseJASCGI';  saStageNote:=sTHIS_ROUTINE_NAME;{$ENDIF}

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
  //ASPrintln('i4BytesRead:'+inttostr(Context.i4BytesRead));
  //ASPrintln('i4BytesSent:'+inttostr(Context.i4BytesSent));
  //ASPrintln('uHTTPResponse:'+inttostr(Context.CGIENV.uHTTPResponse));
  //ASPrintln('dtRequested:'+datetostr(Context.dtrequested));
  //ASPrintln('saRequestedHost:'+Context.saRequestedHost);
  //ASPrintln('saRequestedHostRootDir:'+Context.saRequestedHostRootDir);
  //ASPrintln('sRequestMethod:'+Context.sRequestMethod);
  //ASPrintln('sRequestType:'+Context.sRequestType);
  //ASPrintln('saRequestedFile:'+Context.saRequestedFile);
  //ASPrintln('saOriginallyREquestedFile:'+Context.saOriginallyREquestedFile);
  //ASPrintln('saRequestedName:'+Context.saRequestedName);
  //ASPrintln('saRequestedDir:'+Context.saRequestedDir);
  //ASPrintln('saFileSought:'+Context.saFileSought);
  //ASPrintln('saQueryString:'+Context.saQueryString);
  //ASPrintln('saLogFile:'+Context.saLogFile);
  //ASPrintln('bJASCGI:'+sTrueFalse(Context.bJASCGI));
  //ASPrintln('Context b4 JASCGI -------------------------------END');
  }

  TK:=JFC_TOKENIZER.create;
  TK.sSeparators:=#13;
  TK.sWhitespace:=#13#10;
  if (self.Context.CGIENV.uHTTPResponse = 0) then
  begin
    i:=pos(#13#10#13#10, Context.CGIENV.saPostData);
    saHeader:=copy(Context.CGIENV.saPostData, 1, i + 1);
    Context.CGIENV.saPostData:=copy(Context.CGIENV.saPostData, i+4, length(Context.CGIENV.saPostData)-i+4);
    Context.CGIENV.uPostContentLength:=length(Context.CGIENV.saPostData);

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
          Context.sRequestMethod:=saValue;
          Context.CGIENV.bPost:=(Context.sRequestMethod=csINET_HDR_METHOD_POST);
        end else

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
        end else

        if saName=csCGI_HTTP_HOST then
        begin
          if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_HOST,true) then
          begin
            Context.REQVAR_XDL.Item_saValue:=saValue;
          end;
        end
        else
        begin
          Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
        end;

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
        end else

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
        end else

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
        end else

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
        end else

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
        end else

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
        end else

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
        end else

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
        end else

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
        end else

        //if saName=csCGI_HTTP_COOK IE then
        //begin
        //  if Context.REQVAR_XDL.FoundItem_saName(csCGI_HTTP_COOK IE,true) then
        //  begin
        //    Context.REQVAR_XDL.Item_saValue:=saValue;
        //  end
        //  else
        //  begin
        //    Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(saName,saValue,'JAS CGI');
        //  end;
        //  If length(JFC_XDLITEM(  Context.REQVAR_XDL.lpItem ).saValue)>0 Then
        //  Begin
        //    TK2:=JFC_TOKENIZER.Create;
        //    TK2.SetDefaults;
        //    TK2.sSeparators:=';';
        //    TK2.sWhiteSpace:=';';
        //    TK2.Tokenize(saValue);
        //    //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_webrequest_cook ie.txt');
        //    If TK2.ListCount>0 Then
        //    Begin
        //      TK2.MoveFirst;
        //      repeat
        //        i:=length(TK2.Item_saToken);
        //        iEQ:=pos('=',TK2.Item_saToken);
        //        If iEQ>1 Then
        //        Begin
        //          self.Context.CGIENV.CKY IN.AppendItem_saName_N_saValue(
        //            trim(Upcase(leftstr(TK2.Item_saToken, iEQ-1))),
        //            trim(rightstr(TK2.Item_saToken, i-iEQ)));
        //        End;
        //      Until not tk2.movenext;
        //    End;
        //    TK2.Destroy;
        //  End;
        //end else

        // Become the original Server (obviously will break networking but will allow
        // filtering by remote information
        if saName=csCGI_REMOTE_ADDR then Context.rJSession.JSess_IP_ADDR:=trim(saValue) else
        // Make current remote port still ok to use by commenting line below
        //if saName=csCGI_REMOTE_PORT then Context.saRemotePort:=saValue;

        // Let's keep the stock server info intact - as a form of masquerade
        if saName=csCGI_SERVER_ADDR then Context.sServerIPCGI:=saValue else
        if saName=csCGI_SERVER_PORT then Context.u2ServerportCGI:=u2Val(saValue) else

        // Can't do this yet - TODO: Make possible the relaying of the server software info - preserve
        // acrross the proxy
        //if XDL.FoundItem_saNAME(csCGI_SERVER_SOFTWARE) then Context.sServerSoftware=saValue;

        //if saName=csCGI_DOCUMENT_ROOT then Context.saRequestedDir:=saValue;
        if saName=csCGI_REQUEST_URI then
        begin
          Context.saRequestedFile:=saValue;
          Context.sarequesturi:=saValue;
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
            self.Context.saRequestedFile:=RightStr(self.Context.saRequestedFile, length(self.Context.saRequestedFile)-1);
          End;
          {$IFDEF DIAGMSG}
          JASPrintLn('jcore - parse request - self.Context.saRequestedFile:'+self.Context.saRequestedFile);
          {$ENDIF}


          self.Context.saRequestedFile:=saDecodeURI(self.Context.saRequestedFile);
          //ASPrintln('ParseJASCGI - Req File After processing: '+Context.saRequestedFile);
        end else

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
        Context.REQVAR_XDL.Item_saValue:=inttostr(Context.CGIENV.uPostContentLength);
      end
      else
      begin
        Context.REQVAR_XDL.AppendItem_saName_saValue_saDesc(csCGI_CONTENT_LENGTH,inttostr(Context.CGIENV.uPostContentLength),'JAS CGI');
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
  //ASPrintln('i4BytesRead:'+inttostr(Context.i4BytesRead));
  //ASPrintln('i4BytesSent:'+inttostr(Context.i4BytesSent));
  //ASPrintln('uHTTPResponse:'+inttostr(Context.CGIENV.uHTTPResponse));
  //ASPrintln('dtRequested:'+datetostr(Context.dtrequested));
  //ASPrintln('saRequestedHost:'+Context.saRequestedHost);
  //ASPrintln('saRequestedHostRootDir:'+Context.saRequestedHostRootDir);
  //ASPrintln('sRequestMethod:'+Context.sRequestMethod);
  //ASPrintln('sRequestType:'+Context.sRequestType);
  //ASPrintln('saRequestedFile:'+Context.saRequestedFile);
  //ASPrintln('saOriginallyREquestedFile:'+Context.saOriginallyREquestedFile);
  //ASPrintln('saRequestedName:'+Context.saRequestedName);
  //ASPrintln('saRequestedDir:'+Context.saRequestedDir);
  //ASPrintln('saFileSought:'+Context.saFileSought);
  //ASPrintln('saQueryString:'+Context.saQueryString);
  //ASPrintln('saLogFile:'+Context.saLogFile);
  //ASPrintln('bJASCGI:'+sTrueFalse(Context.bJASCGI));
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
procedure TWORKER.PunkBeGone;
//=============================================================================
var
  bWeGotzANuddaPunk: boolean;
  DBC: JADO_CONNECTION;
  sReason:string;
  sPunkBeGone: string;
  u2Errors: Int64;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TWORKER.PunkBeGone';  saStageNote:=sTHIS_ROUTINE_NAME; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBIN(201601091313,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}TrackThread(201601091314, sTHIS_ROUTINE_NAME);{$ENDIF}
  //bOk:=true;
  //ASprintln('BEGIN - worker.punkbegone');
  //result:=false;

  DBC:=Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bWeGotzANuddaPunk:=false;
  sReason:='';sPunkBeGone:='Punk-Be-Gone Offense: ';
  //u8Downloads:=0;
  u2Errors:=0;

  if (not bWeGotzANuddaPunk) and (Context.bErrorCondition or (self.Context.CGIENV.uHTTPResponse>=400)) then
  begin
    u2Errors+=1;
    bWeGotzANuddaPunk:= u2Errors > grJASConfig.u2PunkBeGoneMaxErrors;
    sReason:='Error Limit Reached: '+inttostr(grJASConfig.u2PunkBeGoneMaxErrors);
  end;

  if bWeGotzANuddaPunk and (not Context.bHavePunkAmongUs) and (not Context.bWhiteListed) then
  begin
    JASPrintln(sPunkBeGone+sReason);
    JIPListControl(DBC,'B', Context.rJSession.JSess_IP_ADDR, sPunkBeGone+sReason,0);
    //result:=true;
  end;
  //ASprintln('END - worker.punkbegone');
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}DBOUT(201601091340,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
