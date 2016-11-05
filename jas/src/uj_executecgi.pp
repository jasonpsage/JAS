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
Unit uj_executecgi;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_executecgi.pp'}
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


{DEFINE SAVE_HTMLRIPPER_OUTPUT}
{$IFDEF SAVE_HTMLRIPPER_OUTPUT}
  {$INFO | SAVE_HTMLRIPPER_OUTPUT: TRUE}
{$ENDIF}

{DEFINE SAVE_ALL_OUTPUT}
{$IFDEF SAVE_ALL_OUTPUT}
  {$INFO | SAVE_ALL_OUTPUT: TRUE}
{$ENDIF}

{DEFINE DIAGNOSTIC_LOG}
{$IFDEF DIAGNOSTIC_LOG}
  {$INFO | DIAGNOSTIC_LOG: TRUE}
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
,syncobjs
,sysutils
,process
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_tokenizer
,uj_context
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
// This function handles executing processes using the CGI standard.
// e.g. CGI, exe, CGI Perl, CGI PHP
procedure ExecuteCGI(p_Context: TCONTEXT);
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
procedure ExecuteCGI(p_Context: TCONTEXT);
//=============================================================================
var
  filename: ansistring='';
  //sa:ansistring;
  M: TMemoryStream;
  BytesRead: Integer;
  N: Integer; 
  TK: JFC_TOKENIZER;
  iPos: integer;
  bPHPRedirect: boolean;
  {$IFDEF DIAGNOSTIC_WEB_MSG}
  bMIMEOutIsText: boolean;
  {$ENDIF}
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}

  Const READ_BYTES=2048;
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ExecuteCGI(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102317,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102318, sTHIS_ROUTINE_NAME);{$ENDIF}

  //result:='200 OK';
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;//ok
  BytesRead:=0;n:=0;
  // Begin ------------------------------------------------------------------- PROCESS INVOCATION
  // Begin ------------------------------------------------------------------- PROCESS INVOCATION
  // Begin ------------------------------------------------------------------- PROCESS INVOCATION
  // Begin ------------------------------------------------------------------- PROCESS INVOCATION
  // CGI Process Launching happens in here. Some mime type specific code laced
  // throughout as necessary for specific mime type behaviors - such as PHP and perl.
  {$ifdef WINDOWS}
    p_Context.saQueryString := StringReplace(p_Context.saQueryString, '%', '%%', [rfReplaceAll]);
  {$ELSE}
    p_Context.saQueryString := StringReplace(p_Context.saQueryString, '&', ';', [rfReplaceAll]);
  {$endif}
  //ASPRintln('200907241454 - Post Information Length:'+inttostr(Context.CGIENV.iPostContentLength)+ ' PostData:'+Context.CGIENV.saPostData);

  If p_Context.bMIME_execute_php Then
  Begin
    bPHPRedirect:=false;
    {$IFDEF DIAGNOSTIC_WEB_MSG}
    bMIMEOutIsText:=false;
    {$ENDIF}
    filename:=grJASConfig.saPHP + ' ' +p_Context.saFileSought;
  end
  else
  begin
    If p_Context.bMIME_execute_perl Then
    Begin
      //filename:=Context.saFileSought;
      filename:=grJASConfig.saPerl + ' ' +p_Context.saFileSought;
    End
    else
    begin
      filename:=p_Context.saFileSought;
      {$IFDEF WINDOWS}
      if upcase(rightstr(filename,4))='.CGI' then
      begin
        filename:=leftstr(filename,length(filename)-4)+'.exe';
      end;
      {$ENDIF}
    end;
  end;  

  if(length(filename)>0)then
  begin
    m:=TMemoryStream.Create;
    p_Context.PROCESS:=TProcess.Create(nil);
    p_Context.PROCESS.Environment.NameValueSeparator:='=';
    p_Context.Process.Currentdirectory:=p_Context.saRequestedDir;
    p_Context.Process.options:=p_Context.Process.options+[pousepipes];
    p_Context.Process.CommandLine:=filename + ' "' + p_Context.saQueryString + '"';
    {$IFDEF DIAGNOSTIC_WEB_MSG}
    JASPrintln('Process.Currentdirectory:'+Process.Currentdirectory);
    JASPRintln('Process.CommandLine:'+Process.CommandLine);
    {$ENDIF}
    
    
    
    //NOTE--------------------------------------START
    //NOTE--------------------------------------START
    //NOTE--------------------------------------START
    //NOTE--------------------------------------START
    //NOTE--------------------------------------START
    // This BLOCK Does work in that postdata is read in properly.... but I had issues
    // when toying with the values being submitted to the CGI process (php-cgi) while
    // trying to get sessions and stuff to work right, that the postdata stopped being
    // read in which had me doubting the TProcess class' ability to pipe in stdin.
    // SO FROM HERE to the end of this commented block    
    //if (p_Context.CGIENV.CKY IN.MoveFirst) then
    //begin
    //  sa:='';
    //  repeat
    //    sa+=p_Context.CGIENV.CKY IN.Item_saName+'='+p_Context.CGIENV.CKY IN.Item_saValue+'; ';
    //  until not p_Context.CGIENV.CKY IN.Movenext;
    //  p_Context.PROCESS.Environment.Add(csCGI_HTTP_COOK IE+'='+ sa );
    //
    //  //sa:='';
    //  //repeat
    //  //  p_Context.PROCESS.Environment.Add(csCGI_HTTP_COOK IE+'='+p_Context.CGIENV.CKY IN.Item_saName+'='+p_Context.CGIENV.CKY IN.Item_saValue);
    //  //  JAS_LOG(p_Context,cnLog_Debug, 201009141722,'COOK IE for Process Environment: '+csCGI_HTTP_COOK IE+'='+p_Context.CGIENV.CKY IN.Item_saName+'='+p_Context.CGIENV.CKY IN.Item_saValue,'',SOURCEFILE);
    //  //until not p_Context.CGIENV.CKY IN.Movenext;
    //
    //end;

    //JAS_Log(p_Context, cnLog_Debug, 201009141721,'COOK IE DUMP IN EXECUTE CGI: '+p_Context.CGIENV.CKY IN.saHtmlTable,'',SOURCEFILE);

    p_Context.PROCESS.Environment.Add(csCGI_REMOTE_ADDR+'='+p_Context.rJSession.JSess_IP_ADDR);
    p_Context.PROCESS.Environment.Add(csCGI_SERVER_SOFTWARE+'='+grJASConfig.sServerSoftware);
    p_Context.PROCESS.Environment.Add(csCGI_DOCUMENT_ROOT+'='+p_Context.saRequestedDir);
    {$IFDEF WINDOWS}
    p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_FILENAME+'='+saSNRStr(p_Context.saFileSought,'/','\'));
    {$ELSE}
    p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_FILENAME+'='+p_Context.saFileSought);
    {$ENDIF}
    p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_NAME+'='+p_Context.saRequestedFile);
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_USER_AGENT+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_USER_AGENT));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_HOST+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_HOST));
    p_Context.PROCESS.Environment.Add(csCGI_QUERY_STRING+'='+p_Context.saQueryString);
    p_Context.PROCESS.Environment.Add(csCGI_REQUEST_METHOD+'='+p_Context.sRequestMethod);
    p_Context.PROCESS.Environment.Add(csCGI_CONTENT_TYPE+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_CONTENT_TYPE));
    p_Context.PROCESS.Environment.Add(csCGI_CONTENT_LENGTH+'='+inttostr(p_Context.CGIENV.uPostContentLength));
    // TODO: Not sure what needs to be here, but a lack of anything seems to hang cgi run php
    // this is tied somehow to the php-cgi built in security features for running via cgi executable
    // and also there are some php.ini options related to it... but it's not really documented
    // well enough for me to know what to do with the values. I tossed "NONE" in there...
    // and most of the php functionality is working, but... I can't run a full php app yet.
    // NOW I'm also AWARE that unless I get an equivalent to apache's mod_rewrite, many php applications
    // like process maker won't run. I've been doing my testing on an opensource timeclock program that
    // doesn't use mod_rewrite... and it seems to almost work. 
    p_Context.PROCESS.Environment.Add(csCGI_REDIRECT_STATUS+'=200');
    //NOTE--------------------------------------END
    //NOTE--------------------------------------END
    //NOTE--------------------------------------END
    //NOTE--------------------------------------END
    //NOTE--------------------------------------END
    
    
    
    
    //if (p_Context.CGIENV.DATAIN.MoveFirst) then
    //begin
    //  repeat
    //    if p_Context.CGIENV.DATAIN.Item_saDesc <> 'QUERY_STRING' then p_Context.PROCESS.Environment.Add(p_Context.CGIENV.DATAIN.Item_saName+'='+p_Context.CGIENV.DATAIN.Item_saValue);
    //  until not p_Context.CGIENV.DATAIN.Movenext;
    //end;
    //if p_Context.CGIENV.ENVVAR.MoveFirst then
    //begin
    //  repeat
    //    if p_Context.CGIENV.ENVVAR.Item_saName > '' then p_Context.PROCESS.Environment.Add(p_Context.CGIENV.ENVVAR.Item_saName+'='+p_Context.CGIENV.ENVVAR.Item_saValue);
    //  until not p_Context.CGIENV.ENVVAR.MoveNext;
    //end;      
    //if self.p_Context.REQVAR_XDL.MoveFirst then
    //begin
    //  repeat
    //    if p_Context.REQVAR_XDL.Item_saName > '' then PROCESS.Environment.Add(p_Context.REQVAR_XDL.Item_saName+'='+p_Context.REQVAR_XDL.Item_saValue);
    //  until not p_Context.REQVAR_XDL.MoveNext;
    //end;      



    //------------------TODO: The items in this block were done based on comparing calls to PHP from Apache.
    //                        hardcoded values need to be corrected to come from legitimate sources (config file or something)
    //                        Note - I'm not certain what each feature is... like q=0.8 or q=0.9 on the HTTP_ACCEPT for example
    //                        I know what keep alives are and I don't choose to use them due to the unreliability of it's 
    //                        implementation in various browsers... I like speed gains - but it's a hodge podge protocol to my 
    //                        knowledge.
    //                        Also - somewhere buried in here is probably a data value that says the server does multi-part forms. 
    //                        at this point 200907242052 - JAS doesn't support multipart forms - at least no code was written for
    //                        that.
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_ACCEPT+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_ACCEPT));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_ACCEPT_LANGUAGE+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_ACCEPT_LANGUAGE));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_ACCEPT_ENCODING+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_ACCEPT_ENCODING));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_ACCEPT_CHARSET+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_ACCEPT_CHARSET));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_KEEPALIVE+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_KEEPALIVE));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_CONNECTION+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_CONNECTION));
    p_Context.PROCESS.Environment.Add(csCGI_HTTP_REFERER+'='+p_Context.REQVAR_XDL.Get_saValue(csCGI_HTTP_REFERER));
    p_Context.PROCESS.Environment.Add('SERVER_SIGNATURE=Jegas Application Server/'+  grJegasCommon.sVersion+' '+p_Context.saRequestedHost+' Port:'+inttostr(p_Context.u2ServerPort));
    p_Context.PROCESS.Environment.Add('SERVER_NAME='+p_Context.saRequestedHost);
    p_Context.PROCESS.Environment.Add('SERVER_ADDR='+p_Context.sServerIP);
    p_Context.PROCESS.Environment.Add('SERVER_PORT='+inttostr(p_Context.u2ServerPort));
    p_Context.PROCESS.Environment.Add('DOCUMENT_ROOT='+p_Context.saRequestedHostRootDir);// sample: /xfiles/inet/web/root80vhost
    p_Context.PROCESS.Environment.Add('SERVER_ADMIN=webmaster@jegas.com');
    p_Context.PROCESS.Environment.Add('GATEWAY_INTERFACE=CGI/1.1');
    p_Context.PROCESS.Environment.Add('SERVER_PROTOCOL=HTTP/1.1');
    p_Context.PROCESS.Environment.Add('REQUEST_URI=/'+p_Context.saOriginallyRequestedfile); //  sample: /novo1/phpinfo.php
    //p_Context.PROCESS.Environment.Add('PHP_SELF=/'+p_Context.saOriginallyRequestedfile); //  sample: /novo1/phpinfo.php
    //p_Context.PROCESS.Environment.Add('REQUEST_TIME='+inttostr(datetimetounix(now)));
    //p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_NAME+'='+p_Context.saRequestedFile);
    //p_Context.PROCESS.Environment.Add(csCGI_REMOTE_ADDR+'='+p_Context.saRemoteIP);
    //p_Context.PROCESS.Environment.Add(csCGI_REMOTE_PORT+'='+p_Context.saRemotePort);
    //p_Context.PROCESS.Environment.Add(csCGI_SERVER_SOFTWARE+'='+grJASConfig.saServerSoftware);
    //p_Context.PROCESS.Environment.Add(csCGI_DOCUMENT_ROOT+'='+p_Context.saRequestedDir);
    //{$IFDEF WINDOWS}
    //  p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_FILENAME+'='+saSNRStr(p_Context.saFileSought,'/','\'));
    //{$ELSE}
    //  p_Context.PROCESS.Environment.Add(csCGI_SCRIPT_FILENAME+'='+p_Context.saFileSought);
    //{$ENDIF}
    //p_Context.PROCESS.Environment.Add(csCGI_QUERY_STRING+'='+p_Context.saQueryString);
    //p_Context.PROCESS.Environment.Add(csCGI_REQUEST_METHOD+'='+p_Context.saRequestMethod);
    
    
    
    { // just here for reference - delete when you like
      p_Context.saRequestedHost
      p_Context.saRequestedHostRootDir 
      p_Context.saRequestMethod:='';
      p_Context.saRequestType:='';
      p_Context.saRequestedFile:='';
      p_Context.saRequestedName:='';
      p_Context.saRequestedDir:='';
      p_Context.saFileSought:='';
      p_Context.saQueryString:='';
    }    
    
    {$IFDEF DIAGNOSTIC_WEB_MSG}
    JASPrint('Process.Execute Firing Now...');
    {$ENDIF}

    try
      p_Context.Process.Execute;
    except
      // um - just don't stop running :)
      {$IFDEF DIAGNOSTIC_WEB_MSG}
      JASPrintln('Had an exception caught in ExecuteCGI');
      JASPrintln('CommandLine:'+p_Context.Process.CommandLine);
      {$ENDIF}
    end;
    
    {$IFDEF DIAGNOSTIC_WEB_MSG}
    JASPrintln('Done!');
    {$ENDIF}
    
    // TODO: Note this does work but I need to keep an eye on blowing up the input length
    // limit that might exist from a buffer perspective. Perhaps its handled already,
    // if not, we might need to read back some value from Process.Input.Write function to 
    // get a count of how many bytes were accepted, and write code to yield, loop, and 
    // keep feeding it data as fast as it will take it - empting the buffer as we do it.  
    if p_Context.CGIENV.bPost then p_Context.Process.Input.Write(PCHAR(p_Context.CGIENV.saPostData)^,length(p_Context.CGIENV.saPostData));
    
    While p_Context.Process.Running Do
    Begin          
      M.SetSize(BytesRead + READ_BYTES);// make sure we have room
      n := p_Context.Process.Output.Read((M.Memory + BytesRead)^, READ_BYTES);//// try reading it
      If n > 0 Then Begin Inc(BytesRead, n); End Else Begin Yield(100); End;
    End;
  
    // read last part
    repeat
      M.SetSize(BytesRead + READ_BYTES);// make sure we have room
      n := p_Context.Process.Output.Read((M.Memory + BytesRead)^, READ_BYTES);// try reading it
      If n > 0 Then Inc(BytesRead, n); 
    Until n <= 0;
    M.SetSize(BytesRead);
    setlength(p_Context.saOut,M.Size);
    M.ReadBuffer(PCHAR(p_Context.saOut)^, M.Size);
    M.Destroy;M:=nil;
    p_Context.PROCESS.Destroy;p_Context.Process:=nil;

    
    // IF NOT a NPH- (Non Parsed HEader then ...
    If false=(length(filename)>4) and (uppercase(copy(filename,1,4))='NPH-')Then
    Begin
      {$IFDEF DIAGNOSTIC_WEB_MSG}
      //ASPrintln('::::::::::::::::Final Result BEFORE Adding HEADER  -BEGIN');
      //ASPRint(p_Context.saOut);
      //ASPrintln('::::::::::::::::Final Result BEFORE Adding HEADER  -END');
      {$ENDIF}  
      If p_Context.bMIME_execute_php Then
      Begin
        iPos:=pos(csCRLF+csCRLF,  p_Context.saOut);
        if iPos>0 then
        begin
          TK:=JFC_TOKENIZER.Create;
          TK.sSeparators:=csCR;
          TK.sWhiteSpace:=csCRLF;
          TK.Tokenize(saLeftStr(p_Context.saOut,iPos));
          if(TK.MoveFirst) then
          begin
            bPHPRedirect:=(TK.Item_saToken='Status: 302');
          end;
          {$IFDEF DIAGNOSTIC_WEB_MSG}
          bMIMEOutIsText:=TK.FoundItem_saToken('Content-type: text/html',false);
          {$ENDIF}
          
          { This code block seeks a cook ie out put with path like path=/ and makes sure it has the correct path on it.. path=/admin/
          if(TK.MoveFirst) then
          begin
            repeat
              if saLeftStr(TK.Item_saToken,12)='Set-Cook ie: ' then
              begin
                if saRightStr(TK.Item_saToken,6)='path=/' then 
                begin
                  asprintln('******************************GOT MESSED COOK IE');
                  if length(p_Context.saoriginallyrequestedfile)>0 then
                  begin
                    sa:=sareverse(p_Context.saoriginallyrequestedfile);
                    sa:=sareverse(sarightstr(sa,length(sa)-pos('/',sa)));
                    asprintln('sa:'+sa);
                    p_Context.saOut:=saSNRStr(p_Context.saOut,TK.Item_saToken+#13,TK.Item_saToken+sa+'/'+#13);
                    
                    with p_Context do begin 
                      //asprintln('saIN:'+sain);
                      //asprintln('saOut:'+saout);
                      //asprintln('REQVAR_XDL:'+REQVAR_XDL.sahtmltable);
                      asprintln('saRemoteIP:'+saRemoteIP);
                      asprintln('saRemotePort:'+saREmotePort);
                      asprintln('saServerIP:'+saServerIP);
                      asprintln('saServerPort:'+saServerPort);
                      asprintln('i4BytesRead:'+inttostr(i4bytesread));
                      asprintln('i4BytesSent:'+inttostr(i4bytessent));
                      asprintln('bBlackListed:'+satruefalse(bBlacklisted));
                      asprintln('bWhiteListed:'+satruefalse(bWhitelisted));
                      asprintln('bAccessDenied:'+satruefalse(bAccessdenied));
                      asprintln('dtRequested:'+saFormatDateTime(csDATETIMEFORMAT,dtRequested));
                      asprintln('saRequestedHost:'+saREquestedhost);
                      asprintln('saRequestedHostRootDir:'+sarequestedhostrootdir);
                      asprintln('saRequestMethod:'+sarequestmethod);
                      asprintln('saRequestType:'+sarequesttype);
                      asprintln('saRequestedFile:'+sarequestedfile);
                      asprintln('saOriginallyREquestedFile:'+saoriginallyrequestedfile);
                      asprintln('saRequestedName:'+sarequestedname);
                      asprintln('saRequestedDir:'+sarequesteddir);
                      asprintln('saFileSought:'+safilesought);
                      asprintln('saQueryString:'+saquerystring);
                      asprintln('i4ErrorCode:'+inttostr(i4errorcode));
                      asprintln('saLogFile:'+salogfile);
                    end;//endwith
                  end;
                end;
              end; 
            until (TK.Item_saToken='') or (not TK.MoveNext);
          end;
          }
          
          
          TK.Destroy;
        end;
        if bPHPRedirect then 
        begin      
          p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_302;
        end;
      end;
      
      if upcase(leftstr(p_Context.saRequestedFile,4))<>'NPH-' then
      begin
        p_Context.saOut := 'HTTP/1.1 ' + p_Context.CGIENV.saHTTPResponse + csCRLF + p_Context.saOut;
      end
      else
      begin
        // just make sure no headers set
        p_Context.CGIENV.Header.DeleteAll;
      end;
    End;         
  end
  else
  begin
    p_Context.saOut:=p_Context.CGIENV.saHTTPServerError500(200903211212,'Server Error - ExecuteCGI','Server Error', p_Context.sMimeType);
  end;
  // END ------------------------------------------------------------------- PROCESS INVOCATION
  // END ------------------------------------------------------------------- PROCESS INVOCATION
  // END ------------------------------------------------------------------- PROCESS INVOCATION
  // END ------------------------------------------------------------------- PROCESS INVOCATION

  {$IFDEF DIAGNOSTIC_WEB_MSG}
  jASPrintln('');
  jASPrintln('::::::::::::::::Final Result AFTER Adding HEADER  -BEGIN');
  if bMIMEOutIsText then JASPRint(p_Context.saOut);
  jASPrintln('::::::::::::::::Final Result AFTER Adding HEADER  -END');
  {$ENDIF}  
   
  if p_Context.CGIENV.uHTTPResponse=0 then p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102319,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
