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
// Test Sage UI
program tui;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='tui.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================



//=============================================================================
Uses 
//=============================================================================
sysutils
,ug_common
,ug_jegas
,uc_console
,uc_sageui
;


//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************




//=============================================================================
// MenuBar Constants
Const
     // File
    mnuNew = 100;
    mnuNewTemplate = 110;
    mnuOpenProject = 120;
    mnuReopen = 130;
    mnuNewSourceFile = 140;
    mnuNewResourceFile = 150;
    mnuSaveUnit = 160;
    mnuSaveUnitAs = 170;
    mnuSaveAll = 180;
    mnuCloseProject = 190;
    mnuClose = 200;
    mnuPrint = 210;
    mnuExit = 220;

     // Edit
    mnuUndo = 230;
    mnuRedo = 240;
    mnuCut = 250;
    mnuCopy = 260;
    mnuPaste = 270;
    mnuInsert = 280;
    mnuToggleBookmarks = 290;
    mnuGotoBookmarks = 300;
    mnuSelectAll = 310;

     // Search
    mnuFind = 320;
    mnuFindnext = 330;
    mnuFindandReplace = 340;
    mnuGotoline = 350;

     // View
    mnuProjectManager = 360;
    mnuStatusBar = 370;
    mnuCompilerOutput = 380;
    mnuToolBars = 390;

     // Project
    mnuNewUnitinProject = 400;
    mnuAddtoproject = 410;
    mnuRemovefromproject = 420;
    mnuSetmainunit = 430;
    mnuEditResourceFile = 440;
    mnuGenerateMakefile = 450;
    mnuProjectoptions = 460;

     // Execute
    mnuCompile = 470;
    mnuRun = 480;
    mnuCompileandRun = 490;
    mnuRebuildAll = 500;
    mnuDebug = 510;

     // Options
    mnuCompileroptions = 520;
    mnuEnvironmentOptions = 530;
    mnuIconsStyle = 540;

     // Tools
    mnuCompileresults = 550;
    mnuToolsconfiguration = 560;
    mnuDosShell = 570;
    mnuExplorer = 580;
    mnuPackageManager = 590;
    mnuSetupCreator = 600;

     // Window
    mnuTile = 610;
    mnuCascade = 620;
    mnuArrangeicons = 630;
    mnuCloseAll = 640;
    mnuMinimizeAll = 650;
    mnuFullscreenmode = 660;
    mnuNext = 670;
    mnuPrevious = 680;

     // Help
    mnuHelp = 690;
    mnuTutorial = 700;
    mnuGNUDebuggerHelp = 710;
    mnuGettheDriftYet = 720;
    mnuCreated20020919 = 730;
    mnuByJasonPSage = 740;
    mnujasonpsagehotmailcom = 750;
    mnuEmailmeifyoulikethis = 760;

//=============================================================================






//=============================================================================
Var
//=============================================================================
  byIdleFG: Byte;

  Window: array [1..10] Of TWindow;
  ctlLabel: tctlLabel;
  ctlInput: tctlInput;
  //vcmsg: Cardinal;
//=============================================================================




//=============================================================================
Function MainMsgHandler(Var p_rSageMsg: rtSageMsg):Cardinal;
//=============================================================================
Begin
  //Sagelog(1,'I AM A MAINMSGHANDLER:'+MSGTOTEXT(p_rSageUIMsg),SOURCEFILE);
  Result:=0;
End;
//=============================================================================



// For Windows
//=============================================================================
Function MsgHandler(Var p_rSageMsg: rtSageMsg):Cardinal;
//=============================================================================
Begin
  //Sagelog(1,'I AM A MSGHANDLER:'+MSGTOTEXT(p_rSageUIMsg),SOURCEFILE);
  Result:=0;
End;
//=============================================================================






















//=============================================================================
Procedure InitProgram;
//=============================================================================
Var u4Menu: Cardinal;
    t: LongInt;
Begin

//  
//    //SetGfxSchema(2);
//    //SetColorSchema(2);
//    gbMenuEnabled:=True;
//    gbMenuVisible:=True;
//    //DrawMenuBar;
//  
//    u4Menu:=AddMenuBarItem('&File',True);
//    AddMenuPopUpItem(u4Menu,'&New',True,mnuNew);
//    AddMenuPopUpItem(u4Menu,'New &Template',True,mnuNewTemplate);
//    AddMenuPopUpItem(u4Menu,'&Open Project',True,mnuOpenProject);
//    AddMenuPopUpItem(u4Menu,'&Reopen',True,mnuReopen);
//    AddMenuPopUpItem(u4Menu,'New Source &File',True,mnuNewSourceFile);
//    AddMenuPopUpItem(u4Menu,'New Reso&urce File',True,mnuNewResourceFile);
//    AddMenuPopUpItem(u4Menu,'&Save Unit',True,mnuSaveUnit);
//    AddMenuPopUpItem(u4Menu,'Save Unit &As...',True,mnuSaveUnitAs);
//    AddMenuPopUpItem(u4Menu,'Save A&ll',True,mnuSaveAll);
//    AddMenuPopUpItem(u4Menu,'Close Pro&ject',True,mnuCloseProject);
//    AddMenuPopUpItem(u4Menu,'&Close',True,mnuClose);
//    AddMenuPopUpItem(u4Menu,'-',True,0);
//    AddMenuPopUpItem(u4Menu,'&Print',True,mnuPrint);
//    AddMenuPopUpItem(u4Menu,'-',True,mnuExit);
//    AddMenuPopUpItem(u4Menu,'E&xit',True,mnuExit);
//    
//    u4Menu:=AddMenuBarItem('&Edit',True);
//    AddMenuPopUpItem(u4Menu,'&Undo',True,mnuUndo);
//    AddMenuPopUpItem(u4Menu,'&Redo',True,mnuReDo);
//    AddMenuPopUpItem(u4Menu,'-',True,0);
//    AddMenuPopUpItem(u4Menu,'Cu&t',True,mnuCut);
//    AddMenuPopUpItem(u4Menu,'&Copy',True,mnuCopy);
//    AddMenuPopUpItem(u4Menu,'&Paste',True,mnuPaste);
//    AddMenuPopUpItem(u4Menu,'-',True,0);
//    AddMenuPopUpItem(u4Menu,'&Insert',True,mnuInsert);
//    AddMenuPopUpItem(u4Menu,'&Toggle Bookmarks',True,mnuToggleBookMarks);
//    AddMenuPopUpItem(u4Menu,'&Goto Bookmarks',True,mnuGotoBookMarks);
//    AddMenuPopUpItem(u4Menu,'-',True,0);
//    AddMenuPopUpItem(u4Menu,'&Select All',True,mnuSelectAll);

  
  
  gRCW.saCaption:='First Test Caption';
  gRCW.X:=35;
  gRCW.Y:=2;
  gRCW.Width:=43;
  gRCW.Height:=16;
  gRCW.bFrame:=True;
  gRCW.WindowState:=WS_NORMAL;
  gRCW.bCaption:=True;
  gRCW.bMinimizeButton:=True;
  gRCW.bMaximizeButton:=True;
  gRCW.bCloseButton:=True;
  gRCW.bSizable:=True;
  gRCW.bVisible:=True;
  gRCW.bEnabled:=True;
  gRCW.lpfnWndProc:=@msgHandler;
  gRCW.bAlwaysOnTop:=False;

  For t :=1 To 10 Do 
  begin
    Window[t]:=TWindow.create(gRCW);
    ctlLabel:=tctllabel.create(Window[t]);
    ctlLabel.X:=3;
    ctlLabel.Y:=4;
    ctlLabel.Width:=15;
    ctlLabel.Height:=6;
    //ctlLabel.TextColor:=White;
    //ctlLabel.BackColor:=Black;
    ctlLabel.Caption:='This is The Win32/DOS Look (My Favorite)';
    ctlLabel.Enabled:=True;
    ctlLabel.Visible:=True;
  
    ctlInput:=tctlInput.create(Window[t]);
    ctlInput.X:=21;
    ctlInput.Y:=4;
    ctlInput.Data:='Input Data Here Man I should be bigger than control';

    ctlInput:=tctlInput.create(Window[t]);
    ctlInput.X:=21;
    ctlInput.Y:=6;
    ctlInput.Data:='Input Data Here Man I should be bigger than control';

  End;
  {
  ctlInput:=tctlInput.create(Window[1]);
  ctlInput.X:=21;
  ctlInput.Y:=6;
  ctlInput.Data:='Input Data Here Man I should be bigger than control';
  }
  
  // Remove create msg
  SetActiveVC(guVCMain);
  VCFillBoxCtr(VCWidth, VCHeight,gchScreenBGChar);
  byidleFG:=0;
  //updateconsole;
End;
//=============================================================================


//=============================================================================
Procedure RunApplication;
//=============================================================================
Var rSageMsg: rtSageMsg;
Begin
  While Getmessage(rSageMsg) Do Begin
    DispatchMessage(rSageMsg);
  End;
End;
//=============================================================================




//=============================================================================
// Main Program Starts Here
//=============================================================================
Begin
  deletefile(csLOG_FILENAME_DEFAULT);
  If InitSageUI(@MainMsgHandler) Then
  Begin 
    InitProgram; 
    RunApplication;
    DoneSageUI;
  End
  Else
  Begin
    JLog(cnLog_ERROR,200902081259, 'tui - create Failed',sourcefile);
  End;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
