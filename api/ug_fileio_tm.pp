{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}


//=============================================================================
{ }
// This unit has fileio routines designed for use with the
// u01g_jfc_threadmgr.pp unit.
Unit ug_fileio_tm;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_fileio_tm.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
{$INFO | DEBUGLOGBEGINEND: TRUE}
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
{}
uses
//=============================================================================
{}
classes
,syncobjs
,ug_common
,sysutils
;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
const BLOCKREADBUFFERSIZETM=65536;

//=============================================================================
{}
// Init this Unit.
Procedure InitFileIO_TM(p_iMaxFileHandles:integer);
//=============================================================================
{}
// Finish Using this Unit
Procedure DoneFileIO_TM;
//=============================================================================
{}
// Reserve a File Handle. Your Responsibilitiy to free it.
// Note this is just a counter to allow "throttling" opened files.
function bReserveFileHandle(p_RetryLimit: integer; p_iRetryDelayInMSec: Integer):boolean;
//=============================================================================
{}
// Free Reserved File Handle
procedure DoneFileHandle;
//=============================================================================
{}
// Returns # of unused file handles. !!Note!! this is a counter, not OS
// filehandle #'s !!!
function iFileHandlesLeft: Integer;
//=============================================================================
{}
function iMaxFileHandles:integer;
//=============================================================================
{}
// Thread safe File Loading function, BlockRead Core, and ReadOnly Mode.
// Note: There are various points along the way this function can have a 
// problem such as: Did it get a FileHandle from our FileHandle Throttle?
// Did the file open Ok? How about the Read? How about the file Close?
// The Point is that the RetryLimit is the maximum # of "ERRORS" the function
// will tolerate. The returned p_u2IOResult SHOULD be the last disk Error
// if in fact a disk error caused the final "FAIL". If you get a fail and
// no disk error, chances are a filehandle was not begot.
//
// THIS FUNCTION HANDLES the FileHandle(counter) Thing for YOU!!!!
function bLoadFileTS(
  p_saFilename: ansistring;
  var p_saFileData: ansistring;
  p_iRetryLimit: integer;
  p_iRetryDelayInMSecs: integer;
  var p_u2IOResult: word;
  var p_bWasAbleToGetFileHandle: boolean
):boolean;
//=============================================================================

//=============================================================================
{}
// Thread safe File Saving function. Uses TEXT mode with a Write (versus a
// writeln) so in theory should be useful for various file types even though
// creates file of text.
function bSaveFileTS(
  p_saFilename: ansistring;
  var p_saFileData: ansistring;
  p_iRetryLimit: integer;
  p_iRetryDelayInMSecs: integer;
  var p_u2IOResult: word;
  var p_bWasAbleToGetFileHandle: boolean;
  p_bAppend: boolean
):boolean;
//=============================================================================



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

//=============================================================================
var 
  pvt_iFileHandlesLeft: integer;
  pvt_iMaxFileHandles:integer;
  pvt_u1OldFileMode: byte;
  CSECTION_FILEREADMODEFLAG: TCriticalSection;
  CSECTION_FILEHANDLE: TCriticalSection;
  pvt_bFileIOTMInitialized: boolean;
//=============================================================================

//=============================================================================


//=============================================================================
// Init this Unit.
Procedure InitFileIO_TM(p_iMaxFileHandles:integer);
//=============================================================================
begin
  //riteln('InitFileIO_TM(',p_iMaxFileHandles,')');
  if not pvt_bFileIOTMInitialized then
  begin
    //riteln('InitFileIO_TM Start up Executed Properly');
    pvt_iMaxFileHandles:=p_iMaxFileHandles;
    pvt_iFileHandlesLeft:=p_iMaxFileHandles;
    CSECTION_FILEREADMODEFLAG:=TCriticalSection.Create;
    CSECTION_FILEHANDLE:=TCriticalSection.Create;
    pvt_bFileIOTMInitialized:=true;
  end;
end;
//=============================================================================


//=============================================================================
// Finish Using this Unit
Procedure DoneFileIO_TM;
//=============================================================================
begin
  if pvt_bFileIOTMInitialized then
  begin
    CSECTION_FILEREADMODEFLAG.Destroy;
    CSECTION_FILEREADMODEFLAG:=nil;
    CSECTION_FILEHANDLE.Destroy;
    CSECTION_FILEHANDLE:=nil;
    pvt_bFileIOTMInitialized:=false;
  end;
end;
//=============================================================================

//=============================================================================
// Reserve a File Handle. Your Responsibilitiy to free it.
// Note this is just a counter to allow "throttling" opened files.
function bReserveFileHandle(p_RetryLimit: integer; p_iRetryDelayInMSec: Integer):boolean;
//=============================================================================
var 
  iRetries: integer;
begin
  result:=false; iRetries:=0;
  while (result = false) and (iRetries<=p_RetryLimit) do 
  begin
    CSECTION_FILEHANDLE.Enter;
    result:=pvt_iFileHandlesLeft>0;
    if result then 
    begin
      pvt_iFileHandlesLeft-=1
    end
    else
    begin
      //riteln('bReserveFileHandle unable to get filehandle. File Handles Left:',
      //pvt_iFileHandlesLeft);
    end;
    CSECTION_FILEHANDLE.Leave;
    if not result then 
    begin
      iRetries+=1;
      Yield(p_iRetryDelayInMSec);
    end;
  end;
end;
//=============================================================================

//=============================================================================
// Free Reserved File Handle
procedure DoneFileHandle;
//=============================================================================
begin
  CSECTION_FILEHANDLE.Enter;
  pvt_iFileHandlesLeft+=1;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================


//=============================================================================
// Returns # of unused file handles. !!Note!! this is a counter, not OS 
// filehandle #'s !!!
function iFileHandlesLeft: Integer;
//=============================================================================
begin
  CSECTION_FILEHANDLE.Enter;
  result:=pvt_iFileHandlesLeft;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================

//=============================================================================
function iMaxFileHandles:integer;
//=============================================================================
begin
  CSECTION_FILEHANDLE.Enter;
  result:=pvt_iMaxFileHandles;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================






//=============================================================================
// Thread safe File Loading function, BlockRead Core, and ReadOnly Mode.
function bLoadFileTS(
  p_saFilename: ansistring;
  var p_saFileData: ansistring;
  p_iRetryLimit: integer;
  p_iRetryDelayInMSecs: integer;
  var p_u2IOResult: word;
  var p_bWasAbleToGetFileHandle: boolean
):boolean;
//=============================================================================
var 
  bOk: boolean;
  f: File;
  iRetries: integer;
  u4Numread: cardinal;
  b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  lpB: pointer;
  lpSA: pointer;
 u4OldLen: LongWord;
begin
  p_saFileData:='';
  iRetries:=0;
  u4Numread:=0;
  u4OldLen:=0;
  bOk:=false;
  //rite('A0');
  p_bWasAbleToGetFileHandle:=bReserveFileHandle(p_iRetryLimit,p_iRetryDelayInMSecs);

  if p_bWasAbleToGetFileHandle then 
  begin
    assign(f,p_saFilename);
    repeat
      pvt_u1OldFileMode := filemode;
      CSECTION_FILEREADMODEFLAG.Enter;
      filemode := READ_ONLY;
      try reset(f,1); except on E:Exception do p_u2IOResult:=60000; end;//try
      CSECTION_FILEREADMODEFLAG.Leave;
      p_u2IOResult+=ioresult;
      filemode := pvt_u1OldFileMode;
      if p_u2IOResult<>0 then
      begin
        bOk:=false;
        iRetries+=1; 
        Yield(p_iRetryDelayInMSecs);
      end
      else
      begin
        bOk:=true;
        //p_u2IOResult:=0;// Make sure its ZERO is all.
      end;    
    until bOk or (iRetries>p_iRetryLimit);
  end;
  //if not bOk then riteln('Part 3');
  //rite('A3');
  
  if bOk then
  begin
    While (p_u2IOResult=0) and (not Eof(f)) Do Begin
      try BlockRead(f,b,BLOCKREADBUFFERSIZETM,u4NumRead); except on E:Exception do p_u2IOResult:=60000; end;//try
      p_u2IOResult+=ioresult;
      iF(p_u2IOResult=0)then
      begin
        u4OldLen:=length(p_saFileData);
        setlength(p_saFileData, u4OldLen+u4NumRead);
        lpB:=@b;lpSA:=pointer(UINT(pointer(p_saFileData))+u4OldLen);
        move(lpB^,lpSA^,u4NumRead);
      end
      else
      begin
        //riteln('Block Read issue:',saIOResult(p_u2IOREsult));
      end;
    End;
    bOk:=(p_u2IOResult=0);
    try close(f); except on e:exception do p_u2IOResult:=60000;end;//try
    p_u2IOResult+=ioresult;
    bOk:=(p_u2IOResult=0);
  end;
  //if not bOk then riteln('Part 4');
  //rite('A4');
  Result:=bOk;
  if(p_bWasAbleToGetFileHandle) then DoneFileHandle;
  //rite('A5');
end;
//=============================================================================






//=============================================================================
// Thread safe File Saving function. Uses TEXT mode with a Write (versus a 
// writeln) so in theory should be useful for various file types even though
// creates file of text.
function bSaveFileTS(
  p_saFilename: ansistring;
  var p_saFileData: ansistring;
  p_iRetryLimit: integer;
  p_iRetryDelayInMSecs: integer;
  var p_u2IOResult: word;
  var p_bWasAbleToGetFileHandle: boolean;
  p_bAppend: boolean
):boolean;
//=============================================================================
var 
  bOk: boolean;
  f: text;
  iRetries: integer;
  //u4Numread: cardinal;
  //b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  //lpB: pointer;
  //lpSA: pointer;
  //u4OldLen: LongWord;
begin
  iRetries:=0;
  //u4Numread:=0;
  //u4OldLen:=0;
  bOk:=false;
  //rite('A0');
  p_bWasAbleToGetFileHandle:=bReserveFileHandle(p_iRetryLimit,p_iRetryDelayInMSecs);

  if p_bWasAbleToGetFileHandle then 
  begin
    assign(f,p_saFilename);
    p_u2IOResult:=ioresult;
    bOk:=(p_u2IOResult=0);
  end;
  //if not bOk then riteln('Part 2');
  //rite('A2');

  if bOk then 
  begin
    //p_u2IOResult:=0;// Make sure its ZERO is all.
    repeat 
      pvt_u1OldFileMode := filemode;
      CSECTION_FILEREADMODEFLAG.Enter;
      filemode := WRITE_ONLY;
      if(p_bAppend)then
      begin
        try append(f); except on E:Exception do p_u2IOResult:=60000; end;//try
      end
      else
      begin
        try rewrite(f); except on E:Exception do p_u2IOResult:=60000; end;//try
      end;
      CSECTION_FILEREADMODEFLAG.Leave;
      p_u2IOResult+=ioresult;
      filemode := pvt_u1OldFileMode;
      if p_u2IOResult<>0 then
      begin
        bOk:=false;
        iRetries+=1; 
        Yield(p_iRetryDelayInMSecs);
      end
      else
      begin
        bOk:=true;
        //p_u2IOResult:=0;// Make sure its ZERO is all.
      end;    
    until bOk or (iRetries>p_iRetryLimit);
  end;
  //if not bOk then riteln('Part 3');
  //rite('A3');
  
  if bOk then
  begin
    While (p_u2IOResult=0) and (not Eof(f)) Do Begin
      try write(f,p_saFileData);except on E:Exception do p_u2IOResult:=60000; end;//try
      p_u2IOResult+=ioresult;
    End;
    bOk:=(p_u2IOResult=0);
  end;
  try close(f); except on E:Exception do; end;//try
  //rite('A4');
  Result:=bOk;
  if(p_bWasAbleToGetFileHandle) then DoneFileHandle;
  //rite('A5');
end;
//=============================================================================






//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  pvt_iMaxFileHandles:=0;
  pvt_iFileHandlesLeft:=0;
  CSECTION_FILEREADMODEFLAG:=nil;
  CSECTION_FILEHANDLE:=nil;
  pvt_bFileIOTMInitialized:=false;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
