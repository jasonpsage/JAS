unit pasagi;

{* ----------------------------------------------------------------------------
Pascal AGI Wrapper for Asterisk.  This unit contains class TPasAGI which
communicates with Asterisk PBX through AGI/FastAGI.

Copyright (c) 2007 R. Lee Jenkins

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Contact the author: lee(dot)jenkins(at)datatrakpos.com

This units was inspired by and based on MONO-TONE C# class by Gabriel Gunderson @
http://gundy.org/asterisk/

Note: The only correction that I could find to Gabriel's work was to use
Lazarus/Freepascal instead of .net ;)

------------------------------------------------------------------------------*}
{$mode delphi}{$H+}

interface

uses
  {$IFDEF UNIX}cthreads,
  {$ENDIF}
  Classes, SysUtils, blcksock, synsock;

{* ---------------------------------
 Exception Classes
-----------------------------------*}
{** EPasAGIBadAsteriskVersion **}
Type
   EPasAGIBadAsteriskVersion = class(Exception);
{** EPasAGIBadAGIType **}
type
   EPasAGIBadAGIType = class(Exception);
{** EPasAGIBadAstReturnValue **}
type
   EPasAGIBadAstReturnValue = class(Exception);

{* ---------------------------------
 Class Definition for TPasAGI and related enums
-----------------------------------*}

{** TDialPadKey Type **}
type TDialPadKey = (dkZero, dkOne, dkTwo, dkThree, dkFour, dkFive, dkSix, dkSeven,
   dkEight, dkNine, dkStar, dkPound, dkNone, dkUnknown, dkNotSet);

{** TChannelStatus **}
type TChannelStatus = (csDownAvailable, csDownReserved, csOffHook, csDigitsDialed,
   csLineRinging, csRemoteEndRinging, csLineUp, csLineBusy, csFailed);

{** TAGIType **}
type TAGIType = (atAGI, atFastAGI);

{** TPasAGI Object **}
type

{ TPasAGI }
TPasAGI = class(TObject)
   private
   {* ---------------------------------
    Variables - Private
   -----------------------------------*}
   FHandler: TThread;
   BlockSocket: TTCPBlockSocket;
   FAGIType: TAGIType;
   FSocketTimeout: integer;
   FSuccessful: Boolean;
   FTempTimeout: integer;
   Sock: TSocket;
   FAccountCode: string;
   FAGINetwork: string;
   FAGINetworkScript: string;
   FAstVersion: string;
   FCallerID: string;
   FCallerIDName: string;
   FCallingANI2: string;
   FCallingPres: string;
   FCallingTNS: string;
   FCallingTON: string;
   FChannel: string;
   FChannelType: string;
   FCONTEXT: string;
   FDebug: boolean;
   FDNID: string;
   FEnhanced: string;
   FEXTENSION: string;
   FLanguage: string;
   FPriority: integer;
   FRDNIS: string;
   FRequest: string;
   FUniqueID: string;
   FUserVarList: TStringList;

   {* ---------------------------------
    Methods - Private
   -----------------------------------*}
   {** Initializes variables sent from Asterisk over Fast AGI **}
   procedure InitVarsFromSocket;
   {** Initializes variable sent from Asterisk over StdIn **}
   procedure InitVarsFromStdIn;
   {** Processes a single initial variable sent from asterisk Over stdin/stdout or Socket **}
   function ProcessInitVariable(AVar: string): boolean;
   {** Processes agi_network_script var sent by Asterisk and parses any params sent (Asterisk 1.2) **}
   procedure ProcessNetworkAGIScript(url: string);
   procedure SetSocketTimeout(const AValue: integer);
   procedure SetSuccessful(const AValue: Boolean);
   {** These functions deal with AGI command return values to boolean type **}
   function ZeroNegOneToBool(AValue: string): boolean;
   Function OneNegOneToBool(AValue: string): boolean;
   Function OneZeroToBool(AValue: string): Boolean;
   Function ExtractAGIResponse(AValue: string): string;
   {** Extract result from Parenthesis **}
   Function ExtractFromParens(AValue: string): string;
   {** Tests if a value is numeric **}
   Function IsNumeric(AValue: string): boolean;

   procedure SetAccountCode(const AValue: string);
   procedure SetAGINetwork(const AValue: string);
   procedure SetAGINetworkScript(const AValue: string);
   procedure SetAGIType(const AValue: TAGIType);
   procedure SetAstVersion(const AValue: string);
   procedure SetCallerID(const AValue: string);
   procedure SetCallerIDName(const AValue: string);
   procedure SetCallingANI2(const AValue: string);
   procedure SetCallingPres(const AValue: string);
   procedure SetCallingTNS(const AValue: string);
   procedure SetCallingTON(const AValue: string);
   procedure SetChannel(const AValue: string);
   procedure SetChannelType(const AValue: string);
   procedure SetCONTEXT(const AValue: string);
   procedure SetDebug(const AValue: boolean);
   procedure SetDNID(const AValue: string);
   procedure SetEnhanced(const AValue: string);
   procedure SetEXTENSION(const AValue: string);
   procedure SetLanguage(const AValue: string);
   procedure SetPriority(const AValue: integer);
   procedure SetRDNIS(const AValue: string);
   procedure SetRequest(const AValue: string);
   procedure SetUniqueID(const AValue: string);

   public
   {* ---------------------------------
    Constructors/Destructors
   -----------------------------------*}
//   constructor Create;
   constructor Create(AVersion: string; ASock: TSocket; var AThread: TThread);
   destructor Destroy; override;

   {* ---------------------------------
    Properties - Public
   -----------------------------------*}
   property Request: string read FRequest write SetRequest;
   property Channel: string read FChannel write SetChannel;
   property Language: string read FLanguage write SetLanguage;
   property ChannelType: string read FChannelType write SetChannelType;
   property UniqueID: string read FUniqueID write SetUniqueID;
   property CallerID: string read FCallerID write SetCallerID;
   property CallerIDName: string read FCallerIDName write SetCallerIDName;
   property CallingPres: string read FCallingPres write SetCallingPres;
   property CallingANI2: string read FCallingANI2 write SetCallingANI2;
   property CallingTON: string read FCallingTON write SetCallingTON;
   property CallingTNS: string read FCallingTNS write SetCallingTNS;
   property DNID: string read FDNID write SetDNID;
   property RDNIS: string read FRDNIS write SetRDNIS;
   property CONTEXT: string read FCONTEXT write SetCONTEXT;
   property EXTENSION: string read FEXTENSION write SetEXTENSION;
   property Priority: integer read FPriority write SetPriority;
   property Enhanced: string read FEnhanced write SetEnhanced;
   property AccountCode: string read FAccountCode write SetAccountCode;
   property Debug: boolean read FDebug write SetDebug;
   property AGINetworkScript: string read FAGINetworkScript write SetAGINetworkScript;
   property AGINetwork: string read FAGINetwork write SetAGINetwork;
   property AstVersion: string read FAstVersion write SetAstVersion;
   property AGIType: TAGIType read FAGIType write SetAGIType;
   Property UserVarList: TStringList read FUserVarList {write SetUserVarList};
   property Successful: Boolean read FSuccessful write SetSuccessful;
   property SocketTimeout: integer read FSocketTimeout write SetSocketTimeout;
   {* ---------------------------------
    Methods - Public
   -----------------------------------*}
   {** Initializes variables sent from Asterisk **}
   Procedure InitVars;
   {** Send Command to Asterisk over correct protocol (stdin/stdout or Socket) **}
   function SendAstCmd(ACmd: string): string;
   {** Sends command to asterisk over stdout and recieves over stdin **}
   function SendCmdViaStdOut(ACmd: string): string;
   {** Sends command to asterisk over socket (Synapse library) **}
   function SendCmdViaSocket(ACmd: string): string;
   {** Converts a string to a TDialpadKey **}
   function StringToDialpadKey(AString: string): TDialpadKey;
   {** Temporarily changes the ScoketTimeout property **}
   procedure SetTempSocketTimeout(ATimeout: integer);
   {** GetProperty **}
   Function GetProp(AName: string): string;
   {** set property  **}
   procedure SetProp(AName, AVAlue: string);
   {** Retrieves Parameters sent to AGI **}
   function  GetAGIParam(AIndex: Integer): string;
   {** Get Count of Parameters sent to AGI **}
   Function  GetParamCount: Integer;
   {** GetsUniqueID **}
   Function  GetUniqueID: string;
   {** AGI Commands - Translate directly to Asterisk AGI commands **}
   Procedure Answer;
   Function  ChannelStatus(AName: string): TChannelStatus;
   procedure DBDelete(AFamily, AKey: string);
   procedure DBDelTree(AFamily, AKeyTree: string);
   function  DBGet(AFamily, AKey: string): string;
   Procedure DBPut(AFamily, AKey, AValue: string);
   Function  ExecCommand(AApplication, AOptions: string): string;
   Function  GetData(AFileName: string; ATimeout, AMaxDigits: Integer): string;
   Function  GetFullVariable(AVarName, AChannelName: string): string;
   function  GetVariable(AName: string): string;
   Procedure Hangup(AChannelName: string);
   procedure NOOP(AValue: string);
   Function  ReceiveChar(ATimeout: Integer): string;
   Procedure RecordFile(AFilename, AFormat, AEscape: String;
      ATimeout, AOffSetSample: integer; ABeep: boolean; ASilence: Integer);
   procedure SayAlpha(AString, Escape: string; var AKey: TDialpadKey);
   Procedure SayDate(ADate, Escape: string; var AKey: TDialpadKey);
   procedure SayTime(ATime, Escape: string; var AKey: TDialpadKey );
   procedure SayDigits(ANumber, Escape: string; var AKey: TDialpadKey);
   procedure SayNumber(ANumber, Escape: string; var AKey: TDialpadkey);
   procedure SayPhonetic(AString, Escape: string; var AKey: TDialpadKey);
   function  SetVariable(AName, AValue: string): string;
   procedure SetAutoHangup(ATimeSecs: integer);
   procedure SetChannelCallerID(ANumber: string);
   procedure SetExitContext(AContext: String);
   procedure SetExitExten(AExten: string);
   procedure SetExitPriority(APriority: string);
   procedure SetExitAll(AContext, AExten, APriority: string);
   procedure SetMusicOn(TurnOn: Boolean; AClass: string);
   procedure StreamFile(AFilename, Escape: string; SampleOffset: integer; var AKey: TDialpadKey);
   procedure Verbose(AMsgLevel: Integer);
   procedure WaitForDigit(ATimeout: Integer; var AKey: TDialpadKey);
   end;


   
   
   
   
   
   
   
   
   
   
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
implementation
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
// ===========================================================================
















{ TPasAGI }

procedure TPasAGI.InitVars;
begin

case FAGIType of
   atAGI       : self.InitVarsFromStdIn;
   atFastAGI   : self.InitVarsFromSocket;
   else
      raise EPasAGIBadAGIType.Create('AGIType Set to Invalid Value');
   end;

end;

procedure TPasAGI.InitVarsFromSocket;
var
sRead: string;
bDone: boolean;
begin


bDone := false;

repeat;
   sRead := BlockSocket.RecvTerminated(FSocketTimeout, Chr(10));
   bDone := self.ProcessInitVariable(sRead);
until (bDone);

end;

procedure TPasAGI.InitVarsFromStdIn;
var
sRead: string;
bDone: boolean;
i: integer;
begin
// init var to false
bDone := false;

// read in environmental variables from asterisk
repeat;
   begin
   ReadLn(sRead);
   bDone := self.ProcessInitVariable(sRead);
   end;
until (bDone);

// add passed in params to internal list
for i := 1 to ParamCount -1 do
   FUserVarList.Add(ParamStr(i));

end;

function TPasAGI.ProcessInitVariable(AVar: string): boolean;
Var
  iColon: integer;
  name, value: string;
Begin

if (aVar = '') or (aVar = #10) then
  begin
  result := true;
  exit;
  end;

// get index of colon ":" character
iColon := POS(':', aVar);
If (iColon <= 0) Then
  Begin
    result := true;
    exit;
  End;

// get name of variable
name := copy(aVar, 1, icolon - 1);
// get value of variable
value := copy(aVar, icolon + 1, 1024);

  // if...then through the value and assigned it to proper property
If (name = 'agi_request') Then Frequest :=  Trim(value)
   Else If (name = 'agi_channel') Then fchannel := Trim(value)
   Else If (name = 'agi_callerid') Then
      FCallerID := Trim(value)
   Else If (name = 'agi_rdnis') Then Frdnis := Trim(value)
   Else If (name = 'agi_context') Then Fcontext := Trim(value)
   Else If (name = 'agi_extension') Then Fextension := Trim(value)
   Else If (name = 'agi_priority') Then Fpriority := StrToInt(Trim(value))
   Else If (name = 'agi_enhanced') Then Fenhanced := Trim(value)
   Else If (name = 'agi_accountcode') Then Faccountcode := Trim(value)
   else if (name = 'agi_calleridname') then FCallerIDName := Trim(value)
   else if (name = 'agi_network_script') then self.ProcessNetworkAGIScript(Trim(value))
   else if (name = 'agi_network') then FAGINetwork := Trim(value)
   else if (POS('agi_arg', name) > 0) then FUserVarList.Add(Trim(value));

   result := false;
end;

procedure TPasAGI.ProcessNetworkAGIScript(url: string);
var
sl: TStringList;
i, iPOS: integer;
begin
{
   Sample of url value:
   /MyScript?param1=val1&param2=val2&param3=val3
}

// "?" indicates presense of parameters attatched to end of string
iPOS := POS('?', url);

// Set script variable from url (/ScriptName)
if (iPOS > 0) then
   FAGINetworkScript := Copy(url, 1, iPOS-1)
else
   FAGINetworkScript := Copy(url, 1, 1024);


// If there are parameters, parse them and place into UserVarList property
If (iPOS > 0) then
   begin
   sl := TStringList.Create;
   try
   // Set delimiters to use for parsing
   sl.Delimiter := '&'; // to separate the param/value pairs first
   sl.DelimitedText := Copy(url, iPOS+1, Length(url) - iPOS);
   if (pos('=', URL) > 0) then
      begin
      sl.Delimiter := '='; // to separate the param from values now
      // apply values to internal list
      for i := 0 to sl.Count - 1 do
         FUserVarList.Add(sl.Values[sl.Names[i]]);
      end
   else
      begin
      for i := 0 to sl.count - 1 do
         FuserVarList.Add(sl.Strings[i]);
      end;
   finally;
      sl.free;
      end;
   end;

end;

procedure TPasAGI.SetSocketTimeout(const AValue: integer);
begin
 if FSocketTimeout=AValue then exit;
 FTempTimeout := AValue;
 FSocketTimeout:=AValue;
end;

procedure TPasAGI.SetSuccessful(const AValue: Boolean);
begin
 if FSuccessful=AValue then exit;
 FSuccessful:=AValue;
end;

procedure TPasAGI.SetAccountCode(const AValue: string);
begin
 if FAccountCode=AValue then exit;
 FAccountCode:=AValue;
end;

procedure TPasAGI.SetAGINetwork(const AValue: string);
begin
 if FAGINetwork=AValue then exit;
 FAGINetwork:=AValue;
end;

procedure TPasAGI.SetAGINetworkScript(const AValue: string);
begin
 if FAGINetworkScript=AValue then exit;
 FAGINetworkScript:=AValue;
end;

procedure TPasAGI.SetAGIType(const AValue: TAGIType);
begin
 if FAGIType=AValue then exit;
 FAGIType:=AValue;
end;

procedure TPasAGI.SetAstVersion(const AValue: string);
begin
 if FAstVersion=AValue then exit;
 if (AValue <> '1.2') AND
    (AValue <> '1.4') then
   raise EPasAGIBadAsteriskVersion.Create('Incorrect Version: ' + AValue);

 FAstVersion:=AValue;
end;

procedure TPasAGI.SetCallerID(const AValue: string);
begin
 if FCallerID=AValue then exit;
 FCallerID:=AValue;
end;

procedure TPasAGI.SetCallerIDName(const AValue: string);
begin
 if FCallerIDName=AValue then exit;
 FCallerIDName:=AValue;
end;

procedure TPasAGI.SetCallingANI2(const AValue: string);
begin
 if FCallingANI2=AValue then exit;
 FCallingANI2:=AValue;
end;

procedure TPasAGI.SetCallingPres(const AValue: string);
begin
 if FCallingPres=AValue then exit;
 FCallingPres:=AValue;
end;

procedure TPasAGI.SetCallingTNS(const AValue: string);
begin
 if FCallingTNS=AValue then exit;
 FCallingTNS:=AValue;
end;

procedure TPasAGI.SetCallingTON(const AValue: string);
begin
 if FCallingTON=AValue then exit;
 FCallingTON:=AValue;
end;

procedure TPasAGI.SetChannel(const AValue: string);
begin
 if FChannel=AValue then exit;
 FChannel:=AValue;
end;

procedure TPasAGI.SetChannelType(const AValue: string);
begin
 if FChannelType=AValue then exit;
 FChannelType:=AValue;
end;

procedure TPasAGI.SetCONTEXT(const AValue: string);
begin
 if FCONTEXT=AValue then exit;
 FCONTEXT:=AValue;
end;

procedure TPasAGI.SetDebug(const AValue: boolean);
begin
 if FDebug=AValue then exit;
 FDebug:=AValue;
end;

procedure TPasAGI.SetDNID(const AValue: string);
begin
 if FDNID=AValue then exit;
 FDNID:=AValue;
end;

procedure TPasAGI.SetEnhanced(const AValue: string);
begin
 if FEnhanced=AValue then exit;
 FEnhanced:=AValue;
end;

procedure TPasAGI.SetEXTENSION(const AValue: string);
begin
 if FEXTENSION=AValue then exit;
 FEXTENSION:=AValue;
end;

procedure TPasAGI.SetLanguage(const AValue: string);
begin
 if FLanguage=AValue then exit;
 FLanguage:=AValue;
end;

procedure TPasAGI.SetPriority(const AValue: integer);
begin
 if FPriority=AValue then exit;
 FPriority:=AValue;
end;

procedure TPasAGI.SetRDNIS(const AValue: string);
begin
 if FRDNIS=AValue then exit;
 FRDNIS:=AValue;
end;

procedure TPasAGI.SetRequest(const AValue: string);
begin
 if FRequest=AValue then exit;
 FRequest:=AValue;
end;

procedure TPasAGI.SetUniqueID(const AValue: string);
begin
 if FUniqueID=AValue then exit;
 FUniqueID:=AValue;
end;



constructor TPasAGI.Create(AVersion: String; ASock: TSocket; var AThread: TThread);
begin
 inherited Create;
 FUserVarList := TStringList.Create;
 FAGIType := atAGI;
 Sock := ASock;
 BlockSocket := TTCPBlockSocket.Create;
 BlockSocket.Socket := self.Sock;
 BlockSocket.GetSins;
 if (Integer(Sock) > 0) then
   begin
   FHandler := AThread;
   FAGIType := atFastAGI
   end
 else
   FAGIType := atAGI;

 Self.SocketTimeout := 5000;
end;


destructor TPasAGI.Destroy;
begin
   // Clean Up
   UserVarList.Free;
   BlockSocket.CloseSocket;
   BlockSocket.Free;
   inherited Destroy;
end;

function TPasAGI.SendAstCmd(ACmd: string): string;
begin

case FAGIType of
   atAGI       : result := self.SendCmdViaStdOut(ACmd);
   atFastAGI   : result := self.SendCmdViaSocket(ACmd);
   else
      raise EPasAGIBadAGIType.Create('AGIType Set to Invalid Value');
   end;
end;

function TPasAGI.SendCmdViaStdOut(ACmd: string): string;
var
F: Text;
sRet: string;
begin
Assign(f,'');
Rewrite(f);
Write(f, aCmd + #10);
flush(f);
ReadLn(sRet);
close(f);
Result := sRet;
end;

function TPasAGI.SendCmdViaSocket(ACmd: string): string;
var
sRet: string;
iTimeout: integer;
begin

// which timeout to use?  TempTimout or normal FSocketTimeout?
if (FTempTimeout <> FSocketTimeout) then
   iTimeout := FTempTimeout
else
   iTimeout := FSocketTimeout;


if (BlockSocket.LastError > 0) then
   begin
   sRet := BlockSocket.LastErrorDesc;
   sRet := IntToStr(BlockSocket.LastError);
   FHandler.Terminate;
   exit;
   end;

BlockSocket.SendString(ACmd + Chr(10));
sRet := BlockSocket.RecvTerminated(iTimeout, Chr(10));

{TODO: Set soft by user}

// Reset
FTemptimeout := FSocketTimeout;

Result := sRet;

end;

function TPasAGI.StringToDialpadKey(AString: string): TDialpadKey;
begin

if (AString = '48') then result := dkZero
   else if ((AString = '49') or (AString = '1')) then result := dkOne
   else if ((AString = '50') or (AString = '2')) then result := dkTwo
   else if ((AString = '51') or (AString = '3')) then result := dkThree
   else if ((AString = '52') or (AString = '4')) then result := dkFour
   else if ((AString = '53') or (AString = '5')) then result := dkFive
   else if ((AString = '54') or (AString = '6')) then result := dkSix
   else if ((AString = '55') or (AString = '7')) then result := dkSeven
   else if ((AString = '56') or (AString = '8')) then result := dkEight
   else if ((AString = '57') or (AString = '9')) then result := dkNine
   else if (AString = '42') then result := dkStar
   else if (AString = '35') then result := dkPound
   else if (AString = '0') then result := dkZero
   else
      result := dkUnknown;
end;

procedure TPasAGI.SetTempSocketTimeout(ATimeout: integer);
begin
if (ATimeout <= 0) then
   FTempTimeout := FSocketTimeout
else
   FTempTimeout := ATimeout;

end;

function TPasAGI.GetProp(AName: string): string;
begin
if (lowercase(AName) = 'request') then
   result := FRequest
else if (lowercase(AName) = 'channel') then
   result := FChannel
else if (lowercase(AName) = 'language') then
   result := FLanguage
else if (lowercase(AName) = 'channeltype') then
   result := FChannelType
else if (lowercase(AName) = 'uniqueid') then
   result := FUniqueID
else if (lowercase(AName) = 'callerid') then
   result := FCallerID
else if (lowercase(AName) = 'calleridname') then
   result := FCallerIDName
else if (lowercase(AName) = 'callingpres') then
   result := FCallingPres
else if (lowercase(AName) = 'callingani2') then
   result := FCallingANI2
else if (lowercase(AName) = 'callington') then
   result := FCallingTON
else if (lowercase(AName) = 'callingtns') then
   result := FCallingTNS
else if (lowercase(AName) = 'dnid') then
   result := FDNID
else if (lowercase(AName) = 'rdnis') then
   result := FRDNIS
else if (lowercase(AName) = 'context') then
   result := FContext
else if (lowercase(AName) = 'extension') then
   result := FExtension
else if (lowercase(AName) = 'priority') then
   result := IntToStr(FPriority)
else if (lowercase(AName) = 'accountcode') then
   result := FAccountCode
else if (lowercase(AName) = 'debug') then
   result := BoolToStr(FDebug)
else if (lowercase(AName) = 'aginetworkscript') then
   result := FAGINetworkScript
else if (lowercase(AName) = 'aginetwork') then
   result := FAGINetwork
else if (lowercase(AName) = 'astversion') then
   result := FAstVersion
else if (lowercase(AName) = 'successful') then
   result := BoolToStr(FSuccessful)
else if (lowercase(AName) = 'sockettimeout') then
   result := IntToStr(FSocketTimeout);




end;

procedure TPasAGI.SetProp(AName, AVAlue: string);
begin
if (lowercase(AName) = 'request') then
   FRequest := AValue
else if (lowercase(AName) = 'channel') then
   FChannel := AValue
else if (lowercase(AName) = 'language') then
   FLanguage := AValue
else if (lowercase(AName) = 'channeltype') then
   FChannelType := AValue
else if (lowercase(AName) = 'uniqueid') then
   FUniqueID := AValue
else if (lowercase(AName) = 'callerid') then
   FCallerID := AValue
else if (lowercase(AName) = 'calleridname') then
   FCallerIDName := AValue
else if (lowercase(AName) = 'callingpres') then
   FCallingPres := AValue
else if (lowercase(AName) = 'callingani2') then
   FCallingANI2 := AValue
else if (lowercase(AName) = 'callington') then
   FCallingTON := AValue
else if (lowercase(AName) = 'callingtns') then
   FCallingTNS := AValue
else if (lowercase(AName) = 'dnid') then
   FDNID := AValue
else if (lowercase(AName) = 'rdnis') then
   FRDNIS := AValue
else if (lowercase(AName) = 'context') then
   FContext  := AValue
else if (lowercase(AName) = 'extension') then
   FExtension := AValue
else if (lowercase(AName) = 'priority') then
   FPriority := StrToInt(AValue)
else if (lowercase(AName) = 'accountcode') then
   FAccountCode := AValue
else if (lowercase(AName) = 'debug') then
   FDebug := StrToBool(AValue)
else if (lowercase(AName) = 'aginetworkscript') then
   FAGINetworkScript := AValue
else if (lowercase(AName) = 'aginetwork') then
   FAGINetwork := AValue
else if (lowercase(AName) = 'astversion') then
   FAstVersion := AValue
else if (lowercase(AName) = 'successful') then
   FSuccessful := StrToBool(AValue)
else if (lowercase(AName) = 'sockettimeout') then
   self.SocketTimeout := StrToInt(AValue);
end;

function TPasAGI.GetAGIParam(AIndex: Integer): string;
begin
if (AIndex > (FUserVarList.Count-1)) then
   begin
   result := '';
   exit;
   end;

result := self.UserVarList[AIndex];

end;

function TPasAGI.GetParamCount: Integer;
begin
 result := fUserVarList.Count;
end;

function TPasAGI.GetUniqueID: string;
begin
if (FUniqueID = '') then
   begin
   FUniqueID := Self.GetVariable('UNIQUEID');
   end;
result := FUniqueID;

end;

procedure TPasAGI.Answer;
var
sRet: string;
begin
sRet := self.SendAstCmd('ANSWER');

// set Successful property
FSuccessful := self.ZeroNegOneToBool(self.ExtractAGIResponse(sRet))
end;

function TPasAGI.ChannelStatus(AName: string): TChannelStatus;
var
sRet: string;
sStatus: string;
iStatus: integer;
begin

sRet := self.SendAstCmd(format('CHANNEL STATUS %s', [AName]));

sStatus := self.ExtractAGIResponse(sRet);
iStatus := StrToInt(sStatus);

Result := TChannelStatus(iStatus);

end;

procedure TPasAGI.DBDelete(AFamily, AKey: string);
var
s, sRet: string;
begin

s := format('DATABASE DEL %s %s', [AFamily, AKey]);
sRet := self.SendAstCmd(s);

FSuccessful := self.OneZeroToBool(sRet);

end;

procedure TPasAGI.DBDelTree(AFamily, AKeyTree: string);
var
s, sRet: string;
begin
s := Trim(format('DATABASE DELTREE %s %s', [AFamily, AKeyTree]));
sRet := self.SendAstCmd(s);

FSuccessful := self.OneZeroToBool(sRet);

end;

function TPasAGI.DBGet(AFamily, AKey: string): string;
var
s, sRet: string;
begin
s := format('DATABASE GET %s %s', [AFamily, AKey]);
sRet := self.SendAstCmd(s);

Result := self.ExtractFromParens(sRet);
FSuccessful := (Result <> '');

end;

procedure TPasAGI.DBPut(AFamily, AKey, AValue: string);
var
s, sRet: string;
begin
s := format('DATABASE PUT %s %s %s', [AFamily, AKey, AValue]);
sRet := self.SendAstCmd(s);

FSuccessful := self.OneZeroToBool(self.ExtractAGIResponse(sRet));

end;

function TPasAGI.ExecCommand(AApplication, AOptions: string): string;
var
s, sRet: string;
begin
s := trim(format('EXEC %s %s', [AApplication, AOptions]));
sRet := self.SendAstCmd(s);
result := self.ExtractAGIResponse(sRet);

FSuccessful := (Result <> '-2');

end;

function TPasAGI.GetData(AFileName: string; ATimeout, AMaxDigits: Integer): string;
var
s, sRet: string;
begin
s := format('GET DATA %s %d %d', [AFileName, ATimeout, AMaxDigits]);
sRet := self.SendAstCmd(s);

FSuccessful := ( (POS('result=-1', sRet) = 0) AND (sRet <> '') );

Result := self.ExtractAGIResponse(sRet);


end;

function TPasAGI.GetFullVariable(AVarName, AChannelName: string): string;
var
s, sRet, sTemp: string;
begin
s := Format('GET FULL VARIABLE %s %s', [AVarName, AChannelName]);
sRet := SendAstCmd(s);
sTemp := self.ExtractAGIResponse(sRet);

if (sTemp = '0') then
   begin
   FSuccessful := false;
   Result := '';
   end
else
   begin
   FSuccessful := true;
   Result := self.ExtractFromParens(sRet);
   end;
end;

function TPasAGI.GetVariable(AName: string): string;
var
s: string;
sRet: string;
//sTemp: string;
begin

s := format('GET VARIABLE %s',[AName]);

// get result and parse it
sRet := self.SendAstCmd(s);
Result := self.ExtractFromParens(sRet);
// set Successful property
FSuccessful := self.OneZeroToBool(self.ExtractAGIResponse(sRet))
end;

procedure TPasAGI.Hangup(AChannelName: string);
var
s, sRet: string;
begin
s := trim(format('HANGUP %s',[AChannelName]));
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '1');


end;

function TPasAGI.SetVariable(AName, AValue: string): string;
var
s: string;
sRet: string;
begin

s := format('SET VARIABLE %s %s', [AName, AValue]);
sRet := self.SendAstCmd(s);
Result := sRet;

// set Successful property
FSuccessful := self.OneZeroToBool(self.ExtractAGIResponse(sRet))

end;

procedure TPasAGI.SetAutoHangup(ATimeSecs: integer);
var
s, sRet: String;
begin
s := format('SET AUTOHANGUP %d',[ATimeSecs]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');

end;

procedure TPasAGI.SetChannelCallerID(ANumber: string);
var
s, sRet: String;
begin
s := format('SET CALLERID %s',[ANumber]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '1');

end;

procedure TPasAGI.SetExitContext(AContext: String);
var
s, sRet: String;
begin
s := format('SET CONTEXT %s',[AContext]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');


end;

procedure TPasAGI.SetExitExten(AExten: string);
var
s, sRet: String;
begin
s := format('SET EXTENSION %s',[AExten]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');


end;

procedure TPasAGI.SetExitPriority(APriority: string);
var
s, sRet: String;
begin
s := format('SET PRIORITY %s',[APriority]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');

end;

procedure TPasAGI.SetExitAll(AContext, AExten, APriority: string);
begin
 self.SetExitContext(AContext);
 self.SetExitExten(AExten);
 self.SetExitPriority(APriority);
end;

procedure TPasAGI.SetMusicOn(TurnOn: Boolean; AClass: string);
var
s, sRet: String;
sTemp: string;
begin
if (turnon) then
   sTemp := 'on'
else
   sTemp := 'off';

s := format('SET MUSIC ON %s %s',[sTemp, AClass]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');

end;

procedure TPasAGI.StreamFile(AFilename, Escape: string; SampleOffset: integer;
 var AKey: TDialpadKey);
var
s, sRet: String;
begin
s := format('STREAM FILE %s %s %d',[AFilename, Escape, SampleOffset]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s = '0');
if (not FSuccessful) then
   if (s <> '-1') then
      AKey := self.StringToDialpadKey(s)
   else
      AKey := dkUnknown;

end;

procedure TPasAGI.Verbose(AMsgLevel: Integer);
var
s, sRet: String;
begin
s := format('VERBOSE %d',[AMsgLevel]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := true;

end;

procedure TPasAGI.WaitForDigit(ATimeout: Integer; var AKey: TDialpadKey);
var
s, sRet: String;
begin
s := format('WAIT FOR DIGIT %d',[ATimeout]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := ((s <> '0') AND (s <> '-1'));
If (FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.NOOP(AValue: string);
var
SendString: string;
begin
SendString := format('NOOP %s',[AValue]);
SendString := Self.SendAstCmd(SendString);
end;

function TPasAGI.ReceiveChar(ATimeout: Integer): string;
var
s, sRet: string;
begin
s := format('RECEIVE CHAR %d',[ATimeout]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
if ((s <> '-1') AND (POS('(',s) = 0)) then
   begin
   Result := s;
   FSuccessful := true;
   end
else
   begin
   Result := '';
   FSuccessful := false;
   end;

end;

procedure TPasAGI.RecordFile(AFilename, AFormat, AEscape: String; ATimeout,
 AOffSetSample: integer; ABeep: boolean; ASilence: Integer);
var
s, sRet: string;
begin
s := format('RECORD FILE %s %s %s %d', [AFilename, AFormat, AEscape,
   ATimeout]);
if (ABeep) then
   s := s +  ' BEEP ';
if (ASilence > 0) then
   s := s + 's=' + IntToStr(ASilence);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := (s <> '-1');

end;

procedure TPasAGI.SayAlpha(AString, Escape: string; var AKey: TDialpadKey);
var
s, sRet: String;
begin

s := format('SAY ALPHA "%s" "%s"',[AString, Escape]);
sRet := self.SendAstCmd(s);
s := self.ExtractAGIResponse(sRet);
FSuccessful := self.ZeroNegOneToBool(s);
if (Not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.SayDate(ADate, Escape: string; var AKey: TDialpadKey);
var
s, sRet: String;
begin

s := format('SAY DATE %s %s',[ADate,Escape]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := self.ZeroNegOneToBool(s);
if (Not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.SayTime(ATime, Escape: string; var AKey: TDialpadKey);
var
s, sRet: String;
begin
s := format('SAY TIME %s %s', [ATime, Escape]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := self.ZeroNegOneToBool(s);
if (Not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.SayDigits(ANumber, Escape: string; var AKey: TDialpadKey);
var
s, sRet: String;
begin
s := format('SAY DIGITS %s %s',[ANumber, Escape]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := self.ZeroNegOneToBool(s);
if (Not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.SayNumber(ANumber, Escape: string; var AKey: TDialpadkey);
var
s, sRet: String;
begin
s := format('SAY NUMBER %s %s',[ANumber, Escape]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := self.ZeroNegOneToBool(s);
if (not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;

procedure TPasAGI.SayPhonetic(AString, Escape: string; var AKey: TDialpadKey);
var
s, sRet: String;
begin
s := format('SAY PHONETIC %s %s',[AString, Escape]);
sRet := self.SendAstCmd(s);

s := self.ExtractAGIResponse(sRet);
FSuccessful := self.OneNegOneToBool(s);
If (not FSuccessful) then
   AKey := self.StringToDialpadKey(s)
else
   AKey := dkUnknown;

end;


function TPasAGI.ZeroNegOneToBool(AValue: string): boolean;
begin
  if (AValue = '0') then
    result := true
  else if (AValue = '-1') then
    result := false
  else if (AValue = '') then
    result := false
  else if (IsNumeric(AValue)) then
    result := false
  else
    raise EPasAGIBadAstReturnValue.Create('ZeroNegOneToBool: unknown value: ' + AValue);
end;

function TPasAGI.OneNegOneToBool(AValue: string): boolean;
begin
  if (AValue = '1') then
    result := true
  else if (AValue = '-1') then
    result := false
  else if (AValue = '') then
    Result := false
  else
    raise EPasAGIBadAstReturnValue.Create('OneNegOneToBool: unknown value: ' + AValue);
end;

function TPasAGI.OneZeroToBool(AValue: string): Boolean;
begin
   if (AValue = '1') then
    result := true
  else if (AValue = '0') then
    result := false
  else if (AValue = '') then
    Result := false
  else
    raise EPasAGIBadAstReturnValue.create('OneZeroToBool: unknown value: ' + AValue);
end;

function TPasAGI.ExtractAGIResponse(AValue: string): string;
var
iPOS, OffSet: Integer;
begin
OffSet := Length('result=');
iPOS := POS('result=', AValue);

if (iPOS <= 0) then
   result := ''
else
   begin
   Result := trim(copy(AValue, iPOS + OffSet, 1024));

   // is there a "(" ???
   iPOS := POS('(', Result);
   if (iPOS > 0) then
      result := Trim(Copy(Result, 1, iPOS - 1));

   end;

end;

function TPasAGI.ExtractFromParens(AValue: string): string;
var
iPOS: integer;
sTemp: string;
begin
iPOS := POS('(', AValue);
sTemp := copy(AValue, iPOS + 1, 1024);
iPOS := POS(')', sTemp);
sTemp := copy(stemp, 1, iPOS - 1);
// return result
Result := sTemp;
end;

function TPasAGI.IsNumeric(AValue: string): boolean;
var
i: integer;
begin
try
i := StrToInt(AValue);
Result := true;
except on e: exception do
   begin
   result := false;
   end;
   end;
end;

end.

