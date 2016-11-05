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


{$mode objfpc}
{h+}
{ }
// This program is a test and and example of the inter-process communication
// units. This is a file based system that is surprisingly fast and it a
// neat way to use shared network drives as inter-computer communication
// conduits! :)
program ipcserver;//test program
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

