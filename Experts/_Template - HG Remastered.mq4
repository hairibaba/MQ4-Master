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
#property description   "HG Remastered"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#include <Telegram.mqh>
CCustomBot bot;

#define MAXSPREAD          21
#define MAX_RETRIES        2
#define RETRY_SECONDS      2
#define IDENTIFIER_TRADE   66621

class CCount {
   public:
      int OrderAllTerminal();
      int OrderAll(int magic);
      int OrderAllTrade(int magic);   
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
   public: 
      bool FirstCheck();   
      void AssignMagic(int identifier);
      void OpenOrder(int type, int magic, double lot, string comment);
      bool ExpiredOrder(int magic, int bar, ENUM_TIMEFRAMES timeframe);
      void CloseOrder(int magic);
      void PartialClose(int magic, double lot);

      void ModifyStopLoss(int magic, double stopPrice);
      void ModifyTakeProfit(int magic, double takePrice);
      
      void CloseGhostOrder();
      void DeleteGhostOrder();
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
      double HG_FullMarginLot(double MinMarginPercentage = 120, int divider = 1, double CommPerStdLot = 4);
      double getReferencePrice();
}Money;

class CFeatures {
   public:
      void HiddenSL(int magic, int stopPoint);
      void BreakEven(int magic, int distance, int lock = 10);
      void ProtectingTarget(int magic, double TP_Level = 0, int trigger = 20, int lock = 20);
      void ProtectingTargetScalp(int magic, int lock = 5);
}Features;

class CGeneral {
   public:
      int OrderCommissionChk();
      double TotalLotSymbol();
}General;

class CReport {
   public:
      double Closed_Daily();
      double Closed_Weekly();
      double Closed_Monthly();
      double FloatingStatusTerminal();
      double TradePL(int magic);

}Report;

class CProp {
   public:
      int type(int magic);
      double orderLot(int magic);
      double stopLoss(int magic);
      double takeProfit(int magic);
      datetime openTime(int magic);
      double openPrice(int magic);
      bool justClose(int magic, int minutesAgo, double& closePrice, datetime& closeTime, int& pipsClose, double& pnl, int& duration);
}Property;

// --- Input Variable ------------------------------------------------------------------
input bool     ActivateEA     = true,
               UseLimitEquity = false;
input double   MaxEquity      = 1980.0;

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
const int   Allowed_Accounts[]   = {924635,2090128619};  // Demo      
string      ObjIdentifier  = "HGX_",
            CommentSwing   = "PoundTrader ",
            AllowSysmbol   = "GBPUSD";
int         MagicHedge,Magic1,
            MagicX1,MagicX2,MagicX3,MagicX4,MagicX5,MagicX6,
            lastClosedPip;
bool        useComplimentaryOrder   = true;
static int  minRecMargin   = 1000,
            maxRecMargin   = 100;

//--- input parameters for Telegram
bool        publishTelegram  = true;
string      InpChannelName   = "GBPUSDScalping",                                   // Channel Name
            InpToken         = "643900677:AAGYa11O9YzCah9rQwp_C-fgPeSpXra8M3c";    // Token

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   else if(LiveOperation() && publishTelegram && !TelegramInit()) return INIT_FAILED;
   
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   
   // Account Inilization Start
   ChartHistory();
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   ChartSetting();
   if(!AllowedSymbol(AllowSysmbol) || !AccountPermission()) return INIT_FAILED;
   
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
   SentStatus(23,53,Report.Closed_Daily(),Report.Closed_Weekly(),Report.Closed_Monthly());
   
   GhostOrder();
   ManageComplimentaryOrder();
   PipExit();
   EquityControl();
   /*
   SystemSwing(OP_SELL,19,12,6,25,1.2617,5*58); // test expired
   SystemSwing(OP_BUY,20,12,23,30,1.2690,5*3,true); // test stoploss
   SystemSwing(OP_BUY,20,12,9,25,1.27,5*3,true); // test stoploss
   SystemSwing(OP_SELL,20,12,12,35,1.2656,5*3,true); // test stoploss
   */
   
   SystemSwing(OP_SELL,21,3,9,15,1.3107,49*5);
   SystemSwing(OP_SELL,21,3,16,5,1.3012,29*5);
   SystemSwing(OP_BUY,21,3,19,50,1.3132,45*5);
   SystemSwing(OP_SELL,22,3,10,5,1.3083,18*5);
   SystemSwing(OP_BUY,22,3,11,45,1.3219,77*5);
   SystemSwing(OP_SELL,25,3,11,1,1.3164,102);
   SystemSwing(OP_SELL,22,3,18,2,1.3181,85);
   SystemSwing(OP_BUY,25,3,9,40,1.3213,16*5);
   SystemSwing(OP_BUY,25,3,13,41,1.3245,52);
   SystemSwing(OP_SELL,25,3,17,48,1.3168,44);
   
   /*
   SystemSwing(OP_SELL,21,3,9+1,15,1.3107,49*5);
   SystemSwing(OP_SELL,21,3,16+1,5,1.3012,29*5);
   SystemSwing(OP_BUY,21,3,19+1,50,1.3132,45*5);
   SystemSwing(OP_SELL,22,3,10+1,5,1.3083,18*5);
   SystemSwing(OP_BUY,22,3,11+1,45,1.3219,77*5);
   SystemSwing(OP_SELL,25,3,11+1,1,1.3164,102);
   SystemSwing(OP_SELL,22,3,18+1,2,1.3181,85);
   SystemSwing(OP_BUY,25,3,9+1,40,1.3213,16*5);
   SystemSwing(OP_BUY,25,3,13+1,41,1.3245,52);
   SystemSwing(OP_SELL,25,3,17+1,48,1.3168,44);
   */

   
   if(Acc_MarginLevel>0) {
      if(Acc_MarginLevel<minRecMargin) minRecMargin = Acc_MarginLevel;
      if(Acc_MarginLevel<2000) {
         if(Acc_MarginLevel>maxRecMargin) maxRecMargin = Acc_MarginLevel;
      }
   }
   Comment(
   "\n\n MarginLevel : ",Acc_MarginLevel,
   "\n\n Min Recorder Margin : ",minRecMargin,
   "\n\n Max Recorder Margin : ",maxRecMargin);
}

bool BalanceControl() {
   bool x = true;
   if(UseLimitEquity) {
      double balancelimit = MaxEquity*0.995;
      if(Acc_Balance>=balancelimit) x = false;
   }
   return x;
}

void EquityControl() {
   if(UseLimitEquity) {
      double extreme = MaxEquity*1.008;
      if(Acc_Equity>=extreme) {
         Trade.CloseOrder(Magic1);
         Trade.CloseOrder(MagicX1);
         Trade.CloseOrder(MagicX2);
         Trade.CloseOrder(MagicX3);
         Trade.CloseOrder(MagicX4);
         Trade.CloseOrder(MagicX5);
         Trade.CloseOrder(MagicX6);
         PipExit();
      }
      else if(Acc_Equity>=MaxEquity) {
         Features.ProtectingTargetScalp(Magic1,10);
         Features.ProtectingTargetScalp(MagicX1,10);
         Features.ProtectingTargetScalp(MagicX2,10);
         Features.ProtectingTargetScalp(MagicX3,10);
         Features.ProtectingTargetScalp(MagicX4,10);
         Features.ProtectingTargetScalp(MagicX5,10);
         Features.ProtectingTargetScalp(MagicX6,10);
      }
      
      if(!BalanceControl()) {
         if(Count.OrderAllTrade(Magic1)==0 && 
            Count.OrderAllTrade(MagicX1)==0 && 
            Count.OrderAllTrade(MagicX2)==0 && 
            Count.OrderAllTrade(MagicX3)==0 && 
            Count.OrderAllTrade(MagicX4)==0 && 
            Count.OrderAllTrade(MagicX5)==0 && 
            Count.OrderAllTrade(MagicX6)==0) {
            if(Acc_Type=="Real") WithdrawText();
            ExpertRemove();
         }
      }
   }
}

void ComplimentaryOrder(int type, double masterEntry, double masterExit) {
   if(NewBar(PERIOD_M5) && Acc_MarginLevel>=200) {
      bool proceedOrder    = false;
      bool safeLevel       = false;
      double bufferStart   = NumToPoint(180);
      double bufferEnd     = NumToPoint(100+MAXSPREAD);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(type==OP_BUY) {
         if(tick.ask<masterExit-bufferEnd) {
            safeLevel = true;
            if(tick.bid>=masterEntry+bufferStart) proceedOrder = true;
         }
      }
      else if(type==OP_SELL) {
         if(tick.bid>masterExit+bufferEnd) {
            safeLevel = true;
            if(tick.ask<=masterEntry-bufferStart) proceedOrder = true;
         }
      }
      
      int minMargin = 850;
      if(Acc_Leverage>1000)      minMargin += 250; // Leverage 2000
      else if(Acc_Leverage>888)  minMargin += 150; // Leverage 1000
      else if(Acc_Leverage>500)  minMargin += 100; // Leverage 888
      else if(Acc_Leverage>300)  minMargin += 50;  // Leverage 500
      
      if(safeLevel) {
         bool order1 = Count.OrderAllTrade(MagicX1)>0;
         if(proceedOrder || order1 || Acc_MarginLevel>minMargin) {
            bool order2 = Count.OrderAllTrade(MagicX2)>0;
            bool order3 = Count.OrderAllTrade(MagicX3)>0;
            bool order4 = Count.OrderAllTrade(MagicX4)>0;
            bool order5 = Count.OrderAllTrade(MagicX5)>0;
            bool order6 = Count.OrderAllTrade(MagicX6)>0;
            
            double lot = ComplimentaryLot();
            
            if(!order1) OpenSeqOrder(MagicX1,type,lot,CommentSwing+Market_Symbol);
            else if(!order2) OpenSeqOrder(MagicX2,type,lot,CommentSwing+Market_Symbol);
            else if(!order3) OpenSeqOrder(MagicX3,type,lot,CommentSwing+Market_Symbol);
            else if(!order4) OpenSeqOrder(MagicX4,type,lot,CommentSwing+Market_Symbol);
            else if(!order5) OpenSeqOrder(MagicX5,type,lot,CommentSwing+Market_Symbol);
            else if(!order6) OpenSeqOrder(MagicX6,type,lot,CommentSwing+Market_Symbol);
         }
      }
   }
}

void ManageComplimentaryOrder() {
   EachComplimentary(MagicX1);
   EachComplimentary(MagicX2);
   EachComplimentary(MagicX3);
   EachComplimentary(MagicX4);
   EachComplimentary(MagicX5);
   EachComplimentary(MagicX6);
}

void EachComplimentary(int magic) {
   if(Count.OrderAllTrade(magic)>0) {
      int type = Property.type(magic);
      double op = Property.openPrice(magic);
      double bufferBuy = NumToPoint(111);
      double bufferSell = NumToPoint(111+Market_Spread);
      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      
      if((type==OP_BUY && tick.bid>=op+bufferBuy) || (type==OP_SELL && tick.bid<=op-bufferSell)) Features.ProtectingTargetScalp(magic,10);
      if(Count.OrderAllTrade(Magic1)==0) Features.ProtectingTargetScalp(magic);
   }
}

void WithdrawText(){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Withdraw Alert!",
                                             NewLine,"Broker : ",sInput,
                                             NewLine,"Acc No : %d (",sInput,")",
                                             NewLine,"Acc Balance : ",sInput
                                           );
      
   string msg = StringFormat(output_string,Acc_Broker,Acc_Login,Acc_Type,StringDollar(Acc_Balance));
   Alert(msg);
   Print(msg);
   SendNotificationFunction(msg);
}

double AssigningLotHG(int type, bool hitstop) {
   double x = Market_MinLot;
   
   int limitpercent = fmax(Acc_MarginCall+25,125);
   if(type==OP_SELL)             limitpercent += 5;
   if(TimeCurrent()<HourMin(7))  limitpercent += 50;
   
   if(Acc_Leverage>1000)         limitpercent += 75;  // Leverage 2000
   else if(Acc_Leverage>888)     limitpercent += 50;  // Leverage 1000
   else if(Acc_Leverage>500)     limitpercent += 25;  // Leverage 888
   else if(Acc_Leverage>300)     limitpercent += 15;  // Leverage 500
   
   if(hitstop) {
      limitpercent += 100;
      return singledigitLot(Money.HG_FullMarginLot(limitpercent,20,4),0.1);
   }
   x = Money.HG_FullMarginLot(limitpercent,1,4);
   if(x>1) return singledigitLot(x,0.1);
   return x;
}

double singledigitLot(double value, double rounding) {
   if(value>Market_MinLot) {
      if(value>10) return floor(value);
      return floor(value/rounding)*rounding;
   }
   return value;
}

double ComplimentaryLot() {
   if(Count.OrderAllTrade(Magic1)>0) {
      double lot = Property.orderLot(Magic1);
      if(lot>10) {
         double x = Money.HG_FullMarginLot(350,6,4);
         if(x>1) return singledigitLot(x,0.1);
         return x;
      }
      else if(lot>2) return Money.HG_FullMarginLot(400,6,4);
   }
   return Money.HG_FullMarginLot(450,6,4);
}

bool NewTradeSeq(int month,int day, int hour, int minutes){
   bool x = false;
   if(month>=1 && month<=12 && day>=1 && day<=31 && hour>=0 && hour<=23 && minutes>=0 && minutes<=59) {
      datetime useTime = TimeCurrent();
      int year = TimeYear(useTime);
      int thisMin = minutes;
      int thisHour = hour;
      if(minutes==0) {
         thisMin=60;
         thisHour -= 1;
      }
      if(useTime>=ExactTime(year,month,day,thisHour,thisMin-1,58) && useTime<=ExactTime(year,month,day,hour,minutes,25)) x = true;
   }
   return x;
}

bool HGTiming(int magic, int month, int day, int hour, int minutes) {
   datetime useTime = TimeCurrent();
   int year = TimeYear(useTime);
   int thisMinStart = minutes;
   int thisMinEnd = minutes;
   int thisHourStart = hour;
   int thisHourEnd = hour;
   int thisDayEnd = day;
   if(minutes==0) {
      thisMinStart   = 60;
      thisHourStart -= 1;
   }
   else if(minutes==58) {
      thisMinEnd     = 0;
      if(hour==23) {
         thisHourEnd = 0;
         thisDayEnd += 1;
      }
      else thisHourEnd += 1;
   }
   
   datetime OT = Property.openTime(magic);
   return OT>=ExactTime(year,month,day,thisHourStart,thisMinStart-1) && OT<=ExactTime(year,month,thisDayEnd,thisHourEnd,thisMinEnd+2);
}

void OpenSeqOrder(int magic, int type, double lot, string comment){
   if(Count.OrderAllTrade(magic)==0 && SpreadFilterPair()) {
      int marReq = 200;
      if(Acc_Leverage>1000)      marReq = 500;  // Leverage 2000
      else if(Acc_Leverage>888)  marReq = 400;  // Leverage 1000
      else if(Acc_Leverage>500)  marReq = 300;  // Leverage 888
      else if(Acc_Leverage>300)  marReq = 250;  // Leverage 500
      
      if(MarginLevelProcced(marReq)) Trade.OpenOrder(type,magic,lot,comment);
   }
}

void RangePeriod(ENUM_TIMEFRAMES timeframe, int range, double& pricehigh, double& pricelow){
   int shiftHighest = iHighest(_Symbol,timeframe,MODE_HIGH,range,0);
   int shiftLowest = iLowest(_Symbol,timeframe,MODE_LOW,range,0);
   pricehigh = iHigh(_Symbol,timeframe,shiftHighest);
   pricelow = iLow(_Symbol,timeframe,shiftLowest);
}

void SystemSwing(int type, int day, int month, int hour, int minutes, double pTakeProfit, int limitbar, bool hitStop = false){
   if(Count.OrderAllTrade(Magic1)>0) {
      if(HGTiming(Magic1,month,day,hour,minutes)) {
         int useLimitbar = limitbar;
         if(hitStop && limitbar>15) useLimitbar = 15;
         if(Trade.ExpiredOrder(Magic1,useLimitbar,PERIOD_M1)) {
            double lot = Property.orderLot(Magic1);
            double pnl = Report.TradePL(Magic1);
            double minimumProfit = lot*20;
            if(pnl>=minimumProfit) Features.ProtectingTargetScalp(Magic1);
            else Trade.CloseOrder(Magic1);
         }
         else {
            ManageStopLoss(pTakeProfit);
            ManageTakeProfit(pTakeProfit);
            if(!hitStop && useComplimentaryOrder) {
               double op = Property.openPrice(Magic1);
               ComplimentaryOrder(type,op,pTakeProfit);
            }
         }      
      }
   }
   else {
      if(ActivateEA && Trade.FirstCheck() && NewTradeSeq(month,day,hour,minutes)) {
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         bool correctswing = ((type==OP_BUY && pTakeProfit>tick.ask) || (type==OP_SELL && pTakeProfit<tick.bid));
         if(correctswing) {
            if(!BalanceControl()) {
               string msg = "Account balance exceeding buffer limit. Current balance : "+StringDollar(Acc_Balance);
               Alert(msg);
               Print(msg);
               SendNotificationFunction(msg);
               SleepSeconds(200);
            }
            else {
               double useLot = AssigningLotHG(type,hitStop);
               OpenSeqOrder(Magic1,type,useLot,CommentSwing+Market_Symbol);
               if(Count.OrderAllTrade(Magic1)>0 && LiveOperation()) {
                  ScreenShot("HolyGrail");
                  TelegramEntrySignal(type,Property.openPrice(Magic1));
               }
            }
         }
      }
   }
}

void ManageStopLoss(double pTakeProfit) {
   double sl = Property.stopLoss(Magic1);
   if(sl==0) {
      double op = Property.openPrice(Magic1);
      int type = Property.type(Magic1);
      int useTrail = 300;
      if(pTakeProfit>0) {
         int range = PointToInt(fabs(pTakeProfit-op)*0.35);
         useTrail = fmax(300,range);
         if(useTrail>500) useTrail = 500;
      }
      
      int stop = 100;
      if(type==OP_SELL) stop += MAXSPREAD;
      Features.HiddenSL(Magic1,stop);
      Features.BreakEven(Magic1,useTrail,30);
   }
}

void ManageTakeProfit(double pTakeProfit) {
   if(Count.OrderAllTrade(Magic1)>0 && pTakeProfit>0) {
      double rangeTrigger = NumToPoint(100);
      if(BetweenPriceRange(pTakeProfit-rangeTrigger,pTakeProfit+rangeTrigger)) {
         RefreshRates();
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         double RangeHigh,RangeLow;
         double ProtectInitial,ProtectSecure;
         double distanceTri = NumToPoint(20);
         double dist_ProtectInitial = NumToPoint(20);
         double dist_ProtectSecure  = NumToPoint(10);
         
         double lot = Property.orderLot(Magic1);
         double partialCloseLot = NormLot(lot*0.40);
         bool firstTickM1 = FirstTick(PERIOD_M1);
         
         int dir = Property.type(Magic1);
         RangePeriod(PERIOD_M1,10,RangeHigh,RangeLow);
         
         if(dir==OP_BUY) {
            ProtectInitial = pTakeProfit-dist_ProtectInitial;
            ProtectSecure  = pTakeProfit-dist_ProtectSecure;
            
            if(tick.bid>=ProtectInitial || RangeHigh>=ProtectInitial) Features.ProtectingTarget(Magic1,pTakeProfit);
            if(tick.bid>=pTakeProfit) Trade.CloseOrder(Magic1);
            else if(tick.bid>=ProtectSecure || RangeLow>=ProtectSecure) {
               Features.ProtectingTargetScalp(Magic1);
               if(firstTickM1) Trade.PartialClose(Magic1,partialCloseLot);
            }
         }
         else if(dir==OP_SELL) {
            ProtectInitial = pTakeProfit+dist_ProtectInitial;
            ProtectSecure  = pTakeProfit+dist_ProtectSecure;
            
            if(tick.bid<=ProtectInitial || RangeLow<=ProtectInitial) Features.ProtectingTarget(Magic1,pTakeProfit);
            if(tick.bid<=pTakeProfit) Trade.CloseOrder(Magic1);
            else if(tick.bid<=ProtectSecure || RangeLow<=ProtectSecure) {
               Features.ProtectingTargetScalp(Magic1);
               if(firstTickM1) Trade.PartialClose(Magic1,partialCloseLot);
            }
         }
      }
   }
}

void GhostOrder() {
   if(Count.OrderAllTerminal()>0) {
      Trade.CloseGhostOrder();
      Trade.DeleteGhostOrder();
   }
}

bool AllowedSymbol(string symbol) {
   bool x = false;
   if(Market_Symbol==symbol) x = true;
   
   if(!x) Alert("Symbol not allowed!");
   return x;
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
   Acc_Slippage         = 5;
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
      Acc_Slippage    = 50;
      Acc_Pips = 10;
   }
}

double ZeroDivided(double value) {
   double tempVal = 1.0;
   if(value!=0) tempVal = value;
   return tempVal;
}

bool PendingLevelsChk(string obj, int limit, double& level){
   double buffer  = NumToPoint(limit+Market_Spread);
   level   = NormPrice(ObjectGetValueByShift(ObjIdentifier+obj,0));
   if(level!=0) return BetweenPriceRange(level+buffer,level-buffer);
   else return false;
}

void SentStatus(int hour, int minutes, double report1, double report2, double report3) {
   string NewLine = "\n", sInput  = "%s";
   datetime time1 = HourMin(hour,minutes);
   datetime time2 = HourMin(hour,minutes+1);
   
   if(BetweenTimeRange(time1,time2) && FirstTick(PERIOD_M1)) {
      string floating = "No Order";
      string acc = " ("+Acc_Type+")";
      if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(Report.FloatingStatusTerminal()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel));
      
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
   OrderMagicNumber()==MagicX1      ||
   OrderMagicNumber()==MagicX2      ||
   OrderMagicNumber()==MagicX3      ||
   OrderMagicNumber()==MagicX4      ||
   OrderMagicNumber()==MagicX5      ||
   OrderMagicNumber()==MagicX6
   );
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

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool MarginLevelProcced(int margin){
   int marginLvl = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   return marginLvl==0 || marginLvl>=margin;
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

double RoundUp(double var, double rounding) {
   return ceil(var/rounding)*rounding;
}

double RoundDn(double var, double rounding) {
   return floor(var/rounding)*rounding;
}

double Round(double var, double rounding) {
   return round(var/rounding)*rounding;
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

double CMoney::HG_FullMarginLot(double MinMarginPercentage = 120, int divider = 1, double CommPerStdLot = 4) {
   int buffer                    = 3*Acc_Pips;
   int margin                    = Market_Spread*2;
   double LotSize                = Market_MaxLot;
   double LevMargin              = Market_ContractSize/double(Acc_Leverage);
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
   if(Acc_Balance<100) divider_starter += 0.01;
   double Extreme = Acc_Balance/divider_starter;
   
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

void CTrade::CloseGhostOrder(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.TerminalTrade(order) && !Select.ThisEA()) {
         string msg = "Ghost order detected on "+OrderSymbol()+" with magic "+IntegerToString(OrderMagicNumber());
         Alert(msg);
         SendNotificationFunction(msg);
         
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

void CTrade::DeleteGhostOrder(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      if(Select.TerminalPending(order) && !Select.ThisEA()) {
         string msg = "Ghost order detected on "+OrderSymbol()+" with magic "+IntegerToString(OrderMagicNumber());
         Alert(msg);
         SendNotificationFunction(msg);
         
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
   
   if(sym=="GBPUSD") x = 1;
   else if(sym=="GBPJPY") x = 2;
   else if(sym=="GBPAUD") x = 3;
   else if(sym=="GBPNZD") x = 4;
   else if(sym=="GBPCHF") x = 5;
   else if(sym=="GBPCAD") x = 6;

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
   MagicX1     = generateID(ref);
   MagicX2     = generateID(ref);
   MagicX3     = generateID(ref);
   MagicX4     = generateID(ref);
   MagicX5     = generateID(ref);
   MagicX6     = generateID(ref);

   DebugPrint("Magic Number assigned = "+IntegerToString(Magic1));
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

void CFeatures::BreakEven(int magic, int distance, int lock = 10){
   if(Count.OrderAllTrade(magic)>0 && distance>lock && lock>=0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(Select.MagicTrade(order,magic)) {         
            double TrailingLevel;
            double LockBE = 0;
            double buffer_distance = NumToPoint(distance);
            double buffer_lock = NumToPoint(lock);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            
            bool x = false;
            if(OrderType() == OP_SELL){
               TrailingLevel = OrderOpenPrice() - buffer_distance;
               LockBE = OrderOpenPrice() - buffer_lock;
               if(tick.ask<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) x = true;
            }
            else if(OrderType() == OP_BUY){
               TrailingLevel = OrderOpenPrice() + buffer_distance;
               LockBE = OrderOpenPrice() + buffer_lock;
               if(tick.bid>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) x = true;
            }
            
            if(x) {
               Trade.ModifyStopLoss(magic,LockBE);
               if(magic==Magic1) BotMsgBE(Market_Symbol,2);
            }
         } 
      } 
   }
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

void CFeatures::ProtectingTargetScalp(int magic, int lock = 5) {
   if(Count.OrderAllTrade(magic)>0) {
      int type = Property.type(magic);
      double SL = Property.stopLoss(magic);
      double dis_lock = NumToPoint(lock)+Market_StopFreeze;
      double TriggerSL;

      RefreshRates();
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);
      if(type==OP_BUY) {
         TriggerSL = tick.bid-dis_lock;
         if(SL<TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
      }
      else if(type==OP_SELL) {
         TriggerSL = tick.ask+dis_lock;
         if(SL>TriggerSL || SL==0) Trade.ModifyStopLoss(magic,TriggerSL);
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

bool CProp::justClose(int magic, int minutesAgo, double& closePrice, datetime& closeTime, int& pipsClose, double& pnl, int& duration) {
   bool x = false;
   datetime time = -1;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*PeriodSeconds(PERIOD_M1));
   
   int      temptype    = 100;
   double   tempPrice   = 0,
            tempOpen    = 0,
            tempPnl     = 0;
   datetime tempTime    = 0,
            tempTimeSt  = 0;
   
   for(int order = 0; order <= OrdersHistoryTotal()-1; order++) {
      if(Select.MagicTrade(order,magic,MODE_HISTORY) && Select.ThisEA() && OrderCloseTime()>HistoryRange && OrderCloseTime()>time) {
         x = true;
         temptype    = OrderType();
         tempPrice   = OrderClosePrice();
         tempOpen    = OrderOpenPrice();
         tempTime    = OrderCloseTime();
         tempTimeSt  = OrderOpenTime();
         tempPnl     = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   closePrice  = tempPrice;
   closeTime   = tempTime;
   pnl         = NormDollar(tempPnl);
   duration    = int((tempTime-tempTimeSt)/60);
   if(temptype==OP_BUY) pipsClose = PointToInt((tempPrice-tempOpen)/Acc_Pips);
   else if(temptype==OP_SELL) pipsClose = PointToInt((tempOpen-tempPrice)/Acc_Pips);
   
   return x;
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

double CReport::TradePL(int magic){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(Select.MagicTrade(order,magic)) PnL += OrderProfit()+OrderCommission()+OrderSwap(); 
   }
   return NormDollar(PnL);
}

void ChartSetting(bool setcolor = true){
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(0,CHART_SCALE,3);
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

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
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

void ScreenShot(string directory = "TradeScreenshot", bool entry = true) {
   if(LiveOperation()) {
      string filetype = ".gif";
      int width = int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));   // Chart's width
      int heigh = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear()+"/"+Market_Symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string when = "Entry";
      if(!entry) when = "Exit";
      string pairscreen = Market_Symbol+"_"+when+"_"+TimeStamp()+filetype;
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

// ------- Telegram Features
bool TelegramInit() {
   if(StringLen(InpChannelName)==0){
      Alert("Error: Channel name is empty");
      return false;
   }
   
   bot.Token(InpToken);
   int result = bot.GetMe();
   
   if(result!=0) {
      Alert("Error: ",GetErrorDescription(result));
      return false;
   }
   else Print("Bot name: ",bot.Name());
   return true;
}

void TelegramEntrySignal(int type, double price) {
   if(publishTelegram && LiveOperation()) {
      string emoji = "\x203C";
      string signal = "BUY ";
      if(type==OP_SELL) signal = "SELL ";
      
      string constructor = StringConcatenate(emoji," <strong>",signal,Market_Symbol,"</strong> ",emoji," \nServer Time: %s \nEntry Price : %s \nStoploss : 10pips");
      string time =  TimeToString(TimeCurrent());
      BotMsg(constructor,time,StringPrice(price));
   }
}

void TelegramExitSignal(datetime timeClose, double price, int pip, int duration) {
   if(publishTelegram && LiveOperation()) {
      string emoji = "\xF4B0";
      string how = "CLOSE WITH PROFIT ";
      if(pip<=0) how = "CUTLOSS / STOPLOSS ";
      string constructor = StringConcatenate(emoji,emoji," <strong>",how,Market_Symbol,"</strong> ",emoji,emoji," \nServer Time: %s \nExit Price : %s \nPips Gain/Loss : %d pips \nTrade duration : %d minute(s)");
      string time =  TimeToString(timeClose);
      BotMsg(constructor,time,StringPrice(price),pip,true,duration);
   }
}

void BotMsg(string constructor, string time, string price, int pip = 0, bool exit = false, int duration = 0) {
   string msg = "";
   if(exit) msg = StringFormat(constructor,time,price,pip,duration);
   else msg = StringFormat(constructor,time,price);
   
   int res=bot.SendMessage(InpChannelName,msg);
   if(res!=0) Print("Error: ",GetErrorDescription(res));
   else Print("Signal Telegram sent!");
}

void BotMsgBE(string symbol, int pip) {
   if(publishTelegram && LiveOperation()) {
      string msg = StringConcatenate(symbol," move to Breakeven + ",pip,"pip");
      
      int res=bot.SendMessage(InpChannelName,msg);
      if(res!=0) Print("Error: ",GetErrorDescription(res));
      else Print("Signal Telegram sent!");
   }
}

void PipExit() {
   int pip,duration;
   double closePrice,pnl;
   datetime closeTime;
   static int pipclose = 0;
   static double profitloss = 0;
   if(Property.justClose(Magic1,1,closePrice,closeTime,pip,pnl,duration)) {
      if(profitloss!=pnl) {
         profitloss = pnl;
         pipclose = pip;
         CloseNotifier(pip,pnl);
         ScreenShot("HolyGrail",false);
         TelegramExitSignal(closeTime,closePrice,pip,duration);
      }
   }
}

void CloseNotifier(int pip, double pnl) {
   string NewLine = "\n", sInput  = "%s", space = " ";
   string acc = " ("+Acc_Type+")";
   double report = Report.Closed_Daily();
   
   string output_string = StringConcatenate("Broker : ",sInput,space,
                                            NewLine,"Acc Number : %d ",sInput,space,
                                            NewLine,"Last closed Pips : %d pips ",
                                            NewLine,"Last closed PnL  : ",sInput,space,
                                            NewLine,
                                            NewLine,"Acc Balance : ",sInput,space,
                                            NewLine,"PnL Today : ",sInput," (",sInput,")"
                                            );
                           
   string msg = StringFormat( output_string,
                                 Acc_Broker,
                                 Acc_Login,acc,
                                 pip,
                                 StringDollar(pnl),
                                 StringDollar(Acc_Balance),
                                 StringDollar(report),ReturnPercent(report)
                               );
   Print(msg);
   SendNotificationFunction(msg);
}