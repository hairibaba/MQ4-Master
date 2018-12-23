//+------------------------------------------------------------------+
//|                                                       stdlib.mq4 |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2005-2015, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property library
//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code) {
   string error_string;
   switch(error_code) {
      //--- codes returned from trade server
      case 0    :	error_string="No error returned";	break;
      case 1    :	error_string="No error, trade conditions not changed";	break;
      case 2    :	error_string="Common error";	break;
      case 3    :	error_string="Invalid trade parameters";	break;
      case 4    :	error_string="Trade server is busy";	break;
      case 5    :	error_string="Old version of the client terminal";	break;
      case 6    :	error_string="No connection with trade server";	break;
      case 7    :	error_string="Not enough rights";	break;
      case 8    :	error_string="Too frequent requests";	break;
      case 9    :	error_string="Malfunctional trade operation";	break;
      case 64   :	error_string="Account disabled";	break;
      case 65   :	error_string="Invalid account";	break;
      case 128  :	error_string="Trade timeout";	break;
      case 129  :	error_string="Invalid price";	break;
      case 130  :	error_string="Invalid stops";	break;
      case 131  :	error_string="Invalid trade volume";	break;
      case 132  :	error_string="Market is closed";	break;
      case 133  :	error_string="Trade is disabled";	break;
      case 134  :	error_string="Not enough money";	break;
      case 135  :	error_string="Price changed";	break;
      case 136  :	error_string="Off quotes";	break;
      case 137  :	error_string="Broker is busy";	break;
      case 138  :	error_string="Requote";	break;
      case 139  :	error_string="Order is locked";	break;
      case 140  :	error_string="Buy orders only allowed";	break;
      case 141  :	error_string="Too many requests";	break;
      case 145  :	error_string="Modification denied because order is too close to market";	break;
      case 146  :	error_string="Trade context is busy";	break;
      case 147  :	error_string="Expirations are denied by broker";	break;
      case 148  :	error_string="The amount of open and pending orders has reached the limit";	break;
      case 149  :	error_string="Hedging is prohibited";	break;
      case 150  :	error_string="Prohibited by FIFO rules";	break;
      case 4000 :	error_string="No error returned";	break;
      case 4001 :	error_string="Wrong function pointer";	break;
      case 4002 :	error_string="Array index is out of range";	break;
      case 4003 :	error_string="No memory for function call stack";	break;
      case 4004 :	error_string="Recursive stack overflow";	break;
      case 4005 :	error_string="Not enough stack for parameter";	break;
      case 4006 :	error_string="No memory for parameter string";	break;
      case 4007 :	error_string="No memory for temp string";	break;
      case 4008 :	error_string="Not initialized string";	break;
      case 4009 :	error_string="Not initialized string in array";	break;
      case 4010 :	error_string="No memory for array string";	break;
      case 4011 :	error_string="Too long string";	break;
      case 4012 :	error_string="Remainder from zero divide";	break;
      case 4013 :	error_string="Zero divide";	break;
      case 4014 :	error_string="Unknown command";	break;
      case 4015 :	error_string="Wrong jump (never generated error)";	break;
      case 4016 :	error_string="Not initialized array";	break;
      case 4017 :	error_string="DLL calls are not allowed";	break;
      case 4018 :	error_string="Cannot load library";	break;
      case 4019 :	error_string="Cannot call function";	break;
      case 4020 :	error_string="Expert function calls are not allowed";	break;
      case 4021 :	error_string="Not enough memory for temp string returned from function";	break;
      case 4022 :	error_string="System is busy (never generated error)";	break;
      case 4023 :	error_string="DLL-function call critical error";	break;
      case 4024 :	error_string="Internal error";	break;
      case 4025 :	error_string="Out of memory";	break;
      case 4026 :	error_string="Invalid pointer";	break;
      case 4027 :	error_string="Too many formatters in the format function";	break;
      case 4028 :	error_string="Parameters count exceeds formatters count";	break;
      case 4029 :	error_string="Invalid array";	break;
      case 4030 :	error_string="No reply from chart";	break;
      case 4050 :	error_string="Invalid function parameters count";	break;
      case 4051 :	error_string="Invalid function parameter value";	break;
      case 4052 :	error_string="String function internal error";	break;
      case 4053 :	error_string="Some array error";	break;
      case 4054 :	error_string="Incorrect series array using";	break;
      case 4055 :	error_string="Custom indicator error";	break;
      case 4056 :	error_string="Arrays are incompatible";	break;
      case 4057 :	error_string="Global variables processing error";	break;
      case 4058 :	error_string="Global variable not found";	break;
      case 4059 :	error_string="Function is not allowed in testing mode";	break;
      case 4060 :	error_string="Function is not allowed for call";	break;
      case 4061 :	error_string="Send mail error";	break;
      case 4062 :	error_string="String parameter expected";	break;
      case 4063 :	error_string="Integer parameter expected";	break;
      case 4064 :	error_string="Double parameter expected";	break;
      case 4065 :	error_string="Array as parameter expected";	break;
      case 4066 :	error_string="Requested history data is in updating state";	break;
      case 4067 :	error_string="Internal trade error";	break;
      case 4068 :	error_string="Resource not found";	break;
      case 4069 :	error_string="Resource not supported";	break;
      case 4070 :	error_string="Duplicate resource";	break;
      case 4071 :	error_string="Custom indicator cannot initialize";	break;
      case 4072 :	error_string="Cannot load custom indicator";	break;
      case 4073 :	error_string="No history data";	break;
      case 4074 :	error_string="No memory for history data";	break;
      case 4075 :	error_string="Not enough memory for indicator calculation";	break;
      case 4099 :	error_string="End of file";	break;
      case 4100 :	error_string="Some file error";	break;
      case 4101 :	error_string="Wrong file name";	break;
      case 4102 :	error_string="Too many opened files";	break;
      case 4103 :	error_string="Cannot open file";	break;
      case 4104 :	error_string="Incompatible access to a file";	break;
      case 4105 :	error_string="No order selected";	break;
      case 4106 :	error_string="Unknown symbol";	break;
      case 4107 :	error_string="Invalid price";	break;
      case 4108 :	error_string="Invalid ticket";	break;
      case 4109 :	error_string="Trade is not allowed. Please enable checkbox \"Allow live trading\" in the Expert Advisor properties";	break;
      case 4110 :	error_string="Longs are not allowed. Check the Expert Advisor properties";	break;
      case 4111 :	error_string="Shorts are not allowed. Check the Expert Advisor properties";	break;
      case 4112 :	error_string="Automated trading by Expert Advisors/Scripts disabled by trade server";	break;
      case 4200 :	error_string="Object already exists";	break;
      case 4201 :	error_string="Unknown object property";	break;
      case 4202 :	error_string="Object does not exist";	break;
      case 4203 :	error_string="Unknown object type";	break;
      case 4204 :	error_string="No object name";	break;
      case 4205 :	error_string="Object coordinates error";	break;
      case 4206 :	error_string="No specified subwindow";	break;
      case 4207 :	error_string="Graphical object error";	break;
      case 4210 :	error_string="Unknown chart property";	break;
      case 4211 :	error_string="Chart not found";	break;
      case 4212 :	error_string="Chart subwindow not found";	break;
      case 4213 :	error_string="Chart indicator not found";	break;
      case 4220 :	error_string="Symbol select error";	break;
      case 4250 :	error_string="Notification error";	break;
      case 4251 :	error_string="Notification parameter error";	break;
      case 4252 :	error_string="Notifications disabled";	break;
      case 4253 :	error_string="Notification send too frequent";	break;
      case 4260 :	error_string="FTP server is not specified";	break;
      case 4261 :	error_string="FTP login is not specified";	break;
      case 4262 :	error_string="FTP connection failed";	break;
      case 4263 :	error_string="FTP connection closed";	break;
      case 4264 :	error_string="FTP path not found on server";	break;
      case 4265 :	error_string="File not found in the MQL4\\Files directory to send on FTP server";	break;
      case 4266 :	error_string="Common error during FTP data transmission";	break;
      case 5001 :	error_string="Too many opened files";	break;
      case 5002 :	error_string="Wrong file name";	break;
      case 5003 :	error_string="Too long file name";	break;
      case 5004 :	error_string="Cannot open file";	break;
      case 5005 :	error_string="Text file buffer allocation error";	break;
      case 5006 :	error_string="Cannot delete file";	break;
      case 5007 :	error_string="Invalid file handle (file closed or was not opened)";	break;
      case 5008 :	error_string="Wrong file handle (handle index is out of handle table)";	break;
      case 5009 :	error_string="File must be opened with FILE_WRITE flag";	break;
      case 5010 :	error_string="File must be opened with FILE_READ flag";	break;
      case 5011 :	error_string="File must be opened with FILE_BIN flag";	break;
      case 5012 :	error_string="File must be opened with FILE_TXT flag";	break;
      case 5013 :	error_string="File must be opened with FILE_TXT or FILE_CSV flag";	break;
      case 5014 :	error_string="File must be opened with FILE_CSV flag";	break;
      case 5015 :	error_string="File read error";	break;
      case 5016 :	error_string="File write error";	break;
      case 5017 :	error_string="String size must be specified for binary file";	break;
      case 5018 :	error_string="Incompatible file (for string arrays-TXT, for others-BIN)";	break;
      case 5019 :	error_string="File is directory not file";	break;
      case 5020 :	error_string="File does not exist";	break;
      case 5021 :	error_string="File cannot be rewritten";	break;
      case 5022 :	error_string="Wrong directory name";	break;
      case 5023 :	error_string="Directory does not exist";	break;
      case 5024 :	error_string="Specified file is not directory";	break;
      case 5025 :	error_string="Cannot delete directory";	break;
      case 5026 :	error_string="Cannot clean directory";	break;
      case 5027 :	error_string="Array resize error";	break;
      case 5028 :	error_string="String resize error";	break;
      case 5029 :	error_string="Structure contains strings or dynamic arrays";	break;
      case 5200 :	error_string="Invalid URL";	break;
      case 5201 :	error_string="Failed to connect to specified URL";	break;
      case 5202 :	error_string="Timeout exceeded";	break;
      case 5203 :	error_string="HTTP request failed";	break;
      default   :	error_string="Unknown error";	
   }
   return(error_string);
}

//+------------------------------------------------------------------+
//| convert red, green and blue values to color                      |
//+------------------------------------------------------------------+
int RGB(int red_value,int green_value,int blue_value)
  {
//--- check parameters
   if(red_value<0)     red_value=0;
   if(red_value>255)   red_value=255;
   if(green_value<0)   green_value=0;
   if(green_value>255) green_value=255;
   if(blue_value<0)    blue_value=0;
   if(blue_value>255)  blue_value=255;
//---
   green_value<<=8;
   blue_value<<=16;
   return(red_value+green_value+blue_value);
  }
//+------------------------------------------------------------------+
//| right comparison of 2 doubles                                    |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,8)==0) return(true);
   else return(false);
  }
//+------------------------------------------------------------------+
//| up to 16 digits after decimal point                              |
//+------------------------------------------------------------------+
string DoubleToStrMorePrecision(double number,int precision)
  {
   static double DecimalArray[17]=
     {
      1.0,
      10.0,
      100.0,
      1000.0,
      10000.0,
      100000.0,
      1000000.0,
      10000000.0,
      100000000.0,
      1000000000.0,
      10000000000.0,
      100000000000.0,
      1000000000000.0,
      10000000000000.0,
      100000000000000.0,
      1000000000000000.0,
      10000000000000000.0
     };

   double rem,integer,integer2;
   string intstring,remstring,retstring;
   bool   isnegative=false;
   int    rem2;
//---
   if(precision<0)  precision=0;
   if(precision>16) precision=16;
//---
   double p=DecimalArray[precision];
   if(number<0.0)
     {
      isnegative=true;
      number=-number;
     }
   integer=MathFloor(number);
   rem=MathRound((number-integer)*p);
   remstring="";
   for(int i=0; i<precision; i++)
     {
      integer2=MathFloor(rem/10);
      rem2=(int)NormalizeDouble(rem-integer2*10,0);
      remstring=IntegerToString(rem2)+remstring;
      rem=integer2;
     }
//---
   intstring=DoubleToStr(integer,0);
   if(isnegative)
      retstring="-"+intstring;
   else
      retstring=intstring;

   if(precision>0)
      retstring=retstring+"."+remstring;
//---
   return(retstring);
  }
//+------------------------------------------------------------------+
//| convert integer to string contained input's hexadecimal notation |
//+------------------------------------------------------------------+
string IntegerToHexString(int integer_number)
  {
   string hex_string="00000000";
   int    value,shift=28;
//---
   for(int i=0; i<8; i++)
     {
      value=(integer_number>>shift)&0x0F;
      if(value<10)
         hex_string=StringSetChar(hex_string,i,ushort(value+'0'));
      else
         hex_string=StringSetChar(hex_string,i,ushort((value-10)+'A'));
      shift-=4;
     }
//---
   return(hex_string);
  }
//+------------------------------------------------------------------+
