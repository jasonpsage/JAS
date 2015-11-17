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
  bSessionValid: Boolean;   //< This Ok for many operations not requiring login
  bErrorCondition: Boolean; {< True When an Error has occurred. Typically code should allow fall through
                             because the OUTPUT page is rendered as an error HTML page.}
  u8ErrNo: UInt64;           //< most RECENT Error.
  saErrMsg: AnsiString;     //< most recent Error Message
  saErrMsgMoreInfo: ansistring;//< most recent Error Message - additional information if available
  
  saServerIP: ansistring;
  saServerPort: ansistring;
  
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
  saLang: ansistring;
  {}
  //JMenuDL: JFC_DL; {< Instantiated as JFC_DL.CreateCopy(gJMenuDL) during
  // Thread creation. Not Cleared or Destroyed until thread destructor fired. }
  //=============================================================================
  {}
  bOutputRaw: boolean; {< Most pages from JAS until 2007-02-15 were html only.
   Output raw is the first thing to set if you know the output is not 
   to get a HTML/XHTML response. This allows sending completely 
   controlled raw output. This means you need to create your own headers.
   See the new JFC_CGIENV.saCGIHdrXml function which sends out a default
   HTTP header, for mime type text/xml, and a basic xml header line
   example: <?xml version="1.0" encoding="UTF-8" standalone="yes"?> }
  //=============================================================================
  {}
  // Converting pages to static - the following variables are SET by
  // the function saHTMLRIPPER (in uxxj_api.pp) and uxxg_jcore - Because JCORE
  // does the final processing on outbound data. The output is basically the 
  // SENT web page. Links are not yet handled nor do I intend to handle that 
  // any time soon. This is not your typical content "publishing tool, nor 
  // was it designed for static web page development. This is just a way to 
  // capture output and work it into static pages to offset JAS workload
  // and make reading statitics easier from a web master point of view.
  // Files names are based on AREA, PAGE, SECTION separated by underscores.
  // All Filenames are set to lowercase.
  saHTMLRIPPER_Area, saHTMLRIPPER_Page, saHTMLRIPPER_Section: ansistring;
  u8MenuTopID: Uint64; // Current Root Menu to Draw
  saUserCacheDir: ansistring; //< Ends up being cache + mac_dosslash + U????? +  mac_dosslash
  saHelpID: ansistring;
  
  iErrorReportingMode: Longint;//< Used for Per request Resolve of ErrorReporting and Debug Security Mode
  iDebugMode: Longint;//< Used for Per request Resolve of ErrorReporting and Debug Security Mode
  
  // Some Flags used to control code flow
  {}
  bMIME_execute: boolean;//< Executable MIME TYPE - (the word "execute/" is in the mime type name) could be *.exe, php, *.bat etc.
  bMIME_execute_Jegas: Boolean;
  bMIME_execute_JegasWebService: boolean;
  bMIME_execute_php: boolean;
  bMIME_execute_perl: boolean;
  
  saMimeType: ansistring;
  bMimeSNR: boolean;
  saFileSoughtNoExt: ansistring; //< e.g:  f:/somedir/myfile
  saFileSoughtExt: ansistring; //< e.g:                     html
  saFileNameOnly: ansistring; //< e.g:               myfile.html
  saFileNameOnlyNoExt: ansistring;//< e.g:           myfile

  saIN: AnsiString;
  saOut: AnsiString;
  REQVAR_XDL: JFC_XDL;
  u8BytesRead: Uint64;
  u8BytesSent: Uint64;
  saRequestedHost: ansistring;
  saRequestedHostRootDir: ansistring; 
  saRequestMethod: AnsiString;
  saRequestType: AnsiString;
  saRequestedFile: AnsiString;
  saOriginallyRequestedFile: ansistring;
  saRequestedName: AnsiString;
  saRequestedDir: AnsiString;
  saFileSought: AnsiString;
  saQueryString: AnsiString;
  i4ErrorCode: LongInt; //< HTTP Error Code usually 200 for OK
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
  saActionType: ansistring;//<iwf specific
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
  JTrak_TableID: ansistring;
  JTrak_u2JDType: word;
  JTRak_saPKeyCol: ansistring;
  JTrak_DBConID: ansistring;
  JTrak_saUID: ansistring;
  JTrak_bExist: boolean;//if record Exists at the onset
  JTrak_saTable: ansistring;
  saColorTheme: ansistring;
  i4VHost: longint;
  saAlias: ansistring; // used for Alias that indicates a separate virtual host.
  saServerURL: ansistring;
  bMenuHasPAnels: boolean;
  
  constructor create(
    p_saServerSoftware: ansistring; 
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
  //
  // Just remember to not DESTROY vTigerCon because it's just a reference 
  // to the actual connection class object pre-instantiated in the thread.
  function DBCON(p_saConnectionName: Ansistring): JADO_CONNECTION;
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
  function DBCON(p_JDCon_JDConnection_UID: UINT64): JADO_CONNECTION;
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
  // JAS_SNR is getting stuck in SNR Infinite loop at the moment 20101230,
  // and the "STUCK" factor happens in JFC_XDL.SNR - So because I can't
  // See what's going on in that low-level class - I'm putting the routine here
  // where I can get some feedback and maybe even step through this thing.
  function saJAS_PROCESS_SNR_LIST(p_bCaseSensitive: boolean; p_saPayLoad: ansistring): ANSISTRING;
  //=============================================================================
  {}
  Procedure JTrakBegin(p_DBCon: JADO_CONNECTION; p_saTable: ansistring; p_saUID: ansistring);
  //=============================================================================
  {}
  Procedure JTrakEnd(p_saUID: ansistring; p_saSQL: ansistring);
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
    p_saTable: ansistring;
    p_saUID: ansistring;
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
    p_sValue: string
  ): ansistring;
  {}
  // Returns the SQL for the specified lookup and
  // also returns by reference the lookup table's name
  function saLookUpSQL(
    p_sTableName: string;
    p_sColumnName: string;
    var p_sLUTableName: ansistring
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
  // Returns the HTML that appears between the HEADER tags for the color theme
  // specified
  function saJThemeColorHeader(p_saColorTheme: ansistring): ansistring;
  //=============================================================================
  {}
  // Looks up the Current language code - based on current user's settings
  // but can be the default if a setting is not found. 
  function saJLanguageLookup(p_u8LangID: UInt64): ansistring;
  //=============================================================================
  {}
  // Function to return the MAIN JADO_CONNECTION for the current VHOST.
  function VHDBC: JADO_CONNECTION;
  //=============================================================================
  {}
  // Return URL of specified VHOST
  function saGetURL(p_i: longint): ansistring;
  //=============================================================================
  public
  //=============================================================================
  {}
  // This just holds the list of valid themes in use on the server.
  sIconTheme: string;
  u2LogType_ID: word;
  bNoWebCache: boolean;
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
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  DT: TDateTime;
  safileName: ansistring;
  sa: ansistring;
  u2IOResult: word;
  f: text;


  
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
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  saLogMsg:=p_saMsg;
  saLogExtra:='';

  //if length(p_saMoreInfo)>0 then
  //begin
  //  saLogMsg+=' More Info Start: '+p_saMoreInfo+' :More Info end. ';
  //end;

  if(p_JADOC<>nil)then
  begin
    saLogExtra+='<br /><br /> JAS (JADOC[0]) JADO_CONNECTION INFORMATION: '+
                ' u2DbmsID: ' + inttostr(DBC.u2DBMSID)+
                ' i4Attributes: withheld'+
                ' saConnectionString: withheld'+
                ' saDefaultDatabase: '+DBC.saDefaultDatabase+
                ' Properties: withheld'+
                ' saProvider: '+DBC.saProvider+
                ' i4State: '+JADO.saObjectState(DBC.i4State)+
                ' saVersion: '+DBC.saVersion+
                ' u2DrivID: '+inttostr(DBC.u2DrivID)+
                ' saMyUsername: withheld'+
                ' saMyPassword: withheld'+
                ' saMyConnectString: withheld'+
                ' saMyDatabase: '+DBC.saMyDatabase+
                ' saMyServer: '+DBC.saMyServer+
                ' Errors.ListCount: '+inttostr(DBC.Errors.ListCount);
                
    {$IFDEF ODBC}
    saLogExtra+=' ODBCDBHandle: '+inttostr(UINT(DBC.ODBCDBHandle))+
                ' ODBCStmtHandle: '+inttostr(UINT(DBC.ODBCStmtHandle));
    {$ENDIF}

    if(DBC.Errors.ListCount>0) then saLogExtra+='<br /><br />'+DBC.saRenderHTMLErrors;
  end;

  if(p_JADOC<>nil) and (DBC <> p_JADOC)then
  begin
    saLogExtra+='<br /><br /> p_JADOC JADO_CONNECTION INFORMATION: '+
                ' u2DbmsID: ' + inttostr(p_JADOC.u2DBMSID)+
                ' i4Attributes: withheld'+
                ' saConnectionString: withheld'+
                ' saDefaultDatabase: '+p_JADOC.saDefaultDatabase+
                ' Properties: withheld'+
                ' saProvider: '+p_JADOC.saProvider+
                ' i4State: '+JADO.saObjectState(p_JADOC.i4State)+
                ' saVersion: '+p_JADOC.saVersion+
                ' u2DrivID: '+inttostr(p_JADOC.u2DrivID)+
                ' saMyUsername: withheld'+
                ' saMyPassword: withheld'+
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

  if p_JADOR<>nil then
  begin
    saLogExtra+='<br /><br />  p_JADOR JADO_RECORDSET INFORMATION: '+
                ' u2DBMSID:'+inttostr(p_JADOR.u2DBMSID)+
                ' Fields.Count:'+inttostr(p_JADOR.Fields.ListCount)+
                ' ActiveConnection:'+inttostr(UINT(p_JADOR.ActiveConnection))+
                ' i4EditMode:'+inttostr(p_JADOR.i4EditMode)+
                ' EOL:'+saTrueFalse(p_JADOR.EOL)+
                ' i4LockType:'+inttostr(p_JADOR.i4LockType)+
                ' u8MaxRecords:'+inttostr(p_JADOR.u8MaxRecords)+
                ' i4State:'+inttostr(p_JADOR.i4State)+
                ' i4Status:'+inttostr(p_JADOR.i4Status)+
                ' u2DrivID:'+inttostr(p_JADOR.u2DrivID)+
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

  if length(saLogExtra)>0 then
  begin
    saLogExtra:='<br /><br /> Log Extra: '+saLogExtra;
  end;
  saLogMsg+=' '+p_saMoreInfo+' '+saLogExtra;
  JLog(p_u2LogType_ID, p_u8Msg, '201503162240 - JAS_Log: '+saLogMsg, p_saSourceFile);
  

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
    saFilename:=trim(garJVHostLight[p_Context.i4VHost].saErrorLog);
    if saFilename='' then saFilename:=trim(garJVHostLight[0].saErrorLog);
    if saFilename='' then saFilename:=trim(grJASConfig.saDefaultErrorLog);
    if (saFilename<>'') and bTSOpenTextFile(saFilename,u2IOResult,f,false,true) then
    begin
      // [Sun Oct 21 10:50:52 2012] [error] [client 98.144.40.193] File does not exist: /xfiles/inet/gallery/gallery.nepro.org/favicon.ico
      sa:='['+saFormatDateTIme('DDD MMM DD HH:NN:SS YYYY',DT)+'] ['+saSeverity+'] [client '+p_Context.rJSession.JSess_IP_ADDR+'] '+
          saSNRStr(saSNRStr(saSNRStr(saLogMsg,csCRLF,' '),#13,' '),#10,' ');
      {$I-}
      writeln(f,sa);
      {$I+}
      bTSCloseTextFile(saFilename, u2IOResult,f);
    end;
  end;

  saQry:=
    'INSERT INTO jlog ('+
      'JLOG_DateNTime_dt, '+
      'JLOG_JLogType_ID, '+
      'JLOG_Entry_ID, '+
        'JLOG_EntryData_s, '+
      'JLOG_SourceFile_s, '+
      'JLOG_User_ID, '+
      'JLOG_CmdLine_s '+
    ') VALUES ('+
      DBC.saDBMSDateScrub(DT)+','+
      DBC.saDBMSUIntScrub(p_u2LogType_ID)+','+
      DBC.saDBMSUIntScrub(p_u8Msg)+','+
      DBC.saDBMSScrub(saLogMsg)+','+
      DBC.saDBMSScrub(p_saSourceFile)+','+
      DBC.saDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
      DBC.saDBMSScrub(saCmdLine)+
    ')';
  if not rs.open(saQry,DBC,201503161708) then
  begin
    JLOG(cnLog_Error,201008102109,'JAS_LOGTHIS Unable to record issue in database. Query: '+saQry+' CALLER: '+p_saSourceFile,SOURCEFILE);
  end;
  rs.Destroy;

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
  p_saServerSoftware: ansistring; 
  p_iTimeZoneOffset: integer;
  p_JThread_Reference: TJTHREAD
);
//=============================================================================
  var
    i: integer;
    //rs: JADO_RECORDSET;
    //JAS: JADO_CONNECTION;
    //saQry: ansistring;
    //bOk: boolean;//kust for theme bit atm
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.create(p_saServerSoftware: ansistring;p_iTimeZoneOffset: integer;p_JThread_Reference: TJTHREAD);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_JThread_Reference.DBIN(201203102224,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_JThread_Reference.TrackThread(201203102225, sTHIS_ROUTINE_NAME);{$ENDIF}

  self.JThread:=p_JThread_Reference;
  //ASPrintln('Context.create - Server: '+p_saServerSoftware+' TimeZone:'+inttostr(p_iTimeZoneOffset)+' Thread Ref:'+inttostr(cardinal(p_JThread_Reference)));
  self.CGIENV:=JFC_CGIENV.Create(p_saServerSoftware, p_iTimeZoneOffset);
  self.REQVAR_XDL:=JFC_XDL.Create;
  self.PAGESNRXDL:=JFC_XDL.Create;
  //ASPrintln('Context.create - 10000');
  self.XML:=JFC_XML.Create;
  self.MATRIX:=JFC_MATRIX.create;
  self.LogXXDL:=JFC_XXDL.create;


  //ASPrintln('Context.create - 10010');
  //ASPrintln('length(gaJCon):'+inttostr(length(gaJCon)));
  
  //Log(cnLog_Debug,201007061749,'TCONTEXT.create - length(gaJCon):'+inttostr(length(gaJCon)),sourcefile);
  setlength(self.JADOC, length(gaJCon));

  //ASPrintln('Context.create - 10020');
  for i:=0 to length(gaJCon)-1 do
  begin 
    //Log(cnLog_Debug,201202210359,'TCONTEXT.create - gaJCon['+inttostr(i)+'].ID='+gaJCon[i].ID+' Nil? :'+inttostr(UINT(gaJCon[i])),sourcefile);
    self.JADOC[i]:=JADO_Connection.createcopy(gaJCon[i]);
    //Log(cnLog_Debug,201007061757,'TCONTEXT.create - self.JADOC['+inttostr(i)+'].ID='+self.JADOC[i].ID+' Nil? :'+inttostr(UINT(self.JADOC[i])),sourcefile);
    if (not self.JADOC[i].OpenCon) then
    begin
      JLog(cnLog_WARN,201001151256,'Unable to Open DSN['+inttostr(i)+']',sourcefile);
      writeln;
      writeln('Unable to Open DSN['+inttostr(i)+']');
      if(i=0)then
      begin
        Writeln;
        Writeln('Critical - Unable to Open MAIN JAS Database');
        writeln('ID: (JDConnection_ID)',self.JADOC[i].ID);
        writeln('u2DbmsID:',inttostr(self.JADOC[i].u2DbmsID));
        writeln('saConnectionString:',self.JADOC[i].saConnectionString);
        writeln('saDefaultDatabase:',self.JADOC[i].saDefaultDatabase);
        writeln('Errors.ListCount:',inttostr(self.JADOC[i].Errors.Listcount));
        writeln('saProvider:',self.JADOC[i].saProvider);
        writeln('i4State:',inttostr(self.JADOC[i].i4State));
        writeln('saVersion:',self.JADOC[i].saVersion);
        writeln('u2DrivID:',inttostr(self.JADOC[i].u2DrivID));
        //writeln('saMyUsername:',self.JADOC[i].saMyUsername);
        //writeln('saMyPassword:',self.JADOC[i].saMyPassword);
        writeln('saMyConnectString:',self.JADOC[i].saMyConnectString);
        writeln('saMyDatabase:',self.JADOC[i].saMyDatabase);
        writeln('saMyServer:',self.JADOC[i].saMyServer);
        //writeln('saUserName:',self.JADOC[i].saUserName);
        //writeln('saPassword:',self.JADOC[i].saPassword);
        writeln('saDriver:',self.JADOC[i].saDriver);
        writeln('saServer:',self.JADOC[i].saServer);
        writeln('saDatabase:',self.JADOC[i].saDatabase);
        HALT(1);
      end
      else
      begin
        //
      end;
    end
    else
    begin
      //ASPrintln(upcase(JADOC[i].saName)+' i:'+inttostr(i));
    end;
  end;

  //ASPrintln('Context.create - 10030');
  //if gJMenuDL<>nil then self.JMenuDL:=JFC_DL.CreateCopy(gJMenuDL);
  //ASPrintln('Context.create - 10040');
  SessionXDL:=JFC_XDL.create;
  JTrakXDL:=JFC_XDL.Create;

  //ASPrintln('Context.create - 10050');

  Process:=nil;
  self.Reset;
  //ASPrintln('Context.create - 10060');
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
  saHelpID:='';
  saErrMsg:='';
  saErrMsgMoreInfo:='';
  saServerIP:='0.0.0.0';
  saServerPort:='0';
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
  saLang:='en'; // Default for system.
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
  iErrorReportingMode:=grJASConfig.iErrorReportingMode;//cnSYS_INFO_MODE_SECURE;
  iDebugMode:=grJASConfig.iDebugMode;//cnSYS_INFO_MODE_SECURE;
  bMIME_execute:=false;// Executable MIME TYPE - (the word "execute/" is in the mime type name)
                       // could be *.exe, php, *.bat etc.
  bMIME_execute_Jegas:=false;
  bMIME_execute_JegasWebService:=false;
  bMIME_execute_php:=false;
  bMIME_execute_perl:=false;
  saMimeType:=csMIME_AppForceDownload;
  bMimeSNR:=false;
  saFileSoughtNoExt:='';
  saFileSoughtExt:='';
  saFileNameOnly:='';
  saFileNameOnlyNoExt:='';
  saIN:='';// DATA IN :)
  saOut:='';// DATA OUT :)
  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBOUT(201002092012,'Code Block',SOURCEFILE);{$ENDIF}

  {$IFDEF DEBUGTHREADBEGINEND}self.JThread.DBIN(201002092013,'Code Block',SOURCEFILE);{$ENDIF}

  REQVAR_XDL.Deleteall; 
  saServerIP:='';
  saServerPort:='';
  u8BytesRead:=0;
  u8BytesSent:=0;
  dtRequested:=0;
  saRequestedHost:='';
  saRequestedHostRootDir:=''; 
  saRequestMethod:='';
  saRequestType:='';
  saRequestedFile:='';
  saOriginallyREquestedFile:='';
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

  saActionType:='xml';// iwf specific - usually set to xml unless doing tricky 
                      // javascript client stuff
  MATRIX.DeleteAll;  
  LogXXDL.DeleteAll;
  iSessionResultCode:=cnSession_MeansErrorOccurred;// just resetting here
  clear_JSession(rJSession);
  rJSession.JSess_JSession_UID:='0';
  rJSession.JSess_IP_ADDR:='0.0.0.0';
  rJSession.JSess_PORT_u:='0';

  clear_JUser(rJUser);
  rJUser.JUser_Name:='Anonymous';
  
  // Do not touch JThread because its set when TCONTEXT created.
  //JThread
  SessionXDL.DeleteAll;
  bSaveSessionData:=false;
  bInternalJob:=false;
  JTrakXDL.DeleteAll;
  JTrak_TableID:='';
  JTrak_u2JDType:=0;
  JTRak_saPKeyCol:='';
  JTrak_DBConID:='0';
  JTrak_saUID:='';
  JTrak_bExist:=false;
  JTrak_saTable:='';
  if Process<>nil then
  begin
    Process.Destroy;Process:=nil;
  end;
  saColorTheme:='default';
  sIconTheme:='CrystalClear';
  u2LogType_ID:=0;
  bNoWebCache:=false;
  i4VHost:=-1;
  saAlias:='/';
  saServerURL:=grJASConfig.saServerURL;
  bMenuHasPAnels:=false;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================

//=============================================================================
function TCONTEXT.DBCON(p_saConnectionName: ANSISTRING): JADO_CONNECTION;
//=============================================================================
var
  i: longint;
  saUp: ansistring;
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
  saUp:=upcase(p_saConnectionName);
  i:=0;
  while(result=nil) and (i<length(JADOC)) do
  begin
    if (saUp=upcase(JADOC[i].saName)) then result:=JADOC[i];
    i+=1;
  end;
  if result = nil then
  begin
    saErr:='201203092111 - DBCON requested not present: '+p_saConnectionName;
    JASPrintln('');
    JASPrintln('');
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
function TCONTEXT.DBCON(p_JDCon_JDConnection_UID: UINT64): JADO_CONNECTION;
//=============================================================================
var
  i: integer;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.DBCON(p_JDCon_JDConnection_UID: UINT64): JADO_CONNECTION;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102234,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102235, sTHIS_ROUTINE_NAME);{$ENDIF}
  result:=nil;
  for i:=0 to length(JADOC)-1 do
  begin
    if p_JDCon_JDConnection_UID=u8Val(JADOC[i].ID) then
    begin
      result:=JADOC[i];
      exit;
    end;
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
    //AS_Log(self, cnLog_Debug,201210241556, 'LXML.saXML(FALSE,FALSE):',LXML.saXML(false,false),SOURCEFILE);
    bOk:=bLoadContextWithXML(LXML);
  end;
  result:=bOk;
  LXML.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203102239,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
          saRequestMethod:=XMLNODE.Item_saValue;
        end;
      end;

      if XMLNODE.FoundItem_saName('saRequestType',true) then
      begin
        if length(XMLNODE.Item_saValue)>0 then
        begin
          saRequestType:=XMLNODE.Item_saValue;
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

                      if XMLNODE4.FoundItem_saName('i8User',true) then
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

                    if XMLNODE4.FoundItem_saName('i8User',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.DATAIN.Item_i8User:=i8Val(XMLNODE4.Item_saValue);
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
        if XMLNODE2.FoundItem_saName('CKYIN',true) then
        begin
          XMLNODE3:=JFC_XML(XMLNODE2.Item_lpPtr);
          if XMLNODE3<>nil then
          begin
            if XMLNODE3.MoveFirst then
            begin
              repeat
                if XMLNode3.Item_saName='ITEM' then
                begin
                  CGIENV.CKYIN.AppendItem;
                  XMLNODE4:=JFC_XML(XMLNODE3.Item_lpPtr);
                  if XMLNODE4<>nil then
                  begin
                    if XMLNODE4.FoundItem_saName('lpPtr',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.CKYIN.Item_lpPtr:=pointer(UINT(u8Val(XMLNODE4.Item_saValue)));
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('UID',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        JFC_XDLITEM(CGIENV.CKYIN.lpItem).UID:=u8Val(XMLNODE4.Item_saValue);
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saName',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.CKYIN.Item_saName:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saValue',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.CKYIN.Item_saValue:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('saDesc',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.CKYIN.Item_saDesc:=XMLNODE4.Item_saValue;
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('i8User',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        CGIENV.CKYIN.Item_i8User:=i8Val(XMLNODE4.Item_saValue);
                      end;
                    end;

                    if XMLNODE4.FoundItem_saName('TS',true) then
                    begin
                      if length(XMLNODE4.Item_saValue)>0 then
                      begin
                        JFC_XDLITEM(CGIENV.CKYIN.lpItem).TS:=StrToTimeStamp(XMLNODE4.Item_saValue);
                      end;
                    end;
                  end;
                end;
              until not XMLNODE3.MoveNExt;
            end;
          end;
        end;
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
            CGIENV.iPostContentLength:=iVal(XMLNODE2.Item_saValue);
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
  XMLNODE.AppendItem_saName_N_saValue('bSessionValid',saYesNo(bSessionValid));
  XMLNODE.AppendItem_saName_N_saValue('bErrorCondition',saYesNo(bErrorCondition));
  XMLNODE.AppendItem_saName_N_saValue('u8ErrNo',inttostr(u8ErrNo));
  XMLNODE.AppendItem_saName_N_saValue('saErrMsg',saErrMsg);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saErrMsgMoreInfo',saErrMsgMoreInfo);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saServerIP',saServerIP);
  XMLNODE.AppendItem_saName_N_saValue('saServerPort',saServerPort);
  XMLNODE.AppendItem_saName_N_saValue('saPage',saPage);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('bLoginAttempt',saYesNo(bLoginAttempt));
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
      //XMLNODE3.AppendItem_saName_N_saValue('saMyPassword',JADOC[i].saMyPassword);
      XMLNODE3.AppendItem_saName_N_saValue('saMyDatabase',JADOC[i].saMyDatabase);
      XMLNODE3.AppendItem_saName_N_saValue('saMyServer',JADOC[i].saMyServer);
      XMLNODE3.AppendItem_saName_N_saValue('u4MyPort',inttostr(JADOC[i].u4MyPort));
    end;
  end;

  XMLNODE.AppendItem_saName_N_saValue('dtRequested',saFormatDateTime(csDATETIMEFORMAT,dtRequested));
  XMLNODE.AppendItem_saName_N_saValue('dtServed',saFormatDateTime(csDATETIMEFORMAT,dtServed));
  XMLNODE.AppendItem_saName_N_saValue('dtFinished',saFormatDateTime(csDATETIMEFORMAT,dtFinished));
  XMLNODE.AppendItem_saName_N_saValue('saLang',saLang);
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
  XMLNODE.AppendItem_saName_N_saValue('bOutputRaw',saYesNo(bOutputRaw));
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Area',saHTMLRIPPER_Area);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Page',saHTMLRIPPER_Page);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saHTMLRIPPER_Section',saHTMLRIPPER_Section);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('u8MenuTopID',inttostr(u8MenuTopID));
  XMLNODE.AppendItem_saName_N_saValue('iSessionResultCode',inttostr(iSessionResultCode));

  XMLNODE.AppendItem_saName_N_saValue('saUserCacheDir',saUserCacheDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('iErrorReportingMode',inttostr(iErrorReportingMode));
  XMLNODE.AppendItem_saName_N_saValue('iDebugMode',inttostr(iDebugMode));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute',saYesNo(bMIME_execute));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_Jegas',saYesNo(bMIME_execute_Jegas));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_JegasWebService',saYesNo(bMIME_execute_JegasWebService));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_php',saYesNo(bMIME_execute_php));
  XMLNODE.AppendItem_saName_N_saValue('bMIME_execute_perl',saYesNo(bMIME_execute_perl));
  XMLNODE.AppendItem_saName_N_saValue('saMimeType',saMimeType);
  XMLNODE.AppendItem_saName_N_saValue('bMimeSNR',saYesNo(bMimeSNR));
  XMLNODE.AppendItem_saName_N_saValue('saFileSoughtNoExt',saFileSoughtNoExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saFileSoughtExt',saFileSoughtExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saFileNameOnly',saFileNameOnly);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saFileNameOnlyNoExt',saFileNameOnlyNoExt);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saIN',saIN);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saOUT',saOUT);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName('REQVAR_XDL');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE2.bParseXML(REQVAR_XDL.saXML);
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE.AppendItem_saName_N_saValue('u8BytesRead',inttostr(u8BytesRead));
  XMLNODE.AppendItem_saName_N_saValue('u8BytesSent',inttostr(u8BytesSent));
  XMLNODE.AppendItem_saName_N_saValue('saRequestedHost',saRequestedHost);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedHostRootDir',saRequestedHostRootDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestMethod',saRequestMethod);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestType',saRequestType);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedFile',saRequestedFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saOriginallyRequestedFile',saOriginallyREquestedFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedName',saRequestedName);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saRequestedDir',saRequestedDir);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saFileSought',saFileSought);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('saQueryString',saQueryString);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('i4ErrorCode',inttostr(i4ErrorCode));
  XMLNODE.AppendItem_saName_N_saValue('saLogFile',saLogFile);XMLNODE.Item_bCData:=true;
  XMLNODE.AppendItem_saName_N_saValue('bJASCGI',saYesNo(bJASCGI));
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
  
  XMLNODE2.AppendItem_saName('CKYIN');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.CKYIN.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('CKYOUT');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.CKYOUT.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('HEADER');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.HEADER.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName('FILESIN');
  XMLNODE3:=JFC_XML.Create;
  XMLNODE3.bParseXML(CGIENV.FILESIN.saXML);
  XMLNODE2.Item_lpPtr:=XMLNODE3;
  
  XMLNODE2.AppendItem_saName_N_saValue('bPost',saYesNo(CGIENV.bPost));
  XMLNODE2.AppendItem_saName_N_saValue('saPostContentType',CGIENV.saPostContentType);XMLNODE2.Item_bCData:=true;
  XMLNODE2.AppendItem_saName_N_saValue('iPostContentLength',inttostr(CGIENV.iPostContentLength));
  XMLNODE2.AppendItem_saName_N_saValue('iTimeZoneOffset',inttostr(CGIENV.iTimeZoneOffset));
  XMLNODE2.AppendItem_saName_N_saValue('iHTTPResponse',inttostr(CGIENV.iHTTPResponse));
  XMLNODE2.AppendItem_saName_N_saValue('saServerSoftware',CGIENV.saServerSoftware);XMLNODE2.Item_bCData:=true;

  XMLNODE.AppendItem_saName_N_saValue('saActionType',saActionType);

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
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JSession_UID',rJSession.JSess_JSession_UID);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JSessionType_ID',rJSession.JSess_JSessionType_ID);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JUser_ID',rJSession.JSess_JUser_ID);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_Connect_DT',rJSession.JSess_Connect_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_LastContact_DT',rJSession.JSess_LastContact_DT);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_IP_ADDR',rJSession.JSess_IP_ADDR);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_PORT_u',rJSession.JSess_PORT_u);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_Username',rJSession.JSess_Username);
  XMLNODE2.AppendItem_saName_N_saValue('JSess_JJobQ_ID',rJSession.JSess_JJobQ_ID);

  XMLNODE.AppendItem_saName('rJUser');
  XMLNODE2:=JFC_XML.Create;
  XMLNODE.Item_lpPtr:=XMLNODE2;
  XMLNODE2.AppendItem_saName_N_saValue('JUser_JUser_UID',inttostr(rJUser.JUser_JUser_UID));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Name',rJUser.JUser_Name);
  //XMLNODE2.AppendItem_saName_N_saValue('JUser_Password',rJUser.JUser_Password);
  XMLNODE2.AppendItem_saName_N_saValue('JUser_JPerson_ID',inttostR(rJUser.JUser_JPerson_ID));
  XMLNODE2.AppendItem_saName_N_saValue('JUser_Enabled_b',saTrueFalsE(rJUser.JUser_Enabled_b));
  if garJVHostLight[i4VHost].saServerDomain='default' then
  begin
    XMLNODE2.AppendItem_saName_N_saValue('JUser_Admin_b',satrueFalse(rJUser.JUser_Admin_b));
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
  XMLNODE.AppendItem_saName_N_saValue('bSaveSessionData',saYesNo(bSaveSessionData));
  XMLNODE.AppendItem_saName_N_saValue('bInternalJob',saYesNo(bInternalJob));
  XMLNODE.AppendItem_saName_N_saValue('bMenuHasPanels',saYesNo(bMenuHasPanels));

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
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.JAS_SNR;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203102246,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203102247, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=nil;
  RS:=Nil;
  iJSecKey:=0;
  u8Zero:=0;
  bPerformSNR:=false;
  //ASPrintln('In TCONTEXT.JAS_SNR');
  //ASPrintln('MIME: '+saMimeType+' SNR Flag: '+saTRUEFALSE(bPerformSNR));
  u8TempOutLen:=length(saOut);
  if (u8TempOutLen>u8Zero) then
  begin
    //ASPrintln('In TCONTEXT.JAS_SNR: got good length');
    //if CGIENV.HEADER.FoundItem_saName(csINET_HDR_CONTENT_TYPE,true) then
    //begin
    //  saMimeType:=CGIENV.HEADER.Item_saValue;
    //end;
    if saMimeType<>'application/force-download' then
    begin
      //ASPrintln('In TCONTEXT.JAS_SNR: In Server Mode. Hunting for mime type:'+saMimeType);
      bPerformSNR:=false;
      if length(garJMimeLight)>0 then
      begin
        for i:=0 to length(garJMimeLight)-1 do
        begin
          //ASPrintln('JAS_SNR - garJMimeLight[i].saType: '+garJMimeLight[i].saType+' MimeType: '+saMimeType);
          if garJMimeLight[i].saType=saMimeType then
          begin
            //ASPrintln('JAS_SNR - Found Mime garJMimeLight[i].bSNR: '+satrueFalse(garJMimeLight[i].bSNR));
            bPerformSNR:=garJMimeLight[i].bSNR;
            break;
          end;
        end;
      end;

      if bPerformSNR then
      begin
        //ASPrintln('Preforming SNR - PageSNRXDL.ListCount :' +inttostR(PageSNRXDL.ListCount));
        PAGESNRXDL.AppendItem_SNRPair('[@LANG@]', saLang);
        PAGESNRXDL.AppendItem_SNRPair('[@HELPID@]', saHelpID);
        PAGESNRXDL.AppendItem_SNRPair('[@ERRORCONDITION@]',saTrueFalse(bErrorCondition));//TODO: Make context sensitive, no reason to have this place holder all the time
        PAGESNRXDL.AppendItem_SNRPair('[@ERRORNUMBER@]',inttostr(u8ErrNo));//TODO: Make context sensitive, no reason to have this place holder all the time
        PAGESNRXDL.AppendItem_SNRPair('[@USERID@]',inttostR(rJUser.JUser_JUser_UID));
        PAGESNRXDL.AppendItem_SNRPair('[@USERNAME@]',rJUser.JUser_Name);
        PAGESNRXDL.AppendItem_SNRPair('[@REMOTEIP@]',rJSession.JSess_IP_ADDR);
        PAGESNRXDL.AppendItem_SNRPair('[@JSID@]',rJSession.JSess_JSession_UID);
        PAGESNRXDL.AppendItem_SNRPair('[@SESSIONVALID@]',saYesNo(bSessionValid));
        //---menu global nav
        PAGESNRXDL.AppendItem_SNRPair('[@JASNAME@]',garJVHostLight[i4VHost].saServerName);
        PAGESNRXDL.AppendItem_SNRPair('[@JASID@]',garJVHostLight[i4VHost].saServerIdent);
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
        PAGESNRXDL.AppendItem_SNRPAIR('<? echo $JASDIRWEBSHARE; ?>',grJASConfig.saWebShareAlias);
        PAGESNRXDL.AppendItem_SNRPAIR('[@JASDIRWEBSHARE@]',grJASConfig.saWebShareAlias);

        // Echo3 GUI Related---
        //Context.PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRICON; ?>',grJASConfig.saWebShareAlias+'img/icon/VistaInspirate/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.Appenditem_saName_N_saValue('[@SERVERURL@]',saServerURL);
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRICONTHEME@]',grJASConfig.saWebShareAlias+'img/icon/themes/'+sIconTheme+'/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRICONTHEME; ?>',grJASConfig.saWebShareAlias+'img/icon/themes/'+sIconTheme+'/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRICON@]',grJASConfig.saWebShareAlias+'img/icon/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRICON; ?>',grJASConfig.saWebShareAlias+'img/icon/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRBACKGROUND@]',grJASConfig.saWebShareAlias+'img/background/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRBACKGROUND; ?>',grJASConfig.saWebShareAlias+'img/background/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRLOGO@]',grJASConfig.saWebShareAlias+'img/logo/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRLOGO; ?>',grJASConfig.saWebShareAlias+'img/logo/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRWINDOW@]',grJASConfig.saWebShareAlias+'img/window/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRWINDOW; ?>',grJASConfig.saWebShareAlias+'img/window/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRWORKSPACE@]',grJASConfig.saWebShareAlias+'img/workspace/slate/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRWORKSPACE; ?>',grJASConfig.saWebShareAlias+'img/workspace/slate/');//hardcoded for now. casesensitive, path in echo3 gui to theme
        // Echo3 GUI Related---
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRIMG@]',grJASConfig.saWebShareAlias+'img/');
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRIMG; ?>',grJASConfig.saWebShareAlias+'img/');
        PAGESNRXDL.AppendItem_SNRPair('[@JASDIRTHEME@]',grJASConfig.saJASDirTheme);// path to current theme e.g. for "Stock Theme" might become in a URL: /jws/themes/stock/
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASDIRTHEME; ?>',grJASConfig.saJASDirTheme);

        PAGESNRXDL.AppendItem_SNRPair('[@JASTHEME@]',saColorTheme);// e.g.: stock
        PAGESNRXDL.AppendItem_SNRPair('<? echo $JASTHEME; ?>',saColorTheme);

        //PAGESNRXDL.AppendItem_SNRPair('[@JASTHEMENAME@]',grJASConfig.saDefaultThemeName);// human name
        //PAGESNRXDL.AppendItem_SNRPair('<? echo $JASTHEMENAME; ?>',grJASConfig.saDefaultThemeName);
        //PAGESNRXDL.AppendItem_SNRPair('[@JASTHEMEAUTHOR@]',grJASConfig.saDefaultThemeAuthor);// them author
        //PAGESNRXDL.AppendItem_SNRPair('<? echo $JASTHEMEAUTHOR; ?>',grJASConfig.saDefaultThemeAuthor);
        PAGESNRXDL.AppendItem_SNRPAIR('[@NOW@]',JDATE('',11,0,dtRequested));
  
        dtServed:=now;
        PAGESNRXDL.AppendItem_SNRPAIR('[@PTMILLI@]',saStr(iDiffMSec(dtRequested, dtserved)));

        //--JAS THEME HEADER
        if Upcase(CGIENV.CKYIN.Get_saValue('JASDISPLAYHEADERS'))<>'OFF' then
        begin
          PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]',sadecodeURI(saJThemeColorHeader(saColorTheme)));
        end
        else
        begin
          PAGESNRXDL.AppendItem_SNRPAir('[@JASTHEMEHEADER@]','');
        end;

        PAGESNRXDL.AppendItem_SNRPAIR('[@ALIAS@]',saAlias);

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
              'JSKey_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
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
Procedure TCONTEXT.JTrakBegin(p_DBCon: JADO_CONNECTION; p_saTable: ansistring; p_saUID: ansistring);
//=============================================================================
Var
  bOk: boolean;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='TCONTEXT.JTrakBegin(p_DBCon: JADO_CONNECTION; p_saTable: ansistring; p_saUID: ansistring);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBIN(201203252228,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}JThread.TrackThread(201203252228, sTHIS_ROUTINE_NAME);{$ENDIF}
  if rJUser.JUser_Audit_b then
  begin
    DBC:=VHDBC;
    rs:=JADO_RECORDSET.Create;
    JTrakXDL.DeleteAll;
    JTrak_TableID:=DBC.saGetTableID(p_DBCon.ID,p_saTable,201210012302);
    JTrak_saTable:=p_saTable;
    JTrak_u2JDType:=0;
    JTRak_saPKeyCol:='';
    JTrak_DBConID:=p_DBCON.ID;
    JTrak_saUID:=p_saUID;


    saQry:='select JColu_Name, JColu_JDType_ID from jcolumn where JColu_JTable_ID='+
      JTrak_TableID + ' and JColu_PrimaryKey_b = ' + DBC.saDBMSBoolScrub(true) +
      ' and JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
    bOk:=rs.open(saQry,DBC,201503161710);
    if not bOk then
    begin
      JAS_LOG(self, cnLog_Error, 201203260022, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,RS);
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
      JTrak_saPKeyCol:=rs.fields.Get_saValue('JColu_Name');
      JTrak_u2JDType:=u2Val(rs.fields.Get_saValue('JColu_JDType_ID'));
      case JTrak_u2JDType of
      cnJDType_Unknown: saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_b      : saQry:=p_DBCon.saDBMSBoolScrub(p_saUID);
      cnJDType_i1     : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_i2     : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_i4     : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_i8     : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_i16    : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_i32    : saQry:=p_DBCon.saDBMSIntScrub(p_saUID);
      cnJDType_u1     : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_u2     : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_u4     : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_u8     : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_u16    : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_u32    : saQry:=p_DBCon.saDBMSUIntScrub(p_saUID);
      cnJDType_fp     : saQry:=p_DBCon.saDBMSDecScrub(p_saUID);
      cnJDType_fd     : saQry:=p_DBCon.saDBMSDecScrub(p_saUID);
      cnJDType_cur    : saQry:=p_DBCon.saDBMSDecScrub(p_saUID);
      cnJDType_ch     : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_chu    : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_dt     : saQry:=p_DBCon.saDBMSDateScrub(p_saUID);
      cnJDType_s      : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_su     : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_sn     : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_sun    : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      cnJDType_bin    : saQry:=p_DBCon.saDBMSScrub(p_saUID);
      end;//switch
      saQry:='select * from ' + p_saTable + ' where ' + JTrak_saPKeyCol + '=' + saQry;
    end;
    rs.close;

    if bOk then
    begin
      bOk:=rs.open(saQry, p_DBCon,201503161711);
      if not bOk then
      begin
        JAS_LOG(self, cnLog_Error, 201203260024, 'Trouble with query.','Query: '+saQry,SOURCEFILE,p_DBCON,rs);
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
Procedure TCONTEXT.JTrakEnd(p_saUID: ansistring; p_saSQL: Ansistring);
//=============================================================================
Var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  Final_saUID: ansistring;
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
    TGT:=JADOC[u8Val(JTrak_DBConID)];
    RS:=JADO_RECORDSET.Create;
    XDL:=JFC_XDL.Create;
    Final_dtWhen:=now;
    bFirstFieldSaved:=false;


    case JTrak_u2JDType of
    cnJDType_Unknown: saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_b      : saQry:=TGT.saDBMSBoolScrub(p_saUID);
    cnJDType_i1     : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_i2     : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_i4     : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_i8     : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_i16    : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_i32    : saQry:=TGT.saDBMSIntScrub(p_saUID);
    cnJDType_u1     : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_u2     : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_u4     : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_u8     : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_u16    : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_u32    : saQry:=TGT.saDBMSUIntScrub(p_saUID);
    cnJDType_fp     : saQry:=TGT.saDBMSDecScrub(p_saUID);
    cnJDType_fd     : saQry:=TGT.saDBMSDecScrub(p_saUID);
    cnJDType_cur    : saQry:=TGT.saDBMSDecScrub(p_saUID);
    cnJDType_ch     : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_chu    : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_dt     : saQry:=TGT.saDBMSDateScrub(p_saUID);
    cnJDType_s      : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_su     : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_sn     : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_sun    : saQry:=TGT.saDBMSScrub(p_saUID);
    cnJDType_bin    : saQry:=TGT.saDBMSScrub(p_saUID);
    end;//switch
    saQry:='select * from ' + JTrak_saTable + ' where ' + JTrak_saPKeyCol + '=' + saQry;
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
      if not Final_bCreate then //make sure not a flagged delete
      saQry:='select JTabl_ColumnPrefix from jtable where JTabl_JTable_UID='+JTrak_TableID;
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
      if Final_bCreate then Final_saUID:=JTrak_saUID else Final_saUID:=p_saUID;
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
              'JColu_JTable_ID='+JTrak_TableID+' and ' +
              'JColu_Name='+DBC.saDBMSScrub(XDL.Item_saName)+' and '+
              'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
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
                JTrak_JDConnection_ID     :=JTrak_DBConID;
                JTrak_JSession_ID         :=rJSession.JSess_JSession_UID;
                JTrak_JTable_ID           :=JTrak_TableID;
                JTrak_Row_ID              :=Final_saUID;
                JTrak_Col_ID              :=rs.fields.Get_saValue('JColu_JColumn_UID');
                JTrak_JUser_ID            :=inttostr(rJUser.JUser_JUser_UID);
                JTrak_Create_b            :=saYesNo(Final_bCreate);
                JTrak_Modify_b            :=saYesNo(Final_bModify);
                JTrak_Delete_b            :=saYesNo(Final_bDelete);
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
                    DBC.saDBMSUIntScrub(JTrak_JDConnection_ID)+','+
                    DBC.saDBMSUIntScrub(JTrak_JSession_ID    )+','+
                    DBC.saDBMSUIntScrub(JTrak_JTable_ID      )+','+
                    DBC.saDBMSUIntScrub(JTrak_Row_ID         )+','+
                    DBC.saDBMSUIntScrub(JTrak_Col_ID         )+','+
                    DBC.saDBMSUIntScrub(JTrak_JUser_ID       )+','+
                    DBC.saDBMSBoolScrub(JTrak_Create_b       )+','+
                    DBC.saDBMSBoolScrub(JTrak_Modify_b       )+','+
                    DBC.saDBMSBoolScrub(JTrak_Delete_b       )+','+
                    DBC.saDBMSDateScrub(JTrak_When_DT        )+','+
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
  if(iDebugMode <> cnSYS_INFO_MODE_SECURE) and
    ((((rJSession.JSess_IP_ADDR='127.0.0.1') or (rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
     (iDebugMode = cnSYS_INFO_MODE_VERBOSE) ) then
  begin
    //ASPrintln('CALLED DebugHTMLOutput Accepted');
    //saTemplate:=saLoadTextFile(saGetPage(SELF,'','sys_debug','MAIN',true,'',201209141029);
    //saFilename:=grJASConfig.saTemplatesDir+lowercase(saLang)+csDOSSLASH+'sys_debug.jas';
    saFilename:=garJVHostLight[i4VHost].saTemplateDir+lowercase(saLang)+csDOSSLASH+'sys_debug.jas';
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

    
    saTitle:='Cookie Data Coming In. Class: JFC_CGIENV.CKYIN';
    saMessage:=CGIENV.CKYIN.saHTMLTable(
      '',
      True,
      'CGIENV.CKYIN (JFC_CGIENV.JFC_XDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0
    );
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;



    
    saTitle:='Cookie Data Sent Out. Class: JFC_CGIENV.CKYOUT';
    saMessage:=CGIENV.CKYOUT.saHTMLTable(
      '',
      True,
      'CGIENV.CKYOUT (JFC_CGIENV.JFC_XDL) Rows: ',
      True,
      True,
      'Row', 1,
      '',0,
      'UID', 4,
      'Name',2,
      'Value',3,
      '',0,
      '',0,
      '',0
    );
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;


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
      '      <tr class="r2"><td>bPost</td><td>'+saTRueFalse(CGIENV.bPost)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPostContentType</td><td>'+CGIENV.saPostContentType+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iPostContentLength</td><td>'+inttostr(CGIENV.iPostContentLength)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPostData</td><td>'+CGIENV.saPostData+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iTimeZoneOffset</td><td>'+inttostr(CGIENV.iTimeZoneOffset)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>iHTTPResponse</td><td>'+inttostr(CGIENV.iHTTPResponse)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saServerSoftware</td><td>'+CGIENV.saServerSoftware+'</td></tr>'+csCRLF+
      '      </tbody>'+ csCRLF+
      '      </table>'+ csCRLF+
      '    </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;




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
      '      <tr class="r2"><td>saServerIP</td><td>'+saServerIP+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saServerPort</td><td>'+saServerPort+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saOut</td><td>This Page</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bLoginAttempt</td><td>'+saYesNo(bLoginAttempt)+'</td></tr>'+csCRLF+
      //'      <tr class="r2"><td>saLoginMsg</td><td>'+saLoginMsg+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bRedirection</td><td>'+saYesNo(bRedirection)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPageTitle</td><td>'+saPageTitle+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>dtRequested</td><td>'+saFormatDateTime(csDATETIMEFORMAT,dtRequested)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saLang</td><td>'+saLang+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bOutputRaw</td><td>'+saTrueFalse(bOutputRaw)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saHTMLRIPPER_Area</td><td>'+saHTMLRIPPER_Area+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saHTMLRIPPER_Page</td><td>'+saHTMLRIPPER_Page+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saHTMLRIPPER_Section</td><td>'+saHTMLRIPPER_Section+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saUserCacheDir</td><td>'+saUserCacheDir+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>iErrorReportingMode (context based) </td>'+csCRLF;saMessage+='<td>';
    case iErrorReportingMode of
    cnSYS_INFO_MODE_VERBOSELOCAL: saMessage+='cnSYS_INFO_MODE_VERBOSELOCAL';
    cnSYS_INFO_MODE_VERBOSE: saMessage+='cnSYS_INFO_MODE_VERBOSE';
    else saMessage+='cnSYS_INFO_MODE_SECURE';
    end;//endcase
    saMessage+='</td></tr>'+csCRLF;
    saMessage+='      <tr class="r2"><td>iDebugMode (context based) </td><td>';
    case iDebugMode of
    cnSYS_INFO_MODE_VERBOSELOCAL: saMessage+='cnSYS_INFO_MODE_VERBOSELOCAL';
    cnSYS_INFO_MODE_VERBOSE: saMessage+='cnSYS_INFO_MODE_VERBOSE';
    else saMessage+='cnSYS_INFO_MODE_SECURE';
    end;//endcase
    saMessage+='</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute</td><td>'+saTrueFalse(bMIME_execute)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bMIME_execute_Jegas</td><td>'+saTrueFalse(bMIME_execute_Jegas)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute_JegasWebService</td><td>'+saTrueFalse(bMIME_execute_JegasWebService)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bMIME_execute_php</td><td>'+saTrueFalse(bMIME_execute_php)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMIME_execute_perl</td><td>'+saTrueFalse(bMIME_execute_perl)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saMimeType</td><td>'+saMimeType+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMimeSNR</td><td>'+saTrueFalse(bMimeSNR)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saFileSoughtNoExt</td><td>'+saFileSoughtNoExt+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saFileSoughtExt</td><td>'+saFileSoughtExt+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saFileNameOnly</td><td>'+saFileNameOnly+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saFileNameOnlyNoExt</td><td>'+saFileNameOnlyNoExt+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saIN</td><td>'+saIN+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saOut</td><td>View the Source for this information.</td></tr>'+csCRLF+     //+saOut+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u8BytesRead</td><td>'+inttostr(u8BytesRead)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>u8BytesSent</td><td>'+inttostr(u8BytesSent)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestedHost</td><td>'+saRequestedHost+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestedHostRootDir</td><td>'+saRequestedHostRootDir+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestMethod</td><td>'+saRequestMethod+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestType</td><td>'+saRequestType+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestedFile</td><td>'+saRequestedFile+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saOriginallyRequestedFile</td><td>'+saOriginallyREquestedFile+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saRequestedName</td><td>'+saRequestedName+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saRequestedDir</td><td>'+saRequestedDir+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saFileSought</td><td>'+saFileSought+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saQueryString</td><td>'+saQueryString+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>i4ErrorCode</td><td>'+inttostr(i4ErrorCode)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saLogFile</td><td>'+saLogFile+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bJASCGI</td><td>'+saTrueFalsE(bJASCGI)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saActionType</td><td>'+saActionType+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iSessionrResultCode</td><td>'+inttostR(iSessionResultCode)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread</td><td></td><td>'+inttostr(UINT(JThread))+'</td></tr>'+csCRLF+
      
      '      <tr class="r1"><td>JThread.i8Stage</td><td>'+inttostr(JThread.i8Stage)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.saStageNote</td><td>'+JThread.saStageNote+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.UID</td><td>'+inttostr(JThread.UID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.Suspended</td><td>'+saTrueFalse(JThread.Suspended)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.lpParent</td><td>'+inttostr(UINT(JThread.lpParent))+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.iExecuteIterations</td><td>'+inttostr(JThread.iExecuteIterations)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.dtCreated</td><td>'+FormatDateTime(csDATETIMEFORMAT,JThread.dtCreated)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.dtExecuteBegin</td><td>'+FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteBegin)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JThread.dtExecuteEnd</td><td>'+FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteEnd)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.bShuttingDown</td><td>'+saTRueFalse(JThread.bShuttingDown)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JThread.bLoopContinuously</td><td>'+saTRueFalse(JThread.bLoopContinuously)+'</td></tr>'+csCRLF+

      '      <tr class="r2"><td>bSaveSessionData</td><td>'+saTrueFalsE(bSaveSessionData)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bInternalJob</td><td>'+saTrueFalsE(bInternalJob)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>u8MenuTopID</td><td>'+inttostr(u8MenuTopID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>saPage</td><td>'+saPage+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saPageTitle</td><td>'+saPageTitle+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>dtRequested</td><td>'+saFormatDateTime(csDATETIMEFORMAT,dtRequested)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>iDebugMode</td><td>'+inttostr(iDebugMode)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bJASCGI</td><td>'+saTruefalse(bJASCGI)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrakXDL</td><td>'+JTrakXDL.saXML+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_TableID</td><td>'+JTrak_TableID+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_u2JDType</td><td>'+inttostr(JTrak_u2JDType)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTRak_saPKeyCol</td><td>'+JTRak_saPKeyCol+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_DBConID</td><td>'+JTrak_DBConID+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_saUID</td><td>'+JTrak_saUID+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>JTrak_bExist</td><td>'+saTRueFalse(JTrak_bExist)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>JTrak_saTable</td><td>'+JTrak_saTable+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saColorTheme</td><td>'+saColorTheme+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>i4VHost</td><td>'+inttostr(i4VHost)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>saAlias</td><td>'+saAlias+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>bMenuHasPanels</td><td>'+saTrueFalse(bMenuHasPanels)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>sIconTheme</td><td>'+sIconTheme+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>u2LogType_ID</td><td>'+inttostr(u2LogType_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>bNoWebCache</td><td>'+saTrueFalse(bNoWebCache)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JSession_UID</td><td>'+rJSession.JSess_JSession_UID+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_JSessionType_ID</td><td>'+rJSession.JSess_JSessionType_ID+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JUser_ID</td><td>'+rJSession.JSess_JUser_ID+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_Connect_DT</td><td>'+rJSession.JSess_Connect_DT+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_LastContact_DT</td><td>'+rJSession.JSess_LastContact_DT+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_IP_ADDR</td><td>'+rJSession.JSess_IP_ADDR+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_PORT_u</td><td>'+rJSession.JSess_PORT_u+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJSession.JSess_Username</td><td>'+rJSession.JSess_Username+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJSession.JSess_JJobQ_ID</td><td>'+rJSession.JSess_JJobQ_ID+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_JUser_UID</td><td>'+inttostr(rJUser.JUser_JUser_UID)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Name</td><td>'+rJUser.JUser_Name+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Password</td><td>Withheld</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_JPerson_ID</td><td>'+inttostR(rJUser.JUser_JPerson_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Enabled_b</td><td>'+saTRueFalse(rJUser.JUser_Enabled_b)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Login_First_DT</td><td>'+rJUser.JUser_Login_First_DT+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Login_Last_DT</td><td>'+rJUser.JUser_Login_Last_DT+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Logins_Successful_u</td><td>'+inttostr(rJUser.JUser_Logins_Successful_u)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Logins_Failed_u</td><td>'+inttostr(rJUser.JUser_Logins_Failed_u)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Password_Changed_DT</td><td>'+rJUser.JUser_Password_Changed_DT+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_AllowedSessions_u</td><td>'+inttostr(rJUser.JUser_AllowedSessions_u)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_DefaultPage_Login</td><td>'+rJUser.JUser_DefaultPage_Login+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_DefaultPage_Logout</td><td>'+rJUser.JUser_DefaultPage_Logout+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_JLanguage_ID</td><td>'+inttostR(rJUser.JUser_JLanguage_ID)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_Audit_b</td><td>'+saTRueFalse(rJUser.JUser_Audit_b)+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_ResetPass_u</td><td>'+inttostr(rJUser.JUser_ResetPass_u)+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_CreatedBy_JUser_ID</td><td>'+rJUser.JUser_CreatedBy_JUser_ID+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Created_DT</td><td>'+rJUser.JUser_Created_DT+'</td></tr>'+csCRLF+
      '      <tr class="r2"><td>rJUser.JUser_ModifiedBy_JUser_ID</td><td>'+rJUser.JUser_ModifiedBy_JUser_ID+'</td></tr>'+csCRLF+
      '      <tr class="r1"><td>rJUser.JUser_Modified_DT</td><td>'+rJUser.JUser_Modified_DT+'</td></tr>'+csCRLF;
    if garJVHostLight[i4VHost].saServerDomain='default' then
    begin
      saMessage+='      <tr class="r2"><td>rJUser.JUser_Admin_b</td><td>'+saTrueFalsE(rJUser.JUser_Admin_b)+'</td></tr>'+csCRLF;
    end;
    saMessage+=
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
      '    <tr class="r2"><td>saSysDir</td><td>'+grJASConfig.saSysDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saConfigDir</td><td>'+grJASConfig.saConfigDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saFileDir</td><td>'+grJASConfig.saFileDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saWebshareDir</td><td>'+grJASConfig.saWebshareDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saCacheDir</td><td>'+grJASConfig.saCacheDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saLogDir</td><td>'+grJASConfig.saLogDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saThemeDir</td><td>'+grJASConfig.saThemeDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saWebRootDir</td><td>'+grJASConfig.saWebRootDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saBinDir</td><td>'+grJASConfig.saBinDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saSetupDir</td><td>'+grJASConfig.saSetupDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saSoftwaredir</td><td>'+grJASConfig.saSoftwaredir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saSrcDir</td><td>'+grJASConfig.saSrcDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDataBaseDir</td><td>'+grJASConfig.saDataBaseDir+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saPHPDir</td><td>'+grJASConfig.saPHPDir+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDBCFileName</td><td>'+grJASConfig.saDBCFileName+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saConfigFile</td><td>'+grJASConfig.saConfigFile+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saPHP</td><td>'+grJASConfig.saPHP+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saPerl</td><td>'+grJASConfig.saPerl+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDiagnosticLogFileName</td><td>'+grJASConfig.saDiagnosticLogFileName+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saJASFooter</td><td>'+grJASConfig.saJASFooter+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saWebShareAlias</td><td>'+grJASConfig.saWebShareAlias+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saJASDirTheme</td><td>'+grJASConfig.saJASDirTheme+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saServerURL</td><td>'+grJASConfig.saServerURL+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saServerName</td><td>'+grJASConfig.saServerName+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saServerIdent</td><td>'+grJASConfig.saServerIdent+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saServerSoftware</td><td>'+grJASConfig.saServerSoftware+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDefaultArea</td><td>'+grJASConfig.saDefaultArea+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saDefaultPage</td><td>'+grJASConfig.saDefaultPage+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDefaultSection</td><td>'+grJASConfig.saDefaultSection+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>u1PasswordKey</td><td>'+inttostr(grJASConfig.u1PasswordKey)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDefaultLanguage</td><td>'+grJASConfig.saDefaultLanguage+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>u1DefaultMenuRenderMethod</td><td>'+inttostr(grJASConfig.u1DefaultMenuRenderMethod)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saServerIP</td><td>'+grJASConfig.saServerIP+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>u2ServerPort</td><td>'+inttostr(grJASConfig.u2ServerPort)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iRetryLimit</td><td>'+inttostr(grJASConfig.iRetryLimit)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iRetryDelayInMSec</td><td>'+inttostr(grJASConfig.iRetryDelayInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iTIMEZONEOFFSET</td><td>'+inttostr(grJASConfig.iTIMEZONEOFFSET)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iMaxFileHandles</td><td>'+inttostr(grJASConfig.iMaxFileHandles)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bBlacklistEnabled</td><td>'+saTrueFalse(grJASConfig.bBlacklistEnabled)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bWhiteListEnabled</td><td>'+saTruefalse(grJASConfig.bWhiteListEnabled)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bJobQEnabled</td><td>'+saTruefalse(grJASConfig.bJobQEnabled)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iJobQIntervalInMSec</td><td>'+inttostr(grJASConfig.iJobQIntervalInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>u8DefaultTop_JMenu_ID</td><td>'+inttostr(grJASConfig.u8DefaultTop_JMenu_ID)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bDirectoryListing</td><td>'+saTruefalse(grJASConfig.bDirectoryListing)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bDataOnRight</td><td>'+satrueFalse(grJASConfig.bDataOnRight)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>sCacheMaxAgeInSeconds</td><td>'+grJASConfig.sCacheMaxAgeInSeconds+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>sSMTPHost</td><td>'+grJASConfig.sSMTPHost+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>sSMTPUsername</td><td>'+grJASConfig.sSMTPUsername+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>sSMTPPassword</td><td>'+grJASConfig.sSMTPPassword+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>sSystemEmailFromAddress</td><td>'+grJASConfig.sSystemEmailFromAddress+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bProtectJASRecords</td><td>'+saTrueFalse(grJASConfig.bProtectJASRecords)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bSafeDelete</td><td>'+satruefalse(grJASConfig.bSafeDelete)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iThreadPoolNoOfThreads</td><td>'+inttostr(grJASConfig.iThreadPoolNoOfThreads)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iThreadPoolMaximumRunTimeInMSec</td><td>'+inttostr(grJASConfig.iThreadPoolMaximumRunTimeInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iLogLevel</td><td>'+inttostr(grJASConfig.iLogLevel)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bLogMessagesShowOnServerConsole</td><td>'+saTrueFalse(grJASConfig.bLogMessagesShowOnServerConsole)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bDeleteLogFile</td><td>'+satrueFalsE(grJASConfig.bDeleteLogFile)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iErrorReportingMode</td><td>'+inttostr(grJASConfig.iErrorReportingMode)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saErrorReportingSecureMessage</td><td>'+grJASConfig.saErrorReportingSecureMessage+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bServerConsoleMessagesEnabled</td><td>'+saTrueFalsE(grJASConfig.bServerConsoleMessagesEnabled)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bDebugServerConsoleMessagesEnabled</td><td>'+satrueFalse(grJASConfig.bDebugServerConsoleMessagesEnabled)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iDebugMode</td><td>'+inttostr(grJASConfig.iDebugMode)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iSessionTimeOutInMinutes</td><td>'+inttostr(grJASConfig.iSessionTimeOutInMinutes)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iLockTimeOutInMinutes</td><td>'+inttostr(grJASConfig.iLockTimeOutInMinutes)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iLockRetriesBeforeFailure</td><td>'+inttostr(grJASConfig.iLockRetriesBeforeFailure)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iLockRetryDelayInMSec</td><td>'+inttostr(grJASConfig.iLockRetryDelayInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iValidateSessionRetryLimit</td><td>'+inttostr(grJASConfig.iValidateSessionRetryLimit)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>i8MaximumRequestHeaderLength</td><td>'+inttostr(grJASConfig.i8MaximumRequestHeaderLength)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iCreateSocketRetry</td><td>'+inttostr(grJASConfig.iCreateSocketRetry)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>iCreateSocketRetryDelayInMSec</td><td>'+inttostr(grJASConfig.iCreateSocketRetryDelayInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>iSocketTimeOutInMSec</td><td>'+inttostr(grJASConfig.iSocketTimeOutInMSec)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>bEnableSSL</td><td>'+saTRueFalse(grJASConfig.bEnableSSL)+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saHOOK_ACTION_CREATESESSION_FAILURE</td><td>'+grJASConfig.saHOOK_ACTION_CREATESESSION_FAILURE+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saHOOK_ACTION_CREATESESSION_SUCCESS</td><td>'+grJASConfig.saHOOK_ACTION_CREATESESSION_SUCCESS+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saHOOK_ACTION_REMOVESESSION_FAILURE</td><td>'+grJASConfig.saHOOK_ACTION_REMOVESESSION_FAILURE+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saHOOK_ACTION_REMOVESESSION_SUCCESS</td><td>'+grJASConfig.saHOOK_ACTION_REMOVESESSION_SUCCESS+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saHOOK_ACTION_SESSIONTIMEOUT</td><td>'+grJASConfig.saHOOK_ACTION_SESSIONTIMEOUT+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saHOOK_ACTION_VALIDATESESSION_FAILURE</td><td>'+grJASConfig.saHOOK_ACTION_VALIDATESESSION_FAILURE+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saHOOK_ACTION_VALIDATESESSION_SUCCESS</td><td>'+grJASConfig.saHOOK_ACTION_VALIDATESESSION_SUCCESS+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saClientToVICIServerIP</td><td>'+grJASConfig.saClientToVICIServerIP+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saJASServertoVICIServerIP</td><td>'+grJASConfig.saJASServertoVICIServerIP+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saDefaultColorTheme</td><td>'+grJASConfig.saDefaultColorTheme+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>bDefaultSharesDefaultDomain</td><td>'+saTrueFalsE(grJASConfig.bDefaultSharesDefaultDomain)+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saDefaultIconTheme</td><td>'+grJASConfig.saDefaultIconTheme+'</td></tr>'+csCRLF+
      '    <tr class="r1"><td>saDefaultAccessLog</td><td>'+grJASConfig.saDefaultAccessLog+'</td></tr>'+csCRLF+
      '    <tr class="r2"><td>saDefaultErrorLog</td><td>'+grJASConfig.saDefaultErrorLog+'</td></tr>'+csCRLF+
      '    </tbody>'+ csCRLF+
      '    </table>'+ csCRLF+
      '  </div>'+ csCRLF;
    sa:=saSNRStr(saTemplate, '[@TITLE@]', saTitle);
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
    saOut+=sa;




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
        '    <tr class="r2"><td>ID</td><td>'+JADOC[i].ID+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>JDCon_JSecPerm_ID</td><td>'+JADOC[i].JDCon_JSecPerm_ID+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>u2DbmsID</td><td>';
      case JADOC[i].u2DbmsID of
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
        '    <tr class="r1"><td>saConnectionString</td><td>'+JADOC[i].saConnectionString+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDefaultDatabase</td><td>'+JADOC[i].saDefaultDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saProvider</td><td>'+JADOC[i].saProvider+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>i4State</td><td>';
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
        '    <tr class="r2"><td>saVersion</td><td>'+JADOC[i].saVersion+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>u2DrivID</td><td>';
      case JADOC[i].u2DrivID of
      cnDriv_ODBC: saMessage+='ODBC';
      cnDriv_MySQL: saMessage+='MySQL API';
      else begin saMessage+='Unknown'; end;
      end;//case
      saMessage+=
        '</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saMyUsername</td><td>'+JADOC[i].saMyUsername+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saMyPassword</td><td>Withheld</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saMyConnectString</td><td>'+JADOC[i].saMyConnectString+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saMyDatabase</td><td>'+JADOC[i].saMyDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saMyServer</td><td>'+JADOC[i].saMyServer+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>u4MyPort</td><td>'+inttostR(JADOC[i].u4MyPort)+'</td></tr>'+csCRLF+
{$IFDEF ODBC}        
        '    <tr class="r2"><td>ODBCDBHandle</td><td>'+IntToStr(UINT(JADOC[i].ODBCDBHandle))+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>ODBCStmtHandle</td><td>'+IntToStr(UINT(JADOC[i].ODBCStmtHandle))+'</td></tr>'+csCRLF+
{$ENDIF}        
        '    <tr class="r2"><td>saName</td><td>'+JADOC[i].saName+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDesc</td><td>'+JADOC[i].saDesc+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saDSN</td><td>'+JADOC[i].saDSN+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saUserName</td><td>'+JADOC[i].saUserName+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saPassword</td><td>Withheld</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDriver</td><td>'+JADOC[i].saDriver+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saServer</td><td>'+JADOC[i].saServer+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saDatabase</td><td>'+JADOC[i].saDatabase+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>bConnected</td><td>'+saTrueFalse(JADOC[i].bConnected)+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>bConnecting</td><td>'+saTrueFalse(JADOC[i].bConnecting)+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>bInUse</td><td>'+satrueFalse(JADOC[i].bInUse)+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>bFileBasedDSN</td><td>'+saTrueFalse(JADOC[i].bFileBasedDSN)+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>saDSNFileName</td><td>'+JADOC[i].saDSNFileName+'</td></tr>'+csCRLF+
        '    <tr class="r1"><td>saConnectString</td><td>'+JADOC[i].saConnectString+'</td></tr>'+csCRLF+
        '    <tr class="r2"><td>bIsCopy</td><td>'+saTrueFalse(JADOC[i].bIsCopy)+'</td></tr>'+csCRLF+
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
            '    <tr class="'+sa+'">i8NativeError</td><td>i8Number</td><td>saSource</td><td>saSQLState</td></tr>'+csCRLF+
            '      <td>'+inttostr(JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).i8NativeError)+'</td>'+
            '      <td>'+inttostr(JADO_ERROR(JFC_DLITEM(JADOC[i].Errors.lpItem).lpPtr).i8Number)+'</td>'+
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

    saTitle:='Search-N-Replace Class: TCONTEXT.PageSNRXDL';
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
    sa:=saSNRStr(sa, '[@MESSAGE@]', saMessage);
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

  result:= (CGIENV.iHttpREsponse>=300) and (CGIENV.iHttpREsponse<400);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}JThread.DBOUT(201203311220,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
{}
function TCONTEXT.bLoadXDLForMerge(
  p_saTable: ansistring;
  p_saUID: ansistring;
  p_XDL: JFC_XDL;
  var p_uDupeScore: cardinal
): boolean;
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  sTableID: string;
  sTablePKey: string;
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
  sTableID:=DBC.saGetTableID(DBC.ID, p_saTable,201210012303);

  // ----- GET TABLE DUPE SCORE
  saQry:='SELECT JTabl_DupeScore_u, JTabl_ColumnPrefix from jtable where JTabl_JTable_UID='+DBC.saDBMSUIntScrub(sTableID);
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
      'where JColu_JTable_ID='+DBC.saDBMSUIntScrub(sTableID)+' AND JColu_Deleted_b<>'+
      DBC.saDBMSBoolScrub(true);
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
      p_XDL.Item_i8User:=u4Val(rs.fields.Get_saValue('JColu_Weight_u'));
      if bVal(rs.fields.Get_saValue('JColu_PrimaryKey_b')) then
        sTablePKey:=rs.fields.Get_saValue('JColu_Name');
    until not rs.movenext;
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select * from '+p_saTable+' where '+sTablePkey+'='+DBC.saDBMSUIntScrub(p_saUID);
    if DBC.bColumnExists(p_saTable,sTableColPrefix+'_Deleted_b',201210020035) then
    begin
      saQry+= ' AND '+sTableColPrefix+'_Deleted_b<>'+DBC.saDBMSBoolScrub(True);
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
    sDelColumn:=DBC.saGetColumnPrefix(DBC.ID, DBC.saGetTableID(DBC.ID,p_sTableName,201210012304))+'_Deleted_b';
    bDelColumnExists:=DBC.bColumnExists(p_sTableName, p_sColumnName, 201210020036);
    saQry:='select ' + p_sColumnName + ' from ' + p_sTableName;
    if bDelColumnExists then saQry+=' WHERE '+sDelColumn+'<>'+DBC.saDBMSBoolScrub(true)+' ';
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
      'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
      'JColu_JTable_ID='+DBC.saDBMSUIntScrub(DBC.saGetTableID(DBC.ID,p_sTableName,201210012305))+' AND '+
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
      if UpCase(Trim(saLU_LUF_Value))='NULL' then saLU_LUF_Value:='';
    end;
    rs.close;
    //------------------------------------------GET INFORMATION ABOUT LOOK UP


    //------------------------------------------LOAD LOOKUP SQL FROM TARGET
    saQry:='SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
      'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
      'JColu_JColumn_UID='+DBC.saDBMSUIntScrub(sLU_JColumn_ID);
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


    saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value);
    if bLD_CaptionRules then
    begin
      saQry:=saSNRStr(saQry, '[@LANG@]',saLang);
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
  p_sValue: string
): ansistring;
//=============================================================================
var
  bOk: Boolean;
  //u2JWidgetID: word;
  DBC: JADO_CONNECTION;
  saQry: ansistring;//dont want to over the saQry that part of this class
  rs: JADO_RECORDSET;

  sLU_JColumn_ID: string;
  saLU_LUF_Value: ansistring;
  //--
  saLD_Column_SQL: ansistring;
  bLD_CaptionRules: boolean;
  sLU_PKey: string;
  sLU_JTable_ID: string;

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
    'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
    'JColu_JTable_ID='+DBC.saDBMSUIntScrub(DBC.saGetTableID(DBC.ID,p_sTableName,201210012305))+' AND '+
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
    sLU_JColumn_ID:=rs.fields.Get_saValue('JColu_LU_JColumn_ID');
    saLU_LUF_Value:=rs.fields.Get_saValue('JColu_LUF_Value');
    if UpCase(Trim(saLU_LUF_Value))='NULL' then saLU_LUF_Value:='';
  end;
  rs.close;
  //------------------------------------------GET INFORMATION ABOUT LOOK UP


  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  saQry:='SELECT JColu_JTable_ID, JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
    'JColu_JColumn_UID='+DBC.saDBMSUIntScrub(sLU_JColumn_ID);
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
      JAS_Log(self,cnLog_Warn,201204130007,'Unable to load target lookup column UID: '+sLU_JColumn_ID,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    sLU_JTable_ID:=rs.fields.Get_saValue('JColu_JTable_ID');
    saLD_Column_SQL:=rs.fields.Get_saValue('JColu_LD_SQL');
    bLD_CaptionRules:=bVal(rs.fields.Get_saValue('JColu_LD_CaptionRules_b'));
  end;
  rs.close;
  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  sLU_PKey:=DBC.saGetPKeyColumnWTableID(pointer(DBC),sLU_JTable_ID,201210020155);
  saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value + '[@LOOKUP@]');
  saQry:=saSNRStr(saQry,'[@LOOKUP@]',' AND '+sLU_PKey+'='+p_sValue);
  if bLD_CaptionRules then
  begin
    saQry:=saSNRStr(saQry, '[@LANG@]',saLang);
  end;
  bOk:=rs.open(saQry,DBC,201503161757);
  if not bOk then
  begin
    JAS_Log(self,cnLog_Warn,201203260948,'TCONTEXT.saLookUp had trouble with query. Lang: '+saLang,'Query: '+saQry,SOURCEFILE,DBC,rs);
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      result:=rs.fields.Get_saValue('DisplayMe');
    end
    else
    begin
      result:='[ '+p_sValue+' ]';
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
  var p_sLUTableName: ansistring
): ansistring;
//=============================================================================
var
  bOk: Boolean;
  //u2JWidgetID: word;
  DBC: JADO_CONNECTION;
  saQry: ansistring;//dont want to over the saQry that part of this class
  rs: JADO_RECORDSET;

  sLU_JColumn_ID: string;
  saLU_LUF_Value: ansistring;
  //--
  saLD_Column_SQL: ansistring;
  bLD_CaptionRules: boolean;
  //sLU_PKey: string;
  sLU_JTable_ID: string;

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
    'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
    'JColu_JTable_ID='+DBC.saDBMSUIntScrub(DBC.saGetTableID(DBC.ID,p_sTableName,201210012306))+' AND '+
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
    sLU_JColumn_ID:=rs.fields.Get_saValue('JColu_LU_JColumn_ID');
    saLU_LUF_Value:=rs.fields.Get_saValue('JColu_LUF_Value');
    if UpCase(Trim(saLU_LUF_Value))='NULL' then saLU_LUF_Value:='';
  end;
  rs.close;
  //------------------------------------------GET INFORMATION ABOUT LOOK UP


  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  saQry:='SELECT JColu_JTable_ID, JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE '+
    'JColu_Deleted_b<>'+DBC.saDBMSBoolScrub(true)+' AND '+
    'JColu_JColumn_UID='+DBC.saDBMSUIntScrub(sLU_JColumn_ID);
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
      JAS_Log(self,cnLog_Warn,201205150128,'Unable to load target lookup column UID: '+sLU_JColumn_ID,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    sLU_JTable_ID:=rs.fields.Get_saValue('JColu_JTable_ID');
    saLD_Column_SQL:=rs.fields.Get_saValue('JColu_LD_SQL');
    bLD_CaptionRules:=bVal(rs.fields.Get_saValue('JColu_LD_CaptionRules_b'));
    p_sLUTableName:=DBC.saGetTable(sLU_JTable_ID);
  end;
  rs.close;
  //------------------------------------------LOAD LOOKUP SQL FROM TARGET
  //sLU_PKey:=JAS.saGetPKeyColumnNameWTableID(pointer(JAS),sLU_JTable_ID);
  saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value);
  //saQry:=saSNRStr(saLD_Column_SQL,'[@SQLFILTER@]',saLU_LUF_Value + '[@LOOKUP@]');
  //saQry:=saSNRStr(saQry,'[@LOOKUP@]',' AND '+sLU_PKey+'='+p_sValue);
  if bLD_CaptionRules then
  begin
    saQry:=saSNRStr(saQry, '[@LANG@]',saLang);
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

  if(CGIENV.iHTTPResponse=0)then
  begin
    // nothing process - say as much - as error
    JAS_LOG(self,cnLog_Error,200912100012,'CreateIWFXML - HTTP Response not set in API call:'+saFileNameOnlyNoExt,'',SOURCEFILE);
    XML.DeleteAll;//wipe outgoing data for safety
  end;

  DebugXMLOutput;
  //iErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  bOutputRaw:=true;
  saPage+='<?xml version="1.0" encoding="UTF-8" ?>' + csCRLF;
  saPage+='<response>'+csCRLF;
  saPage+='  <action type="'+saHTMLSCRUB(saActionType)+'" errorCode="'+inttostr(u8ErrNo)+'" errorMessage="'+saHTMLScrub(saErrMsg)+'" >'+csCRLF;// + csLF;
  if(UpperCase(saActionType)='JAVASCRIPT')then
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
  if (iDebugMode = cnSYS_INFO_MODE_VERBOSE) or
     (iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL) then
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


  if(iDebugMode <> cnSYS_INFO_MODE_SECURE) and
    ((((rJSession.JSess_IP_ADDR='127.0.0.1') or (rJSession.JSess_IP_ADDR=grJASConfig.saServerIP)) AND (iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL)) OR
     (iDebugMode = cnSYS_INFO_MODE_VERBOSELOCAL) ) then
  begin
    xmlJASDebugXMLOutput:=JFC_XML.create;
    xmlJASDebugXMLOutput.bDestroyNestedLists:=true;
    xmlJASDebugXMLOutput.bShowNestedLists:=true;

    // BEGIN ------------------------ JASConfig
    xmlJASConfig:=JFC_XML.Create;
    xmlJASConfig.bDestroyNestedLists:=true;
    xmlJASConfig.bShowNestedLists:=true;

    //=========================================================================
    xmlJASConfig.AppendItem_saName_N_saValue('saSysDir',grJASConfig.saSysDir); //< Directory where JAS is installed
    xmlJASConfig.AppendItem_saName_N_saValue('saConfigDir',grJASConfig.saConfigDir); // JAS Configuration Directory (DNS, jegas.cfg etc.)
    xmlJASConfig.AppendItem_saName_N_saValue('saFileDir',grJASConfig.saFileDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saWebshareDir',grJASConfig.saWebshareDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saCacheDir',grJASConfig.saCacheDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saLogDir',grJASConfig.saLogDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saThemeDir',grJASConfig.saThemeDir);//os location
    xmlJASConfig.AppendItem_saName_N_saValue('saWebRootDir',grJASConfig.saWebRootDir); // actual file system path to default webroot
    xmlJASConfig.AppendItem_saName_N_saValue('saBinDir',grJASConfig.saBinDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saSetupDir',grJASConfig.saSetupDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saSoftwaredir',grJASConfig.saSoftwaredir);
    xmlJASConfig.AppendItem_saName_N_saValue('saSrcDir',grJASConfig.saSrcDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saDataBaseDir',grJASConfig.saDataBaseDir);
    xmlJASConfig.AppendItem_saName_N_saValue('saPHPDir',grJASConfig.saPHPDir);
    // Physical Dir -------------------------------------------------------------

    // Filenames ----------------------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('saDBCFileName',grJASConfig.saDBCFileName);
    xmlJASConfig.AppendItem_saName_N_saValue('saConfigFile',grJASConfig.saConfigFile);//usually jas.cfg at this point.
    xmlJASConfig.AppendItem_saName_N_saValue('saPHP',grJASConfig.saPHP); //< Full Path to PHP php-cgi.exe for launching CGI based PHP
    xmlJASConfig.AppendItem_saName_N_saValue('saPerl',grJASConfig.saPerl); //< Full Path to Perl exe for launching CGI based Perl
    xmlJASConfig.AppendItem_saName_N_saValue('saDiagnosticLogFileName',grJASConfig.saDiagnosticLogFileName);// SEE DIAGNOSTIC_LOG PRE-COMPILE Directive
    xmlJASConfig.AppendItem_saName_N_saValue('saJASFooter',grJASConfig.saJASFooter);
    // Filenames ----------------------------------------------------------------


    // Web Paths ----------------------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('saWebShareAlias',grJASConfig.saWebShareAlias); //< Aliased Directory "webshare". Usually: jws
    xmlJASConfig.AppendItem_saName_N_saValue('saJASDirTheme',grJASConfig.saJASDirTheme);//web view
    // Web Paths ----------------------------------------------------------------

    // Misc Settings ----------------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('saServerURL',grJASConfig.saServerURL);// should not have trailing slash
    xmlJASConfig.AppendItem_saName_N_saValue('saServerName',grJASConfig.saServerName);
    xmlJASConfig.AppendItem_saName_N_saValue('saServerIdent',grJASConfig.saServerIdent);
    xmlJASConfig.AppendItem_saName_N_saValue('saServerSoftware',grJASConfig.saServerSoftware);//<not a config thing as much as vari is more space efficient than constants in exe creation (same string repeated all over in binary executable)
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultArea',grJASConfig.saDefaultArea);
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultPage',grJASConfig.saDefaultPage);
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultSection',grJASConfig.saDefaultSection);
    xmlJASConfig.AppendItem_saName_N_saValue('u1PasswordKey',inttostr(grJASConfig.u1PasswordKey));
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultLanguage',grJASConfig.saDefaultLanguage); //< DEFAULT should be 'en' for english naturally. Note: In filenames, and code - lowercase. In JAS MySQL jcaption table, upper case for field names. e.g. JCapt_EN = English Caption
    xmlJASConfig.AppendItem_saName_N_saValue('u1DefaultMenuRenderMethod',inttostr(grJASConfig.u1DefaultMenuRenderMethod));
    xmlJASConfig.AppendItem_saName_N_saValue('saServerIP',grJASConfig.saServerIP);
    xmlJASConfig.AppendItem_saName_N_saValue('u2ServerPort',inttostr(grJASConfig.u2ServerPort));
    xmlJASConfig.AppendItem_saName_N_saValue('iRetryLimit',inttostr(grJASConfig.iRetryLimit));
    xmlJASConfig.AppendItem_saName_N_saValue('iRetryDelayInMSec',inttostr(grJASConfig.iRetryDelayInMSec));
    xmlJASConfig.AppendItem_saName_N_saValue('iTIMEZONEOFFSET',inttostr(grJASConfig.iTIMEZONEOFFSET));
    xmlJASConfig.AppendItem_saName_N_saValue('iMaxFileHandles',inttostr(grJASConfig.iMaxFileHandles));//< NOT OS FILEHANDLES! Max Reservations for Jegas Threadsafe File Handles.
    xmlJASConfig.AppendItem_saName_N_saValue('bBlacklistEnabled',saTrueFalse(grJASConfig.bBlacklistEnabled));
    xmlJASConfig.AppendItem_saName_N_saValue('bWhiteListEnabled',saTruefalse(grJASConfig.bWhiteListEnabled));
    xmlJASConfig.AppendItem_saName_N_saValue('bJobQEnabled',saTruefalse(grJASConfig.bJobQEnabled));
    xmlJASConfig.AppendItem_saName_N_saValue('iJobQIntervalInMSec',inttostr(grJASConfig.iJobQIntervalInMSec));
    xmlJASConfig.AppendItem_saName_N_saValue('u8DefaultTop_JMenu_ID',inttostr(grJASConfig.u8DefaultTop_JMenu_ID));
    xmlJASConfig.AppendItem_saName_N_saValue('bDirectoryListing',saTruefalse(grJASConfig.bDirectoryListing));
    xmlJASConfig.AppendItem_saName_N_saValue('bDataOnRight',satrueFalse(grJASConfig.bDataOnRight));
    xmlJASConfig.AppendItem_saName_N_saValue('sCacheMaxAgeInSeconds',grJASConfig.sCacheMaxAgeInSeconds);
    xmlJASConfig.AppendItem_saName_N_saValue('sSMTPHost',grJASConfig.sSMTPHost);
    xmlJASConfig.AppendItem_saName_N_saValue('sSMTPUsername',grJASConfig.sSMTPUsername);
    xmlJASConfig.AppendItem_saName_N_saValue('sSMTPPassword',grJASConfig.sSMTPPassword);
    xmlJASConfig.AppendItem_saName_N_saValue('sSystemEmailFromAddress',grJASConfig.sSystemEmailFromAddress);
    xmlJASConfig.AppendItem_saName_N_saValue('bProtectJASRecords',saTrueFalse(grJASConfig.bProtectJASRecords));
    xmlJASConfig.AppendItem_saName_N_saValue('bSafeDelete',satruefalse(grJASConfig.bSafeDelete));
    // Misc Settings ----------------------------------------------------------

    // Threading --------------------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('iThreadPoolNoOfThreads',inttostr(grJASConfig.iThreadPoolNoOfThreads));
    xmlJASConfig.AppendItem_saName_N_saValue('iThreadPoolMaximumRunTimeInMSec',inttostr(grJASConfig.iThreadPoolMaximumRunTimeInMSec));
    // Threading --------------------------------------------------------------

    // Error and Log Settings -------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('iLogLevel',inttostr(grJASConfig.iLogLevel));
    xmlJASConfig.AppendItem_saName_N_saValue('bLogMessagesShowOnServerConsole',saTrueFalse(grJASConfig.bLogMessagesShowOnServerConsole));
    xmlJASConfig.AppendItem_saName_N_saValue('bDeleteLogFile',satrueFalsE(grJASConfig.bDeleteLogFile));
    xmlJASConfig.AppendItem_saName_N_saValue('iErrorReportingMode',inttostr(grJASConfig.iErrorReportingMode));
    xmlJASConfig.AppendItem_saName_N_saValue('saErrorReportingSecureMessage',grJASConfig.saErrorReportingSecureMessage);
    xmlJASConfig.AppendItem_saName_N_saValue('bServerConsoleMessagesEnabled',saTrueFalsE(grJASConfig.bServerConsoleMessagesEnabled));
    xmlJASConfig.AppendItem_saName_N_saValue('bDebugServerConsoleMessagesEnabled',satrueFalse(grJASConfig.bDebugServerConsoleMessagesEnabled));
    xmlJASConfig.AppendItem_saName_N_saValue('iDebugMode',inttostr(grJASConfig.iDebugMode));
    // Error and Log Settings -------------------------------------------------

    // Session and Record Locking ---------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('iSessionTimeOutInMinutes',inttostr(grJASConfig.iSessionTimeOutInMinutes));
    xmlJASConfig.AppendItem_saName_N_saValue('iLockTimeOutInMinutes',inttostr(grJASConfig.iLockTimeOutInMinutes));
    xmlJASConfig.AppendItem_saName_N_saValue('iLockRetriesBeforeFailure',inttostr(grJASConfig.iLockRetriesBeforeFailure));
    xmlJASConfig.AppendItem_saName_N_saValue('iLockRetryDelayInMSec',inttostr(grJASConfig.iLockRetryDelayInMSec));
    xmlJASConfig.AppendItem_saName_N_saValue('iValidateSessionRetryLimit',inttostr(grJASConfig.iValidateSessionRetryLimit));
    // Session and Record Locking ---------------------------------------------

    // IP Protocol Related ----------------------------------------------------
    xmlJASConfig.AppendItem_saName_N_saValue('i8MaximumRequestHeaderLength',inttostr(grJASConfig.i8MaximumRequestHeaderLength));
    xmlJASConfig.AppendItem_saName_N_saValue('iCreateSocketRetry',inttostr(grJASConfig.iCreateSocketRetry));
    xmlJASConfig.AppendItem_saName_N_saValue('iCreateSocketRetryDelayInMSec',inttostr(grJASConfig.iCreateSocketRetryDelayInMSec));
    xmlJASConfig.AppendItem_saName_N_saValue('iSocketTimeOutInMSec',inttostr(grJASConfig.iSocketTimeOutInMSec));
    xmlJASConfig.AppendItem_saName_N_saValue('bEnableSSL',saTRueFalse(grJASConfig.bEnableSSL));
    // IP Protocol Related ----------------------------------------------------

    // ADVANCED CUSTOM PROGRAMMING --------------------------------------------
    // Programmable Session Custom Hooks - Names for Actions that might
    // be coded into the u01g_sessions file. Useful for working with
    // integrated systems.
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_CREATESESSION_FAILURE',grJASConfig.saHOOK_ACTION_CREATESESSION_FAILURE);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_CREATESESSION_SUCCESS',grJASConfig.saHOOK_ACTION_CREATESESSION_SUCCESS);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_REMOVESESSION_FAILURE',grJASConfig.saHOOK_ACTION_REMOVESESSION_FAILURE);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_REMOVESESSION_SUCCESS',grJASConfig.saHOOK_ACTION_REMOVESESSION_SUCCESS);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_SESSIONTIMEOUT',grJASConfig.saHOOK_ACTION_SESSIONTIMEOUT);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_VALIDATESESSION_FAILURE',grJASConfig.saHOOK_ACTION_VALIDATESESSION_FAILURE);
    xmlJASConfig.AppendItem_saName_N_saValue('saHOOK_ACTION_VALIDATESESSION_SUCCESS',grJASConfig.saHOOK_ACTION_VALIDATESESSION_SUCCESS);
    xmlJASConfig.AppendItem_saName_N_saValue('saClientToVICIServerIP',grJASConfig.saClientToVICIServerIP);
    xmlJASConfig.AppendItem_saName_N_saValue('saJASServertoVICIServerIP',grJASConfig.saJASServertoVICIServerIP);
    // ADVANCED CUSTOM PROGRAMMING --------------------------------------------

    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultColorTheme',grJASConfig.saDefaultColorTheme);
    xmlJASConfig.AppendItem_saName_N_saValue('bDefaultSharesDefaultDomain',saTrueFalsE(grJASConfig.bDefaultSharesDefaultDomain));
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultIconTheme',grJASConfig.saDefaultIconTheme);
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultAccessLog',grJASConfig.saDefaultAccessLog);
    xmlJASConfig.AppendItem_saName_N_saValue('saDefaultErrorLog',grJASConfig.saDefaultErrorLog);


    xmlJASDebugXMLOutput.appenditem_lpPtr(xmlJASConfig);
    xmlJASDebugXMLOutput.Item_saName:='JASConfig';
    // END -------------------------- JASConfig




    // BEGIN ------------------------ Context
    xmlContext:=JFC_XML.Create;
    xmlContext.bDestroyNestedLists:=true;
    xmlContext.bShowNestedLists:=true;

    xmlContext.AppendItem_saName_N_saValue('bSessionValid',saTrueFalse(bSessionValid));
    xmlContext.AppendItem_saName_N_saValue('bErrorCondition',saTrueFalse(bErrorCondition));
    xmlContext.AppendItem_saName_N_saValue('u8ErrNo',inttostr(u8ErrNo));
    xmlContext.AppendItem_saName_N_saValue('saErrMsg',saErrMsg);
    xmlContext.AppendItem_saName_N_saValue('saErrMsgMoreInfo',saErrMsgMoreInfo);
    xmlContext.AppendItem_saName_N_saValue('saServerIP',saServerIP);
    xmlContext.AppendItem_saName_N_saValue('saServerPort',saServerPort);
    xmlContext.AppendItem_saName_N_saValue('saPage',saPage);
    xmlContext.AppendItem_saName_N_saValue('bLoginAttempt',saTrueFalse(bLoginAttempt));
    //xmlContext.AppendItem_saName_N_saValue('saLoginMsg',saLoginMsg);
    xmlContext.AppendItem_saName_N_saValue('saPageTitle',saPageTitle);
    xmlContext.AppendItem_saName_N_saValue('dtRequested',saFormatDateTime(csDATETIMEFORMAT,dtRequested));
    xmlContext.AppendItem_saName_N_saValue('dtServed',saFormatDatetime(csDATETIMEFORMAT,dtServed));
    xmlContext.AppendItem_saName_N_saValue('dtFinished',saFormatDateTime(csDATETIMEFORMAT,dtFinished));
    xmlContext.AppendItem_saName_N_saValue('saLang',saLang);
    xmlContext.AppendItem_saName_N_saValue('bOutputRaw',saTrueFalse(bOutputRaw));
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Area',saHTMLRIPPER_Area);
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Page',saHTMLRIPPER_Page);
    xmlContext.AppendItem_saName_N_saValue('saHTMLRIPPER_Section',saHTMLRIPPER_Section);
    xmlContext.AppendItem_saName_N_saValue('u8MenuTopID',inttostr(u8MenuTopID));
    xmlContext.AppendItem_saName_N_saValue('saUserCacheDir',saUserCacheDir);
    xmlContext.AppendItem_saName_N_saValue('iErrorReportingMode',inttostr(iErrorReportingMode));
    xmlContext.AppendItem_saName_N_saValue('iDebugMode',inttostr(iDebugMode));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute',saTrueFalse(bMIME_execute));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_Jegas',saTrueFalse(bMIME_execute_Jegas));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_JegasWebService',satrueFalse(bMIME_execute_JegasWebService));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_php',saTruefalse(bMIME_execute_php));
    xmlContext.AppendItem_saName_N_saValue('bMIME_execute_perl',satrueFalse(bMIME_execute_perl));
    xmlContext.AppendItem_saName_N_saValue('saMimeType',saMimeType);
    xmlContext.AppendItem_saName_N_saValue('bMimeSNR',satrueFalse(bMimeSNR));
    xmlContext.AppendItem_saName_N_saValue('saFileSoughtNoExt',saFileSoughtNoExt);
    xmlContext.AppendItem_saName_N_saValue('saFileSoughtExt',saFileSoughtExt);
    xmlContext.AppendItem_saName_N_saValue('saFileNameOnly',saFileNameOnly);
    xmlContext.AppendItem_saName_N_saValue('saFileNameOnlyNoExt',saFileNameOnlyNoExt);
    xmlContext.AppendItem_saName_N_saValue('saIN',saIN);
    xmlContext.AppendItem_saName_N_saValue('saOut',saOut);
    xmlContext.AppendItem_saName_N_saValue('u8BytesRead',inttostr(u8BytesRead));
    xmlContext.AppendItem_saName_N_saValue('u8BytesSent',inttostr(u8BytesSent));
    xmlContext.AppendItem_saName_N_saValue('saRequestedHost',saRequestedHost);
    xmlContext.AppendItem_saName_N_saValue('saRequestedHostRootDir',saRequestedHostRootDir);
    xmlContext.AppendItem_saName_N_saValue('saRequestMethod',saRequestMethod);
    xmlContext.AppendItem_saName_N_saValue('saRequestType',saRequestType);
    xmlContext.AppendItem_saName_N_saValue('saRequestedFile',saRequestedFile);
    xmlContext.AppendItem_saName_N_saValue('saOriginallyREquestedFile',saOriginallyREquestedFile);
    xmlContext.AppendItem_saName_N_saValue('saRequestedName',saRequestedName);
    xmlContext.AppendItem_saName_N_saValue('saRequestedDir',saRequestedDir);
    xmlContext.AppendItem_saName_N_saValue('saFileSought',saFileSought);
    xmlContext.AppendItem_saName_N_saValue('saQueryString',saQueryString);
    xmlContext.AppendItem_saName_N_saValue('i4ErrorCode',inttostr(i4ErrorCode));
    xmlContext.AppendItem_saName_N_saValue('saLogFile',saLogFile);
    xmlContext.AppendItem_saName_N_saValue('bJASCGI',saTruefalse(bJASCGI));
    xmlContext.AppendItem_saName_N_saValue('saActionType',saActionType);
    xmlContext.AppendItem_saName_N_saValue('iSessionResultCode',inttostr(iSessionResultCode));
    xmlContext.AppendItem_saName_N_saValue('bSaveSessionData',satruefalsE(bSaveSessionData));
    xmlContext.AppendItem_saName_N_saValue('bInternalJob',satrueFalse(bInternalJob));
    xmlContext.AppendItem_saName_N_saValue('JTrakXDL',JTrakXDL.saXML);
    xmlContext.AppendItem_saName_N_saValue('JTrak_TableID',JTrak_TableID);
    xmlContext.AppendItem_saName_N_saValue('JTrak_u2JDType',inttostr(JTrak_u2JDType));
    xmlContext.AppendItem_saName_N_saValue('JTRak_saPKeyCol',JTRak_saPKeyCol);
    xmlContext.AppendItem_saName_N_saValue('JTrak_DBConID',JTrak_DBConID);
    xmlContext.AppendItem_saName_N_saValue('JTrak_saUID',JTrak_saUID);
    xmlContext.AppendItem_saName_N_saValue('JTrak_bExist',saTRueFalse(JTrak_bExist));
    xmlContext.AppendItem_saName_N_saValue('JTrak_saTable',JTrak_saTable);
    xmlContext.AppendItem_saName_N_saValue('saColorTheme',saColorTheme);
    xmlContext.AppendItem_saName_N_saValue('i4VHost',inttostr(i4VHost));
    xmlContext.AppendItem_saName_N_saValue('saAlias',saAlias);
    xmlContext.AppendItem_saName_N_saValue('sIconTheme',sIconTheme);
    xmlContext.AppendItem_saName_N_saValue('u2LogType_ID',inttostr(u2LogType_ID));
    xmlContext.AppendItem_saName_N_saValue('bNoWebCache',saTrueFalse(bNoWebCache));
    xmlContext.AppendItem_saName_N_saValue('JThread',inttostr(UINT(JTHREAD)));
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;
    xmlNode.AppendItem_saName_N_saDesc('i8Stage',inttostr(JThread.i8Stage));
    xmlNode.AppendItem_saName_N_saDesc('saStageNote',JThread.saStageNote);
    ////JThread.rJTMsgFifoInit: rtFifoInit;
    ////JThread.JTMSGFIFO: JFC_FIFO;
    ////JThread.JTMSG_OUT: rtFIFOItem;
    xmlNode.AppendItem_saName_N_saDesc('UID',inttostr(JThread.UID));
    ////JThread.Children: JFC_DL;
    xmlNode.AppendItem_saName_N_saDesc('Suspended',saTrueFalse(JThread.Suspended));
    xmlNode.AppendItem_saName_N_saDesc('lpParent',inttostr(UINT(JThread.lpParent)));
    xmlNode.AppendItem_saName_N_saDesc('iExecuteIterations',inttostr(JThread.iExecuteIterations));
    xmlNode.AppendItem_saName_N_saDesc('dtCreated',FormatDateTime(csDATETIMEFORMAT,JThread.dtCreated));
    xmlNode.AppendItem_saName_N_saDesc('dtExecuteBegin',FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteBegin));
    xmlNode.AppendItem_saName_N_saDesc('dtExecuteEnd',FormatDateTime(csDATETIMEFORMAT,JThread.dtExecuteEnd));
    xmlNode.AppendItem_saName_N_saDesc('bShuttingDown',saTRueFalse(JThread.bShuttingDown));
    xmlNode.AppendItem_saName_N_saDesc('bLoopContinuously',saTRueFalse(JThread.bLoopContinuously));
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

      xmlNode3.AppendItem_saName_N_saValue('ID',JADOC[i].ID);
      xmlNode3.AppendItem_saName_N_saValue('u2DbmsID',inttostr(JADOC[i].u2DbmsID));
      xmlNode3.AppendItem_saName_N_saValue('saConnectionString',JADOC[i].saConnectionString);
      xmlNode3.AppendItem_saName_N_saValue('saDefaultDatabase',JADOC[i].saDefaultDatabase);
      xmlNode3.AppendItem_saName_N_saValue('saProvider',JADOC[i].saProvider);
      xmlNode3.AppendItem_saName_N_saValue('i4State',inttostr(JADOC[i].i4State));
      xmlNode3.AppendItem_saName_N_saValue('saVersion',JADOC[i].saVersion);
      xmlNode3.AppendItem_saName_N_saValue('u2DrivID',inttostr(JADOC[i].u2DrivID));
      xmlNode3.AppendItem_saName_N_saValue('saMyUsername',JADOC[i].saMyUsername);
      xmlNode3.AppendItem_saName_N_saValue('saMyPassword','Withheld');//JADOC[i].saMyPassword);
      xmlNode3.AppendItem_saName_N_saValue('saMyConnectString',JADOC[i].saMyConnectString);
      xmlNode3.AppendItem_saName_N_saValue('saMyDatabase',JADOC[i].saMyDatabase);
      xmlNode3.AppendItem_saName_N_saValue('saMyServer',JADOC[i].saMyServer);
      xmlNode3.AppendItem_saName_N_saValue('u4MyPort',inttostr(JADOC[i].u4MyPort));
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
    xmlNode.AppendItem_saName_N_saValue('CKYIN',CGIENV.CKYIN.saXML);
    xmlNode.AppendItem_saName_N_saValue('CKYOUT',CGIENV.CKYOUT.saXML);
    xmlNode.AppendItem_saName_N_saValue('HEADER',CGIENV.HEADER.saXML);
    xmlNode.AppendItem_saName_N_saValue('FILESIN',CGIENV.FILESIN.saXML);
    xmlNode.AppendItem_saName_N_saValue('bPost',saTRueFalse(CGIENV.bPost));
    xmlNode.AppendItem_saName_N_saValue('saPostContentType',CGIENV.saPostContentType);
    xmlNode.AppendItem_saName_N_saValue('iPostContentLength',inttostr(CGIENV.iPostContentLength));
    xmlNode.AppendItem_saName_N_saValue('saPostData',CGIENV.saPostData);
    xmlNode.AppendItem_saName_N_saValue('iTimeZoneOffset',inttostr(CGIENV.iTimeZoneOffset));
    xmlNode.AppendItem_saName_N_saValue('iHTTPResponse',inttostr(CGIENV.iHTTPResponse));
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
    xmlContext.AppendItem_saName_N_saValue('JUser_Enabled_b',saTRueFalsE(rJUser.JUser_Enabled_b));
    if garJVHostLight[i4VHost].saServerDomain='default' then
    begin
      xmlContext.AppendItem_saName_N_saValue('JUser_Admin_b',satrueFalse(rJUser.JUser_Admin_b));
    end;
    xmlContext.AppendItem_saName_N_saValue('JUser_Login_First_DT',rJUser.JUser_Login_First_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Login_Last_DT',rJUser.JUser_Login_Last_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Logins_Successful_u',inttostr(rJUser.JUser_Logins_Successful_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_Logins_Failed_u',inttostr(rJUser.JUser_Logins_Failed_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_Password_Changed_DT',rJUser.JUser_Password_Changed_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_AllowedSessions_u',inttostr(rJUser.JUser_AllowedSessions_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_DefaultPage_Login',rJUser.JUser_DefaultPage_Login);
    xmlContext.AppendItem_saName_N_saValue('JUser_DefaultPage_Logout',rJUser.JUser_DefaultPage_Logout);
    xmlContext.AppendItem_saName_N_saValue('JUser_JLanguage_ID',inttostR(rJUser.JUser_JLanguage_ID));
    xmlContext.AppendItem_saName_N_saValue('JUser_Audit_b',saTRueFalse(rJUser.JUser_Audit_b));
    xmlContext.AppendItem_saName_N_saValue('JUser_ResetPass_u',inttostr(rJUser.JUser_ResetPass_u));
    xmlContext.AppendItem_saName_N_saValue('JUser_CreatedBy_JUser_ID',rJUser.JUser_CreatedBy_JUser_ID);
    xmlContext.AppendItem_saName_N_saValue('JUser_Created_DT',rJUser.JUser_Created_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_ModifiedBy_JUser_ID',rJUser.JUser_ModifiedBy_JUser_ID);
    xmlContext.AppendItem_saName_N_saValue('JUser_Modified_DT',rJUser.JUser_Modified_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_DeletedBy_JUser_ID',rJUser.JUser_DeletedBy_JUser_ID);
    xmlContext.AppendItem_saName_N_saValue('JUser_Deleted_DT',rJUser.JUser_Deleted_DT);
    xmlContext.AppendItem_saName_N_saValue('JUser_Deleted_b',rJUser.JUser_Deleted_b);
    xmlContext.AppendItem_saName_N_saValue('JAS_Row_b',saTRueFalse(rJUser.JAS_Row_b));
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='User';



    // rJSession: rtJSession;
    xmlNode:=JFC_XML.Create;
    xmlNode.bDestroyNestedLists:=true;
    xmlNode.bShowNestedLists:=true;
    xmlContext.AppendItem_saName_N_saValue('JSess_JSession_UID',rJSession.JSess_JSession_UID);
    xmlContext.AppendItem_saName_N_saValue('JSess_JSessionType_ID',rJSession.JSess_JSessionType_ID);
    xmlContext.AppendItem_saName_N_saValue('JSess_JUser_ID',rJSession.JSess_JUser_ID);
    xmlContext.AppendItem_saName_N_saValue('JSess_Connect_DT',rJSession.JSess_Connect_DT);
    xmlContext.AppendItem_saName_N_saValue('JSess_LastContact_DT',rJSession.JSess_LastContact_DT);
    xmlContext.AppendItem_saName_N_saValue('JSess_IP_ADDR',rJSession.JSess_IP_ADDR);
    xmlContext.AppendItem_saName_N_saValue('JSess_PORT_u',rJSession.JSess_PORT_u);
    xmlContext.AppendItem_saName_N_saValue('JSess_Username',rJSession.JSess_Username);
    xmlContext.AppendItem_saName_N_saValue('JSess_JJobQ_ID',rJSession.JSess_JJobQ_ID);
    xmlContext.AppendItem_lpPtr(xmlNode);
    xmlContext.Item_saName:='Session';

    // SessionXDL: JFC_XDL;
    xmlContext.AppendItem_saName_N_saValue('SessionXDL',SessionXDL.saXML);

    // PAGESNRXDL: JFC_XDL;
    xmlContext.AppendItem_saName_N_saValue('PAGESNRXDL',PAGESNRXDL.saXML);

    // REQVAR_XDL
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
function TCONTEXT.saJThemeColorHeader(p_saColorTheme: ansistring): ansistring;
var
  i: longint;
  saUpCaseThemeColor: ansistring;
begin
  result:='';
  if length(garJThemeColorLight)>0 then
  begin
    saUpCaseThemeColor:=upcase(p_saColorTheme);
    for i:=0 to length(garJThemeColorLight)-1 do
    begin
      if UPCase(garJThemeColorLight[i].saName)=saUpCaseThemeColor then
      begin
        result:= garJThemeColorLight[i].saTemplate_Header;
        break;
      end;
    end;
  end;
end;
//=============================================================================




//=============================================================================
function TCONTEXT.saJLanguageLookup(p_u8LangID: UInt64): ansistring;
//=============================================================================
var
  i: longint;
begin
  //ASPrintln('saJLanguageLookup('+inttostr(p_u8LangID)+')');
  result:=grJASConfig.saDefaultLanguage;
  if length(garJLanguageLight)>0 then
  begin
    for i:=0 to length(garJLanguageLight)-1 do
    begin
      //ASPrintln('saJLanguageLookup Loop - garJLanguageLight[i].u8JLanguage_UID: '+inttostr(garJLanguageLight[i].u8JLanguage_UID));
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
  if (i4VHost>-1) and (garJVHostLight[i4VHost].u8JDConnection_ID>0) then
  begin
    //ASPrintln('INSIDE VHDBC IF');
    i:=0;
    bDone:=false;
    repeat
      //ASPrintln('VHDBC REPEAT');
      if u8val(JADOC[i].ID)=garJVHostLight[i4VHost].u8JDConnection_ID then
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
  end
  else
  begin
    //ASPrintln('TCONTEXT.VHDBC Defaulted to VHost ZERO');
    i4VHost:=0;
  end;
  //ASPrintln('END TCONTEXT.VHDBC - Result.ID: ' + RESULT.ID+' '+RESULT.saName  );
end;
//=============================================================================



//=============================================================================
{}
function TCONTEXT.saGetURL(p_i: longint): ansistring;
//=============================================================================
begin
  if garJVHostLight[p_i].bSharesDefaultDomain then
  begin
    result:=garJVHostLight[0].saServerDomain+'/'+garJVHostLight[p_i].saServerDomain+'/';
  end
  else
  begin
    if garJVHostLight[p_i].saServerDomain='default' then
    begin
      result:=grJASConfig.saServerURL+'/';
    end
    else
    begin
      result:=garJVHostLight[p_i].saServerDomain+'/';
    end;
    
  end;
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
