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

{$mode objfpc}
{$h+}
{ }
{ This program is used to test the file based inter-process communication
routines. This can be used for computer to computer comunication viw drop
files. Generally people use networking but this is quite fast as it uses
file block reads and writes for its file io.}
program ipcclient;//test program

uses simpleipc,
sysutils,
ug_jegas

;
var 
   saMyID: ansistring;
   Srv: TSimpleIPCServer;
   s: ansistring;
   bGotIt: boolean;
   bServerOffLine: boolean;
begin
  bServerOffline:=false;

  saMyID:=FloattoStr(TimeStampToMsecs(DateTimeToTimeStamp(now)));
  With TSimpleIPCClient.Create(Nil) do
    try
      ServerID:='Jegas';
      try
        Active:=True;
      except
        bServerOffline:=true;
      end;  
      if not bServerOffline then
      begin
        SendStringMessage(saMyID);
        Active:=False;
      end;
    finally
      Free;
    end;

  if not bServerOffline then
  begin
    Srv:=TSimpleIPCServer.Create(Nil);
    Try
      Srv.ServerID:=saMyID;
      Srv.Global:=true;
      Srv.StartServer;
      Writeln('Client IPC Server started. Listening for message from main server');
      bGotit:=false;
      Repeat
        If Srv.PeekMessage(1,True) then
          begin
          S:=Srv.StringMessage;
          writeln(s);
          Writeln('Received you message. Length: ',length(S), ' Message:',s);
          bGotit:=true;
          end
        else
          Sleep(10);
      Until bGotIt;
    Finally
      Srv.Free;
    end;
  end
  else
  begin
    Writeln('Server Offline');
  end;
end.
