//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "XXXX"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define RETRY_DELAY        2000
#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3
#define IDENTIFIER_TRADE   54347

class CCount {
   public:
      int OrderAllTerminal();
      int OrderAllSymbol();
      int OrderAllSymbol(int type);
      int OrderAll(int magic);
      int OrderAll(int magic, int type);       
}Count;

class CTrade {
   private:
      void TickData();
      int Identifier(int identifier);
      int getID();
      int generateID(int x);
      void OrderSendError(string ordertype);
      void ModifyError(int ticket);
      void OrderCloseError(int ticket, string action);
      void NotifySetting(string msg);
      bool ServerError(int pErrorCode);
      bool multiple_closeby_symbol();
      bool multiple_closeby_symbol(const int magic);
      bool OrderExist(int magic);
      bool NewOrderChk(string orderType, int type, double lot, string& retMsg);
      void OpenOrder(int type, int magic, double lot, string comment);
      void OpenPendingOrder(int type, int magic, double lot, double pPricePending, string comment, int expiredMinutes);
   public: 
      string SignalComment(int sig);  
      string SignalDirection(int sig);    
      void AssignMagic(int identifier);
      void OpenBuy(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenSell(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      
      void OpenBuyLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0);
      void OpenBuyStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0);
      void OpenSellLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0);
      void OpenSellStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0);
      
      void CloseOrder(int magic);
      void CloseOrderBy(int magic1, int magic2);
      void CloseAllOrder_Symbol();
      void CloseAllOrder_Terminal();
      void CloseAllOrder_HedgingCloseBy();
      void CloseAllOrder_HedgingCloseBy(int magic);
      void PartialClose(int magic, double lot);
      void DeletePendingOrder(int magic);
      void DeleteAllPendingOrder_Symbol();
      void DeleteAllPendingOrder_Terminal();
      void DeletePendingOrderTimer(int magic, int second);
      void ModPendingOrder(int magic, double pPending);
      void ModifyStopLoss(int magic, double stopPrice);
      void ModifyTakeProfit(int magic, double takePrice);
      void ModifySL_Point(int magic, int stopPoint);
      void ModifyTP_Point(int magic, int takePoint);
      void DeleteSLTP();
}Trade;

class CMoney {
   public:
      double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0);
      double FullMarginLot(double balance, int leverage, int spread, double MinMarginPercentage = 105, int divider = 1, double CommPerStdLot = 0);
      double LotManagement(bool pRiskManagement, double risk, int stop = 150, double CommPerStdLot = 0);
      double refPrice();
}Money;

class CFeatures {
   private:
      bool HiddenTP_Trail(int magic, int takePoint);
   public:
      void HiddenSL(int magic, int stopPoint);
      void HiddenTP(int magic, int takePoint);
      void HiddenSLTP(int magic, int stopPoint, int takePoint, bool trail = false);
      void HiddenSLTP(int magic, double pPriceSL, double pPriceTP);
      void BreakEven(int magic, int distance, int lock = 10);
      void TrailingStop(int magic, int distance, int step = 10);
      void SystemTrailing(int magic, int distance = 100, int step = 10);
      void TrailingStopIndicator(int magic, double value);
      void TrailingStop_Hidden(int magic, int distance, int step = 10);
      void ProtectingTarget(int magic, int trigger = 25, int lock = 25, double TP_Level = 0);
      void ProtectingTargetScalp(int magic, int lock = 10);
}Features;

class CGeneral {
   public:
      int OrderCommissionChk();
      double TotalLotSymbol();
      double Sell_LowestSL();
      double Buy_HighestSL();
      
      double HighestOrderPrice();
      double LowestOrderPrice();
      double HighestOrderLot();
      double dirOrderLot(int direction);
      double averagePrice();
      int avgDailyRange(int range = 30, int startbar = 0);
}General;

class CReport {
   public:
      double Closed_Daily();
      double Closed_Weekly();
      double Closed_Monthly();
      double FloatingStatusAll();
      double TradePL(int magic);
      double TradeHistoryPL(int magic, int dayHistory = 30);
}Report;

class CProp {
   public:
      int type(int magic);
      double orderLot(int magic);
      double stopLoss(int magic);
      double takeProfit(int magic);
      
      double currentOrderLot(int direction);
      int ticket(int magic);
      datetime openTime(int magic);
      string comment(int magic);
      string symbol(int magic);
      double openPrice(int magic);
      bool justClose(int magic, int minutesAgo = 1);
      void lastClosedOrder(int& type, int& ticket, double& lot, double& openPrice, double& closePrice, double& profit, double& nettPnl);
      void newestOrder(int& type, double& lot, double& price, double& profit, double& nettPnl);
}Property;

enum ENUM_INPUT {BUY,SELL};

// --- Input Variable ------------------------------------------------------------------
input bool        ActivateEA        = true,
                  UseRiskManagement = true;
input double      RiskPerTrade      = 1.0,
                  StartLot          = 0.01;
input int         StopLoss          = 600,
                  TakeProfit        = 200;
input string      OrderTradeComment = "xxx";
input bool        UseTrailingStop   = true;
input int         TrailingDistance  = 100,
                  TrailingStep      = 10;
input ENUM_INPUT  Testing           = BUY;

// --- Standard Global Variable ---------------------------------------------------------
static int  s_id = 0;
       bool NotiEnable,Tester_Debug;
     string Acc_Broker,Acc_Currency,Market_Symbol,Acc_DrawdownText,
            SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
            Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_MarginUsed,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_VolumeLimit,Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel,Market_StopFreeze;

// --- System Global Variable -----------------------------------------------------------        
string      ObjIdentifier  = "EAX_";
int         MagicBuy_1,MagicBuy_2,MagicSell_1,MagicSell_2;

// Product Licensing --------------------------------------------------------------------
       bool Use_Expiry         = false,
            Use_AccountLock    = false,
            Use_DemoOnly       = false;
     string ProductOwner       = "zulhairibaba@gmail.com";
        int Expiry_Year        = 2018,
            Expiry_Month       = 12,
            Expiry_Day         = 31;
const long  Allowed_Accounts[] = {924635,979890};

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
   if(!ProductLicense(Use_DemoOnly,Use_AccountLock,Acc_Login,ProductOwner)) return INIT_FAILED;
   if(!InitFailed()) return INIT_FAILED;
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   
   // Account Inilization Start
   ChartHistory();
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   ChartSetting();
   
   // Assigning Magic Number and Property
   Trade.AssignMagic(IDENTIFIER_TRADE);
   ul_res = GetMicrosecondCount()-ul;
   if(!MQLInfoInteger(MQL_TESTER)) printf("Initilized in %s ms.",StringMs(ul_res));
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(getUninitReasonText(_UninitReason));
   reportReason(_UninitReason);
   s_id = 0;
}

void OnTick(){
   ProductExpired(Use_Expiry,ProductOwner,Expiry_Year,Expiry_Month,Expiry_Day);
   AllowTrading();
   ChartHistory();
   AccountParameter_Var();
   SentStatus(23,53,Report.Closed_Daily(),Report.Closed_Weekly(),Report.Closed_Monthly());
   
   // System Trailing Stop
   if(UseTrailingStop) {
      Features.SystemTrailing(MagicBuy_1,TrailingDistance,TrailingStep);
      Features.SystemTrailing(MagicSell_1,TrailingDistance,TrailingStep);
   }
   
   //if(Count.OrderAllSymbol()==0 && !GlobalVariableCheck(_Symbol)) GlobalVariableSet(_Symbol,TimeCurrent());
   //double tempGlobal;
   //if(GlobalVariableGet("GBP",tempGlobal)) {}
   //GlobalVariablesDeleteAll();
   //Trade.OpenBuy(MagicBuy_1,0.01,"test");
   //Print("Symbol data are synchronized = ", (bool)SynchonizedChart());
   
   int newType,lastType,lastTicket;
   double newLot,newOP,newProfit,newPnL,lastLot,lastOP,lastCP,lastProfit,lastPnL;
   Property.newestOrder(newType,newLot,newOP,newProfit,newPnL);
   Property.lastClosedOrder(lastType,lastTicket,lastLot,lastOP,lastCP,lastProfit,lastPnL);
   
   
   
   Comment(
   "\n\n Symbol : ",SymbolTimeframe(),
   "\n\n Account Balance : ",StringDollar(Acc_Balance),
   "\n\n Account Equity : ",StringDollar(Acc_Equity),
   "\n\n PnL Daily : ",StringDollar(Report.Closed_Daily())," (",ReturnPercent(Report.Closed_Daily()),")",
   "\n\n PnL Weekly : ",StringDollar(Report.Closed_Weekly())," (",ReturnPercent(Report.Closed_Weekly()),")",
   "\n\n PnL Monthly : ",StringDollar(Report.Closed_Monthly())," (",ReturnPercent(Report.Closed_Monthly()),")",
   "\n\n Time Server : ",TimeCurrent(),
   "\n\n Time GMT : ",TimeGMT(),
   "\n\n Time GMT : ",TimeGMTOffset()/PeriodSeconds(PERIOD_H1),
   "\n\n Day of the Year : ",TimeDayOfYear(TimeCurrent()),
   "\n\n Week No : ",StdWeek(),
   "\n\n",
   "\n\n 1% Risk Lot = ",StringLot(Money.LotManagement(UseRiskManagement,1,StopLoss,4)),
   "\n\n",
   "\n\n Newest Order Pnl : ",newPnL,
   "\n\n LastClosed Order Pnl : ",lastPnL,
   "\n\n ref : ",Money.refPrice(),
   "\n\n Margin Used : ",StringDollar(Acc_MarginUsed),
   "\n\n Tick Value : ",300*SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)
   ); 
   

}

void staticFunc() {
   static int staticVar = 0;
   staticVar++;
   Print(staticVar);
   if(staticVar==10) staticVar=0;
}

int speedometer() {
   int diff = 0;
   static double price  = 0;
   static ulong ul      = 0;
   ulong        ul_res  = 0;
   ul = GetMicrosecondCount();
   ul_res = GetMicrosecondCount()-ul;
   if(ul_res>=1000) {
      ul = 0;
      diff = PointToInt(fabs(Bid-price));
      price = Bid;
   }
   return diff;
}

void FirstOrder() {
   if(ActivateEA && NewBar(PERIOD_CURRENT) && MarginLevelProcced(500)) {
      int Signal = TradeSignal();
      int stop = StopLoss;
      int take = TakeProfit;
      string comment = OrderTradeComment;
      double UseLot = Money.LotManagement(UseRiskManagement,RiskPerTrade,StopLoss);
      //double UseLot = VerifyLotMinMax(StartLot);
      
      if(Signal<2) {
         if(Signal==OP_BUY) Trade.OpenBuy(MagicBuy_1,UseLot,comment,stop,take);
         else if(Signal==OP_SELL) Trade.OpenSell(MagicSell_1,UseLot,comment,stop,take);
      }
   }
}

int TradeSignal(){
   int x = 100;
   
   return x;
}

string comm(double balance, int leverage) {
   string msg = "";
   string FML = DoubleToString(Money.FullMarginLot(balance,leverage,30,105,1,4),2);
   double z = ceil(Money.MarginRequired(leverage,30,1,4)/0.1)*0.1;
   string MR1Lot = StringDollar(z);
   string MRMin = StringDollar(Money.MarginRequired(leverage,30,Market_MinLot,4));
   string MRFM = StringDollar(Money.MarginRequired(leverage,30,StringToDouble(FML),4));
   int Double = int(balance/StringToDouble(FML));
   
   msg = StringConcatenate(" Balance: $",balance,". Leverage 1:",leverage,". Full Margin: ",FML,"lot. TP Distance to double: ",Double,". Margin Req 1 Lot: ",MR1Lot,". Margin Req Min Lot: ",MRMin,". Margin Full Margin: ",MRFM);
   return msg;
}

void AccountParameter_Var() {
   // Account Info
   Acc_Balance       = AccountInfoDouble(ACCOUNT_BALANCE);
   Acc_Equity        = AccountInfoDouble(ACCOUNT_EQUITY);
   Acc_FreeMargin    = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   Acc_MarginUsed    = AccountInfoDouble(ACCOUNT_MARGIN);
   Acc_MarginLevel   = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   Market_TickValue  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   Market_Spread     = int(MarketInfo(_Symbol,MODE_SPREAD));
   Acc_Drawdown      = 0;
   NotiEnable        = TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);
   if(Acc_Balance>Acc_Equity && Acc_Balance>0) {
      Acc_Drawdown = StringToDouble(DoubleToString((1-(Acc_Equity/Acc_Balance))*100,1));
   }
   Acc_DrawdownText  = DoubleToString(Acc_Drawdown,1)+" %";
}

void AccountParameter_Symbol() {   
   Market_CalcMode   = int(MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   Market_Symbol     = _Symbol;
   SymbolCurr1       = StringSubstr(_Symbol,0,3);
   SymbolCurr2       = StringSubstr(_Symbol,3,3);
   SymbolCurrPrefix  = "";
   SymbolCurrSuffix  = "";
   
   if(Market_CalcMode==0 && StringLen(_Symbol)>6) {
      getPrefixSuffix(SymbolCurrPrefix,SymbolCurrSuffix);
      int lenprefix = StringLen(SymbolCurrPrefix);
      if(lenprefix==0) {
         Market_Symbol   = StringSubstr(_Symbol,0,6);
         SymbolCurr1     = StringSubstr(_Symbol,0,3);
         SymbolCurr2     = StringSubstr(_Symbol,3,3);
      }
      else {
         Market_Symbol   = StringSubstr(_Symbol,lenprefix,6);
         SymbolCurr1     = StringSubstr(_Symbol,lenprefix,3);
         SymbolCurr2     = StringSubstr(_Symbol,lenprefix+3,3);
      }
   }
}

void getPrefixSuffix(string& prefix, string& suffix){ 
   int SectorSize = 1936;
   prefix=""; suffix="";
   
   int fileHandle = FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ);
   if (fileHandle == -1) return; //HFILE Error
   
   for(int i=0;; i++){
      FileSeek(fileHandle, SectorSize*i, SEEK_SET); 
      if (FileIsEnding(fileHandle)) { prefix="err"; break; }
      string symbolName = FileReadString(fileHandle,12);
      
      symbolName = StringSubstr(symbolName,0);
      int pos = StringFind(symbolName,"EURUSD",0);
      if (pos > -1){
         if (pos>0) prefix = StringSubstr(symbolName,0,pos);
         if ((pos+6)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+6),0);
         break;
      }     
   } 
   if (fileHandle>-1) FileClose(fileHandle);
}

void AccountParameter_Fixed() {
   // Account Info
   Acc_Login            = int(AccountInfoInteger(ACCOUNT_LOGIN));
   Acc_Leverage         = int(AccountInfoInteger(ACCOUNT_LEVERAGE));
   Acc_Broker           = AccountInfoString(ACCOUNT_COMPANY);
   Acc_Currency         = AccountInfoString(ACCOUNT_CURRENCY);
   Acc_MaxOrder         = int(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   Acc_Slippage         = 2;
   // Market Info
   Market_ContractSize  = MarketInfo(_Symbol,MODE_LOTSIZE);
   Market_MarginHedge   = MarketInfo(_Symbol,MODE_MARGINHEDGED)/Market_ContractSize;
   Market_VolumeLimit   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
   Market_MaxLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   Market_MinLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   Market_LotStep       = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   Market_TickSize      = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)/_Point;
   Market_StopLevel     = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   Market_FreezeLevel   = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   Market_StopFreeze    = fmax(Market_StopLevel,Market_FreezeLevel);
   Acc_MarginCall       = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   Acc_StopOut          = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Acc_Pips             = 1;

   if(_Digits == 3 || _Digits == 5) {
      Acc_Slippage    = 15;
      Acc_Pips = 10;
   }
}

double CustomIndicator(ENUM_TIMEFRAMES timeframe, string name, int buffer, int input1, int input2, int shift = 1, bool market = false){
   if(market) return NormPrice(iCustom(_Symbol,timeframe,"\\Market\\"+name,input1,input2,buffer,shift));
   else return NormPrice(iCustom(_Symbol,timeframe,name,input1,input2,buffer,shift));
}

bool emptyValue(double value) {
   return value>EMPTY_VALUE-2;
}

bool PendingLevelsChk(string obj, int limit, double& level){
   double buffer  = NumToPoint(limit+Market_Spread);
   level   = NormPrice(ObjectGetValueByShift(obj,0));
   if(level!=0) return BetweenPriceRange(level+buffer,level-buffer);
   else return false;
}

bool ProductLicense(bool demo, bool acclock, int login, string owner){
   bool auth = true;
   bool is_auth = false;
   string msg = "";
   
   if(demo && !AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO) {
      msg = StringConcatenate("Only demo account allowed!");
      Alert(msg);
      auth = false;
   }
   if(acclock){
      for (int i=0; i<ArraySize(Allowed_Accounts); i++){
         if (login == Allowed_Accounts[i]){
            is_auth = true;
            break;
         }
      }
      if(!is_auth){
         msg = StringConcatenate("Invalid account number, please contact ",owner);
         Alert(msg);
         auth = false;
      }
   }
   return auth;
}

void SentStatus(int hour, int minutes, double report1, double report2, double report3) {
   string NewLine = "\n", sInput  = "%s";
   datetime time1 = HourMin(hour,minutes);
   datetime time2 = HourMin(hour,minutes+1);
   
   if(BetweenTimeRange(time1,time2) && FirstTick(PERIOD_M1)) {
      string floating = "No Order";
      string acc = " (Real)";
      if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO) acc = " (Demo)";
      if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(Report.FloatingStatusAll()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel),NewLine,"Drawdown : ",Acc_DrawdownText);
      
      string output_string = StringConcatenate("Broker : ",sInput,
                                                NewLine,"Acc Number : %d",sInput,
                                                NewLine,"Acc Balance : ",sInput,
                                                NewLine,"PnL Today : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Weekly : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Monthly : ",sInput,"  (",sInput,")",
                                                NewLine,"Orders Status : ",sInput
                                              );
                           
      string msg = StringFormat( output_string,
                                 Acc_Broker,
                                 Acc_Login,acc,
                                 StringDollar(Acc_Balance),
                                 StringDollar(report1),ReturnPercent(report1),
                                 StringDollar(report2),ReturnPercent(report2),
                                 StringDollar(report3),ReturnPercent(report3),
                                 floating
                               );
      Print(msg);
      if(TimeCurrent()>HourMin(23)) SendMailFunction("#"+IntegerToString(Acc_Login)+acc+" Acc Summary : "+TimeStampDate(),msg);
      if(NotiEnable) SendNotification(msg);
   }
}

double MartingaleLot(double lot, double multiplier, int level){
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double rawlot = lot*pow(multiplier,level);
   return VerifyLotMinMax(round(rawlot/step)*step);
}

bool GridDistChk(int magic, int distance = 0, bool martingale = true){
   double   distanceLvl = NumToPoint(distance);
   double   ChkLevel;

   if(distance>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic)) {
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(martingale) {
               if(OrderType() == OP_SELL){
                  ChkLevel = OrderOpenPrice() + distanceLvl;        
                  if(tick.bid>ChkLevel) return true;
               }
               else if(OrderType() == OP_BUY){
                  ChkLevel = OrderOpenPrice() - distanceLvl; 
                  if(tick.ask<ChkLevel) return true;
               }
            }
            else {
               if(OrderType() == OP_SELL){
                  ChkLevel = OrderOpenPrice() - distanceLvl;        
                  if(tick.bid<=ChkLevel) return true;
               }
               else if(OrderType() == OP_BUY){
                  ChkLevel = OrderOpenPrice() + distanceLvl; 
                  if(tick.bid>=ChkLevel) return true;
               }
            }
         }
      }
   }
   return false;
}

bool selectSymbol(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

bool selectSymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

bool selectTradeHistory(int i, datetime history){
   return (OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) && OrderCloseTime()>=history && (OrderType()==OP_BUY || OrderType()==OP_SELL) );
}

bool selectMagic(int i, int magic, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic);
}

bool selectMagicTrade(int i, int magic, int mode = MODE_TRADES){
   return (
   OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic 
   && (OrderType()==OP_BUY || OrderType()==OP_SELL)
   );
}

bool selectMagicPending(int i, int magic, int mode = MODE_TRADES){
   return (
   OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic 
   && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
   );
}

bool selectThisEA() {
   return (
   OrderMagicNumber()==MagicBuy_1   ||
   OrderMagicNumber()==MagicBuy_2   ||
   OrderMagicNumber()==MagicSell_1  ||
   OrderMagicNumber()==MagicSell_2
   );
}

// --- Counting Variable ------------------------------------------------------------------
// for(int i=0;i<total;i++) // Counting up
// for(int i=total; i>0; i--) // counting down
// for(int i = OrdersTotal() - 1; i >= 0 ; i--)

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}

int PointToInt (double point) {
   return int(point/_Point);
}

bool StopLevel(double pPrice) {
   double res = Market_StopFreeze;
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double uppermargin = tick.ask + res;
   double lowermargin = tick.bid - res;
   if(pPrice<=uppermargin && pPrice>=lowermargin) return false;
   else return true;
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return round(price/ticksize)*ticksize;
}

double NormLot(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(lot>minLot) {
      if(lot>maxLot) return maxLot;
      else return floor(lot/lotStep)*lotStep;
   }
   else return minLot;
}

string SymbolTimeframe() {
   return StringConcatenate(Market_Symbol+" ("+ChartTimeframe()+")");
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}

bool BetweenPriceRange(double a, double b) {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick); 
   double above = fmax(a,b);
   double below = fmin(a,b);
   return tick.bid<=above && tick.bid>=below;
}

bool OutsidePriceRange(double a, double b) {
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick); 
   double above = fmax(a,b);
   double below = fmin(a,b);
   return tick.bid>=above || tick.ask<=below;
}

bool BetweenPriceRange(double priceCompare, double a, double b) {
   double above = fmax(a,b);
   double below = fmin(a,b);
   return priceCompare<=above && priceCompare>=below;
}

bool SwitchSignal(int x, int y) {
   return ((x==OP_BUY && y==OP_SELL) || (x==OP_SELL && y==OP_BUY));
}

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool MarginLevelProcced(int margin){
   int marginLvl = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   return marginLvl==0 || marginLvl>=margin;
}

double VerifyLotMinMax(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(lot>=maxLot) return maxLot;
   else if(lot<minLot) return minLot;
   else return lot;
}

bool VariableSpreadFilter(){
   int MaxSpread = MAXSPREAD;
   string sym = Market_Symbol;
   if(sym=="EURUSD" || sym=="USDJPY" || sym=="GBPUSD") MaxSpread = 20;
   else if(sym=="AUDUSD" || sym=="NZDUSD" || sym=="EURJPY") MaxSpread = 24;
   else if(sym=="USDCAD" || sym=="USDCHF") MaxSpread = 26;
   if(Market_Spread>MaxSpread) return false;
   else return true;
}

string StringPrice(double price) {
   return DoubleToString(NormPrice(price),_Digits);
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

string StringMs(double ms) {
   string x = DoubleToString(ms/1000.0,2);
   string res = x;
   int z = StringLen(x); 
   if(z>6) {
      string s1 = StringSubstr(x,0,z-3);
      string s2 = StringSubstr(x,z-3);
      int ins1 = StrToInteger(s1);
      string sx = IntegerProper(ins1);
      res =  sx+s2; 
   }
   return res;
}

string StringLot(double lot) {
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   int x = 0;
   if(step==0.01) x = 2;
   else if(step==0.1) x = 1;
   return DoubleToString(lot,x);
}

double NormDollar(double dollarValue) {
   return round(dollarValue/0.01)*0.01;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double CMoney::MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0) {
   int margin              = spread*2;
   double marginRequired   = 0, 
          CommissionCost   = 0,
          referencePrice   = refPrice();
   
   // Account Multiplier
   double multiplier = (Market_ContractSize/double(leverage))*lotsize;
   // Margin Required
   if(SymbolCurr1==Acc_Currency) marginRequired = multiplier;
   else marginRequired = multiplier*referencePrice;
   // Commission Cost
   if(CommPerStdLotRoundTurn>0) CommissionCost = referencePrice*lotsize*CommPerStdLotRoundTurn;
   // Spread Cost
   if(Market_Spread<=1*Acc_Pips) margin =1*Acc_Pips;
   else if(Market_Spread<=2*Acc_Pips) margin = 2*Acc_Pips;
   else if(Market_Spread<=3*Acc_Pips) margin = 3*Acc_Pips;
   double SpreadCost = margin*lotsize*Market_TickValue;
   double raw = marginRequired+CommissionCost+SpreadCost;
   return ceil(raw/0.01)*0.01;
}

double CMoney::FullMarginLot(double balance, int leverage, int spread, double MinMarginPercentage = 105, int divider = 1, double CommPerStdLot = 0) {
   int buffer                    = 3*Acc_Pips;
   int margin                    = spread*2;
   double LotSize                = Market_MaxLot;
   double LevMargin              = Market_ContractSize/double(leverage);
   double RefPrice               = refPrice();
   double CommPerStdLotRoundTurn = fmax(CommPerStdLot,General.OrderCommissionChk());
   double CommissionCost         = 0;
   
   // CommissionPer1MilContract =  $4/roundtrip/1StdLot. for most broker = $20 per 1 million traded lot per turn
   if(CommPerStdLotRoundTurn>0) CommissionCost = RefPrice*CommPerStdLotRoundTurn;
   // Some room for margin calculation
   if(Market_Spread<=1*Acc_Pips)       margin = (2*Acc_Pips)+buffer;
   else if(Market_Spread<=2*Acc_Pips)  margin = (3*Acc_Pips)+buffer;
   else if(Market_Spread<=3*Acc_Pips)  margin = (4*Acc_Pips)+buffer;
   // calculation for cost
   double SpreadCost       = margin*Market_TickValue;
   double MarginReqCost    = RefPrice*LevMargin;
   double AccociateCost    = CommissionCost+MarginReqCost+SpreadCost;
   
   double divider_starter = MinMarginPercentage/100.0;
   if(divider_starter<1) divider_starter = 1.01;
   if(balance<100) divider_starter += 0.01;
   double Extreme = balance/divider_starter;
   
   if(divider<1) divider = 1.0;
   double rawlot = (Extreme/AccociateCost)/divider;
   double SuicideLot = NormLot(rawlot);
   if(SuicideLot<Market_MaxLot) LotSize = SuicideLot;

   return LotSize;
}

double CMoney::refPrice() {
   string refSym     = "", 
          refSym2    = "";
   double RefPrice   = 1,
          buffer     = NumToPoint(1*Acc_Pips);

   // Get Reference Price
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   if(SymbolCurr1==Acc_Currency) RefPrice = 1;
   else if(SymbolCurr2==Acc_Currency || Market_CalcMode!=0) RefPrice = tick.ask;
   else {
      refSym = SymbolCurr1+Acc_Currency;
      string ThisSym1 = refSym;
      string ThisSymX_1 = refSym;
      if(SymbolCurrPrefix!="" && SymbolCurrSuffix!="") ThisSym1 = SymbolCurrPrefix+ThisSymX_1+SymbolCurrSuffix;
      else if(SymbolCurrPrefix!="") ThisSym1 = SymbolCurrPrefix+ThisSymX_1;
      else if(SymbolCurrSuffix!="") ThisSym1 = ThisSymX_1+SymbolCurrSuffix;

      refSym2 = Acc_Currency+SymbolCurr1;
      string ThisSym2 = refSym2;
      string ThisSymX_2 = refSym2;
      if(SymbolCurrPrefix!="" && SymbolCurrSuffix!="") ThisSym2 = SymbolCurrPrefix+ThisSymX_2+SymbolCurrSuffix;
      else if(SymbolCurrPrefix!="") ThisSym2 = SymbolCurrPrefix+ThisSymX_2;
      else if(SymbolCurrSuffix!="") ThisSym2 = ThisSymX_2+SymbolCurrSuffix;
      
      // if deposit in USD
      if(Acc_Currency=="USD"){
         if(refSym=="EURUSD" || refSym=="GBPUSD" || refSym=="AUDUSD" || refSym=="NZDUSD" || refSym=="XAUUSD" || refSym=="XAGUSD" || 
         refSym=="BTCUSD" || refSym=="ETHUSD" || refSym=="XRPUSD") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1/(SymbolInfoDouble(ThisSym2,SYMBOL_ASK));
      }
      else if(Acc_Currency=="GBP") {
         if(refSym=="EURGBP") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1; // need to refine this code for deposit currency other than USD
      }
      else if(Acc_Currency=="JPY") {
         if(refSym=="EUJPY" || refSym=="GBPJPY" || refSym=="AUDJPY" || refSym=="NZDJPY" || refSym=="USDJPY" || refSym=="CADJPY" || refSym=="CHFJPY") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1; // need to refine this code for deposit currency other than USD
      }
   }
   
   return RefPrice+buffer;
}

double CMoney::LotManagement(bool pRiskManagement, double risk, int stop = 150, double CommPerStdLot = 0) {
   double RefPrice               = refPrice(),
          LotSize                = Market_MinLot,
          CommissionCost         = 0,
          CommPerStdLotRoundTurn = fmax(CommPerStdLot,General.OrderCommissionChk());
   
   if(!pRiskManagement) LotSize = VerifyLotMinMax(StartLot);
   else if(risk>0 && stop>0) {
      if(risk>MAXRISK) risk = MAXRISK; // Limit the max risk to 10%
      // Delta per lot
      double deltaperlot = Market_TickValue/double(Market_TickSize);
      // To manage Divided by Zero errors
      double deltaLot = 1.0;
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
   }
   return LotSize;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

int CCount::OrderAllTerminal() {
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select) {
         if(OrderType()==OP_BUY) count++;
         else if(OrderType()==OP_BUYLIMIT) count++;
         else if(OrderType()==OP_BUYSTOP) count++;
         else if(OrderType()==OP_SELL) count++;
         else if(OrderType()==OP_SELLLIMIT) count++;
         else if(OrderType()==OP_SELLSTOP) count++;
      }
   }
   return count;
}

int CCount::OrderAllSymbol(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order)) {
         if(OrderType()==OP_BUY) count++;
         else if(OrderType()==OP_BUYLIMIT) count++;
         else if(OrderType()==OP_BUYSTOP) count++;
         else if(OrderType()==OP_SELL) count++;
         else if(OrderType()==OP_SELLLIMIT) count++;
         else if(OrderType()==OP_SELLSTOP) count++;
      }
   }
   return count;
}

int CCount::OrderAllSymbol(int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order)) {
         if(type==OP_BUY && OrderType()==OP_BUY) count++;
         else if(type==OP_BUYLIMIT && OrderType()==OP_BUYLIMIT) count++;
         else if(type==OP_BUYSTOP && OrderType()==OP_BUYSTOP) count++;
         else if(type==OP_SELL && OrderType()==OP_SELL) count++;
         else if(type==OP_SELLLIMIT && OrderType()==OP_SELLLIMIT) count++;
         else if(type==OP_SELLSTOP && OrderType()==OP_SELLSTOP) count++;
      }
   }
   return count;
}

int CCount::OrderAll(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(selectMagic(order,magic)) {
         if(OrderType()==OP_BUY) count++;
         else if(OrderType()==OP_BUYLIMIT) count++;
         else if(OrderType()==OP_BUYSTOP) count++;
         else if(OrderType()==OP_SELL) count++;
         else if(OrderType()==OP_SELLLIMIT) count++;
         else if(OrderType()==OP_SELLSTOP) count++;
      }
   }
   return count;
}

int CCount::OrderAll(int magic, int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) {
         if(type==OP_BUY && OrderType()==OP_BUY) count++;
         else if(type==OP_BUYLIMIT && OrderType()==OP_BUYLIMIT) count++;
         else if(type==OP_BUYSTOP && OrderType()==OP_BUYSTOP) count++;
         else if(type==OP_SELL && OrderType()==OP_SELL) count++;
         else if(type==OP_SELLLIMIT && OrderType()==OP_SELLLIMIT) count++;
         else if(type==OP_SELLSTOP && OrderType()==OP_SELLSTOP) count++;
      }
   }
   return count;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

bool EnoughFund(double lot, int commission = 4) {
   return Acc_FreeMargin >= Money.MarginRequired(Acc_Leverage,Market_Spread+(5*Acc_Pips),lot,commission);
}

bool AcceptableDifference(double price, double pricecompare) {
   double buffer = NumToPoint(2);
   double range_u = pricecompare+buffer,
          range_b = pricecompare-buffer;
   if(price==pricecompare || (price<range_u && price>range_b)) return false;
   else return true;
}

void CTrade::TickData(){
   if(!MQLInfoInteger(MQL_TESTER)){
      while(!TerminalInfoInteger(TERMINAL_CONNECTED)) Sleep(1);
      while(IsTradeContextBusy()) Sleep(1);
      while(!RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

bool CTrade::OrderExist(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) {
         if(OrderType()==OP_BUY) count++;
         else if(OrderType()==OP_BUYLIMIT) count++;
         else if(OrderType()==OP_BUYSTOP) count++;
         else if(OrderType()==OP_SELL) count++;
         else if(OrderType()==OP_SELLLIMIT) count++;
         else if(OrderType()==OP_SELLSTOP) count++;
      }
   }
   if(count>0) return true;
   else return false;
}

bool CTrade::NewOrderChk(string orderType, int type, double lot, string& retMsg) {
   bool chk             = true;
   int maxOrder         = int(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   double maxLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double limitVol      = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);

   if(!EnoughFund(lot) || !MarginLevelProcced(105)) {
      retMsg = StringConcatenate(_Symbol+" ",orderType,": Not enough funds to open order with  ",lot," lot!");
      return false;
   }
   else if(maxOrder>0 && maxOrder==OrdersTotal()) {
      retMsg = _Symbol+" "+orderType+": Reaching Maximum order!";
      chk = false;
   }
   else if(lot<minLot || lot>maxLot) {
      retMsg = _Symbol+" "+orderType+": Invalid lot! - "+DoubleToString(lot,5);
      chk = false;
   }
   else if(limitVol>0) {
      if(General.TotalLotSymbol()+lot > limitVol) {
         retMsg = _Symbol+" "+orderType+": Reaching max volume!";
         chk = false;
      }
   }
   else if(orderType=="Market") {
      if(type==OP_BUYLIMIT || type==OP_BUYSTOP || type==OP_SELLLIMIT || type==OP_SELLSTOP) {
         retMsg = _Symbol+" "+orderType+": Invalid order type!";
         chk = false;
      }
   }
   else if(orderType=="Pending") {
      if(type==OP_BUY || type==OP_SELL) {
         retMsg = _Symbol+" "+orderType+": Invalid order type!";
         chk = false;
      }
   }
   return chk;
}

void CTrade::OpenOrder(int type, int magic, double lot, string comment){
   string msg;
   if(!NewOrderChk("Market",type,lot,msg)) {
      NotifySetting(msg);
      Sleep(5000);
      return;
   }
   else if(type==OP_BUY || type==OP_SELL){
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
      TickData(); // Updating Latest Tick Data
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      double price = tick.bid;
      color arrow  = clrRed;
      if(type==OP_BUY) {price = tick.ask;arrow = clrGreen;}
      int ticket = OrderSend(_Symbol,type,lot,price,Acc_Slippage,0,0,comment,magic,0,arrow);
      if(ticket == -1) OrderSendError("Market");
      else {
         ul_res = GetMicrosecondCount()-ul;
         if(!MQLInfoInteger(MQL_TESTER)) printf("Market order execute in %s ms.",StringMs(ul_res));
      }
   }
}

void CTrade::OpenPendingOrder(int type, int magic, double lot, double pPricePending, string comment, int expiredMinutes){
   string   msg;
   bool     proceed     = false;
   color    arrow       = clrGreen;
   datetime Expired     = 0;
   double stopLevel     = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   double freezeLevel   = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   double useLvl        = fmax(stopLevel,freezeLevel);

   if(!NewOrderChk("Pending",type,lot,msg)) {
      NotifySetting(msg);
      Sleep(5000);
      return;
   }
   
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   if((type==OP_BUYLIMIT || type==OP_SELLSTOP) && tick.bid>pPricePending+useLvl) proceed = true;
   else if((type==OP_SELLLIMIT || type==OP_BUYSTOP)) {
      arrow = clrRed;
      if(tick.ask<pPricePending-useLvl) proceed = true;
   }
   
   if(proceed){
      int retry = 0;
      int ticket = -1;
      
      if(expiredMinutes>0) {
         if(expiredMinutes<12) {
            msg = _Symbol+" Pending Order: Minimum expired is 12 minutes. Re-adjust expiry to 12 minutes!";
            NotifySetting(msg);
            Expired = TimeCurrent()+12*PeriodSeconds(PERIOD_M1);
         }
         else Expired = TimeCurrent()+expiredMinutes*PeriodSeconds(PERIOD_M1);
         if(Expired>HourMin(23,54) && TimeCurrent()<HourMin(23,40)) Expired = HourMin(23,54);   // expired end of the day
      }

      while(retry <= MAX_RETRIES) {
         ticket = OrderSend(_Symbol,type,lot,pPricePending,Acc_Slippage,0,0,comment,magic,Expired,arrow);
         if(ticket != -1) break;
         else {
            bool RetryOnServerError = ServerError(_LastError);
            if(RetryOnServerError) {
               retry++;
               Print("Server error detected, retrying...");
               Sleep(RETRY_DELAY);
            }
            else break;
         }
      } // -- end while retry ---
      if(ticket == -1) OrderSendError("Pending");
   }
}

void CTrade::OpenBuy(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0){
   if(!OrderExist(magic) && SpreadFilterPair()){
      OpenOrder(OP_BUY,magic,lot,comment);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice<tick.bid-Market_StopLevel) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice>tick.ask+Market_StopLevel) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenSell(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0){
   if(!OrderExist(magic) && SpreadFilterPair()){
      OpenOrder(OP_SELL,magic,lot,comment);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice>tick.ask+Market_StopLevel) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice<tick.bid-Market_StopLevel) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenBuyLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0){
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_BUYLIMIT,magic,lot,pPendingPrice,comment,expired);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
   }
}

void CTrade::OpenBuyStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0){
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_BUYSTOP,magic,lot,pPendingPrice,comment,expired);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
   }
}

void CTrade::OpenSellLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0){
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_SELLLIMIT,magic,lot,pPendingPrice,comment,expired);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
   }
}

void CTrade::OpenSellStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0){
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_SELLSTOP,magic,lot,pPendingPrice,comment,expired);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
   }
}

void CTrade::CloseOrder(int magic){
   if(OrderExist(magic)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic)) {
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  while(!SpreadFilterPair()) Sleep(1000);
                  TickData();
                  closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     if(MQLInfoInteger(MQL_TESTER)) Print("Order #",OrderTicket()," closed.");
                     else printf("Order ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                     break;
                  }
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!closeorder) OrderCloseError(OrderTicket(),"close");
            }
         }     
      }
   }
}

void CTrade::CloseOrderBy(int magic1, int magic2){
   if(OrderExist(magic2) && OrderExist(magic2)) {
      double lot1 = Property.orderLot(magic1);
      double lot2 = Property.orderLot(magic2);
      int type2   = Property.type(magic2);
      int ticket2 = Property.ticket(magic2); 
      
      if(lot1<=lot2 && (type2==OP_BUY||type2==OP_SELL)) {
         for(int order = OrdersTotal()-1; order >= 0; order--){
            if(selectMagicTrade(order,magic1)) {
               bool proceed = true;     
               if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
               else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
               if(proceed) {
                  ulong  ul=0, ul_res=0;
                  ul = GetMicrosecondCount();
                  int retry = 0;
                  bool closeorder = false;
                  while(retry <= MAX_RETRIES) {
                     while(!SpreadFilterPair()) Sleep(1000);
                     TickData();
                     //closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
                     closeorder = OrderCloseBy(OrderTicket(),ticket2,clrRed);
                     if(closeorder) {
                        ul_res = GetMicrosecondCount()-ul;
                        if(MQLInfoInteger(MQL_TESTER)) Print("Order closeby #",OrderTicket()," closed.");
                        else printf("Order closeby ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                        break;
                     }
                     else {
                        bool RetryOnServerError = ServerError(_LastError);
                        if(RetryOnServerError) {
                           retry++;
                           Print("Server error detected, retrying...");
                           Sleep(RETRY_DELAY);
                        }
                        else break;
                     }
                  } // -- end while retry ---
                  if(!closeorder) OrderCloseError(OrderTicket(),"close");
               }
            }     
         }
      }
   }
}

bool CTrade::multiple_closeby_symbol() {
   for(int i=OrdersTotal()-1; i>0; --i){
      if(selectSymbolTrade(i)) {
         ulong  ul=0, ul_res=0;
         ul = GetMicrosecondCount();
         int    first_ticket = OrderTicket();
         int    first_type   = OrderType();
         for(int j=i-1; j>=0; --j){
            if(OrderSelect(j, SELECT_BY_POS) && OrderType() < 2 && OrderSymbol() == _Symbol && OrderType()!= first_type) {
               bool closeorder = false;
               closeorder = OrderCloseBy(first_ticket, OrderTicket(),clrRed);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  if(MQLInfoInteger(MQL_TESTER)) Print("CloseBy Order #",OrderTicket()," closed.");
                  else printf("CloseBy Order ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                  return multiple_closeby_symbol();
               }
               else return false;
            }
         }
         break;
      }
   }
   return true;
}

bool CTrade::multiple_closeby_symbol(const int magic) {
   for(int i=OrdersTotal()-1; i>0; --i){
      if(selectMagicTrade(i,magic)) {
         ulong  ul=0, ul_res=0;
         ul = GetMicrosecondCount();
         int    first_ticket = OrderTicket();
         int    first_type   = OrderType();
         for(int j=i-1; j>=0; --j){
            if(OrderSelect(j, SELECT_BY_POS) && OrderType() < 2 && OrderSymbol() == _Symbol && OrderType()!= first_type) {
               bool closeorder = false;
               closeorder = OrderCloseBy(first_ticket, OrderTicket(),clrRed);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  if(MQLInfoInteger(MQL_TESTER)) Print("CloseBy Order #",OrderTicket()," closed.");
                  else printf("CloseBy Order ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                  return multiple_closeby_symbol(magic);
               }
               else return false;
            }
         }
         break;
      }
   }
   return true;
}

void CTrade::CloseAllOrder_Symbol(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(selectSymbolTrade(order)){
         bool proceed = true;
         if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
         else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
         if(proceed) {
            ulong  ul=0, ul_res=0;
            ul = GetMicrosecondCount();
            int retry = 0;
            bool closeorder = false;
            while(retry <= MAX_RETRIES) {
               while(!SpreadFilterPair()) Sleep(1000);
               TickData();
               closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  if(MQLInfoInteger(MQL_TESTER)) Print("Order #",OrderTicket()," closed.");
                  else printf("Order ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                  order--;
                  break;
               }
               else {
                  bool RetryOnServerError = ServerError(_LastError);
                  if(RetryOnServerError) {
                     retry++;
                     Print("Server error detected, retrying...");
                     Sleep(RETRY_DELAY);
                  }
                  else break;
               }
            } // -- end while retry ---
            if(!closeorder) OrderCloseError(OrderTicket(),"close");
         }
      }
   }
}

void CTrade::CloseAllOrder_Terminal(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && (OrderType()==OP_BUY || OrderType()==OP_SELL)){
         bool proceed = true;
         if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
         else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
         if(proceed) {
            ulong  ul=0, ul_res=0;
            ul = GetMicrosecondCount();
            int retry = 0;
            bool closeorder = false;
            while(retry <= MAX_RETRIES) {
               while(!SpreadFilterPair()) Sleep(1000);
               TickData();
               closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  if(MQLInfoInteger(MQL_TESTER)) Print("Order #",OrderTicket()," closed.");
                  else printf("Order ticket %d closed in %s ms.",OrderTicket(),StringMs(ul_res));
                  order--;
                  break;
               }
               else {
                  bool RetryOnServerError = ServerError(_LastError);
                  if(RetryOnServerError) {
                     retry++;
                     Print("Server error detected, retrying...");
                     Sleep(RETRY_DELAY);
                  }
                  else break;
               }
            } // -- end while retry ---
            if(!closeorder) OrderCloseError(OrderTicket(),"close");
         }
      }
   }
}

void CTrade::CloseAllOrder_HedgingCloseBy() {
   int loop = 0;
   bool leftOver = true;
   while(leftOver) {
      bool CloseByPossible = Count.OrderAllSymbol(OP_BUY)>0 && Count.OrderAllSymbol(OP_SELL)>0;
      bool exist = true;
      while(exist && CloseByPossible) {
         exist = multiple_closeby_symbol();
      }
      leftOver = Count.OrderAllSymbol(OP_BUY)>0 && Count.OrderAllSymbol(OP_SELL)>0;
   }
}

void CTrade::CloseAllOrder_HedgingCloseBy(int magic) {
   int loop = 0;
   int magicType = Property.type(magic);
   bool leftOver = true;
   while(leftOver) {
      bool CloseByPossible = Count.OrderAllSymbol(OP_BUY)-Count.OrderAll(magic)>0 && Count.OrderAllSymbol(OP_SELL)>0;
      if(magicType==OP_SELL) CloseByPossible = Count.OrderAllSymbol(OP_BUY)>0 && Count.OrderAllSymbol(OP_SELL)-Count.OrderAll(magic)>0;
      
      bool exist = true;
      while(exist && CloseByPossible) {
         exist = multiple_closeby_symbol(magic);
      }
      
      if(magicType==OP_BUY) leftOver = Count.OrderAllSymbol(OP_BUY)-Count.OrderAll(magic)>0 && Count.OrderAllSymbol(OP_SELL)>0;
      else if(magicType==OP_SELL) leftOver = Count.OrderAllSymbol(OP_BUY)>0 && Count.OrderAllSymbol(OP_SELL)-Count.OrderAll(magic)>0;
   }
}

void CTrade::PartialClose(int magic, double lot) {
   if(OrderExist(magic)) {
      string msg1 = "Partial Order #";
      string msg2 = " closed. Order ticket changed.";
      double originallot = Property.orderLot(magic);
      if(lot>0) {
         if(lot>=originallot) {
            lot = originallot;
            msg1 = "Order #";
            msg2 = " closed.";
         }
         for(int order = OrdersTotal()-1; order >= 0; order--){
            if(selectMagicTrade(order,magic)) {
               bool proceed = true;     
               if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
               else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
               if(proceed) {
                  int retry = 0;
                  bool closeorder = false;
                  while(retry <= MAX_RETRIES) {
                     while(!SpreadFilterPair()) Sleep(1000);
                     TickData();
                     closeorder = OrderClose(OrderTicket(),lot,OrderClosePrice(),Acc_Slippage,clrRed);
                     if(closeorder) {
                        Print(msg1, OrderTicket(),msg2);
                        break;
                     }
                     else {
                        bool RetryOnServerError = ServerError(_LastError);
                        if(RetryOnServerError) {
                           retry++;
                           Print("Server error detected, retrying...");
                           Sleep(RETRY_DELAY);
                        }
                        else break;
                     }
                  } // -- end while retry ---
                  if(!closeorder) OrderCloseError(OrderTicket(),"partial close");
               }
            }     
         }
      }
   }
}

void CTrade::DeletePendingOrder(int magic){
   if(OrderExist(magic)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicPending(order,magic)) {
            if(StopLevel(OrderOpenPrice())) {
               int retry = 0;
               bool Deleted = false;
               while(retry <= MAX_RETRIES) {
                  Deleted = OrderDelete(OrderTicket(),clrRed);
                  if(Deleted) {
                     Print("Order # ", OrderTicket(), " deleted.");
                     break;
                  }
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!Deleted) OrderCloseError(OrderTicket(),"delete");
            }
         }
      }
   }
}

void CTrade::DeleteAllPendingOrder_Symbol(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)){
         if(StopLevel(OrderOpenPrice())) {
            int retry = 0;
            bool Deleted = false;
            while(retry <= MAX_RETRIES) {
               Deleted = OrderDelete(OrderTicket(),clrRed);
               if(Deleted) {
                  Print("Order # ", OrderTicket(), " deleted");
                  order--;
                  break;
               }
               else {
                  bool RetryOnServerError = ServerError(_LastError);
                  if(RetryOnServerError) {
                     retry++;
                     Print("Server error detected, retrying...");
                     Sleep(RETRY_DELAY);
                  }
                  else break;
               }
            } // -- end while retry ---
            if(!Deleted) OrderCloseError(OrderTicket(),"delete");
         }
      }
   }
}

void CTrade::DeleteAllPendingOrder_Terminal(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)){
         if(StopLevel(OrderOpenPrice())) {
            int retry = 0;
            bool Deleted = false;
            while(retry <= MAX_RETRIES) {
               Deleted = OrderDelete(OrderTicket(),clrRed);
               if(Deleted) {
                  Print("Order # ", OrderTicket(), " deleted");
                  order--;
                  break;
               }
               else {
                  bool RetryOnServerError = ServerError(_LastError);
                  if(RetryOnServerError) {
                     retry++;
                     Print("Server error detected, retrying...");
                     Sleep(RETRY_DELAY);
                  }
                  else break;
               }
            } // -- end while retry ---
            if(!Deleted) OrderCloseError(OrderTicket(),"delete");
         }
      }
   }
}

void CTrade::DeletePendingOrderTimer(int magic, int second) {
   if(OrderExist(magic)) {
      datetime opentimeLimit = Property.openTime(magic)+second;
      if(TimeCurrent()>=opentimeLimit) DeletePendingOrder(magic);   
   }
}

void CTrade::DeleteSLTP() { 
   for(int order = OrdersTotal()-1; order >= 0; order--){ 
      if(selectSymbol(order)){
         int retry = 0;
         bool modify = false;
         while(retry <= MAX_RETRIES) {
            modify = OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0);
            if(modify) break;
            else {
               bool RetryOnServerError = ServerError(_LastError);
               if(RetryOnServerError) {
                  retry++;
                  Print("Server error detected, retrying...");
                  Sleep(RETRY_DELAY);
               }
               else break;
            }
         } // End while retry
         if(!modify) ModifyError(OrderTicket());
      }
   }
}

void CTrade::ModPendingOrder(int magic, double pPending) { 
   if(OrderExist(magic) && pPending>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicPending(order,magic)) {
            double NormPending = NormPrice(pPending);
            if(AcceptableDifference(OrderOpenPrice(),NormPending) && StopLevel(NormPending)){
               datetime bufferExpired = TimeCurrent()+12*PeriodSeconds(PERIOD_M1);
               if(OrderExpiration()==0 || (OrderExpiration()>0 && bufferExpired<OrderExpiration())) {
                  int retry = 0;
                  bool modify = false;
                  while(retry <= MAX_RETRIES) {
                     modify = OrderModify(OrderTicket(),NormPending,OrderStopLoss(),OrderTakeProfit(),OrderExpiration());
                     if(modify) break;
                     else {
                        bool RetryOnServerError = ServerError(_LastError);
                        if(RetryOnServerError) {
                           retry++;
                           Print("Server error detected, retrying...");
                           Sleep(RETRY_DELAY);
                        }
                        else break;
                     }
                  } // while retry loop
                  if(!modify) ModifyError(OrderTicket());
               }
            } 
         }
      }
   }
}

void CTrade::ModifyStopLoss(int magic, double pPriceSL) { 
   if(OrderExist(magic) && pPriceSL>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagic(order,magic)) {
            double NormSL = NormPrice(pPriceSL);
            if(AcceptableDifference(OrderStopLoss(),NormSL) && StopLevel(NormSL)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),NormSL,OrderTakeProfit(),0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify) ModifyError(OrderTicket());
            }
         }
      }
   }
}

void CTrade::ModifyTakeProfit(int magic, double pPriceTP) { 
   if(OrderExist(magic) && pPriceTP>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagic(order,magic)) {
            double NormTP = NormPrice(pPriceTP);
            if(AcceptableDifference(OrderTakeProfit(),NormTP) && StopLevel(NormTP)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormTP,0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify) ModifyError(OrderTicket());
            } 
         }
      }
   }
}

void CTrade::ModifySL_Point(int magic, int stopPoint) { 
   if(OrderExist(magic) && stopPoint>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagic(order,magic)) {
            bool proceedmodify = false;
            double bufferSL = NumToPoint(stopPoint), pPriceSL = 0;
            if(OrderType()==OP_BUY) {
               pPriceSL = OrderOpenPrice() - bufferSL;
               if(StopLevel(pPriceSL)) proceedmodify = true;
            }
            else if(OrderType()==OP_SELL) {
               pPriceSL = OrderOpenPrice() + bufferSL;
               if(StopLevel(pPriceSL)) proceedmodify = true;
            }
            if(proceedmodify && AcceptableDifference(OrderStopLoss(),pPriceSL)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),pPriceSL,OrderTakeProfit(),0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify) ModifyError(OrderTicket());
            }
         }
      }
   }
}

void CTrade::ModifyTP_Point(int magic, int takePoint) { 
   if(OrderExist(magic) && takePoint>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagic(order,magic)) {
            bool proceedmodify = false;
            double bufferTP = NumToPoint(takePoint), pPriceTP = 0;
            if(OrderType()==OP_BUY) {
               pPriceTP = OrderOpenPrice() + bufferTP;
               if(StopLevel(pPriceTP)) proceedmodify = true;
            }
            else if(OrderType()==OP_SELL) {
               pPriceTP = OrderOpenPrice() - bufferTP;
               if(StopLevel(pPriceTP)) proceedmodify = true;
            }
            if(proceedmodify && AcceptableDifference(OrderTakeProfit(),pPriceTP)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),pPriceTP,0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               }
               if(!modify) ModifyError(OrderTicket());
            }
         }
      }
   }
}

string CTrade::SignalComment(int sig) {
   string x;
   switch(sig){      
      case OP_BUY:         x = "BUY";        break;
      case OP_BUYLIMIT:    x = "BUY LIMIT";  break;
      case OP_BUYSTOP:     x = "BUY STOP";   break;
      case OP_SELL:        x = "SELL";       break;
      case OP_SELLLIMIT:   x = "SELL LIMIT"; break;
      case OP_SELLSTOP:    x = "SELL STOP";  break;
      case 100:            x = "NO SIGNAL";  break;
      default:             x = "INVALID SIGNAL";
   }
   return x;
}

string CTrade::SignalDirection(int sig) {
   string x;
   switch(sig){      
      case OP_BUY:         x = "BUY DIRECTION";        break;
      case OP_SELL:        x = "SELL DIRECTION";       break;
      default:             x = "NO DIRECTION";
   }
   return x;
}

bool CTrade::ServerError(int pErrorCode){
   switch(pErrorCode) {
		case ERR_BROKER_BUSY:
		case ERR_COMMON_ERROR:
		case ERR_NO_ERROR:
		case ERR_NO_CONNECTION:
		case ERR_NO_RESULT:
		case ERR_SERVER_BUSY:
		case ERR_NOT_ENOUGH_RIGHTS:
      case ERR_MALFUNCTIONAL_TRADE:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_TRADE_TIMEOUT:
      case ERR_REQUOTE:
      case ERR_TOO_MANY_REQUESTS:
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_TOO_FREQUENT_REQUESTS:
		return(true);
	}
	return(false);
}

int CTrade::Identifier(int identifier){
   int x = 99;
   string sym = Market_Symbol;
   
   if(sym=="EURUSD") x = 1;
   else if(sym=="EURJPY") x = 2;
   else if(sym=="EURGBP") x = 3;
   else if(sym=="EURAUD") x = 4;
   else if(sym=="EURNZD") x = 5;
   else if(sym=="EURCHF") x = 6;
   else if(sym=="EURCAD") x = 7;
   else if(sym=="GBPUSD") x = 8;
   else if(sym=="GBPJPY") x = 9;
   else if(sym=="GBPAUD") x = 10;
   else if(sym=="GBPNZD") x = 11;
   else if(sym=="GBPCHF") x = 12;
   else if(sym=="GBPCAD") x = 13;
   else if(sym=="USDJPY") x = 14;
   else if(sym=="USDCHF") x = 15;
   else if(sym=="USDCAD") x = 16;
   else if(sym=="USDCNH") x = 17;
   else if(sym=="USDCZK") x = 18;
   else if(sym=="USDHKD") x = 19;
   else if(sym=="USDHUF") x = 20;
   else if(sym=="USDMXN") x = 21;
   else if(sym=="USDNOK") x = 22;
   else if(sym=="USDSEK") x = 23;
   else if(sym=="USDSGD") x = 24;
   else if(sym=="USDTRY") x = 25;
   else if(sym=="USDZAR") x = 26;
   else if(sym=="USDRUB") x = 27;
   else if(sym=="USDPLN") x = 28;
   else if(sym=="AUDUSD") x = 29;
   else if(sym=="AUDJPY") x = 30;
   else if(sym=="AUDCHF") x = 31;
   else if(sym=="AUDCAD") x = 32;
   else if(sym=="NZDUSD") x = 33;
   else if(sym=="NZDJPY") x = 34;
   else if(sym=="NZDCHF") x = 35;
   else if(sym=="NZDCAD") x = 36;
   else if(sym=="CADJPY") x = 37;
   else if(sym=="CADCHF") x = 38;
   else if(sym=="AUDNZD") x = 39;
   else if(sym=="CHFJPY") x = 40;
   else if(sym=="XAUUSD") x = 41;   // Gold
   else if(sym=="XAGUSD") x = 42;   // Silver
   else if(sym=="BTCUSD") x = 43;   // Bitcoin
   else if(sym=="ETHUSD") x = 44;   // Ethrium
   else if(sym=="XRPUSD") x = 45;   // XRP
   else if(sym=="BCHUSD") x = 46;   // BCH
   else if(sym=="DCHUSD") x = 47;   // DCH
   else if(sym=="LTCUSD") x = 48;   // LTC
   else if(sym=="BRENT" || sym == "BRN")  x = 49;   // BRENT
   else if(sym=="WTI")    x = 50;   // WTI

   return x * identifier;
}

int CTrade::getID(){
   return s_id++;
}

int CTrade::generateID(int x) {
   return x + getID();
}

void CTrade::AssignMagic(int identifier) {
   int ref = Identifier(identifier);
   MagicBuy_1  = generateID(ref);
   MagicBuy_2  = generateID(ref);
   MagicSell_1 = generateID(ref);
   MagicSell_2 = generateID(ref);
}

void CTrade::OrderSendError(string ordertype){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,
                                             NewLine,sInput," order failed!",
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void CTrade::ModifyError(int ticket){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,
                                             NewLine,"Order ticket #%d modify failed!",
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ticket,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void CTrade::OrderCloseError(int ticket, string action){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,
                                             NewLine,"Order ticket #%d failed to ",sInput,
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ticket,action,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void CTrade::NotifySetting(string msg) {
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(msg);
   if(NotiEnable) SendNotification(acc);
   ResetLastError();
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

void CFeatures::HiddenSL(int magic, int stopPoint){
   bool     ChkCondition   = false;
   double   bufferSL       = NumToPoint(stopPoint);
   double   stopLoss;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagicTrade(order,magic) && stopPoint>0) {
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         double ClosingBuy = tick.bid;
         double ClosingSell = tick.ask;
         if(!VariableSpreadFilter()){
            ClosingBuy = tick.ask;
            ClosingSell = tick.bid;
         }
         if(OrderType()==OP_BUY) {
            stopLoss = OrderOpenPrice() - bufferSL;
            if(ClosingBuy<=stopLoss) ChkCondition = true;
         }
         else if(OrderType()==OP_SELL){
            stopLoss = OrderOpenPrice() + bufferSL;
            if(ClosingSell>=stopLoss) ChkCondition = true;
         }
         if(ChkCondition) Trade.CloseOrder(magic);
      }
   }
}

void CFeatures::HiddenTP(int magic, int takePoint){
   bool ChkCondition = false;
   if(Count.OrderAll(magic)>0 && takePoint>0) {
      double   bufferTP = NumToPoint(takePoint);
      double   takeProfit;
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic) && takePoint>0) {
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            double ClosingBuy = tick.bid;
            double ClosingSell = tick.ask;         
            if(OrderType()==OP_BUY) {
               takeProfit    = OrderOpenPrice() + bufferTP;
               if(ClosingBuy>=takeProfit) ChkCondition = true;
            }
            else if(OrderType()==OP_SELL){
               takeProfit    = OrderOpenPrice() - bufferTP;
               if(ClosingSell<=takeProfit) ChkCondition = true;
            }
            if(ChkCondition) Trade.CloseOrder(magic);
         }
      }
   }
}

bool CFeatures::HiddenTP_Trail(int magic, int takePoint){
   bool ChkCondition = false;
   if(Count.OrderAll(magic)>0 && takePoint>0) {
      double bufferTP = NumToPoint(takePoint);
      double takeProfit;
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic) && takePoint>0) {
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            double ClosingBuy = tick.bid;
            double ClosingSell = tick.ask;         
            if(OrderType()==OP_BUY) {
               takeProfit    = OrderOpenPrice() + bufferTP;
               if(ClosingBuy>=takeProfit) ChkCondition = true;
            }
            else if(OrderType()==OP_SELL){
               takeProfit    = OrderOpenPrice() - bufferTP;
               if(ClosingSell<=takeProfit) ChkCondition = true;
            }
         }
      }
   }
   return ChkCondition;
}

void CFeatures::HiddenSLTP(int magic, int stopPoint, int takePoint, bool trail = false){
   HiddenSL(magic,stopPoint);
   if(takePoint>0) {
      if(!trail) HiddenTP(magic,takePoint);
      else if(HiddenTP_Trail(magic,takePoint)) ProtectingTargetScalp(magic);
   }
}

void CFeatures::HiddenSLTP(int magic, double pPriceSL, double pPriceTP){
   if(Count.OrderAll(magic)>0 && pPriceSL>0 && pPriceTP>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic)) {
            bool ChkCondition = false;
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            double ClosingBuy = tick.bid;
            double ClosingSell = tick.ask;
            if(!SpreadFilterPair()){
               ClosingBuy = tick.ask;
               ClosingSell = tick.bid;
            }
            if(OrderType()==OP_BUY && (ClosingBuy>=pPriceTP || ClosingBuy<=pPriceSL)) ChkCondition = true; 
            else if(OrderType()==OP_SELL && (ClosingSell<=pPriceTP || ClosingSell>=pPriceSL)) ChkCondition = true;
            if(ChkCondition) Trade.CloseOrder(magic);
         }
      }
   }
}

void CFeatures::BreakEven(int magic, int distance, int lock = 10){
   if(Count.OrderAll(magic)>0 && distance>lock && lock>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic)) {         
            double TrailingLevel,LockBE;
            double buffer_distance = NumToPoint(distance);
            double buffer_lock = NumToPoint(lock);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(OrderType() == OP_SELL){
               TrailingLevel = OrderOpenPrice() - buffer_distance;
               LockBE = OrderOpenPrice() - buffer_lock;
               if(tick.ask<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) Trade.ModifyStopLoss(magic,LockBE);
            }
            else if(OrderType() == OP_BUY){
               TrailingLevel = OrderOpenPrice() + buffer_distance;
               LockBE = OrderOpenPrice() + buffer_lock;
               if(tick.bid>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) Trade.ModifyStopLoss(magic,LockBE);
            }
         } 
      } 
   }
}

void CFeatures::TrailingStop(int magic, int distance, int step = 10){
   if(Count.OrderAll(magic)>0 && distance>step && step>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic) && OrderStopLoss()>0) {
            double TrailingLevel,StepLevel;
            double buffer_distance = NumToPoint(distance);
            double buffer_step = NumToPoint(step);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(OrderType() == OP_SELL && OrderStopLoss()<=OrderOpenPrice()){
               TrailingLevel = OrderStopLoss() - buffer_distance;
               StepLevel     = OrderStopLoss() - buffer_step;
               if(tick.ask<TrailingLevel) Trade.ModifyStopLoss(magic,StepLevel);
            }
            else if(OrderType() == OP_BUY && OrderStopLoss()>=OrderOpenPrice()){
               TrailingLevel = OrderStopLoss() + buffer_distance;
               StepLevel     = OrderStopLoss() + buffer_step;
               if(tick.bid>TrailingLevel) Trade.ModifyStopLoss(magic,StepLevel);
            }
         } 
      }
   }
}

void CFeatures::SystemTrailing(int magic, int distance = 100, int step = 10){
   BreakEven(magic,distance,step);
   TrailingStop(magic,distance,step);
}

void CFeatures::TrailingStopIndicator(int magic, double value){
   if(Count.OrderAll(magic)>0 && value>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic)) {
            double trailValue = NormPrice(value);
            if(StopLevel(trailValue)) {
               if(OrderType()==OP_SELL && OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()>value) Trade.ModifyStopLoss(magic,trailValue);
               else if(OrderType()==OP_BUY && OrderStopLoss()>=OrderOpenPrice() && OrderStopLoss()<value) Trade.ModifyStopLoss(magic,trailValue);
            }
         } 
      }
   }
}

void CFeatures::TrailingStop_Hidden(int magic, int distance, int step = 10){
   if(Count.OrderAll(magic)>0 && distance>step && step>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectMagicTrade(order,magic) && OrderStopLoss()>0) {
            double TrailingLevel,StepLevel;
            double buffer_distance = NumToPoint(distance);
            double buffer_step = NumToPoint(step);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(OrderType() == OP_SELL && OrderStopLoss()<=OrderOpenPrice()){
               TrailingLevel = OrderStopLoss() - buffer_distance;
               StepLevel     = OrderStopLoss() - buffer_step;
               if(tick.ask<TrailingLevel) DrawShortHLine("HiddenTrailing",StepLevel,STYLE_DASHDOT,clrRed,1);
            }
            else if(OrderType() == OP_BUY && OrderStopLoss()>=OrderOpenPrice()){
               TrailingLevel = OrderStopLoss() + buffer_distance;
               StepLevel     = OrderStopLoss() + buffer_step;
               if(tick.bid>TrailingLevel) DrawShortHLine("HiddenTrailing",StepLevel,STYLE_DASHDOT,clrRed,1);
            }
            
            double TrailLevel = 0;
            bool CloseHiddenTrail = false;
            bool TrailingExist = PendingLevelsChk(ObjIdentifier+"HiddenTrailing",3*Acc_Pips,TrailLevel);
            
            if(TrailingExist) {
               if(OrderType()==OP_SELL && tick.ask>=TrailLevel) CloseHiddenTrail = true;
               else if(OrderType()==OP_BUY && tick.bid<=TrailLevel) CloseHiddenTrail = true;
            }
            if(CloseHiddenTrail) {
               Trade.CloseOrder(magic);
               ObjectDrawDelete(ObjIdentifier,"HiddenTrailing");
            }
         } 
      }
   }
   else ObjectDrawDelete(ObjIdentifier,"HiddenTrailing");
}

void DrawShortHLine(string objName, double pPrice, int style, color clr, int width) {   
   datetime T0 = iTime(_Symbol,PERIOD_H1,2);
   datetime T1 = Time[0];
   
   if (ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   else{
      ObjectDelete(0,ObjIdentifier+objName);
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY, false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
}

void CFeatures::ProtectingTarget(int magic, int trigger = 25, int lock = 25, double TP_Level = 0) {
   if(Count.OrderAll(magic)>0) {
      int type = Property.type(magic);
      double SL = Property.stopLoss(magic);
      double TP = Property.takeProfit(magic);
      double OP = Property.openPrice(magic);
      double trigger_buy,trigger_sell,TriggerSL;
      double dis_trigger   = NumToPoint(trigger);
      double dis_lock      = NumToPoint(lock);
      double buffer        = NumToPoint(2*Acc_Pips);
      double maxVal        = Market_StopFreeze;
      bool checkrange      = BetweenPriceRange(TP_Level+dis_trigger+buffer,TP_Level-dis_trigger-buffer);
      
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(TP>0) {
         trigger_buy   = TP-dis_trigger;
         trigger_sell  = TP+dis_trigger;
         
         if(type==OP_BUY && TP>OP && tick.ask>trigger_buy) {
            TriggerSL = tick.bid-(dis_lock+maxVal);
            if(SL<TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
         }
         else if(type==OP_SELL && TP<OP && tick.bid<trigger_sell) {
            TriggerSL = tick.ask+(dis_lock+maxVal);
            if(SL>TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
         }
      }
      
      if(TP_Level>0 && checkrange) {
         trigger_buy   = TP_Level-dis_trigger;
         trigger_sell  = TP_Level+dis_trigger;
         if(type==OP_BUY && TP_Level>OP && tick.ask>trigger_buy) {
            TriggerSL = tick.bid-(dis_lock+maxVal);
            if(SL<TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
         }
         else if(type==OP_SELL && TP_Level<OP && tick.bid<trigger_sell) {
            TriggerSL = tick.ask+(dis_lock+maxVal);
            if(SL>TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
         }
      }
   }
}

void CFeatures::ProtectingTargetScalp(int magic, int lock = 10) {
   if(Count.OrderAll(magic)>0) {
      int type = Property.type(magic);
      double SL = Property.stopLoss(magic);
      double TriggerSL;
      double dis_lock = NumToPoint(lock)+Market_StopFreeze;

      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(type==OP_BUY) {
         TriggerSL = tick.bid-dis_lock;
         if(SL<TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
      }
      else if(type==OP_SELL) {
         TriggerSL = tick.ask+dis_lock;
         if(SL>TriggerSL||SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
      }
   }
}
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

int CProp::ticket(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(selectMagic(order,magic)) type = OrderTicket();
   }
   return type;
}

double CProp::stopLoss(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) ChkLevel = OrderStopLoss();  
   }
   return ChkLevel;
}

string CProp::symbol(int magic){
   string x = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) x = OrderSymbol();  
   }
   return x;
}

double CProp::openPrice(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) ChkLevel = OrderOpenPrice();  
   }
   return ChkLevel;
}

double CProp::orderLot(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) lot = OrderLots();  
   }
   return lot;
}

double CProp::currentOrderLot(int direction) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order) && OrderType()==direction) x += OrderLots();  
   }
   return x;
}

datetime CProp::openTime(int magic){
   datetime time = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) time = OrderOpenTime();  
   }
   return time;
}

int CProp::type(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) type = OrderType();
   }
   return type;
}

double CProp::takeProfit(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) ChkLevel = OrderTakeProfit();  
   }
   return ChkLevel;
}

string CProp::comment(int magic){
   string comment = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagic(order,magic)) comment = OrderComment();  
   }
   return comment;
}

bool CProp::justClose(int magic, int minutesAgo = 1){
   bool x = false;
   datetime time = 0;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*PeriodSeconds(PERIOD_M1));
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(selectMagicTrade(order,magic,MODE_HISTORY) && selectThisEA() && OrderCloseTime()>HistoryRange && OrderCloseTime()>time) x = true;
   }
   return x;
}

void CProp::lastClosedOrder(int& type, int& ticket, double& lot, double& openPrice, double& closePrice, double& profit, double& nettPnl) {
   lot = 0;
   ticket = 0;
   type = 100;
   openPrice = 0;
   closePrice = 0;
   profit = 0;
   nettPnl = 0;
   datetime time = 0;
   datetime HistoryRange = TimeCurrent()-(10*PeriodSeconds(PERIOD_D1));
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(selectSymbolTrade(order,MODE_HISTORY) && selectThisEA() && OrderCloseTime()>HistoryRange && OrderCloseTime()>time) {
         ticket = OrderTicket();
         lot = OrderLots();
         type = OrderType();
         openPrice = OrderOpenPrice();
         closePrice = OrderClosePrice();
         profit = OrderProfit();
         nettPnl = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
}

void CProp::newestOrder(int& type, double& lot, double& price, double& profit, double& nettPnl) {
   lot = 0;
   type = 100;
   price = 0;
   profit = 0;
   nettPnl = 0;
   datetime time = 0;
   for(int order = 0; order <= OrdersTotal()-1; order++) {
      if(selectSymbolTrade(order) && selectThisEA() && OrderOpenTime()>time) {
         lot = OrderLots();
         type = OrderType();
         price = OrderOpenPrice();
         profit = OrderProfit();
         nettPnl = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double CGeneral::TotalLotSymbol(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order)) lot += OrderLots();
   }
   return lot;
}

double CGeneral::HighestOrderLot(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order) && selectThisEA() && OrderLots()>lot) lot = OrderLots();
   }
   return lot;
}

double CGeneral::Sell_LowestSL(){
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double sl = tick.ask+NumToPoint(1000*Acc_Pips);
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order) && selectThisEA() && OrderType()==OP_SELL && OrderStopLoss()>0 && OrderStopLoss()<sl) sl = OrderStopLoss();
   }
   if(sl==tick.ask+NumToPoint(1000*Acc_Pips)) return 0;
   else return sl;
}

double CGeneral::Buy_HighestSL(){
   double sl = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order) && selectThisEA() && OrderType()==OP_BUY && OrderStopLoss()>0 && OrderStopLoss()>sl)  sl = OrderStopLoss();
   }
   return sl;
}

double CGeneral::HighestOrderPrice() {
   double price[];
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(selectSymbol(order) && selectThisEA()) {
         ArrayResize(price,ArraySize(price)+1,0);
         price[ArraySize(price)-1] = OrderOpenPrice();
      }
   }
   if(ArraySize(price)==0) return 0;
   int index = ArrayMaximum(price,0,WHOLE_ARRAY);
   return(price[index]);
}

double CGeneral::LowestOrderPrice() {
   double price[];
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(selectSymbol(order) && selectThisEA()) {
         ArrayResize(price,ArraySize(price)+1,0);
         price[ArraySize(price)-1] = OrderOpenPrice();
      }
   }
   if(ArraySize(price)==0) return 0;
   int index = ArrayMinimum(price,0,WHOLE_ARRAY);
   return(price[index]);
}

int CGeneral::OrderCommissionChk() {
   int x = 4; // Equivalent $20 per 1million trade / direction ~ 
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      if(selectSymbolTrade(order,MODE_HISTORY) && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

double CGeneral::dirOrderLot(int direction) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbolTrade(order) && selectThisEA() && OrderType()==direction) x += OrderLots(); 
   }
   return x;
}

double CGeneral::averagePrice() {
   double x = 0;
   double total = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbolTrade(order) && selectThisEA()) x += OrderOpenPrice()*OrderLots();
   }
   
   double totallot = dirOrderLot(OP_BUY)+dirOrderLot(OP_SELL);
   if(totallot>0) total = x/totallot;
   return NormPrice(total);
}

int CGeneral::avgDailyRange(int range = 30, int startbar = 0){
   double sum = 0;
   int count = 0;
   int div = 1;
   double hi = 0;
   double lo = 0;
   datetime dt = 0;
      
   for (int i=range+startbar; i>startbar; i--){
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied = CopyRates(_Symbol,PERIOD_D1,i,2,rates);
      if(copied>0) {
         hi = rates[0].high;
         lo = rates[0].low;
         dt = rates[0].time;
      }
      if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6) {
         sum += hi-lo;
         count++;
      }
   }
   if(count==0) div = 1;
   else div = count;
   
   return int((sum/div)/_Point);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
double CReport::Closed_Daily(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(2*PeriodSeconds(PERIOD_D1));
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(selectTradeHistory(order,HistoryRange) && TimeDay(OrderCloseTime())==Day())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::Closed_Monthly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(32*PeriodSeconds(PERIOD_D1));
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(selectTradeHistory(order,HistoryRange) && TimeMonth(OrderCloseTime())==Month())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::Closed_Weekly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(8*PeriodSeconds(PERIOD_D1));
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(selectTradeHistory(order,HistoryRange) && ChkWeek(OrderCloseTime())==StdWeek())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::TradePL(int magic){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectMagicTrade(order,magic)) PnL += OrderProfit()+OrderCommission()+OrderSwap(); 
   }
   return NormDollar(PnL);
}

double CReport::FloatingStatusAll(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && (OrderType()==OP_BUY || OrderType()==OP_SELL))
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::TradeHistoryPL(int magic, int dayHistory = 30){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(dayHistory*PeriodSeconds(PERIOD_D1));
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(selectMagicTrade(order,magic,MODE_HISTORY) && TimeDay(OrderCloseTime())==Day() && OrderCloseTime()>HistoryRange) 
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

// -----------------------
ENUM_TIMEFRAMES TFMigrate(int tf){
   switch(tf){
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      
      default: return(PERIOD_CURRENT);
   }
}

void ChartSetting(bool setcolor = true){
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(0,CHART_SCALE,4);
   ChartSetInteger(0,CHART_AUTOSCROLL,0,true);
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,0,false);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,true);
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
   string text = "";
   switch(reasonCode){      
      case REASON_PROGRAM:       text = __FILE__+" was terminated by ExpertRemove() at "+TimeToString(TimeCurrent(),TIME_MINUTES); break;
      case REASON_REMOVE:        text = __FILE__+" was removed from chart at "+TimeToString(TimeCurrent(),TIME_MINUTES); break;
      case REASON_CLOSE:         text = "Terminal was closed at "+TimeToString(TimeCurrent(),TIME_MINUTES); break;
   }
   if(NotiEnable && text!="") SendNotification(text);
}

bool InitFailed() {
   string login = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   string type = " (Real)";
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO) type = " (Demo)";
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Alert("Please enable Automated Trading in the terminal settings!");
      return false;
   }
   else if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Alert("Automated trading is forbidden in the program settings for ",__FILE__);
      return false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
      Alert("Automated trading is forbidden for the account ",login,type," at the trade server side");
      return false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Alert("Trading is forbidden for the account ",login,type,
      ".\nPerhaps an investor password has been used to connect to the trading account.",
      "\nCheck the terminal journal for the following entry:",
      "\n\'",login,"\': trading has been disabled - investor mode.");
      return false;
   }
   return true;
}

void AllowTrading() {
   if (!InitFailed()) ExpertRemove();
}

void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
}

void ObjectDrawDelete(string objIdentifier, string name) {
   ObjectDelete(0,objIdentifier+name);
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

bool SynchonizedChart(string other_symbol) {
   static datetime last_bar_time = 0; 
   static bool synchonized = false; 
   if(last_bar_time==0) { 
      last_bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE); 
      printf("The last_bar_time variable is initialized with value %s",TimeToString(last_bar_time)); 
   }  
   datetime curr_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE); 
   if(curr_time!=last_bar_time) { 
      last_bar_time=curr_time; 
      synchonized = false; 
      printf("A new bar has appeared on symbol %s at %s",_Symbol,TimeToString(TimeCurrent())); 
   }
   datetime other_time; 
   while(!(curr_time==(other_time=(datetime)SeriesInfoInteger(other_symbol,_Period,SERIES_LASTBAR_DATE)) && !synchonized)) { 
      printf("Waiting 5 seconds.."); 
      Sleep(5000); 
   } 
   synchonized = true; 
   printf("Open bar time of the chart symbol %s: is %s",_Symbol,TimeToString(last_bar_time)); 
   printf("Open bar time of the symbol %s: is %s",other_symbol,TimeToString(other_time)); 
   Print("The bars are synchronized at ",TimeToString(TimeCurrent(),TIME_SECONDS)); 
   return synchonized;
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

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

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

int TickCount(ENUM_TIMEFRAMES timeframe) {
   static int TickCount = 0;
   static datetime BarTime = 0; 
   datetime timechk = iTime(_Symbol,timeframe,0);
   
   if(timechk!=BarTime) { 
      TickCount = 0; 
      BarTime = timechk;
   } else TickCount++;
   return TickCount;
}

bool FirstTick(ENUM_TIMEFRAMES timeframe) {
   return TickCount(timeframe)==1;
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

datetime ExactTime(int pYear = 0, int pMonth = 0, int pDay = 0, int pHour = 0, int pMinute = 0, int pSec = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.year   = pYear;    // Year
   timeStruct.mon    = pMonth;   // Month
   timeStruct.day    = pDay;     // Day
   timeStruct.hour   = pHour;    // Hour
   timeStruct.min    = pMinute;  // Minutes
   timeStruct.sec    = pSec;     // Sec
   return StructToTime(timeStruct);
}

int DST_ShiftTime(){
   // https://www.timeanddate.com/time/change/usa?
   int x = 0;
   if(BetweenTimeRange(ServerDate(2018,11,4),ServerDate(2019,3,10))) x = -1;
   else if(BetweenTimeRange(ServerDate(2019,11,3),ServerDate(2020,3,8))) x = -1;
   else if(BetweenTimeRange(ServerDate(2020,11,1),ServerDate(2021,3,14))) x = -1;
   else if(BetweenTimeRange(ServerDate(2021,11,7),ServerDate(2022,3,13))) x = -1;
   else if(BetweenTimeRange(ServerDate(2022,11,6),ServerDate(2023,3,12))) x = -1;
   else if(BetweenTimeRange(ServerDate(2023,11,5),ServerDate(2024,3,10))) x = -1;
   else if(BetweenTimeRange(ServerDate(2024,11,3),ServerDate(2025,3,9))) x = -1;
   return x;
}

bool BetweenTimeRange(datetime timeStart, datetime timeEnd) {
   datetime compare = TimeCurrent();
   return compare>=timeStart && compare<timeEnd;
}

bool TradeTiming(int pStartH, int pStartM, int pEndH, int pEndM) {
   datetime time1 = HourMin(pStartH,pStartM);
   datetime time2 = HourMin(pEndH,pEndM);
   return BetweenTimeRange(time1,time2);
}

void ProductExpired(bool use, string owner, int year, int month, int day) {
   string msg = "";
   if(use && TimeCurrent()>=ServerDate(year,month,day)){
      msg = StringConcatenate(__FILE__," was expired, please contact ",owner);
      Alert(msg);
      ExpertRemove();
   }
}

string timeIdentifier() {
   return TimeToString(iTime(_Symbol,PERIOD_M1,0),TIME_DATE|TIME_MINUTES);
}

string TimeStamp() {
   MqlDateTime tm;
   TimeToStruct(iTime(_Symbol,PERIOD_M1,0),tm);
   return StringFormat("%4d%02d%02d%02d%02d",tm.year,tm.mon,tm.day,tm.hour,tm.min);
}

string TimeStampDate() {
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(),tm);
   return StringFormat("%02d-%02d-%4d",tm.day,tm.mon,tm.year);
}

string DirectoryMonthYear() {
   string x = "";
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(),tm);
   switch(tm.mon){      
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
   return x+"-"+string(tm.year);
}

void ScreenShot(string directory = "TradeScreenshot") {
   if(!MQLInfoInteger(MQL_TESTER)) {
      string filetype = ".gif";
      int width = int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));   // Chart's width
      int heigh = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear()+"/"+Market_Symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string pairscreen = Market_Symbol+"_"+ChartTimeframe()+"_"+TimeStamp()+filetype;
      string ScreenShotName = FolderDirectory+pairscreen;
   
      //Making ScreenShot
      if(!WindowScreenShot(ScreenShotName,width,heigh)) Alert(ErrorDescription(GetLastError()));
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}

void SendMailFunction(string subject, string text) {
   if(TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) {
      bool send = SendMail(subject,text); 
      if(!send) Alert("Error sending email");
   }
}

void DebugNode(string text) {
   if(Tester_Debug) Print("-----> Debug Node: "+text+" evaluated.");
}

void DebugSignal(int signal) {
   string sig = Trade.SignalComment(signal);
   if(signal<=5 && Tester_Debug) Print("-----> Signal: "+sig);
}

void DebugBool(string name, bool check) {
   string x = "True";
   if(!check) x = "False";
   if(Tester_Debug) Print("-----> "+name+": ",x);
}

void DebugValue(string text, int value, string unit) {
   if(Tester_Debug) Print("-----> "+text+": "+IntegerToString(value)+" "+unit);
}

void DebugValue(string text, double value, string unit, int precision = 8) {
   if(Tester_Debug) Print("-----> "+text+": "+DoubleToString(value,precision)+" "+unit);
}

bool multiple_closeby(const string symbol=NULL, const int magic=NULL) {
   for(int i=OrdersTotal()-1; i>0; --i){
      if(OrderSelect(i, SELECT_BY_POS) && OrderType() < 2 && (symbol == NULL || OrderSymbol() == symbol) && (magic == NULL  || OrderMagicNumber() == magic)) {
         int    first_ticket = OrderTicket();
         string first_symbol = OrderSymbol();
         int    first_type   = OrderType();
         for(int j=i-1; j>=0; --j){
            if(OrderSelect(j, SELECT_BY_POS) && OrderType() < 2 && (magic == NULL || OrderMagicNumber() == magic) && OrderSymbol() == first_symbol && OrderType()!= first_type) {
               if(OrderCloseBy(first_ticket, OrderTicket(),clrRed)) return multiple_closeby(symbol, magic);
               else return false;
            }
         }
         break;
      }
   }
   return true;
}