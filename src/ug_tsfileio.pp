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
// This unit has fileio routines designed for use with the uxxg_jfc_threadmgr.pp
// unit. The "TS" means thread safe.
//
// To be clear; this unit doesn't rely on uxxg_jfc_threadmgr.pp which is a
// thread manager - but this unit is designed specifically to safeguard fileio
// in multi-threaded freepascal applications. One thing that I've noticed is
// freepascal (other pascals maybe?) has one filemode flag that is global.
//
// If this flag isn't protected, one thread might set it while another opens a
// file thinking it was in another state. So there lies the main problem.
// The other issue is that if two threads attempt to read/write a file, you can
// have problems.
//
// Operating systems usually prevent this; but when the same application tries
// to do it - (left hand not knowing what the right hand is
// doing) how is that handled? Is it handled the same in each OS? Does the
// attempt simply fail because the file is in use?
//
// Well - the solution to all of these potential scenarios ( in effect platform
// independant solution) is to track which files are open, and their mode, and
// more or less serialize access if read/write mode is desired. Basically; this
// unit retries a fixed number of times with a configurable delay in
// milliseconds where the thread yields. If it simply can't get the file - it
// will fail. But, at least it tries really hard first. The environment this
// is designed for is a webserver running multiple threads. So, files aren't
// opened that long - and this unit when systemically implemented can be used
// to throttle the number of open files at any one time and handles the single
// filemode global variable in freepascal and prevents file contention.
Unit ug_tsfileio;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_tsfileio.pp'}
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
uses 
//=============================================================================
classes
,syncobjs
,ug_misc
,sysutils
,ug_jfc_xdl
,ug_common
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
// Hardcoded Buffer Size for Block Reads. Because the buffer is allocated
// as an array in the routines that work with Untyped File Block Reads
// on the stack versus dynamically allocating the ram; this value is used to 
// dictate the size of those buffers. Feel free to change as needed just
// remember the value applies to all programs that link to this unit and use 
// the Untyped File Block Write/Read functions.

//const BLOCKREADBUFFERSIZETM=1048575;//1048576;
const BLOCKREADBUFFERSIZETM=524288;
//const BLOCKREADBUFFERSIZETM=131072; // best for large harddrives and fast fileio
//const BLOCKREADBUFFERSIZETM=65536; // best for large harddrives and fast fileio
//const BLOCKREADBUFFERSIZETM=256; // more likely to work on smaller flash drives and the like


var gu2LastFileExistIOResult: word;

//=============================================================================
{}
// Init this Unit.
Procedure InitTSFileIO(
  p_iMaxFileHandles:longint;
  p_iRetryLimit: longint;
  p_iRetryDelayInMSec: longint
);
//=============================================================================
{}
// Finish Using this Unit
Procedure DoneTSFileIO;
//=============================================================================
{}
// open text file
function bTSOpenTextFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: text;
  p_bReadOnly: boolean;
  p_bAppend: boolean // ignored if p_bReadOnly = TRUE 
):boolean;
//=============================================================================
{}
// close a textfile
function bTSCloseTextFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: text 
):boolean;
//=============================================================================
{}
// Open untyped file.
function bTSOpenUTFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: file;
  p_u4SizeOfRecords: cardinal;
  p_bReadOnly: boolean;
  p_bReset: boolean//< alternate is rewrite, but ignored if p_bReadOnly = TRUE
):boolean;
//=============================================================================
{}
// Close opened untyped file.
function bTSCloseUTFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: file 
):boolean;
//=============================================================================
{}
// Reserve a File Handle. Your Responsibilitiy to free it.
// Note this is just a counter to allow "throttling" opened files.
function bTSReserveFileHandle(p_saFilename: ansistring; p_bReadOnly: boolean):boolean;
//=============================================================================
{}
// Returns # of unused file handles. !!Note!! this is a counter, not OS 
// filehandle #'s !!!
function iTSFileHandlesLeft: longint;
//=============================================================================
{}
// Number of "FileIO" (NOT OS!!) FILEHANDLES.
function iTSMaxFileHandles:longint;
//=============================================================================
{}
// Read one block from UT file
// UT = Untyped File
function bTSReadUTBlock(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring;
  var p_u4NumRead: longword
):boolean;
//=============================================================================
{}
// Loads Entire File. Preface with bTSOPenUTFile, follow with bTSCloseUTFile
// UT = Untyped File
function bTSLoadUTFile(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring
):boolean;
//=============================================================================
{}
// Saves Entire File. Preface with bTSOPenUTFile, follow with bTSCloseUTFile
// UT = Untyped File
function bTSSaveUTFile(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring
):boolean;
//=============================================================================
{}
// Handles open, load, and close for you.
function bTSLoadEntireFile(
  var p_saFilename: ansistring; 
  var p_u2IOResult: word; 
  var p_saFileData: ansistring
): boolean; 
//=============================================================================

//=============================================================================
// Handles open, load, and close for you.
function bTSSaveEntireFile(
  var p_saFilename: ansistring;
  var p_u2IOResult: word;
  var p_saFileData: ansistring
): boolean;
//=============================================================================



//=============================================================================
{}
// THREADSAFE Version of bIOAppend
// append an ansistring to existing file - or write new file using it
// this variation does not return error code, just true if successful
Function bTSIOAppend(
  p_saFilename: AnsiString;
  p_saData: AnsiString
): Boolean;
//=============================================================================
{}
// THREADSAFE Version of bIOAppend
// append an ansistring to existing file - or write new file using it
// this variation returns the IORESULT - see saIOResult function.
Function bTSIOAppend(
  p_saFilename: AnsiString;
  p_saData: AnsiString;
  var p_u2IOResult: Word
): Boolean;
//=============================================================================
{}
// This needs to be used prior to setting the FileMode flag of FPC when  
// developing multi-threaded applications because it's a global variable
// and this is the Jegas API way of preventing different threads of changing
// this variable on the fly making it corrupt.
var CSECTION_FILEREADMODEFLAG: TCriticalSection;
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
  pvt_bTSFileIOInitialized: boolean;
  pvt_iMaxFileHandles:longint;
  pvt_iRetryLimit: longint;
  pvt_iRetryDelayInMSec: longint;
  CSECTION_FILEHANDLE: TCriticalSection;
  
  pvt_FIOXDL: JFC_XDL;// This XDL Tracks OPEN Files Internally in the unit.
  //-- JFC_XDLITEM
    // UID: longint; // Unique ID - AutoNumber Handled For you ... "primary Key"
    // saName: AnsiString; // Serves as FILENAME
    // saValue: AnsiString;
    // saDesc: AnsiString;
    // iUser: longint; // SET to 0 For READONLY, Set to 1 for any kind of
                       // Writing.
    // TS:TTIMESTAMP;  // For general Use, but is set by the sysutils' unit NOW
                       // function in the create constructor.

  
//=============================================================================

//=============================================================================


//=============================================================================
// Init this Unit.
//=============================================================================
Procedure InitTSFileIO(
  p_iMaxFileHandles:longint;
  p_iRetryLimit: longint;
  p_iRetryDelayInMSec: longint
);
//=============================================================================
begin
  //riteln('InitFileIOTS(',p_iMaxFileHandles,')');
  if not pvt_bTSFileIOInitialized then
  begin
    //riteln('InitFileIOTS Start up Executed Properly');
    pvt_iMaxFileHandles:=p_iMaxFileHandles;
    pvt_iRetryLimit:=p_iRetryLimit;
    pvt_iRetryDelayInMSec:=p_iRetryDelayInMSec;
    pvt_FIOXDL:=JFC_XDL.Create;
    CSECTION_FILEREADMODEFLAG:=TCriticalSection.Create;
    CSECTION_FILEHANDLE:=TCriticalSection.Create;
    pvt_bTSFileIOInitialized:=true;
  end;
end;
//=============================================================================


//=============================================================================
// Finish Using this Unit
Procedure DoneTSFileIO;
//=============================================================================
begin
  if pvt_bTSFileIOInitialized then
  begin
    pvt_FIOXDL.Destroy;pvt_FIOXDL:=nil;// Doesn't close Files!
    pvt_iMaxFileHandles:=0;
    pvt_iRetryLimit:=0;
    pvt_iRetryDelayInMSec:=0;
    CSECTION_FILEREADMODEFLAG.Destroy;CSECTION_FILEREADMODEFLAG:=nil;
    CSECTION_FILEHANDLE.Destroy;CSECTION_FILEHANDLE:=nil;
    pvt_bTSFileIOInitialized:=false;
  end;
end;
//=============================================================================



//=============================================================================
function bTSOpenTextFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: text;
  p_bReadOnly: boolean;
  p_bAppend: boolean // ignored if p_bReadOnly = TRUE 
):boolean;
//=============================================================================
begin
  p_u2IOResult:=0;result:=false;
  if bTSReserveFileHandle(p_saFilename, p_bREadOnly) then
  begin
    {$I-}
    //assign(p_F, p_saFilename);
    assignfile(p_F, p_saFilename);
    CSECTION_FILEREADMODEFLAG.Enter;
    // This implementation has two modes, not dual READ/WRITE.
    if p_bREadOnly then
    begin
      filemode:=READ_ONLY;
      reset(p_f);// Don't think I need the buffer counter second paramer like 
                 //for the block read stuff.
    end
    else
    begin
      filemode:=Write_Only;
      if(p_bAppend)then
      begin
        If FileExists(p_saFilename) Then Begin
          append(p_F);
        End Else Begin
          rewrite(p_F);
        End;
      end
      else
      begin
        rewrite(p_F);
      end;
    end;
    p_u2IOREsult:=ioresult;
    result:=p_u2IOREsult=0;
    CSECTION_FILEREADMODEFLAG.Leave;
    {$I+}
  end; 
end;
//=============================================================================

//=============================================================================
function bTSCloseTextFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: text 
):boolean;
//=============================================================================
var
  saFilename: ansistring;
begin
  result:=false;
  {$ifdef win32}
  safileName:=upcase(p_saFileName);
  {$else}
  safilename:=p_saFilename;
  {$endif}
  CSECTION_FILEHANDLE.Enter;
  if pvt_FIOXDL.FoundItem_saName(saFilename,TRUE) then
  begin
    result:=true;
    pvt_FIOXDL.DeleteItem;
    {$I-}
    close(p_F);
    {$I+}
    p_u2IOResult:=ioresult;
  end;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================







//=============================================================================
function bTSOpenUTFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: file;
  p_u4SizeOfRecords: cardinal;
  p_bReadOnly: boolean;
  p_bReset: boolean// alternate is rewrite, but ignored if p_bReadOnly = TRUE
):boolean;
//=============================================================================
begin
  p_u2IOResult:=0;result:=false;
  if bTSReserveFileHandle(p_saFilename, p_bReadOnly) then
  begin
    {$I-}
    assign(p_F, p_saFilename);
    CSECTION_FILEREADMODEFLAG.Enter;
    if p_bREadOnly then
    begin
      filemode:=READ_ONLY;
      reset(p_f, p_u4SizeOfRecords);
    end
    else
    begin
      filemode:=WRITE_ONLY;// Only Two Modes this implementation READ_ONLY 
                           // or WRITE_ONLY.
      if(p_bReset)then
      begin
        reset(p_F, p_u4SizeOfRecords);
      end
      else
      begin
        rewrite(p_F, p_u4SizeOfRecords);
      end;
    end;
    p_u2IOREsult:=ioresult;
    result:= (p_u2IOREsult = 0);
    CSECTION_FILEREADMODEFLAG.Leave;
    {$I+}
  end; 
end;
//=============================================================================

//=============================================================================
function bTSCloseUTFile(
  p_saFilename: Ansistring; 
  var p_u2IOResult: word; 
  var p_F: file 
):boolean;
//=============================================================================
var
  saFilename: ansistring;
begin
  result:=false;
  {$ifdef win32}
  safileName:=upcase(p_saFileName);
  {$else}
  safilename:=p_saFilename;
  {$endif}
  CSECTION_FILEHANDLE.Enter;
  if pvt_FIOXDL.FoundItem_saName(saFilename,TRUE) then
  begin
    result:=true;
    pvt_FIOXDL.DeleteItem;
    {$I-}
    close(p_F);
    {$I+}
    p_u2IOResult:=ioresult;
  end;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================









//=============================================================================
// Reserve a File Handle. Your Responsibilitiy to free it.
// Note this is just a counter to allow "throttling" opened files.
function bTSReserveFileHandle(p_saFilename: ansistring; p_bReadOnly: boolean):boolean;
//=============================================================================
var 
  iRetries: longint;
  saFilename: ansistring;
begin
  result:=false; iRetries:=0;
  {$ifdef win32}
  safileName:=upcase(p_saFileName);
  {$else}
  safilename:=p_saFilename;
  {$endif}
   
  while (result = false) and (iRetries<=pvt_iRetryLimit) do 
  begin
    // Admittedly a LONG Crit Section! :(
    CSECTION_FILEHANDLE.Enter;
    result:=pvt_FIOXDL.ListCount<pvt_iMaxFileHandles;
    if result then 
    begin
      if(pvt_FIOXDL.FoundItem_i8User(1))then
      begin
        repeat
          if(p_saFilename=pvt_FIOXDL.Item_saName)then result:=false;//File In Use READ/WRITE
        until (result=false) or (pvt_FIOXDL.FNextItem_i8User(1)=false); 
      end;// result will be true if not found in READ/WRITE mode.
     
      if result then
      begin
        if p_bReadOnly then 
        begin
          // If need Read Only - We Good!
        end
        else
        begin
          // Ok we need Read/Write.. let's insist no "readers" going.
          // Note - Case Sensitive flag being true is ok for win32 and linuz
          // cuz we handle this above and during the append below
          // so we don't have to keep calling UpCase constantly.
          if(pvt_FIOXDL.FoundItem_saName(saFilename,TRUE))then result:=false;
        end;
      end;
      
      if result then // if still TRUE result - we good! Claim it! 
      begin
        pvt_FIOXDL.AppendItem;
        pvt_FIOXDL.Item_saName:=saFilename;
        if p_bReadOnly then 
        begin
          pvt_FIOXDL.Item_i8User:=0;
        end
        else
        begin
          pvt_FIOXDL.Item_i8User:=1;
        end;
      end;
    end;
    CSECTION_FILEHANDLE.Leave;

    if not result then 
    begin
      iRetries+=1;
      Yield(pvt_iRetryDelayInMSec);
    end;
  end;
end;
//=============================================================================



//=============================================================================
// Returns # of unused file handles. !!Note!! this is a counter, not OS 
// filehandle #'s !!!
function iTSFileHandlesLeft: longint;
//=============================================================================
begin
  CSECTION_FILEHANDLE.Enter;
  result:=pvt_iMaxFileHandles-pvt_FIOXDL.ListCount;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================

//=============================================================================
function iTSMaxFileHandles:longint;
//=============================================================================
begin
  CSECTION_FILEHANDLE.Enter;
  result:=pvt_iMaxFileHandles;
  CSECTION_FILEHANDLE.Leave;
end;
//=============================================================================



//=============================================================================
function bTSReadUTBlock(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring;
  var p_u4NumRead: longword
):boolean;
//=============================================================================
var 
  b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  lpB: pointer;
  lpSA: pointer;
 u4OldLen: LongWord;

begin
  result:=false;
  {$I-}
  blockread(p_F,b,BLOCKREADBUFFERSIZETM,p_u4NumRead);
  {$I+}
  p_u2IOResult:=ioresult;
  iF(p_u2IOResult=0)then
  begin
    u4OldLen:=length(p_saFileData);
    setlength(p_saFileData, u4OldLen+p_u4NumRead);
    //lpB:=@b;lpSA:=pointer(LongWord(pointer(p_saFileData))+u4OldLen);
    lpB:=@b;lpSA:=pointer(p_saFileData);
    move(lpB^,lpSA^,p_u4NumRead);
    result:=true;
  end;
end;
//=============================================================================


//=============================================================================
function bTSLoadUTFile(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring
):boolean;
//=============================================================================
var 
  b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  lpB: pointer;
  lpSA: pointer;
  u4NumRead:longword; 
  uOldLen: UINT;
begin
  p_saFileData:='';
  result:=false; p_u2IOResult:=0;u4NumRead:=0;uOldLen:=0;
  While (p_u2IOResult=0) and (not Eof(p_F)) Do Begin
    {$I-}
    blockread(p_F,b,BLOCKREADBUFFERSIZETM,u4NumRead);
    {$I+}
    p_u2IOResult:=ioresult;
    iF(p_u2IOResult=0)then
    begin
      uOldLen:=length(p_saFileData);
      setlength(p_saFileData, uOldLen+u4NumRead);
      lpB:=@b;
      lpSA:=pointer(UINT(pointer(p_saFileData))+uOldLen);
      move(lpB^,lpSA^,u4NumRead);
    end
    else
    begin
      //riteln('Block Read issue:',saIOResult(p_u2IOREsult));
    end;
  End;
  result:=(p_u2IOResult=0);
end;
//=============================================================================





//=============================================================================
function bTSSaveUTFile(
  var p_u2IOResult: word;
  var p_F: file;
  var p_saFileData: ansistring
):boolean;
//=============================================================================
var
  //b: array [0..BLOCKREADBUFFERSIZETM] of Byte;
  //lpB: pointer;
  //lpSA: pointer;
  u4NumWritten:longword;
  //uOldLen: UINT;
  i: cardinal;
begin
  result:=false; p_u2IOResult:=0;u4NumWritten:=0;
  for i:=1 to length(p_saFileData) do
  begin
    {$I-}
    blockwrite(p_F,byte(p_saFileData[i]),1,u4NumWritten);
    {$I+}
    p_u2IOResult:=ioresult;
    iF(p_u2IOResult<>0)then break;
  End;
  result:=(p_u2IOResult=0);
end;
//=============================================================================






//=============================================================================
// Handles open, load, and close for you.
function bTSLoadEntireFile(
  var p_saFilename: ansistring; 
  var p_u2IOResult: word; 
  var p_saFileData: ansistring
): boolean; 
//=============================================================================
var F: file;
u2IOResultLast: word;
begin
  result:=bTSOpenUTFile(p_saFilename,p_u2IOResult,F,1,true,true);
  if result then bTSLoadUTFile(p_u2IOResult, F, p_saFileData); 
  if bTSCloseUTFile(p_saFilename, u2IOResultLast, F) and result then
  begin
    p_u2IOResult := u2IOResultLast;
  end;
end; 
//=============================================================================




//=============================================================================
// Handles open, load, and close for you.
function bTSSaveEntireFile(
  var p_saFilename: ansistring;
  var p_u2IOResult: word;
  var p_saFileData: ansistring
): boolean;
//=============================================================================
var F: file;
u2IOResultLast: word;
begin
  result:=bTSOpenUTFile(p_saFilename,p_u2IOResult,F,1,false,false);
  if result then bTSSaveUTFile(p_u2IOResult, F, p_saFileData);
  if bTSCloseUTFile(p_saFilename, u2IOResultLast, F) and result then
  begin
    p_u2IOResult := u2IOResultLast;
  end;
end;
//=============================================================================








//=============================================================================
// ThreadSafe version if bIOAppend
// Append an ansistring to existing file - or write new file using it
// this variation does not return error code, just true if successful
Function bTSIOAppend(
  p_saFilename: AnsiString;
  p_saData: AnsiString
): Boolean;
//=============================================================================
Var u2IOresultDummy: Word;
Begin
  u2IOresultDummy:=0;
  Result := bTSIOAppend(p_saFileName, p_saData, u2IOResultDummy);
End; 
//=============================================================================
// ThreadSafe version if bIOAppend
// Append an ansistring to existing file - or write new file using it
// this variation returns the IORESULT - see saIOResult function.
Function bTSIOAppend(
  p_saFilename: AnsiString;
  p_saData: AnsiString;
  var p_u2IOResult: Word
): Boolean;
//=============================================================================
Var Text_File: text;
    iTries: longint;
    bTextFileOpened: Boolean;
    u2LastIOResult: Word;
    u2ClosingIOResult: Word;
Begin
  Result:=False;
  iTries:=0;
  bTextFileOpened:= False;
  p_u2IOResult:= 0;
  repeat
    iTries+=1;
    bTextFileOpened:= bTSOpenTextFile(
      p_saFilename,
      p_u2IOResult,
      Text_File,
      false,
      true//bFileexists(p_saFilename)
    );        
    u2LastIOResult:=ioresult;
    bTextFileOpened:=(u2LastIOResult=0);
    if not bTextFileOpened then
    begin
      //riteln;
      //riteln('IOResult:' + saIOResult(u2LastIOResult)+' Tries: '+inttostr(iTries)+' Max Try: '+inttostr(cnIOAppendMaxTries));
      //riteln('Filename: '+p_saFilename);
      //riteln;
    end;
  Until bTextFileOpened OR (iTries >= cnIOAppendMaxTries);
  If bTextFileOpened Then
  Begin
     {$I-}
     Write(Text_File,p_saData);
     {$I+}
     u2LastIOResult:=ioresult;
     bTSCloseTextFile(
       p_saFilename,
       p_u2IOResult,
       Text_File
     );
     u2ClosingIOResult:=ioresult;
     If u2LastIOResult<>0 Then Begin
       p_u2IOResult:= u2LastIOResult;
     End Else Begin
       p_u2IOResult:= u2ClosingIOResult;
     End;
  End;
  Result:=bTextFileOpened and (p_u2IOResult=0);
End;
//=============================================================================













//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  pvt_bTSFileIOInitialized:=false;
  pvt_iMaxFileHandles:=0;
  pvt_iRetryLimit:=0;
  pvt_iRetryDelayInMSec:=0;
  CSECTION_FILEREADMODEFLAG:=nil;
  CSECTION_FILEHANDLE:=nil;
  pvt_FIOXDL:=nil;// This XDL Tracks OPEN Files Internally in the unit.
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
