//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "hairibaba © 2012-2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "3.4"
#property description   "Account Information Notifier"
#property strict

#define TIME_ADD_DAY 86400

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

// --- Input Variable -------------------------------------------------------------------
input bool     WithdarawAlert    = false;
input double   WithdrawThreshold = 1950;

// --- Standard Global Variable ---------------------------------------------------------
     string Acc_Broker,Acc_Currency,Market_Symbol,Acc_DrawdownText;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,
            Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel;
     string ObjIdentifier  = "EXX_",
            NewLine        = "\n",
            sInput         = "%s";

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   // Account Inilization Start
   ChartHistory();
   AccountParameter_Fixed(Acc_Login,Acc_Leverage,Acc_Broker,Acc_Currency,Market_Symbol,Market_ContractSize,Market_MarginHedge,Market_CalcMode,
   Market_MaxLot,Market_MinLot,Market_LotStep,Market_TickSize,Market_StopLevel,Market_FreezeLevel,Acc_Pips,Acc_MarginCall,Acc_StopOut);
   ChartSetting();
   string text = "Acc #"+IntegerToString(Acc_Login)+" monitoring start. \nServer Time: "+TimeToString(TimeCurrent(),TIME_MINUTES);
   Print(text);
   SendNotification(text);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(getUninitReasonText(reason));
   reportReason(_UninitReason);
}

void SleepSeconds(int seconds) {
   Sleep(seconds*1000);
}

void OnTick(){
   AllowTrading();
   ChartHistory();
   AccountParameter_Var(Acc_Balance,Acc_Equity,Acc_FreeMargin,Acc_MarginLevel,Acc_Drawdown,Market_TickValue,Market_Spread);
   double daily = PerformanceClosed_Daily();
   double weekly = PerformanceClosed_Weekly();
   double monthly = PerformanceClosed_Monthly();
   
   SentStatus(23,54,daily,weekly,monthly);
   SentStatus(17+DST_ShiftTime(),0,daily,weekly,monthly);
   SentStatus(19,10,daily,weekly,monthly);
   
   if(Acc_MarginLevel>0 && Acc_MarginLevel<=100) {
      MargicCallText();
      SleepSeconds(30);   // Sleep 30 seconds
      RefreshRates();
   }
   else if(NewBar(PERIOD_M5)) {
      PeriodicMsg(1-DST_ShiftTime(),5);   // 0605
      PeriodicMsg(4,10);                  // 0910
      PeriodicMsg(7,10);                  // 1210
      PeriodicMsg(9,10);                  // 1410
      PeriodicMsg(11,15);                 // 1615
      PeriodicMsg(13,0);                  // 1800
      PeriodicMsg(14,15);                 // 1915
      PeriodicMsg(15,45);                 // 2045
      PeriodicMsg(18,30);                 // 2330
      PeriodicMsg(21,0);                  // 0200
      PeriodicMsg(22,0);                  // 0300
      
      if(Acc_MarginLevel>0 && Acc_MarginLevel<=600) LowMarginText();    // Alert on Low Margin
      else if(WithdarawAlert) WithdrawText();                           // Alert on withdaraw
   }
   
   string floating = "No Order";
   if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()),NewLine,NewLine," Margin Level : ",IntegerProper(Acc_MarginLevel),NewLine,NewLine," Drawdown : ",Acc_DrawdownText);
   
   Comment(
            "\n\n Time Server : ",TimeCurrent(),
            "\n\n Account Balance : ",StringDollar(Acc_Balance),
            "\n\n Account Equity : ",StringDollar(Acc_Equity),
            "\n\n PnL Daily : ",StringDollar(daily)," (",ReturnPercent(daily),")",
            "\n\n PnL Weekly : ",StringDollar(weekly)," (",ReturnPercent(weekly),")",
            "\n\n PnL Monthly : ",StringDollar(monthly)," (",ReturnPercent(monthly),")",
            "\n\n Order Status : ",floating
          );
}

string getUninitReasonText(int reasonCode){
   string text = "";
   switch(reasonCode){      
      case REASON_PROGRAM:       text = __FILE__+" was terminated by ExpertRemove()"; break;
      case REASON_REMOVE:        text = __FILE__+" was removed from chart";break;
      case REASON_RECOMPILE:     text = __FILE__+" was recompiled";break;
      case REASON_CHARTCHANGE:   text = "Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:    text = "Chart was closed";break;
      case REASON_PARAMETERS:    text = "Input-parameter was changed";break;
      case REASON_ACCOUNT:       text = "Account was changed";break;
      case REASON_TEMPLATE:      text = "New template was applied to chart";break;
      case REASON_INITFAILED:    text = "Initialization fail";break;
      case REASON_CLOSE:         text = "Terminal was closed";break;
      default:                   text = "Another reason...";
   }
   return text;
}

void reportReason(int reasonCode){
   int Login = int(AccountInfoInteger(ACCOUNT_LOGIN));
   string stringlogin = IntegerToString(Login);
   string text = "";
   string ServerTime = TimeToString(TimeCurrent(),TIME_MINUTES);
   if(reasonCode==REASON_PROGRAM)      text = "Acc #"+stringlogin+" "+__FILE__+" was terminated by ExpertRemove() at Server Time : "+ServerTime;
   else if(reasonCode==REASON_REMOVE)  text = "Acc #"+stringlogin+" "+__FILE__+" was removed from chart at Server Time : "+ServerTime;
   else if(reasonCode==REASON_CLOSE)   text = "Acc #"+stringlogin+" - Terminal was closed at Server Time : "+ServerTime;

   if(text!="") SendNotificationFunction(text);
}

void AccountParameter_Var(double& balance, double& equity, double& freemargin, int& marginlevel, double& drawdown, double& tickvalue, int& spread) {
   // Account Info
   balance        = AccountInfoDouble(ACCOUNT_BALANCE);
   equity         = AccountInfoDouble(ACCOUNT_EQUITY);
   freemargin     = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   marginlevel    = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   tickvalue      = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   spread         = int(MarketInfo(_Symbol,MODE_SPREAD));
   drawdown       = 0;
   if(Acc_Balance>Acc_Equity && Acc_Balance>0) {
      drawdown = StringToDouble(DoubleToString((1-(Acc_Equity/Acc_Balance))*100,1));
   }
   Acc_DrawdownText  = DoubleToString(Acc_Drawdown,1)+" %";
}

void AccountParameter_Fixed(int& Login, int& Leverage, string& Broker, string& AccCurrency, string& symbol, 
double& ContractSize, double& MarginHedge, int& CalcMode, double& MaxLot, double& MinLot, double& LotStep, double& ticksize, 
double& stopLevel, double& freezeLevel, int& PipModifier, int& MarginCall, int& StopOut) {
   // Account Info
   Login          = int(AccountInfoInteger(ACCOUNT_LOGIN));
   Leverage       = int(AccountInfoInteger(ACCOUNT_LEVERAGE));
   Broker         = AccountInfoString(ACCOUNT_COMPANY);
   AccCurrency    = AccountInfoString(ACCOUNT_CURRENCY);
   // Market Info
   symbol         = _Symbol;
   ContractSize   = MarketInfo(_Symbol,MODE_LOTSIZE);
   CalcMode       = int(MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   MarginHedge    = MarketInfo(_Symbol,MODE_MARGINHEDGED)/ContractSize;
   MaxLot         = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   MinLot         = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   LotStep        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   ticksize       = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)/_Point;
   stopLevel      = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   freezeLevel    = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   MarginCall     = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   StopOut        = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   PipModifier    = 1;

   if(CalcMode!=0 && StringLen(_Symbol)>6) symbol = StringSubstr(_Symbol,0,6);
   if(_Digits == 3 || _Digits == 5) PipModifier = 10;
}

bool InitFailed() {
   string login = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   string type = " (Real)";
   if(IsDemo()) type = " (Demo)";
   bool x = true;
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Alert("Please enable Automated Trading in the terminal settings!");
      x = false;
   }
   else if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Alert("Automated trading is forbidden in the program settings for ",__FILE__);
      x = false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
      Alert("Automated trading is forbidden for the account ",login,type," at the trade server side");
      x = false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Alert("Trading is forbidden for the account ",login,type,
      ".\nPerhaps an investor password has been used to connect to the trading account.",
      "\nCheck the terminal journal for the following entry:",
      "\n\'",login,"\': trading has been disabled - investor mode.");
      x = false;
   }
   return x;
}

void AllowTrading() {
   if (!InitFailed()) ExpertRemove();
}

void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
}

double NormDollar(double dollarValue) {
   return round(dollarValue/0.01)*0.01;
}

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double step = Market_LotStep;
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}

int PointToInt (double point) {
   return int(point/_Point);
}

string ReturnPercent(double curr) {
   string x = "0";
   if(curr!=0 && Acc_Balance>0) {
      double acc = ((Acc_Balance/(Acc_Balance-curr))-1)*100;
      if(acc<100 && acc>-100) x = DoubleToString(acc,1);
      else x = IntegerProper((int)acc);
   }
   return StringConcatenate(x," %");
}

string IntegerProper(int pInteger) {
   string p1 = "";
   string p2 = "";
   string p3 = "";
   string comma = ",";
   string x = IntegerToString(pInteger);
   int z = StringLen(x);
   int shift = 0;
   if(pInteger<0)  shift = 1;
   
   if(z>3+shift && z<7+shift) {
      if(z==4+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift);
      }
      else if(z==5+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift);
      }
      else if(z==6+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift);
      }
      x = p1+comma+p2;
   }
   else if(z>=7+shift && z<10+shift) {
      if(z==7+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift,3+shift);
         p3 = StringSubstr(x,4+shift);
      }
      else if(z==8+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift,4+shift);
         p3 = StringSubstr(x,5+shift);
      }
      else if(z==9+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift,5+shift);
         p3 = StringSubstr(x,6+shift);
      }
      x = p1+comma+p2+comma+p3;
   }
   return x;
}

string StringDollar(double dollaValue) {
   string currency = "$";

   string x = DoubleToString(NormDollar(dollaValue),2);
   string res = x;
   int z = StringLen(x); 

   int shift = 0;
   if(dollaValue<0)  shift = 1;
   if(Acc_Currency!="USD") currency = Acc_Currency;
   
   if(z>6+shift) {
      string s1 = StringSubstr(x,0,z-3);
      string s2 = StringSubstr(x,z-3);
      int ins1 = StrToInteger(s1);
      string sx = IntegerProper(ins1);
      res =  sx+s2; 
   }

   return currency+" "+res;
}

bool BetweenTimeRange(datetime timeStart, datetime timeEnd) {
   datetime compare = TimeCurrent();
   return compare>=timeStart && compare<timeEnd;
}

bool BetweenTimeRange(int hour, int minutes) {
   datetime compare = TimeCurrent();
   int thisMinStart = minutes;
   int thisMinEnd = minutes;
   int thisHourStart = hour;
   int thisHourEnd = hour;
   
   if(minutes==0) {
      thisMinStart=60;
      thisHourStart -= 1;
   }
   else if(minutes==59) {
      thisMinEnd=0;
      if(hour==23) thisHourEnd = 0;
      else thisHourEnd += 1;
   }
   
   return compare>=HourMin(thisHourStart,thisMinStart-1) && compare<=HourMin(thisHourEnd,thisMinEnd+1);
}

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}

datetime ServerDate(int pYear = 0, int pMonth = 0, int pDay = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.year   = pYear;    // Year
   timeStruct.mon    = pMonth;   // Month
   timeStruct.day    = pDay;     // Day
   return StructToTime(timeStruct);
}

int DST_ShiftTime(){
   // https://www.timeanddate.com/time/change/uk/london
   int x = 0;
   if(BetweenTimeRange(ServerDate(2018,10,28),ServerDate(2019,3,31))) x = -1;
   else if(BetweenTimeRange(ServerDate(2019,10,27),ServerDate(2020,3,29))) x = -1;
   else if(BetweenTimeRange(ServerDate(2020,10,25),ServerDate(2021,3,28))) x = -1;
   return x;
}

bool NewBar(ENUM_TIMEFRAMES timeframe){
   datetime ArrayTime[];
   static datetime LastTime = 0;
   bool firstRun = false, newBar = false;
   ArraySetAsSeries(ArrayTime,true);
	CopyTime(_Symbol,timeframe,0,2,ArrayTime);
	
	if(LastTime == 0) firstRun = true;
	if(ArrayTime[0] > LastTime){
		if(firstRun == false) newBar = true;
		LastTime = ArrayTime[0];
	}
	return newBar;   
}

bool VerifyHistory(string symbol = NULL) {
   if(symbol==NULL) symbol=_Symbol;
   bool x = true;
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   int copied = CopyTime(symbol,PERIOD_M1,0,2,ArrayTime);
   if(copied<0) x = false;
   return x;
}

void ChartSetting(bool setcolor = true)
{
   ChartSetInteger(0,CHART_MODE,1);
   ChartSetInteger(0,CHART_SCALE,3);
   ChartSetInteger(0,CHART_AUTOSCROLL,0,true);
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,0,false);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,false);
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   ChartSetInteger(0,CHART_SHIFT,0,true);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,0,false);
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,0,true);
   if(setcolor){
      ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'19,23,34');
      ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrLightSlateGray);      // C'37,44,63'
      ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrWhiteSmoke);
      ChartSetInteger(0,CHART_COLOR_CHART_UP,C'102,184,149');
      ChartSetInteger(0,CHART_COLOR_CHART_DOWN,C'214,87,95');
      ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,C'102,184,149');
      ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,C'214,87,95');
      ChartSetInteger(0,CHART_COLOR_VOLUME,C'37,44,63');
      ChartSetInteger(0,CHART_COLOR_BID,C'37,44,63');
      ChartSetInteger(0,CHART_COLOR_ASK,C'214,87,95');
   }
}

int TickCount(int timeframe) {
   static int TickCount = 0;
   static datetime BarTime = 0; 
   datetime timechk = iTime(_Symbol,timeframe,0);
   
   if(timechk!=BarTime) { 
      TickCount = 0; 
      BarTime= timechk;
   } else TickCount++;
   return TickCount;
}

bool FirstTick(int timeframe) {
   return TickCount(timeframe)==1;
}

double OrderProperty_FloatingStatus(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderType()<2) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double PerformanceClosed_Daily(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(4*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeDay(OrderCloseTime())==Day() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double PerformanceClosed_Monthly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(32*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeMonth(OrderCloseTime())==Month() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double PerformanceClosed_Weekly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(14*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && ChkWeek(OrderCloseTime())==StdWeek() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

int StdWeek(){
   int iDay  = (DayOfWeek() + 6 ) % 7 + 1;        // convert day to standard index (1=Mon,...,7=Sun)
   int iWeek = (DayOfYear() - iDay + 10 ) / 7;    // calculate standard week number
   return iWeek;
}

int ChkWeek(datetime time){
   int iDay  = ( TimeDayOfWeek(time) + 6 ) % 7 + 1;      // convert day to standard index (1=Mon,...,7=Sun)
   int iWeek = ( TimeDayOfYear(time) - iDay + 10 ) / 7;  // calculate standard week number
   return iWeek;
}

void SentStatus(int hour, int minutes, double report1, double report2, double report3) {
   datetime time1 = HourMin(hour,minutes);
   datetime time2 = HourMin(hour,minutes+1);
   
   if(BetweenTimeRange(time1,time2) && FirstTick(PERIOD_M1)) {
      string floating = "No Order";
      string acc = " (Real)";
      if(IsDemo()) acc = " (Demo)";
      if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel));
      
      string output_string = StringConcatenate("Broker : ",sInput,
                                                NewLine,"Acc Number : %d",sInput,
                                                NewLine,"Acc Balance : ",sInput,
                                                NewLine,"Acc Leverage : ",sInput,
                                                NewLine,"PnL Today : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Weekly : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Monthly : ",sInput,"  (",sInput,")",
                                                NewLine,"Order(s) Status : ",sInput
                                              );
                           
      string msg = StringFormat( output_string,
                                 Acc_Broker,
                                 Acc_Login,acc,
                                 StringDollar(Acc_Balance),
                                 IntegerProper(Acc_Leverage),
                                 StringDollar(report1),ReturnPercent(report1),
                                 StringDollar(report2),ReturnPercent(report2),
                                 StringDollar(report3),ReturnPercent(report3),
                                 floating
                               );
      Print(msg);
      if(TimeCurrent()>HourMin(23)) SendMailFunction("#"+IntegerToString(Acc_Login)+acc+" Acc Summary : "+TimeStampDate(),msg);
      SendNotificationFunction(msg);
   }
}

void WithdrawText() {
   bool real = AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO;
   if(real) {
      double threshold = WithdrawThreshold;
      if(Acc_Balance>=threshold || Acc_Equity>= threshold) {
         string floating = "No Order";
         string acc = " (Real)";
         if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel));
         
         string output_string = StringConcatenate( "Withdraw Alert!",
                                                   NewLine,"Broker : ",sInput,
                                                   NewLine,"Acc Number : %d (Real)",
                                                   NewLine,"Acc Balance : ",sInput,
                                                   NewLine,"Acc Equity : ",sInput,
                                                   NewLine,"Order(s) Status : ",sInput
                                                   );
                                 
         string msg = StringFormat( output_string,
                                    Acc_Broker,
                                    Acc_Login,
                                    StringDollar(Acc_Balance),
                                    StringDollar(Acc_Equity),
                                    floating
                                  );
         Alert(msg);
         Print(msg);
         SendNotificationFunction(msg);
      }
   }
}

void PeriodicText(){
   string floating = "No Order";
   string acc = " (Real)";
   if(IsDemo()) acc = " (Demo)";
   double daily = PerformanceClosed_Daily();
   if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel));
      
   string output_string = StringConcatenate("Broker : ",sInput, 
                                             NewLine,"Acc Number : %d",sInput,
                                             NewLine,"Acc Balance : ",sInput,
                                             NewLine,"Daily PnL : ",sInput,"  (",sInput,")",
                                             NewLine,"Order(s) Status : ",sInput
                                            );
                           
   string msg = StringFormat( output_string,
                              Acc_Broker,
                              Acc_Login,acc,
                              StringDollar(Acc_Balance),
                              StringDollar(daily),
                              ReturnPercent(daily),
                              floating
                             );
   Print(msg);
   SendNotificationFunction(msg); 
}

void LowMarginText(){
   double lot;
   string symbol,ordertype;
   ExtremeOrder(lot,symbol,ordertype);
   int order = CountOrder(symbol);

   string floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()));
   string details = StringConcatenate("-------------\n",IntegerToString(order)," order(s) on ",symbol,"\nHighest lot: ",StringLot(lot)," (",ordertype,")");
   string acc = " (Real)";
   if(IsDemo()) acc = " (Demo)";
      
   string output_string = StringConcatenate( "Account MarginLevel : ",sInput,
                                             NewLine,"Broker : ",sInput,
                                             NewLine,"Acc Number : %d",sInput,
                                             NewLine,"Acc Balance : ",sInput,
                                             NewLine,"Order(s) Status : ",sInput,
                                             NewLine,sInput
                                            );
                           
   string msg = StringFormat( output_string,
                              IntegerProper(Acc_MarginLevel),
                              Acc_Broker,
                              Acc_Login,acc,
                              StringDollar(Acc_Balance),
                              floating,
                              details
                             );
   Alert(msg);
   Print(msg);
   SendNotificationFunction(msg);
}

void MargicCallText(){
   double lot;
   string symbol,ordertype;
   ExtremeOrder(lot,symbol,ordertype);
   int order = CountOrder(symbol);

   string floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()));
   string details = StringConcatenate("-------------\n",IntegerToString(order)," order(s) on ",symbol,"\nHighest lot: ",StringLot(lot)," (",ordertype,")");
   string mc = "MC-SO : "+IntegerToString(Acc_MarginCall)+"-"+IntegerToString(Acc_StopOut);
   string acc = " (Real)";
   if(IsDemo()) acc = " (Demo)";
      
   string output_string = StringConcatenate( "Margin Call Alert !!",
                                             NewLine,"Marginlevel : ",sInput,
                                             NewLine,sInput,
                                             NewLine,"Broker : ",sInput,
                                             NewLine,"Acc Number : %d",sInput,
                                             NewLine,"Acc Balance : ",sInput,
                                             NewLine,"Order(s) Status : ",sInput,
                                             NewLine,sInput
                                            );
                           
   string msg = StringFormat( output_string,IntegerProper(Acc_MarginLevel),
                              mc,
                              Acc_Broker,
                              Acc_Login,acc,
                              StringDollar(Acc_Balance),
                              floating,
                              details
                             );
   Alert(msg);
   Print(msg);
   SendNotificationFunction(msg);
}

void SendMailFunction(string subject, string text) {
   if(LiveOperation() && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) {
      bool send = SendMail(subject,text); 
      if(!send) Alert("Error sending email");
   }
}

void PeriodicMsg(int hour, int minutes) {
   if(BetweenTimeRange(hour+DST_ShiftTime(),minutes) && (Acc_MarginLevel==0 || Acc_MarginLevel>=650)) PeriodicText();
}

void ExtremeOrder(double& lot, string& symbol, string& type){
   double thisLot = 0;
   string thisSymbol = "";
   string thisType = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderType()<2 && OrderLots()>thisLot) {
         thisLot = OrderLots();
         thisSymbol = OrderSymbol();
         if(OrderType()==OP_SELL) thisType = "Sell Order";
         else thisType = "Buy Order";
      }
   }
   lot = thisLot;
   symbol = thisSymbol;
   type = thisType;
}

int CountOrder (string symbol) {
   int x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==symbol) x++;
   }
   return x;
}

string TimeStampDate() {
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(),tm);
   return StringFormat("%02d-%02d-%4d",tm.day,tm.mon,tm.year);
}

string StringLot(double lot) {
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   int x = 0;
   if(step==0.01) x = 2;
   else if(step==0.1) x = 1;
   
   return DoubleToString(lot,x);
}

void ChartHistory(string symbol = NULL) {
   ENUM_PROGRAM_TYPE mql_program = (ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE); 
   
   if(mql_program == PROGRAM_EXPERT || mql_program == PROGRAM_SCRIPT) {
      if(!MQLInfoInteger(MQL_TESTER)){
         if(symbol==NULL) symbol=_Symbol;
         ENUM_TIMEFRAMES tfs[] = {
         PERIOD_M1,  PERIOD_M5, PERIOD_M15,
         PERIOD_M30, PERIOD_H1, PERIOD_H4, 
         PERIOD_D1,  PERIOD_W1, PERIOD_MN1
         };
         
         for(int j=ArraySize(tfs)-1; j>=0; --j)
            while(!verifyHistory(symbol,tfs[j]));
      }   
   }
   RefreshRates();
}

bool verifyHistory(string symbol, ENUM_TIMEFRAMES tf) {
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   int copied = CopyTime(symbol,tf,0,5,ArrayTime);
   if(copied<0) {
      Sleep(10);
      return false;
   }
   else return true;
}

void SendNotificationFunction(string msg) {
   if(LiveOperation() && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
}

bool LiveOperation() {
   return !(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE));
}