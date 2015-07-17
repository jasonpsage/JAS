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
// Test Jegas' Matrix Unit
program test_ug_jfc_matrix;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$mode objfpc}
//=============================================================================

//=============================================================================
Uses
//=============================================================================
  sysutils,
  ug_jfc_matrix,
  ug_jegas;
//=============================================================================

//=============================================================================
Var
//=============================================================================
  MATRIX: JFC_MATRIX;
  MATRIXCOPY: JFC_MATRIX;
  
  i: Integer;
  dt1: TDATETIME;
  dt2: TDATETIME;
  saHuntfor: ansistring;
//=============================================================================

//=============================================================================
Begin
//=============================================================================
  MATRIX:=JFC_MATRIX.Create;
  MATRIX.SetNoOfColumns(2);
  MATRIX.asaColumns[1]:='Column Name';
  Writeln('Column Name:', MATRIX.Get_saColName(1));
  
  Writeln('Before Adding Rows - the Results Below');
  Writeln('Get_saMatrix(1,1):',MATRIX.Get_saMatrix(1,1));
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  Writeln;
  Writeln('Appending a Row');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  
  Writeln('Appending Row 2');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIX.iNth);
  Writeln;
  Writeln('Populating Data Long Hand');
  MATRIX.asaMatrix[0]:='Test';
  MATRIX.asaMatrix[1]:='Value';
  MATRIX.asaMatrix[2]:='Test';
  MATRIX.asaMatrix[3]:='Another';
  Writeln('Populating Data Short Hand');
  MATRIX.asaMatrix[MATRIX.iGetIndex(1,1)]:='Test';
  MATRIX.asaMatrix[MATRIX.iGetIndex(1,2)]:='Value';
  MATRIX.asaMatrix[MATRIX.iGetIndex(2,1)]:='Test';
  MATRIX.asaMatrix[MATRIX.iGetIndex(2,2)]:='Another';
  Write('Populating 3 thru 1000000 records...');
  
  For i:=3 To 1000 Do 
  Begin
     MATRIX.AppendItem;
     MATRIX.asaMatrix[MATRIX.iGetIndex(1,i)]:='records';
     MATRIX.asaMatrix[MATRIX.iGetIndex(2,i)]:=inttostr(i);
  End;
  Writeln('Done.');
  
  saHuntFor:='500';
  Writeln('Trying to locate index for record with text value in column 2 = '+saHuntfor);
  dt1:=now;
  i:=MATRIX.iFoundItem(2,saHuntFor,False);
  dt2:=now;
  Writeln('Milliseconds:',iDiffMSec(dt1,dt2));
  //Writeln(now);
  Writeln('iFoundItem(2,'''+saHuntFor+''',false):',i);
  Writeln('data found there:',MATRIX.asaMatrix[i-1]);
  Writeln('data found there:',MATRIX.asaMatrix[i]);
  
  Writeln('DeleteAll----------------------------------------------');
  MATRIX.Deleteall;
  
  Writeln('Before Adding Rows - the Results Below');
  Writeln('Get_saMatrix(1,1):',MATRIX.Get_saMatrix(1,1));
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  Writeln;
  Writeln('Appending a Row');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  
  Writeln('Appending Row 2');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIX.iGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIX.iNth);
  Writeln;
  
  
  MATRIX.SetNoOfcolumns(3);
  MATRIX.AppendItem_saName_N_saValue('Jason','Sage');
  MATRIX.AppendItem_saName_N_saValue('Springli','Sage2');
  MATRIX.AppendItem_saName_N_saValue('Kenny','Sage3');
  Writeln('Get_saMatrix(1,1):',MATRIX.Get_saMatrix(1,1));
  Writeln('Get_saMatrix(2,1):',MATRIX.Get_saMatrix(2,1));  
  Writeln('Get_saMatrix(1,2):',MATRIX.Get_saMatrix(1,2));
  Writeln('Get_saMatrix(2,2):',MATRIX.Get_saMatrix(2,2));  
  Writeln('Get_saMatrix(1,3):',MATRIX.Get_saMatrix(1,3));
  Writeln('Get_saMatrix(2,3):',MATRIX.Get_saMatrix(2,3));  
  Writeln('Get_saMatrix(1,1):',MATRIX.Get_saMatrix(1,1));
  Writeln('Get_saMatrix(2,1):',MATRIX.Get_saMatrix(2,1));  
  
  writeln('---- Testing a Copy-----');
  MATRIXCOPY:=JFC_MATRIX.CreateCopy(MATRIX);
  Writeln('MATRIXCOPY.Get_saMatrix(1,1):',MATRIXCOPY.Get_saMatrix(1,1));
  Writeln('MATRIXCOPY.Get_saMatrix(2,1):',MATRIXCOPY.Get_saMatrix(2,1));  
  Writeln('MATRIXCOPY.Get_saMatrix(1,2):',MATRIXCOPY.Get_saMatrix(1,2));
  Writeln('MATRIXCOPY.Get_saMatrix(2,2):',MATRIXCOPY.Get_saMatrix(2,2));  
  Writeln('MATRIXCOPY.Get_saMatrix(1,3):',MATRIXCOPY.Get_saMatrix(1,3));
  Writeln('MATRIXCOPY.Get_saMatrix(2,3):',MATRIXCOPY.Get_saMatrix(2,3));  
  Writeln('MATRIXCOPY.Get_saMatrix(1,1):',MATRIXCOPY.Get_saMatrix(1,1));
  Writeln('MATRIXCOPY.Get_saMatrix(2,1):',MATRIXCOPY.Get_saMatrix(2,1));  
  Writeln('MoveFirst:',MATRIXCOPY.MoveFirst);
  Writeln('MoveLast:',MATRIXCOPY.MoveLast);
  Writeln('MovePrevious:',MATRIXCOPY.MovePrevious);
  Writeln('MoveNext:',MATRIXCOPY.MoveNext);
  Writeln('iGetIndex(1,1):',MATRIXCOPY.iGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIXCOPY.iNth);
  Writeln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
