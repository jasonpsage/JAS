{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}



//=============================================================================
{ }
// Allow command line httpd requests to be made. Very raw test tool. Some
// (non standard perse - and persnickity servers may scoff you and send you
// a get lost response, while your browsers gets a warm welcome! =|:^)> )
program jegas_http_requester;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE=jegas_http_requester.pas}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{$IFDEF MIND_CHANGED_ABOUT_SENDING_SCRIPT}
  {$INFO CONFIGURED SO SCRIPTS AND REQUEST WILL BE TRANSMITTED TO JAS}
  {$INFO SERVER OVER THE WIRE!}
{$ELSE}
  {$INFO CONFIGURED SO ONLY REQUEST WILL BE TRANSMITTED TO JAS SERVER}
{$ENDIF}
//=============================================================================


//=============================================================================
Uses
//=============================================================================
  classes
  ,dos
  ,httpsend
  ,sysutils
  ;
//=============================================================================

//=============================================================================
const 
//=============================================================================
  csCRLF                                 = #13#10;
  csINET_HDR_CONTENT_LENGTH              ='Content-Length: ';
  csINET_HDR_CONTENT_TYPE                ='Content-Type: ';
  csMIME_TextPlain                       ='text/plain';
  csMIME_TextHtml                        ='text/html';
//  csCGI_GET                              = 'GET';
  csCGI_CONTENT_TYPE                     = 'CONTENT_TYPE';
  csCGI_CONTENT_LENGTH                   = 'CONTENT_LENGTH';
  csCGI_DOCUMENT_ROOT                    = 'DOCUMENT_ROOT';
//  csCGI_HTTP_ACCEPT                      = 'HTTP_ACCEPT';
//  csCGI_HTTP_ACCEPT_LANGUAGE             = 'HTTP_ACCEPT_LANGUAGE';
//  csCGI_HTTP_ACCEPT_ENCODING             = 'HTTP_ACCEPT_ENCODING';
//  csCGI_HTTP_ACCEPT_CHARSET              = 'HTTP_ACCEPT_CHARSET';
//  csCGI_HTTP_KEEPALIVE                   = 'HTTP_KEEPALIVE';//underscore not between keep and alive purposely.
//  csCGI_HTTP_CONNECTION                  = 'HTTP_CONNECTION';
//  csCGI_HTTP_COOKIE                      = 'HTTP_COOKIE';
//  csCGI_HTTP_HOST                        = 'HTTP_HOST';
//  csCGI_HTTP_REFERER                     = 'HTTP_REFERER';
//  csCGI_HTTP_USER_AGENT                  = 'HTTP_USER_AGENT';
//  csCGI_HTTP_JEGAS                       = 'HTTP_JEGAS';
  csCGI_PATH_INFO                        = 'PATH_INFO';
//  csCGI_POST                             = 'POST';
  csCGI_QUERY_STRING                     = 'QUERY_STRING';
//  csCGI_REMOTE_ADDR                      = 'REMOTE_ADDR';
//  csCGI_REMOTE_PORT                      = 'REMOTE_PORT';
  csCGI_REQUEST_METHOD                   = 'REQUEST_METHOD';
//  csCGI_REQUEST_URI                      = 'REQUEST_URI';
//  csCGI_SCRIPT_FILENAME                  = 'SCRIPT_FILENAME';
  csCGI_SCRIPT_NAME                      = 'SCRIPT_NAME';
//  csCGI_SERVER_SOFTWARE                  = 'SERVER_SOFTWARE';
//  csCGI_REDIRECT_STATUS                  = 'REDIRECT_STATUS';
//=============================================================================


//=============================================================================
Var // GLOBALS 
//=============================================================================
  HTTP: THTTPSend;
  saHOST: ansistring;
  saOut: ansistring;
//=============================================================================




//=============================================================================
// MAIN
//=============================================================================
Var 
  bSuccess: boolean;
  saErrorStr: AnsiString;
  {$IFDEF MIND_CHANGED_ABOUT_SENDING_SCRIPT}
  saDataIn: AnsiString;
  {$ENDIF}
  saDataOut: ansistring;
  //u2IOREsult:word;
//  i: integer;//debug thing
Begin
  
  If paramcount=1 Then Begin
    saHost:=paramstr(1);
    //writeln('Host:',saHost);
  End;
  
  saOut:='';// our parsed CGI env vars
  saDataOut:=''; // final result
  saErrorStr:='Send Failed';
  HTTP:=THTTPSend.create;
  bSuccess:=false;
  //HTTP.Headers.Add('Jegas: JAS-HTTP Requester 1.0.0');
  //HTTP.Headers.Add('Script: '+saScriptFullyQualifiedFilename+' Result:'+saStr(u2IOResult));//debug thing
  //HTTP.Headers.Add('DocRoot: '+saDocRoot);//debug thing
  //For i:=0 To paramcount Do HTTP.Headers.Add('Param '+saStr(i)+':'+paramstr(i));//debug thing
  try
    if HTTP.HTTPMethod('GET',saHost) then
    begin
      writeln('Begin ---- Cookies ----');
      write(Http.cookies.text);
      writeln('End   ---- Cookies ----');
      writeln;
      writeln('Begin ---- Headers ----');
      write(Http.headers.text);
      writeln('End   ---- Headers ----');
      writeln;
      
      write(csINET_HDR_CONTENT_TYPE+csMIME_TextHtml +csCRLF);
      write('Content-length: ' + inttostr(Http.Document.Size) + csCRLF+csCRLF);
      setlength(saDataOut,Http.Document.Size);
      Http.Document.ReadBuffer(PCHAR(saDataOut)^, Http.Document.Size);
      bSuccess:=true;
    end
    else
    begin
      saErrorStr:='Communication error with host. '+csCRLF+
                  'Host: '+saHOST+csCRLF+
                  'Result code: '+inttostr(Http.Resultcode);
    end;
  finally
  end;//try

  If not bSuccess then 
  Begin
    saDataOut:=saErrorStr+csCRLF;
    //saDataOut:=
    ////'HTTP/1.1 ' + '200 OK' + csCRLF +
    ////'MIME-version: 1.0'+csCRLF +
    ////'Allow: GET, POST'+csCRLF +
    //csINET_HDR_CONTENT_TYPE+csMIME_TextPlain +csCRLF+
    //'Content-length: ' + inttostr(length(saErrorStr)+4) + csCRLF+csCRLF +
    //saErrorStr+#13#10#13#10;
  End;
  write(saDataOut);
  HTTP.Free;
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

