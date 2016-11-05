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
// File Based Interprocess Communication
//
// NOTE: This is the Old Way. The New Way is SIMPLY an autonumber
// managed as a simple one line text file - that fights contention 
// (Record locking, multi-user use etc) with a lock file - os dependant.
// SHOULD work. 2006-09-29 12:45 pm Jason P Sage
// ---------------------------------------------------------------------
// FileName: YYYYMMDDHHNNSSCCCRRRRRRRRRR.extension
// YYYY = YEAR     CCC = Milli Seconds
// MM = Month      RRRRRRRRRR = RANDOM NUMBER (31 bit range)
// DD = DAY
// HH = HOUR
// NN = MINUTES
// SS = SECONDS
// ----------------------------------------------------------------------
//
//
// The range is 0 thru 32Bit Largest Positive 32bit Integer for 32bit programs
//              0 thru 64bit Largest Positive 64bit Integer for 64bit programs
Unit ug_ipc_send_file;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_ipc_send_file.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$INCLUDE i_jegas_ipc_path.pp}

{$DEFINE FILEBASED_IPC}
{$IFDEF FILEBASED_IPC}
  {$INFO | File Based IPC }
{$ENDIF}
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
  sysutils,
  dos,
  ug_jfilesys,
  ug_misc,
  ug_common;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Var sIPCFileNameLessExtension: String;
Function sGetUniqueCommID(p_saPath: ansiString):String;

//=============================================================================
{}
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_sCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_sCommid: String;
  p_bGenerateCommID: Boolean;
  p_saPath: ansistring;
  p_sExt: String
): Boolean;
//=============================================================================
{$IFDEF FILEBASED_IPC}
{}
// this version sends rtCGI
Function bIPCSendCGI(
  p_rCGI: rtCGI; //data
  Var p_sCommid: String;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_sExt: String
): Boolean;
{$ENDIF}
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//Function saGetUniqueID_OLDWay: AnsiString;
//Var
// t: Integer;// my generic integer variable :) 'i' is over rated ;)
// y,m,d,wd,h,n,s,s100: Word;// date + time via dos unit
// sa: AnsiString;
// saUID: AnsiString;
//Begin
//  GetDate(y,m,d,wd);
//  GetTime(h,n,s,s100);
//  str(y:4,sa);saUID:=sa;
//  str(m:2,sa);saUID:=saUID+sa;
//  str(d:2,sa);saUID:=saUID+sa;
//  str(h:2,sa);saUID:=saUID+sa;
//  str(n:2,sa);saUID:=saUID+sa;
//  str(s:2,sa);saUID:=saUID+sa;
//  str(s100:3,sa);saUID:=saUID+sa;
//  // 31 bits - cuz random takes integer - not unsigned
//  t:=b30+b29+b28+b27+b26+b25+b24+b23+b22+b21+b20+b19+b18+b17+b16+b15+b14+b13+b12+b11+b10+b09+b08+b07+b06+b05+b04+b03+b02+b01+b00;
//  t:=random(t);
//  str(t:10,sa);saUID:=saUID+sa; 
//  Result:=saSNR(saUID, ' ','0');
//End;

Const csLockfile = 'zzlockfile.lock';
Const csIPCSendAutoNumberFilename = 'zzIPCSendAutoNumberFilename.txt';
Const cnRetryLimit=20;
Const cnRetryDelayInMilliseconds=20;
Function sGetUniqueCommID(p_saPath: ansiString):String;
Var
 fileLock: text;
 fileAutoNum: text;
 iRetries: Integer;
 bGotIt: Boolean;
 u2IOResult: Word;
 saLineIn: AnsiString;
 uAutoOut: UInt;
 
Begin
  iRetries:=0;
  bGotit:=False;
  assign(fileLock, p_saPath + csLockFile);
  assign(fileAutoNum, p_saPAth+csIPCSendAutoNumberFilename);
  repeat
    {$I-}
    try rewrite(fileLock); except on E:Exception do u2IOResult:=60000; end;//try
    u2IOResult+=IOResult;
    {$I+}
    bGotIt:=u2IOResult=0;
    If not bGotIt Then
    Begin
      Inc(iRetries);
      Yield(cnRetryDelayInMilliseconds);
    End;
  Until bgotIt OR (iRetries>=cnRetryLimit);
  
  If bGotIt Then
  Begin
    saLineIn:='';
    {$I-}
    try reset(fileAutoNum); except on E:Exception do u2IOResult:=60000; end;//try
    u2IOResult:=IOResult;
    {$I+}
    If u2IOResult<>0 Then // Make a new File?
    Begin
      // no problem... We are going to any way.
    End;
    
    If u2IOResult=0 Then
    Begin
      try readln(fileAutonum,saLineIn); except on E:Exception do u2IOResult:=60000; end;//try
      // Don''t care what we actually get. Just convert to a number,
      // and add one Then Write it back out and release the lock! :)
      try close(fileAutoNum); except on E:Exception do u2IOResult:=60000; end;//try
    End;
    {$IFDEF CPU32}
      uAutoOut:=u4Val(saLineIn);
    {$ELSE}
      uAutoOut:=u8Val(saLineIn);
    {$ENDIF}
    try rewrite(fileAutonum); except on E:Exception do ; end;//try
    try Writeln(fileAutonum, sZeroPadInt(uAutoOut+1,20)); except on E:Exception do ; end;//try
    try close(fileAutonum); except on E:Exception do ; end;//try
    try close(fileLock); except on E:Exception do ; end;//try
    Result:=sZeroPadUInt(uAutoOut,20);
  End
  Else
  Begin
    Result:=sZeroPadUInt(999999,20);
  End;
End;


//=============================================================================
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_sCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_sCommid: String;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_sExt: String
): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  rJFS: rtJFSFile;
  uAnsiLength: UInt;
  f:File;
  u2IOResult: Word;
Begin
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  If p_bGenerateCommID Then
  Begin
    p_sCommID:=sGetUniqueCommID(p_saPath);
  End;
  JFSClearFileInfo(rJFS);
{  jlog(MAC_SEVERITY_DEBUG,200609250629,'Just past InitJFS. rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}  
  
  //rJFS.saFilename:=p_saPath + p_sCommID + '.'+p_saExt;
  rJFS.saFilename:=p_saPath + p_sCommID + '.'+p_sExt+'.temp';
  
  //riteln('Filename:',rJFS.saFilename);
  rJFS.u1Mode:=cnJFSMode_Write;
  bOk:=bJFSOpen(rJFS);
{  jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Just tried to open the file.bOks:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
  }
  
  
  If bOk Then bOk:=bJFSSeek(rJFS,2);// Get past header record
{  jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Just tried to SEEK second record. bOk:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  If bOk Then
  Begin // Store the regular data types
    uAnsiLength:=length(p_sa);
   bOk:=bOk and bJFSWriteStream(rJFS,@uAnsiLength,sizeof(uAnsiLength));
 {
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. File Data Going Out. iAnsiLength:'+inttostr(iAnsiLength)+
      ' (Sending the LENGTH Out) bOk:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
    bOk:=bOk and bJFSWriteStream(rJFS,pointer(p_sa),uAnsiLength);
{
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. File Data Going Out. iAnsiLength:'+inttostr(iAnsiLength)+
      ' (Writing the Actual Stream Out) bOk:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  End;
  If bOk Then
  Begin
   bOk:=bJFSWriteBufferNow(rJFS);
{    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. trying the bJFSWriteBufferNow Call.'+
      ' this MIGHT be a problem. It might fail when not needed. bOk:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  End;
  //if bOk then Writeln('SUCCESS!!');
  JFSClose(rJFS);
{    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Everything GOOD.  Just tried to bJFSClose() the file. '+
      ' It might fail when not needed. bOk:'+saTrueFalse(bOk)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  {$I-}
  assign(f,rJFS.saFilename);
  try rename(f,p_saPath + p_sCommID + '.'+p_sExt); except on E:Exception do u2IOResult:=60000; end;//try
  u2IOResult+=ioresult;
  bOk:=u2IOREsult=0;
  {$I+}
{
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Everything GOOD.  Just tried to finish up by renaming the output file. '+
      ' It might fail when not needed. bOk:'+saTrueFalse(bOk)+
      ' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+
      ' rJFS.u2IOResult:'+inttostr(u2tempioresult) + ' '+saIOResult(u2tempIOResult),sourcefile);
}
  Result:=bOk;
End;
//=============================================================================

{$IFDEF FILEBASED_IPC}
//=============================================================================
// File version uses p_sCOMMID as PATH going out (with trailing backslash)
// but returns complete filename used coming out.
Function bIPCSendCGI(
  p_rCGI: rtCGI; //data
  Var p_sCommid: String;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_sExt: String
): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
//  saFN: AnsiString;
  rJFS: rtJFSFile;
  u: uint;
  uAnsiLength: uInt;
  F: File;
Begin
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  If p_bGenerateCommID Then
  Begin
    p_sCommID:=sGetUniqueCommID(p_saPath);
  End;
  JFSClearFileInfo(rJFS);
  rJFS.saFilename:=p_saPath + p_sCommID + '.'+p_sExt+'.temp';
  //riteln('Filename:',rJFS.saFilename);
  rJFS.u1Mode:=cnJFSMode_Write;
  bOk:=bJFSOpen(rJFS);
  If bOk Then bOk:=bJFSSeek(rJFS,2);// Get past header record
  If bOk Then
  Begin // Store the regular data types
    bOk:=bOk and bJFSWriteStream(rJFS,@p_rCGI.uENVVarCount,sizeof(p_rCGI.uENVVarCount));
    bOk:=bOk and bJFSWriteStream(rJFS,@p_rCGI.iRequestMethodIndex,sizeof(p_rCGI.iRequestMethodIndex));
    bOk:=bOk and bJFSWriteStream(rJFS,@p_rCGI.bPost,sizeof(p_rCGI.bPost));
    bOk:=bOk and bJFSWriteStream(rJFS,@p_rCGI.iPostContentTypeIndex,sizeof(p_rCGI.iPostContentTypeIndex));
    bOk:=bOk and bJFSWriteStream(rJFS,@p_rCGI.uPostContentLength,sizeof(p_rCGI.uPostContentLength));
  End;  
  If bOk Then
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    If p_rCGI.uEnvVarCount>0 Then
    Begin  
      For u :=1 To p_rCGI.uEnvVarCount Do
      Begin
        //rite('i IPCSEND:',i, 'i-1:',i-1,' p_rCGI.iEnvVarCount:',p_rCGI.iEnvVarCount);
        uAnsiLength:=length(p_rCGI.arnvPair[u-1].saName);
        bOk:=bOk and bJFSWriteStream(rJFS,@uAnsiLength,sizeof(uAnsiLength));
        bOk:=bOk and bJFSWriteStream(rJFS,pointer(p_rCGI.arNVPair[u-1].saName),uAnsiLength);

        uAnsiLength:=length(p_rCGI.arnvPair[u-1].saValue);
        bOk:=bOk and bJFSWriteStream(rJFS,@uAnsiLength,sizeof(uAnsiLength));
        bOk:=bOk and bJFSWriteStream(rJFS,pointer(p_rCGI.arNVPair[u-1].saValue),uAnsiLength);

      End;
    End;
  End;
  If bOk Then
  Begin
    // write the post data
    uAnsiLength:=length(p_rCGI.saPostData);
    bOk:=bOk and bJFSWriteStream(rJFS,@uAnsiLength,sizeof(uAnsiLength));
    bOk:=bOk and bJFSWriteStream(rJFS,pointer(p_rCGI.saPostData),uAnsiLength);
  End;
  If bOk Then bOk:=bJFSWriteBufferNow(rJFS);
  //if bOk then Writeln('SUCCESS!!');
  JFSClose(rJFS);

  If bOk Then
  Begin
    assign(f,rJFS.saFilename);
    try rename(f,p_saPath + p_sCommID + '.'+p_sExt); except on E:Exception do rJFS.u2IOResult:=60000; end;//try
    rJFS.u2IOResult+=ioresult;
    bOk:=rJFS.u2IOREsult=0;
  End;
  Result:=bOk;
End;
//=============================================================================
{$ENDIF}




//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  //Randomize; // Part of old way to get unique ID's
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
