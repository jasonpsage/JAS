{=============================================================================
|    _________ _______  _______  ______  _______  Get out of the Mainstream, |
|   /___  ___// _____/ / _____/ / __  / / _____/    Mainstream Jetstream!    |
|      / /   / /__    / / ___  / /_/ / / /____         and into the          |
|     / /   / ____/  / / /  / / __  / /____  /            Jetstream! (tm)    |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                        Jason@Jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}


//=============================================================================
{ }
// Various Console Keyboard and Mouse Utilities
//
// Tabled: No Solution for losing mouse when shelling out in win32 yet.
//
// THE FIX: You have to use the mouse unit directly in your program
// and then follow these steps after shelling out:
//         DoneMouse;
//         InitMouse;
//         RedrawConsole;
//
// Keyboard degradation of child (spawned process) still there in DOS.
// Function iCShell(p_saCommand: AnsiString; p_saParam: AnsiString): Integer;
// SO Far Linux performance is fine.
Unit uc_library; //<Routines for programs using the Console Unit
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
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

{INCLUDE i01_jegas_splash.pp}
{INFO =================================================================}
{INFO | Filename:           uc_Library.pp}
{INFO | Author:             Jason Sage}
{INFO | Date Created:       2002-12-24}
{INFO | Classification:     Console}
{INFO | Purpose: Routines for programs using the Console Unit}
{INFO =================================================================}

{$INCLUDE i_jegas_macros.pp}

//=============================================================================
// DEBUG/LOGGING Directives
//=============================================================================
{$DEFINE SOURCEFILE:='uc_library.pp'}
//=============================================================================

//=============================================================================
{}
Uses 
//=============================================================================
  {}
  sysutils,
  uc_console,
  ug_jegas,
  ug_common;
{}
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{ }
// Draws a ascii representation of a USA 101 PC Keyboard. Pass your X,Y
// coordinates set to where you want the top left character of the keyboard to
// be drawn.
Procedure DrawKeyBoard(X, Y: LongInt);//< Relies on Current VC FGC and BGC
{ }
// Draws the passed keypress in highlighted fashion. The position of the letter
// should be correct if the x,y coordinates used to draw thekeyboard are used
// to draw the letter. This routine will figure out the rest.
Procedure DrawKeyPressOnKeyBoard(X, Y: LongInt; rKey: rtKeyPress);//< Relies on Current VC FGC and BGC
{ }
//=============================================================================
{ }
{Overrides Current VC FGC and BGC with the color parameters passed.
On return, at time of putting this routine in this unit, the colors set
on return will be p_FG, p_BG.}
Procedure DrawKeypressRecord(x,y: LongInt;
                             rKey: rtKeyPress;
                             p_FG, p_BG, p_DataFG, p_DataBG: Byte
);
{}
//=============================================================================
{ }
{Changes FGC, and uses current PenXY on Entry for position.
Updates Console repeatedly while waiting for keyhit.}
Procedure SpinCursor;
//=============================================================================
{ }
{Overrides Current VC FGC and BGC with the color parameters passed.
On return, at time of putting this routine in this unit, the colors set
on return will be p_FG, p_BG.}
Procedure DrawMouseEventRecord(x,y: LongInt;
                             rMevent: rtMEvent;
                             p_FG, p_BG, p_DataFG, p_DataBG: Byte
);
{}
//=============================================================================
{ }
{Returns ExitCode - Works for DOS and Linux. Note: Linux just
appends the two parameters with a space separator. Using this
gives you a platform independant way to execute shell commands.
See uxxg_library.i4Shell function}
Function u2CShell(p_saCommand: AnsiString; p_saParam: AnsiString): word;
{}
//=============================================================================
{ }
Procedure JegasLogo;{< Displays the Jegas Logo in Text - prepared for console unit,
for the current console vc, current cursor location, and color settings.}
{ }
Procedure JegasLogoFramed;{< Displays the Jegas Logo in Text - prepared for console unit,
for the current console vc, current cursor location, and color settings.}
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
Procedure DrawKeyBoard(X, Y: LongInt);
//=============================================================================
Begin
  VCWriteXY(X,Y,  'esc f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12');
  VCWriteXY(X,Y+1,'` 1 2 3 4 5 6 7 8 9 0 - = \ [bs]    ins home pgup');
  VCWriteXY(X,Y+2,'[t] q w e r t y u i o p [ ]         del end  pgdn');
  VCWriteXY(X,Y+3,'     a s d f g h j k l ; '' [enter]');
  VCWriteXY(X,Y+4,'[shift] z x c v b n m , . / [shift]    [up]');
  VCWriteXY(X,Y+5,'[cntl] [alt] [space] [alt] [cntl]  [lt][dn][rt]');
End;  
//=============================================================================

//=============================================================================
Procedure DrawKeyPressOnKeyBoard(X, Y: LongInt; rKey: rtKeyPress);
//=============================================================================
Begin
  If rKey.bShiftPressed Then 
  Begin
    VCWriteXY(X,Y+4,'[SHIFT]');
    VCWriteXY(X+28,Y+4,'[SHIFT]');
  End;
  If rKey.bCNTLPressed Then 
  Begin
    VCWriteXY(X,Y+5,'[CNTL]');
    VCWriteXY(X+27,Y+5,'[CNTL]');
  End;
  If rKey.bALTPressed Then 
  Begin
    VCWriteXY(X+7,Y+5,'[ALT]');
    VCWriteXY(X+21,Y+5,'[ALT]');
  End;
  
  Case rKey.ch Of
  ' ':     VCWriteXY(X+13,Y+5,'[space]');
  '`','~': VCWriteCharXY(X,Y+1,rKey.ch); 
  '1','!': VCWriteCharXY(X+2,Y+1,rKey.ch); 
  '2','@': VCWriteCharXY(X+4,Y+1,rKey.ch); 
  '3','#': VCWriteCharXY(X+6,Y+1,rKey.ch); 
  '4','$': VCWriteCharXY(X+8,Y+1,rKey.ch);
  '5','%': VCWriteCharXY(X+10,Y+1,rKey.ch);
  '6','^': VCWriteCharXY(X+12,Y+1,rKey.ch);
  '7','&': VCWriteCharXY(X+14,Y+1,rKey.ch);
  '8','*': VCWriteCharXY(X+16,Y+1,rKey.ch);
  '9','(': VCWriteCharXY(X+18,Y+1,rKey.ch);
  '0',')': VCWriteCharXY(X+20,Y+1,rKey.ch);
  '-','_': VCWriteCharXY(X+22,Y+1,rKey.ch);
  '=','+': VCWriteCharXY(X+24,Y+1,rKey.ch);
  '\','|': VCWriteCharXY(X+26,Y+1,rKey.ch);
  #8: VCWriteXY(X+28,Y+1,'[BS]');//backspace
  #9: VCWriteXY(X,Y+2,'[T]');//tab
  'q','Q': VCWriteCharXY(X+4,Y+2,rKey.ch);
  'w','W': VCWriteCharXY(X+6,Y+2,rKey.ch);
  'e','E': VCWriteCharXY(X+8,Y+2,rKey.ch);
  'r','R': VCWriteCharXY(X+10,Y+2,rKey.ch);
  't','T': VCWriteCharXY(X+12,Y+2,rKey.ch);
  'y','Y': VCWriteCharXY(X+14,Y+2,rKey.ch);
  'u','U': VCWriteCharXY(X+16,Y+2,rKey.ch);
  'i','I': VCWriteCharXY(X+18,Y+2,rKey.ch);
  'o','O': VCWriteCharXY(X+20,Y+2,rKey.ch);
  'p','P': VCWriteCharXY(X+22,Y+2,rKey.ch);
  '[','{': VCWriteCharXY(X+24,Y+2,rKey.ch);
  ']','}': VCWriteCharXY(X+26,Y+2,rKey.ch);
  'a','A': VCWriteCharXY(X+5,Y+3,rKey.ch);
  's','S': VCWriteCharXY(X+7,Y+3,rKey.ch);
  'd','D': VCWriteCharXY(X+9,Y+3,rKey.ch);
  'f','F': VCWriteCharXY(X+11,Y+3,rKey.ch);
  'g','G': VCWriteCharXY(X+13,Y+3,rKey.ch);
  'h','H': VCWriteCharXY(X+15,Y+3,rKey.ch);
  'j','J': VCWriteCharXY(X+17,Y+3,rKey.ch);
  'k','K': VCWriteCharXY(X+19,Y+3,rKey.ch);
  'l','L': VCWriteCharXY(X+21,Y+3,rKey.ch);
  ';',':': VCWriteCharXY(X+23,Y+3,rKey.ch);
  '''','"': VCWriteCharXY(X+25,Y+3,rKey.ch);
  #13: VCWriteXY(X+27,Y+3,'[ENTER]');
  'z','Z': VCWriteCharXY(X+8,Y+4,rKey.ch);
  'x','X': VCWriteCharXY(X+10,Y+4,rKey.ch);
  'c','C': VCWriteCharXY(X+12,Y+4,rKey.ch);
  'v','V': VCWriteCharXY(X+14,Y+4,rKey.ch);
  'b','B': VCWriteCharXY(X+16,Y+4,rKey.ch);
  'n','N': VCWriteCharXY(X+18,Y+4,rKey.ch);
  'm','M': VCWriteCharXY(X+20,Y+4,rKey.ch);
  ',','<': VCWriteCharXY(X+22,Y+4,rKey.ch);
  '.','>': VCWriteCharXY(X+24,Y+4,rKey.ch);
  '/','?': VCWriteCharXY(X+26,Y+4,rKey.ch);
  End;
  
  Case rKey.u2KeyCode Of
  kbdF1: VCWriteXY(X+4,y,'F1');
  kbdF2: VCWriteXY(X+7,y,'F2');
  kbdF3: VCWriteXY(X+10,y,'F3');
  kbdF4: VCWriteXY(X+13,y,'F4');
  kbdF5: VCWriteXY(X+16,y,'F5');
  kbdF6: VCWriteXY(X+19,y,'F6');
  kbdF7: VCWriteXY(X+22,y,'F7');
  kbdF8: VCWriteXY(X+25,y,'F8');
  kbdF9: VCWriteXY(X+28,y,'F9');
  kbdF10:VCWriteXY(X+31,y,'F10'); 
  kbdF11:VCWriteXY(X+35,y,'F11');
  kbdF12:VCWriteXY(X+39,y,'F12');
  kbdHome:VCWriteXY(X+40,Y+1,'HOME');
  kbdUp:VCWriteXY(X+39,Y+4,'[UP]');
  kbdPgUp:VCWriteXY(X+45,Y+1,'PGUP');
  kbdLeft:VCWriteXY(X+35,Y+5,'[LT]');
  {kbdMiddle:}
  kbdRight:VCWriteXY(X+43,Y+5,'[RT]');
  kbdEnd:VCWriteXY(X+40,Y+2,'END');
  kbdDown:VCWriteXY(X+39,Y+5,'[DN]');
  kbdPgDn:VCWriteXY(X+45,Y+2,'PGDN');
  kbdInsert:VCWriteXY(X+36,Y+1,'INS');
  kbdDelete:VCWriteXY(X+36,Y+2,'DEL');
  End;


End;
//=============================================================================








//=============================================================================
Procedure DrawKeypressRecord(x,y: LongInt;
                             rKey: rtKeyPress;
                             p_FG, p_BG, p_DataFG, p_DataBG: Byte
);
//=============================================================================
Begin
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y,'uxxc_Console TYPE rtKeyPress=RECORD');
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+1,'   u1Flags             = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  Case rKey.u1Flags Of
  kbAscii:   VCWrite('kbAscii');
  kbUniCode: VCWrite('kbUniCode');
  kbFnKey:   VCWrite('kbFnKey');
  kbPhys:    VCWrite('kbPhys');
  kbReleased:VCWrite('kbReleased');
  Else
    VCWrite('?? Unknown ??');
  End; // Case
  VCWrite(' Value:'+ saFixedLength(inttostr(rKey.u1Flags),1,10));
  

  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+2,'   u2KeyCodeRaw         = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rKey.u2KeyCodeRaw),1,10)); 
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+3,'   bSHIFTPressed        = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(sTrueFalse(rKey.bShiftPressed));
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+4,'   bLSHIFTPressed       = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(sTrueFalse(rKey.bLShiftPressed));
  VCSetFGC(p_FG);VCSetBGC(p_BG); 
  //VCWrite(' // Unreliable on Win32/Intel');
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,Y+5,'   bRSHIFTPressed       = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(sTrueFalse(rKey.bRShiftPressed));
  VCSetFGC(p_FG);VCSetBGC(p_BG); 
  //VCWrite(' // Unreliable on Win32/Intel');
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+6,'   bCNTLPressed         = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(sTrueFalse(rKey.bCNTLPressed));
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+7,'   bALTPressed          = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(sTrueFalse(rKey.bALTPressed));
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+8,'// OS Independant Translation ');//By KEYBOARD Unit''s TranslateKeyEvent'); 
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+9 ,'   u2KeyCode            = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rKey.u2KeyCode),1,10)); 
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+10,'   ch                   = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  Case rKey.ch Of
  #13: VCWrite(saFixedLength('[ENTER] Value 13dec',1,20));
  #9:  VCWrite(saFixedLength('[TAB] Value 9dec',1,20));
  Else 
    Begin
      VCWrite(saFixedLength(rKey.ch + ' Ordinal:' + inttostr(Ord(rKey.ch)),1,20)); 
    End;
  End;

  VCSetFGC(p_FG);VCSetBGC(p_BG);VCWriteXY(x,y+11,'End;');

End;
//=============================================================================


// Changes FGC, and uses current PenXY on Entry for position.
// Updates Console repeatedly while waiting for keyhit.
//=============================================================================
Procedure SpinCursor;
//=============================================================================
Begin
  While not KeyHit Do
  Begin
    VCSetFGC(Red);
    VCWriteXY(VCGetPenX,VCGetPenY,'-'); VCSetPenX(VCGetPenX-1);
    updateconsole;
    VCSetFGC(Yellow);
    VCWriteXY(VCGetPenX,VCGetPenY,'\'); VCSetPenX(VCGetPenX-1);
    updateconsole;
    VCSetFGC(Red);
    VCWriteXY(VCGetPenX,VCGetPenY,'|'); VCSetPenX(VCGetPenX-1);
    updateconsole;
    VCSetFGC(Yellow);
    VCWriteXY(VCGetPenX,VCGetPenY,'/'); VCSetPenX(VCGetPenX-1);
    updateconsole;
  End;
End;
//=============================================================================



//=============================================================================
// Overrides Current VC FGC and BGC with the color parameters passed.
// On return, at time of putting this routine in this unit, the colors set
// on return will be p_FG, p_BG.
Procedure DrawMouseEventRecord(x,y: LongInt;
                             rMevent: rtMEvent;
                             p_FG, p_BG, p_DataFG, p_DataBG: Byte
);
//=============================================================================
Var i4Actions:  LongInt;
Begin
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y,'uxxc_Console TYPE rtMEvent=RECORD');
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+1,'   Buttons  = ');
  If (rMEvent.Buttons and MouseLeftButton)=MouseLeftButton Then
  Begin
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Left ');

  If (rMEvent.Buttons and MouseMiddleButton)=MouseMiddleButton Then
  Begin
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Middle ');

  If (rMEvent.Buttons and MouseRightButton)=MouseRightButton Then
  Begin
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Right');

  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+2,'   ConsoleX = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rMEvent.ConsoleX),1,2));
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+3,'   ConsoleY = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rMEvent.ConsoleY),1,2));
  
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+4,'   Action   = ');
  i4Actions:=0;
  If (rMEvent.Action  and MouseActionMove)=MouseActionMove Then
  Begin
    i4Actions+=1;
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Move ');

  If (rMEvent.Action and MouseActionDown)=MouseActionDown Then
  Begin
    i4Actions+=1;
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Down ');

  If (rMEvent.Action and MouseActionUp)=MouseActionUp Then
  Begin
    i4Actions+=1;
    VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  End
  Else
  Begin
    VCSetFGC(p_FG);VCSetBGC(p_BG);
  End;
  VCWrite('Up');
  
  If i4Actions>1 Then VCWrite(' Actions:'+inttostr(i4Actions));

  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+5,'   VC       = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rMEvent.VC),1,10));
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+6,'   VMX      = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rMEvent.VMX),1,2));
  
  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+7,'   VMY      = ');
  VCSetFGC(p_DataFG);VCSetBGC(p_DataBG);
  VCWrite(saFixedLength(inttostr(rMEvent.VMY),1,2));

  VCSetFGC(p_FG);VCSetBGC(p_BG);
  VCWriteXY(x,y+8,'end;');
End;
//=============================================================================

//=============================================================================
Function u2CShell(p_saCommand: AnsiString; p_saParam: AnsiString): word;
//=============================================================================
{IFDEF INTELWIN32}
//var sa: AnsiString;
{ENDIF}
Begin
{IFDEF INTELWIN32}
//  sa:=p_saCommand + ' ' + p_saParam+#0;
//  Result:=WinExec(PChar(sa),SW_SHOWNORMAL);
// ------ method idea
//  if CreateProcess(PChar(sa),
//                nil, 
//                nil,
//                nil,
//                false,
//                DETACHED_PROCESS,
//                nil,
//                nil,
//                nil,
//                nil)<>false then
//  begin
//    Result:=0;
//  end
//  else
//  begin
//    Result:=1;
//  end;
//-------------- method idea
//  DoneKeyBoard;
//  Result:=i4Shell(p_saCommand,p_saParam);
//  InitMouse;
//  InitKeyBoard;
{ELSE}
  Result:=u2Shell(p_saCommand,p_saParam);
{ENDIF}  
End;
//=============================================================================

//=============================================================================
Procedure JegasLogo;
//=============================================================================
Var jx, jy: LongInt;
Begin
  jx:=VCGetPenX;
  jy:=VCGetPenY;
  vcsetBGC(red);
  vcsetfgc(white);
  vcWriteXY(jx,jy+1,'     _________ _______  _______  ______  _______');
  vcWriteXY(jx,jy+2,'    /___  ___// _____/ / _____/ / __  / / _____/');
  vcWriteXY(jx,jy+3,'       / /   / /__    / / ___  / /_/ / / /____  ');
  vcWriteXY(jx,jy+4,'      / /   / ____/  / / /  / / __  / /____  /  ');
  vcWriteXY(jx,jy+5,' ____/ /   / /___   / /__/ / / / / / _____/ /   ');
  vcWriteXY(jx,jy+6,'/_____/   /______/ /______/ /_/ /_/ /______/    ');
  vcWriteXY(jx,jy+7,'             Virtually Everything IT            ');
End;
//=============================================================================

//=============================================================================
Procedure JegasLogoFramed;
//=============================================================================
Var jx, jy: LongInt;
Begin
  jx:=VCGetPenX;
  jy:=VCGetPenY;
  vcsetBGC(red);
  vcsetfgc(white);
  vcWriteXY(jx,jy  ,';================================================');
  vcWriteXY(jx,jy+1,';|    _________ _______  _______  ______  ______|');
  vcWriteXY(jx,jy+2,';|   /___  ___// _____/ / _____/ / __  / / _____/');
  vcWriteXY(jx,jy+3,';|      / /   / /__    / / ___  / /_/ / / /____ |');
  vcWriteXY(jx,jy+4,';|     / /   / ____/  / / /  / / __  / /____  / |');
  vcWriteXY(jx,jy+5,';|____/ /   / /___   / /__/ / / / / / _____/ /  |');
  vcWriteXY(jx,jy+6,';/_____/   /______/ /______/ /_/ /_/ /______/   |');
  vcWriteXY(jx,jy+7,';|            Virtually Everything IT           |');
  vcWriteXY(jx,jy+8,';================================================');
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
