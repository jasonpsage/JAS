//==============================================================================
//       _________ _______  _______  ______  _______     http://www.jegas.com
//      /___  ___// _____/ / _____/ / __  / / _____/
//         / /   / /__    / / ___  / /_/ / / /____
//        / /   / ____/  / / /  / / __  / /____  /
//   ____/ /   / /___   / /__/ / / / / / _____/ /
//  /_____/   /______/ /______/ /_/ /_/ /______/
//                  Under the Hood
//==============================================================================
// Filename: jegas.js
//==============================================================================

//==============================================================================
// Jegas Application Server Configuration
//==============================================================================
var sMainURL='http://localhost/';
var sProgramDir='/';

var URL_JASAPI=sMainURL+'?jasapi=';
var URL_USERAPI=sMainURL+'?userapi=';
//==============================================================================
// Jegas Application Server Configuration
//==============================================================================

//==============================================================================
// GLOBAL
//==============================================================================
var JASAPI=null;// class instance used globally for JASAPI interaction
//==============================================================================

//==============================================================================
// JBlokmode constants
//==============================================================================
const cnJBlokMode_View = 0;
const cnJBlokMode_New = 1;
const cnJBlokMode_Delete = 2;
const cnJBlokMode_Save = 3;
const cnJBlokMode_Edit = 4;
const cnJBlokMode_Deleted = 5;
const cnJBlokMode_Cancel = 6;
const cnJBlokMode_SaveNClose=7;
const cnJBlokMode_CancelNClose=8;
//==============================================================================



//==============================================================================
function PageOnLoad(p_sPageTitle){
//==============================================================================
  try{
    if(p_sPageTitle != "" ) {
      if((document.title=="")||(document.title=="Loading...")){
        document.title=p_sPageTitle;
      };
    };
    if(document.title=="Loading..."){
      document.title="JAS";
    };
  }catch(eX){};
};
//==============================================================================


//==============================================================================
function ToggleHeader(){
//==============================================================================
  //try{
    var el = document.getElementById("jas-toggle-header");
    if(el.style.display==""){
      el.style.display="none";
    } else {
      el.style.display="";
    };
  //}catch(eX) { };
};
//==============================================================================


//==============================================================================
// Jegas Javascript
//==============================================================================
var win=null;
function NewWindowAdvanced(mypage,myname,w,h,scroll,pos){
  if(pos==null){
    if(w==null){w=screen.width};w=w+'';
    if(h==null){h=screen.height};h=h+'';
  };
  if(pos=="random"){
    LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;
  };
  if(pos=="center"){
    LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h)/2:100;
  }else if((pos!="center" && pos!="random") || pos==null){
    LeftPosition=0;TopPosition=20
  };
  settings='width='+(w+'')+',height='+(h+'')+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=yes,directories=yes,status=yes,menubar=yes,toolbar=yes,resizable=yes';
  win=window.open(mypage,myname,settings);
  if(win.focus){
    win.focus();
  };
};
// NewWindowAdvanced(this.href,'Cool','300','200','yes','center');return false
//==============================================================================

//==============================================================================
function NewWindowDialog(mypage,myname,w,h,scroll,pos){
  if(pos==null){
    if(w==null){w=screen.width};w=w+'';
    if(h==null){h=screen.height};h=h+'';
  };
  if(pos=="random"){
    LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;
  };
  if(pos=="center"){
    LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h)/2:100;
  }else if((pos!="center" && pos!="random") || pos==null){
    LeftPosition=0;TopPosition=20
  };
  settings='width='+(w+'')+',height='+(h+'')+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no';
  win=window.open(mypage,myname,settings);
  if(win.focus){
    win.focus();
  };
};
//==============================================================================



//==============================================================================
// this version is good for DEFAULT Settings. Note - In FireFox - its a new TAB!
//==============================================================================
function NewWindow(p_url){ window.open(p_url); };
//==============================================================================
function DebugWindow(p_url,p_content){
  var w = window.open(p_url);
  w.document.getElementById("debugcontent").innerHTML=p_content;
};
//==============================================================================

//==============================================================================
function NoFramesPlease(){if (window != top) top.location.href = document.location;};
//==============================================================================
function SetFocusById(p_id){try{document.getElementById(p_id).focus();}catch(e){};};
//==============================================================================
function CreateEmailLink(p_who, p_where){
  document.write('<a href="mailto:' + p_who + '@' + p_where+'">'+p_who+'@'+p_where+'</a>');
  return true;
};
//==============================================================================
function LTrim(p_s){
  if(p_s == undefined){return p_s};
  if(p_s == null){return null};
  if(p_s==''){return ''};
  var i = 0;
  var s= new String();
  s=String(p_s);
  var LEN=String(s).length;
  while((i<LEN)&&(s.substr(i,1)==" "))i++;
  if ((LEN-i)>0){
    return s.substr(i,LEN-i);
  }else{
    return s;
  };
};
//==============================================================================

//==============================================================================
function RTrim(p_s){
  if(typeof(p_s) == "undefined"){return p_s};
  if(p_s == null){return null};
  if(p_s==''){return ''};
  var s = new String();
  s=String(p_s);
  var LEN=String(s).length;
  var i = LEN;
  while((i>0)&&(s.substr(i-1,1)==" "))i--;
  //Response.Write("<br><font face=courier>INSIDE RTrim('"+s+"') Length:");
  //Response.Write(s.length);
  //Response.Write(" LEN="+LEN.toString());
  //Response.Write(" i="+i.toString());
  if(i>-1){
    //Response.Write(" Returning:"+String(s).substr(0,i)+":</font><hr>");
    return s.substr(0,i);
  }else{
    //Response.Write(" Returning:NOTHING but quote quote</font><hr>");
    return '';
  };
};
//==============================================================================
function Trim(p_s){
  if(p_s === undefined){return p_s};
  if(p_s === null){return null};
  if(p_s==''){return ''};
  return RTrim(LTrim(p_s));
};
//==============================================================================
function sURIDecode(p_s){
  if(p_s == undefined){return p_s};
  if(p_s == null){return null};
  if(p_s==''){return ''};
  // Actually got a string to play with
  var s,i;
  s = p_s.replace(/\&gt;/g,'>');
  s = s.replace(/\&lt;/g,'<');
  s = s.replace(/\&apos;/g,"'");
  s = s.replace(/\&quot;/g,'"');
  s = s.replace(/\&amp;/g,'&');
  return s;
};
//==============================================================================
function sReverse(p_s){
  var s,i;
  if(p_s == undefined){return p_s};
  if(p_s == null){return null};
  if(p_s==''){return ''};
  s='';
  for(i=p_s.length;i>-1;i--){
    s = s + p_s.substr(i,1);
  };
  return s;
};
//==============================================================================
function toRadix(N,radix) {
 var HexN="", Q=Math.floor(Math.abs(N)), R;
 while (true) {
  R=Q%radix;
  HexN = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".charAt(R)+HexN;
  Q=(Q-R)/radix; if (Q==0) break;
 };
 return ((N<0) ? "-"+HexN : HexN);
};
//==============================================================================
//Extremely CHEAP 2 digit number padding subroutine
// give it 0 it gives 00
function sZP(number){
 var s=String(number);
 if (s.length==1){
   return "0" + s;
 }else{s
   return s;
 };
};
//==============================================================================
// Cheap 4 Digit Number Padding
function sZP4(number){
 var s=String(number);
 if (s.length==1){
   return "000" + s;
 }else{
         if (s.length==2){
           return "00" + s;
         }else{
                 if (s.length==3){
                   return "0" + s;
                 }else{
                   return s;
                 };
         };
 };
};
//==============================================================================
// This pair of functions (myesc and myunesc) are the same as
// the standard escape and unescape, with one exception. PLUSES in DATA,
// when passed to the normal ESCAPE/UNESCAPE routines come back as
// Spaces... because in a CGI line you can have "Hey Bob" represented in a URL
// as Hey+Bob. Well, that's just fine unless you want to PASS a PLUS!
// So what do I do? (I don't know yet, I haven't written the routine but I'm thinking of
// ESCAPING pluses with a code if there is one I can snag :)
function myesc(p_s){
  return escape((p_s).replace(/\+/,"\\x2B"));
};
//==============================================================================
function myunesc(p_s){
  return (unescape(p_s)).replace(/\\x2B/,"+");
};
//==============================================================================
// returns coords of an object in the DOM
function findPos(obj) {
  var curleft = curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
    return [curleft,curtop];
  };
};
//==============================================================================


//==============================================================================
//==============================================================================
//==============================================================================
// Date String to String conversion (can optionally pass date object, but
// send '?' as p_FormatIn parameter.
//
// REQ PARAMETERS:
//  p_sDate - DATE IN STRING FORMAT (or date object)
//  p_sFormatOut - DESIRED OUTPUT FORMAT - ZERO makes it return DATE OBJECT
//  p sFormatIn -  Format of date coming in ----  unless date object, in
//      which case pass '?' or 0, or nothing!
//
// You CAN pass the values of the following array, either literally or
// using the array itself, but for speed's sake, and to shave a few bytes
// out of date intensive works, I set up the function to be smart enough
// to know WHAT format you want by sending the indexes of this array in
// place of the string representations!
//
//==============================================================================
//==============================================================================
//==============================================================================
  var asDateFormat= new Array(
    '?',                              //0 for when you pass DATE OBJECT, use
                                      // this as format in,
                                      //  just so routine doesn't kick you out.

    'MM/DD/YYYY HH:NN AM',            //1 ADO Friendly for SAVING TO MSSQL
                                      //  5/1/2005 12:00 am (or Zero Padded
                                      //  not  sure if matters)

    'MM/DD/YYYY',                     //2

    'YYYY-MM-DD',                     //3 BlueShoes Date Picker Format for
                                      //  isoInit and CGI Params

    'DDD MMM DD HH:MM:SS EDT YYYY',   //4

    'DDD, DD MMM YYYY HH:MM:SS',      //5 JavaScript date object - can be used
                                      //  to set time, I think

    'DDD, DD MMM YYYY HH:MM:SS UTC',  //6

    'DDDD, DD MMM, YYYY HH:MM:SS AM', //7 javascript date.toLocaleString()
                                      //  format  DDDD=day name spelled out

    'HH:NN:SS',                       //8

    'HH:NN:SS EDT',                   //9

    'MMM DDD DD YYYY',                //10 'Mon May 20 2002'

    'YYYY-MM-DD HH:NN:SS',            //11 '2005-01-30 14:15:12'

    'MM/DD/YY',                       //12 '01/02/06'

    'DD/MMM/YYYY',                    //13 '17/Jan/2007'

    'DD/MMM/YYYY HH:MM AM',           //14 '17/Jan/2007 03:08 PM'

    'DD/MMM/YYYY HH:MM',              //15 '17/Jan/2007 23:00' Military time

    'HH:MM AM',                       //16 '03:08 PM'

    'HH:MM'                           //17 '23:00' Military time

    );
  var aMonth = new Array ('January','Febuary','March', 'April', 'May','June',
                          'July','August','September','October','November',
                          'December');
  var aDay = new Array ('Sunday','Monday','Tuesday','Wednesday','Thursday',
                        'Friday','Saturday');

//==============================================================================
//==============================================================================
//==============================================================================

  function iMilitaryHours(p_sAMPMFLAG, p_sHours){
    if((p_sAMPMFLAG=='PM')&&((p_sHours-0)<12)){return ((p_sHours-0)+12);};//Make Military HOURS
    if((p_sAMPMFLAG=='AM')&&((p_sHours-0)==12)){return 0};//Make Military HOURS
    return (p_sHours-0);
  };
  function iNormalHours(p_sAMPMFLAG, p_sHours){
    if((p_sAMPMFLAG=='PM')&&((p_sHours-0)>12)){return ((p_sHours-0)-12);};//Make Normal Hours
    if((p_sAMPMFLAG=='AM')&&((p_sHours-0)==0)){return 12};//Make normal hours
    return p_sHours -0;
  };
  function iMilitaryToNormalHours(p_sHours){
    if((p_sHours-0)>12){return ((p_sHours-0)-12);}else{if((p_sHours-0)==0){return 12}else{return (p_sHours-0);};};//Make Normal Hours
  };

  function sAMPM(p_iMilitaryHours){if(p_iMilitaryHours>11){return 'PM'}else{return 'AM'};};
  function iMonth(p_sMonthName){
    var s=p_sMonthName.toUpperCase();
    var result=0;var i=0;
    for(i=0;i<aMonth.length;i++){
      if(  String(aMonth[i].substr(0,3)).toUpperCase() === s ){
        return i+1;//set month
      };
    };
    Response.Write('IMONTH:'+p_sMonthName);

  };

//==============================================================================
//==============================================================================
//==============================================================================
function JDate(p_Date, p_sFormatOut,p_sFormatIn){
/*document.write('<br>\n\nDATE:');
document.write(p_Date);
document.write('<br>\n\nFormatOut:');
document.write(p_sFormatOut);
document.write('<br>\n\nFormatIn:');
document.write(p_sFormatIn);
document.write('<br>\n\n');
*/
  // Three main variables to set up, what we got, what we think it is, what
  // we want it to become
  var sin = '';
  var iFmt = -1; //in format array index
  var oFmt = -1; //out format array index

  if((p_sFormatIn!='?')&&(arguments.length>=3)){
    if(String(p_sFormatIn*1)!='NaN'){// we got a numeral! (well, close enough
                                     // a test for us!)
      iFmt=p_sFormatIn;
    };
  };
  if(String(p_sFormatOut*1)!='NaN'){//we got a numeral!
                                   // (well, close enough a test for us!)
    oFmt=p_sFormatOut;
  };

  try{//If passed a date type, try to get into string format
    sin = p_Date.getDay();//THIS command will bust it if not date object!
                          // (hence the try{}catch thing)
    iFmt = 0; //denote date object coming in
  }catch(e){
    try{//if passed string, cool
      sin = Trim(String(p_Date));
      if(sin.length==0)return '';
      //unless they passed the '?' format!
      if(arguments.length>=3){
        if(p_sFormatIn=='?')return
          'Question Mark Not Valid In this context JDate()';
      };
    }catch(e){//dont know what they hell I got
      return '';// give them empty string, this is a string type function
                // afterall
    };
  };

  var i=0;
  if(iFmt==-1){
    var sFormatIn = new String(Trim(p_sFormatIn)).toUpperCase();
    for(i=0;i<asDateFormat.length;i++){if(sFormatIn===asDateFormat[i])iFmt=i;};
    if(iFmt==-1)return 'BAD DATE FORMAT IN JDate() - Value Passed:'+sFormatIn;
  };
  if(oFmt==-1){
    var sFormatOut = new String(Trim(p_sFormatOut)).toUpperCase();
    //Make sure all the parameters are cool for this routine
    if(sFormatOut=='?')return 'Question Mark Not Valid for output format parameter, ANYTIME! JDate()';
    for(i=0;i<asDateFormat.length;i++){if(sFormatOut===asDateFormat[i])oFmt=i;};
    if(oFmt==-1)return 'BAD DATE FORMAT OUT JDate() - Value Passed:'+sFormatOut;
  };

  // fill these variables - all date conversion revolve around these being set right
  var m=0;//month (1=January)
  var d=0;//days
  var y=0;//years
  var h=0;//hours
  var n=0;//minutes
  var s=0;//seconds
  var mh=0;//military hours


  switch (iFmt){
  case 0://date object
    m= p_Date.getMonth()+1;//month (1=January)
    d= p_Date.getDate();//days
    y= p_Date.getYear();//years
    h= iMilitaryToNormalHours(mh=p_Date.getHours());//hours
    n= p_Date.getMinutes();//minutes
    s= p_Date.getSeconds();//seconds
    //military hours
    break;
  case 1://'MM/DD/YYYY HH:NN AM'
    var sp = sin.split(' '); //sp0='mm/dd/yyyy' sp1='hh:nn' sp2='am'
    var dp = sp[0].split('/');//dp0=mm dp1=dd dp2=yyyy
    var tp = sp[1].split(':'); //tp0=hh, tp1=nn
    m=dp[0]-0;d=dp[1]-0;y=dp[2]-0;//month, day, year
    h=iNormalHours(sp[2],tp[0]);n=tp[1]-0;//s=tp[2]-0;//hours, minutes, possibly seconds
    mh=iMilitaryHours(sp[2],tp[0]);
    break;
  case 2://MM/DD/YYYY
    var dp = sin.split('/');//dp0=mm dp1=dd dp2=yyyy
    m=dp[0]-0;d=dp[1]-0;y=dp[2]-0;//month, day, year
    break;
  case 3://YYYY-MM-DD
    var dp = sin.split('-');
    m=dp[1]-0;d=dp[2]-0;y=dp[0]-0;
    break;
  case 4://'DDD MMM DD HH:MM:SS EDT YYYY'
    //date
    var sp = sin.split(' '); //sp0=ddd, 1=mmm 2=dd 3=hh:mm:ss 4=EDT 5=yyyy
    m=iMonth(sp[1]);d=sp[2]-0;y=sp[5]-0;
    //time
    var tp = sp[3].split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);

    //Response.Write("TP[0]");
    //Response.Write(tp[0]);

    mh=tp[0]-0;
    n=tp[1]-0;
    s=tp[2]-0;



    break;
  case 5://'DDD, DD MMM YYYY HH:MM:SS'
    var sp = sin.split(' '); //sp0=ddd, 1=dd 2=mmm 3=yyyy 4=hh:mm:ss
    m=iMonth(sp[2]);d=sp[1]-0;y=sp[3]-0;
    //time
    var tp = String(sp[4]).split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=tp[0]-0;
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 6://'DDDD, DD MMM, YYYY HH:MM:SS AM'
    var sp = sin.split(' '); //sp0=dddd, 1=dd 2=mmm 3=yyyy 4=hh:mm:ss 5=am
    m=iMonth(sp[2]);d=sp[1]-0;y=sp[3]-0;
    //time
    var tp = String(sp[4]).split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=iMilitaryHours(sp[5],tp[0]);
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 7://'DDDD, DD MMM, YYYY HH:MM:SS AM'
    var sp = sin.split(' '); //sp0=dddd, 1=dd 2=mmm 3=yyyy 4=hh:mm:ss 5=am
    m=iMonth(sp[2]);d=sp[1]-0;y=sp[3]-0;
    //time
    var tp = String(sp[4]).split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=iMilitaryHours(sp[5],tp[0]);
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 8://'HH:NN:SS'
    //time
    var tp = sin.split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=tp[0]-0;
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 9://'HH:NN:SS EDT'
    //time
    var tp = sin.split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=tp[0]-0;
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 10://'MMM DDD DD YYYY'
    var sp = sin.split(' '); //sp0=mmm 1=ddd 2=dd 3=yyyy
    m=iMonth(sp[0]);d=sp[2]-0;y=sp[3]-0;
    break;
  case 11://'2005-01-30 14:15:12'
    var sp = sin.split(' ');// sp0='YYYY-MM-DD'  sp1='HH:MM:SS'
    var dp = sp[0].split('-');
    m=dp[1]-0;d=dp[2]-0;y=dp[0]-0;
    var tp = sp[1].split(':'); //tp0=hh, tp1=nn, tp2=seconds
    h=iMilitaryToNormalHours(tp[0]);
    mh=tp[0]-0;
    nn=tp[1]-0;
    s=tp[2]-0;
    break;
  case 12://'01/02/06'
    var dp = sin.split('/');
    m=dp[0]-0;d=dp[1]-0;y=dp[2]-0;
    break;
  case 13://'17/Jan/2007'
    var sp = sin.split('/'); //sp0=dd 1=mmm 2=yyyy
    m=iMonth(sp[1]);d=sp[0];y=sp[2]-0;
    break;
  case 14:// '17/Jan/2007 03:08 PM'    'DD/MMM/YYYY HH:MM AM'
    var sp = sin.split(' ');// sp0='DD/MMM/YYYY' sp1='HH:MM' sp2='AM'
    var dp = sp[0].split('/');m=iMonth(dp[1]);d=dp[0];y=dp[2]-0;
    var tp = String(sp[1]).split(':'); //tp0=hh, tp1=nn
    h=tp[0];
    mh=iMilitaryHours(sp[2],tp[0]);
    n=tp[1]-0;
    break;
  case 15:// 'DD/MMM/YYYY HH:MM'       '17/Jan/2007 23:00' Military time
    var sp = sin.split(' ');// sp0='DD/MMM/YYYY' sp1='HH:MM'
    var dp = sp[0].split('/');m=iMonth(dp[1]);d=dp[0];y=dp[2]-0;
    var tp = String(sp[1]).split(':'); //tp0=hh, tp1=nn
    h=iMilitaryToNormalHours(tp[0]);
    mh=tp[0];
    nn=tp[1]-0;
    break;
  case 16:// 'HH:MM AM'                '03:08 PM'
    var sp = sin.split(' '); // sp[0]='HH:MM' sp[1]='PM'
    var tp = String(sp[0]).split(':'); //tp0=hh, tp1=nn
    h=tp[0];
    mh=iMilitaryHours(sp[1],tp[0]);
    n=tp[1]-0;
    break;
  case 17:// 'HH:MM'                   '23:00' Military time
    var tp = sin.split(':'); // tp[0]='HH' tp[1]='MM'
    h=iMilitaryToNormalHours(tp[0]);
    //mh=iMilitaryHours(sp[1],tp[0]);
    mh=tp[0];
    n=tp[1]-0;
  };//switch

  // TODO: Try This: h=iMilitaryToNormalHours(h+'');// Make sure flip things like 00 to 12
  if(y<20){y+=2000}else{if(y<200){y+=1900}};
  /*
  document.write('<br>Y:');document.write(y.toString());
  document.write('<br>M:');document.write(m.toString());
  document.write('<br>D:');document.write(d.toString());
  document.write('<br>H:');document.write(h.toString());
  document.write('<br>N:');document.write(n.toString());
  document.write('<br>S:');document.write(s.toString());
  document.write('<br>mh:');document.write(mh.toString());
  document.write('<br>');
  */

  if(y==1899){return '';};// handle nulls coming in (in ado anyways)





  var dtDate = new Date(y,m-1,d,mh,n,s,0);
  switch(oFmt){
  case 0: return dtDate;
  case 1://'MM/DD/YYYY HH:NN AM'
    return sZP(m)+'/'+sZP(d)+'/'+sZP4(y)+' '+sZP(h)+':'+sZP(n)+' '+sAMPM(mh);
  case 2://'MM/DD/YYYY'
    return sZP(m)+'/'+sZP(d)+'/'+sZP4(y)
  case 3://'YYYY-MM-DD'
    return sZP4(y)+'-'+sZP(m)+'-'+sZP(d)
  case 4://'DDD MMM DD HH:MM:SS EDT YYYY'
    return String(dtDate);
  case 5://'DDD, DD MMM YYYY HH:MM:SS'
    var ts=dtDate.toUTCString();
    ts = ts.substr(0,ts.length-4)
    return ts;
  case 6://'DDD, DD MMM YYYY HH:MM:SS UTC'
    return dtDate.toUTCString();
  case 7://'DDDD, DD MMM, YYYY HH:MM:SS AM'
    return dtDate.toLocaleDateString();
  case 8://'HH:NN:SS'
    return sZP(mh)+':'+sZP(n)+':'+sZP(s);
  case 9://'HH:NN:SS EDT'
    return sZP(mh)+':'+sZP(n)+':'+sZP(s)+' EDT';
  case 10://'MMM DDD DD YYYY'
    return String(aMonth[m-1]).substr(0,3)+' '+
      String(aDay[dtDate.getDay()]).substr(0,3)+' '+sZP(d)+' '+sZP4(y);
  case 11://'2005-01-30 14:15:12'
    return sZP4(y)+'-'+sZP(m)+'-'+sZP(d) +' '+sZP(mh)+':'+sZP(n)+':'+sZP(s);
  case 12://'01/02/06'
    return sZP(m)+'/'+sZP(d)+'/'+(sZP(y)).substr(2);
  case 13://'17/Jan/2007'
    //var ts=dtDate.toUTCString();
    var ts = dtDate.toDateString();
    ts = ts.substr(4,3);
    return sZP(d)+'/'+ts+'/'+sZP(y);
  case 14:// '17/Jan/2007 03:08 PM'    'DD/MMM/YYYY HH:MM AM'
    return sZP(d)+'/'+String(aMonth[m-1]).substr(0,3)+'/'+sZP4(y)+' '+sZP(h)+':'+sZP(n)+' '+sAMPM(mh);
  case 15:// 'DD/MMM/YYYY HH:MM'       '17/Jan/2007 23:00' Military time
    return sZP(d)+'/'+String(aMonth[m-1]).substr(0,3)+'/'+sZP4(y)+' '+sZP(mh)+':'+sZP(n);
  case 16:// 'HH:MM AM'                '03:08 PM'
    return sZP(h)+':'+sZP(n)+' '+sAMPM(mh);
  case 17:// 'HH:MM'                   '23:00' Military time
    return sZP(mh)+':'+sZP(n);
  };//switch
};
//==============================================================================


//==============================================================================
function createCookie(name,value,days) {
//==============================================================================
        if (days) {
                var date = new Date();
                date.setTime(date.getTime()+(days*24*60*60*1000));
                var expires = "; expires="+date.toGMTString();
        }
        else var expires = "";
        document.cookie = name+"="+value+expires+"; path=/";
}
//==============================================================================

//==============================================================================
function readCookie(name) {
//==============================================================================
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1,c.length);
                if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
}

//==============================================================================
function eraseCookie(name) {
//==============================================================================
        createCookie(name,"",-1);
}
//==============================================================================

//==============================================================================
function removeCDATA(p_s){
//==============================================================================
    var s = '';
    s=p_s;
    var iP = s.indexOf("<![CD"+"ATA[");
    if(iP>-1){
      s.replace("<![CD"+"ATA[",'');
    };
    return s;
};
//==============================================================================

//==============================================================================
// Jegas JASAPI
//==============================================================================
function clsJASAPI(){
  this.doc=null;
  this.SessionUID="0";
  this.iwfCallback=function(p_doc){
    JASAPI.doc=p_doc;//JASAPI.doc specified and purposely not "this.doc"
  };
  this.JASAPIURL=function(p_JASAPI_Function){
    var jsid=null;
    var iP=window.location.href.toUpperCase().indexOf('JSID=');
    if(iP>-1){
      jsid=window.location.href.substr(iP+5);
    }else{
      jsid=readCookie('JSID');
    };
    var sCall=URL_JASAPI+p_JASAPI_Function;
    if(jsid!=null){sCall+='&jsid='+jsid;};
    return sCall;
  };
  this.USERAPIURL=function(p_USERAPI_Function){
    var jsid=null;
    var iP=window.location.href.toUpperCase().indexOf('JSID=');
    if(iP>-1){
      jsid=window.location.href.substr(iP+5);
    }else{
      jsid=readCookie('JSID');
    };
    var sCall=URL_USERAPI+p_USERAPI_Function;
    if(jsid!=null){sCall+='&jsid='+jsid;};
    return sCall;
  };
  this.iRowIndexWithName=function(p_name){
    var ix=0;
    if(this.doc.rows[0].row.length>0){
      try{
        while((this.doc.rows[0].row[ix].name[0].getText()!=p_name)&&(ix<this.doc.rows[0].row.length-1)){
          ix++;
        };
        if(this.doc.rows[0].row[ix].name[0].getText()!=p_name){
          ix=-1;
        };
      }catch(e){
        alert(e.message + ' ix:'+ix.toString()+' doc:'+this.doc);
      };
    }else{
      ix=-1;
    };
    return ix;
  };

  // returns helloworld text
  this.helloworld=function(){
    //alert(this.JASAPIURL('helloworld'));
    iwfRequest(this.JASAPIURL('helloworld'),this.iwfCallback,true,null);
    var ix=this.iRowIndexWithName('helloworld');
    if(ix>-1){
      return this.doc.rows[0].row[ix].name[0].getText();
    }else{
      return "";
    };
  };
  // returns session string ( 0 = Access Denied )
  this.validatesession=function(){
    iwfRequest(this.JASAPIURL('validatesession'),this.iwfCallback,true,null);
    var ix=this.iRowIndexWithName('validatesession');
    if(ix>-1){
      return this.doc.rows[0].row[ix].value[0].getText()==="true";
    }else{
      return false;
    };
  };
  this.createsession=function(p_sUsername, p_sPassword, p_sNewPassword1, p_sNewPassword2){
    var sCall=this.JASAPIURL("createsession") +
      "&username="+encodeURIComponent(p_sUsername)+
      "&password="+encodeURIComponent(p_sPassword);
    if((p_sNewPassword1!=null)||(p_sNewPassword2!=null)){
      s+="&newpassword1=";
      if(p_sNewPassword1!=null){s+=encodeURIComponent(p_sNewPassword1);};
      s+="&newpassword2=";
      if(p_sNewPassword2!=null){s+=encodeURIComponent(p_sNewPassword2);};
    };
    iwfRequest(sCall,this.iwfCallback,true,null);
    var ix=this.iRowIndexWithName('createsession');
    var bOk=false;
    if(ix>-1){
      bOk=(this.doc.rows[0].row[ix].value[0].getText()==='True');
      if(bOk){
        ix=this.iRowIndexWithName('createsessionuid');
        if(ix>-1){
          this.SessionUID=this.doc.rows[0].row[ix].value[0].getText();
        }else{alert('SessionUID Not found');};
      };
    };
    return bOk;
  };
  // Call immediately after createsession to snag createsessionmessage
  this.createsessionmessage=function(){
    var ix=this.iRowIndexWithName('createsessionmessage');
    if(ix>-1){
      return this.doc.rows[0].row[ix].value[0].getText();
    }else{
      return "";
    };
  };

};
//==============================================================================




//<script language="javascript">
//  var bfs1000x=0;
//</script>
//<div id="bfs1000"><img onclick="bfs1000x = sortswitch('bfs1000',bfs1000x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-up.png" /></div>
//<div id="bfs1000A" style="display: none;"><img onclick="bfs1000x = sortswitch('bfs1000',bfs1000x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/go-down.png" /></div>
//<div id="bfs1000D" style="display: none;"><img onclick="bfs1000x = sortswitch('bfs1000',bfs1000x);" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-no.png" /></div>
// <input type="hidden" id="bfs1000S" value="2" /><script language="javascript">var bfs1000x=2;</script>'
//==============================================================================
function sortswitch(p_id, p_x){
//==============================================================================
  var el=null;
  p_x+=1;if(p_x>2){p_x=0;};
  el=document.getElementById(p_id);
  if(p_x==0){el.style.display="";}else{el.style.display="none";};
  el=document.getElementById(p_id+'A');
  if(p_x==1){el.style.display="";}else{el.style.display="none";};
  el=document.getElementById(p_id+'D');
  if(p_x==2){el.style.display="";}else{el.style.display="none";};
  el=document.getElementById(p_id+'U').value=p_x.toString();
  //el.value=p_x.toString();
  return p_x;
};
//==============================================================================


//==============================================================================
function sabswitch(){
//==============================================================================
  var el=null;
  if(document.getElementById("sab").value==""){
    document.getElementById("sab").value="sab";
    el=document.getElementById("sab1");el.style.display="none";
    el=document.getElementById("sab2");el.style.display="";
  }else{
    document.getElementById("sab").value="";
    el=document.getElementById("sab1");el.style.display="";
    el=document.getElementById("sab2");el.style.display="none";
  };
};
//==============================================================================



//==============================================================================
// Example: jsleep(3); (Stay under 5 seconds to avoid timeouts) - Mike McCuen
function jsleep(s){
//==============================================================================
	s=s*1000;
	var a=true;
	var n=new Date();
	var w;
	var sMS=n.getTime();
	while(a){
		w=new Date();
		wMS=w.getTime();
		if(wMS-sMS>s) a=false;
	}
}
//==============================================================================

//==============================================================================
function d2h(d) {return d.toString(16);}
//==============================================================================
function h2d(h) {return parseInt(h,16);}
//==============================================================================


//==============================================================================
// BEGIN ---------- JCrypt
//==============================================================================

//==============================================================================
var sJSecKey = '[@JSECKEY@]';
var sJPubKey = '[@JPUBKEY@]';
var sJCryptMix = '[@JCRYPTMIX@]';
var au1Pub = new Array(512);
var au1Mix = new Array(256);
var bJCryptOk = false;
//==============================================================================

//==============================================================================
function InitJCrypt(){
  try{
    if(( parseInt(sJSecKey) > 0  ) && (sJPubKey.substring(0,2)!='[@') && (sJCryptMix.substring(0,2)!='[@')){
      var i = 0; for(i=0; i < 512; i++){au1Pub[i]=(h2d(sJPubKey.substr(i*2,2)));};
      for(i=0; i < 256; i++){au1Mix[i]=(h2d(sJCryptMix.substr(i*2,2)));};
      bJCryptOk=true;
    }else{  };
  }catch(err){
    /*alert(err);*/
  };
};
//==============================================================================


//==============================================================================
function sJegasEncryptSingleKey(p_sData){
//==============================================================================
  if((!bJCryptOk)  || (p_sData == null) || (p_sData == undefined) || (p_sData == 'undefined')) return 'ERROR - JCRYPT - 201012222058';
  var PADCHECK = 128;
  var iPad=p_sData.length % PADCHECK;
  //alert('IPAD: ' + iPad.toString() +' datalen:'+p_sData.length.toString());
  if (p_sData.length==0) iPad=PADCHECK;
  if (iPad>0){
    var iMustAdd = PADCHECK - iPad;
    var sPadCode = 'JCRYPTPAD['+(iMustAdd).toString()+']';
    var p = 0;
    for (p = 0 ; p<iMustAdd; p++){
      p_sData = p_sData + String.fromCharCode((Math.random()*26)+64);
    };
    p_sData = sPadCode + p_sData;
  };

  var au1 = new Array(p_sData.length);
  for(i=0; i < p_sData.length; i++){
    //au1[i] = p_sData.charCodeAt(i)
    au1[i]=au1Mix[p_sData.charCodeAt(i)];
    //alert('Encrypt '+p_sData[i]+' to ' + p_sData.charCodeAt(i).toString() + ' mixed: '+ au1Mix[p_sData.charCodeAt(i)].toString());
  };

  for(i=0; i < au1.length; i++){
    au1[i]=au1[i]^au1Pub[i % 1024];
    //alert('encrypt xor to:'+au1[i].toString());
  };

  var s = "";
  var h = "";
  for(i=0; i < p_sData.length; i++){
    h = d2h(au1[i]);
    if (h.length==1) h = '0'+h;
    s = s + h;
  };
  return s;
};
//==============================================================================

function u1UnMix(p_u1){
  var i=0;
  for(i=0;i<256;i++){
    if(au1Mix[i]==p_u1){ return i; };
  };
  return 0;
};

//==============================================================================
function sJegasDecryptSingleKey(p_sData){
//==============================================================================
  if((!bJCryptOk)  || (p_sData == null) || (p_sData == undefined) || (p_sData == 'undefined') || ((p_sData.length % 2)!=0)) return 'ERROR - JCRYPT - 201012222059';
  var au1 = new Array(( p_sData.length / 2 ) | 0 );
  var i = 0;
  var h="";
  for(i=0;i<au1.length; i++){
    h=p_sData.substr(i*2,2);
    au1[i] = h2d(h);
  };

  for(i=0; i < au1.length; i++){
    au1[i]=au1[i]^au1Pub[i % 1024];
  };

  var s = "";
  for(i=0; i < au1.length; i++){
    s = s + String.fromCharCode(u1UnMix(au1[i]));
  };

  if(s.length>12){
    if(s.substring(0,10)=='JCRYPTPAD['){
      s = s.substring(10,s.length-10);
      var x=s.indexOf(']');
      var iPad=parseInt(s.substring(0,x));
      s=s.substring(x+1);
      //alert('s length:'+s.length.toString()+' iPad Valu:'+iPad.toString()+' :'+s);
      s=s.substring(0,s.length-iPad+10);
    };
  };
  return s;
};
//==============================================================================

//if((sJSecKey == '[@'+'JSECKEY'+'@]')&&
//   (sJPubKey == '[@'+'JPUBKEY'+'@]')){
//  //(sJCryptMix == '[@'+'JCRYPTMIX'+'@]')
//  // ADD TEMP FIXED Encrypt keys HEre
  sJSecKey="2B391BA02EB356682F0889AB2771B500574F2977915E7382B4735C07575A2D4EA279787988A0D7EF0673D2AC81D3B93DC1EC9F7D95BE3300342921477BB8D4B51CFCFE209E0F36A2204D04B975A548E578414A88B2F62DA3D1491A36E9D1444ABDE51D9E2A4E2BF1C2925A6E6D2112ABBD2DBCC05F3026C483F244B19493D5148BDE693F66A0D3F8C0380A0DDDF84A21F070E9905D3E08A87BA7229C3F4F93C7928DE91991396279D4D2FB2F39E609C0FA1F4301C28908E1EAB92B80D93A994C64AA498C7A3181C6BF43AECC33826D084E11E776D9988264AB562672EE4EE3F0E24965C4C16A150D0FEBA1E369F6A1FB49791B950274C7A2959177A6D88D121D2AE640CA8642C6E60B0B871FC4EB8E74DC21F353836CC81B54ED472A449EA6642E78106EDD998BF9C97DF10B56B44ECC3D2484FFAD14DDBBBA1A1FCCD9FCF0035A89E24F81367AE85113125ED976B807DDDFF3897D181600B01637A47227FAF0A555510FC6C20711E1AB2871D4D3E6D3B9E74B95005E7D72C9FCF2981DA27A00E5A891767672A2FE67A7BED3C853386F107FB5353E6274F686EDFD0FC361AF34A1DAF92C30D730ADDB70C49A5E1F3D3E6370F21E417DD6FC8E33021DDB48D3368A0CD9A5B276B16BB2461162C25AB0610D21B84D81469ECD737C8481D40EAA9FC9E64F0C406D9E5BC5D39C6975A5DF8077FF4D2041D847511273E1B242F4B3BF";
  sJPubKey="1";
  sJCryptMix=
         'E5210B679D2E197C7EA1C63BBF4A1068478291234DDE120498F263A2EA628FC7'+
         '948CEE6AB46B1722726113F55E5DF009387A4F7399A90565800CD99CFAE64897'+
         '02E7584CF6A67D8EAAB852CBE22FC87F1EAE1D8D14762495BB2BDC3FFB33C23A'+
         '311684865FB51CFED239D0A0E13CF1E9CA9EBD1AD45AF43E9F88205B56379BA8'+
         '03497BFDD3326C3D7807B1892D594E35D1B3646DD7EC0E8B53B6776F87931FB7'+
         '51DAD80D6ECF4B42F35C697485C430B9E828A3256643907181EFEB2CD6402A0A'+
         'FF79D596018AC100CDDD55BAF941F81554349A834650BC27ADFCCCC5A7F7A41B'+
         'EDDF450844AB92E4267506E370E0C311A529C00FC9B2BE6036DB18B0AFACCE57';
//};
InitJCrypt();
//alert(bJCryptOk);
//var ss = sJegasEncryptSingleKey('Hello world.');
//alert('ENCRYPT OUTPUT: ' + ss);
//ss = sJegasDecryptSingleKey(ss);
//alert('DECRYPT OUTPUT('+ss.length.toString()+'): ' + ss);

//==============================================================================
// END ---------- JCrypt - By Jason P Sage of JEgas
//==============================================================================


//==============================================================================
// BEGIN --------------------
//==============================================================================
var gaoReqFields = new Array();
//==============================================================================


//==============================================================================
// BEGIN --------------------
//==============================================================================
function bReqFields_Validate(){
  try{
    //lert('Inside bReqFields_Validate. Fields:'+gaoReqFields.length.toString());
    var bValid=true;
    // properly render asterisks for entire list
    // return true if fields all properly filled in
    for(var w=0;w<gaoReqFields.length;w++){
      s=gaoReqFields[w].substr(0,gaoReqFields[w].length -2);
      //lert(w.toString() + ' '+s);
      var c = document.getElementById(s);
      bOk=c.value!=null;
      if(bOk){ bOk=c.value!=undefined ; };
      if(bOk){
        nc=Trim(c.value);
        bOk=nc.length>0;
        if(bOk){
          nc = nc.toUpperCase();
          bOk=(nc != 'NULL');
        }
      }
      if((false==bOk)&&bValid){
        bValid=false;
        alert('Please enter data in the required fields.');
        c.focus();
      }
    };
    //alert('Leaving bReqFields_Validate');
    return bValid;
  }catch(eX){
    return true;
  };
};
//==============================================================================
// END ----------------------
//==============================================================================




//==============================================================================
// BEGIN - LOGIN FUNCTIONS
//==============================================================================

//==============================================================================
function CheckIfSubmitting(){
//==============================================================================
	if (window.event){
	  if ((window.event.keyCode==13) && (!document.getElementById("changepassword").checked)){
	    SubmitForm();
	  }else{
	    return window.event.keyCode;
	  };
	}else{
	  return null;
	};
};
//==============================================================================

//==============================================================================
function bChecknewpasswords(){
//==============================================================================
  var bSuccess=false;
  try{
      if((document.getElementById("newpassword1").value==0) && ((document.getElementById("newpassword2").value==''))){
        document.getElementById("warning").innerHTML='New Password is Blank.';
        bSuccess=false;
      } else {
        if((document.getElementById("newpassword1").value != document.getElementById("newpassword2").value)){
	        document.getElementById("warning").innerHTML='Passwords do not match.';
	        bSuccess=false;
	        //document.getElementById("submitbutton").disabled=true;
        } else {
          document.getElementById("warning").innerHTML='';
          //document.getElementById("submitbutton").disabled=false;
          bSuccess=true;
        };
      };
    }catch(e){
      bSuccess=true;
    };
    return bSuccess;
};
//==============================================================================

//==============================================================================
function changepasswordclick(){
//==============================================================================
  if(document.getElementById("changepassword").checked){
    document.getElementById("changepassworddiv").innerHTML=
      '<table><tr><td colspan="3"><h2>Change Password</h2></td></tr><tr><td>New '+
      'Password</td><td>&nbsp;</td><td><input name="newpassword1" id="newpassword1" '+
      'type="password" "maxlength="32" /></td></tr><tr><td>Confirm New Password</td>'+
      '<td>&nbsp;</td><td><input name="newpassword2" id="newpassword2" type="password"'+
      ' maxlength="32" /></td></tr></table><p class="jas-page-footer">'+
      'Passwords must be betweeen 8 and 32 characters long and they must contain at '+
      'least one: uppercase letter, lowercase '+
      'letter and a number. Other valid characters that will accepted: ~`!@#$%^&*()-_=+'+
      '[];\'./\\|}{":&gt;&lt;?</p>';

    document.getElementById("warning").innerHTML='';
    document.getElementById("submitbutton").disabled=false;
  }else{
    document.getElementById("changepassworddiv").innerHTML='';
    document.getElementById("warning").innerHTML='';
    document.getElementById("submitbutton").disabled=false;
  };
};
//==============================================================================

//==============================================================================
function SubmitLoginForm(){
//==============================================================================
  var bSuccess = true;
  if (document.getElementById("changepassword").checked==true){
    bSuccess = bChecknewpasswords();
  };
  if(bSuccess==true){
    document.getElementById("frmlogin").submit();
  };
};
//==============================================================================

//==============================================================================
// END - LOGIN FUNCTIONS
//==============================================================================



//==============================================================================
// BEGIN - Theme Related
//==============================================================================

function callbacksettheme(doc){
  if(doc.errorCode!=0){alert(doc);}else{window.location.reload();}
};

function settheme(p_sName){
  var sURL='.?jasapi=settheme&name='+encodeURIComponent(p_sName);
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};

function seticontheme(p_sName){
  var sURL='.?jasapi=seticontheme&name='+encodeURIComponent(p_sName);
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};


function HeadersOn(){
  var sURL='.?jasapi=setdisplayheaders&value=true';
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};

function HeadersOff(){
  var sURL='.?jasapi=setdisplayheaders&value=false';
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};


function QuickLinksOn(){
  var sURL='.?jasapi=setdisplayquicklinks&value=true';
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};

function QuickLinksOff(){
  var sURL='.?jasapi=setdisplayquicklinks&value=false';
  try{
    iwfRequestSync(sURL,null,null,callbacksettheme);
  }catch(eX){
    alert('JAS Server appears to be offline.');
  };
};
//==============================================================================
// END - Theme Related
//==============================================================================






//==============================================================================
// Filter User Input
// Sample Use:
/* onkeypress="return goodchars(event,'0123456789'); */
//==============================================================================
function getkey(e){
  if (window.event)
     return window.event.keyCode;
  else if (e)
     return e.which;
  else
     return null;
};
function goodchars(e, goods){
  var key, keychar;
  key = getkey(e);
  if (key == null) return true;

  // get character
  keychar = String.fromCharCode(key);
  keychar = keychar.toLowerCase();
  goods = goods.toLowerCase();

  // check goodkeys
  if (goods.indexOf(keychar) != -1)
    return true;

  // control keys
  if ( key==null || key==0 || key==8 || key==9 || key==13 || key==27 )
     return true;

  // else return false
  return false;
};
//==============================================================================



//==============================================================================
// Callback for JASAPI_MoveQuickLink function
//==============================================================================
function callbackajax_movequicklink(doc){
  try{
    if(String(doc.getText())=='true'){
      SubmitForm();
    }else{
      alert(doc);
    };
  }catch(eX){
    confirm(eX.message);
  };
};
//==============================================================================





//alert('DEBUG: jegas.js Lives');
//==============================================================================
// END - Code by Jason P Sage, Jegas, LLC http://www.jegas.com
//==============================================================================



//==============================================================================
// DATE PICKER
//==============================================================================
//Javascript name: My Date Time Picker
//Date created: 16-Nov-2003 23:19
//Creator: TengYong Ng
//Website: http://www.rainforestnet.com
//Copyright (c) 2003 TengYong Ng
//FileName: DateTimePicker_css.js
//Version: 2.2.0
// Note: Permission given to use and modify this script in ANY kind of applications if
//       header lines are left unchanged.
//Permission is granted to redistribute and modify this javascript under the terms of the GNU General Public License 3.0.
//New Css style version added by Yvan Lavoie (Québec, Canada) 29-Jan-2009
//Formatted for JSLint compatibility by Labsmedia.com (30-Dec-2010)


// NOTE: Special permission granted to Jegas, LLC to inline this code
// to minimize server requests from author: TengYong Ng


//Global variables

var winCal;
var dtToday;
var Cal;
var MonthName;
var WeekDayName1;
var WeekDayName2;
var exDateTime;//Existing Date and Time
var selDate;//selected date. version 1.7
var calSpanID = "calBorder"; // span ID
var domStyle = null; // span DOM object with style
var cnLeft = "0";//left coordinate of calendar span
var cnTop = "0";//top coordinate of calendar span
var xpos = 0; // mouse x position
var ypos = 0; // mouse y position
var calHeight = 0; // calendar height
var CalWidth = 208;// calendar width
var CellWidth = 30;// width of day cell.
var TimeMode = 24;// TimeMode value. 12 or 24
var StartYear = 1990; //First Year in drop down year selection
var EndYear = 5; // The last year of pickable date. if current year is 2011, year after 2016 will not be pickable.
var CalPosOffsetX = 8; //X position offset relative to calendar icon, can be negative value
var CalPosOffsetY = 8; //Y position offset relative to calendar icon, can be negative value

//Configurable parameters

//var WindowTitle = "DateTime Picker";//Date Time Picker title.

var SpanBorderColor = "";//"#FFFFFF";//span border color
var SpanBgColor = "";//"#FFFFFF";//span background color
var WeekChar = 2;//number of character for week day. if 2 then Mo,Tu,We. if 3 then Mon,Tue,Wed.
var DateSeparator = "-";//Date Separator, you can change it to "-" if you want.
var ShowLongMonth = true;//Show long month name in Calendar header. example: "January".
var ShowMonthYear = true;//Show Month and Year in Calendar header.
var MonthYearColor = "#cc0033";//Font Color of Month and Year in Calendar header.
var WeekHeadColor = "#18861B";//var WeekHeadColor="#18861B";//Background Color in Week header.
var SundayColor = "#999999";//"#C0F64F";//var SundayColor="#C0F64F";//Background color of Sunday.
var SaturdayColor = "#999999";//"#C0F64F";//Background color of Saturday.
var WeekDayColor = "#000000";//"#FFEDA6"; //Background color of weekdays.
var FontColor = "white";//color of font in Calendar day cell.
var TodayColor = "#006000";//"#FFFF33";//var TodayColor="#FFFF33";//Background color of today.
var SelDateColor = "#8DD53C";//var SelDateColor = "#8DD53C";//Backgrond color of selected date in textbox.
var YrSelColor = "#cc0033";//color of font of Year selector.
var MthSelColor = "#cc0033";//color of font of Month selector if "MonthSelector" is "arrow".
var HoverColor = "#0000B0";//"#E0FF38"; //color when mouse move over.
var DisableColor = "#999966"; //color of disabled cell.
var ThemeBg = "";//Background image of Calendar window.
var CalBgColor = "gray";//Background color of Calendar window.
var PrecedeZero = true;//Preceding zero [true|false]
var MondayFirstDay = false;//true:Use Monday as first day; false:Sunday as first day. [true|false]  //added in version 1.7
var UseImageFiles = true;//Use image files with "arrows" and "close" button
var DisableBeforeToday = false; //Make date before today unclickable.


//use the Month and Weekday in your preferred language.

var MonthName = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
var WeekDayName1 = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
var WeekDayName2 = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];


//end Configurable parameters

//end Global variable


// Calendar prototype
function Calendar(pDate, pCtrl)
{

  //Properties
  this.Date = pDate.getDate();//selected date
  this.Month = pDate.getMonth();//selected month number
  this.Year = pDate.getFullYear();//selected year in 4 digits
  this.Hours = pDate.getHours();

  if (pDate.getMinutes() < 10)
  {
    this.Minutes = "0" + pDate.getMinutes();
  }
  else
  {
    this.Minutes = pDate.getMinutes();
  }

  if (pDate.getSeconds() < 10)
  {
    this.Seconds = "0" + pDate.getSeconds();
  }
  else
  {
    this.Seconds = pDate.getSeconds();
  }


  this.MyWindow = winCal;
  this.Ctrl = pCtrl;
  this.Format = "ddMMyyyy";
  this.Separator = DateSeparator;
  this.ShowTime = false;
  this.Scroller = "DROPDOWN";
  if (pDate.getHours() < 12)
  {
    this.AMorPM = "AM";
  }
  else
  {
    this.AMorPM = "PM";
  }

  this.ShowSeconds = true;
}

Calendar.prototype.GetMonthIndex = function (shortMonthName)
{
  for (var i = 0; i < 12; i += 1)
  {
    if (MonthName[i].substring(0, 3).toUpperCase() === shortMonthName.toUpperCase())
    {
      return i;
    }
  }
};

Calendar.prototype.IncYear = function ()
{
  Cal.Year += 1;
};

Calendar.prototype.DecYear = function ()
{
  Cal.Year -= 1;
};

Calendar.prototype.IncMonth = function ()
{
  Cal.Month += 1;
  if (Cal.Month >= 12)
  {
    Cal.Month = 0;
    Cal.IncYear();
  }
};

Calendar.prototype.DecMonth = function ()
{
  Cal.Month -= 1;
  if (Cal.Month < 0)
  {
    Cal.Month = 11;
    Cal.DecYear();
  }
};

Calendar.prototype.SwitchMth = function (intMth)
{
  Cal.Month = parseInt(intMth, 10);
};

Calendar.prototype.SwitchYear = function (intYear)
{
  Cal.Year = parseInt(intYear, 10);
};

Calendar.prototype.SetHour = function (intHour)
{
  var MaxHour,
  MinHour,
  HourExp = new RegExp("^\\d\\d"),
  SingleDigit = new RegExp("\\d");

  if (TimeMode === 24)
  {
    MaxHour = 23;
    MinHour = 0;
  }
  else if (TimeMode === 12)
  {
    MaxHour = 12;
    MinHour = 1;
  }
  else
  {
    alert("TimeMode can only be 12 or 24");
  }

  if ((HourExp.test(intHour) || SingleDigit.test(intHour)) && (parseInt(intHour, 10) > MaxHour))
  {
    intHour = MinHour;
  }

  else if ((HourExp.test(intHour) || SingleDigit.test(intHour)) && (parseInt(intHour, 10) < MinHour))
  {
    intHour = MaxHour;
  }

  if (SingleDigit.test(intHour))
  {
    intHour = "0" + intHour;
  }

  if (HourExp.test(intHour) && (parseInt(intHour, 10) <= MaxHour) && (parseInt(intHour, 10) >= MinHour))
  {
    if ((TimeMode === 12) && (Cal.AMorPM === "PM"))
    {
      if (parseInt(intHour, 10) === 12)
      {
        Cal.Hours = 12;
      }
      else
      {
        Cal.Hours = parseInt(intHour, 10) + 12;
      }
    }

    else if ((TimeMode === 12) && (Cal.AMorPM === "AM"))
    {
      if (intHour === 12)
      {
        intHour -= 12;
      }

      Cal.Hours = parseInt(intHour, 10);
    }

    else if (TimeMode === 24)
    {
      Cal.Hours = parseInt(intHour, 10);
    }
  }

};

Calendar.prototype.SetMinute = function (intMin)
{
  var MaxMin = 59,
  MinMin = 0,

  SingleDigit = new RegExp("\\d"),
  SingleDigit2 = new RegExp("^\\d{1}$"),
  MinExp = new RegExp("^\\d{2}$"),

  strMin = 0;

  if ((MinExp.test(intMin) || SingleDigit.test(intMin)) && (parseInt(intMin, 10) > MaxMin))
  {
    intMin = MinMin;
  }

  else if ((MinExp.test(intMin) || SingleDigit.test(intMin)) && (parseInt(intMin, 10) < MinMin))
  {
    intMin = MaxMin;
  }

  strMin = intMin + "";
  if (SingleDigit2.test(intMin))
  {
    strMin = "0" + strMin;
  }

  if ((MinExp.test(intMin) || SingleDigit.test(intMin)) && (parseInt(intMin, 10) <= 59) && (parseInt(intMin, 10) >= 0))
  {
    Cal.Minutes = strMin;
  }
};

Calendar.prototype.SetSecond = function (intSec)
{
  var MaxSec = 59,
  MinSec = 0,

  SingleDigit = new RegExp("\\d"),
  SingleDigit2 = new RegExp("^\\d{1}$"),
  SecExp = new RegExp("^\\d{2}$"),

  strSec = 0;

  if ((SecExp.test(intSec) || SingleDigit.test(intSec)) && (parseInt(intSec, 10) > MaxSec))
  {
    intSec = MinSec;
  }

  else if ((SecExp.test(intSec) || SingleDigit.test(intSec)) && (parseInt(intSec, 10) < MinSec))
  {
    intSec = MaxSec;
  }

  strSec = intSec + "";
  if (SingleDigit2.test(intSec))
  {
    strSec = "0" + strSec;
  }

  if ((SecExp.test(intSec) || SingleDigit.test(intSec)) && (parseInt(intSec, 10) <= 59) && (parseInt(intSec, 10) >= 0))
  {
    Cal.Seconds = strSec;
  }

};

Calendar.prototype.SetAmPm = function (pvalue)
{
  this.AMorPM = pvalue;
  if (pvalue === "PM")
  {
    this.Hours = parseInt(this.Hours, 10) + 12;
    if (this.Hours === 24)
    {
      this.Hours = 12;
    }
  }

  else if (pvalue === "AM")
  {
    this.Hours -= 12;
  }
};

Calendar.prototype.getShowHour = function ()
{
  var finalHour;

  if (TimeMode === 12)
  {
    if (parseInt(this.Hours, 10) === 0)
    {
      this.AMorPM = "AM";
      finalHour = parseInt(this.Hours, 10) + 12;
    }

    else if (parseInt(this.Hours, 10) === 12)
    {
      this.AMorPM = "PM";
      finalHour = 12;
    }

    else if (this.Hours > 12)
    {
      this.AMorPM = "PM";
      if ((this.Hours - 12) < 10)
      {
        finalHour = "0" + ((parseInt(this.Hours, 10)) - 12);
      }
      else
      {
        finalHour = parseInt(this.Hours, 10) - 12;
      }
    }
    else
    {
      this.AMorPM = "AM";
      if (this.Hours < 10)
      {
        finalHour = "0" + parseInt(this.Hours, 10);
      }
      else
      {
        finalHour = this.Hours;
      }
    }
  }

  else if (TimeMode === 24)
  {
    if (this.Hours < 10)
    {
      finalHour = "0" + parseInt(this.Hours, 10);
    }
    else
    {
      finalHour = this.Hours;
    }
  }

  return finalHour;
};

Calendar.prototype.getShowAMorPM = function ()
{
  return this.AMorPM;
};

Calendar.prototype.GetMonthName = function (IsLong)
{
  var Month = MonthName[this.Month];
  if (IsLong)
  {
    return Month;
  }
  else
  {
    return Month.substr(0, 3);
  }
};

Calendar.prototype.GetMonDays = function() { //Get number of days in a month

    var DaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (Cal.IsLeapYear()) {
        DaysInMonth[1] = 29;
    }

    return DaysInMonth[this.Month];
};

Calendar.prototype.IsLeapYear = function ()
{
  if ((this.Year % 4) === 0)
  {
    if ((this.Year % 100 === 0) && (this.Year % 400) !== 0)
    {
      return false;
    }
    else
    {
      return true;
    }
  }
  else
  {
    return false;
  }
};

Calendar.prototype.FormatDate = function (pDate)
{
  var MonthDigit = this.Month + 1;
  if (PrecedeZero === true)
  {
    if ((pDate < 10) && String(pDate).length===1) //length checking added in version 2.2
    {
      pDate = "0" + pDate;
    }
    if (MonthDigit < 10)
    {
      MonthDigit = "0" + MonthDigit;
    }
  }

  switch (this.Format.toUpperCase())
  {
    case "DDMMYYYY":
    return (pDate + DateSeparator + MonthDigit + DateSeparator + this.Year);
    case "DDMMMYYYY":
    return (pDate + DateSeparator + this.GetMonthName(false) + DateSeparator + this.Year);
    case "MMDDYYYY":
    return (MonthDigit + DateSeparator + pDate + DateSeparator + this.Year);
    case "MMMDDYYYY":
    return (this.GetMonthName(false) + DateSeparator + pDate + DateSeparator + this.Year);
    case "YYYYMMDD":
    return (this.Year + DateSeparator + MonthDigit + DateSeparator + pDate);
    case "YYMMDD":
    return (String(this.Year).substring(2, 4) + DateSeparator + MonthDigit + DateSeparator + pDate);
    case "YYMMMDD":
    return (String(this.Year).substring(2, 4) + DateSeparator + this.GetMonthName(false) + DateSeparator + pDate);
    case "YYYYMMMDD":
    return (this.Year + DateSeparator + this.GetMonthName(false) + DateSeparator + pDate);
    default:
    return (pDate + DateSeparator + (this.Month + 1) + DateSeparator + this.Year);
  }
};

// end Calendar prototype

function GenCell(pValue, pHighLight, pColor, pClickable)
{ //Generate table cell with value
  var PValue,
  PCellStr,
  vColor,
  PClickable,

  vHLstr1,//HighLight string
  vHLstr2,
  vTimeStr;

  if (!pValue)
  {
    PValue = "";
  }
  else
  {
    PValue = pValue;
  }

  if (pColor)
  {
    vColor = "bgcolor=\"" + pColor + "\"";
  }
  else
  {
    vColor = CalBgColor;
  }
  if (pHighLight)
  {
    vHLstr1 = "<font class='calR'>";
    vHLstr2 = "</font>";
  }
  else
  {
    vHLstr1 = "";
    vHLstr2 = "";
  }

  if (pClickable !== undefined)
  {
    PClickable = pClickable;
  }
  else
  {
    PClickable = true;
  }

  if (Cal.ShowTime)
  {
    vTimeStr = ' ' + Cal.Hours + ':' + Cal.Minutes;
    if (Cal.ShowSeconds)
    {
      vTimeStr += ':' + Cal.Seconds+' ';
    }
    if (TimeMode === 12)
    {
      vTimeStr += ' ' + Cal.AMorPM;
    }
  }

  else
  {
    vTimeStr = "";
  }

  if (PValue !== "")
  {
    if (PClickable === true)
    {
      PCellStr = "\n<td " + vColor + " class='calTD' style='cursor: pointer;' onmouseover='changeBorder(this, 0);' onmouseout=\"changeBorder(this, 1, '" + pColor + "');\" onClick=\"javascript:callback('" + Cal.Ctrl + "','" + Cal.FormatDate(PValue) + "');\">" + vHLstr1 + PValue + vHLstr2 + "</td>";
    }
    else
    {
      PCellStr = "\n<td " + vColor + " class='calTD' >" + vHLstr1 + PValue + vHLstr2 + "</td>";
    }
  }
  else
  {
    PCellStr = "\n<td " + vColor + " class='calTD'>&nbsp;</td>";
  }

  return PCellStr;
}

function RenderCssCal(bNewCal)
{

  if (typeof bNewCal === "undefined" || bNewCal !== true)
  {
    bNewCal = false;
  }
  var vCalHeader,
  vCalData,
  vCalTime = "",
  vCalClosing = "",
  winCalData = "",
  CalDate,

  i,
  j,

  SelectStr,
  vDayCount = 0,
  vFirstDay,

  WeekDayName = [],//Added version 1.7
  strCell,

  showHour,
  ShowArrows = false,
  HourCellWidth = "35px", //cell width with seconds.

  SelectAm,
  SelectPm,

  funcCalback,

  headID,
  e,
  cssStr,
  style,
  cssText,
  span;

  calHeight = 0; // reset the window height on refresh

  // Set the default cursor for the calendar

  winCalData = "<span style='cursor:auto;'>\n";

  if (ThemeBg === "")
  {
    CalBgColor = "bgcolor='" + WeekDayColor + "'";
  }
  vCalHeader = "<table " + CalBgColor + " background='" + ThemeBg + "' style=\"border:1px solid #000000; width:200px; \">\n";

  //Table for Month & Year Selector

  vCalHeader += "<tr>\n<td colspan='7'>\n<table border='0' width='200px' cellpadding='0' cellspacing='0'>\n<tr>\n";
  //******************Month and Year selector in dropdown list************************

  if (Cal.Scroller === "DROPDOWN")
  {
    vCalHeader += "<td align='center'><select name=\"MonthSelector\" onChange=\"javascript:Cal.SwitchMth(this.selectedIndex);RenderCssCal();\">\n";
    for (i = 0; i < 12; i += 1)
    {
      if (i === Cal.Month)
      {
        SelectStr = "Selected";
      }
      else
      {
        SelectStr = "";
      }
      vCalHeader += "<option " + SelectStr + " value=" + i + ">" + MonthName[i] + "</option>\n";

    }

    vCalHeader += "</select></td>\n";
    //Year selector

    vCalHeader += "<td align='center'><select name=\"YearSelector\" size=\"1\" onChange=\"javascript:Cal.SwitchYear(this.value);RenderCssCal();\">\n";
    for (i = StartYear; i <= (dtToday.getFullYear() + EndYear); i += 1)
    {
      if (i === Cal.Year)
      {
        SelectStr = 'selected="selected"';
      }
      else
      {
        SelectStr = '';
      }
      vCalHeader += "<option " + SelectStr + " value=" + i + ">" + i + "</option>\n";

    }

    vCalHeader += "</select></td>\n";
    calHeight += 30;
  }

  //******************End Month and Year selector in dropdown list*********************

  //******************Month and Year selector in arrow*********************************

  else if (Cal.Scroller === "ARROW")
  {

    if (UseImageFiles)
    {
      vCalHeader += "<td><img onmousedown='javascript:Cal.DecYear();RenderCssCal();' src='/jws/widgets/datetimepicker/images/cal_fastreverse.gif' width='13px' height='9' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td>\n";//Year scroller (decrease 1 year)
      vCalHeader += "<td><img onmousedown='javascript:Cal.DecMonth();RenderCssCal();' src='/jws/widgets/datetimepicker/images/cal_reverse.gif' width='13px' height='9' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td>\n";//Month scroller (decrease 1 month)
      vCalHeader += "<td width='70%' class='calR'><font color='" + YrSelColor + "'>" + Cal.GetMonthName(ShowLongMonth) + " " + Cal.Year + "</font></td>\n";//Month and Year
        vCalHeader += "<td><img onmousedown='javascript:Cal.IncMonth();RenderCssCal();' src='/jws/widgets/datetimepicker/images/cal_forward.gif' width='13px' height='9' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td>\n"; //Month scroller (increase 1 month)
        vCalHeader += "<td><img onmousedown='javascript:Cal.IncYear();RenderCssCal();' src='/jws/widgets/datetimepicker/images/cal_fastforward.gif' width='13px' height='9' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td>\n"; //Year scroller (increase 1 year)

      calHeight += 22;
    }
    else
    {
      vCalHeader += "<td><span id='dec_year' title='reverse year' onmousedown='javascript:Cal.DecYear();RenderCssCal();' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white; color:" + YrSelColor + "'>-</span></td>";//Year scroller (decrease 1 year)
      vCalHeader += "<td><span id='dec_month' title='reverse month' onmousedown='javascript:Cal.DecMonth();RenderCssCal();' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'>&lt;</span></td>\n";//Month scroller (decrease 1 month)
      vCalHeader += "<td width='70%' class='calR'><font color='" + YrSelColor + "'>" + Cal.GetMonthName(ShowLongMonth) + " " + Cal.Year + "</font></td>\n";//Month and Year
      vCalHeader += "<td><span id='inc_month' title='forward month' onmousedown='javascript:Cal.IncMonth();RenderCssCal();' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'>&gt;</span></td>\n";//Month scroller (increase 1 month)
      vCalHeader += "<td><span id='inc_year' title='forward year' onmousedown='javascript:Cal.IncYear();RenderCssCal();'  onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white; color:" + YrSelColor + "'>+</span></td>\n";//Year scroller (increase 1 year)
      calHeight += 22;
    }
  }

  vCalHeader += "</tr>\n</table>\n</td>\n</tr>\n";

  //******************End Month and Year selector in arrow******************************

  //Calendar header shows Month and Year
  if (ShowMonthYear && Cal.Scroller === "DROPDOWN")
  {
    vCalHeader += "<tr><td colspan='7' class='calR'>\n<font color='" + MonthYearColor + "'>" + Cal.GetMonthName(ShowLongMonth) + " " + Cal.Year + "</font>\n</td></tr>\n";
    calHeight += 19;
  }

  //Week day header

  vCalHeader += "<tr><td colspan=\"7\"><table cellspacing=1><tr>\n";
  if (MondayFirstDay === true)
  {
    WeekDayName = WeekDayName2;
  }
  else
  {
    WeekDayName = WeekDayName1;
  }
  for (i = 0; i < 7; i += 1)
  {
    vCalHeader += "<td bgcolor=" + WeekHeadColor + " width='" + CellWidth + "px' class='calTD'><font color='white'>" + WeekDayName[i].substr(0, WeekChar) + "</font></td>\n";
  }

  calHeight += 19;
  vCalHeader += "</tr>\n";
  //Calendar detail
  CalDate = new Date(Cal.Year, Cal.Month);
  CalDate.setDate(1);

  vFirstDay = CalDate.getDay();

  //Added version 1.7

  if (MondayFirstDay === true)
  {
    vFirstDay -= 1;
    if (vFirstDay === -1)
    {
      vFirstDay = 6;
    }
  }

  //Added version 1.7

  vCalData = "<tr>";
  calHeight += 19;
  for (i = 0; i < vFirstDay; i += 1)
  {
    vCalData = vCalData + GenCell();
    vDayCount = vDayCount + 1;
  }

  //Added version 1.7

  for (j = 1; j <= Cal.GetMonDays(); j += 1)
  {
    if ((vDayCount % 7 === 0) && (j > 1))
    {
      vCalData = vCalData + "\n<tr>";
    }

    vDayCount = vDayCount + 1;
    //added version 2.1.2
    if (DisableBeforeToday === true && ((j < dtToday.getDate()) && (Cal.Month === dtToday.getMonth()) && (Cal.Year === dtToday.getFullYear()) || (Cal.Month < dtToday.getMonth()) && (Cal.Year === dtToday.getFullYear()) || (Cal.Year < dtToday.getFullYear())))
    {
      strCell = GenCell(j, false, DisableColor, false);//Before today's date is not clickable
    }
    //if End Year + Current Year = Cal.Year. Disable.
    else if (Cal.Year > (dtToday.getFullYear()+EndYear))
    {
        strCell = GenCell(j, false, DisableColor, false);
    }
    else if ((j === dtToday.getDate()) && (Cal.Month === dtToday.getMonth()) && (Cal.Year === dtToday.getFullYear()))
    {
      strCell = GenCell(j, true, TodayColor);//Highlight today's date
    }
    else
    {
      if ((j === selDate.getDate()) && (Cal.Month === selDate.getMonth()) && (Cal.Year === selDate.getFullYear()))
      { //modified version 1.7
        strCell = GenCell(j, true, SelDateColor);
      }
      else
      {
        if (MondayFirstDay === true)
        {
          if (vDayCount % 7 === 0)
          {
            strCell = GenCell(j, false, SundayColor);
          }
          else if ((vDayCount + 1) % 7 === 0)
          {
            strCell = GenCell(j, false, SaturdayColor);
          }
          else
          {
            strCell = GenCell(j, null, WeekDayColor);
          }
        }
        else
        {
          if (vDayCount % 7 === 0)
          {
            strCell = GenCell(j, false, SaturdayColor);
          }
          else if ((vDayCount + 6) % 7 === 0)
          {
            strCell = GenCell(j, false, SundayColor);
          }
          else
          {
            strCell = GenCell(j, null, WeekDayColor);
          }
        }
      }
    }

    vCalData = vCalData + strCell;

    if ((vDayCount % 7 === 0) && (j < Cal.GetMonDays()))
    {
      vCalData = vCalData + "\n</tr>";
      calHeight += 19;
    }
  }

  // finish the table proper

  if (vDayCount % 7 !== 0)
  {
    while (vDayCount % 7 !== 0)
    {
      vCalData = vCalData + GenCell();
      vDayCount = vDayCount + 1;
    }
  }

  vCalData = vCalData + "\n</table></td></tr>";


  //Time picker
  if (Cal.ShowTime === true)
  {
    showHour = Cal.getShowHour();

    if (Cal.ShowSeconds === false && TimeMode === 24)
    {
      ShowArrows = true;
      HourCellWidth = "10px";
    }

    vCalTime = "\n<tr>\n<td colspan='7' align='center'><center>\n<table border='0' width='199px' cellpadding='0' cellspacing='2'>\n<tr>\n<td height='5px' width='" + HourCellWidth + "px'>&nbsp;</td>\n";

    if (ShowArrows && UseImageFiles) //this is where the up and down arrow control the hour.
    {
        vCalTime += "<td align='center'><table cellspacing='0' cellpadding='0' style='line-height:0pt'><tr><td><img onclick='nextStep(\"Hour\", \"plus\");' onmousedown='startSpin(\"Hour\", \"plus\");' onmouseup='stopSpin();' src='/jws/widgets/datetimepicker/images/cal_plus.gif' width='13px' height='9px' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td></tr><tr><td><img onclick='nextStep(\"Hour\", \"minus\");' onmousedown='startSpin(\"Hour\", \"minus\");' onmouseup='stopSpin();' src='/jws/widgets/datetimepicker/images/cal_minus.gif' width='13px' height='9px' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td></tr></table></td>\n";
    }

    vCalTime += "<td align='center' width='22px'><input type='text' name='hour' maxlength=2 size=1 style=\"WIDTH:22px\" value=" + showHour + " onkeyup=\"javascript:Cal.SetHour(this.value)\">";
    vCalTime += "</td><td align='center' style='font-weight:bold;'>:</td><td align='center' width='22px'>";
    vCalTime += "<input type='text' name='minute' maxlength=2 size=1 style=\"WIDTH: 22px\" value=" + Cal.Minutes + " onkeyup=\"javascript:Cal.SetMinute(this.value)\">";

    if (Cal.ShowSeconds)
    {
        vCalTime += "</td><td align='center' style='font-weight:bold;'>:</td><td align='center' width='22px'>";
      vCalTime += "<input type='text' name='second' maxlength=2 size=1 style=\"WIDTH: 22px\" value=" + Cal.Seconds + " onkeyup=\"javascript:Cal.SetSecond(parseInt(this.value,10))\">";
    }

    if (TimeMode === 12)
    {
      SelectAm = (Cal.AMorPM === "AM") ? "Selected" : "";
      SelectPm = (Cal.AMorPM === "PM") ? "Selected" : "";

      vCalTime += "</td><td>";
      vCalTime += "<select name=\"ampm\" onChange=\"javascript:Cal.SetAmPm(this.options[this.selectedIndex].value);\">\n";
      vCalTime += "<option " + SelectAm + " value=\"AM\">AM</option>";
      vCalTime += "<option " + SelectPm + " value=\"PM\">PM<option>";
      vCalTime += "</select>";
    }

    if (ShowArrows && UseImageFiles) //this is where the up and down arrow to change the "Minute".
    {
        vCalTime += "</td>\n<td align='center'><table cellspacing='0' cellpadding='0' style='line-height:0pt'><tr><td><img onclick='nextStep(\"Minute\", \"plus\");' onmousedown='startSpin(\"Minute\", \"plus\");' onmouseup='stopSpin();' src='/jws/widgets/datetimepicker/images/cal_plus.gif' width='13px' height='9px' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td></tr><tr><td><img onmousedown='startSpin(\"Minute\", \"minus\");' onmouseup='stopSpin();' onclick='nextStep(\"Minute\",\"minus\");' src='/jws/widgets/datetimepicker/images/cal_minus.gif' width='13px' height='9px' onmouseover='changeBorder(this, 0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td></tr></table>";
    }

    vCalTime += "</td>\n<td align='right' valign='bottom' width='" + HourCellWidth + "px'></td></tr>";
    vCalTime += "<tr><td colspan='7' align='center'><input style='width:60px;font-size:12px;' onClick='javascript:closewin(\"" + Cal.Ctrl + "\");'  type=\"button\" value=\"OK\">&nbsp;<input style='width:60px;font-size:12px;' onClick='javascript: winCal.style.visibility = \"hidden\"' type=\"button\" value=\"Cancel\"></td></tr>";
  }
  else //if not to show time.
  {
      vCalTime += "\n<tr>\n<td colspan='7' align='right'>";
      //close button
      if (UseImageFiles) {
          vCalClosing += "<img onmousedown='javascript:closewin(\"" + Cal.Ctrl + "\"); stopSpin();' src='/jws/widgets/datetimepicker/images/cal_close.gif' width='16px' height='14px' onmouseover='changeBorder(this,0)' onmouseout='changeBorder(this, 1)' style='border:1px solid white'></td>";
      }
      else {
          vCalClosing += "<span id='close_cal' title='close'onmousedown='javascript:closewin(\"" + Cal.Ctrl + "\");stopSpin();' onmouseover='changeBorder(this, 0)'onmouseout='changeBorder(this, 1)' style='border:1px solid white; font-family: Arial;font-size: 10pt;'>x</span></td>";
      }
      vCalClosing += "</tr>";
  }



  vCalClosing += "</table></center>\n</td>\n</tr>";
  calHeight += 31;
  vCalClosing += "\n</table>\n</span>";

  //end time picker
  funcCalback = "function callback(id, datum) {\n";
  funcCalback += " var CalId = document.getElementById(id); if (datum=== 'undefined') { var d = new Date(); datum = d.getDate() + '/' +(d.getMonth()+1) + '/' + d.getFullYear(); } window.calDatum=datum;CalId.value=datum;\n";
  funcCalback += " if (Cal.ShowTime) {\n";
  funcCalback += " CalId.value+=' '+Cal.getShowHour()+':'+Cal.Minutes;\n";
  funcCalback += " if (Cal.ShowSeconds)\n  CalId.value+=':'+Cal.Seconds;\n";
  funcCalback += " if (TimeMode === 12)\n  CalId.value+=' '+Cal.getShowAMorPM();\n";
  funcCalback += "}\n winCal.style.visibility='hidden';\n}\n";


  // determines if there is enough space to open the cal above the position where it is called
  if (ypos > calHeight)
  {
    ypos = ypos - calHeight;
  }

  if (!winCal)
  {
    headID = document.getElementsByTagName("head")[0];

    // add javascript function to the span cal
    e = document.createElement("script");
    e.type = "text/javascript";
    e.language = "javascript";
    e.text = funcCalback;
    headID.appendChild(e);
    // add stylesheet to the span cal

    cssStr = ".calTD {font-family: verdana; font-size: 12px; text-align: center; border:0 }\n";
    //cssStr+= ".calR {font-family: verdana; font-size: 12px; text-align: center; font-weight: bold; color: red;}"
    cssStr += ".calR {font-family: verdana; font-size: 12px; text-align: center; font-weight: bold;}";

    style = document.createElement("style");
    style.type = "text/css";
    style.rel = "stylesheet";
    if (style.styleSheet)
    { // IE
      style.styleSheet.cssText = cssStr;
    }

    else
    { // w3c
      cssText = document.createTextNode(cssStr);
      style.appendChild(cssText);
    }

    headID.appendChild(style);
    // create the outer frame that allows the cal. to be moved
    span = document.createElement("span");
    span.id = calSpanID;
    span.style.position = "absolute";
    span.style.left = (xpos + CalPosOffsetX) + 'px';
    span.style.top = (ypos - CalPosOffsetY) + 'px';
    span.style.width = CalWidth + 'px';
    span.style.border = "solid 2pt " + SpanBorderColor;
    span.style.padding = "0pt";
    span.style.cursor = "move";
    span.style.backgroundColor = SpanBgColor;
    span.style.zIndex = 100;
    document.body.appendChild(span);
    winCal = document.getElementById(calSpanID);
  }

  else
  {
    winCal.style.visibility = "visible";
    winCal.style.Height = calHeight;

    // set the position for a new calendar only
    if (bNewCal === true)
    {
      winCal.style.left = (xpos + CalPosOffsetX) + 'px';
      winCal.style.top = (ypos - CalPosOffsetY) + 'px';
    }
  }

  winCal.innerHTML = winCalData + vCalHeader + vCalData + vCalTime + vCalClosing;
  return true;
}


function NewCssCal(pCtrl, pFormat, pScroller, pShowTime, pTimeMode, pHideSeconds)
{
  // get current date and time

  dtToday = new Date();
  Cal = new Calendar(dtToday);

  if (pShowTime !== undefined)
  {
      if (pShowTime) {
          Cal.ShowTime = true;
      }
      else {
          Cal.ShowTime = false;
      }


    if (pTimeMode)
    {
      pTimeMode = parseInt(pTimeMode, 10);
    }
    if (pTimeMode === 12 || pTimeMode === 24)
    {
      TimeMode = pTimeMode;
    }
    else
    {
      TimeMode = 24;
    }

    if (pHideSeconds !== undefined)
    {
      if (pHideSeconds)
      {
        Cal.ShowSeconds = false;
      }
      else
      {
        Cal.ShowSeconds = true;
      }
    }

    else
    {
      Cal.ShowSeconds = false;
    }

  }

  if (pCtrl !== undefined)
  {
    Cal.Ctrl = pCtrl;
  }

  if (pFormat !== undefined)
  {
    Cal.Format = pFormat.toUpperCase();
  }
  else
  {
    Cal.Format = "MMDDYYYY";
  }

  if (pScroller !== undefined)
  {
    if (pScroller.toUpperCase() === "ARROW")
    {
      Cal.Scroller = "ARROW";
    }
    else
    {
      Cal.Scroller = "DROPDOWN";
    }
  }

  exDateTime = document.getElementById(pCtrl).value; //Existing Date Time value in textbox.

  if (exDateTime)
  { //Parse existing Date String
    var Sp1 = exDateTime.indexOf(DateSeparator, 0),//Index of Date Separator 1
    Sp2 = exDateTime.indexOf(DateSeparator, parseInt(Sp1, 10) + 1),//Index of Date Separator 2
    tSp1,//Index of Time Separator 1
    tSp2,//Index of Time Separator 2
    strMonth,
    strDate,
    strYear,
    intMonth,
    YearPattern,
    strHour,
    strMinute,
    strSecond,
    winHeight,
    offset = parseInt(Cal.Format.toUpperCase().lastIndexOf("M"), 10) - parseInt(Cal.Format.toUpperCase().indexOf("M"), 10) - 1,
    strAMPM = "";
    //parse month


    if (Cal.Format.toUpperCase() === "DDMMYYYY" || Cal.Format.toUpperCase() === "DDMMMYYYY")
    {
      if (DateSeparator === "")
      {
        strMonth = exDateTime.substring(2, 4 + offset);
        strDate = exDateTime.substring(0, 2);
        strYear = exDateTime.substring(4 + offset, 8 + offset);
      }
      else
      {
        if (exDateTime.indexOf("D*") !== -1)
        {   //DTG
          strMonth = exDateTime.substring(8, 11);
          strDate  = exDateTime.substring(0, 2);
          strYear  = "20" + exDateTime.substring(11, 13);  //Hack, nur für Jahreszahlen ab 2000

        }
        else
        {
          strMonth = exDateTime.substring(Sp1 + 1, Sp2);
          strDate = exDateTime.substring(0, Sp1);
          strYear = exDateTime.substring(Sp2 + 1, Sp2 + 5);
        }
      }

    }

    else if (Cal.Format.toUpperCase() === "MMDDYYYY" || Cal.Format.toUpperCase() === "MMMDDYYYY")
    {

      if (DateSeparator === "")
      {
        strMonth = exDateTime.substring(0, 2 + offset);
        strDate = exDateTime.substring(2 + offset, 4 + offset);
        strYear = exDateTime.substring(4 + offset, 8 + offset);
      }

      else
      {

        strMonth = exDateTime.substring(0, Sp1);
        strDate = exDateTime.substring(Sp1 + 1, Sp2);
        strYear = exDateTime.substring(Sp2 + 1, Sp2 + 5);
      }

    }

    else if (Cal.Format.toUpperCase() === "YYYYMMDD" || Cal.Format.toUpperCase() === "YYYYMMMDD")
    {

      if (DateSeparator === "")
      {
        strMonth = exDateTime.substring(4, 6 + offset);
        strDate = exDateTime.substring(6 + offset, 8 + offset);
        strYear = exDateTime.substring(0, 4);
      }

      else
      {
        strMonth = exDateTime.substring(Sp1 + 1, Sp2);
        strDate = exDateTime.substring(Sp2 + 1, Sp2 + 3);
        strYear = exDateTime.substring(0, Sp1);
      }

    }

    else if (Cal.Format.toUpperCase() === "YYMMDD" || Cal.Format.toUpperCase() === "YYMMMDD")
    {

      if (DateSeparator === "")
      {
        strMonth = exDateTime.substring(2, 4 + offset);
        strDate = exDateTime.substring(4 + offset, 6 + offset);
        strYear = exDateTime.substring(0, 2);
      }

      else
      {
        strMonth = exDateTime.substring(Sp1 + 1, Sp2);
        strDate = exDateTime.substring(Sp2 + 1, Sp2 + 3);
        strYear = exDateTime.substring(0, Sp1);
      }

    }

    if (isNaN(strMonth))
    {
      intMonth = Cal.GetMonthIndex(strMonth);
    }
    else
    {
      intMonth = parseInt(strMonth, 10) - 1;
    }

    if ((parseInt(intMonth, 10) >= 0) && (parseInt(intMonth, 10) < 12))
    {
      Cal.Month = intMonth;
    }

    //end parse month

    //parse year
    YearPattern = /^\d{4}$/;
    if (YearPattern.test(strYear)) {
        Cal.Year = parseInt(strYear, 10);
    }
    //end parse year

    //parse Date
    if ((parseInt(strDate, 10) <= Cal.GetMonDays()) && (parseInt(strDate, 10) >= 1)) {
      Cal.Date = strDate;
    }
    //end parse Date



    //parse time

    if (Cal.ShowTime === true)
    {

      //parse AM or PM

      if (TimeMode === 12)
      {
        strAMPM = exDateTime.substring(exDateTime.length - 2, exDateTime.length);
        Cal.AMorPM = strAMPM;
      }

      tSp1 = exDateTime.indexOf(":", 0);
      tSp2 = exDateTime.indexOf(":", (parseInt(tSp1, 10) + 1));
      if (tSp1 > 0)
      {

        strHour = exDateTime.substring(tSp1, tSp1 - 2);
        Cal.SetHour(strHour);

        strMinute = exDateTime.substring(tSp1 + 1, tSp1 + 3);
        Cal.SetMinute(strMinute);

        strSecond = exDateTime.substring(tSp2 + 1, tSp2 + 3);
        Cal.SetSecond(strSecond);

      }
      else if (exDateTime.indexOf("D*") !== -1)
      {   //DTG
        strHour = exDateTime.substring(2, 4);
        Cal.SetHour(strHour);
        strMinute = exDateTime.substring(4, 6);
        Cal.SetMinute(strMinute);

      }
    }

  }

  selDate = new Date(Cal.Year, Cal.Month, Cal.Date);//version 1.7
  RenderCssCal(true);
}

function closewin(id) {

    if (Cal.ShowTime === true) {

        if (DisableBeforeToday === true && ((Cal.Date < dtToday.getDate()) && (Cal.Month === dtToday.getMonth()) && (Cal.Year === dtToday.getFullYear()) || (Cal.Month < dtToday.getMonth()) && (Cal.Year === dtToday.getFullYear()) || (Cal.Year < dtToday.getFullYear()))) {
        }
        else if (Cal.Year > (dtToday.getFullYear() + EndYear)) {
        }
        else {
            callback(id, Cal.FormatDate(Cal.Date)); //added in version 2.2.0
        }
    }
  var CalId = document.getElementById(id);

  CalId.focus();
  winCal.style.visibility = 'hidden';
}

function changeBorder(element, col, oldBgColor)
{
  if (col === 0)
  {
    element.style.background = HoverColor;
    element.style.borderColor = "black";
    element.style.cursor = "pointer";
  }

  else
  {
    if (oldBgColor)
    {
      element.style.background = oldBgColor;
    }
    else
    {
      element.style.background = "white";
    }
    element.style.borderColor = "white";
    element.style.cursor = "auto";
  }
}


function pickIt(evt)
{
  var objectID,
  dom,
  de,
  b;
  // accesses the element that generates the event and retrieves its ID
  if (document.addEventListener)
  { // w3c
    objectID = evt.target.id;
    if (objectID.indexOf(calSpanID) !== -1)
    {
      dom = document.getElementById(objectID);
      cnLeft = evt.pageX;
      cnTop = evt.pageY;

      if (dom.offsetLeft)
      {
        cnLeft = (cnLeft - dom.offsetLeft);
        cnTop = (cnTop - dom.offsetTop);
      }
    }

    // get mouse position on click
    xpos = (evt.pageX);
    ypos = (evt.pageY);
  }

  else
  { // IE
    objectID = event.srcElement.id;
    cnLeft = event.offsetX;
    cnTop = (event.offsetY);

    // get mouse position on click
    de = document.documentElement;
    b = document.body;

    xpos = event.clientX + (de.scrollLeft || b.scrollLeft) - (de.clientLeft || 0);
    ypos = event.clientY + (de.scrollTop || b.scrollTop) - (de.clientTop || 0);
  }

  // verify if this is a valid element to pick
  if (objectID.indexOf(calSpanID) !== -1)
  {
    domStyle = document.getElementById(objectID).style;
  }

  if (domStyle)
  {
    domStyle.zIndex = 100;
    return false;
  }

  else
  {
    domStyle = null;
    return;
  }
}



function dragIt(evt)
{
  if (domStyle)
  {
    if (document.addEventListener)
    { //for IE
      domStyle.left = (event.clientX - cnLeft + document.body.scrollLeft) + 'px';
      domStyle.top = (event.clientY - cnTop + document.body.scrollTop) + 'px';
    }
    else
    {  //Firefox
      domStyle.left = (evt.clientX - cnLeft + document.body.scrollLeft) + 'px';
      domStyle.top = (evt.clientY - cnTop + document.body.scrollTop) + 'px';
    }
  }
}

// performs a single increment or decrement
function nextStep(whatSpinner, direction)
{
  if (whatSpinner === "Hour")
  {
    if (direction === "plus")
    {
      Cal.SetHour(Cal.Hours + 1);
      RenderCssCal();
    }
    else if (direction === "minus")
    {
      Cal.SetHour(Cal.Hours - 1);
      RenderCssCal();
    }
  }
  else if (whatSpinner === "Minute")
  {
    if (direction === "plus")
    {
      Cal.SetMinute(parseInt(Cal.Minutes, 10) + 1);
      RenderCssCal();
    }
    else if (direction === "minus")
    {
      Cal.SetMinute(parseInt(Cal.Minutes, 10) - 1);
      RenderCssCal();
    }
  }

}

// starts the time spinner
function startSpin(whatSpinner, direction)
{
  document.thisLoop = setInterval(function ()
  {
    nextStep(whatSpinner, direction);
  }, 125); //125 ms
}

//stops the time spinner
function stopSpin()
{
  clearInterval(document.thisLoop);
}

function dropIt()
{
  stopSpin();

  if (domStyle)
  {
    domStyle = null;
  }
}

// Default events configuration

document.onmousedown = pickIt;
document.onmousemove = dragIt;
document.onmouseup = dropIt;

//==============================================================================
// DATE PICKER
//==============================================================================








