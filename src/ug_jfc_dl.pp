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
// Base Jegas Double Linked List Classes. There is a CLASS for the List Items,
// and the Class that manages lists of them; respectively: JFC_DLITEM
// and JFC_DL.
Unit ug_jfc_dl;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_dl.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{DEFINE DEBUG_G_JFC_DL}
{$IFDEF DEBUG_G_JFC_DL}
  {$INFO | DEBUG_G_JFC_DL}
{$ENDIF}
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
{$IFDEF DEBUG_G_JFC_DL}
  sysutils,
  ug_common;
{$ELSE}
  sysutils;
{$ENDIF}
//=============================================================================





//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_DLITEM
//*****************************************************************************

//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// BASE Class for everything (By using this as base - a class can be directly
// manipulated by classes derived from JFC_DL. If this isn't possible
// you still can JFC_DL. For this situation - JFC_DL was "recreated"
// for Version 3 of this Library - Its not 100% Compatible - Names changed
// to match V3 - but its basicly the same thing - ONLY
// FASTER and LEANER than ever. Dynamic Linked List Navigation is FAST but
// sorting is a bit trickier. There is a method for SWAPPING Linked List
// positions but for faster sorting (without using an array directly)
// I'd use lpPTR for my objects and just swap pointers or something...
// I'm not a sorting genuis anyways.
Type JFC_DLITEM = Class
//=============================================================================
  //protected
  Public
  {}
  lpPrev: pointer;//< private 
  lpNext: pointer;//< private
  //  public
  {}
  lpPtr: pointer; //< Most Basic User Storage Field
  saClassName: AnsiString;  //< Class Name 
  Constructor create; //< OVERRIDE - INHERIT - Initializes pointers as NIL
  Destructor destroy; override;//< override - inherit - CLEAR YOUR ANSISTRINGS;
End;
//=============================================================================



//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_DL
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
{}
// Out of the box this class manipulates JFC_DLITEM class - Which until you
// expand on it - or use a one of the derivitives iNN here, is useless.
// It gives you the foundation for a very powerful double linked list
// pair: JFC_DLITEM CLASS to have dynamic instances of , and a JFC_DL 
// to manage multiple instances of your CLASSES derived from JFC_DLITEM.
//
// Sample Code provided iNN vitual "STUB" routines contained iNN comments
Type JFC_DL = Class(JFC_DLITEM)
//=============================================================================
  Public
  bDebug: Boolean;
  
  //---------------------------------------------------------------------------
  //protected 
  //---------------------------------------------------------------------------
  {}
  lpOwner: pointer; //< DESCENDANT DEFINED
  iType  : LongInt; //< DESCENDANT DEFINED
  iItems: LongInt;
  iNN: LongInt;
  lpFirst: pointer; 
  lpLast: pointer;
  bCopy: Boolean;
  pvt_u8AutoNumber: UInt64;
  //---------------------------------------------------------------------------
  

  //---------------------------------------------------------------------------
  //protected
  //---------------------------------------------------------------------------
  {}
  // OVERRIDE - DON'T INHERIT! Make this return YOUR ITEM CLASS TYPE after its instanced.
  Function pvt_CreateItem: JFC_DLITEM; Virtual; 
  
  {}
  // Place to put "generations" of code thats you can add to but inherit the
  // previous generation - unlike pvt_createitem which gets overriden entirely
  // CALLED AFTER pvt_createItem
  Procedure pvt_createtask; Virtual;
                            
  {}
  // OVERRIDE - DON'T INHERIT!
  // Make This DESTROY your ClassItem When p_ptr (pointer to YOUR class) is 
  // sent.
  Procedure pvt_DestroyItem(p_lp:pointer); Virtual; 
  
  {}
  // Place to put "generations" of code thats you can add to but inherit the
  // previous generation - unlike pvt_destroyitem which gets overriden entirely
  // CALLED BEFORE pvt_DestroyItem
  Procedure pvt_destroytask(p_lp: pointer); Virtual;
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // make properties work
  //---------------------------------------------------------------------------
  {}
  Function read_item_lpPtr: pointer;//< make properties work
  Procedure write_item_lpptr(p_lp:pointer);//< make properties work
  {}
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  //public // Overridable - Work As Is
  //---------------------------------------------------------------------------
  {}
  Constructor Create; //< OVERRIDE BUT INHERIT
  {}
  //---------------------------------------------------------------------------
  {}
  // Makes an Instance of CLASS that is "ReadOnly" and "looks" at the list 
  // managed by the CLASS you passed iNN p_lpSameTypeOfClass. This allows
  // TWO or more "CURSORs" iNN the same list. Before You Start messing with 
  // a copyied VERSION of this CLASS, call "Sync" method if it is possible
  // the copied CLASS has added or removed any items. 
  Constructor CreateCopy(p_lpSameTypeOfClass: pointer);
  //---------------------------------------------------------------------------
  {}
  // Returns TRUE if this class was created with the CreateCopy constructor.
  Property  IsCopy: Boolean read bCopy;
  //---------------------------------------------------------------------------
  {}
  Procedure Sync(p_lpSameTypeOfClass: pointer); Virtual;//<OVERRIDE BUT INHERIT
  //---------------------------------------------------------------------------
  {}
  Destructor Destroy; override; //< override but inherit
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  {}
  public
  lpItem: pointer; //< CURRENT "ItemClass" this CLASS is looking at.
  Function Next_lpItem:pointer; //< Pointer to next JFC_DLITEM item (See lpItem)
  Function Prev_lpItem:pointer; //< Pointer to next JFC_DLITEM item (See lpItem)
  {}
  //---------------------------------------------------------------------------
  {}
  // Special Feature Presentation of the Highly advanced AutoNumber ;)
  // Returns a higher LongInt number each time its called until it rolls over.
  // Good for UNIQUE IDENTIFIERS. Works Like Database AUTONUMBER fields.
  // NOTE: This is not called automatically ANYWHERE - Descendant classes
  // that wish to utilize this are totally responsible for calling this routine 
  // at the right times - Suggestion: When AppendItem'n or InsertITem'n ;)
  Function AutoNumber: UInt64;
  //---------------------------------------------------------------------------
  
  
  
  // Appends
  //---------------------------------------------------------------------------
  {}
  // Appends your class to the end of the list and makes it the current item.
  // Pass pointer to your classitem - You are responsible for not adding 
  // same class twice - that is pointless ONE and TWO it will corrupt
  // the list. If you're not sure - Call "FindItem" function - with the 
  // pointer of the class you wish to add. If it returns false - then
  // its safe to add it.
  Function AppendItemToList(p_lpNewItem: pointer):Boolean; 
  // true unless copy or error
  Function AppendItem:Boolean; 
  // True unless copy or error
  Function AppendItem_lpPtr(p_lpPtr: pointer): Boolean; //virtual;
  //---------------------------------------------------------------------------

  // Inserts
  //---------------------------------------------------------------------------
  {}
  // Inserts Your Class iNN front of the current item and becomes the current
  // item. Same rules apply as append concerning duplicates.
  Function InsertItemInList(p_lpNewItem: pointer):Boolean;
  // TRUE if Successful - False if Copy, or error
  Function InsertItem:Boolean; 
  // TRUE if Successful - False if Copy, or error
  Function InsertItem_lpPtr(p_lpPtr: pointer): Boolean; 

  // Deletes/Remove
  //---------------------------------------------------------------------------
  {}
  // "Removes" Current Item from List - Returns NIL if failed else
  // pointer to your removed item. Fails if list empty or a "bCopy"
  Function RemoveItemFromList:pointer; //(ADVANCED)
  //---------------------------------------------------------------------------
  {}
  // Same Thing as RemoveItemFromList but removes SPECIFIC item instead of 
  // Current "lpItem".
  Function RemoveThisItemFromList(p_lpItem:pointer):pointer; //(ADVANCED)
  //---------------------------------------------------------------------------
  {}
  // TRUE if Successful Delete - False if Copy, empty list, or error
  Function DeleteItem:Boolean; 
  // DeleteAll Returns TRUE unless Error - Or bCopyied Class.
  Function DeleteAll: Boolean; 
  Function DeleteThisItem(p_lpItem:pointer):Boolean;
  //---------------------------------------------------------------------------
  {}
  // DELETE Special Flag - If you inherit JFC_DL - you must implement yourself. 
  // For example see pvt_destroyitem. It's simple. DEFAULT is FALSE. If Set to 
  // TRUE - then when the interior pvt_Destroyitem function is called via
  // DeleteItem, DeleteAll or DeleteThisItem - then the JFC_DLITEM.lpPtr field
  // is checked to see if its NIL. If it IS NOT NIL - It is presumed to be a 
  // pointer to another JFC_DL class - which needs to be destroyed so orphans
  // aren't left in memory. SO... It Calls DeleteAll on the JFC_DL hanging off
  // the DLITEM.lpPtr we are deleting, then destroys it, and sets lpPtr to NIL
  // right before the item is released. There is no 100% secure way I know of
  // to ascertain if the class I want to delete IS NOT a base or whatever...
  //
  // SO DO NOT misunderstand the name of this variable. I needed a generic
  // enough name so descendants can implement this also.
  //
  // If this FLAG is true, the Code in the JFC_DL.pvt_destroyitem procedure 
  // ASSUMES the Object pointed to in JFC_DLITEM.lpPtr is a JFC_DL.
  //
  // Likewise, in the JFC_XDL class, If this FLAG is true, the Code in the 
  // JFC_XDL.pvt_destroyitem procedure ASSUMES
  // the Object pointed to in JFC_XDLITEM.lpPtr is a JFC_XDL.
  public
  bDestroyNestedLists: boolean;
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  
  
  // Basic Navigation
  //---------------------------------------------------------------------------
  {}
  Function  MoveFirst:Boolean;                                
  //---------------------------------------------------------------------------
  {}
  Function  MoveLast:Boolean;                                 
  //---------------------------------------------------------------------------
  {}
  Function  MovePrevious:Boolean;
  //---------------------------------------------------------------------------
  {}
  Function  MoveNext:Boolean;
  //---------------------------------------------------------------------------
  {}
  // Reports CURRENT Item's sequential position iNN the list.
  Property  N: LongInt read iNN;
  //---------------------------------------------------------------------------
  {}
  // "Beginning of List" - TRUE if Current Item is the FIRST ITEM iNN the list
  // OR the list is Empty.
  Function  BOL: Boolean;
  //---------------------------------------------------------------------------
  {}
  // "End Of List" - TRUE if Current Item is the LAST ITEM iNN the list
  // OR the list is Empty.
  Function  EOL: Boolean;
  //---------------------------------------------------------------------------
  {}
  // Returns number of items iNN list.
  Property  ListCount: LongInt read iItems;
  //---------------------------------------------------------------------------
  {}
  // SEEK "Nth" item iNN list. Returns TRUE if Found, FALSE otherwise
  // 
  // This routine does calculate the shortest method to navigate from the 
  // current position iNN the list to the requested one. But it does require
  // multiple iterations - though so far it proves to be pretty darn fast.
  // Fast as it can without a jump table.
  //
  // I didn't add a jump table as a memory saver for classes that don't even 
  // use this. It would be very possible to make your own jump table. I didn't
  // because it would add storage overhead I didn't want iNN the base class.
  Function  FoundNth(p_iNN: LongInt):Boolean;
  //---------------------------------------------------------------------------
  
  {}
  // Search Funtions
  // NOTES ABOUT THESE SEARCH METHODS: 
  // --They All are smart enough to just return false if the list is empty.
  // --They ALL - upon a successful FIND - Set the CURRENT Item to the just   
  //   FOUND item. 
  // --They ALL - upon failing - RETURN the list to the item that was Current
  //   before the search was invoked.
  // --They all are reasonably fast, platform independant and to a large degree
  //   datatype oblivious - less special searches for ANSISTRING type.
  // --Any Binary searches for data types (for instance a whole record) that
  //   has one or more ANSISTRING variables iNN it will be unreliable because
  //   ANSISTRINGS are really pointers and the SAME data might be stored
  //   somewhere else _in_ mem, meaning pointer values won't match - hence search
  //   MAY fail.
  //
  // CORE Binary Search - Tricky BUT GOLDEN!
  //
  // Returns TRUE if Found and False if not. Good For EXACT MATCHES of BINARY
  // Data - This means everything except ANSISTRINGS - IF used for STRINGS - 
  // CASE and LENGTH SENSISTIVE!
  //
  // Its Tricky but portable - Kind of a VARIANT type thing - HERE is an
  // example to try to explain how it works. 
  //
  //   Result:=JFC_DL.FoundBinary(@FindThis, SizeOf(FindThis), 
  //                             @TYOURITEMCLASS(nil).FindThisField;
  //                             TRUE,FALSE);
  //
  //   To Seek a record based on an OBJECT stored _in_ lpPTR change the last 
  //   field to true and instead of @TYOURITEMCLASS(nil).iFindThisField
  //   Use @YOURCLASS(nil).iFindThisField;
  //
  // NOTE: The TypeCast of nil is MUTE! ITs used for pointer math - 
  //       But you need to send it because it is a reference point for
  //       the pointer math. IT Works - thats all that matters.
  //       If you have multiple SIZE class items managed by this JFC_DL
  //       class - Careful about Searching fields that might (memory wise)
  //       fall outside of a class's memory bounds - _in_ Short - If you have
  //       two classes _in_ a list where the FIRST type has one LongInt and the
  //       second has two - You should only do searches on the FIRST int cuz you
  //       might inadvertantly attempt to read from a memory location that 
  //       isn't yours. This shouldn't be something to worry about until 
  //       you start getting REALLY complex - multiple class types _in_ same 
  //       linked list etc. And even then it works with care.
  Function FoundBinary(
    p_lpWhat: pointer;
    p_iSize: LongInt;
    p_lpOffset: pointer;
    p_bStartAtBegin: Boolean;
    p_bUsePtr: Boolean):Boolean;
  //---------------------------------------------------------------------------
  {}
  // CORE Ansistring Search
  // Same as FoundBinary but for Ansistrings - Has Case Sensitivity option.
  // Not for use with NORMAL STRINGS. Normal Strings have serious limitations
  // not true with ANSISTRINGS. I CHOSE to use ANSISTRINGS as much as possible.
  // Sorry there isn't a Case insensitive search for normal strings. This is
  // a base class....you could write one! :)
  Function FoundAnsistring(
    p_saString: AnsiString;
    p_bCaseSensitive: Boolean;
    p_lpOffset: pointer;
    p_bStartAtBegin: Boolean;
    p_bUsePtr: Boolean):Boolean;
  //---------------------------------------------------------------------------
  {}
  // CORE TTIMESTAMP Search
  // Same as FoundBinary but for TTIMESTAMP
  // This does not return a sort listed, it simply searches for the next
  // TTIMESTAMP within the p_tsFrom and p_tsTo Parameters.
  Function FoundTimestamp(
    p_tsFrom: TTIMESTAMP;
    p_tsTo: TTIMESTAMP;
    p_lpOffset: pointer;
    p_bStartAtBegin: Boolean;
    p_bUsePtr: Boolean):Boolean;
  //---------------------------------------------------------------------------
  {}
  // Looks for specific lpItem pointer value - Important Because just setting
  // lpItem to a specific pointer to an ITEM you know EXISTS will screw up
  // "Nth" - The Item's #'d position iNN list - BUT you can get around this
  // for blazing speed by SETTING lpITem directly = and doing a MoveFirst
  // or MoveLast to resync Nth value...As long as you remember that "Nth" 
  // is corrupt until then if you just hyperspeed your way around. 
  //
  // Use this to be safe. If its already THERE - just returns TRUE otherwise
  // IT does a MoveFirst and loops through list until it finds it. If it 
  // DOES it returns TRUE, FALSE otherwise. 
  Function FoundItem(p_lp: pointer):Boolean;
  //---------------------------------------------------------------------------
  {}
  // Good Sample Source to See How a Basic JFC_DL.FoundBinary is done. Looks
  // for your pointer starting from beginning of list
  Function FNextItem_lpPTR(p_lp: pointer):Boolean;
  //---------------------------------------------------------------------------
  {}
  // Good Sample Source to See How a Basic JFC_DL.FoundBinary is done. Looks
  // for your pointer starting from NEXT position _in_ list
  Function FoundItem_lpPTR(p_lp: pointer):Boolean;
  //---------------------------------------------------------------------------
  {}
  // No Error Checking - Make sure they exist - Swaps Sequential Positions
  // in list - not fastest thing iNN world but it works.
  Procedure SwapItems(p_lpItem1, p_lpItem2: pointer);
  //---------------------------------------------------------------------------
  {}
  // Faster Than Swap Items - This doesn't Change the ORDER or the linked list
  // itself - it swaps the data iNN the JFC_DLITEM.lpPtr fields. You Supply
  // the TWO "ITEMS" that point to the JFC_DLITEM classes.
  Procedure SwapItem_lpPtr(p_lpItem1, p_lpItem2: pointer);
  //---------------------------------------------------------------------------
  {}
  // THIS is a slow Bubble Sort - Though Pointer method faster paradigm
  // Then trying to sort the ACTUAL pointers that control the DL navigation
  Function SortBinary(
    p_iSize: LongInt;  //< Size of BINARY data "FIELD"
    p_lpOffset: pointer;//< Refererence to Field - syntax: @JFC_DLITEM(nil).Field
    p_bAscending: Boolean;
    p_bUsePtr: Boolean //< NOTE: This decides whether or not to Calculate the
    // offest required to base the sorting on the ITEM class itself OR (false)
    // a class whose pointer in stored in the ?DL_ITEM.lpPtr field. (TRUE)
   ):Boolean;
  {}
  //---------------------------------------------------------------------------
  {}
  // THIS is a slow Bubble Sort - Though Pointer method faster paradigm
  // Then trying to sort the ACTUAL pointers that control the DL navigation
  Function SortAnsistring(
    p_bCaseSensitive: Boolean;
    p_lpOffset: pointer;
    p_bAscending: Boolean;
    p_bUsePtr: Boolean
   ):Boolean;
  //---------------------------------------------------------------------------
  
  // Properties and Stuff Added for conveinance of accessing fields iNN "ITEMs"
  Property Item_lpPtr: pointer read read_item_lpPtr Write write_item_lpptr;
  // Returns RAW value from JFC_DLITEM.lpPtr field from the next or prev
  // item. If it doesn't exist - Currently its designed to just bomb
  // for speed reasons. (Die Quickly...kidding)
  Function NextItem_lpPtr: pointer; 
  Function PrevItem_lpPtr: pointer; 
  // Not Implemented fully this Generation - but ATM, 2009-02-12, only 
  // JFC_XDL and JFC_XXDL have the saHTMLTable Function.
  // The same way that bDestroyNestedLists:=true - Destroys DL's hanging off 
  // the JFC_DLITEM.lpPtr (if not NIL), this variable controls if the
  // saHTMLTable function rendered nested lists.
  public
  bShowNestedLists: boolean;
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
//=*=




//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_DLITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//
// JFC_DLITEM Routines          BASE "ITEMCLASS" 
//             
//*****************************************************************************

//=============================================================================
Constructor JFC_DLITEM.create; // OVERRIDE - BUT INHERIT
//=============================================================================
Begin
  Inherited;
  lpPrev:=nil; // Required fields for BASIC double linked list functionality.
  lpNext:=nil;
  // Duplicates supported Because lpPtr has nothing to do with underlying
  // double linked list management. Thats Why TWO search routines
  // provided - Find FIRST (FoundPTR) Starting from Beginning OR Find
  // Next (FNextPTR) starting from NEXT Item iNN list.
  lpPtr:=nil; 
  saClassName:='JFC_DLITEM';
End;
//=============================================================================

//=============================================================================
Destructor JFC_DLITEM.Destroy; // OVERRIDE - BUT INHERIT
//=============================================================================
Begin
  saClassName:='';
  Inherited;
End;
//=============================================================================







//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_DL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//
// JFC_DL Routines          BASE Double Linked List Functionality
//             
//*****************************************************************************
// OVERRIDABLE Stuff Listed first to serve as quick reference
//
//----OVERRIDE BUT INHERIT
//=============================================================================
Constructor JFC_DL.Create; // You can Override but you should inherit
//=============================================================================
Begin
  Inherited;
  bDebug:=False;
  saClassName:='JFC_DL';
  
  lpFirst:=nil;
  lpLast:=nil;
  lpItem:=nil;
  iNN:=0;
  iItems:=0;
  pvt_u8AutoNumber:=0;
  bCopy:=False;
  lpOwner:=nil;
  iType:=0;
  
  bDestroyNestedLists:=false;
  bShowNestedLists:=false;
End;
//=============================================================================

//=============================================================================
Destructor JFC_DL.Destroy;
//=============================================================================
Begin
  DeleteAll;
  saClassName:='';
  Inherited;
End;
//=============================================================================




//---OVERRIDING THIS Properly MAKES things like AppendItem, InsertItem
//=============================================================================
Function JFC_DL.pvt_CreateItem: JFC_DLITEM;
//=============================================================================
Begin
  Result:=JFC_DLITEM.Create; 
End;
//=============================================================================

// OVERRIDE But Inherit
//=============================================================================
Procedure JFC_DL.pvt_createtask;
//=============================================================================
Begin
  // Nothing iNN this generation
  {$IFDEF DEBUG_G_JFC_DL}
  If bDebug Then Begin
    JLog(MAC_SEVERITY_DEBUG,630,'JFC_DL.pvt_createtask classname:'+saclassname+' lpItem:'+inttostr(UINT(lpitem)),MAC_SOURCEFILE);
  End;
  {$ENDIF}
End;
//=============================================================================


//---OVERRIDING THIS Properly MAKES things like DeleteItem, bDeleteThisITem,
//and DeleteAll work correctly.
//=============================================================================
Procedure JFC_DL.pvt_DestroyItem(p_lp: pointer);
//=============================================================================
Begin
  // This code is for NESTED JFC_DL ONLY!!! Do NOT Inherit this procedure!!!!!
  // MAKE YOUR OWN!
  if bDestroyNestedLists then 
  begin
    if(JFC_DLITEM(p_lp).lpPtr <> nil)then
    begin
      JFC_DL(JFC_DLITEM(p_lp).lpPtr).DeleteAll;
      JFC_DL(JFC_DLITEM(p_lp).lpPtr).Destroy;
      JFC_DLITEM(p_lp).lpPtr:=nil;
    end;
  end;
  JFC_DLITEM(p_lp).Destroy;
End;
//=============================================================================

// OVERRIDE But Inherit
//=============================================================================
Procedure JFC_DL.pvt_destroytask(p_lp:pointer);
//=============================================================================
Begin
  // Nothing iNN this generation
  p_lp:=p_lp; // shutup compiler  
End;
//=============================================================================



//----OVERRIDE BUT INHERIT
// Shouldn't call this if not a COPY Version "child" Version of class.
// (Not talking inheritance). You can Override this BUT you should inherit
// it iNN order for it to still work. Overrided version might just copy
// More Stuff From one to other that you added. These are necessary for Copyies 
// to Work.
//=============================================================================
Procedure JFC_DL.Sync(p_lpSameTypeOfClass: pointer); 
//=============================================================================
Begin
  If bCopy Then
  Begin
    lpFirst:=JFC_DL(p_lpSameTypeOfClass).lpFirst;
    lpLast:=JFC_DL(p_lpSameTypeOfClass).lpLast;
    lpItem:=JFC_DL(p_lpSameTypeOfClass).lpItem;
    iItems:=JFC_DL(p_lpSameTypeOfClass).iItems;
    iNN:=JFC_DL(p_lpSameTypeOfClass).iNN;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.AppendItem:Boolean; 
//=============================================================================
Begin
  // Note: This shouldn't ever FAIL as is BUT if it DOES - There is a GHOST
  //       Item class floating around and we haven't saved the pointer.
  //       returned from createitem
  Result:=AppendItemToList(pvt_CreateItem);
  If Result Then pvt_createtask;
  {$IFDEF DEBUG_G_JFC_DL}
  If not Result Then JLog(MAC_SEVERITY_DEBUG,691,'JFC_DL.AppendItem Failed- classname:' + saClassname, MAC_SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_DL.AppendItem_lpPtr(p_lpPtr: pointer): Boolean; 
//=============================================================================
Begin
  Result:=AppendItemToList(pvt_CreateItem);
  If Result Then 
  Begin
    JFC_DLITEM(lpItem).lpPtr:=p_lpPtr;
    pvt_createtask;
  End;
  
  {$IFDEF DEBUG_G_JFC_DL}
  If not Result Then JLog(MAC_SEVERITY_DEBUG,709,'JFC_DL.AppendItem_lpPtr Failed- classname:' + saClassname, MAC_SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_DL.InsertItem:Boolean; 
//=============================================================================
Begin
  // Note: This shouldn't ever FAIL as is BUT if it DOES - There is a GHOST
  //       Item class floating around and we haven't saved the pointer from
  //       createitem
  Result:=InsertItemInList(pvt_CreateItem);
  If Result Then pvt_createtask;
  
  {$IFDEF DEBUG_G_JFC_DL}
  If not Result Then JLog(MAC_SEVERITY_DEBUG,726,'JFC_DL.InsertItem_lpPtr Failed- classname:' + saClassname, MAC_SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================

//=============================================================================
Function JFC_DL.InsertItem_lpPtr(p_lpPtr: pointer): Boolean; 
//=============================================================================
Begin
  Result:=InsertItemInList(pvt_CreateItem);
  If Result Then 
  Begin
    JFC_DLITEM(lpItem).lpPtr:=p_lpPtr;
    pvt_createtask;
  End;

  {$IFDEF DEBUG_G_JFC_DL}
  If not Result Then JLog(MAC_SEVERITY_DEBUG,744,'JFC_DL.InsertItem_lpPtr Failed- classname:' + saClassname, MAC_SOURCEFILE);
  {$ENDIF}

End;
//=============================================================================



//=============================================================================
Function JFC_DL.AutoNumber: UInt64;
//=============================================================================
Begin
  pvt_u8Autonumber+=1;
  Result:=pvt_u8Autonumber;
End;
//=============================================================================

//=============================================================================
Constructor JFC_DL.CreateCopy(p_lpSameTypeOfClass: pointer);
//=============================================================================
Begin
  bCopy:=True;
  Sync(p_lpSameTypeOfClass);
End;
//=============================================================================



//=============================================================================
Function JFC_DL.AppendItemToList(p_lpNewItem:pointer):Boolean;
//=============================================================================
Begin
  If (not bcopy) and (p_lpNewItem<>nil) Then
  Begin
    Result:=True;
    lpItem:=p_lpNewItem;
    iItems+=1;
    If iItems=1 Then
    Begin
      lpFirst:=lpItem;
    End
    Else
    Begin
      JFC_DLITEM(lpItem).lpPrev:=lpLast;
      JFC_DLITEM(lpLast).lpNext:=lpItem;
    End;
    lpLast:=lpItem;
    iNN:=iItems;
  End
  Else
  Begin
    Result:=False;
  End;
End;
//=============================================================================


//=============================================================================
Function JFC_DL.InsertItemInList(p_lpNewItem:pointer):Boolean; 
//=============================================================================
Var lpCurItem: pointer;
Begin
  If (not bcopy) and (p_lpNewItem<>nil) Then 
  Begin
    If iItems=0 Then
    Begin
      Result:=AppendItemToList(p_lpNewItem);
    End
    Else
    Begin
      Result:=True;
      iItems+=1;
      lpCurItem:=lpItem; // We Snag the Record and hang on to it cuz we moving it 
                         // down
      //AutoNumber+=1;
      lpItem:=p_lpNewItem;
      
      // next we need to point the previous record (if it exists) to the new 
      // record
      If JFC_DLITEM(lpcuritem).lpprev<>nil Then 
        JFC_DLITEM(JFC_DLITEM(lpcuritem).lpprev).lpnext:=lpItem;
      
      // next we need to make our new record prev point to the one iNN front of it
      JFC_DLITEM(lpItem).lpPrev:=JFC_DLITEM(lpCurItem).lpPrev;
  
      // next we need to make the current DL's previous pointer to point to 
      // the new record
      JFC_DLITEM(lpcuritem).lpPrev:=lpItem;
      
      // next we need to make our new record point to the current item
      JFC_DLITEM(lpItem).lpNext:=lpCurItem;
  
      // next we need to see if we need to update the LIST's FIRST/LAST record 
      // pointers
      If JFC_DLITEM(lpItem).lpPrev=nil Then 
      Begin
        lpFirst:=lpItem;
      End;
    End;
  End
  Else
  Begin
    Result:=False;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.RemoveItemFromList:pointer;
//=============================================================================
//var lpTempItem: pointer;
Begin
  If (iItems>0) and (not bCopy) Then
  Begin
    Result:=lpItem;
    iItems-=1; //NOTE: TODO: Debugging this code (in C++) suggested moving
    // this iItem-=1 below (end of this nest) and the if below this comment
    // to if(iItems=1)  {cuz ya haven't delete it in this scenario yet}
    // Also not sure how the "current item" gets set if the item deleted is
    // somewhere in the middle of the list. Needed to tweak this in c++.
    If iItems=0 Then 
    Begin
      //pvt_destroyitem(lpItem);
      lpFirst:=nil;
      lpLast:=nil;
      lpItem:=nil;
      iNN:=0;
    End
    Else
    Begin
      If BOL Then // there definately is one after because there is at least 
      Begin       // two records and the first of which we are deleting NOW.
        lpFirst:=JFC_DLITEM(lpItem).lpNext;
        //pvt_destroyitem(lpItem);
        lpItem:=lpFirst;
        If lpItem<>nil Then 
        Begin
          JFC_DLITEM(lpItem).lpPrev:=nil;
        End;
      End
      Else
      Begin
        If EOL Then // Again there is definately a record (or class) iNN front
        Begin        // of this one - so we will deal accordingly
          lpLast:=JFC_DLITEM(lpItem).lpPrev;
          //pvt_destroyitem(lpItem);
          lpItem:=lpLast;
          JFC_DLITEM(lpItem).lpNext:=nil;
        End
        Else // OK - The Tricky one iNN my Eyes - Got one iNN front and one iNN 
        Begin// back
          JFC_DLITEM(JFC_DLITEM(lpItem).lpPrev).lpNext:=JFC_DLITEM(lpItem).lpNext;
          JFC_DLITEM(JFC_DLITEM(lpItem).lpNext).lpPrev:=JFC_DLITEM(lpItem).lpPrev;
          //lpTempItem:=lpItem;
          lpItem:=JFC_DLITEM(lpItem).lpNext;
          //pvt_destroyitem(lpTempItem);
        End;
      End;
      // only when at least one record left (and not unassigned (nil))
      //if pointer(moveevent)<>nil then MoveEvent(DL,pointer(self)); 
    End;
  End
  Else
  Begin
    Result:=nil;
    iNN:=iItems;// just make sure N is iNN Sync :)
  End;
End;
//=============================================================================


//=============================================================================
Function JFC_DL.RemoveThisItemFromList(p_lpItem:pointer):pointer;
//=============================================================================
Begin
  If (not bCopy) and (FoundItem(p_lpItem)) Then
    Result:=RemoveItemFromList
  Else
    Result:=nil;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.DeleteItem:Boolean; 
//=============================================================================
Var lp: pointer;
Begin
  lp:=RemoveItemFromList;
  Result:=(lp<>nil);
  If Result Then 
  Begin
    pvt_destroytask(lp);
    pvt_DestroyItem(lp);
  End;
End;
//=============================================================================

// This returns TRUE unless Delete item fails which it shouldn't or
// its a copy class. Bottom line is I wanted DELETEALL to report success
// whether actually deleted anything or - Success then means - YUP Everything
// is GONE! 
//=============================================================================
Function JFC_DL.DeleteAll: Boolean; 
//=============================================================================
Begin
  {$IFDEF DEBUG_G_JFC_DL}
  If bDebug Then Begin
    JLog(MAC_SEVERITY_DEBUG,945,'JFC_DL - DeleteAll - BEGIN - CLASS:'+saClassname, MAC_SOURCEFILE);
  End;
  {$ENDIF}
    
  Result:=(not bCopy);
  If Result and (iItems>0) Then Begin
    While Result and (iItems>0) Do Begin
      Result:=DeleteItem;
    End;
  End;

  {$IFDEF DEBUG_G_JFC_DL}
  If bDebug Then Begin
    JLog(MAC_SEVERITY_DEBUG,958,'JFC_DL - DeleteAll - END   - CLASS:'+saClassname, MAC_SOURCEFILE);
  End;
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_DL.DeleteThisItem(p_lpItem:pointer):Boolean;
//=============================================================================
Var p:pointer;
Begin
  p:=RemoveThisItemFromList(p_lpItem);
  Result:=p<>nil;
  If Result Then 
  Begin
    pvt_destroytask(p);
    pvt_DestroyItem(p);
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.BOL:Boolean;
//=============================================================================
Begin
  Result:=lpFirst=lpItem;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.EOL:Boolean;
//=============================================================================
Begin
  Result:=lpLast=lpItem;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.MoveFirst:Boolean; 
//=============================================================================
Begin
  Result:=iItems>0;
  lpItem:=lpFirst;
  If Result Then iNN:=1 Else iNN:=0;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.MoveLast:Boolean; 
//=============================================================================
Begin
  iNN:=iItems;
  lpItem:=lpLast;
  Result:=iItems>0;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.MovePrevious: Boolean;
//=============================================================================
Begin
  Result:=not BOL;
  If Result Then
  Begin
    lpItem:=JFC_DLITEM(lpItem).lpPrev;
    iNN-=1;
  End;
End;
//=============================================================================


//=============================================================================
Function JFC_DL.MoveNext: Boolean;
//=============================================================================
Begin
  Result:=not EOL;
  If Result Then 
  Begin
    lpItem:=JFC_DLITEM(lpItem).lpNext;
    iNN+=1;
  End
  Else
  Begin//safety code
    lpItem:=lpLast;
    iNN:=iItems;
  End;
End;
//=============================================================================


//=============================================================================
Function JFC_DL.FoundNth(p_iNN: LongInt): Boolean;
//=============================================================================
Begin
  Result:=False;
  If (iItems>0) and (p_iNN>0) and (iItems>=p_iNN) Then
  Begin
    If iNN<>p_iNN Then
    Begin
      // is current position After Or Before
      If p_iNN > iNN Then
      Begin
        // After
        //ok less steps go from here or from end backward
        If (p_iNN-iNN) < (iItems-p_iNN) Then
        Begin
          // from here forward
          While (iNN<>p_iNN) and (not EOL) Do Begin MoveNext; End;
        End
        Else
        Begin
         // from end backward
          MoveLast;
          While (iNN<>p_iNN) and (not BOL) Do Begin MovePrevious; End;
        End;
      End
      Else
      Begin
        // Before
        // Ok Less Steps go from here backward or from the beginning forward
        If (iNN-p_iNN) < (p_iNN) Then
        Begin
          // from here backward
          While (iNN<>p_iNN) and (not BOL) Do Begin MovePrevious; End;
        End
        Else
        Begin
          // from the beginning forward
          MoveFirst;
          While (iNN<>p_iNN) and (not EOL) Do Begin MoveNext; End;
        End;
      End;  
    End;
    Result:=True;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.FoundBinary(
  p_lpWhat: pointer;
  p_iSize: LongInt;
  p_lpOffset: pointer;
  p_bStartAtBegin: Boolean;
  p_bUsePtr: Boolean):Boolean;
//=============================================================================
Var TempPtr: pointer;
    TempN: LongInt;
    lpHuntMe: pointer;
    //iTrueOffset: LongInt;
    bGotIt: Boolean;
    iCalcSize: longint;
Begin
  //riteln('Enter JFC_DL.FoundBinary...(iItems:',iItems,')');
  Result:=False;
  If iItems>0 Then
  Begin
    TempPtr:=lpItem;
    TempN:=iNN;
    //iTrueOffset:=LongInt(p_lpOffset);//-LongInt(lpItem);
//    lpHuntMe:=pointer(LongInt(lpItem)+iTrueOffset);
//    bGotIt:=p_bStartAtBegin and (comparebyte(p_lpWhat^, lpHuntMe^,p_iSize) =0);
//    if not bGotIt then
//    begin
    bGotIt:=False;  
    If (p_bStartAtBegin and MoveFirst) OR
       ((not p_bStartAtBegin) and MoveNext) Then
    Begin
      if(p_iSize mod 4)=0 then
      begin
        iCalcSize:=p_iSize div 4;
        //MoveFirst;
        If not p_buseptr Then
        Begin
          repeat
            lpHuntMe:=pointer(UINT(lpItem)+UINT(p_lpOffset));
            bGotIT:=(comparedword(p_lpWhat^, lpHuntMe^,iCalcSize)=0);
          Until bGotIT OR (not MoveNext);
        End
        Else Begin
          //riteln('foundbinary Repeat Loop...BEGIN');
          repeat
            lpHuntMe:=pointer(UINT(JFC_DLITEM(lpItem).lpPtr)+UINT(p_lpOffset));
            //riteln('comparebyte call... p_iSize:',p_iSize);
            bGotIT:=(comparedword(p_lpWhat^, lpHuntMe^,iCalcSize)=0);
            //riteln('Back from comparebyte call... p_iSize:',p_iSize);
            //riteln('lpHuntMe:',cardinal(lpHuntMe),' bGotIt:',bGotIt,' N:',N, ' lpItem:',cardinal(lpITem));
          Until bGotIT OR (not MoveNext);
          //riteln('foundbinary Repeat Loop...DONE');
        End;
      end
      else
      begin
        if(p_iSize mod 2)=0 then
        begin
          iCalcSize:=p_iSize div 2;
          //MoveFirst;
          If not p_buseptr Then
          Begin
            repeat
              lpHuntMe:=pointer(UINT(lpItem)+UINT(p_lpOffset));
              bGotIT:=(compareword(p_lpWhat^, lpHuntMe^,iCalcSize)=0);
            Until bGotIT OR (not MoveNext);
          End
          Else Begin
            //riteln('foundbinary Repeat Loop...BEGIN');
            repeat
              lpHuntMe:=pointer(UINT(JFC_DLITEM(lpItem).lpPtr)+UINT(p_lpOffset));
              //riteln('comparebyte call... p_iSize:',p_iSize);
              bGotIT:=(compareword(p_lpWhat^, lpHuntMe^,iCalcSize)=0);
              //riteln('Back from comparebyte call... p_iSize:',p_iSize);
              //riteln('lpHuntMe:',cardinal(lpHuntMe),' bGotIt:',bGotIt,' N:',N, ' lpItem:',cardinal(lpITem));
            Until bGotIT OR (not MoveNext);
            //riteln('foundbinary Repeat Loop...DONE');
          End;
        end
        else
        begin
          //MoveFirst;
          If not p_buseptr Then
          Begin
            repeat
              lpHuntMe:=pointer(UINT(lpItem)+UINT(p_lpOffset));
              bGotIT:=(comparebyte(p_lpWhat^, lpHuntMe^,p_iSize)=0);
            Until bGotIT OR (not MoveNext);
          End
          Else Begin
            //riteln('foundbinary Repeat Loop...BEGIN');
            repeat
              lpHuntMe:=pointer(UINT(JFC_DLITEM(lpItem).lpPtr)+UINT(p_lpOffset));
              //riteln('comparebyte call... p_iSize:',p_iSize);
              bGotIT:=(comparebyte(p_lpWhat^, lpHuntMe^,p_iSize)=0);
              //riteln('Back from comparebyte call... p_iSize:',p_iSize);
              //riteln('lpHuntMe:',cardinal(lpHuntMe),' bGotIt:',bGotIt,' N:',N, ' lpItem:',cardinal(lpITem));
            Until bGotIT OR (not MoveNext);
            //riteln('foundbinary Repeat Loop...DONE');
          End;
        end;
      end;
    End;
//    end;
    Result:=bGotIT;
    If not Result Then 
    Begin
      lpItem:=TempPtr;
      iNN:=TempN;
    End;
  End;
  //riteln('Leaving JFC_DL.FoundBinary...(iItems:',iItems,')');
End;
//=============================================================================


//=============================================================================
Function JFC_DL.FoundAnsiString(
  p_saString: AnsiString;
  p_bCaseSensitive: Boolean;
  p_lpOffset: pointer;
  p_bStartAtBegin: Boolean;
  p_bUsePtr: Boolean):Boolean;
//=============================================================================
Var TempPtr: pointer;
    TempN: LongInt;
    //iTrueOffset: LongInt;
    bGotIt: Boolean;

    saSearchFor: AnsiString;
    saSearchIn: AnsiString;

Begin
  Result:=False;
  If iItems>0 Then
  Begin
    TempPtr:=lpItem;
    TempN:=iNN;
    If not p_bCaseSensitive Then saSearchFor:=Upcase(p_saString) Else saSearchFor:=p_saString;
    bGotIt:=False;
    If (p_bStartAtBegin and MoveFirst) OR
       ((not p_bStartAtBegin) and MoveNext) Then
    Begin
      If not p_bUsePtr Then Begin
        repeat
          If not p_bCaseSensitive Then
            saSearchIn:=upcase(AnsiString(pointer(UINT(lpItem)+UINT(p_lpOffset))^))
          Else
            saSearchIn:=AnsiString(pointer(UINT(lpItem)+UINT(p_lpOffset))^);
          bGotIt:=(saSearchFor=saSearchIn);
        Until bGotIT OR (not MoveNext);
      End
      Else Begin
        repeat
          If not p_bCaseSensitive Then
            saSearchIn:=upcase(AnsiString(pointer(UINT(JFC_DLITEM(lpItem).lpPtr)+UINT(p_lpOffset))^))
          Else
            saSearchIn:=AnsiString(pointer(Cardinal(JFC_DLITEM(lpItem).lpPtr)+Cardinal(p_lpOffset))^);
          bGotIt:=(saSearchFor=saSearchIn);
        Until bGotIT OR (not MoveNext);
      End;
    End;
    Result:=bGotIT;
    If not Result Then 
    Begin
      lpItem:=TempPtr;
      iNN:=TempN;
    End;
  End;
End;
//=============================================================================


// Result:=JFC_DL.FoundTimeStamp(p_tsFrom, p_tsTo: TTIMESTAMP, 
//                             @TYOURITEMCLASS(nil).FindThisTimeStampField;
//                             bStartAtBegin,bUsePointer); (means use DLITEM.lpPTR)
//=============================================================================
Function JFC_DL.FoundTimestamp(
    p_tsFrom: TTIMESTAMP;
    p_tsTo: TTIMESTAMP;
    p_lpOffset: pointer;
    p_bStartAtBegin: Boolean;
    p_bUsePtr: Boolean):Boolean;
//=============================================================================
Var lpBookMark: pointer;
    iTempN: LongInt;
    lpTimeStamp: ^TTIMESTAMP;
    bGotIt: Boolean;


//===========================================
// NOTE: I didn't know how to overload an operator in FREEPASCAL at the
// time I wrote this 2006-09-15 7:13 PM (Jason P Sage Here) so This is 
// the Equivalent - See FreePascal's dateutils unit. Has a similiar
// function but is based on TDateTime - THEREFORE - because I'm under the 
// impression that TTimeStamp has greater resolution, I'm going with it.
// It is my understanding TTimeStamp has the Following Structure,
// hence what this code is based on:
//    TTIMESTAMP = Record
//      Time: LongInt; { Number of milliseconds since midnight }
//      Date: LongInt; { One plus number of days since 1/1/0001 }
//    End ;
Function bTimeStamp_GreaterThan(p_tsIsThisTimeStamp,{greater than} p_tsThisOne: TTIMESTAMP): Boolean;
Begin
  If p_tsIsThisTimeStamp.date>p_tsThisOne.date Then
    Result:=True
  Else
    If p_tsIsThisTimeStamp.date<p_tsThisOne.date Then
      Result:=False
    Else
      If p_tsIsThisTimeStamp.time>p_tsThisOne.time Then
        Result:=True
      Else
        Result:=False;
End;
Function bTimeStamp_LessThan(p_tsIsThisTimeStamp,{less than} p_tsThisOne: TTIMESTAMP): Boolean;
Begin
  If p_tsIsThisTimeStamp.date<p_tsThisOne.date Then
    Result:=True
  Else
    If p_tsIsThisTimeStamp.date>p_tsThisOne.date Then
      Result:=False
    Else
      If p_tsIsThisTimeStamp.time<p_tsThisOne.time Then
        Result:=True
      Else
        Result:=False;
End;
Function bTimeStamp_EqualTo(p_tsIsThisTimeStamp,{EQUALTO} p_tsThisOne: TTIMESTAMP): Boolean;
Begin
  Result:=(p_tsIsThisTimeStamp.date=p_tsThisOne.date) and 
          (p_tsIsThisTimeStamp.time=p_tsThisOne.time);
End;
//===========================================

Begin
  Result:=False;
  If iItems>0 Then
  Begin
    lpBookMark:=lpItem;
    iTempN:=iNN;
    bGotIt:=False;  
    If (p_bStartAtBegin and MoveFirst) OR
       ((not p_bStartAtBegin) and MoveNext) Then
    Begin
      If not p_buseptr Then
      Begin
        repeat
          lpTimeStamp:=pointer(UINT(lpItem)+UINT(p_lpOffset));
          bGotIt:=
            (bTimeStamp_GreaterThan(lpTimeStamp^,p_tsFrom) OR
            bTimeStamp_EqualTo(lpTimeStamp^,p_tsFrom))
            and
            (bTimeStamp_LessThan(lpTimeStamp^,p_tsTo) OR
            bTimeStamp_EqualTo(lpTimeStamp^,p_tsTo));
        Until bGotIT OR (not MoveNext);
      End
      Else Begin
        repeat
          lpTimeStamp:=pointer(UINT(JFC_DLITEM(lpItem).lpPtr)+UINT(p_lpOffset));
          bGotIt:=
            (bTimeStamp_GreaterThan(lpTimeStamp^,p_tsFrom) OR
            bTimeStamp_EqualTo(lpTimeStamp^,p_tsFrom))
            and
            (bTimeStamp_LessThan(lpTimeStamp^,p_tsTo) OR
            bTimeStamp_EqualTo(lpTimeStamp^,p_tsTo));
        Until bGotIT OR (not MoveNext);
      End;
    End;
    Result:=bGotIT;
    If not Result Then 
    Begin
      lpItem:=lpBookMark;
      iNN:=iTempN;
    End;
  End;
End;
//=============================================================================

































//=============================================================================
Function JFC_DL.FoundItem(p_lp: pointer):Boolean;
//=============================================================================
Begin
  If iItems>0 Then Begin
    If lpItem<>p_lp Then Begin
      MoveFirst;
      repeat Until (not MoveNext) OR (lpItem=p_lp);
    End;
    Result:=lpItem=p_lp;
  End
  Else Result:=False;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.FoundItem_lpPTR(p_lp: pointer):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_lp, SizeOf(pointer), 
                       @JFC_DLITEM(nil).lpPtr, True, False);

End;
//=============================================================================

//=============================================================================
Function JFC_DL.FNextItem_lpPTR(p_lp: pointer):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_lp, SizeOf(pointer), 
                       @JFC_DLITEM(nil).lpPtr, False, False);
End;
//=============================================================================



//=============================================================================
Procedure JFC_DL.SwapItems(p_lpItem1, p_lpItem2: pointer);
//=============================================================================
Var 
lpTempPrev1: pointer;
lpTempNext1: pointer;

Begin
  
  // Make Sure BOL and EOL Stuff Stays Valid
  If JFC_DLITEM(p_lpItem1).lpPrev=nil Then lpFirst:=p_lpItem2;
  If JFC_DLITEM(p_lpItem1).lpNext=nil Then lpLast:= p_lpItem2;
  If JFC_DLITEM(p_lpItem2).lpPrev=nil Then lpFirst:=p_lpItem1;
  If JFC_DLITEM(p_lpItem2).lpNext=nil Then lpLast:= p_lpItem1;
 
  // Are we pointing at each other?
  //----lpItem2 is Directly iNN front of lpItem1
  If JFC_DLITEM(p_lpItem1).lpPrev = p_lpItem2 Then
  Begin
    JFC_DLITEM(p_lpItem1).lpPrev:=JFC_DLITEM(p_lpItem2).lpPrev;
    JFC_DLITEM(p_lpItem2).lpNext:=JFC_DLITEM(p_lpItem1).lpNext;
    If JFC_DLITEM(p_lpItem1).lpPrev<>nil Then
      JFC_DLITEM(JFC_DLITEM(p_lpItem1).lpPrev).lpNext:=p_lpItem1;
    If JFC_DLITEM(p_lpItem2).lpNext<>nil Then
      JFC_DLITEM(JFC_DLITEM(p_lpItem2).lpNext).lpPrev:=p_lpItem2;
    JFC_DLITEM(p_lpItem2).lpPrev:=p_lpItem1;
    JFC_DLITEM(p_lpItem1).lpNext:=p_lpItem2;  
  End
  Else
  
  //----lpItem1 is Directly iNN front of lpItem2
  If JFC_DLITEM(p_lpItem1).lpNext = p_lpItem2 Then
  Begin
    JFC_DLITEM(p_lpItem2).lpPrev:=JFC_DLITEM(p_lpItem1).lpPrev;
    JFC_DLITEM(p_lpItem1).lpNext:=JFC_DLITEM(p_lpItem2).lpNext;
    If JFC_DLITEM(p_lpItem2).lpPrev<>nil Then
      JFC_DLITEM(JFC_DLITEM(p_lpItem2).lpPrev).lpNext:=p_lpItem2;
    If JFC_DLITEM(p_lpItem1).lpNext<>nil Then
      JFC_DLITEM(JFC_DLITEM(p_lpItem1).lpNext).lpPrev:=p_lpItem1;
    JFC_DLITEM(p_lpItem1).lpPrev:=p_lpItem2;
    JFC_DLITEM(p_lpItem2).lpNext:=p_lpItem1;  
  End
  Else 
  //----lpItem1 and lpItem2 are not "touching"
  Begin
    lpTempPrev1:=JFC_DLITEM(p_lpItem1).lpPrev;
    lpTempNext1:=JFC_DLITEM(p_lpItem1).lpNext;
  
    JFC_DLITEM(p_lpItem1).lpPrev:=JFC_DLITEM(p_lpItem2).lpPrev;
    JFC_DLITEM(p_lpItem1).lpNext:=JFC_DLITEM(p_lpItem2).lpNext;
    
    JFC_DLITEM(p_lpItem2).lpPrev:=lpTempPrev1;
    JFC_DLITEM(p_lpItem2).lpNext:=lpTempNext1;

    If JFC_DLITEM(p_lpItem1).lpPrev<>nil Then
    Begin
      JFC_DLITEM(JFC_DLITEM(p_lpItem1).lpPrev).lpNext:=p_lpItem1;
    End;
    
    If JFC_DLITEM(p_lpItem1).lpNext<>nil Then
    Begin
      JFC_DLITEM(JFC_DLITEM(p_lpItem1).lpNext).lpPrev:=p_lpItem1;
    End;
    
    If JFC_DLITEM(p_lpItem2).lpPrev<>nil Then
    Begin
      JFC_DLITEM(JFC_DLITEM(p_lpItem2).lpPrev).lpNext:=p_lpItem2;
    End;
    
    If JFC_DLITEM(p_lpItem2).lpNext<>nil Then
    Begin
      JFC_DLITEM(JFC_DLITEM(p_lpItem2).lpNext).lpPrev:=p_lpItem2;
    End;

  End;  
End;
//=============================================================================

//=============================================================================
Procedure JFC_DL.SwapItem_lpPtr(p_lpItem1, p_lpItem2: pointer);
//=============================================================================
Var 
  lpTemp: pointer;

//=============================================================================
Begin
  lpTemp:=JFC_DLITEM(p_lpItem1).lpPtr;
  JFC_DLITEM(p_lpItem1).lpPtr:=JFC_DLITEM(p_lpItem2).lpPtr;
  JFC_DLITEM(p_lpItem2).lpPtr:=lpTemp;
End;
//=============================================================================



//=============================================================================
Function JFC_DL.SortBinary(
    p_iSize: LongInt;
    p_lpOffset: pointer;
    p_bAscending: Boolean;
    p_bUsePtr: Boolean
):Boolean;
//=============================================================================
Var 
  lpBookMark: pointer;
  i1,i2: LongInt;
  iCompare: LongInt;
  lpItem1: pointer;
  lpItem2: pointer;
  
  //userCheck: function(p_lp1, p_lp2: pointer):boolean;
  //bSwapEm: boolean;
  
Begin
  // bubble sort method 
  // Because I didn't know how else to do it for this kind of sort in a double
  // linked list. Other Methods would likely be hindered speed wise because
  // of the way the navigation works. I'm not sure though, but usually fast
  // sorting algorithms work on an array of a set datatype. This is different.
  // This is double linked list that each element is indeed a class, which
  // may contain pointers to other instantiated classes. Its not so bad as is.
  Result:=(not bCopy) and (iItems>0);
  If iItems>1 Then Begin// Do Actual Sort
    If not p_busePtr Then Begin
      lpBookMark:=lpItem;
      //i1:=1;
      //while i1<= iItems do begin
      For i1:=1 To iItems Do Begin
        MoveFirst;
        i2:=1;
        While i2<=iItems-1 Do Begin
        //for i2:=1 to iItems-1 do begin
          lpItem1:=lpItem;
          lpItem2:=JFC_DLITEM(lpITem).lpNext;
          iCompare:=CompareByte(
            pointer(UINT(lpItem1)+UINT(p_lpOffSet))^,
            pointer(UINT(lpItem2)+UINT(p_lpOffSet))^,
           p_iSize
          );
          If ((iCompare>0) and (p_bAscending)) OR
             ((iCompare<0) and (not p_bAscending)) Then
          Begin // ascending
            SwapItems(lpItem1, lpItem2);
            i2+=1;
          End;
          movenext;
          i2+=1;
        End;
      End;
      FoundItem(lpBookMark);
    End Else Begin
      // Finds First SAME VALUE pointer - If you have dupes you need another way to 
      // 100% accuracy
      lpBookMark:=JFC_DLITEM(lpItem).lpPtr;
      For i1:=1 To iItems Do Begin
        MoveFirst;
        i2:=1;
        While i2<=iItems-1 Do Begin
        //for i2:=1 to iItems-1 do begin
          lpItem1:=lpItem;
          lpItem2:=JFC_DLITEM(lpITem).lpNext;
          {$IFDEF CPU32}
            iCompare:=CompareByte(
              pointer(UINT(JFC_DLITEM(lpItem1).lpPtr)+UINT(p_lpOffSet))^,
              pointer(UINT(JFC_DLITEM(lpItem2).lpPtr)+UINT(p_lpOffSet))^,
              p_iSize
            );
          {$ELSE}
            iCompare:=CompareByte(
              pointer(UInt64(JFC_DLITEM(lpItem1).lpPtr)+UInt64(p_lpOffSet))^,
              pointer(UInt64(JFC_DLITEM(lpItem2).lpPtr)+UInt64(p_lpOffSet))^,
              p_iSize
            );
          {$ENDIF}
          If ((iCompare>0) and (p_bAscending)) OR
             ((iCompare<0) and (not p_bAscending)) Then
          Begin // ascending
            SwapItem_lpPtr(lpItem1, lpItem2);
            i2+=1;
          End;
          movenext;
          i2+=1
        End;
      End;
      FoundItem_lpPTR(lpBookMark);
    End;
  End;
End;
//=============================================================================


//=============================================================================
// THIS is a slow Bubble Sort - Though Pointer method faster paradigm
// Then trying to sort the ACTUALLY pointers that control the DL navigation
//=============================================================================
Function JFC_DL.SortAnsistring(
  p_bCaseSensitive: Boolean;
  p_lpOffset: pointer;
  p_bAscending: Boolean;
  p_bUsePtr: Boolean
 ):Boolean;
//=============================================================================
Var 
  lpBookMark: pointer;
  i1,i2: LongInt;
  lpItem1: pointer;
  lpItem2: pointer;
  
  //userCheck: function(p_lp1, p_lp2: pointer):boolean;
  //bSwapEm: boolean;
Begin
 
  // bubble sort method 
  // Because I didn't know how else to do it for this kind of sort iNN a double
  // linked list.
  Result:=(not bCopy) and (iItems>0);
  
  // Same Algorythm Split into "TYPE" for effieciency hopefully - 
  // Figure out "METHOD" first then do just that...less if this do that
  // during loop
  If iItems>1 Then Begin// Do Actual Sort
    If not p_busePtr Then Begin
      lpBookMark:=lpItem;
      If p_bAscending Then Begin
        If not p_bCaseSensitive Then Begin
          
          // NOT Case sensitive, Ascending, NOT using lpPtr
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If UPCASE(AnsiString( pointer(UINT(lpItem1)+UINT(p_lpOffset))^) ) >
                 UPCASE(AnsiString( pointer(UINT(lpItem2)+UINT(p_lpOffset))^) )
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End Else Begin

          // Case sensitive, Ascending, NOT using lpPtr
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If AnsiString( pointer(UINT(lpItem1)+UINT(p_lpOffset))^)  >
                 AnsiString( pointer(UINT(lpItem2)+UINT(p_lpOffset))^)
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End;

      End Else Begin

        If not p_bCaseSensitive Then Begin
          
          // NOT Case sensitive, DESCENDING, NOT using lpPtr
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If UPCASE(AnsiString( pointer(UINT(lpItem1)+UINT(p_lpOffset))^) ) <
                 UPCASE(AnsiString( pointer(UINT(lpItem2)+UINT(p_lpOffset))^) )
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End Else Begin

          // Case sensitive, DESCENDING, NOT using lpPtr
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If AnsiString( pointer(UINT(lpItem1)+UINT(p_lpOffset))^)  <
                 AnsiString( pointer(UINT(lpItem2)+UINT(p_lpOffset))^)
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End;

      End;
      FoundItem(lpBookMark);
    End Else Begin
//POINTER VERSIONS
      // Finds First SAME VALUE pointer - If you have dupes you need another way to 
      // 100% accuracy
      lpBookMark:=JFC_DLITEM(lpItem).lpPtr;

      If p_bAscending Then Begin
        If not p_bCaseSensitive Then Begin
          
          // NOT Case sensitive, Ascending, USING lpPTR
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If UPCASE(AnsiString( pointer(UINT(JFC_DLITEM(lpItem1).lpPtr)+UINT(p_lpOffset))^) ) >
                 UPCASE(AnsiString( pointer(UINT(JFC_DLITEM(lpItem2).lpPtr)+UINT(p_lpOffset))^) )
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End Else Begin

          // Case sensitive, Ascending, USING POINTER
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If AnsiString( pointer(UINT(JFC_DLITEM(lpItem1).lpPtr)+UINT(p_lpOffset))^)  >
                 AnsiString( pointer(UINT(JFC_DLITEM(lpItem2).lpPtr)+UINT(p_lpOffset))^)
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End;

      End Else Begin

        If not p_bCaseSensitive Then Begin
          
          // NOT Case sensitive, DESCENDING, USING POINTER
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If UPCASE(AnsiString( pointer(UINT(JFC_DLITEM(lpItem1).lpPtr)+UINT(p_lpOffset))^) ) <
                 UPCASE(AnsiString( pointer(UINT(JFC_DLITEM(lpItem2).lpPtr)+UINT(p_lpOffset))^) )
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End Else Begin

          // Case sensitive, DESCENDING, USING POINTER
          For i1:=1 To iItems Do Begin
            MoveFirst;
            i2:=1;
            While i2<= iItems-1 Do Begin
            //for i2:=1 to iItems-1 do begin
              lpItem1:=lpItem;
              lpItem2:=JFC_DLITEM(lpITem).lpNext;
              If AnsiString( pointer(UINT(JFC_DLITEM(lpItem1).lpPtr)+UINT(p_lpOffset))^)  <
                 AnsiString( pointer(UINT(JFC_DLITEM(lpItem2).lpPtr)+UINT(p_lpOffset))^)
              Then Begin
                SwapItems(lpItem1, lpItem2);
                i2+=1;
              End;
              movenext;
              i2+=1;
            End;
          End;

        End;

      End;
      FoundItem_lpPTR(lpBookMark);

    End;
  End;   
End;
//=============================================================================












// Returns RAW Values
//=============================================================================
Function JFC_DL.Next_lpItem:pointer; // Pointer to next JFC_DLITEM item (See lpItem)
//=============================================================================
Begin
  Result:=JFC_DLITEM(lpitem).lpNext;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.Prev_lpItem:pointer; // Pointer to next JFC_DLITEM item (See lpItem)
//=============================================================================
Begin
  Result:=JFC_DLITEM(lpitem).lpPrev;
End;
//=============================================================================

//=============================================================================
// Returns RAW value from JFC_DLITEM.lpPtr field Providing the Next or Prev
// record exists - If it doesn't - Currently its designed to just bomb
// for speed reasons
//=============================================================================
Function JFC_DL.NextItem_lpPtr: pointer; // Pointer Value iNN lpPTR from next Iem
//=============================================================================
Begin
  Result:=JFC_DLITEM(JFC_DLITEM(lpitem).lpNext).lpPtr;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.PrevItem_lpPtr: pointer; // Pointer Value iNN lpPTR from next Iem
//=============================================================================
Begin
  Result:=JFC_DLITEM(JFC_DLITEM(lpitem).lpPrev).lpPtr;
End;
//=============================================================================

//=============================================================================
Function JFC_DL.read_item_lpPtr: pointer;
//=============================================================================
Begin
  Result:=JFC_DLITEM(lpItem).lpPtr;
End;
//=============================================================================

//=============================================================================
Procedure JFC_DL.write_item_lpptr(p_lp:pointer);
//=============================================================================
Begin
  JFC_DLITEM(lpItem).lpPtr:=p_lp;
End;
//=============================================================================





//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
