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
function test_jfc_tokenizer: boolean;
//=============================================================================
var TK: jfc_TOKENIZER;
    dwResult: LongWord;
    saResult: AnsiString;

label jumphere;

Begin
  result:=true;

  TK:=jfc_TOKENIZER.Create;
  
  writeln('TEST 1 --------------------');
  // Test01
  TK.bKeepDebugInfo:=true;
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  //TK.QuotesDL.AppendItem('','');
  TK.bKeepDebugInfo:=true;
  result:=(TK.Tokenize('Hello There Dude!')=3) and
          (TK.NthItem_saToken(1)='Hello') and
          (TK.NthItem_saToken(2)='There') and 
          (TK.NthItem_saToken(3)='Dude!') and 
          (TK.MoveFirst) and
          (TK.Item_saToken='Hello') and
          (TK.MoveNext) and
          (TK.Item_saToken='There') and 
          (TK.MoveNExt) and
          (TK.Item_saToken='Dude!') and
          (not TK.MoveNExt) and
          (TK.Tokens=TK.ListCount);
          
  if not result then Begin
    Writeln('Error With Test #1');
    goto jumphere;
  End;
  writeln('TEST 1 -------------------- PASSED');
  writeln;

  
  
  // Test02
  writeln('TEST 2 --------------------');
  TK.sSeparators:=' ';
  TK.sWhiteSpace:=' ';
  TK.DeleteAll;//writeln('just emptied tokens TK.ListCount:',TK.ListCount);
  setlength(TK.aQuotePair,0);
  TK.AppendQuotePair('[@','@]');
  result:=length(TK.aQuotePair)=1;

  //writeln('test 2:TK.Tokenize(''Hello There [@name@]!''):',TK.Tokenize('Hello There [@name@]!'));

  if not result                                                                       then writeln('test02 - A');
  if result then begin result:=(TK.ListCount=0);                        if not result then writeln('test02 - B');  end;
  if result then begin result:=(TK.Tokenize('Hello There [@name@]!')=4);if not result then writeln('test02 - C');  end;
  if result then begin result:=TK.MoveFirst;                            if not result then writeln('test02 - D');  end;
  if result then begin result:=(Tk.Item_saToken='Hello');               if not result then writeln('test02 - E');  end;
  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('test02 - F');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('test02 - G');  end;
  if result then begin result:=(TK.Item_saToken='There');               if not result then writeln('test02 - H');  end;
  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('test02 - I');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('test02 - J');  end;
  if result then begin result:=(TK.Item_saToken='name');                if not result then writeln('test02 - K');  end;
  if result then begin result:=(TK.Item_iQuoteID=1);                    if not result then writeln('test02 - L');  end;
  if result then begin result:=TK.MoveNExt;                             if not result then writeln('test02 - M');  end;




  if result then begin result:=(tk.Item_saToken='!');                   if not result then writeln('test02 - N');  end;




  if result then begin result:=(TK.Item_iQuoteID=0);                    if not result then writeln('test02 - O');  end;
  if not result then Begin
    Writeln('Error in Test 02');
    goto jumphere;
  End;

  //tk.dumptotextfile('debug_tokenizer.txt');
  //riteln('test2 - see debug_tokenizer.txt');
  //riteln('Press ENTER to Continue.');
  //eadln;

  Tk.DeleteAll;
  TK.Destroy;
  writeln('TEST 2 -------------------- PASSED');
  writeln;

  // Future: Allow Blank Start quote - Test



  // Future: Allow Blank End Quote - Test




// ---- TWEAKED Version 1 Stuff Below (single Quotes in sQUOTES only)
  writeln('TEST 3 --------------------');
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
    goto jumphere;
  End;
  //Writeln('Token Batch 1');
  writeln('TEST 3 -------------------- PASSED');
  writeln;


  writeln('TEST 4 --------------------');
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
    goto jumphere;
  End;
  writeln('TEST 4 -------------------- PASSED');
  writeln;

  
  writeln('TEST 5 --------------------');
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

  if not Result then goto jumphere;
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
  
  if not Result then 
  Begin
    //Writeln('Problem With jfc_TOKENIZER.TOKENIZER(''Hello There'')');
    goto jumphere;
  End;
  writeln('TEST 5 -------------------- PASSED');
  writeln;

  //Writeln('Token Batch 4');
  





  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA
  //  BEGIN CURRENT PROBLEM AREA

  writeln('TEST 6 --------------------');
//  Write('TOKENIZR - First Big Test - OK! Press Enter:');
//  readln;
  TK.sQuotes:='"';
  TK.sSeparators:=', ';
  TK.sWhiteSpace:=' ';
  if Result then Begin
    dwResult:=TK.Tokenize('Hello, "John""Boy"""');
    result:=dwResult=3;
    //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""Boy"""'')');
    if not result then Begin
      Writeln('Failed to return valid result' +
        '. Expected:3 Recieved:',dwResult);
      goto jumphere;
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
      goto jumphere;
    End;
  End;

  //Writeln('Token Batch 6');
  if Result then Begin
    saResult:=TK.NthItem_saToken(3);
    Result:=saResult='John"Boy"';
    if not Result then Begin
      Writeln('TK.NthItem_saToken(2) failed. '+
        'Expected:''John"Boy"'' Recieved:'''+saResult+'''');
      goto jumphere;
    End;
  End;
  if result then Begin
    result:=TK.Item_iQuoteID<0;
    if not result then Begin
      Writeln('(TK.Item_iQuoteID<0) Nope. Failed!'+
        ' Expected TRUE, Got FALSE - Aw MAN!');
      goto jumphere;
    End;
  End;

  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=3;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
       'result. Expected:3 Recieved:', dwResult);
  End;
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


  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA
  // END CURRENT PROBLEM AREA




  writeln('TEST 7 --------------------');
  //Writeln('Token Batch 7');
  TK.sQuotes:='"';
  TK.sSeparators:='';
  TK.sWhiteSpace:=' ';
  if Result then dwResult:=TK.Tokenize('Hello  There');
  if Result then Result:=dwresult=1;
  if not result then 
  Begin
    Writeln('jfc_TOKENIZER.TOKENIZER(''Hello  There'') With Special Config');
    Writeln('Problem With jfc_TOKENIZER.Tokenize(''Hello There''); With special config');
    goto jumphere;
  End;
  writeln('TEST 7 -------------------- PASSED');


  //Writeln('Token Batch 8');
  
  
JumpHere:
  TK.DumpToTextFile('debug_tokenizer.txt');
  TK.Destroy;
  
  //Writeln('jfc_TOKENIZER Tests:',Result);

// code to examine tokens
//  for dwResult :=1 to dwResult do
//  begin
//    Writeln('>' + TK.TokenText(dwResult) + '< ',dwResult);
//  end;
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

