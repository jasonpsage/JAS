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
// Graphics Related - Bitmap manipulation
//
// There are functions documented, but here is the documentation for BITMAP
// graphic file formats:
//
//
// DOCUMENTATION FOR BITMAP FORMAT *.bmp
//
// Introduction:
// The .bmp file format (sometimes also saved as .dib) is the standard for a
// Windows 3.0 or later DIB(device independent bitmap) file. It may use
// compression (though I never came across a compressed .bmp-file) and is
// (by itself) not capable of storing animation. However, you can animate a
// bitmap using different methods but you have to write the code which
// performs the animation. There are different ways to compress a .bmp-file,
// but I won't explain them here because they are so rarely used. The image
// data itself can either contain pointers to entries in a color table or
// literal RGB values (this is explained later).
//
// Basic structure:
//   A .bmp file contains of the following data structures:
//
// BITMAPFILEHEADER    bmfh;
// BITMAPINFOHEADER    bmih;
// RGBQUAD             aColors[];
// BYTE                aBitmapBits[];
//
// bmfh contains some information about the bitmap file (about the file, not
// about the bitmap itself). bmih contains information about the bitmap such
// as size, colors,... The aColors array contains a color table. The rest is
// the image data, which format is specified by the bmih structure.
//
// Exact structure:
// The following tables give exact information about the data structures and
// also contain the settings for a bitmap with the following dimensions:
// size 100x100, 256 colors, no compression. The start-value is the position
// of the byte in the file at which the explained data element of the
// structure starts, the size-value contains the nuber of bytes used by this
// data element, the name-value is the name assigned to this data element by
// the Microsoft API documentation. Stdvalue stands for standard value. There
// actually is no such a thing as a standard value but this is the value Paint
// assigns to the data element if using the bitmap dimensions specified above
// (100x100x256). The meaning-column gives a short explanation of the purpose
// of this data element.
//
//-----------------------
// The BITMAPFILEHEADER:
//-----------------------
// start 	size 	name 	       stdvalue 	purpose
// 1         2  bfType          19778   must always be set to 'BM' to declare that this is a .bmp-file.
// 3         4  bfSize             ??   specifies the size of the file in bytes
// 7 	       2  bfReserved1         0 	must always be set to zero.
// 9         2  bfReserved2         0   must always be set to zero.
// 11        4 	bfOffBits 	     1078 	specifies the offset from the beginning of the file to the bitmap data.
//-----------------------
//
//-----------------------
// The BITMAPINFOHEADER:
//-----------------------
// start 	size 	name 	       stdvalue 	purpose
// 15 	     4  biSize 	           40 	specifies the size of the BITMAPINFOHEADER structure, in bytes.
// 19 	     4  biWidth           100 	specifies the width of the image, in pixels.
// 23 	     4  biHeight 	        100   specifies the height of the image, in pixels.
// 27 	     2  biPlanes            1   specifies the number of planes of the target device, must be set to zero.
// 29 	     2  biBitCount          8   specifies the number of bits per pixel.
// 31 	     4  biCompression       0   Specifies the type of compression, usually set to zero (no compression).
// 35 	     4  biSizeImage         0   Specifies the size of the image data, in bytes. If there is no compression, it is valid to set this member to zero.
// 39 	     4  biXPelsPerMeter     0 	specifies the the horizontal pixels per meter on the designated targer device, usually set to zero.
// 43 	     4  biYPelsPerMeter 	  0 	specifies the the vertical pixels per meter on the designated targer device, usually set to zero.
// 47 	     4  biClrUsed 	        0   specifies the number of colors used in the bitmap, if set to zero the number of colors is calculated using the biBitCount member.
// 51 	     4  biClrImportant      0   specifies the number of color that are 'important' for the bitmap, if set to zero, all colors are important.
//-----------------------
//
//
// Note that biBitCount actually specifies the color resolution of the bitmap.
// The possible values are: 1 (black/white); 4 (16 colors); 8 (256 colors);
// 24 (16.7 million colors). The biBitCount data element also decides if there
// is a color table in the file and how it looks like. In 1-bit mode the color
// table has to contain 2 entries (usually white and black). If a bit in the
// image data is clear, it points to the first palette entry. If the bit is
// set, it points to the second. In 4-bit mode the color table must contain 16
// colors. Every byte in the image data represents two pixels. The byte is
// split into the higher 4 bits and the lower 4 bits and each value of them
// points to a palette entry. There are also standard colors for 16 colors
// mode (16 out of Windows 20 reserved colors (without the entries 8, 9, 246,
// 247)). Note that you do not need to use this standard colors if the bitmap
// is to be displayed on a screen which support 256 colors or more, however
// (nearly) every 4-bit image uses this standard colors. In 8-bit mode every
// byte represents a pixel. The value points to an entry in the color table
// which contains 256 entries (for details see Palettes in Windows. In 24-bit
// mode three bytes represent one pixel. The first byte represents the red
// part, the second the green and the third the blue part. There is no need
// for a palette because every pixel contains a literal RGB-value, so the
// palette is omitted.
//
//-----------------------
//The RGBQUAD array:
//-----------------------
// The following table shows a single RGBQUAD structure:
// start 	size 	name 	stdvalue 	purpose
// 1 	1 	rgbBlue 	- 	specifies the blue part of the color.
// 2 	1 	rgbGreen 	- 	specifies the green part of the color.
// 3 	1 	rgbRed 	- 	specifies the red part of the color.
// 4 	1 	rgbReserved 	- 	must always be set to zero.
//-----------------------
//
// Note that the term palette does not refer to a RGBQUAD array, which is
// called color table instead. Also note that, in a color table (RGBQUAD), the
// specification for a color starts with the blue byte. In a palette a color
// always starts with the red byte. There is no simple way to map the whole
// color table into a LOGPALETTE structure, which you will need to display the
// bitmap. You will have to write a function that copies byte after byte.
//
// The pixel data:
// It depens on the BITMAPINFOHEADER structure how the pixel data is to be
// interpreted (see above). It is important to know that the rows of a DIB are
// stored upside down. That means that the uppest row which appears on the
// screen actually is the lowest row stored in the bitmap.
Unit ug_pixelgrid;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_pixelgrid.pp'}
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
{ }
uses
  sysutils
 ,ug_common
 ,ug_jegas
 ,ug_xyz
 ,ug_rgba;
//=============================================================================


//============================================================================
{ }
// Note: The Memory Block Format is the same as a IMAGE that is 4Bytes Per
//       Pixel. First 12 bytes store the image header(3xDWord)
//       Width, Height, Depth.
type TPIXELGRID = class
//============================================================================
  { }
  public
    pvt_BytesPerPixel: longint;
    pvt_Width: longint;
    pvt_Height: longint;
    pvt_Depth: longint;

    constructor Create;
    destructor Destroy; override;

  public
    //-----
    // Useful type for typecasting 4 consecutive bytes
    //Type TR4ByteCast = Packed Record
    //  u1: array[1..4] Of Byte;
    //End;
    MB: array of byte;
    function  Word_Get(p_iIndex: longint):word;
    procedure Word_Set(p_iIndex: longint; p_u2: word);
    function  DWord_Get(p_iIndex: longint):cardinal;
    procedure DWord_Set(p_iIndex: longint; p_u4: cardinal);
    function  Long_Get(p_iIndex: longint):longint;
    procedure Long_Set(p_iIndex: longint; p_i4: longint);
    //-----
  public
    saFilenameSrc: Ansistring;
    saFilenameDest: ansistring;
    saFilenameSrcBMP: ansistring;
    saFilenameDestBMP: ansistring;


    function MemPos(p_X:longint; p_Y:longint): cardinal;//< For Working with Images OWNED by this Class

    function Size_Set(p_Width:longint; p_Height:longint): boolean;
    function Width_Get:longint;
    function Height_Get:longint;
    function Depth_Get:longint;
    function BytesPerPixel:longint;
    procedure Red_Set(p_X:longint; p_Y:longint; p_Value:byte);
    procedure Green_Set(p_X:longint; p_Y:longint; p_Value:byte);
    procedure Blue_Set(p_X:longint;p_Y:longint;p_Value:byte);
    procedure Alpha_Set(p_X:longint;p_Y:longint;p_Value:byte);

    procedure RGB_Set(p_X:longint; p_Y:longint; p_R: byte; p_G: byte; p_B: byte);
    procedure RGB_Set(p_X:longint; p_Y:longint; p_Value: cardinal);
    procedure RGB_Set(p_X:longint; p_Y:longint; p_RGBA: TRGBA);
    procedure RGBA_Set(p_X:longint;p_Y:longint; p_R: byte; p_G: byte; p_B: byte; p_A: byte);
    procedure RGBA_Set(p_X:longint;p_Y:longint; p_Value: cardinal);
    procedure RGBA_Set(p_X:longint;p_Y:longint; p_RGBA: TRGBA);

    function Red_Get(p_X: longint; p_Y: longint): byte;
    function Green_Get(p_X: longint; p_Y: longint): byte;
    function Blue_Get(p_X: longint; p_Y: longint): byte;
    function Alpha_Get(p_X: longint; p_Y: longint): byte;
    function RGB_Get(p_X: longint; p_Y: longint):cardinal;
    function RGBA_Get(p_X: longint; p_Y: longint):cardinal;


    function u2SaveAsText(p_saFilenameDest: ansistring): word;
    function u2LoadBitmap24(p_saFilenameSrc_24BitBitmap: ansistring):word;
    function u2SaveBitmap24(p_saFilenameDest_24BitBitmap:ansistring; p_lpfnPBarUpdate: pointer; p_lpfnFormInstance: pointer):word;


    Procedure AdjustR(p_X: longint; p_Y: longint; p_Value: longint);//< Use to lighten/lessen values with positive or negative values.
    Procedure AdjustG(p_X: longint; p_Y: longint; p_Value: longint);//< Use to lighten/lessen values with positive or negative values.
    Procedure AdjustB(p_X: longint; p_Y: longint; p_Value: longint);//< Use to lighten/lessen values with positive or negative values.
    Procedure AdjustA(p_X: longint; p_Y: longint; p_Value: longint);//< Use to lighten/lessen values with positive or negative values.
    Procedure AdjustRGB(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint);//< Use to lighten/lessen values with positive or negative values.
    Procedure AdjustRGBA(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint; p_A: longint);//< Use to lighten/lessen values with positive or negative values.

    //------------------------------------------------------------------------
    // Getting Fancy---- these are for Terrain Generation and perhaps other effects
    // ..that is - just a place to store info that can be used for whatever.
    //... Like settings for a texture before you pass it through a blender or
    // something.
    //------------------------------------------------------------------------
  { }
  public
    VScale: single; // 1=As Is. Less or double - you're call.
    VStrength: single; // 1=Full Strength  0.5 = 50% Blend
    VPosMin: TXYZFLOAT;
    VPosMax: TXYZFLOAT;
    VAngMin: TXYZFLOAT;
    VAngMax: TXYZFLOAT;
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // Fills
    //------------------------------------------------------------------------
  { }
    Procedure FillR(p_R: byte);
    Procedure FillG(p_G: byte);
    Procedure FillB(p_B: byte);
    Procedure FillA(p_A: byte);
    Procedure FillRGB(p_R: byte;p_G: byte;p_B: byte);
    Procedure FillRGBA(p_R: byte;p_G: byte; p_B:byte; p_A: byte);
    Procedure FillRGBA(p_RGBA: cardinal);
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // Lines
    //------------------------------------------------------------------------
  { }
    Procedure Line(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_RGBA: cardinal
    );
    Procedure LineR(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Red: byte
    );
    Procedure LineG(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Green: byte
    );
    Procedure LineB(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Blue: byte
    );
    Procedure LineA(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Alpha: byte
    );
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // Boxes
    //------------------------------------------------------------------------
  { }
    Procedure Box(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_RGBA: cardinal
    );
  { }
    Procedure Box(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_RGBA: cardinal;
      p_RGBA_Fill: cardinal
    );
  { }
    Procedure BoxR(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Red: byte
    );
  { }
    Procedure BoxR(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Red: byte;
      p_Red_Fill: byte
    );
  { }
    Procedure BoxG(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Green: byte
    );
  { }
    Procedure BoxG(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Green: byte;
      p_Green_Fill: byte
    );
  { }
    Procedure BoxB(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Blue: byte
    );
  { }
    Procedure BoxB(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Blue: byte;
      p_Blue_Fill: byte
    );
  { }
    Procedure BoxA(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Alpha: byte
    );
  { }
    Procedure BoxA(
      p_x1: longint;
      p_y1: longint;
      p_x2: longint;
      p_y2: longint;
      p_Alpha: byte;
      p_Alpha_Fill: byte
    );
    //------------------------------------------------------------------------

end;
//============================================================================




//============================================================================
//============================================================================
//============================================================================
                               Implementation
//============================================================================
//============================================================================
//============================================================================





//============================================================================
// Begin                          TPIXELGRID
//============================================================================

//----------------------------------------------------------------------------
constructor TPIXELGRID.create;
//----------------------------------------------------------------------------
begin
  //this->pvt_RGBA=new JFC_RGBA();
  //this->MB=new JGC_MEMBLOCK();
  pvt_BytesPerPixel:=4;
  pvt_Depth:=32;
  saFilenameSrc:='';
  saFilenameDest:='';
  saFilenameSrcBMP:='';
  saFilenameDestBMP:='';
  pvt_Width:=0;
  pvt_Height:=0;
  VPosMin:=TXYZFLOAT.Create(0,0,0);
  VPosMax:=TXYZFLOAT.Create(0,0,0);
  VAngMin:=TXYZFLOAT.Create(0,0,0);
  VAngMax:=TXYZFLOAT.Create(0,0,0);
  VScale:=0;
  VStrength:=0;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
destructor TPIXELGRID.Destroy();
//----------------------------------------------------------------------------
begin
  //delete this->pvt_RGBA;
  //SAFE_DELETE(this->MB);
  saFilenameSrc:='';
  saFilenameDest:='';
  saFilenameSrcBMP:='';
  saFilenameDestBMP:='';
  VPosMin.Destroy;
  VPosMax.Destroy;
  VAngMin.Destroy;
  VAngMax.Destroy;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.MemPos(p_X: longint;p_Y: longint): cardinal;
//----------------------------------------------------------------------------
begin
  // 12 is the header size - BPP or Bytes Per Pixel Defaults to 4.
  result:=((p_X+(p_Y*pvt_Width)) * pvt_BytesPerPixel)+12;
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
function TPIXELGRID.Word_Get(p_iIndex: longint):word;
//----------------------------------------------------------------------------
var wc: rt2ByteCast;//Packed Record u1: array[0..1] Of Byte;
begin
  wc.u1[0]:=mb[p_iIndex];
  wc.u1[1]:=mb[p_iIndex+1];
  result:=word(wc);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Word_Set(p_iIndex: longint; p_u2: word);
//----------------------------------------------------------------------------
var wc: rt2ByteCast;//Packed Record u1: array[0..1] Of Byte;
begin
  wc:=rt2ByteCast(p_u2);
  mb[p_iIndex]:=wc.u1[0];
  mb[p_iIndex+1]:=wc.u1[1];
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
function TPIXELGRID.DWord_Get(p_iIndex: longint):cardinal;
//----------------------------------------------------------------------------
var  bc: rt4ByteCast;//Packed Record u1: array[1..4] Of Byte;
begin
  bc.u1[0]:=mb[p_iIndex];
  bc.u1[1]:=mb[p_iIndex+1];
  bc.u1[2]:=mb[p_iIndex+2];
  bc.u1[3]:=mb[p_iIndex+3];
  result:=cardinal(bc);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.DWord_Set(p_iIndex: longint; p_u4: cardinal);
//----------------------------------------------------------------------------
var  bc: rt4ByteCast;//Packed Record u1: array[1..4] Of Byte;
begin
  bc:=rt4ByteCast(p_u4);
  mb[p_iIndex]:=bc.u1[0];
  mb[p_iIndex+1]:=bc.u1[1];
  mb[p_iIndex+2]:=bc.u1[2];
  mb[p_iIndex+3]:=bc.u1[3];
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Long_Get(p_iIndex: longint):longint;
//----------------------------------------------------------------------------
var  bc: rt4ByteCast;//Packed Record u1: array[1..4] Of Byte;
begin
  bc.u1[0]:=mb[p_iIndex]  ;
  bc.u1[1]:=mb[p_iIndex+1];
  bc.u1[2]:=mb[p_iIndex+2];
  bc.u1[3]:=mb[p_iIndex+3];
  result:=longint(bc);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Long_Set(p_iIndex: longint; p_i4: longint);
//----------------------------------------------------------------------------
var  bc: rt4ByteCast;//Packed Record u1: array[1..4] Of Byte;
begin
  bc:=rt4ByteCast(p_i4);
  mb[p_iIndex]:=bc.u1[0];
  mb[p_iIndex+1]:=bc.u1[1];
  mb[p_iIndex+2]:=bc.u1[2];
  mb[p_iIndex+3]:=bc.u1[3];
end;
//----------------------------------------------------------------------------



//----------------------------------------------------------------------------
function TPIXELGRID.Size_Set(p_Width: longint; p_Height: longint):boolean;
//----------------------------------------------------------------------------
var
  bOk: boolean;
  iSize: longint;
begin
  bOk:=(p_Width>0) and (p_Height>0);
  if(bOk)then
  begin
    iSize:=(p_Width*p_Height*pvt_BytesPerPixel)+12;
    setlength(MB,iSize);
    pvt_Width:=p_Width;
    pvt_Height:=p_Height;
    Long_Set(0,pvt_Width);
    Long_Set(4,pvt_Height);
    Long_Set(8,pvt_BytesPerPixel*8);
    FillRGBA(0,0,0,255);
  end;
  Result:=bOk;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Width_Get: longint;
//----------------------------------------------------------------------------
begin
  result:=pvt_Width;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Height_Get: longint;
//----------------------------------------------------------------------------
begin
  result:=pvt_Height;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Depth_Get: longint;
//----------------------------------------------------------------------------
begin
  result:=pvt_Depth;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.BytesPerPixel:longint;
//----------------------------------------------------------------------------
begin
  result:=pvt_BytesPerPixel;
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
procedure TPIXELGRID.Red_Set(p_X: longint; p_Y: longint; p_Value: byte);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width)and(p_Y<pvt_Height)and(p_X>=0)and(p_Y>=0)then
  begin
    MB[MemPos(p_X,p_Y)+2]:=p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Green_Set(p_X: longint; p_Y: longint; p_Value: byte);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    MB[MemPos(p_X,p_Y)+1]:=p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Blue_Set(p_X: longint; p_Y: longint; p_Value: byte);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width)and(p_Y<pvt_Height)and(p_X>=0)and(p_Y>=0)then
  begin
    MB[MemPos(p_X,p_Y)]:=p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Alpha_Set(p_X: longint; p_Y: longint; p_Value: byte);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    MB[MemPos(p_X,p_Y)+3]:=p_Value;
  end;
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
procedure TPIXELGRID.RGB_Set(p_X: longint; p_Y: longint; p_Value: cardinal);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X,p_Y);
    MB[mp+0]:=(p_Value and $000f);
    MB[mp+1]:=(p_Value and $00f0);
    MB[mp+2]:=(p_Value and $0f00);
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.RGB_Set(p_X: longint; p_Y: longint; p_R:byte; p_G:byte; p_B:byte);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X,p_Y);
    MB[mp+0]:=p_B;
    MB[mp+1]:=p_G;
    MB[mp+2]:=p_R;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.RGB_Set(p_X: longint; p_Y: longint; p_RGBA: TRGBA);
//----------------------------------------------------------------------------
begin
  RGB_Set(p_X, p_Y, p_RGBA.RGB_Get());
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
procedure TPIXELGRID.RGBA_Set(p_X: longint; p_Y: longint; p_R: byte; p_G: byte; p_B: byte; p_A: byte);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X,p_Y);
    MB[mp+0]:=p_B;
    MB[mp+1]:=p_G;
    MB[mp+2]:=p_R;
    MB[mp+3]:=p_A;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.RGBA_Set(p_X: longint; p_Y: longint; p_Value: cardinal);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    Dword_Set(MemPos(p_X,p_Y),p_Value);
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.RGBA_Set(p_X: longint; p_Y:longint; p_RGBA: TRGBA);
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0) then
  begin
    Dword_Set(MemPos(p_X,p_Y),p_RGBA.RGBA_Get());
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Red_Get(p_X: longint; p_Y: longint): byte;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0) then
  begin
    result:= MB[MemPos(p_X,p_Y)+2];
  end
  else
  begin
    result:=0;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Green_Get(p_X: longint; p_Y: longint):byte;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0) then
  begin
    result:= MB[MemPos(p_X,p_Y)+1];
  end
  else
  begin
    result:=0;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Blue_Get(p_X: longint; p_Y: longint): byte;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    result:= MB[MemPos(p_X,p_Y)];
  end
  else
  begin
    result:= 0;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.Alpha_Get(p_X: longint; p_Y: longint): byte;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    result:= MB[MemPos(p_X,p_Y)+3];
  end
  else
  begin
    result:=0;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.RGB_Get(p_X: longint; p_Y: longint): cardinal;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0) then
  begin
    result:= Dword_Get(MemPos(p_X,p_Y)) and $00FFFFFF;
  end
  else
  begin
    result:=0;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
function TPIXELGRID.RGBA_Get(p_X:longint;p_Y: longint): cardinal;
//----------------------------------------------------------------------------
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    result:= Dword_Get(MemPos(p_X,p_Y));
  end
  else
  begin
    result:=0;
  end;
end;
//----------------------------------------------------------------------------



//----------------------------------------------------------------------------
function TPIXELGRID.u2SaveAsText(p_saFilenameDest: ansistring):word;
//----------------------------------------------------------------------------
var
  f: text;
  bOk: boolean;
  x: longint; y: longint;
  fEvenWidth1: single;
  EvenWidth2: longint;
  PadSize: longint;
  u2IOResult: word;
begin
  fEvenWidth1:=(single(pvt_Width)*3)/4;
  EvenWidth2:=(pvt_Width*3) div 4;
  PadSize:=0;
  if(fEvenWidth1<>EvenWidth2)then
  begin
    fEvenWidth1:=fEvenWidth1-EvenWidth2;
    PadSize:=longint(4-(fEvenWidth1*4));
  end;

  bOk:=true;u2IOresult:=0;
  assign(f, p_saFilenameDest);
  try rewrite(f);except on E:Exception do u2IOResult:=60000;end;//try
  u2IOresult+=IOResult;
  {$I+}
  bOk:=u2IOResult=0;
  if bOk then
  begin
    try
      writeln(f,';==============================================================================');
      writeln(f,';|    _________ _______  _______  ______  _______    Jegas, LLC               |');
      writeln(f,';|   /___  ___// _____/ / _____/ / __  / / _____/    JasonPSage@jegas.com     |');
      writeln(f,';|      / /   / /__    / / ___  / /_/ / / /____                               |');
      writeln(f,';|     / /   / ____/  / / /  / / __  / /____  /                               |');
      writeln(f,';|____/ /   / /___   / /__/ / / / / / _____/ /                                |');
      writeln(f,';/_____/   /______/ /______/ /_/ /_/ /______/                                 |');
      writeln(f,';|                 Under the Hood                                             |');
      writeln(f,';==============================================================================');
      writeln(f,';                     Copyright(c)2016 Jegas, LLC                              ');
      writeln(f,';==============================================================================');
      writeln(f,';FILENAME:   '+p_saFilenameDest);
      writeln(f,';==============================================================================');
      writeln(f,'; BytesPerPixel: '+inttostr(pvt_BytesPerPixel));
      writeln(f,'; Depth        : '+inttostr(pvt_Depth));
      writeln(f,'; Height       : '+inttostr(pvt_Height));
      writeln(f,'; Width        : '+inttostr(pvt_Width));
      writeln(f,';==============================================================================');
      writeln(f,'; EvenWidth1: ',fEvenWidth1,' EvenWidth2: ',EvenWidth2,' PadSize: ',PadSize);
      writeln(f,'; 26 + ((Width*3)+PadSize) * Height): ',26 + ((pvt_Width*3)+PadSize) * pvt_Height);
      writeln(f,';==============================================================================');
      
      //writeln(f,'VAngMaxX     : '+saSingle(VAngMax.X,10,10));
      //writeln(f,'VAngMaxY     : '+saSingle(VAngMax.Y,10,10));
      //writeln(f,'VAngMaxZ     : '+saSingle(VAngMax.Z,10,10));
      //writeln(f,'VAngMinX     : '+saSingle(VAngMin.X,10,10));
      //writeln(f,'VAngMinY     : '+saSingle(VAngMin.Y,10,10));
      //writeln(f,'VAngMinZ     : '+saSingle(VAngMin.Z,10,10));
      //writeln(f,'VPosMaxX     : '+saSingle(VPosMax.X,10,10));
      //writeln(f,'VPosMaxY     : '+saSingle(VPosMax.Y,10,10));
      //writeln(f,'VPosMaxZ     : '+saSingle(VPosMax.Z,10,10));
      //writeln(f,'VPosMinX     : '+saSingle(VPosMin.X,10,10));
      //writeln(f,'VPosMinY     : '+saSingle(VPosMin.Y,10,10));
      //writeln(f,'VPosMinZ     : '+saSingle(VPosMin.Z,10,10));
      //writeln(f,'VScale       : '+saSingle(VScale,10,10));
      //writeln(f,';==============================================================================');
      //writeln(f,';                     RGBA DATA TO FOLLOW                                      ');
      //writeln(f,';==============================================================================');
      //for y:=0 to pvt_Height-1 do begin
      //  for x:=0 to pvt_Width-1 do begin
      //    writeln(f,
      //      inttostr(Red_Get(x,y))+' '+
      //      inttostr(Green_Get(x,y))+' '+
      //      inttostr(Blue_Get(x,y))+' '+
      //      inttostr(Alpha_Get(x,y))
      //    );
      //  end;
      //end;
      writeln(f,';==============================================================================');
      writeln(f,';                     RGB  DWORD DATA TO FOLLOW  (No Alpha)                    ');
      writeln(f,';==============================================================================');
      for y:=0 to pvt_Height-1 do
      begin
        for x:=0 to pvt_Width-1 do begin
          write(f, inttostr(RGB_Get(x,y))+',');
        end;
        writeln(f);
      end;
      writeln(f,';==============================================================================');
      writeln(f,'; EOF                                                                          ');
      writeln(f,';==============================================================================');
    except on E:Exception do u2IOResult:=60000+ioresult;end;//try
  end;
  try close(f);except on E:Exception do;end;//try
  saFilenameDest:=p_saFilenameDest;
  result:= u2IOResult;
end;
//----------------------------------------------------------------------------




//----------------------------------------------------------------------------
function TPIXELGRID.u2LoadBitmap24(p_saFilenameSrc_24BitBitmap: ansistring):word;
//----------------------------------------------------------------------------
var
  bOk: boolean;
  BmpWidth: longint;
  BmpHeight: longint;
  BmpDepth: longint;
  ypos: longint;
  padsize: longint;
  padlp: longint;
  Ylp: longint;
  Xlp: longint;
  blue: byte;
  green: byte;
  red: byte;
  junk: byte;
  f: file of byte;
  u2IOResult: word;
  u4c: rt4ByteCast;
  u2c: rt2ByteCast;
  i4HeaderInfoPixOffset: longint;
  i4HeaderInfoSize: longint;
  i4SizeOfFile: longint;
begin
  // shutup compiler
  i4HeaderInfoPixOffset:=0;i4HeaderInfoPixOffset:=i4HeaderInfoPixOffset;
  i4HeaderInfoSize:=0;i4HeaderInfoSize:=i4HeaderInfoSize;
  i4SizeOfFile:=0;i4SizeOfFile:=i4SizeOfFile;

  //bOk:=FileExists(p_saFilenameSrc_24BitBitmap);
  u2IOResult:=0;
  assign(f,p_saFilenameSrc_24BitBitmap);

  try reset(f);except on E:Exception do u2IOResult:=60000;end;//try
  u2IOResult+=IOResult;
  bOk:=u2IOResult=0;
  if not bOk then
  begin
    writeln('unable to write: ',p_saFilenameSrc_24BitBitmap);
  end;


  if(bOk)then
  begin
    try
      //========BEGIN OF BITMAP FILE HEADER
      //-----------------
      // Signature Field - Size: 2
      read(f,junk);
      read(f,junk);
      //-----------------
    
      //-----------------
      // Size of File - Size: 4
      read(f,u4c.u1[0]);read(f,u4c.u1[1]);read(f,u4c.u1[2]);read(f,u4c.u1[3]);
      i4SizeOfFile:=longint(u4c);
      //-----------------
    
      //-----------------
      // Reserved01 - Size: 2
      read(f,junk);read(f,junk);
      //-----------------
    
      //-----------------
      // Reserved02 - Size: 2
      read(f,junk);read(f,junk);
      //-----------------
    
      //-----------------
      // Header Info Size (Offset to Pixel Data) Size: 4
      // 26 (But reference material says std value here: 1078 [weird]
      read(f,u4c.u1[0]);read(f,u4c.u1[1]);read(f,u4c.u1[2]);read(f,u4c.u1[3]);
      i4HeaderInfoPixOffset:=longint(u4c);
      //-----------------
      //========END OF BITMAP FILE HEADER
    
    
      //========BEGIN OF BITMAP INFO HEADER
      //-----------------
      // Size of BITMAP INFO HEADER - Size: 4
      // 12 (Reference MAterial Says usually 40)
      read(f,u4c.u1[0]);read(f,u4c.u1[1]);read(f,u4c.u1[2]);read(f,u4c.u1[3]);
      i4HeaderInfoSize:=longint(u4c);
      //-----------------
    
      //-----------------
      // Width in Pixels - Size: 4
      read(f,u2c.u1[0]);read(f,u2c.u1[1]);
      BmpWidth:=word(u2c);
      //-----------------
    
      //-----------------
      // Height In Pixels - Size: 4
      read(f,u2c.u1[0]);read(f,u2c.u1[1]);
      BmpHeight:=word(u2c);
      //-----------------
    
      //-----------------
      // Planes of Target Device - Size: 2
      // 1 (Reference MAterial Says set to: 0 )zero
      read(f,junk);read(f,junk);
      //-----------------
    
      //-----------------
      // Specifies Bits Per Pixel - Size: 2
      //-----------------
      read(f,u2c.u1[0]);read(f,u2c.u1[1]);
      BmpDepth:=word(u2c);
      //-----------------
    
      bOk:=(BmpDepth=24);
      if(false=bOk)then
      begin
        writeln('BAD BitmapDepth:',BmpDepth);
      end;
    except on E:Exception do
    begin
      bOk:=false;
      writeln('Trouble inmain loop loading bitmap.');
      u2IOResult:=60000+ioresult;
    end;
    end;//try
  end;

  if(bOk)then
  begin
    ypos:=BmpHeight-1;
    PadSize:=4-((BmpWidth*3) mod 4);
    if padsize>=4 then padsize:=0;
    bOk := Size_Set(BmpWidth,BmpHeight);
    if not bOk then
    begin
      writeln('Size_Set failed');
    end;
  end;

  if(bOk)then
  begin
    try
      for Ylp:=0 to BmpHeight-1 do begin
        //dbSetCursor(300,10);dbPrint("Size:");
        //dbSetCursor(360,10);dbPrint(dbStr(BmpWidth));
        //dbSetCursor(420,10);dbPrint(dbStr(BmpHeight));
        //dbSetCursor(310,20);dbPrint("Row:");
        //dbSetCursor(360,20);dbPrint(dbStr(Ylp));
        //dbSync();
        for Xlp:=0 to BmpWidth-1 do begin
          read(f,green);
          read(f,blue);
          read(f,red);
          RGB_Set(Xlp,ypos,red,green,blue);
        end;
        ypos-=1;
        if(padsize<>0)then
        begin
          for padlp:=0 to padsize-1 do begin
            read(f,junk);//padbyte
          end;
        end;
      end;
      saFilenameSrcBMP:=p_saFilenameSrc_24BitBitmap;
    except on E:Exception do;end;//try
  end;
  try close(f);except on E:Exception do;end;//try
  result:=u2IOResult;
end;
//----------------------------------------------------------------------------




//----------------------------------------------------------------------------
function TPIXELGRID.u2SaveBitmap24(
  p_saFilenameDest_24BitBitmap:ansistring;
  p_lpfnPBarUpdate: pointer;
  p_lpfnFormInstance: pointer
):word;
//----------------------------------------------------------------------------
var
  bOk: boolean;
  x: longint; y: longint; mp: longint;
  PadSize: longint;
  f: file of byte;
  u2c: rt2ByteCast;
  u4c: rt4ByteCast;
  u2IOResult: word;
  lpfnPBarUpdate: procedure (p_i4Fill: longint; p_i4Value: longint; p_i4Max: longint; p_FormInstance: pointer);
  lpfnFormInstance: pointer;
  i4Rows: longint;
  i4CurrentRow: longint;
begin
  pointer(lpfnPBarUpdate):=p_lpfnPBarUpdate;
  lpfnFormInstance:=p_lpfnFormInstance;
  i4Rows:=pvt_Height;
  i4CurrentRow:=0;

  x:=0;
  y:=0;
  mp:=0;
  PadSize:=4-((pvt_Width*3) mod 4);
  if padsize>=4 then padsize:=0;
  assign(f,p_saFilenameDest_24BitBitmap);
  try rewrite(f);except on E:Exception do u2IOResult:=60000; end;//try
  u2IOResult+=IOResult;
  bOK:=u2IOResult=0;
  if(bOk)then
  begin
    try
      //========BEGIN OF BITMAP FILE HEADER
      //-----------------
      // Signature Field - Size: 2
      write(f,ord('B'));
      write(f,ord('M'));
      //-----------------
      
      //-----------------
      // Size of File - Size: 4
      u4c:=rt4ByteCast(longint(26 + ((pvt_Width*3)+PadSize) * pvt_Height));//bWriteWord(f,26 + ((pvt_Width*3)+PadSize) * pvt_Height);
      write(f,u4c.u1[0]);write(f,u4c.u1[1]);write(f,u4c.u1[2]);write(f,u4c.u1[3]);
      //-----------------
      
      //-----------------
      // Reserved01 - Size: 2
      write(f,0);write(f,0);
      //-----------------
      
      //-----------------
      // Reserved02 - Size: 2
      write(f,0);write(f,0);
      //-----------------
      
      //-----------------
      // Header Info Size (Offset to Pixel Data) Size: 4
      // 26 (But reference material says std value here: 1078 [weird]
      write(f,26);write(f,0);write(f,0);write(f,0);
      //-----------------
      //========END OF BITMAP FILE HEADER
      
      
      //========BEGIN OF BITMAP INFO HEADER
      //-----------------
      // Size of BITMAP INFO HEADER - Size: 4
      // 12 (Reference MAterial Says usually 40)
      write(f,12);write(f,0);write(f,0);write(f,0);
      //-----------------
      
      //-----------------
      // Width in Pixels - Size: 4
      u2c:=rt2ByteCast(word(pvt_Width));//bWriteWord(f,pvt_Width);
      write(f,u2c.u1[0]);write(f,u2c.u1[1]);
      //-----------------
      
      //-----------------
      // Height In Pixels - Size: 4
      u2c:=rt2ByteCast(word(pvt_Height));//bWriteWord(f,pvt_Height);
      write(f,u2c.u1[0]);write(f,u2c.u1[1]);
      //-----------------
      
      //-----------------
      // Planes of Target Device - Size: 2
      // 1 (Reference MAterial Says set to: 0 )zero
      write(f,1);write(f,0);
      //-----------------
      
      //-----------------
      // Specifies Bits Per Pixel - Size: 2
      //-----------------
      write(f,24);write(f,0);
      //-----------------
      for y:= pvt_Height-1 downto 0 do begin
        for x:=0 to pvt_Width-1 do begin
          mp:=MemPos(x,y);
          write(f,mb[mp+0]);//red
          write(f,mb[mp+1]);//green
          write(f,mb[mp+2]);//blue
        end;
        if(PadSize>0)then
        begin
          for x:=0 to PadSize-1 do begin
            write(f,0);
          end;
        end;
        //writeln('Row:',x,' of ', pvt_Height);
        if p_lpfnPBarUpdate<>nil then
        begin
          i4CurrentRow:=i4CurrentRow+1;
          lpfnPBarUpdate(0,i4CurrentRow, i4Rows, lpfnFormInstance);
        end;
      end;
      Close(f);
    except on E:Exception do;
    end;//try
    saFilenameDestBMP:=p_saFilenameDest_24BitBitmap;
  end;
  result:=u2IOResult;
end;
//----------------------------------------------------------------------------



//----------------------------------------------------------------------------
// Use to lighten/lessen values with positive or negative values.
procedure TPIXELGRID.AdjustR(p_X: longint; p_Y: longint; p_Value: longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0) then
  begin
    mp:=MemPos(p_X, p_Y);
    MB[mp+2]:=mb[mp+2]+p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.AdjustG(p_X: longint; p_Y: longint; p_Value: longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X, p_Y);
    mb[mp+1]:=mb[mp+1]+p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.AdjustB(p_X: longint; p_Y: longint; p_Value: longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X, p_Y);
    mb[mp+0]:=mb[mp+0]+p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.AdjustA(p_X: longint; p_Y: longint; p_Value:longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X, p_Y);
    mb[mp+3]:=mb[mp+3]+p_Value;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.AdjustRGB(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X, p_Y);
    mb[mp+2]:=mb[mp+2]+p_R;
    mb[mp+1]:=mb[mp+1]+p_G;
    mb[mp+0]:=mb[mp+0]+p_B;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.AdjustRGBA(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint; p_A:longint);
//----------------------------------------------------------------------------
var mp: longint;
begin
  if(p_X<pvt_Width) and (p_Y<pvt_Height) and (p_X>=0) and (p_Y>=0)then
  begin
    mp:=MemPos(p_X, p_Y);
    mb[mp+2]:= mb[mp+2]+p_R;
    mb[mp+1]:= mb[mp+1]+p_G;
    mb[mp+0]:= mb[mp+0]+p_B;
    mb[mp+3]:= mb[mp+3]+p_A;
  end;
end;
//----------------------------------------------------------------------------














//----------------------------------------------------------------------------
procedure TPIXELGRID.FillR(p_R: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      Red_Set(x,y,p_R);
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.FillG(p_G: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      Green_Set(x,y,p_G);
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.FillB(p_B: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      Blue_Set(x,y,p_B);
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.FillA(p_A: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      Alpha_Set(x,y,p_A);
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.FillRGB(p_R: byte; p_G: byte; p_B: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      RGB_Set(x,y,p_R,p_G,p_B);
    end;
  end;
end;
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
procedure TPIXELGRID.FillRGBA(p_R:byte; p_G: byte; p_B: byte; p_A: byte);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      RGBA_Set(x,y,p_R,p_G,p_B,p_A);
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.FillRGBA(p_RGBA: cardinal);
//----------------------------------------------------------------------------
var x: longint; y: longint;
begin
  for y:=0 to pvt_Height-1 do begin
    for x:=0 to pvt_Width-1 do begin
      RGBA_Set(x,y,p_RGBA);
    end;
  end;
end;
//----------------------------------------------------------------------------







//----------------------------------------------------------------------------
procedure TPIXELGRID.Line(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_RGBA: cardinal
);
//----------------------------------------------------------------------------
var
  bSteep : boolean;
  temp   : longint;
  deltax : integer;
  deltay : integer;
  error  : integer;
  ystep  : integer;
  y      : integer;
  x      : integer;

begin
  bSteep:=(ABS(p_y2 - p_y1) > ABS(p_x2 - p_x1));
  if(bSteep)then
  begin
    temp:=p_x1;p_x1:=p_y1;p_y1:=temp;
    temp:=p_x2;p_x2:=p_y2;p_y2:=temp;
  end;
  if(p_x1 > p_x2)then
  begin
    temp:=p_x1;p_x1:=p_x2;p_x2:=temp;
    temp:=p_y1;p_y1:=p_y2;p_y2:=temp;
  end;
  deltax := p_x2-p_x1;
  deltay := ABS(p_y2-p_y1);
  error  := -(deltax+1) div 2;
  ystep  := 0;
  y      := p_y1;
  x      := 0;

  if(p_y1 < p_y2)then ystep:= 1 else ystep:= -1;

  for x:=p_x1 to p_x2-1 do
  begin
    if(bSteep)then
    begin
      RGBA_Set(y,x,p_RGBA);
    end
    else
    begin
      RGBA_Set(x,y,p_RGBA);
    end;
    error+=deltay;
    if(error >= 0)then
    begin
      y+=ystep;
      error-=deltax;
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.LineR(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Red: byte
);
//----------------------------------------------------------------------------
var
  bSteep : boolean;
  temp   : longint;
  deltax : integer;
  deltay : integer;
  error  : integer;
  ystep  : integer;
  y      : integer;
  x      : integer;
begin
  bSteep:=(ABS(p_y2 - p_y1) > ABS(p_x2 - p_x1));
  if(bSteep)then
  begin
    temp:=p_x1;p_x1:=p_y1;p_y1:=temp;
    temp:=p_x2;p_x2:=p_y2;p_y2:=temp;
  end;
  if(p_x1 > p_x2)then
  begin
    temp:=p_x1;p_x1:=p_x2;p_x2:=temp;
    temp:=p_y1;p_y1:=p_y2;p_y2:=temp;
  end;
  deltax := p_x2-p_x1;
  deltay := ABS(p_y2-p_y1);
  error  := -(deltax+1) div 2;
  ystep  := 0;
  y      := p_y1;
  x      := 0;

  if(p_y1 < p_y2)then ystep:= 1 else ystep:= -1;

  for x:=p_x1 to p_x2-1 do
  begin
    if(bSteep)then
    begin
      Red_Set(y,x,p_Red);
    end
    else
    begin
      Red_Set(x,y,p_Red);
    end;
    error+=deltay;
    if(error >= 0)then
    begin
      y+=ystep;
      error-=deltax;
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.LineG(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Green: byte
);
//----------------------------------------------------------------------------
var
  bSteep : boolean;
  temp   : longint;
  deltax : integer;
  deltay : integer;
  error  : integer;
  ystep  : integer;
  y      : integer;
  x      : integer;
begin
  bSteep:=(ABS(p_y2 - p_y1) > ABS(p_x2 - p_x1));
  if(bSteep)then
  begin
    temp:=p_x1;p_x1:=p_y1;p_y1:=temp;
    temp:=p_x2;p_x2:=p_y2;p_y2:=temp;
  end;
  if(p_x1 > p_x2)then
  begin
    temp:=p_x1;p_x1:=p_x2;p_x2:=temp;
    temp:=p_y1;p_y1:=p_y2;p_y2:=temp;
  end;
  deltax := p_x2-p_x1;
  deltay := ABS(p_y2-p_y1);
  error  := -(deltax+1) div 2;
  ystep  := 0;
  y      := p_y1;
  x      := 0;

  if(p_y1 < p_y2)then ystep:= 1 else ystep:= -1;

  for x:=p_x1 to p_x2-1 do
  begin
    if(bSteep)then
    begin
      Green_Set(y,x,p_Green);
    end
    else
    begin
      Green_Set(x,y,p_Green);
    end;
    error+=deltay;
    if(error >= 0)then
    begin
      y+=ystep;
      error-=deltax;
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.LineB(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Blue: byte
);
//----------------------------------------------------------------------------
var
  bSteep : boolean;
  temp   : longint;
  deltax : integer;
  deltay : integer;
  error  : integer;
  ystep  : integer;
  y      : integer;
  x      : integer;
begin
  bSteep:=(ABS(p_y2 - p_y1) > ABS(p_x2 - p_x1));
  if(bSteep)then
  begin
    temp:=p_x1;p_x1:=p_y1;p_y1:=temp;
    temp:=p_x2;p_x2:=p_y2;p_y2:=temp;
  end;
  if(p_x1 > p_x2)then
  begin
    temp:=p_x1;p_x1:=p_x2;p_x2:=temp;
    temp:=p_y1;p_y1:=p_y2;p_y2:=temp;
  end;

  deltax := p_x2-p_x1;
  deltay := ABS(p_y2-p_y1);
  error  := -(deltax+1) div 2;
  ystep  := 0;
  y      := p_y1;
  x      := 0;

  if(p_y1 < p_y2)then ystep:= 1 else ystep:= -1;

  for x:=p_x1 to p_x2-1 do
  begin
    if(bSteep)then
    begin
      Blue_Set(y,x,p_Blue);
    end
    else
    begin
      Blue_Set(x,y,p_Blue);
    end;
    error+=deltay;
    if(error >= 0)then
    begin
      y+=ystep;
      error-=deltax;
    end;
  end;
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.LineA(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Alpha: byte
);
//------------------------------------------------------------------------
var
  bSteep : boolean;
  temp   : longint;
  deltax : integer;
  deltay : integer;
  error  : integer;
  ystep  : integer;
  y      : integer;
  x      : integer;
begin
  bSteep:=(ABS(p_y2 - p_y1) > ABS(p_x2 - p_x1));
  if(bSteep)then
  begin
    temp:=p_x1;p_x1:=p_y1;p_y1:=temp;
    temp:=p_x2;p_x2:=p_y2;p_y2:=temp;
  end;
  if(p_x1 > p_x2)then
  begin
    temp:=p_x1;p_x1:=p_x2;p_x2:=temp;
    temp:=p_y1;p_y1:=p_y2;p_y2:=temp;
  end;
  deltax := p_x2-p_x1;
  deltay := ABS(p_y2-p_y1);
  error  := -(deltax+1) div 2;
  ystep  := 0;
  y      := p_y1;
  x      := 0;

  if(p_y1 < p_y2)then ystep:= 1 else ystep:= -1;

  for x:=p_x1 to p_x2-1 do
  begin
    if(bSteep)then
    begin
      Alpha_Set(y,x,p_Alpha);
    end
    else
    begin
      Alpha_Set(x,y,p_Alpha);
    end;
    error+=deltay;
    if(error >= 0)then
    begin
      y+=ystep;
      error-=deltax;
    end;
  end;
end;
//------------------------------------------------------------------------


//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Boxes
//------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Box(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_RGBA: cardinal
);
//----------------------------------------------------------------------------
begin
  Line(p_x1, p_y1, p_x2, p_y1, p_RGBA);//top
  Line(p_x1, p_y2, p_x2, p_y2, p_RGBA);//bottom
  Line(p_x1, p_y1, p_x1, p_y2, p_RGBA);//left
  Line(p_x2, p_y1, p_x2, p_y2, p_RGBA);//right
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.Box(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_RGBA: cardinal;
  p_RGBA_Fill: cardinal
);
//----------------------------------------------------------------------------
var
  x1: longint;
  x2: longint;
  y1: longint;
  y2: longint;
  y: longint;
begin
  x1:=p_x1;
  x2:=p_x2;
  y1:=p_y1;
  y2:=p_y2;
  for y:=y1 to y2-1 do
  begin
    Line(x1,y,x2,y,p_RGBA_Fill);
  end;
  Box(p_x1, p_y1, p_x2, p_y2,p_RGBA);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxR(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Red: byte
);
//----------------------------------------------------------------------------
begin
  LineR(p_x1, p_y1, p_x2, p_y1, p_Red);//top
  LineR(p_x1, p_y2, p_x2, p_y2, p_Red);//bottom
  LineR(p_x1, p_y1, p_x1, p_y2, p_Red);//left
  LineR(p_x2, p_y1, p_x2, p_y2, p_Red);//right
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxR(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Red: byte;
  p_Red_Fill: byte
);
//----------------------------------------------------------------------------
var
  x1: longint;
  x2: longint;
  y1: longint;
  y2: longint;
  y: longint;
begin
  x1:=p_x1;
  x2:=p_x2;
  y1:=p_y1;
  y2:=p_y2;
  for y:=y1 to y2-1 do
  begin
    LineR(x1,y,x2,y,p_Red_Fill);
  end;
  BoxR(p_x1, p_y1, p_x2, p_y2,p_Red);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxG(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Green: byte
);
//----------------------------------------------------------------------------
begin
  LineG(p_x1, p_y1, p_x2, p_y1, p_Green);//top
  LineG(p_x1, p_y2, p_x2, p_y2, p_Green);//bottom
  LineG(p_x1, p_y1, p_x1, p_y2, p_Green);//left
  LineG(p_x2, p_y1, p_x2, p_y2, p_Green);//right
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxG(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Green: byte;
  p_Green_Fill: byte
);
//----------------------------------------------------------------------------
var
  x1: longint;
  x2: longint;
  y1: longint;
  y2: longint;
  y: longint;
begin
  x1:=p_x1;
  x2:=p_x2;
  y1:=p_y1;
  y2:=p_y2;
  for y:=y1 to y2-1 do begin
    LineG(x1,y,x2,y,p_Green_Fill);
  end;
  BoxG(p_x1, p_y1, p_x2, p_y2,p_Green);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxB(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Blue: byte
);
//----------------------------------------------------------------------------
begin
  LineB(p_x1, p_y1, p_x2, p_y1, p_Blue);//top
  LineB(p_x1, p_y2, p_x2, p_y2, p_Blue);//bottom
  LineB(p_x1, p_y1, p_x1, p_y2, p_Blue);//left
  LineB(p_x2, p_y1, p_x2, p_y2, p_Blue);//right
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxB(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Blue: byte;
  p_Blue_Fill: byte
);
//----------------------------------------------------------------------------
var
  x1: longint;
  x2: longint;
  y1: longint;
  y2: longint;
  y: longint;
begin
  x1:=p_x1;
  x2:=p_x2;
  y1:=p_y1;
  y2:=p_y2;
  for y:=y1 to y2-1 do begin
    LineB(x1,y,x2,y,p_Blue_Fill);
  end;
  BoxB(p_x1, p_y1, p_x2, p_y2,p_Blue);
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxA(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Alpha: byte
);
//----------------------------------------------------------------------------
begin
  LineA(p_x1, p_y1, p_x2, p_y1, p_Alpha);//top
  LineA(p_x1, p_y2, p_x2, p_y2, p_Alpha);//bottom
  LineA(p_x1, p_y1, p_x1, p_y2, p_Alpha);//left
  LineA(p_x2, p_y1, p_x2, p_y2, p_Alpha);//right
end;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
procedure TPIXELGRID.BoxA(
  p_x1: longint;
  p_y1: longint;
  p_x2: longint;
  p_y2: longint;
  p_Alpha: byte;
  p_Alpha_Fill: byte
);
//------------------------------------------------------------------------
var
  x1: longint;
  x2: longint;
  y1: longint;
  y2: longint;
  y: longint;
begin
  x1:=p_x1;
  x2:=p_x2;
  y1:=p_y1;
  y2:=p_y2;
  for y:=y1 to y2-1 do begin
    LineA(x1,y,x2,y,p_Alpha_Fill);
  end;
  BoxA(p_x1, p_y1, p_x2, p_y2,p_Alpha);
end;
//------------------------------------------------------------------------


//============================================================================
// End                            TPIXELGRID
//============================================================================



//============================================================================
begin
end.
//============================================================================

//****************************************************************************
// EOF
//****************************************************************************








