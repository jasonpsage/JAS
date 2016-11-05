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
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_fifo.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
{ }
// Dynamic FIFO Messaging Queue
Unit ug_jfc_fifo;
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
sysutils;
//=============================================================================





//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!rtFIFOItem - The Items the FIFO Tracks - Intended for general messaging
//*****************************************************************************

//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// The Data Structure for our FIFO Message Queue's messages.
Type rtFIFOItem=record // Jegas Thread(safe) Message
//=============================================================================
  UID: UINT;//< Unique Message Identifier within FIFO.
  dtSent: TDateTime;//< DateTime Sent
  bBroadCast: boolean;//< Flag to broadcast the message to all potential listeners
  
  u2MsgType: word;//< Message Type
  
  //Sender Info - Information About Sender and info to aid a "Call back"
  {}
  u2SrcEntity: word;//< Source Entity (Type)
  uSrcID: UINT;//< Source Entity ID
  lpSrcObj: pointer;//< Pointer to Source Entity/object 
  {}
  //saSrcData: AnsiString;
  
  //Target Info - Information About Target and info to aid a "Call back"
  {}
  u2DestEntity: word;//< Destination Entity (type)
  uDestID: UINT;//< Destination Entity ID
  lpDestObj: pointer;//< Pointer to Destination Entity/object
  {}
  //saDestData: AnsiString;
  
  // Message Data
  {}
  //iMsg: Integer;//< Message Data - Integer 
  //i8Msg: int64;//< Message Data - Int64
  //lpMsg: pointer;//< Message Data - Pointer
  //fMsg:  single;//< Message Data - 32bit float
  //dMsg:  double;//< Message Data - 64bit float
  //cMsg: char;//< Message Data Char (byte width)
  //bMsg: boolean;//< Message Data - Boolean
  saMsg: ansistring;
end;  
//=============================================================================



//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_FIFO
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
{}
// This structure contains variables that need to be set prior to initializing 
// this UNIT. Once Set, you pass this structure to the JFC_FIFO class' create
// constructor.
type rtFifoInit=record
//=============================================================================
  // FIFO JTMSG Queue Related
  {}
  iAllocationSize: INT;//< How many messages for the Queue
  // you wish to allocate at one time when the FIFO fills and 
  // more space is needed for an incoming message. 
  
  iInitialNoOfAllocationUnits: INT;//< How many allocation units to
  // create when the class is created initially. 
  // (iAllocationSize * iInitialNoOfAllocationUnits)=How Many possible 
  // messages the FIFO can hold initially. The benefit of "pre allocating"
  // space for messages is that overhead is incurred whenever the FIFO
  // fills up because more message memory is allocated on demand - precisely a 
  // one more Allocation unit is added (which again can be room for one 
  // message or a group of messages - see iAllocationSize). You can also
  // limit how messages can come into the Queue - see 
  // bAddAllocationUnitsWhenFIFOFull
  
  bAddAllocationUnitsWhenFIFOFull: boolean;//<This flag allows you limit the
  // number of messages in the QUEUE if you set it to FALSE. If the queue fills
  // then messages can not be added to the queue until there is room to do so.
  
  bAutoNumberUIDField: boolean;//< Unique Identifier/Auto Number - Only When 
  // UID=0 Will a the new UID be generated. These UID's are generated when 
  // the Message is added to the Queue.
  
  bAutoRecordDateNTimeInSentField: boolean;//< Only when datetime=0 will it do this.
  // NOTE: For Both UID and DateTime "Auto" fill, Clearing a rtFIFOItem record
  // with ClearFIFOItem(MyFifoItem) will zero the UID and DateTime for you.
  
  iMaximumAllowedAllocationUnits: INT;//< If ZERO, this has no effect, however if bAddAllocationUnitsWhenFIFOFull
  // (In essence GROW if full) is TRUE then this iMaximumAllowedAllocationUnits
  // allows you to set a restriction on the growth.
end;
//=============================================================================


//=============================================================================
{}
// This is the main class that handles a FIFO of Messages.
type JFC_FIFO=class
//=============================================================================
  {}
  pvt_aFIFOItem: array of rtFIFOItem;//< PRIVATE - This is the internal dynamic array
  // used to hold messages in the FIFO. Due to the nature of this; memory
  // is not freed when the queue empties - the memory stays allocated and 
  // is reused. However if the Queue fills and the bAddAllocationUnitsWhenFIFOFull
  // is set to TRUE during class instantiation, then more memory (allocation units)
  // will be allocated as needed.
  
  pvt_uNextUID: UINT;//< PRIVATE - Next Autonumber value to use
  pvt_iHead: INT;//< PRIVATE - Tracks the start of where we are in the FIFO array
  pvt_iTail: INT;//< PRIVATE - Tracks the END of where we are in the FIFO
  pvt_iItems: INT;//< PRIVATE
  pvt_iAllocationSize: INT;//< PRIVATE
  pvt_iAllocatedUnits: INT;//< PRIVATE
  pvt_iInitialNoOfAllocationUnits: INT;//< PRIVATE
  pvt_iMaximumAllowedAllocationUnits:INT;//< PRIVATE
  pvt_iSize: INT;//< PRIVATE
  pvt_bAddAllocationUnitsWhenFIFOFull: boolean;//< PRIVATE
  pvt_bAutoNumberUIDField: boolean;//< PRIVATE
  pvt_bAutoRecordDateNTimeInSentField: boolean;//< PRIVATE
  pvt_iNumberTimesSendFailed: INT;//< PRIVATE
  pvt_iMaximumNumberOfItemsReached: INT;//< PRIVATE
  pvt_iMaximumNumberOfUnitsAllocated: INT;//< PRIVATE

  constructor Create(p_rFifoInit:rtFifoInit);//< Constructor for JFC_FIFO - See rtFifoInit Record Type for more information
  destructor Destroy;override;//< Destructor - Empties Frees Array of JFC_DARRITEM but not necessarily
  // the contents. e.g. pointers to objects or memory.
                     
  function iItems: INT;//< Items in FIFO
  
  procedure CopyFIFOItem(var p_Src: rtFIFOITEM; var p_Dest: rtFIFOITEM);//<this function allows
  // duplicating a rtFIFOITEM structure.
  
  function bRecv(var p_rFIFOItem: rtFIFOITEM):boolean;//<Accepts a Message and place it in the QUEUE
  function bSend(var p_rFIFOItem: rtFIFOITEM):boolean;//<Sends a Message and removes it from the Queue

  // Used internally for housekeeping
  procedure pvt_CompactFIFO;


  // --House Keeping :)
  // returns the number of allocation units that could be reclaimed by the 
  // system if you were to call the house keeping function:
  // bReclaimUnusedAllocationUnits(p_iHowMany:Integer);
  // Use this function to see if it's be worth performing the 
  // bReclaimUnusedAllocationUnits function if you like.
  function iAllocationUnitsNotInUse: INT;
  
  // --House Keeping :)
  // Attempts to reclaim the requested number of allocation units
  // note that it will never reclaim more than are "EMPTY of data"
  // so there is no harm asking it to reclaim 500 units when only 
  // 2 exist for example.
  // There is a housekeeping processing cost (it might take awhile
  // depending on # of allocation units allocated - as it consolidates the 
  // data) Returns howmany allocation units freed.
  function iReclaimUnusedAllocationUnits(p_iHowMany:INT):INT;
  
  property NextUID:UINT read pvt_uNextUID;//< Next Unique Identifier
  property HeadPos:INT read pvt_iHead;//< Head Position of the FIFO in the Array
  property TailPos:INT read pvt_iTail;//< Tail position of the FIFO in the Array
  property Items:INT read pvt_iItems;//< Number of items in the Array
  property AllocationSize: INT read pvt_iAllocationSize;//<Number of items per Allocation Unit
  property AllocatedUnits: INT read pvt_iAllocatedUnits;//<Number of units allocated
  property InitialNoOfAllocationUnits: INT read pvt_iInitialNoOfAllocationUnits;//<Number of allocation units allocated when class instantiated. This serves as a minimum.
  property MaximumAllowedAllocationUnits: INT read pvt_iMaximumAllowedAllocationUnits;//<Maximum Allowed Allocation Units.

  property SendFailures: INT read pvt_iNumberTimesSendFailed;//< This is the number of times messages didn't sucessfully get sent (to be clear)
  property MaximumNumberOfItemsReached: INT read pvt_iMaximumNumberOfItemsReached;//< Number of times the Fifo hit it's limit if limit set.
  property MaximumNumberOfUnitsAllocated: INT read pvt_iMaximumNumberOfUnitsAllocated;//< Maximum number of Units allocated through life of the FIFO

  property Size: INT read pvt_iSize;//< The Size of the FIFO.
  property AddAllocationUnitsWhenFIFOFull: boolean read pvt_bAddAllocationUnitsWhenFIFOFull;//<Read-only property to report whether or not the FIFO instance is configured to dynamically allocate memory as needed.
  property AutoRecordDateNTimeInSentField: boolean read pvt_bAutoRecordDateNTimeInSentField;//<Read-Only property to report whether or not the FIFO instance is configured to track date and time of messages as they are created.
  
  function bPeek(var p_rFIFOItem: rtFIFOITEM):boolean;//< Receives Message if available but doesn't remove from queue
  procedure ClearFIFOItem(var p_rFIFOItem: rtFIFOITEM);//< Empties specific FIFO Item's data
end;
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
//=*=



//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_FIFO
//*****************************************************************************
//=============================================================================
//*****************************************************************************




//=============================================================================
constructor JFC_FIFO.Create(p_rFifoInit:rtFifoInit);
//=============================================================================
begin
  pvt_uNextUID:=1;
  pvt_iHead:=-1;
  pvt_iTail:=-1;
  pvt_iItems:=0;
  pvt_iAllocationSize:=p_rFifoInit.iAllocationSize;
  if pvt_iAllocationSize<1 then pvt_iAllocationSize:=1;
  pvt_iInitialNoOfAllocationUnits:=p_rFifoInit.iInitialNoOfAllocationUnits;
  //if pvt_uAllocatedUnits<0 then pvt_uAllocatedUnits:=0;//from when was integer
  pvt_iMaximumAllowedAllocationUnits:=p_rFifoInit.iMaximumAllowedAllocationUnits;
  if(pvt_iMaximumAllowedAllocationUnits>0) and
    (pvt_iInitialNoOfAllocationUnits>pvt_iMaximumAllowedAllocationUnits)then
  begin
    pvt_iInitialNoOfAllocationUnits:=pvt_iMaximumAllowedAllocationUnits;
  end;
  pvt_iAllocatedUnits:=pvt_iInitialNoOfAllocationUnits;
  pvt_iSize:=pvt_iAllocationSize * pvt_iAllocatedUnits;
  
//  try
    //riteln('set length:',pvt_iSize);
    //riteln('RAM Request (Per Item: ',SizeOf(rtFIFOItem),'):',pvt_iSize*sizeof(rtFIFOItem));
    setlength(pvt_aFIFOItem,pvt_iSize);
    //riteln('ok that worked.');
//  finally
//    riteln('Finally :(');
//    pvt_iAllocationSize:=1;
//    pvt_iAllocatedUnits:=1;
//    pvt_iSize:=pvt_iAllocationSize * pvt_iAllocatedUnits;
//    setlength(pvt_aFIFOItem,pvt_iSize);
//    riteln('Finally Done though :)');
//  end;
  
  pvt_iNumberTimesSendFailed:=0;
  pvt_iMaximumNumberOfItemsReached:=0;
  pvt_iMaximumNumberOfUnitsAllocated:=pvt_iSize;


  pvt_bAddAllocationUnitsWhenFIFOFull:=p_rFifoInit.bAddAllocationUnitsWhenFIFOFull;
  pvt_bAutoNumberUIDField:=p_rFifoInit.bAutoNumberUIDField;
  pvt_bAutoRecordDateNTimeInSentField:=p_rFifoInit.bAutoRecordDateNTimeInSentField;
end;
//=============================================================================

//=============================================================================
destructor JFC_FIFO.Destroy;// Empties Frees Array of JFC_DARRITEM but not necessarily
                   // the contents. e.g. pointers to objects or memory.
//=============================================================================
begin
  setlength(pvt_aFIFOItem,0);
  inherited;
end;
//=============================================================================

//=============================================================================
function JFC_FIFO.iItems: int;
//=============================================================================
begin
  result:=pvt_iItems;
end;
//=============================================================================

//=============================================================================
procedure JFC_FIFO.CopyFIFOItem(var p_Src: rtFIFOITEM; var p_Dest: rtFIFOITEM);
//=============================================================================
begin
  
  p_Dest.UID                  :=          p_Src.UID            ;
  p_Dest.dtSent               :=          p_Src.dtSent         ;
  p_Dest.bBroadCast           :=          p_Src.bBroadCast     ;
  p_Dest.u2MsgType            :=          p_Src.u2MsgType      ;
  p_Dest.uSrcID               :=          p_Src.uSrcID         ;
  p_Dest.lpSrcObj             :=          p_Src.lpSrcObj       ;
  //p_Dest.saSrcData            :=          p_Src.saSrcData     ;
  p_Dest.uDestID              :=          p_Src.uDestID        ;
  p_Dest.lpDestObj            :=          p_Src.lpDestObj      ;
  //p_Dest.saDestData           :=          p_Src.saDestData     ;
  //p_Dest.iMsg                 :=          p_Src.iMsg           ;
  //p_Dest.i8Msg                :=          p_Src.i8Msg          ;
  //p_Dest.lpMsg                :=          p_Src.lpMsg          ;
  //p_Dest.fMsg                 :=          p_Src.fMsg           ;
  //p_Dest.dMsg                 :=          p_Src.dMsg           ;
  //p_Dest.cMsg                 :=          p_Src.cMsg           ;
  //p_Dest.bMsg                 :=          p_Src.bMsg           ;
  p_Dest.saMsg                :=          p_Src.saMsg          ;

end;
//=============================================================================

//=============================================================================
procedure JFC_FIFO.ClearFIFOItem(var p_rFIFOItem: rtFIFOITEM);//Empties it.
//=============================================================================
begin
  
  p_rFIFOItem.UID                  :=          0;
  p_rFIFOItem.dtSent               :=          0;
  p_rFIFOItem.bBroadCast           :=          false;
  p_rFIFOItem.u2MsgType            :=          0;
  p_rFIFOItem.uSrcID               :=          0;
  p_rFIFOItem.lpSrcObj             :=          nil;
  //p_rFIFOItem.saSrcData            :=          '';
  p_rFIFOItem.uDestID              :=          0;
  p_rFIFOItem.lpDestObj            :=          nil;
  //p_rFIFOItem.saDestData           :=          '';

  //p_rFIFOItem.iMsg                 :=          0;
  //p_rFIFOItem.i8Msg                :=          0;
  //p_rFIFOItem.lpMsg                :=          nil;
  //p_rFIFOItem.fMsg                 :=          0;
  //p_rFIFOItem.dMsg                 :=          0;
  //p_rFIFOItem.cMsg                 :=          #0;
  //p_rFIFOItem.bMsg                 :=          false;
  //p_rFIFOItem.saMsg                :=          '';

end;
//=============================================================================


//=============================================================================
function JFC_FIFO.bRecv(var p_rFIFOItem: rtFIFOITEM):boolean;
//=============================================================================
begin
  Result:=(pvt_iItems>0);
  if Result then 
  begin
    //riteln('bRec head:',pvt_iHead);
    CopyFIFOItem(pvt_aFIFOItem[pvt_iHead],p_rFIFOItem);
    pvt_iItems-=1;
    if pvt_iItems>0 then
    begin
      if (pvt_iHead+1)>=pvt_iSize then
      begin
        pvt_iHead:=0;
      end
      else
      begin
        pvt_iHead+=1;
      end;
    end
    else
    begin
      pvt_iHead:=-1;
      pvt_iTail:=-1;
    end;
  end;
end;
//=============================================================================

//=============================================================================
function JFC_FIFO.bPeek(var p_rFIFOItem: rtFIFOITEM):boolean;
//=============================================================================
begin
  Result:=(pvt_iItems>0);
  if Result then 
  begin
    //riteln('bRec head:',pvt_iHead);
    CopyFIFOItem(pvt_aFIFOItem[pvt_iHead],p_rFIFOItem);
  end;
end;
//=============================================================================


//=============================================================================
//--Used internally for housekeeping
procedure JFC_FIFO.pvt_CompactFIFO;
//=============================================================================
var 
  aFIFOItem: array of rtFIFOItem;
  i: integer;
  ix: integer;
begin
  if (pvt_iSize>0) and (pvt_iItems>0) then
  begin
    setlength(aFIFOItem, pvt_iSize);
    if(pvt_iHead>pvt_iTail) then
    begin
      ix:=0;
      for i:=pvt_iHead to pvt_iSize-1 do
      begin
        CopyFIFOItem(pvt_aFIFOItem[i], aFIFOItem[ix]);
        iX+=1;
      end;
      for i:=0 to pvt_iTail do
      begin
        CopyFIFOItem(pvt_aFIFOItem[i], aFIFOItem[ix]);
        iX+=1;
      end;
    end
    else
    begin
      ix:=0;
      for i:=pvt_iHead to pvt_iTail do
      begin
        CopyFIFOItem(pvt_aFIFOItem[i], aFIFOItem[ix]);
        iX+=1;
      end;
    end;
    pvt_aFIFOItem:=aFIFOItem;
    setlength(aFIFOItem,0);// Just free out local stuff.
    pvt_iHead:=0;
    pvt_iTail:=pvt_iItems-1;
  end;
end;
//=============================================================================



//=============================================================================
function JFC_FIFO.bSend(var p_rFIFOItem: rtFIFOITEM):boolean;
//=============================================================================
begin
  result:=true;
  // Need More RAM?
  if (pvt_iItems+1) > pvt_iSize then
  begin
    // YES!!! But Are We Allowed to add more RAM?
    if pvt_bAddAllocationUnitsWhenFIFOFull and
       ((pvt_iMaximumAllowedAllocationUnits>pvt_iAllocatedUnits) or
       (pvt_iMaximumAllowedAllocationUnits=0))then 
    begin
      // YES!!
      
      //riteln('Allocating RAM Items on entry:',pvt_iItems,' Size on Entry:',pvt_iSize);
      
      pvt_CompactFIFO;// Handles Head and Tail positions
      pvt_iSize+=pvt_iAllocationSize;
      setlength(pvt_aFIFOItem,pvt_iSize);
      pvt_iAllocatedUnits+=1;    
    end
    else
    begin
      // NO!! Fail! All Bets Off! Get Outta Here! You Lose! LATER! ;)
      result:=false;
      pvt_iNumberTimesSendFailed+=1;
      exit;// For Speed Sake ;)
    end;
  end;
  
  //if result then 
  //begin
    // In theory, if we got here, we are ready to Append a NEW FIFO item
    if pvt_iItems=0 then 
    begin
      pvt_iHead:=0;
    end;
    // Note pvt_iTail is set to -1 when list empties, so just adding to 
    // it and bounds checking should be good enough.
    pvt_iTail+=1;
    if(pvt_iTail>=pvt_iSize)then
    begin
      pvt_iTail:=0;// then wrap it :)
    end;
    CopyFIFOItem(p_rFIFOItem, pvt_aFIFOItem[pvt_iTail]);
    
    pvt_iItems+=1;
    

    if pvt_iItems > pvt_iMaximumNumberOfItemsReached then 
      pvt_iMaximumNumberOfItemsReached:=pvt_iItems;
    if pvt_iAllocatedUnits > pvt_iMaximumNumberOfUnitsAllocated then 
      pvt_iMaximumNumberOfUnitsAllocated:=pvt_iAllocatedUnits;
    //if pvt_iMaximumNumberOfItemsReached< pvt_iMaximumNumberOfUnitsAllocated then
    // begin
    //  //RITELN('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BEGIN FIFO OFF KILTER!!!!!!!!!!!!');
    //  //riteln('pvt_iMaximumNumberOfItemsReached:',pvt_iMaximumNumberOfItemsReached); 
    //  //riteln('pvt_iMaximumNumberOfUnitsAllocated:',pvt_iMaximumNumberOfUnitsAllocated); 
    //  //RITELN('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! END FIFO OFF KILTER!!!!!!!!!!!!');
    //end;

    if pvt_bAutoNumberUIDField and (pvt_aFIFOItem[pvt_iTail].UID=0) then
    begin
      //riteln('pp-fifo autonumber:',pvt_uNextUID,' tail:',pvt_iTail);
      pvt_aFIFOItem[pvt_iTail].UID:=pvt_uNextUID;
      pvt_uNextUID+=1;
    end;
    
    if pvt_bAutoRecordDateNTimeInSentField and 
       (pvt_aFIFOItem[pvt_iTail].dtSent=0) then
    begin
      pvt_aFIFOItem[pvt_iTail].dtSent:=now;
    end;
    
  //end;
end;
//=============================================================================
  
                     
//=============================================================================
// --House Keeping :)
// returns the number of allocation units that could be reclaimed by the 
// system if you were to call the house keeping function:
// bReclaimUnusedAllocationUnits(p_iHowMany:Integer);
// Use this function to see if it's be worth performing the 
// bReclaimUnusedAllocationUnits function if you like.
function JFC_FIFO.iAllocationUnitsNotInUse: INT;
//=============================================================================
begin
  result:=(pvt_iSize-pvt_iItems) div pvt_iAllocationSize;
end;
//=============================================================================
  
//=============================================================================
// --House Keeping :)
// Attempts to reclaim the requested number of allocation units
// note that it will never reclaim more than are "EMPTY of data"
// so there is no harm asking it to reclaim 500 units when only 
// 2 exist for example.
// There is a housekeeping processing cost (it might take awhile
// depending on # of allocation units allocated - as it consolidates the 
// data)
function JFC_FIFO.iReclaimUnusedAllocationUnits(p_iHowMany:INT):INT;
//=============================================================================
var iMinUnits:integer;
    iHowManyCanSpare: integer;
begin
  result:=0;
  if (p_iHowMany>0) and  (p_iHowMany <= iAllocationUnitsNotInUse) then
  begin
    iMinUnits:=pvt_iItems div pvt_iAllocationSize;
    if(pvt_iItems mod pvt_iAllocationSize) > 0 then iMinUnits+=1;
    if(iMinUnits<pvt_iInitialNoOfAllocationUnits) then 
    begin
      iMinUnits:=pvt_iInitialNoOfAllocationUnits;
    end;  
    iHowManyCanSpare:=pvt_iAllocatedUnits-iMinUnits;

    if(iHowManyCanSpare>0)then
    begin
      pvt_CompactFIFO;
      if(p_iHowMany>iHowManyCanSpare)then
      begin
        result:=iHowManyCanSpare;
        pvt_iSize:=pvt_iSize-(iHowManyCanSpare*pvt_iAllocationSize);
      end
      else
      begin
        result:=p_iHowMany;
        pvt_iSize:=pvt_iSize-(p_iHowMany*pvt_iAllocationSize);
      end;  
      setlength(pvt_aFIFOItem,pvt_iSize);
      pvt_iAllocatedUnits:=pvt_iSize div pvt_iAllocationSize;
    end;
  end;
end;
//=============================================================================






//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
