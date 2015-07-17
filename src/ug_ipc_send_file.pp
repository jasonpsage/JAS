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

{INCLUDE i_jegas_ipc_path.pp}

{DEFINE FILEBASED_IPC}
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
Var saIPCFileNameLessExtension: AnsiString;
Function saGetUniqueCommID(p_saPath: AnsiString):AnsiString;

//=============================================================================
{}
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_saCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_saExt: AnsiString
): Boolean;
//=============================================================================
{}
// this version sends rtCGI
{$IFDEF FILEBASED_IPC}
Function bIPCSendCGI(
  p_rCGI: rtCGI; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_saExt: AnsiString
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
Function saGetUniqueCommID(p_saPath: AnsiString):AnsiString;
Var
 flock: text;
 fautonum: text;
 iRetries: Integer;
 bGotIt: Boolean;
 u2IOResult: Word;
 saLineIn: AnsiString;
 iAutoOut: Integer;
 
Begin
  iRetries:=0;
  bGotit:=False;
  assign(flock, p_saPath + csLockFile);
  assign(fautonum, p_saPAth+csIPCSendAutoNumberFilename);
  repeat
    {$I-}
    rewrite(flock);
    u2IOResult:=IOResult;
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
    reset(fautonum);
    u2IOResult:=IOResult;
    {$I+}
    If u2IOResult<>0 Then // Make a new File?
    Begin
      // no problem... We are going to any way.
    End;
    
    If u2IOResult=0 Then
    Begin
      {$I-}
      readln(fautonum,saLineIn);
      {$I+}
      // Don''t care what we actually get. Just convert to a number, 
      // and add one Then Write it back out and release the lock! :)
      close(fAutoNum);
    End;
    iAutoOut:=iVal(saLineIn);
    
    {$I-}
    rewrite(fautonum);
    //u2IOResult:=IOResult; /// Don''t care - but if a problem and you're 
    // debugging - LOOK this over.
    {$I+}
    
    {$I-}
    Writeln(fautonum, saZeroPadInt(iAutoOut+1,7));
    //Writeln(fautoNum, 'iAutoOut:',iAutoOut,' saLineIn:',saLineIn, ' saZeroPadInt(iAutoOut+1,7):',saZeroPadInt(iAutoOut+1,7),' bGotIt:',satrueFalse(bGotit));
    
    //u2IOResult:=IOResult; /// Don''t care - but if a problem and you're 
    // debugging - LOOK this over.
    {$I+}
    close(fautonum);
    close(flock);// release the Lock  
    Result:=saZeroPadInt(iAutoOut,7);
  End
  Else
  Begin
    Result:=saZeroPadInt(999999,7);
  End;
End;


//=============================================================================
// Note: p_bGenerateCommID
//             Flag - When false, means you already have a commid
//
//                    When true - a commid is generated for you,
//                    and is returned in p_saCommId on return.
//       
Function bIPCSend(
  p_sa: AnsiString; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_saExt: AnsiString
): Boolean;
//=============================================================================
Var 
  bSuccess: Boolean;
  rJFS: rtJFSFile;
  iAnsiLength: Integer;
  f:File;
  u2TempIOResult: Word;
Begin
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  If p_bGenerateCommID Then
  Begin
    p_saCommID:=saGetUniqueCommID(p_saPath);
  End;
  InitJFS(rJFS);
{  jlog(MAC_SEVERITY_DEBUG,200609250629,'Just past InitJFS. rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}  
  
  //rJFS.saFilename:=p_saPath + p_saCommID + '.'+p_saExt;
  rJFS.saFilename:=p_saPath + p_saCommID + '.'+p_saExt+'.temp';
  
  //riteln('Filename:',rJFS.saFilename);
  rJFS.u1Mode:=cnJFSMode_Write;
  bSuccess:=bJFSOpen(rJFS); 
{  jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Just tried to open the file. bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
  }
  
  
  If bSuccess Then bSuccess:=bJFSSeek(rJFS,2);// Get past header record
{  jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Just tried to SEEK second record. bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  If bSuccess Then 
  Begin // Store the regular data types
    iAnsiLength:=length(p_sa);
    bSuccess:=bSuccess and bJFSWriteStream(rJFS,@iAnsiLength,sizeof(iAnsiLength));
 {
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. File Data Going Out. iAnsiLength:'+inttostr(iAnsiLength)+
      ' (Sending the LENGTH Out) bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
    bSuccess:=bSuccess and bJFSWriteStream(rJFS,pointer(p_sa),iAnsiLength);
{
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. File Data Going Out. iAnsiLength:'+inttostr(iAnsiLength)+
      ' (Writing the Actual Stream Out) bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  End;
  If bSuccess Then 
  Begin
    bSuccess:=bJFSWriteBufferNow(rJFS);
{    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. trying the bJFSWriteBufferNow Call.'+
      ' this MIGHT be a problem. It might fail when not needed. bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
  End;
  //if bSuccess then Writeln('SUCCESS!!');
  If bSuccess Then
  Begin
    bSuccess:=bJFSClose(rJFS);
{    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Everything GOOD.  Just tried to bJFSClose() the file. '+
      ' It might fail when not needed. bSuccess:'+saTrueFalse(bSuccess)+' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+' rJFS.u2IOResult:'+inttostr(rJFS.u2ioresult) + ' '+saIOResult(rJFS.u2IOResult),sourcefile);
}
    {$I-}
    assign(f,rJFS.saFilename);
    rename(f,p_saPath + p_saCommID + '.'+p_saExt);
    u2TempIOResult:=ioresult;
    bSuccess:=u2TempIOREsult=0;
    {$I+}
{
    jlog(MAC_SEVERITY_DEBUG,0,'InitJFS. Everything GOOD.  Just tried to finish up by renaming the output file. '+
      ' It might fail when not needed. bSuccess:'+saTrueFalse(bSuccess)+
      ' rJFS.bFileOpen:'+saTrueFalse(rJFS.bFileOpen)+
      ' rJFS.u2IOResult:'+inttostr(u2tempioresult) + ' '+saIOResult(u2tempIOResult),sourcefile);
}
  End;
  Result:=bSuccess;
End;
//=============================================================================

{$IFDEF FILEBASED_IPC}
//=============================================================================
// File version uses p_saCOMMID as PATH going out (with trailing backslash)
// but returns complete filename used coming out.
Function bIPCSendCGI(
  p_rCGI: rtCGI; //data
  Var p_saCommid: AnsiString;
  p_bGenerateCommID: Boolean;
  p_saPath: AnsiString;
  p_saExt: AnsiString
): Boolean;
//=============================================================================
Var 
  bSuccess: Boolean;
//  saFN: AnsiString;
  rJFS: rtJFSFile;
  i: Integer;
  iAnsiLength: Integer;
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
    p_saCommID:=saGetUniqueCommID(p_saPath);
  End;
  InitJFS(rJFS);
  rJFS.saFilename:=p_saPath + p_saCommID + '.'+p_saExt+'.temp';
  //riteln('Filename:',rJFS.saFilename);
  rJFS.u1Mode:=cnJFSMode_Write;
  bSuccess:=bJFSOpen(rJFS); 
  If bSuccess Then bSuccess:=bJFSSeek(rJFS,2);// Get past header record
  If bSuccess Then 
  Begin // Store the regular data types
    bSuccess:=bsuccess and bJFSWriteStream(rJFS,@p_rCGI.iENVVarCount,sizeof(p_rCGI.iENVVarCount));
    bSuccess:=bsuccess and bJFSWriteStream(rJFS,@p_rCGI.iRequestMethodIndex,sizeof(p_rCGI.iRequestMethodIndex));
    bSuccess:=bsuccess and bJFSWriteStream(rJFS,@p_rCGI.bPost,sizeof(p_rCGI.bPost));
    bSuccess:=bsuccess and bJFSWriteStream(rJFS,@p_rCGI.iPostContentTypeIndex,sizeof(p_rCGI.iPostContentTypeIndex));
    bSuccess:=bsuccess and bJFSWriteStream(rJFS,@p_rCGI.iPostContentLength,sizeof(p_rCGI.iPostContentLength));
  End;  
  If bSuccess Then 
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    If p_rCGI.iEnvVarCount>0 Then
    Begin  
      For i :=1 To p_rCGI.iEnvVarCount Do
      Begin
        //rite('i IPCSEND:',i, 'i-1:',i-1,' p_rCGI.iEnvVarCount:',p_rCGI.iEnvVarCount);
        iAnsiLength:=length(p_rCGI.arnvPair[i-1].saName);
        bSuccess:=bSuccess and bJFSWriteStream(rJFS,@iAnsiLength,sizeof(iAnsiLength));
        bSuccess:=bSuccess and bJFSWriteStream(rJFS,pointer(p_rCGI.arNVPair[i-1].saName),iAnsiLength);

        iAnsiLength:=length(p_rCGI.arnvPair[i-1].saValue);
        bSuccess:=bSuccess and bJFSWriteStream(rJFS,@iAnsiLength,sizeof(iAnsiLength));
        bSuccess:=bSuccess and bJFSWriteStream(rJFS,pointer(p_rCGI.arNVPair[i-1].saValue),iAnsiLength);

      End;
    End;
  End;
  If bSuccess Then 
  Begin
    // write the post data
    iAnsiLength:=length(p_rCGI.saPostData);
    bSuccess:=bSuccess and bJFSWriteStream(rJFS,@iAnsiLength,sizeof(iAnsiLength));
    bSuccess:=bSuccess and bJFSWriteStream(rJFS,pointer(p_rCGI.saPostData),iAnsiLength);
  End;
  If bSuccess Then bSuccess:=bJFSWriteBufferNow(rJFS);
  //if bSuccess then Writeln('SUCCESS!!');
  If bSuccess Then
  Begin
    bSuccess:=bJFSClose(rJFS);
    If bSuccess Then 
    Begin
      {$I-}
      assign(f,rJFS.saFilename);
      rename(f,p_saPath + p_saCommID + '.'+p_saExt);
      bSuccess:=IOREsult=0;
      {$I+}
    End;
  End;
  Result:=bSuccess;
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
