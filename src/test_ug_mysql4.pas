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
// Testing u01g_mysql04.pp
program test_ug_mysql4;
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
  mysql4,
  ug_common,
  ug_jegas,
  ug_mysql4;
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

  iMSecb4: integer;
  iMSecAfter: integer;
Begin
  iMSecb4:=iMsec;
  saDB:='test';
  saQuery:='';
  
  
  clsMySql:=TCMySqlDL.Create;
  Writeln('Made clsMySql Active');
  
  if clsMySql.CreateConnection('localhost','root','229156') then
  Begin
    Writeln('Connection Established');
    if not clsMySql.SelectDatabase(saDB) then 
    Begin
      Writeln (stderr,'Couldn''t select database:');
      Writeln (stderr,mysql_error(clsMySql.Item_lpptr));
    End
    else
    Begin
      Writeln('Selected Database "',saDB,'" successfully.');
      saQuery:='DROP TABLE IF EXISTS `smf_ads`';
      if not clsMySql.ExecuteQuery(saQuery) then
      Begin
        Writeln (stderr,'Query failed.');
        Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
      End
      else
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
          ') TYPE=MyISAM;                                               ';
        Writeln ('Executing query:',saQuery); 
        if not clsMySql.ExecuteQuery(saQuery) then
        Begin
          Writeln (stderr,'Query failed.');
          Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
        End
        else
        begin
          saQuery:='insert into smf_ads (`NAME`,`CONTENT`,`BOARDS`) VALUES (''SomeName'',''SomeContent'',''SomeBoard'')';
          Writeln ('Executing query:',saQuery); 
          if not clsMySql.ExecuteQuery(saQuery) then
          Begin
            Writeln (stderr,'Query failed.');
            Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
          End
          else
          begin          
            saQuery:='select NAME,CONTENT,BOARDS from smf_ads';
            Writeln ('Executing query:',saQuery); 
            if not clsMySql.ExecuteQuery(saQuery) then
            Begin
              Writeln (stderr,'Query failed.');
              Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
            End
            else
            begin          
              if not clsMySql.HaveResults then
              Begin
                Writeln ('Query returned nil result.');
              End
              else
              Begin
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
            end;
          end;
        end;
      End;
    End;
  End
  else
  Begin
    Writeln (stderr,'Couldn''t connect to MySQL.');
    Writeln (stderr,mysql_error(@clsMySql.rMySQL));
  End;  
  Writeln('Removing Connection!');
  clsMySql.DeleteItem;
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
