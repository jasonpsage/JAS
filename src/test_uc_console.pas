{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  Jason@jegas.com             |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// Testing the JegasAPI u01c_Console.pp Console Unit
program test_uc_console;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================

//=============================================================================
Uses 
 sysutils,
 uc_console,
 uc_library,
 ug_jegas,
 uc_animate;
 
 
// u01c_Library, sysutils,u01g_library,u01g_sagelog; 
//=============================================================================

//=============================================================================
Procedure WaitForKeyPress;
//=============================================================================
Begin
  VCSetFGC(LightGray);
  VCSetBGC(Black);
  VCSetPenXY(1,23);
  VCWrite('Press Key>');
  //SpinCursor;
  UpDateConsole;  GetKEypress;
End;
//=============================================================================







//=============================================================================
Procedure testkeyboard(p_bPoll: Boolean);
//=============================================================================
Var rKey: rtKeyPress;
Begin
  VCSetFGC(LightGray);
  VCSetBGC(Black);
  VCClear;
  If not p_bPoll Then 
    VCWriteXY(1,1, 'u03c_Console Test - Testing Keyboard Method 1 TERM:'+gsaTerm)
  Else
    VCWriteXY(1,1, 'u03c_Console Test - Testing Keyboard Method 2 TERM:'+gsaTerm);
  DrawKeyBoard(1,3);
  repeat
    //WaitForKeyPress;

    //VCWriteXY(1,2,'gbTaskSwitchMode:'+saTrueFalse(gbTaskSwitchMode));
    UpdateConsole;
    If p_bPoll Then
    Begin
      repeat Until KeyHit;
      GetKeypress;
      rKey:=rLKey;
    End
    Else
    Begin
      GetKeyPress;
      rKey:=rLKey;
    End;
    
    
    VCSetFGC(LightGray);
    VCSetBGC(Black);
    DrawKeyboard(1,3);
    VCSetFGC(White);
    VCSetBGC(Black);
    DrawKeyPressOnKeyboard(1,3,rKey);
    DrawKeypressRecord(1,10, rKey, lightgray, black, white, black);
    
  Until rLKey.ch=#27;
End;
//=============================================================================


//=============================================================================
Procedure TestVCS; // test virtual console system with "Blocks"
//=============================================================================
Const cnHowmany = 50;
Var TempVC: Integer;
Begin
  TempVC:=NewVC;
  chBLock:=' ';
  InitBlocks(cnHowMAny);
  BringVcToTop(1);
  SetActiveVC(1);
  VCClear;
  VCSetTransparency(True);
  VCSetOpaqueBG(False);
//  VCSetOpaqueFG(false);
  VCSetFGC(White);
  VCSetPenXY(1,3);
  VCWriteCtr('You see this text? Well Its on it''s own "VC" or Virtual Console.');
  VCSetPenXY(1,6);
  VCWriteCtr('These Blocks Flying Around are separate "VC''s" also!');
  VCSnrBox(1,1,giconsolewidth,giconsoleheight,' ',#0);
  repeat 
    UpdateBlocks;
    UpdateConsole;
    sleep(30);
  Until KeyHit;
  getkeypress;
  DoneBlocks;
  REmoveVC(TempVC);
  VCSetOpaqueFG(True);
  VCSetOpaqueBG(True);
  VCSetTransparency(False);
End;
//=============================================================================


//=============================================================================
Procedure testcolors;
//=============================================================================
Var t,s: Byte;
Begin
  VCSetFGC(lightgray);
  VCSetBGC(black);
  VCClear;
  vcwriteln('0 Black');
  vcwriteln('1 Blue');
  vcwriteln('2 Green');
  vcwriteln('3 Cyan');
  vcwriteln('4 Red');
  vcwriteln('5 Magenta');
  vcwriteln('6 Brown');
  vcwriteln('7 LightGray');
  vcwriteln('8 DarkGray');
  vcwriteln('9 LightBlue');
  vcwriteln('a LightGreen');
  vcwriteln('b LightCyan');
  vcwriteln('c LightRed');
  vcwriteln('d LightMagenta');
  vcwriteln('e Yellow');
  vcwriteln('f White');
  
  VCWriteln('');
  VCWriteln('Left Hex Digit-Background Color, Right Hex Digit-Foreground Color');
  
  

  For t:=0 To 15 Do
  Begin
    VCSetPenXY(20,t+1);
    For s:=0 To 15 Do
    Begin
      VCSetFGC(t);
      VCSetBGC(s);
      VCWrite(HexStr(s,1)+HexStr(t,1));
    End;  
    VCwriteln('');
  End;
  
  
  VCSetFGC(lightgray);
  VCSetBGC(black);
  WaitForKeypress;  
End;
//=============================================================================

//=============================================================================
Procedure SplashDemo; 
//=============================================================================
Var bDoneSplash: Boolean;
Begin
  VCSetCursorType(crHidden);
  InitStars();
  InitJegasLogoSplash(
    'Jegas API',
    'Virtually Everything IT (tm)',
    'Copyright(c)2015',
    'jason@jegas.com',
    ''
  );
  bDoneSplash:=False;
  repeat
    If not bDoneSplash Then bDoneSplash:=UpdateJegasLogoSplash;
    //else UpdateStars;
    UpDateStars;
    UpdateConsole;
    sleep(30);
  Until keyhit;
  GetKeypress;
  //DoneStars;
  DoneJegasLogoSplash;
  VCSetCursorType(crUnderline);
End;
//=============================================================================

//=============================================================================
Procedure TestWordWrap;
//=============================================================================
Var saMsg: AnsiString;
Begin
  VCClear;
  VCWriteXY(1,1,'JegasAPI v3 - Word Wrap Test');
  VCWriteXY(1,2,'This test : VCWordWrap(60,11,MSg); Width=60, Height=11');
  VCWriteXY(1,3,'from current Cursor position - Setting that to 10,5 (X,Y)');
  VCSetPenXY(10,5);
  
  saMsg:='Ahh - You got this to compile...cool. I hope it works for ya. This' +
         ' FPC stuff is pretty cool - I hope you find my lib cool to. In '+
         'version one I was still learning - still am - but from here on out '+
         'I will support this lib concerning backward compatibility. So things ' +
         'don''t break in the future if you try to "upgrade" to version 4 or '+
         'whatever. Version 2 never existed because I started it - and then ' +
         'wanted to make the whole lib a shared lib and started working on '+
         'version 3 - so version 2 kinda got skipped ultimately and as of '+
         '2003-03-10 - There isn''t a HAS-ALL BE-ALL shared lib. Just a ' +
         '"Hello World" lib...Want it? :^) - Jason';
  
  VCWordwrap(60,11, saMsg);
  Waitforkeypress;
End;
//=============================================================================

//=============================================================================
Procedure testmouse;
//=============================================================================
Begin
  VCClear;
  VCWrite('Testing MOUSE functionality - Press any key to quit (Move Mouse Around!)');
  UpDateConsole;
  repeat
    If MEvent Then
    Begin
      GetMEvent;
      DrawMouseEventRecord(10,10,
                           rLMevent,
                           VCGetPenFGC,VCGetPenBGC,
                           white,black);
      UpDateConsole;
    End;
  Until KeyHit;
  GetKeyPRess;
End;
//=============================================================================

//=============================================================================
Procedure TestBlinky;
//=============================================================================
Var avc: array[1..4] Of LongWord;
Begin
  aVC[1]:=GetActiveVC;
  VCSetBGC(Blue);
  VCSetCursorType(crUnderLine);
  VCClear;
  VCWrite('SHOULD See Blinky!!  Hit Key For Next Test:');
  UpDateConsole;
  GetKEyPress;
  VCWriteln;
  VCWrite('SHOULD NOT See Blinky!!  Hit Key For Next Test:');
  VCSetCursorType(crHidden);
  UpDateConsole;
  GetKEyPress;
  aVC[2]:=NewVC(10,10,10,10);
  VCSetCursorType(crUnderline);//redundant - I think this is default for new VC
  VCWriteln('You See A Blinky In Here? You Should!');
  UpDateConsole;
  GetKEyPress;
  

  RemoveVC(aVC[2]);
  SetActiveVC(aVC[1]);
End;
//=============================================================================



//=============================================================================
// Main Program Starts Here
//=============================================================================
Var bDone: Boolean;
Begin
  bDone:=False;
  InitConsole;
  //TurnOffCntlC;
  //VCSetCursorType(crHidden);
  repeat
    VCSetFGC(white);
    VCSetBGC(black);
    VCSetCursortype(crUnderline);
    VCClear;
    VCWriteXY(1,1, 'u03c_Console Unit Test Application');
    VCWriteXY(1,2, 'Mouse Buttons (Zero=No Mouse):'+inttostr(MButtons));
    VCWriteXY(3,5,   '1: Test KEYBOARD (Waits For Keys)');
    VCWriteXY(3,6,   '2: Test KEYBOARD (Polls For Keys)');
    VCWriteXY(3,7,   '3: Test Virtual Console System');
    VCWriteXY(3,8,   '4: Test Colors');
    VCWriteXY(3,9,   '5: Test Word Wrap');
    VCWriteXY(3,10,  '6: Test Mouse');
    VCWriteXY(3,11,  '7: Test Blinky');
    VCWriteXY(3,12,  '8: Example "Sage Splash" "Demo"');
    VCWriteXY(1,14,'ESC: Quit');
    WaitForKeyPress;
    //VCWriteCharXY(3,9,rLKey.ch);
    Case rLKey.ch Of
    '1': TestKeyBoard(False); 
    '2': TestKeyboard(True);  
    '3': TestVCS;
    '4': TestColors; 
    '5': TestWordWrap;
    '6': TestMouse;
    '7': TestBlinky;
    '8': SplashDemo; 
    #27 : bDone:=True;
    End;
  Until bDone;
  DoneConsole;
  Writeln('All Done - Good Bye, See Ya Later, Take Care, Best Regards, um...Yeah!');
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
