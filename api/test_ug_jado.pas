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
program test_ug_jado;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_ug_jado.pas'}
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
  ug_jfc_xdl,
  ug_misc,
  sysutils;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
Var 
  JCMDXDL: JFC_XDL;
  saFilename: AnsiString;
  JADOC: JADO_CONNECTION;
  JADOR: JADO_RECORDSET;
  bVerbose: Boolean;
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
Function bTest_Connection: Boolean;
//=============================================================================
Begin
  // PErhaps here could
  //cnDriv_MySQL);
  //rCon.saDSN:='FOX MSI';
  //rCon.saDSN:='FOX FPC';
  //rCon.saDSN:='PROVIDER=MSDASQL;Driver=MySQL ODBC 3.51 Driver;Server=192.168.1.3;UID=root;PWD=229156;Database=Jegas;OPTION=133121;';
  //Writeln('Attempting open connection with: ',rCon.saDSN );
  writeln('Conection Opened: ', sYesNo(JADOC.OpenCon));
  Writeln('oADOC.i4State = ',JADOC.i4State);
  Write('JADOC.u8DrivID = ', JADOC.u8DriverID);
  JADOC:=JADO_CONNECTION.Create;
  Case JADOC.u8DriverID Of
  {$IFDEF ODBC}
  cnDriv_ODBC: Writeln('JADO ODBC Driver');
  {$ENDIF}
  cnDriv_MySQL: Writeln('JADO MySQL Driver');
  End;//case
  Result:=JADOC.OpenCon;
End;
//=============================================================================

{$IFDEF ODBC}
//=============================================================================
Procedure ShowODBCDataSources;
//=============================================================================
Begin
  Writeln('///////////////////////////////////////////////////////////////////////////////');
  Writeln('///  DATA SOURCES');
  Writeln('///////////////////////////////////////////////////////////////////////////////');
  JADO.ODBCLoadDataSources;
  Writeln(saFixedLength('Data Sources',1,39),' ',saFixedLength('Driver',1,39));
  Writeln(StringOfChar('-',79));
  JADO.ODBCDSNXDL.MoveFirst;
  While not JADO.ODBCDSNXDL.EOL Do Begin
    Writeln(saFixedLength(JADO.ODBCDSNXDL.Item_saName,1,39),' ',saFixedLength(JADO.ODBCDSNXDL.Item_saValue,1,39));
    JADO.ODBCDSNXDL.MoveNext;
  End;//while
  Writeln('///////////////////////////////////////////////////////////////////////////////');
End;
//=============================================================================
{$ENDIF}

{$IFDEF ODBC}
//=============================================================================
Function bTest_OpenRecordSet: Boolean;
//=============================================================================
Var saSQL: AnsiString;
Begin
  oADOR:=JADO_RECORDSET.Create;
  Write('Enter SQL Statement:');
  readln(saSQL);
  oADOR.Open(saSQL,oADOC);
  Result:=oADOR.i4State=adStateOpen;
End;
//=============================================================================
{$ENDIF}


{$IFDEF ODBC}
//=============================================================================
Function bTest_ODBCClose: Boolean;
//=============================================================================
Begin
  // This function uses the settings in Test_ODBC.dsn
  // To establish an ODBC Connection.
  oADOC.Close;
  Writeln('Just Closed ODBC Connection. oADOC.i4State = ',oADOC.i4State);
  Result:=oADOC.i4State = adStateClosed;
End;
//=============================================================================
{$ENDIF}





//=============================================================================
Procedure JegasJADOSplash;
//=============================================================================
Begin
  Writeln(';==============================================================================');
  Writeln(';|    _________ _______  _______  ______  ______| Welcome. This little test app');
  Writeln(';|   /___  ___// _____/ / _____/ / __  / / _____/ has evolved into a little    ');
  Writeln(';|      / /   / /__    / / ___  / /_/ / / /____ | console app for querying both');
  Writeln(';|     / /   / ____/  / / /  / / __  / /____  / | ODBC and MySQL4+ Databases.  ');
  Writeln(';|____/ /   / /___   / /__/ / / / / / _____/ /  |        www.jegas.org         ');
  Writeln(';/_____/   /______/ /______/ /_/ /_/ /______/   |  Copyright(C)2006-2016 Jegas ');
  Writeln(';|                 Under the Hood               |      All Rights Reserved     ');
  Writeln(';==============================================================================');
End;
//=============================================================================


//=============================================================================
Procedure FlushSessionFiles;
//=============================================================================
Var i: Integer;
s: String;
Begin
  For i:=1 To 999 Do Begin
    s:='jadoclu_session.'+sZeroPadInt(i,3)+'.txt';
    If FileExists(s) Then DeleteFile(s);
  End;
End;
//=============================================================================



//=============================================================================
Procedure Save_JCMDXDL;
//=============================================================================
Var
  fout: text;
  IOR: Word;
Begin
  If JCMDXDL.MoveFirst Then 
  Begin
    saFileName:=saSequencedFilename('jadoclu_session','txt');
    assign(fout, saFilename);
    {$I-}
    rewrite(fout);
    IOR:=IOResult;If IOR<>0 Then
    Begin Writeln(sIOResult(IOR));End;
    {$I+}
    
    If ior=0 Then
    Begin
      repeat
        {$I-}
        Writeln(fout, JCMDXDL.Item_saName);
        {$I+}
        IOR:=IOResult;If IOR<>0 Then
        Begin close(fout); Writeln(sIOResult(IOR));End;
      Until (IOR<>0) OR (not JCMDXDL.MoveNext);
    End;    
    
    If IOR=0 Then
    Begin
      {$I-}
      close(fout);
      IOR:=IOResult;If IOR<>0 Then
      Begin close(fout); Writeln(sIOResult(IOR));End;
      {$I+}
    End;   
  End;
End;
//=============================================================================

  
  
//=============================================================================
Procedure DisplayStatus;
//=============================================================================
Begin
  Writeln;
  Writeln('///////////////////////////////////////////////////////////////////////////////');
  Writeln('///  STATUS');
  Writeln('///////////////////////////////////////////////////////////////////////////////');
  Writeln('-----JADO.rtConnection BEGIN');
  Writeln;
  
  
  Write('SQL Dialect:');
  Case JADOC.u8DBMSID Of
  cnDBMS_Generic:       Write('Generic');
  cnDBMS_MSSQL:         Write('MSSQL');
  cnDBMS_MSAccess:      Write('Access');
  cnDBMS_MySQL:         Write('MySQL');
  cnDBMS_Excel:         Write('Excel');
  cnDBMS_dBase:         Write('dBase');
  cnDBMS_FoxPro:        Write('FoxPro');
  cnDBMS_Oracle:        Write('Oracle');
  cnDBMS_Paradox:       Write('Paradox');
  cnDBMS_Text:          Write('text');
  cnDBMS_PostGresSQL:   Write('PostGresSQL');
  cnDBMS_SQLite:        Write('SQLite');
  Else                  Write('Unknown');
  End;//case
  Write(' ');
  Writeln;

  Write('DriverID:');
  Case JADOC.u8DriverID Of
  0:            Write('Not Assigned');
  cnDriv_ODBC:   Write('JADO ODBC');
  cnDriv_MySQL: Write('JADO MySQL');
  Else           Write('Unknown');
  End;//case
  Write(' ');
  Writeln;

  Write('DBMSID:');
  Case JADOC.u8DriverID Of
  0:                  Write('Not Assigned');
  cnDBMS_Generic:     Write('Generic');
  cnDBMS_MSSQL:       Write('MSSQL');
  cnDBMS_MSAccess:    Write('MSACCESS');
  cnDBMS_MySQL:       Write('MySQL');
  cnDBMS_Excel:       Write('Excel');
  cnDBMS_dBase:       Write('dBase');
  cnDBMS_FoxPro:      Write('FoxPro');
  cnDBMS_Oracle:      Write('Oracle');
  cnDBMS_Paradox:     Write('Paradox');
  cnDBMS_Text:        Write('Text');
  cnDBMS_PostGresSQL: Write('Postgres');
  else write('Unknown Value:' + inttostr(JADOC.u8DriverID));
  End;//case
  Write(' ');
  Writeln;

  Write('Name:',JADOC.sName,' ');
  Writeln;
  
  Write('Desc:',JADOC.saDesc,' ');
  Writeln;
  
  Write('DSN:',JADOC.sDSN,' ');
  Writeln;
  
  Write('U:',JADOC.sUserName,' ');
  Writeln;
  Write('P:',JADOC.sPassword,' ');
  Writeln;
  Write('Driver:',JADOC.sDriver,' ');
  Writeln;
  Write('Server:',JADOC.sServer,' ');
  Writeln;
  Write('DataBase:',JADOC.sDatabase,' ');
  Writeln;
  
  {
  FirstConnect=2006-08-31 13:55:25
  LastConnect=2006-09-12 18:09:03
  }

  {
  ; If PermitTimeCheck flag is Set To False, any calls 
  ; To the JADO.TimeCheck routine are not performed.
  ; IMPORTANT: If you have Polling On For a Connection, but you have
  ;            PermitTimecheck=No, Then the software won't be able to tell if or
  ;            when the connection is dropped (e.g. service stopped). The Time-
  ;            Check mechanism is HOW the software discovers connection failure!
  PermitTimeCheck=Yes
  LastTimeCheck=2006-08-31 13:55:25
  }

  {          
  ;FileBased has To Do With the ODBC connection, not this File.
  FileBased=No 
  ; Filebased Databases are handled in this way during the actual connection:
  ; FIRST:  If the the Database Variable above has a value At all, that is the 
  ;         filename that is used For the database when the FileBased Variable 
  ;         above is Set To Yes.
  ; SECOND: If the Database Variable Above is EMPTY and the FileBased Variable
  ;         above is Set To Yes, Then the FileName Variable's value (below) is 
  ;         used. 
  ; Therefore (psuedo-code To demonstrate logic): 
  ; If FILEBASED=YES and DATABASENAME=SOMETHING Then
  ;   DataBaseFileToOpen=SOMETHING
  ; Else
  ;   DataBaseFileToOpen=FILENAME's VALUE
  ; End If
  }

  {
  Writeln('Last Save Filename:',rCon.saFileName,' ');
  Writeln('Connection TimeOut(ni):',rCon.i4ConnectionTimeOut,' ');
  Writeln('Command TimeOut(ni):',rcon.i4Commandtimeout,' ');          
  SetValidToFalseIfUnableToConnect=No 
  SetConnectToFalseIfUnableToConnect=No 
  }


  {
  ; The following EXECUTE External APPLICATION parameters are only
  ; acted upon when the a connection is attempted OR when a timecheck 
  ; is attempted and fails due To connectivity error(s). not when a 
  ; connection is closed purposely. This statement was/is True when this
  ; File was generated.
  ;
  ; NOTE: There are several command line parameters that can be passed 
  ; in the ExternalAppIf(No)Connect values that get expanded (like macros) 
  ; allowing context sensitive information To be evalulated. These Are 
  ; Case sensitive, see your documention For more details, but here are 
  ; a few that should be helpful without having To dig into the documentation
  ; first: 
  ; [@NAME@]  Name Of Connection Returned in Quotes "Like This"
  ; [@USERNAME@] not Returned in Quotes (Shouldn't have spaces anyways)
  ; [@SERVER@] not returned in quotes, could be text, IP address, etc.
  ; [@SCHEMAMASTERUID@] Returned as Numeric text Value.
  ExecExternalAppIfNoConnect=No 
  ExternalAppToExecuteIfNoConnect=
  ExecExternalAppIfConnect=No 
  ExternalAppToExecuteIfConnect=
  }

  {
  ; Set To True If you are unsure. There are valid reasons For this flag, 
  ; as you may have guessed, improperly used it can make problem solving 
  ; a nightmare. 
  ShowWarningDialogIfUnableToConnect=No 
  }
  
  {
  LogNoConnect=No 
  LogConnect=No 
  These values are observed by SchemaMaster, and are numeric.
  WinWidth=15090
  WinHeight=9945
  WinTop=3390
  WinLeft=1350
  These values are observed by SchemaMaster also. 
  WindowState=Normal
  DoNotPoll=Yes
  CloseConEachPoll=No 
  }
  //Write('SchemaMasterVersionID:',JADOC.i4SchemaMasterVersionID,' ');
  Writeln;
  Writeln('-----JADO.rtConnection END');
  Writeln; 
  ///////////////////////////////////////////////////////////////////////////////////
  Writeln;
  ///////////////////////////////////////////////////////////////////////////////////
  Write('Loaded File:',saFilename,' ');
  Writeln;
  Write('JADO_CONNECTION:');
  If JADOC=nil Then
  Begin
    Write('NIL');
  End
  Else
  Begin
    write(JADO.sObjectState(JADOC.i4State));
  End;
  Write(' ');
  Writeln;
  
  Write('JADO_RECORDSET:');
  If JADOR=nil Then
  Begin
    Write('NIL');
  End
  Else
  Begin
    write(JADO.sObjectState(JADOC.i4State));
  End;
  Writeln;
  Writeln('Verbose:',sOnOff(bVerbose));
  Writeln;
  Writeln('///////////////////////////////////////////////////////////////////////////////');
  Writeln;
  
End;








Procedure FileStuff;
Var 
  bDone: Boolean;
  saFile: AnsiString;
  bHandled: Boolean;
  saMySqlDbcFilename: ansistring;
  saODBCDbcFilename: ansistring;
Begin
  bDone:=False;
  bHandled:=False;
  saMySqlDbcFilename:='.'+DOSSLASH+'data'+DOSSLASH+'mysql.dbc';
  saODBCDbcFilename:='.'+DOSSLASH+'data'+DOSSLASH+'odbc.dbc';
  repeat
    bHandled:=False;
    Write('(?=help) File:');readln(saFile);saFile:=trim(saFile);
    JCMDXDL.AppendItem_saName(saFile);
    Writeln;
    If (safile='?') Then 
    Begin
      Writeln('File Commands');
      writeln('1 - Attempts to open: '+saMySqlDbcFilename);
      writeln('2 - Attempts to open: '+saOdbcDbcFilename);
      Writeln('?=Help Q=Quit - You may also just type a filename.');
      saFile:='';
      bHandled:=True;
    End;
        
    If not bHandled Then 
    Begin
      If (saFile='Q') OR (saFile='q') Then
      Begin
        bHandled:=True;
        Writeln('Back to Command Mode (Press Q Again to EXIT Application).');
        bDone:=True;
      End;
    End;
          
    If not bhandled Then
    Begin
      If saFile='1' Then
      Begin
        saFile:=saMySqlDbcFilename;
      End;
    End;
    
    If not bhandled Then
    Begin
      If saFile='2' Then
      Begin
        saFile:=saOdbcDbcFilename;
      End;
    End;
        
    If (not bDone) and (not bHandled) Then 
    Begin
      If FileExists(saFile) Then
      Begin
        If JADOC.bLoad(saFile) Then
        Begin
          Writeln(safile,' loaded successfully. You are back in command mode.');
          bDone:=True;
        End
        Else
        Begin
          Writeln(saFile, 'Did not load properly.');
        End;
      End    
      Else
      Begin
        Writeln(saFile,'  Does not exist. Command Not Recognized.');
      End;
    End;
  Until bDone;
End;



Procedure ShowJegasLog;
Var 
  saData: AnsiString;
  u2IOResult: Word;
Begin
  u2IOResult:=0;
  Writeln('----------------------------------------');
  If bLoadTextFile(csLOG_FILENAME_DEFAULT,saData,u2IOResult) Then
  Begin
    Writeln(saData);
  End
  Else
  Begin
    Writeln('Error:',sIOResult(u2IOResult));
  End;
  Writeln('----------------------------------------');
  Writeln;
End;


//=============================================================================
// Initialization
//=============================================================================
Var 
    bHandled: Boolean;
    bDone: Boolean;
    uTotalRows:Cardinal;
    uTotalCols: Cardinal;
    saCommand: AnsiString;
    //saConStr: AnsiString;
Begin
//=============================================================================
  bDone:=False;
  bHandled:=False;
  JADOC:=JADO_CONNECTION.create;
  JADOR:=nil;//JADO_RECORDSET.Create;
  saCommand:='';
  JCMDXDL:=JFC_XDL.Create;
  bVerbose:=False;  

  JegasJadoSplash;  
  repeat 
    bHandled:=False;
    Write('(?=help) Command:');readln(saCommand);saCommand:=trim(saCommand);
    JCMDXDL.AppendItem_saName(saCommand);    
    Writeln;
    
    If not bHandled Then 
    Begin
      If (saCommand='Q') OR (saCommand='q') Then
      Begin
        bHandled:=True;
        bDone:=True;
        Save_JCMDXDL;Writeln('Session File:',saFilename);
        Writeln('Good Bye! -=/JegaS\=-');
      End;
      
      If not bHandled Then 
      Begin
        If (saCommand='?') Then 
        Begin
          JegasJAdoSplash;
          Writeln;
          Writeln('JADO Command Line Utility Commands  (JADOCLU)');
          //Writeln('?=Help Q=Quit S=Status F=File C=Connection On/Off D=Driver ODBC/MySQL Toggle');
          Writeln('?=Help');
          Writeln('S=Status');
          Writeln('F=File'); 
          Writeln('C=Connection On/Off');

          {$IFDEF ODBC}
          Writeln('D=Driver ODBC/MySQL Toggle');
          Writeln('N=View DSN List');
          {$ELSE}
          writeln('Program was compiled with MySQL/MariaDB support, No ODBC');
          {$ENDIF}
          Writeln('K=Kill All Existing JADOCLU Session Files');
          Writeln('J=Show Jegas Log: '+ csLOG_FILENAME_DEFAULT);
          Writeln('R=Remove (delete) Jegas Log: ' + csLOG_FILENAME_DEFAULT);
          Writeln('V=Verbose On/Off');
          Writeln;
          Writeln('Q=Quit');
          Writeln;
          bHandled:=True;
        End;
      End;
      If (not bHandled) Then
      Begin
        If (saCommand='V') OR (saCommand='v') Then
        Begin
          bHandled:=True;
          bVerbose:=not bVerbose;
          Writeln('Verbose is now ' + sOnOff(bVerbose));
        End;
      End;          
      If (not bHandled) Then
      Begin
        If (saCommand='R') OR (saCommand='r') Then
        Begin
          bHandled:=True;
          If FileExists(csLOG_FILENAME_DEFAULT) Then
          Begin
            DeleteFile(csLOG_FILENAME_DEFAULT);
            Writeln('File: ' + csLOG_FILENAME_DEFAULT + ' successfully deleted.');
          End
          Else
          Begin
            Writeln('File: '+csLOG_FILENAME_DEFAULT+' Does not exist.');
            Writeln;
          End;
        End;
      End;          
      If (not bHandled) Then
      Begin
        If (saCommand='J') OR (saCommand='j') Then
        Begin
          bHandled:=True;
          ShowJegasLog;
        End;
      End;          
      If (not bHandled) Then
      Begin
        If (saCommand='K') OR (saCommand='k') Then
        Begin
          bHandled:=True;
          FlushSessionFiles;
        End;
      End;          

      {$IFDEF ODBC}
      If (not bHandled) Then
      Begin
        If (saCommand='N') OR (saCommand='n') Then
        Begin
          bHandled:=True;
          ShowODBCDataSources;
        End;
      End;          
      {$ENDIF}

      
      
      If not bHandled Then
      Begin
        If (saCommand='S') OR (saCommand='s') Then
        Begin
          bHandled:=True; DisplayStatus;
        End;
      End;  
        
      If not bHandled Then
      Begin
        If (saCommand='F') OR (saCommand='f') Then
        Begin
          bHandled:=True; FileStuff;
        End;
      End;
          
      If not bHandled Then
      Begin
        If (saCommand='C') OR (saCommand='c') Then
        Begin
          bHandled:=True;
          If JADOC=nil Then
          Begin
            writeln('JADOC is Nil.');
            //If bVerbose Then Writeln('Instantiating JADO Connection with i4DrivID:',rCon.i4DrivID);
            //JADOC:=JADO_Connection.create(rCon.i4DrivID, rCon.i4DBMSID);
            //If bVerbose Then Writeln('Building Connection String from JADO.rtConnection Record Structure "rCon"');
            //saConStr:=saBuildConnectString( 
            //  rCon.saDSN,
            //  rCon.saDriver,
            //  rCon.saServer,
            //  rCon.saUserName,
            //  rCon.saPassword,
            //  rCon.saDatabase,
            //  rCon.bFileBased,
            //  rcon.i4DrivID
            //);
            //If bVerbose Then Writeln('Connection String:',saConStr);
            //If bverbose Then Writeln('About to open connection with JADO_CONNECTION.Open(saConnectionStr)');
            //If JADOC.Open(saConSTR) Then
            //Begin
            //  Writeln('JADO Connection Now Open.');
            //End
            //Else
            //Begin
            //  Writeln('JADO_Connection.Open had Error(s). Returned FALSE.');
            //End;
          End
          Else
          Begin
            If JADOC.i4State<>adStateClosed then
            begin
              If bVerbose Then Writeln('Shutting Down JADO Connection. (Close)');
              If bVerbose Then Writeln('JADOC.i4State=adStateOpen Going to Close it now.');
              If JADOC.bClose Then
              Begin
                Writeln('JADO_CONNECTION is now Closed.');
              End
              Else
              Begin
                Writeln('JADO_CONNECTION.Close Had Error(s). Returned FALSE');
              End;
            End
            else
            begin
              //If bVerbose Then Writeln('About to Destroy JADO_CONNECTION and set it to NIL.');
              //JADOC.Destroy; JADOC:=nil;
              //If bVerbose Then Writeln('JADO_CONNECTION Class Destroyed.');
              If bVerbose Then Write('Opening Connection...');
              if JADOC.OpenCon then
              begin
                writeln('Done!');
              end
              else
              begin
                writeln('Unable to open connection.');  
              end;
            end;
          End;
        End;  
      End;      
            
      {$IFDEF ODBC}
      If not bHandled Then
      Begin
        If (saCommand='D') OR (saCommand='d') Then
        Begin
          bHandled:=True;
          If JADOC.u2DrivID=cnDriv_ODBC Then
            JADOC.u2DrivID:=cnDriv_MySQL
          Else
            JADOC.u2DrivID:=cnDriv_ODBC;
          Write('Driver Changed to:');
          Case JADOC.u2DrivID Of
          0:            Write('Not Assigned');
          cnDriv_ODBC:   Write('JADO ODBC');
          cnDriv_MySQL: Write('JADO MySQL');
          Else           Write('Unknown');
          End;//case
          If JADOC<>nil Then
          Begin
            Writeln(' You will need to toggle the connection off, then on (C=Connection On/Off) to see the results.');
          End
          Else
          Begin
            Writeln;
          End;
        End;
      End;
      {$ENDIF}
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      // PREPARE TO EXECUTE QUERY
      //////////////////////////////////////////////////////////////////////////////////////////////
      If not bHandled Then
      Begin
        If bVerbose Then Writeln('Preparing to Execute SQL Command');
        If (JADOC=nil) Then
        Begin
          Writeln('Connection Closed.');
          bHandled:=True;
        End;
        
        If not bHandled Then
        Begin
          If bVerbose Then Writeln('Checking if JADOC.i4State=adStateOpen');
          If (JADOC.i4State=adStateOpen) Then
          Begin
            If bVerbose Then Writeln('Checking if JADOR<>NIL (Is it Instantiated? Should NOT BE)');
            If JADOR<>nil Then
            Begin
              Writeln('JADO Recordset Instantiated - Shouldn''t be. hmmm...');
              Writeln('Connection (Msgs/Errors):', JADOC.Errors.ListCount);
              if JADOC.Errors.ListCount>1 then 
              begin
                JADOC.Errors.MoveFirst;
                repeat
                  writeln('ERR:'+JADO_ERROR(JADOC.errors.lpitem).saSource);
                until not JADOC.Errors.MoveNext;
              end;
              
              
              Writeln('Look At the Jegas Log file too. (J Command).');
              Writeln('I''ll try to force it closed.');
              If JADOR.i4State=adStateOpen Then
              Begin
                If not JADOR.Close Then
                Begin
                  Writeln('JADO_RECORDSET.Close Had Error(s). Returned FALSE.');
                  If bVerbose Then Writeln('Just Closed it, Is this JADO_RECORDSET.i4State = 0 ?? (Value:',Jador.i4State,')');
                  If bVerbose Then Writeln('Well, should be ok to play some more. I''m forcing it into oblivion.');
                  JADOR.Destroy;
                  JADOR:=nil;
                End;
              End
              Else
              Begin
                Writeln('JADO_RECORDSET.Closed.');
                JADOR.Destroy;
                Writeln('JADO_RECORDSET.Destroy''d');
                JADOR:=nil;
              End;
              bHandled:=True;
            End;

            If not bHandled Then
            Begin
              If bVerbose Then Writeln('Instantiating JADO_RECORDSET');
              JADOR:=JADO_RECORDSET.Create;
              If bVerbose Then Writeln('JADO_RECORDSET Instantiated.');
              
              If bVerbose Then Writeln('Checking if JADOR.i4State<>adStateCloseD (It SHOULD BE)');
              If JADOR.i4State<>adStateClosed Then
              Begin
                Writeln('RecordSet State Stuck Open - (JADOR.i4State<>adClosed) - Unable to execute command.');
                bHandled:=True;
              End;
              
              If not bHandled Then
              Begin
                bHandled:=True;
                If bVerbose Then Begin
                  Writeln('About to open JADO_RECORDSET with the following Command:');
                  Writeln('saCommand:',saCommand);
                End;
                
                If JADOR.Open(saCommand,JADOC,201602121431) Then
                Begin
                  If bVerbose Then Writeln('JADO_RECORDSET Open Command Executed.');
                  If JADOR.i4State<>adStateOpen Then
                  Begin
                    Writeln('RecordSet Not Open. (No Results?)');
                    Writeln('Connection (Msgs/Errors):', JADOC.Errors.ListCount);
                    if JADOC.Errors.ListCount>=1 then 
                    begin
                      JADOC.Errors.MoveFirst;
                      repeat
                        writeln('ERR '+ inttostr(JADOC.errors.n) +':'+ inttostr(JADO_ERROR(JADOC.errors.lpitem).u8Number) +' '+ JADO_ERROR(JADOC.errors.lpitem).saSource);
                      until not JADOC.Errors.MoveNext;
                    end;
                  End
                  Else
                  Begin
                    bHandled:=True;
                    uTotalCols:=JADOR.Fields.ListCount; uTotalRows:=0;
                    If bVerbose Then Writeln('JADO_RECORDSET has ',uTotalCols,' columns. So far ok.');
                    // Columns
                    Writeln;
                    Writeln('--------------------------------------------------------------------');
                    Writeln('RESULTS - JADOR.Fields.ListCount:',JADOR.Fields.ListCount);
                    Writeln('--------------------------------------------------------------------');
                    If JADOR.Fields.MoveFirst Then 
                    repeat Write(JADOR.Fields.Item_saName, #9); Until not JADOR.Fields.MoveNext; Writeln;
  
                    If bVerbose Then Writeln('Displayed Columns with JADO_RECORDSET.Fields.Item_saName Property.');
                    repeat
                      If (JADOR.Fields.MoveFirst) and (JADOR.u4RowsRead>0) Then 
                      repeat Write(JADOR.Fields.Item_saValue, #9); Until not JADOR.Fields.MoveNext; Writeln;
                      Inc(uTotalRows);
                    Until not JADOR.MoveNext;                
                    Writeln;
                    Writeln('--------------------------------------------------------------------');
                    Writeln('Records Read:',JADOR.u4RowsRead);
                    If bVerbose Then Writeln('Done Looping Through Data.');
                    If bVerbose Then 
                    Begin
                      Writeln('--------------------------------------------------------------------');
                    End;
                    //Writeln('Rows:',utotalRows, ' Columns:',uTotalCols);
                    If bVerbose Then Writeln('Closing JADO_RECORDSET Now.');
                    If not JADOR.Close Then
                    Begin
                      Writeln('JADO_RECORDSET.Close Returned with error(s). Returned FALSE.');
                    End;
                    If bVerbose Then Writeln('Destroying JADO_RECORDSET Now');
                    JadoR.destroy;
                    JAdoR:=nil;
                    If bVerbose Then Writeln('Destroyed JADO_RECORDSET and it set it to NIL');
                  End;
                End
                Else
                Begin
                  Writeln('RecordSet Wouldn''t Open. Returned False.');
                  Writeln('Connection (Msgs/Errors):', JADOC.Errors.ListCount);
                  if JADOC.Errors.ListCount>=1 then 
                  begin
                    JADOC.Errors.MoveFirst;
                    repeat
                      writeln('ERR '+ inttostr(JADOC.errors.n) +':'+ inttostr(JADO_ERROR(JADOC.errors.lpitem).u8Number) +' '+ JADO_ERROR(JADOC.errors.lpitem).saSource);
                    until not JADOC.Errors.MoveNext;
                  end;
                  JadoR.Destroy;
                  Jador:=nil;
                End;
              End;
            End;  
          End
          Else
          Begin
            Writeln('hmm... Connection should be open but its not.');
            Writeln('I''ve seen this situation when using the ODBC driver but the DataSource didn''t exist.');
          End;  
        End;  
      End;/////    End of the query stuff.    
      //////////////////////////////////////////////////////////////////////////////////////////////
    End;      
  Until bDone;      
  If JADOR<>nil Then
  Begin
    If JADOR.i4State=adStateOpen Then JADOR.Close;
    JADOR.Destroy;
    JADOR:=nil;
  End;
      
  If JADOC<>nil Then
  Begin
    If JADOC.i4State=adStateOpen Then JADOC.bClose;
    JADOC.Destroy;
    JADOC:=nil;
  End;
  
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
