{$mode objfpc}
{$h+}
program ipcclient;

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
