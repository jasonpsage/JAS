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
// Note: The purpose of this UNIT is to make a CGI application that
// is lean as possible - in that its purpose is to gather all the environment
// information, send it to another application that will do the actual work,
// and wait for (predetermined maximum wait time) the response and output
// it correctly. In short - trying to offset a BIG application's start up
// time and shut down time - which is normally the Achilles heel of CGI.
//
// Note that CGIIN (this unit) has a mate - CGIOUT - which has the
// overhead of classes etc... but shares the common structures here
// by "USING" this unit also. This allows for a tight integration with
// a single place for structure declarations that are shared, at the same
// time still allowing a LEAN CGI EXE for the "thin Client model discussed here.
//
// The "mate" is uxxxg_cgiout.pp as of this edit 2006-07-14 Jason P Sage
//
// The theory is that if I can write a thin enough client that can load quickly
// like a tiny CGI APP... that doens't do a whole hell-uv-a-lot - this might
// be a viable alternative to writing FastCGI hooks, and Apache, IIS  Specific
// hooks etc.
//
// That being said - FreePascal CLASSES are not going to be loaded if I can
// help it. Great care is going into trying to keep the binary small.
//
// Because I can't expect the Free Pascal (unpaid) world to respond to my
// every technical hurdle - I am going to try to make the simplest self
// contained code I can... relying on translated headers but shying away
// from constructs that use classes internally etc. That is my goal....
// Let's see how this ends up looking. --- Jason P Sage 2006-07-11
//
// TODO: Put limit on PASSEDDATA length - in otherwords,
// consider making it less likely HUGE submissions would be considered
// as one request - for say a DOS attack.
Unit ug_cgiin;
//=============================================================================


//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_cgiin.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$DEFINE CGITHIN_TIGHTCODE}
{$IFDEF CGITHIN_TIGHTCODE}
  {$INFO | CGITHIN_TIGHTCODE}
{$ENDIF}

{DEFINE CGIIN_DIAGNOSTIC_LOG}
{$IFDEF CGIIN_DIAGNOSTIC_LOG}
  {$INFO | CGIIN_DIAGNOSTIC_LOG}
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
Uses //WANT THIS LEAN AS POSSIBLE!
//=============================================================================
dos
,ug_common
{$IFNDEF CGITHIN_TIGHTCODE}
,ug_jegas
,sysutils
{$ENDIF}
;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Var rCGIIN: rtCGI;
//=============================================================================
{}
// Loads CGI environment into rCGIIN, returns 0 if successful.
// other numbers indicate errors
Function i8CGIIN: Int64;// Load CGI Environment
//=============================================================================

//=============================================================================
{}
// Sends User's Browser to web page you specify
Function saCGIHdrRedirect(p_saURL,p_saCGIFormattedDate:AnsiString): AnsiString;
//=============================================================================


//=============================================================================
{}
// Sends HEader required for sending plain text
Function saCGIHdrPlainText: AnsiString;
//=============================================================================

//=============================================================================
{}
// Sends Header Required to send a html document - like JFC_CGIENV.saCGIHdrHtml
// But Without the cookies-n-milk
Function saCGIHdrHtmlNoCookie: AnsiString;
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
// Sends User's Browser to web page you specify
Function saCGIHdrRedirect(p_saURL,p_saCGIFormattedDate:AnsiString): AnsiString;
//=============================================================================
//HTTP/1.1 302 Redirected
//Server: Microsoft-IIS/5.0
//Date: Mon, 24 Mar 2003 21:44:30 GMT
//Location: http://lc1.law5.hotmail.passport.com/cgi-bin/login
//<blank>
Begin
  // NOTE: in u01g_cgiout there is a function titled
  // saCGIFormattedDate that returns this line in the correct format AND
  // ALSO returns the necessary csCRLF.
  // SO you can USE THIS: 
  //saCGIHdrRedirect('http://someplace.com/',saCGIFormattedDate);


  Result:='HTTP/1.1 302 Redirected'+ csCRLF +
          csINET_HDR_SERVER + csINET_JAS_CGI_SOFTWARE + csCRLF + 
          p_saCGIFormattedDate + 
          'Location: '+p_saURL+csCRLF+csCRLF;
End;
//=============================================================================

//=============================================================================
// Sends Header required for sending plain text
Function saCGIHdrPlainText: AnsiString;
//=============================================================================
Begin
  Result:=csCGI_HTTP_HDR_VERSION+csHTTP_RESPONSE_200+csCRLF+
          csINET_HDR_SERVER + csINET_JAS_CGI_SOFTWARE + csCRLF + 
          csMIME_TextPlain + csCRLF+
          csCRLF; 
End;
//=============================================================================

//=============================================================================
// Sends Header Required to send a html document - like JFC_CGIENV.saCGIHdrHtml
// But Without the cookies-n-milk
Function saCGIHdrHtmlNoCookie: AnsiString;
//=============================================================================
Begin
  Result:= 
           csCGI_HTTP_HDR_VERSION+csHTTP_RESPONSE_200+csCRLF+
           csINET_HDR_SERVER + csINET_JAS_CGI_SOFTWARE + csCRLF + 
           csMIME_TextHtml+csCRLF+
           csCRLF;
End;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!CGIIN - Get CGI Environment
//*****************************************************************************
//=============================================================================
//*****************************************************************************
Function i8CGIIN: Int64;
Var t: Integer;
    eq: Integer;
    sa: AnsiString;
    
    cc: Integer;//counter for post data char count of read
    c: Char;// individual char - for post data read
    
    {$IFDEF CGIIN_DIAGNOSTIC_LOG}
    f: text;    
    {$ENDIF}
    
Begin
  Result:=0;
  {$IFNDEF CGITHIN_TIGHTCODE}
  JLog(MAC_SEVERITY_DEBUG, 3,'CGIIN BEGIN', SOURCEFILE);
  {$ENDIF}
  // Gather Environment Variables First.
  With rCGIIN Do Begin
    iEnvVarCount:=envcount;
    // Assumed compiler handles this during allocation - 
    // AnsiStrings get special compiler handling. 
    // Prob safe for others - but - gut says don't assume - 
    // Initialize - Jason P Sage
    // --- And here I assume Ansi's ok hahah ;) -- its a pointer and "new" 
    // call thing. (that is next line not a loop clearing strings to ''.)
    // arNVPair: array [0..cn_MaxEnvVariables-1] of rtEnvPair;
    // ---
    iRequestMethodIndex:= -1; // Set to WHICH in the Array of EnvPairs that
                             // have the request method (GET or POST)
  
    // POST SPECIFIC - if not post - assumed GET or a "got nothing" 
    //(I think technically a "got nothing" is a GET...).
    bPost:=False;// true if POST Recieved
    //saPostData: AnsiString; 
    iPostContentTypeIndex:=-1;// Set to WHICH in the Array of EnvPairs that
                              // have the CONTENT_TYPE Env Values
    iPostContentLength:=-1; // Length of posted Content.
    iEnvVarCount:=envcount;
    rCGIIN.bPost:=False;// Make Sure we start initialized.
  End;
  
  // Attempt to warn that the hardcoded ENV variable limit
  // is getting close (or exceeded) the  threshold.
  If (rCGIIN.iEnvVarCount>=cn_MaxEnvWarnThreshold) Then
  Begin 
    If (rCGIIN.iEnvVarCount<cn_MaxEnvVariables) Then
    Begin
      {$IFNDEF CGITHIN_TIGHTCODE}
      JLog(MAC_SEVERITY_WARN,13, 'CGI Environment variables past hardcoded ' +
        'threshhold of ' + inttostr(cn_MaxEnvWarnThreshold) +'.' +
        ' Absolute Maximum that can be handled: ' + inttostr(cn_MaxEnvVariables) + 
        ' This invocation had ' + inttostr(rCGIIN.iEnvVarCount) + '.',
        SOURCEFILE);
      {$ENDIF}
      Result:=13;
    End
    Else
    Begin
      {$IFNDEF CGITHIN_TIGHTCODE}
      JLog(MAC_SEVERITY_ERROR,14, 'Maximum CGI Environment variables EXCEEDED ' +
        ' the hardcoded limit of : ' + inttostr(cn_MaxEnvVariables) +'. ' +
        ' Lower # of environment variables in your system or contact support.'+
        ' Only first ' + inttostr(cn_MaxEnvVariables) + ' variables processed.',
        SOURCEFILE);
      {$ENDIF}
      rCGIIN.iEnvVarCount:=cn_MaxEnvVariables;
      Result:=14;// allows code that cares to handle - but continues.
      // allowing a limp by kinda of approach if programmer doesn't address.
    End;
  End;
  
  
  {$IFDEF CGIIN_DIAGNOSTIC_LOG}
  assign(f, 'uxxg_cgiin_diagnostic_log.txt');
  {$I-}
  rewrite(f);
  {$I+}
  {$ENDIF}  
  
  // grab-n-store the environment variables.
  For t:=0 To rCGIIN.iEnvVarCount-1 Do
  Begin
    sa:=envstr(t);
    eq:=pos('=',sa);
    rCGIIN.arNVPair[t].saName:=copy(sa,1,eq-1);
    rCGIIN.arNVPair[t].saValue:=copy(sa,eq+1,length(sa)-eq);
    
    //We do this because I we get double percents in the query string
    // I THINK it's because the parameters for a get are passed on the command line
    // and perhaps a windows only thing but say for and email address in the query string (get) like this: email=test@test.com
    // I'd get: email=test%%40test.com instead of email=test%40test.com  ... so 
    // I added this bit of code to solve it.
    // If you are feeling enterprising - test if this is a windows only thing, and 
    // test to make sure only query_string is effected by this. I imagine other parameters
    // could be subject but I don't think percent characters are typical for the other environment 
    // variables.
    If (rCGIIN.arNVPair[t].saName=csCGI_QUERY_STRING) then
    begin
      rCGIIN.arNVPair[t].saValue:=saSNRStr(rCGIIN.arNVPair[t].saValue,'%%','%',true);
    end;
    
    {$IFDEF CGIIN_DIAGNOSTIC_LOG}
    writeln(f,t,' "',sa,'" equal pos=',eq,' NAME: "',rCGIIN.arNVPair[t].saName,'" Value: "',rCGIIN.arNVPair[t].saValue,'"');
    {$ENDIF}
    If (rCGIIN.arNVPair[t].saName=csCGI_REQUEST_METHOD) Then
    Begin
      rCGIIN.iRequestMethodIndex:=t;
    End;       
    If (rCGIIN.arNVPair[t].saName=csCGI_CONTENT_TYPE) Then
    Begin
      rCGIIN.iPostContentTypeIndex:=t;
    End;       
    If (rCGIIN.arNVPair[t].saName=csCGI_CONTENT_LENGTH) Then
    Begin
      //Writeln('Content Length String:'+rCGIIN.arNVPair[t].saValue);
      rCGIIN.iPostContentLength:=iVal(rCGIIN.arNVPair[t].saValue);
      //Writeln('iLeanIntToStr:',iLeanIntToStr(rCGIIN.arNVPair[t].saValue));
    End;       
    //Writeln(rCGIIN.arNVPair[t].saName, #09, rCGIIN.arNVPair[t].saValue+'<br>');
  End;
  //Writeln('got env ..next is post');

  {$IFDEF CGIIN_DIAGNOSTIC_LOG}
  close(f);
  {$ENDIF}


  // OK POST Part
  If rCGIIN.iRequestMethodIndex>-1 Then 
  Begin // avoid crash cuz env limit maxed out - possibilty low but...
    rCGIIN.bPost:=rCGIIN.arNVPair[rCGIIN.iRequestMethodIndex].saValue='POST';
    If rCGIIN.bPost Then
    Begin
      rCGIIN.arNVPair[rCGIIN.iPostContentTypeIndex].saValue:=
        upcase(rCGIIN.arNVPair[rCGIIN.iPostContentTypeIndex].saValue);
      If rCGIIN.arNVPair[rCGIIN.iPostContentTypeIndex].saValue=
        csCGI_application_x_www_form_urlencoded Then 
      Begin
        If rCGIIN.iPostContentLength>0 Then
        Begin
          cc:=0;
          //TODO: This may be able to be optimize, but I'm not
          // sure if you can block read from stdin in one pass.
          // additionally the blockread length would have to 
          // be predetermined (which is t should be already
          // via rCGIIN.iPostContentLength) I do remember
          // with apache, looping for EOF didn't work right.
          rCGIIN.saPostData:='';
          While cc<rCGIIN.iPostContentLength Do Begin
            cc+=1; //rite(cc,' ');
            read(c);// Writeln(Ord(c),' ',c);
            rCGIIN.saPostData:=rCGIIN.saPostData+c;
          End;
        End;
      End 
      Else
      Begin
        {$IFNDEF CGITHIN_TIGHTCODE}
        JLog(MAC_SEVERITY_WARN, 15,'Unknown CONTENT_TYPE:'+
          upcase(rCGIIN.arNVPair[t].saValue), SOURCEFILE);
        {$ENDIF}
        Result:=15;
      End;
    End;
  End;
  {$IFNDEF CGITHIN_TIGHTCODE}
  JLog(MAC_SEVERITY_DEBUG, 4,'CGIIN END', SOURCEFILE);
  {$ENDIF}
End;



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
