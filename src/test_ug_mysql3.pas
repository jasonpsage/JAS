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
// Purpose : Testing u03g_mysql03.pp
// Note    : FPC unit and mysql3 shared lib required
// Note    : LINK Failure will occur without them
program test_ug_mysql03;
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
  mysql3,
  ug_misc,
  ug_common,
  ug_jegas,
  ug_mysql3;
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
  saQuery:='select * from tblperm';
  
  
  clsMySql:=TCMySqlDL.Create;
  Writeln('Made clsMySql Active');
  
  if clsMySql.CreateConnection('localhost','root','') then
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
      Writeln ('Executing query:',saQuery); 
      if not clsMySql.ExecuteQuery(saQuery) then
      Begin
        Writeln (stderr,'Query failed.');
        Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
      End
      else
      Begin
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
            Write  ('(Id: ', rowbuf[0]);
            Write  (', Name: ', rowbuf[1]);
            Writeln(', Email : ', rowbuf[2],')');
            rowbuf := mysql_fetch_row(clsMySql.QResult);
          End;
          
          Writeln ('Freeing memory occupied by result set...');
          clsMySql.DoneQuery;
        End;
      End;
    End;
  End
  else
  Begin
    Writeln (stderr,'Couldn''t connect to MySQL.');
    Writeln (stderr,mysql_error(clsMySql.Item_lpPtr));
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
