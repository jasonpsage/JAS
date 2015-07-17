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
// Jegas API XML Unit: This unit is for working with XML data
Unit ug_jfc_xml;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_JFC_XML.pp'}
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
  ug_misc,
  ug_common,
  ug_jegas,
  ug_jfc_xdl,
  ug_jfC_tokenizer;
//=============================================================================


//=============================================================================
{}
// JFC_XMLITEM BASE JFC_XML Linked List Item
// Note: In this descendant, this class' role is of an XML CLASS library
// the following JFC_XMLITEM fields are not used by this implementation
// specifically but are available for developers for whatever reason
// they dream up.
// (The byte count hopefully isn't enough to consume memory at an unreasonable
// pace)
// JFC_XMLITEM.UID - Still works as Unique Identifier - could be useful
// JFC_XMLITEM.i8User - still available for user use
// JFC_XMLITEM.TS (timestamp)
// JFC_XMLITEM.saDesc
Type JFC_XMLITEM = Class(jfc_XDLITEM)
//=============================================================================
  Public
  // Boolean to denote if VALUE is surrounded by CDATA tags
  bCData: boolean;
  // Used to Hold XML Attributes when this class is used as an XML class lib
  AttrXDL: JFC_XDL;
  Constructor create; 
  Destructor Destroy; override;
End;
//=============================================================================

//=============================================================================
{}
// Main JFC_XML class.
Type JFC_XML = Class(jfc_XDL)
//=============================================================================
  public
  Function pvt_CreateItem: JFC_XMLITEM; override; 
  Procedure pvt_DestroyItem(p_lp:pointer);  override;
  
  Public
  Constructor create; 
  Destructor destroy; override;

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
  
    p_sabCDataHEADText: AnsiString;
    p_ibCDataCol: Integer;
    
    p_saAttrXDLHeadText: AnsiString;
    p_iAttrXDLCol: Integer

  ):AnsiString;

  Function read_item_bCData: boolean;//< make properties work
  Procedure write_item_bCData(p_b: boolean);//< make properties work
  Property Item_bCData: boolean read read_item_bCData Write write_item_bCData; //< No Checks Are made - Using this property when the list is empty will cause a runtime error.

  
  {}
  // PASS XML and this class will parse and represent it as objects that
  // can be manipulated and/or rendered via: saXML
  function bParseXML(p_saXML: ansistring): boolean;
  {}
  // PRIVATE: This is used internally by the bParseXML function
  function bParseNode(p_TK: JFC_TOKENIZER; var p_i4Line: longint; var bOk: boolean; p_XML: JFC_XML; p_i4Nest: longint): boolean;
  {}
  // This is a simple way to show error information 
  public
  saLastError: ansistring;

  // Renders all XML from data loaded in the JFC_XML object
  function saXML(
    p_bStripComments: boolean;
    p_bStripWhiteSpace: boolean
  ): AnsiString;

  // Renders SPECIFIC (current) NODE or all data loaded in the JFC_XML object.
  // Generally you pass a ONE to the i4Nest parameter. It effects whitespace
  // indentation fo human reading of the XML. Eliminate the possibility 
  // of this function rendering whitespace, pass a negative ONE.
  function saXML(
    p_bStripComments: boolean;
    p_bStripWhiteSpace: boolean;
    p_bRenderThisNodeandChildrenOnly: boolean;
    i4Nest: longint
  ):ansistring;
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
// !#!JFC_XMLITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//
// JFC_XMLITEM Routines          BASE jfc_XDLITEM "itemclass"
//             
//*****************************************************************************

//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor JFC_XMLITEM.create;
//=============================================================================
Begin
  Inherited;
  saClassName:='JFC_XMLITEM';
  bCData:=false;
  AttrXDL:=JFC_XDL.Create;
End;
//=============================================================================

//=============================================================================
Destructor JFC_XMLITEM.Destroy;
//=============================================================================
Begin
  saClassName:='';
  AttrXDL.Destroy;
  if lpPtr<>nil then
  begin
    JFC_XML(lpPtr).Destroy;
  end;
  Inherited;
End;
//=============================================================================


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_XML
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_XML Routines          BASE jfc_XDL Dynamic Double Linked List
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
Constructor JFC_XML.Create;
//=============================================================================
Begin
  Inherited;
  saClassName:='JFC_XML';
End;
//=============================================================================

//=============================================================================
Destructor JFC_XML.Destroy;
//=============================================================================
Begin
  saClassName:='';
  Inherited;
End;
//=============================================================================


//=============================================================================
Function JFC_XML.pvt_CreateItem: JFC_XMLITEM;  
//=============================================================================
Begin
  Result:=JFC_XMLITEM.create;
  //JFC_XMLITEM(Result).UID:=AutoNumber;
End;
//=============================================================================

//=============================================================================
Procedure JFC_XML.pvt_DestroyItem(p_lp:pointer); 
//=============================================================================
Begin
  // This code is for NESTED JFC_XML ONLY!!! Do NOT Inherit this procedure!!!!!
  // MAKE YOUR OWN!
  if bDestroyNestedLists then 
  begin
    if(JFC_XMLITEM(p_lp).lpPtr <> nil)then
    begin
      JFC_XML(JFC_XMLITEM(p_lp).lpPtr).DeleteAll;
      JFC_XML(JFC_XMLITEM(p_lp).lpPtr).Destroy;
      JFC_XMLITEM(p_lp).lpPtr:=nil;
    end;
  end;
  
  JFC_XMLITEM(p_lp).Destroy;
End;
//=============================================================================














//=============================================================================
Function JFC_XML.read_item_bCData: boolean;//< make properties work
//=============================================================================
begin
  result:=JFC_XMLITEM(lpitem).bCData;
end;
//=============================================================================

//=============================================================================
Procedure JFC_XML.write_item_bCData(p_b: boolean);//< make properties work
//=============================================================================
begin
  JFC_XMLITEM(lpitem).bCData:=p_b;
end;
//=============================================================================



//=============================================================================
Function JFC_XML.saHTMLTable: AnsiString;
//=============================================================================
Begin
  Result:=self.saHTMLTable(
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

    '',//p_saAttrXDLHeadText: AnsiString;
    8//p_iAttrXDLCol: Integer;

  );
End;
//=============================================================================

//=============================================================================
Function JFC_XML.saHTMLTable(
  
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

  p_sabCDataHEADText: AnsiString;
  p_ibCDataCol: Integer;


  p_saAttrXDLHeadText: AnsiString;
  p_iAttrXDLCol: Integer

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
    Result+='<caption>' + p_saTableCaption;
    If p_bTableCaptionShowRowCount Then Result+=' '+ inttostr(ListCount);
    Result+='</caption>';
  End;
  
  // This is based on the fact that there should always be one column minimum
  // and that the max is SIX (6) columns, and the Caller is smart enough
  // to have their passed indexes correct, no duplicates, and zero
  // indicates DO NOT show column.. but they will always have at least
  // ONE column configured.
  If p_bTableHEAD Then
  Begin
    Result+='<thead><tr>';
    For i:=1 To 12 Do
    Begin

      If p_iNCol=i Then
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

      If p_ilpPtrCol=i Then
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
      
      If p_iUIDCol=i Then
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
    
      If p_isaNameCol=i Then
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
      
      If p_isaValueCol=i Then
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
      
      If p_isaDescCol=i Then
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
      
      If p_ibCDataCol=i Then
      Begin
        Result+='<th align="right">';
        If length(p_sabCDataHEADText)>0 Then 
        Begin
          Result+=p_sabCDataHEADText;
        End
        Else
        Begin
          Result+='i8User';
        End;
        Result+='</th>'
      End;

      If p_iAttrXDLCol=i Then
      Begin
        Result+='<th align="right">';
        If length(p_saAttrXDLHeadText)>0 Then 
        Begin
          Result+=p_saAttrXDLHeadText;
        End
        Else
        Begin
          Result+='ID[1]';
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
      For i:=1 To 12 Do
      Begin
        If p_iNCol    =i Then
        Begin
          Result+='<td align="right">'+inttostr(N)+'</td>';
        End;        

        If p_ilpPtrCol  =i Then
        Begin
          Result+='<td align="right">'+inttostr(UINT(JFC_XMLITEM(lpItem).lpPtr));
          if ( bShowNestedLists ) and (Item_lpPtr<>NIL) then
          begin
            Result+='<br />'+JFC_XML(JFC_XMLITEM(lpItem).lpPtr).saHTMLTable;
          end;
          Result+='</td>';
          
        End;        

        If p_iUIDCol    =i Then
        Begin
          Result+='<td align="right">'+inttostr(Item_UID)+'</td>';
        End;        

        If p_isaNameCol =i Then
        Begin
          Result+='<td align="left">'+Item_saName+'</td>';
        End;        

        If p_isaValueCol=i Then
        Begin
          Result+='<td align="left">'+Item_saValue+'</td>';
        End;        

        If p_isaDescCol =i Then
        Begin
          Result+='<td align="left">'+Item_saDesc+'</td>';
        End;        

        If p_ibCDataCol  =i Then
        Begin
          Result+='<td align="right">'+inttostr(Item_i8User)+'</td>';
        End;        

        If p_iAttrXDLCol  =i Then
        Begin
          Result+='<td align="right">'+JFC_XMLITEM(lpItem).AttrXDL.saHTMLTable+'</td>';
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
    If p_ibCDataCol>0 Then iColSpan+=1;
    Result+='<tr class="r1"><td colspan="'+inttostr(iColSpan)+'" align="center">No Data</td></tr>';
  End;
  Result+='</tbody></table>';
  FoundNth(iBookMarkNth);
End;
//=============================================================================


{
//=============================================================================
function JFC_XML.bParseNode(p_TK: JFC_TOKENIZER; var p_i4Line: longint; var bOk: boolean; p_XML: JFC_XML; p_i4Nest: longint): boolean;
//=============================================================================
var
  bDone: boolean;
  bBail: boolean;
  NTK: JFC_TOKENIZER;
  bInNode: boolean;
  saNodeWeAreIn: ansistring;
  //iBookMarkNth: longint;
begin
  //iBookMarkNth:=N;
  NTK:=JFC_TOKENIZER.Create;
  bInNode:=false;
  bBail:=false;
  repeat
    //riteln('TOP Nest:',p_i4Nest,' TK.Item_saToken:'+p_TK.Item_saToken+' Line:',p_i4Line, 'InNode:',bInNode);
    bDone:=false;
    if p_i4Line=1 then
    begin
      //riteln('LINE=1 Check');
      if (saLeftStr(p_TK.Item_saToken,1)='?') and (p_TK.Item_iQuoteID=2) then
      begin
        //riteln('  Looks like a possible encoding tag');
        if p_TK.Item_saToken<>'?xml version="1.0" encoding="UTF-8" ?' then
        begin
          //riteln('  but its not - erroring out - doesn''t match our spec');
          bOk:=false;
          saLastError:='201004191354 - Invalid XML Encoding: <'+p_TK.Item_saToken+'>';
        end
        else
        begin
          //riteln('Yup - special encoding tab');
          bDone:=true;
          //riteln('  Special Encoding Tag Handled for p_TK.Item_saToken:'+p_TK.Item_saToken);
        end;
      end;
    end;
    
    // See If a Line Feed
    if bOk and (not bDone) then
    begin
      if (p_TK.Item_saToken=csLF) and (p_TK.Item_iQuoteID=0) then 
      begin
        //riteln('LineFeed');
        p_i4Line+=1;
        bDone:=true;
      end;
    end;
    
        
    if bOk and (not bDone) then
    begin
      if (p_TK.Item_iQuoteID=3) then // probably a node
      begin
        //riteln('QUOTE2 Test: Checking Node - in a QuoteID2',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        if (bInNode=false) then
        begin
          //riteln('  IN NODE=FALSE');
          if (saLeftStr(p_TK.Item_saToken,1)='/') then 
          begin
            //riteln('    Node terminator (From previous Next Leve? Bailing!');
            p_TK.MoveNext;
            bBail:=true;
            bDone:=true;
            bInNode:=false;
          end
          else
          begin
            //riteln('  Parsing Node',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
            // Parse the node, recurse if necessary
            NTK.saSeparators:=' =';
            NTK.saWhitespace:=' ';
            NTK.saQuotes:='"';  
            NTK.Tokenize(p_TK.Item_saToken);
            NTK.bKeepDebugInfo:=false;
            //NTK.DumpToTextFile('tk_jfc_xml_node.txt');
            if NTK.MoveFirst then
            begin
              p_XML.AppendItem;
              p_XML.Item_saName:=NTK.Item_saToken;
              bInNode:=true;
              saNodeWeAreIn:=NTK.Item_saToken;
              //riteln('      Added Node NTK.Item_saToken:'+NTK.Item_saToken+' NOW WE are in a NODE!');
              if NTK.MoveNext then
              begin
                //riteln('        Gonna loop thru and handle any attributes');
                repeat
                  //riteln('L',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                  if NTK.Item_iQuoteID=0 then
                  begin
                    //riteln('m',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                    if (NTK.Item_saToken<>'/') and (NTK.Item_saToken<>'/>') then
                    begin
                      //riteln('n',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                      JFC_XMLITEM(p_XML.lpItem).AttrXDL.AppendItem;
                      JFC_XMLITEM(p_XML.lpItem).AttrXDL.Item_saName:=NTK.Item_saToken;
                      if NTK.MoveNext then
                      begin
                        //riteln('o',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                        if (NTK.Item_saToken='=') and (NTK.Item_iQuoteID=0) then
                        begin
                          //riteln('p',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                          if NTK.MoveNext then
                          begin
                            //riteln('q',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
                            JFC_XMLITEM(p_XML.lpItem).AttrXDL.Item_saValue:=saHTMLUnScrub(NTK.Item_saToken);
                          end;
                        end;
                      end;
                    end
                    else
                    begin
                      // Presume We Hit End of node
                      //riteln('        end of node during attribute parsing. NTK.N',NTK.N,' NTK.Listcount:',NTK.Listcount);
                      if NTK.N=NTK.Listcount then
                      begin
                        //riteln('          YUP - Leaving NODE MODE');
                        bInNode:=false;

                        //-----EXPERIMENTAL - BEGIN
                        p_TK.MoveNext;
                        bBail:=true;
                        //bDone:=true;  - would be redundant
                        bInNode:=false;
                        //-----EXPERIMENTAL - END


                      end;
                    end;
                  end;
                until not NTK.MoveNext;
                //riteln('Done parsing node attributes',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
              end;
            end
            else
            begin
              //riteln('qq','MTK.MoveFirst Failed TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
            end;
            bDone:=true;  
          end;
        end
        else
        begin
          //riteln('  We are in a NODE So we must check for node terminator (e.g. /tag TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
          if saLeftStr(p_TK.Item_saToken,1)='/' then
          begin
            //riteln('    Got our /tag terminator TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
            //if saRightStr(p_TK.Item_saToken,length(p_TK.Item_saToken)-1)=p_XML.Item_saName then
            //begin
              bInNode:=false;
              bDone:=false;
              bBail:=true;              
              //riteln('END OF NODE:'+p_TK.Item_saToken);
            //end
            //else
            //begin
              //bOk:=false;
              //saLastError:='201004191630 - '+inttostr(p_i4Line)+'Mismatch Node Name: Started with'+p_XML.Item_saName +' and ran into:'+p_TK.Item_saToken;
            //end;
          end;
        end;
      end;
    end;
    
    if bOk and (not bDone) then
    begin
      //riteln('u',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
      if (bInNode=true) and (p_TK.Item_iQuoteID=3) then // probably a node
      begin
        //riteln('RECURSING');
        //riteln('v',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        if p_XML.Item_lpPtr=nil then 
        begin
          //riteln('w',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
          p_XML.Item_lpPtr:=JFC_XML.Create;
        end;
        //riteln('x',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        bOk:=bParseNode(p_TK, p_i4Line, bOk, JFC_XML(p_XML.Item_lpPtr), p_i4Nest+1);
        //riteln('y',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        //riteln('  RECURSE RESULT:'+saTrueFalse(bOk));
        bDone:=true;
      end;
    end;
      
    if bOk and (not bDone) and (bInNode) then
    begin  
      //riteln('z',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
      if (p_TK.Item_iQuoteID=1) then // probably CDATA
      begin
        //riteln('PLACING CDATA VALUE On current XML ITEM:'+p_TK.Item_saToken);
        //riteln('aa',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        JFC_XMLITEM(p_XML.lpItem).bCDATA:=true;
        p_XML.Item_saValue:=p_TK.Item_saToken;
        //riteln('ab',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
        bDone:=true;
      end
      else
      begin
        //if (p_TK.Item_iQuoteID<>2) then // skip comments - put them in CDATA if you need them.
        //begin
          //riteln('PLACING VALUE On current XML ITEM:'+p_TK.Item_saToken);
          //riteln('ac',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
          p_XML.Item_saValue:=saHTMLUnScrub(p_TK.Item_saToken);
          //p_XML.Item_saValue:=p_TK.Item_saToken;
          bDone:=true;
        //end;
      end;
    end;
  until (bBail) or (bOk=false) or (not p_TK.MoveNext);
  //riteln('ad',' TK.Item_saToken:'+p_TK.Item_saToken+', Nest:',p_i4Nest,' Line:',p_i4Line, 'InNode:',bInNode);
  NTK.Destroy;
  
  if bOk then 
  begin
    bOk:=(bInNode=false);
    if not bOk then
    begin
      saLastError:='201111152303 - Unclosed Node. Line:'+inttostr(p_i4Line)+' Node we are in:' +saNodeWeAreIn+' Nest:'+inttostr(p_i4Nest);
    end;
  end;
  //FoundNth(iBookMarkNth);
  result:=bOk;
end;
//=============================================================================
}


//=============================================================================
function JFC_XML.bParseNode(p_TK: JFC_TOKENIZER; var p_i4Line: longint; var bOk: boolean; p_XML: JFC_XML; p_i4Nest: longint): boolean;
//=============================================================================
var
  bDone: Boolean;
  bInNode: boolean;
  NTK: JFC_TOKENIZER;
  sNode: string;
  bTimeToGo: boolean;
begin
  NTK:=JFC_TOKENIZER.Create;
  bInNode:=false;
  bTimeToGo:=false;
  repeat
    bDone:=false;


    if bInNode then
    begin
      if (p_TK.Item_iQuoteID=0) then
      begin
        p_XML.Item_saValue:=p_XML.Item_saValue+saHTMLUnscrub(p_TK.Item_saToken);
        p_XML.Item_saValue:=saSNRStr(p_XML.Item_saValue,#13,'');
        p_XML.Item_saValue:=saSNRStr(p_XML.Item_saValue,#10,' ');
        p_XML.Item_saValue:=trim(p_XML.Item_saValue);
        bDone:=true;
      end else

      if (p_TK.Item_iQuoteID=1) then
      begin
        p_XML.Item_saValue:=p_XML.Item_saValue+p_TK.Item_saToken;
        p_XML.Item_bCData:=true;
        bDone:=true;
      end else
    end;

    // TEST for Init Line - Add to XML (main one) if there so reproduced if rendered
    if bOk and (not bDone) then
    begin
      if (p_i4Nest=1) and (p_i4Line=1) and (p_TK.Item_saToken='?xml version="1.0" encoding="UTF-8" ?') and (p_TK.Item_iQuoteID=3) then
      begin
        bDone:=true;
        p_XML.AppendItem_saName(p_TK.Item_saToken);
      end;
    end;

    if bOk and (not bDone) then
    begin
      if p_TK.Item_iQuoteID=2 then
      begin
        bDone:=true;
        p_XML.AppendItem_saName(p_TK.Item_saToken);
        p_XML.Item_i8User:=B00;// Denote Comment
      end;
    end;


    if bOk and (not bDone) then
    begin // carriage return - move on
      if (p_TK.Item_saToken=csCR) and (p_TK.Item_iQuoteID=0) then bDone:=true;
    end;

    if bOk and (not bDone) then
    begin // Line Feed - add to line count then move on
      if (p_TK.Item_saToken=csLF) and (p_TK.Item_iQuoteID=0) then begin p_i4Line+=1; bDone:=true; end;
    end;

    if bOk and (not bDone) then
    begin // Presumably White space
      if (p_TK.Item_iQuoteID=0) then bDone:=true;
    end;

    if bOk and (not bDone) then
    begin // We have a node
      if (p_TK.Item_iQuoteID=3) then
      begin
        NTK.SetDefaults;
        NTK.saSeparators:=' =';
        NTK.saWhitespace:=' ';
        NTK.saQuotes:='"';
        NTK.bKeepDebugInfo:=false;
        NTK.Tokenize(p_TK.Item_saToken);
        //if NTK.MoveFirst then NTK.DumpToTextFile('tk_jfc_xml_node_'+NTK.Item_saToken+'.txt');
        if not NTK.MoveFirst then
        begin
          bOk:=false;
          saLastError:='201204040035 - Bad or missing node name. Line:'+inttostr(p_i4Line);
        end;

        if bOk then
        begin
          if bInNode then
          begin
            bInNode:=false;
            if saLeftStr(NTK.Item_saToken,1)='/' then
            begin
              bDone:=true;
            end
            else
            begin
              if p_XML.Item_lpPtr=nil then
              begin
                p_XML.Item_lpPtr:=JFC_XML.Create;
              end;
              bOk:=bParseNode(p_TK,p_i4Line,bOk,JFC_XML(p_XML.Item_lpPtr),p_i4Nest+1);
              bDone:=true;
            end;
          end
          else
          begin
            if saLeftStr(NTK.Item_saToken,1)='/' then
            begin
              bTimeToGo:=true;
            end
            else
            begin
              bInNode:=true;
              sNode:=NTK.Item_saToken;
              p_XML.AppendItem_saName(sNode);
              // TODO: Check Validity of characters
            end;
          end;

          if not bDone then
          begin
            if NTK.MoveNext then
            begin
              repeat
                if (NTK.Item_iQuoteID=0) then
                begin
                  if (NTK.Item_saToken='/>') or (NTK.Item_saToken='/') then
                  begin
                    bInNode:=false;
                  end else

                  // ATTRIBUTE
                  begin
                    JFC_XMLITEM(p_XML.lpItem).AttrXDL.AppendItem_saName(NTK.Item_saToken);
                    //riteln('Node: '+sNode+' Attribute: '+NTK.Item_saToken);
                    if NTK.MoveNext and (NTK.Item_iQuoteID=0) and (NTK.Item_saToken='=') and
                       NTK.MoveNext and (NTK.Item_iQuoteID=-1) then
                    begin
                      //riteln('Node: '+sNode+' Attribute Value: '+NTK.Item_saToken);
                      JFC_XMLITEM(p_XML.lpItem).AttrXDL.Item_saValue:=saHTMLUnScrub(NTK.Item_saToken);
                    end
                    else
                    begin
                      // bad attribute
                      bOk:=false;
                      saLastError:='201204041226 - Badly formed Attribute. Node: '+sNode+' Line:'+inttostr(p_i4Line);
                    end;
                  end;
                end
                else
                begin
                  // bad tag
                  bOk:=false;
                  saLastError:='201204041227 - Badly formed Tag. Node: '+sNode+' Line:'+inttostr(p_i4Line);
                end;
              until (not bOk) or (bDone) or (not NTK.MoveNext);
            end;
          end;
        end;
      end;
    end;
  until (not bOk) or (bTimeToGo) or (not p_TK.MoveNext);


  if bOk then
  begin
    bOk:=(bInNode=false);
    if not bOk then
    begin
      saLastError:='201111152303 - Unclosed Node.  Node: '+sNode+' Line:'+inttostr(p_i4Line);
    end;
  end;

  NTK.Destroy;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
function JFC_XML.bParseXML(p_saXML: ansistring): boolean;
//=============================================================================
var 
  bOk: boolean;
  TK: JFC_TOKENIZER;  
  i4Line: longint;
  iBookMarkNth: longint;
begin
  iBookMarkNth:=N;
  bOk:=true;
  i4Line:=1;
  saLastError:='';
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=csCR+csLF+#9;
  //TK.saWhitespace:=' '+#9;
  TK.QuotesXDL.AppendItem_QuotePair('<![CDATA[',']]>');
  TK.QuotesXDL.AppendItem_QuotePair('<!--','-->');
  TK.QuotesXDL.AppendItem_QuotePair('<','>');
  TK.bKeepDebugInfo:=false;
  TK.Tokenize(p_saXML);
  //TK.DumpToTextFile('tk_jfc_xml_test.txt');
  if TK.MoveFirst then
  begin
    bOk:=bParseNode(tk,i4Line, bOk, self, 1);
  end
  else
  begin
    bOk:=false;
    saLastError:='201004191552 - JFC_XML Parsing Error - Unable to tokenize:'+p_saXML;
  end;
  TK.Destroy;
  FoundNth(iBookMarkNth);
  result:=bOk;  
end;
//=============================================================================


//=============================================================================
Function JFC_XML.saXML(p_bStripComments: boolean; p_bStripWhiteSpace: boolean): AnsiString;
//=============================================================================
begin
  result:=saXML(p_bStripComments, p_bStripWhiteSpace, false,1);
end;
//=============================================================================

//=============================================================================
Function JFC_XML.saXML(
  p_bStripComments: boolean;
  p_bStripWhiteSpace: boolean;
  p_bRenderThisNodeandChildrenOnly: boolean;
  i4Nest: longint
):ansistring;
//=============================================================================
//var iBookMarkNth: longint;
var bDone: boolean;
Begin
  //iBookMarkNth:=N;
  bDone:=false;
  result:='';
  if (MoveFirst) or (p_bRenderThisNodeandChildrenOnly) then
  begin
    if (i4Nest=1) and (Item_saName='?xml version="1.0" encoding="UTF-8" ?') then
    begin
      result+='<'+Item_saName+'>';
      if not p_bStripWhiteSpace then result+=csCRLF;
      bDone:=not MoveNext;
    end;
    if not bDone then
    begin
      repeat
        if not p_bStripWhiteSpace then result+=saRepeatChar(' ',(i4Nest-1)*2);
        if Item_i8User=B00 then
        begin
          if not p_bStripComments then result+='<!--'+Item_saName+'-->';
          if not p_bStripWhiteSpace then result+=csCRLF;
        end
        else
        begin
          result+='<'+Item_saName;
          if JFC_XMLITEM(lpItem).AttrXDL.Movefirst then
          begin
            repeat
              result+=' '+JFC_XMLITEM(lpItem).AttrXDL.Item_saName+'="'+saHTMLScrub(JFC_XMLITEM(lpItem).AttrXDL.Item_saValue)+'"';
            until not JFC_XMLITEM(lpItem).AttrXDL.MoveNext;
          end;
          if length(Item_saValue)=0 then
          begin
            if Item_lpPtr=nil then
            begin
              result+=' />';
              if not p_bStripWhiteSpace then result+=csCRLF;
            end
            else
            begin
              result+='>';
              if not p_bStripWhiteSpace then result+=csCRLF;
              result+=JFC_XML(Item_lpPtr).saXML(p_bStripComments, p_bStripWhiteSpace, false, i4Nest+1);
              if not p_bStripWhiteSpace then result+=saRepeatChar(' ',(i4Nest-1)*2);
              result+='</'+Item_saName+'>';
              if not p_bStripWhiteSpace then result+=csCRLF;
            end;
          end
          else
          begin
            result+='>';
            if JFC_XMLITEM(lpItem).bCData then
            begin
              result+='<![CDATA['+Item_saValue+']]>';
            end
            else
            begin
              result+=saHTMLScrub(Item_saValue);
            end;
            if Item_lpPtr<>nil then
            begin
              result+=JFC_XML(Item_lpPtr).saXML(p_bStripComments, p_bStripWhiteSpace,false,i4Nest+1);
              if not p_bStripWhiteSpace then result+=saRepeatChar(' ',(i4Nest-1)*2);
            end;
            result+='</'+Item_saName+'>';
            if not p_bStripWhiteSpace then result+=csCRLF;
          end;
        end;
      until (p_bRenderThisNodeandChildrenOnly) or (not movenext);
    end;
  end;
  //foundNth(iBookmarknth);
End;
//=============================================================================



//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************
