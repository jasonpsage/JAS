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
{}
// Program to test Synapse PING
program testping;
//=============================================================================

//=============================================================================
// GLOBAL DIRECTIVES
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$MODE DELPHI}
//=============================================================================

//=============================================================================
uses
//=============================================================================
 pingsend,
 sysutils;
//=============================================================================

//=============================================================================
var
//=============================================================================
  ping:TPingSend;
//=============================================================================

//=============================================================================
begin
//=============================================================================
  ping:=TPingSend.Create;
  try
    ping.ping(ParamStr(1));
    Writeln (IntTostr(ping.pingtime));  
  finally
    ping.Free;
  end;
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
