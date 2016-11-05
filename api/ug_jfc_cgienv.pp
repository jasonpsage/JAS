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
// Common Gateway Interface Class (http use also)
// This class derived from CGI programming needs,
// expanded to include many http protocol and
// related tasks - manipulating headers, storing
// cookies, useful for both client stuff coming in and
// server stuff going out.
Unit ug_jfc_cgienv;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_cgienv.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
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
   ug_common
  ,ug_misc
  ,ug_jegas
  ,ug_jfc_xdl
  ,ug_jfc_tokenizer
  ,sysutils
;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//=============================================================================



//=============================================================================
{}
Type JFC_CGIENV = Class
  ENVVAR: JFC_XDL;
  DATAIN: JFC_XDL;
  CKYIN: JFC_XDL;
  CKYOUT: JFC_XDL;
  HEADER: JFC_XDL;
  FILESIN: JFC_XDL;

  bPost: Boolean;//< Whether request coming in was get or post
  saPostContentType: AnsiString;//< content type (mime) coming in
  uPostContentLength: UInt;//< length of post data when a post
  saPostData: AnsiString;//< raw posted data.
  iTimeZoneOffset: integer;{< offset from GMT timezone. Example: Eastern
                            standard time is usually -5}
  uHTTPResponse: word;{< Used for building http headers going out
                          and also by JAS to track status of a given
                          thread. e.g. starts at ZERO when a thread 
                          starts, and stays ZERO until the request has 
                          been handled one way or another e.g. error
                          or otherwise .. like a successful page.}

  saServerSoftware: ansistring; //< used for many out going headers
  
  Constructor create(
    p_saServerSoftware: ansistring; 
    p_iTimeZoneOffset: integer
  );
  Destructor destroy; override;
  Procedure Reset;


  //---------------------------------------------------------------------------
  {}
  // copies data from rtCGI structure to this class. Purpose is the rtCGI 
  // structure is a LEAN LEAN version of this class used just to "grab"
  // true CGI info passed from webserver CGI requests.  
  procedure PopulateMeWith(p_rCGI: rtCGI);
  //---------------------------------------------------------------------------
  {}
  // Function appends "cookie" data into the CKYOUY XDL class for later use when 
  // building outgoing http headers.
  Procedure AddCookie(
    p_saName, 
    p_saValue, 
    p_saPath: AnsiString;
    p_dt: TDATETIME; 
    p_bSecure: Boolean
  );
  //---------------------------------------------------------------------------
  {}
  // This function takes the cookies in the CKYOUT xdl and appends them to the  
  // HEADERS XDL
  Procedure Header_Cookies(p_sServerIdent: string);
  //---------------------------------------------------------------------------
  {}
  // Shortcut method to build a complete header for HTML output. Make sure 
  // CGIENV.iHTTPResponse is set properly (to a server response code) before
  // calling. 
  Procedure Header_Html(p_sServerIdent: string);
  //---------------------------------------------------------------------------
  {}
  // Shortcut method to build a complete header for HTML output without the 
  // cookies-n-milk. 
  Procedure Header_HtmlNoCookies;
  //---------------------------------------------------------------------------
  {}
  // Shortcut method to build a complete header for XML output. Make sure 
  // CGIENV.iHTTPResponse is set properly (to a server response code) before
  // calling. 
  Procedure Header_Xml(p_sServerIdent: string);
  //---------------------------------------------------------------------------
  {}
  // This returns the Content for the NPH-CGITEST that has been around a long
  // time in this library. The biggest change is now the HTTP header is 
  // generaated and placed into the CGIENV.Header XDL - so some work needs to 
  // be done before you send this out.
  Function saNPHCGITEST: AnsiString;
  //---------------------------------------------------------------------------
  {}
  Function saRequestURIPath: AnsiString;
  //---------------------------------------------------------------------------
  {}
  Function saRequestURIWithoutParam:AnsiString;
  //---------------------------------------------------------------------------
  {}
  Procedure TokenizeURI(p_PlacesDataIntoThisXDL:JFC_XDL; p_sa: AnsiString; p_saDesc: AnsiString);
  //---------------------------------------------------------------------------
  {}
  // Returns the header text for various HTTP Responses. 
  // If unsupported code passed, "xxx Unexpected Error Code" is returned where
  // xxx = to the http response code passed to it.
  // This maybe should be referred to as the server response codes.. it 
  // uses CGIENV.iHTTPResponse value to get the right return error or success 
  // code. Such as: "200 OK"  or "403 Forbidden" or "404 File not Found"  
  function saHTTPResponse: ansistring;
  //---------------------------------------------------------------------------
  {}
  // Shortcut method to create a redirect header that will Send the user's 
  // Browser to the web page you specify.    
  //  Note: cnHTTP_RESPONSE_302 is the PROPER Code according to RFC but Apache 
  // doesn't recognize correctly, so jas-cgi doesn't work right. So... use 
  // cnHTTP_RESPONSE_301 for redirects (or test first if you use another to 
  // make sure the browser is honoring your request(s))
  Procedure Header_Redirect(p_saURL: ansistring; p_sServerIdent: string);
  //---------------------------------------------------------------------------
  {}
  // Shortcut method creates all that's needed for sending out a plain text
  // file.
  Procedure Header_PlainText(p_sServerIdent: string);
  //---------------------------------------------------------------------------
  {}
  // previously: Function saCGIFormatedDate(p_dtLocalTime: TDATETIME): AnsiString;
  Procedure Header_Date;
  //---------------------------------------------------------------------------
  {}
  // Converts URL Encoded to Human readable. Note: Because the postdata might
  // come from outside structure (rtCGI), we don't use the internal saPostData
  // variable directly because it the postdata is very large. This is why we 
  // don't copy the postdata in the PopulateMeWith method into this class; it
  // could be a 100 meg file or data post in theory! So - we implicitly pass 
  // WHICH postdata ansistring we want to interrogate.
  Procedure TranslateParameters(
    var p_saPostDataToInterrogate: ansistring
    ;p_saContentType: ansistring
  ); 
  //---------------------------------------------------------------------------
  {}
  // convert post data for multi-part form encoded data. This is typically for 
  // file uploading, but variables akin form variables can be embedded also.
  // This function only needs the p_saContentType sent so it can figure out the
  // separator string that sepearates variables and files from each other
  procedure ParseMultiPartData(var p_saPostDataToParse: ansistring; p_saContentType: ansistring);
  //---------------------------------------------------------------------------
  {}
  function saHttpServerError500(
    p_u8CodeID: int64;
    p_saMsg: ansistring;
    p_saMoreInfo: ansistring;
    var p_OUT_sMimeType: string
  ): ansistring;
  //---------------------------------------------------------------------------
  function saGetHeaders(
    p_sMimeType: string;
    p_u4ContentLength: cardinal;
    p_sCacheControl: string;
    p_sServerSoftware: string;
    p_sServerIdent: string
  ): ansistring;
  //---------------------------------------------------------------------------
End;




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
Constructor JFC_CGIENV.create(
  p_saServerSoftware: ansistring; 
  p_iTimeZoneOffset: integer
);
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.create(p_saServerSoftware: ansistring;p_iTimeZoneOffset: integer);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.ENVVAR:=JFC_XDL.Create;
  self.DATAIN:=JFC_XDL.Create;
  self.CKYIN:=JFC_XDL.Create;
  self.CKYOUT:=JFC_XDL.Create;
  self.HEADER:=JFC_XDL.Create;
  self.FILESIN:=JFC_XDL.Create;
  self.saServerSoftware:=p_saServerSoftware;
  self.iTimeZoneOffset:=p_iTimeZoneOffset;
  reset();
End;
//=============================================================================

//=============================================================================
Destructor JFC_CGIENV.destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.ENVVAR.destroy;
  self.DATAIN.destroy;
  self.CKYIN.destroy;
  self.CKYOUT.destroy;
  self.HEADER.destroy;
  self.FILESIN.destroy;
  Inherited;
  saPostContentType:='';
  bPost:=False;
  uPostContentLength:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
procedure JFC_CGIENV.Reset;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Reset;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  ENVVAR.DeleteAll;
  DATAIN.DeleteAll;
  CKYIN.DeleteAll;
  CKYOUT.DeleteAll;
  HEADER.DeleteAll;
  FILESIN.DeleteAll;
  bPost:=false;//not sure if needed here
  saPostContentType:='';
  uPostContentLength:=0; // not sure if needed here
  saPostData:='';
  uHTTPResponse:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================




//=============================================================================
Procedure JFC_CGIENV.TranslateParameters(var p_saPostDataToInterrogate: ansistring; p_saContentType: ansistring);
//=============================================================================
var bMultiPartformData: boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.TranslateParameters(var p_saPostDataToInterrogate: ansistring; p_saContentType: ansistring);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}

  bMultiPartformData:=( saLeftStr(p_saContentType,20)='multipart/form-data;');
  //ASPrintln('p_saContentType: '+p_saContentType+' MultiPart:'+saYesNo(bMultiPartformData)+' Data:'+p_saPostDataToInterrogate);

  // GRAB QUERY_STRING
  If ENVVAR.FoundItem_saName(csCGI_QUERY_STRING,True) Then
  Begin
    self.TokenizeURI(DATAIN, ENVVAR.Item_saValue, csCGI_QUERY_STRING);
    //ASPrintln('Tokenizing: '+ENVVAR.Item_saValue);
  End;

    // Grab Posted Data 
  if bPost then  
  begin
    if not bMultiPartFormData then
    begin
      self.TokenizeURI(DATAIN, self.saPostData, csCGI_POST);
    end
    else
    begin
      // Parse multipart/form-data here
      self.ParseMultiPartData(p_saPostDataToInterrogate, p_saContentType);
      //ASPrintln('returned from parsemultipartdata');
    end;
    //ASPrintln('Tokenizing postdata: '+p_saPostData);
    //ASPrintln('DATAIN.ListCount:'+saStr(DATAIN.ListCount));
    
    // Disect URI/URL and add it to the mix as well.
    If self.ENVVAR.FoundItem_saName(csCGI_REQUEST_URI,True) Then
    Begin
      self.TokenizeURI(DATAIN, self.ENVVAR.Item_saValue, csCGI_REQUEST_URI);
      //ASPrintln('Tokenizing Request uri: '+ENVVAR.Item_saValue);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
 

//=============================================================================
Procedure JFC_CGIENV.PopulateMeWith(p_rCGI: rtCGI);
//=============================================================================
Var u,uEQ: UInt;
Var TK: JFC_Tokenizer;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.PopulateMeWith(p_rCGI: rtCGI);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.reset;
  // ENVIRONMENT VARI's
  If p_rCGI.uEnvVarCount>0 Then
  Begin
    For u := 0 To p_rCGI.uEnvVarCount-1 Do
    Begin
      ENVVAR.AppendItem_saName_N_saValue(
        UpCase(p_rCGI.arNVPair[u].saName),
        p_rCGI.arNVPair[u].saValue
      );
    End;
  End;

  // Other Stats captured in original rCGIIN/rCGI
  If p_rCGI.iPostcontentTypeIndex>-1 Then
  Begin
    saPostContentType:=p_rCGI.arNVPair[p_rCGI.iPostContentTypeIndex].saValue;
  End;
  bPost:=p_rCGI.bPost;
  uPostContentLength:=p_rCGI.uPostContentLength;
  //NOTE: Not doing this (copying post data into the saPostData
  //  variable) yet because it could be big and I'm
  // only writing support for x-www-form-url-encoded currently
  // saPostData:=p_rCGI.saPostData;
  // So for now x-www-form-url-encoded is implied.
  // 2006-07-22 Jason P Sage

  // NOTE: FOR JEGAS APPLICATIONS THIS CODE NEEDS TO
  // HAPPEN WHEN A WEB REQUEST beomes an INVOCATOR
  // OF JEGAS Routines!!!
  self.TranslateParameters(p_rCGI.saPostData,saPostContentType);
  //self.TranslateParameters(p_rCGI.saPostData);
  
  // GRAB the Cookies Coming In  
  If ENVVAR.FoundItem_saName(csCGI_HTTP_Cookie,True) Then
  Begin
    If length(ENVVAR.Item_saValue)>0 Then
    Begin
      TK:=JFC_TOKENIZER.Create;//(16384,1);
      TK.SetDefaults;
      TK.sSeparators:=';';
      TK.sWhiteSpace:=';';
      TK.Tokenize(ENVVAR.Item_saValue);
      //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_cookie.txt');
      If TK.ListCount>0 Then 
      Begin
        TK.MoveFirst;
        repeat
          u:=length(TK.Item_saToken);
          uEQ:=pos('=',TK.Item_saToken);
          If uEQ>1 Then
          Begin
            CKYIN.AppendItem_saName_N_saValue(
              trim(Upcase(leftstr(TK.Item_saToken, uEQ-1))),
              trim(rightstr(TK.Item_saToken, u-uEQ)));
          End;
        Until not tk.movenext;
      End;
      TK.Destroy;
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
Procedure JFC_CGIENV.AddCookie(
  p_saName, 
  p_saValue, 
  p_saPath: AnsiString;
  p_dt: TDATETIME; 
  p_bSecure: Boolean
);
//=============================================================================
Var 
  iLen: Integer;
  sa: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin


   exit;



{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.AddCookie(p_saName,p_saValue,p_saPath: AnsiString;p_dt: TDATETIME;p_bSecure: Boolean);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  // gotta put slash on left and NOT on right.
  iLen:=Length(p_saPath);
  If iLen>1 Then 
  Begin
    If p_saPath[1]<>'/' Then 
    Begin
      iLen+=1;
      p_saPath:='/'+p_saPath;
    End;
    If p_saPath[iLen]='/' Then 
    Begin
      iLen-=1;
      p_saPath:=LeftStr(p_saPath,iLen);
    End;
  End;

  sa:=trim(p_saValue+';path='+p_saPath+';expires='+
    FormatDateTime(csWEBDATETIMEFORMAT, dtAddHours(p_dt,-self.iTIMEZONEOFFSET)));
    
  if not CKYOUT.FoundItem_saName(p_saName,false) then
  begin
    CKYOUT.AppendItem_saName_N_saValue(trim(p_saName),sa);
  end
  else
  begin
    CKYOUT.Item_saName:=trim(p_saName);
    CKYOUT.Item_saValue:=trim(sa);
  end;

  If p_bSecure Then 
  Begin
    CKYOUT.Item_saValue:=CKYOUT.Item_saValue+'; secure=yes';
  End;
  //p_saValue+';path='+p_saPath+';expires='+
  //  FormatDateTime(csWEBDATETIMEFORMAT,dtAddHours(p_dt,0))
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// Sends Header Required to send a html document - also handles sending
// cookies for you IF they are CKYOUT (JFC_XDL) which you load by calling
// AddCookie :)
          
          // NOTE: Here is the Cache Header Value that vs2005 pro uses for the dev
          // server you use to test .net web apps with uses for ZERO TIME Cache:
          // Cache-Control: private, max-age=0
          //
          // These two are from joomla running php
          // Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
          // Pragma: no-cache

Procedure JFC_CGIENV.Header_Html(p_sServerIdent: string);
//=============================================================================
// Server: mattermuch  <-- Not done currently
// Cache-Control: private, max-age=0
// Transfer-Encoding: chunked
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_Html;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  // HTTP/1.1 200 OK
  self.HEADER.MoveFirst;
  self.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,saHttpResponse);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,self.saServerSoftware);
  // Set-Cookie: jasoncookie1=somedata;path=/cgi-bin;expires=Thu, 01 Dec 2003 16:00:00 GMT
  // Set-Cookie: jasoncookie2=somemoredata;path=/cgi-bin;expires=Thu, 01 Dec 2003 16:00:00 GMT
  self.Header_Cookies(p_sServerIdent);
  
  // Content-type: text/html
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,csMIME_TextHtml);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure JFC_CGIENV.Header_Cookies(p_sServerIdent: string);
//=============================================================================
var sName: string;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_Cookies;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  //sa+=csCGI_SERVER+csCRLF;
  //sa+='Set-Cookie: cgibin=cookcgibin;path=;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: jegas=cookjegas;path=/jegas;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: jegascom=cookjegascom;path=/jegas/com;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: BIG=BIG;path=/jegas/com;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  If self.ckyout.movefirst Then 
  Begin
    self.HEADER.MoveLast;
    repeat
      sName:=self.ckyout.item_saName;
      if length(p_sServerIdent)>0 then sName:=p_sServerIdent+'_'+sName;
      self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SETCOOKIE,sName+'='+trim(self.ckyOut.Item_saValue));
    Until not self.ckyout.movenext;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================
  


//=============================================================================
// Sends Header Required to send a simple xml document.
// old note:   FormatDateTime(csWEBDATETIMEFORMAT, dtAddHours(p_dt,grJASConfig.iTIMEZONEOFFSET))
Procedure JFC_CGIENV.Header_Xml(p_sServerIdent: string);
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_Xml;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.HEADER.MoveFirst;
  self.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,saHttpResponse);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,self.saServerSoftware);
  self.Header_Cookies(p_sServerIdent);  
  self.HEADER.AppendItem_saName_N_saValue('Accept-Ranges: ','bytes');   
  self.HEADER.AppendItem_saName_N_saValue('Content-Length: ','[@CONTENTLENGTH@]');   
  self.HEADER.AppendItem_saName_N_saValue('Connection: ','close');   
  // Content-type: text/xml
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,csMIME_TextXml);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
// Sends User's Browser to web page you specify
Procedure JFC_CGIENV.Header_Redirect(p_saURL: ansistring; p_sServerIdent: string);
//=============================================================================
//HTTP/1.1 302 Redirected
//Server: Microsoft-IIS/5.0
//Date: Mon, 24 Mar 2003 21:44:30 GMT
//Location: http://lc1.law5.hotmail.passport.com/cgi-bin/login
//<blank>
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_Redirect(p_saURL: ansistring);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  // Do Not Overwrite Redirection codes set in the application
  if (self.uHTTPResponse<300) or (self.uHttpResponse>=400) then self.uHTTPResponse:=302;
  //self.HEADER.MoveFirst;
  self.HEADER.AppendItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,saHttpResponse);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,self.saServerSoftware);
  self.HEADER_Date;
  self.HEADER.AppendItem_saName_N_saValue('Location: ',p_saURL);
  self.Header_Cookies(p_sServerIdent);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// Sends HEader required for sending plain text
Procedure JFC_CGIENV.Header_PlainText(p_sServerIdent: String);
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_PlainText;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.HEADER.MoveFirst;
  self.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,saHttpResponse);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,self.saServerSoftware);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,csMIME_TextPlain);
  self.Header_Cookies(p_sServerIdent);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// Sends Header Required to send a html document - like JFC_CGIENV.saCGIHdrHtml
// But Without the cookies-n-milk
Procedure JFC_CGIENV.Header_HtmlNoCookies;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_HtmlNoCookies;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.HEADER.MoveFirst;
  self.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,saHttpResponse);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,self.saServerSoftware);
  self.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,csMIME_TextHtml);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
//Function saCGIFormatedDate(p_dtLocalTime: TDATETIME): AnsiString;
Procedure JFC_CGIENV.Header_Date;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.Header_Date;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  self.HEADER.AppendItem_saName_N_saValue(
    'Date: ',
    FormatDateTime(csWEBDATETIMEFORMAT,dtAddHours(now, self.iTimeZoneOffset))
  ); 
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
Function JFC_CGIENV.saNPHCGITEST: AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saNPHCGITEST: AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  AddCookie(
      'NPHCGITEST_COOKIE',
      'I am a cookie that expires in 5 minutes.',
      saRequestURIWithoutParam,
      dtAddminutes(now,5),
      False);
  self.Header_Html('');
  Result:='<!DOCTYPE HTML public "-//W3C//DTD HTML 4.0//EN"'+
          '"http://www.w3.org/TR/REC-html40/strict.dtd"><HTML>'+
          '<HEAD><TITLE>NPH-CGITEST By: Jason P Sage</TITLE></HEAD>'+
          //Background black, links blue (unvisited), navy (visited), red (active)
          '<BODY bgcolor="#000000" text="#FFFFFF" link="#0000FF"'+
          ' vlink="#000080" alink="#FF0000">'+
          '<H1 align="center">NPH-CGITEST v5.0</H1>'+
          '<h3 align="center">CGI Serverside HTML Form Tester</h3>'+
          '<h4 align="center">By: <a href="mailto:jasonpsage@jegas.com">'+
          'Jason Peter Sage</a></h4>'+
          '<p align="center">This application runs on Windows 32/64bit and POSIX '+
          'platforms and was originally created with FreePascal 2.0.2 back in '+
          '2003-02-05.</p>'+
          '<center><b>'+FormatDateTime(csDATETIMEFORMAT,NOW)+'</b></center>'+
          '<hr size="8">'+
          '<CENTER>DATAIN</CENTER>'+
          '<center>'+DataIn.saHTMLTable+'</center>'+
          '<p>This is your DATA IN. All Data that can be interpreted from '+
          'the GET REQUEST, the URL Itself, and any FORM URI encoded POSTED '+
          'data shows in this Table.</p>'+
          '<hr>'+
          
          '<CENTER>CKYIN</CENTER>'+
          '<center>'+CkyIn.saHTMLTable+'</center>'+
          '<p>These are any cookies that were transmitted and found '+
          'in the CGI environment.</p>'+
          '<hr>'+
          
          '<CENTER>ENVVAR</CENTER>'+
          '<center>'+ENVVAR.saHTMLTable+'</center>'+
          '<hr size="8">'+
          '</body></html>'; 

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_CGIENV.saRequestURIWithoutParam: AnsiString;
//=============================================================================
Var saRURI: AnsiString;
    iPosOfQuestionMark: Integer;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saRequestURIWithoutParam: AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  Result:='';
  saRURI:=self.ENVVAR.Get_saValue('REQUEST_URI');
  If length(saRURI)>0 Then
  Begin
    iPosOfQuestionMark:=pos('?',saRURI);
    If iPosOfQuestionMark > 0 Then
    Begin
      Result:=saLeftStr(saRURI,iPosOfQuestionMark-1);
    End
    Else
    Begin
      Result:=saRURI;
    End;
  End
  Else
  Begin
    // Nothing to Return?!?
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================





//=============================================================================
// Used for Determining Cookie path for example
Function JFC_CGIENV.saRequestURIPath: AnsiString;
//=============================================================================
Var saRURI: AnsiString;
    iPosOfLastSlash: Integer;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saRequestURIPath: AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  Result:='/';
  saRURI:=saReverse(self.saRequestURIWithoutParam);
  iPosOfLastSlash:=pos('/', saRURI);
  If iPosOfLastSlash>0 Then
  Begin
    DeleteString(saRURI, 1, iPosOfLastSlash);
    saRURI:=saReverse(saRURI);
    Result:=saRURI;
  End
  Else
  Begin
    // Nothing to Return?!?
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure JFC_CGIENV.TokenizeURI(p_PlacesDataIntoThisXDL:JFC_XDL; p_sa: AnsiString; p_saDesc: AnsiString);
//=============================================================================
Var
  iQM: Integer;
  TK: JFC_TOKENIZER;

{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.TokenizeURI(p_PlacesDataIntoThisXDL:JFC_XDL; p_sa: AnsiString; p_saDesc: AnsiString);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  // Extra Feature - Fake Get .. If p_sa is sent http://somedir/yourcgi?some=data
  // It will handle removing the http://somedir/yourcgi? part for you.
  // This unit was not designed to need this, or even think about it but
  // the need arised where I wanted to parse REQUEST URL Env Variable.
  //
  // This way I could get a post and Still Do some fancy tricks :)

  iQM:=pos('?',p_sa);
  If iQM>0 Then p_sa:=rightStr(p_sa, length(p_Sa)-iQM);
  TK:=JFC_TOKENIZER.create;//(16384,1);
  TK.SetDefaults;
  //TK.bKeepDebugInfo:=true;
  TK.sSeparators:='&';
  TK.sWhitespace:='&';
  TK.Tokenize(p_sa);
  {$IFDEF DEBUGCGI}
  TK.DumpToTextFile('Debug_Tokenizer.txt.'+saStr(random(100)));
  {$ENDIF}
  If (TK.Listcount>0) Then
  Begin
    TK.MoveFirst;
    repeat
      p_PlacesDataIntoThisXDL.AppendItem;
      p_PlacesDataIntoThisXDL.Item_saName:= Trim(UpCase(saGetStringBeforeEqualSign( Tk.Item_saTOken )));
      p_PlacesDataIntoThisXDL.Item_saValue:=Trim(saGetStringAfterEqualSign(Tk.Item_saTOken ));
      p_PlacesDataIntoThisXDL.Item_saValue:=saDecodeURI(p_PlacesDataIntoThisXDL.Item_saValue);
      p_PlacesDataIntoThisXDL.Item_saDesc:=p_saDesc;
    Until not TK.MoveNExt;
  End;
  TK.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
function JFC_CGIENV.saHTTPResponse: ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saHTTPResponse: ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
  case self.uHTTPResponse of
  cnHTTP_RESPONSE_100: result:=csHTTP_RESPONSE_100;
  cnHTTP_RESPONSE_101: result:=csHTTP_RESPONSE_101;
  cnHTTP_RESPONSE_102: result:=csHTTP_RESPONSE_102;
  cnHTTP_RESPONSE_200: result:=csHTTP_RESPONSE_200;
  cnHTTP_RESPONSE_201: result:=csHTTP_RESPONSE_201;
  cnHTTP_RESPONSE_202: result:=csHTTP_RESPONSE_202;
  cnHTTP_RESPONSE_203: result:=csHTTP_RESPONSE_203;
  cnHTTP_RESPONSE_204: result:=csHTTP_RESPONSE_204;
  cnHTTP_RESPONSE_205: result:=csHTTP_RESPONSE_205;
  cnHTTP_RESPONSE_206: result:=csHTTP_RESPONSE_206;
  cnHTTP_RESPONSE_207: result:=csHTTP_RESPONSE_207;
  cnHTTP_RESPONSE_226: result:=csHTTP_RESPONSE_226;
  cnHTTP_RESPONSE_300: result:=csHTTP_RESPONSE_300;
  cnHTTP_RESPONSE_301: result:=csHTTP_RESPONSE_301;
  cnHTTP_RESPONSE_302: result:=csHTTP_RESPONSE_302;
  cnHTTP_RESPONSE_303: result:=csHTTP_RESPONSE_303;
  cnHTTP_RESPONSE_304: result:=csHTTP_RESPONSE_304;
  cnHTTP_RESPONSE_305: result:=csHTTP_RESPONSE_305;
  cnHTTP_RESPONSE_306: result:=csHTTP_RESPONSE_306;
  cnHTTP_RESPONSE_307: result:=csHTTP_RESPONSE_307;
  cnHTTP_RESPONSE_400: result:=csHTTP_RESPONSE_400;
  cnHTTP_RESPONSE_401: result:=csHTTP_RESPONSE_401;
  cnHTTP_RESPONSE_402: result:=csHTTP_RESPONSE_402;
  cnHTTP_RESPONSE_403: result:=csHTTP_RESPONSE_403;
  cnHTTP_RESPONSE_404: result:=csHTTP_RESPONSE_404;
  cnHTTP_RESPONSE_405: result:=csHTTP_RESPONSE_405;
  cnHTTP_RESPONSE_406: result:=csHTTP_RESPONSE_406;
  cnHTTP_RESPONSE_407: result:=csHTTP_RESPONSE_407;
  cnHTTP_RESPONSE_408: result:=csHTTP_RESPONSE_408;
  cnHTTP_RESPONSE_409: result:=csHTTP_RESPONSE_409;
  cnHTTP_RESPONSE_410: result:=csHTTP_RESPONSE_410;
  cnHTTP_RESPONSE_411: result:=csHTTP_RESPONSE_411;
  cnHTTP_RESPONSE_412: result:=csHTTP_RESPONSE_412;
  cnHTTP_RESPONSE_413: result:=csHTTP_RESPONSE_413;
  cnHTTP_RESPONSE_414: result:=csHTTP_RESPONSE_414;
  cnHTTP_RESPONSE_415: result:=csHTTP_RESPONSE_415;
  cnHTTP_RESPONSE_416: result:=csHTTP_RESPONSE_416;
  cnHTTP_RESPONSE_417: result:=csHTTP_RESPONSE_417;
  cnHTTP_RESPONSE_418: result:=csHTTP_RESPONSE_418;
  cnHTTP_RESPONSE_422: result:=csHTTP_RESPONSE_422;
  cnHTTP_RESPONSE_423: result:=csHTTP_RESPONSE_423;
  cnHTTP_RESPONSE_424: result:=csHTTP_RESPONSE_424;
  cnHTTP_RESPONSE_425: result:=csHTTP_RESPONSE_425;
  cnHTTP_RESPONSE_426: result:=csHTTP_RESPONSE_426;
  cnHTTP_RESPONSE_449: result:=csHTTP_RESPONSE_449;
  cnHTTP_RESPONSE_500: result:=csHTTP_RESPONSE_500;
  cnHTTP_RESPONSE_501: result:=csHTTP_RESPONSE_501;
  cnHTTP_RESPONSE_502: result:=csHTTP_RESPONSE_502;
  cnHTTP_RESPONSE_503: result:=csHTTP_RESPONSE_503;
  cnHTTP_RESPONSE_504: result:=csHTTP_RESPONSE_504;
  cnHTTP_RESPONSE_505: result:=csHTTP_RESPONSE_505;
  cnHTTP_RESPONSE_506: result:=csHTTP_RESPONSE_506;
  cnHTTP_RESPONSE_507: result:=csHTTP_RESPONSE_507;
  cnHTTP_RESPONSE_509: result:=csHTTP_RESPONSE_509;
  cnHTTP_RESPONSE_510: result:=csHTTP_RESPONSE_510;
  else result:=inttostr(uHTTPResponse)+' Unexpected Error Code';
  end;//case
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
procedure JFC_CGIENV.ParseMultiPartData(var p_saPostDataToParse: ansistring; p_saContentType: ansistring);
//=============================================================================
var
  //bOk: boolean;
  saBoundary: ansistring;
  i4BLen: longint;
  //bDone: boolean;
  iPos: longint;
  sa: ansistring;
  saData: ansistring;
  isaPos: longint;
  
  TK: JFC_TOKENIZER;

  saName: ansistring;
  saFilename: ansistring;
  saFileContentType: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='ParseMultiPartData(var p_saPostDataToParse: ansistring; p_saContentType: ansistring);';
  DebugIn(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}

  // Sample: Content-Type: multipart/form-data; boundary=---------------------------146043902153
  // Note: Boundary is weird, first two dashes have to go.
  saBoundary:='--'+saGetStringAfterEqualSign(p_saContentType);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, 'p_saContentType:' + p_saContentType, SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, 'saBoundary:' + saBoundary, SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, 'p_saPostDataToParse:' + p_saPostDataToParse, SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);
  //Log(cnLog_Debug, 201004152344, '.', SOURCEFILE);

  i4BLen:=length(saBoundary);
  if i4BLen>2 then
  begin
    iPos:=pos(saBoundary, p_saPostDataToParse);
    if iPos>0 then
    begin
      p_saPostDataToParse:=saRightStr(p_saPostDataToParse,length(p_saPostDataToParse)-(iPos+i4BLen-1));
      //riteln(saRepeatchar('-',79));
      //riteln('Post DataToParse');
      //riteln(saRepeatchar('-',79));
      //riteln(p_saPostDataToParse);
      //riteln(saRepeatchar('-',79));
      repeat
        saName:='';
        saFilename:='';
        saFileContentType:='';
        
        iPos:=pos(saBoundary, p_saPostDataToParse);
        if iPos>0 then
        begin
          sa:=saLeftStr(p_saPostDataToParse, iPos-1);
          p_saPostDataToParse:=saRightStr(p_saPostDataToParse,length(p_saPostDataToParse)-(iPos+i4BLen-1));
          //JLocnLog_y_Debug, 201004152344, 'MultiPart:' + sa, SOURCEFILE);
          
          isaPos:=pos(csCRLF+csCRLF,sa);
          if (isaPos>0) then
          begin
            saData:=saRightStr(sa, length(sa)-(isaPos+3));
            saData:=saLeftStr(saData,length(saData)-2);
            sa:=saLeftStr(sa, isaPos-1);
            //riteln(saRepeatchar('-',79));
            //riteln('Tokenize File Info');
            //riteln(saRepeatchar('-',79));
            //riteln(sa);
            //riteln(saRepeatchar('-',79));

            //Log(cnLog_Debug, 201004152344, 'sa:'+sa, SOURCEFILE);
            //Log(cnLog_Debug, 201004152344, 'saData:'+saData, SOURCEFILE);
            
            TK:=JFC_TOKENIZER.create;
            TK.sWhiteSpace:=csCR+csLF+'; ';
            TK.sSeparators:=';= ';
            TK.sQuotes:='"';
            //TK.bKeepDebugInfo:=true;
            TK.Tokenize(sa);
            //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_multipart.txt');
            
            if TK.MoveFirst then
            begin
              if TK.MoveFirst then
              begin
                if (TK.Item_saToken='Content-Disposition:') and TK.MoveNext then
                begin
                  //Log(cnLog_Debug, 201110162128, 'Content Disposition', SOURCEFILE);
                  if (TK.Item_saToken='form-data') and TK.MoveNext then
                  begin
                    //Log(cnLog_Debug, 201110162129, 'form-data', SOURCEFILE);
                    if (TK.Item_saToken='name') then
                    begin
                      //Log(cnLog_Debug, 201110162130, 'name', SOURCEFILE);
                      if (Tk.MoveNext) and (TK.Item_saToken='=') and (TK.MoveNext) then
                      begin
                        //Log(cnLog_Debug, 201110162130, 'grabbed named value', SOURCEFILE);
                        saName:=TK.Item_saToken; TK.MoveNext;
                      end;
                    end;
                    
                    if (TK.Item_saToken='filename') then
                    begin
                      //Log(cnLog_Debug, 201110162131, 'filename', SOURCEFILE);
                      if (Tk.MoveNext) and (TK.Item_saToken='=') and (TK.MoveNext) then
                      begin
                        saFileName:=TK.Item_saToken; TK.MoveNext;
                      end;
                    end;
                    
                    if (TK.Item_saToken='Content-Type:') then
                    begin
                      //Log(cnLog_Debug, 201110162132, 'Content-Type', SOURCEFILE);
                      if (Tk.MoveNext) then
                      begin
                        saFileContentType:=TK.Item_saToken; TK.MoveNext;
                      end;
                    end;
                    
                    if length(saFileContentType)>0 then
                    begin
                      //Log(cnLog_Debug, 201110162133, 'Appending Data to FILESIN', SOURCEFILE);
                      // treat as a file coming in
                      self.FilesIn.AppendItem;
                      self.FilesIn.Item_saName:=saName;
                      self.FilesIn.Item_saValue:=saData;
                      self.FilesIn.Item_saDesc:=saFileContentType;
                      self.FilesIn.Item_i8User:=Length(saData);
                      
                      self.DataIn.AppendItem;
                      self.DataIn.Item_saName:=saName;
                      self.DataIn.Item_saValue:=saFileName;
                      self.DataIn.Item_saDesc:='FILE';
                    end
                    else
                    begin
                      self.DataIn.AppendItem;
                      self.DataIn.Item_saName:=saName;
                      self.DataIn.Item_saValue:=saData;
                      self.DataIn.Item_saDesc:='POST';
                    end;
                    
                  end;
                end;
              end;
            end;
            TK.Destroy;TK:=nil;
          end;
        end;
      until iPos=0;
    end;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================





//=============================================================================
function JFC_CGIENV.saHttpServerError500(
  p_u8CodeID: int64;
  p_saMsg: ansistring;
  p_saMoreInfo: ansistring;
  var p_OUT_sMimeType: string
): ansistring;
//=============================================================================
var
  u8CodeID: int64;
  saMsg: ansistring;
  saMoreInfo: ansistring;
  sa: ansistring;
  
  saHTTPStatusCode: ansistring;
  saFileData: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saHttpServerError500';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  u8CodeID:=p_u8CodeID;
  saMsg:=p_saMsg;
  saMoreInfo:=p_saMoreInfo;
  sa:='';
  
  uHTTPResponse:=cnHTTP_RESPONSE_500;
  p_OUT_sMimeType:='text/html';
  if(grJASConfig.u2ErrorReportingMode=cnSYS_INFO_MODE_Secure)then
  begin
    saMoreInfo:=grJASConfig.saErrorReportingSecureMessage;
  end;

  saHTTPStatusCode:='500 Server Error';
  saFileData:='<h1>'+saHTTPStatusCode+' '+inttostr(u8CodeID)+'</h1><br />'+csCRLF+csCRLF+
    saMsg+'<br />'+csCRLF+csCRLF+
    saMoreInfo+'<br />'+csCRLF+csCRLF+    
    #13#10 + #13#10;
  sa := 
    'HTTP/1.1 ' + saHTTPStatusCode + #13#10 + 
    'Server: '+grJASConfig.sServerSoftware + #13#10 +
    'MIME-version: 1.0'+#13#10 +
    'Allow: GET, POST'+#13#10 +
    'Content-type: ' + p_OUT_sMimeType + #13#10 +
    'Content-length: ' + inttostr(length(saFileData)) + #13#10#13#10 +
    saFileData;

  result:=sa;


  JLog(cnLog_Error,201202222247,sa,SOURCEFILE);


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('JFC_CGIENV.HttpServerError500',SourceFile);
{$ENDIF}
end;
//=============================================================================














//=============================================================================
function JFC_CGIENV.saGetHeaders(
  p_sMimeType: string;
  p_u4ContentLength: cardinal;
  p_sCacheControl: string;
  p_sServerSoftware: string;
  p_sServerIdent: string
): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JFC_CGIENV.saGetHeaders';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //riteln('----ug_jfc_cgienv----');
  //riteln('p_sMimeType           ' , p_sMimeType);
  //riteln('p_u4ContentLength     ' , p_u4ContentLength);
  //riteln('p_sCacheControl       ' , p_sCacheControl);
  //riteln('p_sServerSoftware     ' , p_sServerSoftware);
  //riteln('p_sServerIdent        ' , p_sServerIdent);
  //riteln('----ug_jfc_cgienv----');




  // Don't Touch Redirects - Assume they have built thier headers already
  if (uHTTPResponse<300) or (uHTTPResponse>399) then
  begin

    //-----------------------------------------------------------------------------------------
    // Build Header
    //-----------------------------------------------------------------------------------------
    Header.AppendItem_saName_N_saValue('HTTP/1.1 ',saHTTPResponse);
    Header.AppendItem_saName_N_saValue('Server: ',p_sServerSoftware);
    Header.AppendItem_saName_N_saValue('Context-type: ',p_sMimeType);
    Header.AppendItem_saName_N_saValue('MIME-version: ','1.0');
    Header.AppendItem_saName_N_saValue('Allow: ','GET, POST');
    Header.AppendItem_saName_N_saValue('Cache-Control: ',p_sCacheControl);
    Header.AppendItem_saName_N_saValue('Content-length: ',inttostr(p_u4ContentLength));
    Header.AppendItem_saName_N_saValue('Connection: ','close');
    //-----------------------------------------------------------------------------------------
    // Build Header
    //-----------------------------------------------------------------------------------------
  end;
  //riteln('----B    ug_jfc_cgienv----');

  //-----------------------------------------------------------------------------------------
  //---------------------------------------------------------- OUTPUT HEADERS
  //-----------------------------------------------------------------------------------------
  result:='';
  Header_Cookies(p_sServerIdent);
  if Header.MoveFirst then
  begin
    repeat
      result+=Header.Item_saName+Header.Item_saValue+csCRLF   ;
    until not Header.MoveNext;
  end;
  result+=csCRLF;
  //-----------------------------------------------------------------------------------------
  //---------------------------------------------------------- OUTPUT HEADERS
  //-----------------------------------------------------------------------------------------
  
  //riteln('----C    ug_jfc_cgienv----');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('JFC_CGIENV.saGetHeaders',SourceFile);
{$ENDIF}
end;
//=============================================================================







//=============================================================================
// Initialization
//=============================================================================
Begin
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
