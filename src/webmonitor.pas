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
program webmonitor;
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
//=============================================================================


//=============================================================================
Uses
//=============================================================================
  classes
  ,dos
  ,httpsend
  ,sysutils
  ,smtpsend_jas
  ,ug_common
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
  saFilename: ansistring;
//=============================================================================




function saEmailNotice: ansistring;
var
  f: text;
  SL: TSTRINGLIST;
  s: string;
  sName,sValue,sFrom,sTo,sEmailHost,sUser,sPass: string[64];
begin
  SL:=TSTRINGLIST.create;
  result:='';
  writeln('Process webmonitor config file: ' + saFilename);
  try
    assign(f,saFilename);
    reset(f);sFrom:='';sTo:='';sEmailHost:='';sUser:='';sPass:='';
    while not eof(f) do begin
      readln(f,s);
      sName:=UPCase(LeftStr(s,pos('=',s)-1));
      sValue:=RightStr(s,length(s)-pos('=',s));
      if sName='EMAILHOST' then sEmailHost:=sValue else
      if sName='EMAILUSER' then sUser:=sValue else
      if sName='EMAILPASS' then sPass:=saScramble(sValue) else
      if sName='EMAILTO'   then sTo:=sValue else
      if sName='EMAILFROM'   then sFrom:=sValue;
    end;
    close(f);

    SL.Add('Server '+saHost+' appears offline.');

    writeln('----Sending Email----');
    writeln('Host:'+sEmailHost);
    writeln('User:'+sUser);
    writeln('Pass:'+sPass);
    writeln('To  :'+sTo);
    writeln('From:'+sFrom);
    writeln('----Sending Email----');


    if not SendToEx(sFrom, sTo, saHost+' Server is Down', saHost,  SL, sUser, sPass) then
    begin
      result:=csCRLF+'Your web server is down and I am unable to email you!';
    end
    else
    begin
      writeln('===EMAIL SENT===');
    end;
  except on e:Exception do writeln('Trouble reporting '+saHost+' server being down.');
  end;//try

  SL.Destroy;SL:=nil;
end;


//=============================================================================
// MAIN
//=============================================================================
Var 
  bSuccess: boolean;
  saErrorStr: AnsiString;
  saDataOut: ansistring;
  f: text;
Begin
  case paramcount of
  2: begin
    saFilename:=paramstr(1);
    saHost:=paramstr(2);
    saDataOut:=''; // final result
    saErrorStr:='Send Failed';
    HTTP:=THTTPSend.create;
    bSuccess:=false;
    try
      bSuccess:=HTTP.HTTPMethod('GET',saHost);
      if bSuccess then saDataOut:='Success' else
      begin
        saDataOut:='Communication error with host. '+csCRLF+
                    'Host: '+saHOST+csCRLF+
                    'Result code: '+inttostr(Http.Resultcode);
        saDataOut+=saEmailNotice;
      end;
    finally
      HTTP.Free;
    end;//try
  end;
  5: begin // make password file
    writeln('------MAKING PASSWORD/CONFIG FILE-------');
    try
      assign(f,'webmonitor.cfg');
      rewrite(f);
      writeln(f,'emailhost='+ParamStr(1));
      writeln(f,'emailuser='+ParamStr(2));
      writeln(f,'emailpass='+saScramble(ParamStr(3)));
      writeln(f,'emailto='  +ParamStr(4));
      writeln(f,'emailfrom='+ParamStr(5));
      close(f);
      //riteln('Password unscrambled: ' + saScramble(saScramble(ParamStr(2))));
    except on e:EXception do begin saDataOut:='Unable to create password/config file.';end;
    end;//try
  end;
  else begin
    saDataOut+='To create a Webmonitor email config file use: '+csCRLF+
      '  webmonitor [host] [username] [password] [to] [from]'+csCRLF+csCRLF+
      'Example:'+csCRLF+
      '  webmonitor email.com john@email.com MyPassword to@email.com from@email.com'+csCRLF+csCRLF+
      'The default config filename is webmonitor.cfg but you can rename it.'+csCRLF+csCRLF+
      'To actually use the Web Monitor, specifify the WebMonitor Config File and '+csCRLF+
      'the target Web Server we are checking. Site has to be down 100% to get a hit.'+csCRLF+
      'Usage: webmonitor [webmonitor-config-file] [host]';
  end;
  end;//case
  writeln(saDataOut);

  If bSuccess then halt(0) else halt(1);
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

