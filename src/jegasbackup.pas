{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2015 Jegas, LLC
==============================================================================}

//=============================================================================
// Jegas Backup
program jegasbackup;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='jegasbackup.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}


{DEFINE JEGASBACKUP_DONOTCOPY}
{$IFDEF JEGASBACKUP_DONOTCOPY}
  {$INFO WARNING - DIAG VERSION - JEGASBACKUP_DONOTCOPY Compiler directive SET! }
{$ENDIF}
{DEFINE DEBUG}
{$IFDEF DEBUG}
  {$INFO WARNING - Compiled in DEBUG mode! Lots of console output!}
{$ENDIF}
//=============================================================================



//=============================================================================
Uses 
//=============================================================================
sysutils
,ug_common
,ug_jegas
,ug_jfc_dir
,ug_misc
,dos
;

//=============================================================================


//=============================================================================
// !@!Declarations 
//=============================================================================
var
  saSrcDir: ansistring;
  saDestDir: ansistring;
  u8ErrID: int64;
  saErr: ansistring;
  bPruneMode: boolean;
//=============================================================================



  
//=============================================================================
procedure BUError(p_id: uint64; p_saErr:ansistring);
//=============================================================================
begin
  u8Errid:=p_id;
  saErr:=p_saErr;
end;
//=============================================================================




//=============================================================================
function bProcessCommandline: boolean;
//=============================================================================
var bok: boolean;
begin
  bOk:=true;
  if paramstr(1)='--help' then
  begin
    bOk:=false;
  end
  else

  if paramcount<>2 then
  begin
    bOk:=false;
    BUError(201502281250,'wrong number of parameters.');
  end;  
      
  if bok then
  begin
    if paramstr(1)='--prune' then
    begin
      saSrcDir:='';
      bPruneMode:=true;
    end
    else
    begin
      saSrcDir:=paramstr(1);
    end;
    saDestDir:=paramstr(2);
  end;  

 result:=bok;
end;
//=============================================================================





//=============================================================================
function bDiveIn(p_saSrcDir: ansistring; p_saDestDir: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  SrcDir:  JFC_DIR;
  DestDir: JFC_DIR;
  u2IOResult: word;
  saSrcFilename: ansistring;
  saDestFilename: ansistring;
  sa: ansistring;
  i: integer;
  bDestinationExists: boolean;
  u8srcfileage,u8destfileage: uint64;
  bSkip: boolean;
  i4Rev: longint;  

  dir:string;
  name: string;
  ext: string;


  
label tryagain;
begin
  SrcDir :=JFC_DIR.create;
  DestDir:=JFC_DIR.Create;
  i:=0;
  bOk:=true;

  //remove quotes if there
  if leftstr(p_saSrcDir,1)='"' then p_saSrcDir:=rightstr(p_saSrcDir,length(saSrcDir)-1);
  if rightstr(p_saSrcDir,1)='"' then p_saSrcDir:=leftstr(p_saSrcDir,length(saSrcDir)-1);
  if leftstr(p_saDestDir,1)='"' then p_saDestDir:=rightstr(p_saDestDir,length(saDestDir)-1);
  if rightstr(p_saDestDir,1)='"' then p_saDestDir:=leftstr(p_saDestDir,length(saDestDir)-1);
  if rightstr(p_saSrcDir,1)<>csDosslash then p_saSrcDir+=csDosslash;
  if rightstr(p_saDestDir,1)<>csDosslash then p_saDestDir+=csDosslash;

  
  
  
  with SrcDir do
  begin
    saPath:=p_saSrcDir;
    //riteln('Source Path:' + saPath);
    bDirOnly:=false;
    saFileSpec:='*';
    bSort:=true;
    bSortAscending:=false;
    bSortCaseSensitive:=true;//faster
    //Procedure LoadDir;
    //Procedure PreviousDir;
    LoadDir;
  end;
  
  with DestDir do
  begin
    saPath:=p_saDestDir;
    //riteln('Dest Path:' + saPath);
    bDirOnly:=false;
    saFileSpec:='*.jbu*';
    bSort:=true;
    bSortAscending:=false;
    bSortCaseSensitive:=true;//faster
    //Procedure LoadDir;
    //Procedure PreviousDir;
    LoadDir;
  end;

/////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////
//          SLEEP(500);
//////////////////////////////////////
///////////////////////////////////////
/////////////////////////////////////



  if not FileExists(p_sadestdir) then createdir(p_sadestdir);
  
  if SrcDir.movefirst {and srcdir.movenext} then  // pass the period for current directory.
  begin
    repeat
      //Property Item_saName: AnsiString read read_item_saName;
      //Property Item_bReadOnly: Boolean read read_item_bReadOnly;
      //Property Item_bHidden: Boolean   read read_item_bHidden;
      //Property Item_bSysFile: Boolean  read read_item_bSysFile;
      //Property Item_bVolumeID: Boolean read read_item_bVolumeID;
      //Property Item_bDir: Boolean      read read_item_bDir;
      //Property Item_bArchive: Boolean  read read_item_bArchive;
      if ((srcdir.Item_saName='.') or (srcdir.Item_saName='..') or (srcdir.Item_saName='')) then
      begin
	// skip it     
	{$IFDEF DEBUG}
	//riteln('skipping dir entry: '+srcdir.item_saname);
	{$ENDIF}
      end else

      if SrcDir.Item_bDir then
      begin
	      {$IFDEF DEBUG}
	      writeln('dive: src:'+p_sasrcDir+SrcDir.Item_saName+'  Dest: '+p_sadestdir+srcdir.item_saname);
	      {$ENDIF}
        sa:=trim(SrcDir.Item_saName);
        //recurse if first test passes
        bOk:=(pos(':',sa)=0) and bDiveIn(p_sasrcDir+SrcDir.Item_saName, p_sadestdir+srcdir.item_saname);
        if not bOk then
        begin
          writeln('201506250221: Directory Name Contains colon. May indicate access denied. src:'+p_sasrcDir+SrcDir.Item_saName+'  Dest: '+p_sadestdir+srcdir.item_saname);
        end;
      end
      else
      begin
	      saSrcFilename:=p_sasrcDir+SrcDir.Item_saName;
	      saDestFilename:=p_saDestDir+srcdir.Item_saName;
        u8SrcFileAge:=fileage(saSrcfilename);
        u8DestFileAge:=fileage(saDestfilename);
        bDestinationExists:=fileexists(saDestFilename);
	      {$IFDEF DEBUG}
	      //riteln('Dest File Exists: '+saYesNo(bDestinationExists)+' SrcAge:'+inttostr(u8SrcFileAge)+' DestAge: '+inttostr(u8DestFileAge)+' src:'+saSrcFilename+'  Dest: '+saDestFilename);
	      {$ENDIF}
        bSkip:=false;

tryagain:
	      u2ioresult:=0;
        if bDestinationExists and (u8SrcFileAge>u8DestFileAge) then
        //if bDestinationExists and ((u8SrcFileAge-u8DestFileAge)>1000) then
        begin
          //riteln('Destination does exist:'+saDestFilename);
          FSplit(saDestFilename,dir,name,ext);
       
          DestDir.saFilespec:=name+ext+'.jbu*';
          //riteln('filespec:'+DestDir.saFilespec);
          DestDir.loaddir;
          i:=1;
          if DestDir.MoveFirst then
          begin
            repeat
              i4Rev:= iVal(rightstr(destdir.item_saName,3));
              
              //riteln(inttostr(i4rev) +' <--i4rev');
              
              if i4Rev>=i then i:=i4rev+1;
            until not DestDir.MoveNext;
          end;
          //else
          //riteln('read directory FAILED to grab stuff');
          
          sa:=saDestFilename+'.jbu'+saZeroPadInt(i,3);
          //riteln('bmovefile('+'saDestFilename'+' , '+sa);
          bok:=bmovefile(saDestFilename, sa);
          if not bok then
          begin
            writeln('ERROR:201503021539: File Move Error: '+saIOResult(u2ioresult,cnLANG_ENGLISH)+
                ' Source: '+saDestFilename+' Destination: '+sa);
          end;
	      end
	      else
	      begin
	        bSkip:=bDestinationExists;
	        {IFDEF DEBUG}
	        //riteln('SKIPPING: '+saSrcfilename);
	        {ENDIF}
	      end;
	
        if bok and (not bSkip) then
        begin
          // Function bCopyFile(Var p_saSrc: AnsiString; Var p_saDest: AnsiString; Var p_u2IOREsult: Word):Boolean;
          sa:=p_saSrcDir+SrcDir.Item_saName;
          writeln(sa + ' --> ' + saDestFilename);
          //riteln('copy begin');

          {$IFNDEF JEGASBACKUP_DONOTCOPY}
          bOk:=bCopyFile(sa,saDestFilename,u2IOresult);
          {$ENDIF}
          if not bok then
          begin
            Writeln('201502281326: File Copy Error: '+saIOResult(u2ioresult,cnLANG_ENGLISH)+
              ' Source: '+sa+' Destination: '+sadestfilename);
          end;
        end; 
      end;
      if not bOK then
      begin
        writeln('ERROR: PROBLEM MOVING FILE ABOVE THIS MESSAGE!!!!');
      end;
      bOk:=true; /// forces backup to continue on error     
    until (not SrcDir.MoveNext);
  end;
  SrcDir.destroy;
  DestDir.destroy;  
  result:=bok; 
end;  
//=============================================================================






//=============================================================================
function BackItUp: boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=bDiveIn(saSrcDir,saDestDir);
  
  result:=bOk;
end;
//=============================================================================
































//=============================================================================
function bPruneit(p_saDestDir: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  DestDir: JFC_DIR;
  saDestFilename: ansistring;
  bDestinationExists: boolean;
begin
  DestDir:=JFC_DIR.Create;
  bOk:=true;
  
  //remove quotes if there
  if leftstr(p_saDestDir,1)='"' then p_saDestDir:=rightstr(p_saDestDir,length(saDestDir)-1);
  if rightstr(p_saDestDir,1)='"' then p_saDestDir:=leftstr(p_saDestDir,length(saDestDir)-1);
  if rightstr(p_saDestDir,1)<>csDosslash then p_saDestDir+=csDosslash;

  with DestDir do
  begin
    saPath:=p_saDestDir;
    bDirOnly:=false;
    saFileSpec:='*';
    bSort:=false;
    bSortAscending:=false;
    bSortCaseSensitive:=true;//faster
    //Procedure LoadDir;
    //Procedure PreviousDir;
    LoadDir;
  end;
  
  if destDir.movefirst {and srcdir.movenext} then  // pass the period for current directory.
  begin
    repeat
      //Property Item_saName: AnsiString read read_item_saName;
      //Property Item_bReadOnly: Boolean read read_item_bReadOnly;
      //Property Item_bHidden: Boolean   read read_item_bHidden;
      //Property Item_bSysFile: Boolean  read read_item_bSysFile;
      //Property Item_bVolumeID: Boolean read read_item_bVolumeID;
      //Property Item_bDir: Boolean      read read_item_bDir;
      //Property Item_bArchive: Boolean  read read_item_bArchive;
      if ((destdir.Item_saName='.') or (destdir.Item_saName='..') or (destdir.Item_saName='')) then
      begin
	// skip it     
	{$IFDEF DEBUG}
	writeln('pruneit: skipping dir entry: '+destdir.item_saname);
	{$ENDIF}
      end else

      if destDir.Item_bDir then
      begin
        
	{$IFDEF DEBUG}
	writeln('pruneit: Dest: '+p_sadestdir+destdir.item_saname);
	{$ENDIF}
        bOk:=bPruneIt(p_sadestdir+destdir.item_saname);//recurse
      end else
      
      
      begin
	if leftstr(rightstr(destdir.Item_saName,7),4)='.jbu' then
	begin
 	  saDestFilename:=p_saDestDir+destdir.Item_saName;
	  bDestinationExists:=fileexists(saDestFilename);
	  {$IFDEF DEBUG}
	  writeln('pruneit: Dest File Exists: '+saYesNo(bDestinationExists)+' Dest: '+saDestFilename);
	  {$ENDIF}
	
          if bDestinationExists then
          begin
	          writeln('pruning: '+saDestFilename);
            deletefile(saDestFilename);
          end;
        end;
      end;
    until (not DestDir.MoveNext);
  end
  else
  begin
    {$IFDEF DEBUG}
    writeln('pruneit: Directory completely empty.');
    {$ENDIF}
  end;
  DestDir.destroy;  
  result:=bok; 
end;  
//=============================================================================












//=============================================================================
function PruneItBaby: boolean;
//=============================================================================
var bOk: boolean;
begin
  writeln('Pruning versioned files.');
  bOk:=bPruneIt(saDestDir);
  result:=bOk;
end;
//=============================================================================



//=============================================================================
// Program Starts Here
//=============================================================================
var bAllGood: boolean;
Begin
 with grJegasCommon do begin
    saAppTitle:='Jegas Backup';//<application title
    saAppProductName:='Jegas Backup';
    saAppMajor:='1';
    saAppMinor:='2';
    saAppRevision:='0';
    writeln(saApptitle+' '+saAppMajor+'.'+saAppMinor+'.'+saApprevision);
  end;//with

  
  bAllGood:=bprocesscommandline;
  if bAllGood then
  begin
    if not bPruneMode then
    begin
      // perform the back up because commandline looks good but
      // the parameters might not be valid and they might have quotes to deal
      // with potentential spaces in the directory names.
      // lets call our, likely to be huge, main procedure.
      bAllGood:=Backitup;
    end
    else
    begin
      bAllGood:=PruneItBaby;
    end;
  end;
  
  if not ballgood then 
  begin
    if not (paramstr(1)='--help') then
    begin
      writeln('Error: '+inttostr(u8errid)+' '+saErr);
      writeln('Try: jegasbackup --help');
    end
    else
    begin
      writeln('Usage: jegasbackup [source directory] [destination directory]');
      writeln;
      writeln('To Prune a backup directory recursively of versions.');
      writeln('Usage: jegasbackup --prune [destination directory]');
      writeln;
      writeln('Note: Files matching this filename wildcard will be removed: *.jbu*');
      writeln;
      writeln(grJegasCommon.saAppProductName+' Version: '+grJegasCommon.saAppmajor+'.'+grJegasCommon.saappminor+'.'+grJegasCommon.saapprevision);
      writeln('By: Jason Peter Sage - Jegas, LLC - Jegas.com');
    end;
  end;
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
