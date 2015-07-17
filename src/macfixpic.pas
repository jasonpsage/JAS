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
// Replace picture file names in AC4 Files (Awning Composer)
program macfixpic;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='macfixpic.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
Uses 
//=============================================================================
  ug_common,
  ug_jegas,
  ug_misc,
  ug_jfc_dir,
  ug_jfc_tokenizer,
  sysutils;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************


var 
  gsaOldPath: ansistring;
  gsaNewPath: ansistring;



//=============================================================================
function bProcessAC4(p_saFileName: ansistring): boolean;
//=============================================================================
var 
  bOk: boolean;
  saIn: ansistring;
  sa: ansistring;
  u2IOResult: word;
  TK: JFC_TOKENIZER;
  saOut: ansistring;
  bGotHandle: boolean;
begin
  saOut:='';
  TK:=JFC_TOKENIZER.Create;
  bOk:=bLoadTextFile(p_safilename, saIn, u2IoResult);
  if(length(saIn)=0) then
  begin
    writeln('no data loaded');
    halt(2);
  end;
  
  
  if bOk then
  begin
    TK.SetDefaults;
    TK.saSeparators:=#13#10;
    TK.saWhiteSpace:=#10;
    TK.bKeepDebugInfo:=true;
    sa:=saIn;
    TK.Tokenize(sa);
    TK.DumpToTextFile('tk.macfixpic.txt');  
    if TK.MoveFirst then
    begin
      repeat
        if UpCase(saGetStringBeforeEqualSign(TK.Item_saToken))='BACKDROPFILENAME' then
        begin
          saOut+='BackdropFilename='+saSNRStr(saGetStringAfterEqualSign(TK.Item_saToken),gsaOldPath,gsaNewPath);
        end
        else
        begin
          if TK.Item_saToken=#13 then
          begin
            saOut+=csCRLF;
          end
          else
          begin
            saOut+=TK.Item_saToken;
          end;
        end;
      until not tk.movenext;
    end;
  end;
  if trim(saOut)='' then saOut:=saIn;

  if(length(saOut)=0) and (length(saIn)>0)then
  begin
    writeln('macfixpic - 201008051908 - no data - internal error - stopping to prevent damage.');
    halt(2);
  end;
  
  if bOk then
  begin
    bOk:=bSaveFile(p_saFilename,saOut,10,1,u2IOResult,false);
  end;
  

  
  
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
procedure fixpic;
//=============================================================================
var 
  d: JFC_DIR;
  iSucceeded: integer;
  iFailed: integer;
  iSkipped: integer;
begin
  iSucceeded:=0;
  iFailed:=0;
  iSkipped:=0;
  
  d:=JFC_DIR.Create;
  d.saPath:='.';
  d.bDirOnly:=false;
  d.saFileSpec:='*.ac4';
  d.loaddir;
  
  if d.MoveFirst then
  begin
    writeln(saJegasLogoRawText(csCRLF));
    repeat
      write(d.n,' of ',d.listcount,' ');
      if (not d.Item_bHidden) and (not d.Item_bDir) then
      begin
        write('Processing: '+JFC_DIRENTRY(d.Item_lpPtr).saName,' ');
        if bProcessAC4(JFC_DIRENTRY(d.Item_lpPtr).saName) then
        begin
          write('Success!');
          iSucceeded+=1;
        end
        else
        begin
          Write('Failed!');
          iFailed+=1;
        end;
        //write(JFC_DIRENTRY(d.Item_lpPtr).u1Attr,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).i4Time,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).i4Size,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).u2Reserved ,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).saSearchSpec,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).u2NamePos,#9);
        //write(JFC_DIRENTRY(d.Item_lpPtr).saName,#9);
      end
      else
      begin
        write('Not AC4 - Skipping.');
        iSkipped+=1;
      end;
      writeln;
    until not d.movenext;
    writeln('Succeeded: ',iSucceeded);
    writeln('Failed   : ',iFailed);
    writeln('Skipped  : ',iSkipped);
    writeln('Done.');
  end;  
  d.destroy;  
end;
//=============================================================================



//=============================================================================
// Main
//=============================================================================
begin
  if paramcount<2 then
  begin
    writeln('Usage: macfixpic OLDPICTUREPATH NEWPICTUREPATH');
  end
  else
  begin
    gsaOldPath:=ParamStr(1);
    if saRightStr(gsaOldPath,1)<>csDOSSLASH then gsaOldPath+=csDOSSLASH;
    
    gsaNewPath:=ParamStr(2);
    if saRightStr(gsaNewPath,1)<>csDOSSLASH then gsaNewPath+=csDOSSLASH;
    
    writeln('gsaOldPath: ',gsaOldPath);
    writeln('gsaNewPath: ',gsaNewPath);

    FixPic;  
  end;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
