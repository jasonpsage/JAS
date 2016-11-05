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
{ }
// Unit that coupled with uxxg_cgiin makes for a rather complete CGI
// toolkit for FASTCGI-Like Architecture minus the need to compile
// code into each specific web server. 
Unit ug_cgiout;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_cgiout.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$DEFINE CGITHIN_TIGHTCODE}
{$IFDEF CGITHIN_TIGHTCODE}
  {$INFO | CGITHIN_TIGHTCODE}
{$ENDIF}

{DEFINE DEBUGCGI}
{$IFDEF DEFINE DEBUGCGI}
  {$INFO | DEFINE DEBUGCGI}
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
sysutils
,ug_cgiin
,ug_common
,ug_misc
,ug_jegas
,ug_jfc_xdl
,ug_jfc_matrix
,ug_jfc_tokenizer
;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{
Const cn_MaxEnvVariables = 100;
      cn_MaxEnvWarnThreshold = 60;
      
//-------------- The CGI Environment Gets Pushed in here
Type rtCGIEnv = Record
  iEnvVarCount: Integer; // How Many ENV Variables
  arEnvPair: array [0..cn_MaxEnvVariables-1] Of rtEnvPair;
  
  iRequestMethodIndex: Integer; // Set to WHICH in the Array of EnvPairs that
                                // have the request method (GET or POST)

  // POST SPECIFIC - if not post - assumed GET or a "got nothing" 
  //(I think technically a "got nothing" is a GET...).
  bPost: Boolean; // true if POST Recieved
  saPostData: AnsiString;
  iPostContentTypeIndex: Integer; // Set to WHICH in the Array of EnvPairs that
                           // have the CONTENT_TYPE Env Values
  iPostContentLength: Integer; 
End;  
//--------------------------------------------------------
Var grCGIEnv: rtCGIEnv;
Function iCGIIN: Integer;// Load CGI Environment
// CGIRELATED END
}

{}
Type JFC_CGIENV = Class
  ENVVAR: JFC_XDL;
  DATAIN: JFC_XDL;
  CKYIN: JFC_XDL;
  CKYOUT: JFC_XDL;
  {}
  //ENVVAR: JFC_MATRIX;
  //DATAIN: JFC_MATRIX;
  //CKYIN: JFC_MATRIX;
  //CKYOUT: JFC_MATRIX;
  {}


  sCommID: String[40];
  bPost: Boolean;
  sPostContentType: String;
  uPostContentLength: UInt;
  saPostData: AnsiString;
    
  Constructor create;
  
  Procedure CGIINIT(p_rCGI: rtCGI);
  Destructor destroy; override;
  Procedure AddCookie(
    p_saName, 
    p_saValue, 
    p_saPath: AnsiString;
    p_dt: TDATETIME; 
    p_bSecure: Boolean
  );
  Function saCGIHdrHTML: AnsiString;
  Function saCGIHdrXml: AnsiString;
  Function saNPHCGITEST: AnsiString;
  Function saRequestURIPath: AnsiString;
  Function saRequestURIWithoutParam:AnsiString;
  // Converts URL Encoded to Human readable
  Procedure TranslateParameters(Var p_saPostData: AnsiString); 
End;



//=============================================================================
{}
Type rtWebServerRequest=Record
  saIN: AnsiString;
  saOut: AnsiString;
  REQVAR_XDL: JFC_XDL;
  ip: AnsiString;
  i4BytesRead: LongInt;
  i4BytesSent: LongInt;
  bBlackListed: Boolean;
  bWhiteListed: boolean;
  bAccessDenied: Boolean;
  dtRequested: TDATETIME;
  sRequestMethod: String[10];
  sRequestType: String;
  saRequestedFile: AnsiString;
  saRequestedName: AnsiString;
  saRequestedDir: AnsiString;
  saFileSought: AnsiString;
  saQueryString: AnsiString;
  i4ErrorCode: LongInt; //< HTTP Error Code usually 200 for OK
  saLogFile: Ansistring; //< This is for deciding what log file to write out to.s
End;
//=============================================================================


//=============================================================================
{}
Function saCGIFormattedDate: AnsiString;
//=============================================================================
{}
Procedure TokenizeURI(p_MTX:JFC_XDL; p_sa: AnsiString; p_saDesc: AnsiString);
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
Procedure TokenizeURI(p_MTX:JFC_XDL; p_sa: AnsiString; p_saDesc: AnsiString);
//Procedure TokenizeURI(p_MTX:JFC_MATRIX; p_sa: AnsiString; p_saDesc: AnsiString);
//=============================================================================
Var
  iQM: Integer;
  TK: JFC_TOKENIZER;
Begin
  // Extra Feature - Fake Get .. If p_sa is sent http://somedir/yourcgi?some=data
  // It will handle removing the http://somedir/yourcgi? part for you.
  // This unit was not designed to need this, or even think about it but
  // the need arised where I wanted to parse REQUEST URL Env Variable.
  //
  // This way I could get a post and Still Do some fancy tricks :)

  iQM:=pos('?',p_sa);
  If iQM>0 Then p_sa:=rightStr(p_sa, length(p_Sa)-iQM);
  TK:=JFC_TOKENIZER.create;
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
      p_MTX.AppendItem;

      p_MTX.Item_saName:=Trim(UpCase(saGetStringBeforeEqualSign(TK.Item_saToken)));

      p_MTX.Item_saValue:=Trim(saGetStringAfterEqualSign(TK.Item_saToken));

      p_MTX.Item_saValue:=saDecodeURI(p_MTX.Item_saValue);
      p_MTX.Item_saDesc:=p_saDesc;
    Until not TK.MoveNExt;
  End;
  TK.Destroy;
End;
//=============================================================================


//=============================================================================
// Most Basic Instantiator
Constructor JFC_CGIENV.create;
//=============================================================================
Begin
  self.ENVVAR:=JFC_XDL.Create;
  self.DATAIN:=JFC_XDL.Create;
  self.CKYIN:=JFC_XDL.Create;
  self.CKYOUT:=JFC_XDL.Create;
  
  //self.ENVVAR:=JFC_MATRIX.Create;
  //self.ENVVAR.SetNoOfColumns(3);
  //self.DATAIN:=JFC_MATRIX.Create;
  //self.DATAIN.SetNoOfColumns(3);
  //self.CKYIN:= JFC_MATRIX.Create;
  //self.CKYIN.SetNoOfColumns(3);
  //self.CKYOUT:=JFC_MATRIX.Create;
  //self.CKYOUT.SetNoOfColumns(3);
  sPostContentType:='';
  bPost:=False;
  uPostContentLength:=0;
End;
//=============================================================================

//=============================================================================
Procedure JFC_CGIENV.TranslateParameters(Var p_saPostData: AnsiString);
//=============================================================================
Begin
  //If not bPost Then
  //Begin
    // GRAB QUERY_STRING  
    If ENVVAR.FoundItem_saName(csCGI_QUERY_STRING,True) Then
    Begin
      TokenizeURI(DATAIN, ENVVAR.Item_saValue, csCGI_QUERY_STRING);
      //ASPrintln('Tokenizing: '+ENVVAR.Item_saValue);
    End;
  //End
  //Else
    
    // Grab Posted Data 
  if bPost then  
  begin
    TokenizeURI(DATAIN, p_saPostData, csCGI_POST);
    //ASPrintln('Tokenizing postdata: '+p_saPostData);
    //ASPrintln('DATAIN.ListCount:'+saStr(DATAIN.ListCount));
    
    // Disect URI/URL and add it to the mix as well.
    If ENVVAR.FoundItem_saName(csCGI_REQUEST_URI,True) Then
    Begin
      TokenizeURI(DATAIN, ENVVAR.Item_saValue, csCGI_REQUEST_URI);
      //ASPrintln('Tokenizing Request uri: '+ENVVAR.Item_saValue);
    End;
  End;
End;
//=============================================================================
 


//=============================================================================
Procedure JFC_CGIENV.CGIINIT(p_rCGI: rtCGI);
//=============================================================================
Var u2,u2EQ: word;
Var TK: JFC_Tokenizer;
Begin
  self.ENVVAR.DeleteAll;
  self.DATAIN.DeleteAll;
  self.CKYIN.DeleteAll;
  self.CKYOUT.DeleteAll;
  // ENVIRONMENT VARI's
  If p_rCGI.uEnvVarCount>0 Then
  Begin
    For u2 := 0 To p_rCGI.uEnvVarCount-1 Do
    Begin
      ENVVAR.AppendItem_saName_N_saValue(
        UpCase(p_rCGI.arNVPair[u2].saName),
        p_rCGI.arNVPair[u2].saValue
      );
    End;
  End;

  // Other Stats captured in original rCGIIN/rCGI
  If p_rCGI.iPostcontentTypeIndex>0 Then
  Begin
    //if length(p_rCGI.arNVPair)>0 then
    //begin
      sPostContentType:=p_rCGI.arNVPair[p_rCGI.iPostContentTypeIndex].saValue;
    //end;
  End;
  bPost:=p_rCGI.bPost;
  uPostContentLength:=p_rCGI.uPostContentLength;
  
  //NOTE: Not doing this (copying post data into the saPostData
  //  variable) yet because it could be big and I'm
  // only writing support for x-www-form-url-encoded currently
  // saPostData:=p_rCGI.saPostData;
  // So for now x-www-form-url-encoded is implied.
  // 2006-07-22 Jason P Sage
  // TODO: Add other support.
  //
  // NOTE: FOR JEGAS APPLICATIONS THIS CODE NEEDS TO 
  // HAPPEN WHEN A WEB REQUEST beomes an INVOCATOR
  // OF JEGAS Routines!!!
  self.TranslateParameters(p_rCGI.saPostData);
  
  // GRAB the Cookies Coming In  
  If ENVVAR.FoundItem_saName(csCGI_HTTP_Cookie,True) Then
  Begin
    If length(ENVVAR.Item_saValue)>0 Then
    Begin
      TK:=JFC_TOKENIZER.Create;
      TK.SetDefaults;
      TK.sSeparators:=';';
      TK.sWhiteSpace:=';';
      TK.Tokenize(ENVVAR.Item_saValue);
      //TK.DumpToTextFile(grJASConfig.saLogDir + 'tk_cookie.txt');
      If TK.ListCount>0 Then 
      Begin
        TK.MoveFirst;
        repeat
          u2:=length(TK.Item_saToken);
          u2EQ:=pos('=',TK.Item_saToken);
          If u2EQ>1 Then
          Begin
            CKYIN.AppendItem_saName_N_saValue(
              trim(Upcase(leftstr(TK.Item_saToken, u2EQ-1))),
              trim(rightstr(TK.Item_saToken, u2-u2EQ)));
          End;
        Until not tk.movenext;
      End;
      TK.Destroy;
    End;
  End;
End;
//=============================================================================


//=============================================================================
Destructor JFC_CGIENV.destroy;
//=============================================================================
Begin
  // BROKEN CODE - THIS is the memory leak Created by Jason 2007-02-13 and 
  // found in the snow storm of 2007-02-14 - the following day - and fixed - 
  // after half a day/ lost tracking down this dumb shit right here!
  {Inherited;
  self.ENVVAR:=JFC_XDL.create;
  self.DATAIN:=JFC_XDL.create;
  self.CKYIN:=JFC_XDL.create;
  self.CKYOUT:=JFC_XDL.create;
  }
  
  // the fix - duh? How could I do this ahhhh!!!! Jason
  self.ENVVAR.destroy;
  self.DATAIN.destroy;
  self.CKYIN.destroy;
  self.CKYOUT.destroy;
  Inherited;
  
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

Begin
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
  //CKYOUT.AppendItem_saName_N_saValue(
  //  p_saName, 
  //  // Time Zone Thing
  //  p_saValue+';path='+p_saPath+';expires='+
  //  FormatDateTime(csWEBDATETIMEFORMAT,dtAddHours(p_dt,MAC_TIMEZONE_OFFSET))
  //);

  sa:=p_saValue+';path='+p_saPath+';expires='+
    FormatDateTime(csWEBDATETIMEFORMAT, dtAddHours(p_dt,grJASConfig.i1TIMEZONEOFFSET));
  
  if CKYOUT.FoundItem_saName(p_saName,false) then
  begin
    CKYOUT.Item_saName:=p_saName;
    CKYOUT.Item_saValue:=sa;
  end
  else
  begin
    CKYOUT.AppendItem_saName_N_saValue(p_saName, sa);
  end;
  
  If p_bSecure Then 
  Begin
    CKYOUT.Item_saValue:=CKYOUT.Item_saValue+'; secure=yes';
  End;
  //p_saValue+';path='+p_saPath+';expires='+
  //  FormatDateTime(csWEBDATETIMEFORMAT,dtAddHours(p_dt,0))
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

//TODO: Integrate a definitive cache flow control that all the header creation
// functions can use by accepting a cache parameter (that is text) created
// by a function specifically designed to create user designed cache behavior.
// NOTE: The priority for this is not that high because  
Function JFC_CGIENV.saCGIHdrHtml: AnsiString;
//=============================================================================
Var sa: AnsiString;
Begin
  sa:='';
//  Writeln('HTTP/1.1 200 OK');
  //Writeln('Server: mattermuch');
  //Writeln;
  // These Show up in HTTP_COOKIE env var :)
  //Writeln('Set-Cookie: jasoncookie1=somedata;path=/cgi-bin;expires=Thu, 01 Dec 2003 16:00:00 GMT');
  //Writeln('Set-Cookie: jasoncookie2=somemoredata;path=/cgi-bin;expires=Thu, 01 Dec 2003 16:00:00 GMT');
  //Writeln('Set-Cookie: jasoncookie3=somedata;path=/cgi-bin;expires=Thu, 01 Dec 2003 16:00:00 GMT');
//  Writeln('Content-type: text/html');
  sa+=csCGI_HTTP_HDR_VERSION+csHTTP_RESPONSE_200+csCRLF;
  sa+='Cache-Control: private, max-age=0'+csCRLF;
  // This was recommneded for MyServer:  Transfer-Encoding: chunked
  //sa+='Transfer-Encoding: chunked'+ csCRLF;
  
  //sa+=csCGI_SERVER+csCRLF;
  //sa+='Set-Cookie: cgibin=cookcgibin;path=;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: jegas=cookjegas;path=/jegas;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: jegascom=cookjegascom;path=/jegas/com;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  //sa+='Set-Cookie: BIG=BIG;path=/jegas/com;expires=Thu, 01 Dec 2007 16:00:00 GMT'+csCRLF;
  If self.ckyout.movefirst Then 
  Begin
    repeat
      sa+='Set-Cookie: ' + trim(self.ckyout.item_saName)+'='+
               trim(self.ckyOut.Item_saValue)+csCRLF;
    Until not self.ckyout.movenext;
  End;
  sa+=csINET_HDR_CONTENT_TYPE + csMIME_TextHtml+csCRLF+csCRLF;
  Result:=sa;
End;
//=============================================================================

//=============================================================================
// Sends Header Required to send a simple xml document.
Function JFC_CGIENV.saCGIHdrXml: AnsiString;
Begin
  Result:='';
  Result+=csCGI_HTTP_HDR_VERSION+csHTTP_RESPONSE_200+csCRLF;
  Result+='Accept-Ranges: bytes'+csCRLF;
  Result+='Content-Length: [@CONTENTLENGTH@]'+csCRLF;
  Result+='Connection: close'+csCRLF;
  Result+=csMIME_TextXml+csCRLF+csCRLF;
  //Result+='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+csCRLF;
  //Result+='<?xml version="1.0" encoding="UTF-8" ?>'+csCRLF;
  
  //FormatDateTime(csWEBDATETIMEFORMAT, dtAddHours(p_dt,grJASConfig.iTIMEZONEOFFSET))
  
End;
//=============================================================================


//=============================================================================
Function JFC_CGIENV.saNPHCGITEST: AnsiString;
//=============================================================================
Begin
  AddCookie(
      'NPHCGITEST_COOKIE',
      'I am a cookie that expires in 5 minutes.',
      '',
      dtAddminutes(now,5),
      False
  );
  Result:=saCGIHdrHtml;
  Result+='<!DOCTYPE HTML public "-//W3C//DTD HTML 4.0//EN"'+
          '"http://www.w3.org/TR/REC-html40/strict.dtd"><HTML>'+
          '<HEAD><TITLE>NPH-CGITEST By: Jason P Sage</TITLE></HEAD>'+
          //Background black, links blue (unvisited), navy (visited), red (active)
          '<BODY bgcolor="#000000" text="#FFFFFF" link="#0000FF"'+
          ' vlink="#000080" alink="#FF0000">'+
          '<H1 align="center">NPH-CGITEST v5.0</H1>'+
          '<h3 align="center">CGI Serverside HTML Form Tester</h3>'+
          '<h4 align="center">By: <a href="mailto:jasonpsage@jegas.com">'+
          'Jason Peter Sage</a></h4>'+
          '<p align="center">This application runs on Win32 (IIS and Apache 2) and POSIX '+
          'platforms (Apache 2). It was created with FreePascal 2.0.2. It was '+
          'originally created 2003-02-05.'+
          '</p>'+
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

End;
//=============================================================================

//=============================================================================
//Function saCGIFormatedDate(p_dtLocalTime: TDATETIME): AnsiString;
Function saCGIFormattedDate: AnsiString;
Begin
  Result:='Date: '+FormatDateTime(csWEBDATETIMEFORMAT, 
          dtAddHours(now, cnTIMEZONE_OFFSET))+csCRLF;
End;
//=============================================================================

//=============================================================================
Function JFC_CGIENV.saRequestURIWithoutParam: AnsiString;
//=============================================================================
Var saRURI: AnsiString;
    iPosOfQuestionMark: Integer;
Begin
  Result:='';
  saRURI:=self.ENVVAR.Get_saValue('REQUEST_URI');
  If length(saRURI)>0 Then
  Begin
    iPosOfQuestionMark:=pos('?',saRURI);
    If  iPosOfQuestionMark > 0 Then
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

End;
//=============================================================================

//=============================================================================
// Used for Determining Cookie path for example
Function JFC_CGIENV.saRequestURIPath: AnsiString;
//=============================================================================
Var saRURI: AnsiString;
    iPosOfLastSlash: Integer;
Begin
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

End;
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
