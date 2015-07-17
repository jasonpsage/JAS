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
// Test the Console Base GUI SageUI
program test_uc_sageui;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$DEFINE SOURCEFILE:='test_uxxc_sageui.pas'}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$DEFINE MENUENABLED}
{$IFDEF MENUENABLED}
  {$INFO | FEATURE: MENU}
{$ENDIF}

{$DEFINE WIN01ENABLED}
{$IFDEF WIN01ENABLED}
  {$INFO | FEATURE: WIN 01}
{$ENDIF}

{$DEFINE WIN02ENABLED}
{$IFDEF WIN02ENABLED}
  {$INFO | FEATURE: WIN 02}
{$ENDIF}

{$DEFINE WIN03ENABLED}
{$IFDEF WIN03ENABLED}
  {$INFO | FEATURE: WIN 03}
{$ENDIF}

{$DEFINE WIN04ENABLED}
{$IFDEF WIN04ENABLED}
  {$INFO | FEATURE: WIN 04}
{$ENDIF}
//=============================================================================


//=============================================================================
Uses 
//=============================================================================
sysutils
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_dir
//,ug_cgiin
//,ug_cgiout
,ug_ipc_send_file
,ug_ipc_wait_file
,ug_ipc_recv_file
,uc_console
,uc_library
,uc_animate
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
    mnuemail = 750;
    mnuEmailmeifyoulikethis = 760;

//=============================================================================






//=============================================================================
Var
//=============================================================================
  //byIdleFG: Byte;

  //Window: array [1..10] Of TWindow;
  //
  //ctlLabel: tctlLabel;
  //ctlVScrollBar: tctlvscrollbar;
  //ctlHScrollBar: tctlHscrollbar;
  //ctlProgressBar: tctlProgressbar;
  //ctlInput: tctlInput;
  //ctlInput01: tctlInput;
  //ctlButton01: tctlbutton;
  //ctlButton02: tctlbutton;
  //ctlCheckBox: tctlCheckBox;  
  
  //ctlLabel3: tctlLabel;
  //ctlVScrollBar3: tctlvscrollbar;
  //ctlHScrollBar3: tctlHscrollbar;
  //ctlProgressBar3: tctlProgressbar;
  //ctlInput3: tctlInput;

  //ctlListBox: tctlListBox;

  vcmsg: UINT;
//=============================================================================

//Function MainMsgHandler(p_rSageMsg: rtSageMsg):UINT;
//begin
//  writeln('test_uxxc_sageui - MainMsgHandler - BEGIN');
//  result:=0;
//  writeln('test_uxxc_sageui - MainMsgHandler - END');
//end;

//=============================================================================
Function MainMsgHandler(p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
      //---
      Procedure DisplayMsg;
      //---
      Var sa: AnsiString;
      Begin
        Case p_rSageMsg.uMsg Of
        MSG_IDLE:              sa:='MSG_IDLE';
        MSG_UNHANDLEDKEYPRESS: sa:='MSG_UNHANDLEDKEYPRESS';
        MSG_UNHANDLEDMOUSE:    sa:='MSG_UNHANDLEDMOUSE';
        MSG_MENU:              sa:='MSG_MENU';
        Else sa:='Not Sure';
        End;//case
        
        
        SetActiveVC(guVCStatusBar);
        VCWriteXY(13,1,saFixedLength(sa,1,20));
        VCWrite(' P1:' + saFixedLength(inttostr(p_rSageMsg.uParam1),1,8));
        VCWrite(' P2:' + saFixedLength(inttostr(p_rSageMsg.uParam2),1,8));
        VCWrite(' ObjType:' + saFixedLength(inttostr(p_rSageMsg.uObjType),1,8));
        VCWrite(' u4Msg:' + saFixedLength(inttostr(p_rSageMsg.uMsg),1,8));
      End;
      //---

Var     
  u2ShellResult: word;
Begin
  //Log(cnLog_Debug,201201312004,'MainMsgHandler Entry',SOURCEFILE);
  
  Case p_rSageMsg.uMsg Of
  MSG_UNHANDLEDKEYPRESS: Begin
  End;

  MSG_UNHANDLEDMOUSE: Begin
  End;

  MSG_BUTTONDOWN: Begin
    //DisplayMSG;
  End;

  MSG_MENU: Begin
    //DisplayMsg;
    //grGFXops.b pDateConsole:=True;
    Case p_rSageMsg.uParam1 Of
     // File
    mnuNew                          : Begin
      {$IFDEF Win32}
      u2ShellResult:=u2CShell('test_uxxc_animate.exe','');
      ReDrawConsole;
      MsgBox('Shell Results:test_uxxc_animate','Returned Value:'+inttostr(u2ShellResult),MB_OK);
      {$ELSE}
      u2ShellREsult:=u2Shell('./ta','');
      ReDrawConsole;
      MsgBox('Shell Results:./ta','Returned Value:'+inttostr(u2ShellResult),MB_OK);
      {$ENDIF}
    End;
    mnuNewTemplate                  : ;
    mnuOpenProject                  : ;
    mnuReopen                       : ;
    mnuNewSourceFile                : ;
    mnuNewResourceFile              : ;
    mnuSaveUnit                     : ;
    mnuSaveUnitAs                   : ;
    mnuSaveAll                      : ;
    mnuCloseProject                 : ;
    mnuClose                        : ;
    mnuPrint                        : ;
    mnuExit                         : Begin
      With p_rSageMsg Do Begin
        uMsg    := MSG_SHUTDOWN;
        uParam1 := 0;
        uParam2 := 0;
        uObjType:= 0;
        lpptr    :=nil;
        //saSender:='USER';
      End;//with
      PostMessage(p_rSageMsg);
    End;

     // Edit
    mnuUndo                         : ;
    mnuRedo                         : ;
    mnuCut                          : ;
    mnuCopy                         : ;
    mnuPaste                        : ;
    mnuInsert                       : ;
    mnuToggleBookmarks              : ;
    mnuGotoBookmarks                : ;
    mnuSelectAll                    : ;

     // Search
    mnuFind                         : ;
    mnuFindnext                     : ;
    mnuFindandReplace               : ;
    mnuGotoline                     : ;

     // View
    mnuProjectManager               : ;
    mnuStatusBar                    : ;
    mnuCompilerOutput               : ;
    mnuToolBars                     : ;

     // Project
    mnuNewUnitinProject             : ;
    mnuAddtoproject                 : ;
    mnuRemovefromproject            : ;
    mnuSetmainunit                  : ;
    mnuEditResourceFile             : ;
    mnuGenerateMakefile             : ;
    mnuProjectoptions               : ;

     // Execute
    mnuCompile                      : ;
    mnuRun                          : ;
    mnuCompileandRun                : ;
    mnuRebuildAll                   : ;
    mnuDebug                        : ;

     // Options
    mnuCompileroptions              : ;
    mnuEnvironmentOptions           : ;
    mnuIconsStyle                   : ;

     // Tools
    mnuCompileresults               : ;
    mnuToolsconfiguration           : ;
    mnuDosShell                     : ;
    mnuExplorer                     : ;
    mnuPackageManager               : ;
    mnuSetupCreator                 : ;

     // Window
    mnuTile                         : ;
    mnuCascade                      : ;
    mnuArrangeicons                 : ;
    mnuCloseAll                     : ;
    mnuMinimizeAll                  : ;
    mnuFullscreenmode               : ;
    mnuNext                         : ;
    mnuPrevious                     : ;

     // Help
    mnuHelp                         : ;
    mnuTutorial                     : ;
    mnuGNUDebuggerHelp              : ;
    mnuGettheDriftYet               : ;
    mnuCreated20020919              : ;
    mnuByJasonPSage                 : ;
    mnuemail         : ;
    mnuEmailmeifyoulikethis         : ;

    End; // case
  End;
  End; //case

  Result:=0;
End;
//=============================================================================



// For Windows
//=============================================================================
Function MsgHandler(p_rSageMsg: rtSageMsg):UINT;
//=============================================================================
Var sa: AnsiString;
Begin
  //riteln('test_uxxc_sageui - MsgHandler - BEGIN');
  SetActiveVC(VCMsg);
  Case p_rSageMsg.uMsg Of
  MSG_IDLE               :sa:='MSG_IDLE';
  MSG_FIRSTCALL          :sa:='MSG_FIRSTCALL';
  MSG_UNHANDLEDKEYPRESS  :sa:='MSG_UNHANDLEDKEYPRESS';
  MSG_UNHANDLEDMOUSE     :sa:='MSG_UNHANDLEDMOUSE';
  MSG_MENU               :sa:='MSG_MENU';
  MSG_SHUTDOWN           :sa:='MSG_SHUTDOWN';
  MSG_CLOSE              :sa:='MSG_CLOSE';
  MSG_DESTROY            :sa:='MSG_DESTROY';
  MSG_BUTTONDOWN         :sa:='MSG_BUTTONDOWN';
  MSG_LOSTFOCUS          :sa:='MSG_LOSTFOCUS';
  MSG_GOTFOCUS           :sa:='MSG_GOTFOCUS';
  MSG_CTLLOSTFOCUS       :sa:='MSG_CTLLOSTFOCUS';//+inttostr(p_rSageMsg.uUID);
  MSG_CTLGOTFOCUS        :sa:='MSG_CTLGOTFOCUS';//+inttostr(p_rSageMsg.uUID);
  MSG_WINDOWSTATE        :sa:='MSG_WINDOWSTATE';
  MSG_WINDOWRESIZE       :sa:='MSG_WINDOWRESIZE';
  MSG_WINDOWMOVE         :sa:='MSG_WINDOWMOVE';
  MSG_CTLSCROLLLEFT      :sa:='MSG_SCROLLLEFT';
  MSG_CTLSCROLLRIGHT     :sa:='MSG_SCROLLRIGHT';
  MSG_CTLSCROLLUP        :sa:='MSG_SCROLLUP';
  MSG_CTLSCROLLDOWN      :sa:='MSG_SCROLLDOWN';
  MSG_CHECKBOX           :sa:='MSG_CHECKBOX';
  MSG_LISTBOXMOVE        :sa:='MSG_LISTBOXMOVE';
  MSG_LISTBOXCLICK       :sa:='MSG_LISTBOXCLICK';

  Else sa:='???';
  End;
  
  If (p_rSageMsg.uMsg<>MSG_IDLE) Then VCWriteln(sa);
  VCWriteln(sa);
  VCSetFGC(VCGetPenFGC+1);
  If VCGetPenFGC=0 Then VCSetFGC(1);
  //pDateConsole;
  
  
  //If p_rSageMsg.u4Msg = MSG_BUTTONDOWN Then
  //Begin
  //  MsgBox('Caption','Message',MB_ABORTRETRYIGNORE);
  //  //MakeNew;
  //End;
  
  Result:=0;
  
  // if a window gets the MSG_CLOSE - Set Result to "1" to 
  // refuse.
  
End;
//=============================================================================






















//=============================================================================
Procedure InitProgram;
//=============================================================================
Var
  {$IFDEF MENUENABLED}
    uMenu: UINT;
  {$ENDIF}
  t: LongInt;
Begin
  //SetGfxSchema(2);
  //SetColorSchema(2);
  VCMsg:=NewVC(60,2,20,7);
  VCClear;
  VcWriteln('VCMsg Window');

  // shutup compiler
  //ctlLabel:=ctlLabel;
  //ctlVScrollBar:=ctlVScrollBar;
  //ctlHScrollBar:=ctlHScrollBar;
  //ctlProgressBar:=ctlProgressBar;
  //ctlInput:=ctlInput;
  //ctlInput01:=ctlInput01;
  //ctlButton01:=ctlButton01;
  //ctlButton02:=ctlButton02;
  //ctlCheckBox:=ctlCheckBox;
  
  //ctlLabel3:= ctlLabel3;
  //ctlVScrollBar3:= ctlVScrollBar3;
  //ctlHScrollBar3:= ctlHScrollBar3;
  //ctlProgressBar3:= ctlProgressBar3;
  //ctlInput3:= ctlInput3;

  SetActiveVC(guVCStatusBar);
  VCSetVisible(True);
  

  


  {$IFDEF MENUENABLED}
    gbMenuEnabled:=True;
    gbMenuVisible:=True;

    uMenu:=AddMenuBarItem('&File',True);

    AddMenuPopUpItem(uMenu,'&New',True,mnuNew);
    AddMenuPopUpItem(uMenu,'New &Template',True,mnuNewTemplate);
    AddMenuPopUpItem(uMenu,'&Open Project',True,mnuOpenProject);
    AddMenuPopUpItem(uMenu,'&Reopen',True,mnuReopen);
    AddMenuPopUpItem(uMenu,'New Source &File',True,mnuNewSourceFile);
    AddMenuPopUpItem(uMenu,'New Reso&urce File',True,mnuNewResourceFile);
    AddMenuPopUpItem(uMenu,'&Save Unit',True,mnuSaveUnit);
    AddMenuPopUpItem(uMenu,'Save Unit &As...',True,mnuSaveUnitAs);
    AddMenuPopUpItem(uMenu,'Save A&ll',True,mnuSaveAll);
    AddMenuPopUpItem(uMenu,'Close Pro&ject',True,mnuCloseProject);
    AddMenuPopUpItem(uMenu,'&Close',True,mnuClose);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Print',True,mnuPrint);
    AddMenuPopUpItem(uMenu,'-',True,mnuExit);
    AddMenuPopUpItem(uMenu,'E&xit',True,mnuExit);

    uMenu:=AddMenuBarItem('&Edit',True);
    AddMenuPopUpItem(uMenu,'&Undo',True,mnuUndo);
    AddMenuPopUpItem(uMenu,'&Redo',True,mnuReDo);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'Cu&t',True,mnuCut);
    AddMenuPopUpItem(uMenu,'&Copy',True,mnuCopy);
    AddMenuPopUpItem(uMenu,'&Paste',True,mnuPaste);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Insert',True,mnuInsert);
    AddMenuPopUpItem(uMenu,'&Toggle Bookmarks',True,mnuToggleBookMarks);
    AddMenuPopUpItem(uMenu,'&Goto Bookmarks',True,mnuGotoBookMarks);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Select All',True,mnuSelectAll);

    uMenu:=AddMenuBarItem('&Search',True);
    AddMenuPopUpItem(uMenu,'&Find...',True,mnuFind);
    AddMenuPopUpItem(uMenu,'Find &next',True,mnuFindNext);
    AddMenuPopUpItem(uMenu,'Find and &Replace',True,mnuFindAndReplace);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Go to line...',True,mnuGoToLine);

    uMenu:=AddMenuBarItem('&View',True);
    AddMenuPopUpItem(uMenu,'&Project Manager',True,mnuProjectManager);
    AddMenuPopUpItem(uMenu,'&Status Bar',True,mnuStatusBar);
    AddMenuPopUpItem(uMenu,'&Compiler Output',True,mnuCompilerOutput);
    AddMenuPopUpItem(uMenu,'&Tool Bars',True,mnuToolBars);

    uMenu:=AddMenuBarItem('&Project',True);
    SetMenuBarItemEnabled(uMenu,False);
    AddMenuPopUpItem(uMenu,'New &Unit in Project',True,mnuNewUnitinProject);
    AddMenuPopUpItem(uMenu,'&Add to project...',True,mnuAddtoproject);
    AddMenuPopUpItem(uMenu,'&Remove from project...',True,mnuRemovefromproject);
    AddMenuPopUpItem(uMenu,'&Set main unit...',True,mnuSetmainunit);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Edit Resource File',True,mnuEditResourceFile);
    AddMenuPopUpItem(uMenu,'&Generate Makefile...',True,mnuGenerateMakefile);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Project options',True,mnuProjectoptions);

    uMenu:=AddMenuBarItem('E&xecute',True);
    AddMenuPopUpItem(uMenu,'&Compile',True,mnuCompile);
    AddMenuPopUpItem(uMenu,'&Run',True,mnuRun);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'Compile &and Run',True,mnuCompileandRun);
    AddMenuPopUpItem(uMenu,'R&ebuild All',True,mnuRebuildAll);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Debug',True,mnuDebug);

    uMenu:=AddMenuBarItem('&Options',True);
    AddMenuPopUpItem(uMenu,'&Compiler options',True,mnuCompileroptions);
    AddMenuPopUpItem(uMenu,'&Environment Options',True,mnuEnvironmentOptions);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Icons Style',True,mnuIconsStyle);

    uMenu:=AddMenuBarItem('&Tools',True);
    AddMenuPopUpItem(uMenu,'&Compile results',True,mnuCompileresults);
    AddMenuPopUpItem(uMenu,'&Tools configuration',True,mnuToolsconfiguration);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Dos Shell',True,mnuDosShell);
    AddMenuPopUpItem(uMenu,'&Explorer',True,mnuExplorer);
    AddMenuPopUpItem(uMenu,'&Package Manager',True,mnuPackageManager);
    AddMenuPopUpItem(uMenu,'&Setup Creator',True,mnuSetupCreator);

    uMenu:=AddMenuBarItem('&Window',True);
    AddMenuPopUpItem(uMenu,'&Tile',True,mnuTile);
    AddMenuPopUpItem(uMenu,'&Cascade',True,mnuCascade);
    AddMenuPopUpItem(uMenu,'&Arrange icons',True,mnuArrangeicons);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'C&lose All',True,mnuCloseAll);
    AddMenuPopUpItem(uMenu,'&Minimize All',True,mnuMinimizeAll);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Full screen mode',True,mnuFullscreenmode);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'&Next',True,mnuNext);
    AddMenuPopUpItem(uMenu,'&Previous',True,mnuPrevious);

    uMenu:=AddMenuBarItem('&Help',True);
    AddMenuPopUpItem(uMenu,'&Help',True,mnuHelp);
    AddMenuPopUpItem(uMenu,'&Tutorial',True,mnuTutorial);
    AddMenuPopUpItem(uMenu,'&GNU Debugger Help',True,mnuGNUDebuggerHelp);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'Get the &Drift Yet?',True,mnuGettheDriftYet);
    AddMenuPopUpItem(uMenu,'Created 2002-09-19',True,mnuCreated20020919);
    AddMenuPopUpItem(uMenu,'&By Jason P Sage',True,mnuByJasonPSage);
    AddMenuPopUpItem(uMenu,'info@jegas.com',True,mnuemail);
    AddMenuPopUpItem(uMenu,'-',True,0);
    AddMenuPopUpItem(uMenu,'Email us if you like this!',True,mnuEmailmeifyoulikethis);
  {$ENDIF}


  {$IFDEF WIN01}
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
    // gbgSFCDebugLog:=true;
    Window[1]:=TWindow.create(gRCW);
    ctlLabel:=tctllabel.create(Window[1]);
    ctlLabel.X:=3;
    ctlLabel.Y:=4;
    ctlLabel.Width:=15;
    ctlLabel.Height:=6;
    //ctlLabel.TextColor:=White;
    //ctlLabel.BackColor:=Black;
    ctlLabel.Caption:='This is The Win32/DOS Look (My Favorite)';
    ctlLabel.Enabled:=True;
    //ctlLabel.Visible:=true;

    ctlVScrollBar:=tctlVScrollBar.create(Window[1]);
    ctlVScrollBar.X:=42;
    ctlVScrollBar.Y:=3;
    ctlVScrollBar.MaxValue:=50;
    ctlVScrollBar.Height:=10;
    ctlVScrollBar.Value:=ctlVScrollBar.MaxValue Div 4;

    ctlHScrollBar:=tctlHScrollBar.create(Window[1]);
    ctlHScrollBar.X:=3;
    ctlHScrollBar.Y:=14;
    ctlHScrollBar.Width:=20;
    ctlHScrollBar.MaxValue:=75;
    ctlHScrollBar.Value:=ctlHScrollBar.MaxValue Div 2;

    ctlProgressBar:=tctlProgressBar.create(Window[1]);
    ctlProgressBar.X:=5;
    ctlProgressBar.Y:=12;
    ctlProgressBar.Width:=30;
    ctlProgressBar.MaxValue:=200;
    ctlProgressBar.Value:=150;


    ctlInput:=tctlInput.create(Window[1]);
    ctlInput.X:=21;
    ctlInput.Y:=4;
    ctlInput.Data:='Input Data Here Man I should be bigger than control';


    ctlInput01:=tctlinput.create(Window[1]);
    ctlInput01.X:=21;
    ctlInput01.Y:=6;
    ctlInput01.Data:='More Data Here';

    ctlButton01:=tctlbutton.create(Window[1]);
    ctlButton01.X:=10;
    ctlButton01.Y:=10;
    //ctlButton01.Width:=8;
    ctlButton01.Caption:='&Ok';


    ctlButton02:=tctlButton.create(Window[1]);
    ctlButton02.X:=20;
    ctlButton02.Y:=10;
    //ctlButton02.i4Width:=8;
    ctlButton02.Caption:='&Cancel';

    ctlCheckBox:=tctlCheckBox.create(window[1]);
    ctlCheckBox.X:=25;
    ctlCheckBox.Y:=14;
    ctlCheckBox.RadioStyle:=True;
  {$ENDIF}

  {$IFDEF WIN02}
    gRCW.saCaption:='Second Test Caption';
    gRCW.X:=2;
    gRCW.Y:=14;
    gRCW.Width:=45;
    gRCW.Height:=5;
    gRCW.bFrame:=True;
    gRCW.WindowState:=WS_MINIMIZED;
    gRCW.bCaption:=True;
    gRCW.bMinimizeButton:=True;
    gRCW.bMaximizeButton:=True;
    gRCW.bCloseButton:=True;
    gRCW.bSizable:=True;
    gRCW.bVisible:=True;
    gRCW.bEnabled:=True;
    gRCW.lpfnWndProc:=@msgHandler;
    gRCW.bAlwaysOnTop:=False;

    Window[2]:=TWindow.create(gRCW);

      ctlButton02:=tctlButton.create(Window[2]);
      ctlButton02.X:=20;
      ctlButton02.Y:=10;
      //ctlButton02.i4Width:=8;
      ctlButton02.Caption:='&Cancel';
  {$ENDIF}
  
  {$IFDEF WIN03}
    gRCW.saCaption:='Third Test Caption';
    gRCW.X:=3;
    gRCW.Y:=5;
    gRCW.Width:=60;
    gRCW.Height:=8;
    gRCW.bFrame:=True;
    gRCW.WindowState:=WS_MINIMIZED;
    gRCW.bCaption:=True;
    gRCW.bMinimizeButton:=True;
    gRCW.bMaximizeButton:=True;
    gRCW.bCloseButton:=True;
    gRCW.bSizable:=True;
    gRCW.bVisible:=True;
    gRCW.bEnabled:=True;
    gRCW.lpfnWndProc:=@msgHandler;
    gRCW.bAlwaysOnTop:=False;

    window[3]:=TWindow.create(gRCW);


    ctlLabel3:=tctlLabel.create(Window[3]);
    ctlLabel3.X:=5;
    ctlLabel3.Y:=15;
    ctlLabel3.Width:=20;
    ctlLabel3.Height:=4;
    ctlLabel3.TextColor:=Yellow;
    ctlLabel3.BackColor:=Blue;
    ctlLabel3.Caption:='hello dude jkfsdahfjdshfkljdhasjfhsajhfkjshfdjkhlfkjshafdkjslhjfdklfhjasl Hello';
    ctlLabel3.Enabled:=True;
    ctlLabel3.Visible:=True;

    ctlVScrollBar3:=tctlVScrollBAr.create(window[3]);
    ctlVScrollBar3.X:=79;
    ctlVScrollBar3.MaxValue:=50;
    ctlVScrollBar3.Value:=ctlVScrollBar3.MaxValue Div 4;

    ctlHScrollBar3:=tctlHScrollBar.create(Window[3]);
    ctlHScrollBar3.Y:=22;
    ctlHScrollBar3.Width:=77;
    ctlHScrollBar3.MaxValue:=75;
    ctlHScrollBar3.Value:=ctlHScrollBar3.MaxValue Div 2;

    ctlProgressBAr3:=tctlProgressBar.create(window[3]);
    ctlProgressBar3.X:=5;
    ctlProgressBar3.Y:=20;
    ctlProgressBar3.Width:=70;
    ctlProgressBar3.MaxValue:=200;
    ctlProgressBar3.Value:=0;

    ctlInput3:=tctlInput.create(window[3]);
    ctlInput3.X:=5;
    ctlInput3.Y:=4;
    ctlInput3.Data:='Input Data Here';
  {$ENDIF}


  {$IFDEF WIN04}
    gRCW.saCaption:='Fifth Test Caption';
    gRCW.X:=5;
    gRCW.Y:=5;
    gRCW.Width:=20;
    gRCW.Height:=17;
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



    window[4]:=TWindow.create(gRCW);




    ctlListBox:=tctlListBox.create(window[4]);
    ctlListBox.X:=2;
    ctlListBox.Y:=2;
    ctlListBox.Width:=40;
    ctlListBox.DataWidth:=250;
    ctlListBox.Height:=23;
    ctlListBox.AppendCaption('Caption1');
    ctlListBox.AppendCaption('Caption2');
    randomize;
    For t:=1 To 1000 Do
    Begin
      If random(2)=1 Then
        ctlListBox.Append(True,inttostr(t)+' Testing The listbox thingy dude! Testing The listbox thingy dude! Testing The listbox thingy dude! Testing The listbox thingy dude!')
      Else
      Begin
        ctlListBox.Append(False,inttostr(t)+' What do You Think? What do You Think? What do You Think? What do You Think? What do You Think?');
        ctlListBox.ChangeItemFG(LightGreen);
      End;
    End;
    ctlListBox.CurrentItem:=1; // Move to top of list
  {$ENDIF}

  // Remove create msg
  SetActiveVC(guVCMain);
  VCFillBoxCtr(VCWidth, VCHeight,gchScreenBGChar);
  //byidleFG:=0;

  updateconsole;

End;
//=============================================================================


//=============================================================================
Procedure RunApplication;
//=============================================================================
Var rSageMsg: rtSageMsg;
    //dtMsg: TDATETIME;
    i4MostMsg: LongInt;
Begin
  i4MostMsg:=0;
  While Getmessage(rSageMsg) Do Begin
    SetActiveVC(guVCMain);
//    SageLog(1,'AFTER STA - MEMAVAIL:'+inttostr(MEMAVAIL));
    VCSetFGC(black);
    DrawKeyBoard(1, 2);
    VCSetFGC(white);
    DrawKeyPressOnKeyBoard(1, 2,rLKey);
    DrawKeypressRecord(1,10,rLKey,black,blue,white, blue);
    VCSetFGC(white);
    //VCWriteXY(1,giScreenHeight-3,'Window:'+saSTR(GW.N));
    //VCWriteXY(1,giScreenHeight-2,'UID     :'+saFixedLength(inttostr(rSageMsg.uUID),1,8));
    If MQ.ListCount>i4MostMsg Then i4MostMsg:=MQ.Listcount;
    VCWrite('Most Msgs:'+saFixedLength(inttostr(i4MostMsg),1,8));
    //VCWriteXY(1,23,'MEMAVAIL:'+saFixedLength(inttostr(MEMAVAIL),1,8));

    DispatchMessage(rSageMsg);
      
//    SageLog(1,'AFTER DIS - MEMAVAIL:'+inttostr(MEMAVAIL));
//    if gbUpdateConsole then UpdateConsole;
//    updateconsole;
//    SageLog(1,'AFTER UPC - MEMAVAIL:'+inttostr(MEMAVAIL));
  End;
End;
//=============================================================================




//=============================================================================
// Main Program Starts Here
//=============================================================================
Begin
  deletefile('..'+csDOSSLASH+'log'+csDOSSLASH+'jegaslog.csv');
  If InitSageUI(@MainMsgHandler) Then
  Begin 
    InitProgram; 
    RunApplication;
    DoneSageUI;
  End
  Else
  Begin
    //SageLog(1,'test_uxxc_sageuiI - create Failed',sourcefile);    
  End;
  //H a l t;
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
