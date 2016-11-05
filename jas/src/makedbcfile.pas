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
{}
//proverbial test app :) No Copyleft'n lol :)
program test;
//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

uses
  ug_jegas,
  ug_jado;

var 
  DBC: JADO_CONNECTION;
begin
  DBC:=JADO_CONNECTION.Create;
  DBC.sName:='JAS';
  DBC.saDesc:='JAS Squadron Leader, Lead Jet, Master Database';
  grJegasCommon.sAppTitle:='Jegas, LLC';
  grJegasCommon.sAppEXEName:='jas';
  grJegasCommon.saAppPath:='.';
  grJegasCommon.sAppProductName:='Jegas Application Server';
  grJegasCommon.sVersion:='2016-08-10';
  if DBC.bSave('jas.dbc',true) then writeln('Saved Ok') else writeln('Error Saving');
  DBC.Destroy;
end.
