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
// XML API Calls and IWF XML Response Generation
Unit uj_xml;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_xml.pp'}
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
,sysutils
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jfc_xml
,ug_jfc_tokenizer
,ug_jado
,uj_locking
,uj_tables_loadsave
,uj_permissions
,uj_user
,uj_context
,uj_definitions
,uj_sessions
,uj_email
,uj_dbtools
,uj_menusys
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
// Runs JASAPIXML functions - This function is called automatically by JAS from
// uxxj_jcore when the MIME type is execute/jasapi internally. This MIME type  
// is set internally when a parameter named JASAPI is passed in the URI or in 
// the POST data. The value is expected to be the name of the JASAPI function 
// you are calling. Note.. There are two sorts of JAS API functions. Those
// in binary and those used here which are for accessing binary functions 
// over the wire, and should be thought of as JASAPIXML functions. They are 
// akin to webservices.    
//
// See USERAPI_Dispatch for a similiar architecture and mechanism to make
// calls for user applications that work the same way.
procedure JASAPI_Dispatch(p_Context: TCONTEXT);  
//=============================================================================

//=============================================================================
{}
// JASAPIXML Function
// sends out xml with the payload being simply "hello world" inside an xml
// file formatted to be iwf friendly.
procedure jasapi_helloworld(p_Context: TCONTEXT);
//=============================================================================
{}
// JASAPIXML Function
// Takes information from CGIENV and ascertains if the "session" is 
// valid/logged in.
procedure jasapi_validatesession(p_Context: TCONTEXT);
//=============================================================================
{}
// JASAPIXML Function
// user login mechanism
procedure jasapi_createsession(p_Context: TCONTEXT);
//=============================================================================
{}
// JASAPIXML Function
// user logout mechanism
procedure jasapi_removesession(p_Context: TCONTEXT);
//=============================================================================

 

//=============================================================================
{}
// JASAPIXML Function
// This function just returns a XML response using the CreateIWFXML function
// but note this function has a random "error" component. Odds 1 out of 100. 
// This was created to facilitate testing "hitting" the JAS server and having
// it occasionally simulate errors. The error message clearly states the 
// error was randomly generated so you know if a real error occurred or a 
// fake one. 
procedure JAS_XmlTest(p_Context: TCONTEXT); 
//=============================================================================
{}
// RenderQuicklinks - returns the appropriate quicklinks rendered as an
// html unordered list with only the css class attribute of the top ul set to
// "jas-menu" (maybe jas-quicklinks if menu thing doesnt work out I'll make 
// a special mod to all themes for the quicklink bit.)
// Current Session and Owner Ship of Links taken into account. 
//
// Random Note:  about the end goal to bring the xml api under the hood error
// status etc exactly like the html rendered one - so the same file logging
// infrastructure is utilized. We're close.. just not "done" yet.
// here is how the quicklinks xml apirender function does it:
//
// if the JAS_LOG hits this same field list.. then bring inline the same exact
// logging functions to the xml side and making those "error" or "codes" count
// systemically.. then - that's the right way.. so that's the direction for that.
//        p_Context.bErrorCondition:=true;
//        p_Context.u8ErrNo:=201012201638;
//        p_Context.saErrMsg:='RenderQuickLinks - Trouble with Query.';
//        p_Context.saErrMsgMoreInfo:='Query: '+saQry;
//
// One other reminder - remember to make the log stuff that get's thunked to
// the database for management quick response etc happens after the page is
// served (for performance) before thread is recycled.
procedure JASAPI_RenderQuickLinks(p_Context: TCONTEXT);
//=============================================================================
{}
// pass jastheme=name
procedure JASAPI_SetTheme(p_Context: TCONTEXT);
//=============================================================================
{}
// JASDISPLAYHEADERS set to "on" or "off" based on value set.
procedure JASAPI_SetDisplayHeaders(p_Context: TCONTEXT);
//=============================================================================
{}
// JASDISPLAYQUICKLINKS set to "on" or "off"
procedure JASAPI_SetDisplayQuickLinks(p_Context: TCONTEXT);
//=============================================================================
{}
// Background Image Repeat set to "on" or "off"
procedure JASAPI_SetBackgroundRepeat(p_Context: TCONTEXT);
//=============================================================================
{}
// JASICONTHEME set to one of the icon themes' names.
procedure JASAPI_SetIconTheme(p_Context: TCONTEXT);

//=============================================================================
{}
// make database table using data in jtable and jcolumn
// .?jasapi=maketable&JTabl_JTable_UID=1000
procedure JASAPI_MakeTable(p_Context: TCONTEXT);
//=============================================================================
{}
// make database table using data in jtable and jcolumn
function bJAS_MakeTable(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring):boolean;
//=============================================================================
{}
// JASAPI_TableExist is identical to bJAS_TableExist except that its called 
// using the JASAPI convention: jasapi=maketable which is AJAX friendly.
//
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_TableExist(p_Context: TCONTEXT);
//=============================================================================
{}
function bJAS_TableExist(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring): boolean;
//=============================================================================
{}
// JASAPI_ColumnExist is identical to bJAS_ColumnExist except that it is called
// using the JASAPI convention: jasapi=maketable 
//
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_ColumnExist(p_Context: TCONTEXT);
//=============================================================================
{}
// return true or false if table's column exists for given connection
// Example:
function bJAS_ColumnExist(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring):boolean;
//=============================================================================
{}
// JASAPI_MakeColumn is identical to JAS_MakeColumn except
// that it takes jasapi=MakeColumn as then indication that is what
// is being requested versus cnAction_MakeColumn=56;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_MakeColumn(p_Context: TCONTEXT);
//=============================================================================
{}
// returns true successful altering or creating DB column from data in the
// jcolumn table. Pass the Column UID of the column. Said column should be
// connected to an existing table and database connection.
function bJAS_MakeColumn(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring): boolean;
//=============================================================================
{}
// example: .?jasapi=rowexist&UID=1000&JTabl_JTable_UID=1
procedure JASAPI_RowExist(p_Context: TCONTEXT);
//=============================================================================
{}
function bJAS_RowExist(
  p_Context: TCONTEXT;
  p_UID: ansistring;
  p_JTabl_JTable_UID: ansistring
): boolean;
//=============================================================================
{}
// Makes a particular saved filter the users default by adding it to the
// jfiltersavedef table.
//
// example: .?jasapi=filtersavedef&filtersave=1234
//
procedure JASAPI_FilterSaveDef(p_Context: TCONTEXT);
//=============================================================================
{}
// Used to allow a user to click a button in jas to move a quicklink
//up or down (really left or right)
procedure JASAPI_MoveQuickLink(p_Context: TCONTEXT);
//=============================================================================
{}
// User Registration with Email Verification
procedure jasapi_register(p_Context: TCONTEXT);
//=============================================================================
{}
// URI Parameters:
// JTabl_JTable_UID = (SOURCE TABLE) JTable Record containing table or view
//   you wish to make a copy of. Connection is figured out from
//   this information. a data connection doesn't need to be active to make a
//   screen for it.
//
// Name = (DESTINATION [new] NAME)
//
// This function might not belong in this unit - as it does it's task and
// returns an XML document - however because it is so integral to the
// User Interface - it's here.
//
// TODO: Move this to the JASAPI side of things and make it work using the
//       extensible xml mechanisms. e.g. i01j_api_xml.pp
procedure JASAPI_CopyScreen(p_Context: TCONTEXT);
//=============================================================================
{}
// pas parameter: NAME in URL for the name of the user,password and database.
// Note the permissions only allow access from localhost - this is why password
// scheme works.

// Makes new user, password and database and makes a JAS connection
// for it using same info. This routin passes back the JDConnection UID
// when successful or a ZERO if it failed. Note the connection IS NOT ENABLED
// so the next step to make the database etc would be to load the info
// into an instance of JDCON, Doo all you have to do then SAVE the connection
// as ENABLED and send the Cycle command into the JobQueue of the Squadron
// Leader databse.
procedure JASAPI_NewConAndDB(p_Context: TCONTEXT);
//=============================================================================
{}
// Parameters:
// JDCon_JDConnection_UID: Database connection in source DB to use
// Name to use making a connection if JDCon_JDConnection_UID is ZERO on entry
// bLeadJet: If True treat as Master Database, otherwise like a JET database.
//
// Makes New Master databses or Jet databases and also upgrades existing
// databases.
procedure JASAPI_DBMasterUtility(p_Context: TCONTEXT);
//=============================================================================
{}
// This routine IS Only for Squadron leaders who know what they are doing.
// This is 100% destructive to ALL security Settings! It Sets Up defaults,
// deletes all existing everything for security, and then adds the default
// security groups, adds a ton of permissions for screens and tables and then
// assigns ALL permissions to ALL GROUPS! (Leaving a lot of labor to
// Do for the bloke who fired this puppy OFF!
procedure JASAPI_SetDefaultSecuritySettings(p_Context: TCONTEXT);
//=============================================================================
{}
// This is the JASAPI call that does the ENTIRE process of taking a JAS USER
// who DOES NOT have a JAS JET already and creates it start to finish and then
// emails the user with information to get in.
//
// This will be normally invoked from the JobQueue - as it takes awhile.
// Certain requirements need to be met for this process to work:
//
// Must have JAS Master Database User Account
// Account must have a JPerson record with a valid work email address.
//
// PARAMETERS
// name = name of alias, dir, domain
// servername = business name or title of CRM
// fromemailaddress = used when system sends email.
// firstname, lastname, workemail
procedure JASAPI_CreateVirtualHost(p_Context: TCONTEXT);
//=============================================================================
{}
// Parameters: None
// Returns: link to user's JAS Jet CRM if they have one setup, blank otherwise
procedure JASAPI_DoesUserHaveJet(p_Context: TCONTEXT);
//=============================================================================
{}
// Handles daily updates to user records of folks owning JAS Jet's and on the
// first of the month turns values into the billable number of users to bill
// for the previous month. Note there is a Date Override for testing purposes.
//
// Check if Date is the First. Note this method might be problematic if the
// code doesn't run on the 1st of the month. We can use the Date Override
// though. This will be harder if code doesn't run on 1st but runs on second,
// in either case we can run a query to rollback the accumulator for all the
// JETs and then run this function as if it was the first. Downside, without
// more SQL efforts, we lost a day of "user counting" which works in customer's
// favor if don't run a process to recount for the said day. Again this
// routine's data override will assist.
procedure JASAPI_JetBilling(p_Context: TCONTEXT);
//=============================================================================
{}
// This JASAPI call performs the exact function that the TJADO or TCONNECTION
// classes offer. Session Validation is performed. Also, the user needs to have
// READ PERMISSION for the juserpref table or the call will fail.
procedure JASAPI_GetValue(p_Context: TCONTEXT);
//=============================================================================
{}
// This JASAPI call accepts a parameter named UID which is the UID for the
// juserpref table. In this table is the jhelp UID that we use to grab the
// html help for both the user and (if an admin) the admin help too, in the
// appropriate language for the user.
procedure JASAPI_UserPrefHelp(p_Context: TCONTEXT);
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
// Runs Jegas API functions and wraps the results in IWF friendly xml
procedure JASAPI_Dispatch(p_Context: TCONTEXT);  
//=============================================================================
label done_jasapi;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_Dispatch(p_Context: TCONTEXT);  '; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102759,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102760, sTHIS_ROUTINE_NAME);{$ENDIF}


  // The IWF framework has a few values we need to populate. The one that changes how the 
  // result is used on the client receiving the file is the actiontype value. IWF has the 
  // ability to dynamically deliver javascript. Normally this value will be "xml" but for
  // some fancy client interactions, it can be changed as required. See IWF documentation
  // for more instruction.
  p_Context.sFileNameOnlyNoExt:=lowercase(p_Context.sFileNameOnlyNoExt);
  if (p_Context.sFileNameOnlyNoExt='helloworld')then
  begin 
    jasapi_helloworld(p_Context); 
    goto done_jasapi; 
  end;
  
  if (p_Context.sFileNameOnlyNoExt='validatesession')then
  begin 
    jasapi_validatesession(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='createsession')then
  begin 
    jasapi_createsession(p_Context);
    goto done_jasapi;
  end;
  
  if (p_Context.sFileNameOnlyNoExt='removesession')then
  begin 
    jasapi_removesession(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='renderquicklinks')then
  begin
    jasapi_renderquicklinks(p_Context);
    goto done_jasapi;
  end;

  if(p_Context.sFileNameOnlyNoExt='settheme') then
  begin
    JASAPI_SetTheme(p_Context);
    goto done_jasapi;
  end;

  if(p_Context.sFileNameOnlyNoExt='setdisplayheaders') then
  begin
    JASAPI_SetDisplayHeaders(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='setdisplayquicklinks') then
  begin
    JASAPI_SetDisplayQuickLinks(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='setbackgroundrepeat') then
  begin
    JASAPI_SetBackgroundrepeat(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='seticontheme') then
  begin
    JASAPI_SetIconTheme(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='maketable') then
  begin
    JASAPI_MakeTable(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='tableexist') then
  begin
    JASAPI_TableExist(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='columnexist') then
  begin
    JASAPI_ColumnExist(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='makecolumn') then
  begin
    JASAPI_MakeColumn(p_Context);
    goto done_jasapi;
  end;


  if (p_Context.sFileNameOnlyNoExt='rowexist') then
  begin
    JASAPI_RowExist(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='email') then
  begin
    JASAPI_Email(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='filtersavedef') then
  begin
    JASAPI_FilterSaveDef(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='movequicklink') then
  begin
    JASAPI_MoveQuickLink(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='register')then
  begin
    jasapi_register(p_Context);
    goto done_jasapi; // For speed - to jump over multiple conditionals as things grow
  end;

  
  if (p_Context.sFileNameOnlyNoExt='copyscreen') then
  begin
    JASAPI_CopyScreen(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='newconanddb') then
  begin
    JASAPI_NewConAndDB(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='dbmasterutility') then
  begin
    JASAPI_DBMasterUtility(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='setdefaultsecuritysettings') then
  begin
    JASAPI_SetDefaultSecuritySettings(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='createvirtualhost') then
  begin
    JASAPI_CreateVirtualHost(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='doesuserhavejet') then
  begin
    JASAPI_DoesUserHaveJet(p_Context);
    goto done_jasapi;
  end;
  
  if (p_Context.sFileNameOnlyNoExt='jetbilling') then
  begin
    JASAPI_JetBilling(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='getvalue') then
  begin
    JASAPI_GetValue(p_Context);
    goto done_jasapi;
  end;

  if (p_Context.sFileNameOnlyNoExt='userprefhelp') then
  begin
    JASAPI_UserPrefHelp(p_Context);
    goto done_jasapi;
  end;

  //p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_422;// 422 - unprocessable entity
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Force Bad Call through as xml error response
  p_Context.bErrorCondition:=true;
  p_Context.u8ErrNo:=201507132023;
  p_Context.saErrMsg:='Invalid JAS API Function Name';
  p_Context.saErrMsgMoreInfo:='';


  done_jasapi:

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102761,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

 
//=============================================================================
procedure jasapi_helloworld(p_Context: TCONTEXT);
//=============================================================================
var 
  xmlnode: JFC_XML;
  xmlnode2: JFC_XML;
  bOk: boolean;//  booo security
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='jasapi_helloworld(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102762,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102763, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201608241531, 'Invalid Session.','',SOURCEFILE);
  end;

  if bok then
  begin
    bOk:=bJAS_HasPermission(p_context, cnPerm_API_Helloworld);//so sad - i know an admin will want this off if tightening up so...
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241531, 'You are not authorized to say hello to the WORLD! So THERE!','',SOURCEFILE);
    end;
  end;

  with p_Context do begin
    // The dataxdl is where ouput data goes
    p_Context.XML.AppendItem_saName_n_saValue('helloworld','hello world!');

    // Here we interrogate the CGIENV class which contains the kinds of things 
    // required for web application development: form parameters,
    // environment information etc. 
    // So.. that said, we are iterating through all the cook ies that may have
    // come in and our sending them out as part of this functions result. 
    //p_Context.XML.AppendItem_saName('CKY  IN');
    //if(p_Context.CGIENV.CKY IN.MoveFirst)then
    //begin
    //  xmlnode:=JFC_XML.Create;
    //  p_Context.XML.Item_lpPtr:=xmlnode;
    //  repeat
    //    xmlnode.AppendItem_saName_n_saValue(
    //      p_Context.CGIENV.CKY IN.Item_saName,
    //      p_Context.CGIENV.CKY IN.Item_saValue
    //    );
    //  until not p_Context.CGIENV.CKY IN.movenext;
    //end;

    // Here we interrogate any and all parameters that came in either through
    // POST method or GET (and if post, we still collect parameters from the URL
    // effectively making POST a dual role :) 
    p_Context.XML.AppendItem_saName('DATAIN');
    if(p_Context.CGIENV.DATAIN.MoveFirst)then
    begin
      xmlnode:=JFC_XML.Create;
      p_Context.XML.Item_lpPtr:=xmlnode;
      repeat
        xmlnode.appenditem_saName(p_Context.CGIENV.DATAIN.Item_saName);
        xmlnode2:=JFC_XML.Create;
        xmlnode.Item_lpPtr:=xmlnode2;
        xmlnode2.AppendItem_saName_n_saValue('value',p_Context.CGIENV.DATAIN.Item_saValue);
        xmlnode2.AppendItem_saName_n_saValue('desc',p_Context.CGIENV.DATAIN.Item_saDesc);
      until not p_Context.CGIENV.DATAIN.movenext;
    end;

    // Now we add a cook ie for the output. You should see it when you call
    // this function a second time. First call it's sent, after it might 
    // come in with the other cook ies :)
    //p_Context.CGIENV.AddCook ie(
    //  'cook iename',
    //  'cook ievalue',
    //  p_Context.CGIENV.saRequestURIWithoutParam,
    //  dtAddMinutes(now,grJASConfig.u2SessionTimeOutInMinutes),
    //  false
    //);
  end;
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102764,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
// The purpose of this function is faceted. Removed DATED Sessions,
// Validate that the REMOTE_ADDR of the user has not changed.
//=============================================================================
procedure jasapi_validatesession(p_Context: TCONTEXT);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='jasapi_validatesession(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102675,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102676, sTHIS_ROUTINE_NAME);{$ENDIF}

  p_Context.XML.AppendItem_saName_n_saValue('validatesession',trim(sTrueFalse(bJAS_ValidateSession(p_Context))));
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102677,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================


//=============================================================================
procedure jasapi_createsession(p_Context: TCONTEXT);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='jasapi_createsession(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102678,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102679, sTHIS_ROUTINE_NAME);{$ENDIF}

  bJAS_CreateSession(p_Context);
  p_Context.XML.AppendItem_saName_N_saValue('createsession',IntToStr(p_Context.iSessionResultCode));
  if p_Context.iSessionResultCode=cnSession_Success then
  begin
    //JFC_XMLITEM(p_Context.XML.lpItem).AttrXDL.AppendItem_saName_N_saValue('sessionid',p_Context.rJSession.JSess_JSession_UID);
    p_Context.XML.AppendItem_saName_N_saValue('sessionid',inttostr(p_Context.rJSession.JSess_JSession_UID));
  end;

  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102680,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
Procedure jasapi_removesession(p_Context:TCONTEXT);
//=============================================================================
Var
  bOk: Boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='jasapi_removesession(p_Context:TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102681,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102682, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140347, 'jasapi_removesession - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_RemoveSession(p_Context);
  end;
  p_Context.XML.AppendItem_saName_N_saValue('removesession',trim(sTrueFalse(bOk)));

  // Nothing dramatic happened, so we use the HTTP style error codes to make sure the given renderer,
  // if applicable, doesn't think something went haywire.
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102683,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================



 
 

 
 
//=============================================================================
procedure JAS_XmlTest(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  rJTestOne: rtJTestOne;
  DBC: JADO_CONNECTION;   
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_XmlTest(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102690,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102691, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  p_context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140349, 'JAS_XmlTest - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_XMLTest);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241443, 'You are not authorized to perform this action.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    rJTestOne.JTes1_JTestOne_UID:=0;
    rJTestOne.JTes1_Memo:=p_Context.saIN;
    bOk:=bJas_Save_jTestOne(p_Context,DBC,rJTestOne,false,false,201608310110);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201002231717, 'Problem saving posted data to JAS_XmlTest function in '+SOURCEFILE,'',SOURCEFILE);
    end;
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase(sTrueFalse(bOk)));

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102692,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
 
 








//=============================================================================
procedure JASAPI_RenderQuickLinks(p_Context: TCONTEXT);
//=============================================================================
var
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  bOk: boolean;
  saQry: ansistring;
  saData: ansistring;
  bRender: boolean;
  sIcon: string;
  bJMail: boolean;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_RenderQuickLinks(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102693,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102694, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  p_Context.XML.AppendItem_lpPtr(nil);
  p_Context.XML.Item_saName:='QuickLinks';
  //if 'OFF'<>upcase(trim(p_Context.CGIENV.CKY IN.get_savalue('JASDISPLAYQUICKLINKS'))) then
  begin
    DBC:=p_Context.VHDBC;
    rs:=JADO_RECORDSET.Create;
    
    if bOk then
    begin
      saQry:=
	      'SELECT '+
	      '  JQLnk_JQuickLink_UID,'+
	      '  JQLnk_Name,'+
	      '  JQLnk_SecPerm_ID,'+
	      '  JQLnk_Desc,'+
	      '  JQLnk_URL,'+
	      '  JQLnk_Icon,';
        saQry+=
	      '  JQLnk_Owner_JUser_ID,'+
	      '  JQLnk_Position_u, '+
        '  JQLnk_ValidSessionOnly_b,'+
	      '  JQLnk_DisplayIfNoAccess_b,'+
	      '  JQLnk_DisplayIfValidSession_b,'+
	      '  JQLnk_RenderAsUniqueDiv_b,'+
	      '  JQLnk_Private_Memo,';
        saQry+=
	      '  JQLnk_Private_b '+
	      'FROM jquicklink '+
	      'WHERE JQLnk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' and ';
      if(p_Context.bSessionValid) then
      begin
        saQry+='JQLnk_DisplayIfValidSession_b=true ';
      end
      else
      begin
        saQry+='JQLnk_DisplayIfNoAccess_b=true and '+
               '(JQLnk_ValidSessionOnly_b<>true)';
      end;
      saQry+=' ORDER BY JQLnk_Position_u ';


      bOk:=rs.open(saQry, DBC,201503161400);
      if not bOk then
      begin
        p_Context.bErrorCondition:=true;
        p_Context.u8ErrNo:=201012201638;
        p_Context.saErrMsg:='RenderQuickLinks - Trouble with Query.';
        p_Context.saErrMsgMoreInfo:='Query: '+saQry;
      end;
    end;

    if bOk then
    begin
      saData:=csCRLF+'<ul>'+csCRLF;
      //if p_Context.bSessionValid then
      //begin
        saData+='  <li>'+csCRLF+'    <a title="Home" href="[@ALIAS@]" target="_blank">'+csCRLF+
          '      <img class="image" src="[@JASDIRICONTHEME@]22/places/user-home.png" />'+csCRLF+
          '    </a>'+csCRLF+'  </li>'+csCRLF;
      //end;

      //if p_Context.bSessionValid then
      //begin
        saData+='  <li>'+csCRLF+'    <a target="_blank" href="[@ALIAS@].?Action=JAS_Calendar&JSID=[@JSID@]" title="Calendar" >'+csCRLF+
            '      <img class="image" src="[@JASDIRICONTHEME@]22/apps/accessories-date.png" />'+csCRLF+'    </a>'+csCRLF+'  </li>'+csCRLF;
      //end;

      //--- inbox - with growing mailbox
      if p_Context.bSessionValid then
      begin
        bJMail:=(0<DBC.u8GetRecordCount('jmail','JMail_CreatedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' and '+
          'JMail_From_User_ID<>'+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))',201506171747));
        saData+='  <li>'+csCRLF+'    <a target="_blank" href="[@ALIAS@].';
        if (p_Context.rJUser.JUser_JUser_UID<>cnJUserID_Guest) then saData+='?screen=jmail+Search' else saData+='?SCREENID=354';
        saData+='&JSID=[@JSID@]" title="JMail" >'+csCRLF+'      <img src="[@JASDIRICONTHEME@]';
        if bJMail then saData+='32' else saData+='22';
        saData+='/actions/mail.png" />'+csCRLF+'    </a>'+csCRLF+'  </li>';
      end;
          

      if(rs.eol=false) then
      begin 
        repeat
      	  bRender:=true;
          if(p_Context.bSessionValid) then
          begin
            if(u8Val(rs.fields.Get_saValue('JQLnk_SecPerm_ID'))>0)then
	          begin
	            bRender:=bJAS_HasPermission(p_Context,u8Val(rs.fields.Get_saValue('JQLnk_SecPerm_ID')));
	          end;
            if bRender then
            begin
              if bVal(rs.fields.Get_saValue('JQLnk_Private_b')) then
              begin
                bRender:=p_Context.rJUser.JUser_JUser_UID=u8Val(rs.fields.Get_saValue('JQLnk_Owner_JUser_ID'));
              end;
            end;
          end;

          if bRender then
          begin 
            if (trim(rs.fields.Get_saValue('JQLnk_Icon'))='') or (trim(rs.fields.Get_saValue('JQLnk_Icon'))='NULL') then
            begin
              sIcon:='      <img class="image" src="[@JASDIRICON@]JAS/products/jas/32/jas_logo.png" /> ';
            end
            else
            begin
              sIcon:='      <img class="image" src="'+rs.fields.Get_saValue('JQLnk_Icon')+'" />';
            end;
            sIcon:=saSNRStr(sIcon, '[@JASDIRICONTHEME@]',garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+p_Context.sIconTheme+'/');
            sIcon:=saSNRStr(sIcon, '<? echo $JASDIRICONTHEME; ?>',garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+p_Context.sIconTheme+'/');
            sIcon:=saSNRStr(sIcon, '[@JASDIRICON@]',garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/');
            sIcon:=saSNRStr(sIcon, '<? echo $JASDIRICON; ?>',garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/');
         
            if NOT (bVal(rs.fields.Get_saValue('JQLnk_RenderAsUniqueDiv_b')))then
            begin
              saData+='  <li>'+csCRLF+'    <a target="_blank" href="'+rs.fields.Get_saValue('JQLnk_URL')+'" '+
                      ' title="'+saHtmlScrub(rs.fields.get_saValue('JQLnk_Name'))+'" >'+csCRLF+
                      sIcon+csCRLF+'    </a>'+csCRLF+'  </li>'+csCRLF;
            end
            else
            begin
              saData+='  <li>'+csCRLF+
                '    <div id="QLDIV'+rs.fields.Get_saValue('JQLnk_JQuickLink_UID')+'">'+csCRLF+
                '      <a id="QLANCHOR'+rs.fields.Get_saValue('JQLnk_JQuickLink_UID')+'">'+sIcon+csCRLF;
              saData+=
                '      </a>'+csCRLF+
                '    </div>'+csCRLF+'  </li>'+csCRLF;
            end;
          end;
        until (not bOk) or (not rs.MoveNext);
      end;
      saData+='</ul>'+csCRLF;
      //saData+='<br /><p>'+saQry+'</p>';
    end;
    //Log(cnLog_DEBUG, 201012201726, 'saData:'+saData+'   QUERY:'+saQry, SOURCEFILE);
    rs.destroy;
  end;
  p_Context.sMimeType:=csMIME_TextXML;
  p_Context.XML.Item_saValue:=saData;
  p_Context.XML.Item_bCData:=true;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102695,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
procedure JASAPI_SetTheme(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bLocked: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetTheme(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102696,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102697, sTHIS_ROUTINE_NAME);{$ENDIF}

  bLocked:=false;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if bok then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'juser',p_COntext.rJuser.JUser_JUser_UID,0,201607192115);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192116,
        'Unable to save color  theme user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' Record Lock could not be won.',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bLocked:=true;
    saQry:='update juser set JUser_Theme='+DBC.saDBMSScrub(p_Context.CGIEnv.DATAIN.Get_saValue('name'))+
      ' WHERE (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID) + ') and '+
      ' ((JUser_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JUser_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201607192117);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192118,
        'Unable to save color theme user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' updating juser table',SOURCEFILE);
    end;
  end;

  if bLocked then
  begin
    bJAS_UnLockRecord(p_Context, DBC.ID, 'juser',p_Context.rJUser.JUser_JUser_UID,0,201607192119);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',trim(lowercase(struefalse(bOk))));
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  rs.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102698,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
procedure JASAPI_SetDisplayHeaders(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bLocked: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetDisplayHeaders(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102699,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102700, sTHIS_ROUTINE_NAME);{$ENDIF}
  bLocked:=false;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if bok then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'juser',p_COntext.rJuser.JUser_JUser_UID,0,201607192002);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192002,
        'Unable to save display headers user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' Record Lock could not be won.',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bLocked:=true;
    saQry:='update juser set JUser_Headers_b='+DBC.sDBMSBoolScrub(p_Context.CGIEnv.DATAIN.Get_saValue('value'))+
      ' WHERE (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID) + ') and '+
      ' ((JUser_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JUser_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201607191958);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192002,
        'Unable to save display headers user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' updating juser table',SOURCEFILE);
    end;
  end;

  if bLocked then
  begin
    bJAS_UnLockRecord(p_Context, DBC.ID, 'juser',p_Context.rJUser.JUser_JUser_UID,0,201607192033);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',trim(lowercase(struefalse(bOk))));
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  rs.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102701,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure JASAPI_SetDisplayQuickLinks(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bLocked: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetDisplayQuickLinks'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102702,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102703, sTHIS_ROUTINE_NAME);{$ENDIF}
  bLocked:=false;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if bok then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'juser',p_COntext.rJuser.JUser_JUser_UID,0,201607192017);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192018,
        'Unable to save QuickLinks view user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' Record Lock could not be won.',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bLocked:=true;
    saQry:='update juser set JUser_QuickLinks_b='+DBC.sDBMSBoolScrub(p_Context.CGIEnv.DATAIN.Get_saValue('value'))+
      ' WHERE (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID) + ') and '+
      ' ((JUser_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JUser_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201607192019);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201607192020,
        'Unable to save QuickLinks view user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' updating juser table',SOURCEFILE);
    end;
  end;

  if bLocked then
  begin
    bJAS_UnLockRecord(p_Context, DBC.ID, 'juser',p_Context.rJUser.JUser_JUser_UID,0,201607192032);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',trim(lowercase(struefalse(bOk))));
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102704,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================














//=============================================================================
procedure JASAPI_SetBackgroundRepeat(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bLocked: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetBackgroundRepeat'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201610302002,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201610302003, sTHIS_ROUTINE_NAME);{$ENDIF}
  bLocked:=false;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  //bOk:=p_Context.bValidateSession;
  //if bok then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'juser',p_COntext.rJuser.JUser_JUser_UID,0,201610302004);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201610302005,
        'Unable to save Background Repeat user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' Record Lock could not be won.',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bLocked:=true;
    saQry:='update juser set JUser_BackgroundRepeat_b='+DBC.sDBMSBoolScrub(p_Context.CGIEnv.DATAIN.Get_saValue('value'))+
      ' WHERE (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID) + ') and '+
      ' ((JUser_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JUser_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201610302006);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201610302007,
        'Unable to save Background Repeat user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' updating juser table',SOURCEFILE);
    end;
  end;

  if bLocked then
  begin
    bJAS_UnLockRecord(p_Context, DBC.ID, 'juser',p_Context.rJUser.JUser_JUser_UID,0,201610302008);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',trim(lowercase(struefalse(bOk))));
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201610302009,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















//=============================================================================
procedure JASAPI_SetIconTheme(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bLocked: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetIconTheme(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102705,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102706, sTHIS_ROUTINE_NAME);{$ENDIF}
  bLocked:=false;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if bok then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'juser',p_COntext.rJuser.JUser_JUser_UID,0,2016072047);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 2016072048,
        'Unable to save Icon Theme view user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' Record Lock could not be won.',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bLocked:=true;
    saQry:='update juser set JUser_IconTheme='+DBC.saDBMSScrub(p_Context.CGIEnv.DATAIN.Get_saValue('name'))+
      ' WHERE (JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID) + ') and '+
      ' ((JUser_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JUser_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,2016072049);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 2016072050,
        'Unable to save Icon Theme view user preference.',
        'JUser: '+inttostr(p_COntext.rJuser.JUser_JUser_UID)+' updating juser table',SOURCEFILE);
    end;
  end;

  if bLocked then
  begin
    bJAS_UnLockRecord(p_Context, DBC.ID, 'juser',p_Context.rJUser.JUser_JUser_UID,0,2016072051);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',trim(lowercase(struefalse(bOk))));
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102707,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// JASAPI_MakeTable identical to except takes jasapi=maketable as indication
// that is what is being requested versus cnAction_MakeTable=53;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_MakeTable(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  JTabl_JTable_UID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_MakeTable(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102708,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102709, sTHIS_ROUTINE_NAME);{$ENDIF}

  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140404, 'jasapi_maketable - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_MakeTable);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204140405, 'Not authorized. "Database Maintenance" permission required for this operation.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID');
    bOk:=bJAS_MakeTable(p_Context, JTabl_JTable_UID);
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase(sTrueFalse(bOk)));
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102710,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
// make database table using data in jtable and jcolumn
function bJAS_MakeTable(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring): boolean;
//=============================================================================
var
  rJTable: rtJTable;
  bOk: boolean;
  bTableExists: boolean;
  TGT: JADO_CONNECTION; // TARGET Dataconnection for new Table
  DBC: JADO_CONNECTION; // for permission creation and table and column meta-data
  saDDL: ansistring;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rJColumn: rtJColumn;
  sPKeyName: string;
  sField: string;
  DT: TDATETIME;
  rJSecPerm: rtJSecPerm;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_MakeTable(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring): boolean;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102711,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102712, sTHIS_ROUTINE_NAME);{$ENDIF}

  DT:=now;
  rs:=JADO_RECORDSET.Create;
  DBC:=p_Context.VHDBC;
  bOk:=true;

  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=u8Val(p_JTabl_JTable_UID);
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable,false,201608310111);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_ERROR, 201110101808, 'JAS_MakeTable - Unable to load JTable record. UID: ' +
        inttostr(rJTable.JTabl_JTable_UID), '',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    TGT:=nil;
    //riteln('make table before assigning TGT');
    TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312260);
    //riteln('make table AFTER assigning TGT');
    bOk:=TGT<>nil;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201110101809, 'JAS_MakeTable - Unable to connect to database. '+
        'DBCON came back null for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID), '',SOURCEFILE);
    end;
  end;

  sPKeyName:=TGT.sGetPkeyColumnName(rJTable.JTabl_Name,201210020202);
  if sPKeyName='' then sPKeyName:=rJTable.JTabl_ColumnPrefix+'_'+saProper(rJTable.JTabl_Name)+'_UID';

  if bOk then
  begin
    {
     CREATE TABLE `jas_jegas`.`TEST2` ( `tempcolumn` BIGINT UNSIGNED NOT NULL,PRIMARY KEY (`tempcolumn`)) ENGINE = InnoDB;
    }
    bTableExists:=TGT.bTableExists(rJTable.JTabl_Name,201210020201);
    if not bTableExists then
    begin
      saDDL:='CREATE TABLE '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' '+
        '('+TGT.sDBMSEncloseObjectName(sPKeyName)+' BIGINT UNSIGNED NOT NULL, PRIMARY KEY ('+TGT.sDBMSEncloseObjectName(sPKeyName)+'))';
      bOk:=rs.open(saDDL, TGT,201503161401);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201110101810, 'JAS_MakeTable - Trouble with CREATE TABLE query: '+saDDL, '',SOURCEFILE,TGT,rs);
      end;
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:=
      'select '+
      '  JColu_JColumn_UID '+
      'from jcolumn '+
      'where '+
      ' JColu_JTable_ID='+inttostr(rJTable.JTabl_JTable_UID)+' and '+
      ' JColu_PrimaryKey_b='+DBC.sDBMSBoolScrub(false)+' and '+
      ' JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry, DBC,201503161402);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110110333;
      p_Context.saErrMsg:='JAS_MakeTable - Trouble with query: '+saQry;
      JAS_Log(p_Context,cnLog_Error, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE,DBC,rs);
    end;
  end;

  if bok and (not rs.eol) then
  begin
    repeat
      clear_JColumn(rJColumn);
      rJColumn.JColu_JColumn_UID:=u8Val(rs.fields.get_saValue('JColu_JColumn_UID'));
      //if not DBC.bColumnExists(rJTable.JTabl_Name, rJColumn.JColu_Name) then
      //begin
        bOk:=bJAS_MakeColumn(p_Context, inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error, 201110111218, 'JAS_MakeTable - JAS_MakeColumn Failed '+
            ' DBCON: '+inttostr(TGT.ID)+' JTabl_JTable_UID:'+inttostr(rJTable.JTabl_JTable_UID)+
            ' JTabl_Name: ' + rJTable.JTabl_Name+
            ' JColu_JColumn_UID: '+inttostr(rJColumn.JColu_JColumn_UID)+
            ' JColu_Name: '+rJColumn.JColu_Name, '', SOURCEFILE);
        end;
      //end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  // NOw WE ADD What is missing
  // --- ADD UID to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    //if not DBC.bColumnExists(rJTable.JTabl_Name, sPKey) then
    //begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sPKeyName;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_u8;
        JColu_AllowNulls_b            := false;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := true;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 8;
        JColu_NumericScale_u          := 1;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := true;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := '';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310112);
      if not bOk then
      begin
        //ASPrintln('FAILED making jcolumn record');
        JAS_Log(P_Context,cnLog_Error,201110110459,'JAS_MakeTable - Trouble with bSave_JColumn','JColu_JColumn_UID:'+
          inttostr(rJColumn.JColu_JColumn_UID),SOURCEFILE);
      end;

      if bOk and not rJColumn.JColu_PrimaryKey_b then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151226, 'JAS_Make_Table - Unable to create Primary Key column','',SOURCEFILE);
        end;
      end;
    //end;
  end;
  // --- ADD UID to JColumn ------------------------------ END




  // --- ADD _CreatedBy_JUser_ID to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_CreatedBy_JUser_ID';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020040) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_u8;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 8;
        JColu_NumericScale_u          := 1;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310113);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201110110501, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151236, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- ADD CreatedBy_JUser_ID to JColumn ------------------------------ END






  // --- ADD _Created_DT  to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_Created_DT';
    if not DBC.bColumnExists(rJTable.JTabl_Name, sField,201210020041) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_dt;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 0;
        JColu_NumericScale_u          := 0;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310114);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201110110503, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151236, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- _Created_DT to JColumn ------------------------------ END







  // --- ADD _ModifiedBy_JUser_ID to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_ModifiedBy_JUser_ID';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020042) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_u8;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 8;
        JColu_NumericScale_u          := 1;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310115);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151239, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151240, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- ADD ModifiedBy_JUser_ID to JColumn ------------------------------ END






  // --- ADD _Modified_DT  to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_Modified_DT';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020043) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_dt;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 0;
        JColu_NumericScale_u          := 0;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310116);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151240, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151241, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- _Modified_DT to JColumn ------------------------------ END









  // --- ADD _DeletedBy_JUser_ID to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_DeletedBy_JUser_ID';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020044) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_u8;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 8;
        JColu_NumericScale_u          := 1;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310117);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151242, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151243, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- ADD DeletedBy_JUser_ID to JColumn ------------------------------ END






  // --- ADD _Deleted_DT  to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_Deleted_DT';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020045) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_dt;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 0;
        JColu_NumericScale_u          := 0;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310118);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151244, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151245, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- _Deleted_DT to JColumn ------------------------------ END











  // --- ADD _Deleted_b  to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:=rJTable.JTabl_ColumnPrefix+'_Deleted_b';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020046) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_b;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 0;
        JColu_NumericScale_u          := 0;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := false;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310119);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151246, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151247, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- _Deleted_b to JColumn ------------------------------ END








  // --- ADD JAS_Row_b  to JColumn ------------------------------ BEGIN
  if bOk then
  begin
    sField:='JAS_Row_b';
    if not TGT.bColumnExists(rJTable.JTabl_Name, sField,201210020047) then
    begin
      clear_JColumn(rJColumn);
      with rJColumn do begin
        //JColu_JColumn_UID             : ansistring;
        JColu_Name                    := sField;
        JColu_JTable_ID               := rJTable.JTabl_JTable_UID;
        JColu_JDType_ID               := cnJDType_b;
        JColu_AllowNulls_b            := true;
        JColu_DefaultValue            := 'NULL';
        JColu_PrimaryKey_b            := false;
        JColu_JAS_b                   := false;
        JColu_JCaption_ID             := 0;
        JColu_DefinedSize_u           := 1;
        JColu_NumericScale_u          := 0;
        JColu_Precision_u             := 0;
        JColu_Boolean_b               := true;
        JColu_JAS_Key_b               := false;
        JColu_AutoIncrement_b         := false;
        JColu_LUF_Value               := 'NULL';
        JColu_LD_CaptionRules_b       := false;
        JColu_JDConnection_ID         := TGT.ID;
        JColu_Desc                    := 'NULL';
        JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Created_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        JColu_Modified_DT:=FormatDateTime(csDATETIMEFORMAT,DT);
        JColu_DeletedBy_JUser_ID      :=0;
        JColu_Deleted_DT              :='NULL';
        JColu_Deleted_b               :=false;
        JAS_Row_b                     :=false;
      end;//with
      bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, false, false,201608310120);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error, 201204151248, 'JAS_MakeTable - Trouble with bSave_JColumn', '', SOURCEFILE);
      end;

      if bOk then
      begin
        bOk:=bJAS_MakeColumn(p_Context,inttostr(rJColumn.JColu_JColumn_UID));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204151249, 'JAS_Make_Table - Unable to create '+sField,'',SOURCEFILE);
        end;
      end;
    end;
  end;
  // --- JAS_Row_b to JColumn ------------------------------ END


writeln('MAke Table - About to add permissions');


  //----- ADD STANDARD PERMISSIONS TO GO ALONG WITH TABLE
  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' Add';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171748) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310120);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030052,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' Edit';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171749) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310121);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030053,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' View';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171748) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310122);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030054,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' Delete';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171749) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310123);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030055,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' Modify';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171750) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310124);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030056,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    clear_JSecPerm(rJSecPerm);rJSecPerm.perm_Name:=rJTable.JTabl_Name+' Export';
    if 0=DBC.u8GetRecordCount('jsecperm','perm_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'perm_Name='+DBC.saDBMSSCrub(rJSecPerm.perm_Name),201506171751) then
    begin
      bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false,201608310125);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201205030057,'Trouble saving new permission: ' +rJSecPerm.perm_Name,'',SOURCEFILE);
      end;
    end;
  end;


  result:=bOk;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102713,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// JASAPI_TableExist identical to except takes jasapi=maketable as indication
// that is what is being requested versus cnAction_TableExist=54;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_TableExist(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  JTabl_JTable_UID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_TableExist(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102714,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102715, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140406, 'jasapi_tableexist - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_TableExist);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204140407, 'Not authorized. "Database Maintenance" permission required for this operation.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID');
    bOk:=bJAS_TableExist(p_Context,JTabl_JTable_UID);
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase(sTrueFalse(bOk)));
  //p_Context.XML.AppendItem_saName_N_saValue('ok',lowercase(sTrueFalse(bOk)));
  //p_Context.XML.AppendItem_saName_N_saValue('TableExist',lowercase(sTrueFalse(bTableExists)));
  //p_Context.XML.AppendItem_saName_N_saValue('u8ErrNo',inttostr(p_Context.u8ErrNo));
  //p_Context.XML.AppendItem_saName_N_saValue('saErrMsg',p_Context.saErrMsg);
  //CreateIWFXML(p_Context);
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102716,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// return true or false if table exists for given connection
function bJAS_TableExist(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring): boolean;
//=============================================================================
var
  rJTable: rtJTable;
  bOk: boolean;
  bTableExists: boolean;
  DBC: JADO_CONNECTION;// Main DB
  TGT: JADO_CONNECTION;// Target DB
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_TableExist(p_Context: TCONTEXT; p_JTabl_JTable_UID: ansistring): boolean;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102717,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102718, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=u8Val(p_JTabl_JTable_UID);
    bOk:=bJAS_Load_JTable(p_Context, DBC,rJTable,false,201608310130);
    if not bOk then
    begin
      //p_Context.u8ErrNo:=201110082234;
      //p_Context.saErrMsg:='JAS_TableExist - Unable to load JTable record. UID: ' + rJTable.JTabl_JTable_UID;
      //JLog(cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    TGT:=nil;
    TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312261);
    if (TGT=nil) and (rJTable.JTabl_JDConnection_ID=0) then TGT:=p_Context.JADOC[0];
    bOk:=TGT<>nil;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110082235;
      p_Context.saErrMsg:='JAS_TableExist - Unable to connect to database. '+
        'DBCON came back null for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  bTableExists:=false;
  if bOk then
  begin
    bTableExists:=TGT.bTableExists(rJTable.JTabl_Name,201210020203);
  end;

  result:=bTableExists;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102719,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// JASAPI_Column identical to except takes jasapi=maketable as indication
// that is what is being requested versus cnAction_ColumnExist=55;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_ColumnExist(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  JColu_JColumn_UID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_ColumnExist(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102720,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102721, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140408, 'jasapi_columnexist - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_ColumnExist);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204140409, 'Not authorized.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JColu_JColumn_UID:=p_Context.CGIENV.DataIn.Get_saValue('JColu_JColumn_UID');
    bOk:=bJAS_ColumnExist(p_Context,JColu_JColumn_UID);
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( sTrueFalse( bOk )));
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102722,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// returns true or false if table's column exists for given connection
function bJAS_ColumnExist(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring):boolean;
//=============================================================================
var
  rJTable: rtJTable;
  rJColumn: rtJColumn;
  bOk: boolean;
  bColumnExists: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_ColumnExist(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring):boolean;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102723,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102724, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_COntext.VHDBC;
  clear_jcolumn(rJColumn);
  rJColumn.JColu_JColumn_UID:=u8Val(p_JColu_JColumn_UID);
  bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false,201608310131);
  if not bOk then
  begin
    p_Context.u8ErrNo:=201110082230;
    p_Context.saErrMsg:='JAS_ColumnExist - Unable to load JColumn record. UID: ' + inttostr(rJColumn.JColu_JColumn_UID);
    JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
  end;

  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=rJColumn.JColu_JTable_ID;
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable,false,201608310132);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110082231;
      p_Context.saErrMsg:='JAS_ColumnExist - Unable to load JTable record. UID: ' + inttostr(rJTable.JTabl_JTable_UID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    TGT:=nil;
    TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312262);
    bOk:=TGT<>nil;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110082232;
      p_Context.saErrMsg:='JAS_ColumnExist - Unable to connect to database. '+
        'DBCON came back null for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bColumnExists:=TGT.bColumnExists(rJTable.JTabl_Name, rJColumn.JColu_Name,201210020048);
  end;
  result:=bOk and bColumnExists;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102725,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// JASAPI_MakeColumn is identical to JAS_MakeColumn except
// that it takes jasapi=MakeColumn as then indication that is what
// is being requested versus cnAction_MakeColumn=56;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_MakeColumn(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  JColu_JColumn_UID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_MakeColumn(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102726,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102727, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140409, 'jasapi_makecolumn - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_MakeColumn);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204140410, 'Not authorized. "Database Maintenance" permission required for this operation.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JColu_JColumn_UID:=p_Context.CGIENV.DataIn.Get_saValue('JColu_JColumn_UID');
    bOk:=bJAS_Makecolumn(p_Context,JColu_JColumn_UID);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( sTrueFalse( bOk )));
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102728,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_MakeColumn(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring): boolean;
//=============================================================================
var
  rJTable: rtJTable;
  rJColumn: rtJColumn;
  bOk: boolean;
  bColumnExists: boolean;
  DBC: JADO_CONNECTION;  
  TGT: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  saDefault: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_MakeColumn(p_Context: TCONTEXT; p_JColu_JColumn_UID: ansistring): boolean;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102729,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102730, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  clear_jcolumn(rJColumn);
  rJColumn.JColu_JColumn_UID:=u8Val(p_JColu_JColumn_UID);
  bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false,201608310133);
  if not bOk then
  begin
    p_Context.u8ErrNo:=201110102230;
    p_Context.saErrMsg:='JAS_MakeColumn - Unable to load JColumn record. UID: ' + inttostr(rJColumn.JColu_JColumn_UID);
    JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
  end;

  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=rJColumn.JColu_JTable_ID;
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable,false,201608310134);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110102231;
      p_Context.saErrMsg:='JAS_MakeColumn - Unable to load JTable record. UID: ' + inttostr(rJTable.JTabl_JTable_UID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    TGT:=nil;
    TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312263);
    bOk:=TGT<>nil;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110102232;
      p_Context.saErrMsg:='JAS_MakeColumn - Unable to connect to database. '+
        'DBCON came back null for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bColumnExists:=TGT.bColumnExists(rJTable.JTabl_Name, rJColumn.JColu_Name,201210020049);
  end;

  saQry:='';
  saQry+='ALTER TABLE '+TGT.sDBMSEncloseObjectName(rJTable.JTAbl_Name)+' ';
  if bOk then
  begin
    if bColumnexists then
    begin
      // USE ALTER COLUMN
      saQRY+='MODIFY ' ;//+TGT.sDBMSEncloseObjectName(rJColumn.JColu_Name) +' ';
    end
    else
    begin
      // USE CREATE COLUMN
      saQRY+='ADD ';// +TGT.sDBMSEncloseObjectName(rJColumn.JColu_Name) +' ';
    end;

    saDefault:=rJColumn.JColu_DefaultValue;
    if saDefault='EMPTY' then saDefault:='';
    saQry+=JADO.saDDLField(
      rJColumn.JColu_Name,
      TGT.u8DBMSID,
      rJColumn.JColu_JDType_ID,
      rJColumn.JColu_DefinedSize_u,
      rJColumn.JColu_NumericScale_u,
      rJColumn.JColu_Precision_u,
      saDefault,
      rJColumn.JColu_AllowNulls_b,
      rJColumn.JColu_AutoIncrement_b,
      false // Clean Field Names - this is to prevent keyword field names.
    );
    bOk:=rs.open(saQry, TGT,201503161403);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110101514;
      p_Context.saErrMsg:='JAS_MakeColumn - trouble with query to create or alter a column. Qry:'+saQry;
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE,TGT,rs);
    end;
  end;
  rs.close;

  result:=bOk;
  rs.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102731,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// JASAPI_RowExist identical to JAS_RowExist except that it takes
// jasapi=rowexist as indication that is what is being requested versus
// cnAction_RowExist=57;
// The NAME (JASAPI) is kept to clearly indicate which functions use the JAS
// API, AJAX friendly paradigm to invoke them.
// JASAPI_???? Tend to be in uxxj_xml.pp while other "JAS" functions (actions)
// can be anywhere and are not guaranteed to return xml, they can be entire
// "mini applications" etc with HTML UI etc.
procedure JASAPI_RowExist(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  UID: ansistring;
  JTabl_JTable_UID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_RowExist(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102732,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102733, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140411, 'jasapi_rowexist - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_COntext, cnPerm_API_RowExist);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241605, 'jasapi_rowexist - Not authorized','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    UID:=p_Context.CGIENV.DataIn.Get_saValue('UID');
    JTabl_JTable_UID:=p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID');
    bOk:=bJAS_RowExist(p_Context,UID,JTabl_JTable_UID);
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( sTrueFalse(bOk)));

  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102734,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
function bJAS_RowExist(
  p_Context: TCONTEXT;
  p_UID: ansistring;
  p_JTabl_JTable_UID: ansistring
): boolean;
//=============================================================================
var
  rJTable: rtJTable;
  bOk: boolean;
  TGT: JADO_CONNECTION;
  DBC: JADO_CONNECTION;
  saUIDColumn: ansistring;
  saUID: ansistring;
  rs: JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='function bJAS_RowExist(p_Context: TCONTEXT;p_UID: ansistring;p_JTabl_JTable_UID: ansistring): boolean;'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102735,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102736, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.create;

  // return xml regardless if called as action or via
  if p_Context.CGIENV.uHTTPResponse=0 then
  begin
    p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  end;

  saUID:=p_UID;
  if bOk then
  begin
    clear_JTable(rJTable);
    rJTable.JTabl_JTable_UID:=u8Val(p_JTabl_JTable_UID);
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable,false,201608310135);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110091933;
      p_Context.saErrMsg:='JASAPI_RowExist - Unable to load JTable record. UID: ' + inttostr(rJTable.JTabl_JTable_UID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    TGT:=nil;
    TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312264);
    bOk:=TGT<>nil;
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110091934;
      p_Context.saErrMsg:='JAS_RowExist - Unable to connect to database. '+
        'DBCON came back null for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=TGT.bTableExists(rJTable.JTabl_Name,201210020204);
    if not bOk then
    begin
      p_Context.XML.AppendItem_saName_N_saValue('info','table '+
        rJTable.JTabl_Name+' does not exist');
    end;
  end;

  if bOk then
  begin
    saQry:='select JColu_Name '+
      'from jcolumn '+
      'where JColu_JTable_ID='+inttostr(rJTable.JTabl_JTable_UID)+' and '+
      'JColu_JAS_Key_b='+DBC.sDBMSBoolScrub(true)+' and '+
      'JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry,DBC,201503161404);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110091935;
      p_Context.saErrMsg:='JAS_RowExist - Unable to locate JegasKey column '+
        'row for JTable UID: ' + inttostr(rJTable.JTabl_JTable_UID)+
        ' JDConnection ID: '+inttostr(rJTable.JTabl_JDConnection_ID);
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.eol=false;
    if not bOk then
    begin
      p_Context.XML.AppendItem_saName_N_saValue('info','JegasKey column not '+
        'found for table '+rJTable.JTabl_Name+' does not exist');
    end;
  end;


  if bOk then
  begin
    saUIDColumn:=rs.fields.Get_saValue('JColu_Name');
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select '+saUIDColumn+' from '+rJTable.JTabl_Name + ' where '+
      saUIDColumn + ' = ' + saUID + ' and ' +
      DBC.sGetColumnPrefix(rJTable.JTabl_Name)+'_Deleted_b<>'+
      TGT.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry,TGT,201503161405);
    if not bOk then
    begin
      p_Context.u8ErrNo:=201110091935;
      p_Context.saErrMsg:='JAS_RowExist - trouble opening final query to '+
        'test for row existance. Qry: '+saQry;
      JAS_Log(p_Context,cnLog_FATAL, p_Context.u8ErrNo, p_Context.saErrMsg, '', SOURCEFILE, TGT, rs);
    end;
  end;
  result:=bOk and (rs.eol=false);
  rs.close;
  rs.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102737,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















//=============================================================================
{}
// Makes a particular saved filter the users default by adding it to the
// jfiltersavedef table.
//
// example: .?jasapi=filtersavedef&filtersave=1234
//
procedure JASAPI_FilterSaveDef(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  rJFilterSaveDef: rtJFilterSaveDef;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_FilterSaveDef(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204062359,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204070000, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204140419, 'jasapi_filtersavedef - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    clear_JFilterSaveDef(rJFilterSaveDef);
    rJFiltersaveDef.JFtSD_JFilterSave_ID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('filtersave'));
    saQry:='select JFtSa_JBlok_ID from jfiltersave '+
      'WHERE JFtSa_JFilterSave_UID='+DBC.sDBMSUIntScrub(rJFilterSaveDef.JFtSD_JFilterSave_ID)+' AND '+
            'JFtSa_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161406);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204070051, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
    end;

    if not rs.eol then
    begin
      rJFilterSaveDef.JFtSD_JBlok_ID:=u8Val(rs.fields.Get_saValue('JFtSa_JBlok_ID'));
      saQry:='JBlok_JBlok_UID='+DBC.sDBMSUIntScrub(rJFilterSaveDef.JFtSD_JBlok_ID)+' AND '+
        'JBlok_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
      if DBC.u8GetRecordCount('jblok',saQry,201506171752)>0 then
      begin
        rs.close;
        saQry:='select JFtSD_JFilterSaveDef_UID from jfiltersavedef '+
          ' WHERE JFtSD_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
          ' JFtSD_JBlok_ID='+DBC.sDBMSUIntScrub(rJFilterSaveDef.JFtSD_JBlok_ID)+' AND '+
          ' JFtSD_CreatedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
        bOk:=rs.open(saQry,DBC,201503161407);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204070007, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
        end;

        if bOk and (not rs.EOL) then
        begin
          repeat
            bOk:=bJAS_DeleteRecord(p_Context,DBC,'jfiltersavedef', u8Val(rs.fields.Get_saValue('JFtSD_JFilterSaveDef_UID')));
          until (not bOk) or (not rs.movenext);
        end;
        rs.close;

        if bOk then
        begin
          bOk:=bJAS_Save_JFilterSaveDef(p_Context, DBC, rJFilterSaveDef, false, false,201608310136);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201204070008, 'Trouble saving new filter default.','', SOURCEFILE);
          end;
        end;
      end;
    end;
    rs.close;
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  p_Context.XML.AppendItem_saName_N_saValue('filtersave',inttostr(rJFilterSaveDef.JFtSD_JFilterSave_ID));
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070001,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






















//=============================================================================
{}
// example: .?jasapi=movequicklink&UID=?????&direction=up&private=1
procedure JASAPI_MoveQuickLink(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  u4Pos: cardinal;
  u4NewPos: cardinal;
  bHaveRecords: boolean;
  bSwap: boolean;
  bGotLock: boolean;
  u4Highest: Cardinal;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_MoveQuickLink(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204162113,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204162114, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  bGotLock:=false;

  //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL entry: UID: '+p_Context.CGIENV.DataIn.Get_saValue('UID')+' '+
  //  'Direction: '+p_Context.CGIENV.DataIn.Get_saValue('direction')+' '+
  //  'Private: '+p_Context.CGIENV.DataIn.Get_saValue('private'),'', SOURCEFILE);


  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201204162115, 'jasapi_movequicklink - Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_LockRecord(p_COntext, DBC.ID, 'jquicklink',0,0,201501020010);// LOCK TABLE
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162116, 'Unable to lock QuickLink table for this operation.','', SOURCEFILE);
    end
    else
    begin
      bGotLock:=true;
    end;
  end;

  // Get all the Quicklinks in sequential order
  if bOk then
  begin
    saQry:='SELECT JQLnk_JQuickLink_UID FROM jquicklink WHERE JQLnk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND ';
    if bVal(rs.fields.Get_saValue('private')) then
    begin
      saQry+='JQLnk_Owner_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' AND JQLnk_Private_b='+DBC.sDBMSBoolScrub(true);
    end
    else
    begin
      saQry+='JQLnk_Private_b='+DBC.sDBMSBoolScrub(false);
    end;
    saQry+=' ORDER BY JQLnk_Position_u';
    //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL Query to Sort Set of Quicklinks: '+saQry,'', SOURCEFILE);
    bOk:=rs.open(saQry, DBC,201503161408);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162117, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk then
  begin
    bHaveRecords:=not rs.eol;
    if bHaveRecords then
    begin
      u4Pos:=1;
      repeat
        saQry:='update jquicklink set JQLnk_Position_u='+DBC.sDBMSUIntScrub(u4Pos)+
          ' WHERE JQLnk_JQuickLink_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JQLnk_JQuickLink_UID'));
        //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL Store Sort Positions : '+saQry,'', SOURCEFILE);
        bOk:=rs2.open(saQry,DBC,201503161409);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201204162118, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
        end;
        rs2.close;
        u4Pos+=1;
      until (not bOk) or (not rs.movenext);
      u4Pos-=1;
      u4Highest:=u4Pos;
      bHaveRecords:=u4Pos>2;
    end;
  end;
  rs.close;


  if bOk and bHaveRecords then
  begin
    saQry:='select JQLnk_Position_u from jquicklink where JQLnk_JQuickLink_UID='+DBC.sDBMSUIntScrub(p_Context.CGIENV.DataIn.Get_saValue('UID'));
    bOk:=rs.open(saQry, DBC,201503161410);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162131, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk and bHaveRecords then
  begin
    bOk:=(not rs.eol);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162131, 'Missing Expected QuickLink record.','Query: '+saQry, SOURCEFILE);
    end;
  end;

  bSwap:=false;
  if bOk and bHaveRecords then
  begin
    u4Pos:=u4Val(rs.fields.Get_saValue('JQLnk_Position_u'));
    //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL Grabbing Position ('+inttostr(u4Pos)+') of selected item: '+saQry,'', SOURCEFILE);
    if (upcase(p_Context.CGIENV.DataIn.Get_saValue('direction'))='UP') and (u4Pos>1) then
    begin
      u4NewPos:=u4Pos-1;
      bSwap:=true;
    end else

    if (upcase(p_Context.CGIENV.DataIn.Get_saValue('direction'))='DOWN') and (u4Pos<u4Highest) then
    begin
      u4NewPos:=u4Pos+1;
      bSwap:=true;
    end else
  end;
  rs.close;

  if bSwap then
  begin
    saQry:='update jquicklink set JQLnk_Position_u='+DBC.sDBMSUIntScrub(u4Pos)+
      ' WHERE JQLnk_Position_u='+DBC.sDBMSUIntScrub(u4NewPos)+' AND ';
    if bVal(rs.fields.Get_saValue('private')) then
    begin
      saQry+='JQLnk_Owner_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+' AND JQLnk_Private_b='+DBC.sDBMSBoolScrub(true);
    end
    else
    begin
      saQry+='JQLnk_Private_b='+DBC.sDBMSBoolScrub(false);
    end;
    //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL Swap Q1: '+saQry,'', SOURCEFILE);
    bOk:=rs.open(saQry, DBC,201503161411);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162141, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
    end;
    rs.close;
  end;

  if bSwap and bOk then
  begin
    saQry:='update jquicklink set JQLnk_Position_u='+DBC.sDBMSUIntScrub(u4NewPos)+
      ' WHERE JQLnk_JQuickLink_UID='+DBC.sDBMSUIntScrub(p_Context.CGIENV.DataIn.Get_saValue('UID'));
    //JAS_LOG(p_Context, nLog_Debug, 201204162141, 'QL Swap Q2: '+saQry,'', SOURCEFILE);
    bOk:=rs.open(saQry, DBC,201503161412);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204162142, 'Trouble with Query.','Query: '+saQry, SOURCEFILE,DBC,rs);
    end;
    rs.close;
  end;

  if bGotLock then  bOk:=bJAS_UnLockRecord(p_Context, DBC.ID, 'jquicklink',0,0,201501020011);// UNLOCK TABLE


  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

  rs2.destroy;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070001,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
























//=============================================================================
procedure jasapi_register(p_Context: TCONTEXT);
//=============================================================================
var
  xmlnode: JFC_XML;
  //xmlnode2: JFC_XML;
  saUsername: ansistring;
  saEmail: ansistring;
  saNewPassword1: ansistring;
  saNewPassword2: ansistring;
  saFirstname: ansistring;
  saLastname: ansistring;
  saCellphone: ansistring;
  saBirthday: ansistring;

  //u1Result: byte;

  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  bOk: Boolean; // Used different than normally used
  bBirthdayOk: boolean;
  // if not OK - processing continues so output has all errors

  rJPerson: rtJPerson;
  rJUser: rtJUser;
  saMsg: ansistring;
  DT: TDateTime;

  rJJobQ: rtJJObQ;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='jasapi_register(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102354,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102356, sTHIS_ROUTINE_NAME);{$ENDIF}


  //ASPRintln('register xml - begin');

  if garJVHost[p_Context.u2VHost].VHost_AllowRegistration_b then
  begin
    //ASPrintln('xml - registration enabled');
    //u1Result:=cnRegister_MeansErrorOccurred;
    saMsg:='An error has occurred.';
    DBC:=p_Context.VHDBC;
    rs:=JADO_RECORDSET.Create;
    with p_Context do begin
      //rs:=JADO_RECORDSET.Create;
      XML.AppendItem_saName_n_saValue('register','');
      xmlnode:=JFC_XML.Create;
      XML.Item_lpPtr:=xmlnode;
      bOk:=true;

      // username ---------------------------------------------------------------
      saUsername:=         trim(CGIENV.DataIn.Get_saValue('username'));
      if bOk then
      begin
        bOk:=bGoodUsername(saUsername);
        if not bOk then
        begin
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidUsername));
        end;
      end;
      // username----------------------------------------------------------------

      // Email ------------------------------------------------------------------
      saEmail:=         trim(CGIENV.DataIn.Get_saValue('email'));
      if bOk then
      begin
        bOk:=(length(saEmail)<=128) and bGoodEmail(saEmail);
        if not bOk then
        begin
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidEmail));
        end;
      end;
      // Email ------------------------------------------------------------------

      // Email Exists -----------------------------------------------------------
      if bOk then
      begin
        bOk:=(DBC.u8GetRecordCount('jperson','((JPers_Home_Email='+DBC.saDBMSScrub(saEmail) +
            ') or (JPers_Work_Email='+DBC.saDBMSScrub(saEmail) + ')) AND '+
            '((JPers_Deleted_b<>true) or (JPers_Deleted_b IS NULL))',201506171753)=0);
        if not bOk then
        begin
          bOk:=false;
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_EmailExists ));
        end;
      end;
      // Email Exists -----------------------------------------------------------

      // NewPassword1 -----------------------------------------------------------
      saNewPassword1:=  CGIENV.DataIn.Get_saValue('newpassword1');
      if bOk then
      begin
        bOk:=bGoodPassword(saNewPassword1);
        if not bOk then
        begin
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidPassword));
        end;
      end;
      // NewPassword1 -----------------------------------------------------------

      // NewPassword2 -----------------------------------------------------------
      saNewPassword2:=CGIENV.DataIn.Get_saValue('newpassword1');
      if bOk then
      begin
        bOk:=bGoodPassword(saNewPassword2);
        if not bOk then
        begin
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidPassword));
        end;
      end;
      // NewPassword2 -----------------------------------------------------------

      // Compare Passwords ------------------------------------------------------
      if (saNewPassword1<>saNewPassword2) then
      begin
        bOk:=false;
        xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_PasswordsDoNotMatch));
      end;
      // Compare Passwords ------------------------------------------------------

      // Firstname --------------------------------------------------------------
      saFirstname:=     CGIENV.DataIn.Get_saValue('Firstname');
      if (length(saFirstname)>50) or (saFirstname='') then
      begin
        bOk:=false;
        xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidFirstname));
      end;
      // Firstname --------------------------------------------------------------

      // Lastname ---------------------------------------------------------------
      saLastname:=     CGIENV.DataIn.Get_saValue('Lastname');
      if (length(saLastname)>50) or (saLastname='') then
      begin
        bOk:=false;
        xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidLastname));
      end;
      // Lastname ---------------------------------------------------------------


      // Name Exists ------------------------------------------------------------
      saQry:='UCASE(TRIM(JPers_NameFirst))='+DBC.saDBMSScrub(Upcase(saFirstname)) + ' and ' +
        'UCASE(TRIM(JPers_NameLast))='+DBC.saDBMSScrub(Upcase(saLastname)) + ' AND ' +
        '((JPers_Deleted_b=false) or (JPers_Deleted_b IS NULL))';
      if DBC.u8GetRecordCount('jperson',saQry,201506171754) >0 then
      begin
        bOk:=false;
        xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_NameExists));
      end;
      // Name Exists ------------------------------------------------------------


      // Cellphone --------------------------------------------------------------
      if garJVHost[p_Context.u2VHost].VHost_RegisterReqCellPhone_b then
      begin
        saCellphone:=     CGIENV.DataIn.Get_saValue('Cellphone');
        if (length(saCellphone)>32) or (saCellphone='') then
        begin
          bOk:=false;
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidCellPhone));
        end;
        // Cellphone --------------------------------------------------------------

        // Cell Phone Exists ------------------------------------------------------
        if DBC.u8GetRecordCount('jperson',
          'JPers_Mobile_Phone='+DBC.saDBMSScrub(saCellPhone)+' and '+
          'JPers_Deleted_b<>true',201506171755)>0 then
        begin
          bOk:=false;
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_CellPhoneExists));
        end;
      end;
      // Cell Phone Exists ------------------------------------------------------




      // Birthday ---------------------------------------------------------------
      if garJVHost[p_Context.u2VHost].VHost_RegisterReqBirthday_b then
      begin
        bBirthdayOk:=true;
        saBirthday:=      CGIENV.DataIn.Get_saValue('Birthday');
        try
          dt:=StrToDateTime(JDATE(saBirthday,1,3));
          except on E : EConvertError do bBirthdayOk:=false;
        end;

        if bBirthdayOk then
        begin
          saBirthday:=FormatDateTime('YYYY-MM-DD',dt);
        end
        else
        begin
          bOk:=false;
          xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_InvalidBirthday));
        end;
      end;
      // Birthday ---------------------------------------------------------------

    end;//with

    if bOk then
    begin
      //=============================================================================
      // Add Person
      //=============================================================================
      clear_JPerson(rJPerson);
      with rJPerson do begin
        //JPers_JPerson_UID                 : ansistring;
        //JPers_Desc                        : ansistring;
        //JPers_NameSalutation              : ansistring;
        JPers_NameFirst                   :=saFirstName;
        //JPers_NameMiddle                  : ansistring;
        JPers_NameLast                    :=saLastName;
        //JPers_NameSuffix                  : ansistring;
        //JPers_NameDear                    : ansistring;
        //JPers_Gender                      : ansistring;
        JPers_Private_b                   :=false;
        //JPers_Addr1                       : ansistring;
        //JPers_Addr2                       : ansistring;
        //JPers_Addr3                       : ansistring;
        //JPers_City                        : ansistring;
        //JPers_State                       : ansistring;
        //JPers_PostalCode                  : ansistring;
        //JPers_Country                     : ansistring;
        //JPers_Home_Email                  : ansistring
        //JPers_Home_Phone                  : ansistring;
        //JPers_Latitude_d                  : ansistring;
        //JPers_Longitude_d                 : ansistring;
        if garJVHost[p_Context.u2VHost].VHost_RegisterReqCellPhone_b then
        begin
          JPers_Mobile_Phone                :=saCellPhone;
        end;
        JPers_Work_Email                  :=saEmail;
        //JPers_Work_Phone                  : ansistring;
        //JPers_Primary_Org_ID          : ansistring;
        JPers_Customer_b                  :=false;
        //JPers_Vendor_b                    : ansistring;
        if garJVHost[p_Context.u2VHost].VHost_RegisterReqBirthday_b then
        begin
          JPers_DOB_DT                      :=saBirthDay;
        end;
        //JPers_CreatedBy_JUser_ID          : ansistring;
        //JPers_Created_DT                  : ansistring;
        //JPers_ModifiedBy_JUser_ID         : ansistring;
        //JPers_Modified_DT                 : ansistring;
        //JPers_DeletedBy_JUser_ID          : ansistring;
        //JPers_Deleted_DT                  : ansistring;
        //JPers_Deleted_b                   : ansistring;
        JAS_Row_b                         :=false;
      end;//with
      bOk:=bJAS_Save_JPerson(p_Context, DBC, rJPerson, false, false,201608310137);
      if not bOk then
      begin
        saMsg:=p_Context.saErrMsg + ' Additional Info: bJAS_Save_JPerson(p_Context, DBC, rJPerson, false, false) failed specifically.';
        JAS_Log(p_Context,cnLog_Error,201208180242,saMsg,'',SOURCEFILE,DBC);
      end;
      //=============================================================================
    end;

    if bOk then
    begin
      //=============================================================================
      // Add JUser
      //=============================================================================
      clear_JUser(rJUser);
      with rJUser do begin
        //JUser_JUser_UID              : ansistring;
        JUser_Name                   :=saUsername;
        JUser_Password               :=saxorstring(trim(saNewPassword1),garJVHost[p_Context.u2VHost].VHost_passwordkey_u1);
        JUser_JPerson_ID             :=rJPerson.JPers_JPerson_UID;
        JUser_Enabled_b              :=false;
        JUser_Admin_b                :=false;
        //JUser_Login_First_DT         : ansistring;
        //JUser_Login_Last_DT          : ansistring;
        //JUser_Logins_Successful_u    : ansistring;
        //JUser_Logins_Failed_u        : ansistring;
        //JUser_Password_Changed_DT    : ansistring;
        JUser_AllowedSessions_u      :=1;
        JUser_DefaultPage_Login      :='newuser';
        //JUser_DefaultPage_Logout     : ansistring;
        JUser_JLanguage_ID           :=cnLang_English;
        JUser_Audit_b                :=false;
        //JUser_CreatedBy_JUser_ID     : ansistring;
        //JUser_Created_DT             : ansistring;
        //JUser_ModifiedBy_JUser_ID    : ansistring;
        //JUser_Modified_DT            : ansistring;
        //JUser_DeletedBy_JUser_ID     : ansistring;
        //JUser_Deleted_DT             : ansistring;
        //JUser_Deleted_b              : ansistring;
        JAS_Row_b                    :=false;
      end;//with
      bOk:=bJAS_Save_JUser(p_Context, DBC, rJUser, false, false,201608310138);
      if not bOk then
      begin
        saMsg:=p_Context.saErrMsg;
        JAS_Log(p_Context,cnLog_Error,201208180243,saMsg,'',SOURCEFILE,DBC);
        saQry:='DELETE FROM jperson WHERE JPers_JPerson_UID='+DBC.sDBMSUIntScrub(rJPerson.JPers_JPerson_UID);
        if not rs.open(saQry,DBC,201503161413) then
        begin
          JAS_Log(p_Context,cnLog_Error,201209271815,'Unable to delete jperson record when juser save failed.','',SOURCEFILE,DBC,rs);
        end;
        rs.close;
      end;
      //=============================================================================
    end;

    if bOk then
    begin
      //=============================================================================
      // Send Email for EMail confirmation and enabling the user's account
      //=============================================================================
      dt:=now;
      clear_JJobQ(rJJobQ);
      with rJJobQ do begin
        //JJobQ_JJobQ_UID           :=
        JJobQ_JUser_ID            :=1;
        JJobQ_JJobType_ID         :=1;//General
        JJobQ_Start_DT            :=FormatDateTime(csDATETIMEFORMAT,DT);
        JJobQ_ErrorNo_u           :=0;
        JJobQ_Started_DT          :='NULL';
        JJobQ_Running_b           :=false;
        JJobQ_Finished_DT         :='NULL';
        JJobQ_Name                :='Email - Validate User';
        JJobQ_Repeat_b            :=false;
        JJobQ_RepeatMinute        :='10/*';
        JJobQ_RepeatHour          :='*';
        JJobQ_RepeatDayOfMonth    :='*';
        JJobQ_RepeatMonth         :='*';
        JJobQ_Completed_b         :=false;
        JJobQ_Result_URL          :='';
        JJobQ_ErrorMsg            :='';
        JJobQ_ErrorMoreInfo       :='';
        JJobQ_Enabled_b           :=true;
        JJobQ_Job                 :=
          '<CONTEXT>'+
          '  <saRequestMethod>GET</saRequestMethod>'+
          '  <saQueryString>jasapi=email&type=validateuser&UID='+
            inttostR(rJUser.JUser_JUser_UID)+'</saQueryString>'+
          '  <saRequestedFile>.</saRequestedFile>'+
          '</CONTEXT>';
        JJobQ_Result              :='NULL';
        //JJobQ_CreatedBy_JUser_ID  :=
        //JJobQ_Created_DT          :=
        //JJobQ_ModifiedBy_JUser_ID :=
        //JJobQ_Modified_DT         :=
        //JJobQ_DeletedBy_JUser_ID  :=
        //JJobQ_Deleted_DT          :=
        //JJobQ_Deleted_b           :=
        JAS_Row_b                 :=false;
        //JJobQ_JTask_ID            :=
      end;//with
      bOk:=bJAS_Save_JJobQ(p_Context, DBC, rJJobQ, false,false,201608310139);
      if not bOk then
      begin
        saMsg:='Unable to SAVE the new user registration reminder email record into the Job Queue.';
        JAS_Log(p_Context,cnLog_Error,201208181621,saMsg,'',SOURCEFILE);

        saQry:='DELETE FROM jperson WHERE JPers_JPerson_UID='+DBC.sDBMSUIntScrub(rJPerson.JPers_JPerson_UID);
        if not rs.open(saQry,DBC,201503161414) then
        begin
          JAS_Log(p_Context,cnLog_Error,201209271816,'Unable to delete jperson record when jjobq save failed.','',SOURCEFILE,DBC,rs);
        end;
        rs.close;

        saQry:='DELETE FROM juser WHERE JUser_JUser_UID='+DBC.sDBMSUIntScrub(rJUser.JUser_JUser_UID);
        if not rs.open(saQry,DBC,201503161415) then
        begin
          JAS_Log(p_Context,cnLog_Error,201209271817,'Unable to delete juser record when jjobq save failed.','',SOURCEFILE,DBC,rs);
        end;
        rs.close;
      end;
      //=============================================================================
    end;
    //if bOk then JFC_XMLITEM(xmlnode.lpItem).AttrXDL.AppendItem_saName_N_saValue('code',inttostr(cnRegister_Success));
    if bOk then xmlnode.AppendItem_saName_N_saValue('result',inttostr(cnRegister_Success));
    rs.destroy;
  end
  else
  begin
    //ASPrintln('xml registration disabled');
    bOk:=false;
    saMSG:='User Registration is Disabled';
    JAS_LOG(p_COntext, cnLog_Error,201211280855,saMsg,'',SOURCEFILE);
  end;
  
  if not bOk then
  begin
    //ASPrintln('xml registration not enabled - should send msg to user)');
    xmlnode.AppendItem_saName_N_saValue('result',saMsg);
  end;

  //JAS_Log(p_Context, cnLog_Debug, 201208181623,'userapi_register JUser Locked: '+
  //  sTrueFalse(bJAS_RecordLockValid(p_Context,JAS.ID, 'juser',rJUser.JUser_JUser_UID,'0')
  //),'',SOURCEFILE);
  //SPRintln('register xml - done');

  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201208181622,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================























//=============================================================================
{}
// URI Parameters:
// JScrn_JScreen_UID = (SOURCE SCREEN) JScreen Record ID of Screen You Wish to copy.
//
// DestScreenName = (DESTINATION [new] NAME)
//
// This function might not belong in this unit - as it does it's task and
// returns an XML document - however because it is so integral to the
// User Interface - it's here.
//
// TODO: Move this to the JASAPI side of things and make it work using the
//       extensible xml mechanisms. e.g. i01j_api_xml.pp
procedure JASAPI_CopyScreen(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;

  Src_rJScreen: rtJScreen;
  Dest_rJScreen: rtJScreen;

  Src_rJBlok: rtJBlok;
  Dest_rJBlok: rtJBlok;

  Src_rJBlokField: rtJBlokField;
  Dest_rJBlokField: rtJBlokField;

  Src_rJBlokButton: rtJBlokButton;
  Dest_rJBlokButton: rtJBlokButton;

  iBlokCount: longint;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JAS_JScreenCopy(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102639,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102640, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_LOG(p_Context,cnLog_Error,201009121618,'Screen Copy - Invalid Session. You are not logged in.','',SOURCEFILE);
  End;
  If bOk Then
  Begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_CopyScreen);
    If not bOk Then
    Begin
      JAS_LOG(p_Context,cnLog_Error,201009121618,'Screen Copy - You are not authorized to perform this action',
        'Missing Admin Permission. JUser_JUser_UID:' + inttostr(p_Context.rJUser.JUser_JUser_UID),SOURCEFILE);
    End;
  End;
  clear_jscreen(Src_rJScreen);
  clear_jscreen(Dest_rJScreen);
  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('DestScreenName');
    if bOk then
    begin
      Dest_rJScreen.JScrn_Name:=p_Context.CGIENV.DataIn.Item_saValue;
    end
    else
    begin
      JAS_LOG(p_Context,cnLog_Error,201009141803,'Missing Destination Screen Name Parameter.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('JScrn_JScreen_UID');
    if bOk then
    begin
      Src_rJScreen.JScrn_JScreen_UID:=u8Val(p_Context.CGIENV.DataIn.Item_saValue);
    end
    else
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121620,'Screen Copy - Missing the Source Screen ID parameter to copy; it wasn''t passed.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_Load_JScreen(p_Context, DBC, Src_rJScreen, false,201608310140);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121621,'Screen Copy - Trouble loading original screen record.',
        'bJAS_Load_JScreen - Src_rJScreen.JScrn_JScreen_UID: '+inttostr(Src_rJScreen.JScrn_JScreen_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saQry:='select count(*) as MyCount from jscreen where '+
      '(UPPER(JScrn_Name)='+DBC.saDBMSScrub(upcase(Dest_rJScreen.JScrn_Name))+') and '+
      '((JScrn_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JScrn_Deleted_b IS NULL))';
    bOk:=rs.Open(saQry,DBC,201503161416);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121622,'Screen Copy - Query trouble getting a record count of screens with desired name of new copy.',
        'Query: '+saQry,SOURCEFILE);
    end;

    if bOk then
    begin
      bOk:= iVal(rs.fields.get_savalue('MyCount'))=0;
      if not bOk then
      begin
        JAS_LOG(p_Context,cnLog_Error,201009121623,'Screen Copy - Screen named '+Dest_rJScreen.JScrn_Name+
          ' already exists. Duplicates are not allowed.','Query: '+saQry,SOURCEFILE);
      end;
    end;
    rs.close;
  end;


  if bOk then
  begin
    Dest_rJScreen.JScrn_JScreen_UID              :=0;
    //Dest_rJScreen.JScrn_Name                   :=Src_rJScreen.
    Dest_rJScreen.JScrn_JScreenType_ID           :=Src_rJScreen.JScrn_JScreenType_ID;
    Dest_rJScreen.JScrn_Template                 :=Src_rJScreen.JScrn_Template;
    Dest_rJScreen.JScrn_ValidSessionOnly_b       :=Src_rJScreen.JScrn_ValidSessionOnly_b;
    Dest_rJScreen.JScrn_Detail_JScreen_ID        :=0;
    Dest_rJScreen.JScrn_Desc                     :=Src_rJScreen.JScrn_Desc;
    Dest_rJScreen.JScrn_JSecPerm_ID              :=Src_rJScreen.JScrn_JSecPerm_ID;
    Dest_rJScreen.JScrn_JCaption_ID              :=Src_rJScreen.JScrn_JCaption_ID;
    //Dest_rJScreen.JScrn_CreatedBy_JUser_ID       :=Src_rJScreen.
    //Dest_rJScreen.JScrn_Created_DT               :=Src_rJScreen.
    //Dest_rJScreen.JScrn_ModifiedBy_JUser_ID      :=Src_rJScreen.
    //Dest_rJScreen.JScrn_Modified_DT              :=Src_rJScreen.
    //Dest_rJScreen.JScrn_DeletedBy_JUser_ID       :=Src_rJScreen.
    //Dest_rJScreen.JScrn_Deleted_DT               :=Src_rJScreen.
    //Dest_rJScreen.JScrn_Deleted_b                :=Src_rJScreen.
    Dest_rJScreen.JScrn_IconSmall                :=Src_rJScreen.JScrn_IconSmall;
    Dest_rJScreen.JScrn_IconLarge                :=Src_rJScreen.JScrn_IconLarge;
    Dest_rJScreen.JAS_Row_b                      :=false;
    Dest_rJScreen.JScrn_TemplateMini             :=Src_rJScreen.JScrn_TemplateMini;
    bOk:=bJAS_Save_JScreen(p_Context, DBC, Dest_rJScreen, false,false,201608310141);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121624,'Screen Copy - Unable to save new screen record.','bJAS_Save_JScreen save new failed.',SOURCEFILE);
    end;
  end;


  if bok then
  begin
    saQry:='select JBlok_JBlok_UID, JBlok_JScreen_ID from jblok where JBlok_JScreen_ID='+
      inttostr(Src_rJScreen.JScrn_JScreen_UID)+' and '+
      '((JBlok_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JBlok_Deleted_b IS NULL))';
    bOk:=rs.open(saQry, DBC,201503161417);
    if not bok then
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121757,'Screen Copy - Query trouble loading screen sections. (JBloks)','Query:'+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.eol = FALSE;
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201009121803,'Screen Copy - There are missing required records missing from the database.','Query: '+ saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JASPrintln(saQry);
    repeat
      //ASPrintln('JAS_JScreenCopy - copy: '+inttostr(Src_rJScreen.JScrn_JScreen_UID)+
      //  ' DBScreen: '+rs.fields.get_saValue('JBlok_JScreen_ID')+' JBlok: '+ rs.fields.get_saValue('JBlok_JBlok_UID'));
      clear_jblok(Src_rJBlok);
      clear_jblok(Dest_rJBlok);
      if bOk then
      begin
        Src_rJBlok.JBlok_JBlok_UID:=u8Val(rs.fields.get_saValue('JBlok_JBlok_UID'));
        bOk:=bJAS_Load_JBlok(p_Context, DBC, Src_rJBlok, false, 201608310143);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Error,201009121759,'Screen Copy - Trouble loading screen section (JBlok).',
            'bJAS_Load_JBlok for Src_rJBlok.JBlok_JBlok_UID: '+inttostr(Src_rJBlok.JBlok_JBlok_UID),SOURCEFILE);
        end;
      end;

//   function saGetValue(p_sTable: string; p_sField: string; p_saWhereClauseOrBlank: ansistring; p_u8Caller: UInt64):ansistring;



      if bOk then
      begin
        Dest_rJBlok.JBlok_JBlok_UID            :=0;
        Dest_rJBlok.JBlok_JTable_ID            :=Src_rJBlok.JBlok_JTable_ID;
        Dest_rJBlok.JBlok_Name                 :=Dest_rJScreen.JScrn_Name+' '+
          DBC.saGetValue('jbloktype','JBkTy_Name','JBkTy_JBlokType_UID='+DBC.sDBMSUIntScrub(Src_rJBlok.JBlok_JBlokType_ID)+' AND '+
            '((JBkTy_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JBkTy_Deleted_b IS NULL))',201608230007);
        iBlokCount:=DBC.u8GetRecordCount('jblok','((JBlok_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JBlok_Deleted_b IS NULL)) AND '+
                      '(JBlok_JScreen_ID='+DBC.sDBMSUIntScrub(Dest_rJScreen.JScrn_JScreen_UID)+')',201506171756);
        if iBlokCount>1 then Dest_rJBlok.JBlok_Name+=inttostr(iBlokCount);
        Dest_rJBlok.JBlok_Columns_u            :=Src_rJBlok.JBlok_Columns_u;
        Dest_rJBlok.JBlok_JBlokType_ID         :=Src_rJBlok.JBlok_JBlokType_ID;
        Dest_rJBlok.JBlok_Custom               :=Src_rJBlok.JBlok_Custom;
        Dest_rJBlok.JBlok_JCaption_ID          :=Src_rJBlok.JBlok_JCaption_ID;
        //Dest_rJBlok.JBlok_CreatedBy_JUser_ID   :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_Created_DT           :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_ModifiedBy_JUser_ID  :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_Modified_DT          :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_DeletedBy_JUser_ID   :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_Deleted_DT           :=Src_rJBlok.;
        //Dest_rJBlok.JBlok_Deleted_b            :=Src_rJBlok.;
        Dest_rJBlok.JBlok_IconSmall            :=Src_rJBlok.JBlok_IconSmall;
        Dest_rJBlok.JBlok_IconLarge            :=Src_rJBlok.JBlok_IconLarge;
        Dest_rJBlok.JAS_Row_b                  :=false;
        Dest_rJBlok.JBlok_Position_u           :=Src_rJBlok.JBlok_Position_u;
        Dest_rJBlok.JBlok_JScreen_ID           :=Dest_rJScreen.JScrn_JScreen_UID;
        bOk:=bJAS_Save_JBlok(p_Context, DBC, Dest_rJBlok, false,false, 201608310144);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Error,201009121800,'Screen Copy - Trouble saving a new screen section (JBlok).','bJAS_Save_JBlok failed',SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        saQry:='select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID='+inttostr(Src_rJBlok.JBlok_JBlok_UID)+' '+
          'AND ((JBlkF_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JBlkF_Deleted_b IS NULL))';
        bOk:=rs2.open(saQry, DBC,201503161418);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Error,201009121802,'Screen Copy - Trouble reading screen fields (JBlokfields)','Query: '+ saQry,SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        bOk:=rs2.eol = FALSE;
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Error,201009121904,'Screen Copy - There are required records missing from the database.',
            'Query: '+ saQry,SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        JASPrintln('JAS_JScreenCopy - copy jblokfield records');
        repeat
          clear_jblokfield(Src_rJBlokField);
          clear_jblokfield(Dest_rJBlokField);
          Src_rJBlokField.JBlkF_JBlokField_UID:=u8Val(rs2.fields.get_saValue('JBlkF_JBlokField_UID'));
          bOk :=bJAS_Load_JBlokField(p_Context, DBC, Src_rJBlokField,false, 201608310145);
          if not bOk then
          begin
            JAS_LOG(p_Context,cnLog_Error,201009121905,'Screen Copy - Trouble loading a screen field. (JBlokfield)',
              'bJAS_Load_JBlokField for Src_rJBlokField.JBlkF_JBlokField_UID: '+ inttostr(Src_rJBlokField.JBlkF_JBlokField_UID),SOURCEFILE);
          end;

          if bOk then
          begin
            Dest_rJBlokField.JBlkF_JBlokField_UID         :=0;
            Dest_rJBlokField.JBlkF_JBlok_ID               :=Dest_rJBlok.JBlok_JBlok_UID;
            Dest_rJBlokField.JBlkF_JColumn_ID             :=Src_rJBlokField.JBlkF_JColumn_ID;
            Dest_rJBlokField.JBlkF_Position_u             :=Src_rJBlokField.JBlkF_Position_u;
            Dest_rJBlokField.JBlkF_ReadOnly_b             :=Src_rJBlokField.JBlkF_ReadOnly_b;
            Dest_rJBlokField.JBlkF_JWidget_ID             :=Src_rJBlokField.JBlkF_JWidget_ID;
            Dest_rJBlokField.JBlkF_Widget_MaxLength_u     :=Src_rJBlokField.JBlkF_Widget_MaxLength_u;
            Dest_rJBlokField.JBlkF_Widget_Width           :=Src_rJBlokField.JBlkF_Widget_Width;
            Dest_rJBlokField.JBlkF_Widget_Height          :=Src_rJBlokField.JBlkF_Widget_Height;
            Dest_rJBlokField.JBlkF_Widget_Password_b      :=Src_rJBlokField.JBlkF_Widget_Password_b;
            Dest_rJBlokField.JBlkF_Widget_Date_b          :=Src_rJBlokField.JBlkF_Widget_Date_b;
            Dest_rJBlokField.JBlkF_Widget_Time_b          :=Src_rJBlokField.JBlkF_Widget_Time_b;
            Dest_rJBlokField.JBlkF_Widget_Mask            :=Src_rJBlokField.JBlkF_Widget_Mask;
            Dest_rJBlokField.JBlkF_ColSpan_u              :=Src_rJBlokField.JBlkF_ColSpan_u;
            Dest_rJBlokField.JBlkF_ClickAction_ID         :=Src_rJBlokField.JBlkF_ClickAction_ID;
            Dest_rJBlokField.JBlkF_ClickActionData        :=Src_rJBlokField.JBlkF_ClickActionData;
            Dest_rJBlokField.JBlkF_JCaption_ID            :=Src_rJBlokField.JBlkF_JCaption_ID;
            //Dest_rJBlokField.JBlkF_CreatedBy_JUser_ID     :=Src_rJBlokField.JBlkF_CreatedBy_JUser_ID;
            //Dest_rJBlokField.JBlkF_Created_DT             :=Src_rJBlokField.JBlkF_Created_DT;
            //Dest_rJBlokField.JBlkF_ModifiedBy_JUser_ID    :=Src_rJBlokField.JBlkF_ModifiedBy_JUser_ID;
            //Dest_rJBlokField.JBlkF_Modified_DT            :=Src_rJBlokField.JBlkF_Modified_DT;
            //Dest_rJBlokField.JBlkF_DeletedBy_JUser_ID     :=Src_rJBlokField.JBlkF_DeletedBy_JUser_ID;
            //Dest_rJBlokField.JBlkF_Deleted_DT             :=Src_rJBlokField.JBlkF_Deleted_DT;
            //Dest_rJBlokField.JBlkF_Deleted_b              :=Src_rJBlokField.JBlkF_Deleted_b;
            Dest_rJBlokField.JBlkF_Width_is_Percent_b     :=Src_rJBlokField.JBlkF_Width_is_Percent_b;
            Dest_rJBlokField.JBlkF_Height_is_Percent_b    :=Src_rJBlokField.JBlkF_Height_is_Percent_b;
            Dest_rJBlokField.JAS_Row_b                    :=false;
            Dest_rJBlokField.JBlkF_Required_b             :=Src_rJBlokField.JBlkF_Required_b;
            Dest_rJBlokField.JBlkF_MultiSelect_b          :=Src_rJBlokField.JBlkF_MultiSelect_b;
            Dest_rJBlokField.JBlkF_Widget_OnBlur          :=Src_rJBlokField.JBlkF_Widget_OnBlur;
            Dest_rJBlokField.JBlkF_Widget_OnChange        :=Src_rJBlokField.JBlkF_Widget_OnChange;
            Dest_rJBlokField.JBlkF_Widget_OnClick         :=Src_rJBlokField.JBlkF_Widget_OnClick;
            Dest_rJBlokField.JBlkF_Widget_OnDblClick      :=Src_rJBlokField.JBlkF_Widget_OnDblClick;
            Dest_rJBlokField.JBlkF_Widget_OnFocus         :=Src_rJBlokField.JBlkF_Widget_OnFocus;
            Dest_rJBlokField.JBlkF_Widget_OnKeyDown       :=Src_rJBlokField.JBlkF_Widget_OnKeyDown;
            Dest_rJBlokField.JBlkF_Widget_OnKeyUp         :=Src_rJBlokField.JBlkF_Widget_OnKeyUp;
            Dest_rJBlokField.JBlkF_Widget_OnSelect        :=Src_rJBlokField.JBlkF_Widget_OnSelect;
            Dest_rJBlokField.JBlkF_Widget_OnKeypress      :=Src_rJBlokField.JBlkF_Widget_OnKeypress;
            Dest_rJBlokField.JBlkF_Visible_b              :=Src_rJBlokField.JBlkF_Visible_b;

            bOk:=bJAS_Save_JBlokField(p_Context, DBC, Dest_rJBlokField, falsE,false, 201608310146);
            if not bOk then
            begin
              JAS_LOG(p_Context,cnLog_Error,201009121804,'Screen Copy - trouble saving a screen field. (JBlokField)',
                'bJAS_Save_JBlokField addnew failed.',SOURCEFILE);
            end;
          end;
          
        until (not bOk) or (not rs2.movenext);
      end;
      rs2.close;





      if bOk then
      begin
        saQry:='select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID='+inttostr(Src_rJBlok.JBlok_JBlok_UID) +' '+
          'AND ((JBlkB_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JBlkB_Deleted_b IS NULL))';
        bOk:=rs2.open(saQry, DBC,201503161419);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Error,201009121805,'Screen Copy - Query trouble loading buttons.','Query: '+ saQry,SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        if rs2.eol=false then // Grids don't have buttons and technically aren't required.
        begin
          repeat
            clear_jblokbutton(Src_rJBlokButton);
            clear_jblokbutton(Dest_rJBlokButton);
            Src_rJBlokButton.JBlkB_JBlokButton_UID:=u8Val(rs2.fields.get_saValue('JBlkB_JBlokButton_UID'));
            bOk :=bJAS_Load_JBlokButton(p_Context, DBC, Src_rJBlokButton,false, 201608310147);
            if not bOk then
            begin
              JAS_LOG(p_Context,cnLog_Error,201009121807,'Screen Copy - Trouble loading a button.',
                'bJAS_Load_JBlokButton - for Src_rJBlokButton.JBlkF_JBlokButton_UID: '+ inttostr(Src_rJBlokButton.JBlkB_JBlokButton_UID),SOURCEFILE);
            end;

            if bOk then
            begin

              Dest_rJBlokButton.JBlkB_JBlokButton_UID     :=0;
              Dest_rJBlokButton.JBlkB_JBlok_ID            :=Dest_rJBlok.JBlok_JBlok_UID;
              Dest_rJBlokButton.JBlkB_JCaption_ID         :=Src_rJBlokButton.JBlkB_JCaption_ID;
              Dest_rJBlokButton.JBlkB_Name                :=Src_rJBlokButton.JBlkB_Name;
              Dest_rJBlokButton.JBlkB_GraphicFileName     :=Src_rJBlokButton.JBlkB_GraphicFileName;
              Dest_rJBlokButton.JBlkB_Position_u          :=Src_rJBlokButton.JBlkB_Position_u;
              Dest_rJBlokButton.JBlkB_JButtonType_ID      :=Src_rJBlokButton.JBlkB_JButtonType_ID;
              Dest_rJBlokButton.JBlkB_CustomURL           :=Src_rJBlokButton.JBlkB_CustomURL;
              //Dest_rJBlokButton.JBlkB_CreatedBy_JUser_ID  :=Src_rJBlokButton.JBlkB_CreatedBy_JUser_ID;
              //Dest_rJBlokButton.JBlkB_Created_DT          :=Src_rJBlokButton.JBlkB_Created_DT;
              //Dest_rJBlokButton.JBlkB_ModifiedBy_JUser_ID :=Src_rJBlokButton.JBlkB_ModifiedBy_JUser_ID;
              //Dest_rJBlokButton.JBlkB_Modified_DT         :=Src_rJBlokButton.JBlkB_Modified_DT;
              //Dest_rJBlokButton.JBlkB_DeletedBy_JUser_ID  :=Src_rJBlokButton.JBlkB_DeletedBy_JUser_ID;
              //Dest_rJBlokButton.JBlkB_Deleted_DT          :=Src_rJBlokButton.JBlkB_Deleted_DT;
              //Dest_rJBlokButton.JBlkB_Deleted_b           :=Src_rJBlokButton.JBlkB_Deleted_b;
              Dest_rJBlokButton.JAS_Row_b                 :=false;

              bOk:=bJAS_Save_JBlokbutton(p_Context, DBC, Dest_rJBlokbutton, false,false, 201608310148);
              if not bOk then
              begin
                JAS_LOG(p_Context,cnLog_Error,201009121808,'Screen Copy - Trouble saving a button.','',SOURCEFILE);
              end;
            end;

          until (not bOk) or (not rs2.moveNext);
        end;
      end;
      rs2.close;
    until (not bok) or (not rs.movenext);
  end;

  if bOk then
  begin
    p_Context.xml.AppendItem_saName_N_saValue('result','Success');
  end
  else
  begin
    p_Context.xml.AppendItem_saName_N_saValue('result','Error');
  end;

  p_context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  rs.destroy;
  rs2.destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102641,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
// pas parameter: NAME in URL for the name of the user,password and database.
// Note the permissions only allow access from localhost - this is why password
// scheme works.

// Makes new user, password and database and makes a JAS connection
// for it using same info. This routin passes back the JDConnection UID
// when successful or a ZERO if it failed. Note the connection IS NOT ENABLED
// so the next step to make the database etc would be to load the info
// into an instance of JDCON, Doo all you have to do then SAVE the connection
// as ENABLED and send the Cycle command into the JobQueue of the Squadron
// Leader databse.
procedure JASAPI_NewConAndDB(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saName: ansistring;
  JDCon_JDConnection_UID: UInt64;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_NewConAndDB(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210291311,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210291312, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201210291313, 'Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=p_Context.rJUser.JUser_Admin_b and (p_Context.u2VHost=0);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210291314, 'Access Denied','User Admin: '+
        sTrueFalse(p_Context.rJUser.JUser_Admin_b)+' VHost ServerDomain: '+garJVHost[p_Context.u2VHost].VHost_ServerDomain,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saName:=p_Context.CGIENV.DataIn.Get_saValue('name');
    bOk:=bGoodUserName(saName);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210291318,'Invalid Name passed. Only Letters, Numbers, Underscores '+
        'and dashes allowed. Valid Length: 1 to 32 characters. Name Passed: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    JDCon_JDConnection_UID:=u8NewConAndDB(p_Context, saName);
    bOk:=JDCon_JDConnection_UID>0;
    //if not bOk then
    //begin
    //  JAS_LOG(p_Context, cnLog_Error, 201210291322,'New Connection and Database creation function failed.',
    //    'Result JDCon_JDConnection_UID: '+inttostr(JDCon_JDConnection_UID),SOURCEFILE);
    //end;
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  p_Context.XML.AppendItem_saName_N_saValue('JDCon_JDConnection_UID',inttostr(JDCon_JDConnection_UID));
  //p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070001,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


























//=============================================================================
{}
// Parameters:
// JDCon_JDConnection_UID: Database connection in source DB to use
// Name to use making a connection if JDCon_JDConnection_UID is ZERO on entry
// LeadJet: If True treat as Master Database, otherwise like a JET database.
//
// Makes New Master databases or Jet databases and also upgrades existing
// databases.
procedure JASAPI_DBMasterUtility(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  JDCon_JDConnection_UID: Uint64;
  saName: ansistring;
  bLeadJet: boolean;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_DBMasterUtility(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210291329,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210291330, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  DBC:=p_Context.VHDBC;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201210291331, 'Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_DBMasterUtility);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241631, 'You are authoized to perform this action.','',SOURCEFILE);
    end;
  end;


  //if bOk then
  //begin
  //  bOk:=p_Context.rJUser.JUser_Admin_b and (p_Context.uVHost=0);
  //  if not bOk then
  //  begin
  //    JAS_LOG(p_Context, cnLog_Error, 201210291332, 'Access Denied','User Admin: '+
  //      sTrueFalse(p_Context.rJUser.JUser_Admin_b)+' VHost ServerDomain: '+garJVHostLight[p_Context.i4VHost].saServerDomain,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    JDCon_JDConnection_UID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('JDCon_JDConnection_UID'));
    saName:=p_Context.CGIENV.DataIn.Get_saValue('name');//was servername
    bLeadJet:=bVal(p_Context.CGIENV.DataIn.Get_saValue('leadjet'));
    JASPrintln('========= going in to dbmasterutil');
    JASPrintln('bLeadJet:'+sYesNo(bLeadJet)+' saName:'+saName+' JDCon_JDConnection_UID: '+inttostr(JDCon_JDConnection_UID));
    JASPrintln('========= going in to dbmasterutil');

    bOk:=bDBMasterUtility(p_Context,DBC,JDCon_JDConnection_UID,saName,bLeadJet);

    JASPrintln('========= got out of dbmasterutil');
    JASPrintln('yay');
    JASPrintln('========= got out of dbmasterutil');
    //if not bOk then
    //begin
    //  JAS_LOG(p_Context, cnLog_Error, 201210291344,'Call to bDBMasterUtility failed. ConID: '+inttostR(JDCon_JDConnection_UID)+' '+
    //    ' Name: '+saName+' LeadJet: '+sTrueFalse(bLeadJet),'',SOURCEFILE);
    //end;
    //ASPrintln('========= coming out of the dbmasterutil');
    //ASPrintln('=========');
    //ASPrintln('Success? '+sYesNo(bOk));
    //ASPrintln('=========');
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  p_Context.XML.AppendItem_saName_N_saValue('JDCon_JDConnection_UID',inttostr(JDCon_JDConnection_UID));
  //p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070001,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





















//=============================================================================
{}
procedure JASAPI_SetDefaultSecuritySettings(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  //DBC: JADO_CONNECTION;
  //JDCon_JDConnection_UID: Uint64;
  //saName: ansistring;
  //bLeadJet: boolean;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetDefaultSecuritySettings(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211022231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211022232, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  //DBC:=p_Context.VHDBC;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201211022233, 'Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=p_Context.rJUser.JUser_Admin_b and (p_Context.u2VHost=0);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022234, 'Access Denied','User: '+p_Context.rJUser.JUser_Name+' User Admin: '+
        sTrueFalse(p_Context.rJUser.JUser_Admin_b)+' VHost ServerDomain: '+garJVHost[p_Context.u2VHost].VHost_ServerDomain,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=bSetDefaultSecuritySettings(p_Context);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210291344,'Call to bSetDefaultSecuritySettings failed. VHost: '+inttostr(p_Context.u2VHost),'',SOURCEFILE);
    end;
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  //p_Context.u2ErrorReportingMode:=cnSYS_INFO_MODE_SECURE;// Prevent debug info being appended

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211022235,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




















//=============================================================================
{}
// This is the JASAPI call that does the ENTIRE process of taking a JAS USER
// who DOES NOT have a JAS JET already and creates it start to finish and then
// emails the user with information to get in.
//
// This will be normally invoked from the JobQueue - as it takes awhile.
// Certain requirements need to be met for this process to work:
//
// Must have JAS Master Database User Account
// Account must have a JPerson record with a valid work email address.
//
// PARAMETERS
// name = name of alias, dir, domain
// servername = business name or title of CRM
// fromemail = used when system sends email.
// firstname, lastname, workemail
procedure JASAPI_CreateVirtualHost(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  saName: ansistring;
  saServerName: ansistring;
  saFromEmailAddress: ansistring;
  rJVHost: rtJVHost;
  rJAlias: rtJAlias;
  rJIndexFile1: rtJIndexFile;
  rJIndexFile2: rtJIndexFile;
  rJUser: rtJUser;
  rJPerson: rtJPerson;
  rJSecPerm: rtJSecPerm;
  saDestPath: ansistring;
  sawhere: ansistring;
  JDCon_JDConnection_UID: UInt64;
  //saSrc: ansistring;
  //saDest: ansistring;
  saLogDir: ansistring;
  rJDCon: rtJDConnection;
  TGT: JADO_CONNECTION;
  saDBCFilename: ansistring;
  rJSecGrpUserLink: rtJSecGrpUserLink;
  rJSecGrpLink: rtJSecGrpLink;
  bCGIBased: boolean;
  u2IOREsult: word;
  saCGIFileSrc: ansistring;
  saCGIFileDest: ansistring;
  saMsg: ansistring;
  //i: longint;
  sa:ansistring;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_SetDefaultSecuritySettings(p_Context: TCONTEXT);'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211061923,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211061924, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  DBC:=p_Context.VHDBC;
  TGT:=JADO_CONNECTION.Create;
  rs:=JADO_RECORDSET.Create;

  JASPrintln('201511240000 ------------------Create Virtual Host Started -------------------');
  JASPrintln('Current User: '+p_Context.rJUser.JUser_Name);

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201211061925, 'Invalid Session','',SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=p_Context.rJUser.JUser_Admin_b and (p_Context.u2VHost=0);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211082342, 'Access Denied','User: '+p_Context.rJUser.JUser_Name+' User Admin: '+
        sTrueFalse(p_Context.rJUser.JUser_Admin_b)+' VHost ServerDomain: '+garJVHost[p_Context.u2VHost].VHOST_ServerDomain,SOURCEFILE);
    end;
  end;
  

  if bOk then
  begin
    saName:=trim(saDecodeURI(lowercase(p_Context.CGIENV.DataIn.Get_saValue('name'))));
    saServerName:=trim(saDecodeURI(p_Context.CGIENV.DataIn.Get_saValue('servername')));

    if saName='' then saName:=p_Context.rJUser.JUser_Name;
    if saServerName='' then saServerName:=p_Context.rJUser.JUser_Name;

    //AS_LOG(p_Context, cnLog_Debug,201211241201,'ServerName from CGIENV: '+saServerName,'',SOURCEFILE);
    
    saFromEmailAddress:=saDecodeURI(p_Context.CGIENV.DataIn.Get_saValue('fromemail'));
 
    saWhere:='((VHost_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL)) AND '+
             '((VHost_ServerIdent='+UPCASE(DBC.saDBMSScrub(saName))+')OR('+
             'VHost_ServerDomain='+DBC.saDBMSScrub(saName)+'))';
    bOk:=DBC.u8GetRecordCount('jvhost',saWhere,201506171757)=0;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201211091352,'New JET Name exists in '+
        'Virtual Host Table. Name: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saWhere:='((Alias_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(Alias_Deleted_b IS NULL)) AND '+
      '(Alias_Alias='+DBC.saDBMSScrub(saName)+')';
    bOk:=DBC.u8GetRecordCount('jalias',saWhere,201506171758)=0;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201211091353,'New JET Name exists in Alias Table. Name: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saWhere:='((JDCon_Deleted_b='+DBC.sDBMSBoolScrub(false)+')OR(JDCon_Deleted_b IS NULL)) AND '+
      '(JDCon_Name='+DBC.saDBMSScrub(saName)+')';
    bOk:=DBC.u8GetRecordCount('jdconnection',saWhere,201506171759)=0;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201211091354,'New JET Name exists in Connection Table. Name: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saDestPath:=grJASCOnfig.saSysDir+'jets'+DOSSLASH+saName;
    bOk:=NOT fileexists(saDestPath);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211091359,'Jets Directory for Name '+saName+' already exists.',saDestPath,SOURCEFILE);
    end;
  end;

  //if bOk then
  //begin
  //  saQry:='UPDATE juser set JUser_JVHost_ID='+DBC.sDBMSUIntScrub(cnJUser_JVHost_Processing)+' WHERE JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
  //  bOk:=rs.open(saQry, DBC,201503161420);
  //  if not bOk then
  //  begin
  //    JAS_LOG(p_Context, cnLog_Error, 201211272241, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
  //  end;
  //  rs.close;
  //end;


  if bOk then
  begin
    JDCon_JDConnection_UID:=1;
    bOk:=bDBMasterUtility(p_Context,DBC,JDCon_JDConnection_UID,saName,false);
  end;
  




  //if bOk then
  //begin
  //  saSrc:=grJASConfig.saWebRootDir+'index.jas';
  //  saDest:=rJVHost.VHost_WebRootDir+'index.jas';
  //  bOk:=bCopyFile(saSrc,saDest);
  //  if not bOk then
  //  begin
  //    JAS_LOG(p_Context, cnLog_Error, 201211101148,'Unable to copy file Src: '+saSrc+' Dest: '+saDest,'',SOURCEFILE);
  //  end;
  //end;


  if bOk then
  begin
    clear_JDConnection(rJDCon);
    rJDCon.JDCon_JDConnection_UID:=JDCon_JDConnection_UID;
    bOk:=bJAS_Load_JDConnection(p_Context, DBC, rJDCon, true, 201608310149);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211110020, 'Trouble loading JDConnection record: '+inttostr(JDCon_JDConnection_UID),'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with TGT do begin
      ID:=                  rJDCon.JDCon_JDConnection_UID;
      JDCon_JSecPerm_ID:=   rJDCon.JDCon_JSecPerm_ID;
      sName:=               upcase(rJDCon.JDCon_Name);
      saDesc:=              rJDCon.JDCon_Desc;
      sDSN:=                rJDCon.JDCon_DSN;
      bFileBasedDSN:=       rJDCon.JDCon_DSN_FileBased_b;
      saDSNFileName:=       rJDCon.JDCon_DSN_Filename;
      sUserName:=           rJDCon.JDCon_Username;
      sPassword:=           rJDCon.JDCon_Password;
      sDriver:=             rJDCon.JDCon_ODBC_Driver;
      sServer:=             rJDCon.JDCon_Server;
      sDatabase:=           rJDCon.JDCon_Database;
      u8DriverID:=          rJDCon.JDCon_Driver_ID;
      u8DbmsID:=            rJDCon.JDCon_DBMS_ID;
      bJas:=                rJDCon.JDCon_JAS_b;
      saDBCFilename:=       rJDCon.JDCon_DBC_Filename;
      if fileexists(saDBCFilename) then
      begin
        bOk:=TGT.bLoad(saDBCFilename);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211110021, '****Unable to load DBC configuration file: ' + saDBCFilename,'', SOURCEFILE);
        end;
      end ;
    end;//with
  end;

  if bOk then
  begin
    bOk:=TGT.OpenCon;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211110022,'Unable to open TARGET database connection',
        'Name: '+TGT.sName+' u84DBMSID:'+inttostr(TGT.u8DBMSID)+' u8DriverID: '+inttostr(TGT.u8DriverID),SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    saLogDir:='..'+DOSSLASH+'jets'+DOSSLASH+saName+DOSSLASH+'log'+DOSSLASH;
    clear_JVHost(rJVHost);
    with rJVHost do begin
      VHost_JVHost_UID               :=0;
      VHost_WebRootDir               :='..'+DOSSLASH+'jets'+DOSSLASH+lowercase(saName)+DOSSLASH+'webroot'+DOSSLASH;
      //VHost_WebRootDir               :='..'+DOSSLASH+'webroot'+DOSSLASH;
      VHost_ServerName               :=saServerName;
      VHost_ServerIdent              :=Upcase(saName);
      VHost_ServerDomain             :=saName;
      VHost_DefaultLanguage          :='en';
      VHost_DefaultTheme             :='brown';
      VHost_MenuRenderMethod         :=3;
      VHost_DefaultArea              :='sys_area';
      VHost_DefaultPage              :='sys_page';
      VHost_DefaultSection           :='MAIN';
      VHost_DefaultTop_JMenu_ID      :=1;// JAS Default Menu Tree Top
      VHost_DefaultLoggedInPage      :='/'+saName+'/';
      VHost_DefaultLoggedOutPage     :='/'+saName+'/';
      VHost_DataOnRight_b            :=false;
      VHost_CacheMaxAgeInSeconds     :=3600;
      VHost_SystemEmailFromAddress   := saFromEmailAddress;
      VHost_SharesDefaultDomain_b    :=true;
      VHost_DefaultIconTheme         :=garJVHost[p_Context.u2VHost].VHost_DefaultIconTheme;
      VHost_DirectoryListing_b       :=true;
      VHost_FileDir                  :='..'+DOSSLASH+'jets'+DOSSLASH+saName+DOSSLASH+'file'+DOSSLASH;
      VHost_AccessLog                :=saLogdir+'access.'+saName+'.log';
      VHost_ErrorLog                 :=saLogDir+'error.'+saName+'.log';
      VHost_JDConnection_ID          :=JDCon_JDConnection_UID;
      VHost_Enabled_b                :=true;
      VHost_CacheDir                 :='..'+DOSSLASH+'jets'+DOSSLASH+saName+DOSSLASH+'cache'+DOSSLASH;
      VHost_TemplateDir              :='..'+DOSSLASH+'jets'+DOSSLASH+saName+DOSSLASH+'templates'+DOSSLASH;
    end;//with
    bOk:=bJAS_Save_JVHost(p_COntext, DBC, rJVHost, false,false, 201608310150);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201211091305, 'Unable to save Virtual Host record to database.','Name: '+saName,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    clear_JIndexFile(rJIndexFile1);
    with rJIndexFile1 do begin
      JIDX_JIndexFile_UID        :=0;
      JIDX_JVHost_ID             :=rJVhost.VHost_JVHost_UID;
      JIDX_Filename              :='index.jas';
      JIDX_Order_u               :=1;
    end;//with
    bOk:=bJAS_Save_JIndexFile(p_Context, DBC, rJIndexFile1, false,false, 201608310151);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211101508,'Unable to save new jas index file record for name: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    clear_JIndexFile(rJIndexFile2);
    with rJIndexFile2 do begin
      JIDX_JIndexFile_UID        :=0;
      JIDX_JVHost_ID             :=rJVhost.VHost_JVHost_UID;
      JIDX_Filename              :='index.html';
      JIDX_Order_u               :=2;
    end;//with
    bOk:=bJAS_Save_JIndexFile(p_Context, DBC, rJIndexFile2, false,false, 201608310152);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211101508,'Unable to save new html index file record for name: '+saName,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    clear_JPerson(rJPerson);
    with rJPerson do begin
      JPers_JPerson_UID                 :=0;
      //JPers_Desc                        : ansistring;
      //JPers_NameSalutation              : ansistring;
      JPers_NameFirst                   :=p_Context.CGIENV.DataIn.Get_saValue('firstname');
      //JPers_NameMiddle                  : ansistring;
      JPers_NameLast                    :=p_Context.CGIENV.DataIn.Get_saValue('lastname');
      //JPers_NameSuffix                  : ansistring;
      //JPers_NameDear                    : ansistring;
      //JPers_Gender                      : ansistring;
      //JPers_Private_b                   : ansistring;
      //JPers_Addr1                       : ansistring;
      //JPers_Addr2                       : ansistring;
      //JPers_Addr3                       : ansistring;
      //JPers_City                        : ansistring;
      //JPers_State                       : ansistring;
      //JPers_PostalCode                  : ansistring;
      //JPers_Country                     : ansistring;
      //JPers_Home_Email                  : ansistring;
      //JPers_Home_Phone                  : ansistring;
      //JPers_Latitude_d                  : ansistring;
      //JPers_Longitude_d                 : ansistring;
      //JPers_Mobile_Phone                : ansistring;
      JPers_Work_Email                  :=p_Context.CGIENV.DataIn.Get_saValue('workemail');
      //JPers_Work_Phone                  : ansistring;
      //JPers_Primary_Org_ID              : ansistring;
      //JPers_Customer_b                  : ansistring;
      //JPers_Vendor_b                    : ansistring;
      //JPers_DOB_DT                      : ansistring;
      //JPers_CreatedBy_JUser_ID          : ansistring;
      //JPers_Created_DT                  : ansistring;
      //JPers_ModifiedBy_JUser_ID         : ansistring;
      //JPers_Modified_DT                 : ansistring;
      //JPers_DeletedBy_JUser_ID          : ansistring;
      //JPers_Deleted_DT                  : ansistring;
      //JPers_Deleted_b                   : ansistring;
      //JAS_Row_b                         : ansistring;
    end;//with
    bOk:=bJAS_Save_JPerson(p_Context, TGT, rJPerson, false, false, 201608310153);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211102327,'Unable to save person record.','',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    saQry:='delete from juser';
    rs.open(saQry,TGT,201506121123);
    rs.close;
    
    clear_JUser(rJUser);
    with rJUser do begin
      JUser_JUser_UID              :=0;
      JUser_Name                   :='admin';
      JUser_Password               :='NOT SET';
      JUser_JPerson_ID             :=rJPerson.JPers_JPerson_UID;
      JUser_Enabled_b              :=true;
      JUser_Admin_b                :=false;
      //JUser_Login_First_DT         : ansistring;
      //JUser_Login_Last_DT          : ansistring;
      JUser_Logins_Successful_u    :=0;
      JUser_Logins_Failed_u        :=0;
      //JUser_Password_Changed_DT    : ansistring;
      JUser_AllowedSessions_u      :=1;
      JUser_DefaultPage_Login      :='';
      JUser_DefaultPage_Logout     :='';
      JUser_JLanguage_ID           :=1;//english
      JUser_Audit_b                :=false;
      JUser_ResetPass_u            :=u8Val(sGetUID);
      JUser_JVHost_ID              :=rJVhost.VHost_JVHost_UID;
      JAS_Row_b                    :=true;
    end;//with
    bOk:=bJAS_Save_JUser(p_Context, TGT, rJUser, false, false, 201608310154);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211102319,'Unable to save admin user record.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    rJUser.JUser_JUser_UID:=1;
    saQry:='UPDATE juser SET JUser_JUser_UID='+TGT.sDBMSUIntScrub(rJUser.JUser_JUser_UID);
    bOk:=rs.open(saQry,TGT,201503161421);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211240137,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT, rs);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='UPDATE jmenu SET JMenu_URL=''.'' WHERE JMenu_JMenu_UID=2012050308492312356';
    bOk:=rs.open(saQry,TGT,201503161422);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201503130006,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT, rs);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='delete from jquicklink where JQLnk_JQuickLink_UID=61';//cycle server quicklink
    bOk:=rs.open(saQry,TGT,201503161423);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201503130248,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT, rs);
    end;
    rs.close;
  end;


  if bOk then
  begin
    saQry:='delete from jmenu where JMenu_JMenu_UID=1234';//Cycle Server Menu Option
    bOk:=rs.open(saQry,TGT,201503161424);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201503130253,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT, rs);
    end;
    rs.close;
  end;

  if bOk then  // change the caption on sync n cycle to just say sync for jets.
  begin
    saQry:='update jmenu set JMenu_Name=''Syncronization'', JMenu_Title_EN=''Synchronization'' where JMenu_JMenu_UID=1442';
    bOk:=rs.open(saQry,TGT,201503161425);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201503130253,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT, rs);
    end;
    rs.close;
  end;


  if bOk then
  begin
    clear_JSecGrpUserLink(rJSecGrpUserLink);
    with rJSecGrpUserLink do begin
      JSGUL_JSecGrpUserLink_UID   :=0;
      JSGUL_JSecGrp_ID            :=cnJSecGrp_Administrators;
      JSGUL_JUser_ID              :=rJUser.JUser_JUser_UID;
    end;//with
    bOk:=bJAS_Save_JSecGrpUserLink(p_Context, TGT, rJSecGrpUserLink, false, false, 201608310155);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211110101, 'Unable to save JSecGrpUserLink for Admin','',SOURCEFILE);
    end;
  end;

  // Make New DB Connection a Permission IN BOTH Main Jet and Client Jet
  if bOk then
  begin
    Clear_JSecPerm(rJSecPerm);
    with rJSecPerm do begin
      perm_JSecPerm_UID        :=0;
      perm_Name                :='DB Connection '+rJDCon.JDCon_Name;
    end;//with
    bOk:=bJAS_Save_JSecPerm(p_Context, DBC, rJSecPerm, false,false, 201608310156);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211271422, 'Unable to save permission in Lead Jet for Client DBConnection','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saQry:='INSERT INTO jsecperm (perm_JSecPerm_UID) VALUES ('+DBC.sDBMSUIntScrub(rJSecPerm.perm_JSecPerm_UID)+')';
    bOk:=rs.Open(saQry, TGT,201503161426);
    if not bOk then
    begin
      JAS_LOG(p_COntext, cnLog_Error, 201211271426,'Trouble with query.','Query: '+saQry, SOURCEFILE, TGT, rs);
    end;
    rs.close;
  end;

  if bOk then
  begin
    bOk:=bJAS_Save_JSecPerm(p_Context, TGT, rJSecPerm, false,false, 201608310157);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211271427, 'Unable to save permission in Client Jet for Client DBConnection','',SOURCEFILE);
    end;
  end;    

  // Add it to Client DB Permission to Administrators Group
  if bOk then
  begin
    clear_JSecGrpLink(rJSecGrpLink);
    with rJSecGrpLink do begin
      JSGLk_JSecGrpLink_UID     :=0;
      JSGLk_JSecPerm_ID         :=rJSecPerm.perm_JSecPerm_UID;
      JSGLk_JSecGrp_ID          :=cnJSecGrp_Administrators;
    end;//with
    bOk:=bJAS_Save_JSecGrpLink(p_Context, TGT, rJSecGrpLink, false, false, 201608310157);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211271433, 'Unable to save JSecGrpLink to Client Jet for DB Permission','',SOURCEFILE);
    end;
  end;

  // Save PermID in New DBConnection Record
  if bOk then
  begin
    rJDCon.JDCon_JSecPerm_ID:=rJSecPerm.perm_JSecPerm_UID;
    bOk:=bJAS_Save_JDConnection(p_Context, DBC, rJDCon, false, false, 201608310158);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211271436,'Enable to update Lead Jet with client Jet DB Permission','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bCGIBased:=grJASConfig.bCreateHybridJets;
    if bCGIBased then
    begin
      createdir(garJVHost[p_COntext.u2VHost].VHost_WebRootDir+saName);
      saCGIFileSrc:='../bin/nph-jas.cgi';
      saCGIFileDest:=garJVHost[p_COntext.u2VHost].VHost_WebRootDir+saName+DOSSLASH+'nph-jas.cgi';
      bOk:=bCopyFile(saCGIFileSrc,saCGIFileDest);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211112329, 'Unable to copy nph-jas.cgi program.','',SOURCEFILE);
      end;

      if bOk then
      begin
        u2IOResult:=u2Shell('../bin/fixcgi.sh', saCGIFileDest);
        bOk:=u2IOResult=0;
        if not bOk then
        begin
          //if u2IOResult>32768 then u2IOResult-=32768; not likely going to work with unsigned :)
          JAS_LOG(p_Context, cnLog_warn, 201211120014, 'Unable to configure CGI program.','Cmd >../bin/fixcgi.sh '+saCGIFileDest+'<  Result: '+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),SOURCEFILE);
          //bOk:=true;
        end;
      end;

      if bOk then
      begin
        // chgrp apache nph-jas.cgi
      end;
    end;
  end;

  if bOk then
  begin
    CreateDir(grJASConfig.saSysDir+DOSSLASH+'jets');
    CreateDir(saDestPath);
    CreateDir(rJVHost.VHost_CacheDir);
    CreateDir(rJVHost.VHost_TemplateDir);
    CreateDir(rJVHost.VHost_FileDir);
    CreateDir(rJVHost.VHost_WebRootDir);
    CreateDir(saLogdir);
    
    sa:=grJASConfig.saSysDir+'webroot'+DOSSLASH+'index.jas '+
      rJVHost.VHost_WebRootDir+DOSSLASH+'index.jas';
    u2IOResult:=u2Shell('../bin/cpdir.sh', sa);
    bOk:=u2ioresult=0;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Warn, 201503131350, 'Unable to copy index.jas file. '+sa,
        'Result: '+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),SOURCEFILE);
    end;
    //bOk:=true;
  end;
  
  if bOk then 
  begin
    sa:=grJASConfig.saSysDir+DOSSLASH+'templates'+DOSSLASH+'* '+
       rJVHost.VHost_TemplateDir+'.';
    u2IOResult:=u2Shell('../bin/cpdir.sh', sa);
    bOk:=u2ioresult=0;
    if not bOk then
    begin
      JAS_LOG(p_COntext, cnLog_Warn, 201503131357,'Unable to copy templates folder: ' +sa,'',SOURCEFILE);
      bOk:=false;
    end;
  end;
  
  
  
  if bOk then 
  begin  
    clear_JALias(rJAlias);
    with rJAlias do begin
      Alias_JAlias_UID            :=0;
      Alias_JVHost_ID             :=rJVHost.VHost_JVHost_UID;
      Alias_Alias                 :=saName;
      Alias_Path                  :=rJVHost.VHost_WebRootDir;
      Alias_VHost_b               :=true;
    end;//with
    bOk:=bJAS_Save_JAlias(p_Context,DBC,rJAlias,false,false, 201608310159);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211091407, 'Unable to save new alias record for name: '+saName,'',SOURCEFILE);
    end;
  end;



  if bOk then
  begin
    JASprintln('uj_xml createvirt - update user vhost uid: '+inttostr(rJVHost.VHost_JVHost_UID)+' p_Context.rJUser.JUser_JUser_UID:'+inttostr(p_Context.rJUser.JUser_JUser_UID));
    saQry:='UPDATE juser set JUser_JVHost_ID='+DBC.sDBMSUIntScrub(rJVHost.VHost_JVHost_UID)+' WHERE JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
    bOk:=rs.open(saQry, DBC,201503161427);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211261633, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
    rs.close;
  end;


  if bOk then
  begin
    //ASPrintln('Things are looking up - Sending PASSWORD RESET EMAIL');
    saMsg:=
        '<h2>Congratulations!</h2>'+csCRLF+
        '<p>Your own JAS Jet has been created successfully and is ready for you to log in!</p>'+csCRLF+
        '<p>Your default username is <strong>admin</strong>. All that is left is creating '+
        'your password and logging in!</p><br /><br />'+csCRLF;
    bOk:=bEmail_ResetPassword(p_Context,1, rJUser.JUser_ResetPass_u, rJPerson.JPers_Work_Email,saMsg, saName);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201211231232,'Unable to send JAS Jet Welcome reset password email upon JAS Jet Creation completing.','',SOURCEFILE);
    end;
  end
  else
  begin
    saMsg:=
      '<h2>We''re Sorry</h2>'+csCRLF+
      '<p>The JAS encountered an error while creating your jet. We will address this as soon as possible for you!</p>'+csCRLF+
      '<p>Error code: '+inttostr(p_Context.u8Errno)+' '+p_Context.saErrMsg+'</p>'+csCRLF+
      'Regards,<br />'+csCRLF+
      '&nbsp;&nbsp;The Management'+csCRLF;
    if not bEmail_Generic(p_Context,saMsg,'JAS - We''re Sorry - We were unable to create your JAS Jet <br />') then
    begin
      JAS_Log(p_Context,cnLog_Error,201211231233,'Unable to send create jet failure email notice.',saMsg,SOURCEFILE);
    end;
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',lowercase( trim(sTrueFalse( bok))));
  JASPrintln('Create Virtual Host Finished. Result: '+sTrueFalse(bOk));
  TGT.CloseCon;
  TGT.Destroy;
  rs.destroy;

  JASPrintln('201511240000 ------------------Create Virtual Host Finished ---- OK: '+sTrueFalse(bOk)+'----------');

  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211061926,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
procedure JASAPI_DoesUserHaveJet(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  saHostID: ansistring;
  saAlias: ansistring;
  VHost_SharesDefaultDomain_b: ansistring;
  VHost_ServerDomain: ansistring;
  VHost_EnableSSL_b: ansistring;
  
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_DoesUserHaveJet'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211240014,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211240015, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saAlias:='';

  if p_Context.bSessionValid then
  begin
    if bOk then
    begin
      saQry:='SELECT JUser_JVHost_ID from juser WHERE ((JUser_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
        '(JUser_JUser_UID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+')';
      bOk:=rs.open(saQry, DBC,201503161428);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211240023, 'Trouble with query.','Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      bOk:=NOT rs.eol;
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211240025, 'User record missing.','Query: '+saQry,SOURCEFILE);
      end;
    end;


    if bOk then
    begin
      saHostID:=rs.fields.Get_saValue('JUser_JVHost_ID');
      if u8Val(saHostID)=cnJUser_JVHost_Processing then saAlias:='PROCESSING';
      rs.close;
    end;

    if bOk and (u8Val(saHostID)>0) and (u8Val(saHostID)<>cnJUser_JVHost_Processing) then
    begin
      saQry:='SELECT VHost_SharesDefaultDomain_b, VHost_ServerDomain, VHost_EnableSSL_b FROM jvhost WHERE '+
        '((VHost_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(VHost_Deleted_b IS NULL)) AND '+
        '(VHost_JVHost_UID='+DBC.sDBMSUIntScrub(saHostID)+')';
      bOk:=rs.open(saQry,DBC,201503161429);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211240024, 'Trouble with query.','Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk and (u8Val(saHostID)>0) and (u8Val(saHostID)<>cnJUser_JVHost_Processing)  then
    begin
      bOk:=NOT rs.eol;
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211240025, 'Users VHost record is missing. saHostID: '+saHostID+' Numeric: '+inttostr(u8Val(saHostID)),'Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk and (u8Val(saHostID)>0) and (u8Val(saHostID)<>cnJUser_JVHost_Processing)  then
    begin
      VHost_SharesDefaultDomain_b:=rs.fields.Get_saValue('VHost_SharesDefaultDomain_b');
      VHost_ServerDomain:=rs.fields.Get_saValue('VHost_ServerDomain');
      VHost_EnableSSL_b:=rs.fields.Get_saValue('VHost_EnableSSL_b');
      rs.close;
      saQry:='SELECT Alias_Alias FROM jalias WHERE (Alias_JVHost_ID = '+DBC.sDBMSUIntScrub(saHostID)+') AND '+
        '((Alias_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(Alias_Deleted_b IS NULL))';
      bOk:=rs.open(saQry, DBC,201503161430);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211240024, 'Trouble with query.','Query: '+saQry,SOURCEFILE);
      end;
    end;

    if bOk then
    begin
      if ((u8Val(saHostID)>0)) and (not rs.eol)  and (u8Val(saHostID)<>cnJUser_JVHost_Processing) then
      begin
        saAlias:=rs.fields.Get_saValue('Alias_Alias');
        if bVal(VHost_SharesDefaultDomain_b) then
        begin
          saAlias:=garJVHost[p_COntext.u2VHost].VHost_ServerURL+'/'+saAlias+'/';
        end
        else
        begin
          saAlias:=VHost_ServerDomain+'/'+saAlias+'/';
          if bVal(VHost_EnableSSL_b) then
          begin
            saAlias:='https://'+saAlias;
          end
          else
          begin
            saAlias:='http://'+saAlias;
          end;
        end;
      end;
    end;
    rs.close;
  end
  else
  begin
    saAlias:='INVALID SESSION';
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',saAlias);
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211240017,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
procedure JASAPI_JetBilling(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  u: uint;
  iDBX: longint;
  u8ActiveUserCount: UInt64;
  DT: TDATETIME;
  fdDaysInPreviousMonth: double;
  fdTotalJetUsers: double;
  iNumOfUsers: longint;
  u2Year, u2Month, u2Day: word;
  rJUser: rtJUSer;
  rJPerson: rtJPerson;
  saSubject: ansistring;
  saMessage: ansistring;
  fdOwed: double;
  saURL: ansistring;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_JetBilling'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201212090711,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201212090712, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;


  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context,cnLog_Error,201212090828,'Invalid Session.','', SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_JetBilling);
    if not bok then
    begin
      JAS_LOG(p_Context,cnLog_Error,201608241639,'You are not authorized to perform this action.','', SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    if p_Context.CGIENV.DataIn.FoundItem_saName('date') then
    begin
      try
        bOk:=false;
        DT:=StrToDateTime(JDate(p_Context.CGIENV.DataIn.Item_saValue,1,11));
        bOk:=true;
      finally
      end;
      if not bOk then
      begin
        JAS_LOG(p_Context,cnLog_Error,201212100638,'BILLING: Invalid date parameter passed: '+
          p_Context.CGIENV.DataIn.Item_saValue,'', SOURCEFILE);
      end;
    end
    else
    begin
      DT:=now;
    end;
  end;
  
  //ASPrintln('UpdateJetUSerAvg - Session Valid');
  if bOk then
  begin
    for u:=0 to length(garJVHost)-1 do
    begin
      bOk:=true;
      //ASPrintln('UpdateJetUSerAvg - Loop: '+inttostR(i));
      if garJVHost[u].VHost_JDConnection_ID<>0 then
      begin
        //ASPrintln('UpdateJetUSerAvg - Non JAS VHost DB Con Found');
        if JADO.bFoundConnectionByID(garJVHost[u].VHost_JDConnection_ID, pointer(p_Context.JADOC), iDBX) then
        begin
          //ASPrintln('UpdateJetUSerAvg - Found Connection By ID: '+inttostr(iDBX));
          //ASPrintln('JADOC len: '+inttostr(length(p_Context.JADOC))+' iDBX: '+inttostr(iDBX));
          TGT:=p_Context.JADOC[iDBX];
          //ASPrintln('UpdateJetUSerAvg - Assigned TGT');

          // Query JAS JET Connection's active user count
          u8ActiveUserCount:=TGT.u8GetRecordCount(
            'juser','((JUser_Deleted_b<>'+TGT.sDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
            'JUser_Enabled_b='+TGT.sDBMSBoolScrub(true),201506171760);
          //ASPrintln('UpdateJetUSerAvg - Got Active USer Count: '+inttostr(u8ActiveUserCount)+' HostID:'+inttostr(garJVHostLight[i].u8JVHost_UID));
          clear_JUser(rJUser);
          rJUser.JUser_JUser_UID:=u8Val(DBC.saGetValue('juser','JUser_JUser_UID','JUser_JVHost_ID='+DBC.sDBMSUIntScrub(garJVHost[u].VHost_JVHost_UID),201608230008));
          bOk:=bJAS_Load_JUser(p_Context,DBC,rJUser,falsE, 201608310160);
          if not bOk then
          begin
            JAS_LOG(p_Context,cnLog_Error,201212090827,'BILLING: Unable to load JUser: '+inttostR(rJUser.JUser_JUser_UID),'', SOURCEFILE);
          end;
          //ASPrintln('UpdateJetUSerAvg - saUserID: '+saUserID);

          if bOk then
          begin
            clear_JPerson(rJPerson);
            rJPerson.JPers_JPerson_UID:=rJUser.JUser_JPerson_ID;
            bOk:=bJAS_Load_JPerson(p_Context, DBC, rJPerson,false, 201608310161);
            if not bOk then
            begin
              JAS_LOG(p_Context,cnLog_Error,201212100720,'BILLING: Unable to load JPerson: '+inttostr(rJPerson.JPers_JPerson_UID),'', SOURCEFILE);
            end;
          end;

          if bOk then
          begin
            DecodeDate(DT,u2Year, u2Month, u2Day);
            if u8ActiveUserCount>2 then
            begin
              if (length(rJPerson.JPers_NameFirst)=0) or
                 (length(rJPerson.JPers_NameLast)=0) or
                 (length(rJPerson.JPers_Work_Email)=0) or
                 (length(rJPerson.JPers_CC)=0) or
                 (length(rJPerson.JPers_CCExpire)=0) or
                 (length(rJPerson.JPers_CCSecCode)=0) or
                 (length(rJPerson.JPers_Addr1)=0) or
                 (length(rJPerson.JPers_City)=0) or
                 (length(rJPerson.JPers_State)=0) or
                 (length(rJPerson.JPers_PostalCode)=0) or
                 (length(rJPerson.JPers_Work_Phone)=0) then
              begin
                saURL:=p_Context.saGetURL(0);
                saSubject:='Jegas CRM Credit Card Request - You have exceeded two users.';
                saMessage:=
                  'Hello '+rJPerson.JPers_NameFirst+','+csCRLF+
                  'We hope you are happy so far with your Jegas CRM. '+csCRLF+csCRLF+
                  'We''ve noticed you have more than two '+
                  'users in your CRM which officially makes you a subscriber. We need '+
                  'your billing information so that we can continue your '+
                  'service.'+csCRLF+csCRLF+
                  'Our system will send reminders until '+
                  'you have a chance to enter your billing information or you bring your active user count '+
                  'to one or two users.'+csCRLF+csCRLF+
                  'Thank you for choosing Jegas, LLC,'+csCRLF+
                  '  The Management'+csCRLF+csCRLF+
                  'Please login and select Account Info in the Preferences menu: '+saURL;
                if not bJAS_Sendmail(p_Context, garJVHost[u].VHost_SystemEmailFromAddress, rJPerson.JPers_Work_Email, saSubject, saMessage) then
                begin
                  JAS_LOG(p_Context,cnLog_Error,201212101718,'BILLING: Unable to send credit card app to : '+rJPerson.JPers_NameFirst+' '+rJPerson.JPers_NameLast,'', SOURCEFILE);
                end;

                saSubject:='New Jegas CRM Subscriber';
                saMessage:='Bill Request Sent - Name: '+rJPerson.JPers_NameFirst+' '+rJPerson.JPers_NameLast;
                if not bJAS_Sendmail(p_Context, garJVHost[0].VHost_SystemEmailFromAddress, garJVHost[0].VHost_SystemEmailFromAddress, saSubject, saMessage) then
                begin
                  JAS_LOG(p_Context,cnLog_Error,201212101718,'BILLING: Unable to send new subscriber notice.','', SOURCEFILE);
                end;

              end;
            end;

            if u2Day=1 then
            begin
              //ASPrintLn('JASBilling: Day: '+inttostr(u2Day));
              DecodeDate(dtAddDays(DT,-1),u2Year, u2Month, u2Day);
              fdDaysInPreviousMonth:=u2Day;
              //ASPrintln('JAS BILLING: Days in previous month: '+saDouble(fdDaysInPreviousMonth,2,0));

              // Note: Total is not Count of users, but a accumulator of users active for each day
              fdTotalJetUsers:=fdVal(DBC.saGetValue('juser','JUser_TotalJetUsers_d','JUser_JUser_UID='+DBC.sDBMSUIntScrub(rJUSer.JUser_JUser_UID),201608230009));
              //ASPrintln('JAS BILLING: Total Jet Users: '+saDouble(fdTotalJetUsers,2,0));
              if fdTotalJetUsers<>0 then
              begin
                iNumOfUsers:=round(fdTotalJetUsers / fdDaysInPreviousMonth);
              end
              else
              begin
                iNumOfUsers:=0;
              end;

              //ASPrintLn('JASBilling: # of Users for '+garJVHostLight[i].saServerName+': '+inttostr(iNumOfUsers));
              if iNumOfUsers>=3 then
              begin
                saSubject:='JAS BILLING for '+rJUser.JUser_Name+' Name: '+rJPerson.JPers_NameFirst+' '+rJPerson.JPers_NameLast;
                saMessage:='<b>'+rJPerson.JPers_NameFirst+' '+rJPerson.JPers_NameLast +'</b> needs to be billed and charged for '+
                  '<b>'+inttostr(iNumOfUsers)+'</b> users for the month of <b>'+inttostr(u2Year)+'-'+inttostr(u2Month)+'</b>,';
                if (iNumOfUsers>=3) and (iNumOfUsers<=5) then fdOwed:=iNumOfUsers * 10.00 else
                if (iNumOfUsers>=6) and (iNumOfUsers<=10) then fdOwed:=iNumOfUsers * 9.50 else
                if (iNumOfUsers>=11) and (iNumOfUsers<=15) then fdOwed:=iNumOfUsers * 9.00 else
                if (iNumOfUsers>=16) and (iNumOfUsers<=20) then fdOwed:=iNumOfUsers * 8.50 else
                if (iNumOfUsers>=21) then fdOwed:=iNumOfUsers * 8.00;
                saMessage+=' this comes to a total of <b>'+saDouble(fdOwed,3,2);

                // BEGIN - - - - - INITIATE BILLING HERE
                bOk:=bEmail_Generic(p_Context, saSubject, saMessage);
                if not bOk then
                begin
                  JAS_LOG(p_Context,cnLog_Error,201212090827,'BILLING EMAIL FAILED TO SEND',
                    'Subject: '+saSubject+' Message: '+saMessage, SOURCEFILE);
                end;
                // END - - - - - INITIATE BILLING HERE
              end;

              if bOk then
              begin
                saQry:='UPDATE juser SET JUser_TotalJetUsers_d='+DBC.sDBMSUIntScrub(0)+
                  ' WHERE JUser_JUser_UID='+DBC.sDBMSUIntScrub(rJUser.JUser_JUser_UID);
                bOk:=rs.open(saQry, DBC,201503161431);
                if not bOk then
                begin
                  JAS_LOG(p_Context,cnLog_Error,201212100826,'BILLING: Trouble with Query.','Query: '+saQry, SOURCEFILE, DBC, rs);
                end;
                rs.close;
              end;
            end;

            if bOk then
            begin
              // Update LEAD JET user record of user owning JAS JET's running average of active users
              saQry:='UPDATE juser SET JUser_TotalJetUsers_d=JUser_TotalJetUsers_d + '+
                DBC.sDBMSUIntScrub(u8ActiveUserCount)+' WHERE ((JUser_Deleted_b<>'+
                DBC.sDBMSBoolScrub(true)+')OR(JUser_Deleted_b IS NULL)) AND '+
                'JUser_Enabled_b='+DBC.sDBMSBoolScrub(true)+' AND JUser_JUser_UID='+
                DBC.sDBMSUIntScrub(rJUSer.JUser_JUser_UID);
              bOk:=rs.open(saQry, DBC,201503161432);
              if not bOk then
              begin
                JAS_LOG(p_Context,cnLog_Error,201212090827,'BILLING: Trouble with Query.','Query: '+saQry, SOURCEFILE, DBC, rs);
              end;
              rs.close;
              //ASPrintln('UpdateJetUSerAvg - bOk: '+sTrueFalse(bOk)+' Qry: '+saQry);
            end;
          end;
        end
        else
        begin
          bOk:=false;
          JAS_LOG(p_Context,cnLog_Error,201212100614,'BILLING: Unable to find DB Connection for Jet '+garJVHost[u].VHost_ServerName,'Query: '+saQry, SOURCEFILE, DBC, rs);
        end;
      end;
      if not bOk then break;
    end;
  end;

  p_Context.XML.AppendItem_saName_N_saValue('result',sTrueFalse(bOk));
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201212090713,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
// This JASAPI call performs the exact function that the TJADO or TCONNECTION
// classes offer. Session Validation is performed. Also, the user needs to have
// READ PERMISSION for the juserpref table or the call will fail.
// Pretty much anytime a user can't access a permission table - they can't do JACK! :)
procedure JASAPI_GetValue(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saTable: ansistring;//looks better to me..this formatting of the variables
  saWhere: ansistring;//having them vertical versus comma delimited in a list.
  saField: ansistring;//but either way is fine. I'm leaving this
  saValue: ansistring;//comment in BOOO! :) --Jason
  saReqPermID: ansistring;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_GetValue'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201507120000,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201507120001, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  DBC:=p_Context.VHDBC;
  saTable:=      '';
  saWhere:=      '';
  saField:=      '';
  saValue:=      '';
  saReqPermID:=  '';

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    p_Context.bErrorCondition:=true;
    p_Context.u8ErrNo:=201507120002;
    p_Context.saErrMsg:='Invalid Session';
    p_Context.saErrMsgMoreInfo:='';
    //AS_LOG(p_Context,cnLog_Warn,p_Context.u8ErrNo,'Invalid Session.','', SOURCEFILE);
  end;

  if bOk then
  begin
    if p_COntext.CGIENV.DataIn.FoundItem_saName('table') then saTable:=p_COntext.CGIENV.DataIn.Item_saValue;
    if p_COntext.CGIENV.DataIn.FoundItem_saName('field') then saField:=p_COntext.CGIENV.DataIn.Item_saValue;
    if p_COntext.CGIENV.DataIn.FoundItem_saName('where') then saWhere:=p_COntext.CGIENV.DataIn.Item_saValue;
    saReqPermID:= p_Context.VHDBC.saGetValue(
      'jtable',
      'JTabl_View_JSecPerm_ID',
      '(JTabl_Name='+DBC.saDBMSScrub(saTable)+') and (JTabl_Deleted_b<>true)'
    ,201608230010);
    //ASprintln('req perm id:'+saReqPermID);
    bOk:=bJAS_HasPermission(p_Context,u8Val(saReqPermID));
    if not bOk then
    begin
      p_Context.bErrorCondition:=true;
      p_Context.u8ErrNo:=201507120004;
      p_Context.saErrMsg:='Access Denied';
      p_Context.saErrMsgMoreInfo:='';
      //AS_LOG(p_Context,cnLog_Warn,201507120004,'Access Denied','', SOURCEFILE);
      bOk:=false;
    end;
  end;

  if bOk then
  begin
    //function saGetValue(p_saTable: ansistring; p_saField: ansistring; p_saWhereClauseOrBlank: ansistring):ansistring;
    saValue:=DBC.saGetValue(saTable,saField,saWhere,201608230011);
  end;
  p_Context.XML.AppendItem_saName_N_saValue('result',saValue);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201507120003,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
{}
// This JASAPI call accepts a parameter named UID which is the UID for the
// juserpref table. In this table is the jhelp UID that we use to grab the
// html help for both the user and (if an admin) the admin help too, in the
// appropriate language for the user.
procedure JASAPI_UserPrefHelp(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saUID: ansistring;
  saQry: ansistring;
  saHelpID: ansistring;
  rs: JADO_RECORDSET;
  saResult: ansistring;
  DBC: JADO_CONNECTION;

{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='JASAPI_UserPrefHelp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201507130000,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201507130001, sTHIS_ROUTINE_NAME);{$ENDIF}
  p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;// Not setting this will cause an error.
  saResult:='';
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    p_Context.bErrorCondition:=true;
    p_Context.u8ErrNo:=201507130002;
    p_Context.saErrMsg:='Invalid Session';
    p_Context.saErrMsgMoreInfo:='';
    //AS_LOG(p_Context,cnLog_Warn,201507130002,'Invalid Session.','', SOURCEFILE);
  end;

  if bOk then
  begin
    bOk:=p_COntext.CGIENV.DataIn.FoundItem_saName('UID');
    if not bOk then                             
    begin                                       
      p_Context.bErrorCondition:=true;
      p_Context.u8ErrNo:=201507130003;
      p_Context.saErrMsg:='Missing Required Parameter';
      p_Context.saErrMsgMoreInfo:=
        'The missing parameter is named UID and refers to the juserpref table''s UID. '+
        'From this the help information in the correct language is extrapolated.';
      //AS_LOG(p_Context,cnLog_Warn,201507130003,'Missing Required Parameter.',
      //  'The missing parameter is named UID and refers to the juserpref table''s UID. '+
      //  'From this the help information in the correct language is extrapolated.', SOURCEFILE);
    end;                                        
  end;                                          
                                                
  if bOk then
  begin                                         
    saUID:=inttostr(u8Val(p_COntext.CGIENV.DataIn.Item_saValue));
    //riteln('========saUID:'+saUID+'===========');
    saHelpID:=inttostr(u8Val(DBC.saGetValue('juserpref','UserP_Help_ID',
      '(UserP_UserPref_UID='+saUID+ ') and (UserP_Deleted_b<>true)',201608230012)));
    bOk:=saHelpID<>'0';
    if not bOk then
    begin
      //p_Context.bErrorCondition:=true;
      //p_Context.u8ErrNo:=201507131517;
      //p_Context.saErrMsg:='Help ID Not Found: '+saHelpID;
      //p_Context.saErrMsgMoreInfo:='';

      // Fall thru - so no output - just no help.
      // not error.. just more content needed.
    end;
  end;

  if bOk then
  begin
    saQry:=
      'SELECT '+
        'Help_Name_'+p_Context.sLang+' ,'+
        'Help_HTML_'+p_Context.sLang;
    if p_Context.rJUser.JUser_Admin_b then
    begin
      saQry+=
        ' , Help_HTML_Adv_'+p_COntext.sLang+' ';
    end;
    saQry+=
      'FROM jhelp '+
      'WHERE (Help_Deleted_b<>true) AND (Help_JHelp_UID='+saHelpID+')';
    bOk:=rs.Open(saQry, DBC, 201507121806);
    if not bOk then
    begin
      p_Context.bErrorCondition:=true;
      p_Context.u8ErrNo:=201507130004;
      //p_Context.saErrMsg:='Query Trouble '+'Query: '+saQry;
      p_Context.saErrMsg:='Query Trouble';
      p_Context.saErrMsgMoreInfo:='Query: '+saQry;
      //AS_LOG(p_Context,cnLog_Warn,201507130004,'Trouble with Query.',
      //  'Query: '+saQry, SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    if not rs.eol then
    begin
      saResult:=rs.fields.Get_saValue('Help_Name_'+p_COntext.sLang)+' '+
                rs.fields.Get_saValue('Help_HTML_'+p_COntext.sLang);
      if p_Context.rJUser.JUser_Admin_b then
      begin
        saResult+=' '+rs.fields.Get_saValue('Help_HTML_Adv_'+p_COntext.sLang);
      end;
    end;
  end;
  saResult:=saEncodeURI(saResult);
  p_Context.XML.AppendItem_saName_N_saValue('result',saResult);
  rs.destroy;rs:=nil;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201507130005,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
