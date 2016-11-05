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
// JAS Context Class
Unit uj_context;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_context.pp'}
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
classes
,syncobjs
,process
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_threadmgr
,ug_jfc_cgienv
,ug_jfc_matrix
,ug_jfc_xml
,ug_tsfileio
,ug_jcrypt
,ug_jado
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
// The CONTEXT class holds the CONTEXT of each thread's state; whether just
// serving in the WebServer mode or running complex custom applications.
// Each Thread has its own instance of this object. It serves as a easy way
// to pass thread based contextual data to singleton functions in a way that 
// makes writing functions to interact with the JAS TWORKER threads defined in
// uxxj_jcore.pp possible.
Type TCONTEXT = class
  u8RequestUID: UInt64;
  lpWorker: pointer;
  bSessionValid: Boolean;   //< This Ok for many operations not requiring login
  bErrorCondition: Boolean; {< True When an Error has occurred. Typically code should allow fall through
                             because the OUTPUT page is rendered as an error HTML page.}
  u8ErrNo: UInt64;           //< most RECENT Error.
  saErrMsg: AnsiString;     //< most recent Error Message
  saErrMsgMoreInfo: ansistring;//< most recent Error Message - additional information if available
  
  sServerIP: string;
  u2ServerPort: word;
  
  sServerIPCGI: string;
  u2ServerPortCGI: word;

  saPage: AnsiString; //< Actual Output Page
  bLoginAttempt: Boolean;
  //saLoginMsg: AnsiString; //< primarily used for replacing [@JEGASLOGINMESSAGE@] 
  PAGESNRXDL: JFC_XDL;
  saPageTitle: AnsiString;{<populated in saGetPage when <!--PAGETITLE "Title Here"--> Encountered. Note that last one wins if multiple apearances.}
  JADOC: array of JADO_CONNECTION;
  {}
  dtRequested: TDATETIME; {< Time thread kicked off }
  dtServed: TDATETIME; {< Time Thread done (captured as soon as possible to 
                        still be accessible by the result page. So there
                        is some processing after this value is sought }
  dtFinished: TDATETIME; // Time sought AFTER page served
  sLang: string;
  {}
  //JMenuDL: JFC_DL; {< Instantiated as JFC_DL.CreateCopy(gJMenuDL) during
  // Thread creation. Not Cleared or Destroyed until thread destructor fired. }
  //=============================================================================
  {}
  bOutputRaw: boolean; {< Output raw is the first thing to set if you know the
   output is not to get a HTML/XHTML response. This allows sending completely
   controlled raw output. (files? :) ) This means you need to create your own
   headers. See the new JFC_CGIENV.saCGIHdrXml function which sends out a default
   HTTP header, for mime type text/xml }
  {}
  //=============================================================================
  {}
  // Converting pages to static - the following variables are SET by
  // the function saHTMLRIPPER The output is basically the
  // SENT web page.
  // Files names of the static templates (just files, you can edit them) are
  // based on AREA, PAGE, SECTION separated by underscores.
  // All Filenames are set to lowercase.
  saHTMLRIPPER_Area, saHTMLRIPPER_Page, saHTMLRIPPER_Section: ansistring;
  u8MenuTopID: Uint64; // Current Root Menu to Draw
  saUserCacheDir: ansistring; //< Ends up being cache + mac_dosslash + U????? +  mac_dosslash
  u8HelpID: uint64;
  
  u2ErrorReportingMode: word;//< Used for Per request Resolve of ErrorReporting and Debug Security Mode
  u2DebugMode: word;//< Used for Per request Resolve of ErrorReporting and Debug Security Mode
  
  // Some Flags used to control code flow
  {}
  bMIME_execute: boolean;//< Executable MIME TYPE - (the word "execute/" is in the mime type name) could be *.exe, php, *.bat etc.
  bMIME_execute_Jegas: Boolean;
  bMIME_execute_JegasWebService: boolean;
  bMIME_execute_php: boolean;
  bMIME_execute_perl: boolean;
  
  sMimeType: string;
  bMimeSNR: boolean;
  saFileSoughtNoExt: ansistring; //< e.g:  f:/somedir/myfile
  sFileSoughtExt: string; //< e.g:                     html
  sFileNameOnly: string; //< e.g:               myfile.html
  sFileNameOnlyNoExt: string;//< e.g:           myfile

  saIN: AnsiString;
  saOut: AnsiString;
  REQVAR_XDL: JFC_XDL;
  uBytesRead: Uint;
  uBytesSent: Uint;
  saRequestedHost: ansistring;
  saRequestedHostRootDir: ansistring; 
  sRequestMethod: String;
  sRequestType: String;
  saRequestURI: ansistring;//< populated in bPArseJASCGI in uj_worker.pp
  saRequestedFile: AnsiString;
  saOriginallyRequestedFile: ansistring;
  saRequestedName: AnsiString;
  saRequestedDir: AnsiString;
  saFileSought: AnsiString;
  saQueryString: AnsiString;
  u2HttpErrorCode: word; //< HTTP Error Code usually 200 for OK
  saLogFile: Ansistring; //< This is for deciding what log file to write out to.s
  bJASCGI: boolean; //< true only if web request is a JASCGI proxy request.
  //=============================================================================
  {}
  // Used for moving dynamic/arbitrary data around
  // iwf data to be placed in the xml document in the action or
  // code block if javascript is being sent to the client via ajax.
  // Note: The XDL double linked list is how we handle abstract
  //       data passing around - and we will likely have functions that
  //       convert that information into saData (ansistring) information
  //       in xml format or javascript. The XDL's allow lists of lists
  //       and are suitable for hierarchial data structures. Double linked 
  //       lists are more flexible but do suffer a speed penalty for 
  //       searching etc. for this the JFC_MATRIX is better suited:
  //       dynamic array + able to hold dynamic table data 
  // Note: the JFC_XML class is a JFC_XDL descendant class.
  XML: JFC_XML;
  CGIENV: JFC_CGIENV;
  sActionType: string;//<iwf specific
  MATRIX: JFC_MATRIX;{< This can be used to arbitrarily place a "TABLE" of data into it so 
                      which ever render mechanism you need it for can render from it. 
                      the Advantage of the JFC_MATRIX is look up speed. }
  LogXXDL: JFC_XXDL;
  rJSession: rtJSession;
  rJUser: rtJUser;
  iSessionResultCode: longint;
  JThread: TJTHREAD;
  SessionXDL: JFC_XDL;
  bSaveSessionData: boolean;
  bInternalJob: boolean;
  JTrakXDL: JFC_XDL;
  JTrak_TableID: uInt64;
  JTrak_JDType_u: word;
  JTRak_sPKeyColName: string;
  JTrak_DBConOffset: UInt64;
  JTrak_Row_ID: uInt64;
  JTrak_bExist: boolean;//< if record Exists at the onset
  JTrak_sTable: string;
  sTheme: string;
  u2VHost: word;//< offset into array of virtual hosts populated at start up or when cycling the server.
  sAlias: string; //< used for Alias that indicates a separate virtual host.
  bMenuHasPAnels: boolean;
  bHavePunkAmongUs: boolean;
  
  constructor create(
    p_sServerSoftware: string;
    p_iTimeZoneOffset: integer;
    p_JThread_Reference: TJTHREAD
  );
  destructor destroy;override;
  procedure reset;
  // used to populate this class with data derived from the passed xml
  function bLoadContextWithXML(p_saXML: ansistring):boolean;
  // used to populate this class with data derived from the passed JFC_XML class
  function bLoadContextWithXML(LXML: JFC_XML): boolean;
  function saXML: ansistring;
  function bRedirection: boolean;
  //=============================================================================
  {}
  // This function returns a REFERENCE to the JADO_CONNECTION with the 
  // name passed. If it fails, it RETURNS NIL! (USE CAUTION)
  // The Main Database connection is always connected if JADO subsystem are 
  // compiled into the codebase. The need for this function arises from the 
  // fact that JAS now manages additional connections dynamically - and hardcoding 
  // the INDEX into the p_Context.JADOC[] array of JADO_CONNECTION class instances 
  // is not very adapatable where using name references allows managing multiple 
  // connections in the database with the same name and only enabling the one you 
  // wish to use with a given name so that recompiling isn't necessary or 
  // complicated management of how the connections are loaded; relying on their 
  // load sequence order.
  //
  // Sample Usage: 
  //
  //@code( procedure SomeProc(p_Context: TCONTEXT);  )@br
  //@code(    var vTigerCon: JADO_CONNECTION;        )@br
  //@code(        RS: JADO_RECORDSET;                )@br
  //@code(        saQry: Ansistring;                 )@br
  //@code(    begin                                  )@br
  //@code(      vTigerCon:=p_Context.DBCon('vtiger');)@br
  //@code(      RS:=JADO_RECORDSET.Create;           )@br
  //@code(      saQry:='select * from test';         )@br
  //@code(      RS.Open(saQry, vTigerCon);           )@br
  function DBCON(p_sConnectionName: string;p_u8Caller: UInt64): JADO_CONNECTION;

  //=============================================================================
  {}
  // This function returns a REFERENCE to the JADO_CONNECTION with the
  // JDCon_JDConnection_UID passed. If it fails, it RETURNS NIL! (USE CAUTION)
  // The Main Database connection is always connected if JADO subsystem are 
  // compiled into the codebase. The need for this function arises from the 
  // fact that JAS now manages additional connections dynamically - and hardcoding 
  // the INDEX into the p_Context.JADOC[] array of JADO_CONNECTION class instances 
  // is not very adapatable where using name references allows managing multiple 
  // connections in the database with the same name and only enabling the one you 
  // wish to use with a given name so that recompiling isn't necessary or 
  // complicated management of how the connections are loaded; relying on their 
  // load sequence order.
  function DBCON(p_JDCon_JDConnection_UID: UINT64;p_u8Caller: UInt64): JADO_CONNECTION;
  // FreePascal Class for creating external processes in the OS
  public
  PROCESS: TPROCESS;

  //=============================================================================
  {}
  // JAS SNR is where SYSTEM Tokens and data pairs prepared by user programs
  // and JAS itself are applied to the payload on its way out the proverbial
  // door.
  procedure JAS_SNR;
  //=============================================================================
  {}
  // JAS_SNR is/was getting stuck in SNR Infinite loop at the moment 20101230,
  // and the "STUCK" factor happens in JFC_XDL.SNR - So because I can't
  // See what's going on in that low-level class - I'm putting the routine here
  // where I can get some feedback and maybe even step through this thing.
  function saJAS_PROCESS_SNR_LIST(p_bCaseSensitive: boolean; p_saPayLoad: ansistring): ANSISTRING;
  //=============================================================================
  {}
  Procedure JTrakBegin(p_Con: JADO_CONNECTION; p_sTable: string; p_u8UID: UInt64);
  //=============================================================================
  {}
  Procedure JTrakEnd(p_u8UID: UInt64; p_saSQL: ansistring);
  //=============================================================================
  {}
  // Renders all sorts of diagnostic information appended to HTML based output
  // to help with development and troubleshooting. DebugMode set to Verbose
  // causes this function to be called automatically.
  procedure DebugHtmlOutput;
  {}
  // This function returns false if it fails. It loads the passed,
  // pre-initialized JFC_XDL with a record's information along with
  // each column's WEIGHT to be used with duplicate identification
  // as well as the DupeScore (Score that when met indicates a duplicate.)
  // The DupeScore comes from the jtable table. The Column Weight Scores
  // come from the jcolumn table.
  // See also the bMerge function located in ug_jegas.pp
  // That function explains the format of the XDL data it requires. This
  // function meets that requirement while reading a data row from the
  // database.
  function bLoadXDLForMerge(
    p_sTable: string;
    p_u8UID: uint64;
    p_XDL: JFC_XDL;
    var p_uDupeScore: cardinal
  ): boolean;
  //=============================================================================
  {}
  // Returns list populated with entire resultset from specified TABLE,
  // column name with desired lookup query in it. Provide  default value
  // so that the WebWidget can render the list appropriately. It will be
  // contructed to be compatible with WebWidget List controls.
  // LookUp Flag indicates whther to use lookup rules or LIST rules which are
  // just a GROUP BY on the specified table.
  function bPopulateLookUpList(
    p_sTableName: string;
    p_sColumnName: string;
    ListXDL: JFC_XDL;
    p_sDefaultValue: string;
    p_bLookUp: boolean
  ):boolean;
  //=============================================================================
  {}
  // Returns Single Value using Lookup rules/Captionrules
  // Specify Table, ColumnName with desired lookup query in it
  // and the UID value.
  function saLookUp(
    p_sTableName: string;
    p_sColumnName: string;
    p_saValue: ansistring
  ): ansistring;
  {}
  // Returns the SQL for the specified lookup and
  // also returns by reference the lookup table's name
  function saLookUpSQL(
    p_sTableName: string;
    p_sColumnName: string;
    var p_sLUTableName: string
  ): ansistring;
  //=============================================================================
  {}
  // Creates IWF friendly XML output for use with jasapi_????? xml functions
  // This function expects a HTTP Result code to be set in
  // p_Context.CGIENV.iHTTPResponse. If the function is called with
  // p_Context.CGIENV.iHTTPResponse equal to zero, it will fail with error code
  // 200912100012.
  //
  // p_Context.saActionType must be set with either "xml" or "javascript". This
  // value are placed into the action tag's "type" property.
  //
  // p_Context.i8ErrCode and p_Context.saErrMsg values are placed into the
  // action tag's "errorCode" and "errorMessage" properties respectively.
  //
  // If the p_Context.saActionType="javascript", then the payload of this
  // function is wrapped in a CDATA xml tage because it is assumed that
  // the payload contains javascript code.
  //
  // If the p_Context.saActionType value is not javascript, then xml is
  // assumed and no CDATA tags are used to wrap the payload.
  //
  // The Payload can be any XML or HTML context that equates to an end result
  // that the output is an acceptable XML output. The Payload is actually
  // sent using the p_Context.DataXDL which is a JEGAS API JFC_XDL class.
  //
  // The values(rows)for each p_Context.DataXDL element (JFC_XDLITEM)
  // are as follows:
  //
  // For JAVASCRIPT: Just load up p_Context.DATAXML with JFC_XDLITEM.saValue
  //                 items containg javascript.
  //
  // sample: p_Context.DATAXML.AppendItem_saValue('alert("hello mom");');
  //
  // For XML and HTML... the same variable is used to supply the payload but
  // it's a little more involved because you can created nested data structures
  // so that full web pages and xml files can be represented is both a simple
  // or advanced fashion. This is done using the p_Context.DataXDL.saXML
  // function (see JFC_XDL.saXML function). This function spits out tags
  // and recurses as well. To Summarize the concept, it works similar to the
  // javascript explained above except all the values in JFC_XDLITEM are
  // output as XML less the JFC_ITEM.lpPtr field. This field is used to
  // attach CHILDNODES to p_Context.DATAXML. So You could make a JFC_XDL
  // object, load it up with data, then do something like:
  //
  // p_Context.DATAXML.AppendItem( MyChildrenXDL );
  // p_Context.DATAXML.Item_saName:='MyChildren';
  //
  // And you'd get a tag named <MyChildren>, and inside it, the contents of
  // MyChildrenXDL would be rendered as xml.
  procedure CreateIWFXML;
  //=============================================================================
  {}
  // Dumps debug information as XDL node data into Context.DataXDL as a new node
  // named JASDEBUDINFO. This allows JASAPIXML functions to return debug
  // information like the HTML stock user interface does when DebugMode is set to
  // verbose or verboselocal is the (jas)config/jas.cfg file.
  procedure DebugXMLOutput;
  //=============================================================================
  {}
  // Returns the HTML that appears between the HEADER tags for the theme
  // specified
  function saJThemeHeader(p_sTheme: string): ansistring;
  //=============================================================================
  {}
  // Looks up the Current language code - based on current user's settings
  // but can be the default if a setting is not found. 
  function sJLanguageLookup(p_u8LangID: UInt64): string;
  //=============================================================================
  {}
  // Function to return the MAIN JADO_CONNECTION for the current VHOST.
  function VHDBC: JADO_CONNECTION;
  //=============================================================================
  {}
  // Return URL of specified VHOST
  function saGetURL(p_u: uint): ansistring;
  {}
  procedure BanPage;
  //=============================================================================
  public
  //=============================================================================
  {}
  // This just holds the list of valid themes in use on the server.
  sIconTheme: string;
  u2LogType_ID: word;
  bNoWebCache: boolean;
  bWhiteListed: boolean;
end;
//=============================================================================









//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log( 
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64; 
  p_saMsg: AnsiString; 
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOC: JADO_CONNECTION;// pass nil if not applicable
  p_JADOR: JADO_RECORDSET// pass nil if not applicable
);
//=============================================================================

//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log( 
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64;
  p_saMsg: AnsiString; 
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOC: JADO_CONNECTION// pass nil if not applicable
);
//=============================================================================

//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log( 
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64;
  p_saMsg: AnsiString; 
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOR: JADO_RECORDSET// pass nil if not applicable
);  
//=============================================================================

//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log( 
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64;
  p_saMsg: AnsiString; 
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring
);  
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
// this appends to ErrorXXDL with information in JADOC added to the info
// being recorded to help debugging things.
Procedure JAS_Log(
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64;
  p_saMsg: AnsiString;
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOC: JADO_CONNECTION;// pass nil if not applicable
  p_JADOR: JADO_RECORDSET// pass nil if not applicable
);
//=============================================================================
var
  saLogMsg: ansistring;
  saLogExtra: ansistring;
  saSeverity: ansistring;
  DT: TDateTime;
  safileName: ansistring;
  sa: ansistring;
  u2IOResult: word;
  f: text;
  DBC: JADO_COnnection;
  saQry: ansistring;
  rs: JADO_RECORDSET;

  
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='Procedure JAS_Log(p_Context: TCONTEXT;p_u2LogType_ID: word;p_u8Msg: UInt64;p_saMsg: AnsiString;p_saMoreInfo: ansistring;p_saSourceFile: ansistring'+
  'p_JADOC: JADO_CONNECTION;p_JADOR: JADO_RECORDSET);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
//  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102252,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102253, sTHIS_ROUTINE_NAME);{$ENDIF}

  DT:=now;
  DBC:= p_COntext.VHDBC;
  saLogMsg:=p_saMsg;
  saLogExtra:='';

  //if length(p_saMoreInfo)>0 then
  //begin
  //  saLogMsg+=' More Info Start: '+p_saMoreInfo+' :More Info end. ';
  //end;

  if garJVHost[p_Context.u2VHost].VHost_LogToDataBase_b and (p_JADOC<>nil)then
  begin
    saLogExtra+='<br /><br /> JAS (JADOC[0]) JADO_CONNECTION INFORMATION: '+
                ' u8DbmsID: ' + inttostr(p_JADOC.u8DbmsID)+
                ' i4Attributes: withheld'+
                ' saConnectionString: withheld'+
                ' sDefaultDatabase: '+p_JADOC.sDefaultDatabase+
                ' Properties: withheld'+
                ' sProvider: '+p_JADOC.sProvider+
                ' i4State: '+inttostr(p_JADOC.i4State)+' '+JADO.sObjectState(p_JADOC.i4State)+
                ' sVersion: '+p_JADOC.sVersion+
                ' u8DriverID: '+inttostr(p_JADOC.u8DriverID)+
                ' sMyUsername: withheld'+
                ' sMyPassword: withheld'+
                ' saMyConnectString: withheld'+
                ' saMyDatabase: '+p_JADOC.saMyDatabase+
                ' saMyServer: '+p_JADOC.saMyServer+
                ' Errors.ListCount: '+inttostr(p_JADOC.Errors.ListCount);
                
    {$IFDEF ODBC}
    saLogExtra+=' ODBCDBHandle: '+inttostr(UINT(p_JADOC.ODBCDBHandle))+
                ' ODBCStmtHandle: '+inttostr(UINT(p_JADOC.ODBCStmtHandle));
    {$ENDIF}

    if(p_JADOC.Errors.ListCount>0) then saLogExtra+='<br /><br />'+p_JADOC.saRenderHTMLErrors;
  end;

  if garJVHost[p_Context.u2VHost].VHost_LogToDataBase_b and (p_JADOC<>nil) then
  begin
    saLogExtra+='<br /><br /> p_JADOC JADO_CONNECTION INFORMATION: '+
                ' u8DbmsID: ' + inttostr(p_JADOC.u8DbmsID)+
                ' i4Attributes: withheld'+
                ' saConnectionString: withheld'+
                ' sDefaultDatabase: '+p_JADOC.sDefaultDatabase+
                ' Properties: withheld'+
                ' sProvider: '+p_JADOC.sProvider+
                ' i4State: '+inttostr(p_JADOC.i4State)+' '+JADO.sObjectState(p_JADOC.i4State)+
                ' sVersion: '+p_JADOC.sVersion+
                ' u8DriverID: '+inttostr(p_JADOC.u8DriverID)+
                ' sMyUsername: withheld'+
                ' sMyPassword: withheld'+
                ' saMyConnectString: withheld'+
                ' saMyDatabase: '+p_JADOC.saMyDatabase+
                ' saMyServer: '+p_JADOC.saMyServer+
                ' Errors.ListCount: '+inttostr(p_JADOC.Errors.ListCount);
    {$IFDEF ODBC}
    saLogExtra+=' ODBCDBHandle: '+inttostr(UINT(DBC.ODBCDBHandle))+
                ' ODBCStmtHandle: '+inttostr(UINT(p_JADOC.ODBCStmtHandle));
    {$ENDIF}
                
    if(p_JADOC.Errors.ListCount>0) then saLogExtra+='<br /><br />'+p_JADOC.saRenderHTMLErrors;
  end;

  if garJVHost[p_Context.u2VHost].VHost_LogToDataBase_b and (p_JADOR<>nil) then
  begin
    saLogExtra+='<br /><br />  p_JADOR JADO_RECORDSET INFORMATION: '+
                ' u8DbmsID:'+inttostr(p_JADOR.u8DbmsID)+
                ' Fields.Count:'+inttostr(p_JADOR.Fields.ListCount)+
                ' ActiveConnection:'+inttostr(UINT(p_JADOR.ActiveConnection))+
                ' i4EditMode:'+inttostr(p_JADOR.i4EditMode)+
                ' EOL:'+sTrueFalse(p_JADOR.EOL)+
                ' i4LockType:'+inttostr(p_JADOR.i4LockType)+
                ' u8MaxRecords:'+inttostr(p_JADOR.u8MaxRecords)+
                ' i4State:'+inttostr(p_JADOR.i4State)+
                ' i4Status:'+inttostr(p_JADOR.i4Status)+
                ' u8DriverID:'+inttostr(p_JADOR.u8DriverID)+
                ' lpMySQLResults:'+inttostR(UINT(p_JADOR.lpMySQLResults))+
                ' lpMySQLPtr:'+inttostR(UINT(p_JADOR.lpMySQLPtr))+
                ' lpMySQLHost:'+inttostR(UINT(p_JADOR.lpMySQLHost))+
                //' lpMySQLUser:'+inttostR(UINT(p_JADOR.lpMySQLUser))+
                //' lpMySQLPasswd:'+inttostR(UINT(p_JADOR.lpMySQLPasswd))+
                ' aRowBuf:'+inttostR(UINT(p_JADOR.aRowBuf))+
                ' u4Columns:'+inttostR(p_JADOR.u4Columns)+
                ' u4Rows:'+inttostR(p_JADOR.u4Rows)+
                ' u4RowsLeft:'+inttostR(p_JADOR.u4RowsLeft)+
                ' u4RowsRead:'+inttostR(p_JADOR.u4RowsRead);
    {$IFDEF ODBC}
    saLogExtra+=' ODBCSQLHSTMT:'+inttostR(UINT(p_JADOR.ODBCSQLHSTMT));
    {$ENDIF}

  end;

  if garJVHost[p_Context.u2VHost].VHost_LogToDataBase_b then
  begin
    if (length(saLogExtra)>0) then
    begin
      saLogExtra:='<br /><br /> Log Extra: '+saLogExtra;
    end;
    saLogMsg+=' '+p_saMoreInfo+' '+saLogExtra;
    //Log(p_u2LogType_ID, p_u8Msg, '201503162240 - JAS_Log: '+saLogMsg, p_saSourceFile);
  end;

  p_Context.LogXXDL.AppendItem_Message(
      p_u8Msg,
      p_saMsg,
      p_saMoreInfo + saLogExtra,
      p_u2LogType_ID,
      p_saSourceFile
  );

  p_Context.u2LogType_ID:=p_u2LogType_ID;
  if (p_u2LogType_ID=cnLog_FATAL) or (p_u2LogType_ID=cnLog_ERROR) then
  begin
    //if p_i8LogNo=i8LogNumberToWatch then JASPrintln('JASLOG 4000');
    //if p_i8LogNo=i8LogNumberToWatch then JASPrintln('JASLOG 5000');
    // Let The Context Record know what's going on - This helps RenderHTMLErrorPage - for example.
    p_Context.u8ErrNo:=p_u8Msg;
    p_Context.saErrMsg:=p_saMsg;
    p_Context.saErrMsgMoreInfo:=p_saMoreInfo + saLogExtra;
    p_Context.bErrorCondition:=true;
  end;
  
  if (p_u2LogType_ID <> cnLog_NONE) and (p_u2LogType_ID<>cnLog_DEBUG)  then
  begin
    if p_u2LogType_ID = cnLog_FATAL then
    begin
      saSeverity:='fatal';
    end else
    if p_u2LogType_ID = cnLog_ERROR then
    begin
      saSeverity:='error';
    end else
    if p_u2LogType_ID = cnLog_WARN then
    begin
      saSeverity:='warning';
    end else
    if p_u2LogType_ID = cnLog_INFO then
    begin
      saSeverity:='notice';
    end else
    if (p_u2LogType_ID>= cnLog_RESERVED) and (p_u2LogType_ID<cnLog_USERDEFINED) then
    begin
      saSeverity:='JEGAS DEFINED';
    end else
    begin
      saSeverity:='USER DEFINED';
    end;
    saFilename:=trim(garJVHost[p_Context.u2VHost].VHost_ErrorLog);
    if saFilename='' then saFilename:=trim(garJVHost[0].VHost_ErrorLog) else
    if saFilename='' then saFilename:='..'+DOSSLASH+'log'+DOSSLASH; //trim(grJASConfig.saDefaultErrorLog);
    if (saFilename<>'') and bTSOpenTextFile(saFilename,u2IOResult,f,false,true) then
    begin
      // [Sun Oct 21 10:50:52 2012] [error] [client 98.144.40.193] File does not exist: /xfiles/inet/gallery/gallery.nepro.org/favicon.ico
      sa:='['+FormatDateTIme('DDD MMM DD HH:NN:SS YYYY',DT)+'] ['+saSeverity+'] [client '+p_Context.rJSession.JSess_IP_ADDR+'] '+
          saSNRStr(saSNRStr(saSNRStr(saLogMsg,csCRLF,' '),#13,' '),#10,' ');
      {$I-}
      writeln(f,sa);
      {$I+}
      bTSCloseTextFile(saFilename, u2IOResult,f);
    end;
  end;
  JLog(p_u2LogType_ID,p_u8Msg,saLogMsg+' MORE INFO: '+p_saMoreInfo,p_saSourceFile);

  if garJVHost[p_Context.u2VHost].VHost_LogToDataBase_b then
  begin
    //asprintln('Attempting to save log entry into the database...');
    rs:=JADO_RECORDSET.CReate;
    saQry:='insert into jlog ( JLOG_JLog_UID,JLOG_Type,JLOG_When_dt,JLOG_IPAddress,JLOG_Message) VALUES ( ';
    saQry+=DBC.sDBMSUIntScrub(sGetUID)+',';
    saQry+=DBC.sDBMSUIntScrub(p_u2LogType_ID)+','+DBC.sDBMSDateScrub(FORMATDATETIME(csDATETIMEFORMAT24, now))+',';
    saQry+=DBC.saDBMSScrub(p_COntext.rJSession.JSess_IP_Addr)+',';
    saQry+=DBC.saDBMSScrub(saLogMsg)+')';
    if not rs.open(saQry,DBC,201605040000) then
    begin
      JLog(cnLog_Warn,201605040001,'Attempt to save the log to the database failed. Qry: '+saQry,p_saSourceFile);
    end;
    rs.close;
    rs.destroy;
  end;

{$IFDEF DEBUGLOGBEGINEND}
//  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102254,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log(
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: UInt64;
  p_saMsg: AnsiString;
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOC: JADO_CONNECTION// pass nil if not applicable
);
//=============================================================================
{$IFDEF ROUTINENAMES} var  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='Procedure JAS_Log(p_Context: TCONTEXT;p_u2LogType_ID: word;p_u8Msg:UInt64;p_saMsg:AnsiString;p_saMoreInfo:ansistring;'+
  'p_saSourceFile: ansistring;p_JADOC: JADO_CONNECTION);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  //DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102255,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102256, sTHIS_ROUTINE_NAME);{$ENDIF}

  JAS_Log(p_Context, p_u2LogType_ID, p_u8Msg, p_saMsg, p_saMoreInfo, p_saSourceFile, p_JADOC, nil);

{$IFDEF DEBUGLOGBEGINEND}
  //DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102257,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log(
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: uInt64;
  p_saMsg: AnsiString;
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring;
  p_JADOR: JADO_RECORDSET// pass nil if not applicable
);
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
sTHIS_ROUTINE_NAME:='JAS_Log(p_Context,p_u2LogType_ID,p_u8Msg,p_saMsg,p_saMoreInfo,p_saSourceFile,p_JADOR);';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  //DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102258,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102259, sTHIS_ROUTINE_NAME);{$ENDIF}

  JAS_Log(p_Context, p_u2LogType_ID, p_u8Msg, p_saMsg, p_saMoreInfo, p_saSourceFile, nil, p_JADOR);


{$IFDEF DEBUGLOGBEGINEND}
  //DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102260,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// this appends to ErrorXXDL with information in TCONTEXT added to the info
// being recorded to help debugging things.
// Unit Test Created - Action 11 - cnAction_Test_JAS_LogThis
Procedure JAS_Log(
  p_Context: TCONTEXT;
  p_u2LogType_ID: word;
  p_u8Msg: uInt64;
  p_saMsg: AnsiString;
  p_saMoreInfo: ansistring;
  p_saSourceFile: ansistring
);
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='JAS_Log(p_Context;p_u2LogType_ID;p_u8Msg;p_saMsg;p_saMoreInfo;p_saSourceFile);';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  //DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102261,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102262, sTHIS_ROUTINE_NAME);{$ENDIF}

  JAS_Log(p_Context, p_u2LogType_ID, p_u8Msg, p_saMsg, p_saMoreInfo, p_saSourceFile, nil, nil);

{$IFDEF DEBUGLOGBEGINEND}
  //DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102263,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================































//=============================================================================
Constructor TCONTEXT.create(
  p_sServerSoftware: string;
  p_iTimeZoneOffset: integer;
  p_JThread_Reference: TJTHREAD
);
//=============================================================================
  var
    i: integer;
    //rs: JADO_RECORDSET;
    //JAS: JADO_CONNECTION;
    //saQry: ansistring;
    bOk: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.create(p_saServerSoftware: ansistring;p_iTimeZoneOffset: integer;p_JThread_Reference: TJTHREAD);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_JThread_Reference.DBIN(201203102224,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_JThread_Reference.TrackThread(201203102225, sTHIS_ROUTINE_NAME);{$ENDIF}
// Note how to use trackthread using this reference:  p_Context.JThread.TrackThread(  ,  '');
  self.u8RequestUID:=0;
  self.JThread:=p_JThread_Reference;
  //ASPrintln('Context.create - Server: '+p_sServerSoftware+' TimeZone:'+inttostr(p_iTimeZoneOffset)+' Thread Ref:'+inttostr(cardinal(p_JThread_Reference)));
  self.CGIENV:=JFC_CGIENV.Create(p_sServerSoftware, p_iTimeZoneOffset);
  self.REQVAR_XDL:=JFC_XDL.Create;
  self.PAGESNRXDL:=JFC_XDL.Create;
  //ASPrintln('Context.create - 10000');
  self.XML:=JFC_XML.Create;
  self.MATRIX:=JFC_MATRIX.create;
  self.LogXXDL:=JFC_XXDL.create;
  saRequestURI:='';
  bNoWebCache:=false;

  //ASPrintln('Context.create - 10010');
  //ASPrintln('length(gaJCon):'+inttostr(length(gaJCon)));
  
  //Log(cnLog_Debug,201007061749,'TCONTEXT.create - length(gaJCon):'+inttostr(length(gaJCon)),sourcefile);
  setlength(self.JADOC, length(gaJCon));

  //ASPrintln('Context.create - 10020');
  for i:=0 to length(gaJCon)-1 do
  begin
    //ASPrintln('Context.create - 10100');
    //Log(cnLog_Debug,201202210359,'TCONTEXT.create - gaJCon['+inttostr(i)+'].ID='+gaJCon[i].ID+' Nil? :'+inttostr(UINT(gaJCon[i])),sourcefile);
    self.JADOC[i]:=JADO_Connection.createcopy(gaJCon[i]);
    //if (i=0) and (JADOC[i].ID=0) then JADOC[i].ID:=1;//the one is the UID for the JDConnection main system record.

    //Log(cnLog_Debug,201007061757,'TCONTEXT.create - self.JADOC['+inttostr(i)+'].ID='+self.JADOC[i].ID+' Nil? :'+inttostr(UINT(self.JADOC[i])),sourcefile);
    //riteln('sleeping');sleep(1000);
    //ASPrintln('Context.create - 10200');
    //riteln('wait for opening it - sleeping');sleep(1000);
    bOk:=self.JADOC[i].OpenCon;//riteln('sleeping');sleep(1000);

    //fudge due to suspected opencon clobber - i recall- might be some logic for it - but we dont need it here.
    if (i=0) and (self.JADOC[0].ID=0) then self.JADOC[0].ID:=1;// possible the clobber id db based - going to make the default tables set to jas main

    //riteln('wait after opening it - sleeping');sleep(1000);
    //ASPrintln('Context.create - 10205');
    if (not bOk) then
    begin
      //ASPrintln('Context.create - 10210');
      JLog(cnLog_WARN,201001151256,'Unable to Open DSN['+inttostr(i)+']',sourcefile);
      writeln;
      writeln('Unable to Open DSN['+inttostr(i)+']');
      if(i=0)then
      begin
        Writeln;
        Writeln('Critical - Unable to Open MAIN JAS Database');
        writeln('ID: (JDConnection_ID)',self.JADOC[i].ID);
        writeln('u8DbmsID:',inttostr(self.JADOC[i].u8DbmsID));
        writeln('saConnectionString:',self.JADOC[i].sConnectionString);
        writeln('sDefaultDatabase:',self.JADOC[i].sDefaultDatabase);
        writeln('Errors.ListCount:',inttostr(self.JADOC[i].Errors.Listcount));
        writeln('sProvider:',self.JADOC[i].sProvider);
        writeln('i4State:',inttostr(self.JADOC[i].i4State));
        writeln('sVersion:',self.JADOC[i].sVersion);
        writeln('u8DriverID:',inttostr(self.JADOC[i].u8DriverID));
        writeln('saMyUsername:',self.JADOC[i].saMyUsername);
        writeln('saMyPassword:',self.JADOC[i].saMyPassword);
        writeln('saMyConnectString:',self.JADOC[i].saMyConnectString);
        writeln('saMyDatabase:',self.JADOC[i].saMyDatabase);
        writeln('saMyServer:',self.JADOC[i].saMyServer);
        //riteln('sUserName:',self.JADOC[i].sUserName);
        //riteln('sPassword:',self.JADOC[i].sPassword);
        writeln('sDriver:',self.JADOC[i].sDriver);
        writeln('saServer:',self.JADOC[i].sServer);
        writeln('saDatabase:',self.JADOC[i].sDatabase);
        HALT(1);
      end;
    end;
  end;

  //if gJMenuDL<>nil then self.JMenuDL:=JFC_DL.CreateCopy(gJMenuDL);
  //ASPrintln('Context.create - 10040');
  SessionXDL:=JFC_XDL.create;
  JTrakXDL:=JFC_XDL.Create;

  //ASPrintln('Context.create - 10050');

  Process:=nil;
  self.Reset;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_JThread_Reference.DBOUT(201203102226,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
Destructor TCONTEXT.Destroy;
//=============================================================================
  var i: integer;

{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME:='TCONTEXT.Destroy;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

{IFDEF DEBUGTHREADBEGINEND}
//JThread.DBIN(201203102227,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}

{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102228, sTHIS_ROUTINE_NAME);{$ENDIF}


{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCONTEXT.Destroy',SourceFile);
{$ENDIF}
  //asprintln('tcontext.destroy - start');
  self.CGIENV.destroy;
  self.REQVAR_XDL.destroy;
  self.PAGESNRXDL.destroy;
  self.XML.Destroy;
  self.MATRIX.Destroy;
  self.LogXXDL.Destroy;
  self.SessionXDL.Destroy;
  JTrakXDL.Destroy;

  //if self.JMenuDL<>nil then
  //begin
  //  self.JMenuDL.Destroy;
  //end;

  for i:=-1 to length(self.JADOC)-1 do
  begin 
    if i>-1 then 
    begin
      if(self.JADOC[i] <> nil)then
      begin
        self.JADOC[i].Destroy;
      end;
    end;
  end;
  setlength(self.JADOC,0);
  JThread:=nil;//<this is a reference - not the maintainer of the object this references.
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

{IFDEF DEBUGTHREADBEGINEND}
  //JThread.DBOUT(201203102227,sTHIS_ROUTINE_NAME,SOURCEFILE);
{ENDIF}
  //asprintln('tcontext.destroy finished');
end;
//=============================================================================



//=============================================================================
Procedure TCONTEXT.Reset;
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.Reset;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102229,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(2012031022230, sTHIS_ROUTINE_NAME);{$ENDIF}


  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092009,'Code Block',SOURCEFILE);{$ENDIF}
  bSessionValid:=False;
  bErrorCondition:=False;
  u8ErrNo:=0;
  u8HelpID:=0;
  saErrMsg:='';
  saErrMsgMoreInfo:='';
  sServerIP:='0.0.0.0';
  u2ServerPort:=0;
  sServerIPCGI:='0.0.0.0';
  u2ServerPortCGI:=0;



  saPage:='';
  bLoginAttempt:=False;
  //saLoginMsg:='';
  PAGESNRXDL.Deleteall; 
  //saPageTitle:='Jegas, LLC';
  saPageTitle:='';
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092010,'Code Block',SOURCEFILE);{$ENDIF}
  

  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092011,'Code Block',SOURCEFILE);{$ENDIF}
  // JADO CONNECTION IS NOT CLEARED because it is instantiated when 
  // the THREADS are first created and stays open until the system is
  // shutdown. This Connection is the main database connector, not 
  // those used by additional connections. Those "extra" connections
  // are to be managed in each thread during the duration of the thread.
  // There is a bit of overhead for this approach but saves having 
  // multiple connections open to various datasources when they are not 
  // in use. The reason we keep them open for the threads - is 
  // responsiveness. By having all the threads in mem - waiting for work,
  // already connected to the database, the system should be more 
  // responsive during normal (meaning not cross database) navigation
  // and operations. JADOC: JADO_CONNECTION;
  //-----------------------
  // JADOC:=nil; NO!!!!!!! this is Done ONCE when the thread is first created!!!!
  //-----------------------
  dtRequested:=0;
  dtServed:=0;// just to put a value in there - it gets overwritten on page serve.
  dtFinished:=0;// just to put a value in there - it gets overwritten when process of send if complete (The more accurate pageserrved - goes in log file).
  sLang:='en'; // Default for system.
  // The same thing applies for JMenuDL as does for JADOC. Furthermore, JMenuDL has
  // specific functions to call to "instantiate and load" bCreateAndLoadJMenuIntoDL it, 
  // as well as a function to "Empty and Destroy" it cleanly (bEmptyAndDestroyJMenuDL).
  //-----------------------
  // JMenuDL:=nil; NO!!!!!!! this is Done ONCE when the thread is first created!!!!
  //-----------------------
  bOutputRaw:=False;
  
  saHTMLRIPPER_Area:='';
  saHTMLRIPPER_Page:='';
  saHTMLRIPPER_Section:='';
  u8MenuTopID:=0;
  saUserCacheDir:='';
  u2ErrorReportingMode:=grJASConfig.u2ErrorReportingMode;//cnSYS_INFO_MODE_SECURE;
  u2DebugMode:=grJASConfig.u2DebugMode;//cnSYS_INFO_MODE_SECURE;
  bMIME_execute:=false;// Executable MIME TYPE - (the word "execute/" is in the mime type name)
                       // could be *.exe, php, *.bat etc.
  bMIME_execute_Jegas:=false;
  bMIME_execute_JegasWebService:=false;
  bMIME_execute_php:=false;
  bMIME_execute_perl:=false;
  sMimeType:=csMIME_AppForceDownload;
  bMimeSNR:=false;
  saFileSoughtNoExt:='';
  sFileSoughtExt:='';
  sFileNameOnly:='';
  sFileNameOnlyNoExt:='';
  saIN:='';// DATA IN :)
  saOut:='';// DATA OUT :)
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092012,'Code Block',SOURCEFILE);{$ENDIF}

  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092013,'Code Block',SOURCEFILE);{$ENDIF}

  REQVAR_XDL.Deleteall; 
  sServerIP:='';
  u2ServerPort:=0;
  sServerIPCGI:='';
  u2ServerPortCGI:=0;
  uBytesRead:=0;
  uBytesSent:=0;
  dtRequested:=0;
  saRequestedHost:='';
  saRequestedHostRootDir:=''; 
  sRequestMethod:='';
  sRequestType:='';
  saRequestedFile:='';
  saOriginallyRequestedFile:='';
  saRequestedName:='';
  saRequestedDir:='';
  saFileSought:='';
  saQueryString:='';
  saLogFile:='';
  bJASCGI:=false;
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092014,'Code Block',SOURCEFILE);{$ENDIF}
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092015,'DataXDL.DeleteAll;',SOURCEFILE);{$ENDIF}
  //DataXDL.DeleteAll;
  XML.DeleteAll;
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092016,'DataXDL.DeleteAll;',SOURCEFILE);{$ENDIF}

  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092017,'CGIENV.Reset;',SOURCEFILE);{$ENDIF}
  CGIENV.Reset;
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092018,'CGIENV.Reset;',SOURCEFILE);{$ENDIF}

  sActionType:='xml';// iwf specific - usually set to xml unless doing tricky
                      // javascript client stuff
  MATRIX.DeleteAll;  
  LogXXDL.DeleteAll;
  iSessionResultCode:=cnSession_MeansErrorOccurred;// just resetting here
  clear_JSession(rJSession);
  rJSession.JSess_JSession_UID:=0;
  rJSession.JSess_IP_ADDR:='0.0.0.0';
  rJSession.JSess_PORT_u:=0;

  clear_JUser(rJUser);
  rJUser.JUser_Name:='Anonymous';
  
  // Do not touch JThread because its set when TCONTEXT created.
  //JThread
  SessionXDL.DeleteAll;
  bSaveSessionData:=false;
  bInternalJob:=false;
  JTrakXDL.DeleteAll;
  JTrak_TableID:=0;
  JTrak_JDType_u:=0;
  JTRak_sPKeyColName:='';
  JTrak_DBConOffset:=0;
                       //JTrak_saUID:='';
  JTrak_Row_ID:=0;
  //JTrak_Col_ID:='';
  JTrak_bExist:=false;
  JTrak_sTable:='';
  if Process<>nil then
  begin
    Process.Destroy;Process:=nil;
  end;

  //sTheme:=garJVHost[self.u2VHost].VHost_DefaultTheme;
  //sIconTheme:=garJVHost[self.u2VHost].VHost_DefaultIconTheme;
  //sTheme:='blue';
  //sIconTheme:='CrystalClear';
  sTheme:='';
  sIconTheme:='';

  u2LogType_ID:=0;
  bNoWebCache:=false;
  u2VHost:=0;
  sAlias:='/';
  bMenuHasPAnels:=false;
  bWhiteListed:=false;
  bHavePunkAmongUs:=false;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================

//=============================================================================
function TCONTEXT.DBCON(p_sConnectionName: STRING;p_u8Caller: UInt64): JADO_CONNECTION;
//=============================================================================
var
  u: uint;
  sUp: string;
  saErr: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.DBCON(p_saConnectionName: ANSISTRING): JADO_CONNECTION;';{$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
//{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102232, sTHIS_ROUTINE_NAME);{$ENDIF}


  result:=nil;
  sUp:=upcase(p_sConnectionName);
  u:=0;
  while(result=nil) and (u<length(JADOC)) do
  begin
    if (sUp=upcase(JADOC[u].sName)) then result:=JADOC[u];
    u+=1;
  end;
  if result = nil then
  begin
    saErr:='201203092111 - DBCON requested not present: '+p_sConnectionName;
    JASPrintln('');
    JASPrintln('Caller:'+inttostr(p_u8caller));
    JASPrintln('***********************************************');
    JASPrintln('');
    JASPRintln(saErr);
    JASPrintln('');
    JASPrintln('***********************************************');
    JASPrintln('');
    jlog(cnLog_FATAL,201007070543,saErr,sourcefile);
  end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102233,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================






//=============================================================================
function TCONTEXT.DBCON(p_JDCon_JDConnection_UID: UINT64;p_u8Caller: UInt64): JADO_CONNECTION;
//=============================================================================
var
  i: integer;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.DBCON(p_JDCon_JDConnection_UID: UINT64;p_u8Caller: UInt64): JADO_CONNECTION;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102234,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102235, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:=nil;
  //if JADOC[0].ID=0 then JADOC[0].ID:=1;

  for i:=0 to length(JADOC)-1 do
  begin
    if p_JDCon_JDConnection_UID=JADOC[i].ID then
    begin
      result:=JADOC[i];
      exit;
    end;
  end;

  if result = nil then
  begin
    JLog(cnLog_Warn,201610312247,'Context.DBCON - Caller: ' +inttostr(p_u8Caller)+' p_JDCon_JDConnection_UID: '+inttostr(p_JDCon_JDConnection_UID)+' JADOC[0].ID:'+inttostr(JADOC[0].ID),SOURCEFILE);
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102236,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



//=============================================================================
function TCONTEXT.bLoadContextWithXML(p_saXML: ansistring):boolean;
//=============================================================================
var
  LXML: JFC_XML;
  bOk: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.bLoadContextWithXML(p_saXML: ansistring):boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102237,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102238, sTHIS_ROUTINE_NAME);{$ENDIF}

  LXML:=JFC_XML.Create;
  bOk:=LXML.bParseXML(p_saXML);  
  if not bOk then
  begin  
    JAS_Log(self,cnLog_ERROR,201004262239,'TCONTEXT.bLoadContextWithXML(p_saXML: ansistring) - Unable to parse XML. LXML.saLastError:'+LXML.saLastError,'',sourcefile);
  end;
  
  if bOk then
  begin
    //ASPrintln('TCONTEXT.bLoadContextWithXML - Parsed Incoming - next actual loadcontext with the xml data');
    //AS_Log(self, cnLog_Debug,201210241556, 'XML in as Text:',p_saXML,SOURCEFILE);
    //AS_Log(self, cnLog_Debug,201210241557, 'LXML.saXML(FALSE,FALSE):',LXML.saXML(false,false),SOURCEFILE);
    bOk:=bLoadContextWithXML(LXML);
  end;
  result:=bOk;
  LXML.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201605271018,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function TCONTEXT.bLoadContextWithXML(LXML: JFC_XML): boolean;
//=============================================================================
var
  bOk: boolean;
  XMLNODE: JFC_XML;
  XMLNODE2: JFC_XML;
  XMLNODE3: JFC_XML;
  XMLNODE4: JFC_XML;
  //XMLNODE5: JFC_XML;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.bLoadContextWithXML(LXML: JFC_XML): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102240,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102241, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintln(LXML.saXML(false,false));

  XMLNODE:=nil;
  XMLNODE2:=nil;
  XMLNODE3:=nil;
  XMLNODE4:=nil;
  //XMLNODE5:=nil;

  //AS_LOG(self, cnLog_Debug, 201209081528,'bLoadContextWithXML - LXML: '+LXML.saXML(false,false),'',SOURCEFILE);

  bOk:=LXML.FoundItem_saName('CONTEXT');
  if bOk then
  begin
    XMLNODE:=JFC_XML(LXML.Item_lpPtr);
    if XMLNODE<>nil then
    begin
      if XMLNODE.FoundItem_saName('saRequestMethod',true) then
      begin
        if length(XMLNODE.Item_saValue)>0 then
        begin
          sRequestMethod:=leftstr(XMLNODE.Item_saValue,255);//precautionary trimming ansi to short string
        end;
      end;

      if XMLNODE.FoundItem_saName('saRequestType',true) then
      begin
        if length(XMLNODE.Item_saValue)>0 then
        begin
          sRequestType:=leftstr(XMLNODE.Item_saValue,255);//precautionary trimming ansi to short string
        end;
      end;

      if XMLNODE.FoundItem_saName('saRequestedFile',true) then
      begin
        if length(XMLNODE.Item_saValue)>0 then
        begin
          saRequestedFile:=XMLNODE.Item_saValue;
        end;
      end;


      if XMLNODE.FoundItem_saName('saQueryString',true) then
      begin
        if length(XMLNODE.Item_saValue)>0 then
        begin
          saQueryString:=XMLNODE.Item_saValue;
          jasprintln('uj_context-loadcontextwithxml-saQueryString:'+saQueryString);
        end;
      end;


      //------------------------------ REQVAR_XDL
      if XMLNODE.FoundItem_saName('REQVAR_XDL',true) then
      begin
        XMLNODE2:=JFC_XML(XMLNODE.Item_lpPtr);
        if XMLNODE2<>nil then
        begin
          if XMLNODE2.MoveFirst then
          begin
            repeat
              if XMLNode2.Item_saName='ITEM' then
              begin
                REQVAR_XDL.AppendItem;
                XMLNODE3:=JFC_XML(XMLNODE2.Item_lpPtr);
                if XMLNODE3<>nil then
                begin
                  if XMLNODE3.FoundItem_saName('lpPtr',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      REQVAR_XDL.Item_lpPtr:=pointer(UINT(u8Val(XMLNODE3.Item_saValue)));
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('UID',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      JFC_XDLITEM(REQVAR_XDL.lpItem).UID:=u8Val(XMLNODE3.Item_saValue);
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('saName',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      REQVAR_XDL.Item_saName:=XMLNODE3.Item_saValue;
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('saValue',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      REQVAR_XDL.Item_saValue:=XMLNODE3.Item_saValue;
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('saDesc',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      REQVAR_XDL.Item_saDesc:=XMLNODE3.Item_saValue;
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('i8User',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      REQVAR_XDL.Item_i8User:=i8Val(XMLNODE3.Item_saValue);
                    end;
                  end;

                  if XMLNODE3.FoundItem_saName('TS',true) then
                  begin
                    if length(XMLNODE3.Item_saValue)>0 then
                    begin
                      JFC_XDLITEM(REQVAR_XDL.lpItem).TS:=StrToTimeStamp(XMLNODE3.Item_saValue);
                    end;
                  end;
                end;
              end;
            until not XMLNODE2.MoveNExt;
          end;
        end;
      end;
      //------------------------------ REQVAR




      //------------------------------ CGIENV
      if XMLNODE.FoundItem_saName('CGIENV',true) then
      begin
        //AS_LOG(self, cnLog_Debug, 201209081526,'bLoadContextWithXML - CGIENV','',SOURCEFILE);
        XMLNODE2:=JFC_XML(XMLNODE.Item_lpPtr);
        //------
        if XMLNODE2<>nil then
        begin
          if XMLNODE2.FoundItem_saName('ENVVAR',true) then
          begin
            XMLNODE3:=JFC_XML(XMLNODE2.Item_lpPtr);
            if XMLNODE3<>nil then
            begin
              if XMLNODE3.MoveFirst then
              begin
                repeat
                  if XMLNode3.Item_saName='ITEM' then
                  begin
                    CGIENV.ENVVAR.AppendItem;
                    XMLNODE4:=JFC_XML(XMLNODE3.Item_lpPtr);
                    if XMLNODE4<>nil then
                    begin
                      if XMLNODE4.FoundItem_saName('lpPtr',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          CGIENV.ENVVAR.Item_lpPtr:=pointer(UINT(u8Val(XMLNODE4.Item_saValue)));
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('UID',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          JFC_XDLITEM(CGIENV.ENVVAR.lpItem).UID:=u8Val(XMLNODE4.Item_saValue);
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('saName',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          CGIENV.ENVVAR.Item_saName:=XMLNODE4.Item_saValue;
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('saValue',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          CGIENV.ENVVAR.Item_saValue:=XMLNODE4.Item_saValue;
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('saDesc',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          CGIENV.ENVVAR.Item_saDesc:=XMLNODE4.Item_saValue;
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('u8User',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          CGIENV.ENVVAR.Item_i8User:=i8Val(XMLNODE4.Item_saValue);
                        end;
                      end;

                      if XMLNODE4.FoundItem_saName('TS',true) then
                      begin
                        if length(XMLNODE4.Item_saValue)>0 then
                        begin
                          JFC_XDLITEM(CGIENV.ENVVAR.lpItem).TS:=StrToTimeStamp(XMLNODE4.Item_saValue);
                        end;
                      end;
                    end;
                  end;
                until not XMLNODE3.MoveNExt;
              end;
            end;
          end;
        end;
        //------

        //------
        if XMLNODE2.FoundItem_saName('DATAIN',true) then
        begin
          XMLNODE3:=JFC_XML(XMLNODE2.Item_lpPtr);
          if XMLNODE3<>nil then
          begin
            if XMLNODE3.MoveFirst then
            begin
              repeat
                if XMLNode3.Item_saName='ITEM' then
                begin
                  CGIENV.DATAIN.AppendItem;
                  XMLNODE4:=JFC_XML(XMLNODE3.Item_lpPtr);
                  if XMLNODE4<>nil then
                  begin
                    if XMLNODE4.FoundItem_saName('lpPtr',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_lpPtr:=pointer(UINT(u8Val(XMLNODE4.Item_saValue)));
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('UID',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        JFC_XDLITEM(CGIENV.DATAIN.lpItem).UID:=u8Val(XMLNODE4.Item_saValue);
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saName',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_saName:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saValue',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_saValue:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saDesc',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_saDesc:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('u8User',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_i8User:=u8Val(XMLNODE4.Item_saValue);
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('TS',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        JFC_XDLITEM(CGIENV.DATAIN.lpItem).TS:=StrToTimeStamp(XMLNODE4.Item_saValue);
                      end;
                    end;
                  end;
                end;
              until not XMLNODE3.MoveNExt;
            end;
          end;
        end;
        //------


        //------
        //if XMLNODE2.FoundItem_saName('CKY IN',true) then
        //begin
        //  XMLNODE3:=JFC_XML(XMLNODE2.Item_lpPtr);
        //  if XMLNODE3<>nil then
        //  begin
        //  if XMLNODE3.MoveFirst then
        //    begin
        //      repeat
        //        if XMLNode3.Item_saName='ITEM' then
        //        begin
        //          CGIENV.CKY IN.AppendItem;
        //          XMLNODE4:=JFC_XML(XMLNODE3.Item_lpPtr);
        //          if XMLNODE4<>nil then
        //          begin
        //            if XMLNODE4.FoundItem_saName('lpPtr',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                CGIENV.CKY IN.Item_lpPtr:=pointer(UINT(u8Val(XMLNODE4.Item_saValue)));
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('UID',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                JFC_XDLITEM(CGIENV.CKY IN.lpItem).UID:=u8Val(XMLNODE4.Item_saValue);
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('saName',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                CGIENV.CKY IN.Item_saName:=XMLNODE4.Item_saValue;
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('saValue',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                CGIENV.CKY IN.Item_saValue:=XMLNODE4.Item_saValue;
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('saDesc',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                CGIENV.CKY IN.Item_saDesc:=XMLNODE4.Item_saValue;
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('u8User',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                CGIENV.CKY IN.Item_i8User:=u8Val(XMLNODE4.Item_saValue);
        //              end;
        //            end;
        //
        //            if XMLNODE4.FoundItem_saName('TS',true) then
        //            begin
        //              if length(XMLNODE4.Item_saValue)>0 then
        //              begin
        //                JFC_XDLITEM(CGIENV.CKY IN.lpItem).TS:=StrToTimeStamp(XMLNODE4.Item_saValue);
        //              end;
        //            end;
        //          end;
        //        end;
        //      until not XMLNODE3.MoveNExt;
        //    end;
        //  end;
        //end;
        //------

        if XMLNODE2.FoundItem_saName('bPost',true) then
        begin
          if length(XMLNODE2.Item_saValue)>0 then
          begin
            CGIENV.bPost:=bVal(XMLNODE2.Item_saValue);
          end;
        end;

        if XMLNODE2.FoundItem_saName('saPostContentType',true) then
        begin
          if length(XMLNODE2.Item_saValue)>0 then
          begin
            CGIENV.saPostContentType:=XMLNODE2.Item_saValue;
          end;
        end;

        if XMLNODE2.FoundItem_saName('iPostContentLength',true) then
        begin
          if length(XMLNODE2.Item_saValue)>0 then
          begin
            CGIENV.uPostContentLength:=iVal(XMLNODE2.Item_saValue);
          end;
        end;

      end;
      //------------------------------ CGIENV
    end;
  end
  else
  begin
    JAS_Log(self, cnLog_ERROR,201004262238,'TCONTEXT.bLoadContextWithXML(LXML: JFC_XML) - Unable to Locate CONTEXT tag in parsed XML','',sourcefile);
  end;
  //ASPrintln('Got to End of bLoadContextWithXML(jfc_xml)');
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102242,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
function TCONTEXT.saXML: ansistring;
//=============================================================================
var
  LXML: JFC_XML;
  XMLNODE: JFC_XML;
  XMLNODE2: JFC_XML;
  XMLNODE3: JFC_XML;
  i: longint;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.saXML: ansistring;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102243,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102244, sTHIS_ROUTINE_NAME);{$ENDIF}

  LXML:=JFC_XML.Create;
  LXML.AppendItem_saName('CONTEXT');
  XMLNODE:=JFC_XML.Create;
  LXML.Item_lpPtr:=XMLNODE;
  XMLNODE.AppendItem_saName_N_saValue('bSessionValid',sYesNo(bSessionValid));
  XMLNODE.AppendItem_saName_N_saValue('bErrorCondition',sYesNo(bErrorCondition));
  XMLNODE.AppendItem_saName_N_saValue('u8ErrNo',inttostr(u8ErrNo));
  XMLNODE.AppendItem_saName_N_saValue('saErrMsg',saErrMsg);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saErrMsgMoreInfo',saErrMsgMoreInfo);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sServerIP',sServerIP);
  XMLNODE.AppendItem_saName_N_saValue('sServerPort',inttostr(u2ServerPort));
  XMLNODE.AppendItem_saName_N_saValue('sServerIPCGI',sServerIPCGI);
  XMLNODE.AppendItem_saName_N_saValue('u8ServerPortCGI',inttostr(u2ServerPortCGI));
  XMLNODE.AppendItem_saName_N_saValue('saPage',saPage);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('bLoginAttempt',sYesNo(bLoginAttempt));
  //XMLNODE.AppendItem_saName_N_saValue('saLoginMsg',saLoginMsg);XMLNODE.Item_bCData:=true;
  
  XMLNODE.AppendItem_saName('PAGESNRXDL');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(PAGESNRXDL.saXML);
  XMLNODE.Item_lpPtr:=XMLNODE2;
  
  XMLNODE.AppendItem_saName_N_saValue('saPageTitle',saPageTitle);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName('JADOC_ARRAY');
  if length(JADOC)>0 then
  begin
    XMLNODE2:=JFC_XML.Create;
    XMLNODE.Item_lpPtr:=XMLNODE2;
    for i:=0 to length(JADOC)-1 do
    begin
      //JASPrintln('i:'+inttostr(i));
      XMLNODE2.AppendItem_saName('JADOC');
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('INDEX',inttostr(i));
      XMLNODE3:=JFC_XML.Create;
      XMLNODE2.Item_lpPtr:=XMLNODE3;
      XMLNODE3.AppendItem_saName_N_saValue('saMyUsername',JADOC[i].saMyUsername);
      XMLNODE3.AppendItem_saName_N_saValue('sMyPassword',JADOC[i].saMyPassword);
      XMLNODE3.AppendItem_saName_N_saValue('saMyDatabase',JADOC[i].saMyDatabase);
      XMLNODE3.AppendItem_saName_N_saValue('saMyServer',JADOC[i].saMyServer);
      XMLNODE3.AppendItem_saName_N_saValue('u4MyPort',inttostr(JADOC[i].u2MyPort));
    end;
  end;

  XMLNODE.AppendItem_saName_N_saValue('dtRequested',FormatDateTime(csDATETIMEFORMAT,dtRequested));
  XMLNODE.AppendItem_saName_N_saValue('dtServed',   FormatDateTime(csDATETIMEFORMAT,dtServed));
  XMLNODE.AppendItem_saName_N_saValue('dtFinished', FormatDateTime(csDATETIMEFORMAT,dtFinished));
  XMLNODE.AppendItem_saName_N_saValue('sLang',sLang);
  {
  If (JMenuDL<>nil) and (JMenuDL.MoveFirst) Then
  begin
    XMLNODE.AppendItem_saName('JMenuDL');
    XMLNODE2:=JFC_XML.Create;
    XMLNODE.Item_lpPtr:=XMLNODE2;
    repeat      
      XMLNODE2.AppendItem_saName('JMenuItem'); 
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('Row',inttostr(JMenuDL.N));       
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_DisplayIfNoAccess_b', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_DisplayIfNoAccess_b);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_IconAltText', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_IconAltText);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_IconAltText_JCaption_ID', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_IconAltText_JCaption_ID);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_JMenu_UID', inttostr(rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_JMenu_UID));
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_JMenuParent_ID', inttostr(rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_JMenuParent_ID));

      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_JNote_ID', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_JNote_ID);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_JSecPerm_ID', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_JSecPerm_ID);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_Name', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_Name);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_NewWindow_b', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_NewWindow_b);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_SEQ', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_SEQ);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_URL', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_URL);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_ValidSessionOnly_b', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_ValidSessionOnly_b);
      JFC_XMLITEM(XMLNODE2.lpItem).AttrXDL.AppendItem_saName_N_saValue('JMenu_DisplayIfValidSession_b', rtJMenu(JFC_DLITEM(JMenuDL.lpItem).lpPtr^).JMenu_DisplayIfValidSession_b);
    Until not JMenuDL.MoveNext;
  end;
  }
  XMLNODE.AppendItem_saName_N_saValue('bOutputRaw',sYesNo(bOutputRaw));
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Area',saHTMLRIPPER_Area);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Page',saHTMLRIPPER_Page);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Section',saHTMLRIPPER_Section);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('u8MenuTopID',inttostr(u8MenuTopID));
  XMLNODE.AppendItem_saName_N_saValue('iSessionResultCode',inttostr(iSessionResultCode));

  XMLNODE.AppendItem_saName_N_saValue('saUserCacheDir',saUserCacheDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('u2ErrorReportingMode',inttostr(u2ErrorReportingMode));
  XMLNODE.AppendItem_saName_N_saValue('u2DebugMode',inttostr(u2DebugMode));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute',sYesNo(bMIME_execute));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_Jegas',sYesNo(bMIME_execute_Jegas));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_JegasWebService',sYesNo(bMIME_execute_JegasWebService));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_php',sYesNo(bMIME_execute_php));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_perl',sYesNo(bMIME_execute_perl));
  XMLNODE.AppendItem_saName_N_saValue('sMimeType',sMimeType);
  XMLNODE.AppendItem_saName_N_saValue('bMimeSNR',sYesNo(bMimeSNR));
  XMLNODE.AppendItem_saName_N_saValue('saFileSoughtNoExt',saFileSoughtNoExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sFileSoughtExt',sFileSoughtExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sFileNameOnly',sFileNameOnly);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sFileNameOnlyNoExt',sFileNameOnlyNoExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saIN',saIN);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saOUT',saOUT);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName('REQVAR_XDL');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(REQVAR_XDL.saXML);
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE.AppendItem_saName_N_saValue('uBytesRead',inttostr(uBytesRead));
  XMLNODE.AppendItem_saName_N_saValue('uBytesSent',inttostr(uBytesSent));
  XMLNODE.AppendItem_saName_N_saValue('saRequestedHost',saRequestedHost);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedHostRootDir',saRequestedHostRootDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sRequestMethod',sRequestMethod);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('sRequestType',sRequestType);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedFile',saRequestedFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saOriginallyRequestedFile',saOriginallyREquestedFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedName',saRequestedName);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedDir',saRequestedDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saFileSought',saFileSought);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saQueryString',saQueryString);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('u2HttpErrorCode',inttostr(u2HttpErrorCode));
  XMLNODE.AppendItem_saName_N_saValue('saLogFile',saLogFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('bJASCGI',sYesNo(bJASCGI));
  XMLNODE.AppendItem_saName('XML');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(XML.saXML(false,false));
  XMLNODE.Item_lpPtr:=XMLNODE2;
  
  XMLNODE.AppendItem_saName('CGIENV');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE.Item_lpPtr:=XMLNODE2;
  
  XMLNODE2.AppendItem_saName('ENVVAR');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.ENVVAR.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('DATAIN');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.DATAIN.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  //XMLNODE2.AppendItem_saName('CKY IN');
  //XMLNODE3:=JFC_XML.Create;
  //XMLNODE3.bParseXML(CGIENV.CKY IN.saXML);
  //XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  //XMLNODE2.AppendItem_saName('CKY OUT');
  //XMLNODE3:=JFC_XML.Create;
  //XMLNODE3.bParseXML(CGIENV.CKY OUT.saXML);
  //XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('HEADER');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.HEADER.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('FILESIN');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.FILESIN.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName_N_saValue('bPost',sYesNo(CGIENV.bPost));
  XMLNODE2.AppendItem_saName_N_saValue('saPostContentType',CGIENV.saPostContentType);XMLNODE2.Item_bCData:=true;
  XMLNODE2.AppendItem_saName_N_saValue('uPostContentLength',inttostr(CGIENV.uPostContentLength));
  XMLNODE2.AppendItem_saName_N_saValue('iTimeZoneOffset',inttostr(CGIENV.iTimeZoneOffset));
  XMLNODE2.AppendItem_saName_N_saValue('uHTTPResponse',inttostr(CGIENV.uHTTPResponse));
  XMLNODE2.AppendItem_saName_N_saValue('saServerSoftware',CGIENV.saServerSoftware);XMLNODE2.Item_bCData:=true;

  XMLNODE.AppendItem_saName_N_saValue('sActionType',sActionType);

  XMLNODE.AppendItem_saName('MATRIX');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(MATRIX.saXML);
  XMLNODE.Item_lpPtr:=XMLNODE2;

  XMLNODE.AppendItem_saName('LogXXDL');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(LogXXDL.saXML);
  XMLNODE.Item_lpPtr:=XMLNODE2;

  XMLNODE.AppendItem_saName('rJSession');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JSession_UID',inttostr(rJSession.JSess_JSession_UID));
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JSessionType_ID',inttostr(rJSession.JSess_JSessionType_ID));
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JUser_ID',inttostr(rJSession.JSess_JUser_ID));
  XMLNODE2.AppendItem_saName_N_saValue('JSess_Connect_DT',rJSession.JSess_Connect_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_LastContact_DT',rJSession.JSess_LastContact_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_IP_ADDR',rJSession.JSess_IP_ADDR);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_PORT_u',inttostr(rJSession.JSess_PORT_u));
  XMLNODE2.AppendItem_saName_N_saValue('JSess_Username',rJSession.JSess_Username);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JJobQ_ID',inttostr(rJSession.JSess_JJobQ_ID));

  XMLNODE.AppendItem_saName('rJUser');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE2.AppendItem_saName_N_saValue('JUser_JUser_UID',inttostr(rJUser.JUser_JUser_UID));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Name',rJUser.JUser_Name);
  //XMLNODE2.AppendItem_saName_N_saValue('JUser_Password',rJUser.JUser_Password);
  XMLNODE2.AppendItem_saName_N_saValue('JUser_JPerson_ID',inttostR(rJUser.JUser_JPerson_ID));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Enabled_b',sTrueFalsE(rJUser.JUser_Enabled_b));
  if garJVHost[u2VHost].VHost_ServerDomain='default' then
  begin
    XMLNODE2.AppendItem_saName_N_saValue('JUser_Admin_b',strueFalse(rJUser.JUser_Admin_b));
  end;
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Login_First_DT',rJUser.JUser_Login_First_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Login_Last_DT',rJUser.JUser_Login_Last_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Logins_Successful_u',inttostr(rJUser.JUser_Logins_Successful_u));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Logins_Failed_u',inttostr(rJUser.JUser_Logins_Failed_u));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Password_Changed_DT',rJUser.JUser_Password_Changed_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JUser_AllowedSessions_u',inttostr(rJUser.JUser_AllowedSessions_u));
  XMLNODE.AppendItem_saName_N_saValue('JThread',inttostr(UINT(JThread)));
  XMLNODE.AppendItem_saName('SessionXDL');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE2.bParseXML(SessionXDL.saXML);
  XMLNODE.AppendItem_saName_N_saValue('bSaveSessionData',sYesNo(bSaveSessionData));
  XMLNODE.AppendItem_saName_N_saValue('bInternalJob',sYesNo(bInternalJob));
  XMLNODE.AppendItem_saName_N_saValue('bMenuHasPanels',sYesNo(bMenuHasPanels));

  result:=LXML.saXML(false,false);
  LXML.Destroy;

//todo: add 'saTheme' to this output maybe
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102245,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
procedure TCONTEXT.JAS_SNR;
//=============================================================================
var 
  bPerformSNR: boolean;
  RS: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  iJSecKey: integer;
  saPubKey:ansistring;
  bKey1: boolean;
  bKey2: boolean;
  bKey3: boolean;
  bKeyGood: boolean;
  u8TempOutLen: uint64;
  i: longint;
  u8Zero: uint64;
  sLocalIconTheme: string;
  sLocalTheme: string;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.JAS_SNR;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102246,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102247, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=VHDBC;
  RS:=Nil;

  iJSecKey:=0;
  u8Zero:=0;
  bPerformSNR:=false;
  //ASPrintln('In TCONTEXT.JAS_SNR');
  //ASPrintln('MIME: '+saMimeType+' SNR Flag: '+sTrueFalse(bPerformSNR));
  u8TempOutLen:=length(saOut);
  if (u8TempOutLen>u8Zero) then
  begin
    //ASPrintln('In TCONTEXT.JAS_SNR: got good length');
    //if CGIENV.HEADER.FoundItem_saName(csINET_HDR_CONTENT_TYPE,true) then
    //begin
    //  saMimeType:=CGIENV.HEADER.Item_saValue;
    //end;
    //if sMimeType<>'application/force-download' then
    begin
      //ASPrintln('In TCONTEXT.JAS_SNR: In Server Mode. Hunting for mime type:'+saMimeType);
      bPerformSNR:=false;
      if length(garJMimeLight)>0 then
      begin
        for i:=0 to length(garJMimeLight)-1 do
        begin
          //ASPrintln('JAS_SNR - garJMimeLight[i].saType: '+garJMimeLight[i].saType+' MimeType: '+saMimeType);
          if garJMimeLight[i].sType=sMimeType then
          begin
            //ASPrintln('JAS_SNR - Found Mime garJMimeLight[i].bSNR: '+sTrueFalse(garJMimeLight[i].bSNR));
            bPerformSNR:=garJMimeLight[i].bSNR;
            break;
          end;
        end;
      end;

      if bPerformSNR then
      begin
        //ASPrintln('Preforming SNR - PageSNRXDL.ListCount :' +inttostR(PageSNRXDL.ListCount));
        PAGESNRXDL.AppendItem_SNRPair('[@LANG@]', sLang);
        PAGESNRXDL.AppendItem_SNRPair('[@HELPID@]', inttostr(u8HelpID));
        PAGESNRXDL.AppendItem_SNRPair('[@ERRORCONDITION@]',sTrueFalse(bErrorCondition));//TODO: Make context sensitive, no reason to have this place holder all the time
        PAGESNRXDL.AppendItem_SNRPair('[@ERRORNUMBER@]',inttostr(u8ErrNo));//TODO: Make context sensitive, no reason to have this place holder all the time
        PAGESNRXDL.AppendItem_SNRPair('[@USERID@]',inttostR(rJUser.JUser_JUser_UID));
        PAGESNRXDL.AppendItem_SNRPair('[@USERNAME@]',rJUser.JUser_Name);
        PAGESNRXDL.AppendItem_SNRPair('[@REMOTEIP@]',rJSession.JSess_IP_ADDR);
        PAGESNRXDL.AppendItem_SNRPair('[@JSID@]',inttostr(rJSession.JSess_JSession_UID));
        PAGESNRXDL.AppendItem_SNRPair('[@SESSIONVALID@]',sYesNo(bSessionValid));
        //---menu global nav
        PAGESNRXDL.AppendItem_SNRPair('[@SERVERNAME@]',garJVHost[u2VHost].VHost_ServerName);
        PAGESNRXDL.AppendItem_SNRPair('[@JASID@]',garJVHost[u2VHost].VHost_ServerIdent);
        saPageTitle:=PAGESNRXDL.SNR(saPageTitle,True);
        if(length(trim(saPageTitle))>0) then
        begin
          PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]',saPageTitle);
        end
        else
        begin
          PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]','');// seems redundant now - but gonna put stuff here
        end;
        PAGESNRXDL.AppendItem_SNRPair('[@JASSIG@]',gsaJasFooter);
        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $JASDIRWEBSHARE; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias));
        PAGESNRXDL.AppendItem_SNRPAIR('[@JASDIRWEBSHARE@]',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias));
        // ---- punk-be-gone related
        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $PUNKSBANNED; ?>',sDelimitUInt(grPunkBeGoneStats.uBanned));
        PAGESNRXDL.AppendItem_SNRPAIR('[@PUNKSBANNED@]',sDelimitUInt(grPunkBeGoneStats.uBanned));

        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $PUNKSBANNEDSINCESTART; ?>',sDelimitUInt(grPunkBeGoneStats.uBannedSinceServerStart));
        PAGESNRXDL.AppendItem_SNRPAIR('[@PUNKSBANNEDSINCESTART@]',sDelimitUInt(grPunkBeGoneStats.uBannedSinceServerStart));

        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $PUNKSBLKSINCESTART; ?>',sDelimitUInt(grPunkBeGoneStats.uBlockedSinceServerStart));
        PAGESNRXDL.AppendItem_SNRPAIR('[@PUNKSBLKSINCESTART@]',sDelimitUInt(grPunkBeGoneStats.uBlockedSinceServerStart));

        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $JASSERVERSTART; ?>',FORMATDATETIME(csDATETIMEFORMAT, grPunkBeGoneStats.dtServerStarted));
        PAGESNRXDL.AppendItem_SNRPAIR('[@JASSERVERSTART@]',FORMATDATETIME(csDATETIMEFORMAT, grPunkBeGoneStats.dtServerStarted));
        // ---- punk-be-gone related
        PAGESNRXDL.Appenditem_saName_N_saValue('[@SERVERURL@]',garJVHost[self.u2VHost].VHost_ServerURL);
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRLOGO; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/logo/');
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRIMG@]',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/');
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRIMG; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/');
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRTHEME@]',garJVHost[self.u2VHost].VHost_JASDirTheme);
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRTHEME; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_JASDirTheme));
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRICON@]',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/icon/');
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRICON; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/icon/');
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRLOGO@]',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/logo/');
        PAGESNRXDL.AppendItem_SNRPAIR('[@NOW@]',JDATE('',11,0,dtRequested));

        //----background and no-repeat thing for css
        if (uVal(CGIENV.DataIn.Get_saValue('JSID'))=0) then
        begin
          // Get the VHOST Settings for background and repeat
          PAGESNRXDL.AppendItem_SNRPAIR('[@BACKGROUND@]',garJVHost[u2VHost].VHost_Background);
          //riteln('JAS_SNR - Session not valid - using vhost background: '+garJVHost[u2VHost].VHost_Background);
          if garJVHost[u2VHost].VHost_BackgroundRepeat_b then
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('/*[@BACKGROUNDREPEAT@]*/','');
          end
          else
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('/*[@BACKGROUNDREPEAT@]*/','background-repeat: no-repeat;  background-size: cover;');
          end;
        end
        else
        begin
          if (rJUser.JUser_JUser_UID=0)then // non-zero=presume juser loaded already
          begin
            rs:=JADO_RecordSet.Create;
            if rs.open('select JSess_JUser_ID from jsession where JSess_JSession_UID='+DBC.sDBMSUintScrub(CGIENV.DataIn.Get_saValue('JSID')),DBC,201510301416) and (not rs.eol) then
            begin
              rJUser.JUser_Background:=dbc.saGetValue('juser','JUser_Background','JUser_JUser_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JSess_JUser_ID')),201610301427);
              rJUser.JUser_BackgroundRepeat_b:=bVal(dbc.saGetValue('juser','JUser_BackgroundRepeat_b','JUser_JUser_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JSess_JUser_ID')),201610301427));
            end;
            rs.close;rs.destroy;rs:=nil;
          end;
          if length(trim(rJUser.JUser_Background))>0 then
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('[@BACKGROUND@]',rJUser.JUser_Background);
          end
          else
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('[@BACKGROUND@]','');
          end;
          if rJUser.JUser_BackgroundRepeat_b then
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('/*[@BACKGROUNDREPEAT@]*/','');
          end
          else
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('/*[@BACKGROUNDREPEAT@]*/','background-repeat: no-repeat;  background-size: cover;');
          end;
        end;







        //--JAS THEME HEADER
        sLocalIconTheme:=sIconTheme;//get default from tcontext
        sLocalTheme:=sTheme;//get default from tcontext
        if bSessionValid then
        begin
          if rJUser.JUser_Headers_b then
          begin
            PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]',sadecodeURI(saJThemeHeader(sTheme)));
          end
          else
          begin
            PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]','');
          end;

          if (rJUser.JUser_IconTheme<>'') then
          begin
            sLocalIconTheme:=rJUser.JUser_IconTheme;
          end;
          PAGESNRXDL.AppendItem_SNRPAir('[@JASICONTHEME@]',sLocalIconTheme);
          PAGESNRXDL.AppendItem_SNRPAir('[@JASQUICKLINKS@]',sYesNo(rJUser.JUser_QuickLinks_b));
        end
        else
        begin
          if garJVHost[u2VHost].VHost_Headers_b then
          begin
            PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]',sadecodeURI(saJThemeHeader(sTheme)));
          end
          else
          begin
            PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]','');
          end;
          PAGESNRXDL.AppendItem_SNRPAir('[@JASICONTHEME@]',sLocalIconTheme);
          PAGESNRXDL.AppendItem_SNRPAir('[@JASQUICKLINKS@]',sYesNo(garJVHost[u2VHost].VHost_QuickLinks_b));
        end;

        PAGESNRXDL.AppendItem_SNRPair('[@JASTHEME@]',sLocalTheme);// e.g.: stock
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASTHEME; ?>',sLocalTheme);

        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRICONTHEME@]',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/icon/themes/'+sLocalIconTheme+'/');
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRICONTHEME; ?>',saAddFwdSlash(garJVHost[self.u2VHost].VHost_WebShareAlias)+'img/icon/themes/'+sLocalIconTheme+'/');

        PAGESNRXDL.AppendItem_SNRPair('[@JASTHEME@]',sLocalTheme);// e.g.: stock
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASTHEME; ?>',sLocalTheme);


        PAGESNRXDL.AppendItem_SNRPAIR('[@ALIAS@]',sAlias);
        PAGESNRXDL.AppendItem_SNRPAIR('[@PUNKBEGONEENABLED@]',sTrueFalse(grJASConfig.bPunkBeGoneEnabled));

        // BEGIN --------------- SPECIAL SCENARIO - FOR JSKey_JSecKey_UID and JSKey_KeyPub
        // This one requires a DB lookup. SO... We want to avoid it 99%. How do we figure this bit out?
        // quick POS check for [@JSECKEY@] AND [@JPUBKEY@]
        // IF BOTH EXIST then we "Bother" to do the deed. Deed is get a random #1 - 1024
        // and then we use that number to look up the public key from the jseckey table.
        bKeyGood:=false;
        bKey1:=(pos('[@JSECKEY@]',saOut)>0);
        bKey2:=(pos('[@JPUBKEY@]',saOut)>0);
        bKey3:=(pos('[@JCRYPTMIX@]',saOut)>0);
        if bKey1 or bKey2 or bKey3 then
        begin
          if bKey1 and bKey2 then
          begin
            iJSecKey:=random(1024)+1;
            //iJSecKey:=654;
            DBC:=VHDBC;
            RS:=JADO_RECORDSET.Create;
            saQry:='select JSKey_KeyPub from jseckey '+
              'where JSKey_JSecKey_UID='+inttostR(iJSecKey) + ' and ' +
              'JSKey_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
            if rs.open(saQry, DBC,201503161709) then
            begin
              if not rs.eol then
              begin
                bKeyGood:=true;
                saPubKey:=rs.fields.get_saValue('JSKey_KeyPub');
                PAGESNRXDL.AppendItem_SNRPAIR('[@JSECKEY@]',inttostR(iJSecKey));
                PAGESNRXDL.AppendItem_SNRPAIR('[@JPUBKEY@]',saPubKey);
                PAGESNRXDL.AppendItem_SNRPAIR('[@JCRYPTMIX@]',saJCryptMix);
              end;
            end
            else
            begin
            end;
            RS.Destroy;RS:=Nil;
          end;
          if not bKeyGood then
          begin
            PAGESNRXDL.AppendItem_SNRPAIR('[@JSECKEY@]','0');
            PAGESNRXDL.AppendItem_SNRPAIR('[@JPUBKEY@]','ERROR');
            PAGESNRXDL.AppendItem_SNRPAIR('[@JCRYPTMIX@]','ERROR');
          end;
        end;
        // END --------------- SPECIAL SCENARIO - FOR JSKey_JSecKey_UID and JSKey_KeyPub


        {$IFDEF DIAGNOSTIC_WEB_MSG}
        if gbServerMode then
        begin
          JASPrintln('SEARCH-N-REPLACE PageSNR Items:'+inttostr(PAGESNRXDL.Listcount));
          JASPrintln('SEARCH-N-REPLACE BLOCK---------------------------------------END');
        end;
        {$ENDIF}
     

        dtServed:=now;//as close as I can get to end without losing ability to display time it took to serve
        PAGESNRXDL.AppendItem_SNRPAIR('[@PTMILLI@]',inttostr(iDiffMSec(dtRequested, dtserved)));



        // Note that the S-N-R Happens twice for completeness. There is logic to prevent infinate loops
        // in the SNR - so those items get skipped - by two passes - it seems to handle those
        // anomalies so far.
        {$IFDEF DIAGNOSTIC_WEB_MSG}
        JASPrintLn('JAS_SNR - SNR PASS 1 of 2: '+saFileSought);
        PAGESNRXDL.SortItem_saName(true,true);
        if PAGESNRXDL.MoveFirst then
        begin
          repeat
            writeln('SNR TOKENS: '+ PAGESNRXDL.Item_saName);
          until not pagesnrxdl.movenext;
        end;
        {$ENDIF}
        saOut:=saJAS_PROCESS_SNR_LIST(true, saOut);
        saOut:=saJAS_PROCESS_SNR_LIST(true, saOut);
      end;
    end;
  end;

  //if bPerformSNR then
  //begin
  //  ASPrintln('PERFORMED SNR. Mime Type: '+saMimeType+' '+saOriginallyRequestedFile);
  //end
  //else
  //begin
  //  ASPrintln('DO NOT PERFORM SNR. Mime Type: '+saMimeType+' '+saOriginallyRequestedFile);
  //end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102248,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TCONTEXT.saJAS_PROCESS_SNR_LIST(p_bCaseSensitive: boolean; p_saPayLoad: ansistring): ANSISTRING;
//=============================================================================
//---paste begin
Var
  i8: int64;
  sa: AnsiString;
  saUp: AnsiString;
  bSkip: Boolean;
  u8TempPayloadLen: uint64;
  //u8TempItemNameLen: uint64;
  //u8TempItemValueLen: uint64;
  //XDLCOPY: JFC_XDL;
  i8Last: int64;
  i8MainLoopIterations: uint64;
  //i8RegressIterations: uint64;
  u8Zero: uint64;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.saJAS_PROCESS_SNR_LIST(p_bCaseSensitive: boolean; p_saPayLoad: ansistring): ANSISTRING;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102249,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102250, sTHIS_ROUTINE_NAME);{$ENDIF}

  u8Zero:=0;
  u8TempPayloadLen:=length(p_saPayLoad);
  sa:=p_saPayLoad;//Cuz we chopping it and its a pointer... we do not
  // want to hack our original in this case.

  //XDLCOPY:=JFC_XDL.CreateCopy(self);
  //If (length(p_sa)>0) and (iItems>0) Then
  If (u8TempPayloadLen>u8Zero) and (PAGESNRXDL.MoveFirst) Then
  Begin
    //riteln('Got In ...');
    //MoveFirst;
    i8MainLoopIterations:=0;
    repeat
      If not p_bCaseSensitive Then saUp:=UpCase(sa);
      i8Last:=0;
      //i8RegressIterations:=0;
      repeat
        If (not p_bCaseSensitive) then
        Begin
          i8:=pos(upcase(JFC_XDLITEM(PAGESNRXDL.lpItem).saName),saUp);
          //bSkip:=copy(saUp,i8,length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName))=Upcase(JFC_XDLITEM(PAGESNRXDL.lpItem).saValue);//ORIGINAL
          bSkip:=0<(
            pos(
              copy(saUp,i8,length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName)),
              Upcase(JFC_XDLITEM(PAGESNRXDL.lpItem).saValue)
            )
          );
        End
        Else
        Begin
          i8:=pos(JFC_XDLITEM(PAGESNRXDL.lpItem).saName,sa);
          //bSkip:=copy(sa,i8,length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName))=JFC_XDLITEM(PAGESNRXDL.lpItem).saValue;//ORIGINAL
          bSkip:=0<(
            pos(
              copy(sa,i8,length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName)),
              JFC_XDLITEM(PAGESNRXDL.lpItem).saValue
            )
          );
        End;

        if i8Last>0 then
        begin
          if(i8Last=i8) then
          begin
            bSkip:=true;
          end;
        end;
        i8Last:=i8;

        if (i8>0) then
        begin
          //riteln(ItemName,'<>',sa,'<>',i);
          If (not bSkip) Then
          Begin
            DeleteString(sa, i8, length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName));
            //riteln('after delete sa:',sa);
            Insert(JFC_XDLITEM(PAGESNRXDL.lpItem).saValue,sa, i8);
            //riteln('after insert sa:',sa);
            If not p_bCaseSensitive Then
            Begin
              DeleteString(saUp, i8, length(JFC_XDLITEM(PAGESNRXDL.lpItem).saName));
              Insert(upcase(JFC_XDLITEM(PAGESNRXDL.lpItem).saValue),saUp, i8);
            End;
          End;
        end;

      Until bSkip or (i8<1);
      i8MainLoopIterations+=1;
    Until not PAGESNRXDL.MoveNext;

  End;
  {else
  Begin
    Writeln('SNR prob...Length p_sa:',length(p_Sa));
    Writeln('iItems:',iItems);
  End;}
  //Writeln('returning>',sa);
  //Writeln('returned length:',length(sa));
  //XDLCOPY.Destroy;
  Result:=sa;
//---paste end

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102251,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
{}
Procedure TCONTEXT.JTrakBegin(p_COn: JADO_COnnECTION; p_sTable: string; p_u8UID: UInt64);
//=============================================================================
Var
  bOk: boolean;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  u: byte;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.JTrakBegin(p_DBCon: JADO_CONNECTION; p_saTable: ansistring; p_u8UID: Uint64);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203252228,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203252228, sTHIS_ROUTINE_NAME);{$ENDIF}
  if rJUser.JUser_Audit_b then
  begin
    for u := 0 to length(JADOC)-1 do
    begin
      if JADOC[u]=p_Con then break;
    end;


    DBC:=VHDBC;
    rs:=JADO_RECORDSET.Create;
    JTrakXDL.DeleteAll;
    JTrak_TableID:=DBC.u8GetTableID(p_sTable,201210012302);
    JTrak_sTable:=p_sTable;
    JTrak_JDType_u:=0;
    JTRak_sPKeyColName:='';
    JTrak_DBConOffset:=u;
    JTrak_Row_ID:=p_u8UID;


    saQry:='select JColu_Name, JColu_JDType_ID from jcolumn where JColu_JTable_ID='+
      inttostr(JTrak_TableID) + ' and JColu_PrimaryKey_b = ' + DBC.sDBMSBoolScrub(true) +
      ' and JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry,p_Con,201503161710);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201203260022, 'Trouble with query.','Query: '+saQry,SOURCEFILE,P_Con,RS);
    end;

    if bOk then
    begin
      bOk:= not rs.eol;
      if not bok then
      begin
        JAS_LOG(self, cnLog_Error, 201203260023, 'No rows returned.','Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      JTrak_sPKeyColname:=rs.fields.Get_saValue('JColu_Name');
      //JTrak_u8JDType:=u8Val(rs.fields.Get_saValue('JColu_JDType_ID'));
      //case JTrak_u8JDType of
      //cnJDType_Unknown: saQry:=p_DBCon.saDBMSUIntScrub(inttostr(p_u8UID));
      //cnJDType_b      : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_i1     : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_i2     : saQry:=p_DBCon.sDBMSIntScrub(p_u8UID);
      //cnJDType_i4     : saQry:=p_DBCon.sDBMSIntScrub(p_u8UID);
      //cnJDType_i8     : saQry:=p_DBCon.sDBMSIntScrub(p_u8UID);
      //cnJDType_i16    : saQry:=p_DBCon.sDBMSIntScrub(p_u8UID);
      //cnJDType_i32    : saQry:=p_DBCon.sDBMSIntScrub(p_u8UID);
      //cnJDType_u1     : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_u2     : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_u4     : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_u8     : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_u16    : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_u32    : saQry:=p_DBCon.sDBMSUIntScrub(p_u8UID);
      //cnJDType_fp     : saQry:=p_DBCon.sDBMSDecScrub(p_u8UID);
      //cnJDType_fd     : saQry:=p_DBCon.sDBMSDecScrub(p_u8UID);
      //cnJDType_cur    : saQry:=p_DBCon.sDBMSDecScrub(p_u8UID);
      //cnJDType_ch     : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_chu    : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_dt     : saQry:=p_DBCon.sDBMSDateScrub(p_u8UID);
      //cnJDType_s      : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_su     : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_sn     : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_sun    : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      //cnJDType_bin    : saQry:=p_DBCon.saDBMSScrub(p_u8UID);
      ///end;//switch
      //saQry:=p_DBCon.sDBMSUIntScrub(inttostr(p_u8UID));
      saQry:='select * from ' + p_Con.sDBMSEncloseObjectName(p_sTable) + ' where ' + p_Con.sDBMSEncloseObjectName(JTrak_sPKeyColName) + '=' + saQry;
    end;
    rs.close;

    if bOk then
    begin
      bOk:=rs.open(saQry, p_COn,201503161711);
      if not bOk then
      begin
        JAS_LOG(self, cnLog_Error, 201203260024, 'Trouble with query.','Query: '+saQry,SOURCEFILE,p_Con,rs);
      end;
    end;

    if bOk then
    begin
      JTrak_bExist:=not rs.eol;
      if rs.fields.movefirst then
      begin
        repeat
          JTrakXDL.AppendItem_saName_N_saValue(rs.fields.Item_saName, rs.fields.Item_saValue);
        until not rs.fields.movenext;
      end;
    end;
    rs.close;
    rs.destroy;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203252229,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
{}
Procedure TCONTEXT.JTrakEnd(p_u8UID: UInt64; p_saSQL: ansistring);
//=============================================================================
Var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  Final_UID: uInt64;
  Final_bCreate: boolean;
  Final_bModify: boolean;
  Final_bDelete: boolean;
  Final_dtWhen: TDateTime;

  XDL: JFC_XDL;
  bExistsNow: boolean;
  rJTrak: rtJTrak;
  saColPrefix: ansistring;
  bFirstFieldSaved: boolean;

  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.JTrakEnd(p_saUID: ansistring; p_saSQL: ansistring);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203252230,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203252230, sTHIS_ROUTINE_NAME);{$ENDIF}
  if rJUser.JUser_Audit_b then
  begin
    DBC:=VHDBC;
    TGT:=JADOC[JTrak_DBConOffset];
    RS:=JADO_RECORDSET.Create;
    XDL:=JFC_XDL.Create;
    Final_dtWhen:=now;
    bFirstFieldSaved:=false;


    //case JTrak_u8JDType of
    //cnJDType_Unknown: saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_b      : saQry:=TGT.sDBMSBoolScrub(p_sUID);
    //cnJDType_i1     : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_i2     : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_i4     : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_i8     : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_i16    : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_i32    : saQry:=TGT.sDBMSIntScrub(p_sUID);
    //cnJDType_u1     : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_u2     : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_u4     : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_u8     : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_u16    : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_u32    : saQry:=TGT.sDBMSUIntScrub(p_sUID);
    //cnJDType_fp     : saQry:=TGT.sDBMSDecScrub(p_sUID);
    //cnJDType_fd     : saQry:=TGT.sDBMSDecScrub(p_sUID);
    //cnJDType_cur    : saQry:=TGT.sDBMSDecScrub(p_sUID);
    //cnJDType_ch     : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_chu    : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_dt     : saQry:=TGT.sDBMSDateScrub(p_sUID);
    //cnJDType_s      : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_su     : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_sn     : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_sun    : saQry:=TGT.saDBMSScrub(p_sUID);
    //cnJDType_bin    : saQry:=TGT.saDBMSScrub(p_sUID);
    //end;//switch
    saQry:=TGT.sDBMSUIntScrub(p_u8UID);
    saQry:='select * from ' + TGT.sDBMSEncloseObjectName(JTrak_sTable) + ' where ' + TGT.sDBMSEncloseObjectName(JTrak_sPKeyColName) + '=' + saQry;
    bOk:=rs.open(saQry, TGT,201503161712);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201203260025, 'Trouble with query.','Query: '+saQry,SOURCEFILE, TGT, rs);
    end;

    if bOk then
    begin
      bExistsNow:=not rs.eol;
      if rs.fields.movefirst then
      begin
        repeat
          XDL.AppendItem_saName_N_saValue(rs.fields.Item_saName, rs.fields.Item_saValue);
        until not rs.fields.movenext;
      end;
    end;
    rs.close;

    if bOk then
    begin
      Final_bCreate:=(not JTrak_bExist) and (bExistsNow);
      //if not Final_bCreate then //make sure not a flagged delete
      saQry:='select JTabl_ColumnPrefix from jtable where JTabl_JTable_UID='+DBC.sDBMSUintScrub(JTrak_TableID);
      bOk:=rs.open(saQry, DBC,201503161713);
      if not bOk then
      begin
        JAS_LOG(self, cnLog_Error, 201203260026, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
      end;
    end;

    if bOk then
    begin
      bOk:=not rs.eol;
      if not bOk then
      begin
        JAS_LOG(self, cnLog_Error, 201203260027, 'No rows returned.','Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      saColPrefix:=rs.fields.Get_saValue('JTabl_ColumnPrefix');
      if XDL.FoundItem_saName(saColPrefix+'_Deleted_b') and (bVal(XDL.Item_saValue)=true) then bExistsNow:=false;
      Final_bModify:=JTrak_bExist and bExistsNow;
      Final_bDelete:=JTrak_bExist and (not bExistsNow);
      if Final_bCreate then Final_UID:=JTrak_Row_ID else Final_UID:=p_u8UID;
    end;
    rs.close;

    if bOk then
    begin
      if XDL.MoveFirst then
      begin
        repeat
          if JTrakXDL.FoundItem_saName(XDL.Item_saName) and (XDL.Item_saValue<>JTrakXDL.Item_saValue) then
          begin
            saQry:='select JColu_JColumn_UID from jcolumn where '+
              'JColu_JTable_ID='+inttostr(JTrak_TableID)+' and ' +
              'JColu_Name='+DBC.saDBMSScrub(XDL.Item_saName)+' and '+
              'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
            bOk:=rs.open(saQry, DBC,201503161714);
            if not bOk then
            begin
              JAS_LOG(self, cnLog_Error, 201203260028, 'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
            end;

            if bOk then
            begin
              clear_jtrak(rJTrak);
              with rJTrak do begin
                //JTrak_JTrak_UID           :=
                JTrak_JDConnection_ID     :=JTrak_DBConOffset;
                JTrak_JSession_ID         :=rJSession.JSess_JSession_UID;
                JTrak_JTable_ID           :=JTrak_TableID;
                JTrak_Row_ID              :=Final_UID;
                JTrak_Col_ID              :=u8Val(rs.fields.Get_saValue('JColu_JColumn_UID'));
                JTrak_JUser_ID            :=rJUser.JUser_JUser_UID;
                JTrak_Create_b            :=Final_bCreate;
                JTrak_Modify_b            :=Final_bModify;
                JTrak_Delete_b            :=Final_bDelete;
                JTrak_When_DT             :=FormatDateTime(csDATETIMEFORMAT,Final_dtWhen);
                JTrak_Before              :=JTrakXDL.Item_saValue;
                JTrak_After               :=XDL.Item_saValue;
                if not bFirstFieldSaved then
                begin
                  JTrak_SQL:=p_saSQL; bFirstFieldSaved:=true;
                end;
                saQry:=
                  'INSERT INTO jtrak ('+
                    'JTrak_JDConnection_ID,'+
                    'JTrak_JSession_ID,'+
                    'JTrak_JTable_ID,'+
                    'JTrak_Row_ID,'+
                    'JTrak_Col_ID,'+
                    'JTrak_JUser_ID,'+
                    'JTrak_Create_b,'+
                    'JTrak_Modify_b,'+
                    'JTrak_Delete_b,'+
                    'JTrak_When_DT,'+
                    'JTrak_Before,'+
                    'JTrak_After,'+
                    'JTrak_SQL'+
                  ') VALUES (' +
                    DBC.sDBMSUIntScrub(JTrak_JDConnection_ID)+','+
                    DBC.sDBMSUIntScrub(JTrak_JSession_ID    )+','+
                    DBC.sDBMSUIntScrub(JTrak_JTable_ID      )+','+
                    DBC.sDBMSUIntScrub(JTrak_Row_ID         )+','+
                    DBC.sDBMSUIntScrub(JTrak_Col_ID         )+','+
                    DBC.sDBMSUIntScrub(JTrak_JUser_ID       )+','+
                    DBC.sDBMSBoolScrub(JTrak_Create_b       )+','+
                    DBC.sDBMSBoolScrub(JTrak_Modify_b       )+','+
                    DBC.sDBMSBoolScrub(JTrak_Delete_b       )+','+
                    DBC.sDBMSDateScrub(JTrak_When_DT        )+','+
                    DBC.saDBMSScrub(JTrak_Before             )+','+
                    DBC.saDBMSScrub(JTrak_After              )+','+
                    DBC.saDBMSScrub(JTrak_SQL                )+' '+
                  ')';
              end;//with
              rs.close;
              bOk:=rs.open(saQry, DBC,201503161715);
              if not bOk then
              begin
                JAS_LOG(self, cnLog_Error, 201203260029, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
              end;
            end;
            rs.close;
          end;
        until (not bOk) or (not XDL.MoveNext);
      end
      else
      begin
        bOk:=false;
        JAS_LOG(self, cnLog_Error, 201203260030, 'Trouble with Context - XDL Empty.','JTRAK',SOURCEFILE);
      end;
    end;
    rs.destroy;
    XDL.Destroy;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203252231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================























//=============================================================================
// Append diagnostic information to END of output document
Procedure TCONTEXT.DebugHTMLOutPut;
//=============================================================================
Var
  bR1: Boolean; // for alternating grid display class
  XDL: JFC_XDL;
  sa: ansistring;
  i: longint;
  saTitle: ansistring;
  saMessage: ansistring;
  saTemplate: ansistring;
  u2IOResult: word;
  saFilename: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASDebugHTMLOutPut(p_Context:TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102594,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102595, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintln('CALLED DebugHTMLOutput: '+inttostr(iDebugMode));
  if(u2DebugMode <> cnSYS_INFO_MODE_SECURE) and
    ((((rJSession.JSess_IP_ADDR='127.0.0.1') or (rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND (u2DebugMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
     (u2DebugMode = cnSYS_INFO_MODE_VERBOSE) ) then
  begin
    //ASPrintln('CALLED DebugHTMLOutput Accepted');
    //saTemplate:=saLoadTextFile(saGetPage(SELF,'','sys_page_debug','MAIN',true,'',201209141029);
    //saFilename:=grJASConfig.saTemplatesDir+lowercase(sLang)+csDOSSLASH+'sys_page_debug.jas';
    saFilename:=garJVHost[u2VHost].VHost_TemplateDir+lowercase(sLang)+DOSSLASH+'sys_page_debug.jas';
    if not bTSLoadEntireFile(saFilename, u2IOResult, saTemplate) then
    begin
      saTemplate:='<table><tr><td>[@TITLE@]</td></tr><tr><td>[@MESSAGE@]</td></tr></table><br /><br />'+csCRLF+csCRLF;
    end;
    saFilename:='';
  
    XDL:=JFC_XDL.Create;
    bR1:=True;
    bR1:=bR1;//shut up compiler
    saOut:=saSNRStr(saOut, '</body>','');
    saOut:=saSNRStr(saOut, '</html>','');

    saOut+=csCRLF +csCRLF + csCRLF;
    saOut+=csCRLF +csCRLF + csCRLF;
    saOut+='<!-- +=+=+=+=+= BELOW IS DEBUG INFORMATION =+=+=+=+=+= -->'+ csCRLF;
    saOut+='<!-- +=+=+=+=+= BELOW IS DEBUG INFORMATION =+=+=+=+=+= -->'+ csCRLF;
    saOut+='<!-- Compile JAS without the {$DEFINE DEBUGHTMLOUTPUT} -->'+ csCRLF;
    saOut+='<!-- compiler option in ' + SOURCEFILE + '-->'+ csCRLF;
    saOut+='<!-- to prevent this information from appearing -->'+ csCRLF;
    saOut+='<!-- +=+=+=+=+= BELOW IS DEBUG INFORMATION =+=+=+=+=+= -->'+ csCRLF;
    saOut+='<!-- +=+=+=+=+= BELOW IS DEBUG INFORMATION =+=+=+=+=+= -->'+ csCRLF;
    saOut+='<script>document.write(''<hr width="''+screen.width+''" />'');</script>'+ csCRLF;
    if saFileName<>'' then saOut+='<h1>Debug Template File Missing: '+saFilename+'</h1><br />';

    

    saMessage:='<p style="font-weight:bold">Note: The information below is diagnostic in nature and is only displayed when the system '+csCRLF+
                 '       configuration file''s DebugMode option is set to either VERBOSE or VERBOSELOCAL. Set to OFF or SECURE '+
                 'to prevent this data from being transmitted.'+csCRLF+
                 '    </p>';
    saTitle:='Form Data Coming In. (Post and|or Get)';
    saMessage:=CGIENV.DataIn.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;
    

    if (CGIENV.FilesIn.ListCount>0) then
    begin
      saTitle:='Files In';
      saMessage:=CGIENV.FilesIn.saHTMLTable(
        '',
        True,
        'CGIENV.FILESIN (Data ColumnWithheld ) Rows: ',
        True,
        True,
        'Nth', 1,
        '',0,
        '',0,
        'Name',2,
        'Data',5,
        'Content-Type',3,
        'Bytes',4,
        '',0
      );
      sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
      sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
      saOut+=sa;
    end;

    
    //saTitle:='Cook ie Data Coming In. Class: JFC_CGIENV.CKY IN';
    //saMessage:=CGIENV.CKY IN.saHTMLTable(
    //  '',
    //  True,
    //  'CGIENV.CKY IN (JFC_CGIENV.JFC_XDL) Rows: ',
    //  True,
    //  True,
    //  'Row', 1,
    //  '',0,
    //  'UID', 4,
    //  'Name',2,
    //  'Value',3,
    //  '',0,
    //  '',0,
    //  '',0
    //);
    //sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    //sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    //saOut+=sa;



    
    //saTitle:='Cook ie Data Sent Out. Class: JFC_CGIENV.CKY OUT';
    //saMessage:=CGIENV.CKY OUT.saHTMLTable(
    //  '',
    //  True,
    //  'CGIENV.CKY OUT (JFC_CGIENV.JFC_XDL) Rows: ',
    //  True,
    //  True,
    //  'Row', 1,
    //  '',0,
    //  'UID', 4,
    //  'Name',2,
    //  'Value',3,
    //  '',0,
    //  '',0,
    //  '',0
    //);
    //sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    //sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    //saOut+=sa;


    saTitle:='Environment Variables. Class: JFC_CGIENV.ENVVAR';
    saMessage:=CGIENV.ENVVAR.saHTMLTable(
      '',
      True,
      'CGIENV.ENVVAR (JFC_CGIENV.JFC_XDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0);
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;



    saTitle:='Environment Headers';
    saMessage:=CGIENV.HEADER.saHTMLTable(
      '',
      True,
      'CGIENV.HEADER (JFC_CGIENV.JFC_XDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0);
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;



    saTitle:='Session Data Class: TCONTEXT.SessionXDL';
    saMessage:=SessionXDL.saHTMLTable(
      '',
      True,
      'SessionXDL (JFC_CGIENV.JFC_XDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0);
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;



    saTitle:='Context XML Class: TCONTEXT.XML';
    saMessage:=XML.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;


    saTitle:='Context Matrix Class: TCONTEXT.MATRIX';
    saMessage:=MATRIX.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;


    saTitle:='Request Variables Class: TCONTEXT.REQVAR_XDL';
    saMessage:=REQVAR_XDL.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;



    // CGIENV: JFC_CGIENV;
    saTitle:='CGI Environment';
    saMessage:=
      '    <div class="jasgrid">'+ csCRLF+
      '      <table>'+ csCRLF+
      '      <thead>'+csCRLF+
      '      <tr>'+ csCRLF+
      '        <td align="left" valign="middle">Name</td>'+ csCRLF+
      '        <td align="left" valign="middle">Value</td>'+ csCRLF+
      '      </tr>'+ csCRLF+
      '      </thead>'+csCRLF+
      '      <tbody>'+csCRLF+
      '      <tr class="r2"><td>bPost</td><td>'+sTRueFalse(CGIENV.bPost)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPostContentType</td><td>'+CGIENV.saPostContentType+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>uPostContentLength</td><td>'+inttostr(CGIENV.uPostContentLength)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPostData</td><td>'+CGIENV.saPostData+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iTimeZoneOffset</td><td>'+inttostr(CGIENV.iTimeZoneOffset)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>uHTTPResponse</td><td>'+inttostr(CGIENV.uHTTPResponse)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saServerSoftware</td><td>'+CGIENV.saServerSoftware+'</td></tr>'+csCRLF+
      '      </tbody>'+ csCRLF+
      '      </table>'+ csCRLF+
      '    </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;

    //====================================================================================
    //====================================================================================
    //====================================================================================
    //====================================================================================
    //====================================================================================
    //====================================================================================
    //====================================================================================









    saTitle:='JAS TCONTEXT';
    saMessage:=
      '    <div class="jasgrid">'+ csCRLF+
      '      <table>'+ csCRLF+
      '      <thead>'+csCRLF+
      '      <tr>'+ csCRLF+
      '        <td align="left" valign="middle">Name</td>'+ csCRLF+
      '        <td align="left" valign="middle">Value</td>'+ csCRLF+
      '      </tr>'+ csCRLF+
      '      </thead>'+csCRLF+
      '      <tbody>'+csCRLF+
      '      <tr class="r2"><td>u8RequestUID</td><td>'+inttostr(u8RequestUID)+'</td></tr>'+csCRLF+

      '      <tr class="r1"><td>lpWorker</td><td>'+INTTOSTR(UINT(lpWorker))+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bSessionValid</td><td>'+sYesNo(bSessionValid)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bErrorCondition</td><td>'+sYesNo(bErrorCondition)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u8ErrNo</td><td>'+inttostr(u8ErrNo)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saErrMsg</td><td>'+saErrMsg+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saErrMsgMoreInfo</td><td>'+saErrMsgMoreInfo+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sServerIP</td><td>'+sServerIP+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sServerPort</td><td>'+inttostr(u2ServerPort)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sServerIPCGI</td><td>'+sServerIPCGI+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u2ServerPortCGI</td><td>'+inttostr(u2ServerPortCGI)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPage</td><td>'+saPage+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bLoginAttempt</td><td>'+sYesNo(bLoginAttempt)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPageTitle</td><td>'+saPageTitle+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>dtRequested</td><td>'+formatdatetime(csDATETIMEFormat,dtRequested)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>dtServed</td><td>'+formatdatetime(csDATETIMEFormat,dtServed)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>dtFinished</td><td>'+formatdatetime(csDATETIMEFormat,dtFinished)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sLang</td><td>'+sLang+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bOutputRaw</td><td>'+sYesNo(bOutputRaw)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saHTMLRIPPER_Area</td><td>'+saHTMLRIPPER_Area+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saHTMLRIPPER_Page</td><td>'+saHTMLRIPPER_Page+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saHTMLRIPPER_Section</td><td>'+saHTMLRIPPER_Section+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u8MenuTopID</td><td>'+inttostr(u8MenuTopID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saUserCacheDir</td><td>'+saUserCacheDir+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sHelpID</td><td>'+inttostr(u8HelpID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>u2ErrorReportingMode</td><td>';
    case u2ErrorReportingMode of
    cnSYS_INFO_MODE_VERBOSELOCAL: saMessage+='cnSYS_INFO_MODE_VERBOSELOCAL';
    cnSYS_INFO_MODE_VERBOSE: saMessage+='cnSYS_INFO_MODE_VERBOSE';
    else saMessage+='cnSYS_INFO_MODE_SECURE';
    end;//endcase
    saMessage+='</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iDebugMode (context based) </td><td>';
    case u2DebugMode of
    cnSYS_INFO_MODE_VERBOSELOCAL: saMessage+='cnSYS_INFO_MODE_VERBOSELOCAL';
    cnSYS_INFO_MODE_VERBOSE: saMessage+='cnSYS_INFO_MODE_VERBOSE';
    else saMessage+='cnSYS_INFO_MODE_SECURE';
    end;//endcase
    saMessage+='</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute</td><td>'+sYesNo(bMIME_execute)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bMIME_execute_Jegas</td><td>'+sYesNo(bMIME_execute_Jegas)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute_JegasWebService</td><td>'+sYesNo(bMIME_execute_JegasWebService)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bMIME_execute_php</td><td>'+sYesNo(bMIME_execute_php)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute_perl</td><td>'+sYesNo(bMIME_execute_perl)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sMimeType</td><td>'+sMimeType+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMimeSNR</td><td>'+sYesNo(bMimeSNR)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saFileSoughtNoExt</td><td>'+saFileSoughtNoExt+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sFileSoughtExt</td><td>'+sFileSoughtExt+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sFileNameOnly</td><td>'+sFileNameOnly+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sFileNameOnlyNoExt</td><td>'+sFileNameOnlyNoExt+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saIN</td><td>'+saIN+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saOut</td><td>'+saOut+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>uBytesRead</td><td>'+inttostr(uBytesRead)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>uBytesSent</td><td>'+inttostr(uBytesSent)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestedHost</td><td>'+saRequestedHost+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestedHostRootDir</td><td>'+saRequestedHostRootDir+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sRequestMethod</td><td>'+sRequestMethod+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sRequestType</td><td>'+sRequestType+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestURI</td><td>'+saRequestURI+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestedFile</td><td>'+saRequestedFile+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saOriginallyRequestedFile</td><td>'+saOriginallyRequestedFile+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestedName</td><td>'+saRequestedName+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestedDir</td><td>'+saRequestedDir+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saFileSought</td><td>'+saFileSought+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saQueryString</td><td>'+saQueryString+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>u2HttpErrorCode</td><td>'+inttostr(u2HttpErrorCode)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saLogFile</td><td>'+saLogFile+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bJASCGI</td><td>'+sYesNo(bJASCGI)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sActionType</td><td>'+sActionType+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>iSessionResultCode</td><td>'+inttostr(iSessionResultCode)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bSaveSessionData</td><td>'+sYesNo(bSaveSessionData)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bInternalJob</td><td>'+sYesNo(bInternalJob)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_TableID</td><td>'+inttostr(JTrak_TableID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_u2JDType</td><td>'+inttostr(JTrak_JDType_u)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTRak_sPKeyCol</td><td>'+JTRak_sPKeyColName+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_DBConID</td><td>'+inttostr(JTrak_DBConOffset)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_Row_ID</td><td>'+inttostr(JTrak_Row_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_bExist</td><td>'+sYesNo(JTrak_bExist)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_sTable</td><td>'+JTrak_sTable+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sTheme</td><td>'+sTheme+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u2VHost</td><td>'+inttostr(u2VHost)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sAlias</td><td>'+sAlias+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bMenuHasPAnels</td><td>'+sYesNo(bMenuHasPAnels)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>sIconTheme</td><td>'+sIconTheme+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u2LogType_ID</td><td>'+inttostr(u2LogType_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bNoWebCache</td><td>'+sYesNo(bNoWebCache)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bWhiteListed</td><td>'+sYesno(bWhiteListed)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JSession_UID</td><td>'+inttostr(rJSession.JSess_JSession_UID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_JSessionType_ID</td><td>'+inttostr(rJSession.JSess_JSessionType_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JUser_ID</td><td>'+inttostr(rJSession.JSess_JUser_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_Connect_DT</td><td>'+rJSession.JSess_Connect_DT+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_LastContact_DT</td><td>'+rJSession.JSess_LastContact_DT+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_IP_ADDR</td><td>'+rJSession.JSess_IP_ADDR+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_PORT_u</td><td>'+inttostr(rJSession.JSess_PORT_u)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_Username</td><td>'+rJSession.JSess_Username+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JJobQ_ID</td><td>'+inttostr(rJSession.JSess_JJobQ_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_JUser_UID</td><td>'+inttostr(rJUser.JUser_JUser_UID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Name</td><td>'+rJUser.JUser_Name                 +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Password</td><td>Withheld</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_JPerson_ID</td><td>'+inttostr(rJUser.JUser_JPerson_ID)           +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Enabled_b</td><td>'+sYesNo(rJUser.JUser_Enabled_b)            +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Admin_b</td><td>'+sYesNo(rJUser.JUser_Admin_b)              +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Login_First_DT</td><td>'+rJUser.JUser_Login_First_DT       +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Login_Last_DT</td><td>'+rJUser.JUser_Login_Last_DT        +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Logins_Successful_u</td><td>'+inttostr(rJUser.JUser_Logins_Successful_u)  +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Logins_Failed_u</td><td>'+inttostr(rJUser.JUser_Logins_Failed_u)      +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Password_Changed_DT</td><td>'+rJUser.JUser_Password_Changed_DT  +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_AllowedSessions_u</td><td>'+inttostr(rJUser.JUser_AllowedSessions_u)    +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_DefaultPage_Login</td><td>'+rJUser.JUser_DefaultPage_Login    +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_DefaultPage_Logout</td><td>'+rJUser.JUser_DefaultPage_Logout   +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_JLanguage_ID</td><td>'+inttostr(rJUser.JUser_JLanguage_ID)         +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Audit_b</td><td>'+sYesNo(rJUser.JUser_Audit_b)              +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_ResetPass_u</td><td>'+inttostr(rJUser.JUser_ResetPass_u)          +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_JVHost_ID</td><td>'+inttostr(rJUser.JUser_JVHost_ID)            +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_TotalJetUsers_u</td><td>'+inttostr(rJUser.JUser_TotalJetUsers_u)      +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_SIP_Exten</td><td>'+rJUser.JUser_SIP_Exten            +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_SIP_Pass</td><td>'+rJUser.JUser_SIP_Pass             +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Headers_b</td><td>'+sYesNo(rJUser.JUser_Headers_b)            +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_QuickLinks_b</td><td>'+sYesNo(rJUser.JUser_QuickLinks_b)         +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_IconTheme</td><td>'+rJUser.JUser_IconTheme            +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Theme</td><td>'+rJUser.JUser_Theme                +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_CreatedBy_JUser_ID</td><td>'+inttostr(rJUser.JUser_CreatedBy_JUser_ID)   +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Created_DT</td><td>'+rJUser.JUser_Created_DT           +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_ModifiedBy_JUser_ID</td><td>'+inttostr(rJUser.JUser_ModifiedBy_JUser_ID)  +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Modified_DT</td><td>'+rJUser.JUser_Modified_DT          +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_DeletedBy_JUser_ID</td><td>'+inttostr(rJUser.JUser_DeletedBy_JUser_ID)   +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Deleted_DT</td><td>'+rJUser.JUser_Deleted_DT           +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Deleted_b</td><td>'+sYesNo(rJUser.JUser_Deleted_b)            +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.rJAS_Row_b</td><td>'+sYesNo(rJUser.JAS_Row_b)                 +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.lpParent</td><td>'+inttostr(UINT(JThread.lpParent))          +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.uExecuteIterations</td><td>'+inttostr(JThread.uExecuteIterations)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.dtCreated</td><td>'+FormatDateTime(csDateTimeFormat,JThread.dtCreated)         +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.dtExecuteBegin</td><td>'+FormatDateTime(csDateTimeFormat,JThread.dtExecuteBegin)    +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.dtExecuteEnd</td><td>'+FormatDateTime(csDateTimeFormat,JThread.dtExecuteEnd)      +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.bShuttingDown</td><td>'+sYesNo(JThread.bShuttingDown)     +'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.bLoopContinuously</td><td>'+sYesNo(JThread.bLoopContinuously) +'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.bFinished</td><td>'+sYesNo(JThread.bFinished)         +'</td></tr>'+csCRLF+
      '    </tbody>'+ csCRLF+
      '    </table>'+ csCRLF+
      '  </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;




    if PAGESNRXDL.MoveFirst then
    begin
      Repeat
        XDL.appenditem;
        xdl.Item_saName:=PAGESNRXDL.Item_saName;
        xdl.Item_saValue:=saHTMLScrub(PAGESNRXDL.Item_saValue);
        xdl.Item_saDesc:=PAGESNRXDL.Item_saDesc;
        xdl.Item_i8User:=PAGESNRXDL.Item_i8User;
      until not PAGESNRXDL.MoveNext;
    end;
    if XDL.MoveFirst then
    begin
      repeat
        sa:=XDL.Item_saName;
        XDL.Item_saName:='';
        for i:=1 to length(sa) do
        begin
          XDL.Item_saName:=XDL.Item_saName+sa[i]+' ';
        end;
      until not XDL.MoveNext;
    end;
    saTitle:='Context Page Search-N-Replace XDL Class: TCONTEXT.PAGESNRXDL '+inttostr(PAGESNRXDL.ListCount)+' xdl:'+inttostr(xdl.listcount);
    saMessage:=XDL.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;
    saOut+='<hr /><b>End of DEBUG OUTPUT</b><hr />';
    saOut+='</body></html>';
    XDL.Destroy;XDL:=nil;




    // =-=-=-=-=-=-=-=-=-=-=-=-==-
    //   XML: JFC_XML;
    //   CGIENV: JFC_CGIENV;
    //   MATRIX: JFC_MATRIX;
    //   LogXXDL: JFC_XXDL;
    //   SessionXDL: JFC_XDL;
    //   JTrakXDL: JFC_XDL;
    //   PROCESS: TPROCESS;
    //   JADOC: array of JADO_CONNECTION;
    //   REQVAR_XDL: JFC_XDL;
    // -=-=-=-=-=-=-=-=-=-=-=-=-=
    // grJASConfig
    // Virtual Host
    // -=-=-=-=-=-=-=-=-=-=-=-=-=


    saTitle:='JAS Config';
    saMessage:=
      '    <div class="jasgrid">'+ csCRLF+
      '    <table>'+ csCRLF+
      '    <thead>'+csCRLF+
      '    <tr>'+ csCRLF+
      '      <td align="left" valign="middle">Name</td>'+ csCRLF+
      '      <td align="left" valign="middle">Value</td>'+ csCRLF+
      '    </tr>'+ csCRLF+
      '    </thead>'+csCRLF+
      '    <tbody>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.saSysDir</td><td>'+grJASConfig.saSysDir                            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.saLogDir</td><td>'+grJASConfig.saLogDir                            +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.saPHPDir</td><td>'+grJASConfig.saPHPDir                            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.saPHP</td><td>'+grJASConfig.saPHP                               +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.saPerl</td><td>'+grJASConfig.saPerl                              +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.saJASFooter</td><td>'+grJASConfig.saJASFooter                         +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sServerSoftware</td><td>'+grJASConfig.sServerSoftware                     +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2ThreadPoolNoOfThreads</td><td>'+inttostr(grJASConfig.u2ThreadPoolNoOfThreads)             +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.uThreadPoolMaximumRunTimeInMSec</td><td>'+inttostr(grJASConfig.uThreadPoolMaximumRunTimeInMSec)     +'</td></tr>'+csCRLF+
//      '    <tr class="r2"><td>grJASConfig.sServerURL</td><td>'+grJASConfig.sServerURL                          +'</td></tr>'+csCRLF+
//      '    <tr class="r1"><td>grJASConfig.sServerName </td><td>'+grJASConfig.sServerName                         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sServerIdent</td><td>'+grJASConfig.sServerIdent                        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sDefaultLanguage</td><td>'+grJASConfig.sDefaultLanguage                    +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u1DefaultMenuRenderMethod</td><td>'+inttostr(grJASConfig.u1DefaultMenuRenderMethod)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sServerIP</td><td>'+grJASConfig.sServerIP                           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2ServerPort</td><td>'+inttostr(grJASConfig.u2ServerPort)                        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2RetryLimit</td><td>'+inttostr(grJASConfig.u2RetryLimit)                        +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u4RetryDelayInMSec</td><td>'+inttostr(grJASConfig.u4RetryDelayInMSec)                  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.i1TIMEZONEOFFSET</td><td>'+inttostr(grJASConfig.i1TIMEZONEOFFSET)                    +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u4MaxFileHandles</td><td>'+inttostr(grJASConfig.u4MaxFileHandles)                    +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bBlacklistEnabled</td><td>'+sYesNo(grJASConfig.bBlacklistEnabled)                   +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bWhiteListEnabled</td><td>'+sYesNo(grJASConfig.bWhiteListEnabled)                   +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bBlacklistIPExpire</td><td>'+sYesNo(grJASConfig.bBlacklistIPExpire)                  +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bWhitelistIPExpire</td><td>'+sYesNo(grJASConfig.bWhitelistIPExpire)                  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bInvalidLoginsExpire</td><td>'+sYesNo(grJASConfig.bInvalidLoginsExpire)                +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2BlacklistDaysUntilExpire</td><td>'+inttostr(grJASConfig.u2BlacklistDaysUntilExpire)          +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2WhitelistDaysUntilExpire</td><td>'+inttostr(grJASConfig.u2WhitelistDaysUntilExpire)          +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2InvalidLoginsDaysUntilExpire</td><td>'+inttostr(grJASConfig.u2InvalidLoginsDaysUntilExpire)      +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bJobQEnabled</td><td>'+sYesNo(grJASConfig.bJobQEnabled)                        +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u4JobQIntervalInMSec</td><td>'+inttostr(grJASConfig.u4JobQIntervalInMSec)                +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sSMTPHost</td><td>'+grJASConfig.sSMTPHost                           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sSMTPUsername</td><td>'+grJASConfig.sSMTPUsername                       +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sSMTPPassword</td><td>Withheld</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bProtectJASRecords</td><td>'+sYesNo(grJASConfig.bProtectJASRecords)                  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bSafeDelete</td><td>'+sYesNo(grJASConfig.bSafeDelete)                         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bAllowVirtualHostCreation</td><td>'+sYesNo(grJASConfig.bAllowVirtualHostCreation)           +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bPunkBeGoneEnabled</td><td>'+sYesNo(grJASConfig.bPunkBeGoneEnabled)                  +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2PunkBeGoneMaxErrors</td><td>'+inttostr(grJASConfig.u2PunkBeGoneMaxErrors)               +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2PunkBeGoneMaxMinutes</td><td>'+inttostr(grJASConfig.u2PunkBeGoneMaxMinutes)              +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u4PunkBeGoneIntervalInMSec</td><td>'+inttostr(grJASConfig.u4PunkBeGoneIntervalInMSec)          +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2PunkBeGoneIPHoldTimeInDays</td><td>'+inttostr(grJASConfig.u2PunkBeGoneIPHoldTimeInDays)        +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2PunkBeGoneMaxDownloads</td><td>'+inttostr(grJASConfig.u2PunkBeGoneMaxDownloads)            +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bPunkBeGoneSmackBadBots</td><td>'+sYesNo(grJASConfig.bPunkBeGoneSmackBadBots)             +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2LogLevel</td><td>'+inttostr(grJASConfig.u2LogLevel)                          +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bDeleteLogFile</td><td>'+sYesNo(grJASConfig.bDeleteLogFile)                      +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2ErrorReportingMode</td><td>'+inttostr(grJASConfig.u2ErrorReportingMode)                +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.saErrorReportingSecureMessage</td><td>'+grJASConfig.saErrorReportingSecureMessage       +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bSQLTraceLogEnabled</td><td>'+sYesNo(grJASConfig.bSQLTraceLogEnabled)                 +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bServerConsoleMessagesEnabled</td><td>'+sYesNo(grJASConfig.bServerConsoleMessagesEnabled)       +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.rbDebugServerConsoleMessagesEnabled </td><td>'+sYesNo(grJASConfig.bDebugServerConsoleMessagesEnabled) +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2DebugMode</td><td>'+inttostr(grJASConfig.u2DebugMode )                        +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2SessionTimeOutInMinutes</td><td>'+inttostr(grJASConfig.u2SessionTimeOutInMinutes)           +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2LockTimeOutInMinutes</td><td>'+inttostr(grJASConfig.u2LockTimeOutInMinutes   )           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2LockRetriesBeforeFailure</td><td>'+inttostr(grJASConfig.u2LockRetriesBeforeFailure)          +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2LockRetryDelayInMSec</td><td>'+inttostr(grJASConfig.u2LockRetryDelayInMSec   )           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2ValidateSessionRetryLimit</td><td>'+inttostr(grJASConfig.u2ValidateSessionRetryLimit)         +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.uMaximumRequestHeaderLength</td><td>'+inttostr(grJASConfig.uMaximumRequestHeaderLength)         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2CreateSocketRetry</td><td>'+inttostr(grJASConfig.u2CreateSocketRetry)                 +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.u2CreateSocketRetryDelayInMSec</td><td>'+inttostr(grJASConfig.u2CreateSocketRetryDelayInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.u2SocketTimeOutInMSec</td><td>'+inttostr(grJASConfig.u2SocketTimeOutInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bEnableSSL</td><td>'+sYesNo(grJASConfig.bEnableSSL)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bRedirectToPort443</td><td>'+sYesNo(grJASConfig.bRedirectToPort443)                  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sHOOK_ACTION_CREATESESSION_FAILURE</td><td>'+grJASConfig.sHOOK_ACTION_CREATESESSION_FAILURE  +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sHOOK_ACTION_CREATESESSION_SUCCESS</td><td>'+grJASConfig.sHOOK_ACTION_CREATESESSION_SUCCESS  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sHOOK_ACTION_REMOVESESSION_FAILURE</td><td>'+grJASConfig.sHOOK_ACTION_REMOVESESSION_FAILURE  +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sHOOK_ACTION_REMOVESESSION_SUCCESS</td><td>'+grJASConfig.sHOOK_ACTION_REMOVESESSION_SUCCESS  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sHOOK_ACTION_SESSIONTIMEOUT</td><td>'+grJASConfig.sHOOK_ACTION_SESSIONTIMEOUT         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sHOOK_ACTION_VALIDATESESSION_FAILURE</td><td>'+grJASConfig.sHOOK_ACTION_VALIDATESESSION_FAILURE+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sHOOK_ACTION_VALIDATESESSION_SUCCESS</td><td>'+grJASConfig.sHOOK_ACTION_VALIDATESESSION_SUCCESS+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.sClientToVICIServerIP</td><td>'+grJASConfig.sClientToVICIServerIP               +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.sJASServertoVICIServerIP</td><td>'+grJASConfig.sJASServertoVICIServerIP            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>grJASConfig.bCreateHybridJets</td><td>'+sYesNo(grJASConfig.bCreateHybridJets)                   +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>grJASConfig.bRecordLockingEnabled</td><td>'+sYesNo(grJASConfig.bRecordLockingEnabled)               +'</td></tr>'+csCRLF+
      '    </tbody>'+ csCRLF+
      '    </table>'+ csCRLF+
      '  </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;











    //============================================================== CURRENT JVHOST IN PLAY =========================================================
    saTitle:='Virtual Host #'+inttostr(self.u2VHost)+' (0=Main or Default Virtual host.)';
    saMessage:=
      '    <div class="jasgrid">'+ csCRLF+
      '    <table>'+ csCRLF+
      '    <thead>'+csCRLF+
      '    <tr>'+ csCRLF+
      '      <td align="left" valign="middle">Name</td>'+ csCRLF+
      '      <td align="left" valign="middle">Value</td>'+ csCRLF+
      '    </tr>'+ csCRLF+
      '    </thead>'+csCRLF+
      '    <tbody>'+csCRLF+
      //'    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].MenuDL</td><td>'+garJVHost[u2VHost].MenuDL                       +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].bIdentOk</td><td>'+sYesNo(garJVHost[u2VHost].bIdentOk)                     +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_AllowRegistration_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_AllowRegistration_b)    +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_RegisterReqCellPhone_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_RegisterReqCellPhone_b) +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_RegisterReqBirthday_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_RegisterReqBirthday_b)  +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_JVHost_UID</td><td>'+inttostr(garJVHost[u2VHost].VHost_JVHost_UID)             +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_WebRootDir</td><td>'+garJVHost[u2VHost].VHost_WebRootDir             +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ServerName</td><td>'+garJVHost[u2VHost].VHost_ServerName             +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ServerIdent</td><td>'+garJVHost[u2VHost].VHost_ServerIdent            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ServerURL</td><td>'+garJVHost[u2VHost].VHost_ServerURL              +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ServerDomain</td><td>'+garJVHost[u2VHost].VHost_ServerDomain           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultLanguage</td><td>'+garJVHost[u2VHost].VHost_DefaultLanguage        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultTheme</td><td>'+garJVHost[u2VHost].VHost_DefaultTheme           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_MenuRenderMethod</td><td>'+inttostr(garJVHost[u2VHost].VHost_MenuRenderMethod)       +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultArea</td><td>'+garJVHost[u2VHost].VHost_DefaultArea            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultPage</td><td>'+garJVHost[u2VHost].VHost_DefaultPage            +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultSection</td><td>'+garJVHost[u2VHost].VHost_DefaultSection         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultTop_JMenu_ID</td><td>'+inttostr(garJVHost[u2VHost].VHost_DefaultTop_JMenu_ID)    +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultLoggedInPage</td><td>'+garJVHost[u2VHost].VHost_DefaultLoggedInPage    +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultLoggedOutPage</td><td>'+garJVHost[u2VHost].VHost_DefaultLoggedOutPage   +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DataOnRight_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_DataOnRight_b)          +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_CacheMaxAgeInSeconds</td><td>'+inttostr(garJVHost[u2VHost].VHost_CacheMaxAgeInSeconds)   +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_SystemEmailFromAddress </td><td>'+garJVHost[u2VHost].VHost_SystemEmailFromAddress +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_SharesDefaultDomain_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_SharesDefaultDomain_b)  +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DefaultIconTheme</td><td>'+garJVHost[u2VHost].VHost_DefaultIconTheme       +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DirectoryListing_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_DirectoryListing_b)     +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_FileDir</td><td>'+garJVHost[u2VHost].VHost_FileDir                +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_AccessLog</td><td>'+garJVHost[u2VHost].VHost_AccessLog              +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ErrorLog</td><td>'+garJVHost[u2VHost].VHost_ErrorLog               +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_JDConnection_ID</td><td>'+Inttostr(garJVHost[u2VHost].VHost_JDConnection_ID)        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_Enabled_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_Enabled_b)              +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_TemplateDir</td><td>'+garJVHost[u2VHost].VHost_TemplateDir            +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_SipURL</td><td>'+garJVHost[u2VHost].VHOST_SipURL                 +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_CacheDir</td><td>'+garJVHost[u2VHost].VHOST_CacheDir               +'</td></tr>'+csCRLF+
      //'    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST _LogDir</td><td>'+garJVHost[u2VHost].VHOST _LogDir                 +'</td></tr>'+csCRLF+
      //'    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHOST _ThemeDir</td><td>'+garJVHost[u2VHost].VHOST _ThemeDir               +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_WebshareDir</td><td>'+garJVHost[u2VHost].VHOST_WebshareDir            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_WebShareAlias</td><td>'+garJVHost[u2VHost].VHOST_WebShareAlias          +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_JASDirTheme</td><td>'+garJVHost[u2VHost].VHOST_JASDirTheme            +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_DefaultArea</td><td>'+garJVHost[u2VHost].VHOST_DefaultArea           +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_DefaultPage</td><td>'+garJVHost[u2VHost].VHOST_DefaultPage           +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_DefaultSection</td><td>'+garJVHost[u2VHost].VHOST_DefaultSection        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHOST_PasswordKey_u1</td><td>'+inttostr(garJVHost[u2VHost].VHOST_PasswordKey_u1)         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_LogToDataBase_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_LogToDataBase_b)        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_LogToConsole_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_LogToConsole_b)         +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_LogRequestsToDatabase_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_LogRequestsToDatabase_b)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_AccessLog</td><td>'+garJVHost[u2VHost].VHost_AccessLog       +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ErrorLog</td><td>'+garJVHost[u2VHost].VHost_ErrorLog        +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_CreatedBy_JUser_ID</td><td>'+inttostr(garJVHost[u2VHost].VHost_CreatedBy_JUser_ID)     +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_Created_DT</td><td>'+garJVHost[u2VHost].VHost_Created_DT             +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_ModifiedBy_JUser_ID</td><td>'+inttostr(garJVHost[u2VHost].VHost_ModifiedBy_JUser_ID)    +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_Modified_DT</td><td>'+garJVHost[u2VHost].VHost_Modified_DT            +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_DeletedBy_JUser_ID</td><td>'+inttostr(garJVHost[u2VHost].VHost_DeletedBy_JUser_ID)     +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].VHost_Deleted_DT</td><td>'+garJVHost[u2VHost].VHost_Deleted_DT             +'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>garJVHost['+inttostr(u2VHost)+'].VHost_Deleted_b</td><td>'+sYesNo(garJVHost[u2VHost].VHost_Deleted_b)              +'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>garJVHost['+inttostr(u2VHost)+'].JAS_Row_b</td><td>'+sYesNo(garJVHost[u2VHost].JAS_Row_b)                   +'</td></tr>'+csCRLF+
      '    </tbody>'+ csCRLF+
      '    </table>'+ csCRLF+
      '  </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;
    //============================================================== CURRENT JVHOST IN PLAY =========================================================







    //JADOC: array of JADO_CONNECTION;
    for i:=0 to length(JADOC)-1 do
    begin
      saTitle:='Database Connection #'+inttostr(i);
      saMessage:=
        '    <div class="jasgrid">'+ csCRLF+
        '    <table>'+ csCRLF+
        '    <thead>'+csCRLF+
        '    <tr>'+ csCRLF+
        '      <td align="left" valign="middle">Name</td>'+ csCRLF+
        '      <td align="left" valign="middle">Value</td>'+ csCRLF+
        '    </tr>'+ csCRLF+
        '    </thead>'+csCRLF+
        '    <tbody>'+csCRLF+
        '    <tr class="r2"><td>ID</td><td>'+inttostr(JADOC[i].ID)+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>JDCon_JSecPerm_ID</td><td>'+inttostr(JADOC[i].JDCon_JSecPerm_ID)+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>u8DbmsID</td><td>';
      case JADOC[i].u8DbmsID of
      cnDBMS_Generic:      saMessage+='Generic';
      cnDBMS_MSSQL:        saMessage+='Microsoft SQL';
      cnDBMS_MSAccess:     saMessage+='MS Access';
      cnDBMS_MySQL:        saMessage+='MySQL';
      cnDBMS_Excel:        saMessage+='Excel';
      cnDBMS_dBase:        saMessage+='dBase';
      cnDBMS_FoxPro:       saMessage+='FoxPro';
      cnDBMS_Oracle:       saMessage+='Oracle';
      cnDBMS_Paradox:      saMessage+='Paradox';
      cnDBMS_Text:         saMessage+='Test';
      cnDBMS_PostGresSQL:  saMessage+='PostGres SQL';
      cnDBMS_SQLite:       saMessage+='SQL Lite';
      else begin saMessage+='Unknown'; end;
      end;//case
      saMessage+=
        '</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saConnectionString</td><td>'+JADOC[i].sConnectionString+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>sDefaultDatabase</td><td>'+JADOC[i].sDefaultDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>sProvider</td><td>'+JADOC[i].sProvider+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>i4State</td><td>';
      case JADOC[i].i4State of
      adStateClosed:saMessage+='Closed';
      adStateConnecting:saMessage+='Connecting';
      adStateExecuting:saMessage+='Executing';
      adStateFetching:saMessage+='Fetching';
      adStateOpen:saMessage+='Open';
      else begin saMessage+='Unknown'; end;
      end;//case
      saMessage+=
        '</td></tr>'+csCRLF+
        '    <tr class="r1"><td>sVersion</td><td>'+JADOC[i].sVersion+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>u2DrivID</td><td>';
      case JADOC[i].u8DriverID of
      cnDriv_ODBC: saMessage+='ODBC';
      cnDriv_MySQL: saMessage+='MySQL API';
      else begin saMessage+='Unknown'; end;
      end;//case
      saMessage+=
        '</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saMyUsername</td><td>'+JADOC[i].saMyUsername+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saMyPassword</td><td>Withheld</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saMyConnectString</td><td>'+JADOC[i].saMyConnectString+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saMyDatabase</td><td>'+JADOC[i].saMyDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saMyServer</td><td>'+JADOC[i].saMyServer+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>u4MyPort</td><td>'+inttostR(JADOC[i].u2MyPort)+'</td></tr>'+csCRLF+
{$IFDEF ODBC}        
        '    <tr class="r1"><td>ODBCDBHandle</td><td>'+IntToStr(UINT(JADOC[i].ODBCDBHandle))+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>ODBCStmtHandle</td><td>'+IntToStr(UINT(JADOC[i].ODBCStmtHandle))+'</td></tr>'+csCRLF+
{$ENDIF}        
        '    <tr class="r1"><td>saName</td><td>'+JADOC[i].sName+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saDesc</td><td>'+JADOC[i].saDesc+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDSN</td><td>'+JADOC[i].sDSN+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saUserName</td><td>'+JADOC[i].sUserName+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saPassword</td><td>Withheld</td></tr>'+csCRLF+
        '    <tr class="r2"><td>sDriver</td><td>'+JADOC[i].sDriver+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saServer</td><td>'+JADOC[i].sServer+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saDatabase</td><td>'+JADOC[i].sDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>bConnected</td><td>'+sTrueFalse(JADOC[i].bConnected)+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>bConnecting</td><td>'+sTrueFalse(JADOC[i].bConnecting)+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>bInUse</td><td>'+sTrueFalse(JADOC[i].bInUse)+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>bFileBasedDSN</td><td>'+sTrueFalse(JADOC[i].bFileBasedDSN)+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDSNFileName</td><td>'+JADOC[i].saDSNFileName+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saConnectString</td><td>'+JADOC[i].sConnectString+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>bIsCopy</td><td>'+sTrueFalse(JADOC[i].bIsCopy)+'</td></tr>'+csCRLF+
        '    </tbody>'+ csCRLF+
        '    </table>'+ csCRLF+
        '  </div>'+ csCRLF;
      sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
      sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
      saOut+=sa;


      saTitle:='Database Connection #'+inttostr(i)+' Table Matrix';
      saMessage:=JADOC[i].JASTABLEMATRIX.saHTMLTable;
      sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
      sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
      saOut+=sa;

      if JADOC[i].Errors.MoveFirst then
      begin
        saTitle:='Database Connection #'+inttostr(i)+' Errors';
        saMessage:=
          '    <div class="jasgrid">'+ csCRLF+
          '    <table>'+ csCRLF+
          '    <thead>'+csCRLF+
          '    <tr>'+ csCRLF+
          '      <td align="left" valign="middle">Name</td>'+ csCRLF+
          '      <td align="left" valign="middle">Value</td>'+ csCRLF+
          '    </tr>'+ csCRLF+
          '    </thead>'+csCRLF+
          '    <tbody>'+csCRLF;

        if (JADOC[i].Errors.N mod 2)=0 then sa:='r2' else sa:='r2';
        repeat
          saMessage+=
            '    <tr class="'+sa+'">u8NativeError</td><td>u8Number</td><td>saSource</td><td>saSQLState</td></tr>'+csCRLF+
            '      <td>'+inttostr(JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).u8NativeError)+'</td>'+
            '      <td>'+inttostr(JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).u8Number)+'</td>'+
            '      <td>'+JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).saSource+'</td>'+
            '      <td>'+JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).saSQLState+'</td>'+
            '    </tr>'+csCRLF;
        until not JADOC[i].Errors.MoveNext;

        saMessage+=
          '    </tbody>'+ csCRLF+
          '    </table>'+ csCRLF+
          '  </div>'+ csCRLF;
        sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
        sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
        saOut+=sa;
      end;
    end;

    //PROCESS: TPROCESS; - not doing

    saTitle:='Search-N-Replace (URI Encoded) Class: TCONTEXT.PageSNRXDL';
    saMessage:=PageSNRXDL.saHTMLTable(
      '',
      True,
      'PageSNRXDL (TCONTEXT.PageSNRXDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0);
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saEncodeURI(saMessage));
    saOut+=sa;




    // LogXXDL: JFC_XXDL;
    saTitle:='Logged entries this call: TCONTEXT.LogXXDL';
    saMessage:=LogXXDL.saHTMLTable;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;

    //JASPrintln(saOut);
  end;//  if(iDebugMode <> cnSYS_INFO_MODE_SECURE) then
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102596,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



//=============================================================================
{}
function TCONTEXT.bRedirection: boolean;
//=============================================================================
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='function TCONTEXT.bRedirection: boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203311218,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203311219, sTHIS_ROUTINE_NAME);{$ENDIF}

  result:= (CGIENV.uHttpREsponse>=300) and (CGIENV.uHttpREsponse<400);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203311220,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
{}
function TCONTEXT.bLoadXDLForMerge(
  p_sTable: string;
  p_u8UID: uint64;
  p_XDL: JFC_XDL;
  var p_uDupeScore: cardinal
): boolean;
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  u8TableID: uint64;
  sTablePKeyColName: string;
  sTableColPrefix: string;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bLoadXDLForMerge'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201204091603,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201204091604, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=VHDBC;
  rs:=JADO_RECORDSET.create;
  u8TableID:=DBC.u8GetTableID(p_sTable,201210012303);

  // ----- GET TABLE DUPE SCORE
  saQry:='SELECT JTabl_DupeScore_u, JTabl_ColumnPrefix from jtable where JTabl_JTable_UID='+DBC.sDBMSUIntScrub(u8TableID);
  bOk:=rs.open(saQry, DBC,201503161747);
  if not bOk then
  begin
    JAS_LOG(self, cnLog_Error, 201204091617, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC,rs);
  end;
  if bOk then
  begin
    bOk:=not rs.eol;
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201204091618, 'Expected record non-existant.','Query: '+saQry, SOURCEFILE, DBC,rs);
    end;
  end;
  if bOk then
  begin
    p_uDupeScore:=u4Val(rs.fields.Get_saValue('JTabl_DupeScore_u'));
    sTableColPrefix:=rs.fields.Get_saValue('JTabl_ColumnPrefix');
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select JColu_Name, JColu_Weight_u, JColu_PrimaryKey_b from jcolumn '+
      'where JColu_JTable_ID='+DBC.sDBMSUIntScrub(u8TableID)+' AND JColu_Deleted_b<>'+
      DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161748);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201204091619, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201204091620, 'Expected record(s) non-existant.','Query: '+saQry, SOURCEFILE, DBC,rs);
    end;
  end;

  if bOk then
  begin
    p_XDL.Deleteall;
    repeat
      p_XDL.AppendItem_saName(rs.fields.Get_saValue('JColu_Name'));
      p_XDL.Item_i8User:=u8Val(rs.fields.Get_saValue('JColu_Weight_u'));
      if bVal(rs.fields.Get_saValue('JColu_PrimaryKey_b')) then
        sTablePKeyColName:=rs.fields.Get_saValue('JColu_Name');
    until not rs.movenext;
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select * from '+DBC.sDBMSEncloseObjectName(p_sTable)+' where '+DBC.sDBMSEncloseObjectName(sTablePkeyColName)+'='+DBC.sDBMSUIntScrub(p_u8UID);
    if DBC.bColumnExists(p_sTable,sTableColPrefix+'_Deleted_b',201210020035) then
    begin
      saQry+= ' AND '+sTableColPrefix+'_Deleted_b<>'+DBC.sDBMSBoolScrub(True);
    end;
    bOk:=rs.Open(saQry, DBC,201503161748);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201204091621, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      bOk:=true;
      JAS_LOG(self, cnLog_Warn, 201204091622, 'Import - Expected record(s) non-existant.','Query: '+saQry, SOURCEFILE, DBC,rs);
    end;
  end;

  if bOk then
  begin
    if p_XDL.MoveFirst then
    begin
      repeat
        if rs.fields.founditem_saName(p_XDL.Item_saName) then
        begin
          p_XDL.Item_saValue:=rs.fields.Item_saValue;
        end;
      until not p_XDL.MoveNext;
    end;
  end;
  rs.close;
  rs.destroy;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201204091605,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
function TCONTEXT.bPopulateLookUpList(
  p_sTableName: string;
  p_sColumnName: string;
  ListXDL: JFC_XDL;
  p_sDefaultValue: string;
  p_bLookUp: boolean
):boolean;
//=============================================================================
var
  bOk: Boolean;
  //u2JWidgetID: Word;
  sDelColumn: string;
  bDelColumnExists: Boolean;
  saQry: ansistring;//dont want to over the saQry that part of this class
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  //saWhere: ansistring;
  sLU_JColumn_ID: string;
  saLU_LUF_Value: ansistring;
  //--
  saLD_Column_SQL: ansistring;
  bLD_CaptionRules: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TCONTEXT.bPopulateLookUpList'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201204122351,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201204122352, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=VHDBC;
  rs:=JADO_RECORDSET.CREATE;

  ListXDL.DeleteAll; //caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
  if not p_bLookUp then // COMBOBOX STYLE
  begin
    sDelColumn:=DBC.sGetColumnPrefix(inttostr(DBC.u8GetTableID(p_sTableName,201210012304)))+'_Deleted_b';
    bDelColumnExists:=DBC.bColumnExists(p_sTableName, p_sColumnName, 201210020036);
    saQry:='select ' + p_sColumnName + ' from ' + p_sTableName;
    if bDelColumnExists then saQry+=' WHERE '+sDelColumn+'<>'+DBC.sDBMSBoolScrub(true)+' ';
    saQry+='order by ' + p_sColumnName;
    bOk:=rs.open(saQry,DBC,201503161749);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204122353,'TCONTEXT.bPopulateLookUpList had trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;

    if bOk then
    begin
      ListXDL.Appenditem;
      ListXDL.Item_saName:='';//caption (seen)
      ListXDL.Item_saValue:='';//value (returned)
      ListXDL.Item_i8User:=b00;//caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default

      ListXDL.Appenditem;
      ListXDL.Item_saName:='NULL';//caption (seen)
      ListXDL.Item_saValue:='NULL';//value (returned)
      ListXDL.Item_i8User:=b00;//caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default

      //ListXDL.Appenditem;
      //ListXDL.Item_saName:='0 - Zero';//caption (seen)
      //ListXDL.Item_saValue:='0';//value (returned)
      //ListXDL.Item_i8User:=b00;//caption (seen)//value (returned)// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default



      if rs.eol=false then
      begin
        repeat
          if false=ListXDL.FoundItem_saValue(rs.fields.Get_saValue(p_sColumnName)) then
          begin
            ListXDL.Appenditem;
            ListXDL.Item_saName:=rs.fields.Get_saValue(p_sColumnName);//caption (seen)
            ListXDL.Item_saValue:=rs.fields.Get_saValue(p_sColumnName);//value (returned)
            ListXDL.Item_i8User:=b00;
          end;
        until (not rs.movenext);
      end;
    end;
    rs.close;
  end
  else
  begin
    //------------------------------------------ GET INFORMATION ABOUT LOOK UP
    saQry:='SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE '+
      'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'JColu_JTable_ID='+DBC.sDBMSUIntScrub(DBC.u8GetTableID(p_sTableName,201210012305))+' AND '+
      'JColu_Name='+DBC.saDBMSScrub(p_sColumnName);
    bOk:=rs.Open(saQry,DBC,20150316175);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204122354,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;

    if bOk then
    begin
      bOk:=(not rs.eol);
      if not bOk then
      begin
        JAS_Log(self,cnLog_Warn,201204122355,'Unable to load lookup column for column: '+p_sColumnName,'',SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      sLU_JColumn_ID:=rs.fields.Get_saValue('JColu_LU_JColumn_ID');
      saLU_LUF_Value:=rs.fields.Get_saValue('JColu_LUF_Value');
    end;
    rs.close;
    //------------------------------------------GET INFORMATION ABOUT LOOK UP


    //------------------------------------------LOAD LOOKUP SQL FROM TARGET
    saQry:='SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
      'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'JColu_JColumn_UID='+DBC.sDBMSUIntScrub(sLU_JColumn_ID);
    bOk:=rs.Open(saQry,DBC,201503161752);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204130006,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;

    if bOk then
    begin
      bOk:=(not rs.eol);
      if not bOk then
      begin
        JAS_Log(self,cnLog_Warn,201204130007,'Unable to load target lookup column UID: '+sLU_JColumn_ID,'',SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      saLD_Column_SQL:=rs.fields.Get_saValue('JColu_LD_SQL');
      bLD_CaptionRules:=bVal(rs.fields.Get_saValue('JColu_LD_CaptionRules_b'));
    end;
    rs.close;
    //------------------------------------------LOAD LOOKUP SQL FROM TARGET

    if saLU_LUF_Value='NULL' then saLU_LUF_Value:='';
    saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value);
    if bLD_CaptionRules then
    begin
      saQry:=saSNRStr(saQry, '[@LANG@]',sLang);
    end;
    bOk:=rs.open(saQry,DBC,201503161753);

    //JAS_Log(self,nLog_Debug,201204142034,'Lookup QUERY: '+saQry,'',SOURCEFILE);


    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204122356,'TCONTEXT.bPopulateLookUpList had trouble with query. '+
        'Column Name: '+p_sColumnName+' saLD_Column_SQL: '+saLD_Column_SQL+' '+
        'saLU_LUF_Value: '+saLU_LUF_Value,
        'Query: '+saQry,SOURCEFILE,DBC,rs);
    end;

    if bOk then
    begin
      ListXDL.Appenditem;
      ListXDL.Item_saName:='';//caption (seen)
      ListXDL.Item_saValue:='';//value (returned)
      ListXDL.Item_i8User:=b00;//selectable

      ListXDL.Appenditem;
      ListXDL.Item_saName:='NULL';//caption (seen)
      ListXDL.Item_saValue:='NULL';//value (returned)
      ListXDL.Item_i8User:=b00;//selectable

      if rs.eol=false then
      begin
        repeat
          if false=ListXDL.FoundItem_saValue(rs.fields.Get_saValue('ColumnValue')) then
          begin
            ListXDL.Appenditem;
            ListXDL.Item_saName:=rs.fields.Get_saValue('DisplayMe');//caption (seen)
            ListXDL.Item_saValue:=rs.fields.Get_saValue('ColumnValue');//value (returned)
            ListXDL.Item_i8User:=b00;// i8User bit flags: (b00)1=selectable, (b01)2=selected, (b02)4=default
          end;
        until (not rs.movenext);
      end;
    end;
    rs.close;
  end;

  if ListXDL.founditem_saValue(p_sDefaultValue) then begin
    if (ListXDL.Item_i8User and b02)=0 then ListXDL.Item_i8User:=ListXDL.Item_i8User+b02;
    if (ListXDL.Item_i8User and b01)=0 then ListXDL.Item_i8User:=ListXDL.Item_i8User+b01;
  end;


  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201204122357,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
function TCONTEXT.saLookUp(
  p_sTableName: string;
  p_sColumnName: string;
  p_saValue: ansistring
): ansistring;
//=============================================================================
var
  bOk: Boolean;
  //u2JWidgetID: word;
  DBC: JADO_CONNECTION;
  saQry: ansistring;//dont want to over the saQry that part of this class
  rs: JADO_RECORDSET;

  LU_JColumn_ID: uint64;
  saLU_LUF_Value: ansistring;
  //--
  saLD_Column_SQL: ansistring;
  bLD_CaptionRules: boolean;
  LU_PKeyID: uint64;
  LU_JTable_ID: uint64;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TCONTEXT.saLookUp'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203201821,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203201822, sTHIS_ROUTINE_NAME);{$ENDIF}
  result:='';
  DBC:=VHDBC;
  rs:=JADO_RECORDSET.CREATE;

  //------------------------------------------ GET INFORMATION ABOUT LOOK UP
  saQry:='SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    'JColu_JTable_ID='+DBC.sDBMSUIntScrub(DBC.u8GetTableID(p_sTableName,201210012305))+' AND '+
    'JColu_Name='+DBC.saDBMSScrub(p_sColumnName);
  bOk:=rs.Open(saQry,DBC,201503161754);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201204122354,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204122355,'Unable to load lookup column for column: '+p_sColumnName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    LU_JColumn_ID:=u8Val(rs.fields.Get_saValue('JColu_LU_JColumn_ID'));
    saLU_LUF_Value:=rs.fields.Get_saValue('JColu_LUF_Value');
  end;
  rs.close;
  //------------------------------------------GET INFORMATION ABOUT LOOK UP


  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  saQry:='SELECT JColu_JTable_ID, JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    'JColu_JColumn_UID='+DBC.sDBMSUIntScrub(LU_JColumn_ID);
  bOk:=rs.Open(saQry,DBC,201503161755);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201204130006,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201204130007,'Unable to load target lookup column UID: '+inttostr(LU_JColumn_ID),'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    LU_JTable_ID:=u8Val(rs.fields.Get_saValue('JColu_JTable_ID'));
    saLD_Column_SQL:=rs.fields.Get_saValue('JColu_LD_SQL');
    bLD_CaptionRules:=bVal(rs.fields.Get_saValue('JColu_LD_CaptionRules_b'));
  end;
  rs.close;
  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  LU_PKeyID:=DBC.u8GetPKeyColumnWTableID(LU_JTable_ID,201210020155);
  if saLU_LUF_Value='NULL' then saLU_LUF_Value:='';
  saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value + '[@LOOKUP@]');
  saQry:=saSNRStr(saQry,'[@LOOKUP@]',' AND '+inttostr(LU_PKeyID)+'='+p_saValue);
  if bLD_CaptionRules then
  begin
    saQry:=saSNRStr(saQry, '[@LANG@]',sLang);
  end;
  bOk:=rs.open(saQry,DBC,201503161757);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201203260948,'TCONTEXT.saLookUp had trouble with query. Lang: '+sLang,'Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      result:=rs.fields.Get_saValue('DisplayMe');
    end
    else
    begin
      result:='[ '+p_saValue+' ]';
    end;
  end;
  rs.close;
  rs.destroy;
  if not bOk then Result:='(JWidget Troubles)';
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203201821,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



















//=============================================================================
function TCONTEXT.saLookUpSQL(
  p_sTableName: string;
  p_sColumnName: string;
  var p_sLUTableName: string
): ansistring;
//=============================================================================
var
  bOk: Boolean;
  //u2JWidgetID: word;
  DBC: JADO_CONNECTION;
  saQry: ansistring;//dont want to over the saQry that part of this class
  rs: JADO_RECORDSET;

  LU_JColumn_ID: uInt64;
  saLU_LUF_Value: ansistring;
  //--
  saLD_Column_SQL: ansistring;
  bLD_CaptionRules: boolean;
  //sLU_PKey: string;
  LU_JTable_ID: uInt64;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TCONTEXT.saLookUpSQL'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201205150123,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201205150124, sTHIS_ROUTINE_NAME);{$ENDIF}
  result:='';
  DBC:=VHDBC;
  rs:=JADO_RECORDSET.CREATE;

  //------------------------------------------ GET INFORMATION ABOUT LOOK UP
  saQry:='SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    'JColu_JTable_ID='+DBC.sDBMSUIntScrub(DBC.u8GetTableID(p_sTableName,201210012306))+' AND '+
    'JColu_Name='+DBC.saDBMSScrub(p_sColumnName);
  bOk:=rs.Open(saQry,DBC,201503161758);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201205150125,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201205150126,'EOL - No Rows for lookup column for column: '+p_sColumnName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    LU_JColumn_ID:=u8val(rs.fields.Get_saValue('JColu_LU_JColumn_ID'));
    saLU_LUF_Value:=rs.fields.Get_saValue('JColu_LUF_Value');
  end;
  rs.close;
  //------------------------------------------GET INFORMATION ABOUT LOOK UP


  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  saQry:='SELECT JColu_JTable_ID, JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    'JColu_JColumn_UID='+DBC.sDBMSUIntScrub(LU_JColumn_ID);
  bOk:=rs.Open(saQry,DBC,201503161759);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201205150127,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_Log(self,cnLog_Warn,201205150128,'Unable to load target lookup column UID: '+inttostr(LU_JColumn_ID),'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    LU_JTable_ID:=u8Val(rs.fields.Get_saValue('JColu_JTable_ID'));
    saLD_Column_SQL:=rs.fields.Get_saValue('JColu_LD_SQL');
    bLD_CaptionRules:=bVal(rs.fields.Get_saValue('JColu_LD_CaptionRules_b'));
    p_sLUTableName:=DBC.sGetTable(LU_JTable_ID,201608191904);
  end;
  rs.close;
  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  //sLU_PKey:=JAS.saGetPKeyColumnNameWTableID(pointer(JAS),sLU_JTable_ID);
  if saLU_LUF_Value='NULL' then saLU_LUF_Value:='';
  saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value);
  //saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value + '[@LOOKUP@]');
  //saQry:=saSNRStr(saQry,'[@LOOKUP@]',' AND '+sLU_PKey+'='+p_saValue);
  if bLD_CaptionRules then
  begin
    saQry:=saSNRStr(saQry, '[@LANG@]',sLang);
  end;

  if bOk then
  begin
    result:=saQry
  end
  else
  begin
    Result:='';
  end;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201205150129,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

































//=============================================================================
Procedure TCONTEXT.CreateIWFXML;
//=============================================================================
{$IFDEF ROUTINENAMES} var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='CreateIWFXML'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102756,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102757, sTHIS_ROUTINE_NAME);{$ENDIF}

  if(CGIENV.uHTTPResponse=0)then
  begin
    // nothing process - say as much - as error
    JAS_LOG(self,cnLog_Error,200912100012,'CreateIWFXML - HTTP Response not set in API call:'+sFileNameOnlyNoExt,'',SOURCEFILE);
    XML.DeleteAll;//wipe outgoing data for safety
  end;

  DebugXMLOutput;
  //iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  bOutputRaw:=true;
  saPage+='<?xml version="1.0" encoding="UTF-8" ?>' + csCRLF;
  saPage+='<response>'+csCRLF;
  saPage+='  <action type="'+saHTMLSCRUB(sActionType)+'" errorCode="'+inttostr(u8ErrNo)+'" errorMessage="'+saHTMLScrub(saErrMsg)+'" >'+csCRLF;// + csLF;
  if(UpperCase(sActionType)='JAVASCRIPT')then
  begin
    saPage+='<![CDATA[';
    if(XML.MoveFirst)then
    begin
      repeat
        saPage+=XML.Item_saValue;
      until not XML.MoveNext;
    end;
    saPage+=']]>';
  end
  else
  begin
    saPage+=XML.saXML(false,false);
  end;
  saPage+='  </action>' + csCRLF;
  //if rJUser.JUser_Admin_b or (iDebugMode = cnSYS_INFO_MODE_VERBOSE) or
  //  (iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL) then
  if (u2DebugMode = cnSYS_INFO_MODE_VERBOSE) or
     (u2DebugMode = cnSYS_INFO_MODE_VERBOSELOCAL) then
  begin
    saPage+='<errorinfo>'+saHTMLSCrub(saErrMsgMoreInfo)+'</errorinfo>'+csCRLF;
  end;
  saPage+='</response>' + csCRLF+csCRLF+csCRLF;
  //saMimeType:=csMIME_TextXml; Done previous so MIME override possible.

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102758,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






















//=============================================================================
{}
// Dumps debug information as XDL node data into Context.DataXDL as a new node
// named JASDEBUDINFO.
procedure TCONTEXT.DebugXMLOutput;
//=============================================================================
var
  i: integer;
  xmlContext: JFC_XML;
  xmlJASDebugXMLOutput: JFC_XML;
  xmlJASConfig: JFC_XML;
  xmlNode: JFC_XML;
  xmlNode2: JFC_XML;
  xmlNode3: JFC_XML;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TCONTEXT.DebugXMLOutput'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102687,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102688, sTHIS_ROUTINE_NAME);{$ENDIF}


  if(u2DebugMode <> cnSYS_INFO_MODE_SECURE) and
    ((((rJSession.JSess_IP_ADDR='127.0.0.1') or (rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND (u2DebugMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
     (u2DebugMode = cnSYS_INFO_MODE_VERBOSELOCAL) ) then
  begin
    xmlJASDebugXMLOutput:=JFC_XML.create;
    xmlJASDebugXMLOutput.bDestroyNestedLists:=true;
    xmlJASDebugXMLOutput.bShowNestedLists:=true;

    //=====================================================
    // TODO: replace jasconfig in context.debugxmloutput
    // TODO: replace jdbcon in context.debugxmloutput
    // TODO: replace MATRIX in context.debugxmloutput
    // TODO: replace CGIENV in context.debugxmloutput
    // TODO: replace rJUser in context.debugxmloutput
    // TODO: replace rJSession in context.debugxmloutput
    // TODO: replace SessionXDL in context.debugxmloutput
    // TODO: replace PAGESNRXDL in context.debugxmloutput
    // TODO: replace REQVAR_XDL in context.debugxmloutput
    // TODO: replace LogXXDL in context.debugxmloutput
    //=====================================================


    // BEGIN ------------------------ JASConfig
    xmlJASConfig:=JFC_XML.Create;
    xmlJASConfig.bDestroyNestedLists:=true;
    xmlJASConfig.bShowNestedLists:=true;
    if self.u2VHost=0 then
    begin

      //=========================================================================
      xmlJASConfig.AppendItem_saName_N_saValue('saSysDir',grJASConfig.saSysDir); //< Directory where JAS is installed
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_FileDir',garJVhost[self.u2VHost].VHost_FileDir);
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_WebshareDir',garJVhost[self.u2VHost].VHost_WebshareDir);
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_CacheDir',garJVhost[self.u2VHost].VHost_CacheDir);
      //xmlJASConfig.AppendItem_saName_N_saValue('VHost _LogDir',garJVhost[self.u2VHost].VHost _LogDir);
      //xmlJASConfig.AppendItem_saName_N_saValue('VHost _ThemeDir',garJVhost[self.u2VHost].VHost _ThemeDir);//os location
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_WebRootDir',garJVhost[self.u2VHost].VHost_WebRootDir); // actual file system path to default webroot
      xmlJASConfig.AppendItem_saName_N_saValue('saPHPDir',grJASConfig.saPHPDir);
      // Physical Dir -------------------------------------------------------------
      
      // Filenames ----------------------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('saPHP',grJASConfig.saPHP); //< Full Path to PHP php-cgi.exe for launching CGI based PHP
      xmlJASConfig.AppendItem_saName_N_saValue('saPerl',grJASConfig.saPerl); //< Full Path to Perl exe for launching CGI based Perl
      xmlJASConfig.AppendItem_saName_N_saValue('saJASFooter',grJASConfig.saJASFooter);
      // Filenames ----------------------------------------------------------------
      
      
      // Web Paths ----------------------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('saWebShareAlias',garJVHost[self.u2VHost].VHost_WebShareAlias); //< Aliased Directory "webshare". Usually: jws
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_JASDirTheme',garJVHost[self.u2VHost].VHost_JASDirTheme);//web view
      // Web Paths ----------------------------------------------------------------
      
      // Misc Settings ----------------------------------------------------------
      //xmlJASConfig.AppendItem_saName_N_saValue('sServerURL',grJASConfig.sServerURL);// should not have trailing slash
      //xmlJASConfig.AppendItem_saName_N_saValue('sServerName',grJASConfig.sServerName);
      xmlJASConfig.AppendItem_saName_N_saValue('sServerIdent',grJASConfig.sServerIdent);
      xmlJASConfig.AppendItem_saName_N_saValue('sServerSoftware',grJASConfig.sServerSoftware);//<not a config thing as much as vari is more space efficient than constants in exe creation (same string repeated all over in binary executable)
      xmlJASConfig.AppendItem_saName_N_saValue('saDefaultArea',garJVHost[self.u2VHost].VHost_DefaultArea);
      xmlJASConfig.AppendItem_saName_N_saValue('saDefaultPage',garJVHost[self.u2VHost].VHost_DefaultPage);
      xmlJASConfig.AppendItem_saName_N_saValue('saDefaultSection',garJVHost[self.u2VHost].VHost_DefaultSection);
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_PasswordKey_u1',inttostr(garJVHost[self.u2VHost].VHost_PasswordKey_u1));
      xmlJASConfig.AppendItem_saName_N_saValue('sDefaultLanguage',grJASConfig.sDefaultLanguage); //< DEFAULT should be 'en' for english naturally. Note: In filenames, and code - lowercase. In JAS MySQL jcaption table, upper case for field names. e.g. JCapt_EN = English Caption
      xmlJASConfig.AppendItem_saName_N_saValue('u1DefaultMenuRenderMethod',inttostr(grJASConfig.u1DefaultMenuRenderMethod));
      xmlJASConfig.AppendItem_saName_N_saValue('sServerIP',saHTMLSCrub(grJASConfig.sServerIP));
      xmlJASConfig.AppendItem_saName_N_saValue('u2ServerPort',inttostr(grJASConfig.u2ServerPort));
      xmlJASConfig.AppendItem_saName_N_saValue('u2RetryLimit',inttostr(grJASConfig.u2RetryLimit));
      xmlJASConfig.AppendItem_saName_N_saValue('u4RetryDelayInMSec',inttostr(grJASConfig.u4RetryDelayInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('i1TIMEZONEOFFSET',inttostr(grJASConfig.i1TIMEZONEOFFSET));
      xmlJASConfig.AppendItem_saName_N_saValue('u4MaxFileHandles',inttostr(grJASConfig.u4MaxFileHandles));//< NOT OS FILEHANDLES! Max Reservations for Jegas Threadsafe File Handles.
      xmlJASConfig.AppendItem_saName_N_saValue('bBlacklistEnabled',sTrueFalse(grJASConfig.bBlacklistEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('bWhiteListEnabled',sTrueFalse(grJASConfig.bWhiteListEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('bBlacklistIPExpire',sTrueFalse(grJASConfig.bBlacklistIPExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('bWhitelistIPExpire',sTrueFalse(grJASCOnfig.bWhitelistIPExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('bInvalidLoginsExpire',sTrueFalse(grJASCOnfig.bInvalidLoginsExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('u2BlacklistDaysUntilExpire',inttostr(grJASConfig.u2BlacklistDaysUntilExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('u2WhitelistDaysUntilExpire',inttostr(grJASConfig.u2WhitelistDaysUntilExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('u2InvalidLoginsDaysUntilExpire',inttostr(grJASConfig.u2InvalidLoginsDaysUntilExpire));
      xmlJASConfig.AppendItem_saName_N_saValue('bJobQEnabled',sTrueFalse(grJASConfig.bJobQEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('u4JobQIntervalInMSec',inttostr(grJASConfig.u4JobQIntervalInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_DefaultTop_JMenu_ID',inttostr(garJVHost[self.u2VHost].VHost_DefaultTop_JMenu_ID));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_DirectoryListing_b',sTrueFalse(garJVHost[self.u2VHost].VHost_DirectoryListing_b));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_DataOnRight_b',sYesNo(garJVHost[self.u2VHost].VHost_DataOnRight_b));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_CacheMaxAgeInSeconds',inttostr(garJVHost[self.u2VHost].VHost_CacheMaxAgeInSeconds));
      xmlJASConfig.AppendItem_saName_N_saValue('sSMTPHost',grJASConfig.sSMTPHost);
      xmlJASConfig.AppendItem_saName_N_saValue('sSMTPUsername',grJASConfig.sSMTPUsername);
      xmlJASConfig.AppendItem_saName_N_saValue('sSMTPPassword','Withheld');
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_SystemEmailFromAddress',garJVHost[self.u2VHost].VHost_SystemEmailFromAddress);
      xmlJASConfig.AppendItem_saName_N_saValue('bProtectJASRecords',sTrueFalse(grJASConfig.bProtectJASRecords));
      xmlJASConfig.AppendItem_saName_N_saValue('bSafeDelete',sTrueFalse(grJASConfig.bSafeDelete));
      xmlJASConfig.AppendItem_saName_N_saValue('bAllowVirtualHostCreation',sTrueFalse(grJASConfig.bAllowVirtualHostCreation));
      // Misc Settings ----------------------------------------------------------
      
      // Punk-Be-Gone -----------------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('bPunkBeGoneEnabled',sTrueFalse(grJASConfig.bPunkBeGoneEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('u2PunkBeGoneMaxErrors',inttostr(grJASConfig.u2PunkBeGoneMaxErrors));
      xmlJASConfig.AppendItem_saName_N_saValue('u2PunkBeGoneMaxMinutes',inttostr(grJASConfig.u2PunkBeGoneMaxMinutes));
      xmlJASConfig.AppendItem_saName_N_saValue('u4PunkBeGoneIntervalInMSec',inttostr(grJASConfig.u4PunkBeGoneIntervalInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('u2PunkBeGoneIPHoldTimeInDays',inttostr(grJASConfig.u2PunkBeGoneIPHoldTimeInDays));
      xmlJASConfig.AppendItem_saName_N_saValue('u2PunkBeGoneMaxDownloads',inttostr(grJASConfig.u2PunkBeGoneMaxDownloads));
      // Punk-Be-Gone -----------------------------------------------------------
      
      // Error and Log Settings -------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_LogToDataBase_b',sTrueFalse(garJVHost[self.u2VHost].VHost_LogToDataBase_b));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_LogRequestsToDatabase_b',sTrueFalse(garJVHost[self.u2VHost].VHost_LogRequestsToDatabase_b));
      xmlJASConfig.AppendItem_saName_N_saValue('bSQLTraceLogEnabled',sTrueFalse(grJASCOnfig.bSQLTraceLogEnabled));
      // Error and Log Settings -------------------------------------------------
      
      // Session and Record Locking ---------------------------------------------
      
      // Threading --------------------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('u2ThreadPoolNoOfThreads',inttostr(grJASConfig.u2ThreadPoolNoOfThreads));
      xmlJASConfig.AppendItem_saName_N_saValue('uThreadPoolMaximumRunTimeInMSec',inttostr(grJASConfig.uThreadPoolMaximumRunTimeInMSec));
      // Threading --------------------------------------------------------------
      
      // Error and Log Settings -------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('u2LogLevel',inttostr(grJASConfig.u2LogLevel));
      xmlJASConfig.AppendItem_saName_N_saValue('VHost_LogToConsole_b',sTrueFalse(garJVHost[self.u2VHost].VHost_LogToConsole_b));
      xmlJASConfig.AppendItem_saName_N_saValue('bDeleteLogFile',sTrueFalse(grJASConfig.bDeleteLogFile));
      xmlJASConfig.AppendItem_saName_N_saValue('u2ErrorReportingMode',inttostr(grJASConfig.u2ErrorReportingMode));
      xmlJASConfig.AppendItem_saName_N_saValue('saErrorReportingSecureMessage',grJASConfig.saErrorReportingSecureMessage);
      xmlJASConfig.AppendItem_saName_N_saValue('bServerConsoleMessagesEnabled',sTrueFalse(grJASConfig.bServerConsoleMessagesEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('bDebugServerConsoleMessagesEnabled',sTrueFalse(grJASConfig.bDebugServerConsoleMessagesEnabled));
      xmlJASConfig.AppendItem_saName_N_saValue('u2DebugMode',inttostr(grJASConfig.u2DebugMode));
      // Error and Log Settings -------------------------------------------------
      
      // Session and Record Locking ---------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('u2SessionTimeOutInMinutes',inttostr(grJASConfig.u2SessionTimeOutInMinutes));
      xmlJASConfig.AppendItem_saName_N_saValue('u2LockTimeOutInMinutes',inttostr(grJASConfig.u2LockTimeOutInMinutes));
      xmlJASConfig.AppendItem_saName_N_saValue('u2LockRetriesBeforeFailure',inttostr(grJASConfig.u2LockRetriesBeforeFailure));
      xmlJASConfig.AppendItem_saName_N_saValue('u2LockRetryDelayInMSec',inttostr(grJASConfig.u2LockRetryDelayInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('u2ValidateSessionRetryLimit',inttostr(grJASConfig.u2ValidateSessionRetryLimit));
      // Session and Record Locking ---------------------------------------------
      
      // IP Protocol Related ----------------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('uMaximumRequestHeaderLength',inttostr(grJASConfig.uMaximumRequestHeaderLength));
      xmlJASConfig.AppendItem_saName_N_saValue('u2CreateSocketRetry',inttostr(grJASConfig.u2CreateSocketRetry));
      xmlJASConfig.AppendItem_saName_N_saValue('u2CreateSocketRetryDelayInMSec',inttostr(grJASConfig.u2CreateSocketRetryDelayInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('u2SocketTimeOutInMSec',inttostr(grJASConfig.u2SocketTimeOutInMSec));
      xmlJASConfig.AppendItem_saName_N_saValue('bEnableSSL',sTrueFalse(grJASConfig.bEnableSSL));
      // IP Protocol Related ----------------------------------------------------
      
      // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
      // Programmable Session Custom Hooks - Names for Actions that might
      // be coded into the u01g_sessions file. Useful for working with
      // integrated systems.
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_CREATESESSION_FAILURE',grJASConfig.sHOOK_ACTION_CREATESESSION_FAILURE);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_CREATESESSION_SUCCESS',grJASConfig.sHOOK_ACTION_CREATESESSION_SUCCESS);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_REMOVESESSION_FAILURE',grJASConfig.sHOOK_ACTION_REMOVESESSION_FAILURE);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_REMOVESESSION_SUCCESS',grJASConfig.sHOOK_ACTION_REMOVESESSION_SUCCESS);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_SESSIONTIMEOUT',grJASConfig.sHOOK_ACTION_SESSIONTIMEOUT);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_VALIDATESESSION_FAILURE',grJASConfig.sHOOK_ACTION_VALIDATESESSION_FAILURE);
      xmlJASConfig.AppendItem_saName_N_saValue('sHOOK_ACTION_VALIDATESESSION_SUCCESS',grJASConfig.sHOOK_ACTION_VALIDATESESSION_SUCCESS);
      xmlJASConfig.AppendItem_saName_N_saValue('sClientToVICIServerIP',grJASConfig.sClientToVICIServerIP);
      xmlJASConfig.AppendItem_saName_N_saValue('sJASServertoVICIServerIP',grJASConfig.sJASServertoVICIServerIP);
      // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
      xmlJASConfig.AppendItem_saName_N_saValue('bCreateHybridJets',sTrueFalse(grJASConfig.bCreateHybridJets));
      xmlJASConfig.AppendItem_saName_N_saValue('bRecordLockingEnabled',sTrueFalse(grJASConfig.bRecordLockingEnabled));
    end;


    xmlJASConfig.AppendItem_saName_n_saValue('VHost_AllowRegistration_b',    sYesNo(garJVHost[self.u2VHost].VHost_AllowRegistration_b       ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_RegisterReqCellPhone_b', sYesNo(garJVHost[self.u2VHost].VHost_RegisterReqCellPhone_b    ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_RegisterReqBirthday_b',  sYesNo(garJVHost[self.u2VHost].VHost_RegisterReqBirthday_b     ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_JVHost_UID',             inttostr(garJVHost[self.u2VHost].VHost_JVHost_UID                ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_WebRootDir',             garJVHost[self.u2VHost].VHost_WebRootDir                );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ServerName',             garJVHost[self.u2VHost].VHost_ServerName                );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ServerIdent',            garJVHost[self.u2VHost].VHost_ServerIdent               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ServerURL',              garJVHost[self.u2VHost].VHost_ServerURL                 );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ServerDomain',           garJVHost[self.u2VHost].VHost_ServerDomain              );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultLanguage',        garJVHost[self.u2VHost].VHost_DefaultLanguage           );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultTheme',           garJVHost[self.u2VHost].VHost_DefaultTheme              );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_MenuRenderMethod',       inttostr(garJVHost[self.u2VHost].VHost_MenuRenderMethod          ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultArea',            garJVHost[self.u2VHost].VHost_DefaultArea               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultPage',            garJVHost[self.u2VHost].VHost_DefaultPage               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultSection',         garJVHost[self.u2VHost].VHost_DefaultSection            );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultTop_JMenu_ID',    inttostr(garJVHost[self.u2VHost].VHost_DefaultTop_JMenu_ID)       );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultLoggedInPage',    garJVHost[self.u2VHost].VHost_DefaultLoggedInPage       );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultLoggedOutPage',   garJVHost[self.u2VHost].VHost_DefaultLoggedOutPage      );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DataOnRight_b',          sYesNo(garJVHost[self.u2VHost].VHost_DataOnRight_b             ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_CacheMaxAgeInSeconds',   inttostr(garJVHost[self.u2VHost].VHost_CacheMaxAgeInSeconds      ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_SystemEmailFromAddress', garJVHost[self.u2VHost].VHost_SystemEmailFromAddress    );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_SharesDefaultDomain_b',  sYesNo(garJVHost[self.u2VHost].VHost_SharesDefaultDomain_b     ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DefaultIconTheme',       garJVHost[self.u2VHost].VHost_DefaultIconTheme          );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_DirectoryListing_b',     sYesNo(garJVHost[self.u2VHost].VHost_DirectoryListing_b        ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_FileDir',                garJVHost[self.u2VHost].VHost_FileDir                   );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_AccessLog',              garJVHost[self.u2VHost].VHost_AccessLog                 );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ErrorLog',               garJVHost[self.u2VHost].VHost_ErrorLog                  );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_JDConnection_ID',        inttostr(garJVHost[self.u2VHost].VHost_JDConnection_ID           ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_Enabled_b',              sYesNo(garJVHost[self.u2VHost].VHost_Enabled_b                 ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_TemplateDir',            garJVHost[self.u2VHost].VHost_TemplateDir               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_SipURL',                 garJVHost[self.u2VHost].VHOST_SipURL                    );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_CacheDir',               garJVHost[self.u2VHost].VHOST_CacheDir                  );
    //xmlJASConfig.AppendItem_saName_n_saValue('VHOST _LogDir',                 garJVHost[self.u2VHost].VHOST _LogDir                    );
    //xmlJASConfig.AppendItem_saName_n_saValue('VHOST _ThemeDir',               garJVHost[self.u2VHost].VHOST _ThemeDir                  );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_WebshareDir',            garJVHost[self.u2VHost].VHOST_WebshareDir               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_WebShareAlias',          garJVHost[self.u2VHost].VHOST_WebShareAlias             );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_JASDirTheme',            garJVHost[self.u2VHost].VHOST_JASDirTheme               );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_DefaultArea',           garJVHost[self.u2VHost].VHOST_DefaultArea              );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_DefaultPage',           garJVHost[self.u2VHost].VHOST_DefaultPage              );
    xmlJASConfig.AppendItem_saName_n_saValue('VHOST_DefaultSection',        garJVHost[self.u2VHost].VHOST_DefaultSection           );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_LogToDataBase_b',        sYesNo(garJVHost[self.u2VHost].VHost_LogToDataBase_b           ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_LogToConsole_b',         sYesNo(garJVHost[self.u2VHost].VHost_LogToConsole_b            ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_LogRequestsToDatabase_b',sYesNo(garJVHost[self.u2VHost].VHost_LogRequestsToDatabase_b   ));
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_AccessLog'       ,garJVHost[self.u2VHost].VHost_AccessLog          );
    xmlJASConfig.AppendItem_saName_n_saValue('VHost_ErrorLog'        ,garJVHost[self.u2VHost].VHost_ErrorLog           );


    xmlJASDebugXMLOutput.appenditem_lpPtr(xmlJASConfig);
    xmlJASDebugXMLOutput.Item_saName:='JASConfig';
    // END -------------------------- JASConfig





    // BEGIN ------------------------ Context
    xmlContext:=JFC_XML.Create;
    xmlContext.bDestroyNestedLists:=true;
    xmlContext.bShowNestedLists:=true;

    xmlContext.AppendItem_saName_N_saValue('bSessionValid',sTrueFalse(bSessionValid));
    xmlContext.AppendItem_saName_N_saValue('bErrorCondition',sTrueFalse(bErrorCondition));
    xmlContext.AppendItem_saName_N_saValue('u8ErrNo',inttostr(u8ErrNo));
    xmlContext.AppendItem_saName_N_saValue('saErrMsg',saErrMsg);
    xmlContext.AppendItem_saName_N_saValue('saErrMsgMoreInfo',saErrMsgMoreInfo);
    xmlContext.AppendItem_saName_N_saValue('sServerIP',sServerIP);
    xmlContext.AppendItem_saName_N_saValue('sServerPort',inttostr(u2ServerPort));
    xmlContext.AppendItem_saName_N_saValue('sServerIPCGI',sServerIPCGI);
    xmlContext.AppendItem_saName_N_saValue('u2ServerPortCGI',inttostr(u2ServerPortCGI));
    xmlContext.AppendItem_saName_N_saValue('saPage',saPage);
    xmlContext.AppendItem_saName_N_saValue('bLoginAttempt',sTrueFalse(bLoginAttempt));
    //xmlContext.AppendItem_saName_N_saValue('saLoginMsg',saLoginMsg);
    xmlContext.AppendItem_saName_N_saValue('saPageTitle',saPageTitle);
    xmlContext.AppendItem_saName_N_saValue('dtRequested',FormatDateTime(csDATETIMEFORMAT,dtRequested));
    xmlContext.AppendItem_saName_N_saValue('dtServed',FormatDatetime(csDATETIMEFORMAT,dtServed));
    xmlContext.AppendItem_saName_N_saValue('dtFinished',FormatDateTime(csDATETIMEFORMAT,dtFinished));
    xmlContext.AppendItem_saName_N_saValue('sLang',sLang);
    xmlContext.AppendItem_saName_N_saValue('bOutputRaw',sTrueFalse(bOutputRaw));
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Area',saHTMLRIPPER_Area);
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Page',saHTMLRIPPER_Page);
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Section',saHTMLRIPPER_Section);
    xmlContext.AppendItem_saName_N_saValue('u8MenuTopID',inttostr(u8MenuTopID));
    xmlContext.AppendItem_saName_N_saValue('saUserCacheDir',saUserCacheDir);
    xmlContext.AppendItem_saName_N_saValue('u2ErrorReportingMode',inttostr(u2ErrorReportingMode));
    xmlContext.AppendItem_saName_N_saValue('iDebugMode',inttostr(u2DebugMode));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute',sTrueFalse(bMIME_execute));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_Jegas',sTrueFalse(bMIME_execute_Jegas));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_JegasWebService',sTrueFalse(bMIME_execute_JegasWebService));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_php',sTrueFalse(bMIME_execute_php));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_perl',sTrueFalse(bMIME_execute_perl));
    xmlContext.AppendItem_saName_N_saValue('sMimeType',sMimeType);
    xmlContext.AppendItem_saName_N_saValue('bMimeSNR',sTrueFalse(bMimeSNR));
    xmlContext.AppendItem_saName_N_saValue('saFileSoughtNoExt',saFileSoughtNoExt);
    xmlContext.AppendItem_saName_N_saValue('sFileSoughtExt',sFileSoughtExt);
    xmlContext.AppendItem_saName_N_saValue('sFileNameOnly',sFileNameOnly);
    xmlContext.AppendItem_saName_N_saValue('sFileNameOnlyNoExt',sFileNameOnlyNoExt);
    xmlContext.AppendItem_saName_N_saValue('saIN',saIN);
    xmlContext.AppendItem_saName_N_saValue('saOut',saOut);
    xmlContext.AppendItem_saName_N_saValue('uBytesRead',inttostr(uBytesRead));
    xmlContext.AppendItem_saName_N_saValue('uBytesSent',inttostr(uBytesSent));
    xmlContext.AppendItem_saName_N_saValue('saRequestedHost',saRequestedHost);
    xmlContext.AppendItem_saName_N_saValue('saRequestedHostRootDir',saRequestedHostRootDir);
    xmlContext.AppendItem_saName_N_saValue('saRequestMethod',sRequestMethod);
    xmlContext.AppendItem_saName_N_saValue('saRequestType',sRequestType);
    xmlContext.AppendItem_saName_N_saValue('saRequestedFile',saRequestedFile);
    xmlContext.AppendItem_saName_N_saValue('saOriginallyREquestedFile',saOriginallyREquestedFile);
    xmlContext.AppendItem_saName_N_saValue('saRequestedName',saRequestedName);
    xmlContext.AppendItem_saName_N_saValue('saRequestedDir',saRequestedDir);
    xmlContext.AppendItem_saName_N_saValue('saFileSought',saFileSought);
    xmlContext.AppendItem_saName_N_saValue('saQueryString',saQueryString);
    xmlContext.AppendItem_saName_N_saValue('u2HttpErrorCode',inttostr(u2HttpErrorCode));
    xmlContext.AppendItem_saName_N_saValue('saLogFile',saLogFile);
    xmlContext.AppendItem_saName_N_saValue('bJASCGI',sTrueFalse(bJASCGI));
    xmlContext.AppendItem_saName_N_saValue('saActionType',sActionType);
    xmlContext.AppendItem_saName_N_saValue('iSessionResultCode',inttostr(iSessionResultCode));
    xmlContext.AppendItem_saName_N_saValue('bSaveSessionData',sTrueFalse(bSaveSessionData));
    xmlContext.AppendItem_saName_N_saValue('bInternalJob',sTrueFalse(bInternalJob));
    xmlContext.AppendItem_saName_N_saValue('JTrakXDL',JTrakXDL.saXML);
    xmlContext.AppendItem_saName_N_saValue('JTrak_TableID',inttostr(JTrak_TableID));
    xmlContext.AppendItem_saName_N_saValue('JTrak_JDType_u',inttostr(JTrak_JDType_u));
    xmlContext.AppendItem_saName_N_saValue('JTRak_sPKeyColName',JTRak_sPKeyColName);
    xmlContext.AppendItem_saName_N_saValue('JTrak_DBConOffset',inttostr(JTrak_DBConOffset));
    xmlContext.AppendItem_saName_N_saValue('JTrak_Row_ID',inttostr(JTrak_Row_ID));
    xmlContext.AppendItem_saName_N_saValue('JTrak_bExist',sTrueFalse(JTrak_bExist));
    xmlContext.AppendItem_saName_N_saValue('JTrak_sTable',JTrak_sTable);
    xmlContext.AppendItem_saName_N_saValue('sTheme',sTheme);
    xmlContext.AppendItem_saName_N_saValue('u2VHost',inttostr(u2VHost));
    xmlContext.AppendItem_saName_N_saValue('sAlias',sAlias);
    xmlContext.AppendItem_saName_N_saValue('sIconTheme',sIconTheme);
    xmlContext.AppendItem_saName_N_saValue('u2LogType_ID',inttostr(u2LogType_ID));
    xmlContext.AppendItem_saName_N_saValue('bNoWebCache',sTrueFalse(bNoWebCache));
    xmlContext.AppendItem_saName_N_saValue('JThread',inttostr(UINT(JTHREAD)));
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;
    xmlNode.AppendItem_saName_N_saDesc('u8Stage',inttostr(JThread.u8Stage));
    xmlNode.AppendItem_saName_N_saDesc('saStageNote',JThread.saStageNote);
    ////JThread.rJTMsgFifoInit: rtFifoInit;
    ////JThread.JTMSGFIFO: JFC_FIFO;
    ////JThread.JTMSG_OUT: rtFIFOItem;
    xmlNode.AppendItem_saName_N_saDesc('UID',inttostr(JThread.UID));
    ////JThread.Children: JFC_DL;
    xmlNode.AppendItem_saName_N_saDesc('Suspended',sTrueFalse(JThread.Suspended));
    xmlNode.AppendItem_saName_N_saDesc('lpParent',inttostr(UINT(JThread.lpParent)));
    xmlNode.AppendItem_saName_N_saDesc('uExecuteIterations',inttostr(JThread.uExecuteIterations));
    xmlNode.AppendItem_saName_N_saDesc('dtCreated',FormatDateTime(csDATETIMEFORMAT,JThread.dtCreated));
    xmlNode.AppendItem_saName_N_saDesc('dtExecuteBegin',FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteBegin));
    xmlNode.AppendItem_saName_N_saDesc('dtExecuteEnd',FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteEnd));
    xmlNode.AppendItem_saName_N_saDesc('bShuttingDown',sTrueFalse(JThread.bShuttingDown));
    xmlNode.AppendItem_saName_N_saDesc('bLoopContinuously',sTrueFalse(JThread.bLoopContinuously));
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='JThread';
    xmlContext.Item_saValue:='';
    xmlContext.Item_saDesc:='Worker Process';

    //XML: JFC_XML;
    xmlContext.AppendItem_saName_N_saValue('XML','XML - Circular Reference');

    //JADOC: array of JADO_CONNECTION;
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;
    for i:=0 to length(JADOC)-1 do
    begin
      xmlNode2:=JFC_XML.Create;
      xmlNode2.bDestroyNestedLists:=true;
      xmlNode2.bShowNestedLists:=true;
      xmlNode.AppendItem_lpPtr(xmlNode2);
      JFC_XMLITEM(xmlNode.lpItem).AttrXDL.AppendItem_saName_N_saValue('Index',inttostr(i));
      xmlNode.Item_saName:='DatabaseConnection';

      xmlNode3:=JFC_XML.Create;
      xmlNode3.bDestroyNestedLists:=true;
      xmlNode3.bShowNestedLists:=true;
      xmlNode2.AppendItem_lpPtr(xmlNode3);

      xmlNode3.AppendItem_saName_N_saValue('ID',inttostr(JADOC[i].ID));
      xmlNode3.AppendItem_saName_N_saValue('u8DbmsID',inttostr(JADOC[i].u8DbmsID));
      xmlNode3.AppendItem_saName_N_saValue('saConnectionString',JADOC[i].sConnectionString);
      xmlNode3.AppendItem_saName_N_saValue('sDefaultDatabase',JADOC[i].sDefaultDatabase);
      xmlNode3.AppendItem_saName_N_saValue('sProvider',JADOC[i].sProvider);
      xmlNode3.AppendItem_saName_N_saValue('i4State',inttostr(JADOC[i].i4State));
      xmlNode3.AppendItem_saName_N_saValue('sVersion',JADOC[i].sVersion);
      xmlNode3.AppendItem_saName_N_saValue('u8DriverID',inttostr(JADOC[i].u8DriverID));
      xmlNode3.AppendItem_saName_N_saValue('saMyUsername',JADOC[i].saMyUsername);
      xmlNode3.AppendItem_saName_N_saValue('saMyPassword','Withheld');//JADOC[i].saMyPassword);
      xmlNode3.AppendItem_saName_N_saValue('saMyConnectString',JADOC[i].saMyConnectString);
      xmlNode3.AppendItem_saName_N_saValue('saMyDatabase',JADOC[i].saMyDatabase);
      xmlNode3.AppendItem_saName_N_saValue('saMyServer',JADOC[i].saMyServer);
      xmlNode3.AppendItem_saName_N_saValue('u2MyPort',inttostr(JADOC[i].u2MyPort));
    end;
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='DatabaseConnections';

    // MATRIX: JFC_MATRIX;
    xmlContext.AppendItem_saName_N_saValue('MATRIX',MATRIX.saXML);

    // CGIENV: JFC_CGIENV;
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;
    xmlNode.AppendItem_saName_N_saValue('ENVVAR',CGIENV.ENVVAR.saXML);
    xmlNode.AppendItem_saName_N_saValue('DATAIN',CGIENV.DATAIN.saXML);
    //xmlNode.AppendItem_saName_N_saValue('CKY IN',CGIENV.CKY IN.saXML);
    //xmlNode.AppendItem_saName_N_saValue('CKY OUT',CGIENV.CKY OUT.saXML);
    xmlNode.AppendItem_saName_N_saValue('HEADER',CGIENV.HEADER.saXML);
    xmlNode.AppendItem_saName_N_saValue('FILESIN',CGIENV.FILESIN.saXML);
    xmlNode.AppendItem_saName_N_saValue('bPost',sTrueFalse(CGIENV.bPost));
    xmlNode.AppendItem_saName_N_saValue('saPostContentType',CGIENV.saPostContentType);
    xmlNode.AppendItem_saName_N_saValue('uPostContentLength',inttostr(CGIENV.uPostContentLength));
    xmlNode.AppendItem_saName_N_saValue('saPostData',CGIENV.saPostData);
    xmlNode.AppendItem_saName_N_saValue('iTimeZoneOffset',inttostr(CGIENV.iTimeZoneOffset));
    xmlNode.AppendItem_saName_N_saValue('uHTTPResponse',inttostr(CGIENV.uHTTPResponse));
    xmlNode.AppendItem_saName_N_saValue('saServerSoftware',CGIENV.saServerSoftware);
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='CGIEnvironment';



    //PROCESS: TPROCESS; - not doing

    // rJUser: rtJUser;
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;

    xmlContext.AppendItem_saName_N_saValue('JUser_JUser_UID',inttostR(rJUser.JUser_JUser_UID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Name',rJUser.JUser_Name);
    xmlContext.AppendItem_saName_N_saValue('JUser_Password','Withheld');//rJUser.JUser_Password);
    xmlContext.AppendItem_saName_N_saValue('JUser_JPerson_ID',inttostr(rJUser.JUser_JPerson_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Enabled_b',sTrueFalse(rJUser.JUser_Enabled_b));
    //if garJVHostLight[u2VHost].saServerDomain='default' then
    if u2VHost=0 then xmlContext.AppendItem_saName_N_saValue('JUser_Admin_b',sTrueFalse(rJUser.JUser_Admin_b));
    xmlContext.AppendItem_saName_N_saValue('JUser_Login_First_DT',rJUser.JUser_Login_First_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Login_Last_DT',rJUser.JUser_Login_Last_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Logins_Successful_u',inttostr(rJUser.JUser_Logins_Successful_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_Logins_Failed_u',inttostr(rJUser.JUser_Logins_Failed_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_Password_Changed_DT',rJUser.JUser_Password_Changed_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_AllowedSessions_u',inttostr(rJUser.JUser_AllowedSessions_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_DefaultPage_Login',rJUser.JUser_DefaultPage_Login);
    xmlContext.AppendItem_saName_N_saValue('JUser_DefaultPage_Logout',rJUser.JUser_DefaultPage_Logout);
    xmlContext.AppendItem_saName_N_saValue('JUser_JLanguage_ID',inttostR(rJUser.JUser_JLanguage_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Audit_b',sTrueFalse(rJUser.JUser_Audit_b));
    xmlContext.AppendItem_saName_N_saValue('JUser_ResetPass_u',inttostr(rJUser.JUser_ResetPass_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_JVHost_ID',inttostr(rJUSer.JUser_JVHost_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_TotalJetUsers_u',inttostr(rJUser.JUser_TotalJetUsers_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_SIP_Exten',rJUser.JUser_SIP_Exten);
    xmlContext.AppendItem_saName_N_saValue('JUser_SIP_Pass',rJUser.JUser_SIP_Pass);
    xmlContext.AppendItem_saName_N_saValue('JUser_Headers_b',sYesNo(rJUser.JUser_Headers_b));
    xmlContext.AppendItem_saName_N_saValue('JUser_QuickLinks_b',sYesNo(rJUser.JUser_QuickLinks_b));
    xmlContext.AppendItem_saName_N_saValue('JUser_IconTheme',rJUser.JUser_IconTheme);
    xmlContext.AppendItem_saName_N_saValue('JUser_Theme',rJUser.JUser_Theme);
    xmlContext.AppendItem_saName_N_saValue('JUser_CreatedBy_JUser_ID',inttostr(rJUser.JUser_CreatedBy_JUser_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Created_DT',rJUser.JUser_Created_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_ModifiedBy_JUser_ID',inttostr(rJUser.JUser_ModifiedBy_JUser_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Modified_DT',rJUser.JUser_Modified_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_DeletedBy_JUser_ID',inttostr(rJUser.JUser_DeletedBy_JUser_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Deleted_DT',rJUser.JUser_Deleted_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Deleted_b',sYesNo(rJUser.JUser_Deleted_b));
    xmlContext.AppendItem_saName_N_saValue('JAS_Row_b',sYesNo(rJUser.JAS_Row_b));
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='User';



    // rJSession: rtJSession;
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;

    xmlContext.AppendItem_saName_N_saValue('JSess_JSession_UID',inttostr(rJSession.JSess_JSession_UID));
    xmlContext.AppendItem_saName_N_saValue('JSess_JSessionType_ID',inttostr(rJSession.JSess_JSessionType_ID));
    xmlContext.AppendItem_saName_N_saValue('JSess_JUser_ID',inttostr(rJSession.JSess_JUser_ID));
    xmlContext.AppendItem_saName_N_saValue('JSess_Connect_DT',rJSession.JSess_Connect_DT);
    xmlContext.AppendItem_saName_N_saValue('JSess_LastContact_DT',rJSession.JSess_LastContact_DT);
    xmlContext.AppendItem_saName_N_saValue('JSess_IP_ADDR',rJSession.JSess_IP_ADDR);
    xmlContext.AppendItem_saName_N_saValue('JSess_PORT_u',inttostr(rJSession.JSess_PORT_u));
    xmlContext.AppendItem_saName_N_saValue('JSess_Username',rJSession.JSess_Username);
    xmlContext.AppendItem_saName_N_saValue('JSess_JJobQ_ID',inttostr(rJSession.JSess_JJobQ_ID));
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='Session';

    // SessionXDL: JFC_XDL;
    xmlContext.AppendItem_saName_N_saValue('SessionXDL',SessionXDL.saXML);

    // PAGESNRXDL: JFC_XDL;
    xmlContext.AppendItem_saName_N_saValue('PAGESNRXDL',PAGESNRXDL.saXML);

    xmlContext.AppendItem_saName_N_saValue('REQVAR_XDL',REQVAR_XDL.saXML);

    // LogXXDL: JFC_XXDL;
    xmlContext.AppendItem_saName_N_saValue('LogXXDL',LogXXDL.saXML);

    xmlJASDebugXMLOutput.appenditem_lpPtr(xmlContext);
    xmlJASDebugXMLOutput.Item_saName:='Context';

    // END -------------------------- Context

    XML.AppendItem_lpPtr(xmlJASDebugXMLOutput);
    XML.Item_saName:='JASDEBUGINFO';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102689,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function TCONTEXT.saJThemeHeader(p_sTheme: string): ansistring;
//=============================================================================
var
  i: longint;
  sUpCaseTheme: string;
begin
  result:='';
  if length(garJThemeLight)>0 then
  begin
    sUpCaseTheme:=upcase(p_sTheme);
    for i:=0 to length(garJThemeLight)-1 do
    begin
      if UPCase(garJThemeLight[i].saName)=sUpCaseTheme then
      begin
        result:= garJThemeLight[i].saTemplate_Header;
        break;
      end;
    end;
  end;
end;
//=============================================================================




//=============================================================================
function TCONTEXT.sJLanguageLookup(p_u8LangID: UInt64): string;
//=============================================================================
var
  i: longint;
begin
  //ASPrintln('sJLanguageLookup('+inttostr(p_u8LangID)+')');
  result:=grJASConfig.sDefaultLanguage;
  if length(garJLanguageLight)>0 then
  begin
    for i:=0 to length(garJLanguageLight)-1 do
    begin
      //ASPrintln('sJLanguageLookup Loop - garJLanguageLight[i].u8JLanguage_UID: '+inttostr(garJLanguageLight[i].u8JLanguage_UID));
      if garJLanguageLight[i].u8JLanguage_UID=p_u8LangID then
      begin
        //ASPrintln('GOT ONE! garJLanguageLight[i].saCode: '+garJLanguageLight[i].saCode);
        result:=garJLanguageLight[i].saCode;
        break;
      end;
    end;
  end;
end;
//=============================================================================





//=============================================================================
function TCONTEXT.VHDBC: JADO_CONNECTION;
//=============================================================================
var
  i: longint;
  bDone: boolean;
begin

  //ASPrintln('BEGIN TCONTEXT.VHDBC garJVHostLight[i4VHost].u8JDConnection_ID: '+inttostR(garJVHostLight[i4VHost].u8JDConnection_ID)+' i4VHost: '+inttostr(i4VHost));
  //ASPrintln('RequestedFile: '+saREquestedFile);
  result:=JADOC[0];
  //ASPrintln('Before VHDBC IF');
  if (garJVHost[u2VHost].VHost_JDConnection_ID>0) then
  begin
    //ASPrintln('INSIDE VHDBC IF');
    i:=0;
    bDone:=false;
    repeat
      //ASPrintln('VHDBC REPEAT');
      if JADOC[i].ID=garJVHost[u2VHost].VHost_JDConnection_ID then
      begin
        //ASPrintln('VHDBC REPEAT - GOT IT');
        bDone:=true;
        result:= JADOC[i];
      end;
      i+=1;
    until bDone or (i=length(JADOC));
    //ASPrintln('VHDBC REPEAT - DONE');
    //if bDone then
    //begin
      //ASPrintln('FOUND JADOC[i].ID: '+RESULT.ID+' garJVHostLight['+inttostr(i4VHost)+'].u8JDConnection_ID: '+inttostr(garJVHostLight[i4VHost].u8JDConnection_ID));
    //end
    //else
    //begin
      //ASPrintln('NOT FOUND - No VHost/Connection');
    //end;
  end;
  //ASPrintln('END TCONTEXT.VHDBC - Result.ID: ' + RESULT.ID+' '+RESULT.saName  );
end;
//=============================================================================



//=============================================================================
{}
function TCONTEXT.saGetURL(p_u: uint): ansistring;
//=============================================================================
begin

  if RightStr(garJVHost[p_u].VHost_ServerURL   ,1)<>'/' then garJVHost[p_u].VHost_ServerURL+='/';
  if RightStr(garJVHost[p_u].VHost_ServerDomain,1)<>'/' then garJVHost[p_u].VHost_ServerDomain+='/';

  if garJVHost[p_u].VHost_SharesDefaultDomain_b then
  begin
    result:=garJVHost[0].VHost_ServerDomain+garJVHost[p_u].VHost_ServerDomain;
  end
  else
  begin
    // begin--original
    //if garJVHost[p_u].saServerDomain='default' then
    //begin
    //  result:=garJVHost[p_u].VHost_ServerURL;
    //end
    //else
    //begin
    //  result:=garJVHost[p_u].VHost_ServerDomain;
    //end;
    // end--original

    //--New
    result:=garJVHost[p_u].VHost_ServerURL;
  end;
end;
//=============================================================================



procedure TContext.banpage;
begin
      CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;

      //=== HOW TO DO COMPRESSED INLINE IMAGE======
      //  So you just include it in the HTML as such:
      //  <img src="data:image/png;base64,your-base-64-encoded-image-data" alt="some textual description of your image">
      //
      //  To base64 encode a file on a *nix system (such as OS X or Linux), you can use the base64 command:
      //
      //  base64 "myimage.jpg" > myimage-base64.txt
      //
      //  Get the png or cpressed online first or something so its much smaller of course :)
      //
      //=== HOW TO DO COMPRESSED INLINE IMAGE======





      // Punk-Be-Gone - Sprite Lady
      {
      Context.saOut:=
            '<html><head><title>BANNED</title></head><body bgcolor="#000000" ><center><table '+
            'width="100%" height="100%"><tr><td align="center" valign="middle"><h1>'+
            'Punk-Be-Gone</h1><h2>Preemptive Defense System</h2><br /><img ' +
            'src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABHCAMAAACAsrF'+
            'UAAAAllBMVEUAAAA4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4O'+
            'Dg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg5OTk4ODg4ODg4ODg'+
            '4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4O'+
            'DgfAQ4oAAAAMXRSTlMA+yIE89YaBjzREJEL7+Xcv6j3xrWtc21GNurMupyKfEtCJuFhVC4'+
            'peBWXaVtQoqCEMbjV5AAAAzVJREFUWMOdl+mWojAQhQvZXAFlEVBb2t0e7en7/i83EnEST'+
            'CJpvz96PKSoVG7dlKRnWH3PsE329B7eCA2zI71BBgHXpt+yQAvnQL9jhGdWZMowpTyDgvm'+
            'YTLDLlCwosciEIi620GCSwkcALQvqohfhFV5X9VZ4ybLr9QAmwRpaPuglR8s5EdHl3Qz88'+
            'Ew3UrQYHdx65R6MeJHPtJreVUTjJZ4ZUQBrOUDD90av3ZQ+A7wmstXSG7kZK2E3K58ULBE'+
            'VRFTBBNUWgC2TIIxQ2NPGRZm4DmDNyUEnKmPYZNPIheUVQEkJJIxa8hNZXcivBF30NY1w2'+
            '0AfcjOZK7rCaOXQCp2MSMOmcqY0QCdT0lKWJyBGB06u9QUHwNZEksGQJGoxroEB9WFCj56'+
            '5INolQLiZwoS/JHNI4BARjHBJxl9gT8MpjJiQzA8CP5/h7QCNBFIXJgxIBjU/7OMtNX3Mj'+
            'nnVIw9GfMrGhgvdMJTBliS8RhvZWzpiC4mRwoQxSQRL3g+Wffp1BmP88BL0af5rY/Sx4rM'+
            'RdQZYk0QI32/UFHcHiBSeCDhjYtPRTgpgNuzUCeTN3TF/11nd5voqoMXivSDjs2Y8Ex2gp'+
            'Vi+mJc89oox+6IhpuJFCivcSFhnqGHRQ90N1yxjjnuFmpyJTXfDHQWvifQ+MkbNH5LJxHF'+
            '0qu+BuNmpRNiaINQK5p5BEmf+u+gsgs8+amU1tXrij3hjjB0Ak6rnEx1d3KkeAUq1ElLB7'+
            'C6ttr9HCNv/h3LZU3iWX6gpeXHaDbRjQ6c0bPM+vbZ9J38++CNqlCXoc1tBQHdGcv8pfW0'+
            'KwKE7W0EqO8Wozk7mQg/4or2Yo02MBDVX6VlpWJoAli9KoifUBmf5Hp3Jd6Nj//fYG2Ejl'+
            'U95SI7AOHEt2P0YgHVubdLy+flmz/ViOGL+bMlBPBIMBVVUqgAIB2v+TEtt84+v9UNra9T'+
            'sVAEmTA6HCHBYRunz4fIiIH42X6E06ZyKu1hSpddlg6BcSBERniz0ubotZkbYkRJb/O5gZ'+
            'bvAhOz19R7RQmxbpV+fukedJKxnv4VdefuCJgufzPBwfXi4y11lbQ3JEO9vs5+TWzvoP5G'+
            'flinUPe9cAAAAAElFTkSuQmCC" /><br /><font size="30px" color="#666666">B'+
            'ANNED</font></td></tr></table></center></body></html>';
      }


      saOut:=
            '<html><head><title>BANNED</title></head><body bgcolor="#000000" ><center><table '+
            'width="80%" height="80%"><tr><td align="center" valign="middle"><h1>'+
            'Punk-Be-Gone</h1><h2>Preemptive Defense System</h2><br /><img title="&quot;'+
            'You have been weighed and measured and found wanting.&quot; - A Knight''s Tale"' +
            'src="data:image/png;base64,'+
            'iVBORw0KGgoAAAANSUhEUgAAARIAAAESBAMAAADDGUcQAAAAIVBMVEVMaXH///8ZGRkkJCQHBweH'+
            'h4eYmJh2dnY5OTlcXFxQUFCnQKMBAAAAAXRSTlMAQObYZgAAAvNJREFUeF7swKERACAIAECaVoez'+
            'y/5LeMcIFMp/NAAAAAAAAADAvnnKi0krP/t2jBw1EEQBtBsXhSHqL7kcY7jALnAAiuICDjiAE2Jz'+
            'BCJSuAEJ9yRZalQrS61F6ulfu/NDj2rmuWc0o9pdYZCvXx6THC8xyu3vDMgPPJWf9SHf8HRuKzvu'+
            'MZOakFeYi9W7c8vM5FblOUpSy/ICSKBQS/7cY1ESbt+kqihAQnnACQk+8ziKgpLcqihIKNcgkVx/'+
            'x+mxoNXKQVEayS/8ZyImh6MqDywSBcAxPWCRKBIo5BKsitFIwCOxM5Q8o5EojQRrEydpErBIFKvT'+
            '0UhwbpI7Gske6/M+YKtPLMoVSnI3fL1ASZM0SUcjAbOkSV7TSHY0EmuSJmkSmHi7WD2JZkj2E306'+
            'O7tuL5k8PtwFoZESfynLMJtKdLq3BSdulEROlmiMxGaQU8NphGTc1wKJKI1EtpdMtLkS3VpiKyVo'+
            'kkHOVyJLJBM9xEtkkUQSJBYrcQcpkWCJQ/HPOK0tAVIlPY3EgQRIpnoywLGKoopEYOJIUOfeUZiI'+
            'zl5RUwIoieRwVaTE7wgsEgCDZZkoUQCDy6xJRFEk8c/2MiMZjlCuumiJDhvKeAmS0lAGDJA4PZUq'+
            'eHtxvOR4ZBySJpFjiVWWAFMSwGpKyrBzf4uXKOYlQCUJ4Epg45W9+cGjoxFnGjTmc3vn00YdtyFI'+
            'AueLgdzvd4RNUihNYsSSJhEWiS2X4JwkV07v9SSyp5HoJpKORnIjG2QTiUkAhVFiyyUfY3/TbZUW'+
            'bIkv8Q+oYMo/gUU/svn/sR0kTkneSLgEh4Z5SM/yIl7/QThelHz3luMdYyN5KV7CcpKiFCSzKEWR'+
            'XxS5GIkmzA27RDQBwi6RgOUaWBQTlpoIi8QkbXaaxA+PpEmaRDhr0pNJbgCgY5B0xxLjOYvbU0GT'+
            'sK6Tctt8Tnss+ISSVMl4pu6AHkCH3d924KAIAAACABgNOP27isFjiw+yp+IQAAAAAAAAsFMoCZ4q'+
            'MyIOAAAAAElFTkSuQmCC'+
            '" /><br /><font size="30px" color="#666666">B'+
            'ANNED</font></td></tr></table></center></body></html>';
end;




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
