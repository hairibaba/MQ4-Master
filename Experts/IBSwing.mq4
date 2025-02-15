//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's Email     : zulhairibaba@gmail.com                                       |
//|   Coder's MQL site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's Location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release Date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "hairibaba © 2012-2019"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "IB Swing"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3
#define RETRY_SECONDS      2
#define IDENTIFIER_TRADE   55321

class CCount {
   public:
      int OrderAllTerminal();
      int OrderAllSymbol();
      int OrderAllSymbol(int type);
      int OrderTradeSymbol(int type);
      
      int OrderAll(int magic);
      int OrderAll(int magic, int type);
      int OrderAllTrade(int magic);
      int OrderAllPending(int magic);
      
      int OrderTradeEA(int type);
      int ThisEACount();
      double ThisEALot();    
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
      void OpenPendingOrder(int type, int magic, double lot, double pPricePending, string comment, int expiredMinutes);
      
      bool MultipleCloseBy();
      bool MagicCloseBy(const int magic1, const int magic2);
      void HedgeToClose(int signal, int magic, double lot);
      void Symbol_HedgeToCloseSystem();
      void Magic_HedgeToCloseSystem(int magic, double lot = 0.0);
      
      bool CloseAll_Symbol_FIFO();
      bool CloseAll_Symbol_NonFIFO();
   public: 
      bool FirstCheck();
      string SignalComment(int sig);  
      string SignalDirection(int sig);    
      void AssignMagic(int identifier);
      void OpenBuy(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenSell(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      
      void OpenBuyLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenBuyStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenSellLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      void OpenSellStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0);
      
      bool ExpiredOrder(int magic, int bar, ENUM_TIMEFRAMES timeframe);
      void CloseAllOrder_Terminal();
      void CloseOrder(int magic);
      void CloseAllOrder_Symbol();
      void PartialClose(int magic, double lot);
      void SecureManualOrder(int magic = 0);
      void PendingOrderManagement(int magic = 0);
      
      void CloseAllOrder_Symbol_FIFO();
      void CloseAllOrder_Symbol_NonFIFO();
      
      // By hedging
      void CloseOrder_ByHedging(int magic);
      void CloseAllOrderSymbol_ByHedging();
      void PartialCloseOrder_ByHedging(int magic, double lot);
      //bool multiple_closeby_symbol();
      
      void DeletePendingOrder(int magic);
      void DeleteAllPendingOrder_Symbol();
      void DeleteAllPendingOrder_Terminal();
      void DeletePendingOrderTimer(int magic, int second);
      void ModPendingOrder(int magic, double pPending);
      void ModifyStopLoss(int magic, double stopPrice);
      void ModifyStopLossTicket(int ticket, double pPriceSL);
      void ModifyTakeProfit(int magic, double takePrice);
      void ModifySL_Point(int magic, int stopPoint);
      void ModifyTP_Point(int magic, int takePoint);
      void DeleteSLTP(int magic);
      void DeleteSLTPTrade();
}Trade;

class CPool {
   public:
      bool TerminalTrade(int i);
      bool TerminalPending(int i);
      bool SymbolAll(int i, int mode = MODE_TRADES);
      bool SymbolTrade(int i, int mode = MODE_TRADES);
      bool SymbolPending(int i, int mode = MODE_TRADES);
      bool Magic(int i, int magic, int mode = MODE_TRADES);
      bool MagicTrade(int i, int magic, int mode = MODE_TRADES);
      bool MagicPending(int i, int magic, int mode = MODE_TRADES);
      bool TradeHistory(int i, int timeframe, int period);
      bool TradeHedging(int i, int masterType);
      bool ThisEA();
}Select;

class CMoney {
   public:
      double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0);
      double FullMarginLot(double balance, int leverage, int spread, double MinMarginPercentage = 120, int divider = 1, double CommPerStdLot = 0);
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
      void HiddenSLTP(int magic, double pPriceSL, double pPriceTP);
      void BreakEven(int magic, int distance, int lock = 10);
      void BreakEvenTicket(int ticket, int distance, int lock = 10);
      void TrailingStop(int magic, int distance, int step = 10);
      void SystemTrailing(int magic, int distance = 100, int step = 10);
      void TrailingStopIndicator(int magic, double value);
      void TrailingStop_Hidden(int magic, int distance, int step = 10);
      void ProtectingTarget(int magic, double TP_Level = 0, int trigger = 20, int lock = 20);
      void ProtectingTargetScalp(int magic, int lock = 10);
}Features;

class CGeneral {
   private:
      double AllOrderAvgPrice();
      double dirLot(int type);
      double hedgeCalc(double val, double total, double avg);
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
      double MarginUsed();
      int avgDailyRange(int range = 30, int startbar = 0);
}General;

class CReport {
   public:
      double Closed_Daily();
      double Closed_Weekly();
      double Closed_Monthly();
      double FloatingStatusSymbol();
      double FloatingStatusTerminal();
      double TradePL(int magic);
      double TradeHistoryPL(int magic, int dayHistory = 30);
}Report;

class CProp {
   public:
      int type(int magic);
      double orderLot(int magic);
      double stopLoss(int magic);
      double takeProfit(int magic);
      double openPrice(int magic);
      datetime openTime(int magic);
      
      int ticket(int magic);
      string comment(int magic);
      string symbol(int magic);
      
      double orderLotHedge(int magic, int type);
      double currentOrderLot(int direction);
      bool justClose(int magic, int minutesAgo = 1);
      void lastClosedOrder(int& type, int& ticket, double& lot, double& openPrice, double& closePrice, double& profit, double& nettPnl);
      void newestOrder(int& type, double& lot, double& price, double& profit, double& nettPnl);
}Property;

// --- Input Variable ------------------------------------------------------------------
input bool        ActivateEA        = true;
input double      StartLot          = 0.02;

// --- Standard Global Variable ---------------------------------------------------------
static int  s_id = 0;
     string Acc_Broker,Acc_Currency,Acc_Type,Market_Symbol,Acc_DrawdownText,
            SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
            Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_MarginUsed,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_VolumeLimit,Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel,Market_StopFreeze;

// --- System Global Variable -----------------------------------------------------------        
string      ObjIdentifier  = "EAX_";
int         dailyFibo,
            MagicHedge,
            Magic1,Magic2,Magic3,Magic4,Magic5,Magic6,Magic7,Magic8,Magic9,Magic10,Magic11,Magic12,Magic13,Magic14,Magic15,Magic16,Magic17,Magic18,Magic19,Magic20,Magic21,Magic22,Magic23,Magic24,Magic25;
double      ib_point1,ib_point2,ib_point3,ib_point4,ib_point5,ib_point6,ib_point7,ib_point8,ib_point9,ib_slSell,ib_tpSell,ib_slBuy,ib_tpBuy,
            fib_point1,fib_point2,fib_point3,fib_point4,fib_point5,fib_point6,fib_point7,fib_point8,fib_point9,fib_slSell,fib_tpSell,fib_slBuy,fib_tpBuy;

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
   
   dailyFibo = defineDailyFibo(fib_point1,fib_point2,fib_point3,fib_point4,fib_point5,fib_point6,fib_point7,fib_point8,fib_point9,fib_slBuy,fib_tpSell,fib_slSell,fib_tpBuy);
   ManageExistingOrder();
   FirstOrder();
   SpecialSwingThursday();
   SpecialSwingMonday();
   SpecialGapMonday();
   
   Comment("\n\nDaily Fibo Swing : ",Trade.SignalComment(dailyFibo));
}

int RangePeriodSwing(int timeframe, int range, int startbar, double& pricehigh, double& pricelow){
   int shiftHighest  = iHighest(_Symbol,timeframe,MODE_HIGH,range,startbar);
   int shiftLowest   = iLowest(_Symbol,timeframe,MODE_LOW,range,startbar);
   pricehigh         = iHigh(_Symbol,timeframe,shiftHighest);
   pricelow          = iLow(_Symbol,timeframe,shiftLowest);
   
   int x = 100;
   if(shiftHighest > shiftLowest) x = OP_SELL;
   else if(shiftHighest < shiftLowest) x = OP_BUY;
   return x;
}

int defineDailyFibo(double& point1, double& point2, double& point3, double& point4, double& point5, double& point6, double& point7, double& point8, double& point9, double& stopBelow, double& takeBelow, double& stopAbove, double& takeAbove) {
   double HighX,LowX;
   double yesHigh = iHigh(_Symbol,PERIOD_D1,1);
   double yesLow  = iLow(_Symbol,PERIOD_D1,1);
   
   double range   = yesHigh-yesLow;
   double r1      = range*0.118;
   double r2      = range*0.236068;
   double r3      = range*0.381966;
   double r4      = range*0.5;
   double r5      = range*0.618034;
   double r6      = range*0.763932;
   double r7      = range*0.882;
   double r8      = range*0.272;

   point1      = yesHigh;
   point2      = NormPrice(yesLow + r7);
   point3      = NormPrice(yesLow + r6);
   point4      = NormPrice(yesLow + r5);
   point5      = NormPrice(yesLow + r4);
   point6      = NormPrice(yesLow + r3);
   point7      = NormPrice(yesLow + r2);
   point8      = NormPrice(yesLow + r1);
   point9      = yesLow;
   
   stopBelow   = NormPrice(yesLow - r1);
   takeBelow   = NormPrice(yesLow - r8);
   stopAbove   = NormPrice(yesHigh + r1);
   takeAbove   = NormPrice(yesHigh + r8);
   
   return RangePeriodSwing(PERIOD_H1,24,Hour(),HighX,LowX);
}

void defineEntryIB(ENUM_TIMEFRAMES timeframe, double& point1, double& point2, double& point3, double& point4, double& point5, double& point6, double& point7, double& point8, double& point9, double& stopBelow, double& takeBelow, double& stopAbove, double& takeAbove) {
   double yesHigh,yesLow;
   int fibDaily = RangePeriodSwing(timeframe,2,1,yesHigh,yesLow);
   
   double range   = yesHigh-yesLow;
   double r1      = range*0.118;
   double r2      = range*0.236068;
   double r3      = range*0.381966;
   double r4      = range*0.5;
   double r5      = range*0.618034;
   double r6      = range*0.763932;
   double r7      = range*0.882;
   double r8      = range*0.272;

   point1      = yesHigh;
   point2      = NormPrice(yesLow + r7);
   point3      = NormPrice(yesLow + r6);
   point4      = NormPrice(yesLow + r5);
   point5      = NormPrice(yesLow + r4);
   point6      = NormPrice(yesLow + r3);
   point7      = NormPrice(yesLow + r2);
   point8      = NormPrice(yesLow + r1);
   point9      = yesLow;
   
   stopBelow   = NormPrice(yesLow - r4);
   takeBelow   = NormPrice(yesLow - r5);
   stopAbove   = NormPrice(yesHigh + r4);
   takeAbove   = NormPrice(yesHigh + r5);
}

void defineEntrySpx(ENUM_TIMEFRAMES timeframe, double& point1, double& point2, double& point3, double& point4, double& point5, double& point6, double& point7, double& point8, double& point9, double& stopBelow, double& takeBelow, double& stopAbove, double& takeAbove) {
   double yesHigh,yesLow;
   int fibDaily = RangePeriodSwing(timeframe,2,1,yesHigh,yesLow);
   
   double range   = yesHigh-yesLow;
   double r1      = range*0.118;
   double r2      = range*0.236068;
   double r3      = range*0.381966;
   double r4      = range*0.5;
   double r5      = range*0.618034;
   double r6      = range*0.763932;
   double r7      = range*0.882;
   double r8      = range*0.272;

   point1      = yesHigh;
   point2      = NormPrice(yesLow + r7);
   point3      = NormPrice(yesLow + r6);
   point4      = NormPrice(yesLow + r5);
   point5      = NormPrice(yesLow + r4);
   point6      = NormPrice(yesLow + r3);
   point7      = NormPrice(yesLow + r2);
   point8      = NormPrice(yesLow + r1);
   point9      = yesLow;
   
   stopBelow   = NormPrice(yesLow - r1);
   takeBelow   = NormPrice(yesLow - r3);
   stopAbove   = NormPrice(yesHigh + r1);
   takeAbove   = NormPrice(yesHigh + r3);
}

int OHLC(ENUM_TIMEFRAMES timeframe, int shift, double& open, double& high, double& low, double& close) {
   int x       = 100;
   open        = iOpen(_Symbol,timeframe,shift);
   high        = iHigh(_Symbol,timeframe,shift);
   low         = iLow(_Symbol,timeframe,shift);
   close       = iClose(_Symbol,timeframe,shift);
   
   if(close>open)       x = OP_BUY;    // Bullish
   else if(close<open)  x = OP_SELL;   // Bearish
   return x;
}

void RangePriceHiLo(int timeframe, int range, int startbar, double& pricehigh, double& pricelow) {   
   int shiftHighest  = iHighest(_Symbol,timeframe,MODE_HIGH,range,startbar);
   int shiftLowest   = iLowest(_Symbol,timeframe,MODE_LOW,range,startbar);
   pricehigh         = iHigh(_Symbol,timeframe,shiftHighest);
   pricelow          = iLow(_Symbol,timeframe,shiftLowest);
}

void RangePriceOpCl(int timeframe, int range, int startbar, double& pricehigh, double& pricelow) {   
   int shiftHighest  = iHighest(_Symbol,timeframe,MODE_CLOSE,range,startbar);
   int shiftLowest   = iLowest(_Symbol,timeframe,MODE_CLOSE,range,startbar);
   pricehigh         = iClose(_Symbol,timeframe,shiftHighest);
   pricelow          = iClose(_Symbol,timeframe,shiftLowest);
}

int defineInitialBreak() {
   int x = 100;
   double lastOpen,lastHigh,lastLow,lastClose;
   double prevOpen,prevHigh,prevLow,prevClose;
   int last = OHLC(PERIOD_H1,1,lastOpen,lastHigh,lastLow,lastClose);
   int prev = OHLC(PERIOD_H1,2,prevOpen,prevHigh,prevLow,prevClose);
   
   if(SwitchSignal(last,prev)) {
      double pointhigh,pointlow,range;
      double ib_closeHigh,ib_closeLow;
      double ib_rangehigh,ib_rangelow,prev_rangehigh,prev_rangelow;
      RangePriceOpCl(PERIOD_H1,4,1,ib_closeHigh,ib_closeLow);
      RangePriceHiLo(PERIOD_H1,4,1,ib_rangehigh,ib_rangelow);
      RangePriceHiLo(PERIOD_H1,8,2,prev_rangehigh,prev_rangelow);
      
      bool IB_HH       = false,
           IB_LL       = false,
           IB_HC       = false,
           IB_LC       = false,
           IB_ExtHigh  = false,
           IB_ExtLow   = false,
           PR_HH       = false,
           PR_LL       = false;
      
      if(lastHigh==ib_rangehigh) IB_HH = true;
      if(lastLow==ib_rangelow) IB_LL = true;
      if(lastClose==ib_closeHigh) IB_HC = true;
      else if(lastClose==ib_closeLow) IB_LC = true;
      
      if(prevHigh==prev_rangehigh) PR_HH = true;
      if(prevLow==prev_rangelow) PR_LL = true;
      
      if(last==OP_BUY && prev==OP_SELL) {
         if(IB_HH && IB_HC && (IB_LL||PR_LL)) {
            pointhigh   = lastHigh;
            pointlow    = fmin(lastLow,prevLow);
            range       = pointhigh-pointlow;
            if(PointToInt(range)>=220) x = OP_BUY;
         }
      
      }
      else if(last==OP_SELL && prev==OP_BUY) {
         if(IB_LL && IB_LC && (IB_HH||PR_HH)) {
            pointhigh   = fmax(lastHigh,prevHigh);
            pointlow    = lastLow;
            range       = pointhigh-pointlow;
            if(PointToInt(range)>=220) x = OP_SELL;
         }
      }
   }
   return x;
}

void fiboEntry(int type, int magic, double lot, double pending, string comment, double sl, double tp) {
   if(Count.OrderAll(magic)==0) {
      int expired = 0;
      if(magic==Magic9 || magic==Magic10 || magic==Magic11 || magic==Magic12 || magic==Magic13 || magic==Magic14 || magic==Magic15) expired = 60*24;
      else if(magic==Magic20 || magic==Magic21 || magic==Magic22 || magic==Magic23 || magic==Magic24 || magic==Magic25) expired = 60*16;
      
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(type==OP_BUY) {
         if(tick.bid-Market_StopFreeze>pending) Trade.OpenBuyLimit(magic,lot,pending,comment+" ",expired,0,0,sl,tp);
         else Trade.OpenBuy(magic,lot,comment+" ",0,0,sl,tp);
      }
      else if(type==OP_SELL) {
         if(tick.ask+Market_StopFreeze<pending) Trade.OpenSellLimit(magic,lot,pending,comment+" ",expired,0,0,sl,tp);
         else Trade.OpenSell(magic,lot,comment+" ",0,0,sl,tp);
      }
   }
}

void InstantEntry(int type, int magic, double lot, string comment, double sl, double tp) {
   if(Count.OrderAllTrade(magic)==0) {
      if(type==OP_BUY) Trade.OpenBuy(magic,lot,comment,0,0,sl,tp);
      else if(type==OP_SELL) Trade.OpenSell(magic,lot,comment,0,0,sl,tp);
   }
}

void SpecialGapMonday() {
   if(DayOfWeek()==MONDAY && BetweenTimeRange(HourMin(1,1),HourMin(1,30))) {
      bool count20   = Count.OrderAll(Magic20)==0;
      bool count21   = Count.OrderAll(Magic21)==0;
      bool count22   = Count.OrderAll(Magic22)==0;
      bool count23   = Count.OrderAll(Magic23)==0;
      bool count24   = Count.OrderAll(Magic24)==0;
      bool count25   = Count.OrderAll(Magic24)==0;
      
      double level = iClose(_Symbol,PERIOD_H1,1);
      double lot = StartLot;
      int x = 100;
      if(level>fib_point5) x = OP_BUY;
      else if(level<fib_point5) x = OP_SELL;
      
      if(x==OP_BUY) {
         fiboEntry(OP_BUY,Magic20,lot,fib_point4,Market_Symbol+"_SW_MonGap1",fib_slBuy,fib_tpBuy);
         fiboEntry(OP_BUY,Magic21,lot,fib_point5,Market_Symbol+"_SW_MonGap2",fib_slBuy,fib_tpBuy);
         fiboEntry(OP_BUY,Magic22,lot,fib_point6,Market_Symbol+"_SW_MonGap3",fib_slBuy,fib_tpBuy);
         fiboEntry(OP_BUY,Magic23,lot,fib_point7,Market_Symbol+"_SW_MonGap4",fib_slBuy,fib_tpBuy);
         fiboEntry(OP_BUY,Magic24,lot,fib_point8,Market_Symbol+"_SW_MonGap5",fib_slBuy,fib_tpBuy);
         fiboEntry(OP_BUY,Magic25,lot,fib_point9,Market_Symbol+"_SW_MonGap6",fib_slBuy,fib_tpBuy);
      }
      else if(x==OP_SELL) {
         fiboEntry(OP_SELL,Magic20,lot,fib_point1,Market_Symbol+"_SW_MonGap1",fib_slSell,fib_tpSell);
         fiboEntry(OP_SELL,Magic21,lot,fib_point2,Market_Symbol+"_SW_MonGap2",fib_slSell,fib_tpSell);
         fiboEntry(OP_SELL,Magic22,lot,fib_point3,Market_Symbol+"_SW_MonGap3",fib_slSell,fib_tpSell);
         fiboEntry(OP_SELL,Magic23,lot,fib_point4,Market_Symbol+"_SW_MonGap4",fib_slSell,fib_tpSell);
         fiboEntry(OP_SELL,Magic24,lot,fib_point5,Market_Symbol+"_SW_MonGap5",fib_slSell,fib_tpSell);
         fiboEntry(OP_SELL,Magic25,lot,fib_point6,Market_Symbol+"_SW_MonGap6",fib_slSell,fib_tpSell);
      }
   }
}

void SpecialSwingMonday() {
   if(DayOfWeek()==MONDAY && BetweenTimeRange(HourMin(17,31),HourMin(18,10))) {
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      
      bool count18   = Count.OrderAllTrade(Magic18)==0;
      bool count19   = Count.OrderAllTrade(Magic19)==0;
      
      if(count18 && BetweenTimeRange(HourMin(17,31),HourMin(17,33))) {
         int sig = 100;
         double last = iClose(_Symbol,PERIOD_H1,4);
         double lot = StartLot*3;
      
         if(tick.bid<last) Trade.OpenBuy(Magic18,lot,Market_Symbol+"_SW_Position_Monday1",0,500,0,0);
         else if(tick.bid>last) Trade.OpenSell(Magic18,lot,Market_Symbol+"_SW_Position_Monday1",0,500,0,0);
      }
      else if(count19 && !count18 && BetweenTimeRange(HourMin(18,0),HourMin(18,2))) {
         int dir = Property.type(Magic18);
         double op = Property.openPrice(Magic18);
         double tp = Property.takeProfit(Magic18);
         double buffer = NumToPoint(MAXSPREAD);
         double lot = StartLot*4;
         
         if(dir==OP_BUY) {
            if(tick.ask<op+buffer) Trade.OpenBuy(Magic19,lot,Market_Symbol+"_SW_Position_Monday2",350,0,0,tp);
         }
         else if(dir==OP_SELL) {
            if(tick.bid>op-buffer) Trade.OpenSell(Magic19,lot,Market_Symbol+"_SW_Position_Monday2",350,0,0,tp);
         }      
      }
      
      if(!count18 && TimeCurrent()>=HourMin(18,4)) {
         double sl18 = Property.stopLoss(Magic18);
         
         if(sl18==0) {
            if(!count19) {
               double sl = Property.stopLoss(Magic19);
               if(sl>0 && StopLevel(sl)) Trade.ModifyStopLoss(Magic18,sl);
            }
            else {
               int margin = 200;
               int dir = Property.type(Magic18);
               double op = Property.openPrice(Magic18);
               double buffer_margin = NumToPoint(margin);
               
               if(dir==OP_BUY) {
                  if(tick.bid<op-buffer_margin-Market_StopFreeze) Trade.CloseOrder(Magic18);
                  else Trade.ModifySL_Point(Magic18,margin);
               }
               else if(dir==OP_SELL) {
                  if(tick.ask>op+buffer_margin+Market_StopFreeze) Trade.CloseOrder(Magic18);
                  else Trade.ModifySL_Point(Magic18,margin);
               }
            }
         }
      }
   }
}

void RangePrice(int timeframe, int range, int startbar, int highmode, int lowmode, double& pricehigh, double& pricelow) {   
   int shiftHighest  = iHighest(_Symbol,timeframe,highmode,range,startbar);
   int shiftLowest   = iLowest(_Symbol,timeframe,lowmode,range,startbar);
   pricehigh         = iHigh(_Symbol,timeframe,shiftHighest);
   pricelow          = iLow(_Symbol,timeframe,shiftLowest);
}

void SpecialSwingThursday() {
   if(DayOfWeek()==THURSDAY && TimeCurrent()<=HourMin(4,0) && SpreadFilterPair()) {
      bool order16 = Count.OrderAll(Magic16)==0;
      bool order17 = Count.OrderAll(Magic17)==0;
      
      if(order16 || order17) {
         double sx_point1,sx_point2,sx_point3,sx_point4,sx_point5,sx_point6,sx_point7,sx_point8,sx_point9,sx_slSell,sx_tpSell,sx_slBuy,sx_tpBuy;
         defineEntrySpx(PERIOD_D1,sx_point1,sx_point2,sx_point3,sx_point4,sx_point5,sx_point6,sx_point7,sx_point8,sx_point9,sx_slBuy,sx_tpSell,sx_slSell,sx_tpBuy);
         
         double dayOpen = iOpen(_Symbol,PERIOD_D1,0);
         int sig = 100;
         if(dayOpen>sx_point5) sig = OP_SELL;
         else if(dayOpen<sx_point5) sig = OP_BUY;
         
         // weekly check
         double dayhigh, daylow, stop;
         RangePrice(PERIOD_H1,10,1,MODE_HIGH,MODE_LOW,dayhigh,daylow);
         double weekhigh = iHigh(_Symbol,PERIOD_W1,0);
         double weeklow = iLow(_Symbol,PERIOD_W1,0);
         double bufferSpread = NumToPoint(Market_Spread);
         double bufferEntry = NumToPoint(MAXSPREAD*2);
         int expired = 60*30;
         double lot = StartLot*5;
         
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         
         if(TimeCurrent()>=HourMin(2,5)) {
            double scare = NumToPoint(100);
            if(dayhigh==weekhigh) {
               stop = dayhigh+bufferSpread+bufferEntry;
               if(tick.ask>=dayhigh-scare) stop = dayhigh+bufferSpread+scare;
               
               Trade.OpenSell(Magic16,lot,Market_Symbol+"_SW_Position_Thurs1",0,0,stop,0);
               Trade.OpenSell(Magic17,lot,Market_Symbol+"_SW_Position_Thurs2",0,0,stop,0);
            }
            else if(daylow==weeklow) {
               stop = daylow-bufferEntry;
               if(tick.bid<=daylow+scare) stop = daylow-scare;
               
               Trade.OpenBuy(Magic16,lot,Market_Symbol+"_SW_Position_Thurs1",0,0,stop,0);
               Trade.OpenBuy(Magic17,lot,Market_Symbol+"_SW_Position_Thurs2",0,0,stop,0);
            }
         }
         else {
            if(sig==OP_BUY) {
               if(tick.bid>sx_point2-bufferSpread) {
                  Trade.OpenSellStop(Magic16,lot,sx_point2-bufferSpread,Market_Symbol+"_SW_Position_Thurs1",expired,0,0,sx_slSell,0);
                  Trade.OpenSellStop(Magic17,lot,sx_point2-bufferSpread,Market_Symbol+"_SW_Position_Thurs2",expired,0,0,sx_slSell,0);
               }
               else if(tick.ask<sx_point2 && tick.bid>sx_point5) {
                  Trade.OpenSell(Magic16,lot,Market_Symbol+"_SW_Position_Thurs1",0,0,0,0);
                  Trade.OpenSellLimit(Magic17,lot,sx_point2+bufferSpread,Market_Symbol+"_SW_Position_Thurs2",expired,0,0,sx_slSell,0);
               }      
            }
            else if(sig==OP_SELL) {
               if(tick.ask<sx_point8+bufferSpread) {
                  Trade.OpenBuyStop(Magic16,lot,sx_point8+bufferSpread,Market_Symbol+"_SW_Position_Thurs1",expired,0,0,sx_slBuy,0);
                  Trade.OpenBuyStop(Magic17,lot,sx_point8+bufferSpread,Market_Symbol+"_SW_Position_Thurs2",expired,0,0,sx_slBuy,0);
               }
               else if(tick.ask<sx_point5 && tick.bid>sx_point8) {
                  Trade.OpenBuy(Magic16,lot,Market_Symbol+"_SW_Position_Thurs1",0,0,0,0);
                  Trade.OpenBuyLimit(Magic17,lot,sx_point8-bufferSpread,Market_Symbol+"_SW_Position_Thurs2",expired,0,0,sx_slBuy,0);
               }      
            }
         }
      }
   }
}

void FirstOrder() {
   if(ActivateEA && NewBar(PERIOD_H1) && MarginLevelProcced(200) && TradeTiming(10,0,21,10)) {
      int Signal = defineInitialBreak();
      if(Signal<2) {
         defineEntryIB(PERIOD_H1,ib_point1,ib_point2,ib_point3,ib_point4,ib_point5,ib_point6,ib_point7,ib_point8,ib_point9,ib_slBuy,ib_tpSell,ib_slSell,ib_tpBuy);
         
         double dayHigh = iHigh(_Symbol,PERIOD_D1,0);
         double dayLow  = iLow(_Symbol,PERIOD_D1,0);
         double bufferX = NumToPoint(20);
         
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         double bufferTarget = NumToPoint(75);
         double lot = StartLot;
         
         double targert_buy_ib = fmin(ib_tpBuy,fib_tpBuy);
         double targert_sell_ib = fmax(ib_tpSell,fib_tpSell);
         
         if(dailyFibo==OP_BUY) {
            if(Signal==OP_BUY) {
               if(tick.bid>fib_point1 && dayHigh<=targert_buy_ib-bufferX) {
                  // Buy order (Signal)
                  fiboEntry(OP_BUY,Magic1,lot,ib_point2,Market_Symbol+"_SW_1",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic2,lot,ib_point3,Market_Symbol+"_SW_2",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic3,lot,ib_point4,Market_Symbol+"_SW_3",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic4,lot,ib_point5,Market_Symbol+"_SW_4",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic5,lot,ib_point6,Market_Symbol+"_SW_5",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic6,lot,ib_point7,Market_Symbol+"_SW_6",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic7,lot,ib_point8,Market_Symbol+"_SW_7",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic8,lot,ib_point9,Market_Symbol+"_SW_8",ib_slBuy,targert_buy_ib);
               }
               else if(dayHigh<fib_point1 && dayLow>fib_point1+bufferTarget && dayLow>=fib_tpSell+bufferX) {
                  // Sell order Instant
                  // SL at fib_sellSL
                  // TP at fib_sellTP
                  InstantEntry(OP_SELL,Magic15,lot,Market_Symbol+"_SW_15",fib_slSell,fib_tpSell);
                  fiboEntry(OP_SELL,Magic9,lot,fib_point2,Market_Symbol+"_SW_9",fib_slSell,fib_tpSell);
                  fiboEntry(OP_SELL,Magic10,lot,fib_point3,Market_Symbol+"_SW_10",fib_slSell,fib_tpSell);
                  fiboEntry(OP_SELL,Magic11,lot,fib_point4,Market_Symbol+"_SW_11",fib_slSell,fib_tpSell);
                  fiboEntry(OP_SELL,Magic12,lot,fib_point5,Market_Symbol+"_SW_12",fib_slSell,fib_tpSell);
                  fiboEntry(OP_SELL,Magic13,lot,fib_point6,Market_Symbol+"_SW_13",fib_slSell,fib_tpSell);
               }
            }
            else if(Signal==OP_SELL) {
               if(dayLow<=fib_point6 && dayLow>=targert_sell_ib+bufferX && tick.bid<fib_point6) {
                  // Sell order (Signal)   
                  fiboEntry(OP_SELL,Magic1,lot,ib_point1,Market_Symbol+"_SW_1",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic2,lot,ib_point2,Market_Symbol+"_SW_2",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic3,lot,ib_point3,Market_Symbol+"_SW_3",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic4,lot,ib_point4,Market_Symbol+"_SW_4",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic5,lot,ib_point5,Market_Symbol+"_SW_5",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic6,lot,ib_point6,Market_Symbol+"_SW_6",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic7,lot,ib_point7,Market_Symbol+"_SW_7",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic8,lot,ib_point8,Market_Symbol+"_SW_8",ib_slSell,targert_sell_ib);          
               }
               else if(dayLow>fib_point6 && dayHigh<fib_point1 && dayHigh<fib_tpBuy+bufferX) {
                  // Buy limit order (Daily Fibo) - 3 orders
                  // Expired at 23.54
                  double stop = fib_tpSell - NumToPoint(MAXSPREAD);
                  fiboEntry(OP_BUY,Magic9,lot,fib_point5,Market_Symbol+"_SW_9",stop,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic10,lot,fib_point6,Market_Symbol+"_SW_10",stop,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic11,lot,fib_point7,Market_Symbol+"_SW_11",stop,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic12,lot,fib_point8,Market_Symbol+"_SW_12",stop,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic13,lot,fib_point9,Market_Symbol+"_SW_13",stop,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic14,lot,fib_slBuy,Market_Symbol+"_SW_14",stop,fib_tpBuy);
               }           
            }
         }
         else if(dailyFibo==OP_SELL) {
            if(Signal==OP_BUY) {
               if(dayHigh>=fib_point3 && tick.bid>=fib_point3 && dayHigh<=targert_buy_ib-bufferX) {
                  // Buy order (Signal)
                  fiboEntry(OP_BUY,Magic1,lot,ib_point2,Market_Symbol+"_SW_1",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic2,lot,ib_point3,Market_Symbol+"_SW_2",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic3,lot,ib_point4,Market_Symbol+"_SW_3",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic4,lot,ib_point5,Market_Symbol+"_SW_4",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic5,lot,ib_point6,Market_Symbol+"_SW_5",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic6,lot,ib_point7,Market_Symbol+"_SW_6",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic7,lot,ib_point8,Market_Symbol+"_SW_7",ib_slBuy,targert_buy_ib);
                  fiboEntry(OP_BUY,Magic8,lot,ib_point9,Market_Symbol+"_SW_8",ib_slBuy,targert_buy_ib);
               }
               else if(dayHigh<fib_point3 && dayLow>fib_point9 && dayLow>=fib_tpSell+bufferX) {
                  // Sell limit order (Daily Fibo) - 3 orders
                  // Expired at 23.54
                  double stop = fib_tpBuy + NumToPoint(MAXSPREAD);
                  fiboEntry(OP_SELL,Magic9,lot,fib_point1,Market_Symbol+"_SW_9",stop,fib_tpSell);
                  fiboEntry(OP_SELL,Magic10,lot,fib_point2,Market_Symbol+"_SW_10",stop,fib_tpSell);
                  fiboEntry(OP_SELL,Magic11,lot,fib_point3,Market_Symbol+"_SW_11",stop,fib_tpSell);
                  fiboEntry(OP_SELL,Magic12,lot,fib_point4,Market_Symbol+"_SW_12",stop,fib_tpSell);
                  fiboEntry(OP_SELL,Magic13,lot,fib_point5,Market_Symbol+"_SW_13",stop,fib_tpSell);
                  fiboEntry(OP_SELL,Magic14,lot,fib_slSell,Market_Symbol+"_SW_14",stop,fib_tpSell);
               }
            }
            else if(Signal==OP_SELL) {
               if(tick.bid<fib_point9 && dayLow>=targert_sell_ib+bufferX) {
                  // Sell order (Signal)
                  fiboEntry(OP_SELL,Magic1,lot,ib_point1,Market_Symbol+"_SW_1",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic2,lot,ib_point2,Market_Symbol+"_SW_2",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic3,lot,ib_point3,Market_Symbol+"_SW_3",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic4,lot,ib_point4,Market_Symbol+"_SW_4",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic5,lot,ib_point5,Market_Symbol+"_SW_5",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic6,lot,ib_point6,Market_Symbol+"_SW_6",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic7,lot,ib_point7,Market_Symbol+"_SW_7",ib_slSell,targert_sell_ib);
                  fiboEntry(OP_SELL,Magic8,lot,ib_point8,Market_Symbol+"_SW_8",ib_slSell,targert_sell_ib); 
               }
               else if(dayLow>fib_point9 && dayHigh<fib_point1-bufferTarget && dayHigh<=fib_tpBuy-bufferX) {
                  // Buy order Instant
                  // SL at fib_buySL
                  // TP at fib_buyTP
                  InstantEntry(OP_BUY,Magic15,lot,Market_Symbol+"_SW_15",fib_slBuy,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic9,lot,fib_point4,Market_Symbol+"_SW_9",fib_slBuy,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic10,lot,fib_point5,Market_Symbol+"_SW_10",fib_slBuy,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic11,lot,fib_point6,Market_Symbol+"_SW_11",fib_slBuy,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic12,lot,fib_point7,Market_Symbol+"_SW_12",fib_slBuy,fib_tpBuy);
                  fiboEntry(OP_BUY,Magic13,lot,fib_point8,Market_Symbol+"_SW_13",fib_slBuy,fib_tpBuy);
               }
            }
         }
      }
   }
}

void EachOrder(int magic) {
   if(Count.OrderAll(magic)>0) {
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      int type = Property.type(magic);
      double tp = Property.takeProfit(magic);
      double trigger;
      
      bool thursday     = false,
           monday       = false,
           monday_gap   = false,
           ib           = false;
      if(magic==Magic16 || magic==Magic17) thursday = true;
      else if(magic==Magic18 || magic==Magic19) monday = true;
      else if(magic==Magic20 || magic==Magic21 || magic==Magic22 || magic==Magic23 || magic==Magic24 || magic==Magic25) monday_gap = true;
      else if(magic==Magic1 || magic==Magic2 || magic==Magic3 || magic==Magic4 || magic==Magic5 || magic==Magic6 || magic==Magic7 || magic==Magic8) ib = true;
      
      if(Count.OrderAllPending(magic)>0) {
         double todayHigh  = iHigh(_Symbol,PERIOD_D1,0);
         double todayLow   = iLow(_Symbol,PERIOD_D1,0);
         
         double buffer = NumToPoint(20);
         if(tp>0) {
            if((type==OP_BUYLIMIT && (tick.bid>=tp-buffer||todayHigh>=tp-buffer)) || (type==OP_SELLLIMIT && (tick.bid<=tp+buffer||todayLow<=tp+buffer))) Trade.DeletePendingOrder(magic);
         }
         
         int expiry = 16;
         if(thursday) expiry = 20;
         
         if(Trade.ExpiredOrder(magic,expiry,PERIOD_H1)) Trade.DeletePendingOrder(magic);
         else if(monday_gap && TimeCurrent()>HourMin(17,29)) Trade.DeletePendingOrder(magic);
         else if(ib && DayOfWeek()==FRIDAY && TimeCurrent()>HourMin(23,54)) Trade.DeletePendingOrder(magic);
      }
      else if(Count.OrderAllTrade(magic)>0) {
         double buffer = NumToPoint(20);
         if(tp>0) {
            if(type==OP_BUY) {
               trigger = tp-buffer;
               if(tick.bid>=trigger) Features.ProtectingTargetScalp(magic);
            }
            else if(type==OP_SELL) {
               trigger = tp+buffer;
               if(tick.bid<=trigger) Features.ProtectingTargetScalp(magic);
            }
         }
         
         if(monday) {
            Features.BreakEven(magic,300);
         }
         else if(monday_gap) {
            Features.BreakEven(magic,500);
            if(DayOfWeek()==MONDAY && BetweenTimeRange(HourMin(17,32),HourMin(17,35))) {
               bool order18 = Count.OrderAllTrade(Magic18)>0;
               if(order18) {
                  int dir = Property.type(Magic18);
                  if(type!=dir) Trade.CloseOrder(magic);
               }
            }
         }
         else if(thursday) {
            Features.BreakEven(magic,500,50);
            if(DayOfWeek()==FRIDAY) {
               if(tp==0) {
                  double lvl;               
                  if(type==OP_BUY) {
                     lvl = fib_slSell;
                     if(tick.ask+Market_StopFreeze>lvl-buffer) Features.ProtectingTargetScalp(magic);
                     else Trade.ModifyTakeProfit(magic,lvl);
                  }
                  else if(type==OP_SELL) {
                     lvl = fib_slBuy;
                     if(tick.bid-Market_StopFreeze<lvl+buffer) Features.ProtectingTargetScalp(magic);
                     else Trade.ModifyTakeProfit(magic,lvl);
                  }               
               }
               if(TimeCurrent()>=HourMin(23,54)) Features.ProtectingTargetScalp(magic);
            }
         }
         else if(TimeCurrent()>=HourMin(23,54)) {
            Features.BreakEven(magic,350);
            double op = Property.openPrice(magic);
            if(type==OP_BUY) {
               trigger = op+(buffer*2);
               if(tick.bid>=trigger) Features.ProtectingTargetScalp(magic);
            }
            else if(type==OP_SELL) {
               trigger = op-(buffer*2);
               if(tick.ask<=trigger) Features.ProtectingTargetScalp(magic);
            }
         }
      }
   }
}


void ManageExistingOrder() {
   EachOrder(Magic1);
   EachOrder(Magic2);
   EachOrder(Magic3);
   EachOrder(Magic4);
   EachOrder(Magic5);
   EachOrder(Magic6);
   EachOrder(Magic7);
   EachOrder(Magic8);
   EachOrder(Magic9);
   EachOrder(Magic10);
   EachOrder(Magic11);
   EachOrder(Magic12);
   EachOrder(Magic13);
   EachOrder(Magic14);
   EachOrder(Magic15);
   EachOrder(Magic16);
   EachOrder(Magic17);
   EachOrder(Magic18);
   EachOrder(Magic19);
   EachOrder(Magic20);
   EachOrder(Magic21);
   EachOrder(Magic22);
   EachOrder(Magic23);
   EachOrder(Magic24);
   EachOrder(Magic25);
   
   Trade.SecureManualOrder();
   Trade.SecureManualOrder(111111111);  // Buy Script
   Trade.SecureManualOrder(999999999);  // Sell Script

   Trade.PendingOrderManagement();
   Trade.PendingOrderManagement(111111111);
   Trade.PendingOrderManagement(999999999);
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
   Acc_Type             = "Real";
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO) Acc_Type = "Demo";
   
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

double CustomIndicator(ENUM_TIMEFRAMES timeframe, string name, int buffer, int input1, int input2, int shift = 1, bool market = false){
   if(market) return NormPrice(iCustom(_Symbol,timeframe,"\\Market\\"+name,input1,input2,buffer,shift));
   else return NormPrice(iCustom(_Symbol,timeframe,name,input1,input2,buffer,shift));
}

bool emptyValue(double value) {
   return value>EMPTY_VALUE-2;
}

bool PendingLevelsChk(string obj, int limit, double& level){
   double buffer  = NumToPoint(limit+Market_Spread);
   level   = NormPrice(ObjectGetValueByShift(ObjIdentifier+obj,0));
   if(level!=0) return BetweenPriceRange(level+buffer,level-buffer);
   else return false;
}

int barExpired(int timeframe, int bar) {
   int timeMinutes = PeriodSeconds(PERIOD_M1);
   int timeHour    = PeriodSeconds(PERIOD_H1);
   int timeDay     = PeriodSeconds(PERIOD_D1);
   int timeWeek    = PeriodSeconds(PERIOD_W1);
   int timeMonth   = PeriodSeconds(PERIOD_MN1);
   int Exp         = timeMonth*4;
   
   if(timeframe==PERIOD_CURRENT) {
      int x = _Period;
      if(x==PERIOD_W1) Exp = timeWeek*bar;
      else if(x==PERIOD_D1) Exp = timeDay*bar;
      else if(x==PERIOD_H4) Exp = (timeHour*4)*bar;
      else if(x==PERIOD_H1) Exp = timeHour*bar;
      else if(x==PERIOD_M30) Exp = (timeMinutes*30)*bar;
      else if(x==PERIOD_M15) Exp = (timeMinutes*15)*bar;
      else if(x==PERIOD_M5) Exp = (timeMinutes*5)*bar;
      else if(x==PERIOD_M1) Exp = timeMinutes*bar;
   }
   else if(timeframe==PERIOD_W1) Exp = timeWeek*bar;
   else if(timeframe==PERIOD_D1) Exp = timeDay*bar;
   else if(timeframe==PERIOD_H4) Exp = (timeHour*4)*bar;
   else if(timeframe==PERIOD_H1) Exp = timeHour*bar;
   else if(timeframe==PERIOD_M30) Exp = (timeMinutes*30)*bar;
   else if(timeframe==PERIOD_M15) Exp = (timeMinutes*15)*bar;
   else if(timeframe==PERIOD_M5) Exp = (timeMinutes*5)*bar;
   else if(timeframe==PERIOD_M1) Exp = timeMinutes*bar;

   return Exp;
}

void SentStatus(int hour, int minutes, double report1, double report2, double report3) {
   string NewLine = "\n", sInput  = "%s";
   datetime time1 = HourMin(hour,minutes);
   datetime time2 = HourMin(hour,minutes+1);
   
   if(BetweenTimeRange(time1,time2) && FirstTick(PERIOD_M1)) {
      string floating = "No Order";
      string acc = " ("+Acc_Type+")";
      if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(Report.FloatingStatusTerminal()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel),NewLine,"Drawdown : ",Acc_DrawdownText);
      
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
      SendNotificationFunction(msg);
   }
}

double MartingaleLot(double lot, double multiplier, int level){
   double rawlot = lot*pow(multiplier,level);
   return VerifyLotMinMax(rawlot); 
}

bool GridDistChk(int magic, int distance = 0, bool martingale = true){
   double   distanceLvl = NumToPoint(distance);
   double   ChkLevel;

   if(distance>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
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

bool CPool::TerminalTrade(int i) {
   return (OrderSelect(i,SELECT_BY_POS) && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

bool CPool::TerminalPending(int i) {
   return (OrderSelect(i,SELECT_BY_POS)
   && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP));
}

bool CPool::SymbolAll(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

bool CPool::SymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

bool CPool::SymbolPending(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol 
   && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP));
}

bool CPool::TradeHistory(int i, int timeframe, int period){
   datetime range = TimeCurrent()-(period*PeriodSeconds(timeframe));
   return (OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) && OrderCloseTime()>=range && (OrderType()==OP_BUY || OrderType()==OP_SELL) );
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

bool CPool::MagicPending(int i, int magic, int mode = MODE_TRADES){
   return (
   OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic 
   && (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
   );
}

bool CPool::TradeHedging(int i, int masterType){
   int opposite = 100;
   if(masterType==OP_BUY) opposite = OP_SELL;
   else if(masterType==OP_SELL) opposite = OP_BUY;
   
   return (OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderType()==opposite);
}

bool CPool::ThisEA() {
   return (
   OrderMagicNumber()==MagicHedge   ||
   OrderMagicNumber()==Magic1       ||
   OrderMagicNumber()==Magic2       ||
   OrderMagicNumber()==Magic3       ||
   OrderMagicNumber()==Magic4       ||
   OrderMagicNumber()==Magic5       ||
   OrderMagicNumber()==Magic6       ||
   OrderMagicNumber()==Magic7       ||
   OrderMagicNumber()==Magic8       ||
   OrderMagicNumber()==Magic9       ||
   OrderMagicNumber()==Magic10      ||
   OrderMagicNumber()==Magic11      ||
   OrderMagicNumber()==Magic12      ||
   OrderMagicNumber()==Magic13      ||
   OrderMagicNumber()==Magic14      ||
   OrderMagicNumber()==Magic15      ||
   OrderMagicNumber()==Magic16      ||
   OrderMagicNumber()==Magic17      ||
   OrderMagicNumber()==Magic18      ||
   OrderMagicNumber()==Magic19      ||
   OrderMagicNumber()==Magic20      ||
   OrderMagicNumber()==Magic21      ||
   OrderMagicNumber()==Magic22      ||
   OrderMagicNumber()==Magic23      ||
   OrderMagicNumber()==Magic24      ||
   OrderMagicNumber()==Magic25
   );
}

// --- Counting Variable ------------------------------------------------------------------
// for(int i=0;i<total;i++) // Counting up
// for(int i=total; i>0; i--) // counting down
// for(int i = OrdersTotal() - 1; i >= 0 ; i--)

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

int tfIdentifier(ENUM_TIMEFRAMES timeframe) {
   switch(timeframe){
      case 1:     return 1;
      case 5:     return 2;
      case 15:    return 3;
      case 30:    return 4;
      case 60:    return 5;
      case 240:   return 6;
      case 1440:  return 7;
      case 10080: return 8;
      case 43200: return 9;      
      default:    return 0;
   }
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

bool sameLot(double a, double b) {
   return StringLot(a)==StringLot(b);
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
   else if(sym=="AUDUSD" || sym=="NZDUSD" || sym=="EURJPY") MaxSpread = 25;
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

double CMoney::FullMarginLot(double balance, int leverage, int spread, double MinMarginPercentage = 120, int divider = 1, double CommPerStdLot = 0) {
   int buffer                    = 3*Acc_Pips;
   int margin                    = spread*2;
   double LotSize                = Market_MaxLot;
   double LevMargin              = Market_ContractSize/double(leverage);
   double RefPrice               = getReferencePrice();
   double CommPerStdLotRoundTurn = fmax(CommPerStdLot,General.OrderCommissionChk());
   double tempDivider            = double(divider);
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
   if(divider_starter<1.0) divider_starter = 1.02;
   if(balance<100) divider_starter += 0.01;
   double Extreme = balance/divider_starter;
   
   if(divider<1) tempDivider = 1.0;
   double rawlot = (Extreme/AccociateCost)/tempDivider;
   double SuicideLot = NormLot(rawlot);
   if(SuicideLot<Market_MaxLot) LotSize = SuicideLot;

   return LotSize;
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
   
   if(!pRiskManagement) LotSize = VerifyLotMinMax(StartLot);
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

int CCount::OrderAllSymbol(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order)) {
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
      if(Select.SymbolAll(order)) {
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

int CCount::OrderTradeSymbol(int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order) && Select.ThisEA()) {
         if(type==OP_BUY && OrderType()==OP_BUY) count++;
         else if(type==OP_SELL && OrderType()==OP_SELL) count++;
      }
   }
   return count;
}

int CCount::OrderTradeEA(int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order) && Select.ThisEA()) {
         if(type==OP_BUY && OrderType()==OP_BUY) count++;
         else if(type==OP_SELL && OrderType()==OP_SELL) count++;
      }
   }
   return count;
}

int CCount::ThisEACount(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && Select.ThisEA()) count++;
   }
   return count;
}

double CCount::ThisEALot(){
   double lot = 0.0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && Select.ThisEA()) lot += OrderLots();
   }
   return lot;
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

int CCount::OrderAll(int magic, int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) {
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

int CCount::OrderAllTrade(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.Magic(order,magic)) {
         if(OrderType()==OP_BUY) count++;
         else if(OrderType()==OP_SELL) count++;
      }
   }
   return count;
}

int CCount::OrderAllPending(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.Magic(order,magic) && OrderType()>=2) count++;
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
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !SpreadFilterPair() || !RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

bool CTrade::FirstCheck() {
   if(LiveOperation()) return TerminalInfoInteger(TERMINAL_CONNECTED) && !IsTradeContextBusy() && SpreadFilterPair() && SessionTrade();
   else return true;
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
      }
   }
}

void CTrade::OpenPendingOrder(int type, int magic, double lot, double pPricePending, string comment, int expiredMinutes){
   string   msg;
   bool     proceed     = false;
   color    arrow       = clrGreen;
   datetime Expired     = 0;

   if(!NewOrderChk("Pending",type,lot,msg)) {
      NotifySetting(msg);
      SleepSeconds(30); // Pause 30 seconds
      return;
   }
   
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   if((type==OP_BUYLIMIT || type==OP_SELLSTOP) && tick.bid>pPricePending+Market_StopFreeze) proceed = true;
   else if((type==OP_SELLLIMIT || type==OP_BUYSTOP)) {
      arrow = clrRed;
      if(tick.ask<pPricePending-Market_StopFreeze) proceed = true;
   }
   
   if(proceed) {
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
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
               SleepSeconds(RETRY_SECONDS);
            }
            else break;
         }
      } // -- end while retry ---
      if(ticket == -1) OrderSendError("Pending");
      else {
         ul_res = GetMicrosecondCount()-ul;
         msString("Pending order execute",ul_res);
      }
   }
}

void CTrade::HedgeToClose(int signal, int magic, double lot) {
   if(signal<2) {
      string comment = "HedgeToClose";
      if(signal==OP_BUY) Trade.OpenBuy(magic,lot,comment);
      else if(signal==OP_SELL) Trade.OpenSell(magic,lot,comment);
   }
}

void CTrade::Magic_HedgeToCloseSystem(int magic, double lot = 0.0) {
   int hedgeSignal   = 100;
   double hedgeLot   = 0;
   double temp       = 0;
   double lotbuy     = Property.orderLotHedge(magic,OP_BUY);
   double lotsell    = Property.orderLotHedge(magic,OP_SELL);
   
   if(lotbuy>lotsell) {
      hedgeSignal = OP_SELL;
      temp = lotbuy - lotsell;
      if(lot>0 && lot<temp) hedgeLot = lot;
      else hedgeLot = temp;
   }
   else if(lotbuy<lotsell) {
      hedgeSignal = OP_BUY;
      temp = lotsell - lotbuy;
      if(lot>0 && lot<temp) hedgeLot = lot;
      else hedgeLot = temp;
   }
   
   if(hedgeSignal<2) {
      DeleteSLTP(magic);
      if(Count.OrderAll(MagicHedge)==0) HedgeToClose(hedgeSignal,MagicHedge,hedgeLot);
   }
   
   if(Count.OrderAll(MagicHedge)>0) {
      SleepSeconds(1);
      bool x = MagicCloseBy(MagicHedge,magic);
      if(!x) {
         Trade.CloseOrder(magic);
         Trade.CloseOrder(MagicHedge);
      }
   }
}

void CTrade::Symbol_HedgeToCloseSystem() {
   bool equivalent   = false;
   int hedgeSignal   = 100;
   double hedgeLot   = 0;
   double lotbuy     = Property.currentOrderLot(OP_BUY);
   double lotsell    = Property.currentOrderLot(OP_SELL);
   
   if(lotbuy>lotsell) {
      hedgeSignal = OP_SELL;
      hedgeLot = lotbuy - lotsell;
   }
   else if(lotbuy<lotsell) {
      hedgeSignal = OP_BUY;
      hedgeLot = lotsell - lotbuy;
   }
   else if(sameLot(lotbuy,lotsell)) equivalent = true;
   
   if(hedgeSignal<2) {
      DeleteSLTPTrade();
      if(!equivalent && Count.OrderAll(MagicHedge)==0) HedgeToClose(hedgeSignal,MagicHedge,hedgeLot);
   }
   if(Count.OrderAll(MagicHedge)>0 || equivalent) {
      SleepSeconds(1);
      bool x = MultipleCloseBy();
      if(!x) Trade.CloseOrder(MagicHedge);
   }
}

void CTrade::OpenBuy(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic) && SpreadFilterPair()){
      OpenOrder(OP_BUY,magic,lot,comment);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice<tick.bid-Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice>tick.ask+Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenSell(int magic, double lot, string comment, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic) && SpreadFilterPair()){
      OpenOrder(OP_SELL,magic,lot,comment);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice>tick.ask+Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice<tick.bid-Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenBuyLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_BUYLIMIT,magic,lot,pPendingPrice,comment,expired);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice<tick.bid-Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice>tick.ask+Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenBuyStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_BUYSTOP,magic,lot,pPendingPrice,comment,expired);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice<tick.bid-Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice>tick.ask+Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenSellLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_SELLLIMIT,magic,lot,pPendingPrice,comment,expired);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice>tick.ask+Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice<tick.bid-Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

void CTrade::OpenSellStop(int magic, double lot, double pPendingPrice, string comment, int expired = 0, int stopPoint=0, int takePoint=0, double stopPrice=0, double takePrice=0) {
   if(!OrderExist(magic)) {
      OpenPendingOrder(OP_SELLSTOP,magic,lot,pPendingPrice,comment,expired);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(stopPoint>0) ModifySL_Point(magic,stopPoint);
      else if(stopPrice>0 && stopPrice>tick.ask+Market_StopFreeze) ModifyStopLoss(magic,stopPrice);
      if(takePoint>0) ModifyTP_Point(magic,takePoint);
      else if(takePrice>0 && takePrice<tick.bid-Market_StopFreeze) ModifyTakeProfit(magic,takePrice);
   }
}

bool CTrade::ExpiredOrder(int magic, int bar, ENUM_TIMEFRAMES timeframe) {
   bool x = false;
   if(Count.OrderAll(magic)>0) {
      datetime ot = Property.openTime(magic);
      if(TimeCurrent()>=ot+bar*PeriodSeconds(timeframe)) x = true;
   }
   return x;
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
               if(!closeorder) {
                  if(OrderExist(magic)) OrderCloseError(OrderTicket(),"close");
                  else ResetLastError();
               }
            }
         }     
      }
   }
}

void CTrade::CloseOrder_ByHedging(int magic){
   if(OrderExist(magic)) {
      double pnl = Report.TradePL(magic);
      if(pnl>0 && Acc_MarginLevel>=1000) Magic_HedgeToCloseSystem(magic);
      else CloseOrder(magic);
   }
}

void CTrade::PartialCloseOrder_ByHedging(int magic, double lot) {
   if(OrderExist(magic)) {
      if(Acc_MarginLevel>=1000) {
         double sl = Property.stopLoss(magic);
         double tp = Property.takeProfit(magic);
         Magic_HedgeToCloseSystem(magic,lot);
         // restore SLTP
         if(Count.OrderAll(magic)>0) {
            if(sl>0) Trade.ModifyStopLoss(magic,sl);
            if(tp>0) Trade.ModifyTakeProfit(magic,tp);
         }
      }
      else PartialClose(magic,lot);
   }
}

void CTrade::CloseAllOrderSymbol_ByHedging(){
   if(Count.OrderAllSymbol(OP_BUY)>0 || Count.OrderAllSymbol(OP_SELL)>0) {
      if(Acc_MarginLevel>=2000) Symbol_HedgeToCloseSystem();
      else CloseAllOrder_Symbol();
   }
}

bool CTrade::MagicCloseBy(const int magic1, const int magic2) {
   double lot = 0;
   for(int i=OrdersTotal()-1; i>0; --i){
      if(Select.SymbolTrade(i) && OrderLots()>lot && (OrderMagicNumber()==magic1 || OrderMagicNumber()==magic2)) {
         int   first_ticket = OrderTicket();
         int   first_type   = OrderType();
         for(int j=i; j>=0; --j){
            if(Select.TradeHedging(j,first_type) && (OrderMagicNumber()==magic1 || OrderMagicNumber()==magic2)) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
                  closeorder = OrderCloseBy(first_ticket,OrderTicket(),clrPink);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     msString("closedby",ul_res,OrderTicket());
                     return MagicCloseBy(magic1,magic2);
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
            }
         }
         break;
      }
   }
   return true;
}

bool CTrade::MultipleCloseBy() {
   double lot = 0;
   for(int i=OrdersTotal()-1; i>0; --i){
      if(Select.SymbolTrade(i) && OrderLots()>lot && Select.ThisEA()) {
         int   first_magic  = OrderMagicNumber();
         int   first_type   = OrderType();
         for(int j=i; j>=0; --j){
            if(Select.TradeHedging(j,first_type) && Select.ThisEA()) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
                  closeorder = OrderCloseBy(Property.ticket(first_magic), OrderTicket(),clrPink);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     msString("multiple closedby",ul_res,OrderTicket());
                     return MultipleCloseBy();
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
            }
         }
         break;
      }
   }
   return true;
}

void CTrade::CloseAllOrder_Symbol(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.SymbolTrade(order)){
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
                  order--;
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

void CTrade::CloseAllOrder_Symbol_NonFIFO() {
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   int retry = 0;
   while(retry <= MAX_RETRIES) {
      if(!CloseAll_Symbol_NonFIFO()) {
         retry++;
         SleepSeconds(RETRY_SECONDS);
      }
      else break;
   }
   ul_res = GetMicrosecondCount()-ul;
   msString("Multiple closed order",ul_res);
}

void CTrade::CloseAllOrder_Symbol_FIFO() {
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   int retry = 0;
   while(retry <= MAX_RETRIES) {
      if(!CloseAll_Symbol_FIFO()) {
         retry++;
         SleepSeconds(RETRY_SECONDS);
      }
      else break;
   }
   ul_res = GetMicrosecondCount()-ul;
   msString("Multiple closed order (FIFO)",ul_res);
}

void CTrade::PendingOrderManagement(int magic = 0) {
   for(int i = OrdersTotal()-1; i >= 0; --i) {
      if(Select.SymbolPending(i) && OrderMagicNumber()==magic) {
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         bool x = false;
         double buffer = NumToPoint(20);

         if(OrderType()==OP_BUYLIMIT && OrderTakeProfit()>0) {
            if(tick.ask>=OrderTakeProfit()-buffer) x = true;
         }
         else if(OrderType()==OP_SELLLIMIT && OrderTakeProfit()>0) {
            if(tick.bid<=OrderTakeProfit()+buffer) x = true;   
         }
         else if(OrderType()==OP_BUYSTOP && OrderStopLoss()>0) {
            if(tick.bid<=OrderStopLoss()) x = true;
         }
         else if(OrderType()==OP_SELLSTOP && OrderStopLoss()>0) {
            if(tick.ask>OrderStopLoss()) x = true;
         }
         
         if(x) {
            bool Deleted = false;
            ServerCheck();
            Deleted = OrderDelete(OrderTicket(),clrRed);
            if(Deleted) Print("Order # ", OrderTicket(), " deleted.");
         }
      }
   }
}

void CTrade::SecureManualOrder(int magic = 0) {
   int type = 100;
   int ticket = -1;
   
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.SymbolTrade(order) && OrderMagicNumber()==magic && OrderTakeProfit()>0) {
         Features.BreakEvenTicket(OrderTicket(),350);
         
         type = OrderType();
         
         bool x = false;
         double buffer  = NumToPoint(30);
         double bufferX = NumToPoint(50);
         
         if(type==OP_BUY) {
            if(tick.bid>OrderOpenPrice()+bufferX) {
               if(tick.bid>=OrderTakeProfit()-buffer && (OrderStopLoss()==0 || OrderStopLoss()<tick.bid-buffer)) x = true;
               else if(TimeCurrent()>=HourMin(23,50)) Features.BreakEvenTicket(OrderTicket(),75);
            }
         }
         else if(type==OP_SELL) {
            if(tick.ask<OrderOpenPrice()-bufferX) {
               if(tick.bid<=OrderTakeProfit()+buffer && (OrderStopLoss()==0 || OrderStopLoss()>tick.ask+buffer)) x = true;
               else if(TimeCurrent()>=HourMin(23,50)) Features.BreakEvenTicket(OrderTicket(),75);
            }
         }
         
         if(x) {
            ticket = OrderTicket();
            break;
         }
      }  
   }
   
   if(ticket!=-1) {
      if(OrderSelect(ticket, SELECT_BY_TICKET)) {
         double sl = 0;
         double sl_buffer = NumToPoint(5);
         if(type==OP_BUY) sl = tick.bid-sl_buffer;
         else if(type==OP_SELL) sl = tick.ask+sl_buffer;    
         
         if(AcceptableDifference(OrderStopLoss(),sl) && StopLevel(sl)){
            int retry = 0;
            bool modify = false;
            while(retry <= MAX_RETRIES) {
               ServerCheck();
               modify = OrderModify(ticket,OrderOpenPrice(),sl,OrderTakeProfit(),0);
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
            if(!modify) ModifyError(ticket);
         }
      }
   }
}

bool CTrade::CloseAll_Symbol_NonFIFO() {
   int ticket = -1;
   int magic = -1;
   datetime open_time = -1;
   bool haveSLTP = false;
   
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.SymbolTrade(order) && Select.ThisEA() && OrderOpenTime()>open_time) ticket = OrderTicket();
   }
   
   if(ticket!=-1) {
      DeleteSLTPTrade();
      if(OrderSelect(ticket, SELECT_BY_TICKET)) {
         int retry = 0;
         bool closeorder = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            closeorder = OrderClose(ticket,OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
            if(closeorder) return CloseAll_Symbol_NonFIFO();
            else {
               bool RetryOnServerError = ServerError(_LastError);
               if(RetryOnServerError) {
                  retry++;
                  Print("Server error detected, retrying...");
                  SleepSeconds(RETRY_SECONDS);
               }
               else return false;
            }
         }
      }
   }
   return true;
}

bool CTrade::CloseAll_Symbol_FIFO() {
   int ticket = -1;
   datetime open_time = -1;
   
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.SymbolTrade(order) && Select.ThisEA() && (open_time == -1 || OrderOpenTime() < open_time)) ticket = OrderTicket();
   }
   
   if(ticket!=-1) {
      DeleteSLTPTrade();
      if(OrderSelect(ticket, SELECT_BY_TICKET)) {
         int retry = 0;
         bool closeorder = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            closeorder = OrderClose(ticket,OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
            if(closeorder) return CloseAll_Symbol_FIFO();
            else {
               bool RetryOnServerError = ServerError(_LastError);
               if(RetryOnServerError) {
                  retry++;
                  Print("Server error detected, retrying...");
                  SleepSeconds(RETRY_SECONDS);
               }
               else return false;
            }
         }
      }
   }
   return true;
}

void CTrade::CloseAllOrder_Terminal(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.TerminalTrade(order)) {
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
                  order--;
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
            if(Select.MagicTrade(order,magic)) {
               bool proceed = true;     
               if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
               else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
               if(proceed) {
                  int retry = 0;
                  bool closeorder = false;
                  while(retry <= MAX_RETRIES) {
                     ServerCheck();
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
                           SleepSeconds(RETRY_SECONDS);
                        }
                        else break;
                     }
                  } // -- end while retry ---
                  if(!closeorder) {
                     if(OrderExist(magic)) OrderCloseError(OrderTicket(),"partial close");
                     else ResetLastError();
                  }
               }
            }     
         }
      }
   }
}

void CTrade::DeletePendingOrder(int magic){
   if(OrderExist(magic)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicPending(order,magic)) {
            if(StopLevel(OrderOpenPrice())) {
               int retry = 0;
               bool Deleted = false;
               while(retry <= MAX_RETRIES) {
                  ServerCheck();
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
                        SleepSeconds(RETRY_SECONDS);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!Deleted) {
                  if(OrderExist(magic)) OrderCloseError(OrderTicket(),"delete");
                  else ResetLastError();
               }
            }
         }
      }
   }
}

void CTrade::DeleteAllPendingOrder_Symbol(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.SymbolPending(order)) {
         if(StopLevel(OrderOpenPrice())) {
            int retry = 0;
            bool Deleted = false;
            while(retry <= MAX_RETRIES) {
               ServerCheck();
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
                     SleepSeconds(RETRY_SECONDS);
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
      if(Select.TerminalPending(order)) {
         if(StopLevel(OrderOpenPrice())) {
            int retry = 0;
            bool Deleted = false;
            while(retry <= MAX_RETRIES) {
               ServerCheck();
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
                     SleepSeconds(RETRY_SECONDS);
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

void CTrade::DeleteSLTP(int magic) { 
   for(int order = OrdersTotal()-1; order >= 0; order--){ 
      if(Select.Magic(order,magic) && (OrderTakeProfit()>0 || OrderStopLoss()>0)){
         int retry = 0;
         bool modify = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            modify = OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0);
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
         } // End while retry
         if(!modify) {
            if(Count.OrderAll(magic)>0) ModifyError(OrderTicket());
            else ResetLastError();
         }
      }
   }
}

void CTrade::DeleteSLTPTrade() { 
   for(int order = OrdersTotal()-1; order >= 0; order--){ 
      if(Select.SymbolTrade(order) && Select.ThisEA() && (OrderTakeProfit()>0 || OrderStopLoss()>0)){
         int retry = 0;
         bool modify = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            modify = OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0);
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
         } // End while retry
         if(!modify) ModifyError(OrderTicket());
      }
   }
}


void CTrade::ModPendingOrder(int magic, double pPending) { 
   if(OrderExist(magic) && pPending>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicPending(order,magic)) {
            double NormPending = NormPrice(pPending);
            if(AcceptableDifference(OrderOpenPrice(),NormPending) && StopLevel(NormPending)){
               datetime bufferExpired = TimeCurrent()+12*PeriodSeconds(PERIOD_M1);
               if(OrderExpiration()==0 || (OrderExpiration()>0 && bufferExpired<OrderExpiration())) {
                  int retry = 0;
                  bool modify = false;
                  while(retry <= MAX_RETRIES) {
                     ServerCheck();
                     modify = OrderModify(OrderTicket(),NormPending,OrderStopLoss(),OrderTakeProfit(),OrderExpiration());
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
                  } // while retry loop
                  if(!modify) {
                     if(OrderExist(magic)) ModifyError(OrderTicket());
                     else ResetLastError();
                  }
               }
            } 
         }
      }
   }
}

void CTrade::ModifyStopLoss(int magic, double pPriceSL) { 
   if(OrderExist(magic) && pPriceSL>=0) {
      for(int i = OrdersTotal()-1; i >= 0; --i) {
         if(Select.Magic(i,magic)) {
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
               if(!modify) {
                  if(OrderExist(magic) && _LastError!=130) ModifyError(OrderTicket());
                  else ResetLastError();
               }
            }
         }
      }
   }
}

void CTrade::ModifyStopLossTicket(int ticket, double pPriceSL) { 
   if(OrderSelect(ticket, SELECT_BY_TICKET) && pPriceSL>0) {
      double sl = NormPrice(pPriceSL);
      if(AcceptableDifference(OrderStopLoss(),sl) && StopLevel(sl)){
         int retry = 0;
         bool modify = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            modify = OrderModify(ticket,OrderOpenPrice(),sl,OrderTakeProfit(),0);
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
         if(!modify) ModifyError(ticket);
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
               if(!modify) {
                  if(OrderExist(magic)) ModifyError(OrderTicket());
                  else ResetLastError();
               }
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
               if(!modify) {
                  if(OrderExist(magic)) ModifyError(OrderTicket());
                  else ResetLastError();
               }
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
               if(!modify) {
                  if(OrderExist(magic)) ModifyError(OrderTicket());
                  else ResetLastError();
               }
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
   MagicHedge  = generateID(ref);
   Magic1      = generateID(ref);
   Magic2      = generateID(ref);
   Magic3      = generateID(ref);
   Magic4      = generateID(ref);
   Magic5      = generateID(ref);
   Magic6      = generateID(ref);
   Magic7      = generateID(ref);
   Magic8      = generateID(ref);
   Magic9      = generateID(ref);
   Magic10     = generateID(ref);
   Magic11     = generateID(ref);
   Magic12     = generateID(ref);
   Magic13     = generateID(ref);
   Magic14     = generateID(ref);
   Magic15     = generateID(ref);
   Magic16     = generateID(ref);
   Magic17     = generateID(ref);
   Magic18     = generateID(ref);
   Magic19     = generateID(ref);
   Magic20     = generateID(ref);
   Magic21     = generateID(ref);
   Magic22     = generateID(ref);
   Magic23     = generateID(ref);
   Magic24     = generateID(ref);
   Magic25     = generateID(ref);
   DebugPrint("Magic Number assigned");
}

void CTrade::OrderSendError(string ordertype){
   string NewLine = "\n", sInput  = "%s", space = " ";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,space,
                                             NewLine,sInput," order failed!",space,
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void CTrade::ModifyError(int ticket){
   string NewLine = "\n", sInput  = "%s", space = " ";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,space,
                                             NewLine,"Order ticket #%d modify failed!",space,
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ticket,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void CTrade::OrderCloseError(int ticket, string action){
   string NewLine = "\n", sInput  = "%s", space = " ";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,space,
                                             NewLine,"Order ticket #%d failed to ",sInput,space,
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
   Print(acc);
   SendNotificationFunction(acc);
   ResetLastError();
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

void CFeatures::HiddenSL(int magic, int stopPoint){
   if(Count.OrderAllTrade(magic)>0 && stopPoint>0) {
      double   bufferSL = NumToPoint(stopPoint);
      double   stopLoss;
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
            bool ChkCondition = false;
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            double sl_buy = tick.bid;
            double sl_sell = tick.ask;
            if(!SpreadFilterPair()) {
               sl_buy = tick.ask;
               sl_sell = tick.bid;
            }
            
            if(OrderType()==OP_BUY) {
               stopLoss = OrderOpenPrice() - bufferSL;
               if(sl_buy<=stopLoss) ChkCondition = true;
            }
            else if(OrderType()==OP_SELL){
               stopLoss = OrderOpenPrice() + bufferSL;
               if(sl_sell>=stopLoss) ChkCondition = true;
            }
            if(ChkCondition) Trade.CloseOrder(magic);
         }
      }
   }
}

void CFeatures::HiddenTP(int magic, int takePoint){
   if(Count.OrderAllTrade(magic)>0 && takePoint>0) {
      double   bufferTP = NumToPoint(takePoint);
      double   takeProfit;
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
            bool ChkCondition = false;
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
   if(Count.OrderAllTrade(magic)>0 && takePoint>0) {
      double bufferTP = NumToPoint(takePoint);
      double takeProfit;
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
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
   if(Count.OrderAllTrade(magic)>0 && (pPriceSL>0 || pPriceTP>0)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {
            bool ChkCondition = false;
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            double sl_buy = tick.bid;
            double sl_sell = tick.ask;
            if(!SpreadFilterPair()) {
               sl_buy = tick.ask;
               sl_sell = tick.bid;
            }
            if(OrderType()==OP_BUY) {
               if((pPriceTP>0 && tick.bid>=pPriceTP) || (pPriceSL>0 && sl_buy<=pPriceSL)) ChkCondition = true; 
            }
            else if(OrderType()==OP_SELL) {
               if((pPriceTP>0 && tick.ask<=pPriceTP) || (pPriceSL>0 && sl_sell>=pPriceSL)) ChkCondition = true;
            }
            if(ChkCondition) Trade.CloseOrder(magic);
         }
      }
   }
}

void CFeatures::BreakEven(int magic, int distance, int lock = 10){
   if(Count.OrderAllTrade(magic)>0 && distance>lock && lock>=0) {
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

void CFeatures::BreakEvenTicket(int ticket, int distance, int lock = 10){
   if(distance>lock && lock>=0) {
      if(OrderSelect(ticket, SELECT_BY_TICKET)) {
         double TrailingLevel,LockBE;
         double buffer_distance = NumToPoint(distance);
         double buffer_lock = NumToPoint(lock);
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         if(OrderType() == OP_SELL){
             TrailingLevel = OrderOpenPrice() - buffer_distance;
             LockBE = OrderOpenPrice() - buffer_lock;
             if(tick.ask<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) Trade.ModifyStopLossTicket(ticket,LockBE);
         }
         else if(OrderType() == OP_BUY){
            TrailingLevel = OrderOpenPrice() + buffer_distance;
            LockBE = OrderOpenPrice() + buffer_lock;
            if(tick.bid>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) Trade.ModifyStopLossTicket(ticket,LockBE);
         }
      }
   }
}

void CFeatures::TrailingStop(int magic, int distance, int step = 10){
   if(Count.OrderAllTrade(magic)>0 && distance>step && step>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic) && OrderStopLoss()>0) {
            double TrailingLevel,StepLevel;
            double buffer_distance = NumToPoint(distance);
            double buffer_step = NumToPoint(step);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(OrderType() == OP_SELL) {
               if(OrderStopLoss()<=OrderOpenPrice()){
                  TrailingLevel = OrderStopLoss() - buffer_distance;
                  StepLevel     = OrderStopLoss() - buffer_step;
                  if(tick.ask<TrailingLevel) Trade.ModifyStopLoss(magic,StepLevel);
               }
            }
            else if(OrderType() == OP_BUY) {
               if(OrderStopLoss()>=OrderOpenPrice()){
                  TrailingLevel = OrderStopLoss() + buffer_distance;
                  StepLevel     = OrderStopLoss() + buffer_step;
                  if(tick.bid>TrailingLevel) Trade.ModifyStopLoss(magic,StepLevel);
               }
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
   if(Count.OrderAllTrade(magic)>0 && value>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic) && OrderStopLoss()>0) {
            double trailValue = NormPrice(value);
            if(StopLevel(trailValue)) {
               if(OrderType()==OP_SELL) {
                  if(OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()>value) Trade.ModifyStopLoss(magic,trailValue);
               }
               else if(OrderType()==OP_BUY) {
                  if(OrderStopLoss()>=OrderOpenPrice() && OrderStopLoss()<value) Trade.ModifyStopLoss(magic,trailValue);
               }
            }
         } 
      }
   }
}

void CFeatures::TrailingStop_Hidden(int magic, int distance, int step = 10){
   if(Count.OrderAllTrade(magic)>0 && distance>step && step>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic) && OrderStopLoss()>0) {
            double TrailingLevel,StepLevel;
            double buffer_distance = NumToPoint(distance);
            double buffer_step = NumToPoint(step);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            if(OrderType() == OP_SELL) {
               if(OrderStopLoss()<=OrderOpenPrice()){
                  TrailingLevel = OrderStopLoss() - buffer_distance;
                  StepLevel     = OrderStopLoss() - buffer_step;
                  if(tick.ask<TrailingLevel) DrawShortHLine("HiddenTrailing",StepLevel,STYLE_DASHDOT,clrRed,1);
               }
            }
            else if(OrderType() == OP_BUY) {
               if(OrderStopLoss()>=OrderOpenPrice()){
                  TrailingLevel = OrderStopLoss() + buffer_distance;
                  StepLevel     = OrderStopLoss() + buffer_step;
                  if(tick.bid>TrailingLevel) DrawShortHLine("HiddenTrailing",StepLevel,STYLE_DASHDOT,clrRed,1);
               }
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

void CFeatures::ProtectingTarget(int magic, double TP_Level = 0, int trigger = 20, int lock = 20) {
   if(Count.OrderAllTrade(magic)>0) {
      int type             = Property.type(magic);
      double SL            = Property.stopLoss(magic);
      double TP            = Property.takeProfit(magic);
      double OP            = Property.openPrice(magic);
      double dis_trigger   = NumToPoint(trigger);
      double dis_lock      = NumToPoint(lock)+Market_StopFreeze;
      double TriggerSL,triggerLvl;

      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(TP>0) {
         if(type==OP_BUY) {
            triggerLvl = TP-dis_trigger;
            if(TP>OP && tick.ask>triggerLvl) {
               TriggerSL = tick.bid-dis_lock;
               if(SL<TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
            }
         }
         else if(type==OP_SELL) {
            triggerLvl = TP+dis_trigger;
            if(TP<OP && tick.bid<triggerLvl) {
               TriggerSL = tick.ask+dis_lock;
               if(SL>TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
            }
         }
      }
      
      if(TP_Level>0) {
         double buffer     = dis_trigger*2;
         bool checkrange   = BetweenPriceRange(TP_Level+buffer,TP_Level-buffer);
         if(checkrange) {
            if(type==OP_BUY) {
               triggerLvl = TP-dis_trigger;
               if(TP_Level>OP && tick.ask>triggerLvl) {
                  TriggerSL = tick.bid-dis_lock;
                  if(SL<TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
               }
            }
            else if(type==OP_SELL) {
               triggerLvl = TP+dis_trigger;
               if(TP_Level<OP && tick.bid<triggerLvl) {
                  TriggerSL = tick.ask+dis_lock;
                  if(SL>TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
               }
            }
         }
      }
   }
}

void CFeatures::ProtectingTargetScalp(int magic, int lock = 10) {
   if(Count.OrderAllTrade(magic)>0) {
      int type             = Property.type(magic);
      double SL            = Property.stopLoss(magic);
      double init_lock     = NumToPoint(lock*4);
      double init_buffer   = NumToPoint(20);
      double dis_lock      = NumToPoint(lock)+Market_StopFreeze;
      double InitTrigger,TriggerSL;

      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(type==OP_BUY) {
         InitTrigger = tick.bid-init_lock;
         if(SL<InitTrigger-init_buffer || SL==0) Trade.ModifyStopLoss(magic,InitTrigger);
         else {
            TriggerSL   = tick.bid-dis_lock;
            if(SL<TriggerSL) Trade.ModifyStopLoss(magic,TriggerSL);
         }
      }
      else if(type==OP_SELL) {
         InitTrigger = tick.ask+init_lock;
         if(SL>InitTrigger+init_buffer || SL==0) Trade.ModifyStopLoss(magic,InitTrigger);
         else {
            TriggerSL = tick.ask+dis_lock;
            if(SL>TriggerSL) Trade.ModifyStopLoss(magic,TriggerSL);
         }
      }
   }
}
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

int CProp::ticket(int magic){   
   int type = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(Select.Magic(order,magic)) type = OrderTicket();
   }
   return type;
}

double CProp::stopLoss(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) ChkLevel = OrderStopLoss();  
   }
   return ChkLevel;
}

string CProp::symbol(int magic){
   string x = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) x = OrderSymbol();  
   }
   return x;
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

double CProp::orderLotHedge(int magic, int type){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic) && OrderType()==type) lot += OrderLots();  
   }
   return lot;
}

double CProp::currentOrderLot(int direction) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && OrderType()==direction) x += OrderLots();  
   }
   return x;
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

string CProp::comment(int magic){
   string comment = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.Magic(order,magic)) comment = OrderComment();  
   }
   return comment;
}

bool CProp::justClose(int magic, int minutesAgo = 1){
   bool x = false;
   datetime time = -1;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*PeriodSeconds(PERIOD_M1));
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(Select.MagicTrade(order,magic,MODE_HISTORY) && Select.ThisEA() && OrderCloseTime()>HistoryRange && OrderCloseTime()>time) x = true;
   }
   return x;
}

void CProp::lastClosedOrder(int& type, int& ticket, double& lot, double& openPrice, double& closePrice, double& profit, double& nettPnl) {
   int      temp_type         = 100,
            temp_ticket       = WRONG_VALUE;
   double   temp_lot          = 0,
            temp_openPrice    = 0,
            temp_closePrice   = 0,
            temp_profit       = 0,
            temp_nettPnl      = 0;
   datetime time              = -1,
            HistoryRange      = TimeCurrent()-(10*PeriodSeconds(PERIOD_D1));
            
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(Select.SymbolTrade(order,MODE_HISTORY) && Select.ThisEA() && OrderCloseTime()>HistoryRange && OrderCloseTime()>time) {
         temp_ticket = OrderTicket();
         temp_lot = OrderLots();
         temp_type = OrderType();
         temp_openPrice = OrderOpenPrice();
         temp_closePrice = OrderClosePrice();
         temp_profit = OrderProfit();
         temp_nettPnl = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   
   type = temp_type;
   ticket = temp_ticket;
   lot = temp_lot;
   openPrice = temp_openPrice;
   closePrice = temp_closePrice;
   profit = temp_profit;
   nettPnl = temp_nettPnl;
}

void CProp::newestOrder(int& type, double& lot, double& price, double& profit, double& nettPnl) {
   int      temp_type         = 100;
   double   temp_lot          = 0,
            temp_price        = 0,
            temp_profit       = 0,
            temp_nettPnl      = 0;
   datetime time              = -1;
   
   for(int order = 0; order <= OrdersTotal()-1; order++) {
      if(Select.SymbolTrade(order) && Select.ThisEA() && OrderOpenTime()>time) {
         temp_lot = OrderLots();
         temp_type = OrderType();
         temp_price = OrderOpenPrice();
         temp_profit = OrderProfit();
         temp_nettPnl = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   
   type = temp_type;
   lot = temp_lot;
   price = temp_price;
   profit = temp_profit;
   nettPnl = temp_nettPnl;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double CGeneral::TotalLotSymbol(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order)) lot += OrderLots();
   }
   return lot;
}

double CGeneral::HighestOrderLot(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && Select.ThisEA() && OrderLots()>lot) lot = OrderLots();
   }
   return lot;
}

double CGeneral::Sell_LowestSL(){
   double sl = DBL_MAX;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && Select.ThisEA() && OrderType()==OP_SELL && OrderStopLoss()>0 && OrderStopLoss()<sl) sl = OrderStopLoss();
   }
   if(sl==DBL_MAX) return 0;
   else return sl;
}

double CGeneral::Buy_HighestSL(){
   double sl = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && Select.ThisEA() && OrderType()==OP_BUY && OrderStopLoss()>0 && OrderStopLoss()>sl)  sl = OrderStopLoss();
   }
   return sl;
}

double CGeneral::HighestOrderPrice() {
   double price[];
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.SymbolAll(order) && Select.ThisEA()) {
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
      if(Select.SymbolAll(order) && Select.ThisEA()) {
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
      if(Select.SymbolTrade(order,MODE_HISTORY) && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

double CGeneral::dirOrderLot(int direction) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order) && Select.ThisEA() && OrderType()==direction) x += OrderLots(); 
   }
   return x;
}

double CGeneral::averagePrice() {
   double x = 0,lot = 0, total = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order) && Select.ThisEA()) {
         x += OrderOpenPrice()*OrderLots();
         lot += OrderLots();
      }
   }
   
   if(lot>0) total = NormPrice(x/lot);
   return total;
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

double CGeneral::AllOrderAvgPrice() {
   double x = 0;
   double lot = 0;
   double total = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order)) {
         x += OrderOpenPrice()*OrderLots();
         lot += OrderLots();
      }
   }
   
   if(lot>0) total = x/lot;
   return total;
}

double CGeneral::dirLot(int type) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolAll(order) && OrderType()==type) x += OrderLots(); 
   }
   return x;
}

double CGeneral::hedgeCalc(double val, double total, double avg) {
   double multiplier = Market_ContractSize/Acc_Leverage;
   double a = val*2;
   double b = a*avg*multiplier*Market_MarginHedge;
   double c = (total-a)*avg*multiplier;
   return b+c;
}

double CGeneral::MarginUsed() {
   double x = 0;
   
   if(General.TotalLotSymbol()>0) {
      double buy = dirLot(OP_BUY);
      double sell = dirLot(OP_SELL);
      double multiplier = Market_ContractSize/Acc_Leverage;
      
      double avg = AllOrderAvgPrice();
      if(SymbolCurr2!=Acc_Currency) avg = Money.getReferencePrice()-NumToPoint(1*Acc_Pips);
      
      if(buy>0 && sell>0) {
         double hedge = Market_MarginHedge;
         double total = buy+sell;
         if(StringLot(buy)==StringLot(sell)) x = ((avg*(buy*2)*Market_ContractSize)/Acc_Leverage)*hedge;
         else {
            if(buy>sell) x = hedgeCalc(sell,total,avg);
            else if(buy<sell) x = hedgeCalc(buy,total,avg);
         }
      }
      else if(buy>0) x = buy*avg*multiplier;
      else if(sell>0) x = sell*avg*multiplier;
   }
   return NormDollar(x);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
double CReport::Closed_Daily(){
   double PnL = 0;
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(Select.TradeHistory(order,PERIOD_D1,2) && TimeDay(OrderCloseTime())==Day())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::Closed_Monthly(){
   double PnL = 0;
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(Select.TradeHistory(order,PERIOD_D1,32) && TimeMonth(OrderCloseTime())==Month())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::Closed_Weekly(){
   double PnL = 0;
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(Select.TradeHistory(order,PERIOD_D1,8) && ChkWeek(OrderCloseTime())==StdWeek())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::TradePL(int magic){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.MagicTrade(order,magic)) PnL += OrderProfit()+OrderCommission()+OrderSwap(); 
   }
   return NormDollar(PnL);
}

double CReport::FloatingStatusSymbol(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.SymbolTrade(order)) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double CReport::FloatingStatusTerminal(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(Select.TerminalTrade(order)) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double CReport::TradeHistoryPL(int magic, int dayHistory = 30){
   double PnL = 0;
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(Select.TradeHistory(order,PERIOD_D1,dayHistory) && TimeDay(OrderCloseTime())==Day())
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
   ChartSetSymbolPeriod(0,_Symbol,0);
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

void ObjectDrawDelete(string objIdentifier, string name) {
   ObjectDelete(0,objIdentifier+name);
}

/*
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
*/

void ChartHistory(string symbol = NULL) {
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
      SleepSeconds(5); 
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

datetime ServerDate(int pYear = 0, int pMonth = 0, int pDay = 0) {
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
   // https://www.timeanddate.com/time/change/uk/london
   int x = 0;
   if(BetweenTimeRange(ServerDate(2018,10,28),ServerDate(2019,3,31))) x = -1;
   else if(BetweenTimeRange(ServerDate(2019,10,27),ServerDate(2020,3,29))) x = -1;
   else if(BetweenTimeRange(ServerDate(2020,10,25),ServerDate(2021,3,28))) x = -1;
   return x;
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
      thisMinStart   = 60;
      thisHourStart -= 1;
   }
   else if(minutes==59) {
      thisMinEnd     = 0;
      if(hour==23) thisHourEnd = 0;
      else thisHourEnd += 1;
   }
   return compare>=HourMin(thisHourStart,thisMinStart-1) && compare<=HourMin(thisHourEnd,thisMinEnd+1);
}

bool TradeTiming(int pStartH, int pStartM, int pEndH, int pEndM) {
   datetime time1 = HourMin(pStartH,pStartM);
   datetime time2 = HourMin(pEndH,pEndM);
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

void SendFTPFunction(string filename, string filepath = NULL) {
   if(LiveOperation() && TerminalInfoInteger(TERMINAL_FTP_ENABLED)) SendFTP(filename,filepath);
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

void DebugPrint(string msg) {
   Print(__FILE__+" "+Market_Symbol+" >> "+msg+".");
}

/*
bool CTrade::multiple_closeby_symbol() {
   double lot = 0;
   for(int i=OrdersTotal()-1; i>0; i--){
      if(Select.SymbolTrade(i) && Select.ThisEA() && OrderLots()>lot) {
         ulong  ul=0, ul_res=0;
         ul = GetMicrosecondCount();
         int    first_ticket = OrderTicket();
         int    first_type   = OrderType();
         for(int j=i; j>=0; j--){
            if(Select.TradeHedging(j,first_type) && Select.ThisEA()) {
               bool closeorder = false;
               int ticket2 = OrderTicket();
               ServerCheck();
               closeorder = OrderCloseBy(first_ticket,OrderTicket(),clrPink);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  msString("closedby",ul_res,OrderTicket());
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
*/

int RandomSpreadtester() {
   int x = 0;
   int min = -10;
   int max = 3;
   x = min + (max - min + 1) * rand() / 32768;
   return x;
}