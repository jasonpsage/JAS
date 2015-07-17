program testsox;

uses ug_jegas,dos;

var iResult: longint;
begin
  
  iResult:=iShell('/usr/bin/sox', '-m'+
     ' -c 1 "/vros/2012/0910/2012091020051081302_Video_Processed.wav"'+
     ' -c 1 "/vros/2012/0910/2012091020052035171_Video_Processed.wav"'+
     ' -c 1 "/vros/2012/0910/2012091020053796106_Video_Processed.wav"'+
     ' -c 1 "/vros/2012/0910/2012091020051081302_Mixed.wav"');
  
  
  {
  iResult:=iShell('/usr/bin/sox', '-m'+
     ' -c 1 "/vros/2012091020051081302_Video_Processed.wav"'+
     ' -c 1 "/vros/2012091020052035171_Video_Processed.wav"'+
     ' -c 1 "/vros/2012091020053796106_Video_Processed.wav"'+
     ' -c 1 "/vros/mixed.wav"');
   }

   writeln('Result: ',iResult);

   //Exec('/usr/bin/sox', '-m'+
   //  ' -c 1 "/vros/2012/0910/2003/2689/624E/work/2012091020051081302_Video_Processed.wav"'+
   //  ' -c 1 "/vros/2012/0910/2003/2689/624E/work/2012091020052035171_Video_Processed.wav"'+
   //  ' -c 1 "/vros/2012/0910/2003/2689/624E/work/2012091020053796106_Video_Processed.wav"'+
   //  ' -c 1 "/vros/2012/0910/2003/2689/624E/work/mixed.wav"');
end.
