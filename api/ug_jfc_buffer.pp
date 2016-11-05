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
// JFC_BUFFER Design                     Buffer Class for Dynamic Buffers
Unit ug_jfc_buffer;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_buffer.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
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
ug_common,
ug_jfc_dl;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_BUFFER
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
// JFC_BUFFER Design                     Buffer Class for Dynamic Buffers
//
// Plus there are a couple routines to treat the buffer correctly with 
// ansistrings and it does it very fast.
//=============================================================================

//type TCHARARRAY = array [1..maxint] of char;
//=============================================================================
{}
Type JFC_BUFFER = Class(JFC_DLITEM)
//=============================================================================
  Private
    pvt_uSize: UINT;
    pvt_uSizePerItem: UINT;
    pvt_lpBuffer: pointer;

  private
    Procedure write_uSize(p_u: UINT);

  Public
    //-----------------------------------------------
    {}
    // Used for "How Much In Buffer" scratch variable
    // for your programs/units and used by "saIn" method of this class.
    // Modified by "SAIN(ansistring)" automatically
    // and USED as a GUIDE for "saOut: ansistring"
    // You can use as a scratch variable also.
    uItems: uint;
    //-----------------------------------------------
    {}
    // Returns ansistring of contents in buffer, iBytesInBuffer long
    // Internally MOVE is used so it should be fast.
    Function saOut: AnsiString;
    //-----------------------------------------------
    {}
    // Copies an ansistring into buffer
    // This uses MOVE and DELETE so it should be fast.
    // The AnsiString PARAMETER you send WILL be modified! IF the 
    // whole String fits in the buffer - then it will
    // come back empty. If only part fits in the buffer - 
    // then the part that fits will be deleted and the shortened 
    // (not fitting) portion will be what you have left. 
    // Use iBytesInBuffer to get the number of bytes 
    // actually copied to the buffer and subsequently 
    // "Delete"'d from your passed parameter.
    // Forced to make my own DELETE called DELETESTRING
    // cuz FPC version crashed with 2 meg ansistring when trying
    // to "DELETE" LEft 1 meg of it. DELETESTRING is in u03g_strings.pp
    // Uses FPC sysutils LEftStr and RightStr - Should be fairly 
    // fast still and does try to prevent errors.
    Procedure SaIn(Var p_sa: AnsiString);
    {}
    // Does what it looks like. Its here for convenience. Setting the Size
    // of the buffer (uSize) to zero does the same thing.
    procedure DeleteAll;
    //-----------------------------------------------
    {}
    // This function adds the char to the buffer as an alternative
    // to sending in a string. This should process faster
    // than using the saIn procedure to process individual characters/bytes.
    // the function returns false if the char can not fit in the buffer.
    Function chIn(p_ch: char): boolean;
    //-----------------------------------------------
    {}
    // Resize BUFFER - Contents Preserved but "NEW" empty space
    // is not ZERO filled or anything.
    Property uSize: UINT read pvt_usize Write write_usize;
    Property lpBuffer: pointer read pvt_lpBuffer;
    Property uSizePerItem: UINT read pvt_uSizePerItem;


    Constructor create(p_uSize: UINT; p_uSizePerItem: UINT);
    Destructor destroy; override;
End;
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
//


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_BUFFER Routines                   Buffer Class for Dynamic Buffers
//
// Plus there are a couple routines to treat the buffer correctly with 
// ansistrings and it does it very fast.
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
Constructor JFC_BUFFER.create(p_uSize: UINT; p_uSizePerItem: UINT);
//=============================================================================
Begin
  Inherited create;
  pvt_uSize:=p_uSize;
  pvt_uSizePerItem:=p_uSizePerItem;
  if pvt_uSizePerItem<1 then pvt_uSizePerItem:=1;
  If pvt_uSize>0 Then getmem(pvt_lpBuffer, pvt_uSize*pvt_uSizePerItem) Else pvt_lpBuffer:=nil;
End;
//=============================================================================

//=============================================================================
Destructor JFC_BUFFER.destroy;
//=============================================================================
Begin
  If (pvt_lpBuffer<>nil) Then freemem(pvt_lpBuffer);
End;
//=============================================================================

//=============================================================================
Procedure JFC_BUFFER.write_usize(p_u: uint);
//=============================================================================
Var p: pointer;
Begin
  If (p_u*pvt_uSizePerItem)>(pvt_uSize*pvt_uSizePerItem) Then
  Begin
    If pvt_lpBuffer<>nil Then
    Begin
      getmem(p, p_u*pvt_uSizePerItem);
      move(pointer(pvt_lpBuffer)^, p^, pvt_uSize*pvt_uSizePerItem);
      freemem(pvt_lpBuffer);
      pvt_lpBuffer:=p;
    End
    Else
    Begin
      // presumably pvt_iSize=0 IF here
      GetMem(pvt_lpBuffer, p_u*pvt_uSizePerItem);
    End;  
  End
  Else If (p_u*pvt_uSizePerItem)<(pvt_uSize*pvt_uSizePerItem) Then
  Begin
    If p_u>0 Then
    Begin
      // In theory - When going smaller you dont' have to do anything even
      // if want ZERO. 
      //getmem(p, p_u*pvt_uSizePerItem);
      //move(pointer(pvt_lpBuffer)^, p^, p_i);  
      //freemem(pvt_lpBuffer);
      //pvt_lpBuffer:=p;
    End
    Else
    Begin
      // If going ZERO - To keep it easier to maintain - kiss goodbye
      // Though shrinking to ZERO is Stupid. Got to CODE Thoroughly.
      FreeMem(pvt_lpBuffer);
      pvt_lpBuffer:=nil;
    End;
  End;
  pvt_uSize:=p_u;
End;
//=============================================================================

//=============================================================================
Function JFC_BUFFER.saOut: AnsiString;
//=============================================================================
Begin
  Result:='';
  If uItems>0 Then
  Begin
    //Writeln('sabuffer.Setting len');
    SetLength(Result,uItems*pvt_uSizePerItem);
    //for i:=1 to giBytesInShareBuf do result[i]:=gachShareBuf[i];
    //Writeln('sabuffer.Doing MOve:',uItems);
    move(pvt_lpBuffer^, pointer(Result)^, uItems*pvt_uSizePerItem);
    //Writeln('sabuffer.Done');
  End;
End;  
//=============================================================================

//=============================================================================
Procedure JFC_BUFFER.SaIn(Var p_sa: AnsiString);
Var 
  uStop: uInt;
  ulength: uInt;
Begin
  ulength:=length(p_sa);
  If ulength>pvt_uSize Then uStop:=pvt_uSize*pvt_uSizePerItem Else uStop:=uLength;
  If uLength>0 Then
  Begin
    //for i:=1 to iStop do gachShareBuf[i]:=p_sa[i];
    //Writeln('Buffer..move istop:',istop,' iMaxSize:',pvt_iMaxBufferSize);
    move(pointer(p_sa)^, pvt_lpBuffer^, uStop);
    //Write('Buffer..delete(p_sa,1,',istop,') Len psa In:',length(p_sa));
    DeleteString(p_sa, 1, uStop);
    //Writeln(' len psa out:',length(p_sa));
    uItems:=ustop;
  End
  Else
  Begin
    uItems:=0;
  End;
End;
//=============================================================================

//=============================================================================
function JFC_BUFFER.chIn(p_ch: char):boolean;
//=============================================================================
Var sa: ^ansistring;
Begin
  result:=uItems<(pvt_uSize*pvt_uSizePerItem);
  if result then
  begin
    uItems+=pvt_uSizePerItem;
    sa:=pvt_lpBuffer;
    sa[uItems*pvt_uSizePerItem]:=p_ch;//should be one, but I don't want to
    // stifle it from something clever being done with it as is...
    // like Unicode which is 2 bytes per character
  end;
end;
//=============================================================================

//=============================================================================
procedure JFC_BUFFER.DeleteAll; inline;
//=============================================================================
begin
  uSize:=0;
end;
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
