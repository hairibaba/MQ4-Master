//+---------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                 |
//|   Coder's contact   : +60123337356 (Whatsapp)                                   |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                       |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                            |
//|   Code release date : 22-July-2017                                              |
//+---------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba"
#property version       "1.0"
#property description   "WildGhost Buy Script"
#property show_inputs
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define TIME_ADD_HOUR   3600
#define TIME_ADD_MINUTE 60
#define MAXSPREAD       30
#define SLIPPAGE        15
#define MAXRISK         10

// Input Variable ------------------------------------------------------------------
input bool     UseFixedLot       = false;
extern double  EntryPrice        = 0.0,
               StartLot          = 0.01,
               RiskPercent       = 1.0;
input int      CommPerStdLot     = 4,
               StopLoss          = 600,
               TakeProfit        = 50,
               ExpiredHour       = 1;
input bool     UseStop           = false,
               UseTakeProfit     = true; 
input string   TradeComment      = "Long";

// Global Variable ------------------------------------------------------------------  
double   UseLot      = 0;
datetime Expired     = 0;
int      Type        = OP_BUY,
         MagicNumber = 30303030;
double   Acc_Balance,Acc_Equity,Market_ContractSize,
         Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
         Market_TickValue,Market_TickSize,Market_StopLevel;
string   Acc_Broker,Acc_Currency,Market_Symbol;
int      Acc_MarginCall,Acc_StopOut,Acc_MarginLevel,Market_Spread;
long     Acc_Leverage,Acc_Login;

int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   ChartHistory();
   // Account Inilization Start
   AccountParameter_Fixed(Acc_Login,Acc_Leverage,Acc_Broker,Acc_Currency,Market_Symbol,Market_ContractSize,Market_MarginHedge,
   Market_MaxLot,Market_MinLot,Market_LotStep,Market_TickSize,Market_StopLevel,Acc_MarginCall,Acc_StopOut);
   
   return(INIT_SUCCEEDED);
}

void OnStart(){    
   double SL_Level,TP_Level;
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   // Account Inilization Variable
   AccountParameter_Var(Acc_Balance,Acc_Equity,Acc_MarginLevel,Market_TickValue,Market_Spread);
   TickData();
   
   if(EntryPrice>0){
      if(EntryPrice>Ask) Type=OP_BUYSTOP;
      else if(EntryPrice<Bid) Type=OP_BUYLIMIT;
      if(ExpiredHour>0 && ExpiredHour<100) Expired = TimeCurrent()+(ExpiredHour*TIME_ADD_HOUR);
      else if(ExpiredHour>=100 && TimeCurrent()<HourMin(23,40)) Expired = HourMin(23,54);
      else Expired = TimeCurrent()+(12*TIME_ADD_MINUTE);
      
      SL_Level = EntryPrice - NumToPoint(StopLoss);
      TP_Level = EntryPrice + NumToPoint(TakeProfit);
   }
   else {
      EntryPrice = Ask;
      SL_Level = Bid - NumToPoint(StopLoss);
      TP_Level = Ask + NumToPoint(TakeProfit);
   }
   
   // Order Entry -------------------------------------------------------------------
   if(MarginLevelProcced(110)){
      if (!UseStop) SL_Level = 0;
      if (!UseTakeProfit) TP_Level = 0;
   
      UseLot = LotManagement(RiskPercent,StopLoss,CommPerStdLot);
      int Ticket = OrderSend(_Symbol, Type, UseLot, EntryPrice, SLIPPAGE, SL_Level, TP_Level, TradeComment+" "+Market_Symbol, MagicNumber, Expired, clrGreen);
      if(Ticket == -1) OrderSendError("Script");
      else {
         ul_res = GetMicrosecondCount()-ul;
         string ms = DoubleToString((ul_res/1000.0),2);
         if(!IsTesting()) PrintFormat("order execute in %s ms.",ms);
         ScreenShot();
      }
   }   
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

void TickData(){
   if(!IsTesting()){
      while(!IsConnected()) Sleep(1);
      while(IsTradeContextBusy()) Sleep(1);
      while(!RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

bool VerifyHistory(string symbol) {
   bool x = true;
   datetime times[];
   ResetLastError();
   ArrayCopySeries(times,MODE_TIME,symbol,PERIOD_M1);
   if(_LastError==ERR_HISTORY_WILL_UPDATED || _LastError==ERR_NO_HISTORY_DATA) x = false;
   ResetLastError();
   return x;
}

void ChartHistory(string symbol = NULL) {
   if(!IsTesting()){
      if(symbol==NULL) symbol=_Symbol;
      while(!VerifyHistory(symbol)) {
         Sleep(5000); 
         RefreshRates();
      }
   }
   else RefreshRates();
}

void OrderSendError(string ordertype){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #",sInput," - Symbol : ",sInput,
                                             NewLine,sInput," order failed!",
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,IntegerToString(Acc_Login),_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void NotifySetting(string msg) {
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(msg);
   ResetLastError();
}

bool SpreadFilterPair(){
   bool allow = true;
   if(Market_Spread>MAXSPREAD) allow=false;
   
   return allow;
}

bool MarginLevelProcced(int margin){
   bool proceed = false;
   if(Acc_MarginLevel==0 || Acc_MarginLevel>=margin) proceed = true;
   return proceed;
}

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}

void AccountParameter_Var(double& balance, double& equity, int& marginlevel, double& tickvalue, int& spread){
   // Account Info
   balance        = AccountInfoDouble(ACCOUNT_BALANCE);
   equity         = AccountInfoDouble(ACCOUNT_EQUITY);
   marginlevel    = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   tickvalue      = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   spread         = int(MarketInfo(_Symbol,MODE_SPREAD));
}

void AccountParameter_Fixed(long& Login, long& Leverage, string& Broker, string& AccCurrency, string& symbol, 
double& ContractSize, double& MarginHedge, double& MaxLot, double& MinLot, double& LotStep, double& ticksize, 
double& stopLevel, int& MarginCall, int& StopOut) {
   // Account Info
   Login          = AccountInfoInteger(ACCOUNT_LOGIN);
   Leverage       = AccountInfoInteger(ACCOUNT_LEVERAGE);
   Broker         = AccountInfoString(ACCOUNT_COMPANY);
   AccCurrency    = AccountInfoString(ACCOUNT_CURRENCY);
   // Market Info
   symbol         = _Symbol;
   ContractSize   = MarketInfo(_Symbol, MODE_LOTSIZE);
   MarginHedge    = MarketInfo(_Symbol, MODE_MARGINHEDGED)/ContractSize;
   MaxLot         = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   MinLot         = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   LotStep        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   ticksize       = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)/_Point;
   stopLevel      = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   MarginCall     = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   StopOut        = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)); 

   if(!(symbol=="BRENT"||symbol=="WTI")) symbol = StringSubstr(_Symbol,0,6);
}

string SymShort(int a, int b, int c) {
   return getletter(a)+getletter(b)+getletter(c);
}

bool GetSuffix(string& suff) {
   bool x = false;
   int SymLen = StringLen(_Symbol);
   if(SymLen>6) {
      x = true;
      suff = StringSubstr(_Symbol,6,SymLen-6);
   }
   return x;
}

double LotReferencePrice() {
   string refSym = "", refSym2 = "", suffix = "";
   string sym1 = SymShort(0,1,2);
   string sym2 = SymShort(3,4,5);
   bool hvsuffix = GetSuffix(suffix);
   double RefPrice = 1;
   double buffer = NumToPoint(20);

   // Get Reference Price
   RefreshRates();
   if(sym1==Acc_Currency) RefPrice = 1;
   else if(sym2==Acc_Currency || _Symbol=="BRENT" || _Symbol=="WTI") RefPrice = Ask;
   else {
      refSym = sym1+Acc_Currency;
      string ThisSym1 = refSym;
      if(hvsuffix) ThisSym1 = refSym+suffix;
      
      refSym2 = Acc_Currency+sym1;
      string ThisSym2 = refSym2;
      if(hvsuffix) ThisSym2 = refSym2+suffix;
      
      if(Acc_Currency=="USD"){
         if(refSym=="EURUSD" || refSym=="GBPUSD" || refSym=="AUDUSD" || refSym=="NZDUSD" || refSym=="XAUUSD" || refSym=="XAGUSD" || 
         refSym=="BTCUSD" || refSym=="ETHUSD" || refSym=="XRPUSD") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1/(SymbolInfoDouble(ThisSym2,SYMBOL_ASK));
      }
      else RefPrice = 1; // need to refine this code for deposit currency other than USD
   }
   
   return RefPrice+buffer;
}

double LotManagement(double risk, int stop = 150, double CommStdLot = 0) {
   double RefPrice               = LotReferencePrice(),
          LotSize                = Market_MinLot,
          CommissionCost         = 0,
          CommPerStdLotRoundTurn = fmax(CommStdLot,OrderCommissionChk());
   
   if(UseFixedLot) LotSize = VerifyLotMinMax(StartLot);
   else if(!UseFixedLot && risk>0 && stop>0) {
      if(risk>MAXRISK) risk = MAXRISK; // Limit the max risk to 10%
      // Delta per lot
      double deltaperlot = Market_TickValue/Market_TickSize;
      // To manage Divided by Zero errors
      double deltaLot = 1;
      if(deltaperlot!=0) deltaLot = deltaperlot;
      // CommissionPer1MilContract =  $4/roundtrip/1StdLot. for most broker = $20 per 1 million traded lot per turn
      if(CommPerStdLotRoundTurn>0) CommissionCost = RefPrice*CommPerStdLotRoundTurn;
      // Risk Amount Calculation
      double AmountAtRisk  = Acc_Balance * (risk / 100.0);
      double RefineCalc    = AmountAtRisk-CommissionCost; // Include Comission calculation
      int    ActDistance   = stop+Market_Spread;
      // Lot Calculation
      double rawlot = (RefineCalc/ActDistance)/deltaLot;
      LotSize = VerifyLotMinMax(NormLot(rawlot));
      
      // For Alpari Broker
      //double MaxLotAlpari = NormalizeDouble(50/(Ask+(70*_Point)),rounding);
      //if(AccountNumber()==1478232 && LotSize>MaxLotAlpari) LotSize=MaxLotAlpari;
   }
   return LotSize;
}

double VerifyLotMinMax(double lot) {
   double uselot = lot;
   if(uselot>Market_MaxLot) uselot = Market_MaxLot;
   else if(uselot<Market_MinLot) uselot = Market_MinLot;
   return uselot;
}

int OrderCommissionChk() {
   int x = 4;
   for(int order = OrdersHistoryTotal(); order>0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderType()<2 && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

string getletter(int pos)
{
   string x = "None";
   
   string sym = Market_Symbol;
   ushort loc = StringGetCharacter(sym,pos);
   
   if(loc==65) x = "A";
   else if(loc==66) x = "B";
   else if(loc==67) x = "C";
   else if(loc==68) x = "D";
   else if(loc==69) x = "E";
   else if(loc==70) x = "F";
   else if(loc==71) x = "G";
   else if(loc==72) x = "H";
   else if(loc==73) x = "I";
   else if(loc==74) x = "J";
   else if(loc==75) x = "K";
   else if(loc==76) x = "L";
   else if(loc==77) x = "M";
   else if(loc==78) x = "N";
   else if(loc==79) x = "O";
   else if(loc==80) x = "P";
   else if(loc==81) x = "Q";
   else if(loc==82) x = "R";
   else if(loc==83) x = "S";
   else if(loc==84) x = "T";
   else if(loc==85) x = "U";
   else if(loc==86) x = "V";
   else if(loc==87) x = "W";
   else if(loc==88) x = "X";
   else if(loc==89) x = "Y";
   else if(loc==90) x = "Z";

   return x;
}

double NormLot(double lot){
   double useLot  = Market_MinLot;
   
   if(lot>Market_MaxLot) useLot = Market_MaxLot;
   else if(lot>Market_MinLot) useLot = MathFloor(lot/Market_LotStep)*Market_LotStep;

   return useLot;
}

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}

string ProperDigit(int value) {
   string ret = IntegerToString(value);
   if(value<10) ret = StringConcatenate("0",value);
   return ret;
}

string TimeStamp() {
   datetime Now = iTime(_Symbol,PERIOD_M1,0);
   int year = TimeYear(Now);
   int month = TimeMonth(Now);
   int day = TimeDay(Now);
   int hour = TimeHour(Now);
   int min = TimeMinute(Now);
   return StringConcatenate(year,ProperDigit(month),ProperDigit(day),ProperDigit(hour),ProperDigit(min));
}

string DirectoryMonthYear(datetime time) {
   int month = TimeMonth(time);
   int year = TimeYear(time);
   
   string x = "";
   switch(month){      
      case 1:  x = "JAN"; break;
      case 2:  x = "FEB"; break;
      case 3:  x = "MAR"; break;
      case 4:  x = "APR"; break;
      case 5:  x = "MAY"; break;
      case 6:  x = "JUN"; break;
      case 7:  x = "JUL"; break;
      case 8:  x = "AUG"; break;
      case 9:  x = "SEP"; break;
      case 10: x = "OCT"; break;
      case 11: x = "NOV"; break;
      default: x = "DEC";
   }
   return x+"-"+string(year);
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}

void ScreenShot(string symbol = "", string directory = "TradeScreenshot") {
   if(!IsTesting()) {
      int width = int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));   // Chart's width
      int heigh = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear(TimeCurrent())+"/"+symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string pairscreen = symbol+"_"+ChartTimeframe()+"_"+TimeStamp()+".gif";
      string ScreenShotName = FolderDirectory+pairscreen;
   
      //Making ScreenShot
      if(!WindowScreenShot(ScreenShotName,width,heigh)) Alert(ErrorDescription(GetLastError()));
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}