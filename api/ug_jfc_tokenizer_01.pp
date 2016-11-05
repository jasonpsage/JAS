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


{DEFINE DIAGMSG}
{$IFDEF DIAGMSG}
{$INFO DIAGNOSTIC MESSAGES ENABLED}
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
  // sQuotes. Value *-1 in this case tels you WHICH
  // Quote (char position in sQuotes)
  iQuoteID: Int;

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
  Function read_Item_iQuoteID:Int;
  Procedure write_Item_iQuoteID(p_i: Int);
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
  
  Property Item_iQuoteID: Int read read_Item_iQuoteID Write write_Item_iQuoteID;
  Property Item_saToken: AnsiString read read_Item_saToken Write write_item_saToken;
  Property Item_i8Pos: Int64 read read_Item_i8Pos Write write_Item_i8Pos;

  Property Tokens: uint read uItems; //< same as listcount in JFC_DL for example.
  Property Token: UInt read uN; //< same as "N" - The Sequential Position in JFC_DL for example.
  
  Function Tokenize(p_sa: AnsiString): Int; //< Deletes Token List
  Function TokenizeMore(p_sa: AnsiString): Int; //< Continues where it left off
  Function DumpToTextFile(p_saFileName: AnsiString): word;//< dumps the contents of the JFC_TOKENIZER, great for analysis and debugging.
  Function NthItem_saToken(p_i: Int): AnsiString; //< SAFE method - Give me the "N'th" record
  Function FoundItem_iQuoteID(p_i: Int):Boolean;
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
  sQuotes: String;

  {}
  // Separators START New Tokens
  // Load Up with separators
  sSeparators: AnsiString;
  
  // White Space Characters Don't Make it into TOKENS
  // unless within quotes. Whitespace shouldn't be in 
  // quotes. Load Up With WhiteSpace Chars (Get Dropped)
  sWhiteSpace: AnsiString;
  

  // 0 = not in quote mode, otherwise - points to 
  //     QUOTE mode last in.
  // NEGATIVE Value Means In Single Quote Mode From
  // sQuotes. Value *-1 in this case tels you WHICH
  // Quote.   
  iQuoteMode: INT;
                       
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
  sClassname:='JFC_QUOTEXDL';
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
  sClassname:='JFC_TOKENITEM';
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

// NOTE: Escaped singled quotes (sQuotes)can not SPAN multiple Tokenize Mores
//=============================================================================
Constructor JFC_TOKENIZER.create;
//=============================================================================
Begin
  Inherited;
  sClassname:='JFC_TOKENIZER';
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
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER - Setdefaults - Begin');
  {$ENDIF}
  QUOTESXDL.DeleteAll;
  saLastOne:='';
  bCaseSensitive:=False;
  bKeepDebugInfo:=False;
  sQuotes:='';
  sWhiteSpace:='';
  sSeparators:='';
  iQuoteMode:=0;
  self.deleteall;
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER - SetDefaults - End');
  {$ENDIF}
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
Function JFC_TOKENIZER.read_Item_iQuoteID:Int;
//=============================================================================
Begin
  Result:=JFC_TOKENITEM(lpitem).iQuoteID;
End;
//=============================================================================

//=============================================================================
Procedure JFC_TOKENIZER.write_Item_iQuoteID(p_i: Int);
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
Function JFC_TOKENIZER.NthItem_saToken(p_i: Int):AnsiString;
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
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.FoundItem_saToken - Begin');
  {$ENDIF}

  Result:=FoundAnsiString(p_sa,
                           p_bCaseSensitive, 
                           @JFC_TOKENITEM(nil).saToken,
                           True,False);
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.FoundItem_saToken - End');
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.FNextItem_saToken(
  p_sa:AnsiString;
  p_bCaseSensitive:Boolean
):Boolean;
//=============================================================================
Begin
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.FNextItem_saToken - Begin');
  {$ENDIF}
  Result:=FoundAnsiString(p_sa,
                           p_bCaseSensitive, 
                           @JFC_TOKENITEM(nil).saToken,
                           False,False);
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.FNextItem_saToken - End');
  {$ENDIF}
End;
//=============================================================================




//=============================================================================
Function JFC_TOKENIZER.DumpToTextFile(p_saFileName: AnsiString): word;
//=============================================================================
Var f: text;
    saDashedLine:AnsiString;
    uBookMarkN: uint;
    u2IOResult: word;
Begin
  u2IOResult:=0;
  uBookMarkN:=self.N;
  assign(f, p_saFilename);
  FileMode:=read_write;
  try
    rewrite(f);
    writeln(f,'JFC_TOKENIZER.DumpToTextFile(p_Filename:ansistring):word;');
  except on E:Exception do u2IOResult:=60000;end;//try
  u2IOResult+=ioresult;
  If u2IOResult=0 Then
  Begin
    saDashedLine:=StringOfChar('-',79);
    try
      Writeln(f,'JFC_TOKENIZER.DumpToTextFile('+p_saFilename+')');
      Writeln(f,saDashedLine);
      Writeln(f,'Non-Displayable characters appear as (#n) where n is ascii code.');
      Writeln(f,'QuotesXDL.ListCount= ', QuotesXDL.ListCount);
      If QuotesXDL.ListCount>0 Then
      Begin
        QuotesXDL.MoveFirst;
        repeat
          Writeln(f,'Quote Pair ',QuotesXDL.uN,': start (Length=',
            length(QuotesXDL.ITem_saNAme), ') >',
            saHumanReadable(QuotesXDL.Item_saNAme),'< end (Length=',
            length(QuotesXDL.Item_saDesc), ') >',
            saHumanReadable(QuotesXDL.Item_saDesc),'<');
        Until not QuotesXDL.MoveNext;
      End;
      Writeln(f);

      Write(f,'sQuotes (Length=',length(sQuotes),')>',
               saHumanreadable(sQuotes),'<');
      Writeln(f);


      Write(f,'sSeparators (Length=',length(sSeparators),')>',
               saHumanreadable(sSeparators),'<');
      Writeln(f);

      Write(f,'sWhiteSpace (Length=',length(sWhiteSpace),')>',
               saHumanreadable(sWhiteSpace),'<');
      Writeln(f);

      Writeln(f,saDashedLine);
      Writeln(f,'Quote Mode on Exit (Zero=Not In Quote Mode, Non-Zero=Which Quote Mode) :',iQuoteMode);
      Writeln(f,saDashedLine);
      Write(f,'Passed String>');
      If not bKeepDebugInfo Then Write(f,'--Class Not Set to "bKeepDebugInfo"--') Else
        Write(f,saHumanreadable(saLastOne));
      Writeln(f,'<');
      Writeln(f,saDashedLine);
      Writeln(f,'Tokens:',uItems);
      Writeln(f,saDashedLine);
      If ListCount>0 Then
      Begin
        MoveFirst;
        repeat
          Writeln(f,'Token ',uN,' >',saHumanReadable(ITem_saToken),'< iQuoteID:',Item_iQuoteID );
        Until not MoveNext;
        Writeln(f,saDashedLine);
      End;
      Writeln(f);
    except on e:exception do u2IOResult:=60000+ioresult;
    end;//try
  End;
  try close(f);except on E:Exception do;end;//try
  FoundNth(uBookMarkN);
  Result:=u2IOResult;
End;
//=============================================================================


//=============================================================================
Function JFC_TOKENIZER.Tokenize(p_sa: AnsiString): Int; // Deletes Token List
//=============================================================================
Begin
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.Tokenize - Begin');
  {$ENDIF}
  DeleteAll;
  iQuoteMode:=0;
  Result:=TokenizeMore(p_sa);
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.Tokenize - End');
  {$ENDIF}
End;
//=============================================================================



//=============================================================================
// Continues where it left off from last tokenizemore or tokenize call
Function JFC_TOKENIZER.TokenizeMore(p_sa: AnsiString): Int;
//=============================================================================
Var iBP: Int;
    iSep: Int;
    iWhiteSpace: Int;
    uListCountIn: UInt;
//    sa: AnsiString; 
    saUp: AnsiString;
    bGotStartQuote:Boolean;
//    i_sQuotesLength: int;
//    i_sWhiteSpaceLength: int;
//    i_sSeparatorsLength: int;
    iSingleQuote: Int;
    ipsaLength: Integer;
Begin
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.Tokenizemore - Begin');
  {$ENDIF}
  // For Look-ahead optimization "branch" pre-process (put less often in else)
  If not bKeepDebugInfo Then 
  Else saLastOne:=p_sa; // For Use By "DumpToTextFile"
  
  uListCountIn:=uItems; // Record How Many Tokens So Far to Calc end result
  ipsalength:=length(p_sa);
  If (ipsalength>0) Then
  Begin
    //i_sQuotesLength:=length(sQuotes);
    //i_sWhiteSpaceLength:=length(sWhiteSpace);
    //i_saSeparatorsLength:=length(saSeparators);
    
    iBP:=1;
    AppendItem;
    if(ipsalength>0)then Item_i8Pos:=1;
    While iBP<=ipsalength Do
    Begin
      //if (iBP mod 1000)=0 then rite(iBP,' ');
      If not bCaseSensitive Then 
         saUp:= UpCase(p_sa); // Keep upcased version handy for case insensitive stuff
  
      If iQuoteMode=0 Then
      Begin//not in quotemode
        {$IFDEF DIAGMSG}
        //riteln('JFC_TOKENIZER.tokenizemore - Quotes have highest priority - Check For them first');
        {$ENDIF}
        If QuotesXDL.uItems>0 Then
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

            {$IFDEF DIAGMSG}
            //riteln('JFC_TOKENIZER.TokenizeMore - Looping - A');
            {$ENDIF}
          Until (bGotStartQuote) OR (not QuotesXDL.MoveNext);
          If bGotStartQuote Then
          Begin
            {$IFDEF DIAGMSG}
            //riteln('JFC_TOKENIZER.Tokenizemore - Got One!');
            {$ENDIF}
            iQuoteMode:=QuotesXDL.uN;

            {$IFDEF DIAGMSG}
            //riteln('JFC_TOKENIZER.Tokenizemore - Generate actual QUOTE Token');
            {$ENDIF}
            If length(Item_saToken)<>0 Then AppendItem;
            
            //saToken:=Copy(p_sa, iBp, length(QuotesXDL.saName));
            {$IFDEF DIAGMSG}
            //riteln('JFC_TOKENIZER.Tokenizemore - QuoteXDL.Item_saName:',QuotesXDL.Item_saName);
            {$ENDIF}

            Item_i8Pos:=iBP+1;
            iBP+=length(QuotesXDL.Item_saName);
            //sagelog(1,'length(QuotesXDL.saName):' + inttostr(length(QuotesXDL.saName)));
            
            iQuoteMode:=QuotesXDL.uN;
            Item_iQuoteID:=iQuoteMode;
            
            
            // Generate "Quoted" text token
            //AppendItem;
            //iQuoteMode:=QuotesXDL.N;
            //iQuoteID:=iQuoteMode;
            

            {$IFDEF DIAGMSG}
            //riteln('JFC_TOKENIZER.Tokenizemore - Is End Quote Nothing? >',QuotesXDL.Item_saDesc,'<');
            {$ENDIF}
            // If End Quote is '' (nothing) then
            // Make the current token the rest of the line and bail
            If not (QuotesXDL.Item_saDesc='') Then
            Else 
            Begin
              iQuoteMode:=0;
              If iBP<=ipsalength Then
              Begin
                {$IFDEF DIAGMSG}
                //riteln('JFC_TOKENIZER.Tokenizemore - begin - quote - token copy');
                {$ENDIF}
                Item_saToken:=copy(p_sa,iBP,((ipsalength-ibp)+1));
                {$IFDEF DIAGMSG}
                //riteln('JFC_TOKENIZER.Tokenizemore - End - quote - token copy');
                {$ENDIF}
              End;  
            End;
            
          End;
        End;

        // If still not in quote mode - Check Single Quote Stuff
        If iQuoteMode=0 Then
        Begin
          {$IFDEF DIAGMSG}
          //riteln('JFC_TOKENIZER.Tokenizemore - begin - Check for Single quote');
          {$ENDIF}
          iSingleQuote:=pos(p_sa[iBP], sQuotes);
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
          {$IFDEF DIAGMSG}
          //riteln('JFC_TOKENIZER.Tokenizemore - Still NOt in Quote Mode...');
          {$ENDIF}
          iSep:=pos(p_sa[iBP], sSeparators);
          iWhitespace:= pos(p_sa[iBP], sWhiteSpace);
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
            {$IFDEF DIAGMSG}
            //riteln('Got END QUOTE! Start block');
            {$ENDIF}
            iQuoteMode:=0;
            iBP+=length(QuotesXDL.Item_saDesc);
            {$IFDEF DIAGMSG}
            //riteln('Got END QUOTE! end block');
            {$ENDIF}
          End;
        End
        Else
        Begin
          {$IFDEF DIAGMSG}
          //riteln('JFC_TOKENIZER.tokenizemore - Single Char Quote System');
          {$ENDIF}
          If p_sa[iBP]<>sQuotes[iQuoteMode*-1] Then
          Begin // Not End Quote!
            Item_saToken:=Item_saToken+p_sa[iBp];
            //iBP+=1;
          End 
          Else 
          Begin
            If ipsalength>(iBp+1) Then 
            Begin // possible escape quote
              If (p_sa[iBp]=sQuotes[iQuoteMode*-1]) and
                 (p_sa[iBp+1]<>sQuotes[iQuoteMode*-1]) Then
              Begin // END QUOTE
                iQuoteMode:=0;
              End 
              Else 
              Begin // Escaped
                iBP+=1; // will get incremented again
                Item_saToken:=Item_saToken+sQuotes[iQuoteMode*-1];
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
        If iQuoteMode=0 Then
        begin
          {$IFDEF DIAGMSG}writeln('Length: ',ipsalength,' Pos: ',iBP, ' Token: ',Item_saToken);{$ENDIF}
          AppendItem;
        end;
      End;//quotemode
    End;//end while
  End; // if ipsalength>0
  
  If (uItems>0) and (length(Item_saToken)=0) Then DeleteItem;
  //if(Item_saToken='#@!JEG!@#') then Item_saToken:='';
  
  Result:=uItems-uListCountIn;
  {$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.TokenizeMore - END');
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JFC_TOKENIZER.FoundItem_iQuoteID(p_i: Int):Boolean;
//=============================================================================
Begin
{$IFDEF DIAGMSG}
  //riteln('JFC_TOKENIZER.FoundItem_iQuoteID - i:',p_i,' BEGIN');
{$ENDIF}
  Result:=FoundBinary(@p_i, SizeOf(Int),
                       @JFC_TOKENITEM(nil).iQuoteID, True,False);
{$IFDEF DIAGMSG}
//riteln('JFC_TOKENIZER.FoundItem_iQuoteID - END');
{$ENDIF}
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
