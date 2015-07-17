{---------------------------------------------------------------------------
                                 CncWare
                           (c) Copyright 2000
 ---------------------------------------------------------------------------
  Filename..: daemon.pp
  Programmer: Ken J. Wright  - Gave permission to use in JAS.
  Date......: 03/21/2000

  Purpose - Program to demonstrate construction of a Linux daemon.

  Usage:
    1) Compile this program.
    2) Run it. You will be immediately returned to a command prompt.
    3) Issue the command: ps ax|grep daemon. This will show you the process
       id of the program "daemon" that you just ran.
    4) Issue the command: tail -f daemon.log This let's you watch the log file
       being filled with the message in the code below. Press Ctrl/c to break
       out of the tail command.
    5) Issue the command: kill -HUP pid. pid is the process number you saw with
       the ps command above. You will see that a new log file has been created.
    6) Issue the command: kill -TERM pid. This will stop the daemon. Issuing the
       ps command above, you will see that the daemon is no longer running.

-------------------------------<< REVISIONS >>--------------------------------
  Ver  |    Date    | Prog | Description
-------+------------+------+--------------------------------------------------
  1.00 | 03/21/2000 | kjw  | Initial release.
  1.01 | 03/21/2000 | kjw  | Forgot to close input, output, & stderr.
  1.02 | 04/03/2000 | kjw  | Some minor touch-up.
  1.03 | 04/10/2000 | kjw  | Dies if a forking error.
  1.04 | 09/11/2000 | kjw  | 1) Added IoResult call after initial closing of
                           | the log file when it's not open.
                           | 2) Added VER0 conditional. v1.0 changed
                           | the sa_handler field to a case variant.
                           | 3) Added VER1_00_0 check because of compiler bug.
------------------------------------------------------------------------------
}
Program Daemon;
{$IFDEF LINUX}
uses linux;
Var
   { vars for daemonizing }
   bHup,
   bTerm : boolean;
   fLog : text;
   logname : string;
   aOld,
   aTerm,
   aHup : pSigActionRec;
   ps1  : psigset;
   sSet : cardinal;
   pid : longint;
   secs : longint;
   hr,mn,sc,sc100 : word;

{ handle SIGHUP & SIGTERM }
{ keep this code small! }
procedure DoSig(sig : longint);cdecl;
begin
   case sig of
      SIGHUP : bHup := true;
      SIGTERM : bTerm := true;
   end;
end;

{ create the log file }
Procedure NewLog;
Begin
   Assign(fLog,logname);
   Rewrite(fLog);
   GetTime(hr,mn,sc,sc100);
   Writeln(flog,'Log created at ',hr:0,':',mn:0,':',sc:0);
   Close(fLog);
End;

Begin
   logname := 'daemon.log';
   secs := 10;

   { set global daemon booleans }
   bHup := true; { to open log file }
   bTerm := false;

   { block all signals except -HUP & -TERM }
   sSet := $ffffbffe;
   ps1 := @sSet;
   sigprocmask(sig_block,ps1,nil);

   { setup the signal handlers }
   new(aOld);
   new(aHup);
   new(aTerm);
   { v1.0 changed the structure of SigActionRec }
   {$ifdef VER0 }
   aTerm^.sa_handler := @DoSig;
   aHup^.sa_handler := @DoSig;
   {$else}
   aTerm^.handler.sh := @DoSig;
   aHup^.handler.sh := @DoSig;
   {$endif}
   aTerm^.sa_mask := 0;
   aTerm^.sa_flags := 0;
   aTerm^.sa_restorer := nil;
   aHup^.sa_mask := 0;
   aHup^.sa_flags := 0;
   aHup^.sa_restorer := nil;
   SigAction(SIGTERM,aTerm,aOld);
   SigAction(SIGHUP,aHup,aOld);

   { daemonize }
   pid := Fork;
   Case pid of
      0 : Begin { we are in the child }
         {$ifdef VER1_00_0 }
         writeln('WARNING:');
         writeln('Please upgrade your compiler to a later snapshot.');
         writeln('v1.00 contains a bug in the system unit relative to');
         writeln('using /dev/null.');
         writeln('input, output, and stderr have not been re-directed.');
         {$else}
         Close(input);  { close standard in }
         Close(output); { close standard out }
         Assign(output,'/dev/null');
         ReWrite(output);
         Close(stderr); { close standard error }
         Assign(stderr,'/dev/null');
         ReWrite(stderr);
         {$endif}
      End;
      -1 : secs := 0;     { forking error, so run as non-daemon }
      Else Halt;          { successful fork, so parent dies }
   End;

   { begin processing loop }
   If secs > 0 Then
   Repeat
      If bHup Then Begin
         {$I-}
         Close(fLog);
         IoResult;
         {$I+}
         NewLog;
         bHup := false;
      End;
      {----------------------}
      { Do your daemon stuff }
      GetTime(hr,mn,sc,sc100);
      Append(flog);
      Writeln(flog,'daemon code activated at ',hr:0,':',mn:0,':',sc:0);
      Close(fLog);
      { the following output goes to the bit bucket (/dev/null) }
      Writeln('daemon code activated at ',hr:0,':',mn:0,':',sc:0);
      {----------------------}
      If not bTerm Then
         { wait a while }
         Select(0,nil,nil,nil,secs*1000);
   Until bTerm;
End.
{$ELSE}
begin
end.
{$ENDIF}
