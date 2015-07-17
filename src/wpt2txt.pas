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
// Converts Old Wordprocessor *.WPT files into usable Text
program wpt2txt;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='wpt2txt.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
Uses
//=============================================================================
   ug_common
  ,ug_jegas
  ,ug_jfc_dir
  ,dos
  ;
//=============================================================================

//=============================================================================
var
//=============================================================================
  Dir: JFC_DIR;
  iConverted: longint;
//=============================================================================

//=============================================================================
procedure JegasLogoWPT2TXT;
//=============================================================================
begin
  Writeln('     _________ _______  _______  ______  _______');
  Writeln('    /___  ___// _____/ / _____/ / __  / / _____/');
  Writeln('       / /   / /__    / / ___  / /_/ / / /____  ');
  Writeln('      / /   / ____/  / / /  / / __  / /____  /  ');
  Writeln(' ____/ /   / /___   / /__/ / / / / / _____/ /   ');
  Writeln('/_____/   /______/ /______/ /_/ /_/ /______/    ');
  Writeln('             Virtually Everything IT            ');
end;
//=============================================================================



//=============================================================================
Procedure ConvertWPT2TXT(p_saPath, p_saFilename: Ansistring);
//=============================================================================
var
  fin: text;
  fout: text;
  saFileOut: ansistring;
  saDir, saName, saExt: string;

  ch: char;
  ix: longint;

begin
  fsplit(p_saPath + p_saFilename, saDir, saName, saExt);
  saFileOut:=p_saPath+saName+'.txt';

  assign(fin, p_saPath + p_saFilename);
  reset(fin);

  assign(fout,saFileOut);
  rewrite(fout);

  ix:=0;
  while (not eof(fin)) and (ix<=37) do
  begin
    read(fin,ch);
    ix:=ix+1;
  end;

  while (not eof(fin)) do
  begin
    read(fin,ch);
    case ch of
    #00: write(fout,' ');
    #02: writeln(fout);
    #219: write(fout, ' ');
    else write(fout,ch);
    end;//switch
  end;
  close(fin);
  close(fout);
end;
//=============================================================================










//=============================================================================
Begin
//=============================================================================
  DIR:=JFC_DIR.create;
  DIR.bDirOnly:=false;
  DIR.saFileSpec:='*.WPT';
  DIR.bSort:=true;
  DIR.bSortAscending:=true;
  DIR.bSortCaseSensitive:=false;
  DIR.LoadDir;
  iConverted:=0;
  if (DIR.MoveFirst) then
  begin
    repeat
      if(DIR.Item_bDir=false)then
      begin
        ConvertWPT2TXT(DIR.saPath,DIR.Item_saName);
        iConverted:=iConverted+1;
      end;
    until NOT DIR.MoveNext;
  end
  else
  begin
    writeln('No Files to convert in: '+DIR.saPAth);
  end;
  DIR.Destroy;
  if(iConverted=0)then
  begin
    writeln('ZERO *.WPT FILES FOUND');
  end
  else
  begin
    writeln('Converted ',iConverted, ' files from *.WPT to *.TXT');
  end;
  JegasLogoWPT2TXT;

//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
