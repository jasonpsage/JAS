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
// Test Jegas' jfc_tokenizer class
program test_ug_jfc_tokenizer;
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
  ug_common,
  ug_jfc_tokenizer;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// jfc_TOKENIZER Test Code
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=


//=============================================================================
// Points to Address is tests
//=============================================================================
//   bCaseSensitive: Boolean; //< Default FALSE
// X bKeepDebugInfo: Boolean; //< Default FALSE (But you better check!)
// X Property Item_iQuoteID: Int read read_Item_iQuoteID Write write_Item_iQuoteID;
// X Property Item_saToken: AnsiString read read_Item_saToken Write write_item_saToken;
//   Property Item_i8Pos: Int64 read read_Item_i8Pos Write write_Item_i8Pos;
// X Property Tokens: uint read uRows; //< same as listcount in JFC_DL for example.
// X Property Token: UInt read N; //< same as "N" - The Sequential Position in JFC_DL for example.
// X Function Tokenize(p_sa: AnsiString): Int; //< Deletes Token List
//   Function TokenizeMore(p_sa: AnsiString): Int; //< Continues where it left off
// X Function DumpToTextFile(p_saFileName: AnsiString): word;//< dumps the contents of the JFC_TOKENIZER, great for analysis and debugging.
// X Function NthItem_saToken(p_i: Int): AnsiString; //< SAFE method - Give me the "N'th" record
//   Function FoundItem_iQuoteID(p_i: Int):Boolean;
// X Procedure SetDefaults;//< Does what you think, but a look at the ug_jfc_tokenizer.pp would give you the specifics on what those defaults are.
//   procedure AppendQuotePair(p_sStart: string; p_sEnd: string); inline;//< used to apply a quote pair to the JFC_TOKENIZER class' aQuote[] of rtQuotePair.
//   function QuotePairs: UINT;//< returns length of the array in the class - for conveniance and more readable then length(Tk.aQuote) everywhere :)
//   Function SortTokens(p_bCaseSensitive: Boolean;p_bAscending: Boolean):Boolean;//< Alphabetically sorts the tokens
// X aQuotePair: array of rtQuotePair;
// X sQuotes: String;
// X sSeparators: String;
// X sWhiteSpace: String;
// X iQuoteMode: INT;
//   Function FoundItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//   Function FNextItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================



































//=============================================================================
function bTest01:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
  bOK: Boolean;
begin
  writeln('Test 01');
  bOk:=true;
  TK:=JFC_TOKENIZER.Create;
  TK.SetDefaults;
  TK.bKeepDebugInfo:=true;
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  //TK.QuotesDL.AppendItem('','');
  TK.bKeepDebugInfo:=true;
  bOk:=(TK.Tokenize('Hello There Dude!')=3);
  //TK.DumpToTextfile('tokendump.txt');
  if bOk then
  begin
    bOk:=(TK.NthItem_saToken(1)='Hello');
    if not bOk then
    begin
      writeln('MARK A');
    end;
  end;

  if bOk then
  begin
    bOk:=(TK.NthItem_saToken(2)='There');
    if not bOk then
    begin
      writeln('MARK B');
    end;
  end;

  if bOk then
  begin
    bOk:=(TK.NthItem_saToken(3)='Dude!');
    if not bOk then
    begin
      writeln('MARK C');
    end;
  end;

  if bOk then
  begin
    bOk:=TK.MoveFirst;
    if not bOk then
    begin
      writeln('MARK D');
    end;
  end;

  if bOk then
  begin
    bOk:=TK.Item_saToken='Hello';
    if not bOk then
    begin
      writeln('MARK E');
    end;
  end;

  if bOk then
  begin
    bOk:=TK.MoveNext;
    if not bOk then
    begin
      writeln('MARK F');
    end;
  end;


  if bOk then
  begin
    bOk:=TK.Item_saToken='There';
    if not bOk then
    begin
      writeln('MARK G');
    end;
  end;

  if bOk then
  begin
    bOk:= TK.MoveNExt;
    if not bOk then
    begin
      writeln('MARK H');
    end;
  end;

  if bOk then
  begin
    bOk:=TK.Item_saToken='Dude!';
    if not bOk then
    begin
      writeln('MARK I');
    end;
  end;

  if bOk then
  begin
    bOk:= not TK.MoveNExt;
    if not bOk then
    begin
      writeln('MARK J');
    end;
  end;

  if bOk then
  begin
    bOk:= TK.Tokens = TK.ListCount;
    if not bOk then
    begin
      writeln('MARK K');
    end;
  end;

  TK.Destroy;
  result:=bOk;
end;
//=============================================================================



























//=============================================================================
function bTest02:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
begin
  writeln('Test 02');
  TK:=JFC_TOKENIZER.Create;
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  TK.DeleteAll;//writeln('just emptied tokens TK.ListCount:',TK.ListCount);
  setlength(TK.aQuotePair,0);
  TK.AppendQuotePair('[@','@]');
  result:=length(TK.aQuotePair)=1;
  //writeln('test 2:TK.Tokenize(''Hello There [@name@]!''):',TK.Tokenize('Hello There [@name@]!'));
  if not result                                                                       then writeln('Mark A');
  if result then begin result:=(TK.ListCount=0);                        if not result then writeln('Mark B');  end;
  if result then begin result:=(TK.Tokenize('Hello There [@name@]!')=4);if not result then writeln('Mark C');  end;
  if result then begin result:=TK.MoveFirst;                            if not result then writeln('Mark D');  end;
  if result then begin result:=(Tk.Item_saToken='Hello');               if not result then writeln('Mark E');  end;
  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('Mark F');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('Mark G');  end;
  if result then begin result:=(TK.Item_saToken='There');               if not result then writeln('Mark H');  end;
  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('Mark I');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('Mark J');  end;
  if result then begin result:=(TK.Item_saToken='name');                if not result then writeln('Mark K');  end;
  if result then begin result:=(TK.Item_iQuoteID=1);                    if not result then writeln('Mark L');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('Mark M');  end;
  if result then begin result:=(tk.Item_saToken='!');                   if not result then writeln('Mark N');  end;
  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('Mark O');  end;
  //tk.dumptotextfile('debug_tokenizer.txt');
  //riteln('test2 - see debug_tokenizer.txt');
  //riteln('Press ENTER to Continue.');
  //eadln;
  TK.Destroy;
end;
//=============================================================================
















//=============================================================================
function bTest03:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
begin
  writeln('Test 03');
  TK:=JFC_TOKENIZER.Create;
// ---- TWEAKED Version 1 Stuff Below (single Quotes in sQUOTES only)
  //Writeln('Testing Single Quote System...');
  TK:=jfc_TOKENIZER.Create;
  TK.bKeepDebugInfo:=true;
  //Writeln('Past Token Init');
  Result:=true;
  if Result then result:=TK.sQuotes='';
  if Result then result:=TK.sSeparators='';
  if Result then result:=TK.sWhiteSpace='';
  if Result then result:=TK.Tokens=0;
  //if Result then result:=TK.TokenText='';    // Equivalent would bomb cuz ZERO
  if Result then result:=TK.NthItem_saToken(1)=''; // Always works - returns '' when not found
  if Result then result:=TK.Token=0;
  if not Result then Begin
    Writeln('Problem With jfc_TOKENIZER Init');
  End;
  TK.Destroy;
end;
//=============================================================================














//=============================================================================
function bTest04:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
begin
  writeln('Test 04');
  TK:=JFC_TOKENIZER.Create;
  TK.sQuotes:='"';
  TK.sSeparators:=', ';
  TK.sWhiteSpace:=' ';
  if Result then result:=TK.Tokenize('')=0;
  if Result then result:=TK.sQuotes='"';
  if Result then result:=TK.sSeparators=', ';
  if Result then result:=TK.sWhiteSpace=' ';
  if Result then result:=TK.Tokens=0;
  //if Result then result:=TK.TokenText='';
  //if Result then result:=TK.TokenText(1)='';
  if Result then result:=TK.Token=0;
  if not Result then Begin
    Writeln('Problem With jfc_TOKENIZER.TOKENIZER('''')');
  End;
  TK.Destroy;
end;
//=============================================================================


















//=============================================================================
function bTest05:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
  dwResult: cardinal;
  saREsult:ansistring;
begin
  writeln('Test 05');
  TK:=JFC_TOKENIZER.Create;
  TK.sQuotes:='';
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  //if not Result then Writeln('jfc_TOKENIZER.TOKENIZER(''Hello There'')');
  //Writeln('before tokenize');
  dwResult:=TK.Tokenize('Hello There');
  //Writeln('after tokenize');
  if Result then Begin
    result:=dwResult=2;
    if not Result then Begin
      Writeln('Failed to return valid result' +
        '. Expected:2 Recieved:',dwResult);
    End;
  End;

  if Result then Begin
    result:=TK.sQuotes='';
    if not Result then Writeln('TK.sQuotes corrupt');
  End;
  if Result then Begin
    result:=TK.sSeparators=' ';
    if not Result then Writeln('TK.sSeparators corrupt');
  End;
  if Result then Begin
    result:=TK.sWhiteSpace=' ';
    if not Result then Writeln('TK.sWhiteSpace Corrupt');
  End;
  if Result then Begin
    dwResult:=TK.Tokens;
    result:=dwResult=2;
    if not Result then Writeln('TK.Tokens Returned Invalid Result. '+
       'Expected:2 Recieved:',dwResult);
  End;
  TK.MoveFirst;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult='Hello';
    if not Result then Writeln('TK.TokenText failed to return a valid '+
       'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;

  if Result then Begin
    saResult:=TK.NthItem_saToken(1);
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken(1) failed to return valid '+
       'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token; // Same as TK.N;
    result:=dwResult=1;
    if not Result then Writeln('(check 1) TK.Token failed to return valid '+
       'result. Expected:1 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.NthItem_saToken(2);
    result:=saResult='There';
    if not Result then Writeln('TK.NthItem_saToken(2) failed to return valid '+
       'result. Expected:''There'' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=2;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
      'result. Expected:2 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult='There';
    if not Result then Writeln('TK.Item_saToken failed to return valid '+
       'result. Expected:''There'' Recieved:'''+saResult+'''');
  End;

  TK.Destroy;
end;
//=============================================================================




















//=============================================================================
function bTest06:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
  dwResult: cardinal;
  saREsult: ansistring;
begin
  TK:=JFC_TOKENIZER.Create;
  writeln('Test 06');
  TK.sQuotes:='"';
  TK.sSeparators:=', ';
  TK.sWhiteSpace:=' ';
  if Result then Begin
    dwResult:=TK.Tokenize('Hello, "John""Boy"""');
    tk.dumptotextfile('tokendump.txt');
    result:=dwResult=3;
    //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""oy"""'')');
    if not result then Begin
      Writeln('Failed to return valid result' +
        '. Expected:3 Recieved:',dwResult);
    End;
  End;
  //Writeln('Token Batch 5');

  if Result then Begin
    result:=TK.sQuotes='"';
    if not Result then Writeln('TK.sQuotes corrupt');
  End;
  if Result then Begin
    result:=TK.sSeparators=', ';
    if not Result then Writeln('TK.sSeparators corrupt');
  End;
  if Result then Begin
    result:=TK.sWhiteSpace=' ';
    if not Result then Writeln('TK.sWhiteSpace Corrupt');
  End;
  if Result then Begin
    dwResult:=TK.Tokens;
    result:=dwResult=3;
    if not Result then Writeln(' -> TK.Tokens Returns Invalid Result. '+
      'Expected:3 Recieved:',dwResult);
  End;
  if Result then Begin
    TK.MoveFirst;
    saResult:=TK.NthItem_saToken(TK.Token);
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken failed to return valid '+
      'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then saResult:=TK.NthItem_saToken(1);
  if Result then Begin
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken(1) failed to return valid '+
      'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then dwResult:=TK.Token;
  if Result then Begin
    result:=dwResult=1;
    if not Result then Writeln('(check 1) TK.Token failed to return valid '+
       'result. Expected:1 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.NthItem_saToken(2);
    result:=saResult=',';
    if not Result then Writeln('TK.NthItem_saToken(2) failed to return valid '+
      'result. Expected:'','' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=2;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
       'result. Expected:2 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult=',';
    if not Result then Begin
      //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""Boy"""'')');
      Writeln('TK.Item_saToken failed to return valid '+
       'result. Expected:'','' Recieved:'''+saResult+'''');
    End;
  End;

  //Writeln('Token Batch 6');
  if Result then Begin
    saResult:=TK.NthItem_saToken(3);
    Result:=saResult='John"Boy"';
    if not Result then Begin
      Writeln('TK.NthItem_saToken(2) failed. '+
        'Expected:''John"Boy"'' Recieved:'''+saResult+'''');
    End;
  End;
  if result then Begin
    result:=TK.Item_iQuoteID<0;
    if not result then Begin
      Writeln('(TK.Item_iQuoteID<0) Nope. Failed!'+
        ' Expected TRUE, Got FALSE - Aw MAN!');
    End;
  End;

  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=3;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
       'result. Expected:3 Recieved:', dwResult);
  End;

// TROUBLE SPOT ???
//  {
//  if Result then Begin
//    saResult:=TK.Item_saToken;
//    result:=saResult='"';
//    if not Result then
//    Begin
//      Writeln('TK.TokenText failed to return valid '+
//        'result. Expected:''"'' Recieved:'''+saResult+'''');
//      //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""Boy"""'')');
//      //Writeln('Problem With jfc_TOKENIZER.Tokenize(''Hello, "John""Boy"""'');');
//    End;
//  End;
//  }
//
//  if not result then Begin
//    goto jumphere;
//  End;
//  writeln('TEST 6 -------------------- PASSED');
//  writeln;
  TK.Destroy;
end;
//=============================================================================


























//=============================================================================
function bTest07:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
  bOK: Boolean;
begin
  writeln('Test 07');
  bOk:=true;
  TK:=JFC_TOKENIZER.Create;
  TK.sQuotes:='"';
  TK.sSeparators:='';
  TK.sWhiteSpace:=' ';
  bOk:=TK.Tokenize('Hello  There')=1;
  if not bOk then
  Begin
    Writeln('jfc_TOKENIZER.TOKENIZER(''Hello  There'') With Special Config');
    Writeln('Problem With jfc_TOKENIZER.Tokenize(''Hello There''); With special config');
  End;
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================












//=============================================================================
function bTest08:boolean;
//=============================================================================
var
  TK: JFC_Tokenizer;
  u: uint;
  bOk: boolean;
begin
  writeln('Test 08');
  TK:=JFC_TOKENIZER.Create;
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  u:=TK.Tokenize('Hello LiveCoding.tv during testing YAY');
  //TK.bKeepDebugInfo:=true;
  //TK.DumpToTextFile('tokendump.txt');
  bOk:= u = 5 ;
  if not bOk then
  Begin
    Writeln('Expected 5 Tokens but got ',u);
  End;

  if bOk then
  begin
    bOk:=TK.FoundItem_saToken('LiveCoding.tv',false);
    if not bOk then
    begin
      writeln('Mark A');
    end;
  end;

  if bOk then
  begin
    bOk:=TK.FNextItem_saToken('testing',false);
    if not bOk then
    begin
      writeln('Mark B');
    end;
  end;

//   Function FoundItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//   Function FNextItem_saToken(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;

  TK.Destroy;
  result:=bOk;
end;
//=============================================================================














//=============================================================================
function test_jfc_tokenizer: boolean;
//=============================================================================
Begin
  result:=bTest01;
  if result then result:=bTest02;
  if result then result:=bTest03;
  if result then result:=bTest04;
  if result then result:=bTest05;
  if result then result:=bTest06;
  if result then result:=bTest07;
  if result then result:=bTest08;
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
    bResult:=test_jfc_tokenizer;
    Writeln('jfc_TOKENIZER Test Result:',bResult);
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

