{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{ }
// Test Jegas' Vector Classes
program test_ug_xyz;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
//=============================================================================


//=============================================================================
uses
//=============================================================================
  ug_jegas,
  ug_xyz;
//=============================================================================


//=============================================================================
var
//=============================================================================
  xyint: txyint;
  xyfloat: txyfloat;
  xyzint: txyzint;
  xyzfloat: txyzfloat;
  xyzwint: txyzwint;
  xyzwfloat: txyzwfloat;
  bOk: boolean;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  bOk:=true;

  if bOk Then
  begin
    xyint:= txyint.create(1,2);
    bOk:=(xyint.x=1) and (xyint.y=2);
    if not bOk then
    begin
      writeln('TXYINT FAILED!');
    end;
    xyint.destroy;
  end;

  if bOk Then
  begin
    xyfloat:= txyfloat.create(0.5,1.5);
    bOk:=(xyfloat.x>0.4) and (xyfloat.x<0.6) and
         (xyfloat.y>1.4) and (xyfloat.y<1.6);
    if not bOk then
    begin
      writeln('TXYINT FAILED!');
    end;
    xyfloat.destroy;
  end;

  if bOk Then
  begin
    xyzint:= txyzint.create(1,2,3);
    bOk:=(xyzint.x=1) and (xyzint.y=2) and (xyzint.z=3);
    if not bOk then
    begin
      writeln('TXYINT FAILED!');
    end;
    xyzint.destroy;
  end;

  if bOk Then
  begin
    xyzfloat:= txyzfloat.create(0.5,1.5,2.0);
    bOk:=(xyzfloat.x>0.4) and (xyzfloat.x<0.6) and
         (xyzfloat.y>1.4) and (xyzfloat.y<1.6) and
         (xyzfloat.z>1.9) and (xyzfloat.z<2.1);
    if not bOk then
    begin
      writeln('TXYINT FAILED!');
    end;
    xyzfloat.destroy;
  end;

  if bOk Then
  begin
    xyzwint:= txyzwint.create(1,2,3,4);
    bOk:=(xyzwint.x=1) and (xyzwint.y=2) and
         (xyzwint.z=3) and (xyzwint.w=4);
    if not bOk then
    begin
      writeln('TXYINT FAILED!');
    end;
    xyzwint.destroy;
  end;

  if bOk Then
  begin
    xyzwfloat:= txyzwfloat.create(0.5,1.5,2.0,2.5);
    bOk:=(xyzwfloat.x>0.4) and (xyzwfloat.x<0.6) and
         (xyzwfloat.y>1.4) and (xyzwfloat.y<1.6) and
         (xyzwfloat.z>1.9) and (xyzwfloat.z<2.1) and
         (xyzwfloat.w>2.4) and (xyzwfloat.w<2.6);
    if not bOk then
    begin
      writeln('TXYZWFLOAT FAILED!');
    end;
    xyzwfloat.destroy;
  end;

  if bOk then
  begin
    writeln('All xyz tests PASSED! Yay!');
  end;
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

