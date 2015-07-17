{$mode objfpc}
{h+}
program ipcserver;


uses
  classes,
  SysUtils,
  simpleipc;
Var
  Srv : TSimpleIPCServer;
  S : ansiString;
begin
  Srv:=TSimpleIPCServer.Create(Nil);
  Try
    Srv.ServerID:='Jegas';
    Srv.Global:=true;
    Srv.StartServer;
    Writeln('Server started. Listening for messages');
    Repeat
      If Srv.PeekMessage(1,True) then
      begin
        S:=Srv.StringMessage;
        writeln('Recv:'+s);
      end
      else
        Sleep(10);
    Until CompareText(S,'stop')=0;
  Finally
    Srv.Free;
  end;
end.

