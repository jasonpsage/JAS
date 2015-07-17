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
// Jegas Application Server - CGI Thin Client
program jegas_cgi_thin_client;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE=jegas_cgi_thin_client.pas}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
Uses
//=============================================================================
  classes
  ,dos
  {$IFDEF linux}
  ,baseunix
  {$ENDIF}
  ,ug_misc
  ,httpsend
  ;
//=============================================================================


//=============================================================================
const 
//=============================================================================
  //csJASCGI_Config_File                   = '/etc/jas-cgi.cfg';
  //csJASCGI_Config_File                   = 'c:\wfiles\code\jas\config\jas-cgi.cfg';
  csJASCGI_Config_File                   = '/xfiles/inet/jas/jegas/config/jas-cgi.cfg';
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
  sa:AnsiString;
  saBeforeEqual: AnsiString;
  HTTP: THTTPSend;
  saJASHOST: ansistring;
  
  //saScriptFullyQualifiedFilename: ansistring;
  //iScriptLength: integer;
  saDocRoot: ansistring;
  saPathInfo: ansistring;
  saOut: ansistring;
  //saJetHtml: ansistring;
//=============================================================================



//=============================================================================
function RenderErrorPage(i8Err: int64; saErrorStr: ansistring): ansistring;
//=============================================================================
var sa: ansistring;
begin
sa:=
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'+csCRLF+
'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >'+csCRLF+
'<head>'+csCRLF+
'  <title>JAS CGI MESSAGE</title>'+csCRLF+
'  <!-- www.jegas.com - Jegas, LLC-Virtually Everything IT(TM)-Copyright(c)2015 -->'+csCRLF+
'  <!--      _________ _______  _______  ______  _______                        -->'+csCRLF+
'  <!--     /___  ___// _____/ / _____/ / __  / / _____/                        -->'+csCRLF+
'  <!--        / /   / /__    / / ___  / /_/ / / /____                          -->'+csCRLF+
'  <!--       / /   / ____/  / / /  / / __  / /____  /                          -->'+csCRLF+
'  <!--  ____/ /   / /___   / /__/ / / / / / _____/ /                           -->'+csCRLF+
'  <!-- /_____/   /______/ /______/ /_/ /_/ /______/                            -->'+csCRLF+
'  <!--                                                                         -->'+csCRLF+
'  <!-- www.jegas.com - Jegas, LLC-Virtually Everything IT(TM)-Copyright(c)2015 -->'+csCRLF+
''+csCRLF+ 
'  <!-- BEGIN - THEME RELATED -->'+csCRLF+
'  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'+csCRLF+
'  <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />'+csCRLF+
'  <script type="text/javascript"        src= "/jws/themes/black/script.js"></script>'+csCRLF+
'  <link rel="stylesheet" href="/jws/themes/black/style.css" type="text/css" media="screen" />'+csCRLF+
'  <!--[if IE 6]><link rel="stylesheet" href="/jws/themes/black/style.ie6.css" type="text/css" media="screen" /><![endif]-->'+csCRLF+
'  '+csCRLF+
'  <!--[if IE 7]><link rel="stylesheet" href="/jws/themes/black/style.ie7.css" type="text/css" media="screen" /><![endif]-->'+csCRLF+
''+csCRLF+
'  <link rel="stylesheet" href="/jws/themes/black/jas_custom.css" type="text/css" media="screen" />'+csCRLF+
'  <!-- END - THEME RELATED -->'+csCRLF+
'  '+csCRLF+
'  '+csCRLF+
'  <!-- BEGIN - JAS STUFF -->'+csCRLF+
'  <link rel="stylesheet" href="/jws/css/jas.css" type="text/css" media="screen" />'+csCRLF+
'  <script type="text/javascript" src="/jws/script/jas_customizations.js"></script>'+csCRLF+
'  <script type="text/javascript" src="/jws/script/jegas.js"></script>'+csCRLF+
'  '+csCRLF+
'  <script type="text/javascript" src="/jws/iwf/iwf_complete.js"></script>'+csCRLF+
'  <!-- END - JAS STUFF -->'+csCRLF+
''+csCRLF+  
''+csCRLF+  
'  <!-- JASCID: 201106222242 - jegas_cgi_thin_client4.pp -->'+csCRLF+
'</head>'+csCRLF+
''+csCRLF+
'<body onload="PageOnLoad('');" >'+csCRLF+
'  <div id="jas-page-background-simple-gradient"><div id="jas-page-background-gradient"></div></div>'+csCRLF+
'  <div id="jas-page-background-glare"><div id="jas-page-background-glare-image"></div></div>'+csCRLF+
'  <div id="jas-main">'+csCRLF+
'    <div class="jas-sheet">'+csCRLF+
'      <div class="jas-sheet-tl"></div>'+csCRLF+
'      <div class="jas-sheet-tr"></div>'+csCRLF+
'      <div class="jas-sheet-bl"></div>'+csCRLF+
'      <div class="jas-sheet-br"></div>'+csCRLF+
'      <div class="jas-sheet-tc"></div>'+csCRLF+
'      <div class="jas-sheet-bc"></div>'+csCRLF+
'      <div class="jas-sheet-cl"></div>'+csCRLF+
'      <div class="jas-sheet-cr"></div>'+csCRLF+
'      <div class="jas-sheet-cc"></div>'+csCRLF+
'        <div class="jas-sheet-body">'+csCRLF+
'          <div class="jas-content-layout">          <div id="jaslogodiv">'+'<center><h3>Please wait while JAS prepares for takeoff.</h3></center>'+'<center><img width="50%" class="image" src="/jws/img/logo/jegas/jasjet_graycirclespotlight.png" /></center>'+csCRLF+
'            <center><p>'+SAstr(i8Err)+' '+saErrorStr+'</p></center>'+csCRLF+
'          </div>'+csCRLF+
'          '+csCRLF+
'        </div>'+csCRLF+
'      </div>'+csCRLF+
'    </div>'+csCRLF+
'    <table align="center" width="100%" class="jas-page-footer">'+csCRLF+
'    <tr  class="jas-page-footer">'+csCRLF+
'      <td align="left" width="33%" class="jas-page-footer">Server: <b>Jegas, LLC</b>  &nbsp;&nbsp; User: <b>Anonymous</b></td>'+csCRLF+
'      <td align="center" width="33%" class="jas-page-footer">'+csCRLF+
'        <p  class="jas-page-footer" style="margin-bottom: 2px;" >          Powered by <a target="_blank" href="http://www.jegas.com">          <img class="image" style="position: relative; top: 14px;"'+csCRLF+ 'src="/jws/img/logo/jegas/Logo.png" title="Jegas, LLC Homepage Link" /></a> Software</p>'+csCRLF+
'          '+csCRLF+
'        <p  class="jas-page-footer">Copyright&copy;2011 Jegas, LLC - All Rights Reserved.</p>'+csCRLF+
'      </td>'+csCRLF+
'      <td align="right" width="33%"  class="jas-page-footer"></td>'+csCRLF+
'    </tr>'+csCRLF+
'    </table>'+csCRLF+
'    <!-- www.jegas.com - Jegas, LLC-Virtually Everything IT(TM)-Copyright(C)2011 -->'+csCRLF+
'    </div>'+csCRLF+
'  </div>'+csCRLF+
'</body>'+csCRLF+
'</html>'+csCRLF;
result:=sa;
end;
//=============================================================================



//=============================================================================
procedure LoadJASCGIConfigFile(p_saFilename: ansistring);
//=============================================================================
var   ftext: text;
Begin
  assign(ftext, p_safileNAme);
  reset(ftext);
  While not Eof(ftext) Do
  Begin
    readln(ftext, sa);
    sa:=saTrim(sa);
    If (Length(sa) <> 0) and (saLeftStr(sa, 1) <> ';') and (saLeftStr(sa,2)<>'//') Then
    Begin
      saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
      If saBeforeEqual='HOST' Then saJASHOST:=lowercase(saGetStringAfterEqualSign(sa));
    End;
  End;
  close(ftext);
End;
//=============================================================================






//=============================================================================
Procedure LoadCGIEnvironment;
//=============================================================================
Var t: Integer;
    eq: Integer;
    sa: AnsiString;
    cc: Integer;//counter for post data char count of read
    c: Char;// individual char - for post data read
    saName: ansistring;
    //iNameLength: integer;
    saValue: ansistring;
    //iValueLength: integer;
    iEnvCount: integer;
    //iRequestMethodIndex: integer;
    //iPostContentTypeIndex: integer;
    iPostContentLength: integer;
    //bPost: boolean;    
    
Begin
  //------------------------------------------- PART #1 - The Environment Variables
  //iRequestMethodIndex:=-1;
  //iPostContentTypeIndex:=-1;
  //bPost:=false;
  iPostContentLength:=0;
  iEnvCount:=envcount;
  For t:=0 To iEnvCount-1 Do
  Begin
    sa:=envstr(t);
    //HTTP.Headers.Add('a: '+sa);  // DEBUG thing
    eq:=pos('=',sa);
    saName:=copy(sa,1,eq-1);
    //saValue:=copy(sa,eq+1,length(sa)-eq);
    {$IFDEF WIN32}
    saValue:=getenv(saName);
    {$ELSE}
    saValue:=pchar(fpgetenv(saName));
    {$ENDIF}
    
    
    //If (saName=csCGI_REQUEST_METHOD) Then
    //Begin
    //  //iRequestMethodIndex:=t;
    //  bPost:=(saValue='POST'); 
    //End;       
    //If (saName=csCGI_CONTENT_TYPE) Then
    //Begin
    //  iPostContentTypeIndex:=t;
    //End;       
    If (saName=csCGI_CONTENT_LENGTH) Then
    Begin
      iPostContentLength:=ival(saValue);
    End;       
    // These values are used to locate and send the requested *.jas file
    If (saName=csCGI_DOCUMENT_ROOT) Then
    Begin
      saDocRoot:=saValue;
    End;
    If (saName=csCGI_PATH_INFO) Then
    Begin
      saPathInfo:=saValue;
    End;
    //saOut+=  (sa+csCRLF);
    saOut+=saName+'='+saValue+csCRLF;
  End;
  //saOut+='test filler'+csCRLF;
  saOut+=csCRLF;

  //------------------------------------------- PART #2 - Post Data
  If iPostContentLength>0 Then
  Begin
    cc:=0;
    While cc<iPostContentLength Do Begin
      cc+=1; //rite(cc,' ');
      read(c);// Writeln(Ord(c),' ',c);
      saOut+=c;
    End;
  End;
End;
//=============================================================================


//=============================================================================
// MAIN
//=============================================================================
Var 
  saFilename: AnsiString;
  bSuccess: boolean;
  i8Err: Int64;
  saErrorStr: AnsiString;
  {$IFDEF MIND_CHANGED_ABOUT_SENDING_SCRIPT}
  saDataIn: AnsiString;
  {$ENDIF}
  saDataOut: ansistring;
  //u2IOREsult:word;
//  i: integer;//debug thing
Begin
  saOut:='';// our parsed CGI env vars
  saDataOut:=''; // final result
  HTTP:=THTTPSend.create;
  saFilename:=csJASCGI_Config_File;
  bSuccess:=bFileExists(csJASCGI_Config_File);
  if not bSuccess then
  begin
    i8Err:=-200907261020;
    saErrorStr:='Missing JAS-CGI configuration file.';
  end;
     
  if bSuccess then
  begin  
    
    // LOAD Incoming Environment - And Prepare to Push it out again
    LoadCGIEnvironment;// must happen before other io or acts quirky
    
    // Get Config loaded after the STDIN stuff is finished
    LoadJASCGIConfigFile(saFilename);
    
    // Send out our incoming header/environment and Posted data
    HTTP.Document.Write(PCHAR(saOut)^,length(saOut));
    //write(saOut);
    //h a l t(0);
  end;
      
  if bSuccess then
  begin
    HTTP.Headers.Add('Jegas: JAS-CGI 1.0.0');
    //HTTP.Headers.Add('Script: '+saScriptFullyQualifiedFilename+' Result:'+saStr(u2IOResult));//debug thing
    //HTTP.Headers.Add('DocRoot: '+saDocRoot);//debug thing
    //For i:=0 To paramcount Do HTTP.Headers.Add('Param '+saStr(i)+':'+paramstr(i));//debug thing
    try
      bSuccess:=HTTP.HTTPMethod('POST', saJASHOST);
      if bSuccess then
      begin
        write(Http.headers.text);
        //write(csINET_HDR_CONTENT_TYPE+csMIME_TextHtml +csCRLF);
        //write('Content-length: ' + saStr(Http.Document.Size) + csCRLF+csCRLF);
        setlength(saDataOut,Http.Document.Size);
        Http.Document.ReadBuffer(PCHAR(saDataOut)^, Http.Document.Size);
      end
      else
      begin
        i8Err:=-200907260440;
        saErrorStr:='Communication error with host:'+ saJASHOST+' Result code: '+saStr(Http.Resultcode);
        if(Http.Resultcode=500)then
        begin
          saErrorStr+=csCRLF+csCRLF;
          saErrorStr+='Error code 500 can mean the JAS server is offline. Perhaps it is in the middle of being restarted or is down for service. '+csCRLF+csCRLF;
          saErrorStr+='Try refreshing this page. If this problem persists contact your system administrator.';
        end;

        if(Http.Resultcode=0)then
        begin
          saErrorStr+=csCRLF+csCRLF;
          saErrorStr+='NOTE: The result code came back with a zero, this '+
            'usually means that the request DID get to the server but the '+
            'server is still busy processing it. Usually you do not need to '+
            're-submit your request if you see this message. If you are '+
            'waiting for a response, perhaps you need to run said application '+
            'with the job queue system or directly without the jas proxy.'+
            csCRLF+csCRLF;
        end;
      end;
    finally
    end;//try    
  End;
 
  If not bSuccess then 
  Begin
    saDataOut:=RenderErrorPage(i8Err, saErrorStr);
    //'HTTP/1.1 ' + '200 OK' + csCRLF + 
    //'MIME-version: 1.0'+csCRLF +
    //'Allow: GET, POST'+csCRLF +
    //csINET_HDR_CONTENT_TYPE+csMIME_TextPlain +csCRLF+
    //'Content-length: ' + saStr(length(saErrorStr)+4) + csCRLF+csCRLF +
    //saErrorStr+#13#10#13#10;
  End;
  write(saDataOut);
  {
  writeln('<h1>nph-index.cgi</h1>');
  writeln('Request sent:<br />');
  writeln(saOut);
  }
  HTTP.Free;
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

