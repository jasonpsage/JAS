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
// Unit tests for Jegas' common unit
program test_ug_common;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  ug_common;
//=============================================================================

//=============================================================================
// MAIN
//=============================================================================
// This function is in uxxg_jegas now.
//function test_JLog: boolean;
//Begin
//  result := JLog(1,23041,'Some Entry Test', 'sourcefile.txt');
//End;
//=============================================================================



//=============================================================================
function test_sahumanreadable: boolean;
Begin
  result:='(#0)Hello'=saHumanReadable(#0+'Hello');
End;
//=============================================================================
  
//=============================================================================
function test_DeleteString: boolean;
var sa: AnsiString;
Begin
  sa:=stringofchar('?',1024*1024*16);
  DeleteString(sa,1,1024*1024*8);
  result:=length(sa)=1024*1024*8;
  //riteln('Length sa:',length(sa));
  if result then
  Begin
    //riteln('DeleteStringBigCut Part Worked');
    sa:='hi';
    DeleteString(sa,2,1);
    result:=sa='h';
    //riteln('h?',sa);
    
    if result then
    Begin
      sa:='hi';
      DeleteString(sa,1,1);
      result:=sa='i';
      //riteln('i?',sa);
      if result then
      Begin
        sa:='hi';
        DeleteString(sa,10,5);
        result:=sa='hi';
      End;
    End;
  End;
End;
//=============================================================================

//=============================================================================
function test_saFixedLength: boolean;
//=============================================================================
//var sa: AnsiString;
Begin
  result:=saFixedLength('',1,10)=StringOfChar(' ',10);
//  Writeln('saFixedlength('''',1,10) Result>'+saFixedlength('',1,10)+'<');
  if result then
  Begin
//    Writeln('Test 1 ok');
    result:=saFixedLength('Hello',1,10)='Hello'+StringOfChar(' ',5);
//    Writeln('saFixedlength(''Hello'',1,10) Result>'+saFixedlength('Hello',1,10)+'<');
    if result then
    Begin
//      Writeln('Test 2 ok');
      result:=saFixedLength('HELLO WORLD',6,10)=' WORLD'+StringOfChar(' ',4);
//      Writeln('saFixedlength(''HELLO WORLD'',6,10) Result>'+saFixedlength('HELLO WORLD',6,10)+'<');
    End;
  End;
End;
//=============================================================================


//=============================================================================
function test_saFileToTreeDOS: boolean;
//=============================================================================
var sa: AnsiString;
Begin
  sa:=saFileToTreeDOS('123456789',3,3);
  result:=sa='123'+csDOSSLASH+'456'+csDOSSLASH+'789'+csDOSSLASH;
  Writeln(sa);
End;
//=============================================================================

//=============================================================================
function test_saFileToTreeFWDSLash: boolean;
//=============================================================================
var sa: AnsiString;
Begin
  sa:=saFileToTreeFWDSLash('123456789',3,3);
  result:=sa='123/456/789/';
  Writeln(sa);
End;
//=============================================================================


//=============================================================================
function test_saFormatLongIntWithCommas:boolean;
//=============================================================================
Begin
  result:=saFormatLongIntWithCommas(2000000000)='2,000,000,000';
  //writeln(saFormatLongIntWithCommas(2000000000));
End;
//=============================================================================

//=============================================================================
function test_hextodecandback: boolean;
//=============================================================================
var
  u1: byte;
  bOk: boolean;
begin
  bOk:=true;
  for u1:=0 to 255 do
  begin
    if u8HexToU8(saU8ToHex(u1))<>u1 then bOk:=false;
    if not bOk then
    begin
      writeln('test_hextodecandback did not convert ',u1,' properly.');
    end;
  end;
  result:=bOk;
end;
//=============================================================================

//=============================================================================
function Test_saSNRStr: boolean;
//=============================================================================
begin
  result:=('Test Here'=saSNRStr('Test'+#13+'Here',#13,' ')) and
          ('Test Here'=saSNRStr('Test'+#10+'Here',#10,' ')) ;
end;
//=============================================================================

//=============================================================================
function Test_saDecodeURI: boolean;
//=============================================================================
begin
  result:=saDecodeURI('jet01%40jegas.com')='jet01@jegas.com';
  if not result then
  begin
    writeln('saDecodeURI Fail: ','jet01%40jegas.com');
  end;
  
  
end;
//=============================================================================



var bResult: boolean;
//=============================================================================
Begin // Main Program
//=============================================================================
  bresult:=true;
  
  //if bResult then Begin
  //  bResult:=test_jlog;
  //  Writeln('Jlog Written To');
  //End;
  
  
  if bResult then
  Begin
    bResult:=test_saHumanreadable;
    Writeln('saHumanReadable Test Result:',bresult);
  End;
  
  if bResult then
  Begin
    bResult:=test_DeleteString;
    Writeln('DeleteString Test Result:',bresult);
  End;

  if bResult then
  Begin
    bResult:=test_saFixedLength;
    Writeln('saFixedLength Test Result:',bresult);
  End;

  if bResult then
  Begin
    bResult:=test_saFileToTreeDOS;
    Writeln('saFileToTreeDOS Test Result:',bresult);
  End;

  if bResult then
  Begin
    bResult:=Test_saFileToTreeFWDSLash;
    Writeln('saFileToTreeFWDSLash Test Result:',bresult);
  End;

  if bResult then
  Begin
    bResult:=test_saFormatLongIntWithCommas;
    Writeln('saFormatLongIntWithCommas Test Result:',bresult);
  End;

  if bResult then
  begin
    bResult:=test_hextodecandback;
    Writeln('test_hextodecandback Test Result:',bresult);
  end;

  if bResult then
  begin
    bResult:=Test_saSNRStr;
    Writeln('Test_saSNRStr Test Result:',bresult);
  end;

  if bResult then
  begin
    bResult:=Test_saDecodeURI;
    Writeln('Test_saDecodeURI Test Result:',bresult);
  end;


  Writeln;
  Write('Press Enter To End This Program:');
  readln;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
