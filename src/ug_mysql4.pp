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
// MySQL 4+ unit
//
//Note: The goal of this unit is to make a wrapper for the FreePascal
// MySql unit written for version 4... and trying to maintain 
// backward compatibility with the MySQL3 wrapper counterpart of this unit.
//
// NOTE: SUCCESS - however there are two pointers you need to be concerned 
// about in version 4. 
// 
// 1:The clsMySQL.rMySQL is for any MySQL4 unit calls that
// require TMYSQL. This is like a global pointer to the mysql client.
//
// 2: Each item/connection in clsMySQL has a pointer stored in 
//    clsMySQL.Item_lpItem. When a MySql4 unit requires PMYSQL, this
//    is the value you need to send.
//
Unit ug_mysql4;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_mysql4.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
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
  mysql4,
  ug_misc,
  ug_common,
  ug_jfc_xdl;
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
Type TCMySqlItem = Class(JFC_XDLITEM)
//=============================================================================
  Public
  //rSock: PMYSQL;
  {}
  alpRowBuf : TMYSQL_ROW;
  lpQResult : PMYSQL_RES;
  bConnected: Boolean;
  Constructor create;
  Destructor destroy; override;
  // Executes query using THIS connection
  // calls mysql_store_result internally - don't need to call it yourself.
  // however - when you are through with the query - call DoneQuery
  // so mysql_free_result gets called.
  Function ExecuteQuery(p_sa: AnsiString):Boolean;
  // Works Just Like Execute Query except it executes the specified file if it
  // can find it and load it.
  Function ExecuteQueryFromFile(p_sa: AnsiString):Boolean;
  // Calls mysql_free_result for current connection MYSqlXDL is pointing to.
  Procedure DoneQuery;
  // Calls mysql_select_db for current connection MySqlXDL is pointing to.
  Function SelectDatabase(p_sa:AnsiString):Boolean;
  // returns true if current connection MySQLXDL is pointing to. This only
  // works if you follow recommendations - see "QResult" above.
  Function HaveResults: Boolean;
  Property HaveConnection: Boolean read bconnected Write bConnected;
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
Type TCMYSQLDL = Class(JFC_XDL)
//=============================================================================
  {}
  public
  Function pvt_CreateItem: TCMySqlItem; override;
  Procedure pvt_DestroyItem(p_lp:pointer); override;

  Function  read_item_lpQResult: pointer;
  Procedure write_item_lpQResult(p_lpQResult: pointer);
  Function read_bConnected: Boolean;
  Procedure write_bConnected(p_bConnected: Boolean);
  Function Read_item_alpRowBuf: pointer;
  Procedure Write_item_alpRowBuf(p_lp: pointer);
{}
//  function read_item_lp: pointer;
//  procedure write_item_lp(p_lp: pointer);
{}


  Public
  Constructor create;
  
  public
  rMySQL: TMYSQL;

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
  Function CreateConnection(p_saHost, p_saUser, p_saPasswd: AnsiString):Boolean;
  //--------------------------------------------------------------------------
  {}
  // Returns mysql.pp "PMYSQL_RES" This is maintained provided you use
  // Method ExecuteQuery instead of mysql_query and you use method DoneQuery
  // instead of mysql_free_result. If you follow this advice - QResult will
  // be set to NIL whenever you don't have results in mem. This is how
  // the method HaveResults works. This works on the Current "connection"
  // MySQLXDL is pointing to.
  Property QResult: pointer read read_item_lpQResult Write write_item_lpQResult;
  //--------------------------------------------------------------------------
  {}
  // Obvious - But it only works for current "connection" MySqlXDL is pointing
  // to.
  Property Connected: Boolean read read_bConnected Write Write_bConnected;
  //--------------------------------------------------------------------------
  {}
  // Executes query using current connection MySqlXDL is pointing to -
  // calls mysql_store_result internally - don't need to call it yourself.
  // however - when you are through with the query - call DoneQuery
  // so mysql_free_result gets called.
  Function ExecuteQuery(p_sa: AnsiString):Boolean;
  //--------------------------------------------------------------------------
  {}
  // Works Just Like Execute Query except it executes the specified file if it
  // can find it and load it.
  Function ExecuteQueryFromFile(p_sa: AnsiString):Boolean;
  //--------------------------------------------------------------------------
  {}
  // Calls mysql_free_result for current connection MYSqlXDL is pointing to.
  Procedure DoneQuery;
  //--------------------------------------------------------------------------
  {}
  // Calls mysql_select_db for current connection MySqlXDL is pointing to.
  Function SelectDatabase(p_sa:AnsiString):Boolean;
  //--------------------------------------------------------------------------
  {}
  // returns true if current connection MySQLXDL is pointing to. This only
  // works if you follow recommendations - see "QResult" above.
  Function HaveResults: Boolean;
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
  Property Item_RowBuf: pointer read read_item_alpRowBuf Write write_item_alpRowBuf;
  //--------------------------------------------------------------------------
  {}
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
Var clsMYSQL: TCMYSQLDL;
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
//


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !@!TCMySqlItem
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor TCMySqlItem.Create;
//=============================================================================
Begin
  Inherited;
  lpQResult:=nil;
  pointer(alpRowBuf):=nil;
  bConnected:=False;
End;
//=============================================================================

//=============================================================================
Destructor TCMySqlItem.destroy;
//=============================================================================
Begin
  If lpQResult<>nil Then mysql_free_result(lpQResult);
  If bConnected Then mysql_close(lpPtr);
  Inherited;
End;
//=============================================================================

//=============================================================================
Function TCMySqlItem.ExecuteQuery(p_sa: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=mysql_query(lpPtr,PChar(p_sa))=0;
  If Result Then lpQResult:=mysql_store_result(lpPtr);
End;
//=============================================================================

//=============================================================================
// Works Just Like Execute Query except it executes the specified file if it
// can find it and load it.
Function TCMySqlItem.ExecuteQueryFromFile(p_sa: AnsiString):Boolean;
//=============================================================================
Var saData: AnsiString;
Begin
  Result := bLoadTextFile(p_sa, saData) and ExecuteQuery(saData);
End;
//=============================================================================

//=============================================================================
// Calls mysql_free_result for THIS connection
Procedure TCMySqlItem.DoneQuery;
//=============================================================================
Begin
  If HaveResults Then mysql_free_result(lpQResult);
  lpQResult:=nil;
End;
//=============================================================================

//=============================================================================
// Calls mysql_select_db for THIS connection
Function TCMySqlItem.SelectDatabase(p_sa:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=mysql_select_db(lpPtr,PChar(p_sa))=0;
End;
//=============================================================================

//=============================================================================
Function TCMySqlItem.HaveResults: Boolean;
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

Constructor TCMySQLDL.create;
Begin
  Inherited;
  mysql_init(PMySQL(@rMySql));
End;


//=============================================================================
Function TCMySqlDL.pvt_CreateItem: TCMySqlItem;
//=============================================================================
Begin
  Result:=TCMySqlItem.create;
End;
//=============================================================================

//=============================================================================
Procedure TCMySqlDL.pvt_DestroyItem(p_lp:pointer);
//=============================================================================
Begin
  TCMySqlItem(p_lp).destroy;
End;
//=============================================================================

//=============================================================================
Function  TCMySqlDL.read_item_lpQResult: pointer;
//=============================================================================
Begin
  Result:=TCMySqlItem(lpITem).lpQResult;
End;
//=============================================================================

//=============================================================================
Procedure TCMySqlDL.write_item_lpQresult(p_lpQresult: pointer);
//=============================================================================
Begin
  TCMySqlItem(lpITem).lpQResult:=p_lpQResult;
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.read_bConnected: Boolean;
//=============================================================================
Begin
  Result:=TCMySqlItem(lpItem).bConnected;
End;
//=============================================================================

//=============================================================================
Procedure TCMySqlDL.write_bConnected(p_bConnected: Boolean);
//=============================================================================
Begin
  TCMySqlItem(lpItem).bConnected:=p_bConnected;
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.ExecuteQuery(p_sa: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=TCMySQlItem(lpItem).ExecuteQuery(p_sa);
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.ExecuteQueryFromFile(p_sa: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=tCMySqlItem(lpItem).ExecuteQueryFromFile(p_sa);
End;
//=============================================================================


//=============================================================================
Procedure TCMySqlDL.DoneQuery;
//=============================================================================
Begin
  TCMySqlItem(lpItem).DoneQuery;
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.SelectDatabase(p_sa:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=TCMySQLItem(lpItem).SelectDatabase(p_sa);
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.HaveResults: Boolean;
//=============================================================================
Begin
  Result:=TCMySqlItem(lpitem).HAveResults;
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.Read_item_alpRowBuf: pointer;
//=============================================================================
Begin
  Result:=TCMySqlItem(lpItem).alpRowBuf;
End;
//=============================================================================

//=============================================================================
Procedure TCMySqlDL.Write_item_alpRowBuf(p_lp: pointer);
//=============================================================================
Begin
  TCMySqlItem(lpItem).alpRowBuf:=p_lp;
End;
//=============================================================================

//=============================================================================
Function TCMySqlDL.CreateConnection(
  p_saHost, p_saUser, p_saPasswd: AnsiString):Boolean;
//=============================================================================
Var lphost:pointer;
    lpUser:pointer;
    lpPasswd:pointer;
Begin
  AppendItem;
  If length(p_saHost)=0 Then lpHost:=nil Else lpHost:=pointer(p_saHost);
  If length(p_saUser)=0 Then lpUser:=nil Else lpUser:=pointer(p_saUser);
  If length(p_saPasswd)=0 Then lpPasswd:=nil Else lpPasswd:=pointer(p_saPasswd);
  //sagelog(1,'MYSql Item_lpPtr Before:'+inttostr(longword(item_lpPtr)));
  
  // MySql03 Method--begin
  //TCMySqlItem(lpItem).lpPtr:=mysql_connect(TCMySqlItem(lpItem).lpPtr,lpHost, lpUser, lpPasswd);
  //result:=TCMySqlItem(lpItem).lpPtr<>nil;
  // MySql03 Method--end
  

  
  
  //function mysql_real_connect(
  //  mysql:PMYSQL; 
  //  host:PChar; 
  //  user:PChar; 
  //  passwd:PChar; 
  //  db:PChar;
  //  port:dword; 
  //  unix_socket:PChar; 
  //  clientflag:dword):PMYSQL;
  // cdecl;external External_library name 'mysql_real_connect';
  TCMySqlItem(lpItem).lpPtr :=  
    mysql_real_connect(
      PMySQL(@rMySql),
      lpHost,
      lpUser,
      lpPasswd,
      nil,
      0,
      nil,
      0);

  Result:=TCMySqlItem(lpItem).lpPtr<>nil;
  
  

  //sagelog(1,'After:'+inttostr(longword(item_lpptr)));
  Connected:=Result;
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
