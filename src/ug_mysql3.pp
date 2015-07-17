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
// Unit to aid with Mysql v3
//
// NOTE: This file (2006-05-09) compiled today, note its a bit dated, at least
// the version of MYSQL it was designed to run on. I'm currently redesigning,
// organizing, and "upgrading" the source - to new version of FreePascal
// and MySQL... bringing the ultimate sum of the Jegas Parts into 2006/2007
// technology that appears to be consistant for the moment... ah... 
// technology and computers... like clothes on a computer, you can change
// the clothes... but its still a computer :)
//
unit ug_mysql3;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_mysql3.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================






//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
uses 
//=============================================================================
  mysql3,
  ug_misc,
  ug_common,
  ug_jfc_dl;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!TCMySqlItem
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
type TCMySqlItem = class(JFC_DLITEM)
//=============================================================================
  public
  alpRowBuf : TMYSQL_ROW;
  lpQResult : PMYSQL_RES;
  bConnected: boolean;
  constructor create;
  destructor destroy; override;
  {}
  // Executes query using THIS connection
  // calls mysql_store_result internally - don't need to call it yourself.
  // however - when you are through with the query - call DoneQuery
  // so mysql_free_result gets called.
  function ExecuteQuery(p_sa: AnsiString):boolean;
  {}
  // Works Just Like Execute Query except it executes the specified file if it
  // can find it and load it.
  function ExecuteQueryFromFile(p_sa: AnsiString):boolean;
  {}
  // Calls mysql_free_result for current connection MYSqlXDL is pointing to.
  procedure DoneQuery;
  {}
  // Calls mysql_select_db for current connection MySqlXDL is pointing to.
  function SelectDatabase(p_sa:AnsiString):boolean;
  {}
  // returns true if current connection MySQLXDL is pointing to. This only
  // works if you follow recommendations - see "QResult" above.
  function HaveResults: boolean;
  property HaveConnection: boolean read bconnected Write bConnected;
End;
//=============================================================================










//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!TCMySqlDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{}
type TCMYSQLDL = class(JFC_DL)
//=============================================================================
  protected
  function pvt_CreateItem: TCMySqlItem; override;
  procedure pvt_DestroyItem(p_lp:pointer); override;

  function  read_item_lpQResult: pointer;
  procedure write_item_lpQResult(p_lpQResult: pointer);
  function read_bConnected: boolean;
  procedure write_bConnected(p_bConnected: boolean);
  function Read_item_alpRowBuf: pointer;
  procedure Write_item_alpRowBuf(p_lp: pointer);
{}
//  function read_item_lp: pointer;
//  procedure write_item_lp(p_lp: pointer);
{}


  public
  //--------------------------------------------------------------------------
  {}
  // This function returns true if the connection was successful and false if
  // not - simple enough - just remember that a record is created in the
  // MYSQLXDL class (see uxxg_JFC.pp for details) regardless of connection.
  // this way you can poll for errors and stuff like this:
  // writeln(stderr, mysql_error(MySqlXDL.PTR));
  //
  // when you are totally done you can simply delete the record from MySqlXDL
  // with MySqlXDL.Delete - just make sure MySqlXDL is pointing to the correct
  // connection you want to delete! It can hold a practically unlimited
  // amount of valid and failed connections.
  function CreateConnection(p_saHost, p_saUser, p_saPasswd: AnsiString):boolean;
  //--------------------------------------------------------------------------
  {}
  // Returns mysql.pp "PMYSQL_RES" This is maintained provided you use
  // Method ExecuteQuery instead of mysql_query and you use method DoneQuery
  // instead of mysql_free_result. If you follow this advice - QResult will
  // be set to NIL whenever you don't have results in mem. This is how
  // the method HaveResults works. This works on the Current "connection"
  // MySQLXDL is pointing to.
  property QResult: pointer read read_item_lpQResult Write write_item_lpQResult;
  //--------------------------------------------------------------------------
  {}
  // Obvious - But it only works for current "connection" MySqlXDL is pointing
  // to.
  property Connected: boolean read read_bConnected Write Write_bConnected;
  //--------------------------------------------------------------------------
  {}
  // Executes query using current connection MySqlXDL is pointing to -
  // calls mysql_store_result internally - don't need to call it yourself.
  // however - when you are through with the query - call DoneQuery
  // so mysql_free_result gets called.
  function ExecuteQuery(p_sa: AnsiString):boolean;
  //--------------------------------------------------------------------------
  {}
  // Works Just Like Execute Query except it executes the specified file if it
  // can find it and load it.
  function ExecuteQueryFromFile(p_sa: AnsiString):boolean;
  //--------------------------------------------------------------------------
  {}
  // Calls mysql_free_result for current connection MYSqlXDL is pointing to.
  procedure DoneQuery;
  //--------------------------------------------------------------------------
  {}
  // Calls mysql_select_db for current connection MySqlXDL is pointing to.
  function SelectDatabase(p_sa:AnsiString):boolean;
  //--------------------------------------------------------------------------
  {}
  // returns true if current connection MySQLXDL is pointing to. This only
  // works if you follow recommendations - see "QResult" above.
  function HaveResults: boolean;
  //--------------------------------------------------------------------------
  {}
  // This is a shorthand way to access TCMySqlItem(MySqlXDL.lpITem).aRowBuf
  // When mysql_fetchrow. Example:
  //   MySqlXDL.RowBuf:=mysql_fetch_row(MySQLXDL.QResult);
  //
  // This is provided so you can have a rowbuffer for each connection in
  // MySQLXDL. Accessing elements directly is a pain - its easyier to make a
  // your own MyRowBuf: TMySql_ROW; for working with - just
  // assign it like this MyRowBuf:=MySqlXDL.RowBuf;
  // then do whatever writeln(MyRowBuf[1]); (Or use the ITEM in the linked list
  // directly.)
  property Item_RowBuf: pointer read read_item_alpRowBuf Write write_item_alpRowBuf;
  //--------------------------------------------------------------------------
  // This is the a pointer for each connection - a pointer to a TMYSQL structure
  // Item_lpPtr
End;
//=============================================================================




//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!Declarations
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{}
var clsMYSQL: TCMYSQLDL;
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              implementation
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !@!TCMySqlItem
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
constructor TCMySqlItem.Create;
//=============================================================================
Begin
  inherited;
  lpQResult:=nil;
  pointer(alpRowBuf):=nil;
  bConnected:=false;
End;
//=============================================================================

//=============================================================================
destructor TCMySqlItem.destroy;
//=============================================================================
Begin
  if lpQResult<>nil then mysql_free_result(lpQResult);
  if bConnected then mysql_close(lpPtr);
  inherited;
End;
//=============================================================================

//=============================================================================
function TCMySqlItem.ExecuteQuery(p_sa: AnsiString):boolean;
//=============================================================================
Begin
  result:=mysql_query(lpPtr,PChar(p_sa))=0;
  if result then lpQResult:=mysql_store_result(lpPtr);
End;
//=============================================================================

//=============================================================================
// Works Just Like Execute Query except it executes the specified file if it
// can find it and load it.
function TCMySqlItem.ExecuteQueryFromFile(p_sa: AnsiString):boolean;
//=============================================================================
var saData: AnsiString;
Begin
  result := bLoadTextFile(p_sa, saData) and ExecuteQuery(saData);
End;
//=============================================================================

//=============================================================================
// Calls mysql_free_result for THIS connection
procedure TCMySqlItem.DoneQuery;
//=============================================================================
Begin
  if HaveResults then mysql_free_result(lpQResult);
  lpQResult:=nil;
End;
//=============================================================================

//=============================================================================
// Calls mysql_select_db for THIS connection
function TCMySqlItem.SelectDatabase(p_sa:AnsiString):boolean;
//=============================================================================
Begin
  result:=mysql_select_db(lpPtr,PChar(p_sa))=0;
End;
//=============================================================================

//=============================================================================
function TCMySqlItem.HaveResults: boolean;
//=============================================================================
Begin
  Result:=lpQResult<>nil;
End;
//=============================================================================











//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !@!TCMySqlDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
function TCMySqlDL.pvt_CreateItem: TCMySqlItem;
//=============================================================================
Begin
  result:=TCMySqlItem.create;
End;
//=============================================================================

//=============================================================================
procedure TCMySqlDL.pvt_DestroyItem(p_lp:pointer);
//=============================================================================
Begin
  TCMySqlItem(p_lp).destroy;
End;
//=============================================================================

//=============================================================================
function  TCMySqlDL.read_item_lpQResult: pointer;
//=============================================================================
Begin
  result:=TCMySqlItem(lpITem).lpQResult;
End;
//=============================================================================

//=============================================================================
procedure TCMySqlDL.write_item_lpQresult(p_lpQresult: pointer);
//=============================================================================
Begin
  TCMySqlItem(lpITem).lpQResult:=p_lpQResult;
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.read_bConnected: boolean;
//=============================================================================
Begin
  result:=TCMySqlItem(lpItem).bConnected;
End;
//=============================================================================

//=============================================================================
procedure TCMySqlDL.write_bConnected(p_bConnected: boolean);
//=============================================================================
Begin
  TCMySqlItem(lpItem).bConnected:=p_bConnected;
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.ExecuteQuery(p_sa: AnsiString):boolean;
//=============================================================================
Begin
  result:=TCMySQlItem(lpItem).ExecuteQuery(p_sa);
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.ExecuteQueryFromFile(p_sa: AnsiString):boolean;
//=============================================================================
Begin
  result:=tCMySqlItem(lpItem).ExecuteQueryFromFile(p_sa);
End;
//=============================================================================


//=============================================================================
procedure TCMySqlDL.DoneQuery;
//=============================================================================
Begin
  TCMySqlItem(lpItem).DoneQuery;
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.SelectDatabase(p_sa:AnsiString):boolean;
//=============================================================================
Begin
  result:=TCMySQLItem(lpItem).SelectDatabase(p_sa);
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.HaveResults: boolean;
//=============================================================================
Begin
  result:=TCMySqlItem(lpitem).HAveResults;
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.Read_item_alpRowBuf: pointer;
//=============================================================================
Begin
  Result:=TCMySqlItem(lpItem).alpRowBuf;
End;
//=============================================================================

//=============================================================================
procedure TCMySqlDL.Write_item_alpRowBuf(p_lp: pointer);
//=============================================================================
Begin
  TCMySqlItem(lpItem).alpRowBuf:=p_lp;
End;
//=============================================================================

//=============================================================================
function TCMySqlDL.CreateConnection(
  p_saHost, p_saUser, p_saPasswd: AnsiString):boolean;
//=============================================================================
var lphost:pointer;
    lpUser:pointer;
    lpPasswd:pointer;
Begin
  AppendItem;
  if length(p_saHost)=0 then lpHost:=nil else lpHost:=pointer(p_saHost);
  if length(p_saUser)=0 then lpUser:=nil else lpUser:=pointer(p_saUser);
  if length(p_saPasswd)=0 then lpPasswd:=nil else lpPasswd:=pointer(p_saPasswd);
  //sagelog(1,'MYSql Item_lpPtr Before:'+inttostr(longword(item_lpPtr)));
  TCMySqlItem(lpItem).lpPtr:=mysql_connect(TCMySqlItem(lpItem).lpPtr,lpHost, lpUser, lpPasswd);
  result:=TCMySqlItem(lpItem).lpPtr<>nil;

  //sagelog(1,'After:'+inttostr(longword(item_lpptr)));

  Connected:=result;
End;
//=============================================================================








//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  clsMySql:=nil;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
