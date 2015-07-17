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
  ug_common,
  ug_jegas;


var
  bOk: boolean;
  saSrc: ansistring;
  saDest: ansistring;
  u2Result: word;
begin
  writeln(JDATE('20/2005/03 01:20 PM',1,22));
    
  
end.
