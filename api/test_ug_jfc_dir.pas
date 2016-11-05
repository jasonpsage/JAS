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
  dos,//temp
  sysutils,//temp
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
function test01: boolean;
//=============================================================================
var DIR: JFC_DIR;

Begin
  result:=true;
  DIR:=JFC_DIR.Create;
  DIR.saFileSpec:='*';
  writeln('DIR.saPath >'+DIR.saPath+'<');
  DIR.LoadDir;///this requires a mod to the base class)
  Writeln('DIR.ListCount:',DIR.ListCount);
  if DIR.MoveFirst then
  begin
    repeat
      Writeln(saFixedLength(JFC_DIRENTRY(DIR.Item_lpPtr).saName,1,30),
              StringOfChar(' ',5),
              'DIR.Item_bDir: ', sYesNo(DIR.Item_bDir));
    until not DIR.movenext;
  end
  else
  begin
    writeln('Empty Directory? So that is how you test a directory CLASS? O_o');
    result:=false;
  end;
  DIR.Destroy;
  if result then writeln('Test01 PASSED!');
End;
//=============================================================================









//=============================================================================
function Test02:boolean;
//=============================================================================
var s: string; f: text; DIR: JFC_DIR;
begin
  writeln('Test 02 Started');
  result:=true;
  DIR:=JFC_DIR.Create;
  if result then
  begin
    s:='.'+DOSSLASH+'deletethistest';
    try createdir(s); except on E:Exception do begin writeln('Unable to make dir: '+s); result:=false; end; end;//try
  end;

  if result then
  begin
    try
      assign(f,s+DOSSLASH+'deleteme.txt');
      rewrite(f);
      writeln(f,'Delete this test file.');
      close(f);
    except on e:EXception do begin
      result:=false;
      writeln('Unable to make test file 1');
    end;
    end;//try
  end;


  if Result then
  begin
    s:='.'+DOSSLASH+'deletethistest'+DOSSLASH+'deletethistest';
    try createdir(s); except on E:Exception do begin writeln('Unable to make dir: '+s); result:=false; end; end;//try
  end;

  if result then
  begin
    try
      assign(f,s+DOSSLASH+'deleteme.txt');
      rewrite(f);
      writeln(f,'Delete this test file.');
      close(f);
    except on e:EXception do begin
      result:=false;
      writeln('Unable to make test file 2');
    end;
    end;//try
  end;






  if result then
  begin
    s:='.'+DOSSLASH+'deletethistest'+DOSSLASH+'deletethistest'+DOSSLASH+'deletethistest';
    try createdir(s); except on E:Exception do begin writeln('Unable to make dir: '+s); result:=false; end; end;//try
  end;


  if result then
  begin
    try
      assign(f,s+DOSSLASH+'deleteme.txt');
      rewrite(f);
      writeln(f,'Delete this test file.');
      close(f);
    except on e:EXception do begin
      result:=false;
      writeln('Unable to make test file 3');
    end;
    end;//try
  end;

  if result then
  begin
    writeln('Calling DeleteThis');
    result:=DIR.DeleteThis('.'+DOSSLASH+'deletethistest');
    if not result then writeln('Failed Call to DIR.DeleteThis(.'+DOSSLASH+'deletethistest)');
    writeln('Calling DeleteThis finished');
  end;

  if result then
  begin
    result:=DirectoryExists('.'+DOSSLASH+'deletethistest');
  end;

  if Result then
  begin
    result:=removeDir('.'+DOSSLASH+'deletethistest');
    if not result then writeln('Directory Remains after delete attempt: .'+DOSSLASH+'deletethistest');
  end;

  DIR.Destroy;
  if result then writeln('Test02 PASSED!');
end;
//=============================================================================






//=============================================================================
Begin // Main Program
//=============================================================================
  if not test01 then writeln('Test01 - Basic JFC_DIR Load and iterate thru a directory') else
  if not test02 then writeln('Test02 - DeleteThis - Which deletes a directory and its files') else writeln('SUCCESS!');

  Writeln;
  Write('Press Enter To End This Program:');
  readln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

