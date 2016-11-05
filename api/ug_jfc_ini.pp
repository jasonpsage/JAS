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
{ }
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
  sClassName:='JFC_INI';
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
  //JFC_XDL(Item_lpPtr).sClassName:='JFC_XDL (JFC_INI Item)';
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
    bOk: Boolean;
    u2IOResult: word;
    sa: AnsiString;
    iLen: Int;
    iEq: Int; // Position of First EqualSign
    bInSection: Boolean;
    ic: Int; // Position of first Semicolon
Begin
  bOk:=true;u2IOResult:=0;
  assign(f, p_saFileNPath);
  try reset(f); except on E:Exception do u2IOResult:=60000;end;//try
  u2IOREsult+=ioresult;
  bOk:=u2IOResult=0;
  if bOk then
  begin
    bInSection:=False;
    While (bOk) AND (NOT Eof(f)) Do Begin
      try readln(f, sa); except on E:Exception do u2IOResult:=60000;end;//try
      u2IOResult+=ioResult;
      bOk:= u2IOResult = 0 ;
      if bOk then
      begin
        iLen:=length(sa);
        ieq:=pos('=',sa);
        ic:=pos(';',sa);
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
    try Close(f); except on E:Exception do ; end;//try
    {$I+}
  End;
  result:=bOk;
End;
//=============================================================================

//=============================================================================
Function  JFC_INI.SaveIniFile(p_saFileNPath: AnsiString):Boolean;
//=============================================================================
Var bOk: Boolean;
    F: text;
    u2IOResult:Word;
Begin
  Result:=False;u2IOResult:=0;
  assign(f, p_saFileNPath);
  try rewrite(f); except on e:exception do u2IOResult:=60000;end;//try
  u2IOResult+=ioResult;
  bOk:=u2IOResult=0;
  If bOk then
  begin
    If ListCount>0 Then
    Begin
      moveFirst;
      repeat
        Item_saName:=trim(item_saname);
        Item_saValue:=trim(item_saValue);
        If length(Item_saName)>0 Then
        Begin
          try Writeln(f,Item_saName); Except on E:Exception do u2IOResult:=60000;end;//try
          u2IOResult+=ioresult;
          if bOk AND (JFC_XDL(Item_lpPtr).ListCount>0) Then
          Begin
            JFC_XDL(Item_lpPtr).MoveFirst;
            repeat 
              JFC_XDL(Item_lpPtr).Item_saName:=trim(JFC_XDL(Item_lpPtr).Item_saName);
              JFC_XDL(Item_lpPtr).Item_saValue:=trim(JFC_XDL(Item_lpPtr).Item_saValue);
              If length(JFC_XDL(Item_lpPtr).Item_saName)>0 Then
              Begin
                If JFC_XDL(Item_lpPtr).Item_saName[1]<>';' Then
                Begin
                  try Writeln(f,JFC_XDL(Item_lpPtr).Item_saName+JFC_XDL(Item_lpPtr).Item_saValue);Except on E:Exception do u2IOResult:=60000;end;//try
                  u2IOResult+=ioresult;
                End
                else
                Begin // write comment
                  try Writeln(f,JFC_XDL(Item_lpPtr).Item_saName);Except on E:Exception do u2IOResult:=60000;end;//try
                  u2IOResult+=ioresult;
                End;
              End;
              bOk:=u2IOResult=0;
            Until (not bOk) or (NOT JFC_XDL(Item_lpPtr).MoveNext);
          End;
          bOk:=u2IOResult=0;
        End
        else
        Begin
          {$I-}
          try Writeln(f);Except on E:Exception do u2IOResult:=60000;end;//try
          bOk:=u2IOResult=0;
          {$I+}
        End;
      Until not (bOk and movenext);
    End;
    {$I-}
    if bOk then try Writeln(f);Except on E:Exception do u2IOResult:=60000;end;//try
    try close(f);Except on E:Exception do ;end;//try
    {$I+}
  End;
  Result:=bOk;
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
