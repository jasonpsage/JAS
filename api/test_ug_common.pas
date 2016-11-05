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
var sa: ansistring;
Begin
  sa:=saFileToTreeDOS('123456789',3,3);
  result:=sa='123'+DOSSLASH+'456'+DOSSLASH+'789'+DOSSLASH;
  Writeln(sa);
End;
//=============================================================================

//=============================================================================
function test_saFileToTreeFWDSLash: boolean;
//=============================================================================
var sa: ansiString;
Begin
  sa:=saFileToTreeFWDSLash('123456789',3,3);
  result:=sa='123/456/789/';
  Writeln(sa);
End;
//=============================================================================


//=============================================================================
function test_sFormatLongIntWithCommas:boolean;
//=============================================================================
Begin
  result:=sFormatLongIntWithCommas(2000000000)='2,000,000,000';
  //writeln(saFormatLongIntWithCommas(2000000000));
End;
//=============================================================================

//=============================================================================
function test_hextodecandback: boolean;
//=============================================================================
var
  u1: byte;
  bOk: boolean;
  s:string;
begin
  bOk:=true;


  if bOk then
  begin
    s:=sCharToHex(' ');// $ 20=32space/ascii/blah blah
    writeln('sCharToHex('' '') returned: ',s);
    bOk:=(s='20');
    if not bOk then
    begin
      writeln('sCharToHex looks broke..yup!');
    end;
  end;

  if bOk then
  begin
    s:=sByteToHex(255);
    writeln('sByteToHex(255) returned: ',s);
    bOk:=(s='FF');
    if not bOk then
    begin
      writeln('sByteToHex looks busted - aw man! :(');
    end;
  end;


  if bOk then
  begin
    bOk:=bOk and (sU8ToHex(0)= '0000000000000000');
    bOk:=bOk and (sU8ToHex(1)= '0000000000000001');
    bOk:=bOk and (sU8ToHex(2)= '0000000000000002');
    bOk:=bOk and (sU8ToHex(3)= '0000000000000003');
    bOk:=bOk and (sU8ToHex(4)= '0000000000000004');
    bOk:=bOk and (sU8ToHex(5)= '0000000000000005');
    bOk:=bOk and (sU8ToHex(6)= '0000000000000006');
    bOk:=bOk and (sU8ToHex(7)= '0000000000000007');
    bOk:=bOk and (sU8ToHex(8)= '0000000000000008');
    bOk:=bOk and (sU8ToHex(9)= '0000000000000009');
    bOk:=bOk and (sU8ToHex(10)='000000000000000A');
    bOk:=bOk and (sU8ToHex(11)='000000000000000B');
    bOk:=bOk and (sU8ToHex(12)='000000000000000C');
    bOk:=bOk and (sU8ToHex(13)='000000000000000D');
    if not bOk then
    begin
      writeln('sU8ToHex function is busted.');
      writeln('BEGIN ------Sample output from it-------');
      for u1:=0 to 15 do
      begin
        writeln(u1,': ',sU8ToHex(u1));
      end;
      writeln('END   ------Sample output from it-------');
    end;
  end;
  //for u1:=0 to 255 do
  //begin
  //  if u8HexToU8(sU8ToHex(u1))<>u1 then bOk:=false;
  //  if not bOk then
  //  begin
  //    writeln('test_hextodecandback did not convert ',u1,' properly.');
  //  end;
  //end;
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

//=============================================================================
function Test_saScramble:boolean;
//=============================================================================
begin
  writeln('saScramble(''TEstTest1212!@''):'+saScramble('TEstTest1212!@'));
  result:=saScramble(saScramble('TEstTest1212!@'))='TEstTest1212!@';
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
    bResult:=test_sFormatLongIntWithCommas;
    Writeln('sFormatLongIntWithCommas Test Result:',bresult);
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

  if bResult then
  begin
    bResult:=test_saScramble;
    writeln('Test_saScramble Test Result:',bResult);
  end;

  Writeln;
  Write('Press Enter To End This Program:');
  readln;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
