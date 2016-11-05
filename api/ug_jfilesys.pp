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
// Jegas' own file storage system. Powerful - but not fully realized. Currently
// only supports block data and streamed data. Designed to be a fixed width
// block file system with speed being paramount goal.
unit ug_jfilesys;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfilesys.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{DEFINE DEBUG_JFSReadStream}
{$IFDEF DEBUG_JFSReadStream}
  {$INFO | DEBUG_JFSReadStream}
{$ENDIF}

{DEFINE DEBUG_JFSWriteStream}
{$IFDEF DEBUG_JFSWriteStream}
  {$INFO | DEBUG_JFSWriteStream}
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
{}
uses
//=============================================================================
{}
  sysutils,
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
// Jegas Filesystem
//=============================================================================
{}
const cnJFS_Base=128;
const cnJFS_RecSizeMinimum=cnJFS_Base;
//{}
////const cnJFS_RecSizeDefault=cnJFS_Base*1;//128 bytes
////const cnJFS_RecSizeDefault=cnJFS_Base*2;//256 bytes
////const cnJFS_RecSizeDefault=cnJFS_Base*4;//512 bytes
{}
const cnJFS_RecSizeDefault=cnJFS_Base*8;//1k
//{}
////const cnJFS_RecSizeDefault=cnJFS_Base*16;//2k
////const cnJFS_RecSizeDefault=cnJFS_Base*32;//4k
////const cnJFS_RecSizeDefault=cnJFS_Base*64;//8k
////const cnJFS_RecSizeDefault=cnJFS_Base*128;//16k
////const cnJFS_RecSizeDefault=cnJFS_Base*256;//32k
////const cnJFS_RecSizeDefault=cnJFS_Base*512;//64k
{}

const cnJFS_BufSizeDefault=cnJFS_RecSizeDefault*16384;
//const cnJFS_BufSizeDefault=cnJFS_RecSizeDefault*3;

const cnJFS_RecType_Header=0;
const cnJFS_RecType_Stream=1;
{}
// Makes DEFAULT "Always Safe" Descriptor
// Every "Record" has one
type rtJFS = packed record
  u4RecType: LongWord;
End;
{}
type rtJFSHdr = packed record
  u4RecType: LongWord;//<cnJFS_RecType_Header
  u4RecSize: LongWord;
  s: String[120];
End;
{}
const cnJFSSTREAMREC_HDROFFSET=7;
{}
// IMPORTANT TO MAKE CORRECT FOR NOW
// UNTIL Logic put in place to calc where the achStream thing is.
// basically size of header fields BEFORE achStream less one.
type rtJFSStream = packed record
  u4RecType: LongWord;//<cnJFS_RecType_Stream

  u8BytesRemaining: UINT64;

  achStream: array [1..1] of char;{< place to point to for refernce
   use the Bytes Remaining field to indicate a stream still
   going by being larger than can fit in the record.
   rec 1 of 2 or 120 byte records my say 200 bytes remaining
   in record 1, and (128byte record-8byte header-120)=remaining
   in record 2.}
End;

{}

const cnJFSMode_Read=0;      //< FPC FileMode matches
const cnJFSMode_Write=1;     //< FPC FileMode matches
const cnJFSMode_ReadWrite=2; //< FPC FileMode matches
//
{}
type rtJFSFile = packed record
  F: file;
  u1Mode: byte; //<0=read  1=write  2=read/write
  saFileName: AnsiString;
  bFileOpen: boolean; //< true if file open.

  // Records
  {}
  u4RecSize: LongWord; //< Size of records - Must be =< buffer size
  u4BufRow: LongWord; //< Offset - Starts at Zero
  u4RowsInBuffer: LongWord; //< How many actual records in the buffer
  uRow: UInt; //< Current ROW, First record = 1

  // Buffer Blocks
  {}
  u4BufSize: LongWord; //< Size of Buffer Block
  lpBuffer: pointer; //< pointer to Buffer
  bBufModified: boolean; {< True if Records in Buffer
   Modified and the buffer needs to be written.}

  uRawOffset: UInt; {< For use with WriteStream
   bytes out as RAW records. You can start a new batch by
   "writebuffernow" to reset everything in the buffer,
   but for continuous stream - just keep calling WriteStream.
   Leave this field alone - it tracks where it is in each
   record as it moves along. Fast append is used internally
   to handle the buffers in memory and when to write them
   the Write Raw handles chunking the data into each "record"
   within its "size" constraints, BUT returns "unfinished"
   waiting for more data. If you are addressing writing out
   raw binary in streams - note there isn't anything multi
   user about it yet, nor is it ok to do some of this, then
   something else, then comeback (concerning your JFS file)
   Before you start, write buffers or invalidate them,
   seek a position in the file - and GO!!!!!!!!
   keeping streaming data until you have no more by looping
   and calling the WriteStream routine. when your stream is done
   writebuffernow to commit what ya have.}
  {}
  // Last Error Result captured from IOResult
  u2IOResult: word;

  //rJFS: ^rtJFS;
  //rJFSHdr: ^rtJFSHdr;
  //rJFSRaw: ^rtJFSStream;
  lpRecord: pointer;
End;






//
////=============================================================================
////=============================================================================
////=============================================================================
//// THE CALLS
////=============================================================================
////=============================================================================
////=============================================================================






////=============================================================================
{}
// Initializes the passed rtJFSFile structure with defaults. Override them
// before calling open if you want the system to performa correctly with,
// for example, larger record sizes.
procedure JFSClearFileInfo(var p_rJFSFile: rtJFSFile);
////=============================================================================
{}
// Opens the file - and the work you need to do to make this work right
// is this:
//
//  1st: Set up a rtJFSFile record as a variable.
//       e.g.: var rJFSFile: rtJFSFile;
//
//  2nd: Make sure you initialize your new record structure to defaults.
//       e.g. InitJFS(rJFSFile);
//
//  3rd: Assign a VALID filename (For reads, it should exist already obviously)
//       e.g. rJFSFile.saFilename:='testfile.bin';
//
//  4th: Give it a mode
//       e.g. rJFSFile.u1Mode:=cnJFSMode_Read;
//
// IMPORTANT: you can override the default (compiled contants values)
// for the record size and buffersizes by changing the values of these
// fields before opening the file. The call to bJFSOpen will allocate the
// memory for you. bJFSClose will release the memory for you.
function bJFSOpen(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
{}
// This function obviously closes the file, but also releases the allocated
// memory for the file buffer.
procedure JFSClose(var p_rJFSFile: rtJFSFile);
//=============================================================================
{}
// This is an index into the file. Low Level FPC uses 0 to indicate first
// record. We use 1 to indicate the first record to stay alligned with
// the u4Row variable in the rtJFSFile record structure. This also seems
// intuitive to me when thinking in terms of databases. The first record
// is always referred to as record 1 in my experience. The fact that we
// use a header record doesn't change this because this lib is at that level.
//
// This function is only called internally (and should only be called by
// you, when you want to force going to a specific record in the file,
// in preperation for reloading the buffer. Using this function to get
// around is only efficient when you know where you MUST go and WHY!
//
// MoveFirst and MoveNext are a bit more refined and are a little higher level
// and have some logic built in to them to make them work as you would expect.
// At least I'm planning on making them do so next - 2006-07-21 Jason P Sage
function bJFSSeek(var p_rJFSFile: rtJFSFile;p_uSeekRecord:uint): boolean;
//=============================================================================
{}
function bJFSEOF(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
{}
// This Appends a Record in Buffer, then when full
// writes entire buffer, and reset the counter for the next
// buffer full. Very Fast - not a multi-user thing...
// great for cranking out data though.
function bJFSFastAppend(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
{}
// This is similiar to fast append - and is great for
// reading a lot of records quickly. Every time it is
// called, if the buffer is empty, it loads it, and
// sets the record position to the first record in the
// buffer, subsequent calls move record pointers to the next
// record. Once it cant go any further, the process starts
// over again.
function bJFSFastRead(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
{}
// From WHERE ever the file position is, write records known
// to be in buffer starting with first in the buffer
//
// This means if you have 4 records in the buffer, but only
// really manipulated any one of them, all the records get written
// in the buffer. It doesn't matter which record in the buffer you
// were on when you called this routine, the buffer gets written.
function bJFSWriteBufferNow(p_rJFSFile: rtJFSFile):boolean;
//=============================================================================
{}
// Unlike a normal "Current" record function, this function returns a
// calculated pointer that points to the first byte of the current record.
// You can type cast record structures over this value.
function lpJFSCurrentRecord(var p_rJFSFile: rtJFSFile): pointer;
////=============================================================================
{}
// (bJFSWriteStream function description)
// This is a wonderful function, however you need to be aware of its inner
// workings to really get the most of it. BASICALLY - it allows you to
// send big or small streams of data to the file. How it works, is meant
// to make this operation as simple as possible for storing streams of
// data. I'm not sure my use of the word stream is technically accurate,
// but this function allows you to send big or small blocks of information,
// BYTES, to the open file, without being REQUIRED to worry about the current
// buffer size, or the record size. This function is the only record structure
// so far (as of 2006-07-22) in this unit that has its own support built in.
// Seeing how the goal of this unit is to stay lean, there probably won't
// be to much more - except maybe some multi user stuff added to what
// exists now.
//
// I'm trying to summerize what this function does "mechanically". ahh..
// First thing to remember is that with a clean slate, (after a call to
// bJFSWriteBufferNow, opening the file, or setting rtJFSFile.uRawOffset=0
// this function starts writing into the current record, past the record
// header bytes + uRawOffset. This means basically that when uRawOffset=0
// that the next call to here starts copying the data from uRawOffset
// for as far as it can before reaching the end of the record size, at which
// point it automatically advances to the next record and continues.
// (When the buffer gets full, it gets written.)
//
// Anyway, an important thing to remember, is that when this function
// leaves, you might of happened to stop writing right smack in the middle
// of a record. That is ok. Thats what the uRawOffset is for, its a bookmark.
// This means you can call this function again, with more data, and it
// will manage when to move to the next record and when to write the buffer
// out etc. As far as your written data appears, it will be contiguous.
//
// IMPORTANT: Each record written out, using this method has a record type
// of RAW. The RAW Record Type Header has a field named BYTES REMAINING.
// This is only 100% accurate WHEN this VALUE is less than or EQUAL to
// (RECORDSIZE-HEADERSIZE). The VALUE has a purpose on other records also.
// Let's say you saved one stream of data spanning two records.
// on the first record, the BYTES REMAINING value is guaranteed to be larger
// than (RECORDSIZE-HEADERSIZE). That is how the function named bJFSReadStream
// knows it can keep going during a read (direct opposite of this function).
// In the 2nd record, the BYTEREMAINING field (in rtJFSFile) is 100%
// accurate.
//
// You could say that a contigous stream of bytes can be written using
// this function as if you were just appending a raw binary file.
//
// The bJFSReadStream does exactly the opposite.
//
// Note: One application of this would be to save what are referred to
// as MEMO fields or BLOBs in database nomenclature. I personally plan
// on using this as a way of storing various data fields in a stream
// in such a manner so that I can read them back and recreate them in
// memory.
//
// For instance.. to store two ansistrings, I might write the 4 bytes to
// indicate a 32bit length, and then stream in the whole ansistring.
//
// when reading the information back, I'll snag the length value (4 bytes)
// and then use that to read the ansistring back from the disk!
// phew - enough on this function. 2006-07-21 Jason P Sage
//
// Wait one more comment - remember internally this routine does direct
// memory moving - so - you better know what your doing when you
// pass it a pointer to where your data is and the length you want written.
function bJFSWriteStream(
  var p_rJFSFile: rtJFSFile;
  p_ptrSrc: pointer;
  p_uHowMany: UINT
  ): boolean;
//=============================================================================
{}
// So in theory you can start calling this when rJFSFile.uRawOffset=0
// This does the very opposite of bJFSWrite Raw, but the important
// difference is that this call only returns what is available up
// to the ammount you indicate you want in the p_u4HowMany variable.
//
// upon return, p_u4HowMany contains the value that was actually read.
//
// Note: just like the bJFSWriteStream, this function does direct memory
// moving - so - you better know what you're doing when you pass it a
// pointer and have a valid destination for the amount of bytes you
// want moved from the file into your memory area.
function bJFSReadStream(
  var p_rJFSFile: rtJFSFile;
  p_ptrDest: pointer;
  var p_uHowMany: UINT
  ): boolean;
//=============================================================================
{}
// writes many of the rtJFSFile record structure values to
// stdout for debugging. To save bytes, don't call this routine unless you
// must in your compiled program, I mean, don't even refer to it.. this
// way the smartlinker won't include the code (which has text in it)
// in your compiled application. (This statement relies on FPC smartlinking)
procedure DebugJFSFile(p_rJFSFile: rtJFSFile);
//=============================================================================
{}
function bJFSMoveFirst(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
{}
function bJFSMoveLast(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
{}
function bJFSMovePrevious(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
{}
function bJFSMoveNext(var p_rJFSFile: rtJFSFile):boolean;
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
procedure JFSClearFileInfo(var p_rJFSFile: rtJFSFile);
//=============================================================================
Begin
  with p_rJFSFile do Begin
    u1Mode:=cnJFSMode_Read;
    saFileName:='';
    bFileOpen:=false;

    // Records or "raw records"
    u4RecSize:=cnJFS_RecSizeDefault;
    u4BufRow:=0;
    u4RowsInBuffer:=0;
    uRow:=0;

    u4BufSize:=cnJFS_BufSizeDefault;
    lpBuffer:=nil;
    bBufModified:=false;
    uRawOffset:=0;
    u2IOResult:=0;

    lpRecord:=nil;
  End;
End;
//=============================================================================



//=============================================================================
procedure GetTheMem(var p_rJFSFile: rtJFSFile);
//=============================================================================
Begin
  with p_rJFSFile do Begin
    getmem(lpBuffer, u4BufSize);
    lpRecord:=lpBuffer;
    rtJFSHdr(lpRecord^).s:='Jegas File System';
  End;
End;
//=============================================================================


//=============================================================================
procedure SyncTheMem(var p_rJFSFile: rtJFSFile);
//=============================================================================
var u4BufPos: LongWord;
Begin
  with p_rJFSFile do Begin
    u4BufPos:=(u4BufRow*u4RecSize);
    lpRecord:=pointer(UINT(lpBuffer)+u4BufPos);
  End;
End;
//=============================================================================



//=============================================================================
procedure FreeTheMem(var p_rJFSFile: rtJFSFile);
//=============================================================================
Begin
  with p_rJFSFile do Begin
    freemem(lpBuffer);
    lpBuffer:=nil;
    lpRecord:=nil;
  End;
End;
//=============================================================================

procedure DebugJFSFile(p_rJFSFile: rtJFSFile);
Begin
  with p_rJFSFile do Begin
    Writeln('-DEBUG-JFSFILE-BEGIN-');
    Writeln('u1Mode:         ',u1Mode);
    Writeln('saFileName:     ',saFilename);
    Writeln('bFileOpen:      ',bFileOpen);
    Writeln('u4RecSize:      ',u4RecSize);
    Writeln('u4BufRow:       ',u4BufRow);
    Writeln('uRow:          ',uRow);
    Writeln('u4BufSize:      ',u4BufSize);
    Writeln('u4RowsInBuffer: ',u4RowsInBuffer);
    Writeln('lpBuffer:       ',UINT(lpBuffer));
    Writeln('u2IOResult:     ',u2IOResult);
    Writeln('lpRecord:       ',UINT(lpRecord));
    Writeln('-DEBUG-JFSFILE-END-');
    Writeln;
  End;
End;


//=============================================================================
function bJFSOpen(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var 
  achT: array [0..127] of char;
  bOk: boolean;
  i2TRead: SmallInt;
Begin
  bOk:=false;
  p_rJFSFile.lpRecord:=nil;
  with p_rJFSFile do Begin
    bOk:=false;
    // What Mode ?
    //-----------------------------------------------------------------
    if (u1Mode=cnJFSMode_Read) or (u1Mode=cnJFSMode_ReadWrite) then
    Begin
    //-----------------------------------------------------------------
      bOk:=true;
      assign(f,saFilename);
      // Open it for reading the Record Type
      if bOk then
      Begin
        filemode:=cnJFSMode_Read;
        try reset(f,cnJFS_Base); except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        bOk:=u2IOResult=0;
      End;

      // Read first 128 bytes
      if bOk then
      Begin
        //riteln('blockread1-');
        {$I-}
        i2TRead:=1;
        try blockread(f, acht, 1, i2TRead); except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        {$I+}

        //ebugJFSFile(p_rJFSFile);

        lpRecord:=@acht;// Make our pointers point to array of char

        // use as staging area for decyphering the header (first 128 bytes)
        bOk:=u2IOResult=0;
        if bOk then bOk:=i2TRead=1;
        if bOk then bOk:=rtJFS(lpRecord^).u4RecType=cnJFS_RecType_Header;
        if bOk then Begin
          u4RecSize:=rtJFSHdr(lpRecord^).u4RecSize;
          if u4RecSize>u4BufSize then
          Begin
            u4BufSize:=u4RecSize;
          End;
          try reset(F,u4RecSize);except on E:Exception do u2IOResult:=60000; end;//try
          u2IOResult+=ioresult;
        End;
        bOk:=u2IOResult=0;
      End;

      if bOk then
      Begin
        //riteln('success read finishing up-');
        bFileOpen:=true;
        lpRecord:=@acht;// SAME for HEADER RECORD overlay.
        u4RecSize:=rtJFSHdr(lpRecord^).u4RecSize;
        GetTheMem(p_rJFSFile);
        {$I-}
        try reset(f,u4RecSize);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;

        if u2IOResult= 0 then
        begin
          try Seek(f,0);except on E:Exception do u2IOResult:=60000; end;//try
          u2IOResult+=IOResult;
        end;
        {$I+}
       bOk:=u2IOResult=0;
      End;
    //-----------------------------------------------------------------
    End;
    //-----------------------------------------------------------------
    
    
    
    //-----------------------------------------------------------------
    if (u1Mode=cnJFSMode_Write) or (u1Mode=cnJFSMode_ReadWrite) then
    Begin
    //-----------------------------------------------------------------
      bOk:=true;
      //riteln('Write and readwrite mode stuff');
      // Assign It
      assign(f,saFilename);
      // Create Header Record
      //riteln('In Write mode - gonna make the header record');
      if (u1Mode=cnJFSMode_Write) then
      Begin
        //riteln('About to allocate some memory');
        GetTheMem(p_rJFSFile);
        //riteln('Allocated some memory - now to modify some values');
        rtJFSHdr(lpRecord^).u4RecType:=cnJFS_RecType_Header;
        rtJFSHdr(lpRecord^).u4RecSize:=u4RecSize;
        //riteln('Ok so far - now to rewrite(f,u4RecSize)');
        try rewrite(f,u4RecSize);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        //riteln('rewrite(f,u4RecSize) 1118 IOResult:',u2IOResult,' u4RecSize=',u4RecSize);
      End
      else
      Begin
        filemode:=cnJFSMode_ReadWrite;
        try reset(f, u4RecSize);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        //riteln('RESET 1116 returned IOResult:',u2IOResult,' u4recSize=',u4RecSize);
      End;
      //riteln('Trying to Seek f,0');
      //i4SeekZero:=0;
      try Seek(f,0);except on E:Exception do u2IOResult:=60000; end;//try
      u2IOResult+=IOResult;
      //riteln('Seek returned IOResult:',u2IOResult);
      //riteln('It seeked... hahaha');
      if (u2IOResult=0) and (u1Mode=cnJFSMode_Write) then
      Begin
        writeln('We are in write mode - so we need to write the record header:',uint(lpBuffer));
        i2TRead:=1;// Just write the correct one Record;
        {$I-}
        try blockwrite(f, lpBuffer^, 1, i2TRead);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        {$I+}
        //riteln('It should have written.. just executed a blockwrite');
      End;
      u4RowsInBuffer:=0;
      u4BufRow:=0;
      uRow:=0;
      bFileOpen:=u2IOREsult=0;
    //-----------------------------------------------------------------
    End;
    //-----------------------------------------------------------------
    
    
    if not bOk then
    Begin
      //riteln('JFSOPEN FAILED');
      //ebugJFSFile(p_rJFSFile);
      //riteln('JFSOPEN FAILED');
      JFSClose(p_rJFSFile);
    End
    else
    Begin
      //riteln('JFSOPEN SUCCEEDED');
      //ebugJFSFile(p_rJFSFile);
      //riteln('JFSOPEN SUCCEEDED');
    End;
  End;
  SyncTheMem(p_rJFSFile);
  result:=bOk;
End;
//=============================================================================

//=============================================================================
procedure JFSClose(var p_rJFSFile: rtJFSFile);
//=============================================================================
Begin
  with p_rJFSFile do Begin
    if lpBuffer<>nil then
    Begin
      if bFileOpen then
      Begin
        try close(f);except on E:Exception do;end;//try
        FreetheMem(p_rJFSFile);
      End;
    End;
    bFileopen:=false;
  End;//with
End;
//=============================================================================


//=============================================================================
function bJFSFastRead(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var //u4BufPos: LongWord;
    u4NumToLoad: LongWord;
    u4NumLoaded: LongWord;
    bOk: boolean;
Begin
  bOk:=false;
  with p_rJFSFile do Begin
    if bFileOpen and 
       (u1Mode=cnjfsmode_read) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      if u4RowsInBuffer=0 then
      Begin
        u4BufRow:=0;
      End
      else
      Begin
        u4BufRow+=1;// move to next record position in buffer.
      End;
      // No pointer math here - but basically checking if 
      // INSIDE buffer still
      if (u4BufRow>=u4RowsInBuffer) then
      Begin
        // RELOAD BUFFER WITH NEXT RECORD(S)
        if not Eof(f) then
        Begin
          //riteln('----LOADING BUFFER----Row:',uRow);
          u4BufRow:=0;
          {$I-}
          u4NumToLoad:=(u4BufSize div u4RecSize);
          try blockread(f, lpBuffer^, u4NumToLoad, u4NumLoaded);except on E:Exception do u2IOResult:=60000; end;//try
          u2IOResult+=IOResult;
          {$I+}
          u4RowsInBuffer:=u4NumLoaded;
          if (u2IOResult=0) and (u4NumLoaded>0) then
          Begin
            bOk:=true;
          End;
        End
        else
        Begin
          // EOF
          bOk:=false;
        End;
      End
      else
      Begin
        bOk:=true;
      End;

      if bOk then
      Begin
        uRow+=1;
        SyncTheMem(p_rJFSFile);
      End;
    End;//if file open etc
  End;//with
  result:=bOk;
End;
//=============================================================================




//=============================================================================
function bJFSWriteBufferNow(p_rJFSFile: rtJFSFile):boolean;
//=============================================================================
var
  u4NumToWrite: LongWord;
  u4NumWritten: LongWord;
  bOk: boolean;
Begin
  bOk:=false;
  with p_rJFSFile do Begin
    //riteln('About to write a row');
    if bFileOpen and 
       (u1Mode=cnjfsmode_Write) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      //Writeln('---WriteBufferNOW----flushing....<schwoooooosh>  uBufRow+1 (forced):',u4BufRow+1);
      // SENDOUT THE BUFFER WITH THE RECORD(S)
      //u4BufRow:=0;
      {$I-}
      //-----------------------
      u4NumToWrite:=u4BufRow+1;
      //------------------------
      try blockwrite(f, lpBuffer^, u4NumToWrite, u4NumWritten);except on E:Exception do u2IOResult:=60000; end;//try
      u2IOResult+=IOResult;
      {$I+}
      if (u2IOResult=0) and (u4NumToWrite=u4NumWritten) then
      Begin
        u4BufRow:=0;
        bBufModified:=false;
        uRawOffset:=0;
        bOk:=true;
      End;
      //riteln('Wrote something out. Flushed!');
    End;
  End;//with
  SyncTheMem(p_rJFSFile);
  result:=bOk;
End;
//=============================================================================


//=============================================================================
function bJFSFastAppend(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var u4BufPos: LongWord;
    u4NumToWrite: LongWord;
    u4NumWritten: LongWord;
    bOk: boolean;
Begin
  bOk:=false;
  with p_rJFSFile do Begin
    //riteln('About to write a row');
    if bFileOpen and 
       (u1Mode=cnjfsmode_Write) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      u4BufRow+=1;// move to next record position in buffer.
      u4BufPos:=(u4BufRow*u4RecSize);
      if u4BufPos>=u4BufSize then
      Begin
        //Writeln('--------------------fastappend flushing....<schwoooooosh>  uBufRow:',u4BufRow);
        //riteln('Need to flush');
        // SENDOUT THE BUFFER WITH THE RECORD(S)
        //u4BufRow:=0;
        {$I-}
        u4NumToWrite:=u4BufRow;
        try blockwrite(f, lpBuffer^, u4NumToWrite, u4NumWritten);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        {$I+}
        if (u2IOResult=0) and (u4NumToWrite=u4NumWritten) then
        Begin
          u4BufRow:=0;
          bBufModified:=false;
          bOk:=true;
        End;
        //riteln('Wrote something out. Flushed!');
      End
      else
      Begin
        bOk:=true;
        bBufModified:=true;
        //riteln('No need to Flush');
      End;

      if bOk then
      Begin
        //riteln('Got some Write success - syncing mem');
        uRow+=1;
        SyncTheMem(p_rJFSFile);
      End;
    End
    else
    Begin
      //riteln('Um...File not open?');
    End;//if file open etc
  End;//with
  result:=bOk;
End;
//=============================================================================

//=============================================================================
function lpJFSCurrentRecord(var p_rJFSFile: rtJFSFile): pointer;
//=============================================================================
var 
  u4OffSet: LongWord;
Begin
  with p_rJFSFile do Begin
    u4Offset:=u4BufRow*u4RecSize;
    if bFileOpen and (u4OffSet<u4BufSize) then //(u4RowsInBuffer>0)
    Begin
      result:=pointer(UINT(lpBuffer) + u4Offset);
    End
    else
    Begin
      result:=nil;
    End;
  End;//with    
End;
//=============================================================================


//=============================================================================
function bJFSSeek(var p_rJFSFile: rtJFSFile; p_uSeekRecord:UINT): boolean;
//=============================================================================
var 
  bOk: boolean;
  //u4FilePos: LongWord;
Begin
  bOk:=false;
  with p_rJFSFile do Begin
    if bFileOpen and 
       (u1Mode=cnjfsmode_read) or 
       ( ((u1Mode=cnjfsmode_write) or (u1Mode=cnjfsmode_readwrite)) and 
         (bBufModified=false)
       )then
    Begin
      {I-}
      //u4FilePos:=FilePos(F);
      //u2IOResult:=IOResult;
      {I+}
      //bOk:=u2IOResult=0;
      
      
      //if bOk then
      //Begin
        {$I-}
        try seek(f,p_uSeekRecord-1);except on E:Exception do u2IOResult:=60000; end;//try
        u2IOResult+=IOResult;
        {$I+}
        bOk:=u2IOResult=0;
      //End;
      
      if bOk then
      Begin
        u4RowsInBuffer:=0;
        u4BufRow:=0;
        uRow:=p_uSeekRecord;
      End;
    End;
  End;//with
  Result:=bOk;
End; 
//=============================================================================


//=============================================================================
function bJFSMoveFirst(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
Begin
  result:=bJFSSeek(p_rJFSFile, 1);
End;
//=============================================================================


//=============================================================================
function bJFSMoveLast(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
Begin
  result:=bJFSSeek(p_rJFSFile,UINT(FileSize(p_rJFSFile.F)));
End;
//=============================================================================

//=============================================================================
function bJFSMovePrevious(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var 
  bOk: boolean;
  uCalcRowsBackward: uint;
  uRowOnEntry: uint;
Begin
  bOk:=true;
  with p_rJFSFile do Begin
    if bFileOpen then
    Begin
      uRowOnEntry:=uRow;
      if uRow>1 then
      Begin
        if u4BufRow>0 then
        Begin
          u4BufRow-=1;
          SyncTheMem(p_rJFSFile);
        End
        else
        Begin
          // Attempt to go backward without flipping over. With unisigned numbers comes GREAT POWER until you flipp it or roll it... no negatives ahhh!
          // but so much more range! twice the amount in fact less one ;)
          uCalcRowsBackward:=u4BufSize div u4RecSize;
          if uCalcRowsBackward>uRow then
          Begin
            // we can jump back a whole buffer block of records,
            // and then adjust the pointers to point to the last record 
            // in the freshly loaded buffer block.
            bOk:=bJFSSeek(p_rJFSFile, uRow-uCalcRowsBackward);
            // OK Should be pointing to the last row in the 
            // buffer.
          End
          else
          Begin
            // We need to just go to the beginning of the file,
            // fill the buffer, and then adjust the pointers to 
            // the correct record.
            bOk:=bJFSSeek(p_rJFSFile, 1);
          End;
          if bOk then
          Begin
            uRow:=uRowOnEntry-1;
            u4BufRow:=u4RowsInBuffer-1;
          End;
        End;
      End
      else
      Begin
        bOk:=false;
      End;
    End;
  End;//with    
  result:=bOk;
End;
//=============================================================================


//=============================================================================
// version 1
//function bJFSEOF(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
//var bEOF: boolean;
//Begin
//  bEOF:=true;
//  try
//    with p_rJFSFile do Begin
//      if bFileOpen then
//      Begin
//        if ((u4BufRow+1)<u4RowsInBuffer) and
//           (not Eof(f)) then bEOF:=false;
//      End;
//    End;//with
//  except on e:Exception do;
//  end;//try
//  result:=bEOF;
//End;
//=============================================================================


//=============================================================================
function bJFSEOF(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var bEOF: boolean;
Begin
  //riteln;
  //riteln('BEGIN - bJFSEOF ---------------');
  //howFileInfo(p_rJFSFile);
  //riteln('BEGIN - bJFSEOF ---------------');

  with p_rJFSFile do Begin
    try
      bEOF:=(not bFileOpen) or eof(f);// or (uBufRow       end of buffer or file...
        //stock-if ((uBufRow+1)< uRowsInBuffer) or
        //   (not Eof(f)) then bEOF:=false;
        // hack2 - if ((uBufRow+1)< uRowsInBuffer) then bEOF:=false;
    except on e:Exception do {NOTHING :) };
    end;//try
  End;//with
  result:=bEOF;
  //riteln('END - bJFSEOF ---------------');
  //ShowFileInfo(p_rJFSFile);
  //writeln('END - bJFSEOF ---------------');

End;
//=============================================================================



//=============================================================================
function bJFSMoveNext(var p_rJFSFile: rtJFSFile):boolean;
//=============================================================================
Begin
  result:=bJFSFastRead(p_rJFSFile);
End;
//=============================================================================






//=============================================================================
// So intheory you can start calling this when rJFSFile.uRawOffset=0
// and you just did a FASTAPPEND (cuz then pointers are on the next record
// to be worked on in the buffer.
//
// Currently only written to succeed during a valid FastAppend run.
// finish a run with "writebuffernow".
function bJFSWriteStream(
  var p_rJFSFile: rtJFSFile; 
  p_ptrSrc: pointer;
  p_uHowMany: UINT
  ): boolean;
//=============================================================================
var 
  bOk: boolean;
//  u4Len: LongWord;
//  uRemaining: LongWord;
//  u4MoveHowMany: LongWord;
//  u4From: LongWord;
// u4t: LongWord;    
var 
  lpRec: pointer;  // BASE OF Current Record
  lpSrc: pointer;  
  lpDest: pointer; // Where to start moving the data to
  uChunkSize: UINT;
  uRemaining: UINT;
Begin
  bOk:=false;
  with p_rJFSFile do Begin
    //riteln('About to write a row');
    if bFileOpen and 
       (u1Mode=cnjfsmode_Write) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      //cnJFSSTREAMREC_HDROFFSET
      lpRec:=lpJFSCurrentRecord(p_rJFSFile);
      rtJFSStream(lpRecord^).u8BytesRemaining:=uRawOffset+p_uHowMany;
      uRemaining:=p_uHowMany;
      lpSrc:=p_ptrSrc;
      
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln;
      Writeln('--WS--DEBUG uxxg_jfilesys.bJFSWriteStream');
      Writeln('--WS----------------------------------');
      Writeln('--WS--lpRec Coming In:                  ',UINT(lpRec));
      Writeln('--WS--uRawOffset:                      ',uRawOffset);
      Writeln('--WS--p_uHowMany:                      ',p_uHowMany);
      Writeln('--WS--uRemaining Starts as p_uHowMany.');
      Writeln('--WS--p_ptrSrc (lp):                    ',UINT(p_ptrSrc));
      Writeln('--WS--lpSrc:                            ',UINT(lpSrc));
      Writeln('--WS----------------------------------');
      Writeln('--WS--Beginning Repeat Loop Next to start chunking.');
      Writeln('--WS----------------------------------');
      Writeln;
      {$ENDIF}
      
      
      repeat
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS----------------------------------');
        Writeln('--WS--TOP OF LOOP');
        Writeln('--WS----------------------------------');
        Writeln('--WS--uRawOffset:                      ',uRawOffset);
        Writeln('--WS--*************The Big Fast Append Descision is below:');
        Writeln('--WS--if uRawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then');
        Writeln('--WS--Offset shown above, and the other part''s value is:',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
        {$ENDIF}
        
        if uRawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then
        Begin
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS---*-*-*-Decision for FastAppend Made');
          Writeln('--WS---uRawOffset:',uRawOffset,'>= (u4RecSize-cnJFSSTREAMREC_HDROFFSET-1):',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
          {$ENDIF}
          
          // Begin New Record
          rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-- rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;');
          {$ENDIF}
          
          rtJFSStream(lpRecord^).u8BytesRemaining:=uRawOffset+uRemaining;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-- rtJFSStream(lpRecord^).u4BytesRemaining:=uRawOffset+uRemaining;');
          Writeln('--WS-- uRawOffset:',uRawOffset,' uRemaining:',uRemaining);
          Writeln('--WS-- rtJFSStream(lpRecord^).u4BytesRemaining:',rtJFSStream(lpRecord^).u8BytesRemaining);
          {$ENDIF}

          uRawOffset:=0;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-- uRawOffset becomes ZERO');
          {$ENDIF}
          
          bOk:=bJFSFastAppend(p_rJFSFile);
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--bFastAppend Returned:bOkss);
          {$ENDIF}
          
          lpRec:=lpJFSCurrentRecord(p_rJFSFile);
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--lpRec (lpJFSCurrentRecord(this file):',LongWord(lpRec));
          {$ENDIF}
        End;
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS---=-=-=--2ndPartOfSameLoop-Past fastappend decision blk');
        Writeln('--WS--lpRec (lpJFSCurrentRecord(this file):',LongWord(lpRec));
        {$ENDIF}
        lpDest:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+uRawOffset+1);
        {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--lpDest:=pointer(LongWord(lpRec)+ cnJFSSTREAMREC_HDROFFSET+uRawOffset+1);');
          Writeln('--WS--lpDest:',UINT(lpDest));
        {$ENDIF}
        uchunkSize:=uRemaining;
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--uchunkSize:=uRemaining;');
        Writeln('--WS--uChunkSize:',uChunkSize);
        Writeln('--WS--uRemaining:',uRemaining);
        Writeln('--WS-----Big chunk Descision---');
        {$ENDIF}
        // ORIGINAL:if ((cnJFSSTREAMREC_HDROFFSET+uRawOffset)+uChunkSize)
        if ((cnJFSSTREAMREC_HDROFFSET+uRawOffset+1)+uChunkSize)
           >
           u4RecSize then
        Begin
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-----HAS decided to shrink chunk size for this iteration');
          {$ENDIF}
          uChunkSize:=(u4RecSize-(cnJFSSTREAMREC_HDROFFSET+uRawOffset)-1);
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-----New uChunkSize:',uChunkSize);
          {$ENDIF}
        End;   
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        {$ENDIF}
        
        move(lpSrc^, lpDest^, uChunkSize);
        
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--move(lpSrc^, lpDest^, uChunkSize);');
        Writeln('--WS--lpSrc:',UINT(lpSrc));
        Writeln('--WS--lpDest:',UINT(lpDest));
        Writeln('--WS--uChunkSize:',uChunkSize);
        Writeln('--WS------------------------------------ Move Done');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        {$ENDIF}
        
        lpSrc:=pointer(UINT(lpSrc)+uChunkSize);
        {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--lpSrc:=lpSrc+uChunkSize  result:',UINT(lpSrc));
        {$ENDIF}
        
        uRawOffset+=uChunkSize;
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS-uRawOffsett+=uChunkSize result uRawOffset:',uRawOffset);
        {$ENDIF}
        
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS-------BEFORE THE LAST DECISION before loop iterates---');
        Writeln('--WS--uChunkSize:',uChunkSize);
        Writeln('--WS--uRemaining:',uRemaining);
        {$ENDIF}

        if uRemaining>=uchunkSize then
        Begin
          uRemaining-=uchunksize;
        End;

        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS-------LLLLLLLLLLLLLLOOOOOOOOOOOOOPPPPPPPPPPPPPP AGAIN ?---');
        Writeln('--WS--uChunkSize:',uChunkSize);
        Writeln('--WS--uRemaining:',uRemaining);
        Writeln('--WS----------------------------');
        Writeln('--WS--Loop goes on again until uRemaining=0;');
        {$ENDIF}
      until uRemaining=0;
      // Note - should go until EQUAL (for exactness)
      bOk:=true;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS--NOTE: uRawOffset is at:',uRawOffset);
      {$ENDIF}
      rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS-- rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;');
      {$ENDIF}
      rtJFSStream(lpRecord^).u8BytesRemaining:=uRawOffset+uRemaining;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS-- rtJFSStream(lpRecord^).u8BytesRemaining:',rtJFSStream(lpRecord^).u8BytesRemaining);
      {$ENDIF}
    End;
    Result:=bOk;
  End;//with
  {$IFDEF DEBUG_JFSWriteStream}
  Writeln('--WS--');
  Writeln('--WS--');
  Writeln('--WS--');
  Writeln('--WS--');
  Writeln('--WS--END OF CALL--------------------------------------------------------');
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  {$ENDIF}
End;
//=============================================================================












//=============================================================================
// So intheory you can start calling this when rJFSFile.uRawOffset=0
//
function bJFSReadStream(
  var p_rJFSFile: rtJFSFile; 
  p_ptrDest: pointer;
  var p_uHowMany: uint
  ): boolean;
//=============================================================================
var 
  bOk: boolean;
  lpRec: pointer;  // BASE OF Current Record
  lpDest: pointer;  
  lpSrc: pointer; // Where to start moving the data to
  uChunkSize: uint;
  uRemaining: uint;
  uBytesRead: uint;
Begin
  bOk:=false;
  uBytesRead:=0;
  with p_rJFSFile do Begin
    //riteln('About to READ a row');
    if bFileOpen and 
       (u1Mode=cnjfsmode_read) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      //riteln('YES! Gonna read a row!');
      //cnJFSSTREAMREC_HDROFFSET
      lpRec:=lpJFSCurrentRecord(p_rJFSFile);
      //riteln('rJFSRaw^.u4recType:               ',rJFSRaw^.u4recType);
      if rtJFSStream(lpRec^).u4recType=cnJFS_RecType_Stream then
      Begin
        //rJFSRaw^.u4BytesRemaining:=uRawOffset+p_u4HowMany;
        uRemaining:=p_uHowMany;
        lpDest:=p_ptrDest;
        
        {$IFDEF DEBUG_JFSReadStream}
        Writeln;
        Writeln('--RS--DEBUG uxxg_jfilesys.bJFSReadStream');
        Writeln('--RS----------------------------------');
        Writeln('--RS--lpRec Coming In.....................: ',UINT(lpRec));
        Writeln('--RS--lpRecord (lp) coming in.............: ',uint(lpRecord));
        Writeln('--RS--rtJFSStream(lpRec^).u4recType.......: ',rtJFSStream(lpRec^).u4recType);
        Writeln('--RS--rtJFSStream(lpRec^).u8BytesRemaining: ',rtJFSStream(lpRec^).u8BytesRemaining);
        Writeln('--RS--uRawOffset..........................: ',uRawOffset);
        Writeln('--RS--uRow................................: ',uRow);
        Writeln('--RS--p_uHowMany..........................: ',p_uHowMany);
        //Writeln('uRemaining Starts as p_u4HowMany.');
        Writeln('--RS--p_ptrDest (lp)......................: ',UINT(p_ptrDest));
        Writeln('--RS--lpDest..............................: ',UINT(lpDest));
        Writeln('--RS----------------------------------');
        Writeln('--RS--Beginning Repeat Loop Next to start reading and chunking.');
        Writeln('--RS----------------------------------');
        Writeln;
        {$ENDIF}
        
        
        repeat
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS----------------------------------');
          Writeln('--RS--TOP OF LOOP - READ RAW');
          Writeln('--RS----------------------------------');
          Writeln('--RS--lpRec coming in.....................: ',UINT(lpRec));
          Writeln('--RS--rtJFSStream(lpRec^).u4recType.......: ',rtJFSStream(lpRec^).u4recType);
          Writeln('--RS--rtJFSStream(lpRec^).u8BytesRemaining: ',rtJFSStream(lpRec^).u8BytesRemaining);
          Writeln('--RS--uRawOffset..........................: ',uRawOffset);
          Writeln('--RS--p_uHowMany..........................: ',p_uHowMany);
          Writeln('--RS----------------------------------');
  
  
          //--- TOP of loop
          // This if does not allow for inexact anything.
          // CODE better make sure the value is one past record to flag
          // time to make a new record BEFORE another move instruction 
          // occurs. - I put >= - but it should BE EQUAL or less.
          // EQUAL means sitting past where we can write to buffer.
          Writeln('--RS--*************The Big Fast Read Descision is below:');
          Writeln('--RS--if uRawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then');
          Writeln('--RS--Offset shown above, and the other part''s value is:',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
          {$ENDIF}
          
          if uRawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then
          Begin
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS---*-*-*-Decision for FastREAD Made');
            Writeln('--RS--uRawOffsett:',uRawOffset,'>= (u4RecSize-cnJFSSTREAMREC_HDROFFSET-1):',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
            {$ENDIF}
            
            // Begin New Record
            //rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;
            
            //rJFSRaw^.u4BytesRemaining:=uRawOffset+uRemaining;
  
            uRawOffset:=0;
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--uRawOffset becomes ZERO');
            {$ENDIF}
            
            bOk:=bJFSFastRead(p_rJFSFile);
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--bJFSFastRead Returned:bOkss);
            {$ENDIF}
            
            lpRec:=lpJFSCurrentRecord(p_rJFSFile);
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--lpRec (lpJFSCurrentRecord(this file):',LongWord(lpRec));
            Writeln('--RS--rJFSRaw^.u4BytesRemaining:=uRawOffset+uRemaining;');
            Writeln('--RS--uRawOffset:',uRawOffset,' uRemaining:',uRemaining);
            Writeln('--RS--rJFSRaw^.u4BytesRemaining:',rJFSRaw^.u4BytesRemaining);
            {$ENDIF}
            
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS---=-=-=-=-=-=-=-=-=Read Just completed-=-=-=-=-=-');
            {$ENDIF}
          End;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS---=-=-=--2ndPartOfSameLoop-Past fastread decision blk');
          Writeln('--RS--lpRec (lpJFSCurrentRecord(this file):',LongWord(lpRec));
          {$ENDIF}
          lpSrc:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+uRawOffset+1);

          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--lpSrc:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+uRawOffset+1);');
          Writeln('--RS--lpSrc:',UINT(lpSrc));
          {$ENDIF}
          
          if rtJFSStream(lpRecord^).u8BytesRemaining<uRemaining then
          Begin
            // Found Endof stream!
            uRemaining:=rtJFSStream(lpRecord^).u8BytesRemaining;
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--End of Stream Found %%%%%%%%%');
            {$ENDIF}
          End;
  
          
          
          uChunkSize:=uRemaining;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--uChunkSize:=uRemaining;');
          Writeln('--RS--uChunkSize:',uChunkSize);
          Writeln('--RS--uRemaining:',uRemaining);
          Writeln('--RS-----Big chunk Descision---');
          {$ENDIF}
 
          // ORIGINAL:if ((cnJFSSTREAMREC_HDROFFSET+uRawOffset)+uChunkSize)
          if ((cnJFSSTREAMREC_HDROFFSET+uRawOffset+1)+uChunkSize)
             >
             u4RecSize then
          Begin
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS-----HAS decided to shrink chunk size for this iteration');
            {$ENDIF}
            uChunkSize:=(u4RecSize-(cnJFSSTREAMREC_HDROFFSET+uRawOffset)-1);
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS-----New uChunkSize:',uChunkSize);
            {$ENDIF}
          End;   
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          {$ENDIF}
          
          //move(lpDest^, lpSrc^, uChunkSize);
          move(lpSrc^,lpDest^, uChunkSize);
          uBytesRead+=uChunkSize;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--move(lpDest^, lpSrc^, uChunkSize);');
          Writeln('--RS--lpDest:',UINT(lpDest));
          Writeln('--RS--lpSrc:',UINT(lpSrc));
          Writeln('--RS--uChunkSize:',uChunkSize);
          Writeln('--RS------------------------------------ Move Done');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          {$ENDIF}
          
          lpDest:=pointer(UINT(lpDest)+uChunkSize);

          {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--lpDest:=lpDest+uChunkSize  result:',UINT(lpDest));
          {$ENDIF}
          uRawOffset+=uChunkSize;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--uRawOffset+=uChunkSize result uRawOffset:',uRawOffset);
          {$ENDIF}
          
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS-------BEFORE THE LAST DECISION before loop iterates---');
          Writeln('--RS--uChunkSize:',uChunkSize);
          Writeln('--RS--uRemaining:',uRemaining);
          {$ENDIF}
  
          if uRemaining>=uChunkSize then
          Begin
           uRemaining-=uChunkSize;
          End;
  
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS-------LLLLLLLLLLLLLLOOOOOOOOOOOOOPPPPPPPPPPPPPP AGAIN ?---');
          Writeln('--RS--uChunkSize:',uChunkSize);
          Writeln('--RS--uRemaining:',uRemaining);
          Writeln('--RS----------------------------');
          Writeln('--RS--Loop goes on again until uRemaining=0;');
          {$ENDIF}
        until (uRemaining=0);//qqq
        // Note - should go until EQUAL (for exactness)
        bOk:=true;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS--NOTE: uRawOffset is at:',uRawOffset);
        {$ENDIF}
        rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS-- rtJFSStream(lpRecord^).u4RecType:=cnJFS_RecType_Stream;');
        {$ENDIF}
        //rJFSRaw^.u4BytesRemaining:=uRawOffset+uRemaining;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS-- rtJFSStream(lpRecord^).u8BytesRemaining:',rtJFSStream(lpRecord^).u8BytesRemaining);
        {$ENDIF}
      End;
    End;
    p_uHowMany:=uBytesRead;
    Result:=bOk;
  End;//with
  {$IFDEF DEBUG_JFSREADStream}
  Writeln('--RS--');
  Writeln('--RS--');
  Writeln('--RS--');
  Writeln('--RS--');
  Writeln('--RS--END OF CALL--------------------------------------------------------');
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  {$ENDIF}
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
