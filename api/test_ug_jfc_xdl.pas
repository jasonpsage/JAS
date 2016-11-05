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
// Test the Jegas Foundation Class: JFC_XDL
program test_ug_jfc_xdl;
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
  ug_jfc_xdl;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_XDL Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
function test_JFC_xdl:boolean;
//=============================================================================
var 
  XDL: JFC_XDL;
  XDLC: JFC_XDL;
  SNR: JFC_XDL;
  saSend: AnsiString;
  saReceived: AnsiString;

  // For Nested XDL Deletion Test.
  XDL1: JFC_XDL;
  XDL2: JFC_XDL;
  XDL3: JFC_XDL;
  XDL4: JFC_XDL;
  
label jumphere;

Begin
  Result:=true;
  XDL:=JFC_XDL.create;
  //Writeln('Got past XDL Init');
  XDLC:=JFC_XDL.CreateCopy(XDL);
  //Writeln('Got past XDLC Init');
  if Result then result:=XDL.BOL;
  if Result then result:=XDL.EOL;
  if Result then result:=XDL.Listcount=0;
  if not Result then Begin
    Writeln('Problem With XDL After Init');
    goto jumphere;
  End;
  //Writeln('Got past XDL Test Batch 1');

  if Result then XDLC.Sync(XDL);
  if Result then result:=XDLC.BOL;
  if Result then result:=XDLC.EOL;
  if Result then result:=XDLC.Listcount=0;
  if not Result then Begin
    Writeln('Problem With XDLC After Init');
    goto jumphere;
  End;
  //Writeln('Got past XDL Test Batch 2');

  XDL.AppendItem;
  //Writeln('Got past XDL Test AppendItem');  
  XDL.Item_lpPtr:=pointer(1);
  //Writeln('Got past XDL Test AppendItem lpPtr=');  
  XDL.Item_saName:='John';
  //Writeln('Got past XDL Test AppendItem Item_saName=');  
  XDL.Item_saDesc:='DESCJohn';
  //Writeln('Got past XDL Test AppendItem saDesc=');  
  
  
  if Result then result:=XDL.BOL;
  //if not Result then Writeln('BOL');
  
  if Result then result:=XDL.EOL;
  //if not Result then Writeln('EOL');
  
  if Result then result:=XDL.Listcount=1;
  //if not Result then Writeln('Listcount');
  
  if Result then result:=XDL.Item_lpPtr=pointer(1);
  //if not Result then Writeln('lpPtr');
  
  if Result then result:=XDL.Item_saName='John';
  //if not Result then Writeln('Item_saName:',XDL.Item_saName);
  
  if Result then result:=XDL.Item_saDesc='DESCJohn';
  //if not Result then Writeln('saDesc');
  
  if not Result then Writeln('Problem With XDL After First AppendItem');
  if not Result then goto jumphere;
  //Writeln('Got past XDL Test Batch 3');  
  
  if Result then XDLC.Sync(XDL);
  //Writeln(result);
  if Result then result:= XDLC.BOL;
  //Writeln(result);
  if Result then result:= XDLC.EOL;
  //Writeln(result);
  if Result then result:=XDLC.Listcount=1;
  //Writeln(result);
  if Result then result:=XDLC.Item_lpPtr=pointer(1);
  //Writeln(result);
  if Result then result:=XDLC.Item_saName='John';
  //Writeln(result);
  if Result then result:=XDLC.Item_saDesc='DESCJohn';
  //Writeln(result);
  if not Result then Writeln('Problem With XDLC After First AppendItem');
  if not Result then goto jumphere;
  //Writeln('Got past XDL Test Batch 4');  

  XDL.AppendItem; 
  XDL.Item_saName:='JOHN';
  XDL.Item_saDesc:='DESCJOHN';
  XDL.Item_lpPtr:=pointer(1);
  //Writeln('Got past XDL AppendItem 2');  

  XDL.AppendItem; 
  XDL.Item_saName:='Larry';
  XDL.Item_saDesc:='DESCLarry';
  XDL.Item_lpPtr:=pointer(3);
  //Writeln('Got past XDL AppendItem 3');  

  XDL.AppendItem; 
  XDL.Item_saName:='John';
  XDL.Item_saDesc:='DESCJohn';
  XDL.Item_lpPtr:=pointer(4);
  //Writeln('Got past XDL AppendItem 4');  
  
  Writeln('Got past XDL Test AppendItem Group');  
  

  if Result then result:=XDL.FoundItem_uID(1);
  if Result then result:=XDL.FoundItem_uID(2);
  if Result then result:=XDL.FoundItem_uID(3);
  if Result then result:=XDL.FoundItem_uID(4);
  if Result then result:=not XDL.FoundItem_uID(5);
  if not Result then Writeln('Problem With XDL FoundItem_uID Search');
  if not Result then goto jumphere;
  Writeln('Got past XDL Test Batch 5');  
  
  if Result then result:=XDL.FoundItem_lpPtr(pointer(1));
  if not Result then Writeln('Problem With XDL FoundItem_lpPtr Search');

  Writeln('founditem_lpptr - test1');

  if not Result then goto jumphere;
  if Result then result:=XDL.FNextItem_lpPtr(pointer(1));
  if not Result then Writeln('Problem With XDL FNextItem_lpPtr Search');

  if not Result then goto jumphere;
  if Result then result:=not XDL.FNextItem_lpPtr(pointer(1));
  if not Result then Writeln('Problem With XDL FNextItem_lpPtr Search(2)');
  if not Result then goto jumphere;
  Writeln('Got past XDL Test Batch 6');  

  if Result then result:=XDL.FoundItem_saName('John',true);
  if Result then result:=XDL.FNextItem_saName('John',true);
  //Writeln(XDL.EOL);
  if Result then result:=not XDL.FNextItem_saName('John',true);
  //Writeln(XDL.EOL);
  if Result then result:=not XDL.FNextItem_saName('John',true);
  //Writeln(XDL.EOL);
  //Writeln('Testing - You see logfile?');
  //readln;
  Writeln('Got past XDL Test Batch 8');  
  if not Result then Writeln('Problem With XDL FoundItem_saName CaseSensitive Search');
  if not Result then goto jumphere;
  
  if Result then result:=XDL.FoundItem_saName('John',false);
  if Result then result:=XDL.FNextItem_saName('John',false);
  if Result then result:=XDL.FNextItem_saName('John',false);
  if Result then result:=not XDL.FNextItem_saName('John',false);
  if Result then result:=not XDL.FNextItem_saName('John',false);
  if not Result then Writeln('Problem With XDL FoundItem_saName Non-CaseSensitive Search');
  if not Result then goto jumphere;
  
  if Result then result:=XDL.FoundItem_saDesc('DESCJohn',true);
  if Result then result:=XDL.FNextItem_saDesc('DESCJohn',true);
  //Writeln(XDL.EOL);
  if Result then result:=not XDL.FNextItem_saDesc('DESCJohn',true);
  //Writeln(XDL.EOL);
  if Result then result:=not XDL.FNextItem_saDesc('DESCJohn',true);
  //Writeln(XDL.EOL);
  if Result then result:=not XDL.FNextItem_saDesc('DESCJohn',true);
  //Writeln('Testing - You see logfile?');
  //readln;
  if not Result then Writeln('Problem With XDL FNextItem_saDesc CaseSensitive Search');
  if not Result then goto jumphere;
  
  Writeln('Got past XDL Test Batch 9');  
  if Result then result:=XDL.FoundItem_saDesc('DESCJohn',false);
  if Result then result:=XDL.FNextItem_saDesc('DESCJohn',false);
  if Result then result:=XDL.FNextItem_saDesc('DESCJohn',false);
  if Result then result:=not XDL.FNextItem_saDesc('DESCJohn',false);
  if Result then result:=not XDL.FNextItem_saDesc('DESCJohn',false);
  if not Result then Writeln('Problem With XDL FNextItem_saDesc Non-CaseSensitive Search');
  if not Result then goto jumphere;

  
  if Result then result:=XDL.FoundItem_uID(2);
  Writeln('Got past XDL Test Batch 10');  
  if Result then XDL.DeleteItem;
  if Result then XDL.DeleteItem;
  Writeln('Got past XDL Test Batch 11');  
  if Result then XDLC.Sync(XDL);
  
  if Result then result:=XDLC.ListCount=XDL.ListCount;
  if not Result then Writeln('Problem With XDL Syncronization');
  if not Result then goto jumphere;

  if result then Begin// saSNR Test
    SNR:=JFC_XDL.Create;
    //Writeln('Testing saSNR - Case Sensitive ...');
    result:=SNR.AppendItem_SNRPair('Who','Jason');
    if not result then Writeln('AppendItem(name,desc) failed to return true');
    if result then result:=SNR.AppendItem_SNRPair('when','tomorrow');
    if result then result:=SNR.listcount=2;
    if not result then Writeln('JFC_XDL AppendItem or Listcount failing!');
    
    saSend:='Who will go when.';
    saReceived:=SNR.SNR(saSend,true);
    result:= saReceived='Jason will go tomorrow.';
    //Writeln('Sent:',saSend);
    //Writeln('Recieved:', saReceived);
    if not result then Writeln('JFC_XDL.saSNR Non Case sensitive search FAILED!');
    
    if result then
    Begin
      //Writeln('Testing saSNR - NOT Case Sensitive ...');
      saSend:='WHO will go WHEN.';
      saReceived:=SNR.SNR(saSend,false);
      result:= saReceived='Jason will go tomorrow.';
      //Writeln('Sent:',saSend);
      //Writeln('Recieved:', saReceived);
      if not result then Writeln('JFC_XDL.saSNR Case sensitive search FAILED!');
    End;
    SNR.Destroy;SNR:=nil;
  End;

  
  XDL1:=JFC_XDL.Create;
  XDL1.bDestroyNestedLists:=true;
    XDL2:=JFC_XDL.Create;
    XDL2.bDestroyNestedLists:=true;
      XDL3:=JFC_XDL.Create;
      XDL3.bDestroyNestedLists:=true;
        XDL4:=JFC_XDL.Create;
        XDL4.bDestroyNestedLists:=true;
      XDL3.AppendItem_lpPtr(XDL4);
    XDL2.AppendItem_lpPtr(XDL3);
  XDL1.AppendItem_lpPtr(XDL2);
  XDL1.Destroy;
  XDL1:=nil;
  // If it didn't crash - it likely worked :)
  




JumpHere:
  //Writeln('about to kill XDLC');
  XDLC.destroy;
  XDL.Destroy;
  //Writeln('XDL Tests Passed:',Result);
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
    bResult:=test_JFC_XDL;
    Writeln('JFC_XDL Test Result:',bresult);
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

  
