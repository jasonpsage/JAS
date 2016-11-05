{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{ }
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
  ug_common,
  ug_jegas;
//=============================================================================

//=============================================================================
//=============================================================================

//=============================================================================
function bTest01: boolean;
//=============================================================================
Var
  MATRIX: JFC_MATRIX;
  MATRIXCOPY: JFC_MATRIX;
  //dt1: TDATETIME;
  //dt2: TDATETIME;
  //saHuntfor: ansistring;
Begin
  result:=true;
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
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  Writeln;
  Writeln('Appending a Row');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  
  Writeln('Appending Row 2');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIX.N);
  Writeln;
  Writeln('Populating Data Long Hand');
  MATRIX.asaMatrix[0]:='Test';
  MATRIX.asaMatrix[1]:='Value';
  MATRIX.asaMatrix[2]:='Test';
  MATRIX.asaMatrix[3]:='Another';
  Writeln('Populating Data Short Hand');
  MATRIX.asaMatrix[MATRIX.uGetIndex(1,1)]:='Test';
  MATRIX.asaMatrix[MATRIX.uGetIndex(1,2)]:='Value';
  MATRIX.asaMatrix[MATRIX.uGetIndex(2,1)]:='Test';
  MATRIX.asaMatrix[MATRIX.uGetIndex(2,2)]:='Another';
  Write('Populating 3 thru 1000000 records...');
  
  //For i:=3 To 10 Do
  //Begin
  //   MATRIX.AppendItem;
  //   MATRIX.asaMatrix[MATRIX.uGetIndex(1,i)]:=CHAR(random(26)+64);
  //   MATRIX.asaMatrix[MATRIX.uGetIndex(2,i)]:=inttostr(i);
  //End;
  //Writeln('Done.');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Zebra');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'linux');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Apple');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Vertigo');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'pear');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'dog');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Cat');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'House');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Speaker');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'University');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Testing');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Bee');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Bird');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Gazelle');
  MAtrix.AppendItem; Matrix.Set_Matrix(1,'Hornet');

  writeln;
  writeln('bSort Test... BEFORE SORT:');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(MAtrix.Get_saMatrix(1,MATRIX.N));
    until not MAtrix.movenext;
  end;
  writeln('REsult: ' + sYesNo(MAtrix.bSort(1,true,false)));
  writeln('bSort Test... aFTER SORT:');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(MAtrix.Get_saMatrix(1));
    until not MAtrix.movenext;
  end;






  //saHuntFor:='500';
  //Writeln('Trying to locate index for record with text value in column 2 = '+saHuntfor);
  //dt1:=now;
  //i:=MATRIX.uFoundItem(2,saHuntFor,False);
  //dt2:=now;
  //Writeln('Milliseconds:',iDiffMSec(dt1,dt2));
  ////Writeln(now);
  //Writeln('iFoundItem(2,'''+saHuntFor+''',false):',i);
  //Writeln('data found there:',MATRIX.asaMatrix[i-1]);
  //Writeln('data found there:',MATRIX.asaMatrix[i]);
  
  Writeln('DeleteAll----------------------------------------------');
  MATRIX.Deleteall;
  
  Writeln('Before Adding Rows - the Results Below');
  Writeln('Get_saMatrix(1,1):',MATRIX.Get_saMatrix(1,1));
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  Writeln;
  Writeln('Appending a Row');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  
  Writeln('Appending Row 2');
  MATRIX.AppendItem;
  Writeln('MoveFirst:',MATRIX.MoveFirst);
  Writeln('MoveLast:',MATRIX.MoveLast);
  Writeln('MovePrevious:',MATRIX.MovePrevious);
  Writeln('MoveNext:',MATRIX.MoveNext);
  Writeln('uGetIndex(1,1):',MATRIX.uGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIX.N);
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
  Writeln('uGetIndex(1,1):',MATRIXCOPY.uGetIndex(1,1));
  Writeln;
  Writeln('Current Row:',MATRIXCOPY.N);
  Writeln;
  if MATRIXCOPY.Get_saMatrix(2,2)='Sage2' then
  begin
    writeln('Compiled, Ran, and ONE random data check looks good.');
    writeln('you can add more data verification checks or just analyze the output.');
    writeln;
    writeln('Test PASSED!');
  end
  else
  begin
    writeln('Expected ''Sage2'', got ',MATRIXCOPY.Get_saMatrix(2,2),' in MATRIXCOPY.Get_saMatrix(2,2)');
  end;


  writeln;
  writeln('bSort Test... BEFORE SORT:');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(MAtrix.Get_saMatrix(1,MATRIX.N));
    until not MAtrix.movenext;
  end;
  writeln('REsult: ' + sYesNo(MAtrix.bSort(1,true,false)));
  writeln('bSort Test... aFTER SORT:');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(MAtrix.Get_saMatrix(1));
    until not MAtrix.movenext;
  end;

  MATRIX.DeleteAll;
  MATRIX.AppendItem; Matrix.Set_Matrix(1,'ROW A');
  MATRIX.AppendItem; Matrix.Set_Matrix(1,'ROW B');
  MATRIX.AppendItem; Matrix.Set_Matrix(1,'ROW C');
  writeln('--Before DeleteItem--');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(Matrix.Get_saMatrix(1));
    until not MATRIX.MoveNext;
  end;
  MATRIX.MoveFirst;writeln('N1: ',MATRIX.N);
  MAtrix.MoveNExt;writeln('N2: ',MATRIX.N);
  MAtrix.DeleteITem;
  MAtrix.MoveNExt;writeln('N2b: ',MATRIX.N);
  writeln('--After DeleteItem--');
  if MATRIX.MoveFirst then
  begin
    repeat
      writeln(Matrix.Get_saMatrix(1));
    until not MATRIX.MoveNext;
  end;


end;
//=============================================================================











//=============================================================================
function Test_jfc_Matrix: boolean;
//=============================================================================
begin
  result:=bTest01;
  //if result then result:=bTest02;
end;
//=============================================================================



//=============================================================================
begin
//=============================================================================
  write('JFC_MATRIX Unit Tests ');
  if Test_jfc_Matrix then
    writeln('PASSED')
  else
    writeln('FAILED.');
//=============================================================================
End.
//=============================================================================



//*****************************************************************************
// EOF
//*****************************************************************************
