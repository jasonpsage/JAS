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
// Test Jegas' JCrypt Unit
program test_ug_jcrypt;
//=============================================================================

//=============================================================================
// GLOBAL Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  ug_common,
  ug_jcrypt;
//=============================================================================





//=============================================================================
function bTest_JegasCrypt: boolean;
//=============================================================================
var
  NVP: rtNameValuePair;
  bOK: boolean;
begin
  JegasCrypt(NVP);
  writeln('PUBLIC KEY');
  writeln(saRepeatChar('=',79));
  writeln(NVP.saName);
  writeln(saRepeatChar('=',79));
  writeln;
  writeln('PRIVATE KEY');
  writeln(saRepeatChar('=',79));
  writeln(NVP.saName);
  writeln(saRepeatChar('=',79));
  bOk:=length(NVP.saName)>0;
  if not bOk then
  begin
    writeln('jegascrypt - public key came back zero length');
  end;

  if bOk then
  begin
    bOk:=length(NVP.saValue)>0;
    if not bOk then
    begin
      writeln('jegascrypt - private key came back zero length');
    end;
  end;

  if bOk then
  begin
    bOk:=length(NVP.saName)=length(NVP.saValue);
    if not bOk then
    begin
      writeln('jegascrypt - public and private keys have different stringlengths: ',length(NVP.saName),' and ',length(NVP.saValue));
    end;
  end;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
function bTest_JCryptMixer: boolean;
//=============================================================================
var NVP: rtNameValuePair;
begin
  // The Mixer returns two long strings. The First is redundant admittedly at
  // this point. This routine scrambles the order of 256 bytes in an array
  // 65536 times then returns the p_NVP.saName (the redundant bit) as a series
  // of hex values from 00 thru FF. The mixed up stuff comes back in
  // p_NVP.saValue. This is to be used to generate a constant that is used in
  // code that needs to encrypt and decrypt data using JCrypt.
  //riteln;
  //riteln('JCryptMixer - BEFORE');
  //riteln('NVP.saName : ');
  //riteln(NVP.saName);
  //riteln('NVP.saValue: ');
  //riteln(NVP.saValue);
  //riteln;
  JCryptMixer(NVP);
  //riteln('JCryptMixer - AFTER');
  //riteln('NVP.saName : ');
  //riteln(NVP.saName);
  //riteln('NVP.saValue: ');
  //riteln(NVP.saValue);

  result:=NVP.saName <> NVP.saValue;
end;
//=============================================================================




//=============================================================================
function bTest_SingleKeySystem: boolean;
//=============================================================================
var saKey: ansistring;
    saEncrypted: ansistring;
    saEncryptThis: ansistring;
    saDecrypted: ansistring;
begin
  //riteln('bTest_SingleKeySystem');
  saKey:=saKeyGen;// make a KEY
  saEncryptThis:='Something to Encrypt.';
  saEncrypted:=saJegasEncryptSingleKey(saEncryptThis, saKey,256);
  saDecrypted:=saJegasDecryptSingleKey(saEncrypted,saKey);
  //riteln('saKey:');
  //riteln(saKey);
  //riteln;

  //riteln('saEncrypt This:',saEncryptThis);
  //riteln;

  //riteln('saEncrypted:');
  //riteln(saEncrypted);
  //riteln;

  //riteln('saDecrypted:');
  //riteln(saDecrypted);
  //riteln;

  Result:=saEncryptThis=saDecrypted;
end;



//---- the following not written into this test program yet.

{}
// USE AFTER SETTING saJCrypt
//procedure JCryptMix(p_saMix: ansistring);
//=============================================================================
{}
//function saJCryptMix: ansistring;
//=============================================================================
{}
//function bJCryptIsRegistered(
//  p_saName: ansistring;
//  p_saEmail: ansistring;
//  p_saRegKey: ansistring;
//  p_saCrypt: ansistring;
//  p_saMix: ansistring
//): boolean;
//=============================================================================
{}
//function bJCryptIsValidRegKey(
//  p_saName: ansistring;
//  p_saEmail: ansistring;
//  p_saRegKey: ansistring;
//  p_saCrypt: ansistring;
//  p_saMix: ansistring
//): boolean;
//=============================================================================






//=============================================================================
// main
//=============================================================================
var bGood : boolean;
begin
  bGood:=bTest_JegasCrypt;
  if not bGood then
  begin
    writeln('bTest_JegasCrypt FAILED');
  end;

  if bGood then
  begin
    bGood:=bTest_JCryptMixer;
    if not bGood then
    begin
      writeln('bTest_JCryptMixer FAILED!');
    end;
  end;

  if bGood then
  begin
    bGood:=bTest_SingleKeySystem;
    if not bGood then
    begin
      writeln('bTest_SingleKeySystem FAILED!');
    end;
  end;

  if bGood then writeln('Tests All Passed!');

end.
//=============================================================================




//-=-=-=-=-=-=-=-=-=-== OLD BELOW =-=-=-=-=-=-=-=-=-=-=-=-=-=













//Procedure ParseName(
//  p_In_saName: ansistring;
//  var p_Out_saFirst: ansistring; 
//  var p_Out_saMiddle: ansistring;
//  var p_Out_saLast: ansistring
//);

//=============================================================================
//var
//=============================================================================
//  NVP: rtNameValuePair;
//  sa: ansistring;
//=============================================================================


//=============================================================================
//begin
//=============================================================================
  //writeln('---Key 1-------------');
  //writeln(saKeyGen);
  //writeln('---Key 2-------------');
  //writeln(saKeyGen);
  //writeln;

  //JCryptMixer(NVP);
  //writeln(NVP.saName);
  //writeln;
  //writeln(NVP.saValue);
  //writeln;


  //JegasCrypt(NVP);

  {writeln;
  writeln('PUB:');
  writeln(NVP.saName);
  writeln;

  writeln('PVT:');
  writeln(NVP.saValue);
  writeln;

  writeln(u8HexToU8('FFFF'));
  writeln(saU8ToHex(65535));
  }

  //935
  //7D528766DDCB75A250E6FDFAF1F78E579E02D3D0BADBE2FB12F366ACA6F6BEBAD749E0022F8EAAA0271A69BE1320EAC435A07AB63FA0129E43996E6B4CD022B9E92A7F684377AFA3FA849616E57686D108726CAFC047ED9EA34010D15730D77E0D5775D7B05A9D55208F5E5B6C9707D518D78DD20EF35D8F047B57247C44BF25FFC850F805997C07E0A0C1C0B69192FE3140968431173CD6A6C3C604391932DCF6EEA23963C5D98D1A9A2260B1FF2A8A75365F4B5B7D878F4B2459139C327E1D3A63072AA2429EA97A9B014D77E1A1EBE6D274F8D3EBA416BE84E060178AE66DEDCEAD37182608659AF15376C8BC38F90EE151150B8823FBF7D94632FED2C7B1864B31BC911383A13F7C4550BDB8B79B070DF1389D3356D558A85D722F9D36BDC06317BF83EEA5882E0A24A4B4608BA3EAB779A616F90491540532D188DE0D18812C446846976335180857655FFC3E3C25BDC064CB5A30ACDA1BB2DD615A5F36B374E1D13D8ACD94C977127FF99727872D0F62DFF65D0C7DB54918785E853F2BA3001BEB0C4931C7024F7B4B25EC3414200577C2B0842319A1C669F70E902F8AB3DAF7CF2F8E8FEC03A924CC4F9CC35403CE2BA8F0CE9B3928F7EA382DA07194841882A8A34412ECBC11C33FE97567832F370B17816631902A502032555CF57D16CBCE918DF82126FF980E8A2FC8F42EA53402690A1748C196DB86D76953154D
  //NVP.saName:='7D528766DDCB75A250E6FDFAF1F78E579E02D3D0BADBE2FB12F366ACA6F6BEBAD749E0022F8'+
  //            'EAAA0271A69BE1320EAC435A07AB63FA0129E43996E6B4CD022B9E92A7F684377AFA3FA8496'+
  //            '16E57686D108726CAFC047ED9EA34010D15730D77E0D5775D7B05A9D55208F5E5B6C9707D51'+
  //            '8D78DD20EF35D8F047B57247C44BF25FFC850F805997C07E0A0C1C0B69192FE314096843117'+
  //            '3CD6A6C3C604391932DCF6EEA23963C5D98D1A9A2260B1FF2A8A75365F4B5B7D878F4B24591'+
  //            '39C327E1D3A63072AA2429EA97A9B014D77E1A1EBE6D274F8D3EBA416BE84E060178AE66DED'+
  //            'CEAD37182608659AF15376C8BC38F90EE151150B8823FBF7D94632FED2C7B1864B31BC91138'+
  //            '3A13F7C4550BDB8B79B070DF1389D3356D558A85D722F9D36BDC06317BF83EEA5882E0A24A4'+
  //            'B4608BA3EAB779A616F90491540532D188DE0D18812C446846976335180857655FFC3E3C25B'+
  //            'DC064CB5A30ACDA1BB2DD615A5F36B374E1D13D8ACD94C977127FF99727872D0F62DFF65D0C'+
  //            '7DB54918785E853F2BA3001BEB0C4931C7024F7B4B25EC3414200577C2B0842319A1C669F70'+
  //            'E902F8AB3DAF7CF2F8E8FEC03A924CC4F9CC35403CE2BA8F0CE9B3928F7EA382DA071948418'+
  //            '82A8A34412ECBC11C33FE97567832F370B17816631902A502032555CF57D16CBCE918DF8212'+
  //            '6FF980E8A2FC8F42EA53402690A1748C196DB86D76953154D';

  // 654
//  NVP.saName:=  '4759B5CE50FD5B1E79D561EB3B961DEB8266D0B79D53FC852CCBBC351B11EEFA29AEF0FA902'+
//                '2AF9204BCEA3EC7D8F9F6D994C955F84A83CDB57C7E5BB3D433D02B2D400E7A1DC117C5205D'+
//                '637AC1A70C1332953E93F370CFEC9569FB567367C03E1C2CF4622A9FB459C541853422A747E'+
//                'D5B6158ABE64176A719861ED7FBB5E96B3042A24FEDE023027617433511BB86FB57710E3251'+
//                '5AFC8758E3E106397B655374B6B264061533848C258484FE6CB4861CC2FABEC839E21A5DABB'+
//                '1DF734FA159E37C57262B3ED0928968891012AF9E537C06826043CB5C96CEFF3B0EDEEDB5F6'+
//                '99F3EA2E3949EF8F9A829A24AA07BFCA5FC1D4973ECBDD232504092918D7C3CD8E9231603CD'+
//                '56EF312EB1AB527DA7C7332947435140D888C5E419EBF27F0ED19490E49CABDD3B423B44757'+
//                '99283EC6CA8E3D827DEFC4299C0E75A697DD85DFF15CEDD538015D6499A3058F57F7A5310AF'+
//                '984789744CC967B9386163B4A760BCD067F27F06913F9281E8432E01A8036B56F7A6674CC82'+
//                'F9410ADAB74ED972149D88A7836CA8905C6B40477B868718528CF5719B17BD30CA689CB9C03'+
//                '235C648CE53B4858F933A99E6404AEB91CC70B68F085BFF7EF663D3A10411D60655BB596826'+
 //               'DF5BC8A615AE58F1030BA1EC23A4F329A2137D3B8007DF5372B2001922B40A6E35BF0E6C1CD'+
  //              '6DE288FC9D6DACB2D14B9196DFB1BEDEAB021415A96FB99E8';


  //writeln('Length of saJCryptMix:',length(saJCryptMix));

  //sa:=saJegasEncryptSingleKey('testuser3', NVP.saName,128);
  //writeln('Encrypted:'+sa);
  //writeln;

  //sa:=saJegasDeCryptSingleKey(sa, NVP.saName);
  //writeln('Decrypted:'+sa);
  //writeln;


  //sa:='1515a8e54ee945f98fea1bd3bba5cdfd988f217d874502302e1b09cb0d0b1e7cc092e4b6c87a84648912'+
  //    'e8abe3aefb007f5cddf356dfac43137ec5e3a7a28876735be6218cd523bdc79b221c364fba0e9e2f8166'+
  //    '1d5992b0c3be3b5179d9797bb3a460823a3782a07ddb6a732a366c68ef17da2e0d9089f8409'+
  //    '7cad685a97e9633461a454df9fd3d1f2e9a5793f3';
  //sa:=saJegasDeCryptSingleKey(sa, NVP.saName);
  //writeln('Decrypted:'+sa);
  //writeln;

//  NVP.saName:='2D51888A27BE7A8B1A2F3E5942F183B24CB7E88AC58AFB6575CCC403AFD5F5A5'+
//              '38C864FD6037F4323E86B801114CC58CF07134F0DD784FA223085D365BB58792'+
//              'E639936303C63092FA7D7A3A4AECD48FE9CA91BAABEF7679E301366DABCC7687'+
//              'C52E551CB0B9AE39377D85F14754C30CFF350B41A7ED5913207C922A83AFD115'+
//              'CBD5910DBBB220E5B49455093F6C8EAE8738D6DD69889D7762C350D765BECE86'+
//              '75860AB81EE82C119521FE2CB0B8AF5B34DF95E88FAE95B426689D1D845B6C50'+
//              'CAA7405F5ED8DEAAD2F936C2116F711A84721855847FE75242374ADA5197B5D2'+
//              '45820599498EC9F67B5120C875980646C7C6987926EB5930EEACD821F8C1E6A7'+
//              '022CC6B9C7A9C8DF972A1A269682EB33D37578A5352C8F5B3E11AA36EAA80057'+
//              'DA627226F059A1B5717E8D0C36FE3AF4A3AF5386C2428B459C15BA7EC4884AAC'+
//              'B135C28D17FF07C42A2D3855D9F70435D2AF2E5914986D3CC5533B204A53F24E'+
//              'A50A9790A99401C1CC49007A42C34411812CF12DC21CCFB4ED29EEB8F6C34358'+
//              'C0EFAEB260E18234E0D90C0FA7D6B441EA34C7D4FD7E506E9F44B31239F2323D'+
//              '2FABC34C773F573F8CC3B344CC362270B34F4F5256DB17C515E50DA832116EDC'+
//              '3AAB64707E09643713F3CFB1E51632545C1123F4E85101EFC4C70B27EED7C6C8'+
//              'A8F8996C59D892C04858420A0E10B467D9CC5E1A308DBB19AB553AC4BEB3BAA9';
//  sa:=saJegasDecryptSingleKey('571E6D',NVP.saName);
//  writeln('Decrypted:'+sa);
//=============================================================================
//end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

