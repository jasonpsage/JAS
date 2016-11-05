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

{$DEFINE DEBUGMESSAGES}
{$IFDEF DEBUGMESSAGES}
  {$INFO | DEBUGMESSAGES}
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
  sysutils,
  ug_jfilesys,
{$IFDEF DEBUGMESSAGES}
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
// inter-process communication - file based call.
// The sample programs are the best reference for this currently but in
// short - one side sends a file with an ID, another scans for something
// to arrive. You can also limit it so you are only looking for a specific
// communication id. After we receive the file, we can opt to have it deleted.
function bIPCRecv(
  var p_sa: AnsiString; 
  p_sCommID: String;
  p_saPath:AnsiString;
  p_sExt:String;
  p_bDelete: boolean
): boolean;
//=============================================================================
{}
// inter-process communication - file based call.
// The sample programs are the best reference for this currently but in
// short - one side sends a file with an ID, another scans for something
// to arrive. You can also limit it so you are only looking for a specific
// communication id. After we receive the file, we can opt to have it deleted.
// This version is tailored for CGI applications using filebased Inter-process
// communication. How much demand for this? I needed it for awhile. It still
// works, so I'm keeping it. :)
function bIPCRecvCGI(
  var p_rCGI: rtCGI; //data
  var p_sCommid: String;
  p_saPath: AnsiString;
  p_sExt: String;
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
  p_sCommID: String;
  p_saPath:AnsiString;
  p_sExt:String;
  p_bDelete: boolean
): boolean;
//=============================================================================
var 
    bOk: boolean;
    uAnsiLength: uint;
    rJFS: rtJFSFile;
    uHowMany: uint;
//    f:file;
Begin
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  bOk:=false;

  JFSClearFileInfo(rJFS);
  rJFS.saFilename:=p_saPath + p_sCommID + '.' + p_sExt;
  rJFS.u1Mode:=cnJFSMode_Read;
  bOk:=bJFSOpen(rJFS);
  {$IFDEF DEBUGMESSAGES}
  if not bOk then
  begin
    JLOG(cnLog_ERROR,200703021712,'bJFSOpen Failed. File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
  end;
  {$ENDIF}
  
  
  
  if bOk then
  begin
    bOk:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSMoveNext Failed - trying to get past the first record. File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bOk then
  begin
   bOk:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSMoveNext Failed - trying to get past the second record. File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bOk then
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    uHowMany:=sizeof(uAnsiLength);
    bOk:=bJFSReadStream(rJFS,@uAnsiLength,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSReadstream Failed - trying to read How Long the next Ansistring is. File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  end;
  
  if bOk then
  begin
    setlength(p_sa,uAnsiLength);
    uHowMany:=uAnsiLength;
    bOk:=bJFSReadStream(rJFS,pointer(p_sa),uHowMany);
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      JLOG(cnLog_ERROR,200703021712,'bJFSReadStream Failed - trying to read Ansistring. File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
    end;
    {$ENDIF}
  End;

  JFSClose(rJFS);

  if bOk then
  Begin
    if p_bDelete then
    Begin
      {$I-}
      assign(rJFS.F,rJFS.saFilename);
      try erase(rJFS.F);except on E:Exception do ; end;//try
      bOk:=IOResult=0;
      {$I+}
      {$IFDEF DEBUGMESSAGES}
      if not bOk then
      begin
        JLOG(cnLog_ERROR,200703021712,'bIPCRecv Failed Trying to delete the File:'+rJFS.saFilename+' Read Mode.',SOURCEFILE);
      end;
      {$ENDIF}
    End;
  End;
  result:=bOk;
End;
//=============================================================================



//=============================================================================
// p_sa gets your data in one fell swoop
// p_saCommID needs to have the complete path and filename of where the data 
// will be loaded from, less the .FIFO extension
function bIPCRecvCGI(
  var p_rCGI: rtCGI; //data
  var p_sCommid: String;
  p_saPath: AnsiString;
  p_sExt: String;
  p_bDelete: boolean
): boolean;
//=============================================================================
var 
//    F: text;  
    bOk: boolean;
    uAnsiLength: uint;
//    saFN: AnsiString;
    rJFS: rtJFSFile;
    uHowMany: uint;
    u:uint;
    u2IOResult: word;
Begin
  bOk:=false;
  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  
  {$IFDEF DEBUGMESSAGE}writeln('Grabbing the CGI FILE:',p_saCommID+'.FIFO');{$ENDIF}

  // This function needs to establish one of the following
  //
  // true - that data made it to the destination - and its ok to wait for a 
  // response communication.
  //
  // False - After attempts are exhausted - data was not successfully  sent.  
  JFSClearFileInfo(rJFS);
  rJFS.saFilename:=p_saPath + p_sCommID + '.' + p_sExt;
  {$IFDEF DEBUGMESSAGES}writeln('bIPCRecvCGI Filename:',rJFS.saFilename);{$ENDIF}
  rJFS.u1Mode:=cnJFSMode_Read;
  bOk:=bJFSOpen(rJFS);
  //ebugJFSFile(rJFS);
  {$IFDEF DEBUGMESSAGES}writeln('Did the File Open Ok: ',sYesNo(bOk));{$ENDIF}
  //ibOkss then bOk:=bJFSSeek(rJFS,2);// Get past header record
  //if bOk then bOk:=bJFSMoveNext(rJFS);// Get past header record
  if bOk then
  begin
    bOk:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      writeln('1st bJFSMoveNext failed.');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    bOk:=bJFSMoveNext(rJFS);// Get past header record
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      writeln('2nd bJFSMoveNext failed.');
    end;
    {$ENDIF}
  end;
  //riteln('zzzSuccess:',bOk);
  //ebugJFSFile(rJFS);
  if bOk then
  Begin // Gather the regular data types
    {$IFDEF DEBUGMESSAGES}writeln('GATHERING DATA');{$ENDIF}
    uHowMany:=sizeof(p_rCGI.uENVVarCount);
    writeln('1 uHowMany:',uHowMany);
    bOk:=bJFSReadStream(rJFS,@p_rCGI.uENVVarCount,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    //ebugJFSFile(rJFS);
    if not bok then
    begin
      writeln('1 - readstream failed');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    bOk:=bJFSReadStream(rJFS,@p_rCGI.uENVVarCount,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    writeln('2 uHowMany:',uHowMany);
    if not bOk then
    begin
      writeln('2 -restream failed');
    end;
    {$ENDIF}
  end;
    
  if bOk then
  begin
    uHowMany:=sizeof(p_rCGI.iRequestMethodIndex);
    bOk:=bJFSReadStream(rJFS,@p_rCGI.iRequestMethodIndex,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    writeln('2 Success:',bOk);
    if not bOk then
    begin
      writeln('3 - readstream failed');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    uHowMany:=sizeof(p_rCGI.bPost);
    bOk:=bJFSReadStream(rJFS,@p_rCGI.bPost,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    writeln('3 Success:',bOk);
    if not bOk then
    begin
      writeln('4 - readstream failed');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    uHowMany:=sizeof(p_rCGI.iPostContentTypeIndex);
    bOk:=bJFSReadStream(rJFS,@p_rCGI.iPostContentTypeIndex,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    writeln('4 Success:',bOk);
    if not bOk then
    begin
      writeln('5 - readstream failed');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    uHowMany:=sizeof(p_rCGI.uPostContentLength);
    bOk:=bJFSReadStream(rJFS,@p_rCGI.uPostContentLength,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    writeln('5 Success:',bOk);
    if not bOk then
    begin
      writeln('6 - readstream failed');
    end;
    {$ENDIF}
  End;


  if bOk then
  Begin // now store the ansistrings in 4byte LENGTH SIZE and then data pairs.
    if p_rCGI.uEnvVarCount>0 then
    Begin  
      for u :=1 to p_rCGI.uEnvVarCount do
      Begin
        uHowMany:=sizeof(uAnsiLength);
        bOk:=bJFSReadStream(rJFS,@uAnsiLength,uHowMany);
        if not bOk then
        begin
          {$IFDEF DEBUGMESSAGES}writeln('7 - readstream - u: ',u,' p_rCGI.uenvvarcount:',p_rCGI.uenvvarcount);{$ENDIF}
          break;
        end;

        setlength(p_rCGI.arNVPair[u-1].saName,uAnsiLength);
        uHowMany:=uAnsiLength;
        bOk:=bJFSReadStream(rJFS,pointer(p_rCGI.arNVPair[u-1].saName),uHowMany);
        if not bOk then
        begin
          {$IFDEF DEBUGMESSAGES}writeln('8 - readstream - u: ',u,' p_rCGI.uenvvarcount:',p_rCGI.uenvvarcount);{$ENDIF}
          break;
        end;

        uHowMany:=sizeof(uAnsiLength);
        bOk:=bJFSReadStream(rJFS,@uAnsiLength,uHowMany);
        if not bOk then
        begin
          {$IFDEF DEBUGMESSAGES}
            writeln('9 - readstream - u: ',u,' p_rCGI.uenvvarcount:',p_rCGI.uenvvarcount);
          {$ENDIF}
          break;
        end;

        {$IFDEF DEBUGMESSAGES}write('+3:',uAnsiLength,':');{$ENDIF}
        setlength(p_rCGI.arNVPair[u-1].saValue,uAnsiLength);
        uHowMany:=uAnsiLength;
        bOk:=bJFSReadStream(rJFS,pointer(p_rCGI.arNVPair[u-1].saValue),uHowMany);
        if not bOk then
        begin
          {$IFDEF DEBUGMESSAGES}
            writeln('10 - readstream - u: ',u,' p_rCGI.uenvvarcount:',p_rCGI.uenvvarcount);
          {$ENDIF}
          break;
        end;

        //rite('+4');
        //riteln;
      End;
    End;
  End;

  if bOk then
  Begin
    // record the posted data
    uHowMany:=sizeof(uAnsiLength);
    bOk:=bJFSReadStream(rJFS,@uAnsiLength,uHowMany);
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      writeln('11 - readstream fail');
    end;
    {$ENDIF}
  end;

  if bOk then
  begin
    setlength(p_rCGI.saPostData,uAnsiLength);
    uHowMany:=uAnsiLength;
    bOk:=bJFSReadStream(rJFS,pointer(p_rCGI.saPostData),uHowMany);
    {$IFDEF DEBUGMESSAGES}
    if not bOk then
    begin
      writeln('12 - readstream fail');
    end;
    {$ENDIF}
  End;
  JFSClose(rJFS);
  if bOk then
  Begin
    if p_bDelete then
    Begin
      {$IFDEF DEBUGMESSAGES}writeln('ipcrecv jfs.u2ioresult:',rJFS.u2IOREsult);{$ENDIF}
      assign(rJFS.F,rJFS.saFilename);
      try erase(rJFS.F);except on E:Exception do; end;//try
      u2IOResult:=IOResult;
      bOk:=u2IOResult=0;
      {$IFDEF DEBUGMESSAGES}
      if not bOk then
      begin
        writeln('erase failed: '+sIOResult(u2IOResult)+' FOR FILE: '+rJFS.safilename);
      end;
      {$ENDIF}
    End;
  End;
  //riteln('Leaving the RECV thing');
  result:=bOk;
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
