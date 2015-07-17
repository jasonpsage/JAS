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
// This unit is the CORE Jegas API's Console support
Unit uc_console;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uc_console.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{DEFINE DEBUGLOWLEVELDRAWING}

{$DEFINE VCCHECK}

{$DEFINE LESSFRAG} // Not sure how well this works. Attempts to REUSE
                  // Allocated Memory if the new VC Size is the same
                  // size or smaller than it was previously -
                  // This pertains to VCResize.

{$DEFINE TIGHTCODE} // This removes certain error messages from going to
                   // the SageLog. Its not fully tested - and could break
                   // DEBUGLOGBEGINEND stuff.

{DEFINE DROPWIN32} // For Writing Linux Code initially on Win32,
  // I use this so IF WIN32, but this is SET - "Pretend" its linux.
  // I don't expect the code to run in win32 like this, but it lets
  // me do - at least quite a bit of "does it compile" testing in Win32
  // which is the only place I can use my favorite text editor:
  // www.terasoft.ru "Tera Edit" - Awesome Column editing feature...
  // anyways back to it...

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}
{$IFDEF DEBUGLOWLEVELDRAWING}
  {$INFO | DEBUGLOWLEVELDRAWING: TRUE}
{$ENDIF}
{$IFDEF VCCHECK}
  {$INFO | VCCHECK: TRUE}
{$ENDIF}
{$IFDEF LESSFRAG}
  {$INFO | LESSFRAG: TRUE}
{$ENDIF}
{$IFDEF TIGHTCODE}
  {$INFO | TIGHTCODE: TRUE}
{$ENDIF}
{$IFDEF DROPWIN32}
  {$INFO | DROPWIN32: TRUE}
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


{
//=============================================================================
// Code Snippet Using rtVCInfo with function VCGetInfo and Proc VCSetInfo
//=============================================================================
Var rVCInfo: rtVCInfo;
    iTempActiveVC: LongInt;
Begin
  uTempActiveVC:=GetActiveVC;
  vc:=NewVC(giConsoleWidth, giConsoleHeight);
  rVCInfo:=GetVCInfo;
  With rVCInfo Do Begin
    // Virtual Screen coords Relative to Real Video Screen-One Based
    VX:=VX;  // (Default: 1)
    VY:=VY;  // (Default: 1)

    // Height and Width of Virtual Screen
    VW:=VW; // (Set by NewVC Call)
    VH:=VH; // (Set by NewVC Call.)

    // Pen Coords - One Based
    VPX:=VPX; // (Default: 1)
    VPY:=VPY; // (Default: 1)

    // Pen Foreground And Background Colors
    VFGC:=VFGC; // (Default: Light Gray)
    VBGC:=VBGC; // (Default: Black)

    // Toggles whether Writing Past the Width of the VC makes the cursor
    // drop to the next line. Has no bearing on VCPut commands, just VCWrite stuff
    VWrap:=VWrap; // (Default: True)

    // Tabsize - Only has effect when VCWrit'n with the pen
    VTabSize:=VTabSize; // (Default: 8)

    // Toggles AutoCursor Tracking. The Cursor Follows the Pen when using VCWrite
    VTrackCursor:=VTrackCursor; //(Default: True)

    // Blinky  Coords - One Based
    VCX:=VCX; // (Default: 1)
    VCY:=VCY; // (Default: 1)
    // The Blinky Cursor Types: crUnderline, crHidden, crBlock, crHalfBlock
    VCursorType:=VCursorType; // (Default:  crUnderline)

    // Toggles Auto Scroll - Which scrolls the VC's contents up if while using
    // VCWrite commands you either wrote past the bottom right hand corner of the
    // VC (if VWrap is set to true) or if a Linefeed (Ascii #10) is encountered.
    VScroll:=VScroll; // (Default: True)

    // Scrolling Region X,Y,W,H (One Based)- MUST Be entirely within VC.
    VSX:=VSX; // (Default: 1)
    VSY:=VSY; // (Default: 1)
    VSW:=VSW; // (Default: VCWidth  -See VW Field of this record)
    VSH:=VSH; // (Default: VCHeight -See VH Field of this record)

    // Toggles whether VC is Hidden or not
    VVisible:=VVisible; // (Default: True)

    // Toggles whether characters in the VC with Ascii Value Zero makes those
    // cells transparent or not. Also, Ascii 1=Solid FGC
    //                                 Ascii 2=Solid BGC
    //                                 Ascii 3=Solid FGC & BGC
    VTransparency:=VTransparency; // (Default: False)

    // Toggles Ability to allow Characters of whatever is underneath VC to show
    VOpaqueCh:=VOpaqueCh; // (Default: True)
    // Toggles Ability to allow FG color of whatever is underneath VC to show
    VOpaqueFG:=VOpaqueFG; // (Default: True)
    // Toggles Ability to allow BG color of whatever is underneath VC to show
    VOpaqueBG:=VOpaqueBG;//  (Default: True)

    // Note: Having Transparency Set To TRUE while All cell's characters set
    //       to ASCII ZERO will render the VC Invisible - Not hidden.
    //       The same is true for Setting All VCOpaque flags to False.
    //       These are not the most efficient ways to hide a VC. Just set
    //       to hidden for optimal performance.
  End;
  SetActiveVC(iTempActiveVC);
//=============================================================================
}



//=============================================================================
Uses
//=============================================================================
{$IFDEF WIN32}
windows,
{$ENDIF}
Video,
Mouse,
Keyboard,
Sysutils,
ug_common,
ug_jegas,
ug_JFC_XDL,
ug_JFC_TOKENIZER,
{$IFDEF LINUX}
crt,//This is not used directly but causes desired behavior in linux.
    //With out it - task switching in Linux Console dones't work.
    //The other piece to this strange solution is in initconsole -
    //I init the FPC KEYBOARD unit, empty the buffer, then call
    //donekeybaord but I still call the keyboard unit procs/func
    //as if it was "Initialized". This in conjuction with including CRT
    //in linux gives desired results - at least with intel linux.
    //I don't like this at but I implemented keyboard to try to
    //inherit the platform independance - which has not been easy.
{$ENDIF}
dos;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!Declarations
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{Note: Having Transparency Set To TRUE while All cell's characters set
 to ASCII ZERO will render the VC Invisible - Not hidden.
 The same is true for Setting All VCOpaque flags to False.
 These are not the most efficient ways to hide a VC. Just set
 to hidden for optimal performance.}
Type rtVCInfo = Record
//=============================================================================
  {}
  VX: LongInt;  //< (Default: 1) Virtual Screen coords Relative to Real Video Screen-One Based
  VY: LongInt;  //< (Default: 1) Virtual Screen coords Relative to Real Video Screen-One Based

  VW: LongInt; //< (No Default - You Must In NewVC Call) Height and Width of Virtual Screen
  VH: LongInt; //< (No Default - You Must In NewVC Call) Height and Width of Virtual Screen

  VPX: LongInt; //< (Default: 1) Pen Coords - One Based
  VPY: LongInt; //< (Default: 1) Pen Coords - One Based

  VFGC: Byte; //< (Default: Light Gray) Pen Foreground And Background Colors
  VBGC: Byte; //< (Default: Black) Pen Foreground And Background Colors

  VWrap: Boolean; //< (Default: True)Toggles whether Writing Past the Width of the VC makes the cursor drop to the next line. Has no bearing on VCPut commands, just VCWrite stuff

  VTabSize: Byte; //< (Default: 8) Tabsize - Only has effect when VCWrit'n with the pen

  VTrackCursor:Boolean; //<(Default: True) Toggles AutoCursor Tracking. The Cursor Follows the Pen when using VCWrite

  VCX: LongInt; //< (Default: 1) Blinky  Coords - One Based
  VCY: LongInt; //< (Default: 1) Blinky  Coords - One Based

  VCursorType: Word; //< (Default:  crUnderline) The Blinky Cursor Types: crUnderline, crHidden, crBlock, crHalfBlock

  VScroll: Boolean; {< (Default: True) Toggles Auto Scroll - Which scrolls the VC's contents up if while using
                    VCWrite commands you either wrote past the bottom right hand corner of the
                    VC (if VWrap is set to true) or if a Linefeed (Ascii #10) is encountered.}

  VSX: LongInt; //< (Default: 1) Scrolling Region X,Y,W,H (One Based)- MUST Be entirely within VC.
  VSY: LongInt; //< (Default: 1) Scrolling Region X,Y,W,H (One Based)- MUST Be entirely within VC.
  VSW: LongInt; //< (Default: VCWidth  -See VW Field of this record) Scrolling Region X,Y,W,H (One Based)- MUST Be entirely within VC.
  VSH: LongInt; //< (Default: VCHeight -See VH Field of this record) Scrolling Region X,Y,W,H (One Based)- MUST Be entirely within VC.

  VVisible:Boolean; //< (Default: True) Toggles whether VC is Hidden or not

  VTransparency: Boolean; {< (Default: False) Toggles whether characters in the VC with Ascii Value Zero makes those
                           cells transparent or not. Also, Ascii 1=Solid FGC
                                                           Ascii 2=Solid BGC
                                                           Ascii 3=Solid FGC & BGC}

  VOpaqueCh: Boolean; //< (Default: True) Toggles Ability to allow Characters of whatever is underneath VC to show

  VOpaqueFG: Boolean; //< (Default: True) Toggles Ability to allow FG color of whatever is underneath VC to show

  VOpaqueBG: Boolean;//<  (Default: True) Toggles Ability to allow BG color of whatever is underneath VC to show
  {}

  VUseScrollRegionCoords: Boolean;
End;
//=============================================================================

//=============================================================================
{}
Type rtConsoleDriver = Record
//=============================================================================
  {}
  InitDriver : Procedure;
  DoneDriver : Procedure;
  UpdateScreen : Procedure(Force : Boolean);
  ClearScreen : Procedure;
  SetVideoMode : Function (Const Mode : TVideoMode) : Boolean;
  GetVideoModeCount : Function : Word;
  GetVideoModeData : Function(Index : Word; Var Data : TVideoMode) : Boolean;
  SetCursorPos : Procedure (NewCursorX, NewCursorY: Word);
  GetCursorType : Function : Word;
  SetCursorType : Procedure (NewType: Word);
  GetCapabilities : Function : Word;
End;
//=============================================================================

//=============================================================================
{}
Type rtConsoleMode = Record
//=============================================================================
  {}
  Col,Row : Word;
  Color : Boolean;
End;
//=============================================================================

//=============================================================================
{}
Type rtKeyPress=Record
//=============================================================================
  {}
  u1Flags: Byte;
  u2KeyCodeRaw: Word; //< No Translation Performed.
  bSHIFTPressed: Boolean;
  bLSHIFTPressed: Boolean;
  bRSHIFTPressed:Boolean;
  bCNTLPressed: Boolean;
  bALTPressed: Boolean;
  // OS Independant Translated Data
  u2KeyCode: Word;  //< OS Independant Translated Data OS Independant Translation of Function Keys and Physical
                    // keys to thier ASCII counterpart if there is Equivalent.
  ch: Char;
End;
//=============================================================================

// Mouse Event Record (mouseevent)
//=============================================================================
{}
Type rtMEvent = Record
//=============================================================================
  {}
  Buttons :Word;
  ConsoleX:LongInt;
  ConsoleY:LongInt;
  Action  :Word;
  VC      : UINT;
  VMX     :LongInt;
  VMY     :LongInt;
End;
//=============================================================================




//=============================================================================
{}
Const {< PREPARATION for NCURSES Type Output - Either ANSI or GFX Chars
      If I ever get around to it - these chars - when encountered in
      buffer will be translated to the Correct "NCURSES" call on linux
      Cheap Way Out For Now is the compiler define}
//=============================================================================
{$IFDEF WIN32}
  cch_GFX_LARROWUP = #24;  //< LIGHT Arrows
  cch_GFX_LARROWDOWN = #25;
  cch_GFX_LARROWLEFT = #27;
  cch_GFX_LARROWRIGHT = #26;
  cch_GFX_HARROWUP = #30;  //< Heavy Arrows
  cch_GFX_HARROWDOWN = #31;
  cch_GFX_HARROWLEFT = #17;
  cch_GFX_HARROWRIGHT = #16;
  cch_GFX_SHADE1 = #176;
  cch_GFX_SHADE2 = #177;
  cch_GFX_SHADE3 = #178;
  cch_GFX_SOLID = #219;
  cch_GFX_HALFTOP = #223;
  cch_GFX_HALFBOTTOM = #220;
  cch_GFX_HALFLEFT = #221;
  cch_GFX_HALFRIGHT=#222;
  cch_GFX_LFRAMETOPLEFT=#218; //< LIGHT Frames - single line or whatever
  cch_GFX_LFRAMETOPRIGHT=#191;
  cch_GFX_LFRAMEBOTTOMLEFT=#192;
  cch_GFX_LFRAMEBOTTOMRIGHT=#217;
  cch_GFX_LFRAMEHORIZONTAL=#196;
  cch_GFX_LFRAMEVERTICAL=#179;
  cch_GFX_LFRAMETLEFT=#195;
  cch_GFX_LFRAMETRIGHT=#180;
  cch_GFX_LFRAMET=#194;
  cch_GFX_LFRAMETU=#193;//<upsidedown
  cch_GFX_LFRAMECROSS=#197;
  cch_GFX_HFRAMETOPLEFT=#201; //< Heavy frames - Double lines or whatever
  cch_GFX_HFRAMETOPRIGHT=#187;
  cch_GFX_HFRAMEBOTTOMLEFT=#200;
  cch_GFX_HFRAMEBOTTOMRIGHT=#188;
  cch_GFX_HFRAMEHORIZONTAL=#205;
  cch_GFX_HFRAMEVERTICAL=#186;
  cch_GFX_HFRAMETLEFT=#204;
  cch_GFX_HFRAMETRIGHT=#185;
  cch_GFX_HFRAMET=#203;
  cch_GFX_HFRAMETU=#202;//<upsidedown
  cch_GFX_HFRAMECROSS=#206;
  cch_GFX_DOT1=#250; //< light dot
  cch_GFX_DOT2=#254; //< square dot
  cch_GFX_DOT3=#249; //< Heavy Round Dot
  cch_GFX_DOT4=#240; //< HEAVY Square
  cch_GFX_CURLYBRACELEFT=#123;
  cch_GFX_CURLYBRACERIGHT=#125;
  cch_GFX_PIPE=#124;
  cch_GFX_CHECKMARK=#251;
{$ELSE}
  cch_GFX_LARROWUP = '^';  //< LIGHT Arrows
  cch_GFX_LARROWDOWN = 'v';
  cch_GFX_LARROWLEFT = '<';
  cch_GFX_LARROWRIGHT = '>';
  cch_GFX_HARROWUP = '^';  //< Heavy Arrows
  cch_GFX_HARROWDOWN = 'v';
  cch_GFX_HARROWLEFT = '<';
  cch_GFX_HARROWRIGHT = '>';
  cch_GFX_SHADE1 = ' ';
  cch_GFX_SHADE2 = ' ';
  cch_GFX_SHADE3 = ' ';
  cch_GFX_SOLID = ' ';
  cch_GFX_HALFTOP = ' ';
  cch_GFX_HALFBOTTOM = ' ';
  cch_GFX_HALFLEFT = ' ';
  cch_GFX_HALFRIGHT=' ';
  cch_GFX_LFRAMETOPLEFT='+'; //< LIGHT Frames - single line or whatever
  cch_GFX_LFRAMETOPRIGHT='+';
  cch_GFX_LFRAMEBOTTOMLEFT='+';
  cch_GFX_LFRAMEBOTTOMRIGHT='+';
  cch_GFX_LFRAMEHORIZONTAL='+';
  cch_GFX_LFRAMEVERTICAL='+';
  cch_GFX_LFRAMETLEFT='+';
  cch_GFX_LFRAMETRIGHT='+';
  cch_GFX_LFRAMET='+';
  cch_GFX_LFRAMETU='+';//<upsidedown
  cch_GFX_LFRAMECROSS=' ';
  cch_GFX_HFRAMETOPLEFT='*'; //< Heavy frames - Double lines or whatever
  cch_GFX_HFRAMETOPRIGHT='*';
  cch_GFX_HFRAMEBOTTOMLEFT='*';
  cch_GFX_HFRAMEBOTTOMRIGHT='*';
  cch_GFX_HFRAMEHORIZONTAL='*';
  cch_GFX_HFRAMEVERTICAL='*';
  cch_GFX_HFRAMETLEFT='*';
  cch_GFX_HFRAMETRIGHT='*';
  cch_GFX_HFRAMET='*';
  cch_GFX_HFRAMETU='*';//<upsidedown
  cch_GFX_HFRAMECROSS='*';
  cch_GFX_DOT1='.'; //< light dot
  cch_GFX_DOT2='.'; //< square dot
  cch_GFX_DOT3='.'; //< Heavy Round Dot
  cch_GFX_DOT4='#'; //< HEAVY Square
  cch_GFX_CURLYBRACELEFT='(';
  cch_GFX_CURLYBRACERIGHT=')';
  cch_GFX_PIPE='|';
  cch_GFX_CHECKMARK='X';
{$ENDIF}
//=============================================================================







//=============================================================================
{}
Const
//=============================================================================
  {}
  // ------------------------ Mouse Related --------------
  {}
  MouseActionDown   = MouseActionDown   ;{< Mouse down event }
  MouseActionUp     = MouseActionUp     ;{< Mouse up event }
  MouseActionMove   = MouseActionMove   ;{< Mouse move event }

  MouseLeftButton   = MouseLeftButton   ;{< Left mouse button }
  MouseRightButton  = MouseRightButton  ;{< Right mouse button }
  MouseMiddleButton = MouseMiddleButton ;{< Middle mouse button }

  // ------------------------ Video Releated -------------
  {}
  CR = #13;
  LF = #10;
  CRLF = CR+LF;

  {$IFNDEF LINUX}
  {$IFNDEF DROPWIN32}
  cpUnderline=cpUnderline; //< Capability Flags
  cpBlink=cpBlink; //< Capability Flags
  cpColor=cpColor; //< Capability Flags
  cpChangeFont=cpChangeFont; //< Capability Flags
  cpChangeMode=cpChangeMode; //< Capability Flags
  cpChangeCursor=cpChangeCursor; //< Capability Flags
  {$ENDIF}
  {$ENDIF}

  crBlock=crBlock; //< Cursor Shapes
  crHalfBlock=crHalfBlock; //< Cursor Shapes
  crUnderline=crUnderline; //< Cursor Shapes
  crHidden=crHidden; //< Cursor Shapes

  Black         = Black; //< can be used as foreground and background colors.
  Blue          = Blue; //< can be used as foreground and background colors.
  Green         = Green; //< can be used as foreground and background colors.
  Cyan          = Cyan; //< can be used as foreground and background colors.
  Red           = Red; //< can be used as foreground and background colors.
  Magenta       = Magenta; //< can be used as foreground and background colors.
  Brown         = Brown; //< can be used as foreground and background colors.
  LightGray     = LightGray; //< can be used as foreground and background colors.

  DarkGray      = DarkGray; //< can be used as foreground colors only
  LightBlue     = LightBlue; //< can be used as foreground colors only
  LightGreen    = LightGreen; //< can be used as foreground colors only
  LightCyan     = LightCyan; //< can be used as foreground colors only
  LightRed      = LightRed; //< can be used as foreground colors only
  LightMagenta  = LightMagenta; //< can be used as foreground colors only
  Yellow        = Yellow; //< can be used as foreground colors only
  White         = White; //< can be used as foreground colors only

  // ------------------------ Keyboard Related --------------
  {}
  kbdF1 = kbdF1;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF2 = kbdF2;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF3 = kbdF3;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF4 = kbdF4;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF5 = kbdF5;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF6 = kbdF6;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF7 = kbdF7;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF8 = kbdF8;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF9 = kbdF9;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdF10 = kbdF10;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF11 = kbdF11;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF12 = kbdF12;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF13 = kbdF13;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF14 = kbdF14;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF15 = kbdF15;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF16 = kbdF16;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF17 = kbdF17;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF18 = kbdF18;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF19 = kbdF19;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdF20 = kbdF20;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdHome = kbdHome;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbdUp = kbdUp;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out o
n each platform and implemented appropriately in this unit.}
  kbdPgUp = kbdPgUp;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbdLeft = kbdLeft;          {<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be
 figured out on each platform and implemented appropriately in this unit.}
  kbdMiddle = kbdMiddle;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figur
ed out on each platform and implemented appropriately in this unit.}
  kbdRight = kbdRight;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured
 out on each platform and implemented appropriately in this unit.}
  kbdEnd = kbdEnd;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbdDown = kbdDown;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbdPgDn = kbdPgDn;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbdInsert = kbdInsert;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figur
ed out on each platform and implemented appropriately in this unit.}
  kbdDelete = kbdDelete;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figur
ed out on each platform and implemented appropriately in this unit.}
  kbAscii = kbAscii;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbUniCode = kbUniCode;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figur
ed out on each platform and implemented appropriately in this unit.}
  kbFnKey = kbFnKey;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured o
ut on each platform and implemented appropriately in this unit.}
  kbPhys = kbPhys;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be figured out
 on each platform and implemented appropriately in this unit.}
  kbReleased = kbReleased;{<Declaration brought over from fpc keyboard unit. Note these are under the different platform to platform.. but is handled for you. More complex key combinations are a maintenance issue - like CNTL+F1 for example needs to be fig
ured out on each platform and implemented appropriately in this unit.}


//=============================================================================

//=============================================================================
{}
Var //< Available to Programs that use this unit.
//=============================================================================
  {}
  rLKey: rtKeyPress;
  rLMEvent: rtMEvent;
  rPollMouseEvent: TMouseEvent;
  ConsoleUnitInitialized: Boolean;
  giConsoleWidth: LongInt;
  giConsoleHeight: LongInt;

  gsaTerm: AnsiString;
  gbConsoleDebugLog: Boolean; //< used by DEBUGLOGBEGINEND


//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                  UNIT Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
{}
Function InitConsole:Boolean; //< Initialize Unit
Procedure DoneConsole; //< ShutDown Unit
{}
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                     Exported Keyboard Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
{}
Function KeyHit: Boolean;
Procedure GetKeyPress;
Procedure TurnOffCNTLC;
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                        Exported Mouse Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
{}
Function HaveM: Boolean;
Function MButtons: LongInt;
Procedure HideMCursor;
Procedure ShowMCursor;
Function GetMEvent:rtMEvent;
Function MEvent: Boolean;
Function GetMX: Word; //< not reliable in windows
Function GetMY: Word; //< not reliable in windows
Function GetMButtons: Word;
Procedure SetMXY(x,y:Word);
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                     Exported Console Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
{}
Procedure UpdateConsole;
Procedure RedrawConsole;
Function GetConsoleLockCount: LongInt;
Procedure AddConsoleLock;
Procedure RemoveConsoleLock;
Function GetConsoleCapabilities: Word;
Procedure GetConsoleDriver(Var Driver: rtConsoleDriver);
Procedure GetConsoleMode(Var Mode: rtConsoleMode);
Function GetConsoleModeCount: Word;
Function GetConsoleModeData(Index: Word; Var Data: rtConsoleMode):Boolean;
Function SetConsoleDriver(Const Driver: rtConsoleDriver):Boolean;
Function SetConsoleMode(mode:rtConsoleMode):Boolean;
{< NOTE: SetCursorType is normally managed TOTALLY within the UNIT,
but sometimes its needed to FORCE the cursor to show for
unclean closing of programs.}
Procedure ForceCursorType(CursorType:Word);
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                  Exported Virtual Console Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
// Four Polymorphed Versions of NewVC
//-----------------------------------------------------------------------------
{}
Function NewVC:UINT; //< Creates VC with W,H = giConsoleWidth x giConsoleHeight
{}
//-----------------------------------------------------------------------------
{}
Function NewVC(p_iVWidth, p_iVHeight: LongInt):UINT;
{}
//-----------------------------------------------------------------------------
{}
Function NewVC(p_iX, p_iY,p_iVWidth, p_iVHeight: Longint):UINT;
//-----------------------------------------------------------------------------
{}
Function NewVC(p_iX, p_iY,p_iVWidth, p_iVHeight: Longint;p_u1VFGC, p_u1VBGC: Byte):UINT;
//-----------------------------------------------------------------------------
{}
Procedure RemoveVC(p_uVCUID: UINT);
Function  GetVCCount: LongInt;
Procedure BringVCToTop(p_uVCUID: UINT);
Procedure SetActiveVC(p_uVCUID: UINT);
Function  GetActiveVC: UINT;
Procedure VCClear;
Function VCWidth: LongInt;
Function VCHeight: LongInt;
Function VCCursorType: Word;
Procedure VCSetCursorType(p_wCursorType: Word);
Procedure VCSetCursorXY(p_iX, p_iY: LongInt);
Function VCGetCursorX: LongInt;
Function VCGetCursorY: LongInt;

Procedure VCSetFGC(p_u1FGC: Byte);
Procedure VCSetBGC(p_u1BGC: Byte);
Procedure VCSetPenXY(p_iX, p_iY:LongInt);
Procedure VCSetPenX(p_iX:LongInt);
Procedure VCSetPenY(p_iY:LongInt);
Procedure VCPutChar(p_iX, p_iY: LongInt; p_ch:Char);
Procedure VCPutBGC(p_iX, p_iY: LongInt; p_u1BGC:Byte);
Procedure VCPutFGC(p_iX, p_iY: LongInt; p_u1FGC:Byte);
{}
// PolyMorphed VCPutAll
{}
Procedure VCPutAll(p_iX, p_iY: LongInt; p_wAll:Word);
Procedure VCPutAll(p_iX, p_iY: LongInt; P_ch: Char; p_byFG, p_byBG: Byte);
Function VCGetChar(p_iX, p_iY: LongInt): Char;
Function VCGetBGC(p_iX, p_iY: LongInt):Byte;
Function VCGetFGC(p_iX, p_iY: LongInt):Byte;
Function VCGetAll(p_iX, p_iY: LongInt):Word;
Procedure VCWriteCharXY(p_iX, p_iY: LongInt; p_ch:Char);
Procedure VCWriteChar(p_Char: Char);
Procedure VCWrite(sa:AnsiString);
Procedure VCWriteln;
Procedure VCWriteln(sa:AnsiString);
Procedure VCWriteXY(X,Y: LongInt; sa: AnsiString) ;
Procedure VCWriteCTR(sa:AnsiString);
Procedure VCClrEol;
Function VCGetCenterX(p_iWidth: LongInt): LongInt;
Function VCGetCenterY(p_iHeight: LongInt): LongInt;
Procedure VCFillBox(X,Y: LongInt;W,H: LongInt; ch:Char);
Procedure VCFillBoxCTR(W,H: LongInt; ch:Char);
Procedure VCFillBoxChar(X,Y: LongInt;W,H: LongInt; ch:Char);
Procedure VCFillBoxCharCTR(W,H: LongInt; ch:Char);
Procedure VCFillBoxFGC(X,Y: LongInt;W,H: LongInt; p_u1FGC:Byte);
Procedure VCFillBoxFGCCTR(W,H: LongInt; p_u1FGC:Byte);
Procedure VCFillBoxBGC(X,Y: LongInt;W,H: LongInt; p_u1BGC:Byte);
Procedure VCFillBoxBGCCTR(W,H: LongInt; p_u1BGC:Byte);
Procedure VCSetXY(p_iX, p_iY:LongInt);
Function VCGetX: LongInt;
Function VCGetY: LongInt;
Function VCGetPenX: LongInt;
Function VCGetPenY: LongInt;
Function VCGetPenFGC: Byte;
Function VCGetPenBGC: Byte;
Function VCGetInfo: rtVCInfo;
Procedure VCSetInfo(p_rVCInfo: rtVCInfo);
Procedure VCSetTransparency(p_bTransparency:Boolean);
Function VCGetTransparency:Boolean;
Procedure VCSetTabsize(p_iTabsize: LongInt);
Function VCGetTabSize: LongInt;
Procedure VCSetWrap(p_bWrap: Boolean);
Function VCGetWrap:Boolean;
//procedure VCSetScroll(p_iX, p_iY, p_iW, p_iH:LongInt);
Procedure VCScrollUp;
Procedure VCScrollDown;
Procedure VCScrollLeft;
Procedure VCScrollRight;
Procedure VCSNRBoxCTR(W,H: LongInt; chfind,chreplace:Char);
Procedure VCSNRBox(X,Y: LongInt;W,H: LongInt; chfind,chreplace:Char);
Procedure VCSetOpaqueFG(p_bOpaque: Boolean);
Function VCGetOpaqueFG: Boolean;
Procedure VCSetOpaqueBG(p_bOpaque: Boolean);
Function VCGetOpaqueBG: Boolean;
Procedure VCResize(p_iNewWidth, p_iNewHeight: LongInt);
Procedure VCSetVisible(p_b:Boolean);
Function VCGetVisible:Boolean;
Procedure VCSetTrackCursor(p_bTrackCursor: Boolean);
Function VCGetTrackCursor:Boolean;
Procedure SyncAllVC;
{< Causes next UpdateConsole or RedrawConsole to Redraw all the VC's in the
 VideoBuffer. This added to deal with situations where special effects like
 opaque and transparencies don't appear correctly.

 These "incorrect" situations are simply that a VC's CELL is made
 transparent (entirely or just foreground or background colors)
 remain that way visually until the screen buffer is recalculated.
 This is for efficency. There is a routine to FIX (or recalculate the
 screen buffer for one cell), called "VCRedrawCell", but it would slow the
 main drawing routines if it was added to the main logic to keep verifying
 - one char at a time - if a transparency  has changed and recalculating it
 individually. This is much slower in cases where many transparency chars
 have changed. Recalculating the screen the way the "SyncAllVC" causes is
 much faster than using RedrawCH. The bottom line is VCRedrawCell is faster
 than the Syncronization that SyncAllVC causes, but VCRedrawCell for one
 character is MUCH faster than SyncAll VC. You - "The Programmer" have
 to decide when to do which. SyncAllVC is plenty fast enough for all
 normal text based applications. Animations are when this is most important
 to consider. Sorry - to write a book - but I wanted to document enough
 information to allow "you" the programmer to understand this unit as
 well as know how best to leverage its design to your benefit.
 Below is a list of routines that cause this syncronization to occur.

 Other routines that cause this syncronization to occur before the next
 UpdateConsole or RedrawConsole are as follows:

   --Routines         -- Providing the VC was...
   NewVC            - OnScreen made on the screen

   RemoveVC         - On Screen & VC Visible

   BringVCToTop     - On Screen & VC Visible

   VCSetXY          - On Screen before or after move & VC Visible

   VCResize         - On Screen before or after resize & VC Visible

   VCSetVisible      - On Screen & Actually Toggled ( Calling VCSetVisible(true)
                      when it is already true will NOT cause SyncAllVC to be
                      called. )

   VCSetTransparency- On Screen & VC Visible & Actually Toggled
                      ( Calling VCSetTransparency(true) when it is already
                      true will NOT cause SyncAllVC to be called. )

   VCSetOpaqueFG    - On Screen & VC Visible & Actually Toggled
                      ( Calling VCSetOpaqueFG(true) when it is already
                      true will NOT cause SyncAllVC to be called. )

   VCSetOpaqueBG    - On Screen & VC Visible = False & Actually Toggled
                      ( Calling VCSetOpaqueBG(true) when it is already
                      true will NOT cause SyncAllVC to be called. )

   VCSetOpaqueCH    - On Screen & VC Visible = False & Actually Toggled
                      ( Calling VCSetOpaqueCH(true) when it is already
                      true will NOT cause SyncAllVC to be called. )

   VCSetInfo        - This routine is a global way to change VC parameters
                      and as such calls the following routines if the
   (Special)          passed parameters have changed from thier previous
                      settings: VCSetXY, VCResize, VCSetTransparency,
                      VCSetOpaqueFG, VCSetOpaqueBG, and VCSetVisible.}
Procedure VCSetScrollRegion(p_X, p_Y, p_W, p_H: LongInt);
Procedure VCGetScrollRegion(Var p_X, p_Y, p_W, p_H: LongInt);
Procedure VCSetScroll(p_bEnabled: Boolean);
Function VCGetScroll: Boolean;
Procedure VCSetOpaqueCh(p_bOpaque: Boolean);
Function VCGetOpaqueCH:Boolean;
Procedure VCSetUseScrollRegionCoords(p_b: Boolean);
Function VCGetUseScrollRegionCoords: Boolean;
// Return Z Position of Current VC (Remember TopMost is GetVCCount result)
Function VCGetZ: LongInt;
// Return VC UID of Specific Z Position
Function GetVCZ(p_Z: LongInt): LongInt;
// Return Z order position for Specific VC
Function GetZVC(p_VC: LongInt): LongInt;
// uses current Pen Position
Procedure VCWordWrap(p_iWidth,p_iHeight: LongInt; p_saMsg: AnsiString);
// use to draw with background colors only on a transparency VC
// use string chars 0-7 to make background color, spaces=holes
Procedure VCDrawBGXY(px,py: LongInt;sa:AnsiString);
// This routine starts at 0 Zbuff (nothing) and works up to the ZBuffer Top
// Performance Good for minimal updates (Maybe)}
Procedure VCRedrawCell(p_vx,p_vy:LongInt); //< parameters ONE BASED VC
{}
//procedure VCUpdateCursor; // causes System to recalculate and appropriately
//                          // Display the Blinky cursor for Active VC if valid
//=============================================================================
{}
// This proc BOOKMARKS the Current VC, effectively having no effect on what ever
// you had as current, switches to the VC you tell it, toggles the visible flag,
// and then sets the "current" working VC to what it was before you made this
// call. Its just a conveinant way to hide/unhide any VC anytime without
// needing To Write PREPARATION code to Save You Current VC, Set the New VC,
// toggle the Visible Flag, and then Set Back the VC I was on before... etc.
Procedure ToggleVCVisible(p_VC:LongInt);
//=============================================================================













//=============================================================================
{}
Type TVCXDLITEM = Class(JFC_XDLITEM)
//=============================================================================
  {}
  Protected
  //uUID: LongInt; // Unique Identifier of VC
  //UID: LongInt;
  {}
  iZorder: LongInt;

  VX: LongInt;  //< Virtual Screen coords Relative to Real Video Screen
  VY: LongInt;
  VW: LongInt; //< Width of Virtual Screen
  VH: LongInt; //< Height of Virtual Screen
  {$IFDEF LESSFRAG}
    MAXMEM: LongInt; //< largest Width*height
  {$ENDIF}
  VPX: LongInt; //< Virtual Screen Pen Coords Relative to Real Video Screen
  VPY: LongInt;
  VCX: LongInt; //< Virtual Screen Blinky Cursor Relative to Real Video Screen
  VCY: LongInt;
  VCursorType: Word;
  VFGC: Byte;
  VBGC: Byte;
  VTabSize: Byte;
  VWrap: Boolean; //< Word Wrap Flag
  VTransparency: Boolean;
  VSX: LongInt;//<scroll window coords
  VSY: LongInt;
  VSW: LongInt;
  VSH: LongInt;
  VOpaqueFG: Boolean;
  VOpaqueBG: Boolean;
  VVisible:Boolean;
  VTrackCursor:Boolean;
  VScroll:Boolean;
  VOpaqueCh: Boolean;
  VUseScrollRegionCoords: Boolean;
  VBuf: ^Word; //< Buffer
  Public
  Procedure CreateVC(p_iVWidth, p_iVHeight:LongInt);
  Destructor Destroy; override;
  Procedure Resize(p_iNewWidth, p_iNewHeight:LongInt);
  Function bOnscreen: Boolean;
End;
//=============================================================================

//=============================================================================
Type TVCXDL = Class(JFC_XDL)
//=============================================================================
  public
    Function pvt_CreateItem: TVCXDLITEM; override;
    Procedure pvt_DestroyItem(p_ptr:pointer); override;
    Function read_item_VCID: UINT;
    Procedure write_item_VCID(p_u:UINT);
    Property Item_VCID: UINT read read_item_VCID
                            Write write_item_VCID;
    Function FoundItem_VCID(p_u: UINT):Boolean;
    Function FoundItem_iZOrder(p_iZOrder: LongInt):Boolean;
End;
//=============================================================================

//=============================================================================
Var
//=============================================================================
  {}
  VC: TVCXDL;
  ActiveVC: UINT;
  uMSButtons: LongInt;
  MG: ^UINT; //< Mouse Grid has UID of VC
  bInvalid: Boolean; //< used to call CopyAllVCToVideo in UpdateConsole proc
  CursorX, CursorY: LongInt;
  CursorType: Word;//<physical blinky
  ConsoleCapabilities: Word;
  RVM: TVideoMode;
  //  rMEvent: rtMEvent;
{}

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






//=============================================================================
//const
//=============================================================================
//  cn_VCTabsize =8;
//  cb_VCWrap =true;
//  cb_VCTransparency =false;
//  cn_VCCursorType = crUnderline;
//=============================================================================















//{IFDEF DEBUGLOGBEGINEND}
////=============================================================================
//Procedure DebugIN(sa: AnsiString,SOURCEFILE);
////=============================================================================
////var tempvc:LongInt;
//Begin
//  If gbConsoleDebugLog Then
//  Begin
//    Jlog(cnLog_Debug,201202011742,StringOfChar(' ',5)+'|'+StringOfChar('.',giNestLevel)+sa+ ' ' +
//      StringOfChar('-',40-length(sa)) +' Begin', SOURCEFILE);
//    giNestLevel+=1;
//  End;
//
//  {if ActiveVC=6 then
//  Begin
//    tempvc:=VC.Item_VCID;
//    VC.FoundItem_iVCID(ActiveVC);
//    Jlog(cnLog_Debug,201202017423,'DebugIN-TrackCursor:'+inttostr(TVCXDLITEM(VC.lpItem).VCX));
//    VC.FoundItem_iVCID(TempVC);
//  End;
//  }
//End;
////=============================================================================
////=============================================================================
//Procedure DebugOUT(sa: AnsiString,SOURCEFILE,SOURCEFILE);
////=============================================================================
//Begin
//  If gbConsoleDebugLog Then
//  Begin
//    giNestLevel-=1;
//    Jlog(cnLog_Debug,201202017424,StringOfChar(' ',5)+'|'+StringOfChar('.',giNestLevel)+sa+ ' ' +
//      StringOfChar('-',40-length(sa)) +' End', SOURCEFILE);
////    Jlog(cnLog_Debug,201202017425,StringOfChar(' ',5)+'|'+StringOfChar('.',giNestLevel)+sa+ ' ' +
////      StringOfChar('-',40-length(sa)) +' End');
//  End;
//End;
////=============================================================================
//{ENDIF}
//
//




// Private Implementation Declarations Above
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
// Private Procs and functions below (Private Class Code Below Exported stuff)






//=============================================================================
Procedure ThrowItInMem(VBufOfs, VideoOFs: LongInt);
//=============================================================================
//var MX, MY: LongInt;
//    bMouseInWay: boolean;
Var iVBufLoByte: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('ThrowItInMem',SOURCEFILE);
{$ENDIF}

  //bMouseInWay:=false;
  //if VideoOfs = (getMouseX + GetMouseY * giConsoleWidth) then
  //begin
  //  bMouseInWay:=true;
  //  MX:=GetMouseX;
  //  MY:=GetMouseY;
  //  if VideoOfs=0 then
  //    SetMouseXY(1,1)
  //  else
  //    SetMouseXY(0,0);
  //end;

  iVBufLoByte:= TVCXDLITEM(VC.lpItem).VBuf[VBufOfs] and $00ff;

  // Update Mouse Grid With VC.Item_VCID if not transparent
  If ((not TVCXDLITEM(VC.lpItem).VTransparency) and (TVCXDLITEM(VC.lpItem).VOpaqueCH))
     OR
     (TVCXDLITEM(VC.lpItem).VTransparency and
     (iVBufLoByte>3))
  Then MG[VideoOfs]:=VC.Item_VCID;

  // Foreground Color
  If (TVCXDLITEM(VC.lpItem).VOpaqueFG)
     and
     (
       (not TVCXDLITEM(VC.lpItem).VTransparency)
       OR
       (
        (TVCXDLITEM(VC.lpItem).VTransparency) and
        ((iVBufLoByte>3) OR ((iVBufLoByte and 1)=1))
       )
     ) Then
  Begin
    VideoBuf^[VideoOfs]:=
      (VideoBuf^[VideoOfs] and $F0FF)+
      (TVCXDLITEM(VC.lpItem).VBuf[VBufOfs] and $0F00);
  End;

  // Background Color
  If (TVCXDLITEM(VC.lpItem).VOpaqueBG)
     and
     (
       (not TVCXDLITEM(VC.lpItem).VTransparency)
       OR
       (
        (TVCXDLITEM(VC.lpItem).VTransparency) and
        ((iVBufLoByte>3) OR ((iVBufLoByte and 2)=2))
       )
     ) Then
  Begin
    VideoBuf^[VideoOfs]:=
      (VideoBuf^[VideoOfs] and $0FFF)+
      (TVCXDLITEM(VC.lpItem).VBuf[vbufofs] and $F000);
  End;

  // now the character itself
  // Foreground Color
  If (TVCXDLITEM(VC.lpItem).VOpaqueCh)
     and
     (
       (not TVCXDLITEM(VC.lpItem).VTransparency)
       OR
       (
        (TVCXDLITEM(VC.lpItem).VTransparency) and
        (iVBufLoByte>3)
       )
     ) Then
  Begin
    VideoBuf^[videoofs]:=
      (VideoBuf^[videoofs] and $FF00)+iVBufLoByte;
  End;

  //if bMouseInWay then SetMouseXY(mx,my);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('ThrowItInMem',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================






{
// Original - Works on Active VC only
//=============================================================================
Procedure UpdateCursor;
//=============================================================================
Var cx,cy: LongInt;
Begin
  //if GetVCCount>0 then
  //begin
    cx:=(TVCXDLITEM(VC.lpItem).VX+TVCXDLITEM(VC.lpItem).VCX-2);
    cy:=(TVCXDLITEM(VC.lpItem).VY+TVCXDLITEM(VC.lpItem).VCY-2);

    If (cx>-1) and (cx<giConsoleWidth) and (cy>-1) and (cy<giConsoleHeight) and
       (MG[cx+cy*giConsoleWidth]=ActiveVC) Then
    Begin
      If (cx<>CursorX) OR (cy<>CursorY) Then SetCursorPos(cx,cy);
      If CursorType<>TVCXDLITEM(VC.lpItem).VCursorType Then
        SetCursorType(TVCXDLITEM(VC.lpItem).VCursorType);
      CursorX:=cx; CursorY:=cy;
      CursorType:=TVCXDLITEM(VC.lpItem).VCursorType;
    End
    Else
    Begin
      If CursorType<>crHidden Then SetCursorType(crHidden);
      CursorType:=crHidden;
    End;
  //end;
End;
//=============================================================================
}




//debugcode//// New Version - Recalculates based on ZBuffer - Highest one
//debugcode//// with a physically visible (onscreen) and non-hidden attribute gets it
//debugcode//// Starts at Bottom of ZBuffer.
//debugcode////=============================================================================
//debugcode//procedure UpdateCursor;
//debugcode////=============================================================================
//debugcode//var cx,cy: LongInt;
//debugcode//    t: LongInt;
//debugcode//    NewCX, NewCY, NewCT: word;
//debugcode//begin
//debugcode//{IFDEF DEBUGLOGBEGINEND}
//debugcode//  DebugIN('UpdateCursor',SOURCEFILE);
//debugcode//{ENDIF}
//debugcode//
//debugcode////  Jlog(cnLog_Debug,201202017426,'UpdateCursor Begin -------------------------------------------');
//debugcode//  if VC.ListCount>0 then
//debugcode//  begin
//debugcode//    NewCX:=CursorX; NewCY:=CursorY; NewCT:=crHidden;
//debugcode//    for t:=1 to VC.ListCount do
//debugcode//    begin
//debugcode////      Jlog(cnLog_Debug,201202017427,'************************************');
//debugcode//      if VC.FoundID(t,1) then
//debugcode//      begin
//debugcode//
//debugcode////if VC.Item_VCID=6 then
//debugcode////begin
//debugcode////        Jlog(cnLog_Debug,201202017428, '+++Updatecursor - T:'+inttostr(T) +
//debugcode////                 ' VC.Item_VCID: ' + inttostr(VC.Item_VCID));
//debugcode////        Jlog(cnLog_Debug,201202017429,'+++VC Z Level:'+inttostr(TVCXDLITEM(VC.lpItem).iZOrder));
//debugcode////end;
//debugcode//        cx:=(TVCXDLITEM(VC.lpItem).VX-1)+(TVCXDLITEM(VC.lpItem).VCX-1);
//debugcode//        cy:=(TVCXDLITEM(VC.lpItem).VY-1)+(TVCXDLITEM(VC.lpItem).VCY-1);
//debugcode//
//debugcode////        cx:=1;
//debugcode////        cy:=1;
//debugcode//
//debugcode//
//debugcode//// if VC.Item_VCID=6 then
//debugcode//// begin
//debugcode////        Jlog(cnLog_Debug,201202017430,'+++VC X-1:'+inttostr(TVCXDLITEM(VC.lpItem).VX-1));
//debugcode////        Jlog(cnLog_Debug,201202017431,'+++VC Y-1:'+Inttostr(TVCXDLITEM(VC.lpItem).VY-1));
//debugcode////        Jlog(cnLog_Debug,201202017432,'+++VC VCX-1:'+inttostr(TVCXDLITEM(VC.lpItem).VCX-1));
//debugcode////        Jlog(cnLog_Debug,201202017433,'+++VC VCY-1:'+inttostr(TVCXDLITEM(VC.lpItem).VCY-1));
//debugcode////        Jlog(cnLog_Debug,201202017434,'+++Calc CX:'+inttostr(cx));
//debugcode////        Jlog(cnLog_Debug,201202017435,'+++Calc CY:'+inttostr(cy));
//debugcode////        Jlog(cnLog_Debug,201202017436,'+++MG[cx+cy*giConsoleWidth]:'+inttostr(MG[cx+cy*giConsoleWidth]));
//debugcode////        case TVCXDLITEM(VC.lpItem).VCursorType of
//debugcode////        crHidden:   Jlog(cnLog_Debug,201202017436,'+++VC''s Cursor Type: crHidden');
//debugcode////        crUnderline:Jlog(cnLog_Debug,201202017437,'+++VC''s Cursor Type: crUnderline');
//debugcode////        crBlock:    Jlog(cnLog_Debug,201202017438,'+++VC''s Cursor Type: crBlock');
//debugcode////        crHalfBlock:Jlog(cnLog_Debug,201202017439,'+++VC''s Cursor Type: crHalfBlock');
//debugcode////        end;//case
//debugcode//// end;
//debugcode//
//debugcode//        if (cx>-1) and (cx<giConsoleWidth) and
//debugcode//           (cy>-1) and (cy<giConsoleHeight) and
//debugcode//           (MG[cx+cy*giConsoleWidth]=VC.Item_VCID) and
//debugcode//           (TVCXDLITEM(VC.lpItem).VCursorType<>crHidden) and
//debugcode//           ((TVCXDLITEM(VC.lpItem).VCursorType <> NewCT) or
//debugcode//            (cx<>NewCX) or (cy<>NewCY)) then
//debugcode//        begin
//debugcode//          NewCX:=cx; NewCY:=cy; NewCT:=TVCXDLITEM(VC.lpItem).VCursorType;
//debugcode//          Jlog(cnLog_Debug,201202017440,'+++CHANGE');
//debugcode//        end
//debugcode//        else
//debugcode//        begin
//debugcode//          Jlog(cnLog_Debug,201202017441,'+++NO CHANGE');
//debugcode//        end;
//debugcode//
//debugcode//      end;
//debugcode//    end;
//debugcode//
//debugcode//    if (NewCX<>CursorX) or (NewCY<>CursorY) then
//debugcode//    begin
//debugcode//      SetCursorPos(NewCX,NewCY);
//debugcode//      CursorX:=NewCX; CursorY:=NewCY;
//debugcode////      Jlog(cnLog_Debug,201202017442,'+++SetCursorPos('+inttostr(newcx)+','+
//debugcode////                inttostr(newcy)+')');
//debugcode//    end;
//debugcode//
//debugcode//    if CursorType<>NewCT then
//debugcode//    begin
//debugcode//      SetCursorType(NewCT);
//debugcode//      CursorType:=NewCT;
//debugcode////      case NewCT of
//debugcode////      crHidden:   Jlog(cnLog_Debug,201202017443,'Setting CursorType: crHidden');
//debugcode////      crUnderline:Jlog(cnLog_Debug,201202017444,'Setting CursorType: crUnderline');
//debugcode////      crBlock:    Jlog(cnLog_Debug,201202017445,'Setting CursorType: crBlock');
//debugcode////      crHalfBlock:Jlog(cnLog_Debug,201202017446,'Setting CursorType: crHalfBlock');
//debugcode////      end;//case
//debugcode//    end;
//debugcode//    VC.FoundItem_iVCID(ActiveVC);
//debugcode//  end;
//debugcode//
//debugcode//
//debugcode////  SetCursorPos(1,1);
//debugcode////  SetCursorType(crUnderline);
//debugcode//
//debugcode////  Jlog(cnLog_Debug,201202017447,'ALL DONE - CursorX:'+inttostr(cursorx));
//debugcode////  Jlog(cnLog_Debug,201202017448,'ALL DONE - CursorY:'+inttostr(cursorY));
//debugcode////  case CursorType of
//debugcode////  crHidden:   Jlog(cnLog_Debug,201202017449,'ALL DONE - CursorType: crHidden');
//debugcode////  crUnderline:Jlog(cnLog_Debug,201202017450,'ALL DONE - CursorType: crUnderline');
//debugcode////  crBlock:    Jlog(cnLog_Debug,201202017451,'ALL DONE - CursorType: crBlock');
//debugcode////  crHalfBlock:Jlog(cnLog_Debug,201202017452,'ALL DONE - CursorType: crHalfBlock');
//debugcode////  end;//case
//debugcode//
//debugcode//
//debugcode//
//debugcode////  Jlog(cnLog_Debug,201202017453,'UpdateCursor End   -------------------------------------------');
//debugcode//
//debugcode//{IFDEF DEBUGLOGBEGINEND}
//debugcode//  DebugOUT('Updatecursor',SOURCEFILE);
//debugcode//{ENDIF}
//debugcode//
//debugcode//end;
//=============================================================================



// New Version - Recalculates based on ZBuffer - Highest one
// with a physically visible (onscreen) and non-hidden attribute gets it
// Starts at Bottom of ZBuffer.
//=============================================================================
Procedure UpdateCursor;
//=============================================================================
Var cx,cy: LongInt;
    t: LongInt;
    NewCX, NewCY, NewCT: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('UpdateCursor',SOURCEFILE);
{$ENDIF}

  If VC.ListCount>0 Then
  Begin
    NewCX:=CursorX; NewCY:=CursorY; NewCT:=crHidden;
    For t:=1 To VC.ListCount Do
    Begin
      If VC.FoundItem_iZOrder(t) Then
      //if VC.FoundItem_iVCID(t) then
      Begin
        cx:=(TVCXDLITEM(VC.lpItem).VX-1)+(TVCXDLITEM(VC.lpItem).VCX-1);
        cy:=(TVCXDLITEM(VC.lpItem).VY-1)+(TVCXDLITEM(VC.lpItem).VCY-1);

        If (cx>-1) and (cx<giConsoleWidth) and
           (cy>-1) and (cy<giConsoleHeight) and
           (MG[cx+cy*giConsoleWidth]=TVCXDLITEM(VC.lpITem).UID) and
           (TVCXDLITEM(VC.lpItem).VCursorType<>crHidden) and
           ((TVCXDLITEM(VC.lpItem).VCursorType <> NewCT) OR
            (cx<>NewCX) OR (cy<>NewCY)) Then
        Begin
          NewCX:=cx; NewCY:=cy; NewCT:=TVCXDLITEM(VC.lpItem).VCursorType;
        End;
      End;
    End;

    If (NewCX<>CursorX) OR (NewCY<>CursorY) Then
    Begin
      SetCursorPos(NewCX,NewCY);
      CursorX:=NewCX; CursorY:=NewCY;
    End;

    If CursorType<>NewCT Then
    Begin
      SetCursorType(NewCT);
      CursorType:=NewCT;
    End;
    VC.FoundItem_VCID(ActiveVC);
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('Updatecursor',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================








// relies on  valid MG
// one based
//=============================================================================
Procedure UpdateCh(X, Y: LongInt);
//=============================================================================
Var rx,ry: LongInt;//physical screen zero based
    vx,vy: LongInt;//Current VC zero based coords in vbuf
    VbufOFs: LongInt; // calculated Offset into VC's VBuf
    VideoOfs: LongInt; // calculated offset into VIDEOBUF and MouseGrid

//    ox,oy: LongInt;//Other VC's zero based coords in vbuf
    iP: LongInt;
    VCC: TVCXDL;
//    bDrawIt: boolean;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugIN('UpdateCH',SOURCEFILE);
  {$ENDIF}
{$ENDIF}

  // First, are we on the screen at all?
  If (TVCXDLITEM(VC.lpItem).VVisible) and
     (TVCXDLITEM(VC.lpItem).bOnScreen)
  Then
  Begin
    // Check if particular VC X,Y we are even on the screen by checking MG
    vx:=x-1;
    vy:=y-1;
    rx:=vx+TVCXDLITEM(VC.lpItem).VX-1;
    ry:=vy+TVCXDLITEM(VC.lpItem).VY-1;
    If (rx>-1) and (rx<giConsoleWidth) and
       (ry>-1) and (ry<giConsoleHeight) Then
    Begin
      // OK At this point RX and RY are Physical Screen Zero Based Coords
      // And the VX and VY MUST be 0 Based Coords WITHIN a VC zerobased buffer
      VCC:=TVCXDL.createcopy(vc);
      VideoOfs:=rx+ry*giConsoleWidth;
      VBufOfs:=VX+VY*TVCXDLITEM(VC.lpItem).VW;
      iP:=MG[VideoOfs];

      //if (VideoBuf^[videoofs] and $ff00)=Ord('?') then
      //begin
      //  Jlog(cnLog_Debug,201202017454,'consoledebug p='+inttostr(p));
      //  Jlog(cnLog_Debug,201202017455,'consoledebug VC.Item_VCID:'+inttostr(VC.Item_VCID));
      //  Jlog(cnLog_Debug,201202017456,'consoledebug VCC.FoundItem_iVCID(p):'+saTrueFalse(VCC.FoundItem_iVCID(p)));
      //  if VCC.FoundItem_iVCID(p) then
      //  begin
      //    Jlog(cnLog_Debug,201202017457,'consoledebug VCC.XXDL^.ID[1]:'+inttostr(VCC.XXDL^.ID[1]));
      //    Jlog(cnLog_Debug,201202017458,'consoledebug <');
      //    Jlog(cnLog_Debug,201202017459,'consoledebug VC.XXDL^.ID[1]:'+inttostr(VC.XXDL^.ID[1]));
      //  end;
      //end;


      If (ip=0) OR (TVCXDLITEM(VC.LpItem).UID=ip) OR
         (VCC.FoundItem_VCID(ip) and
          //qqq (TVCXDLITEM(VCC.lpitem).iZorder < TVCXDLITEM(VCC.lpItem).iZOrder)
          (TVCXDLITEM(VCC.lpitem).iZorder < TVCXDLITEM(VC.lpItem).iZOrder)
          ) Then
      Begin
        // Ok worth looking at because either we owned it before
        // or the owner is lower on the zbuffer
        // so we are ok to draw.
        ThrowItInMem(VBufOfs, VideoOFs);
      End;
      VCC.Destroy;
    End;
  End; // VC onscreen

{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugOUT('UpdateCH',SOURCEFILE);
  {$ENDIF}
{$ENDIF}

End;
//=============================================================================


// This routine starts at 0 Zbuff (nothing) and works up to the ZBuffer Top
// Performance Good for minimal updates (Maybe)
//=============================================================================
Procedure RedrawCH(p_rx,p_ry:LongInt); // parameters ZERO BASED Physical Scr.
//=============================================================================
Var //VCC: JFC_XXDL;
  zl: LongInt;
  vx, vy: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('RedrawCH',SOURCEFILE);
{$ENDIF}

  If (p_rx>-1) and (p_rx<giConsoleWidth) and (p_ry>-1) and (p_ry<giConsoleHeight) Then
  Begin
    If vc.listcount>0 Then
    Begin
      // First completely bottom out of ZBuffer
      //Jlog(cnLog_Debug,201202017460, 'console - RedrawCH - p_rx:'+inttostr(p_rx)+
      //                               ' p_ry:'+inttostr(p_ry));
      MG[p_rx + p_ry * giConsoleWidth]:=0;
      VideoBuf^[p_rx+p_ry * giConsoleWidth]:= (lightgray*256)+Ord('?');
      // now work backward through each VC using ZBuffer

      For zl:=1 To vc.listcount Do
      Begin
        VC.FoundItem_iZOrder(zl);
        //if not VC.FoundID(zl,1) then
        //begin
        //  Jlog(cnLog_Debug,201202017461,'Console Unit - RedrawCH - Missing ZBuf');
        //end;
        If (TVCXDLITEM(VC.lpItem).VVisible) and
           (TVCXDLITEM(VC.lpItem).bOnScreen) Then
        Begin
          vx:=p_rx-(TVCXDLITEM(VC.lpItem).vx-2);
          vy:=p_ry-(TVCXDLITEM(VC.lpItem).vy-2);
          //Jlog(cnLog_Debug,201202017462,'console - redraw - vx:'+inttostr(vx)+
          //          ' vy:'+inttostr(vy));

          If (vx>0) and (vx<=TVCXDLITEM(VC.lpItem).vw) and
             (vy>0) and (vy<=TVCXDLITEM(VC.lpItem).vh) Then
          Begin
            //Jlog(cnLog_Debug,201202017463,'Console - RedrawCH - Calling UpdateCH('+inttostr(vx)+','+
            //  inttostr(vy)+')');
            UpdateCH(vx,vy); // Draw the character
          End
          Else
          Begin
            //Jlog(cnLog_Debug,201202017464, 'console - RedrawCH - p_rx:'+inttostr(p_rx)+
            //                               ' p_ry:'+inttostr(p_ry));

            //Jlog(cnLog_Debug,201202017465,'Console - RedrawCH - Illegal Calling UpdateCH('+inttostr(vx)+','+
            //  inttostr(vy)+')');

          End;
        End;
      End;
      VC.FoundItem_VCID(ActiveVC);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('RedrawCH',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================







{
// ZERO BASED
//=============================================================================
Function bXYOnScreen(X,Y: LongInt):Boolean;
//=============================================================================
Begin
  If (x>-1) and (x<giConsoleWidth) and (y>-1) and (y<giConsoleHeight) Then
  Begin
    bXYOnScreen:=True;
  End
  Else
  Begin
    bXYOnScreen:=False;
  End;
End;
//=============================================================================
}


{
// scans MG for specified MG and does complete zordering of that char
//=============================================================================
Procedure UpdateMGbyUID(p_iUID: LongInt);
//=============================================================================
Var rx,ry: LongInt;
Begin
  For ry:=0 To giConsoleHeight-1 Do
  Begin
    For rx:=0 To giConsoleWidth-1 Do
    Begin
      If MG[rx+ry*giConsoleWidth]=p_iUID Then RedrawCH(rx,ry);
    End;
  End;
End;
//=============================================================================
}

{
//=============================================================================
Procedure CopyAllVCToVideo;
//=============================================================================
Var rx,ry: LongInt;
Begin
  For ry:=0 To giConsoleHeight-1 Do
  Begin
    For rx:=0 To giConsoleWidth-1 Do
    Begin
      RedrawCH(rx,ry);
    End;
  End;
End;
//=============================================================================
}

//=============================================================================
Procedure CopyAllVCToVideo;
//=============================================================================
Var vx,vy: LongInt;
    t: LongInt;
    rx, ry: LongInt;
    VideoOfs: LongInt;
    VBufOfs: LongInt;

Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('CopyAllToVCToVideo',SOURCEFILE);
{$ENDIF}

  // Start at BOTTOM of ZBuffer and work way to Top
  If VC.Listcount>0 Then // pretty sure this is precautionary
  Begin
    For t:=1 To VC.Listcount Do
    Begin
      VC.FoundItem_iZOrder(t); // Point VC to correct ZBuf
      If (TVCXDLITEM(VC.lpItem).VVisible) and
         (TVCXDLITEM(VC.lpItem).bOnScreen) Then
      Begin
        //------------------WORKS PERFECT-----------BEGIN
        // Now Go through VC and when the Translated X,Y is on the
        // physical Video, Mark the MG with the UID at the translated
        // coord, and copy the TVCXDLITEM.VBuf for that visible coord.
        For vy:=0 To TVCXDLITEM(VC.lpItem).VH-1 Do
        Begin
          For vx:=0 To TVCXDLITEM(VC.lpItem).VW-1 Do
          Begin
            rx:=(VX+TVCXDLITEM(VC.lpItem).VX-1);
            ry:=(VY+TVCXDLITEM(VC.lpItem).VY-1);
            If (rx>-1) and (rx<giConsoleWidth) and
               (ry>-1) and (ry<giConsoleHeight) Then
            Begin
              VideoOfs:=rx+ry*giConsoleWidth;
              VBufOfs:=VX+VY*TVCXDLITEM(VC.lpItem).VW;
              ThrowItInMem(VBufOfs, VideoOFs);
            End;
          End;
        End;
        //------------------WORKS PERFECT-----------END
      End; // onscreen
    End;
    // Should be pointing to Front Most ZOrdered VC
    VC.FoundItem_VCID(ActiveVC); // set back to active
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('CopyAllVcToVideo',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function CreateNewVC(p_iVWidth, p_iVHeight: LongInt):LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('CreateNewVC',SOURCEFILE);
{$ENDIF}

{$IFNDEF TIGHTCODE}
  Jlog(cnLog_Debug,201202011741,'about to append the new vc',SOURCEFILE);
{$ENDIF}
  VC.AppendItem;

{$IFNDEF TIGHTCODE}
  Jlog(cnLog_DEBUG,200609181217,'Past append',SOURCEFILE);
  Jlog(cnLog_DEBUG,201202011900,'createnewvc Does this match new item ptr?  vc.lpitem :'+inttostr(INT(vc.lpITem)),sourcefile);
  Jlog(cnLog_DEBUG,201202011902,'Autonumber''d field TVCXDLITEM(vc.lpITem).UID now says:'+inttostr(TVCXDLITEM(vc.lpITem).UID),sourcefile);
{$ENDIF}

  TVCXDLITEM(vc.lpITem).CreateVC(p_iVWidth, p_iVHeight);
  //Jlog(cnLog_Debug,2012020117466,'Past VC.PTR assign');
  SetActiveVC(VC.Item_VCID);   // Set New Console As Active
  //Jlog(cnLog_Debug,2012020117467,'CreateNewVC - Past SetActiveVC ActiveVC=' + inttostr(ActiveVC) + ' ' +
  //          'VC.Item_VCID='+inttostr(VC.Item_VCID));
  TVCXDLITEM(VC.lpitem).iZOrder:=VC.ListCount; // Move to top of ZBuffer
  //Jlog(cnLog_Debug,2012020117468,'Past Zbuffer ID[1] thing');

  //Jlog(cnLog_Debug,2012020117469,'New VC UID:'+inttostr(VC.Item_VCID)+' Z:'+inttostr(VC.XXDL^.ID[1]));
  Result:=VC.Item_VCID;
  //Jlog(cnLog_Debug,2012020117470,'Past result assignment');
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('CreateNewVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure PrepareScroll(Var sx, sy, sw, sh: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('PrepareScroll',SOURCEFILE);
{$ENDIF}

  If TVCXDLITEM(VC.lpItem).VUseScrollRegionCoords Then
  Begin
    sx:=TVCXDLITEM(VC.lpItem).VSX;
    sy:=TVCXDLITEM(VC.lpItem).VSY;
    sw:=TVCXDLITEM(VC.lpItem).VSW;
    sh:=TVCXDLITEM(VC.lpItem).VSH;
  End
  Else
  Begin
    sx:=1;
    sy:=1;
    sw:=TVCXDLITEM(VC.lpItem).VW;
    sh:=TVCXDLITEM(VC.lpItem).VH;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('PrepareScroll',SOURCEFILE);
{$ENDIF}

End;
//=============================================================================


{$IFDEF WIN32}
//=============================================================================
Function NewHandlerRoutine(ASignal: dword): LongBool; stdcall;
//=============================================================================
Var rKeyRecord: TKeyRecord;
Begin
  If (ASignal = CTRL_C_EVENT) Then
  Begin
    LongInt(rKeyrecord):=0;
    rKeyRecord.KeyCode:=3;
    rKeyRecord.shiftstate:=kbctrl;
    putkeyevent(LongInt(rkeyrecord));
    Result := True;
  End
  Else
  Begin
    Result := False;
  End;
End;
//=============================================================================
{$ENDIF}





// Private Procs and functions Above (Private Class Code Below Exported stuff)
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
// Exported Procs and Functions Below

//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                  Exported Global UNIT Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=


//=============================================================================
Function InitConsole: Boolean;
//=============================================================================
Var bInitError: Boolean;
    iInitErrorCode: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('InitConsole',SOURCEFILE);
{$ENDIF}
  bInitError:= False;
  If not ConsoleUnitInitialized Then
  Begin
    DoneVideo;
    ConsoleCapabilities:=GetCapabilities;
    InitVideo;
    iInitErrorCode:=Errorcode;
    If iInitErrorCode<>0 Then
    Begin
      bInitError:=True;
      {$IFNDEF TIGHTCODE}
      Jlog(cnLog_Debug,201202011903,'Error - u01c_Console.pp - Unit Init VIDEO Failed ErrorCode: ' +
        Inttostr(iInitErrorCode),SOURCEFILE);
      {$ENDIF}
    End;

    If not bInitError Then
    Begin
      giConsoleWidth:=ScreenWidth;
      giConsoleHeight:=ScreenHeight;
      If giConsoleWidth>132 Then giConsoleWidth:=132;
      {$IFDEF WIN32}
      If giConsoleHeight>50 Then giConsoleHeight:=50;
      {$ENDIF}


      InitMouse;
      iInitErrorCode:=ErrorCode;
      If iInitErrorCode=errMouseNotImplemented Then
      Begin
        uMSButtons:=0;
        ErrorCode:=0;
      End
      Else
      Begin
        uMSButtons:=DetectMouse;
      End;
      // SizeOf used to determine endian - and do 4 for 32bits, 8 for 64bits.
      GetMem(MG, giConsoleWidth * giConsoleHeight * SizeOf(pointer)); // Mouse Grid of UID's
      bInitError:=(MG=nil);

      If bInitError Then
      Begin
        {$IFNDEF TIGHTCODE}
        Jlog(cnLog_Error,201202011904,'Error - u01c_Console.pp - Couldn''t allocate mem for mousegrid',SOURCEFILE);
        {$ENDIF}
      End
      Else
      Begin
        // ShowMouse; // was hoping this would make a difference on linux
                      // console - didnt help
        VC:=TVCXDL.create;
        //Jlog(cnLog_Debug,2012020117471,'made vc(JFCxxdl) VC nil?'+inttostr(LongInt(VC)));
        //VC.Append;
        //Jlog(cnLog_Debug,2012020117472,'appended for hell of it');
        //VC.DElete;
        //Jlog(cnLog_Debug,2012020117473,'deleted for hell of it');

        bInvalid:=False;
        SetCursorType(crUnderline);
        SetCursorPos(0,0);
        CursorX:=1; CursorY:=1; CursorType:=crUnderline;
        // Ignore result - we know it is gonna be 1
        NewVC(giConsoleWidth, giConsoleHeight);
        InitKeyboard;
        gsaTerm:=GetEnv('TERM');
        {$IFDEF LINUX}
        If (gsaTerm='linux') Then
      	Begin
      	  While PollKeyEvent<>0 Do GetKeyEvent;
      	  DoneKeyBoard; // Strange but seems to work well.
      	End;
	      {$ENDIF}
      End;
    End;
  End;
  If bInitError Then
  Begin
    InitConsole:=False;
    ConsoleUnitInitialized:=False;
  End
  Else
  Begin
    InitConsole:=True;
    ConsoleUnitInitialized:=True;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('InitConsole',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure DoneConsole; // ShutDown Unit
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('DoneConsole',SOURCEFILE);
{$ENDIF}
  If ConsoleUnitInitialized Then
  Begin
    ConsoleUnitInitialized:=False;
    While VC.Listcount>0 Do RemoveVC(VC.Item_VCID);
    VC.Destroy;
    FreeMem(MG);
    SetCursorType(crUnderLine);
    ClearScreen;
    HideMouse; // only cuz Init has ShowMouse now
    DoneMouse;
    DoneVideo;
    DoneKeyboard;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('DoneConsole',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure ToggleVCVisible(p_VC:LongInt);
//=============================================================================
Var iVCBookMark: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('ToggleVCVisible',SOURCEFILE);
{$ENDIF}
  iVCBookMark:=GetActiveVC;
  VCSetVisible(not VCGetVisible);
  SetActiveVC(iVCBookMark);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('ToggleVCVisible',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================














//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                     Exported Keyboard Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
Function KeyHit: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('KeyHit',SOURCEFILE);
{$ENDIF}
  KeyHit:=(PollKeyEvent<>0);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('KeyHit',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure GetKeypress;
//=============================================================================
Var
  iKeyEvent: LongInt;
  rKeyRecord: TKeyRecord;
  iTranslatedKeyEvent: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetKeyPress',SOURCEFILE);
{$ENDIF}

  While not KeyHit Do;
  iKeyEvent:=GetKeyEvent;

  //if TKeyRecord(iKeyEvent).KeyCode=3 then
  //begin
  //  Jlog(cnLog_Debug,2012020117475,'CNTL-C',SOURCEFILE);
  //end;

  //TKeyRecord(iKeyEvent).Flags are :kbAscii, kbUniCode, kbFnKey, kbPhys,kbReleased
  rKeyRecord:=TKeyRecord(iKeyEvent);


  rLKey.u1Flags:= rKeyRecord.Flags;
  rLKey.u2KeyCodeRaw:= rKeyRecord.KeyCode;



  rLKey.bLSHIFTPressed:=
    ((rKeyRecord.ShiftState and kbLeftShift) = kbLeftShift);

  rLKey.bRSHIFTPressed:=
    ((rKeyRecord.ShiftState and kbRightShift) = kbRightShift);

  rLKey.bShiftPressed:= rLKey.bLSHIFTPressed OR rLKey.bRSHIFTPressed;

  rLKey.bCNTLPressed:=
    ((rKeyRecord.ShiftState and kbCtrl) = kbCtrl);

  rLKey.bALTPressed:=
    ((rKeyRecord.ShiftState and kbAlt) = kbAlt);

  // Translated Stuff
  iTranslatedKeyEvent:=TranslateKeyEvent(iKeyEvent);
  rLKey.ch:=GetKeyEventChar(iTranslatedKeyEvent);
  rKeyRecord:=TKeyRecord(iTranslatedKeyEvent);
  rLKey.u2KeyCode:= rKeyRecord.KeyCode;



  // Intel, Win32 Special Handling
  {$IFDEF WIN32}
    If rLKey.u2KeyCode=256 Then
    Begin
      // wierd handling for CAPLOCK+ESC not = 27 - Gonna force it to be same as
      // ESC normal- not sure if standard thing to do but...ESC is ESC to me
      rLKEy.ch:=#27;
    End;
    If rLKEy.ch=#0 Then
    Begin
      Case rLKEY.u2KeyCode Of
      37888: Begin
        // CNTL + TAB doesn't Work
        rLKey.ch:=#9;
      End;
      3840: Begin
        // Shift+Tab Doesn't Work
        rLKey.ch:=#9;
      End;
      // ALT Codes using Left ALT Key doesn't work
      // (My Right ALT Key already works for these)
      7680: If rLKEy.bShiftPressed Then rLKEy.ch:='A' Else rLKEy.ch:='a';
      12288:If rLKEy.bShiftPressed Then rLKEy.ch:='B' Else rLKEy.ch:='b';
      11776:If rLKEy.bShiftPressed Then rLKEy.ch:='C' Else rLKEy.ch:='c';
      8192: If rLKEy.bShiftPressed Then rLKEy.ch:='D' Else rLKEy.ch:='d';
      4608: If rLKEy.bShiftPressed Then rLKEy.ch:='E' Else rLKEy.ch:='e';
      8448: If rLKEy.bShiftPressed Then rLKEy.ch:='F' Else rLKEy.ch:='f';
      8704: If rLKEy.bShiftPressed Then rLKEy.ch:='G' Else rLKEy.ch:='g';
      8960: If rLKEy.bShiftPressed Then rLKEy.ch:='H' Else rLKEy.ch:='h';
      5888: If rLKEy.bShiftPressed Then rLKEy.ch:='I' Else rLKEy.ch:='i';
      9216: If rLKEy.bShiftPressed Then rLKEy.ch:='J' Else rLKEy.ch:='j';
      9472: If rLKEy.bShiftPressed Then rLKEy.ch:='K' Else rLKEy.ch:='k';
      9728: If rLKEy.bShiftPressed Then rLKEy.ch:='L' Else rLKEy.ch:='l';
      12800:If rLKEy.bShiftPressed Then rLKEy.ch:='M' Else rLKEy.ch:='m';
      12544:If rLKEy.bShiftPressed Then rLKEy.ch:='N' Else rLKEy.ch:='n';
      6144: If rLKEy.bShiftPressed Then rLKEy.ch:='O' Else rLKEy.ch:='o';
      6400: If rLKEy.bShiftPressed Then rLKEy.ch:='P' Else rLKEy.ch:='p';
      4096: If rLKEy.bShiftPressed Then rLKEy.ch:='Q' Else rLKEy.ch:='q';
      4864: If rLKEy.bShiftPressed Then rLKEy.ch:='R' Else rLKEy.ch:='r';
      7936: If rLKEy.bShiftPressed Then rLKEy.ch:='S' Else rLKEy.ch:='s';
      5120: If rLKEy.bShiftPressed Then rLKEy.ch:='T' Else rLKEy.ch:='t';
      5632: If rLKEy.bShiftPressed Then rLKEy.ch:='U' Else rLKEy.ch:='u';
      12032:If rLKEy.bShiftPressed Then rLKEy.ch:='V' Else rLKEy.ch:='v';
      4352: If rLKEy.bShiftPressed Then rLKEy.ch:='W' Else rLKEy.ch:='w';
      11520:If rLKEy.bShiftPressed Then rLKEy.ch:='X' Else rLKEy.ch:='x';
      5376: If rLKEy.bShiftPressed Then rLKEy.ch:='Y' Else rLKEy.ch:='y';
      11264:If rLKEy.bShiftPressed Then rLKEy.ch:='Z' Else rLKEy.ch:='z';
      End;//case
    End;
  {$ELSE}

    {$IFDEF LINUX}
    // getting all kinds of screwy Linux things - going to
    // do all my own translations simply because linux has
    // been a pain in the ass

    rLKey.bShiftPressed:=False;
    rLKey.bLShiftPRessed:=False;
    rLKey.bRShiftPressed:=False;
    rLKey.bCNTLPressed:=False;
    rLKEy.bAltPressed:=False;

    //If gsaTerm='xterm' Then
    Begin
      Case rLKey.u2KeyCode Of
      7681: Begin // CNTL+A
         rLKey.bCntlPressed:=True;
         rLKey.ch:='A';
      End;
      12290: Begin //CNTL-B
         rLKey.bCntlPressed:=True;
         rLKey.ch:='B';
      End;
      11779: Begin //CNTL+C
        rLKey.bCntlPressed:=True;
        rLKey.ch:='C';
      End;
      8196: Begin // CNTL-D
        rLKey.bCntlPressed:=True;
        rLKey.ch:='D';
      End;
      4613: Begin // CNTL-E
        rLKEy.bCntlPRessed:=True;
        rLKey.ch:='E';
      End;
      8454: Begin // CNTL-F
        rLKEy.bCntlPressed:=True;
        rLKey.ch:='F';
      End;
      8711: Begin // CNTL-G
        rLKey.bCntlPRessed:=True;
        rLKey.ch:='G';
      End;
      // CNTL-H = backspace
      // CNTL-I = TAB
      9226: Begin // CNTL-J
        rLKEy.bCntlPressed:=True;
        rLKey.ch:='J';
      End;
      9483: Begin // CNTL-K
        rLKey.bCntlPressed:=True;
        rLKey.ch:='K';
      End;
      9740: Begin // CNTL-L
        rLKey.bCntlPRessed:=True;
        rLKey.ch:='L';
      End;
      // CNTL-M = ENTER
      6159: Begin // CNTL-O
        rLKEy.bCntlPRessed:=True;
        rLKey.ch:='O';
      End;
      6416: Begin // CNTL-P
        rLKEy.bCntlPressed:=True;
        rLKey.ch:='P';
      End;
      4113: Begin // CNTL-Q
        rLKEy.bCntlPRessed:=True;
        rLKey.ch:='Q';
      End;
      4882: Begin // CNTL-R
        rLKey.bCNTLPressed:=True;
        rLKey.ch:='R';
      End;
      7955: Begin // CNTL-S
        rLKEy.bCntlPRessed:=True;
        rLKey.ch:='S';
      End;
      5140: Begin // CNTL-T
        rLKEy.bCntlPressed:=True;
        rLKey.ch:='T';
      End;
      5653: Begin // CNTL-U
        rLKEY.bCntlPRessed:=True;
        rLKey.ch:='U';
      End;
      12054: Begin // CNTL-V
        rLKEy.bCntlpressed:=True;
        rLKey.ch:='V';
      End;
      4375: Begin // CNTL-W
        rLKEY.bCntlPRessed:=True;
        rLKey.ch:='W';
      End;
      11544: Begin // CNTL-X
        rLKEy.bCntlPressed:=True;
        rLKey.ch:='X';
      End;
      5401: Begin // cntl-Y
        rLKEy.bCntlPRessed:=True;
        rLKey.ch:='Y';
      End;
      11290: Begin // cntl-Z
        rLKEY.bCntlPRessed:=True;
        rLKey.ch:='Z';
      End;
      // LOWERCASE ALTS
      7680: Begin // ALT-a
        rLKEY.bAltPressed:=True;
        rLKey.ch:='a';
      End;
      12288: Begin // ALT-b
        rLKEy.bAltPressed:=True;
        rLKEY.ch:='b';
      End;
      11776: Begin // ALT-c
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='c';
      End;
      8192: Begin // ALT-d
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='d';
      End;
      4608: Begin // ALT-e
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='e';
      End;
      8448: Begin // ALT-f
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='f';
      End;
      8704: Begin // ALT-g
        rLKEy.bAltPRessed:=True;
        rLKey.ch:='g';
      End;
      8960: Begin // ALT-h
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='h';
      End;
      5888: Begin // ALT-i
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='i';
      End;
      9216: Begin // ALT-j
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='j';
      End;
      9472: Begin // ALT-k
        rLKEy.bAltPRessed:=True;
        rLKey.ch:='k';
      End;
      9728: Begin // ALT-l
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='l';
      End;
      12800: Begin // ALT-m
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='m';
      End;
      12544: Begin // ALT-n
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='n';
      End;
      6144: Begin // ALT-o
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='o';
      End;
      6400: Begin // ALT-p
        rLKEy.bAltPressed:=True;
        rLKey.ch:='p';
      End;
      4096: Begin // ALT-q
        rLkey.bAltPressed:=True;
        rLKEy.ch:='q';
      End;
      4864: Begin // ALT-r
        rLkey.bAltPRessed:=True;
        rLkey.ch:='r';
      End;
      7936: Begin // ALT-s
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='s';
      End;
      5120: Begin // ALT-t
        rLKEy.bAltPRessed:=True;
        rLKey.ch:='t';
      End;
      5632: Begin // ALT-u
        rLKEy.bAltPressed:=True;
        rLKey.ch:='u';
      End;
      12032: Begin // ALT-v
        rLkey.bAltPRessed:=True;
        rLKey.ch:='v';
      End;
      4352: Begin // ALT-w
        rLKEy.bAltPressed:=True;
        rLkey.ch:='w';
      End;
      11520: Begin // ALT-x
        rLKEy.bAltPressed:=True;
        rLKey.ch:='x';
      End;
      5376: Begin // ALT-y
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='y';
      End;
      11264: Begin  // ALT-z
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='z';
      End;

      10592: Begin // ALT+` <Under Tilde)
        rLKEy.bAltPRessed:=True;
        rLKey.ch:='`';
      End;
      30720: Begin // ALT+1
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='1';
      End;
      30976:  Begin // ALT-2
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='2';
      End;
      31232:  Begin // ALT-3
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='3';
      End;
      31488: Begin // ALT-4
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='4';
      End;
      31744: Begin // alt+5
        rLkey.bAltPRessed:=True;
        rLKEy.ch:='5';
      End;
      32000: Begin // ALT+6
        rLKEy.bAltPressed:=True;
        rLKEy.ch:='6';
      End;
      32256: Begin // ALT+7
        rLKey.bAltPressed:=True;
        rLKEy.ch:='7';
      End;
      32512: Begin // ALT+8
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='8';
      End;
      32768: Begin // ALT+9
        rLKEy.bAltPressed:=True;
        rLKey.ch:='9';
      End;
      33024: Begin // ALT+0 (zero)
        rLKEy.bAltPRessed:=True;
        rLKEy.ch:='0';
      End;
      //33280: Begin // ALT+- <minus>
      //  rLKEy.bAltPressed:=True;
      //  rLKEy.ch:='-';
      //End;
      //33536: Begin // ALT+= <equal>
      //  rLKEy.bAltPRessed:=True;
      //  rLKEy.ch:='=';
      //End;
      //2048: Begin // ALT+BACKSPACE
      //  rLKEy.bAltPRessed:=True;
      //  rLKEy.ch:=#8;
      //End;
      //6656: Begin // ALT+[
      //  rLKEy.bAltPRessed:=True;
      //  rLKEy.ch:='[';
      //End;
      //7005: Begin // ALT+]
      //  rLKEy.bAltPressed:=True;
      //  rLKEy.ch:=']';
      //End;
      //11100: Begin // ALT+\
      //  rLKEy.bAltPRessed:=True;
      //  rLKEy.ch:='\';
      //End;
      //10043: Begin // ALT+;
      //  rLKEy.bAltPRessed:=True;
      //  rLKEy.ch:=';';
      //End;
      //10279: Begin // ALT+appostrophe
      //  rLKEy.bAltPressed:=True;
      //  rLKEy.ch:='''';
      //End;
      //13100: Begin // ALT+,
      //  rLKEy.bAltPressed:=True;
      //  rLKEy.ch:=',';
      //End;
      //13358: Begin  // alt+.
      //  rLKEy.bAltPRessed:=True;
      //  rLkey.ch:='.';
      //End;
      //13615: Begin // alt+/
      //  rLKEy.bAltPressed:=True;
      //  rLKey.ch:='/';
      //End;
      End;//case
    End;


    // No Discernment
    rLKey.bLShiftPressed:=rLKey.bShiftPressed;
    rLKey.bRShiftPressed:=rLKey.bShiftPressed;

    {$ENDIF}
 {$ENDIF}


{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetKeyPress',SOURCEFILE);
{$ENDIF}

End;
//=============================================================================


//=============================================================================
Procedure TurnOffCNTLC;
//=============================================================================
Begin
{$IFDEF WIN32}
  SetConsoleCtrlHandler(@NewHandlerRoutine, True);
{$ENDIF}
End;
//=============================================================================




//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                        Exported Mouse Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
Function HaveM: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('HaveM',SOURCEFILE);
{$ENDIF}
  HaveM:=(uMSButtons>0);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('HaveM',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function MButtons: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('MButtons',SOURCEFILE);
{$ENDIF}
  MButtons:=uMSButtons;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('MButtons',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure HideMCursor;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('HideCursor',SOURCEFILE);
{$ENDIF}
  HideMouse;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('HideCursor',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure ShowMCursor;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('ShowMCursor',SOURCEFILE);
{$ENDIF}
  ShowMouse;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('ShowMCursor',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetMEvent:rtMEvent;
//=============================================================================
Var
  rMouseEvent: TMouseEvent;
  VCC: TVCXDL;
{$IFDEF WIN32}
  wButtons: Word;
{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetMEvent',SOURCEFILE);
{$ENDIF}


  //Jlog(cnLog_Debug,2012020117476,'Console.GetMEvent------------------------Begin',SOURCEFILE);
  GetMouseEvent(rMouseEvent);


//----------Sometimes on Intel/Win32 - I recieved MouseAction ZER0
//----------So I had to "Repair" the event as best I could.
{$IFDEF WIN32}
  If rMouseEvent.Action=0 Then
  Begin
    //Jlog(cnLog_Debug,2012020117477,'Console.GetMEvent - MouseEvent Action Returned ZERO! Attempting Fix',SOURCEFILE);

    // This is a Fix for this strange Mouse Error
    // Must report bug to FreePascal.org if this comes up again.

    // Fix idea to compare rLMEVENT against NEw rMouseEvent before setting
    // To try and Identify Action and Button Changes -
    // This fix relies on Buttons and X,Y Still reporting Accurately.
    // The bug appears to be with the TMOUSEEVENT.Action field

    // Attempt a fix for Actions Up & Down

    //wButtons:=GetMouseButtons;
    wButtons:=rMouseEvent.Buttons;

    // Left Mouse Button
    If ((wButtons and MouseLeftButton)=0) and
       ((rLMEvent.Buttons and MouseLeftButton)=MouseLeftButton) Then
    Begin
      If (rMouseEvent.Action and MouseActionUp)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionUp;
      End;
    End;

    If ((wButtons and MouseLeftButton)=MouseLeftButton) and
       ((rLMEvent.Buttons and MouseLeftButton)=0) Then
    Begin
      If (rMouseEvent.Action and MouseActionDown)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionDown;
      End;
    End;

    // Right Mouse Button
    If ((wButtons and MouserightButton)=0) and
       ((rLMEvent.Buttons and MouserightButton)=MouserightButton) Then
    Begin
      If (rMouseEvent.Action and MouseActionUp)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionUp;
      End;
    End;

    If ((wButtons and MouserightButton)=MouserightButton) and
       ((rLMEvent.Buttons and MouserightButton)=0) Then
    Begin
      If (rMouseEvent.Action and MouseActionDown)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionDown;
      End;
    End;

    // middle Mouse Button
    If ((wButtons and MousemiddleButton)=0) and
       ((rLMEvent.Buttons and MousemiddleButton)=MousemiddleButton) Then
    Begin
      If (rMouseEvent.Action and MouseActionUp)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionUp;
      End;
    End;

    If ((wButtons and MousemiddleButton)=MousemiddleButton) and
       ((rLMEvent.Buttons and MousemiddleButton)=0) Then
    Begin
      If (rMouseEvent.Action and MouseActionDown)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionDown;
      End;
    End;

    {// Test for movement
    If rMouseEvent.X<>(rLMEvent.ConsoleX-1) Then
    Begin
      If (rMouseEvent.Action and MouseActionMove)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionMove;
      End;
    End;

    If rMouseEvent.Y<>(rLMEvent.ConsoleY-1) Then
    Begin
      If (rMouseEvent.Action and MouseActionMove)=0 Then
      Begin
        rMouseEvent.Action+=MouseActionMove;
      End;
    End;
    }
    If (rMouseEvent.Action and MouseActionMove)=0 Then
    Begin
      rMouseEvent.Action+=MouseActionMove;
    End;

    // This is Correct bug code
    //rMouseEvent.Action:=MouseActionUp+MouseActionMove;

   //If rMouseEvent.Action=0 Then
   //  Jlog(cnLog_DEBUG,201202011905,'Console - Attempted Fix Failed',SOURCEFILE);
  End;
{$ENDIF}


  VCC:=TVCXDL.CreateCopy(VC);
  rLMEvent.Buttons :=rMouseEvent.Buttons;
  rLMEvent.ConsoleX:=rMouseEvent.x+1;
  rLMEvent.ConsoleY:=rMouseEvent.y+1;
  rLMEvent.Action  :=rMouseEvent.Action;
  rLMEvent.VC      :=MG[rMouseEvent.x+rMouseEvent.y*giConsoleWidth];
  VCC.FoundItem_VCID(rLMEvent.VC);
  rLMEvent.VMX     := (rLMEvent.ConsoleX - TVCXDLITEM(VCC.lpItem).VX)+1;
  rLMEvent.VMY     := (rLMEvent.ConsoleY - TVCXDLITEM(VCC.lpItem).VY)+1;
  VCC.Destroy;
  GetMEvent:=rLMEvent;
  //Jlog(cnLog_Debug,2012020117478,'Console.GetMEvent------------------------End',SOURCEFILE);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetMEvent',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function MEvent: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('MEvent',SOURCEFILE);
{$ENDIF}
  MEvent:=PollMouseEvent(rPollMouseEvent);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('MEvent',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function GetMX: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetMX',SOURCEFILE);
{$ENDIF}
  GetMX:=GetMouseX;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetMX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetMY: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetMY',SOURCEFILE);
{$ENDIF}
  GetMY:=GetMouseY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetMY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetMButtons: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetMButtons',SOURCEFILE);
{$ENDIF}
  GetMButtons:=GetMouseButtons;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetMButtons',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure SetMXY(x,y:Word);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('SetMXY',SOURCEFILE);
{$ENDIF}
  SetMouseXY(x,y);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('SetMXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                     Exported Console Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
Procedure UpdateConsole;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('UpdateConsole',SOURCEFILE);
{$ENDIF}
  If bInvalid Then CopyAllVCToVideo;
  bInvalid:=False;
  If TVCXDLITEM(VC.lpItem).VTrackCursor Then
  Begin
    VCSetCursorXY(VCGetPenX, VCGetPenY);
  End;
  UpdateCursor;
  UpdateScreen(False);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('UpdateConsole',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure RedrawConsole;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('RedrawConsole',SOURCEFILE);
{$ENDIF}
{  if bInvalid then CopyAllVCToVideo;
  bInvalid:=False;
  If TVCXDLITEM(VC.lpItem).VTrackCursor Then
  Begin
    VCSetCursorXY(VCGetPenX, VCGetPenY);
  End;
  UpdateCursor;}
  UpdateConsole;
  Updatescreen(True);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('RedrawConsole',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
Function GetConsoleLockCount: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetConsoleLockCount',SOURCEFILE);
{$ENDIF}
  GetConsoleLockCount:=GetLockScreenCount;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetConsoleLockCount',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure AddConsoleLock;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('AddConsoleLock',SOURCEFILE);
{$ENDIF}
  LockScreenUpdate;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('AddConsoleLock',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure RemoveConsoleLock;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('RemoveConsoleLock',SOURCEFILE);
{$ENDIF}
  UnlockScreenUpdate;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('RemoveConsoleLock',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetConsoleCapabilities: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetConsoleCapabilities',SOURCEFILE);
{$ENDIF}
  GetConsoleCapabilities:=ConsoleCapabilities;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetConsoleCapabilities',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure GetConsoleDriver(Var Driver: rtConsoleDriver);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetVideoDriver',SOURCEFILE);
{$ENDIF}
  GetVideoDriver(TVideoDriver(Driver));
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetVideoDriver',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure GetConsoleMode(Var Mode: rtConsoleMode);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetConsoleMode',SOURCEFILE);
{$ENDIF}
  GetVideoMode(rVM);
  mode.col:=rVM.Col;
  mode.row:=rVM.row;
  mode.color:=rVM.color;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetConsoleMode',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetConsoleModeCount: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetConsoleModeCount',SOURCEFILE);
{$ENDIF}
  GetConsoleModecount:=GetVideoModecount;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetConsoleModeCount',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetConsoleModeData(Index: Word; Var Data: rtConsoleMode):Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetConsoleModeData',SOURCEFILE);
{$ENDIF}
  Result:=GetVideoModeData(Index, rvm);
  data.col:=rVM.Col;
  data.row:=rVM.row;
  data.color:=rVM.color;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetConsoleModeData',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetConsoleDriver(Const Driver: rtConsoleDriver):Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('SetConsoleDriver',SOURCEFILE);
{$ENDIF}
  SetConsoleDriver:=SetVideoDriver(TVideoDriver(Driver));
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('SetConsoleDriver',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetConsoleMode(mode:rtConsoleMode):Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('SetConsoleMode',SOURCEFILE);
{$ENDIF}
 rVM.Col   := mode.col;
 rVM.row   := mode.row;
 rVM.color := mode.color;
 SetConsoleMode:=SetVideoMode(rvm);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('SetConsoleMode',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure ForceCursorType(CursorType:Word);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('ForceCursorType',SOURCEFILE);
{$ENDIF}
  SetCursorType(CursorType);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('ForceCursorType',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                  Exported Virtual Console Routines
//
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

// Lowest Level So here is where we check for invalid Size
//=============================================================================
Function NewVC(p_iVWidth, p_iVHeight: LongInt):UINT;
//=============================================================================
Var sa: AnsiString;
    nw,nh: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('NewVC Width, Height',SOURCEFILE);
{$ENDIF}

  If (p_iVWidth<1) OR (p_iVHeight<1) Then
  Begin
    If p_iVWidth<1 Then nw:=1 Else nw:=p_iVWidth;
    If p_iVHeight<1 Then nh:=1 Else nh:=p_iVHeight;
    NewVC:=CreateNewVC(nw, nh);
    sa:= 'Width='+inttostr(p_iVWidth)+' Height:'+ inttostr(p_iVHeight);
    Jlog(cnLog_Warn,201202017479,'uxxc_Console.NewVC called with invalid parameters. ' +
      'Use positive numbers >= 1. The requested size was: ' + sa,SOURCEFILE);
  End
  Else
  Begin
    NewVC:=CreateNewVC(p_iVWidth, p_iVHeight);
    VCClear;
  End;
  If TVCXDLITEM(VC.lpItem).bOnScreen Then bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('NewVC Width, Height',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function NewVC:UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('NewVC No Parameters',SOURCEFILE);
{$ENDIF}
  Result:=CreateNewVC(giConsoleWidth, giConsoleHeight);
  VCClear;
  If TVCXDLITEM(VC.lpItem).bOnScreen Then bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('NewVC No Parameters',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function NewVC(p_iX, p_iY,p_iVWidth, p_iVHeight: LongInt):UINT;
//=============================================================================
Var bLocalInvalid: Boolean;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('NewVC x,y,width,height',SOURCEFILE);
{$ENDIF}
  bLocalInvalid:=bInvalid;
  Result:=CreateNewVC(p_iVWidth, p_iVHeight);
  VCSetXY(p_iX,p_iY);
  VCClear;
  If not bLocalInvalid Then If TVCXDLITEM(VC.lpItem).bOnScreen Then bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('NewVC x,y,width,height',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function NewVC(p_iX, p_iY,p_iVWidth, p_iVHeight: LongInt;p_u1VFGC, p_u1VBGC: Byte):UINT;
//=============================================================================
Var bLocalInvalid: Boolean;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('NewVC x,y,width,height,fgc,bgc',SOURCEFILE);
{$ENDIF}
  bLocalInvalid:=bInvalid;
  Result:=CreateNewVC(p_iVWidth, p_iVHeight);
  VCSetXY(p_iX,p_iY);
  VCSetFGC(p_u1VFGC);
  VCSetBGC(p_u1VBGC);
  VCClear;
  If not bLocalInvalid Then If TVCXDLITEM(VC.lpItem).bOnScreen Then bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('NewVC x,y,width,height,fgc,bgc',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure RemoveVC(p_uVCUID: UINT);
//=============================================================================
Var
  iTempZ: LongInt;
  uTempUID: UINT;
  T: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('RemoveVC',SOURCEFILE);
{$ENDIF}
  If not VC.FoundItem_VCID(p_uVCUID) Then
  Begin
    Jlog(cnLog_Warn,2012020117500,'RemoveVC(VC_ID) Requested VC_UID:' + inttostr(p_uVCUID) +
               'Number of VC''s at time of request:' + inttostr(VC.Listcount),SOURCEFILE);
    //if VC.Listcount>0 then
    //begin
    //  vc.movefirst;
    //  repeat
    //    Jlog(cnLog_Debug,201202011751,'VC.N:'+inttostr(vc.n)+' '+
    //              'VC.Item_VCID:' + inttostr(VC.Item_VCID),SOURCEFILE);
    //  until not VC.MoveNext;
    //end;
  End
  Else
  Begin
    If (TVCXDLITEM(VC.lpItem).VVisible) and
       (TVCXDLITEM(VC.lpItem).bOnScreen)
    Then bInvalid:=True;
    iTempZ:=TVCXDLITEM(VC.lpITem).iZOrder;
    uTempUID:=VC.Item_VCID;
    VC.DeleteItem;
    If VC.ListCount>0 Then
    Begin
      // Is ZBUF update necessary? Only if NOT Top of ZBuf
      If iTempZ<>(VC.Listcount+1) Then
      Begin
        For t:=iTempZ+1 To VC.ListCount+1 Do
        Begin
          If VC.FoundItem_iZOrder(t) Then
          Begin
            TVCXDLITEM(VC.lpItem).iZORder-=1; // Deduct ZOrder By 1
            If (TVCXDLITEM(VC.lpItem).VVisible) and
               (TVCXDLITEM(VC.lpItem).bOnScreen)
            Then bInvalid:=True;
          End;
        End;
      End;
      // Update Active VC if just removed the active one
      If ActiveVC=uTempUID Then
      Begin
        VC.FoundItem_iZOrder(VC.ListCount);
        ActiveVC:=VC.Item_VCID;
        If (TVCXDLITEM(VC.lpItem).VVisible) and
           (TVCXDLITEM(VC.lpItem).bOnScreen)
        Then bInvalid:=True;
      End
      Else
      Begin
        VC.FoundItem_VCID(ActiveVC); // otherwise just set back to Active
      End;
    End;
    //UpdateMGbyUID(p_iVCUID); never tested
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('RemoveVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetVCCount: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetVCCount',SOURCEFILE);
{$ENDIF}
  GetVCCount:=VC.Listcount;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetVCCount',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure BringVCToTop(p_uVCUID: UINT);
//=============================================================================
Var iOldZ: LongInt;
    t: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('BringVCToTop',SOURCEFILE);
{$ENDIF}
  If not VC.FoundItem_VCID(p_uVCUID) Then
  Begin
    JLog(cnLog_Warn,201202011906,'BringVCToTop(VC_ID) Requested VC_ID:' + inttostr(p_uVCUID) +
     'Number of VC''s at time of request:' + inttostr(VC.Listcount),SOURCEFILE);
  End
  Else
  Begin
//    Jlog(cnLog_Debug,201202011752,'BringVCToTop---------------------------Total VC''s:'+inttostr(VC.ListCount),SOURCEFILE);
//    VC.MoveFirst;
//    repeat
//      Jlog(cnLog_Debug,201202011753,'VC UID:'+Inttostr(VC.Item_VCID)+' Z:'+inttostr(VC.XXDL^.ID[1]),SOURCEFILE);
//    until not VC.MoveNext;
//    Jlog(cnLog_Debug,201202011754,'-----end of Dump',SOURCEFILE);
//    VC.FoundItem_iVCID(p_uVCUID);
//
//    Jlog(cnLog_Debug,201202011755,'Passed UID:'+inttostr(p_uVCUID),SOURCEFILE);
//    Jlog(cnLog_Debug,201202011756,'UID after FoundUID call:'+inttostr(VC.Item_VCID),SOURCEFILE);
    iOldZ:=TVCXDLITEM(vc.lpitem).iZOrder; // Position in ZBuf Before update
//    Jlog(cnLog_Debug,201202011757,'Z of VC.Item_VCID '+inttostr(VC.Item_VCID)+' before update:'+inttostr(VC.XXDL^.ID[1]),SOURCEFILE);
//    Jlog(cnLog_Debug,201202011758,'VC Listcount:'+inttostr(VC.ListCount),SOURCEFILE);
    For t:=iOLDZ To VC.ListCount Do // move all VC's down zbuf by 1
    Begin
      VC.FoundItem_iZOrder(t);
      TVCXDLITEM(VC.lpItem).iZORder-=1;
    End;
    VC.FoundItem_VCID(p_uVCUID); // Move to Top of ZBuf
    TVCXDLITEM(VC.lpItem).iZOrder:=VC.ListCount;
//    Jlog(cnLog_Debug,201202011759,'Z of VC.Item_VCID '+inttostr(p_uVCUID)+' after update:'+inttostr(VC.XXDL^.ID[1]),SOURCEFILE);
    If (TVCXDLITEM(VC.lpItem).VVisible) and
       (TVCXDLITEM(VC.lpItem).bOnScreen) Then bInvalid:=True;
    VC.FoundItem_VCID(ActiveVC); // Set VC back to active
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('BringVCToTop',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure SetActiveVC(p_uVCUID: UINT);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('SetActiveVC',SOURCEFILE);
{$ENDIF}
  If not VC.FoundItem_VCID(p_uVCUID) Then
  Begin
    Jlog(cnLog_Warn,201202011800,'SetActiveVC(VC_ID) Requested VC_ID:' + inttostr(p_uVCUID) +
               'Number of VC''s at time of request:' + inttostr(VC.Listcount),SOURCEFILE);
  End
  Else
  Begin
    ActiveVC:=p_uVCUID;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('SetActiveVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetActiveVC: UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetActiveVC',SOURCEFILE);
{$ENDIF}
  GetActiveVC:=ActiveVC;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetActiveVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCClear;
//=============================================================================
Var
  t,s: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCClear',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011801,'VCClear-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCSetPenXY(1,1);
  For s:=1 To TVCXDLITEM(VC.lpItem).VH Do
  Begin
    For t:=1 To TVCXDLITEM(VC.lpItem).VW Do
    Begin
      VCPutAll(t,s, Ord(' ')+
      (TVCXDLITEM(VC.lpItem).VFGC + (TVCXDLITEM(VC.lpItem).VBGC shl 4)) shl 8);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCClear',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCWidth: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWidth',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011802,'VCWidth-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCWidth:=TVCXDLITEM(VC.lpItem).VW;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWidth',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCHeight: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWidth',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011803,'VCHeight-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCHeight:=TVCXDLITEM(VC.lpItem).VH;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWidth',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function VCCursorType: Word;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCCursorType',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011804,'VCCursorType-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCCursorType:=TVCXDLITEM(VC.lpItem).VCursorType;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCCursorType',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetCursorType(p_wCursorType: Word);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetCursorType',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011805,'VCSetcursorType-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}


//  if TVCXDLITEM(VC.lpItem).VCursorType<>p_wCursorType then
//  begin
    TVCXDLITEM(VC.lpItem).VCursorType:=p_wCursorType;
    //Updatecursor;
//  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetCursorType',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetCursorXY(p_iX, p_iY: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetCursorXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011806,'VCSetCursorXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

//  if (TVCXDLITEM(VC.lpItem).VCX<>p_iX) or
//     (TVCXDLITEM(VC.lpItem).VCY<>p_iY) then
//  begin
    TVCXDLITEM(VC.lpItem).VCX:=p_iX;
    TVCXDLITEM(VC.lpItem).VCY:=p_iY;
    //if (TVCXDLITEM(VC.lpItem).VCursorType<>crHidden) then UpdateCursor;
//  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetCursorXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  VCGetCursorX: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetCursorX',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011807,'VCGetCursorX-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetCursorX:=TVCXDLITEM(VC.lpItem).VCX;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetCursorX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  VCGetCursorY: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetCursorY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011808,'VCGetCursorY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetCursorY:=TVCXDLITEM(VC.lpItem).VCY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetCursorY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetFGC(p_u1FGC: Byte);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetFGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011809,'VCSetFGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VFGC:=(p_u1FGC and $0f);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetFGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetBGC(p_u1BGC: Byte);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetBGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011810,'VCSetBGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VBGC:=(p_u1BGC and $0F);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetBGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetPenXY(p_iX, p_iY:LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetPenXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011811,'VCSetPenXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VPX:=p_iX;
  TVCXDLITEM(VC.lpItem).VPY:=p_iY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetPenXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetPenX(p_iX:LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetPenX',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011812,'VCSetPenX-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VPX:=p_iX;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetPenX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetPenY(p_iY:LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetPenY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011812,'VCSetPenY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VPY:=p_iY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetPenY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCPutChar(p_iX, p_iY: LongInt; p_ch:Char);
//=============================================================================
Var p: LongInt;
    wData: Word;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCPutChar',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011813,'VCPutchar-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    wData:=(TVCXDLITEM(VC.lpItem).VBuf[p] and $FF00)+Ord(p_ch);
    If wData<>TVCXDLITEM(VC.lpItem).VBuf[p] Then
    Begin
      TVCXDLITEM(VC.lpItem).VBuf[p]:=wData;
      UpdateCH(p_iX, p_iY);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCPutChar',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCPutBGC(p_iX, p_iY: LongInt; p_u1BGC:Byte);
//=============================================================================
Var p: LongInt;
    wData: Word;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCPutBGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011814,'VCPutBGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    wData:=(TVCXDLITEM(VC.lpItem).VBuf[p] and $0FFF)+(p_u1BGC shl 12);
    If wData<>TVCXDLITEM(VC.lpItem).VBuf[p] Then
    Begin
      TVCXDLITEM(VC.lpItem).VBuf[p]:=wData;
      UpdateCH(p_iX, p_iY);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCPutBGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCPutFGC(p_iX, p_iY: LongInt; p_u1FGC:Byte);
//=============================================================================
Var p: LongInt;
    wData:Word;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCPutFGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011815,'VCPutFGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    wData:=(TVCXDLITEM(VC.lpItem).VBuf[p] and $F0FF)+(p_u1FGC shl 8);
    If wData<>TVCXDLITEM(VC.lpItem).VBuf[p] Then
    Begin
      TVCXDLITEM(VC.lpItem).VBuf[p]:=wData;
      UpdateCH(p_iX, p_iY);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCPutFGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCPutAll(p_iX, p_iY: LongInt; p_wAll:Word);
//=============================================================================
Var p: LongInt;
//    wData:word;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugIN('VCPutAll 1',SOURCEFILE);
  {$ENDIF}
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011816,'VCPutAll-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    If p_wAll <> TVCXDLITEM(VC.lpItem).VBuf[p] Then
    Begin
      TVCXDLITEM(VC.lpItem).VBuf[p]:=p_wAll;
      UpdateCH(p_iX, p_iY);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugOUT('VCPutAll 1',SOURCEFILE);
  {$ENDIF}
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCPutAll(p_iX, p_iY: LongInt; P_ch: Char; p_byFG, p_byBG: Byte);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCPutAll 2',SOURCEFILE);
{$ENDIF}

  VCPutAll(p_iX, p_iY, Ord(p_ch)+((p_byfg + (p_byBG shl 4)) shl 8));

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCPutAll 2',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
Function VCGetChar(p_iX, p_iY: LongInt): Char;
//=============================================================================
Var p: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetChar',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011817,'VCGetchar-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    VCGetChar:=Char(TVCXDLITEM(VC.lpItem).VBuf[p] and $00FF);
  End
  Else
  Begin
    VCGetChar:=#0;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetChar',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetBGC(p_iX, p_iY: LongInt):Byte;
//=============================================================================
Var p: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetBGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011818,'VCGetBGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    VCGetBGC:=Byte((TVCXDLITEM(VC.lpItem).VBuf[p] and $F000) shr 8);
  End
  Else
  Begin
    VCGetBGC:=0;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetBGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetFGC(p_iX, p_iY: LongInt):Byte;
//=============================================================================
Var p: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetFGC',SOURCEFILE);
{$ENDIF}
  {$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011819,'VCGetFGC-VCCHECK ERROR!!',SOURCEFILE);
  {$ENDIF}

  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    VCGetFGC:=Byte((TVCXDLITEM(VC.lpItem).VBuf[p] and $0F00) shr 8);
  End
  Else
  Begin
    VCGetFGC:=0;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetFGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetAll(p_iX, p_iY: LongInt):Word;
//=============================================================================
Var p: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetAll',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011820,'VCGetAll-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iX>0) and (p_iX<=TVCXDLITEM(VC.lpItem).VW) and
     (p_iY>0) and (p_iY<=TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    p:=(p_iX-1)+(p_iY-1)*TVCXDLITEM(VC.lpItem).VW;
    VCGetAll:=TVCXDLITEM(VC.lpItem).VBuf[p];
  End
  Else
  Begin
    VCGetAll:=0;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetAll',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWriteCharXY(p_iX, p_iY: LongInt; p_ch:Char);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteCharXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011821,'VCWriteCharXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCSetPenXY(p_iX, p_iY);
  VCWriteChar(p_ch);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteCharXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWriteChar(p_Char: Char);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteChar',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011822,'VCWriteChar-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  Case p_Char Of
  (#13): // carriage return
    Begin
      TVCXDLITEM(VC.lpItem).VPX:=1;
    End;
  (#10): // line feed
    Begin
      TVCXDLITEM(VC.lpItem).VPX:=1;
      TVCXDLITEM(VC.lpItem).VPY+=1;
      If TVCXDLITEM(VC.lpItem).VPY>TVCXDLITEM(VC.lpItem).VH Then
      Begin
        TVCXDLITEM(VC.lpItem).VPY:=TVCXDLITEM(VC.lpItem).VH;
        If TVCXDLITEM(VC.lpItem).VScroll Then VCScrollUp;
      End;
    End;
  (#9):  // TAB
    Begin
      // --- new --- begin
      // this is recursive but aims at my goal of having minimal
      // scroll reasons.
      VCWrite(StringOfChar(' ',TVCXDLITEM(VC.lpItem).VTabSize));
      // --- new --- end
    End;
  (#7):  // Bell
    Begin
      // Do Nothing - For Dos Platform I don't know what to do
    End;
  Else
    Begin
      // put it in the buffer
      VCPutAll(
        TVCXDLITEM(VC.lpItem).VPX,
        TVCXDLITEM(VC.lpItem).VPY,
        Ord(p_char)+ // loword
        ((TVCXDLITEM(VC.lpItem).VFGC + (TVCXDLITEM(VC.lpItem).VBGC shl 4)) shl 8)//hiword
      );
      // update cursor - does wrap
      TVCXDLITEM(VC.lpItem).VPX+=1;
      If TVCXDLITEM(VC.lpItem).VWrap Then
      Begin
        If TVCXDLITEM(VC.lpItem).VPX>TVCXDLITEM(VC.lpItem).VW Then
        Begin
          TVCXDLITEM(VC.lpItem).VPX:=1;
          TVCXDLITEM(VC.lpItem).VPY+=1;
          If TVCXDLITEM(VC.lpItem).VPY>TVCXDLITEM(VC.lpItem).VH Then
          Begin
            TVCXDLITEM(VC.lpItem).VPY:=TVCXDLITEM(VC.lpItem).VH;
            If TVCXDLITEM(VC.lpItem).VScroll Then VCScrollUp;
          End;
        End;
      End;
    End;//case else
  End;//case
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteChar',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWrite(sa:AnsiString);
//=============================================================================
Var iLoop: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWrite',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011823,'VCWrite-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If length(sa)>0 Then
  Begin
    For iLoop:=1 To length(sa) Do VCWriteChar(sa[iLoop]);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWrite',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


// use to draw with background colors only on a transparency VC
// use string chars 0-7 to make background color, spaces=holes
//=============================================================================
Procedure VCDrawBGXY(px,py: LongInt;sa:AnsiString);
//=============================================================================
Var i: LongInt;
    v: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCDrawBGXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011824,'VCDrawBGXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  If length(sa)>0 Then
  Begin
    For i:=1 To length(sa) Do
    Begin
      v:=Pos(sa[i],'01234567');
      If v>0 Then
      Begin
        v-=1;
        VCPutChar(i+px-1,py,' ');
        //VCPutFGC(i+px-1,py,3);
        VCPutBGC(i+px-1,py,v);
      End
      Else
      Begin
        VCPutChar(i+px-1,py,#0);
        //VCPutFGC(i+px-1,py,1);
        //VCPutBGC(i+px-1,py,2);
      End;
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCDrawBGXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWriteln;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteln',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011825,'VCWriteln-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCWrite(crlf);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteln',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure VCWriteln(sa:AnsiString);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteln()',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011826,'VCWriteln()-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCWrite(sa+crlf);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteln()',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWriteXY(X,Y: LongInt; sa: AnsiString) ;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011827,'VCWriteXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCSetPenXY(x,y);
  VCWrite(sa);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWriteCTR(sa:AnsiString);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWriteCTR',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011828,'VCWriteCTR-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If length(sa)>=VCWidth Then
  Begin
    VCWrite(sa);
  End
  Else
  Begin
    VCWriteXY(VCGetCenterX(length(sa)),VCGetPenY,sa);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWriteCTR',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCClrEol;
//=============================================================================
  Var iLoop: LongInt;
      iTempX: LongInt;
      iTempY: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCClrEol',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011829,'VCClrEOL-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  iTempX:=TVCXDLITEM(VC.lpItem).VPX;
  iTempY:=TVCXDLITEM(VC.lpItem).VPY;
  For iLoop:=TVCXDLITEM(VC.lpItem).VPX To TVCXDLITEM(VC.lpItem).VW Do vcwritechar(' ');
  VCSetPenXY(iTempX,iTempY);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCClrEol',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetCenterX(p_iWidth: LongInt): LongInt;
//=============================================================================
// returns xpos that would center something p_iWidth on the screen
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetCenterX',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011830,'VCGetCenterX-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetCenterX:=((TVCXDLITEM(VC.lpItem).VW-p_iWidth) Div 2)+1;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetCenterX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetCenterY(p_iHeight: LongInt): LongInt;
//=============================================================================
// returns xpos that would center something p_iWidth on the screen
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetCenterY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011831,'VCGetCenterY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetCenterY:=((TVCXDLITEM(VC.lpItem).VH-p_iHeight) Div 2)+1;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetCenterY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBox(X,Y: LongInt;W,H: LongInt; ch:Char);
//=============================================================================
Var iX,iY: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBox',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011832,'VCFillBox-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  For iY:=Y To Y+H-1 Do
  Begin
    For iX:=X To W+X-1 Do
    Begin
      VCPutAll(iX, iY, Ord(ch)+(TVCXDLITEM(VC.lpItem).VFGC shl 8)+
                         (TVCXDLITEM(VC.lpItem).VBGC shl 12));

      //VCPutChar(iX,iY,ch);
      //VCPutFGC(iX,iY,TVCXDLITEM(VC.lpItem).VFGC);
      //VCPutBGC(iX,iY,TVCXDLITEM(VC.lpItem).VBGC);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBox',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxCTR(W,H: LongInt; ch:Char);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxCTR',SOURCEFILE);
{$ENDIF}
  {$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011833,'VCFillBoxCtr-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCFillBox(VCGetCenterX(W),VCGetCenterY(H),W,H,ch);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxCTR',SOURCEFILE);
{$ENDIF}

End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxChar(X,Y: LongInt;W,H: LongInt; ch:Char);
//=============================================================================
Var
  t,s: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxChar',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011834,'VCFillBoxChar-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  For s:=y To y+h-1 Do
    For t:=x To x+w-1 Do Begin
      VCPutChar(t,s,ch);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxChar',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxCharCTR(W,H: LongInt; ch:Char);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxCharCTR',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011835,'VCFillBoxCharCtr-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCFillBoxChar(VCGetCenterX(W),VCGetCenterY(H),W,H,ch);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxCharCTR',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxFGC(X,Y: LongInt;W,H: LongInt; p_u1FGC:Byte);
//=============================================================================
Var
  t,s: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxFGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011836,'VCFillBoxFGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  For s:=y To y+h-1 Do
    For t:=x To x+w-1 Do Begin
      VCPutFGC(t,s,p_u1FGC);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxFGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxFGCCTR(W,H: LongInt; p_u1FGC:Byte);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxFGCCTR',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011837,'VCFillBoxFGCCtr-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCFillBoxFGC(VCGetCenterX(W),VCGetCenterY(H),W,H,p_u1FGC);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxFGCCTR',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxBGC(X,Y: LongInt;W,H: LongInt; p_u1BGC:Byte);
//=============================================================================
Var
  t,s: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxBGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011838,'VCFillBoxBGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  For s:=y To y+h-1 Do
    For t:=x To x+w-1 Do Begin
      VCPutBGC(t,s,p_u1BGC);
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxBGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCFillBoxBGCCTR(W,H: LongInt; p_u1BGC:Byte);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCFillBoxBGCCTR',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011839,'VCFillBoxBGCCTR-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCFillBoxBGC(VCGetCenterX(W),VCGetCenterY(H),W,H,p_u1BGC);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCFillBoxBGCCTR',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure VCSetXY(p_iX, p_iY:LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetXY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011840,'VCSetXY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (TVCXDLITEM(VC.lpItem).VX <> p_iX) OR
     (TVCXDLITEM(VC.lpItem).VY <> p_iY) Then
  Begin
    If (TVCXDLITEM(VC.lpItem).VVisible) and
       (TVCXDLITEM(VC.lpItem).bOnScreen)
    Then bInvalid:=True;
    TVCXDLITEM(VC.lpItem).VX:=p_iX;
    TVCXDLITEM(VC.lpItem).VY:=p_iY;
    //UpdateCursor;
    If (TVCXDLITEM(VC.lpItem).VVisible) and
       (TVCXDLITEM(VC.lpItem).bOnScreen)
    Then bInvalid:=True;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetXY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetX: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetX',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011841,'VCGetX-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetX:=TVCXDLITEM(VC.lpItem).VX;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetY: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011842,'VCGetY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetY:=TVCXDLITEM(VC.lpItem).VY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function VCGetPenX: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetPenX',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011843,'VCGetPenX-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetPenX:=TVCXDLITEM(VC.lpItem).VPX;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetPenX',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetPenY: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetPenY',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011844,'VCGetPenY-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetPenY:=TVCXDLITEM(VC.lpItem).VPY;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetPenY',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetPenFGC: Byte;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetPenFGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011845,'VCGetPenFGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetPenFGC:=TVCXDLITEM(VC.lpItem).VFGC;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetPenFGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetPenBGC: Byte;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetPenBGC',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011846,'VCGetPenBGC-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCgetPenBGC:=TVCXDLITEM(VC.lpItem).VBGC;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetPenBGC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetInfo: rtVCInfo;
//=============================================================================
Var rVCInfo: rtVCInfo;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetInfo',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011848,'VCGetInfo-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  rVCInfo.VX:=TVCXDLITEM(VC.lpItem).VX;  // Virtual Screen coords Relative to Real Video Screen
  rVCInfo.VY:=TVCXDLITEM(VC.lpItem).VY;
  rVCInfo.VW:=TVCXDLITEM(VC.lpItem).VW;  // Width of Virtual Screen
  rVCInfo.VH:=TVCXDLITEM(VC.lpItem).VH; // Height of Virtual Screen
  rVCInfo.VPX:=TVCXDLITEM(VC.lpItem).VPX;// Virtual Screen Pen Coords Relative to Real Video Screen
  rVCInfo.VPY:=TVCXDLITEM(VC.lpItem).VPY;
  rVCInfo.VCX:=TVCXDLITEM(VC.lpItem).VCX; // Virtual Screen Blinky Cursor Relative to Real Video Screen
  rVCInfo.VCY:=TVCXDLITEM(VC.lpItem).VCX;
  rVCInfo.VCursorType:=TVCXDLITEM(VC.lpItem).VCursorType;
  rVCInfo.VFGC:=TVCXDLITEM(VC.lpItem).VFGC;
  rVCInfo.VBGC:=TVCXDLITEM(VC.lpItem).VBGC;
  rVCInfo.VTabSize:=TVCXDLITEM(VC.lpItem).VTabSize;
  rVCInfo.VTrackCursor:=TVCXDLITEM(VC.lpItem).VTrackCursor;
  rVCInfo.VWrap:=TVCXDLITEM(VC.lpItem).VWrap; // Word Wrap Flag
  rVCInfo.VTransparency:=TVCXDLITEM(VC.lpItem).VTransparency;
  rVCInfo.VSX:=TVCXDLITEM(VC.lpItem).VSX;
  rVCInfo.VSY:=TVCXDLITEM(VC.lpItem).VSY;
  rVCInfo.VSW:=TVCXDLITEM(VC.lpItem).VSW;
  rVCInfo.VSH:=TVCXDLITEM(VC.lpItem).VSH;
  rVCInfo.VOpaqueFG:=TVCXDLITEM(VC.lpItem).VOpaqueFG;
  rVCInfo.VOpaqueBG:=TVCXDLITEM(VC.lpItem).VOpaqueBG;
  rVCInfo.VVisible:=TVCXDLITEM(VC.lpItem).VVisible;
  rVCInfo.VOpaqueCH:=TVCXDLITEM(VC.lpItem).VOpaqueCH;
  rVCInfo.VUseScrollRegionCoords:=TVCXDLITEM(VC.lpItem).VUseScrollRegionCoords;
  VCGetInfo:=rVCInfo;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetInfo',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetInfo(p_rVCInfo: rtVCInfo);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetInfo',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011849,'VCSetInfo-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
//qqq


  //Jlog(cnLog_Debug,201202011858,'1',SOURCEFILE);
  If (TVCXDLITEM(VC.lpItem).VX <> p_rVCInfo.VX) OR
     (TVCXDLITEM(VC.lpItem).VY <> p_rVCInfo.VY) Then
  Begin
    VCSetXY(p_rVCInfo.VX, p_rVCInfo.VY); // Handles SyncAllVC
  End;

  //Jlog(cnLog_Debug,201202011907,'2',SOURCEFILE);
  If (p_rVCInfo.VW<>TVCXDLITEM(VC.lpItem).VW) OR
     (p_rVCInfo.VH<>TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    TVCXDLITEM(VC.lpItem).Resize(p_rVCInfo.VW, p_rVCInfo.VH);//handles syncAllVC
  End;

  TVCXDLITEM(VC.lpItem).VPX        :=p_rVCInfo.VPX;
  TVCXDLITEM(VC.lpItem).VPY        :=p_rVCInfo.VPY;

  //Jlog(cnLog_Debug,201202011907,'3',SOURCEFILE);
  //if (TVCXDLITEM(VC.lpItem).VCX<>p_rVCInfo.VCX) or
  //   (TVCXDLITEM(VC.lpItem).VCX<>p_rVCInfo.VCY) or
  //   (TVCXDLITEM(VC.lpItem).VCursorType<>p_rVCInfo.VCursortype) then
  //begin
    VCSetCursorXY(p_rVCInfo.VCX,p_rVCInfo.VCY);
    VCSetCursorType(p_rVCInfo.VCursortype);
  //end;

  //Jlog(cnLog_Debug,201202011908,'4',SOURCEFILE);
  TVCXDLITEM(VC.lpItem).VFGC        :=p_rVCInfo.VFGC;
  TVCXDLITEM(VC.lpItem).VBGC        :=p_rVCInfo.VBGC;
  TVCXDLITEM(VC.lpItem).VTabSize    :=p_rVCInfo.VTabSize;
  TVCXDLITEM(VC.lpItem).VTrackCursor:=p_rVCInfo.VTrackCursor;
  TVCXDLITEM(VC.lpItem).VWrap       :=p_rVCInfo.VWrap;

  //Jlog(cnLog_Debug,201202011909,'5',SOURCEFILE);
  If TVCXDLITEM(VC.lpItem).VTransparency <> p_rVCInfo.VTransparency Then
  Begin
    VCSetTransparency(p_rVCInfo.VTransparency); // handles syncallvc
  End;
  If (TVCXDLITEM(VC.lpItem).VSX<>p_rVCInfo.VSX) OR
     (TVCXDLITEM(VC.lpItem).VSY<>p_rVCInfo.VSY) OR
     (TVCXDLITEM(VC.lpItem).VSX<>p_rVCInfo.VSW) OR
     (TVCXDLITEM(VC.lpItem).VSX<>p_rVCInfo.VSH) Then
  Begin
    VCSetScrollRegion(
       p_rVCInfo.VSX, p_rVCInfo.VSY, p_rVCInfo.VSW, p_rVCInfo.VSH
    );
  End;

  //Jlog(cnLog_Debug,201202011910,'6',SOURCEFILE);
  If TVCXDLITEM(VC.lpItem).VOpaqueFG <> p_rVCInfo.VOpaqueFG Then
  Begin
    VCSetOpaqueFG(p_rVCInfo.VOpaqueFG);
  End;

  //Jlog(cnLog_Debug,201202011911,'7',SOURCEFILE);
  If TVCXDLITEM(VC.lpItem).VOpaqueBG <> p_rVCInfo.VOpaqueBG Then
  Begin
    VCSetOpaqueBG(p_rVCInfo.VOpaqueFG);
  End;

  //Jlog(cnLog_Debug,201202011912,'8',SOURCEFILE);
  If TVCXDLITEM(VC.lpItem).VVisible <> p_rVCInfo.VVisible Then
  Begin
    VCSetVisible(p_rVCInfo.VVisible);
  End;

  //Jlog(cnLog_Debug,201202011913,'9',SOURCEFILE);
  If TVCXDLITEM(VC.lpItem).VOpaqueCH <> p_rVCInfo.VOpaqueCH Then
  Begin
    VCSetOpaqueCH(p_rVCInfo.VOpaqueCH);
  End;

  TVCXDLITEM(VC.lpItem).VUseScrollRegionCoords:=p_rVCInfo.VUseScrollRegionCoords;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetInfo',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetTransparency(p_bTransparency:Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetTransparancy',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    Jlog(cnLog_Error,201202011914,'VCSetTransparency-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (TVCXDLITEM(VC.lpItem).VTransparency<>p_bTransparency) and
     (TVCXDLITEM(VC.lpItem).VVisible) and
     (TVCXDLITEM(VC.lpItem).bOnScreen)
  Then bInvalid:=True;
  TVCXDLITEM(VC.lpItem).VTransparency:=p_bTransparency;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetTransparancy',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetTransparency:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetTransparancy',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011915,'VCGetTransparency-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetTransparency:=TVCXDLITEM(VC.lpItem).VTransparency;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetTransparancy',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetTabsize(p_iTabsize: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetTabSize',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011916,'VCSetTabSize-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VTabSize:=p_iTabsize;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetTabSize',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetTabSize: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetTabSize',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011917,'VCGetTabsize-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetTabsize:=TVCXDLITEM(VC.lpItem).VTabsize;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetTabSize',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetWrap(p_bWrap: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetWrap',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011918,'VCSetWrap-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  TVCXDLITEM(VC.lpItem).VWrap:=p_bWrap;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetWrap',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetWrap:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetWrap',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011919,'VCGetWrap-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetWrap:=TVCXDLITEM(VC.lpItem).VWrap;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetWrap',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
//procedure VCSetScroll(p_iX, p_iY, p_iW, p_iH:LongInt);
//=============================================================================
//begin
{IFDEF DEBUGLOGBEGINEND}
//  DebugIN('VCSetScroll',SOURCEFILE);
{ENDIF}
{IFDEF VCCHECK}
//  if VC.Item_VCID<>ActiveVC then
//    JLog(cnLog_Debug,201202011920,'VCSetScroll-VCCHECK ERROR!!');
{ENDIF}
//  TVCXDLITEM(VC.lpItem).VSX:=p_iX;
//  TVCXDLITEM(VC.lpItem).VSY:=p_iY;
//  TVCXDLITEM(VC.lpItem).VSW:=p_iW;
//  TVCXDLITEM(VC.lpItem).VSH:=p_iH;
{IFDEF DEBUGLOGBEGINEND}
//  DebugOUT('VCSetScroll',SOURCEFILE);
{ENDIF}
//end;
//=============================================================================

//=============================================================================
Procedure VCScrollUp;
//=============================================================================
Var t,s: LongInt;
    X,Y: LongInt;
    w:Boolean;
    sx,sy,sw,sh: LongInt;

Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCScrollUp',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011921,'VCScrollUP-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}

  x:=VCGetPenX; y:=VCGetPenY;w:=VCGetWrap;
  VCSetWrap(False);
  PrepareScroll(sx,sy,sw,sh);
  For s:=SY+1 To SH Do
  Begin
    For t:=SX To SW Do
    Begin
      VCPutAll(t,s-1,VCGetAll(t,s));
      If s=SH Then VCWriteXY(t,s,' ');
    End;
  End;
  VCSetPenXY(x,y);VCSetWrap(w);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCScrollUp',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCScrollDown;
//=============================================================================
Var t,s: LongInt;
    X,Y: LongInt;
    w:Boolean;
    sx,sy,sw,sh: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCScrollDown',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011922,'VCScrollDown-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  x:=VCGetPenX; y:=VCGetPenY;w:=VCGetWrap;
  VCSetWrap(False);
  sx:=0;sy:=0;sw:=0;sh:=0;
  PrepareScroll(sx,sy,sw,sh);
  For s:=SH-1 DownTo SY Do
  Begin
    For t:=SX To SW Do
    Begin
      VCPutAll(t,s+1,VCGetAll(t,s));
      If s=1 Then VCWriteXY(t,s,' ');
    End;
  End;
  VCSetPenXY(x,y);VCSetWrap(w);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCScrollDown',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCScrollLeft;
//=============================================================================
Var t,s: LongInt;
    X,Y: LongInt;
    w:Boolean;
    sx,sy,sw,sh: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCScrollLeft',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011923,'VCScrollLeft-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  x:=VCGetPenX; y:=VCGetPenY;w:=VCGetWrap;
  VCSetWrap(False);
  PrepareScroll(sx,sy,sw,sh);
  For t:=SX+1 To SW Do
  Begin
    For s:=SY To SH Do
    Begin
      VCPutAll(t-1,s,VCGetAll(t,s));
      If t=SW Then VCWriteXY(t,s,' ');
    End;
  End;
  VCSetPenXY(x,y);VCSetWrap(w);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCScrollLeft',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCScrollRight;
//=============================================================================
Var t,s: LongInt;
    X,Y: LongInt;
    w:Boolean;
    sx,sy,sw,sh: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCScrollRight',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011924,'VCScrollRight-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  x:=VCGetPenX; y:=VCGetPenY;w:=VCGetWrap;
  VCSetWrap(False);
  PrepareScroll(sx,sy,sw,sh);
  For t:=SW-1 DownTo SX Do
  Begin
    For s:=SY To SH Do
    Begin
      VCPutAll(t+1,s,VCGetAll(t,s));
      If t=1 Then VCWriteXY(t,s,' ');
    End;
  End;
  VCSetPenXY(x,y);VCSetWrap(w);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCScrollRight',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSNRBoxCTR(W,H: LongInt; chfind,chreplace:Char);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSNRBoxCTR',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011925,'VCSNRBoxCtr-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCSNRBox(VCGetCenterX(W),VCGetCenterY(H),W,H,chfind,chreplace);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSNRBoxCTR',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSNRBox(X,Y: LongInt;W,H: LongInt; chfind,chreplace:Char);
//=============================================================================
Var
  t,s: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSNRBox',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011926,'VCSNRBox-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If chFind<>chReplace Then
  Begin
    If (TVCXDLITEM(VC.lpItem).VTransparency) and
       (
        (chFind=#0) OR
        (chReplace=#0) OR
        (chFind=#1) OR
        (chReplace=#1) OR
        (chFind=#2) OR
        (chReplace=#2) OR
        (chFind=#3) OR
        (chReplace=#3)
       )
       Then
    Begin
      If (TVCXDLITEM(VC.lpItem).VVisible) and
         (TVCXDLITEM(VC.lpItem).bOnScreen)
      Then bInvalid:=True;
    End;
    For s:=y To y+h-1 Do
      For t:=x To x+w-1 Do Begin
        If VCGetChar(t,s)=chFind Then VCPutChar(t,s,chreplace);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSNRBox',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetOpaqueFG(p_bOpaque: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetOpaqueFG',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,7,'VCSetOpaqueFG-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (TVCXDLITEM(VC.lpItem).VOpaqueFG <> p_bOpaque) and
     (TVCXDLITEM(VC.lpItem).VVisible) and
     (TVCXDLITEM(VC.lpItem).bOnScreen)
  Then bInvalid:=True;
  TVCXDLITEM(VC.lpItem).VOpaqueFG:=p_bOpaque;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetOpaqueFG',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetOpaqueFG: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetOpaqueFG',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011928,'VCGetOpaqueFG-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetOpaqueFG:=TVCXDLITEM(VC.lpItem).VOpaqueFG;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetOpaqueFG',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetOpaqueBG(p_bOpaque: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetOpaqueBG',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011929,'VCSetOpaqueBG-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (TVCXDLITEM(VC.lpItem).VOpaqueBG <> p_bOpaque) and
     (TVCXDLITEM(VC.lpItem).VVisible) and
     (TVCXDLITEM(VC.lpItem).bOnScreen)
  Then bInvalid:=True;
  TVCXDLITEM(VC.lpItem).VOpaqueBG:=p_bOpaque;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetOpaqueBG',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetOpaqueBG: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetOpaqueBG',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011930,'VCGetOpaqueBG-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetOpaqueBG:=TVCXDLITEM(VC.lpItem).VOpaqueBG;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetOpaqueBG',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCResize(p_iNewWidth, p_iNewHeight: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCResize',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011931,'VCResize-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_iNewWidth <> TVCXDLITEM(VC.lpItem).VW) OR
    (p_iNewHeight <> TVCXDLITEM(VC.lpItem).VH) Then
  Begin
    TVCXDLITEM(VC.lpItem).Resize(p_iNewWidth, p_iNewHeight);
    // Invalidated in TVCXDLITEM.Resize
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCResize',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetVisible(p_b:Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetVisible',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011932,'VCSetVisible-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (p_b<>TVCXDLITEM(VC.lpItem).VVisible) Then
  Begin
    If TVCXDLITEM(VC.lpItem).bOnScreen Then bInvalid:=True;
    TVCXDLITEM(VC.lpItem).VVisible:=p_b;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetVisible',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetVisible:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetVisible',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011933,'VCGetVisible-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetVisible:=TVCXDLITEM(VC.lpItem).VVisible;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetVisible',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetTrackCursor(p_bTrackCursor: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetTrackCursor',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011934,'VCSetTrackCursor-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VTrackCursor:=p_bTrackCursor;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetTrackCursor',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetTrackCursor:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetTrackCursor',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011935,'VCGetTrackCursor-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetTrackCursor:=TVCXDLITEM(VC.lpItem).VTrackCursor;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetTrackCursor',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure SyncAllVC;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('SyncAllVC',SOURCEFILE);
{$ENDIF}
  bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('SyncAllVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetScrollRegion(p_X, p_Y, p_W, p_H: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetScrollRegion',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011936,'VCSetScrollRegion-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VSX:=p_X;
  TVCXDLITEM(VC.lpItem).VSY:=p_Y;
  TVCXDLITEM(VC.lpItem).VSW:=p_W;
  TVCXDLITEM(VC.lpItem).VSH:=p_H;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetScrollRegion',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCGetScrollRegion(Var p_X, p_Y, p_W, p_H: LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetScrollRegion',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011937,'VCGetScrollRegion-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  p_X:=TVCXDLITEM(VC.lpItem).VSX;
  p_Y:=TVCXDLITEM(VC.lpItem).VSY;
  p_W:=TVCXDLITEM(VC.lpItem).VSW;
  p_H:=TVCXDLITEM(VC.lpItem).VSH;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetScrollRegion',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetScroll(p_bEnabled: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetScroll',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011938,'VCSetScroll-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VScroll:=p_bEnabled;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetScroll',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  VCGetScroll: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetScroll',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011939,'VCGetScroll-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetScroll:=TVCXDLITEM(VC.lpItem).VScroll;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetScroll',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetOpaqueCh(p_bOpaque: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetOpaqueCH',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011940,'VCSetOpaqueCh-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  If (TVCXDLITEM(VC.lpItem).VOpaqueCH <> p_bOpaque) and
     (TVCXDLITEM(VC.lpItem).VVisible) and
     (TVCXDLITEM(VC.lpItem).bOnScreen)
  Then bInvalid:=True;
  TVCXDLITEM(VC.lpItem).VOpaqueCH:=p_bOpaque;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetOpaqueCH',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  VCGetOpaqueCH:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetOpaqueCH',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011941,'VCGetOpaqueCh-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetOpaqueCH:=TVCXDLITEM(VC.lpItem).VOpaqueCH;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetOpaqueCH',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCSetUseScrollRegionCoords(p_b: Boolean);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCSetUseScrollRegionCoords',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011942,'VCSetUseScrollRegionCoords-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  TVCXDLITEM(VC.lpItem).VUseScrollRegionCoords:=p_b;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCSetUseScrollRegionCoords',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function VCGetUseScrollRegionCoords: Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetUseScrollRegionCoords',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011943,'VCGetUseScrollRegionCoords-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetUseScrollRegionCoords:=TVCXDLITEM(VC.lpItem).VUseScrollRegionCoords;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetUseScrollRegionCoords',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  VCGetZ: LongInt;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCGetZ',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011944,'VCGetZ-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  VCGetZ:=TVCXDLITEM(VC.lpItem).iZOrder;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCGetZ',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  GetZVC(p_VC: LongInt): LongInt;
//=============================================================================
Var TempVC: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetZVC',SOURCEFILE);
{$ENDIF}
  TempVC:=VC.Item_VCID;
  If VC.FoundItem_VCID(p_VC) Then
    GetZVC:=TVCXDLITEM(VC.lpItem).iZOrder
  Else
    GetZVC:=0;
  VC.FoundItem_VCID(TempVC);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetZVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  GetVCZ(p_Z: LongInt): LongInt;
//=============================================================================
Var TempVC: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('GetVCZ',SOURCEFILE);
{$ENDIF}
  TempVC:=VC.Item_VCID;
  If VC.FoundItem_iZOrder(p_Z) Then
    GetVCZ:=VC.Item_VCID
  Else
    GetVCZ:=0;
  SetActiveVC(TempVC);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('GetVCZ',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure VCWordwrap(p_iWidth,p_iHeight: LongInt; p_saMsg: AnsiString);
//=============================================================================
// this routine writes p_sMsg on the screen in current FG and BG colors
// starting at the current Console Coords VCGetPenX and VCGetPenY and wraps
// at or before p_Width. No Call to UpdateConsole is made.
Var iX,iH,iTX: LongInt;
    TK: JFC_TOKENIZER;
    saTemp: AnsiString;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCWordwrap',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011945,'VCWordwrap-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
  ix:=VCGetPenX;
  iH:=1;
  TK:= JFC_TOKENIZER.create;
  TK.saSeparators:=' ';
  TK.saWhiteSpace:=' ';
  TK.Tokenize(p_saMsg);
  //TK.DumpToTextfile('debug_tokens.txt');
  VCFillBox(VCGetPenX, VCGetPenY, p_iWidth, p_iHeight,' ');
  If tk.ListCount>0 Then
  Begin
    TK.MoveFirst;
    repeat
      saTemp:=TK.Item_saToken;
      repeat
        If length(saTemp)>p_iWidth Then
        Begin
          If VCGetPenX<>iX Then
          Begin
            iH+=1;
            If iH<=p_iHeight Then VCSetPenXY(iX,VCGetPenY+1);
          End;
          VCWrite(saFixedLength(satemp,1,p_iWidth));
          //JLog(cnLog_Debug,201202011946,'Before DeleteString(saTemp,1,'+inttostr(p_iWidth)+'): saTemp:'+saTemp);
          DeleteString(saTemp,1,p_iWidth);
          //JLog(cnLog_Debug,201202011947,'After DeleteString(saTemp,1,'+inttostr(p_iWidth)+'): saTemp:'+saTemp);
        End;
      Until length(saTemp)<=p_iWidth;
      If length(satemp)+VCGetPenX-1>(iX+p_iWidth-1) Then
      Begin
        iH+=1;
        If iH<=p_iHeight Then VCSetPenXY(iX,VCGetPenY+1);
      End;
      iTX:=VCGetPenX;
      If iH<=p_iHeight Then
      Begin
        //JLog(cnLog_Debug,201202011948,'saFixedLength('+saTemp+',1,'+inttostr((iX+p_iWidth)-VCGetPenX)+')');
        VCWrite(saFixedLength(saTemp,1,(iX+p_iWidth)-VCGetPenX));
        //JLog(cnLog_Debug,201202011949,'Result>'+saTemp+'<');
        VCSetPenX(iTX+length(saTemp)+1);
      End;
    Until not tk.movenext;
  End;
  TK.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCWordwrap',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


// This routine starts at 0 Zbuff (nothing) and works up to the ZBuffer Top
// Performance Good for minimal updates (Maybe)
//=============================================================================
Procedure VCRedrawCell(p_vx,p_vy:LongInt); // parameters ONE BASED VC
//=============================================================================
Var rx,ry: LongInt;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('VCRedrawCell',SOURCEFILE);
{$ENDIF}
{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Error,201202011950,'VCRedrawCell Begin-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}


  If not bInvalid Then // Don't bother if Console Invalidated and a
                       // SyncAllVC is going to occur anyway.
  Begin
    If VC.Listcount>0 Then // pretty sure this is precautionary
    Begin
      If (TVCXDLITEM(VC.lpItem).VVisible) and
         (TVCXDLITEM(VC.lpItem).bOnScreen) Then
      Begin
        If (p_vx>0) and (p_vx<=TVCXDLITEM(VC.lpItem).vw) and
           (p_vy>0) and (p_vy<=TVCXDLITEM(VC.lpItem).vh) Then
        Begin
          rx:=(TVCXDLITEM(VC.lpItem).VX-1)+p_vx-1;
          ry:=(TVCXDLITEM(VC.lpItem).VY-1)+p_vy-1;
          If (rx>-1) and (rx<giConsoleWidth) and
             (ry>-1) and (ry<giConsoleHeight) Then
          Begin
            //JLog(cnLog_Debug,201202011951,'console - VCRedrawCell - Calling RedrawCh('+inttostr(rx)+
            //  ','+inttostr(ry)+')');
            RedrawCh(rx,ry);
          End;
        End;
      End;
    End;
  End;

{$IFDEF VCCHECK}
  If VC.Item_VCID<>ActiveVC Then
    JLog(cnLog_Warn,201202011952,'VCRedrawCell END-VCCHECK ERROR!!',SOURCEFILE);
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('VCRedrawCell',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
//procedure VCUpdateCursor;
//=============================================================================
//begin
//  Updatecursor;
//end;
//=============================================================================



// Exported Routines Above
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\
// Private TVCXDLITEM Class Routines and Initialization Routine Below

//=============================================================================
Procedure TVCXDLITEM.CreateVC(p_iVWidth, p_iVHeight:LongInt);
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('TVCXDLITEM.CreateVC',SOURCEFILE);
{$ENDIF}
  VX:=1;  // Virtual Screen coords Relative to Real Video Screen
  VY:=1;
  VW:=p_iVWidth;  // Width of Virtual Screen
  VH:=p_iVHeight; // Height of Virtual Screen
  VPX:=1; // Virtual Screen Pen Coords Relative to Real Video Screen
  VPY:=1;
  VCX:=1; // Virtual Screen Blinky Cursor Relative to Real Video Screen
  VCY:=1;
  VCursorType:=crUnderline;
  VFGC:=lightgray;
  VBGC:=black;
  VTabSize:=8;
  VWrap:=True;
  VTransparency:=False;
  VSX:=1;
  VSY:=1;
  VSW:=VW;
  VSH:=VH;
  VOpaqueFG:=True;
  VOpaqueBG:=True;
  VVisible:=True;
  VTrackCursor:=True;
  VScroll:=True;
  VOpaqueCH:=True;
  VUseScrollRegionCoords:=False;
  GetMem(VBuf, VW*VH*2); // Buffer
  {$IFDEF LESSFRAG}
  MAXMEM:=VW*VH;
  {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('TVCXDLITEM.CreateVC',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor TVCXDLITEM.Destroy;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('TVCXDLITEM.Done',SOURCEFILE);
{$ENDIF}
  FreeMem(VBuf);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('TVCXDLITEM.Done',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

// Responsibility of programmer to adjust Scroll Region to within VC grid.
//=============================================================================
Procedure TVCXDLITEM.Resize(p_iNewWidth, p_iNewHeight: LongInt);
//=============================================================================
Var
  OldVBuf: ^Word;
  t,s: LongInt;
  X,Y: LongInt; // preserve Pen location
  W,H: LongInt; // preserve Width and Height of VC
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIN('TVCXDLITEM.Resize',SOURCEFILE);
{$ENDIF}

  if(p_iNewWidth<1) or (p_iNewHeight<1) then
  begin
    Jlog(cnLog_Warn,201202011554,
      'TVCXDLITEM.Resize - Invalid: Newwidth:' +inttostr(p_iNewWidth) +
      ' newheight:' + inttostr(p_iNewHeight),SOURCEFILE);
  end;
  
  

  If (bOnscreen) and (VVisible) Then bInvalid:=True;
  getmem(OldVBuf,1); freemem(OldVBuf); // shutoff hint
  OldVBuf:=VBuf;
  GetMem(VBuf, p_iNewWidth * p_iNewHeight * 2);
  x:=VPX; // preserve pen location
  y:=VPY;
  w:=VW; // preseve old width and height
  h:=VH;
  // TVCXDLITEM Reflect new parameters
  VW:=p_iNewWidth;
  VH:=p_iNewHeight;
  VCClear; // clear screen with current FGC & BGC and spaces.
  VPX:=x; // put the pen back where it was
  VPY:=y;
  For t:=0 To W-1 Do
  Begin
    For s:=0 To H-1 Do
    Begin
      If (t<=p_iNewWidth-1) and (s<=p_iNewHeight-1) Then
      Begin
        // VBuf[t+s*p_iNewWidth]:=OldVBuf[t+s*H]; think this is bug
        VBuf[t+s*p_iNewWidth]:=OldVBuf[t+s*W];
      End;
    End;
  End;

{$IFDEF LESSFRAG}
  // avoid unecessary memory fragmentation
  If (p_iNewWidth*p_iNewHeight)<=(MAXMEM) Then
  Begin
    For t:=0 To VW-1 Do
    Begin
      For s:=0 To VH-1 Do
      Begin
        OldVBuf[t+s*p_iNewWidth]:=VBuf[t+s*p_iNewWidth];
      End;
    End;
    freemem(vbuf);
    vbuf:=oldvbuf;
  End
  Else
  Begin
    MAXMEM:=p_iNewWidth*p_iNewHeight;
    Freemem(OldVBuf);
  End;
{$ELSE}
  Freemem(OldVBuf);
{$ENDIF}


  If (bOnscreen) and (VVisible) Then bInvalid:=True;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('TVCXDLITEM.Resize',SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TVCXDLITEM.bOnScreen:Boolean;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugIN('TVCXDLITEM.bOnScreen',SOURCEFILE);
  {$ENDIF}
{$ENDIF}
  If (vx<=giConsoleWidth) and ((vx+vw-1)>=1) and
     (vy<=giConsoleHeight) and ((vy+vh-1)>=1) Then
    bOnscreen:=True
  Else
    bOnScreen:=False;
{$IFDEF DEBUGLOGBEGINEND}
  {$IFDEF DEBUGLOWLEVELDRAWING}
  DebugOUT('TVCXDLITEM.bOnScreen',SOURCEFILE);
  {$ENDIF}
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TVCXDL.pvt_CreateItem: TVCXDLITEM;
//=============================================================================
Begin
  // Don't call this directly - use same code
  // thats here but with TBaseItem Child you are gonna use
  Result:=TVCXDLITEM.Create;
  // It would be a good idea putting any class or object init code in here
  // providing you destroy it in the JFCbasedl_deleteitem method below.
  // e.g. TBaseItem(result).PTR:=YourClass.Create;


  // If you want to use the autonumber feature to Uniquely Mark each item
  // with a sequential number (opposed to using a pointer or something)
  // Do IT HERE:
  //TVCXDLITEM(Result).UID:=AutoNumber;
  //JLog(cnLog_Debug,201202011953,'NewVC Autonumber:'+inttostr(TVCXDLITEM(result).UID)+' '+
  //'New Item: '+inttostr(LongInt(result)),SOURCEFILE);

End;
//=============================================================================

//=============================================================================
Procedure TVCXDL.pvt_DestroyItem(p_ptr: pointer);
//=============================================================================
Begin

  // In override version - If you have
  // TBaseItem.PTR containing a pointer to a class or something
  // release its memory here, call its destructor or whatever.
  // E.G. YourClass(TBaseItem(p_ptr).ptr).Destroy;

  // This routine is called from within the class delete routine.
  // don't call this directly!
  TVCXDLITEM(p_ptr).Destroy;
End;
//=============================================================================

//=============================================================================
Function TVCXDL.FoundItem_iZOrder(p_iZOrder: LongInt): Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_iZOrder, sizeof(LongInt), @TVCXDLITEM(nil).iZorder, True,False);
End;
//=============================================================================

//=============================================================================
Function TVCXDL.FoundItem_VCID(p_u: UINT):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_u, sizeof(LongInt), @TVCXDLITEM(nil).UID, True,False);
End;
//=============================================================================

//=============================================================================
Function TVCXDL.read_item_VCID: UINT;
//=============================================================================
Begin
  Result:=TVCXDLITEM(lpitem).UID;
End;
//=============================================================================

//=============================================================================
Procedure TVCXDL.write_item_VCID(p_u: UINT);
//=============================================================================
Begin
  TVCXDLITEM(lpitem).UID:=p_u;
End;
//=============================================================================




//=============================================================================
// Console Unit Init
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  gbConsoleDebugLog:=True;
  DebugIN('u01c_Console Initialization',SOURCEFILE);
  {$ENDIF}

  ConsoleUnitInitialized:=False;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('u01c_Console Initialization',SOURCEFILE);
  {$ENDIF}
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
