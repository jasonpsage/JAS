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
// Jegas Foundation Class - XDL Double Linked List - Descendant of JFC_DL
Unit ug_jfc_xdl;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_xdl.pp'}
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
  dos,
  sysutils,
  ug_common,
  ug_jfc_dl;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_XDLITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//-----------------------------------------------------------------------------
// declarations
//-----------------------------------------------------------------------------

//=============================================================================
// {}
// JFC_XDLITEM BASE JFC_XDL Linked List Item
Type JFC_XDLITEM = Class(JFC_DLITEM)
//=============================================================================
  Public
  UID: Uint64; //< Unique ID - AutoNumber Handled For you ... "primary Key"
  saName: AnsiString;//< User Data Point - ansistring String. 
  saValue: AnsiString;//< User Data Point - ansistring String. 
  saDesc: AnsiString;//<User Data Point - ansistring String. 
  i8User: int64;  {< User Field for whatever. If you need more fields - 
                     Consider writing your own "DL" from JFC_DL directly
                     using ITEMCLASSES that contain EVERYTHING you are
                     managing. You Could Also Just expand on this one.
                     That's Up to you. I have Found In Tests That You
                     are better off Using the lpPtr field to point to 
                     your own object and work it like that because sorting
                     takes a hit - this isn't quite a dynamic array and 
                     swapping pointers is better then copying fields }
  
  TS:TTIMESTAMP;    {< For general Use, but is set by the sysutils' unit NOW
                     function in the create constructor. }
  {}                    
  Constructor create;
  Destructor Destroy; override;
End;
//=============================================================================



//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_XDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// Base JFC_XDL class
Type JFC_XDL = Class(JFC_DL)
//=============================================================================
  Public 
  //---------------------------------------------------------------------------
  {}
  Function read_item_UID: UInt64;//< make properties work
  Function read_item_saname: AnsiString;//< make properties work
  Procedure write_item_saname(p_sa: AnsiString);//< make properties work
  Function read_item_savalue: AnsiString; //< make properties work
  Procedure write_item_savalue(p_sa:AnsiString); //< make properties work
  Function read_item_sadesc: AnsiString;//< make properties work
  Procedure write_item_sadesc(p_sa:AnsiString);//< make properties work
  Function read_item_i8User: Int64;//< make properties work
  Procedure write_item_i8User(p_i8: Int64);//< make properties work
  {}
  // Sorry - Compiler Doesn't support this TYPE for Property Access.
  //Function read_item_ts: TTIMESTAMP;
  //Procedure write_item_ts(p_ts: TTIMESTAMP);
  //Property Item_TS: TDATETIME read read_item_ts Write write_item_ts;
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  {}
  public
  Function pvt_CreateItem: JFC_XDLITEM; override; //< Override if you make descendant of JFC_DLITEM with more fields or something.
  Procedure pvt_createtask; override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  Procedure pvt_DestroyItem(p_lp:pointer); override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  Procedure pvt_destroytask(p_lp:pointer); override;  //< Override if you make descendant of JFC_DLITEM with more fields or something.
  {}
  //---------------------------------------------------------------------------
  
  Public
  {}
  Constructor create; //< OVERRIDE BUT INHERIT
  Destructor Destroy; override;  //< OVERRIDE BUT INHERIT
  {}
  
  //---------------------------------------------------------------------------
  {}
  Property Item_UID: UInt64 read read_item_UID; //< No Checks Are made - Using this property when the list is empty will cause a runtime error.
  Property Item_saName: AnsiString read read_item_saname Write write_item_saname; //< No Checks Are made - Using this property when the list is empty will cause a runtime error.
  Property Item_saValue: AnsiString read read_item_savalue Write write_item_savalue;  //< No Checks Are made - Using this property when the list is empty will cause a runtime error.
  Property Item_saDesc: AnsiString read read_item_saDesc Write write_item_sadesc; //< No Checks Are made - Using this property when the list is empty will cause a runtime error.
  Property Item_i8User: Int64 read read_item_i8User Write write_item_i8User; //< No Checks Are made - Using this property when the list is empty will cause a runtime error.
  {}
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  {}  
  Function FoundItem_UID(p_u8: UInt64):Boolean;//< Find Matching Item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find first matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find Next Matching Item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_saValue(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find first matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saValue(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find Next matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_saDesc(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find first matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saDesc(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find Next matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.

  Function FoundItem_saName(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
  Function FNextItem_saName(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
  Function FoundItem_saValue(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
  Function FNextItem_saValue(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
  Function FoundItem_saDesc(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
  Function FNextItem_saDesc(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive




  {}
  // Find first match
  // This Finds Name & Value At Same Time
  // This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_saName_N_saValue(
             p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
             p_saValue: AnsiString; p_bValueCaseSensitive: Boolean
  ):Boolean;
  {}
  // Find Next Match
  // This Finds Name & Value At Same Time
  // This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saName_N_saValue(
             p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
             p_saValue: AnsiString; p_bValueCaseSensitive: Boolean
  ):Boolean;
  
  
  {}
  // This finds first item with matching criteria for both Name and Desc fields.
  // This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_saName_N_saDesc(
             p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
             p_saDesc: AnsiString; p_bDescCaseSensitive: Boolean
  ):Boolean;
  {}
  // This finds next item with matching criteria for both Name and Desc fields.
  // This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saName_N_saDesc(
             p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
             p_saDesc: AnsiString; p_bDescCaseSensitive: Boolean
  ):Boolean;

  // Search for first item with matching i8User Value. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_i8User(p_i8:Int64): Boolean;
  // Search for next item with Matching i8User Value. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_i8User(p_i8:Int64): Boolean;


  // Search for First item with matching TimeStamp - This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundItem_TS(p_tsFrom, p_tsTo: TTIMESTAMP):Boolean;
  // Search for Next matching TimeStamp - This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FoundNext_TS(p_tsTo:TTIMESTAMP):Boolean;
  //---------------------------------------------------------------------------





  //---------------------------------------------------------------------------
  {}
  // NOW this is kinda special! Yes - Its a search and Replace routine BUT
  // This is for when You Want to do MULTIPLE Searches and
  // replaces to a string with ONE CALL! How It works is simple - First -
  // Create an Instance of this class naturally - THEN Create "ITEMS". The
  // important fields here are saName and saValue. Each "Item" in the linked
  // list is a SEARCHFOR and REPLACEWITH parameter pair. Put SEARCHFOR string
  // in saName and REPLACEWITH string in saValue - Add as many as you want
  // THEN call this routine with the string you want SEARCH'd and Replace'd
  // it returns the CONVERTED result back to you. This Definately is special
  // purpose - it was intended to give a WHOLE new Reason to use this class.
  Function SNR(p_sa:AnsiString; p_bCaseSensitive:Boolean): AnsiString;
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  //public
  //---------------------------------------------------------------------------
  {}
  Function AppendItem_saName(p_saName:AnsiString):Boolean;
  Function InsertItem_saName(p_saName:AnsiString):Boolean;
  Function AppendItem_saValue(p_saValue:AnsiString):Boolean;
  Function InsertItem_saValue(p_saValue:AnsiString):Boolean;
  Function AppendItem_saName_N_saDesc(p_saName, p_saDesc: AnsiString): Boolean;
  Function InsertItem_saName_N_saDesc(p_saName, p_saDesc: AnsiString): Boolean;
  Function AppendItem_saName_N_saValue(p_saName, p_saValue: AnsiString): Boolean;
  Function InsertItem_saName_N_saValue(p_saName, p_saValue: AnsiString): Boolean;
  Function AppendItem_saName_saValue_saDesc(p_saName, p_saValue, p_saDesc: AnsiString): Boolean;
  Function InsertItem_saName_saValue_saDesc(p_saName, p_saValue, p_saDesc: AnsiString): Boolean;
  {}
  //---------------------------------------------------------------------------

  // New this generation - Conveinance stuff
  //---------------------------------------------------------------------------
  {}
  Function AppendItem_i8User(p_i8User: Int64): Boolean;
  Function InsertItem_i8User(p_i8User: Int64): Boolean;
  Function AppendItem_XDL(p_lpPtr: pointer;
                       p_saName, p_saValue, p_saDesc: AnsiString;
                       p_i8User: Int64
                       ): Boolean;
  Function InsertItem_XDL(p_lpPtr: pointer;
                       p_saName, p_saValue, p_saDesc: AnsiString;
                       p_i8User: Int64
                       ): Boolean;

  Function AppendItem_SNRPair(
    p_saSearchFor, p_saReplacewith: AnsiString): Boolean;
  Function InsertItem_SNRPair(
    p_saSearchFor, p_saReplacewith: AnsiString): Boolean;
  Procedure DumpToTextFile(p_sa: AnsiString);
  Procedure DumpToTextFile(p_sa:AnsiString; Var p_u2IOResult: Word);
  Function SortItem_saName(
    p_bCaseSensitive: Boolean;    p_bAscending: Boolean  ):Boolean;
  Function SortItem_saValue(
    p_bCaseSensitive: Boolean;  p_bAscending: Boolean):Boolean;
  Function SortItem_saDesc(
    p_bCaseSensitive: Boolean;  p_bAscending: Boolean):Boolean;
    
    
  // Create HTML to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones mostly fixed implementation.
  Function saHTMLTable: AnsiString;// Uses Defaults
  // Create HTML to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones mostly fixed implementation - but this version gives you much more control of the output than the version that doesn't take parameters.
  Function saHTMLTable(
    p_saTableTagInsert: AnsiString;
  
    p_bTableCaption: Boolean;
    p_saTableCaption: AnsiString;
    p_bTableCaptionShowRowCount: Boolean;
    
    p_bTableHEAD: Boolean;
    
    p_saNHEADText: AnsiString;
    p_iNCol: Integer;
  
    p_salpPTRHEADText: AnsiString;
    p_ilpPtrCol: Integer;// zero = Don't Display
  
    p_saUIDHEADText: AnsiString;
    p_iUIDCol: Integer;
  
    p_sasaNameHEADText: AnsiString;
    p_isaNameCol: Integer;
  
    p_sasaValueHEADText: AnsiString;
    p_isaValueCol: Integer;
  
    p_sasaDescHEADText: AnsiString;
    p_isaDescCol: Integer;
  
    p_sai8UserHEADText: AnsiString;
    p_ii8UserCol: Integer;

    p_saTSHEADText: AnsiString;
    p_iTSCol: Integer

  ):AnsiString;

  // Create xml to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones mostly fixed implementation.
  Function saXML: AnsiString;// Uses Defaults
  // Create xml to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones mostly fixed implementation. but this version gives you much more control of the output than the version that doesn't take parameters.
  {
  Function saXML(
    p_saRootPropertyInsert: AnsiString;
  
    p_bTableCaption: Boolean;
    p_saTableCaption: AnsiString;
    p_bTableCaptionShowRowCount: Boolean;
    
    p_saNHEADText: AnsiString;
    p_iNCol: Integer;
  
    p_salpPTRHEADText: AnsiString;
    p_ilpPtrCol: Integer;//< zero = Don't Display
  
    p_saUIDHEADText: AnsiString;
    p_iUIDCol: Integer;
  
    p_sasaNameHEADText: AnsiString;
    p_isaNameCol: Integer;
  
    p_sasaValueHEADText: AnsiString;
    p_isaValueCol: Integer;
  
    p_sasaDescHEADText: AnsiString;
    p_isaDescCol: Integer;
  
    p_sai8UserHEADText: AnsiString;
    p_ii8UserCol: Integer
  ):AnsiString;
  }




  function Get_Item(p_saName: ansistring): pointer;
  function Get_ItemCS(p_saName: ansistring): pointer;
  
  Function Get_saValue(p_saName: AnsiString):AnsiString;
  Function Get_saValueCS(p_saName: AnsiString):AnsiString;
  Function Get_saDesc(p_saName: AnsiString):AnsiString;
  Function Get_saDescCS(p_saName: AnsiString):AnsiString;

  procedure Set_saValue(p_saName: AnsiString; p_saValue: ansistring);
  procedure Set_saValueCS(p_saName: AnsiString; p_saValue: ansistring);
  procedure Set_saDesc(p_saName: AnsiString; p_saDesc: ansistring);
  procedure Set_saDescCS(p_saName: AnsiString; p_saDesc: ansistring);

  //=============================================================================
  {}
  // This procedure empties the list and loads it with the current ENV Variables.
  Procedure LoadXDLWithEnvVar;
  //=============================================================================
  {}
  // This procedure empties the list and loads it with parameters passed to the program from the command line.
  Procedure LoadXDLWithParams;
  //=============================================================================

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
//=============================================================================
//*****************************************************************************
//
// JFC_XDLITEM Routines          BASE JFC_XDLITEM "itemclass"
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor JFC_XDLITEM.create;
//=============================================================================
Begin
  Inherited;
  saClassName:='JFC_XDLITEM';
  UID:=0;
  saName:='';
  saValue:='';
  saDesc:='';
  i8User:=0;
  TS:=DateTimeToTimeStamp(Now);
End;
//=============================================================================

//=============================================================================
Destructor JFC_XDLITEM.Destroy;
//=============================================================================
Begin
  saClassname:='';
  saName:='';
  saValue:='';
  saDesc:='';
  Inherited;
End;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_XDL Routines          BASE JFC_XDL Dynamic Double Linked List
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor JFC_XDL.create;
//=============================================================================
Begin
  Inherited;  
  saClassName:='JFC_XDL';
End;
//=============================================================================

//=============================================================================
Destructor JFC_XDL.Destroy;
//=============================================================================
Begin
  saClassName:='';
  Inherited;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.read_item_UID: UInt64;
//=============================================================================
Begin
  Result:=JFC_XDLITEM(lpItem).UID;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.read_item_saname: AnsiString;
//=============================================================================
Begin
  Result:=JFC_XDLITEM(lpItem).saName;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.write_item_saname(p_sa: AnsiString);
//=============================================================================
Begin
  JFC_XDLITEM(lpItem).saName:=p_sa;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.read_item_sadesc: AnsiString;
//=============================================================================
Begin
  Result:=JFC_XDLITEM(lpItem).saDesc;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.write_item_sadesc(p_sa:AnsiString);
//=============================================================================
Begin
  JFC_XDLITEM(lpItem).saDesc:=p_sa;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.read_item_savalue: AnsiString;
//=============================================================================
Begin
  Result:=JFC_XDLITEM(lpItem).savalue;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.write_item_savalue(p_sa:AnsiString);
//=============================================================================
Begin
  JFC_XDLITEM(lpItem).savalue:=p_sa;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.read_item_i8User: Int64;
//=============================================================================
Begin
  Result:=JFC_XDLITEM(lpItem).i8User;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.write_item_i8User(p_i8:Int64);
//=============================================================================
Begin
  JFC_XDLITEM(lpItem).i8User:=p_i8;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.pvt_CreateItem: JFC_XDLITEM;  
//=============================================================================
Begin
  Result:=JFC_XDLITEM.create;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.pvt_createtask;
//=============================================================================
Begin
  JFC_XDLITEM(lpItem).UID:=AutoNumber;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.pvt_DestroyItem(p_lp:pointer); 
//=============================================================================
Begin
  // This code is for NESTED JFC_XDL ONLY!!! Do NOT Inherit this procedure!!!!!
  // MAKE YOUR OWN!
  if bDestroyNestedLists then 
  begin
    if(JFC_XDLITEM(p_lp).lpPtr <> nil)then
    begin
      JFC_XDL(JFC_XDLITEM(p_lp).lpPtr).DeleteAll;
      JFC_XDL(JFC_XDLITEM(p_lp).lpPtr).Destroy;
      JFC_XDLITEM(p_lp).lpPtr:=nil;
    end;
  end;

  JFC_XDLITEM(p_lp).Destroy;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.pvt_destroytask(p_lp:pointer); 
//=============================================================================
Begin
  // This one can be totally overriden
  //p_lp:=p_lp; // shutup compiler;
  Inherited;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.FoundItem_UID(p_u8: UInt64): Boolean;
//=============================================================================
Begin
  If iItems>0 Then
  Begin
    Result:=(p_u8=JFC_XDLITEM(lpITem).UID) OR
      FoundBinary(@p_u8, sizeof(Int64), @JFC_XDLITEM(nil).UID,True, False);
  End Else Result:=False;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.FoundItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saName,
                           True,False);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saName,
                           False,False);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FoundItem_saDesc(p_sa: AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saDesc,
                           True,False);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saDesc(p_sa: AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saDesc,
                           False,False);
End;
//=============================================================================
  
//=============================================================================
Function JFC_XDL.FoundItem_savalue(p_sa: AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saValue,
                           True,False);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saValue(p_sa: AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_XDLITEM(nil).saValue,
                           False,False);
End;
//=============================================================================





//=============================================================================
Function JFC_XDL.FoundItem_saName_N_saDesc(
           p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
           p_saDesc: AnsiString; p_bDescCaseSensitive: Boolean
):Boolean;
//=============================================================================
Var 
  lpBookMArK: pointer;
  bGotIt: Boolean;
  saTempDesc: AnsiString;
Begin
  lpBookMArk:=lpItem;
  Result:=False;
  If iItems>0 Then
  Begin
    bGotIt:=False;
    If not p_bDescCaseSensitive Then 
      saTempDesc:=UpCase(p_saDesc)
    Else
      saTempDesc:=p_saDesc;
      
    If FoundItem_saName(p_saName, p_bNameCaseSensitive) Then
    Begin
      repeat
        If not p_bDescCaseSensitive Then
          bGotIt:= saTempDesc=upcase(JFC_XDLITEM(lpITem).saDesc)
        Else
          bGotIt:= saTempDesc=JFC_XDLITEM(lpITem).saDesc;
      Until bGotIt OR (not (FNextItem_saName(p_saName, p_bNameCaseSensitive)));
    End;
    Result:=bgotit;
  End;
  If not Result Then lpItem:=lpBookMark;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FoundItem_saName_N_saValue(
           p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
           p_saValue: AnsiString; p_bValueCaseSensitive: Boolean
):Boolean;
//=============================================================================
Var 
  lpBookMArK: pointer;
  bGotIt: Boolean;
  saTempValue: AnsiString;
Begin
  lpBookMArk:=lpItem;
  Result:=False;
  If iItems>0 Then
  Begin
    bGotIt:=False;
    If not p_bValueCaseSensitive Then 
      saTempValue:=UpCase(p_saValue)
    Else
      saTempValue:=p_saValue;
      
    If FoundItem_saName(p_saName, p_bNameCaseSensitive) Then
    Begin
      repeat
        If not p_bValueCaseSensitive Then
          bGotIt:= saTempValue=upcase(JFC_XDLITEM(lpITem).saValue)
        Else
          bGotIt:= saTempValue=JFC_XDLITEM(lpITem).saValue;
      Until bGotIt OR (not (FNextItem_saName(p_saName, p_bNameCaseSensitive)));
    End;
    Result:=bgotit;
  End;
  If not Result Then lpItem:=lpBookMark;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.FNextItem_saName_N_saDesc(
           p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
           p_saDesc: AnsiString; p_bDescCaseSensitive: Boolean
):Boolean;
//=============================================================================
Var 
  lpBookMArK: pointer;
  bGotIt: Boolean;
  saTempDesc: AnsiString;
Begin
  lpBookMArk:=lpItem;
  Result:=False;
  If iItems>0 Then
  Begin
    bGotIt:=False;
    If not p_bDescCaseSensitive Then 
      saTempDesc:=UpCase(p_saDesc)
    Else
      saTempDesc:=p_saDesc;
      
    If FNextItem_saName(p_saName, p_bNameCaseSensitive) Then
    Begin
      repeat
        If not p_bDescCaseSensitive Then
          bGotIt:= saTempDesc=upcase(JFC_XDLITEM(lpITem).saDesc)
        Else
          bGotIt:= saTempDesc=JFC_XDLITEM(lpITem).saDesc;
      Until bGotIt OR (not (FNextItem_saName(p_saName, p_bNameCaseSensitive)));
    End;
    Result:=bgotit;
  End;
  If not Result Then lpItem:=lpBookMark;
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.FNextItem_saName_N_saValue(
           p_saName: AnsiString; p_bNameCaseSensitive: Boolean;
           p_saValue: AnsiString; p_bValueCaseSensitive: Boolean
):Boolean;
//=============================================================================
Var 
  lpBookMArK: pointer;
  bGotIt: Boolean;
  saTempValue: AnsiString;
Begin
  lpBookMArk:=lpItem;
  Result:=False;
  If iItems>0 Then
  Begin
    bGotIt:=False;
    If not p_bValueCaseSensitive Then 
      saTempValue:=UpCase(p_saValue)
    Else
      saTempValue:=p_saValue;
      
    If FNextItem_saName(p_saName, p_bNameCaseSensitive) Then
    Begin
      repeat
        If not p_bValueCaseSensitive Then
          bGotIt:= saTempValue=upcase(JFC_XDLITEM(lpITem).saValue)
        Else
          bGotIt:= saTempValue=JFC_XDLITEM(lpITem).saValue;
      Until bGotIt OR (not (FNextItem_saName(p_saName, p_bNameCaseSensitive)));
    End;
    Result:=bgotit;
  End;
  If not Result Then lpItem:=lpBookMark;
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.SNR(p_sa:AnsiString; p_bCaseSensitive:Boolean): AnsiString;
//=============================================================================
Var
  i8: int64;
  sa: AnsiString;
  saUp: AnsiString;
  bSkip: Boolean;
  u8TempPayloadLen: uint64;
  //u8TempItemNameLen: uint64;
  //u8TempItemValueLen: uint64;
  //XDLCOPY: JFC_XDL;
  i8Last: int64;


Begin
  sa:=p_sa;//Cuz we chopping it and its a pointer... we do not
  // want to hack our original in this case.

  u8TempPayloadLen:=length(p_sa);
  //XDLCOPY:=JFC_XDL.CreateCopy(self);

  //If (length(p_sa)>0) and (iItems>0) Then
  If (u8TempPayloadLen>0) and (MoveFirst) Then
  Begin
    //riteln('Got In ...');
    //MoveFirst;
    repeat
      If not p_bCaseSensitive Then saUp:=UpCase(sa);
      i8Last:=0;
      repeat
        //u8TempItemNameLen:= length(trim(JFC_XDLITEM(lpItem).saName));
        //bSkip:=(u8TempItemNameLen = 0);
        //if not bSkip then // commented out because would prevent replacing something with nothing.
        //begin
        //  u8TempItemValueLen:= length(trim(JFC_XDLITEM(lpItem).saValue));
        //  bSkip:=(u8TempItemValueLen = 0);
        //end;

        //if (not bSkip) Then
        //begin
          If (not p_bCaseSensitive) then
          Begin
            i8:=pos(upcase(JFC_XDLITEM(lpItem).saName),saUp);
            //bSkip:=copy(saUp,i8,length(JFC_XDLITEM(lpItem).saName))=Upcase(JFC_XDLITEM(lpItem).saValue);//ORIGINAL
            bSkip:=0<(
              pos(
                copy(saUp,i8,length(JFC_XDLITEM(lpItem).saName)),
                Upcase(JFC_XDLITEM(lpItem).saValue)
              )
            );
          End
          Else
          Begin
            i8:=pos(JFC_XDLITEM(lpItem).saName,sa);
            bSkip:=0<(
              pos(
                copy(sa,i8,length(JFC_XDLITEM(lpItem).saName)),
                JFC_XDLITEM(lpItem).saValue
              )
            );
            //bSkip:=copy(sa,i8,length(JFC_XDLITEM(lpItem).saName))=JFC_XDLITEM(lpItem).saValue;//ORIGINAL
          End;
        //end;


        //-
        if i8Last>0 then
        begin
          if(i8Last=i8) then
          begin
            bSkip:=true;
          end;
        end;
        i8Last:=i8;
        //-

        if (i8>0) then
        begin
          //riteln(ItemName,'<>',sa,'<>',i);
          If (not bSkip) Then
          Begin
            DeleteString(sa, i8, length(JFC_XDLITEM(lpItem).saName));
            //riteln('after delete sa:',sa);
            Insert(JFC_XDLITEM(lpItem).saValue,sa, i8);
            //riteln('after insert sa:',sa);
            If not p_bCaseSensitive Then
            Begin
              DeleteString(saUp, i8, length(JFC_XDLITEM(lpItem).saName));
              Insert(upcase(JFC_XDLITEM(lpItem).saValue),saUp, i8);
            End;
          End;
        end;


      Until bSkip or (i8<1);
    Until not MoveNext;    
  End;
  {else
  Begin
    Writeln('SNR prob...Length p_sa:',length(p_Sa));
    Writeln('iItems:',iItems);
  End;}
  //Writeln('returning>',sa);
  //Writeln('returned length:',length(sa));
  //XDLCOPY.Destroy;
  Result:=sa;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FoundItem_i8User(p_i8:Int64): Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_i8, sizeof(Int64), @JFC_XDLITEM(nil).i8User,True, False);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_i8User(p_i8:Int64): Boolean;  
//=============================================================================
Begin
  Result:=FoundBinary(@p_i8, sizeof(Int64), @JFC_XDLITEM(nil).i8User,False, False);
End;
//=============================================================================




//=============================================================================
Function JFC_XDL.AppendItem_i8User(p_i8User: Int64): Boolean;  
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).i8User:=p_i8User;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_i8User(p_i8User: Int64): Boolean;  
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).i8User:=p_i8User;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_saName(p_saName:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saname;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_saName(p_saName:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saname;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_saValue(p_saValue:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_saValue(p_saValue:AnsiString):Boolean;
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_saName_N_saDesc(p_saName, p_saDesc: AnsiString): Boolean;  
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
  End;
  //Writeln('AppendItem(name,desc Called...returned:',result);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_saName_N_saDesc(p_saName, p_saDesc: AnsiString): Boolean;  
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_saName_N_saValue(p_saName, p_saValue: AnsiString): Boolean;  
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
  End;
  //Writeln('AppendItem(name,Value Called...returned:',result);
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_saName_N_saValue(p_saName, p_saValue: AnsiString): Boolean;  
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_saName_saValue_saDesc(p_saName, p_saValue, p_saDesc: AnsiString): Boolean;
//=============================================================================
begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
  End;
  //Writeln('AppendItem(name,Value Called...returned:',result);
end;
//=============================================================================
  
//=============================================================================
Function JFC_XDL.InsertItem_saName_saValue_saDesc(p_saName, p_saValue, p_saDesc: AnsiString): Boolean;
//=============================================================================
begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
  End;
end;
//=============================================================================


//=============================================================================
Function JFC_XDL.AppendItem_XDL(
  p_lpPtr: pointer;
  p_saName, p_saValue, p_saDesc: AnsiString;
  p_i8User: Int64
): Boolean;  
//=============================================================================
Begin
  Result:=self.AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).lpPtr:=p_lpPtr;
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
    JFC_XDLITEM(lpItem).i8User:=p_i8User;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_XDL(
  p_lpPtr: pointer;
  p_saName, p_saValue, p_saDesc: AnsiString;
  p_i8User: Int64
): Boolean;  
//=============================================================================
Begin
  Result:=self.InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).lpPtr:=p_lpPtr;
    JFC_XDLITEM(lpItem).saName:=p_saName;
    JFC_XDLITEM(lpItem).saValue:=p_saValue;
    JFC_XDLITEM(lpItem).saDesc:=p_saDesc;
    JFC_XDLITEM(lpItem).i8User:=p_i8User;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.AppendItem_SNRPair(
  p_saSearchFor,
  p_saReplacewith: AnsiString
): Boolean;
//=============================================================================
Begin
  Result:=AppendItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saSearchFor;
    JFC_XDLITEM(lpItem).saValue:=p_saReplaceWith;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.InsertItem_SNRPair(
  p_saSearchFor,
  p_saReplacewith: AnsiString
): Boolean;
//=============================================================================
Begin
  Result:=InsertItem;
  If Result Then Begin
    JFC_XDLITEM(lpItem).saName:=p_saSearchFor;
    JFC_XDLITEM(lpItem).saValue:=p_saReplaceWith;
  End;
End;
//=============================================================================


//=============================================================================
Procedure JFC_XDL.DumpToTextFile(p_sa:AnsiString);
//=============================================================================
Var u2IOResult:Word;
Begin
  u2IOResult:=0;// shut up compiler
  DumpToTextFile(p_sa, u2IOResult);
End;
//=============================================================================
Procedure JFC_XDL.DumpToTextFile(p_sa:AnsiString; Var p_u2IOResult: Word);
//=============================================================================
Var f:text;
Begin
  {$I-}
  Assign(f,p_sa);
  rewrite(f);
  p_u2IOResult:=IORESULT;
  {$I+}
  If p_u2IOREsult=0 Then
  Begin
    Writeln(f,'JFC_XDL.DumpToTextFile OutPut - Debug Thingy');
    Writeln(f,'ListCount:',iItems);
    Writeln(f,'UID, lpPTR, iUser, saName, saDesc, saValue, TS');
    If movefirst Then
    Begin
      repeat 
        Writeln(f,'UID:',Item_UID);
        Writeln(f,'lpPTR  :',UINT(Item_lpPtr));
        Writeln(f,'i8User  :',Item_i8User);
        Writeln(f,'saName :',Item_saName);
        Writeln(f,'saDesc :',Item_saDesc);
        Writeln(f,'saValue:',Item_saValue);
        Writeln(f,'TS',TimeStampToDateTime(JFC_XDLITEM(lpItem).TS));
        Writeln(f);
      Until not movenext;
    End;
    {$I-}
    Close(f);
    {$I+}
  End;
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.SortItem_saName(
  p_bCaseSensitive: Boolean;
  p_bAscending: Boolean
):Boolean;
//=============================================================================
Begin
  Result:=SortAnsistring(
    p_bCaseSensitive,
    @JFC_XDLITEM(nil).saName,
    p_bAscending,
    False
  );
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.SortItem_saDesc(
  p_bCaseSensitive: Boolean;
  p_bAscending: Boolean
):Boolean;
//=============================================================================
Begin
  Result:=SortAnsistring(
    p_bCaseSensitive,
    @JFC_XDLITEM(nil).saDesc,
    p_bAscending,
    False
  );
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.SortItem_saValue(
  p_bCaseSensitive: Boolean;
  p_bAscending: Boolean
):Boolean;
//=============================================================================
Begin
  Result:=SortAnsistring(
    p_bCaseSensitive,
    @JFC_XDLITEM(nil).saValue,
    p_bAscending,
    False
  );
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.saHTMLTable: AnsiString;
//=============================================================================
Begin
  Result:=saHTMLTable(
    '',//p_saTableTagInsert: AnsiString;

    True, //p_bTableCaption: boolean;
    'ClassName: ' +saClassName+' - Rows',//p_saTableCaption: AnsiString;
    True,//p_bTableCaptionShowRowCount: boolean;
    
    True,//p_bTableHEAD: boolean;
    
    '',//p_NHEADText: AnsiString;
    1,//p_iNCol: integer;// zero = Don't Display

    '',//p_salpPTRHEADText: AnsiString;
    2,//p_ilpPtrCol: integer;// zero = Don't Display
  
    '',//p_saUIDHEADText: AnsiString;
    3,//p_iUIDCol: integer;
  
    '',//p_sasaNameHEADText: AnsiString;
    4,//p_isaNameCol: integer;
  
    '',//p_sasaValueHEADText: AnsiString;
    5,//p_isaValueCol: integer;
  
    '',//p_sasaDescHEADText: AnsiString;
    6,//p_isaDescCol: integer;
  
    '',//p_saiUserHEADText: AnsiString;
    7,//p_iiUserCol: integer;
    
    '',//p_saTSHEADText: AnsiString;
    8//p_iTSCol: Integer
  );
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.saHTMLTable(
  
  p_saTableTagInsert: AnsiString;

  p_bTableCaption: Boolean;
  p_saTableCaption: AnsiString;
  p_bTableCaptionShowRowCount: Boolean;
  
  p_bTableHEAD: Boolean;
  
  p_saNHEADText: AnsiString;
  p_iNCol: Integer;

  p_salpPTRHEADText: AnsiString;
  p_ilpPtrCol: Integer;// zero = Don't Display

  p_saUIDHEADText: AnsiString;
  p_iUIDCol: Integer;

  p_sasaNameHEADText: AnsiString;
  p_isaNameCol: Integer;

  p_sasaValueHEADText: AnsiString;
  p_isaValueCol: Integer;

  p_sasaDescHEADText: AnsiString;
  p_isaDescCol: Integer;

  p_sai8UserHEADText: AnsiString;
  p_ii8UserCol: Integer;
  
  p_saTSHEADText: AnsiString;
  p_iTSCol: Integer
  
):AnsiString;
//=============================================================================
Var i: Integer;
    iColSpan: Integer;
    iBookMarkNth: longint;
Begin
  iBookMarkNth:=N;
  Result:='<table class="gridresults" '+p_saTableTagInsert+'>';
  If p_bTableCaption Then
  Begin
    //Result+='<caption>' + saEncodeURI(p_saTableCaption);
    Result+='<caption>' + p_saTableCaption;
    If p_bTableCaptionShowRowCount Then Result+=' '+ inttostr(ListCount);
    Result+='</caption>';
  End;
  
  // This is based on the fact that there should always be one column minumum
  // and that the max is SIX (6) columns, and the Caller is smart enough
  // to have their passed indexes correct, no duplicates, and zero
  // indicates DO NOT show column.. but they will always have at least
  // ONE column configured.
  If p_bTableHEAD Then
  Begin
    Result+='<thead><tr>';
    For i:=1 To 8 Do
    Begin
      If p_iNCol=i Then
      Begin
        Result+='<td align="right">';
        If length(p_saNHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_saNHEADText);
          Result+=p_saNHEADText;
        End
        Else
        Begin
          Result+='Nth';
        End;
        Result+='</td>'
      End;

      If p_ilpPtrCol=i Then
      Begin
        Result+='<td align="right">';
        If length(p_salpPTRHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_salpPTRHEADText);
          Result+=p_salpPTRHEADText;
        End
        Else
        Begin
          Result+='lpPTR';
        End;
        Result+='</td>'
      End;
      
      If p_iUIDCol=i Then
      Begin
        Result+='<td align="left">';
        If length(p_saUIDHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_saUIDHEADText);
          Result+=p_saUIDHEADText;
        End
        Else
        Begin
          Result+='UID';
        End;
        Result+='</td>'
      End;
    
      If p_isaNameCol=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sasaNameHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_sasaNameHEADText);
          Result+=p_sasaNameHEADText;
        End
        Else
        Begin
          Result+='saName';
        End;
        Result+='</td>'
      End;
      
      If p_isaValueCol=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sasaValueHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_sasaValueHEADText);
          Result+=p_sasaValueHEADText;
        End
        Else
        Begin
          Result+='saValue';
        End;
        Result+='</td>'
      End;
      
      If p_isaDescCol=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sasaDescHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_sasaDescHEADText);
          Result+=p_sasaDescHEADText;
        End
        Else
        Begin
          Result+='saDesc';
        End;
        Result+='</td>'
      End;
      
      If p_ii8UserCol=i Then
      Begin
        Result+='<td align="right">';
        If length(p_sai8UserHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_sai8UserHEADText);
          Result+=p_sai8UserHEADText;
        End
        Else
        Begin
          Result+='i8User';
        End;
        Result+='</td>'
      End;

      If p_iTSCol=i Then
      Begin
        Result+='<td align="right">';
        If length(p_saTSHEADText)>0 Then 
        Begin
          //Result+=saEncodeURI(p_saTSHEADText);
          Result+=p_saTSHEADText;
        End
        Else
        Begin
          Result+='TS';
        End;
        Result+='</td>'
      End;
    End;
    Result+='</thead>';
  End;// TABLE HEAD
  Result+='<tbody>';    
      

  If MoveFirst Then
  Begin
    repeat
      If (N Mod 2)=0 Then 
        Result+='<tr class="r2">' 
      Else 
        Result+='<tr class="r1">';
      
      For i:=1 To 8 Do
      Begin
        If p_iNCol    =i Then
        Begin
          Result+='<td align="right">'+inttostr(N)+'</td>';
        End;        

        If p_ilpPtrCol  =i Then
        Begin
          Result+='<td align="right">'+inttostr(UINT(JFC_XDLITEM(lpItem).lpPtr));
          //if ( bShowNestedLists ) and (Item_lpPtr<>NIL) then
          //begin
          //  Result+='<br />'+JFC_XDL(JFC_XDLITEM(lpItem).lpPtr).saHTMLTable;
          //end;
          Result+='</td>';
        End;        

        If p_iUIDCol    =i Then
        Begin
          Result+='<td align="right">'+inttostr(Item_UID)+'</td>';
        End;        

        If p_isaNameCol =i Then
        Begin
          //Result+='<td align="left">'+saEncodeURI(Item_saName)+'</td>';
          Result+='<td align="left">'+Item_saName+'</td>';
        End;        

        If p_isaValueCol=i Then
        Begin
          //Result+='<td align="left">'+saEncodeURI(Item_saValue)+'</td>';
          Result+='<td align="left">'+Item_saValue+'</td>';
        End;        

        If p_isaDescCol =i Then
        Begin
          //Result+='<td align="left">'+saEncodeURI(Item_saDesc);
          Result+='<td align="left">'+Item_saDesc;
          if ( bShowNestedLists ) and (Item_lpPtr<>NIL) then
          begin
            Result+='<br />'+JFC_XDL(JFC_XDLITEM(lpItem).lpPtr).saHTMLTable(
              p_saTableTagInsert,
              p_bTableCaption,
              p_saTableCaption,
              p_bTableCaptionShowRowCount,
              p_bTableHEAD,
              p_saNHEADText,
              p_iNCol,
              p_salpPTRHEADText,
              p_ilpPtrCol,
              p_saUIDHEADText,
              p_iUIDCol,
              p_sasaNameHEADText,
              p_isaNameCol,
              p_sasaValueHEADText,
              p_isaValueCol,
              p_sasaDescHEADText,
              p_isaDescCol,
              p_sai8UserHEADText,
              p_ii8UserCol,
              p_saTSHEADText,
              p_iTSCol
            );
          end;
          Result+='</td>';
        End;        

        If p_ii8UserCol  =i Then
        Begin
          Result+='<td align="right">'+inttostr(Item_i8User)+'</td>';
        End;        

        If p_iTSCol=i Then
        Begin
          //Result+='<td align="left">'+saEncodeURI(FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(JFC_XDLITEM(lpItem).TS)))+'</td>';
          Result+='<td align="left">'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(JFC_XDLITEM(lpItem).TS))+'</td>';
        End;        


      End;    
      Result+='</tr>';
    Until not MoveNext;    
  End
  Else
  Begin
    iColSpan:=0;
    If p_iNCol>0 Then iColSpan+=1;
    If p_ilpPtrCol>0 Then iColSpan+=1;
    If p_iUIDCol>0 Then iColSpan+=1;
    If p_isaNameCol>0 Then iColSpan+=1;
    If p_isaValueCol>0 Then iColSpan+=1;
    If p_isaDescCol>0 Then iColSpan+=1;
    If p_ii8UserCol>0 Then iColSpan+=1;
    If p_iTSCol>0 Then iColSpan+=1;
    iColSpan+=1;// for empty column
    Result+='<tr class="r1"><td colspan="'+inttostr(iColSpan)+'" align="center">No Data</td></tr>';
  End;
  Result+='</tbody></table>';
  FoundNth(iBookMarkNth);
End;
//=============================================================================








//=============================================================================
Function JFC_XDL.saXML: AnsiString;
//=============================================================================
var 
  BookMarkN: longint;
begin
  BookMarkN:=N;
  if MoveFirst then
  begin
    result:='<'+saClassName+'>';
    repeat
      result+='<row rowno="'+inttostr(N)+'" >';
      result+='<lpPtr>'+inttostR(UINT(Item_lpPtr))+'</lpPtr>';
      if bShowNestedLists then
      begin
        if Item_lpPtr<>nil then
        begin
          if JFC_XDL(Item_lpPtr).ListCount>0 then
          begin
            result+='<children>'+JFC_XDL(Item_lpPtr).saXML+'</children>';
          end
          else
          begin
            result+='<children />';
          end;
        end;
      end;
      result+='<UID>'+inttostr(Item_UID)+'</UID>';
      result+='<saName><![CDATA['+Item_saName+']]></saName>';
      result+='<saValue><![CDATA['+Item_saValue+']]></saValue>';
      result+='<saDesc><![CDATA['+Item_saDesc+']]></saDesc>';
      result+='<i8User>'+inttostr(Item_i8User)+'</i8User>';
      result+='<TS>'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(JFC_XDLITEM(lpItem).TS))+'</TS>';
      result+='</row>';
    until not MoveNext;
    result+='</'+saClassName+'>';
  end
  else
  begin
    result:='<'+saClassName+' />';
  end;
  FoundNth(BookMarkN);
end;
//=============================================================================




















{
//=============================================================================
Function JFC_XDL.read_item_ts: TTIMESTAMP;
//=============================================================================
Begin
  Result:=jfc_XDLITEM(lpITem).TS;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XDL.write_item_ts(p_ts: TTIMESTAMP);
//=============================================================================
Begin
  jfc_XDLITEM(lpITem).TS:=p_ts;
End;
//=============================================================================
}

//=============================================================================
function JFC_XDL.Get_Item(p_saName: ansistring): pointer;
//=============================================================================
begin
  Result:=nil;
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,false) Then
    Begin
      Result:=lpItem;
    End;
  End;
end;
//=============================================================================

//=============================================================================
function JFC_XDL.Get_ItemCS(p_saName: ansistring): pointer;
//=============================================================================
begin
  Result:=nil;
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,True) Then
    Begin
      Result:=lpItem;
    End;
  End;
end;
//=============================================================================


//=============================================================================
Function JFC_XDL.Get_saValueCS(p_saName: AnsiString):AnsiString;
//=============================================================================
Begin
  Result:='';
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,True) Then
    Begin
      Result:=Item_saValue;
    End;
  End;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.Get_saValue(p_saName: AnsiString):AnsiString;
//=============================================================================
Begin
  Result:='';
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,False) Then
    Begin
      Result:=Item_saValue;
    End;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_XDL.Get_saDescCS(p_saName: AnsiString):AnsiString;
//=============================================================================
Begin
  Result:='';
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,True) Then
    Begin
      Result:=Item_saDesc;
    End;
  End;
End;
//=============================================================================



//=============================================================================
Function JFC_XDL.Get_saDesc(p_saName: AnsiString):AnsiString;
//=============================================================================
Begin
  Result:='';
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,False) Then
    Begin
      Result:=Item_saDesc;
    End;
  End;
End;
//=============================================================================



//=============================================================================
procedure JFC_XDL.Set_saValueCS(p_saName: AnsiString; p_saValue: ansistring);
//=============================================================================
Begin
  If FoundItem_saName(p_saName,True) Then
  begin
    Item_saValue:=p_saValue;
  End
  else
  begin
    AppendItem_saName_N_saValue(p_saName, p_saValue);
  end;
End;
//=============================================================================



//=============================================================================
procedure JFC_XDL.Set_saValue(p_saName: AnsiString; p_saValue: ansistring);
//=============================================================================
Begin
  If FoundItem_saName(p_saName,false) Then
  begin
    Item_saValue:=p_saValue;
  End
  else
  begin
    AppendItem_saName_N_saValue(p_saName, p_saValue);
  end;
End;
//=============================================================================


//=============================================================================
procedure JFC_XDL.Set_saDescCS(p_saName: AnsiString; p_saDesc: ansistring);
//=============================================================================
Begin
  If FoundItem_saName(p_saName,True) Then
  begin
    Item_saDesc:=p_saDesc;
  End
  else
  begin
    AppendItem_saName_N_saDesc(p_saName, p_saDesc);
  end;
End;
//=============================================================================


//=============================================================================
procedure JFC_XDL.Set_saDesc(p_saName: AnsiString; p_saDesc: ansistring);
//=============================================================================
Begin
  If FoundItem_saName(p_saName,false) Then
  begin
    Item_saDesc:=p_saDesc;
  End
  else
  begin
    AppendItem_saName_N_saDesc(p_saName, p_saDesc);
  end;
End;
//=============================================================================








//=============================================================================
Function JFC_XDL.FoundItem_TS(p_tsFrom, p_tsTo: TTIMESTAMP):Boolean;
//=============================================================================
Begin
 Result:=FoundTimeStamp(p_tsFrom, p_tsTo, 
                             @JFC_XDLITEM(nil).TS,
                             True,False); //(means use DLITEM.lpPTR)
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.FoundNext_TS(p_tsTo:TTIMESTAMP):Boolean;
//=============================================================================
Begin
 If ListCount>0 Then
 Begin
   Result:=FoundTimeStamp(JFC_XDLITEM(lpItem).TS, p_tsTo, 
                             @JFC_XDLITEM(nil).TS,
                             True,False);// (means use DLITEM.lpPTR)
 End
 Else
 Begin
   Result:=False;
 End;
End;
//=============================================================================


//=============================================================================
// This procedure empties XDL, and loads it with the current
// ENV Variables.
Procedure JFC_XDL.LoadXDLWithEnvVar;
//=============================================================================
Var
  sa: AnsiString;
  eq: Integer;
Begin
  // envstr is zero based array
  DeleteAll;
  If envcount>0 Then
  Begin
    repeat
      sa:=envstr(N);
      eq:=pos('=',sa);
      AppendItem_saName_N_saValue(copy(sa,1,eq-1), copy(sa,eq+1,length(sa)-eq));
    Until N=envcount+1;
  End;
End;
//=============================================================================


//=============================================================================
// This procedure empties XDL, and loads it with parameters
// passed to the program from the command line.
Procedure JFC_XDL.LoadXDLWithParams;
//=============================================================================
//var
Begin
  // envstr is zero based array
  DeleteAll;
  repeat
    AppendItem_saValue(ParamStr(N));
  Until (N=paramcount+1);
End;
//=============================================================================


//=============================================================================
Function JFC_XDL.FoundItem_saName(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FoundItem_saName(p_sa,false);
end;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saName(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FNextItem_saName(p_sa,false);
end;
//=============================================================================

//=============================================================================
Function JFC_XDL.FoundItem_saValue(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FoundItem_saValue(p_sa,falsE);
end;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saValue(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FNextItem_saValue(p_sa,false);
end;
//=============================================================================

//=============================================================================
Function JFC_XDL.FoundItem_saDesc(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FoundItem_saDesc(p_sa,false);
end;
//=============================================================================

//=============================================================================
Function JFC_XDL.FNextItem_saDesc(p_sa:AnsiString):Boolean;//< Find first matching item. NOT CASE Sensistive
//=============================================================================
begin
  result:=FNextItem_saDesc(p_sa,false);
end;
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
