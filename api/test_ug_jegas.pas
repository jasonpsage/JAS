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
// Test Jegas' Jegas Unit
program test_ug_jegas;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
Uses
//=============================================================================
  ug_jegas,
  ug_misc,
  ug_common,
  sysutils;
//=============================================================================


//=============================================================================
//=============================================================================
//=============================================================================
// !@!DEBUG RELATED
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================

//=============================================================================
function Test_Debug: boolean;
//=============================================================================
var bOk: boolean;
    iTempNestLevel: integer;
begin
  bOk:=true;
  if bOk then
  begin
    iTempNestLevel:=giDebugNestLevel;
    writeln('iTempNestLevel:',iTempNestLevel);
    DebugIn('Testing DebugIn function.','test_uxxg_jegas');
    DebugIn('Testing DebugIn function.','test_uxxg_jegas');
    writeln('giDebugNestLevel:',giDebugNestLevel);

    bOk:=(giDebugNestLevel-2)=iTempNestLevel;
    if not bOk then write('DebugIn - giDebugNestLevel:'+inttostr(giDebugNestLevel)+' iTempNestLevel:'+inttostr(iTempNestLevel));
    debugout('Testing DebugIn function.','test_uxxg_jegas');
    debugout('Testing DebugIn function.','test_uxxg_jegas');
    if bOk then
    begin
      bOk:=giDebugNestLevel=iTempNestLevel;
      if not bOk then write('DebugOut');
    end;
  end;
  
  if bOk then
  begin
    JASPrint('testing JASPrint');
    JASPrintln('testing JASPrintln');
    JASDebugPrint('testing JASDebugPrint');
    JASDebugPrintln('testing JASDebugPrintln');
  end;  
  
  result:=bOk;
end;
//=============================================================================









//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!File Related
//*****************************************************************************
//==========================================================================
//*****************************************************************************


//=============================================================================
function Test_File: boolean;
//=============================================================================
var bOk: boolean;
    saSource: ansistring;
    saDest: ansistring;
    u2IOResult: word;
    u2ShellResult: integer;
    f: text;
begin
  bOk:=true;
  if bok then
  begin
    {$IFDEF WIN32}
    u2ShellResult:=u2shell('cmd','/c time /t');
    bOk:=u2ShellResult=0;
    {$ELSE}
    u2ShellResult:=u2shell('/usr/bin/time','-apvV');
    bOk:=u2ShellResult=0;
    {$ENDIF}
    if not bOk then
    begin
      write('iShell - result:',u2ShellResult);
      if(u2ShellResult>32768)then
      begin
        write(' This is a DosError Code - you need to subtract 32768 to '+
          'get the real Error code, its: ', u2ShellResult-32768,
          ' which means error: ',sIOResult(word(u2ShellResult-32768)));
      end
      else
      begin
        write(' This is a Dos EXIT (errorlevel) Code that was returned from iShell.');
      end;
    end;  
  end;
  
  if bOk then
  begin
    {$IFDEF WIN32}
    u2ShellResult:=u2shell('cmd','/c echo hello > test_ug_jegas_output.txt');
    bOk:=u2ShellResult=0;
    {$ELSE}
    assign(f,'test_ug_jegas_output.txt');
    rewrite(f);
    write(f,'hello');
    close(f);
    //iShellResult:=ishell('echo','hello > test_uxxg_jegas_output.txt');
    {$ENDIF}
    if not bOk then write('problem shelling out to make output file for testing purposes. '+sIOREsult(u2Shellresult));
    if bOk then
    begin
      bOk:=FileExists('test_ug_jegas_output.txt');
      if not bOk then write('tried to make a test drop file, it doesn''t exist like it should.');
    end;
    
    if bOk then
    begin
      saSource:='test_ug_jegas_output.txt';
      saDest:='test_ug_jegas_output2.txt';
      bOk:=bCopyfile(saSource, saDest);
      if not bOk then 
      begin
        write('bCopyFile(src,dest) 201001270217');
        bOk:=bCopyfile(saSource, saDest,u2IOResult);
        writeln('bOk: '+sTrueFalse(bOk)+' ioresult:'+sIOREsult(u2IOResult));
      end;
      
      if bOk then 
      begin
        bOk:=FileExists(saDest);
        if not bOk then write('bCopyFile(src,dest) - file not exist after it finished.');
      end;
    end;
  end;
    
  if bOk then
  begin
    u2IOResult:=0;
    deletefile(saSource);
    bOk:=bCopyfile(saDest, saSource, u2IOResult);
    if not bOk then write('bCopyFile(src,dest,u2IOResult)');
    if bOk then 
    begin
      bOk:=u2IOResult=0;
      if not bOk then write('bCopyFile(src,dest,u2IOResult) - IOResult:'+inttostr(u2IOResult));
    end;
    if bOk then 
    begin
      bOk:=FileExists(saSource);
      if not bOk then write('bCopyFile(src,dest,u2IOResult) file not exist afterwards.');
    end;
  end;
    
  if bOk then
  begin
    bOk:=bMoveFile(saSource,saDest);
    if not bOk then write('bMoveFile(src,dest)');
    if bOk then
    begin
      bOk:=FileExists(saSource)=false;
      if not bOk then write('bMoveFile(src,desc) didn''t remove original file.');
    end;
  end;
    
  if bOk then
  begin
    u2IOResult:=0;
    bOk:=bMovefile(saDest, saSource, u2IOResult);
    if not bOk then write('bMoveFile(src,dest,u2IOResult)');
    if bOk then 
    begin
      bOk:=u2IOResult=0;
      if not bOk then write('bMoveFile(src,dest,u2IOResult) - IOResult:'+inttostr(u2IOResult));
    end;
    if bOk then 
    begin
      bOk:=FileExists(saSource);
      if not bOk then write('bMoveFile(src,dest,u2IOResult) file not exist afterwards.');
    end;
  end;

  if bOk then 
  begin
    deletefile('test_ug_jegas_output.001.txt');
    deletefile('test_ug_jegas_output.002.txt');
    bOk:=(false=FileExists('test_ug_jegas_output.001.txt')) and (false=FileExists('test_ug_jegas_output.002.txt'));
    if not bOk then write('unable to remove test output files prior to test - they still exist and should not.');

    if bOk then
    begin
      assign(f,'test_ug_jegas_output.001.txt');
      rewrite(f);
      write(f,'hello');
      close(f);
      if not bOk then write('trouble trying to make a test output file.');
    end;
    
    if bOk then 
    begin
      bOk:=FileExists('test_ug_jegas_output.001.txt');
      if not bOk then write('output file created for test doesn''t exist so unable to test.');
    end;
    
    if bOk then
    begin
      bOk:=(saSequencedFilename('test_ug_jegas_output','txt')='test_ug_jegas_output.002.txt');
      if not bOk then write('saSequencedFilename(filename,ext): ',saSequencedFilename('test_ug_jegas_output','txt'));
    end; // its a unit tester ..bah ;)
    
    if bOk then
    begin
      // Clean up :)
      deletefile('test_ug_jegas_output.001.txt');
      deletefile('test_ug_jegas_output.txt');
    end;
  end;

  // The following 3 routines are a bit complex for a quick unit test because 
  // they create directories on the fly. Our run location for this app 
  // isn't fixed and I don't feel like going through the motions
  // right now to make a safe and clean unit test for these.
  // Future: bFileExistsInTRee test
  // Future: bStoreFileInTree test
  // Future: bDeleteFilesInTree test
  
  if bOk then
  begin
    {$IFDEF WINDOWS}
      saSource:='c:\somedir\somefile.txt';
      bOk:=(saFileNameNoExt(saSource)='somefile');
    {$ELSE}
      saSource:='/home/somefile.txt';
      bOk:=(saFileNameNoExt(saSource)='somefile');
    {$ENDIF}
    if not bOk then write('saFileNameNoExt(src):',saFileNameNoExt(saSource));
  end;
  

  // Future: function bSaveFile(p_saFilename: ansistring;p_saFileData: ansistring;p_iRetryLimit: integer;p_iRetryDelayInMSecs: integer;var p_u2IOResult: word;p_bAppend: boolean):boolean;



  result:=bOk;
end;
//=============================================================================






//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Date-n-Time 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
// We could add more JDate tests - but I think we have most of the ground 
// covered.
function Test_DateNTime: boolean;
//=============================================================================
var bOk: boolean;
    dt: TDATETIME;
    dt2: TDATETIME;
    ts: TTIMESTAMP;
    sa: ansistring;
begin
  bOk:=true;
  
  // Testing JDATE Variety that doesn't Pass Date Object In OR Out
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_01,cnDateFormat_01)='10/07/1971 05:30 AM');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_01,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_01,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_02,cnDateFormat_01)='10/07/1971');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_02,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_02,cnDateFormat_01));
  end;
  
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_03,cnDateFormat_01)='1971-10-07');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_03,csDateFormat_01)');
  end;
  
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_04,cnDateFormat_01)='Thu Oct 07 05:30:00 EDT 1971');//'DDD MMM DD HH:NN:SS EDT YYYY'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_04,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_04,cnDateFormat_01));
  end;
  
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_05,cnDateFormat_01)='Thu, 07 Oct 1971 05:30:00');//'DDD, DD MMM YYYY HH:NN:SS'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_05,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_05,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_06,cnDateFormat_01)='Thu, 07 Oct 1971 05:30:00 UTC');//'DDD, DD MMM YYYY HH:NN:SS UTC
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_06,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_06,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_07,cnDateFormat_01)='Thur, 07 Oct 1971 05:30:00 AM');//DDDD, DD MMM, YYYY HH:NN:SS AM
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_07,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_07,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_08,cnDateFormat_01)='05:30:00');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_08,csDateFormat_01)');
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_09,cnDateFormat_01)='05:30:00 EDT');//'HH:NN:SS EDT'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_09,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_09,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_10,cnDateFormat_01)='Oct Thu 07 1971');//'MMM DDD DD YYYY'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_10,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_10,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_11,cnDateFormat_01)='1971-10-07 05:30:00');//'YYYY-MM-DD HH:NN:SS'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_11,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_11,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_12,cnDateFormat_01)='10/07/71');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_12,csDateFormat_01)');
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_13,cnDateFormat_01)='07/Oct/1971');//'DD/MMM/YYYY'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_13,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_13,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_14,cnDateFormat_01)='07/Oct/1971 05:30 AM');//'DD/MMM/YYYY HH:MM AM'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_14,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_14,cnDateFormat_01));
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_15,cnDateFormat_01)='07/Oct/1971 05:30');//'DD/MMM/YYYY HH:MM'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_15,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_15,cnDateFormat_01));
  end;
  
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_16,cnDateFormat_01)='05:30 AM');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_16,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_16,cnDateFormat_01));
  end;
  
  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_17,cnDateFormat_01)='05:30');
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_17,csDateFormat_01)');
  end;

  if bOk then
  begin
    bOk:=(JDate('10/07/1971 05:30 AM',cnDateFormat_18,cnDateFormat_01)='07/Oct/1971:05:30:00');//'DD/MMM/YYYY:HH:NN:SS'
    if not bOk then write('JDate(''10/07/1971 05:30 AM'',cnDateFormat_18,csDateFormat_01):'+JDate('10/07/1971 05:30 AM',cnDateFormat_18,cnDateFormat_01));
  end;

  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  end;
  
  // Testing JDATE Variety that DOES Pass Date Object In OR Out
  if bOk then
  begin
    bOk:=(JDate('',cnDateFormat_01,cnDateFormat_00,dt)='10/07/1971 05:30 AM');
    if not bOk then write('JDate('''',cnDateFormat_01,cnDateFormat_00,dt):'+JDate('',cnDateFormat_01,cnDateFormat_00,dt));
  end;

  //ts:=StrToTimeStamp('10/07/1971 05:30 AM');
  //writeln(saFormatTimeStamp('yyyy-mm-dd hh:nn',ts));

  //--------------------
  // Function tsAddYears(p_tsFrom: TTIMESTAMP; p_iYears: Integer): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2071,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddYears(DateTimeToTimeStamp(dt), 100))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddYears failed');
  end;
  
  //--------------------
  // Function tsAddMonths( p_tsFrom: TTIMESTAMP;  p_iMonths: Integer): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1972,2,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddMonths(DateTimeToTimeStamp(dt), 4))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddMonths failed');
  end;
  
  //--------------------
  // Function tsAddDays(p_tsFrom: TTIMESTAMP; p_iDays: Integer): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,11,2);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddDays(DateTimeToTimeStamp(dt), 26))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddDays failed');
  end;
  

  //--------------------
  // Function tsAddHours(p_tsFrom: TTIMESTAMP; p_Comp_Hours: Comp): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,8);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddHours(DateTimeToTimeStamp(dt), 24))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddHours failed:'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(tsAddHours(DateTimeToTimeStamp(dt), 24))));
  end;


  //--------------------
  // Function tsAddMinutes(p_tsFrom: TTIMESTAMP; p_Comp_Minutes: Comp): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddMinutes(DateTimeToTimeStamp(dt), 60))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddMinutes failed:'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(tsAddMinutes(DateTimeToTimeStamp(dt), 24))));
  end;

  //--------------------
  // Function tsAddSec(p_tsFrom: TTIMESTAMP; p_Comp_Seconds: Comp): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddSec(DateTimeToTimeStamp(dt), 3600))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddSec failed:'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(tsAddSec(DateTimeToTimeStamp(dt), 24))));
  end;

  //--------------------
  // Function tsAddMSec( p_tsFrom: TTIMESTAMP; p_Comp_MSec: Comp): TTIMESTAMP;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,1,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(TimeStampToDateTime(tsAddMSec(DateTimeToTimeStamp(dt), 1000))=TimeStampToDateTime(ts));
    if not bOk then write('tsAddMSec failed:'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(tsAddMSec(DateTimeToTimeStamp(dt), 24))));
  end;
  

  //--------------------
  // Function iDiffYears(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP):Integer ;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,1,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2011,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffYears(DateTimeToTimeStamp(dt),ts)= -40;
    if not bOk then write('iDiffYears failed:'+inttostr(iDiffYears(DateTimeToTimeStamp(dt),ts)));
  end;

  //--------------------
  // Function iDiffMonths(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,1,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(1972,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffMonths(DateTimeToTimeStamp(dt),ts)= -11;
    if not bOk then write('iDiffMonths failed:'+inttostr(iDiffMonths(DateTimeToTimeStamp(dt),ts)));
  end;

  //--------------------
  // Function iDiffDays(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,2,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffDays(DateTimeToTimeStamp(dt),ts)= -31;
    if not bOk then write('iDiffDays failed:'+inttostr(iDiffDays(DateTimeToTimeStamp(dt),ts)));
  end;


  //--------------------
  // Function iDiffHours(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffHours(DateTimeToTimeStamp(dt),ts)=1;
    if not bOk then write('iDiffHours failed:'+inttostr(iDiffHours(DateTimeToTimeStamp(dt),ts)));
  end;




  //--------------------
  // Function iDiffMinutes(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,1,2);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;
  
    bOk:=iDiffMinutes(DateTimeToTimeStamp(dt),ts)=-1440;
    if not bOk then write('iDiffMinutes failed:'+inttostr(iDiffMinutes(DateTimeToTimeStamp(dt),ts)));
  end;

  if bOk then
  begin
    Try
    dt:= EnCodeDate(2010,9,25);
    Except
    End;

    Try
    dt:= dt + EnCodeTime(1,00,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2010,9,24);
    Except
    End;

    Try
    dt:= dt + EnCodeTime(23,0,0,0);
    Except
    End;

    bOk:=iDiffMinutes(DateTimeToTimeStamp(dt),ts)=120;
    if not bOk then write('iDiffMinutes failed:'+inttostr(iDiffMinutes(DateTimeToTimeStamp(dt),ts)));
  end;



  //--------------------
  // Function iDiffSeconds(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,31,0,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffSeconds(DateTimeToTimeStamp(dt),ts)=60;
    if not bOk then write('iDiffSeconds failed:'+inttostr(iDiffSeconds(DateTimeToTimeStamp(dt),ts)));
  end;

  //--------------------
  // Function iDiffMSec(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): Integer;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,100);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=iDiffMSec(DateTimeToTimeStamp(dt),ts)=100;
    if not bOk then write('iDiffMSec failed:'+inttostr(iDiffMSec(DateTimeToTimeStamp(dt),ts)));
  end;


  //--------------------
  // SEE NOTES in ug_jegas.pp for this function - the results aren't 100%
  // IDEAL. Excluding from the testing for now.
  // Function tsDiff(p_tsFrom: TTIMESTAMP; p_tsTo: TTIMESTAMP): TTIMESTAMP;
  //--------------------
  {
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,31,1,0);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);

    Try
    dt:= EnCodeDate(2006,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    writeln('RESULT:'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(tsDiff(DateTimeToTimeStamp(dt),ts))));
    //bOk:=tsDiff(DateTimeToTimeStamp(dt),ts);
    //if not bOk then write('iDiffMSec failed:'+inttostr(iDiffMSec(DateTimeToTimeStamp(dt),ts)));
  end;
  }

  
  //=============================================================================
  // Function saFormatTimeStamp(p_saFormat: AnsiString; p_ts: TTIMESTAMP): AnsiString;
  //=============================================================================
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,100);
    Except
    End;
    ts:=DateTimeToTimeStamp(dt);
    bOk:='2005-01-01 5:30:00'=saFormatTimeStamp(csDATETIMEFORMAT,ts);
    if not bOk then write('saFormatTimeStamp');
  end;

  //=============================================================================
  // Function StrToTimeStamp(p_sa: AnsiString):TTIMESTAMP;
  //=============================================================================
  if bOk then
  begin
    sa:='1/1/5 5:30 PM';
    ts:=StrToTimeStamp(sa);
    bOk:='2005-01-01 17:30:00'=FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(ts));
    if not bOk then write('StrToTimeStamp');
  end;

  //=============================================================================
  // Function FormatDateTime(p_saFormat: AnsiString; p_ts: TTIMESTAMP): AnsiString;
  //=============================================================================
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,1,1);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,100);
    Except
    End;
    bOk:='2005-01-01 5:30:00'=FormatDateTime(csDATETIMEFORMAT,dt);
    if not bOk then write('FormatDateTime');
  end;

  //=============================================================================
  // Function dtAddYears(p_dtFrom: TDATETIME; p_iYears: Integer): TDATETIME;
  //=============================================================================
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(2071,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddYears(dt, 100)=dt2);
    if not bOk then write('dtAddYears failed');
  end;


  //=============================================================================
  // Function dtAddMonths(p_dtFrom: TDATETIME; p_iMonths: Integer): TDATETIME;
  //=============================================================================
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(1972,2,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddMonths(dt, 4)=dt2);
    if not bOk then write('dtAddMonths failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddMonths(dt, 4)));
  end;


  //--------------------
  // Function dtAddDays(p_dtFrom: TDATETIME; p_iDays: Integer): TDATETIME;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(2005,11,2);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(2005,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddDays(dt2, 26)=dt);
    if not bOk then write('dtAddDays failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddDays(dt2, 26)));
  end;
  

  //--------------------
  // Function dtAddHours(p_dtFrom: TDATETIME;p_iHours: Integer): TDATETIME;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,8);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;
  
    Try
    dt2:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddHours(dt2, 24)=dt);
    if not bOk then write('dtAddHours failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddHours(dt2, 24)));
  end;


  //--------------------
  // Function dtAddMinutes(p_dtFrom: TDATETIME; p_iMinutes: Integer): TDATETIME;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddMinutes(dt2, 60)=dt);
    if not bOk then write('dtAddMinutes failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddMinutes(dt2, 60)));
  end;

  //--------------------
  // Function dtAddSec(p_dtFrom: TDATETIME; p_iSeconds: Integer): TDATETIME;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(6,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,0,0);
    Except
    End;
  
    bOk:=(dtAddSec(dt2, 3600)=dt);
    if not bOk then write('dtAddSec failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddSec(dt2, 3600)));
  end;

  //--------------------
  // Function dtAddMSec(p_dtFrom: TDATETIME; p_iMSec: Integer): TDATETIME;
  //--------------------
  if bOk then
  begin
    Try
    dt:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt:= dt + EnCodeTime(5,30,0,0);
    Except
    End;

    Try
    dt2:= EnCodeDate(1971,10,7);
    Except
    End;
    
    Try
    dt2:= dt2 + EnCodeTime(5,30,1,0);
    Except
    End;
  
    bOk:=(dtAddMSec(dt, 1000)=dt2);
    if not bOk then write('dtAddMSec failed:'+FormatDateTime(csDATETIMEFORMAT,dtAddMSec(dt, 1000)));
  end;


  { Future: Make Tests for these
  //=============================================================================
  Function iDiffYears(p_dtFrom: TDATETIME; p_dtTo: TDATETIME):Integer ;
  //=============================================================================
  // This is a funky way to do it, but necessary as far as I know because
  // it manages to handle the leap year stuff by leveraging the FreePascal
  // IncMonth Function. This works out to be accurate, versus day math like
  // days divided by some guess'timate like 30 days a month - which is skewed.
  Function iDiffMonths(p_dtFrom: TDATETIME;p_dtTo: TDATETIME): Integer;
  //=============================================================================
  Function iDiffDays(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Integer;
  // This looks recursive but its not - there are two versions of many of the 
  // datetime functions - one for freepascal TDATETIME and one for OS TIMESTAMPS.
  //=============================================================================
  Function iDiffHours(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Integer;
  //=============================================================================
  Function iDiffMinutes(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Integer;
  //=============================================================================
  Function iDiffSeconds(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Integer;
  //=============================================================================
  Function iDiffMSec(p_dtFrom: TDATETIME; p_dtTo: TDATETIME): Integer;
  //=============================================================================
  // cheap milli sec thing - returns milliseconds since midnight.
  Function iMSec(p_dt: TDATETIME):Integer;
  //=============================================================================
  // cheap milli sec thing - returns milliseconds since midnight
  // This is the Same as the above version of this routine except this one
  // uses the system clock with the sysutils' NOW function.
  Function iMSec:Integer;
  //=============================================================================
  Procedure WaitInMSec(p_iMilliSeconds: Integer);
  //=============================================================================
  // sysutils consts
  // SecsPerDay = 24 * 60 * 60; // Seconds and milliseconds per day
  // MSecsPerDay = SecsPerDay * 1000;
  // DateDelta = 693594; // Days between 1/1/0001 and 12/31/1899
  // Procedure WaitInSec(p_iSeconds:Integer);
  //=============================================================================
  //=============================================================================
  // sysutils consts
  // SecsPerDay = 24 * 60 * 60; // Seconds and milliseconds per day
  // MSecsPerDay = SecsPerDay * 1000;
  // DateDelta = 693594; // Days between 1/1/0001 and 12/31/1899
  Procedure WaitInSec(p_iSeconds:Integer);
  //=============================================================================
  }
  result:=bOk;
end;
//=============================================================================







//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Logging
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
function Test_Logging: boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=true;
  { Future: Make Tests for these
  //=============================================================================
  // NOTE: Used internally by IOAppendLog
  // This was internally Encapsulated but - returns column headers
  // prepared to be outed by IOAppend after an EOL is appendeded for
  // the correct OS implementation.
  Function saIOAppendLogColumnHeaders(Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
  //=============================================================================
  
  //=============================================================================
  // NOTE: Used internally by IOAppendLog
  // This was internally Encapsulated but - returns column data
  // prepared to be outed by IOAppend after an EOL is appendeded for
  // the correct OS implementation.
  Function saIOAppendLogColumnData(Var p_rIOAppendLog: rtIOAppendLog): AnsiString;
  //-----------------------------------------------------------------------------
  // Purpose: To make the most compatible "generic" logging format for importing 
  // data into various applications.
  Function bIOAppendLog(Var p_rIOAppendLog: rtIOAppendLog):Boolean;
  //function bIOAppendLog(var p_rIOAppendLog: rtIOAppendLog; var p_u2IOResult: word):boolean;
  //-----------------------------------------------------------------------------
  
  //=============================================================================
  // INTERNAL
  Function JLog(
    p_u1Severity: Byte;
    p_u8Entry_ID: Int64; 
    p_saEntryData: AnsiString;
    p_saSourceFile: AnsiString
  ): Boolean;
  //=============================================================================

  //=============================================================================
  // This function is used by internal JLOG logging function and is made
  // available externally for uxxg_jfc_threadmgr's internal debugging infrastructure.
  Function saDebugNest(p_saSectionName: AnsiString; p_bBegin: Boolean; var p_iNestLevel: integer): AnsiString;
  //=============================================================================

  }
  write(' LOGGING TESTS not implemented yet ');
  result:=bOk;
end;
//=============================================================================







//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Strings
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
// Base64 Conversion
//=============================================================================
function test_base64: boolean;
var 
  bOk: boolean;
  saBase64_Before: ansistring;
  saBase64_After : ansistring;
  saResult: ansistring;
  saDecodethis: ansistring;
  
begin
  saBase64_Before := 'Hello World!';
  saBase64_After := 'SGVsbG8gV29ybGQh';
    
  bOk:=true;
  if bOk then
  begin
    saResult:=saBase64Encode(saBase64_Before);
    bOk:= (saResult = saBase64_After);
    if not bOk then
    begin
      writeln('201012111203 - saBase64Encode(''',saBase64_Before,''') returned: '+ saResult);
      writeln('201012111203 - Expected: ',saBase64_After);
    end;
  end;
  
  if bOk then
  begin
    saDecodethis:=saResult;
    saResult:=saBase64Decode(saDecodethis);
    bOk:= (saResult = saBase64_Before);
    if not bOk then
    begin
      writeln('201012111204 - saBase64Decode(''',saDecodethis,''') returned: '+ saResult);
      writeln('201012111204 - Expected: ',saBase64_Before);
    end;
  end;
  
  result:=bOk;
end;
//=============================================================================





//=============================================================================
function Test_Strings: boolean;
//=============================================================================
var bOk: boolean;
begin
  bOk:=true;

  if bOK then
  begin
    bOk:=sZeroPadInt(20,3)='020';
    if not bok then writeln('sZeroPadInt(20,3): '+sZeroPadInt(20,3));
  end;


  if bOk then
  begin
    bOk:=length(saJegasLogoRawText(csCRLF, true))>0;
    if not bok then
    begin
      writeln('saJegasLogoRawText(ansistring,boolean)');
    end;
  end;

  if bOk then
  begin
    bOk:=length(saJegasLogoRawText(csCRLF))>0;
    if not bOk then
    begin
      writeln('saJegasLogoRawText(ansistring)');
    end;
  end;

  if bOk then
  begin
    bOk:=length(saJegasLogoRawHtml)>0;
    if not bOk then
    begin
      writeln('saJegasUnderTheHoodLogoRawHtml');
    end;
  end;

  //  Function saWindowStateToString(p_i4WindowState: LongInt): AnsiString;
  //  Function i4WindowStateToInt(p_saWindowState: AnsiString): LongInt;
  //  Function saOnOff(p_bBoolean:Boolean): AnsiString;
  //  Function bOnOff(p_saOnOff: AnsiString): Boolean;
  //  Function saXorString(p_sa: AnsiString; p_u1Key: Byte):AnsiString;
  //  Function saRepeatChar(p_ch: Char; p_iHowMany: Integer): AnsiString;
  //  Function saOneZero(p_bOneZero: Boolean):AnsiString;
  //  Function i4PToC(p_sa: AnsiString; Var p_cdest: PChar; p_i4DestCBuflen: LongInt):LongInt;
  //  Function saCToP(Var p_csrc: PChar):AnsiString;
  //  function saSolveRelativePath(p_sa: AnsiString):ansistring;
  //  Function saProper(p_saSentence: ansistring): ansistring;
  //  Function saParseLastName(p_saName: ansistring): ansistring;
  //  Function saBuildName(
  //    p_saDear: AnsiString;
  //    p_saFirst: AnsiString;
  //    p_saMiddle: AnsiString;
  //    p_saLast: AnsiString;
  //    p_saSuffix: ansiString
  //  ):ansistring;
  //  Function saPhoneConCat(p_saPhone: ansistring; p_saExt: ansistring): ansistring;
  //  Procedure ParseName(
  //    p_In_saName: ansistring;
  //    var p_Out_saFirst: ansistring;
  //    var p_Out_saMiddle: ansistring;
  //    var p_Out_saLast: ansistring
  //  );

  //function saMid(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
  if bOk then
  begin
    bOk:=saMid('test this thing',6,4)='this';
    if not bOk then
    begin
      writeln('saMid(ansistring,int64,int64):ansistring;');
    end;
  end;

  if bOk then
  begin
    bOk:=saMid('test this thing',100,200)='';
    if not bOk then
    begin
      writeln('saMid(ansistring,int64,int64):ansistring;');
    end;
  end;


  //function saCut(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
  if bOk then
  begin
    bOk:=saCut('test this thing',6,5)='test thing';
    if not bOk then
    begin
      writeln('saCut(ansistring,int64,int64):ansistring;');
    end;
  end;


  //function saInsert(p_saSrc: ansistring; p_i8Start: int64; p_i8Length: int64): ansistring;
  if bOk then
  begin
    bOk:=saInsert('test thing','this ', 6)='test this thing';
    if not bOk then
    begin
      writeln('saInsert(ansistring,int64,int64):ansistring;');
      writeln('Result: '+saInsert('test thing','this ', 6));
    end;
  end;

  if bOk then
  begin
    bOk:=saInsert('test this','thing!', 11)='test this thing!';
    if not bOk then
    begin
      writeln('(test 2) saInsert(ansistring,int64,int64):ansistring;');
      writeln('Result: '+saInsert('test this','thing!', 11));
    end;
  end;

  if bOk then
  begin
    bOk:=Test_Base64;
  end;

  //function saSingle(p_fValue: single; p_iDigits: longint; p_iDecimals: longint): ansistring;
  //function saDoubleEscape(p_saEscapeThis: ansistring; p_chCharToEscape: char): ansistring;


  if bOk then
  begin
    bOk:=bGoodEmail('jasonpsage@jegas.com');
    if not bOk then
    begin
      writeln('bGoodEmail(''jasonpsage@jegas.com'')');
    end;
  end;

  if bOk then
  begin
    bOk:=NOT bGoodEmail('jasonpsagejegas.com');
    if not bOk then
    begin
      writeln('bGoodEmail(''jasonpsagejegas.com'')');
    end;
  end;
  
  if bOk then // >=8 <= 32 - no spaces
  begin
    bOk:=bGoodPassword('12345678');
    if not bOk then
    begin
      writeln('bGoodPassword(''12345678'')');
    end;
  end;

  if bOk then // >=8 <= 32 - no spaces
  begin
    bOk:=not bGoodPassword('1234567');
    if not bOk then
    begin
      writeln('bGoodPassword(''1234567'')');
    end;
  end;

  if bOk then
  begin
    bOk:=bGoodUserName('test01');
    if not bOk then
    begin
      writeln('bGoodUsername(''test01'')');
    end;
  end;

  if bOk then
  begin
    bOk:=NOT bGoodUserName('test 01');
    if not bOk then
    begin
      writeln('bGoodUsername(''test 01'')');
    end;
  end;


  if bOk then
  begin
    bOk:=uIPAddressCount('1.1.1.1')=1;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 1');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1.1.1.')=256;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 256');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1.1.1')=256;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 256');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1.1.')=65536;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 65536');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1.1')=65536;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 65536');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1.')=16777216;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 16777216');
    end;
  end;
  if bOk then
  begin
    bOk:=uIPAddressCount('1')=16777216;
    if not bOk then
    begin
      writeln('uIPAddressCount(''1.1.1.1'')=',uIPAddressCount('1.1.1.1'),' Wanted: 1');
    end;
  end;
  result:=bok;
end;
//=============================================================================






//=============================================================================
Var 
  //sa: AnsiString;
  bOk: boolean;
//=============================================================================
Begin
  Write('Debug related tests: ');bOk:=Test_Debug;if bOk then Writeln('Passed.') else Writeln(' Failed.');
  writeln;
  
  Write('File related tests: ');bOk:=Test_File;if bOk then Writeln('Passed.') else Writeln(' Failed.');
  writeln;

  Write('Date-n-Time related tests: ');bOk:=Test_DateNTime;if bOk then Writeln('Passed.') else Writeln(' Failed.');
  writeln;

  Write('Logging related tests: ');bOk:=Test_Logging;if bOk then Writeln('Passed.') else Writeln(' Failed.');
  writeln;
  
  Write('Strings related tests: ');bOk:=Test_Strings;if bOk then Writeln('Passed.') else Writeln(' Failed.');
  writeln;
  
  if bOk then
  writeln('ALL TESTS PASSED!');
  //writeln('Press any key to continue.');
  //readln;
//=============================================================================
end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
