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
#property description   "Hedger"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define RETRY_DELAY        2000
#define MAXRISK            10
#define MAX_RETRIES        3
#define IDENTIFIER_TRADE   94444

class CCount {
   public:
      int OrderAll(int magic);
      int OrderTradeSymbol(int type);
      int ThisEACount();
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
      bool OrderExist(int magic);
      bool NewOrderChk(string orderType, int type, double lot, string& retMsg);
      void OpenOrder(int type, int magic, double lot, string comment);
   public: 
      bool SessionTrade();
      string SignalComment(int sig);
      string SignalDirection(int sig);
      void OrderCloseReason(string reason, ulong countdown);
      void DebugCloseReason(string reason);
      void DebugInitialized();
      void AssignMagic(int identifier);
      void OpenBuy(int magic, double lot, string comment);
      void OpenSell(int magic, double lot, string comment);
      void CloseOrder(int magic);
      void CloseOrderBySameLot(int magic1, int magic2);
      void CloseOrderByDifferentLot();
      bool multiple_closeby_symbol();

}Trade;

class CMoney {
   public:
      double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0);
      double MarginUsed(double entryPrice, double lotsize);
      double refPrice();
}Money;

class CGeneral {
   public:
      int OrderCommissionChk();
      int HighestLotDirection();
      double TotalLotSymbol();
      
      double HighestOrderPrice();
      double LowestOrderPrice();
      double HighestOrderLot(int type);
      double dirOrderLot(int direction);
      double averagePrice();
      int avgDailyRange(int range = 30, int startbar = 0);
}General;

class CReport {
   public:
      double FloatingStatusAll();
      double TradePL(int magic);
      double Closed_DailySymbol(ENUM_TIMEFRAMES timeframe);
      double Closed_Daily();
}Report;

class CProp {
   public:
      int ticket(int magic);
      int type(int magic);
      double orderLot(int magic);
      double openPrice(int magic);
      datetime openTime(int magic);
      double orderSwap(int magic);
      double orderComm(int magic);
      int newestOrder();
}Property;

// --- Input Variable ------------------------------------------------------------------
input bool ActivateEA = true;

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
const int   Allowed_Accounts[]   = {924635,250197595,250197573,250116829,9414694};
bool        orderFour            = false;
string      ObjIdentifier        = "EAX_";
int         MAXSPREAD            = 30,
            gridDistance         = 100,
            gridRepeat           = 60,
            minTP                = 20;
int         Magic1,Magic2,Magic3,Magic4,Magic5,Magic6,Magic7,Magic8,Magic9,Magic10,MagicX;

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
   if(!AllowedSymbol() || !AccountPermission()) return INIT_FAILED;
   if(Market_Symbol=="GBPCAD") {
      gridDistance   = 120;
      gridRepeat     = 70;
      minTP          = 60;
   }
   else if(SymbolCurr2=="JPY") minTP = 50;
   
   // Assigning Magic Number and Property
   Trade.AssignMagic(IDENTIFIER_TRADE);
   ul_res = GetMicrosecondCount()-ul;
   msString("Expert initilized",ul_res);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(getUninitReasonText(_UninitReason));
   reportReason(_UninitReason);
   s_id = 0;
}

void OnTick(){
   AllowTrading();
   ChartHistory();
   AccountParameter_Var();
   minimumBalance();
   
   // Close order based on condition
   FBS2000_Close();
   Friday_Close();
   LowMarginRecovery();
   
   // Sequence order start
   ManagingOrder();
   SequenceOrderNext();
   ulong test;
   if(Count.OrderAll(Magic1)==0 && Count.ThisEACount()>0) thisEACloseAll("Clear Order",test);
   if(NewBar(PERIOD_M5)) SequenceOrderFirst();
   
   DrawTarget();
   int todayRange = PointToInt(iHigh(_Symbol,PERIOD_D1,0) - iLow(_Symbol,PERIOD_D1,0));
   int yesterdayRange = PointToInt(iHigh(_Symbol,PERIOD_D1,1) - iLow(_Symbol,PERIOD_D1,1));

   Comment(
   "\n\n D1 Signal : ",Trade.SignalComment(HeikinAshi(PERIOD_D1,2))," --> ",Trade.SignalComment(HeikinAshi(PERIOD_D1)),
   "\n\n H1 Signal : ",Trade.SignalComment(HeikinAshi(PERIOD_H1,2))," --> ",Trade.SignalComment(HeikinAshi(PERIOD_H1)),
   "\n\n M15 Signal : ",Trade.SignalComment(HeikinAshi(PERIOD_M15,2))," --> ",Trade.SignalComment(HeikinAshi(PERIOD_M15)),
   "\n\n M5 Signal : ",Trade.SignalComment(HeikinAshi(PERIOD_M5,2))," --> ",Trade.SignalComment(HeikinAshi(PERIOD_M5)),
   "\n\n Distance High-Low : ",PointToInt(General.HighestOrderPrice()-General.LowestOrderPrice()),
   "\n\n Avg Daily Range : ",IntegerProper(General.avgDailyRange()),
   "\n\n LW Daily Range : ",IntegerProper(LWAvg()),
   "\n\n Today Daily Range : ",IntegerProper(todayRange),
   "\n\n Yesterday Daily Range : ",IntegerProper(yesterdayRange),
   "\n\n Session : ",Trade.SessionTrade(),
   "\n\n"
   "\n\n Direction : ",Trade.SignalDirection(Property.newestOrder()),
   "\n\n Today's Closed PnL : ",StringDollar(Report.Closed_DailySymbol(PERIOD_D1)),
   "\n\n Margin Used : ",StringDollar(HedgeMargin()),
   "\n\n Minimum Profit : ",StringDollar(minProfittoClose()),
   "\n\n Est Max Profit : ",StringDollar(EstMaxProfit()),
   "\n\n Floating : ",StringDollar(Report.FloatingStatusAll()),
   "\n\n Order Status : ",OrderStatus(),
   "\n\n"
   "\n\n Lot Buy : ",StringLot(General.dirOrderLot(OP_BUY)),
   "\n\n Lot Sell : ",StringLot(General.dirOrderLot(OP_SELL)),
   "\n\n Lot Diff : ",StringLot(fabs(General.dirOrderLot(OP_BUY)-General.dirOrderLot(OP_SELL))),
   "\n\n"
   "\n\n MC-SO : ",Acc_MarginCall,"-",Acc_StopOut
   );   
}

void DrawTarget() {
   if(maxClosePrice()>0) HLine("Target",maxClosePrice(),STYLE_DOT,clrWhite,1);
   else {
      ObjectDrawDelete(ObjIdentifier,"Target");
      ObjectDrawDelete(ObjIdentifier,"Target_Price");
   }
}

double EstMaxProfit() {
   double x = 0;
   double level = maxClosePrice();
   
   if(level>0) {
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
   
      x += EstPnL(Magic1,level,tick.bid,tick.ask);
      x += EstPnL(Magic2,level,tick.bid,tick.ask);
      x += EstPnL(Magic3,level,tick.bid,tick.ask);
      x += EstPnL(Magic4,level,tick.bid,tick.ask);
      x += EstPnL(Magic5,level,tick.bid,tick.ask);
      x += EstPnL(Magic6,level,tick.bid,tick.ask);
      x += EstPnL(Magic7,level,tick.bid,tick.ask);
      x += EstPnL(Magic8,level,tick.bid,tick.ask);
      x += EstPnL(Magic9,level,tick.bid,tick.ask);
      x += EstPnL(Magic10,level,tick.bid,tick.ask);
   }
   return x;
}

string OrderStatus() {
   string x = "No order";
   string method = "Single";
   int count = 0;
   
   if(Count.OrderAll(Magic1)>0) {
      method = "Single";
      count = Count.ThisEACount();
      if(Count.OrderAll(Magic2)>0) {
         double lot1 = Property.orderLot(Magic1);
         double lot2 = Property.orderLot(Magic2);
         
         if(sameLot(lot1,lot2)) method = "Method 1";
         else method = "Method 2";
      }
   }
   
   if(count>0) x = method+": "+IntegerToString(count)+" order(s)";
   return x;
}

double EstPnL(int magic, double level, double bid, double ask) {
   double x = 0;
   if(Count.OrderAll(magic)>0 && level>0) {
      int dist;
      double tot;
      int dir = Property.type(magic);
      double tickVal = Market_TickValue;
      double op = Property.openPrice(magic);
      double lot = Property.orderLot(magic);
      double associate = Property.orderComm(magic)+Property.orderSwap(magic);
      
      if(ask<level) {
         if(dir==OP_BUY) {
            dist = PointToInt(fabs(level-op));
            tot = dist*tickVal*lot;
            x = tot+associate;
         }
         else if(dir==OP_SELL) {
            dist = PointToInt(fabs(level-op))+Market_Spread;
            tot = dist*tickVal*lot;
            x = -tot+associate;
         }
      }
      else if(bid>level) {
         if(dir==OP_BUY) {
            dist = PointToInt(fabs(level-op))+Market_Spread;
            tot = dist*tickVal*lot;
            x = -tot+associate;
         }
         else if(dir==OP_SELL) {
            dist = PointToInt(fabs(level-op));
            tot = dist*tickVal*lot;
            x = tot+associate;
         }
      }
   }
   return NormDollar(x);
}

void SequenceOrderFirst() {
   if(noOrder()) {
      int signal = TradeSignal();
      FirstOrder(signal);
   }
}

bool noOrder() {
   return 
   Count.OrderAll(Magic1)==0 && Count.OrderAll(Magic2)==0 && 
   Count.OrderAll(Magic3)==0 && Count.OrderAll(Magic4)==0 && 
   Count.OrderAll(Magic5)==0 && Count.OrderAll(Magic6)==0 && 
   Count.OrderAll(Magic7)==0 && Count.OrderAll(Magic8)==0 &&
   Count.OrderAll(Magic9)==0 && Count.OrderAll(Magic10)==0;
}

void LowMarginRecovery() {
   double pnl = Report.FloatingStatusAll();
   
   if(pnl>0) {
      double minimumProfit = 0.9;
      if(Count.OrderAll(Magic2)>0) {
         double lot1 = Property.orderLot(Magic1);
         double lot2 = Property.orderLot(Magic2);
         if(sameLot(lot1,lot2)) minimumProfit = fmax(lot1*2,lot2)*gridDistance*1.11;
      }
      if(pnl>=minimumProfit) {
         datetime ot = Property.openTime(Magic1);
         bool limit = TimeCurrent()>=ot+(16*PeriodSeconds(PERIOD_H1));
         int marginLvl = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
         
         if(limit) funcCloseAll("Exceeding hours.");
         else if(Count.OrderAll(Magic4)>0 && marginLvl<=500) funcCloseAll("Low Margin \nMin Profit : "+StringDollar(minimumProfit));
      }
   }
}

bool sameLot(double a, double b) {
   return StringLot(a)==StringLot(b);
}

void Managing_Recovery(int direction) {
   bool injectNew = false;
   int tempSig = 100;
   double pnl = Report.FloatingStatusAll();

   if(pnl>=0 && SpreadFilterPair()) {
      int h1First = HAColor(PERIOD_H1);
      bool sigSwitch = SwitchSignal(direction,h1First);
      
      if(Count.OrderAll(Magic2)==0 && sigSwitch) {
         ulong  ul=0, ul_res=0;
         ul = GetMicrosecondCount();
         Trade.CloseOrder(Magic1);
         ul_res = GetMicrosecondCount()-ul;
         if(noOrder()) {
            string msg = "Single Order.";
            Trade.OrderCloseReason(msg,ul_res);
         }
      }
      else if(Count.OrderAll(Magic2)>0) {
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         double op1 = Property.openPrice(Magic1);
         double op2 = Property.openPrice(Magic2);
         double upper = fmax(op1,op2);
         double lower = fmin(op1,op2);
         
         if(OutsidePriceRange(upper,lower)) {
            double minus = MAXSPREAD;
            if(Market_Spread<MAXSPREAD) minus = Market_Spread;
            int minVal = fmin(General.avgDailyRange(),LWAvg());
            double margin = NumToPoint(minVal/2)-NumToPoint(minus);
            bool limitReach = OutsidePriceRange(upper+margin,lower-margin);

            if(sigSwitch || limitReach)  {
               double lot1 = Property.orderLot(Magic1);
               double lot2 = Property.orderLot(Magic2);
               
               if(Count.OrderAll(Magic3)==0 && sameLot(lot1,lot2)) {
                  string res = "Limit Reach";
                  if(sigSwitch) res = "Candle Swich";
                  funcCloseAll("Hedging - Same lot "+res);
                  double repeat = NumToPoint(gridRepeat);
                  if(BetweenPriceRangeAskBid(upper,upper+repeat) || BetweenPriceRangeAskBid(lower,lower-repeat)) { 
                     injectNew = true;
                     tempSig = h1First;
                  }
               }
               else {
                  double minProfit = minProfittoClose();
                  if(pnl>=minProfit) {
                     double newMin = minProfit*1.118; 
                     double pnlX = Report.TradePL(Magic1);
                     int d1 = HeikinAshi(PERIOD_D1);
                     int d2 = HeikinAshi(PERIOD_D1,2);
                     
                     if(direction==d1 && pnlX>0) {                       
                        if(limitReach) funcCloseAll("Hedging - Direct Limit.");
                        else {
                           newMin = minProfit*1.238;  
                           if(d1==d2) newMin = fmax(EstMaxProfit()/2.0,minProfit*1.382); 
                           if(pnl>=newMin) funcCloseAll("Hedging - Direct Switch \nMin Profit : "+StringDollar(newMin));
                        }
                     }
                     else {
                        if(limitReach) funcCloseAll("Hedging - Reverse Limit.");
                        else {
                           string di = "Sell";
                           if(tick.bid>upper) {
                              newMin = minProfit*1.238;
                              di = "Buy";
                           }
                           if(pnl>=newMin) funcCloseAll("Hedging - Reverse Switch "+di+" \nMin Profit : "+StringDollar(newMin));
                        }
                     }
                  }
               }
            }
         }
      }
   }
   
   if(injectNew && noOrder()) FirstOrder(tempSig,true);
}

double minProfittoClose() {
   double x = 0.8;
   if(Count.OrderAll(Magic2)>0) {
      double lotDiff = fabs(General.dirOrderLot(OP_BUY)-General.dirOrderLot(OP_SELL));
      double minProfit = lotDiff*minTP;
      if(minProfit>x) x = minProfit;
   }
   return x;
}

double maxClosePrice() {
   double x = 0;
   if(Count.OrderAll(Magic2)>0) {
      double minus = MAXSPREAD;
      if(Market_Spread<MAXSPREAD) minus = Market_Spread;
      int minVal = fmin(General.avgDailyRange(),LWAvg());
      double margin = NumToPoint(minVal/2)-NumToPoint(minus);
      
      double op1 = Property.openPrice(Magic1);
      double op2 = Property.openPrice(Magic2);
      double upper = fmax(op1,op2);
      double lower = fmin(op1,op2);
      
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      
      if(tick.bid>upper) x = upper+margin;
      else if(tick.ask<lower) x = lower-margin;
   }
   return x;
}

void ManagingOrder() {
   if(Count.OrderAll(Magic1)>0) {
      int dir1 = Property.type(Magic1);
      Managing_Recovery(dir1);
   }
}

void SequenceOrderNext() { 
   if(Count.OrderAll(Magic1)>0 && Count.OrderAll(Magic9)==0) {
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      int dir1 = Property.type(Magic1);
      double op1 = Property.openPrice(Magic1);
      double buffer  = NumToPoint(gridDistance);
      double missTrain = NumToPoint(50);
      double multiplier = 2;
      string comment = Market_Symbol+"_M";
      
      if(Count.OrderAll(Magic2)>0) {
         double op2  = Property.openPrice(Magic2);
         double lot1 = Property.orderLot(Magic1);
         double lot2 = Property.orderLot(Magic2);
         int method = 1;
         
         if(DoubleToString(lot1,2)!=DoubleToString(lot2,2)) method = 2;
         
         int count10 = Count.OrderAll(Magic10);
         int count9 = Count.OrderAll(Magic9);
         int count8 = Count.OrderAll(Magic8);
         int count7 = Count.OrderAll(Magic7);
         int count6 = Count.OrderAll(Magic6);
         int count5 = Count.OrderAll(Magic5);
         int count4 = Count.OrderAll(Magic4);
         int count3 = Count.OrderAll(Magic3);
         
         bool order10 = count9>0 && count10==0;
         bool order9 = count8>0 && count9==0;
         bool order8 = count7>0 && count8==0;
         bool order7 = count6>0 && count7==0;
         bool order6 = count5>0 && count6==0;
         bool order5 = count4>0 && count5==0;
         bool order4 = count3>0 && count4==0;
         bool order3 = count3==0;
         
         if(method==1) {
            if(dir1==OP_BUY) {
               if(BetweenPriceRange(tick.bid,op2+missTrain,op2)) {
                  if(order10)     Buy(Magic10,lot1,multiplier,9,comment+"1-10");
                  else if(order8) Buy(Magic8,lot1,multiplier,7,comment+"1-8");
                  else if(order6) Buy(Magic6,lot1,multiplier,5,comment+"1-6");
                  else if(order4) Buy(Magic4,lot1,multiplier,3,comment+"1-4");
               }
               else if(BetweenPriceRange(tick.ask,op1,op1-missTrain)) {
                  if(order9)      Sell(Magic9,lot1,multiplier,8,comment+"1-9");
                  else if(order7) Sell(Magic7,lot1,multiplier,6,comment+"1-7");
                  else if(order5) Sell(Magic5,lot1,multiplier,4,comment+"1-5");
                  else if(order3) Sell(Magic3,lot1,multiplier,2,comment+"1-3");
               } 
            }
            else if(dir1==OP_SELL) {
               if(BetweenPriceRange(tick.ask,op2,op2-missTrain)) {
                  if(order10)     Sell(Magic10,lot1,multiplier,9,comment+"1-10");
                  else if(order8) Sell(Magic8,lot1,multiplier,7,comment+"1-8");
                  else if(order6) Sell(Magic6,lot1,multiplier,5,comment+"1-6");
                  else if(order4) Sell(Magic4,lot1,multiplier,3,comment+"1-4");
               }
               else if(BetweenPriceRange(tick.bid,op1+missTrain,op1)) {
                  if(order9)      Buy(Magic9,lot1,multiplier,8,comment+"1-9");
                  else if(order7) Buy(Magic7,lot1,multiplier,6,comment+"1-7");
                  else if(order5) Buy(Magic5,lot1,multiplier,4,comment+"1-5");
                  else if(order3) Buy(Magic3,lot1,multiplier,2,comment+"1-3");
               }
            }
         }
         else if(method==2) {
            if(dir1==OP_BUY) {
               if(BetweenPriceRange(tick.ask,op2,op2-missTrain)) {
                  if(order10)     Sell(Magic10,lot1,multiplier,9,comment+"2-10");
                  else if(order8) Sell(Magic8,lot1,multiplier,7,comment+"2-8");
                  else if(order6) Sell(Magic6,lot1,multiplier,5,comment+"2-6");
                  else if(order4) Sell(Magic4,lot1,multiplier,3,comment+"2-4");
               }
               else if(BetweenPriceRange(tick.bid,op1+missTrain,op1)) {
                  if(order9)      Buy(Magic9,lot1,multiplier,8,comment+"2-9");
                  else if(order7) Buy(Magic7,lot1,multiplier,6,comment+"2-7");
                  else if(order5) Buy(Magic5,lot1,multiplier,4,comment+"2-5");
                  else if(order3) Buy(Magic3,lot1,multiplier,2,comment+"2-3");
               }  
            }
            else if(dir1==OP_SELL) {
               if(BetweenPriceRange(tick.bid,op2+missTrain,op2)) {
                  if(order10)     Buy(Magic10,lot1,multiplier,9,comment+"2-10");
                  else if(order8) Buy(Magic8,lot1,multiplier,7,comment+"2-8");
                  else if(order6) Buy(Magic6,lot1,multiplier,5,comment+"2-6");
                  else if(order4) Buy(Magic4,lot1,multiplier,3,comment+"2-4");
               }
               else if(BetweenPriceRange(tick.ask,op1,op1-missTrain)) {
                  if(order9)      Sell(Magic9,lot1,multiplier,8,comment+"2-9");
                  else if(order7) Sell(Magic7,lot1,multiplier,6,comment+"2-7");
                  else if(order5) Sell(Magic5,lot1,multiplier,4,comment+"2-5");
                  else if(order3) Sell(Magic3,lot1,multiplier,2,comment+"2-3");
               }
            }
         }
      }
      else if(Count.OrderAll(Magic2)==0) {
         bool manage = OutsidePriceRange(op1+buffer,op1-buffer);
         if(manage) {
            int prevD1 = HeikinAshi(PERIOD_D1,2);
            double thisVal = NumToPoint(25);
            if(dir1==prevD1) thisVal = NumToPoint(40);
            int minVal = fmax(General.avgDailyRange(),LWAvg());
            double dailyMax = NumToPoint(int(minVal/10));
            double bufferMax = fmax(buffer+thisVal,dailyMax);
            bool proceed = false;
            
            double lot = Property.orderLot(Magic1);
            string commentExt = "1-2";
            if(dir1==OP_BUY) {
               if(tick.ask<=op1-buffer) {
                  lot = MartingaleLot(lot,multiplier,1);
                  commentExt = "2-2";
                  proceed = true;
               }
               else if(tick.bid>=op1+bufferMax) proceed = true;
               if(proceed) Trade.OpenSell(Magic2,lot,comment+commentExt);
            }
            else if(dir1==OP_SELL) {
               if(tick.bid>=op1+buffer) {
                  lot = MartingaleLot(lot,multiplier,1);
                  commentExt = "2-2";
                  proceed = true;
               }
               else if(tick.ask<=op1-bufferMax) proceed = true;
               if(proceed) Trade.OpenBuy(Magic2,lot,comment+commentExt);
            }
         }
      }
   }
}

double MartingaleLot(double lot, double multiplier, int level){
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double rawlot = lot*pow(multiplier,level);
   return VerifyLotMinMax(round(rawlot/step)*step);
}

bool SwitchSignal(int x, int y) {
   return ((x==OP_BUY && y==OP_SELL) || (x==OP_SELL && y==OP_BUY));
}

void FirstOrder(int signal, bool rep = false) {
   if(ActivateEA && signal<2 && FBS2000() && TradeTiming(1,0,23,0) && Friday_Filter()) {
      string comment = Market_Symbol+"_1";
      if(rep) comment = Market_Symbol+" (Repeat)";
      double lot = LiveAccountLot();
      double UseLot = VerifyLotMinMax(lot);
      int minMargin = minMarginLevel();

      if(MarginLevelProcced(minMargin)) {
         if(signal==OP_BUY) Trade.OpenBuy(Magic1,UseLot,comment);
         else if(signal==OP_SELL) Trade.OpenSell(Magic1,UseLot,comment);
      }
   }
}

int minMarginLevel() {
   int x = 2500;
   if(DayOfWeek()==FRIDAY || (DayOfWeek()==MONDAY && TimeCurrent()<HourMin(12,0))) x = 3000;
   else if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO) {
      int leverage = Acc_Leverage;
      double balance = Acc_Balance;
      if(leverage>1000 && balance<660)       x = 3000;
      else if(leverage>888 && balance<1000)  x = 3000;
      else if(leverage>300 && balance<1670)  x = 3000;
      else if(leverage>200 && balance<2570)  x = 3000;
      else if(leverage>100 && balance<3700)  x = 3000;
   }
   
   if(SymbolCurr1=="GBP") x += 500;
   
   return x;
}

bool FBS2000() {
   if(Acc_Leverage>1000 && Acc_Balance>=1950) return false;
   else return true;
}

void FBS2000_Close() {
   if(Acc_Leverage>1000) {
      if((Acc_Balance>=1990 || Acc_Equity>= 1995)) {
         funcCloseAll("Balance / Equity Limit.");
         ExpertRemove();
      }
   }
}

bool closingHedgeRequirement() {
   bool x = true;
   if(!MQLInfoInteger(MQL_TESTER)) {
      if(!Trade.SessionTrade()) x = false;
      else {
         string login = IntegerToString(Acc_Login);
         if(!SpreadFilterPair()) {
            if(NotiEnable) SendNotification("#"+login+" ("+Market_Symbol+") - Spread "+IntegerToString(Market_Spread));
            x = false;
         }
         if(IsTradeContextBusy()) {
            if(NotiEnable) SendNotification("#"+login+" ("+Market_Symbol+") - Server Busy");
            x = false;
         }
         if(!TerminalInfoInteger(TERMINAL_CONNECTED)) {
            if(NotiEnable) SendNotification("#"+login+" ("+Market_Symbol+") - Terminal not connected");
            x = false;
         }
      }
   }
   if(!x) Sleep(500);
   return x;
}

void funcCloseAll(string msg) {
   ulong coundown;
   thisEACloseAll(msg,coundown);
   if(noOrder()) Trade.OrderCloseReason(msg,coundown);
   else {
      string x = "Not all order(s) closed on"+_Symbol;
      Print(x);
      if(NotiEnable) SendNotification(x);
   }
}

void thisEACloseAll(string msg, ulong& ul_res) {
   ulong waitcount = 0;
   int sleepwait = 3000;
   bool wait = false;
   ulong  ul=0;
   ul_res=0;
   ul = GetMicrosecondCount();
   
   Trade.DebugInitialized();
   if(closingHedgeRequirement()) {
      if(Count.OrderAll(Magic1)==0) CloseAllTrade();
      else {
         if(Count.OrderAll(Magic2)>0) {
            double lot1 = Property.orderLot(Magic1);
            double lot2 = Property.orderLot(Magic2);
            if(sameLot(lot1,lot2) && Count.OrderAll(Magic3)==0) Trade.CloseOrderBySameLot(Magic1,Magic2);
            else {
               if(Acc_MarginLevel>=2500) {
                  int hedgingSignal = 100;
                  double hedgingLot = 0;
                  double lotbuy = General.dirOrderLot(OP_BUY);
                  double lotsell = General.dirOrderLot(OP_SELL);
                  
                  if(lotbuy>lotsell) {
                     hedgingSignal = OP_SELL;
                     hedgingLot = lotbuy - lotsell;
                  }
                  else if(lotbuy<lotsell) {
                     hedgingSignal = OP_BUY;
                     hedgingLot = lotsell - lotbuy;
                  }
                  
                  HedgingToClose(hedgingSignal,hedgingLot);
                  Sleep(sleepwait);
                  wait = true;

                  bool x = Trade.multiple_closeby_symbol();
                  if(x) {
                     string ttt = "Check hedge to close order on "+_Symbol;
                     Alert(ttt);
                     if(NotiEnable) SendNotification(ttt);
                  }
                  
               } // end multiple closebuy
               else Trade.CloseOrderByDifferentLot();
            }
         }
         if(Count.ThisEACount()>0) CloseAllTrade();
      }
   }
   else if(Trade.SessionTrade()) Trade.DebugCloseReason(msg);
   
   if(wait) waitcount = sleepwait;
   ul_res = GetMicrosecondCount()-ul-waitcount;
}

void HedgingToClose(int signal, double lot) {
   if(signal<2) {
      string comment = "HedgeToClose";
      if(signal==OP_BUY) Trade.OpenBuy(MagicX,lot,comment);
      else if(signal==OP_SELL) Trade.OpenSell(MagicX,lot,comment);
   }
}

void CloseAllTrade() {
   Trade.CloseOrder(MagicX);
   Trade.CloseOrder(Magic10);
   Trade.CloseOrder(Magic9);
   Trade.CloseOrder(Magic8);
   Trade.CloseOrder(Magic7);
   Trade.CloseOrder(Magic6);
   Trade.CloseOrder(Magic5);
   Trade.CloseOrder(Magic4);
   Trade.CloseOrder(Magic3);
   Trade.CloseOrder(Magic2);
   Trade.CloseOrder(Magic1);
}

int TradeSignal(){
   int x = 100;
   int dir = TradeDirection(PERIOD_D1);
   int sig = FirstSignal(PERIOD_H1);
   
   if(dir==OP_BUY && sig==OP_BUY) x = OP_BUY;
   else if(dir==OP_SELL && sig==OP_SELL) x = OP_SELL;
   
   return x;
}

int FirstSignal(ENUM_TIMEFRAMES timeframe) {
   int x = 100;
   int h1 = HeikinAshi(timeframe);
   int h1Prev = HeikinAshi(timeframe,2);
   
   bool buyCurrent = h1==OP_BUY||h1==OP_BUYSTOP;
   bool sellCurrent = h1==OP_SELL||h1==OP_SELLSTOP;
   bool buyPrev = h1Prev==OP_BUY||h1Prev==OP_BUYSTOP;
   bool sellPrev = h1Prev==OP_SELL||h1Prev==OP_SELLSTOP;
   
   if(buyCurrent && sellPrev) x = OP_BUY;
   else if(sellCurrent && buyPrev) x = OP_SELL;
   return x;
}

int HAColor(ENUM_TIMEFRAMES timeframe) {
   int x = 100;
   int h1 = HeikinAshi(timeframe);
   
   if(h1==OP_BUY||h1==OP_BUYSTOP) x = OP_BUY;
   else if(OP_SELL||h1==OP_SELLSTOP) x = OP_SELL;
   return x;
}

int TradeDirection(ENUM_TIMEFRAMES timeframe) {
   int x = 100;
   int dir = HeikinAshi(timeframe);
   if(dir==OP_BUY) x = OP_BUY;
   else if(dir==OP_SELL) x = OP_SELL;
   return x;
}

int HeikinAshi(ENUM_TIMEFRAMES timeframe, int bar = 1) { 
   double HA_Open,HA_High,HA_Low,HA_Close;
   double HA_Open2,HA_High2,HA_Low2,HA_Close2;
   HA(timeframe,bar,HA_Open,HA_High,HA_Low,HA_Close);
   HA(timeframe,bar+1,HA_Open2,HA_High2,HA_Low2,HA_Close2);

   int x = 100;
   if(HA_Close>HA_Open) {
      if(HA_Close>HA_Close2) x = OP_BUY;  // Strong Bullish
      else x = OP_BUYSTOP;                // Weak Bullish
   }
   else if(HA_Close<HA_Open) {
      if(HA_Close<HA_Close2) x = OP_SELL; // Strong Bearish
      else x = OP_SELLSTOP;               // Weak Bearish
   }
   return x;
}

void HA(ENUM_TIMEFRAMES timeframe, int bar, double& HA_Open, double& HA_High, double& HA_Low, double& HA_Close) { 
   HideTestIndicators(true);
   HA_High  = iCustom(_Symbol,timeframe,"default\\Heiken Ashi",0,bar);
   HA_Low   = iCustom(_Symbol,timeframe,"default\\Heiken Ashi",1,bar);
   HA_Open  = iCustom(_Symbol,timeframe,"default\\Heiken Ashi",2,bar);
   HA_Close = iCustom(_Symbol,timeframe,"default\\Heiken Ashi",3,bar);
   HideTestIndicators(false);
}

double ema(ENUM_TIMEFRAMES timeframe) {
   HideTestIndicators(true);
   double ma = iMA(_Symbol,timeframe,13,0,MODE_EMA,PRICE_CLOSE,1);
   HideTestIndicators(false);
   return ma;
}

void DrawShortHLine(string objName, double pPrice, int style, color clr, int width) {   
   datetime T0 = iTime(_Symbol,PERIOD_H1,24);
   datetime T1 = Time[0];
   
   if(ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   else {
      ObjectDelete(0,ObjIdentifier+objName);
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY, false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
}

void CreatePriceFlag(string name, double price, color col){
   datetime time = Time[0]+_Period*60;
   if(ObjectFind(0,ObjIdentifier+name) != 0) ObjectCreate(0,ObjIdentifier+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
   else ObjectMove(0,ObjIdentifier+name,0, time, price);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
}

void HLine(string objName, double pPrice, int style, color clr, int width) {
   DrawShortHLine(objName,pPrice,style,clr,width);
   CreatePriceFlag(objName+"_Price",pPrice,clr);
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

void msString(string msg, long res) {
   if(!MQLInfoInteger(MQL_TESTER)) printf("%s in %s ms.",msg,StringMs(res));
}

void msString(string msg, long res, int ticket) {
   if(MQLInfoInteger(MQL_TESTER)) printf("Order #%d %s.",ticket,msg);
   else printf("Order ticket %d %s in %s ms.",ticket,msg,StringMs(res));
}
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

bool BetweenPriceRangeAskBid(double a, double b) {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick); 
   double above = fmax(a,b);
   double below = fmin(a,b);
   return tick.ask<=above && tick.bid>=below;
}

bool BetweenAccBalance(double a, double b) {
   double balance = Acc_Balance;
   double above = fmax(a,b);
   double below = fmin(a,b);
   return balance<above && balance>=below;
}

bool OutsidePriceRange(double a, double b) {
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

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool AllowedSymbol() {
   bool x = false;
   string sym = Market_Symbol;
   
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO) x = true;
   else if(sym=="EURUSD" || sym=="GBPUSD" || sym=="EURJPY"  || sym=="GBPJPY" || sym=="AUDJPY" || sym=="USDCAD") x = true;
   
   if(x) {
      if(sym=="EURUSD") MAXSPREAD = 15;
      else if(sym=="GBPUSD" || sym=="EURJPY" || sym=="AUDJPY") MAXSPREAD = 20;
   }
   else Alert("Symbol not allowed for Live Account!");
   return x;
}

double LiveAccountLot() {
   double divider = 4310.0;
   if(SymbolCurr1=="GBP") divider = 4850.0;
   double x = NormLot((Acc_Balance/divider)*0.01);
   
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO) {
      x = 0.01;
      double balance = Acc_Balance;
      double hedge = Market_MarginHedge;
      
      if(hedge==0.5) {
         // Alpari / FBS account (hedge = 0.5)
         if(balance>=600+110) {
            if(Acc_Leverage>1000 && balance>=600+110) autoLot(balance,600,110);         // Leverage 2000
            else if(Acc_Leverage>888 && balance>=1032+180) autoLot(balance,1032,180);   // Leverage 1000
            else if(Acc_Leverage>300 && balance>=1782+300) autoLot(balance,1782,300);   // Leverage 500
            else if(Acc_Leverage>200 && balance>=2778+470) autoLot(balance,2778,470);   // Leverage 300
            else if(Acc_Leverage>100 && balance>=4026+680) autoLot(balance,4026,680);   // Leverage 200
         }
      }
      else if(hedge==0.25) {
         // Roboforex ECN account (hedge = 0.25)
         if(balance>=852+142) {
            if(Acc_Leverage>888 && balance>=852+142) autoLot(balance,852,142);          // Leverage 1000 (hedge 0.25)
            else if(Acc_Leverage>300 && balance>=1416+240) autoLot(balance,1416,240);   // Leverage 500 (hedge 0.25)
            else if(Acc_Leverage>200 && balance>=2172+370) autoLot(balance,2172,370);   // Leverage 300 (hedge 0.25)
            else if(Acc_Leverage>100 && balance>=3114+520) autoLot(balance,3114,520);   // Leverage 200 (hedge 0.25)
         }
      }
   }
   return x;
}

void minimumBalance() {
   double min = 110.0;
   if(Acc_Balance<min) {
      Alert("Minimum balance required is $110.00");
      ExpertRemove();
   }
}

double autoLot(double balance, double baseline, double adder) {
   double x = 0.01;
   string sym = Market_Symbol;
   if(sym=="GBPUSD") x = lotseq(baseline,balance,adder,1);
   else if(sym=="EURJPY") x = lotseq(baseline,balance,adder,2);
   else if(sym=="EURUSD") x = lotseq(baseline,balance,adder,3);
   else if(sym=="AUDJPY") x = lotseq(baseline,balance,adder,4);
   else if(sym=="GBPJPY") x = lotseq(baseline,balance,adder,5);
   else if(sym=="USDCAD") x = lotseq(baseline,balance,adder,6);

   return x;
}

double lotseq(double baseline, double balance, double adder, int step) {
   double x = 0.01;
   
   if(Market_Symbol=="GBPJPY") baseline += 79;
   else if(SymbolCurr1=="GBP") baseline += 50;
   
   if(balance>=baseline+((step+60)*adder)) x = 0.12;
   else if(balance>=baseline+((step+54)*adder)) x = 0.11;
   else if(balance>=baseline+((step+48)*adder)) x = 0.10;
   else if(balance>=baseline+((step+42)*adder)) x = 0.09;
   else if(balance>=baseline+((step+36)*adder)) x = 0.08;
   else if(balance>=baseline+((step+30)*adder)) x = 0.07;
   else if(balance>=baseline+((step+24)*adder)) x = 0.06;
   else if(balance>=baseline+((step+18)*adder)) x = 0.05;
   else if(balance>=baseline+((step+12)*adder)) x = 0.04;
   else if(balance>=baseline+((step+6)*adder)) x = 0.03;
   else if(balance>=baseline+(step*adder)) x = 0.02;
   return x;
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

double CMoney::MarginUsed(double entryPrice, double lotsize) {
   double marginRequired   = 0, 
          CommissionCost   = 0,
          referencePrice   = refPrice();
   
   // Account Multiplier
   double multiplier = (Market_ContractSize/double(Acc_Leverage))*lotsize;
   // Margin Required
   if(SymbolCurr1==Acc_Currency) marginRequired = multiplier;
   else marginRequired = multiplier*referencePrice;
   // Commission Cost
   CommissionCost = referencePrice*lotsize*General.OrderCommissionChk();
   double raw = marginRequired+CommissionCost;
   //double raw = marginRequired;
   return round(raw/0.01)*0.01;
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

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
int CCount::OrderAll(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol) {
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

int CCount::OrderTradeSymbol(int type){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(selectSymbol(order) && selectThisEA()) {
         if(type==OP_BUY && OrderType()==OP_BUY) count++;
         else if(type==OP_SELL && OrderType()==OP_SELL) count++;
      }
   }
   return count;
}

int CCount::ThisEACount(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(selectSymbolTrade(order,MODE_TRADES) && selectThisEA()) count++;
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
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !SpreadFilterPair()) Sleep(1);
   }
   RefreshRates();
}

bool CTrade::SessionTrade() {
   datetime p,l;
   bool c = SymbolInfoSessionTrade(_Symbol,MONDAY,0,p,l);
   int p_h = TimeHour(p);
   int p_m = TimeMinute(p);
   int l_h = TimeHour(l);
   int l_m = TimeMinute(l);
   
   datetime checktime = TimeCurrent();
   if(checktime>=HourMin(0,2) && checktime<HourMin(23,58)) return true;
   else return false;
}

bool CTrade::OrderExist(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol) {
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
      Sleep(30*1000);
      return;
   }
   else if(SessionTrade() && (type==OP_BUY || type==OP_SELL)) {
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
         msString("Market order execute",ul_res);
         ScreenShot("HA_Hedge");
      }
   }
}

void CTrade::OpenBuy(int magic, double lot, string comment){
   if(!OrderExist(magic) && SpreadFilterPair()) OpenOrder(OP_BUY,magic,lot,comment);
}

void Buy(int magic, double lot, double multiplier, int level, string comment) {
   Trade.OpenBuy(magic,MartingaleLot(lot,multiplier,level),comment);
}

void Sell(int magic, double lot, double multiplier, int level, string comment) {
   Trade.OpenSell(magic,MartingaleLot(lot,multiplier,level),comment);
}

void CTrade::OpenSell(int magic, double lot, string comment){
   if(!OrderExist(magic) && SpreadFilterPair()) OpenOrder(OP_SELL,magic,lot,comment);
}

void CTrade::CloseOrder(int magic){
   if(SessionTrade() && OrderExist(magic)) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         bool select = OrderSelect(order,SELECT_BY_POS);
         if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL)){
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  TickData();
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

void CTrade::CloseOrderBySameLot(int magic1, int magic2){
   if(SessionTrade() && OrderExist(magic2) && OrderExist(magic2)) {
      double lot1 = Property.orderLot(magic1);
      double lot2 = Property.orderLot(magic2);
      int type1   = Property.type(magic1);
      int type2   = Property.type(magic2);
      int ticket2 = Property.ticket(magic2); 
      
      if(sameLot(lot1,lot2) && ticket2>0 && type1!=type2) {
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
                     TickData();
                     closeorder = OrderCloseBy(ticket2,OrderTicket(),clrRed);
                     if(closeorder) {
                        ul_res = GetMicrosecondCount()-ul;
                        msString("closedby",ul_res,OrderTicket());
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
                  if(!closeorder) OrderCloseError(OrderTicket(),"closeby");
               }
            }     
         }
      }
   }
}

void CTrade::CloseOrderByDifferentLot() {
   int magic = 0;
   if(Count.OrderAll(Magic10)>0) magic = Magic10;
   else if(Count.OrderAll(Magic9)>0) magic = Magic9;
   else if(Count.OrderAll(Magic8)>0) magic = Magic8;
   else if(Count.OrderAll(Magic7)>0) magic = Magic7;
   else if(Count.OrderAll(Magic6)>0) magic = Magic6;
   else if(Count.OrderAll(Magic5)>0) magic = Magic5;
   else if(Count.OrderAll(Magic4)>0) magic = Magic4;
   else if(Count.OrderAll(Magic3)>0) magic = Magic3;
   else if(Count.OrderAll(Magic2)>0) magic = Magic2;
   
   if(magic>0) {
      int type = Property.type(magic);
      int opposite = OP_BUY;
      if(type==OP_BUY) opposite = OP_SELL;
   
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(selectHedgingTrade(order,opposite)) {
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  TickData();
                  closeorder = OrderCloseBy(Property.ticket(magic),OrderTicket(),clrGray);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     msString("multiple closedby",ul_res,OrderTicket());
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
               if(!closeorder) OrderCloseError(OrderTicket(),"multiple closeby");
            }
         }     
      }
   }
}

bool CTrade::multiple_closeby_symbol() {
   double lot = 0;
   for(int i=OrdersTotal()-1; i>0; --i){
      if(selectSymbolTrade(i) && selectThisEA() && OrderLots()>lot) {
         ulong  ul=0, ul_res=0;
         ul = GetMicrosecondCount();
         int    first_ticket = OrderTicket();
         int    first_type   = OrderType();
         for(int j=i; j>=0; --j){
            if(selectHedgingTrade(j,!first_type) && selectThisEA()) {
               bool closeorder = false;
               TickData();
               closeorder = OrderCloseBy(first_ticket, OrderTicket(),clrPink);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  msString("closed",ul_res,OrderTicket());
                  return multiple_closeby_symbol();
               }
               else return false;
            }
         }
         Print("No More hedging orders.");
         if(Count.OrderTradeSymbol(OP_BUY)>0) Print("Buy order still running...");
         else if(Count.OrderTradeSymbol(OP_SELL)>0) Print("Sell order still running...");
         break;
      }
   }
   return true;
}


bool selectHedgingTrade(int i, int type){
   return (OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderType()==type);
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
      default:             x = "NO ORDER";
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
   Magic1   = generateID(ref);
   Magic2   = generateID(ref);
   Magic3   = generateID(ref);
   Magic4   = generateID(ref);
   Magic5   = generateID(ref);
   Magic6   = generateID(ref);
   Magic7   = generateID(ref);
   Magic8   = generateID(ref);
   Magic9   = generateID(ref);
   Magic10  = generateID(ref);
   MagicX   = generateID(ref);
}

void CTrade::OrderCloseReason(string reason, ulong countdown){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,
                                             NewLine,"Closing reason : ",sInput,
                                             NewLine,
                                             NewLine,"Basket closing time : ",sInput," ms",
                                             NewLine,"Basket closing PnL : ",sInput,
                                             NewLine,"Today's symbol PnL : ",sInput,
                                             NewLine,"Today's Daily PnL : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,reason,StringMs(countdown),StringDollar(Report.Closed_DailySymbol(PERIOD_M1)),StringDollar(Report.Closed_DailySymbol(PERIOD_D1)),StringDollar(Report.Closed_Daily()));
   Print(msg);
   if(NotiEnable) SendNotification(msg);
}

void CTrade::DebugCloseReason(string reason){
   string output_string = StringConcatenate("Failed attempt to %s");
   string msg = StringFormat(output_string,reason);
   Alert(msg);
   Print(msg);
   if(NotiEnable) SendNotification(msg);
}

void CTrade::DebugInitialized(){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,
                                             NewLine,"Floating : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,StringDollar(Report.FloatingStatusAll()));
   Print(msg);
   if(NotiEnable) SendNotification(msg);
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
double CProp::openPrice(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) ChkLevel = OrderOpenPrice();  
   }
   return ChkLevel;
}

datetime CProp::openTime(int magic){
   datetime time = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) time = OrderOpenTime();  
   }
   return time;
}

double CProp::orderLot(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) lot = OrderLots();  
   }
   return lot;
}

double CProp::orderComm(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) lot = OrderCommission();  
   }
   return lot;
}

double CProp::orderSwap(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) lot = OrderSwap();  
   }
   return lot;
}

int CProp::ticket(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(selectMagicTrade(order,magic)) type = OrderTicket();
   }
   return type;
}

int CProp::type(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol) type = OrderType();
   }
   return type;
}

int CProp::newestOrder() {
   int type = 100;
   datetime time = 0;
   for(int order = 0; order <= OrdersTotal()-1; order++) {
      if(selectSymbolTrade(order) && OrderOpenTime()>time && selectThisEA()) type = OrderType();
   }
   return type;
}

bool selectSymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

bool selectSymbol(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

bool selectThisEA() {
   return (
         OrderMagicNumber()==Magic1 ||
         OrderMagicNumber()==Magic2 ||
         OrderMagicNumber()==Magic3 ||
         OrderMagicNumber()==Magic4 ||
         OrderMagicNumber()==Magic5 ||
         OrderMagicNumber()==Magic6 ||
         OrderMagicNumber()==Magic7 ||
         OrderMagicNumber()==Magic8 ||
         OrderMagicNumber()==Magic9 ||
         OrderMagicNumber()==Magic10
   );
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

double CGeneral::TotalLotSymbol(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol) lot += OrderLots();
   }
   return lot;
}

double CGeneral::HighestOrderLot(int type){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==type && OrderLots()>lot && selectThisEA()) lot = OrderLots();
   }
   return lot;
}

double CGeneral::HighestOrderPrice() {
   double price[];
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol && selectThisEA()) {
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
      bool select=OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol && selectThisEA()) {
         ArrayResize(price,ArraySize(price)+1,0);
         price[ArraySize(price)-1] = OrderOpenPrice();
      }
   }
   if(ArraySize(price)==0) return 0;
   int index = ArrayMinimum(price,0,WHOLE_ARRAY);
   return(price[index]);
}

int CGeneral::OrderCommissionChk() {
   int x = 4;
   datetime HistoryRange = TimeCurrent()-(30*PeriodSeconds(PERIOD_D1));
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderCloseTime()>HistoryRange && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

double CGeneral::dirOrderLot(int direction) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==direction && selectThisEA()) x += OrderLots();  
   }
   return x;
}

double CGeneral::averagePrice() {
   double x = 0;
   double total = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL) && selectThisEA()) {
         x += OrderOpenPrice()*OrderLots();
      }
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
         //sum += (hi-lo);
         count--;
      }
   }
   
   lwav = sum/total;
   return int(lwav/_Point);
}

double AllOrderAvgPrice() {
   double x = 0;
   double lot = 0;
   double total = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL)) {
         x += OrderOpenPrice()*OrderLots();
         lot += OrderLots();
      }
   }
   
   if(lot>0) total = x/lot;
   return total;
}

double dirLot(int type) {
   double x = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==type) x += OrderLots();  
   }
   return x;
}

double HedgeMargin() {
   double x = 0;
   
   if(General.TotalLotSymbol()>0) {
      double buy = dirLot(OP_BUY);
      double sell = dirLot(OP_SELL);
      double multiplier = Market_ContractSize/Acc_Leverage;
      
      double avg = AllOrderAvgPrice();
      if(SymbolCurr2!=Acc_Currency) avg = Money.refPrice()-NumToPoint(1*Acc_Pips);
      
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

double hedgeCalc(double val, double total, double avg) {
   double multiplier = Market_ContractSize/Acc_Leverage;
   double a = val*2;
   double b = a*avg*multiplier*Market_MarginHedge;
   double c = (total-a)*avg*multiplier;
   return b+c;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
double CReport::FloatingStatusAll(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && (OrderType()==OP_BUY || OrderType()==OP_SELL) && selectThisEA())
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

bool selectMagicTrade(int i, int magic, int mode = MODE_TRADES){
   return (
   OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && OrderMagicNumber()==magic 
   && (OrderType()==OP_BUY || OrderType()==OP_SELL)
   );
}

double CReport::Closed_DailySymbol(ENUM_TIMEFRAMES timeframe){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(3*PeriodSeconds(timeframe));
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(selectTradeHistory(order,HistoryRange) && OrderSymbol()==_Symbol && TimeDay(OrderCloseTime())==Day())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

double CReport::Closed_Daily(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(2*PeriodSeconds(PERIOD_D1));
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      if(selectTradeHistory(order,HistoryRange) && TimeDay(OrderCloseTime())==Day())
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
   }
   return NormDollar(PnL);
}

bool selectTradeHistory(int i, datetime history){
   return (OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) && OrderCloseTime()>=history && (OrderType()==OP_BUY || OrderType()==OP_SELL) );
}

// -----------------------
void ChartSetting(bool setcolor = true){
   ChartSetInteger(0,CHART_MODE,CHART_BARS);
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
      ChartSetInteger(0,CHART_COLOR_VOLUME,clrLightSlateGray);
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

bool TradeTiming(int pStartH, int pStartM, int pEndH, int pEndM) {
   datetime time1 = HourMin(pStartH,pStartM);
   datetime time2 = HourMin(pEndH,pEndM);
   return BetweenTimeRange(time1,time2);
}

bool Friday_Filter(){
   if((DayOfWeek()==MONDAY && TimeCurrent()<HourMin(4)) || (DayOfWeek()==FRIDAY && TimeCurrent()>HourMin(18+DST_ShiftTime(),0))) return false;
   else return true;
}

void Friday_Close() {
   if(DayOfWeek()==FRIDAY && TimeCurrent()>=HourMin(23,53)) {
      double minimumProfit = 0.6;
      if(Count.OrderAll(Magic1)>0 && Report.FloatingStatusAll()>minimumProfit) funcCloseAll("Friday Closure.");
   }
}

string TimeStamp() {
   MqlDateTime tm;
   TimeToStruct(iTime(_Symbol,PERIOD_M1,0),tm);
   return StringFormat("%4d%02d%02d%02d%02d",tm.year,tm.mon,tm.day,tm.hour,tm.min);
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
      if(!ChartScreenShot(0,ScreenShotName,width,heigh)) Alert(ErrorDescription(GetLastError()));
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}

int AvgDailyRange(int range, int startbar=0){
   double sum = 0;
   int count = 0;
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
   return int((sum/count)/_Point);
}

bool AccountPermission() {
   string msg;
   bool x = false;
   for (int i=0; i<ArraySize(Allowed_Accounts); i++){
      if(Acc_Login == Allowed_Accounts[i]) {
         msg = StringConcatenate("Account number authorized.");
         Print(msg);
         x = true;
         break;
      }
   }
   if(!x) {
      msg = StringConcatenate("Account not allowed, please contact zulhairibaba@gmail.com");
      Alert(msg);
   }
   return x;
}

bool NFP() {
   bool x = false;
   if(DayOfWeek()==FRIDAY) {
      int monthNow = TimeMonth(TimeCurrent());
      int monthPre = TimeMonth(TimeCurrent()-7*PeriodSeconds(PERIOD_D1));
      if(monthNow!=monthPre) x = true;
   }
   return x;
}