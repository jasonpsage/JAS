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
// Tests Jegas' USGS unit uxxg_usgs
program test_ug_usgs;
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
  ug_usgs;
//=============================================================================


//=============================================================================
// Shrinks a USGS GridFloat Map by skipping specific number of data points
// Called Floats
//function USGSMapConvert(
//  p_i4FloatsToSkip: longint;
//  p_saFilename_FloatFile_NoExtension: ansistring;
//  p_saOutFile_NoExtension: ansistring
//): boolean;
//=============================================================================
function Test_USGSMapConvert: boolean;
//=============================================================================
var
  sFileIn: string;
  sFileOut: string;
begin
  sFileIn:='.'+DOSSLASH+'data'+DOSSLASH+'usgs-map';
  sFileOut:='.'+DOSSLASH+'data'+DOSSLASH+'usgs-mapconvert';
  writeln('Test_USGSMapConvert(4,'''+sFileIn+''','''+sFileOut+''')');
  result:=USGSMapConvert(4,sFileIn,sFileOut);

end;
//=============================================================================



//=============================================================================
//function USGSMapToBitMap(
//  p_bGrayScale: boolean;
//  p_saFilename_FloatFile_NoExtension: ansistring;
//  p_saOutFile_NoExtension: ansistring;
//  p_iDesiredSize: integer;
//  p_fScale: single;
//  p_lpfnProgressBar: pointer;
//  p_lpfnFormInstance: pointer;
//  p_bRegistered: boolean
///):word;
//=============================================================================
function Test_USGSMapToBitMap: boolean;
//=============================================================================
begin
  result:=0=USGSMapToBitMap(
    true,
    '.'+DOSSLASH+'data'+DOSSLASH+'usgs-map',
    '.'+DOSSLASH+'data'+DOSSLASH+'usgs',
    1024,
    1.0,
    nil,
    nil,
    true
  );
end;
//----------------------------------------------------------------------------

//=============================================================================
//function USGSMapToRaw16(
//  //p_i4DesiredSize: longint;
//  p_saFilename_FloatFile_NoExtension: ansistring;
//  p_saOutFile_WithExtension: ansistring;
//  p_iDesiredSize: integer;
//  p_fScale: single;
//  p_lpfnProgressBar: pointer;
//  p_lpfnFormInstance: pointer;
//  p_bRegistered: boolean
//): word;
//=============================================================================
function Test_USGSMapToRaw16: boolean;
begin
//    '.'+DOSSLASH+'data'+DOSSLASH+'usgs-maptoraw16.raw',

  result:=0=USGSMapToRaw16(
    '.'+DOSSLASH+'data'+DOSSLASH+'usgs-map',
    '.'+DOSSLASH+'data'+DOSSLASH+'usgs-maptoraw16.raw',
    1024,
    1.0,
    nil,
    nil,
    true
  );
end;
//=============================================================================




//=============================================================================
var
//=============================================================================
  bGood: boolean;
//=============================================================================

//=============================================================================
begin
//=============================================================================
  bGood:=true;


  writeln('Testing USGSMapConvert');
  if bGood then
  begin
    bGood:=Test_USGSMapConvert;
    if not bGood then
    begin
      writeln('USGSMapConvert Failed.');
    end;
  end;

  if bGood then
  begin
    writeln('Testing USGSMapToRaw16');
    bGood:=Test_USGSMapToRaw16;
    if not bGood then
    begin
      writeln('Test_USGSMapToRaw16 Failed.');
    end;
  end;


  if bGood then
  begin
    writeln('Testing USGSMapToBitMap');
    bGood:=Test_USGSMapToBitMap;
    if not bGood then
    begin
      writeln('USGSMapToBitMap Failed.');
    end;
  end;

  writeln;
  Writeln('Both the sample data and the output are in .'+DOSSLASH+'data'+DOSSLASH);
  Writeln('This test program, like many of the others, is intended to be run');
  writeln('inside the API folder, then the test programs can find the data');
  writeln('sudirectory.');
  writeln;
  if bGood then
  begin
    Writeln('All the Tests Passed!');
  end;
//=============================================================================
end.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************

