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
// Test Jegas Filesystem
program test_ug_jfilesys_01;
//=============================================================================

                                                                      
//=============================================================================
// Global Directives                                                  
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='test_uxxg_jfilesys_01.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}                                                      
{$MODE objfpc}                                                        
//=============================================================================


                                                                      
//=============================================================================
uses                                                                  
//=============================================================================
  ug_common
 ,ug_jfilesys
 ,dos
 ;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
var 
  rJFSFile: rtJFSFile;
  ch: char;


procedure aout;
var t: integer;
  p: pointer;
Begin
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='!testfile.bin';
  rJFSFile.u1Mode:=cnJFSMode_Write;
  Writeln;
  Writeln('Opened:',bJFSOpen(rJFSFile),' Working...');
  for t:=1 to 1000000 do Begin
    p:=lpJFSCurrentRecord(rJFSFile);
    rtJFsHdr(p^).u4RecType:=cnJFS_RecType_Header;
    //Write('p:                      ',LongWord(p),'  ');
    //Writeln('rtJFsHdr(p^).u4RecType: ',rtJFsHdr(p^).u4RecType);
    if not bJFSFastAppend(rJFSFile) then Break;
    //Writeln('Wrote:',t);
  End;
  Writeln('Records Written:',t);
  Writeln('Closed:',bJFSClose(rJFSFile));
End;

procedure ain;
var i4RecordsRead: LongInt;
bSuccess: boolean;
Begin
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='!testfile.bin';
  rJFSFile.u1Mode:=cnJFSMode_Read;
  //riteln('BEFORE OPEN READMODE');
  //eBugJFSFile(rJFSFile);
  Writeln('Opened:',bJFSOpen(rJFSFile));
  //eBugJFSFile(rJFSFile);
  
  Writeln ('READING BEGIN--------');
  bSuccess:=true;
  i4RecordsRead:=0;
  repeat 
    //eBugJFSFile(rJFSFile);
    bSuccess:=bJfsFastRead(rJFSFile);
    if bSuccess then 
    Begin
      i4RecordsRead+=1;
    End;
  until not bSuccess;
  
  Writeln ('READING DONE--------');
  //eBugJFSFile(rJFSFile);
  Writeln('Records Read:',i4RecordsRead);
  Writeln('Closed:',bJFSClose(rJFSFile));
End;

procedure aboth;
Begin
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='!testfile.bin';
  rJFSFile.u1Mode:=cnJFSMode_ReadWrite;
  //riteln('BEFORE OPEN READMODE');
  //eBugJFSFile(rJFSFile);
  Writeln('Opened:',bJFSOpen(rJFSFile));
  //eBugJFSFile(rJFSFile);
  
  Writeln ('READING BEGIN--------');
  while bJfsFastRead(rJFSFile) do Begin
    //eBugJFSFile(rJFSFile);
  End;
  Writeln ('READING DONE--------');
  Writeln('Records Read:',rJFSFile.u4Row);
  Writeln('Closed:',bJFSClose(rJFSFile));
End;


procedure rawout;
var t: integer;
  ch: array [0..500] of char;
  //sa: AnsiString;
  p:pointer;
  u4HowMany: LongWord; 
  bResult: boolean;
  u4Bytes: LongWord;
Begin
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='!testfile.bin';
  rJFSFile.u1Mode:=cnJFSMode_Write;
  Writeln;
  Writeln('Opened:',bJFSOpen(rJFSFile));
   

  for t:=0 to (500 div 8) do Begin
    ch[t*(8)+0]:='0';
    ch[t*(8)+1]:='1';
    ch[t*(8)+2]:='2';
    ch[t*(8)+3]:='3';
    ch[t*(8)+4]:='4';
    ch[t*(8)+5]:='5';
    ch[t*(8)+6]:='6';
    ch[t*(8)+7]:='7';
  End;
  
  u4HowMany:=126;
  Writeln('We are going to write ',u4HowMany, ' bytes out.');
  u4Bytes:=u4HowMany;
  if u4Bytes>500 then u4Bytes:=500; // to prevent going past the allocated 
  //                                   array size in this test
  for t:=0 to u4Bytes-1 do Write(ch[t]);
  Writeln; 

    
  p:=@ch;
  bresult:=bJFSWriteStream(rJFSFile,p, u4HowMany);
  Writeln('bJFSWriteStream returned:',bresult);
  Writeln('We Flush to commit to the disk result from bJFSWriteBufferNow:',bJFSWriteBufferNow(rJFSFile));
  Writeln('Closed:',bJFSClose(rJFSFile));

End;

procedure rawin;
var bResult: boolean;
  p: pointer;
  ch: array [0..500] of char;
  t: integer;
  u4Bytes: LongWord;
Begin
  p:=@ch;
  InitJFS(rJFSFile);
  rJFSFile.saFilename:='!testfile.bin';
  rJFSFile.u1Mode:=cnJFSMode_Read;
  Writeln;
  Writeln('-----------Opened:',bJFSOpen(rJFSFile));
  //ebugJFSFile(rJFSFile);
  Writeln('---------FASTREAD-1---------Header Rec');
  bResult:=bJFSFastRead(rJFSFile);
  //ebugJFSFile(rJFSFile);
  Writeln('---------FASTREAD-2---------Data Rec 1');
  bResult:=bJFSFastRead(rJFSFile);
  //ebugJFSFile(rJFSFile);
  Writeln('------READ RAW NEXT------------------------------');
  //u4Bytes:=130;
  //Writeln('Trying to read ',u4Bytes,' bytes.');
  //bResult:=bJFSReadStream(rJFSFile,p,u4bytes);//I stored 124 purposely
  //Writeln('bJFSReadRaw Returned:',bResult);
  //Writeln('And we read ',u4Bytes,' bytes.');
  //if u4Bytes>500 then u4Bytes:=500; // to prevent going past the allocated 
  ////                                   array size in this test
  //for t:=0 to u4Bytes-1 do Write(ch[t]);
  //Writeln; 
  
  u4Bytes:=233;
  Writeln('Trying to read ',u4Bytes,' bytes.');
  bResult:=bJFSReadStream(rJFSFile,p,u4bytes);//I stored 124 purposely
  Writeln('bJFSReadRaw Returned:',bResult);
  Writeln('And we read ',u4Bytes,' bytes.');
  if u4Bytes>500 then u4Bytes:=500; // to prevent going past the allocated 
  //                                   array size in this test
  for t:=0 to u4Bytes-1 do Write(ch[t]);
  Writeln; 
  Writeln('Closed:',bJFSClose(rJFSFile));
End;


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================

repeat
  Writeln('r - test read, w - test write, b - BOTH');
  Writeln('a - RAW Stream WRITES, c - RAW STREAM READS');
  
  readln(ch);
  if ch='w' then 
  Begin
    aout;
  End;
  if ch='r' then 
  Begin
    ain;
  End;
  if ch='b' then 
  Begin
    aboth;
  End;
  if ch='a' then 
  Begin
    rawout;
  End;
  if ch='c' then 
  Begin
    rawin;
  End;
until 1=2;
//rawout;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
