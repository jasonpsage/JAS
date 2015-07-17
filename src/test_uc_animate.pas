{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  Jason@jegas.com             |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|        Virtually Everything IT(tm)                                          |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// Testing the u01c_Animate.pp Unit and "demo" a bit
program test_uc_animate;
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
uses
ug_common,
uc_Console,
uc_Animate,
sysutils;//,u01g_Library;
//=============================================================================

//=============================================================================
// Main Program Starts Here
//=============================================================================
Begin
  initconsole;


  InitStars;
  InitJegasLogoSplash(
    'Console Animate Unit',
    'Jegas API Version: 1.0.0', 
    'By: Jason P Sage',
    'jason@jegas.com',
    'http://www.jegas.com'
  );




  repeat
    UpdateStars;
    UpdateJegasLogoSplash;
    UpdateConsole;
    sleep(32);
  until keyhit;
  GetKeypress;
  //Sagelog(1,'Removing Stars');
  DoneStars;
  //sagelog(1,'removing JegasAPI');
  doneJegasLogosplash;
  //SyncAllVC;
  
  vcclear;
  VCWriteln('Press [ENTER] to see the "Stars" Console animation:');
  VCWriteln('(Remember - pressing a key always goes to next animation.');
  UpdateConsole;
  repeat
    GetKeyPress;
  until rLKey.ch=#13;
  VCClear;

  InitStars;
  repeat
    UpdateStars;
    UpdateConsole;
    sleep(32);
  until keyhit;
  GetKeypress;
  DoneStars;

  VCWrite('Press [ENTER] to see the "Blocks" Console animation:');
  UpdateConsole;
  repeat
    GetKeyPress;
  until rLKey.ch=#13;
  VCClear;
    


  InitBlocks(50);
  repeat
    UpdateBlocks;
    UpdateConsole;
    sleep(32);
  until keyhit;
  GetKeypress;
  DoneBlocks;



  SetActiveVC(1);
  VCClear;
  VCWrite('Press [ENTER] to see the "Fishies" Console animation:');
  UpdateConsole;
  repeat
    GetKeyPress;
  until rLKey.ch=#13;
  VCClear;


  VCSetCursorType(crHidden);
  InitFish(30);
  repeat
    UpdateFish;
//    SetActiveVC(1);
//    VCWriteXY(1,1,'MEMAVAIL:'+inttostr(MEMAVAIL div 1024)+' ');

    UpdateConsole;
    sleep(32);
  until keyhit;
  GetKeypress;
  DoneFish;




  SetActiveVC(1);
  VCSetCursorType(crUnderline);
  VCClear;
  VCWrite('Press [ENTER] to see Everything Together-Very CPU intensive :');
  UpdateConsole;
  repeat
    GetKeyPress;
  until rLKey.ch=#13;
  VCClear;
  
  
  InitStars;
  InitJegasLogoSplash(
    'Console Animate Unit',
    'Jegas API Version: 1.0.0', 
    'By: Jason P Sage',
    'jasonpsage@jegas.com',
    'http://www.jegas.com'
  );
  InitBlocks(20);
  InitFish(30);
  repeat
    UpdateStars;
    UpdateJegasLogoSplash;
    UpdateBlocks;
    UpdateFish;
    UpdateConsole;
    sleep(32);
  until keyhit;
  GetKeypress;
  DoneStars;
  DoneJegasLogoSplash;
  DoneBlocks;
  DoneFish;



  DoneConsole;

End.
//=============================================================================


//*****************************************************************************
// eof 
//*****************************************************************************
