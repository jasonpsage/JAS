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
Unit ug_wave;
//=============================================================================
// 44.1kHz   or 44100  Samples per second
//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_wave.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================



//****************************************************************************
//=============================================================================
//****************************************************************************
//
                               Interface
//             
//****************************************************************************
//=============================================================================
//****************************************************************************

//=============================================================================
Uses
//=============================================================================
  sysutils
  ,ug_tsfileio
  ,ug_misc
  ,ug_jegas
  ,ug_common
  //,ug_rgba
  ,ug_jfc_xdl
  ,ug_pixelgrid;
//=============================================================================


//=============================================================================
TYPE rtWaveRiff = record
//=============================================================================
  acChID: array[0..3] of char;
  u4ChunkSize: Cardinal; // 4+n
  acWaveID: array[0..3] of char;
end;
//=============================================================================


//=============================================================================
type rtFormat = record
  acChID: array[0..3] of char;
  u4ChunkSize: Cardinal; // 16, 18 or 40
  u2FormatTag: word;         // format type
  u2Channels:word;           // number of channels (i.e. mono, stereo...)/
  u4SamplesPerSec: cardinal; // sample rate
  u4AvgBytesPerSec: cardinal;// for buffer estimation/
  u2BlockAlign: word;        // block size of data
  u2BitsPerSample: word;     // Number of bits per sample of mono data/
  //--------16 Chunk Size Stops Above this line
  u2Size: word;             // The count in bytes of the size of
                            //extra information (after cbSize)
  //--------18 Chunk Size Stops Above this line
  u2ValidBitsPerSample: word;
  u4ChannelMask: cardinal;
  acSubformat: array [0..15] of char; // GUID plus data format code.
end;
//=============================================================================

//=============================================================================
type rtFact = record
//=============================================================================
  acChID: array[0..3] of char;
  u4ChunkSize: Cardinal;
  u4SampleLength: cardinal;
end;
//=============================================================================

//=============================================================================
type rtData = record
//=============================================================================
  acChID: array[0..3] of char;
  u4ChunkSize: Cardinal;
  lpData: pointer;
end;
//=============================================================================



// 8-bit samples are stored as unsigned bytes, ranging from 0 to 255.
// 16-bit samples are stored as 2's-complement signed integers, ranging from -32768 to 32767.
// For example a 16-bit sample can range from -32,768 to +32,767 with a mid-point (silence) at 0.

// Format        Maximum Value      Minimum Value Midpoint Value
// 8-bit PCM        255 (0xFF)                  0     128 (0x80)
// 16-bit PCM   32767 (0x7FFF)   -32768 (-0x8000)              0
//=============================================================================
Type TWAVE = Class
//=============================================================================
  Public
  //---------------------------------------------------------------------------
  {}
    // Ar is an array of pointers to various record structures stored in
    // ram, portions of the Wave file - in contiguous order.
    ar: Array of pointer;
    u4Samples: cardinal; // assumes 16bit mono wave with one data chunk.
                         // So, Length is in Samples at Rate 44100 per second
  //---------------------------------------------------------------------------

  Public
  //---------------------------------------------------------------------------
  {}
  // Constructor for the TWAVE Class
  Constructor create;
  //---------------------------------------------------------------------------
  {}
  // Destructor for the TWAVE Class
  Destructor destroy; override;
  //---------------------------------------------------------------------------
  {}
  // Used to compare the Chunk ID's for each Rach Structure stored in the AR
  // array. Basically the chunk ID's are four character arrays and this
  // function allows one to test the four character array against a string or
  // ansistring that is four characters long.
  function bCmpID(p_aCH: array of char; p_saCompare: ansistring): boolean;
  //---------------------------------------------------------------------------
  {}
  // Returns a four character chunk ID as a string to ease use.
  function saID(p_aCH: array of char): ansistring;
  //---------------------------------------------------------------------------
  {}
  // Loads a wave file into the TWAVE class.
  // NOTE: Only MONO 16bit Waves are currently supported.
  function Load(p_saFilename: ansistring; var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
  //---------------------------------------------------------------------------
  {}
  // Saves a a Wave File from the TWAVE class.
  // NOTE: Only MONO 16bit Waves are currently supported.
  function Save(p_saFilename: ansistring; var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
  //---------------------------------------------------------------------------
  {}
  // This routine returns a string representation of all the record structures
  // store in the ar Array as text for easy analysis.
  function saDiagnosticInfo: ansistring;
  //---------------------------------------------------------------------------
  {}
  // This routine writes to the screen the entire list of sound samples in the
  // the loaded Wave File. It Also shows at the end the HIGHEST point and the
  // lowest point (volume/intensity wise) in the file.
  Procedure DumpSamples;
  //---------------------------------------------------------------------------
  {}
  // this function normalizes the WAVE file in the TWAVE class.
  function bNormalize(var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
  //---------------------------------------------------------------------------
  {}
  // Create a bitmap representation of the Audio File
  function bMakeBitMap(
    p_uWidth: cardinal;
    p_uHeight: cardinal;
    p_u1PenR: byte;
    p_u1PenG: byte;
    p_u1PenB: byte;
    p_u1BgR: byte;
    p_u1BgG: byte;
    p_u1BgB: byte;
    p_saFilename: ansistring;
    p_u8Result: UInt64;
    p_saResult: ansistring
  ): boolean;
  //---------------------------------------------------------------------------
  {}
  // This function compares THIS TWAVE instance with that of another TWAVE
  // class instance's files and attempts to find a COMMON SYNC point in them
  // so if they are of the same SONG but have different starting points for
  // example, the exact starting points can be located.
  //
  // A Positive Offset means THIS class (FIRST WAVE) needs to be Offset to
  // be in sync with the SECOND using the offset value.
  //
  // A Negative Offset means the PASSED (SECOND WAVE) needs to be Offset to
  // be in sync with the SECOND. NOTE: The negative number needs to be
  // multipled by -1 BEFORE applying the offset. The Offset is REALLY a
  // positive Value.
  //
  // Negative OFFSET is just to discern WHICH wave file needs to apply
  // the offset value in its positive form e.g.: abs( p_iOffset );
  function bSynchronize(
    p_lpSameTypeOfClass: pointer;
    var p_iOffset: longint;
    var p_fLowestScore: double;
    var p_u8Result: UInt64;
    var p_saResult: ansistring;
    p_saDisplay: ansistring
  ):boolean;

  function pvt_bSynchronize(
    p_lpSameTypeOfClass1: pointer;
    p_lpSameTypeOfClass2: pointer;
    var p_iOffset: longint;
    var p_fLowestScore: double;
    var p_u8Result: UInt64;
    var p_saResult: ansistring;
    p_saDisplay: ansistring
  ):boolean;
  //---------------------------------------------------------------------------
  {}
  // this function assumes 16bit mono wave with one data chunk.
  // It can truncate or lengthen the wave file.
  function bSetLength(p_InWords: cardinal): boolean;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  {}
  // this function assumes 16bit mono wave with one data chunk.
  // It Deletes the number of samples from the data at the
  // specified starting location.
  //function bDelete(p_Start, p_HowMany: cardinal): boolean;
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  {}
  // Inserts Specified number of Samples, with a Value of ZERO, at position
  // ZERO in the Data stream.
  function bInsertQuietAtBeginning(p_InWords: cardinal): boolean;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  {}
  // Resets the Data in this class, effectively restoring it to it's state
  // when instantiated
  Procedure WaveReset;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  {}
  // Resets the Data in this class, effectively restoring it to it's state
  // when instantiated
  Procedure CreateNewWave(p_u4Samples: cardinal);
  //---------------------------------------------------------------------------

End;
//=============================================================================
















//=============================================================================
Type TWAVEMERGE = class(JFC_XDL)
//=============================================================================
  public
    MergedWave: TWAVE;

  //---------------------------------------------------------------------------
  {}
  public
  Function pvt_CreateItem: JFC_XDLITEM; override; //< Override if you make descendant of JFC_DLITEM with more fields or something.
  //Procedure pvt_createtask; override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  Procedure pvt_DestroyItem(p_lp:pointer); override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  //Procedure pvt_destroytask(p_lp:pointer); override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  {}
  //---------------------------------------------------------------------------

  Public
  {}
  Constructor create; //< OVERRIDE BUT INHERIT
  Destructor Destroy; override;  //< OVERRIDE BUT INHERIT
  {}



  public
  //---------------------------------------------------------------------------
  {}
  // NOTE: bLoadWaves is expected to have XDL Items with the saName property
  // populated with a fully qualified path/filename. So Populate the XDL
  // Using AppendItem_saName('FILENAME') repeatedly for each file to merge.
  // The Result Parameters return the error that caused the process to abort
  // and UNLOAD the Waves.
  function bLoadWaves(var p_u8result: UInt64; var p_saResult: Ansistring): boolean;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  {}
  // This function merges the wave files loaded with bLoadWaves. Upon
  // successful completion, call bSaveMerged to save the new wave file to
  // disk.
  function bMerge: boolean;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  {}
  // Save the Merged wave file to disk
  function bSaveMergedWave(p_saFilename: ansistring; var p_u8result: UInt64; var p_saResult: Ansistring): boolean;
  //---------------------------------------------------------------------------
  
end;
//=============================================================================








//****************************************************************************
//=============================================================================
//****************************************************************************
//
                                Implementation
//             
//****************************************************************************
//=============================================================================
//****************************************************************************
//=*=



//=============================================================================
//=============================================================================
//=============================================================================
//=====================    TWAVE     BEGIN ====================================
//=============================================================================
//=============================================================================
//=============================================================================


//=============================================================================
Constructor TWAVE.create;
//=============================================================================
begin
  setlength(ar,0);
  u4Samples:=0;
end;
//=============================================================================

//=============================================================================
Destructor TWAVE.destroy;
//=============================================================================
begin
  WaveReset;
end;
//=============================================================================

//=============================================================================
Procedure TWAVE.WaveReset;
//=============================================================================
var
  //i: longint;
  u: cardinal;
  //rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  //rFact: ^rtFact;
  rData: ^rtData;
begin
  //riteln('ug_wave - Starting Reset');
  if length(ar)>0 then
  begin
    u:=0;
    //riteln('ug_wave - Begin of Loop');
    repeat
      //riteln('ug_wave - Top Of Loop');
      rWaveRiff:=ar[u];
      //=======================================================WAVERIFF
      //if bCmpID(rWaveRiff^.acChId,'RIFF') then
      //begin
      //end else
      //=======================================================WAVERIFF

      //=======================================================FACT
      //if bCmpID(rWaveRiff^.acChId,'fact') then
      //begin
      //end else
      //=======================================================FACT

      //=======================================================FORMAT
      //if bCmpID(rWaveRiff^.acChId,'fmt ') then
      //begin
      //end else
      //=======================================================FORMAT

      //=======================================================DATA
      //riteln('ug_wave - Remove Data Start u:'+inttostR(u));
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        rData:=ar[u];
        freemem(rData^.lpData);
      end;
      //riteln('ug_wave - Remove Data End u:'+inttostR(u));
      //=======================================================DATA

      //riteln('ug_wave - Freemem Start u:'+inttostR(u));
      freemem(ar[u]);
      //riteln('ug_wave - Freemem End u:'+inttostR(u));
      u+=1;
      //riteln('ug_wave - Bottom of Loop');
    until (u=length(ar));
    //riteln('ug_wave - End Loop');
  end;
  //riteln('ug_wave - Set Array to Zero BEGIN');
  setlength(ar,0);
  //riteln('ug_wave - Set Array to Zero END');
  u4Samples:=0;
  ar:=nil;
  //riteln('Ended Destroy');
end;
//=============================================================================

//=============================================================================
function TWAVE.bCmpID(p_aCH: array of char; p_saCompare: ansistring): boolean;
//=============================================================================
var sa: ansistring;
begin
  sa:=p_aCH[0]+p_aCH[1]+p_aCH[2]+p_aCH[3];
  result:=sa=p_saCompare;
end;
//=============================================================================


//=============================================================================
function TWAVE.saID(p_aCH: array of char): ansistring;
//=============================================================================
begin
  result:=p_aCH[0]+p_aCH[1]+p_aCH[2]+p_aCH[3];
end;
//=============================================================================


//=============================================================================
function TWAVE.Load(p_saFilename: ansistring; var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  u2IOResult: word;
  //f: file;
  p: cardinal;
  r4ByteCast: rt4ByteCast;
  r2ByteCast: rt2ByteCast;
  sChID: string[4];
  u4ChSize: cardinal;
  bDone: boolean;
  rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  rFact: ^rtFact;
  rData: ^rtData;
  saIn: ansistring;
  u: cardinal;
  u1Pad: ^byte;
begin
  p_u8Result:=0;
  p_saresult:='Ok';

  bOk:=FileExists(p_saFilename);
  if not bOk then
  begin
    p_u8Result:=201204210512;
    p_saresult:='File not found: '+p_saFilename;
  end;


  if bOk then
  begin
    bOk:=bTSLoadEntireFile(p_saFilename, u2IOResult, saIn);
    if not bOk then
    begin
      p_u8Result:=201204210513;
      p_saResult:='Load IO Error: '+saIOREsult(u2IOResult);
    end;
  end;

  if bOk then
  begin
    bOk:=length(saIn)>12;
  end;
  //riteln('Load');
  if bOk then
  begin
    p:=1;
    bDone:=false;
    while (not bDone) do begin
      sChID:=saIn[p]+saIn[p+1]+saIn[p+2]+saIn[p+3];
      //riteln('Chunk ID: ', sCHID);
      r4ByteCast.u1[0]:=ord(saIn[p+4]);
      r4ByteCast.u1[1]:=ord(saIn[p+5]);
      r4ByteCast.u1[2]:=ord(saIn[p+6]);
      r4ByteCast.u1[3]:=ord(saIn[p+7]);
      u4ChSize:=cardinal(r4ByteCast);
      //riteln('Chunk size: ',inttostr(u4ChSize));

      if sCHID='RIFF' then
      begin
        setlength(ar, length(ar)+1);
        ar[length(ar)-1]:=getmem(sizeof(rtWaveRiff));
        rWaveRiff:=ar[length(ar)-1];
        rWaveRiff^.acChID[0]:=saIn[p]; p+=1;
        rWaveRiff^.acChID[1]:=saIn[p]; p+=1;
        rWaveRiff^.acChID[2]:=saIn[p]; p+=1;
        rWaveRiff^.acChID[3]:=saIn[p]; p+=1;
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rWaveRiff^.u4ChunkSize:=cardinal(r4ByteCast);
        rWaveRiff^.acWaveID[0]:=saIn[p]; p+=1;
        rWaveRiff^.acWaveID[1]:=saIn[p]; p+=1;
        rWaveRiff^.acWaveID[2]:=saIn[p]; p+=1;
        rWaveRiff^.acWaveID[3]:=saIn[p]; p+=1;
      end else

      if sChID='fmt ' then
      begin
        setlength(ar, length(ar)+1);
        ar[length(ar)-1]:=getmem(sizeof(rtFormat));
        rFormat:=ar[length(ar)-1];
        //riteln('after format mem allocated');
        rFormat^.acChID[0]:=saIn[p]; p+=1;
        rFormat^.acChID[1]:=saIn[p]; p+=1;
        rFormat^.acChID[2]:=saIn[p]; p+=1;
        rFormat^.acChID[3]:=saIn[p]; p+=1;
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rFormat^.u4ChunkSize:=cardinal(r4ByteCast);
        r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        rFormat^.u2FormatTag:=word(r2ByteCast);
        r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        rFormat^.u2Channels:=word(r2ByteCast);
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rFormat^.u4SamplesPerSec:=cardinal(r4ByteCast);
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rFormat^.u4AvgBytesPerSec:=cardinal(r4ByteCast);
        r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        rFormat^.u2BlockAlign:=word(r2ByteCast);
        r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        rFormat^.u2BitsPerSample:=word(r2ByteCast);
        //riteln('Format Fixed Section');
        //--------16 Chunk Size Stops Above this line
        if u4ChSize>=16 then
        begin
          r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
          r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
          rFormat^.u2Size:=word(r2ByteCast);
          //if u4ChSize=18 then
          if rFormat^.u2Size=22 then
          begin
            //--------18 Chunk Size Stops Above this line
            r2ByteCast.u1[0]:=ord(saIn[p]);p+=1;
            r2ByteCast.u1[1]:=ord(saIn[p]);p+=1;
            rFormat^.u2ValidBitsPerSample:=word(r2ByteCast);
            r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
            r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
            r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
            r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
            rFormat^.u4ChannelMask:=cardinal(r4ByteCast);
            rFormat^.acSubformat[0]:=saIn[p];p+=1;
            rFormat^.acSubformat[1]:=saIn[p];p+=1;
            rFormat^.acSubformat[2]:=saIn[p];p+=1;
            rFormat^.acSubformat[3]:=saIn[p];p+=1;
            rFormat^.acSubformat[4]:=saIn[p];p+=1;
            rFormat^.acSubformat[5]:=saIn[p];p+=1;
            rFormat^.acSubformat[6]:=saIn[p];p+=1;
            rFormat^.acSubformat[7]:=saIn[p];p+=1;
            rFormat^.acSubformat[8]:=saIn[p];p+=1;
            rFormat^.acSubformat[9]:=saIn[p];p+=1;
            rFormat^.acSubformat[10]:=saIn[p];p+=1;
            rFormat^.acSubformat[11]:=saIn[p];p+=1;
            rFormat^.acSubformat[12]:=saIn[p];p+=1;
            rFormat^.acSubformat[13]:=saIn[p];p+=1;
            rFormat^.acSubformat[14]:=saIn[p];p+=1;
            rFormat^.acSubformat[15]:=saIn[p];p+=1;
          end;
        end;
        //riteln('done Format');
      end else

      if sChID='fact' then
      begin
        //riteln('start fact');
        setlength(ar, length(ar)+1);
        ar[length(ar)-1]:=getmem(sizeof(rtFact));
        rFact:=ar[length(ar)-1];
        rFact^.acChID[0]:=saIn[p]; p+=1;
        rFact^.acChID[1]:=saIn[p]; p+=1;
        rFact^.acChID[2]:=saIn[p]; p+=1;
        rFact^.acChID[3]:=saIn[p]; p+=1;
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rFact^.u4ChunkSize:=cardinal(r4ByteCast);
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rFact^.u4SampleLength:=cardinal(r4ByteCast);
        //riteln('done Fact');
      end else

      if sChID='data' then
      begin
        //riteln('Top of Data');
        setlength(ar, length(ar)+1);
        ar[length(ar)-1]:=getmem(sizeof(rtData));
        rData:=ar[length(ar)-1];
        rData^.acChID[0]:=saIn[p]; p+=1;
        rData^.acChID[1]:=saIn[p]; p+=1;
        rData^.acChID[2]:=saIn[p]; p+=1;
        rData^.acChID[3]:=saIn[p]; p+=1;
        r4ByteCast.u1[0]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[1]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[2]:=ord(saIn[p]);p+=1;
        r4ByteCast.u1[3]:=ord(saIn[p]);p+=1;
        rData^.u4ChunkSize:=cardinal(r4ByteCast);
        u4Samples:=rData^.u4ChunkSize div 2;
        rData^.lpData:=getmem(rData^.u4ChunkSize);
        //riteln('Data Load: rData^.lpData: ',MemSize(rData^.lpData), ' ChunkSize: ',rData^.u4ChunkSize);

        for u:=0 to rData^.u4ChunkSize-1 do begin
          u1Pad:=rData^.lpData+u;
          u1Pad^:=ord(saIn[p+u]);
        end;
        p+=rData^.u4ChunkSize;
        if (rData^.u4ChunkSize mod 2)=1 then
        begin
          p+=1;
        end;
      end else
      begin
        bDone:=true;
      end;
    end;//while
    //riteln('Done Load. p:'+inttostr(p)+' Len saData:' +inttostr(length(saData)));
  end;
  result:=bOk;
end;
//=============================================================================


//=============================================================================
function TWAVE.Save(p_saFilename: ansistring; var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  u2IOResult: word;
  u4Sent: cardinal;
  u: cardinal;
  rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  rFact: ^rtFact;
  rData: ^rtData;
  f: file;
  bfileOpen: boolean;
  u1Pad: ^byte;
begin
  p_u8Result:=0;
  p_saresult:='Ok';

  bFileOpen:=bTSOpenUTFile(p_saFilename, u2IOresult,f, 1, false, false);
  bOk:=bFileOpen;
  if not bOk then
  begin
    p_u8Result:=201204191410;
    p_saresult:='Save IO Error opening file: '+saIOResult(u2IOResult);
  end;

  if bOk then
  begin
    if length(ar)>0 then
    begin
      u:=0;
      repeat
        rWaveRiff:=ar[u];
        //=======================================================WAVERIFF
        if bCmpID(rWaveRiff^.acChId,'RIFF') then
        begin
          {$I-}
          blockwrite(f, rWaveRiff^,sizeof(rtWaveRiff),u4Sent);
          {$I+}
          bOk:=u4Sent=sizeof(rtWaveRiff);
          if not bOk then
          begin
            p_u8Result:=201204191411;
            p_saresult:='Save Error';
          end;
        end else
        //=======================================================WAVERIFF



        //=======================================================FACT
        if bCmpID(rWaveRiff^.acChId,'fact') then
        begin
          rFact:=ar[u];
          {$I-}
          blockwrite(f, rFact^, sizeof(rtFact),u4Sent);
          {$I+}
          bOk:=u4Sent=sizeof(rtFact);
          if not bOk then
          begin
            p_u8Result:=201204191430;
            p_saresult:='Save Error';
          end;
        end else
        //=======================================================FACT

        //=======================================================FORMAT
        if bCmpID(rWaveRiff^.acChId,'fmt ') then
        begin
          rFormat:=ar[u];
          {$I-}
          blockwrite(f, rFormat^,24,u4Sent);
          {$I+}
          bOk:=u4Sent=24;
          if not bOk then
          begin
            p_u8Result:=201204191431;
            p_saresult:='Save Error';
          end;

          if bOk and (rFormat^.u4ChunkSize>16) then
          begin
            {$I-}
            blockwrite(f, rFormat^.u2Size,2,u4Sent);
            {$I+}
            bOk:=u4Sent=2;
            if not bOk then
            begin
              p_u8result:=201204191414;
              p_saResult:='Save IO Error';
            end;
            if bOk and (rFormat^.u2Size=22) then
            begin
              {$I-}
              blockwrite(f, rFormat^.u2ValidBitsPerSample,22,u4Sent);
              {$I+}
              bOk:=u4Sent=22;
              if not bOk then
              begin
                p_u8Result:=201204191415;
                p_saResult:='Save IO Error';
              end;
            end;
          end;
        end else
        //=======================================================FORMAT

        //=======================================================DATA
        if bCmpID(rWaveRiff^.acChId,'data') then
        begin
          //riteln('Saving Data Header');
          rData:=ar[u];
          {$I-}
          blockwrite(f, rData^,8,u4Sent);
          {$I+}
          bOk:=u4Sent=8;
          if not bOk then
          begin
            p_u8Result:=201204191432;
            p_saResult:='Save Error';
          end;

          if bOk then
          begin
            //riteln('Saving Data. rData^.lpData: ',MemSize(rData^.lpData), ' ChunkSize: ',rData^.u4ChunkSize);
            {$I+}
            blockwrite(f,rData^.lpData^,rData^.u4ChunkSize,u4Sent);
            {$I-}
            bOk:=u4Sent=rData^.u4ChunkSize;
            if not bOk then
            begin
              p_u8Result:=201204191418;
              p_saresult:='Save IO Error';
            end;

            if bOk and ((rData^.u4ChunkSize mod 2)=1) then
            begin
              //riteln('Saving Data Pad Byte');
              u1Pad:=rData^.lpData+rData^.u4ChunkSize;
              u1Pad^:=0;
              {$I-}
              blockwrite(f,u1Pad,1,u4Sent);
              {$I+}
              bOk:=u4Sent=1;
              if not bOk then
              begin
                p_u8result:=201204191419;
                p_saResult:='Save IO Error';
              end;
            end;
          end;
        end;
        //=======================================================DATA

        u+=1;
      until (not bOk) or (u=length(ar));
    end;
  end;

  if bFileOpen then
  begin
    u2IOresult:=0;
    bTSCloseUTFile(p_saFilename,u2IOResult,f);
    if u2IOResult<>0 then
    begin
      p_u8Result:=201204191420;
      p_saResult:='Save IO Error: '+saIOREsult(u2IOResult);
    end;
  end;


  result:=bOk;
end;
//=============================================================================






//=============================================================================
function TWAVE.saDiagnosticInfo: ansistring;
//=============================================================================
var
  sa: ansistring;
  i: longint;
  t: longint;
  rWaveRiff: ^rtWaveRiff;
  rFormat: ^rtFormat;
  rFact: ^rtFact;
  rData: ^rtData;
begin
  //riteln('DIAG - saData len:',length(saData));
  if length(ar)=0 then
  begin
    sa:='No Wave file loaded: Nothing to report.';
  end
  else
  begin
    sa:='Samples: '+inttostr(u4Samples);
    for i:=0 to length(ar)-1 do
    begin
      //riteln('Diag loop i: ',i);
      //riteln('Len Data: '+inttostr(length(saData)));
      //riteln('Len ar: '+inttostr(length(ar)));
      rWaveRiff:=ar[i];
     
      if bCmpID(rWaveRiff^.acCHID,'RIFF') then
      begin
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='WaveRif Structure'+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Chunk ID: '+saID(rWaveRiff^.acChId)+csCRLF;
        sa+='Chunk Size: '+inttostr(rWaveRiff^.u4ChunkSize)+csCRLF;
        sa+='Wave ID: '+saID(rWaveRiff^.acWaveID)+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF+csCRLF;
        //riteln('WAVERIFF Output: '+csCRLF+sa);
      end else

      if bCmpID(rWaveRiff^.acCHID,'fmt ') then
      begin
        rFormat:=ar[i];
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Format Chunk'+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Chunk ID: '+saID(rFormat^.acChID)+csCRLF;
        sa+='Chunk Size: '+inttostr(rFormat^.u4ChunkSize)+csCRLF;
        sa+='Format Tag: '+inttostr(rFormat^.u2FormatTag)+csCRLF;
        sa+='Channels :'+inttostr(rFormat^.u2Channels)+csCRLF;
        sa+='Samples Per Second: '+inttostr(rFormat^.u4SamplesPerSec)+csCRLF;
        sa+='Average Bytes Per Second: '+inttostr(rFormat^.u4AvgBytesPerSec)+csCRLF;
        sa+='Block Align: '+inttostr(rFormat^.u2BlockAlign)+csCRLF;
        sa+='Bits Per Sample: '+inttostr(rFormat^.u2BitsPerSample)+csCRLF;
        if rFormat^.u4ChunkSize>=16 then
        begin
          sa+='Size: '+inttostr(rFormat^.u2Size)+csCRLF;
          //if rFormat^.u4ChunkSize=18 then
          if rFormat^.u2Size=22 then
          begin
            sa+='Valid Bits Per Sample: '+inttostr(rFormat^.u2ValidBitsPerSample)+csCRLF;
            sa+='Channel Mask: '+inttostr(rFormat^.u4ChannelMask)+csCRLF;
            sa+='Subformat: ';
            for t:=0 to 15 do sa+=rFormat^.acSubformat[t];
            sa+=csCRLF;
          end;
        end;
        sa+=saRepeatChar('-',78)+csCRLF+csCRLF;
      end else

      if bCmpID(rWaveRiff^.acCHID,'fact') then
      begin
        rFact:=ar[i];
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Fact Chunk'+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Chunk ID: '+saID(rFact^.acChID)+csCRLF;
        sa+='Chunk Size: '+inttostr(rFact^.u4ChunkSize)+csCRLF;
        sa+='Samples Length: '+inttostr(rFact^.u4SampleLength)+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF+csCRLF;
      end else

      if bCmpID(rWaveRiff^.acCHID,'data') then
      begin
        rData:=ar[i];
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Data Chunk'+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF;
        sa+='Chunk ID: '+saID(rData^.acChID)+csCRLF;
        sa+='Chunk Size: '+inttostr(rData^.u4ChunkSize)+csCRLF;
        sa+=saRepeatChar('-',78)+csCRLF+csCRLF;
      end;
    end;
  end;
  result:=sa;
end;
//=============================================================================






//=============================================================================
Procedure TWAVE.DumpSamples;
//=============================================================================
var
  u4Loop: cardinal;
  //rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  //rFact: ^rtFact;
  rData: ^rtData;

  u4:     cardinal;
  aSrc: ^smallint;
  uSrcLen: Cardinal;
  i2Pos: smallint;
  i2Neg: smallint;
begin
  if length(ar)>0 then
  begin
    u4Loop:=0;
    repeat
      rWaveRiff:=ar[u4Loop];
      //=======================================================WAVERIFF
      //if bCmpID(rWaveRiff^.acChId,'RIFF') then
      //begin
      //end else
      //=======================================================WAVERIFF

      //=======================================================FACT
      //if bCmpID(rWaveRiff^.acChId,'fact') then
      //begin
      //end else
      //=======================================================FACT

      //=======================================================FORMAT
      //if bCmpID(rWaveRiff^.acChId,'fmt ') then
      //begin
      //end else
      //=======================================================FORMAT

      //=======================================================DATA
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        rData:=ar[u4Loop];
        uSrcLen:=rData^.u4ChunkSize div 2;
        i2Pos:=0;
        i2Neg:=0;
        for u4:=0 to uSrcLen-1 do
        begin
          aSrc:=rData^.lpData+(u4*2);
          write(aSrc^,' ');
          if aSrc^ > i2Pos then i2Pos:=aSrc^;
          if aSrc^ < i2Neg then i2Neg:=aSrc^;
        end;
        //riteln;
        //riteln('i2Pos: ',i2Pos);
        //riteln('i2Neg: ',i2Neg);
      end;
      //riteln;
      //=======================================================DATA
      u4Loop+=1;
    until (u4Loop=length(ar));
  end;
end;
//=============================================================================














//=============================================================================
function TWAVE.bNormalize(var p_u8Result: UInt64; var p_saResult: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  rWaveRiff: ^rtWaveRiff;
  rData: ^rtData;
  u: cardinal;
  uLoop:cardinal;
  aSrc: ^SmallInt;
  uSrcLen: Cardinal;
  i2Diff: SmallInt;
  fDiff: double;
  i2Loudest: SmallInt;
  i2LoudestNeg: SmallInt;
  fLoudest: double;
  fPCtMove: double;
begin
  p_u8Result:=0;
  p_saresult:='Ok';
  rData:=nil;

  bOk:=length(ar)>0;
  if not bOk then
  begin
    p_u8result:=201204210454;
    p_saresult:='No Data';
  end;

  if bOk then
  begin
    u:=0;
    repeat
      rWaveRiff:=ar[u];
      //=======================================================DATA
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        bOk:=rData=nil;
        if not bOk then
        begin
          p_u8result:=201204210456;
          p_saresult:='More than one sample chunk found. Not Supported.';
        end;
        if bOk then
        begin
          rData:=ar[u];
          //riteln('Normalizing...');
          uSrcLen:=rData^.u4ChunkSize div 2;
            i2Loudest:=0; i2LoudestNeg:=0;
          for uLoop:=0 to uSrcLen-1 do
          begin
            aSrc:=rData^.lpData+(uLoop*2);
            if aSrc^>0 then
            begin
              if aSrc^ > i2Loudest then i2Loudest:=aSrc^;
            end
            else
            begin
              if aSrc^ < i2LoudEstNeg then i2LoudestNeg:=aSrc^;
            end;
          end;

          if i2Loudest > abs(i2LoudestNeg) then
          begin
            i2Diff:=32767-i2Loudest;
          end
          else
          begin
            i2Loudest:=abs(i2LoudestNeg);
            i2Diff:= 32767-i2Loudest;
          end;
          fDiff:=i2Diff;
          fLoudest:=i2Loudest;

          if fLoudest=0 then fPctMove:=0 else fPctMove:=fDiff/fLoudest;

          if i2Diff>0 then
          begin
            for uLoop:=0 to uSrcLen-1 do
            begin
              aSrc:=rData^.lpData+(uLoop*2);
              if aSrc^>0 then
              begin
                aSrc^:=aSrc^ + round( abs(aSrc^) * fPctMove);
              end else

              if aSrc^<0 then
              begin
                aSrc^:=aSrc^ - round( abs(aSrc^) * fPctMove);
              end;
            end;
          end;
          //riteln('fPCTMove: ', fPctMove);
          //riteln('Normalization Diff:',i2Diff, ' fDiff: ',fDiff, ' i2Loudest: ',i2Loudest);
          //riteln('fLoudest: ',fLoudest, ' i2LoudestNeg: ',i2LoudestNeg);
        end;
      end;
      //=======================================================DATA
      u+=1;
    until (not bOk) or (u=length(ar));

    if bOk then
    begin
      bOk:=rData<>nil;
      begin
        if rData=nil then
        begin
          p_u8result:=201204210455;
          p_saresult:='Sample Data Not found';
        end;
      end;
    end;
  end;
  result:=bok;
end;
//=============================================================================










//=============================================================================
function TWAVE.bMakeBitMap(
  p_uWidth: cardinal;
  p_uHeight: cardinal;
  p_u1PenR: byte;
  p_u1PenG: byte;
  p_u1PenB: byte;
  p_u1BgR: byte;
  p_u1BgG: byte;
  p_u1BgB: byte;
  p_saFilename: ansistring;
  p_u8Result: UInt64;
  p_saResult: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  u2IOResult: word;

  PG: TPIXELGRID;

  uLoop: cardinal;
  //rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  //rFact: ^rtFact;
  rData: ^rtData;

  u:     cardinal;
  aSrc: ^smallint;
  uSrcLen: Cardinal;

  fFracWidth:  double;
  fFracHeight: double;
  fX: double;
  fY: double;
  fYMiddle: double;
  
begin
  p_u8Result:=0;
  p_saResult:='Ok';
  //RGBA:=TRGBA.Create;
  PG:=TPIXELGRID.Create;
  bOk:=PG.Size_Set(p_uWidth, p_uHeight);
  if not bOk then
  begin
    p_u8Result:=201204211313;
    p_saResult:='Unable to Size_Set PixelGrid to '+inttostr(p_uWidth)+ 'x'+inttostr(p_uHeight);
  end;

  if bOk then
  begin
    PG.FillRGB(p_u1BgR, p_u1BgG, p_u1BgB);
    if length(ar)>0 then
    begin
      rData:=nil;
      uLoop:=0;
      repeat
        rWaveRiff:=ar[uLoop];
        //=======================================================DATA
        if bCmpID(rWaveRiff^.acChId,'data') then
        begin
          bOk:=rData=nil;
          if not bOk then
          begin
            p_u8Result:=201204211314;
            p_saResult:='Multiple Data Chunks encountered. Not supported.';
          end;
          if bOk then
          begin
            rData:=ar[uLoop];
            uSrcLen:=rData^.u4ChunkSize div 2;
            fFracWidth:=p_uWidth / uSrcLen;
            fYMiddle:=p_uHeight/2;
            fFracHeight:=fYMiddle/32767;
            fX:=0;
            fY:=0;
            //fOX:=0;
            //fOY:=0;
            for u:=0 to uSrcLen-1 do
            begin
              aSrc:=rData^.lpData+(u*2);
              //fOX:=fX;
              //fOY:=fY;

              fX:=fFracWidth*u;
              fY:=fFracHeight*abs(aSrc^);
              if aSrc^>0 then fy:=fYMiddle-fY else
              if aSrc^<0 then fy:=fYMiddle+fY;
              //RGBA.Red_Set(p_u1PenR);
              //RGBA.Green_Set(p_u1PenG);
              //RGBA.Blue_Set(p_u1PenB);
              //RGBA.Alpha_Set(0);
              //PG.Line(round(fX), round(fY), round(fOX), round(fOY), RGBA.RGBA_Get);
              PG.RGB_Set(Round(fx), round(fy), p_u1PenR, p_u1PenG, p_u1PenB);
            end;
          end;
        end;
        //=======================================================DATA
        uLoop+=1;
        if (uLoop mod 100)=100 then Sleep(0);
      until (not bOk) or (uLoop=length(ar));
    end;
  end;

  if bOk then
  begin
    u2IOResult:=PG.u2SaveBitmap24(p_saFilename,nil, nil);
    bOk:=u2IOResult=0;
    if not bOk then
    begin
      p_u8Result:=201204211318;
      p_saResult:='Unable to save bitmap. '+saIOResult(u2IOREsult)+ ' file: '+p_saFilename;
    end;
  end;
  //RGBA.Destroy;
  PG.Destroy;
  result:=bOk;
end;
//=============================================================================









//=============================================================================
function TWAve.bSynchronize(
  p_lpSameTypeOfClass: pointer;
  var p_iOffset: longint;
  var p_fLowestScore: double;
  var p_u8Result: UInt64;
  var p_saResult: ansistring;
  p_saDisplay: ansistring
):boolean;
//=============================================================================
var
  bOk: Boolean;
  iOffset1: longint;
  fLowest1: double;

  iOffset2: longint;
  fLowest2: double;
begin
  p_u8Result:=0;
  p_saresult:='Ok';

  //riteln('Synchronization - PASS 1 ---------------------------------------');
  bOk:=pvt_bSynchronize(self, p_lpSameTypeOfClass,p_iOffset, p_fLowestScore, p_u8result, p_saresult, p_saDisplay);
  if bOk then
  begin
    iOffSet1:=p_iOffset;
    fLowest1:=p_fLowestScore;
    //riteln;
    //riteln('Synchronization - PASS 2 ---------------------------------------');
    bOk:=pvt_bSynchronize(p_lpSameTypeOfClass, self, p_iOffset, p_fLowestScore, p_u8result, p_saresult, p_saDisplay);
    if bOk then
    begin
      iOffSet2:=p_iOffset;
      fLowest2:=p_fLowestScore;
      if fLowest1<fLowest2 then
      begin
        p_fLowestScore:=fLowest1;
        p_iOffset:=iOffset1;
      end
      else
      begin
        p_fLowestScore:=fLowest2;
        p_iOffset:=iOffset2*-1;
      end;
    end;
  end;
  result:=bOk;
end;
//=============================================================================





//=============================================================================
function TWAve.pvt_bSynchronize(
  p_lpSameTypeOfClass1: pointer;
  p_lpSameTypeOfClass2: pointer;
  var p_iOffset: longint;
  var p_fLowestScore: double;
  var p_u8Result: UInt64;
  var p_saResult: ansistring;
  p_saDisplay: ansistring
):boolean;
//=============================================================================
var
  bOk: Boolean;
  Wave1: TWave;
  Wave2: TWave;
  uLoop: cardinal;// Main Decipher loops

  rWaveRiff: ^rtWaveRiff;

  u: cardinal;
  uCommonLen: cardinal;

  rSrcData: ^rtData;
  uSrcLen: Cardinal;
  i2Src: ^smallint;
  fSrc: double;
  fSrcPrev: double;
  afSrcRat: array of double;

  rDestData: ^rtData;
  uDestLen: Cardinal;
  i2Dest: ^smallint;
  fDest: double;
  fDestPrev: double;
  afDestRat: array of double;

  uOffSet: cardinal;
  afScore: array of double;

  iWriteDelay: longint;

  u4ScoreLen: cardinal; // LENGTH of SWATH
  fScoreAvg: double;
begin
  // ======================================================== PREPARE
  rWaveRiff:=nil;
  rSrcData:=nil;
  i2Src:=nil;
  rDestData:=nil;
  i2Dest:=nil;
  p_u8Result:=0;
  p_saresult:='Ok';
 
  bOk:=p_lpSameTypeOfClass1<>nil;
  if not bOk then
  begin
    p_u8Result:=201204241533;
    p_saresult:='Wave1 is null.';
  end;

  bOk:=p_lpSameTypeOfClass2<>nil;
  if not bOk then
  begin
    p_u8Result:=201204241534;
    p_saresult:='Wave2 is null.';
  end;


  if bOk then
  begin
    Wave1:=TWAVE(p_lpSameTypeOfClass1);
    bOk:=length(Wave1.ar)>0;
    if not bOk then
    begin
      p_u8Result:=201204241541;
      p_saresult:='No data in Wave class.';
    end;
  end;



  if bOk then
  begin
    Wave2:=TWAVE(p_lpSameTypeOfClass2);
    bOk:=length(Wave2.ar)>0;
    if not bOk then
    begin
      p_u8Result:=201204241535;
      p_saresult:='No data in Wave class.';
    end;
  end;
  // ======================================================== PREPARE

  //====================================================== HUNT for Src Data
  if bOk then
  begin
    uLoop:=0;
    repeat
      rWaveRiff:=Wave1.ar[uLoop];
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        bOk:=rSrcData=nil;
        if not bOk then
        begin
          p_u8Result:=201204241536;
          p_saresult:='Multiple data chunks in Wave class. Not Supported.';
        end;
        if bOk then
        begin
          rSrcData:=Wave1.ar[uLoop];
        end;
      end;
      uLoop+=1;
    until (not bOk) or (uLoop=length(Wave1.ar));
  end;

  if bOk then
  begin
    bOk:=rSrcData<>nil;
    if not bOk then
    begin
      p_u8Result:=201204241537;
      p_saresult:='Unable to locate Data chunk in Wave class.';
    end;
  end;
  //====================================================== HUNT for Src Data



  //====================================================== HUNT for Dest Data
  if bOk then
  begin
    bOk:=length(Wave2.ar)>0;
    if not bOk then
    begin
      p_u8result:=201204241538;
      p_saresult:='No data in other Wave class.';
    end;
  end;

  if bOk then
  begin
    uLoop:=0;
    repeat
      rWaveRiff:=Wave2.ar[uLoop];
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        bOk:=rDestData=nil;
        if not bOk then
        begin
          p_u8Result:=201204241539;
          p_saresult:='Multiple data chunks in Other Wave class. Not Supported.';
        end;
        if bOk then
        begin
          rDestData:=Wave2.ar[uLoop];
        end;
      end;
      uLoop+=1;
    until (not bOk) or (uLoop=length(Wave2.ar));
  end;

  if bOk then
  begin
    bOk:=rDestData<>nil;
    if not bOk then
    begin
      p_u8Result:=201204241540;
      p_saresult:='Unable to locate Data chunk in other Wave class.';
    end;
  end;
  //====================================================== HUNT for Dest Data




  // ===================================================== PASS 1 - GET RATIOS
  if bOK then
  begin
    // Find Common Length from beginning of WAVE sounds.
    // the shorter of the two
    iWriteDelay:=0;
    uSrcLen:=rSrcData^.u4ChunkSize div 2;
    uDestLen:=rDestData^.u4ChunkSize div 2;
    if (uSrcLen>2) and (uDestLen>2) then
    begin
      uCommonlen:=uSrcLen;
      if uSrcLen>uDestLen then ucommonLen:=uDestLen else uCommonLen:=uSrcLen;
      //uCommonLen:=uCommonLen div 2;

      // NEW if uSrcLen>uDestLen then ucommonLen:=uSrcLen else uCommonLen:=uDestLen;
      

      setlength(afSrcRat,uCommonLen);
      setlength(afDestRat,uCommonLen);

      u:=0; fSrc:=0;iWriteDelay:=0;
      repeat
        if u>0 then fSrcPrev:=fSrc else fSrcPrev:=0;
        //if u<uSrcLen then
        //begin
          i2Src:=rSrcData^.lpData+(u*2);
          fSrc:=i2Src^;
        //end
        //else
        //begin//new
        //  fSrc:=0;
        //end;
        if u>0 then
        begin
          if (fSrc<>0) then //and (u<=uSrcLen) then
          begin
            afSrcRat[u]:=abs(abs(fSrcPrev) / abs(fSrc) );
          end
          else
          begin
            afSrcRat[u]:=0;
          end;
        end
        else
        begin
          afSrcRat[u]:=0;
        end;
        iWriteDelay+=1;
        if (iWritedelay mod 1000)=0 then Sleep(0);
        if iWriteDelay = 50000 then
        begin
          iWriteDelay:=0;
          writeln('Calculating Src Ratio ',u,' of ',ucommonlen,' '+p_saDisplay);
        end;
        u+=1;
      until u>=ucommonLen;


      u:=0; fDest:=0;
      repeat
        if u>0 then fDestPrev:=fDest else fDestPrev:=0;
        //if u<uDestLen then
        //begin
          i2Dest:=rDestData^.lpData+(u*2);
          fDest:=i2Dest^;
        //end
        //else
        //begin
        //  fDest:=0;
        //end;

        if u>0 then
        begin
          if (fDest<>0) then // and (u<uDestLen) then
          begin
            afDestRat[u]:=abs(abs(fDestPrev) / abs(fDest) );
          end
          else
          begin
            afDestRat[u]:=0;
          end;
        end
        else
        begin
          afDestRat[u]:=0;
        end;
        iWriteDelay+=1;
        if (iWritedelay mod 1000)=0 then Sleep(0);
        if iWriteDelay = 50000 then
        begin
          iWriteDelay:=0;
          writeln('Calculating Dest Ratio ',u,' of ',ucommonlen,' '+p_saDisplay);
        end;
        u+=1;
      until u>=ucommonLen;
    end;
  end;
  //riteln('Ratios Gathered');
  // ===================================================== PASS 1 - GET RATIOS


  // ===================================================== PASS 2 - SCORE Positions
  if bOk then
  begin
    iWriteDelay:=0;
    //riteln('<<<<<<<<<<<<  Started Scoring  >>>>>>>>>>>');
    uOffSet:=0;
    u4ScoreLen:=uCommonLen div 2;//div 4 does first two samples perfect
    setlength(afScore, u4ScoreLen);
    repeat
      u:=0;
      afScore[uOffSet]:=0;
      fScoreAvg:=0;
      repeat
        if (u<length(afSrcRat)) and ((u+uOffSet)<length(afDestRat)) then
        begin
          afScore[uOffSet]:=afScore[uOffSet]+abs(afSrcRat[u]-afDestRat[u+uOffSet]);
          fScoreAvg+=afScore[uOffSet];
        end
        else
        begin
          //riteln('Out of Range - Skews Score');
          afScore[uOffSet]:=fScoreAvg / u;
        end;
        u+=1;
        //u+=10;
      until u > u4ScoreLen;
      uOffSet+=1;
      iWriteDelay+=1;
      if (iWritedelay mod 100)=0 then Sleep(0);
      if iWriteDelay = 5000 then
      begin
        iWriteDelay:=0;
        writeln('Scoring Ratio ',uOffSet,' of ',u4ScoreLen,' '+p_saDisplay);
      end;
    until uOffset>=u4ScoreLen;
    writeln('Done.');
  end;
  // ===================================================== PASS 2 - SCORE Positions


  // ===================================================== PASS 3 - Show Lowest Scores
  if bOk then
  begin
    p_fLowestScore:=99999999; uOffSet:=0;
    //riteln('Locating Lowest Score');
    for u:=0 to u4ScoreLen-1 do begin
      //riteln(' SCORES: ', round(afScore[u]));
      if afScore[u]<p_fLowestScore then
      begin
        p_fLowestScore:=afScore[u];
        uOffSet:=u;
        //riteln('New Lowest Score: ',p_fLowestScore);
      end;
    end;
    //riteln('Lowest Score: ',p_fLowestScore, ' offset:', uOffSet, ' Int Score: ',round(p_fLowestScore));
    p_iOffset:=uOffset;
  end;
  // ===================================================== PASS 3 - Show Lowest Scores

  setlength(afSrcRat,0);
  setlength(afDestRat,0);
  setlength(afScore,0);
  result:=bOk;
end;
//=============================================================================


//=============================================================================
// this function assumes 16bit mono wave with one data chunk.
// It can truncate or lengthen the wave file.
function TWAVE.bSetLength(p_InWords: cardinal): boolean;
//=============================================================================
var
  bOk: boolean;
  uLoop: cardinal;
  rWaveRiff: ^rtWaveRiff;
  rData: ^rtData;
  lp: pointer;
  u: cardinal;
  uOldLen: cardinal;
  u2Src: ^word;
  u2Dest: ^word;

begin
  bOk:=(length(ar)>0);
  if bOk then
  begin
    u4Samples:=p_InWords;
    uLoop:=0;
    repeat
      rWaveRiff:=ar[uLoop];
      //=======================================================WAVERIFF
      //if bCmpID(rWaveRiff^.acChId,'RIFF') then
      //begin
      //end else
      //=======================================================WAVERIFF

      //=======================================================FACT
      //if bCmpID(rWaveRiff^.acChId,'fact') then
      //begin
      //end else
      //=======================================================FACT

      //=======================================================FORMAT
      //if bCmpID(rWaveRiff^.acChId,'fmt ') then
      //begin
      //end else
      //=======================================================FORMAT

      //=======================================================DATA
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        rData:=ar[uLoop];
        if p_InWords=0 then
        begin
          freemem(rData^.lpData);
          rData^.u4ChunkSize:=0;
          rData^.lpData:=nil;
        end
        else
        begin
          uOldLen:=rData^.u4ChunkSize div 2;
          lp:=getmem(p_InWords*2);
          rData^.u4ChunkSize:=p_InWords*2;
          u:=0;
          repeat
            u2Dest:=lp+(u*2);
            if u<=uOldLen then
            begin
              u2Src:=rData^.lpData+(u*2);
              u2Dest:=lp+(u*2);
              u2Dest^:=u2Src^;
            end
            else
            begin
              u2Dest^:=0;
            end;
            u+=1;
          until u>=p_InWords;
          freemem(rData^.lpData);
          rData^.lpData:=lp;
          bOk:=true;
        end;
      end;
      //=======================================================DATA
      uLoop+=1;
    until (uLoop=length(ar));
  end;
  result:=bOk;
end;
//=============================================================================







//=============================================================================
// this function assumes 16bit mono wave with one data chunk.
function TWAVE.bInsertQuietAtBeginning(p_InWords: cardinal): boolean;
//=============================================================================
var
  bOk: boolean;
  uLoop: cardinal;
  rWaveRiff: ^rtWaveRiff;
  rData: ^rtData;
  lp: pointer;
  u: cardinal;
  uOldLen: cardinal;
  u2Src: ^word;
  u2Dest: ^word;
  uNewLen: cardinal;
begin
  bOk:=(length(ar)>0);
  if bOk then
  begin
    uLoop:=0;
    repeat
      rWaveRiff:=ar[uLoop];
      //=======================================================WAVERIFF
      //if bCmpID(rWaveRiff^.acChId,'RIFF') then
      //begin
      //end else
      //=======================================================WAVERIFF

      //=======================================================FACT
      //if bCmpID(rWaveRiff^.acChId,'fact') then
      //begin
      //end else
      //=======================================================FACT

      //=======================================================FORMAT
      //if bCmpID(rWaveRiff^.acChId,'fmt ') then
      //begin
      //end else
      //=======================================================FORMAT

      //=======================================================DATA
      if bCmpID(rWaveRiff^.acChId,'data') then
      begin
        rData:=ar[uLoop];
        if p_InWords>0 then
        begin
          uOldLen:=rData^.u4ChunkSize div 2;
          uNewLen:=p_InWords+uOldLen;
          lp:=getmem(uNewLen*2);
          rData^.u4ChunkSize:=uNewLen*2;
          u4Samples:=uNewLen;
          u:=0;
          repeat
            u2Dest:=lp+(u*2);
            if u<p_Inwords then
            begin
              u2Dest^:=0;
            end
            else
            begin
              u2Src:=rData^.lpData+((u-p_InWords)*2);
              u2Dest^:=u2Src^;
            end;
            u+=1;
          until u>=uNewLen;
          freemem(rData^.lpData);
          rData^.lpData:=lp;
          bOk:=true;
        end;
      end;
      //=======================================================DATA
      uLoop+=1;
    until (uLoop=length(ar));
  end;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
Procedure TWave.CreateNewWave(p_u4Samples: cardinal);
//=============================================================================
var
  rFormat: ^rtFormat;
  rWaveRiff: ^rtWaveRiff;
  //rFact: ^rtFact;
  rData: ^rtData;
  //u1: ^byte;
  //u: cardinal;
begin
  WaveReset;

  // RIFF
  setlength(ar, length(ar)+1);
  ar[length(ar)-1]:=getmem(sizeof(rtWaveRiff));
  rWaveRiff:=ar[length(ar)-1];
  rWaveRiff^.acChID[0]:='R';
  rWaveRiff^.acChID[1]:='I';
  rWaveRiff^.acChID[2]:='F';
  rWaveRiff^.acChID[3]:='F';
  rWaveRiff^.u4ChunkSize:=(p_u4Samples*2)+sizeof(rtWaveRiff)+sizeof(rtFormat)+sizeof(rtData);
  rWaveRiff^.acWaveID[0]:='W';
  rWaveRiff^.acWaveID[1]:='A';
  rWaveRiff^.acWaveID[2]:='V';
  rWaveRiff^.acWaveID[3]:='E';


  // FORMAT
  setlength(ar, length(ar)+1);
  ar[length(ar)-1]:=getmem(sizeof(rtFormat));
  rFormat:=ar[length(ar)-1];
  rFormat^.acChID[0]:='f';
  rFormat^.acChID[1]:='m';
  rFormat^.acChID[2]:='t';
  rFormat^.acChID[3]:=' ';
  rFormat^.u4ChunkSize:=18;
  rFormat^.u2FormatTag:=1;
  rFormat^.u2Channels:=1;
  rFormat^.u4SamplesPerSec:=44100;
  rFormat^.u4AvgBytesPerSec:=88200;
  rFormat^.u2BlockAlign:=2;
  rFormat^.u2BitsPerSample:=16;
  rFormat^.u2Size:=0;


  // FACT
  //setlength(ar, length(ar)+1);
  //ar[length(ar)-1]:=getmem(sizeof(rtFact));
  //rFact:=ar[length(ar)-1];
  //rFact^.acChID[0]:='f';
  //rFact^.acChID[1]:='a';
  //rFact^.acChID[2]:='c';
  //rFact^.acChID[3]:='t';
  //rFact^.u4ChunkSize:=p_u4Size*2;
  //rFact^.u4SampleLength:=p_u4Size;


    // DATA
  setlength(ar, length(ar)+1);
  ar[length(ar)-1]:=getmem(sizeof(rtData));
  rData:=ar[length(ar)-1];
  rData^.acChID[0]:='d';
  rData^.acChID[1]:='a';
  rData^.acChID[2]:='t';
  rData^.acChID[3]:='a';
  rData^.u4ChunkSize:=p_u4Samples*2;
  u4Samples:=p_u4Samples;
  rData^.lpData:=getmem(rData^.u4ChunkSize);

  //for u:=0 to rData^.u4ChunkSize-1 do begin
  //  u1:=rData^.lpData+u;
  //  u1^:=ord(random(255));
  //end;
  //riteln('Data Load: rData^.lpData: ',MemSize(rData^.lpData), ' ChunkSize: ',rData^.u4ChunkSize);

end;
//=============================================================================

//=============================================================================
//=============================================================================
//=============================================================================
//=====================  TWAVE   END  =========================================
//=============================================================================
//=============================================================================
//=============================================================================














//=============================================================================
//=============================================================================
//=============================================================================
//====================     TWAVEMERGE BEGIN     ===============================
//=============================================================================
//=============================================================================
//=============================================================================

//=============================================================================
Constructor TWAVEMERGE.create; //< OVERRIDE BUT INHERIT
//=============================================================================
begin
  Inherited;
  MergedWave:=TWAVE.Create;
end;
//=============================================================================

//=============================================================================
Destructor TWAVEMERGE.Destroy; //< OVERRIDE BUT INHERIT
//=============================================================================
begin
  MergedWave.Destroy;
  Inherited;
end;
//=============================================================================



//=============================================================================
Function TWAVEMERGE.pvt_CreateItem: JFC_XDLITEM;
//=============================================================================
Begin
  Result:=JFC_XDLITEM.create;
  Result.lpPtr:=pointer(TWave.create);
End;
//=============================================================================

//=============================================================================
//Procedure TWAVEMERGE.pvt_createtask;
//=============================================================================
//Begin
//  JFC_XDLITEM(lpItem).UID:=AutoNumber;
//End;
//=============================================================================

//=============================================================================
Procedure TWAVEMERGE.pvt_DestroyItem(p_lp:pointer);
//=============================================================================
Begin
  // This code is for NESTED JFC_XDL ONLY!!! Do NOT Inherit this procedure!!!!!
  // MAKE YOUR OWN!
  if(JFC_XDLITEM(p_lp).lpPtr <> nil) then
  begin
    TWAVE(JFC_XDLITEM(p_lp).lpPtr).Destroy;
    JFC_XDLITEM(p_lp).lpPtr:=nil;
  end;
  JFC_XDLITEM(p_lp).Destroy;
End;
//=============================================================================

//=============================================================================
//Procedure TWAVEMERGE.pvt_destroytask(p_lp:pointer);
//=============================================================================
//Begin
//  // This one can be totally overriden
//  //p_lp:=p_lp; // shutup compiler;
//  Inherited;
//End;
//=============================================================================



//=============================================================================
{}
// NOTE: bLoadWaves is expected to have XDL Items with the saName property
// populated with a fully qualified path/filename. So Populate the XDL
// Using AppendItem_saName('FILENAME') repeatedly for each file to merge.
// The Result Parameters return the error that caused the process to abort
// and UNLOAD the Waves.
function TWAVEMERGE.bLoadWaves(var p_u8result: UInt64; var p_saResult: Ansistring): boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=ListCount>=2;
  if not bOk then
  begin
    p_u8Result:=2012091122329;
    p_saResult:='Two or more wave file names need to be added to this class. Use Classname.AppendItem_saName(''filename'')';
  end;

  if bOk then
  begin
    Movefirst;
    repeat
      bOk:=TWAVE(JFC_XDLITEM(lpItem).lpPTR).Load(Item_saName, p_u8result, p_saResult);
    until (not bOk) or (not MoveNExt);
  end;  
    
  result:=bOk;
end;
//=============================================================================

//=============================================================================
{}
// This function merges the wave files loaded with bLoadWaves. Upon
// successful completion, call bSaveMerged to save the new wave file to
// disk.
function TWAVEMERGE.bMerge: boolean;
//=============================================================================
var
  bOk: boolean;
  arData: array of ^rtData;
  rData: ^rtData;
  rWaveRiff: ^rtWaveRiff;
  
  u4: cardinal;
  u4MaxLength: cardinal;
  i2Sum: smallint;
  //u4Result: cardinal;
  i2Divisor: smallint;
  ux: cardinal;
  rTargetData: ^rtData;
  i2Src: ^smallint;
  i2Total: ^smallint;
begin
  if MergedWave=nil then MergedWave:=TWave.Create;
  //riteln('Starting Destroy');
  setlength(arData,0);
  bOk:=ListCount>=2;
  //if not bOk then
  //begin
  //end;

  if bOk then
  begin
    //riteln('Find Actual Sample Data');
    MoveFirst;
    repeat
      //riteln('FILE: ',Item_saName);
      // BEGIN ---- FIND ACTUAL SAMPLE DATA----------------
      if length(TWAVE(JFC_XDLITEM(lpItem).lpPTR).ar)>0 then
      begin
        u4:=0;
        repeat
          rWaveRiff:=TWAVE(JFC_XDLITEM(lpItem).lpPTR).ar[u4];
          //=======================================================DATA
          if TWAVE(JFC_XDLITEM(lpItem).lpPTR).bCmpID(rWaveRiff^.acChId,'data') then
          begin
            rData:=TWAVE(JFC_XDLITEM(lpItem).lpPTR).ar[u4];
            setlength(arData, length(arData)+1);
            arData[length(arData)-1]:=rData;
            //riteln('Data Pointer Assigned. u4:',u4);
            //riteln('Chunk is assigned rtData:',arData[length(arData)-1]^.u4ChunkSize);
          end;
          //=======================================================DATA
          u4+=1;
        until (u4=length(TWAVE(JFC_XDLITEM(lpItem).lpPTR).ar));
      end
      else
      begin
        bOk:=false;// EMPTY WAVE ITEM - Not Loaded
      end;
      // END ---- FIND ACTUAL SAMPLE DATA----------------
    until (not bOk) or (not MoveNext);
  end;

  
  if bOk then
  begin
    //riteln('Find Length of longest Wave File');
    u4:=0;
    u4MaxLength:=0;
    repeat
      //riteln('Chunk Size Wave ',u4+1,': ',arData[u4]^.u4ChunkSize);
      if arData[u4]^.u4ChunkSize>u4MaxLength then
      begin
        u4MaxLength:=arData[u4]^.u4ChunkSize;
      end;
      u4+=1;
    until u4=length(arData);
    //riteln('Longest Wave file: ',u4MaxLength);
    if bOk then bOk:=u4MaxLength>0;
    if bOk then MergedWave.CreateNewWave(u4MaxLength div 2);
  end;

  
  if bOk then
  begin
    //riteln('Locate Empty MergedWave Data Location');
    u4:=0;
    repeat
      rWaveRiff:=MergedWave.ar[u4];
      //=======================================================DATA
      if MergedWave.bCmpID(rWaveRiff^.acChId,'data') then
      begin
        rTargetData:=MergedWave.ar[u4];
      end;
      //=======================================================DATA
      u4+=1;
    until (u4=length(MergedWave.ar));
  end;

  
  if bOk then
  begin
    //riteln('Actually Merge the Wave Files');
    ux:=0;
    repeat
      //riteln('Merge Outer Loop Top');
      u4:=0;
      i2Sum:=0;
      i2Divisor:=0;
      repeat
        //riteln('Inner Loop Top');
        if ux<arData[u4]^.u4ChunkSize then
        begin
          i2Divisor+=1;
          i2Src:=arData[u4]^.lpData+ux;
          i2Sum+=i2Src^;
        end;
        u4+=1;
        //riteln('Inner Loop Bottom');
        //riteln('ux: ',ux,' u4: ',u4,' MaxLength: ',u4MaxLength,' Sum: ',i2Sum,' Divisor: ',i2Divisor, ' Data: ',i2Src^);
      until u4>=length(arData);
      //riteln('Merge Outer Loop Bottom');
      i2Total:=rTargetData^.lpData+ux;
      i2Total^:=i2Sum div i2Divisor;
      //riteln('ux: ',ux,' MaxLength: ',u4MaxLength,' Sum: ',i2Sum,' Divisor: ',i2Divisor, ' Src: ',i2Src^, ' Total: ',i2Total^);
      ux+=2;
    until ux>=(u4MaxLength);
  end;
  result:=bOk;
end;
//=============================================================================

//=============================================================================
{}
// Save the Merged wave file to disk
function TWAVEMERGE.bSaveMergedWave(p_saFilename: ansistring; var p_u8result: UInt64; var p_saResult: Ansistring): boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=MergedWave.Save(p_saFilename,p_u8Result, p_saResult);
  result:=bOk;
end;
//=============================================================================




//=============================================================================
//=============================================================================
//=============================================================================
//=====================  TWAVEMERGE  END   ====================================
//=============================================================================
//=============================================================================
//=============================================================================








//=============================================================================
End.
//=============================================================================


//****************************************************************************
// EOF
//****************************************************************************
