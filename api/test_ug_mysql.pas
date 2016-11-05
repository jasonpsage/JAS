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
{}
// Test MySQL API Libraries - Both MySQL4 and MySQL5 - Needs to be compiled
// to test one or the other. See MYSQL5 precompiler directive in:
//   i_jegas_macros.pp
//
program test_ug_mysql;
//=============================================================================

//=============================================================================
// Global Compiler Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$MODE objfpc}
{$PACKRECORDS 4}
{$SMARTLINK ON}
//=============================================================================


//=============================================================================
uses 
//=============================================================================
  {$IFNDEF MYSQL5}
  mysql4,
  ug_mysql4,
  {$ELSE}
  mysql5,
  ug_mysql5,
  {$ENDIF}
  ug_common,
  ug_jegas;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                               The Code
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
var 
  rowbuf : TMYSQL_ROW;
  saDB: AnsiString;
  saQuery: AnsiString;
  bOk: boolean;

  iMSecb4: integer;
  iMSecAfter: integer;
Begin
  iMSecb4:=iMsec;
  saDB:='test';
  saQuery:='';
  bOk:=true;

  {$IFNDEF MYSQL5}
  writeln('Configured to test the MYSQL5 API.');
  {$ELSE}
  writeln('Configured to test the MYSQL4 API.');
  {$ENDIF}

  clsMySql:=TCMySqlDL.Create;Writeln('Made clsMySql Active');
  
  bOk:=clsMySql.CreateConnection('localhost','root','root');
  if not bOk then
  begin
    //Writeln (stderr,'Couldn''t connect to MySQL.');
    //Writeln (stderr,mysql_error(@clsMySql.rMySQL));
    Writeln ('Couldn''t connect to MySQL.');
    Writeln (mysql_error(@clsMySql.rMySQL));
  end;

  if bOk then
  Begin
    Writeln('Connection Established');
    bOk:=clsMySql.SelectDatabase(saDB);
    if not bOk then
    begin
      Writeln (stderr,'Couldn''t select database:');
      Writeln (stderr,mysql_error(clsMySql.Item_lpptr));
    End;
  end;

  if bOk then
  begin
    Writeln('Selected Database "',saDB,'" successfully.');
    saQuery:='DROP TABLE IF EXISTS `smf_ads`';
    bOk:=clsMySql.ExecuteQuery(saQuery);
    if not bOk then
    begin
      //riteln (stderr,'Query failed.');
      //riteln (stderr,mysql_error(clsMySql.Item_lpPtr));
      Writeln ('Query failed.');
      Writeln (mysql_error(clsMySql.Item_lpPtr));
    end;
  end;

  if bOk then
  begin
    saQuery:=
      'CREATE TABLE `smf_ads` (                                     '+
      '  ADS_ID mediumint(8) unsigned NOT NULL auto_increment,      '+
      '  NAME tinytext NOT NULL,                                    '+
      '  CONTENT text NOT NULL,                                     '+
      '  BOARDS tinytext,                                           '+
      '  POSTS tinytext,                                            '+
      '  CATEGORY tinytext,                                         '+
      '  HITS mediumint(8) NOT NULL default 0,                      '+
      '  TYPE smallint(4) NOT NULL default 0,                       '+
      '  show_index smallint(4) NOT NULL default 0,                 '+
      '  show_board smallint(4) NOT NULL default 0,                 '+
      '  show_threadindex smallint(4) NOT NULL default 0,           '+
      '  show_lastpost smallint(4) NOT NULL default 0,              '+
      '  show_thread smallint(4) NOT NULL default 0,                '+
      '  show_bottom smallint(4) NOT NULL default 0,                '+
      '  show_welcome smallint(4) NOT NULL default 0,               '+
      '  show_topofpage smallint(4) NOT NULL default 0,             '+
      '  show_towerright smallint(4) NOT NULL default 0,            '+
      '  show_towerleft smallint(4) NOT NULL default 0,             '+
      '  show_betweencategories smallint(4) NOT NULL default 0,     '+
      '  show_underchildren smallint(4) NOT NULL default 0,         '+
      '  PRIMARY KEY (ADS_ID)                                       '+
      ');';
      //') TYPE=MyISAM;                                               ';
    Writeln ('Executing query:',saQuery);
    bOk:=clsMySql.ExecuteQuery(saQuery);
    if not bOk then
    Begin
      Writeln ('Query failed.');
      Writeln (mysql_error(clsMySql.Item_lpPtr));
    End;
  end;


  if bOk then
  begin
    saQuery:='insert into smf_ads (`NAME`,`CONTENT`,`BOARDS`) VALUES (''SomeName'',''SomeContent'',''SomeBoard'')';
    Writeln ('Executing query:',saQuery);
    bok:=clsMySql.ExecuteQuery(saQuery);
    if not bOk then
    Begin
      Writeln ('Query failed.');
      Writeln (mysql_error(clsMySql.Item_lpPtr));
    End;
  end;

  if bOk then
  begin
    saQuery:='select NAME,CONTENT,BOARDS from smf_ads';
    Writeln ('Executing query:',saQuery);
    bOk:=clsMySql.ExecuteQuery(saQuery);
    if not bOk then
    Begin
      Writeln ('Query failed.');
      Writeln (mysql_error(clsMySql.Item_lpPtr));
    end;
  end;

  if bOk then
  begin
    bOk:=clsMySql.HaveResults;
    if not bOk then
    begin
      Writeln ('Query returned nil result.');
    End;
  end;

  if bOk then
  begin
    Writeln('Got Results');
    Writeln ('Number of records returned  : ',mysql_num_rows (clsMySql.QResult));
    Writeln ('Number of fields per record : ',mysql_num_fields(clsMySql.QResult));
    rowbuf := mysql_fetch_row(clsMySql.QResult);
    while (rowbuf <>nil) do Begin
      Write  ('(NAME:', rowbuf[0]);
      Write  (', CONTENT:', rowbuf[1]);
      Writeln(', BOARD:', rowbuf[2],')');
      rowbuf := mysql_fetch_row(clsMySql.QResult);
    End;
    Writeln ('Freeing memory occupied by result set...');
    clsMySql.DoneQuery;
  End;
  Writeln('Removing Connection!');
  clsMySql.DeleteItem;//< Great for handling multiple connections ;)
  // or simply 
  clsMySql.Destroy;
  iMSecAfter:=iMsec;
  
  Writeln('Millsecs:',iMSecAfter-iMSecb4);
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
