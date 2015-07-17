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
  DBC.saName:='JAS';
  DBC.saDesc:='JAS Squadron Leader, Lead Jet, Master Database';
  grJegasCommon.saAppTitle:='Jegas, LLC';
  grJegasCommon.saAppEXEName:='jas';
  grJegasCommon.saAppPath:='/xfiles/inet/jas/bin/';
  grJegasCommon.saAppProductName:='Jegas Application Server';
  grJegasCommon.saAppMajor:='0';
  grJegasCommon.saAppMinor:='0';
  grJegasCommon.saAppRevision:='1';
  if DBC.bSave('/xfiles/inet/jas/jegas/config/jas.dbc',true) then writeln('Saved Ok') else writeln('Error Saving');
  DBC.Destroy;
end.
