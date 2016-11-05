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
// XXDL Jegas Foundation Class - Double Linked List Class - descendant of
// JFC_XDL
Unit ug_jfc_xxdl;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_xxdl.pp'}
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
  ug_jfc_xdl;
//=============================================================================



//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_XXDLITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//TODO: Document Override Comments - "inherit" or Not to Inherit that is the
//      question! :)
//=============================================================================
{}
// jfc_XXDLITEM BASE jfc_XDL Linked List Item
Type jfc_XXDLITEM = Class(jfc_XDLITEM)
//=============================================================================
  Public
  ID: array[1..4] Of UInt64; //< Array of Int64 for user use. Numeric General Datapoints.

  
  DT: TDATETIME; {< NOTE This new Element, by default, is loaded with the NOW
                  sysutils unit function but is a user field in every other 
                  respect.}
  Constructor create; 
  Destructor Destroy; override;
End;
//=============================================================================

//=============================================================================
{}
// Main JFC_XXDL class.
Type jfc_XXDL = Class(jfc_XDL)
//=============================================================================
  public
  Function pvt_CreateItem: jfc_XXDLITEM; override; 
  Procedure pvt_DestroyItem(p_lp:pointer);  override;
  
  Function read_item_id1: UInt64;
  Procedure write_item_id1(p_u8: UInt64);
  Function read_item_id2: UInt64;
  Procedure write_item_id2(p_u8: UInt64);
  Function read_item_id3: UInt64;
  Procedure write_item_id3(p_u8: UInt64);
  Function read_item_id4: UInt64;
  Procedure write_item_id4(p_u8: UInt64);
  Function read_item_dt: TDateTime;
  Procedure write_item_dt(p_dt: TDateTime);
  
  Public
  Constructor create;
  Destructor destroy; override;

  Property Item_ID1: UInt64 read read_item_id1 Write write_item_id1;
  Property Item_ID2: UInt64 read read_item_id2 Write write_item_id2;
  Property Item_ID3: UInt64 read read_item_id3 Write write_item_id3;
  Property Item_ID4: UInt64 read read_item_id4 Write write_item_id4;
  Property Item_DT: TDateTime read read_item_dt Write write_item_dt;

  
  Function FoundItem_ID(p_u8, p_Index: UInt64):Boolean;
  Function FNextItem_ID(p_u8, p_Index: UInt64):Boolean;
  
  Function AppendItem_XXDL(
    p_lpPtr: pointer;
    p_saName, p_saDesc: AnsiString;
    p_i8User: Int64;
    p_ID1, p_ID2, p_ID3, p_ID4: UInt64
  ): Boolean;

  Function AppendItem_XXDL(
    p_lpPtr: pointer;
    p_saName, p_saDesc, p_saValue: AnsiString;
    p_i8User: Int64;
    p_ID1, p_ID2, p_ID3, p_ID4: UInt64
  ): Boolean;


  // Render this class' cojntents as XML
  function saXML: ansistring;
  
  // Create HTML to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones implementation.
  Function saHTMLTable: AnsiString;
  // Create HTML to make a Diagnostic or whatever table of the XDL
  // Contents. This is a barebones implementation - however you have quite a bit of output control with this version of the function.
  Function saHTMLTable(
    p_saTableTagInsert: AnsiString;
  
    p_bTableCaption: Boolean;
    p_saTableCaption: AnsiString;
    p_bTableCaptionShowRowCount: Boolean;
    
    p_bTableHEAD: Boolean;
    
    p_saNHEADText: AnsiString;
    p_u1NCol: byte;
  
    p_salpPTRHEADText: AnsiString;
    p_u1lpPtrCol: byte;//< zero = Don't Display
  
    p_saUIDHEADText: AnsiString;
    p_u1UIDCol: byte;
  
    p_sasaNameHEADText: AnsiString;
    p_u1saNameCol: byte;
  
    p_sasaValueHEADText: AnsiString;
    p_u1saValueCol: byte;
  
    p_sasaDescHEADText: AnsiString;
    p_u1saDescCol: byte;
  
    p_sai8UserHEADText: AnsiString;
    p_u1i8UserCol: byte;
    
    p_saTSHeadText: ANSISTRING;
    p_u1TSCol: byte;

    p_saID1HeadText: AnsiString;
    p_u1ID1Col: byte;

    p_saID2HeadText: AnsiString;
    p_u1ID2Col: byte;

    p_saID3HeadText: AnsiString;
    p_u1ID3Col: byte;

    p_saID4HeadText: AnsiString;
    p_u1ID4Col: byte;

    p_saDTHeadText: AnsiString;
    p_u1DTCol: byte
  ):AnsiString;

  procedure AppendItem_Message(
    p_i8Msg: Int64; 
    p_saMsg: AnsiString; 
    p_saMoreInfo: ansistring;
    p_i8Catagory: Int64;{< similiar to jlog severity values but user can do 
                         what they want for their own purposes.}
    p_saValue: ansistring{< store in JFC_XXDL.saValue field - often used to
                           hold SourceFile name in jegas apps}
  );


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
// !#!JFC_XXDLITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//
// JFC_XDLITEM Routines          BASE jfc_XDLITEM "itemclass"
//             
//*****************************************************************************

//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor jfc_XXDLITEM.create;
//=============================================================================
Begin
  Inherited;
  sClassName:='JFC_XXDLITEM';
  id[1]:=0;
  id[2]:=0;
  id[3]:=0;
  id[4]:=0;
  DT:=now;
End;
//=============================================================================

//=============================================================================
Destructor JFC_XXDLITEM.Destroy;
//=============================================================================
Begin
  sClassName:='';
  Inherited;
End;
//=============================================================================


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_XXDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_XXDL Routines          BASE jfc_XDL Dynamic Double Linked List
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor jfc_XXDL.Create;
//=============================================================================
Begin
  Inherited;
  sClassName:='JFC_XXDL';
End;
//=============================================================================

//=============================================================================
Destructor JFC_XXDL.Destroy;
//=============================================================================
Begin
  sClassName:='';
  Inherited;
End;
//=============================================================================


//=============================================================================
Function jfc_XXDL.pvt_CreateItem: jfc_XXDLITEM;  
//=============================================================================
Begin
  Result:=jfc_XXDLITEM.create;
  //jfc_XXDLITEM(Result).UID:=AutoNumber;
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.pvt_DestroyItem(p_lp:pointer); 
//=============================================================================
Begin
  // This code is for NESTED JFC_XXDL ONLY!!! Do NOT Inherit this procedure!!!!!
  // MAKE YOUR OWN!
  if bDestroyNestedLists then 
  begin
    if(JFC_XXDLITEM(p_lp).lpPtr <> nil)then
    begin
      JFC_XXDL(JFC_XXDLITEM(p_lp).lpPtr).DeleteAll;
      JFC_XXDL(JFC_XXDLITEM(p_lp).lpPtr).Destroy;
      JFC_XXDLITEM(p_lp).lpPtr:=nil;
    end;
  end;
  
  jfc_XXDLITEM(p_lp).Destroy;
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.FoundItem_ID(p_u8, p_Index: UInt64):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_u8, SizeOf(Uint64), @jfc_XXDLITEM(nil).ID[p_Index],
                      True, False);
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.FNextItem_ID(p_u8, p_Index: UInt64):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_u8, SizeOf(Uint64), @jfc_XXDLITEM(nil).ID[p_Index],
                      False, False);
End;
//=============================================================================


//=============================================================================
Function jfc_XXDL.read_item_id1: UInt64;
//=============================================================================
Begin
  Result:=jfc_XXDLITEM(lpITem).ID[1];
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.write_item_id1(p_u8: UInt64);
//=============================================================================
Begin
  jfc_XXDLITEM(lpITem).ID[1]:=p_u8;
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.read_item_id2: UInt64;
//=============================================================================
Begin
  Result:=jfc_XXDLITEM(lpITem).ID[2];
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.write_item_id2(p_u8: UInt64);
//=============================================================================
Begin
  jfc_XXDLITEM(lpITem).ID[2]:=p_u8;
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.read_item_id3: UInt64;
//=============================================================================
Begin
  Result:=jfc_XXDLITEM(lpITem).ID[3];
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.write_item_id3(p_u8: UInt64);
//=============================================================================
Begin
  jfc_XXDLITEM(lpITem).ID[3]:=p_u8;
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.read_item_id4: UInt64;
//=============================================================================
Begin
  Result:=jfc_XXDLITEM(lpITem).ID[4];
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.write_item_id4(p_u8: UInt64);
//=============================================================================
Begin
  jfc_XXDLITEM(lpITem).ID[4]:=p_u8;
End;
//=============================================================================

//=============================================================================
Function jfc_XXDL.read_item_dt: TDateTime;
//=============================================================================
Begin
  Result:=jfc_XXDLITEM(lpITem).DT;
End;
//=============================================================================

//=============================================================================
Procedure jfc_XXDL.write_item_DT(p_dt: TDateTime);
//=============================================================================
Begin
  jfc_XXDLITEM(lpITem).DT:=p_dt;
End;
//=============================================================================




//=============================================================================
Function jfc_XXDL.AppendItem_XXDL(
p_lpPtr: pointer;
p_saName, p_saDesc: AnsiString;
p_i8User: Int64;
p_ID1, p_ID2, p_ID3, p_ID4: UInt64
): Boolean;
//=============================================================================
Begin
  Result:=AppendItem;
  If Result Then Begin
    JFC_XXDLITEM(lpItem).lpPtr:=p_lpPtr;
    JFC_XXDLITEM(lpItem).saName:=p_saNAme;
    JFC_XXDLITEM(lpItem).saDesc:=p_saDesc;
    JFC_XXDLITEM(lpItem).i8User:=p_i8User;
    JFC_XXDLITEM(lpItem).ID[1]:=p_ID1;
    JFC_XXDLITEM(lpItem).ID[2]:=p_ID2;
    JFC_XXDLITEM(lpItem).ID[3]:=p_ID3;
    JFC_XXDLITEM(lpItem).ID[4]:=p_ID4;
  End;
End;
//=============================================================================

//=============================================================================
// New Version has saVALUE Property in it
Function jfc_XXDL.AppendItem_XXDL(
p_lpPtr: pointer;
p_saName, p_saDesc, p_saValue: AnsiString;
p_i8User: Int64;
p_ID1, p_ID2, p_ID3, p_ID4: Uint64
): Boolean;
//=============================================================================
Begin
  Result:=AppendItem;
  If Result Then Begin
    JFC_XXDLITEM(lpItem).lpPtr:=p_lpPtr;
    JFC_XXDLITEM(lpItem).saName:=p_saNAme;
    JFC_XXDLITEM(lpItem).saDesc:=p_saDesc;
    JFC_XXDLITEM(lpItem).saValue:=p_saValue;
    JFC_XXDLITEM(lpItem).i8User:=p_i8User;
    JFC_XXDLITEM(lpItem).ID[1]:=p_ID1;
    JFC_XXDLITEM(lpItem).ID[2]:=p_ID2;
    JFC_XXDLITEM(lpItem).ID[3]:=p_ID3;
    JFC_XXDLITEM(lpItem).ID[4]:=p_ID4;
  End;
End;
//=============================================================================














//=============================================================================
Function JFC_XXDL.saHTMLTable: AnsiString;
//=============================================================================
Begin
  Result:=self.saHTMLTable(
    '',//p_saTableTagInsert: AnsiString;

    True, //p_bTableCaption: boolean;
    'ClassName: ' +sClassName+' - Rows',//p_saTableCaption: AnsiString;
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
  
    '',//p_sai8UserHEADText: AnsiString;
    7,//p_ii8UserCol: integer;
    
    '',//p_saTSHeadText: ANSISTRING;
    8, //p_iTSCol: integer;

    '',//p_saID1HeadText: AnsiString;
    9,//p_iID1Col: Integer;

    '',//p_saID2HeadText: AnsiString;
    10,//p_iID2Col: Integer;

    '',//p_saID3HeadText: AnsiString;
    11,//p_iID3Col: Integer;

    '',//p_saID4HeadText: AnsiString;
    12,//p_iID4Col: Integer;

    '',//p_saDTHeadText: AnsiString;
    13//p_iDTCol: Integer
    
  );
End;
//=============================================================================

//=============================================================================
Function JFC_XXDL.saHTMLTable(
  p_saTableTagInsert: AnsiString;

  p_bTableCaption: Boolean;
  p_saTableCaption: AnsiString;
  p_bTableCaptionShowRowCount: Boolean;
  
  p_bTableHEAD: Boolean;
  
  p_saNHEADText: AnsiString;
  p_u1NCol: byte;

  p_salpPTRHEADText: AnsiString;
  p_u1lpPtrCol: byte;// zero = Don't Display

  p_saUIDHEADText: AnsiString;
  p_u1UIDCol: byte;

  p_sasaNameHEADText: AnsiString;
  p_u1saNameCol: byte;

  p_sasaValueHEADText: AnsiString;
  p_u1saValueCol: byte;

  p_sasaDescHEADText: AnsiString;
  p_u1saDescCol: byte;

  p_sai8UserHEADText: AnsiString;
  p_u1i8UserCol: byte;

  p_saTSHEADText: AnsiString;
  p_u1TSCol: byte;

  p_saID1HeadText: AnsiString;
  p_u1ID1Col: byte;

  p_saID2HeadText: AnsiString;
  p_u1ID2Col: byte;

  p_saID3HeadText: AnsiString;
  p_u1ID3Col: byte;

  p_saID4HeadText: AnsiString;
  p_u1ID4Col: byte;

  p_saDTHeadText: AnsiString;
  p_u1DTCol: byte

):AnsiString;
//=============================================================================
Var u1: UInt;
    u1ColSpan: byte;
    uBookmarkNth: uint;
Begin
  uBookmarknth:=N;
  Result:='<table class="gridresults" '+p_saTableTagInsert+'>';
  If p_bTableCaption Then
  Begin
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
    For u1:=1 To 12 Do
    Begin

      If p_u1NCol=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saNHEADText)>0 Then 
        Begin
          Result+=p_saNHEADText;
        End
        Else
        Begin
          Result+='Nth';
        End;
        Result+='</th>'
      End;

      If p_u1lpPtrCol=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_salpPTRHEADText)>0 Then 
        Begin
          Result+=p_salpPTRHEADText;
        End
        Else
        Begin
          Result+='lpPTR';
        End;
        Result+='</th>'
      End;
      
      If p_u1UIDCol=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saUIDHEADText)>0 Then 
        Begin
          Result+=p_saUIDHEADText;
        End
        Else
        Begin
          Result+='UID';
        End;
        Result+='</th>'
      End;
    
      If p_u1saNameCol=u1 Then
      Begin
        Result+='<th align="left">';
        If length(p_sasaNameHEADText)>0 Then 
        Begin
          Result+=p_sasaNameHEADText;
        End
        Else
        Begin
          Result+='saName';
        End;
        Result+='</th>'
      End;
      
      If p_u1saValueCol=u1 Then
      Begin
        Result+='<th align="left">';
        If length(p_sasaValueHEADText)>0 Then 
        Begin
          Result+=p_sasaValueHEADText;
        End
        Else
        Begin
          Result+='saValue';
        End;
        Result+='</th>'
      End;
      
      If p_u1saDescCol=u1 Then
      Begin
        Result+='<th align="left">';
        If length(p_sasaDescHEADText)>0 Then 
        Begin
          Result+=p_sasaDescHEADText;
        End
        Else
        Begin
          Result+='saDesc';
        End;
        Result+='</th>'
      End;
      
      If p_u1i8UserCol=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_sai8UserHEADText)>0 Then 
        Begin
          Result+=p_sai8UserHEADText;
        End
        Else
        Begin
          Result+='i8User';
        End;
        Result+='</th>'
      End;

      If p_u1TSCol=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saTSHEADText)>0 Then 
        Begin
          Result+=p_saTSHEADText;
        End
        Else
        Begin
          Result+='TS';
        End;
        Result+='</th>'
      End;


      If p_u1ID1Col=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saID1HEADText)>0 Then 
        Begin
          Result+=p_saID1HEADText;
        End
        Else
        Begin
          Result+='ID[1]';
        End;
        Result+='</th>'
      End;

      If p_u1ID2Col=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saID2HEADText)>0 Then 
        Begin
          Result+=p_saID2HEADText;
        End
        Else
        Begin
          Result+='ID[2]';
        End;
        Result+='</th>'
      End;
      If p_u1ID3Col=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saID3HEADText)>0 Then 
        Begin
          Result+=p_saID3HEADText;
        End
        Else
        Begin
          Result+='ID[3]';
        End;
        Result+='</th>'
      End;
      If p_u1ID4Col=u1 Then
      Begin
        Result+='<th align="right">';
        If length(p_saID4HEADText)>0 Then
        Begin
          Result+=p_saID4HEADText;
        End
        Else
        Begin
          Result+='ID[4]';
        End;
        Result+='</th>'
      End;

      If p_u1DTCol=u1 Then
      Begin
        Result+='<th align="center">';
        If length(p_saDTHEADText)>0 Then 
        Begin
          Result+=p_saDTHEADText;
        End
        Else
        Begin
          Result+='Date';
        End;
        Result+='</th>'
      End;
    End;
    Result+='</thead>';
  End;// TABLE HEAD
  Result+='<tbody>';    
      

  If MoveFirst Then
  Begin
    repeat
      if (N mod 2)=0 then 
        Result+='<tr class="r2">' 
      else 
        Result+='<tr class="r1">';
      For u1:=1 To 12 Do
      Begin
        If p_u1NCol    =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(N)+'</td>';
        End;        

        If p_u1lpPtrCol  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(UINT(JFC_XXDLITEM(lpItem).lpPtr));
          if ( bShowNestedLists ) and (Item_lpPtr<>NIL) then
          begin
            Result+='<br />'+JFC_XXDL(JFC_XXDLITEM(lpItem).lpPtr).saHTMLTable;
          end;
          Result+='</td>';
          
        End;        

        If p_u1UIDCol    =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(Item_UID)+'</td>';
        End;        

        If p_u1saNameCol =u1 Then
        Begin
          Result+='<td align="left">'+Item_saName+'</td>';
        End;        

        If p_u1saValueCol=u1 Then
        Begin
          Result+='<td align="left">'+Item_saValue+'</td>';
        End;        

        If p_u1saDescCol =u1 Then
        Begin
          Result+='<td align="left">'+Item_saDesc+'</td>';
        End;        

        If p_u1i8UserCol  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(Item_i8User)+'</td>';
        End;        

        If p_u1TSCol=u1 Then
        Begin
          Result+='<td align="left">'+FormatDateTime(csDATETIMEFORMAT,TimeStampToDateTime(JFC_XXDLITEM(lpItem).TS))+'</td>';
        End;        

        If p_u1ID1Col  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(JFC_XXDLITEM(lpItem).ID[1])+'</td>';
        End;        

        If p_u1ID2Col  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(JFC_XXDLITEM(lpItem).ID[2])+'</td>';
        End;        

        If p_u1ID3Col  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(JFC_XXDLITEM(lpItem).ID[3])+'</td>';
        End;        

        If p_u1ID4Col  =u1 Then
        Begin
          Result+='<td align="right">'+inttostr(JFC_XXDLITEM(lpItem).ID[4])+'</td>';
        End;        

        If p_u1DTCol  =u1 Then
        Begin
          Result+='<td align="center">'+DateTimeToSTR(JFC_XXDLITEM(lpItem).DT)+'</td>';
        End;        

      End;    
      Result+='</tr>';
    Until not MoveNext;    
  End
  Else
  Begin
    u1ColSpan:=0;
    If p_u1NCol>0 Then u1ColSpan+=1;
    If p_u1lpPtrCol>0 Then u1ColSpan+=1;
    If p_u1UIDCol>0 Then u1ColSpan+=1;
    If p_u1saNameCol>0 Then u1ColSpan+=1;
    If p_u1saValueCol>0 Then u1ColSpan+=1;
    If p_u1saDescCol>0 Then u1ColSpan+=1;
    If p_u1i8UserCol>0 Then u1ColSpan+=1;
    If p_u1TSCol>0 Then u1ColSpan+=1;
    If p_u1ID1Col>0 Then u1ColSpan+=1;
    If p_u1ID2Col>0 Then u1ColSpan+=1;
    If p_u1ID3Col>0 Then u1ColSpan+=1;
    If p_u1ID4Col>0 Then u1ColSpan+=1;
    If p_u1DTCol>0 Then u1ColSpan+=1;

    Result+='<tr class="r1"><td colspan="'+inttostr(u1ColSpan)+'" align="center">No Data</td></tr>';
  End;
  Result+='</tbody></table>';
  foundnth(uBookmarknth);
End;
//=============================================================================


//=============================================================================
Function JFC_XXDL.saXML: AnsiString;
//=============================================================================
var 
  BookMarkN: longint;
begin
  BookMarkN:=N;
  if MoveFirst then
  begin
    result:='<'+sClassName+'>';
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
      result+='<iID1Col>'+inttostR(Item_ID1)+'</iID1Col>';
      result+='<iID2Col>'+inttostR(Item_ID1)+'</iID2Col>';
      result+='<iID3Col>'+inttostR(Item_ID1)+'</iID3Col>';
      result+='<iID4Col>'+inttostR(Item_ID1)+'</iID4Col>';
      result+='<DT>'+DateTimeToSTR(JFC_XXDLITEM(lpItem).DT)+'</DT>';
      result+='</row>';
    until not MoveNext;
    result+='</'+sClassName+'>';
  end
  else
  begin
    result:='<'+sClassName+' />';
  end;
  FoundNth(BookMarkN);
end;
//=============================================================================




//=============================================================================
// Use the XDL as a means for storing errors. There are implmentations of this 
// throughout the Jegas software as a simple means of dynamically recording
// errors in the order the occurred in memory for processing later, logging
// or whatever. This procedure appends messages to the end of the XDL 
//=============================================================================
procedure JFC_XXDL.AppendItem_Message(
  p_i8Msg: Int64; 
  p_saMsg: AnsiString; 
  p_saMoreInfo: ansistring;
  p_i8Catagory: Int64;// similiar to jlog severity values but user can do 
                       // what they want for their own purposes.
  p_saValue: ansistring// store in JFC_XXDL.saValue field - often used to
                        // hold SourceFile name in jegas apps
);
//=============================================================================
begin
  AppendItem;
  JFC_XXDLITEM(lpItem).ID[1]:=p_i8Msg;
  JFC_XXDLITEM(lpItem).ID[2]:=p_i8Catagory;
  JFC_XXDLITEM(lpItem).saName:=p_saMsg;
  JFC_XXDLITEM(lpItem).saValue:=p_saValue;
  JFC_XXDLITEM(lpItem).saDesc:=p_saMoreInfo;
end;
//=============================================================================







//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
