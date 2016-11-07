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
// We needed a FTP client that would do recursive downloads but wouldnt choke
// on the first error encountered such as seems to happen with NCFTP so we
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
 classes
,sysutils
,ug_common
,ug_jegas
,FTPSend
,ug_jfC_tokenizer
,process
,dos
,ug_jfc_dir
,ug_jfc_xdl
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
const cnNestLimit=25;
var
  TK: JFC_TOKENIZER;
  FC: TFTPSend;
  //bLoggedIn: boolean;
  gbRestoreMode: boolean;
  gu2Line: word;
  gu2LinesPerPage: Word;
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
procedure writehelp();
//=============================================================================
begin
  writeln(sarepeatchar('-',78));
  writeln('Commands');
  writeln(sarepeatchar('-',78));
  writeln('!                           - Shell/Command Prompt');
  writeln('?                           - Help, but you knew that!');
  writeln('cd DirectoryName            - Change Directory on Server');
  writeln('lcd LocalDirectoryName      - Change directory on Local Machine');
  writeln('get     -r | * | FILENAME   - Get File(s) from Server');
  writeln('put     -r | * | FILENAME   - Put File(s) on the Server');
  writeln('ls  [ -l ]                  - Directory Listing. -l = details');
  writeln('lines #                     - Lines Per Page. # = Enter # of lines.');
  writeln('mkdir DirectoryName         - Make Directory');
  writeln('rmdir DirectoryName         - Remove Entire Directory');
  writeln('rm      -r | * | FILENAME   - Delete file(s)');
  writeln('rename Source Destination   - Rename File');
  writeln('quit,q or bye               - Guess.');
  writeln(sarepeatchar('-',78));
  writeln('Option Switches');
  writeln(sarepeatchar('-',78));
  writeln(' -r = process current directory and all the subdirectories.');
  writeln(' *  = process current directory. FILENAME = individual file.');
  writeln('      stopping and waiting for the user the press [ENTER].');
  writeln(' -r and * work on multiple files. You cannot combine options.');
  writeln(sarepeatchar('-',78));
end;
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
procedure DirectoryListing;
//=============================================================================
var
  TK2: JFC_Tokenizer;
  saData: ansistring;
begin
  saData:=saDataStream;
  writeln(sarepeatchar('-',78));
  if gu2LinesPerPage=0 then
  begin
    write(saData)
  end
  else
  begin
    TK2:=JFC_TOKENIZER.Create;
    TK2.sSeparators:=csCRLF;
    TK2.sWhiteSpace:=csCRLF;
    TK2.Tokenize(saData);
    gu2Line:=0;
    if TK.MoveFirst then
    begin
      repeat
        Writeln(TK.Item_saToken);
        gu2Line+=1;
        if gu2Line=gu2LinesPerPage then
        begin
          gu2Line:=0;
          Write('Press ANY KEY to Continue: ');
          writeln(saRepeatchar(#8,40));
          read;
        end;
      until not TK2.MoveNext;
    end;
    TK2.Destroy;
  end;
  writeln(sarepeatchar('-',78));
  writeln(FC.FullResult.text);



end;
//=============================================================================












//=============================================================================
//=============================================================================
//=============================================================================
// recurse stuff - begin
//=============================================================================
//=============================================================================
//=============================================================================





//----------------------------------------------------------
//
//        if gsCMD='PUT' then
//        begin
//          Dir:=JFC_DIR.Create;
//          Dir.saPath:='.';
//          Dir.bDirOnly:=false;
//          Dir.saFileSpec:='*';
//          Dir.bSort:=true;
//          Dir.bSortAscending:=true;
//          Dir.bSortCaseSensitive:=true;
//          Dir.bCalcCRC:=false;
//          Dir.bOutput:=true;// TODO: Turn this off when done debugging
//          Dir.LoadDir;
//          if Dir.MoveFirst then
//          begin
//            repeat
//              if NOT Dir.Item_bDir then
//              begin
//                FC.DataStream.LoadFromFile(saAppendSlash(p_saDir)+Dir.Item_saFilename);
//                bOk:=FC.StoreFile(filename-here,true);
//                if not bOk then
//                begin
//                  //riteln('Upload failed: '+TK.Item_saToken);
//                end;
//              end;
//            until not Dir.moveNext;
//          end;
//
//          Dir.Destroy;
//        end else
//
//        if gsCMD='RM' then
//        begin
//        end else writeln('Tell that guy to learn how to code :) ');
//      end;
//-------------------------------------------------------------

















var
  gsCMD: string[10];
  gbRecurse: boolean;
  gu4Nestlevel: cardinal;
  //gsaRelPath: ansistring;
  i4Pos: longint;

  //...........................
  //Dir:=JFC_DIR.Create;
  //with dir do begin
  //  saPath:=FExpand(p_saDir);
  //  bDirOnly:=false;
  //  saFileSpec:='*.*';
  //  bSort:=true;
  //  bSortAscending:=true;
  //  bSortCaseSensitive:=true;
  //  bCalcCRC:= false;
  //  bOutput:= true;
  //end;//with
  //...........................
function bDive(p_saDir: ansistring; p_saFullPath: ansistring):boolean;
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  sLocalPath,sLocalFileName,sLocalExt: string;
  TK: JFC_Tokenizer;
  Dir: JFC_DIR;
  FileXDL: JFC_XDL;

begin
  Writeln(csCRLF+'DIVE: ',p_saDir);
  bOk:=true;
  result:=false;
  TK:= JFC_TOKENIZER.Create;
  FileXDL:=JFC_XDL.Create;
  DIR:=JFC_DIR.Create;
  //DIR.bOutPut:=true;
  DIR.saPath:=p_saFullPath;


  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  if gsCMD='PUT' then
  begin
    writeln('bDive - Put Dir.saPath: '+Dir.saPath);
    Dir.LoadDir;
    if Dir.MoveFirst then
    begin
      writeln('DIR Load '+saRepeatchar('-',70));
      repeat
        //if NOT (DIR.Item_bDir and ((Dir.Item_saName = '.') or
        //   (Dir.Item_saName = '..'))) then
        if (Dir.Item_saName <> '.') AND (Dir.Item_saName <> '..') then
        begin
          FileXDL.AppendItem_saname(DIR.Item_saName);
          if DIR.Item_bDir then
          //begin
            FileXDL.Item_i8User:=1;// else //zero is default
            //writeln('[',DIR.Item_saName,']');
          //end
          //else
          //begin
          //  writeln(DIR.Item_saName);
          //end;
        end;// just skip the DOTS! :)
        // SYMLINK special treatment might be needed. not positive how that will
        // go sending to the server.
      until not DIR.MoveNExt;
      writeln(saREpeatchar('-',79));
    end
    else
    begin
      writeln('Empty Directory. Hmm. Not even the DOT? Hmmm... You got ripped!');
    end;
  end else
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER LOCAL DIR for PUT -=-=-=-=-=-=-=-=-=-==-=




  // BEGIN -=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  // BEGIN -=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  // BEGIN -=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  // BEGIN -=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  begin
    if bOk then
    begin
      write('GET FILE LIST...');
      bOk:=FC.List('',false);
      writeln('Done. bOK:'+sYesNo(bOK));
      if not bOk then
      begin
        Writeln('bDive - FC.List Failed.');
      end;
    end;

    sa:=saReverse(p_saDir);
    if rightstr(sa,1)=DOSSLASH then
    begin
      sa:=leftstr(sa, length(sa)-1);
    end;
    i4Pos:=pos(DOSSLASH,sa);
    if i4Pos>0 then
    begin
      sa:='.'+DOSSLASH+saReverse(leftstr(sa,i4Pos-1));
    end;
    writeln('bDive - Change Dir to: '+sa);
    bOk:=FC.ChangeWorkingDir(sa);
    writeln('bDive - Directory Change Successful:'+syesNo(bOk));
    if not bOk then
    begin
      Writeln('bDive - Unable to change to dive dir: ',sa);
    end;


    if bOk then
    begin
      if FC.FTPList.Count>0 then
      begin
        //---------------------------------
        // Populate FileXDL using the FTPSend Objects/iterator obj etc.
        //---------------------------------
        // In One Instance saw this clip a filename, shortened it erroneously
        // and stuffed that wrong name into FileXDL - so.. going to try
        // Text method - seeing how it spits out correct filenames...albeit raw text.
        //---------------------------------
        //if FC.FTPList.Count>0 then
        //begin
        //  for u4:=0 to FC.FTPList.Count-1 do
        //  begin
        //    writeln('Server: '+FC.FTPList.Items[u4].Filename);
        //    FileXDL.AppendItem_saName(FC.FTPList.Items[u4].Filename);
        //    if FC.FTPList.Items[u4].Directory then FileXDL.Item_i8User:=1;//zero is default
        //  end;
        //end;
        //---------------------------------

        //---------------------------------                              ___ snip
        // Populate FileXDL via Text Parsing                            |
        //---------------------------------                             V
        //          1         2         3         4         5         6         7         8         9
        // 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        //=============================================================================
        // drwxr-xr-x    3 jas        root             4096 Dec 31  1969 Choices
        // -rw-r--r--    1 jas        root              195 Sep 10 14:12 ForceStop-JAS
        //=============================================================================
        TK.sSeparators:=#13#10;
        TK.sWhiteSpace:=#13#10;
        TK.Tokenize(saDataStream);
        if TK.MoveFirst then
        begin
          repeat
            sa:=RightStr(JFC_TOKENITEM(TK.lpItem).saToken,length(JFC_TOKENITEM(TK.lpItem).saToken)-62);
            FileXDL.AppendItem_saName(sa);
            if LeftStr(JFC_TOKENITEM(TK.lpItem).saToken,1)='d' then FileXDL.Item_i8User:=1 else //zero is default
            if LeftStr(JFC_TOKENITEM(TK.lpItem).saToken,1)='l' then
            begin
              //  v--symlink name---V
              //  x-terminal-emulator -> /etc/alternatives/x-terminal-emulator
              //  /etc/alternatives/x-terminal-emulator >- x-terminal-emulator
              writeln;
              writeln('Symlink sa>'+sa+'<');                     //xzcmp -> xzdiff
              sa:=saReverse(sa);
              i4Pos:=pos('>-',sa);
              writeln('Symlink Reversed>'+sa+'< i4Pos: ',i4Pos); //ffidzx >- pmczx    8
              sa:=rightStr(sa,length(sa)-(i4Pos+2));
              writeln('Symlink name extract: '+sa); //pmczx
              sa:=saReverse(sa);
              writeln('Symlink name extract back to normal: '+leftStr(sa,i4Pos-1)); //xzcmp
              JFC_XDLITEM(FileXDL.lpItem).saName:=sa;
            end;
            writeln(FileXDL.Item_saName);
          until not TK.MoveNext;
        end;
        //---------------------------------
      end;
    end;
  end;
  //-=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=
  //-=-=-=-===-=-=-===-= GATHER SERVER DIR for GET -=-=-=-=-=-=-=-=-=-==-=



  if bOk then
  begin
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    if FileXDL.MoveFirst then
    begin
      repeat
        write('+A');
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        if FileXDL.Item_i8User=1 then // Directory?
        begin
          write('B');
          if gbRecurse then //and (FileXDL.Item_saName<>'System Volume Information') then
          begin
            write('C');
            if (gu4NestLevel<cnNestLimit) then
            begin
              write('D');
              gu4NestLevel+=1;
              sa:=saAddSlash(p_saDir)+FileXDL.Item_saName;

              //------------------
              if gsCMD='GET' then
              begin
                //--------------------------------
                // GET
                //--------------------------------
                write('E');
                if not fileexists(sa) then
                begin
                  write(' DIR: '+sa+' ');
                  bOk:=CreateDir(sa);
                  if not bOk then
                  begin
                    writeln('Create Directory Failed: '+sa);
                  end;
                end;
                //--------------------------------
                // GET
                //--------------------------------
              end else

              if gsCMD='PUT' then
              begin
                //--------------------------------
                // gsCMD='PUT'
                //--------------------------------
                bOk:=FC.CreateDir(FileXDL.Item_saName);
                if not bOk then
                begin
                  writeln('Unable to make subdirectory on Server: '+FileXDL.Item_saName);
                end;

                if bOk then
                begin
                  bOk:=fc.changeWorkingDir(FileXDL.Item_saName);
                  if not bOk then
                  begin
                    writeln('Unable to change to server directory: '+FileXDL.Item_saName);
                  end;
                  writeln('Server working DIR:'+FC.GetCurrentDir);
                end;
                //--------------------------------
                // gsCMD='PUT'
                //--------------------------------
              end;// else

              //if gsCMD='RMDIR' then
              //begin
              //end;

              if bOk then
              begin
                //--------------------------------
                // DIVE DEEPER
                //--------------------------------
                writeln('F Diving to: '+sa);
                writeln('DOS LOCAL PATH: '+saAddSlash(p_saFullPath)+saAddSlash(FileXDL.Item_saName));
                //write('Press ENTER: ');readln;
                write('Working...');
                bOk:=bDive(sa, saAddSlash(p_saFullPath)+FileXDL.Item_saName);
                write(saRepeatchar(#8,80));
                write(saRepeatchar(' ',10));
                write(saRepeatchar(#8,80));
                gu4NestLevel-=1;
                //--------------------------------
                // DIVE DEEPER
                //--------------------------------
              end;

              if bOk then //and (gsCmd='PUT') then
              begin
                bOk:=fc.changeWorkingDir('..');
                if not bOk then
                begin
                  writeln('Unable to go up to parent directory.');
                end;
                writeln('working DIR after dive and cd .. --> '+FC.GetCurrentDir);
              end;
            end;
          end;
        end else
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-
        // -0-0-0-0-0-0-0-0- DIRECTORY -0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-




        //=-=-=-=-=-=-=-===-=-
        if gsCMD='GET' then
        //=-=-=-=-=-=-=-===-=-
        begin
          write('G');
          //sa:=saAddSlash(gsaRelPAth)+FileXDL.Item_saName;
          sa:=saAddSlash(p_saDir)+FileXDL.Item_saName;
          FSplit(sa,sLocalPath,sLocalFileName,sLocalExt);
          FC.DirectFile:=true;
          FC.DirectFilename:=saAddSlash(p_saDir)+sLocalfilename+sLocalExt;
          writeln('get ',FC.DirectFilename, ' Src: '+FileXDL.Item_saName);
          write(' [ '+sa+' ] ');
          //bOk:=FC.RetrieveFile(sa, gbRestoreMode);
          writeln(sa);
          bOk:=FC.RetrieveFile( FileXDL.Item_saName, gbRestoreMode);
          //riteln('begot? bOk:'+sYesNo(bOK)+' File: '+FC.DirectFilename);
          //writeln(']');// Ok:'+sYesNo(bOk));
          if not bOk then
          begin
            Writeln('bDive - FC.RetrieveFile('+sa+', restore mode: '+sYesNo(gbRestoreMode)+' Failed.');
          end;
        end else
        //=-=-=-=-=-=-=-===-=-

        //=-=-=-=-=-=-=-===-=-
        if gsCMD='PUT' then
        //=-=-=-=-=-=-=-===-=-
        begin
          write('H');
          sa:=saAddSlash(p_saFullPath)+FileXDL.Item_saName;
          writeln(' ^ '+sa+' ^ ');
          bOk:=FileExists(sa);
          if not bOk then
          begin
            Writeln('File Not Found : ' + sa);
          end;
          if bOk then
          begin
            write('I');
            FC.DataStream.LoadFromFile(sa);
            write('J');
          end;

          write('K');

          if bOk then
          begin
            write('L');
            bOK:=FC.StoreFile(FileXDL.ITem_saName,true);
            write('M');
            if not bOk then
            begin
              writeln('Upload failed: '+FileXDL.ITem_saName);
            end;
          end;
        end else
        //=-=-=-=-=-=-=-===-=-




        //=-=-=-=-=-=-=-===-=-
        // RM
        //=-=-=-=-=-=-=-===-=-
        begin
          bOk:=false;
          FC.DeleteFile(FileXDL.ITem_saName);
        end;
        //=-=-=-=-=-=-=-===-=-


        //writeln('Items[u4].Filename: ',FC.FTPList.Items[u4].Filename, ' directory: ',sYesNo(FC.FTPList.Items[u4].Directory));
        if not bOK then exit;
      until not FileXDL.moveNext;
    end;
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-
    // =-=-=-=-=-=-=-=-=-= Process directories and files in FileXDL =-=-=-=-

  end;
  //if gu4NestLevel>=1 then FC.ChangeWorkingDir('..');
  FileXDL.Destroy;
  Dir.Destroy;
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================











//=============================================================================
function bSpecialCommand(p_sCmd: string; p_bRecurse: boolean): boolean;
//=============================================================================
//var bOk: boolean;
begin
  gsCmd:=p_sCmd;
  gbRecurse:=p_bRecurse;
  //gsaRelPath:='.';
  gu4NestLEvel:=0;
  result:=bDive('.',fExpand('.'));
end;
//=============================================================================












//=============================================================================
//TFTPListRec
//=============================================================================
//    property FileName: string read FFileName write FFileName;
//    {:if name is subdirectory not file.}
//    property Directory: Boolean read FDirectory write FDirectory;
//    {:if you have rights to read}
//    property Readable: Boolean read FReadable write FReadable;
//    {:size of file in bytes}
//    property FileSize: Longint read FFileSize write FFileSize;
//    {:date and time of file. Local server timezone is used. Any timezone
//     conversions was not done!}
//    property FileTime: TDateTime read FFileTime write FFileTime;
//    {:original unparsed line}
//    property OriginalLine: string read FOriginalLine write FOriginalLine;
//    {:mask what was used for parsing}
//    property Mask: string read FMask write FMask;
//    {:permission string (depending on used mask!)}
//    property Permission: string read FPermission write FPermission;
//=============================================================================




//=============================================================================
//TFTPLIST
//=============================================================================
//
//    {:Constructor. You not need create this object, it is created by TFTPSend
//     class as their property.}
//    constructor Create;
//    destructor Destroy; override;
//
//    {:Clear list.}
//    procedure Clear; virtual;
//
//    {:count of holded @link(TFTPListRec) objects}
//    function Count: integer; virtual;
//
//    {:Assigns one list to another}
//    procedure Assign(Value: TFTPList); virtual;
//
//    {:try to parse raw directory listing in @link(lines) to list of
//     @link(TFTPListRec).}
//    procedure ParseLines; virtual;
//
//    {:By this property you have access to list of @link(TFTPListRec).
//     This is for compatibility only. Please, use @link(Items) instead.}
//    property List: TList read FList;
//
//    {:By this property you have access to list of @link(TFTPListRec).}
//    property Items[Index: Integer]: TFTPListRec read GetListItem; default;
//
//    {:Set of lines with RAW directory listing for @link(parseLines)}
//    property Lines: TStringList read FLines;
//
//    {:Set of masks for directory listing parser. It is predefined by default,
//    however you can modify it as you need. (for example, you can add your own
//    definition mask.) Mask is same as mask used in TotalCommander.}
//    property Masks: TStringList read FMasks;
//
//    {:After @link(ParseLines) it holding lines what was not sucessfully parsed.}
//    property UnparsedLines: TStringList read FUnparsedLines;
//=============================================================================


//=============================================================================
//=============================================================================
//=============================================================================
// recurse stuff - end
//=============================================================================
//=============================================================================
//=============================================================================



















//=============================================================================
procedure JegasFTP_Run;
//=============================================================================
var
  sa: ansistring;
  bOk: boolean;
  bDone: boolean;
  bHandled: boolean;

  sLocalPath: string;
  sLocalFileName: string;
  sLocalExt: string;

  PROCESS: TPROCESS;
  saSrc: ansistring;
  saDest: ansistring;
begin
  with grJegasCommon do writeln(sAppTitle,' Version: '+sVersion);
  //saPath:='.';

  // TODO: Handle command Line Commands Here
  bOk:=FC.Login;
    // DEBUG ====
    // if you want to display for debug use these
    // FC.TargetHost
    // FC.TargetPort
    // FC.Username
    // DEBUG ====

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
      writeln;
      writeln('Local Working Directory: '+FExpand('.'));
      write(FC.TargetHost,': ',FC.GetCurrentDir,' >');
      readln(sa);
      TK.SetDefaults;
      TK.sWhiteSpace:=' '+#9;
      TK.sSeparators:=' '+#9;
      TK.sQuotes:='"';
      TK.bKeepDebugInfo:=true;
      TK.Tokenize(sa);
      //TK.DumptoTextfile('jegasftp.tk.txt');
      if (TK.Listcount>0) then
      begin
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if TK.Listcount=1 then
        begin
          if (not bHandled) and ((upcase(TK.Item_saToken)='QUIT') or (upcase(TK.Item_saToken)='Q') or (upcase(TK.Item_saToken)='BYE'))then
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
              if gu2LinesPerPAge=0 then write(saDataStream) else DirectoryListing;
              writeln(sarepeatchar('-',78));
              writeln(FC.FullResult.text);
            end;
          end;

          //if (not bHandled) and ((upcase(TK.Item_saToken)='DISCONNECT') or (upcase(TK.Item_saToken)='CLOSE'))then
          //begin
          //  bHandled:=true;
          //  bOk:=FC.LogOut;
          //  if bOk then
          //  begin
          //    //bLoggedIn:=false;
          //    writeln(FC.FullResult.text);
          //    //writeln(FC.Resultcode,' ',FC.ResultString);
          //  end;
          //end;

          //if (not bHandled) and ((upcase(TK.Item_saToken)='PWD') or (upcase(TK.Item_saToken)='CD')) then
          //begin
          //  bHandled:=true;
          //  writeln(FC.GetCurrentDir);
          //  //writeln(FC.FullResult.text);
          //end;

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

          if (not bHandled) and (upcase(TK.Item_saToken)='RM') then
          begin
            bHandleD:=true;
            bOk:=false;
          end;

          if (not bHandled) and (upcase(TK.Item_saToken)='GET') then
          begin
            bHandleD:=true;
            bOk:=false;
          end;


          if (not bHandled) and ((TK.Item_satoken='?')or(UPCASE(TK.Item_satoken)='HELP')) then
          begin
            bHandled:=true;
            WriteHelp();
          end;
        end;
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-

        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if (not bHandleD) and (TK.ListCount=2) then
        begin
          TK.MoveFirst;
          if (not bHandled) and (upcase(TK.Item_saToken)='CD') then
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
          end else

          if (not bHandled) and (upcase(TK.Item_saToken)='LCD') then
          begin
            TK.MoveNext;
            bHandled:=true;
            write('I');
            bOK:=true;
            try
              chdir(tk.Item_saToken);
            except on E:Exception do
            begin
              bOk:=false;
            end;//except;
            end;//try
            //f bOk then Writeln('Switch to DIR: ',tk.Item_saToken)
          end else



          if (not bHandled) and (upcase(TK.Item_saToken)='LINES') then
          begin
            bHandled:=true;
            TK.MoveNext;
            gu2LinesPerPage:=u8Val(TK.Item_saToken);
          end else



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
                if gu2LinesPerPAge=0 then
                begin
                  write(saDataStream)
                end
                else
                begin
                  DirectoryListing;
                end;
                writeln(sarepeatchar('-',78));
                writeln(FC.FullResult.text);
              end;
            end else

            if (not bHandled) then
            begin
              bHandled:=FC.List(TK.Item_saToken,true);
              if bHandled then
              begin
                writeln(sarepeatchar('-',78));
                write(saDataStream);
                writeln(sarepeatchar('-',78));
              end;
              writeln(FC.FullResult.text);
            end;
          end else

          if (not bHandleD) and (upcase(TK.Item_saToken)='GET') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='*') then
            begin
              bHandled:=bSpecialCommand('GET', false);
            end else

            if (not bHandled) and (upcase(TK.Item_saToken)='-R') then
            begin
              bHandled:=bSpecialCommand('GET', true);
            end else


            if (not bHandled) then
            begin
              bHandled:=true;
              sa:=TK.Item_saToken;
              FSplit(sa,sLocalPath,sLocalFileName,sLocalExt);
              FC.DirectFile:=true;
              FC.DirectFilename:=sLocalfilename+sLocalExt;
              writeln('GET Filename TK current Item: ',TK.Item_saToken, ' Restore Mode: ',sYesNo(gbRestoreMode));
              bOk:=FC.RetrieveFile(TK.Item_saToken, gbRestoreMode);
              if bOk then
              begin
                writeln('Success! Local File would of been: ',sLocalFilename);
              end;
              writeln(FC.FullResult.text);
            end;
          end else

          // function FtpPutFile(const IP, Port, FileName, LocalFile, User, Pass: string): Boolean;
          if (not bHandleD) and (upcase(TK.Item_saToken)='PUT') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='*') then
            begin
              bHandled:=bSpecialCommand('PUT', false);
            end else
            if (not bHandled) and (upcase(TK.Item_saToken)='-R') then
            begin
              bHandled:=bSpecialCommand('PUT', true);
            end else
            begin
              writeln('-=-=Single Put Begin=-=-=-=');
              bHandled:=FileExists(Tk.Item_saToken);
              if bHandled then
              begin
                FC.DataStream.LoadFromFile(Tk.Item_saToken);
                writeln('-=-=Single Put Middle=-=-=-=');
                bHandled:=FC.StoreFile(Tk.Item_saToken,true);
                if not bHandled then
                begin
                  writeln('Upload failed: '+TK.Item_saToken);
                end;
              end
              else
              begin
                Writeln('File Not Found: '+TK.Item_saToken);
              end;
              writeln('-=-=Single Put End=-=-=-=');
            end;
          end else


          if (not bHandleD) and (upcase(TK.Item_saToken)='RM') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='*') then
            begin
              bHandled:=bSpecialCommand('DELETE', false);
            end else

            if (not bHandled) and (UPCASE(TK.Item_saToken)='-R') then
            begin
              bHandled:=bSpecialCommand('DELETE', true);
            end else

            if (not bHandled) then
            begin
              bHandled:=true;
              bOk:=FC.DeleteFile(TK.Item_saToken);
              if not bOk then
              begin
                writeln('Unable to Delete: '+TK.Item_saToken);
              end;
              writeln(FC.FullResult.text);
            end;
          end else

          if (not bHandled) and (upcase(TK.Item_saToken)='MKDIR') then
          begin
            TK.MoveNext;
            if (not bHandled) then
            begin
              bHandled:=FC.CreateDir(TK.Item_saToken);
              writeln(FC.FullResult.text);
            end;
          end else

          if (not bHandled) and (upcase(TK.Item_saToken)='RMDIR') then
          begin
            TK.MoveNext;
            if (not bHandled) then
            begin
              bHandled:=FC.ChangeWorkingDir(tk.Item_saToken);
              if bHandled then
              begin
                bHandled:=bSpecialCommand('DELETE', true);
                if not bHandled then writeln(FC.FullResult.text);
                bHandled:=FC.ChangeToParentDir;
                if not bHandled then writeln(FC.FullResult.text);
              end;

              if bHandled then
              begin
                bHandled:=FC.DeleteDir(TK.Item_saToken);
                if not bHandled then writeln(FC.FullResult.text);
              end;
            end;
          end;
        end;
        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-


        //=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-===-=-=-=-==-=-=-=-=-=-
        if (not bHandleD) and (TK.ListCount=3) then
        begin
          TK.MoveFirst;
          if (not bHandleD) and (upcase(TK.Item_saToken)='GET') then
          begin
            TK.MoveNext;
            bHandled:=true;
          end;

          if (not bHandleD) and (upcase(TK.Item_saToken)='RM') then
          begin
            TK.MoveNext;
            if (not bHandled) and (TK.Item_saToken='-R') then
            begin
              bHandled:=true;
              writeln('TODO: Delete all files RECURSIVELY in current working directory.');
            end
            else
            begin
              TK.MoveNExt;
              fc.DeleteFile(TK.Item_saName);
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
              bHandled:=true;
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
  TK:=nil;FC:=nil;
  {$IFDEF LINUX}
    write(saJegasLogoRawText(#10));
  {$ELSE}
    write(saJegasLogoRawText(#13#10));
  {$ENDIF}
  //riteln('ParamCount:',ParamCount);
  gu4NestLevel:=0;
  gu2LinesPerPage:=0;
  gu2Line:=0;
  if (paramcount=2) or (paramcount=4) then
  begin
    gbRestoreMode:=false;
    TK:=JFC_TOKENIZER.create;
    FC:=TFTPSEND.Create;
    FC.TargetHost:=paramstr(1);
    FC.TargetPort:=paramstr(2);
    FC.Username :=paramstr(3);
    FC.Password :=paramstr(4);
  end
  else
  begin
    writeln;
    writeln('HELP:');
    writeln('jegasftp [HOST] [PORT] ( [USERNAME] [PASSWORD] )');
    // Parse Command Line and show help or connect and let user
    // start ftp'n.
  end;


  //bLoggedIn:=false;
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
    sAppTitle:='Jegas FTP';//<application title
    sAppProductName:='Jegas FTP';
    sVersion:='2016-09-29';
  end;
  JegasFTP_Init;
  if FC<>nil then
  begin
    JegasFTP_Run;
    JegasFTP_Shutdown;
  end;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
