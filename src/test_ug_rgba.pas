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
// Test Jegas' uxxg_rgba unit
program test_ug_rgba;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  ug_rgba;
//=============================================================================

//=============================================================================
var
//=============================================================================
  RGBA: TRGBA;
  bOk: boolean;
//=============================================================================

//=============================================================================
begin
//=============================================================================
  RGBA:=nil;bOk:=true;

  if bOk then
  begin
    RGBA:=TRGBA.Create;
    bOk:= (RGBA.RGBA.Blue=0) and (RGBA.RGBA.Green=0) and (RGBA.RGBA.Red=0) and (RGBA.RGBA.Alpha=0);
    if not bOk then
    begin
      writeln('RGBA.Create Failed!');
    end;
    RGBA.Destroy;
    RGBA:=nil;
  end;

  if bOk then
  begin
    RGBA:=TRGBA.Create($FFFFFFFF);
    bOk:= (RGBA.RGBA.Blue=$FF) and (RGBA.RGBA.Green=$FF) and (RGBA.RGBA.Red=$FF) and (RGBA.RGBA.Alpha=$FF);
    if not bOk then
    begin
      writeln('RGBA.Create(cardinal) Failed!');
    end;
    RGBA.Destroy;
    RGBA:=nil;
  end;

  if bOk then
  begin
    RGBA:=TRGBA.Create(1,2,3,4);
    bOk:= (RGBA.RGBA.Blue=3) and (RGBA.RGBA.Green=2) and (RGBA.RGBA.Red=1) and (RGBA.RGBA.Alpha=4);
    if not bOk then
    begin
      writeln('RGBA.Create(r,g,b,a) Failed!');
    end;
    RGBA.Destroy;
    RGBA:=nil;
  end;

  if bOk then
  begin
    RGBA:=TRGBA.Create(1,2,3);
    bOk:= (RGBA.RGBA.Blue=3) and (RGBA.RGBA.Green=2) and (RGBA.RGBA.Red=1) and (RGBA.RGBA.Alpha=255);
    if not bOk then
    begin
      writeln('RGBA.Create(r,g,b) Failed!');
    end;
    RGBA.Destroy;
    RGBA:=nil;
  end;

  if bOk then
  begin
    RGBA:=TRGBA.Create;

    RGBA.Red_Set(10);
    bOk:=RGBA.RGBA.Red=10;
    if not bOk then
    begin
      writeln('RGBA.Red_Set Failed!');
    end;

    if bOk then
    begin
      RGBA.Green_Set(20);
      bOk:=RGBA.RGBA.Green=20;
      if not bOk then
      begin
        writeln('RGBA.Green_Set Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.Blue_Set(30);
      bOk:=RGBA.RGBA.Blue=30;
      if not bOk then
      begin
        writeln('RGBA.Blue_Set Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.Alpha_Set(40);
      bOk:=RGBA.RGBA.Alpha=40;
      if not bOk then
      begin
        writeln('RGBA.Alpha_Set Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.RGB_Set(1,2,3);
      bOk:= (RGBA.RGBA.Blue=3) and (RGBA.RGBA.Green=2) and (RGBA.RGBA.Red=1) and (RGBA.RGBA.Alpha=40);
      if not bOk then
      begin
        writeln('RGBA.RGB_Set(r,g,b) Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.Alpha_Set(0);
      RGBA.RGB_Set($FFFFFFFF);
      bOk:= (RGBA.RGBA.Blue=$FF) and (RGBA.RGBA.Green=$FF) and (RGBA.RGBA.Red=$FF) and (RGBA.RGBA.Alpha=$00);
      if not bOk then
      begin
        writeln('RGBA.RGB_Set(p_RGB: cardinal) Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.RGBA_Set(1,2,3,4);
      bOk:= (RGBA.RGBA.Blue=3) and (RGBA.RGBA.Green=2) and (RGBA.RGBA.Red=1) and (RGBA.RGBA.Alpha=4);
      if not bOk then
      begin
        writeln('RGBA.RGB_Set(r,g,b,a) Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.Alpha_Set(0);
      RGBA.RGBA_Set($FFFFFFFF);
      bOk:= (RGBA.RGBA.Blue=$FF) and (RGBA.RGBA.Green=$FF) and (RGBA.RGBA.Red=$FF) and (RGBA.RGBA.Alpha=$FF);
      if not bOk then
      begin
        writeln('RGBA.RGBA_Set(p_RGBA: cardinal) Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.RGBA_Set($4F3F2F1F);
      bOk:=RGBA.Red_Get=$3F;
      if not bOk then
      begin
        writeln('RGBA.Red_Get Failed!');
      end;
    end;

    if bOk then
    begin
      bOk:=RGBA.Green_Get=$2F;
      if not bOk then
      begin
        writeln('RGBA.Green_Get Failed!');
      end;
    end;

    if bOk then
    begin
      bOk:=RGBA.Blue_Get=$1F;
      if not bOk then
      begin
        writeln('RGBA.Blue_Get Failed!');
      end;
    end;

    if bOk then
    begin
      bOk:=RGBA.Alpha_Get=$4F;
      if not bOk then
      begin
        writeln('RGBA.Alpha_Get Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.RGBA_Set($FFFFFFFF);
      bOk:=RGBA.RGB_Get=$00FFFFFF;
      if not bOk then
      begin
        writeln('RGBA.RGB_Get Failed!');
      end;
    end;

    if bOk then
    begin
      RGBA.RGBA_Set($11111111);
      bOk:=RGBA.RGBA_Get=$11111111;
      if not bOk then
      begin
        writeln('RGBA.RGBA_Get Failed!');
      end;
    end;

    RGBA.Destroy; RGBA:=nil;
  end;


  if bOk then writeln('All RGBA Tests PASSED! Yay!');

//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

