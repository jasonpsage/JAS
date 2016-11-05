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
// Single Key Encryption - not verified just scrambled
function saJegasEncryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring; p_u2PadLength: word): ansistring;
//=============================================================================
{}
// Single Key Encryption
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
// use saXORString in ug_common.pp
//function saXor(p_s: ansistring; p_u1Mix: byte):ansistring;
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


//=============================================================================
//function saXor(p_s: ansistring; p_u1Mix: byte):ansistring;
//=============================================================================
//var u:uint;
//begin
//  result:='';
//  if length(p_s)>0 then
//  begin
//    for u:=1 to length(p_s) do result+=char(ord(p_s[u]) xor p_u1Mix);
//  end;
//end;
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
  u1: byte;
  u2:word;
  asu1: array [0..255] of byte;
  u1Swap1: byte;
  u1Swap2: byte;
begin
  sa:='';
  randomize;
  for u1:=0 to 255 do
  begin
    asu1[u1]:=u1;
    sa+=sByteToHex(u1);
  end;
  p_NVP.saName:=sa;

  sa:='';
  for u2:=0 to 65535 do
  begin
    u1Swap1:=random(256);
    u1Swap2:=random(256);
    if u1Swap1<>u1Swap2 then
    begin
      u1Swap1:=asu1[u1Swap1];
      u1Swap2:=asu1[u1Swap2];
      asu1[u1Swap1]:=u1Swap2;
      asu1[u1Swap2]:=u1Swap1;
    end;
  end;

  sa:='';
  for u1:=0 to 255 do
  begin
    sa+=sByteToHex(asu1[u1]);
  end;
  p_NVP.saValue:=sa;
end;


//=============================================================================
function saKeyGen: ansistring;
var
  sa: ansistring;
  u2: word;
begin
  sa:='';
  for u2:=1 to 512 do
  begin
    sa+=sByteToHex(random(256));
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
function saJegasEncryptSingleKey(p_saData: ansistring; p_saPubKey: ansistring; p_u2PadLength: word): ansistring;
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  u2Pad: word;
  u2MustAdd: word;
  saPadCode: ansistring;
  up,ui,ux: uint;
  au1: array of byte;
  au1Pub: array of byte;

  h: ansistring;

  uDataLen: uint;
  uPubKeyLen: uint;
begin
  result:='ERROR - JCRYPT';
  uDataLen:=length(p_saData);
  uPubKeyLen:=length(p_saPubKey);
  saPadCode:='';
  u2Pad:=0;
//asprintln('jegasencryptsinglekey - 1');
  bOk:=(uPubKeyLen=1024);//public key
  if bOk then
  begin
//asprintln('jegasencryptsinglekey - 2');
    if p_u2PadLength>0 then
    begin
      //asprintln('jegasencryptsinglekey - 3');
      if (uDataLen=0) then u2Pad:=p_u2PadLength else
      begin
      //asprintln('jegasencryptsinglekey - 3-1');
        try
      //asprintln('jegasencryptsinglekey - 3-2');
          u2Pad:=length(p_saData) mod p_u2PadLength;
      //asprintln('jegasencryptsinglekey - 3-3');
        except on E:Exception do;
        end;//try
      end;
      //asprintln('jegasencryptsinglekey - 3-4');
      if (u2Pad>0) then
      begin
      //asprintln('jegasencryptsinglekey - 3-5');
        u2MustAdd := p_u2PadLength - u2Pad;
      //asprintln('jegasencryptsinglekey - 3-6');
        writeln('u2MustAdd:',u2MustAdd);
        saPadCode := 'JCRYPTPAD['+inttostr(u2MustAdd)+']';
      //asprintln('jegasencryptsinglekey - 3-7');
        if u2MustAdd>0 then
        begin
          for up:=0 to (u2MustAdd-1) do
          begin
            p_saData := p_saData + char(random(26)+65);
          end;
      //asprintln('jegasencryptsinglekey - 3-8');
        end;
        p_saData := saPadCode + p_saData;
      end;
    end;
    uDataLen:=length(p_saData);

//asprintln('jegasencryptsinglekey - 4');
    if length(p_saData)>0 then
    begin
      //asprintln('jegasencryptsinglekey - 5');
      setlength(au1,uDataLen);
      ui:=1;
      repeat
        au1[ui-1]:=byte(p_saData[ui]);
        //riteln('p_saData[',ui,']:'+p_saData[ui],' converted to byte:',au1[ui-1]);
        ui+=1;
      until ui > uDataLen;

//asprintln('jegasencryptsinglekey - 6');
      for ui:=0 to length(au1)-1 do
      begin
        //riteln('au1[',ui,'] mixed from ',au1[ui], ' to ' ,au1Mix[au1[ui]]);
        au1[ui]:=au1Mix[au1[ui]];
      end;

//asprintln('jegasencryptsinglekey - 7');
      setlength(au1Pub,uPubKeyLen div 2);
      ui:=1;
      ux:=0;
      repeat
        if ui=1 then
        begin
          //riteln;
          //riteln('pubkey:'+saMid(p_saPubKey,ui,2));
          //riteln;
        end;
        au1Pub[ux]:=u8HexTou8(saMid(p_saPubKey,ui,2));
        if ui=1 then
        begin
          //riteln('au1Pub[x]:',au1Pub[x]);
        end;
        ui:=ui+2;
        ux:=ux+1;
      until ui > uPubKeyLen;

//asprintln('jegasencryptsinglekey - 8');
      for ui:=0 to length(au1)-1 do
      begin
        //riteln('mod: ',ui mod 1024, ' ',au1Pub[ui mod 1024]);

        //if((ui mod 1024)<0) or ((ui mod 1024)>1023) then
        //begin
        //  riteln('saJegasEncryptSingleKey - Got illegal MOD!');
        //end;

        au1[ui]:=au1[ui] xor (au1Pub[ui mod 1024]);
      end;

//asprintln('jegasencryptsinglekey - 9');
      sa := '';
      h := '';
      for ui:=0 to length(au1)-1 do
      begin
        h := sarightStr(su8ToHex(au1[ui]),2);
        //riteln('au1[',i,'] converted from ', au1[i], ' to hex:',h);
        sa := sa + h;
      end;
      setlength(au1,0);
    end;
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
var u1: byte;
begin
  result:=0;
  for u1:=0 to 255 do
  begin
    if au1Mix[u1]=p_u1 then
    begin
      result:=u1;
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
      //if i=1 then
      //begin
      //  writeln;
      //  writeln('pubkey:'+saMid(p_saPubKey,i,2));
      //  writeln;
      //end;
      au1Pub[x]:=u8HexTou8(saMid(p_saPubKey,i,2));
      i:=i+2;
      x:=x+1;
    until i >= iPubKeyLen;

    for i:=0 to length(au1)-1 do
    begin
      au1[i]:=au1[i] xor (au1Pub[i mod 1024]);
      //if((i mod 1024)<0) or ((i mod 1024)>1023) then
      //begin
      //  writeln('saJegasDecryptSingleKey - Got illegal MOD!');
      //end;
    end;

    for i:=0 to length(au1)-1 do
    begin
      //writeln('DECRYPT: au1[',i,'] Unmixed from ',au1[i], ' to ' ,u1UnMix(au1[i]),' then char: ',char(u1UnMix(au1[i])));
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
  TK.sSeparators:=#13+#10;
  TK.sWhiteSpace:=#13+#10;
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
  TK.sSeparators:=#13+#10;
  TK.sWhiteSpace:=#13+#10;
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
