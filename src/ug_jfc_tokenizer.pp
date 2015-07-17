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
// Configurable Text Tokenizer Class
Unit ug_jfc_tokenizer;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_tokenizer.pp'}
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
  ug_jfc_dl,
  ug_jfc_xdl;
//=============================================================================




//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_QUOTEXDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
Type JFC_QUOTEXDL = Class(JFC_XDL)
//=============================================================================
{}
  Function AppendItem_QuotePair(
              p_saStartQuote, 
              p_saEndQuote: AnsiString
           ): Boolean;

  Property Item_saStartQuote: AnsiString read read_item_saName
                                         Write write_item_saName;
  Property Item_saEndQuote:   AnsiString read read_item_saDesc
                                         Write write_item_saDesc;
  Constructor create;
End;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_TOKENITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
Type JFC_TOKENITEM = Class(JFC_XDLITEM)
//=============================================================================
{}
  Public
  saToken: AnsiString;

  // 0=Not a Quoted Token
  // otherwise - 
  // Positive Numbers point to Which Quote Pair in QuotesXDL
  // The Token is
  //
  // NEGATIVE Value Means In Single Quote Mode From
  // saQuotes. Value *-1 in this case tels you WHICH
  // Quote (char position in saQuotes)
  iQuoteID: Integer; 

  Constructor create; 
  Destructor destroy; override;
End;
//=============================================================================







//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_TOKENIZER
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// This version allows multi-character "quotes" and allows continuing a
// previous tokenize process if you call TokenizeMore. (For say - multi
// line file processing - very important if multi-line "quotes" allowed.
Type JFC_TOKENIZER = Class(JFC_XDL)
//=============================================================================
  {}
  saLastOne: AnsiString;

  //---------------------------------------------------------------------------
  // Routines You want to OVERRIDE if you use a child class of JFC_TOKENITEM
  //---------------------------------------------------------------------------
  {}
  Function pvt_CreateItem: JFC_TOKENITEM; override; 
  Procedure pvt_DestroyItem(p_lp:pointer); override;
  {}
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  // these make properties work
  {}
  Function read_Item_iQuoteID:Integer;
  Procedure write_Item_iQuoteID(p_i: Integer);
  Function read_item_saToken: AnsiString;
  Procedure write_item_saToken(p_sa: AnsiString);
  Function read_Item_i8Pos:Int64;
  Procedure write_Item_i8Pos(p_i8: Int64);
  {}
  //---------------------------------------------------------------------------
    
  Public
  //---------------------------------------------------------------------------
  {}
  // Some Settings To Control How Tokenizing is performed
  bCaseSensitive: Boolean; //< Default FALSE
  bKeepDebugInfo: Boolean; //< Default FALSE (But you better check!)
  {}
  //---------------------------------------------------------------------------
  {}  
  Constructor create;
  Destructor destroy; override;  
  
  Property Item_iQuoteID: Integer read read_Item_iQuoteID Write write_Item_iQuoteID;
  Property Item_saToken: AnsiString read read_Item_saToken Write write_item_saToken;
  Property Item_i8Pos: Int64 read read_Item_i8Pos Write write_Item_i8Pos;

  Property Tokens: Integer read iItems; //< same as listcount in JFC_DL for example.
  Property Token: Integer read iNN; //< same as "N" - The Sequential Position in JFC_DL for example.
  
  Function Tokenize(p_sa: AnsiString): Integer; //< Deletes Token List
  Function TokenizeMore(p_sa: AnsiString): Integer; //< Continues where it left off
  Function DumpToTextFile(p_saFileName: AnsiString): Integer;
  Function NthItem_saToken(p_i: Integer): AnsiString; //< SAFE method - Give me This
  Function FoundItem_iQuoteID(p_i: Integer):Boolean;
  Procedure SetDefaults;
  
  {}
  // Name Field Has Start Quote, Desc Field has End Quote
  // Load Up With Start and End Quotes - 
  // This is designed for Multi Character Start and END Quotes.
  // CAVEATS: (or Blessings) if There is a blank start quote - in the list 
  // Tokenizing Starts with the End Quote 
  // If there is a Blank End Quote tokenizing starts with the start quote
  // If there is quote item with both - Tokenization stops    
  public
  QuotesXDL: JFC_QUOTEXDL;

  {}
  // This is designed for SINGLE QUOTE pairs - Where Start and End Quote 
  // ARE the SAME Character. These can be Escaped by having two in a row.
  // There are checked AFTER the QuotesXDL list is checked due to its
  // "Blank" Quote paradigm. (For Ignoring Stuff) Like These Freepascal
  // Double Slashes for comments! ;)
  saQuotes: AnsiString;

  {}
  // Separators START New Tokens
  // Load Up with separators
  saSeparators: AnsiString;
  
  // White Space Characters Don't Make it into TOKENS
  // unless within quotes. Whitespace shouldn't be in 
  // quotes. Load Up With WhiteSpace Chars (Get Dropped)
  saWhiteSpace: AnsiString; 
  

  // 0 = not in quote mode, otherwise - points to 
  //     QUOTE mode last in.
  // NEGATIVE Value Means In Single Quote Mode From
  // saQuotes. Value *-1 in this case tels you WHICH
  // Quote.   
  iQuoteMode: Integer; 
                       
   Function FoundItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
   Function FNextItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
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
// !#!JFC_QUOTEXDL
//*****************************************************************************
//=============================================================================
//*****************************************************************************

Constructor JFC_QUOTEXDL.create;
Begin
  Inherited;
  saClassname:='JFC_QUOTEXDL';
End;


//=============================================================================
Function JFC_QUOTEXDL.AppendItem_QuotePair(
  p_saStartQuote, 
  p_saEndQuote: AnsiString
): Boolean;
//=============================================================================
Begin
  Result:=AppendItem;
  If Result Then Begin
    Item_saStartQuote:=p_saStartQuote;
    Item_saEndQuote:=p_saEndQuote;
  End;
End;
//=============================================================================








//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_TOKENITEM
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
Constructor JFC_TOKENITEM.create;
//=============================================================================
Begin
  Inherited;
  saClassName:='JFC_TOKENITEM';
  saToken:='';// use saName
  iQuoteID:=0;// use userid
End;
//=============================================================================

//=============================================================================
Destructor JFC_TOKENITEM.destroy;
//=============================================================================
Begin
  Inherited;
End;
//=============================================================================








//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_TOKENIZER
//*****************************************************************************
//=============================================================================
//*****************************************************************************

// NOTE: Escaped singled quotes (saQuotes)can not SPAN multiple Tokenize Mores
//=============================================================================
Constructor JFC_TOKENIZER.create;
//=============================================================================
Begin
  Inherited;
  saClassName:='JFC_TOKENIZER';
  QuotesXDL:=JFC_QUOTEXDL.Create;
  self.SetDefaults;
End;
//=============================================================================

//=============================================================================
Destructor JFC_TOKENIZER.destroy;
//=============================================================================
Begin
  Inherited;
  QuotesXDL.Destroy;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.SetDefaults;
//=============================================================================
Begin
  QUOTESXDL.DeleteAll;
  saLastOne:='';
  bCaseSensitive:=False;
  bKeepDebugInfo:=False;
  saQuotes:='';
  saWhiteSpace:='';
  saSeparators:='';
  iQuoteMode:=0;
  self.deleteall;
End;
//=============================================================================


//=============================================================================
Function JFC_TOKENIZER.pvt_CreateItem: JFC_TOKENITEM; 
//=============================================================================
Begin
  Result:=JFC_TOKENITEM.Create;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.pvt_DestroyItem(p_lp: pointer); 
//=============================================================================
Begin
  JFC_TOKENITEM(p_lp).Destroy;  
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.read_Item_iQuoteID:Integer;
//=============================================================================
Begin
  Result:=JFC_TOKENITEM(lpitem).iQuoteID;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.write_Item_iQuoteID(p_i: Integer);
//=============================================================================
Begin
  JFC_TOKENITEM(lpitem).iQuoteID:=p_i;
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.read_Item_saToken:AnsiString;
//=============================================================================
Begin
  Result:=JFC_TOKENITEM(lpitem).saToken;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.write_Item_saToken(p_sa: AnsiString);
//=============================================================================
Begin
  JFC_TOKENITEM(lpitem).saToken:=p_sa;
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.read_Item_i8Pos:Int64;
//=============================================================================
Begin
  Result:=JFC_TOKENITEM(lpitem).i8User;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.write_Item_i8Pos(p_i8: Int64);
//=============================================================================
Begin
  JFC_TOKENITEM(lpitem).i8User:=p_i8;
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.NthItem_saToken(p_i: Integer):AnsiString;
//=============================================================================
Begin
  Result:='';
  If FoundNth(p_i) Then Result:=JFC_TOKENITEM(lpitem).saToken;
End;
//=============================================================================


//=============================================================================
Function JFC_TOKENIZER.FoundItem_saToken(
  p_sa:AnsiString;
  p_bCaseSensitive:Boolean
):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_TOKENITEM(nil).saToken,
                           True,False);
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.FNextItem_saToken(
  p_sa:AnsiString;
  p_bCaseSensitive:Boolean
):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa, 
                           p_bCaseSensitive, 
                           @JFC_TOKENITEM(nil).saToken,
                           False,False);
End;
//=============================================================================




//=============================================================================
Function JFC_TOKENIZER.DumpToTextFile(p_saFileName: AnsiString): Integer;
//=============================================================================
Var f: text;
    saDashedLine:AnsiString;
    iBookMarkN: integer;
Begin
  iBookMarkN:=self.N;
  assign(f, p_saFilename);
  {$I-}
  FileMode:=read_write;
  rewrite(f);
  {$I+}
  Result:=ioresult;
  If Result=0 Then
  Begin
    saDashedLine:=StringOfChar('-',79);
    
    Writeln(f,'JFC_TOKENIZER.DumpToTextFile('+p_saFilename+')');
    Writeln(f,saDashedLine);
    Writeln(f,'Non-Displayable characters appear as (#n) where n is ascii code.');
    Writeln(f,'QuotesXDL.ListCount= ', QuotesXDL.ListCount);
    If QuotesXDL.ListCount>0 Then
    Begin
      QuotesXDL.MoveFirst;
      repeat
        Writeln(f,'Quote Pair ',QuotesXDL.iNN,': start (Length=',
          length(QuotesXDL.ITem_saNAme), ') >',
          saHumanReadable(QuotesXDL.Item_saNAme),'< end (Length=',
          length(QuotesXDL.Item_saDesc), ') >',
          saHumanReadable(QuotesXDL.Item_saDesc),'<');
      Until not QuotesXDL.MoveNext;
    End;
    Writeln(f);

    Write(f,'saQuotes (Length=',length(saQuotes),')>',
             saHumanreadable(saQuotes),'<');
    Writeln(f);
    
    
    Write(f,'saSeparators (Length=',length(saSeparators),')>',
             saHumanreadable(saSeparators),'<');
    Writeln(f);
    
    Write(f,'saWhiteSpace (Length=',length(saWhiteSpace),')>',
             saHumanreadable(saWhiteSpace),'<');
    Writeln(f);

    
    
    
    Writeln(f,saDashedLine);
    Writeln(f,'Quote Mode on Exit (Zero=Not In Quote Mode, Non-Zero=Which Quote Mode) :',iQuoteMode);
    Writeln(f,saDashedLine);
    Write(f,'Passed String>');
    If not bKeepDebugInfo Then Write(f,'--Class Not Set to "bKeepDebugInfo"--') Else
      Write(f,saHumanreadable(saLastOne));
    Writeln(f,'<');
    Writeln(f,saDashedLine);
    Writeln(f,'Tokens:',iItems);
    Writeln(f,saDashedLine);
    If ListCount>0 Then
    Begin
      MoveFirst;
      repeat
        Writeln(f,'Token ',iNN,' >',saHumanReadable(ITem_saToken),'< iQuoteID:',Item_iQuoteID );
      Until not MoveNext;
      Writeln(f,saDashedLine);
    End;
    Writeln(f);
    close(f);
  End;
  FoundNth(iBookMarkN);
  Result:=ioresult;
End;
//=============================================================================


//=============================================================================
Function JFC_TOKENIZER.Tokenize(p_sa: AnsiString): Integer; // Deletes Token List
//=============================================================================
Begin
  DeleteAll;
  iQuoteMode:=0;
  Result:=TokenizeMore(p_sa);
End;
//=============================================================================



//=============================================================================
// Continues where it left off from last tokenizemore or tokenize call
Function JFC_TOKENIZER.TokenizeMore(p_sa: AnsiString): Integer; 
//=============================================================================
Var iBP: Integer;
    iSep: Integer;
    iWhiteSpace: Integer;
    iListCountIn: Integer;
//    sa: AnsiString; 
    saUp: AnsiString;
    bGotStartQuote:Boolean;
//    i_saQuotesLength: integer;
//    i_saWhiteSpaceLength: integer;
//    i_saSeparatorsLength: integer;
    iSingleQuote: Integer;
    ipsaLength: Integer;
Begin
  // For Look-ahead optimization "branch" pre-process (put less often in else)
  If not bKeepDebugInfo Then 
  Else saLastOne:=p_sa; // For Use By "DumpToTextFile"
  
  iListCountIn:=iItems; // Record How Many Tokens So Far to Calc end result
  ipsalength:=length(p_sa);
  If (ipsalength>0) Then
  Begin
    //i_saQuotesLength:=length(saQuotes);
    //i_saWhiteSpaceLength:=length(saWhiteSpace);
    //i_saSeparatorsLength:=length(saSeparators);
    
    iBP:=1;
    AppendItem;
    if(ipsalength>0)then Item_i8Pos:=1;
    While iBP<=ipsalength Do
    Begin
      //if (iBP mod 1000)=0 then write(iBP,' ');
      If not bCaseSensitive Then 
         saUp:= UpCase(p_sa); // Keep upcased version handy for case insensitive stuff
  
      If iQuoteMode=0 Then
      Begin//not in quotemode
        // Quotes have highest priority - Check For them first
        If QuotesXDL.iItems>0 Then
        Begin
          QuotesXDL.MoveFirst;
          bGotStartQuote:=False;
          repeat
            
            If ipsalength-ibp>=length(QuotesXDL.Item_saName) Then
            Begin
              If ((not bCaseSensitive) and 
                     (copy(saUp,iBP,length(QuotesXDL.Item_saName))=
                     upcase(QuotesXDL.Item_saName)))
                 OR
                 (bCaseSensitive and     
                     (copy(p_sa,iBP,length(QuotesXDL.Item_saName))=
                     QuotesXDL.Item_saName))
              Then 
                 bGotStartQuote:=True;
            End;

            //Writeln('Looping...',p_sa);
          Until (bGotStartQuote) OR (not QuotesXDL.MoveNext);
          If bGotStartQuote Then
          Begin
            //Writeln('Got One!');
            iQuoteMode:=QuotesXDL.iNN;
            // Generate actual QUOTE Token
            
            If length(Item_saToken)<>0 Then AppendItem;
            
            //saToken:=Copy(p_sa, iBp, length(QuotesXDL.saName));
            //Writeln('Quote:',saname);
            Item_i8Pos:=iBP+1;
            iBP+=length(QuotesXDL.Item_saName);
            //sagelog(1,'length(QuotesXDL.saName):' + inttostr(length(QuotesXDL.saName)));
            
            iQuoteMode:=QuotesXDL.iNN;
            Item_iQuoteID:=iQuoteMode;
            
            
            // Generate "Quoted" text token
            //AppendItem;
            //iQuoteMode:=QuotesXDL.N;
            //iQuoteID:=iQuoteMode;
            
            // If End Quote is '' (nothing) then
            // Make the current token the rest of the line and bail
            If not (QuotesXDL.Item_saDesc='') Then
            Else 
            Begin
              iQuoteMode:=0;
              If iBP<=ipsalength Then
              Begin
                Item_saToken:=copy(p_sa,iBP,((ipsalength-ibp)+1));
              End;  
            End;
            
          End;
        End;

        // If still not in quote mode - Check Single Quote Stuff
        If iQuoteMode=0 Then
        Begin
          iSingleQuote:=pos(p_sa[iBP], saQuotes);
          If iSingleQuote>0 Then 
          Begin
            If length(Item_saToken)>0 Then 
            begin
              AppendItem;
              Item_i8Pos:=iBP+1;
            end;
            iBP+=1;
            iQuoteMode:=iSingleQuote*-1; // MAKE Negative to denote single quote thing
            Item_iQuoteID:=iQuoteMode;
          End;
        End;
        
        // If Still NOt in Quote Mode...
        // Search For normal Separators and do whitespace
        // filtering
        If iQuoteMode=0 Then
        Begin
          iSep:=pos(p_sa[iBP], saSeparators);
          iWhitespace:= pos(p_sa[iBP], saWhiteSpace);
          If iSep > 0 Then
          Begin
            If(Length(Item_saToken)>0) Then
            Begin
              AppendItem;
              Item_i8Pos:=iBP+1;
            End;
          End;
          
          If iWhiteSpace=0 Then
          Begin
            if(iSep>0)then
            begin
              if(length(Item_saToken)>0)then
              begin
                AppendItem;
                Item_saToken:=Item_saToken+p_sa[iBp];
                Item_i8Pos:=iBP+1;
              end
              else
              begin
                Item_saToken:=Item_saToken+p_sa[iBp];
                AppendItem;
                Item_i8Pos:=iBP+Length(Item_saToken);
              end;   
            end
            else
            begin
              Item_saToken:=Item_saToken+p_sa[iBp];
            end;
          End;

          iBP+=1;
        End;
      End//not in quotemode
      Else
      Begin//quotemode
        If iQuoteMode>0 Then 
        Begin // Multi Char Quote System
          // Search for end quote now
          If not ((ipsalength-ibp>=length(QuotesXDL.Item_saDesc)) and (
              
              ((not bCaseSensitive) and 
                   (copy(saUp,iBP,length(QuotesXDL.Item_saDesc))=
                   upcase(QuotesXDL.Item_saDesc)))
               OR
               (bCaseSensitive and     
                   (copy(p_sa,iBP,length(QuotesXDL.Item_saDesc))=
                   QuotesXDL.Item_saDesc))
            )) Then 
          Begin
            Item_saToken:=Item_saToken+p_sa[ibp];
            ibp+=1;
          End
          Else
          Begin
            //Writeln('Got END QUOTE!');
            iQuoteMode:=0;
            iBP+=length(QuotesXDL.Item_saDesc);
          End;  
          
          {
          //BEGIN - NEW - 201007070232
          if (not bCaseSensitive) then
          begin
            //Item_saToken:=Item_saToken+' pos:'+inttostr(Pos(upcase(Item_saToken),upcase(QuotesXDL.Item_saDesc)));
            if Pos(upcase(QuotesXDL.Item_saDesc),upcase(Item_saToken))>1 then
            begin
              Item_saToken:=LeftStr(Item_saToken,Pos(QuotesXDL.Item_saDesc,Item_saToken)-1);
            end
            else
            begin
              if upcase(QuotesXDL.Item_saDesc)=upcase(Item_saToken) then Item_saToken:='#@!JEG!@#';
            end;
          end
          else
          begin
            //Item_saToken:=Item_saToken+' pos:'+inttostr(Pos(upcase(Item_saToken),upcase(QuotesXDL.Item_saDesc)));
            if Pos(QuotesXDL.Item_saDesc,Item_saToken)>1 then
            begin
              Item_saToken:=LeftStr(Item_saToken,Pos(QuotesXDL.Item_saDesc,Item_saToken)-1);
            end
            else
            begin
              if QuotesXDL.Item_saDesc=Item_saToken then Item_saToken:='#@!JEG!@#';
            end;
          end;
          //END - NEW - 201007070232
          }
          
        End
        Else
        Begin // Single Char Quote System
          If p_sa[iBP]<>saQuotes[iQuoteMode*-1] Then 
          Begin // Not End Quote!
            Item_saToken:=Item_saToken+p_sa[iBp];
            //iBP+=1;
          End 
          Else 
          Begin
            If ipsalength>(iBp+1) Then 
            Begin // possible escape quote
              If (p_sa[iBp]=saQuotes[iQuoteMode*-1]) and 
                 (p_sa[iBp+1]<>saQuotes[iQuoteMode*-1]) Then 
              Begin // END QUOTE
                iQuoteMode:=0;
              End 
              Else 
              Begin // Escaped
                iBP+=1; // will get incremented again
                Item_saToken:=Item_saToken+saQuotes[iQuoteMode*-1];
              End;
            End 
            Else 
            Begin
              // EndQuote
              iQuoteMode:=0;
            End;
          End;
          iBP+=1;
        End;
        If iQuoteMode=0 Then AppendItem;
      End;//quotemode
    End;//end while
  End; // if ipsalength>0
  
  If (iItems>0) and (length(Item_saToken)=0) Then DeleteItem;
  //if(Item_saToken='#@!JEG!@#') then Item_saToken:='';
  
  Result:=iItems-iListCountIn;
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.FoundItem_iQuoteID(p_i: Integer):Boolean;
//=============================================================================
Begin
  Result:=FoundBinary(@p_i, SizeOf(Integer), 
                       @JFC_TOKENITEM(nil).iQuoteID, True,False);
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
