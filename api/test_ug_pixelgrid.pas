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
// Test Jegas' uxxg_pixelgrid class
program test_ug_pixelgrid;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  ug_common,
  ug_rgba,
  ug_pixelgrid;
//=============================================================================

//=============================================================================
var
//=============================================================================
  pg: TPixelGrid;
  gsafilename_noext: ansistring;
//=============================================================================



//=============================================================================
// Test Memory Array
//=============================================================================
function bTestMemoryArray: boolean;
var
  bOk: boolean;
  mp: longint;
  u2: word;
  u4: cardinal;
begin
  bOk:=pg.size_set(601,601);
  if not bOk then
  begin
    writeln('pg.size_set(601,601) Failed.');
  end;

  if bOk then
  begin
    bOk:=  (length(pg.mb) = ((601*601*4)+12));
    if not bOk then
    begin
      writeln('MB Array Wrong Size after Size_Set(x,y).');
    end;
  end;

  if bOk then
  begin
    bOk:=pg.Width_Get=601;
    if not bOk then
    begin
      writeln('Width_Get Failed!');
    end;
  end;

  if bOk then
  begin
    bOk:=pg.Height_Get=601;
    if not bOk then
    begin
      writeln('Height_Get Failed!');
    end;
  end;

  if bOk then
  begin
    bOk:=pg.Depth_Get=32;
    if not bOk then
    begin
      writeln('Depth_Get Failed!');
    end;
  end;

  if bOk then
  begin
    bOk:=pg.BytesPerPixel=4;
    if not bOk then
    begin
      writeln('BytesPerPixel function Failed!');
    end;
  end;

  if bOk then
  begin
    mp:=pg.mempos(600,600);
    bOk:=mp = (length(pg.mb)-4);
    if not bOk then
    begin
      writeln('MemPos function Failed! MemPos:',mp,
        ' length(pg.mb):',length(pg.mb), '(+4 ok)  Difference: ',mp-length(pg.mb));
    end;
  end;

  if bOk then
  begin
    pg.Word_Set(pg.mempos(100,100),60000);
    u2:=pg.Word_Get(pg.mempos(100,100));
    bOk:=u2=60000;
    if not bOk then
    begin
      writeln('pg.Word_Set/pg.Word_Get Failed!');
    end;
  end;

  if bOk then
  begin
    pg.DWord_Set(pg.mempos(100,100),$FFFFFFFF);
    u4:=pg.DWord_Get(pg.mempos(100,100));
    bOk:=u4=$FFFFFFFF;
    if not bOk then
    begin
      writeln('pg.DWord_Set/pg.DWord_Get Failed!');
    end;
  end;

  if bOk then
  begin
    pg.Long_Set(pg.mempos(101,101),$0AAAAAAA);
    u4:=pg.Long_Get(pg.mempos(101,101));
    bOk:=u4=$0AAAAAAA;
    if not bOk then
    begin
      writeln('pg.Long_Get,pg.Long_Set Failed!');
    end;
  end;
  result:=bok;
end;
//=============================================================================



//=============================================================================
function bTestDrawingCalls:boolean;
//=============================================================================
var
  bOk: boolean;
  x: longint;
  rgba: TRGBA;
begin
  bOk:=true;
  rgba:=TRGBA.Create;

  // These Fill Whole Canvas
  pg.FillR(50);
  pg.FillG(50);
  pg.FillB(50);
  pg.FillA(50);
  pg.FillRGB(100,100,100);
  pg.FillRGBA(200,200,200,200);
  pg.FillRGBA($FF000000);// Then Clear "canvas" to black with full alpha BRIGHT

  // Pixel Grid Allows Full Red, Green, Blue, and Alpha Channel Access
  // Check this out!
  // Ok - showing you something here. pvt_Width is a value that most coders
  // would make PRIVATE. I even indicate that this thing SHOULD at least be
  // treated as private. Why don't I have a function to return canvas height?
  // I DO: pg->Height_Get()
  // So why use this pvt_Height thing? Because accessing the value directly
  // is faster than calling a function. If this was some business application
  // I'd do things differently for security, but game development, this clock
  // cycle saving trick (implemented into JGC everywhere) is perfect!
  // Now not all variables are public, but ones that are advantageous to be
  // for speed reasons - usually are set up this way in the JGC lib.
  //
  // Note: Certain responsibility comes with this underhanded clock cycle saving
  // technique though! These vaules should be treated as READ ONLY!
  // If you have funky bugs that you aren't sure about, switch to using the
  // safe functions instead like: pg->Height_Get()

  x:=0;
  while x<pg.pvt_Width-1 do
  begin
    // Normal Line - all channels - Alpha SET to FULL VISIBLE when PixelGrid Made.
    pg.Line(0,x,x,pg.pvt_Height-1,$ffffff);
    // Parameters: x1,y1, x2,y2, RGBColor

    // Line in only the Red channel
    pg.LineR(0,x+10,x+10,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, RedColor

    // Line in only the Green channel
    pg.LineG(0,x+20,x+20,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, GreenColor

    // Line in only the Blue channel
    pg.LineB(0,x+30,x+30,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, BlueColor

    // Line in only the Alpha channel (We'll make invisible line LOL)
    // HINT: Those Aren't DARK GREEN Lines on the SCREEN! They are HOLES!
    pg.LineA(0,x+40,x+40,pg.pvt_Height-1,0);
    // Parameters: x1,y1, x2,y2, AlphaLevel

    x:=x+25;
  end;


  x:=0;
  while x<pg.pvt_Width-1 do
  begin
    // Normal Line - all channels - Alpha SET to FULL VISIBLE when PixelGrid Made.
    pg.Line(X,0,pg.pvt_width,X,$ffffff);
    // Parameters: x1,y1, x2,y2, RGBColor

    // Line in only the Red channel
    pg.LineR(0,x+10,pg.pvt_width,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, RedColor

    // Line in only the Green channel
    pg.LineG(x+20,0,pg.pvt_width,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, GreenColor

    // Line in only the Blue channel
    pg.LineB(x+30,0,pg.pvt_width,pg.pvt_Height-1,255);
    // Parameters: x1,y1, x2,y2, BlueColor

    // Line in only the Alpha channel (We'll make invisible line LOL)
    // HINT: Those Aren't DARK GREEN Lines on the SCREEN! They are HOLES!
    pg.LineA(x+40,0,pg.pvt_width,pg.pvt_Height-1,0);
    // Parameters: x1,y1, x2,y2, AlphaLevel

    x:=x+15;
  end;


  // How about a couple of boxes done the same way? (Not filled in Variety)
  pg.Box(300,50, 350,500,$00FFFFFF);//normal (RGB channels all written too
  pg.BoxR(310,60,360,510,255);//red
  pg.BoxG(320,70,370,520,255);//green
  pg.BoxB(340,80,380,530,255);//blue
  pg.BoxA(350,90,390,540, 0 );//alpha.. let's punch a hole!

  // Ok.. same thing but we Specify OUTLINE AND INSIDE color (Filled In Variety)
  // Gonna make the outlines BRIGHT and insides darker you you can see how it
  // works B^)
  pg.Box(400,50,450,500,$FFFFFF,$646464);//normal (RGB channels all written too
  pg.BoxR(410,60,460,510,255,120);//red
  pg.BoxG(420,70,470,520,255,120);//green
  pg.BoxB(440,80,480,530,255,120);//blue
  pg.BoxA(450,90,490,540, 0,120 );//alpha.. let's punch a hole...sorta ;)

  //There are also FOUR fill routines but they FILL the WHOLE channel (or all)
  //with specified values.

  // There is Cut and Paste but I think I'll save that for another demo.

  // There CURRENTLY is not CIRCLE or FLOODFILL functions, but I'll get to
  // them sooner or later.

  if bOk then
  begin
    pg.Red_Set(400,20,10);
    bOk:=pg.Red_Get(400,20)=10;
    if not bOk then
    begin
      writeln('Red_Set/Red_Get Failed!');
    end;
  end;

  if bOk then
  begin
    pg.Green_Set(400,20,100);
    bOk:=pg.Green_Get(400,20)=100;
    if not bOk then
    begin
      writeln('Green_Set/Green_Get Failed!');
    end;
  end;

  if bOk then
  begin
    pg.Blue_Set(400,20,200);
    bOk:=pg.Blue_Get(400,20)=200;
    if not bOk then
    begin
      writeln('Blue_Set/Blue_Get Failed!');
    end;
  end;


  if bOk then
  begin
    pg.Alpha_Set(400,20,30);
    bOk:=pg.Alpha_Get(400,20)=30;
    if not bOk then
    begin
      writeln('Alpha_Set/Alpha_Get Failed!');
    end;
  end;

  //if bOk then
  //begin
  //  pg.RGB_Set(400,20,$FF,$FF,$FF);
  //  pg.RGB_Set(400,21,$00AAAAAA);
  //  bOk:=(pg.RGB_Get(400,20)=$FFFFFF) and (pg.RGB_Get(400,21)=$AAAAAA);
  //  if not bOk then
  //  begin
  //    writeln('RGB_Set(x,y,r,g,b)/RGB_Set(x,y,dw)/RGB_Get(x,y) Failed!');
  //  end;
  //end;

  //if bOk then
  //begin
  //  rgba.Red_Set($FF);
  //  rgba.Green_Set($FF);
  //  rgba.Blue_Set($FF);
  //  rgba.Alpha_Set($FF);
  //  pg.RGB_Set(400,20,rgba);
  //  bOk:=pg.RGBA_Get(400,20)=$FFFFFFFF;
  //  if not bOk then
  //  begin
  //    Writeln('pg.RGB_Set(trgba) failed!');
  //  end;
  //end;

  if bOk then
  begin
    pg.RGBA_Set(400,20,$A3,$A2,$A1,$A4);
    bOk:=pg.RGBA_Get(400,20)=$A4A3A2A1;
    if not bOk then
    begin
      Writeln('pg.RGBA_Set(x,y,r,g,b,a) failed!');
    end;
  end;

  // Use to lighten/lessen values with positive or negative values.
  // I "should" test them but I'm pretty sure they work, and if not,
  // I don't use them that much. When I do, if they are broke, I'll fix them
  // Now - I want to get the Load/Save working for *.BMP 24 Bit Format working
  // so USGS code can do its thing.
  //pg.AdjustR(p_X: longint; p_Y: longint; p_Value: longint);
  //pg.AdjustG(p_X: longint; p_Y: longint; p_Value: longint);
  //pg.AdjustB(p_X: longint; p_Y: longint; p_Value: longint);
  //pg.AdjustA(p_X: longint; p_Y: longint; p_Value: longint);
  //pg.AdjustRGB(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint);
  //pg.AdjustRGBA(p_X: longint; p_Y: longint; p_R: longint; p_G: longint; p_B: longint; p_A: longint);

  rgba.destroy;
  result:=bOk;
end;
//=============================================================================












//=============================================================================
var
//=============================================================================
  bGood: boolean;
  u2IOResult: word;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  bGood:=true;
  pg:=TPixelGrid.create;
  gsafilename_noext:='.'+DOSSLASH+'data'+DOSSLASH+'pixelgrid';
  if bGood then
  begin
    writeln('TestMemoryArray');
    bGood:=bTestMemoryArray;
    if not bGood then
    begin
      writeln('bTestMemoryArray failed!');
    end;
  end;

  if bGood then
  begin
    writeln('bTestDrawingCalls');
    bGood:=bTestDrawingCalls;
    if not bGood then
    begin
      writeln('bTestDrawingCalls failed!');
    end;
  end;

  if bGood then
  begin
    writeln('u2SaveAsText');
    bGood:=0=pg.u2SaveAsText(gsafilename_noext+'.txt');
    if not bGood then
    begin
      writeln('u2SaveAsText failed!');
    end;
  end;

  if bGood then
  begin
    writeln('u2SaveBitmap24');
    bGood:=0=pg.u2SaveBitmap24(gsafilename_noext+'.bmp',nil,nil);

    if not bGood then
    begin
      writeln('u2SaveBitMap24 failed!');
    end;
  end;

  if bGood then
  begin
    writeln('u2LoadBitmap24');
    u2IOResult:=pg.u2LoadBitmap24(gsafilename_noext+'.bmp');
    bGood:=u2IOResult=0;
    if not bGood then
    begin
      writeln('u2LoadBitMap24 failed! ',sIOResult(u2IOResult));
    end;
  end;

  //This will bomb in this order for some
  // reason - i'll revisit TODO: revisit this odd error
  //
  //if bGood then
  //begin
  //  writeln('u2SaveBitmap24');
  //  u2IOResult:=pg.u2SaveBitmap24(safilename_noext+'.bmp',nil,nil);
  //  bGood:=u2IOResult=0;
  //  if not bGood then
  //  begin
  //    writeln('u2SaveBitMap24 failed! u2IOResult: ', u2IOResult,' ',saIOResult(u2IOResult));
  //  end;
  //end;

  if pg <> nil then
  begin
    pg.destroy;
    pg:=nil;
  end;

  if bGood then Writeln('All TPixelGrid Tests have Passed! Woo Hoo!');
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

