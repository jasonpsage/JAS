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
// Test the Jegas Foundation Class: JFC_DL
program test_uxxg_jfc_dl;
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
  sysutils,
  ug_JFC_dl;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_BASE Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
type TI = class(JFC_DLITEM)
//=============================================================================
  public 
    UID: LongWord;
    u4FindMe: LongWord;
    saText: AnsiString;
    u4SortMe: LongWord;
    u8Findthat: UInt64;
    i8FindThat: Int64;
End;
//=============================================================================








//=============================================================================
type TDL = class(JFC_DL)
//=============================================================================
  // Routines You want to OVERRIDE if you use a child class of TItem
  //---------------------------------------------------------------------------
  function pvt_CreateItem: TI; override;
  //---------------------------------------------------------------------------
  procedure pvt_DestroyItem(p_lp:pointer); override;
  //---------------------------------------------------------------------------
  //function SwapResult(p_lp1, p_lp2: pointer): boolean;
End;
//=============================================================================

{
function SwapResult(p_lp1, p_lp2: pointer): boolean;
Begin
  Write('(',byte(p_lp1^),'>',byte(p_lp2^),'=');
  result:=byte(p_lp1^)>byte(p_lp2^);
  if result then Write('TRUE)');
End;
}

//=============================================================================
function tDL.pvt_createitem:ti;
//=============================================================================
Begin
  //Writeln('Created TDL ITem');
  result:=ti.create;
  TI(RESULT).UID:=AutoNumber;
End;
//=============================================================================

//=============================================================================
procedure tDL.pvt_destroyitem(p_lp:pointer);
//=============================================================================
Begin
  //Writeln('tl item destroyed');
  ti(p_lp).destroy;
End;
//=============================================================================

// Future: Could add a lot more tests...
//=============================================================================
function test_JFC_DL: boolean;
var L: tDL;
    LC: tDL;
    findthis: LongWord;
    i8findthat: Int64;
    u8findthat: UInt64;
    t: integer;
    
Begin
  //Writeln('Testing (SOME OF) JFC_DL Class...');
  result:=false;
  
  Write('JFC_DL - Wave 1...(Making 1 Million item Linked List!)');
  l:=tDL.create;
  lc:=tDL.createcopy(l);
  
{
  Writeln('Size tdl:',sizeof(l));
  Writeln('Memavail',memavail);
  Writeln('Append Returned:',L.AppendItem);
  Writeln('ListCount:',L.listcount);
  Writeln('Memavail with it in mem',memavail);
  Writeln('DElete Returned:',L.DeleteItem);
  Writeln('ListCount:',L.listcount);
  Writeln('Memavail',memavail);
  Writeln('DEBUG Pause');
  readln;
}  
 
  randomize;
  for t:=1 to 1000000 do
  Begin
    L.AppendItem;
    ti(l.lpitem).u4findme:=t;  
    ti(l.lpitem).saText:=inttostr(t);
    ti(l.lpItem).u4SortMe:=random(100);
    ti(l.lpItem).lpPtr:=pointer(UInt64(random(100)));
    ti(l.lpItem).u8FindThat:=t;
    ti(l.lpItem).i8FindThat:=t;
  End;
  Writeln('List Made.');
  result:=L.ListCount=1000000;
  if not result then Writeln('JFC_DL Error - Wrong ListCount') else
  Begin
    Writeln('ListCount Checked...');
    lc.Sync(l);
    Writeln('Sync Called...');
    result:=Lc.ListCount=1000000;
    Writeln('Copy ListCount Checked...');
    if not result then Writeln('JFC_DL Error - Syncronization Error') else
    Begin
      Writeln('FoundBinary 1');
      findthis:=500000;
      result:=l.FoundBinary(@findthis, sizeof(findthis), @ti(nil).u4FindME,true,false);
      if not result then Writeln('JFC_DL Error - FoundBinary 1') else
      Begin
        Writeln('FoundBinary 2 (In DL Copy)');
        findthis:=30000;
        result:=lc.FoundBinary(@findthis, sizeof(findthis), @ti(nil).u4FindME,true,false);
        if not result then Writeln('FoundBinary 2 (In DL Copy)') else
        Begin
          Writeln('FoundBinary 3 (64bit Int)');
          i8findthat:=20000;
          result:=l.FoundBinary(@i8findthat, sizeof(i8findthat), @ti(nil).i8FindThat,true,false);
          if not result then Writeln('FoundBinary 3 (64bit Int)') else
          Begin
            i8findthat:=30000;
            Writeln('FoundBinary 4 (64bit Int - In DL Copy)');
            result:=lc.FoundBinary(@i8findthat, sizeof(i8findthat), @ti(nil).i8findthat,true,false);
            if not result then Writeln('FoundBinary 4 (64bit Int - In DL Copy)') else
            Begin
              Writeln('FoundBinary 5 (64bit Int)');
              u8findthat:=20300;
              result:=l.FoundBinary(@u8findthat, sizeof(u8findthat), @ti(nil).u8FindThat,true,false);
              if not result then Writeln('FoundBinary 5 (64bit UInt)') else
              Begin
                u8findthat:=30300;
                Writeln('FoundBinary 6 (64bit Int - In DL Copy)');
                result:=lc.FoundBinary(@u8findthat, sizeof(u8findthat), @ti(nil).u8findthat,true,false);
                if not result then Writeln('FoundBinary 6 (64bit UInt - In DL Copy)') else
                Begin
                  // So Far so good ;)
                End;
              end;
            End;
          end;
        End;
      End; 
    End;
  End;








  if result then
  begin
    Writeln('FoundAnsistring 1');
    result:= l.FoundAnsiString('500000', false, @ti(nil).saText,true,false);
    if not result then Writeln('JFC_DL Error - FoundAnsiString Function') else
    Begin
      result:= lc.FoundAnsiString('500000', false, @ti(nil).saText,true,false);
      Writeln('FoundAnsistring 2 (In DL Copy)');
      if not result then Writeln('JFC_DL Error - FoundAnsiString Function in Copy') else
      Begin
        // Looks Pretty Good so far
      End;
    End;
  end;

  //Writeln('Wave 2...');
  if result then Begin
    for t:=1 to 500000 do l.DeleteItem;
    result:=l.listcount=500000;
    if not result then Writeln('JFC_DL Error - DeleteItem') else
    Begin
      for t:=1 to 500000 do l.InsertItem;
      result:=L.ListCount=1000000;
      if not result then Writeln('JFC_DL Error - InsertItem') else
      Begin
        Writeln('Preparing for next Test...The SLOW SORT! ');
        Writeln('Swaps Actual Linked List Nav Pointers and its BubbleSort');
        for t:=1 to 995000 do l.DeleteItem;
        Writeln('Sorting ',l.listcount, ' items.');
        Write('Not Sorted Yet:');
        for t:=1 to 10 do Begin
          l.FoundNth(t);
          Write(ti(l.lpITem).u4SortMe,' ');
        End;
        Writeln;
        //Writeln('Waiting...');
        //readln;
        Writeln('Sorting...');
        result:=L.SortBinary(sizeof(LongWord),@ti(nil).u4SortMe, true,false);
        //result:=L.bSortBinary(@ti(nil).u1SortMe, @SwapResult);
        Writeln; // temp
        if not result then Writeln('JFC_DL Error - bSortBinary Fucntion') else
        Begin
          Write('       Sorted :');
          l.movefirst;
          for t:=1 to 10 do Begin
            l.FoundNth(t);
            Write(ti(l.lpITem).u4SortMe,' ');
          End;
          Writeln;
          // Next Test here
          Writeln('Preparing for next Test...The Better SLOW SORT! ');
          Writeln('Swaps ONLY Pointers In each JFC_DLITEM ... Still a BubbleSort Though');
          Writeln('Sorting ',l.listcount, ' items.');
          Write('Not Sorted Yet:');
          for t:=1 to 10 do Begin
            l.FoundNth(t);
            Write(INT(ti(l.lpItem).lpPtr),' ');
          End;
          Writeln;
          //Writeln('Waiting...');
          //readln;
          Writeln('Sorting...');
          result:=L.SortBinary(sizeof(pointer),@ti(nil).lpPtr, true,false);
          //result:=L.bSortBinary(@ti(nil).u1SortMe, @SwapResult);
          Writeln; // temp
          if not result then Writeln('JFC_DL Error - bSortBinary Fucntion') else
          Begin
            Write('       Sorted :');
            l.movefirst;
            for t:=1 to 10 do Begin
              l.FoundNth(t);
              Write(INT(ti(l.lpITem).lpPtr),' ');
            End;
            Writeln;

            l.deleteall;
            result:=L.ListCount=0;
            if not result then Writeln('JFC_DL Error - DeleteAll') else
            Begin
              // NExt test here
             //cool!
            End;
          End;  
        End;              
      End;
    End;
  End;



  lc.destroy;
  
  
  l.destroy;
  
{  
  l.movefirst;
  
  
  findthis:=20;
  if l.Found(@findthis, sizeof(findthis), @ti(l.lpitem).u4FindME) then
  Writeln('cool')
  else
  Writeln('prob');
  
  if l.FoundStr('3Text', false, @ti(l.lpitem).saText) then
  Writeln('cool')
  else
  Writeln('prob');
  


  Writeln('u4FindMe:',ti(l.lpitem).u4findme);
  l.destroy;
  Writeln('did it');
  readln;
}
End;
//=============================================================================
  



















//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_DL Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
function test_JFC_DL2: boolean;
//=============================================================================
var DL: JFC_DL;
    DLC: JFC_DL;
//    t: integer;

label jumphere;
Begin
  Writeln('Made it here 0');
  
  
  Result:=true;
  DL:=JFC_DL.Create;
  DLC:=JFC_DL.CreateCopy(DL);
  
  Writeln('Made it here 1');
  
  if Result then result:=DL.BOL;
  if Result then result:=DL.EOL;
  if Result then result:=DL.Listcount=0;
  if not Result then Begin
    Writeln('Problem With DL After Init');
    goto jumphere;
  End;
  
  Writeln('Made it here 2');
  
  
  DLC.Sync(DL);
  Writeln('Past Sync');
  
  if Result then result:=DLC.BOL;
  if Result then result:=DLC.EOL;
  if Result then result:=DLC.Listcount=0;
  if not Result then Begin
    Writeln('Problem With DLC After Init');
    goto jumphere;
  End;
  
  Writeln('Append?');
  result:=DL.AppendItem;
  Writeln('Past Append');
  if not result then Begin
    Writeln('Error with first DL.bAppend');
    goto jumphere;
  End;
  
  Writeln('Made it here 3');
  
  DL.Item_lpPtr:=pointer(1);//same as JFC_DLITEM(lpItem).lpPtr:=pointer(1);
    
  Writeln('Made it here 4');
  
  if Result then Begin
    result:=DL.BOL;
    if not Result then Begin
      Writeln('Problem With DL After First AppendItem - BOL');
      goto jumphere;
    End;
  End;
  
  if Result then Begin
    result:=DL.EOL;
    if not Result then Begin
      Writeln('Problem With DL After First AppendItem - EOL');
      goto jumphere;
    End;
  End;
  
  Writeln('Made it here');
  
  
  if Result then Begin
    result:=DL.Listcount=1;
    if not Result then Begin
      Writeln('Problem With DL After First AppendItem - ListCount');
      goto jumphere;
    End;
  End;
  
  
  result:=DL.Item_lpPtr=pointer(1);
  if not Result then Begin
    Writeln('Problem With DL After First AppendItem - lpPtr');
    goto jumphere;
  End;
  
  Writeln('Made it here');
  
  DLC.Sync(dl);
  result:=DLC.BOL and 
          DLC.EOL and 
          (DLC.Listcount=1) and
          (DLC.Item_lpPtr=pointer(1));
  if not Result then Begin
    Writeln('Problem With DLC After First AppendItem');
    goto jumphere;
  End;
  
  DL.AppendItem; 
  DL.Item_lpPtr:=pointer(1);
  
  DL.AppendItem; 
  DL.Item_lpPtr:=pointer(3);

  DL.AppendItem; 
  DL.Item_lpPtr:=pointer(4);

  Dl.MoveFirst;
  if Result then result:=DL.EOL<>true;
  if not Result then Writeln('Problem With DL EOL');
  if not Result then goto jumphere;

  
  if Result then result:=DL.FoundItem_lpPtr(pointer(1));
  if not Result then Writeln('Problem With DL FoundItem_lpPtr Search');
  if not Result then goto jumphere;

  if Result then result:=(DL.FNextItem_lpPTR(pointer(1))) and (DL.N=2);
  {
  if not result then
  Begin
    sagelog(1,'Current Item: ' + 'N:'+inttostr(DL.N)+' '+
                'lpPtr:'+inttostr(integer(DL.Item_lpPtr)) + ' ');
    DL.MoveFirst;
    for t:=1 to DL.ListCount do Begin
      SageLog(1,'N:'+inttostr(DL.N)+' '+
                'lpPtr:'+inttostr(integer(DL.Item_lpPtr)) + ' ');
      DL.MoveNext;
    End;
  End;
  }
  if not Result then Writeln('Problem With DL FNextItem_lpPtr Search');
  if not Result then goto jumphere;

  if Result then result:=not DL.FNextItem_lpPTR(pointer(1));
  {
  if not result then
  Begin
    sagelog(1,'Current Item: ' + 'N:'+inttostr(DL.N)+' '+
                'lpPtr:'+inttostr(integer(DL.Item_lpPtr)) + ' ');
    DL.MoveFirst;
    for t:=1 to DL.ListCount do Begin
      SageLog(1,'N:'+inttostr(DL.N)+' '+
                'lpPtr:'+inttostr(integer(DL.Item_lpPtr)) + ' ');
      DL.MoveNext;
    End;
  End;
  }

Writeln('Made it here');
  

  if not Result then Writeln('Problem With DL FNextItem_lpPtr Search(2)');
  if not Result then goto jumphere;
  
  if Result then DL.DeleteItem;
  if Result then DL.DeleteItem;
  if Result then DLC.Sync(pointer(DL));
  if Result then result:=DLC.ListCount=DL.ListCount;
  if not Result then Writeln('Problem With DL Syncronization');
  if not Result then goto jumphere;
  
  
JumpHere:
  DLC.Destroy;
  DL.Destroy;
//  Writeln('DL Tests Passed:',Result);
End;
//=============================================================================

//=============================================================================
function test_JFC_DL3: boolean;
//=============================================================================
var L: tDL;
Begin
  L:=TDL.Create;
  
  
  // TEST 1 - NOT Case Sensitive, Ascending, NOT using PTR
  L.AppendItem;
  TI(L.lpItem).saText:='ZTOP';
  L.AppendItem;
  TI(L.lpItem).saText:='bMIDDLE';
  L.AppendItem;
  TI(L.lpItem).saText:='ABOTTOM';
  L.SortAnsistring(false,@TI(nil).saText,true,false);
  L.MoveFirst;
  result:=TI(L.lpItem).saText='ABOTTOM';
  if result then Begin
    L.MoveNExt;
    result:=TI(L.lpItem).saText='bMIDDLE';
    if result then Begin
      L.MoveLast;
      result:=TI(L.lpItem).saText='ZTOP';
    End;
  End;
  
  if result then Begin
    // TEST 2 - Case SENSITIVE, Ascending, NOT using PTR
    L.DeleteAll;
    L.AppendItem;
    TI(L.lpItem).saText:='ZTOP';
    L.AppendItem;
    TI(L.lpItem).saText:='amiddle';
    L.AppendItem;
    TI(L.lpItem).saText:='ABOTTOM';
    L.SortAnsistring(true,@TI(nil).saText,true,false);
    L.MoveFirst;
    result:=TI(L.lpItem).saText='ABOTTOM';
    if result then Begin
      L.MoveNExt;
      result:=TI(L.lpItem).saText='ZTOP';
      if result then Begin
        L.MoveLast;
        result:=TI(L.lpItem).saText='amiddle';
      End;
    End;
  End;

  if result then Begin
    // TEST 3 - NOT Case SENSITIVE, DESCENDING, NOT using PTR
    L.DeleteAll;
    L.AppendItem;
    TI(L.lpItem).saText:='ZTOP';
    L.AppendItem;
    TI(L.lpItem).saText:='bMIDDLE';
    L.AppendItem;
    TI(L.lpItem).saText:='ABOTTOM';
    L.SortAnsistring(false,@TI(nil).saText,false,false);
    L.MoveFirst;
    result:=TI(L.lpItem).saText='ZTOP';
    if result then Begin
      L.MoveNExt;
      result:=TI(L.lpItem).saText='bMIDDLE';
      if result then Begin
        L.MoveLast;
        result:=TI(L.lpItem).saText='ABOTTOM';
      End;
    End;
  End;


  if result then Begin
    // TEST 3 - Case SENSITIVE, DESCENDING , NOT using PTR
    L.DeleteAll;
    L.AppendItem;
    TI(L.lpItem).saText:='ZTOP';
    L.AppendItem;
    TI(L.lpItem).saText:='amiddle';
    L.AppendItem;
    TI(L.lpItem).saText:='ABOTTOM';
    L.SortAnsistring(true,@TI(nil).saText,false ,false);
    L.MoveFirst;
    result:=TI(L.lpItem).saText='amiddle';
    if result then Begin
      L.MoveNExt;
      result:=TI(L.lpItem).saText='ZTOP';
      if result then Begin
        L.MoveLast;
        result:=TI(L.lpItem).saText='ABOTTOM';
      End;
    End;
  End;


  // Not writing Using pointer tests now cuz in hurry ONE and
  // TWO its the Same Code with a different offset


  if not result then Begin
    L.MoveFirst;
    repeat
      Writeln(TI(L.lpItem).saText);
    until not L.MoveNExt;
  End;



  L.Destroy;
End;
//=============================================================================





//=============================================================================
// Specifically Test the new bDestroyNestedLists property
function test_JFC_DL4: boolean;
//=============================================================================
var 
  DL1: JFC_DL; // Use For Level 1
  DL2: JFC_DL; // Use For Level 1
  DL3: JFC_DL; // Use For Level 1
  DL4: JFC_DL; // Use For Level 1
  

Begin
  DL1:=JFC_DL.Create;
  DL1.bDestroyNestedLists:=true;
    DL2:=JFC_DL.Create;
    DL2.bDestroyNestedLists:=true;
      DL3:=JFC_DL.Create;
      DL3.bDestroyNestedLists:=true;
        DL4:=JFC_DL.Create;
        DL4.bDestroyNestedLists:=true;
      DL3.AppendItem_lpPtr(DL4);
    DL2.AppendItem_lpPtr(DL3);
  DL1.AppendItem_lpPtr(DL2);
  DL1.Destroy;
  DL1:=nil;
  // If it didn't crash - it likely worked :)
  result:=true;
End;
//=============================================================================






var bResult: boolean;
//=============================================================================
Begin // Main Program
//=============================================================================
  bresult:=true;
  Writeln('Please Wait - Slamming da code!');
  
  
  if bResult then
  Begin
    bResult:=test_JFC_DL;
    //if bresult then begin
    //  Write('Press Enter to slamm that again');
    //  readln;
    //  bresult:=test_JFC_DL;
    //end;
    Writeln('JFC_DL Test 1 Result:',bresult);
  End;
  
  
  if bResult then
  Begin
    bResult:=test_JFC_DL2;
    Writeln('JFC_DL Test2 Result:',bresult);
  End;
  
  if bResult then
  Begin
    bResult:=test_JFC_DL3;
    Writeln('JFC_DL Test3 (Ansistring Sorts):',bresult);
  End;
  
  if bResult then
  Begin
    bResult:=test_JFC_DL4;
    Writeln('JFC_DL Test4 (Test Nested JFC_DL Cleanup):',bresult);
  End;


  Writeln;
  Write('Press Enter To End This Program:');
  readln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

