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
// FileName: YYYYMMDDHHNNSSCCCRRRRRRRRRR.extension
// YYYY = YEAR     CCC = Milli Seconds
// MM = Month      RRRRRRRRRR = RANDOM NUMBER (31 bit range)
// DD = DAY
// HH = HOUR
// NN = MINUTES
// SS = SECONDS
//
unit ug_ipc_recv_file;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_ipc_recv_file.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{INCLUDE i_jegas_ipc_file.pp}

{DEFINE DIAGNOSTIC_MODE}
{$IFDEF DIAGNOSTIC_MODE}
  {$INFO | DIAGOSTIC MODE}
{$ENDIF}
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************







//=============================================================================
uses 
//=============================================================================
  dos,
  ug_jfilesys,
{$IFDEF DIAGNOSTIC_MODE}
  ug_jegas,
{$ENDIF}
  ug_common;



//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// p_sa gets your data in one fell swoop
function bIPCRecv(
  var p_sa: AnsiString; 
  p_saCommID: AnsiString;
  p_saPath:AnsiString;
  p_saExt:AnsiString;
  p_bDelete: boolean
): boolean;
//=============================================================================
{}
function bIPCRecvCGI(
  var p_rCGI: rtCGI; //data
  var p_saCommid: AnsiString;
  p_saPath: AnsiString;
  p_saExt: AnsiString;
  p_bDelete: boolean
): boolean;
//=============================================================================
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              implementation
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
//=============================================================================
function bIPCRecv(
  var p_sa: AnsiString; 
  p_saCommID: AnsiString;
  p_saPath:AnsiString;
  p_saExt:AnsiString;
  p_bDelete: boolean
): boolean;
//=============================================================================
var 
    bSuccess: boolean;
    iAnsiLength: integer;
    rJFS: rtJFSFile;
    u4HowMany: LongWord;
//    f:file;
Begin
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  bSuccess:=false;

  InitJFS(rJFS);
  rJFS.saFilename:=p_saPath + p_saCommID + '.' + p_saExt;
  rJFS.u1Mode:=cnJFSMode_Read;
  bSuccess:=bJFSOpen(rJFS); 
  {$IFDEF DIAGNOSTIC_MODE}
  if not bSuccess then
  begin
    JLOG(cnLog_ERROR,200703021712,'bJFSOpen Failed. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
  end;
  {$ENDIF}
  
  
  
  if bSuccess then 
  begin
    bSuccess:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DIAGNOSTIC_MODE}
    if not bSuccess then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSMoveNext Failed - trying to get past the first record. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bSuccess then 
  begin
    bSuccess:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DIAGNOSTIC_MODE}
    if not bSuccess then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSMoveNext Failed - trying to get past the second record. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bSuccess then 
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    u4HowMany:=sizeof(iAnsiLength);
    bSuccess:=bJFSReadStream(rJFS,@iAnsiLength,u4HowMany);
    {$IFDEF DIAGNOSTIC_MODE}
    if not bSuccess then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSReadstream Failed - trying to read How Long the next Ansistring is. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bSuccess then
  begin
    setlength(p_sa,iAnsiLength);
    u4HowMany:=iAnsiLength;
    bSuccess:=bJFSReadStream(rJFS,pointer(p_sa),u4HowMany);
    {$IFDEF DIAGNOSTIC_MODE}
    if not bSuccess then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSReadStream Failed - trying to read Ansistring. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  End;

  if bSuccess then
  begin
    bSuccess:=bJFSClose(rJFS);
    {$IFDEF DIAGNOSTIC_MODE}
    if not bSuccess then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSClose Failed. File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;

  if bSuccess then
  Begin
    if p_bDelete then
    Begin
      {$I-}
      assign(rJFS.F,rJFS.saFilename);
      erase(rJFS.F);
      bSuccess:=IOResult=0;
      {$I+}
      {$IFDEF DIAGNOSTIC_MODE}
      if not bSuccess then
      begin
        JLOG(cnLog_ERROR,200703021712,'bIPCRecv Failed Trying to delete the File:'+rJFS.saFileName+' Read Mode.',SOURCEFILE);
      end;
      {$ENDIF}
    End;
  End;
  result:=bSuccess;
End;
//=============================================================================



//=============================================================================
// p_sa gets your data in one fell swoop
// p_saCommID needs to have the complete path and filename of where the data 
// will be loaded from, less the .FIFO extension
function bIPCRecvCGI(
  var p_rCGI: rtCGI; //data
  var p_saCommid: AnsiString;
  p_saPath: AnsiString;
  p_saExt: AnsiString;
  p_bDelete: boolean
): boolean;
//=============================================================================
var 
//    F: text;  
    bSuccess: boolean;
    iAnsiLength: integer;
//    saFN: AnsiString;
    rJFS: rtJFSFile;
    u4HowMany: LongWord;
    i:integer;
Begin
  bSuccess:=false;
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  
  //riteln('Grabbing the CGI FILE:',p_saCommID+'.FIFO');

  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  InitJFS(rJFS);
  rJFS.saFilename:=p_saPath + p_saCommID + '.' + p_saExt;
  //riteln('bIPCRecvCGI Filename:',rJFS.saFilename);
  rJFS.u1Mode:=cnJFSMode_Read;
  bSuccess:=bJFSOpen(rJFS); 
  //ebugJFSFile(rJFS);
  //riteln('0 Success:',bSuccess);  
  //if bSuccess then bSuccess:=bJFSSeek(rJFS,2);// Get past header record
  //if bSuccess then bSuccess:=bJFSMoveNext(rJFS);// Get past header record
  if bSuccess then bSuccess:=bJFSMoveNext(rJFS);// Get past header record
  if bSuccess then bSuccess:=bJFSMoveNext(rJFS);// Get past header record
  //riteln('zzzSuccess:',bSuccess);  
  //ebugJFSFile(rJFS);
  if bSuccess then 
  Begin // Gather the regular data types
    //riteln('GATHERING DATA');
    u4HowMany:=sizeof(p_rCGI.iENVVarCount);
    //riteln('1u4HowMany:',u4HowMany);
    //bSuccess:=bsuccess and bJFSReadStream(rJFS,@p_rCGI.iENVVarCount,u4HowMany);
    //ebugJFSFile(rJFS);
    
    bSuccess:=bJFSReadStream(rJFS,@p_rCGI.iENVVarCount,u4HowMany);
    //riteln('2u4HowMany:',u4HowMany);
    
    
    //riteln('1 Success:',bSuccess);
    u4HowMany:=sizeof(p_rCGI.iRequestMethodIndex);
    bSuccess:=bsuccess and bJFSReadStream(rJFS,@p_rCGI.iRequestMethodIndex,u4HowMany);
    //riteln('2 Success:',bSuccess);
    
    u4HowMany:=sizeof(p_rCGI.bPost);
    bSuccess:=bsuccess and bJFSReadStream(rJFS,@p_rCGI.bPost,u4HowMany);
    //riteln('3 Success:',bSuccess);

    u4HowMany:=sizeof(p_rCGI.iPostContentTypeIndex);
    bSuccess:=bsuccess and bJFSReadStream(rJFS,@p_rCGI.iPostContentTypeIndex,u4HowMany);
    //riteln('4 Success:',bSuccess);

    
    u4HowMany:=sizeof(p_rCGI.iPostContentLength);
    bSuccess:=bsuccess and bJFSReadStream(rJFS,@p_rCGI.iPostContentLength,u4HowMany);
    //riteln('5 Success:',bSuccess);

  End;  
  if bSuccess then 
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    if p_rCGI.iEnvVarCount>0 then
    Begin  
      for i :=1 to p_rCGI.iEnvVarCount do
      Begin
        //rite('i IPCRECV:',i, 'i-1:',i-1,' p_rCGI.iEnvVarCount:',p_rCGI.iEnvVarCount);
        u4HowMany:=sizeof(iAnsiLength);
        bSuccess:=bSuccess and bJFSReadStream(rJFS,@iAnsiLength,u4HowMany);
        //rite('+1+sizeof(iansiLength):',sizeof(iAnsiLength));
        //if iAnsiLength<1000 then Begin
        setlength(p_rCGI.arNVPair[i-1].saName,iAnsiLength);
        u4HowMany:=iAnsiLength;
        bSuccess:=bSuccess and bJFSReadStream(rJFS,pointer(p_rCGI.arNVPair[i-1].saName),u4HowMany);
        //rite('+2',p_rCGI.arNVPair[i-1].saName);
        //End;
        
        u4HowMany:=sizeof(iAnsiLength);
        bSuccess:=bSuccess and bJFSReadStream(rJFS,@iAnsiLength,u4HowMany);
        //rite('+3:',iAnsiLength,':');
        setlength(p_rCGI.arNVPair[i-1].saValue,iAnsiLength);
        u4HowMany:=iAnsiLength;
        bSuccess:=bSuccess and bJFSReadStream(rJFS,pointer(p_rCGI.arNVPair[i-1].saValue),u4HowMany);
        
        //rite('+4');
        //riteln;
      End;
    End;
  End;
  if bSuccess then 
  Begin
    // record the posted data
    u4HowMany:=sizeof(iAnsiLength);
    bSuccess:=bSuccess and bJFSReadStream(rJFS,@iAnsiLength,u4HowMany);
    setlength(p_rCGI.saPostData,iAnsiLength);
    u4HowMany:=iAnsiLength;
    bSuccess:=bSuccess and bJFSReadStream(rJFS,pointer(p_rCGI.saPostData),u4HowMany);
  End;
  bSuccess:=bSuccess and bJFSClose(rJFS);
  if bSuccess then
  Begin
    if p_bDelete then
    Begin
      //riteln('ipcrecv jfs.u2ioresult:',rJFS.u2IOREsult);
      {$I-}
      assign(rJFS.F,rJFS.saFilename);
      erase(rJFS.F);
      //riteln(IOResult);
      bSuccess:=IOResult=0;
      {$I+}
    End;
  End;
  //riteln('Leaving the RECV thing');
  result:=bSuccess;
End;
//=============================================================================





//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
