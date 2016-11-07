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
// simple zip utility
program jzip;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================


//=============================================================================
uses
//=============================================================================
  ug_jegas,
  ug_common,
  ug_jfc_dir,
  classes,
  sysutils,
  Zipper;
//=============================================================================

//=============================================================================
var   FileList:TStringList;  Zip: TZipper;
  MyDirectory: ansistring;

//=============================================================================


//=============================================================================
procedure loadthefilelist(p_saPath: ansistring);
//=============================================================================
var
  DIR: JFC_DIR;
  saCurrent: ansistring;
begin
  //riteln('ENTER---path: ',p_saPath);
  //eadln;
  Dir:= JFC_DIR.Create;
  with Dir do
  begin
    saPath:=p_saPath;
    bDirOnly:=false;
    saFileSpec:='*';
    bSort:=true;
    bSortAscending:=true;
    bSortCaseSensitive:=true;//faster
    //Procedure LoadDir;
    //Procedure PreviousDir;
    LoadDir;
  end;

  if DIR.movefirst then
  begin
    repeat
       if rightstr(p_saPath,1)<>DOSSLASH then p_saPAth+=DOSSLASH;
       //riteln('Path:'+p_saPath+' current item: '+DIR.Item_saName);
       saCurrent:=p_saPath+DIR.Item_saName;
       if DIR.Item_bDir then
       begin
         if (DIR.Item_saName<>'.') and (DIR.Item_saName<>'..') then
         begin
           //riteln(saRepeatChar('=',79));
           //riteln('DIR: ', DIR.Item_saName);
           //riteln('path: ', p_saPAth);
           //riteln('Current:' +saCurrent);
           //riteln(saRepeatChar('=',79));
           //eadln;
           loadtheFilelist(saCurrent);
         end;
       end
       else
       begin
         writeln(saCurrent);
         ZIP.Files.Add(saCurrent);
       end;
    until not Dir.movenext;
  end;
  DIR.Destroy;
end;
//=============================================================================




//=============================================================================
procedure main;
//=============================================================================
begin
  if paramcount=2 then
  begin
    MyDirectory:=paramstr(2);
    Zip := TZipper.Create;
    Zip.Filename := paramstr(1);
    fileList:=TStringList.create;
    try
      writeln('Loading File List...');
      LoadtheFileList(MyDirectory);
      writeln('Zipping...');
      Zip.ZipAllFiles;
    finally
      FileList.Free;
      Zip.Free;
    end;
  end
  else
  begin
    writeln('USAGE: jzip zipfilename.zip c:\directory\to\zip\');
    writeln('NOTE: jzip works recursively.');
  end;
end;

//=============================================================================
begin
  Main;
end.
//=============================================================================

//=============================================================================
// EOF ************************************************************************
//=============================================================================






