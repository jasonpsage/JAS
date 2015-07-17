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
// A File Splitter Program
program text_file_splitter;
//=============================================================================

//=============================================================================
// GLOBAL DIRECTIVES
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
//=============================================================================




//=============================================================================
uses
//=============================================================================
  sysutils,
  ug_common,
  ug_jegas;
//=============================================================================

//=============================================================================
var
//=============================================================================
  bOk: boolean;
  safileSought: ansistring;
  saFileSoughtExt: ansistring;
  saFileSoughtNoExt: ansistring;

  saSourcefile: ansistring;
  saDestFile: ansistring;
  saDestFileExt: ansistring;
  
  t: text;
  o: text;
  u2IOresult: word;
  
  i4LineCount: longint;
  i4FileCount: longint;
  i4TotalLineCount: longint;
  
  
  saLineIn: ansistring;
//=============================================================================


//=============================================================================
begin
//=============================================================================
  i4LineCount:=0;
  i4FileCount:=0;
  i4TotalLineCount:=0;

  bOk:=paramcount>=2;
  if not bOk then
  begin
    writeln('usage: textfilesplitter [srcfilename] [outfilename]');
  end;

  if bOk then
  begin
    saSourceFile:=paramstr(1);
  
    saFileSought:=paramstr(2);
    saFileSoughtNoExt:=LowerCase(saFileNameNoExt(saFileSought));
    saFileSoughtExt:=LowerCase(ExtractFileExt(saFileSought));
    saFileSoughtExt:=RightStr(saFileSoughtExt,length(saFileSoughtExt));
    
    saDestFile:=saFileSoughtNoExt;
    saDestFileExt:=saFileSoughtExt;
    writeln('Source Filename:'+saSourceFile);
    writeln('Dest File:'+saDestFile+' Dest FileExt:'+saDestFileExt);
  end;
  
  if bOk then
  begin
    bOk:=FileExists(saSourcefile);
    if not bOk then
    begin
      Writeln('Source file doesn''t exist or permissions prevent access: ',saSourcefile);
    end;
  end;
  
  if bOk then
  begin
    {$I-}
    assign(t,saSourcefile);
    u2IOResult:=IOResult;
    {$I+}
    bOk:= (u2IOResult=0);
    if not bOk then
    begin
      writeln('Assigning File Error:'+saIOResult(u2IOResult));
    end;
  end;  
  
  if bOk then
  begin
    {$I-}
    reset(t);
    u2IOResult:=IOResult;
    {$I+}
    bOk:= (u2IOResult=0);
    if not bOk then
    begin
      writeln('Resetting File Error:'+saIOResult(u2IOResult));
    end;
  end;
  
  if bOk then
  begin
    repeat
      readln(t,saLineIn);
      i4LineCount+=1;
      i4TotalLineCount+=1;
      if i4LineCount=1 then
      begin
        i4FileCount+=1;
        if bOk then
        begin
          {$I-}
          assign(o,saDestfile+saZeroPadInt(i4FileCount,4)+saDestFileExt);
          u2IOResult:=IOResult;
          {$I+}
          bOk:= (u2IOResult=0);
          if not bOk then
          begin
            writeln('Assigning Output File Error:'+saIOResult(u2IOResult));
          end;
        end;  
        
        if bOk then
        begin
          {$I-}
          rewrite(o);
          u2IOResult:=IOResult;
          {$I+}
          bOk:= (u2IOResult=0);
          if not bOk then
          begin
            writeln('Resetting Output File Error:'+saIOResult(u2IOResult));
          end;
        end;
      end;
      
      if bOk then
      begin
        writeln(o, saLineIn);
      end;
      
      if i4LineCount>100000 then 
      begin
        close(o);
        i4LineCount:=0;
      end;
      writeln(saLineIn);
    until eof(t) or (bOk=false);  
  end;
  
  if bOk then
  begin
    writeln('Total Lines Processed: ', i4TotalLineCount);
    close(t);
  end;

//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

