program test_defaultformat_settings;
uses sysutils;

{
CurrencyFormat: 1
NegCurrFormat: 5
ThousandSeparator: ,
DecimalSeparator: .
CurrencyDecimals: 2
DateSeparator: /
TimeSeparator: :
ListSeparator: ,
CurrencyString: $
ShortDateFormat: mm/dd/yyyy
LongDateFormat: dd" "mmmm" "yyyy
TimeAMString: AM
TimePMString: PM
ShortTimeFormat: hh:nn
LongTimeFormat: hh:nn:ss
ShortMonthNames: Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,
LongMonthNames: January,February,March,April,May,June,July,August,September,October,November,December,
ShortDayNames: Sun,Mon,Tue,Wed,Thu,Fri,Sat,
LongDayNames: Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,
TwoDigitYearCenturyWindow: 50
}
var i: integer;
begin

  with DefaultFormatSettings do begin
    //ShortDateFormat:='mm/dd/yyyy';
    //DateSeparator:='/';
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
end.
