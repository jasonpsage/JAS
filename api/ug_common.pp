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

// !@! - Find Category Routine Definitions
// !#! - Find Categorized Routine Source Code


//=============================================================================
{ }
// This file is a collection of fairly lowlevel but useful functions used
// throughout the Jegas codebase.
Unit ug_common;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$MACRO ON}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_common.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               Interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
uses 
//=============================================================================
  ug_misc
  ,sysutils
  ,variants
;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
// This variable is for the maximum value of the native unsigned integer value
// the machine is designed for. This is referred to as the ENDIAN. 32 bit is
// one common one, as is 64. SO... rather than use the constant all over which
// gets compiled into EXE and subsequently ram all over, a variable is a
// way to get the same results with less waste. The speed is the same but
// suffers, like all memory operations, on whether the data being moved is
// aligned in memory or not, what kind of data, read ahead cache invalidations,
// etc.
var UINTMAX: UINT;
{}
const
   READ_ONLY = 0; {< possible value for freepascal's internal filemode variable. }
   WRITE_ONLY = 1; {< possible value for freepascal's internal filemode variable. }
   READ_WRITE = 2; {< possible value for freepascal's internal filemode variable. }

Const
Sys_EPERM       = 1;    {< Operation not permitted }
Sys_ENOENT      = 2;    {< No such file or directory }
Sys_ESRCH       = 3;    {< No such process }
Sys_EINTR       = 4;    {< Interrupted system call }
Sys_EIO         = 5;    {< I/O error }
Sys_ENXIO       = 6;    {< No such device or address }
Sys_E2BIG       = 7;    {< Arg list too long }
Sys_ENOEXEC     = 8;    {< Exec format error }
Sys_EBADF       = 9;    {< Bad file number }
Sys_ECHILD      = 10;   {< No child processes }
Sys_EAGAIN      = 11;   {< Try again }
Sys_ENOMEM      = 12;   {< Out of memory }
Sys_EACCES      = 13;   {< Permission denied }
Sys_EACCESS     = 13;   {< Permission denied }
Sys_EFAULT      = 14;   {< Bad address }
Sys_ENOTBLK     = 15;   {< Block device required, NOT POSIX! }
Sys_EBUSY       = 16;   {< Device or resource busy }
Sys_EEXIST      = 17;   {< File exists }
Sys_EXDEV       = 18;   {< Cross-device link }
Sys_ENODEV      = 19;   {< No such device }
Sys_ENOTDIR     = 20;   {< Not a directory }
Sys_EISDIR      = 21;   {< Is a directory }
Sys_EINVAL      = 22;   {< Invalid argument }
Sys_ENFILE      = 23;   {< File table overflow }
Sys_EMFILE      = 24;   {< Too many open files }
Sys_ENOTTY      = 25;   {< Not a typewriter }
Sys_ETXTBSY     = 26;   {< Text file busy. The new process was
a pure procedure (shared text) file which was
open for writing by another process, or file
which was open for writing by another process,
or while the pure procedure file was being
executed an open(2) call requested write access
requested write access.}
Sys_EFBIG       = 27;   {< File too large }
Sys_ENOSPC      = 28;   {< No space left on device }
Sys_ESPIPE      = 29;   {< Illegal seek }
Sys_EROFS       = 30;   {< Read-only file system }
Sys_EMLINK      = 31;   {< Too many links }
Sys_EPIPE       = 32;   {< Broken pipe }
Sys_EDOM        = 33;   {< Math argument out of domain of func }
Sys_ERANGE      = 34;   {< Math result not representable }
Sys_EDEADLK     = 35;   {< Resource deadlock would occur }
Sys_ENAMETOOLONG= 36;   {< File name too long }
Sys_ENOLCK      = 37;   {< No record locks available }
Sys_ENOSYS      = 38;   {< Function not implemented }
Sys_ENOTEMPTY= 39;      {< Directory not empty }
Sys_ELOOP       = 40;   {< Too many symbolic links encountered }
Sys_EWOULDBLOCK = Sys_EAGAIN;   {< Operation would block }
Sys_ENOMSG      = 42;   {< No message of desired type }
Sys_EIDRM       = 43;   {< Identifier removed }
Sys_ECHRNG      = 44;   {< Channel number out of range }
Sys_EL2NSYNC= 45;       {< Level 2 not synchronized }
Sys_EL3HLT      = 46;   {< Level 3 h a l t e d }
Sys_EL3RST      = 47;   {< Level 3 reset }
Sys_ELNRNG      = 48;   {< Link number out of range }
Sys_EUNATCH     = 49;   {< Protocol driver not attached }
Sys_ENOCSI      = 50;   {< No CSI structure available }
Sys_EL2HLT      = 51;   {< Level 2 h a l t e d }
Sys_EBADE       = 52;   {< Invalid exchange }
Sys_EBADR       = 53;   {< Invalid request descriptor }
Sys_EXFULL      = 54;   {< Exchange full }
Sys_ENOANO      = 55;   {< No anode }
Sys_EBADRQC     = 56;   {< Invalid request code }
Sys_EBADSLT     = 57;   {< Invalid slot }
Sys_EDEADLOCK   = 58;   {< File locking deadlock error }
Sys_EBFONT      = 59;   {< Bad font file format }
Sys_ENOSTR      = 60;   {< Device not a stream }
Sys_ENODATA     = 61;   {< No data available }
Sys_ETIME       = 62;   {< Timer expired }
Sys_ENOSR       = 63;   {< Out of streams resources }
Sys_ENONET      = 64;   {< Machine is not on the network }
Sys_ENOPKG      = 65;   {< Package not installed }
Sys_EREMOTE     = 66;   {< Object is remote }
Sys_ENOLINK     = 67;   {< Link has been severed }
Sys_EADV        = 68;   {< Advertise error }
Sys_ESRMNT      = 69;   {< Srmount error }
Sys_ECOMM       = 70;   {< Communication error on send }
Sys_EPROTO      = 71;   {< Protocol error }
Sys_EMULTIHOP= 72;      {< Multihop attempted }
Sys_EDOTDOT     = 73;   {< RFS specific error }
Sys_EBADMSG     = 74;   {< Not a data message }
Sys_EOVERFLOW= 75;      {< Value too large for defined data type }
Sys_ENOTUNIQ= 76;       {< Name not unique on network }
Sys_EBADFD      = 77;   {< File descriptor in bad state }
Sys_EREMCHG     = 78;   {< Remote address changed }
Sys_ELIBACC     = 79;   {< Can not access a needed shared library }
Sys_ELIBBAD     = 80;   {< Accessing a corrupted shared library }
Sys_ELIBSCN     = 81;   {< .lib section in a.out corrupted }
Sys_ELIBMAX     = 82;   {< Attempting to link in too many shared libraries }
Sys_ELIBEXEC= 83;       {< Cannot exec a shared library directly }
Sys_EILSEQ      = 84;   {< Illegal byte sequence }
Sys_ERESTART= 85;       {< Interrupted system call should be restarted }
Sys_ESTRPIPE= 86;       {< Streams pipe error }
Sys_EUSERS      = 87;   {< Too many users }
Sys_ENOTSOCK= 88;       {< Socket operation on non-socket }
Sys_EDESTADDRREQ= 89;   {< Destination address required }
Sys_EMSGSIZE= 90;       {< Message too long }
Sys_EPROTOTYPE= 91;     {< Protocol wrong type for socket }
Sys_ENOPROTOOPT= 92;    {< Protocol not available }
Sys_EPROTONOSUPPORT= 93;{< Protocol not supported }
Sys_ESOCKTNOSUPPORT= 94;{< Socket type not supported }
Sys_EOPNOTSUPP= 95;     {< Operation not supported on transport endpoint }
Sys_EPFNOSUPPORT= 96;   {< Protocol family not supported }
Sys_EAFNOSUPPORT= 97;   {< Address family not supported by protocol }
Sys_EADDRINUSE= 98;     {< Address already in use }
Sys_EADDRNOTAVAIL= 99;  {< Cannot assign requested address }
Sys_ENETDOWN= 100;      {< Network is down }
Sys_ENETUNREACH= 101;   {< Network is unreachable }
Sys_ENETRESET= 102;     {< Network dropped connection because of reset }
Sys_ECONNABORTED= 103;  {< Software caused connection abort }
Sys_ECONNRESET= 104;    {< Connection reset by peer }
Sys_ENOBUFS     = 105;  {< No buffer space available }
Sys_EISCONN     = 106;  {< Transport endpoint is already connected }
Sys_ENOTCONN= 107;      {< Transport endpoint is not connected }
Sys_ESHUTDOWN= 108;     {< Cannot send after transport endpoint shutdown }
Sys_ETOOMANYREFS= 109;  {< Too many references: cannot splice }
Sys_ETIMEDOUT= 110;     {< Connection timed out }
Sys_ECONNREFUSED= 111;  {< Connection refused }
Sys_EHOSTDOWN= 112;     {< Host is down }
Sys_EHOSTUNREACH= 113;  {< No route to host }
Sys_EALREADY= 114;      {< Operation already in progress }
Sys_EINPROGRESS= 115;   {< Operation now in progress }
Sys_ESTALE      = 116;  {< Stale NFS file handle }
Sys_EUCLEAN     = 117;  {< Structure needs cleaning }
Sys_ENOTNAM     = 118;  {< Not a XENIX named type file }
Sys_ENAVAIL     = 119;  {< No XENIX semaphores available }
Sys_EISNAM      = 120;  {< Is a named type file }
Sys_EREMOTEIO= 121;     {< Remote I/O error }
Sys_EDQUOT      = 122;  {< Quota exceeded }




//=============================================================================
Const
//=============================================================================
{}
// Note: Two Letter Code Designations from ISO 639
// These are mostly found in JAS.
cnLANG_ALL = 0; {< Used as the Ordinal value to use in ixx_jegas_macros.pp in the LANGUAGES_TO_INCLUDE define which determines what languages to compile into the binary. Either ALL or select a specific language. }
cnLANG_ENGLISH = 1; {< English Language Indicator - Default Language }
//=============================================================================



const
  PI = 3.14159265358979323846264338327950288419716939937510582097;
  cnMeter =1.0;
  cnMillimeters=1000.0;
  cnCentimeters=100.0;
  cnFeet=3.28084;
  cnYards=1.09361;
  cnMiles=0.00062;
  cnInches=39.3701;
  cnKilometers=0.001;
  cnOneMeterPerMilliSecond_Is_MilesPerHour=2236.93629;
  //----------------------------------------------------------------------------
  // Time Conversions based on 1 Second
  //----------------------------------------------------------------------------
  {}
  cnMilliseconds=0.001;
  cnMillisecondsPerHour=216000000;
  cnSecond=1;
  cnSecondsPerHour=216000;
  cnHoursPerDay=24;
  cnMinutes=60;
  cnHours=3600;
  cnDays=86400;
  //----------------------------------------------------------------------------



//=============================================================================
Const
//=============================================================================
{}
  cs_HEXVALUES                        = '0123456789ABCDEF';{< used for manipulating and converting hexadecimal values.}

  // Begin--------------------------------------------------------- Bit Values
  {}
  B00       =           1;  //< Bit  0
  B01       =           2;  //< Bit  1
  B02       =           4;  //< Bit  2
  B03       =           8;  //< Bit  3
  B04       =          16;  //< Bit  4 
  B05       =          32;  //< Bit  5
  B06       =          64;  //< Bit  6
  B07       =         128;  //< Bit  7
  
  B08       =         256;  //< Bit  8
  B09       =         512;  //< Bit  9
  B10       =        1024;  //< Bit 10
  B11       =        2048;  //< Bit 11
  B12       =        4096;  //< Bit 12
  B13       =        8192;  //< Bit 13
  B14       =       16384;  //< Bit 14
  B15       =       32768;  //< Bit 15
  {}
  B16       =       65536;  //< Bit 16
  B17       =      131072;  //< Bit 17
  B18       =      262144;  //< Bit 18
  B19       =      524288;  //< Bit 19
  B20       =     1048576;  //< Bit 20
  B21       =     2097152;  //< Bit 21
  B22       =     4194304;  //< Bit 22
  B23       =     8388608;  //< Bit 23
  
  B24       =    16777216;  //< Bit 24
  B25       =    33554432;  //< Bit 25
  B26       =    67108864;  //< Bit 26
  B27       =   134217728;  //< Bit 27
  B28       =   268435456;  //< Bit 28
  B29       =   536870912;  //< Bit 29
  B30       =  1073741824;  //< Bit 30
  B31       =  2147483648;  //< Bit 31
  {}
  B32       =  4294967296;  //< Bit 32
  B33       =  8589934592;  //< Bit 33
  B34       = 17179869184;  //< Bit 34
  B35       = 34359738368;  //< bit 35
  B36       = 68719476736;  //< bit 36
  B37       = 137438953472; //< bit 37
  B38       = 274877906944; //< bit 38
  B39       = 549755813888; //< bit 39

  B40       = 1099511627776; //< bit 40
  B41       = 2199023255552; //< bit 41
  B42       = 4398046511104; //< bit 42
  B43       = 8796093022208; //< bit 43
  B44       = 17592186044416; //< bit 44
  B45       = 35184372088832; //< bit 45
  B46       = 70368744177664; //< bit 46
  B47       = 140737488355328; //< bit 47
  {}
  B48       = 281474976710656; //< bit 48
  B49       = 562949953421312; //< bit 49
  B50       =  1125899906842620; //< bit 50
  B51       =  2251799813685250; //< bit 51
  B52       =  4503599627370500; //< bit 52
  B53       =  9007199254740990; //< bit 53
  B54       = 18014398509482000; //< bit 54
  B55       = 36028797018964000; //< bit 55
  
  B56       = 72057594037927900; //< bit 56
  B57       = 144115188075856000; //< bit 57
  B58       = 288230376151712000; //< bit 58
  B59       = 576460752303424000; //< bit 59
  B60       = 1152921504606850000; //< bit 60
  B61       = 2305843009213690000; //< bit 61
  B62       = 4611686018427390000; //< bit 62
  B63       = 9223372036854780000; //< bit 63
  {}
  // End  --------------------------------------------------------- Bit Values

  // Begin ------------------------------------Sample Bit Wise Constants
  //                           = b31+b30+b29+b28+b27+b26+b25+b24+b23+b22+b21+b20+b19+b18+b17+b16+b15+b14+b13+b12+b11+b10+b09+b08+b07+b06+b05+b04+b03+b02+b01+b00
  //                           = 000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000
  //                            |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  //                            | 31| 30| 29| 28| 27| 26| 25| 24| 23| 22| 21| 20| 19| 18| 17| 16| 15| 14| 13| 12| 11| 10| 9 |  8|  7|  6|  5|  4|  3|  2|  1|  0|
  //CONSTANTNAME                 = 000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000+000;//CONSTANTNAME
  // End --------------------------------------Sample Bit Wise Constants

  // BEGIN ----------------- Maximum Unsigned Integer Values based on Machine Endian
  //       Note: Rahter than use this constant everywhere, it would be more
  //       space saving to use a variable.
  {$IFDEF CPU64}
  const cnUINTMax =  18446744073709551615 ; //< [21] indicates the returned index is not to be used. Its the maximum value a 64bit unsigned number can hold.
  {$ELSE}
  const cnUINTMax =  4294967295 ; //< [10] indicates the returned index is not to be used. Its the maximum value a 32bit unsigned number can hold.
  {$ENDIF}



//=============================================================================

//=============================================================================
// Useful Types
//=============================================================================
{}
// Useful type for typecasting 4 consecutive bytes
Type rt4ByteCast = Packed Record
  u1: array[0..3] Of Byte;
End;
{}
// Useful type for typecasting 4 consecutive bytes
Type rt2ByteCast = Packed Record
  u1: array[0..1] Of Byte;
End;
{}
// Useful type for typecasting 2 consecutive word
Type rt2WordCast = Packed Record
  u2: array[0..1] Of word;
End;
{}
// Useful type for typecasting 8 consecutive bytes
Type rt8ByteCast = Packed Record
  u1: array[0..7] Of Byte;
End;
// Useful type for typecasting 4 consecutive words
Type rt8WordCast = Packed Record
  u2: array[0..3] Of word;
End;
// Useful type for typecasting 2 consecutive longint
Type rt8LongCast = Packed Record
  i4: array[0..1] Of longint;
End;
// Useful type for typecasting 2 consecutive cardinal
Type rt8CardinalCast = Packed Record
  u4: array[0..1] Of Cardinal;
End;
//=============================================================================


//=============================================================================
// Constants for making DOS Slashes Easier to write for
//=============================================================================
{}
const csFWDSLASH='/'; {< A forward Slash regardless of platform - used primarily when building URLs and such }
const csBACKSLASH='\'; {< A backward slash regardless of platform }
{}
//=============================================================================

//=============================================================================
// Constants For Platform Specific CR/LF (DOS) or Unixish LF  End of lines (text)
// Documentation for the RTL, found at pages such as this one:
//http://community.freepascal.org:10000/docs-html/rtl/system/defaulttextlinebreakstyle.html
// recommend not using Operating Specific Stuff that much. Something, I of all 
// people support. So - for now - this code is commented out
// well - lack of '$' makes the MACRO stuff appear as pure comments to the 
// compiler. 
//
// NOTE: Tried their way - couldn't get the stuff to work, SO
// this is easy enough to fix at a later time when its more important.
{}
{$IFDEF WINDOWS}
  const csEOL=#13#10; {< Windows EOL Character combination. FreePascal docs like this page http://community.freepascal.org:10000/docs-html/rtl/system/defaulttextlinebreakstyle.html suggest not using platform specific constructs, leave it to them is their sentiment but their way was problematic and using this works fine. }
{$ELSE}
  const csEOL=#10; {< POSIX EOL Character. FreePascal docs like this page http://community.freepascal.org:10000/docs-html/rtl/system/defaulttextlinebreakstyle.html suggest not using platform specific constructs, leave it to them is their sentiment but their way was problematic and using this works fine. NOTE: MAC I guess is only #13. Food for thought. Apple? Food? hahaha }
{$ENDIF}
{}
//=============================================================================

//=============================================================================
// Constants for common ASCII designations
//=============================================================================
{}
const csCRLF=#13#10; {< Carriage Return + Linefeed Constant}
const csCR=#13; {< Carriage Return Constant}
const csLF=#10; {< Linefeed Constant}
const csTAB=#9; {< TAB Constant}
const csDBLQUOTE=#34; {< Double Quote Constant}
const csSPACE = #32; {< Space Constant}
{}
//=============================================================================

//=============================================================================
{}
const cnTIMEZONE_OFFSET = -5; {< Default CONSTANT For TIME ZONE Difference in Hours FROM Greenwich Mean Time }
{}
//=============================================================================

//=============================================================================
{}
// Constant for Date Time Format Long Form P)
// SEE www.freepascal.org, Freepascal documentation, rtl.pdf section:
// (as of 2006-05-07) 29.6 Date and time formatting characters.
// This is one of the standards adopted in Jegas.
// The other is the Escaping and unescaping of characters the way that 
// URL's handle funk characters passed as values in POST/GET CGI submissions.
// The other, is the Javascript defined "Regular Expressions" as detailed
// in a (www.visibone.com) Visibone Javascript Card titled: 
// Javascript Regular Expressions. 
// (Jan 2002 Edition of the "Web Designer's Javascript Card")
// Most likely this matches the Javascript "spec" so.. it is what is being
// used as a reference.. so it is what it is :)
//=============================================================================
{}
const csDATETIMEFORMAT='yyyy-mm-dd tt'; {< EXAMPLE: 2010-01-01 11:00am - note though the exact TIME portion is determined by freepascal configuration, see FPC documentation for Date and time formatting characters  }
const csDATETIMEFORMAT24='yyyy-mm-dd hh:nn:ss'; {< EXAMPLE: 2010-01-01 11:00:00 - note though the exact TIME portion is determined by freepascal configuration, see FPC documentation for Date and time formatting characters  }
const csDATEFORMAT='yyyy-mm-dd'; {< EXAMPLE: 2010-01-01, see FPC documentation for Date and time formatting characters }
const csTIMEFORMAT='tt'; {< default time format (as set by freepascal configuration, see FPC documentation for Date and time formatting characters}
const csTIMEFORMAT24='hh:nn:ss'; {< default time format (as set by freepascal configuration, see FPC documentation for Date and time formatting characters}
const csWEBDATETIMEFORMAT='ddd, dd mmm yyyy hh:nn:ss "GMT"'; {< EXAMPLE: "Thu, 01 Dec 2003 16:00:00 GMT" }
const csUIDFORMAT='YYYYMMDDhhmmsszzz';{<used for generating left side of UID's. Normal Autonumber system used for right side.}
{}
//=============================================================================


//=============================================================================
// Internal Jegas Logging Severity Definitions - LogType
//=============================================================================
{}
const csLOG_FILENAME_DEFAULT='jegaslog.csv'; {< LOGGING: Default file name for log files made with Jegas API}
const cnLog_NONE         =0;   {< LOGGING: Default Logging Level }
const cnLog_DEBUG        =1;   {< LOGGING: Debug Severity }
const cnLog_FATAL        =2;   {< LOGGING: Fatal }
const cnLog_ERROR        =3;   {< LOGGING: Error }
const cnLog_WARN         =4;   {< LOGGING: Warning }
const cnLog_INFO         =5;   {< LOGGING: Informational }
const cnLog_REQUEST      =6;   {< LOGGING: if grJASConfig.bLogToDatabase = true then all requests are logged in extreme detail.}
const cnLog_RESERVED     =7;   {< LOGGING: Reserved Severity by JEGAS 6 thru 99}
const cnLog_USERDEFINED  =100; {< LOGGING: Reserved Severity for Users 100 thru 255}
{}
//=============================================================================

//=============================================================================
// HTMLRIPPER JFC_TOKENIZER Quote definitions
//=============================================================================
{}
const csHTMLRipperStart='<!--HTMLRIPPER INSERT BEGIN-->'; {< HTMLRIPPER JFC_TOKENIZER Start Quote definition }
const csHTMLRipperEnd='<!--HTMLRIPPER INSERT END-->';     {< HTMLRIPPER JFC_TOKENIZER End Quote definition }
{}
//=============================================================================

//=============================================================================
{}
// This is related to JAS Server - for things like hiding or not hiding
// information from end users such as error messages that might reveal quite a 
// bit of information about a system.
const cnSYS_INFO_MODE_SECURE=0;       
// This is related to JAS Server - for things like hiding or not hiding
// information from end users such as error messages that might reveal quite a 
// bit of information about a system.
const cnSYS_INFO_MODE_VERBOSELOCAL=1; 
// This is related to JAS Server - for things like hiding or not hiding
// information from end users such as error messages that might reveal quite a 
// bit of information about a system.
const cnSYS_INFO_MODE_VERBOSE=2;      
{}
//=============================================================================








//*****************************************************************************
// Jegas Data Types and Insight to naming convention
// Main paradigm difference between code and datamodeling, 
// is that code prefixes theses naming "constructs" as prefixes
// e.g.  i4MyInteger
// And data modeling (column names in databases) uses these construx as 
// suffixes to ease finding giving field names (by both business, report 
// writers, and programmers alike.
// e.g. TABCD_MyInteger_i4
// Which means, TABCD is a 5 char code to represent the TABLE the column 
// belongs to, MyInteger is the columns "name", and the i4 suffix means its
// a 4 byte long integer data type.
//=============================================================================
{}
Const cnJDType_Unknown  = 00; //< Unknown
Const cnJDType_b        = 01; //< Boolean - b
Const cnJDType_i1       = 02; //< Integer - 01 Byte	  i1
Const cnJDType_i2       = 03; //< Integer - 02 Bytes	i2
Const cnJDType_i4       = 04; //< Integer - 04 Bytes	i4
Const cnJDType_i8       = 05; //< Integer - 08 Bytes	i8
Const cnJDType_i16      = 06; //< Integer - 16 Bytes	i16
Const cnJDType_i32      = 07; //< Integer - 32 Bytes	i32
Const cnJDType_u1       = 08; //< Integer - Unsigned - 01 Byte	 u1
Const cnJDType_u2       = 09; //< Integer - Unsigned - 02 Bytes	 u2
Const cnJDType_u4       = 10; //< Integer - Unsigned - 04 Bytes	 u4
Const cnJDType_u8       = 11; //< Integer - Unsigned - 08 Bytes	 u8
Const cnJDType_u16      = 12; //< Integer - Unsigned - 16 Bytes	 u16
Const cnJDType_u32      = 13; //< Integer - Unsigned - 32 Bytes	 u32
Const cnJDType_fp       = 14; //< Floating Point
Const cnJDType_fd       = 15; //< Fixed Decimal Places
Const cnJDType_cur      = 16; //< Currency
Const cnJDType_ch       = 17; //< Char - ASCII	ch
Const cnJDType_chu      = 18; //< Char - Unicode	chu
Const cnJDType_dt       = 19; //< DateTime	dt
Const cnJDType_s        = 20; //< Text - ASCII
Const cnJDType_su       = 21; //< Text - Unicode
Const cnJDType_sn       = 22; //< Memo - ASCII
Const cnJDType_sun      = 23; //< Memo - Unicode
Const cnJDType_bin      = 24; //< Binary - Binary Large Object

{}
// Widget Types that don't map ONE-TO-ONE With Jegas Data Types
// Note: These Types work properly in bIsJDType????? functions.
const cnJWidget_Dropdown = 100;
const cnJWidget_Lookup = 101;
const cnJWidget_URL = 102;
const cnJWidget_Email = 103;
const cnJWidget_ComboBox = 104;
const cnJWidget_LookupComboBox = 105;
const cnJWidget_Phone = 106;
const cnJWidget_Content = 107;
//=============================================================================

//=============================================================================
{}
// All Figures are FACT + 1 for Positive/negative sign
// when applied to Signed Ints. If Not exact, Over
// Estimated for Safety.
Const cnMSAccessMaxString = 60;
//Const cnMSAccessMaxString = 250;
Const cnMaxDigitsFor01ByteUInt = 4      ;
Const cnMaxDigitsFor02ByteUInt = 6      ;
Const cnMaxDigitsFor04ByteUInt = 32     ;
Const cnMaxDigitsFor08ByteUInt = 64     ;
Const cnMaxDigitsFor16ByteUInt = 250    ;
Const cnMaxDigitsFor32ByteUInt = 1023   ;
Const cnMaxDigitsForDateToText = 50     ;
Const cnMaxDigitsForFPtoText = 128      ;
Const cnMaxDigitsForFDtoText = 128      ;
Const cnMaxDigitsForCurtoText = 128     ;
//=============================================================================


//=============================================================================
{}
// Value Pair Structure - With extra description field
Type rtValuePair=record
  saName: ansistring;
  saValue: ansistring;
  saDesc: ansistring;
End;
//=============================================================================

//=============================================================================
{}
// This structure is used to describe a database field in a platform/dbms
// independant manner. This is the middleman for translating fields from one
// DBMS to another as well as various field centric data processing tasks.
Type rtJegasField=record
  sName: string;//< replaces rtJegasColumn.saColumnName
  u2JDType: word;//< replaces rtJegasColumn.uJegasDatatype
  u8DefinedSize: UInt64;//< For lengths like char and bin
  i4NumericScale: longint;
  i4Precision: longint;
  bTrueFalse: Boolean; //< For various Boolean formats to equate to this
  vValue: Variant;//< replaces rtJegasColumn.vData
  bSeekField: Boolean ;//< true when using to build sql where classes
  bDataField: Boolean ;//< true when building sql resultsets
  sSourceField: string;//< used to route ADO data by field name into correct JAS Field by some functions in JADO
  sTargetField: string;//< Used by JADO.JAS2JASFieldCopy - to map fields WHEN copyFieldNameFlag set to false.
End;
//=============================================================================




//=============================================================================
// These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
//=============================================================================
{}
Const cnJWidget_Unknown  = 00; //< Jegas Widget Type - Unknown - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i1       = 01; //< Jegas Widget Type - Integer - 1 Byte	i1 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i2       = 02; //< Jegas Widget Type - Integer - 2 Bytes	i2 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i4       = 03; //< Jegas Widget Type - Integer - 4 Bytes	i4 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i8       = 04; //< Jegas Widget Type - Integer - 8 Bytes	i8 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i16      = 05; //< Jegas Widget Type - Integer - 16 Bytes	i16 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i32      = 06; //< Jegas Widget Type - Integer - 32 Bytes	i32 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u1       = 07; //< Jegas Widget Type - Integer - Unsigned - 1 - Byte	u1 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u2       = 08; //< Jegas Widget Type - Integer - Unsigned - 2 - Bytes	u2 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u4       = 09; //< Jegas Widget Type - Integer - Unsigned - 4 - Bytes	u4 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u8       = 10; //< Jegas Widget Type - Integer - Unsigned - 8 - Bytes	u8 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u16      = 11; //< Jegas Widget Type - Integer - Unsigned - 16 - Bytes	u16 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u32      = 12; //< Jegas Widget Type - Integer - Unsigned - 32 - Bytes	u32 These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_fp       = 13; //< Jegas Widget Type - Floating Point - Largest Supported by Platform	IEEE These are the defined Widget Types. - There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_fd       = 14; //< Jegas Widget Type - Floating Point - Fixed Decimal Places	f?? - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_cur      = 15; //< Jegas Widget Type - Currency - Base U.S. Dollars	cur - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sx       = 16; //< Jegas Widget Type - String - Ascii - x=Fixed Max Length - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sux      = 17; //< Jegas Widget Type - String - Unicode - x=Max Length - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_ch       = 18; //< Jegas Widget Type - Char - One Byte	ch - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_chu      = 19; //< Jegas Widget Type - Char - Unicode	chu - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_b        = 20; //< Jegas Widget Type - Boolean - Byte	b - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_bi1      = 21; //< Jegas Widget Type - Boolean - Boolean Integer - 1 Byte - >Zero=true	bi1 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_jdt      = 22; //< Jegas Widget Type - Jegas Timestamp	jdt (Most likely will be freepascal tdatetime struct) - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_dt       = 23; //< Jegas Widget Type - Timestamp	dt - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_ui4      = 24; //< Jegas Widget Type - Unique Identifiers Integer Based - ui?-This is ui4 - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_s        = 25; //< Jegas Widget Type - String - Unspecified Max Length	s - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_su       = 26; //< Jegas Widget Type - String - Unicode - Unspecified Length	su - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sn       = 27; //< Jegas Widget Type - String - Ascii - Note/Glob/Memo	sn - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sun      = 28; //< Jegas Widget Type - String - Unicode - Note/Glob/Memo	sun - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sz       = 29; //< Jegas Widget Type - String - ASCII - Null Terminated	sz - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_suz      = 30; //< Jegas Widget Type - String - Unicode - Null Terminated	suz - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_sa       = 31; //< Jegas Widget Type - CODE FreePascal ANSISTRING	sa  - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_cn       = 32; //< Jegas Widget Type - CODE - Constants - Numeric	cn - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_cs       = 33; //< Jegas Widget Type - CODE - Constants - String	cs - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_i        = 34; //< Jegas Widget Type - CODE - Represents integer data type that is x bytes - where x=number of bytes wide for the specific platform  - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_u        = 35; //< Jegas Widget Type - CODE - Represent unsigned data type that is x bytes - where x=number of bytes wide for the specific platform  - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_v        = 36; //< Jegas Widget Type - CODE - Represents a Variant Data Type (Freepascal) - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
Const cnJWidget_bin      = 37; //< Jegas Widget Type - Binary - Unspecified Length Binary Large Object - These are the defined Widget Types. There is a one-to-one relationship for the Jegas Data Types - these one-to-one matches are effectively the DEFAULT widgets for said datatypes. However, as the system matures, Multiple Widgets will become available for specific datatypes. Example: Currently, 2007-02-01, the date/time datatypes have a HTML/JAVASCRIPT date control calendar with date selection via dropdown number lists or a calendar you can click the date on. For the time portion, this is only drop downs.
{}


//=============================================================================
const 
//=============================================================================
{}
  csINET_HDR_METHOD_GET                             ='GET'; //< "GET" - Note LACK OF Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_METHOD_POST                            ='POST'; //< "POST" - Note LACK OF Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_JEGAS                                  ='Jegas: '; //< "Jegas: " - Note Trailing Space. TCP HyperText Protocol and related string constant. This particular constant is obviously created by Jegas. It's use is relevant to the nph-jas.cgi aka jegaS_cgi_thin_client3.pas application at the time this comment was written. 
  csINET_HDR_USER_AGENT                             ='User-Agent: '; //< "User-Agent: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_HOST                                   ='Host: ';//< "Host: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_REFERER                                ='Referer: ';//< "Referer: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_ACCEPT                                 ='Accept: ';//< "Accept: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_ACCEPT_LANGUAGE                        ='Accept-Language: ';//< "Accept-Language: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_ACCEPT_ENCODING                        ='Accept-Encoding: ';//< "Accept-Encoding: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_CONTENT_TYPE                           ='Content-Type: ';//< "Content-Type: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_CONTENT_LENGTH                         ='Content-Length: ';//< "Content-Length: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_CONNECTION                             ='Connection: ';//< "Connection: " - Note Trailing Space. TCP HyperText Protocol and related string constants.
  csINET_HDR_CACHE_CONTROL                          ='Cache-Control: ';//< "Cache-Control: " - Note Trailing Space. TCP HyperText Protocol and related string constants.
  csINET_HDR_LAST_MODIFIED                          ='Last-Modified: ';//< "Last-Modified: " - Note Trailing Space. TCP HyperText Protocol and related string constants.
  csINET_HDR_COOKIE                                 ='Cookie: ';//< "Cookie: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_SETCOOKIE                              ='Set-Cookie: ';//< "Set-Cookie: " - Server->Client - RFC 6265 HTTP State Management Mechanism April 2011
  csINET_HDR_ACCEPT_CHARSET                         ='Accept-Charset: ';//< "Accept-Charset: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_KEEPALIVE                              ='Keep-Alive: ';//< "Keep-Alive: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
  csINET_HDR_SERVER                                 ='Server: '; //< "Server: " - Note Trailing Space. TCP HyperText Protocol and related string constant.
//  csINET_JAS_SERVER_SOFTWARE                        ='Jegas Application Server / Jegas, LLC Version 1.0 -en';//< "Jegas Application Server / Jegas, LLC Version 1.0 -en" - Note LACK OF Trailing Space. TCP HyperText Protocol and related string constant. This particular one is a hardcoded version value used when generating HTTP headers.
  csINET_JAS_SERVER_SOFTWARE                        ='Jegas Application Server / Jegas, LLC -en';//< "Jegas Application Server / Jegas, LLC Version 1.0 -en" - Note LACK OF Trailing Space. TCP HyperText Protocol and related string constant. This particular one is a hardcoded version value used when generating HTTP headers.
  csINET_JAS_CGI_SOFTWARE                           ='Jegas CGI Application / Jegas, LLC Version 1.0 -en';//< "Jegas CGI Application / Jegas, LLC Version 1.0 -en" - Note LACK OF Trailing Space. TCP HyperText Protocol and related string constant. This particular one is a hardcoded version value used when generating HTTP headers in CGI applications.
{}
//=============================================================================
  
//=============================================================================
Const // CGI and other web related constants in ug_common.pp
//=============================================================================
{}  
  csJAS_CACHE_CONTROL                    = 'CACHE_CONTROL';//<webserver internal reference             
  csCGI_application_x_www_form_urlencoded= 'APPLICATION/X-WWW-FORM-URLENCODED';
  csCGI_GET                              = 'GET';
  csCGI_CONTENT_TYPE                     = 'CONTENT_TYPE';
  csCGI_CONTENT_LENGTH                   = 'CONTENT_LENGTH';
  csCGI_DOCUMENT_ROOT                    = 'DOCUMENT_ROOT';
  csCGI_HTTP_ACCEPT                      = 'HTTP_ACCEPT';
  csCGI_HTTP_ACCEPT_LANGUAGE             = 'HTTP_ACCEPT_LANGUAGE';
  csCGI_HTTP_ACCEPT_ENCODING             = 'HTTP_ACCEPT_ENCODING';
  csCGI_HTTP_ACCEPT_CHARSET              = 'HTTP_ACCEPT_CHARSET';
  csCGI_HTTP_KEEPALIVE                   = 'HTTP_KEEPALIVE';//< note: underscore not between keep and alive purposely.
  csCGI_HTTP_CONNECTION                  = 'HTTP_CONNECTION';
  csCGI_HTTP_COOKIE                      = 'HTTP_COOKIE';
  csCGI_HTTP_HOST                        = 'HTTP_HOST';
  csCGI_HTTP_REFERER                     = 'HTTP_REFERER';
  csCGI_HTTP_USER_AGENT                  = 'HTTP_USER_AGENT';
  csCGI_PATH_INFO                        = 'PATH_INFO';
  csCGI_POST                             = 'POST';
  csCGI_QUERY_STRING                     = 'QUERY_STRING';
  csCGI_REMOTE_ADDR                      = 'REMOTE_ADDR';
  csCGI_REMOTE_PORT                      = 'REMOTE_PORT';
  csCGI_REQUEST_METHOD                   = 'REQUEST_METHOD';
  csCGI_REQUEST_URI                      = 'REQUEST_URI';
  csCGI_SCRIPT_FILENAME                  = 'SCRIPT_FILENAME';
  csCGI_SCRIPT_NAME                      = 'SCRIPT_NAME';
  csCGI_SERVER_SOFTWARE                  = 'SERVER_SOFTWARE';
  csCGI_REDIRECT_STATUS                  = 'REDIRECT_STATUS';
  csCGI_JEGAS                            = 'JEGAS';
  csCGI_SERVER_ADDR                      = 'SERVER_ADDR';
  csCGI_SERVER_PORT                      = 'SERVER_PORT';

{}
//=============================================================================
{}
  csCGI_HTTP_HDR_VERSION = 'HTTP/1.1 ';//< Part of the status header generated for HTTP. The server status value follws this. Example: HTTP/1.1 200 OK';
  csCGI_JEGAS_CGI_1_0_0='JAS-CGI 1.0.0';//< specific for the JAS CGI Proxy tool

  csMIME_TextPlain =        'text/plain';
  csMIME_TextHtml =         'text/html';
  csMIME_TextHtm =          'text/htm';
  csMIME_TextXml =          'text/xml';
  csMIME_TextWSDL =         'text/xml';
  csMIME_AppForceDownload = 'application/force-download';
  csMIME_ImagePng =         'image/png';
  csMIME_ImageIcon =        'image/x-icon';
  csMime_Javascript =       'application/x-javascript';
  csMime_ImageGif =         'image/gif';
  csMime_TextCSS =          'text/css';
  csMime_ImageJPeg =        'image/jpeg';
  csMime_ImageJPG =         'image/jpeg';
  csMime_PDF =              'application/pdf';
  csMime_AudioMid=          'audio/midi';
  csMime_AudioMidi=         'audio/midi';
  csMime_AudioMPeg=         'audio/mpeg';
  csMime_AudioWav=          'audio/x-wav';
  csMime_ImageBmp=          'image/bmp';
  csMime_TextRTF=           'text/rtf';
  csMime_ExecuteEXE=        'execute/cgi';
  csMime_ExecuteCGI=        'execute/cgi';
  csMime_ExecutePHP=        'execute/php';
  csMime_ExecutePerl=       'execute/perl';
  csMIME_ExecuteJegas=      'execute/jegas';
  // mime=jax execute/jegaswebservice SNR

//
//      .ai  -  application/postscript
//     .aif  -  audio/x-aiff
//    .aifc  -  audio/x-aiff
//    .aiff  -  audio/x-aiff
//     .asc  -  text/plain
//      .au  -  audio/basic
//     .avi  -  video/x-msvideo
//   .bcpio  -  application/x-bcpio
//     .bin  -  application/octet-stream
//       .c  -  text/plain
//      .cc  -  text/plain
//    .ccad  -  application/clariscad
//     .cdf  -  application/x-netcdf
//   .class  -  application/octet-stream
//    .cpio  -  application/x-cpio
//     .cpt  -  application/mac-compactpro
//     .csh  -  application/x-csh
//     .css  -  text/css
//     .dcr  -  application/x-director
//     .dir  -  application/x-director
//     .dms  -  application/octet-stream
//     .doc  -  application/msword
//     .drw  -  application/drafting
//     .dvi  -  application/x-dvi
//     .dwg  -  application/acad
//     .dxf  -  application/dxf
//     .dxr  -  application/x-director
//     .eps  -  application/postscript
//     .etx  -  text/x-setext
//     .exe  -  application/octet-stream
//      .ez  -  application/andrew-inset
//       .f  -  text/plain
//     .f90  -  text/plain
//     .fli  -  video/x-fli
//     .gif  -  image/gif
//    .gtar  -  application/x-gtar
//      .gz  -  application/x-gzip
//       .h  -  text/plain
//     .hdf  -  application/x-hdf
//      .hh  -  text/plain
//     .hqx  -  application/mac-binhex40
//     .htm  -  text/html
//    .html  -  text/html
//     .ice  -  x-conference/x-cooltalk
//     .ief  -  image/ief
//    .iges  -  model/iges
//     .igs  -  model/iges
//     .ips  -  application/x-ipscript
//     .ipx  -  application/x-ipix
//     .jpe  -  image/jpeg
//    .jpeg  -  image/jpeg
//     .jpg  -  image/jpeg
//      .js  -  application/x-javascript
//     .kar  -  audio/midi
//   .latex  -  application/x-latex
//     .lha  -  application/octet-stream
//     .lsp  -  application/x-lisp
//     .lzh  -  application/octet-stream
//       .m  -  text/plain
//     .man  -  application/x-troff-man
//      .me  -  application/x-troff-me
//    .mesh  -  model/mesh
//     .mid  -  audio/midi
//    .midi  -  audio/midi
//     .mif  -  application/vnd.mif
//    .mime  -  www/mime
//     .mov  -  video/quicktime
//   .movie  -  video/x-sgi-movie
//     .mp2  -  audio/mpeg
//     .mp3  -  audio/mpeg
//     .mpe  -  video/mpeg
//    .mpeg  -  video/mpeg
//     .mpg  -  video/mpeg
//    .mpga  -  audio/mpeg
//      .ms  -  application/x-troff-ms
//     .msh  -  model/mesh
//      .nc  -  application/x-netcdf
//     .oda  -  application/oda
//     .pbm  -  image/x-portable-bitmap
//     .pdb  -  chemical/x-pdb
//     .pdf  -  application/pdf
//     .pgm  -  image/x-portable-graymap
//     .pgn  -  application/x-chess-pgn
//     .png  -  image/png
//     .pnm  -  image/x-portable-anymap
//     .pot  -  application/mspowerpoint
//     .ppm  -  image/x-portable-pixmap
//     .pps  -  application/mspowerpoint
//     .ppt  -  application/mspowerpoint
//     .ppz  -  application/mspowerpoint
//     .pre  -  application/x-freelance
//     .prt  -  application/pro_eng
//      .ps  -  application/postscript
//      .qt  -  video/quicktime
//      .ra  -  audio/x-realaudio
//     .ram  -  audio/x-pn-realaudio
//     .ras  -  image/cmu-raster
//     .rgb  -  image/x-rgb
//      .rm  -  audio/x-pn-realaudio
//    .roff  -  application/x-troff
//     .rpm  -  audio/x-pn-realaudio-plugin
//     .rtf  -  text/rtf
//     .rtx  -  text/richtext
//     .scm  -  application/x-lotusscreencam
//     .set  -  application/set
//     .sgm  -  text/sgml
//    .sgml  -  text/sgml
//      .sh  -  application/x-sh
//    .shar  -  application/x-shar
//    .silo  -  model/mesh
//     .sit  -  application/x-stuffit
//     .skd  -  application/x-koan
//     .skm  -  application/x-koan
//     .skp  -  application/x-koan
//     .skt  -  application/x-koan
//     .smi  -  application/smil
//    .smil  -  application/smil
//     .snd  -  audio/basic
//     .sol  -  application/solids
//     .spl  -  application/x-futuresplash
//     .src  -  application/x-wais-source
//    .step  -  application/STEP
//     .stl  -  application/SLA
//     .stp  -  application/STEP
// .sv4cpio  -  application/x-sv4cpio
//  .sv4crc  -  application/x-sv4crc
//     .swf  -  application/x-shockwave-flash
//       .t  -  application/x-troff
//     .tar  -  application/x-tar
//     .tcl  -  application/x-tcl
//     .tex  -  application/x-tex
//    .texi  -  application/x-texinfo
//  .texinfo -  application/x-texinfo
//     .tif  -  image/tiff
//    .tiff  -  image/tiff
//      .tr  -  application/x-troff
//     .tsi  -  audio/TSP-audio
//     .tsp  -  application/dsptype
//     .tsv  -  text/tab-separated-values
//     .txt  -  text/plain
//     .unv  -  application/i-deas
//   .ustar  -  application/x-ustar
//     .vcd  -  application/x-cdlink
//     .vda  -  application/vda
//     .viv  -  video/vnd.vivo
//    .vivo  -  video/vnd.vivo
//    .vrml  -  model/vrml
//     .wav  -  audio/x-wav
//     .wrl  -  model/vrml
//     .xbm  -  image/x-xbitmap
//     .xlc  -  application/vnd.ms-excel
//     .xll  -  application/vnd.ms-excel
//     .xlm  -  application/vnd.ms-excel
//     .xls  -  application/vnd.ms-excel
//     .xlw  -  application/vnd.ms-excel
//     .xml  -  text/xml
//     .xpm  -  image/x-xpixmap
//     .xwd  -  image/x-xwindowdump
//     .xyz  -  chemical/x-pdb
//     .zip  -  application/zip





{}
//=============================================================================
// SAMPLE XML Response:
{
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<response>
  <method>checkName</method>
  <Result>1</Result>
</response>
}

//SAMPLE No-Content Response (perl snip)
//  #!/usr/bin/perl
//  print "$ENV{'SERVER_PROTOCOL'} 204 No Content\n";
//  print "Server: $ENV{'SERVER_SOFTWARE'}\n";
//  print "Content-type: text/plain\n\n";

//=============================================================================


//=============================================================================
// HTTP RESPONSES  
//=============================================================================
  //--------------------------------
  //Informational
  //--------------------------------
  {}
  csHTTP_RESPONSE_100 ='100 Continue';//< INFORMATIONAL HTTP Server Response Code: This means that the server has received the request headers, and that the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). If the request body is large, sending it to a server when a request has already been rejected based upon inappropriate headers is inefficient. To have a server check if the request could be accepted based on the request's headers alone, a client must send Expect: 100-continue as a header in its initial request (see RFC 2616 §14.20 – Expect header) and check if a 100 Continue status code is received in response before continuing (or receive 417 Expectation Failed and not continue).[2]
  cnHTTP_RESPONSE_100 = 100; //< INFORMATIONAL HTTP Server Response Code: This means that the server has received the request headers, and that the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). If the request body is large, sending it to a server when a request has already been rejected based upon inappropriate headers is inefficient. To have a server check if the request could be accepted based on the request's headers alone, a client must send Expect: 100-continue as a header in its initial request (see RFC 2616 §14.20 – Expect header) and check if a 100 Continue status code is received in response before continuing (or receive 417 Expectation Failed and not continue).[2]

  csHTTP_RESPONSE_101 ='101 Switching Protocols';//<INFORMATIONAL HTTP Server Response Code: This means the requester has asked the server to switch protocols and the server is acknowledging that it will do so.[3]
  cnHTTP_RESPONSE_101 = 101;//<INFORMATIONAL HTTP Server Response Code: : This means the requester has asked the server to switch protocols and the server is acknowledging that it will do so.[3]

  csHTTP_RESPONSE_102 ='102 Processing';//<INFORMATIONAL HTTP Server Response Code: WebDAV Related - RFC 2518
  cnHTTP_RESPONSE_102 = 102;//<INFORMATIONAL HTTP Server Response Code: WebDAV Related - RFC 2518
  {}
  //--------------------------------
  // 2xx Success - The action was successfully received, understood, and accepted.
  //--------------------------------
  {}
  csHTTP_RESPONSE_200 ='200 OK';//< 2xx Success - The action was successfully received, understood, and accepted. Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request the response will contain an objectdescribing or containing the result of the action.
  cnHTTP_RESPONSE_200 =200;//< 2xx Success - The action was successfully received, understood, and accepted. Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an objectcorresponding to the requested resource. In a POST request the response will contain an objectdescribing or containing the result of the action.
  
  csHTTP_RESPONSE_201 ='201 Created';//< 2xx Success - The action was successfully received, understood, and accepted. The request has been fulfilled and resulted in a new resource being created.
  cnHTTP_RESPONSE_201 =201;//< 2xx Success - The action was successfully received, understood, and accepted. The request has been fulfilled and resulted in a new resource being created.
  
  csHTTP_RESPONSE_202 ='202 Accepted';//< 2xx Success - The action was successfully received, understood, and accepted. The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.
  cnHTTP_RESPONSE_202 =202;//< 2xx Success - The action was successfully received, understood, and accepted. The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.
  
  csHTTP_RESPONSE_203 ='203 Non-Authoritative Information';//< (since HTTP/1.1) 2xx Success - The action was successfully received, understood, and accepted. The server successfully processed the request, but is returning information that may be from another source.
  cnHTTP_RESPONSE_203 =203;//< (since HTTP/1.1) 2xx Success - The action was successfully received, understood, and accepted. The server successfully processed the request, but is returning information that may be from another source.
  
  csHTTP_RESPONSE_204 ='204 No Content';//< 2xx Success - The action was successfully received, understood, and accepted. The server successfully processed the request, but is not returning any content.
  cnHTTP_RESPONSE_204 =204;//< 2xx Success - The action was successfully received, understood, and accepted. The server successfully processed the request, but is not returning any content.
  
  csHTTP_RESPONSE_205 ='205 Reset Content';//< 2xx Success - The action was successfully received, understood, and accepted. 
  cnHTTP_RESPONSE_205 =205;//< 2xx Success - The action was successfully received, understood, and accepted. The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.
  
  csHTTP_RESPONSE_206 ='206 Partial Content';//< 2xx Success - The action was successfully received, understood, and accepted. The server is delivering only part of the resource due to a range header sent by the client. This is used by tools like wget to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.
  cnHTTP_RESPONSE_206 =206;//< 2xx Success - The action was successfully received, understood, and accepted. The server is delivering only part of the resource due to a range header sent by the client. This is used by tools like wget to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.
  
  csHTTP_RESPONSE_207 ='207 Multi-Status';//< 2xx Success - The action was successfully received, understood, and accepted. WebDAV - The message body that follows is an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.
  cnHTTP_RESPONSE_207 =207;//< 2xx Success - The action was successfully received, understood, and accepted. WebDAV - The message body that follows is an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.
  
  
  csHTTP_RESPONSE_226 ='226 IM Used'; //< 2xx Success - The action was successfully received, understood, and accepted. (NOT INSTANT MESSENGER RELATED!) The server lists the set of instance-manipulations it has applied.
  cnHTTP_RESPONSE_226 =226;//< 2xx Success - The action was successfully received, understood, and accepted. (NOT INSTANT MESSENGER RELATED!) The server lists the set of instance-manipulations it has applied.
  

  {}
  //--------------------------------
  // 3xx Redirection - The client must take additional action to complete the request.
  //--------------------------------
  // This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop.
  {}
  csHTTP_RESPONSE_300 ='300 Multiple Choices'; //< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Indicates multiple options for the resource that the client may follow. It, for instance, could be used to present different format options for video, list files with different extensions, or word sense disambiguation.
  cnHTTP_RESPONSE_300 =300; //< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Indicates multiple options for the resource that the client may follow. It, for instance, could be used to present different format options for video, list files with different extensions, or word sense disambiguation.
  
  csHTTP_RESPONSE_301 ='301 Moved Permanently';//< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. This and all future requests should be directed to the given URI.
  cnHTTP_RESPONSE_301 =301;//< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. This and all future requests should be directed to the given URI.
  
  csHTTP_RESPONSE_302 ='302 Found';//< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. This is the most popular redirect code[citation needed], but also an example of industrial practice contradicting the standard. HTTP/1.0 specification (RFC 1945 ) required the client to perform a temporary redirect (the original describing phrase was "Moved Temporarily"), but popular browsers implemented it as a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to disambiguate between the two behaviours. However, the majority of Web applications and frameworks still use the 302 status code as if it were the 303.
  cnHTTP_RESPONSE_302 =302;//< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop.This is the most popular redirect code[citation needed], but also an example of industrial practice contradicting the standard. HTTP/1.0 specification (RFC 1945 ) required the client to perform a temporary redirect (the original describing phrase was "Moved Temporarily"), but popular browsers implemented it as a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to disambiguate between the two behaviours. However, the majority of Web applications and frameworks still use the 302 status code as if it were the 303.
  
  csHTTP_RESPONSE_303 ='303 See Other';//< (since HTTP/1.1) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. The response to the request can be found under another URI using a GET method. When received in response to a PUT, it should be assumed that the server has received the data and the redirect should be issued with a separate GET message.
  cnHTTP_RESPONSE_303 =303; //< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. The response to the request can be found under another URI using a GET method. When received in response to a PUT, it should be assumed that the server has received the data and the redirect should be issued with a separate GET message.
  
  csHTTP_RESPONSE_304 ='304 Not Modified'; //< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Indicates the resource has not been modified since last requested. Typically, the HTTP client provides a header like the If-Modified-Since header to provide a time against which to compare. Utilizing this saves bandwidth and reprocessing on both the server and client, as only the header data must be sent and received in comparison to the entirety of the page being re-processed by the server, then resent using more bandwidth of the server and client.
  cnHTTP_RESPONSE_304 =304; //< 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Indicates the resource has not been modified since last requested. Typically, the HTTP client provides a header like the If-Modified-Since header to provide a time against which to compare. Utilizing this saves bandwidth and reprocessing on both the server and client, as only the header data must be sent and received in comparison to the entirety of the page being re-processed by the server, then resent using more bandwidth of the server and client.
  
  csHTTP_RESPONSE_305 ='305 Use Proxy';//< (since HTTP/1.1) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Many HTTP clients (such as Mozilla[4] and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.
  cnHTTP_RESPONSE_305 =305; //<  (since HTTP/1.1) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. Many HTTP clients (such as Mozilla[4] and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.
  
  csHTTP_RESPONSE_306 ='306 Switch Proxy'; //< (No longer used.) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop.
  cnHTTP_RESPONSE_306 =306; //< (No longer used.) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop.
  
  csHTTP_RESPONSE_307 ='307 Temporary Redirect';//< (since HTTP/1.1) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. In this occasion, the request should be repeated with another URI, but future requests can still use the original URI. In contrast to 303, the request method should not be changed when reissuing the original request. For instance, a POST request must be repeated using another POST request.
  cnHTTP_RESPONSE_307 =307; //< (since HTTP/1.1) 3xx Redirection - The client must take additional action to complete the request. This class of status code indicates that further action needs to be taken by the user agent in order to fulfil the request. The action required may be carried out by the user agent without interaction with the user if and only if the method used in the second request is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections usually indicate an infinite loop. In this occasion, the request should be repeated with another URI, but future requests can still use the original URI. In contrast to 303, the request method should not be changed when reissuing the original request. For instance, a POST request must be repeated using another POST request.

  {}
  //--------------------------------
  // 4xx Client Error - The request contains bad syntax or cannot be fulfilled.
  //--------------------------------
  // The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online.
  {}
  csHTTP_RESPONSE_400 ='400 Bad Request'; //< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request contains bad syntax or cannot be fulfilled.
  cnHTTP_RESPONSE_400 =400;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request contains bad syntax or cannot be fulfilled.
  
  csHTTP_RESPONSE_401 ='401 Unauthorized';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Similar to 403 Forbidden, but specifically for use when authentication is possible but has failed or not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.
  cnHTTP_RESPONSE_401 =401;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Similar to 403 Forbidden, but specifically for use when authentication is possible but has failed or not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.
  
  csHTTP_RESPONSE_402 ='402 Payment Required';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code has never been used.
  cnHTTP_RESPONSE_402 =402;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code has never been used.
  
  csHTTP_RESPONSE_403 ='403 Forbidden';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request was a legal request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.
  cnHTTP_RESPONSE_403 =403;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request was a legal request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.
  
  csHTTP_RESPONSE_404 ='404 Not Found';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
  cnHTTP_RESPONSE_404 =404;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
  
  csHTTP_RESPONSE_405 ='405 Method Not Allowed';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
  cnHTTP_RESPONSE_405 =405;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
  
  csHTTP_RESPONSE_406 ='406 Not Acceptable';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
  cnHTTP_RESPONSE_406 =406;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
  
  csHTTP_RESPONSE_407 ='407 Proxy Authentication Required';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online.
  cnHTTP_RESPONSE_407 =407;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online.
  
  csHTTP_RESPONSE_408 ='408 Request Timeout';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server timed out waiting for the request.
  cnHTTP_RESPONSE_408 =408;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server timed out waiting for the request.
    
  csHTTP_RESPONSE_409 ='409 Conflict';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Indicates that the request could not be processed because of conflict in the request, such as an edit conflict.
  cnHTTP_RESPONSE_409 =409;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Indicates that the request could not be processed because of conflict in the request, such as an edit conflict.
  
  csHTTP_RESPONSE_410 ='410 Gone';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed; however, it is not necessary to return this code and a 404 Not Found can be issued instead. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indexes.
  cnHTTP_RESPONSE_410 =410;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed; however, it is not necessary to return this code and a 404 Not Found can be issued instead. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indexes.
  
  csHTTP_RESPONSE_411 ='411 Length Required';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request did not specify the length of its content, which is required by the requested resource.
  cnHTTP_RESPONSE_411 =411;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request did not specify the length of its content, which is required by the requested resource.
  
  csHTTP_RESPONSE_412 ='412 Precondition Failed';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server does not meet one of the preconditions that the requester put on the request.
  cnHTTP_RESPONSE_412 =412;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server does not meet one of the preconditions that the requester put on the request.
  
  csHTTP_RESPONSE_413 ='413 Request Entity Too Large';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request is larger than the server is willing or able to process.
  cnHTTP_RESPONSE_413 =413;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request is larger than the server is willing or able to process.
  
  csHTTP_RESPONSE_414 ='414 Request-URI Too Long';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The URI provided was too long for the server to process.
  cnHTTP_RESPONSE_414 =414;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The URI provided was too long for the server to process.
  
  csHTTP_RESPONSE_415 ='415 Unsupported Media Type';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request did not specify any media types that the server or resource supports. For example the client specified that an image resource should be served as image/svg+xml, but the server cannot find a matching version of the image.
  cnHTTP_RESPONSE_415 =415;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The request did not specify any media types that the server or resource supports. For example the client specified that an image resource should be served as image/svg+xml, but the server cannot find a matching version of the image.
  
  csHTTP_RESPONSE_416 ='416 Requested Range Not Satisfiable';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The client has asked for a portion of the file, but the server cannot supply that portion (for example, if the client asked for a part of the file that lies beyond the end of the file).
  cnHTTP_RESPONSE_416 =416;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The client has asked for a portion of the file, but the server cannot supply that portion (for example, if the client asked for a part of the file that lies beyond the end of the file).
  
  csHTTP_RESPONSE_417 ='417 Expectation Failed';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server cannot meet the requirements of the Expect request-header field.
  cnHTTP_RESPONSE_417 =417;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The server cannot meet the requirements of the Expect request-header field.
  
  csHTTP_RESPONSE_418 ='418 I''m a teapot';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The HTCPCP server is a teapot. The responding entity MAY be short and stout. Defined by the April Fools' specification RFC 2324. See Hyper Text Coffee Pot Control Protocol for more information.
  cnHTTP_RESPONSE_418 =418;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. The HTCPCP server is a teapot. The responding entity MAY be short and stout. Defined by the April Fools' specification RFC 2324. See Hyper Text Coffee Pot Control Protocol for more information.
  
  csHTTP_RESPONSE_422 ='422 Unprocessable Entity';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918. The request was well-formed but was unable to be followed due to semantic errors.
  cnHTTP_RESPONSE_422 =422; //< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918. The request was well-formed but was unable to be followed due to semantic errors.
  
  csHTTP_RESPONSE_423 ='423 Locked';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918. The resource that is being accessed is locked
  cnHTTP_RESPONSE_423 =423;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918. The resource that is being accessed is locked
    
  csHTTP_RESPONSE_424 ='424 Failed Dependency';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918.  The request failed due to failure of a previous request (e.g. a PROPPATCH).
  cnHTTP_RESPONSE_424 =424;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related RFC 4918.  The request failed due to failure of a previous request (e.g. a PROPPATCH).
  
  csHTTP_RESPONSE_425 ='425 Unordered Collection';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related. Defined in drafts of WebDav Advanced Collections, but not present in "Web Distributed Authoring and Versioning (WebDAV) Ordered Collections Protocol" (RFC 3648 ). Defined in drafts of WebDav Advanced Collections, but not present in "Web Distributed Authoring and Versioning (WebDAV) Ordered Collections Protocol" (RFC 3648 ).
  cnHTTP_RESPONSE_425 =425;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. WebDAV related. Defined in drafts of WebDav Advanced Collections, but not present in "Web Distributed Authoring and Versioning (WebDAV) Ordered Collections Protocol" (RFC 3648 ). Defined in drafts of WebDav Advanced Collections, but not present in "Web Distributed Authoring and Versioning (WebDAV) Ordered Collections Protocol" (RFC 3648 ).
  
  csHTTP_RESPONSE_426 ='426 Upgrade Required';//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. (RFC 2817 ) The client should switch to TLS/1.0.
  cnHTTP_RESPONSE_426 =426;//< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. (RFC 2817) The client should switch to TLS/1.0.
  
  csHTTP_RESPONSE_449 ='449 Retry With'; //< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. A Microsoft extension. The request should be retried after doing the appropriate action.
  cnHTTP_RESPONSE_449 =449; //< 4xx Client Error - The request contains bad syntax or cannot be fulfilled. The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and whether it is a temporary or permanent condition. These status codes are applicable to any request method. User agents should display any included entity to the user. These are typically the most common error codes encountered while online. A Microsoft extension. The request should be retried after doing the appropriate action.
  {}
  //--------------------------------
  // 5xx Server Error - The server failed to fulfil an apparently valid request.
  //--------------------------------
  //Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method.
  {}
  csHTTP_RESPONSE_500 ='500 Internal Server Error'; //< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. A generic error message, given when no more specific message is suitable.
  cnHTTP_RESPONSE_500 =500;//< 5xx Server Error - The server failed to fulfill an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. A generic error message, given when no more specific message is suitable.
  
  csHTTP_RESPONSE_501 ='501 Not Implemented';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server either does not recognise the request method, or it lacks the ability to fulfil the request.
  cnHTTP_RESPONSE_501 =501;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server either does not recognise the request method, or it lacks the ability to fulfil the request.
  
  csHTTP_RESPONSE_502 ='502 Bad Gateway';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server was acting as a gateway or proxy and received an invalid response from the upstream server.
  cnHTTP_RESPONSE_502 =502;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server was acting as a gateway or proxy and received an invalid response from the upstream server.
  
  csHTTP_RESPONSE_503 ='503 Service Unavailable';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
  cnHTTP_RESPONSE_503 =503;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
  
  csHTTP_RESPONSE_504 ='504 Gateway Timeout';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server was acting as a gateway or proxy and did not receive a timely request from the upstream server.
  cnHTTP_RESPONSE_504 =504;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server was acting as a gateway or proxy and did not receive a timely request from the upstream server.
  
  csHTTP_RESPONSE_505 ='505 HTTP Version Not Supported';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server does not support the HTTP protocol version used in the request.
  cnHTTP_RESPONSE_505 =505;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. The server does not support the HTTP protocol version used in the request.
  
  csHTTP_RESPONSE_506 ='506 Variant Also Negotiates';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (RFC 2295 ) Transparent content negotiation for the request, results in a circular reference.
  cnHTTP_RESPONSE_506 =506;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (RFC 2295) Transparent content negotiation for the request, results in a circular reference.
  
  csHTTP_RESPONSE_507 ='507 Insufficient Storage';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. WebDAV related (RFC 4918)
  cnHTTP_RESPONSE_507 =507;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. WebDAV related (RFC 4918)
  
  csHTTP_RESPONSE_509 ='509 Bandwidth Limit Exceeded';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (Apache bw/limited extension) This status code, while used by many servers, is not specified in any RFCs.
  cnHTTP_RESPONSE_509 =509;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (Apache bw/limited extension) This status code, while used by many servers, is not specified in any RFCs.
  
  csHTTP_RESPONSE_510 ='510 Not Extended';//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an objectcontaining an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (RFC 2774 ) Further extensions to the request are required for the server to fulfil it
  cnHTTP_RESPONSE_510 =510;//< 5xx Server Error - The server failed to fulfil an apparently valid request. Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should include an object containing an explanation of the error situation, and indicate whether it is a temporary or permanent condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any request method. (RFC 2774) Further extensions to the request are required for the server to fulfil it
{}
//=============================================================================




{IFDEF FILEBASED_IPC}
{}
// This structure can be used whereever ansistring name value pairs are useful in code.
Type rtNameValuePair = Record
  saName: AnsiString;
  saValue: AnsiString;
End;
{}

Const 
// cn_MaxEnvVariables is a hardcoded value that gets compiled into the rtCGI structure and may be used in code.
// This value indicates the absolute maximum number of CGI environment variables can be processed by a requset.
cn_MaxEnvVariables = 200;
// cn_MaxEnvWarnThreshold is a value always less than the value in cn_MaxEnvVariables. If the number of environment
// variables coming in a request meet or exceed this value, the software should respond in some way. At the time
// of writing this comment, code surrounding this constant dumps a line to a log file to give warning that this 
// threshold value was met or eceeded.
cn_MaxEnvWarnThreshold = 150;
      
//-------------- The CGI Environment Gets Pushed in here
{}
// This structure is a compact (lean and light weight) to store CGI application request information
// without involving dependancies on classes and other code that could result in a larger binary
// executable. This was inspired by the needs and goals of the Jegas LittleBoy-BigBoy CGI paradigm.
// in short, this type of CGI programming makes way for getting features found in FAST CGI without 
// needing to compile any code into the webserver itself. e.g. use a jegas CGI app (little boy) 
// on a normal webserver with CGI ability, that CGI app gets the request and sends it to software 
// already loaded and running in memory (big boy) to process the request. The results are then sent 
// back to the CGI application. CGI app ends up being smaller, and bigboy makes it so CGI app isn't
// required to make database connections, load a lot of configuration information etc before work
// is performed to satisfy the request.
Type rtCGI = Record
  uEnvVarCount: UInt; //< How Many ENV Variables
  arNVPair: array [0..cn_MaxEnvVariables-1] Of rtNameValuePair;//<Array of name value pairs which hold environment variables sent to CGI app by server.
  
  iRequestMethodIndex: Integer; //< Set to WHICH in the Array of EnvPairs that
                                // have the request method (GET or POST)

  {}
  // POST SPECIFIC - if not post - assumed GET or a "got nothing" 
  //(I think technically a "got nothing" is a GET...).
  // true if POST Recieved
  bPost: Boolean; 
  saPostData: AnsiString; //< Data streamed in from the post request.
  iPostContentTypeIndex: Integer; //< Set to WHICH in the Array of EnvPairs that have the CONTENT_TYPE Env Values
  uPostContentLength: Integer;//<Length of the posted content in bytes.
  //2016-04-16 - saJegasFile: ansistring; //<I think this field has depreciated 2010-01-16 - Jason
End;  
{}
//--------------------------------------------------------
{ENDIF}









//=============================================================================
// IOAppend
//=============================================================================
{}
// # of times to attempt IO functions when there
// is a failure. Picture 50 programs slamming a given log file - this helps
// prevent most bumping because the writes are fast one liners of text USUALLY
// at least if used in a log file role.
Const cnIOAppendMaxTries = 10;
{}
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!GFX 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// returns plot position that would center something p_i4Size inside p_i4Range
Function iPlotCenter(p_i4Range: LongInt; p_i4Size: LongInt): Longint;
{}
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!OS
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// This orignally just worked on windows, and calls the sleep API call.
// Now 2006-09-15 - Added conditional define so that in linux, sysutils unit
// gets included - and performs their generic "sleep" function. Free the 
// processor up - thats what I needed.
//
// The idea is to be able to make a program yield when it doesn't need the CPU
// at the moment.
Procedure Yield(p_uMilliSeconds:UINT);
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!FILE IO
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// Returns a string containing ERROR text for the given IOREsult Error
// code. 
Function sIOResult(p_u2: Word): String;
//=============================================================================
{}
// Returns a string containing ERROR text for the given IOREsult Error
// code. This version allows language specifier. "en" is the default=English.
// Note: As you translate this code base, you will need to address this 
// function but at the least the architecture is in place to make it possible.
// If you are worried about tight compiled binaries, you can set the 
// LANGUAGES_TO_INCLUDE define located in i01_jegas_macros.pp
// Also see declarations like: cnLANG_ENGLISH
Function sIOResult(p_u2: Word; p_u2Language: word): String;
//=============================================================================


//-----------------------------------------------------------------------------
{}
// Note: This function appends p_saFilename, if it exists, with data passed
// in p_saData. If the file does not exist, it is created if possible.
// The function returns TRUE if successful and false if not. IF you 
// wish to see the FREEPASCAL returned IORESULT (error code) then the 
// (by reference) passing of p_u2IOREsult (an unsigned word) will contain 
// the offending cause.
// Two versions of the routine are supplied, one that allows you to interrogate
// the IORESULT, and one that assumes the boolean result (TRUE it worked) is
// enough for you.
//
// NOTE: NOT THREADSAFE
//
// append an ansistring to existing file - or write new file using it
// this variation does not return error code, just true if successful
//
// p_saFilename: Name of File to be appended
// p_saData: Text/Or stream of bytes stuffed in an ansistring
//           to be appended. Note: ASCII EOL Not Sent!!!!!!!
//           See ixx_jegas_macros.pp for csEOL.
Function bIOAppend_NOT_TS(p_saFilename: ansiString; p_saData: AnsiString): Boolean;
{}
//----------------------
{}
// Note: This function appends p_saFilename, if it exists, with data passed
// in p_saData. If the file does not exist, it is created if possible.
// The function returns TRUE if successful and false if not. IF you 
// wish to see the FREEPASCAL returned IORESULT (error code) then the 
// (by reference) passing of p_u2IOREsult (an unsigned word) will contain 
// the offending cause.
// Two versions of the routine are supplied, one that allows you to interrogate
// the IORESULT, and one that assumes the boolean result (TRUE it worked) is
// enough for you.
//
// NOTE: NOT THREADSAFE
//
// append an ansistring to existing file - or write new file using it
// this variation does not return error code, just true if successful
//
// p_saFilename: Name of File to be appended
// p_saData: Text/Or stream of bytes stuffed in an ansistring
//           to be appended. Note: ASCII EOL Not Sent!!!!!!!
//           See ixx_jegas_macros.pp for csEOL.
// This variation returns the IORESULT - see sIOResult function.
Function bIOAppend_NOT_TS(p_saFilename: ansiString; p_saData: AnsiString; var p_u2IOResult: Word): Boolean;
//-----------------------------------------------------------------------------


//=============================================================================
{}
// Simply Loads the text file you specify in p_sa and returns the whole thing
// as a string -
//   NOTE: CR/LF or whatever is removed by readln of file text and
//         replaced with CR/LF on Windows and just LF on other OS's
//
// TRUE=Success, False=Errors
//   You can check the ioresult value in the second calling variation by
//   passing a word vari for the resultant ioresult.
//
//  p_saData contains all successfully read data.
//
// Small Files - Don't go crazy. ;)
Function bLoadTextfile(p_sa: ansiString; Var p_saData: AnsiString):Boolean;
// Simply Loads the text file you specify in p_sa and returns the whole thing
// as a string -
//   NOTE: CR/LF or whatever is removed by readln of file text and
//         replaced with CR/LF on Windows and just LF on other OS's
//
// TRUE=Success, False=Errors
//   You can check the ioresult value in the second calling variation by
//   passing a word vari for the resultant ioresult.
//
//  p_saData contains all successfully read data.
//
// Small Files - Don't go crazy. ;)
Function bLoadTextfile(p_sa: ansiString; Var p_saData: AnsiString; Var p_u2IOResult: Word):Boolean;
//=============================================================================
{}
// Slow, Sure Fire READ ONLY Method. I recommend Using bLoadFile opposed to this
// Because this method reads ONE char at a time whereas bLoadFile does
// MUCH faster block reads. I Noticed, on linux anyway, that the BLOCKREAD
// seems to need FULL ACCESS (read/write) on the file for it to work,
// therefore, in trying to come up with a way to read READONLY files that
// DOESN'T respond to TEXT (Treats incoming as Binary...AS IS or RAW) I did
// this. IF anyone know a FASTER method...Do Share! B^)
Function bLoadFileRO(p_saSrc: ansiString; Var p_saData: AnsiString):Boolean;
// Slow, Sure Fire READ ONLY Method. I recommend Using bLoadFile opposed to this
// Because this method reads ONE char at a time whereas bLoadFile does
// MUCH faster block reads. I Noticed, on linux anyway, that the BLOCKREAD
// seems to need FULL ACCESS (read/write) on the file for it to work,
// therefore, in trying to come up with a way to read READONLY files that
// DOESN'T respond to TEXT (Treats incoming as Binary...AS IS or RAW) I did
// this. IF anyone know a FASTER method...Do Share! B^)
Function bLoadFileRO(p_saSrc: ansiString; Var p_saData: AnsiString; Var p_u2IOResult: Word):Boolean;
//=============================================================================
{}
// loads specified file into p_saData. USes Block Read, any speed loss
// would be from the constant appending to the p_sadata as the file loads.
Function bLoadFile(p_saSrc: ansiString; Var p_saData: AnsiString):Boolean;
// loads specified file into p_saData. USes Block Read, any speed loss
// would be from the constant appending to the p_sadata as the file loads.
Function bLoadFile(p_saSrc: ansiString; Var p_saData: AnsiString; Var p_u2IOResult: Word):Boolean;
//=============================================================================
{}
// Returns 16 bit CRC calculated on the file passed in p_saSrcFile
// Returns 0 if anything wrong or zero length file or file of all zero bytes
// I suppose would do it.
Function u2GetCRC16(p_saSrcFile: ansiString):word;
//=============================================================================
{}
// Returns 64 bit CRC calculated on the file passed in p_saSrcFile
// Returns 0 if anything wrong or zero length file or file of all zero bytes
// I suppose would do it.
Function u8GetCRC64(p_saSrcFile: ansiString):word;
//=============================================================================
{}
// converts slashes in directory paths to the correct ones for the operating
// system.
function saFixSlash( p_sa: ansistring): ansistring;
//=============================================================================
























//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!STRINGS and CONVERSION
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
{}
// Pass a char 0-F (not case sensitive) - it returns the Value in hex -
// illegal chars comeback as ZERO. Only returning a nyble no matter what.
Function u1Hex(p_ch: Char): Byte; inline;
//=============================================================================
{}
// Pass this function a char and a 2 digit hex value is returned to represent the byte 
function sCharToHex(p_ch: char): string; inline;
//=============================================================================
{}
// Pass this function a char and a 2 digit hex value is returned to represent the byte 
function sByteToHex(p_b1: byte): string; inline;
//=============================================================================
{}
// Convert Hex to Unsigned 64bit number
// NOTE: No verification of validity of the hex digits is done. Also,
//       No NON-HEX digits are expected and results are undefined for non-hex
//       characters!!!
function u8HexToU8(p_s: string): uint64;
//=============================================================================
{}
// Convert Unsigned 64bit number to Hex
function sU8ToHex(p_u8: uInt64): string;
//=============================================================================
{}
// TODO: OverHaul this to a REgular Expression Like converter.
// Was about to do this 2006-05-07 but its going to take awhile 
// but should be done. The tricky part that I'm ready to tackle tonight
// is the fact that support needs to made for escaping both unicode and ASCII,
// and the reciprocal of this regular expression deal is having to convert
// octal sequences like \377 <-- Yup that COULD be octal! 3 digi's after slash.
// Anyways, this is what it is for now. 
// There is code in this lib somewhere (saDecodeURI) that handles escaping for 
// the URL requests, and back in that format that looks like %20Hello%20Dude,
// perhaps this should be an option: Original HumanReadable, with the 
// (#xx)  where xx=ascii value 0-255 enclosed in paren's, The URL escaping,
// or the RegularExpression Escaping. that is, make three modes.
Function saHumanReadable(p_sa: AnsiString): AnsiString;
//=============================================================================

//=============================================================================
{}
// Old Name: saTranslatedCGI
// This function turns those pesky URL Encoded strings that look like:
// Hello%20Dude%20 to Hello Dude. you want to do this AFTER you broke
// the string into Name and Value pairs.
// - OK - New Name Taken - OldName was: saTranslatedCGI
Function saDecodeURI(p_sa: AnsiString): AnsiString;
//=============================================================================

//=============================================================================
{}
// Old Name: saTranslatedCGI
// This function makes data URI encoded. 
// Hello Dude to Hello%20Dude%20
// IMPORTANT: This function translates EVERYTHING not in ' 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
// Spaces are turned to pluses (+)
// This means if you want to encode multiple URI parameters, you need to something like:
// sa:='http://someurl/somefile.html?param1=' +saEncodeURI(thedata1)+'&param2'+saEncodeURI(thedata1);  
Function saEncodeURI(p_sa: AnsiString): AnsiString;
//=============================================================================



//=============================================================================
{}
// This function - originally existed in the strings unit but was snagged here
// to prevent circular references. This is the core unit (planned for) of many
// thing but the main reason it was started was for the system to be able to
// record a log for debugging itself.
//
// NOTE: Two Calls, one with implicit control of case sensitivity, one without.
// This version is NOT case sensistive, and is shorthand for the latter)
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;p_saReplaceWith:AnsiString): AnsiString;
// This function - originally existed in the strings unit but was snagged here
// to prevent circular references. This is the core unit (planned for) of many
// thing but the main reason it was started was for the system to be able to
// record a log for debugging itself.
//
// NOTE: Two Calls, one with implicit control of case sensitivity, one without.
// This version is allows you to specify case sensistivity.
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_saReplaceWith:AnsiString;  p_bCaseSensitive: Boolean): AnsiString;
//--
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u4ReplaceWith:cardinal): AnsiString;
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u4ReplaceWith:cardinal;  p_bCaseSensitive: Boolean): AnsiString;
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u8ReplaceWith:uint64): AnsiString;
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u8ReplaceWith:uint64;  p_bCaseSensitive: Boolean): AnsiString;
//=============================================================================



//=============================================================================
{}
// This is the short string variety of saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;p_saReplaceWith:AnsiString): AnsiString;
Function sSNRStr(p_s: String; p_sSearchFor: String;p_sReplaceWith:String): String;
// This is the short string variety of saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_saReplaceWith:AnsiString;  p_bCaseSensitive: Boolean): AnsiString;
Function sSNRStr(p_s: String; p_sSearchFor: String;  p_sReplaceWith:string;  p_bCaseSensitive: Boolean): String;
//=============================================================================
{}
// for formmating - use freepascal's str directly with 
// str(number:digits:decimals, stringresult);
//
// *************************************************************************
// NOTE: Use inttostr instead, unless you want lean an mean and your
// application is purposely intended to not have the sysutils FPC RTL unit 
// used or other OOP code with the intention being to create tiny executables.
// *************************************************************************
//
Function sIntToStr(p_i8:Int64):String; inline;
//=============================================================================
{}
// Pass this a longint and you get a ansistring with comma format
// Cheap - Works up to 4g 4,xxx,xxx,xxx
Function sFormatLongIntWithCommas(p_i4: LongInt): String; inline;
//=============================================================================
{}
// Replaces FPC "DELETE" because it fails with BIG strings and RightStr
// in the SYSUTILS unit seems to work - so This is a "remake" of the
// FPC "Delete" functionality - hopefully without a bug.
Procedure DeleteString(Var p_sa: AnsiString; p_uStart, p_uCount: UInt);
//=============================================================================
{}
// This routine returns the string you pass it but set to a fixed width.
// Additionally it requires you to specify what part of the passed string
// you want returned; you set the start position and how many chars to be 
// processed. There are two versions of this function. One allows you 
// to additionally pass what the padding character to use when adding chars
// to the end of the result if required. The other one uses a space character 
// as the default; we call this the shorthand version. B^)
//
// This is the shorthand version - the pad character is a space (ascii 32dec)
Function saFixedLength(p_sa: AnsiString; p_uStart, p_uLen: uint): AnsiString;
{}
// This routine returns the string you pass it but set to a fixed width.
// Additionally it requires you to specify what part of the passed string
// you want returned; you set the start position and how many chars to be 
// processed. There are two versions of this function. One allows you 
// to additionally pass what the padding character to use when adding chars
// to the end of the result if required. The other one uses a space character 
// as the default; we call this the shorthand version. B^)
//
// This is the Longhand version - allows setting the pad char explicitly.
Function saFixedLength(p_sa: AnsiString; p_uStart, p_uLen: uint; p_chPadchar: char): AnsiString;
{}
//=============================================================================
{}
Function sYesNoFixedLength(p_b:Boolean): String; inline; //< "YES" or "NO " - Note Space after "NO "
//=============================================================================
{}
Function sTrueFalseFixedLength(p_b: Boolean): String; inline;//< "TRUE " or "FALSE" - Note space after "TRUE "
//=============================================================================
{}
// Returns parameter ansistring in reverse - Hello becomes olleH
Function saReverse(p_sa: AnsiString): AnsiString;
//=============================================================================
{}
// searchs string for instances of p_chSearchFor that aren't paired
// In a Pair, one is removed
// EXAMPLE: "John && Bob" Would Become "John & Bob" if Searching for "&"
//          If a single "&" was found, it would be replaced with
//          p_chReplaceWith
Function saSpecialSNR(Var p_sa: AnsiString; p_chSearchFor: Char;p_chReplaceWith: Char): AnsiString;
//=============================================================================
{}
// searchs string for instances of p_chSearchFor and replaces it with
Function saSNR(Var p_sa: AnsiString;p_chSearchFor: Char;p_chReplaceWith: Char): AnsiString;
//=============================================================================
{}
// this is the short string variety of Function saSNR(Var p_sa: AnsiString;p_chSearchFor: Char;p_chReplaceWith: Char): AnsiString;
Function sSNR(Var p_s: String;p_chSearchFor: Char;p_chReplaceWith: Char): String;
//=============================================================================
{}
// Returns p_i as string with leading zeroes. Length specified in p_u1Length
Function sZeroPadInt(p_i8: int64; p_u1Length: byte): String;
//=============================================================================
// Returns p_u as string with leading zeroes. Length specified in p_u1Length
Function sZeroPadUInt(p_u8: uint64; p_u1Length: byte): String;
//=============================================================================
function sDelimitInt(p_I: INT): string;inline;
//=============================================================================
function sDelimitUInt(p_U: UINT): string;
//=============================================================================



{}
// Returns p_sa as string with leading SPACES. Length specified in p_uLength
// RightJustify
Function saRJustify(p_sa: AnsiString;p_uLength: uint): AnsiString;
//=============================================================================
{}
// Returns p_i as string with leading SPACES. Length specified in p_u1Length
Function sRJustifyInt(p_i8,p_u1Length: byte): String;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function i1Val(p_s: String): shortint; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function i4Val(p_s: String): longint; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function i8Val(p_s: String): Int64; inline;
//=============================================================================
// Converts string to Int64 - using i8Val function internally
Function iVal(p_s: String):Int64; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function u1Val(p_s: String): byte; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function u2Val(p_s: String): word; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function u4Val(p_s: String): cardinal; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers 
// returns value - returns ZERO if it can't figure it out
function u8Val(p_s: String): UInt64; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected integers
// returns value - returns ZERO if it can't figure it out
function uVal(p_s: String): UInt64; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected REAL (Floating Point)
// returns value - returns ZERO if it can't figure it out
Function fpVal(p_s: String): Real; inline;
//=============================================================================
{}
// Pass TRimmed string containing suspected Currency (fixed decimal)
// returns value - returns ZERO if it can't figure it out
Function fdVal(p_s: String): currency; inline;
//=============================================================================
{}
// Converts Anything NON A-Z, a-z, 0-9 into underscore and returns converted
// String as result - Tailored for MySQL. 
Function saMySQLScrub(p_sa: AnsiString):AnsiString;
//=============================================================================
{}
// Does Some Changes to make going to MS SQL (And Access) a little easier.
Function saSQLScrub(p_sa: AnsiString):AnsiString;
//=============================================================================
{}
// Makes Sure LAST char in string has DOSSLASH (i03_target.pas)
// IF YOU SEND EMPTY STRING - YOU GET EMPTY STRING (Think Current DIR)
Function saAddSlash(p_sa:AnsiString):AnsiString;
//=============================================================================
{}
// Same as saAddSlash but regardless of OS platform - puts forward slash
// (think web)
// IF YOU SEND EMPTY STRING - YOU GET EMPTY STRING (Think Current Dir)
Function saAddFwdSlash(p_sa: AnsiString):AnsiString;
//=============================================================================
{}
// This function returns a tree directory relative path based on the
// file you pass it. It works by chopping the file name you pass it
// into p_iSize Chunks, p_iLevels (chunks), and returns the relative path
// without a leading slash BUT with an ending slash. No Checking is done
// other than length(p_saFilename)>=pi_size * i_iLevels. You need to make
// Sure you don't get "." periods in the parts of the filename getting
// chunked or you app most likely won't work.
//
// Example: MyRelPAth:=saFileToTree('F10023.txt, 2,2);
//          
//          MyRelPath = 'F1/00/' (Uses DOSSLASH)
//
Function saFileToTreeDOS(p_saFilename: AnsiString;p_u1Size, p_u1Levels: byte): AnsiString;
//=============================================================================
{}
// This function returns a tree directory relative path based on the 
// file you pass it. It works by chopping the file name you pass it
// into p_iSize Chunks, p_iLevels (chunks), and returns the relative path
// without a leading slash BUT with an ending slash. No Checking is done
// other than length(p_saFilename)>=pi_size * i_iLevels. You need to make
// Sure you don't get "." periods in the parts of the filename getting
// chunked or you app most likely won't work.
//
// Example: MyRelPAth:=saFileToTree('F10023.txt, 2,2);
//
//          MyRelPath = 'F1/00/' (Uses Forward Slash ALWAYS)
//
Function saFileToTreeFWDSlash(p_saFilename: AnsiString; p_u1Size, p_u1Levels: byte): AnsiString;
//=============================================================================
{}
// This function converts text to HTML safe codes in theory
Function saHTMLScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{}
// This function converts HTML safe codes back
Function saHTMLUnScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{}
// Takes a string and turns it to TRUE or FALSE as best it can.
// does convert to lower case before trying to discern anything 
// looks for TRUE: "1" "true" "t" "TRUE" "T" "YES" "Yes" "Y" "ON" "On"
// looks for FALSE: everything else
// 
//
// Replaces:
//   Function bYesNo(p_saYesNo: AnsiString): Boolean;
//   Function bTrueFalse(p_saTrueFalse: AnsiString):Boolean;
//   Function bOnOff(p_saTrueFalse: AnsiString):Boolean;
Function bVal(p_s: String): boolean; inline;
//=============================================================================
{}
Function saJegasLogoRawHtml: AnsiString;
//==========================================================================
{}
// Returns English "Yes" or "No " The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "Yes" or "No "
Function sYesNo(p_b:Boolean): String; inline;
//==========================================================================
{}
// Returns English "True" or "False" The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "True " or "False"
Function sTrueFalse(p_b: Boolean): String; inline;
//==========================================================================
{}
// NOTE: For (Function bOnOff(p_sOnOff: AnsiString): Boolean;) Use bVal()
//       in ug_common.pp I believe - Jason
Function sOnOff(p_b:Boolean): string; inline;
//==========================================================================
{}
// This function XORs an entire string using the passed key parameter.
Function saXorString(p_sa: AnsiString; p_u1Key: Byte):AnsiString;
//==========================================================================
{}
// bare minimum text scramble - strong enough to not be plain text
// and not suffer the xor issues from one char set to another across
// javascript, the browser versus the server. It doesn't always translate
// regardless of the whys. This is an effort to just use characters that
// make even the sent passwords for login/changing password mangled enough
// that if the data flies across a console - its hidden. in the database
// its hidden.
function saScramble(p_sa: ansistring): ansistring;
//==========================================================================

{}
// pass a char and how many of it you want back - "Repated" ...
// and that's what you get.
Function saRepeatChar(p_ch: Char; p_uHowMany: uint): AnsiString;
//==========================================================================
{}
// Returns a '1' or a '0' as an ansistring
Function cOneZero(p_b: Boolean):char;
//=============================================================================






//top



































//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************









//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!GFX 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
// returns plot position that would center something p_i4Size inside p_i4Range
Function iPlotCenter(p_i4Range: longint; p_i4Size: longint): Integer;
//=============================================================================
Begin
  Result:=((p_i4Range-p_i4Size) Div 2)+1;
End;
//=============================================================================










//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!OS
//*****************************************************************************
//=============================================================================
//*****************************************************************************


{$IFDEF Windows}
Procedure WinSleep(dwMilliseconds:dword); External 'kernel32' name 'Sleep';
{$ENDIF}
//=============================================================================
Procedure Yield(p_uMilliSeconds:UINT);
//=============================================================================
{$IFDEF WINDOWS}
var dw: dword;
{$ENDIF}

Begin
  {$IFDEF WINDOWS}
  dw:=p_uMilliseconds;
  WinSleep(dw);
  //Sleep(p_uMilliseconds);
  {$ELSE}
  Sleep(p_uMilliseconds);
  {$ENDIF}
End;
//=============================================================================














//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!FILE IO
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=============================================================================
// Returns an ansistring containing ERROR text for the given IOREsult Error
// code. 
// TODO: MultiLanguage Support.
Function sIOResult(p_u2: Word): String;
//=============================================================================
begin
  result:=sIOResult(p_u2,cnLANG_ENGLISH);
end;
//=============================================================================

//=============================================================================
Function sIOResult(p_u2: Word; p_u2Language: word): String;
//=============================================================================
Begin
  //case p_u2Language of
    Case p_u2 Of
    0: Result:='No Error';
    // DOS Errors
    2: Result:='DOS:File Not Found.';
    3: Result:='DOS:Path not Found.';
    4: Result:='DOS:Too many open Files.';
    5: Result:='DOS:Access Denied.';
    6: Result:='DOS:Invalid File Handle.';
    12: Result:='DOS:Invalid File Access Number.';
    15: Result:='DOS:Invalid Disk Number.';
    16: Result:='DOS:Cannot Remove Current Directory.';
    17: Result:='DOS:Cannot Rename Accross Volumes.';
    // IO Errors
    100: Result:='IO:Error when reading from disk.';
    101: Result:='IO:Error when writing to disk.';
    102: Result:='IO:File Not Assigned.';
    103: Result:='IO:File Not Open.';
    104: Result:='IO:File Not opened for Input.';
    105: Result:='IO:File not opened for output.';
    106: Result:='IO:Invalid Filenumber.';
    // Fatal Errors - Causing massive hemorraging and bleeding
    //                Seek MEdical Attention Promptly or you
    //                will see the "RING" - The Blue Screen of DEATH!
    150: Result:='FATAL:Disk is write protected.';
    151: Result:='FATAL:Unknown device.';
    152: Result:='FATAL:Drive Not Ready.';
    153: Result:='FATAL:Unknown Command.';
    154: Result:='FATAL:CRC Check Failed.';
    155: Result:='FATAL:Invalid Drive Specified.';
    156: Result:='FATAL:Seek Error on Disk.';
    157: Result:='FATAL:Invalid Media Type.';
    158: Result:='FATAL:Sector Not Found.';
    159: Result:='FATAL:Printer out of Paper.';
    160: Result:='FATAL:Error when writing to device.';
    161: Result:='FATAL:Error when reading from device.';
    162: Result:='FATAL:Hardware Failure.';
    60000: Result:='Access Denied or Disk Full';
    Else Begin
      Result:='?????:Unexpected Error Code:' + sIntToStr(p_u2);
    End;
    End; //switch
  //end;
  //end;//switch
  Result:=sIntToStr(p_u2)+' '+Result;
End;
//=============================================================================




//=============================================================================
// append an ansistring to existing file - or write new file using it
// this variation does not return error code, just true if successful
Function bIOAppend_NOT_TS(
  p_saFilename: ansiString;
  p_saData: AnsiString
): Boolean;
//=============================================================================
Var u2IOresultDummy: Word;
Begin
  u2IOresultDummy:=0;
  Result := bIOAppend_NOT_TS(p_saFileName, p_saData, u2IOResultDummy);
End; 
//=============================================================================
// append an ansistring to existing file - or write new file using it
// this variation returns the IORESULT - see sIOResult function.
Function bIOAppend_NOT_TS(
  p_saFilename: ansiString;
  p_saData: AnsiString;
  var p_u2IOResult: Word
): Boolean;
//=============================================================================
Var Text_File: text;
    i4Tries: longint;
    bTextFileOpened: Boolean;
    u2LastIOResult: Word;
    u2ClosingIOResult: Word;
    
Begin
  Result:=False;
  i4Tries:=0;
  p_u2IOResult:= 0;
  assign(Text_File,p_saFilename);
  repeat
    i4Tries+=1;
    bTextFileOpened:= true;
    {$I-}
    If Fileexists(p_saFilename) Then
    Begin
      try append(Text_File);except on e:exception do bTextFileOpened:= False; end;//try
    End
    Else
    Begin
      try rewrite(Text_File);except on e:exception do bTextFileOpened:= False; end;//try
    End;
    {$I+}
    u2LastIOResult:=ioresult;
    bTextFileOpened:=(u2LastIOResult=0);
  Until bTextFileOpened OR (i4Tries = cnIOAppendMaxTries);
  If bTextFileOpened Then Begin
     {$I-}
     try Write(Text_File,p_saData);except on e:exception do ; end;//try
     {$I+}
     try u2LastIOResult:=ioresult;except on e:exception do ; end;//try
     {$I-}
     try close(Text_File);except on e:exception do ; end;//try
     {$I+}
     u2ClosingIOResult:=ioresult;
     If u2LastIOResult<>0 Then Begin
       p_u2IOResult:= u2LastIOResult;
     End Else Begin
       p_u2IOResult:= u2ClosingIOResult;
     End;
  End;
  Result:=bTextFileOpened and (p_u2IOResult=0);
End;
//=============================================================================







//=============================================================================
// Simply Loads the text file you specify in p_sa and returns the whole thing
// as a string - NOTE: CR/LF or whatever is removed by readln of file text and
// replaced with CR/LF on Windows and just LF on other OS's If there are any
// Errors (returns False) You can check the ioresult value in this
// units global library_ioresult. p_saData contains all successfully read data.
// Small Files - Don't go crazy.
Function bLoadTextfile(
  p_sa: ansiString;
  Var p_saData: AnsiString
):Boolean;
Var u2IOResult: Word;
Begin u2IOResult:=0; Result:=bLoadTextFile(p_sa, p_saData, u2IOResult); End;
Function bLoadTextfile(
  p_sa: ansiString;
  Var p_saData: AnsiString;
  Var p_u2IOResult: Word
):Boolean;
//=============================================================================
Var
 f: File;
 b: array [0..1023] Of Byte;
 lpB: pointer;
 lpSA: pointer;
 uOldLen: UInt;
 i2NumRead: SmallInt;
 bOk: boolean;
Begin
  //riteln('BEGIN ug_common - bLoadTextFile');
  bOk:=FileExists(p_sa);
  //if not bOk then
  //begin
  //  writeln('ug_common - bLoadTextFile file missing? Lamer! ' + p_sa);
  //end;

  if bOk then
  begin
    p_saData:='';i2NumRead:=0;uOldLen:=0;p_u2IOResult:=0;
    assign(f,p_sa);
    p_u2IOResult:=ioresult;
    bOk:=(p_u2IOResult=0);
    //if not bOk then
    //begin
    //  writeln('ug_common - bLoadTextFile ',p_u2IOResult,' ',sIOResult(p_u2IOResult));
    //end;
  end;

  if bOk then
  Begin
    { reset will open read-only }
    { While this is true, it doesn't seem safe for multithreading.
      meaning this can get out of whack if a multi-threaded app
      is performing this same trick. Therefore I recommend that
      the FileMode value only be handled by CRITICALSECTION
      CODE... PERIOD.. so this doesn't sneak in as an elusive
      bug where calls to RESET hang!
      e.g. pseudo steps:
        * enter critical section
        * set filemode
        * open file
        * exit critical section

      if all threads do this - no stomp using that file mode flag.

    }
    //oldfilemode := filemode;
    //riteln('bloadtextfile - b4 reset');
    filemode := 0;
    try reset(f,1); except on e:exception do ; end;//try
    //riteln('bloadtextfile - after reset');

    //filemode := READ_ONLY;    <---- doesnt work in linux -
    //                         needs r/w access for block read/write stuff even
    //                         for readonly

    p_u2IOResult:=ioresult;//ioresult is a READ oNCE variable. it resets, so wise to store it right away
    bOk:=(p_u2IOResult=0);
    //if not bOk then
    //begin
    //  writeln('ug_common - bLoadTextFile after reset ',p_u2IOResult,' ',sIOResult(p_u2IOResult));
    //end;
  end;

  While bOk and (not Eof(f)) Do Begin // got to love the left to right evaluation here :) Stops at first failure - so safe construct now ;)
    //readln(f,sa);
    //rite('blockread...');
    try blockread(f,b,sizeof(b),i2NumRead);except on e:exception do p_u2IOResult:=60000; end;//try
    //riteln('is done.');
    p_u2IOResult+=ioresult;
    bOk:=p_u2IOResult=0;
    //if not bOk then
    //begin
    //  writeln('ug_common - bLoadTextFile blockread loop ',p_u2IOResult,' ',sIOResult(p_u2IOResult));
    //end;

    if bOk then
    begin
      //p_saData:=p_saData+sa+MAC_EOL;
      uOldLen:=length(p_saData);
      setlength(p_saData, uOldLen+i2NumRead);
      lpB:=@b;lpSA:=pointer(UInt(pointer(p_saData))+uOldLen);
      move(lpB^,lpSA^,i2NumRead);
    End;
  end;//while

  {I-}
  try close(f); except on e:exception do ; end;//try
  {I+}
  Result:=bOk;
  //riteln('END ug_common - bLoadTextFile');
End;
//=============================================================================










//=============================================================================
Function bLoadFile(p_saSrc: ansiString; Var p_saData: AnsiString):Boolean;
Var u2IOResult: Word;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bLoadFile200609191857',SOURCEFILE);
  {$ENDIF}

  u2IOResult:=0;
  Result:=bLoadFile(p_saSrc, p_saData, u2IOResult);
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bLoadFile200609191857',SOURCEFILE);
  {$ENDIF}
End;
Function bLoadFile(p_saSrc: ansiString; Var p_saData: AnsiString; Var p_u2IOResult: Word):Boolean;
//=============================================================================
Var fin: File Of Byte;
//    u1: Byte;
    iNumRead: SmallInt;
    //iNumWritten:integer;
    lpDest: pointer;
    uLen: UInt;
    uLenB4: UInt;

    au1Buf: array Of Byte;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bLoadFile200609191858',SOURCEFILE);
  {$ENDIF}

  setlength(au1Buf,gi4FileIO_BufferSize);

  uLen:=0;

  Result:=False;
  p_saData:='';
  p_u2IOResult:=0;
  assign(fin, p_saSrc);
  {$I-}
  try reset(fin,1); except on e:exception do p_u2IOResult:=60000; end;//try
  {$I+}
  p_u2IOResult+=ioresult;
  If p_u2IOResult=0 Then Begin
    repeat
      try BlockRead(fin, au1buf, sizeof(au1buf), iNumRead); except on e:exception do p_u2IOREsult:=60000; end;//try
      p_u2IOResult+=ioresult;
      If p_u2IOResult=0 Then
      Begin
        uLenB4:=uLen;
        uLen+=UInt(iNumRead);
        SetLength(p_saData,uLen);
        lpDest:=pointer(p_saData);
        UInt(lpDest):=UInt(lpDest)+uLenB4;
        move(au1buf, lpDest^, iNumRead);
      End;
    Until (iNumRead=0) OR (p_u2IOResult<>0);
    try close(fin); except on e:exception do; end;//try
  End;
  Result:=p_u2IOResult=0;
  // In Linux(anyways) then BlockRead Method seems to need WRITE access to
  // work. It is faster so we will try that first. If The Error is Access
  // Denied - We Can Try a Slower Method for the sake of trying to make the
  // thing work - Slower is better than a failure I would think.
  // Has to do freepascal not doing block functions unless in readwrite mode :(
  If p_u2IOResult=5 Then Begin // ACCESS DENIED
    Result:=bLoadFileRO(p_saSrc,p_saData);
  End;
  setlength(au1buf,0);
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bLoadFile200609191858',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================





//=============================================================================
// Slow, Sure Fire READ ONLY Method
Function bLoadFileRO(p_saSrc: AnsiString; Var p_saData: AnsiString):Boolean;
Var u2IOResult: Word;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bLoadFileRO200609191854',SOURCEFILE);
  {$ENDIF}

  u2IOResult:=0;
  Result:=bLoadFileRO(p_saSrc, p_saData, u2IOResult);

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bLoadFileRO',SOURCEFILE);
  {$ENDIF}
End;
//---
Function bLoadFileRO(p_saSrc: ansiString; Var p_saData: AnsiString; Var p_u2IOResult: Word):Boolean;
//=============================================================================
Var fin: text;
    ch: Char;
    au1Buf: array Of Byte;
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('bLoadFileRO200609191855',SOURCEFILE);
  {$ENDIF}
  setlength(au1buf,gi4FileIO_BufferSize);
  Result:=False;
  p_saData:='';
  p_u2IOResult:=0;
  assign(fin, p_saSrc);
  {$I-}
  SetTextBuf(fin, au1Buf);
  p_u2IOResult:=ioresult;
  If p_u2IOResult=0 Then
  Begin
    try reset(fin); except on E:Exception do p_u2IOResult:=60000; end;//try
    p_u2IOResult+=ioresult;
  End;
  {$I+}
  If p_u2IOResult=0 Then
  Begin
    While (not Eof(fin)) and (p_u2IOResult=0) Do Begin
      {$I-}
      try read(fin,ch); except on E:Exception do p_u2IOResult:=60000; end;//try
      {$I+}
      p_u2IOResult:=ioresult;
      If p_u2IOResult=0 Then Begin
        p_saData:=p_saData+ch;
      End;
    End; // while
    {$I-}
    try close(fin); except on E:Exception do ; end;//try
    {$I+}
  End;
  Result:=p_u2IOResult=0;
  setlength(au1buf,0);
  {$IFDEF DEBUGBEGINEND}
    DebugOUT('bLoadFileRO200609191855',SOURCEFILE);
  {$ENDIF}
End;
//=============================================================================






//=============================================================================
Function u2GetCRC16(p_saSrcFile: ansiString):word;
//=============================================================================
var
    //au1Buf: array [0..65536] Of Byte;//64k
    //au1Buf: array [0..524266] Of Byte;//half meg
    {IFNDEF LINUX}
    // au1Buf: array [0..1048576] Of Byte;//meg
    au1Buf: array [0..(1048576*4)] Of Byte;// 4 meg !!!!!! :)
    {ELSE}
    //au1Buf: array [0..(1048576*4)] Of Byte;// 4 meg !!!!!! :)
    //au1Buf: array [0..16777216] Of Byte;//16 megs DOUBT IT
    {ENDIF}
  bOk: boolean;
  f: file of byte;
  u2IOResult: word;
  iNumRead,i: longint;//32bit for buffer length.... I THINK big enough lol
  CRC16:word;
begin
  bOk:=true;
  CRC16:=0;
  filemode:=READ_WRITE; //MIGHT NOT BE ABLE TO DO BLOCK READ with READ ONLY hmm
  assign(f, p_saSrcFile);
  try
    reset(f,1);
  except on E:Exception do u2IOResult:=60000;
  end;//try
  u2IOResult+=ioresult;
  If u2IOResult=0 Then
  Begin
    repeat
      try BlockRead(f, au1buf, sizeof(au1buf), inumread); except on E:EXception do;end;
      u2IOResult:=ioresult;//ioresult is a read once then it it resets.so we use u2IOResult
      If u2IOResult=0 Then for i:=0 to inumread-1 do CRC16+=au1Buf[i];
    Until (inumread=0) OR (u2IOResult<>0);
  End;
  if bOk then try close(f); except on e:exception do;end;
  if u2IOResult<>0 then writeln(sIOREsult(u2IOResult));
  result:=CRC16;
End;
//=============================================================================

//=============================================================================
Function u8GetCRC64(p_saSrcFile: ansiString):word;
//=============================================================================
var
    //au1Buf: array [0..65536] Of Byte;//64k
    //au1Buf: array [0..524266] Of Byte;//half meg
    {IFNDEF LINUX}
    // au1Buf: array [0..1048576] Of Byte;//meg
    au1Buf: array [0..(1048576*4)] Of Byte;// 4 meg !!!!!! :)
    {ELSE}
    //au1Buf: array [0..(1048576*4)] Of Byte;// 4 meg !!!!!! :)
    //au1Buf: array [0..16777216] Of Byte;//16 megs DOUBT IT
    {ENDIF}
  f: file of byte;
  u2IOResult: word;
  iNumRead,i: longint;//32bit for buffer length.... I THINK big enough lol
  CRC64:word;
begin
  CRC64:=0;
  filemode:=READ_WRITE; //MIGHT NOT BE ABLE TO DO BLOCK READ with READ ONLY hmm
  assign(f, p_saSrcFile);
  try
    reset(f,1);
  except on E:Exception do u2IOResult:=60000;end;//try
  u2IOResult+=ioresult;
  If u2IOResult=0 Then
  Begin
    repeat
      try BlockRead(f, au1buf, sizeof(au1buf), inumread); except on E:EXception do;end;
      u2IOResult:=ioresult;//ioresult is a read once then it it resets.so we use u2IOResult
      If u2IOResult=0 Then for i:=0 to inumread-1 do CRC64+=au1Buf[i];
    Until (inumread=0) OR (u2IOResult<>0);
  End;
  try close(f); except on e:exception do;end;//try
  if u2IOResult<>0 then writeln(sIOREsult(u2IOResult));
  result:=CRC64;
End;
//=============================================================================




//=============================================================================
function saFixSlash( p_sa: ansistring): ansistring;
//=============================================================================
begin
  {$IFDEF WINDOWS}
  result:=saSNRStr(p_sa,'/','\');
  {$ELSE}
  result:=saSNRStr(p_sa,'\','/');
  {$ENDIF}
end;
//=============================================================================






















































//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Strings and Conversions (Like HEX to Decimal etc) (Date Stuff Separate)
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
// TODO: Is this really even needed?
// Pass this a longint and you get an ansistring with comma format
// Cheap - Works up to 4g 4,xxx,xxx,xxx
Function sFormatLongIntWithCommas(p_i4: LongInt): String;
//=============================================================================
Begin
  Result:=sIntToStr(p_i4);
  If p_i4>999 Then insert(',',Result,length(Result)-2);
  If p_i4>999999 Then insert(',',Result,length(Result)-6);    
  If p_i4>999999999 Then insert(',',Result,length(Result)-10);
End;
//=============================================================================


//=============================================================================
// This function returns a tree directory relative path based on the 
// file you pass it. It works by chopping the file name you pass it
// into p_iSize Chunks, p_iLevels (chunks), and returns the relative path
// without a leading slash BUT with an ending slash. No Checking is done
// other than length(p_saFilename)>=pi_size * i_iLevels. You need to make
// Sure you don't get "." periods in the parts of the filename getting
// chunked or you app most likely won't work.
//
// Example: MyRelPAth:=saFileToTree('F10023.txt, 2,2);
//          
//          MyRelPath = 'F1/00/' (Uses DOSSLASH)
//
Function saFileToTreeDOS(
  p_saFilename: AnsiString;
  p_u1Size, p_u1Levels: byte
): AnsiString;
//=============================================================================
Var 
  u1Len: byte;
  u1: byte;
Begin
  Result:='';
  u1Len:=length(p_saFilename);
  If (u1Len>0) and (u1Len>=p_u1Size*p_u1Levels) Then Begin
    For u1:= 1 To p_u1Levels Do Begin
      Result+=copy(p_saFilename, (u1*p_u1Size)-p_u1Size+1, p_u1Size) + DOSSLASH;
    End;
  End;
End;
//=============================================================================


//=============================================================================
// This function returns a tree directory relative path based on the
// file you pass it. It works by chopping the file name you pass it
// into p_iSize Chunks, p_iLevels (chunks), and returns the relative path
// without a leading slash BUT with an ending slash. No Checking is done
// other than length(p_saFilename)>=pi_size * i_iLevels. You need to make
// Sure you don't get "." periods in the parts of the filename getting
// chunked or you app most likely won't work.
//
// Example: MyRelPAth:=saFileToTree('F10023.txt, 2,2);
//
//          MyRelPath = 'F1/00/' (Uses Forward Slash ALWAYS)
//
Function saFileToTreeFWDSlash(p_saFilename: AnsiString;p_u1Size, p_u1Levels: byte): AnsiString;
//=============================================================================
Var
  u1Len: byte;
  u1: byte;
Begin
  Result:='';
  u1Len:=length(p_saFilename);
  If (u1Len>0) and (u1Len>=p_u1Size*p_u1Levels) Then Begin
    For u1:= 1 To p_u1Levels Do Begin
      Result:=Result+copy(p_saFilename, (u1*p_u1Size)-p_u1Size+1, p_u1Size) + '/';
    End;
  End;
End;
//=============================================================================







//=============================================================================
// keep as ansistring - urls longer than 255
Function saAddFWDSlash(p_sa:AnsiString): AnsiString;
//=============================================================================
Begin
  Result:=trim(p_sa);
  If (length(p_sa)>0) Then Begin
    If RightStr(p_sa,1)<>'/' Then Result:=Result+'/';
  End Else Begin
    //result:='/';
  End;
End;
//=============================================================================



//=============================================================================
// used for any os - uses correct dos "slash" or directory divider.... blahblah
// leave as ansi :)
Function saAddSlash(p_sa:AnsiString): AnsiString;
//=============================================================================
Begin
  Result:=trim(p_sa);
  //riteln('BEFORE ADDSLASH:',p_sa);
  If (length(p_sa)>0) Then Begin
    If RightStr(p_sa,1)<>DOSSLASH Then Result:=Result+DOSSLASH;
  End Else Begin
    //result:=DOSSLASH;
  End;
  //riteln('AFTER ADDSLASH:',result);
End;
//=============================================================================


//=============================================================================
// Does Some Changes to make going to MySQL DB a little easier.
// Regular Expression Syntax used.
Function saMySQLScrub(p_sa: AnsiString):AnsiString;
//=============================================================================
Var i4: longint;
    i4_psalen: longint;
Begin
  Result:='';
  i4_psalen:=length(p_sa);
  If i4_psalen>0 Then Begin
    For i4:=1 To i4_psalen Do Begin
      Case p_sa[i4] Of
      #0: Result +='(!NULL!)';
      //#1: Result +='\001';
      //#2: Result +='\002';
      //#3: Result +='\003';
      //#4: Result +='\004';
      //#5: Result +='\005';
      //#6: Result +='\006';
      //#7: Result +='\007';
      //#8: Result +='\008';
      #9: Result +='\t';
      #10:Result +='\n';
      //#11:Result +='\011';
      //#12:Result +='\012';
      #13:Result +='\r';
      //'''':Result+='''''';// Double Escapes it (for MySQL)
      '''':Result+='\''';// Double Escapes it (for MySQL)
      '"':Result+='\"';// Double Escapes it (for MySQL)
      
      '`':Result+='``';// TRIES to Double Escape (For MySQL)
      '\':Result+='\\';
      Else
        Result+=p_sa[i4];
      End;//case
    End;
  End;
End;
//=============================================================================

//=============================================================================
// Does Some Changes to make going to MS SQL (And Access) a little easier.
Function saSQLScrub(p_sa: AnsiString):AnsiString;
//=============================================================================
Var u8: longint;
    u8psalen: longint;
Begin
  Result:='';
  u8psalen:=length(p_sa);
  If u8psalen>0 Then Begin
    For u8:=1 To u8psalen Do Begin
      Case p_sa[u8] Of
      '''':Result+='''''';// Double Escapes it (for MySQL)
      Else
        Result+=p_sa[u8];
      End;//case
    End;
  End;
End;
//=============================================================================


//=============================================================================
// Pass Trimmed string containing suspected 8bit Int 
// returns value - returns ZERO if it can't figure it out
function i1Val(p_s: String): shortint;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 32bit Int 
// returns value - returns ZERO if it can't figure it out
function i4Val(p_s: String): longint;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 64bit Int 
// returns value - returns ZERO if it can't figure it out
function i8Val(p_s: String): Int64;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 64bit Int (Uses i8Val Internally)
// returns value - returns ZERO if it can't figure it out
function iVal(p_s: String): Int64;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 8bit Unsigned Int 
// returns value - returns ZERO if it can't figure it out
function u1Val(p_s: String): byte;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 16bit Unsigned Int 
// returns value - returns ZERO if it can't figure it out
function u2Val(p_s: String): word;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 32bit Unsigned Int 
// returns value - returns ZERO if it can't figure it out
function u4Val(p_s: String): cardinal;
//=============================================================================
var u2Code: word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================


//=============================================================================
// Pass Trimmed string containing suspected 64bit Unsigned Int
// returns value - returns ZERO if it can't figure it out
function u8Val(p_s: String): UInt64;
//=============================================================================
var u2Code: word;
Begin
  // 9223 3720 3685 4780 000
  // 2012 0913 0929 1166 088
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected 64bit Unsigned Int
// returns value - returns ZERO if it can't figure it out
function uVal(p_s: String): UInt64;
//=============================================================================
Begin
  result:=u8Val(p_s);
End;
//=============================================================================



//=============================================================================
// Pass Trimmed string containing suspected 64bit Unsigned Int
// returns value - returns ZERO if it can't figure it out
function uVal_homebrew_hold(p_s: String): UInt64;
//=============================================================================
var
  u: UInt;
  u8Out: uint64;
  u8Ten: UInt64;
  bOk: boolean;
Begin
  // 9223 3720 3685 4780 000
  // 2012 0913 0929 1166 088
  //riteln;
  //rite('u8Val passed: '+p_sa);
  bOk:=true;
  u8Out:=0;
  p_s:=saTrim(p_s);
  if length(p_s)>0 then
  begin
    for u:=1 to length(p_s) do
    begin
      if (ord(p_s[u])<48) or (ord(p_s[u])>57) then
      begin
        bOk:=false;
        break;
      end;
    end;

    if bOk then
    begin
      u8Ten:=1;
      for u:=length(p_s) downto 1 do
      begin
        //riteln('ten:',u8ten,' ',p_sa[i],' u8:',u8);
        u8Out+=(ord(p_s[u])-48)*u8Ten;
        u8Ten:=(u8Ten*10);
      end;
    end;
  end;
  result:=u8Out;
  //riteln(' Result: u8Val(',p_sa,')=',result);//,' u2code:',u2Code);
  //riteln;
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected REAL (Floating Point)
// returns value - returns ZERO if it can't figure it out
Function fpVal(p_s: String): Real;
//=============================================================================
Var u2Code: Word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,Result,u2Code);
End;
//=============================================================================

//=============================================================================
// Pass Trimmed string containing suspected REAL (Floating Point)
// returns value - returns ZERO if it can't figure it out
Function fdVal(p_s: String): currency;
//=============================================================================
Var u2Code: Word;
Begin
  u2Code:=0;
  u2Code:=u2Code;
  val(p_s,Result,u2Code);
End;
//=============================================================================



//=============================================================================
Function sZeroPadInt(p_i8:Int64;p_u1Length: byte): String;
//=============================================================================
Var bNeg: Boolean;
Begin
  Result:='';
  bNeg:=p_i8<0;
  If bNeg Then p_i8:=p_i8*-1;
  Str(p_i8:p_u1Length, Result);
  Result:=sSNR(Result, ' ','0');
  If bNeg Then Result:='-'+Result;
End;
//=============================================================================


//=============================================================================
Function sZeroPadUInt(p_u8: uint64; p_u1Length: byte): String; inline;
//=============================================================================
Begin
  Result:='';
  Str(p_u8:p_u1Length, Result);
  Result:=sSNR(Result, ' ','0');
End;
//=============================================================================




//=============================================================================
function sDelimitInt(p_I: INT): string;
//=============================================================================
begin
  if p_I<0 then result:='-';
  result+=sDelimitUInt(abs(p_i));
end;
//=============================================================================

//=============================================================================
function sDelimitUInt(p_U: UINT): string;
//=============================================================================
var s: string;
    i: integer;
    u1Length: byte;
    u1Comma: byte;
begin
  result:='';
  s:=saReverse(inttostr(p_U));
  u1Length:=length(s);
  if u1Length >0 then
  begin
    u1Comma:=0;
    for i:=1 to u1Length do
    begin
      u1Comma+=1;
      if u1Comma=4 then
      begin
        result+=',';
        u1Comma:=1;
      end;
      result+=s[i];
    end;
    result:=saReverse(result);
  end
  else
  begin
    result:='0';
  end;
end;
//=============================================================================

















//=============================================================================
// Returns p_i as string with leading zeroes. Length specified in p_iLength
Function sRJustifyInt(p_i8,p_u1Length: byte): String;
//=============================================================================
Begin
  Result:='';
  Str(p_i8:p_u1Length, Result);
End;
//=============================================================================

//=============================================================================
// Returns p_sa as string, right Justified
Function saRJustify(p_sa: AnsiString;p_uLength: UInt): AnsiString;
//=============================================================================
Begin
  Result:=saReverse(saFixedLength(saReverse(p_sa),1,p_uLength));
End;
//=============================================================================




//=============================================================================
// searchs string for instances of p_chSearchFor and replaces it with
// p_chReplaceWith
//=============================================================================
Function saSNR( 
  Var p_sa: AnsiString;
  p_chSearchFor: Char;
  p_chReplaceWith: Char
): AnsiString;
//=============================================================================
Var u: Uint;
Begin
  Result:='';
  If Length(p_sa)>0 Then
  Begin
    For u:=1 To length(p_sa) Do Begin
      If p_sa[u]=p_chSearchFor Then Begin
        Result:=Result+p_chReplaceWith
      End Else Begin
        Result:=Result+p_sa[u];
      End;
    End;
  End;
End;
//=============================================================================





//=============================================================================
// searchs string for instances of p_chSearchFor and replaces it with
// p_chReplaceWith. This is the shortstring variety of saSNR
//=============================================================================
Function sSNR(
  Var p_s: String;
  p_chSearchFor: Char;
  p_chReplaceWith: Char
): String;
//=============================================================================
Var u1: byte;
Begin
  Result:='';
  If Length(p_s)>0 Then
  Begin
    For u1:=1 To length(p_s) Do Begin
      If p_s[u1]=p_chSearchFor Then Begin
        Result:=Result+p_chReplaceWith
      End Else Begin
        Result:=Result+p_s[u1];
      End;
    End;
  End;
End;
//=============================================================================















//=============================================================================
// searchs string for instances of p_chSearchFor that aren't paired
// In a Pair, one is removed
// EXAMPLE: "John && Bob" Would Become "John & Bob" if Searching for "&"
//          If a single "&" was found, it would be replaced with
//          p_chReplaceWith
//=============================================================================
Function saSpecialSNR(
  Var p_sa: AnsiString; 
  p_chSearchFor: Char;
  p_chReplaceWith: Char
): AnsiString;
//=============================================================================
Var u: uint; // current pos in sa
Begin
  Result:='';
  If length(p_sa)>0 Then
  Begin
    u:=1; Result:='';// sa:='&&My &&Test &Hot &&Key&';
    repeat 
      If (u<length(p_sa)) and
         (p_sa[u]=p_chSearchFor) and
         (p_sa[u+1]<>p_chSearchFor) Then
      Begin
        Result:=Result+p_chReplaceWith;
      End
      Else
      Begin
        If u<length(p_sa) Then
        Begin
          If (p_sa[u]=p_chSearchFor) and (p_sa[u+1]=p_chSearchFor) Then u+=1;
        End;
        Result:=Result+p_sa[u];
      End;
      u+=1;
    Until u > length(p_sa);
  End;
End;
//=============================================================================






//=============================================================================
Procedure DeleteString(Var p_sa: AnsiString; p_uStart, p_uCount: UINT);
//=============================================================================
Var uLen: UINT;
    saLeft, saRight: AnsiString;
Begin
  saLeft:='';
  saRight:='';
  uLen:=length(p_sa);
  If (uLen>0) and (p_uCount>0) Then
  Begin
    If (p_uStart<=uLen) Then
    Begin 
      If (p_uStart>1) Then
      Begin
        saLeft:=saLeftStr(p_sa,p_uStart-1);
      End;
      If (p_uStart+p_uCount-1)<uLen Then
      Begin
        saRight:=copy(p_sa, (p_uStart + p_uCount), uLen-(p_uStart+p_uCount-1));
      End;
      p_sa:=saLeft + saRight;
    End;
  End;
End;
//=============================================================================

//=============================================================================
Function saFixedLength(p_sa: AnsiString; p_uStart, p_uLen: UINT): AnsiString;
//=============================================================================
begin
  result:=saFixedLength(p_sa,p_uStart,p_uLen,' ');
End;
//=============================================================================

//=============================================================================
Function saFixedLength(p_sa: AnsiString; p_uStart, p_uLen: uint; p_chPadchar: char): AnsiString;
//=============================================================================
Var 
  uStop: uint;
  uReslen: uint;
  uPsalen: uint;
  u: uint;
Begin
  result:='';
  if p_uLen>0 then
  begin
    if p_uStart>0 then
    begin
      uStop:=p_uStart+p_uLen-1;
      upsalen:=length(p_sa);
      for u:=p_uStart to uStop do
      begin
        uresLen:=length(result);
        if (uResLen < p_uLen) and ( u <= upsalen ) then
        begin
          result+=p_sa[u];
        end;
      end;
    end;
    uresLen:=length(result);
    if uresLen<p_uLen then
    begin
      result+=StringOfChar(p_chPadChar, p_uLen-uresLen);
    end;    
  end;
End;
//=============================================================================



//=============================================================================
Function sYesNoFixedLength(p_b:Boolean): String; // "YES" or "NO "
//=============================================================================
Begin
  If p_B Then Result:='YES' Else Result:='NO ';//<Notice Space after NO
End;
//=============================================================================

//=============================================================================
Function sTrueFalseFixedLength(p_b: Boolean): String; // "TRUE " or "FALSE"
//=============================================================================
Begin
  If p_b Then Result:='TRUE ' Else Result := 'FALSE';//<Notice Space after TRUE
End;
//=============================================================================


//=============================================================================
// for formatting - use freepascal's str directly with 
// str(number:digits:decimals, stringresult);
Function sIntToStr(p_i8:Int64):String;
//=============================================================================
Var s: String;
Begin
  str(p_i8, s);
  Result:=s;
End;
////=============================================================================


//=============================================================================
Function u1Hex(p_ch: Char): Byte;
//=============================================================================
Begin
  Result:=(pos(upcase(p_ch), cs_hexvalues)-1) and $F;
End;
//=============================================================================

//=============================================================================
Function saHumanReadable(p_sa: AnsiString): AnsiString;
//=============================================================================
Var u: uint;
    sNumber: String[3];
Begin
  Result:='';
  If length(p_Sa)>0 Then
  Begin
    For u:=1 To length(p_sa) Do
    Begin
      If (p_sa[u]>=#32) and (p_sa[u]<=#127) Then
      Begin
        Result:=Result+p_sa[u];
      End
      Else
      Begin
        Str(Ord(p_sa[u]), sNumber);
        Result:=Result+'(#'+sNumber+')';
      End;
    End;  
  End;
End;
//=============================================================================








//=============================================================================
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u4ReplaceWith:cardinal): AnsiString;
//=============================================================================
begin
  result:=saSNRStr(p_sa,p_saSearchFor,inttostr(p_u4Replacewith));
end;
//=============================================================================

//=============================================================================
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u4ReplaceWith:cardinal;  p_bCaseSensitive: Boolean): AnsiString;
//=============================================================================
begin
  result:=saSNRStr(p_sa,p_saSearchFor,inttostr(p_u4Replacewith),p_bCaseSensitive);
end;
//=============================================================================

//=============================================================================
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u8ReplaceWith:uint64): AnsiString;
//=============================================================================
begin
  result:=saSNRStr(p_sa,p_saSearchFor,inttostr(p_u8Replacewith));
end;
//=============================================================================

//=============================================================================
Function saSNRStr(p_sa: AnsiString; p_saSearchFor: AnsiString;  p_u8ReplaceWith:uint64;  p_bCaseSensitive: Boolean): AnsiString;
//=============================================================================
begin
  result:=saSNRStr(p_sa,p_saSearchFor,inttostr(p_u8Replacewith),p_bCaseSensitive);
end;
//=============================================================================


//=============================================================================
// This version is NOT case sensistive, and is shorthand for the latter)
Function saSNRStr(
  p_sa: AnsiString;
  p_saSearchFor: AnsiString;
  p_saReplaceWith:AnsiString
): AnsiString;
Begin
  Result:=saSNRStr(p_sa, p_saSearchFor, p_saReplaceWith, False);
End;
//=============================================================================



//=============================================================================
Function saSNRStr(
  p_sa: AnsiString;//purposely NOT ByReference HERE cuz we chop it up
  p_saSearchFor: AnsiString;
  p_saReplaceWith:AnsiString;
  p_bCaseSensitive: Boolean
): AnsiString;
//=============================================================================
Var
  uPos: uint;
  saUP: AnsiString;
Begin
  If p_bCaseSensitive Then Begin
    repeat
      uPos:=pos(p_saSearchFor, p_sa);
      If uPos>0 Then Begin
        Delete(p_Sa, uPos, length(p_saSearchFor));
        Insert(p_saReplacewith,p_sa, uPos);
      End;
    Until uPos=0;
  End Else Begin
    saUP:=UpCase(p_sa);
    p_saSearchFor:=UPCASE(p_saSearchFor);
    repeat
      uPos:=pos(p_saSearchFor, saUP);
      If uPos>0 Then Begin
        Delete(p_Sa, uPos, length(p_saSearchFor));
        Delete(saUp, uPos, length(p_saSearchFor));;
        Insert(p_saReplacewith, p_sa, uPos);
        Insert(UPCASE(p_saReplacewith), saUP, uPos);
      End;
    Until uPos=0;
  End;
  Result:=p_sa;
End;
//=============================================================================






















//=============================================================================
// This version is NOT case sensistive, and is shorthand for the latter)
Function sSNRStr(
  p_s: String;
  p_sSearchFor: String;
  p_sReplaceWith:String
): String;
Begin
  Result:=sSNRStr(p_s, p_sSearchFor, p_sReplaceWith, False);
End;
//--(The latter below)
Function sSNRStr(
  p_s: String;//purposely NOT ByReference HERE cuz we chop it up
  p_sSearchFor: String;
  p_sReplaceWith:String;
  p_bCaseSensitive: Boolean
): String;
//=============================================================================
Var
  u1Pos: byte;
  sUP: String;
Begin
  If p_bCaseSensitive Then Begin
    repeat
      u1Pos:=pos(p_sSearchFor, p_s);
      If u1Pos>0 Then Begin
        Delete(p_S, u1Pos, length(p_sSearchFor));
        Insert(p_sReplacewith,p_s, u1Pos);
      End;
    Until u1Pos=0;
  End Else Begin
    sUP:=UpCase(p_s);
    p_sSearchFor:=UPCASE(p_sSearchFor);
    repeat
      u1Pos:=pos(p_sSearchFor, sUP);
      If u1Pos>0 Then Begin
        Delete(p_S, u1Pos, length(p_sSearchFor));
        Delete(sUp, u1Pos, length(p_sSearchFor));;
        Insert(p_sReplacewith, p_s, u1Pos);
        Insert(UPCASE(p_sReplacewith), sUP, u1Pos);
      End;
    Until u1Pos=0;
  End;
  Result:=p_s;
End;
//=============================================================================





























//=============================================================================
// Old Name: saTranslatedCGI
Function saDecodeURI(p_sa: AnsiString): AnsiString;
//=============================================================================
Var uPos: uint;
    bDone: Boolean;
Begin
  Result:='';
  bDone:=False;
  uPos:=1;
  While (uPos<= length(p_sa)) and (bDone=False) Do Begin
    If p_sa[uPos]='%' Then
    Begin
      // This could be an error condition if the actual p_sa value
      // doesn't have the two hex digits and we are at the end of the string.
      // That is what the bDone thing is all about.
      If (uPos+2 <= length(p_sa)) Then
      Begin
        Result:= Result+ Char(  (u1Hex(p_sa[uPos+1])*16)+u1Hex(p_sa[uPos+2]) );
        uPos+=3;
      End
      Else
      Begin
        uPos:=length(p_sa);
        bDone:=True;
      End;
    End
    Else
    Begin
      If p_sa[uPos]='+' Then
        Result:=Result+' '
      Else
        Result:=Result+p_sa[uPos];
      uPos+=1;
    End;
  End;
End;
//=============================================================================





//=============================================================================
function sCharToHex(p_ch: char): string;
//=============================================================================
var b1: byte;
    sHex: string;
begin
  b1:=byte(p_ch);
  sHex:=cs_HEXVALUES;
  result:=sHex[    (b1 shr 4)+1]+sHex[(b1 and 15)+1    ];
  //writeln('sChartoHex(',p_ch,'):',result);

end;
//=============================================================================

//=============================================================================
function sByteToHex(p_b1: byte): string;
//=============================================================================
begin
  result:=sCharToHex(char(p_b1));
  //riteln('sByteToHex(',p_b1,'):',result);
end;
//=============================================================================



//=============================================================================
// Convert Hex to Unsigned 64bit number
function u8HexToU8(p_s: string): uint64;
//=============================================================================
var
  s: string;
  u8Mult: uint64;
  u8: Uint64;
  i: integer;
begin
  u8:=0;
  u8Mult:=1;
  s:=upcase(saReverse(p_s));
  if length(s) > 0 then
  begin
    for i := 1 to length(s) do
    begin
      //riteln('POS:',pos(sa[i],cs_HEXVALUES)-1,sa[i]);
      u8+=(pos(s[i],cs_HEXVALUES)-1) * u8Mult;
      u8Mult:=u8Mult * 16;
    end;
  end;
  result:=u8;
end;
//=============================================================================

//=============================================================================
// Convert Unsigned 64bit number to Hex
function sU8ToHex(p_u8: uInt64): string;
//=============================================================================
var
  s: string;
  hx: array [0..7] of string[2];
  u1: byte;
  //u1Val: byte;

//Type rt8ByteCast = Packed Record
//  u1: array[0..7] Of Byte;
//End;
begin
  s:='';
  for u1:=0 to 7 do
  begin
    hx[u1]:=sByteToHex(rt8ByteCast(p_u8).u1[u1]);
    //riteln('--sU8toHex- hx[',u1,']=',hx[u1]);
  end;
  for u1:=7 downto 0 do s+=hx[u1];
  result:=s;
end;
//=============================================================================





//=============================================================================
Function saEncodeURI(p_sa: AnsiString): AnsiString;
//=============================================================================
Var uPos: uint;
    bDone: Boolean;
Begin
  Result:='';
  bDone:=False;
  uPos:=1;
  While (uPos<= length(p_sa)) and (bDone=False) Do Begin
    // ORIGINAL - Specd out pretty sure - but -
    // need to modify fo ajax sending html
    //If not (p_sa[uPos] in [' ','.','0'..'9','a'..'z','A'..'Z']) Then
    If not (p_sa[uPos] in [':',',','/',' ','.','0'..'9','a'..'z','A'..'Z']) Then
    Begin
      Result+=char('%')+sCharToHex(p_sa[uPos]);
    End
    Else
    Begin
      If p_sa[uPos]=' ' Then
      begin
        Result+='%20';
      end
      else
      begin
        Result+=p_sa[uPos];
      end;
    End;
    uPos+=1;
  End;
End;
//=============================================================================



//=============================================================================
// This function converts text to HTML safe codes in theory
Function saHTMLScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
var u: uint;
    uLen: uint;
    saResult: ansistring;
Begin
  uLen:=length(p_sa);
  saresult:='';
  if uLen>0 then
  begin
    for u := 1 to uLen do
    begin
      case p_sa[u] of
      '"': saResult+='&quot;';
      '''': saResult+='&apos;';
      '&': saresult+='[@AMP@]';
      '<': saresult+='&lt;';
      '>': saresult+='&gt;';
      //'-': saResult+='&ndash;';
      //'�': saResult+='&mdash;';
      //'�': saResult+='&iexcl;';
      //'�': saResult+='&iquest;';
      //'�': saResult+='&ldquo;';
      //'�': saResult+='&rdquo;';
      //'�': saResult+='&lsquo;';
      //'�': saResult+='&rsquo;';
      //'�': saResult+='&laquo;';
      //'�': saResult+='&raquo;';
      //' ': saResult+='&nbsp;';
      //'�': saResult+='&copy;';
      //'�': saResult+='&micro;';
      //'�': saResult+='&middot;';
      //'�': saResult+='&para;';
      //'�': saResult+='&plusmn;';
      //'�': saResult+='&reg;';
      //'�': saResult+='&sect;';
      //'�': saResult+='&trade;';

{
      #00: saResult+='&#00;';
      #01: saResult+='&#01;';
      #02: saResult+='&#02;';
      #03: saResult+='&#03;';
      #04: saResult+='&#04;';
      #05: saResult+='&#05;';
      #06: saResult+='&#06;';
      #07: saResult+='&#07;';
      #08: saResult+='&#08;';
      #09: saResult+='&#09;';
      #10: saResult+='&#10;';
      #11: saResult+='&#11;';
      #12: saResult+='&#12;';
      #13: saResult+='&#13;';
      #14: saResult+='&#14;';
      #15: saResult+='&#15;';
      #16: saResult+='&#16;';
      #17: saResult+='&#17;';
      #18: saResult+='&#18;';
      #19: saResult+='&#19;';
      #20: saResult+='&#20;';
      #21: saResult+='&#21;';
      #22: saResult+='&#22;';
      #23: saResult+='&#23;';
      #24: saResult+='&#24;';
      #25: saResult+='&#25;';
      #26: saResult+='&#26;';
      #27: saResult+='&#27;';
      #28: saResult+='&#28;';
      #29: saResult+='&#29;';
      #30: saResult+='&#30;';
      #31: saResult+='&#31;';
}


      else saresult+=p_sa[u];
      end;//end case 
    end;
  end;
  Result:=saSNRStr(saResult,'[@AMP@]','&amp;');
End;
//=============================================================================



//=============================================================================
// Takes a string and turns it to TRUE or FALSE as best it can.
Function bVal(p_s: String): boolean;
//=============================================================================
var s: string;
begin
  //riteln('in bVal');
  s:=Lowercase(Trim(p_s));
  result:=(s='on') or
          (s='1') or
          (s='t') or
          (s='true') or
          (s='y') or
          (s='yes') or
          (s='hell yeah') or
          (s='sure') or
          (s='of course');
  //riteln('leaving bVal');
end;
//=============================================================================



//=============================================================================
// This function converts text to HTML safe codes in theory
Function saHTMLUnScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
Begin
  Result:=saSNRStr(p_sa,  '&amp;'   ,'&');
  Result:=saSNRStr(Result,'&lt;'    ,'<');
  Result:=saSNRStr(Result,'&gt;'    ,'>');
  Result:=saSNRStr(Result,'&quot;'  ,'" ');
  Result:=saSNRStr(Result,'&apos;'  ,'''');
  Result:=saSNRStr(Result,'&#00;',#00);
  Result:=saSNRStr(Result,'&#01;',#01);
  Result:=saSNRStr(Result,'&#02;',#02);
  Result:=saSNRStr(Result,'&#03;',#03);
  Result:=saSNRStr(Result,'&#04;',#04);
  Result:=saSNRStr(Result,'&#05;',#05);
  Result:=saSNRStr(Result,'&#06;',#06);
  Result:=saSNRStr(Result,'&#07;',#07);
  Result:=saSNRStr(Result,'&#08;',#08);
  Result:=saSNRStr(Result,'&#09;',#09);
  Result:=saSNRStr(Result,'&#10;',#10);
  Result:=saSNRStr(Result,'&#11;',#11);
  Result:=saSNRStr(Result,'&#12;',#12);
  Result:=saSNRStr(Result,'&#13;',#13);
  Result:=saSNRStr(Result,'&#14;',#14);
  Result:=saSNRStr(Result,'&#15;',#15);
  Result:=saSNRStr(Result,'&#16;',#16);
  Result:=saSNRStr(Result,'&#17;',#17);
  Result:=saSNRStr(Result,'&#18;',#18);
  Result:=saSNRStr(Result,'&#19;',#19);
  Result:=saSNRStr(Result,'&#20;',#20);
  Result:=saSNRStr(Result,'&#21;',#21);
  Result:=saSNRStr(Result,'&#22;',#22);
  Result:=saSNRStr(Result,'&#23;',#23);
  Result:=saSNRStr(Result,'&#24;',#24);
  Result:=saSNRStr(Result,'&#25;',#25);
  Result:=saSNRStr(Result,'&#26;',#26);
  Result:=saSNRStr(Result,'&#27;',#27);
  Result:=saSNRStr(Result,'&#28;',#28);
  Result:=saSNRStr(Result,'&#29;',#29);
  Result:=saSNRStr(Result,'&#30;',#30);
  Result:=saSNRStr(Result,'&#31;',#31);
  
  //Result:=saSNRStr(Result,'&ndash;' ,'-' );
  //Result:=saSNRStr(Result,'&mdash;' ,'�' );
  //Result:=saSNRStr(Result,'&iexcl;' ,'�' );
  //Result:=saSNRStr(Result,'&iquest;','�' );
  //Result:=saSNRStr(Result,'&quot;'  ,'"' );
  //Result:=saSNRStr(Result,'&ldquo;' ,'�' );
  //Result:=saSNRStr(Result,'&rdquo;' ,'�' );
  //Result:=saSNRStr(Result,'&lsquo;' ,'�' );
  //Result:=saSNRStr(Result,'&rsquo;' ,'�' );
  //Result:=saSNRStr(Result,'&laquo;' ,'�' );
  //Result:=saSNRStr(Result,'&raquo;' ,'�' );
  //Result:=saSNRStr(Result,'&nbsp;'  ,' ' );
  //Result:=saSNRStr(Result,'&copy;'  ,'�' );
  //Result:=saSNRStr(Result,'&micro;' ,'�' );
  //Result:=saSNRStr(Result,'&middot;','�' );
  //Result:=saSNRStr(Result,'&para;'  ,'�' );
  //Result:=saSNRStr(Result,'&plusmn;','�' );
  //Result:=saSNRStr(Result,'&reg;'   ,'�' );
  //Result:=saSNRStr(Result,'&sect;'  ,'�' );
  //Result:=saSNRStr(Result,'&trade;' ,'�' );
End;
//=============================================================================





// seeuxg_common.pp for replacement
////==========================================================================
////Function saYesNo(p_bBoolean:Boolean): AnsiString;
////==========================================================================
//Begin
//  {$IFDEF DEBUGBEGINEND}
//    DebugIN('saYesNo',SOURCEFILE);
//  {$ENDIF}
//
//  If p_bBoolean Then Result:='Yes' Else Result:='No ';
//
//  {$IFDEF DEBUGBEGINEND}
//    DebugOUT('saYesNo',SOURCEFILE)
//  {$ENDIF}
//End;
////==========================================================================

// see ug_common.pp for replacement
////==========================================================================
//Function saTrueFalse(p_bBoolean: Boolean): AnsiString;
////==========================================================================
//Begin
//  {$IFDEF DEBUGBEGINEND}
//    DebugIN('saTrueFalse', SOURCEFILE)
//  {$ENDIF}
//
//  If p_bBoolean Then Result:='True ' Else Result:='False';
//
//  {$IFDEF DEBUGBEGINEND}
//    DebugOUT('saTrueFalse',SOURCECODE)
//  {$ENDIF}
//End;
////==========================================================================

//==========================================================================
Function saXorString(p_sa: AnsiString; p_u1Key: Byte):AnsiString;
//==========================================================================
Var u: uint;
    uLen: uint;
Begin
  Result:='';
  uLen:=length(p_sa);
  If uLen>0 Then
  Begin
    u:=0;
    repeat
      u+=1;
      Result+=Char(Byte(p_sa[u]) xor p_u1Key);
    Until u=uLen;
  End;


End;
//==========================================================================

//==========================================================================
function saScramble(p_sa: ansistring): ansistring;
//==========================================================================
var u: uint;
begin
  if length(p_sa)>0 then
  begin
    for u:=1 to length(p_sa) do
    begin
      case p_sa[u] of
      'A': p_sa[u]:='C';
      'B': p_sa[u]:='D';
      'C': p_sa[u]:='A';
      'D': p_sa[u]:='B';
      'E': p_sa[u]:='G';
      'F': p_sa[u]:='H';
      'G': p_sa[u]:='E';
      'H': p_sa[u]:='F';
      'I': p_sa[u]:='J';
      'J': p_sa[u]:='I';
      'K': p_sa[u]:='O';
      'L': p_sa[u]:='N';
      'M': p_sa[u]:='T';
      'N': p_sa[u]:='L';
      'O': p_sa[u]:='K';
      'P': p_sa[u]:='S';
      'Q': p_sa[u]:='R';
      'R': p_sa[u]:='Q';
      'S': p_sa[u]:='P';
      'T': p_sa[u]:='M';
      'U': p_sa[u]:='Z';
      'V': p_sa[u]:='X';
      'W': p_sa[u]:='Y';
      'X': p_sa[u]:='V';
      'Y': p_sa[u]:='W';
      'Z': p_sa[u]:='U';
      'a': p_sa[u]:='l';
      'b': p_sa[u]:='d';
      'c': p_sa[u]:='t';
      'd': p_sa[u]:='b';
      'e': p_sa[u]:='n';
      'f': p_sa[u]:='o';
      'g': p_sa[u]:='h';
      'h': p_sa[u]:='g';
      'i': p_sa[u]:='r';
      'j': p_sa[u]:='k';
      'k': p_sa[u]:='j';
      'l': p_sa[u]:='a';
      'm': p_sa[u]:='p';
      'n': p_sa[u]:='e';
      'o': p_sa[u]:='f';
      'p': p_sa[u]:='m';
      'q': p_sa[u]:='u';
      'r': p_sa[u]:='i';
      's': p_sa[u]:='v';
      't': p_sa[u]:='c';
      'u': p_sa[u]:='q';
      'v': p_sa[u]:='s';
      'w': p_sa[u]:='y';
      'x': p_sa[u]:='z';
      'y': p_sa[u]:='w';
      'z': p_sa[u]:='x';
      '1': p_sa[u]:='=';
      '2': p_sa[u]:='6';
      '3': p_sa[u]:='9';
      '4': p_sa[u]:='8';
      '5': p_sa[u]:='7';
      '6': p_sa[u]:='2';
      '7': p_sa[u]:='5';
      '8': p_sa[u]:='4';
      '9': p_sa[u]:='3';
      '0': p_sa[u]:='!';
      '!': p_sa[u]:='0';
      '@': p_sa[u]:='$';
      '#': p_sa[u]:='^';
      '$': p_sa[u]:='@';
      '%': p_sa[u]:='(';
      '^': p_sa[u]:='#';
      '&': p_sa[u]:='*';
      '*': p_sa[u]:='&';
      '(': p_sa[u]:='%';
      ')': p_sa[u]:='_';
      '_': p_sa[u]:=')';
      '+': p_sa[u]:='-';
      '-': p_sa[u]:='+';
      '=': p_sa[u]:='1';
      end;//case
    end;
  end;
  result:=p_sa;
end;
//==========================================================================


//==========================================================================
Function saRepeatChar(p_ch: Char; p_uHowMany: uint): AnsiString;
//==========================================================================
Begin
  Result:='';
  If p_uHowMany>0 Then
  Begin
    repeat
      Result+=p_ch;
      dec(p_uHowMany);
    Until p_uHowMany=0;
  End;
End;
//==========================================================================








//=============================================================================
Function saJegasLogoRawHtml: AnsiString;
//=============================================================================
Begin
  Result:='';
  Result+='<font style="font-family: monospace; font-weight: strong;">';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;________&nbsp;&nbsp;_______&nbsp;&nbsp;_______&nbsp;&nbsp;______&nbsp;&nbsp;_______<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;/___  ___/&nbsp;/ _____/&nbsp;/ _____/&nbsp;/&nbsp;__&nbsp;&nbsp;/&nbsp;/&nbsp;_____/<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;/__&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;___&nbsp;&nbsp;/&nbsp;/_/&nbsp;/&nbsp;/&nbsp;/____&nbsp;&nbsp;<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;____/&nbsp;&nbsp;/&nbsp;/&nbsp;/&nbsp;&nbsp;/&nbsp;/&nbsp;__&nbsp;&nbsp;/&nbsp;/____&nbsp;&nbsp;/&nbsp;&nbsp;<br />';
  Result+='&nbsp;____/&nbsp;/&nbsp;&nbsp;&nbsp;/&nbsp;/___&nbsp;&nbsp;&nbsp;/&nbsp;/__/&nbsp;/&nbsp;/&nbsp;/&nbsp;/&nbsp;/&nbsp;_____/&nbsp;/&nbsp;&nbsp;&nbsp;<br />';
  Result+='/_____/&nbsp;&nbsp;&nbsp;/______/&nbsp;/______/&nbsp;/_/&nbsp;/_/&nbsp;/______/&nbsp;&nbsp;&nbsp;&nbsp;<br />';
  Result+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Under the Hood</font><br />';
End;
//=============================================================================

//==========================================================================
Function sOnOff(p_b:Boolean):String;
//==========================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('sOnOff',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='On ' Else Result:='Off';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('sOnOff',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

//==========================================================================
Function cOneZero(p_b: Boolean):char;
//==========================================================================
Begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('cOneZero',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='1' Else Result:='0';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('cOneZero',SOURCEFILE)
  {$ENDIF}
End;
//==========================================================================

//==========================================================================
{}
// Returns English "Yes" or "No " The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "Yes" or "No "
Function sYesNo(p_b:Boolean): String;
//==========================================================================
begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('sYesNo',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='Yes' Else Result:='No ';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('sYesNo',SOURCEFILE)
  {$ENDIF}
end;
//==========================================================================


//==========================================================================
// Returns English "True" or "False" The Old version returned a fixed
// width version of this result - so I don't want to break code - SO...
// This returns "True " or "False"
Function sTrueFalse(p_b: Boolean): String;
//==========================================================================
begin
  {$IFDEF DEBUGBEGINEND}
    DebugIN('sTrueFalse',SOURCEFILE);
  {$ENDIF}

  If p_b Then Result:='True ' Else Result:='False';

  {$IFDEF DEBUGBEGINEND}
    DebugOUT('sYesNo',SOURCEFILE)
  {$ENDIF}
end;
//==========================================================================




//=============================================================================
function saReverse(p_sa: ansistring): ansistring;
//=============================================================================
var
  uLen: uInt;
  u: uInt;
  uBack: uInt;
begin
  result:='';
  uLen:=length(p_sa);
  if(uLen>0)then
  begin
    setlength(result,uLen);
    uBack:=uLen;
    for u:=1 to uLen do
    begin
      result[uBack]:=p_sa[u];
      uBack-=1;
    end;
  end;
end;
//=============================================================================







//=============================================================================
// Initialization
//=============================================================================
Begin
  UINTMAX := cnUINTMax;
  randomize;
End.
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
