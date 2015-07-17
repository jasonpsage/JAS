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
    pvt_iSize: Integer;
    pvt_lpBuffer: pointer;
    private
    Procedure write_iSize(p_i: Integer);

  Public
    //-----------------------------------------------
    {}
    // Used for "How Much In Buffer" scratch variable
    // for your programs/units and used by "sain" method of this class.
    // Modified by "SAIN(ansistring)" automatically
    // and USED as a GUIDE for "saOut: ansistring"
    // You can use as a scratch variable also.
    iBytesInBuffer: Integer;
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
    //-----------------------------------------------
    {}
    // Resize BUFFER - Contents Preserved but "NEW" empty space
    // is not ZERO filled or anything.
    Property iSize: Integer read pvt_isize Write write_isize;
    Property lpBuffer: pointer read pvt_lpBuffer;

    Constructor create(p_iSize: Integer);
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
Constructor JFC_BUFFER.create(p_iSize: Integer);
//=============================================================================
Begin
  Inherited create;
  If p_iSize>0 Then getmem(pvt_lpBuffer, p_iSize) Else pvt_lpBuffer:=nil;
  pvt_iSize:=p_iSize;
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
Procedure JFC_BUFFER.write_isize(p_i: Integer);
//=============================================================================
Var p: pointer;
Begin
  If p_i>pvt_iSize Then
  Begin
    If pvt_lpBuffer<>nil Then
    Begin
      getmem(p, p_i);
      move(pointer(pvt_lpBuffer)^, p^, pvt_iSize);  
      freemem(pvt_lpBuffer);
      pvt_lpBuffer:=p;
    End
    Else
    Begin
      // presumably pvt_iSize=0 IF here
      GetMem(pvt_lpBuffer, p_i);
    End;  
  End
  Else If p_i<pvt_iSize Then
  Begin
    If p_i>0 Then
    Begin
      // In theory - When going smaller you dont' have to do anything even
      // if want ZERO. 
      //getmem(p, p_i);
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
  pvt_iSize:=p_i;
End;
//=============================================================================

//=============================================================================
Function JFC_BUFFER.saOut: AnsiString;
//=============================================================================
Begin
  Result:='';
  If iBytesInBuffer>0 Then   
  Begin
    //Writeln('sabuffer.Setting len');
    SetLength(Result,ibytesinbuffer);
    //for i:=1 to giBytesInShareBuf do result[i]:=gachShareBuf[i];
    //Writeln('sabuffer.Doing MOve:',iBytesInBuffer);
    move(pvt_lpBuffer^, pointer(Result)^, iBytesInBuffer);
    //Writeln('sabuffer.Done');
  End;
End;  
//=============================================================================

//=============================================================================
Procedure JFC_BUFFER.SaIn(Var p_sa: AnsiString);
Var 
  iStop: Integer;
  ilength: Integer;
Begin
  ilength:=length(p_sa);
  If ilength>pvt_iSize Then iStop:=pvt_iSize Else iStop:=iLength;
  If iLength>0 Then
  Begin
    //for i:=1 to iStop do gachShareBuf[i]:=p_sa[i];
    //Writeln('Buffer..move istop:',istop,' iMaxSize:',pvt_iMaxBufferSize);
    move(pointer(p_sa)^, pvt_lpBuffer^, iStop);
    //Write('Buffer..delete(p_sa,1,',istop,') Len psa In:',length(p_sa));
    DeleteString(p_sa, 1, iStop);  
    //Writeln(' len psa out:',length(p_sa));
    iBytesInBuffer:=istop;
  End
  Else
  Begin
    iBytesInBuffer:=0;
  End;
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
