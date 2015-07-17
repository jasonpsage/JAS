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
// Test FReepascal Standard in and standard out functionality
program teststdinout;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
//=============================================================================


//=============================================================================
uses
//=============================================================================
 Classes,
 SysUtils;
//=============================================================================

//=============================================================================
var
//=============================================================================
 st: text;
 ch: char;
 c: integer;
//=============================================================================

//=============================================================================
begin
//=============================================================================
 assign(st,'');
 reset(st);
 c:=0;
 while c<5 do begin // <<<<<<<<--- iterate while not en of file
   read(st,ch); //<<< read only a line
   write('[',ch,']');
   c+=1;
 end;
 close(st); // <<<<<---
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

