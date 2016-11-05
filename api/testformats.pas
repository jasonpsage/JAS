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

//=============================================================================
{ }
// This program is used for testing all kinds of things and is a sandbox
// application.
program testformats;
//=============================================================================

//=============================================================================
// GLOBAL DEFINES
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================

//=============================================================================
uses
//=============================================================================
  sysutils
,ug_common
,ug_jegas
;
//=============================================================================

//=============================================================================
var
//=============================================================================
  DT: TDateTime;
  JTask_Start_DT: Ansistring;
  i: integer;
//=============================================================================


//=============================================================================
begin

{
type TFormatSettings = record
  CurrencyFormat: Byte;             // Currency format string
  NegCurrFormat: Byte;              // Negative currency format string
  ThousandSeparator: Char;          // Thousands separator character
  DecimalSeparator: Char;           // Decimal separator character
  CurrencyDecimals: Byte;           // Currency decimals
  DateSeparator: Char;              // Date separator character
  TimeSeparator: Char;              // Time separator character
  ListSeparator: Char;              // List separator character
  CurrencyString: ;                 // Currency string
  ShortDateFormat: ;                // Short date format string
  LongDateFormat: ;                 // Long Date Format string
  TimeAMString: ;                   // AM time indicator string
  TimePMString: ;                   // PM time indicator string
  ShortTimeFormat: ;                // Short time format string
  LongTimeFormat: ;                 // Long time format string
  ShortMonthNames:                  // TMonthNameArray;Array with short month names
  LongMonthNames:                   // TMonthNameArray;Array with long month names
  ShortDayNames:                    // TWeekNameArray;Array with short day names
  LongDayNames:                     // TWeekNameArray;Long day names
  TwoDigitYearCenturyWindow: Word;  // Value for 2 digit year century window
end;
}
  with DefaultFormatSettings do begin
    //LongDateFormat:='yyyy-mm-dd';
    ShortDateFormat:='mm/dd/yyyy';
    DateSeparator:='/';
    
    writeln('CurrencyFormat: ',Currencyformat);
    writeln('NegCurrFormat: ',NegCurrFormat);
    writeln('ThousandSeparator: ',ThousandSeparator);
    writeln('DecimalSeparator: ',DecimalSeparator);
    writeln('CurrencyDecimals: ',CurrencyDecimals);
    writeln('DateSeparator: ',DateSeparator);
    writeln('TimeSeparator: ',TimeSeparator);
    writeln('ListSeparator: ',ListSeparator);
    writeln('CurrencyString: ',CurrencyString);
    writeln('ShortDateFormat: ',ShortDateFormat);
    writeln('LongDateFormat: ',LongDateFormat);
    writeln('TimeAMString: ',TimeAMString);
    writeln('TimePMString: ',TimePMString);
    writeln('ShortTimeFormat: ',ShortTimeFormat);
    writeln('LongTimeFormat: ',LongTimeFormat);
    write('ShortMonthNames: ');for i:=1 to 12 do write(ShortMonthNames[i],',');writeln;
    write('LongMonthNames: ');for i:=1 to 12 do write(LongMonthNames[i],',');writeln;
    write('ShortDayNames: ');for i:=1 to 7 do write(ShortDayNames[i],',');writeln;
    write('LongDayNames: ');for i:=1 to 7 do write(LongDayNames[i],',');writeln;
    writeln('TwoDigitYearCenturyWindow: ',TwoDigitYearCenturyWindow);
  end;//with
  

  JTask_Start_DT:='2012-02-07 01:13:00';
  //writeln('JTask_Start_DT: ',JTask_Start_DT);
  //writeln('JDATE Format 1: ',JDATE(JTask_Start_DT,1,11));
  dt:=StrToDateTime(JDATE(JTask_Start_DT,1,11));
  //dt:=StrToDate(JTask_Start_DT);

end.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

