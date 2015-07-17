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
// Tests Jegas' USGS unit uxxg_usgs
program test_ug_usgs;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
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
begin
  result:=USGSMapConvert(
    4,
    'F:\files\Media\Gfx\Terrain\Satellite\SatelliteData\68248302\68248302',
    'testgridfloat'
  );
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
    'F:\files\Media\Gfx\Terrain\Satellite\SatelliteData\68248302\68248302',
    'testbitmap',
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
  result:=0=USGSMapToRaw16(
    'F:\files\Media\Gfx\Terrain\Satellite\SatelliteData\68248302\68248302',
    'testraw16.raw',
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

//=============================================================================
end.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************

