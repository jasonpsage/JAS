program testagi;
{$INCLUDE i_jegas_macros.pp}
{$mode objfpc}
uses
  cthreads
 ,classes
 ,pasagi
 ,ug_jfc_xdl
 ,sysutils
 ,ug_common
 ,synsock
 ,ug_jegas;
 

type TTestAGI = class(TThread)
public 
  var
    AGI: TPasAGI;
    Sock: TSocket;
    DialPadKey:  TDialPadKey;    
  public
    constructor create;
    destructor destroy; override;
end;

//=============================================================================

constructor TTestAGI.create;
var bOK: Boolean;
begin
  inherited;
  AGI:=nil;
  Sock:=0;
  bOk:=true;

  if not bOk then 
  begin
    writeln('You dun Fupped Up');
  end;
  
  if bOk then
  begin
    AGI:=TPasAGI.Create('13',sock,TTHread(self));
    //AGI.InitVars;//hangs
    AGI.DialPadKey:=AGI.StringToDialpadKey('1001');
    
    
  end;
end;


destructor TTestAGI.destroy;
begin
  inherited;
  if AGI<>nil then AGI.Destroy;
end;

procedure runtest;
  var TestAGI: TTestAGI;
begin
  TestAGI:=TTestAGI.Create;
  TestAgi.destroy;
end;
 
 
begin
  RunTest;
end.
