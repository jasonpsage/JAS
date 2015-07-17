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
// Handles Serving Files in a webserver role
Unit uj_fileserv;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_fileserv.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE DIAGMSG}
{$IFDEF DIAGMSG}
  {$INFO | DIAGMSG: TRUE}
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
,dos
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_tokenizer
,ug_tsfileio
,uj_permissions
,uj_notes
,uj_context
,uj_definitions
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
// This is the internal function that serves all the webserver files.
// It works by simply passing in the filename you are after and you typically
// pass in a p_iHTTPResponse of 200 (see cnHTTP_RESPONSE_200 defined in 
// uxxg_common.pp for sample response codes.) Upon return, the function returns the
// complete file as its result with a potentially different value in p_iHTTPResponse.
Function getfile(p_Context: TCONTEXT; p_saFilename: AnsiString; var p_iHTTPResponse: integer): AnsiString;
//=============================================================================
{}
// This is an internally used function that performs initialization required 
// to take a web request and prepare TCONTEXT for executing the request as
// a Jegas/JAS application.
// JAS applications originated in purely CGI environments. Therefore there is 
// the need to pull in the following variables from the webserver itself into the 
// p_Context.CGIENV.ENVAR JFC_XDL double linked list. Also the requested file needs 
// to be parsed and the HTMLRIPPER/HTML Template system primed for action.
// This routine is very similiar to the code used internally by the web server to 
// launch external CGI applications such as PHP, Perl and others.
// It is reasonable that the system could be gone through to remove the 
// dependance on this function. Basically, web serves are faster by not calling it 
// for simple file requests. We only call this if we are ramping up to run
// some thick code or a "JAS" application which is when we are basically
// firing up our internal application sus-system that makes this an
// application server and not just a web server, or a crm, or a whatever
// else.
//Procedure PrepareWebBasedJegasApplication(p_Context: TCONTEXT);
//=============================================================================
{}
// HTMLRIPPER is the pet name for the JAS templating system. HTMLRIPPER 
// was originally created as a tool to make creating websites easier by not 
// needing to have repetitive HTML code throughout a website. It has since matured   
// into a pretty powerful templating system. The core of this templating system
// is "Function saGetPage". 
// 
// This saHTMLRIPPER function is a wrapper for the basic HTMLRIPPER usage  
// where you can have an AREA (template) and load content from a "PAGE" and 
// selectively display a certain "SECTION" in the page as needed.   
//
// NOTE: Caller parameter added so you can track who called the function
// when debugging. Optimizations could include compiler directives to
// electively compile without the extra debugging code - then again - its
// helpful when you're LIVE too!
Function saHtmlRipper(p_Context: TCONTEXT; p_i8Caller: uint64): AnsiString;
//=============================================================================
{}
// This Function Call Has become a litle advanced. At least in that its time to 
// Explain how it works. In short - it takes parameters that tell it how to build 
// a HTML page from templates. It does this and returns the compiled HTML.
//
//
// p_saArea: is the HTMLRIPPER template filename without the file name extension.
//           If nothing is passed then the filename specified in 
//           grJASConfig.saDefaultPage is used (This file MUST Exist even if
//           it is not actually used for SECTION ONLY calls Explained below)
//           First this file is searched for in the same directory the JEGAS
//           CGI THIN CLIENT is launched from. Then it looks in the configured 
//           JAS HTML directory for it. If an AREA file (Default or otherwise)
//           cannot be located and loaded - an error is returned to the user.
//           (Case Sensitive. Lowercase .html presumed)
//  
// p_saPage: This is the HTML file that has the SECTION you wish to load. It
//           first search for this file in the directory the JEGAS CGI THIN 
//           CLIENT was launched in. If it is not there, it looks in the 
//           configured JAS HTML directory. If the file cannot be loaded,
//           an error is generated. 
//           (Case Sensitive. Lowercase .html presumed)
//           (Note: IF ANYTHING AT ALL IS PASSED in the p_saCustomSection 
//           parameter, then this PARAMETER is IGNORED!)
//
// p_saSection: This is the NAME of the SECTION you want to RIP out of the 
//           p_saPage template. Sections are discerned from HTML comments
//           that look like:
//               <!--SECTION SECTIONNAME BEGIN-->
//               <!--SECTION SECTIONNAME END-->
//
//           The above "SECTIONAME" is where you name your section. Do not use
//           spaces, USE ALL UPPERCASE. The parameter you pass to look for the
//           the section does not need to be in uppercase. This is done for 
//           you.
//
//           If the SECTION cannont be found in the html template file you
//           specified in p_saPage, then the whole p_saPage data is sent.
//           This is usually undesired, so make your HTML templates carefully.
//
//           (Note: IF ANYTHING AT ALL IS PASSED in the p_saCustomSection 
//           parameter, then this PARAMETER is IGNORED!)
//
//
// p_bSectionOnly: If this parameter is passed as true, this function only returns
//                 the HTML in between the SECTION TAGS explained above or the 
//                 p_saCustomSection value.
//
// (optional)
// p_saCustomSection: This parameter allows you to send HTML and have it inserted 
//                    into the AREA template. Because this overrides the p_saPage
//                    and p_saSection parameters, and allows you to pass your 
//                    own CUSTOM SECTION into an AREA (htmlripper) template,
//                    you can get silly results by setting the p_bSectionOnly
//                    flag to true. Simply put, if you do that (not likely you 
//                    should) this function will simply return your passed custom
//                    section.
// NOTE: Caller parameter added so you can track who called the function
// when debugging. Optimizations could include compiler directives to
// electively compile without the extra debugging code - then again - its
// helpful when you're LIVE too!
Function saGetPage(
  p_Context: TCONTEXT; 
  //var p_bErrorOccurred: boolean;
  p_saArea: AnsiString;
  p_saPage: AnsiString; 
  p_saSection: AnsiString;
  p_bSectionOnly: Boolean;
  p_saCustomSection: AnsiString;
  p_i8Caller: uint64
): AnsiString;
//=============================================================================
{}
// This is a shorterhand method of using saGetPAge. See the other one for the 
// full description of saGetPage's functionality.  
//
// NOTE: Caller parameter added so you can track who called the function
// when debugging. Optimizations could include compiler directives to
// electively compile without the extra debugging code - then again - its
// helpful when you're LIVE too!
Function saGetPage(
  p_Context: TCONTEXT; 
  {}
  //var p_bErrorOccurred: boolean;
  {}
  p_saArea: AnsiString;
  p_saPage: AnsiString; 
  p_saSection: AnsiString;
  p_bSectionOnly: Boolean;
  p_i8Caller: uint64
): AnsiString;
//=============================================================================

//=============================================================================
{}
// returns Note providing session is valid and JNote_Table_ID points to
// jsecperm and JNote_Row_ID points to the required permission. If null or zero,
// no permission required to get it! So pay attention! LOL ;)
//
// example: ?action=????&decodeuri=yes&uid=100
//
// where UID = [JNote_JNote_UID]
//
// Language is taken into consideration!
//
procedure JAS_NoteSecure(p_Context: TCONTEXT);
//=============================================================================
{}
procedure JAS_RenderMindMap(p_Context: TCONTEXT);
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
// !#! ========================================================================
//*****************************************************************************


//=============================================================================
Function saGetPage(
  p_Context:tContext; 
  p_saArea: AnsiString;
  p_saPage: AnsiString; 
  p_saSection: AnsiString;
  p_bSectionOnly: Boolean;
  p_saCustomSection: AnsiString;
  p_i8Caller: uint64
): AnsiString;
//=============================================================================
Var 
  bSuccess: Boolean;
  saFileName: AnsiString;
  TK1, TK2, TK3: JFC_TOKENIZER;//TK is the template, TK2 is the file to insert
  saLoadedfileData: AnsiString;
  saData: AnsiString;  

  u2IOResult:word;
  bLoadedSectionOk: boolean;
  saTemp: ansistring;
  saGetFileCaller: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}




//----------------------------
                        Procedure SendOutTheData;
                        Begin
                          {$IFDEF DEBUGLOGBEGINEND}
                            DebugIn(sTHIS_ROUTINE_NAME+'.SendOutTheData Caller:'+inttostr(p_i8Caller),SourceFile);
                          {$ENDIF}
                          {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203161901,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
                          {$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203161901, sTHIS_ROUTINE_NAME);{$ENDIF}

                          If not p_Context.bErrorCondition Then 
                          Begin
                            //CGI.saCGIHdrHTML;
                            //ASPrintLn('Tokens: '+ inttostr(TK1.Tokens));
                            //ASPrintLn('ListCount:'+inttostr(TK1.ListCount));

                            if TK1.MoveFirst then
                            begin

                              //---UNCOMMENT to DEBUG - they make diagnostics files of the 
                              //--- contexts of the u01g_jfc_tokenizer.pp JFC_TOKENIZER class.
                              //--- and to make sure you have the "right" ones, You might 
                              //--- want to uncomment the DEBUG abrupt H A L T(0) below the repeat loop,
                              //--- then examine the output TK1.txt and TK2.txt to understand what's 
                              //--- going on. :)
                              //TK1.DumpToTextFile(grJASConfig.saLogDir+csDOSSLASH+'TK1.txt');
                              //TK2.DumpToTextFile(grJASConfig.saLogDir+csDOSSLASH+'TK2.txt');
                              repeat 
                                case TK1.Item_iQuoteID of
                                0:begin // At "TOP" or "BOTTOM" chunk of HTMLRIPPER file
                                    If not p_bSectionOnly Then
                                    Begin
                                      saData+=TK1.Item_saToken;
                                    End;
                                end;
                                1:begin // In "Insert Here" area of HTMLRIPPER File
                                  // The TK2 should only have a item with QuoteID = 1 
                                  // when it found the desired section of a template.
                                  If TK2.FoundItem_iQuoteID(1) then
                                  begin
                                    saData+=TK2.Item_saToken;
                                  end
                                  else  
                                  begin
                                    If not p_bSectionOnly Then 
                                    Begin
                                      // In theory we are pulling in the 
                                      // htmlripper template's "INSERT" here stuff 
                                      // because we don't any replacement "section" data for it.
                                      saData+=TK1.Item_saToken;
                                    End;
                                  end;
                                end;
                                end;//endcase
                              Until not TK1.MoveNext;
                            end;
                            //h a l t (0);                            
                            
                            // dynamic Titles
                            TK3.SetDefaults;
                            TK3.bCaseSensitive:=True;//for speed. 
                            TK3.QuotesXDL.AppendItem_QuotePair(
                              '<!--PAGETITLE "',
                              '"-->');
                            TK3.Tokenize(saData);
                            If TK3.FoundItem_iQuoteID(1) Then
                            Begin
                              p_Context.saPagetitle:=TK3.Item_saToken;
                              //p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]',TK3.Item_saToken);
                            End
                            else
                            begin
                              TK3.SetDefaults;
                              TK3.bCaseSensitive:=True;//for speed. 
                              TK3.QuotesXDL.AppendItem_QuotePair(
                                '<!--MENUTITLE "',
                                '"-->');
                              TK3.Tokenize(saData);
                              If TK3.FoundItem_iQuoteID(1) Then
                              Begin
                                p_Context.saPagetitle:=TK3.Item_saToken;
                              end;
                            end;

                          End;                           
                          {$IFDEF DEBUGLOGBEGINEND}
                            DebugOut(sTHIS_ROUTINE_NAME+'.SendOutTheData Caller:'+inttostr(p_i8Caller),SourceFile);
                          {$ENDIF}
                          {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203161902,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
                        End;
//----------------------------



Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='Function saGetPage(p_Context:tContext;p_saArea: AnsiString;p_saPage: AnsiString;p_saSection: AnsiString;'+
    'p_bSectionOnly:Boolean;p_saCustomSection: AnsiString;p_i8Caller: uint64): AnsiString;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102320,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102321, sTHIS_ROUTINE_NAME);{$ENDIF}

  {$IFDEF DIAGMSG}
  JASPrintln('saGetPage-----------------------BEGIN');
  JASPrintLn('p_saArea:'+p_saArea);
  JASPrintLn('p_saPage:'+p_saPage);
  JASPrintLn('p_saSection:'+p_saSection);
  JASPrintLn('p_bSectionOnly:'+saTRueFalse(p_bSectionOnly));
  JASPrintLn('p_saCustomSection:'+p_saCustomSection);
  {$ENDIF}

  bSuccess:=True;
  saLoadedFileData:='';
  saData:='';
  saGetFileCaller:=inttostr(p_i8Caller);saGetFileCaller:=saGetFileCaller;//shutup compiler - frowned practice LOL
  saFileName:=p_saArea;
  {IFDEF DIAGMSG}
  //ASPrintln('getfile - AREA - 100 saFilename:'+saFilename);
  {ENDIF}
  If (length(safilename)>0) and (saFilename<>'jas') Then
  Begin
    saFileName+=csJASFileExt;
    {$IFDEF DIAGMSG}
    jASPrintln('200 saFilename:'+saFilename);
    {$ENDIF}
  End 
  Else 
  Begin
    saFilename:=garJVHostLight[p_Context.i4VHost].saDefaultArea+csJASFileExt;
    {$IFDEF DIAGMSG}
    jASPrintln('300 saFilename:'+saFilename);
    {$ENDIF}
  End;

  // First See if required JAS/HTML FILE is available from the requested dir
  //ASPrintLn('saGetPage - first file check:'+p_Context.saRequestedDir + saFilename);
  If FileExists(p_Context.saRequestedDir + saFilename) Then
  Begin
    {$IFDEF DIAGMSG}
    jASPrintln('saGetFile - GOT IT!'+' GetFileCaller:'+saGetFileCaller);
    {$ENDIF}
    saFilename := p_Context.saRequestedDir + saFilename;
  End
  Else
  Begin
    If FileExists(saFileName) Then
    Begin
      {$IFDEF DIAGMSG}
      jASPrintln('saGetFile - GOT IT!'+' GetFileCaller:'+saGetFileCaller);
      {$ENDIF}
    End
    Else
    Begin
      //------- LOCATE METHOD
      {$IFDEF DIAGMSG}
      JASPrintln('saGetFile - Attempting saJASLocateTemplate on:'+saFilename+' Lang:'+p_Context.saLang+' ColorTheme: '+p_Context.saColorTheme+' GetFileCaller:'+saGetFileCaller);
      {$ENDIF}
      saTemp:=saJASLocateTemplate(saFilename,p_Context.saLang, p_Context.saColorTheme, p_Context.saRequestedDir,201012301748,garJVHostLight[p_Context.i4VHost].saTemplateDir);
      if length(saTemp)>0 then
      begin
        saFilename:=saTemp;
      end
      else
      begin
        JAS_LOG(p_Context, cnLog_Warn, 201204142128, 'saGetPage - Unable to find Area file: '+p_saArea+' Caller: '+ inttostr(p_i8Caller),'',SOURCEFILE);
      end;
      {$IFDEF DIAGMSG}
      JASPrintln('saGetFile - Attempt Result: '+saTemp+' GetFileCaller:'+saGetFileCaller);
      {$ENDIF}
      //------- LOCATE METHOD


      if length(saTemp)=0 then
      begin
        // Make FileName Work With Default HTMLFILES directory.
        //----------------------------------------------------
        {$IFDEF DIAGMSG}
        JASPrintLn('saGetFile - Couldn''t find it... so trying default!'+' GetFileCaller:'+saGetFileCaller);
        {$ENDIF}
        saFilename:=garJVHostLight[p_Context.i4VHost].saTemplateDir+ p_Context.saLang+csDOSSLASH+safilename;
        {$IFDEF DIAGMSG}
        JASPrintLn('saGetFile - default file check:'+ saFilename+' GetFileCaller:'+saGetFileCaller);
        {$ENDIF}
        //----------------------------------------------------
        //AS_Log(p_Context,cnLog_DEBUG,200709272016,'GETPAGE DEBUG NOTE for Admin.','In GETPAGE and this is the TEMPLATE HTML to Load:'+saFilename,sourcefile);
      end;
    end;
  End;


  {$IFDEF DIAGMSG}
    JASPrintln('400 About to open saFilename:'+saFilename);
    JASPrintln('saGetPage - Filename: '+ saFilename +' Exists: '+saTRueFalse( fileexists(saFileName))+' GetFileCaller:'+saGetFileCaller);
  {$ENDIF}
    

  if bTSLoadEntireFile(saFilename, u2IOResult, saLoadedFileData) then
  Begin
    //AS_Log(p_Context,cnLog_DEBUG,200709272017,'DEbug - GetPage just loaded a file.','In GETPAGE and FILE Just Loaded:'+saFilename,sourcefile);
    {$IFDEF DIAGMSG}
    JASPrintLn('Loaded file OK:'+saFilename);
    {$ENDIF}
    TK1:=JFC_Tokenizer.create;
    TK1.bCaseSensitive:=True;//for speed.
    TK1.QuotesXDL.AppendItem_QuotePair(csHTMLRipperStart,csHTMLRipperEnd);
    TK1.Tokenize(saLoadedFileData);
    //TK.DumpToTextFile('htmlripper.txt');
    TK2:=JFC_Tokenizer.create;
    TK3:=JFC_TOKENIZER.Create;

    // Now try to load the file to insert into the template
    {$IFDEF DIAGMSG}
    JASPrintLn('Try load to load file to insert into template. length(p_saPage):'+inttostr(length(p_saPage))+' length(p_saCustomSection):'+inttostr(length(p_saCustomSection)));
    {$ENDIF}
    If (length(p_saPage)>0) OR (length(p_saCustomSection)>0) Then
    Begin
      If length(p_saCustomSection)=0 Then
      Begin
        //----------------------------------------------------------
        //saFilename:=grJASConfig.saHTMLFiles+p_saPage + csJASFileExt;
        {$IFDEF DIAGMSG}
        JASPrintLn('No Passed custom Section - so try to load from client area first, then default area second.');
        {$ENDIF}
        saFilename:=p_saPage+csJASFileExt;
        If not bFileExists(saFilename) Then
        begin
          saFilename:=p_Context.saRequestedDir + p_saPage + csJASFileExt;
          {$IFDEF DIAGMSG}
            JASPrintLn('1 We are hunting for this file:'+saFilename);
          {$ENDIF}
          If FileExists(saFilename) Then
          Begin
            {$IFDEF DIAGMSG}
              JASPrintLn('1 It Exists! :'+saFilename);
            {$ENDIF}
            saFilename := p_Context.saRequestedDir + p_saPage + csJASFileExt;
          end
          Else
          begin
            saTemp:=saJASLocateTemplate(saFilename+csJASFileExt,p_Context.saLang, p_Context.saColorTheme,p_COntext.sarequestedDir,201012301749,garJVHostLight[p_Context.i4VHost].saTemplateDir);
            if length(trim(saTemp))>0 then
            begin
              saFilename:=saTemp;
            end
            else
            Begin
              // Make FileName Work With Default HTMLFILES directory.
              //----------------------------------------------------
              saFilename:=garJVHostLight[p_Context.i4VHost].saTemplateDir+grJASConfig.saDefaultLanguage+csDOSSLASH+p_saPage + csJASFileExt;
              //JAS_LOG(p_Context, nLog_Warn, 201204142129, 'saGetPage - Unable to find Page file: '+p_saPage+' Filename: '+saFilename +' Caller: '+ inttostr(p_i8Caller),'',SOURCEFILE);

              {$IFDEF DIAGMSG}
                JASPrintLn('It doesn''t exist, let''s try from the default area:'+saFilename);
              {$ENDIF}
              //----------------------------------------------------
              //Log(cnLog_DEBUG,200709272019,'In GETPAGE and this is the TEMPLATE HTML to Load:'+saFilename,sourcefile);
              //AS_Log(p_Context,cnLog_DEBUG,200709272019,'GetPage Ready to load a template file.','In GETPAGE and this is the TEMPLATE HTML to Load:'+saFilename,sourcefile);
            End;
          end;
        end;



        //AS_Log(p_Context,cnLog_DEBUG,200709272018,'GetPage Staged to use a RIP file.','In GETPAGE and PAGE to RIP is file:'+saFilename,sourcefile);
        //----------------------------------------------------------
        //If bLoadfile(saFilename, saLoadedFileData) Then
        //if bLoadFileTS(
        //  saFilename,
        //  saLoadedFileData,
        //  grJASConfig.iRetryLimit,
        //  grJASConfig.iRetryDelayInMSec,
        //  u2IOResult,
        //  bGotFileHandle
        //) then

        {$IFDEF DIAGMSG}
        JASPrintln('1 saGetPage - Page Filename: '+safilename+' Exists: '+saTrueFalse(fileexists(saFilename)));
        {$ENDIF}
        
        bLoadedSectionOk:=false;
        if bTSLoadEntireFile(saFilename, u2IOResult, saLoadedFileData) then
        Begin
          bLoadedSectionOk:=true;
          //ASDebugPrintLn('We got it! :'+saFilename);
          //JAS_Log(p_Context,nLog_DEBUG,200709272020,'DEbug Note - Just loaded a HTMLRipper RIP file. ','In GETPAGE and RIP file just loaded:'+saFilename,sourcefile);
          // OK Got the file to Insert in memory - next - we need
          // the section to RIP from it that utimately becomes part
          // of the resultant web page.
          If length(p_saSection)>0 Then
          Begin
            //AS_Log(p_Context,cnLog_DEBUG,200709272021,'Length of p_saSection > Zero','',sourcefile);
            TK2.bCaseSensitive:=True;//for speed.
            TK2.QuotesXDL.AppendItem_QuotePair(
              '<!--SECTION '+UpCase(p_saSection)+' BEGIN-->',
              '<!--SECTION '+UpCase(p_saSection)+' END-->');
            TK2.Tokenize(saLoadedFileData);
          End;

          If TK2.FoundItem_iQuoteID(1) Then
          Begin
            //AS_Log(p_Context,cnLog_DEBUG,200709272022,'In GETPAGE and WE JUST FOUND the SECTION! Time to send it out','',sourcefile);
            // We got the Section! We Ready for sending it out there
            // BUT WAIT!!!  NEW Thing - Dynamic TITLES!!! (We'll handle in our function in a function called "SendOutTheData"
            //ASPrintLn('We have a <!--SECTION '+UpCase(p_saSection)+' BEGIN--> and matching END ;)');
            SendOutTheData;
          End
          Else
          Begin
            // OK - Kinda like the TO DO below but this is the assumed
            // default the webmaster wants - if no section is specified
            // we will now ASSUME they want the WHOLE file -
            // good bad or indifferent!
            // So - the trick is to manipulate the TK2 JFC_Tokenizer
            // instance into THINKING is has a valid section loaded.
            // Not to much code gets called for this trick - and it
            // allows us to use the SendOutTheData function as is.
            //Log(cnLog_DEBUG,200709272023,'In GETPAGE, No Sections - so spit out the default template',sourcefile);
            //AS_Log(p_COntext,cnLog_DEBUG,200709272023,'In GETPAGE, No Sections - so spit out the default template','',sourcefile);

            //ASPrintLn('There is not a <!--SECTION '+UpCase(p_saSection)+' BEGIN--> and matching END - Sending Whole then :(');
            TK2.AppendItem;
            TK2.Item_saToken:=saLoadedFileData;
            TK2.Item_iQuoteID:=1;
            SendOutTheData;
          End;
        End;
        if bLoadedSectionOk=FALSE then
        Begin
          // UTOH - Could not OPEN the file to insert at all -
          // for one reason or another!! This be bad.
          // what do we do? We Send out the file with the error message
          // of what just happened inside the TEMPLATE where the new data
          // was going to go... but wait - we don't knwo HOW the USER
          // was doing this whole thing - it could comeout TOTALLY SCREWED!
          //-----
          // TODO: make a config option to allow either tossing the error
          // message inside as the missing section we couldn''t load
          // OR (default for now) just show an error page that is self
          // contained.
          //-----

          //---begin original
          // TODO: this is a test having this commented Out.. below these two lines
          //legacy_RenderHTMLErrorPage(p_Context, 200609272023, 'Unable to load HTML SECTION from file: ' +saFilename);
          //bSuccess:=False;
          //---End original

          //--begin test (Note SO Far this is looking like a keeper...
          // but to debug see the "SendOutTheData" "sub-function" above.
          // TODO: Decide to keep or remove
            if(TK1.FoundItem_iQuoteID(1))then
            begin
              TK2.AppendItem;
              TK2.Item_saToken:=TK1.Item_saToken;
              TK2.Item_iQuoteID:=1;
              SendOutTheData;
            end
            else
            begin
              JAS_Log(p_Context,cnLog_Error,200610122306,'Unable to load HTML SECTION from file.','file: ' +saFilename + ' and unable to find insert section from default template file.',SOURCEFILE);
              p_Context.saPage:='ErrorNo       : '+inttostr(p_Context.u8ErrNo)+csCRLF+csCRLF+
                                'Error Message : '+p_Context.saErrMsg+csCRLF+csCRLF;
              p_Context.CGIENV.Header_PlainText(garJVHostLight[p_Context.i4VHost].saServerIdent);
            end;
          //--end   test
        End;
      End
      Else
      Begin
        {$IFDEF DIAGMSG}
          JASPrintLn('saGetPage - We have a custom section - so we are using that as our ripped html ;)');
        {$ENDIF}
        TK2.AppendItem;
        TK2.Item_saToken:=p_saCustomSection;
        TK2.Item_iQuoteID:=1;
        SendOutTheData;
      End;
    End
    Else
    Begin
      // Use Default template provided by end user - no messages
      // "page" to insert not specified - so a good place for
      // the home page content or an error message stating this fact.
      //log(cnLog_DEBUG, 200609272024, 'Calling SendOut the Data. ErrorCondition:'+saTrueFalse(p_Context.bErrorCondition) +
      //' TK.ListCount Going In:' + inttostr(TK.Listcount),sourcefile);
      //JAS_Log(p_Context,cnLog_DEBUG, 200609272024, 'Calling SendOut the Data. ErrorCondition:'+saTrueFalse(p_Context.bErrorCondition) +
      //  ' TK1.ListCount Going In:' + inttostr(TK1.Listcount),'',sourcefile);

      SendOutTheData;
    End;
    TK1.Destroy;
    TK2.Destroy;
    TK3.Destroy;
    //======================================================
  End
  Else 
  Begin
    JAS_Log(p_Context,cnLog_Error,200609272025,'Unable to LOAD HTML template file.','file: ' +saFilename + ' Reason:'+saIOResult(u2IOResult),SOURCEFILE);
    //RenderHtmlErrorPage(p_Context);
    bSuccess:=False;
  End;
  if bSuccess then Result:=saData else Result:=p_Context.saPage;

  {$IFDEF DIAGMSG}
  JASPrintln('saGetPAge-----------------------END (bSuccess:'+saTRueFalse(bSuccess)+')');
  {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102322,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





//=============================================================================
Function saGetPage(
  p_Context:TCONTEXT; 
  p_saArea: AnsiString;
  p_saPage: AnsiString; 
  p_saSection: AnsiString;
  p_bSectionOnly: Boolean;
  p_i8Caller: uint64
): AnsiString;
{$IFDEF ROUTINENAMES}var  sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='Function saGetPage(p_Context:TCONTEXT;p_saArea: AnsiString;p_saPage: AnsiString;p_saSection: AnsiString;'+
    'p_bSectionOnly: Boolean;p_i8Caller: uint64): AnsiString;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102326,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102327, sTHIS_ROUTINE_NAME);{$ENDIF}

  Result:=saGetPage(p_Context,p_saArea, p_saPage, p_saSection, p_bSectionOnly,'',p_i8Caller);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102328,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================







//=============================================================================
Function saHtmlRipper(p_Context:TCONTEXT; p_i8Caller: uint64): AnsiString;
{$IFDEF DIAGMSG}
//Var saDiagnostic: AnsiString;
{$ENDIF}
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='saHtmlRipper(p_Context:TCONTEXT; p_i8Caller: uint64): AnsiString;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102329,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102330, sTHIS_ROUTINE_NAME);{$ENDIF}

  {$IFDEF DIAGMSG}
  JASPRintLn('HTMLRIPPER - BEGIN ---');// -- (WRAPS AROUND saGetPage - applies logic to figure out what to render)');
  JASPRintLn('  ENTRY: p_Context.saHTMLRIPPER_Area: ' +p_Context.saHTMLRIPPER_Area);
  JASPRintLn('  ENTRY: p_Context.saHTMLRIPPER_Page: ' +p_Context.saHTMLRIPPER_Page);
  JASPRintLn('  ENTRY: p_Context.saHTMLRIPPER_Section: ' +p_Context.saHTMLRIPPER_Section);
  JASPrintLn('  ENTRY: upcase(p_Context.saFileSoughtExt):'+upcase(p_Context.saFileSoughtExt));
  {$ENDIF}

  if p_Context.saHTMLRIPPER_Area='' then
  begin
    If p_Context.CGIENV.DATAIN.FoundItem_saName('AREA',False) Then
    Begin
      p_Context.saHTMLRIPPER_Area:=p_Context.CGIENV.DATAIN.Item_saValue;
    End
    else
    begin
      if upcase(p_Context.saFileSoughtExt)='JAS' then
      begin
        p_Context.saHTMLRIPPER_Area:=p_Context.saFileNameOnlyNoExt;
      end
      else
      begin
        p_Context.saHTMLRIPPER_Area:=garJVHostLight[p_Context.i4VHost].saDefaultArea;
      end;
    end;
  end;
  //ASPrintLn('PROCESSED AREA: '+p_Context.saHTMLRIPPER_Area);

  If p_Context.saHTMLRIPPER_Page='' Then
  begin
    If p_Context.CGIENV.DATAIN.FoundItem_saName('PAGE',False) Then
    Begin
      p_Context.saHTMLRIPPER_Page:=p_Context.CGIENV.DATAIN.Item_saValue;
    End
    else
    begin
      p_Context.saHTMLRIPPER_Page:=garJVHostLight[p_Context.i4VHost].saDefaultPage;
    end;
  end;
  //ASPrintLn('PROCESSED PAGE: '+p_Context.saHTMLRIPPER_Page);

  If p_Context.saHTMLRIPPER_Section='' Then
  begin
    If p_Context.CGIENV.DATAIN.FoundItem_saName('SECTION',False) Then
    Begin
      p_Context.saHTMLRIPPER_Section:=p_Context.CGIENV.DATAIN.Item_saValue;
    End
    else
    begin
      p_Context.saHTMLRIPPER_Section:=garJVHostLight[p_Context.i4VHost].saDefaultSection;
    end
  end;
  //ASPrintLn('PROCESSED SECTION: '+p_Context.saHTMLRIPPER_Section);

  {$IFDEF DIAGMSG}
  JASPrintln('api.saHTMLRipper Calling saGetPage(rContext,'''+p_Context.saHTMLRIPPER_Area+''','''+p_Context.saHTMLRIPPER_Page+''','''+p_Context.saHTMLRIPPER_Section+''',false)');
  {$ENDIF}
  Result:=saGetPage(
    p_Context,
    p_Context.saHTMLRIPPER_Area,
    p_Context.saHTMLRIPPER_Page,
    p_Context.saHTMLRIPPER_Section,
    False,
    123020100777
  );
  //AS_LOG(p_Context,cnLog_Debug,201210170945,result,'',SOURCEFILE);

  {$IFDEF DIAGMSG}
  JASPRintLn('HTMLRIPPER - END ---');// -- (WRAPS AROUND saGetPage - applies logic to figure out what to render)');
  {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102331,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================

  
//=============================================================================
Function getfile(p_Context: TCONTEXT; p_saFilename: AnsiString; var p_iHTTPResponse: integer): AnsiString;
//=============================================================================
Var
  saFileData: ansistring;
  u2IOResult: word;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='getfile(p_Context: TCONTEXT; p_saFilename: AnsiString; var p_iHTTPResponse: integer): AnsiString;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201002030008,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102217, sTHIS_ROUTINE_NAME);{$ENDIF}
  result:='';
  if bTSLoadEntireFile(p_saFilename,u2IOResult,saFileData) then
  begin  
    Result := saFileData;
  end
  else
  begin
    p_iHTTPResponse:=cnHTTP_Response_500;
    JAS_Log(p_Context,cnLog_Error,201202222240,
      'Server Response 500 Due to Failed bTSLoadEntireFile return value.',
      'file: ' +p_saFilename + ' Reason:'+saIOResult(u2IOResult),SOURCEFILE
    );
  end;

{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201002030008,'getfile-p_saFilename:'+p_saFilename,SOURCEFILE);{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;  
//=============================================================================





//=============================================================================
{}
// returns Note providing session is valid and JNote_Table_ID points to
// jsecperm and JNote_Row_ID points to the required permission. If null or zero,
// no permission required to get it! So pay attention! LOL ;)
//
// example: ?action=51&decodeuri=yes&uid=100
//
// where UID = [JNote_JNote_UID]
//
// Language is taken into consideration!
//
procedure JAS_NoteSecure(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  bDecodeURI: boolean;
  JNote_JNote_UID: ansistring;
  saResult: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JAS_NoteSecure(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102335,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102336, sTHIS_ROUTINE_NAME);{$ENDIF}

  saResult:='';
  JNote_JNote_UID:=p_Context.CgiEnv.DataIn.Get_saValue('UID');
  bDecodeURI:=bVal(p_Context.CgiEnv.DataIn.Get_saValue('decodeuri'));
  bOk:=i8Val(JNote_JNote_UID)>0;
  if not bOk then
  begin
    JAS_Log(
      p_Context,
      cnLog_Error,
      201101131547,
      'JAS_NoteSecure function - missing valid UID',
      'JNote_JNote_UID: ' +JNote_JNote_UID+
      ' User Name: '+p_Context.rJUser.JUser_Name,
      SOURCEFILE
    );
  end;

  if bOk then
  begin
    bOk:= bJASNoteSecure(p_Context,JNote_JNote_UID,saResult,'');
    if not bOk then
    begin
      //log error
      JAS_Log(
        p_Context,
        cnLog_Error,
        201101131548,
        ' bJASNoteSecure function returned false.',
        'JNote_JNote_UID: ' +JNote_JNote_UID+
        ' User Name: '+p_Context.rJUser.JUser_Name,
        SOURCEFILE
      );
    end;
  end;

  if bok then
  begin
    //do whatever
    if bDecodeURI then
    begin
      p_Context.saPage:=saDecodeURI(saResult);
    end
    else
    begin
      p_Context.saPage:=saResult;
    end;

  end;
  p_Context.CGIENV.iHTTPResponse:=200;
  p_Context.saMimeType:='text/plain';

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102337,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
 end;
//=============================================================================








//=============================================================================
{}
procedure JAS_RenderMindMap(p_Context: TCONTEXT);
//=============================================================================
var
  JNote_JNote_UID: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JAS_RenderMindMap(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102237,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102238, sTHIS_ROUTINE_NAME);{$ENDIF}

  JNote_JNote_UID:=p_Context.CgiEnv.DataIn.Get_saValue('UID');
  p_Context.saPage:=saGetPage(p_Context, '','mindmaps','',true,'',201101132054);
  p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JNote_JNote_UID@]',JNote_JNote_UID);
  p_Context.saMimeType:='text/html';
  p_Context.saPageTitle:=p_Context.CgiEnv.DataIn.Get_saValue('pagetitle');
  p_Context.CGIENV.iHTTPResponse:=200;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102239,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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

