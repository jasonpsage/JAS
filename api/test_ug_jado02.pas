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
{ }
// Test Various Components of the Jegas Database Layer
program test_ug_jado02;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_ug_jado02.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
Uses 
//=============================================================================
  ug_common,
  ug_jegas,
  ug_jado,
  sysutils;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
  //JADOR: JADO_RECORDSET;

//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
function bTest_A: boolean;
//=============================================================================
Var
  bOk:Boolean;
  saFilename: AnsiString;
  JADOC: JADO_CONNECTION;
Begin
  //eleteFile(csLOG_FILENAME_DEFAULT);
  saFilename:='.'+DOSSLASH+'data'+DOSSLASH+'mysql.dbc';
  JADOC:=JADO_CONNECTION.Create;
  writeln('File to load: '+saFilename);
  bOk:=JADOC.bLoad(saFilename);
  If bOk Then  writeln('Loaded!') else writeln('Load Failed');

  If bOk Then
  Begin
    with JADOC do begin
      writeln('//============================================================');
      writeln('Type JADO_CONNECTION = Class');
      writeln('//============================================================');
      writeln('ID..................: ',ID);//: string; // UID In jdconnection stored as string
      writeln('JDCon_JSecPerm_ID...: ',JDCon_JSecPerm_ID);//string;// UID of Required Permission
      writeln('u2DbmsID............: ',u8DbmsID);//word; {< Used to determine what DBMS for apps that want to
      // handle different DBMS app differently. This Value is ONLY a reference
      // so each instantiated connection has its own value to see what was used to
      // create it. By allowing each instantiated connection to hold this value,
      // applications (designed to be thread safe) can decipher what the underlying
      // dbms is without having to refer to the rtConnection structure that was used
      // to create it - whose values may change. This is a "memory" of what the DBMS
      // for this instant was/is.}
      writeln('sConnectionString...: ',sConnectionString);//AnsiString;
      //writeln('sDefaultDatabase...: ',sDefaultDatabase);
      writeln('sDefaultDatabase....: ',sDefaultDatabase);
      //if Errors.listCount>0 then writeln(Errors.saHTMLTable);
      writeln('Errors.ListCount....: ',Errors.listCount);
      //writeln('sProvider..........: ',sProvider);
      writeln('sProvider...........: ',sProvider);
      writeln('i4State.............: ',i4State,' ',JADO.sObjectState(i4State));
      writeln('sVersion............: ',sVersion);
      writeln('u8DriverID............: ',u8DriverID);//word;{< (0=ODBC) For when ODBC isn't the connection method,
      //which DBMS driver. This is a Direct Take off from the JADO.rtConnection
      //Connection Record Type. The values are the Same.}

      //writeln('saMyUsername:.......: ',saMyUserName);// String;//< GENERIC - Used by Open Connection
      //writeln('saMyPassword:.......: ',saMyPassword);//String;//< GENEgRIC - Used by Open Connection
      //writeln('saMyConnectString...: ',saMyConnectString);//< GENERIC - Used by Open Connection
      //writeln('saMyDatabase........: ',saMyDatabase);//< GENERIC - Used by Open Connection
      //writeln('saMyServer..........: ',saMyServer);//String;//< GENERIC - Used by Open Connection
      //writeln('u4MyPort............: ',u4MyPort);
      {$IFDEF ODBC}
      writeln('ODBCDBHandle........: ',UINT(ODBCDBHandle));//   : SQLHandle; //< For ODBC Connection
      writeln('ODBCStmtHandle......: ',UINT(ODBCStmtHandle));//SQLHSTMT;  //< Used for executing Commands, the RecordSet Object will uses this as well.
      {$ENDIF}
      writeln('sName...............: ',sName);//String;
      writeln('saDesc..............: ',saDesc);//AnsiString;
      writeln('sDSN................: ',sDSN);//AnsiString;
      writeln('sUserName..........: ',sUserName);//string;
      writeln('sPassword..........: ',sPassword);//String;
      writeln('sDriver.............: ',sDriver);//String; //< ODBC Driver Name (Win32 Specific Maybe)
      writeln('sServer.............: ',sServer);
      writeln('sDatabase...........: ',sDatabase);
      writeln('bConnected..........: ',sYesNo(bConnected));
      writeln('bConnecting.........: ',sYesNo(bConnecting));
      writeln('bInUse..............: ',sYesNo(bInUse));
      writeln('bFileBasedDSN.......: ',sYesNo(bFileBasedDSN));
      writeln('saDSNFileName.......: ',saDSNFilename);
      writeln('sConnectString.....:  ',sConnectionString);//ansistring;{< This is NOT part of the legacy rtConnection
      // structure. It is the actual connect string "compiled" from the various
      // datapoints stored above, like username, password, etc.}
      {}
      // If bJAS is set to true before opening this connection, and
      // JASTABLEMATRIX is nil, then it is instantiated and a query is
      // made to the connection after it opens to gather the table list from
      // a table named "jtable" that is JAS specific. This entire table is
      // recorded into the matrix for look ups germane to JAS internal operations
      // where the table name and it's ID in the system needs to be referred often.
      // Closing a connection will not change this classes contents however subsequent
      // connection opens will. If the class is already instatiated it will be emptied.
      // if the class has not yet been instatiated, it will be.
      // destruction of the class doesn't happen until the instance of JADO_CONNECTION
      // is destroyed.
      if bJAS and (JASTABLEMATRIX<>nil) then writeln('JASTABLEMATRIX ITEMS: ',JASTABLEMATRIX.ListCount);
      // used to indicate (when connection opened via OpenCon (which uses internal values
      // versus passed in ODBC connection info) should perform JAS specific tasks
      writeln('bJAS................: ',bJAS);
      writeln('//============================================================');
      writeln;
    end;


    writeln('Attempting to open the connection.');
    bOk:=JADOC.OpenCon;
    writeln('Back from opening the connection.');

    If not bOk Then
    Begin
      Writeln('bOpenCon Failed.');
      saFilename:='.'+DOSSLASH+'data'+DOSSLASH+'mysql-saved.dbc';
      deletefile(saFilename);
      If not JADOC.bSave(saFilename) Then
      Begin
        Writeln('unable to save:',saFilename);
      End
      Else
      Begin
        Writeln('Saved DBC File Successfully:',saFilename);
      End;
    End;
  End;
  JADOC.Destroy;
  result:=bOk;
end;


//=============================================================================
// Initialization
//=============================================================================
begin
//=============================================================================
   if not bTest_A then writeln('bTest_A Failed') else
     writeln('Passed');
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
