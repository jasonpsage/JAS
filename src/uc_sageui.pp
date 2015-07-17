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
// Console Based UI
// Note: If you shell out from this UI, you need to call DoneMouse; followed
// by InitMouse; (found in the FPC rtl/fcl mouse unit: e.g. add "mouse" to you
// program's uses clause to accomplish this.
Unit uc_sageui;
{}
//=============================================================================



//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uc_sageui.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
{$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE DEBUGPAINTWINDOW}  // use for debugging only
{$IFDEF DEBUGPAINTWINDOW}
{$INFO | DEBUGPAINTWINDOW: TRUE}
{$ENDIF}

{DEFINE LOGMESSAGES}       // use for debugging only
{$IFDEF LOGMESSAGES}
{$INFO | LOGMESSAGES: TRUE}
{$ENDIF}

{DEFINE DEBUGTRACKGFXOPS}
{$IFDEF DEBUGTRACKGFXOPS}
{$INFO | DEBUGTRACKGFXOPS: TRUE}
{$ENDIF}

{DEFINE MENURESIZE}        // Implements code that tries to elastise the menus
{$IFDEF MENURESIZE}
{$INFO | MENURESIZE: TRUE}
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
Uses 
//=============================================================================
classes
,sysutils
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_dir
,uc_console
,uc_animate
,uc_library
,ug_jfc_tokenizer

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
// This JFX_XDL list is used by the help system that is integrated into this user interface.
// To use it, you must load it up AFTER you initialize this unit with the InitSageUI
// call but BEFORE you run your application's main message pump. 
//
// Here's how the help system works: we're using the JFC_XDL because it has
// fields in it's out the box form that could do the job. That said, there are
// some fields in the JFC_XDLITEM class we do not use. Here's the breakdown:
//
// JFC_XDLITEM.saName = TopicName
// JFC_XDLITEM.saValue = Text you see
// JFC_XDLITEM.saDesc = Link TopicName
// 
// Basically, you append items which translate to either lines of 
// text or lines of text that are links to other topics. Kind of a cheap 
// hypertext system. By cheap, a given ROW is a link versus individual words
// being potential links.
//
// Below is an example snippet of a short topic in the help. Note the first
// row has information to point to the topic that led the user to this one. 
// this sample points to the default page, but you can have many levels 
// of nested topics. 
//
// 
//                                                         123456789012345678901234567890123456789012345678901234567890123456789012345                 
// WinHelpTopicXDL.AppendItem_XDL(nil,'[Topic Name Here]','[This is text you see but here is a Back link actually pointing to "[HOME]"]','[HOME]',0);
// WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
// WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'This is content','',0);
// WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'More content, note no text in topic column','',0);
//
// In order to get a link on the main help page though so there is alink to your topic, you 
// must call the WinHelpAppendToExistingTopic function with your new data.
var WinHelpTopicXDL: JFC_XDL;
// This function allows you to append lines to a topic in the winhelp listbox help system.
// This is primarily for making your custom topics appear on the main help page but can
// be used to add simple text lines as well. Returns true if all goes well.
//
// p_saTopicToAppend - must be verbatum topic. The default MAIN topic in the help system is named: [HOME]
// note the brackets are patrt of the name.
// 
// p_saVisibleText - the text that will be shown for the given line. You send empty quotes to get a blank line.
//
// p_saTopicToLinkTo - The Name of the Topic you wish to link to. Send empty quotes if you are appending text only and not making a link.
function WinHelpAppendToExistingTopic(
  p_saTopicToAppend: ansistring;
  p_saVisibleText: ansistring;
  p_saTopicToLinkTo: ansistring
): boolean;
// After using WinHelpAppendtoExistingTopic you want to call this function
// to force the list to be reloaded; you see the first help page is already 
// loaded when the InitSageUI call is made. You're appending to this content
// after the fact. So if you want to see it the first time the help is brought
// up, calling this function will insure it. Typically you call it like this
// to reload the first page: WinHelpLoadListBox('[HOME]');
Procedure WinHelpLoadListBox(p_saTopic: ansistring);

// Allows you to force window focus to the NEXT window (pass true) or previous
// window (pass false).
Procedure WindowChangeFocus(p_Forward:Boolean); 


{SageUI STUFF Below}
//=============================================================================
Type rtCreateWindow=Record
//=============================================================================
  saName: ansistring;
  saCaption: AnsiString;
  X: LongInt;
  y: LongInt;
  Width: LongInt;
  Height: LongInt;
  bFrame: Boolean;
  WindowState: Cardinal;
  bCaption: Boolean;
  bMinimizeButton: Boolean;
  bMaximizeButton: Boolean;
  bCloseButton: Boolean;
  bSizable: Boolean;
  bVisible: Boolean;
  bEnabled: Boolean;
  bAlwaysOnTop: Boolean;
  lpfnWndProc: pointer;
End;
//=============================================================================


//=============================================================================
{}
// Record Structure to hold messages 
// NOTE These are all declared as CARDINALs but they get stored and retrieved
// in the MQ (Message Queue) as Integers. This should work - just pay 
// attention. (Endian Width)
Type rtSageMsg = Record
//=============================================================================
  uUID    : UINT;
  uMsg    : UINT;   //< MQ.Item_ID[4]
  uParam1 : UINT;   //< MQ.Item_ID[1]
  uParam2 : UINT;   //< MQ.Item_ID[2]
  uObjType: UINT;  //< MQ.Item_ID[3] JFC_XXDLITEM(OBJECTSXXDL.lpITem).ID[3]
  lpPTR: pointer;       {<MQ.Item_lpPtr   (To Associated Class Or Object)
                        (AS STORED in OBJECTSXXDL.lpPTR)}
    
  {$IFDEF LOGMESSAGES}
  saSender: AnsiString; //<MQ.Item_saName 
  {$ENDIF}
  saDescOldPackedTime: AnsiString;{< Was Where a Packed TimeStamp was Stuffed
                                   I doubt its used, but it could come in 
                                   handy for process handling. Though all 
                                   things seem to point (regarding dates)
                                   that there isn't a 
                                   GetSystemTimeStamp(): TTimeStamp;
                                   Function so this may have a limit to its
                                   usefulness out the gate. Currently, 
                                   JFC_XDLITEM.Create makes the new
                                   JFC_XDLITEM.TS = DateTimeToTimeStamp(now)
                                   which may lose the granular milli seconds 
                                   I want.. not sure... not an issue yet.
                                   2006-09-15 Jason P Sage}
End;
// Underscores added to preserve TEXT. This is a clip from the AppendMessage 
// To Queue routine that resides elsewhere - just to show relationship to the 
//  above _rtSageMsg_ now Called rtSageMsg.
//----
//      _ptr_,               // lpPTR
//      'MsgToText',         // saName
//      'Description',       // saDesc
//      0,                   // i8User 
//      _uParam1_,          // ID1    (Cardinal 32bit, UInt64 on 64bit)
//      _uParam2_,          // ID2
//      _uObjType_,         // ID3
//      _uMsg_              // ID4
//=============================================================================


//=============================================================================
// GLOBAL OBJECTS Collection.
//=============================================================================
{}
// JFC_XXDLITEM - Break down in this context
// lpPTR =Class OBJECT or Pointer for the VC Based Object - E.G. Window.
// 
// ID1   =TYPECASTED - POINTER to UserMsgHandler: Function(var p_rSageMsg: rtSageMsg):Cardinal;
//        By having ONE STANDARD Calling Mechanism defined, Messages can be SENT to ANY OBJECT
//        SO BY DEFAULT - Remember a VALUE OF NIL HERE PREVENTS Messages From Going there.
// ID2   =VCUID From Console Unit
// ID3   =Object Type
// ID4   =Used by SetGUIEnabled (Stores If gVC Hidden or Not)
Var OBJECTSXXDL: JFC_XXDL; 
//=============================================================================






//=============================================================================
{}
Type tc = Class(JFC_XXDL)
//=============================================================================
  {}
  Public
  SELFOBJECTITEM: JFC_XXDLITEM; //< This is ACTUAL element/item in OBJECTSXXDL
  Function bEnabled: Boolean;
  Function bVisible: Boolean;
  Function bPrivate: Boolean;
  Function lpOwner: pointer;
  Function Read_bRedraw: Boolean;
  Procedure Write_bRedraw(p_bRedraw:Boolean);
  Function bCanGetFocus: Boolean;
  Property bRedraw:Boolean read Read_bRedraw Write Write_bRedraw;
  Procedure Kill;
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Function uObjType: UINT;
  Destructor Destroy; override;
  Procedure ProcessKeyBoard(p_u4Key:Cardinal);
  Function iMouseOnAControl: LongInt;
  Procedure ProcessMouse(p_bMouseIdle: Boolean);
  Function uOwnerObjType: UINT;
  //function bPrivateDispatch(var p_rSageMsg: rtSageMsg):boolean;
End;
//=============================================================================




















//=============================================================================
{}
Type TWindow = Class
//=============================================================================
  {}
  SELFOBJECTITEM: JFC_XXDLITEM; //< This is ACTUAL element/item in OBJECTSXXDL
  {}
  //Private // Comments can ignore this keyword
  // CLASS SCOPE
  //u4WUID: Cardinal; // UID in gW(JFC_XXDL)       now OBJECTSXXDL.UID I guess.
  //lpW: pointer;   // PTR to gW(JFC_XXDL)         Now Not really important, is it?
  
  C: tC; {< Control List }
  i4ControlWithFocusUID: longint;
  
  {}
  //C.i4User - Currently has focus
  //C.PTR - Pointer to Control Type's Class
  //C.ID1 - Control Type (See OBJ_LABEL for example)   
  //C.ID2 - Redraw Flag
  //C.ID3 - Tab Order - TODO: Implement
  {}
  bRedraw: Boolean;//< Redraw window/control flag

  i4RWidth:LongInt;   //< these act as a speed dial too - related to effect 
  i4RHeight:LongInt;  //< these act as a speed dial too - related to effect 
  
  
  i4BCloseX,i4BMinX, i4BMaxX: LongInt; //< used to store button hot spots in window frame, button hot spots
  i4MinX, i4MinY: LongInt; //< used to store button hot spots in window frame, Minimized Coords

  
  u1FrameFG: Byte;//< Default Frame Colors
  u1FrameBG: Byte;//< Default Frame Colors
  u1FrameCaptionFG: Byte;//< Default Frame Colors
  u1FrameCaptionBG: Byte;//< Default Frame Colors
  u1FrameWindowFG: Byte;//< Default Frame Colors
  u1FrameWindowBG: Byte;//< Default Frame Colors
  u1FrameSizeFG: Byte;//< Default Frame Colors
  u1FrameSizeBG: Byte;//< Default Frame Colors
  u1FrameDragFG: Byte;//< Default Frame Colors
  u1FrameDragBG: Byte;//< Default Frame Colors

  rW: rtCreateWindow;//< Contains properties related to the window. See rtCreateWindow record structure

  Procedure CalcRelativeSize;//< Calculates relative size of window
  
  Procedure PvtSetFrameColors; //< Called from PaintWindow Only
  Procedure CntlChangeFocus(p_Forward,p_Keypress:Boolean); //< This function gets called to move the focus forward or backward from whatever control has focus when this is called.
  Function i4MinimizedWidth: LongInt;//< returns minimized width of the window
  Procedure ProcessKeyboard(p_u4Key: Cardinal);//< Handles keypresses
  Procedure ProcessMouse(p_bMouseIdle: Boolean);//<handles mouse
  {}
  
  //  function bCTLPRivate(p_CTLUID: Cardinal): boolean;
  {}
  Function Read_VCUID: INT;//<read the Virtual Console UID
  Function Read_i4MinX:LongInt; //< read the minimum X (width?)
  Procedure Write_i4MinX(p_i4MinX:LongInt);//< write the minimum X (width?)
  Function Read_i4MinY:LongInt;//< read the minimum Y (height?)
  Procedure Write_i4MinY(p_i4MinY:LongInt);//< write the minimum Y (height?)
  Function Read_u1FrameFG:Byte;//<REad Frame Foreground color 
  Procedure Write_u1FrameFG(p_u1FrameFG:Byte);//<write frame foreground color
  Function Read_u1FrameBG:Byte;//<Read frame background color 
  Procedure Write_u1FrameBG(p_u1FrameBG:Byte);//<write frame background color
  Function Read_u1FrameCaptionFG:Byte;//<read frame caption foreground color
  Procedure Write_u1FrameCaptionFG(p_u1FrameCaptionFG:Byte);//<write frame caption foreground color
  Function Read_u1FrameCaptionBG:Byte;//<Read Frame Caption background color
  Procedure Write_u1FrameCaptionBG(p_u1FrameCaptionBG:Byte);//<Write frame caption background color
  Function Read_u1FrameWindowFG:Byte;//<read Frame window foreground color
  Procedure Write_u1FrameWindowFG(p_u1FrameWindowFG:Byte);//<write frame window foreground color
  Function Read_u1FrameWindowBG:Byte;//<Read frame window background color
  Procedure Write_u1FrameWindowBG(p_u1FrameWindowBG:Byte);//<write frame window background color
  Function Read_u1FrameSizeFG:Byte; //< read the frame sizing border foreground color
  Procedure Write_u1FrameSizeFG(p_u1FrameSizeFG:Byte);//<write the frame sizing border foreground color
  Function Read_u1FrameSizeBG:Byte;
  Procedure Write_u1FrameSizeBG(p_u1FrameSizeBG:Byte);
  Function Read_u1FrameDragFG:Byte; 
  Procedure Write_u1FrameDragFG(p_u1FrameDragFG:Byte);
  Function Read_u1FrameDragBG:Byte; 
  Procedure Write_u1FrameDragBG(p_u1FrameDragBG:Byte);
  Function Read_RW_saCaption: AnsiString; 
  Procedure Write_RW_saCaption(p_saCaption:AnsiString);
  Function Read_RW_X:LongInt; 
  Procedure Write_RW_X(p_X:LongInt);
  Function Read_RW_Y:LongInt; 
  Procedure Write_RW_Y(p_Y:LongInt);
  Function Read_RW_Width:LongInt; 
  Procedure Write_RW_Width(p_Width:LongInt);
  Function Read_RW_Height:LongInt;
  Procedure Write_RW_Height(p_Height:LongInt);
  Function Read_RW_bFrame:Boolean;
  Procedure Write_RW_bFrame(p_bFrame:Boolean);
  Function Read_RW_WindowState:Cardinal;
  Procedure Write_RW_WindowState(p_WindowState:Cardinal);
  Function Read_RW_bCaption:Boolean;
  Procedure Write_RW_bCaption(p_bCaption:Boolean);
  Function Read_RW_bMinimizeButton:Boolean; 
  Procedure Write_RW_bMinimizeButton(p_bMinimizeButton:Boolean);
  Function Read_RW_bMaximizeButton:Boolean; 
  Procedure Write_RW_bMaximizeButton(p_bMaximizeButton:Boolean);
  Function Read_RW_bCloseButton:Boolean;
  Procedure Write_RW_bCloseButton(p_bCloseButton:Boolean);
  Function Read_RW_bSizable:Boolean;
  Procedure Write_RW_bSizable(p_bSizable:Boolean);
  Function Read_RW_bVisible:Boolean;
  Procedure Write_RW_bVisible(p_bVisible:Boolean);
  Function Read_RW_bEnabled:Boolean;
  Procedure Write_RW_bEnabled(p_bEnabled:Boolean);
  Function Read_RW_bAlwaysOnTop:Boolean;
  Procedure Write_bAlwaysOnTop(p_bAlwaysOnTop:Boolean);
  Function Read_RW_lpfnWndProc:pointer;

  Public
  Constructor create(p_RCW: rtCreateWindow);
  Destructor  Destroy; override;
  Procedure PaintWindow;
 
  Property VC: INT read Read_VCUID;
  Property MinX: LongInt read Read_i4MinX Write Write_i4MinX;
  Property MinY: LongInt read Read_i4MinY Write Write_i4MinY;
  Property FrameFG: Byte read Read_u1FrameFG Write Write_u1FrameFG;
  Property FrameBG: Byte read Read_u1FrameBG Write Write_u1FrameBG;
  Property FrameCaptionFG: Byte read Read_u1FrameCaptionFG Write Write_u1FrameCaptionFG;
  Property FrameCaptionBG: Byte read Read_u1FrameCaptionBG Write Write_u1FrameCaptionBG;
  Property FrameWindowFG: Byte read Read_u1FrameWindowFG Write Write_u1FrameWindowFG;
  Property FrameWindowBG: Byte read Read_u1FrameWindowBG Write Write_u1FrameWindowBG;
  Property FrameSizeFG: Byte read Read_u1FrameSizeFG Write Write_u1FrameSizeFG;
  Property FrameSizeBG: Byte read Read_u1FrameSizeBG Write Write_u1FrameSizeBG;
  Property FrameDragFG: Byte read Read_u1FrameDragFG Write Write_u1FrameDragFG;
  Property FrameDragBG: Byte reAd Read_u1FrameDragBG Write Write_u1FrameDragBG;
  Property Caption: AnsiString Read Read_RW_saCaption Write Write_RW_saCaption;
  Property X: LongInt read Read_RW_X Write Write_RW_X;
  Property Y: LongInt read Read_RW_Y Write Write_RW_Y;
  Property Width: LongInt read Read_RW_Width Write Write_RW_Width;
  Property Height: LongInt read Read_RW_Height Write Write_RW_Height;
  Property Frame: Boolean read Read_RW_bFrame Write Write_RW_bFrame;
  Property WindowState: Cardinal read Read_RW_WindowState Write Write_RW_WindowState;
  Property CaptionVisible: Boolean read Read_RW_bCaption Write Write_RW_bCaption;
  Property MinimizeButton: Boolean read Read_RW_bMinimizeButton Write Write_RW_bMinimizeButton;
  Property MaximizeButton: Boolean read Read_RW_bMaximizeButton Write Write_RW_bMaximizeButton;
  Property CloseButton: Boolean read Read_RW_bCloseButton Write Write_RW_bCloseButton;
  Property Sizable: Boolean read Read_RW_bSizable Write Write_RW_bSizable;
  Property Visible: Boolean read Read_RW_bVisible Write Write_RW_bVisible;
  Property Enabled: Boolean read Read_RW_bEnabled Write Write_RW_bEnabled;
  Property AlwaysOnTop: Boolean read Read_RW_bAlwaysOnTop Write Write_bAlwaysOnTop;
  Property MsgHandlerAddr: pointer read Read_RW_lpfnWndProc;

  Function CurrentCTLID: UINT;
  Function ControlCTLPTR: pointer;
  Function HasFocus: Boolean;
  Procedure SetFocus;
  //Procedure UnfocusAllControls;
End;
//=============================================================================




//=============================================================================
{}
Type TCTLBASE = Class
//=============================================================================
  {}
  Private 
  //-------------------
  // CLASS SCOPE
  //-------------------
  {}
  {}
  //-------------------
  {}
  bPrivate: Boolean;
  uOwnerObjType: UINT;
  lpOwner: pointer;
  bHasChildren: boolean;

  bEnabled: Boolean;
  bVisible: Boolean;
  i4X: LongInt;
  i4Y: LongInt;
  
  Procedure ProcessKeyboard(p_u4Key: Cardinal); Virtual;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); Virtual;

  Function Read_bEnabled:Boolean;
  Procedure Write_bEnabled(p_bEnabled:Boolean);
  Function Read_bVisible:Boolean;
  Procedure Write_bVisible(p_bVisible:Boolean);
  Function Read_i4X:LongInt;
  Procedure Write_i4X(p_i4X:LongInt);
  Function Read_i4Y:LongInt;
  Procedure Write_i4Y(p_i4Y:LongInt);
  Function Read_ID:UINT;
  Procedure Write_bRedraw(p_bRedraw:boolean);

  Public 
  Constructor create(p_TWindow:TWindow);
  Destructor  Destroy; override;

  Public
  lpTWindow: pointer; // Owning Window
  CTLUID: UINT; //< UID in CTL(JFC_XXDL)
  lpCTL: pointer;   //< PTR to CTL(JFC_XXDL)

  Property Enabled: Boolean read Read_bEnabled Write Write_bEnabled;
  Property Visible: Boolean read Read_bVisible  Write Write_bVisible;
  Property X: LongInt read Read_i4X Write Write_i4X;
  Property Y: LongInt read Read_i4Y Write Write_i4Y;
  
  Property ID: UINT read Read_ID; //<actually "self" Pointer typecasted
  Property UID: UINT read CTLUID;
  Property Redraw: Boolean Write Write_bRedraw;
  
End;
//=============================================================================

//=============================================================================
{}
Type TCTLLABEL = Class(TCTLBASE)
//=============================================================================
  Private
  i4Width: LongInt;
  i4Height: LongInt;
  u1FG: Byte;
  u1BG: Byte;
  saCaption: AnsiString;  
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);

  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_i4Height:LongInt;
  Procedure Write_i4Height(p_i4Height:LongInt);
  Function Read_u1FG:Byte;
  Procedure Write_u1FG(p_u1FG:Byte);
  Function Read_u1BG:Byte;
  Procedure Write_u1BG(p_u1BG:Byte);
  Function Read_saCaption:AnsiString;
  Procedure Write_saCaption(p_saCaption:AnsiString);
  
  Public
  Constructor create(p_TWindow:TWindow);
  Property Width: LongInt read Read_i4Width Write Write_i4Width;
  Property Height: LongInt read Read_i4Height Write Write_i4Height;
  Property TextColor: Byte read Read_u1FG Write Write_u1FG;
  Property BackColor: Byte read Read_u1BG Write Write_u1BG;
  Property Caption: AnsiString read Read_saCaption Write Write_saCaption;
End;
//=============================================================================

//=============================================================================
{}
Type TCTLVScrollBar = Class(TCTLBASE)
//=============================================================================
  {}
  Private  
  i4Height, i4MaxValue, i4Value: LongInt;

  u1ScrollBarSlideFG: Byte;
  u1ScrollBarSlideBG: Byte;
  u1ScrollBarFG: Byte;
  u1ScrollBarBG: Byte;

  chScrollBarUpArrow: Char;
  chScrollBarDownArrow: Char;
  chScrollBarVMarker: Char;
  chScrollBarSlide: Char;

  {}
  { NOTE: This wasn''t understood, so in the scrollbar routine I 
    used a local variable named i4t.
    used internally (2006-09-16 Jason P Sage)
  ---------------  
  iT: LongInt;
  --------------
  }
  {}
  
  i4VScroll: LongInt;
  dVSize: Real;
  dVIndex: Real;
  dVPercent: Real;
  dVSSize: Real;
  dVSIndex: Real;

  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure CalcMe;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;

  Function Read_i4Height:LongInt;
  Procedure Write_i4Height(p_i4Height:LongInt);
  Function Read_i4MaxValue:LongInt;
  Procedure Write_i4MaxValue(p_i4MaxValue:LongInt);
  Function Read_i4Value:LongInt;
  Procedure Write_i4Value(p_i4Value:LongInt);
  Function Read_chScrollBarUpArrow:Char;
  Procedure Write_chScrollBarUpArrow(p_chScrollBarUpArrow:Char);
  Function Read_chScrollBarDownArrow:Char;
  Procedure Write_chScrollBarDownArrow(p_chScrollBarDownArrow:Char);
  Function Read_chScrollBarVMarker:Char;
  Procedure Write_chScrollBarVMarker(p_chScrollBarVMarker:Char);
  Function Read_chScrollBarSlide:Char;
  Procedure Write_chScrollBarSlide(p_chScrollBarSlide:Char);
  Function Read_u1ScrollBarSlideFG:Byte;
  Procedure Write_u1ScrollBarSlideFG(p_u1ScrollBarSlideFG:Byte);
  Function Read_u1ScrollBarSlideBG:Byte;
  Procedure Write_u1ScrollBarSlideBG(p_u1ScrollBarSlideBG:Byte);
  Function Read_u1ScrollBarFG:Byte;
  Procedure Write_u1ScrollBarFG(p_u1ScrollBarFG:Byte);
  Function Read_u1ScrollBarBG:Byte;
  Procedure Write_u1ScrollBarBG(p_u1ScrollBarBG:Byte);

  Public 
  Constructor create(p_TWindow:TWindow);
  
  Property Height: LongInt read Read_i4Height Write Write_i4Height;
  Property MaxValue: LongInt read Read_i4MaxValue Write Write_i4MaxValue;  
  Property Value: LongInt read Read_i4Value Write Write_i4Value;
  Property CharUpArrow:  Char read   Read_chScrollBarUpArrow
                             Write Write_chScrollBarUpArrow;
  Property CharDownArrow: Char read   Read_chScrollBarDownArrow
                             Write Write_chScrollBarDownArrow;
  Property CharMarker: Char read   Read_chScrollBarVMarker
                             Write Write_chScrollBarVMarker;
  Property CharSlide : Char read   Read_chScrollBarSlide
                             Write Write_chScrollBarSlide;
  Property SlideTextColor: Byte read Read_u1ScrollBarSlideFG 
                                     Write Write_u1ScrollBarSlideFG;
  Property SlideBackColor: Byte read Read_u1ScrollBarSlideBG 
                                     Write Write_u1ScrollBarSlideBG;
  Property TextColor: Byte read Read_u1ScrollBarFG 
                           Write Write_u1ScrollBarFG;
  Property BackColor: Byte read Read_u1ScrollBArBG 
                           Write Write_u1ScrollBArBG;
End;
//=============================================================================

//=============================================================================
{}
Type TCTLHScrollBar = Class(TCTLBASE)
//=============================================================================
  {}
  Private 
  i4Width, i4MaxValue, i4Value: LongInt;
  
  u1ScrollBarSlideFG: Byte;
  u1ScrollBarSlideBG: Byte;
  u1ScrollBarFG: Byte;
  u1ScrollBarBG: Byte;

  {}
  { NOTE: This wasn''t understood, so in the scrollbar routine I 
    used a local variable named i4t.
    used internally (2006-09-16 Jason P Sage)
    iT: LongInt;
  }
  {}
  i4HScroll: LongInt;
  dHSize: Real;
  dHIndex: Real;
  dHPercent: Real;
  dHSSize: Real;
  dHSIndex: Real;

  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure CalcMe;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;


  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_i4MaxValue:LongInt;
  Procedure Write_i4MaxValue(p_i4MaxValue:LongInt);
  Function Read_i4Value:LongInt;
  Procedure Write_i4Value(p_i4Value:LongInt);
  Function Read_u1ScrollBarSlideFG:Byte;
  Procedure Write_u1ScrollBarSlideFG(p_u1ScrollBarSlideFG:Byte);
  Function Read_u1ScrollBarSlideBG:Byte;
  Procedure Write_u1ScrollBarSlideBG(p_u1ScrollBarSlideBG:Byte);
  Function Read_u1ScrollBarFG:Byte;
  Procedure Write_u1ScrollBarFG(p_u1ScrollBarFG:Byte);
  Function Read_u1ScrollBarBG:Byte;
  Procedure Write_u1ScrollBarBG(p_u1ScrollBarBG:Byte);


  Public
  Constructor create(p_TWindow:TWindow);
  
  Property Width : LongInt read Read_i4Width Write Write_i4Width;
  Property MaxValue: LongInt read Read_i4MaxValue Write Write_i4MaxValue;  
  Property Value: LongInt read Read_i4Value Write Write_i4Value;
  Property SlideTextColor: Byte read Read_u1ScrollBarSlideFG 
                                     Write Write_u1ScrollBarSlideFG;
  Property SlideBackColor: Byte read Read_u1ScrollBarSlideBG 
                                     Write Write_u1ScrollBarSlideBG;
  Property TextColor: Byte read Read_u1ScrollBarFG 
                           Write Write_u1ScrollBarFG;
  Property BackColor: Byte read Read_u1ScrollBArBG 
                           Write Write_u1ScrollBArBG;
End;
//=============================================================================

//=============================================================================
{}
Type TCTLPROGRESSBAR = Class(TCTLBASE)
//=============================================================================
  {}
  Private 
  i4Width, i4MaxValue, i4Value: LongInt;

  u1ProgressBarSlideFG: Byte;
  u1ProgressBarSlideBG: Byte;
  u1ProgressBarMarkerFG: Byte;
  u1ProgressBarMarkerBG: Byte;
  chProgressBarSlide: Char;
  chProgressBarMarker: Char;
  

  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_chProgressBarSlide:Char;
  Procedure Write_chProgressBArSlide(p_chProgressBarSlide:Char);
  Function Read_chProgressBarmarker:Char;
  Procedure Write_chProgressBArmarker(p_chProgressBarmarker:Char);
  Function Read_u1ProgressBarSlideFG:Byte;
  Procedure Write_u1ProgressBarSlideFG(p_u1ProgressBarSlideFG:Byte);
  Function Read_u1ProgressBarSlideBG:Byte;
  Procedure Write_u1ProgressBarSlideBG(p_u1ProgressBarSlideBG:Byte);
  Function Read_u1ProgressBarMarkerFG:Byte;
  Procedure Write_u1ProgressBarMarkerFG(p_u1ProgressBarMarkerFG:Byte);
  Function Read_u1ProgressBarMarkerBG:Byte;
  Procedure Write_u1ProgressBarMarkerBG(p_u1ProgressBarMarkerBG:Byte);
  Function Read_i4MaxValue:LongInt;
  Procedure Write_i4MaxValue(p_i4MaxValue:LongInt);
  Function Read_i4Value:LongInt;
  Procedure Write_i4Value(p_i4Value:LongInt);
  


  Public
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Constructor create(p_TWindow:TWindow);
  Property Width: LongInt read Read_i4Width Write Write_i4Width;
  Property CharSlide : Char read Read_chProgressBarSlide
                          Write Write_chProgressBArSlide;
  Property CharMarker: Char read Read_chProgressBarMarker
                          Write Write_chProgressBarMarker;
  Property SlideTextColor: Byte read Read_u1ProgressBarSlideFG 
                                     Write Write_u1ProgressBarSlideFG;
  Property SlideBackColor: Byte read Read_u1ProgressBarSlideBG 
                                     Write Write_u1ProgressBarSlideBG;
  Property TextColor: Byte read Read_u1ProgressBarMarkerFG 
                           Write Write_u1ProgressBarMarkerFG;
  Property BackColor: Byte read Read_u1ProgressBArMarkerBG 
                           Write Write_u1ProgressBArMarkerBG;
  Property MaxValue: LongInt read Read_i4MaxValue Write Write_i4MaxValue;  
  Property Value: LongInt read Read_i4Value Write Write_i4Value;


End;
//=============================================================================


//=============================================================================
{ This is a fixed Input Box}
Type TCTLINPUT = Class(TCTLBASE)
//=============================================================================
  {}
  Private 
  i4CurPos: LongInt; //< Where the Blinky is in relation to the control
  i4Index: LongInt;  //< index in saData to begin Writing in Input control
  i4MaxLength: LongInt; //< Longest possible saData. ZERO - (Default) No limit.
  i4Width: LongInt;
  i4SelStart, i4SelLength: LongInt;
  i4OldSelStart, i4OldSelLength: LongInt;
  i4OldRealCurPos: LongInt;
  {}
  //i4MaxLength: LongInt;
  {}
  saData: AnsiString;
  saUndo: AnsiString;
  bPassword:Boolean;

  Procedure StartSelection;
  Procedure EndSelection(p_bMouse: Boolean);
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure ProcessKeyBoard(p_u4Key: Cardinal); override;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;

  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_saData:AnsiString;
  Procedure Write_saData(p_saData:AnsiString);
  Function Read_i4SelStart:LongInt;
  Procedure Write_i4SelStart(p_i4SelStart:LongInt);
  Function Read_i4SelLength:LongInt;
  Procedure Write_i4SelLength(p_i4SelLength:LongInt);
  Function Read_i4RealCurPos:LongInt;
  Procedure Write_i4RealCurPos(p_i4RealCurPos:LongInt);
  Function Read_bPAssword:Boolean;
  Procedure Write_bPassword(p_bPassword:Boolean);
  Function read_i4MaxLength: LongInt;
  Procedure write_i4MaxLength(p_i:Integer);
  
  Public
  Constructor create(p_TWindow:TWindow);

  Property Width: LongInt read Read_i4Width Write Write_i4Width;
    
  Property Data: AnsiString read Read_saData Write Write_saData;
  Property SelStart: LongInt read Read_i4SelStart Write Write_i4SelStart;
  Property SelLength: LongInt read Read_i4SelLength Write Write_i4SelLength;

  
  Property CursorPos: LongInt read Read_i4RealCurPos Write Write_i4RealCurPos;//< Real Cursor Position
  Property IsPassword: Boolean read Read_bPassword Write Write_bPassword;//< Real Cursor Position
  Property MaxLength: LongInt read read_i4MaxLength Write write_i4Maxlength;//< Real Cursor Position
End;
//=============================================================================

//=============================================================================
{}
Type TCTLBUTTON = Class(TCTLBASE)
//=============================================================================
  {}
  Private
  bUp: Boolean;
  i4Width: LongInt;
  saCaption: AnsiString;
  chHotKey: Char;
  bSticky: Boolean;

  u1ButtonHotKeyFG: Byte;
  u1ButtonFGFocus: Byte;
  u1ButtonBGFocus: Byte; //< focused
  u1ButtonFG: Byte;
  u1ButtonBG: Byte;
  u1ButtonFGDisabled: Byte;

  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure ProcessKeyBoard(p_u4Key: Cardinal); override;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;
  
  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_bSticky:Boolean;
  Procedure Write_bSticky(p_bSticky:Boolean);
  Function Read_u1ButtonHotKeyFG:Byte;
  Procedure Write_u1ButtonHotKeyFG(p_u1ButtonHotKeyFG:Byte);
  Function Read_u1ButtonFGFocus: Byte;
  Procedure Write_u1ButtonFGFocus(p_u1ButtonFGFocus:Byte);
  Function Read_u1ButtonBGFocus: Byte;
  Procedure Write_u1ButtonBGFocus(p_u1ButtonBGFocus:Byte);
  Function Read_u1ButtonFG:Byte;
  Procedure Write_u1ButtonFG(p_u1ButtonFG:Byte);
  Function Read_u1ButtonBG:Byte;
  Procedure Write_u1ButtonBG(p_u1ButtonBG:Byte);
  Function Read_u1ButtonFGDisabled:Byte;
  Procedure Write_u1ButtonFGDisabled(p_u1ButtonFGDisabled:Byte);
  Function Read_saCaption:AnsiString;
  Procedure Write_saCaption(p_saCaption:AnsiString);
  

  Public 
  Constructor create(p_TWindow:TWindow);
  
  Property Width: LongInt read Read_i4Width Write Write_i4Width;
  Property Sticky: Boolean read read_bSticky Write write_bsticky;
  Property HotKeyTextColor: Byte read Read_u1ButtonHotKeyFG
                                 Write Write_u1ButtonHotKeyFG;
  Property FocusTextColor: Byte read Read_u1ButtonFGFocus
                                 Write Write_u1ButtonFGFocus;
  Property FocusBackColor: Byte read Read_u1ButtonBGFocus
                                 Write Write_u1ButtonBGFocus;
  Property TextColor: Byte read Read_u1ButtonFG Write Write_u1ButtonFG;
  Property BackColor: Byte read Read_u1ButtonBG Write Write_u1ButtonBG;
       
  Property DisabledTextColor: Byte Read read_u1ButtonFGDisabled   
                                   Write Write_u1ButtonFGDisabled;
  Property Caption: AnsiString read Read_saCaption Write Write_saCaption;
  
End;
//=============================================================================

//=============================================================================
{}
Type TCTLCHECKBOX = Class(TCTLBASE)
//=============================================================================
  {}
  Private
  i4Width: LongInt;
  u1FG: Byte;
  u1BG: Byte;
  u1CheckFG: Byte;
  u1CheckBG: Byte;
  bChecked: Boolean;
  saCaption: AnsiString;
  bRadioStyle: Boolean;
  
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure ProcessKeyBoard(p_u4Key: Cardinal); override;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;

  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_u1FG:Byte;
  Procedure Write_u1FG(p_u1FG:Byte);
  Function Read_u1BG:Byte;
  Procedure Write_u1BG(p_u1BG:Byte);
  Function Read_u1CheckFG:Byte;
  Procedure Write_u1CheckFG(p_u1CheckFG:Byte);
  Function Read_u1CheckBG:Byte;
  Procedure Write_u1CheckBG(p_u1CheckBG:Byte);
  Function Read_bChecked: Boolean;
  Procedure Write_bChecked(p_bChecked:Boolean);
  Function Read_saCaption:AnsiString;
  Procedure Write_saCaption(p_saCaption:AnsiString);
  Function Read_bRadioStyle: Boolean;
  Procedure Write_bRadioStyle(p_bRadioStyle: Boolean);
    
  Public
  Constructor create(p_TWindow:TWindow);
  Property Width: LongInt read Read_i4Width Write Write_i4Width;
  Property TextColor: Byte read Read_u1FG Write Write_u1FG;
  Property BackColor: Byte read Read_u1BG Write Write_u1BG;
  Property CheckTextColor: Byte read Read_u1CheckFG Write Write_u1CheckFG;
  Property CheckBackColor: Byte read Read_u1CheckBG Write Write_u1CheckBG;
  Property Checked: Boolean read Read_bChecked Write Write_bChecked;
  Property Caption: AnsiString read Read_saCaption Write Write_saCaption;
  Property RadioStyle: Boolean read Read_bRadioStyle Write Write_bRadioStyle;

End;
//=============================================================================


//=============================================================================
{}
Type TCTLLISTBOX = Class(TCTLBASE)
//=============================================================================
  {}
  Private
  bSorting: Boolean;
  
  i4Width: LongInt;
  i4Height: LongInt;
  i4DataWidth: LongInt;
  u1FG: Byte;
  u1BG: Byte;
  bShowCheckMarks: Boolean;
  CPL: JFC_XDL; //< Caption List
  DTL: JFC_XDL; //< Data List
  i4Top: LongInt;  //< Position Scroll Up/Down offset
  i4Left: LongInt; //< position scroll left/right offset
  
  HScrollBar: tctlHScrollBar;
  VScrollBar: tctlVScrollBar;
  
  {}
  //procedure PrivateMessage(var p_rSageMsg: rtSageMsg);
  {}
  Procedure paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
  Procedure ProcessKeyBoard(p_u4Key: Cardinal); override;
  Procedure ProcessMouse(p_bMouseIdle: Boolean); override;

  Function Read_i4Width:LongInt;
  Procedure Write_i4Width(p_i4Width:LongInt);
  Function Read_i4Height:LongInt;
  Procedure Write_i4Height(p_i4Height:LongInt);
  Function Read_i4DataWidth:LongInt;
  Procedure Write_i4DataWidth(p_i4DataWidth:LongInt);
  
  Function Read_u1FG:Byte;
  Procedure Write_u1FG(p_u1FG:Byte);
  Function Read_u1BG:Byte;
  Procedure Write_u1BG(p_u1BG:Byte);
  Function read_CurrentItem:LongInt;
  Procedure write_currentItem(p_N: LongInt);
  Function Read_Selected:Boolean;
  Procedure Write_selected(p_bSelected: Boolean);
  Function read_itemtext: AnsiString;
  Procedure write_itemtext(p_ItemText: AnsiString);
  Function Read_bShowCheckMarks:Boolean;
  Procedure Write_bShowCheckMarks(p_bShowCheckMarks:Boolean);
  Function read_itemtag: longint;
  Procedure write_itemtag(p_i4Tag: longint);

  Public
  Constructor create(p_TWindow:TWindow);
  Destructor Destroy; override;
  Property Width: LongInt read Read_i4Width Write Write_i4Width;
  Property Height: LongInt read Read_i4Height Write Write_i4Height;
  Property DataWidth: LongInt read Read_i4DataWidth Write Write_i4DataWidth;
  Property TextColor: Byte read Read_u1FG Write Write_u1FG;
  Property BackColor: Byte read Read_u1BG Write Write_u1BG;
  {}
  //property CaptionCount read CDL.ListCount;
  {}
  Property CurrentItem: LongInt read Read_CurrentItem Write Write_CurrentItem;
  Property Selected: Boolean read Read_Selected Write Write_Selected;
  Function ListCount: LongInt;
  Procedure Append(p_bSelected: Boolean; p_saData: AnsiString);
  Procedure Insert(p_bSelected: Boolean; p_saData: AnsiString);
  Procedure Delete;
  Procedure AppendCaption(p_saCaption: AnsiString);
  Procedure DeleteAllCaptions;
  Function GetCaption(p_N:LongInt): AnsiString;
  Procedure SetCaption(p_N:LongInt;p_sa:AnsiString);
  Procedure Sort(p_bForward: Boolean; p_bCaseSensitive: Boolean);
  Procedure deleteall;
  Procedure ChangeItemFG(p_u1FG: Byte);
  Property ItemText: AnsiString read read_ItemText Write Write_itemtext;
  Property ShowCheckMarks: Boolean read Read_bShowCheckMarks Write Write_bShowCheckMarks;
  Property ItemTag: longint read read_ItemTag Write Write_itemtag;
End;
//=============================================================================
















//=============================================================================
{}
Const
//=============================================================================
  // Begin------------------------------------------------------- Object Types
  {}
  OBJ_NONE               = 0;
  OBJ_VCMAIN             = 1;
  OBJ_VCSTATUSBAR        = 2;
  OBJ_MENUBAR            = 3;
  OBJ_MENUBARPOPUP       = 4;
  OBJ_WINDOW             = 5;
  OBJ_LABEL              = 6;  
  OBJ_VSCROLLBAR         = 7;
  OBJ_HSCROLLBAR         = 8;
  OBJ_PROGRESSBAR        = 9;
  OBJ_INPUT              =10;
  OBJ_BUTTON             =11;
  OBJ_CHECKBOX           =12;
  OBJ_LISTBOX            =13;
  OBJ_TREE               =14;
  OBJ_VCDEBUGMESSAGES    =15;
  OBJ_VCDEBUGKEYPRESS    =16;
  OBJ_VCDEBUGKEYBOARD    =17;
  OBJ_VCDEBUGMOUSE       =18;
  OBJ_VCDEBUGMQ          =19;
  OBJ_VCDEBUGSTATUSBAR   =20;
  OBJ_THREADTERMINATED   =22;
  OBJ_VCDEBUGWINDOWS     =23;
  OBJ_VCSTARANIMATION    =24;
  // End  ------------------------------------------------------- Object Types
  


  // Begin------------------------------------------------------- Window State
  {}
  WS_NORMAL            =0;{< Program Relies on These Actual Values for cycling through
                             window states when user uses keyboard (CNTL+SPACE).}
  WS_MINIMIZED         =1;{< Program Relies on These Actual Values for cycling through
                             window states when user uses keyboard (CNTL+SPACE).}
  WS_MAXIMIZED         =2;{< Program Relies on These Actual Values for cycling through
                             window states when user uses keyboard (CNTL+SPACE).}
  {}
  // End  ------------------------------------------------------- Window State

  
  
  // Begin------------------------------------------------------- Messages
  {}
  MSG_IDLE                                                = 0;
  MSG_FIRSTCALL                                           = 1;
  MSG_UNHANDLEDKEYPRESS                                   = 2;
  MSG_UNHANDLEDMOUSE                                      = 3;
  MSG_MENU                                                = 4;
  MSG_SHUTDOWN                                            = 5;
  MSG_CLOSE                                               = 6;
  MSG_DESTROY                                             = 7;
  MSG_BUTTONDOWN                                          = 8;
  MSG_LOSTFOCUS                                           = 9;
  MSG_GOTFOCUS                                            =10;
  MSG_CTLGOTFOCUS                                         =11;
  MSG_CTLLOSTFOCUS                                        =12;
  MSG_WINDOWSTATE                                         =13;
  MSG_WINDOWMOVE                                          =14;
  MSG_WINDOWRESIZE                                        =15;
  MSG_CTLSCROLLUP                                         =16;
  MSG_CTLSCROLLDOWN                                       =17;
  MSG_CTLSCROLLLEFT                                       =18;
  MSG_CTLSCROLLRIGHT                                      =19;
  MSG_CHECKBOX                                            =20;
  MSG_LISTBOXMOVE                                         =21;  
  MSG_LISTBOXCLICK                                        =22;
  MSG_LISTBOXKEYPRESS                                     =23;
  MSG_PAINTWINDOW                                         =24;
  MSG_SHOWWINDOW                                          =25;
  MSG_CTLKEYPRESS                                         =26;
  MSG_WINPAINTVCB4CTL                                     =27;
  MSG_WINPAINTVCAFTERCTL                                  =28;
  {}
  //MSG_THREADCREATED                                       =500;
  //MSG_THREADTERMINATED                                    =501;
  //MSG_THREADDESTROYED                                     =502;
  
  
  // -------------- USER MESSAGES USED OutSide This Unit
  {}
  MSG_FILESELECTED = 1000; //< used by TDir class in u01u_Library
  {}


  // End  ------------------------------------------------------- Messages

  
  // Begin------------------------------------------------------- MsgBox Flags
  {}
  MB_ABORTRETRYIGNORE                                     = 1;//< THESE Are Sent in the Flags Parameter
  MB_OK                                                   = 2;//< THESE Are Sent in the Flags Parameter
  MB_OKCANCEL                                             = 3;//< THESE Are Sent in the Flags Parameter
  MB_RETRYCANCEL                                          = 4;//< THESE Are Sent in the Flags Parameter
  MB_YESNO                                                = 5;//< THESE Are Sent in the Flags Parameter
  MB_YESNOCANCEL	                                        = 6;//< THESE Are Sent in the Flags Parameter
  {}
  // End  ------------------------------------------------------- MsgBox Flags

  // Begin----------------------------------------------- MsgBox Return Values
  {}
  IDABORT	=1;
  IDCANCEL=2;
  IDIGNORE=3;
  IDNO	  =4;
  IDOK	  =5;
  IDRETRY	=6;
  IDYES	  =7;
  {}
  // End  ----------------------------------------------- MsgBox Return Values

  
  // Begin----------------------------------------------- FileBox Flags
  {}
  FB_GetDir                                              = 1;//< Binary Flags - Can't GetFile and GetDir - Hence 3 Works For Save
  FB_GetFile                                             = 2;//< Binary Flags - Can't GetFile and GetDir - Hence 3 Works For Save
  FB_SaveFile                                            = 3;//< Binary Flags - Can't GetFile and GetDir - Hence 3 Works For Save
  {}
  // End------------------------------------------------- FileBox Flags
  

//=============================================================================




// All public in GFX optimization for Development purposes
//--------------------------------------------------------------------------
// GFX Optimization System--------------------------------------------------
//--------------------------------------------------------------------------
{All routines are to Set to true versus make the calls themselves. These will occur in one place.}
{}
Type rtGFXOps=Record 
  bUpdateZOrder: Boolean; 
  bUpdateConsole: Boolean;
  bMenuPopUpChange: Boolean;  
End;

Var grGFXOps: rtGFXOps;
{}
Var gbMenuVisible: Boolean;
Var gbMenuEnabled: Boolean;


//=============================================================================
{}
Var
//=============================================================================
  {}
  // made public so user code can hide at will. Remember to 
  // call WinLogo.visible:=false; followed by WinLogo.SetFocus;
  WinLogo: TWindow;


  //debug public location
  {}
    MQ: JFC_XXDL;//<Message Queue
  {}
  // MQ: Message Queue
  // PTR: Pointer (lpfn WndProc)
  // ID1: Param1
  // ID2: Param2
  // ID3: ObjType
  // ID4: MSG 
  giMQMaxListCount:Longint;

  gbTrulyIDLE: Boolean;
    
  guVCStatusBar: UINT;
  giVCStatusBarLastKnownYPos: Longint;
  
  //guVCDebugStatusBar: Integer;
  {}
  guVCMain: UINT; //< Main VC
  guVCDebugMessages: UINT;
  guVCDebugWindows: UINT;
  guVCStarsAnimation: UINT;
  gu1VCDebugMessagesFGC: Byte;
  
  {}
  gu1StatusBarIdleFG: Byte; //< Loops through Colors to make Debug Messages look cool.

  gbModal: Boolean;
  
  
  gu1FrameFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameBG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameCaptionFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameCaptionBG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameWindowFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameWindowBG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1NoFocusFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameSizeFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameSizeBG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameDragFG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  gu1FrameDragBG: Byte;//< Default Frame Colors - Copied to Each Created window when create, after that window uses its own programmable copy.
  
  gu1ShadowFG: Byte;
  gu1ShadowBG: Byte;
  gchShadow: Char;
  
  
  gu1ButtonHotKeyFG: Byte;//< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly.
  gu1ButtonFGFocus: Byte;//< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly.
  gu1ButtonBGFocus: Byte; //< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly, focused
  gu1ButtonFG: Byte;//< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly.
  gu1ButtonBG: Byte;//< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly.
  gu1ButtonFGDisabled: Byte;//< used by buttons and Menus New Buttons get their own copy to use Menu uses these values directly.
  
  gchButtonBottom: Char;
  gchButtonSide: Char;
  
  gchFrameUp: Char;//< All Frames
  gchFrameDown: Char;//< All Frames
  gchFrameRestore: Char;//< All Frames

  
  gchFrameSTopLeft: Char;//<Sizable Frame Border
  gchFrameSTopRight: Char;//<Sizable Frame Border
  gchFrameSBottomLeft: Char;//<Sizable Frame Border
  gchFrameSBottomRight: Char;//<Sizable Frame Border
  gchFrameSHorizontal: Char;//<Sizable Frame Border
  gchFrameSVertical: Char;//<Sizable Frame Border
  gchFrameSOpenCaption: Char;//<Sizable Frame Border
  gchFrameSCloseCaption: Char;//<Sizable Frame Border
  
  
  gchFrameFTopLeft: Char;//< Fixed Frame Border
  gchFrameFTopRight: Char;//< Fixed Frame Border
  gchFrameFBottomLeft: Char;//< Fixed Frame Border
  gchFrameFBottomRight: Char;//< Fixed Frame Border
  gchFrameFHorizontal: Char;//< Fixed Frame Border
  gchFrameFVertical: Char;//< Fixed Frame Border
  gchFrameFOpenCaption: Char;//< Fixed Frame Border
  gchFrameFCloseCaption: Char;//< Fixed Frame Border
  
  
  gchInputTail: Char;//< Represents Input Box Tail
  gchPassword: Char;//< Represents Input Box Tail
  
  
  gchScreenBGChar: Char;//< Screen Background
  gu1ScreenFG: Byte;//< Screen Background
  gu1ScreenBG: Byte;//< Screen Background

  
  
  gu1DataFG: Byte;//<INPUT and list boxes
  gu1DataBG: Byte;//<INPUT and list boxes
  gu1TailFG: Byte;//<INPUT and list boxes
  gu1TailBG: Byte;//<INPUT and list boxes
  gu1SelectionFG: Byte;//<INPUT and list boxes
  gu1SelectionBG: Byte;//<INPUT and list boxes
  {}
  // List Box
  {}
  gchScrollBarLeftArrow: Char;//< Scroll Bar Chars
  gchScrollBarRightArrow: Char;//< Scroll Bar Chars
  gchScrollBarUpArrow: Char;//< Scroll Bar Chars
  gchScrollBarDownArrow: Char;//< Scroll Bar Chars
  gchScrollBarHMarker: Char;//< Scroll Bar Chars
  gchScrollBarVMarker: Char;//< Scroll Bar Chars
  gchScrollBarSlide: Char;//< Scroll Bar Chars

  
  gu1ScrollBarSlideFG: Byte;//< New ScrollBars get a copy from here when created - after that they use their own copy.
  gu1ScrollBarSlideBG: Byte;//< New ScrollBars get a copy from here when created - after that they use their own copy.

  
  gchProgressBarSlide: Char;//<ProgressBar Chars, new ProgressBars get a copy from here when created - after that they use their own copy.
  gchProgressBarMarker: Char;//<ProgressBar Chars, new ProgressBars get a copy from here when created - after that they use their own copy.
  
  // New ProgressBars get a copy from here when created - after that they use their own copy.
  gu1ProgressBarSlideFG: Byte;
  gu1ProgressBarSlideBG: Byte;
  gu1ProgressBarMarkerFG: Byte;
  gu1ProgressBarMarkerBG: Byte;

  // check Box Chars
  gchCheckLeft: Char;
  gchCheck: Char;
  gchCheckRight: Char;
  gchRadioLeft: Char;
  gchRadio: Char;
  gchRadioRight: Char;


  gbUnhandledKeypress: Boolean;
  gbUnhandledMouseEvent: Boolean;


  gbLogMessages: Boolean;
  BROADCAST: pointer;
  gbShutDownPending: Boolean;

  glpFUNCTION_uUsersMainMsgHandler: Function (Var p_rSageMsg: rtSageMsg): UINT;

  // made a global so user programs don't need to
  // bother - they use this one copy.
  grCW: rtCreateWindow; 

//=============================================================================






//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
// SAGE UI CONSTRUCTS BEGIN
//=============================================================================
//=============================================================================
//=============================================================================
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
Function InitSageUI(p_lpfnUsersMainMsgHandler: pointer): Boolean;
Procedure DoneSageUI;
Function SageUIUnitInitialized: Boolean;

Function AddMenuBarItem(p_sa: AnsiString; p_b: Boolean): UINT;
Function RemoveMenuBarItem(p: UINT):Boolean;
Function SetMenuBarItemEnabled(p: UINT; p_b: Boolean):Boolean;
Function AddMenuPopUpItem(
  p_MBUID: UINT; //< Menu Bar ID
  p_sa: AnsiString;  //< Caption (With ampersand hot key syntax)
  p_b: Boolean;      //< Enabled Flag
  p_UserID: UINT //< The CODE your main app will receive in the main message queue when the Item is selected by the end user.
): UINT;
Function RemoveMenuPopUpItem(p_PopUpID: UINT):Boolean;
Function RemoveMenuPopUpItem(p_MBUID,p_PopUpID: UINT):Boolean;
Function SetMenuPopUpItemEnabled(p_PopUpID: UINT;p_b: Boolean):Boolean;
Function SetMenuPopUpItemEnabled(
  p_MBUID,p_PopUpID: UINT;p_b:Boolean):Boolean;
Function SetMenuPopUpItemCaption(p_PopUpID: UINT;p_sa: AnsiString):Boolean;
Function GetMenuPopUpItemCaption(p_PopUpID: UINT):AnsiString;
Procedure SetMenuVisibleFlag(p_b:Boolean);
{}
Function GetMessage(Var p_rSageMsg: rtSageMsg):Boolean;
Procedure DispatchMessage(Var p_rSageMsg: rtSageMsg);
Function MsgToText(Var p_rSageMsg: rtSageMsg): AnsiString;
//=============================================================================
{}
// Just takes Object TYPE and returns name if know as text (see also msgtotext)
Function ObjToText(p_uObjType: UINT): AnsiString;
//=============================================================================
{}
Procedure PostMessage(Var p_rSageMsg: rtSageMsg);
var gbMsgBoxOpen: boolean;// prevent firing stacked msgboxes
var gbInputBoxOpen: boolean;// prevent firing stacked msgboxes
var gbFileBoxOpen: boolean;// prevent firing stacked msgboxes
Function MsgBox(
         p_saCaption: AnsiString;
         p_saMsg: AnsiString;
         p_i4Flags: LongInt): LongInt;

Function InputBox(
         p_saCaption: AnsiString;
         p_saData: AnsiString;
         p_i4MaxLength: LongInt;
         p_i4Flags: LongInt): AnsiString;

Function FileBox(
         p_saCaption: AnsiString;
         p_saPath: AnsiString;
         p_saFilespec: AnsiString;
         p_iFlags: Integer): AnsiString;

Procedure SetColorSchema(p_i4ColorSchemaID: LongInt);
Procedure SetGFXSchema(p_i4GFXSchemaID: LongInt);

//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Function uNewVCObject(
  p_saObjectName: AnsiString;
  p_i4Width, 
  p_i4Height:LongInt; 
  p_iSageUI_Object_Type: Integer;
  p_ptr: pointer
): UINT;



//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
// SAGE UI CONSTRUCTS END
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================


// Exported Interface Above
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
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
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
// Private Types, Const, Variables and Routines Below







//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

{}
// Used for debugging the internal keypress encoding. We crunch info like 
// ascii, special key codes (arrows for example) and ALT, CNTL and Shift Key 
// flags into one 32 bit number in the ProcessKeyboardMain function. The value 
// is used both internally and for sending key presses though the message pump
// We made a debug window that can snag this global value and effectively 
// disect the most recent coded keypress (coded from the uxxc_console.pp units
// rtKeypress structure) to assist in developing and debugging applications
// that rely on this value. These coded values do get posted to this systems
// message pump like windows does for the Win32 gui implementation. 
// These encoded keypresses have meaning outside of the ProcessKeyboardMain 
// procedure internal to uxxc_sageui.pp console GUI subsystem. 
// Note: This value is coined KeyPress32 and the debug window is similiarly 
// named. winDebugKeypress32.
var gu4Key: cardinal; 

//=============================================================================
{}
// Value based on last poll
Type rtObjectsXXDLStats=Record 
//=============================================================================
{}
  iNumberOfObjects: Integer;
  iNumberOfWindows: Integer;
  iNumberOfVirtualConsoles: Integer;  
  iNumberOfControls: Integer;
  iNumberOfUnknown: Integer;
  iNumberOfObj_NONE: Integer; //< equates to a ZERO.
End;
Var grObjectsXXDLStats: rtObjectsXXDLStats;
Var gbGetOBJECTSXXDLStatsEnabled:Boolean;
var gbGetMessageFirstTime: boolean;
var gbStatusBarDrawnAtLeastOnce: boolean;
//=============================================================================

Const cnSAGEUI_ScreenUpdateMilliSecondInterval=10; //< Set when logging to 3 seconds for slower emulation

Var
  guVCDebugHasFocus: UINT;

Const cnMAXVCDebugHasFocus=3; 
{<cycle 0=all off, 
 0=main background (VCMain)
 1=vcdebugmessages, 
 2=vcdebugwindows, 
 3=stars animation;
}
var gbSageUI_Enabled: boolean;


{}
var WinControlPanel: TWindow;
    WINControlPanel_ctlLabel: tctllabel;
    WINControlPanel_ctlLogo: tctlCheckBox;
    WINControlPanel_ctlKeyboard: tctlCheckBox;
    WINControlPanel_ctlKeypress: tctlCheckBox;
    WINControlPanel_ctlMQ: tctlCheckBox;
    WINControlPanel_ctlStatus: tctlCheckBox;
    WINControlPanel_ctlMouse: tctlCheckBox;
    WINControlPanel_ctlObjects: tctlCheckBox;
    WINControlPanel_ctlMenu: tctlCheckBox;
    WINControlPanel_ctlPopUp: tctlCheckBox;
    WINControlPanel_ctlKey32: tctlCheckBox;
    WINControlPanel_ctlControls: tctlCheckBox;
    WINControlPanel_ctlLabel2: tctllabel;
    WINControlPanel_ctlButtonMainBG:tctlbutton;
    WINControlPanel_ctlButtonMsgBG: tctlbutton;
    WINControlPanel_ctlButtonDbugWinBG: tctlbutton;
    WINControlPanel_ctlButtonStarsBG: tctlbutton;
    
Var WinHelp: TWindow;
    WinHelp_ctlLabel: tCtlLabel;
    WinHelp_ctlListbox: tCtlListBox;
    {}
    // WinHelpTopicXDL JFC_XDLITEM Usage
    // JFC_XDLITEM.saName = TopicName
    // JFC_XDLITEM.saValue = Text you see
    // JFC_XDLITEM.saDesc = Link TopicName
    // JFC_XDLITEM.i8User = 
    // NOTE: WinHelpTopicXDL: JFC_XDL; is defined above so external 
    //       code utilizing this user interface can augment the help.

Var WinDebugKeyBoard: TWindow;
Var WinDebugKeyPress: TWindow;
Var WinDebugMQ: twindow;
Var WinDebugStatusBar: twindow;
Var windebugmouse: twindow;
Var windebugObjectsXXDL: twindow;
Var windebugmenu: twindow;
Var windebugpopup: twindow;
Var windebugkeypress32: twindow;
Var WinDebugCtl: TWindow;
Var WinDebugCtl_ctlLabel: tctllabel;
Var WinDebugCtl_ctlVScrollBar:tctlVScrollBar;
Var WinDebugCtl_ctlHScrollBar:tctlHScrollBar;
Var WinDebugCtl_ctlProgressBar:tctlProgressBar;
Var WinDebugCtl_ctlInput:tctlInput;
Var WinDebugCtl_ctlInput01:tctlinput;
Var WinDebugCtl_ctlButton01:tctlbutton;
Var WinDebugCtl_ctlButton02:tctlButton;
Var WinDebugCtl_ctlCheckBox:tctlCheckBox;
var WinDebugCtl_ctlListBox:tctlListBox;



//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
// SAGE UI PRIVATE CONSTRUCTS BEGIN
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================



//=============================================================================
//{}
// This Structure if for mouse operations... like dragging.
// the term SPAN means the command can "SPAN" multiple mouse events.
// like a drag.
Type rtMSC = Record
//=============================================================================
  uCmd:     UINT; // ZERO means No Span Command
  dTWindow: UINT; // Specific to Span Command
  iData:    INT;  // LongInt Specific to Span Command
  uObjType: UINT;
  lpObj: pointer;
End;
//=============================================================================





//=============================================================================
Const
//=============================================================================
  cs_Msg_Initializing = 'Initializing, Please Wait...';

  // Begin ------------------------------------------- Mouse Span Commands
  MSC_None                  = 0;
  MSC_WindowDrag            = 1;
  MSC_WindowSize            = 2;
  MSC_InputSel              = 3;
  MSC_ButtonDown            = 4;
  MSC_VSCROLLUP             = 5;
  MSC_VSCROLLDOWN           = 6;
  MSC_HSCROLLLEFT           = 7;
  MSC_HSCROLLRIGHT          = 8;
  MSC_VSCROLLDRAG           = 9;
  MSC_HSCROLLDRAG           =10;
  MSC_CheckBox              =11;
  // End   ------------------------------------------- Mouse Span Commands

  // Used With MSC_WindowSize
  // Begin ------------------------------------------- Window Sizing Edges
  WSE_LEFT        = 1;
  WSE_RIGHT       = 2;
  WSE_BOTTOM      = 4;
  WSE_BOTTOMLEFT  = WSE_BOTTOM+WSE_LEFT; 
  WSE_BOTTOMRIGHT = WSE_BOTTOM+WSE_RIGHT; 
  // End   ------------------------------------------- Window Sizing Edges



//=============================================================================


//=============================================================================
Var
//=============================================================================
  //gbEnabled: Boolean; // I think this will totally remove all the UI VC
  gbSageUIUnitInitialized: Boolean;
  gbInsertMode: Boolean; //global for input boxes
  // This is used all over for Temp Use - Used to Manipulate gVC's
  grVCInfo: rtVCInfo; 
  // This Tracks ALL gVC's used by SageUI
  
  
//  OBJECTSXXDL: JFC_XXDL; 
    // lpPTR =Class OBJECT or Pointer for the VC Based Object - E.G. Window.
    // 
    // ID1   =TYPECASTED - POINTER to UserMsgHandler: Function(var p_rSageMsg: rtSageMsg):Cardinal;
    //        By having ONE STANDARD Calling Mechanism defined, Messages can be SENT to ANY OBJECT
    //        SO BY DEFAULT - Remember a VALUE OF NIL HERE PREVENTS Messages From Going there.
    // ID2   =VCUID From Console Unit
    // ID3   =Object Type
    // ID4   =Used by SetGUIEnabled (Stores If gVC Hidden or Not)
    




  
  //--------------------------------------------------------------------------@br
  // Menu System----------------------------------------------------------    @br
  //--------------------------------------------------------------------------@br
  // gMB is the Menubar items based on JFC_XXDL.                              @br
  // Below is how the JFC_XXDLITEM is implemented                             @br
  // i4User=Current;                                                          @br
  //----------------                                                          @br
  // ID1: Not Used                                                            @br
  // ID2: Not Used (User Defined ID on PopUp Items)                           @br
  // ID3 --- Before Writing Menu Option                                       @br
  //      Id[3]:=VCGetPenx;                 // word 00 00 00 FF               @br
  //      id[3]:=id[3] + (VcGetPenY shl 8); // word 00 00 FF 00               @br
  //      -- After Writing Menu Option                                        @br
  //      id[3]:=id[3] + (VcGetPenX shl 16);// word 00 FF 00 00               @br
  //      id[3]:=id[3] + (VcGetPenY shl 24);// word FF 00 00 00               @br
  // ID4 - Accelerator KeyID for HotKey char                                  @br
  //       (See AKEY declaration for this format)                             @br
  // saName - Caption                                                         @br
  // saDesc = AnsiString = '00000000'                                         @br
  // saDesc[1] = Enabled '1' or '0'                                           @br
  gMB: JFC_XXDL; 
  //-----------------------------------------------------------------------
  {}
  gbMenuDown: Boolean;
  gi4MenuHeight: LongInt;// Stores MenuBar Height (usually 1)

  guVCMenuBar: UINT;// MenuBar Virtual Console
  guVCMenuPopUp: UINT;
  //--------------------------------------------------------------------------
  // Menu System----------------------------------------------------------
  //--------------------------------------------------------------------------





  //--------------------------------------------------------------------------
  // Window System----------------------------------------------------------
  //--------------------------------------------------------------------------
  // Window system
  gi4WindowHasFocusUID: longint; // UID of Window With Focus
  // Next Coords to place newly minimized window
  gi4NextMinX: LongInt;
  gi4NextMinY: LongInt;
  //--------------------------------------------------------------------------
  // Window System----------------------------------------------------------
  //--------------------------------------------------------------------------

  // Flag & Sizing Direction
  //--------------------------------------------------------------------------
  // KeyBoard System----------------------------------------------------------
  //--------------------------------------------------------------------------
  gAKEY: JFC_XXDL;    // Used to Intercept Keystrokes and route special ones
                      // ID1: LOWORD - LowByte 
                      //      Ascii Value
                      //
                      // ID1: LOWORD - HiByte
                      //      Bit Flags for Special Keys
                      //      B00 = Shift Pressed
                      //      B01 = CNTL Pressed
                      //      B02 = ALT Pressed
                      //  
                      // ID1: HIWORD
                      //      OS Independent KeyCode Translation 

  grMSC: rtMSC; {< Mouse Span Command - Allows tracking mousing operations that span individual events - e.g. dragging a window }
  gsaClipBoard: AnsiString;{< Used for copy-n-paste operations. CNTL+INS = COPY, SHIFT+INS=paste }
  
  
  gFBWindow: TWindow; // FileBox Window
  gFBButton: array[1..3] Of tctlButton;
  gFBListBox: tctlListBox;
  gFBLabelFile: tctlLabel;
  gFBInputfile: tctlInput;
  gsaFBResult: AnsiString; // FB Return Value
  giFBResult: Integer; // Used to communicate between FB handler and FB routine
  gFBDir: jfc_dir;
  giFBFlags: Integer;
  
  //gWindow: TWindow; // MsgBox Window, InputBox
  gMsgBoxWindow: TWINDOW;
  gInputBoxWindow: TWINDOW;
  
  gctlButton: array [1..3] Of tctlButton; // For Message Boxes
  gctlLabel: tctlLabel; // for message boxes
  gi4MsgBoxResult: LongInt; 
  gi4MsgBoxFlags: LongInt;
  
  gctlInput: tctlInput;


  // These Are Set by CalcStatusBar procedure.
  gbSBVisible: Boolean; // Status Bar Visible






//=============================================================================


//=============================================================================
//=============================================================================
//=============================================================================
// BEGINNING OF HUGE PASTE FROM SAGE UI







//=============================================================================
//const
//=============================================================================
//  cn_Nothing = 0;
//=============================================================================




//=============================================================================
Procedure BroadcastAddress; Begin End;
//=============================================================================


//=============================================================================
// This Do Hicky is a quick dirty way to get formated label-value pairs on 
// a VC. Only does Ansistring, Right Justified.
// Writes to Currently active VC.
Procedure WVCDataPairStr(
  p_iX: Integer;
  p_iY: Integer;
  p_iLabelWidth: Integer;
  p_iDataWidth: Integer;
  p_saLabel: AnsiString;
  p_saValue: AnsiString
);
//=============================================================================
Begin
  VCSetFGC(lightgray);VCSetBGC(gu1FrameWindowBG);
  VCWriteXY(p_iX,p_iY, saFixedLength(p_saLabel,1,p_iLabelWidth));
  VCSetFGC(gu1FrameWindowFG);
  VCWrite(saRJustify(p_saValue, p_iDataWidth));
End;
//=============================================================================


//=============================================================================
// This Do Hicky is a quick dirty way to get formated label-value pairs on 
// a VC. Only does Integers, Right Justified.
// Writes to Currently active VC.
Procedure WVCDataPairInt(
  p_iX: Integer;
  p_iY: Integer;
  p_iLabelWidth: Integer;
  p_iDataWidth: Integer;
  p_saLabel: AnsiString;
  p_iValue: Integer
);
//=============================================================================
Begin
  VCSetFGC(lightgray);VCSetBGC(gu1FrameWindowBG);
  VCWriteXY(p_iX,p_iY, saFixedLength(p_saLabel,1,p_iLabelWidth));
  VCSetFGC(gu1FrameWindowFG);
  VCWrite(saFixedLength(saRJustifyInt(p_iValue, p_iDataWidth),1,p_iDataWidth));
End;
//=============================================================================





//=============================================================================
Procedure GetOBJECTSXXDLStats;
//=============================================================================
Var
  iBookMarkN: INT;
  uObjType: INT;

Begin
  If gbGetOBJECTSXXDLStatsEnabled Then
  Begin
    If WINDebugOBJECTSXXDL.WindowState<>WS_MINIMIZED Then
    Begin
      iBookMarkN:=OBJECTSXXDL.N;
      With grObjectsXXDLStats Do  Begin
        iNumberOfObjects:=0;
        iNumberOfWindows:=0;
        iNumberOfVirtualConsoles:=0;
        iNumberOfControls:=0;
        iNumberOfUnknown:=0;
        iNumberOfObj_NONE:=0;
        iNumberOfObjects:=OBJECTSXXDL.ListCount;
        If iNumberOfObjects>0 Then
        Begin
          OBJECTSXXDL.MoveFirst;
          repeat
            uObjType:=JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[3];
            Case uObjType Of
            OBJ_NONE               :Inc(iNumberOfObj_NONE);
            OBJ_VCMAIN             :Inc(iNumberOfVirtualConsoles);
            OBJ_VCSTATUSBAR        :Inc(iNumberOfVirtualConsoles);
            OBJ_MENUBAR            :Inc(iNumberOfVirtualConsoles);
            OBJ_MENUBARPOPUP       :Inc(iNumberOfVirtualConsoles);
            OBJ_WINDOW             :Inc(iNumberOfWindows);
            OBJ_LABEL              :Inc(iNumberOfControls);  
            OBJ_VSCROLLBAR         :Inc(iNumberOfControls);
            OBJ_HSCROLLBAR         :Inc(iNumberOfControls);
            OBJ_PROGRESSBAR        :Inc(iNumberOfControls);
            OBJ_INPUT              :Inc(iNumberOfControls);
            OBJ_BUTTON             :Inc(iNumberOfControls);
            OBJ_CHECKBOX           :Inc(iNumberOfControls);
            OBJ_LISTBOX            :Inc(iNumberOfControls);
            OBJ_TREE               :Inc(iNumberOfControls);
            OBJ_VCDEBUGMESSAGES    :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGKEYPRESS    :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGKEYBOARD    :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGMOUSE       :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGMQ          :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGSTATUSBAR   :Inc(iNumberOfVirtualConsoles);
            OBJ_VCDEBUGWINDOWS     :Inc(iNumberOfVirtualConsoles);
            OBJ_VCSTARANIMATION    :Inc(iNumberOfVirtualConsoles);
            Else
              Inc(iNumberOfUnknown);
            End;//case
            
          Until not OBJECTSXXDL.MoveNext;
        End;//with
      End;  
      OBJECTSXXDL.FoundNth(iBookMarkN);
      WinDebugObjectsXXDL.PaintWindow;
    End;
  End;
End;
//=============================================================================



















//=============================================================================
Procedure CalcStatusBar;
//=============================================================================
Var TempVC: Cardinal;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('CalcStatusBar',SOURCEFILE);
  {$ENDIF}
  
  gbSBVisible:=false;
  
  // Keep Status Bar Current
  TempVC:=GetActiveVC;
  if guVCStatusBar>0 then
  begin
    SetActiveVC(guVCStatusBar);
    gbSBVisible:=(VCGetVisible) and
                (((giConsoleHeight-VCHeight)-1) <= VCGetY) and
                (VCgetX=1) and (giConsoleWidth=VCWidth);
  end;
  If gbSBVisible Then giVCStatusBarLastKnownYPos:=VCGetY Else giVCStatusBarLastKnownYPos:=0;
  if TempVC>0 then SetActiveVC(TempVC);

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('CalcStatusBar',SOURCEFILE);
  {$ENDIF}
End;


//=============================================================================
Function bObjGetsFocus(p_uObjType: UINT): Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bObjGetsFocus',SOURCEFILE);
  {$ENDIF}
  Result:=False;
  Case p_uObjType Of
  OBJ_MENUBAR         :Result:=True;
  OBJ_MENUBARPOPUP    :Result:=True;
  OBJ_WINDOW          :Result:=True;
  OBJ_INPUT           :Result:=True;
  OBJ_BUTTON          :Result:=True;
  OBJ_CHECKBOX        :Result:=True;
  OBJ_LISTBOX         :Result:=True;
  OBJ_TREE            :Result:=True;
  End;//case
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bObjGetsFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================




//=============================================================================
Function WriteHotKeyedText(
            p_sa: AnsiString; 
            p_i4Length: LongInt;
            p_bEnabled: Boolean;
            p_bSelected: Boolean;
            p_u1tEnabledFG: Byte;
            p_u1tEnabledCurrentFG: Byte;
            p_u1tEnabledHotKeyFG: Byte;
            p_u1tDisabledFG: Byte;
            p_u1tSelectedBG: Byte;
            p_u1tBG: Byte
          ): Char; 
//=============================================================================
Var i,gW: LongInt;
    saTemp: AnsiString;
    chHotKey: Char;
    bHaveHotKey:Boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WriteHotKeyedText',SOURCEFILE);
  {$ENDIF}


  p_bEnabled:=p_bEnabled;
  
  gW:=0; i:=1;
  saTemp:=saSpecialSNR(p_sa,'&',#1); // Remember HotKeys are prefixed by #1
  If p_bSelected Then 
    VCSetBGC(p_u1tSelectedBG)
  Else
    VCSetBGC(p_u1tBG);

  chHotKey:=#0;
  While gW<p_i4Length Do Begin
    bHaveHotKey:=False;
    If p_bEnabled Then 
    Begin
      If (i<=length(saTemp)) and (saTemp[i]=#1) Then
      Begin
        VCSetFGC(p_u1tEnabledHotKeyFG);
        i+=1;
        bHaveHotKey:=True
      End
      Else
      Begin
        If p_bSelected Then
          VCSetFGC(p_u1tEnabledCurrentFG)
        Else
          VCSetFGC(p_u1tEnabledFG);
      End;
    End
    Else
    Begin
      If (i<=length(saTemp)) and (saTemp[i]=#1) Then 
      Begin
        i+=1;
        bHaveHotKey:=True;//so routine still returns a hotkey accel
                          //without this, ALT+Menu and PopUp-Letters
                          //come up unhandled when they are accounted
                          //for - just off
      End;
      VCSetFGC(p_u1tDisabledFG);
    End;
    
    If (i<=length(saTemp)) Then 
    Begin
      VCWriteChar(saTemp[i]);
      If (bHaveHotKey) and (chHotKey=#0) Then chHotKey:=saTemp[i];
    End
    Else VCWriteChar(' ');
    gW+=1; i+=1;
  End;
  WriteHotKeyedText:=chHotKey;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WriteHotKeyedText',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================






// KeyID Manipulation Routines -------BEGIN
//=============================================================================
Function  bKeyIDShiftPressed(p_u4KeyID: LongWord): Boolean;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bKeyIDShiftPressed',SOURCEFILE);
  {$ENDIF}

  bKeyIDShiftPressed:=(((LongWord(p_u4KeyID) and LongWord($0000FF00)) shr LongWord(8)) and LongWord(b00))=LongWord(b00);

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bKeyIDShiftPressed',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  bKeyIDCntlPressed(p_u4KeyID: LongWord): Boolean;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bKeyIDCntlPressed',SOURCEFILE);
  {$ENDIF}

  bKeyIDCntlPressed:=(((LongWord(p_u4KeyID) and LongWord($0000FF00)) shr LongWord(8)) and LongWord(b01))=LongWord(b01);

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bKeyIDCntlPressed',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  bKeyIDAltPressed(p_u4KeyID: LongWord): Boolean;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bKeyIDAltPressed',SOURCEFILE);
  {$ENDIF}

  bKeyIDAltPressed:=(((LongWord(p_u4KeyID) and LongWord($0000FF00)) shr LongWord(8)) and LongWord(b02))=LongWord(b02);

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bKeyIDAltPressed',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function wKeyIDKeyCode(p_u4KeyID: LongWord): Word;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('wKeyIDKeyCode',SOURCEFILE);
  {$ENDIF}

  wKeyIDKeyCode:=Word((LongWord(p_u4KeyID) and LongWord($FFFF0000)) shr LongWord(16));

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('wKeyIDKeyCode',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function chKeyID(p_u4KeyID: LongWord): Char;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('chKeyID',SOURCEFILE);
  {$ENDIF}

  chKeyID:=Char(LongWord(p_u4KeyID) and LongWord($FF));

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('chKeyID',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetKeyIDShiftPressed(p_u4KeyID: LongWord; p_b: Boolean):LongWord;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetKeyIDShiftPressed',SOURCEFILE);
  {$ENDIF}


  If p_b Then
  Begin
    If not bKeyIDShiftPressed(p_u4KeyID) Then
      SetKeyIDShiftPressed:=p_u4KeyID+ LongWord( (LongWord(b00) shl LongWord(8)) );
  End
  Else
  Begin
    If bKeyIDShiftPressed(p_u4KeyID) Then
      SetKeyIDShiftPressed:=p_u4KeyID-  LongWord(LongWord(b00) shl LongWord(8));
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetKeyIDShiftPressed',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetKeyIDCntlPressed(p_u4KeyID: LongWord; p_b: Boolean):LongWord;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetKeyIDCNTLPressed',SOURCEFILE);
  {$ENDIF}

  If p_b Then
  Begin
    If not bKeyIDCNTLPressed(p_u4KeyID) Then
      SetKeyIDCNTLPressed:=p_u4KeyID+ LongWord(LongWord(b01) shl LongWord(8));
  End
  Else
  Begin
    If bKeyIDCNTLPressed(p_u4KeyID) Then
      SetKeyIDCNTLPressed:=p_u4KeyID-LongWord(LongWord(b01) shl LongWord(8));
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetKeyIDCNTLPressed',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================

//=============================================================================
Function SetKeyIDALTPressed(p_u4KeyID: LongWord; p_b: Boolean):LongWord;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetKeyIDAltPressed',SOURCEFILE);
  {$ENDIF}


  If p_b Then
  Begin
    If not bKeyIDALTPressed(p_u4KeyID) Then
      SetKeyIDALTPressed:=p_u4KeyID+LongWord( LongWord(b02) shl LongWord(8));
  End
  Else
  Begin
    If bKeyIDALTPressed(p_u4KeyID) Then
      SetKeyIDALTPressed:=p_u4KeyID-(LongWord(b02) shl LongWord(8));
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetKeyIDAltPressed',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetKeyIDKeyCode(p_u4KeyID: LongWord; p_w: Word):LongWord;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetKeyIDKeyCode',SOURCEFILE);
  {$ENDIF}

  SetKeyIDKeyCode:=(p_u4KeyID and LongWord($0000FFFF))+(LongWord(p_w) shl LongWord(16));

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetKeyIDKeyCode',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetKeyIDch(p_u4KeyID: LongWord; p_ch: Char):LongWord;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetKeyIDch',SOURCEFILE);
  {$ENDIF}

  SetKeyIDch:=(p_u4KeyID and LongWord($FFFFFF00)) + LongWord(Ord(p_ch));

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetKeyIDch',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  bKeyCodeCheck(
  p_u4KeyID: LongWord;// Packed Key32 (Keypress32 or p_u4KeyID) as packed in ProcessKeyboardMain procedure 
  p_bShift: boolean;// if testing for shift key
  p_bCntl: boolean;// if testing for cntl key
  p_bAlt: boolean;// if testing for alt key
  p_u2KeyCode: word // keycode you want to see if is in the packed u4KeyID
): Boolean;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bKeyCodeCheck',SOURCEFILE);
  {$ENDIF}

  bKeyCodeCheck:= (bKeyIDShiftPressed(p_u4KeyID)=p_bShift) and 
                  (bKeyIDCntlPressed(p_u4KeyID)=p_bCntl) and
                  (bKeyIDAltPressed(p_u4KeyID)=p_bAlt) and  
                  (wKeyIDKeyCode(p_u4KeyID)=p_u2KeyCode);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bKeyCodeCheck',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function  bKeyCharCheck(
  p_u4KeyID: LongWord;// Packed Key32 (Keypress32 or p_u4KeyID) as packed in ProcessKeyboardMain procedure 
  p_bShift: boolean;// if testing for shift key
  p_bCntl: boolean;// if testing for cntl key
  p_bAlt: boolean;// if testing for alt key
  p_chKey: char // ascii key you want to see if is in the packed u4KeyID
): Boolean;
{$IFDEF USEINLINE}Inline;{$ENDIF}
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('bKeyCharCheck',SOURCEFILE);
  {$ENDIF}

  bKeyCharCheck:= (bKeyIDShiftPressed(p_u4KeyID)=p_bShift) and 
                  (bKeyIDCntlPressed(p_u4KeyID)=p_bCntl) and
                  (bKeyIDAltPressed(p_u4KeyID)=p_bAlt) and  
                  (chKeyID(p_u4KeyID)=p_chKey);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('bKeyCharCheck',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


// KeyID Manipulation Routines -------END








// This Routine Does Presume gMB is pointing to correct MenuBarItem
// and also Presumes that gVC upon entry is the MenuBar's and that
// the Cursor in the MenuBar's gVC is Just About to Write the MenuBarItem
//=============================================================================
Procedure DrawPopUp;
//=============================================================================
Var 
  t:LongInt;
  i4Width: LongInt;
  x,y: LongInt; 
  iBookMarkPopUp: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DrawPopUp',SOURCEFILE);
  {$ENDIF}

  If  (gMB<>nil) and (gmb.listcount>0) and (gMB.Item_lpPTR<>nil) Then
  Begin
    x:=VCGetPenX-1;
    If x<1 Then x:=1;
    y:=VCGetPenY;
    SetActiveVC(guVCMenuPopUp);
    i4Width:=0;
    if JFC_XXDL(gMB.Item_lpPTR).listcount>0 then
    begin
      iBookMarkPopUp:=JFC_XXDL(gMB.Item_lpPTR).N;
      JFC_XXDL(gMB.Item_lpPTR).MoveFirst;
      If JFC_XXDL(gMB.Item_lpPTR).Item_i8User=0 Then JFC_XXDL(gMB.Item_lpPTR).Item_i8User:=1;
      repeat
        If length(JFC_XXDL(gMB.Item_lpPTR).Item_saName)>i4Width Then i4Width:=length(JFC_XXDL(gMB.Item_lpPTR).Item_saName);
      Until not JFC_XXDL(gMB.Item_lpPTR).movenext;
    End;
    i4Width+=2; // Frame Sides
    If (i4Width+VCGetX-1 > giConsoleWidth) Then
    Begin
      If ((i4Width+VCGetX-1)-giConsoleWidth)<VCGetX Then
      Begin
        VCSetXY(VCGetX-((i4Width+VCGetX-1)-giConsoleWidth),VCGetY);
      End;
    End;
    i4Width+=2; // Shadow
    
    
    VCResize(i4Width,JFC_XXDL(gMB.Item_lpPTR).ListCount+3);  
    
    // Begin --------------------------------------------------- Frame Draw
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    
    // Begin ----------------------------------------- Top of Frame
    VCSetFGC(gu1ButtonFG);
    VCSetBGC(gu1ButtonBG);
  
    VCSetPenXY(1,1);
    VCWrite(StringOfChar(gchFrameFHorizontal,VCWidth-2));
    // Draw Top Left Corner
    VCSetPenXY(1,1);
    VCWrite(gchFrameFTopLeft);
    // Draw Top Right Corner
    VCSetPenXY(VCWidth-2, 1);
    VCWrite(gchFrameFTopRight);
    // Right Transparent
    VCWrite(#0+#0);
    //VCSetPenXY(VCWidth-3,1); // Prepare Pen For next item (button or not)
    
    // Begin --------------------------------------- Middle of Frame
    If JFC_XXDL(gMB.Item_lpPTR).Listcount>0 Then
    Begin
      JFC_XXDL(gMB.Item_lpPTR).MoveFirst;
      repeat
        VCSetPenXY(1,JFC_XXDL(gMB.Item_lpPTR).N+1);
        VCSetFGC(gu1ButtonFG);
        VCSetBGC(gu1ButtonBG);
        //SageLog(1,'Draw VCGetPenX+1:='+inttostr(VCGetPenx+1));
        JFC_XXDL(gMB.Item_lpPTR).Item_Id3:=VCGetPenx+1;// word 00 00 00 FF
        //SageLog(1,'JFC_XXDL(gMB.Item_lpPTR).Item_Id[3]:='+inttostr(JFC_XXDL(gMB.Item_lpPTR).Item_Id[3]));
        JFC_XXDL(gMB.Item_lpPTR).Item_Id3:=JFC_XXDL(gMB.Item_lpPTR).Item_Id3 + (VcGetPenY shl 8); // word 00 00 FF 00
        
        If (JFC_XXDL(gMB.Item_lpPTR).Item_saName='-') Then
        Begin
          VCWrite(gchFrameFCloseCaption);
          VCWrite(StringOfChar(gchFrameFHorizontal,VCWidth-4));
          JFC_XXDL(gMB.Item_lpPTR).Item_Id4:=0; // prevent hotkey from being available if Separator
        End
        Else
        Begin
          VCWrite(gchFrameFVertical);
          
          // gonna build KeyID Here and stuff it in the menu Item eagch time drawn
          // But not throwing u4KeyCode in there and must remember to zero out
          // the keycode when making first pass (search for menu keypresses)
          // searching for the keypress in the gAKEY accerator "table"
          // Remember also to Search for uppercase version and lowercase
          // version of menu alt+key keyid's
          
          // We JUST stuff the UPCASE char of the Hot Key into the PopUp Menu
          // So we can look for it later. 
          JFC_XXDL(gMB.Item_lpPTR).Item_Id4:=
            SetKeyIDCH(
              0,
              upcase(
                WriteHotKeyedText(
                  ' '+ JFC_XXDL(gMB.Item_lpPTR).Item_saName,
                  i4Width-4,
                  Boolean(gMB.Item_saDesc[1]='1') and 
                  Boolean(JFC_XXDL(gMB.Item_lpPTR).Item_saDesc[1]='1'),
                  (JFC_XXDL(gMB.Item_lpPTR).N=JFC_XXDL(gMB.Item_lpPTR).Item_i8User),
                  gu1ButtonFG,
                  gu1ButtonFGFocus,
                  gu1ButtonHotKeyFG,        
                  gu1ButtonFGDisabled,
                  gu1ButtonBGFocus,
                  gu1ButtonBG
                )
              )
            )
          ;//end command

          // Original stuffs hot key as a ALT+KEY combo into the popup menu itself - which won't help us 
          // We just want the letter here.
          //JFC_XXDL(gMB.Item_lpPTR).Item_Id4:=SetKeyIDCH(SetKeyIDAltPressed(0,True),
          //  upcase(
          //  WriteHotKeyedText(
          //    ' '+ JFC_XXDL(gMB.Item_lpPTR).Item_saName,
          //    i4Width-4,
          //    Boolean(gMB.Item_saDesc[1]='1') and 
          //    Boolean(JFC_XXDL(gMB.Item_lpPTR).Item_saDesc[1]='1'),
          //    (JFC_XXDL(gMB.Item_lpPTR).N=JFC_XXDL(gMB.Item_lpPTR).Item_i8User),
          //    gu1ButtonFG,
          //    gu1ButtonFGFocus,
          //    gu1ButtonHotKeyFG,        
          //    gu1ButtonFGDisabled,
          //    gu1ButtonBGFocus,
          //    gu1ButtonBG
          //  ))
          //);



        End;      
  
        JFC_XXDL(gMB.Item_lpPTR).Item_Id3:=JFC_XXDL(gMB.Item_lpPTR).Item_Id3 + (VcGetPenX shl 16);// word 00 FF 00 00
        JFC_XXDL(gMB.Item_lpPTR).Item_Id3:=JFC_XXDL(gMB.Item_lpPTR).Item_Id3 + (VcGetPenY shl 24);// word FF 00 00 00
        //SageLog(1,'N & ID3:'+inttostr(JFC_XXDL(gMB.Item_lpPTR).N)+' '+inttostr(JFC_XXDL(gMB.Item_lpPTR).Item_Id3));
        VCSetFGC(gu1ButtonFG);
        VCSetBGC(gu1ButtonBG);
        VCSetPenXY(VCWidth-2,JFC_XXDL(gMB.Item_lpPTR).N+1);
  
        If (JFC_XXDL(gMB.Item_lpPTR).Item_saName='-') Then
        Begin
          VCWrite(gchFrameFOpenCaption);
          //JFC_XXDL(gMB.Item_lpPTR).Item_Id[4]:=0; // prevent separators from AccelKey
        End
        Else
        Begin
          VCWrite(gchFrameFVertical);
        End;      
        
        // Right Shadow
        VCSetFGC(gu1ShadowFG);
        VCSetBGC(gu1ShadowBG);
        VCWrite(gchShadow+gchShadow);
        
      Until not JFC_XXDL(gMB.Item_lpPTR).MoveNext;
      JFC_XXDL(gMB.Item_lpPTR).FoundNth(iBookMarkPopUp);
      VCSetFGC(gu1ButtonFG);
      VCSetBGC(gu1ButtonBG);
    End;
    // End  --------------------------------------- Middle of Frame
  
  
    // Begin --------------------------------------- Bottom of Frame
    VCSetFGC(gu1ButtonFG);
    VCSetPenXY(1, VCHeight-1);
    VCWrite(gchFrameFBottomLeft);
    VCSetPenXY(2,VCHeight-1);
    VCWrite(StringOfChar(gchFrameFHorizontal,VCWidth-4));
  
    VCSetPenXY(VCWidth-2, VCHeight-1);
    VCWrite(gchFrameFBottomRight);
  
    VCSetFGC(gu1ShadowFG);
    VCSetBGC(gu1ShadowBG);
    VCWrite(gchShadow+gchShadow);
  
    VCSetPenXY(1,VCHeight);
    VCWrite(#0+#0);
    For t:=3 To VCWidth Do
    Begin
      // Bottom Shadow
      VCSetFGC(gu1ShadowFG);
      VCSetBGC(gu1ShadowBG);
      VCWrite(gchShadow);
    End;
    // End --------------------------------------- Bottom of Frame
  
  
    // End --------------------------------------------------- Frame Draw
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
  
    If (x+(VCWidth-3)>giConsoleWidth) Then
    Begin
      x:=giConsoleWidth-(VCWidth-3);
    End;
    VCSetXY(x,y+1);
    VCSetVisible(true);
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOUT('DrawPopUp',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================






//=============================================================================
Procedure DrawMenuBar;
//=============================================================================
{$IFNDEF MENURESIZE}
Var 
  i4MenHeight: LongInt;
{$ENDIF}

var 
  i4MenuBarBookMark: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DrawMenuBar',SOURCEFILE);
  {$ENDIF}

  If (gMB<>nil) and (gMB.ListCount>0)  Then
  Begin
    grGfxOps.bUpdateConsole:=True;
    grGfxOps.bUpdateZOrder:=True;
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - DrawMenuBar',SOURCEFILE);{$ENDIF}
    
    If gMB.Item_i8User=0 Then
    Begin
      SetActiveVC(guVCMenuPopUp);
      VCSetVisible(False);
    End;
    
    SetActiveVC(guVCMenuBar);
    VCSetVisible(gbMenuVisible);
    VCSetFGC(gu1ButtonFG);
    VCSetBGC(gu1ButtonBG);
    {$IFDEF MENURESIZE}
    VCResize(giConsoleWidth,1);
    {$ELSE}  
    VCFillBoxCTR(VCWidth, VCHeight, #0);
    {$ENDIF}

    {$IFNDEF MENURESIZE}
    i4MenHeight:=1;
    {$ENDIF}
    i4MenuBarBookMark:=gMB.N;
    gMB.MoveFirst;
    VCWriteXY(1,1,' ');
    repeat
      If (VCGetPenx+length(gMB.Item_saName))>giConsoleWidth Then
      Begin
        VCSetFGC(gu1ButtonFG);
        VCSetBGC(gu1ButtonBG);
        VCClrEol;
        {$IFDEF MENURESIZE}
        VCResize(giConsoleWidth,VCHeight+1);
        VCSetPenXY(1,VCHeight);
        {$ELSE}
        i4MenHeight+=1;
        VCSetPenXY(1,i4MenHeight);
        {$ENDIF}
        
      End;
      If (gMB.N=gMB.Item_i8User) and gbMenuDown Then 
      begin
        DrawPopUp;
        SetActiveVC(guVCMenuBar);// Get Out MenuBar ActiveVC Back in play
      end;
      
      gMB.Item_Id3:=VCGetPenx;                         // word 00 00 00 FF
      gMB.Item_Id3:=gMB.Item_Id3 + (VcGetPenY shl 8); // word 00 00 FF 00
      
      // gonna build KeyID Here and stuff it in the menu Item eagch time drawn
      // But not throwing u4KeyCode in there and must remember to zero out
      // the keycode when making first pass (Search for menu keypresses)
      // Searching for the keypress in the AKEY accelerator "table"
      // Remember also to Search for uppercase version and lowercase
      // version of menu alt+key keyid's

      // We JUST stuff the UPCASE char of the Hot Key into the PopUp Menu
      // So we can look for it later. 
      gMB.Item_Id4:=
        SetKeyIDCH(
          0,
          upcase(
            WriteHotKeyedText(
              ' '+ gMB.Item_saName,
              length(gMB.Item_saName)+1,
              Boolean(gMB.Item_saDesc[1]='1'),
              (gMB.N=gMB.Item_i8User),
              gu1ButtonFG,
              gu1ButtonFGFocus,
              gu1ButtonHotKeyFG,        
              gu1ButtonFGDisabled,
              gu1ButtonBGFocus,
              gu1ButtonBG
            )
          )
        )
      ;//end command
      
      
      // Original stuffs hot key as a ALT+KEY combo into the popup menu itself - which won't help us 
      // We just want the letter here.
      //gMB.Item_Id4:=SetKeyIDCH(SetKeyIDAltPressed(0,True),
      //  upcase(
      //  WriteHotKeyedText(
      //    ' '+ gMB.Item_saName,
      //    length(gMB.Item_saName)+1,
      //    Boolean(gMB.Item_saDesc[1]='1'),
      //    (gMB.N=gMB.Item_i8User),
      //    gu1ButtonFG,
      //    gu1ButtonFGFocus,
      //    gu1ButtonHotKeyFG,        
      //    gu1ButtonFGDisabled,
      //    gu1ButtonBGFocus,
      //    gu1ButtonBG
      //  ))
      //);
      
      gMB.Item_Id3:=gMB.Item_Id3 + (VcGetPenX shl 16);// word 00 FF 00 00
      gMB.Item_Id3:=gMB.Item_Id3 + (VcGetPenY shl 24);// word FF 00 00 00
    Until not gMB.movenext;
    gMB.FoundNth(i4MenuBarBookMark);

    VCSetFGC(gu1ButtonFG);
    VCSetBGC(gu1ButtonBG);
    VCClrEol;
    If gbMenuVisible Then 
      {$IFDEF MENURESIZE}
      gi4MenuHeight:=VCHeight
      {$ELSE}
      gi4MenuHeight:=i4MenHeight
      {$ENDIF}
    Else
      gi4MenuHeight:=0;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('DrawMenuBar',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure SetColorSchema(p_i4ColorSchemaID: LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetColorSchema',SOURCEFILE);
  {$ENDIF}

  Case p_i4ColorSchemaID Of
  1: Begin
    // Default Frame Colors
    gu1FrameFG:= yellow;
    gu1FrameBG:= blue;
    gu1FrameCaptionFG:=white;
    gu1FrameCaptionBG:=Blue;
    gu1FrameWindowFG:=yellow;
    gu1FrameWindowBG:=blue;
    gu1NoFocusFG:= darkgray;
    gu1FrameSizeFG:= lightgreen;
    gu1FrameSizeBG:= blue;
    gu1FrameDragFG:= cyan;
    gu1FrameDragBG:= blue;
    gu1ShadowFG:= darkgray;
    gu1ShadowBG:=black;
    
    // used gu1 buttons and Menus
    gu1ButtonHotKeyFG:=white;
    gu1ButtonFGFocus:=lightgray;
    gu1ButtonBGFocus:=black; // focused
    gu1ButtonFG:=black;
    gu1ButtonBG:=lightgray;
    gu1ButtonFGDisabled:=darkgray;
    
    // Screen Background
    gu1ScreenFG:=lightgray;
    gu1ScreenBG:=blue;
  
    // Scroll bar
    gu1ScrollBarSlideFG:=darkgray;
    gu1ScrollBarSlideBG:=black;
    
    // progress bar
    gu1ProgressBarSlideFG:=darkgray;
    gu1ProgressBarSlideBG:=black;
    gu1ProgressBarMarkerFG:=darkgray;
    gu1ProgressBarMarkerBG:=blue;

    gu1DataFG:=White;
    gu1DataBG:=black;
    gu1TailFG:=white;
    gu1SelectionFG:=White;
    {$IFDEF Win32}
    gu1TailBG:=darkgray;
    gu1SelectionBG:=lightgray;
    {$ELSE}
    gu1TailBG:=lightgray;
    gu1SelectionBG:=lightgray;
    {$ENDIF}
  End;


  2: Begin // Used by XTERM (TERM=xterm)
    // Default Frame Colors
    gu1FrameFG:= yellow;
    gu1FrameBG:= blue;
    gu1FrameCaptionFG:=yellow;
    gu1FrameCaptionBG:=blue;
    gu1FrameWindowFG:=brown;
    gu1FrameWindowBG:=blue;
    gu1NoFocusFG:= white;
    gu1FrameSizeFG:= green;
    gu1FrameSizeBG:= blue;
    gu1FrameDragFG:= blue;
    gu1FrameDragBG:= green;
    gu1ShadowFG:= black;
    gu1ShadowBG:= black;
    
    // used gu1 buttons and Menus
    gu1ButtonHotKeyFG:=yellow;
    gu1ButtonFGFocus:=blue;
    gu1ButtonBGFocus:=brown; // focused
    gu1ButtonFG:=brown;
    gu1ButtonBG:=blue;
    gu1ButtonFGDisabled:=red;
    
    // Screen Background
    gu1ScreenFG:=lightgray;
    gu1ScreenBG:=cyan;
  
    // Scroll bar
    gu1ScrollBarSlideFG:=darkgray;
    gu1ScrollBarSlideBG:=cyan;
    
    // progress bar
    gu1ProgressBarSlideFG:=yellow;
    gu1ProgressBarSlideBG:=cyan;
    gu1ProgressBarMarkerFG:=brown;
    gu1ProgressBarMarkerBG:=green;

    gu1DataFG:=yellow;
    gu1DataBG:=brown;
    gu1TailFG:=cyan;
    gu1TailBG:=cyan;
    gu1SelectionFG:=blue;
    gu1SelectionBG:=green;


  End;
  End;//case

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetColorSchema',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================



//=============================================================================
Procedure SetGFXSchema(p_i4GFXSchemaID: LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetGFXSchema',SOURCEFILE);
  {$ENDIF}

  Case p_i4GFXSchemaID Of
  1: Begin // - PC OEM - dos
    // Frame Buttons
    gchFrameUP:=#24;
    gchFrameDown:=#25;
    gchFrameRestore:=#240;

    // Fixed Frame
    gchFrameFTopLeft:=#218;
    gchFrameFTopRight:=#191;
    gchFrameFBottomLeft:=#192;
    gchFrameFBottomRight:=#217;
    gchFrameFHorizontal:=#196;
    gchFrameFVertical:=#179;
    gchFrameFOpenCaption:=#180;
    gchFrameFCloseCaption:=#195;

    // Sizable Frame
    gchFrameSTopLeft:=#201;
    gchFrameSTopRight:=#187;
    gchFrameSBottomLeft:=#200;
    gchFrameSBottomRight:=#188;
    gchFrameSHorizontal:=#205;
    gchFrameSVertical:=#186;
    gchFrameSOpenCaption:=#185;
    gchFrameSCloseCaption:=#204;

    // Represents Input Box Tail
    gchInputTail:=#176;
    gchScreenBGChar:=#176;
    gchScrollBarLeftArrow:=#17;
    gchScrollBarRightArrow:=#16;
    gchScrollBarUpArrow:=#30;
    gchScrollBarDownArrow:=#31;
    gchScrollBarHMarker:=#29;
    gchScrollBarVMarker:=#23;
    gchScrollBarSlide:=#176;
    gchProgressBarSlide:=#176;
    gchProgressBarMarker:=#176;
    gchCheckLeft:='[';
    gchCheck:=#251; // gfx char checkmark
    gchCheckRight:=']';
    gchPassWord:='*';
    gchRadioLeft:='(';
    gchRadio:=#254; // gfx square
    gchRadioRight:=')';

    gchShadow:=#3;
    gchButtonSide:=#220;
    gchButtonBottom:=#223;
    
    // FIXUPS for Non-Windows (linux can't do some of these chars)
    {$IFNDEF Win32}
    gchFrameUP:='^';
    gchFrameDown:='v';
    gchFrameRestore:='#';
    gchCheck:='X'; 
    gchRadio:='*'; 
    gchscrollBarLEftArrow:='<';
    gchScrollBarRightArrow:='>';
    gchScrollBarUpArrow:='^';
    gchScrollBarDownArrow:='v';
    gchScrollBarHMarker:='-';
    gchScrollBarVMarker:='|';
    gchInputTail:='.';
    gchButtonSide:=' ';
    gchButtonBottom:=' ';
    {$ENDIF}
  End;
  2: Begin // ASCII
    // Frame Buttons
    gchFrameUP:='^';
    gchFrameDown:='v';
    gchFrameRestore:='#';

    // Fixed Frame
    gchFrameFTopLeft:='+';
    gchFrameFTopRight:='+';
    gchFrameFBottomLeft:='+';
    gchFrameFBottomRight:='+';
    gchFrameFHorizontal:='-';
    gchFrameFVertical:='!';
    gchFrameFOpenCaption:='(';
    gchFrameFCloseCaption:=')';

    // Sizable Frame
    gchFrameSTopLeft:='#';
    gchFrameSTopRight:='#';
    gchFrameSBottomLeft:='#';
    gchFrameSBottomRight:='#';
    gchFrameSHorizontal:='-';
    gchFrameSVertical:='I';
    gchFrameSOpenCaption:='(';
    gchFrameSCloseCaption:=')';

    // Represents Input Box Tail
    gchInputTail:=' ';
    gchScreenBGChar:=':';
    gchScrollBarLeftArrow:='<';
    gchScrollBarRightArrow:='>';
    gchScrollBarUpArrow:='^';
    gchScrollBarDownArrow:='v';
    gchScrollBarHMarker:='*';
    gchScrollBarVMarker:='*';
    gchScrollBarSlide:=' ';
    gchProgressBarSlide:=':';
    gchProgressBarMarker:='#';
    gchCheckLeft:='<';
    gchCheck:='X'; // gfx char checkmark
    gchCheckRight:='>';
    gchPassWord:='*';
    gchRadioLeft:='(';
    gchRadio:='*'; // gfx square
    gchRadioRight:=')';

    gchShadow:=#0;//makes invisible - no shadow
    gchButtonSide:=' ';
    gchButtonBottom:=' ';
  End;
  End;// case

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetGFXSchema',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
// TRUE Means Forward
Procedure WindowChangeFocus(p_Forward:Boolean); 
//=============================================================================
Var 
    rSageMsg: rtSageMsg;
    iStartedWithUID: Integer;
    iEndedWithUID: Integer;
    iBookMarkN: Integer;
    bDone: Boolean;
    bGotOne:Boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WindowChangeFocus',SOURCEFILE);
  {$ENDIF}
  //Log(cnLog_DEBUG, 200609271452,'WindowChangeFocus Called in SageUI',SOURCEFILE);
  
  // gi4WindowHasFocusUID:=0; Starts as Having Focus
  // iOldWUID 
  bGotOne:=False;
  iStartedWithUID:=gi4WindowHasFocusUID;
  bDone:=False;
  If OBJECTSXXDL.ListCount=0 Then 
  Begin
    bDone:=True;
    iStartedWithUID:=0;
    iEndedWithUID:=0;
  End;
  //Log(cnLog_DEBUG, 200609271452,'WindowChangeFocus - First part. '+
  //  'bDone:'+satrueFalse(bDone),SOURCEFILE);
  
  
  If not bDone Then 
  Begin
    If (not OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID)) Then 
    Begin
      iStartedWithUID:=0;
      If not OBJECTSXXDL.FoundItem_ID(OBJ_WINDOW,3) Then
      Begin
        iEndedWithUID:=0;
        bDone:=True;
      End;
    End;
  End;
  //Log(cnLog_DEBUG, 200609271452,'WindowChangeFocus - Part2. ' +
  //  'bDone:'+satrueFalse(bDone) +' '+
  //  'iStartedWithUID:'+inttostr(iStartedwithUID)+' '+
  //  'iEndedWith:'+inttostr(iEndedWithUID)+' ',SOURCEFILE);
  
  
  // Actual Search
  If not bDone Then 
  Begin  
    iBookMarkN:=OBJECTSXXDL.N;
    repeat
      If p_forward Then 
      Begin
        If not OBJECTSXXDL.MoveNext Then If not OBJECTSXXDL.MoveFIRST Then bDone:=True;
      End
      Else
      Begin
        If not OBJECTSXXDL.MovePrevious Then If not OBJECTSXXDL.MoveLast Then bDone:=True;
      End;
      bGotONE:=(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).ID[3]=OBJ_WINDOW) and
                 (TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR).rw.bVisible and 
                  TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR).rw.bEnabled);
      If bGotOne Then iEndedWithUID:=OBJECTSXXDL.Item_UID;
    Until bGotOne OR (OBJECTSXXDL.N=iBookMarkN);
  End;    
  
  //Log(cnLog_DEBUG, 200609271452,'WindowChangeFocus - Part3. (After official look around loop) ' +
  //  'bDone:'+satrueFalse(bDone) +' '+
  //  'iStartedWithUID:'+inttostr(iStartedwithUID)+' '+
  //  'iEndedWith:'+inttostr(iEndedWithUID)+' ',SOURCEFILE);



  // Cheap Way
  //If bGotOne Then
  //Begin
  //  If iEndedWithUID<>iStartedWithUID Then
  //  Begin
  //    If OBJECTSXXDL.FoundItem_UID(iEndedwithUID) Then
  //    Begin
  //      TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR).SetFocus;
  //    End;  
  //  End;
  //End;
  
  
    
  If not bDone Then
  Begin
    //If (gi4WindowHasFocusUID=0) and (iEndedWithUID<>0) Then gi4WindowHasFocusUID:=iStartedWithUID;
    
    If iEndedWithUID<>iStartedWithUID Then
    Begin
      grGfxOps.bUpdateZOrder:=True;      
      {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - Window Change Focus 1',SOURCEFILE);{$ENDIF}
      gi4WindowHasFocusUID:=iEndedWithUID;
      If OBJECTSXXDL.FoundItem_UID(iStartedWithUID) Then 
      Begin
        TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR).bRedraw:=True;
        With rSageMsg Do Begin
          lpPTR:=JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR;
          uMsg:=MSG_LOSTFOCUS;
          uParam1:=0;
          uParam2:=0;
          uObjType:=OBJ_WINDOW;
          {$IFDEF LOGMESSAGES}
          saSender:='WindowChangeFocus';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End;
      
      If OBJECTSXXDL.FoundItem_UID(iEndedWithUID) Then
      Begin
        TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR).bRedraw:=True;
        With rSageMsg Do Begin
          lpPTR:=JFC_XXDLITEM(OBJECTSXXDL.lpITEM).lpPTR;
          uMsg:=MSG_GOTFOCUS;
          uParam1:=0;
          uParam2:=0;
          uObjType:=OBJ_WINDOW;
          {$IFDEF LOGMESSAGES}
          saSender:='WindowChangeFocus';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        
      End;
    End;
  End;  
  
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WindowChangeFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





//mainprocesskeyboard
//=============================================================================
Procedure ProcessKeyBoardMain;
//=============================================================================
Var
  u4Key: LongWord; // ShortHand for Accel keys, Menu HotKEys and Such.
  //i4Safety: LongInt; // used while scanning PopUp Menus
  //i4OldPopUp: LongInt;
  rSageMsg: rtSageMsg;
  
  //i4MenuBarBookMark: longint; 
  i4MenuBarNewItem: longint;
  i4PopUpBookMark: longint; 
  i4PopUpNewItem: longint;
Begin
// AKEY ID1 KeyID Format
// ---------------------
// ID1: LOWORD - Lobyte
//      Ascii Value
//
// ID1: LOWORD - HiByte
//      Bit Flags for Special Keys
//      B00 = Shift Pressed
//      B01 = CNTL Pressed
//      B02 = ALT Pressed
//  
// ID1: HIWORD
//      OS Independant KeyCode Translation 


  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('ProcessKeyBoardMain',SOURCEFILE);
  {$ENDIF}

  //If rLKey.bCntlPressed and (rLKey.ch=#19) Then hal t(0); //cntl+S ALL STOP    
  
  // F1 HELP KEY
  if gbUnhandledKeypress then
  begin
    If (rLKey.u2KeyCode=kbdF1) Then
    Begin
      if not gbModal then
      begin
        if not WinHelp.Visible then 
        begin
          WinHelp.Visible:=true;
          WinHelp.SetFocus;
          WinHelp.WindowState:=WS_MAXIMIZED;
          gbUnhandledKeyPress:=False;
        end
        else
        begin
          WinHelp.Visible:=false;
          WindowChangeFocus(False);
        end;
      end;
    End;
  end;
  
  // F2 Prev (Previous Window)
  if gbUnhandledKeypress then
  begin
    If (rLKey.u2KeyCode=kbdF2) Then
    Begin
      if not gbModal then
      begin
        WindowChangeFocus(False);// means backwards I think
        gbUnhandledKeyPress:=False;
      end;
    End;
  end;

  // F3 Next (Next Window)
  if gbUnhandledKeypress then
  begin
    If (rLKey.u2KeyCode=kbdF3) Then
    Begin
      if not gbModal then
      begin
        WindowChangeFocus(True);// means forward I think
        gbUnhandledKeyPress:=False;
      end;
    End;
  end;
  
  // F4 - Close
  if gbUnhandledKeypress then 
  begin 
    If (rLKey.u2KeyCode=kbdF4) Then
    Begin
      If (OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID)) and 
         (OBJECTSXXDL.Item_ID3=OBJ_WINDOW) and
         (TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).CloseButton) Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR;
          uMsg:=MSG_CLOSE;
          uParam1:=0;
          uParam2:=0;
          uObjType:=OBJ_WINDOW;
          {$IFDEF LOGMESSAGES}
          saSender:='ProcessKeyboardMain';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledKeyPress:=False;
      End;
    End;
  end;  
  
  // F5: Handled in the TWindow.ProcessKeyboard function.
  
  // F6: Menu
  if gbUnhandledKeypress then
  begin
    If (rLKey.u2KeyCode=kbdF6) Then
    begin
      if (not gbModal) then 
      begin
        //msgbox('DrawMenu bits',
        //  'gMB=nil? '+saTRueFalse(gmb=nil)+ ' '+
        //  'gmb.listcount:'+inttostr(gmb.listcount)+' '
        //  ,MB_OK);
        DrawMenuBar;
        gbMenuVisible:=not gbMenuVisible;
        gbMenuDown:=false;
        
        grGFXOps.bUpdateZOrder:=true;
        {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - Processkeyboardmain f6',SOURCEFILE);{$ENDIF}
        
        gbUnhandledKeyPress:=False;
      end;
    end;
  end;

  // F7: Show Control Panel
  if gbUnhandledKeyPress then
  begin
    If (rLKey.u2KeyCode=kbdF7) Then
    Begin
      if not gbModal then 
      begin
        if WinControlPanel.Visible then 
        begin
          WinControlPanel.SetFocus;
          WinControlPanel.Visible:=false;
        end
        else
        begin
          WinControlPanel.Visible:=true;
          if WinControlPanel.WindowState=WS_MINIMIZED then WinControlPanel.WindowState:=WS_NORMAL;
          WinControlPanel.SetFocus;
        end;
      end;
    End;
  end;
  
  // F8 SHUTDOWN KEY 
  if gbUnhandledKeypress then
  begin
    If (rLKey.u2KeyCode=kbdF8) Then
    Begin
      gbUnhandledKeyPress:=False;
      With rSageMsg Do Begin
        lpPTR:=nil;
        uMsg:=MSG_CLOSE;
        uParam1:=0;
        uParam2:=0;
        uObjType:=OBJ_WINDOW;
        {$IFDEF LOGMESSAGES}
        saSender:='ProcessKeyboardMain';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
      With rSageMsg Do Begin
        lpPTR:=nil;
        uMsg:=MSG_SHUTDOWN;
        uParam1:=0;
        uParam2:=0;
        uObjType:=OBJ_NONE;
        {$IFDEF LOGMESSAGES}
        saSender:='ProcessKeyboardMain';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
      //Writeln('-=\ Jegas /=-');
    End;
  end;
  
  u4Key:=0;
  //if gbUnhandledKeyPress then
  //begin
    // begin --------- Create a KeyID from rLKey (last keypress)
    If rLKey.bShiftPressed Then u4Key+=b00;
    If rLKey.bCntlPressed Then  u4Key+=b01;
    If rLKey.bAltPressed Then   u4Key+=b02;
    u4Key:=u4Key shl 8;
    u4Key+=Ord(rLKey.ch);
    u4Key:=u4Key+(LongWord(rLKey.u2KeyCode) shl LongWord(16));
    // End --------- Create a KeyID from rLKey (last keypress)
  //end;
  gu4Key:=u4Key;// Make Available to WinDebugKeypress32 debug window


  
  // FIRST: Check Keypress against accelerator table and process
  // accordingly
  if gbUnhandledKeypress then
  begin
    If gAKEY.FoundItem_ID(u4Key,1) Then
    Begin
      // These Get First priority when implemented
      //gbUnhandledKeypress:=False;
    End;
  end;  
  
  // SECOND: Handle The menu
  if gbUnhandledKeypress then
  begin
    
    If (gMB.ListCount>0) and (gbMenuEnabled) and (gbMenuVisible) and (gbUnhandledKeyPress)and (not gbModal)Then
    begin
      if gbMenuDown then
      begin
        ///////////////////////
        // Handle The PopUp Menu
        ///////////////////////
        // HotKey Method To Jump to Item in Menu Bar
        if JFC_XXDL(gMB.Item_lpPtr).ListCount > 0 then
        begin
          i4PopUpBookMark:=JFC_XXDL(gMB.Item_lpPtr).N;
          if (rLKey.ch<>#0) and (JFC_XXDL(gMB.Item_lpPtr).FoundItem_ID(SetKeyIDCH(0,upcase(rLKey.ch)),4)) then
          begin
            i4PopUpNewItem:=JFC_XXDL(gMB.Item_lpPtr).N;
            if JFC_XXDL(gMB.Item_lpPtr).MoveFirst then 
            begin
              repeat
                JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=-1;    
              until not JFC_XXDL(gMB.Item_lpPtr).MoveNext;
            end;
            if JFC_XXDL(gMB.Item_lpPtr).FoundNth(i4PopUpNewItem) then
            begin
              JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=JFC_XXDL(gMB.Item_lpPtr).N;
            end;

            If (JFC_XXDL(gMB.Item_lpPTR).Item_saDesc[1]='1') and (gMB.Item_saDesc[1]='1') Then
            Begin  
              //With rSageMsg Do Begin
              //  lpPTR:=nil;
              //  uMsg:=MSG_MENU;
              //  // We've set uParam1 above
              //  uParam1:=JFC_XXDL(gMB.Item_lpPTR).Item_Id2;
              //  uParam2:=gMB.Item_i8User;
              //  uObjType:=OBJ_MENUBAR;
              //  {$IFDEF LOGMESSAGES}
              //  saSender:='ProcessKeyboardMain';
              //  {$ENDIF}
              //End;//with
              //PostMessage(rSageMsg); 
            End;
            //gbMenuVisible:=false;
            //gbMenuDown:=false;          
            grGfxOps.bUpdateZOrder:=true;
            grGfxOps.bUpdateConsole:=true;
            gbUnhandledKeypress:=false;   
            {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain PopUp msg_menu',SOURCEFILE);{$ENDIF}
          end
          else
          begin
            JFC_XXDL(gMB.Item_lpPtr).FoundNth(i4PopUpBookMark); // Get PopUp where it was before hunting for a hotkey
            // Deal With Non hotkey Keypresses germain to popup menu  
            //Function  bKeyCodeCheck(
            //  p_u4KeyID: LongWord;// Packed Key32 (Keypress32 or p_u4KeyID) as packed in ProcessKeyboardMain procedure 
            //  p_bShift: boolean;// if testing for shift key
            //  p_bCntl: boolean;// if testing for cntl key
            //  p_bAlt: boolean;// if testing for alt key
            //  p_u2KeyCode: word // keycode you want to see if is in the packed u4KeyID
            //): Boolean;
            
            if gbUnhandledKeypress then
            begin
              if bKeyCodeCheck(u4Key,false,false,false,kbdLeft) then // Left Arrow
              begin
                gMB.Item_i8User:=0;
                gMB.MovePrevious;
                gMB.Item_i8User:=gMB.N;
                grGfxOps.bUpdateZOrder:=true;
                grGfxOps.bUpdateConsole:=true;
                {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain popup leftarrow',SOURCEFILE);{$ENDIF}
                gbUnhandledKeypress:=false;
              end;  
            end;
            
            if gbUnhandledKeypress then
            begin
              if bKeyCodeCheck(u4Key,false,false,false,kbdRight) then // Right Arrow
              begin
                gMB.Item_i8User:=0;
                gMB.MoveNext;
                gMB.Item_i8User:=gMB.N;
                grGfxOps.bUpdateZOrder:=true;
                grGfxOps.bUpdateConsole:=true;
                {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain popup right arrow',SOURCEFILE);{$ENDIF}
                gbUnhandledKeypress:=false;
              end;  
            end;

            if gbUnhandledKeypress then
            begin
              if bKeyCodeCheck(u4Key,false,false,false,kbdUp) then // up Arrow
              begin
                JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=-1;
                JFC_XXDL(gMB.Item_lpPtr).MovePrevious;
                JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=JFC_XXDL(gMB.Item_lpPtr).N;
                grGfxOps.bUpdateZOrder:=true;
                grGfxOps.bUpdateConsole:=true;
                {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain popup up arrow',SOURCEFILE);{$ENDIF}
                gbUnhandledKeypress:=false;
              end;  
            end;

            if gbUnhandledKeypress then
            begin
              if bKeyCodeCheck(u4Key,false,false,false,kbdDown) then // down Arrow
              begin
                JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=-1;
                JFC_XXDL(gMB.Item_lpPtr).MoveNext;
                JFC_XXDL(gMB.Item_lpPtr).Item_i8User:=JFC_XXDL(gMB.Item_lpPtr).N;
                grGfxOps.bUpdateZOrder:=true;
                grGfxOps.bUpdateConsole:=true;
                {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain popup down arrow',SOURCEFILE);{$ENDIF}
                gbUnhandledKeypress:=false;
              end;  
            end;

            if gbUnhandledKeypress then
            begin
              if bKeyCharCheck(u4Key,false,false,false,#13) then // Enter
              begin
                gbMenuVisible:=false;
                gbMenuDown:=false;          

                if JFC_XXDL(gMB.Item_lpPtr).Item_i8User>-1 then
                begin
                  If (JFC_XXDL(gMB.Item_lpPTR).Item_saDesc[1]='1') and (gMB.Item_saDesc[1]='1') Then
                  Begin  
                    With rSageMsg Do Begin
                      lpPTR:=nil;
                      uMsg:=MSG_MENU;
                      // We've set uParam1 above
                      uParam1:=JFC_XXDL(gMB.Item_lpPTR).Item_Id2;
                      uParam2:=gMB.Item_i8User;
                      uObjType:=OBJ_MENUBAR;
                      {$IFDEF LOGMESSAGES}
                      saSender:='ProcessKeyboard';
                      {$ENDIF}
                    End;//with
                    PostMessage(rSageMsg); 
                    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menu item selected via cr',SOURCEFILE);{$ENDIF}
                  End;
                end;
                grGfxOps.bUpdateZOrder:=true;
                grGfxOps.bUpdateConsole:=true;
                UpdateConsole;
                gbUnhandledKeypress:=false;   
              end;  
            end;
          end;
        end
        else
        begin
          // Empty Pop Up Menu - What the... B^)
        end;
      end
      else
      begin
        ///////////////////////
        // Handle the menu Bar
        ///////////////////////
        // HotKey Method To Jump to Item in Menu Bar
        //i4MenuBarBookMark:=gMB.N;
        if (rLKey.ch<>#0) and gMB.FoundItem_ID(SetKeyIDCH(0,upcase(rLKey.ch)),4) then
        begin
          i4MenuBarNewItem:=gMB.N;
          if gMB.MoveFirst then 
          begin
            repeat
              gMB.Item_i8User:=0;    
            until not gMB.MoveNExt;
          end;
          gMB.FoundNth(i4MenuBarNewItem);
          gMB.Item_i8User:=gMB.N;
          gbMenuDown:=true;          
          grGfxOps.bUpdateZOrder:=true;
          grGfxOps.bUpdateConsole:=true;
          {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menubar handling',SOURCEFILE);{$ENDIF}
          gbUnhandledKeypress:=false;   
        end
        else
        begin
          // Deal With Non hotkey Keypresses germain to menubar
          if gbUnhandledKeypress then
          begin
            if rLKey.u2KeyCode=kbdDown then
            begin
              gbMenuDown:=true;  
              grGfxOps.bUpdateZOrder:=true;
              grGfxOps.bUpdateConsole:=true;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menubar non-hotkey down key',SOURCEFILE);{$ENDIF}
              gbUnhandledKeypress:=false;   
            end;
          end;

          //Function  bKeyCharCheck(
          //  p_u4KeyID: LongWord;// Packed Key32 (Keypress32 or p_u4KeyID) as packed in ProcessKeyboardMain procedure 
          //  p_bShift: boolean;// if testing for shift key
          //  p_bCntl: boolean;// if testing for cntl key
          //  p_bAlt: boolean;// if testing for alt key
          //  p_chKey: char // ascii key you want to see if is in the packed u4KeyID
          //): Boolean;



          if gbUnhandledKeypress then
          begin
            if bKeyCharCheck(u4Key,false,false,false,#13) then // Enter Key same as down arrow for this scenario
            begin
              gbMenuDown:=true;  
              grGfxOps.bUpdateZOrder:=true;
              grGfxOps.bUpdateConsole:=true;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menubar non hotkey CR',SOURCEFILE);{$ENDIF}
              gbUnhandledKeypress:=false;   
            end;
          end;


          if gbUnhandledKeypress then
          begin
            if rLKey.u2KeyCode=kbdRight then
            begin
              if gMB.MoveFirst then
              begin
                while (gMB.Item_i8User=0) and gMB.MoveNext do;
                //i4MenuBarBookMark:=gMB.N;
                gMB.Item_i8User:=0;
                gMB.MoveNext;  
                //i4MenuBarNewItem:=gMB.N;
                gMB.Item_i8User:=gMB.N;
              end;
              gbMenuDown:=true;  
              grGfxOps.bUpdateZOrder:=true;
              grGfxOps.bUpdateConsole:=true;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menubar nonhot right key',SOURCEFILE);{$ENDIF}
              gbUnhandledKeypress:=false;   
            end;
          end;

          if gbUnhandledKeypress then
          begin
            if rLKey.u2KeyCode=kbdLeft then
            begin
              if gMB.MoveFirst then
              begin
                while (gMB.Item_i8User=0) and gMB.MoveNext do;
                //i4MenuBarBookMark:=gMB.N;
                gMB.Item_i8User:=0;
                gMB.MovePrevious;  
                //i4MenuBarNewItem:=gMB.N;
                gMB.Item_i8User:=gMB.N;
              end;
              gbMenuDown:=true;  
              grGfxOps.bUpdateZOrder:=true;
              grGfxOps.bUpdateConsole:=true;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain menubar nonhot left key',SOURCEFILE);{$ENDIF}
              gbUnhandledKeypress:=false;   
            end;
          end;
        end;
      end;
    end;
  end;
  
  // Our Last Key Press Check is this one - it makes some house keeping work
  If gbUnhandledKeypress then
  begin
    if (OBJECTSXXDL.FoundItem_ID(OBJ_WINDOW,3)) Then
    Begin
      // Window Change Focus CTNL+TAB or CNTL+SHIFT+TAB
      If (not rLKey.bAltPressed) and 
         (rLKey.bCntlPressed) and 
         ((rLKey.ch=#9) OR (rLKEY.ch=#23) OR (rLkey.u2KeyCode=kbdF5)){CNTL+W} and
         (not gbModal) Then
      Begin
        WindowChangeFocus(not rLKey.bShiftPressed);
        gbUnhandledKeypress:=False;
      End
      Else
      Begin
        If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then 
        Begin
          //LOG(cnLog_Debug,201003031454,'ProcessKeyBoardMain - Before calling TWindow.ProcessKeyboard - gbUnhandledKeypress:'+saTrueFalsE(gbUnhandledKeypress),SOURCEFILE);
          TWindow(JFC_XXDL(OBJECTSXXDL.lpItem).lpPtr).ProcessKeyboard(u4Key);
          //LOG(cnLog_Debug,201003031455,'ProcessKeyBoardMain - After Calling TWindow.ProcessKeyboard - gbUnhandledKeypress:'+saTrueFalsE(gbUnhandledKeypress),SOURCEFILE);
          If not gbUnhandledKeyPress Then
          Begin
            TWindow(JFC_XXDL(OBJECTSXXDL.lpItem).lpPtr).PaintWindow;
            //grGfxOps.b pdateConsole:=true;
            {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessKeyboardMain very bottom - not unhandled keypress',SOURCEFILE);{$ENDIF}
          End;
        End;
      End;
    End;
  end;



  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('ProcessKeyBoardMain',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

// gbUnhandledMouseEvent flag handles in a rather generic way.
// and that is: if the gVC belongs a menu, popup, or a Window
// then it is considered HANDLED - In addition - During a Size
// or a Move - Move events and Mouse Up's are considered handled.
//
// No great effort has been made to assure Middle and Right Mouse
// button integrity. The code concentrates on left mouse button.
//
// mainprocessmouse
//=============================================================================
Procedure ProcessMouseMain(p_bMouseIdle: Boolean);
//=============================================================================
Var 
  uObjType: UINT;
  lpObj: pointer;
  rSageMsg: rtSageMsg;
  bMenuBarItemChanged: boolean;
  bPopUpChanged: boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}  DebugIn('ProcessMouseMain',SOURCEFILE);  {$ENDIF}
  rSageMsg.lpPTR:=nil;// Shutup compiler
  if not p_bMouseIdle then
  begin
    SetActiveVC(guVCDebugWindows);
    DrawMouseEventRecord(40,1,rLMEvent,LightGray, Black, White, Black);
  end;

  uObjType:=0;
  If grMSC.uCMD<>MSC_None Then
  Begin
    uObjType:=grMSC.uObjType;
    lpObj:=grMSC.lpObj;
  End  
  Else
  Begin
    If not p_bMouseIdle Then
    Begin
      If OBJECTSXXDL.FoundItem_ID(rLMevent.VC,2) Then
      Begin
        uObjType:=OBJECTSXXDL.Item_ID3;
        lpOBJ:=OBJECTSXXDL.Item_lpPTR;
      End;     
    End;
  End;
  
  If (not p_bMouseIdle) and 
     (rLMEvent.VC <> guVCMenuBar) and
     (rLMevent.VC <> guVCMenuPopUp) and
     (rLMEvent.Action<>MouseActionMove) Then
  Begin
    If gMB.Movefirst Then
    Begin
      repeat  
        gMB.Item_i8User:=0;
      until not gMB.MoveNext;
    End;
    gbMenuDown:=False;
    gbMenuVisible:=False;
    grGfxOps.bUpdateConsole:=true;
    grGfxOps.bUpdateZOrder:=true;
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessMouseMain non-idle mousing',SOURCEFILE);{$ENDIF}
  End;
  
  // Dispatch Mouse Event
  Case uObjType Of
  OBJ_MENUBAR    :Begin
    gbUnhandledMouseEvent:=False;
    If (gbMenuEnabled) and (not gbModal)Then 
    Begin
      //cnLog_ity_Debug,201003032122,'Menu appears Enabled',SOURCEFILE);
      //x1      Id[3]:=VCGetPenx;                 // word 00 00 00 FF
      //y1      id[3]:=id[3] + (VcGetPenY shl 8); // word 00 00 FF 00
      //x2      id[3]:=id[3] + (VcGetPenX shl 16);// word 00 FF 00 00
      //y2      id[3]:=id[3] + (VcGetPenY shl 24);// word FF 00 00 00
      //log(cnLog_Debug,201003032123,'MB.ListCount='+inttostr(gMB.Listcount),SOURCEFILE);
      If gMB.MoveFirst Then
      Begin
        bMenuBarItemChanged:=false;
        repeat 
          //sagelog(1,'MB.N='+inttostr(MB.N));
          // does MouseY=cur menu opt y?
          //sagelog(1,'rLMEvent.VMY='+inttostr(rLMEvent.VMY));
          //sagelog(1,'((MB.id[3] and $0000FF00) shr 8)='+inttostr(((MB.id[3] and $0000FF00) shr 8)));
          If (rLMEvent.VMX>=(gMB.Item_Id3 and $000000FF)) and 
             (rLMEvent.VMX< ((gMB.Item_Id3 and $00FF0000) shr 16)) and 
             (rLMEvent.VMY= ((gMB.Item_Id3 and $0000FF00) shr 8 )) then
          begin
            // Do We have a legit change, meaning - we update stuff if a different menubar item is selected.
            bMenuBarItemChanged:=(gMB.Item_i8User<>gMB.N);
            gMB.Item_i8User:=gMB.N;
          End
          else
          begin
            // We force update (to be safe) if this menubar item WAS selected and now is not
            bMenuBarItemChanged:=(gMB.Item_i8User<>0);
            gMB.Item_i8User:=0;
          End;
        Until (not gMB.MoveNext);
        if bMenuBarItemChanged then 
        begin
          grGFXOps.bUpdateZOrder:=true;
          {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - ProcessMouseMain menubar item change',SOURCEFILE);{$ENDIF}
        end;
        
        If (not p_bMouseIdle) and 
           (rLMEvent.Action=MouseActionDown) and
           (rLMEvent.Buttons=MouseLeftButton) Then 
        begin
          gbMenuDown:=True;
        end;
      End
      Else
      Begin
        // have a menu with no items; force update in case user removed items previously
        gbMenuDown:=False;
        gbMenuVisible:=false;
        grGFXOps.bUpdateZOrder:=true;
        {$IFDEF DEBUGTRACKGFXOPS}JcnLog_ity_Debug,201003040235,'grGfxOps - ProcessMouseMain menu - no items - forced update',SOURCEFILE);{$ENDIF}
      End;
    End;
  End; 

  OBJ_MENUBARPOPUP  :Begin
    gbunhandledmouseevent:=False;
    if gMB.MoveFirst then
    begin
      while (gMB.Item_i8User=0) and (gMB.MoveNext) do;
      if gMB.Item_i8User<>0 then // I think we have the menubar item that is highlighted and presumed to hold the menupopup in question.
      begin
        //msgbox('got it',JFC_XXDL(gMB.Item_lpPTR).Item_saName,MB_OK);
        If JFC_XXDL(gMB.Item_lpPTR).MoveFirst Then
        Begin
          bPopUpChanged:=false;
          repeat 
            //sagelog(1,'MB.N='+inttostr(MB.N));
            // does MouseY=cur menu opt y?
            //sagelog(1,'rLMEvent.VMY='+inttostr(rLMEvent.VMY));
            //sagelog(1,'((MB.id[3] and $0000FF00) shr 8)='+inttostr(((MB.id[3] and $0000FF00) shr 8)));
            If (rLMEvent.VMX>=(JFC_XXDL(gMB.Item_lpPTR).Item_Id3 and $000000FF)) and 
               (rLMEvent.VMX< ((JFC_XXDL(gMB.Item_lpPTR).Item_Id3 and $00FF0000) shr 16)) and 
               (rLMEvent.VMY= ((JFC_XXDL(gMB.Item_lpPTR).Item_Id3 and $0000FF00) shr 8 )) then
            begin
              // Do We have a legit change, meaning - we update stuff if a different menubar item is selected.
              bPopUpChanged:=(JFC_XXDL(gMB.Item_lpPTR).Item_i8User<>JFC_XXDL(gMB.Item_lpPTR).N);
              JFC_XXDL(gMB.Item_lpPTR).Item_i8User:=JFC_XXDL(gMB.Item_lpPTR).N;
              If ((rLMEvent.Action and MouseActionUp)=MouseActionUp) Then
              Begin
                //msgbox('got mouse up on popup','',MB_OK);
                If (JFC_XXDL(gMB.Item_lpPTR).Item_saDesc[1]='1') and (gMB.Item_saDesc[1]='1') Then
                Begin  
                  //msgbox('sending popup message','',MB_OK);
                  With rSageMsg Do Begin
                    lpPTR:=nil;
                    uMsg:=MSG_MENU;
                    // We've set uParam1 above
                    uParam1:=JFC_XXDL(gMB.Item_lpPTR).Item_Id2;
                    uParam2:=gMB.Item_i8User;
                    uObjType:=OBJ_MENUBAR;
                    {$IFDEF LOGMESSAGES}
                    saSender:='ProcessMouse';
                    {$ENDIF}
                  End;//with
                  PostMessage(rSageMsg); 
                End;
                gbMenuDown:=False;
                gbMenuVisible:=false;
                grGFXOps.bUpdateZOrder:=true;
                {$IFDEF DEBUGTRACKGFXOPS}JcnLog_ity_Debug,201003040235,'grGfxOps - ProcessMouseMain menuitem selected',SOURCEFILE);{$ENDIF}
                gMB.Item_i8User:=0;
              End;
              //SageLog(1,'Got a PopUp Item Exact');
              // Visit this when adding sub-sub menus etc
              //---------------------------------------------------------
              // this is where SubMenus Off the Menu Bar Get their  
              // VC's X,Y Coords.
              //---------------------------------------------------------
              //i4PopUpX:=JFC_XXDL(Mb.item_lpPTR).id[3] and $000000FF;
              //i4PopUpX-=1;
              //i4PopUpY:=rLMEvent.VMY+1;
              //TempMB:=MB.UID;
              //if MB.FoundItem_UID(JFC_XXDL(MB.item_lpPTR).ID2) then
              //begin
              //  TempVC:=GetActiveVC;
              //  SetActiveVC(JFC_XXDL(MB.item_lpPTR).VC);
              //  VCSetXY(i4PopUpX,i4PopUpY);
              //  SetActiveVC(TempVC);
              //end;
              //MB.FoundItem_UID(TempMB);
              //---------------------------------------------------------
            End
            else
            begin
              // We force update (to be safe) if this popup item WAS selected and now is not
              bPopUpChanged:=(JFC_XXDL(gMB.Item_lpPTR).Item_i8User<>-1);
              JFC_XXDL(gMB.Item_lpPTR).Item_i8User:=-1;
            End;
          Until (not JFC_XXDL(gMB.Item_lpPTR).MoveNext);
          if bPopUpChanged then 
          begin
            grGFXOps.bUpdateZOrder:=true;
            {$IFDEF DEBUGTRACKGFXOPS}JcnLog_ity_Debug,201003040235,'grGfxOps - ProcessMouseMain popup change',SOURCEFILE);{$ENDIF}
          end;
        End
        Else
        Begin
          // have a popup with no items; force update in case user removed items previously
          gbMenuDown:=False;
          gbMenuVisible:=false;
          grGFXOps.bUpdateZOrder:=true;
          {$IFDEF DEBUGTRACKGFXOPS}JcnLog_ity_Debug,201003040235,'grGfxOps - ProcessMouseMain popup no items forced',SOURCEFILE);{$ENDIF}
        End;
      end;
    end;  
  End;

  OBJ_WINDOW     :Begin
    //cnLog_ITY_DEBUG, 0,'About to call: TWindow(lpObj).ProcessMouse(p_bMouseIdle) with lpOBJ='+inttostr(Cardinal(lpOBJ)),SOURCEFILE);
    TWindow(lpObj).ProcessMouse(p_bMouseIdle); 
  End;
  OBJ_LABEL      :        tctlLabel(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_VSCROLLBAR :   tctlVSCROLLBAR(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_HSCROLLBAR :   tctlHSCROLLBAR(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_PROGRESSBAR:  tctlPROGRESSBAR(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_INPUT      :        tctlINPUT(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_BUTTON     :       tctlBUTTON(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_CHECKBOX   :     tctlCheckBox(lpObj).ProcessMouse(p_bMouseIdle);
  OBJ_LISTBOX    :      tctlListBox(lpObj).ProcessMouse(p_bMouseIdle);
  End; //switch

  If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then 
  Begin
    If (not gbUnhandledMouseEvent) Then
    Begin
      //grGfxOps.bUpdateConsole:=true;
      if grMSC.uCmd=MSC_WindowSize then
      begin
        TWindow(JFC_XXDL(OBJECTSXXDL.lpItem).lpPtr).PaintWindow;
        grGfxOps.bUpdateConsole:=true;
      end;
      if gbMenuVisible then
      begin
        grGfxOps.bUpdateZOrder:=true;
      end;
    End
    else
    begin
      //grGfxOps.bUpdateConsole:=true;
      //pdateConsole;
    end;
  End;


  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('ProcessMouseMain',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
// Returns TRUE if Actual User IO - Albeit Keyboard or mouse.
// This result is based on an increase in the # of Messages in MQ CHANGING.
// This function is still responsible for posting messages about what it finds 
// happening with the user.
Function ProcessUserIO: Boolean;
//=============================================================================
Var iMQOnEntry: Integer;
    rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('ProcessUserIO',SOURCEFILE);
  {$ENDIF}

  rSageMsg.lpPTR:=nil;// Shutup compiler

  iMQOnEntry:=MQ.ListCount;
  
  If KeyHit Then
  Begin
    //repeat
      gbUnhandledKeypress:=True;
      GetKeyPress;
      If (WinDebugKeyBoard.windowstate<>WS_MINIMIZED) and (WinDebugKeyBoard.Visible) Then windebugkeyboard.paintwindow;
      If (WinDebugKeyPress.windowstate<>WS_MINIMIZED) and (WinDebugKeyPress.Visible) Then WinDebugKeyPress.PaintWindow;
      ProcessKeyBoardMain;
    //until (not keyhit) or gbUnhandledKeypress;
  End //keyhit (If or While statement loop)
  Else
  Begin
    gbUnhandledKeypress:=False;
    If MEvent Then
    Begin
      repeat
        gbUnhandledMouseEvent:=True;
        GetMEvent;
        
        // This is an attempt to optimize performance when a series of
        // mouse move events are pending. I'm not sure of its 
        // impact. The goal is to pull off all the move events until
        // either no more events pending or the next event isn't a 
        // move - to make the system only respond to the most RECENT
        // move event. 
        While (rLMEvent.Action=MouseActionMove) and
              (Mevent) and
              (rPollMouseEvent.action=mouseactionmove) Do GetMEvent;     
        If (windebugmouse.windowstate<>ws_minimized) and (windebugmouse.Visible) Then WinDebugMouse.paintwindow;     
        ProcessMouseMain(False);//MOUSE IDLE Flag FALSE
      Until (not  Mevent) OR gbUnhandledMouseEvent;
    End
    Else
    Begin
      gbUnhandledMouseEvent:=False;
      ProcessMouseMain(True);//MOUSE IDLE Flag TRUE
    End;  
  End;

  
  If gbUnhandledKeypress Then 
  Begin
    With rSageMsg Do Begin
      lpPTR:=nil;
      uMsg:=MSG_UNHANDLEDKEYPRESS;
      uParam1:=0;
      uParam2:=0;
      uObjType:=OBJ_NONE;
      {$IFDEF LOGMESSAGES}
      saSender:='ProcessUserIO';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 
  End
  Else
  
  If gbUnhandledMouseEvent Then
  Begin
    With rSageMsg Do Begin
      lpPTR:=nil;
      uMsg:=MSG_UNHANDLEDMOUSE;
      uParam1:=0;
      uParam2:=0;
      uObjType:=OBJ_NONE;
      {$IFDEF LOGMESSAGES}
      saSender:='ProcessUserIO';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 
  End;

  Result:=not (MQ.ListCount=iMQOnEntry);
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('ProcessUserIO',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure SetUIEnabled(p_b: Boolean);
//=============================================================================
//var sa: AnsiString;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetUIEnabled',SOURCEFILE);
  {$ENDIF}

  If p_b Then
  Begin
    If p_b<>gbSageUI_Enabled Then
    Begin
      If VC.ListCount>0 Then
      Begin
        VC.MoveFirst;
        repeat
          SetActiveVC(OBJECTSXXDL.Item_ID1);// this might be WRONG: VC.Item_UID 
          If VCGetVisible Then OBJECTSXXDL.Item_ID4:=1 Else OBJECTSXXDL.Item_ID4:=0;
        Until not VC.MoveNext;
        gbSageUI_Enabled:=p_b;
        //pdateconsole;grGfxOps.b pdateConsole:=false;
      End;
    End;
  End
  Else
  Begin
    If p_b<>gbSageUI_Enabled Then
    Begin
      If VC.ListCount>0 Then
      Begin
        VC.MoveFirst;
        repeat
          //case OBJECTSXXDL.Item_ID2 of
          //OBJ_VCMAIN      :sa := 'OBJ_VCMAIN';
          //OBJ_VCSTATUSBAR :sa := 'OBJ_VCSTATUSBAR';
          //OBJ_MENUBAR   :sa := 'OBJ_MENUBAR';
          //OBJ_MENUBARPOPUP :sa := 'OBJ_MENUBARPOPUP';
          //OBJ_WINDOW    :sa := 'OBJ_WINDOW';
          //End;
          //Log(cnLog_Debug,201003032151,'SetUIEnabled Disable:'+sa+' gVC.Item_ID1:'+inttostr(OBJECTSXXDL.Item_ID1),SOURCEFILE);
          SetActiveVC(OBJECTSXXDL.Item_ID2);
          If not VCGetVisible Then OBJECTSXXDL.Item_ID4:=1 Else OBJECTSXXDL.Item_ID4:=0;
          VCSetVisible(False);
        Until not VC.MoveNExt;
        gbSageUI_Enabled:=p_b;
        //pdateconsole;grGfxOps.b pdateConsole:=false;
      End;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetUIEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function uNewVCObject(
  p_saObjectName: AnsiString;
  p_i4Width,
  p_i4Height:LongInt;
  p_iSageUI_Object_Type: Integer;
  p_ptr: pointer
): UINT;
//=============================================================================
Var
  iTestNewVC: INT;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('uNewVCObject',SOURCEFILE);
  {$ENDIF}
  
  // gVC.Append(p_ptr);
  OBJECTSXXDL.AppendItem;
  OBJECTSXXDL.Item_lpPTR:=p_ptr;
  OBJECTSXXDL.Item_ID1:=0;
  OBJECTSXXDL.Item_saName:=p_saObjectName;
  
  iTestNewVC:=NewVC(p_i4Width,p_i4Height);
  OBJECTSXXDL.Item_ID2:=iTestNewVC; Result:=OBJECTSXXDL.Item_ID2;
  //SageLog(1,'TEST NEW VC:'+inttostr(iTestNewVC)+' OT: (5=window):'+inttostr(p_iSageUI_Object_Type)+' Returned Result:'+inttostr(Result),sourcefile);
  
  OBJECTSXXDL.Item_ID3:=p_iSageUI_Object_Type;
  OBJECTSXXDL.Item_ID4:=0;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('uNewVCObject',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure RemoveVCObject(p: UINT);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('RemoveVCObject',SOURCEFILE);
  {$ENDIF}

  RemoveVC(p);
  If OBJECTSXXDL.FoundItem_ID(p,2) Then 
  Begin
    OBJECTSXXDL.DeleteItem;
    // Could Do Optimization Here
    // Like IF IT WAS VISIBLE on the screen, then
    // One of these numbers: grGfxOps.b pdateConsole:=True;
    grGfxOps.bUpdateConsole:=True;
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - removevcobject',SOURCEFILE);{$ENDIF}
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('RemoveVCObject',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function MsgBoxHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('MsgBoxHandler',SOURCEFILE);
  {$ENDIF}

  Result:=0;

  Case p_rSageMsg.uMsg Of
  MSG_IDLE               :;
  MSG_FIRSTCALL          :;
  MSG_UNHANDLEDKEYPRESS  :Begin
    If rLKey.ch=#27 Then
    Begin
      Case gi4MsgBoxFlags Of
      MB_ABORTRETRYIGNORE:gi4MsgBoxResult:=IDABORT;
      MB_OK              :gi4MsgBoxResult:=IDOK;
    
      MB_OKCANCEL        :gi4MsgBoxResult:=IDCANCEL;
      MB_RETRYCANCEL     :gi4MsgBoxResult:=IDCANCEL;
      MB_YESNO           :gi4MsgBoxResult:=IDNO;
      MB_YESNOCANCEL	   :gi4MsgBoxResult:=IDCANCEL;
      End;//case
    End;
  End;
  MSG_UNHANDLEDMOUSE     :;
  MSG_MENU               :;
  MSG_SHUTDOWN           :;
  MSG_CLOSE              :;
  MSG_DESTROY            :;
  MSG_BUTTONDOWN         :Begin
    If p_rSageMsg.uParam2=gctlButton[1].UID Then
    //if p_rSageMsg.uParam2=gctlButton[1].ID then
    Begin
      Case gi4MsgBoxFlags Of
      MB_ABORTRETRYIGNORE:gi4MsgBoxResult:=IDABORT;
      MB_OK              :gi4MsgBoxResult:=IDOK;
      MB_OKCANCEL        :gi4MsgBoxResult:=IDOK;
      MB_RETRYCANCEL     :gi4MsgBoxResult:=IDRETRY;
      MB_YESNO           :gi4MsgBoxResult:=IDYES;
      MB_YESNOCANCEL	   :gi4MsgBoxResult:=IDYES;
      End;//case
    End
    Else If p_rSageMsg.uParam2=gctlButton[2].UID Then
    Begin
      Case gi4MsgBoxFlags Of
      MB_ABORTRETRYIGNORE:gi4MsgBoxResult:=IDRETRY;
      MB_OK              :;
      MB_OKCANCEL        :gi4MsgBoxResult:=IDCANCEL;
      MB_RETRYCANCEL     :gi4MsgBoxResult:=IDCANCEL;
      MB_YESNO           :gi4MsgBoxResult:=IDNO;
      MB_YESNOCANCEL	   :gi4MsgBoxResult:=IDNO;
      End;//case
    End
    Else If p_rSageMsg.uParam2=gctlButton[3].UID Then
    Begin
      Case gi4MsgBoxFlags Of
      MB_ABORTRETRYIGNORE:gi4MsgBoxResult:=IDIGNORE;
      MB_OK              :;
      MB_OKCANCEL        :;
      MB_RETRYCANCEL     :;
      MB_YESNO           :;
      MB_YESNOCANCEL	   :gi4MsgBoxResult:=IDCANCEL;
      End;//case
    End;
  End;
  MSG_LOSTFOCUS          :;
  MSG_GOTFOCUS           :;
  MSG_CTLLOSTFOCUS       :;
  MSG_CTLGOTFOCUS        :;
  MSG_WINDOWSTATE        :;
  MSG_WINDOWRESIZE       :;
  MSG_WINDOWMOVE         :;
  MSG_CTLSCROLLLEFT      :;
  MSG_CTLSCROLLRIGHT     :;
  MSG_CTLSCROLLUP        :;
  MSG_CTLSCROLLDOWN      :;
  MSG_CHECKBOX           :;
  MSG_LISTBOXMOVE        :;
  MSG_LISTBOXCLICK       :;
  End;



  // TODO: This looks real funky - need to set when
  //       ESC is pressed - whenever a FINISHMSGBOX condition met
  //if p_rSageMsg.uMsg=MSG_BUTTONDOWN then gi4MsgBoxResult:=1;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('MsgBoxHandler',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================

//=============================================================================
Function InputBoxHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('InputBoxHandler',SOURCEFILE);
  {$ENDIF}

  Result:=0;
  //sagelog(1,'Inputbox handler');
  Case p_rSageMsg.uMsg Of
  MSG_IDLE               :;
  MSG_FIRSTCALL          :;
  MSG_UNHANDLEDKEYPRESS  :Begin
    If rLKey.ch=#27 Then
    Begin
      gi4MsgBoxResult:=2;
    End;
  End;
  MSG_UNHANDLEDMOUSE     :;
  MSG_MENU               :;
  MSG_SHUTDOWN           :;
  MSG_CLOSE              :;
  MSG_DESTROY            :;
  MSG_BUTTONDOWN         :Begin
    //sagelog(1,'sageui inputboxhandler' +
    //  'param:'+inttostr(var p_rSageMsg.uParam2)+' '+
    //  'Button 1 id (OK):'+inttostr(gctlButton[1].UID));
      
    If p_rSageMsg.uParam2=gctlButton[1].UID Then
    Begin
      //OK button
      gi4MsgBoxResult:=1;
    End
    Else If p_rSageMsg.uParam2=gctlButton[2].UID Then
    Begin
      //cancelbutton
      gi4MsgboxResult:=2;
    End;
  End;
  MSG_LOSTFOCUS          :;
  MSG_GOTFOCUS           :;
  MSG_CTLLOSTFOCUS       :;
  MSG_CTLGOTFOCUS        :;
  MSG_WINDOWSTATE        :;
  MSG_WINDOWRESIZE       :;
  MSG_WINDOWMOVE         :;
  MSG_CTLSCROLLLEFT      :;
  MSG_CTLSCROLLRIGHT     :;
  MSG_CTLSCROLLUP        :;
  MSG_CTLSCROLLDOWN      :;
  MSG_CHECKBOX           :;
  MSG_LISTBOXMOVE        :;
  MSG_LISTBOXCLICK       :;
  End;

//  Result:=0;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('InputBoxHandler',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================






//=============================================================================
Procedure LoadFBListBox;
//=============================================================================
Var saEntry: AnsiString;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('LoadFBListBox',SOURCEFILE);
  {$ENDIF}
  gFBListBox.DeleteAllCaptions;
  gFBListBox.DeleteAll; // Just to be safe - should be redundant
  gFBListBox.AppendCaption('Attributes: R=ReadOnly H=Hidden S=SysFile A=Archive');
  gFBListBox.AppendCaption(gFBDir.saPath);

  gFBDir.MoveFirst;

  repeat
    saEntry:='';
    If gFBDir.Item_bReadOnly Then saEntry:=saEntry+'R' Else saEntry:=saEntry+'-';
    If gFBDir.Item_bHidden Then saEntry:=saEntry+'H' Else saEntry:=saEntry+'-';
    If gFBDir.Item_bSysFile Then saEntry:=saEntry+'S' Else saEntry:=saEntry+'-';
    If gFBDir.Item_bArchive Then saEntry:=saEntry+'A' Else saEntry:=saEntry+'-';
    If gFBDir.Item_bDir Then saEntry:=saEntry+csDOSSLASH Else saEntry:=saEntry+' ';
    saEntry:=saEntry+gFBDir.Item_saNAme;
    gFBListBox.Append(False,saEntry);
    If gFBDir.Item_bDir Then gFBListBox.ChangeItemFG(Green);        
    If gFBDir.Item_bSysFile Then gFBListBox.ChangeItemFG(Red);
  Until not gFBDir.MoveNExt;
  gFBListBox.CurrentItem:=1;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('LoadFBListBox',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function FileBoxHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Var bGotIt: Boolean;



Procedure userselection;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('FileBoxHandler.userselection',SOURCEFILE);
  {$ENDIF}

  //MsgBox('','Found Item:'+inttostr(gFBListBox.CurrentItem)+' '+
  //        saTrueFalse(gFBDir.FoundNTh(gFBListBox.CurrentItem))+
  //       'Name:'+gFBDir.Item_saName+' bDir:'+saTrueFalse(gFBDir.Item_bDir),MB_OK); 
  If gFBDir.FoundNTh(gFBListBox.CurrentItem) Then Begin
    If gFBDir.Item_bDir Then Begin
      If gFBDir.Item_saName='..' Then Begin
        gFBDir.PreviousDir;
        LoadFBListBox;
      End Else Begin
        gFBDir.saPath:=gFBDir.saPath+gFBDir.Item_saName;
        gFBDir.LoadDir;
        LoadFBListBox;
      End;
      bGotit:=True;
    End
    Else
    Begin
      giFBResult:=1; // Just to make stop for now - Same as OK Button
      bGotIt:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('FileBoxHandler.userselection',SOURCEFILE);
  {$ENDIF}
End;




Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('FileBoxHandler',SOURCEFILE);
  {$ENDIF}
  Result:=0;

  Case p_rSageMsg.uMsg Of
  MSG_IDLE               : Begin
    //if gFBListBox.ListCount=0 then LoadListBox;
  End;
  MSG_UNHANDLEDKEYPRESS  :Begin
    If rLKey.ch=#27 Then giFBResult:=-1;
  End;
  MSG_CLOSE              :giFBResult:=-1;
  MSG_BUTTONDOWN         :Begin
    //if MsgBox('','Button Down param:'+inttostr(p_rSageMsg.uParam2)+' '+
    //'Button 1 id (OK):'+inttostr(gFBButton[1].UID),MB_OKCANCEL) = IDOK then
    //msgbox('','OK',MB_OK) else msgbox('','CANCEL',MB_OK);
    If p_rSageMsg.uParam2=gFBButton[1].UID Then giFBResult:=1;
    If p_rSageMsg.uParam2=gFBButton[2].UID Then giFBResult:=-1; // Cancel
  End;

  MSG_WINDOWSTATE, MSG_WINDOWRESIZE:Begin
    gfbListBox.Width:=gfbWindow.Width-3;
    gfbListBox.Height:=gfbWindow.height-9;
    gFBButton[1].Y:=gFBWindow.Height-2;
    gFBButton[2].Y:=gFBWindow.Height-2;
  End;
  MSG_LISTBOXMOVE        :Begin
    gFBButton[1].Enabled:=gFBDir.FoundNTh(gFBListBox.CurrentItem) and (not gFBDir.Item_bDir);
  End;
  MSG_LISTBOXCLICK       : Begin
    UserSelection;
  End;
  MSG_LISTBOXKEYPRESS    : Begin
    bGotIt:=False;
    // keypresses requiring items in list
    If (bGotIt=False) and (gFBListBox.ListCount>0) Then
    Begin
      If rLKey.ch=#27 Then giFBResult:=-1;
      If (rLKey.ch=#8)and 
         (not rLKey.bCntlPressed) and 
         (not rLkey.bShiftPressed) Then
      Begin
        gFBDir.PreviousDir;
        LoadFBListBox;
        bGotit:=True;
        gFBWindow.C.FoundItem_UID(gFBWindow.C.Item_UID);
      End
      Else
      If (rLKey.ch=#13)and 
         (not rLKey.bCntlPressed) and 
         (not rLkey.bShiftPressed) Then
      Begin
        UserSelection;
      End;
    End;
  End;
  End; // case

  If giFBResult=1 Then Begin
    gsaFBResult:=gFBDir.saPath+gFBDir.Item_saName;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('FileBoxHandler',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





// Private Routines Above
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
// Exported Routines Below

//=============================================================================
Function MsgBox(
         p_saCaption: AnsiString;
         p_saMsg: AnsiString;
         p_i4Flags: LongInt): LongInt;
//=============================================================================
Var 
  rSageMsg: rtSageMsg;
//  dtMsg: TDATETIME;

  uOldW: Cardinal;

  lpfnUserMain: pointer;
  //tmq: pointer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('MsgBox',SOURCEFILE);
  {$ENDIF}

  rSageMsg.lpPTR:=nil;//shutup compiler
  Result:=0;
  
  if gbMsgBoxOpen then exit;
  gbMsgBoxOpen:=true;
  
  uOldW:=gi4WindowHasFocusUID;
  gi4MsgBoxFlags:=p_i4Flags;
  
  gbMenuVisible:=false;
  gbMenudown:=false;
  gbModal:=true; 
  
//sagelog(1,'-----------------Entering MsgBox----------------------');
  if gMsgBoxWindow<>nil then
  begin
    gMsgBoxWindow.destroy;
    gMsgBoxWindow:=nil;
  end; 
  
  if gMsgBoxWindow=nil then
  begin
    grCW.saName:='MsgBoxWindow';
    grCW.X:=iPlotCenter(giConsoleWidth,grCW.Width);
    grCW.Y:=iPlotCenter(giConsoleHeight,grCW.Height);
    grCW.Width:=70;
    grCW.Height:=16;
    grCW.bFrame:=True;
    grCW.WindowState:=WS_NORMAL;
    grCW.bCaption:=True;
    grCW.bMinimizeButton:=False;
    grCW.bMaximizeButton:=False;
    grCW.bCloseButton:=False;
    grCW.bSizable:=False;
    grCW.bVisible:=True;
    grCW.bEnabled:=True;
    grCW.lpfnWndProc:=@msgboxHandler;
    grCW.bAlwaysOnTop:=True;
    gMsgBoxWindow:=TWindow.create(grCW);
  
    gctlLabel:=tctlLabel.create(gMsgBoxWindow);
    gctlButton[1]:=tctlButton.create(gMsgBoxWindow);
    gctlButton[2]:=tctlButton.create(gMsgBoxWindow);    
    gctlButton[3]:=tctlButton.create(gMsgBoxWindow);
  end;

  gMsgBoxWindow.Caption:=p_saCaption;


  gctlLabel.X:=2;
  gctlLabel.Y:=2;
  gctlLabel.Width:=gMsgBoxWindow.Width-2;
  gctlLabel.Height:=gMsgBoxWindow.Height-4;//allow room for buttons
  gctlLabel.Caption:=p_saMsg;
  gctlLabel.Enabled:=True;
  gctlLabel.Visible:=True;

  gctlButton[1].Visible:=true;
  gctlButton[2].Visible:=false;
  gctlButton[3].Visible:=false;
  
  Case p_i4Flags Of
  MB_ABORTRETRYIGNORE:Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=true;
    gctlButton[3].Visible:=true;
    
    gctlButton[1].Y:=gMsgBoxWindow.Height-1;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width);
    gctlButton[1].Caption:='&Abort';
    
    gctlButton[2].Y:=gMsgBoxWindow.Height-2;
    gctlButton[2].Width:=8;
    gctlButton[2].X:=iPlotCenter(gMsgBoxWindow.Width,gctlButton[1].Width);
    gctlButton[2].Caption:='&Retry';

    gctlButton[3].Y:=gMsgBoxWindow.Height-2;
    gctlButton[3].Width:=8;
    gctlButton[3].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width)+(gMsgBoxWindow.Width Div 2);
    gctlButton[3].Caption:='&Ignore';
  End;
  MB_OK              :Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=false;
    gctlButton[3].Visible:=false;

    gctlButton[1].Y:=gMsgBoxWindow.Height-2;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width,gctlButton[1].Width);
    gctlButton[1].Caption:='&Ok';
  End;

  MB_OKCANCEL        :Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=true;
    gctlButton[3].Visible:=false;

    gctlButton[1].Y:=gMsgBoxWindow.Height-2;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width);
    gctlButton[1].Caption:='&Ok';

    gctlButton[2]:=tctlButton.create(gMsgBoxWindow);
    gctlButton[2].Y:=gMsgBoxWindow.Height-2;
    gctlButton[2].Width:=8;
    gctlButton[2].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[2].Width)+(gMsgBoxWindow.Width Div 2);
    gctlButton[2].Caption:='&Cancel';
  End;
  MB_RETRYCANCEL     :Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=true;
    gctlButton[3].Visible:=false;

    gctlButton[1].Y:=gMsgBoxWindow.Height-2;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width);
    gctlButton[1].Caption:='&Retry';

    gctlButton[2].Y:=gMsgBoxWindow.Height-2;
    gctlButton[2].Width:=8;
    gctlButton[2].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[2].Width)+(gMsgBoxWindow.Width Div 2);
    gctlButton[2].Caption:='&Cancel';
  End;
  MB_YESNO           :Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=true;
    gctlButton[3].Visible:=false;

    gctlButton[1].Y:=gMsgBoxWindow.Height-2;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width);
    gctlButton[1].Caption:='&Yes';

    gctlButton[2].Y:=gMsgBoxWindow.Height-2;
    gctlButton[2].Width:=8;
    gctlButton[2].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[2].Width)+(gMsgBoxWindow.Width Div 2);
    gctlButton[2].Caption:='&No';
  End;
  MB_YESNOCANCEL	   :Begin
    gctlButton[1].Visible:=true;
    gctlButton[2].Visible:=true;
    gctlButton[3].Visible:=true;

    gctlButton[1].Y:=gMsgBoxWindow.Height-3;
    gctlButton[1].Width:=8;
    gctlButton[1].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[1].Width);
    gctlButton[1].Caption:='&Yes';

    gctlButton[2].Y:=gMsgBoxWindow.Height-3;
    gctlButton[2].Width:=8;
    gctlButton[2].X:=iPlotCenter(gMsgBoxWindow.Width,gctlButton[2].Width);
    gctlButton[2].Caption:='&No';

    gctlButton[3].Y:=gMsgBoxWindow.Height-3;
    gctlButton[3].Width:=8;
    gctlButton[3].X:=iPlotCenter(gMsgBoxWindow.Width Div 2,gctlButton[3].Width)+(gMsgBoxWindow.Width Div 2);
    gctlButton[3].Caption:='&Cancel';
  End;
  Else 
    Result:=-1;  
  End;//case

  gctlButton[1].Redraw:=true;
  gctlButton[2].Redraw:=true;
  gctlButton[3].Redraw:=true;

  if OBJECTSXXDL.FoundItem_lpPtr(gMsgBoxWindow) then gi4WindowHasFocusUID:=JFC_XXDLITEM(gMsgboxWindow.SELFOBJECTITEM).UID;
  gi4WindowHasFocusUID:=JFC_XXDLITEM(gMsgBoxWindow.SELFOBJECTITEM).UID;

  gi4MsgBoxResult:=0;
  lpfnUserMain:=pointer(glpFUNCTION_uUsersMainMsgHandler);
  If Result<>-1 Then
  Begin
    glpFUNCTION_uUsersMainMsgHandler:=@MSGBOXHandler;
    gMsgBoxWindow.visible:=true;
    gMsgBoxWindow.SetFocus;
    gMsgBoxWindow.CntlChangeFocus(true,true);
    While (gi4MsgBoxResult=0) and (Getmessage(rSageMsg)) Do Begin
      DispatchMessage(rSageMsg);
    End;
    gbModal:=False;
    gMsgBoxWindow.visible:=false;
    WindowChangeFocus(false);
  End;
  If OBJECTSXXDL.FoundItem_UID(uOldW) Then
  Begin
    gi4WindowHasFocusUID:=uOldW;
    TWindow(OBJECTSXXDL.Item_lpPTR).bRedraw:=True;
    grGfxOps.bUpdateZOrder:=True;      
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - msgbox',SOURCEFILE);{$ENDIF}
  End;
  pointer(glpFUNCTION_uUsersMainMsgHandler):=lpfnUserMain;
  Result:=gi4MsgBoxResult;
  gbMsgBoxOpen:=false;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('MsgBox',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function InputBox(
         p_saCaption: AnsiString;
         p_saData: AnsiString;
         p_i4MaxLength: LongInt;
         p_i4Flags: LongInt): AnsiString;
//=============================================================================
Var 
  rSageMsg: rtSageMsg;
  uOldW: UINT;
  lpfnUserMain: pointer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('InputBox',SOURCEFILE);
  {$ENDIF}
  p_i4MaxLength:=p_i4MaxLength; // shutup compiler for now
  rSageMsg.lpPTr:=nil;//shutup compiler

  Result:=p_saData;

  if gbInputBoxOpen then exit;
  gbInputBoxOpen:=true;
  uOldW:=gi4WindowHasFocusUID;
  gbMenuVisible:=false;
  gbMenudown:=false;
  gbModal:=true;


//  gi4MsgBoxFlags:=p_i4Flags; 
  
//sagelog(1,'-----------------Entering InputBox----------------------');
  grCW.saCaption:='';
  If p_i4MaxLength=0 Then
  Begin
    grCW.Width:=giConsoleWidth;
  End
  Else
  Begin
    If Length(p_saCaption)>=p_i4MaxLength Then
    Begin
      If Length(p_saCaption)+8>=giConsoleWidth Then
      Begin
        grCW.Width:=giConsoleWidth;    
      End
      Else
      Begin
        grCW.Width:=Length(p_saCaption)+8;
      End;
    End
    Else
    Begin
      If p_i4MaxLength+8>=giConsoleWidth Then
      Begin
        grCW.Width:=giConsoleWidth;    
      End
      Else
      Begin
        grCW.Width:=p_i4MaxLength+8;
      End;
    End;
  End;
  
  if gInputBoxWindow=nil then
  begin
    grCW.saName:='InputBoxWindow';
    grCW.saCaption:=p_saCaption;
    grCW.X:=iPlotCenter(giConsoleWidth,grCW.Width);
    grCW.Y:=iPlotCenter(giConsoleHeight,grCW.Height);
    grCW.Width:=40;
    grCW.Height:=7;
    grCW.bFrame:=length(p_saCaption)>0;
    grCW.WindowState:=WS_NORMAL;
    grCW.bCaption:=True;
    grCW.bMinimizeButton:=False;
    grCW.bMaximizeButton:=False;
    grCW.bCloseButton:=False;
    grCW.bSizable:=False;
    grCW.bVisible:=True;
    grCW.bEnabled:=True;
    grCW.lpfnWndProc:=@InputboxHandler;
    grCW.bAlwaysOnTop:=True;
    gInputBoxWindow:=TWindow.create(grCW);
    gctlInput:=tctlInput.create(gInputboxWindow);
    gctlButton[1]:=tctlButton.create(gInputboxWindow);
    gctlButton[2]:=tctlButton.create(gInputboxWindow);
  end;
  gInputBoxWindow.Caption:=p_saCaption;
  
    
  If (p_i4MaxLength<grCW.Width-4) and (p_i4MaxLength<>0) Then gctlInput.Width:=p_i4MaxLength  Else gctlInput.Width:=grCW.Width-4;
  gctlInput.X:=iPlotCenter(gInputboxWindow.Width,gctlInput.Width);
  gctlInput.Y:=2;
  gctlInput.Data:=p_saData;
  gctlButton[1].Y:=gInputboxWindow.Height-2;
  gctlButton[1].Width:=8;
  gctlButton[1].X:=iPlotCenter(gInputboxWindow.Width Div 2,gctlButton[1].Width);
  gctlButton[1].Caption:='&Ok';
  gctlButton[2].Y:=gInputboxWindow.Height-2;
  gctlButton[2].Width:=8;
  gctlButton[2].X:=iPlotCenter(gInputboxWindow.Width Div 2,gctlButton[2].Width)+(gInputboxWindow.Width Div 2);
  gctlButton[2].Caption:='&Cancel';

  gi4MsgBoxResult:=0;
  if OBJECTSXXDL.FoundItem_lpPtr(gInputBoxWindow) then gi4WindowHasFocusUID:=JFC_XXDLITEM(gInputBoxWindow.SELFOBJECTITEM).UID;
  gi4WindowHasFocusUID:=JFC_XXDLITEM(gInputBoxWindow.SELFOBJECTITEM).UID;
  
  lpfnUserMain:=pointer(glpFUNCTION_uUsersMainMsgHandler);
  glpFUNCTION_uUsersMainMsgHandler:=@InputBoxHandler;
  gInputBoxWindow.visible:=true;
  gInputBoxWindow.i4ControlWithFocusUID:=gctlInput.CTLUID;
  gInputBoxWindow.SetFocus;
  grGfxOps.bUpdateZOrder:=true;
  While (gi4MsgBoxResult=0) and (Getmessage(rSageMsg)) Do Begin
    DispatchMessage(rSageMsg);
  End;
  gbModal:=False;
  gInputBoxWindow.visible:=false;
  WindowChangeFocus(false);

  // Success
  If gi4MsgBoxResult=1 Then
  Begin
    Result:=gctlInput.Data;
  End
  Else
  Begin
    // User Cancelled - return sent data
    // RESULT already Set
  End;

  If ObjectsXXDL.FoundItem_UID(uOldW) Then
  Begin
    gi4WindowHasFocusUID:=uOldW;
    TWindow(ObjectsXXDL.Item_lpPTR).bRedraw:=True;
    grGfxOps.bUpdateZOrder:=True;      
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - inputbox',SOURCEFILE);{$ENDIF}
  End;
  pointer(glpFUNCTION_uUsersMainMsgHandler):=lpfnUserMain;
  gbInputBoxOpen:=false;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('InputBox',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function FileBox(
         p_saCaption: AnsiString;
         p_saPath: AnsiString;
         p_saFilespec: AnsiString;
         p_iFlags: Integer): AnsiString;
//=============================================================================
Var 
  rSageMsg: rtSageMsg;
  uOldW: UINT;
  lpfnUserMain: pointer;
  bErr: Boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('FileBox',SOURCEFILE);
  {$ENDIF}
  if gbFileBoxOpen then exit;
  gbFileBoxOpen:=true;

  if gFBWindow=nil then 
  begin
    grCW.saName:='FileBoxWindow';
    grCW.saCaption:='';
    grCW.X:=iPlotCenter(giConsoleWidth,grCW.Width);
    grCW.Y:=iPlotCenter(giConsoleHeight,grCW.Height);
    grCW.Width:=(giConsoleWidth Div 8)*7;
    grCW.Height:=(giConsoleHeight Div 8)*7;
    grCW.bFrame:=True;
    grCW.WindowState:=WS_NORMAL;
    grCW.bCaption:=True;
    grCW.bMinimizeButton:=False;
    grCW.bMaximizeButton:=True;
    grCW.bCloseButton:=True;
    grCW.bSizable:=False;
    grCW.bVisible:=True;
    grCW.bEnabled:=True;
    grCW.lpfnWndProc:=@fileboxHandler;
    grCW.bAlwaysOnTop:=True;
    grCW.saCaption:=p_saCaption;
    gFBWindow:=TWindow.create(grCW);
    gFbListBox:=tctlListBox.create(gFBWindow);
    gfbLabelFile:=tctlLabel.create(gFBWindow);
    gFBInputFile:=tctlInput.create(gFBWindow);
    gFBButton[1]:=tctlButton.create(gFBWindow);
    gFBButton[2]:=tctlButton.create(gFBWindow);
    gFBDir:=JFC_DIR.Create;
  end;

  
  rSageMsg.lpPtr:=nil;//shutup compiler
  gsaFBResult:='';
  gFBDir.saFileSpec:=p_saFileSpec;
  gFBDir.saPath:=p_saPath;
  gFBDir.LoadDir;
  
  uOldW:=gi4WindowHasFocusUID;
  bErr:=False;
  giFBFlags:=p_iFlags;

  gFbListBox.X:=2;
  gFbListBox.Y:=2;
  gFBListBox.Width:=gFBWindow.Width-3;
  gFBListBox.Height:=gFBWindow.height-9;
  //cListBox[1].Height:=5; 
  gFBListBox.DataWidth:=302;
  gFBListBox.ShowCheckMarks:=True;
  LoadFBListBox;

  If giFBFlags = FB_SaveFile Then Begin
    gfbLabelFile.x:=2;
    gfbLabelFile.y:=gFBWindow.height-3;
    gfbLabelFile.caption:='Filename:';
    gFBLabelFile.width:=9;
    gFBLabelFile.height:=1;
    
    gFBInputFile.X:=gfbLabelFile.x+gfbLabelFile.width;
    gfbinputfile.Y:=gfblabelfile.y;
    gfbinputfile.width:=gFBWindow.Width- gFBInputFile.x - 1;
    gfbinputfile.maxlength:=255;
  End;

  {
  gctlLabel:=tctlLabel.create(gWindow);
  gctlLabel.X:=2;
  gctlLabel.Y:=2;
  gctlLabel.Width:=gWindow.Width-2;
  gctlLabel.Height:=gWindow.Height-4;//allow room for buttons
  gctlLabel.Caption:=p_saMsg;
  gctlLabel.Enabled:=True;
  gctlLabel.Visible:=True;
  }
  
  gFBButton[1].Y:=gFBWindow.Height-2;
  gFBButton[1].Width:=8;
  gFBButton[1].X:=iPlotCenter(gFBWindow.Width Div 2,gFBButton[1].Width);
  gFBButton[1].Enabled:=False;
  
  gFBButton[2].Y:=gFBWindow.Height-2;
  gFBButton[2].Width:=8;
  gFBButton[2].X:=iPlotCenter(gFBWindow.Width Div 2,gFBButton[2].Width)+(gFBWindow.Width Div 2);
  
  Case p_iFlags Of
  FB_GETDIR: Begin
    gFBButton[1].Caption:='&Ok';
    gFBButton[2].Caption:='&Cancel';
  End;
  FB_GETFILE: Begin
    gFBButton[1].Caption:='&Open';
    gFBButton[2].Caption:='&Cancel';
  End;
  FB_SAVEFILE: Begin
    gFBButton[1].Caption:='&Save';
    gFBButton[2].Caption:='&Cancel';
  End;
  Else 
    bErr:=True;
  End;//case

  giFBResult:=0;
  if OBJECTSXXDL.FoundItem_lpPtr(gFBWindow) then gi4WindowHasFocusUID:=JFC_XXDLITEM(gFBWindow.SELFOBJECTITEM).UID;
  gi4WindowHasFocusUID:=JFC_XXDLITEM(gFBWindow.SELFOBJECTITEM).UID;

  lpfnUserMain:=pointer(glpFUNCTION_uUsersMainMsgHandler);
  
  If not bErr Then
  Begin
    glpFUNCTION_uUsersMainMsgHandler:=@FileBoxHandler;
    gFBWindow.visible:=true;
    gFBWindow.CntlChangeFocus(true,true);
    gbModal:=true;
    While (giFBResult=0) and (Getmessage(rSageMsg)) Do Begin
      DispatchMessage(rSageMsg);
    End;
    while MQ.FoundItem_lpPtr(gFBWindow) do MQ.DeleteItem;
    gbModal:=false;
    gFBWindow.visible:=false;
    WindowChangeFocus(false);
  End;

  If ObjectsXXDL.FoundItem_UID(uOldW) Then
  Begin
    gi4WindowHasFocusUID:=uOldW;
    TWindow(ObjectsXXDL.Item_lpPTR).bRedraw:=True;
    grGfxOps.bUpdateZOrder:=True;      
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - filebox',SOURCEFILE);{$ENDIF}
  End;

  pointer(glpFUNCTION_uUsersMainMsgHandler):=lpfnUserMain;
  Result:=gsaFBResult;
  gbFileBoxOpen:=false;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('FileBox',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================









//=============================================================================
Function DummyMsgHandler(Var p_rSageMsg: rtSageMsg):Cardinal;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DummyMsgHandler',SOURCEFILE);
  {$ENDIF}
  Result:=0;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('DummyMsgHandler',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
















//----------------------------------------------------------------------------
// SETUP BUILT IN USER INTERFACE OBJECTS
//----------------------------------------------------------------------------

//=============================================================================
Function WINDebugKeyPressMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugKeyPressMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      VCSetBGC(gu1FrameWindowBG) ;
      VCSetFGC(darkgray);
      DrawKeyBoard(2, 2);
      VCSetFGC(white);
      DrawKeyPressOnKeyBoard(2, 2,rLKey);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugKeyPressMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugKEYBOARDMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugKeyBoardMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      VCSetFGC(gu1NoFocusFG);VCSetBGC(gu1FrameWindowBG);
      VCWriteXY(2,2,'TERM: ');
      VCSetFGC(gu1FrameWindowFG);VCSetBGC(gu1FrameWindowBG);
      VCWrite(gsaTerm);
      DrawKeypressRecord(2,3, rLKey, gu1NoFocusFG, gu1FrameWindowBG, gu1FrameWindowFG, gu1FrameWindowBG);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugKeyBoardMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugMouseMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugmouseMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      // MOUSE--- STATUS Stuff
      DrawMouseEventRecord(2,2,rLMevent,gu1NoFocusFG,gu1FrameWindowBG,gu1FrameWindowFG,gu1FrameWindowBG);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugmouseMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugMQMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugMQMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      WVCDataPairInt(2,2,28,20,'Messages Processed:',MQ.pvt_u8AutoNumber);
      WVCDataPairInt(2,3,28,20,'Messages In Queue (MQ):',MQ.ListCount);
      WVCDataPairInt(2,4,28,20,'Max Msgs in MQ at one time:',giMQMaxListCount);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugMQMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugStatusBarMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Var 
  iVCTemp: Integer;
  //DEBUG The Status Bar
  bTempSBVisible:Boolean;
  iTempSBVCHeight: Integer;
  iTempSBVCGetY:Integer;
  iTempSBVCWidth:Integer;
  
  
  
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugStatusBarMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      ivctemp:=GetActiveVC;
      SetActiveVC(guVCStatusBar);
      bTempSBVisible:=VCGetVisible;
      iTempSBVCGetY:=VCGETY;
      iTempSBVCWidth:=VCWIDTH;
      iTempSBVCHeight:=VCHeight;
      SetActiveVC(iVCTemp);
      VCSetFGC(LightGray);
      VCSetBGC(gu1FrameWindowBG);
      WVCDataPairStr(2,2,28,5,'gbSBVisible:',saTrueFalse(gbSBVisible));
      WVCDataPairInt(2,3,28,5,'giVCStatusBarLastKnownYPos:',giVCStatusBarLastKnownYPos);
      WVCDataPairStr(2,4,28,5,'VCGetVisible:',saTrueFalse(bTempSBVisible));
      WVCDataPairInt(2,5,28,5,'VCGetY:',iTempSBVCGetY);
      WVCDataPairInt(2,6,28,5,'VCWidth:',iTempSBVCWidth);
      WVCDataPairInt(2,7,28,5,'VCHeight:',iTempSBVCHeight);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugStatusBarMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINLOGOMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Var 
  iLine: Integer;
  sa: ansistring;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinLogoMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      VCSetPenXY(iPlotCenter(VCWidth-2,48),3);
      //JegasUnderTheHoodLogoText;
      JegasLogo;
      VCSetBGC(gu1FrameWindowBG);
      
      VCSetFGC(Yellow);
      VCWriteXY(iPlotCenter(WINLOGO.rW.Width,length(grJegasCOmmon.saAppTitle)),2,grJegasCOmmon.saAppTitle);
      
      VCSetFGC(White);
      iLine:=13;
      VCWriteXY(2,iLine,saFixedLength(saRepeatChar(' ',iPlotCenter(WINLOGO.rW.Width-4,length(grJegasCommon.saAppProductName)))+grJegasCommon.saAppProductName,1,WINLOGO.rW.Width)); iLine+=2;

      sa:='Version: ' + grJegasCommon.saAppMajor+'.'+grJegasCommon.saAppMinor+'.'+grJegasCommon.saAppRevision;
      VCWriteXY(2,iLine,saFixedLength(saRepeatChar(' ',iPlotCenter(WINLOGO.rW.Width-4,length(sa)))+sa,1,WINLOGO.rW.Width)); iLine+=1;
      sa:='www.jegas.com';
      VCWriteXY(2,iLine,saFixedLength(saRepeatChar(' ',iPlotCenter(WINLOGO.rW.Width-4,length(sa)))+sa,1,WINLOGO.rW.Width)); iLine+=2;
      
      sa:='Press [F1] For Help';
      VCSetFGC(Yellow);VCWriteXY(2,iLine,saFixedLength(saRepeatChar(' ',iPlotCenter(WINLOGO.rW.Width-4,length(sa)))+sa,1,WINLOGO.rW.Width));iLine+=1;
      sa:='Press [F6] to show the Menu';
      VCSetFGC(Yellow);VCWriteXY(2,iLine,saFixedLength(saRepeatChar(' ',iPlotCenter(WINLOGO.rW.Width-4,length(sa)))+sa,1,WINLOGO.rW.Width));iLine+=1;
  
      //VCWriteXY(2,iLine,' '); iLine:=iLine+1;
      
      //VCWriteXY(2,iLine,'iPlotCenter:'+inttostr(iPlotCenter(WINLOGO.rW.Width,length(grJASConfig.saName))));
      //VCWriteXY(iPlotCenter(length(grJASConfig.saName),WINLOGO.rW.Width+2),iLine,grJASConfig.saName);
      //iLine:=iLine+1;
      
      
      //VCSetBGC(gu1FrameWindowBG);
      //VCSetFGC(Yellow);
      //VCWriteXY(2,iLine,'SYSTEM CONFIGURATION: '); iLine:=iLine+1;
      //VCSetFGC(White);
      //VCWrite(grJASConfig.saName);
      
      //VCWriteXY(2,iLine,'  '); iLine:=iLine+1;
      //VCWriteXY(2,iLine,'  '); iLine:=iLine+1;
      //VCWriteXY(2,iLine,'  '); iLine:=iLine+1;

    End;
  End;//case
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinLogoMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
function WinHelpAppendToExistingTopic(
  p_saTopicToAppend: ansistring;
  p_saVisibleText: ansistring;
  p_saTopicToLinkTo: ansistring
): boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=WinHelpTopicXDL.ListCount>0;
  if bOk then 
  begin
    bOk:=WinHelpTopicXDL.FoundItem_saName(p_saTopicToAppend,false);
  end;
  
  if bOk then
  begin
    repeat until (not WinHelpTopicXDL.MoveNext) or (WinHelpTopicXDL.Item_saName<>'');
    bOk:=WinHelpTopicXDL.Item_saName<>'';
  end;
  
  //if bOk then
  //begin
  //  bOk:=WinHelpTopicXDL.MovePrevious;
  //end;
  
  //if bOk then
  //begin
  //  bOk:=(WinHelpTopicXDL.Item_saName='') or  (upcase(WinHelpTopicXDL.Item_saName)=upcase(p_saTopicToAppend));
  //end;
  
  if bOk then
  begin
    bOk:=WinHelpTopicXDL.InsertItem_XDL(nil,'',p_saVisibleText,p_saTopicToLinkTo,0);
  end;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
Procedure WinHelpLoadListBox(p_saTopic: ansistring);
//=============================================================================
Var saEntry: AnsiString;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinHelpLoadListBox',SOURCEFILE);
  {$ENDIF}
  WinHelp_ctlListbox.DeleteAllCaptions;
  WinHelp_ctlListbox.DeleteAll; // Just to be safe - should be redundant
  WinHelp_ctlListbox.AppendCaption(p_saTopic);

  //if (p_saTopic<>'[HOME]') then
  //begin
  //  saEntry:='[HOME]';
  //  WinHelp_ctlListbox.Append(true,saEntry);
  //  WinHelp_ctlListbox.ItemTag:=1;
  //  WinHelp_ctlListbox.ChangeItemFG(Green);
  //end;

  if WinHelpTopicXDL.FoundItem_saName(p_saTopic,false) then
  begin 
    repeat
      saEntry:=WinHelpTopicXDL.Item_saValue;
      if length(WinHelpTopicXDL.Item_saDesc)>0 then
      begin
        WinHelp_ctlListbox.Append(true,saEntry);
        WinHelp_ctlListbox.ItemTag:=WinHelpTopicXDL.Item_UID;
        WinHelp_ctlListbox.ChangeItemFG(Green);
      end
      else
      begin
        WinHelp_ctlListbox.Append(false,saEntry);
        WinHelp_ctlListbox.ItemTag:=0;
        WinHelp_ctlListbox.ChangeItemFG(White);
      end;
    Until (not WinHelpTopicXDL.MoveNext) or (WinHelpTopicXDL.Item_saName<>'');
    WinHelp_ctlListbox.CurrentItem:=1;
  end
  else
  begin
    saEntry:='No information for this topic found.';
    WinHelp_ctlListbox.Append(false,saEntry);
    WinHelp_ctlListbox.ItemTag:=1;
    WinHelp_ctlListbox.ChangeItemFG(LightRed);
  end;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinHelpLoadListBox',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function WINHelpmsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Var bGotIt: Boolean;



Procedure userselection;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINHelpmsgHandler.userselection',SOURCEFILE);
  {$ENDIF}

  //MsgBox('','Found Item:'+inttostr(WinHelp_ctlListbox.CurrentItem)+' In WinHelpTopicXDL?:'+
  //        saTrueFalse(WinHelpTopicXDL.FoundNTh(WinHelp_ctlListbox.CurrentItem))+
  //       ' Name:'+WinHelpTopicXDL.Item_saName+
  //       ' Value:'+WinHelpTopicXDL.Item_saValue+
  //       ' Desc:'+WinHelpTopicXDL.Item_saValue+
  //       ' Tag:'+inttostR(WinHelp_ctlListbox.ItemTag)
  //       ,MB_OK); 
  
  if WinHelp_ctlListbox.CurrentItem>0 then 
  begin
    If WinHelpTopicXDL.FoundItem_UID(WinHelp_ctlListbox.ItemTag) Then 
    Begin
      WinHelpLoadListBox(WinHelpTopicXDL.Item_saDesc);
      bGotIt:=True;
    End;
  end;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINHelpmsgHandler.userselection',SOURCEFILE);
  {$ENDIF}
End;




Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINHelpmsgHandler',SOURCEFILE);
  {$ENDIF}
  Result:=0;

  Case p_rSageMsg.uMsg Of
  MSG_IDLE               : Begin
    //if WinHelp_ctlListbox.ListCount=0 then LoadListBox;
  End;
  MSG_UNHANDLEDKEYPRESS  :Begin
    //If rLKey.ch=#27 Then giWinHelpResult:=-1;
  End;
  MSG_CLOSE              :;//giWinHelpResult:=-1;
  MSG_BUTTONDOWN         :;

  MSG_WINDOWRESIZE,MSG_WINDOWSTATE,MSG_PAINTWINDOW:Begin
    WinHelp_ctlLabel.Width:=WinHelp.Width-3;
    WinHelp_ctlListbox.Width:=WinHelp.Width-3;
    WinHelp_ctlListbox.Height:=WinHelp.height-WinHelp_ctlLabel.Height-3;
  End;
  MSG_LISTBOXMOVE        :Begin
    //WinHelpButton[1].Enabled:=WinHelpTopicXDL.FoundNTh(WinHelp_ctlListbox.CurrentItem) and (not WinHelpTopicXDL.Item_bDir);
  End;
  MSG_LISTBOXCLICK       : Begin
    UserSelection;
  End;
  MSG_LISTBOXKEYPRESS    : Begin
    bGotIt:=False;
    // keypresses requiring items in list
    If (bGotIt=False) and (WinHelp_ctlListbox.ListCount>0) Then
    Begin
      ////If rLKey.ch=#27 Then giWinHelpResult:=-1;
      //If (rLKey.ch=#8)and 
      //   (not rLKey.bCntlPressed) and 
      //   (not rLkey.bShiftPressed) Then
      //Begin
      //  //WinHelpTopicXDL.PreviousDir;
      //  //WinHelpLoadListBox;
      //  bGotit:=True;
      //  WinHelp.C.FoundItem_UID(WinHelp.C.Item_UID);
      //End
      //Else
      If (rLKey.ch=#13)and 
         (not rLKey.bCntlPressed) and 
         (not rLkey.bShiftPressed) Then
      Begin
        UserSelection;
      End;
    End;
  End;
  End; // case

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINHelpmsgHandler',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
procedure SetBackground;
//=============================================================================
 begin
   // Shut them all off first
   SetActiveVC(guVCMain); VCSetVisible(False);
   SetActiveVC(guVCDebugMessages); VCSetVisible(False);
   SetActiveVC(guVCDebugWindows); VCSetVisible(False);
   SetActiveVC(guVCStarsAnimation); VCSetVisible(False);
   //f7 key, cycle 0=all off, 
   // 0=main background (VCMain)
   // 1=vcdebugmessages, 
   // 2=vcdebugwindows, 
   // 3=stars animation;
   //Inc(guVCDebugHasFocus);
   If guVCDebugHasFocus>cnMAXVCDebugHasFocus Then
   Begin
     guVCDebugHasFocus:=0;
   End; 
   Case guVCDebugHasFocus Of
   0:Begin SetActiveVC(guVCMain); VCSetVisible(True); End;
   1:Begin SetActiveVC(guVCDebugMessages); VCSetVisible(True);End;
   2:Begin SetActiveVC(guVCDebugWindows); VCSetVisible(True);End;
   3:Begin SetActiveVC(guVCStarsAnimation); VCSetVisible(True); end;
   End;//case
   grGfxOps.bUpdateConsole:=true;
 end;
//=============================================================================



//=============================================================================
Function WINControlPanelMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
    //---
    Procedure DisplayMsg;
    //---
    Var sa: AnsiString;
    Begin
      exit;
      Case p_rSageMsg.uMsg Of
      MSG_IDLE: sa:='MSG_IDLE';
      MSG_FIRSTCALL: sa:='MSG_FIRSTCALL';
      MSG_UNHANDLEDKEYPRESS: sa:='MSG_UNHANDLEDKEYPRESS';
      MSG_UNHANDLEDMOUSE: sa:='MSG_UNHANDLEDMOUSE';
      MSG_MENU: sa:='MSG_MENU';
      MSG_SHUTDOWN: sa:='MSG_SHUTDOWN';
      MSG_CLOSE: sa:='MSG_CLOSE';
      MSG_DESTROY: sa:='MSG_DESTROY';
      MSG_BUTTONDOWN: sa:='MSG_BUTTONDOWN';
      MSG_LOSTFOCUS: sa:='MSG_LOSTFOCUS';
      MSG_GOTFOCUS: sa:='MSG_GOTFOCUS';
      MSG_CTLGOTFOCUS: sa:='MSG_CTLGOTFOCUS';
      MSG_CTLLOSTFOCUS: sa:='MSG_CTLLOSTFOCUS';
      MSG_WINDOWSTATE: sa:='MSG_WINDOWSTATE';
      MSG_WINDOWMOVE: sa:='MSG_WINDOWMOVE';
      MSG_WINDOWRESIZE: sa:='MSG_WINDOWRESIZE';
      MSG_CTLSCROLLUP: sa:='MSG_CTLSCROLLUP';
      MSG_CTLSCROLLDOWN: sa:='MSG_CTLSCROLLDOWN';
      MSG_CTLSCROLLLEFT: sa:='MSG_CTLSCROLLLEFT';
      MSG_CTLSCROLLRIGHT: sa:='MSG_CTLSCROLLRIGHT';
      MSG_CHECKBOX: sa:='MSG_CHECKBOX';
      MSG_LISTBOXMOVE: sa:='MSG_LISTBOXMOVE';
      MSG_LISTBOXCLICK: sa:='MSG_LISTBOXCLICK';
      MSG_LISTBOXKEYPRESS: sa:='MSG_LISTBOXKEYPRESS';
      MSG_PAINTWINDOW: sa:='MSG_PAINTWINDOW';
      MSG_SHOWWINDOW: sa:='MSG_SHOWWINDOW';
      MSG_CTLKEYPRESS: sa:='MSG_CTLKEYPRESS';
      MSG_WINPAINTVCB4CTL: sa:='MSG_WINPAINTVCB4CTL';
      MSG_WINPAINTVCAFTERCTL: sa:='MSG_WINPAINTVCAFTERCTL';
      Else sa:='Not Sure';
      End;//case
      
      SetActiveVC(guVCStatusBar);
      VCWriteXY(13,1,saFixedLength(sa,1,20));
      VCWrite(' P1:' + saFixedLength(inttostr(p_rSageMsg.uParam1),1,8));
      VCWrite(' P2:' + saFixedLength(inttostr(p_rSageMsg.uParam2),1,8));
      VCWrite(' ObjType:' + saFixedLength(inttostr(p_rSageMsg.uObjType),1,8));
      VCWrite(' uMsg:' + saFixedLength(inttostr(p_rSageMsg.uMsg),1,8));
      //UpdateConsole; Yield(1000); grGFXOps.bUpdateConsole:=True;
    End;
    //---



Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINControlPanelMsgHandler',SourceFile);
{$ENDIF}
  DisplayMsg;
  Case p_rSageMsg.uMsg Of
  MSG_IDLE:;
  MSG_FIRSTCALL:;
  MSG_UNHANDLEDKEYPRESS:;
  MSG_UNHANDLEDMOUSE:;
  MSG_MENU:;
  MSG_SHUTDOWN:;
  MSG_CLOSE:;
  MSG_DESTROY:;
  MSG_BUTTONDOWN: begin
    // 0=main background (VCMain)
    // 1=vcdebugmessages, 
    // 2=vcdebugwindows, 
    // 3=stars animation;
    if p_rSageMsg.uParam2=WINControlPanel_ctlButtonMainBG.CTLUID then
    begin
      guVCDebugHasFocus:=0;SetBackground;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlButtonMsgBG.CTLUID then
    begin
      guVCDebugHasFocus:=1;SetBackground;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlButtonDbugWinBG.CTLUID then
    begin
      guVCDebugHasFocus:=2;SetBackground;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlButtonStarsBG.CTLUID then
    begin
      guVCDebugHasFocus:=3;SetBackground;
    end;
  end;
  MSG_LOSTFOCUS:;
  MSG_GOTFOCUS:;
  MSG_CTLGOTFOCUS:;
  MSG_CTLLOSTFOCUS:;
  MSG_WINDOWSTATE:;
  MSG_WINDOWMOVE:;
  MSG_WINDOWRESIZE:;
  MSG_CTLSCROLLUP:;
  MSG_CTLSCROLLDOWN:;
  MSG_CTLSCROLLLEFT:;
  MSG_CTLSCROLLRIGHT:;
  MSG_CHECKBOX: begin
    if p_rSageMsg.uParam2=WINControlPanel_ctlLogo.CTLUID then
    begin
      WINLOGO.Visible:=WINControlPanel_ctlLogo.Checked;
      if WINLOGO.Visible then WINLOGO.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlKeyboard.CTLUID then
    begin
      WinDebugKeyBoard.Visible:=WINControlPanel_ctlKeyboard.Checked;
      if WinDebugKeyBoard.Visible then WinDebugKeyBoard.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlKeypress.CTLUID then
    begin
      WinDebugKeyPress.Visible:=WINControlPanel_ctlKeypress.Checked;
      if WinDebugKeyPress.Visible then WinDebugKeyPress.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlMQ.CTLUID then
    begin
      WinDebugMQ.Visible:=WINControlPanel_ctlMQ.Checked;
      if WinDebugMQ.Visible then WinDebugMQ.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlStatus.CTLUID then
    begin
      WinDebugStatusBar.Visible:=WINControlPanel_ctlStatus.Checked;
      if WinDebugStatusBar.Visible then WinDebugStatusBar.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlMouse.CTLUID then
    begin
      windebugmouse.Visible:=WINControlPanel_ctlMouse.Checked;
      if windebugmouse.visible then windebugmouse.setfocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlObjects.CTLUID then
    begin
      windebugObjectsXXDL.visible:=WINControlPanel_ctlObjects.checked;
      if windebugObjectsXXDL.visible then windebugObjectsXXDL.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlMenu.CTLUID then
    begin
      windebugmenu.visible:=WINControlPanel_ctlMenu.Checked;
      if windebugmenu.visible then windebugmenu.SetFocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlPopUp.CTLUID then
    begin
      windebugpopup.visible:=WINControlPanel_ctlPopUp.checked;
      if windebugpopup.visible then windebugpopup.setfocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlKey32.CTLUID then
    begin
      windebugkeypress32.visible:=WINControlPanel_ctlKey32.checked;
      if windebugkeypress32.visible then windebugkeypress32.setfocus;
    end;
    if p_rSageMsg.uParam2=WINControlPanel_ctlControls.CTLUID then
    begin
      WinDebugCtl.visible:=WINControlPanel_ctlControls.checked;
      if WinDebugCtl.visible then WinDebugCtl.setfocus;
    end;
  end;  
  MSG_LISTBOXMOVE:;
  MSG_LISTBOXCLICK:;
  MSG_LISTBOXKEYPRESS:;
  MSG_PAINTWINDOW:;
  MSG_SHOWWINDOW:;
  MSG_CTLKEYPRESS:;
  MSG_WINPAINTVCB4CTL:;
  MSG_WINPAINTVCAFTERCTL:;
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINControlPanelMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
Function WINDebugObjectsXXDLMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINDebugObjectsXXDLMsgHandler',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      With grObjectsXXDLStats Do  Begin
        WVCDataPairInt(3, 3,36,10,'# Of Objects:',iNumberOfObjects);
        WVCDataPairInt(3, 4,36,10,'# Of Windows (Use 1 VC Each):',iNumberOfWindows);
        WVCDataPairInt(3, 5,36,10,'# Of Virtual Consoles:',iNumberOfVirtualConsoles);
        WVCDataPairInt(3, 6,36,10,'# Of Controls:',iNumberOfControls);
        WVCDataPairInt(3, 7,36,10,'# Of Other:',iNumberOfUnknown);
        WVCDataPairInt(3, 8,36,10,'# Of OBJ_NONE:',iNumberOfObj_NONE);
        VCSetFGC(lightgray);
        VCWriteXY(3,9,'Note: VC=Virtual Console List. 1 is Reserved.');
        WVCDataPairInt(3,10,36,10,'# Of Virtual Consoles in VC:',VC.ListCount);
      End;
      
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINDebugObjectsXXDLMsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugMenuMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
var 
  iBookMarkMenu: longint;
  iYPos: integer;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINDebugMenu',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      iBookMarkMenu:=gMB.N;
      WVCDataPairStr(3, 3,36,10,'gbMenuEnabled:',saTrueFalse(gbMenuEnabled));
      WVCDataPairStr(3, 4,36,10,'gbMenuVisible:',saTrueFalse(gbMenuVisible));
      WVCDataPairStr(3, 5,36,10,'gbMenuDown:',saTrueFalse(gbMenuDown));
      WVCDataPairInt(3, 6,36,10,'gi4MenuHeight:',gi4MenuHeight);
      WVCDataPairInt(3, 7,36,10,'gMB.ListCount:',gMB.ListCount);              
      WVCDataPairInt(3, 7,36,10,'gMB.N:',gMB.N);              
      iYPos:=9;
      if gMB.MoveFirst then
      begin
        repeat
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_UID:',gMB.Item_UID);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_i8User:',gMB.Item_i8User);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(1):',gMB.Item_ID1);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(2):',gMB.Item_ID2);iYPos+=1;
          //x1      Id[3]:=VCGetPenx;                 // word 00 00 00 FF
          //y1      id[3]:=id[3] + (VcGetPenY shl 8); // word 00 00 FF 00
          //x2      id[3]:=id[3] + (VcGetPenX shl 16);// word 00 FF 00 00
          //y2      id[3]:=id[3] + (VcGetPenY shl 24);// word FF 00 00 00
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(3)x1:',gMB.Item_ID3 and 255);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(3)y1:',(gMB.Item_ID3 shr 8) and 255);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(3)x2:',(gMB.Item_ID3 shr 16) and 255);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(3)y2:',(gMB.Item_ID3 shr 24) and 255);iYPos+=1;
          WVCDataPairInt(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_ID(4):',gMB.Item_ID4);iYPos+=1;
          WVCDataPairStr(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_saName:',gMB.Item_saName);iYPos+=1;
          WVCDataPairStr(3, iYPos,36,10,'MB('+inttostr(gMB.N)+').Item_saDesc:',gMB.Item_saDesc);iYPos+=1;
        until not gMB.MoveNext;
      end;
      gMB.FoundNth(iBookMarkMenu);
    End
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINDebugMenu',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WINDebugPopUpMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
var 
//  iBookMarkMenu: longint;
  iBookMarkPopUp: longint;
  iYPos: integer;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WINDebugPopUp',SourceFile);
{$ENDIF}
  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      if gbMenuDown then
      begin
        //iBookMarkMenu:=gMB.N;
        if JFC_XXDL(gMB.Item_lpPtr).ListCount=0 then
        begin
          VCWriteXY(3,3,'No Items In Popup '+inttostr(gMB.N));
        end
        else
        begin
          iBookMarkPopUp:=JFC_XXDL(gMB.Item_lpPtr).N;
          WVCDataPairInt(3, 3,36,10,'gMB.N:',gMB.N);              
          iYPos:=5;
          if JFC_XXDL(gMB.Item_lpPtr).MoveFirst then
          begin
            repeat
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_UID:',JFC_XXDL(gMB.Item_lpPtr).Item_UID);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_i8User:',JFC_XXDL(gMB.Item_lpPtr).Item_i8User);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(1):',JFC_XXDL(gMB.Item_lpPtr).Item_ID1);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(2):',JFC_XXDL(gMB.Item_lpPtr).Item_ID2);iYPos+=1;
              //x1      Id[3]:=VCGetPenx;                 // word 00 00 00 FF
              //y1      id[3]:=id[3] + (VcGetPenY shl 8); // word 00 00 FF 00
              //x2      id[3]:=id[3] + (VcGetPenX shl 16);// word 00 FF 00 00
              //y2      id[3]:=id[3] + (VcGetPenY shl 24);// word FF 00 00 00
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(3)x1:',JFC_XXDL(gMB.Item_lpPtr).Item_ID3 and 255);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(3)y1:',(JFC_XXDL(gMB.Item_lpPtr).Item_ID3 shr 8) and 255);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(3)x2:',(JFC_XXDL(gMB.Item_lpPtr).Item_ID3 shr 16) and 255);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(3)y2:',(JFC_XXDL(gMB.Item_lpPtr).Item_ID3 shr 24) and 255);iYPos+=1;
              WVCDataPairInt(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_ID(4):',JFC_XXDL(gMB.Item_lpPtr).Item_ID4);iYPos+=1;
              WVCDataPairStr(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_saName:',JFC_XXDL(gMB.Item_lpPtr).Item_saName);iYPos+=1;
              WVCDataPairStr(3, iYPos,36,10,'Pop Item('+inttostr(JFC_XXDL(gMB.Item_lpPtr).N)+').Item_saDesc:',JFC_XXDL(gMB.Item_lpPtr).Item_saDesc);iYPos+=1;
            until not JFC_XXDL(gMB.Item_lpPtr).MoveNext;
          end;
          JFC_XXDL(gMB.Item_lpPtr).FoundNth(iBookMarkPopUp);
        end;
      end
      else
      begin
        VCWriteXY(3,3,'No Popup Visible');
      end;
    End;
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WINDebugPopup',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function WinDebugKeypress32MsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
var 
  iYPos: integer;
Begin
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinDebugKeypress32MsgHandler',SourceFile);
{$ENDIF}

  // code snip that does the encoding 
  //If rLKey.bShiftPressed Then u4Key+=b00;
  //If rLKey.bCntlPressed Then  u4Key+=b01;
  //If rLKey.bAltPressed Then   u4Key+=b02;
  //u4Key:=u4Key shl 8;
  //u4Key+=Ord(rLKey.ch);
  //u4Key:=u4Key+(LongWord(rLKey.u2KeyCode) shl LongWord(16));

  Case p_rSageMsg.uMsg Of
  MSG_WINPAINTVCb4CTL:
    Begin
      WVCDataPairInt(3, 3,20,10,'Most recent Keypress32:',gu4Key);              
      iYPos:=4;
      WVCDataPairStr(3, iYPos,20,10,'SHIFT',saTruefalse(bKeyIDShiftPressed(gu4Key)));iYPos+=1;
      WVCDataPairStr(3, iYPos,20,10,'CNTL',saTruefalse(bKeyIDCntlPressed(gu4Key)));iYPos+=1;
      WVCDataPairStr(3, iYPos,20,10,'ALT',saTruefalse(bKeyIDAltPressed(gu4Key)));iYPos+=1;
      WVCDataPairStr(3, iYPos,20,10,'KeyCode',inttostr(wKeyIDKeyCode(gu4Key)));iYPos+=1;
      WVCDataPairStr(3, iYPos,20,10,'Char',' '+chKeyID(gu4Key));iYPos+=1;
      WVCDataPairStr(3, iYPos,20,10,'Ascii', inttostr(byte(chKeyID(gu4Key))));iYPos+=1;
    End;
  End;//case
  
  Result:=0;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinDebugKeypress32MsgHandler',SourceFile);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
function WinTestMsgHandler(Var p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
var iYPos: longint;
begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('WinTestMsgHandler',SOURCEFILE);
  {$ENDIF}

  Result:=0;
  //JLog(cnLog_Debug, 201003030309,msgtotext(p_rSageMSG),SOURCEFILE);
  Case p_rSageMSG.uMsg Of
  MSG_IDLE: ;
  MSG_FIRSTCALL:;
  MSG_UNHANDLEDKEYPRESS: begin
    case rLKey.ch of
    '1': begin
      MsgBox('MsgBox Caption','Message',MB_OK);
    end;
    '2': begin
      Inputbox('InputBox Caption','Default Data Passed to function',40,MB_OK);
    end;
    '3': begin
      {$IFDEF WIN32}
      FileBox('FileBox Caption','c:\','*.*',FB_GetFile);
      {$ELSE}
      FileBox('FileBox Caption','/','*.*',FB_GetFile);
      {$ENDIF}
    end;
    end;//switch
  end;  
  MSG_UNHANDLEDMOUSE:;
  MSG_MENU:;
  MSG_SHUTDOWN:;
  MSG_CLOSE:;
  MSG_DESTROY:;
  MSG_BUTTONDOWN:;
  MSG_LOSTFOCUS:;
  MSG_GOTFOCUS:;
  MSG_CTLGOTFOCUS:;
  MSG_CTLLOSTFOCUS:;
  MSG_WINDOWSTATE:;
  MSG_WINDOWMOVE:;
  MSG_WINDOWRESIZE:;
  MSG_CTLSCROLLUP:;
  MSG_CTLSCROLLDOWN:;
  MSG_CTLSCROLLLEFT:;
  MSG_CTLSCROLLRIGHT:;
  MSG_CHECKBOX:;
  MSG_LISTBOXMOVE:;
  MSG_LISTBOXCLICK:;
  MSG_LISTBOXKEYPRESS:;
  MSG_PAINTWINDOW:;
  MSG_SHOWWINDOW:;
  MSG_CTLKEYPRESS:;
  MSG_WINPAINTVCB4CTL: begin
    VCSetFGC(gu1ScreenFG);
    VCSetBGC(gu1ScreenBG);
    iYPos:=16;
    VCWriteXY(2,iYPos,'Press 1 = msgbox, 2 = inputbox, 3 = filebox. (only if key unhandled)');iYPos+=1;
    if((WinDebugCtl.C=nil)=false)then
    begin  
      VCWriteXY(2,iYPos,'C.N:'+inttostr(WinDebugCtl.C.N)+ ' '+ObjToText(WinDebugCtl.C.Item_ID1));iYPos+=1;//Note: WinDebugCtl.C.uObjType seems to be same thing as this field
      VCWriteXY(2,iYPos,'C.bEnabled:'+satrueFalse(WinDebugCtl.C.bEnabled));iYPos+=1;
      VCWrite(' C.bVisible:'+saTrueFalse(WinDebugCtl.C.bVisible));
      VCWrite(' C.bPrivate:'+saTrueFalse(WinDebugCtl.C.bPrivate));
      VCWrite(' C.lpOwner:'+inttostr(UINT(WinDebugCtl.C.lpOwner))+' ');
      VCWriteXY(2,iYPos,'C.bCanGetFocus:'+satrueFalse(WinDebugCtl.C.bCanGetFocus));iYPos+=1;
      VCWrite(' C.bRedraw:'+saTrueFalse(WinDebugCtl.C.bRedraw));
      VCWrite(' C.uOwnerObjType:'+inttostr(WinDebugCtl.C.uOwnerObjType)+' '+ObjToText(WinDebugCtl.C.uOwnerObjType)+' ');
      VCWriteXY(2,iYPos,'C.Item_UID:'+inttostr(WinDebugCtl.C.Item_UID));iYPos+=1;
      VCWrite(' C.Item_i8User:'+inttostr(WinDebugCtl.C.Item_i8User)+' ');
      VCWrite(' win.i4ControlWithFocusUID:'+inttostr(WinDebugCtl.i4ControlWithFocusUID)+'  ');
      Case WinDebugCtl.C.Item_ID1 Of
      OBJ_NONE               :;
      OBJ_VCMAIN             :;
      OBJ_VCSTATUSBAR        :;
      OBJ_MENUBAR            :;
      OBJ_MENUBARPOPUP       :;
      OBJ_WINDOW             :;
      OBJ_LABEL              :;  

      OBJ_VSCROLLBAR         :begin
        VCWriteXY(2,iYPos,'Height:'+inttostr( tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).Height));iYPos+=1;
        VCWrite(' MaxValue:'+inttostr( tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).MaxValue));
        VCWrite(' Value:'+inttostr( tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).Value));
        VCWrite(' CharUpArrow:'+tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).CharUpArrow+' ');
        VCWriteXY(2,iYPos,' CharDownArrow:'+tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).CharDownArrow);iYPos+=1;
        VCWrite(' CharMarker:'+tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).CharMarker);
        VCWrite(' CharSlide:'+tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).CharSlide);
        VCWrite(' SlideTextColor:'+inttostr(tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).SlideTextColor)+' ');
        VCWriteXY(2,iYPos,' SlideBackColor:'+inttostr(tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).SlideBackColor));iYPos+=1;
        VCWrite(' TextColor:'+inttostr(tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).TextColor));
        VCWrite(' BackColor:'+inttostr(tctlVScrollBar(WinDebugCtl.C.Item_lpPtr).BackColor)+' ');
      end;

      OBJ_HSCROLLBAR         :begin
        VCWriteXY(2,iYPos,'Width:'+inttostr( tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).Width));iYPos+=1;
        VCWrite(' MaxValue:'+inttostr( tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).MaxValue));
        VCWrite(' Value:'+inttostr( tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).Value));
        VCWrite(' SlideTextColor:'+inttostr(tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).SlideTextColor)+' ');
        VCWriteXY(2,iYPos,' SlideBackColor:'+inttostr(tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).SlideBackColor));iYPos+=1;
        VCWrite(' TextColor:'+inttostr(tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).TextColor));
        VCWrite(' BackColor:'+inttostr(tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).BackColor));
        VCWrite(' Value:'+inttostr( tctlHScrollBar(WinDebugCtl.C.Item_lpPtr).Value)+' ');
      end;

      OBJ_PROGRESSBAR        : begin
        VCWriteXY(2,iYPos,'Width:'+inttostr( tctlProgressBar(WinDebugCtl.C.Item_lpPtr).Width));iYPos+=1;
        VCWrite(' CharSlide:'+tctlProgressBar(WinDebugCtl.C.Item_lpPtr).CharSlide);
        VCWrite(' CharMarker:'+tctlProgressBar(WinDebugCtl.C.Item_lpPtr).CharMarker);
        VCWrite(' SlideTextColor:'+inttostr(tctlProgressBar(WinDebugCtl.C.Item_lpPtr).SlideTextColor)+' ');
        VCWriteXY(2,iYPos,' SlideBackColor:'+inttostr(tctlProgressBar(WinDebugCtl.C.Item_lpPtr).SlideBackColor));iYPos+=1;
        VCWrite(' TextColor:'+inttostr(tctlProgressBar(WinDebugCtl.C.Item_lpPtr).TextColor));
        VCWrite(' BackColor:'+inttostr(tctlProgressBar(WinDebugCtl.C.Item_lpPtr).BackColor));
        VCWrite(' MaxValue:'+inttostr( tctlProgressBar(WinDebugCtl.C.Item_lpPtr).MaxValue));
        VCWrite(' Value:'+inttostr( tctlProgressBar(WinDebugCtl.C.Item_lpPtr).Value)+' ');
      end;

      OBJ_INPUT              :begin
        VCWriteXY(2,iYPos,'Width:'+inttostr( tctlInput(WinDebugCtl.C.Item_lpPtr).Width));iYPos+=1;
        VCWrite(' SelStart:'+inttostr(tctlInput(WinDebugCtl.C.Item_lpPtr).SelStart));
        VCWrite(' SelLen:'+inttostr(tctlInput(WinDebugCtl.C.Item_lpPtr).SelLength));
        VCWrite(' CursorPos:'+inttostr(tctlInput(WinDebugCtl.C.Item_lpPtr).CursorPos)+' ');
        VCWriteXY(2,iYPos,'IsPassword:'+saTrueFalse( tctlInput(WinDebugCtl.C.Item_lpPtr).IsPassword));iYPos+=1;
        VCWrite(' MaxLength:'+inttostr(tctlInput(WinDebugCtl.C.Item_lpPtr).MaxLength)+' ');
        VCWriteXY(2,iYPos,'Data:'+tctlInput(WinDebugCtl.C.Item_lpPtr).Data+' ');iYPos+=1;
      end;
      
      OBJ_BUTTON             :begin
      VCWriteXY(2,iYPos,'Width:'+inttostr( tctlButton(WinDebugCtl.C.Item_lpPtr).Width));iYPos+=1;
      VCWrite(' Sticky:'+saTrueFalse( tctlButton(WinDebugCtl.C.Item_lpPtr).Sticky));
      VCWrite(' HotKeyTextColor:'+inttostr(tctlButton(WinDebugCtl.C.Item_lpPtr).HotKeyTextColor));
      VCWrite(' FocusTextColor:'+inttostr(tctlButton(WinDebugCtl.C.Item_lpPtr).FocusTextColor)+' ');
      VCWriteXY(2,iYPos,'FocusBackColor:'+inttostr( tctlButton(WinDebugCtl.C.Item_lpPtr).FocusBackColor));iYPos+=1;
      VCWrite(' TextColor:'+inttostr(tctlButton(WinDebugCtl.C.Item_lpPtr).TextColor));
      VCWrite(' BackColor:'+inttostr(tctlButton(WinDebugCtl.C.Item_lpPtr).BackColor));
      VCWrite(' DisabledTextColor:'+inttostr( tctlButton(WinDebugCtl.C.Item_lpPtr).DisabledTextColor)+' '); 
      VCWriteXY(2,iYPos,'Caption:'+tctlButton(WinDebugCtl.C.Item_lpPtr).Caption+' ');iYPos+=1;
      end;
      
      OBJ_CHECKBOX           :begin
        VCWriteXY(2,iYPos,'Width:'+inttostr( tctlCheckBox(WinDebugCtl.C.Item_lpPtr).Width));iYPos+=1;
        VCWrite(' TextColor:'+inttostr(tctlCheckBox(WinDebugCtl.C.Item_lpPtr).TextColor));
        VCWrite(' BackColor:'+inttostr(tctlCheckBox(WinDebugCtl.C.Item_lpPtr).BackColor));
        VCWrite(' CheckTextColor:'+inttostr(tctlCheckBox(WinDebugCtl.C.Item_lpPtr).CheckTextColor)+' ');
        VCWriteXY(2,iYPos,'CheckBackColor:'+inttostr( tctlCheckBox(WinDebugCtl.C.Item_lpPtr).CheckBackColor));iYPos+=1;
        VCWrite(' Checked:'+saTrueFalse(tctlCheckBox(WinDebugCtl.C.Item_lpPtr).Checked));
        VCWrite(' RadioStyle:'+saTrueFalse(tctlCheckBox(WinDebugCtl.C.Item_lpPtr).RadioStyle)+' ');
        VCWriteXY(2,iYPos,'Caption:'+tctlCheckBox(WinDebugCtl.C.Item_lpPtr).Caption+' ');iYPos+=1;
      end;
      
      OBJ_LISTBOX            :begin
        VCWriteXY(2,iYPos,'Width:'+inttostr( tctlListBox(WinDebugCtl.C.Item_lpPtr).Width));    iYPos+=1;
        VCWrite(' Height:'+inttostr(tctlListBox(WinDebugCtl.C.Item_lpPtr).Height));
        VCWrite(' DataWidth:'+inttostr(tctlListBox(WinDebugCtl.C.Item_lpPtr).DataWidth));
        VCWrite(' TextColor:'+inttostr(tctlListBox(WinDebugCtl.C.Item_lpPtr).TextColor)+' ');
        VCWriteXY(2,iYPos,'BackColor:'+inttostr( tctlListBox(WinDebugCtl.C.Item_lpPtr).BackColor));iYPos+=1;    
        VCWrite(' CurrentItem:'+inttostr(tctlListBox(WinDebugCtl.C.Item_lpPtr).CurrentItem));
        VCWrite(' Selected:'+saTrueFalse(tctlListBox(WinDebugCtl.C.Item_lpPtr).Selected));
        VCWrite(' ListCount:'+inttostr(tctlListBox(WinDebugCtl.C.Item_lpPtr).Listcount)+' ');
        VCWriteXY(2,iYPos,'ShowCheckMarks:'+saTrueFalse( tctlListBox(WinDebugCtl.C.Item_lpPtr).ShowCheckMarks)+' ');iYPos+=1;
        VCWriteXY(2,iYPos,'ItemText:'+tctlListBox(WinDebugCtl.C.Item_lpPtr).ItemText+' ');iYPos+=1;
      end;
      
      OBJ_TREE               :;
      OBJ_VCDEBUGMESSAGES    :;
      OBJ_VCDEBUGKEYPRESS    :;
      OBJ_VCDEBUGKEYBOARD    :;
      OBJ_VCDEBUGMOUSE       :;
      OBJ_VCDEBUGMQ          :;
      OBJ_VCDEBUGSTATUSBAR   :;
      OBJ_VCDEBUGWINDOWS     :;
      OBJ_VCSTARANIMATION    :;
      end;//case
    end;
  end;
  MSG_WINPAINTVCAFTERCTL:;
  end;//switch
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('WinTestMsgHandler',SOURCEFILE);
  {$ENDIF}
end;
//=============================================================================

//=============================================================================
Procedure CreateIntegratedUIObjects;
//=============================================================================
var t: longint;
    //rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('CreateIntegratedUIObjects',SOURCEFILE);
  {$ENDIF}
    
  // BEGIN ------------------------------------------- Set Up Schema
  {$IFDEF LINUX}
    //If gsaTerm='xterm' Then
    //Begin
    //  SetGfxSchema(2);
    //  SetColorSchema(2);
    //End
    //Else
    Begin 
      SetGfxSchema(1);
      SetColorSchema(1);
    End;
  {$ELSE}
    SetGFXSchema(1);
    SetColorSchema(1);
  {$ENDIF}
  // END ------------------------------------------- Set Up Schema


  // BEGIN ------------------------------------------- Create Background Consoles
  guVCMain:=uNewVCObject('guVCMain',giConsoleWidth, giConsoleHeight, OBJ_VCMAIN, nil);
  guVCDebugMessages:=uNewVCObject('guVCDebugMessages',giConsoleWidth, giconsoleheight, OBJ_VCDEBUGMESSAGES, nil);VCSetVisible(False);
  VCSetXY(1,1);
    
  guVCDebugWindows:=uNewVCObject('guVCDebugWindows',giConsoleWidth, giconsoleheight, OBJ_VCDEBUGWINDOWS, nil);VCSetVisible(False);
  VCSetXY(1,1);
    
  guVCStarsAnimation:=uNewVCObject('guVCStarsAnimation',giConsoleWidth, giconsoleheight, OBJ_VCSTARANIMATION, nil);VCSetVisible(True);
  VCSetXY(1,1);
  InitStars(guVCStarsAnimation);
  // END ------------------------------------------- Create Background Consoles
    
  //guVCDebugKeyPress:=uNewVCObject(46, 12, OBJ_VCDEBUGKEYPRESS, nil);VCSetVisible(False);
  //VCSetXY(2,giConsoleHeight-20);
  //guVCDebugMouse:=uNewVCObject(31,9, OBJ_VCDEBUGMOUSE, nil);VCSetVisible(False);
  //VCSetXY(49,giConsoleHeight-20);    
  //guVCDebugMQ:=uNewVCObject(31, 2, OBJ_VCDEBUGMQ, nil);VCSetVisible(False);
  //VCSetXY(49,giConsoleHeight-10);    
  //guVCDebugStatusBar:=uNewVCObject(28, 8, OBJ_VCDEBUGSTATUSBAR, nil);VCSetVisible(False);
  //VCSetXY(2,giConsoleHeight-36);    


  // BEGIN ------------------------------------------- guVCMain Background Setup
  SetActiveVC(guVCMain);
  VCSetPenY(VCGetCenterY(1));
  VCSetCursorType(crHidden); 
  VCSetFGC(Blue);  
  VCSetBGC(black);
  VCClear;
  VCFillBoxCtr(VCWidth, VCHeight,gchScreenBGChar);
  VCSetPenXY(1,iPlotCenter(VCHeight,1));
  VCWriteCtr(cs_Msg_Initializing);
  BringVCToTop(guVCMain);
  UpdateConsole;
  // END ------------------------------------------- guVCMain Background Setup

  
  // BEGIN ------------------------------------------- Menu Bar and Pop-Up Menu System
  gMB:=JFC_XXDL.create; // Menu Bar XXDL
  gbMenuEnabled:=false;
  gbMenuVisible:=false;
  
  //// Menu Bar create
  //TODO: when menu's become objects - change nil to Obj Ptr
  {$IFDEF MENURESIZE}
  //guVCMenuBar:=uNewVCObject(giConsoleWidth,1,OBJ_MENUBAR,nil);
  guVCMenuBar:=uNewVCObject('guVCMenuBar',giConsoleWidth,1,OBJ_MENUBAR,nil);
  {$ELSE}
  guVCMenuBar:=uNewVCObject('guVCMenuBar',giConsoleWidth,giConsoleHeight,OBJ_MENUBAR,nil);
  {$ENDIF}
  grVCInfo:=VCGetInfo;
  With grVCInfo Do Begin
    // Virtual Screen coords Relative to Real Video Screen-One Based
    //VX:=VX;  // (Default: 1)
    //VY:=VY;  // (Default: 1)                    
    
    // Height and Width of Virtual Screen
    //VW:=VW; // (No Default - You Must In NewVC Call)
    //VH:=VH; // (No Default - You Must In NewVC Call)
    
    // Pen Coords - One Based
    //VPX:=VPX; // (Default: 1)
    //VPY:=VPY; // (Default: 1)
  
    // Pen Foreground And Background Colors
    VFGC:=gu1ButtonFG; // (Default: Light Gray)
    VBGC:=gu1ButtonBG; // (Default: Black)
    
    // Toggles whether Writing Past the Width of the gVC makes the cursor
    // drop to the next line. Has no bearing on VCPut commands, just VCWrite stuff
    VWrap:=False; // (Default: True)
  
    // Tabsize - Only has effect when VCWrit'n with the pen
    //VTabSize:=VTabSize; // (Default: 8)
  
    // Toggles AutoCursor Tracking. The Cursor Follows the Pen when using VCWrite
    VTrackCursor:=False; //(Default: True)
  
    // Blinky  Coords - One Based
    //VCX:=VCX; // (Default: 1)
    //VCY:=VCY; // (Default: 1)
    // The Blinky Cursor Types: crUnderline, crHidden, crBlock, crHalfBlock
    VCursorType:=crHidden; // (Default:  crUnderline)
    
    // Toggles Auto Scroll - Which scrolls the gVC's contents up if while using
    // VCWrite commands you either wrote past the bottom right hand corner of the 
    // gVC (if VWrap is set to true) or if a Linefeed (Ascii #10) is encountered.
    VScroll:=False; // (Default: True)
  
    // Scrolling Region X,Y,gW,H (One Based)- MUST Be entirely within gVC.
    //VSX:=VSX; // (Default: 1)
    //VSY:=VSY; // (Default: 1)
    //VSW:=VSW; // (Default: VCWidth  -See VW Field of this record)
    //VSH:=VSH; // (Default: VCHeight -See VH Field of this record)
  
    // Toggles whether gVC is Hidden or not
    VVisible:=gbMenuVisible; // (Default: True)
  
    // Toggles whether characters in the gVC with Ascii Value Zero makes those
    // cells transparent or not. 
    VTransparency:=True; // (Default: False)
  
    // Toggles Ability to allow Characters of whatever is underneath gVC to show
    //VOpaqueCh:=VOpaqueCh; // (Default: True)
    // Toggles Ability to allow FG color of whatever is underneath gVC to show 
    //VOpaqueFG:=VOpaqueFG; // (Default: True)
    // Toggles Ability to allow BG color of whatever is underneath gVC to show 
    //VOpaqueBG:=VOpaqueBG;//  (Default: True)
  
    // Note: Having Transparency Set To TRUE while All cell's characters set
    //       to ASCII ZERO will render the gVC Invisible - Not hidden.
    //       The same is true for Setting All VCOpaque flags to False.
    //       These are not the most efficient ways to hide a gVC. Just set
    //       to hidden for optimal performance.
  End;
  vcsetinfo(grVCInfo); 
  
  
  //// Menu PopUp create
  guVCMenuPopUp:=uNewVCObject('guVCMenuPopUp',giConsoleWidth div 2,giConsoleHeight div 2,OBJ_MENUBARPOPUP,nil);
  gbMenuDown:=false; 
  grVCInfo.VVisible:=gbMenuDown;
  vcsetinfo(grVCInfo);// use same infor as the menu bar for the VC init
  // END ------------------------------------------- Menu Bar and Pop-Up Menu System
    
  

  // BEGIN ------------------------------------------- Accelerator Key Collection - Not Fully implemented 
  gAKey:=JFC_XXDL.create;
  // END   ------------------------------------------- Accelerator Key Collection - Not Fully implemented 
  
  // BEGIN ------------------------------------------- Help Window
  gRCW.saCaption:='Help';//
  grCW.saName:='HelpWindow';
  gRCW.X:=iPlotCenter(giConsoleWidth,64);
  gRCW.Y:=3;
  gRCW.Width:=70;
  gRCW.Height:= 20;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MAXIMIZED;
  gRCW.bCaption:=true;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=true;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=true;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINHelpmsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINHELP:=Twindow.create(gRCW);
  
  WinHelp_ctlLabel:=tCtlLabel.Create(WinHelp);
  WinHelp_ctlLabel.X:=2;
  WinHelp_ctlLabel.Y:=2;
  WinHelp_ctlLabel.Width:=WinHelp.Width-2;
  WinHelp_ctlLabel.Height:=2;
  {$IFDEF WIN32}
  WinHelp_ctlLabel.Caption:='Navigate through this HELP using your mouse or the arrow keys. User the ENTER key or Left-Click your mouse to follow links.';
  {$ELSE}
  WinHelp_ctlLabel.Caption:='Navigate through this HELP using your arrows. User the ENTER key to follow links.';
  {$ENDIF}
  
  WinHelp_ctlLabel.Enabled:=True;
  WinHelp_ctlLabel.Visible:=True;

  WinHelp_ctlListbox:=tctlListBox.create(WinHelp);  
  WinHelp_ctlListbox.X:=2;
  WinHelp_ctlListbox.Y:=4;
  WinHelp_ctlListbox.Width:=WinHelp.Width-3;
  WinHelp_ctlListbox.Height:=WinHelp.height-WinHelp_ctlLabel.Height-3;
  WinHelp_ctlListbox.DataWidth:=128;// just shy of the max 132 width for ANY console
  WinHelp_ctlListbox.ShowCheckMarks:=True;
  WinHelp.i4ControlWithFocusUID:=WinHelp_ctlListbox.CTLUID;
  
  WinHelpTopicXDL:=JFC_XDL.Create;
  //WinHelpTopicXDL.AppendItem_XDL(p_lpPtr: pointer; p_saName, p_saValue, p_saDesc: AnsiString; p_i8User: Int64): Boolean;
  WinHelpTopicXDL.AppendItem_XDL(nil,'[HOME]','Help','',0);
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'       _________ _______  _______  ______  _______'                        ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'      /___  ___// _____/ / _____/ / __  / / _____/'                        ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         / /   / /__    / / ___  / /_/ / / /____'                          ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'        / /   / ____/  / / /  / / __  / /____  /'                          ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'   ____/ /   / /___   / /__/ / / / / / _____/ /'                           ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  /_____/   /______/ /______/ /_/ /_/ /______/'                            ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'                Under the Hood'                                            ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,''                                                                          ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'First.. Here''s how to navigate with this SageUI console user interface!' ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,''                                                                          ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'The Status bar at the bottom on the screen has some useful keypresses to ' ,'',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'to get you started. To navigate this help you can use your mouse and/or  ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'the [up] and [down] arrow keys and pressing [ENTER] on the links that are','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'marked with a check or an X. The links are different colors on color ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'consoles.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'So, highlight the desired link below to learn more.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'Press [F1] when this window has focus to close the help.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'[How to get around]','[How to get around]',0);
  
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,'[How to get around]','[Back]','[HOME]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'How To Get Around','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [TAB] - Changes Focus from one field or control within the current','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          window to the next field or control.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [SHIFT]+[TAB] - Changes Focus from one field or control within the','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'                  currentwindow the the PREVIOUS field or control.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F1]  - Toggles this help system.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F2]  - Switches to Previous Window in the SageUI Window List','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F3]  - Switches to the Next Window in the SageUI Window List','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F4]  - Closes Current Window. If window doesn''t has a close button ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          then it will be minimized and the next window in the list will','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          get focus. Hitting it repetitively is a fast way to empty the ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          screen.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F5]  - Cycles the current window through its available window states.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          Usually there are three: Maximized, Normal, and Minimized.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F6]  - Toggles the Menu. You can navigate through the menu using the ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          arrows or the mouse. You can also type the "hot keys" to jump','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          to a particular menu item. Pressing [ENTER] in the menu ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          selects the highlighted menu item.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F7]  - Toggles the Control Panel. The control panel allows you to change ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          the background theme for this application and toggle built in ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          SageUI diagnostic windows as well as turn off the splash window.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'  [F8]  - Immediately shuts down this application unless the Screen Saver','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'          has come on.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                  ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'[Resizing Windows]','[Resizing Windows]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'[Moving Windows]','[Moving Windows]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'[Keyboard Reference]','[Keyboard Reference]',0);
  
  
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,'[Resizing Windows]','[Back]','[How to get around]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Resizing Windows','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'First, you can only resize windows with resiable frames; additionally','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'the window has to be in the NORMAL State. (Meaning not MINIMIZED or ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'MAXIMIZED.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'If your mouse works with this application, you just drag the window frame''s','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'edges using your left mouse button.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'If you want to accomplish the same thing with the keyboard:','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[T]  - Make Current Window Shorter','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[G]  - Make Current Window Taller','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[F]  - Make Current Window Narrower','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[H]  - Make Current Window Wider','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,'[Moving Windows]','[Back]','[How to get around]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Moving Windows','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'First, you can only move windows in either the NORMAL or MINIMIZED STATE.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'If your mouse works with this application, you just drag the TOP window','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'frame edge using your left mouse button.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'If you want to accomplish the same thing with the keyboard:','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[W]  - Move Current Window Up','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[S]  - Move Current Window Down','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[A]  - Move Current Window Left','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[D]  - Move Current Window Right','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,'[Keyboard Reference]','[Back]','[How to get around]',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Keyboard Reference','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [TAB] - Changes Focus from one field or control within the current window','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         to the next field or control.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[TAB] - Changes Focus from one field or control within the current','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'                 window the the PREVIOUS field or control.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Move Windows (Minimized or Normal States only)','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[W]  - Move Current Window Up','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[S]  - Move Current Window Down','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[A]  - Move Current Window Left','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[D]  - Move Current Window Right','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Adjust window sizes (Windows in NORMAL state; Not Maximized or Minimized','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[T]  - Make Current Window Shorter','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[G]  - Make Current Window Taller','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[F]  - Make Current Window Narrower','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ALT]+[H]  - Make Current Window Wider','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F1] - Toggle Help system window you''re reading now.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Switch Windows','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F2] or [CNTL]+[SHIFT]+[TAB] - Move to Previous Window in the SageUI','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'                                Window List ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F3] or [CTNL]+[TAB] - Move to Next Window in SageUI Window List','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Close Current Window','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F4] - Closes Current Window if window has a close button.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Change Window State','',0);
  //                                                      123456789012345678901234567890123456789012345678901234567890123456789012345                 
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' If your mouse works, there are buttons on the top right of windows that','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' allow you to maximize, minimize, and restore to normal window states','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' with a click. This is usually pretty straight forward. X = Close Window.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' Note that not all windows have all the buttons; depends on the window.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F5]  - Cycles the current window through its available window states.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         Usually there are three: Maximized, Normal, and Minimized.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F6]  - Toggles the Menu. You can navigate through the menu using the ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         arrows or the mouse. You can also type the highlighted "hot keys"','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         to jump to a particular menu item. Pressing [ENTER] in the menu ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'         selects the highlighted menu item.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F7] - Opens Open Control Panel Window','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [F8]  - Immediately shuts down this application unless the Screen Saver','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'          has come on.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Controls, fields and widgets','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  This user interface has some different controls and widgets that allow ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  data to be presented and manipulated by you; the end user.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  In any given window, only the control or widget that currently has focus','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  will respond to the keyboard. Some controls do not get focus and the','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  keyboard doesn''t typically effect such controls. Controls can sometimes','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  be disabled preventing them from getting the focus. With that said, below','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  is a list of the different controls or widgets that can appear in this ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  user interface followed by the keypresses that can be used to interact','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  with them.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  You can experiment with the controls by opening the control panel and ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  selecting the check box for the "Controls" window. This "Controls" ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  window has the main controls used in the SageUI console user interface ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'  you are using right now.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
    
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Check Box Control','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SPACE] - Toggles a checkbox from being selected or not when it has','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'           focus. Clicking a checkbox with the left mouse button does','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'           the same thing.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ENTER] - Toggles a checkbox from being selected or not when it has','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'           focus. Clicking a checkbox with the left mouse button does','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'           the same thing.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Buttons','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SPACE] - Presses the button.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ENTER] - Presses the button.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'Input Boxes (Allow you to type text in them)','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[LEFT]  - Selects text to the left of the cursor.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[RIGHT] - Selects text to the right of the cursor.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[END]   - Selects all text from the cursor to the end of the text.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[HOME]  - Selects all text from the cursor to the first character.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [CNTL]+[INS]    - Copies text into THIS APPLICATION''S clipboard.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [SHIFT]+[INS]   - Pastes text from THIS APPLICATION''S clipboard into ','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'                   the current text box.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'ListBoxes (This Help is in a ListBox control)','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [HOME] - Jump to and hightlight first item in listbox.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [END]  - Jump to and highlight last item in listbox.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [UP]   - Move highlight up one item.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [DOWN] - Move highlight down one item.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [PGUP] - Move highlight up one page.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [PGDN] - Move highlight down one page.','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [LEFT] - Pan List to the left','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [RIGHT]- Pan list to the right','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,' [ENTER]- Select highlighted item','',0);
  WinHelpTopicXDL.AppendItem_XDL(nil,''                 ,'','',0);

  WinHelpLoadListBox('[HOME]');
  
  // END   ------------------------------------------- Help Window





  // BEGIN ------------------------------------------- Control Panel Window
  gRCW.saCaption:='Control Panel';//
  gRCW.saName:='ControlPanelWindow';//
  gRCW.X:=iPlotCenter(giConsoleWidth,64);
  gRCW.Y:=5;
  gRCW.Width:=64;
  gRCW.Height:= 19;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=true;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=true;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=true;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINControlPanelMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINControlPanel:=Twindow.create(gRCW);
  
  WINControlPanel_ctlLabel:=tctllabel.create(WINControlPanel);
  WINControlPanel_ctlLabel.X:=3;
  WINControlPanel_ctlLabel.Y:=3;
  WINControlPanel_ctlLabel.Width:=58;
  WINControlPanel_ctlLabel.Height:=2;
  WINControlPanel_ctlLabel.TextColor:=White;
  WINControlPanel_ctlLabel.BackColor:=Blue;
  WINControlPanel_ctlLabel.Caption:='Use the check boxes to toggle the Splash window and integrated trouble shooting windows for the user interface.';
  WINControlPanel_ctlLabel.Enabled:=True;
  WINControlPanel_ctlLabel.Visible:=true;
  
  WINControlPanel_ctlLogo:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlLogo.saCaption:='Splash';
  WINControlPanel_ctlLogo.X:=4;
  WINControlPanel_ctlLogo.Y:=6;
  WINControlPanel_ctlLogo.Width:=25;
  WINControlPanel_ctlLogo.Checked:=true;
  WINControlPanel_ctlLogo.RadioStyle:=false;
  
  WINControlPanel_ctlKeyboard:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlKeyboard.saCaption:='Keyboard';
  WINControlPanel_ctlKeyboard.X:=34;
  WINControlPanel_ctlKeyboard.Y:=6;
  WINControlPanel_ctlKeyboard.Width:=25;
  WINControlPanel_ctlKeyboard.RadioStyle:=false;

  WINControlPanel_ctlKeypress:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlKeypress.saCaption:='Keypress';
  WINControlPanel_ctlKeypress.X:=4;
  WINControlPanel_ctlKeypress.Y:=7;
  WINControlPanel_ctlKeypress.Width:=25;
  WINControlPanel_ctlKeypress.RadioStyle:=false;

  WINControlPanel_ctlMQ:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlMQ.saCaption:='Msg Queue';
  WINControlPanel_ctlMQ.X:=34;
  WINControlPanel_ctlMQ.Y:=7;
  WINControlPanel_ctlMQ.Width:=25;
  WINControlPanel_ctlMQ.RadioStyle:=false;

  WINControlPanel_ctlStatus:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlStatus.saCaption:='Status Bar';
  WINControlPanel_ctlStatus.X:=4;
  WINControlPanel_ctlStatus.Y:=8;
  WINControlPanel_ctlStatus.Width:=25;
  WINControlPanel_ctlStatus.RadioStyle:=false;

  WINControlPanel_ctlMouse:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlMouse.saCaption:='Mouse';
  WINControlPanel_ctlMouse.X:=34;
  WINControlPanel_ctlMouse.Y:=8;
  WINControlPanel_ctlMouse.Width:=25;
  WINControlPanel_ctlMouse.RadioStyle:=false;

  WINControlPanel_ctlObjects:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlObjects.saCaption:='Objects';
  WINControlPanel_ctlObjects.X:=4;
  WINControlPanel_ctlObjects.Y:=9;
  WINControlPanel_ctlObjects.Width:=25;
  WINControlPanel_ctlObjects.RadioStyle:=false;
  
  WINControlPanel_ctlMenu:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlMenu.saCaption:='Menu';
  WINControlPanel_ctlMenu.X:=34;
  WINControlPanel_ctlMenu.Y:=9;
  WINControlPanel_ctlMenu.Width:=25;
  WINControlPanel_ctlMenu.RadioStyle:=false;

  WINControlPanel_ctlPopUp:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlPopUp.saCaption:='Popup';
  WINControlPanel_ctlPopUp.X:=4;
  WINControlPanel_ctlPopUp.Y:=10;
  WINControlPanel_ctlPopUp.Width:=25;
  WINControlPanel_ctlPopUp.RadioStyle:=false;

  WINControlPanel_ctlKey32:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlKey32.saCaption:='Key32';
  WINControlPanel_ctlKey32.X:=34;
  WINControlPanel_ctlKey32.Y:=10;
  WINControlPanel_ctlKey32.Width:=25;
  WINControlPanel_ctlKey32.RadioStyle:=false;

  WINControlPanel_ctlControls:=tctlCheckBox.create(WINControlPanel);
  WINControlPanel_ctlControls.saCaption:='Controls';
  WINControlPanel_ctlControls.X:=4;
  WINControlPanel_ctlControls.Y:=11;
  WINControlPanel_ctlControls.Width:=25;
  WINControlPanel_ctlControls.RadioStyle:=false;


  WINControlPanel_ctlLabel2:=tctllabel.create(WINControlPanel);
  WINControlPanel_ctlLabel2.X:=3;
  WINControlPanel_ctlLabel2.Y:=13;
  WINControlPanel_ctlLabel2.Width:=58;
  WINControlPanel_ctlLabel2.Height:=2;
  WINControlPanel_ctlLabel2.TextColor:=White;
  WINControlPanel_ctlLabel2.BackColor:=Blue;
  WINControlPanel_ctlLabel2.Caption:='Use the buttons below to change the background of the application. Press F7 To Close This Window.';
  WINControlPanel_ctlLabel2.Enabled:=True;
  WINControlPanel_ctlLabel2.Visible:=true;
  
  
  
  
  WINControlPanel_ctlButtonMainBG:=tctlbutton.create(WINControlPanel);
  WINControlPanel_ctlButtonMainBG.X:=4;
  WINControlPanel_ctlButtonMainBG.Y:=16;
  WINControlPanel_ctlButtonMainBG.Width:=10;
  WINControlPanel_ctlButtonMainBG.Caption:='&Main';

  WINControlPanel_ctlButtonMsgBG:=tctlbutton.create(WINControlPanel);
  WINControlPanel_ctlButtonMsgBG.X:=17;
  WINControlPanel_ctlButtonMsgBG.Y:=16;
  WINControlPanel_ctlButtonMsgBG.Width:=10;
  WINControlPanel_ctlButtonMsgBG.Caption:='&Messages';

  WINControlPanel_ctlButtonDbugWinBG:=tctlbutton.create(WINControlPanel);
  WINControlPanel_ctlButtonDBugWinBG.X:=30;
  WINControlPanel_ctlButtonDBugWinBG.Y:=16;
  WINControlPanel_ctlButtonDBugWinBG.Width:=10;
  WINControlPanel_ctlButtonDBugWinBG.Caption:='&Debug';

  WINControlPanel_ctlButtonStarsBG:=tctlbutton.create(WINControlPanel);
  WINControlPanel_ctlButtonStarsBG.X:=45;
  WINControlPanel_ctlButtonStarsBG.Y:=16;
  WINControlPanel_ctlButtonStarsBG.Width:=10;
  WINControlPanel_ctlButtonStarsBG.Caption:='&Stars';
  // End ------------------------------------------- Control Panel Window








  // BEGIN ------------------------------------------- Debug Keypress Window
  gRCW.saName:='DebugKeypressWindow';
  gRCW.saCaption:='DBG KeyP - Debug Keypress';
  gRCW.X:=iPlotCenter(giConsoleWidth,68);
  gRCW.Y:=giConsoleHeight-15;
  gRCW.Width:=51;
  gRCW.Height:= 8;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugKeyPressMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugKeypress:=Twindow.create(gRCW);
  // END   ------------------------------------------- Debug Keypress Window
  

  // BEGIN ------------------------------------------- Debug Keyboard Codes Window
  gRCW.saName:='DebugKeyCodesWindow';
  gRCW.saCaption:='DBG KyC - Debug Keyboard Codes';
  gRCW.X:=iPlotCenter(giConsoleWidth,68);
  gRCW.Y:=3;
  gRCW.Width:=45;
  gRCW.Height:= 14;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugKeyBoardMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugKEYBOARD:=Twindow.create(gRCW);
  // END ------------------------------------------- Debug Keyboard Codes Window


  // BEGIN ------------------------------------------- Debug Mouse Window
  gRCW.saName:='DebugMouseWindow';
  gRCW.saCaption:='DBG Mse - Debug Mouse';
  gRCW.X:=3;
  gRCW.Y:=3;
  gRCW.Width:=38;
  gRCW.Height:= 11;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugMouseMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugMouse:=Twindow.create(gRCW);
  // END   ------------------------------------------- Debug Mouse Window

  // BEGIN ------------------------------------------- Debug Message Queue Window
  gRCW.saName:='DebugMessageQueueWindow';
  gRCW.saCaption:='DBG MQ - Debug Message Queue';
  gRCW.X:=50;
  gRCW.Y:=giConsoleHeight-10;
  gRCW.Width:=50;
  gRCW.Height:= 5;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=True;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugMQMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugMQ:=Twindow.create(gRCW);
  // END ------------------------------------------- Debug Message Queue Window

  // BEGIN ------------------------------------------- Debug Status Bar Window
  gRCW.saName:='DebugStatusBarWindow';
  gRCW.saCaption:='DBG SBar - Debug Status Bar';
  gRCW.X:=iPlotCenter(giConsoleWidth,68);
  gRCW.Y:=giConsoleHeight-10;
  gRCW.Width:=35;
  gRCW.Height:= 8;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugStatusBarMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugStatusBAr:=Twindow.create(gRCW);
  WINDebugStatusBAr:=WINDebugStatusBAr;//shutup compiler
  // END ------------------------------------------- Debug Status Bar Window

  // BEGIN ------------------------------------------- Debug Objects Window
  gRCW.saName:='DebugObjectsWindow';
  gRCW.saCaption:='DBG ObjectsXXDL';
  gRCW.X:=3;
  gRCW.Y:=2;
  gRCW.Width:=50;
  gRCW.Height:= 12;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugObjectsXXDLMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINDebugObjectsXXDL:=Twindow.create(gRCW);
  gbGetOBJECTSXXDLStatsEnabled:=True;// IMPORTANT: Don't SET to TRUE UNTIL This Window is instantiated.
  // END ------------------------------------------- Debug Objects Window
  
  
  // BEGIN ------------------------------------------- Debug Menu Window
  gRCW.saName:='DebugMenuWindow';
  gRCW.saCaption:='DBG Menu';
  gRCW.X:=13;
  gRCW.Y:=4;
  gRCW.Width:=70;
  gRCW.Height:= 20;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=true;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=true;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugMenuMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WinDebugMenu:=Twindow.create(gRCW);
  WinDebugMenu:=WinDebugMenu;//shutupcompiler
  // END ------------------------------------------- Debug Menu Window
  

  // BEGIN ------------------------------------------- Debug Popup Window
  gRCW.saName:='DebugPopupWindow';
  gRCW.saCaption:='DBG Popup';
  gRCW.X:=11;
  gRCW.Y:=4;
  gRCW.Width:=70;
  gRCW.Height:= 20;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=true;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=true;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINDebugPopUpMsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WinDebugPopUp:=Twindow.create(gRCW);
  WinDebugPopUp:=WinDebugPopUp;//shutup compiler
  // END  ------------------------------------------- Debug Popup Window
  
  
  gRCW.saName:='DebugKey32Window';
  gRCW.saCaption:='DBG Key32';
  gRCW.X:=3;
  gRCW.Y:=5;
  gRCW.Width:=34;
  gRCW.Height:= 12;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_MINIMIZED;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=true;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=true;
  gRCW.bVisible:=false;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WinDebugKeypress32MsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WinDebugKeypress32:=Twindow.create(gRCW);
  WinDebugKeypress32:=WinDebugKeypress32;//shutup compiler
  // END ------------------------------------------- Debug Key32 Window


  // BEGIN ------------------------------------------- Debug Controls Window 
  with grCW do begin 
    saName:='ControlsTestWindow';
    saCaption:='Controls - Test how the controls work here.';
    Width:=60;
    Height:=20;
    X:=iPlotCenter(giConsoleWidth,grCW.Width);
    Y:=iPlotCenter(giConsoleHeight,grCW.Height);
    bFrame:=True;
    WindowState:=WS_MINIMIZED;
    bCaption:=True;
    bMinimizeButton:=true;
    bMaximizeButton:=true;
    bCloseButton:=false;
    bSizable:=true;
    bVisible:=false;
    bEnabled:=True;
    lpfnWndProc:=@WinTestMsgHandler;
    bAlwaysOnTop:=false;
  end;//with
  WinDebugCtl:=TWindow.create(grCW);

  WinDebugCtl_ctlLabel:=tctllabel.create(WinDebugCtl);
  WinDebugCtl_ctlLabel.X:=3;
  WinDebugCtl_ctlLabel.Y:=4;
  WinDebugCtl_ctlLabel.Width:=15;
  WinDebugCtl_ctlLabel.Height:=6;
  WinDebugCtl_ctlLabel.TextColor:=White;
  WinDebugCtl_ctlLabel.BackColor:=Blue;
  WinDebugCtl_ctlLabel.Caption:='This is a label.';
  WinDebugCtl_ctlLabel.Enabled:=True;
  WinDebugCtl_ctlLabel.Visible:=true;
 
  WinDebugCtl_ctlVScrollBar:=tctlVScrollBar.create(WinDebugCtl);
  WinDebugCtl_ctlVScrollBar.X:=42;
  WinDebugCtl_ctlVScrollBar.Y:=3;
  WinDebugCtl_ctlVScrollBar.MaxValue:=10000;
  WinDebugCtl_ctlVScrollBar.Height:=12;
  WinDebugCtl_ctlVScrollBar.Value:=WinDebugCtl_ctlVScrollBar.MaxValue Div 4;
  
  WinDebugCtl_ctlHScrollBar:=tctlHScrollBar.create(WinDebugCtl);
  WinDebugCtl_ctlHScrollBar.X:=3;
  WinDebugCtl_ctlHScrollBar.Y:=14;
  WinDebugCtl_ctlHScrollBar.Width:=20;
  WinDebugCtl_ctlHScrollBar.MaxValue:=75;
  WinDebugCtl_ctlHScrollBar.Value:=WinDebugCtl_ctlHScrollBar.MaxValue Div 2;
  
  WinDebugCtl_ctlProgressBar:=tctlProgressBar.create(WinDebugCtl);
  WinDebugCtl_ctlProgressBar.X:=5;
  WinDebugCtl_ctlProgressBar.Y:=12;
  WinDebugCtl_ctlProgressBar.Width:=30;
  WinDebugCtl_ctlProgressBar.MaxValue:=200;
  WinDebugCtl_ctlProgressBar.Value:=150;
  

  WinDebugCtl_ctlInput:=tctlInput.create(WinDebugCtl);
  WinDebugCtl_ctlInput.X:=21;
  WinDebugCtl_ctlInput.Y:=4;
  WinDebugCtl_ctlInput.Data:='Input Data Here and this data should be bigger than the input control itself';
 
 
  WinDebugCtl_ctlInput01:=tctlinput.create(WinDebugCtl);
  WinDebugCtl_ctlInput01.X:=21;
  WinDebugCtl_ctlInput01.Y:=6;
  WinDebugCtl_ctlInput01.Data:='More Data Here';
  
  WinDebugCtl_ctlButton01:=tctlbutton.create(WinDebugCtl);
  WinDebugCtl_ctlButton01.X:=10;
  WinDebugCtl_ctlButton01.Y:=10;
  //WinDebugCtl_ctlButton01.Width:=8;
  WinDebugCtl_ctlButton01.Caption:='&Ok';
  
  
  WinDebugCtl_ctlButton02:=tctlButton.create(WinDebugCtl);
  WinDebugCtl_ctlButton02.X:=20;
  WinDebugCtl_ctlButton02.Y:=10;
  //WinDebugCtl_ctlButton02.i4Width:=8;
  WinDebugCtl_ctlButton02.Caption:='&Cancel';
  
  WinDebugCtl_ctlCheckBox:=tctlCheckBox.create(WinDebugCtl);
  WinDebugCtl_ctlCheckBox.X:=25;
  WinDebugCtl_ctlCheckBox.Y:=14;
  WinDebugCtl_ctlCheckBox.RadioStyle:=false;
  
  
  WinDebugCtl_ctlListBox:=tctlListBox.create(WinDebugCtl);
  WinDebugCtl_ctlListBox.X:=44;
  WinDebugCtl_ctlListBox.Y:=2;
  WinDebugCtl_ctlListBox.Width:=25;
  WinDebugCtl_ctlListBox.DataWidth:=90;
  WinDebugCtl_ctlListBox.Height:=12;
  WinDebugCtl_ctlListBox.AppendCaption('Caption1');
  WinDebugCtl_ctlListBox.AppendCaption('Caption2');
  randomize;
  For t:=1 To 1000 Do
  Begin
    If random(2)=1 Then
      WinDebugCtl_ctlListBox.Append(True,inttostr(t)+' Testing The listbox thingy dude! Testing The listbox thingy dude! Testing The listbox thingy dude! Testing The listbox thingy dude!')
    Else
    Begin
      WinDebugCtl_ctlListBox.Append(False,inttostr(t)+' What do You Think? What do You Think? What do You Think? What do You Think? What do You Think?');
      WinDebugCtl_ctlListBox.ChangeItemFG(LightGreen);
    End;
  End;
  WinDebugCtl_ctlListBox.CurrentItem:=1; // Move to top of list
  // END   ------------------------------------------- Debug Controls Window 

  // BEGIN ------------------------------------------- Status Bar create
  guVCStatusBar:=uNewVCObject('guVCStatusBar',giConsoleWidth,2, OBJ_VCSTATUSBAR,nil);
  SetActiveVC(guVCMain);
  // END ------------------------------------------- Status Bar create

  // BEGIN ------------------------------------------- Splash Window
  gRCW.saName:='SplashWindow';
  gRCW.saCaption:='Splash';//
  gRCW.X:=iPlotCenter(giConsoleWidth,64);
  //gRCW.X:=78;
  gRCW.Y:=3;
  gRCW.Width:=64;
  gRCW.Height:= 20;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_NORMAL;
  gRCW.bCaption:=true;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=False;
  gRCW.bCloseButton:=False;
  gRCW.bSizable:=False;
  gRCW.bVisible:=True;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@WINLOGOmsgHandler;
  gRCW.bAlwaysOnTop:=False;
  WINLOGO:=Twindow.create(gRCW);
  WINLOGO.SetFocus;
  // END   ------------------------------------------- Splash Window
  

  //With rSageMsg Do Begin
  //  lpPTR:=POINTER(WinLogo);
  //  uMsg:=MSG_GOTFOCUS;
  //  uParam1:=0;
  //  uParam2:=0;
  //  uObjType:=OBJ_NONE;
  //  {$IFDEF LOGMESSAGES}
  //  saSender:='InitSageUI';
  //  {$ENDIF}
  //End;//with
  //PostMessage(rSageMsg); 



  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('CreateIntegratedUIObjects',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================


























//=============================================================================
Function InitSageUI(p_lpfnUsersMainMsgHandler: pointer): Boolean;
//=============================================================================
Var 
  bInitError: Boolean;
  rSageMsg: rtSageMsg;
  
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('InitSageUI',SOURCEFILE);
  {$ENDIF}
  bInitError:=False;

  If not gbSageUIUnitInitialized Then
  Begin
    If not ConsoleUnitInitialized Then
    Begin
      If not InitConsole Then
      Begin
        bInitError:=True;
        JLog(cnLog_ERROR,200902081241,'Unable to Initialize uxxc_Console',sourcefile);
      End;
    End
    Else
    Begin
      bInitError:=True;
      JLog(cnLog_ERROR,200609201557,'Console Unit Already Initialized. Do Not Use Console Unit PRIOR to starting SageUI.',SOURCEFILE);
    End;
  End;

  If bInitError Then
  Begin
    InitSageUI:=False;
    gbSageUIUnitInitialized:=False;
  End
  Else
  Begin
    InitSageui:=True;                          
    gbSageUIUnitInitialized:=True;             
 
    gMB:=nil;
    gbMsgBoxOpen:=false;
    gbGetMessageFirstTime:=true;
    gbStatusBarDrawnAtLeastOnce:=false;
    
    With grObjectsXXDLStats Do  Begin
      iNumberOfObjects:=0;
      iNumberOfWindows:=0;
      iNumberOfVirtualConsoles:=0;
      iNumberOfControls:=0;
      iNumberOfUnknown:=0;
      iNumberOfObj_NONE:=0;
    End;


    // Instantiate CORE OBJECTS///////////////////////////////////////////////////////////////////////
    OBJECTSXXDL:=JFC_XXDL.create;

    // Message Queue ///////////////////////////////////////////////
    MQ:=JFC_XXDL.create;
    giMQMaxListCount:=0; // Message QUEUE Max "filled" length or list count.
    BROADCAST:=@BROADCASTADDRESS;
    With rSageMsg Do Begin
      lpPTR:=nil;
      uMsg:=MSG_FIRSTCALL;
      uParam1:=0;
      uParam2:=0;
      uObjType:=OBJ_NONE;
      {$IFDEF LOGMESSAGES}
      saSender:='InitSageUI';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 

    // Mouse and Keyboard Stuff /////////////////////////////////////
    grMSC.uCmd:=MSC_None;
    gsaClipBoard:='';
    //TurnOffCntlC;



    // Window Stuff //////////////////////////////////////////////////
    gi4WindowHasFocusUID:=0;
    //this for next minimized window x,y (Makes them stack nicely when all minimized.
    gi4NextMinX:=(((giConsoleWidth Div 20)*20)-20)+(giConsoleWidth Mod 20)+1;
    gi4NextMinY:=giConsoleHeight-3;
    gbModal:=False;
    
    {$IFDEF LOGMESSAGES}
    gbLogMessages:=True;
    {$ELSE}
    gbLogMessages:=False;
    {$ENDIF}

    
    // GFX Optimization Flags //////////////////////////////////////
    grGfxOps.bUpdateZOrder:=True;
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - InitSageUI - update zorder',SOURCEFILE);{$ENDIF}
    
    // MISC //////////////////////////////////////////////
    gbShutdownPending:=False;
    
    
    
    ///////////////////////////////////////////////////////
    // Integrated UI Objects 
    ///////////////////////////////////////////////////////
    // This Next Call Initializes the CORE USER Interface that is tied into 
    // this system.
    CreateIntegratedUIObjects;
    
    // Finally Set the Users Main Message Handler /////////////////////////////////////
    pointer(glpFUNCTION_uUsersMainMsgHandler):=p_lpfnUsersMainMsgHandler;
    // Finally Set the Users Main Message Handler /////////////////////////////////////
    //grGFXops.b pdateConsole:=True;
    {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - initsageui update console',SOURCEFILE);{$ENDIF}
    SetBackGround;
    BringVCToTop(guVCMain);
    ReDrawConsole;
    
  End;
  
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('InitSageUI',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
// TODO: Could Clean This Up - but the demand isn't there Right now.
// Best Way to Go Would be to TRY to maybe make a loop through objects XXDL and try to 
// Selectively close objects it know about.. but don't care right this moment.
Procedure DoneSageUI;
//=============================================================================
var
  iLoop: Integer;   
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DoneSageUI',SOURCEFILE);
  {$ENDIF}
  
  If gbSageUIUnitInitialized Then
  Begin

    While ObjectsXXDL.FoundItem_ID(OBJ_WINDOW,3)Do Begin
      TWindow(ObjectsXXDL.Item_lpPTR).Destroy;
    End;

{
    While gVC.ListCount>0 Do Begin 
      RemoveVCObject(gVC.Item_ID1);
    End;
    gVC.Destroy;
}


    gAKey.Destroy;
    If gmb.listcount>0 Then
    Begin
      repeat
        JFC_XXDL(gMB.Item_lpPTR).Destroy;
        gMB.DeleteItem;
      Until gmb.listcount=0;
    End;
    gmb.destroy;gmb:=nil;

    MQ.Destroy;

    gbSageUIUnitInitialized:=False;
    //If gbSageUIStartedConsole Then
   // Begin
      // Return Screen To a presentable State
      BringVcToTop(1);
      SetActiveVC(1);
      VCSetVisible(True); // Just in case
      VCResize(giConsoleWidth, giConsoleHeight); // just in case
      VCSetXY(1,1); // Just In case
      VCSetFGC(lightgray);
      VCSetBGC(black);
      VCSetTrackCursor(True);
      VCClear;
      VCSetCursorType(crUnderline);
      ForceCursorType(crUnderline);
      Updateconsole;grGfxOps.bUpdateConsole:=false;
      DoneConsole;
      //Writeln('If it looks like the Program has not ended - Press enter.');
      //Writeln('Good Bye!');
    //End;
    ForceCursorType(crUnderline);
    For iLoop:=1 To 200 Do Write(StringOfChar(' ',giConsoleWidth*2));
    Writeln(saJegasLogoRawText(csEOL));
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('DoneSageUI',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function SageUIUnitInitialized: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SageUIUnitInitialized',SOURCEFILE);
  {$ENDIF}

  SageUIUnitInitialized:=gbSageUIUnitInitialized;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SageUIUnitInitialized',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





























var 
  dtLastScreenUpdate: TDATETIME;
  scrSav_VC: longint;
  scrSav_iTime: Integer;
  scrSav_iTimeDiff: Integer;
//=============================================================================
Procedure UpdateSageUI;
//=============================================================================
//Var bPaintIt:Boolean;
//    bFirstCall: Boolean;
//Var bTempStarVCVisible:Boolean;
Var dtNow: TDATETIME; iMilliSeconds: Integer;
Begin
  dtNow:=now; iMilliSeconds:=iDiffMSec( dtLastScreenUpdate, dtNow);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('UpdateSageUI (gbTrulyIdle:'+saTrueFalse(gbTrulyIdle)+') MilliSeconds Since Last Update:' +inttostr(iMilliSeconds)+ ' (Refresh Every '+inttostr(cnSAGEUI_ScreenUpdateMilliSecondInterval)+' Milliseconds)',SOURCEFILE);
  {$ENDIF}

  If iMilliSeconds>cnSAGEUI_ScreenUpdateMilliSecondInterval Then
  Begin
    dtLastScreenUpdate:=dtNow;
    //-------------------------------------------------------STATUS ORIENTED DEBUG ORIENTED
    // Status Bar
    SetActiveVC(guVCStatusBar);
    If gbTrulyIdle Then 
    Begin
      if gbStatusBarDrawnAtLeastOnce=false then
      begin
        gbStatusBarDrawnAtLeastOnce:=true;
        grGFXOps.bUpdateZOrder:=true;
      end;
      VCSetCursorType(crHidden); 
      VCSetVisible(True);
      VCSetXY(1,giConsoleHeight-1);
      VCSetFGC(gu1ButtonFG);
      VCSetBGC(gu1ButtonBG);
      VCFillBox(1,1,giConsoleWidth,2,' ');
      VCWriteXY(3,1,'F1:Help F2:Prev F3:Next F4:Close F5:Cycle-Win F6:Menu F7:Control F8:Shutdown');
      VCSetFGC(gu1ButtonFG);
      VCSetBGC(gu1ButtonBG);
      VCWriteXY(giConsoleWidth-19,2, saFormatDateTime(csDATETIMEFORMAT,dtNow));
      
      if scrSav_iTime=0 then scrSav_iTime:=iMSec;
      scrSav_iTimeDiff:=iMSec-scrSav_iTime;
      if (scrSav_iTimeDiff>(60000*5)) then
      //if (scrSav_iTimeDiff>(5000)) then  
      begin
        scrSav_VC:=NewVC;
        SetActiveVC(scrSav_VC);
        if random(2)=0 then VCSetBGC(3) else VCSetBGC(0);
        VCClear;
        InitFish(random(30));
        repeat
          UpdateFish;UpdateConsole;
        until KeyHit or Mevent;
        if keyhit then GetKeyPress;
        if mevent then GetMEvent;
        RemoveVC(scrSav_VC);scrSav_VC:=0;
        DoneFish;
        RedrawConsole;
        scrSav_iTime:=0;
        grgfxOps.bUpdateZorder:=true;
        {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - scrsav',SOURCEFILE);{$ENDIF}
      end;
      //VCSetFGC(gu1StatusBarIdleFG);
      //VCWriteXY(1,2,saFixedLength('-=\IDLE/=-',1,12));
      //Inc(gu1StatusBarIdleFG);
      If gu1StatusBarIdleFG=16 Then gu1StatusBarIdleFG:=0;
      if guVCDebugHasFocus = 3 then
      begin
        UpdateStars; 
      end;
      grGfxOps.bUpdateConsole:=true;
    End
    Else
    Begin
      //VCSetFGC(LIGHTRED); VCSetBGC(Black);
      //VCWriteXY(1,2,saFixedLength('>>WORKING<<',1,12));
      scrSav_iTime:=0;
    End;
 
  
    
    If grGfxOps.bUpdateConsole Then
    Begin
      If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then
     Begin
        If TWindow(OBJECTSXXDL.Item_lpPtr).bRedraw Then
        Begin
          TWindow(OBJECTSXXDL.Item_lpPtr).PaintWindow;
        End;
      End;
    end;


    If grGfxOps.bUpdateZOrder Then
    Begin
      // Then Window With Focus
      If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then
      Begin
        BringVCToTop(OBJECTSXXDL.Item_ID2);
      End;

      //// Windows set as "Always on Top" have Higher
      //// priority than Window with focus if its not
      //// "Always on Top"
      If OBJECTSXXDL.FoundItem_ID(OBJ_WINDOW, 3) Then
      Begin
        repeat 
          If TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).rW.bAlwaysOnTop Then
          Begin
            BringVCToTop(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[2]);
          End;
        Until not OBJECTSXXDL.FNextItem_ID(OBJ_WINDOW, 3)
      End;
     
      //// unless window with focus IS set to always on top    
      If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then
      Begin
        If TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).rW.bAlwaysOnTop Then
        Begin
          BringVCToTop(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[2]);
        End;
      End;
  
      SetActiveVC(guVCMenuBar); VCSetVisible(gbMenuVisible);
      SetActiveVC(guVCMenuPopUp); VCSetVisible(gbMenuDown);
      If gbMenuVisible Then 
      begin
        DrawMenuBar;
        BringVCToTop(guVCMenuBar);
        if gbMenuDown then BringVCToTop(guVCMenuPopUp);
      end
      else
      begin
        gi4MenuHeight:=0;
      end;

      // Status Bar TopMost
      if gbStatusBarDrawnAtLeastOnce then
      begin
        BringVCToTop(guVCStatusBar);
      end;
      grGfxOps.bUpdateZorder:=False; 
      //grGfxOps.bUpdateConsole:=True;
    End;
    If grGfxOps.bUpdateConsole Then
    Begin
      UpdateConsole;grGfxOps.bUpdateConsole:=False; 
    End;
  End;  
  
  // reduntant assurance grGfxOps flags reset
  grGfxOps.bUpdateConsole:=false;
  grGFXOps.bUpdateZOrder:=false;
  
  
  //--------------------------------------------------------------------------
  // Maintain GFX OutPut
  //--------------------------------------------------------------------------
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('UpdateSageUI',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================








{$IFDEF DEBUGWINDOWS}
//=============================================================================
Procedure DebugHouseKeeping;
//=============================================================================
//Var rSageMsg: rtSageMsg;
//Var iExitStatus:Integer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DebugHouseKeeping',SOURCEFILE);
  {$ENDIF}

  GetOBJECTSXXDLStats;
  //While ObjectsXXDL.FoundItem_ID(OBJ_THREADCOMPLETEDTASK,3) Do Begin
  //  JTHREAD(JFC_XXDLITEM(ObjectsXXDL.lpItem).lpPTR).suspend;
  //End;
  
  //While ObjectsXXDL.FoundItem_ID(OBJ_THREADTERMINATED,3) Do Begin
    //ObjectsXXDL.DeleteItem;
  //End;
  /// JTHREAD(JFC_XXDLITEM(ObjectsXXDL.lpItem).lpPTR).Destroy;

//  // PASS ONE - Post Messages REgarding the Threads Status if Terminated
//  
//  If OBJECTSXXDL.FoundItem_ID(OBJ_THREAD,3) Then
//  Begin
//    repeat
//      If (JFC_XXDLITEM(OBJECTSXXDL.lpItem).i8User and B00)=0 Then
//      Begin
//        With rSageMsg Do Begin
//          lpPTR:=nil;
//          uMsg:=MSG_THREADTERMINATED;
//          uParam1:=0;
//          uParam2:=0;
//          uObjType:=OBJ_THREAD;
//          {$IFDEF LOGMESSAGES}
//          saSender:='JThread.Create';
//          {$ENDIF}
//        End;//with
//        PostMessage(rSageMsg);
//        JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[3]:=OBJ_THREADTERMINATE_D;
//        JThread(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).Destroy;
//      End;
//    Until not OBJECTSXXDL.FNextItem_ID(OBJ_THREAD,3);
//  End;
//  // PASS 2 - Remove Them
//  While OBJECTSXXDL.FoundItem_ID(OBJ_THREADTERMINATE_D,3) Do
//  Begin
//    OBJECTSXXDL.DeleteItem;
//  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('DebugHouseKeeping',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================
{$ENDIF}










// This doesn't take parameters because ITS JOB is to Round THINGS and 
// Place them in the MessageQueue "MQ" (JFC_XXDL). Thats All.
//=============================================================================
Procedure GetNewMessages; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('GetNewMessages',SOURCEFILE);
  {$ENDIF}
  ProcessUserIO;
  {$IFDEF DEBUGWINDOWS}
  DebugHouseKeeping;
  {$ENDIF}
  // otherwise something happened
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('GetNewMessages',SOURCEFILE);
  {$ENDIF}
End;
//--------------------------------------------------------------------------




















// Supposed to RETURN FALSE When Program Is Shutting Down and All remain
// WORK IS COMPLETED.
// actualgetmessage
//=============================================================================
Function GetMessage(Var p_rSageMsg: rtSageMsg):Boolean;
//=============================================================================
var TempVC: longint;
//--------------------------------------------------------------------------
// actual getmessage routine
//--------------------------------------------------------------------------
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('GetMessage',SOURCEFILE);
  {$ENDIF}
  
  if gbGetMessageFirstTime then
  begin
    gbGetMessageFirstTime:=false;
    TempVC:=GetActiveVC;
    SetActiveVC(guVCMain);
    VCFillBoxCtr(VCWidth, VCHeight,gchScreenBGChar);
    SetActiveVC(TempVC);
  end;
  
  With p_rSageMsg Do Begin
    uMsg   := MSG_IDLE;
    uParam1:= 0;
    uParam2:= 0;
    uObjType:= OBJ_NONE;
    lpptr:=nil;
    {$IFDEF LOGMESSAGES}
    saSender:='GetMessage';
    {$ENDIF}
    saDescOldPackedTime:='';
    uUID:=0;
  End;//with

  GetNewMessages;
  
  // TRULY IDLE - SHOULD NOT be BROADCAST to ALL Objects. Way To Slow.
  // Going to SEND ONE Message - and Only Send it ONCE Until 
  // Something Else doing.. GLOBAL for THIS: gbTRULYIDLE; 
  
  gbTrulyIDLE:=gbTrulyIDLE and (MQ.ListCount=0);
  If gbTrulyIdle Then 
  Begin
    if not gbShutDownPending then
    begin
      // Could Call Something Here to do when nothing important doing.
      // For Now - We'll Call Yield
      UpdateSageUI;
      Yield(10);
    end;
  End
  Else
  Begin
    If MQ.ListCount=0 Then // Going into TRULY IDLE
    Begin
      gbTrulyIDLE:=True;
      // WE ARE DONE HERE - But For Our Switching to 
      // TRULY IDLE, Lets UpDate The Screen.
      UpdateSageUI;
    End
    Else
    Begin
      gbTrulyIDLE:=false;
      scrSav_iTime:=0;
      UpdateSageUI;
      
      MQ.MoveFirst;
      With p_rSageMsg Do Begin
        uUID:=JFC_XXDLITEM(MQ.lpItem).UID;// Share the UID with the World :)
        uMsg:=JFC_XXDLITEM(MQ.lpItem).ID[4];
        uParam1:=JFC_XXDLITEM(MQ.lpItem).ID[1];
        uParam2:=JFC_XXDLITEM(MQ.lpItem).ID[2];
        uObjType:=JFC_XXDLITEM(MQ.lpItem).ID[3];
        lpPTR:=JFC_XXDLITEM(MQ.lpItem).lpPTR;
        {$IFDEF LOGMESSAGES}
        saSender:=JFC_XXDLITEM(MQ.lpItem).saName;
        {$ENDIF}
        saDescOldPackedTime:=JFC_XXDLITEM(MQ.lpItem).saDesc;
      End;          
      // MESSAGE QUEUE
      If MQ.ListCount>giMQMaxListCount Then giMQMaxListCount:=MQ.Listcount;
      MQ.DeleteItem;

      {$IFDEF DEBUGWINDOWS}
      If windebugmq.windowstate<>ws_minimized Then windebugmq.paintwindow;      
      {$ENDIF}
    End;
  End;// of truly idle

  //-------------------------------------------------------STATUS ORIENTED DEBUG ORIENTED
  // MESSAGE QUEUE DEBUG MESSAGES
                            
                                
  if not gbShutDownPending then
  begin                            
    SetActiveVC(guVCMain);
  end;


  //Result:= not (gbTrulyIDLE and gbShutdownPending and (OBJECTSXXDL.ListCount=0)) ; 
  Result:=not gbShutdownPending;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('GetMessage',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================











// Dispatch Message STARTS with a Freshly YANKED message from the Message
// QUEUE. Granted, The USER CAN PEEK AT IT -  in their main processing loop
// but that is Ok.
//
// User Calls GetMessage - Which Ultimately returns the next bit of work to be
// handled - the most recent message off the message queue, before calling
// dispatch. 
//
// DISPATCH Is the beginning of the Message getting processed - in that depending
// on the message, the appropriate user entry points are called, etc.
// ugh - to hard to explain.

//ActualDispatchMessage
//=============================================================================
Procedure DispatchMessage(Var p_rSageMsg: rtSageMsg);
//=============================================================================
Var 
  bHandled: Boolean;// Denotes if the ANYTHING Handled the Situation
  rSageMsg: rtSageMsg;
  uVCBookMark: UINT;
  UserMsgHandler: Function(Var p_rSageMsg: rtSageMsg):UINT;
  uRESULT_UserMsgHandler: UINT;
  uRESULT_UsersMainMessageHandler: UINT;


                        // This function decides how to Generically Invoke USER Configured 
                        // Entry Points.
                        Procedure ObjectSpecificUserHandler;//(var p_rSageMsg: rtSageMsg);
                        var i4Y: longint;
                            i4FLength: longint;
                            TempVC: UINT;
                        Begin
                          {$IFDEF DEBUGLOGBEGINEND}
                          DebugIn('DispatchMessage.ObjectSpecificUserHandler: OBJECTSXXDL.ITem_saName:'+OBJECTSXXDL.ITem_saName,SOURCEFILE);
                          {$ENDIF}
                          If p_rSageMsg.lpPTR<>nil Then // Can''t be NULL
                          Begin
                            If OBJECTSXXDL.FoundItem_lpPtr(p_rSageMsg.lpPTR) Then // Object Must (appear) to Exist
                            Begin
                              If pointer(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[1])<>nil Then // The Entry Point Can Not Be Null
                              Begin
                                TempVC:=GetActiveVC;
                                SetActiveVC(guVCDebugWindows);
                                if VCGetVisible then
                                begin
                                  if 
                                    //(p_rSageMsg.uMsg<>MSG_IDLE              ) and
                                    //(p_rSageMsg.uMsg<>MSG_FIRSTCALL         ) and
                                    //(p_rSageMsg.uMsg<>MSG_UNHANDLEDKEYPRESS ) and
                                    //(p_rSageMsg.uMsg<>MSG_UNHANDLEDMOUSE    ) and
                                    //(p_rSageMsg.uMsg<>MSG_MENU              ) and
                                    //(p_rSageMsg.uMsg<>MSG_SHUTDOWN          ) and
                                    //(p_rSageMsg.uMsg<>MSG_CLOSE             ) and
                                    //(p_rSageMsg.uMsg<>MSG_DESTROY           ) and
                                    //(p_rSageMsg.uMsg<>MSG_BUTTONDOWN        ) and
                                    //(p_rSageMsg.uMsg<>MSG_LOSTFOCUS         ) and
                                    //(p_rSageMsg.uMsg<>MSG_GOTFOCUS          ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLGOTFOCUS       ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLLOSTFOCUS      ) and
                                    //(p_rSageMsg.uMsg<>MSG_WINDOWSTATE       ) and
                                    //(p_rSageMsg.uMsg<>MSG_WINDOWMOVE        ) and
                                    //(p_rSageMsg.uMsg<>MSG_WINDOWRESIZE      ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLSCROLLUP       ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLSCROLLDOWN     ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLSCROLLLEFT     ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLSCROLLRIGHT    ) and
                                    //(p_rSageMsg.uMsg<>MSG_CHECKBOX          ) and
                                    //(p_rSageMsg.uMsg<>MSG_LISTBOXMOVE       ) and
                                    //(p_rSageMsg.uMsg<>MSG_LISTBOXCLICK      ) and
                                    //(p_rSageMsg.uMsg<>MSG_LISTBOXKEYPRESS   ) and
                                    (p_rSageMsg.uMsg<>MSG_PAINTWINDOW       ) and
                                    //(p_rSageMsg.uMsg<>MSG_SHOWWINDOW        ) and
                                    //(p_rSageMsg.uMsg<>MSG_CTLKEYPRESS       ) and
                                    (p_rSageMsg.uMsg<>MSG_WINPAINTVCB4CTL   ) and
                                    (p_rSageMsg.uMsg<>MSG_WINPAINTVCAFTERCTL ) and
                                    (1=1) then
                                  begin
                                    i4Y:=2;// ypos of debug cursor in vc to write at
                                    i4FLength:=10; // fixed length for the field data being written to debug VC
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'type rtSageMSG=record');i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  uUID:              ');VCSetFGC(white);VCWrite(saFixedLength(inttostr(p_rSageMsg.uUID),1,i4FLength));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  uMsg:              ');VCSetFGC(white);VCWrite(saFixedLength(inttostr(p_rSageMsg.uMsg),1,i4FLength));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  uParam1:           ');VCSetFGC(white);VCWrite(saFixedLength(inttostr(p_rSageMsg.uParam1),1,i4FLength));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  uParam2:           ');VCSetFGC(white);VCWrite(saFixedLength(inttostr(p_rSageMsg.uParam2),1,i4FLength));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  uOBJType:          ');VCSetFGC(white);VCWrite(saFixedLength(inttostr(p_rSageMsg.uObjType),1,11) + saFixedLength(ObjToText(p_rSageMsg.uObjType),1,20));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  lpPtr:              ');VCSetFGC(white);
                                    VCWrite(saFixedLength(inttostr(UINT(p_rSageMsg.lpPTR)),1,i4FLength));
                                    i4Y+=1;
                                    {$IFDEF LOGMESSAGES}
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  saSender:           ');VCSetFGC(white);VCWrite(saFixedLength(p_rSageMsg.saSender,1,i4FLength));i4Y+=1;
                                    {$ENDIF}
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  saDescOldPackedTime:');VCSetFGC(white);VCWrite(saFixedLength(p_rSageMsg.saDescOldPackedTime,1,i4FLength));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'end;');i4Y+=1;
                                    VCSetFGC(White);VCWriteXY(1,i4Y,MSGTOTEXT(p_rSageMsg));i4Y+=2;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'gi4WindowHasFocusUID: ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(gi4WindowHasFocusUID),1,5));i4Y+=1;
                                    if OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) then
                                    begin
                                      VCWrite(saFixedLength(   TWINDOW(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPtr).Caption  ,1,10));//
                                    end;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'gi4NextMinX:          ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(gi4NextMinX),1,5));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'gi4NextMinY:          ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(gi4NextMinY),1,5));i4Y+=1;
                                    VCSetFGC(LightGray);VCWriteXY(1,i4Y,'gbModal:              ');VCSetFGC(White);VCWrite(saFixedLength(saTrueFalsE(gbModal),1,5));i4Y+=1;
                                    if OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) then
                                    begin
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'type JFC_XXDLITEM=class');i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  UID:                       ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(JFC_XXDLITEM(OBJECTSXXDL.lpItem).UID),1,11));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  Name:                      ');VCSetFGC(White);VCWrite(saFixedLength(JFC_XXDLITEM(OBJECTSXXDL.lpItem).saName,1,40));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  Value:                     ');VCSetFGC(White);VCWrite(saFixedLength(JFC_XXDLITEM(OBJECTSXXDL.lpItem).saValue,1,40));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  Desc:                      ');VCSetFGC(White);VCWrite(saFixedLength(JFC_XXDLITEM(OBJECTSXXDL.lpItem).saDesc,1,40));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  Object Ptr:                ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(UINT(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPtr)),1,11));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  UserMsgHander Ptr ID[1]:   ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(UINT(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[1])),1,11));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  VC UID ID[2]:              ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[2]),1,5));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  ObjType ID[3]:             ');VCSetFGC(White);VCWrite(saFixedLength(ObjToText(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[3]),1,5));i4Y+=1;
                                      VCSetFGC(LightGray);VCWriteXY(1,i4Y,'  gVC Hidden Flag ID[4]:     ');VCSetFGC(White);VCWrite(saFixedLength(inttostr(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[4]),1,5));i4Y+=1;
                                    end;                                    
                                  end;
                                end;
                                SetActiveVC(TempVC);
                                
                                pointer(UserMsgHandler):=pointer(JFC_XXDLITEM(OBJECTSXXDL.lpItem).ID[1]);
                                uRESULT_UserMsgHandler:=UserMsgHandler(p_rSageMsg);
                                //Log(cnLog_Debug,20120131,'FIRED USERMSGHANDLER!!! uRESULT_UserMsgHandler:'+inttostr(uRESULT_UserMsgHandler),SOURCEFILE);
                              End;
                            End;
                          End;
                          {$IFDEF DEBUGLOGBEGINEND}
                          DebugOut('DispatchMessage.ObjectSpecificUserHandler',SOURCEFILE);
                          {$ENDIF}
                        End;


  //var lpTemp: pointer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('DispatchMessage:',SOURCEFILE);
  {$ENDIF}
  rSageMsg.lpPTR:=nil;//shutupcompiler - Not related to record coming in.
  
  {$IFDEF LOGMESSAGES}
  JLog(cnLog_Debug,201201312000,'DISPATCHING:'+MSGTOTEXT(p_rSageMsg),SOURCEFILE);
  {$ENDIF}

  If 
    (p_rSageMsg.uMsg<>MSG_IDLE) and
    (p_rSageMsg.uMsg<>MSG_UNHANDLEDMOUSE)
  Then
  Begin
    uVCBookMark:=GetActiveVC;
    SetActiveVC(guVCDebugMessages);
    Inc(gu1VCDebugMessagesFGC);
    gu1VCDebugMessagesFGC:=(gu1VCDebugMessagesFGC and 15);
    If (gu1VCDebugMessagesFGC)=VCGetPenBGC Then 
    Begin
      Inc(gu1VCDebugMessagesFGC);
    End;
    VCWriteln;
    VCSetFGC(gu1VCDebugMessagesFGC);
    VCWrite(MsgToText(p_rSageMsg));
    SetActiveVC(uVCBookMark);
  End;
  
  //Log(cnLog_Debug,201201312001,'Display Message',SOURCEFILE);
  
  uRESULT_UserMsgHandler:=0;uRESULT_UserMsgHandler-=0;
  uRESULT_UsersMainMessageHandler:=0;uRESULT_UsersMainMessageHandler-=0;
  bHandled:=False;bHandled:=bHandled and True;

  // MAIN USER HANDLER
  //uRESULT_UsersMainMessageHandler:= glpFUNCTION_uUsersMainMsgHandler(p_rSageMsg);
  
  // Object Specific User Handler
  // uRESULT_UserMsgHandler  
  
  //Log(cnLog_Debug,201201312002,'BEFORE Users Main Msg Handler',SOURCEFILE);
  uRESULT_UsersMainMessageHandler:= glpFUNCTION_uUsersMainMsgHandler(p_rSageMsg);
  //Log(cnLog_Debug,201201312003,'After Users Main Msg Handler',SOURCEFILE);
  
  With p_rSageMsg Do Begin
    Case uMsg Of
    MSG_IDLE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_FIRSTCALL: 
      Begin
        Case uObjType Of
        OBJ_NONE: 
          Begin
            grGFXOps.bUpdateConsole:=True;
            grGFXOps.bMenuPopUpChange:=True;
            grGFXOps.bUpdateZOrder:=True;
            {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - Dispatchmessage - firstcall',SOURCEFILE);{$ENDIF}
            
            //If gMB.ListCount>0 Then
            //Begin
            //  // TODO: Old Code I guess, no references anywhere....
            //  //iOldMenuBar:=gMB.Item_i8User;
            //  //bOldMenuDown:=gbMenuDown;
            //  // This is a guess.
            //  guVCMenuBar:=gMB.Item_i8User;
            //  //gbMenuDown:= NOT Solved
            //End;
            
            // Check If We Have a FOCUSED Window
            //If gi4WindowHasFocusUID<>0 Then
            //Begin
            //  If OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID) Then
            //  Begin
            //    // TODO: Check If this Window is still Valid to be considered IN FOCUS and Correct as necessary
            //    If TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).Enabled and 
            //       TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).visible Then
            //    Begin
            //      // Should Be Ok
            //    End
            //    Else
            //    Begin
            //      gi4WindowHasFocusUID:=0;
            //    End;
            //  End;
            //End;
            
            //If gi4WindowHasFocusUID=0 Then            
            //Begin
              // Make First Valid Window the focused one.
              //If OBJECTSXXDL.FoundItem_ID(OBJ_WINDOW,3) Then
              //Begin
              //  gi4WindowHasFocusUID:=0;
              //  
              //  //repeat
              //  //  If TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).Enabled and 
              //  //     TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).visible Then
              //  //  Begin
              //  //    //grGFXOps.bUpdateZOrder:=True;
              //  //    {$IFDEF DEBUGTRACKGFXOPS}
              //  //    //JLOG(cnLog_Debug,201003040235,'grGfxOps - dispatchmessage - make first window focused',SOURCEFILE);
              //  //    {$ENDIF}
              //  //    gi4WindowHasFocusUID:=OBJECTSXXDL.Item_UID;
              //  //    // Tell Window it got focus. 
              //  //    rSageMsg:=p_rSageMsg;
              //  //    With rSageMsg Do Begin
              //  //      uMsg   := MSG_GOTFOCUS;
              //  //      uParam1:= 0;
              //  //      uParam2:= 0;
              //  //      uObjType:= OBJ_WINDOW;
              //  //      lpptr:=JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR;
              //  //      {$IFDEF LOGMESSAGES}
              //  //      saSender:='DispatchMessage in response to MSG_FIRSTCALL MSGTOTEXT:' + MSGTOTEXT(rSageMsg);
              //  //      {$ENDIF}
              //  //      saDescOldPackedTime:='';
              //  //      //uUID:=0;
              //  //    End;//with
              //  //    PostMessage(rSageMsg); 
              //  //  End;
              //  //Until (gi4WindowHasFocusUID<>0) OR OBJECTSXXDL.FNextItem_ID(OBJ_WINDOW,3);// TODO: Inspect, logic here looks wrong for the until line (FNext part)
              //  
              //End;
            //End;
          End;
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_UNHANDLEDKEYPRESS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_UNHANDLEDMOUSE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_MENU: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_SHUTDOWN: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
        gbShutDownPending:=true;
      End;

    MSG_CLOSE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              rSageMsg:=p_rSageMsg;
              With rSageMsg Do Begin
                uMsg   := MSG_DESTROY;
                uParam1:= 0;
                uParam2:= 0;
                uObjType:= OBJ_WINDOW;
                //lpptr:=;
                {$IFDEF LOGMESSAGES}
                saSender:='DispatchMessage in response to MSG_CLOSE MSGTOTEXT:' + MSGTOTEXT(rSageMsg);
                {$ENDIF}
                saDescOldPackedTime:='';
                //uUID:=0;
              End;//with
              PostMessage(rSageMsg); 
            End;
          End;
        End;//case
      End;

    MSG_DESTROY: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              grGfxOps.bUpdateConsole:=True;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - dispatchmessage - MSG_DESTROY',SOURCEFILE);{$ENDIF}
              TWindow(p_rSageMsg.lpPTR).Destroy;
            End;
          End;
        End;//case
      End;

    MSG_BUTTONDOWN: 
      Begin
        Case uObjType Of
        OBJ_BUTTON:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;

    MSG_LOSTFOCUS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_GOTFOCUS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              //SageLog(1,'Trying to bring Window To Front/top WINDOW POINTER:'+inttostr(Cardinal(rSageMsg.lpPTR)),SOURCEFILE);
              BringVCToTop(TWindow(p_rSageMsg.lpPTR).SELFOBJECTITEM.ID[2]);
              TWindow(p_rSageMsg.lpPTR).bRedraw:=true;
              gi4WindowHasFocusUID:=TWindow(p_rSageMsg.lpPTR).SELFOBJECTITEM.UID;
              //if TWindow(p_rSageMsg.lpPTR).C.Movefirst then
              //begin
              //  repeat
              //    TWindow(p_rSageMsg.lpPTR).C.bRedraw:=true;
              //  until not TWindow(p_rSageMsg.lpPTR).C.MoveNext;
              //end;
              
              //grGfxOps.b pdateConsole:=True;
              {$IFDEF DEBUGTRACKGFXOPS}
              //JLOG(cnLog_Debug,201003040235,'grGfxOps - DispatchMessage - MSG_GOTFOCUS',SOURCEFILE);
              {$ENDIF}
              // To Ask LOOP to Paint me
              rSageMsg:=p_rSageMsg;
              With rSageMsg Do Begin
                uMsg   := MSG_PAINTWINDOW;
                uParam1:= 0;
                uParam2:= 0;
                uObjType:= OBJ_WINDOW;
                //lpptr:=;
                {$IFDEF LOGMESSAGES}
                saSender:='DispatchMessage in response to MSG_GOTFOCUS MSGTOTEXT:' + MSGTOTEXT(rSageMsg);
                {$ENDIF}
                saDescOldPackedTime:='';
                //uUID:=0;
              End;//with
              PostMessage(rSageMsg); 
            End;
          End;
        End;//case
      End;



    MSG_CTLGOTFOCUS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_CTLLOSTFOCUS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_WINDOWSTATE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_WINDOWMOVE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;

    MSG_WINDOWRESIZE: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
              grGfxOps.bUpdateConsole:=true;
              {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - Dispatch - MSG_WINDOWRESIZE',SOURCEFILE);{$ENDIF}
            End;
          End;
        End;//case
      End;


    MSG_CTLSCROLLUP: 
      Begin
        Case uObjType Of
        OBJ_VSCROLLBAR:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_CTLSCROLLDOWN: 
      Begin
        Case uObjType Of
        OBJ_VSCROLLBAR:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_CTLSCROLLLEFT: 
      Begin
        Case uObjType Of
        OBJ_HSCROLLBAR:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_CTLSCROLLRIGHT: 
      Begin
        Case uObjType Of
        OBJ_HSCROLLBAR:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_CHECKBOX: 
      Begin
        Case uObjType Of
        OBJ_CHECKBOX:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_LISTBOXMOVE: 
      Begin
        Case uObjType Of
        OBJ_LISTBOX:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;



    MSG_LISTBOXCLICK: 
      Begin
        Case uObjType Of
        OBJ_LISTBOX:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;

    MSG_LISTBOXKEYPRESS: 
      Begin
        Case uObjType Of
        OBJ_LISTBOX:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;


    MSG_PAINTWINDOW: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              TWindow(p_rSageMsg.lpPTR).PaintWindow;
            End;
          End;
        End;//case
      End;



    
    MSG_SHOWWINDOW: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
              // To Ask LOOP to Paint me
              //OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID);
              //gi4WindowHasFocusUID:=OBJECTSXXDL.Item_UID;
              rSageMsg:=p_rSageMsg;
              With rSageMsg Do Begin
                uMsg   := MSG_GOTFOCUS;
                uParam1:= 0;
                uParam2:= 0;
                uObjType:= OBJ_WINDOW;
                {$IFDEF LOGMESSAGES}
                saSender:='DispatchMessage in response to MSG_SHOWWINDOW MSGTOTEXT:' + MSGTOTEXT(rSageMsg);
               {$ENDIF}
                saDescOldPackedTime:='';
                //uUID:=0;
              End;//with
              PostMessage(rSageMsg); 
            End;
          End;
        End;//case
      End;

    
    MSG_CTLKEYPRESS: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;

    MSG_WINPAINTVCB4CTL: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;
    
    
    MSG_WINPAINTVCAFTERCTL: 
      Begin
        Case uObjType Of
        OBJ_WINDOW:
          Begin
            ObjectSpecificUserHandler;     
            //JLOG(0,0,'MADE IT',SOURCEFILE);
            If uRESULT_UserMsgHandler=0 Then
            Begin
            End;
          End;
        End;//case
      End;
    
    
    
    End;//case


  End;//with

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('DispatchMessage',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
























//=============================================================================
Function AddMenuBarItem(p_sa: AnsiString; p_b: Boolean): UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('AddMenuBarItem',SOURCEFILE);
  {$ENDIF}
  gMB.AppendItem;
  gMB.Item_lpPTR:=JFC_XXDL.create;
  gMB.Item_Id1:=0; // Don't Use
  gMB.Item_Id2:=0; // Current
  gMB.Item_saName:=p_sa; //caption
  If p_b Then
    gMB.Item_saDesc:='10000000'
  Else
    gMB.Item_saDesc:='00000000';
  Result:=gMB.Item_UID;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('AddMenuBarItem',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function RemoveMenuBarItem(p: UINT):Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('RemoveMenuBarItem',SOURCEFILE);
  {$ENDIF}

  If gMB.FoundItem_UID(p) Then
  Begin
    If gMB.Item_i8User=gMB.N Then dec(JFC_XXDL(gMB.lpItem).i8User);//If gMB.Item_i8User=gMB.N Then gMB.Item_i8User-=1;
    JFC_XXDL(gMB.Item_lpPTR).Destroy;
    gMB.DeleteItem;
    Result:=True;
  End
  Else
  Begin
    Result:=False;
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('RemoveMenuBarItem',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetMenuBarItemEnabled(p: UINT; p_b: Boolean):Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetMenuBarItemEnabled',SOURCEFILE);
  {$ENDIF}

  If gMB.FoundItem_UID(p) Then
  Begin
    If p_b Then
      JFC_XDLITEM(gMB.lpItem).saDesc[1]:='1'
    Else
      JFC_XDLITEM(gMB.lpItem).saDesc[1]:='0';
    SetMenuBarItemEnabled:=True;
  End
  Else
  Begin
    SetMenuBarItemEnabled:=False;
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetMenuBarItemEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function AddMenuPopUpItem(
  p_MBUID: UINT;
  p_sa: AnsiString;
  p_b: Boolean;
  p_UserID: UINT
): UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('AddMenuPopUpItem',SOURCEFILE);
  {$ENDIF}

  If gMB.FoundItem_UID(p_MBUID) Then
  Begin
    JFC_XXDL(gMB.Item_lpPTR).AppendItem;
    if JFC_XXDL(gMB.Item_lpPTR).Listcount=1 then JFC_XXDL(gMB.Item_lpPTR).Item_i8User:=1 else JFC_XXDL(gMB.Item_lpPTR).Item_i8User:=-1;
    JFC_XXDL(gMB.Item_lpPTR).Item_Id1:=p_MBUID;
    JFC_XXDL(gMB.Item_lpPTR).Item_Id2:=p_UserID; 
    JFC_XXDL(gMB.Item_lpPTR).Item_saName:=p_sa; //caption
    If p_b Then
      JFC_XXDL(gMB.Item_lpPTR).Item_saDesc:='10000000'
    Else
      JFC_XXDL(gMB.Item_lpPTR).Item_saDesc:='00000000';
    AddMenuPopUpItem:=JFC_XXDL(gMB.Item_lpPTR).Item_UID;
    JFC_XXDL(gMB.Item_lpPTR).MoveFirst;
  End
  Else
  Begin
    AddMenuPopUpItem:=0;  
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('AddMenuPopUpItem',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function RemoveMenuPopUpItem(p_PopUpID: UINT):Boolean;
//=============================================================================
Var bDone: Boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('RemoveMenuPopUpItem(by UserID)',SOURCEFILE);
  {$ENDIF}
  
  RemoveMenuPopUpItem:=False;
  bDone:=False;
  
  If gMB.ListCount>0 Then
  Begin
    gMB.MoveFirst;
    repeat
      If JFC_XXDL(gMB.Item_lpPTR).FoundItem_ID(p_PopUpID,2) Then
      Begin
        JFC_XXDL(gMB.Item_lpPTR).DeleteItem;
        RemoveMenuPopUpItem:=True;
        bDone:=True;
      End;
    Until (bDone) OR (not gMB.movenext);
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('RemoveMenuPopUpItem(by UserID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function RemoveMenuPopUpItem(p_MBUID,p_PopUpID: UINT):Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('RemoveMenuPopUpItem(by MBUID and PopUpUID)',SOURCEFILE);
  {$ENDIF}

  RemoveMenuPopUpItem:=False;
  If gMB.FoundItem_UID(p_MBUID) Then
  Begin
    If JFC_XXDL(gMB.Item_lpPTR).FoundItem_UID(p_PopUpID) Then
    Begin
      JFC_XXDL(gMB.Item_lpPTR).DeleteITem;
      RemoveMenuPopUpItem:=True;
    End;
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('RemoveMenuPopUpItem(by MBUID and PopUpUID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function SetMenuPopUpItemCaption(p_PopUpID: UINT;p_sa: AnsiString):Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetMenuPopUpItemCaption(by UserID)',SOURCEFILE);
  {$ENDIF}
  
  Result:=False;
  
  If gMB.ListCount>0 Then
  Begin
    gMB.MoveFirst;
    repeat
      If JFC_XXDL(gMB.Item_lpPTR).FoundItem_ID(p_PopUpID,2) Then
      Begin
        JFC_XXDL(gMB.Item_lpPTR).Item_saName:=p_sa;
        Result:=True;
      End;
    Until (Result) OR (not gMB.movenext);
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetMenuPopUpItemCaption(by UserID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function GetMenuPopUpItemCaption(p_PopUpID: UINT):AnsiString;
//=============================================================================
Const s= '?cantfind?';
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('GetMenuPopUpItemCaption(by UserID)',SOURCEFILE);
  {$ENDIF}
  
  Result:=s;
  
  If gMB.ListCount>0 Then
  Begin
    gMB.MoveFirst;
    repeat
      If JFC_XXDL(gMB.Item_lpPTR).FoundItem_ID(p_PopUpID,2) Then
      Begin
        Result:=JFC_XXDL(gMB.Item_lpPTR).Item_saName;
      End;
    Until (Result<>s) OR (not gMB.movenext);
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('GetMenuPopUpItemCaption(by UserID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function SetMenuPopUpItemEnabled(p_PopUpID: UINT;p_b: Boolean):Boolean;
//=============================================================================
Var bDone: Boolean;
    i4BookMarkN: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetMenuPopUpItemEnabled(by UserID)',SOURCEFILE);
  {$ENDIF}
  
  SetMenuPopUpItemEnabled:=False;
  bDone:=False;
  
  i4BookMarkN:=gMB.N;
  If gMB.ListCount>0 Then
  Begin
    gMB.MoveFirst;
    repeat
      If JFC_XXDL(gMB.Item_lpPTR).FoundItem_ID(p_PopUpID,2) Then
      Begin
        If p_b Then
          JFC_XDLITEM(JFC_XXDL(gMB.Item_lpPTR).lpItem).saDesc[1]:='1'
        Else
          JFC_XDLITEM(JFC_XXDL(gMB.Item_lpPTR).lpItem).saDesc[1]:='0';
        SetMenuPopUpItemEnabled:=True;
        bDone:=True;
      End;
    Until (bDone) OR (not gMB.movenext);
  End;
  gMB.FoundNth(i4BookMarkN);
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetMenuPopUpItemEnabled(by UserID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function SetMenuPopUpItemEnabled(p_MBUID,p_PopUpID: UINT;p_b:Boolean):Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetMenuPopUpItemEnabled(by MBUID and PopUpID)',SOURCEFILE);
  {$ENDIF}

  SetMenuPopUpItemEnabled:=False;
  If gMB.FoundItem_UID(p_MBUID) Then
  Begin
    If JFC_XXDL(gMB.Item_lpPTR).FoundItem_UID(p_PopUpID) Then
    Begin
      If p_b Then
        JFC_XDLITEM(JFC_XXDL(gMB.Item_lpPTR).lpItem).saDesc[1]:='1'
      Else
        JFC_XDLITEM(JFC_XXDL(gMB.Item_lpPTR).lpItem).saDesc[1]:='0';
      SetMenuPopUpItemEnabled:=True;
    End;
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('RemoveMenuPopUpItem(by MBUID and PopUpUID)',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure SetMenuVisibleFlag(p_b:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('SetMenuVisibleFlag',SOURCEFILE);
  {$ENDIF}

  If p_b<>gbMenuVisible Then
  Begin
    gbMenuVisible:=True;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('SetMenuVisibleFlag',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================







//actualpostmessage
//=============================================================================
Procedure PostMessage(Var p_rSageMsg: rtSageMsg); 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('PostMessage',SOURCEFILE);
  {$ENDIF}
  //SageLog(1,'POST MESSAGE BEGIN ----------- saSender:'+p_rSageMsg.saSender,sourcefile);
  //SageLog(1,'POST MESSAGE MSGTOTEXT :'+ MSGTOTEXT(p_rSageMsg),sourcefile);
  {$IFDEF LOGMESSAGES}
    MQ.AppendItem_XXDL(
      p_rSageMsg.lpptr,               //lpPTR
      p_rSageMsg.saSender,       //saName
      p_rSageMsg.saDescOldPackedTime,     //saDesc
      0,                 //i8User 
      p_rSageMsg.uParam1,          //ID1    (Integers)
      p_rSageMsg.uParam2,          //ID2
      p_rSageMsg.uObjType,         //ID3
      p_rSageMsg.uMsg              //ID4
    );
  {$ELSE}
    MQ.AppendItem_XXDL(
      p_rSageMsg.lpptr,               //lpPTR
      '',                             //saName
      p_rSageMsg.saDescOldPackedTime,     //saDesc
      0,                 //i8User 
      p_rSageMsg.uParam1,          //ID1    (Integers)
      p_rSageMsg.uParam2,          //ID2
      p_rSageMsg.uObjType,         //ID3
      p_rSageMsg.uMsg              //ID4
    );
  {$ENDIF}




  //If p_rSageMsg.lpptr<>MQ.Item_lpPTR Then 
  //Begin
  //  SageLog(1,'POST MESSAGE PTR DONT STICK',sourcefile);
  //End;
  
  //If p_rSageMsg.saSender<>MQ.Item_saName Then 
  //Begin
  //  SageLog(1,'POST MESSAGE NAME DONT STICK',sourcefile);
  //End;
  
  //If p_rSageMsg.saDescOldPackedTime <> MQ.Item_saDesc Then 
  //Begin
  //  SageLog(1,'POST MESSAGE saDesc DONT STICK',sourcefile);
  //End;
  
  //    0,                 //i8User 
  
  //If p_rSageMsg.uParam1<>MQ.Item_ID1 Then
  //Begin
  //  SageLog(1,'POST MESSAGE ID1  DONT STICK',sourcefile);
  //End;
  
  //If p_rSageMsg.uParam2<>MQ.Item_ID2 Then
  //Begin
  //  SageLog(1,'POST MESSAGE ID2  DONT STICK',sourcefile);
  //End;  
    
  //If p_rSageMsg.uObjType<>MQ.Item_ID3 Then
  //Begin
  //  SageLog(1,'POST MESSAGE ID3  DONT STICK',sourcefile);
  //End;
    
  //If p_rSageMsg.uMsg<>MQ.Item_ID4 Then
  //Begin
  //  SageLog(1,'POST MESSAGE ID4  DONT STICK',sourcefile);
  //End;



  //SageLog(1,'POST MESSAGE END  -----------',sourcefile);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('PostMessage',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================



////=============================================================================
//function SendMessage( p_rSageMsg: rtSageMsg): Cardinal;
////=============================================================================
////var u4Result: Cardinal;
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('SendMessage',SOURCEFILE);
//  {$ENDIF}
//  p_rSageMsg:=p_rSageMsg; // shut up compiler
//
//{  if gbLogMessages then 
//    SageLog(1,'SNDed    :' + msgtotext(p_rSageMsg));
//  u4Result:=u4SendMsgToMsgHandler(uMsg,uObjID,uParam1, uParam2,saSender);
//  if gbLogMessages then
//    SageLog(1,'SNDRec   :' + msgtotext(uMsg,uObjID,uParam1, uParam2,saSender));
//  SendMessage:=u4Result;
//}
//  SendMessage:=0;//shut up compiler
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('SendMessage',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================

//ACTUALMSGTOTEXT
//=============================================================================
Function MsgToText(Var p_rSageMsg: rtSageMsg): AnsiString;
//=============================================================================
Var sa: AnsiString;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('MsgToText',SOURCEFILE);
  {$ENDIF}
  
  //SageLog(1,'********MSGTOTEXT IN',Sourcefile);  
  p_rSageMsg:=p_rSageMsg; // shutup compiler
  //SAGELOG(1,'Starting With - uMSG='+inttostr(p_rSageMsg.uMsg),sourcefile);
  With p_rSageMsg Do Begin
    Case uMsg Of
    MSG_IDLE             : sa:='MSG_IDLE';
    MSG_FIRSTCALL        : sa:='MSG_FIRSTCALL';
    MSG_UNHANDLEDKEYPRESS: sa:='MSG_UNHANDLEDKEYPRES';
    MSG_UNHANDLEDMOUSE   : sa:='MSG_UNHANDLEDMOUSE';
    MSG_MENU             : sa:='MSG_MENU';
    MSG_SHUTDOWN         : sa:='MSG_SHUTDOWN';
    MSG_CLOSE            : sa:='MSG_CLOSE';
    MSG_DESTROY          : sa:='MSG_DESTROY';
    MSG_BUTTONDOWN       : sa:='MSG_BUTTONDOWN';
    MSG_LOSTFOCUS        : sa:='MSG_LOSTFOCUS';
    MSG_GOTFOCUS         : sa:='MSG_GOTFOCUS';
    MSG_CTLGOTFOCUS      : sa:='MSG_CTLGOTFOCUS';
    MSG_CTLLOSTFOCUS     : sa:='MSG_CTLLOSTFOCUS';
    MSG_WINDOWSTATE      : sa:='MSG_WINDOWSTATE';
    MSG_WINDOWMOVE       : sa:='MSG_WINDOWMOVE';
    MSG_WINDOWRESIZE     : sa:='MSG_WINDOWRESIZE';
    MSG_CTLSCROLLUP      : sa:='MSG_CTLSCROLLUP';
    MSG_CTLSCROLLDOWN    : sa:='MSG_CTLSCROLLDOWN';
    MSG_CTLSCROLLLEFT     : sa:='MSG_CTLSCROLLLEFT';
    MSG_CTLSCROLLRIGHT    : sa:='MSG_CTLSCROLLRIGHT';
    MSG_CHECKBOX          : sa:='MSG_CHECKBOX';
    MSG_LISTBOXMOVE       : sa:='MSG_LISTBOXMOVE';
    MSG_LISTBOXCLICK      : sa:='MSG_LISTBOXCLICK';
    MSG_LISTBOXKEYPRESS   : sa:='MSG_LISTBOXKEYPRESS';
    MSG_PAINTWINDOW       : sa:='MSG_PAINTWINDOW';
    MSG_SHOWWINDOW        : sa:='MSG_SHOWWINDOW';
    MSG_CTLKEYPRESS       : sa:='MSG_CTLKEYPRESS';
    MSG_WINPAINTVCB4CTL   : sa:='MSG_WINPAINTVCB4CTL';
    MSG_WINPAINTVCAFTERCTL: sa:='MSG_WINPAINTVCAFTERCTL';
    
    
    //MSG_THREADCREATED    : sa:='MSG_THREADCREATED';
    //MSG_THREADTERMINATED : sa:='MSG_THREADTERMINATED';
    //MSG_THREADDESTROYED  : sa:='MSG_THREADDESTROYED';
    Else
      sa:='??? MSGTOTEXT ???';
    End;//case    
    sa:=saFixedLength(sa,5,20);
    
    //SAGELOG(1,'Done With - Checking if broadcast');  
    //If lpptr=BROADCAST Then
    //Begin
    //  //SAGELOG(1,'Its a broadcast');  
    //  sa:=sa+saFixedLength('BROADCAST ',1,15);
    //End
    //Else
    //Begin
      //SAGELOG(1,'Its Not a broadcast');  
    If lpptr=nil Then
    begin
      sa:=sa+saFixedLength('PTR --NIL--',1,14);
    end  
    Else  
    begin
      sa:=sa+saFixedLength('PTR '+inttostr(UINT(lpptr)),1,14);
    end;
    //End;
    //SageLog(1,'Done Checking if broadcast - Building RESULT',sourcefile);

    //If uParam1<>0 Then
    sa:=sa+saFixedLength('P1:'+inttostr(uPAram1),1,11);
    ////sagelog(1,'res 1',sourcefile);
    //If uParam2<>0 Then
    sa:=sa+saFixedLength('P2:'+inttostr(uPAram2),1,11);
    ////sagelog(1,'res 2',sourcefile);
    //If uObjType<>0 Then
    sa:=sa+saFixedLength('OT:'+inttostr(uObjType),1,9);
    ////sagelog(1,'res 3',sourcefile);
    //If uUID<>0 Then
    sa:=sa+saFixedLength('UID:'+inttostr(uUID),1,9);
    
    //SageLog(1,'Done building RESULT',sourcefile);
  End;//with
  //sagelog(1,'Done WITH');  
  //SageLog(1,'********MSGTOTEXT OUT',sourcefile);  
  Result:=sa;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('MsgToText',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





//ACTUALOBJTOTEXT
//=============================================================================
// Just takes Object TYPE and returns name if know as text (see also msgtotext)
Function ObjToText(p_uObjType: UINT): AnsiString;
//=============================================================================
Var sa: AnsiString;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('ObjToText',SOURCEFILE);
  {$ENDIF}

  sa:='';
  Case p_uObjType Of
  OBJ_NONE                        : sa:=sa+'OBJ_NONE';
  OBJ_VCMAIN                      : sa:=sa+'OBJ_VCMAIN';                     
  OBJ_VCSTATUSBAR                 : sa:=sa+'OBJ_VCSTATUSBAR';
  OBJ_MENUBAR                     : sa:=sa+'OBJ_MENUBAR';                    
  OBJ_MENUBARPOPUP                : sa:=sa+'OBJ_MENUBARPOPUP';               
  OBJ_WINDOW                      : sa:=sa+'OBJ_WINDOW';                     
  OBJ_LABEL                       : sa:=sa+'OBJ_LABEL';                      
  OBJ_VSCROLLBAR                  : sa:=sa+'OBJ_VSCROLLBAR';                 
  OBJ_HSCROLLBAR                  : sa:=sa+'OBJ_HSCROLLBAR';                 
  OBJ_PROGRESSBAR                 : sa:=sa+'OBJ_PROGRESSBAR';                
  OBJ_INPUT                       : sa:=sa+'OBJ_INPUT';                    
  OBJ_BUTTON                      : sa:=sa+'OBJ_BUTTON';                     
  OBJ_CHECKBOX                    : sa:=sa+'OBJ_CHECKBOX';                   
  OBJ_LISTBOX                     : sa:=sa+'OBJ_LISTBOX';                   
  OBJ_TREE                        : sa:=sa+'OBJ_TREE';                       
  OBJ_VCDEBUGMESSAGES             : sa:=sa+'OBJ_VCDEBUGMESSAGES';            
  OBJ_VCDEBUGKEYPRESS             : sa:=sa+'OBJ_VCDEBUGKEYPRESS';            
  OBJ_VCDEBUGKEYBOARD             : sa:=sa+'OBJ_VCDEBUGKEYBOARD';            
  OBJ_VCDEBUGMOUSE                : sa:=sa+'OBJ_VCDEBUGMOUSE';              
  OBJ_VCDEBUGMQ                   : sa:=sa+'OBJ_VCDEBUGMQ';                  
  OBJ_VCDEBUGSTATUSBAR            : sa:=sa+'OBJ_VCDEBUGSTATUSBAR';         
  OBJ_VCDEBUGWINDOWS              : sa:=sa+'OBJ_VCDEBUGWINDOWS';
  OBJ_VCSTARANIMATION             : sa:=sa+'OBJ_VCSTARANIMATION';
//  OBJ_THREADCOMPLETEDTASK         : sa:=sa+'OBJ_THREADCOMPLETEDTASK';
  Else
    sa:='??? OBJTOTEXT ???';
  End;//case    
  sa:=saFixedLength(sa,5,16);
  Result:=sa;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('ObjToText',SOURCEFILE);
  {$ENDIF}

End;


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
// Private Class Routines and Initialization Routine Below





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//       TC Class Routines (Control List - JFC_XXDL Based)
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Destructor tc.Destroy;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.Destroy',SOURCEFILE);
  {$ENDIF}

  While ListCount>0 Do Begin
    If bPrivate Then 
      FoundItem_lpPtr(lpOwner)
    Else
      Kill;
  End;  
  Inherited;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.Destroy',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tc.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL:      Begin       TCTLLABEL(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_VSCROLLBAR: Begin  TCTLVSCROLLBAR(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_HSCROLLBAR: Begin  TCTLHSCROLLBAR(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_PROGRESSBAR:Begin TCTLPROGRESSBAR(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_INPUT:      Begin       TCTLINPUT(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_BUTTON:     Begin      TCTLBUTTON(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_CheckBox:   Begin    TCTLCheckBox(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    OBJ_ListBox:    Begin     TCTLListBox(Item_lpPTR).ProcessMouse(p_bMouseIdle);End;
    //OBJ_Tree:       begin        TCTLTree(lpGotControl).ProcessMouse(p_bMouseIdle);end;
    Else JLog(cnLog_ERROR,200902081243,'tc.ProcessMouse - Unknown Object Type',SOURCEFILE);
    End;//case
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.iMouseOnAControl: longint;
//=============================================================================
var iBookMarkN: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.iMouseOnAControl',SOURCEFILE);
  {$ENDIF}

  Result:=0;
  If ListCount>0 Then
  Begin
    iBookMarkN:=N;
    MoveFirst;
    repeat
      Case Item_ID1 Of
      OBJ_LABEL: if 
        tCtlLabel(Item_lpPTR).bEnabled and
        tCtlLabel(Item_lpPTR).bVisible and
        (rLMevent.VMX>=tCtlLabel(Item_lpPTR).i4X) and
        (rLMevent.VMX<=tCtlLabel(Item_lpPTR).i4X+tCtlLabel(Item_lpPTR).i4Width-1) and
        (rLMEvent.VMY>=tCtlLabel(Item_lpPTR).i4Y) and 
        (rLMevent.VMY<=tCtlLabel(Item_lpPTR).i4Y+tCtlLabel(Item_lpPTR).i4Height-1) then result:=Item_UID;
      
      OBJ_VSCROLLBAR: if
        tCtlVScrollBar(Item_lpPTR).bEnabled and
        tCtlVScrollBar(Item_lpPTR).bVisible and
        (rLMevent.VMX=tCtlVScrollBar(Item_lpPTR).i4X) and
        (rLMEvent.VMY>=tCtlVScrollBar(Item_lpPTR).i4Y) and 
        (rLMevent.VMY<=tCtlVScrollBar(Item_lpPTR).i4Y+tCtlVScrollBar(Item_lpPTR).i4Height-1) then result:=Item_UID;
      
      OBJ_HSCROLLBAR: if
        tCtlHScrollBar(Item_lpPTR).bEnabled and
        tCtlHScrollBar(Item_lpPTR).bVisible and
        (rLMEvent.VMX>=tCtlHScrollBar(Item_lpPTR).i4X) and 
        (rLMevent.VMX<=tCtlHScrollBar(Item_lpPTR).i4X+tCtlHScrollBar(Item_lpPTR).i4Width-1) and
        (rLMevent.VMY=tCtlHScrollBar(Item_lpPTR).i4Y)  then result:=Item_UID;

      OBJ_PROGRESSBAR: if
        tCtlProgressBar(Item_lpPTR).bEnabled and
        tCtlProgressBar(Item_lpPTR).bVisible and
        (rLMEvent.VMX>=tCtlProgressBar(Item_lpPTR).i4X) and 
        (rLMevent.VMX<=tCtlProgressBar(Item_lpPTR).i4X+tCtlProgressBar(Item_lpPTR).i4Width-1) and
        (rLMevent.VMY=tCtlProgressBar(Item_lpPTR).i4Y)  then result:=Item_UID;

      OBJ_INPUT: if
        tCtlInput(Item_lpPTR).bEnabled and
        tCtlInput(Item_lpPTR).bVisible and
        (rLMevent.VMX>=tCtlInput(Item_lpPTR).i4X) and
        (rLMevent.VMX<=tCtlInput(Item_lpPTR).i4X+tCtlInput(Item_lpPTR).i4Width) and
        (rLMEvent.VMY=tCtlInput(Item_lpPTR).i4Y)  then result:=Item_UID;
        
      OBJ_BUTTON: if
        tCtlButton(Item_lpPTR).bEnabled and
        tCtlButton(Item_lpPTR).bVisible and
        (rLMEvent.VMX>=tCtlButton(Item_lpPTR).i4X) and 
        (rLMevent.VMX<=tCtlButton(Item_lpPTR).i4X+tCtlButton(Item_lpPTR).i4Width-1) and
        (rLMevent.VMY=tCtlButton(Item_lpPTR).i4Y)  then result:=Item_UID;

      OBJ_CheckBox: if
        tCtlCheckBox(Item_lpPTR).bEnabled and
        tCtlCheckBox(Item_lpPTR).bVisible and
        (rLMEvent.VMX>=tCtlCheckBox(Item_lpPTR).i4X) and 
        (rLMevent.VMX<=tCtlCheckBox(Item_lpPTR).i4X+tCtlCheckBox(Item_lpPTR).i4Width-1) and
        (rLMevent.VMY=tCtlCheckBox(Item_lpPTR).i4Y)  then result:=Item_UID;

      OBJ_ListBox: if
        tCtlListBox(Item_lpPTR).bEnabled and
        tCtlListBox(Item_lpPTR).bVisible and
        (rLMevent.VMX>=tCtlListBox(Item_lpPTR).i4X) and
        (rLMevent.VMX<=tCtlListBox(Item_lpPTR).i4X+tCtlListBox(Item_lpPTR).i4Width-1) and
        (rLMEvent.VMY>=tCtlListBox(Item_lpPTR).i4Y) and 
        (rLMevent.VMY<=tCtlListBox(Item_lpPTR).i4Y+tCtlListBox(Item_lpPTR).i4Height-1)  then result:=Item_UID;

//      OBJ_TREE: Result:=
//        tCtlTree(DL^.PTR).bEnabled and
//        tCtlTree(DL^.PTR).bVisible and
//        (rLMevent.VMX>=tCtlTree(DL^.PTR).i4X) and
//        (rLMevent.VMX<=tCtlTree(DL^.PTR).i4X+tCtlTree(DL^.PTR).i4Width-1) and
//        (rLMEvent.VMY>=tCtlTree(DL^.PTR).i4Y) and 
//        (rLMevent.VMY<=tCtlTree(DL^.PTR).i4Y+tCtlTree(DL^.PTR).i4Height-1);
      Else JLog(cnLog_ERROR,200902081244,'tc.iMouseOnAControl - Unknown Object Type',SOURCEFILE);
      End; // case  
    // Only want First control that Meets MouseClick parameters
    Until (Result<>0) OR (not MoveNExt);
    FoundNth(iBookMarkN);
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.iMouseOnAControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tc.ProcessKeyBoard(p_u4Key:Cardinal);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
  // gbUnhandledKeypress will be set to false only when
  // a keypress is actually handled by a control.
  //If FoundNth(Item_i8User) Then
  //Begin
    Case Item_ID1 Of
    OBJ_LABEL:      Begin       tCtlLabel(Item_lpPTR).ProcessKeyBoard(p_u4Key);End;
    OBJ_VSCROLLBAR: Begin  tCtlVScrollBar(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    OBJ_HSCROLLBAR: Begin  TCTLHScrollBar(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    OBJ_PROGRESSBAR:Begin TCTLPROGRESSBAR(Item_lpPTR).ProcessKeyBoard(p_u4Key);End;
    OBJ_INPUT:      Begin       TCTLINPUT(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    OBJ_BUTTON:     Begin      TCTLBUTTON(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    OBJ_CheckBox:   Begin    TCTLCheckBox(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    OBJ_ListBox:    Begin     TCTLListBox(Item_lpPTR).ProcessKeyboard(p_u4Key);End;
    //OBJ_Tree:       begin        TCTLTree(CTL.PTR).ProcessKeyboard(p_u4Key);end;
    Else
      JLog(cnLog_ERROR,200902081245,'tc.ProcessKeyBoard - Unsupported ObjectType:'+inttostr(Item_ID1),SOURCEFILE);
    End;//case
  //End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.uObjType: UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.uObjType',SOURCEFILE);
  {$ENDIF}
  Result:=0;
  If ListCount>0 Then
  Begin
    Result:=Item_ID1;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.uObjType',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tc.bEnabled: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.bEnabled',SOURCEFILE);
  {$ENDIF}

  Result:=False;
  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :Result:=tCtlLabel(Item_lpPTR).bEnabled;  
    OBJ_VSCROLLBAR  :Result:=tCtlVScrollBar(Item_lpPTR).bEnabled;  
    OBJ_HSCROLLBAR  :Result:=tctlHScrollBar(Item_lpPTR).bEnabled;  
    OBJ_PROGRESSBAR :Result:=tctlProgressBar(Item_lpPTR).bEnabled;  
    OBJ_INPUT       :Result:=tctlInput(Item_lpPTR).bEnabled;  
    OBJ_BUTTON      :Result:=tctlButton(Item_lpPTR).bEnabled;  
    OBJ_CHECKBOX    :Result:=tctlCheckBox(Item_lpPTR).bEnabled;  
    OBJ_LISTBOX     :Result:=tctlListBox(Item_lpPTR).bEnabled;  
    //OBJ_TREE        :tctlTree(DL^.PTR).bEnabled;  
    Else
      JLog(cnLog_ERROR,200902081246,'tc.bEnabled - Unsupported ObjectType: ' +
        inttostr(Item_ID1),sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.bEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.bVisible: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.bVisible',SOURCEFILE);
  {$ENDIF}

  Result:=False;
  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :Result:=tCtlLabel(Item_lpPTR).bVisible;  
    OBJ_VSCROLLBAR  :Result:=tCtlVScrollBar(Item_lpPTR).bVisible;  
    OBJ_HSCROLLBAR  :Result:=tctlHScrollBar(Item_lpPTR).bVisible;  
    OBJ_PROGRESSBAR :Result:=tctlProgressBar(Item_lpPTR).bVisible;  
    OBJ_INPUT       :Result:=tctlInput(Item_lpPTR).bVisible;  
    OBJ_BUTTON      :Result:=tctlButton(Item_lpPTR).bVisible;  
    OBJ_CHECKBOX    :Result:=tctlCheckBox(Item_lpPTR).bVisible;  
    OBJ_LISTBOX     :Result:=tctlListBox(Item_lpPTR).bVisible;  
    //OBJ_TREE        :tctlTree(DL^.PTR).bVisible;  
    Else
      JLog(cnLog_ERROR,200902081247,'tc.bVisible - Unsupported ObjectType: ' +
                 inttostr(Item_ID1),sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.bVisible',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

////=============================================================================
//function tc.bPrivateDispatch(p_rSageMsg: rtSageMsg):boolean;
////=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('tc.bPrivateDispatch',SOURCEFILE);
//  {$ENDIF}
//
//  reSult:=false;
//  if ListCount>0 then
//  begin
//    case p_rSageMsg.uObjType of
//    OBJ_LABEL       :;
//    OBJ_VSCROLLBAR  :begin
//      if TWindow(p_rSageMsg.ptr).C.FoundItem_UID(p_rSageMsg.uParam2) then
//      begin
//        //sagelog(1,'found it');
//        case tctlVScrollBar(TWindow(p_rSageMsg.ptr).C.PTR).uOwnerObjType of
//        OBJ_LISTBOX: begin
//          tctlListBox(tctlVScrollBar(TWindow(p_rSageMsg.ptr).C.PTR).lpOwner).PrivateMessage(p_rSageMsg);
//          Result:=true;
//        end;
//        end;//case
//      end;
//    end;  
//    OBJ_HSCROLLBAR  :;  
//    OBJ_PROGRESSBAR :;
//    OBJ_INPUT       :;
//    OBJ_BUTTON      :;
//    OBJ_CHECKBOX    :;
//    OBJ_LISTBOX     :;
//    //OBJ_TREE        :;  
//    else
//      SageLog(1,'tc.bPrivateDispatch - Unsupported ObjectType: ' + 
//                 inttostr(ID[1]));
//    end;//case
//  end;
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('tc.bPrivateDispatch',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================

//=============================================================================

//=============================================================================
Function tc.bPrivate: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.bPrivate',SOURCEFILE);
  {$ENDIF}

  Result:=False;
  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :Result:=tCtlLabel(Item_lpPTR).bPrivate;  
    OBJ_VSCROLLBAR  :Result:=tCtlVScrollBar(Item_lpPTR).bPrivate;  
    OBJ_HSCROLLBAR  :Result:=tctlHScrollBar(Item_lpPTR).bPrivate;  
    OBJ_PROGRESSBAR :Result:=tctlProgressBar(Item_lpPTR).bPrivate;  
    OBJ_INPUT       :Result:=tctlInput(Item_lpPTR).bPrivate;  
    OBJ_BUTTON      :Result:=tctlButton(Item_lpPTR).bPrivate;  
    OBJ_CHECKBOX    :Result:=tctlCheckBox(Item_lpPTR).bPrivate;  
    OBJ_LISTBOX     :Result:=tctlListBox(Item_lpPTR).bPrivate;  
    //OBJ_TREE        :tctlTree(DL^.PTR).bPrivate;  
    Else
      JLog(cnLog_ERROR,200902081248,'tc.bPrivate - Unsupported ObjectType: ' +
                 inttostr(Item_ID1),sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.bPrivate',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.lpOwner: pointer;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.lpOwner',SOURCEFILE);
  {$ENDIF}

  Result:=nil;
  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :Result:=tCtlLabel(Item_lpPTR).lpOwner;  
    OBJ_VSCROLLBAR  :Result:=tCtlVScrollBar(Item_lpPTR).lpOwner;  
    OBJ_HSCROLLBAR  :Result:=tctlHScrollBar(Item_lpPTR).lpOwner;  
    OBJ_PROGRESSBAR :Result:=tctlProgressBar(Item_lpPTR).lpOwner;  
    OBJ_INPUT       :Result:=tctlInput(Item_lpPTR).lpOwner;  
    OBJ_BUTTON      :Result:=tctlButton(Item_lpPTR).lpOwner;  
    OBJ_CHECKBOX    :Result:=tctlCheckBox(Item_lpPTR).lpOwner;  
    OBJ_LISTBOX     :Result:=tctlListBox(Item_lpPTR).lpOwner;  
    //OBJ_TREE        :tctlTree(PTR).lpOwner;  
    Else
      JLog(cnLog_ERROR,200902081249,'tc.lpOwner - Unsupported ObjectType: ' +
                 inttostr(Item_ID1), sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.lpOwner',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.uOwnerObjType: UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.uOwnerObjType',SOURCEFILE);
  {$ENDIF}

  Result:=0;
  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :Result:=tCtlLabel(Item_lpPTR).uOwnerObjType;
    OBJ_VSCROLLBAR  :Result:=tCtlVScrollBar(Item_lpPTR).uOwnerObjType;
    OBJ_HSCROLLBAR  :Result:=tctlHScrollBar(Item_lpPTR).uOwnerObjType;
    OBJ_PROGRESSBAR :Result:=tctlProgressBar(Item_lpPTR).uOwnerObjType;
    OBJ_INPUT       :Result:=tctlInput(Item_lpPTR).uOwnerObjType;
    OBJ_BUTTON      :Result:=tctlButton(Item_lpPTR).uOwnerObjType;
    OBJ_CHECKBOX    :Result:=tctlCheckBox(Item_lpPTR).uOwnerObjType;
    OBJ_LISTBOX     :Result:=tctlListBox(Item_lpPTR).uOwnerObjType;
    //OBJ_TREE        :tctlTree(PTR).uOwnerType;
    Else
      JLog(cnLog_ERROR,200902081250,'tc.uOwnerType - Unsupported ObjectType: ' +
                 inttostr(Item_ID1),sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.uOwnerObjType',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.Read_bRedraw: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.Read_bRedraw',SOURCEFILE);
  {$ENDIF}
  Result:=False;
  If ListCount>0 Then
  Begin
    Result:=(Item_ID2 and Integer(B00)) = B00;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.Read_bRedraw',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tc.Write_bRedraw(p_bRedraw:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.Write_bRedraw',SOURCEFILE);
  {$ENDIF}
  If ListCount>0 Then
  Begin
    Item_ID2:=(Item_ID2 and (Integer($0FFFFFFF)-Integer(B00)) );
    If p_bRedraw Then JFC_XXDLItem(lpItem).ID[2]+=Integer(B00);
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.Write_bRedraw',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tc.bCanGetFocus: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.bCanGetFocus',SOURCEFILE);
  {$ENDIF}
  Result:=False;
  If ListCount>0 Then
  Begin
    If bObjGetsFocus(Item_ID1) Then
    Begin
      //SageLog(1,'tc.bCanGetFocus DL^.PTR=DL^.PTR? ->'+saTrueFalse(DL^.PTR=DL^.PTR));
      Case Item_ID1 Of
      OBJ_LABEL       :Result:=
        tCtlLabel(Item_lpPTR).bEnabled and
        tCtlLabel(Item_lpPTR).bVisible;
      OBJ_VSCROLLBAR  :Result:=
        tCtlVScrollBar(Item_lpPTR).bEnabled and
        tCtlVScrollBar(Item_lpPTR).bVisible;  
      OBJ_HSCROLLBAR  :Result:=
        tctlHScrollBar(Item_lpPTR).bEnabled and  
        tctlHScrollBar(Item_lpPTR).bVisible;
      OBJ_PROGRESSBAR :Result:=
        tctlProgressBar(Item_lpPTR).bEnabled and
        tctlProgressBar(Item_lpPTR).bVisible;  
      OBJ_INPUT       :Result:=
        tctlInput(Item_lpPTR).bEnabled and
        tctlInput(Item_lpPTR).bVisible;  
      OBJ_BUTTON      :Result:=
        tctlButton(Item_lpPTR).bEnabled and
        tctlButton(Item_lpPTR).bVisible;  
      OBJ_CHECKBOX    :Result:=
        tctlCheckBox(Item_lpPTR).bEnabled and
        tctlCheckBox(Item_lpPTR).bVisible;  
      OBJ_LISTBOX     :Result:=
        tctlListBox(Item_lpPTR).bEnabled and
        tctlListBox(Item_lpPTR).bVisible;  
      //OBJ_TREE        :Result:=
      //  tctlTree(DL^.PTR).bEnabled and
      //  tctlTree(DL^.PTR).bVisible;  
      Else
        JLog(cnLog_ERROR,200902081251,'tc.uOwnerType - Unsupported ObjectType: ' +
                   inttostr(Item_ID1),sourcefile);
      End;//case
    End;
  End;
 
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.bCanGetFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tc.Kill;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.Kill',SOURCEFILE);
  {$ENDIF}

  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       :tCtlLabel(Item_lpPTR).Destroy;  
    OBJ_VSCROLLBAR  :tCtlVScrollBar(Item_lpPTR).Destroy;  
    OBJ_HSCROLLBAR  :tctlHScrollBar(Item_lpPTR).Destroy;  
    OBJ_PROGRESSBAR :tctlProgressBar(Item_lpPTR).Destroy;  
    OBJ_INPUT       :tctlInput(Item_lpPTR).Destroy;  
    OBJ_BUTTON      :tctlButton(Item_lpPTR).Destroy;  
    OBJ_CHECKBOX    :tctlCheckBox(Item_lpPTR).Destroy;  
    OBJ_LISTBOX     :tctlListBox(Item_lpPTR).Destroy;  
    //OBJ_TREE        :tctlTree(DL^.PTR).Destroy;  
    Else
      JLog(cnLog_ERROR,200902081252,'tc.Kill - Unsupported ObjectType: ' +
                 inttostr(Item_ID1),sourcefile);
    End;//case
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.Kill',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tc.paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tc.paintcontrol',SOURCEFILE);
  {$ENDIF}

  If ListCount>0 Then
  Begin
    Case Item_ID1 Of
    OBJ_LABEL       : tCtlLabel(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_VSCROLLBAR  : tCtlVScrollBar(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_HSCROLLBAR  : tctlhScrollBar(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_PROGRESSBAR : tctlprogressbar(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_INPUT       : tctlinput(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_BUTTON      : tctlbutton(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_CHECKBOX    : tctlcheckbox(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    OBJ_LISTBOX     : tctlListBox(Item_lpPTR).PaintControl(p_bWindowHasFocus,p_bPaintWithFocusColors);
    //OBJ_TREE        : tctlTree(CTL.DL^.PTR).PaintControl(p_bGotFocus);
    Else
      JLog(cnLog_ERROR,200902081253,'tc.paintcontrol - Unsupported ObjectType: ' +
                 inttostr(Item_ID1),sourcefile);
    End;//case
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tc.paintcontrol',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
















//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TWindow Class Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor TWindow.create(p_RCW: rtCreateWindow);
//=============================================================================
Var //uOldW: Cardinal;
//    rSageMsg: rtSageMsg;
    
    
    //debug
    //iNewVCValue: Integer;
    iMyNewVC: Integer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.create',SOURCEFILE);
  {$ENDIF}

  // Copy Global Default Window Colors
  u1FrameFG:=        gu1FrameFG         ;
  u1FrameBG:=        gu1FrameBG         ;
  u1FrameCaptionFG:= gu1FrameCaptionFG  ;
  u1FrameCaptionBG:= gu1FrameCaptionBG  ;
  u1FrameWindowFG:=  gu1FrameWindowFG   ;
  u1FrameWindowBG:=  gu1FrameWindowBG   ;
  u1FrameSizeFG:=    gu1FrameSizeFG     ;
  u1FrameSizeBG:=    gu1FrameSizeBG     ;
  u1FrameDragFG:=    gu1FrameDragFG     ;
  u1FrameDragBG:=    gu1FrameDragBG     ;

  bRedraw:=True;
  
  rW:=p_rCW;
  i4MinX:=0; 
  i4MinY:=0;
  C:=TC.create;
  i4ControlWithFocusUID:=0;

  //iNewVCValue:=uNewVCObject(rw.Width, rw.height, OBJ_WINDOW, self);
  iMyNewVC:=uNewVCObject('WinVC Caption:'+rw.saCaption,rw.Width, rw.height, OBJ_WINDOW, self);
  If OBJECTSXXDL.FoundItem_ID(iMyNewVC,2) Then  
  Begin
    SELFOBJECTITEM:=JFC_XXDLITEM(OBJECTSXXDL.lpItem);
  End;
  SELFOBJECTITEM.ID[1]:=INT(rW.lpfnWndProc);

  ////LOGcnLog__DEBUG,0,'iNewVCValue Coming in from uNewVCObject:'+inttostr(iNewVCValue) +
  //' How it looks on OBJECTSXXDL.Item_ID2:'+inttostr(OBJECTSXXDL.Item_ID2)+
  //' How It Looks in Window SELFOBJECTITEM.ID[2]:'+inttostr(SELFOBJECTITEM.ID[2]),SOURCEFILE);
  

  VCSetVisible(False);
  VCSetCursorType(crHidden);
  CalcRelativeSize;

  

//  // Switch Focus?

  //uOldW:=gi4WindowHasFocusUID;
  //gi4WindowHasFocusUID:=OBJECTSXXDL.Item_UID;  
  //grGfxOps.bUpdateZOrder:=True;      
  //If OBJECTSXXDL.FoundItem_UID(uOldW) Then
  //Begin
  //  TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).bRedraw:=True;
  //End;
  //bRedraw:=True;

  
  //If OBJECTSXXDL.FoundItem_UID(uOldW) Then
  //Begin
  //  TWindow(JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR).bRedraw:=True;
  //  // TODO: Possibly Double "LOST FOCUS". See ChangeWindowFocus (Forard: TRUE) or something like that
  //  With rSageMsg Do Begin
  //    lpPTR:=JFC_XXDLITEM(OBJECTSXXDL.lpItem).lpPTR;
  //    uMsg:=MSG_LOSTFOCUS;
  //    uParam1:=0;
  //    uParam2:=0;
  //    uObjType:=OBJ_WINDOW;
  //    {$IFDEF LOGMESSAGES}
  //    saSender:='TWindow.create (LOsT FOCUS) (1):' + MSGTOTEXT(rSageMsg);
  //    {$ENDIF}
  //  End;//with
  //  //If rSageMsg.uMSG<>MSG_FIRSTCALL Then
  //  //Begin
  //    PostMessage(rSageMsg); 
  //  //End;
  //End;
  
  //OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID);

  //With rSageMsg Do Begin
  //  lpPTR:=self;
  //  uMsg:=MSG_SHOWWINDOW;
  //  uParam1:=0;
  //  uParam2:=0;
  //  uObjType:=OBJ_WINDOW;
  //  {$IFDEF LOGMESSAGES}
  //  saSender:='TWindow.create (got_focus) (2):' + MSGTOTEXT(rSageMsg);
  //  {$ENDIF}
  //End;//with
  ////If rSageMsg.uMSG<>MSG_FIRSTCALL Then
  //PostMessage(rSageMsg); 

  
  
  
  
  
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor TWindow.Destroy;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Destroy',SOURCEFILE);
  {$ENDIF}
  
  C.Destroy;
  RemoveVCObject(SELFOBJECTITEM.ID[2]);// Removes off object list also.
  gi4WindowHasFocusUID:=0;

  Inherited;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Destroy',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.i4MinimizedWidth: LongInt;
//=============================================================================
Var i4Result: LongInt;
    i4WidthWCaption: LongInt;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.i4MinimizedWidth',SOURCEFILE);
  {$ENDIF}
  
  i4Result:=0;
  If rW.bCaption Then i4result+=1;
  If rW.bMinimizeButton Then i4result+=1;
  If rW.bMaximizeButton Then i4result+=1;
  If rW.bCloseButton Then i4result+=1;
  
  If rW.bCaption Then
  Begin
    i4WidthWCaption:=(length(rw.saCaption)+2+i4Result);
    If i4WidthWCaption>22 Then
    Begin
      i4Result:=22;
    End
    Else
    Begin
      i4Result:=i4WidthWCaption;
    End;
  End;
  i4MinimizedWidth:=i4Result;      
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.i4MinimizedWidth',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure TWindow.PaintWindow;
//=============================================================================
Var 
  t:LongInt;
  rSageMsg: rtSageMsg;
  bWinGotFocus: boolean;
  bPaintControlWithFocusColors: boolean;

  i4BookMarkCtl: longint;
  i4CtlPaintBookMarkN: longint;  
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.PaintWindow',SOURCEFILE);
  {$ENDIF}
  
  {$IFDEF DEBUGPAINTWINDOW}
    //Log(cnLog_Debug,201003040040,'SECTION 100 - Painting WINDOW',SOURCEFILE);
    JLog(cnLog_Debug,201103040041,
     ' UID:'+inttostr(UINT(SELFOBJECTITEM.UID))+
     ' PTR:'+inttostr(UINT(SELFOBJECTITEM.lpPTR)),
     sourcefile
    );
    JLog(cnLog_Debug,201103040043, 'BEGIN ===========WINDOW=========',SOURCEFILE);
    JLog(cnLog_Debug,201103040045, 'saName: '+self.rw.saName,SOURCEFILE);
    JLog(cnLog_Debug,201103040046, 'saCaption: '+self.rw.saCaption,SOURCEFILE);
    JLog(cnLog_Debug,201103040047, 'X:               '+inttostr(self.rw.X),SOURCEFILE);
    JLog(cnLog_Debug,201103040048, 'Y:               '+inttostr(self.rw.Y),SOURCEFILE);
    JLog(cnLog_Debug,201103040049, 'Width:           '+inttostr(self.rw.Width),SOURCEFILE);
    JLog(cnLog_Debug,201103040050, 'Height:          '+inttostr(self.rw.Height),SOURCEFILE);
    JLog(cnLog_Debug,201103040051, 'bFrame:          '+saYesNo(self.rw.bFrame),SOURCEFILE);
    JLog(cnLog_Debug,201103040052, 'WindowState:     '+inttostr(self.rw.WindowState),SOURCEFILE);
    JLog(cnLog_Debug,201103040053, 'bCaption:        '+saYesNo(self.rw.bCaption),SOURCEFILE);
    JLog(cnLog_Debug,201103040054, 'bMinimizeButton: '+saYesNo(self.rw.bMinimizeButton),SOURCEFILE);
    JLog(cnLog_Debug,201103040055, 'bMaximizeButton: '+saYesNo(self.rw.bMaximizeButton),SOURCEFILE);
    JLog(cnLog_Debug,201103040056, 'bCloseButton:    '+saYesNo(self.rw.bCloseButton),SOURCEFILE);
    JLog(cnLog_Debug,201103040057, 'bSizable:        '+saYesNo(self.rw.bSizable),SOURCEFILE);
    JLog(cnLog_Debug,201103040058, 'bVisible:        '+saYesNo(self.rw.bVisible),SOURCEFILE);
    JLog(cnLog_Debug,201103040059, 'bEnabled:        '+saYesNo(self.rw.bEnabled),SOURCEFILE);
    JLog(cnLog_Debug,201103040060, 'bAlwaysOnTop:    '+saYesNo(self.rw.bAlwaysOnTop),SOURCEFILE);
    JLog(cnLog_Debug,201103040061, 'lpfnWndProc:     '+inttostr(UINT(self.rw.lpfnWndProc)),SOURCEFILE);
    JLog(cnLog_Debug,201103040044, 'END   ===========WINDOW=========',SOURCEFILE);
  {$ENDIF}


  {$IFDEF DEBUGPAINTWINDOW} 
    jlog(cnLog_DEBUG,201202010010,'debug paintwindow update console flag set',sourcefile);
  {$ENDIF}
   //grGfxOps.bUpdateConsole:=True;
   {$IFDEF DEBUGTRACKGFXOPS}
   //JLOG(cnLog_Debug,201003040235,'grGfxOps - TWindow.PaintWindow on entry',SOURCEFILE);
   {$ENDIF}
   bWinGotFocus:=(JFC_XXDLITEM(SELFOBJECTITEM).UID=gi4WindowHasFocusUID);
   i4BookMarkCtl:=C.N;

  //---Query Status Bar's gVC
  //SageLog(1,'----------------Begin Paintwindow Status Bar gVC Query-----');
  //SetActiveVC(guVCStatusBar);
  //Sagelog(1,'guVCStatusBar:'+inttostr(guVCStatusBar));
  //SageLog(1,'VCGetY:'+inttostr(VCGetY));
  //SageLog(1,'VCWidth:'+inttostr(VCWidth));
  //SageLog(1,'VCHeight:'+inttostr(VCHeight));





  // this code works providing status bar is still console width,
  // and exists at the bottom of the screen.
  //  bSBVisible:=(VCGetVisible) and
  //              (((giConsoleHeight-VCHeight)-1) <= VCGetY) and
  //              (VCgetX=1) and (giConsoleWidth=VCWidth);
  //  if bSBVisible then i4Su1:=VCGetY else i4Su1:=0;
  
  //SageLog(1,'VCGetVisible:'+saTrueFalse(VCGetVisible));
  //sagelog(1,'(((giConsoleHeight-VCHeight)-1) <= VCGetY):'+saTrueFalse((((giConsoleHeight-VCHeight)-1) <= VCGetY)));
  //SageLog(1,'VCGetX:'+inttostr(VCGetX));
  //SageLog(1,'i4Su1:'+inttostr(i4Su1));
  



  

  //SageLog(1,'Trying to Set VCUID:'+inttostr(VCUID));
  //  SetActiveVC(VCUID);
  //SageLog(1,'----------------End  Paintwindow Status Bar gVC Query-----');
  //---Destroy Query


  VCSetCursorType(crHidden);  


  //{IFDEF DEBUGPAINTWINDOW} jlog(cnLog_debug,200609211316,'debug paintwindow Deciding how to draw window ',sourcefile);{ENDIF}
      

  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040040,'SECTION 300 (Deciding how to draw the window (Commented out code for menu bar in here))',SourceFile);
  {$ENDIF}
  CalcRelativeSize;
  {$IFDEF DEBUGPAINTWINDOW}
    JLog(cnLog_Debug,201003040040,'SECTION 301 After CalcRelativeSize',SourceFile);
  {$ENDIF}
  SetActiveVC(SELFOBJECTITEM.ID[2]);
  {$IFDEF DEBUGPAINTWINDOW}
    JLog(cnLog_Debug,201003040040,'SECTION 302 After SetActiveVC',SourceFile);
  {$ENDIF}
  i4BCloseX:=0; i4BMinX:=0; i4BMaxX:=0;
  // Size Window Correctly for Window State
  Case rw.WindowState Of 
  WS_MINIMIZED: Begin
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040040,'SECTION 303 Minimized - VCResize Is Next',SourceFile);
    {$ENDIF}
    VCResize(22, 2);
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040040,'SECTION 304 Minimized - VCResize Back From',SourceFile);
    {$ENDIF}
    If (i4MinX=0) and (grMSC.uCMD<>MSC_WINDOWDRAG) Then
    Begin
      If (giVCStatusBarLastKnownYPos<>0) and (gi4NextMinY>=(giVCStatusBarLastKnownYPos+3)) Then gi4NextMinY:=giVCStatusBarLastKnownYPos+3;
      i4MinX:=gi4NextMinX;
      i4MinY:=gi4NextMinY;
      gi4NextMinX-=20;
      If gi4NextMinX<1 Then
      Begin
        gi4NextMinX:=(((giConsoleWidth Div 20)*20)-20)+(giConsoleWidth Mod 20)+1;
        gi4NextMinY-=1;
        If gi4NextMinY<=gi4MenuHeight Then
        If gi4NextMinY<=1 Then  
        Begin
          gi4NextMinX:=(((giConsoleWidth Div 20)*20)-20)+(giConsoleWidth Mod 20)+1;
          If giVCStatusBarLastKnownYPos<>0 Then
          Begin
            gi4NextMinY:=giVCStatusBarLastKnownYPos+3
          End
          Else
          Begin
            gi4NextMinY:=giConsoleHeight;
            //giConsoleHeight;
          End;
        End
      End;
    End;
  End;
  {WS_NORMAL: begin
    VCResize(i4RWidth+2, i4RHeight+1) // Allow room for shadow
  End;
  }
  WS_NORMAL: Begin
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040040,'VCResize Is Next',SourceFile);
    {$ENDIF}
    VCResize(i4RWidth+2, i4RHeight+1);
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040040,'VCResize Completed',SourceFile);
    {$ENDIF}
  end;
  //WS_MAXIMIZED: VCResize(i4RWidth+2, i4RHeight+1); // Allow room for shadow
  WS_MAXIMIZED: Begin
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040040,'SECTION 3110 Maximized - VCResize Is Next',SourceFile);
      JLog(cnLog_Debug,201202012332,'MAXIMIZED begin',SOURCEFILE);
      JLog(cnLog_Debug,201202012334,'giConsoleHeight:'+ inttostr(giConsoleHeight)+' giConsoleWidth:'+inttostr(giConsoleWidth),SOURCEFILE);
      JLog(cnLog_Debug,201202012335,'gi4MenuHeight:'+inttostr(gi4MenuHeight),SOURCEFILE);
      JLog(cnLog_Debug,201202012336,'giVCStatusBarLastKnownYPos:'+inttostr(giVCStatusBarLastKnownYPos),SOURCEFILE);
      JLog(cnLog_Debug,201202012333,'(giConsoleHeight-gi4MenuHeight)-(giConsoleHeight-giVCStatusBarLastKnownYPos)='+
        inttostr((giConsoleHeight-gi4MenuHeight)-(giConsoleHeight-giVCStatusBarLastKnownYPos)),SOURCEFILE);
      JLog(cnLog_Debug,201202012337,'VCHeight:'+inttostr(VCHeight),SOURCEFILE);
    {$ENDIF}
    // VCResize(i4RWidth+2, i4RHeight+1);
    bReDraw:=VCHeight<>(giConsoleHeight-gi4MenuHeight-(giConsoleHeight-giVCStatusBarLastKnownYPos));
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040041,'bRedraw: '+saYesNo(bRedraw),SourceFile);
    {$ENDIF}
    if(giVCStatusBarLastKnownYPos>0)then
    begin
      VCResize(giConsoleWidth+2, (giConsoleHeight-gi4MenuHeight)-(giConsoleHeight-giVCStatusBarLastKnownYPos));
    end
    else
    begin
      VCResize(giConsoleWidth+2, giConsoleHeight-gi4MenuHeight);
    end;
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201003040042,'SECTION 3115 Maximized - VCResize Complete',SourceFile);
    {$ENDIF}
    //VCSetXY(1,1+gi4MenuHeight);
    {$IFDEF DEBUGPAINTWINDOW}
      JLog(cnLog_Debug,201202012331,'MAXIMIZED end',SOURCEFILE);
    {$ENDIF}
  End;

  End;// case


  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040043,'SECTION 400 - Setting Params for drawing in VC of window',SourceFile);
  {$ENDIF}
  // Prepare gVC for Behavior consistant with Window
  grVCInfo:=VCGetInfo;
  With grVCInfo Do Begin
    // Height and Width of Virtual Screen
    //VW:=VW; // (No Default - You Must In NewVC Call)
    //VH:=VH; // (No Default - You Must In NewVC Call)
    
    // Pen Coords - One Based
    //tx:=VPX; // (Default: 1)
    //ty:=VPY; // (Default: 1)
  
    // Toggles whether Writing Past the Width of the gVC makes the cursor
    // drop to the next line. Has no bearing on VCPut commands, just VCWrite stuff
    VWrap:=False; // (Default: True)
  
    // Tabsize - Only has effect when VCWrit'n with the pen
    //VTabSize:=VTabSize; // (Default: 8)
  
    // Toggles AutoCursor Tracking. The Cursor Follows the Pen when using VCWrite
    VTrackCursor:=False; //(Default: True)
  
    // Blinky  Coords - One Based
    //VCX:=VCX; // (Default: 1)
    //VCY:=VCY; // (Default: 1)
    // The Blinky Cursor Types: crUnderline, crHidden, crBlock, crHalfBlock
    //VCursorType:=VCursorType; // (Default:  crUnderline)
    
    // Toggles Auto Scroll - Which scrolls the gVC's contents up if while using
    // VCWrite commands you either wrote past the bottom right hand corner of the 
    // gVC (if VWrap is set to true) or if a Linefeed (Ascii #10) is encountered.
    VScroll:=False; // (Default: True)
  
    // Scrolling Region X,Y,gW,H (One Based)- MUST Be entirely within gVC.
    //VSX:=VSX; // (Default: 1)
    //VSY:=VSY; // (Default: 1)
    //VSW:=VSW; // (Default: VCWidth  -See VW Field of this record)
    //VSH:=VSH; // (Default: VCHeight -See VH Field of this record)
  
    // Toggles whether gVC is Hidden or not
    VVisible:=rW.bVisible; // (Default: True)
  
    // Toggles whether characters in the gVC with Ascii Value Zero makes those
    // cells transparent or not. 
    VTransparency:=True; // (Default: False)
  
    // Toggles Ability to allow Characters of whatever is underneath gVC to show
    //VOpaqueCh:=VOpaqueCh; // (Default: True)
    // Toggles Ability to allow FG color of whatever is underneath gVC to show 
    //VOpaqueFG:=VOpaqueFG; // (Default: True)
    // Toggles Ability to allow BG color of whatever is underneath gVC to show 
    //VOpaqueBG:=VOpaqueBG;//  (Default: True)
  
    // Note: Having Transparency Set To TRUE while All cell's characters set
    //       to ASCII ZERO will render the gVC Invisible - Not hidden.
    //       The same is true for Setting All VCOpaque flags to False.
    //       These are not the most efficient ways to hide a gVC. Just set
    //       to hidden for optimal performance.
  End;
  vcsetinfo(grVCInfo);


  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040045,'SECTION 500 - If bRedraw do ... yada yada',SourceFile);
  {$ENDIF}
  If bRedraw Then
  Begin
    If bWinGotFocus Then
    begin
      VCSetFGC(u1FrameWindowFG);
    end
    Else
    begin
      VCSetFGC(gu1NoFocusFG);
    end;
    VCSetBGC(u1FrameWindowBG);
    If rw.bframe Then
    begin
      if rw.WindowState=WS_MAXIMIZED then
      begin
        VCFillBox(2,2,VCWidth-4,VCHeight-1,' ');
      end
      else
      begin
        VCFillBox(2,2,VCWidth-4,VCHeight-3,' ');
      end;
    end
    Else
    begin
      VCFillBox(1,1,VCWidth-2,VCHeight-1,' ');
    end;
  End;

  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040046,'SECTION 600 - Paint Controls',SourceFile);
  {$ENDIF}
  // Begin ------------------------------------------------Paint Controls
  If rw.WindowState<>WS_MINIMIZED Then
  Begin
    With rSageMsg Do Begin
      lpPtr:=self;
      uMsg   := MSG_WINPAINTVCB4CTL;
      uParam1:= 0;
      uParam2:= 0;
      uObjType:= OBJ_WINDOW;
      //lpptr:=;
      {$IFDEF LOGMESSAGES}
      saSender:='';
      {$ENDIF}
      saDescOldPackedTime:='';
      //uUID:=0;
    End;//with
    DispatchMessage(rSageMsg);

    SetActiveVC(SELFOBJECTITEM.ID[2]);
    If C.ListCount>0 Then
    Begin
      C.MoveFirst;
      repeat 
        If (bRedraw) OR (C.bRedraw) OR ((C.uObjType=OBJ_INPUT) and (C.Item_UID=i4ControlWithFocusUID)) Then
        Begin
          bPaintControlWithFocusColors:=  
            (C.Item_UID=self.i4ControlWithFocusUID) or
            (C.uObjType=OBJ_VSCROLLBAR) or
            (C.uObjType=OBJ_HSCROLLBAR) or
            (C.uObjType=OBJ_PROGRESSBAR);
          
          i4CtlPaintBookMarkN:=C.N;
          C.PaintControl(bWinGotFocus, bPaintControlWithFocusColors);
          C.FoundNth(i4CtlPaintBookMarkN);
          C.bRedraw:=false;
        End;
      Until not C.MoveNext;
      //JLog(cnLog_Debug,201003080112,'Verifying Left Control Paint Loop',SourceFile);
    End;
    
    SetActiveVC(SELFOBJECTITEM.ID[2]);
    With rSageMsg Do Begin
      lpPtr:=self;
      uMsg   :=MSG_WINPAINTVCAFTERCTL;
      uParam1:= 0;
      uParam2:= 0;
      uObjType:= OBJ_WINDOW;
      //lpptr:=;
      {$IFDEF LOGMESSAGES}
      saSender:='';
      {$ENDIF}
      saDescOldPackedTime:='';
      //uUID:=0;
    End;//with
    DispatchMessage(rSageMsg);
    SetActiveVC(SELFOBJECTITEM.ID[2]);
  End;
  // End   ------------------------------------------------Paint Controls


  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040047,'SECTION 700 - Set VC According to WindowState',SourceFile);
  {$ENDIF}
  // Virtual Screen coords Relative to Real Video Screen-One Based
  Case rw.WindowState Of
  WS_MINIMIZED: VCSetXY(i4MinX,i4MinY);
  WS_NORMAL:    VCSetXY(rW.X,rW.Y);
  WS_MAXIMIZED: VCSetXY(1,1+gi4MenuHeight);
  //WS_MAXIMIZED: VCSetXY(1,1);
  End; //case
  // Pen Foreground And Background Colors






      

  {$IFDEF DEBUGPAINTWINDOW} 
    JLog(cnLog_Debug,201003040048,'SECTION 800 - Frame Draw',SourceFile);
  {$ENDIF}
  // Begin --------------------------------------------------- Frame Draw
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  
  If rw.bFrame Then
  Begin
    // Begin ----------------------------------------- Top of Frame
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211318,'debug paintwindow Draw Top of frame',sourcefile);{$ENDIF}
    PvtSetFrameColors;
    //VCSetPenXY(tx,ty);
    VCSetPenXY(1,1);
    If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
    Begin
      VCWrite(StringOfChar(gchFrameSHorizontal,VCWidth-3));
    End
    Else
    Begin
      VCWrite(StringOfChar(gchFrameFHorizontal,VCWidth-3));
    End;
    
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211318,'debug paintwindow Draw topleftcorner',sourcefile);{$ENDIF}
    // Draw Top Left Corner Appropriate for Normal and Minimized
    VCSetPenXY(1,1);
    Case rw.WindowState Of 
    WS_MINIMIZED: Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSCloseCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFCloseCaption);
      End;
    End;
    WS_NORMAL,WS_MAXIMIZED: Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSTopLeft);
      End
      Else
      Begin
        VCWrite(gchFrameFTopLeft);
      End;
    End;
    End;// case

    // Draw Caption (Part #1)
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211319,'debug paintwindow  Draw Caption part 1',sourcefile);{$ENDIF}
    If rW.bCaption and (length(rW.saCaption)>0) Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSOpenCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFOpenCaption);
      End;
      If bWinGotFocus Then 
        VCsetFGC(u1FrameCaptionFG)
      Else
        VCSetFGC(gu1NoFocusFG);
      VCSetBGC(u1FrameCaptionBG);
      VCWrite(saFixedLength(' ' + rW.saCaption, 1, VCWidth-VCGetPenX-2));
    End;
    
    
    // Draw Top Right Corner
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211320,'debug paintwindow  Draw Top Right Corner',sourcefile);{$ENDIF}
    pvtSetFrameColors;
    VCSetPenXY(VCWidth-2, 1);
    If rW.WindowState=WS_MINIMIZED Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSOpenCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFOpenCaption);
      End;
    End
    Else
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSTopRight);
      End
      Else
      Begin
        VCWrite(gchFrameFTopRight);
      End;
    End;
    // Right Transparent
    VCWrite(#0+#0);
    VCRedrawCell(VCWidth,1);
    VCRedrawCell(VCWidth-1,1);
    VCSetPenXY(VCWidth-3,1); // Prepare Pen For next item (button or not)
    
    // Draw Close Button
    {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211320,'debug paintwindow  Draw Close Button',sourcefile);{$ENDIF}
    If rW.bCloseButton Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSCloseCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFCloseCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
      If bWinGotFocus Then
        VCSetFGC(u1FrameCaptionFG)
      Else
        VCSetFGC(gu1NoFocusFG);
      VCSetBGC(u1FrameCaptionBG);
      i4BCloseX:=VCGetPenX;
      //SageLog(1,'CloseX:'+inttostr(CloseX));
      VCWrite('X');
      VCSetPenXY(VCGetPenX-2, 1);
      pvtSetFrameColors;
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSOpenCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFOpenCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
    End;  
    
    // Draw Maximize Button    
    {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211318,'debug paintwindow Draw Maximize button',sourcefile);{$ENDIF}
    If rW.bMaximizeButton Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSCloseCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFCloseCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
      If bWinGotFocus Then
        VCSetFGC(u1FrameCaptionFG)
      Else
        VCSetFGC(gu1NoFocusFG);
      VCSetBGC(u1FrameCaptionBG);
      i4BMaxX:=VCGetPenX;
      Case rw.WindowState Of 
      WS_NORMAL, WS_MINIMIZED: Begin
        VCWrite(gchFrameUp); // Up Arrow
      End;
      WS_MAXIMIZED: Begin
        VCWrite(gchFrameRestore)//little horizontal 3 lines thing
      End;
      End;// case
      VCSetPenXY(VCGetPenX-2, 1);
      pvtSetFrameColors;
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSOpenCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFOpenCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
    End;  
        
    // Draw Minimize Button
    {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211321,'debug paintwindow Draw Minimize button',sourcefile);{$ENDIF}
    If rW.bMinimizeButton Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSCloseCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFCloseCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
      If bWinGotFocus Then
        VCSetFGC(u1FrameCaptionFG)
      Else
        VCSetFGC(gu1NoFocusFG);
      VCSetBGC(u1FrameCaptionBG);

      i4BMinX:=VCGetPenX;
      Case rw.WindowState Of 
      WS_MINIMIZED: Begin
        //VCWrite(#24)//little up arrow
        VCWrite(gchFrameRestore)//little horizontal 3 lines thing
      End;
      WS_NORMAL,WS_MAXIMIZED: Begin
        VCWrite(gchFrameDown); // Down Arrow
      End;
      End;// case
      
      VCSetPenXY(VCGetPenX-2, 1);
      pvtSetFrameColors;
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSOpenCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFOpenCaption);
      End;
      VCSetPenXY(VCGetPenX-2, 1);
    End;  
      
    // Draw Caption (part 2) Finishes caption Work
    If rW.bCaption and (length(rW.saCaption)>0) Then
    Begin
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSCloseCaption);
      End
      Else
      Begin
        VCWrite(gchFrameFCloseCaption);
      End;
    End;
    // End ----------------------------------------- Top of Frame
  End // has frame    
  Else
  Begin
    {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211322,'debug paintwindow Draw Non-frame top of window I think ',sourcefile);{$ENDIF}
    VCSetPenXY(VCWidth-1, 1);
    VCWrite(#0+#0);
    VCRedrawCell(VCWidth,1);
    VCRedrawCell(VCWidth-1,1);
  End;
  
  // Begin --------------------------------------- Middle of Frame
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211323,'debug paintwindow Draw Middle of frame',sourcefile);{$ENDIF}
  If (VCHeight>3) Then// should eliminate minimized windows
  Begin
    //for t:=2 to VCHeight-2 do
    For t:=1 To VCHeight-1 Do
    Begin
      If (t>1) and (t<vcheight-1) and rw.bframe Then
      Begin
        VCSetPenXY(1,t);
        pvtSetFrameColors;
        If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then
        Begin
          VCWrite(gchFrameSVertical);
        End
        Else
        Begin
          VCWrite(gchFrameFVertical);
        End;
        VCSetPenXY(VCWidth-2,t);
        If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then
        Begin
          VCWrite(gchFrameSVertical);
        End
        Else
        Begin
          VCWrite(gchFrameFVertical);
        End;
      End
      Else
      Begin
        If (not rw.bFrame) Then
        Begin
          VCSetPenXY(VCWidth-1,t);
        End;
      End;
      // Right Shadow
      If t>1 Then
      Begin
        VCSetFGC(gu1ShadowFG);
        VCSetBGC(gu1ShadowBG);
        VCWrite(gchShadow+gchShadow);
        VCRedrawCell(VCWidth,t);
        VCRedrawCell(VCWidth-1,t);

        //VCWrite('qq');
      End;
    End;
    //if (p_WUID=gi4WindowHasFocusUID) then
    //  VCSetFGC(u1FrameWindowFG)
    //else
    //  VCSetFGC(gu1NoFocusFG);
    //VCSetBGC(u1FrameWindowBG);
    //VCFillBox(2,2,VCWidth-4,VCHeight-3,' ');
  End;
  // End  --------------------------------------- Middle of Frame


  // Begin --------------------------------------- Bottom of Frame
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211318,'debug paintwindow Draw Bottom of frame',sourcefile);{$ENDIF}
  If rw.bFrame Then
  Begin
    If VCHeight>2 Then
    Begin
      VCSetBGC(u1FrameWindowBG);
      pvtSetFrameColors;
      VCSetPenXY(1, VCHeight-1);
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSBottomLeft);
      End
      Else
      Begin
        VCWrite(gchFrameFBottomLeft);
      End;

      VCSetPenXY(2,VCHeight-1);
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(StringOfChar(gchFrameSHorizontal,VCWidth-4));
      End
      Else
      Begin
        VCWrite(StringOfChar(gchFrameFHorizontal,VCWidth-4));
      End;

      VCSetPenXY(VCWidth-2, VCHeight-1);
      If (rW.bSizable) and (rw.WindowState<>WS_MAXIMIZED) Then 
      Begin
        VCWrite(gchFrameSBottomRight);
      End
      Else
      Begin
        VCWrite(gchFrameFBottomRight);
      End;
      VCSetFGC(gu1ShadowFG);
      VCSetBGC(gu1ShadowBG);
      VCWrite(gchShadow+gchShadow);
      //vcwrite('rr');
      VCRedrawCell(VCWidth,VCHeight-1);
      VCRedrawCell(VCWidth-1,VCHeight-1);
    End;
  End;
  VCSetPenXY(1,VCHeight);
  VCWrite(#0+#0);
  VCRedrawCell(1,VCHeight);
  VCRedrawCell(2,VCHeight);
  
  {$IFDEF DEBUGPAINTWINDOW} jlog(cnLog_DEBUG,200609211322,'debug paintwindow  Draw the bottom shadow',sourcefile);{$ENDIF}
  For t:=3 To VCWidth Do
  Begin
    // Bottom Shadow
    VCSetFGC(gu1ShadowFG);
    VCSetBGC(gu1ShadowBG);
    VCWrite(gchShadow);
    VCRedrawCell(VCGetPenX-1,VCHeight);
    //vcwrite('a');
  End;
  // End --------------------------------------- Bottom of Frame


  // End --------------------------------------------------- Frame Draw
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  VCSetVisible(rW.bVisible);
  C.FoundNth(i4BookMarkCtl);
  bRedraw:=False;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.PaintWindow',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
{$IFDEF DEBUGPAINTWINDOW}
  {$UNDEF DEBUGPAINTWINDOW}
{$ENDIF}




//=============================================================================
Procedure TWindow.PvtSetFrameColors; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
    {$IFDEF DEBUGPAINTWINDOW}
      DebugIn('TWindow.pvtSetFrameColors',SOURCEFILE);
    {$ENDIF}
  {$ENDIF}

  // this should work fine because only a window with focus should
  // be in dragging or sizing mode.
  If JFC_XXDLITEM(SELFOBJECTITEM).UID=gi4WindowHasFocusUID Then
  Begin
    If (grMSC.uCMD=MSC_WindowSize) Then
    Begin
      //Log(cnLog_Debug,201003031348,'TWindow.PvtSetFrameColors - Window sizing colors set',SOURCEFILE);
      VCSetFGC(u1FrameSizeFG);
      VCSetBGC(u1FrameSizeBG);
    End
    Else
    If (grMSC.uCMD=MSC_WindowDrag) Then
    Begin
      VCSetFGC(u1FrameDragFG);
      VCSetBGC(u1FrameDragBG);
    End
    Else
    Begin
      VCSetFGC(u1FrameFG);
      VCSetBGC(u1FrameBG);
    End;
  End
  Else
  Begin
    VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1FrameBG);
  End;

  {$IFDEF DEBUGLOGBEGINEND}
    {$IFDEF DEBUGPAINTWINDOW}
      DebugOut('TWindow.pvtSetFrameColors',SOURCEFILE);
    {$ENDIF}
  {$ENDIF}

End;
//=============================================================================


//=============================================================================
Procedure TWindow.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Var rSageMsg: rtSageMsg;
//    i4BookMarkN: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}

  // Check For Control Focus change (TAB, Shift+TAB, Up, or Down)
  if gbUnhandledKeyPress then
  begin
    // Newer version to lose the arrow keys.
    If (not rLKey.bAltPressed) and 
       (not rLKey.bCntlPressed) and
       (rLKey.ch=#9) and (C.ListCount>0) then  
    Begin
      // gbUnhandledKeypress flag gets set to false
      // in CNTLCHANGEFOCUS because only counts
      // as a handled keypress IF there is at least
      // one focusable control.

      //If (rLKey.bShiftPressed) OR (rLKey.u2KeyCode=kbdUP) Then
      If (rLKey.bShiftPressed) then
      Begin
        //Log(cnLog_DEBUG,201003031241,'Got CONTROL TAB BACKWARDS in tWindow.processKeyBoard',sourcefile);
        CntlChangeFocus(False,True) // Cycle backwards 
      End
      Else
      Begin
        //Log(cnLog_DEBUG,201003031242,'Got CONTROL TAB FORWARD in tWindow.processKeyBoard',sourcefile);
        CntlChangeFocus(True,True); // TRUE Means Cycle Forward
        //PaintWindow(gw.Item_UID);
      End;
    End;
  end;
  
  if gbUnhandledKeyPress then
  begin
    //Log(cnLog_Debug,201003031243,'Before F5 Look in twindow.processkeyboard',sourcefile);
    // Check for CNTL+SPACE to Cycle Through Window States
    If (not rLKey.bCntlPressed) and
       (not rLKey.bAltPressed) and
       (not rLKey.bShiftPressed) and 
       (rLKey.u2KeyCode=kbdF5) Then 
    Begin
      //Log(cnLog_Debug,201003031244,'trying to cycle twindow.processkeyboard',sourcefile);
      If rw.bFrame Then
      Begin
        bRedraw:=True;
        repeat
          rw.WindowState+=1;
          If rw.WindowState>2 Then 
            rw.WindowState:=0;
        Until (rw.bMinimizeButton and 
               (rw.WindowState=WS_MINIMIZED)) OR
              (rw.bMaximizeButton and 
               (rw.WindowState=WS_MAXIMIZED)) OR
              (rw.WindowState=WS_NORMAL);
        With rSageMsg Do Begin
          lpPTR:=self;
          uMsg:=MSG_WINDOWSTATE;
          uParam1:=rw.WindowState;
          uParam2:=0;
          uObjType:=OBJ_WINDOW;
          {$IFDEF LOGMESSAGES}
          saSender:='TWindow.ProcessKeyboard';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 

        //With rSageMsg Do Begin
        //  lpPTR:=self;
        //  uMsg:=MSG_WINDOWRESIZE;
        //  uParam1:=rw.Width;
        //  uParam2:=rw.Height;
        //  uObjType:=OBJ_WINDOW;
        //  {$IFDEF LOGMESSAGES}
        //  saSender:='TWindow.ProcessKeyboard';
        //  {$ENDIF}
        //End;//with
        //PostMessage(rSageMsg); 

        //With rSageMsg Do Begin
        //  lpPTR:=self;
        //  uMsg:=MSG_PAINTWINDOW;
        //  uParam1:=0;
        //  uParam2:=0;
        //  uObjType:=OBJ_WINDOW;
        //  {$IFDEF LOGMESSAGES}
        //  saSender:='TWindow.ProcessKeyboard';
        //  {$ENDIF}
        //End;//with
        //PostMessage(rSageMsg); 
        
        gbUnhandledKeypress:=False;       
      End;
    End;
  end;
  

  if gbUnhandledKeyPress then
  begin
    //Log(cnLog_Debug,201003031243,'Before F5 Look in twindow.processkeyboard',sourcefile);
    // Check for CNTL+SPACE to Cycle Through Window States
    If (not rLKey.bCntlPressed) and
       (not rLKey.bAltPressed) and
       (not rLKey.bShiftPressed) and 
       (rLKey.u2KeyCode=kbdF4) and
       (rw.bMinimizeButton) then
    Begin
      //Log(cnLog_Debug,201003031244,'trying to cycle twindow.processkeyboard',sourcefile);
      gbUnhandledKeypress:=False;
      rw.WindowState:=WS_MINIMIZED;
      WindowchangeFocus(true);
    End;
  end;

  // Move Window Right (ALT-d)
  if gbUnhandledKeyPress then
  begin
    if bKeyCharCheck(gu4Key,false,false,true,'d') then 
    begin
      if rw.WindowState=WS_MINIMIZED then
      begin
        MinX:=MinX+1; 
        if MinX>(giConsoleWidth-1) then 
        begin
          MinX:=(giConsoleWidth-1);
        end;
      end
      else
      begin  
        X:=X+1; 
        if X>(giConsoleWidth-1) then 
        begin
          X:=(giConsoleWidth-1);
        end;
      end;
      gbUnhandledKeyPress:=false; 
    end;
  end;

  // Move Window Left (ALT-a)
  if gbUnhandledKeyPress then
  begin
    if bKeyCharCheck(gu4Key,false,false,true,'a') then
    begin
      if rw.WindowState=WS_MINIMIZED then
      begin
        MinX:=MinX-1; 
        if MinX<1 then 
        begin
          MinX:=1;
        end;
      end
      else
      begin  
        X:=X-1; 
        if X<(1-(Width-2)) then 
        begin
          X:=(1-(Width-2));
        end;
      end;
      gbUnhandledKeyPress:=false; 
    end;
  end;


  // Move Window Up (ALT+w)
  if gbUnhandledKeyPress then
  begin
    if bKeyCharCheck(gu4Key,false,false,true,'w') then
    begin
      if rw.WindowState=WS_MINIMIZED then
      begin
        MinY:=MinY-1; 
        if MinY<1 then 
        begin
          MinY:=1;
        end;
      end
      else
      begin  
        Y:=Y-1; 
        if Y< (1-(height-2)) then 
        begin
          Y:=(1-(height-2));
        end;
      end;
      gbUnhandledKeyPress:=false; 
    end;
  end;


  // Move Window Down (ALT-s)
  if gbUnhandledKeyPress then
  begin
    if bKeyCharCheck(gu4Key,false,false,true,'s') then
    begin
      if rw.WindowState=WS_MINIMIZED then
      begin
        MinY:=MinY+1; 
        if MinY> (giVCStatusBarLastKnownYPos-3) then
        begin
          MinY:=(giVCStatusBarLastKnownYPos-3);
        end;
      end
      else
      begin  
        Y:=Y+1; 
        if Y> (giVCStatusBarLastKnownYPos-3) then
        begin
          Y:=(giVCStatusBarLastKnownYPos-3);
        end;
      end;
      gbUnhandledKeyPress:=false; 
    end;
  end;

  // Widen (WS_NORMAL) (ALT+h)
  if gbUnhandledKeyPress then
  begin
    if rw.WindowState=WS_Normal then
    begin
      if bKeyCharCheck(gu4Key,false,false,true,'h') then        
      begin
        width:=width+1;
        if width>=264 then
        begin
          width:=264; // 132 columns times 2 is how I arrived at that value
        end;
        gbUnhandledKeyPress:=false; 
      end;
    end;
  end;


  // Narrow (WS_NORMAL) (ALT+f)
  if gbUnhandledKeyPress then
  begin
    if rw.WindowState=WS_Normal then
    begin
      if bKeyCharCheck(gu4Key,false,false,true,'f') then        
      begin
        width:=width-1;
        if width<=i4MinimizedWidth then
        begin
          width:=i4MinimizedWidth; 
        end;
        gbUnhandledKeyPress:=false; 
      end;
    end;
  end;

  // Make Taller (WS_NORMAL) ALT-g
  if gbUnhandledKeyPress then
  begin
    if rw.WindowState=WS_Normal then
    begin
      if bKeyCharCheck(gu4Key,false,false,true,'g') then        
      begin
        Height:=Height+1;
        if Height>=300 then
        begin
          Height:=300; // arbitrary limit
        end;
        gbUnhandledKeyPress:=false; 
      end;
    end;
  end;

  // Make Shorter (ALT+t)
  if gbUnhandledKeyPress then
  begin
    if rw.WindowState=WS_Normal then
    begin
      if bKeyCharCheck(gu4Key,false,false,true,'t') then        
      begin
        Height:=Height-1;
        if Height<=3 then
        begin
          Height:=3; 
        end;
        gbUnhandledKeyPress:=false; 
      end;
    end;
  end;

  // F9 - Force Refresh
  if gbUnhandledKeyPress then
  begin
    if bKeyCodeCheck(gu4Key,false,true,false,kbdF9) then        
    begin
      PaintWindow;
      gbUnhandledKeyPress:=false; 
    end;
  end;

  if gbUnhandledKeyPress then
  begin
    // ---- Deal with Controls on Window
    If (C.ListCount>0) then 
    Begin
      if C.FoundItem_UID(i4ControlWithFocusUID) then 
      begin
        C.ProcessKeyBoard(p_u4Key);
        if(not gbUnhandledKeypress) then
        begin
          With rSageMsg Do Begin
            lpPTR:=self;
            uMsg:=MSG_CTLKEYPRESS;
            uParam1:=0;
            uParam2:=C.Item_UID;
            uObjType:=C.uObjType;
            {$IFDEF LOGMESSAGES}
            saSender:='TWindow.ProcessKeyboard';
            {$ENDIF}
          End;//with
          PostMessage(rSageMsg); 
        end;
      end;
      if gbUnhandledKeypress then
      begin // Control didn't consume the keypress so send unhandled window keypress
        With rSageMsg Do Begin
          lpPTR:=self;
          uMsg:=MSG_UNHANDLEDKEYPRESS;
          uParam1:=0;
          uParam2:=0;
          uObjType:=OBJ_WINDOW;
          {$IFDEF LOGMESSAGES}
          saSender:='TWindow.ProcessKeyboard';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      end;
    End;
  end;
  
  if gbUnhandledKeyPress then
  begin
    // Unhandled Keypress I suppose for a window
    With rSageMsg Do Begin
      lpPTR:=self;
      uMsg:=MSG_UNHANDLEDKEYPRESS;
      uParam1:=0;
      uParam2:=0;
      uObjType:=OBJ_WINDOW;
      {$IFDEF LOGMESSAGES}
      saSender:='TWindow.ProcessKeyboard';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 
  end;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

Procedure TWindow.SetFocus; 
Var uOldW: Integer;
 rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.SetFocus',SOURCEFILE);
  {$ENDIF}
  uOldW:=gi4WindowHasFocusUID;
  gi4WindowHasFocusUID:=JFC_XXDLITEM(SELFOBJECTITEM.lpPTR).UID;  
  grGfxOps.bUpdateZOrder:=True;      
  {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - TWindow.SetFocus on entry',SOURCEFILE);{$ENDIF}
  bRedraw:=True;

  If uOldW<>0 Then
  Begin
    {$IFDEF DEBUGLOGBEGINEND} DebugIn('Section 550 BEGIN uOldW<>0 ',SOURCEFILE); {$ENDIF}
    If OBJECTSXXDL.FoundItem_UID(uOldW) Then 
    Begin
      TWindow(OBJECTSXXDL.Item_lpPTR).bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=ObjectsXXDL.Item_lpPTR;
        uMsg:=MSG_LOSTFOCUS;
        uParam1:=0;
        uParam2:=0;
        uObjType:=OBJ_WINDOW;
        {$IFDEF LOGMESSAGES}
        saSender:='WindowChangeFocusTo';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
    {$IFDEF DEBUGLOGBEGINEND}  DebugOut('Section 550 END uOldW<>0 ',SOURCEFILE);{$ENDIF}    
  End;

  {$IFDEF DEBUGLOGBEGINEND} DebugIn('Section 560 BEGIN OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID)',SOURCEFILE);{$ENDIF}    
  
  {$IFDEF DEBUGLOGBEGINEND}  DebugOut('Section 560 END OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID)',SOURCEFILE);{$ENDIF}
  With rSageMsg Do Begin
    lpPTR:=self;
    uMsg:=MSG_GOTFOCUS;
    uParam1:=0;
    uParam2:=0;
    uObjType:=OBJ_WINDOW;
    {$IFDEF LOGMESSAGES}
    saSender:='WindowChangeFocusTo';
    {$ENDIF}
  End;//with
  PostMessage(rSageMsg); 

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.SetFocus',SOURCEFILE);
  {$ENDIF}
End; 


//=============================================================================
// TRUE Means Forward
Procedure TWindow.CntlChangeFocus(p_Forward,p_Keypress:Boolean); 
//=============================================================================
Var iOldCntlUID: Integer;
    iNewCntlUID: Integer;
    rSageMsg: rtSageMsg;
    bCanAControlGetFocus: boolean;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.CntlChangeFocus - p_Forward:'+satruefalse(p_Forward)+' p_Keypress:'+saTrueFalse(p_Keypress),SOURCEFILE);
  {$ENDIF}
  bCanAControlGetFocus:=false;
  If C.ListCount>0 Then
  Begin
    // No Control has focus - so try to assign one with it.
    iOldCntlUID:=i4ControlWithFocusUID;
    
    if C.MoveFirst then
    begin
      repeat
        if C.bCanGetFocus then bCanAControlGetFocus:=true;
      until not C.MoveNext;
    end;
    
    // Get things back how they were before we checked to make sure at least one 
    // control can get focus.
    C.MoveFirst;
    C.FoundItem_UID(i4ControlWithFocusUID);
    
    if bCanAControlGetFocus then
    begin
      // Move To Next CTL
      repeat
        If (p_Forward) Then 
        begin
          if not C.MoveNext then C.MoveFirst;
        end;
        If (p_Forward=false) Then 
        begin
          if not C.MovePrevious then C.MoveLast;
        end;
      until C.bCanGetFocus;
      //C.Item_i8User:=C.N;
      i4ControlWithFocusUID:=C.Item_UID;
      
      
      If p_Keypress Then 
        gbUnhandledKeypress:=False
      Else
        gbUnhandledMouseEvent:=False;
    end;    
    
    If c.Item_UID<>iOldCntlUID Then
    Begin
      iNewCntlUID:=C.Item_UID;
      If iOldCntlUID<>0 Then
      Begin
        C.FoundItem_UID(iOldCntlUID);
        C.bRedraw:=True;
        With rSageMsg Do Begin
          lpPTR:=Self;//TWindow
          uMsg:=MSG_CTLLOSTFOCUS;
          uParam1:=0;
          uParam2:=C.Item_UID;
          uObjType:=C.uObjType;
          {$IFDEF LOGMESSAGES}
          saSender:='TWindow.CntlChangeFocus';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End;
              
      C.FoundItem_UID(iNewCntlUID);
      C.bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=self;
        uMsg:=MSG_CTLGOTFOCUS;
        uParam1:=0;
        uParam2:=C.Item_UID;
        uObjType:=C.uObjType;
        {$IFDEF LOGMESSAGES}
        saSender:='TWindow.CntlChangeFocus';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
      bRedraw:=True; //TWindow
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.CntlChangeFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================






//=============================================================================
Procedure TWindow.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var 
  uOldW: Cardinal;
  bSBVisible: Boolean;
  i4Su1: LongInt;
  iTempUID: Integer;
  
  rSageMsg: rtSageMsg;
  bRedrawOnEntry: Boolean;
  bWinGotFocus: boolean;  
  
  //-----
  iControlWithMouseOverItUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.ProcessMouse',SOURCEFILE);
  {$ENDIF}
  bRedrawOnEntry:=bRedraw;
  bWinGotFocus:=(JFC_XXDLITEM(SELFOBJECTITEM).UID=gi4WindowHasFocusUID);
  //p_bMouseIdle:=p_bMouseIdle; // shutup compiler
  If ((rw.bEnabled) and (not gbModal)) OR 
     ((rw.bEnabled) and bWinGotFocus) Then
  Begin
    If (grMSC.uCMD=MSC_NONE) and (not p_bMouseIdle) Then
    Begin
      If (rLMEvent.Action and MouseActionDown)=MouseActionDown Then
      Begin
        If rLMEvent.Buttons=MouseLeftButton Then
        Begin
          // Switch Focus?
          If not (bWinGotFocus) Then
          Begin
            uOldW:=gi4WindowHasFocusUID;
            gi4WindowHasFocusUID:=JFC_XXDLITEM(SELFOBJECTITEM).UID;  
            grGfxOps.bUpdateZOrder:=True;      
            {$IFDEF DEBUGTRACKGFXOPS}JLOG(cnLog_Debug,201003040235,'grGfxOps - TWindow.Processmouse left mouse button',SOURCEFILE);{$ENDIF}
            If OBJECTSXXDL.FoundItem_UID(uOldW) Then
            Begin
              TWindow(OBJECTSXXDL.Item_lpPTR).bRedraw:=True;
            End;
            bRedraw:=True;
            gbUnhandledMouseEvent:=False;
            
            If uOldW<>0 Then
            Begin
              OBJECTSXXDL.FoundItem_UID(uOldW);
              TWindow(OBJECTSXXDL.Item_lpPTR).bRedraw:=True;
               
              With rSageMsg Do Begin
                lpPTR:=ObjectsXXDL.Item_lpPTR;
                uMsg:=MSG_LOSTFOCUS;
                uParam1:=0;
                uParam2:=0;
                uObjType:=OBJ_WINDOW;
                {$IFDEF LOGMESSAGES}
                saSender:='ProcessMouse';
                {$ENDIF}
              End;//with
              PostMessage(rSageMsg); 
            End;
            
            OBJECTSXXDL.FoundItem_UID(gi4WindowHasFocusUID);
            With rSageMsg Do Begin
              lpPTR:=OBJECTSXXDL.Item_lpPTR;
              uMsg:=MSG_GOTFOCUS;
              uParam1:=0;
              uParam2:=0;
              uObjType:=OBJ_WINDOW;
              {$IFDEF LOGMESSAGES}
              saSender:='ProcessMouse';
              {$ENDIF}
            End;//with
            PostMessage(rSageMsg); 
            
            If (c.listcount>0) and (C.Item_i8User=0)Then
            Begin
              CntlChangeFocus(True,False);
            End;
          End;
          
          If rw.bFrame Then
          Begin
            // Test for Close button
            If (rLMevent.VMX=i4BCloseX) and 
               (rLMEvent.VMY=1) Then
            Begin
              //Log(cnLog_DEBUG, 0,'Window Close Button',SOURCEFILE);
              // Close Button
              With rSageMsg Do Begin     
                uMsg   := MSG_CLOSE;
                uParam1:= 0;
                uParam2:= 0;
                uObjType:= OBJ_WINDOW;
                lpptr:=self;
                {$IFDEF LOGMESSAGES}
                saSender:='TWindow.processmouse';
                {$ENDIF}
              End;//with
              PostMessage(rSageMsg);
              gbUnhandledMouseEvent:=False;
            End
            Else
            
            // Test for Maximize button
            If (rLMevent.VMX=i4BMaxX) and 
               (rLMEvent.VMY=1) Then
            Begin
              //cnLog_ITY_DEBUG, 201003031352,'Window Maximize Button',SOURCEFILE);
              gbUnhandledMouseEvent:=False;
              // Maximize Button
              If rW.WindowState<>WS_MAXIMIZED Then
              Begin
                rW.WindowState:=WS_MAXIMIZED;
                With rSageMsg Do Begin
                  lpPTR:=self;
                  uMsg:=MSG_WINDOWSTATE;
                  uParam1:=rw.WindowState;
                  uParam2:=0;
                  uObjType:=OBJ_WINDOW;
                  {$IFDEF LOGMESSAGES}
                  saSender:='TWindow.ProcessMouse';
                  {$ENDIF}
                End;//with
                PostMessage(rSageMsg); 
              End
              Else
              Begin
                rW.WindowState:=WS_NORMAL;
                With rSageMsg Do Begin
                  lpPTR:=self;
                  uMsg:=MSG_WINDOWSTATE;
                  uParam1:=rw.WindowState;
                  uParam2:=0;
                  uObjType:=OBJ_WINDOW;
                  {$IFDEF LOGMESSAGES}
                  saSender:='TWindow.ProcessMouse';
                  {$ENDIF}
                End;//with
                PostMessage(rSageMsg); 
              End;
              bRedraw:=True;
            End
            Else
             
            // test for minimize button
            If (rLMevent.VMX=i4BMinX) and 
               (rLMEvent.VMY=1) Then
            Begin
              //cnLog_ITY_DEBUG, 0,'Window Minimize Button',SOURCEFILE);
              gbUnhandledMouseEvent:=False;
              // Minimize Button
              If rW.WindowState<>WS_MINIMIZED Then
              Begin
                rW.WindowState:=WS_MINIMIZED;
                With rSageMsg Do Begin
                  lpPTR:=self;
                  uMsg:=MSG_WINDOWSTATE;
                  uParam1:=rw.WindowState;
                  uParam2:=0;
                  uObjType:=OBJ_WINDOW;
                  {$IFDEF LOGMESSAGES}
                  saSender:='TWindow.ProcessMouse';
                  {$ENDIF}
                End;//with
                PostMessage(rSageMsg); 
              End
              Else
              Begin
                rW.WindowState:=WS_NORMAL;
                With rSageMsg Do Begin
                  lpPTR:=self;
                  uMsg:=MSG_WINDOWSTATE;
                  uParam1:=rw.WindowState;
                  uParam2:=0;
                  uObjType:=OBJ_WINDOW;
                  {$IFDEF LOGMESSAGES}
                  saSender:='TWindow.ProcessMouse';
                  {$ENDIF}
                End;//with
                PostMessage(rSageMsg); 
              End;
              bRedraw:=True;
            End
            Else

            // Test for Drag
            If (rLMevent.VMX<=rW.Width+1) and 
               (rLMEvent.VMY=1) and
               ((rw.WindowState=WS_NORMAL) OR 
                (rw.WindowState=WS_Minimized)) Then
            Begin
              //cnLog_ITY_DEBUG, 201003031353,'Window Drag',SOURCEFILE);
              gbUnhandledMouseEvent:=False;
              With grMSC Do Begin
                uCMD:=MSC_WindowDrag;
                dTWindow:=0;
                iData:=(rLMevent.VMX-1)*-1;//Drag Ofs.
                uObjType:=OBJ_WINDOW;
                lpObj:=Self;
              End;//with
              bRedraw:=True;
            End
            Else
            Begin
              // Sizing - Left Edge
              If (rw.bSizable) and 
                 (rw.WindowState=WS_NORMAL) Then
              Begin 
                If (rLMEvent.VMX=1) and (rLMEvent.VMY>1) and
                   (rLMEvent.VMY<rW.Height) Then
                Begin
                  //cnLog_ITY_DEBUG, 201003031354,'Window Sizing Left Edge',SOURCEFILE);
                  With grMSC Do Begin
                    uCMD:=MSC_WindowSize;
                    dTWindow:=0;
                    iData:=WSE_LEFT; // Sizing
                    uObjType:=OBJ_WINDOW;
                    lpObj:=Self;
                  End;//with
                  bRedraw:=True;
                End
                Else
                
                // Sizing - Bottom Left
                If (rLMEvent.VMX=1) and 
                   (rLMEvent.VMY=rW.Height) Then
                Begin
                  //cnLog_ITY_DEBUG, 201003031355,'Window Sizing Bottom Left',SOURCEFILE);
                  With grMSC Do Begin
                    uCMD:=MSC_WindowSize;
                    dTWindow:=0;
                    iData:=WSE_BOTTOMLEFT; // Sizing
                    uObjType:=OBJ_WINDOW;
                    lpObj:=Self;
                  End;//with
                  bRedraw:=True;
                End
                Else
                
                // Sizing - Bottom
                If (rLMEvent.VMY=rW.Height) and
                   (rLMEvent.VMX>1) and 
                   (rLMEvent.VMX<rW.Width) Then
                Begin
                  //cnLog_ITY_DEBUG, 201003031356,'Window Sizing Bottom',SOURCEFILE);
                  With grMSC Do Begin
                    uCMD:=MSC_WindowSize;
                    dTWindow:=0;
                    iData:=WSE_BOTTOM; // Sizing
                    uObjType:=OBJ_WINDOW;
                    lpObj:=Self;
                  End;//with
                  bRedraw:=True;
                End
                Else
                
                // Sizing - Bottom Right
                If (rLMEvent.VMX=rW.Width) and
                   (rLMEvent.VMY=rW.Height) Then
                Begin
                  //cnLog_ITY_DEBUG, 201003031357,'Window Sizing Bottom Right',SOURCEFILE);
                  With grMSC Do Begin
                    uCMD:=MSC_WindowSize;
                    dTWindow:=0;
                    iData:=WSE_BOTTOMRIGHT; // Sizing
                    uObjType:=OBJ_WINDOW;
                    lpObj:=Self;
                  End;//with
                  bRedraw:=True;
                End
                Else
    
                // Sizing - Right
                If (rLMEvent.VMX=rW.Width) and 
                   (rLMEvent.VMY>1) and 
                   (rLMEvent.VMY<rW.HEIGHT) Then
                Begin
                  //cnLog_ITY_DEBUG, 201003031358,'Window Sizing Right',SOURCEFILE);
                  With grMSC Do Begin
                    uCMD:=MSC_WindowSize;
                    dTWindow:=0;
                    iData:=WSE_RIGHT; // Sizing
                    uObjType:=OBJ_WINDOW;
                    lpObj:=Self;
                  End;//with
                  bRedraw:=True;
                End;
              End;
            End;
          End;          
          
          // OK - We took care of Window specific stuff
          // Now let's see if we have a control
          //if gWindow<>nil then sagelog(1,'About to check Controls');    
          If C.ListCount>0 Then
          Begin  
            iControlWithMouseOverItUID:=C.iMouseOnAControl;// Control just clicked on 
            C.FoundItem_UID(iControlWithMouseOverItUID);// make the control clicked on current...
            
            iTempUID:=0;
            If C.bPrivate Then 
            Begin
              iTempUID:=i4ControlWithFocusUID;
              // make parent current if a cluster :) 
              if C.FoundItem_lpPTR(C.lpOwner) then
              begin
                i4ControlWithFocusUID:=C.Item_UID
              end;
            End;
              
            if C.bCanGetFocus then // trying this so you can click stuff already focused
            Begin
              If (i4ControlWithFocusUID<>0) and (i4ControlWithFocusUID<>iControlWithMouseOverItUID) then
              Begin
                C.FoundItem_UID(i4ControlWithFocusUID);
                C.bRedraw:=True;
                C.Item_i8User:=0;
                With rSageMsg Do Begin
                  lpPTR:=Self;//TWindow
                  uMsg:=MSG_CTLLOSTFOCUS;
                  uParam1:=0;
                  uParam2:=C.Item_UID;
                  uObjType:=C.uObjType;
                  {$IFDEF LOGMESSAGES}
                  saSender:='TWindow.ProcessMouse';
                  {$ENDIF}
                End;//with
                PostMessage(rSageMsg); 
              End;
                        
              C.FoundItem_UID(iControlWithMouseOverItUID);
              C.bRedraw:=True;
              With rSageMsg Do Begin
                lpPTR:=self;//TWindow
                uMsg:=MSG_CTLGOTFOCUS;
                uParam1:=0;
                uParam2:=C.Item_UID;
                uObjType:=C.uObjType;
                {$IFDEF LOGMESSAGES}
                saSender:='TWindow.ProcessMouse';
                {$ENDIF}
              End;//with
              PostMessage(rSageMsg); 
              i4ControlWithFocusUID:=iControlWithMouseOverItUID;
              bRedraw:=True; //TWindow
            End
            else
            begin
              bRedraw:=True; //TWindow
            end;
            If iTempUID<>0 Then 
            begin
              // trickle the mouse handling to the "private" control
              // Note This means the private control's item_i8user is zero (looks not focused regardless)
              // This might need more work: e.g. multiple controls (in a private group) with their
              // Item_i8User set will draw like they have focus - but be wary that functions
              // that report of judge if a control is in fact focused might need a second look for 
              // correctness. This will route the mouse action to the child.
              i4ControlWithFocusUID:=iTempUID;
            end;
            C.ProcessMouse(False);
          End;
        End;
      End;
    End;

    
    // OK - we got a command going?
    With grMSC Do Begin
      Case uCMD Of
      MSC_WindowDrag: Begin
        SetActiveVC(SELFOBJECTITEM.ID[2]);
        If rW.WindowState=WS_MINIMIZED Then
        Begin
          i4MinX:=rLMEvent.ConsoleX+iData;
          i4MinY:=rLMEvent.ConsoleY;
          VCSetXY(i4MinX, i4MinY);
          
          If not p_bMouseIdle Then
          Begin
            With rSageMsg Do Begin
              lpPTR:=self;
              uMsg:=MSG_WINDOWMOVE;
              uParam1:=i4MinX;
              uParam2:=i4MinY;
              uObjType:=OBJ_WINDOW;
              {$IFDEF LOGMESSAGES}
              saSender:='TWindow.ProcessMouse';
              {$ENDIF}
            End;//with
            PostMessage(rSageMsg); 
          End;          
        End
        Else
        Begin
          rW.X:=rLMEvent.ConsoleX+iData;
          rW.Y:=rLMEvent.ConsoleY;
          VCSetXY(rw.x, rw.y);
          If not p_bMouseIdle Then
          Begin
            With rSageMsg Do Begin
              lpPTR:=self;
              uMsg:=MSG_WINDOWMOVE;
              uParam1:=rw.x;
              uParam2:=rw.y;
              uObjType:=OBJ_WINDOW;
              {$IFDEF LOGMESSAGES}
              saSender:='TWindow.ProcessMouse';
              {$ENDIF}
            End;//with
            PostMessage(rSageMsg); 
          End;
        End;
        grGfxOps.bUpdateConsole:=True;
        {$IFDEF DEBUGTRACKGFXOPS}JcnLog_ity_Debug,201003040235,'grGfxOps - TWindow.Processmouse got a MSC command going',SOURCEFILE);{$ENDIF}
        If (rLMEvent.Buttons and MouseLeftButton)=0 Then
        Begin
          uCmd:=MSC_None;
          bRedraw:=True;
          
          SetActiveVC(guVCStatusBar);
          // this code works providing status bar is still console width,
          // and exists at the bottom of the screen.
          bSBVisible:=(VCGetVisible) and
                      (((giConsoleHeight-VCHeight)-1) <= VCGetY) and
                      (VCgetX=1) and (giConsoleWidth=VCWidth);
          If bSBVisible Then i4Su1:=VCGetY Else i4Su1:=0;

          If rW.WindowState=WS_MINIMIZED Then
          Begin
            If bSBVisible and (i4MinY>=i4Su1) Then i4MinY:=i4Su1-1;
            If gi4MenuHeight>=i4MinY Then i4MinY:=gi4MenuHeight+1;
          End
          Else
          Begin
            If bSBVisible and (rw.y>=i4Su1) Then rw.y:=i4Su1-1;
            If gi4MenuHeight>=rw.y Then rw.y:=gi4MenuHeight+1;
          End;
        End;
        //bRedraw:=true;
      End;
      MSC_WindowSize: Begin
        If (iData and WSE_LEFT)=WSE_LEFT Then
        Begin
          If (rLMEvent.ConsoleX>rW.X) Then
          Begin
            // This logic Sizes Window based on mouse if greater than 20 width
            // And uses mouse X to set Window X
            If (rW.Width-(rLMEvent.ConsoleX-rW.X) >=20) Then
            Begin
              rW.Width:=rW.Width-(rLMEvent.ConsoleX-rW.X);
              //SageLog(1,'After:'+inttostr(TWindow(W.PTR).rW.Width));
              rW.X:=rLMEvent.ConsoleX;
            End
            Else
            Begin
              // This logic Sizes Window width to 20 cuz the mouse is to far to the
              // right (basically force smallest size to 20)
              // Then bacause the mouse is to far, we position window based on how much
              // I had to shrink the window to make it 20 wide.
              // And uses mouse X to set Window X
              If rW.Width>20 Then
              Begin
                rW.X:=rW.X+(rW.Width-20);
              End;
              rW.Width:=20
            End;
          End
          Else
          Begin
            If rLMEvent.ConsoleX<rW.X Then
            Begin
              //Sagelog(1,'MouseX < Win X');
              rW.Width:=rW.Width+(rW.X-rLMEvent.ConsoleX);
              rW.X:=rLMEvent.ConsoleX;
            End;
          End;
        End;
  
        If (iData and WSE_RIGHT)=WSE_RIGHT Then
        Begin
          // Stretch Wider
          If rLMEvent.ConsoleX>(rW.X+rW.Width-1) Then
          Begin
            rW.Width+=rLMEvent.ConsoleX-(rW.X+rW.Width-1);
          End
          Else  
          Begin  
            // Stretch Smaller - To 20 wide when mouse to far left
            If rLMEvent.ConsoleX<(rW.X+19) Then
            Begin
              rW.Width:=19;
            End
            Else
            Begin
              // IF shinking is valid (normal shrink-mouse within valid area)
              If rLMEvent.ConsoleX<(rW.X+rW.Width-1) Then
              Begin
                rw.Width:=rw.Width-((rW.X+rW.Width-1)-rLMEvent.ConsoleX);
              End;
            End;  
          End;  
        End;
  
        If (iData and WSE_BOTTOM)=WSE_BOTTOM Then
        Begin
          // Stretch Higher
          If rLMEvent.ConsoleY>(rW.Y+rW.Height-1) Then
          Begin
            SetActiveVC(guVCStatusBar);
            // this code works providing status bar is still console width,
            // and exists at the bottom of the screen.
            bSBVisible:=(VCGetVisible) and
                        (((giConsoleHeight-VCHeight)-1) <= VCGetY) and
                        (VCgetX=1) and (giConsoleWidth=VCWidth);
            If bSBVisible Then i4Su1:=VCGetY Else i4Su1:=0;
            If (rLMevent.consoleY<i4Su1) OR (i4Su1=0) Then
            Begin
              rW.Height+=rLMEvent.ConsoleY-(rW.Y+rW.Height-1);
            End
            Else
            Begin
              rW.Height+=i4Su1-(rW.Y+rW.Height-1)-1;
            End;
          End
          Else  
          Begin  
            // Stretch Smaller - To 2 High when mouse to far up
            If rLMEvent.ConsoleY<(rW.Y+1) Then
            Begin
              rW.Height:=2;
            End
            Else
            Begin
              // IF shinking is valid (normal shrink-mouse within valid area)
              If rLMEvent.ConsoleY<(rW.Y+rW.Height) Then
              Begin
                rw.Height:=rw.Height+1-((rW.Y+rW.Height)-rLMEvent.ConsoleY);
              End;
            End;  
          End;  
        End;
        
        If not p_bMouseIdle Then
        Begin
          With rSageMsg Do Begin
            lpPTR:=self;
            uMsg:=MSG_WINDOWRESIZE;
            uParam1:=rw.Width;
            uParam2:=rw.Height;
            uObjType:=OBJ_WINDOW;
            {$IFDEF LOGMESSAGES}
            saSender:='TWindow.ProcessMouse';
            {$ENDIF}
          End;//with
          PostMessage(rSageMsg); 
        End;
        
        If (rLMEvent.Buttons and MouseLeftButton)=0 Then
        Begin
          uCmd:=MSC_None;
        End;
        
        bRedraw:=True;
      End;
      End;//case
    End;//with
  End
  Else
  Begin
    // We aren't enabled - but we got here. Hmm.
    // Ok - Gonna kill pending Cmd.
    grMSC.uCMD:=MSC_NONE;
    //Log(cnLog_DEBUG, 200609191018,'BEGIN------ TWindow.ProcessMouse Issue - Not Enabled but code fell through where it should not.',SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,' rw.bEnabled: '+ saTrueFalse(rw.bEnabled),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,' gbModeless: '+ saTrueFalse(gbModeless),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,' gi4WindowHasFocusUID: '+ inttostr(gi4WindowHasFocusUID),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,' JFC_XXDLITEM(SELFOBJECTITEM).UID: '+ inttostr(JFC_XXDLITEM(SELFOBJECTITEM).UID),SOURCEFILE);
    //cnLog_ITY_DEBUG, 200609191018,' This is logic to prevent this code from being reached: ((rw.bEnabled) and (not gbModeless)) OR ((rw.bEnabled) and (bWinGotFocus))',SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,' rtMSC - Mouse Command',SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'   grMSC.uCmd:'+ inttostr(grMSC.uCmd),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'   grMSC.dTWindow:'+ inttostr(grMSC.dTWindow),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'   grMSC.iData:'+ inttostr(grMSC.iData),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'   grMSC.uObjType:'+ inttostr(grMSC.uObjType),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'   grMSC.lpObj:'+ inttostr(cardinal(grMSC.lpObj)),SOURCEFILE);
    //Log(cnLog_DEBUG, 200609191018,'Not Enabled, Got Here?? Ok, kill pending Mouse Command if there was one.',SOURCEFILE);
    //cnLog_ITY_DEBUG, 200609191018,'END------ TWindow.ProcessMouse Issue - Not Enabled but code fell through where it should not.',SOURCEFILE);
  End;
  
  If (not bReDrawOnEntry) and (bRedraw) Then
  Begin
    With rSageMsg Do Begin
      lpPTR:=self;
      uMsg:=MSG_PAINTWINDOW;
      uParam1:=0;
      uParam2:=0;
      uObjType:=OBJ_WINDOW;
      {$IFDEF LOGMESSAGES}
      saSender:='TWindow.ProcessMouse 200609201156';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 
  End;  
  
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_VCUID: INT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_VCUID',SOURCEFILE);
  {$ENDIF}
  Result:=SELFOBJECTITEM.ID[2];
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_VCUID',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_i4MinX:LongInt; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_i4MinX',SOURCEFILE);
  {$ENDIF}
  Result:=i4MinX;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_i4MinX',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_i4MinX(p_i4MinX:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_i4MinX',SOURCEFILE);
  {$ENDIF}
  If p_i4MinX<>i4MinX Then
  Begin
    i4MinX:=p_i4MinX;
    If rw.windowState=WS_MINIMIZED Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_i4MinX',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_i4MinY:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_i4MinY',SOURCEFILE);
  {$ENDIF}
  Result:=i4MinY;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_i4MinY',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_i4MinY(p_i4MinY:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_i4MinY',SOURCEFILE);
  {$ENDIF}
  If p_i4MinY<>i4MinY Then
  Begin
    i4MinY:=p_i4MinY;
    If rw.windowState=WS_MINIMIZED Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_i4MinY',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameFG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameFG(p_u1FrameFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameFG',SOURCEFILE);
  {$ENDIF}
  If u1FrameFG<>p_u1FrameFG Then
  Begin
    u1FrameFG:=p_u1FrameFG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameBG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameBG(p_u1FrameBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameBG',SOURCEFILE);
  {$ENDIF}
  If u1FrameBG<>p_u1FrameBG Then
  Begin
    u1FrameBG:=p_u1FrameBG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameCaptionFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameCaptionFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameCaptionFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameCaptionFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameCaptionFG(p_u1FrameCaptionFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameCaptionFG',SOURCEFILE);
  {$ENDIF}
  If u1FrameCaptionFG<>p_u1FrameCaptionFG Then
  Begin
    u1FrameCaptionFG:=p_u1FrameCaptionFG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameCaptionFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameCaptionBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameCaptionBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameCaptionBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameCaptionBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameCaptionBG(p_u1FrameCaptionBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameCaptionBG',SOURCEFILE);
  {$ENDIF}
  If u1FrameCaptionBG<>p_u1FrameCaptionBG Then
  Begin
    u1FrameCaptionBG:=p_u1FrameCaptionBG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameCaptionBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameWindowFG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameWindowFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameWindowFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameWindowFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameWindowFG(p_u1FrameWindowFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameWindowFG',SOURCEFILE);
  {$ENDIF}
  If u1FrameWindowFG<>p_u1FrameWindowFG Then
  Begin
    u1FrameWindowFG:=p_u1FrameWindowFG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameWindowFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameWindowBG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameWindowBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameWindowBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameWindowBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameWindowBG(p_u1FrameWindowBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameWindowBG',SOURCEFILE);
  {$ENDIF}
  If u1FrameWindowBG<>p_u1FrameWindowBG Then
  Begin
    u1FrameWindowBG:=p_u1FrameWindowBG;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameWindowBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameSizeFG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameSizeFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameSizeFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameSizeFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameSizeFG(p_u1FrameSizeFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameSizeFG',SOURCEFILE);
  {$ENDIF}
  If u1FrameSizeFG<>p_u1FrameSizeFG Then
  Begin
    u1FrameSizeFG:=p_u1FrameSizeFG;
    If grMSC.uCMD=MSC_WINDOWSIZE Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameSizeFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameSizeBG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameSizeBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameSizeBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameSizeBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameSizeBG(p_u1FrameSizeBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameSizeBG',SOURCEFILE);
  {$ENDIF}
  If u1FrameSizeBG<>p_u1FrameSizeBG Then
  Begin
    u1FrameSizeBG:=p_u1FrameSizeBG;
    If grMSC.uCMD=MSC_WINDOWSIZE Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameSizeBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameDragFG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameDragFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameDragFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameDragFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameDragFG(p_u1FrameDragFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameDragFG',SOURCEFILE);
  {$ENDIF}
  If u1FrameDragFG<>p_u1FrameDragFG Then
  Begin
    u1FrameDragFG:=p_u1FrameDragFG;
    If grMSC.uCMD=MSC_WINDOWDRAG Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameDragFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_u1FrameDragBG:Byte; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_u1FrameDragBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FrameDragBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_u1FrameDragBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_u1FrameDragBG(p_u1FrameDragBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_u1FrameDragBG',SOURCEFILE);
  {$ENDIF}
  If u1FrameDragBG<>p_u1FrameDragBG Then
  Begin
    u1FrameDragBG:=p_u1FrameDragBG;
    If grMSC.uCMD=MSC_WINDOWDRAG Then
    Begin
      bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_u1FrameDragBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_saCaption: AnsiString; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_saCaption',SOURCEFILE);
  {$ENDIF}
  Result:=rw.saCaption;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_saCaption(p_saCaption:AnsiString);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_saCaption',SOURCEFILE);
  {$ENDIF}
  If rw.saCaption <> p_saCaption Then
  Begin
    rw.saCaption:=p_saCaption;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_X:LongInt; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_X',SOURCEFILE);
  {$ENDIF}
  Result:=rw.x;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_X',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_X(p_X:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_X',SOURCEFILE);
  {$ENDIF}
  If rw.x<>p_x Then
  Begin
    rw.x:=p_x;
    bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_X',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_Y:LongInt; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_Y',SOURCEFILE);
  {$ENDIF}
  Result:=rw.Y;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_Y',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_Y(p_Y:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_Y',SOURCEFILE);
  {$ENDIF}
  If rw.y<>p_y Then
  Begin
    rw.Y:=p_y;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_Y',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_Width:LongInt; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_Width',SOURCEFILE);
  {$ENDIF}
  //result:=rw.width;
  Result:=i4RWidth;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_Width(p_Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_Width',SOURCEFILE);
  {$ENDIF}
  If rw.width<>p_width Then
  Begin
    rw.width:=p_width;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_Height:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_Height',SOURCEFILE);
  {$ENDIF}
  //result:=rw.height;
  Result:=i4RHeight;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_Height(p_Height:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_Height',SOURCEFILE);
  {$ENDIF}
  If rw.height <> p_height Then
  Begin
    rw.height:=p_height;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bFrame:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bFrame',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bFrame;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bFrame',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bFrame(p_bFrame:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bFrame',SOURCEFILE);
  {$ENDIF}
  If rw.bFrame<>p_bFrame Then
  Begin
    rw.bFrame:=p_bFrame;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bFrame',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_WindowState:Cardinal;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_WindowState',SOURCEFILE);
  {$ENDIF}
  Result:=rw.windowstate;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_WindowState',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_WindowState(p_WindowState:Cardinal);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_WindowState',SOURCEFILE);
  {$ENDIF}
  If rw.windowstate<>p_windowstate Then
  Begin
    rw.windowstate:=p_windowstate;
    bReDraw:=True;//TODO: Need Minimize Code here for NewMinX and Y
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_WindowState',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bCaption:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bCaption',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bcaption;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bCaption(p_bCaption:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bCaption',SOURCEFILE);
  {$ENDIF}
  If rw.bCaption<>p_bCaption Then
  Begin
    rw.bCaption:=p_bCaption;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bMinimizeButton:Boolean; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bMinimizeButton',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bMinimizeButton;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bMinimizeButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bMinimizeButton(p_bMinimizeButton:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bMinimizeButton',SOURCEFILE);
  {$ENDIF}
  If rw.bMinimizeButton<>p_bMinimizeButton Then
  Begin
    rw.bMinimizeButton:=p_bMinimizeButton;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bMinimizeButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bMaximizeButton:Boolean; 
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bMaximizeButton',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bMaximizeButton;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bMaximizeButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bMaximizeButton(p_bMaximizeButton:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bMaximizeButton',SOURCEFILE);
  {$ENDIF}
  If rw.bMaximizeButton<>p_bMaximizeButton Then
  Begin
    rw.bMaximizeButton:=p_bMaximizeButton;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bMaximizeButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bCloseButton:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bCloseButton',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bCloseButton;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bCloseButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bCloseButton(p_bCloseButton:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bCloseButton',SOURCEFILE);
  {$ENDIF}
  If rw.bCloseButton<>p_bCloseButton Then
  Begin
    rw.bCloseButton:=p_bCloseButton;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bCloseButton',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bSizable:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bSizable',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bSizable;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bSizable',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bSizable(p_bSizable:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bSizable',SOURCEFILE);
  {$ENDIF}
  If rw.bSizable<>p_bSizable Then
  Begin
    rw.bSizable:=p_bSizable;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bSizable',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bVisible:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bVisible',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bVisible;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bVisible',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bVisible(p_bVisible:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bVisible',SOURCEFILE);
  {$ENDIF}
  If rw.bVisible<>p_bVisible Then
  Begin
    rw.bVisible:=p_bVisible;
    bReDraw:=True;
    PaintWindow;
    grGfxOps.bUpdateConsole:=true;
    grGfxOps.bUpdateZOrder:=true;
    if gi4WindowHasFocusUID = SELFOBJECTITEM.UID then
    begin
      gi4WindowHasFocusUID:=0;
      WindowChangeFocus(false);
    end;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bVisible',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bEnabled:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bEnabled',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bEnabled;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_RW_bEnabled(p_bEnabled:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_RW_bEnabled',SOURCEFILE);
  {$ENDIF}
  If rw.bEnabled<>p_bEnabled Then
  Begin
    rw.bEnabled:=p_bEnabled;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_RW_bEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_bAlwaysOnTop:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_bAlwaysOnTop',SOURCEFILE);
  {$ENDIF}
  Result:=rw.bAlwaysOnTop;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_bAlwaysOnTop',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.Write_bAlwaysOnTop(p_bAlwaysOnTop:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Write_bAlwaysOnTop',SOURCEFILE);
  {$ENDIF}
  If rw.bAlwaysOnTop<>p_bAlwaysOnTop Then
  Begin
    rw.bAlwaysOnTop:=p_bAlwaysOnTop;
    bReDraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Write_bAlwaysOnTop',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.Read_RW_lpfnWndProc:pointer;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.Read_RW_lpfnWndProc',SOURCEFILE);
  {$ENDIF}
  Result:=rw.lpfnWndProc;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.Read_RW_lpfnWndProc',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.CurrentCTLID: UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.CurrentCTLID',SOURCEFILE);
  {$ENDIF}
  Result:=i4ControlWithFocusUID;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.CurrentCTLID',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TWindow.ControlCTLPTR: pointer;
//=============================================================================
var i4BookMarkN: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.ControlCTLPTR',SOURCEFILE);
  {$ENDIF}
  i4BookMarkN:=C.N;
  if c.FoundItem_UID(i4ControlWithFocusUID) then 
  begin
    result:=C.Item_lpPtr;
  end
  else
  begin
    result:=nil;
  end;
  c.FoundNth(i4BookMarkN);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.ControlCTLPTR',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TWindow.CalcRelativeSize;
//=============================================================================
//var 
//  t:LongInt;
//  bSBVisible: boolean;
//  i4Su1: LongInt;
//  u4TempVC: Cardinal;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.CalcRelaTiveSize',SOURCEFILE);
  {$ENDIF}

  CalcStatusBar;
  
  Case rw.WindowState Of 
  WS_MINIMIZED, WS_NORMAL: Begin
    i4RWidth:=rw.Width;
    i4RHeight:=rw.Height;
  End;
  WS_MAXIMIZED: Begin
    i4RWidth:=giConsoleWidth;
    i4RHeight:=giConsoleHeight-gi4MenuHeight-(giConsoleHeight-giVCStatusBarLastKnownYPos)-1;
    //i4RHeight:=giConsoleHeight-(giConsoleHeight-giVCStatusBarLastKnownYPos)-1;
  End;
  End;// case
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.CalcRelaTiveSize',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
  
//=============================================================================
Function TWindow.HasFocus: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TWindow.HasFocus',SOURCEFILE);
  {$ENDIF}
  Result:=JFC_XXDLITEM(SELFOBJECTITEM).UID=gi4WindowHasFocusUID;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TWindow.HasFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================






//=============================================================================
//procedure TWindow.ProcessCommand(p_bMouse: boolean);
//=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('TWindow.ProcessCommand',SOURCEFILE);
//  {$ENDIF}
//
//  with grMSC do begin
//    case uCMD of
//    MSC_WindowSize: begin
//    
//    end;
//    MSC_WindowDrag: begin
//    end;
//  end; //with
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('TWindow.ProcessCommand',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================
//
////=============================================================================
//procedure TWindow.Size;
////=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('TWindow.Size',SOURCEFILE);
//  {$ENDIF}
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('TWindow.Size',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================
//
//
//
////=============================================================================
//procedure TWindow.Maximize;
////=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('TWindow.Maximize',SOURCEFILE);
//  {$ENDIF}
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('TWindow.Maximize',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================
//
////=============================================================================
//procedure TWindow.Minimize;
////=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('TWindow.Minimize',SOURCEFILE);
//  {$ENDIF}
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('TWindow.Minimize',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================
//
////=============================================================================
//procedure TWindow.Restore;
////=============================================================================
//begin
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugIn('TWindow.Restore',SOURCEFILE);
//  {$ENDIF}
//
//  {$IFDEF DEBUGLOGBEGINEND}
//  DebugOut('TWindow.Restore',SOURCEFILE);
//  {$ENDIF}
//end;
////=============================================================================

































//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLBASE Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor TCTLBASE.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.create',SOURCEFILE);
  {$ENDIF}

  //Function AppendItem_XXDL(
  //  p_lpPtr: pointer;
  //  p_saName, p_saDesc: AnsiString;
  //  p_i8User: Int64;
  //  p_ID1, p_ID2, p_ID3, p_ID4: Integer
  //  ): Boolean;


//  OBJECTSXXDL.AppendItem_XXDL(
//    self,
//    '',
//    '',
//    0,
//    TWINDOW(p_TWindow).SELFOBJECTITEM.ID[2],  // VC Of Owner Window
//    OBJ_NONE,
//    0,
//    0
//  );        
// SELFOBJECTITEM: JFC_XXDL(OBJECTSXXDL.lpItem); // This is ACTUAL element/item in OBJECTSXXDL
  bHasChildren:=false;
  lpTWindow:=p_TWindow;
  lpCTL:=TWindow(lpTWindow).C;
  TC(lpCTL).AppendItem;
  TC(lpCTL).Item_lpPTR:=self;
  CTLUID:=TC(lpCTL).Item_UID;
  if TC(lpCTL).Listcount=1 then TC(lpCTL).Item_i8User:=1;

  i4X:=1;
  i4Y:=1;
  
  bVisible:=True;
  bEnabled:=True;

  bPrivate:=False;
  uOwnerObjType:=OBJ_NONE;
  lpOwner:=nil;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor TCTLBASE.Destroy;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Destroy',SOURCEFILE);
  {$ENDIF}
  
  Inherited;
  If TC(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).Deleteitem;
  If OBJECTSXXDL.FoundItem_lpPTR(self) Then OBJECTSXXDL.DeleteItem;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Destroy',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.ProcessKeyBoard',SOURCEFILE);
  {$ENDIF}

  p_u4Key:=p_u4KEy; //shutup compiler

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.ProcessKeyBoard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  p_bMouseIdle:=p_bMouseIDle;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlBase.Read_bEnabled: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_bEnabled',SOURCEFILE);
  {$ENDIF}
  Result:=bEnabled;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_bEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.Write_bEnabled(p_bEnabled: Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Write_bEnabled',SOURCEFILE);
  {$ENDIF}
  If bEnabled<>p_bEnabled Then
  Begin
    bEnabled:=p_bEnabled;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    //If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Write_bEnabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlBase.Read_bVisible:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_bVisible',SOURCEFILE);
  {$ENDIF}
  Result:=bVisible;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_bVisible',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.Write_bVisible(p_bVisible:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_bVisible',SOURCEFILE);
  {$ENDIF}
  If bVisible<>p_bVisible Then
  Begin
    bVisible:=p_bVisible;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_bVisible',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlBase.Read_i4X:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_i4X',SOURCEFILE);
  {$ENDIF}
  Result:=i4X;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_i4X',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.Write_i4X(p_i4X:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Write_i4X',SOURCEFILE);
  {$ENDIF}
  If i4X<>p_i4X Then
  Begin
    i4X:=p_i4X;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Write_i4X',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlBase.Read_i4Y:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_i4Y',SOURCEFILE);
  {$ENDIF}
  Result:=i4Y;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_i4Y',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.Write_i4Y(p_i4Y:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Write_i4Y',SOURCEFILE);
  {$ENDIF}
  If i4Y<>p_i4Y Then
  Begin
    i4Y:=p_i4Y;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Write_i4Y',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlBase.Read_ID:UINT;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBASE.Read_ID',SOURCEFILE);
  {$ENDIF}
  Result:=UINT(self);
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBASE.Read_ID',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlBase.Write_bRedraw(p_bRedraw: boolean);
//=============================================================================
var 
  i4BookMarkN: longint;
  MyWin: TWINDOW;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlBase.Write_bRedraw',SOURCEFILE);
  {$ENDIF}
  
  MyWin:=TWINDOW(lpTWindow);
  i4BookMarkN:=MyWin.C.N;
  if MyWin.C.FoundItem_UID(self.CTLUID) then
  begin
    MyWin.C.bRedraw:=p_bRedraw;
  end;
  MyWin.C.FoundNth(i4BookMarkN);
  
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlBase.Write_bRedraw',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


















//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLLABEL Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor tctlLabel.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.create',SOURCEFILE);
  {$ENDIF}
  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_LABEL;
  i4Width:=20;
  i4Height:=1;
  u1FG:=gu1FrameWindowFG;
  u1BG:=gu1FrameWindowBG;
  saCaption:='Label (Control ' + inttostr(tc(lpCTL).LISTCOUNT)+')';
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlLabel.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlLabel.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
    tc(lpCTL).Item_ID2:=0; // Redraw
  If bVisible Then
  Begin
    //If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
    If p_bWindowHasFocus and bEnabled Then
    begin
      VCSetFGC(u1FG);
    end
    Else
    begin
      VCSetFGC(gu1NoFocusFG);
    end;
    VCSetBGC(u1BG);
    VCSetPenXY(i4X, i4Y);
    VCWordwrap(i4Width, i4Height, saCaption);
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlLabel.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Function TCTLLABEL.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLLABEL.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width; 
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLLABEL.Read_i4Height:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Read_i4Height',SOURCEFILE);
  {$ENDIF}
  Result:=i4Height;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Read_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLLABEL.Write_i4Height(p_i4Height:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Write_i4Height',SOURCEFILE);
  {$ENDIF}
  If i4Height<>p_i4Height Then
  Begin
    i4Height:=p_i4Height;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Write_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLLABEL.Read_u1FG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Read_u1FG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Read_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLLABEL.Write_u1FG(p_u1FG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Write_u1FG',SOURCEFILE);
  {$ENDIF}
  If u1FG<>p_u1FG Then
  Begin
    u1FG:=p_u1FG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Write_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLLABEL.Read_u1BG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Read_u1BG',SOURCEFILE);
  {$ENDIF}
  Result:=u1BG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Read_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLLABEL.Write_u1BG(p_u1BG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Write_u1BG',SOURCEFILE);
  {$ENDIF}
  If u1BG<>p_u1BG Then
  Begin
    u1BG:=p_u1BG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Write_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLLABEL.Read_saCaption:AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Read_saCaption',SOURCEFILE);
  {$ENDIF}
  Result:=saCaption;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Read_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLLABEL.Write_saCaption(p_saCaption:AnsiString);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLLABEL.Write_saCaption',SOURCEFILE);
  {$ENDIF}
  If saCaption<>p_saCaption Then
  Begin
    saCaption:=p_saCaption;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLLABEL.Write_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================































//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLVSCROLLBAR Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor tctlVSCROLLBAR.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLVSCROLLBAR.create',SOURCEFILE);
  {$ENDIF}
  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_VSCROLLBAR;
  i4Height:=20;
  i4MaxValue:=20;
  i4Value:=0;

  u1ScrollBarSlideFG:=gu1ScrollBarSlideFG;
  u1ScrollBarSlideBG:=gu1ScrollBarSlideBG;
  u1ScrollBarFG:=TWindow(lpTWindow).u1FrameFG;
  u1ScrollBarBG:=TWindow(lpTWindow).u1FrameBG;
  
  
  chScrollBarUpArrow  := gchScrollBarUpArrow   ;  
  chScrollBarDownArrow:= gchScrollBarDownArrow ;
  chScrollBarVMarker  := gchScrollBarVMarker   ;  
  chScrollBarSlide    := gchScrollBarSlide     ;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLVSCROLLBAR.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure tctlVSCROLLBAR.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var 
  iLoop: Integer;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
    tc(lpCTL).Item_ID2:=0; // Redraw

  If bVisible Then
  Begin
    CalcME;
    // ---- Draw it all
    For iLoop := 1 To i4Height - 2 Do
    Begin
      If (iLoop <> i4VScroll) Then
      Begin
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarSlideFG) Else VCSetFGC(gu1NoFocusFG);
        VCSetBGC(u1ScrollBarSlideBG);
        VCWriteCharXY(i4X, i4Y + iLoop, chScrollBarSlide); 
      End
      Else
      Begin
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarFG) Else VCSetFGC(gu1NoFocusFG);
        VCSetBGC(u1ScrollBarBG);
        VCWriteCharXY(i4X,i4Y+iLoop, chScrollBarVMarker);
      End;
    End;
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarFG) Else VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1ScrollBarBG);
    VCWriteCharXY(i4X, i4Y,gchScrollBarUpArrow);
    VCWriteCharXY(i4X, i4Y+i4Height-1, chScrollBarDownArrow); 
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVScrollBar.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var 
  i4VCY: LongInt;
  rSageMsg: rtSageMsg;

Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  CalcMe;
  
  If not p_bMouseIdle Then
  Begin
    Case grMSC.uCMD Of
    MSC_NONE: Begin
      If ((rLMEvent.Action and MouseActionDown)=MouseActionDown) and
        (rLMEvent.Buttons=MouseLeftButton) Then
      Begin
        If (rLMEvent.VMX=i4X) Then
        Begin
          If (rLMEvent.VMY-i4Y=i4VScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_VScrollDrag;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_VSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End
          Else
          
          If (rLMEvent.VMY-i4Y<i4VScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_VScrollUp;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_VSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End
          Else

          If (rLMEvent.VMY-i4Y>i4VScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_VScrollDown;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_VSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End;
        End;
      End;
    End;
    MSC_VSCROLLUP, MSC_VSCROLLDOWN: Begin
      If ((rLMEvent.Action and MouseActionUp)=MouseActionUp) and
        ((rLMEvent.Buttons and MouseLeftButton)=0) OR
        (rLMEvent.VC<>TWindow(lpTWindow).SELFOBJECTITEM.ID[2]) OR
        (rLMEVent.VMX<>i4X) OR
        (rLMevent.VMY<i4Y) OR
        (rLMEvent.VMY>i4Y+i4Height-1) Then
      Begin
        grMSC.uCmd:=MSC_NONE;
        gbUnhandledMouseEvent:=false;
        If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      End;
    End;
    MSC_VSCROLLDRAG: Begin
      If ((rLMEvent.Action and MouseActionUp)=MouseActionUp) and
        ((rLMEvent.Buttons and MouseLeftButton)=0) Then
      Begin
        grMSC.uCMD:=MSC_NONE;
        gbUnhandledMouseEvent:=false;
        If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      End;
    End;
    End;//case
  End;
  
  Case grMSC.uCMD Of
  MSC_VScrollUp: Begin
    If (i4Value>0) and (rLMEvent.VMY-i4Y<i4VScroll) Then i4Value-=1;
    If tc(lpCTL).FoundItem_lpPTR(self) Then
    Begin
      tc(lpCTL).bRedraw:=True; 
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLUP;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_VSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlVSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg);
        gbUnhandledMouseEvent:=false; 
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).CurrentItem:=i4Value;
          gbUnhandledMouseEvent:=false;
        End;
        End;//case
      End;
    End;
  End;
  MSC_VScrollDown: Begin
    If (i4Value<i4MaxValue) and (rLMEvent.VMY-i4Y>i4VScroll) Then i4Value+=1;
    If tc(lpCTL).FoundItem_lpPTR(self) Then
    Begin
      tc(lpCTL).bRedraw:=True; 
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLDOWN;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_VSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlVSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).CurrentItem:=i4Value;
          gbUnhandledMouseEvent:=false;
        End;
        End;//case
      End;
    End;
  End;
  MSC_VSCROLLDRAG: Begin
    SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
    i4VCY:=rLMEvent.ConsoleY-VCGEtY-i4Y+1;
    If i4VCY<1 Then i4VCY:=1;
    If i4VCY>i4Height-2 Then i4VCY:=i4Height-2;
    
    If rLMEvent.ConsoleY-VCGEtY-i4Y+1>i4VScroll Then // mouse below marker
    Begin
      While ((i4VCY>i4VScroll) and (i4Value<i4MaxValue))OR 
            ((rLMEvent.ConsoleY-VCGEtY-i4Y+1>i4VScroll) and (i4Value<i4MaxValue))Do Begin
        i4Value+=1;
        CalcMe;
      End;
      tc(lpCTL).FoundItem_lpPtr(self);
      tc(lpCTL).bRedraw:=True;
      If not bPRivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLDOWN;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_VSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlVSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).CurrentItem:=i4Value;
          gbUnhandledMouseEvent:=false;
        End;
        End;//case
      End;
    End
    Else
    
    If rLMEvent.ConsoleY-VCGEtY-i4Y+1<i4VScroll Then // mouse above marker
    Begin
      While ((i4VCY<i4VScroll) and (i4Value>1)) OR 
            ((rLMEvent.ConsoleY-VCGEtY-i4Y+1<i4VScroll) and (i4Value>1))Do Begin
        i4Value-=1;
        CalcMe;
      End;
      tc(lpCTL).FoundItem_lpPtr(self);
      tc(lpCTL).bRedraw:=True;
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLUP;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_VSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlVSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).CurrentItem:=i4Value;
          gbUnhandledMouseEvent:=false;
        End;
        End;//case
      End;
    End; // else it equals marker - no change
  End;
  End;//case
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlVScrollBar.CalcMe;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.CalcMe',SOURCEFILE);
  {$ENDIF}

  dVSize := i4MaxValue;
  dVIndex := i4Value;
  If (dVSize>0) Then
    dVPercent := dVIndex/dVSize
  Else
    dVPercent := 1;
  dVSSize := i4Height-2;
  dVSIndex := dVPercent * dVSSize;
  
  i4VScroll := Round(dVSIndex); 
  If(i4VScroll<1)Then i4VScroll:=1;
  If i4VSCroll=i4Height Then i4VScroll:=i4Height-1;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.CalcMe',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_i4Height:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_i4Height',SOURCEFILE);
  {$ENDIF}
  Result:=i4Height; 
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_i4Height(p_i4Height:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_i4Height',SOURCEFILE);
  {$ENDIF}
  If i4Height<>p_i4Height Then 
  Begin
    i4Height:=p_i4Height;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_i4MaxValue:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  Result:=i4MaxValue;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_i4MaxValue(p_i4MaxValue:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  If i4MaxValue<>p_i4MaxValue Then
  Begin
    i4MaxValue:=p_i4Maxvalue;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_i4Value:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_i4Value',SOURCEFILE);
  {$ENDIF}
  Result:=i4Value;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_i4Value(p_i4Value:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_i4Value',SOURCEFILE);
  {$ENDIF}
  If i4Value<>p_i4Value Then
  Begin
    i4Value:=p_i4Value;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_chScrollBarUpArrow:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_chScrollBarUpArrow',SOURCEFILE);
  {$ENDIF}
  Result:=chScrollBarUpArrow;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_chScrollBarUpArrow',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_chScrollBarUpArrow(p_chScrollBarUpArrow:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_chScrollBarUpArrow',SOURCEFILE);
  {$ENDIF}
  If chScrollBarUpArrow<>p_chScrollBarUpArrow Then
  Begin
    chScrollBarUpArrow:=p_chScrollBarUpArrow;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_chScrollBarUpArrow',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_chScrollBarDownArrow:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_chScrollBarDownArrow',SOURCEFILE);
  {$ENDIF}
  Result:=chScrollBarDownArrow;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_chScrollBarDownArrow',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_chScrollBarDownArrow(p_chScrollBarDownArrow:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_chScrollBarDownArrow',SOURCEFILE);
  {$ENDIF}
  If chScrollBarDownArrow<>p_chScrollBarDownArrow Then
  Begin
    chScrollBarDownArrow:=p_chScrollBarDownArrow;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_chScrollBarDownArrow',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_chScrollBarVMarker:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_chScrollBarVMarker',SOURCEFILE);
  {$ENDIF}
  Result:=chScrollBarVMarker;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_chScrollBarVMarker',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_chScrollBarVMarker(p_chScrollBarVMarker:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_chScrollBarVMarker',SOURCEFILE);
  {$ENDIF}
  If chScrollBarVMarker<>p_chScrollBarVMarker Then
  Begin
    chScrollBarVMarker:=p_chScrollBarVMarker;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_chScrollBarVMarker',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_chScrollBarSlide:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_chScrollBarSlide',SOURCEFILE);
  {$ENDIF}
  Result:=chScrollBarSlide;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_chScrollBarSlide',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_chScrollBarSlide(p_chScrollBarSlide:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_chScrollBarSlide',SOURCEFILE);
  {$ENDIF}
  If chScrollBarSlide<>p_chScrollBarSlide Then
  Begin
    chScrollBarSlide:=p_chScrollBarSlide;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_chScrollBarSlide',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_u1ScrollBarSlideFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarSlideFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_u1ScrollBarSlideFG(p_u1ScrollBarSlideFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarSlideFG<>p_u1ScrollBarSlideFG Then
  Begin
    u1ScrollBarSlideFG:=p_u1ScrollBarSlideFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_u1ScrollBarSlideBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarSlideBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_u1ScrollBarSlideBG(p_u1ScrollBarSlideBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarSlideBG<>p_u1ScrollBarSlideBG Then
  Begin
    u1ScrollBarSlideBG:=p_u1ScrollBarSlideBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_u1ScrollBarFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_u1ScrollBarFG(p_u1ScrollBarFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarFG<>p_u1ScrollBarFG Then
  Begin
    u1ScrollBarFG:=p_u1ScrollBarFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlVSCROLLBAR.Read_u1ScrollBarBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Read_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Read_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlVSCROLLBAR.Write_u1ScrollBarBG(p_u1ScrollBarBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlVSCROLLBAR.Write_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarBG<>p_u1ScrollBarBG Then
  Begin
    u1ScrollBarBG:=p_u1ScrollBarBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlVSCROLLBAR.Write_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
























//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLHSCROLLBAR Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor tctlHSCROLLBAR.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLHSCROLLBAR.create',SOURCEFILE);
  {$ENDIF}
  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_HSCROLLBAR;
  i4Width:=20;
  i4MaxValue:=20;
  i4Value:=0;
  
  u1ScrollBarSlideFG:=gu1ScrollBarSlideFG;
  u1ScrollBarSlideBG:=gu1ScrollBarSlideBG;
  u1ScrollBarFG:=TWindow(lpTWindow).u1FrameFG;
  u1ScrollBarBG:=TWindow(lpTWindow).u1FrameBG;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLHSCROLLBAR.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlHSCROLLBAR.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var 
  i4T: LongInt;  
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
    tc(lpCTL).Item_ID2:=0; // Redraw

  If bVisible Then
  Begin
    CalcMe;
    // ---- Draw it all.
    For i4T := 1 To (i4Width-2)Do
    Begin
      If(i4T <> i4HScroll) Then
      Begin
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarSlideFG) Else VCSetFGC(gu1NoFocusFG);
        VCSetBGC(u1ScrollBarSlideBG);
        VCWriteCharXY(i4X+i4T, i4Y, gchScrollBarSlide); //GSHADE
      End
      Else
      Begin
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarFG) Else VCSetFGC(gu1NoFocusFG);
        VCSetBGC(u1ScrollBarBG);
        VCWriteCharXY(i4X+i4T,i4Y,gchScrollBarHMarker); //GDOT
      End;
    End;
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then VCSetFGC(u1ScrollBarFG) Else VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1ScrollBarBG);
    VCWriteCharXY(i4X,i4Y, gchScrollBarLeftArrow); //GLARROW
    VCWriteCharXY(i4X+i4Width-1, i4Y,gchScrollBarRightArrow); //GRARROW
  End;


  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlHScrollBar.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var 
  i4VCX: LongInt;
  rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  CalcMe;
  
  If not p_bMouseIdle Then
  Begin
    Case grMSC.uCMD Of
    MSC_NONE: Begin
      If ((rLMEvent.Action and MouseActionDown)=MouseActionDown) and
        (rLMEvent.Buttons=MouseLeftButton) Then
      Begin
        If (rLMEvent.VMY=i4Y) Then
        Begin
          If (rLMEvent.VMX-i4X=i4HScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_HScrollDrag;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_HSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End
          Else

          If (rLMEvent.VMX-i4X<i4HScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_HScrollLeft;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_HSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End
          Else

          If (rLMEvent.VMX-i4X>i4HScroll) Then
          Begin
            With grMSC Do Begin
              uCMD:=MSC_HScrollRight;
              dTWindow:=0;
              iData:=0;
              uObjType:=OBJ_HSCROLLBAR;
              lpObj:=Self;
            End;//with
            gbUnhandledMouseEvent:=false;
            If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
          End;
        End;
      End;
    End;
    MSC_HSCROLLLEFT, MSC_HSCROLLRIGHT: Begin
      If ((rLMEvent.Action and MouseActionUp)=MouseActionUp) and
        ((rLMEvent.Buttons and MouseLeftButton)=0) OR
        (rLMEvent.VC<>TWindow(lpTWindow).SELFOBJECTITEM.ID[2]) OR
        (rLMEVent.VMY<>i4Y) OR
        (rLMevent.VMX<i4X) OR
        (rLMEvent.VMX>i4X+i4Width-1) Then
      Begin
        grMSC.uCmd:=MSC_NONE;
        gbUnhandledMouseEvent:=false;
        If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      End;
    End;
    MSC_HSCROLLDRAG: Begin
      If ((rLMEvent.Action and MouseActionUp)=MouseActionUp) and
        ((rLMEvent.Buttons and MouseLeftButton)=0) Then
      Begin
        grMSC.uCMD:=MSC_NONE;
        gbUnhandledMouseEvent:=false;
        If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      End;
    End;
    End;//case
  End;
  
  Case grMSC.uCMD Of
  MSC_HScrollLeft: Begin
    If (i4Value>0) and (rLMEvent.VMX-i4X<i4HScroll) Then i4Value-=1;
    If tc(lpCTL).FoundItem_lpPTR(self) Then
    Begin
      tc(lpCTL).Item_ID2:=1; 
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLLEFT;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_VSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlHSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
        tc(lpCTL).bRedraw:=true;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).i4Left:=i4Value;
          tc(lpCTL).FoundItem_lpPTR(lpOwner);
          tc(lpCTL).bRedraw:=True;   
          gbUnhandledMouseEvent:=false;
        End;
        End;//case
      End;
    End;
  End;
  MSC_HScrollRight: Begin
    If (i4Value<i4MaxValue) and (rLMEvent.VMX-i4X>i4HScroll) Then i4Value+=1;
    If tc(lpCTL).FoundItem_lpPTR(self) Then
    Begin
      tc(lpCTL).Item_ID2:=1; 
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLRIGHT;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_HSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlHSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
        tc(lpCTL).bRedraw:=true;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).i4Left:=i4Value;
          tc(lpCTL).FoundItem_lpPTR(lpOwner);
          tc(lpCTL).bRedraw:=True;   
        End;
        End;//case
        gbUnhandledMouseEvent:=false;
      End;
    End;
  End;
  MSC_HSCROLLDRAG: Begin
    SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
    i4VCX:=rLMEvent.ConsoleX-VCGEtX-i4X+1;
    If i4VCX<1 Then i4VCX:=1;
    If i4VCX>i4width-2 Then i4VCX:=i4Width-2;
    
    If rLMEvent.ConsoleX-VCGEtX-i4X+1>i4HScroll Then // mouse right of marker
    Begin
      While ((i4VCX>i4HScroll) and (i4Value<i4MaxValue))OR
      ((rLMEvent.ConsoleX-VCGEtX-i4X+1>i4HScroll) and (i4Value<i4MaxValue)) Do Begin
        i4Value+=1;
        CalcMe;
      End;
      tc(lpCTL).FoundItem_lpPTR(self);
      tc(lpCTL).bRedraw:=True;
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLRIGHT;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_HSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlHSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).i4Left:=i4Value;
          tc(lpCTL).FoundItem_lpPTR(lpOwner);
          tc(lpCTL).bRedraw:=True;   
        End;
        End;//case
        gbUnhandledMouseEvent:=false;
      End;
    End
    Else
    
    If rLMEvent.ConsoleX-VCGEtX-i4X+1<i4HScroll Then // mouse left of marker
    Begin
      While ((i4VCX<i4HScroll) and (i4Value>1))OR 
      ((rLMEvent.ConsoleX-VCGEtX-i4X+1<i4HScroll) and (i4Value>1)) Do Begin
        i4Value-=1;
        CalcMe;
      End;
      tc(lpCTL).FoundItem_lpPTR(self);
      tc(lpCTL).bRedraw:=True;
      If not bPrivate Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CTLSCROLLLEFT;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_HSCROLLBAR;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlHSCROLLBAR.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End
      Else
      Begin
        Case uOwnerObjType Of
        OBJ_LISTBOX: Begin
          tctlListBox(lpOwner).i4Left:=i4Value;
          tc(lpCTL).FoundItem_lpPTR(lpOwner);
          tc(lpCTL).bRedraw:=True;   
          gbUnhandledMouseEvent:=false;
        End;
        End; //case
      End;
    End; // else it equals marker - no change
  End;
  End;//case
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlHScrollBar.CalcMe;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.CalcMe',SOURCEFILE);
  {$ENDIF}

  dHSize := i4MaxValue;
  dHIndex := i4Value;
  If (dHSize>0) Then
    dHPercent := dHIndex/dHSize
  Else
    dHPercent := 1;
  dHSSize := i4Width-2;
  dHSIndex := dHPercent * dHSSize;
  
  i4HScroll := Round(dHSIndex); 
  If(i4HScroll=0)Then i4HScroll:= 1;
  If(i4HScroll<1)Then i4HScroll:=1;
  If i4HSCroll=i4Width Then i4HScroll:=i4Width-1;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.CalcMe',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_i4MaxValue:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  Result:=i4MaxValue;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_i4MaxValue(p_i4MaxValue:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  If i4MaxValue<>p_i4MaxValue Then
  Begin
    i4MaxValue:=p_i4MaxValue;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_i4Value:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_i4Value',SOURCEFILE);
  {$ENDIF}
  Result:=i4Value;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_i4Value(p_i4Value:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_i4Value',SOURCEFILE);
  {$ENDIF}
  If i4Value<>p_i4Value Then
  Begin
    i4Value:=p_i4Value;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_u1ScrollBarSlideFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarSlideFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_u1ScrollBarSlideFG(p_u1ScrollBarSlideFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarSlideFG<>p_u1ScrollBarSlideFG Then
  Begin
    u1ScrollBarSlideFG:=p_u1ScrollBarSlideFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_u1ScrollBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_u1ScrollBarSlideBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarSlideBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_u1ScrollBarSlideBG(p_u1ScrollBarSlideBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarSlideBG<>p_u1ScrollBarSlideBG Then
  Begin
    u1ScrollBarSlideBG:=p_u1ScrollBarSlideBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_u1ScrollBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_u1ScrollBarFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_u1ScrollBarFG(p_u1ScrollBarFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarFG<>p_u1ScrollBarFG Then
  Begin
    u1ScrollBarFG:=p_u1ScrollBarFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_u1ScrollBarFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlHScrollBar.Read_u1ScrollBarBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Read_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ScrollBarBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Read_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlHScrollBar.Write_u1ScrollBarBG(p_u1ScrollBarBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlHSCROLLBAR.Write_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
  If u1ScrollBarBG<>p_u1ScrollBarBG Then
  Begin
    u1ScrollBarBG:=p_u1ScrollBarBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlHSCROLLBAR.Write_u1ScrollBarBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


































//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLBUTTON Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor tctlBUTTON.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLBUTTON.create',SOURCEFILE);
  {$ENDIF}
  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_BUTTON;
  //TODO: make all new controls set their redraw flag,
  // and if their window doesn't have focus then set
  // that window's redraw flag.
  bUp:=True; 
  i4Width:=8;
  saCaption:='&Button';
  chHotKey:=#0;

  // used by buttons and Menus
  u1ButtonHotKeyFG    :=  gu1ButtonHotKeyFG      ;
  u1ButtonFGFocus     :=  gu1ButtonFGFocus       ;
  u1ButtonBGFocus     :=  gu1ButtonBGFocus       ;
  u1ButtonFG          :=  gu1ButtonFG            ;
  u1ButtonBG          :=  gu1ButtonBG            ;
  u1ButtonFGDisabled  :=  gu1ButtonFGDisabled    ;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLBUTTON.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
  begin
    tc(lpCTL).Item_ID2:=0; // Redraw
  end;

  If bVisible Then
  Begin
    VCSetPenXY(i4X, i4Y);
    If not bUp Then
    Begin
      VCSetFGC(TWindow(lpTWindow).u1FrameWindowFG);
      VCSetBGC(TWindow(lpTWindow).u1FrameWindowBG);
      VCWrite(' ');
    End;
    // left side of button
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
    Begin
      VCSetFGC(u1ButtonHotkeyFG);
      VCSetBGC(u1ButtonBGFocus);
      VCWrite(gchScrollBarRightArrow); // right pointing arrow 
    End
    Else
    Begin
      VCSetFGC(u1ButtonFG);
      VCSetBGC(u1ButtonBG);
      VCWrite(' ');
    End;
    chHotKey:=upcase(
    WriteHotKeyedText(
      saCaption,
      i4Width-2,
      bEnabled and p_bWindowHasFocus,
      p_bPaintWithFocusColors,
      u1ButtonFG,
      u1ButtonFGFocus,
      u1ButtonHotKeyFG,        
      u1ButtonFGDisabled,
      u1ButtonBGFocus,
      u1ButtonBG
    ));
    
    // right side of button
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
    Begin
      VCSetFGC(u1ButtonHotKeyFG);
      VCSetBGC(gu1ButtonBGFocus);//TODO: Make this "Black" programmable somehow
      VCWrite(gchScrollBarLeftArrow); // left pointing arrow
    End
    Else
    Begin
      VCSetFGC(u1ButtonFG);
      VCSetBGC(u1ButtonBG);
      VCWrite(' ');
    End;
    VCSetBgC(TWindow(lpTWindow).u1FrameWindowBG);
    If bUp Then
    Begin
      VCSetFGC(gu1ShadowBG); // BG used for ForeGround on purpose - not a typo
      VCWrite(gchButtonSide);//bottom half block
      VCWriteXY(i4X+1, i4Y+1,
        StringOfChar(gchButtonBottom,i4Width)); // top half block
    End
    Else
    Begin
      VCWriteXY(i4X+1, i4Y+1,
        StringOfChar(' ',i4Width)); // top half block
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Var rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}

  p_u4KEy:=p_u4Key;// shut up compiler

  If (not rLKey.bShiftPressed) and 
     (not rLKey.bAltPressed) and 
     (not rLKey.bCntlPressed) Then
  Begin
    If (rLKey.ch=#13) OR 
       (upcase(rLKEy.ch)=chHotKey) OR
       (rLKEy.ch=' ') Then
    Begin
      With TCTLBUTTON(TWindow(lpTWindow).C.Item_lpPTR) Do Begin
        bUp:=False;
        TWindow(lpTWindow).C.bRedraw:=True;
        TWindow(lpTWindow).PaintWindow;
        UpDateConsole;//grGfxOps.b pdateConsole:=false;
        WaitInMSec(250);
        bUp:=True;
        tC(lpCTL).bRedraw:=True;
        TWindow(lpTWindow).PaintWindow;
        //pdateconsole;
        grGfxOps.bUpdateConsole:=true;
        gbUnhandledKeypress:=False;
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_BUTTONDOWN;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_BUTTON;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlButton.ProcessKeyboard';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End; //end
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlButton.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var rSageMsg: rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  // TODO: Make Menu DropDown Mouse Up work like button - add a 
  //       grMSC command like here
  Case grMSC.uCMD Of
  MSC_NONE: Begin
    If not p_bMouseIdle Then
    Begin
      If rLMEvent.Buttons=MouseLeftButton Then
      Begin
        If (rLMEvent.Action and MouseActionDown)=MouseActionDown Then
        Begin
          If tc(lpCTL).FoundItem_lpPTR(self) Then 
            tc(lpCTL).bRedraw:=True;
          bUp:=False;
          With grMSC Do Begin
            uCMD:=MSC_ButtonDown;
            dTWindow:=0;
            iData:=0;
            uObjType:=OBJ_BUTTON;
            lpObj:=Self;
          End;//with
        End;
      End;
    End;
  End;
  MSC_ButtonDown: Begin
    If not p_bMouseIdle Then
    Begin
      If rLMEvent.Buttons<>MouseLeftButton Then
      Begin
        grMSC.uCMD:=MSC_NONE;
        If tc(lpCTL).FoundItem_lpPTR(self) Then 
          tc(lpCTL).bRedraw:=True;
        bUp:=True;
        If (rLMevent.VC=TWindow(lpTWindow).SELFOBJECTITEM.ID[2]) and
           (rLMEvent.VMX>=i4X) and 
           (rLMEvent.VMX<=i4X+i4Width-1) and
           (rLMEvent.VMY=i4Y) Then
        Begin
          With rSageMsg Do Begin
            lpPTR:=lpTWindow;
            uMsg:=MSG_BUTTONDOWN;
            uParam1:=0;
            uParam2:=CTLUID;
            uObjType:=OBJ_BUTTON;
            {$IFDEF LOGMESSAGES}
            saSender:='tctlButton.ProcessMouse';
            {$ENDIF}
          End;//with
          PostMessage(rSageMsg); 
        End;
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg   := MSG_PAINTWINDOW;
          uParam1:= 0;
          uParam2:= 0;
          uObjType:= OBJ_WINDOW;
          //lpptr:=;
          {$IFDEF LOGMESSAGES}
          saSender:='Button Wen Up - must Redraw Window:' + MSGTOTEXT(rSageMsg);
          {$ENDIF}
          saDescOldPackedTime:='';
          //uUID:=0;
        End;//with
        PostMessage(rSageMsg); 
        
      End;
    End;
  End;
  End;//case
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//TODO: Implement Stick button
//=============================================================================
Function tctlButton.Read_bSticky:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_bSticky',SOURCEFILE);
  {$ENDIF}
  Result:=bSticky;  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_bSticky',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_bSticky(p_bSticky:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_bSticky',SOURCEFILE);
  {$ENDIF}
  If bSticky<>p_bSticky Then
  Begin
    If not bSticky Then bUp:=True;
    bSticky:=p_bSticky;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_bSticky',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
//=============================================================================
Function tctlButton.Read_u1ButtonHotKeyFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonHotKeyFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonHotKeyFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonHotKeyFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonHotKeyFG(p_u1ButtonHotKeyFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_u1ButtonHotKeyFG',SOURCEFILE);
  {$ENDIF}
  If u1ButtonHotKeyFG<>p_u1ButtonHotKeyFG Then
  Begin
    u1ButtonHotKeyFG:=p_u1ButtonHotKeyFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_u1ButtonHotKeyFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_u1ButtonFGFocus: Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonFGFocus',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonFGFocus;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonFGFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonFGFocus(p_u1ButtonFGFocus:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.',SOURCEFILE);
  {$ENDIF}
  If u1ButtonFGFocus<>p_u1ButtonFGFocus Then
  Begin
    u1ButtonFGFocus:=p_u1ButtonFGFocus;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_u1ButtonBGFocus: Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonBGFocus',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonBGFocus;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonBGFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonBGFocus(p_u1ButtonBGFocus:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_u1ButtonBGFocus',SOURCEFILE);
  {$ENDIF}
  If u1ButtonBGFocus<>p_u1ButtonBGFocus Then
  Begin
    u1ButtonBGFocus:=p_u1ButtonBGFocus;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_u1ButtonBGFocus',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_u1ButtonFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonFG(p_u1ButtonFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_u1ButtonFG',SOURCEFILE);
  {$ENDIF}
  If u1ButtonFG<>p_u1ButtonFG Then
  Begin
    u1ButtonFG:=p_u1ButtonFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_u1ButtonFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_u1ButtonBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonBG(p_u1ButtonBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_u1ButtonBG',SOURCEFILE);
  {$ENDIF}
  If u1ButtonBG<>p_u1ButtonBG Then
  Begin
    u1ButtonBG:=p_u1ButtonBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_u1ButtonBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlButton.Read_u1ButtonFGDisabled:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Read_u1ButtonFGDisabled',SOURCEFILE);
  {$ENDIF}
  Result:=u1ButtonFGDisabled;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Read_u1ButtonFGDisabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlButton.Write_u1ButtonFGDisabled(p_u1ButtonFGDisabled:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlButton.Write_u1ButtonFGDisabled',SOURCEFILE);
  {$ENDIF}
  If u1ButtonFGDisabled<>p_u1ButtonFGDisabled Then
  Begin
    u1ButtonFGDisabled:=p_u1ButtonFGDisabled;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlButton.Write_u1ButtonFGDisabled',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TCTLButton.Read_saCaption:AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLButton.Read_saCaption',SOURCEFILE);
  {$ENDIF}
  Result:=saCaption;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLButton.Read_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLButton.Write_saCaption(p_saCaption:AnsiString);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLButton.Write_saCaption',SOURCEFILE);
  {$ENDIF}
  If saCaption<>p_saCaption Then
  Begin
    saCaption:=p_saCaption;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLButton.Write_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

























//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLPROGRESSBAR Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor tctlProgressBar.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLPROGRESSBAR.create',SOURCEFILE);
  {$ENDIF}
  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_PROGRESSBAR;

  i4Width:=20;
  i4MaxValue:=20;
  i4Value:=0;

  u1ProgressBarSlideFG :=gu1ProgressBarSlideFG  ;
  u1ProgressBarSlideBG :=gu1ProgressBarSlideBG  ;
  u1ProgressBarMarkerFG:=gu1ProgressBarMarkerFG ;
  u1ProgressBarMarkerBG:=gu1ProgressBarMarkerBG ;
  chProgressBarSlide   :=gchProgressBarSlide    ;
  chProgressBarMarker  :=gchProgressBarMarker   ;


  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLPROGRESSBAR.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var
  // bWindowHasFocus: boolean;
  // bCtlHasFocus: boolean;
  iT: LongInt;
  i4HScroll: LongInt;
  dHSize: Real;
  dHIndex: Real;
  dHPercent: Real;
  dHSSize: Real;
  dHSIndex: Real;

Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
    tc(lpCTL).Item_ID2:=0; // Redraw

  //bWindowHasFocus:=
  //  (JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID=gi4WindowHasFocusUID);
  //bCtlHasFocus:=bWindowHasFocus and (tc(lpCTL).N=tc(lpCTL).Item_i8User);
  
  If bVisible Then
  Begin
    dHSize := i4MaxValue;
    dHIndex := i4Value;
    If (dHSize>0) Then
      dHPercent := dHIndex/dHSize
    Else
      dHPercent := 1;
    dHSSize := i4Width;
    dHSIndex := dHPercent * dHSSize;
    
    i4HScroll := Round(dHSIndex);
    If(i4HScroll = 0) Then i4HScroll := 1; // TODO: Is this necessary?
     
    
    
    // ---- Draw it all.
    For iT := 1 To i4Width Do
    Begin
      If(iT < i4HScroll) OR (i4Value>=i4MaxValue)Then
      Begin
        VCSetFGC(u1ProgressBarMarkerFG); 
        VCSetBGC(u1ProgressBarMarkerBG);
        VCWriteCharXY(i4X+iT-1, i4Y, gchProgressBarMarker);
      End
      Else
      Begin
        VCSetFGC(u1ProgressBarSlideFG); 
        VCSetBGC(u1ProgressBarSlideBG);
        VCWriteCharXY(i4X+iT-1, i4Y, gchProgressBarSlide);
      End;
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tctlProgressBar.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_chProgressBarSlide:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_chProgressBarSlide',SOURCEFILE);
  {$ENDIF}
  Result:=chProgressBarSlide;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_chProgressBarSlide',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_chProgressBArSlide(p_chProgressBarSlide:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_chProgressBArSlide',SOURCEFILE);
  {$ENDIF}
  If chProgressBarSlide<>p_chProgressBarSlide Then
  Begin
    chProgressBarSlide:=p_chProgressBarSlide;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_chProgressBArSlide',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_chProgressBarmarker:Char;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_chProgressBarmarker',SOURCEFILE);
  {$ENDIF}
  Result:=chProgressBarmarker;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_chProgressBarmarker',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_chProgressBArmarker(p_chProgressBarmarker:Char);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_chProgressBArmarker',SOURCEFILE);
  {$ENDIF}
  If chProgressBarmarker<>p_chProgressBarmarker Then
  Begin
    chProgressBarmarker:=p_chProgressBarmarker;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_chProgressBArmarker',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_u1ProgressBarSlideFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_u1ProgressBarSlideFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ProgressBarSlideFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_u1ProgressBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_u1ProgressBarSlideFG(p_u1ProgressBarSlideFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_u1ProgressBarSlideFG',SOURCEFILE);
  {$ENDIF}
  If u1ProgressBarSlideFG<>p_u1ProgressBarSlideFG Then
  Begin
    u1ProgressBarSlideFG:=p_u1ProgressBarSlideFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_u1ProgressBarSlideFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_u1ProgressBarSlideBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_u1ProgressBarSlideBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ProgressBarSlideBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_u1ProgressBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_u1ProgressBarSlideBG(p_u1ProgressBarSlideBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_u1ProgressBarSlideBG',SOURCEFILE);
  {$ENDIF}
  If u1ProgressBarSlideBG<>p_u1ProgressBarSlideBG Then
  Begin
    u1ProgressBarSlideBG:=p_u1ProgressBarSlideBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_u1ProgressBarSlideBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_u1ProgressBarMarkerFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_u1ProgressBarMarkerFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ProgressBarMarkerFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_u1ProgressBarMarkerFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_u1ProgressBarMarkerFG(p_u1ProgressBarMarkerFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_u1ProgressBarMarkerFG',SOURCEFILE);
  {$ENDIF}
  If u1ProgressBarMarkerFG <> P_u1ProgressBarMarkerFG Then
  Begin
    u1ProgressBarMarkerFG:=p_u1ProgressBarMarkerFG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_u1ProgressBarMarkerFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_u1ProgressBarMarkerBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_u1ProgressBarMarkerBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1ProgressBarMarkerBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_u1ProgressBarMarkerBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_u1ProgressBarMarkerBG(p_u1ProgressBarMarkerBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_u1ProgressBarMarkerBG',SOURCEFILE);
  {$ENDIF}
  If u1ProgressBarMarkerBG<>p_u1ProgressBarMarkerBG Then
  Begin
    u1ProgressBarMarkerBG:=p_u1ProgressBarMarkerBG;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_u1ProgressBarMarkerBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tctlProgressBar.Read_i4MaxValue:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  Result:=i4MaxValue;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//TODO: Make maxvalue - if less than value adjust value 
//TODO: make smart enough not to calc ZERO max val's
//=============================================================================
Procedure tctlProgressBar.Write_i4MaxValue(p_i4MaxValue:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
  If i4MaxValue<>p_i4MaxValue Then
  Begin
    i4MaxValue:=p_i4Maxvalue;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_i4MaxValue',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlProgressBar.Read_i4Value:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Read_i4Value',SOURCEFILE);
  {$ENDIF}
  Result:=i4Value;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Read_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlProgressBar.Write_i4Value(p_i4Value:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlProgressBar.Write_i4Value',SOURCEFILE);
  {$ENDIF}
  If (i4Value<>p_i4Value) and (p_i4Value<=i4MaxValue) Then
  Begin
    i4Value:=p_i4Value;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlProgressBar.Write_i4Value',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





































//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLINPUT Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor tctlInput.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLInput.create',SOURCEFILE);
  {$ENDIF}
  Inherited;

  tc(lpCTL).Item_ID1:=OBJ_INPUT;

  i4CurPos:=1;
  i4Index:=1;
  i4SelStart:=0;
  i4SelLength:=0;
  i4MaxLength:=0;
  i4Width:=20;
  saData:='Hello';
  saUndo:='Hello';
  bPassWord:=False;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLInput.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================




//=============================================================================
Procedure tctlinput.StartSelection;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.StartSelection',SOURCEFILE);
  {$ENDIF}
  i4OldSelStart:=i4SelStart;
  i4OldSelLength:=i4SelLength;
  i4OldRealCurPos:=i4Index+i4CurPos-1;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.StartSelection',SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================

//=============================================================================
Procedure tctlinput.EndSelection(p_bMouse: Boolean);
//=============================================================================
Var i4RealCurPos: LongInt;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.EndSelection',SOURCEFILE);
  {$ENDIF}
  If (rLKEy.bShiftPressed) OR (p_bMouse) Then
  Begin
    i4RealCurPos:=i4Index+i4Curpos-1;
    If (i4OldRealCurPos<i4RealCurPos) Then // going right
    Begin
      If i4OldSelStart=0 Then
      Begin
        i4SelStart:=i4OldRealCurPos;
        i4SelLength:=i4RealCurPos-i4SelStart;
      End
      Else
      Begin
        If i4RealCurPos<=(i4OldSelStart+i4OldSelLength-1) Then
        Begin
          i4SelStart:=i4RealCurPos;
          i4SelLength:=i4SelLength-(i4SelStart-i4OldSelStart);
        End
        Else
        Begin
          If i4RealCurPos=(i4OldSelStart+i4OldSelLength) Then
          Begin
            i4SelStart:=0;
            i4SelLength:=0;
          End
          Else
          Begin
            If i4OldSelStart=i4OldRealCurPos Then
            Begin
              i4SelStart:=i4OldSelStart+i4OldSelLength;
            End;
            i4SelLength:=i4RealCurPos-i4SelStart;
          End;
        End;
      End; 
    End
    Else 
    Begin
      If (i4OldRealCurPos>i4RealCurPos) Then // going left
      Begin
        If i4OldSelStart=0 Then
        Begin
          i4SelStart:=i4RealCurPos;
          i4SelLength:=i4OldRealCurPos-i4SelStart;
        End
        Else
        Begin
          If i4RealCurPos>i4SelStart Then
          Begin
            i4SelLength:=i4RealCurPos-i4SelStart;
          End
          Else
          Begin
            If i4RealCurPos=i4SelStart Then
            Begin
              i4SelStart:=0;
              i4SelLength:=0;
            End
            Else
            Begin
              If i4OldRealCurPos=(i4OldSelStart+i4OldSelLength) Then
              Begin
                i4SelStart:=i4RealCurPos;
                i4SelLength:=i4OldSelStart-i4SelStart;
              End
              Else
              Begin
                i4SelStart:=i4RealCurPos;
                i4SelLength:=i4SelLength+(i4OldRealCurPos-i4RealCurPos);
              End;
            End;
          End;
        End;
      End;
    End; 
  End
  Else
  Begin
    i4SelStart:=0;
    i4SelLength:=0;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.EndSelection',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure tctlInput.PaintControl(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var
  iT: LongInt;
  u1CurFG, u1CurBG: Byte; // For colors
  i4CalcIndex: LongInt;//For Calculating Draw loop to saData offset
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlInput.PaintControl',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then tc(lpCTL).Item_ID2:=0; // Redraw

  If bVisible Then
  Begin
    // --- Set BLinky
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
    Begin
      VCSetCursorXY(i4CurPos+i4X-1,i4Y);
      If (VCGetCursorX>=1) and (VCGetCursorX<=VCWidth-3) and 
         (VCGetCursorY>=1) and (VCGetCursorY<=VCHeight-2) Then 
      Begin
        If gbInsertMode Then
          VCSetCursorType(crUnderLine)
        Else
          VCSetCursorType(crBlock);
      End;
    End;
    
    // Draw Control
    For iT:=1 To i4Width Do
    Begin
      i4CalcIndex:=i4Index+iT-1;
      If i4CalcIndex<=length(saData) Then
      Begin
        // Write Data
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then 
        Begin
          If (i4SelStart>0) and
           ((i4CalcIndex>=i4SelStart) and
            (i4CalcIndex<=(i4SelStart+i4SelLength-1))) Then
          Begin
            u1CurFG:=gu1SelectionFG;
          End
          Else
          Begin
            u1CurFG:=gu1DataFG;
          End;
        End
        Else 
        Begin
          u1CurFG:=gu1NoFocusFG;
        End;
        If (i4SelStart>0) and
           ((i4CalcIndex>=i4SelStart) and
            (i4CalcIndex<=(i4SelStart+i4SelLength-1))) Then
        Begin
          u1CurBG:=gu1SelectionBG;
        End
        Else
        Begin
          u1CurBG:=gu1DataBG;
        End;
        
        //debug
        //if i4CalcIndex=i4SelStart then u1BG:=2;
        If bPAssword Then
          VCPutAll(i4X+iT-1, i4Y, gchPassword, u1CurFG, u1CurBG)
        Else
          VCPutAll(i4X+iT-1, i4Y, saData[i4CalcIndex], u1CurFG, u1CurBG);
      End
      Else
      Begin
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then u1CurFG:=gu1DataFG Else u1CurFG:=gu1NoFocusFG;
        u1CurBG:=gu1TailBG;
        VCPutAll(i4X+iT-1, i4Y, gchInputTail, u1CurFG, u1CurBG);
      End;  
    End;
    
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then 
      u1CurFG:=TWindow(lpTWindow).u1FrameFG 
    Else 
      u1CurFG:=gu1NoFocusFG;
    u1CurBG:=TWindow(lpTWindow).u1FrameWindowBG;
    //TODO: these arrows should be defaulted from Window Text colors but then programmable.
    If i4Index>1 Then
      VCPutAll(i4X-1,i4Y,gchScrollBarLeftArrow, u1CurFG, u1CurBG)
    Else
      VCPutAll(i4X-1,i4Y,' ', u1CurFG, u1CurBG);
      
    If i4Index+i4Width-1<length(saData) Then
    Begin
      VCPutAll(i4X+i4Width,i4Y,gchScrollBarRightArrow, u1CurFG, u1CurBG)
    End
    Else
    Begin
      VCPutAll(i4X+i4Width,i4Y,' ', u1CurFG, u1CurBG);
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlInput.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


// TODO: make CNTL+DELETE Delete a "word" at a time.
//=============================================================================
Procedure tctlInput.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Var
  i4RealCurPos: LongInt;
  saTemp: AnsiString;

  Procedure DeleteSelection;
  Begin
    If i4SelStart>0 Then
    Begin
      DeleteString(saData,i4SelStart,i4SelLength);
      i4RealCurPos:=i4SelStart;
      i4SelStart:=0;
      i4SelLength:=0;
      If i4RealCurPos<1 Then i4RealCurPos:=1;
      // Position i4CurPos and i4Index based on i4RealCurPos
      If i4RealCurPos<i4Width Then
      Begin
        i4Index:=1;
        i4CurPos:=i4RealCurPos;
      End
      Else
      Begin
        i4Index:=i4RealCurPos-(i4Width Div 2);
        If i4Index<1 Then i4Index:=1;//safety
        i4CurPos:=i4RealCurPos-i4Index+1;
      End;      
    End;
  End;

  Procedure CopyToClipBoard;
  Begin
    If i4SelStart>0 Then
    Begin
      gsaClipBoard:=saFixedLength(saData, i4SelStart, i4SelLength);
    End;
  End;

  Procedure CutSelection;
  Begin
    If i4SelStart>0 Then
    Begin
      CopyToClipBoard;
      saTemp:=sadata;
      DeleteSelection;
      If saTemp<>saData Then saUndo:=saTemp;
    End;
  End;

  Procedure undo;
  Begin
    saTemp:=saData;
    i4SelStart:=0;
    i4SelLength:=0;
    saData:=saUndo;
    If saData<>saTemp Then saUndo:=saTemp;
  End;

  Procedure paste;
  Begin
    If (length(gsaClipBoard)>0) Then
    Begin
      If i4SelStart>0 Then
      Begin
        saTemp:=saData;
        DeleteString(saData,i4SelStart,i4SelLength);
        Insert(gsaClipBoard,saData, i4SelStart);
        i4RealCurPos:=i4SelStart+length(gsaClipBoard);
        If saTemp<>saData Then saUndo:=saTemp;
        i4RealCurPos:=i4SelStart;
        i4SelStart:=0;
        i4SelLength:=0;
        If i4RealCurPos<1 Then i4RealCurPos:=1;
        // Position i4CurPos and i4Index based on i4RealCurPos
        If i4RealCurPos<i4Width Then
        Begin
          i4Index:=1;
          i4CurPos:=i4RealCurPos;
        End
        Else
        Begin
          i4Index:=i4RealCurPos-(i4Width Div 2);
          If i4Index<1 Then i4Index:=1;//safety
          i4CurPos:=i4RealCurPos-i4Index+1;
        End;      
      End
      Else
      Begin
        saTemp:=saData;
        Insert(gsaClipBoard,saData,i4Index+i4CurPos-1);
        If saData<>saTemp Then saUndo:=saTemp;
        i4RealCurPos:=i4Index+i4CurPos-1+length(gsaClipBoard);
        i4SelStart:=0;
        i4SelLength:=0;
        If i4RealCurPos<1 Then i4RealCurPos:=1;
        // Position i4CurPos and i4Index based on i4RealCurPos
        If i4RealCurPos<i4Width Then
        Begin
          i4Index:=1;
          i4CurPos:=i4RealCurPos;
        End
        Else
        Begin
          i4Index:=i4RealCurPos-(i4Width Div 2);
          If i4Index<1 Then i4Index:=1;//safety
          i4CurPos:=i4RealCurPos-i4Index+1;
        End;      
      End;
    End;
  End;

  Procedure MarkAsHandledKeypress;
  Begin
    gbUnhandledKeypress:=False;
    TC(lpCTL).bRedraw:=True;
  End;

Begin

  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlInput.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}

  p_u4Key:=p_u4Key; // shutup compiler


  Case rLKey.u2KeyCode Of
  kbdInsert: Begin
    If (not rLKEy.bAltPRessed) and
       (not (rLKEy.bCntlPressed and rLKey.bShiftPressed)) Then
    Begin
      MarkAsHandledKeypress;
      If rLKEy.bCntlPressed Then
      Begin
        CopyToClipBoard;
      End
      Else
      If rLKey.bShiftPressed Then
      Begin
        Paste;
      End
      Else
      Begin
        gbInsertMode:=not gbInsertMode;
      End;
    End;
  End;
  kbdEnd: Begin
    If (not rLKEy.bAltPRessed) and
       (not rLKEy.bCntlPressed) Then
    Begin
      MarkAsHandledKeypress;
      If length(saData)>0 Then
      Begin
        StartSelection;
        i4Index:=length(saData)-i4Width+1;
        i4CurPos:=i4Width+1;
        If i4Index<1 Then 
        Begin
          i4Index:=1;
          i4CurPos:=length(saData)+1;
        End;
        EndSelection(False);
      End;
    End;
  End;
  kbdHome: Begin
    If (not rLKEy.bAltPRessed) and
       (not rLKEy.bCntlPressed) Then
    Begin
      MarkAsHandledKeypress;
      If length(saData)>0 Then
      Begin
        StartSelection;
        i4Index:=1;
        i4CurPos:=1;
        EndSelection(False);
      End;
    End;
  End;
  kbdLeft: Begin
    If (not rLKEy.bAltPRessed) Then
    Begin
      MarkAsHandledKeypress;
      If length(saData)>0 Then
      Begin
        StartSelection;
        If (not rLKEy.bCntlPressed) Then
        Begin
          If i4CurPos>1 Then
          Begin
            i4Curpos-=1;
          End
          Else
          Begin
            If i4Index>1 Then i4Index-=1;
          End;
        End
        Else
        Begin // CNTL Left
          // Try to Skip to Next Non space char
          i4RealCurPos:=i4Index+i4CurPos-1;
          If ((i4RealCurPos=length(saData)) and 
             (i4RealCurPos>0) and 
             (saData[i4RealCurpos]=' ')) OR 
             (i4RealCurPos<>length(saData)) Then
          Begin
            While (i4RealCurPos > 1) and 
                  (saData[i4RealCurPos]<>' ') Do i4RealCurPos-=1;
          End;
          While (i4RealCurPos > 1) and 
                ((i4RealCurPos>1) and
                (saData[i4RealCurPos-1]<>' ')) Do i4RealCurPos-=1;
          If i4RealCurPos<i4Width Then
          Begin
            i4Index:=1;
            i4CurPos:=i4RealCurPos;
          End
          Else
          Begin
            i4Index:=i4RealCurPos-(i4Width Div 2);
            If i4Index<1 Then i4Index:=1;//safety
            i4CurPos:=i4RealCurPos-i4Index+1;
          End;      
        End;
        EndSelection(False);
      End;
    End;
  End;
  kbdRight: Begin
    If (not rLKEy.bAltPRessed) Then
    Begin
      MarkAsHandledKeypress;
      If length(saData)>0 Then
      Begin
        StartSelection;
        If (not rLKEy.bCntlPressed) Then
        Begin
          If (i4CurPos<=i4Width) and 
             (i4CurPos+i4Index-1<=length(saData)) Then
          Begin
            i4Curpos+=1;
          End
          Else
          Begin
            // no minus 1 cuz we want the extra
            If i4Index+i4Width<=length(saData) Then
            Begin
              i4Index+=1;
            End;
          End;
        End
        Else
        Begin // CNTL Right
          // Try to Skip to Next Non space char
          i4RealCurPos:=i4Index+i4CurPos-1;
          If i4RealCurPos<length(saData) Then i4RealCurPos+=1;
          If i4RealCurPos>1 Then
          Begin
            While (i4RealCurPos < length(saData)) and 
                  
                  (not ((saData[i4RealCurPos-1]=' ') and
                        (saData[i4RealCurPos]<>' ')))
                 Do i4RealCurPos+=1;
            If i4RealCurPos=Length(sadata) Then i4RealCurPos+=1;
          End;
          If i4RealCurPos<i4Width Then
          Begin
            i4Index:=1;
            i4CurPos:=i4RealCurPos;
          End
          Else
          Begin
            i4Index:=i4RealCurPos-(i4Width Div 2);
            If i4Index<1 Then i4Index:=1;//safety
            i4CurPos:=i4RealCurPos-i4Index+1;
          End;      
          //------------------------------------------------
          // TODO: 
          // This is an unfinished attempt to right align
          // The Input box when tail char shows after
          // CNTL+RIGHT when saData longer than Width.
          // I decided this wasn't necessary 2002-12-29
          //------------------------------------------------
          //if i4Index+i4Width-1>length(saData) then
          //begin
          //  i4CurPos:=i4Index-(length(saData)-i4Width+1);
          //  i4Index:=length(saData)-i4Width+1;
          //end;
          //------------------------------------------------
        End;
        EndSelection(False);
      End;
    End;
  End;
  kbdDelete: Begin
    If (not rLKEy.bAltPRessed) and
       (not rLKEy.bCntlPressed) Then
    Begin
      MarkAsHandledKeypress;
      If (rLKEy.bShiftPressed) Then
      Begin
        CutSelection;
      End
      Else
      Begin
        If length(saData)>0 Then
        Begin
          If i4SelStart=0 Then
          Begin
            saTemp:=saData;
            DeleteString(saData,i4Index+i4CurPos-1,1);
            If saTemp<>saData Then saUndo:=saTemp;
          End
          Else
          Begin
            saTemp:=saData;
            DeleteSelection;
          End;
        End;
      End;
    End;
  End;
  Else Begin
    Case rLKey.ch Of
    #8: Begin //backspace
      If (not rLKey.bShiftPressed) and
         (not rLKEy.bAltPRessed) and
         (not rLKEy.bCntlPressed) Then
      Begin
        MarkAsHandledKeypress;
        If length(saData)>0 Then
        Begin
          If i4SelStart=0 Then
          Begin
            If (i4CurPos > 1) OR (i4Index>1) Then
            Begin
              If (i4Index>(i4Width Div 2)) Then
              Begin
                If (i4CurPos=(i4Width Div 2)) Then
                Begin
                  i4Index-=(i4Width Div 2);
                  i4CurPos+=(i4Width Div 2);
                End;
              End
              Else
              Begin
                If (i4CurPos<=(i4Width Div 2)) Then
                Begin
                  i4CurPos:=i4CurPos+i4Index-1;
                  i4Index:=1;
                End;
              End;
              
              If i4CurPos>1 Then
              Begin
                i4Curpos-=1;
              End
              Else
              Begin
                If i4Index>1 Then i4Index-=1;
              End;
              saTemp:=saData;
              DeleteString(saData, i4Index+i4CurPos-1, 1);
              If saTemp<>saData Then saUndo:=saTemp;
            End;
          End
          Else
          Begin
            saTemp:=saData;
            DeleteSelection;
            If saTemp<>saData Then saUndo:=saTemp;
          End;
        End;
      End;
    End;
    #13: Begin
      If (not rLKey.bShiftPressed) and
         (not rLKEy.bAltPRessed) and
         (not rLKEy.bCntlPressed) Then
      Begin
        MarkAsHandledKeypress;
        i4SelStart:=0;
        i4SelLength:=0;
        TWindow(lpTWindow).CntlChangeFocus(True,True);
        If (tc(lpCTL).FoundNth(tc(lpCTL).Item_i8User)) and
           (tc(lpCTL).Item_ID1=OBJ_INPUT) Then
        Begin
          i4SelStart:=0;
          i4SelLength:=0;
        End;
      End;
    End;
// purposely won't compile on another OS
// TODO: Make a Method of UNHARDCODING This so
//       built in help can explain the keypresses
//       dynamically. E.G. CNTL+Z=UNDO if compiled on win32/intel
//       and the help will reflect it automatically.
    #26: Begin // CNTL+Z - Cheap Undo
    // undo Code
      // TODO: Improve Undo Functionality.
      // Maybe so when the control Gets Focus it stores
      // saData, and when it loses focus the undo starts
      // over so EACH "got focus" is a new Snap Shot that isn't
      // taken until the first change. This way each input control
      // can lose focus, go back and restore to previous state
      // if desired.
      If (not rLKEy.bShiftPressed) and
         (not rLKEy.bAltPressed) Then
      Begin
        MarkAsHandledKeypress;
        Undo;
      End;
    End;
// purposely won't compile on another OS
// TODO: Make a Method of UNHARDCODING This so
//       built in help can explain the keypresses
//       dynamically. 
//       and the help will reflect it automatically.
    #3: Begin // CNTL+C - Copy
    // Copy code
      If (not rLKEy.bShiftPressed) and
         (not rLKEy.bAltPressed) Then
      Begin
        MarkAsHandledKeypress;
        CopyToClipBoard;
      End;
    End;
// purposely won't compile on another OS
// TODO: Make a Method of UNHARDCODING This so
//       built in help can explain the keypresses
//       dynamically. E.G. CNTL+T=Cut if compiled on win32/intel
//       (because CNTL-C aborts Program)
//       and the help will reflect it automatically.
    #20: Begin // CNTL+T - Cut
    // Copy code
      If (not rLKEy.bShiftPressed) and
         (not rLKEy.bAltPressed) Then
      Begin
        MarkAsHandledKeypress;
        CutSelection;
      End;
    End;
// purposely won't compile on another OS
// TODO: Make a Method of UNHARDCODING This so
//       built in help can explain the keypresses
//       dynamically. E.G. CNTL+V=Paste if compiled on win32/intel
//       and the help will reflect it automatically.
    #22: Begin // CNTL+V - Paste
      If (not rLKEy.bShiftPressed) and
         (not rLKEy.bAltPressed) Then
      Begin
        MarkAsHandledKeypress;
        Paste;
      End;
    End;
    #27: Begin // ESC
      // Unhandled
    End
    Else Begin
      // Actual Data Input
      If (not rLKey.bAltPressed) and 
         (not rLKey.bCntlPressed) Then
      Begin
        MarkAsHandledKeypress;
        If i4SelStart>0 Then
        Begin
          saTemp:=saData;
          DeleteString(saData,i4SelStart,i4SelLength);
          If saTemp<>saData Then saUndo:=saTemp;
          i4RealCurPos:=i4SelStart;
          i4SelStart:=0;
          i4SelLength:=0;
          If i4RealCurPos<1 Then i4RealCurPos:=1;
          // Position i4CurPos and i4Index based on i4RealCurPos
          If i4RealCurPos<i4Width Then
          Begin
            i4Index:=1;
            i4CurPos:=i4RealCurPos;
          End
          Else
          Begin
            i4Index:=i4RealCurPos-(i4Width Div 2);
            If i4Index<1 Then i4Index:=1;//safety
            i4CurPos:=i4RealCurPos-i4Index+1;
          End;      
        End;
        If ((length(saData)<i4MaxLength) OR (i4MaxLength=0)) and 
           (rLKey.ch<>#0) Then
        Begin
          If gbInsertMode Then
          Begin
            saTemp:=saData;
            Insert(rLKey.ch,saData,i4CurPos+i4Index-1);  
            If saTemp<>saData Then saUndo:=saTemp;
          End
          Else
          Begin
            If length(saData)>=(i4CurPos+i4Index-1) Then
            Begin
              saTemp:=saData;
              saData[i4CurPos+i4Index-1]:=rLKey.ch;
              If saTemp<>saData Then saUndo:=saTemp;
            End
            Else
            Begin
              saTemp:=saData;
              saData:=saData+rLKey.ch;
              If saTemp<>saData Then saUndo:=saTemp;
            End;
          End;
          If i4CurPos<i4Width+1 Then
          Begin
            i4CurPos+=1;
          End
          Else
          Begin
            i4Index+=1;
          End;
        End;
      End;
    End;
    End;//case
  End;
  End;//case
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlInput.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlInput.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var 
  i4WX: LongInt;
  i4BookMarkN: longint;
    
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlInput.ProcessMouse',SOURCEFILE);
  {$ENDIF}
  i4BookMarkN:=tc(lpCTL).N;
  If (grMSC.uCMD=MSC_NONE) and (not p_bMouseIdle) Then
  Begin
    If rLMEvent.Buttons=MouseLeftButton Then
    Begin
      If (rLMEvent.Action and MouseActionDown)=MouseActionDown Then
      Begin
        i4CurPos:=(rLmEvent.VMX-i4X+1);
        While i4CurPos > length(saData)+1 Do i4CurPos-=1;
        i4SelStart:=0;
        i4SelLength:=0;
        StartSelection;
        With grMSC Do Begin
          uCMD:=MSC_InputSel;
          dTWindow:=0;
          iData:=0;
          uObjType:=OBJ_INPUT;
          lpObj:=Self;
        End;//with
        gbUnhandledMouseEvent:=false;
      End;
    End;
  End;
  
  
  Case grMSC.uCMD Of
  MSC_InputSel: Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then
    Begin
      SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
      i4WX:=VCGetX;
      tc(lpCTL).bRedraw:=True; 
      If rLMEvent.ConsoleX<i4WX+i4X-1 Then
      Begin
        If i4CurPos>1 Then 
          i4CurPos:=1
        Else
          If i4Index>1 Then i4Index-=1;
      End
      Else
      If rLMEvent.ConsoleX>i4WX+i4X+i4Width-1 Then
      Begin
        If i4CurPos<i4Width+1 Then
          i4CurPos:=i4Width+1
        Else
          If i4CurPos+i4Index-1<length(saData)+1 Then i4Index+=1;
      End
      Else
      Begin
        i4CurPos:=rLMEvent.ConsoleX-i4WX-i4X+2;
      End;  
      While i4CurPos > length(saData)+1 Do i4CurPos-=1;
      EndSelection(True);  
      If ((rLMEvent.Buttons and MouseLeftButton)=0) Then
      Begin
        grMSC.uCMD:=MSC_NONE;
      End;
      gbUnhandledMouseEvent:=false;
    End;
  End;
  End;//switch
  tc(lpCTL).FoundNth(i4BookMarkN);

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlInput.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLINPUT.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLINPUT.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TCTLINPUT.Read_saData:AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_saData',SOURCEFILE);
  {$ENDIF}
  Result:=sadata;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_saData',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

// TODO: make Cursor adjust to new data smarter - 
//       now it just jumps to a safe spot. first position
//=============================================================================
Procedure TCTLINPUT.Write_saData(p_saData:AnsiString);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Write_saData',SOURCEFILE);
  {$ENDIF}
  If saData<>p_saData Then 
  Begin
    saData:=p_saData;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    i4Index:=1;
    i4CurPos:=1; 
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Write_saData',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLINPUT.Read_i4SelStart:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_i4SelStart',SOURCEFILE);
  {$ENDIF}
  Result:=i4SelStart;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_i4SelStart',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLINPUT.Write_i4SelStart(p_i4SelStart:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Write_i4SelStart',SOURCEFILE);
  {$ENDIF}
  If i4SelStart<>p_i4SelStart Then
  Begin
    If (p_i4SelStart>=0) and (p_i4SelStart+i4SelLength-1<=length(saData)) Then
    Begin
      i4SelStart:=p_i4SelStart; //TODO: Make this work right
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Write_i4SelStart',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLINPUT.Read_i4SelLength:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_i4SelLength',SOURCEFILE);
  {$ENDIF}
  Result:=i4SelLength;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_i4SelLength',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//TODO: make work right
//=============================================================================
Procedure TCTLINPUT.Write_i4SelLength(p_i4SelLength:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Write_i4SelLength',SOURCEFILE);
  {$ENDIF}
  If i4SelLength<>p_i4SelLength Then
  Begin
    If (p_i4SelLength+i4SelStart-1<=length(saData)) Then
    Begin
      i4SelLength:=p_i4SelLength;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Write_i4SelLength',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function TCTLINPUT.Read_i4RealCurPos:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_i4RealCurPos',SOURCEFILE);
  {$ENDIF}
  Result:=i4CurPos+i4Index-1;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_i4RealCurPos',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLINPUT.Write_i4RealCurPos(p_i4RealCurPos:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Write_i4RealCurPos',SOURCEFILE);
  {$ENDIF}
  
  If p_i4RealCurPos<>(i4CurPos+i4Index-1) Then
  Begin
    If (p_i4RealCurPos<=length(saData)) and (p_i4RealCurPos>0) Then
    Begin
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
      If p_i4RealCurPos<i4Width Then
      Begin
        i4Index:=1;
        i4CurPos:=p_i4RealCurPos;
      End
      Else
      Begin
        i4Index:=p_i4RealCurPos-(i4Width Div 2);
        If i4Index<1 Then i4Index:=1;//safety
        i4CurPos:=p_i4RealCurPos-i4Index+1;
      End;      
    End;//TODO: Log Error if illegal realcurpos sent?
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Write_i4RealCurPos',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TCTLINPUT.Read_bPAssword:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Read_bPAssword',SOURCEFILE);
  {$ENDIF}
  Result:=bPassword;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Read_bPAssword',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure TCTLINPUT.Write_bPassword(p_bPassword:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLINPUT.Write_bPassword',SOURCEFILE);
  {$ENDIF}
  If bPassword<>p_bPassword Then
  Begin
    bPassword:=p_bPassword;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLINPUT.Write_bPassword',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlinput.read_i4MaxLength: LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlinput.read_i4MaxLength',SOURCEFILE);
  {$ENDIF}

  Result:=i4MaxLength;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlinput.read_i4MaxLength',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlinput.write_i4MaxLength(p_i:Integer);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlinput.write_i4MaxLength',SOURCEFILE);
  {$ENDIF}

  i4MaxLength:=p_i;
  If p_i<length(saData) Then Begin // redraw if truncated
    SetLength(saData,p_i);
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlinput.write_i4MaxLength',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================






























//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLCHECKBOX Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor tctlCheckBox.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.create',SOURCEFILE);
  {$ENDIF}
  Inherited;

  tc(lpCTL).Item_ID1:=OBJ_CHECKBOX;
  
  i4Width:=11;
  u1FG:=TWindow(lpTWindow).u1FrameFG;
  u1BG:=TWindow(lpTWindow).u1FrameBG;
  u1CheckFG:=TWindow(lpTWindow).u1FrameCaptionFG;  
  u1CheckBG:=TWindow(lpTWindow).u1FrameCaptionBG;  
  bChecked:=False;  
  saCaption:='Default';
  bRadioStyle:=False;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var t: LongInt;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.paintcontrol',SOURCEFILE);
  {$ENDIF}
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  If tc(lpCTL).FoundItem_UID(CTLUID) Then
    tc(lpCTL).Item_ID2:=0; // Redraw
  If bVisible Then
  Begin
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
      VCSetFGC(u1FG)
    Else
      VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1BG);
    If bRadioStyle Then
      VCWriteXY(i4X,i4Y,gchRadioLeft)
    Else
      VCWriteXY(i4X,i4Y,gchCheckLeft);
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
      VCSetFGC(u1CheckFG)
    Else
      VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1CheckBG);
    If bChecked Then 
    Begin
      If bRadioStyle Then
        VCWriteXY(i4X+1,i4Y,gchRadio)
      Else
        VCWriteXY(i4X+1,i4Y,gchCheck);
    End
    Else
    Begin
      VCWriteXY(i4X+1,i4Y,' ');
    End;
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
      VCSetFGC(u1FG)
    Else
      VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1BG);
    If bRadioStyle Then
      VCWriteXY(i4X+2,i4Y,gchRadioRight)
    Else
      VCWriteXY(i4X+2,i4Y,gchCheckRight);

    If i4Width>3 Then
    Begin
      If p_bWindowHasFocus Then
        VCSetFGC(u1FG)
      Else
        VCSetFGC(gu1NoFocusFG);

      For t:=1 To i4Width-4 Do
      Begin
        If length(saCaption)>=t Then
        Begin
          VCWriteXY(i4X+t+3, i4Y, saCaption[t]);
        End
        Else
        Begin
          VCWriteXY(i4X+t+3, i4Y, ' ');
        End;
      End;
    End;
  End;

  //SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);
  //If tc(lpCTL).FoundItem_UID(CTLUID) Then
  //  tc(lpCTL).Item_ID2:=0; // Redraw
  //If bVisible Then
  //Begin
  //  If tc(lpCTL).Item_i8User=tc(lpCTL).n Then
  //    VCSetFGC(u1FG)
  //  Else
  //    VCSetFGC(gu1NoFocusFG);
  //  VCSetBGC(u1BG);
  //  If bRadioStyle Then
  //    VCWriteXY(i4X,i4Y,gchRadioLeft)
  //  Else
  //    VCWriteXY(i4X,i4Y,gchCheckLeft);
  //  If tc(lpCTL).Item_i8User=tc(lpCTL).n Then
  //    VCSetFGC(u1CheckFG)
  //  Else
  //    VCSetFGC(gu1NoFocusFG);
  //  VCSetBGC(u1CheckBG);
  //  If bChecked Then 
  //  Begin
  //    If bRadioStyle Then
  //      VCWriteXY(i4X+1,i4Y,gchRadio)
  //    Else
  //      VCWriteXY(i4X+1,i4Y,gchCheck);
  //  End
  //  Else
  //  Begin
  //    VCWriteXY(i4X+1,i4Y,' ');
  //  End;
  //  If tc(lpCTL).Item_i8User=tc(lpCTL).n Then
  //    VCSetFGC(u1FG)
  //  Else
  //    VCSetFGC(gu1NoFocusFG);
  //  VCSetBGC(u1BG);
  //  If bRadioStyle Then
  //    VCWriteXY(i4X+2,i4Y,gchRadioRight)
  //  Else
  //    VCWriteXY(i4X+2,i4Y,gchCheckRight);
  //
  //  If i4Width>3 Then
  //  Begin
  //    For t:=1 To i4Width-4 Do
  //    Begin
  //      If length(saCaption)>=t Then
  //      Begin
  //        VCWriteXY(i4X+t+3, i4Y, saCaption[t]);
  //      End
  //      Else
  //      Begin
  //        VCWriteXY(i4X+t+3, i4Y, ' ');
  //      End;
  //    End;
  //  End;
  //End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.paintcontrol',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_u1FG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_u1FG',SOURCEFILE);
  {$ENDIF}
  Result:=u1fg;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_u1FG(p_u1FG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_u1FG',SOURCEFILE);
  {$ENDIF}
  If p_u1FG<>u1FG Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    u1FG:=p_u1FG;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_u1BG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_u1BG',SOURCEFILE);
  {$ENDIF}
  Result:=u1BG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_u1BG(p_u1BG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_u1BG',SOURCEFILE);
  {$ENDIF}
  If p_u1BG<>u1BG Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    u1BG:=p_u1BG;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_u1CheckFG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_u1CheckFG',SOURCEFILE);
  {$ENDIF}
  Result:=u1CheckFG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_u1CheckFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_u1CheckFG(p_u1CheckFG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_u1CheckFG',SOURCEFILE);
  {$ENDIF}
  If p_u1CheckFG<>u1CheckFG Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    u1CheckFG:=p_u1CheckFG;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_u1CheckFG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_u1CheckBG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_u1CheckBG',SOURCEFILE);
  {$ENDIF}
  Result:=u1CheckBG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_u1CheckBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_u1CheckBG(p_u1CheckBG:Byte);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_u1CheckBG',SOURCEFILE);
  {$ENDIF}
  If p_u1CheckBG<>u1CheckBG Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    u1CheckBG:=p_u1CheckBG;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_u1CheckBG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_bChecked:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_bChecked',SOURCEFILE);
  {$ENDIF}
  Result:=bChecked;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_bChecked',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_bChecked(p_bChecked:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_bChecked',SOURCEFILE);
  {$ENDIF}
  If p_bChecked<>bChecked Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    bChecked:=p_bChecked;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_bChecked',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tctlCheckBox.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If (i4Width<>p_i4Width) and (p_i4Width>=3) Then
  Begin
    i4Width:=p_i4Width; 
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_saCaption:AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.Read_saCaption',SOURCEFILE);
  {$ENDIF}
  Result:=saCaption;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.Read_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_saCaption(p_saCaption:AnsiString);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.Write_saCaption',SOURCEFILE);
  {$ENDIF}
  If saCaption<>p_saCaption Then
  Begin
    saCaption:=p_saCaption;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.Write_saCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlCheckBox.Read_bRadioStyle:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Read_bRadioStyle',SOURCEFILE);
  {$ENDIF}
  Result:=bRadioStyle;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Read_bRadioStyle',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlCheckBox.Write_bRadioStyle(p_bRadioStyle:Boolean);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('TCTLCHECKBOX.Write_bRadioStyle',SOURCEFILE);
  {$ENDIF}
  If p_bRadioStyle<>bRadioStyle Then
  Begin
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    bRadioStyle:=p_bRadioStyle;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('TCTLCHECKBOX.Write_bRadioStyle',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
Procedure tctlCheckBox.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Var rSageMsg:rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}

  p_u4KEy:=p_u4Key;// shut up compiler

  If (not rLKey.bShiftPressed) and 
     (not rLKey.bAltPressed) and 
     (not rLKey.bCntlPressed) Then
  Begin
    If (rLKey.ch=#13) OR 
       (rLKEy.ch=' ') Then
    Begin
      bChecked:= not bChecked;
      tc(lpCTL).bRedraw:=True;
      gbUnhandledKeypress:=False;
      With rSageMsg Do Begin
        lpPTR:=lpTWindow;
        uMsg:=MSG_CHECKBOX;
        uParam1:=0;
        uParam2:=CTLUID;
        uObjType:=OBJ_CHECKBOX;
        {$IFDEF LOGMESSAGES}
        saSender:='tctlCheckBox.ProcessKeyboard';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlCheckBox.ProcessMouse(p_bMouseIdle: Boolean);
//=============================================================================
Var rSageMsg:rtSageMsg;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlCheckBox.ProcessMouse',SOURCEFILE);
  {$ENDIF}

  // TODO: Make Menu DropDown Mouse Up work like button - add a 
  //       grMSC command like here
  
  if gbUnhandledMouseEvent then
  begin
    If rLMEvent.Buttons=MouseLeftButton Then
    Begin
      If (rLMEvent.Action and MouseActionDown)=MouseActionDown Then
      Begin
        If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
        bChecked:=not bChecked;
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_CHECKBOX;
          uParam1:=0;
          uParam2:=CTLUID;
          uObjType:=OBJ_CHECKBOX;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlCheckBox.ProcessMouse';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
        gbUnhandledMouseEvent:=false;
      End;
    End;
  end;
    
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlCheckBox.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





















//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//                          TCTLLISTBOX Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor TCTLLISTBOX.create(p_TWindow:TWindow);
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlLISTBOX.create',SOURCEFILE);
  {$ENDIF}

  Inherited;
  tc(lpCTL).Item_ID1:=OBJ_LISTBOX;
  bSorting:=False;
  i4Width:=20;
  i4DataWidth:=40;
  i4Height:=5;
  u1FG:=TWindow(lpTWindow).u1FrameFG;
  u1BG:=TWindow(lpTWindow).u1FrameBG;
  bShowCheckMarks:=True;
  CPL:=JFC_XDL.create; // Caption List
  DTL:=JFC_XDL.create; // Data List
  i4Top:=1;  // Position Scroll Up/Down offset
  i4Left:=1; // position scroll left/right offset
  HScrollBAr:=tctlHScrollBar.create(p_TWindow);
  HScrollBAr.bPrivate:=True;
  HScrollBar.lpOwner:=self;
  HScrollBar.uOwnerObjType:=OBJ_LISTBOX;
  
  VScrollBAr:=tctlVScrollBar.create(p_TWindow);
  VScrollBAr.bPrivate:=True;
  VScrollBar.lpOwner:=self;
  VScrollBar.uOwnerObjType:=OBJ_LISTBOX;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlLISTBOX.create',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor TCTLLISTBOX.Destroy;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlLISTBOX.DestroyList',SOURCEFILE);
  {$ENDIF}

  Inherited;
  
  //DeleteAllCaptions;
  CPL.Destroy;
  DTL.Destroy;
  HScrollBar.Destroy;
  VScrollBAr.Destroy;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlLISTBOX.DestroyList',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.paintcontrol(p_bWindowHasFocus: boolean; p_bPaintWithFocusColors: boolean);
//=============================================================================
Var ty: LongInt;
    TempN: LongInt;
    //bCtlHasFocus: Boolean;
    //bWinGotFocus: boolean;
    //bGotFocus: boolean;
    iBookMarkCTLUID: longint;
    
//    sa: ansistring;
    
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlLISTBOX.PaintControl',SOURCEFILE);
  {$ENDIF}
  
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_UID(CTLUID) Then tc(lpCTL).bRedraw:=False; // Redraw
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);

  TempN:=DTL.N;
  SetActiveVC(TWindow(lpTWindow).SELFOBJECTITEM.ID[2]);

  If i4Left<1 Then i4Left:=1;
  
  VScrollBar.X:=i4X+i4Width;
  VScrollBar.Y:=i4Y;
  VScrollBar.Height:=i4Height;
  VScrollBar.Visible:=(DTL.ListCount>i4Height-CPL.ListCount) and bVisible and (not bSorting);
  VScrollBar.Enabled:=bEnabled;  
  If DTL.ListCount>0 Then
  Begin
    VScrollBar.MaxValue:=DTL.ListCount;
    VScrollBar.Value:=DTL.N;
  End;
  
  HScrollBar.X:=i4X;
  HScrollBar.Y:=i4Y+i4Height;
  HScrollBar.Width:=i4Width;
  If bShowCheckMarks Then
  Begin
    HScrollBar.Visible:=(i4DataWidth>i4Width-2) and bVisible and (not bSorting);
  End
  Else
  Begin
    HScrollBar.Visible:=(i4DataWidth>i4Width) and bVisible and (not bSorting);  
  End;
  HScrollBar.Enabled:=bEnabled;  
  HScrollBar.i4MaxValue:=i4DataWidth-i4Width+1;
  HScrollBar.Value:=i4Left;



  If bSorting Then
  Begin
    If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
      VCSetFGC(u1FG)
    Else
      VCSetFGC(gu1NoFocusFG);
    VCSetBGC(u1BG);
    VCFillBox(i4X,i4Y,i4Width,i4Height,'.');
    VCWriteXY(i4X,i4Y,'Sorting...');
  End
  Else
  Begin  
    If bVisible Then
    Begin
      ty:=1;
      If CPL.ListCount>0 Then
      Begin
        CPL.MoveFirst;
        If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
          VCSetFGC(u1FG)
        Else
          VCSetFGC(gu1NoFocusFG);
        VCSetBGC(u1BG);
        repeat
          If ty<=i4Height Then
          Begin
            VCWriteXY(i4X,i4Y+ty-1,
              saFixedLength(CPL.Item_saName, i4Left, i4Width));
          End;
          ty+=1;
        Until not CPL.MoveNext;
      End;
      If CPL.ListCount<i4Height Then
      Begin
        If DTL.N>i4Height-CPL.ListCount+i4Top-1 Then 
        Begin
          i4Top:=DTL.N-(i4Height-CPL.ListCount)+1;
        End
        Else If DTL.N<i4Top Then i4Top:=DTL.N;
      End;
      If DTL.ListCount>0 Then
      Begin
        If not DTL.FoundNth(i4Top) Then 
        Begin
          i4Top:=1;
          DTL.MoveFirst;
        End;
        repeat
          If ty<=i4Height Then
          Begin
            If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
            Begin
              If TempN=DTL.N Then
              Begin
                // TODO:: This ByteCast Stuff will NEED to be addressed on 64bit platform!!
                If rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]=16 Then
                  VCSetFGC(gu1SelectionFG)
                Else
                  VCSetFGC(rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]);
              End
              Else  
              Begin
                If rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]=16 Then
                  VCSetFGC(gu1DataFG)
                Else
                  VCSetFGC(rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]);
              End;
            End
            Else
            Begin
              VCSetFGC(gu1NoFocusFG);
            End;
            If TempN=DTL.N Then
              VCSetBGC(gu1SelectionBG)
            Else
              VCSetBGC(gu1DataBG);
  
            If bShowCheckMarks Then
            Begin
              If rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]=1 Then
              begin
                VCWriteXY(i4X,i4Y+ty-1,gchCheck+' '+saFixedLength(JFC_XDLITEM(DTL.lpItem).saName,i4Left,i4Width-2));                
              end
              Else
              begin
                VCWriteXY(i4X,i4Y+ty-1,'  '+saFixedLength(JFC_XDLITEM(DTL.lpItem).saName,i4Left,i4Width-2));
              end;
            End
            Else
            Begin
              VCWriteXY(i4X,i4Y+ty-1,saFixedLength(JFC_XDLITEM(DTL.lpItem).saName,i4Left,i4Width));
            End;  
          End;
          ty+=1;
        Until (ty>i4Height) OR (not DTL.MoveNext);
      End;
      If p_bWindowHasFocus and p_bPaintWithFocusColors and bEnabled Then
        VCSetFGC(gu1TailFG)
      Else
        VCSetFGC(gu1NoFocusFG);
      VCSetBGC(gu1TailBG);
      While ty<=i4Height Do Begin
        VCWriteXY(i4X,i4Y+ty-1,StringOfChar(gchInputTail,i4Width));
        ty+=1;
      End;
    End;
    DTL.FoundNth(TempN);
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlLISTBOX.PaintControl',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_i4Width:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_i4Width',SOURCEFILE);
  {$ENDIF}
  Result:=i4Width;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_i4Width(p_i4Width:LongInt);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If i4Width<>p_i4Width Then
  Begin
    i4Width:=p_i4Width; 
  
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);

    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_i4Height:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_i4Height',SOURCEFILE);
  {$ENDIF}
  Result:=i4Height;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_i4Height(p_i4Height:LongInt);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_i4Height',SOURCEFILE);
  {$ENDIF}
  If i4Height<>p_i4Height Then
  Begin
    i4Height:=p_i4Height;

    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);

    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_i4Height',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_i4DataWidth:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_i4DataWidth',SOURCEFILE);
  {$ENDIF}
  Result:=i4DataWidth;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_i4DataWidth',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_i4DataWidth(p_i4DataWidth:LongInt);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_i4DataWidth',SOURCEFILE);
  {$ENDIF}
  If (i4DataWidth<>p_i4DataWidth) Then
  Begin
    i4DataWidth:=p_i4DataWidth; 
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_i4DataWidth',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_u1FG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_u1FG',SOURCEFILE);
  {$ENDIF}
  Result:=u1FG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_u1FG(p_u1FG:Byte);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_u1FG',SOURCEFILE);
  {$ENDIF}
  If u1FG<>p_u1FG Then
  Begin
    u1FG:=p_u1FG;
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_u1FG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_u1BG:Byte;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_u1BG',SOURCEFILE);
  {$ENDIF}
  Result:=u1BG;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_u1BG(p_u1BG:Byte);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_u1BG',SOURCEFILE);
  {$ENDIF}
  If u1BG<>p_u1BG Then
  Begin
    u1BG:=p_u1BG;
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_u1BG',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.GetCaption(p_N:LongInt): AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.GetCaption',SOURCEFILE);
  {$ENDIF}

  If CPL.FoundNth(p_N) Then
  Begin
    Result:=CPL.ITEM_saName;
  End
  Else
  Begin
    Result:='';
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.GetCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.SetCaption(p_N:LongInt; p_sa: AnsiString);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.SetCaption',SOURCEFILE);
  {$ENDIF}

  If CPL.FoundNth(p_N) Then
  Begin
    If CPL.Item_saName<>p_sa Then
    Begin
      CPL.Item_saName:=p_sa;//AnsiString(JFC_DLITEM(JFC_DL(CPL.lpItem).lpItem).lpPTR):=p_sa;//AnsiString(JFC_DL(CPL.lpItem).Item_lpPTR):=p_sa; //This version generates FPC Compiler Error-Internal: 200410231
      iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;
  End;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.SetCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
    
//=============================================================================
Procedure tctlListBox.AppendCaption(p_saCaption: AnsiString);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.AppendCaption',SOURCEFILE);
  {$ENDIF}

  CPL.AppendItem_saName(p_saCaption);
  //GetMem(CPL.DL^.PTR,4);
  //AnsiString(JFC_DLITEM(JFC_DL(CPL.lpItem).lpItem).lpPTR):=p_saCaption;//AnsiString(JFC_DL(CPL.lpItem).Item_lpPTR):=p_saCaption;
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.AppendCaption',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tCtlListBox.DeleteAllCaptions;
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.DeleteAllCaptions',SOURCEFILE);
  {$ENDIF}

  If CPL.ListCount>0 Then
  Begin
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    CPL.DeleteAll;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.DeleteAllCaptions',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.ListCount: LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.ListCount',SOURCEFILE);
  {$ENDIF}
  
  Result:=DTL.ListCount;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.ListCount',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Append(p_bSelected: Boolean; p_saData: AnsiString);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Append',SOURCEFILE);
  {$ENDIF}

  DTL.AppendItem;
  DTL.Item_saName:=p_saData;
  If p_bSelected Then
    rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=1
  Else
    rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=0;
  rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]:=16;//means use gu1DataFG in paint
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Append',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
  
//=============================================================================
Procedure tctlListBox.Insert(p_bSelected: Boolean; p_saData: AnsiString);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Insert',SOURCEFILE);
  {$ENDIF}

  DTL.InsertItem;
  DTL.Item_saName:=p_saData;
  If p_bSelected Then
    rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=1
  Else
    rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=0;
  rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]:=16;//means use gu1DataFG in paint
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then 
    TWindow(lpTWindow).bRedraw:=True;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Insert',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================
  
//=============================================================================
Procedure tctlListBox.Delete;
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Delete',SOURCEFILE);
  {$ENDIF}

  If DTL.ListCount>0 Then
  Begin
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then 
      TWindow(lpTWindow).bRedraw:=True;
    DTL.DeleteItem;
  End;  

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Delete',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_CurrentItem:LongInt;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.read_CurrentItem',SOURCEFILE);
  {$ENDIF}
  
  Result:=DTL.N;
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.read_CurrentItem',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_CurrentItem(p_n:LongInt);
//=============================================================================
Var TempN: LongInt;
Var rSageMsg:rtSageMsg;
iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_CurrentItem',SOURCEFILE);
  {$ENDIF}
  rSageMsg.lpPTR:=nil;//shutupcompiler

  If p_n<>DTL.N Then
  Begin
    TempN:=DTL.N;
    If DTL.FoundNth(p_n) Then 
    Begin
      iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
      If rSageMsg.uMSG<>MSG_FIRSTCALL Then
      Begin
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_LISTBOXMOVE;
          uParam1:=DTL.N;
          uParam2:=CTLUID;
          uObjType:=OBJ_LISTBOX;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlListBox.Write_CurrentItem';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End;
    End
    Else
    Begin
      DTL.FoundNth(TempN);
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_CurrentItem',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.Read_Selected:Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_Selected',SOURCEFILE);
  {$ENDIF}

  If DTL.ListCount>0 Then
  Begin
    Result:=rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]=1;
  End
  Else
  Begin
    Result:=False;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_Selected',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_Selected(p_bSelected: Boolean);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_Selected',SOURCEFILE);
  {$ENDIF}

  If DTL.ListCount>0 Then
  Begin
    If (p_bSelected and (rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]<>1)) OR
       ((not p_bSelected) and (rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]<>0)) Then
    Begin
      If p_bSelected Then
        rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=1
      Else
        rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[0]:=0;
      iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_Selected',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.ProcessKeyboard(p_u4Key: Cardinal);
//=============================================================================
Var 
  bRedraw:Boolean;
  rSageMsg:rtSageMsg;
  iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}

  p_u4Key:=p_u4Key;// shut up compiler

  bRedraw:=False;
  
  Case rLKEY.u2KeyCode Of
  kbdUP: Begin
    gbUnhandledKeypress:=False;
    If DTL.MovePrevious Then
    Begin
      bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=lpTWindow;
        uMsg:=MSG_LISTBOXMOVE;
        uParam1:=DTL.N;
        uParam2:=CTLUID;
        uObjType:=OBJ_LISTBOX;
        {$IFDEF LOGMESSAGES}
        saSender:='tctlListBox.ProcessKeyboard';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
  End;
  kbdDown: Begin
    gbUnhandledKeypress:=False;
    if DTL.MoveNext then
    Begin
      bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=lpTWindow;
        uMsg:=MSG_LISTBOXMOVE;
        uParam1:=DTL.N;
        uParam2:=CTLUID;
        uObjType:=OBJ_LISTBOX;
        {$IFDEF LOGMESSAGES}
        saSender:='tctlListBox.ProcessKeyboard';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
  End;
  kbdLeft: Begin
    If i4Left>1 Then i4Left-=i4Width Div 2;
    If i4Left<1 Then i4Left:=1;
    bRedraw:=True;
    gbUnhandledKeypress:=False;
  End;
  kbdRight: Begin
    gbUnhandledKeypress:=False;
    If i4Left<i4DataWidth-i4Width+1 Then i4Left+=i4Width Div 2;
    If i4Left>i4DataWidth-i4Width+1 Then i4Left:=i4DataWidth-i4width+1;
    bRedraw:=True;
    //SageLog(1,'ListBox debug - i4Left:'+inttostr(i4Left)+
    // ' i4DataWidth:'+inttostr(i4Datawidth)+
    // ' i4Width:'+inttostr(i4Width));
    
  End;
  kbdPGUP: Begin
    gbUnhandledKeypress:=False;
    If DTL.ListCount>0 Then
    Begin
      If DTL.N>1 Then 
      Begin
        If DTL.N>i4Height-CPL.listCount Then 
        Begin
          DTL.FoundNth(DTL.N-(i4Height-CPL.listCount));
          i4Top-=i4Height-CPL.listCount;
        End
        Else
        Begin
          DTL.MoveFirst;
        End;
        bRedraw:=True;
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_LISTBOXMOVE;
          uParam1:=DTL.N;
          uParam2:=CTLUID;
          uObjType:=OBJ_LISTBOX;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlListBox.ProcessKeyboard';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End;
    End;
  End;
  kbdPGDN: Begin
    gbUnhandledKeypress:=False;
    If DTL.ListCount>0 Then
    Begin
      If DTL.N<DTL.ListCount Then 
      Begin
        If DTL.N<=i4Height-CPL.listCount+i4Top-1 Then 
        Begin
          i4Top+=i4Height-CPL.listCount;
          DTL.FoundNth(DTL.N+(i4Height-CPL.listCount));
        End
        Else
        Begin
          DTL.MoveLast;
        End;
        bRedraw:=True;
        With rSageMsg Do Begin
          lpPTR:=lpTWindow;
          uMsg:=MSG_LISTBOXMOVE;
          uParam1:=DTL.N;
          uParam2:=CTLUID;
          uObjType:=OBJ_LISTBOX;
          {$IFDEF LOGMESSAGES}
          saSender:='tctlListBox.ProcessKeyboard';
          {$ENDIF}
        End;//with
        PostMessage(rSageMsg); 
      End;
    End;
  End;
  kbdHOME: Begin
    gbUnhandledKeypress:=False;
    If DTL.ListCount>0 Then
    Begin
      DTL.MoveFirst;
      bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=lpTWindow;
        uMsg:=MSG_LISTBOXMOVE;
        uParam1:=DTL.N;
        uParam2:=CTLUID;
        uObjType:=OBJ_LISTBOX;
        {$IFDEF LOGMESSAGES}
        saSender:='tctlListBox.ProcessKeyboard';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
  End;
  kbdEND: Begin
    gbUnhandledKeypress:=False;
    If DTL.MoveLast Then
    begin
      bRedraw:=True;
      With rSageMsg Do Begin
        lpPTR:=lpTWindow;
        uMsg:=MSG_LISTBOXMOVE;
        uParam1:=DTL.N;
        uParam2:=CTLUID;
        uObjType:=OBJ_LISTBOX;
        {$IFDEF LOGMESSAGES}
        saSender:='tctlListBox.ProcessKeyboard';
        {$ENDIF}
      End;//with
      PostMessage(rSageMsg); 
    End;
  End;
  Else
  Begin
    gbUnhandledKeypress:=False;
    bRedraw:=True;
    With rSageMsg Do Begin
      lpPTR:=lpTWindow;
      uMsg:=MSG_LISTBOXKEYPRESS;
      uParam1:=DTL.N;
      uParam2:=CTLUID;
      uObjType:=OBJ_LISTBOX;
      {$IFDEF LOGMESSAGES}
      saSender:='tctlListBox.ProcessKeyboard';
      {$ENDIF}
    End;//with
    PostMessage(rSageMsg); 
  End;
  End;//case

  If bRedraw Then
  Begin
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  End;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.ProcessKeyboard',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.ProcessMouse(p_bMouseIdle: Boolean); 
//=============================================================================
Var {LX,} LY,ListLine: LongInt;
    bRedraw: Boolean;
Var rSageMsg:rtSageMsg;
iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.ProcessMouse',SOURCEFILE);
  {$ENDIF}

//  (rLMevent.VMX>=tCtlListBox(DL^.PTR).i4X) and
//  (rLMevent.VMX<=tCtlListBox(DL^.PTR).i4X+tCtlListBox(DL^.PTR).i4Width-1) and
//  (rLMEvent.VMY>=tCtlListBox(DL^.PTR).i4Y) and 
//  (rLMevent.VMY<=tCtlListBox(DL^.PTR).i4Y+tCtlListBox(DL^.PTR).i4Height-1);

  // First Find Out the Line (if Any) We are on in the data portion of the list.
  bRedraw:=False;
  
  If DTL.ListCount>0 Then
  Begin
    If (not p_bMouseIdle) and
       ((rLMEvent.Action and MouseActionDown)=MouseActionDown) and
       ((rLMEvent.Buttons and MouseLeftButton)=MouseLeftButton) Then
    Begin
      gbUnhandledMouseEvent:=False;
      //LX:=rLMevent.VMX-i4X+1; // dont need this yet
      LY:=rLMevent.VMY-i4Y-CPL.ListCount+1;  
      If LY>0 Then
      Begin
        ListLine:=LY+i4Top-1;
        If ListLine<=DTL.ListCount Then
        Begin
          If ListLine<>DTL.N Then
          Begin
            DTL.FoundNth(ListLine);
            bRedraw:=True;
            With rSageMsg Do Begin
              lpPTR:=lpTWindow;
              uMsg:=MSG_LISTBOXMOVE;
              uParam1:=DTL.N;
              uParam2:=CTLUID;
              uObjType:=OBJ_LISTBOX;
              {$IFDEF LOGMESSAGES}
              saSender:='tctlListBox.ProcessMouse';
              {$ENDIF}
            End;//with
            PostMessage(rSageMsg); 
          End
          Else
          Begin
            bRedraw:=True;
            With rSageMsg Do Begin
              lpPTR:=lpTWindow;
              uMsg:=MSG_LISTBOXCLICK;
              uParam1:=DTL.N;
              uParam2:=CTLUID;
              uObjType:=OBJ_LISTBOX;
              {$IFDEF LOGMESSAGES}
              saSender:='tctlListBox.ProcessMouse';
              {$ENDIF}
            End;//with
            PostMessage(rSageMsg); 
          End;
        End;
      End;
    End;
  End;  

  If bRedraw Then
  Begin
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  End;



  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.ProcessMouse',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure tctlListBox.DeleteAll;
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.DeleteAll',SOURCEFILE);
  {$ENDIF}

  DTL.Deleteall;
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.DeleteAll',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Sort(p_bForward: Boolean; p_bCaseSensitive: Boolean);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Sort',SOURCEFILE);
  {$ENDIF}

  bSorting:=True;
  iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
  If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
  tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
  TWindow(lpTWindow).PaintWindow;
  //pdateconsole;
  grGfxOps.bUpdateConsole:=true;
  DTL.SORTITEM_saName(p_bForward, p_bCaseSensitive);
  CurrentItem:=1;//Does cause redraw.
  bSorting:=False;

  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Sort',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.ChangeItemFG(p_u1FG: Byte);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
  If DTL.ListCount>0 Then
  Begin
    If ((p_u1FG=gu1DataFG) and (rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]<>16)) OR
       ((p_u1FG<>gu1DataFG) and (rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]<>p_u1FG)) Then
    Begin
      If p_u1FG=gu1DataFG Then 
        rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]:=16
      Else
        rt8ByteCast(JFC_XDLITEM(DTL.lpItem).i8User).u1[1]:=p_u1FG;
      iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;  
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_i4Width',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================


//=============================================================================
Function tctlListBox.read_itemtext: AnsiString;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.read_itemText',SOURCEFILE);
  {$ENDIF}
  If DTL.ListCount>0 Then
  Begin
    Result:=DTL.Item_saName;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.read_itemtext',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.write_itemtext(p_ItemText: AnsiString);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_itemtext',SOURCEFILE);
  {$ENDIF}
  If DTL.ListCount>0 Then
  Begin
    If p_itemtext<>DTL.Item_saName Then
    Begin
      DTL.Item_saName:=p_itemText;
      iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
      If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
      tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
      If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
    End;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_itemtext',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function tctlListBox.read_itemtag: longint;
//=============================================================================
var i8: Int64;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.read_itemTag',SOURCEFILE);
  {$ENDIF}
  result:=0;
  If DTL.ListCount>0 Then
  Begin
    i8:=DTL.Item_i8User;
    Result:=rt8LongCast(i8).i4[1];
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.read_itemtag',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.write_itemtag(p_i4Tag: longint);
//=============================================================================
var i8: Int64;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Write_itemtag',SOURCEFILE);
  {$ENDIF}
  If DTL.ListCount>0 Then
  Begin
    i8:=DTL.Item_i8User;
    rt8LongCast(i8).i4[1]:=p_i4Tag;
    DTL.Item_i8User:=i8;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Write_itemtag',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================




//=============================================================================
Function tctlListBox.Read_bShowCheckMArks: Boolean;
//=============================================================================
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_bShowCheckMarks',SOURCEFILE);
  {$ENDIF}
   Result:=bShowCheckMarks;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_bShowCheckMarks',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure tctlListBox.Write_bShowCheckMarks(p_bShowCheckMarks: Boolean);
//=============================================================================
var iBookMarkCTLUID: longint;
Begin
  {$IFDEF DEBUGLOGBEGINEND}
  DebugIn('tctlListBox.Read_bShowCheckMarks',SOURCEFILE);
  {$ENDIF}
  If p_bShowCheckMArks<>bShowCheckMarks Then
  Begin
    bShowCheckMarks:=p_bShowCheckMArks;
    iBookMarkCTLUID:=TWINDOW(lpTWindow).CurrentCTLID;
    If tc(lpCTL).FoundItem_lpPTR(self) Then tc(lpCTL).bRedraw:=True;
    tc(lpCTL).FoundItem_UID(iBookMarkCTLUID);
    If (gi4WindowHasFocusUID<>JFC_XXDLITEM(TWINDOW(lpTWindow).SELFOBJECTITEM).UID) Then TWindow(lpTWindow).bRedraw:=True;
  End;
  {$IFDEF DEBUGLOGBEGINEND}
  DebugOut('tctlListBox.Read_bShowCheckMarks',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================







//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  gbSageUI_Enabled:=true;
  gbSageUIUnitInitialized:=False;  
  gbInsertMode:=True;
  gbTrulyIDLE:=True;
  {$IFDEF DEBUGWINDOWS}
  gbGetOBJECTSXXDLStatsEnabled:=False;
  {$ENDIF}
  dtLastScreenUpdate:=now;
  gMsgBoxWindow:=nil;
  gInputBoxWindow:=nil;
  gFBWindow:=nil;
  guVCDebugHasFocus:=0;//stars (0 thru 3 background vc's )
  //gMB:=nil;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
