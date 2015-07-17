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
uses 
//=============================================================================
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
//{}
const cnJFS_Base=128;
const cnJFS_RecSizeMinimum=cnJFS_Base;
//{}
////const cnJFS_RecSizeDefault=cnJFS_Base*1;//128 bytes
////const cnJFS_RecSizeDefault=cnJFS_Base*2;//256 bytes
////const cnJFS_RecSizeDefault=cnJFS_Base*4;//512 bytes
//{}
const cnJFS_RecSizeDefault=cnJFS_Base*8;//1k
//{}
////const cnJFS_RecSizeDefault=cnJFS_Base*16;//2k
////const cnJFS_RecSizeDefault=cnJFS_Base*32;//4k
////const cnJFS_RecSizeDefault=cnJFS_Base*64;//8k
////const cnJFS_RecSizeDefault=cnJFS_Base*128;//16k
////const cnJFS_RecSizeDefault=cnJFS_Base*256;//32k
////const cnJFS_RecSizeDefault=cnJFS_Base*512;//64k
//{}
const cnJFS_BufSizeDefault=cnJFS_RecSizeDefault*16384;
const cnJFS_RecType_Header=0;
const cnJFS_RecType_Stream=1;
//
//// Makes DEFAULT "Always Safe" Descriptor
//// Every "Record" has one
type rtJFS = packed record
  u4RecType: LongWord;
End;
//
type rtJFSHdr = packed record
  u4RecType: LongWord;//<cnJFS_RecType_Header
  u4RecSize: LongWord;
  sJegas: String[120];
End;
//
const cnJFSSTREAMREC_HDROFFSET=7;
//// IMPORTANT TO MAKE CORRECT FOR NOW
//// UNTIL Logic put in place to calc where the achStream thing is.
//// basically size of header fields BEFORE achStream less one.
type rtJFSStream = packed record
  u4RecType: LongWord;//<cnJFS_RecType_Stream
  u4BytesRemaining: LongWord;
  achStream: array [1..1] of char;{ place to point to for refernce
   use the Bytes Remaining field to indicate a stream still
   going by being larger than can fit in the record.
   rec 1 of 2 or 120 byte records my say 200 bytes remaining
   in record 1, and (128byte record-8byte header-120)=remaining
   in record 2.}
End;
//
//
const cnJFSMode_Read=0;      //< FPC FileMode matches
const cnJFSMode_Write=1;     //< FPC FileMode matches
const cnJFSMode_ReadWrite=2; //< FPC FileMode matches
//
//{}
type rtJFSFile = packed record
  F: file;
  u1Mode: LongWord; //<0=read  1=write  2=read/write
  saFileName: AnsiString;
  bFileOpen: boolean; //< true if file open.

  // Records
  {}
  u4RecSize: LongWord; //< Size of records - Must be =< buffer size
  u4BufRow: LongWord; //< Offset - Starts at Zero
  u4RowsInBuffer: LongWord; //< How many actual records in the buffer
  u4Row: LongWord; //< Current ROW, First record = 1 (yes the header)

  // Buffer Blocks
  {}
  u4BufSize: LongWord; //< Size of Buffer Block
  lpBuffer: pointer; //< pointer to Buffer
  bBufModified: boolean; {< True if Records in Buffer
   Modified and the buffer needs to be written.}

  u4RawOffset: LongWord; {< For use with WriteStream
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

  rJFS: ^rtJFS;
  rJFSHdr: ^rtJFSHdr;
  rJFSRaw: ^rtJFSStream;
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
//{}
//// Initialize this unit
procedure InitJFS(var p_rJFSFile: rtJFSFile);
////=============================================================================
//{}
//// Opens the file - and the work you need to do to make this work right
//// is this:
////  
////  1st: Set up a rtJFSFile record as a variable.
////       e.g.: var rJFSFile: rtJFSFile;
////
////  2nd: Make sure you initialize your new record structure to defaults. 
////       e.g. InitJFS(rJFSFile); 
////
////  3rd: Assign a VALID filename (For reads, it should exist already obviously)
////       e.g. rJFSFile.saFilename:='testfile.bin';
////       
////  4th: Give it a mode
////       e.g. rJFSFile.u1Mode:=cnJFSMode_Read;
////
//// IMPORTANT: you can override the default (compiled contants values)
//// for the record size and buffersizes by changing the values of these
//// fields before opening the file. The call to bJFSOpen will allocate the
//// memory for you. bJFSClose will release the memory for you.
function bJFSOpen(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
//{}
//// This function obviously closes the file, but also releases the allocated
//// memory for the file buffer.
function bJFSClose(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
//{}
//// This is an index into the file. Low Level FPC uses 0 to indicate first
//// record. We use 1 to indicate the first record to stay alligned with
//// the u4Row variable in the rtJFSFile record structure. This also seems
//// intuitive to me when thinking in terms of databases. The first record
//// is always referred to as record 1 in my experience. The fact that we
//// use a header record doesn't change this because this lib is at that level.
//// 
//// This function is only called internally (and should only be called by
//// you, when you want to force going to a specific record in the file,
//// in preperation for reloading the buffer. Using this function to get 
//// around is only efficient when you know where you MUST go and WHY!
////
//// MoveFirst and MoveNext are a bit more refined and are a little higher level
//// and have some logic built in to them to make them work as you would expect.
//// At least I'm planning on making them do so next - 2006-07-21 Jason P Sage
function bJFSSeek(var p_rJFSFile: rtJFSFile;p_u4SeekRecord:LongWord): boolean;
////=============================================================================
//{}
function bJFSEOF(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
//{}
//// This Appends a Record in Buffer, then when full
//// writes entire buffer, and reset the counter for the next 
//// buffer full. Very Fast - not a multi-user thing... 
//// great for cranking out data though.
function bJFSFastAppend(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
//{}
//// This is similiar to fast append - and is great for
//// reading a lot of records quickly. Every time it is
//// called, if the buffer is empty, it loads it, and 
//// sets the record position to the first record in the 
//// buffer, subsequent calls move record pointers to the next 
//// record. Once it cant go any further, the process starts
//// over again. 
function bJFSFastRead(var p_rJFSFile: rtJFSFile): boolean;
////=============================================================================
//{}
//// From WHERE ever the file position is, write records known
//// to be in buffer starting with first in the buffer
////
//// This means if you have 4 records in the buffer, but only
//// really manipulated any one of them, all the records get written
//// in the buffer. It doesn't matter which record in the buffer you 
//// were on when you called this routine, the buffer gets written.
function bJFSWriteBufferNow(p_rJFSFile: rtJFSFile):boolean;
////=============================================================================
//{}
//// Unlike a normal "Current" record function, this function returns a 
//// calculated pointer that points to the first byte of the current record.
//// You can type cast record structures over this value. 
function lpJFSCurrentRecord(var p_rJFSFile: rtJFSFile): pointer;
////=============================================================================
//{}
//// (bJFSWriteStream function description)
//// This is a wonderful function, however you need to be aware of its inner 
//// workings to really get the most of it. BASICALLY - it allows you to
//// send big or small streams of data to the file. How it works, is meant
//// to make this operation as simple as possible for storing streams of 
//// data. I'm not sure my use of the word stream is technically accurate,
//// but this function allows you to send big or small blocks of information, 
//// BYTES, to the open file, without being REQUIRED to worry about the current 
//// buffer size, or the record size. This function is the only record structure
//// so far (as of 2006-07-22) in this unit that has its own support built in.
//// Seeing how the goal of this unit is to stay lean, there probably won't 
//// be to much more - except maybe some multi user stuff added to what 
//// exists now.
//// 
//// I'm trying to summerize what this function does "mechanically". ahh..
//// First thing to remember is that with a clean slate, (after a call to
//// bJFSWriteBufferNow, opening the file, or setting rtJFSFile.u4RawOffSet=0
//// this function starts writing into the current record, past the record 
//// header bytes + u4RawOffset. This means basically that when u4RawOffSet=0
//// that the next call to here starts copying the data from u4RawOffSet 
//// for as far as it can before reaching the end of the record size, at which
//// point it automatically advances to the next record and continues.
//// (When the buffer gets full, it gets written.)
////
//// Anyway, an important thing to remember, is that when this function 
//// leaves, you might of happened to stop writing right smack in the middle
//// of a record. That is ok. Thats what the u4RawOffSet is for, its a bookmark.
//// This means you can call this function again, with more data, and it 
//// will manage when to move to the next record and when to write the buffer
//// out etc. As far as your written data appears, it will be contiguous.
////
//// IMPORTANT: Each record written out, using this method has a record type
//// of RAW. The RAW Record Type Header has a field named BYTES REMAINING.
//// This is only 100% accurate WHEN this VALUE is less than or EQUAL to
//// (RECORDSIZE-HEADERSIZE). The VALUE has a purpose on other records also.
//// Let's say you saved one stream of data spanning two records. 
//// on the first record, the BYTES REMAINING value is guaranteed to be larger
//// than (RECORDSIZE-HEADERSIZE). That is how the function named bJFSReadStream
//// knows it can keep going during a read (direct opposite of this function).
//// In the 2nd record, the BYTEREMAINING field (in rtJFSFile) is 100%
//// accurate.
////
//// You could say that a contigous stream of bytes can be written using
//// this function as if you were just appending a raw binary file.
////
//// The bJFSReadStream does exactly the opposite.
////
//// Note: One application of this would be to save what are referred to 
//// as MEMO fields or BLOBs in database nomenclature. I personally plan
//// on using this as a way of storing various data fields in a stream
//// in such a manner so that I can read them back and recreate them in 
//// memory.
//// 
//// For instance.. to store two ansistrings, I might write the 4 bytes to
//// indicate a 32bit length, and then stream in the whole ansistring.
//// 
//// when reading the information back, I'll snag the length value (4 bytes)
//// and then use that to read the ansistring back from the disk!
//// phew - enough on this function. 2006-07-21 Jason P Sage
////
//// Wait one more comment - remember internally this routine does direct
//// memory moving - so - you better know what your doing when you
//// pass it a pointer to where your data is and the length you want written.
function bJFSWriteStream(
  var p_rJFSFile: rtJFSFile;
  p_ptrSrc: pointer;
  p_u4HowMany: LongWord
  ): boolean;
//=============================================================================
{}
// So in theory you can start calling this when rJFSFile.u4RawOffset=0
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
  var p_u4HowMany: LongWord
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

procedure InitJFS(var p_rJFSFile: rtJFSFile);
Begin
  with p_rJFSFile do Begin
    u1Mode:=cnJFSMode_Read;
    saFileName:='';
    bFileOpen:=false;
    
    // Records or "raw records"
    u4RecSize:=cnJFS_RecSizeDefault;
    u4BufRow:=0;
    u4RowsInBuffer:=0;
    u4Row:=0;
    
    u4BufSize:=cnJFS_BufSizeDefault;
    lpBuffer:=nil;
    bBufModified:=false;
    u4RawOffset:=0;
    u2IOResult:=0; 

    rJFS:=nil;
    rJFSHdr:=nil;  
    rJFSRaw:=nil;  
  End;
End;


procedure GetTheMem(var p_rJFSFile: rtJFSFile);
Begin
  with p_rJFSFile do Begin
    getmem(lpBuffer, u4BufSize);
    rJFS:=lpBuffer;
    rJFSHdr:=lpBuffer;  
    rJFSHdr^.sJegas:='Jegas Under the Hood v1.0 - This is the First version of the Jegas File System Storage Structure!';
    rJFSRaw:=lpBuffer;  
  End;
End;

procedure SyncTheMem(var p_rJFSFile: rtJFSFile);
var u4BufPos: LongWord;
    p: pointer;
Begin
  with p_rJFSFile do Begin
    u4BufPos:=(u4BufRow*u4RecSize);
    p:=pointer(UINT(lpBuffer)+u4BufPos);
    rJFS:=p;
    rJFSHdr:=p;
    rJFSRaw:=p;
  End;
End;



procedure FreeTheMem(var p_rJFSFile: rtJFSFile);
Begin
  with p_rJFSFile do Begin
    freemem(lpBuffer);
    lpBuffer:=nil;
    rJFS:=nil;
    rJFSHdr:=nil;  
    rJFSRaw:=nil;  
  End;
End;

procedure DebugJFSFile(p_rJFSFile: rtJFSFile);
Begin
  with p_rJFSFile do Begin
    Writeln('-DEBUG-JFSFILE-BEGIN-');
    Writeln('u1Mode:         ',u1Mode);
    Writeln('saFileName:     ',saFilename);
    Writeln('bFileOpen:      ',bFileOpen);
    Writeln('u4RecSize:      ',u4RecSize);
    Writeln('u4BufRow:       ',u4BufRow);
    Writeln('u4Row:          ',u4Row);
    Writeln('u4BufSize:      ',u4BufSize);
    Writeln('u4RowsInBuffer: ',u4RowsInBuffer);
    Writeln('lpBuffer:       ',UINT(lpBuffer));
    Writeln('u2IOResult:     ',u2IOResult);
    Writeln('rJFS:           ',UINT(rJFS));
    Writeln('rJFSHdr:        ',UINT(rJFSHdr));
    Writeln('rJFSRaw:        ',UINT(rJFSRaw));
    Writeln('-DEBUG-JFSFILE-END-');
    Writeln;
  End;
End;


//=============================================================================
function bJFSOpen(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var 
  achT: array [0..127] of char;
  bSuccess: boolean;
  iTRead: integer;
Begin
  bSuccess:=false;
  with p_rJFSFile do Begin
    bSuccess:=false;
    // What Mode ?
    //-----------------------------------------------------------------
    if (u1Mode=cnJFSMode_Read) or (u1Mode=cnJFSMode_ReadWrite) then
    Begin
    //-----------------------------------------------------------------
      bSuccess:=true;
      //riteln('assign-');
      // Assign It
      {$I-}
      assign(f,saFilename);
      u2IOResult:=IOResult;
      {$I+}
      bSuccess:=u2IOResult=0;
      
      // Open it for reading the Record Type
      if bSuccess then
      Begin
        //riteln('reset-');
        {$I-}
        filemode:=cnJFSMode_Read;
        reset(f,cnJFS_Base);
        u2IOResult:=IOResult;
        {$I+}
        bSuccess:=u2IOResult=0;
      End;

      // Read first 128 bytes
      if bSuccess then
      Begin
        //riteln('blockread1-');
        {$I-}
        iTRead:=1;
        blockread(f, acht, 1, iTRead);
        u2IOResult:=IOResult;
        {$I+}

        //ebugJFSFile(p_rJFSFile);

        rJFS:=@acht;// Make our pointers point to array of char
        rJFSHdr:=@acht;//which is our temp lil buffer
        
        // use as staging area for decyphering the header (first 128 bytes)
        bSuccess:=u2IOResult=0;
        if bSuccess then bSuccess:=iTRead=1;
        if bSuccess then bSuccess:=rJFS^.u4RecType=cnJFS_RecType_Header;
        if bSuccess then Begin
          u4RecSize:=rJFSHdr^.u4RecSize;
          if u4RecSize>u4BufSize then
          Begin
            u4BufSize:=u4RecSize;
          End;
          reset(F,u4RecSize);
        End;
      End;

      if bSuccess then 
      Begin
        //riteln('success read finishing up-');
        bFileOpen:=true;
        rJFSHdr:=@acht;// SAME for HEADER RECORD overlay.
        u4RecSize:=rJFSHdr^.u4RecSize;
        GetTheMem(p_rJFSFile);
        {$I-}
        reset(f,u4RecSize);
        Seek(f,0);
        u2IOResult:=IOResult;
        {$I+}
        bSuccess:=u2IOResult=0;
      End;
    //-----------------------------------------------------------------
    End;
    //-----------------------------------------------------------------
    
    
    
    //-----------------------------------------------------------------
    if (u1Mode=cnJFSMode_Write) or (u1Mode=cnJFSMode_ReadWrite) then
    Begin
    //-----------------------------------------------------------------
      bSuccess:=true;
      //riteln('Write and readwrite mode stuff');
      // Assign It
      if (u1Mode=cnJFSMode_Write) then
      Begin
        {$I-}
        assign(f,saFilename);
        u2IOResult:=IOResult;
        {$I+}
        bSuccess:=u2IOResult=0;
      End;
      
      if bSuccess then 
      Begin
        // Create Header Record
        //riteln('In Write mode - gonna make the header record');
        if (u1Mode=cnJFSMode_Write) then
        Begin
          //riteln('About to allocate some memory');
          GetTheMem(p_rJFSFile);
          //riteln('Allocated some memory - now to modify some values');
          rJFSHdr^.u4RecType:=cnJFS_RecType_Header;
          rJFSHdr^.u4RecSize:=u4RecSize;
          //riteln('Ok so far - now to rewrite(f,u4RecSize)');
          {$I-}
          rewrite(f,u4RecSize);
          u2IOResult:=IOResult;
          {$I+}
          //riteln('rewrite(f,u4RecSize) 1118 IOResult:',u2IOResult,' u4RecSize=',u4RecSize);
        End
        else
        Begin
          filemode:=cnJFSMode_ReadWrite;
          {$I-}
          reset(f, u4RecSize);
          u2IOResult:=IOResult;
          {$I+}
          //riteln('RESET 1116 returned IOResult:',u2IOResult,' u4recSize=',u4RecSize);  
        End;
        //riteln('Trying to Seek f,0');
        //i4SeekZero:=0;
        {$I-}
        Seek(f,0);
        u2IOResult:=IOResult;
        {$I+}
        //riteln('Seek returned IOResult:',u2IOResult);
        //riteln('It seeked... hahaha');
        if (u1Mode=cnJFSMode_Write) then
        Begin
          //riteln('We are in write mode - so we need to write the record header');
          iTRead:=1;// Just write the correct one Record;
          {$I-}
          blockwrite(f, lpBuffer^, 1, iTRead);
          {$I+}
          //riteln('It should have written.. just executed a blockwrite');
        End;
        u4RowsInBuffer:=0;
        u4BufRow:=0;
        u4Row:=0;
        bFileOpen:=true;
      End;
      
    //-----------------------------------------------------------------
    End;
    //-----------------------------------------------------------------
    
    
    if not bSuccess then
    Begin
      //riteln('JFSOPEN FAILED');
      //ebugJFSFile(p_rJFSFile);
      //riteln('JFSOPEN FAILED');
      bJFSClose(p_rJFSFile);
    End
    else
    Begin
      //riteln('JFSOPEN SUCCEEDED');
      //ebugJFSFile(p_rJFSFile);
      //riteln('JFSOPEN SUCCEEDED');
    End;
  End;
  result:=bSuccess;
End;
//=============================================================================

//=============================================================================
function bJFSClose(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var bSuccess:boolean;
Begin
  bSuccess:=true;
  with p_rJFSFile do Begin
    if lpBuffer<>nil then
    Begin
      if bFileOpen then
      Begin
        {$I-}close(f);{$I+}
        FreetheMem(p_rJFSFile);
      End;
    End;
    bFileopen:=false;
  End;//with
  result:=bSuccess;
End;
//=============================================================================


//=============================================================================
function bJFSFastRead(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var //u4BufPos: LongWord;
    u4NumToLoad: LongWord;
    u4NumLoaded: LongWord;
    bSuccess: boolean;
Begin
  bSuccess:=false;
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
          //riteln('----LOADING BUFFER----Row:',u4Row);
          u4BufRow:=0;
          {$I-}
          u4NumToLoad:=(u4BufSize div u4RecSize);
          blockread(f, lpBuffer^, u4NumToLoad, u4NumLoaded);
          u2IOResult:=IOResult;
          {$I+}
          u4RowsInBuffer:=u4NumLoaded;
          if (u2IOResult=0) and (u4NumLoaded>0) then
          Begin
            bSuccess:=true;
          End;
        End
        else
        Begin
          // EOF
          bSuccess:=false;
        End;
      End
      else
      Begin
        bSuccess:=true;
      End;

      if bSuccess then 
      Begin
        u4Row+=1;
        SyncTheMem(p_rJFSFile);
      End;
    End;//if file open etc
  End;//with
  result:=bSuccess;
End;
//=============================================================================




//=============================================================================
function bJFSWriteBufferNow(p_rJFSFile: rtJFSFile):boolean;
//=============================================================================
var
  u4NumToWrite: LongWord;
  u4NumWritten: LongWord;
  bSuccess: boolean;
Begin
  bSuccess:=false;
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
      u4NumToWrite:=u4BufRow+1;
      blockwrite(f, lpBuffer^, u4NumToWrite, u4NumWritten);
      u2IOResult:=IOResult;
      {$I+}
      if (u2IOResult=0) and (u4NumToWrite=u4NumWritten) then
      Begin
        u4BufRow:=0;
        bBufModified:=false;
        u4RawOffset:=0;
        bSuccess:=true;
      End;
      //riteln('Wrote something out. Flushed!');
    End;
  End;//with
  result:=bSuccess;
End;
//=============================================================================


//=============================================================================
function bJFSFastAppend(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var u4BufPos: LongWord;
    u4NumToWrite: LongWord;
    u4NumWritten: LongWord;
    bSuccess: boolean;
Begin
  bSuccess:=false;
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
        blockwrite(f, lpBuffer^, u4NumToWrite, u4NumWritten);
        u2IOResult:=IOResult;
        {$I+}
        if (u2IOResult=0) and (u4NumToWrite=u4NumWritten) then
        Begin
          u4BufRow:=0;
          bBufModified:=false;
          bSuccess:=true;
        End;
        //riteln('Wrote something out. Flushed!');
      End
      else
      Begin
        bSuccess:=true;
        bBufModified:=true;
        //riteln('No need to Flush');
      End;

      if bSuccess then 
      Begin
        //riteln('Got some Write success - syncing mem');
        u4Row+=1;
        SyncTheMem(p_rJFSFile);
      End;
    End
    else
    Begin
      //riteln('Um...File not open?');
    End;//if file open etc
  End;//with
  result:=bSuccess;
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
function bJFSSeek(var p_rJFSFile: rtJFSFile;p_u4SeekRecord:LongWord): boolean;
//=============================================================================
var 
  bSuccess: boolean;
  //u4FilePos: LongWord;
Begin
  bSuccess:=false;
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
      //bSuccess:=u2IOResult=0;
      
      
      //if bSuccess then
      //Begin
        {$I-}
        seek(f,p_u4SeekRecord-1);
        u2IOResult:=IOResult;
        {$I+}
        bSuccess:=u2IOResult=0;
      //End;
      
      if bSuccess then
      Begin
        u4RowsInBuffer:=0;
        u4BufRow:=0;
        u4Row:=p_u4SeekRecord;
      End;
    End;
  End;//with
  Result:=bSuccess;
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
  result:=bJFSSeek(p_rJFSFile,LongWord(FileSize(p_rJFSFile.F)));
End;
//=============================================================================

//=============================================================================
function bJFSMovePrevious(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var 
  bSuccess: boolean;
  u4CalcRowsBackward: LongWord;
  u4RowOnEntry: LongWord;
Begin
  bSuccess:=true;
  with p_rJFSFile do Begin
    if bFileOpen then
    Begin
      u4RowOnEntry:=u4Row;
      if u4Row>1 then
      Begin
        if u4BufRow>0 then
        Begin
          u4BufRow-=1;
          SyncTheMem(p_rJFSFile);
        End
        else
        Begin
          // Attempt to go backward intelligently.
          u4CalcRowsBackward:=u4BufSize div u4RecSize;
          if u4CalcRowsBackward>u4Row then
          Begin
            // we can jump back a whole buffer block of records,
            // and then adjust the pointers to point to the last record 
            // in the freshly loaded buffer block.
            bSuccess:=bJFSSeek(p_rJFSFile, u4Row-u4CalcRowsBackward);
            // OK Should be pointing to the last row in the 
            // buffer.
          End
          else
          Begin
            // We need to just go to the beginning of the file,
            // fill the buffer, and then adjust the pointers to 
            // the correct record.
            bSuccess:=bJFSSeek(p_rJFSFile, 1);
          End;
          if bSuccess then
          Begin
            u4Row:=u4RowOnEntry-1;
            u4BufRow:=u4RowsInBuffer-1;
          End;
        End;
      End
      else
      Begin
        bSuccess:=false;
      End;
    End;
  End;//with    
  result:=bSuccess;
End;
//=============================================================================


//=============================================================================
function bJFSEOF(var p_rJFSFile: rtJFSFile): boolean;
//=============================================================================
var bEOF: boolean;
Begin
  bEOF:=true;
  with p_rJFSFile do Begin
    if bFileOpen then
    Begin
      if ((u4BufRow+1)<u4RowsInBuffer) and 
         (not Eof(f)) then bEOF:=false;
    End;
  End;//with
  result:=bEOF;
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
// So intheory you can start calling this when rJFSFile.u4RawOffset=0
// and you just did a FASTAPPEND (cuz then pointers are on the next record
// to be worked on in the buffer.
//
// Currently only written to succeed during a valid FastAppend run.
// finish a run with "writebuffernow".
function bJFSWriteStream(
  var p_rJFSFile: rtJFSFile; 
  p_ptrSrc: pointer;
  p_u4HowMany: LongWord
  ): boolean;
//=============================================================================
var 
  bSuccess: boolean;
//  u4Len: LongWord;
//  u4Remaining: LongWord;
//  u4MoveHowMany: LongWord;
//  u4From: LongWord;
// u4t: LongWord;    
var 
  lpRec: pointer;  // BASE OF Current Record
  lpSrc: pointer;  
  lpDest: pointer; // Where to start moving the data to
  u4ChunkSize: LongWord;
  u4Remaining: LongWord;
Begin
  bSuccess:=false;
  with p_rJFSFile do Begin
    //riteln('About to write a row');
    if bFileOpen and 
       (u1Mode=cnjfsmode_Write) or 
       (u1Mode=cnjfsmode_readwrite) then
    Begin
      //cnJFSSTREAMREC_HDROFFSET
      lpRec:=lpJFSCurrentRecord(p_rJFSFile);
      rJFSRaw^.u4BytesRemaining:=u4RawOffset+p_u4HowMany;
      u4Remaining:=p_u4HowMany;
      lpSrc:=p_ptrSrc;
      
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln;
      Writeln('--WS--DEBUG uxxg_jfilesys.bJFSWriteStream');
      Writeln('--WS----------------------------------');
      Writeln('--WS--lpRec Coming In:                  ',LongWord(lpRec));
      Writeln('--WS--u4RawOffSet:                      ',u4RawOffSet);
      Writeln('--WS--p_u4HowMany:                      ',p_u4HowMany);
      Writeln('--WS--u4Remaining Starts as p_u4HowMany.');
      Writeln('--WS--p_ptrSrc (lp):                    ',LongWord(p_ptrSrc));         
      Writeln('--WS--lpSrc:                            ',LongWord(lpSrc));
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
        Writeln('--WS--u4RawOffSet:                      ',u4RawOffSet);
        //--- TOP of loop
        // This if does not allow for inexact anything.
        // CODE better make sure the value is one past record to flag
        // time to make a new record BEFORE another move instruction 
        // occurs. - I put >= - but it should BE EQUAL or less.
        // EQUAL means sitting past where we can write to buffer.
        Writeln('--WS--*************The Big Fast Append Descision is below:');
        Writeln('--WS--if u4RawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then');
        Writeln('--WS--Offset shown above, and the other part''s value is:',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
        {$ENDIF}
        
        if u4RawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then
        Begin
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS---*-*-*-Decision for FastAppend Made');
          Writeln('--WS---u4RawOffset:',u4RawOffSet,'>= (u4RecSize-cnJFSSTREAMREC_HDROFFSET-1):',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
          {$ENDIF}
          
          // Begin New Record
          rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;');
          {$ENDIF}
          
          rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;');
          Writeln('--WS--u4RawOffSet:',u4RawOffSet,' u4Remaining:',u4Remaining);
          Writeln('--WS--rJFSRaw^.u4BytesRemaining:',rJFSRaw^.u4BytesRemaining);
          {$ENDIF}

          u4RawOffSet:=0;
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--u4RawOffSet becomes ZERO');
          {$ENDIF}
          
          bSuccess:=bJFSFastAppend(p_rJFSFile);  
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--bFastAppend Returned:',bSuccess);
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
        lpDest:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1);
        {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--lpDest:=pointer(LongWord(lpRec)+ cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1);');
          Writeln('--WS--lpDest:',UINT(lpDest));
        {$ENDIF}
        u4chunkSize:=u4Remaining;
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--u4chunkSize:=u4Remaining;');
        Writeln('--WS--u4ChunkSize:',u4ChunkSize);
        Writeln('--WS--u4Remaining:',u4Remaining);
        Writeln('--WS-----Big chunk Descision---');
        {$ENDIF}
        // ORIGINAL:if ((cnJFSSTREAMREC_HDROFFSET+u4RawOffset)+u4ChunkSize)
        if ((cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1)+u4ChunkSize)
           >
           u4RecSize then
        Begin
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-----HAS decided to shrink chunk size for this iteration');
          {$ENDIF}
          u4ChunkSize:=(u4RecSize-(cnJFSSTREAMREC_HDROFFSET+u4RawOffset)-1);
          {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS-----New u4ChunkSize:',u4ChunkSize);
          {$ENDIF}
        End;   
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        {$ENDIF}
        
        move(lpSrc^, lpDest^, u4ChunkSize);
        
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--move(lpSrc^, lpDest^, u4ChunkSize);');
        Writeln('--WS--lpSrc:',UINT(lpSrc));
        Writeln('--WS--lpDest:',UINT(lpDest));
        Writeln('--WS--u4ChunkSize:',u4ChunkSize);
        Writeln('--WS------------------------------------ Move Done');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        Writeln('--WS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        {$ENDIF}
        
        lpSrc:=pointer(UINT(lpSrc)+u4ChunkSize);
        {$IFDEF DEBUG_JFSWriteStream}
          Writeln('--WS--lpSrc:=lpSrc+u4ChunkSize  result:',UINT(lpSrc));
        {$ENDIF}
        
        u4RawOffSet+=u4ChunkSize; 
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS--u4RawOffSet+=u4ChunkSize result u4RawOffSet:',u4RawOffSet);
        {$ENDIF}
        
        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS-------BEFORE THE LAST DECISION before loop iterates---');
        Writeln('--WS--u4ChunkSize:',u4ChunkSize);
        Writeln('--WS--u4Remaining:',u4Remaining);
        {$ENDIF}

        if u4Remaining>=u4chunkSize then 
        Begin
          u4Remaining-=u4chunksize;
        End;

        {$IFDEF DEBUG_JFSWriteStream}
        Writeln('--WS-------LLLLLLLLLLLLLLOOOOOOOOOOOOOPPPPPPPPPPPPPP AGAIN ?---');
        Writeln('--WS--u4ChunkSize:',u4ChunkSize);
        Writeln('--WS--u4Remaining:',u4Remaining);
        Writeln('--WS----------------------------');
        Writeln('--WS--Loop goes on again until u4Remaining=0;');
        {$ENDIF}
      until u4Remaining=0;
      // Note - should go until EQUAL (for exactness)
      bSuccess:=true;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS--NOTE: u4RawOffSet is at:',u4RawOffSet);
      {$ENDIF}
      rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS--rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;');
      {$ENDIF}
      rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;
      {$IFDEF DEBUG_JFSWriteStream}
      Writeln('--WS--rJFSRaw^.u4BytesRemaining:',rJFSRaw^.u4BytesRemaining);
      {$ENDIF}
    End;
    Result:=bSuccess;
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
// So intheory you can start calling this when rJFSFile.u4RawOffset=0
//
function bJFSReadStream(
  var p_rJFSFile: rtJFSFile; 
  p_ptrDest: pointer;
  var p_u4HowMany: LongWord
  ): boolean;
//=============================================================================
var 
  bSuccess: boolean;
  lpRec: pointer;  // BASE OF Current Record
  lpDest: pointer;  
  lpSrc: pointer; // Where to start moving the data to
  u4ChunkSize: LongWord;
  u4Remaining: LongWord;
  u4BytesRead: LongWord;
Begin
  bSuccess:=false;
  u4BytesRead:=0;
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
        //rJFSRaw^.u4BytesRemaining:=u4RawOffset+p_u4HowMany;
        u4Remaining:=p_u4HowMany;
        lpDest:=p_ptrDest;
        
        {$IFDEF DEBUG_JFSReadStream}
        Writeln;
        Writeln('--RS--DEBUG uxxg_jfilesys.bJFSReadStream');
        Writeln('--RS----------------------------------');
        Writeln('--RS--lpRec Coming In:                  ',LongWord(lpRec));
        Writeln('--RS--rJFSRaw (lp) coming in:           ',LongWord(rJFSRaw));
        Writeln('--RS--rJFSRaw^.u4recType:               ',rJFSRaw^.u4recType);
        Writeln('--RS--rJFSRaw^.u4BytesRemaining:        ',rJFSRaw^.u4BytesRemaining);
        Writeln('--RS--u4RawOffSet:                      ',u4RawOffSet);
        Writeln('--RS--u4Row:                            ',u4Row);
        Writeln('--RS--p_u4HowMany:                      ',p_u4HowMany);
        //Writeln('u4Remaining Starts as p_u4HowMany.');
        Writeln('--RS--p_ptrDest (lp):                    ',LongWord(p_ptrDest));         
        Writeln('--RS--lpDest:                            ',LongWord(lpDest));
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
          Writeln('--RS--rJFSRaw (lp) coming in:           ',LongWord(rJFSRaw));
          Writeln('--RS--rJFSRaw^.u4recType:               ',rJFSRaw^.u4recType);
          Writeln('--RS--rJFSRaw^.u4BytesRemaining:        ',rJFSRaw^.u4BytesRemaining);
          Writeln('--RS--u4RawOffSet:                      ',u4RawOffSet);
          Writeln('--RS--p_u4HowMany:                      ',p_u4HowMany);
          Writeln('--RS----------------------------------');
  
  
          //--- TOP of loop
          // This if does not allow for inexact anything.
          // CODE better make sure the value is one past record to flag
          // time to make a new record BEFORE another move instruction 
          // occurs. - I put >= - but it should BE EQUAL or less.
          // EQUAL means sitting past where we can write to buffer.
          Writeln('--RS--*************The Big Fast Read Descision is below:');
          Writeln('--RS--if u4RawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then');
          Writeln('--RS--Offset shown above, and the other part''s value is:',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
          {$ENDIF}
          
          if u4RawOffset>=(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1) then 
          Begin
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS---*-*-*-Decision for FastREAD Made');
            Writeln('--RS---u4RawOffset:',u4RawOffSet,'>= (u4RecSize-cnJFSSTREAMREC_HDROFFSET-1):',(u4RecSize-cnJFSSTREAMREC_HDROFFSET-1));
            {$ENDIF}
            
            // Begin New Record
            //rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;
            
            //rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;
  
            u4RawOffSet:=0;
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--u4RawOffSet becomes ZERO');
            {$ENDIF}
            
            bSuccess:=bJFSFastRead(p_rJFSFile);  
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--bJFSFastRead Returned:',bSuccess);
            {$ENDIF}
            
            lpRec:=lpJFSCurrentRecord(p_rJFSFile);
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--lpRec (lpJFSCurrentRecord(this file):',LongWord(lpRec));
            Writeln('--RS--rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;');
            Writeln('--RS--u4RawOffSet:',u4RawOffSet,' u4Remaining:',u4Remaining);
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
          lpSrc:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1);

          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--lpSrc:=pointer(UINT(lpRec)+ cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1);');
          Writeln('--RS--lpSrc:',UINT(lpSrc));
          {$ENDIF}
          
          if rJFSRaw^.u4BytesRemaining<u4Remaining then
          Begin
            // Found Endof stream!
            u4Remaining:=rJFSRaw^.u4BytesRemaining;
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--End of Stream Found %%%%%%%%%');
            {$ENDIF}
          End;
  
          
          
          u4chunkSize:=u4Remaining;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--u4chunkSize:=u4Remaining;');
          Writeln('--RS--u4ChunkSize:',u4ChunkSize);
          Writeln('--RS--u4Remaining:',u4Remaining);
          Writeln('--RS-----Big chunk Descision---');
          {$ENDIF}
 
          // ORIGINAL:if ((cnJFSSTREAMREC_HDROFFSET+u4RawOffset)+u4ChunkSize)
          if ((cnJFSSTREAMREC_HDROFFSET+u4RawOffset+1)+u4ChunkSize)
             >
             u4RecSize then
          Begin
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS-----HAS decided to shrink chunk size for this iteration');
            {$ENDIF}
            u4ChunkSize:=(u4RecSize-(cnJFSSTREAMREC_HDROFFSET+u4RawOffset)-1);
            {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS-----New u4ChunkSize:',u4ChunkSize);
            {$ENDIF}
          End;   
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          {$ENDIF}
          
          //move(lpDest^, lpSrc^, u4ChunkSize);
          move(lpSrc^,lpDest^, u4ChunkSize);
          u4BytesRead+=u4ChunkSize;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--move(lpDest^, lpSrc^, u4ChunkSize);');
          Writeln('--RS--lpDest:',UINT(lpDest));
          Writeln('--RS--lpSrc:',UINT(lpSrc));
          Writeln('--RS--u4ChunkSize:',u4ChunkSize);
          Writeln('--RS------------------------------------ Move Done');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          Writeln('--RS--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          {$ENDIF}
          
          lpDest:=pointer(UINT(lpDest)+u4ChunkSize);

          {$IFDEF DEBUG_JFSReadStream}
            Writeln('--RS--lpDest:=lpDest+u4ChunkSize  result:',UINT(lpDest));
          {$ENDIF}
          u4RawOffSet+=u4ChunkSize;
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS--u4RawOffSet+=u4ChunkSize result u4RawOffSet:',u4RawOffSet);
          {$ENDIF}
          
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS-------BEFORE THE LAST DECISION before loop iterates---');
          Writeln('--RS--u4ChunkSize:',u4ChunkSize);
          Writeln('--RS--u4Remaining:',u4Remaining);
          {$ENDIF}
  
          if u4Remaining>=u4chunkSize then 
          Begin
            u4Remaining-=u4chunksize;
          End;
  
          {$IFDEF DEBUG_JFSReadStream}
          Writeln('--RS-------LLLLLLLLLLLLLLOOOOOOOOOOOOOPPPPPPPPPPPPPP AGAIN ?---');
          Writeln('--RS--u4ChunkSize:',u4ChunkSize);
          Writeln('--RS--u4Remaining:',u4Remaining);
          Writeln('--RS----------------------------');
          Writeln('--RS--Loop goes on again until u4Remaining=0;');
          {$ENDIF}
        until (u4Remaining=0);//qqq
        // Note - should go until EQUAL (for exactness)
        bSuccess:=true;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS--NOTE: u4RawOffSet is at:',u4RawOffSet);
        {$ENDIF}
        rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS--rJFSRaw^.u4RecType:=cnJFS_RecType_Stream;');
        {$ENDIF}
        //rJFSRaw^.u4BytesRemaining:=u4RawOffset+u4Remaining;
        {$IFDEF DEBUG_JFSReadStream}
        Writeln('--RS--rJFSRaw^.u4BytesRemaining:',rJFSRaw^.u4BytesRemaining);
        {$ENDIF}
      End;
    End;
    p_u4HowMany:=u4BytesRead;
    Result:=bSuccess;
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
