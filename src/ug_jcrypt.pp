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
// Jegas Encryption Cypher
Unit ug_jcrypt;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jcrypt.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
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
sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_tokenizer
;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//=============================================================================


//=============================================================================
{}
// Returns a randomly generated public and private key combination.
// p_SecKey.saName = PUBLIC KEY
// p_SecKey.saValue = PRIVATE KEY
procedure JegasCrypt(var p_SecKey: rtNameValuePair);
//=============================================================================
{}
// The Mixer returns two long strings. The First is redundant admittedly at
// this point. This routine scrambles the order of 256 bytes in an array
// 65536 times then returns the p_NVP.saName (the redundant bit) as a series
// of hex values from 00 thru FF. The mixed up stuff comes back in
// p_NVP.saValue. This is to be used to generate a constant that is used in
// code that needs to encrypt and decrypt data using JCrypt.
Procedure JCryptMixer(var p_NVP: rtNameValuePair);
//=============================================================================

//=============================================================================
{}
// Single Key Encryption -
// RISK: Requires 3rd + party intercept + Encryption code To Break Easily.
function saJegasEncryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring; p_iPadLength: integer): ansistring;
//=============================================================================
{}
// Single Key Encryption - Requires cookie intercept
// RISK: Requires 3rd party intercept + Encryption code To Break Easily.
function saJegasDecryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring): ansistring;
//=============================================================================
{}
// returns randomly generated KEYS - Good for coming up with your own
// public and private keys. 512*8 = 4096 bit Encryption
function saKeyGen: ansistring;
//=============================================================================
{}
// USE AFTER SETTING saJCrypt
procedure JCryptMix(p_saMix: ansistring);
//=============================================================================
{}
function saJCryptMix: ansistring;
//=============================================================================
{}
function bJCryptIsRegistered(
  p_saName: ansistring;
  p_saEmail: ansistring;
  p_saRegKey: ansistring;
  p_saCrypt: ansistring;
  p_saMix: ansistring
): boolean;
//=============================================================================
{}
function bJCryptIsValidRegKey(
  p_saName: ansistring;
  p_saEmail: ansistring;
  p_saRegKey: ansistring;
  p_saCrypt: ansistring;
  p_saMix: ansistring
): boolean;
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

//=============================================================================
var
//=============================================================================
  au1Mix: array of byte;
  pvt_saJCryptMix: ansistring;
//=============================================================================


function saJCryptMix:Ansistring;
var i: byte;
begin
  result:='';
  for i:=1 to 50 do result:=result+char(random(26)+65);
end;



//=============================================================================
Procedure JCryptMixer(var p_NVP: rtNameValuePair);
//=============================================================================
var
  sa: ansistring;
  i: integer;
  asu1: array [0..255] of byte;
  iSwap1: integer;
  iSwap2: integer;
  u1Swap1: byte;
  u1Swap2: byte;
begin
  sa:='';
  randomize;
  for i:=0 to 255 do
  begin
    asu1[i]:=i;
    sa+=saByteToHex(i);
  end;
  p_NVP.saName:=sa;

  sa:='';
  for i:=0 to 65535 do
  begin
    iSwap1:=random(256);
    iSwap2:=random(256);
    if iSwap1<>iSwap2 then
    begin
      u1Swap1:=asu1[iSwap1];
      u1Swap2:=asu1[iSwap2];
      asu1[iSwap1]:=u1Swap2;
      asu1[iSwap2]:=u1Swap1;
    end;
  end;

  sa:='';
  for i:=0 to 255 do
  begin
    sa+=saByteToHex(asu1[i]);
  end;
  p_NVP.saValue:=sa;
end;


//=============================================================================
function saKeyGen: ansistring;
var
  sa: ansistring;
  i: integer;
begin
  sa:='';
  for i:=1 to 512 do
  begin
    sa+=saByteToHex(random(256));
  end;
  result:=sa;
end;
//=============================================================================


//=============================================================================
{}
// p_SecKey.saName = PUBLIC KEY
// p_SecKey.saValue = PRIVATE KEY
procedure JegasCrypt(var p_SecKey: rtNameValuePair);
//=============================================================================
begin
  p_SecKey.saName:=saKeyGen;
  p_SecKey.saValue:=saKeyGen;
end;
//=============================================================================

//=============================================================================
function saJegasEncryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring; p_iPadLength: integer): ansistring;
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  iPad: integer;
  iMustAdd: integer;
  saPadCode: ansistring;
  p,i,x: integer;
  au1: array of byte;
  au1Pub: array of byte;

  h: ansistring;

  iDataLen: integer;
  iPubKeyLen: integer;
begin
  result:='ERROR - JCRYPT';
  iDataLen:=length(p_saData);
  iPubKeyLen:=length(p_saPubKey);

  bOk:=(iPubKeyLen=1024);//public key
  if bOk then
  begin
    if p_iPadLength>0 then
    begin
      iPad:=length(p_saData) mod p_iPadLength;
      if (iDataLen=0) then iPad:=p_iPadLength;
      if (iPad>0) then
      begin
        iMustAdd := p_iPadLength - iPad;
        //riteln('iMustAdd:',iMustAdd);
        saPadCode := 'JCRYPTPAD['+inttostr(iMustAdd)+']';
        for p:=0 to (iMustAdd-1) do
        begin
          p_saData := p_saData + char(random(26)+65);
        end;
        p_saData := saPadCode + p_saData;
      end;
    end;
    iDataLen:=length(p_saData);

    setlength(au1,iDataLen);
    i:=1;
    repeat
      au1[i-1]:=byte(p_saData[i]);
      //riteln('p_saData[',i,']:'+p_saData[i],' converted to byte:',au1[i-1]);
      i:=i+1;
    until i > iDataLen;

    for i:=0 to length(au1)-1 do
    begin
      //riteln('au1[',i,'] mixed from ',au1[i], ' to ' ,au1Mix[au1[i]]);
      au1[i]:=au1Mix[au1[i]];
    end;

    setlength(au1Pub,iPubKeyLen div 2);
    i:=1;
    x:=0;
    repeat
      if i=1 then
      begin
        //riteln;
        //riteln('pubkey:'+saMid(p_saPubKey,i,2));
        //riteln;
      end;
      au1Pub[x]:=u8HexTou8(saMid(p_saPubKey,i,2));
      if i=1 then
      begin
        //riteln('au1Pub[x]:',au1Pub[x]);
      end;
      i:=i+2;
      x:=x+1;
    until i > iPubKeyLen;

    for i:=0 to length(au1)-1 do
    begin
      //riteln('mod: ',i mod 1024, ' ',au1Pub[i mod 1024]);

      //if((i mod 1024)<0) or ((i mod 1024)>1023) then
      //begin
      //  riteln('saJegasEncryptSingleKey - Got illegal MOD!');
      //end;

      au1[i]:=au1[i] xor (au1Pub[i mod 1024]);
    end;

    sa := '';
    h := '';
    for i:=0 to length(au1)-1 do
    begin
      h := sarightStr(sau8ToHex(au1[i]),2);
      //riteln('au1[',i,'] converted from ', au1[i], ' to hex:',h);
      sa := sa + h;
    end;
    setlength(au1,0);
  end;

  if bOk then
  begin
    result:=sa;
  end;

end;
//=============================================================================

//=============================================================================
function u1UnMix(p_u1: byte): byte;
//=============================================================================
var i: integer;
begin
  result:=0;
  for i:=0 to 255 do
  begin
    if au1Mix[i]=p_u1 then
    begin
      result:=i;
      exit;
    end;
  end;
end;
//=============================================================================
//=============================================================================
function saJegasDecryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring): ansistring;
//=============================================================================
var
  i: integer;
  sa: ansistring;
  au1: array of byte;
  au1Pub: array of byte;
  x: integer;
  iDataLen: integer;
  iPubKeyLen: integer;
begin
  iDataLen:=length(p_saData);
  iPubKeyLen:=length(p_saPubKey);
  //riteln('saJegasDecryptSingleKey: '+p_saData);
  sa := '';
  if iDataLen>0 then
  begin
    setlength(au1,iDataLen div 2);
    i:=1;x:=0;
    repeat
      au1[x]:=u8HexToU8(saMid(p_saData, i,2));
      //riteln('DECRYPT: p_saData[',i,']:',saMid(p_saData, i,2),' Converted to au1[',x,']: ' ,au1[x]);
      i:=i+2;
      x:=x+1;
    until i >= iDataLen;

    setlength(au1Pub,iPubKeyLen div 2);
    i:=1;
    x:=0;
    repeat
      if i=1 then
      begin
        //riteln;
        //riteln('pubkey:'+saMid(p_saPubKey,i,2));
        //riteln;
      end;
      au1Pub[x]:=u8HexTou8(saMid(p_saPubKey,i,2));
      i:=i+2;
      x:=x+1;
    until i >= iPubKeyLen;

    for i:=0 to length(au1)-1 do
    begin
      au1[i]:=au1[i] xor (au1Pub[i mod 1024]);
      if((i mod 1024)<0) or ((i mod 1024)>1023) then
      begin
        //riteln('saJegasDecryptSingleKey - Got illegal MOD!');
      end;
    end;

    for i:=0 to length(au1)-1 do
    begin
      //riteln('DECRYPT: au1[',i,'] Unmixed from ',au1[i], ' to ' ,u1UnMix(au1[i]),' then char: ',char(u1UnMix(au1[i])));
      au1[i]:=u1UnMix(au1[i]);
      sa:=sa+char(au1[i]);
    end;
    setlength(au1,0);

    if saLeftStr(sa,10)='JCRYPTPAD[' then
    begin
      sa:=saRightStr(sa,length(sa)-10);
      i:=pos(']',sa);
      x:=iVal(saLeftStr(sa,i-1));
      sa:=saRightStr(sa,length(sa)-i);
      sa:=saLeftstr(sa,length(sa)-x);
    end;
  end;
  result:=sa;
end;
//=============================================================================


//=============================================================================
function bJCryptIsValidRegKey(
  p_saName: ansistring;
  p_saEmail: ansistring;
  p_saRegKey: ansistring;
  p_saCrypt: ansistring;
  p_saMix: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  TK: JFC_TOKENIZER;
  saTempName: ansistring;
  saTempEmail: ansistring;
begin
  bOk:=false;
  //saJegasDecryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring): ansistring;
  JCryptMix(p_saMix);
  sa:=saJegasDecryptSingleKey(p_saRegKey, p_saCrypt);
  //showmessage('saJegasDecryptSingleKey:'+sa);
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=#13+#10;
  TK.saWhiteSpace:=#13+#10;
  TK.bKeepDebugInfo:=false;
  TK.Tokenize(sa);
  //TK.DumpToTextFile('tk.txt');
  if tk.MoveFirst then
  begin
    saTempName:=trim(tk.Item_saToken);
    if tk.movenext then
    begin
      saTempEmail:=trim(tk.Item_saToken);
    end;
  end;
  bOk:=(saTempName=trim(p_saName)) and (saTempEmail=trim(p_saEmail)) and (length(p_saName)>0) and (length(p_saEmail)>0);
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
function bJCryptIsRegistered(
  p_saName: ansistring;
  p_saEmail: ansistring;
  p_saRegKey: ansistring;
  p_saCrypt: ansistring;
  p_saMix: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  TK: JFC_TOKENIZER;
  saTempName: ansistring;
  saTempEmail: ansistring;
  saREGISTERED: ansistring;
begin
  bOk:=false;
  //saJegasDecryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring): ansistring;
  JCryptMix(p_saMix);
  sa:=saJegasDecryptSingleKey(p_saRegKey, p_saCrypt);
  //showmessage('saJegasDecryptSingleKey:'+sa);
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=#13+#10;
  TK.saWhiteSpace:=#13+#10;
  TK.bKeepDebugInfo:=false;
  TK.Tokenize(sa);
  //TK.DumpToTextFile('tk.txt');
  if tk.MoveFirst then
  begin
    saTempName:=trim(tk.Item_saToken);
    if tk.movenext then
    begin
      saTempEmail:=trim(tk.Item_saToken);
      if tk.movenext then
      begin
        saREGISTERED:=trim(tk.Item_saToken);
      end;
    end;
  end;
  bOk:=(saTempName=trim(p_saName)) and (saTempEmail=trim(p_saEmail)) and
    (saREGISTERED='J1E2G3A4S5') and (length(p_saName)>0) and (length(p_saEmail)>0);
  TK.Destroy;
  result:=bOk;
end;
//=============================================================================









//=============================================================================
// Initialization
//=============================================================================
procedure JCryptMix(p_saMix: ansistring);
var
  i: longint;
  x: longint;
  iDataLen: integer;
begin
  iDataLen:=length(p_saMix);
  setlength(au1Mix,iDataLen div 2);
  i:=1;
  x:=0;
  repeat
    au1Mix[x]:=u8HexTou8(saMid(p_saMix,i,2));
    i:=i+2;
    x:=x+1;
  until i >= iDataLen;
  pvt_saJCryptMix:=p_saMix;
end;
Begin
  JCryptMix(
         'E5210B679D2E197C7EA1C63BBF4A1068478291234DDE120498F263A2EA628FC7'+
         '948CEE6AB46B1722726113F55E5DF009387A4F7399A90565800CD99CFAE64897'+
         '02E7584CF6A67D8EAAB852CBE22FC87F1EAE1D8D14762495BB2BDC3FFB33C23A'+
         '311684865FB51CFED239D0A0E13CF1E9CA9EBD1AD45AF43E9F88205B56379BA8'+
         '03497BFDD3326C3D7807B1892D594E35D1B3646DD7EC0E8B53B6776F87931FB7'+
         '51DAD80D6ECF4B42F35C697485C430B9E828A3256643907181EFEB2CD6402A0A'+
         'FF79D596018AC100CDDD55BAF941F81554349A834650BC27ADFCCCC5A7F7A41B'+
         'EDDF450844AB92E4267506E370E0C311A529C00FC9B2BE6036DB18B0AFACCE57'
  );
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
