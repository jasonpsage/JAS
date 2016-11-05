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
// A system independant way for applications using this unit to share/lock
// files. This is NOT an OS file sharing implementation. So the locking
// mechanism this unit offers is only effective when all applications trying
// to access a file protected by this unit either also implment this unit or
// follow the same locking mechanism rules.
// NOTE: This unit is not Threadsafe!
unit ug_fileshare;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_fileshare.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================






//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************



//=============================================================================
uses 
//=============================================================================
  sysutils,
  ug_jegas,
  ug_common,
  ug_jfc_ini,
  ug_jfc_xdl;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{}
// Initialize the Unit - must be done prior to calling other routines in the 
// unit.
procedure InitFileShare;
//=============================================================================
{}
// Pass filename in p_sa to add a share to. It will fail if the file is locked.
// This is for read only access.
function bShareFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
): boolean;
//=============================================================================
{}
// Pass filename in p_sa to LOCK Exclusively. It will fail if the file is 
// being shared. This is so you can take ownership so you can modify the file.
function bLockFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
): boolean;
//=============================================================================
{}
// Lock/share will be removed.
procedure ReleaseFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
);
//=============================================================================
// This will remove ALL locks/shares you have opened during life of program.
{}
procedure DoneFileShare;
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              implementation
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
const
//=============================================================================
  cn_MAX_RETRIES_SEC = 5;
//=============================================================================

//=============================================================================
var
//=============================================================================
  gsaSection: AnsiString;
  gXDL: JFC_XDL;
  gINI: JFC_INI;
  gfTrueLock: text;
//=============================================================================

//=============================================================================
function saLockName(p_saFileNPath, p_saLockPAth: AnsiString): AnsiString;
//=============================================================================
Begin
  p_saFileNPath:=saSNR(p_saFileNPath,DOSSLASH,'_');
  result:=saAddSlash(p_saLockPath)+p_safilenpath;
  if leftstr(result,2)='./' then result:=RightStr(result,length(result)-2);
End;
//=============================================================================

//=============================================================================
function TRUELOCK(p_saFileNPath, p_saLockPAth: AnsiString):boolean;
//=============================================================================
var 
  u2IOResult: word;
  iNowMSec: integer;
  iStartMSec: integer;
  safile: ansistring;
Begin
  Write('BEGIN TRUELOCK');
  result:=false;
  saFile:=saLockname(p_saFileNPath, p_saLockPath)+'.lock.tmp';
  Writeln(' LockFile: '+saFile);
  assign(gfTrueLock,saFile);
  {$I-}
  //iRetries:=0;
  iStartMSec:=iMSec(now);
  repeat
    try rewrite(gfTrueLock); except on E:Exception do u2IOResult:=60000; end;//try
    u2IOREsult+=ioresult;
    //iRetries+=1;
    if u2ioresult<>0 then
    Begin
      iNowMSec:=iMSec;
      if iNowMSec<iStartMSec then
      Begin
        // Deal with midnight thing - reset it
        iStartMSec:=0;
      End;
    End;
  until (u2IOResult=0) or ((iNowMsec-iStartMSec)>=(cn_MAX_RETRIES_SEC*1000));
  {$I+}
  if u2IOResult=0 then try Writeln(gfTrueLock,'Go Ahead'); except on E:Exception do u2IOResult:=60000; end;//try
  u2IOREsult+=ioresult;
  if u2IOResult=0 then try Writeln(gfTruelock,'Delete Me');  except on E:Exception do u2IOResult:=60000; end;//try
  u2IOREsult+=ioresult;
  result:=u2IOREsult=0;
  Writeln('END TRUELOCK ',sYesNo(result));
End;
//=============================================================================




//=============================================================================
procedure TRUEUNLOCK(p_saFileNPAth, p_saLockPAth: AnsiString);
//=============================================================================
Begin
  try close(gfTrueLock); except on E:EXception do;end;//try
  try deletefile(saLockname(p_saFileNPath, p_saLockPath)+'.lock.tmp');except on E:EXception do;end;//try
End;
//=============================================================================




//=============================================================================
function AddLock( p_saFileNPath, p_saLockPath: AnsiString; p_bExclusive: boolean):boolean;
//=============================================================================
var 
  sa: AnsiString;
  iNowMSec: integer;
  iStartMSec: integer;
  bA,bB,bC: boolean;
Begin
  iStartMSec:=iMSec;
  repeat 
    result:=false;
    writeln('AddLock Entered');
    if TRUELOCK(p_saFileNPath, p_saLockPath) then
    Begin
      writeln('AddLock-TrueLock Worked.');
      gXDL.AppendItem_saName_N_saDesc(p_saFileNPath, p_saLockPath);
      gINI.DeleteAll;
      gINI.LoadINIFile(saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock');
      
      bA:=(not gINI.ReadKey('[LOCKED]','program=',sa));
      if not bA then
      begin
        writeln('AddLock-Fail-ReadKey [LOCKED]');
      end;

      if bA then
      begin
        bA:=(not gINI.ReadKey(gsaSection, 'program=',sa));
      end;


      if bA then
      Begin
        if p_bExclusive then
        Begin
           bA:=gINI.ListCount=0;
             if not bA then writeln('FAIL: bA gINI.ListCount<>0');
           bB:=gINI.WriteKey('[LOCKED]','program=',paramstr(0));
             if not bB then writeln('FAIL: gINI.WriteKey');
           bC:=gINI.SaveINIFile(saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock');
             if not bC then writeln('FAIL: Save INI File');
           result:=bA and bB and bC;
        End
        else
        Begin
          result:=gINI.WriteKey(gsaSection, 'program=',paramstr(0));
          if result then
          begin
            result:=gINI.SaveINIFile(saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock');
            if not result then
            begin
              writeln('FAIL: gINI.SaveINIFile :(');
            end;
          end
          else
          begin
            writeln('FAIL: gINI.WriteKey gsaSection: '+gsaSection);
          end;
        End;
      End;  
      TRUEUNLOCK(p_saFileNPath, p_saLockPath);
      if not result then gXDL.Deleteitem;
    End
    Else
    begin
      writeln('AddLock - TRUELOCK Failed. p_saFileNPAth: ',p_saFileNPAth,
        ' p_saLockPath: ', p_saLockPath);
    end;
    if not result then
    Begin
      iNowMSec:=iMSec;
      if iNowMSec<iStartMSec then
      Begin
        // Deal with midnight thing - reset it
        iStartMSec:=0;
      End;
    End;
  until result or ((iNowMsec-iStartMSec)>=(cn_MAX_RETRIES_SEC*1000));  
  if not result then
  begin
    Writeln('addlock fail: inowmsec:',inowmsec,' istartmsec:',istartmsec,
            ' now-start=',iNowMsec-iStartMSec);
  end;
End;
//=============================================================================





//=============================================================================
procedure DeleteLock;
//=============================================================================
Begin
  Writeln('DeleteLock In:'+gXDL.Item_saName);
  if TRUELOCK(gXDL.Item_saName, gXDL.Item_saDesc) then Begin
    gINI.DeleteAll;
    if gINI.LoadINIFile(
      saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock') then Begin
      gINI.DeleteSection('[LOCKED]');
      gINI.DeleteSection(gsaSection);
      if gINI.ListCount>0 then Begin
        gINI.SaveINIFile(saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock');
      End else Begin
        DeleteFile(saLockNAme(gXDL.Item_saName, gXDL.Item_saDesc)+'.lock');
      End;
    End;
    TRUEUNLOCK(gXDL.Item_saName, gXDL.Item_saDesc);
  End; // Else problem - but making unit "quiet"
  Writeln('DeleteLock Out');
End;
//=============================================================================


//=============================================================================
procedure InitFileShare;
//=============================================================================
var 
  dtNow: TDATETIME;
  saLeftSection: AnsiString; // DATE String yyyymmdd
  saRightSection: AnsiString;// '-'+ millisecs since midnight
Begin
  dtNow:=now;
  DateTimeToString(saLeftSection, csDATETIMEFORMAT, dtNOW);
  saRightSection:='-'+inttostr(iMSec(dtNow));
  gsaSection:='['+saLeftSection+saRightSection+']';
  gXDL:=JFC_XDL.create;
  gINI:=JFC_INI.create;
End;
//=============================================================================

//=============================================================================
procedure DoneFileShare;
//=============================================================================
Begin
  writeln('Begin DoneFileShare');
  if gXDL.ListCount>0 then Begin
    gXDL.MoveFirst;
    repeat
      DeleteLock; // BAsed on current gXDL's info
    until not gXDL.MoveNext;
  End;
  gXDL.Destroy;
  gINI.Destroy;
  writeln('End DoneFileShare');
End;
//=============================================================================


//=============================================================================
function bShareFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
): boolean;
//=============================================================================
Begin
  writeln('Begin - bShareFile');
  result:=false;
  if not gXDL.FoundItem_saName_N_saDesc(p_saFileNPAth, false,
                                        p_saLockPAth, false) then
  Begin
    result := addlock(p_saFileNPAth, p_saLockPAth, false);
  End;
  writeln('End - bShareFile Success: ',sYesNo(result));
End;
//=============================================================================


//=============================================================================
function bLockFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
): boolean;
//=============================================================================
Begin
  writeln('Begin - bLockFile');
  result:=false;
  if not gXDL.FoundItem_saName_N_saDesc(p_saFileNPAth, false,
                                        p_saLockPAth, false) then
  Begin
    result := addlock(p_saFileNPAth, p_saLockPAth, true);
  End;
  writeln('End - bLockFile Success: ',sYesNo(result));
End;
//=============================================================================

//=============================================================================
procedure ReleaseFile(
  p_saFileNPath: AnsiString;
  p_saLockPath: AnsiString
);
//=============================================================================
Begin
  writeln('Begin - ReleaseFile');
  if gXDL.FoundItem_saName_N_saDesc(p_saFileNPAth, false,
                                    p_saLockPAth, false) then
  Begin
    Writeln('Trying to release Lock:'+p_saFileNPAth);
    DeleteLock;
  End;
  writeln('End - ReleaseFile');
End;
//=============================================================================






//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
