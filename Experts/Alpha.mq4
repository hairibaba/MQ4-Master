//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's Email     : zulhairibaba@gmail.com                                       |
//|   Coder's MQL site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's Location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release Date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "hairibaba © 2012-2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "XXXX"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3
#define RETRY_SECONDS      2
#define IDENTIFIER_TRADE   565455

class CCount {
   public:
      int OrderAllTerminal();
      int OrderAll(int magic);
      int ThisEACount();
}Count;

class CTrade {
   private:
      void ServerCheck();
      bool SessionTrade();
      int Identifier(int identifier);
      int getID();
      int generateID(int x);
      void OrderSendError(string ordertype);
      void ModifyError(int ticket);
      void OrderCloseError(int ticket, string action);
      void NotifySetting(string msg);
      bool ServerError(int pErrorCode);
      bool OrderExist(int magic);
      bool NewOrderChk(string orderType, int type, double lot, string& retMsg);
      void OpenOrder(int type, int magic, double lot, string comment);
   public: 
      string SignalDirection(int sig);  
      bool FirstCheck();
      void AssignMagic(int identifier);
      void OpenBuy(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenSell(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void CloseOrder(int magic);
      void ModifyStopLoss(int magic, double stopPrice);
      void ModifyTakeProfit(int magic, double takePrice);
      void ModifySL_Point(int magic, int stopPoint);
      void ModifyTP_Point(int magic, int takePoint);
}Trade;

class CPool {
   public:
      bool SymbolAll(int i, int mode = MODE_TRADES);
      bool SymbolTrade(int i, int mode = MODE_TRADES);
      bool Magic(int i, int magic, int mode = MODE_TRADES);
      bool MagicTrade(int i, int magic, int mode = MODE_TRADES);
      bool ThisEA();
}Select;

class CMoney {
   public:
      double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0);
      double LotManagement(bool pRiskManagement, double risk, int stop = 150, double CommPerStdLot = 0);
      double getReferencePrice();
}Money;

class CFeatures {
   private:
      bool HiddenTP_Trail(int magic, int takePoint);
   public:
      void HiddenSL(int magic, int stopPoint);
      void HiddenTP(int magic, int takePoint);
      void HiddenSLTP(int magic, int stopPoint, int takePoint, bool trail = false);
      void BreakEven(int magic, int distance, int lock = 10);
      void ProtectingTargetScalp(int magic, int lock = 10);
}Features;

class CGeneral {

   public:
      int OrderCommissionChk();
      double TotalLotSymbol();
      int avgDailyRange(int range = 30, int startbar = 0);
}General;

class CProp {
   public:
      int type(int magic);
      double stopLoss(int magic);
      double takeProfit(int magic);
      datetime openTime(int magic);
      double openPrice(int magic);
      double orderLot(int magic);
}Property;

// --- Input Variable ------------------------------------------------------------------
input bool        ActivateEA        = true,
                  UseRiskManagement = true;
input double      RiskPerTrade      = 2.0;

// --- Standard Global Variable ---------------------------------------------------------
static int  s_id = 0;
     string Acc_Broker,Acc_Currency,Market_Symbol,Acc_DrawdownText,
            SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
            Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_MarginUsed,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_VolumeLimit,Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel,Market_StopFreeze;

// --- System Global Variable -----------------------------------------------------------        
string      ObjIdentifier  = "EAX_";
int         Magic1;
static int  hiddenSL = 0,
            hiddenTP = 0;

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
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
   msString("Expert initilized",ul_res);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   s_id = 0;
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(getUninitReasonText(_UninitReason));
   reportReason(_UninitReason);
}

void OnTick(){
   AllowTrading();
   ChartHistory();
   AccountParameter_Var();
      
   if(Trade.FirstCheck()) {
      if(Count.OrderAll(Magic1)==0) FirstOrder();
      else if(Count.OrderAll(Magic1)>0) {
         if(TimeCurrent()>Property.openTime(Magic1)+PeriodSeconds(PERIOD_H1)) {
            double op = Property.openPrice(Magic1);
            double stop = NumToPoint(50);
            int dir = Property.type(Magic1);

            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            
            if((dir==OP_BUY && tick.ask<op-stop) || (dir==OP_SELL && tick.bid>op+stop)) Trade.CloseOrder(Magic1);
            else Features.BreakEven(Magic1,usedTP()-100);
         }
         if(hiddenTP!=usedTP()) hiddenTP = usedTP();
         Features.HiddenSLTP(Magic1,hiddenSL,hiddenTP,true);
      }
   }
   
   int prevRange,lastRange;
   double prevOpen,prevClose,lastOpen,lastClose;
   int previous   = OHLC(PERIOD_M5,2,30,prevOpen,prevClose,prevRange);
   int last       = OHLC(PERIOD_M5,1,40,lastOpen,lastClose,lastRange);
   
   Comment(
      "\n\n Prev Signal : ",Trade.SignalDirection(previous),". Range : ",prevRange,
      "\n\n Last Signal : ",Trade.SignalDirection(last),". Range : ",lastRange,
      "\n\n Engulfing : ",Trade.SignalDirection(Engulfing(PERIOD_M5))
   );
}

void FirstOrder() {
   if(ActivateEA && TradeTimingMinutes(5,6) && TradeTiming(2,0,22,10) && MarginLevelProcced(300)) {
      int Signal = Engulfing(PERIOD_M5);
      if(Signal<2) {
         int risk = 100;
         if(Signal==OP_SELL) risk += MAXSPREAD;
         hiddenSL = risk;
         double UseLot = Money.LotManagement(UseRiskManagement,RiskPerTrade,risk);
         
         if(Signal==OP_BUY) Trade.OpenBuy(Magic1,UseLot,Market_Symbol);
         else if(Signal==OP_SELL) Trade.OpenSell(Magic1,UseLot,Market_Symbol);
      }
   }
}

int usedTP() {
   int range = fmin(General.avgDailyRange(),LWAvg());
   return int(range/4);
}

int OHLC(ENUM_TIMEFRAMES timeframe, int shift, int limitRange, double& open, double& close, int& range) {
   open        = iOpen(_Symbol,timeframe,shift);
   close       = iClose(_Symbol,timeframe,shift);
   range       = PointToInt(fabs(open-close));
   int x       = 100;
   
   if(range>=limitRange) {
      if(close>open)       x = OP_BUY;    // Bullish
      else if(close<open)  x = OP_SELL;   // Bearish
   }
   return x;
}

int Engulfing(ENUM_TIMEFRAMES timeframe)  {
   int prevRange,lastRange;
   double prevOpen,prevClose,lastOpen,lastClose;
   int previous   = OHLC(PERIOD_M5,2,30,prevOpen,prevClose,prevRange);
   int last       = OHLC(PERIOD_M5,1,40,lastOpen,lastClose,lastRange);
   int x          = 100;
   
   if(previous==OP_SELL && last==OP_BUY && lastClose>prevOpen) x = OP_BUY;
   else if(previous==OP_BUY && last==OP_SELL && lastClose<prevOpen) x = OP_SELL;
   
   return x;
}

int TradeStop(int signal, double& x) {
   double y = 0;
   int risk = 0;
   double buffer = NumToPoint(50);
   
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
      
   if(signal==OP_BUY) {
      int shiftLowest   = iLowest(_Symbol,PERIOD_H1,MODE_LOW,2,1);
      double pricelow   = iLow(_Symbol,PERIOD_H1,shiftLowest);
      double prevLow    = iLow(_Symbol,PERIOD_M5,2);
      double lastLow    = iLow(_Symbol,PERIOD_M5,1);
      double lowerStop  = fmin(prevLow,lastLow);
      
      y = lowerStop-buffer;
      if(y<pricelow) x = y;
      else x = pricelow;
      risk = PointToInt(tick.bid-x);
   }
   else if(signal==OP_SELL) {
      int shiftHighest  = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,2,1);
      double pricehigh  = iHigh(_Symbol,PERIOD_H1,shiftHighest);
      double prevHigh   = iHigh(_Symbol,PERIOD_M5,2);
      double lastHigh   = iHigh(_Symbol,PERIOD_M5,1);
      double upperStop  = fmax(prevHigh,lastHigh);
      
      y = upperStop+buffer+NumToPoint(Market_Spread);
      if(y>pricehigh) x = y;
      else x = pricehigh;
      risk = PointToInt(x-tick.ask);
   }
   return risk;
}

int TradeStop_Rev(int signal, double& x) {
   int risk = 0;   
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
      
   if(signal==OP_BUY) {
      double prevLow    = iLow(_Symbol,PERIOD_M5,2);
      double lastLow    = iLow(_Symbol,PERIOD_M5,1);
      double lowerStop  = fmin(prevLow,lastLow);
      x = lowerStop;
      risk = PointToInt(tick.bid-x);
   }
   else if(signal==OP_SELL) {
      double prevHigh   = iHigh(_Symbol,PERIOD_M5,2);
      double lastHigh   = iHigh(_Symbol,PERIOD_M5,1);
      double upperStop  = fmax(prevHigh,lastHigh);
      x = upperStop+NumToPoint(MAXSPREAD);
      risk = PointToInt(x-tick.ask);
   }
   return risk;
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

double ZeroDivided(double value) {
   double tempVal = 1.0;
   if(value!=0) tempVal = value;
   return tempVal;
}

bool CPool::SymbolAll(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

bool CPool::SymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

bool CPool::Magic(int i, int magic, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic);
}

bool CPool::MagicTrade(int i, int magic, int mode = MODE_TRADES){
   return (
   OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic 
   && (OrderType()==OP_BUY || OrderType()==OP_SELL)
   );
}

bool CPool::ThisEA() {
   return (OrderMagicNumber()==Magic1);
}
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

void SleepSeconds(int seconds) {
   Sleep(seconds*1000);
   RefreshRates();
}

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double x = dbl*_Point;
   string y = DoubleToString(Round(x,_Point),_Digits); 
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
   return Round(price,ticksize);
}

double NormLot(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(lot>minLot) {
      if(lot>maxLot) return maxLot;
      else return RoundDn(lot,lotStep);
   }
   else return minLot;
}

double VerifyLotMinMax(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(lot>maxLot) return maxLot;
   else if(lot<minLot) return minLot;
   else return Round(lot,lotStep);
}

string SymbolTimeframe() {
   return StringConcatenate(Market_Symbol+" ("+ChartTimeframe()+")");
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool MarginLevelProcced(int margin){
   int marginLvl = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   return marginLvl==0 || marginLvl>=margin;
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

void msString(string msg, long res) {
   if(LiveOperation()) printf("%s in %s ms.",msg,StringMs(res));
}

void msString(string msg, long res, int ticket) {
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE)) printf("Order #%d %s.",ticket,msg);
   else printf("Order ticket %d %s in %s ms.",ticket,msg,StringMs(res));
}

string StringLot(double lot) {
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   int x = 0;
   if(step==0.01) x = 2;
   else if(step==0.1) x = 1;
   return DoubleToString(lot,x);
}

double NormDollar(double dollarValue) {
   return Round(dollarValue,0.01);
}

double RoundUp(double value, double rounding) {
   return ceil(value/rounding)*rounding;
}

double RoundDn(double value, double rounding) {
   return floor(value/rounding)*rounding;
}

double Round(double value, double rounding) {
   return round(value/rounding)*rounding;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double CMoney::MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0) {
   int margin              = spread*2;
   double marginRequired   = 0, 
          CommissionCost   = 0,
          referencePrice   = getReferencePrice();
   
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
   return RoundUp(raw,0.01);
}

double CMoney::getReferencePrice() {
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
      bool have_prefix = SymbolCurrPrefix!="";
      bool have_suffix = SymbolCurrSuffix!="";
      
      refSym = SymbolCurr1+Acc_Currency;
      string ThisSym1 = refSym;
      string ThisSymX_1 = refSym;
      refSym2 = Acc_Currency+SymbolCurr1;
      string ThisSym2 = refSym2;
      string ThisSymX_2 = refSym2;

      if(have_prefix && have_suffix) {
         ThisSym1 = SymbolCurrPrefix+ThisSymX_1+SymbolCurrSuffix;
         ThisSym2 = SymbolCurrPrefix+ThisSymX_2+SymbolCurrSuffix;
      }
      else if(have_prefix) {
         ThisSym1 = SymbolCurrPrefix+ThisSymX_1;
         ThisSym2 = SymbolCurrPrefix+ThisSymX_2;
      }
      else if(have_suffix) {
         ThisSym1 = ThisSymX_1+SymbolCurrSuffix;
         ThisSym2 = ThisSymX_2+SymbolCurrSuffix;
      }
      
      // if deposit in USD
      if(Acc_Currency=="USD"){
         if(refSym=="EURUSD" || refSym=="GBPUSD" || refSym=="AUDUSD" || refSym=="NZDUSD" || refSym=="XAUUSD" || refSym=="XAGUSD" || 
         refSym=="BTCUSD" || refSym=="ETHUSD" || refSym=="XRPUSD") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1/ZeroDivided(SymbolInfoDouble(ThisSym2,SYMBOL_ASK));
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
   double RefPrice               = getReferencePrice(),
          LotSize                = Market_MinLot,
          CommissionCost         = 0,
          CommPerStdLotRoundTurn = fmax(CommPerStdLot,General.OrderCommissionChk());
   
   if(!pRiskManagement) LotSize = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   else if(risk>0 && stop>0) {
      if(risk>MAXRISK) risk = MAXRISK; // Limit the max risk to 10%
      // Delta per lot
      double deltaLot = ZeroDivided(Market_TickValue/double(Market_TickSize));
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

int CCount::ThisEACount(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order) && Select.ThisEA()) count++;
   }
   return count;
}

int CCount::OrderAll(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.Magic(order,magic)) {
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

bool LiveOperation() {
   return !(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE));
}

void CTrade::ServerCheck(){
   if(LiveOperation()) {
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !SpreadFilterPair()) Sleep(1);
   }
   RefreshRates();
}

bool CTrade::FirstCheck() {
   if(LiveOperation()) return TerminalInfoInteger(TERMINAL_CONNECTED) && !IsTradeContextBusy() && SpreadFilterPair() && SessionTrade();
   else return true;
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

bool CTrade::SessionTrade() {
   if(TimeCurrent()>=HourMin(0,2) && TimeCurrent()<HourMin(23,59)) return true;
   else return false;
}

bool CTrade::OrderExist(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) {
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
      SleepSeconds(30); // Pause 30 seconds
      return;
   }
   else {
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
      ServerCheck(); // Updating Latest Tick Data
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      double price = tick.bid;
      color arrow  = clrRed;
      if(type==OP_BUY) {price = tick.ask;arrow = clrGreen;}
      int ticket = OrderSend(_Symbol,type,lot,price,Acc_Slippage,0,0,comment,magic,0,arrow);
      if(ticket == -1) OrderSendError("Market");
      else {
         ul_res = GetMicrosecondCount()-ul;
         msString("Market order execute",ul_res);
         ScreenShot("Scalping");
      }
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

void CTrade::CloseOrder(int magic){
   if(OrderExist(magic)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
                  closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     msString("closed",ul_res,OrderTicket());
                     break;
                  }
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        SleepSeconds(RETRY_SECONDS);
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

void CTrade::ModifyStopLoss(int magic, double pPriceSL) { 
   if(OrderExist(magic) && pPriceSL>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.Magic(order,magic)) {
            double NormSL = NormPrice(pPriceSL);
            if(AcceptableDifference(OrderStopLoss(),NormSL) && StopLevel(NormSL)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),NormSL,OrderTakeProfit(),0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        SleepSeconds(RETRY_SECONDS);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify && OrderExist(magic)) ModifyError(OrderTicket());
            }
         }
      }
   }
}

void CTrade::ModifyTakeProfit(int magic, double pPriceTP) { 
   if(OrderExist(magic) && pPriceTP>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.Magic(order,magic)) {
            double NormTP = NormPrice(pPriceTP);
            if(AcceptableDifference(OrderTakeProfit(),NormTP) && StopLevel(NormTP)){
               int retry = 0;
               bool modify = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormTP,0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        SleepSeconds(RETRY_SECONDS);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify && OrderExist(magic)) ModifyError(OrderTicket());
            } 
         }
      }
   }
}

void CTrade::ModifySL_Point(int magic, int stopPoint) { 
   if(OrderExist(magic) && stopPoint>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.Magic(order,magic)) {
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
                  ServerCheck();
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),pPriceSL,OrderTakeProfit(),0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        SleepSeconds(RETRY_SECONDS);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!modify && OrderExist(magic)) ModifyError(OrderTicket());
            }
         }
      }
   }
}

void CTrade::ModifyTP_Point(int magic, int takePoint) { 
   if(OrderExist(magic) && takePoint>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.Magic(order,magic)) {
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
                  ServerCheck();
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),pPriceTP,0);
                  if(modify) break;
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        SleepSeconds(RETRY_SECONDS);
                     }
                     else break;
                  }
               }
               if(!modify && OrderExist(magic)) ModifyError(OrderTicket());
            }
         }
      }
   }
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

int CTrade::Identifier(int identifier) {
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
   else if(sym=="XBNUSD") x = 41;
   else if(sym=="BTCUSD" || sym == "BTC" || sym == "Bitcoin" || sym == "BITCOIN" || sym == "BTC/USD") x = 42;   // Bitcoin
   else if(sym=="LTCUSD" || sym == "LTC" || sym == "LiteCoin" || sym == "LITECOIN") x = 43;   // LTC
   else if(sym=="ETHUSD" || sym == "ETH" || sym == "Ethereum" || sym == "ETHEREUM") x = 44;   // Ethrium
   else if(sym=="XRPUSD" || sym == "XRP") x = 45;   // XRP
   else if(sym=="BCHUSD" || sym == "BCH") x = 46;   // BCH
   else if(sym=="DCHUSD" || sym == "DCH") x = 47;   // DCH
   else if(sym=="DSHUSD" || sym == "DASH")   x = 48;
   else if(sym=="XAUUSD" || sym == "GOLD" || sym == "GLD" || sym == "GD" || sym == "GC") x = 49;   // Gold
   else if(sym=="XAGUSD" || sym == "SILVER" || sym == "SI" || sym == "SV") x = 50;   // Silver
   else if(sym=="BRENT" || sym=="BRN" || sym == "BR" || sym == "BTC" || sym == "BCOUSD" || sym == "USDBRO" || sym=="XBRUSD")  x = 51;   // BRENT
   else if(sym=="WTI" || sym == "USWTI" || sym == "USOIL" || sym == "CRUD" || sym == "XTIUSD")    x = 52;   // WTI
   else if(sym=="Palladium" || sym == "PALLADIUM")  x = 53;
   else if(sym=="Platinum" || sym == "PLATINUM")   x = 54;
   else if(sym=="DAX30" || sym=="DE30")   x = 55;
   else if(sym=="FTSE100")    x = 56;
   else if(sym=="IBEX35")     x = 57;
   else if(sym=="US30")       x = 58;
   else if(sym=="US2000")     x = 59;
   else if(sym=="HK50")       x = 60;
   else if(sym=="ITALY40")    x = 61;
   else if(sym=="UK100")      x = 62;
   else if(sym=="USTEC")      x = 63;
   else if(sym=="AUS200")     x = 64;
   else if(sym=="NIKK225" || sym=="JP225")   x = 65;
   else if(sym=="SPX500" || sym=="US500")    x = 66;
   else if(sym=="FRANCE40" || sym=="F40")    x = 67;

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
   Magic1      = generateID(ref);
   DebugPrint("Magic1 = "+IntegerToString(Magic1));
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
   SendNotificationFunction(acc);
   ResetLastError();
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

void CFeatures::HiddenSL(int magic, int stopPoint){
   bool     ChkCondition   = false;
   double   bufferSL       = NumToPoint(stopPoint);
   double   stopLoss;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.MagicTrade(order,magic) && stopPoint>0) {
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
         if(Select.MagicTrade(order,magic) && takePoint>0) {
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
         if(Select.MagicTrade(order,magic) && takePoint>0) {
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

void CFeatures::BreakEven(int magic, int distance, int lock = 10){
   if(Count.OrderAll(magic)>0 && distance>lock && lock>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {         
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

double CProp::stopLoss(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) ChkLevel = OrderStopLoss();  
   }
   return ChkLevel;
}

double CProp::openPrice(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) ChkLevel = OrderOpenPrice();  
   }
   return ChkLevel;
}

double CProp::orderLot(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) lot = OrderLots();  
   }
   return lot;
}

datetime CProp::openTime(int magic){
   datetime time = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) time = OrderOpenTime();  
   }
   return time;
}

int CProp::type(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) type = OrderType();
   }
   return type;
}

double CProp::takeProfit(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) ChkLevel = OrderTakeProfit();  
   }
   return ChkLevel;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
double CGeneral::TotalLotSymbol(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order)) lot += OrderLots();
   }
   return lot;
}

int CGeneral::OrderCommissionChk() {
   int x = 4; // Equivalent $20 per 1million trade / direction ~ 
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      if(Select.SymbolTrade(order,MODE_HISTORY) && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
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

int LWAvg() {
   int count = 0;
   double sum = 0;
   double lwav = 0;
   double total = 0;
   datetime dt = 0;
   double hi = 0;
   double lo = 0;
   for(int i=30; i>0; i--){
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied = CopyRates(_Symbol,PERIOD_D1,i,2,rates);
      if(copied>0) dt = rates[0].time;
      if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6) count++;
   }
   
   total = count+count*(count-1)/2.0;
   
   for(int z=30; z>0; z--){
      MqlRates ratesX[];
      ArraySetAsSeries(ratesX,true);
      int copied = CopyRates(_Symbol,PERIOD_D1,z,2,ratesX);
      if(copied>0) {
         hi = ratesX[0].high;
         lo = ratesX[0].low;
      }
      if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6) {
         sum += (hi-lo)*count;
         count--;
      }
   }
   
   lwav = sum/total;
   return int(lwav/_Point);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
void ChartSetting(bool setcolor = true){
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(0,CHART_SCALE,5);
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
   int Login = int(AccountInfoInteger(ACCOUNT_LOGIN));
   string stringlogin = IntegerToString(Login);
   string text = "";
   string ServerTime = TimeToString(TimeCurrent(),TIME_MINUTES);
   if(reasonCode==REASON_PROGRAM)      text = "Acc #"+stringlogin+" "+__FILE__+" was terminated by ExpertRemove() at Server Time : "+ServerTime;
   else if(reasonCode==REASON_REMOVE)  text = "Acc #"+stringlogin+" "+__FILE__+" was removed from chart at Server Time : "+ServerTime;
   else if(reasonCode==REASON_CLOSE)   text = "Acc #"+stringlogin+" - Terminal was closed at Server Time : "+ServerTime;

   if(text!="") SendNotificationFunction(text);
}

bool InitFailed() {
   if(LiveOperation()) {
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

void ChartHistory(string symbol = NULL) {
   ENUM_PROGRAM_TYPE mql_program = (ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE); 
   
   if(mql_program == PROGRAM_EXPERT || mql_program == PROGRAM_SCRIPT) {
      if(LiveOperation()) {
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

datetime Minutes(int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
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

bool TradeTimingMinutes(int pStartM, int pEndM) {
   datetime time1 = Minutes(pStartM);
   datetime time2 = Minutes(pEndM);
   return BetweenTimeRange(time1,time2);
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
   if(LiveOperation()) {
      string filetype = ".gif";
      int width = int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));   // Chart's width
      int heigh = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear()+"/"+Market_Symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string pairscreen = Market_Symbol+"_"+ChartTimeframe()+"_"+TimeStamp()+filetype;
      string ScreenShotName = FolderDirectory+pairscreen;
   
      //Making ScreenShot
      if(!ChartScreenShot(0,ScreenShotName,width,heigh)) Alert(ErrorDescription(GetLastError()));
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}

void SendMailFunction(string subject, string text) {
   if(LiveOperation() && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) {
      bool send = SendMail(subject,text); 
      if(!send) Alert("Error sending email");
   }
}

void SendNotificationFunction(string msg) {
   if(LiveOperation() && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
}

void DebugPrint(string msg) {
   Print(__FILE__+" "+Market_Symbol+" >> "+msg+".");
}