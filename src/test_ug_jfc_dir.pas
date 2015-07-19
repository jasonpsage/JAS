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
// Testing Reading and Working with Directories
program test_ug_jfc_dir;
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
//=============================================================================
  //sysutils,
  ug_common,
  ug_jfc_dir;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_DIR Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
function test_JFC_DIR: boolean;
//=============================================================================
var DIR: JFC_DIR;

Begin
  DIR:=JFC_DIR.Create;
  Writeln('Created...');
  DIR.saPath:='.';
  DIR.LoadDir;
  Writeln('loaded...ListCount:',DIR.ListCount);
  DIR.MoveFirst;
  repeat
    Writeln(saFixedLength(JFC_DIRENTRY(DIR.Item_lpPtr).saName,1,30),
            StringOfChar(' ',5),
            'Directory:', DIR.Item_bDir);
  until not DIR.movenext;

  DIR.Destroy;
  result:=true;
End;
//=============================================================================







var bResult: boolean;
//=============================================================================
Begin // Main Program
//=============================================================================
  bresult:=true;
  Writeln('Please Wait...');
    
  if bResult then
  Begin
    bResult:=test_JFC_DIR;
    Writeln('JFC_DIR Test 1 Result:',bresult);
  End;
  

  Writeln;
  Write('Press Enter To End This Program:');
  readln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

