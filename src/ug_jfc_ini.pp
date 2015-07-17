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
// Manipulation Of INI Files
Unit ug_jfc_ini;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_ini.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
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
  sysutils,
  ug_common,
  ug_jegas,
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
// This Class saves and loads ONE INI file.
// It Tracks KEYS in its items. The Key Values are stored in a JFC_XDL
// pointed to by ITS Item_lpPTR.
Type JFC_INI = Class(JFC_XDL)
//=============================================================================
  Constructor create; 
  Procedure pvt_createtask; override; //virtual;
  Procedure pvt_destroytask(p_lp:pointer); override; //virtual;
  
  Function FoundSection(p_saSection: AnsiString):Boolean;
  Function FoundKey(p_saSection, p_saKey: AnsiString):Boolean;
  
  Function LoadIniFile(p_saFileNPath: AnsiString):Boolean;
  Function SaveIniFile(p_saFileNPath: AnsiString):Boolean;
  {}
  // Need add your own brackets [yoursection]
  Function DeleteSection(p_saSection: AnsiString):Boolean;
  Function DeleteKey(p_saSection, p_saKey: AnsiString):Boolean;
  Function ReadKey(
    p_saSection, p_saKey: AnsiString;
    Var p_saData: AnsiString):Boolean;
  {}
  // Add your own "=" signs
  // example: writekey('[yoursection]','yourkey=','yourvalue')
  Function WriteKey(
    p_saSection, p_saKey: AnsiString;
    p_saData: AnsiString):Boolean;
End;
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
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
Constructor JFC_INI.create;
//=============================================================================
Begin
  inherited;
  saClassNAme:='JFC_INI';
  bDebug:=True;
End;
//=============================================================================


//=============================================================================
Procedure JFC_INI.pvt_createtask; 
//=============================================================================
Begin
  //SageLog(1,'JFC_INI.pvt_createtask - begin lpitem:' + inttostr(longword(lpitem)));
  inherited;
  Item_lpPtr:=JFC_XDL.Create;
  //JFC_XDL(Item_lpPtr).bDebug:=true;
  //JFC_XDL(Item_lpPtr).saClassName:='JFC_XDL (JFC_INI Item)';
  //SageLog(1,'JFC_INI.pvt_createtask - end');
End;
//=============================================================================

//=============================================================================
Procedure JFC_INI.pvt_destroytask(p_lp:pointer); 
//=============================================================================
Begin
  //sagelog(1,'JFC_INI.pvt_destroytask begin');
  
  //sagelog(1,'p_lp:'+inttostr(longword(p_lp)) + ' ');
  //          'JFC_XDL(p_lp).Item_lpPtr:'+inttostr(longword(JFC_XDL(p_lp^).Item_lpPtr))+' ');
            
  
  
  
  JFC_XDL(JFC_XDLITEM(p_lp).lpPtr).Destroy;
  inherited;
  
  //sagelog(1,'JFC_INI.pvt_destroytask end');
End;
//=============================================================================

//=============================================================================
Function  JFC_INI.LoadIniFile(p_saFileNPath: AnsiString):Boolean;
//=============================================================================
Var F: text;
    bErr: Boolean;
    iErr: Integer;
    sa: AnsiString;
    iLen: Integer;
    iEq: Integer; // Position of First EqualSign
    bInSection: Boolean;
    ic: Integer; // Position of first Semicolon
Begin
  // DeleteAll;
  
  
  Result:=False;
  assign(f, p_saFileNPath);
  {$I-}
  reset(f);
  {$I-}
  iErr:=ioresult;
  bErr:=ierr<>0;
  //sagelog(1,'JFC_ini - Just reset file:'+p_saFileNPath + ' ioresult:' + inttostr(ierr));
  If NOT bErr Then Begin
    bInSection:=False;
    While (NOT bErr) AND (NOT Eof(f)) Do Begin
      {$I-}
      readln(f, sa);
      {$I+}
      iErr:=ioResult;
      
      //sagelog(1,'JFC_ini - Just read file:'+sa + ' ioresult:' + inttostr(ierr));
      
      bErr:=iErr<>0;
      
      //--- Not sure if this section has the desired effect 
      //if length(sa)>0 then if(sa[length(sa)]=#13) then sa:=leftstr(sa,length(sa)-1);
      //if length(sa)>0 then if(sa[length(sa)]=#10) then sa:=leftstr(sa,length(sa)-1);
      //---
      
      iLen:=length(sa);
      ieq:=pos('=',sa);
      ic:=pos(';',sa);

      If NOT bErr Then Begin
        // Section? (Relies on - NOTHING but Left Aligned "[Section]" Makes a section)
        If (ilen>=3) AND (sa[1]='[') AND (sa[iLen]=']') AND 
           (length(Trim(copy(sa,2,iLen-2)))>0) Then Begin
          bInSection:=True; // Once In Section STAY in Section just 
                            // Add New [SECTIONS] when encountered
          //AppendItem_saName(Trim(copy(sa,2,iLen-2)));
          AppendItem_saName(sa);
        End else 
        
        // if not IN section BUT the line isn't empty - Better add it to "SECTION"
        // list - May be comment or something
        // ORIGINAL: if (not bInSection) and (iLen>0) then Begin
        If (NOT bInSection) Then Begin
          AppendItem_saName(sa);
        End else 
        
        If (bInSection) AND (iLen>0) Then Begin
          // Do We Split it (i.e. key=somedatamaybe
          If (iEQ>1) AND ((ic>ieq) OR (ic=0)) Then Begin
            // Probably safe (Store Equal Sign to!! Key=)
            JFC_XDL(ITem_lpPtr).AppendItem_saName_N_saValue(
              LeftStr(sa,ieq),
              copy(sa, iEq+1, iLen-iEq)
            );
          End else Begin
            // No Split - Just Add the Thing - Could be anything
            JFC_XDL(ITem_lpPtr).AppendItem_saName(sa);
          End;
        End else Begin
          // Just White Space I guess
          If iLen>0 Then Jlog(cnLog_FATAL,238,'u03g_JFC_ini - Tossed "'+sa+'" While Loading:'+p_saFileNPath,SOURCEFILE);
        End;  
      End;
    End;
    {$I-}
    Close(f);
    {$I+}
    Result:=NOT bErr;
  End;
End;
//=============================================================================

//=============================================================================
Function  JFC_INI.SaveIniFile(p_saFileNPath: AnsiString):Boolean;
//=============================================================================
Var bErr: Boolean;
    F: text;
Begin
  Result:=False;
  assign(f, p_saFileNPath);
  {$I-}
  rewrite(f);
  {$I-}
  bErr:=ioResult<>0;
  If NOT bErr Then Begin
    If ListCount>0 Then Begin
      moveFirst;
      repeat
        Item_saName:=trim(item_saname);
        Item_saValue:=trim(item_saValue);
        If length(Item_saNAme)>0 Then Begin
          {$I-}
          //if Item_saNAme[1]<>';' then begin
            Writeln(f,Item_saName);
          //end else begin // write comment
          //  Writeln(f,Item_saName);
          //end;
          {$I+}
          bErr:=ioResult<>0;
          If (NOT berr) AND
             (JFC_XDL(Item_lpPtr).ListCount>0) Then Begin
            JFC_XDL(Item_lpPtr).MoveFirst;
            repeat 
              JFC_XDL(Item_lpPtr).Item_saName:=trim(JFC_XDL(Item_lpPtr).Item_saName);
              JFC_XDL(Item_lpPtr).Item_saValue:=trim(JFC_XDL(Item_lpPtr).Item_saValue);
              If length(JFC_XDL(Item_lpPtr).Item_saName)>0 Then Begin
                If JFC_XDL(Item_lpPtr).Item_saName[1]<>';' Then Begin
                  {$I-}
                  Writeln(f,JFC_XDL(Item_lpPtr).Item_saName+
                            JFC_XDL(Item_lpPtr).Item_saValue);
                  {$I+}
                End else Begin // write comment
                  {$I-}
                  Writeln(f,JFC_XDL(Item_lpPtr).Item_saName);
                  {$I+}
                End;
                bErr:=ioresult<>0;
              End;
            Until NOT JFC_XDL(Item_lpPtr).MoveNext;
          End;
          bErr:=ioresult<>0;
        End
        else
        Begin
          {$I-}
          Writeln(f);
          bErr:=ioresult<>0;
          {$I+}
        End;
      Until bErr OR (NOT movenext);
    End;
    {$I-}
    Writeln(f);      
    close(f);
    {$I+}
    bErr:=ioresult<>0;
  End;
  Result:=NOT bErr;
End;
//=============================================================================

//=============================================================================
Function JFC_INI.FoundSection(p_saSection: AnsiString):Boolean;
//=============================================================================
Begin
  //riteln(p_saSection,'JFC_INI:FOUNDSECTION:RAW:',FoundItem_saName(trim(p_saSection),false));
  Result:=FoundItem_saName(trim(p_saSection),False);
  //riteln('JFC_INI.FoundSection('+p_saSection+',false) returns:',result);
End;
//=============================================================================


//=============================================================================
Function JFC_INI.FoundKey(p_saSection, p_saKey: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=FoundSection(p_saSection) AND 
          JFC_XDL(Item_lpPtr).FoundItem_saName(trim(p_saKey),False);
End;
//=============================================================================


//=============================================================================
Function  JFC_INI.DeleteSection(p_saSection: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=FoundItem_saName(trim(p_saSection),False) AND DeleteItem;
End;
//=============================================================================


//=============================================================================
Function  JFC_INI.DeleteKey(p_saSection, p_saKey: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=(FoundItem_saName(trim(p_saSection),False)) AND 
          (JFC_XDL(Item_lpPtr).FoundItem_saName(trim(p_saKey),False)) AND
          JFC_XDL(Item_lpPtr).DeleteItem;
End;
//=============================================================================

//=============================================================================
Function  JFC_INI.ReadKey(
                    p_saSection, p_saKey: AnsiString;
                    Var p_saData: AnsiString):Boolean;
//=============================================================================
Begin
  Result:=FoundKey(trim(p_saSection), trim(p_saKey));
  If Result Then p_saData:=JFC_XDL(ITem_lpPtr).Item_saValue else p_saData:='';
End;
//=============================================================================

//=============================================================================
Function  JFC_INI.WriteKey(
  p_saSection, p_saKey: AnsiString;
  p_saData: AnsiString):Boolean;
//=============================================================================
Begin
  p_saSection:=trim(p_saSection);
  p_saKey:=Trim(p_saKey);
  Result:=(length(p_saSection)>0) AND (length(p_saKey)>0);
  If Result Then Begin
    If NOT FoundItem_saName(p_saSection,False) Then Begin
      AppendItem_saName_N_saValue(p_saSection,'');
    End;
    JFC_XDL(Item_lpPtr).AppendItem_saName_N_saValue(p_saKey,trim(p_saData));
  End;  
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
