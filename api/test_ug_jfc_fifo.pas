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
// Test the Jegas Foundation Class: JFC_FIfO
program test_ug_jfc_fifo;
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
  ug_jfc_fifo;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_FIFO Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
var
//=============================================================================
  rFIFOInit: rtFIFOInit;
  rFIFOItem: rtFIFOITEM;
  FIFO: JFC_FIFO;
  i: int;
  iMaxFifo: Int;
  uUID: UInt;
//=============================================================================


//=============================================================================
Begin // Main Program
//=============================================================================
  iMaxFifo:=8192*500;

  with rFifoInit do begin
    // FIFO JTMSG Queue Related
    iAllocationSize:=8192;
    iInitialNoOfAllocationUnits:=500;
    bAddAllocationUnitsWhenFIFOFull:=true;
    bAutoNumberUIDField:=true;// Only When UID=0 Will it make the new UID.
    bAutoRecordDateNTimeInSentField:=true;//Only when datetime=0 will it do this.
    //NOTE: For Both UID and DateTime "Auto" fill, Clearing a rtFIFOItem record
    // with ClearFIFOItem(MyFifoItem) will zero the UID and DateTime for you.
    
    // If ZERO, this has no effect, however if bAddAllocationUnitsWhenFIFOFull
    // (In essence GROW if full) is TRUE then this iMaximumAllowedAllocationUnits
    // allows you to set a restriction on the growth.
    iMaximumAllowedAllocationUnits:= 500;
  end;//with
  

  FIFO:=JFC_FIFO.create(rFIFOInit);
  //Writeln('FIFO.pvt_iSize(0):',FIFO.pvt_iSize);
  //writeln('FIFO.pvt_iAllocatedUnits(0):',FIFO.pvt_iAllocatedUnits);
  //writeln;
  
  
  
  writeln('Sending ',iMaxFifo,' Items.');
  for i:=1 to iMaxFifo do
  begin
    if not FIFO.bSend(rFIFOItem) then writeln('Send Fail');
  end;
  writeln('iAllocationUnitsNotInUse:',FIFO.iAllocationUnitsNotInUse);
  writeln;
  writeln('Its Loaded.. Read a key to pull them off the FIFO!');
  readln;
  
  
  uUID:=0;
  writeln('Receiving ',iMaxFifo,' Items.');
  for i:=1 to iMaxFifo do
  begin
    if not FIFO.bRecv(rFIFOItem) then writeln('Recv Fail');
    if(rFIFOItem.UID<=uUID)then writeln('!!!!!!!  UIDFAIL  !!!!!!!!');
    uUID:=rFIFOItem.UID;
  end;
  writeln('iAllocationUnitsNotInUse:',FIFO.iAllocationUnitsNotInUse);
  
  FIFO.bSend(rFIFOItem);
  Writeln('FIFO.pvt_iSize(0):',FIFO.pvt_iSize);
  writeln('FIFO.pvt_iAllocatedUnits(0):',FIFO.pvt_iAllocatedUnits);
  writeln;

  FIFO.bSend(rFIFOItem);
  Writeln('FIFO.pvt_iSize(0):',FIFO.pvt_iSize);
  writeln('FIFO.pvt_iAllocatedUnits(0):',FIFO.pvt_iAllocatedUnits);
  writeln;
  
  writeln('FIFO.bRecv(rFIFOItem):',FIFO.bRecv(rFIFOItem));
  writeln(rFIFOItem.UID);
  writeln('FIFO.bRecv(rFIFOItem):',FIFO.bRecv(rFIFOItem));
  writeln(rFIFOItem.UID);

  writeln('Items Left in FIFO:', FIFO.pvt_iItems);
  writeln('iAllocationUnitsNotInUse:',FIFO.iAllocationUnitsNotInUse);
  writeln('pvt_iSize:',FIFO.pvt_iSize);
  
  writeln('Reclaiming...');
  FIFO.iReclaimUnusedAllocationUnits(FIFO.iAllocationUnitsNotInUse);
  writeln('Items Left in FIFO:', FIFO.pvt_iItems);
  writeln('iAllocationUnitsNotInUse:',FIFO.iAllocationUnitsNotInUse);
  writeln('pvt_iSize:',FIFO.pvt_iSize);
  
  writeln('Max Messages in Queue Reached:',FIFO.MaximumNumberOfItemsReached);
  writeln('Max # Allocated Units Reached:',FIFO.MaximumNumberOfUnitsAllocated);
  writeln('SendFailures:',FIFO.SendFailures);
  



  writeln;
  writeln('Testing NON-GROW Mode. Size: 1. Will Try adding 2. Should FAIL on second attempt!');
  FIFO.Destroy;
  //constructor Create(
  //  p_iAllocationSize: integer;
  //  p_iInitialNoOfAllocationUnits: integer;
  //  p_bAddAllocationUnitsWhenFIFOFull: boolean;
  //  p_bAutoNumberUIDField: boolean;
  //  p_bAutoRecordDateAnTimeInSentField: boolean
  //);

  with rFifoInit do begin
    // FIFO JTMSG Queue Related
    iAllocationSize:=1;
    iInitialNoOfAllocationUnits:=1;
    bAddAllocationUnitsWhenFIFOFull:=false;
    bAutoNumberUIDField:=true;// Only When UID=0 Will it make the new UID.
    bAutoRecordDateNTimeInSentField:=true;//Only when datetime=0 will it do this.
    //NOTE: For Both UID and DateTime "Auto" fill, Clearing a rtFIFOItem record
    // with ClearFIFOItem(MyFifoItem) will zero the UID and DateTime for you.
    
    // If ZERO, this has no effect, however if bAddAllocationUnitsWhenFIFOFull
    // (In essence GROW if full) is TRUE then this uMaximumAllowedAllocationUnits
    // allows you to set a restriction on the growth.
    iMaximumAllowedAllocationUnits:=0;
  end;//with
  FIFO:=JFC_FIFO.create(rFifoInit);
 
  if(FIFO.bSend(rFIFOItem))then writeln('Send #1 Worked!')else writeln('Send #1 FAILED!');
  Writeln('FIFO.pvt_iSize(0):',FIFO.pvt_iSize);
  writeln('FIFO.pvt_uAllocatedUnits(0):',FIFO.pvt_iAllocatedUnits);
  writeln;

  if(FIFO.bSend(rFIFOItem))then writeln('Send #2 Worked!')else writeln('Send #2 FAILED!');
  Writeln('FIFO.pvt_iSize(0):',FIFO.pvt_iSize);
  writeln('FIFO.pvt_iAllocatedUnits(0):',FIFO.pvt_iAllocatedUnits);
  writeln;
  
  writeln;
  writeln('Will Try receiving 2. Should FAIL on second attempt!');
  
  writeln('FIFO.bRecv(rFIFOItem):',FIFO.bRecv(rFIFOItem));
  writeln(rFIFOItem.UID);
  writeln('FIFO.bRecv(rFIFOItem):',FIFO.bRecv(rFIFOItem));
  writeln(rFIFOItem.UID);

  writeln('Max Messages in Queue Reached:',FIFO.MaximumNumberOfItemsReached);
  writeln('Max # Allocated Units Reached:',FIFO.MaximumNumberOfUnitsAllocated);
  writeln('SendFailures:',FIFO.SendFailures);
  FIFO.Destroy;FIFO:=nil;
  Writeln;
  Writeln('Regression Test Next. Open Task Man and Watch Memory Each go Around.');
  
  with rFifoInit do begin
    // FIFO JTMSG Queue Related
    iAllocationSize:=8192;
    iInitialNoOfAllocationUnits:=500;
    bAddAllocationUnitsWhenFIFOFull:=true;
    bAutoNumberUIDField:=true;// Only When UID=0 Will it make the new UID.
    bAutoRecordDateNTimeInSentField:=true;//Only when datetime=0 will it do this.
    //NOTE: For Both UID and DateTime "Auto" fill, Clearing a rtFIFOItem record
    // with ClearFIFOItem(MyFifoItem) will zero the UID and DateTime for you.
    
    // If ZERO, this has no effect, however if bAddAllocationUnitsWhenFIFOFull
    // (In essence GROW if full) is TRUE then this iMaximumAllowedAllocationUnits
    // allows you to set a restriction on the growth.
    iMaximumAllowedAllocationUnits:= 50;
  end;//with
  FIFO:=JFC_FIFO.create(rFIFOInit);
  for i:=1 to 8192*500 do FIFO.bSend(rFifoItem);
  Write('Look at the Ram. then Press Enter ');
  readln;
  FIFO.iReclaimUnusedAllocationUnits(FIFO.iAllocationUnitsNotInUse);
  Write('Look at the Ram Now. Press enter to continue. ');
  readln;
  
  FIFO.Destroy;FIFO:=nil;
  Writeln;
  Write('Press Enter To End This Program:');
  readln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************


