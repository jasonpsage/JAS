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
// This Unit has Some Console animations, some resembling ANSI ART.
// These are fun, good code examples of the uc_console.pp unit.
// I use this as a screen saver in the console version of JAS/JegasCRM's
// setp program.
unit uc_animate;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uc_animate.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
{}
                               Interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
{}
Uses
//=============================================================================
{}
  sysutils,
  ug_jegas,
  ug_common,
  uc_Console,
  ug_JFC_XDL,
  ug_JFC_DL;
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



//=============================================================================
{ }
Procedure InitBlocks(p_HowMany: LongInt);//< Use first for the blocks routines to work right. pass how many blocks you'd like. Remember if you get a black one you might not see it.
Var chBlock: Char; //< Character to use as a block.
Procedure UpdateBlocks;//< One Iteration of the Blocks Moving.
Procedure DoneBlocks;//< Properly cleans up the blocks variables, objects etc.
{ }
Procedure InitFish(p_HowMany: LongInt);//< Use first for the fish routines to work right
Procedure UpdateFish;//< One Iteration of the fish Moving.
Procedure DoneFish;//< Properly cleans up the fish variables, objects etc.

Procedure InitStars;//< Use first for the stars routines to work right
Procedure InitStars(p_iVC: Integer);//< Works like InitStars except your specifiy the VC or Virtual Console ID to render the stars on.
Procedure UpdateStars;//< One Iteration of the stars Moving.
Procedure DoneStars;//< Properly cleans up the fish variables, objects etc.

{ }
// Prewritten Animated splash screen with five lines of text you can use for under the Jegas Logo.
Procedure JegasLogoSplash(
  p_saLine01: ansistring; 
  p_saLine02: ansistring; 
  p_saLine03: ansistring; 
  p_saLine04: ansistring; 
  p_saLine05: ansistring
);
{ }
Procedure InitJegasLogoSplash( //< Use first for the stars routines to work right
  p_saLine01: ansistring; 
  p_saLine02: ansistring; 
  p_saLine03: ansistring; 
  p_saLine04: ansistring; 
  p_saLine05: ansistring
);
Function UpdateJegasLogoSplash:Boolean;//< One Iteration of the Jegas Logo Moving.
Procedure DoneJegasLogoSplash;//< Properly cleans up the jegas logo variables, objects etc.
{ }
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
//



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












// bof - u01c_Animate_Include_Stars_Def.pp
//=============================================================================
Type rtStar = Record
//=============================================================================
  Z: LongInt; // Z Order (Affects Speed Also)
  Col: Byte; // White, Light Gray, DarkGray
  X: Integer;
  Y: Integer;
End;
//=============================================================================

//=============================================================================
Const
//=============================================================================
  // Star Field
  cn_StarZ = 5;
  
  {$IFDEF WINDOWS}
  cn_StarZ1=256; //(Number of stars furthest away)
  cn_StarZ2=128; // Z1
  cn_StarZ3=64;
  cn_StarZ4=16;
  cn_StarZ5=2;                      
  {$ELSE}
  cn_StarZ1=64; //(Number of stars furthest away)
  cn_StarZ2=32; // Z1
  cn_StarZ3=16;
  cn_StarZ4=4;
  cn_StarZ5=1;                      
  {$ENDIF}
  


  cn_Stars=cn_StarZ1 +
           cn_StarZ2 +
           cn_StarZ3 +
           cn_StarZ4 +
           cn_StarZ5;
  
  //cn_StarDelay=3;
//=============================================================================


//=============================================================================
Var
//=============================================================================
  garStar: array [1..cn_Stars] Of rtStar; 
  gStarCh: array [1..8] Of Char;
  gStarTime: array [1..cn_StarZ] Of Integer;
  gStarVC: Integer;
  
  //gStarDelay: LongInt;
//=============================================================================
// eof - u01c_Animate_Include_Stars_Def.pp




// bof - u01c_Animate_Include_Stars_Code.pp
//=============================================================================
Procedure InitStars(p_iVC: Integer);
//=============================================================================
Var t: Integer;
Begin
  
  gStarVC:=p_iVC;
  SetActiveVC(gStarVC);
  randomize;

//  gStarCh[1]:=#15; // � Big Asterick  
//  gStarCh[2]:=#4;  // � Diamond  
//  gStarCh[3]:=#42; // * Asterick 
//  gStarCh[4]:=#111;// o Letter Oe lowercase
//  gStarCh[5]:=#237;// � Small Saturn
//  gStarCh[6]:=#248;// � Smaller Oe gfx char
//  gStarCh[7]:=#249;// � Dot 1 like period
//  gStarCh[8]:=#250;// � Dot 2 Tiny


  {$IFDEF WINDOWS}
  gStarCh[1]:=#250;
  gStarCh[2]:=#250;
  gStarCh[3]:=#250;
  gStarCh[4]:=#249;
  If gsaTerm='' Then gStarCh[5]:=#15 Else gStarCH[5]:='*';
  {$ELSE}
  gStarCh[1]:='.';
  gStarCh[2]:='''';
  gStarCh[3]:='~';
  gStarCh[4]:='+';
  gStarCH[5]:='*';
  {$ENDIF}

  //gStarWait[1]:=cn_StarWaitMsecZ1;
  //gStarWait[2]:=cn_StarWaitMsecZ2;
  //gStarWait[3]:=cn_StarWaitMsecZ3;
  //gStarWait[4]:=cn_StarWaitMsecZ4;
  //gStarWait[5]:=cn_StarWaitMsecZ5;
  


//  gStarVCB:=NewVC;
//  VCSetCursorType(crHidden);
//  VCSetFGC(blue);
//  for t:= 1 to 500 do
//  begin
//    VCWriteXY(
//      random(giConsoleWidth+1),
//      random(giConsoleHeight+1),
//      gStarCh[1]
//    );
//  end;

  
  
  //gStarVC:=NewVC;
  VCFillBoxCtr(giConsoleWidth, giConsoleHeight, #0);
  VCSetCursorType(crHidden);

  For t:=1 To cn_Stars Do
  Begin
    garStar[t].X:=random(giConsoleWidth)+1;
    garStar[t].Y:=random(giConsoleHeight)+1;//+21);
    If t <= cn_StarZ1 Then
    Begin
      garStar[t].Z:=1;
      garStar[t].Col:=darkgray;
      //garStar[t].Col:=blue;
    End
    Else
    If t <= cn_StarZ1+cn_StarZ2 Then
    Begin
      garStar[t].Z:=2;
      garStar[t].Col:=lightgray;
      //garStar[t].Col:=red;
    End
    Else
    If t <= cn_StarZ1 +cn_StarZ2 + cn_StarZ3 Then
    Begin
      garStar[t].Z:=3;
      garStar[t].Col:=lightgray;
      //garStar[t].Col:=green;
    End
    Else
    If t <= cn_StarZ1+cn_StarZ2+ cn_StarZ3 + cn_StarZ4 Then
    Begin
      garStar[t].Z:=4;
      garStar[t].Col:=white;
      //garStar[t].Col:=lightgreen;
    End
    Else
    Begin
      garStar[t].Z:=5;
      garStar[t].Col:=white;
    End;
  End;

  //gStarTime[1]:=random(cn_StarZ1 div 2);
  //gStarTime[2]:=random(cn_StarZ2 div 2);
  //gStarTime[3]:=random(cn_StarZ3 div 2);
  //gStarTime[4]:=random(cn_StarZ4 div 2);
  //gStarTime[5]:=random(cn_StarZ5 div 2);

  
  //gStarTime[1]:=i4MSec;
  //gStarTime[2]:=i4Msec;
  //gStarTime[3]:=i4Msec;
  //gStarTime[4]:=i4MSec;
  //gStarTime[5]:=i4Msec;
  
  gStarTime[1]:=1;
  gStarTime[2]:=1;
  gStarTime[3]:=1;
  gStarTime[4]:=1;
  gStarTime[5]:=1;
  
  //gStarDelay:=i4MSec;

End;
//=============================================================================


//=============================================================================
Procedure InitStars;
Begin
  InitStars(NewVC);
End;
//=============================================================================


//=============================================================================
Procedure UpDateStars;
//=============================================================================
Var t: LongInt;
Begin
  
  setactiveVC(gStarVC);
  vcclear;

//  if (i4MSec<gStarDelay) or (i4MSec-gStarDelay>cn_StarDelay) then
//  begin
//    gStarDelay:=i4MSec;
    For t:=1 To cn_StarZ Do
    Begin
      gStarTime[t]-=1;
    End;
//  end;
  
  For t:=1 To cn_Stars Do
  Begin
    If (gStarTime[garStar[t].Z]<=0) Then
    Begin
      garStar[t].X-=1;
    End;

    If garStar[t].X<1 Then
    Begin
      garStar[t].X:=giConsoleWidth+1+random(10);
      garStar[t].Y:=random(giConsoleHeight+1);//20); // allow certain amount of rnd *'s
    End;
    
    VCPutFGC(garStar[t].X,garStar[t].Y,garStar[t].col);
    VCPutChar(garStar[t].X,garStar[t].Y,gStarCh[garStar[t].Z]);
  End;
  
  For t:=1 To cn_StarZ Do
  Begin
    If gStarTime[t]<=0 Then
    Case t Of
    1:gStarTime[1]:=32;
    2:gStarTime[2]:=16;
    3:gStarTime[3]:=8;
    4:gStarTime[4]:=4;
    5:gStarTime[5]:=0;
    End;
  End;
End;
//=============================================================================


//=============================================================================
Procedure DoneStars;
//=============================================================================
Begin
  RemoveVC(gStarVC);
//  RemoveVC(gStarVCB);
End;
//=============================================================================
// eof - u01c_Animate_Include_Stars_Code.pp






// bof - u01c_SageApiSplash_Include_Def.pp
//=============================================================================
Const 
//=============================================================================
  cn_SageY = 3;//used by splash
  cn_SplashDelay = 10;
//=============================================================================


//=============================================================================
Var 
//=============================================================================
  SplashVC: JFC_XDL;
  gSplashCh: array[1..9,1..23] Of AnsiString;
  gSplashSeq: Integer;
  gbSplashDone: Boolean;
  iSplashTime: Integer;
//=============================================================================
// eof - u01c_SageApiSplash_Include_Def.pp



// - bof u01c_SageAPISplash_Include_Code.pp
//=============================================================================
Procedure DrawSplash(p: Integer);
//=============================================================================
Var t: Integer;
Begin
//  if VCHeight>1 then
//  begin
    VCSetWrap(False);
//    VCClear;
    For t:=1 To vcheight Do
    Begin
      //SageLog(1,gSplashCh[p,t]);
      VCWriteXY(1,t,gSplashCh[p,t]);        
    End;
    VCSNRBoxCtr(VCWidth, VCHeight, '~', #0);
//  end;
End;
//=============================================================================



//=============================================================================
Procedure InitJegasLogoSplash(
  p_saLine01: ansistring; 
  p_saLine02: ansistring; 
  p_saLine03: ansistring; 
  p_saLine04: ansistring; 
  p_saLine05: ansistring
);
//=============================================================================
Var s,h: Integer;
    iWidthOfMessage: longint;
Begin
  
  SplashVC:=JFC_XDL.create;  
  
  //gSplashCh[,]:='';

  gSplashCh[1,1]:='~~~~~_________';
  gSplashCh[1,2]:='~~~~/___  ___/';
  gSplashCh[1,3]:='~~~~~~ / /~~~~';
  gSplashCh[1,4]:='~~~~~ / /~~~~~';
  gSplashCh[1,5]:='~____/ /~~~~~~';
  gSplashCh[1,6]:='/_____/~~~~~~~';
  gSplashCh[1,7]:='x';

  gSplashCh[2,1]:='~~~~~______';
  gSplashCh[2,2]:='~~~~/ ____/';
  gSplashCh[2,3]:='~~~/ /___ ~';
  gSplashCh[2,4]:='~~/ ____/~~';
  gSplashCh[2,5]:='~/ /___~~~~';
  gSplashCh[2,6]:='/_____/~~~~';
  gSplashCh[2,7]:='x';


  gSplashCh[3,1]:='~~~~~_______';
  gSplashCh[3,2]:='~~~~/ _____/';
  gSplashCh[3,3]:='~~~/ /~___~~';
  gSplashCh[3,4]:='~~/ /~/  /~~';
  gSplashCh[3,5]:='~/ /__/ /~~~';
  gSplashCh[3,6]:='/______/~~~~';
  gSplashCh[3,7]:='x';

  gSplashCh[4,1]:='~~~~~______';
  gSplashCh[4,2]:='~~~~/ __  /';
  gSplashCh[4,3]:='~~~/ /_/ /~';
  gSplashCh[4,4]:='~~/ __  /~~';
  gSplashCh[4,5]:='~/ /~/ /~~~';
  gSplashCh[4,6]:='/_/~/_/~~~~';
  gSplashCh[4,7]:='x';

  gSplashCh[5,1]:='~~~~~_______';
  gSplashCh[5,2]:='~~~~/ _____/';
  gSplashCh[5,3]:='~~~/ /____~~';
  gSplashCh[5,4]:='~~/____  /~~';
  gSplashCh[5,5]:='~_____/ /~~~';
  gSplashCh[5,6]:='/______/~~~~';
  gSplashCh[5,7]:='x';
  



  gSplashCh[6, 1]:='~~~~\~~~~~~~~~~~~~~~~~~~~~~';
  gSplashCh[6, 2]:='~~~~~\\~~~~~~~~~~~~~~~~~~~~';
  gSplashCh[6, 3]:='~~~~~~\~\~~~~~~~~~~~~~~~~~~';
  gSplashCh[6, 4]:='~~~~~~~\~~\~~~~~~~~~~~~~~~~';
  gSplashCh[6, 5]:='~~~~~~~~\~~~\~~~~~~~~~~~~~~';
  gSplashCh[6, 6]:='~~~~~~~~~\~~~~\~~~~~~~~~~~~';
  gSplashCh[6, 7]:='~~~~~~~~~~\~~~~~\~~~~~~~~~~';
  gSplashCh[6, 8]:='~~~~~~~~~~~\~~~~~~\~~~~~~~~';
  gSplashCh[6, 9]:='~~~~~~~~~~~~\~~~~~~~\~~~~~~';
  gSplashCh[6,10]:='_____________\~~~~~~~~\~~~~';
  gSplashCh[6,11]:='\~~~~~~~~~~~~~~~~~~~~~~~\~~';
  gSplashCh[6,12]:='~~\~~~~~~~~~~_____________\';
  gSplashCh[6,13]:='~~~~\~~~~~~~~\~~~~~~~~~~~~~';
  gSplashCh[6,14]:='~~~~~~\~~~~~~~\~~~~~~~~~~~~';
  gSplashCh[6,15]:='~~~~~~~~\~~~~~~\~~~~~~~~~~~';
  gSplashCh[6,16]:='~~~~~~~~~~\~~~~~\~~~~~~~~~~';
  gSplashCh[6,17]:='~~~~~~~~~~~~\~~~~\~~~~~~~~~';
  gSplashCh[6,18]:='~~~~~~~~~~~~~~\~~~\~~~~~~~~';
  gSplashCh[6,19]:='~~~~~~~~~~~~~~~~\~~\~~~~~~~';
  gSplashCh[6,20]:='~~~~~~~~~~~~~~~~~~\~\~~~~~~';
  gSplashCh[6,21]:='~~~~~~~~~~~~~~~~~~~~\\~~~~~';
  gSplashCh[6,22]:='~~~~~~~~~~~~~~~~~~~~~~\~~~~';
  gSplashCh[6,23]:='x';

  iWidthOfMessage:=length(p_saLine01);
  if length(p_saLine02)>iWidthOfMessage then iWidthOfMessage:=length(p_saLine02);
  if length(p_saLine03)>iWidthOfMessage then iWidthOfMessage:=length(p_saLine03);
  if length(p_saLine04)>iWidthOfMessage then iWidthOfMessage:=length(p_saLine04);
  if length(p_saLine05)>iWidthOfMessage then iWidthOfMessage:=length(p_saLine05);
  iWidthOfMessage+=1;

  gSplashCh[7,1]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(p_saLine01)))+p_saLine01,1,iWidthOfMessage);gSplashCh[7,1]:=saSNRStr(gSplashCh[7,1],' ','~');
  gSplashCh[7,2]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(' ')))+' ',1,iWidthOfMessage);gSplashCh[7,2]:=saSNRStr(gSplashCh[7,2],' ','~');
  gSplashCh[7,3]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(p_saLine02)))+p_saLine02,1,iWidthOfMessage);gSplashCh[7,3]:=saSNRStr(gSplashCh[7,3],' ','~');
  gSplashCh[7,4]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(' ')))+' ',1,iWidthOfMessage);gSplashCh[7,4]:=saSNRStr(gSplashCh[7,4],' ','~');
  gSplashCh[7,5]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(p_saLine03)))+p_saLine03,1,iWidthOfMessage);gSplashCh[7,5]:=saSNRStr(gSplashCh[7,5],' ','~');
  gSplashCh[7,6]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(' ')))+' ',1,iWidthOfMessage);gSplashCh[7,6]:=saSNRStr(gSplashCh[7,6],' ','~');
  gSplashCh[7,7]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(p_saLine04)))+p_saLine04,1,iWidthOfMessage);gSplashCh[7,7]:=saSNRStr(gSplashCh[7,7],' ','~');
  gSplashCh[7,8]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(' ')))+' ',1,iWidthOfMessage);gSplashCh[7,8]:=saSNRStr(gSplashCh[7,8],' ','~');
  gSplashCh[7,9]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(p_saLine05)))+p_saLine05,1,iWidthOfMessage);gSplashCh[7,9]:=saSNRStr(gSplashCh[7,9],' ','~');
  gSplashCh[7,10]:=saFixedLength(saRepeatChar(' ',iPlotCenter(iWidthOfMessage,length(' ')))+' ',1,iWidthOfMessage);gSplashCh[7,10]:=saSNRStr(gSplashCh[7,10],' ','~');
  gSplashCh[7,11]:='x';

  For s:=1 To 7 Do
  Begin
    SplashVC.AppendITem;
    h:=1;
    While gSplashCh[s, h]<>'x' Do h+=1;
    If h>1 Then h-=1;
    splashvc.Item_i8User:=NewVC(length(gSplashCH[s, 1]),h);
    VCSetCursorType(crHidden);      
    VCSetFGC(darkgray);
    DrawSplash(s);
    VCSetVisible(False);
    VCSetTransparency(True);
    VCSetOpaqueBG(False);
    //case s of 
    //6,7,8,9: VCSetOpaqueBG(false);
    //end;//case
  End;

  // Start by being letter "S"
  SplashVC.AppendItem;
  SplashVC.Item_i8User:=NewVC(1,1);
  VCSetVisible(False);
  VCSetTransparency(True);
  VCSetOpaqueBG(False);
  VCSetCursorType(crHidden);      
  gSplashSeq:=0;
  gbSplashDone:=True;
End;
//=============================================================================


//=============================================================================
Function UpdateJegasLogoSplash: Boolean;
//=============================================================================
Begin
//  UpdateStars;
  gbSplashDone:=False;  
  Case gSplashSeq Of
  //---------------------------------------------- J
  0: Begin // Start "J"
    Splashvc.foundnth(SplashVC.ListCount);
    SetActiveVC(SplashVC.Item_i8User);
    VCResize(length(gSplashCH[1, 1]),6);
    VCSetFGC(darkGray);
    drawsplash(1);
    VCSetXY(-1*length(gSplashCH[1, 1]),cn_SAGEy);
    VCSetVisible(True);
    gSplashSeq+=1;
    iSplashTime:=iMSec;
  End;
  1: Begin // move "J" right
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(SplashVC.ListCount);
      SetActiveVC(SplashVC.Item_i8User);
      If VCGetX<3 Then
      Begin
        VCSetXY(VCGetX+1,VCGetY);
      End
      Else
      Begin
        VCSetVisible(False);
        splashVC.FoundNth(1);
        SetActiveVC(SplashVC.Item_i8User);
        VCSEtXY(4,cn_SageY);
        VCSetVisible(True);
        BringVCToTop(GetActiveVC);
        gSplashSeq+=1;
      End;
    End;
  End;
  2: Begin // brighten "J"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(1);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,LightGray);
      gSplashSeq+=1;
    End;
  End;
  3: Begin // brighten "J"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(1);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,White);
      gSplashSeq+=1;
    End;
  End;
  4: Begin // brighten "J"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(1);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,lightgreen);
      gSplashSeq+=1;
    End;
  End;
  
  //---------------------------------------------- E
  5: Begin // Start "E"
    Splashvc.foundnth(splashvc.listcount);
    SetActiveVC(SplashVC.Item_i8User);
    VCResize(length(gSplashCH[2, 1]),6);
    VCSetFGC(darkGray);
    drawsplash(2);
    VCSetXY(-1*length(gSplashCH[2, 1]),cn_SAGEy);
    VCSetVisible(True);
    gSplashSeq+=1;
  End;
  6: Begin // move "E" right
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(SplashVC.ListCount);
      SetActiveVC(SplashVC.Item_i8User);
      If VCGetX<13 Then
      Begin
        VCSetXY(VCGetX+1,VCGetY);
      End
      Else
      Begin
        VCSetVisible(False);
        splashVC.FoundNth(2);
        SetActiveVC(SplashVC.Item_i8User);
        VCSEtXY(14,cn_SageY);
        VCSetVisible(True);
        BringVCToTop(GetActiveVC);
        gSplashSeq+=1;
      End;
    End;
  End;
  7: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(2);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,LightGray);
      gSplashSeq+=1;
    End;
  End;
  8: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(2);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,White);
      gSplashSeq+=1;
    End;
  End;
  9: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(2);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,lightgreen);
      gSplashSeq+=1;
    End;
  End;

  //---------------------------------------------- G
  10: Begin // Start "G"
    Splashvc.foundnth(SplashVC.ListCount);
    SetActiveVC(SplashVC.Item_i8User);
    VCResize(length(gSplashCH[3, 1]),6);
    VCSetFGC(darkGray);
    drawsplash(3);
    VCSetXY(-1*length(gSplashCH[3, 1]),cn_SAGEy);
    VCSetVisible(True);
    gSplashSeq+=1;
  End;
  11: Begin // move "G" right
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(SplashVC.ListCount);
      SetActiveVC(SplashVC.Item_i8User);
      If VCGetX<21 Then
      Begin
        VCSetXY(VCGetX+1,VCGetY);
      End
      Else
      Begin
        VCSetVisible(False);
        splashVC.FoundNth(3);
        SetActiveVC(SplashVC.Item_i8User);
        VCSEtXY(22,cn_SageY);
        VCSetVisible(True);
        BringVCToTop(GetActiveVC);
        gSplashSeq+=1;
      End;
    End;
  End;
  12: Begin // brighten "G"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(3);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,LightGray);
      gSplashSeq+=1;
    End;
  End;
  13: Begin // brighten "G"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(3);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,White);
      gSplashSeq+=1;
    End;
  End;
  14: Begin // brighten "G"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(3);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,lightgreen);
      gSplashSeq+=1;
    End;
  End;

  //---------------------------------------------- E
  15: Begin // Start "E"
    Splashvc.foundnth(SplashVC.ListCount);
    SetActiveVC(SplashVC.Item_i8User);
    VCResize(length(gSplashCH[4, 1]),6);
    VCSetFGC(darkGray);
    drawsplash(4);
    VCSetXY(-1*length(gSplashCH[4, 1]),cn_SAGEy);
    VCSetVisible(True);
    gSplashSeq+=1;
  End;
  16: Begin // move "E" right
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(SplashVC.ListCount);
      SetActiveVC(SplashVC.Item_i8User);
      If VCGetX<30 Then
      Begin
        VCSetXY(VCGetX+1,VCGetY);
      End
      Else
      Begin
        VCSetVisible(False);
        splashVC.FoundNth(4);
        SetActiveVC(SplashVC.Item_i8User);
        VCSEtXY(31,cn_SageY);
        VCSetVisible(True);
        BringVCToTop(GetActiveVC);
        gSplashSeq+=1;
      End;
    End;
  End;
  17: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(4);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,LightGray);
      gSplashSeq+=1;
    End;
  End;
  18: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(4);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,White);
      gSplashSeq+=1;
    End;
  End;
  19: Begin // brighten "E"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(4);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,lightgreen);
      BringVcToTop(SplashVC.Item_i8User);
      gSplashSeq+=1;
    End;
  End;





  //---------------------------------------------- S
  20: Begin // Start "S"
    Splashvc.foundnth(SplashVC.ListCount);
    SetActiveVC(SplashVC.Item_i8User);
    VCResize(length(gSplashCH[5, 1]),6);
    VCSetFGC(darkGray);
    drawsplash(5);
    VCSetXY(-1*length(gSplashCH[5, 1]),cn_SAGEy);
    VCSetVisible(True);
    gSplashSeq+=1;
  End;
  21: Begin // move "S" right
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(SplashVC.ListCount);
      SetActiveVC(SplashVC.Item_i8User);
      If VCGetX<38 Then
      Begin
        VCSetXY(VCGetX+1,VCGetY);
      End
      Else
      Begin
        VCSetVisible(False);
        splashVC.FoundNth(5);
        SetActiveVC(SplashVC.Item_i8User);
        VCSEtXY(39,cn_SageY);
        VCSetVisible(True);
        BringVCToTop(GetActiveVC);
        gSplashSeq+=1;
      End;
    End;
  End;
  22: Begin // brighten "S"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(5);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,LightGray);
      gSplashSeq+=1;
    End;
  End;
  23: Begin // brighten "S"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(5);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,White);
      gSplashSeq+=1;
    End;
  End;
  24: Begin // brighten "S"
    If (iMSec<iSplashTime) OR (iMSec-iSplashTime>cn_SplashDelay) Then
    Begin
      iSplashTime:=iMSec;
      Splashvc.foundnth(5);
      SetActiveVC(SplashVC.Item_i8User);   
      VCFillBoxFGCCTR(VCWidth,VCHeight,lightgreen);
      BringVcToTop(SplashVC.Item_i8User);
      gSplashSeq+=1;
    End;
  End;









  //---------------------------------------------- 
  // Bolt and MEssages
  25: Begin
    // bolt 6
    SplashVC.FoundNth(6);
    SetActiveVC(SplashVC.Item_i8User);
    VCFillBoxFGCCTR(VCWidth,VCHeight,Yellow);
    VCSetXY(50,cn_SageY);
    BringVCToTop(GetActiveVC);
    VCSetVisible(True);
    
    // Message 7
    SplashVC.FoundNth(7);
    SetActiveVC(SplashVC.Item_i8User);
    VCFillBoxFGCCTR(VCWidth,VCHeight,White);
    VCSetXY(9,cn_SageY+10);
    BringVCToTop(GetActiveVC);
    VCSetVisible(True);
    gSplashSeq+=1;
  End;
  2000: Begin
    SplashVC.MoveFirst;    
    repeat
      SetActiveVC(SplashVC.Item_i8User);
      VCSetVisible(False);
    Until not splashVc.movenext;  
    gSplashseq:=0;
  End;
  Else 
  Begin
    gSplashSeq+=1;
    gbSplashDone:=True;
  End;


  End;//case
  Result:=gbSplashDone;
End;
//=============================================================================

//=============================================================================
Procedure DoneJegasLogoSplash;
//=============================================================================
Begin
//  DoneStars;
  While SplashVC.ListCount>0 Do Begin
//    SageLog(1,'Removing SplashVC.N:'+inttostr(splashvc.n)+' '+
//              'SplashVC.UID:'+inttostr(splashvc.uid)+' '+
//              'SplashVC.Item_i8User:'+inttostr(SplashVC.Item_i8User));
    RemoveVC(SplashVC.Item_i8User);
    SplashVC.DeleteItem;
  End;
  SplashVC.destroy;
End;
//=============================================================================


//=============================================================================
Procedure JegasLogoSplash(
  p_saLine01: ansistring; 
  p_saLine02: ansistring; 
  p_saLine03: ansistring; 
  p_saLine04: ansistring; 
  p_saLine05: ansistring
);
//=============================================================================
Var bDoneSplash: Boolean;
    iTime: Integer;
    iTimeDiff: Integer;
Begin
  InitConsole;
  InitStars;
  InitJegasLogoSplash(
    p_saLine01,
    p_saLine02,
    p_saLine03,
    p_saLine04,
    p_saLine05
  );
  bDoneSplash:=False;
  iTime:=iMSec;
  repeat
    If not bDoneSplash Then bDoneSplash:=UpdateJegasLogoSplash;
    //else UpdateStars;
    UpDateStars;
    UpdateConsole;
    iTimeDiff:=iMSec-iTime;
  Until (iTimeDiff>15000) OR (iTimeDiff<0) or (keyhit) or (MEvent);
  While keyhit Do getkeypress;
  DoneStars;
  DoneJegasLogoSplash;
  DoneConsole;
End;
//=============================================================================



//=============================================================================
// - eof u01c_SageAPISplash_Include_Code.pp



























//=============================================================================
Const
//=============================================================================
  cch_Block = #206;
//=============================================================================

//=============================================================================
Type TVC = Class(JFC_DLITEM)
//=============================================================================
  iVCUID: Integer;
  iMSec: Integer;
  iDir: Integer;
  iSpeed: Integer;
  iObject: Integer;
End;
//=============================================================================

//=============================================================================
Type TVCDL = Class(JFC_DL)
//=============================================================================
  Function pvt_createitem: TVC; override;
  Procedure pvt_destroyitem(p_ptr: pointer); override;
End;
//=============================================================================



//=============================================================================
Var 
//=============================================================================
  BLOCKVC: TVCDL; // Used to Track VC (Virtual Consoles)
  gi4BlockTime: LongInt;
  
  FISHVC: TVCDL;
  gFish: array [1..10,1..30] Of AnsiString;
  gFishSpeed: array [0..10,1..3] Of LongInt; // zero for bubbles
  gFishBubbleVC: LongWord;
  gFishBubbleSpeed: Integer;
  gFishBubbleTime: Integer;


  giBlocksMaxLeft  : integer;
  giBlocksMaxRight : integer;
  giBlocksMaxUp    : integer;
  giBlocksMaxDown  : integer;
  giBlockDelay     : integer;
  giFishMaxLeft    : integer;
  giFishMaxRight   : integer;
  giFishMaxUp      : integer;
  giFishMaxDown    : integer;


//=============================================================================



















//=============================================================================
Procedure DrawFish(p_Left:Boolean);
//=============================================================================
Var t: LongInt;
Begin
//  if VCHeight>1 then
//  begin
    For t:=1 To vcHeight Do
    Begin
      If p_Left Then
      Begin
        VCDrawBGXY(1,t,gFish[TVC(FishVC.lpitem).iObject,t]);        
      End
      Else
      Begin
        VCDrawBGXY(1,t,saReverse(gFish[TVC(FishVC.lpitem).iObject,t]));        
      End;
    End;
    VCSNRBoxCtr(VCWidth, VCHeight, ' ', #176);
//  end;
  VCSetVisible(True);
End;
//=============================================================================



//=============================================================================
Procedure DrawBubble;
//=============================================================================
Begin
  Case random(4) Of
  0:Begin 
    VCDrawBGXY(1, 1,'       77777        ');
    VCDrawBGXY(1, 2,'     77     77      ');
    VCDrawBGXY(1, 3,'    7  7      7     ');
    VCDrawBGXY(1, 4,'   7           7    ');
    VCDrawBGXY(1, 5,'   7           7    ');
    VCDrawBGXY(1, 6,'    7         7     ');
    VCDrawBGXY(1, 7,'     77     77      ');
    VCDrawBGXY(1, 8,'       77777        ');
    VCDrawBGXY(1, 9,'                    ');
    VCDrawBGXY(1,10,'                    ');
  End;
  1: Begin
    VCDrawBGXY(1, 1,'                    ');
    VCDrawBGXY(1, 2,'                    ');
    VCDrawBGXY(1, 3,'    777             ');
    VCDrawBGXY(1, 4,'   7   7            ');
    VCDrawBGXY(1, 5,'   7   7            ');
    VCDrawBGXY(1, 6,'    777             ');
    VCDrawBGXY(1, 7,'                    ');
    VCDrawBGXY(1, 8,'            7       ');
    VCDrawBGXY(1, 9,'                    ');
    VCDrawBGXY(1,10,'                    ');
  End;
  2:Begin
    VCDrawBGXY(1, 1,'                    ');
    VCDrawBGXY(1, 2,'                 7  ');
    VCDrawBGXY(1, 3,'  7                 ');
    VCDrawBGXY(1, 4,'                    ');
    VCDrawBGXY(1, 5,'                    ');
    VCDrawBGXY(1, 6,'         7          ');
    VCDrawBGXY(1, 7,'                    ');
    VCDrawBGXY(1, 8,'             7      ');
    VCDrawBGXY(1, 9,'                    ');
    VCDrawBGXY(1,10,'                    ');
  End;
  3:Begin
    VCDrawBGXY(1, 1,'             77     ');
    VCDrawBGXY(1, 2,'            7  7    ');
    VCDrawBGXY(1, 3,'   77777     77     ');
    VCDrawBGXY(1, 4,' 77     77          ');
    VCDrawBGXY(1, 5,'7   7     7         ');
    VCDrawBGXY(1, 6,'7         7         ');
    VCDrawBGXY(1, 7,'7         7         ');
    VCDrawBGXY(1, 8,' 77     77          ');
    VCDrawBGXY(1, 9,'   77777            ');
    VCDrawBGXY(1,10,'                    ');
  End;
  End;//case  
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
Procedure InitBlocks(p_HowMany: LongInt);
//=============================================================================
Var s: LongInt;
   fg,bg: Byte;
Begin
  giBlocksMaxLeft    := (vcwidth div 2)*-1;
  giBlocksMaxRight   := vcwidth+(vcwidth div 2);
  giBlocksMaxUp      := (vcheight div 2)*-1;
  giBlocksMaxDown    := vcheight+(vcheight div 2);
  giBlockDelay       := 5;


  BlockVC:=TVCDL.create;
  If p_HowMany>0 Then
  Begin
    randomize;
    For s:=1 To p_HowMany Do
    Begin
      fg:=random(16);                // FGColor
      bg:=random(7)+1;               // BGColor
      If fg=bg Then Begin fg:=white; bg:=blue; End;
      BlockVC.AppendItem;
      tvc(BlockVC.lpitem).iVCUID:=NewVC(
             10, 10, // X,Y of Virtual Screen
             random(40)+8, random(8)+8,  // VWidth and VHeight
             fg,                 // FGColor
             bg                // BGColor
        );
      VCSetCursorType(crHidden);      
      VCFillBoxCtr(VCWidth, VCHeight, chBlock);
      VCSetTransparency(True);
      If random(2)=1 Then
      Begin
        VCFillBoxCtr(VCWidth-(VCWidth Div 2), VCHeight-(VCHeight Div 2),#0);
      End;
      TVC(BlockVC.lpitem).iDir:=random(8); //direction
    End;
  End;
  gi4BlockTime:=iMSec;  
End;
//=============================================================================

//=============================================================================
Procedure UpdateBlocks;
//=============================================================================
Var i4TimeDiff: LongInt;
Begin
  If BlockVC.ListCount>0 Then
  Begin
    i4TimeDiff:=iMSec-gi4BlockTime;
    If (i4TimeDiff>giBlockDelay) OR (i4TimeDiff<0) Then
    Begin
      gi4BlockTime:=iMSec;
    
      BlockVC.MoveFirst;
      repeat
        SetActiveVC(TVC(BlockVC.lpitem).iVCUID);
        Case TVC(BlockVC.lpitem).iDir Of
        0: VCSetXY(VCGetX+2, VCGetY  );//right
        1: VCSetXY(VCGetX+2, VCGetY+2);//down & rgt
        2: VCSetXY(VCGetX,   VCGetY+2);//down
        3: VCSetXY(VCGetX-2, VCGetY+2);//down & left
        4: VCSetXY(VCGetX-2, VCGetY  );//left
        5: VCSetXY(VCGetX-2, VCGetY-2);//left & up
        6: VCSetXY(VCGetX,   VCGetY-2);//up
        7: VCSetXY(VCGetX+2, VCGetY-2);//up & rgt
        End;
        If VCGetx<giBlocksMaxLeft Then
        Begin
          TVC(BlockVC.lpitem).iDir:=random(8);
          VCSetXY(VCGetX+10, VCGetY);
        End;
        If VCGetx>giBlocksMaxRight Then
        Begin
          TVC(BlockVC.lpitem).iDir:=random(8);
          VCSetXY(VCGetX-10, VCGetY);
        End;
        If VCGetY<giBlocksMaxUp Then
        Begin
          TVC(BlockVC.lpitem).iDir:=random(8);
          VCSetXY(VCGetX, VCGetY+10);
        End;
        If VCGetY>giBlocksMaxDown Then
        Begin
          TVC(BlockVC.lpitem).idir:=random(8);
          VCSetXY(VCGetX, VCGetY-10);
        End;
      Until not BlockVC.MoveNExt;
    End;
  End;
End;
//=============================================================================

//=============================================================================
Procedure DoneBlocks;
//=============================================================================
Begin
  If BlockVC.ListCount>0 Then
  Begin
    While BlockVC.ListCount>0 Do Begin
      RemoveVC(TVC(BlockVC.lpItem).iVCUID);
      BlockVC.DeleteItem;
    End;
  End;
  BlockVC.destroy;
End;
//=============================================================================





















//=============================================================================
Procedure InitFish(p_HowMany: LongInt);
//=============================================================================
Var s: LongInt;
    h: Byte;
    bShark: Boolean;
    rX, rY: Integer;
Begin
  giFishMaxLeft    := (vcwidth div 2)*-1;
  giFishMaxRight   := vcwidth+(vcwidth div 2);
  giFishMaxUp      := (vcheight div 2)*-1;;
  giFishMaxDown    := vcheight+(vcheight div 2);;

  FishVC:=TVCDL.create;

//  Black =   0
//  Blue =    1
//  Green =   2
//  Cyan =    3
//  Red =     4
//  Magenta=  5
//  Brown =   6
//  LightGray=7


  gFishSpeed[0,1]:=10;
  gFishSpeed[0,2]:=50;
  gFishSpeed[0,3]:=200;



  gFish[1,1]:='       6      6';
  gFish[1,2]:=' 666666666   66';
  gFish[1,3]:='666066666666666';
  gFish[1,4]:=' 666666666   66';
  gFish[1,5]:='       6      6';
  gFish[1,6]:='x';
  
  gFishSpeed[1,1]:=0;
  gFishSpeed[1,2]:=100;
  gFishSpeed[1,3]:=400;
  
  
  gFish[2,1]:='              6        ';
  gFish[2,2]:='           666       66';
  gFish[2,3]:='    225226662      66  ';
  gFish[2,4]:='   52025222252   6666  ';
  gFish[2,5]:='  22522252222522666    ';
  gFish[2,6]:='  22252225222252666    ';
  gFish[2,7]:=' 22222522252222  66    ';
  gFish[2,8]:='   222262225       66  ';
  gFish[2,9]:='        6            6 ';
  gFish[2,10]:='x';

  gFishSpeed[2,1]:=50;
  gFishSpeed[2,2]:=200;
  gFishSpeed[2,3]:=500;

  
  gFish[3, 1]:='      5         ';
  gFish[3, 2]:='     5555       ';
  gFish[3, 3]:='    5505555 4   ';
  gFish[3, 4]:='   555555555444 ';
  gFish[3, 5]:='  5  55 5555544 ';
  gFish[3, 6]:=' 5      555554  ';
  gFish[3, 7]:='       555555   ';
  gFish[3, 8]:='      5555554   ';
  gFish[3, 9]:='     5555554    ';
  gFish[3,10]:='    5555554     ';
  gFish[3,11]:='  55555554      ';
  gFish[3,12]:=' 5555554        ';
  gFish[3,13]:='5555554   5     ';
  gFish[3,14]:='55555    5 5    ';
  gFish[3,15]:='5555       55   ';
  gFish[3,16]:=' 55555     55   ';
  gFish[3,17]:='   55555 5555   ';
  gFish[3,18]:='     5555555    ';
  gFish[3,19]:='       555      ';
  gFish[3,20]:='x';

  gFishSpeed[3,1]:=100;
  gFishSpeed[3,2]:=50;
  gFishSpeed[3,3]:=1000;

//  Black =   0
//  Blue =    1
//  Green =   2
//  Cyan =    3
//  Red =     4
//  Magenta=  5
//  Brown =   6
//  LightGray=7

  gFish[4, 1]:='                                         31                                                                        1';
  gFish[4, 2]:='                                        31                                                                       11 ';
  gFish[4, 3]:='                                      331                                                                      31   ';
  gFish[4, 4]:='                                    3331                                                                     311    ';
  gFish[4, 5]:='                                  33331                                                                    3311     ';
  gFish[4, 6]:='                                3333331                                                                  33311      ';
  gFish[4, 7]:='                              333333331                                                                 33311       ';
  gFish[4, 8]:='                           333333333333111                                                             333311       ';
  gFish[4, 9]:='             333333333333333333333333333333333333333333333333                                         333311        ';
  gFish[4,10]:='    333333333333333333333333333333333333333333333333333333333333333333333                            333311         ';
  gFish[4,11]:='333333333333333333333333133133133333333333333333333333333333333333333333333333333333333333333       3333111         ';
  gFish[4,12]:=' 333333333333333330333333133133133333333333333333333333333333333333333333333333333333333333333333333333111          ';
  gFish[4,13]:='   3333333333333333333333133133133333333333333333333333333333333333333333333333333333333333333333333333111          ';
  gFish[4,14]:='     33333333333333333333133133133333333333333333333333333333333333333333333333333333333333333333333333111          ';
  gFish[4,15]:='        11111111111133331331331333333333333333333333333333333333333333333333333333333333333333333333333111          ';
  gFish[4,16]:='             3333333333333333333333333311333333333333333333333333333333333333333333333111111       33333111         ';
  gFish[4,17]:='                 333333333333333333333311333333333333333333333333333333333111111       111111       33333111        ';
  gFish[4,18]:='                       333333333333333311333333333333333333333333333333    111111       111111         333311       ';
  gFish[4,19]:='                               3333333311                                   111111                        3311      ';
  gFish[4,20]:='                                333333311                                                                   311     ';
  gFish[4,21]:='                                 33333311                                                                     11    ';
  gFish[4,22]:='                                  33333311                                                                      1   ';
  gFish[4,23]:='                                   3333311                                                                       1  ';
  gFish[4,24]:='                                     333311                                                                       1 ';
  gFish[4,25]:='                                      333311                                                                       1';
  gFish[4,26]:='                                        33311                                                                       ';
  gFish[4,27]:='                                         33311                                                                      ';
  gFish[4,28]:='                                           33111                                                                    ';
  gFish[4,29]:='                                              11111                                                                 ';
  gFish[4,30]:='x';

  gFishSpeed[4,1]:=200;
  gFishSpeed[4,2]:=400;
  gFishSpeed[4,3]:=800;


  gFish[5, 1]:='          454           4545';
  gFish[5, 2]:='        454           4545  ';
  gFish[5, 3]:='   5454545454545    45454   ';
  gFish[5, 4]:='  4577454545454545454545    ';
  gFish[5, 5]:=' 5450745454545454545454     ';
  gFish[5, 6]:='  454545454545454545454     ';
  gFish[5, 7]:='   5454545454545    4545    ';
  gFish[5, 8]:='        45            4545  ';
  gFish[5, 9]:='          4             454 ';
  gFish[5,10]:='           5              45';
  gFish[5,11]:='x';

  gFishSpeed[5,1]:=10;
  gFishSpeed[5,2]:=20;
  gFishSpeed[5,3]:=50;
  
  
  gFish[6, 1]:='     77777     ';
  gFish[6, 2]:='    75 5 57    ';
  gFish[6, 3]:='   75 5 5 57   ';
  gFish[6, 4]:='  75 5 5 5 57  ';
  gFish[6, 5]:='    7 7  7 7   ';
  gFish[6, 6]:='   7  7  7  7  ';
  gFish[6, 7]:='  7   7   7  7 ';
  gFish[6, 8]:='  7   7    7  7';
  gFish[6, 9]:='   7   7    7 7';
  gFish[6,10]:='   7   7    7  ';
  gFish[6,11]:='    7   7    7 ';
  gFish[6,12]:='x';

  gFishSpeed[6,1]:=300;
  gFishSpeed[6,2]:=800;
  gFishSpeed[6,3]:=1800;

  If p_HowMany>0 Then
  Begin
    randomize;
    bShark:=False;
    For s:=1 To p_HowMany Do
    Begin
      FishVC.AppendItem;
      h:=1;
      TVC(FishVC.lpitem).iObject:=0;
      
      TVC(FishVC.lpitem).iObject:=random(6)+1; // How many kinds of fish
      If bShark and (TVC(FishVC.lpitem).iObject=4) Then
      Begin
        repeat
          TVC(FishVC.lpitem).iObject:=random(6)+1; // How many kinds of fish
        Until TVC(FishVC.lpitem).iObject<>4; // only 1 shark max
      End;
      If TVC(FishVC.lpitem).iObject=4 Then bShark:=True;
      

      While gFish[TVC(FishVC.lpitem).iObject, h]<>'x' Do h+=1;
      If h>1 Then h-=1;
      
      
      rx:=  giFishMaxRight-giFishMaxLeft;
      ry:=  giFishMaxDown-giFishMaxUp;
      
      tvc(FishVC.lpitem).iVCUID:=NewVC(
        random(rx)+giFishMaxLEft,
        random(ry)+giFishMaxUp,
        length(gFish[TVC(FishVC.lpitem).iObject, 1]),
        h); // H=Fishie Height
      VCSetFGC(random(16));
      VCClear;
      TVC(FishVC.lpitem).iDir:=random(8); //direction
      VCSetCursorType(crHidden);      
      VCSetVisible(False);
      VCSetTransparency(True);
    End;
  End;
  
  gFishBubbleVC:=NewVC(40,50,20,10);
  VCSetTransparency(True);
  gFishBubbleSpeed:=gFishSpeed[0,(random(2)+1)];
  gFishBubbleTime:=iMSec;
  DrawBubble;
  
End;
//=============================================================================

//=============================================================================
Procedure UpdateFish;
//=============================================================================
Var bDirchange: Boolean;
Begin
  
  If (iMSec-gFishBubbletime)>gFishBubbleSpeed Then
  Begin
    //Sagelog(1,inttostr(iMSec)+' '+inttostr(gFishBubbleTime)+' '+inttostr(gFishBubbleSpeed)+' Now-Stored='+inttostr(iMSec-gFishBubbleTime));    
    gFishBubbleTime:=iMSec;

    SetActiveVC(gFishBubbleVC);
    VCSetXY(VCGetX,VCGetY-1);
    If VCGetY<-50 Then
    Begin
      gFishBubbleSpeed:=gFishSpeed[0,(random(2)+1)];
      VCSetXY(random(100)-20,giConsoleHeight+10);   
      DrawBubble;
    End;
  End
  Else
  Begin
    If (iMSec-gFishBubbletime)<0 Then // spans midnight;
    Begin
      gFishBubbleTime:=iMSec; // 
    End;
  End;
  
  If FishVC.listCount>0 Then
  Begin
    FishVC.MoveFirst;
    repeat
      bDirChange:=False;
      SetActiveVC(TVC(FishVC.lpitem).iVCUID);
      If vcWidth>1 Then VCSetVisible(True);
      If (iMSec-TVC(FishVC.lpitem).iMSec)>TVC(FishVC.lpitem).iSpeed Then
      Begin
        Case TVC(FishVC.lpitem).iDir Of
        0: VCSetXY(VCGetX+1, VCGetY  );//right
        1: VCSetXY(VCGetX+1, VCGetY+1);//down & rgt
        2: VCSetXY(VCGetX,   VCGetY+1);//down
        3: VCSetXY(VCGetX-1, VCGetY+1);//down & left
        4: VCSetXY(VCGetX-1, VCGetY  );//left
        5: VCSetXY(VCGetX-1, VCGetY-1);//left & up
        6: VCSetXY(VCGetX,   VCGetY-1);//up
        7: VCSetXY(VCGetX+1, VCGetY-1);//up & rgt
        End;
        TVC(fishvc.lpItem).iMSec:=iMSec;
      
        If VCGetx<giFishMaxLeft Then
        Begin
          TVC(FishVC.lpitem).iDir:=random(8);
          bDirChange:=True;
          VCSetXY(giFishMaxLeft, VCGetY);
        End;
        If (VCGetx+vcWidth-1)>giFishMaxRight Then
        Begin
          TVC(FishVC.lpitem).iDir:=random(8);
          bDirChange:=True;
          VCSetXY(giFishMaxRight-VCWidth+1, VCGetY);
        End;
        If VCGetY<giFishMaxUp Then
        Begin
          TVC(FishVC.lpitem).iDir:=random(8);
          bDirChange:=True;
          VCSetXY(VCGetX, giFishMaxUp);
        End;
        If (VCGetY+VCHeight-1)>giFishMaxDown Then
        Begin
          TVC(FishVC.lpitem).iDir:=random(8);
          bDirChange:=True;
          VCSetXY(VCGetX, giFishMaxDown-VCHeight+1);
        End;
        
        If TVC(FishVC.lpitem).iObject<>4 Then // But Not Shark
        Begin
          If random(20)=10 Then
          Begin
            TVC(FishVC.lpitem).iDir:=random(9);// Direction 8 stays still
            bDirChange:=True;
          End;
        End;
      End
      Else
      Begin
        If iMSec-TVC(FishVC.lpItem).iMSec<0 Then
        Begin
          // crossed midnight
          TVC(fishvc.lpItem).iMSec:=iMSec;
        End;
      End;
            
      If bDirChange Then
      Begin
        TVC(FishVC.lpitem).iSpeed:=gFishSpeed[TVC(FishVC.lpitem).iObject,(random(2)+1)];
        Case TVC(FishVC.lpItem).idir Of
        0,1,7: Begin // if Go Right
          DrawFish(False);
        End;  
        3,4,5: Begin // left
          DrawFish(True);
        End;  
        2,6,8: Begin // up or down
          If random(2)=0 Then
            DrawFish(True)
          Else
            DrawFish(False);
        End;
        End;//case
      End;
    Until not FishVC.movenext;  
  End; 
End;
//=============================================================================


//=============================================================================
Procedure DoneFish;
//=============================================================================
Begin
  RemoveVC(gFishBubbleVC);
  If FishVC.ListCount>0 Then
  Begin
    While FishVC.ListCount>0 Do Begin
      RemoveVC(TVC(FishVC.lpITem).iVCUID);
      FishVC.DeleteItem;
    End;
  End;
  FishVC.destroy;
End;
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
// Private Class Routines and Initialization Routine Below


//=============================================================================
Function TVCDL.pvt_createitem: TVC;
//=============================================================================
Begin
  Result:=TVC.Create;
End;
//=============================================================================

//=============================================================================
Procedure TVCDL.pvt_destroyitem(p_ptr: pointer); 
//=============================================================================
Begin
  TVC(p_ptr).Destroy;
End;
//=============================================================================




//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  chBlock:=cch_Block;
//=============================================================================
End.
//=============================================================================


//=============================================================================
// History (Please Insert Historic Entries at top)
//=============================================================================
// Date        Who              Notes
//=============================================================================
// 2002-12-21  Jason P Sage     To be honest I started writing this when I 
//                              was getting frustrated with Keyboard perform-
//                              ance with the SageUI Unit. This was a funny
//                              conversation piece with my girlfriend. The 
//                              first animation started as demo for the console
//                              unit and I just took it a bit further. This is 
//                              for fun and to show off a bit - simply because
//                              I haven't seen this kind of thing before in 
//                              console applications.
//
//                              There is a special Console Unit routine made
//                              just for this kind of thing called VCDrawBGXY.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
