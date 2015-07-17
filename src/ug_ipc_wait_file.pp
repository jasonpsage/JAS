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
// File Based Interprocess Communication
//
// FileName: YYYYMMDDHHNNSSCCCRRRRRRRRRR.extension
// YYYY = YEAR     CCC = Milli Seconds
// MM = Month      RRRRRRRRRR = RANDOM NUMBER (31 bit range)
// DD = DAY
// HH = HOUR
// NN = MINUTES
// SS = SECONDS
//
Unit ug_ipc_wait_file;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_ipc_send_file.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{INCLUDE i_jegas_ipc_file.pp}
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               Interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
Uses 
//=============================================================================
  dos,
  ug_common;
//=============================================================================

//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Const cnMilliSecondInterval=10;
{}
Var saIPCFileNameLessExtension: AnsiString;
//=============================================================================
{}
// in this implementation - this is the FULL FILENAME AND PATH
// LESS the Extension. c:\fifopath\4312412334312421432141414
// -
// the p_bExact means you aren't polling for a filespec within
// the current 
// - 
// NOTE: Wild Card "time range" resolution is hardcoded in this routine
// and is easy enough to tighten up... but its based on YYYYMM
// TODO: Logic to handle crossing "boundries" like a New year
// or month, or day or whatever the resolution is should be handled
// by EXACT CALL that is p_saComm='*', p_bExact=true.
// this will bring all *.FIFO in the path sent WHICH could
// make an infinate loop if files aren't delete after being processed 
// OR an error condition!!! This can get dicey. A manner to fix this sounds
// simple enough - just delete the file or rename if error... BUT.... 
// the advanced FPC file handling - uses SYSUTILS unit which brings
// with it OOP support internally to itself, BUT causes the runtime EXE size
// to get big - this is fine usually - but not with the thin layer design for 
// the CGI. This should be OK for now because of the fact that I personally
// play on FIFO going out, and a separate FIFO coming in. (2 directories)
// which makes allowance for "problem situations" to be handled by the 
// BIG applications that are OOP anyway and don't have the problem
// of using the FPC sysutils overhead.
//
// NOTE: I don't know which units may or may not require 
// (internally) the OOP support in linux. Hmm.
Function bIPCWait(
  Var p_saCommID: AnsiString; 
  p_bExact: Boolean; 
  p_saPath: AnsiString;
  Var p_saExt: AnsiString;
  p_iMaxWaitInMilliSeconds:Integer
): Boolean;
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Function bIPCWait(
  Var p_saCommID: AnsiString; 
  p_bExact: Boolean; 
  p_saPath: AnsiString;
  Var p_saExt: AnsiString;
  p_iMaxWaitInMilliseconds: Integer
): Boolean;
//=============================================================================
Const cn_FilenameArraySize=50;
Var 
  //F: text;  
  //u2IOResult: word;
  //y,m,d,wd: word;
  //h,n,s,s100: Word;// date + time via dos unit
  //u2SecStart: word;
  
  iMilliSecondsWaitedForSoFar:Integer;
  //sa: AnsiString;
  saFN: AnsiString;
  sPath, sName, sExt: String;

  // Hardcoded but should compress nicely if not 
  // created on stack.
  DIR: SearchRec;
  t1,t2: Integer;// my generic integer variable :) 'i' is over rated ;)
  iLoadedFilenames: Integer;

  asFileNames: array [0..cn_FilenameArraySize] Of String;
  sSortTemp: String;
  bGotIt: Boolean;
Begin
  //FSplit(p_saCommID, sPath,sName,sExt);
  iMilliSecondsWaitedForSoFar:=0;
    
  Result:=False;
  If p_bExact Then 
  Begin
    // Waiting for specific Filename!
    // Therefore - Timemout mechanism appropriate for now
    // until OS specific implementations to release CPU get put
    // in place to make the time out thing more efficient.
    saFN:=p_saPath + p_saCommID+'.'+p_saExt;
    // SNAG Time NOW
    //GetTime(h,n,s,s100);
    //iSecStart:=s-1;
    //u2SecStart:=s-1;
    bGotIt:=False;
    //If iSecStart=-1 Then iSecStart:=59; 
    repeat     
      FindFirst(saFN,archive, DIR);
      If DosError=0 Then
      Begin
        //p_saCommID:=sPath + saFN;
        bGotIt:=True;
        Result:=True;
      End;
      If (not bGotIt) and (p_iMaxWaitInMilliSeconds>0) Then Begin
        Yield(cnMilliSecondInterval);
        iMilliSecondsWaitedForSoFar:=iMilliSecondsWaitedForSoFar+cnMilliSecondInterval;
      End;
      FindClose(DIR);
      //GetTime(h,n,s,s100);
      //riteln(iSecStart,' ',s,' ',saFN,'<br>');
    Until (iMilliSecondsWaitedForSoFar>p_iMaxWaitInMilliSeconds) OR (bGotIt);
  End
  Else
  Begin
    // FIFO MODE - Currently first of the first 
    //   cn_FilenameArraySize
    saFN:=p_saPath + '*.' + p_saExt;
    iLoadedFilenames:=0;
    //riteln('loading filenames');
    //riteln('FindFirst spec:',saFN);
    FindFirst(saFN,archive, DIR);
    //riteln('ipcwait filename found:>',DIR.Name,'<');
    //riteln('length of the filename:',length(DIR.Name));
    //riteln('DosError:',DosError);
    If DosError=0 Then
    Begin
      While (DosError=0) and 
            (iLoadedFilenames<cn_FilenameArraySize) Do Begin
        //riteln('FindFirstWorked');
        asFilenames[iLoadedFilenames]:=dir.name;
        iLoadedFilenames+=1;
        FindNext(DIR);
      End;
      DosError:=0;
    End;
    FindClose(DIR);
    //riteln('FindClose DosError?:',DosError);
    //riteln('Loaded File Names:',iLoadedFileNames);
      
    If (DosError=0)and(iLoadedFilenames>0) Then
    Begin
      // OK - at this point we grabbed the first 100 filenames
      // and we will sort ascending - (yes this is a hardcoded         
      // threshold)
      //riteln('Sorting filenames');
      If iLoadedFilenames>=2 Then 
      Begin
        t2:=0;
        While t2<iLoadedFilenames-1 Do Begin
          t1:=0;
          While t1<iLoadedFilenames-1 Do Begin
            If asFilenames[t1]>asFilenames[t1+1] Then
            Begin
              // cheap bubble sort swap
              sSortTemp:=asFilenames[t1];
              asFilenames[t1]:=asFilenames[t1+1];
              asFilenames[t1+1]:=sSortTemp;
            End;
            t1+=1;
          End;
          t2+=1;
        End;
      End;
      //p_saCommID:=sPath + asfilenames[0];
      FSplit(asfilenames[0], sPath,sName,sExt);
      p_saCommID:=sName;
      //p_saPath:=sPath;
      //p_saExt:=sExt;
      Result:=True;
      //writeln('p_saCommID Out:',p_saCommID);
    End
    Else
    Begin
      //riteln('DosError is bad:',doserror);
      Result:=False;
    End;
  End;
  //riteln('Wait Result:',result);
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
