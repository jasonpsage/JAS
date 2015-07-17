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
// We needed a FTP client that would do recursive downloads but wouldnt choke
// on the first error encountered such as seems to happen with NCFTP so we
// wrote this.
program jegasftp;
//=============================================================================


//=============================================================================
// Note: History at end of File
//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='jegasftp.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
Uses 
 sysutils
,ug_common
,ug_jegas
,FTPSend
,ug_jfC_tokenizer
,process
;
//=============================================================================

//=============================================================================
// NATIVE FTP SERVER COMMANDS
//=============================================================================
// ABOR ACCT ALLO APPE CDUP CWD  DELE EPRT EPSV FEAT HELP LIST MDTM MKD
// MODE NLST NOOP OPTS PASS PASV PORT PWD  QUIT REIN REST RETR RMD  RNFR
// RNTO SITE SIZE SMNT STAT STOR STOU STRU SYST TYPE USER XCUP XCWD XMKD
// XPWD XRMD
//=============================================================================

//=============================================================================
// Globals
//=============================================================================
var
  TK: JFC_TOKENIZER;
  FC: TFTPSend;
  saHost: ansistring;
  saPort: ansistring;
  saUsername: ansistring;
  saPassword: ansistring;
  bLoggedIn: boolean;
  bRestoreMode: boolean;
//=============================================================================

//=============================================================================
// !               delete          literal         prompt          send
// ?               debug           ls              put             status
// append          dir             mdelete         pwd             trace
// ascii           disconnect      mdir            [quit]            type
// bell            get             mget            quote           user
// binary          glob            mkdir           recv            verbose
// bye             hash            mls             remotehelp
// cd              help            mput            rename
// close           lcd             open            rmdir
//=============================================================================
                                                                        
//=============================================================================
// Not used yet:
//=============================================================================
// function RetrieveFile(const FileName: string; Restore: Boolean): Boolean; virtual;
// function StoreFile(const FileName: string; Restore: Boolean): Boolean; virtual;
// function StoreUniqueFile: Boolean; virtual;
// function AppendFile(const FileName: string): Boolean; virtual;
// function RenameFile(const OldName, NewName: string): Boolean; virtual;
// function FileSize(const FileName: string): integer; virtual;
// function NoOp: Boolean; virtual;
// function DeleteDir(const Directory: string): Boolean; virtual;
// function CreateDir(const Directory: string): Boolean; virtual;
// property DirectFile: Boolean read FDirectFile Write FDirectFile;
// property DirectFileName: string read FDirectFileName Write FDirectFileName;
// property FtpList: TFTPList read FFtpList;
// function FtpGetFile(const IP, Port, FileName, LocalFile,  User, Pass: string): Boolean;
// function FtpPutFile(const IP, Port, FileName, LocalFile, User, Pass: string): Boolean;
// function FtpInterServerTransfer(const FromIP, FromPort, FromFile, FromUser, FromPass: string; const ToIP, ToPort, ToFile, ToUser, ToPass: string): Boolean;
//=============================================================================

//=============================================================================
function saDataStream: ansistring;
//=============================================================================
begin
  result:='';
  setlength(result,FC.DataStream.Size);
  FC.DataStream.ReadBuffer(PCHAR(result)^, FC.DataStream.Size);
end;
//=============================================================================


//=============================================================================
procedure JegasFTP_Run;
//=============================================================================
var
  sa: ansistring;
  bOk: boolean;
  bDone: boolean;
  bHandled: boolean;
  saLocalFileName: ansistring;
  PROCESS: TPROCESS;
  saSrc: ansistring;
  saDest: ansistring;
begin
  {$IFDEF LINUX}
    write(saJegasLogoRawText(#10));
  {$ELSE}
    write(saJegasLogoRawText(#13#10));
  {$ENDIF}
  with grJegasCommon do writeln(saAppTitle,' v',saAppMajor,'.',saAppMinor,'.',saAppRevision);
  //writeln('Connected to: ',FC.DataIP,':',FC.DataPort);





  // TODO: Handle command Line Commands Here
  bOk:=FC.Login;
  bDone:=false;
  if bOk then
  begin
    Write('Checking Server for Resume Ability:');
    FC.BinaryMode:=true;
    write(FC.FullResult.text);

    writeln('Setting Passive Mode...Set!');
    FC.PassiveMode:=true;

    repeat
      bOk:=true;
      bHandled:=false;
      write(FC.TargetHost,': ',FC.GetCurrentDir,' >');
      readln(sa);
      TK.SetDefaults;
      TK.saWhiteSpace:=' '+#9;
      TK.saSeparators:=' '+#9;
      TK.saQuotes:='"';
      TK.bKeepDebugInfo:=true;
      TK.Tokenize(sa);
      TK.DumptoTextfile('jegasftp.tk.txt');
      if (not bHandled) and (TK.Listcount>0) then
      begin
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if TK.Listcount=1 then
        begin
          if (not bHandled) and ((upcase(TK.Item_saToken)='QUIT') or (upcase(TK.Item_saToken)='BYE'))then
          begin
            bHandled:=true;
            bDone:=true;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='LS') then
          begin
            bHandled:=true;
            bOk:=FC.List('',true);
            if bOk then
            begin
              writeln(sarepeatchar('-',78));
              write(saDataStream);
              writeln(sarepeatchar('-',78));
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandled) and ((upcase(TK.Item_saToken)='DISCONNECT') or (upcase(TK.Item_saToken)='CLOSE'))then
          begin
            bHandled:=true;
            bOk:=FC.LogOut;
            if bOk then
            begin
              bLoggedIn:=false;
              writeln(FC.FullResult.text);
              //writeln(FC.Resultcode,' ',FC.ResultString);
            end;
          end;

          if (not bHandled) and ((upcase(TK.Item_saToken)='PWD') or (upcase(TK.Item_saToken)='CD')) then
          begin
            bHandled:=true;
            writeln(FC.GetCurrentDir);
            //writeln(FC.FullResult.text);
          end;

          if (not bHandled) and (TK.Item_satoken='!') then
          begin
            bHandled:=true;
            PROCESS:=TProcess.Create(nil);
            {$IFDEF LINUX}
            Process.commandline:='sh';
            {$ELSE}
            Process.commandline:='cmd';
            {$ENDIF}
            Process.Execute;
            Process.WaitOnExit;
            Process.Destroy;Process:=nil;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='MKDIR') then
          begin
            bHandleD:=true;
            bOk:=false;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='DELETE') then
          begin
            bHandleD:=true;
            bOk:=false;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='GET') then
          begin
            bHandleD:=true;
            bOk:=false;
          end;


          if (not bHandled) and ((TK.Item_satoken='?')or(TK.Item_satoken='help')) then
          begin
            writeln(sarepeatchar('-',78));
            write('!',#9);
            write('?',#9);
            write('bye',#9);
            write('cd',#9);
            write('close',#9);
            write('delete',#9);
            write('disconnect',#9);
            writeln;//every 7
            write('help',#9);
            write('ls',#9);
            write('mkdir',#9);
            write('pwd',#9);
            write('quit',#9);
            write('rename',#9);
            write('rmdir',#9);
            writeln;//every 7
            //writeln;
            writeln(sarepeatchar('-',78));
          end;
        end;
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-

        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if (not bHandleD) and (TK.ListCount=2) then
        begin
          TK.MoveFirst;
          if (not bHandleD) and (upcase(TK.Item_saToken)='CD') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='.') then
            begin
              bHandleD:=true;
              writeln(FC.GetCurrentDir);
              //writeln(FC.FullResult.text);
            end;

            if (not bHandled) and (tk.Item_satoken='..') then
            begin
              bHandled:=true;
              bOk:=FC.ChangeToParentDir;
              //writeln(FC.FullResult.text);
            end;

            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.ChangeWorkingDir(tk.Item_saToken);
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='LS') then
          begin
            TK.MoveNext;
            if (not bHandled) and (upcase(TK.Item_saToken)='-L') then
            begin
              bHandled:=true;
              bOk:=FC.List('',false);
              if bOk then
              begin
                writeln(sarepeatchar('-',78));
                write(saDataStream);
                writeln(sarepeatchar('-',78));
              end;
              writeln(FC.FullResult.text);
            end;

            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.List(TK.Item_saToken,true);
              if bOk then
              begin
                writeln(sarepeatchar('-',78));
                write(saDataStream);
                writeln(sarepeatchar('-',78));
              end;
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandleD) and (upcase(TK.Item_saToken)='GET') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='*') then
            begin
              bHandleD:=true;
              writeln('TODO: GET ALL FILES in working directory.');
            end;

            if (not bHandled) then
            begin
              bHandled:=true;
              saLocalFilename:=TK.Item_saToken;
              //FC.DirectFile:=true;
              //FC.DirectFilename:=saLocalfilename;
              bOk:=FC.RetrieveFile(TK.Item_saToken, bRestoreMode);
              if bOk then
              begin
                writeln('Success! Local File would of been:',saLocalFilename);
              end;
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandleD) and (upcase(TK.Item_saToken)='DELETE') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='*') then
            begin
              bHandleD:=true;
              writeln('TODO: Delete all files in current working directory.');
              //writeln(FC.FullResult.text);
            end;

            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.DeleteFile(TK.Item_saToken);
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='MKDIR') then
          begin
            TK.MoveNext;
            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.CreateDir(TK.Item_saToken);
              writeln(FC.FullResult.text);
            end;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='RMDIR') then
          begin
            TK.MoveNext;
            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.DeleteDir(TK.Item_saToken);
              writeln(FC.FullResult.text);
            end;
          end;

        end;
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-


        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if (not bHandleD) and (TK.ListCount=3) then
        begin
          TK.MoveFirst;
          if (not bHandled) and (upcase(TK.Item_saToken)='LS') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='-l') then
            begin
              bHandled:=true;
              TK.MoveNext;
              bOk:=FC.List(TK.Item_saToken,false);
              if bOk then
              begin
                writeln(sarepeatchar('-',78));
                write(saDataStream);
                writeln(sarepeatchar('-',78));
              end;
              writeln(FC.FullResult.text);
            end
            else
            begin
              bOk:=false;
            end;
          end;

          if (not bHandleD) and (upcase(TK.Item_saToken)='GET') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='-R') then
            begin
              TK.MoveNext;
              if (not bHandled) and (TK.Item_saToken='*') then
              begin
                bHandled:=true;
                writeln('TODO: GET ALL FILES in specified directory and RECURSE!');
              end
              else
              begin
                bOk:=false;
              end;
            end
            else
            begin
              bOk:=false;
            end;
          end;

          if (not bHandleD) and (upcase(TK.Item_saToken)='DELETE') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='-R') then
            begin
              TK.movenext;
              if (not bHandled) and (TK.Item_saToken='*') then
              begin
                bHandled:=true;
                writeln('TODO: Delete all files in current working directory.');
                //writeln(FC.FullResult.text);
              end
              else
              begin
                bOk:=false;
              end;
            end
            else
            begin
              bOk:=false;
            end;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='RENAME') then
          begin
            TK.MoveNext;
            if (not bHandled) then
            begin
              saSrc:=TK.Item_saToken;
              TK.MoveNext;
              saDest:=TK.Item_saToken;
              bOk:=FC.Renamefile(saSrc, saDest);
              writeln(FC.FullResult.text);
            end;
          end;
        end;
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
      end;

      if (not bOk) or (not bHandled) and (TK.ListCount>0) then
      begin
        writeln('Unable to comply.');
      end;

    until bDone;
    writeln('Bye... Come back again! - Jegas, LLC - Virtually Everything IT(tm)');
  end;
end;
//=============================================================================


//=============================================================================
procedure JegasFTP_Init;
//=============================================================================
begin
  saPort:='21';
  saHost:='jegas.net';
  bLoggedIn:=false;
  bRestoreMode:=false;
  FC:=TFTPSEND.Create;
  FC.TargetHost:=saHost;
  FC.TargetPort:=saPort;
  TK:=JFC_TOKENIZER.create;
end;
//=============================================================================

//=============================================================================
procedure JegasFTP_Shutdown;
//=============================================================================
begin
  TK.Destroy;TK:=nil;
  FC.Destroy;FC:=nil;
end;
//=============================================================================

//=============================================================================
// MAIN
//=============================================================================
Begin
  //-- Set up Jegas Common Information about product
  with grJegasCommon do begin
    saAppTitle:='Jegas FTP';//<application title
    saAppProductName:='Jegas FTP';
    saAppMajor:='0';
    saAppMinor:='0';
    saAppRevision:='1';
  end;  
  JegasFTP_Init;
  JegasFTP_Run;
  JegasFTP_Shutdown;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
